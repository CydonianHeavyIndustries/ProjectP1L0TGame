param(
  [string]$OutputDir = "F:\projectP1_server_setup"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScript = Join-Path $scriptDir "install_server.ps1"

if (-not (Test-Path $installScript)) {
  throw "Missing installer script: $installScript"
}

if (Test-Path $OutputDir) {
  Remove-Item -Path $OutputDir -Recurse -Force
}
New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

Copy-Item -Path $installScript -Destination (Join-Path $OutputDir "install_server.ps1") -Force

$setupBat = @'
@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set "INSTALLER_ROOT=%~dp0"
if "%INSTALLER_ROOT:~-1%"=="\" set "INSTALLER_ROOT=%INSTALLER_ROOT:~0,-1%"
echo [P1LOT] Starting host-branch server setup...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_server.ps1" -Repo "CydonianHeavyIndustries/ProjectP1L0TGame" -Branch "host" -InstallerRoot "%INSTALLER_ROOT%" %*
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo [P1LOT] Setup failed with code %CODE%.
)
pause
exit /b %CODE%
'@
Set-Content -Path (Join-Path $OutputDir "setup_server.bat") -Value $setupBat -Encoding ASCII

$diagnosticsBat = @'
@echo off
setlocal
cd /d "%~dp0"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "LOG=%~d0\projectp1_server_diagnostics_%COMPUTERNAME%_%TS%.log"
set "INSTALL_A=C:\Program Files\ProjectP1L0T_Server"
set "INSTALL_B=C:\Program Files (x86)\ProjectP1L0T_Server"

echo [P1LOT] Writing diagnostics to: %LOG%
echo Project P1L0T Server Diagnostics > "%LOG%"
echo Generated: %DATE% %TIME%>> "%LOG%"
echo Computer: %COMPUTERNAME%>> "%LOG%"
echo User: %USERNAME%>> "%LOG%"
echo.>> "%LOG%"

echo ===== OS INFO =====>> "%LOG%"
ver >> "%LOG%" 2>&1
systeminfo >> "%LOG%" 2>&1
echo.>> "%LOG%"

echo ===== POWERSHELL / NODE =====>> "%LOG%"
powershell -NoProfile -Command "$PSVersionTable" >> "%LOG%" 2>&1
where node >> "%LOG%" 2>&1
where npm >> "%LOG%" 2>&1
echo.>> "%LOG%"

echo ===== SERVICE: ProjectP1L0TServer =====>> "%LOG%"
sc query ProjectP1L0TServer >> "%LOG%" 2>&1
sc qc ProjectP1L0TServer >> "%LOG%" 2>&1
powershell -NoProfile -Command "try { Get-Service ProjectP1L0TServer | Format-List * } catch { $_ | Out-String }" >> "%LOG%" 2>&1
echo.>> "%LOG%"

echo ===== TASK / FIREWALL =====>> "%LOG%"
schtasks /Query /TN ProjectP1L0TServerAutoStart /V /FO LIST >> "%LOG%" 2>&1
powershell -NoProfile -Command "Get-NetFirewallRule -DisplayName 'ProjectP1L0T Server API' -ErrorAction SilentlyContinue | Format-List *" >> "%LOG%" 2>&1
echo.>> "%LOG%"

echo ===== PORT 4280 =====>> "%LOG%"
netstat -ano | findstr :4280 >> "%LOG%" 2>&1
powershell -NoProfile -Command "try { Invoke-RestMethod -Uri 'http://127.0.0.1:4280/api/health' -TimeoutSec 5 | ConvertTo-Json -Depth 6 } catch { $_.Exception.Message }" >> "%LOG%" 2>&1
echo.>> "%LOG%"

echo ===== INSTALL FOLDERS =====>> "%LOG%"
call :dump_dir "%INSTALL_A%"
call :dump_dir "%INSTALL_B%"
echo.>> "%LOG%"

echo ===== SERVER RUNTIME LOGS =====>> "%LOG%"
call :dump_runtime_logs "%INSTALL_A%"
call :dump_runtime_logs "%INSTALL_B%"
echo.>> "%LOG%"

echo ===== INSTALLER LOGS =====>> "%LOG%"
if exist "%~d0\installer.log" (
  echo --- %~d0\installer.log --- >> "%LOG%"
  type "%~d0\installer.log" >> "%LOG%" 2>&1
) else (
  echo Missing: %~d0\installer.log>> "%LOG%"
)
if exist "C:\ProgramData\ProjectP1L0TServer\logs\installer.log" (
  echo --- C:\ProgramData\ProjectP1L0TServer\logs\installer.log --- >> "%LOG%"
  type "C:\ProgramData\ProjectP1L0TServer\logs\installer.log" >> "%LOG%" 2>&1
) else (
  echo Missing: C:\ProgramData\ProjectP1L0TServer\logs\installer.log>> "%LOG%"
)
echo.>> "%LOG%"

echo ===== CONNECTIVITY =====>> "%LOG%"
powershell -NoProfile -Command "try { (Invoke-WebRequest -Uri 'https://codeload.github.com/CydonianHeavyIndustries/ProjectP1L0TGame/zip/refs/heads/host' -Method Head -UseBasicParsing -TimeoutSec 20).StatusCode } catch { $_.Exception.Message }" >> "%LOG%" 2>&1
echo.>> "%LOG%"

echo [P1LOT] Diagnostics complete.
echo [P1LOT] File: %LOG%
pause
exit /b 0

:dump_dir
set "TARGET=%~1"
if exist "!TARGET!" (
  echo Found: !TARGET!>> "%LOG%"
  dir "!TARGET!" /s /b >> "%LOG%" 2>&1
) else (
  echo Missing: !TARGET!>> "%LOG%"
)
exit /b 0

:dump_runtime_logs
set "ROOT=%~1"
if exist "!ROOT!\apps\server-api\data\server.log" (
  echo --- !ROOT!\apps\server-api\data\server.log --- >> "%LOG%"
  powershell -NoProfile -Command "Get-Content -Path '!ROOT!\apps\server-api\data\server.log' -Tail 200" >> "%LOG%" 2>&1
)
if exist "!ROOT!\apps\server-api\data\service_stdout.log" (
  echo --- !ROOT!\apps\server-api\data\service_stdout.log --- >> "%LOG%"
  powershell -NoProfile -Command "Get-Content -Path '!ROOT!\apps\server-api\data\service_stdout.log' -Tail 200" >> "%LOG%" 2>&1
)
if exist "!ROOT!\apps\server-api\data\service_stderr.log" (
  echo --- !ROOT!\apps\server-api\data\service_stderr.log --- >> "%LOG%"
  powershell -NoProfile -Command "Get-Content -Path '!ROOT!\apps\server-api\data\service_stderr.log' -Tail 200" >> "%LOG%" 2>&1
)
exit /b 0
'@
Set-Content -Path (Join-Path $OutputDir "server_diagnostics.bat") -Value $diagnosticsBat -Encoding ASCII

$readme = @'
Project P1L0T Server Setup (Host Branch)
----------------------------------------

This installer always pulls install content from:
https://github.com/CydonianHeavyIndustries/ProjectP1L0TGame/tree/host

How to run:
1) Copy this folder to target machine.
2) Right-click setup_server.bat and Run as Administrator.
3) Choose install directory.
4) If setup/service fails, run server_diagnostics.bat and send generated log.

Requirements:
- Internet access (for GitHub and Node runtime download if needed).
'@
Set-Content -Path (Join-Path $OutputDir "README.txt") -Value $readme -Encoding ASCII

Write-Host "[P1LOT] Created setup bundle at: $OutputDir"

