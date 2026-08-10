# Stage scripts (0–6)

Shared rules for every stage:

- **Idempotent**: before each action, check whether it already happened (file exists,
  tool responds, STATE says done). Re-running a stage never breaks anything.
- **Events**: log `stage_start` when entering (and write the stage number to
  `zero/analytics/.stage`), `stage_end` when the exit criteria pass. Log the
  per-action events named below.
- **STATE**: update `zero/STATE.md` at stage end AND after any step whose loss would
  hurt (mid-stage progress, pending restart, awaited user input).
- Time estimates before anything slow; big-download warnings ("~20 min — zostaw
  komputer włączony, nie zamykaj aplikacji").
- **Commit by explicit paths** (`git add app/ zero/ .claude/…`), never a blanket
  `git add -A` — operator/IDE artifacts (`.idea/`, `.vscode/`) must not enter the
  repo even if the ignores miss them.

## Stage 0 — Start & tutorial

**Entry:** fresh project, or STATE stage 0 (possibly mid-flight, e.g. "restart pending").

> **Virgin-machine note:** on a fresh macOS, `git` arrives only with the Command Line
> Tools (stage 2); on fresh Windows, with Git for Windows (stage 2). If `git
> --version` fails now, DEFER the git-dependent parts of steps 6–8 (identity, remote,
> push, commit): record "deferred: git steps" in STATE and complete them in stage 2
> immediately after the toolchain lands. Everything else in stage 0 proceeds.

1. Read `zero/config.json`. Detect OS + basics; log `env{os, arch, disk_free_gb, git, flutter}`.
2. **Mode** (clickable): "Czy kiedykolwiek programowałeś/aś?" → never / trochę / jestem
   programistą (→ Pro). Log `question`/`answer`, and `tutorial{skipped:true}` for Pro.
   (The hidden Utopia mode — passphrase "jestem z utopii" — is recognized at ANY
   moment, per SKILL.md; it is never one of the offered options.)
3. **Analytics info** (both modes, plain words): what is collected (steps, decisions,
   errors, time, conversation copies), why (Utopia studies how well this works), where
   it lives (their project repo, visible to Utopia), and that "wyłącz analitykę"
   works at any time. Log `consent{analytics, transcripts}`.
4. **Tutorial** (Zero mode only, ~6 short paragraphs, user's language): how this chat
   works; stages 0–6 overview; nothing is ever lost ("wysyłam kopie do sejfu");
   how to come back ("otwórz projekt i napisz: kontynuuj"); dictation is welcome —
   talk as long as you like; auto-accept: where the AUTO/permissions toggle lives, and
   the symptom of it being off (constant "Allow?" popups → tell me and I'll guide you).
5. **Model advice** per `model-advice.md`; log `model_info`.
   *After each of steps 2–5, update `zero/STATE.md` immediately (mode, consent,
   model) — a session dying mid-stage-0 must not lose these answers.*
6. **Git identity** (silent): `git config user.name "<participant_id>"`,
   `git config user.email "<participant_id>@zero.utopiasoft.io"` (repo-local).
7. **Remote + PAT** (silent): if `zero/.pat` exists, set
   `git remote set-url origin https://x-access-token:<PAT>@<host>/<owner>/<repo>.git`
   (values from config `git_remote`); verify `git ls-remote origin` quietly; push
   current branch. No `.pat`? Try the EXISTING remote as-is first (`git ls-remote`,
   then push) — operator and self-serve machines often authenticate via their own
   SSH keys or credential helper. Only when nothing authenticates → continue
   local-only, note it in STATE, and plan a "skontaktuj się z Utopią" step
   (config `utopia_contact`).
8. **Wire analytics hooks** for this OS into `.claude/settings.json` (exact JSON in
   `analytics.md`), commit. Then the **one planned restart**: ask the user to fully
   quit and reopen the app, open the project again, and write "kontynuuj". Write
   `STATE: restart pending` first so the resume path knows to verify hooks
   (`zero/analytics/events.jsonl` gains a `session_start` line) and move on.
9. **Verify plugins**: the starter's `.claude/settings.json` declares both
   marketplaces and the plugin set (utopia-zero + utopia-hooks, utopia-ai-arch,
   utopia-dart-lsp, utopia-cms, utopia-reviews). Check they're active (skills
   available). If not: try `claude plugin install <name>@<marketplace>` via Bash;
   if the CLI refuses, give the user the exact `/plugin install …` lines to paste
   (one by one, in order) and wait.
10. `stage_end`; STATE → stage 1 with a one-line teaser of what's next.

**Exit:** consent logged · hooks confirmed live · push worked (or degraded-local noted) · plugins active.

## Stage 1 — Idea & look

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
   checkpoints off — this is the visual contract for the whole build).
6. Write `zero/BRIEF.md` (user's language; structure in `interview-guide.md`,
   design section records tokens + mock list), read back a 5-line summary, get
   approval. Log `checkpoint{feature:"brief"}`.
7. Commit + push (including `zero/design/`); `stage_end`.

**Exit:** BRIEF.md approved and pushed · 2–3 mocks accepted in `zero/design/`.

## Stage 2 — Foundations

Load `environment-macos.md` or `environment-windows.md` + `utopia-ui-build.md`.
**Entry:** BRIEF + mocks approved.

1. Environment for the **web goal only**: git + Flutter SDK + a system browser
   (no Chrome requirement — preview uses `flutter run -d web-server` and the default
   browser). Follow the OS playbook; log `env` again after installs.
2. `dart pub global activate utopia_cli`; verify `utopia` on PATH (playbook).
3. Create the app: `utopia create flutter_app app --org <config.org>` (check
   `utopia create --help` first and adapt; target directory `app/`). If `utopia
   create` fails twice, fall back to `flutter create` + manual `utopia_hooks` wiring
   per the utopia-hooks skill, and log `error` + `fix_attempt`.
   Then run the scaffold's code generation BEFORE any gate:
   `dart run build_runner build --delete-conflicting-outputs` — the fresh scaffold
   is not analyzer-clean until this runs (undefined localization classes are
   expected before it). A couple of info-level lints may remain in template files —
   fix them immediately so the analyze gate stays at literally zero issues.
4. **Visual layer** (`utopia-ui-build.md`): add `utopia_ui` via the dependency
   ladder (pub.dev → git → tokenized-Material fallback; log the rung), emit
   `lib/app/theme.dart` from the accepted Pracownia tokens, wire `UtopiaTheme` at
   the root + the Material mirror. Log `decision{area:"ui-dependency"}`.
5. Append project facts to `.claude/CLAUDE.md`: app name, user language, BRIEF path,
   `zero/design/` as the visual contract, "run: cd app && flutter run -d web-server".
6. **Welcome screen**: replace the default home with a branded one — it must MATCH
   the accepted welcome mock (or, when no welcome mock exists, the tokens + patterns
   of the accepted mocks). Self-check the a11y floor from `design-interview.md`
   (text contrast ≥ 4.5:1 on every element, icons/assets instead of raw emoji).
6. Run it: `flutter run -d web-server --web-port 7357` (background), open
   `http://localhost:7357` in the default browser for the user. Ask what they see
   (clickable: "Widzę ekran powitalny!" / "Nic się nie otworzyło"). Log
   `build{target:"web"}` + `checkpoint{feature:"welcome"}`.
7. Gates: `flutter analyze` + `utopia doctor` (from `app/`). Fix until clean.
8. Ask the **visual checkpoint preference** (once): after each feature — show the app
   / don't show / "sam odpalam na telefonie". Save to STATE; log `decision`.
9. Commit + push. **Pulse survey #1** (two 1–5 clickables: "Czy czujesz, że masz
   kontrolę nad tym, co powstaje?", "Na ile jasne jest to, co się teraz dzieje?").
   Log `survey{stage:2}`. `stage_end`.

**Exit:** welcome screen seen by the user in a browser · gates clean · pushed.

## Stage 3 — Skeleton

**Entry:** stage 2 done. The utopia-hooks skill governs all code.

1. From BRIEF's MVP list derive the screen map (you decide navigation/structure).
2. Build every MVP screen as Screen/State/View skeleton with believable fake data
   (const lists, lorem-free, in the user's language) and wired navigation. Screens
   that have a Pracownia mock follow its layout; the rest reuse the same tokens and
   the app-local kit (`utopia-ui-build.md`).
3. Run + **mandatory checkpoint** (even if checkpoints are off — this is the app map):
   "Przeklikaj się przez aplikację — to jej mapa. Zgadza się z Twoją wizją?"
   Log `checkpoint{feature:"skeleton", verdict, rework}`; iterate on "change".
4. Gates clean; commit + push; `stage_end`.

**Exit:** user approved the clickable skeleton.

## Stage 4 — Features (the loop)

Load `failure-playbooks.md`. **Entry:** skeleton approved. Repeat per feature:

1. Pick next feature: recommend one (dependency-first), user confirms or picks
   another (clickable list, ≤4 options per question). Log `feature_start`.
2. **Plan**: one paragraph, user's language, no jargon — what will exist when done.
   Approve (clickable: buduj / zmień plan / pomiń). Log `question`/`answer`.
3. Build per utopia-hooks (and utopia-cms for admin surfaces); visuals per
   `utopia-ui-build.md` — `Utopia*` widgets + the app-local kit, tokens only, never
   literals. All technical choices yours; log `decision` (+ rationale +
   alternatives) for each significant one.
4. **Backend, lazily** — first feature that needs it:
   - Choose provider yourself (auth/data/realtime/files needs → Firebase or Supabase).
     Log `decision{area:"backend-provider"}`.
   - v1 accounts come from Utopia: point the user at **their Utopia person** —
     `utopia_contact` in config names the member who prepared this project (the
     participant knows them; never suggest a generic mailbox as the default) —
     with a ready message (what to ask for, what to include); wait, then configure.
     Log `backend_step{delegated:true}`.
   - Secrets go to `app/.env` (gitignored) or `--dart-define` — never committed,
     never echoed back in chat. If the user pasted a secret, move it to the file and
     don't repeat it.
5. Gates (`analyze`, `doctor`, build) — a feature failing gates is not done.
6. Visual checkpoint if enabled: run web preview, ask verdict (dobrze / zmień /
   odrzuć). Log `checkpoint`; rework counts.
   **User-reported corrections ALWAYS log** `checkpoint{feature, verdict:"change",
   rework:n}` — also when visual checkpoints are off; a fix with no analytics trace
   is a data bug. After any visual fix, hot-restart the running preview and, when
   the user self-previews, tell them to hard-refresh (Cmd+Shift+R / Ctrl+F5) —
   Flutter web caches aggressively and they may be staring at the old bundle.
7. Append `zero/DECISIONS.md` (EN); update STATE; commit + push; log `feature_done`.
8. Every ~3 features: pulse survey (2 clickables). Log `survey`.

Out-of-BRIEF requests at any point: do it if feasible (log
`scope_request{handled:"done"}`), otherwise explain kindly, park it in BRIEF "Później"
(log `scope_request{handled:"declined_logged"}`).

**Exit (to stage 6):** all MVP features done, or the user says "wystarczy na MVP".

## Stage 5 — Devices (optional, on demand)

Load the OS environment playbook + `failure-playbooks.md`. Trigger: the user asks
("na telefonie?") or picks it after stage 4.

Offer the ladder top-down, cheapest first — each rung is a full success:

1. **Phone browser, zero installs**: `flutter run -d web-server --web-hostname 0.0.0.0
   --web-port 7357`, user opens `http://<computer-LAN-IP>:7357` on the phone
   (same Wi-Fi). Works on iPhone even from Windows.
2. **Android emulator / iOS simulator**: heavy toolchain install per playbook
   (Android Studio + SDK / full Xcode — honest multi-GB, ~1 h warnings).
3. **Physical install**: Android — developer mode + USB debugging, guided tap by tap;
   iOS (macOS only) — full Xcode + free provisioning with the **user personally**
   signing into Xcode with their Apple ID (guide clicks; explain the 7-day expiry
   honestly). Windows + iPhone → rung 1 is the answer; say it plainly.

Log `build{target}` per attempt; failures follow the 5-strategy ladder, plan B =
previous rung. `stage_end` when the user is satisfied with any rung.

## Stage 6 — Handover

Load `handover.md`. **Entry:** MVP loop closed.

1. Polish pass: app name + icon (flutter_launcher_icons), empty/error/loading states
   on every screen, final visual sweep against the design tokens + a contrast audit
   (≥ 4.5:1) of every screen.
2. Final gates: `flutter analyze`, `utopia doctor`, `flutter build web` release.
3. Fill `zero/HANDOVER.md` from the template (EN). Self-score the rubric; fix every
   cheap gap (<30 min each); rescore. Log `handover_selfscore{scores}`.
4. Tag: `git tag poc-v1 && git push origin poc-v1`.
5. **Final survey** (5 × 1–5 clickable + one open "co byś zmienił/a w tym procesie?"):
   control · clarity · frustration at stuck moments · result-vs-vision · would
   recommend. Log `survey{stage:6}`.
6. What's next (user's language): Utopia can take it over (contact from config), or
   we keep going — say "dodajemy funkcję X" any time (Polish mode). `stage_end`.

**Exit:** HANDOVER.md complete · rubric ≥ 14/20 or gaps explained inside it ·
`poc-v1` pushed · survey logged.
