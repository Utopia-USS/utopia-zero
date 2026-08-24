# Analytics - schema, scripts, hooks, privacy

Principles: everything lives **inside the project repo** (`zero/analytics/`), pushed
like code; the user can turn it off at any moment; secrets never enter events or
transcripts (scripts redact, you don't feed them); data is keyed by `participant_id`,
never a name.

## Config flags (`zero/config.json`)

- `analytics_enabled` - master switch; `false` → `log_event` is a silent no-op and
  hooks skip everything except STATE injection.
- `transcripts_enabled` - session transcript copies on/off (independent of events).

Opt-out procedure (user says "wyłącz analitykę" / "disable analytics"): log one final
`consent{analytics:false}`, flip the flag(s) in config, commit, confirm in plain
words. Re-enable symmetrically.

**When the user asks to DELETE already-collected data** (transcripts, events): do it,
but say one plain sentence of truth first - removed files stay in git history unless
the history is rewritten, and offer that rewrite (or the planned move to a fresh repo)
as the actual erasure. Never let "usunięte" mean less than the user thinks it means
(dry-run #2: 21 "deleted" transcripts still sat in history at handover).

## Scripts (in `starter/zero/scripts/`)

| Script | Called by | Does |
|---|---|---|
| `log_event.sh` / `.ps1` | you (skill) + other scripts | appends one JSONL event, auto-fills common fields, redacts, **enforces the catalog** (see below), keeps the pulse counter |
| `hook_session_start.sh` / `.ps1` | SessionStart hook | `.session` file, **`.stage` reconciled with STATE.md**, `session_start` event, STATE summary → stdout (context), pulse-survey reminder, new `[zero]`-issue replies → stdout |
| `hook_session_end.sh` / `.ps1` | SessionEnd hook | `session_end` event with token usage from the transcript (cumulative per session - see catalog), transcript copy (redacted), auto-commit+push of `zero/` analytics files |

`VERSION` in the same directory numbers the script set. Participant repos carry
COPIES of these scripts, so fixes do not reach them through the plugin - the
session entry protocol (SKILL.md) compares the local `VERSION` against the
canonical one on GitHub and refreshes the copies when it is behind.

Call form (always from the project root):

```bash
bash zero/scripts/log_event.sh <type> '<json-payload>'   # macOS AND Windows (Git Bash)
powershell -NoProfile -ExecutionPolicy Bypass -File zero/scripts/log_event.ps1 <type> '<json-payload>'   # Windows, ONLY if bash is absent
```

**Windows prefers Git Bash + the `.sh` scripts** (`bash` ships with Git for
Windows, which the wizard guarantees anyway): calling `.ps1` through a nested
PowerShell mangles the JSON quoting and corrupts payloads (pilot #1). The `.ps1`
variants stay as a last resort for a machine with no usable `bash` - and after
any `.ps1` call, check the resulting JSONL line actually parses.

Common fields are added by the script: `ts` (ISO-8601 UTC), `participant_id`,
`project_id` (from config), `session_id` (from `zero/analytics/.session`, written by
the SessionStart hook), `stage` (from `zero/analytics/.stage`).

**Your duty on `stage_start`**: write the number first, then log -
`printf '3' > zero/analytics/.stage && bash zero/scripts/log_event.sh stage_start '{}'`.

## Hard logging rules (violations found in dry-runs #1 and #2 - do not repeat)

1. **`question` BEFORE asking, every time.** An `answer` without a paired `question`
   event is a data bug; the pairing (`id`) is what makes the interview analyzable.
   This includes the stage-4 plan approvals (loop step 2) - dry-run #2 logged 11
   questions against 43 features.
2. **Every user-reported correction logs a checkpoint**:
   `checkpoint{feature, verdict:"change", rework:n}` - also when visual checkpoints
   are turned off. Silent fixes destroy the vision↔implementation research signal.
3. **`feature_done` only AFTER its commit exists** (and after push, when possible) -
   events must never claim commits git can't show.
4. **Fill the catalog keys, then add prose.** `log_event` now warns on stderr and
   stamps `_schema_warning` into the payload when a required key is missing or the
   type is unknown. A warning is a DATA BUG you just created: keep working, but log
   the next event of that type with the full catalog payload. Extra keys are always
   welcome (`found_by`, `tests`, `note`, ...) - required keys are not negotiable,
   because they are the columns every analysis groups by. In dry-run #2 the payloads
   drifted into prose after day one and the rework metric became uncomputable.
5. **`feature_start` before every `feature_done`.** Time per feature is a research
   question; 11 starts against 43 dones made it unanswerable in dry-run #2.
6. **Stage 4 logs `decision` like every other stage.** The loop is the stage where
   this rule dies: pilot #1 logged 13 decisions across stages 0-3 and ZERO in stage 4,
   while choosing a persistence mechanism, a startup/routing shape and a preview mode.
   Package, storage layer, navigation shape, data format → `decision`, every time.
7. **Survey scales are normalized "higher = better"** before logging. A reversed
   question (e.g. frustration) gets its score flipped (6 minus the answer on 1-5),
   and the payload key says what was asked, e.g. `calm_at_stuck` not `frustration`.

## Event catalog (type → when → payload)

Required keys (enforced by `log_event`) are the ones named below; anything extra
is welcome on top.

| type | when | payload keys |
|---|---|---|
| `session_start` / `session_end` | hooks | `source`; end: `models{name:{in,cache_read,out}}` (`in` = fresh + cache-write; `cache_read` separate - lumping them made stage-0 look like 3.3M tokens), `cumulative:true` (sums cover the WHOLE transcript incl. earlier resumes - analyses take the LAST snapshot per `session_id`, never the sum), `est_cost_usd`, `transcript_copied` |
| `stage_start` / `stage_end` | every stage boundary | `stage` is in common fields; end: `duration_hint` |
| `tutorial` | stage 0 | `skipped` |
| `consent` | stage 0 + every change | `analytics`, `transcripts` |
| `env` | stage 0 + after installs | `os`, `arch`, `disk_free_gb`, `git`, `flutter`, `toolchains[]` |
| `model_info` | stage 0 + on change | `model`, `effort`, `source: advised\|user` |
| `question` / `answer` | every user question | q: `id`, `mode: options\|open`, `topic`; a: `id`, `length_chars`, `changed_prior` |
| `decision` | every significant technical choice | `area`, `choice`, `rationale`, `alternatives[]`, `user_involved` |
| `user_override` | user changes any prior decision | `ref`, `from`, `to` |
| `build` | every run/build attempt | `target: web\|android\|ios`, `ok`, `duration_s`, `attempt` |
| `error` | every surfaced failure | `category`, `signature` (first error line, redacted), `found_by: author\|test\|simulator\|device\|analyzer\|wizard` (who/what surfaced it - the most interesting column of dry-run #2) |
| `fix_attempt` | every ladder step | `n`, `strategy`, `ok` |
| `stuck` | ladder exhausted | `attempts`, `action: issue_created\|plan_b\|deferred` |
| `checkpoint` | every visual checkpoint | `feature`, `verdict: accept\|change\|reject`, `rework` |
| `feature_start` / `feature_done` | stage-4 loop | `name`; done: `commits`; parallel-agent work adds `parallel_agents:n` |
| `scope_request` | out-of-BRIEF ask | `summary`, `handled: done\|declined_logged` |
| `backend_step` | backend setup moments | `provider`, `step`, `delegated_to: utopia\|user\|none` (WHO the account work went to - the old boolean `delegated` could not tell "Utopia is creating it" from "the user is creating it himself", so pilot #1's deviation was invisible in the data) |
| `language_switch` | language change | `from`, `to` |
| `survey` | pulses + final | `stage`, `scores{}` (normalized: higher = better), `free_text` |
| `handover_selfscore` | stage 6 | `scores{criterion:0-2}`, `total` |

Unlisted momentary needs → prefer `decision`/`error` with a good payload over
inventing new types; if a new type is truly needed, use it (accepting the
`_schema_warning` it earns) and note it in HANDOVER.

**Pulse cadence is mechanical, not remembered**: `log_event` counts `feature_done`
into `zero/analytics/.pulse` and resets it on `survey`; the SessionStart hook
surfaces "pulse overdue" at ≥ 3. When you see that banner, run the 2-question
pulse at the next natural break - dry-run #2 collected 0 of ~15 due pulses on
memory alone.

## Hook wiring (stage 0 writes this into `.claude/settings.json`)

macOS:
```json
"hooks": {
  "SessionStart": [{ "matcher": "startup|resume|clear|compact",
    "hooks": [{ "type": "command", "command": "bash zero/scripts/hook_session_start.sh" }] }],
  "SessionEnd": [{ "hooks": [{ "type": "command", "command": "bash zero/scripts/hook_session_end.sh" }] }]
}
```

Windows - same structure, commands:
`powershell -NoProfile -ExecutionPolicy Bypass -File zero/scripts/hook_session_start.ps1`
(and `…session_end.ps1`).

The hooks go into the **committed** `settings.json` deliberately: one participant =
one machine, and the exact analytics config stays reproducible in the repo. (If a
project ever spans two OSes, move the hook block to `settings.local.json` per machine.)

Hooks load at session start → after wiring, one **planned restart** (stage 0 step 8).
Verification after restart: `zero/analytics/events.jsonl` contains a fresh
`session_start` line. Missing → re-check settings JSON validity, path, and that the
project folder (not a parent) is open.

**Manual dispatch fallback (field-proven on pilot #1)**: if the checks pass and a
SECOND planned restart still yields no `session_start` (seen on the Windows desktop
app - wiring correct, scripts fine when run by hand, dispatch simply dead), stop
restarting and take over dispatch yourself, every session from then on:

```bash
echo '{"source":"manual","session_id":"manual-<YYYYMMDDTHHMM>"}' | bash zero/scripts/hook_session_start.sh   # at session entry
echo '{"source":"manual"}' | bash zero/scripts/hook_session_end.sh    # at session wrap-up / before a fresh-session reset
```

Mint a FRESH `session_id` at every entry (timestamp form above) - without it the
stale `.session` file glues every manual session together and the last-snapshot
token rule above breaks (pilot #1: the whole run logged as `s0`). Log
`error{category:"hooks", signature:"hooks wired but never dispatched",
found_by:"wizard"}` once, write `hooks: manual dispatch` into `zero/STATE.md` (the
session entry protocol re-reads it every session), and retry native dispatch only
after app updates - a `session_start` you did not run yourself means the hooks came
alive. A manual `hook_session_end` has no hook stdin, so `session_end` may lack
token usage - acceptable degradation, never fake the numbers.

## Redaction & privacy

Scripts redact these patterns to `[REDACTED]` (e-mails to `[EMAIL]`) in event
payloads AND transcript copies: `github_pat_*`, `ghp_*`, `gho_*`,
`x-access-token:*@`, `sk-*`, `AIza*`, long `Bearer` values, e-mail addresses.

Never log: real names, secrets, full file contents, raw URLs with credentials.
`error.signature` = first line of the error only, post-redaction.

Hidden Utopia-mode (insider) sessions log `decision{area:"mode", choice:"utopia"}` -
participant analyses MUST filter those runs out.

Token usage: `hook_session_end` parses the session transcript (`transcript_path`
from hook stdin) with `python3` (macOS; skip with a warning event if absent) /
PowerShell `ConvertFrom-Json` (Windows), sums per-model input/output tokens, and
estimates cost informatively (the user is on a subscription - it's research data,
not a bill).

On-demand usage report: `/utopia-zero:report` aggregates `events.jsonl` into work
time, per-model tokens, and API-equivalent cost (read-only; see the command file).
