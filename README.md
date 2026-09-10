# 👾 utopia-zero

**From zero to a developable app - with one skill.** A Claude Code plugin by
[UtopiaSoftware](https://utopiasoft.io) that walks a complete non-programmer from
an idea to a POC/MVP a professional team can take over: environment setup, an idea
and design interview, a clickable skeleton, a feature loop, and a handover a
developer can actually read.

You do not need to know how to code. You do not need a GitHub account. You will be
asked what you want to build, and everything technical is decided for you.

> ⚠️ **Experimental.** Three pilot runs so far. It works, and it still has rough
> edges we know about - see [Known limitations](#known-limitations).

## Start here (anyone)

1. Install [Claude Code](https://claude.com/product/claude-code).
2. Install the plugin. In the Claude Code **terminal**:

   ```
   /plugin marketplace add Utopia-USS/utopia-zero
   /plugin install utopia-zero@utopia-zero
   ```

   In the **desktop app** `/plugin` does not exist - use the CLI instead
   (`claude plugin marketplace add Utopia-USS/utopia-zero` then
   `claude plugin install utopia-zero@utopia-zero`).
3. Open an empty folder in Claude Code and run `/utopia-zero:start`.

The skill builds the project shell itself and takes it from there. Your analytics
stay in your own folder and nothing is sent to Utopia - see
[PRIVACY.md](PRIVACY.md).

**One recommendation worth taking:** install [Wispr Flow](https://wisprflow.ai) and
talk to the wizard instead of typing. The app it builds is made out of what you
tell it, and nobody types three paragraphs about their idea. Everybody says three
paragraphs.

## If Utopia sent you a ZIP

You are on the guided path. Unzip it, open the folder in Claude Code, and paste:

> **Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji.**
> / *Let's start. Guide me from zero to my own app.*

Step-by-step guide: 🇵🇱 [docs/ONBOARDING-PL.md](docs/ONBOARDING-PL.md) ·
🇬🇧 [docs/ONBOARDING-EN.md](docs/ONBOARDING-EN.md)

## What you get at the end

A Flutter app that runs in a browser and on a phone, in a git repository, with a
`HANDOVER.md` written for the developer who takes over: what was built, why, what
is missing, and how to run it. Pilot #1 reached a party game with online rooms,
nine passing tests and a public link, in roughly a week of evenings.

## Known limitations

Honest list, kept current:

- **Analytics hooks do not fire on the Windows desktop app.** Cause unknown. The
  wizard falls back to running them by hand, which works but depends on it
  remembering. On macOS they fire normally.
- **The self-serve path has never been run end to end.** Every run so far started
  from a prepared repo. If you are the first, expect rough edges and please open a
  run report.
- **A clean-machine install has never been tested on macOS** either; the one macOS
  run already had Flutter installed.
- Stage 5 (real devices) needs heavy toolchains and is optional by design.

## For Utopia operators

`/utopia-zero:prepare <slug> <participant_id>` creates the private participant repo,
config, PAT and ZIP. `/utopia-zero:inbox` collects open `[zero]` issues across
participant repos and helps you answer them; the participant's wizard picks the
reply up at their next session start.

## Repo layout

| Path | What it is |
|---|---|
| [`plugins/utopia-zero/`](plugins/utopia-zero/) | The plugin: the staged wizard skill + its references, `/utopia-zero:start`, `/utopia-zero:prepare`, `/utopia-zero:inbox` |
| [`starter/`](starter/) | The project shell copied into each participant repo: settings, analytics hooks (`.sh`/`.ps1`), state files, config, web-preview workflow |
| [`docs/`](docs/) | Design doc, onboarding (PL/EN), the invite message to send with the ZIP, and the findings from every run |

The findings documents are worth reading even if you never run this: they are a
blow-by-blow record of what breaks when a non-programmer builds software with an
AI, and why.

## How it relates to [utopia-flutter-skills](https://github.com/Utopia-USS/utopia-flutter-skills)

utopia-zero does not duplicate the Utopia Flutter skills, it **orchestrates** them.
The starter pre-declares `utopia-hooks`, `utopia-ai-arch`, `utopia-dart-lsp`,
`utopia-cms` and `utopia-reviews`, and the wizard drives them on the user's behalf.

## Contributing

Run reports are worth more than patches here - see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

BSD 2-Clause - see [LICENSE](LICENSE).
