param(
  [string]$OutputExe = "F:\projectP1_server_setup.exe",
  [string]$Runtime = "win-x64"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectPath = Join-Path $scriptDir "ServerSetupBootstrap\ServerSetupBootstrap.csproj"

if (-not (Test-Path $projectPath)) {
  throw "Missing bootstrap project: $projectPath"
}

$publishDir = Join-Path $scriptDir "ServerSetupBootstrap\publish"
if (Test-Path $publishDir) {
  Remove-Item -Path $publishDir -Recurse -Force
}
New-Item -Path $publishDir -ItemType Directory -Force | Out-Null

Write-Host "[P1LOT] Publishing standalone server setup executable..."
dotnet publish $projectPath `
  -c Release `
  -r $Runtime `
  --self-contained true `
  /p:PublishSingleFile=true `
  /p:PublishTrimmed=false `
  /p:IncludeNativeLibrariesForSelfExtract=true `
  -o $publishDir

$builtExe = Join-Path $publishDir "projectP1_server_setup.exe"
if (-not (Test-Path $builtExe)) {
  throw "Publish did not produce: $builtExe"
}

$destDir = Split-Path -Parent $OutputExe
if ([string]::IsNullOrWhiteSpace($destDir)) {
  throw "OutputExe must include a directory path."
}
if ($destDir -match '^[A-Za-z]:\\?$') {
  $destDir = "$($destDir.TrimEnd('\'))\"
}
if (-not (Test-Path $destDir) -and -not ($destDir -match '^[A-Za-z]:\\$')) {
  New-Item -Path $destDir -ItemType Directory -Force | Out-Null
}
Copy-Item -Path $builtExe -Destination $OutputExe -Force

Write-Host "[P1LOT] Server setup exe ready: $OutputExe"
