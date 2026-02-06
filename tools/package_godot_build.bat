@echo off
setlocal enabledelayedexpansion

set "ROOT=%~dp0.."
set "GODOT="
if not "%GODOT_PATH%"=="" set "GODOT=%GODOT_PATH%"
if "%GODOT%"=="" if exist "%ROOT%tools\\godot\\godot.exe" set "GODOT=%ROOT%tools\\godot\\godot.exe"
if "%GODOT%"=="" if exist "%ROOT%tools\\godot.exe" set "GODOT=%ROOT%tools\\godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files\\Godot\\godot.exe" set "GODOT=C:\\Program Files\\Godot\\godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files\\Godot\\Godot.exe" set "GODOT=C:\\Program Files\\Godot\\Godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files\\Godot Engine\\godot.exe" set "GODOT=C:\\Program Files\\Godot Engine\\godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files\\Godot4\\godot.exe" set "GODOT=C:\\Program Files\\Godot4\\godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files (x86)\\Godot\\godot.exe" set "GODOT=C:\\Program Files (x86)\\Godot\\godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files (x86)\\Godot Engine\\godot.exe" set "GODOT=C:\\Program Files (x86)\\Godot Engine\\godot.exe"
if "%GODOT%"=="" if exist "C:\\Program Files (x86)\\Godot4\\godot.exe" set "GODOT=C:\\Program Files (x86)\\Godot4\\godot.exe"
if "%GODOT%"=="" (
  where godot >nul 2>&1
  if not errorlevel 1 set "GODOT=godot"
)
if "%GODOT%"=="" (
  echo [P1L0T] Godot executable not found.
  echo [P1L0T] Set GODOT_PATH or place godot.exe at tools\\godot\\godot.exe.
  exit /b 1
)

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
