#!/usr/bin/env bash
# utopia-zero SessionStart hook: session id file, session_start event,
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

bash "$ROOT/zero/scripts/log_event.sh" session_start "{\"source\":\"${SRC:-unknown}\"}" || true

# --- context injection: project state ---
if [ -f "$ROOT/zero/STATE.md" ]; then
  echo "=== utopia-zero: zero/STATE.md (stan projektu / project state) ==="
  head -60 "$ROOT/zero/STATE.md" 2>/dev/null
  echo "=== koniec STATE / end of STATE ==="
fi

# --- Utopia replies on [zero] issues (best-effort; needs python3 + PAT) ---
PATF="$ROOT/zero/.pat"
if command -v python3 >/dev/null 2>&1 && [ -f "$PATF" ]; then
  python3 - "$ROOT" <<'PYEOF' 2>/dev/null || true
import json, re, sys, pathlib, urllib.request

root = pathlib.Path(sys.argv[1])
try:
    cfg = json.loads((root / "zero/config.json").read_text())
    pat = (root / "zero/.pat").read_text().strip()
    m = re.search(r"github\.com[/:]([\w.-]+/[\w.-]+?)(?:\.git)?$", cfg.get("git_remote", ""))
    if not (pat and m):
        sys.exit(0)
    repo = m.group(1)
    ckpt_file = root / "zero/analytics/.issues_seen"
    since = ckpt_file.read_text().strip() if ckpt_file.exists() else "1970-01-01T00:00:00Z"

    def get(url):
        req = urllib.request.Request(url, headers={
            "Authorization": f"Bearer {pat}",
            "Accept": "application/vnd.github+json",
            "User-Agent": "utopia-zero"})
        with urllib.request.urlopen(req, timeout=6) as r:
            return json.loads(r.read())

    latest = since
    out = []
    for issue in get(f"https://api.github.com/repos/{repo}/issues?state=open&per_page=20"):
        if not issue.get("title", "").startswith("[zero]"):
            continue
        for c in get(issue["comments_url"] + "?per_page=30"):
            created = c.get("created_at", "")
            if created > since:
                body = (c.get("body") or "")[:600]
                out.append(f"--- Odpowiedź Utopii / Utopia replied on issue #{issue['number']} "
                           f"({issue['title']}):\n{body}\n")
                latest = max(latest, created)
    if out:
        print("=== utopia-zero: nowe odpowiedzi Utopii w issues ===")
        print("\n".join(out))
        print("(Przeczytaj je PRZED planowaniem pracy i odpisz w issue, co zrobiłeś.)")
    ckpt_file.write_text(latest)
except Exception:
    pass
PYEOF
fi
exit 0
