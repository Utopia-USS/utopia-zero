# utopia-zero SessionEnd hook (Windows): session_end event with token usage,
# redacted transcript copy (when enabled), auto-commit+push of analytics.
# Compatible with Windows PowerShell 5.1; UTF-8 throughout, BOM-less writes.
$ErrorActionPreference = "SilentlyContinue"
try {
  try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch { }
  try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
  $an = Join-Path $Root "zero\analytics"
  New-Item -ItemType Directory -Force -Path (Join-Path $an "transcripts") | Out-Null
  $cfg = Get-Content (Join-Path $Root "zero\config.json") -Raw -Encoding UTF8 | ConvertFrom-Json

  $raw = [Console]::In.ReadToEnd()
  $in = $null
  if ($raw) { $in = $raw | ConvertFrom-Json }
  $sid = "s0"
  if ($in -and $in.session_id) { $sid = $in.session_id }
  elseif (Test-Path (Join-Path $an ".session")) { $sid = (Get-Content (Join-Path $an ".session") -Raw).Trim() }
  $tp = $null; if ($in -and $in.transcript_path) { $tp = $in.transcript_path }

  # --- token usage from transcript ---
  $acc = @{}
  if ($tp -and (Test-Path $tp)) {
    foreach ($line in Get-Content $tp -Encoding UTF8) {
      try { $obj = $line | ConvertFrom-Json } catch { continue }
      if (-not $obj.message -or -not $obj.message.usage) { continue }
      $model = "unknown"; if ($obj.message.model) { $model = $obj.message.model }
      if (-not $acc.ContainsKey($model)) { $acc[$model] = @{ in = 0; out = 0 } }
      $u = $obj.message.usage
      $acc[$model]["in"] += [int]($u.input_tokens) + [int]($u.cache_creation_input_tokens) + [int]($u.cache_read_input_tokens)
      $acc[$model]["out"] += [int]($u.output_tokens)
    }
  }
  $models = "{}"
  if ($acc.Count -gt 0) { $models = ($acc | ConvertTo-Json -Compress -Depth 4) }

  # copied = the actual copy condition, not just the flags
  $copied = ($cfg.transcripts_enabled -ne $false) -and ($cfg.analytics_enabled -ne $false) -and $tp -and (Test-Path $tp)

  # in-process call (a child powershell.exe would strip the JSON quotes on PS 5.1)
  & (Join-Path $Root "zero\scripts\log_event.ps1") "session_end" `
      ('{"models":' + $models + ',"est_cost_usd":null,"transcript_copied":' + $copied.ToString().ToLower() + '}') | Out-Null

  # --- redacted transcript copy ---
  if ($copied) {
    $text = Get-Content $tp -Raw -Encoding UTF8
    $text = $text -replace 'github_pat_[A-Za-z0-9_]+', '[REDACTED]'
    $text = $text -replace 'gh[pousr]_[A-Za-z0-9]{10,}', '[REDACTED]'
    $text = $text -replace 'x-access-token:[^@"]*@', '[REDACTED]@'
    $text = $text -replace 'sk-[A-Za-z0-9_-]{16,}', '[REDACTED]'
    $text = $text -replace 'AIza[A-Za-z0-9_-]{30,}', '[REDACTED]'
    $text = $text -replace 'Bearer [A-Za-z0-9._-]{16,}', 'Bearer [REDACTED]'
    $text = $text -replace '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[EMAIL]'
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $an "transcripts\$sid.jsonl"), $text, $enc)
  }

  # --- auto-commit + push analytics ---
  $git = Get-Command git
  if ($git) {
    & git -C $Root add zero/analytics zero/STATE.md 2>$null
    & git -C $Root diff --cached --quiet 2>$null
    if ($LASTEXITCODE -ne 0) {
      & git -C $Root commit -q -m "zero: analytics sync (session $sid)" 2>$null
      & git -C $Root push -q 2>$null
    }
  }
} catch { }
exit 0
