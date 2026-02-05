@echo off
setlocal

set "ROOT=%~dp0"
set "PACKAGER=%ROOT%tools\package_godot_build.bat"

if not exist "%PACKAGER%" (
  echo ERROR: Godot packaging script not found: %PACKAGER%
  exit /b 1
)

call "%PACKAGER%" %*
if errorlevel 1 exit /b %errorlevel%

endlocal
