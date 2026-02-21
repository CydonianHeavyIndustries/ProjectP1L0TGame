@echo off
setlocal
set "OUT=%~1"
if "%OUT%"=="" set "OUT=F:\projectP1_server_setup.exe"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_server_setup_exe.ps1" -OutputExe "%OUT%"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo.
  echo [P1LOT] Failed to build server setup exe. Code %CODE%.
  pause
)
exit /b %CODE%

