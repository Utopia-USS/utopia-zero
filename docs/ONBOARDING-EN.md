# Build your app - getting started (utopia-zero)

**Short version (usually all you need):** install the **Claude Code** app
(https://claude.com/download) and log in → unzip the package from Utopia → open
the unzipped folder in Claude Code (Open project) → accept everything it asks
about (folder trust, add-on install, restart) → **type anything**, e.g. "start".
From that moment the guide leads you by the hand - including installing
whatever else is needed.

Below is the same path step by step with screenshots - in case something goes
differently. ~20-30 minutes. No skills required.

## What you need

- A **Mac** or **Windows** computer with at least **10 GB** free.
- Stable internet (big downloads ahead).
- A Claude account with a subscription - your own, or credentials from Utopia.
- **The ZIP package from Utopia** (your project), sent to you directly.
- ~30 calm minutes to start.

## What gets installed (and by whom)

| Program | What for | Who installs it |
|---|---|---|
| **Claude Code** | the app where you talk and your project gets built | **You** - step 1 below (the only manual install) |
| **Git** | the "safe" that records every step of the work | **the guide**, along the way - it only asks for your OK |
| **Flutter** | the engine your app runs on | **the guide**, along the way (big download, ~15 min) |
| dictation (optional) | speak instead of typing | you - see the "Dictation" section below |

So: you manually install Claude Code only. The guide handles the rest - when it
asks for permission to install something, just agree.

> 🔒 Privacy: the project records how the work goes (steps, decisions, conversation
> copies) into your private repository so Utopia can study how well this process
> works. You can turn it off at any moment by typing: **"disable analytics"**.

## Step 1 - Install the Claude Code app

Go to **https://claude.com/download** and install **Claude Code** for your system
(Mac / Windows), like any other app.

`[SCREENSHOT: download page with the button highlighted]`

## Step 2 - Sign in

Open Claude Code and sign in to the Claude account (yours or the one from Utopia).

`[SCREENSHOT: sign-in screen]`

## Step 3 - Unpack the package

Unzip the package you received, e.g. into `Documents/MyApp`. It contains a ready
project - don't change anything in it by hand.

`[SCREENSHOT: unpacked folder]`

## Step 4 - Open the project

In Claude Code choose **Open project** and select the unpacked folder.

`[SCREENSHOT: folder picker]`

## Step 5 - Accept the add-ons

After opening the folder, the app will offer to install add-ons (the "utopia-zero"
and "utopia-flutter-skills" marketplaces plus a few plugins). **Accept all of
them.** Then quit the app, reopen it, and open your folder again.

`[SCREENSHOT: the add-on installation prompt]`

> A **folder-trust** question (Trust) may appear first - confirm it; the add-on
> prompt follows right after.
> No prompt appeared? See the FAQ below.

## Step 6 - Turn on automatic mode

In the chat window switch the permission mode to **automatic (auto-accept)** so
Claude doesn't ask for approval on every action.

`[SCREENSHOT: the mode toggle with AUTO highlighted]`

> You'll recognize it's off by constant "Allow?" popups - come back to this step.

## Step 7 - Start!

Type (or dictate) **anything** - this is enough:

```
start
```

From here the guide takes over: it presents the stage plan, interviews you about
your idea, and owns all the technical work. Wolisz po polsku? Zacznij od:
`Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji.` - the conversation
language follows you and can be switched at any time.

## Coming back after a break?

Open Claude Code → open your folder → type: **"continue"**. The guide remembers
exactly where you left off.

## Dictation - talk, don't type

Free-flowing, long answers work best - the guide sorts them out. Three options,
simplest first:

1. **The microphone in Claude Code** - the mic icon by the chat box. Note: it
   understands **English** best; other languages can be hit-and-miss.
2. **System dictation in your language** (recommended):
   - **Windows**: press **Win + H**, pick your language and speak - text goes
     straight into the chat box.
   - **Mac**: System Settings → Keyboard → Dictation - turn it on; trigger is
     the 🎤 (F5) key or double-press Fn (🌐) - the exact shortcut is shown in
     that same settings pane.
3. **A Whisper-based app** (for the curious - best quality, works offline):
   ask your Utopia contact for a current recommendation for your system.

## Good habits

- During big downloads ("this will take ~20 minutes") keep the computer awake and
  the app open.
- Nothing can be permanently broken - every step is saved "to the safe".

## FAQ - when something's off

| Symptom | What to do |
|---|---|
| No add-on prompt (step 5) | **Fully quit** the app (not just the window), open it again and open the same folder - the add-on install popup should appear; accept everything. Then type anything - the guide fetches the rest itself. No popup at all? No problem - type anything and the guide **downloads itself** and proceeds normally. Note: `/plugin ...` commands **do not work in the app** - only in Claude Code in a terminal (there: `/plugin marketplace add Utopia-USS/utopia-zero`, then `/plugin install utopia-zero@utopia-zero`). |
| Constant "Allow…?" popups | Automatic mode is off → step 6. |
| A usage-limit message | Your plan has time-window limits. The app shows when it resets - come back then and type "continue". |
| Something looks broken / confusing | Just type: "what's going on?" - the guide explains in plain words. |
| Nothing helps | Reach out directly to the Utopia person who sent you the package (same channel). Fallback: **info@utopiasoft.io**. |

Good luck! 🚀
