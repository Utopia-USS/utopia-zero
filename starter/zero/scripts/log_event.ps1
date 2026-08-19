# utopia-zero analytics: append one event to zero/analytics/events.jsonl
# usage: powershell -NoProfile -ExecutionPolicy Bypass -File zero/scripts/log_event.ps1 <type> ['<json-payload>']
# Compatible with Windows PowerShell 5.1. Writes BOM-less UTF-8.
# Enforces the event catalog (references/analytics.md): a payload missing a
# required key still gets logged, but with a _schema_warning field and a line
# on stderr - drifting payloads are a data bug, not a style choice.
param(
  [string]$Type = "note",
  [string]$Payload = "{}"
)
$ErrorActionPreference = "SilentlyContinue"
try {
  $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
  $cfgPath = Join-Path $Root "zero\config.json"
  $cfg = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($cfg.analytics_enabled -eq $false) { exit 0 }

  $an = Join-Path $Root "zero\analytics"
  New-Item -ItemType Directory -Force -Path $an | Out-Null

  $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
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

  # --- event catalog: required payload keys per type (analytics.md) ---
  $catalog = @{
    "session_start"      = @("source")
    "session_end"        = @("models")
    "tutorial"           = @("skipped")
    "consent"            = @("analytics")
    "env"                = @("os")
    "model_info"         = @("model")
    "question"           = @("id", "mode", "topic")
    "answer"             = @("id", "mode", "length_chars", "changed_prior")
    "decision"           = @("area", "choice", "rationale", "alternatives", "user_involved")
    "user_override"      = @("ref", "from", "to")
    "build"              = @("target", "ok")
    "error"              = @("category", "signature", "found_by")
    "fix_attempt"        = @("n", "strategy", "ok")
    "stuck"              = @("attempts", "action")
    "checkpoint"         = @("feature", "verdict", "rework")
    "feature_start"      = @("name")
    "feature_done"       = @("name", "commits")
    "scope_request"      = @("summary", "handled")
    "backend_step"       = @("provider", "step", "delegated")
    "language_switch"    = @("from", "to")
    "survey"             = @("stage", "scores")
    "handover_selfscore" = @("scores", "total")
    "stage_start"        = @()
    "stage_end"          = @()
    "note"               = @()
  }
  $warn = ""
  if (-not $catalog.ContainsKey($Type)) {
    $warn = "unknown event type '$Type' - use a catalog type from analytics.md, or note the new type in HANDOVER"
  } else {
    $missing = @()
    foreach ($k in $catalog[$Type]) {
      if ($Payload -notmatch ('"' + [regex]::Escape($k) + '"')) { $missing += $k }
    }
    if ($missing.Count -gt 0) { $warn = "missing required keys: " + ($missing -join ",") }
  }
  if ($warn -ne "") {
    [Console]::Error.WriteLine("utopia-zero log_event SCHEMA WARNING ($Type): $warn. Event logged anyway - fill the catalog keys next time (extra keys are welcome, missing ones break the analysis).")
    $p = $Payload.TrimEnd()
    if ($p -eq "{}") {
      $Payload = '{"_schema_warning":"' + $warn + '"}'
    } elseif ($p.EndsWith("}")) {
      $Payload = $p.Substring(0, $p.Length - 1) + ',"_schema_warning":"' + $warn + '"}'
    }
  }

  $Payload = (Redact $Payload) -replace "`r?`n", " "

  $line = '{"ts":"' + $ts + '","participant_id":"' + $cfg.participant_id +
          '","project_id":"' + $cfg.project_id + '","session_id":"' + $sid +
          '","stage":"' + $stage + '","type":"' + $Type + '","payload":' + $Payload + '}'
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::AppendAllText((Join-Path $an "events.jsonl"), $line + "`n", $enc)

  # --- pulse-survey counter: feature_done increments, survey resets ---
  $pulse = Join-Path $an ".pulse"
  if ($Type -eq "feature_done") {
    $c = 0
    if (Test-Path $pulse) {
      $v = (Get-Content $pulse -Raw).Trim()
      if ($v -match '^\d+$') { $c = [int]$v }
    }
    [System.IO.File]::WriteAllText($pulse, [string]($c + 1), $enc)
  } elseif ($Type -eq "survey") {
    [System.IO.File]::WriteAllText($pulse, "0", $enc)
  }
} catch { }
exit 0
