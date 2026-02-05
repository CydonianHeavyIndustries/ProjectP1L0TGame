@echo off
setlocal enabledelayedexpansion

set "ROOT=%~dp0.."
set "GODOT=%GODOT_PATH%"
if "%GODOT%"=="" set "GODOT=godot"

set "EXPORT_PRESET=Windows Desktop"
set "BUILD_DIR=%ROOT%\Builds\Godot"
set "EXE_PATH=%BUILD_DIR%\ProjectP1L0T.exe"
set "ZIP_PATH=%ROOT%\Builds\ProjectP1L0T_Godot.zip"

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo [P1L0T] Importing assets...
"%GODOT%" --headless --path "%ROOT%" --import
if errorlevel 1 (
  echo [P1L0T] Import step failed (continuing to export).
)

echo [P1L0T] Exporting Godot build...
"%GODOT%" --headless --path "%ROOT%" --export-release "%EXPORT_PRESET%" "%EXE_PATH%"
if errorlevel 1 (
  echo [P1L0T] Export failed.
  exit /b 1
)

echo [P1L0T] Zipping build...
powershell -NoProfile -Command "if (Test-Path '%ZIP_PATH%') { Remove-Item '%ZIP_PATH%' -Force }; Compress-Archive -Path '%BUILD_DIR%\\*' -DestinationPath '%ZIP_PATH%'"
if errorlevel 1 (
  echo [P1L0T] Zip failed.
  exit /b 1
)

echo [P1L0T] Done: %ZIP_PATH%
exit /b 0
