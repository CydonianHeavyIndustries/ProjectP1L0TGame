@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_server_setup.ps1" %*
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo [P1LOT] Failed to build server setup bundle. Code %CODE%.
  pause
)
exit /b %CODE%
