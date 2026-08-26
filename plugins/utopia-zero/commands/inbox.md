---
description: Utopia-side inbox - open [zero] issues across participant repos, with drafted replies
argument-hint: "[repo-slug | all]"
allowed-tools: Bash, Read, Grep, Glob, WebFetch
model: inherit
---

# Utopia Zero - inbox

Answer the participants' open `[zero]` issues in one pass. Everything a participant's
wizard cannot do alone arrives here: accounts, permissions, stuck reports, defects in
Utopia's own tooling. A reply posted in the thread is picked up by their wizard at the
next session start - the participant does nothing, pastes nothing.

Raw arguments: `$ARGUMENTS` (empty or `all` = every `poc-*` repo in the org; a slug
like `poc-janek` = just that one).

## Gather

```bash
gh repo list Utopia-USS --limit 100 --json name --jq '.[].name' | grep '^poc-'
```

For each repo, list open issues whose title starts with `[zero]`, newest first, with
the full thread:

```bash
gh issue list --repo Utopia-USS/<repo> --state open --json number,title,createdAt,updatedAt,comments \
  --jq '.[] | select(.title | startswith("[zero]")) | "#\(.number) \(.title) (\(.updatedAt[:10]), \(.comments|length) comments)"'
gh issue view <n> --repo Utopia-USS/<repo> --comments
```

Skip a thread whose last comment is already from Utopia and asks nothing - it is
waiting on the participant, not on you.

## Understand before drafting

For each open thread, read the repo's own context rather than guessing: `zero/STATE.md`
(stage, open questions), `zero/config.json` (`audience`, participant id), the last few
commits, and `zero/analytics/events.jsonl` around the issue timestamp (the `error`,
`stuck` and `fix_attempt` events say what was already tried). A reply that repeats an
attempt the wizard already made costs another day.

## Present, then post

Show the operator a compact list: repo · issue · what is being asked · what you propose
to answer · what it commits Utopia to (an account, a paid tier, a decision). Then ask
ONE approval question with the drafted replies attached. Nothing is posted before that.

After approval:

```bash
gh issue comment <n> --repo Utopia-USS/<repo> --body-file <draft>
gh issue close <n> --repo Utopia-USS/<repo>   # only when the thread is actually finished
```

Rules for the replies:

- **Never a credential.** A Firebase web config is public by design and may be posted;
  a PAT, an API key, a password or a service-account file must not go into an issue
  even in a private repo - those need a private channel, and the reply should say so.
- **No personal names**, in the body or the sign-off: the participant's project files
  and issue threads say "Utopia" and nothing more.
- **Answer in the participant's language** (`language_default` / what the thread uses).
  The wizard reads it, but the participant may read it too.
- **Actionable, not conversational**: say what was created, what changes on their side,
  and in what order. The wizard will execute it directly, so ordering matters more than
  tone ("do X and Y in one change, otherwise Z breaks").
- **When the answer is "no" or "later"**, say it plainly with the reason - a thread left
  hanging blocks a participant who is politely waiting.

## Close the loop

For anything that revealed a fault in the skill rather than in the participant's project,
add a line to `docs/PILOT1-FINDINGS.md` (or the current pilot's findings file) instead of
fixing it only in the reply. The issues are the field data; a fix that lives only in one
thread helps one person.
