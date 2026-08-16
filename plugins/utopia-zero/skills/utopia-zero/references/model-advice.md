# Model advice + token economy (stage 0, and whenever it changes)

Quality of stages 1–4 decides developability - the experiment's #1 metric - but
most participants run on the BASE subscription (Pro-class, ~100 zł), where limits
are tight 5-hour windows. Advice is therefore **plan-aware**: the strongest model
the user's plan can sustain for a whole build evening, not the strongest on paper.

## Step 1: learn the plan (once, stage 0, clickable)

"Jaki masz plan Claude?" → Pro (podstawowy) / Max / nie wiem. On "nie wiem", guide:
the plan name is in app settings / on claude.com/settings - or just assume Pro
(the safe default for participants). Log it inside `model_info{plan}`.

## Step 2: the advice matrix

| Plan | Stages 1–4 (build) | Late-game tweaks + stage 6 | Never |
|---|---|---|---|
| **Pro (default)** | **Sonnet-class, effort medium** - near-Opus quality at a fraction of the limit burn; a full evening fits in the window | Sonnet-class, effort low | Haiku-class for building; Opus-class as the *default* (limit dies mid-stage) |
| **Max / Team** | strongest available (Opus-class), high effort | Sonnet-class fine | Haiku-class for building |

Pro escape hatch: for a genuinely hard, isolated moment (architecture knot, a bug
that survived the 5-strategy ladder) it is fine to switch to Opus-class FOR THAT
TASK and switch back - say so in one sentence, log `model_info{source:"user"}`.

How to deliver (Zero mode, user's language, one breath): "Sprawdź, jaki model jest
wybrany przy polu wiadomości - na czas budowania najlepszy będzie <model>. Pokażę
Ci, gdzie to przełączyć." Describe the selector generically (UI drifts); ask what
they see, guide from there.

Log `model_info{model, effort, plan, source:"advised"|"user"}` - also whenever the
user changes the model later.

## Token economy (holds for the whole project, mostly on Pro)

Context is the silent limit-eater: a long session re-reads its whole history every
turn. Data point from our dry-runs: ~98% of consumed input was context re-reads,
not new work.

1. **Fresh session per stage.** STATE.md is designed to carry everything between
   sessions. At every `stage_end` on a Pro plan, actively suggest: "Zamknij okno i
   otwórz projekt na nowo - napisz cokolwiek, będę pamiętał. To oszczędza Twój
   limit." (Bonus: new sessions pick up plugin updates.) Never force it mid-stage.
2. **No parallel subagent fan-outs on Pro.** Sequential feature work; parallel
   agent batches are a Max-plan luxury (they multiply context N times).
3. **Targeted reads.** Read the fragment you need, not whole generated files
   repeatedly; never re-`cat` a file you just wrote.
4. **Short outputs** are already invariant 13 (calibrated messages) - it also
   saves output tokens.
5. **Limits hit anyway?** Be honest ("limit odnowi się <kiedy> - zróbmy przerwę"),
   prefer a pause over a mid-architecture downgrade to Haiku-class. Log
   `error{category:"claude-limits"}` + the chosen path as `decision`.

> Maintenance note (Utopia): refresh model names as the lineup changes; the tables
> speak in tiers on purpose so they survive releases.
