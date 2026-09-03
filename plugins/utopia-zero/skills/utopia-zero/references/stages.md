# Stage scripts (0–6)

Shared rules for every stage:

- **Idempotent**: before each action, check whether it already happened (file exists,
  tool responds, STATE says done). Re-running a stage never breaks anything.
- **Events**: log `stage_start` when entering (and write the stage number to
  `zero/analytics/.stage`), `stage_end` when the exit criteria pass; on a Pro
  plan also suggest the fresh-session reset from `model-advice.md` (token
  economy). Log the
  per-action events named below.
- **STATE**: update `zero/STATE.md` at stage end AND after any step whose loss would
  hurt (mid-stage progress, pending restart, awaited user input).
- Time estimates before anything slow; big-download warnings ("~20 min - zostaw
  komputer włączony, nie zamykaj aplikacji").
- **Commit by explicit paths** (`git add app/ zero/ .claude/…`), never a blanket
  `git add -A` - operator/IDE artifacts (`.idea/`, `.vscode/`) must not enter the
  repo even if the ignores miss them.

## Stage 0 - Start & tutorial

**Entry:** fresh project, or STATE stage 0 (possibly mid-flight, e.g. "restart pending").

> **Virgin-machine note:** on a fresh macOS, `git` arrives only with the Command Line
> Tools (stage 2); on fresh Windows, with Git for Windows (stage 2). If `git
> --version` fails now, DEFER the git-dependent parts of steps 6–8 (identity, remote,
> push, commit): record "deferred: git steps" in STATE and complete them in stage 2
> immediately after the toolchain lands. Everything else in stage 0 proceeds.

1. Read `zero/config.json`. Detect OS + basics; log `env{os, arch, disk_free_gb, git, flutter}`.
2. **Mode** (clickable): "Czy kiedykolwiek programowałeś/aś?" → nigdy (→ Zero) /
   trochę (→ Zero) / jestem programistą (→ Pro) / jestem z Utopii. The last option
   only ASKS for the passphrase ("jestem z utopii") - Utopia mode is an insider
   surface (stage jumping, analytics introspection, raw technical transparency), so
   clicking a button must not be enough to enter it. No passphrase → treat as Pro
   and move on without making a thing of it. Log `question`/`answer`, and
   `tutorial{skipped:true}` for Pro.
2b. **Audience** (clickable, ONE question, before anything about data): "Czy jesteś
   przyjacielem Utopii?" → tak / nie. This is not small talk - it decides what may
   be collected and whether a help channel exists. Write `audience: "friend"` or
   `"public"` into `zero/config.json`, log `question`/`answer` +
   `decision{area:"audience", user_involved:true}`.
   - **friend**: a Utopia channel exists. Refer to it ONLY as "Utopia" - never a
     person's name, never an e-mail, in chat or in any prepared message. A friend
     already knows who to write to; naming someone turns a project file into
     personal data and ages badly the moment that person changes role.
   - **public**: there is no channel. Say so plainly and once ("prowadzisz to
     samodzielnie"), and never send them chasing a contact that will not answer.
3. **Data, shaped by the audience** (plain words, both modes). Always explain: what is
   collected (steps, decisions, errors, time), where it lives (their own repo), and
   that "wyłącz analitykę" works at any moment. Then:
   - **friend**: ask about analytics AND about conversation transcripts, as two
     separate questions - transcripts are a bigger ask than event counters and must
     never ride along on one "yes". Say plainly that Utopia can read what lands in
     the repo.
   - **public**: ask about analytics ONLY. **Transcripts are never collected and
     never offered** - set `transcripts_enabled: false` and do not raise the subject.
     The events stay in their own repo; nobody at Utopia sees them unless the person
     chooses to share the repo. Never imply Utopia is watching a stranger's project.
   Log `consent{analytics, transcripts}` either way (public always logs
   `transcripts:false`).
4. **Tutorial** (Zero mode only, ~6 short paragraphs, user's language): how this chat
   works; stages 0–6 overview; nothing is ever lost ("wysyłam kopie do sejfu");
   how to come back ("otwórz projekt i napisz: kontynuuj"); auto-accept: where the
   AUTO/permissions toggle lives, and the symptom of it being off (constant
   "Allow?" popups → tell me and I'll guide you).
4a. **Dictation - recommend it properly, once** (both modes, clickable, still the
   user's choice): "Najlepiej pracuje się mówiąc - długie, swobodne wypowiedzi.
   Polecam Wispr Flow, to zmienia sposób pracy z asystentem." → zainstaluję /
   już mam / nie, będę pisać.
   - The recommendation is **Wispr Flow**: https://wisprflow.ai (Windows, macOS,
     iPhone, Android). Give the link and one honest sentence about why it matters:
     spoken answers are longer and carry far more detail than typed ones, and this
     whole flow runs on how much the wizard learns from you - the idea interview in
     stage 1 most of all. Nobody types three paragraphs about their app idea;
     everybody says three paragraphs.
   - **Say up front that it is a system-wide app**: it types into ANY text field,
     so there is nothing to "connect" to Claude. Pilot #2's first move after
     installing was asking the wizard to connect it - the integration mental
     model is the lay default, and one sentence prevents the whole detour.
   - **Do not send them round the built-in options first.** Pilot #1 burned three
     attempts on Windows dictation (Win+H) before giving up and typing all the way
     through - it does not do Polish reliably, and the Claude Code mic is noticeably
     weaker outside English. Mention them only as a fallback if the user declines
     the install.
   - Frame it as strongly recommended, never a requirement, and never block on it.
     Do not walk them through the install click by click unless they ask - it is a
     normal app with its own onboarding.
   Log `decision{area:"dictation", choice:"<wispr-flow|already-has|typing|system>",
   user_involved:true}`. **Return to this once** if their answers get very short or
   dictation-garbled: terse input is the visible symptom of the thing this step
   exists to prevent.
5. **Model advice** per `model-advice.md`; log `model_info`.
   *After each of steps 2–5, update `zero/STATE.md` immediately (mode, consent,
   model) - a session dying mid-stage-0 must not lose these answers.*
6. **Git identity** (silent): `git config user.name "<participant_id>"`,
   `git config user.email "<participant_id>@zero.utopiasoft.io"` (repo-local).
7. **Remote + PAT** (silent): if `zero/.pat` exists, set
   `git remote set-url origin https://x-access-token:<PAT>@<host>/<owner>/<repo>.git`
   (values from config `git_remote`); verify `git ls-remote origin` quietly; push
   current branch. No `.pat`? Try the EXISTING remote as-is first (`git ls-remote`,
   then push) - operator and self-serve machines often authenticate via their own
   SSH keys or credential helper. Only when nothing authenticates → continue
   local-only, note it in STATE. `audience: friend` → plan a "skontaktuj się
   z Utopią" step (just that, no name, no address). `audience: public` → say
   plainly that pushing needs their own GitHub account and offer to wire it.
8. **Wire analytics hooks** for this OS into `.claude/settings.json` (exact JSON in
   `analytics.md`), commit. Then the **one planned restart**: ask the user to fully
   quit and reopen the app, open the project again, and write "kontynuuj". Write
   `STATE: restart pending` first so the resume path knows to verify hooks
   (v9+: a fresh marker in `zero/analytics/.pending/` or a freshly rewritten
   `zero/analytics/.session` - the `session_start` LINE is deferred and only
   reaches `events.jsonl` with the session's first real event, see analytics.md)
   and move on.
   **If the restart leaves no trace of the start hook**: re-check per analytics.md
   (settings JSON validity, path, project folder - not a parent - opened), allow
   ONE more planned restart, and if there is still no trace, switch to the
   **manual hook dispatch** fallback (analytics.md) - from then on you run the
   hook scripts yourself at every session entry and wrap-up. Log the `error`,
   note `hooks: manual dispatch` in STATE, and keep going - never a third restart
   (pilot #1: the Windows desktop app never dispatched hooks despite correct
   wiring; the user must not pay for that in restarts).
9. **Verify plugins**: the starter's `.claude/settings.json` declares both
   marketplaces and the plugin set (utopia-zero + utopia-hooks, utopia-ai-arch,
   utopia-dart-lsp, utopia-cms, utopia-reviews). Check they're active (skills
   available). If not: try `claude plugin marketplace add …` / `claude plugin install
   <name>@<marketplace>` via Bash. If the CLI is missing or refuses, walk the user
   through a **full quit → reopen app → open this folder → accept the add-on popup**
   (do NOT tell a desktop-app user to paste `/plugin …` - that command exists only in
   the Claude Code terminal; offer those lines only if they are in a terminal).
10. `stage_end`; STATE → stage 1 with a one-line teaser of what's next.

**Exit:** consent logged · hooks confirmed live (or manual dispatch noted in STATE) · push worked (or degraded-local noted) · plugins active.

## Stage 1 - Idea & look

Load `interview-guide.md` + `design-interview.md` + `design-workshop.md`.
**Entry:** stage 0 done.

1. Idea interview (open questions, reflect back, no interrupting) → raw feature list.
2. MVP cut: you draft the split (MVP now / later / out of scope), present it in their
   language, they approve or move items (clickable approve / "zmień coś" open).
   Log `decision{area:"mvp-scope"}` (+ `user_override` for every moved item).
3. Admin-panel detection: scan the idea for owner-managed content, moderation, roles,
   pricing, stats. If signals exist, pitch in plain words; their call. Log
   `decision{area:"admin-panel", user_involved:true}`.
4. Design interview → design tokens draft (seed color, font, radius, density, mode).
5. **Pracownia** (`design-workshop.md`): full token set → `zero/design/tokens.css` +
   2–3 HTML mocks of the key MVP screens → user reviews them in the browser and
   iterates until accepted. Mandatory checkpoints per mock (even with visual
   checkpoints off - this is the visual contract for the whole build).
6. Write `zero/BRIEF.md` (user's language; structure in `interview-guide.md`,
   design section records tokens + mock list), read back a 5-line summary, get
   approval. Log `checkpoint{feature:"brief"}`.
7. **STATE names the visual contract**: write one line into `zero/STATE.md` -
   `Kontrakt wizualny / Visual contract: zero/design/`. The contract may later
   graduate (dry-run #2: an in-app workshop under `app/web/design/` plus a
   generated design-system page beat the static mocks) - graduating is welcome,
   but ONLY with the STATE line updated to the new location and a
   `decision{area:"design-contract"}` logged. A contract nobody can find is
   a broken protocol, not flexibility.
8. Commit + push (including `zero/design/`); `stage_end`.

**Exit:** BRIEF.md approved and pushed · 2–3 mocks accepted in `zero/design/`.

## Stage 2 - Foundations

Load `environment-macos.md` or `environment-windows.md` + `utopia-ui-build.md`.
**Entry:** BRIEF + mocks approved.

1. Environment for the **web goal only**: git + Flutter SDK + a system browser
   (no Chrome requirement - preview uses `flutter run -d web-server` and the default
   browser). Follow the OS playbook; log `env` again after installs.
2. `dart pub global activate utopia_cli`; verify `utopia` on PATH (playbook).
3. Create the app: `utopia create flutter_app app --org <config.org>` (check
   `utopia create --help` first and adapt; target directory `app/`). If `utopia
   create` fails twice, fall back to `flutter create` + manual `utopia_hooks` wiring
   per the utopia-hooks skill, and log `error` + `fix_attempt`.
   **Strip the sheet-backed localization generator BEFORE the first codegen.**
   The scaffold arrives wired to `utopia_localization_generator` with placeholder
   sheet ids (DOCID/SHEETID); on pilot #1 codegen fetched the sheet, got an HTML
   error page, baked it into `app_localizations` and blocked the build. A zero
   POC is single-language by design: remove the generator wiring (dependency +
   build config + its generated stubs), keep every UI string inline in the user's
   language, and log `decision{area:"localization", choice:"inline strings"}`.
   (Multi-language is a post-handover concern; a real sheet can be wired then.)
   **Dropping the generator must NOT drop Flutter's own localization delegates.**
   Keep `flutter_localizations` in the pubspec and, on the root `MaterialApp`,
   `localizationsDelegates` (GlobalMaterial/GlobalWidgets/GlobalCupertino) plus
   `supportedLocales: [Locale('<user language>')]`. Without them the FIRST
   `TextField` the app renders throws `No MaterialLocalizations found` at runtime -
   the analyzer stays green, so it detonates on a screen the user is looking at
   (pilot #1 hit exactly this after the strip).
   Then run the scaffold's code generation BEFORE any gate:
   `dart run build_runner build --delete-conflicting-outputs` - the fresh scaffold
   is not analyzer-clean until this runs (undefined generated classes are
   expected before it). A couple of info-level lints may remain in template files -
   fix them immediately so the analyze gate stays at literally zero issues.
4. **Visual layer** (`utopia-ui-build.md`): add `utopia_ui` via the dependency
   ladder (pub.dev → git → tokenized-Material fallback; log the rung), emit
   `lib/app/theme.dart` from the accepted Pracownia tokens, wire `UtopiaTheme` at
   the root + the Material mirror. Log `decision{area:"ui-dependency"}`.
5. Append project facts to `.claude/CLAUDE.md`: app name, user language, BRIEF path,
   `zero/design/` as the visual contract, "run: cd app && flutter run -d web-server
   --web-port 7357 --release" (the user-facing preview is always `--release`).
6. **Welcome screen**: replace the default home with a branded one - it must MATCH
   the accepted welcome mock (or, when no welcome mock exists, the tokens + patterns
   of the accepted mocks). Self-check the a11y floor from `design-interview.md`
   (text contrast ≥ 4.5:1 on every element, icons/assets instead of raw emoji).
7. Run it: `flutter run -d web-server --web-port 7357 --release` (background), open
   `http://localhost:7357` in the default browser for the user. **Every preview the
   USER looks at is a release build.** A debug web-server serves through dwds, which
   accepts a single debug connection - a second (or stale) browser tab leaves them
   staring at a blank white page and reporting "nic się nie otworzyło" (pilot #1
   burned a fix ladder on this). Debug is yours alone, for one tab you control; the
   release build costs a couple of minutes and is what the user sees. Ask what they see
   (clickable: "Widzę ekran powitalny!" / "Nic się nie otworzyło"). Log
   `build{target:"web"}` + `checkpoint{feature:"welcome"}`.
8. Gates: `flutter analyze` + `utopia doctor` (from `app/`). Fix until clean.
9. Ask the **visual checkpoint preference** (once): after each feature - show the app
   / don't show / "sam odpalam na telefonie". Save to STATE; log `decision`.
10. Commit + push. **The app is now online**: if `.github/workflows/deploy-web.yml`
   exists and the push went through, the preview builds itself at
   `https://<repo>.pages.dev` (~4 min). Tell the user in one warm sentence and
   give them the link - for a beginner, "my app has an address other people can
   open" is a bigger moment than any gate. Never promise it when the repo has no
   workflow or the push failed; a broken link costs more trust than no link.
   **Say plainly how public that address is**, in the same breath and in one
   sentence: anyone who has it can open it, and the address itself is not a secret,
   because addresses like this appear in public certificate registries the moment
   the site goes up. Their code and `zero/` stay private (only `build/web` is
   published), and the app holds no accounts or personal data - so this is a
   shop window, not a leak. A beginner hears "my app is online" as "only the people
   I send it to", and that assumption has to be corrected the first time, not after
   they send it somewhere they regret. If they want it closed, Cloudflare Access
   (Zero Trust, free tier, e-mail code) gates the whole site without touching
   the repo - offer it, never set it up unasked.
   While you are there, write `app/web/robots.txt` with `User-agent: *` +
   `Disallow: /` and commit it with the rest: it does nothing against scanners, but
   it keeps a personal practice project out of search results, and the scaffold
   ships no robots.txt at all, so every path answers 200 to a crawler.
   **Pulse survey #1** (two 1–5 clickables: "Czy czujesz, że masz
   kontrolę nad tym, co powstaje?", "Na ile jasne jest to, co się teraz dzieje?").
   Log `survey{stage:2}`. `stage_end`.

**Exit:** welcome screen seen by the user in a browser · gates clean · pushed.

## Stage 3 - Skeleton

**Entry:** stage 2 done. The utopia-hooks skill governs all code.

1. From BRIEF's MVP list derive the screen map (you decide navigation/structure).
2. Build every MVP screen as Screen/State/View skeleton with believable fake data
   (const lists, lorem-free, in the user's language) and wired navigation. Screens
   that have a Pracownia mock follow its layout; the rest reuse the same tokens and
   the app-local kit (`utopia-ui-build.md`).
2a. **A web POC must survive a browser refresh.** The user WILL hit F5 (and reopen
   the tab tomorrow). Flutter web rebuilds the route from the URL without the
   arguments it was pushed with, so any screen that reads route arguments renders
   an empty or grey page. Route through a startup/splash screen that re-derives
   state from storage instead of passing objects between routes, and check it by
   refreshing every screen yourself before the checkpoint (pilot #1: a grey screen
   after refresh cost a whole feature's debugging).
3. Run + **mandatory checkpoint** (even if checkpoints are off - this is the app map):
   "Przeklikaj się przez aplikację - to jej mapa. Zgadza się z Twoją wizją?"
   Log `checkpoint{feature:"skeleton", verdict, rework}`; iterate on "change".
4. Gates clean; commit + push; `stage_end`.

**Exit:** user approved the clickable skeleton.

## Stage 4 - Features (the loop)

Load `failure-playbooks.md`. **Entry:** skeleton approved. Repeat per feature:

1. Pick next feature: recommend one (dependency-first), user confirms or picks
   another (clickable list, ≤4 options per question). Log `feature_start`.
2. **Plan**: one paragraph, user's language, no jargon - what will exist when done.
   Approve (clickable: buduj / zmień plan / pomiń). Log `question`/`answer`.
3. Build per utopia-hooks (and utopia-cms for admin surfaces); visuals per
   `utopia-ui-build.md` - `Utopia*` widgets + project components, tokens only, never
   literals. An element no manifest component covers = GAP: report it (screen
   skill format) and scaffold a project component or file it upstream - never a
   silent hand-roll (`utopia-ui-build.md`, gap discipline). All technical choices yours; log `decision` (+ rationale +
   alternatives) for each significant one. **The loop is where decisions go missing**
   (pilot #1: 13 decisions across stages 0-3, ZERO in stage 4 while picking a
   persistence mechanism, a startup/routing shape and a preview mode). If a feature
   made you choose a package, a storage layer, a navigation shape or a data format,
   that is a `decision` - the handover reader has no other way to learn why.
4. **Backend, lazily** - first feature that needs it:
   - Choose provider yourself (auth/data/realtime/files needs → Firebase or Supabase).
     Log `decision{area:"backend-provider"}`.
   - **The account is an ORGANIZATIONAL decision, not a technical one** (SKILL.md
     invariant 3), so it is the one backend question you DO put to the user - and
     you put it before anything exists in anyone's name. v1 accounts come from
     Utopia. Do all three, in this order:
     1. `audience: friend` → **open a `[zero]` issue in this repo**
        (`failure-playbooks.md`) saying what to create, for which project and what
        to send back, then tell the user in one sentence that the request is with
        Utopia. Do NOT hand them a message to copy into e-mail: that costs a human
        round trip each way and comes back as something to paste, while an issue
        reply is read by the wizard itself at the next session start. A copyable
        message is the fallback for when there is no PAT. Say "Utopia" and nothing
        more - no personal name, no address, in chat or in the issue.
        `audience: public` → there is no Utopia to ask; the account is theirs, so
        say what needs creating, guide the clicks, and state the free-tier limits.
     2. Ask, clickable, with the consequence spelled out in plain words:
        "poczekać na konto Utopii (Utopia płaci i przejmie projekt)" /
        "założę własne teraz (szybciej, ale przeniesienie później = nowy projekt od
        zera i skasowanie tego)". **Do not silently pick either.** "Handing project
        creation to the user" is NOT delegating to Utopia - pilot #1 did exactly
        that and the participant ended up owning the project on a 30-day trial,
        outside Utopia's infrastructure, without ever being offered the alternative.
     3. Log `decision{area:"backend-account", choice, rationale, alternatives,
        user_involved:true}`, plus `user_override` when they pick their own account
        against the Utopia default, and `backend_step{delegated_to:"utopia"|"user"}`.
     **Never block the user while waiting**: keep building everything that does not
     need live credentials (client code, models, UI, tests against fakes) and wire
     the config when it arrives.
   - Secrets go to `app/.env` (gitignored) or `--dart-define` - never committed,
     never echoed back in chat. If the user pasted a secret, move it to the file and
     don't repeat it.
5. Gates (`analyze`, `doctor`, build) - a feature failing gates is not done. A
   feature that stood up a backend is not done either until account ownership is
   decided AND logged (`decision{area:"backend-account"}`) - an account nobody chose
   is how a project quietly ends up outside Utopia.
6. Visual checkpoint if enabled: run web preview, ask verdict (dobrze / zmień /
   odrzuć). Log `checkpoint`; rework counts.
   **User-reported corrections ALWAYS log** `checkpoint{feature, verdict:"change",
   rework:n}` - also when visual checkpoints are off; a fix with no analytics trace
   is a data bug. After any visual fix, hot-restart the running preview and, when
   the user self-previews, tell them to hard-refresh (Cmd+Shift+R / Ctrl+F5) -
   Flutter web caches aggressively and they may be staring at the old bundle.
7. Append `zero/DECISIONS.md` (EN); update STATE; commit + push; log `feature_done`.
8. Every ~3 features: pulse survey (2 clickables). Log `survey`.

Out-of-BRIEF requests at any point: do it if feasible (log
`scope_request{handled:"done"}`), otherwise explain kindly, park it in BRIEF "Później"
(log `scope_request{handled:"declined_logged"}`).

**Parallel agents / worktrees** (Pro and Utopia modes only): allowed for
independent features, with duties - log `decision{area:"parallelism",
choice:"<n> agents", rationale, user_involved:false}` once per burst, add
`parallel_agents:n` to the affected `feature_start`/`feature_done`, and know that
per-feature timing for that burst is lost to the analysis. Every merged
`worktree-agent-*` / scratch branch is deleted at the latest in stage 6
(dry-run #2 left six and lost the repo-hygiene point for it).

**MVP close is a ceremony, not a vibe.** When the BRIEF's MVP list is done (or the
user says "wystarczy na MVP"): log `stage_end{duration_hint, note:"MVP closed"}`,
update STATE ("MVP zamknięte <date>"), and ask the user what's next (clickable):
finish & hand over (→ stage 6) / keep building (→ **Polish mode**). Choosing to
keep building switches the mode in STATE, logs `decision{area:"mode",
choice:"polish"}`, and the loop continues with all the same duties - post-MVP work
must not float outside any stage (dry-run #2: 60% of all work happened in an
unmarked afterlife of stage 4).

**Exit (to stage 6):** all MVP features done, or the user says "wystarczy na MVP".

## Stage 5 - Devices (optional, on demand)

Load the OS environment playbook + `failure-playbooks.md`. Trigger: the user asks
("na telefonie?") or picks it after stage 4.

Offer the ladder top-down, cheapest first - each rung is a full success:

1. **Phone browser, zero installs**: `flutter run -d web-server --web-hostname 0.0.0.0
   --web-port 7357 --release`, user opens `http://<computer-LAN-IP>:7357` on the
   phone (same Wi-Fi). Works on iPhone even from Windows. `--release` is not
   optional here: the phone is a SECOND viewer, and a debug web-server hands its
   single dwds connection to whoever asks first, so the phone gets a blank page
   while your laptop tab looks fine.
2. **Android emulator / iOS simulator**: heavy toolchain install per playbook
   (Android Studio + SDK / full Xcode - honest multi-GB, ~1 h warnings).
3. **Physical install**: Android - developer mode + USB debugging, guided tap by tap;
   iOS (macOS only) - full Xcode + free provisioning with the **user personally**
   signing into Xcode with their Apple ID (guide clicks; explain the 7-day expiry
   honestly). Windows + iPhone → rung 1 is the answer; say it plainly.

Log `build{target}` per attempt; failures follow the 5-strategy ladder, plan B =
previous rung. `stage_end` when the user is satisfied with any rung.

## Stage 6 - Handover

Load `handover.md`. **Entry:** MVP loop closed.

1. Polish pass: app name + icon (flutter_launcher_icons), empty/error/loading states
   on every screen, final visual sweep against the design tokens + a contrast audit
   (≥ 4.5:1) of every screen.
2. Final gates: `flutter analyze`, `utopia doctor`, `flutter build web` release.
2a. **Platform reality check**: every platform the app declares (android/ios/web
   folders present) has been LAUNCHED at least once during the project - a build
   alone does not count (dry-run #2 handed over an Android that had never run).
   Can't launch one here (no emulator, no device)? Don't fake it: name it in
   HANDOVER "Known limitations" in the first three bullets, with an effort
   estimate for the takeover team.
2b. **Branch hygiene**: delete every fully-merged work branch (worktree-agent-*,
   scratch, design experiments the user does not want as history); what stays,
   stays by the user's explicit word, recorded in HANDOVER.
3. Fill `zero/HANDOVER.md` from the template (EN). Self-score the rubric; fix every
   cheap gap (<30 min each); rescore. Log `handover_selfscore{scores}`.
4. Tag: `git tag poc-v1 && git push origin poc-v1`.
5. **Final survey** (5 × 1–5 clickable + one open "co byś zmienił/a w tym procesie?"):
   control · clarity · frustration at stuck moments · result-vs-vision · would
   recommend. Log `survey{stage:6}`.
6. What's next (user's language): Utopia can take it over (contact from config), or
   we keep going - say "dodajemy funkcję X" any time (Polish mode). `stage_end`.

**Exit:** HANDOVER.md complete · rubric ≥ 14/20 or gaps explained inside it ·
`poc-v1` pushed · survey logged.
