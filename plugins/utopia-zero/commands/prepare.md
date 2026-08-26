---
description: "Utopia-side: prepare a participant repo (poc-<slug>) - copy starter, fill config, guide the PAT, produce the ZIP + start prompt"
argument-hint: "<slug> <participant_id> [project name] [pl|en]"
allowed-tools: Read, Write, Edit, Bash, Glob, AskUserQuestion
model: inherit
---

# Utopia Zero - prepare a participant repo

You are preparing a private per-participant repo for the utopia-zero experiment.
The operator is a Utopia member with `gh` authenticated and repo-create rights in
the target org (default `Utopia-USS`). Work in a scratch directory.

Raw arguments: `$ARGUMENTS` → slug (e.g. `gra-imprezowa`), participant id (e.g.
`P001`), optional project display name and default language. Ask (clickable) only
for what's missing.

## Steps

1. **Preflight**: `gh auth status`; derive `REPO=poc-<slug>`; confirm the owner with
   the operator - an org (default `Utopia-USS`) **or the operator's personal
   account**. Personal account = the no-approval path: fine-grained PATs for your own
   repos work instantly, no org-owner blessing needed (org repos may require policy
   enablement + per-token approval). Utopia teammates get access as collaborators;
   the repo can be transferred into the org later without losing history.
   `gh repo view <owner>/<repo>` must 404 (abort if it exists - never overwrite).
2. **Fresh starter**: `git clone --depth 1 https://github.com/Utopia-USS/utopia-zero
   /tmp/utopia-zero-src` (or `git -C … pull` if already there this session) and copy
   `starter/` content into a new work dir.
3. **Fill `zero/config.json`**: `participant_id`, `project_id` (= repo name),
   `project_name`, `language_default`, `git_remote`
   (`https://github.com/<org>/<repo>.git`), and `audience: "friend"` (a prepared
   repo always goes to someone who knows Utopia). Flags stay `true`.
   **Never put a person into the config.** `utopia_contact` stays the literal string
   `"Utopia"`: friends already know who to write to, and a name or address in a
   project file is personal data that outlives the person's role - pilot #1 shipped
   a full name plus an address in that field and it had to be cleaned out afterwards.
   House rule applies to VALUES too: no em-dashes in any config field (dry-run #2
   shipped one, pilot #1 shipped one again - check this field specifically before
   committing) - plain dash with spaces.
4. **utopia_ui dependency**: the utopia-ui repo is PUBLIC - participants fetch it
   themselves via the git dependency (the wizard adds it in stage 2; see the
   skill's `utopia-ui-build.md` ladder). No vendoring by default. Vendor a copy
   into `<repo>/packages/utopia_ui/` (with `VENDORED.md`: source commit + date)
   ONLY when the participant is expected to work offline.
5. **Create + push**: `gh repo create <org>/<repo> --private
   --description "utopia-zero POC - <project name>"`; `git init -b main`, commit
   `zero: starter for <participant_id>`, push. (The initial push authenticates as
   the operator; the participant's PAT is only for their machine.)
6. **PAT (operator does this in the browser - guide, don't automate)**:
   GitHub → Settings → Developer settings → Personal access tokens → Fine-grained →
   Generate new: Resource owner = the repo owner (the org, or the operator's account
   for the no-approval path) · Only select repositories = `<owner>/<repo>`
   · Repository permissions: **Contents: Read and write, Issues: Read and write** ·
   Expiration 90 days. Operator pastes the token **into the terminal prompt you give
   them, not into chat if avoidable**; write it to `zero/.pat` (gitignored - verify
   with `git check-ignore zero/.pat` before ANY commit). If org settings reject
   fine-grained PATs, tell the operator the org owner must allow them (Org Settings
   → Third-party Access → Personal access tokens) and pause here.
6a. **Participant's own GitHub account (optional, recommended)**: when the
   participant has (or will create) a GitHub account, invite them as a repo
   COLLABORATOR - repo-level, no organization membership involved, instant on a
   personal-owner repo:
   ```bash
   gh api -X PUT repos/<owner>/<repo>/collaborators/<participant-username> -f permission=push
   ```
   `push` (write) is enough: clone, push, open issues - never `admin`. The
   participant accepts the e-mail invitation (it expires after 7 days).
   NOTE: this does NOT replace `zero/.pat` - a fine-grained PAT can only be
   issued by the repo owner, so the participant's own fine-grained PAT will not
   work on this repo. The shipped `zero/.pat` keeps powering pushes and the
   escalation channel; the collaborator invite gives the participant web access
   to their project and lets them authenticate as themselves (gh login or a
   classic PAT) if they ever need to.
6b. **Web preview secrets (silent, ~10 s)**: the starter ships
   `.github/workflows/deploy-web.yml`, which publishes the built app to
   Cloudflare Pages on every push that touches `app/` - the participant gets a
   link they can send to friends, Utopia gets a live view of the work. Set both
   secrets now so the very first stage-2 push deploys itself:
   ```bash
   gh secret set CLOUDFLARE_API_TOKEN  --repo <owner>/<repo> --body "$CF_TOKEN"
   gh secret set CLOUDFLARE_ACCOUNT_ID --repo <owner>/<repo> --body "$CF_ACCOUNT"
   ```
   The operator supplies both once (Cloudflare → My Profile → API Tokens, template
   permission **Cloudflare Pages: Edit**; account id sits on the dashboard sidebar) -
   read them from the operator's environment or prompt for them in the terminal,
   never into chat. The URL defaults to `https://<repo>.pages.dev`; once the app
   has a real name (stage 1), give the participant an address that matches it -
   `gh variable set PAGES_PROJECT --repo <owner>/<repo> --body "<slug>"` (lowercase,
   digits, hyphens; no diacritics) - and re-run the workflow. Do it once and early:
   Cloudflare cannot rename a Pages project, so a later change strands the old link.
   Put the final URL in the repo homepage after the first green run. No Cloudflare account? Skip this step -
   the workflow detects the missing secrets and stays green.
7. **ZIP**: zip the work dir INCLUDING `.git` and `zero/.pat`
   (`zip -r poc-<slug>.zip <dir> -x '*.DS_Store'`). State clearly: the ZIP contains
   a repo-scoped token - send it over a private channel only.
8. **Hand-off summary** for the operator, ready to forward: ZIP path · link to
   `docs/ONBOARDING-PL.md` / `-EN.md` · the start prompt to send the participant:
   - PL: „Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji."
   - EN: "Let's start. Guide me from zero to my own app."
9. **Verify before finishing**: fresh `git clone` of the new repo into /tmp shows
   starter files, NO `.pat`, NO real token anywhere (`git log -p | grep -c
   github_pat_` → 0). Report the checklist result.

Never print the token back, never commit it, never put it in the repo description
or issues.
