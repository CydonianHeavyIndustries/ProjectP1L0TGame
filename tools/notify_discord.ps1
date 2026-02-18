param(
  [Parameter(Mandatory = $true)]
  [string]$Message,
  [string]$WebhookUrl = $env:DISCORD_WEBHOOK_URL
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($WebhookUrl)) {
  throw "Missing Discord webhook URL. Set DISCORD_WEBHOOK_URL or pass -WebhookUrl."
}

$payload = @{
  username = "P1L0T Build Agent"
  content  = $Message
}

Invoke-RestMethod -Method Post -Uri $WebhookUrl -ContentType "application/json" -Body ($payload | ConvertTo-Json -Compress) | Out-Null
