# utopia-zero analytics: append one event to zero/analytics/events.jsonl
# usage: powershell -NoProfile -ExecutionPolicy Bypass -File zero/scripts/log_event.ps1 <type> ['<json-payload>']
param(
  [string]$Type = "note",
  [string]$Payload = "{}"
)
$ErrorActionPreference = "SilentlyContinue"
try {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
  $cfgPath = Join-Path $Root "zero\config.json"
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
  if ($cfg.analytics_enabled -eq $false) { exit 0 }

  $an = Join-Path $Root "zero\analytics"
  New-Item -ItemType Directory -Force -Path $an | Out-Null

  $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $sid = "s0"; $sf = Join-Path $an ".session"
  if (Test-Path $sf) { $sid = (Get-Content $sf -Raw).Trim() }
  $stage = "0"; $stf = Join-Path $an ".stage"
  if (Test-Path $stf) { $stage = (Get-Content $stf -Raw).Trim() }

  function Redact([string]$s) {
    $s = $s -replace 'github_pat_[A-Za-z0-9_]+', '[REDACTED]'
    $s = $s -replace 'gh[pousr]_[A-Za-z0-9]{10,}', '[REDACTED]'
    $s = $s -replace 'x-access-token:[^@"]*@', '[REDACTED]@'
    $s = $s -replace 'sk-[A-Za-z0-9_-]{16,}', '[REDACTED]'
    $s = $s -replace 'AIza[A-Za-z0-9_-]{30,}', '[REDACTED]'
    $s = $s -replace 'Bearer [A-Za-z0-9._-]{16,}', 'Bearer [REDACTED]'
    $s = $s -replace '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[EMAIL]'
    return $s
  }

  if ([string]::IsNullOrWhiteSpace($Payload)) { $Payload = "{}" }
  $Payload = (Redact $Payload) -replace "`r?`n", " "

  $line = '{"ts":"' + $ts + '","participant_id":"' + $cfg.participant_id +
          '","project_id":"' + $cfg.project_id + '","session_id":"' + $sid +
          '","stage":"' + $stage + '","type":"' + $Type + '","payload":' + $Payload + '}'
  Add-Content -Path (Join-Path $an "events.jsonl") -Value $line -Encoding utf8
} catch { }
exit 0
