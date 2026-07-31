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

# --- token usage from transcript (python3 best-effort) ---
MODELS="{}"
if command -v python3 >/dev/null 2>&1 && [ -n "${TP:-}" ] && [ -f "$TP" ]; then
  MODELS="$(python3 - "$TP" <<'PYEOF' 2>/dev/null || echo '{}'
import json, sys, collections
acc = collections.defaultdict(lambda: {"in": 0, "out": 0})
try:
    with open(sys.argv[1]) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except Exception:
                continue
            msg = obj.get("message") or {}
            usage = msg.get("usage") or {}
            model = msg.get("model") or "unknown"
            if usage:
                acc[model]["in"] += (usage.get("input_tokens") or 0) \
                    + (usage.get("cache_creation_input_tokens") or 0) \
                    + (usage.get("cache_read_input_tokens") or 0)
                acc[model]["out"] += usage.get("output_tokens") or 0
    print(json.dumps(dict(acc)))
except Exception:
    print("{}")
PYEOF
)"
  [ -z "$MODELS" ] && MODELS="{}"
fi

# copied = the actual copy condition, not just the flags
COPIED=false
if [ "$(flag transcripts_enabled)" != "false" ] && [ "$(flag analytics_enabled)" != "false" ] \
   && [ -n "${TP:-}" ] && [ -f "$TP" ]; then
  COPIED=true
fi

bash "$ROOT/zero/scripts/log_event.sh" session_end \
  "{\"models\":$MODELS,\"est_cost_usd\":null,\"transcript_copied\":$COPIED}" || true

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
