# Analytics — schema, scripts, hooks, privacy

Principles: everything lives **inside the project repo** (`zero/analytics/`), pushed
like code; the user can turn it off at any moment; secrets never enter events or
transcripts (scripts redact, you don't feed them); data is keyed by `participant_id`,
never a name.

## Config flags (`zero/config.json`)

- `analytics_enabled` — master switch; `false` → `log_event` is a silent no-op and
  hooks skip everything except STATE injection.
- `transcripts_enabled` — session transcript copies on/off (independent of events).

Opt-out procedure (user says "wyłącz analitykę" / "disable analytics"): log one final
`consent{analytics:false}`, flip the flag(s) in config, commit, confirm in plain
words. Re-enable symmetrically.

## Scripts (in `starter/zero/scripts/`)

| Script | Called by | Does |
|---|---|---|
| `log_event.sh` / `.ps1` | you (skill) + other scripts | appends one JSONL event, auto-fills common fields, redacts |
| `hook_session_start.sh` / `.ps1` | SessionStart hook | `.session` file, `session_start` event, STATE summary → stdout (context), new `[zero]`-issue replies → stdout |
| `hook_session_end.sh` / `.ps1` | SessionEnd hook | `session_end` event with token usage from the transcript, transcript copy (redacted), auto-commit+push of `zero/` analytics files |

Call form (always from the project root):

```bash
bash zero/scripts/log_event.sh <type> '<json-payload>'        # macOS
powershell -NoProfile -ExecutionPolicy Bypass -File zero/scripts/log_event.ps1 <type> '<json-payload>'   # Windows
```

Common fields are added by the script: `ts` (ISO-8601 UTC), `participant_id`,
`project_id` (from config), `session_id` (from `zero/analytics/.session`, written by
the SessionStart hook), `stage` (from `zero/analytics/.stage`).

**Your duty on `stage_start`**: write the number first, then log —
`printf '3' > zero/analytics/.stage && bash zero/scripts/log_event.sh stage_start '{}'`.

## Hard logging rules (violations found in dry-run #1 — do not repeat)

1. **`question` BEFORE asking, every time.** An `answer` without a paired `question`
   event is a data bug; the pairing (`id`) is what makes the interview analyzable.
2. **Every user-reported correction logs a checkpoint**:
   `checkpoint{feature, verdict:"change", rework:n}` — also when visual checkpoints
   are turned off. Silent fixes destroy the vision↔implementation research signal.
3. **`feature_done` only AFTER its commit exists** (and after push, when possible) —
   events must never claim commits git can't show.

## Event catalog (type → when → payload)

| type | when | payload keys |
|---|---|---|
| `session_start` / `session_end` | hooks | `source`; end: `models{name:{in,cache_read,out}}` (`in` = fresh + cache-write; `cache_read` separate — lumping them made stage-0 look like 3.3M tokens), `est_cost_usd`, `transcript_copied` |
| `stage_start` / `stage_end` | every stage boundary | `stage` is in common fields; end: `duration_hint` |
| `tutorial` | stage 0 | `skipped` |
| `consent` | stage 0 + every change | `analytics`, `transcripts` |
| `env` | stage 0 + after installs | `os`, `arch`, `disk_free_gb`, `git`, `flutter`, `toolchains[]` |
| `model_info` | stage 0 + on change | `model`, `effort`, `source: advised\|user` |
| `question` / `answer` | every user question | q: `id`, `mode: options\|open`, `topic`; a: `id`, `length_chars`, `changed_prior` |
| `decision` | every significant technical choice | `area`, `choice`, `rationale`, `alternatives[]`, `user_involved` |
| `user_override` | user changes any prior decision | `ref`, `from`, `to` |
| `build` | every run/build attempt | `target: web\|android\|ios`, `ok`, `duration_s`, `attempt` |
| `error` | every surfaced failure | `category`, `signature` (first error line, redacted) |
| `fix_attempt` | every ladder step | `n`, `strategy`, `ok` |
| `stuck` | ladder exhausted | `attempts`, `action: issue_created\|plan_b\|deferred` |
| `checkpoint` | every visual checkpoint | `feature`, `verdict: accept\|change\|reject`, `rework` |
| `feature_start` / `feature_done` | stage-4 loop | `name`; done: `commits` |
| `scope_request` | out-of-BRIEF ask | `summary`, `handled: done\|declined_logged` |
| `backend_step` | backend setup moments | `provider`, `step`, `delegated` |
| `language_switch` | language change | `from`, `to` |
| `survey` | pulses + final | `stage`, `scores{}`, `free_text` |
| `handover_selfscore` | stage 6 | `scores{criterion:0-2}`, `total` |

Unlisted momentary needs → prefer `decision`/`error` with a good payload over
inventing new types; if a new type is truly needed, use it and note it in HANDOVER.

## Hook wiring (stage 0 writes this into `.claude/settings.json`)

macOS:
```json
"hooks": {
  "SessionStart": [{ "matcher": "startup|resume|clear|compact",
    "hooks": [{ "type": "command", "command": "bash zero/scripts/hook_session_start.sh" }] }],
  "SessionEnd": [{ "hooks": [{ "type": "command", "command": "bash zero/scripts/hook_session_end.sh" }] }]
}
```

Windows — same structure, commands:
`powershell -NoProfile -ExecutionPolicy Bypass -File zero/scripts/hook_session_start.ps1`
(and `…session_end.ps1`).

The hooks go into the **committed** `settings.json` deliberately: one participant =
one machine, and the exact analytics config stays reproducible in the repo. (If a
project ever spans two OSes, move the hook block to `settings.local.json` per machine.)

Hooks load at session start → after wiring, one **planned restart** (stage 0 step 8).
Verification after restart: `zero/analytics/events.jsonl` contains a fresh
`session_start` line. Missing → re-check settings JSON validity, path, and that the
project folder (not a parent) is open.

## Redaction & privacy

Scripts redact these patterns to `[REDACTED]` (e-mails to `[EMAIL]`) in event
payloads AND transcript copies: `github_pat_*`, `ghp_*`, `gho_*`,
`x-access-token:*@`, `sk-*`, `AIza*`, long `Bearer` values, e-mail addresses.

Never log: real names, secrets, full file contents, raw URLs with credentials.
`error.signature` = first line of the error only, post-redaction.

Hidden Utopia-mode (insider) sessions log `decision{area:"mode", choice:"utopia"}` —
participant analyses MUST filter those runs out.

Token usage: `hook_session_end` parses the session transcript (`transcript_path`
from hook stdin) with `python3` (macOS; skip with a warning event if absent) /
PowerShell `ConvertFrom-Json` (Windows), sums per-model input/output tokens, and
estimates cost informatively (the user is on a subscription — it's research data,
not a bill).
