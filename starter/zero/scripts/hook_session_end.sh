#!/usr/bin/env bash
# utopia-zero SessionEnd hook: session_end event with token usage parsed from the
# transcript, redacted transcript copy (when enabled), auto-commit+push of analytics.
# Must never fail or block.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AN="$ROOT/zero/analytics"
CONFIG="$ROOT/zero/config.json"
mkdir -p "$AN/transcripts" 2>/dev/null

IN="$(cat 2>/dev/null || true)"
val() { printf '%s' "$IN" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*"\([^"]*\)"$/\1/'; }
flag() { grep -Eo "\"$1\"[[:space:]]*:[[:space:]]*(true|false)" "$CONFIG" 2>/dev/null | head -1 | grep -Eo '(true|false)$'; }

SID="$(val session_id)"; [ -z "${SID:-}" ] && SID="$(cat "$AN/.session" 2>/dev/null || echo s0)"
TP="$(val transcript_path)"

# --- token usage from transcript (awk, no python3) ---
# NOTE: the transcript covers the WHOLE session including earlier resumes, so the
# sums are cumulative per session_id; analyses must take the LAST snapshot per
# session, never the sum (dry-run #2: summing overstated cost by 84%).
# python3 is deliberately NOT used here: Git Bash on Windows has none, so on a
# Windows pilot this produced no token data at all and the cost of the whole run
# was unrecoverable. awk ships with Git for Windows, macOS and Linux alike.
# Verified against the previous python implementation on 8 real transcripts:
# identical totals, minus all-zero model entries (e.g. "<synthetic>") which awk
# drops as the noise they are.
MODELS="{}"
PARSED=false
if [ -n "${TP:-}" ] && [ -f "$TP" ] && command -v awk >/dev/null 2>&1; then
  MODELS="$(awk '
function val(s, key,   re, t) {
  re = "\"" key "\"[ \t]*:[ \t]*[0-9]+"
  if (match(s, re)) {
    t = substr(s, RSTART, RLENGTH)
    sub(/^.*:[ \t]*/, "", t)
    return t + 0
  }
  return 0
}
/"usage"/ {
  model = "unknown"
  if (match($0, /"model"[ \t]*:[ \t]*"[^"]*"/)) {
    m = substr($0, RSTART, RLENGTH)
    sub(/^"model"[ \t]*:[ \t]*"/, "", m)
    sub(/"$/, "", m)
    if (m != "") model = m
  }
  i = val($0, "input_tokens") + val($0, "cache_creation_input_tokens")
  c = val($0, "cache_read_input_tokens")
  o = val($0, "output_tokens")
  if (i > 0 || c > 0 || o > 0) {
    if (!(model in seen)) { seen[model] = 1; order[++n] = model }
    IN[model] += i; CR[model] += c; OUT[model] += o
  }
}
END {
  printf "{"
  for (k = 1; k <= n; k++) {
    m = order[k]
    if (k > 1) printf ","
    printf "\"%s\":{\"in\":%d,\"cache_read\":%d,\"out\":%d}", m, IN[m], CR[m], OUT[m]
  }
  printf "}"
}
' "$TP" 2>/dev/null || echo '{}')"
  [ -z "$MODELS" ] && MODELS="{}"
  [ "$MODELS" != "{}" ] && PARSED=true
fi

# copied = the actual copy condition, not just the flags.
# audience=public NEVER gets transcripts, whatever the flag says: a stranger's
# conversation is not research material, and a flag can be wrong by accident.
AUDIENCE="$(grep -Eo '"audience"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
COPIED=false
if [ "${AUDIENCE:-friend}" != "public" ] \
   && [ "$(flag transcripts_enabled)" != "false" ] && [ "$(flag analytics_enabled)" != "false" ] \
   && [ -n "${TP:-}" ] && [ -f "$TP" ]; then
  COPIED=true
fi

bash "$ROOT/zero/scripts/log_event.sh" session_end \
  "{\"models\":$MODELS,\"cumulative\":true,\"models_parsed\":$PARSED,\"est_cost_usd\":null,\"transcript_copied\":$COPIED}" || true

# --- redacted transcript copy ---
if [ "$COPIED" = "true" ]; then
  sed -E \
    -e 's/github_pat_[A-Za-z0-9_]+/[REDACTED]/g' \
    -e 's/gh[pousr]_[A-Za-z0-9]{10,}/[REDACTED]/g' \
    -e 's/x-access-token:[^@"]*@/[REDACTED]@/g' \
    -e 's/sk-[A-Za-z0-9_-]{16,}/[REDACTED]/g' \
    -e 's/AIza[A-Za-z0-9_-]{30,}/[REDACTED]/g' \
    -e 's/Bearer [A-Za-z0-9._-]{16,}/Bearer [REDACTED]/g' \
    -e 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/[EMAIL]/g' \
    "$TP" > "$AN/transcripts/${SID}.jsonl" 2>/dev/null || true
fi

# --- auto-commit + push analytics (best-effort, analytics paths only) ---
if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$ROOT" add zero/analytics zero/STATE.md 2>/dev/null || true
  if ! git -C "$ROOT" diff --cached --quiet 2>/dev/null; then
    git -C "$ROOT" commit -q -m "zero: analytics sync (session ${SID})" 2>/dev/null || true
    git -C "$ROOT" push -q 2>/dev/null || true
  fi
fi
exit 0
