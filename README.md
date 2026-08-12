# 👾 utopia-zero

**From zero to a developable app - with one skill.** An experimental Claude Code
plugin by [UtopiaSoftware](https://utopiasoft.io) that guides a complete
non-programmer from an idea to a professional-grade POC/MVP: environment setup,
plugin installation, a staged wizard from idea interview to handover - with
built-in, opt-out analytics so every run can be studied afterwards.

> ⚠️ **Experimental** - pilot phase, under active development.
> Full design document (Polish): [docs/DESIGN.md](docs/DESIGN.md).

## For participants

You should have received a **ZIP package** and a link to the step-by-step guide:

- 🇵🇱 [docs/ONBOARDING-PL.md](docs/ONBOARDING-PL.md)
- 🇬🇧 [docs/ONBOARDING-EN.md](docs/ONBOARDING-EN.md)

Short version: install Claude Code → unzip → open the folder → accept the add-ons →
paste *„Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji."* /
*"Let's start. Guide me from zero to my own app."*

## For anyone (self-serve)

The skill is public. In any Claude Code session:

```
/plugin marketplace add Utopia-USS/utopia-zero
/plugin install utopia-zero@utopia-zero
```

Then, in an empty folder, run `/utopia-zero:start` - the skill bootstraps the
project shell itself (analytics stays local in your repo; no data goes to Utopia).

## For Utopia operators

Preparing a participant repo (private `poc-<slug>`, config, PAT, ZIP):
`/utopia-zero:prepare <slug> <participant_id>` - or follow the manual checklist in
[docs/DESIGN.md](docs/DESIGN.md) §12. Escalations arrive as `[zero]`-prefixed
issues in the participant repo; answer them there - the next session picks your
reply up automatically.

## Repo layout

| Path | What it is |
|---|---|
| [`plugins/utopia-zero/`](plugins/utopia-zero/) | The plugin: `utopia-zero` skill (staged wizard, 9 references) + `/utopia-zero:start` + `/utopia-zero:prepare`, served from this repo's own marketplace |
| [`starter/`](starter/) | The project shell copied into each participant repo: `.claude` settings (marketplaces + plugins + auto-accept), analytics hooks (`.sh`/`.ps1`), state files, config |
| [`docs/`](docs/) | Design doc + participant onboarding guides (PL/EN) |

## How it relates to [utopia-flutter-skills](https://github.com/Utopia-USS/utopia-flutter-skills)

`utopia-zero` doesn't duplicate the Utopia Flutter skills - it **orchestrates**
them. The starter pre-declares `utopia-hooks`, `utopia-ai-arch`, `utopia-dart-lsp`,
`utopia-cms`, and `utopia-reviews` from the `utopia-flutter-skills` marketplace,
and the wizard drives them on the user's behalf.

## License

BSD 2-Clause - see [LICENSE](LICENSE).
