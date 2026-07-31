#!/usr/bin/env bash
# utopia-zero analytics: append one event to zero/analytics/events.jsonl
# usage: bash zero/scripts/log_event.sh <type> ['<json-payload>']
# Silent no-op when analytics_enabled=false. Never fails the caller.
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
exit 0
