# Design interview (stage 1) → design tokens

Goal: enough visual direction to make stage 2's welcome screen feel "theirs", encoded
as tokens the code can use. Full creative freedom for the user; full technical
translation by you. "Nie znam się / zdecyduj ty" is a first-class answer.

## Questions (open unless marked; adapt, keep intent)

1. **Charakter**: "Gdyby Twoja aplikacja była osobą — jaka jest? Rzuć kilka
   przymiotników." (poważna, ciepła, zabawowa, elegancka, surowa…)
2. **Inspiracje**: "Pokaż lub wymień 2–3 aplikacje albo strony, które Ci się PODOBAJĄ
   wizualnie. Co Ci się w nich podoba?"
3. **Kolory**: "Masz ulubione kolory, kolory marki, albo takie, których nie znosisz?"
4. Clickable — **tryb**: jasny / ciemny / oba (domyślnie: oba, start od jasnego).
5. Clickable — **gęstość**: "Dużo informacji na ekranie" / "Dużo powietrza, mniej naraz".
6. Clickable — **ton skali**: bardzo poważna / neutralna / zabawowa.

Reflect the answers back in one sentence ("czyli: ciepło, prosto, zielono — tak?").

## Mapping answers → tokens (yours, silent)

| Signal | Token decision |
|---|---|
| brand/favourite colour | `seed` = that colour (Material 3 `ColorScheme.fromSeed`) |
| no colour opinion | seed by domain vibe: usługi/biznes `#2F5DA8`, zdrowie/natura `#2E7D5B`, rozrywka/impreza `#B3418E`, edukacja `#5B4DB3`, narzędzie codzienne `#455A64` |
| character: zabawowa | font Nunito/Quicksand, radius 20–24, playful empty-states |
| character: elegancka | font Fraunces/Playfair (headings) + Inter (body), radius 8 |
| character: neutralna/poważna | font Inter/Manrope, radius 12 |
| density: dużo informacji | compact paddings, list-first layouts |
| density: powietrze | roomy paddings, card-first layouts |

Record tokens in BRIEF's design section (EN line): `seed #2E7D5B · font Nunito ·
radius 20 · density roomy · mode both(light-first)`.

## Rules

- Google Fonts only (offline-safe via `google_fonts` package); one display + one body
  font max.
- Accessibility floor regardless of answers: text contrast ≥ 4.5:1, touch targets
  ≥ 48dp — never trade these away.
- "Zdecyduj ty" → neutral modern default (Inter, radius 12, domain-vibe seed) and say
  one sentence about what you chose, in their language, no jargon.
- The stage-2 welcome screen is the design checkpoint: if the vibe is wrong there,
  fixing it costs minutes; log `checkpoint{feature:"welcome", verdict}` and iterate.
- Later screens reuse tokens only — no per-screen restyling. The user can change the
  direction any time (it's a creative decision → theirs); log `user_override`.
