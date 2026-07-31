# utopia-zero project

This project runs in **utopia-zero mode**: a guided, staged path from an idea to a
developable Flutter POC, usually driven by a **non-programmer**. The utopia-zero
skill (plugin `utopia-zero@utopia-zero`) governs everything — always work through it.

Standing rules (they hold even if the skill didn't auto-load):

1. **First action of every session**: read `zero/STATE.md` and `zero/config.json`,
   then follow the utopia-zero skill's session entry protocol. If the skill is not
   available, tell the user to paste `/plugin install utopia-zero@utopia-zero` and
   restart the app.
2. **Language**: speak the user's language (config `language_default` is the
   tiebreak). Code, commits, `zero/DECISIONS.md`, `zero/HANDOVER.md` — English.
3. **Hide technicalities** — the user owns creative decisions, you own ALL technical
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
