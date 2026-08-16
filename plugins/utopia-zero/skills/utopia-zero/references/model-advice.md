# Model advice + token economy (stage 0, and whenever it changes)

Quality of stages 1–4 decides developability - the experiment's #1 metric - and
**quality wins over token economy** (Utopia's explicit call): use the better model
and the higher effort even when it is slower and eats more of the limit. Most
participants run on the base subscription (Pro-class, ~100 zł) with tight 5-hour
windows - the answer to that is hygiene and honest pauses, never a quiet
downgrade. Plan detection below exists to set expectations, not to lower the bar.

## Step 1: learn the plan (once, stage 0 - detect silently, ask only as fallback)

**Detect first, silently**, from the local Claude Code config (an internal file -
format may drift, so treat failures as "unknown", never block):

- macOS/Linux: `~/.claude.json` → `oauthAccount.userRateLimitTier`
  ```bash
  python3 -c "import json,pathlib;print(json.loads((pathlib.Path.home()/'.claude.json').read_text()).get('oauthAccount',{}).get('userRateLimitTier',''))" 2>/dev/null
  ```
- Windows (PowerShell):
  ```powershell
  (Get-Content "$env:USERPROFILE\.claude.json" -Raw | ConvertFrom-Json).oauthAccount.userRateLimitTier
  ```

Map the tier string: contains `max` → **Max**; contains `pro` → **Pro**; empty,
missing, or anything else → **unknown**. On unknown ONLY, ask (clickable):
"Jaki masz plan Claude?" → Pro (podstawowy) / Max / nie wiem - and on "nie wiem"
assume Pro (the safe default for participants). Log it inside
`model_info{plan, plan_source:"detected"|"asked"|"assumed"}`.

## Step 2: the advice matrix (quality first, on every plan)

| Plan | Stages 1–4 (build) | Late-game cosmetic tweaks + stage 6 copy | Never |
|---|---|---|---|
| **Max / Team** | strongest available (Opus-class), **high effort** | Sonnet-class fine | Haiku-class for building |
| **Pro (participants' default)** | **same: strongest available, high effort** - accept that the 5h window may end mid-evening; warn once up front: "przy Twoim planie zrobimy czasem przerwę - to normalne" | Sonnet-class fine (quality can't suffer there) | Haiku-class for building; silent downgrades to stretch the limit |

On Pro the levers for the tight window are the token-economy rules below (they
cost zero quality) and honest pauses when the limit hits - NOT a weaker model or
lower effort on design/build work.

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

These rules save the limit without touching quality - apply them on Pro always,
on Max when convenient:

1. **Fresh session per stage.** STATE.md is designed to carry everything between
   sessions. At every `stage_end` on a Pro plan, actively suggest: "Zamknij okno i
   otwórz projekt na nowo - napisz cokolwiek, będę pamiętał. To oszczędza Twój
   limit." (Bonus: new sessions pick up plugin updates.) Never force it mid-stage.
2. **Prefer sequential subagent work on Pro.** Parallel agent batches multiply
   context N times; use them on Pro only when they genuinely buy quality or the
   user asked for speed - never as the default.
3. **Targeted reads.** Read the fragment you need, not whole generated files
   repeatedly; never re-`cat` a file you just wrote.
4. **Short outputs** are already invariant 13 (calibrated messages) - it also
   saves output tokens.
5. **Limits hit anyway?** Be honest ("limit odnowi się <kiedy> - zróbmy przerwę"),
   prefer a pause over a mid-architecture downgrade to Haiku-class. Log
   `error{category:"claude-limits"}` + the chosen path as `decision`.

> Maintenance note (Utopia): refresh model names as the lineup changes; the tables
> speak in tiers on purpose so they survive releases.
