@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "INSTALLER_ROOT=%~dp0"
if "%INSTALLER_ROOT:~-1%"=="\" set "INSTALLER_ROOT=%INSTALLER_ROOT:~0,-1%"

echo [P1LOT] Starting server setup from GitHub host branch...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_server.ps1" -Repo "CydonianHeavyIndustries/ProjectP1L0TGame" -Branch "host" -InstallerRoot "%INSTALLER_ROOT%" %*
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo [P1LOT] Setup failed with code %CODE%.
)
pause
exit /b %CODE%
