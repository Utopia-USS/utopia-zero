#!/usr/bin/env bash
# utopia-zero analytics: append one event to zero/analytics/events.jsonl
# usage: bash zero/scripts/log_event.sh <type> ['<json-payload>']
# Silent no-op when analytics_enabled=false. Never fails the caller.
# Enforces the event catalog (references/analytics.md): a payload missing a
# required key still gets logged, but with a _schema_warning field and a line
# on stderr - drifting payloads are a data bug, not a style choice.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONFIG="$ROOT/zero/config.json"
AN="$ROOT/zero/analytics"

TYPE="${1:-note}"
PAYLOAD="${2:-}"
[ -z "$PAYLOAD" ] && PAYLOAD="{}"

cfg() {
  grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$CONFIG" 2>/dev/null \
    | head -1 | sed 's/.*"\([^"]*\)"$/\1/'
}
flag() {
  grep -Eo "\"$1\"[[:space:]]*:[[:space:]]*(true|false)" "$CONFIG" 2>/dev/null \
    | head -1 | grep -Eo '(true|false)$'
}

[ "$(flag analytics_enabled)" = "false" ] && exit 0

redact() {
  sed -E \
    -e 's/github_pat_[A-Za-z0-9_]+/[REDACTED]/g' \
    -e 's/gh[pousr]_[A-Za-z0-9]{10,}/[REDACTED]/g' \
    -e 's/x-access-token:[^@"]*@/[REDACTED]@/g' \
    -e 's/sk-[A-Za-z0-9_-]{16,}/[REDACTED]/g' \
    -e 's/AIza[A-Za-z0-9_-]{30,}/[REDACTED]/g' \
    -e 's/Bearer [A-Za-z0-9._-]{16,}/Bearer [REDACTED]/g' \
    -e 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/[EMAIL]/g'
}

# --- event catalog: required payload keys per type (analytics.md) ---
required_keys() {
  case "$1" in
    session_start) echo "source" ;;
    session_end) echo "models" ;;
    tutorial) echo "skipped" ;;
    consent) echo "analytics" ;;
    env) echo "os" ;;
    model_info) echo "model" ;;
    question) echo "id mode topic" ;;
    answer) echo "id mode length_chars changed_prior" ;;
    decision) echo "area choice rationale alternatives user_involved" ;;
    user_override) echo "ref from to" ;;
    build) echo "target ok" ;;
    error) echo "category signature found_by" ;;
    fix_attempt) echo "n strategy ok" ;;
    stuck) echo "attempts action" ;;
    checkpoint) echo "feature verdict rework" ;;
    feature_start) echo "name" ;;
    feature_done) echo "name commits" ;;
    scope_request) echo "summary handled" ;;
    backend_step) echo "provider step delegated_to" ;;
    language_switch) echo "from to" ;;
    survey) echo "stage scores" ;;
    handover_selfscore) echo "scores total" ;;
    stage_start|stage_end|note) echo "" ;;
    *) echo "__unknown__" ;;
  esac
}

WARN=""
REQ="$(required_keys "$TYPE")"
if [ "$REQ" = "__unknown__" ]; then
  WARN="unknown event type '$TYPE' - use a catalog type from analytics.md, or note the new type in HANDOVER"
elif [ -n "$REQ" ]; then
  MISSING=""
  for k in $REQ; do
    printf '%s' "$PAYLOAD" | grep -q "\"$k\"" || MISSING="$MISSING$k,"
  done
  MISSING="${MISSING%,}"
  [ -n "$MISSING" ] && WARN="missing required keys: $MISSING"
fi
if [ -n "$WARN" ]; then
  echo "utopia-zero log_event SCHEMA WARNING ($TYPE): $WARN. Event logged anyway - fill the catalog keys next time (extra keys are welcome, missing ones break the analysis)." >&2
  # inject the warning into the payload (payload is a one-line JSON object)
  P_TRIM="$(printf '%s' "$PAYLOAD" | sed 's/[[:space:]]*$//')"
  case "$P_TRIM" in
    "{}") PAYLOAD="{\"_schema_warning\":\"$WARN\"}" ;;
    *"}") PAYLOAD="${P_TRIM%\}},\"_schema_warning\":\"$WARN\"}" ;;
  esac
fi

TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
PARTICIPANT="$(cfg participant_id)"
PROJECT="$(cfg project_id)"
SESSION="$(cat "$AN/.session" 2>/dev/null || echo "s0")"
STAGE="$(cat "$AN/.stage" 2>/dev/null || echo "0")"

PAYLOAD="$(printf '%s' "$PAYLOAD" | redact | tr '\n' ' ')"

mkdir -p "$AN"
printf '{"ts":"%s","participant_id":"%s","project_id":"%s","session_id":"%s","stage":"%s","type":"%s","payload":%s}\n' \
  "$TS" "${PARTICIPANT:-unknown}" "${PROJECT:-unknown}" "${SESSION:-s0}" "${STAGE:-0}" "$TYPE" "$PAYLOAD" \
  >> "$AN/events.jsonl" 2>/dev/null

# --- pulse-survey counter: feature_done increments, survey resets ---
PULSE="$AN/.pulse"
case "$TYPE" in
  feature_done)
    C="$(cat "$PULSE" 2>/dev/null || echo 0)"
    case "$C" in (*[!0-9]*|'') C=0 ;; esac
    printf '%s' "$((C + 1))" > "$PULSE" 2>/dev/null
    ;;
  survey)
    printf '0' > "$PULSE" 2>/dev/null
    ;;
esac
exit 0
