# Model advice (stage 0 + whenever it changes)

Quality of stages 1–4 decides developability - the experiment's #1 metric - so the
default advice is simple: **the strongest model available on the user's plan, with
high reasoning effort, for designing and building.** Economy is allowed only where
it can't hurt the architecture.

| Work | Advice |
|---|---|
| Stages 1–4: interview, architecture, features, debugging | strongest available (Claude 5 family - e.g. Fable 5 / Opus-class), extended thinking / high effort ON |
| Stage 4 late-game: long series of small cosmetic tweaks | a fast strong model (Sonnet-class) is acceptable |
| Stage 6 polish + copywriting | Sonnet-class fine |
| Never for building | small/fast tiers (Haiku-class) |

How to deliver the advice (Zero mode, user's language, one breath): "Sprawdź, jaki
model jest wybrany przy polu wiadomości - na czas budowania najlepszy będzie
<model>. Pokażę Ci gdzie to przełączyć." Describe the model selector generically
(desktop app: selector at the composer / conversation header) - UI details drift, so
point at the concept, ask what they see, guide from there.

Then log `model_info{model, effort, source: "advised"|"user"}` - also every time the
user changes the model later (`source:"user"`).

Subscription limits: when usage warnings appear or replies get throttled, be honest
("limit planu odnowi się <kiedy> - zróbmy przerwę / wróćmy jutra"), and prefer a
pause over downgrading the model mid-architecture. Downgrade willingly only for the
economy rows above. Log the moment as `error{category:"claude-limits"}` + the chosen
path as `decision`.

> Maintenance note (Utopia): refresh the model names here as the lineup changes;
> the table speaks in tiers on purpose so it survives releases.
