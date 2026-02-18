@echo off
setlocal

REM Edit MESSAGE before running, or pass a message as arguments.
set "WEBHOOK_URL=https://discord.com/api/webhooks/1458500967875088436/sCnQ7EidxfwsTsFuSb-N_WxID9Ktf7FdqNwxpBBvXKGES6QZBfmctJWwP31okzr_8oVq"
set "MESSAGE=[Project P1L0T] Task batch complete. Update this message before sending."

if not "%~1"=="" (
  set "MESSAGE=%*"
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$payload = @{ username = 'P1L0T Build Agent'; content = $env:MESSAGE } | ConvertTo-Json -Compress; Invoke-RestMethod -Method Post -Uri $env:WEBHOOK_URL -ContentType 'application/json' -Body $payload | Out-Null"

if errorlevel 1 (
  echo Discord notification failed.
  exit /b 1
)

echo Discord notification sent.
exit /b 0
