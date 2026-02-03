@echo off
setlocal

if "%GITHUB_TOKEN%"=="" if "%GH_TOKEN%"=="" if "%GITHUB_PAT%"=="" (
  echo Missing GitHub token.
  echo Set GITHUB_TOKEN (recommended) or GH_TOKEN or GITHUB_PAT, then re-run.
  echo Example:
  echo   set GITHUB_TOKEN=YOUR_PAT
  exit /b 1
)

set SCRIPT_DIR=%~dp0
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%publish_release.ps1" %*

endlocal
