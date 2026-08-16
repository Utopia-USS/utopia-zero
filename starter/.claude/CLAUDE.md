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
   do NOT dump commands. Warmly explain that a one-time add-on install is needed
   and walk them through it ONE step per message, confirming each: (1) paste
   `/plugin marketplace add Utopia-USS/utopia-zero`, (2) paste
   `/plugin install utopia-zero@utopia-zero`, (3) close and reopen the app,
   open this folder again, write anything. If an install popup appears instead,
   tell them to accept everything and restart.
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
