# Environment playbook - macOS

Lazy toolchain: install only what the current goal needs. Web goal (stages 2–4):
Command Line Tools (git) + Flutter SDK. Browser: the system default (Safari is fine -
preview uses `flutter run -d web-server`; Chrome is NOT required). Heavy toolchains
(Xcode, Android Studio) belong to stage 5 only.

## Detect first (all silent, log `env`)

```bash
sw_vers -productVersion          # macOS version
uname -m                         # arm64 | x86_64
df -g / | tail -1 | awk '{print $4}'   # free GB
xcode-select -p 2>/dev/null      # CLT installed?
git --version 2>/dev/null
flutter --version 2>/dev/null; which flutter
utopia --help >/dev/null 2>&1 && echo utopia-ok
```

Free disk < 10 GB → stop and help the user free space BEFORE any download
(biggest offenders: ~/Downloads, old iOS backups, Trash). Stage 5 with full Xcode
needs ~40 GB free - check again there.

## Command Line Tools (gives git)

`xcode-select --install` opens a **system dialog** - tell the user exactly what
they'll see and to click "Install" ("wyskoczy okienko systemowe - kliknij
Zainstaluj; to potrwa kilka minut"). Then poll until ready:

```bash
until xcode-select -p >/dev/null 2>&1; do sleep 20; done
```

Already installed → skip silently.

## Flutter SDK

1. Pick the stable channel zip for the detected arch from
   `https://docs.flutter.dev/release/archive` (stable, macOS, arm64 or x64) -
   resolve the latest stable URL at runtime (the JSON index at
   `https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json`
   lists it; field `current_release.stable` → matching archive).
2. Download + unpack (~15 min on average links - warn the user):
   ```bash
   mkdir -p ~/development && cd ~/development
   curl -L -o flutter.zip "<archive-url>"
   unzip -q flutter.zip && rm flutter.zip
   ```
3. PATH - both for future shells and the current session:
   ```bash
   grep -q 'development/flutter/bin' ~/.zprofile 2>/dev/null || \
     echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zprofile
   export PATH="$HOME/development/flutter/bin:$PATH"
   ```
4. Warm-up + verify: `flutter --version` (first run sets up the Dart SDK),
   then `flutter doctor` - **filtered to the web goal**: `[✓] Flutter` is all that
   matters now; Android/Xcode complaints are EXPECTED and not errors. Never show the
   raw doctor output to a Zero-mode user.

## utopia_cli

```bash
dart pub global activate utopia_cli
grep -q '.pub-cache/bin' ~/.zprofile 2>/dev/null || \
  echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' >> ~/.zprofile
export PATH="$HOME/.pub-cache/bin:$PATH"
utopia --help >/dev/null && echo ok
```

## Web preview (default run mode)

```bash
cd app && flutter run -d web-server --web-port 7357   # keep running (background)
open http://localhost:7357                             # default browser
```

Phone preview without any toolchain: add `--web-hostname 0.0.0.0`, find the LAN IP
(`ipconfig getifaddr en0`), user opens `http://<ip>:7357` on the phone (same Wi-Fi).

## Stage 5 extras (only on demand)

- **Android**: `brew` is NOT assumed - download Android Studio dmg, guide the user
  through the drag-to-Applications and first-run SDK wizard click by click; then
  `flutter doctor --android-licenses` (answer `y`). Emulator via Device Manager.
- **iOS**: full Xcode from the App Store (say honestly: tens of GB, ~1 h). The user
  personally signs into Xcode with their Apple ID (Settings → Accounts) - guide
  clicks, never touch credentials. Free provisioning re-signs every 7 days - explain
  before they choose this rung. Then `cd app && flutter run -d <device>` with the
  phone unlocked + trusted.

Every step here is idempotent: check-before-install, and a re-run after a failed
download just resumes.
