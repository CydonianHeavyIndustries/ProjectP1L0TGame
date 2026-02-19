@echo off
setlocal
cd /d "%~dp0..\.."
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\server_setup\launch_server_manager_preview.ps1"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo [P1LOT] Failed to launch Electron server manager preview.
  pause
)
exit /b %CODE%
