---
description: Project usage report - work time, tokens per model, estimated API-equivalent cost, from zero/analytics/events.jsonl
argument-hint: "[all | since YYYY-MM-DD]"
allowed-tools: Read, Bash, Glob, Grep
model: inherit
---

# Utopia Zero - report

Produce a usage report for THIS project from `zero/analytics/events.jsonl`.
Answer in the user's language (default Polish). Works in any repo that has the
file; if it's missing, say so and stop - do not invent numbers.

Raw arguments: `$ARGUMENTS` (empty = whole file; `since YYYY-MM-DD` = filter by `ts`).

## What to compute

Parse the JSONL (python3 on macOS/Linux, PowerShell on Windows - one script, not
per-line tool calls). Skip malformed lines silently.

1. **Work time**
   - **A `session_id` is reused across resumes** - one id can hold several
     start/end EPISODES days apart. Never compute first-start → last-end
     (verified on poc-dryrun: that yields 144h instead of the real 7h). Walk
     each session's events chronologically: `session_start` opens an episode,
     `session_end` closes it; an episode without a clean end closes at its last
     event (mark `~`). Events before the first `session_start` of an id (pre-hook
     era) form one episode ending at their `session_end`.
   - Per-stage time: sum the deltas between consecutive in-episode events,
     attributed to the earlier event's `stage` - NOT the episode's start stage
     (a single evening episode can span stages 0→4).
   - Report: episode count, total time (`h:mm`), calendar span (first event →
     last event), and the per-stage split.
2. **Tokens per model**
   - Sum `session_end.payload.models` across sessions: per model, `in`,
     `cache_read` (treat a missing key as 0), `out`.
   - `in` already includes cache WRITES (the hook lumps fresh input +
     cache-creation) - say this in one footnote line.
   - **Old-format events**: `session_end` entries where a model has NO
     `cache_read` key come from the pre-fix hook that lumped cache READS into
     `in` too. Count how many sessions are old-format; if any, their cost is a
     big OVERestimate (cache reads billed at full input price). Report the total
     with an explicit `≤` and one footnote naming the affected session count.
     Verified on poc-dryrun: 647M "in" tokens are mostly cache reads - the naive
     total ($3.3k) is an upper bound, not a real figure.
   - Normalize model names by prefix (strip date suffixes): `claude-opus-4-8*`
     → one row.
3. **Effort**
   - Events do not carry per-request effort. If `decision{area:"model"}` or
     `model_info` events exist, report the declared model+effort choices with
     their timestamps as context. Otherwise write one line: effort data is not
     recorded per request - it lives in the Claude Code session settings, not in
     the transcript usage fields. Never fabricate an effort split.
4. **Cost (API-equivalent estimate)**
   - The user runs on a Claude subscription, so this is "what these tokens would
     cost at Anthropic API list prices", not a bill. Say so in one line.
   - `cost = in/1M × price_in + cache_read/1M × price_cache_read + out/1M × price_out`.
   - Because `in` lumps cache writes (billed at 1.25× input on the API), the
     estimate is a LOWER bound for new-format sessions - and an UPPER bound for
     old-format ones (see above). State which applies; if both formats are
     present, give the two components separately.

## Price table (USD per MTok, Anthropic API - snapshot 2026-08)

| Model prefix | in | cache read | out |
|---|---|---|---|
| `claude-fable-5`, `claude-mythos-5` | 10.00 | 1.00 | 50.00 |
| `claude-opus-5`, `claude-opus-4-8`, `claude-opus-4-7`, `claude-opus-4-6`, `claude-opus-4-5` | 5.00 | 0.50 | 25.00 |
| `claude-sonnet-5` | 3.00 (intro 2.00 do 2026-08-31) | 0.30 (intro 0.20) | 15.00 (intro 10.00) |
| `claude-sonnet-4-6`, `claude-sonnet-4-5` | 3.00 | 0.30 | 15.00 |
| `claude-haiku-4-5` | 1.00 | 0.10 | 5.00 |

Cache read = 0.1× input price. A model not in the table → show its tokens with
cost `?` and say the price table needs updating (never guess a price). If the
report matters financially, suggest verifying prices at
https://platform.claude.com/docs/en/pricing before relying on them.

## Output format

Compact and readable, no filler:

```
Raport - <project_id> (<zakres dat>)
Czas pracy: <suma> w <n> sesjach (kalendarzowo: <pierwsza> → <ostatnia>)
  etap 0: <t> · etap 1: <t> · ...

Tokeny i koszt (równowartość API):
| Model | in | cache read | out | koszt |
|---|---|---|---|---|
| claude-opus-4-8 | 1.2M | 168.7M | 0.64M | $38.53 |
Razem: $<suma>

Effort: <co wiadomo / jedna linia o braku danych>
```

Footnotes (one line each): `in` includes cache writes → cost is a lower bound;
prices are an API snapshot; sessions marked `~` had no clean end.

## Rules

- Read-only: never modify `events.jsonl` or log new events from this command.
- If analytics is disabled or the file is empty, report what exists and say what
  is missing - no guessing.
- Numbers over 1M → show as `x.xM`; costs to 2 decimals.
