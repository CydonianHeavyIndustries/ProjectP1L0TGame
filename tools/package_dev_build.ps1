param(
  [string]$InstallRoot = "C:\ProjectP1L0T",
  [string]$Configuration = "Development",
  [switch]$Zip,
  [switch]$PublishRelease
)
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$uproject = Join-Path $repoRoot "ProjectP1L0T.uproject"

if (-not (Test-Path $uproject)) {
  Write-Error "Could not find ProjectP1L0T.uproject in $repoRoot"
  exit 1
}

$engineAssociation = $null
try {
  $projectJson = Get-Content $uproject -Raw | ConvertFrom-Json
  $engineAssociation = $projectJson.EngineAssociation
} catch {
  Write-Warning "Could not parse EngineAssociation from uproject."
}

$possibleRoots = @()
if ($env:UE_ROOT) { $possibleRoots += $env:UE_ROOT }
if ($env:UE_PATH) { $possibleRoots += $env:UE_PATH }
if ($engineAssociation) {
  $possibleRoots += "C:\Program Files\Epic Games\UE_$engineAssociation"
  $possibleRoots += "C:\Epic\UE_$engineAssociation"
  try {
    $regKey = "HKLM:\Software\EpicGames\Unreal Engine\$engineAssociation"
    $regInstall = (Get-ItemProperty -Path $regKey -ErrorAction SilentlyContinue).InstalledDirectory
    if ($regInstall) { $possibleRoots += $regInstall }
  } catch {
    # ignore registry lookup failures
  }
}
$possibleRoots += "C:\Program Files\Epic Games\UE_5.7"
$possibleRoots += "C:\Epic\UE_5.7"

$ueRoot = $possibleRoots | Where-Object { Test-Path (Join-Path $_ "Engine\Build\BatchFiles\RunUAT.bat") } | Select-Object -First 1

if (-not $ueRoot) {
  Write-Error "Unreal Engine not found. Set UE_ROOT to your UE install (ex: C:\Program Files\Epic Games\UE_5.7)."
  exit 1
}

$runUAT = Join-Path $ueRoot "Engine\Build\BatchFiles\RunUAT.bat"
$archiveDir = Join-Path $repoRoot "Builds\Package"

New-Item -ItemType Directory -Force $archiveDir | Out-Null

Write-Host "Using Unreal Engine at: $ueRoot"
Write-Host "Packaging $Configuration build..."

& $runUAT BuildCookRun `
  -project="$uproject" `
  -noP4 `
  -platform=Win64 `
  -clientconfig="$Configuration" `
  -serverconfig="$Configuration" `
  -cook `
  -build `
  -stage `
  -pak `
  -archive `
  -archivedirectory="$archiveDir" `
  -prereqs `
  -utf8output

$stagedRoot = Get-ChildItem $archiveDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "ProjectP1L0T") } | Select-Object -First 1
if (-not $stagedRoot) {
  $stagedRoot = Get-ChildItem $archiveDir -Directory | Select-Object -First 1
}

if (-not $stagedRoot) {
  Write-Error "Could not find staged build under $archiveDir"
  exit 1
}

$installDir = Join-Path $InstallRoot "install"
$configDir = Join-Path $InstallRoot "config"

Write-Host "Copying build to launcher install: $installDir"

if (Test-Path $installDir) {
  Remove-Item -Recurse -Force $installDir
}
New-Item -ItemType Directory -Force $installDir | Out-Null
Copy-Item -Path (Join-Path $stagedRoot.FullName '*') -Destination $installDir -Recurse -Force

New-Item -ItemType Directory -Force $configDir | Out-Null
$versionFile = Join-Path $repoRoot "VERSION"
$versionStamp = Get-Date -Format "yyyy.MM.dd.HHmm"
$version = $versionStamp
if (Test-Path $versionFile) {
  $version = (Get-Content $versionFile -Raw).Trim()
}
$installedRecord = @{
  version = $version
  channel = "dev"
  installedAt = (Get-Date).ToString("o")
  path = $InstallRoot
  source = "local-package"
}
$installedRecord | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $configDir "installed.json")

if ($Zip) {
  $zipDir = Join-Path $repoRoot "Builds\Zips"
  New-Item -ItemType Directory -Force $zipDir | Out-Null
  $zipPath = Join-Path $zipDir "ProjectP1L0T-Dev-$version.zip"
  if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
  Write-Host "Creating zip: $zipPath"
  Compress-Archive -Path (Join-Path $installDir '*') -DestinationPath $zipPath -Force

  if ($PublishRelease -or $env:PUBLISH_RELEASE -eq "1") {
    $exePublisher = Join-Path $repoRoot "tools\publish_release.exe"
    $psPublisher = Join-Path $repoRoot "tools\publish_release.ps1"
    if (Test-Path $exePublisher) {
      Write-Host "Publishing release via publish_release.exe"
      & $exePublisher --zip $zipPath | Write-Host
    } elseif (Test-Path $psPublisher) {
      Write-Host "Publishing release via publish_release.ps1"
      powershell -ExecutionPolicy Bypass -File $psPublisher -ZipPath $zipPath | Write-Host
    } else {
      Write-Warning "No release publisher found. Skipping publish step."
    }
  }
}

Write-Host "Done. Launch from the launcher using the configured executable path."

