@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_server_setup.ps1" %*
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo Build failed with code %CODE%.
  pause
)
exit /b %CODE%

