@echo off
setlocal

set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
set "GODOT="
if not "%GODOT_PATH%"=="" set "GODOT=%GODOT_PATH%"
if "%GODOT%"=="" if exist "%ROOT%\\tools\\godot\\godot.exe" set "GODOT=%ROOT%\\tools\\godot\\godot.exe"
if "%GODOT%"=="" if exist "%ROOT%\\tools\\godot.exe" set "GODOT=%ROOT%\\tools\\godot.exe"
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
set "BUILD_DIR=%ROOT%\\Builds\\Godot"
set "EXE_PATH=%BUILD_DIR%\\ProjectP1L0T.exe"
set "ZIP_PATH=%ROOT%\\Builds\\ProjectP1L0T_Godot.zip"

for /f "tokens=1" %%V in ('"%GODOT%" --headless --version') do set "GODOT_VER=%%V"
for /f "tokens=1-3 delims=." %%a in ("%GODOT_VER%") do (
  set "TEMPLATE_VER=%%a.%%b.%%c"
  set "TEMPLATE_TAG=%%a.%%b-%%c"
)
set "TEMPLATES_DIR=%APPDATA%\\Godot\\export_templates\\%TEMPLATE_VER%"
set "TEMPLATE_MARKER=%TEMPLATES_DIR%\\windows_release_x86_64.exe"

if not exist "%TEMPLATE_MARKER%" (
  echo [P1L0T] Export templates missing. Downloading for %TEMPLATE_TAG%...
  set "TPZ_PATH=%TEMP%\\Godot_v%TEMPLATE_TAG%_export_templates.tpz"
  set "TPZ_ZIP=%TEMP%\\Godot_v%TEMPLATE_TAG%_export_templates.zip"
  call curl.exe -L -o "%%TPZ_PATH%%" "https://github.com/godotengine/godot-builds/releases/download/%TEMPLATE_TAG%/Godot_v%TEMPLATE_TAG%_export_templates.tpz"
  if errorlevel 1 (
    echo [P1L0T] Template download failed.
    exit /b 1
  )
  call copy /y "%%TPZ_PATH%%" "%%TPZ_ZIP%%" >nul
  call powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '%TEMPLATES_DIR%' | Out-Null; Expand-Archive -Path '%%TPZ_ZIP%%' -DestinationPath '%TEMPLATES_DIR%' -Force"
  if errorlevel 1 (
    echo [P1L0T] Template extraction failed.
    exit /b 1
  )
  if not exist "%TEMPLATE_MARKER%" if exist "%TEMPLATES_DIR%\\templates\\windows_release_x86_64.exe" (
    move /y "%TEMPLATES_DIR%\\templates\\*" "%TEMPLATES_DIR%\\" >nul
    rmdir "%TEMPLATES_DIR%\\templates"
  )
)

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
if exist "%ZIP_PATH%" del /f /q "%ZIP_PATH%"

echo [P1L0T] Importing assets...
"%GODOT%" --headless --path "%ROOT%" --import
if errorlevel 1 (
  echo [P1L0T] Import step failed - continuing to export.
)

echo [P1L0T] Exporting Godot build...
"%GODOT%" --headless --path "%ROOT%" --export-release "%EXPORT_PRESET%" "%EXE_PATH%"
set "EXPORT_CODE=%errorlevel%"
if not "%EXPORT_CODE%"=="0" (
  echo [P1L0T] Export failed.
  exit /b 1
)

echo [P1L0T] Zipping build...
powershell -NoProfile -Command "if (Test-Path '%ZIP_PATH%') { Remove-Item '%ZIP_PATH%' -Force }; Compress-Archive -Path '%BUILD_DIR%\\*' -DestinationPath '%ZIP_PATH%'"
set "ZIP_CODE=%errorlevel%"
if not "%ZIP_CODE%"=="0" (
  echo [P1L0T] Zip failed.
  exit /b 1
)

echo [P1L0T] Done: %ZIP_PATH%
exit /b 0
