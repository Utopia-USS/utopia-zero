# Building on utopia_ui (stages 2–4)

The app's visual layer is the `utopia_ui` design system: the tokens accepted in the
Pracownia become `theme.dart`, screens compose from `Utopia*` widgets plus a small
app-local kit. This is what makes POCs look professional AND hand-over cleanly.

## Dependency ladder (stage 2, right after `utopia create`)

Try in order; log a `decision{area:"ui-dependency"}` with the rung you landed on:

1. **pub.dev**: `flutter pub add utopia_ui` - if the package is published (as of
   2026-08 it is not yet; check before skipping).
2. **git** (the DEFAULT - the repo is public): in `pubspec.yaml`:
   ```yaml
   utopia_ui:
     git: {url: https://github.com/Utopia-USS/utopia-ui.git}
   ```
   Tracks main; pin with `ref:` to a tag when tags exist. Needs network only at
   `pub get` time.
3. **Vendored copy** (offline fallback): if `packages/utopia_ui/` exists in the
   project root (older prepared repos), use it:
   ```yaml
   utopia_ui:
     path: ../packages/utopia_ui
   ```
   Frozen snapshot (source commit in `packages/utopia_ui/VENDORED.md`). Prefer
   swapping to the git dependency when online; note the choice in HANDOVER.
4. **Fallback (nothing above works)**: build WITHOUT the package - Material 3 styled
   from the same token values (seed = `--u-color-primary`, dark scheme from canvas,
   Google Font, radii). The mock contract still holds; note the fallback in
   `zero/DECISIONS.md` so the takeover team can swap the dependency in later.

`utopia_ui` requires Dart SDK ^3.11 / Flutter 3.44+ and pulls `utopia_hooks` -
same stack the scaffold already uses.

## Wiring (once, stage 2)

0. **Design protocol IS the path** (proven in the field on the Paplanina
   migration): the `utopia-design` plugin is enabled in prepared repos - use it.
   Flow: `tokens` skill bootstraps `design/tokens.json` from the package
   default → override the branded slots from the Pracownia →
   `flutter pub add --dev utopia_design_tools` → `sync` regenerates the theme
   (`validate_tokens` → `validate_manifest` → `generate_theme`, freshness
   proved with `generate_theme --check`). Never hand-edit generated Dart.
   NOTE: the token document is SINGLE-context in protocol v0 - one palette;
   the mode was chosen in the design interview (a second mode is out of scope
   until the protocol grows modes). The manual emission below is ONLY for
   offline machines or stale vendored snapshots without the protocol.
1. **`lib/app/theme.dart`** (manual fallback) - emit from the accepted tokens,
   using `tokens/utopia.tokens.json` as the authoritative default-theme export
   (override only the branded slots). The emitted Dart takes this exact shape
   (mirrors the package's own showcase themes):
   ```dart
   import 'package:flutter/material.dart';
   import 'package:google_fonts/google_fonts.dart';
   import 'package:utopia_ui/utopia_ui.dart';

   final appUtopiaTheme = UtopiaThemeData.fromTokens(
     colors: const UtopiaThemeColors(
       primary: Color(0xFFB3418E),      // --u-color-primary
       accent: Color(0xFFE36BB4),       // --u-color-accent
       canvas: Color(0xFF141018),       // --u-color-canvas
       field: Color(0xFF2A2233),        // --u-color-field
       text: Color(0xFFF4EFF7),         // --u-color-text
       error: Color(0xFFFF5A6E),
       disabled: Color(0xFF5C5266),
       onColoredContent: Colors.white,
       onColoredSelected: Colors.white,
       onColoredHover: Colors.white70,
       surface: Color(0xFF1E1824),      // --u-color-surface
       border: Color(0xFF3A3144),
       hint: Color(0xFF9A8FA6),
       chipBackground: Color(0xFF3A2440),
       chipForeground: Color(0xFFE36BB4),
     ),
     textStyles: UtopiaThemeTextStyles(   // 6 roles ← --u-type-*
       header: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFFF4EFF7)),
       title:  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFF4EFF7)),
       text:   GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFF4EFF7)),
       label:  GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF4EFF7)),
       caption:GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF9A8FA6)),
       button: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
     ),
     tokens: UtopiaTokens.fromBase(4),    // --u-x
   );
   ```
2. **Root wiring**: wrap the app in `UtopiaTheme(data: appUtopiaTheme, child: …)`.
3. **Material mirror** (until the package ships a bridge): give `MaterialApp` a
   `ThemeData` derived from the SAME values - `ColorScheme.fromSeed(seedColor:
   primary, brightness: …)`, `scaffoldBackgroundColor: canvas`, the same text theme -
   so Material internals (snackbars, pickers, scrollbars) don't clash. Read widgets
   through `context.colors` / `context.tokens` extensions; **never** hardcode a
   colour/gap/radius in a screen.

## What to use for what

| Need | Use |
|---|---|
| primary action | `UtopiaButton` (hero component; `loading:`, `dense:` built in; resting height 48px) |
| secondary/ghost action | `UtopiaGhostButton` |
| text input / search / dropdown / date | `UtopiaTextField`, `UtopiaSearchField`, `UtopiaDropdownField<T>`, `UtopiaDatePicker` (48px controls, themed states) |
| confirm / form dialog | `UtopiaConfirmDialog.show(danger:)`, `UtopiaDialog.form` - **adaptive**: real bottom-sheet on mobile widths |
| tags / status | `UtopiaChip`, `UtopiaChipList` |
| container / layout | `UtopiaCard` (child-only - pad inside yourself), `UtopiaPageWrapper`, `UtopiaGradientBackground`, `UtopiaDivider` |
| headings | `UtopiaHeader`, `UtopiaTitle` |
| loading / skeleton | `UtopiaLoader`, `UtopiaLoadingBox`, `UtopiaThreeBounce` |
| empty state | `UtopiaTableEmpty` (generic despite the name: icon/title/subtitle/actions) |
| toggles / selection | `UtopiaSwitchField`, `UtopiaCheckRow`, `UtopiaCheckbox`, `UtopiaRadio`, `UtopiaSlider` |

Metrics worth knowing (palette v2, protocol era): controls are 48px tall, the
radius ladder is chip (6) < controls (12) < cards/dialogs (16) - override via
tokens if the accepted mock says otherwise, don't fight it per-widget.

Import ONLY the barrel (`package:utopia_ui/utopia_ui.dart`). Do not reference
unexported internals; `UtopiaButtonVariant` does not exist (charter naming example).

## App-local kit (`lib/common/widget/`)

**Gap discipline first (field-proven on Paplanina):** an element no manifest
component covers is a GAP - never a silent hand-roll. Report it in the `screen`
skill's 5-part format (element / rejected candidate ids + why / missing
capability / suggested action / component-spec seed), then either scaffold it
as a PROJECT component via the `component` skill (overlay YAML in
`design/overlay/`, regenerated manifests, namespaced `app:*` id) or file it
upstream (utopia-ui issue; check #2 "Mobile app kit" for duplicates first).
Every participant POC thus feeds the utopia-ui backlog instead of hiding gaps.

**A participant cannot open an issue on utopia-ui** - their PAT reaches their own
repo and nothing else. So in a zero project "file it upstream" means: open a
`[zero] ui-gap: <component> - <one-line symptom>` issue in THIS repo (the
escalation channel Utopia already watches, per `escalation.md`), with the 5-part
report in the body, and log `error{category:"ui-gap", found_by}`. The event alone
is not filing - pilot #1 logged a real `UtopiaTextField` defect (ignores external
value changes after mount, so the field never clears after submit) that reached
nobody, because a JSONL line in a participant repo is data, not a report.

Known consumer-mobile gaps you will likely hit (build as project components,
token-driven - `context.colors` / `context.tokens`, zero literals):

- `AppListTile` - leading/title/subtitle/trailing, `tileHeight` from theme
  (`UtopiaTable` is a back-office grid; wrong for app lists).
- `AppBottomNav` / tabs - `UtopiaSidebar` is desktop rail/drawer only.
- `AppPageHeader` - app-bar row with back/action (`UtopiaHeader`/`UtopiaTitle`
  are typography, not an app bar - compose them inside).
- Avatar/badge/progress only if the BRIEF needs them.

The Paplanina migration produced five such project components
(`app:brand-backdrop`, `app:category-card`, `app:category-chip`,
`app:question-card`, `app:question-tile`) - use them as reference
implementations of the pattern.

**Before hand-rolling, check whether the package caught up**: Utopia is filling
these gaps (utopia-ui issue #2) - inspect the barrel / CHANGELOG of the version you
resolved; use the real component when it exists.

## Gates addition

Stage 2–4 checkpoints compare the running app against the accepted Pracownia mocks
(`zero/design/`). A screen that has a mock must match its layout, palette, and type
scale; deviations the user asks for later are fine - log `user_override` and note
them in `zero/DECISIONS.md` (don't back-port to the mock files).
