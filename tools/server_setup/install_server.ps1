param(
  [string]$InstallDir = "",
  [string]$InstallerRoot = "",
  [string]$Repo = "CydonianHeavyIndustries/ProjectP1L0TGame",
  [string]$Branch = "host"
)

$ErrorActionPreference = "Stop"

$InstallDir = $InstallDir.Trim()
$InstallerRoot = $InstallerRoot.Trim().Trim('"')
$Repo = $Repo.Trim()
$Branch = $Branch.Trim()
if ($InstallerRoot.EndsWith("\")) {
  $InstallerRoot = $InstallerRoot.TrimEnd("\")
}

$script:ExternalLogPath = ""
if (-not [string]::IsNullOrWhiteSpace($InstallerRoot)) {
  try {
    $script:ExternalLogPath = Join-Path $InstallerRoot "installer.log"
  } catch {}
}

function Write-InstallLog([string]$message) {
  $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $message
  Write-Host $line
  if (-not [string]::IsNullOrWhiteSpace($script:ExternalLogPath)) {
    try { Add-Content -Path $script:ExternalLogPath -Value $line -Encoding UTF8 } catch {}
  }
}

function Test-Admin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-Info([string]$message) {
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.MessageBox]::Show($message, "Project P1L0T Server Setup", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
  } catch {
    Write-Host $message
  }
}

function Ask-YesNo([string]$message) {
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    $result = [System.Windows.Forms.MessageBox]::Show($message, "Project P1L0T Server Setup", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    return $result -eq [System.Windows.Forms.DialogResult]::Yes
  } catch {
    return $false
  }
}

function Show-Error([string]$message) {
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.MessageBox]::Show($message, "Project P1L0T Server Setup", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
  } catch {
    Write-Error $message
  }
}

function Show-InstallWizard([string]$DefaultDir) {
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    Add-Type -AssemblyName System.Drawing | Out-Null
  } catch {
    return @{
      InstallDir = $DefaultDir
      EnableMaxHardware = $false
      CreateDesktopShortcut = $true
      LaunchAfterInstall = $true
    }
  }

  $form = New-Object System.Windows.Forms.Form
  $form.Text = "Project P1L0T Server Setup"
  $form.StartPosition = "CenterScreen"
  $form.FormBorderStyle = "FixedDialog"
  $form.MaximizeBox = $false
  $form.MinimizeBox = $false
  $form.ClientSize = New-Object System.Drawing.Size(640, 300)
  $form.TopMost = $true

  $title = New-Object System.Windows.Forms.Label
  $title.Text = "Server Installation Setup"
  $title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
  $title.AutoSize = $true
  $title.Location = New-Object System.Drawing.Point(16, 14)
  $form.Controls.Add($title)

  $desc = New-Object System.Windows.Forms.Label
  $desc.Text = "Choose installation folder and options."
  $desc.AutoSize = $true
  $desc.Location = New-Object System.Drawing.Point(16, 44)
  $form.Controls.Add($desc)

  $pathLabel = New-Object System.Windows.Forms.Label
  $pathLabel.Text = "Install Location:"
  $pathLabel.AutoSize = $true
  $pathLabel.Location = New-Object System.Drawing.Point(16, 78)
  $form.Controls.Add($pathLabel)

  $pathBox = New-Object System.Windows.Forms.TextBox
  $pathBox.Size = New-Object System.Drawing.Size(490, 24)
  $pathBox.Location = New-Object System.Drawing.Point(16, 100)
  $pathBox.Text = $DefaultDir
  $form.Controls.Add($pathBox)

  $browse = New-Object System.Windows.Forms.Button
  $browse.Text = "Browse..."
  $browse.Size = New-Object System.Drawing.Size(100, 27)
  $browse.Location = New-Object System.Drawing.Point(522, 98)
  $browse.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Choose install directory for Project P1L0T Server"
    $dialog.SelectedPath = if ([string]::IsNullOrWhiteSpace($pathBox.Text)) { $DefaultDir } else { $pathBox.Text }
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
      $pathBox.Text = $dialog.SelectedPath
    }
  })
  $form.Controls.Add($browse)

  $maxHardware = New-Object System.Windows.Forms.CheckBox
  $maxHardware.Text = "Use all available hardware (max performance profile)"
  $maxHardware.AutoSize = $true
  $maxHardware.Location = New-Object System.Drawing.Point(16, 142)
  $form.Controls.Add($maxHardware)

  $desktopShortcut = New-Object System.Windows.Forms.CheckBox
  $desktopShortcut.Text = "Create desktop shortcut"
  $desktopShortcut.Checked = $true
  $desktopShortcut.AutoSize = $true
  $desktopShortcut.Location = New-Object System.Drawing.Point(16, 168)
  $form.Controls.Add($desktopShortcut)

  $launchAfter = New-Object System.Windows.Forms.CheckBox
  $launchAfter.Text = "Launch server manager after install"
  $launchAfter.Checked = $true
  $launchAfter.AutoSize = $true
  $launchAfter.Location = New-Object System.Drawing.Point(16, 194)
  $form.Controls.Add($launchAfter)

  $ok = New-Object System.Windows.Forms.Button
  $ok.Text = "Install"
  $ok.Size = New-Object System.Drawing.Size(95, 30)
  $ok.Location = New-Object System.Drawing.Point(430, 248)
  $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $form.AcceptButton = $ok
  $form.Controls.Add($ok)

  $cancel = New-Object System.Windows.Forms.Button
  $cancel.Text = "Cancel"
  $cancel.Size = New-Object System.Drawing.Size(95, 30)
  $cancel.Location = New-Object System.Drawing.Point(535, 248)
  $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $form.CancelButton = $cancel
  $form.Controls.Add($cancel)

  $ok.Add_Click({
    if ([string]::IsNullOrWhiteSpace($pathBox.Text)) {
      [System.Windows.Forms.MessageBox]::Show("Install location is required.", "Project P1L0T Server Setup") | Out-Null
      $form.DialogResult = [System.Windows.Forms.DialogResult]::None
      return
    }
  })

  $result = $form.ShowDialog()
  if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
    return $null
  }

  return @{
    InstallDir = $pathBox.Text.Trim()
    EnableMaxHardware = [bool]$maxHardware.Checked
    CreateDesktopShortcut = [bool]$desktopShortcut.Checked
    LaunchAfterInstall = [bool]$launchAfter.Checked
  }
}

$script:ProgressForm = $null
$script:ProgressLabel = $null
$script:ProgressBar = $null

function Start-InstallProgress {
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    Add-Type -AssemblyName System.Drawing | Out-Null
  } catch {
    return
  }

  $script:ProgressForm = New-Object System.Windows.Forms.Form
  $script:ProgressForm.Text = "Project P1L0T Server Setup Progress"
  $script:ProgressForm.StartPosition = "CenterScreen"
  $script:ProgressForm.FormBorderStyle = "FixedDialog"
  $script:ProgressForm.MaximizeBox = $false
  $script:ProgressForm.MinimizeBox = $false
  $script:ProgressForm.ControlBox = $false
  $script:ProgressForm.ClientSize = New-Object System.Drawing.Size(620, 120)
  $script:ProgressForm.TopMost = $true

  $script:ProgressLabel = New-Object System.Windows.Forms.Label
  $script:ProgressLabel.Text = "Starting setup..."
  $script:ProgressLabel.AutoSize = $false
  $script:ProgressLabel.Size = New-Object System.Drawing.Size(590, 26)
  $script:ProgressLabel.Location = New-Object System.Drawing.Point(15, 18)
  $script:ProgressLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  $script:ProgressForm.Controls.Add($script:ProgressLabel)

  $script:ProgressBar = New-Object System.Windows.Forms.ProgressBar
  $script:ProgressBar.Location = New-Object System.Drawing.Point(15, 58)
  $script:ProgressBar.Size = New-Object System.Drawing.Size(590, 28)
  $script:ProgressBar.Minimum = 0
  $script:ProgressBar.Maximum = 100
  $script:ProgressBar.Value = 0
  $script:ProgressForm.Controls.Add($script:ProgressBar)

  $script:ProgressForm.Show()
  [System.Windows.Forms.Application]::DoEvents()
}

function Set-InstallProgress([int]$Percent, [string]$Message) {
  $p = [Math]::Min([Math]::Max($Percent, 0), 100)
  Write-InstallLog "[P1LOT] Progress $p% - $Message"
  if ($script:ProgressForm -and -not $script:ProgressForm.IsDisposed) {
    $script:ProgressLabel.Text = $Message
    $script:ProgressBar.Value = $p
    [System.Windows.Forms.Application]::DoEvents()
  } else {
    Write-Progress -Activity "Project P1L0T Server Setup" -Status $Message -PercentComplete $p
  }
}

function Stop-InstallProgress {
  if ($script:ProgressForm -and -not $script:ProgressForm.IsDisposed) {
    $script:ProgressForm.Close()
    $script:ProgressForm.Dispose()
  }
  $script:ProgressForm = $null
  $script:ProgressLabel = $null
  $script:ProgressBar = $null
}

function New-FileShortcut([string]$ShortcutPath, [string]$TargetPath, [string]$Arguments = "", [string]$WorkingDirectory = "") {
  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($ShortcutPath)
  $shortcut.TargetPath = $TargetPath
  if (-not [string]::IsNullOrWhiteSpace($Arguments)) {
    $shortcut.Arguments = $Arguments
  }
  if (-not [string]::IsNullOrWhiteSpace($WorkingDirectory)) {
    $shortcut.WorkingDirectory = $WorkingDirectory
  }
  $shortcut.Save()
}

function New-AdminToken {
  $bytes = New-Object byte[] 24
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  return ([Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', 'A').Replace('/', 'B'))
}

function Download-RepoBranch([string]$RepoName, [string]$BranchName, [string]$TempRoot) {
  $zipPath = Join-Path $TempRoot "$BranchName.zip"
  $extractDir = Join-Path $TempRoot "$BranchName.extract"
  $url = "https://codeload.github.com/$RepoName/zip/refs/heads/$BranchName"
  Write-InstallLog "[P1LOT] Downloading branch archive: $url"
  Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -TimeoutSec 120
  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

  $rootDir = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
  if (-not $rootDir) {
    throw "Downloaded branch archive is empty."
  }
  return $rootDir.FullName
}

function Ensure-NodeRuntime([string]$InstallRoot, [string]$TempRoot) {
  $runtimeDir = Join-Path $InstallRoot "node_runtime"
  if (Test-Path $runtimeDir) {
    Remove-Item -Path $runtimeDir -Recurse -Force
  }
  New-Item -Path $runtimeDir -ItemType Directory -Force | Out-Null

  $systemNode = Get-Command node -ErrorAction SilentlyContinue
  $systemNpm = Get-Command npm -ErrorAction SilentlyContinue

  if ($systemNode -and $systemNpm) {
    Copy-Item -Path $systemNode.Source -Destination (Join-Path $runtimeDir "node.exe") -Force
    Write-InstallLog "[P1LOT] Using system npm: $($systemNpm.Source)"
    return @{
      NodeExe = (Join-Path $runtimeDir "node.exe")
      NpmCmd = $systemNpm.Source
    }
  }

  Write-InstallLog "[P1LOT] System Node/npm not found. Downloading Node LTS runtime..."
  $index = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" -Method Get -TimeoutSec 60
  $lts = $index | Where-Object { $_.lts -and $_.lts -ne $false } | Select-Object -First 1
  if (-not $lts) {
    throw "Could not resolve Node LTS release."
  }

  $version = $lts.version
  $zipName = "node-$version-win-x64.zip"
  $zipUrl = "https://nodejs.org/dist/$version/$zipName"
  $zipPath = Join-Path $TempRoot $zipName
  $extractPath = Join-Path $TempRoot "node.extract"

  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 120
  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

  $nodeDir = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
  if (-not $nodeDir) {
    throw "Node runtime archive did not extract correctly."
  }

  Copy-Item -Path (Join-Path $nodeDir.FullName "*") -Destination $runtimeDir -Recurse -Force
  $npmCmd = Join-Path $runtimeDir "npm.cmd"
  $nodeExe = Join-Path $runtimeDir "node.exe"
  if (-not (Test-Path $npmCmd)) { throw "npm.cmd missing after Node runtime download." }
  if (-not (Test-Path $nodeExe)) { throw "node.exe missing after Node runtime download." }

  Write-InstallLog "[P1LOT] Downloaded Node runtime $version"
  return @{
    NodeExe = $nodeExe
    NpmCmd = $npmCmd
  }
}

function Ensure-Nssm([string]$InstallRoot, [string]$TempRoot) {
  $toolsDir = Join-Path $InstallRoot "tools"
  New-Item -Path $toolsDir -ItemType Directory -Force | Out-Null
  $nssmExe = Join-Path $toolsDir "nssm.exe"
  if (Test-Path $nssmExe) {
    return $nssmExe
  }

  $zipPath = Join-Path $TempRoot "nssm-2.24.zip"
  $extractDir = Join-Path $TempRoot "nssm.extract"
  Write-InstallLog "[P1LOT] Downloading NSSM service wrapper..."
  Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $zipPath -UseBasicParsing -TimeoutSec 120
  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

  $candidate = Get-ChildItem -Path $extractDir -Recurse -File -Filter "nssm.exe" | Where-Object { $_.FullName -match "\\win64\\nssm\.exe$" } | Select-Object -First 1
  if (-not $candidate) {
    $candidate = Get-ChildItem -Path $extractDir -Recurse -File -Filter "nssm.exe" | Select-Object -First 1
  }
  if (-not $candidate) {
    throw "NSSM download did not contain nssm.exe."
  }

  Copy-Item -Path $candidate.FullName -Destination $nssmExe -Force
  return $nssmExe
}

function Write-ServerManagerScripts([string]$InstallRoot, [string]$AdminToken) {
  $managerDir = Join-Path $InstallRoot "server_manager"
  New-Item -Path $managerDir -ItemType Directory -Force | Out-Null

  $tokenFile = Join-Path $managerDir "admin_token.txt"
  Set-Content -Path $tokenFile -Value $AdminToken -Encoding ASCII -Force

  $openAdmin = @"
@echo off
setlocal
set "BASE_URL=http://127.0.0.1:4280"
set "ADMIN_TOKEN=$AdminToken"
if not "%~1"=="" set "BASE_URL=%~1"
start "" "%BASE_URL%/admin/?token=%ADMIN_TOKEN%"
exit /b 0
"@
  Set-Content -Path (Join-Path $managerDir "open_admin_ui.bat") -Value $openAdmin -Encoding ASCII

  $control = @'
@echo off
setlocal EnableDelayedExpansion
set "SVC=ProjectP1L0TServer"

:menu
cls
echo ===========================================
echo       Project P1L0T Server Control
echo ===========================================
echo [1] Start service
echo [2] Stop service
echo [3] Restart service
echo [4] Service status
echo [5] Open Admin UI
echo [0] Exit
echo.
set /p "choice=Select option: "

if "!choice!"=="1" (
  net start "!SVC!"
  pause
  goto menu
)
if "!choice!"=="2" (
  net stop "!SVC!"
  pause
  goto menu
)
if "!choice!"=="3" (
  net stop "!SVC!"
  net start "!SVC!"
  pause
  goto menu
)
if "!choice!"=="4" (
  sc query "!SVC!"
  pause
  goto menu
)
if "!choice!"=="5" (
  start "" "http://127.0.0.1:4280/admin/"
  goto menu
)
if "!choice!"=="0" exit /b 0
goto menu
'@
  Set-Content -Path (Join-Path $managerDir "server_control.bat") -Value $control -Encoding ASCII
}

function Write-ServiceRunnerScript([string]$InstallRoot) {
  $runnerPath = Join-Path $InstallRoot "run_server_service.bat"
  $runner = @'
@echo off
setlocal
cd /d "%~dp0apps\server-api"
"%~dp0node_runtime\node.exe" "%~dp0apps\server-api\server.js"
'@
  Set-Content -Path $runnerPath -Value $runner -Encoding ASCII
  return $runnerPath
}

function Wait-Health([int]$MaxChecks = 20, [int]$DelayMs = 300) {
  for ($i = 0; $i -lt $MaxChecks; $i++) {
    Start-Sleep -Milliseconds $DelayMs
    try {
      $health = Invoke-RestMethod -Uri "http://127.0.0.1:4280/api/health" -Method Get -TimeoutSec 2
      if ($health.ok) {
        return $true
      }
    } catch {
    }
  }
  return $false
}

function Stop-NodeProcessesForInstall([string]$InstallRoot) {
  try {
    $prefix = [IO.Path]::GetFullPath($InstallRoot).TrimEnd('\') + '\'
    $nodeProcs = Get-Process -Name "node" -ErrorAction SilentlyContinue
    foreach ($proc in $nodeProcs) {
      try {
        $procPath = $proc.Path
        if ($procPath -and $procPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
          Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
      } catch {
      }
    }
  } catch {
  }
}

function Remove-ExistingService([string]$ServiceName, [string]$InstallRoot) {
  $existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
  if (-not $existing) {
    return
  }

  Write-InstallLog "[P1LOT] Existing service detected. Removing $ServiceName..."
  try { Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue } catch {}
  Start-Sleep -Seconds 1

  $nssmFromInstall = Join-Path $InstallRoot "tools\nssm.exe"
  if (Test-Path $nssmFromInstall) {
    try { & $nssmFromInstall remove $ServiceName confirm | Out-Null } catch {}
  }

  try { sc.exe stop $ServiceName | Out-Null } catch {}
  try { sc.exe delete $ServiceName | Out-Null } catch {}
  Start-Sleep -Seconds 2
}

if (-not (Test-Admin)) {
  Write-InstallLog "[P1LOT] Elevating installer to admin..."
  $args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-File", "`"$PSCommandPath`"")
  if (-not [string]::IsNullOrWhiteSpace($InstallDir)) {
    $args += "-InstallDir"
    $args += "`"$InstallDir`""
  }
  if (-not [string]::IsNullOrWhiteSpace($InstallerRoot)) {
    $args += "-InstallerRoot"
    $args += "`"$InstallerRoot`""
  }
  if (-not [string]::IsNullOrWhiteSpace($Repo)) {
    $args += "-Repo"
    $args += "`"$Repo`""
  }
  if (-not [string]::IsNullOrWhiteSpace($Branch)) {
    $args += "-Branch"
    $args += "`"$Branch`""
  }

  $proc = Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs -PassThru
  $proc.WaitForExit()
  Write-InstallLog "[P1LOT] Elevated installer exited with code $($proc.ExitCode)."
  exit $proc.ExitCode
}

$setupRoot = if (-not [string]::IsNullOrWhiteSpace($InstallerRoot)) { $InstallerRoot } else { $PSScriptRoot }
$programDataRoot = Join-Path $env:ProgramData "ProjectP1L0TServer"
$logDir = Join-Path $programDataRoot "logs"
$logFile = Join-Path $logDir "installer.log"
New-Item -Path $logDir -ItemType Directory -Force | Out-Null

$tempRoot = Join-Path $env:TEMP ("ProjectP1L0T_ServerInstall_" + [guid]::NewGuid().ToString("N"))
New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null

Start-Transcript -Path $logFile -Append | Out-Null
try {
  Write-InstallLog "[P1LOT] Running elevated installer."
  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  Add-Type -AssemblyName System.Drawing | Out-Null

  $serviceName = "ProjectP1L0TServer"
  $defaultInstallDir = if ([string]::IsNullOrWhiteSpace($InstallDir)) { "$env:ProgramFiles\ProjectP1L0T_Server" } else { $InstallDir }
  $wizard = Show-InstallWizard -DefaultDir $defaultInstallDir
  if (-not $wizard) {
    throw "Install cancelled."
  }

  $InstallDir = $wizard.InstallDir
  $enableMaxHardware = [bool]$wizard.EnableMaxHardware
  $createDesktopShortcut = [bool]$wizard.CreateDesktopShortcut
  $launchAfterInstall = [bool]$wizard.LaunchAfterInstall

  Start-InstallProgress
  Set-InstallProgress 5 "Preparing installation..."

  Remove-ExistingService -ServiceName $serviceName -InstallRoot $InstallDir
  Stop-NodeProcessesForInstall -InstallRoot $InstallDir

  New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null

  Set-InstallProgress 15 "Downloading host branch files..."
  $sourceRoot = $null
  try {
    $sourceRoot = Download-RepoBranch -RepoName $Repo -BranchName $Branch -TempRoot $tempRoot
  } catch {
    if ($Branch -eq "host") {
      Write-InstallLog "[P1LOT] Branch 'host' failed, trying 'Host'..."
      $sourceRoot = Download-RepoBranch -RepoName $Repo -BranchName "Host" -TempRoot $tempRoot
    } else {
      throw
    }
  }

  Set-InstallProgress 25 "Preparing server files..."
  $serverSrc = Join-Path $sourceRoot "apps\server-api"
  $websiteSrc = Join-Path $sourceRoot "apps\website"
  if (-not (Test-Path $serverSrc)) {
    throw "Missing apps/server-api in downloaded branch."
  }

  $serverDest = Join-Path $InstallDir "apps\server-api"
  $websiteDest = Join-Path $InstallDir "apps\website"

  if (Test-Path $serverDest) {
    Remove-Item -Path $serverDest -Recurse -Force
  }
  New-Item -Path $serverDest -ItemType Directory -Force | Out-Null
  Copy-Item -Path (Join-Path $serverSrc "*") -Destination $serverDest -Recurse -Force

  if (Test-Path $websiteSrc) {
    if (Test-Path $websiteDest) {
      Remove-Item -Path $websiteDest -Recurse -Force
    }
    New-Item -Path $websiteDest -ItemType Directory -Force | Out-Null
    Copy-Item -Path (Join-Path $websiteSrc "*") -Destination $websiteDest -Recurse -Force
  }

  $runtimeData = Join-Path $serverDest "data"
  if (Test-Path $runtimeData) {
    Remove-Item -Path $runtimeData -Recurse -Force
  }
  New-Item -Path (Join-Path $runtimeData "user_files") -ItemType Directory -Force | Out-Null

  Set-InstallProgress 35 "Writing server management scripts..."
  Set-InstallProgress 45 "Installing runtime dependencies..."
  $runtime = Ensure-NodeRuntime -InstallRoot $InstallDir -TempRoot $tempRoot
  $nodeExe = $runtime.NodeExe
  $npmCmd = $runtime.NpmCmd
  $nssmExe = Ensure-Nssm -InstallRoot $InstallDir -TempRoot $tempRoot

  Write-InstallLog "[P1LOT] Installing server npm dependencies..."
  Set-InstallProgress 60 "Installing npm dependencies..."
  Push-Location $serverDest
  try {
    & $npmCmd install --omit=dev --no-audit --no-fund | Out-Null
  } finally {
    Pop-Location
  }

  Set-InstallProgress 70 "Applying server configuration..."
  $configPath = Join-Path $runtimeData "server.config.json"
  $existingConfig = @{}
  if (Test-Path $configPath) {
    try {
      $parsed = Get-Content -Path $configPath -Raw -ErrorAction Stop | ConvertFrom-Json
      if ($parsed) {
        foreach ($prop in $parsed.PSObject.Properties) {
          $existingConfig[$prop.Name] = $prop.Value
        }
      }
    } catch {
      $existingConfig = @{}
    }
  }
  $existingConfig["hardwareProfile"] = if ($enableMaxHardware) { "max" } else { "recommended" }
  $existingConfig["maxPlayers"] = if ($enableMaxHardware) { 128 } else { 64 }
  $existingConfig["tickRate"] = if ($enableMaxHardware) { 120 } else { 60 }
  $existingConfig["autosaveSeconds"] = if ($enableMaxHardware) { 15 } else { 30 }
  $adminToken = if ($existingConfig.ContainsKey("adminToken") -and -not [string]::IsNullOrWhiteSpace($existingConfig["adminToken"])) { [string]$existingConfig["adminToken"] } else { New-AdminToken }
  if ($adminToken -eq "change-me-now") {
    $adminToken = New-AdminToken
  }
  $existingConfig["adminToken"] = $adminToken
  $existingConfig | ConvertTo-Json -Depth 8 | Set-Content -Path $configPath -Encoding UTF8

  Set-InstallProgress 74 "Writing server management scripts..."
  Write-ServerManagerScripts -InstallRoot $InstallDir -AdminToken $adminToken
  $runnerBat = Write-ServiceRunnerScript -InstallRoot $InstallDir

  Set-InstallProgress 78 "Configuring Windows service..."
  $serverJs = Join-Path $serverDest "server.js"
  $serverControlBat = Join-Path $InstallDir "server_manager\server_control.bat"
  $openAdminBat = Join-Path $InstallDir "server_manager\open_admin_ui.bat"
  if (-not (Test-Path $nodeExe)) { throw "node.exe missing at $nodeExe" }
  if (-not (Test-Path $serverJs)) { throw "server.js missing at $serverJs" }
  if (-not (Test-Path $runnerBat)) { throw "service runner batch missing at $runnerBat" }
  if (-not (Test-Path $serverControlBat)) { throw "server manager batch missing at $serverControlBat" }
  if (-not (Test-Path $openAdminBat)) { throw "admin launcher batch missing at $openAdminBat" }

  Write-InstallLog "[P1LOT] Running preflight startup test..."
  Set-InstallProgress 84 "Running preflight health check..."
  $preflightProc = Start-Process -FilePath $nodeExe -ArgumentList "`"$serverJs`"" -WorkingDirectory $serverDest -WindowStyle Hidden -PassThru
  if (-not (Wait-Health -MaxChecks 25 -DelayMs 300)) {
    try { Stop-Process -Id $preflightProc.Id -Force -ErrorAction SilentlyContinue } catch {}
    throw "Preflight failed: node server did not pass health check on port 4280."
  }
  try { Stop-Process -Id $preflightProc.Id -Force -ErrorAction SilentlyContinue } catch {}
  Start-Sleep -Milliseconds 800

  Remove-ExistingService -ServiceName $serviceName -InstallRoot $InstallDir

  & $nssmExe install $serviceName $nodeExe $serverJs | Out-Null
  & $nssmExe set $serviceName AppDirectory $serverDest | Out-Null
  & $nssmExe set $serviceName DisplayName "Project P1L0T Server" | Out-Null
  & $nssmExe set $serviceName Description "Project P1L0T backend server API and admin UI." | Out-Null
  & $nssmExe set $serviceName Start SERVICE_AUTO_START | Out-Null
  & $nssmExe set $serviceName AppStdout (Join-Path $runtimeData "service_stdout.log") | Out-Null
  & $nssmExe set $serviceName AppStderr (Join-Path $runtimeData "service_stderr.log") | Out-Null
  & $nssmExe set $serviceName AppRotateFiles 1 | Out-Null
  & $nssmExe set $serviceName AppRotateOnline 1 | Out-Null
  try {
    Set-InstallProgress 90 "Starting service..."
    Start-Service -Name $serviceName
    Write-InstallLog "[P1LOT] Service installed and started."
  } catch {
    $qc = (sc.exe qc $serviceName) -join " "
    $query = (sc.exe query $serviceName) -join " "
    Write-InstallLog "[P1LOT] Service start diagnostics QC: $qc"
    Write-InstallLog "[P1LOT] Service start diagnostics QUERY: $query"
    throw
  }

  Set-InstallProgress 94 "Applying firewall and startup rules..."
  if (-not (Get-NetFirewallRule -DisplayName "ProjectP1L0T Server API" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "ProjectP1L0T Server API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 4280 | Out-Null
  }

  $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"Try { Start-Service -Name 'ProjectP1L0TServer' } Catch {}`""
  $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
  $taskPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
  Register-ScheduledTask -TaskName "ProjectP1L0TServerAutoStart" -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Force | Out-Null

  $adminUrl = "http://127.0.0.1:4280/admin/"
  $desktopName = "Project P1L0T Server Manager.lnk"
  if ($createDesktopShortcut) {
    $desktopTargets = @(
      [Environment]::GetFolderPath("Desktop"),
      "$env:PUBLIC\Desktop"
    ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

    foreach ($desktop in $desktopTargets) {
      $shortcutPath = Join-Path $desktop $desktopName
      New-FileShortcut -ShortcutPath $shortcutPath -TargetPath "cmd.exe" -Arguments "/c `"$openAdminBat`"" -WorkingDirectory (Split-Path -Parent $openAdminBat)
    }
  }

  $startMenuDir = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\Project P1L0T"
  New-Item -Path $startMenuDir -ItemType Directory -Force | Out-Null
  $startMenuShortcut = Join-Path $startMenuDir $desktopName
  New-FileShortcut -ShortcutPath $startMenuShortcut -TargetPath "cmd.exe" -Arguments "/c `"$openAdminBat`"" -WorkingDirectory (Split-Path -Parent $openAdminBat)

  $controlShortcut = Join-Path $startMenuDir "Project P1L0T Server Control.lnk"
  New-FileShortcut -ShortcutPath $controlShortcut -TargetPath "cmd.exe" -Arguments "/k `"$serverControlBat`"" -WorkingDirectory (Split-Path -Parent $serverControlBat)

  $startupDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
  if (Test-Path $startupDir) {
    $startupShortcut = Join-Path $startupDir $desktopName
    New-FileShortcut -ShortcutPath $startupShortcut -TargetPath "cmd.exe" -Arguments "/c `"$openAdminBat`"" -WorkingDirectory (Split-Path -Parent $openAdminBat)
  }

  Set-InstallProgress 98 "Final health verification..."
  if (-not (Wait-Health -MaxChecks 20 -DelayMs 400)) {
    throw "Service installed but health check failed on port 4280."
  }

  if ($launchAfterInstall) {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$openAdminBat`"" -WorkingDirectory (Split-Path -Parent $openAdminBat) | Out-Null
    Write-InstallLog "[P1LOT] Admin UI launcher executed."
  } else {
    Write-InstallLog "[P1LOT] Launch-after-install disabled by user."
  }
  Set-InstallProgress 100 "Install complete."
  Stop-InstallProgress
  Show-Info "Project P1L0T Server installed successfully.`n`nSource branch: $Branch`nService: $serviceName`nAdmin UI: $adminUrl`nAdmin token: $adminToken`nToken file: $($InstallDir)\server_manager\admin_token.txt`nServer manager scripts: $($InstallDir)\server_manager`nDesktop shortcut: $(if ($createDesktopShortcut) {'Yes'} else {'No'})`nLaunch after install: $(if ($launchAfterInstall) {'Yes'} else {'No'})`n`nInstaller log:`n$logFile"
}
catch {
  Stop-InstallProgress
  Write-InstallLog "[P1LOT] Install failed: $($_.Exception.Message)"
  Show-Error "Server setup failed.`n`n$($_.Exception.Message)`n`nInstaller log:`n$logFile"
  exit 1
}
finally {
  Stop-InstallProgress
  try {
    if (Test-Path $tempRoot) { Remove-Item -Path $tempRoot -Recurse -Force }
  } catch {}
  try { Stop-Transcript | Out-Null } catch {}
}
