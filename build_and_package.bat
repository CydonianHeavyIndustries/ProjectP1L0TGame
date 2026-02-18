@echo off
setlocal

set "SCRIPT=%~dp0apps\game-godot\build_and_package.bat"
if not exist "%SCRIPT%" (
  echo [P1L0T] ERROR: Missing game packager at %SCRIPT%
  if not defined P1LOT_NO_PAUSE pause
  exit /b 1
)

call "%SCRIPT%" %*
set "CODE=%ERRORLEVEL%"
if not defined P1LOT_NO_PAUSE pause
endlocal & exit /b %CODE%
