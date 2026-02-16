param(
  [string]$OutputExe = "F:\projectP1_server_setup.exe"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..\..")
$serverRoot = Join-Path $repoRoot "services\server-api"
$installScript = Join-Path $scriptDir "install_server.ps1"
$nodeExe = "C:\Program Files\nodejs\node.exe"

if (-not (Test-Path $serverRoot)) { throw "Server folder not found: $serverRoot" }
if (-not (Test-Path $installScript)) { throw "Install script missing: $installScript" }
if (-not (Test-Path $nodeExe)) { throw "node.exe not found at $nodeExe" }

$staging = Join-Path $scriptDir "staging"
$payload = Join-Path $staging "payload"
$payloadZip = Join-Path $staging "payload.zip"
$sedPath = Join-Path $staging "server_setup.sed"

if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force -Path $payload | Out-Null

Write-Host "Preparing payload..."
Copy-Item -LiteralPath $nodeExe -Destination (Join-Path $payload "node.exe") -Force
Copy-Item -LiteralPath $serverRoot -Destination (Join-Path $payload "server") -Recurse -Force

Write-Host "Creating payload.zip..."
Compress-Archive -Path $payload -DestinationPath $payloadZip -CompressionLevel Optimal -Force
Copy-Item -LiteralPath $installScript -Destination (Join-Path $staging "install_server.ps1") -Force

$targetDir = Split-Path -Parent $OutputExe
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}
if (Test-Path $OutputExe) { Remove-Item -Force $OutputExe }

$friendlyName = "Project P1L0T Server Setup"
$finishMessage = "Project P1L0T Server setup completed."
$appLaunch = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File install_server.ps1"

$sed = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=1
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=$finishMessage
TargetName=$OutputExe
FriendlyName=$friendlyName
AppLaunched=$appLaunch
PostInstallCmd=<None>
AdminQuietInstCmd=$appLaunch
UserQuietInstCmd=$appLaunch
SourceFiles=SourceFiles

[SourceFiles]
SourceFiles0=$staging

[SourceFiles0]
install_server.ps1=
payload.zip=
"@

Set-Content -LiteralPath $sedPath -Value $sed -Encoding ASCII

Write-Host "Building installer with IExpress..."
& iexpress.exe /N $sedPath | Out-Null

if (-not (Test-Path $OutputExe)) {
  throw "IExpress did not create installer: $OutputExe"
}

$item = Get-Item -LiteralPath $OutputExe
Write-Host "Created: $($item.FullName)"
Write-Host "Size: $([math]::Round($item.Length / 1MB, 2)) MB"
