# Failure playbooks, plan-B ladder, escalation

The invariant: **the user never ends a session in a dead end.** Something always
works (web preview at worst), or the work continues on another front while Utopia
answers an escalation.

## The 5-strategy ladder

Per problem, up to **5 distinct strategies** - a retry of the same command is NOT a
new strategy. Before each attempt: re-read the FULL error (not the last line), check
your assumption against the actual file/state. Log `fix_attempt{n, strategy, ok}`
each time; on success log the fix in one plain sentence to the user only if they saw
the failure (otherwise stay silent - invisible technicalities).

Strategy menus per category:

**Environment / installs**
1. Re-run after reading the real error (network blip, partial download).
2. Full-path invocation (PATH not refreshed yet - common right after installs).
3. Alternative source/method (zip instead of winget, different mirror).
4. Disk/permission fix with the user (free space, "kliknij Zezwól w okienku systemowym").
5. Lighter goal (web instead of device; system browser instead of anything missing).

**Build / dependencies**
1. `flutter clean && flutter pub get`.
2. Read the resolver conflict; upgrade/downgrade the ONE named package.
3. Pin the failing transitive version in `pubspec.yaml`.
4. Swap the package for a maintained alternative (your call, log `decision`).
5. Rebuild the feature slice without the package (hand-rolled minimal version).

**Runtime bugs**
1. Read the stack + the named file:line in full.
2. Reproduce minimally (which action triggers it), fix the actual cause.
3. Add targeted debug prints, run, read, remove them.
4. `git diff` against the last good commit - bisect what changed.
5. Rebuild the broken slice from the last good commit (small, honest rework).

**Expectation mismatch** ("miało być inaczej")
1. Name the difference precisely, in their words, no defensiveness.
2. Smallest targeted change first; re-checkpoint. Log `checkpoint{rework:true}`.
3. If it keeps missing twice → back to a 3-question mini-interview about THIS screen.

**Backend**
1. Verify the credential actually works (`curl` the health/auth endpoint quietly).
2. Check rules/permissions (Firestore rules, RLS) against the exact failing call.
3. Quota/plan limits - read the console error class properly.
4. Re-init config from `.env` (typos, wrong project id).
5. Needs an admin/account action → delegate: ready-to-send message to `utopia_contact`.

**Claude Code itself**
- Subscription limit hit: honest message + when it resets; propose a break -
  never degrade to a weaker model mid-build of a critical stage (see model-advice).
- Constant permission popups: auto-accept is off - guide the toggle, per ONBOARDING.
- Plugin update broke a flow: pin/workaround, then escalate with details.

**User-driven**
- Manual file edits: `git diff`, explain kindly what changed, reconcile - never scold.
- Laptop slept mid-build: just re-run; stage scripts are idempotent.

## Plan-B ladder (targets)

physical device → emulator/simulator → phone browser via LAN → local web preview.
Every rung is a legitimate success; parking a feature and building another one is
also a plan B. Say which rung you're on, in plain words, without shame.

## Escalation (after the ladder + no plan B, or the user is stuck twice on the same thing)

1. Log `stuck{attempts, action:"issue_created"}`.
2. Create a GitHub issue in the project repo (title `[zero] Stuck: <short-slug>`):

   macOS - write the body to `/tmp/zero_issue.md` (already redacted), then:
   ```bash
   PAT=$(cat zero/.pat)
   REPO=$(grep -o 'github\.com[/:][A-Za-z0-9_./-]*' zero/config.json | head -1 | sed 's|github\.com[/:]||; s|\.git$||')
   python3 -c 'import json,pathlib,sys; print(json.dumps({"title": sys.argv[1], "body": pathlib.Path("/tmp/zero_issue.md").read_text()}))' \
     "[zero] Stuck: <short-slug>" > /tmp/zero_issue.json
   curl -sS -X POST -H "Authorization: Bearer $PAT" -H "Accept: application/vnd.github+json" \
     "https://api.github.com/repos/$REPO/issues" --data @/tmp/zero_issue.json
   ```
   Windows:
   ```powershell
   $pat  = (Get-Content zero\.pat -Raw).Trim()
   $cfg  = Get-Content zero\config.json -Raw -Encoding UTF8 | ConvertFrom-Json
   $repo = $cfg.git_remote -replace '^.*github\.com[/:]','' -replace '\.git$',''
   $json = @{ title = "[zero] Stuck: <slug>"; body = $body } | ConvertTo-Json
   Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$repo/issues" `
     -Headers @{ Authorization = "Bearer $pat"; Accept = "application/vnd.github+json"; "User-Agent" = "utopia-zero" } -Body $json
   ```

   Issue body sections: Stage & goal · Error (last ~30 lines, redacted) · Strategies
   tried (numbered, with results) · Environment (`env` payload) · Last commit link ·
   Impact on the user · Conversation language.
3. Tell the user, their language, no drama: "Zatrzymałem się na X i wysłałem raport
   do Utopii. W międzyczasie możemy robić Y, albo wróć jutro - sprawdzę odpowiedź."
4. Every session start, the hook surfaces new Utopia replies on `[zero]` issues -
   read them FIRST and weave the guidance into the plan (then comment back on the
   issue what you did, so the thread is a real two-way channel).
5. No PAT / self-serve project → say there's no help channel wired, suggest the
   user contacts `utopia_contact` themselves with the summary you prepare.
