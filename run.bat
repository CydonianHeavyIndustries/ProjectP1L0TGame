@echo off
setlocal

set ELECTRON_ENABLE_LOGGING=1
set ELECTRON_ENABLE_STACK_DUMPING=1
set ELECTRON_RUN_AS_NODE=

cd /d "%~dp0Launcher"
if errorlevel 1 (
  echo Failed to enter Launcher directory.
  pause
  exit /b 1
)

for /f %%P in ('powershell -NoProfile -Command "(Get-NetTCPConnection -LocalPort 5173 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty OwningProcess)"') do set "P1LOT_VITE_PID=%%P"
if defined P1LOT_VITE_PID (
  echo Port 5173 in use by PID %P1LOT_VITE_PID%. Stopping it...
  powershell -NoProfile -Command "Stop-Process -Id %P1LOT_VITE_PID% -Force"
  if errorlevel 1 (
    echo Failed to stop PID %P1LOT_VITE_PID%. Close the app using port 5173 and try again.
    pause
    exit /b 1
  )
)

if not exist "node_modules" (
  echo Installing dependencies...
  call npm install
  if errorlevel 1 goto :fail
)
echo Starting launcher...
call npm run dev

echo.
echo Launcher exited with code %errorlevel%.
pause
endlocal
exit /b %errorlevel%

:fail
echo.
echo Launcher failed with code %errorlevel%.
pause
endlocal
exit /b %errorlevel%
