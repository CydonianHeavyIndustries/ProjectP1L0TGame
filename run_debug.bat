@echo off
setlocal

set ELECTRON_ENABLE_LOGGING=1
set ELECTRON_ENABLE_STACK_DUMPING=1

cd /d "%~dp0Launcher"
if not exist "node_modules" (
  echo Installing dependencies...
  call npm install
)
echo Starting launcher (debug)...
call npm run dev

echo.
echo Launcher exited with code %errorlevel%.
pause
endlocal
