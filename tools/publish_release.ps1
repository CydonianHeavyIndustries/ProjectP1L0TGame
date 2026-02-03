param(
  [string]$ZipPath,
  [string]$Tag,
  [string]$Owner = "CydonianHeavyIndustries",
  [string]$Repo = "ProjectP1L0TGame"
)

$ErrorActionPreference = "Stop"

$token = $env:GITHUB_TOKEN
if (-not $token) { $token = $env:GH_TOKEN }
if (-not $token) { $token = $env:GITHUB_PAT }

if (-not $token) {
  Write-Error "Missing GitHub token. Set GITHUB_TOKEN, GH_TOKEN, or GITHUB_PAT with repo scope."
  exit 1
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

if (-not $ZipPath) {
  $zipDir = Join-Path $repoRoot "Builds\Zips"
  $latestZip = Get-ChildItem -Path $zipDir -Filter "*.zip" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $latestZip) {
    Write-Error "No zip builds found in $zipDir. Run tools/package_dev_build.ps1 -Zip first."
    exit 1
  }
  $ZipPath = $latestZip.FullName
}

if (-not (Test-Path $ZipPath)) {
  Write-Error "Zip not found: $ZipPath"
  exit 1
}

if (-not $Tag) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($ZipPath)
  if ($name -match "(\\d{4}\\.\\d{2}\\.\\d{2}\\.\\d{4})") {
    $Tag = "v$($Matches[1])"
  } else {
    $Tag = "v$([DateTime]::UtcNow.ToString('yyyy.MM.dd.HHmm'))"
  }
}

$apiBase = "https://api.github.com/repos/$Owner/$Repo"
$headers = @{
  "Authorization" = "Bearer $token"
  "User-Agent" = "ProjectP1L0T-Release"
  "Accept" = "application/vnd.github+json"
}

Write-Host "Preparing release $Tag for $Owner/$Repo"

$release = $null
try {
  $release = Invoke-RestMethod -Method Post -Uri "$apiBase/releases" -Headers $headers -Body (@{
    tag_name = $Tag
    name = "Auto Build $Tag"
    prerelease = $true
    draft = $false
    generate_release_notes = $true
  } | ConvertTo-Json)
} catch {
  if ($_.Exception.Response.StatusCode.value__ -ne 422) {
    throw
  }
  Write-Host "Release already exists for $Tag. Fetching existing release..."
  $release = Invoke-RestMethod -Method Get -Uri "$apiBase/releases/tags/$Tag" -Headers $headers
}

if (-not $release) {
  Write-Error "Failed to create or fetch release for tag $Tag"
  exit 1
}

$assetName = [System.IO.Path]::GetFileName($ZipPath)
$uploadUrl = $release.upload_url -replace "\\{\\?name,label\\}$", ""
$assetUrl = "$uploadUrl?name=$([Uri]::EscapeDataString($assetName))"

Write-Host "Uploading asset: $assetName"
Invoke-WebRequest -Method Post -Uri $assetUrl -Headers @{
  "Authorization" = "Bearer $token"
  "User-Agent" = "ProjectP1L0T-Release"
  "Content-Type" = "application/zip"
} -InFile $ZipPath | Out-Null

Write-Host "Release published: $($release.html_url)"
