# Build your app - getting started (utopia-zero)

**Short version (usually all you need):** install the **Claude** app
(https://claude.com/download) and log in → unzip the package from Utopia → in
the app's **Code** tab choose **Local** → **Select folder** and pick the unzipped
folder → accept everything it asks about (folder trust, add-on install,
restart) → **type anything**, e.g. "start".
From that moment the guide leads you by the hand - including installing
whatever else is needed.

Below is the same path step by step with screenshots - in case something goes
differently. ~20-30 minutes. No skills required.

## What you need

- A **Mac** or **Windows** computer with at least **10 GB** free.
- Stable internet (big downloads ahead).
- A Claude account with a paid plan (**Pro** or **Max**) - your own, or credentials from Utopia.
- **The ZIP package from Utopia** (your project), sent to you directly.
- ~30 calm minutes to start.

## What gets installed (and by whom)

| Program | What for | Who installs it |
|---|---|---|
| **Claude** (the Code tab) | the app where you talk and your project gets built | **You** - step 1 below (the only manual install) |
| **Git** | the "safe" that records every step of the work | **the guide**, along the way - it only asks for your OK |
| **Flutter** | the engine your app runs on | **the guide**, along the way (big download, ~15 min) |
| Wispr Flow (optional) | speak instead of typing - or use the mic built into Claude | you - see the "Dictation" section below |

So: you manually install the Claude app only. The guide handles the rest - when it
asks for permission to install something, just agree.

> 🔒 Privacy: the project records how the work goes (steps, decisions, and
> conversation copies only if you agree to them separately) into your private repository so Utopia can study how well this process
> works. You can turn it off at any moment by typing: **"disable analytics"**.

## Step 1 - Install the Claude app

Go to **https://claude.com/download** and download the app for your system
(Mac / Windows). Install it like any other program. Already have Claude on your
computer? Great - that is the right app; just make sure it is up to date.

> Claude Code is no longer a separate app: it is the **Code** tab inside the
> regular Claude app (alongside Chat and Cowork). Everything below happens in
> that tab.

`[SCREENSHOT: download page with the button highlighted]`

## Step 2 - Sign in

Open Claude and sign in to the Claude account (yours or the one from Utopia).
Then click the **Code** tab at the top centre. If it asks you to upgrade, the
account needs a paid plan (Pro or Max).

`[SCREENSHOT: sign-in screen]`

## Step 3 - Unpack the package

Unzip the package you received, e.g. into `Documents/MyApp`. It contains a ready
project - don't change anything in it by hand.

`[SCREENSHOT: unpacked folder]`

## Step 4 - Open the project

In the **Code** tab choose **Local**, click **Select folder** and pick the unpacked
folder (the one that contains `zero` and `README.md`, not a folder inside it).

`[SCREENSHOT: folder picker]`

## Step 5 - Accept the add-ons

After opening the folder, the app will offer to install add-ons (the "utopia-zero"
and "utopia-flutter-skills" marketplaces plus a few plugins). **Accept all of
them.** Then quit the app, reopen it, and open your folder again.

`[SCREENSHOT: the add-on installation prompt]`

> A **folder-trust** question (Trust) may appear first - confirm it; the add-on
> prompt follows right after.
> No prompt appeared? See the FAQ below.

## Step 6 - Check the permission mode

Next to the send button there is a permission-mode selector. Set it to
**Accept edits** (the project usually sets this itself) so Claude doesn't ask for
approval on every action.

`[SCREENSHOT: the mode selector next to the send button]`

> You'll recognize the wrong mode by constant "Allow?" popups - come back to this step.

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

Open Claude → the **Code** tab → your folder (it is in the sidebar) → type: **"continue"**. The guide remembers
exactly where you left off.

## Dictation - talk, don't type

Two good ways - pick either:

- **The microphone in Claude** - the mic icon under the chat field. Nothing to
  install: click, speak, click again, and the text lands in the field.
- **Wispr Flow: https://wisprflow.ai** (Windows, Mac, iPhone, Android) - a
  separate app that types what you say into any text field on your computer.

It is worth it, and it may be the most useful advice on this page. The guide
builds your app out of what you tell it, so the more detail it gets, the closer
the result lands. And the honest truth is that nobody wants to type three
paragraphs about their idea. Saying three paragraphs costs nothing. Speaking
gives the guide several times more to work with, for less effort - and it shows
most in the idea interview at the very start.

Your operating system's own dictation (Windows **Win + H**; Mac: System Settings
→ Keyboard → Dictation) is a last resort - outside English it can be unreliable,
and our first participant never got it working at all.

## Good habits

- During big downloads ("this will take ~20 minutes") keep the computer awake and
  the app open.
- Nothing can be permanently broken - every step is saved "to the safe".

## FAQ - when something's off

| Symptom | What to do |
|---|---|
| No add-on prompt (step 5) | **Fully quit** the app (not just the window), open it again and open the same folder - the add-on install popup should appear; accept everything. Then type anything - the guide fetches the rest itself. No popup at all? No problem - type anything and the guide **downloads itself** and proceeds normally. Note: `/plugin ...` commands **do not work in the app** - only in Claude Code in a terminal (there: `/plugin marketplace add Utopia-USS/utopia-zero`, then `/plugin install utopia-zero@utopia-zero`). |
| Constant "Allow…?" popups | Wrong permission mode → step 6. |
| Claude answers but can't see any files or the project | You're in the **Chat** tab - switch to **Code** and open the folder (step 4). |
| A usage-limit message | Your plan has time-window limits. The app shows when it resets - come back then and type "continue". |
| Something looks broken / confusing | Just type: "what's going on?" - the guide explains in plain words. |
| Nothing helps | Reach out directly to the Utopia person who sent you the package (same channel). Fallback: **info@utopiasoft.io**. |

Good luck! 🚀
