param(
  [string]$InstallDir = ""
)

$ErrorActionPreference = "Stop"

function Test-Admin {
  $current = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($current)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
  Write-Host "ERROR: Please run this installer as Administrator."
  exit 1
}

Add-Type -AssemblyName System.Windows.Forms | Out-Null

if ([string]::IsNullOrWhiteSpace($InstallDir)) {
  $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
  $dialog.Description = "Choose install directory for Project P1L0T Server"
  $dialog.SelectedPath = "$env:ProgramFiles\\ProjectP1L0T_Server"
  if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "Install cancelled."
    exit 1
  }
  $InstallDir = $dialog.SelectedPath
}

$payloadRoot = Join-Path $PSScriptRoot "payload"
$payloadZip = Join-Path $PSScriptRoot "payload.zip"
if (-not (Test-Path $payloadRoot)) {
  if (Test-Path $payloadZip) {
    Write-Host "Extracting payload..."
    Expand-Archive -LiteralPath $payloadZip -DestinationPath $PSScriptRoot -Force
  }
}
if (-not (Test-Path $payloadRoot)) {
  Write-Host "ERROR: Payload not found. Rebuild the installer."
  exit 1
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Write-Host "Installing to $InstallDir"

Copy-Item -Path (Join-Path $payloadRoot "*") -Destination $InstallDir -Recurse -Force

$serviceName = "ProjectP1L0TServer"
$displayName = "Project P1L0T Server"
$nodeExe = Join-Path $InstallDir "node.exe"
$serverJs = Join-Path $InstallDir "server\\server.js"

if (-not (Test-Path $nodeExe)) { Write-Host "ERROR: node.exe missing."; exit 1 }
if (-not (Test-Path $serverJs)) { Write-Host "ERROR: server.js missing."; exit 1 }

$binPath = "`"$nodeExe`" `"$serverJs`""

try {
  $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
  if ($existing) {
    Write-Host "Removing existing service..."
    sc.exe stop $serviceName | Out-Null
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 2
  }
} catch {
  # ignore
}

Write-Host "Creating service..."
sc.exe create $serviceName binPath= $binPath start= auto DisplayName= $displayName | Out-Null
sc.exe description $serviceName "Project P1L0T backend server (social + logging)." | Out-Null

Write-Host "Configuring firewall..."
try {
  netsh advfirewall firewall add rule name="ProjectP1L0T Server" dir=in action=allow protocol=TCP localport=4280 | Out-Null
} catch {
  Write-Host "WARN: Firewall rule could not be added."
}

Write-Host "Starting service..."
sc.exe start $serviceName | Out-Null

Write-Host "Creating logon task (ensures service is running)..."
try {
  schtasks /Create /TN "ProjectP1L0TServerAutoStart" /TR "sc start ProjectP1L0TServer" /SC ONLOGON /RL HIGHEST /F | Out-Null
} catch {
  Write-Host "WARN: Could not create scheduled task."
}

Write-Host "Install complete."
