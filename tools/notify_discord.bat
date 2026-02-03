@echo off
setlocal enableextensions enabledelayedexpansion

set "WEBHOOK_URL=https://discord.com/api/webhooks/1458500967875088436/sCnQ7EidxfwsTsFuSb-N_WxID9Ktf7FdqNwxpBBvXKGES6QZBfmctJWwP31okzr_8oVq"

set "MESSAGE=%*"
set "MESSAGE=!MESSAGE:"=!"
if "!MESSAGE!"=="" set "MESSAGE=Freya: Task complete."

set "DISCORD_CONTENT=!MESSAGE!"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$body = @{ content = $env:DISCORD_CONTENT }; Invoke-RestMethod -Uri '%WEBHOOK_URL%' -Method Post -Body ($body | ConvertTo-Json) -ContentType 'application/json'"

endlocal
