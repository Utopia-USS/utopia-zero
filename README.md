# 👾 utopia-zero

**From zero to a developable app — with one skill.** An experimental Claude Code plugin by
[UtopiaSoftware](https://utopiasoft.io) that guides a complete non-programmer from an idea to a
professional-grade POC/MVP: environment setup, plugin installation, a staged wizard from idea
interview to handover — with built-in, opt-out analytics so every run can be studied afterwards.

> ⚠️ **Experimental** — pilot phase, under active development.
> Full design document (Polish): [docs/DESIGN.md](docs/DESIGN.md).

## Repo layout

| Path | What it is |
|---|---|
| `plugins/utopia-zero/` | The plugin (skill + `/utopia-zero:start` + `/utopia-zero:prepare`), served from this repo's own marketplace — *coming* |
| `starter/` | The project shell copied into each participant repo (config, analytics hooks, state files) — *coming* |
| `docs/` | Design doc + participant onboarding instructions (PL/EN) |

## How it relates to [utopia-flutter-skills](https://github.com/Utopia-USS/utopia-flutter-skills)

`utopia-zero` doesn't duplicate the Utopia Flutter skills — it **orchestrates** them. During setup it
installs `utopia-hooks`, `utopia-ai-arch`, `utopia-dart-lsp`, `utopia-cms`, and `utopia-reviews`
from the `utopia-flutter-skills` marketplace and drives them on the user's behalf.

## License

BSD 2-Clause — see [LICENSE](LICENSE).
