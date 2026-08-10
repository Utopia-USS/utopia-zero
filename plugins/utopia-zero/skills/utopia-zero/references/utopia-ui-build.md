# Building on utopia_ui (stages 2–4)

The app's visual layer is the `utopia_ui` design system: the tokens accepted in the
Pracownia become `theme.dart`, screens compose from `Utopia*` widgets plus a small
app-local kit. This is what makes POCs look professional AND hand-over cleanly.

## Dependency ladder (stage 2, right after `utopia create`)

Try in order; log a `decision{area:"ui-dependency"}` with the rung you landed on:

1. **pub.dev**: `flutter pub add utopia_ui` — if the package is published.
2. **git**: in `pubspec.yaml`:
   ```yaml
   utopia_ui:
     git: {url: https://github.com/Utopia-USS/utopia-ui.git}
   ```
   Works once the repo is public. Pin with `ref:` to a tag when tags exist.
3. **Fallback (repo unreachable)**: build WITHOUT the package — Material 3 styled
   from the same token values (seed = `--u-color-primary`, dark scheme from canvas,
   Google Font, radii). The mock contract still holds; note the fallback in
   `zero/DECISIONS.md` so the takeover team can swap the dependency in later.

`utopia_ui` requires Dart SDK ^3.11 (fine on current stable) and pulls
`utopia_hooks` — same stack the scaffold already uses.

## Wiring (once, stage 2)

1. **`lib/app/theme.dart`** — emit from the accepted tokens, in this exact shape
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
   `ThemeData` derived from the SAME values — `ColorScheme.fromSeed(seedColor:
   primary, brightness: …)`, `scaffoldBackgroundColor: canvas`, the same text theme —
   so Material internals (snackbars, pickers, scrollbars) don't clash. Read widgets
   through `context.colors` / `context.tokens` extensions; **never** hardcode a
   colour/gap/radius in a screen.

## What to use for what

| Need | Use |
|---|---|
| primary action | `UtopiaButton` (hero component; `loading:`, `dense:` built in) |
| secondary/ghost action | app-local `AppGhostButton` (see kit below) |
| text input / search / dropdown / date | `UtopiaTextField`, `UtopiaSearchField`, `UtopiaDropdownField<T>`, `UtopiaDatePicker` |
| confirm / form dialog | `UtopiaConfirmDialog.show(danger:)`, `UtopiaDialog.form` — **adaptive**: real bottom-sheet on mobile widths |
| tags / status | `UtopiaChip`, `UtopiaChipList` |
| container | `UtopiaCard` (child-only — pad inside yourself) |
| loading / skeleton | `UtopiaLoader`, `UtopiaMockLoadingBox`, `UtopiaThreeBounce` |
| empty state | `UtopiaTableEmpty` (generic despite the name: icon/title/subtitle/actions) |
| toggles | `UtopiaSwitchField`, `UtopiaCheckRow` |

Import ONLY the barrel (`package:utopia_ui/utopia_ui.dart`). Do not reference
unexported internals; `UtopiaButtonVariant` does not exist (charter naming example).

## App-local kit (`lib/common/widget/`)

`utopia_ui` v0.1 has no consumer-mobile idiom for these — build them ONCE per app,
token-driven (`context.colors`, `context.tokens`), zero literals:

- `AppListTile` — leading/title/subtitle/trailing, `tileHeight` from theme
  (`UtopiaTable` is a back-office grid; wrong for app lists).
- `AppBottomNav` / tabs — `UtopiaSidebar` is desktop rail/drawer only.
- `AppPageHeader` — title + optional back/action (no app bar in the package).
- `AppGhostButton` — port the private `_GhostButton` pattern from the package's
  confirm dialog (outlined, token-styled).
- Avatar/badge/progress only if the BRIEF needs them.

**Before hand-rolling, check whether the package caught up**: Utopia is filling
these gaps (utopia-ui issue #2) — inspect the barrel / CHANGELOG of the version you
resolved; use the real component when it exists.

## Gates addition

Stage 2–4 checkpoints compare the running app against the accepted Pracownia mocks
(`zero/design/`). A screen that has a mock must match its layout, palette, and type
scale; deviations the user asks for later are fine — log `user_override` and note
them in `zero/DECISIONS.md` (don't back-port to the mock files).
