param(
  [switch]$Major,
  [switch]$Minor,
  [switch]$Patch,
  [string]$Set
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$versionPath = Join-Path $repoRoot "VERSION"

if (-not (Test-Path $versionPath)) {
  Set-Content -Path $versionPath -Value "0.1.0" -Encoding UTF8
}

$current = (Get-Content $versionPath -Raw).Trim()
if (-not $current -match "^\\d+\\.\\d+\\.\\d+$") {
  Write-Error "VERSION must be in MAJOR.MINOR.PATCH format. Current: $current"
  exit 1
}

if ($Set) {
  if (-not $Set -match "^\\d+\\.\\d+\\.\\d+$") {
    Write-Error "Set value must be MAJOR.MINOR.PATCH"
    exit 1
  }
  $next = $Set
} else {
  $parts = $current.Split(".") | ForEach-Object { [int]$_ }
  if ($Major) {
    $parts[0]++
    $parts[1] = 0
    $parts[2] = 0
  } elseif ($Minor) {
    $parts[1]++
    $parts[2] = 0
  } else {
    # default to patch bump
    $parts[2]++
  }
  $next = "$($parts[0]).$($parts[1]).$($parts[2])"
}

Set-Content -Path $versionPath -Value $next -Encoding UTF8
Write-Host "Version updated: $current -> $next"
