#!/usr/bin/env bash
# utopia-zero SessionStart hook: session id file, deferred session_start marker,
# STATE.md summary -> stdout (context), new Utopia replies on [zero] issues -> stdout.
# Must never fail or block the session.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AN="$ROOT/zero/analytics"
mkdir -p "$AN" 2>/dev/null

IN="$(cat 2>/dev/null || true)"
val() { printf '%s' "$IN" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*"\([^"]*\)"$/\1/'; }

SID="$(val session_id)"
[ -n "${SID:-}" ] && printf '%s' "$SID" > "$AN/.session" 2>/dev/null
SRC="$(val source)"

# --- reconcile .stage with STATE.md (the STATE stage line is the source of truth;
# a stale .stage once mislabeled 197 events - dry-run #2) ---
# The stage number may or may not be bolded: the starter template writes
# "Etap / Stage: 3", some wizards write "**3**" (pilot #1: bold-only regex
# never matched, the mechanism was silently dead).
STATE_STAGE="$(grep -m1 -Eo 'Etap ?/ ?Stage: ?\*{0,2}[0-9]+' "$ROOT/zero/STATE.md" 2>/dev/null | grep -Eo '[0-9]+$' || true)"
if [ -n "${STATE_STAGE:-}" ]; then
  CUR="$(cat "$AN/.stage" 2>/dev/null || echo '')"
  if [ "$CUR" != "$STATE_STAGE" ]; then
    printf '%s' "$STATE_STAGE" > "$AN/.stage" 2>/dev/null
    echo "=== utopia-zero: .stage reconciled with STATE.md (${CUR:-none} -> $STATE_STAGE) ==="
  fi
fi

# --- session_start is DEFERRED, not logged here (dry-run #1 point 9, dry-run #2
# point 14, finally implemented after pilot #2): app restarts spawn second-long
# sessions whose start/end pairs are pure noise - 4 of the first 33 events of
# pilot #2 were such churn. The event line is built NOW (correct timestamp) but
# parked in .pending/<sid>; it reaches events.jsonl only when the session logs a
# real event (log_event flushes it) or lives past 10 s (the end hook flushes it).
# A short, silent session leaves no trace at all: no events, no transcript copy,
# no sync commit.
cfg() { grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$ROOT/zero/config.json" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/'; }
ENABLED="$(grep -Eo '"analytics_enabled"[[:space:]]*:[[:space:]]*(true|false)' "$ROOT/zero/config.json" 2>/dev/null | head -1 | grep -Eo '(true|false)$')"
if [ "${ENABLED:-true}" != "false" ]; then
  PEND="$AN/.pending"
  mkdir -p "$PEND" 2>/dev/null
  # a marker nothing ever flushed (session died without its end hook) must not
  # linger forever - sweep anything older than a day
  find "$PEND" -type f -mmin +1440 -exec rm -f {} \; 2>/dev/null
  CSID="$(cat "$AN/.session" 2>/dev/null || echo s0)"
  PARTICIPANT="$(cfg participant_id)"
  PROJECT="$(cfg project_id)"
  STG="$(cat "$AN/.stage" 2>/dev/null || echo 0)"
  {
    date +%s
    printf '{"ts":"%s","participant_id":"%s","project_id":"%s","session_id":"%s","stage":"%s","type":"session_start","payload":{"source":"%s"}}\n' \
      "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${PARTICIPANT:-unknown}" "${PROJECT:-unknown}" "$CSID" "${STG:-0}" "${SRC:-unknown}"
  } > "$PEND/$CSID" 2>/dev/null
fi

# --- first-session banner (fresh project) ---
if grep -q "nic jeszcze / nothing yet" "$ROOT/zero/STATE.md" 2>/dev/null; then
  echo "=== utopia-zero: PIERWSZA SESJA ==="
  echo "This is the participant's very first session. Whatever their first message"
  echo "says, greet them warmly in their language and start the wizard (stage 0)."
  echo "They were told everything happens by itself - do not wait for any prompt."
  echo "=== koniec / end ==="
fi

# --- context injection: project state ---
if [ -f "$ROOT/zero/STATE.md" ]; then
  echo "=== utopia-zero: zero/STATE.md (stan projektu / project state) ==="
  head -60 "$ROOT/zero/STATE.md" 2>/dev/null
  echo "=== koniec STATE / end of STATE ==="
fi

# --- pulse-survey reminder (counter kept by log_event: feature_done +1, survey resets) ---
P="$(cat "$AN/.pulse" 2>/dev/null || echo 0)"
case "$P" in (*[!0-9]*|'') P=0 ;; esac
if [ "$P" -ge 3 ]; then
  echo "=== utopia-zero: puls satysfakcji zaległy / pulse survey overdue ==="
  echo "$P feature_done since the last survey. Run the 2-question pulse (stages.md,"
  echo "stage 4 step 8) at the next natural break and log survey{stage, scores}."
  echo "=== koniec / end ==="
fi

# --- Utopia replies on [zero] issues (needs curl + PAT; friend audience only) ---
# python3 is deliberately NOT required: Git Bash on Windows usually has no python3,
# and this block used to fail there in complete silence - pilot #1 ran a whole
# project believing the channel worked while .issues_seen never moved off the epoch.
# Parsing is left to the reader: the raw API response goes to stdout and the wizard
# reads it. A crude sed parser would be one more thing to break quietly.
PATF="$ROOT/zero/.pat"
AUD="$(grep -Eo '"audience"[[:space:]]*:[[:space:]]*"[^"]*"' "$ROOT/zero/config.json" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [ -f "$PATF" ] && [ "${AUD:-friend}" != "public" ]; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "=== utopia-zero: nie moge sprawdzic wiadomosci od Utopii (brak curl) ==="
    echo "Tell the user in one plain sentence that the Utopia channel cannot be"
    echo "checked automatically here, and read the repo issues yourself instead."
    echo "=== koniec / end ==="
  else
    REPO="$(grep -o 'github\.com[/:][A-Za-z0-9_./-]*' "$ROOT/zero/config.json" 2>/dev/null | head -1 | sed 's|.*github\.com[/:]||; s|\.git$||')"
    PAT="$(tr -d '\r\n' < "$PATF" 2>/dev/null)"
    SINCE="$(tr -d '\r\n' < "$AN/.issues_seen" 2>/dev/null || echo '')"
    # NOT the epoch: GitHub's issues list quietly returns [] for since=1970 (it
    # accepts 1990 and later), and the epoch is exactly the default checkpoint -
    # so a fresh repo would have surfaced nothing at all, forever.
    case "${SINCE:-}" in
      ''|1970-*) SINCE='2000-01-01T00:00:00Z' ;;
    esac
    # -f matters: without it GitHub's {"message":"Not Found"} body counts as a
    # successful answer, the check reports nothing and the channel dies quietly.
    api() { curl -sS -f -m 8 -H "Authorization: Bearer $PAT" -H "Accept: application/vnd.github+json" \
              -H "User-Agent: utopia-zero" "$1" 2>/dev/null; }
    if [ -n "${REPO:-}" ] && [ -n "${PAT:-}" ]; then
      # New or updated threads: the BODY of an issue Utopia opened is a message in
      # its own right, not just a container for comments. Fetching only comments
      # meant an operator-opened issue reached nobody.
      FRESH="$(api "https://api.github.com/repos/$REPO/issues?state=open&since=$SINCE&per_page=20")"
      case "${FRESH:-}" in
        ''|'[]') ;;
        *) echo "=== utopia-zero: nowe lub zmienione watki [zero] od Utopii ==="
           # GitHub's issue JSON is verbose (one issue is ~4 kB of mostly URLs),
           # so the cap has to fit more than a single thread or a second message
           # gets clipped mid-object.
           printf '%s\n' "$FRESH" | cut -c1-16000
           echo "=== koniec / end ===" ;;
      esac
      ISSUES="$(api "https://api.github.com/repos/$REPO/issues?state=open&per_page=20")"
      if [ -z "${ISSUES:-}" ]; then
        echo "=== utopia-zero: nie udalo sie sprawdzic wiadomosci od Utopii ==="
        echo "Network or token problem. Say ONE plain sentence to the user only if"
        echo "they are waiting on an answer; otherwise carry on and retry next session."
        echo "=== koniec / end ==="
      else
        FOUND=""
        for N in $(printf '%s' "$ISSUES" | grep -o '"number"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*$'); do
          NEW="$(api "https://api.github.com/repos/$REPO/issues/$N/comments?since=$SINCE&per_page=30")"
          case "$NEW" in
            ''|'[]') ;;
            *) FOUND="yes"
               echo "=== utopia-zero: nowa odpowiedz Utopii w issue #$N ==="
               printf '%s\n' "$NEW" | cut -c1-4000
               echo "=== koniec / end ===" ;;
          esac
        done
        if [ -n "$FOUND" ]; then
          echo "=== utopia-zero: przeczytaj powyzsze PRZED planowaniem pracy ==="
          echo "Act on it, then comment back on the issue saying what you did - the"
          echo "thread is a two-way channel, not an inbox."
          echo "=== koniec / end ==="
        fi
        # Checkpoint moves only after a successful round, so a failed check re-reads
        # the same comments next session instead of losing them.
        printf '%s' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$AN/.issues_seen" 2>/dev/null
      fi
    fi
  fi
fi

exit 0
