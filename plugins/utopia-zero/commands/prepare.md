---
description: "Utopia-side: prepare a participant repo (poc-<slug>) — copy starter, fill config, guide the PAT, produce the ZIP + start prompt"
argument-hint: "<slug> <participant_id> [project name] [pl|en]"
allowed-tools: Read, Write, Edit, Bash, Glob, AskUserQuestion
model: inherit
---

# Utopia Zero — prepare a participant repo

You are preparing a private per-participant repo for the utopia-zero experiment.
The operator is a Utopia member with `gh` authenticated and repo-create rights in
the target org (default `Utopia-USS`). Work in a scratch directory.

Raw arguments: `$ARGUMENTS` → slug (e.g. `gra-imprezowa`), participant id (e.g.
`P001`), optional project display name and default language. Ask (clickable) only
for what's missing.

## Steps

1. **Preflight**: `gh auth status`; derive `REPO=poc-<slug>`; confirm the owner with
   the operator — an org (default `Utopia-USS`) **or the operator's personal
   account**. Personal account = the no-approval path: fine-grained PATs for your own
   repos work instantly, no org-owner blessing needed (org repos may require policy
   enablement + per-token approval). Utopia teammates get access as collaborators;
   the repo can be transferred into the org later without losing history.
   `gh repo view <owner>/<repo>` must 404 (abort if it exists — never overwrite).
2. **Fresh starter**: `git clone --depth 1 https://github.com/Utopia-USS/utopia-zero
   /tmp/utopia-zero-src` (or `git -C … pull` if already there this session) and copy
   `starter/` content into a new work dir.
3. **Fill `zero/config.json`**: `participant_id`, `project_id` (= repo name),
   `project_name`, `language_default`, `git_remote`
   (`https://github.com/<org>/<repo>.git`), `utopia_contact` — the **operator's own
   direct contact** (participants are friends of Utopia and write to a person they
   know, not a mailbox; e.g. `Paweł — pawel@…`). Use `info@utopiasoft.io` only as a
   last-resort fallback when no direct contact fits. Flags stay `true`.
4. **Vendor utopia_ui** (required while the utopia-ui repo is private — participants
   cannot fetch it themselves): clone/refresh `Utopia-USS/utopia-ui` with the
   operator's access, copy `pubspec.yaml`, `lib/`, `fonts/`, `LICENSE` (skip
   `example/`, `test/`, `.git`) into `<repo>/packages/utopia_ui/`, and write
   `packages/utopia_ui/VENDORED.md` with the source commit hash + date. The app will
   consume it as a `path` dependency (see the skill's `utopia-ui-build.md` ladder).
5. **Create + push**: `gh repo create <org>/<repo> --private
   --description "utopia-zero POC — <project name>"`; `git init -b main`, commit
   `zero: starter for <participant_id>`, push. (The initial push authenticates as
   the operator; the participant's PAT is only for their machine.)
6. **PAT (operator does this in the browser — guide, don't automate)**:
   GitHub → Settings → Developer settings → Personal access tokens → Fine-grained →
   Generate new: Resource owner = the repo owner (the org, or the operator's account
   for the no-approval path) · Only select repositories = `<owner>/<repo>`
   · Repository permissions: **Contents: Read and write, Issues: Read and write** ·
   Expiration 90 days. Operator pastes the token **into the terminal prompt you give
   them, not into chat if avoidable**; write it to `zero/.pat` (gitignored — verify
   with `git check-ignore zero/.pat` before ANY commit). If org settings reject
   fine-grained PATs, tell the operator the org owner must allow them (Org Settings
   → Third-party Access → Personal access tokens) and pause here.
7. **ZIP**: zip the work dir INCLUDING `.git` and `zero/.pat`
   (`zip -r poc-<slug>.zip <dir> -x '*.DS_Store'`). State clearly: the ZIP contains
   a repo-scoped token — send it over a private channel only.
8. **Hand-off summary** for the operator, ready to forward: ZIP path · link to
   `docs/ONBOARDING-PL.md` / `-EN.md` · the start prompt to send the participant:
   - PL: „Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji."
   - EN: "Let's start. Guide me from zero to my own app."
9. **Verify before finishing**: fresh `git clone` of the new repo into /tmp shows
   starter files, NO `.pat`, NO real token anywhere (`git log -p | grep -c
   github_pat_` → 0). Report the checklist result.

Never print the token back, never commit it, never put it in the repo description
or issues.
