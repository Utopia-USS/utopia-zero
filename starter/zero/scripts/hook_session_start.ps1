# utopia-zero SessionStart hook (Windows): session id file, session_start event,
# STATE.md summary -> stdout (context), new Utopia replies on [zero] issues -> stdout.
# Compatible with Windows PowerShell 5.1; UTF-8 in and out.
$ErrorActionPreference = "SilentlyContinue"
try {
  try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch { }
  try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
  $an = Join-Path $Root "zero\analytics"
  New-Item -ItemType Directory -Force -Path $an | Out-Null

  $raw = [Console]::In.ReadToEnd()
  $in = $null
  if ($raw) { $in = $raw | ConvertFrom-Json }
  if ($in -and $in.session_id) { Set-Content -Path (Join-Path $an ".session") -Value $in.session_id -NoNewline }
  $src = "unknown"; if ($in -and $in.source) { $src = $in.source }

  # --- reconcile .stage with STATE.md (the STATE stage line is the source of truth;
  # a stale .stage once mislabeled 197 events - dry-run #2) ---
  $statePath = Join-Path $Root "zero\STATE.md"
  if (Test-Path $statePath) {
    $m = [regex]::Match((Get-Content $statePath -Raw -Encoding UTF8), 'Etap ?/ ?Stage: ?\*\*(\d+)')
    if ($m.Success) {
      $stf = Join-Path $an ".stage"
      $cur = ""
      if (Test-Path $stf) { $cur = (Get-Content $stf -Raw).Trim() }
      if ($cur -ne $m.Groups[1].Value) {
        $encS = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($stf, $m.Groups[1].Value, $encS)
        Write-Output ("=== utopia-zero: .stage reconciled with STATE.md (" + $(if ($cur) { $cur } else { "none" }) + " -> " + $m.Groups[1].Value + ") ===")
      }
    }
  }

  # in-process call (a child powershell.exe would strip the JSON quotes on PS 5.1)
  & (Join-Path $Root "zero\scripts\log_event.ps1") "session_start" ('{"source":"' + $src + '"}') | Out-Null

  # --- first-session banner (fresh project) ---
  $state = Join-Path $Root "zero\STATE.md"
  if ((Test-Path $state) -and (Select-String -Path $state -Pattern "nic jeszcze / nothing yet" -Quiet)) {
    Write-Output "=== utopia-zero: PIERWSZA SESJA ==="
    Write-Output "This is the participant's very first session. Whatever their first message"
    Write-Output "says, greet them warmly in their language and start the wizard (stage 0)."
    Write-Output "They were told everything happens by itself - do not wait for any prompt."
    Write-Output "=== koniec / end ==="
  }

  # --- context injection: project state ---
  if (Test-Path $state) {
    Write-Output "=== utopia-zero: zero/STATE.md (stan projektu / project state) ==="
    Get-Content $state -TotalCount 60 -Encoding UTF8
    Write-Output "=== koniec STATE / end of STATE ==="
  }

  # --- pulse-survey reminder (counter kept by log_event: feature_done +1, survey resets) ---
  $pulseFile = Join-Path $an ".pulse"
  $pc = 0
  if (Test-Path $pulseFile) {
    $pv = (Get-Content $pulseFile -Raw).Trim()
    if ($pv -match '^\d+$') { $pc = [int]$pv }
  }
  if ($pc -ge 3) {
    Write-Output "=== utopia-zero: puls satysfakcji zalegly / pulse survey overdue ==="
    Write-Output "$pc feature_done since the last survey. Run the 2-question pulse (stages.md,"
    Write-Output "stage 4 step 8) at the next natural break and log survey{stage, scores}."
    Write-Output "=== koniec / end ==="
  }

  # --- Utopia replies on [zero] issues (best-effort) ---
  $patFile = Join-Path $Root "zero\.pat"
  $cfg = Get-Content (Join-Path $Root "zero\config.json") -Raw -Encoding UTF8 | ConvertFrom-Json
  if ((Test-Path $patFile) -and $cfg.git_remote -match 'github\.com[/:]([\w\.-]+/[\w\.-]+?)(\.git)?$') {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }
    $repo = $Matches[1]
    $pat = (Get-Content $patFile -Raw).Trim()
    $ckptFile = Join-Path $an ".issues_seen"
    $since = "1970-01-01T00:00:00Z"
    if (Test-Path $ckptFile) { $since = (Get-Content $ckptFile -Raw).Trim() }
    $headers = @{ Authorization = "Bearer $pat"; Accept = "application/vnd.github+json"; "User-Agent" = "utopia-zero" }
    $latest = $since
    $found = @()
    $issues = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/issues?state=open&per_page=20" -Headers $headers -TimeoutSec 6
    foreach ($issue in $issues) {
      if (-not $issue.title.StartsWith("[zero]")) { continue }
      $comments = Invoke-RestMethod -Uri ($issue.comments_url + "?per_page=30") -Headers $headers -TimeoutSec 6
      foreach ($c in $comments) {
        if ($c.created_at -gt $since) {
          $body = $c.body
          if ($body.Length -gt 600) { $body = $body.Substring(0, 600) }
          $found += "--- Odpowiedź Utopii / Utopia replied on issue #$($issue.number) ($($issue.title)):`n$body`n"
          if ($c.created_at -gt $latest) { $latest = $c.created_at }
        }
      }
    }
    if ($found.Count -gt 0) {
      Write-Output "=== utopia-zero: nowe odpowiedzi Utopii w issues ==="
      $found | ForEach-Object { Write-Output $_ }
      Write-Output "(Przeczytaj je PRZED planowaniem pracy i odpisz w issue, co zrobiłeś.)"
    }
    Set-Content -Path $ckptFile -Value $latest -NoNewline
  }
} catch { }
exit 0
