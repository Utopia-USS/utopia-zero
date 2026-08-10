# Design workshop — „Pracownia" (second half of stage 1)

Lock the app's look on **cheap HTML mocks before any Flutter code exists**. The mocks
speak the same token vocabulary as `utopia_ui`, so an accepted mock translates
faithfully into `theme.dart` + real widgets (see `utopia-ui-build.md`). Visual rework
moves from expensive Flutter code to a file the user refreshes in their browser.

Zero-mode language: „przymiarka wyglądu" / „makieta", never "mock".

## When, inputs, outputs

Runs right after the design interview, **before** BRIEF approval.

- Input: interview answers → token draft (mapping tables in `design-interview.md`).
- Output: `zero/design/tokens.css` + 2–3 **accepted** `zero/design/mock-<screen>.html`,
  committed; BRIEF's design section records the final tokens and lists the mocks.
- The accepted mocks are the visual contract for stages 2–4 (checkpoints compare the
  app against them). They are stage-1 artifacts — do NOT maintain them afterwards;
  later deviations are logged in `zero/DECISIONS.md`, not back-ported to HTML.

## Flow

1. Derive the full token set (vocabulary table below) from the interview.
2. Pick **2–3 screens** from the MVP list: the **hero screen** (where the user's
   "success answer" happens), the most-used flow screen, and — if the brand carries
   it — the welcome screen. Never more than 3.
3. Generate each mock from the template below: **one self-contained HTML file**
   (vars inlined in `<style>` — must open via `file://`, no server), phone frame.
4. Self-check before showing: contrast ≥ 4.5:1 on every text/background pair
   (compute it), no raw emoji as ornaments, only components the build can honor
   (check the gaps list in `utopia-ui-build.md` — don't mock what can't be built).
5. Show one at a time: `open zero/design/mock-<name>.html` (macOS) /
   `Start-Process zero\design\mock-<name>.html` (Windows). Ask the verdict
   (clickable: „Podoba mi się!" / „Zmieńmy coś" → open feedback).
6. Iterate by editing vars/markup; user refreshes the tab. Log
   `checkpoint{feature:"mock-<name>", verdict, rework:n}` on EVERY round.
7. All accepted → log `decision{area:"design-tokens", choice:"<one-line summary>",
   user_involved:true}`, commit `zero/design/`, fold tokens + mock list into BRIEF.

## Protocol twin first (when the package ships it)

If the resolved/vendored `utopia_ui` contains `twin/` + `tokens/` (the design
protocol), do **not** hand-roll the vocabulary below — use the package's own,
version-matched artifacts:

- `twin/tokens.css` — the canonical CSS variable sheet (names AND default values);
  inline it into the mock's `<style>` and override the branded variables after it.
- `twin/components.css` + `twin/components.html` — faithful component twins;
  compose mocks from these classes instead of the approximations below.
- `twin/gallery.html` — everything at once; handy as the user's first look.
- `tokens/utopia.tokens.json` (DTCG) — the machine-readable source when emitting
  `theme.dart` (override the branded slots, keep the rest).

The template below is the FALLBACK for packages without the protocol.

## Token vocabulary (CSS custom property ↔ utopia_ui)

Use exactly these names — they mirror the canonical identifiers `utopia_ui` declares
for external tools. Values in the mocks MUST be the ones you will emit in `theme.dart`.

| CSS var | utopia_ui slot |
|---|---|
| `--u-color-primary` / `--u-color-accent` | `UtopiaThemeColors.primary` / `.accent` |
| `--u-color-canvas` / `--u-color-surface` | `.canvas` / `.surface` |
| `--u-color-field` / `--u-color-border` / `--u-color-hint` | `.field` / `.border` / `.hint` |
| `--u-color-text` / `--u-color-error` / `--u-color-disabled` | `.text` / `.error` / `.disabled` |
| `--u-color-on-colored` (+`-selected`, `-hover`) | `.onColoredContent` (+ variants) |
| `--u-color-chip-bg` / `--u-color-chip-fg` | `.chipBackground` / `.chipForeground` |
| `--u-font-family` | `UtopiaThemeTextStyles` font (Google Fonts name) |
| `--u-type-header` … `--u-type-caption` (size/weight pairs) | the 6 roles: `header, title, text, label, caption, button` |
| `--u-space-{xs,sm,md,lg,xl,xxl}` | `UtopiaTokens.spacing.*` (from base `x`) |
| `--u-radius-{sm,md,lg,xl}` | `UtopiaTokens.radius.*` |
| `--u-x` | token base (`UtopiaTokens.fromBase`) |

## Mock template (start every mock from this)

```html
<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Przymiarka — NAZWA_EKRANU</title>
<style>
:root{
  --u-x:4px;
  --u-color-primary:#B3418E; --u-color-accent:#E36BB4;
  --u-color-canvas:#141018; --u-color-surface:#1E1824;
  --u-color-field:#2A2233; --u-color-border:#3A3144; --u-color-hint:#9A8FA6;
  --u-color-text:#F4EFF7; --u-color-error:#FF5A6E; --u-color-disabled:#5C5266;
  --u-color-on-colored:#FFFFFF; --u-color-chip-bg:#3A2440; --u-color-chip-fg:#E36BB4;
  --u-font-family:'Nunito',system-ui,sans-serif;
  --u-space-sm:8px; --u-space-md:12px; --u-space-lg:16px; --u-space-xl:24px;
  --u-radius-md:8px; --u-radius-lg:12px; --u-radius-xl:16px; --u-radius-full:9999px;
}
*{box-sizing:border-box;margin:0} body{background:#000;display:flex;justify-content:center;padding:24px;font-family:var(--u-font-family)}
.phone{width:390px;min-height:780px;background:var(--u-color-canvas);color:var(--u-color-text);
  border-radius:40px;padding:var(--u-space-xl) var(--u-space-lg);display:flex;flex-direction:column;gap:var(--u-space-lg)}
.appbar{display:flex;align-items:center;justify-content:space-between;font-weight:700;font-size:16px}
.card{background:var(--u-color-surface);border-radius:var(--u-radius-xl);padding:var(--u-space-lg)}
.btn{display:block;width:100%;padding:18px;border:0;border-radius:var(--u-radius-full);
  background:var(--u-color-primary);color:var(--u-color-on-colored);font:700 16px var(--u-font-family);text-align:center}
.btn-ghost{background:transparent;color:var(--u-color-text);border:1.5px solid var(--u-color-border)}
.field{background:var(--u-color-field);border:1px solid var(--u-color-border);border-radius:var(--u-radius-md);
  padding:14px var(--u-space-lg);color:var(--u-color-hint)}
.chip{display:inline-block;background:var(--u-color-chip-bg);color:var(--u-color-chip-fg);
  border-radius:var(--u-radius-full);padding:6px 14px;font-size:12px;font-weight:600}
.tile{display:flex;align-items:center;gap:var(--u-space-md);background:var(--u-color-surface);
  border-radius:var(--u-radius-lg);padding:var(--u-space-md) var(--u-space-lg)}
.bottomnav{margin-top:auto;display:flex;justify-content:space-around;background:var(--u-color-surface);
  border-radius:var(--u-radius-xl);padding:var(--u-space-md)}
</style>
<div class="phone">
  <!-- compose the screen here from .appbar/.card/.btn/.field/.chip/.tile/.bottomnav -->
</div>
```

Load the brand's Google Font with a `<link>` when online; the system fallback keeps
`file://` mocks working offline.

## Rules

- The mock is a **promise the build must keep** — style only with the vars, compose
  only from patterns `utopia_ui` + the app-local kit can deliver.
- One screen per file; no JS beyond trivial show/hide if a state matters.
- Density/mood changes = edit vars first (that's the point of tokens); layout changes
  second.
- If the user says „nie umiem ocenić na płasko, chcę zobaczyć w telefonie" — mocks
  can be served over LAN exactly like the app preview (`python3 -m http.server` /
  any static trick) — but offer it only if asked.
