# Environment playbook - Windows

Lazy toolchain: web goal (stages 2–4) needs Git for Windows + Flutter SDK. Browser:
system default (Edge is preinstalled - preview uses `flutter run -d web-server`;
Chrome NOT required). Android Studio belongs to stage 5. **No iOS on Windows** - when
the topic comes up, say it plainly and offer the phone-browser rung (LAN preview).

On Windows prefer PowerShell for anything you script; the analytics hooks use the
`.ps1` variants. Long dictated paths with spaces → always quote.

## Weak hardware (old CPU, pre-2016 laptops)

Detect via `(Get-CimInstance Win32_Processor).Name` in the same silent pass. On a
weak CPU (old AMD APU / 2-core era) the flow does not change - web-first is built
for this - but expectations do:

- Say ONCE, up front, in plain words: "Ten laptop da rade, ale pierwsze
  uruchomienia potrwaja kilka minut - to normalne, nie przerywaj." Then never
  mention the hardware again (no shaming, no repeated warnings).
- First `flutter pub get` / first build: minutes, not seconds - do not treat as
  hung before ~10 min; Defender scanning new toolchains stacks on top.
- **Never suggest the Android emulator** on such machines (stage 5 included) -
  go straight to the physical-phone rung: LAN preview first, USB device only if
  the user insists. Log `decision{area:"preview-target", choice:"lan"}`.
- Suggest closing heavy apps (browser z 30 kartami) before long builds, once.

## Detect first (silent, log `env`)

```powershell
[System.Environment]::OSVersion.Version.ToString()
$env:PROCESSOR_ARCHITECTURE                    # AMD64 | ARM64
[math]::Round((Get-PSDrive C).Free/1GB)        # free GB
git --version 2>$null
flutter --version 2>$null
winget --version 2>$null
```

Free disk < 10 GB → help the user free space before any download. Stage 5 with
Android Studio needs ~15 GB more.

## Git for Windows

```powershell
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
```

- `winget` missing → guide the user to install "App Installer" from Microsoft Store
  (describe the exact tiles/clicks), then retry.
- **PATH refresh caveat**: the current session won't see `git` yet. Until the app is
  restarted, call it by full path `& "C:\Program Files\Git\cmd\git.exe" …` or prepend
  `$env:Path = "C:\Program Files\Git\cmd;" + $env:Path` per session. The stage-0
  planned restart usually resolves this naturally.

## Flutter SDK

1. Resolve the latest stable Windows zip from
   `https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json`
   (`current_release.stable` → matching archive URL).
2. Download + unpack - use `tar` (ships with Windows 10+, much faster than
   Expand-Archive on big zips):
   ```powershell
   New-Item -ItemType Directory -Force "$env:USERPROFILE\dev" | Out-Null
   curl.exe -L -o "$env:USERPROFILE\dev\flutter.zip" "<archive-url>"
   tar -xf "$env:USERPROFILE\dev\flutter.zip" -C "$env:USERPROFILE\dev"
   Remove-Item "$env:USERPROFILE\dev\flutter.zip"
   ```
3. PATH - **never `setx`** (silent 1024-char truncation). Use:
   ```powershell
   $p = [Environment]::GetEnvironmentVariable("Path","User")
   if ($p -notlike "*dev\flutter\bin*") {
     [Environment]::SetEnvironmentVariable("Path", "$p;$env:USERPROFILE\dev\flutter\bin", "User")
   }
   $env:Path += ";$env:USERPROFILE\dev\flutter\bin"   # current session
   ```
4. Warm-up + verify: `flutter --version`, then `flutter doctor` filtered to the web
   goal (`[✓] Flutter` suffices; Android/Visual Studio complaints are EXPECTED now).
   First builds can be slow - Defender scans new toolchains; that's normal, don't
   fight it (an exclusion needs admin rights; only suggest it if builds stay painful
   and the user is comfortable clicking through Windows Security themselves).

## utopia_cli

```powershell
dart pub global activate utopia_cli
$pub = "$env:LOCALAPPDATA\Pub\Cache\bin"
$p = [Environment]::GetEnvironmentVariable("Path","User")
if ($p -notlike "*Pub\Cache\bin*") { [Environment]::SetEnvironmentVariable("Path", "$p;$pub", "User") }
$env:Path += ";$pub"
utopia --help | Out-Null; echo ok
```

## Web preview (default run mode)

```powershell
cd app; flutter run -d web-server --web-port 7357 --release   # keep running (background)
Start-Process http://localhost:7357                            # default browser (Edge ok)
```

**`--release` for anything the user looks at.** Debug web-server serves through
dwds, which accepts one debug connection - a second or stale tab shows a blank
white page (pilot #1 chased it as a broken app). Debug is fine for your own
single-tab checks; the user's preview is always a release build.

Phone preview, zero installs: add `--web-hostname 0.0.0.0`, LAN IP via
`(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.PrefixOrigin -eq "Dhcp"}).IPAddress`,
phone opens `http://<ip>:7357` (same Wi-Fi; if it fails, Windows Defender Firewall
likely asked for permission on first run - tell the user to allow "private networks").

## Stage 5 - Android (only on demand)

```powershell
winget install --id Google.AndroidStudio -e --accept-package-agreements --accept-source-agreements
```

Then guide the first-run SDK wizard click by click, `flutter doctor
--android-licenses` (answer `y`), device: Settings → About → tap "Build number" ×7 →
Developer options → USB debugging (describe taps), or an emulator via Device Manager.
iPhone owner on Windows → LAN web preview rung, plainly.

Every step idempotent: check-before-install; failed downloads re-run safely.
