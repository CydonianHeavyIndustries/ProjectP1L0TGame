param()

$ErrorActionPreference = "Stop"

$serverDir = Resolve-Path (Join-Path $PSScriptRoot "..\..\apps\server-api")
$launcherDir = Resolve-Path (Join-Path $PSScriptRoot "..\..\apps\launcher")
$electronCmd = Resolve-Path (Join-Path $launcherDir "node_modules\.bin\electron.cmd")
$nodeCmd = Get-Command node -ErrorAction Stop

$serverProc = Start-Process -FilePath $nodeCmd.Source -ArgumentList "server.js" -WorkingDirectory $serverDir -WindowStyle Hidden -PassThru

$ok = $false
for ($i = 0; $i -lt 20; $i++) {
  Start-Sleep -Milliseconds 300
  try {
    Invoke-RestMethod -Uri "http://127.0.0.1:4280/api/health" -TimeoutSec 1 | Out-Null
    $ok = $true
    break
  } catch {
  }
}

if (-not $ok) {
  throw "Server did not start on 127.0.0.1:4280. PID=$($serverProc.Id)"
}

$previewScript = Join-Path $env:TEMP "p1lot_server_manager_preview.cjs"
@'
const { app, BrowserWindow } = require('electron');

function createWindow() {
  const win = new BrowserWindow({
    width: 1400,
    height: 900,
    autoHideMenuBar: true,
    backgroundColor: '#071019',
    webPreferences: {
      contextIsolation: true,
      sandbox: true,
      devTools: true,
    },
  });
  win.loadURL('http://127.0.0.1:4280/admin/');
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => app.quit());
'@ | Set-Content -Path $previewScript -Encoding UTF8

$electronProc = Start-Process -FilePath $electronCmd -ArgumentList "`"$previewScript`"" -WorkingDirectory $launcherDir -PassThru

Write-Output "SERVER_PID=$($serverProc.Id)"
Write-Output "ELECTRON_PID=$($electronProc.Id)"
Write-Output "SCRIPT=$previewScript"

