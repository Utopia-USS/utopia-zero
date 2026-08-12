# Handover (stage 6) - HANDOVER.md template + developability rubric

The experiment's #1 success metric is: **can a professional Flutter team take this
over?** `zero/HANDOVER.md` (English, developer-facing) plus a rubric self-score are
how stage 6 makes that concrete. `zero/DECISIONS.md` is its raw material - keep it
fed all along (invariant 6).

## DECISIONS.md entry format (append-only, English)

```
- 2026-08-14 · state-mgmt · global CartState via useProvided · survives navigation,
  two screens mutate it · alt: per-screen state (rejected: duplication), stream in
  repo (rejected: overkill for POC)
```

One line per decision: date · area · what · why · alternatives (with rejection reasons).

## HANDOVER.md template

```markdown
# Handover - <App Name>

> POC built with utopia-zero by a non-programmer guided end to end.
> Brief (user language): zero/BRIEF.md · Decisions log: zero/DECISIONS.md
> Tag: poc-v1 · Date: <date> · Conversation language: <PL/EN>

## What this is
2–4 sentences: the product, for whom, current scope (which BRIEF features shipped).

## Run it from a clean clone
- Flutter <version> (channel stable), Dart <version>
- `cd app && flutter pub get && flutter run -d web-server --web-port 7357`
- Secrets: copy `.env.example` → `app/.env`, values held by <who> (never in repo)
- Admin panel (if present): `cd admin && flutter run -d web-server`

## Architecture map
- `app/lib/screen/…` - screens (Screen/State/View per utopia-hooks)
- global states: <list + one-liners>
- backend: <provider, project name, who owns the account>
- packages worth knowing: <top 5 with why>

## Key decisions (top 5 - full log in zero/DECISIONS.md)
1. …

## Known limitations & honest TODO
- …

## Accounts & secrets - who has what (NO values here)
| What | Where | Held by |

## Suggested first steps for the team
1. …
```

## Developability rubric (self-score in stage 6; Utopia dev re-scores post-hoc)

Score each 0 (missing) / 1 (partial) / 2 (solid). Target ≥ 14/20; fix every gap
costing < 30 min before scoring final.

| # | Criterion |
|---|---|
| 1 | `flutter analyze` clean |
| 2 | `utopia doctor` pass |
| 3 | Screen/State/View conformance (no rogue StatefulWidgets/setState) |
| 4 | State via utopia_hooks idioms (hooks, global states registered properly) |
| 5 | Repo hygiene: small commits, `.gitignore` right, **zero secrets in history** |
| 6 | BRIEF + DECISIONS + HANDOVER complete and matching reality |
| 7 | Dependency sanity (maintained packages, no duplicates, pinned where fragile) |
| 8 | Runs from a clean clone by following HANDOVER alone |
| 9 | At least smoke tests for the riskiest state logic |
| 10 | TODOs/limitations written down honestly (no surprises for the team) |

Log `handover_selfscore{scores, total}`. If a criterion scores 0 for a reason the
POC can't fix (e.g. tests skipped by scope), say so inside HANDOVER - an explained
gap beats a hidden one.

## Stage-6 checklist order

1. Polish pass (icons, app name, empty/error/loading states).
2. Gates: analyze, doctor, `flutter build web` (release) all green.
3. Write HANDOVER.md from the template; verify the "clean clone" section by actually
   following it in a temp directory.
4. Self-score → cheap fixes → rescore → log.
5. `git tag poc-v1 && git push origin poc-v1`.
6. Final survey (stages.md) + what-next message.
