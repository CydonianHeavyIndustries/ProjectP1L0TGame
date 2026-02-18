@echo off
setlocal

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "PACKAGER=%ROOT%\..\..\tools\package_godot_build.bat"
for %%I in ("%PACKAGER%") do set "PACKAGER=%%~fI"

echo [P1L0T] Working dir: %ROOT%
if not exist "%PACKAGER%" (
  echo [P1L0T] ERROR: Godot packaging script not found: %PACKAGER%
  echo.
  if not defined P1LOT_NO_PAUSE pause
  exit /b 1
)

call "%PACKAGER%" "%ROOT%" %*
set "EXIT_CODE=%errorlevel%"

echo.
if %EXIT_CODE% neq 0 (
  echo [P1L0T] Build failed with code %EXIT_CODE%.
) else (
  echo [P1L0T] Build completed successfully.
)
echo.
if not defined P1LOT_NO_PAUSE pause
endlocal & exit /b %EXIT_CODE%
