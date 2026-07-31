# Idea interview (stage 1)

Goal: everything needed for `zero/BRIEF.md` — vision, audience, feature list with an
MVP cut, admin-panel decision — without the user ever touching a technical concept.

## How to run it

- **Open questions, one at a time.** Users dictate via speech-to-text: invite long
  answers ("opowiedz swobodnie, ja to poukładam"), never interrupt, never compress
  their answer into 4 clickable options.
- **Reflect back** after each big answer: "Czyli: … — zgadza się?" Corrections are
  gold; log `answer{changed_prior:true}` when they revise something.
- Clickables only for true forks (MVP approval, admin yes/no, priority picks ≤4).
- Everything in the user's language; write BRIEF.md in that language too.

## Core questions (adapt wording, keep intent)

1. **Pomysł**: "Opowiedz mi o swoim pomyśle — co to za aplikacja i skąd się wzięła?"
2. **Odbiorca i scena**: "Kto będzie z niej korzystał i w jakim momencie dnia /
   w jakiej sytuacji po nią sięgnie?"
3. **Sukces**: "Wyobraź sobie, że apka działa od miesiąca i jest świetnie. Co się
   zmieniło? Po czym poznasz, że działa?"

Follow-ups as needed:

- "Przeprowadź mnie przez jedno typowe użycie, krok po kroku, jak opowieść."
- "Jak ten problem jest rozwiązywany dziś — kartka, Excel, inna apka? Co wkurza?"
- "Czy ktoś oprócz zwykłych użytkowników będzie czymś zarządzał? (treści, ceny,
  wydarzenia, zgłoszenia…)" ← feeds admin detection.
- "Jest coś, czego ta aplikacja ma NIE robić?"

## Feature extraction → MVP cut

1. Turn the answers into a plain-language feature list (their words, not yours).
2. **You draft the cut**: MVP now / Później / Poza zakresem — smallest set that makes
   the success-question true. Present it as a short list.
3. One clickable: "Zatwierdzasz taki podział na start?" (Zatwierdzam / Chcę coś
   przesunąć — open follow-up). Every moved item → `user_override`.
4. Rule of thumb: MVP ≤ 5 features. More → say honestly that smaller = faster first
   version, and park the rest in "Później".

## Admin-panel detection (utopia_cms)

Signals — any of these in their answers:

- owner-managed content (menu, cennik, wydarzenia, FAQ, ogłoszenia),
- moderation or approving user submissions,
- roles beyond "user" (owner, employee, moderator),
- "chcę widzieć statystyki / kto się zapisał",
- content that changes without releasing a new app version.

Pitch (plain words, no "CMS"): "Przy Twoim pomyśle przydałoby się osobne miejsce,
w którym Ty — jako właściciel — zmieniasz X bez grzebania w aplikacji. Robimy je?"
Options: Tak, od razu / Może później / Nie. Record in BRIEF; if "tak", it becomes a
stage-4 feature built with the utopia-cms skill in `admin/`.

## BRIEF.md structure (user's language)

```markdown
# BRIEF — <nazwa robocza>
> Zatwierdzony: <data> · Język projektu: <PL/EN>

## Wizja (2–3 zdania)
## Dla kogo i na jaką sytuację
## Po czym poznamy sukces
## Funkcje
### MVP (budujemy teraz)
### Później
### Poza zakresem
## Panel właściciela: tak / później / nie (+ co się w nim zarządza)
## Design brief
- charakter (przymiotniki):
- kolory / czego unikać:
- tryb: jasny / ciemny / oba
- inspiracje (aplikacje, które się podobają):
- tokeny (techniczne, EN): seed #…, font …, radius …, density …
## Nazwa robocza
```

Read back a 5-line summary before asking for approval — the BRIEF is the contract
for stages 2–6 and the first handover artifact.
