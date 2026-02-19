@echo off
setlocal
cd /d "%~dp0"

set "OUT_DIR=%~dp0dist"
if exist "%OUT_DIR%" rmdir /s /q "%OUT_DIR%"

echo [P1L0T] Building ProjectP1L0T_Game_Setup.exe ...
dotnet publish GameRepoSetup.csproj -c Release -r win-x64 ^
  -p:PublishSingleFile=true ^
  -p:SelfContained=true ^
  -p:PublishTrimmed=false ^
  -o "%OUT_DIR%"
if errorlevel 1 (
  echo [P1L0T] Build failed.
  exit /b 1
)

if exist "%OUT_DIR%\ProjectP1L0T_Game_Setup.exe" (
  echo [P1L0T] Done: %OUT_DIR%\ProjectP1L0T_Game_Setup.exe
) else (
  echo [P1L0T] ERROR: Output exe not found.
  exit /b 1
)

exit /b 0
