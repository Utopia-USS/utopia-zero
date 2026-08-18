# utopia-zero project

This project runs in **utopia-zero mode**: a guided, staged path from an idea to a
developable Flutter POC, usually driven by a **non-programmer**. The utopia-zero
skill (plugin `utopia-zero@utopia-zero`) governs everything - always work through it.

Standing rules (they hold even if the skill didn't auto-load):

1. **ANY first message starts the wizard.** "cześć", "start", "co teraz?", a
   question - whatever the user writes, read `zero/STATE.md` + `zero/config.json`
   and enter the utopia-zero skill's session entry protocol. Never wait for a
   magic phrase, never answer "how can I help" - fresh project → greet warmly in
   the user's language, one sentence about what happens next, and begin stage 0;
   STATE mid-flight → resume. The user was told everything happens by itself.
1a. **If the utopia-zero skill is NOT available** (plugins not installed yet):
   do NOT dump commands, and **never tell them to paste `/plugin ...`** - that
   command does not exist in the desktop app (it answers "Some commands only work
   in the Claude Code terminal"). Work this order instead:
   (a) **try it yourself first, silently, via Bash**: `claude plugin marketplace add
   Utopia-USS/utopia-zero`, then `claude plugin install utopia-zero@utopia-zero`
   (the CLI often sits next to the desktop app; if it's missing or refuses, never
   mind - move on to (b) without bothering the user with the details);
   (b) then guide them, ONE step per message, confirming each: **fully quit the
   app** (not just close the window), **open it again**, **open this folder** -
   and **accept the add-on install popup** that appears; then write anything.
   (c) the `/plugin marketplace add Utopia-USS/utopia-zero` +
   `/plugin install utopia-zero@utopia-zero` lines may ONLY be suggested if the
   user is working in the Claude Code **terminal** - never in the desktop app.
2. **Language**: speak the user's language (config `language_default` is the
   tiebreak). Code, commits, `zero/DECISIONS.md`, `zero/HANDOVER.md` - English.
3. **Hide technicalities** - the user owns creative decisions, you own ALL technical
   ones. Never ask them a technical question.
4. Flutter work follows the **utopia-hooks** skill (Screen/State/View); admin panels
   follow **utopia-cms**.
5. **Secrets**: tokens/keys live only in `zero/.pat` and `app/.env` (both gitignored).
   Never commit, echo, or log them.
6. **Analytics**: log events per the skill's `references/analytics.md` via
   `zero/scripts/log_event.sh` (macOS) / `.ps1` (Windows). The user can disable it
   at any time ("wyłącz analitykę").
7. Commit + push after every completed step; small commits, English messages.

<!-- stage 2 appends project facts here: app name, run command, BRIEF pointer -->
