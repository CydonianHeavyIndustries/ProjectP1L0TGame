param(
  [string]$InstallDir = ""
)

$ErrorActionPreference = "Stop"

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

function Try-SyncFromHostBranch([string]$InstallDir) {
  $repo = "CydonianHeavyIndustries/ProjectP1L0TGame"
  $branches = @("host", "Host")
  $tempRoot = Join-Path $env:TEMP ("ProjectP1L0T_HostSync_" + [guid]::NewGuid().ToString("N"))
  New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null

  try {
    foreach ($branch in $branches) {
      try {
        $zipPath = Join-Path $tempRoot "$branch.zip"
        $extractDir = Join-Path $tempRoot "$branch.extract"
        $url = "https://codeload.github.com/$repo/zip/refs/heads/$branch"
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -TimeoutSec 20
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

        $rootDir = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
        if (-not $rootDir) {
          continue
        }

        $serverSrc = Join-Path $rootDir.FullName "services\server-api"
        $websiteSrc = Join-Path $rootDir.FullName "website\cydonianheavyindustries.inc"
        $serverDest = Join-Path $InstallDir "services\server-api"
        $websiteDest = Join-Path $InstallDir "website\cydonianheavyindustries.inc"

        if (Test-Path $serverSrc) {
          Copy-Item -Path (Join-Path $serverSrc "*") -Destination $serverDest -Recurse -Force
        }
        if (Test-Path $websiteSrc) {
          New-Item -Path $websiteDest -ItemType Directory -Force | Out-Null
          Copy-Item -Path (Join-Path $websiteSrc "*") -Destination $websiteDest -Recurse -Force
        }
        return @{
          Success = $true
          Branch = $branch
        }
      }
      catch {
        continue
      }
    }

    return @{
      Success = $false
      Branch = ""
    }
  }
  finally {
    try {
      if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force
      }
    }
    catch {}
  }
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

if (-not (Test-Admin)) {
  $args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-File", "`"$PSCommandPath`"")
  if (-not [string]::IsNullOrWhiteSpace($InstallDir)) {
    $args += "-InstallDir"
    $args += "`"$InstallDir`""
  }
  Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs | Out-Null
  exit 0
}

$setupRoot = $PSScriptRoot
$programDataRoot = Join-Path $env:ProgramData "ProjectP1L0TServer"
$logDir = Join-Path $programDataRoot "logs"
$logFile = Join-Path $logDir "installer.log"
New-Item -Path $logDir -ItemType Directory -Force | Out-Null

Start-Transcript -Path $logFile -Append | Out-Null
try {
  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  if ([string]::IsNullOrWhiteSpace($InstallDir)) {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Choose install directory for Project P1L0T Server"
    $dialog.SelectedPath = "$env:ProgramFiles\ProjectP1L0T_Server"
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
      throw "Install cancelled."
    }
    $InstallDir = $dialog.SelectedPath
  }

  $payloadRoot = Join-Path $setupRoot "payload"
  $payloadZip = Join-Path $setupRoot "payload.zip"
  if (-not (Test-Path $payloadRoot) -and (Test-Path $payloadZip)) {
    Expand-Archive -LiteralPath $payloadZip -DestinationPath $setupRoot -Force
  }
  if (-not (Test-Path $payloadRoot)) {
    throw "Payload not found."
  }

  New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
  Copy-Item -Path (Join-Path $payloadRoot "*") -Destination $InstallDir -Recurse -Force

  $sync = Try-SyncFromHostBranch -InstallDir $InstallDir
  if ($sync.Success) {
    Write-Host "[P1LOT] Synced latest server content from origin branch '$($sync.Branch)'."
  } else {
    Write-Host "[P1LOT] Host branch sync unavailable. Using packaged payload content."
  }

  $enableMaxHardware = Ask-YesNo "Enable MAX hardware profile?`n`nYES = use all available hardware settings for this server profile.`nNO = recommended profile."
  $configDir = Join-Path $InstallDir "services\server-api\data"
  $configPath = Join-Path $configDir "server.config.json"
  New-Item -Path $configDir -ItemType Directory -Force | Out-Null
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
  $existingConfig | ConvertTo-Json -Depth 8 | Set-Content -Path $configPath -Encoding UTF8

  $serviceName = "ProjectP1L0TServer"
  $nodeExe = Join-Path $InstallDir "node.exe"
  $serverJs = Join-Path $InstallDir "services\server-api\server.js"
  $serverManagerExe = Join-Path $InstallDir "server_manager\ProjectP1ServerManager.exe"
  if (-not (Test-Path $nodeExe)) { throw "node.exe missing at $nodeExe" }
  if (-not (Test-Path $serverJs)) { throw "server.js missing at $serverJs" }
  if (-not (Test-Path $serverManagerExe)) { throw "server manager missing at $serverManagerExe" }

  $existing = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
  if ($existing) {
    try { Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue } catch {}
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 2
  }

  $binPath = "`"$nodeExe`" `"$serverJs`""
  New-Service -Name $serviceName -BinaryPathName $binPath -DisplayName "Project P1L0T Server" -Description "Project P1L0T backend server API and admin UI." -StartupType Automatic | Out-Null
  Start-Service -Name $serviceName

  if (-not (Get-NetFirewallRule -DisplayName "ProjectP1L0T Server API" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "ProjectP1L0T Server API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 4280 | Out-Null
  }

  $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"Try { Start-Service -Name 'ProjectP1L0TServer' } Catch {}`""
  $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
  $taskPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
  Register-ScheduledTask -TaskName "ProjectP1L0TServerAutoStart" -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Force | Out-Null

  $adminUrl = "http://127.0.0.1:4280/admin/"
  $desktopName = "Project P1L0T Server Manager.lnk"
  $desktopTargets = @(
    [Environment]::GetFolderPath("Desktop"),
    "$env:PUBLIC\Desktop"
  ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

  foreach ($desktop in $desktopTargets) {
    $shortcutPath = Join-Path $desktop $desktopName
    New-FileShortcut -ShortcutPath $shortcutPath -TargetPath $serverManagerExe -WorkingDirectory (Split-Path -Parent $serverManagerExe)
  }

  $startMenuDir = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\Project P1L0T"
  New-Item -Path $startMenuDir -ItemType Directory -Force | Out-Null
  $startMenuShortcut = Join-Path $startMenuDir $desktopName
  New-FileShortcut -ShortcutPath $startMenuShortcut -TargetPath $serverManagerExe -WorkingDirectory (Split-Path -Parent $serverManagerExe)

  $startupDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
  if (Test-Path $startupDir) {
    $startupShortcut = Join-Path $startupDir $desktopName
    New-FileShortcut -ShortcutPath $startupShortcut -TargetPath $serverManagerExe -WorkingDirectory (Split-Path -Parent $serverManagerExe)
  }

  Start-Sleep -Seconds 2
  try {
    $health = Invoke-RestMethod -Uri "http://127.0.0.1:4280/api/health" -Method Get -TimeoutSec 5
    if (-not $health.ok) {
      throw "Health endpoint returned invalid response."
    }
  } catch {
    throw "Service installed but health check failed: $($_.Exception.Message)"
  }

  Start-Process $serverManagerExe | Out-Null
  Show-Info "Project P1L0T Server installed successfully.`n`nService: $serviceName`nAdmin UI: $adminUrl`nServer Manager: $serverManagerExe`nDesktop and startup shortcuts created.`n`nInstaller log:`n$logFile"
}
catch {
  Show-Error "Server setup failed.`n`n$($_.Exception.Message)`n`nInstaller log:`n$logFile"
  exit 1
}
finally {
  try { Stop-Transcript | Out-Null } catch {}
}
