@echo off
setlocal

REM Read GitHub token from local file (do not echo or log it)
set "TOKEN_FILE=E:\OneDrive\Desktop\github token.txt"
set "REPO_URL=github.com/CydonianHeavyIndustries/ProjectP1L0TGame.git"

set GIT_TERMINAL_PROMPT=0

if not exist "%TOKEN_FILE%" (
  echo ERROR: Token file not found: %TOKEN_FILE%
  exit /b 1
)

set /p GITHUB_TOKEN=<"%TOKEN_FILE%"
if "%GITHUB_TOKEN%"=="" (
  echo ERROR: Token file is empty.
  exit /b 1
)

git push https://%GITHUB_TOKEN%@%REPO_URL% master

endlocal
