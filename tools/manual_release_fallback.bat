@echo off
setlocal
cd /d "%~dp0.."

set "DEFAULT_ASSET=tools\game_setup\dist\ProjectP1L0T_Game_Setup.exe"
set "TOKEN_FILE=E:\OneDrive\Desktop\github token.txt"

if not exist "%DEFAULT_ASSET%" (
  echo [P1L0T] Missing asset: %DEFAULT_ASSET%
  echo Build it first: tools\game_setup\build_game_setup_exe.bat
  exit /b 1
)

if exist "%TOKEN_FILE%" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "tools\manual_release_fallback.ps1" -AssetPath "%DEFAULT_ASSET%" -TargetBranch "main" -TokenFile "%TOKEN_FILE%" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "tools\manual_release_fallback.ps1" -AssetPath "%DEFAULT_ASSET%" -TargetBranch "main" %*
)

set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo [P1L0T] Manual release fallback failed with code %CODE%.
  pause
  exit /b %CODE%
)

echo [P1L0T] Manual release fallback complete.
exit /b 0
