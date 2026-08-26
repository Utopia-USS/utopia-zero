# Contributing

utopia-zero is a wizard that walks non-programmers from an idea to a working app.
That single fact decides most of what follows: the person on the other end cannot
read a stack trace, cannot tell a warning from an error, and has nobody to ask.
Everything here optimises for them.

## The most valuable contribution is a run report

Not a patch. **A run report.** Every defect worth fixing so far was found by
someone using this for real and telling us what happened, and none of them were
found by reading the code. If you ran the wizard and something confused you, cost
you an evening, or made you give up, open a **Run report** issue. Half-finished
runs are the most useful kind.

## Reporting a bug

Open a **Bug report** issue. What actually helps:

- which stage you were in (`zero/STATE.md` says),
- your OS and whether hooks fire (`zero/analytics/events.jsonl` contains
  `session_start` lines, or it does not),
- what the wizard said, in its own words,
- the relevant lines from `events.jsonl`.

**Never paste a token, key or password into an issue.** If a report needs one to
make sense, say so and leave it out. If you have already pasted one, revoke it
before anything else.

Participants of a Utopia pilot should report inside their own project repo as a
`[zero]` issue instead - that channel is read by the wizard itself at the next
session start.

## Changing the skill

The skill is prose that another model has to follow under pressure, so it is
edited like code, not like documentation.

**Write the reason, not just the rule.** Every rule here exists because something
went wrong in the field, and a rule without its reason gets "optimised away" by
the next reader. Compare:

> Preview builds use `--release`.

with what the file actually says:

> Every preview the USER looks at is a release build. A debug web-server serves
> through dwds, which accepts a single debug connection, so a second or stale tab
> leaves them staring at a blank white page.

The second one survives contact with a model that thinks it knows better.

**Never block the beginner.** If a rule can leave someone waiting on a human, it
will lose to the wizard's instinct to keep going, and it will lose silently. Give
it a non-blocking path.

**Make failure loud.** Two separate features here died in complete silence for a
week because a failed check looked exactly like a successful one. If your change
can fail, make sure the failure is visible in the output or in the event payload.

**No em-dashes**, anywhere, including inside config values. Plain dash with spaces.

Code, commit messages, `zero/DECISIONS.md` and `zero/HANDOVER.md` are English.
Text the participant reads is written in their language, with correct diacritics.

## Changing the scripts

`starter/zero/scripts/` runs on the participant's machine, which means:

- **bash 3.2 and BSD tools.** A fresh Mac has bash 3.2.57 and BSD `awk`/`sed`.
  Test with `/bin/bash`, not your Homebrew bash.
- **No `python3`.** Git Bash on Windows does not have it. That single dependency
  cost pilot #1 its entire cost metric, silently. `awk`, `sed`, `curl` and `grep`
  are the toolbox.
- **Never fail loudly at the user, never fail silently at us.** Hooks must not
  break a session, but a check that could not run has to say so.
- **Bump `starter/zero/scripts/VERSION`.** Participant repos hold copies; the
  session entry protocol compares that number and refreshes them. Forget the bump
  and your fix reaches nobody.

Verify before opening a PR:

```bash
bash -n starter/zero/scripts/*.sh
```

plus a sandbox run of whatever you touched. There is no CI here yet; the sandbox
run is the test suite, so describe it in the PR.

## Pull requests

`main` is protected: PRs required, no force-pushes, no deletions. Fork, branch,
open a PR. Describe **what broke and why your change fixes it**, not just what you
changed, and say what you verified and what you did not.

Fixes that came out of a real run belong in the current findings document
(`docs/PILOT1-FINDINGS.md` and successors) as well as in the code. The findings
files are the memory of this project; a fix recorded only in a diff is a lesson
that gets relearned.

## What does not belong here

- Anything that assumes the user can debug, read logs, or "just check the console".
- Analytics that leave the participant's own repository.
- A person's name or address in a config file or a project template.
- New required tooling on the participant's machine.

## License

BSD 2-Clause. By contributing you agree your contribution ships under it.
