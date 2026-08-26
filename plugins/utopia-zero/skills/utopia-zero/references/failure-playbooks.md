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
5. Needs an admin/account action → `audience: friend`: delegate with a ready-to-send
   message **to Utopia** (no personal name, no address). `audience: public`: it is
   their own account - guide the clicks instead of delegating.

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

## Escalation - the `[zero]` issue channel

**This is the default way to reach Utopia, not a last resort.** Open an issue
whenever the work needs something only Utopia can give, and keep building meanwhile:

- **Stuck**: the ladder is exhausted, no plan B, or the user is stuck twice on the
  same thing. Log `stuck{attempts, action:"issue_created"}`.
- **Accounts and access**: a backend project, a paid tier, a permission, anything
  that lives on Utopia's side (stages.md, stage 4 step 4).
- **A defect in Utopia's own tooling**: a `utopia_ui` gap, a broken scaffold - file
  it as `[zero] ui-gap: ...` / `[zero] bug: ...` here, since a participant PAT
  reaches no other repo.

Why by default: a message the user has to copy into e-mail costs a full human
round trip in each direction, and the answer comes back as something to paste. An
issue is read by the wizard itself at the next session start and acted on - the
participant does nothing.

**Never put a credential in an issue.** A Firebase web config is public by design
and may be posted; a PAT, an API key, a password or a service-account file must
never appear there, not even redacted-looking. Those stay on a private channel.
`audience: public` has no channel at all - do not open issues nobody will read.

1. Log the matching event (`stuck`, or `backend_step{delegated_to:"utopia"}`).
2. Create a GitHub issue in the project repo (title `[zero] <kind>: <short-slug>`).
   Write the body to `zero/.issue.md` first (gitignored, already redacted), then -
   **no python3 anywhere, Git Bash on Windows does not have it**:
   ```bash
   PAT=$(tr -d '\r\n' < zero/.pat)
   REPO=$(grep -o 'github\.com[/:][A-Za-z0-9_./-]*' zero/config.json | head -1 | sed 's|.*github\.com[/:]||; s|\.git$||')
   BODY=$(sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\r//' zero/.issue.md | awk 'BEGIN{ORS=""} {print $0 "\\n"}')
   printf '{"title":"%s","body":"%s"}' "[zero] Stuck: <short-slug>" "$BODY" > zero/.issue.json
   curl -sS -X POST -H "Authorization: Bearer $PAT" -H "Accept: application/vnd.github+json" \
     -H "User-Agent: utopia-zero" "https://api.github.com/repos/$REPO/issues" --data @zero/.issue.json
   rm -f zero/.issue.json
   ```
   (Verified escaping: quotes, backslashes and blank lines survive the round trip.
   Avoid raw tabs in the body.)
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
4. Every session start the hook fetches new comments on open `[zero]` issues and
   prints them - read them FIRST, act, then comment back on the issue saying what
   you did. The thread is a two-way channel, not an inbox.
   **If the hook prints that it could not check** (no curl, network, token), say one
   plain sentence to the user only when they are actually waiting on an answer, and
   read the issues yourself before planning. A channel that fails silently is worse
   than no channel: pilot #1 spent its whole project believing this worked, while
   `.issues_seen` never moved off the epoch because the old implementation needed
   python3 and Git Bash on Windows has none.
5. No PAT / self-serve project → say there's no help channel wired. `audience:
   friend`: offer the summary to send to Utopia themselves. `audience: public`:
   the honest answer is that they are self-hosting this - hand them the summary
   for their own use (or for an issue on the utopia-zero repo when the fault looks
   like ours), and never point at a contact that will not answer.
