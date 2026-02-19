param(
  [string]$Owner = "CydonianHeavyIndustries",
  [string]$Repo = "ProjectP1L0TGame",
  [string]$TargetBranch = "main",
  [string]$Tag,
  [string]$ReleaseName,
  [switch]$PreRelease = $true,
  [switch]$Draft = $false,
  [string]$AssetPath = "tools/game_setup/dist/ProjectP1L0T_Game_Setup.exe",
  [string]$Token,
  [string]$TokenFile,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
  return (Resolve-Path (Join-Path $scriptDir "..")).Path
}

function Get-TokenValue {
  param([string]$ExplicitToken, [string]$ExplicitTokenFile)

  if ($ExplicitToken) { return $ExplicitToken.Trim() }

  $envToken = $env:GITHUB_TOKEN
  if (-not $envToken) { $envToken = $env:GH_TOKEN }
  if (-not $envToken) { $envToken = $env:GITHUB_PAT }
  if ($envToken) { return $envToken.Trim() }

  if ($ExplicitTokenFile) {
    if (-not (Test-Path $ExplicitTokenFile)) {
      throw "Token file not found: $ExplicitTokenFile"
    }
    $fileToken = (Get-Content $ExplicitTokenFile -Raw).Trim()
    if (-not $fileToken) {
      throw "Token file is empty: $ExplicitTokenFile"
    }
    return $fileToken
  }

  throw "Missing GitHub token. Set GITHUB_TOKEN/GH_TOKEN/GITHUB_PAT or pass -Token / -TokenFile."
}

function Resolve-AssetPath {
  param([string]$Root, [string]$PathValue)
  if ([System.IO.Path]::IsPathRooted($PathValue)) {
    return $PathValue
  }
  return (Join-Path $Root $PathValue)
}

function New-TagIfMissing {
  param(
    [string]$ApiBase,
    [hashtable]$Headers,
    [string]$TagName,
    [string]$TargetSha,
    [switch]$DryRunMode
  )

  try {
    Invoke-RestMethod -Method Get -Uri "$ApiBase/git/ref/tags/$TagName" -Headers $Headers | Out-Null
    Write-Host "[P1L0T] Tag exists: $TagName"
    return
  } catch {
    # 404 means tag does not exist yet.
  }

  if ($DryRunMode) {
    Write-Host "[DRY-RUN] Would create tag $TagName at $TargetSha"
    return
  }

  Invoke-RestMethod -Method Post -Uri "$ApiBase/git/refs" -Headers $Headers -Body (@{
    ref = "refs/tags/$TagName"
    sha = $TargetSha
  } | ConvertTo-Json) | Out-Null

  Write-Host "[P1L0T] Created tag: $TagName"
}

function Get-OrCreateRelease {
  param(
    [string]$ApiBase,
    [hashtable]$Headers,
    [string]$TagName,
    [string]$ReleaseTitle,
    [string]$Target,
    [bool]$IsPrerelease,
    [bool]$IsDraft,
    [switch]$DryRunMode
  )

  try {
    $existing = Invoke-RestMethod -Method Get -Uri "$ApiBase/releases/tags/$TagName" -Headers $Headers
    Write-Host "[P1L0T] Using existing release: $($existing.html_url)"
    return $existing
  } catch {
    # if not found, create
  }

  if ($DryRunMode) {
    Write-Host "[DRY-RUN] Would create release for tag: $TagName"
    return @{
      upload_url = "https://uploads.github.com/repos/$Owner/$Repo/releases/0/assets{?name,label}"
      html_url = "https://github.com/$Owner/$Repo/releases/tag/$TagName"
      assets = @()
    }
  }

  $created = Invoke-RestMethod -Method Post -Uri "$ApiBase/releases" -Headers $Headers -Body (@{
    tag_name = $TagName
    target_commitish = $Target
    name = $ReleaseTitle
    draft = $IsDraft
    prerelease = $IsPrerelease
    generate_release_notes = $true
  } | ConvertTo-Json)

  Write-Host "[P1L0T] Created release: $($created.html_url)"
  return $created
}

function Remove-AssetIfExists {
  param(
    [string]$ApiBase,
    [hashtable]$Headers,
    [object]$Release,
    [string]$AssetName,
    [switch]$DryRunMode
  )

  $existing = @($Release.assets) | Where-Object { $_.name -eq $AssetName } | Select-Object -First 1
  if (-not $existing) { return }

  if ($DryRunMode) {
    Write-Host "[DRY-RUN] Would delete existing asset: $AssetName"
    return
  }

  Invoke-RestMethod -Method Delete -Uri "$ApiBase/releases/assets/$($existing.id)" -Headers $Headers | Out-Null
  Write-Host "[P1L0T] Removed existing asset: $AssetName"
}

function Upload-Asset {
  param(
    [hashtable]$Headers,
    [object]$Release,
    [string]$PathValue,
    [switch]$DryRunMode
  )

  $assetName = [System.IO.Path]::GetFileName($PathValue)
  $uploadBase = ($Release.upload_url -replace "\{.*\}$", "").Trim()
  $builder = New-Object System.UriBuilder($uploadBase)
  $builder.Query = "name=$([Uri]::EscapeDataString($assetName))"
  $assetUrl = $builder.Uri.AbsoluteUri

  if ($DryRunMode) {
    Write-Host "[DRY-RUN] Would upload: $PathValue"
    Write-Host "[DRY-RUN] Upload URL: $assetUrl"
    return
  }

  Invoke-WebRequest -Method Post -Uri $assetUrl -Headers @{
    Authorization = $Headers.Authorization
    "User-Agent" = $Headers."User-Agent"
    "Content-Type" = "application/octet-stream"
  } -InFile $PathValue | Out-Null

  Write-Host "[P1L0T] Uploaded asset: $assetName"
}

$repoRoot = Get-RepoRoot
$resolvedAsset = Resolve-AssetPath -Root $repoRoot -PathValue $AssetPath
if (-not (Test-Path $resolvedAsset)) {
  throw "Asset not found: $resolvedAsset"
}

if (-not $Tag) {
  $Tag = "v$([DateTime]::UtcNow.ToString('yyyy.MM.dd.HHmm')).manual"
}
if (-not $ReleaseName) {
  $ReleaseName = "Manual Build $Tag"
}

$tokenValue = Get-TokenValue -ExplicitToken $Token -ExplicitTokenFile $TokenFile
$apiBase = "https://api.github.com/repos/$Owner/$Repo"
$headers = @{
  Authorization = "Bearer $tokenValue"
  "User-Agent" = "ProjectP1L0T-Manual-Release"
  Accept = "application/vnd.github+json"
}

Write-Host "[P1L0T] Repo: $Owner/$Repo"
Write-Host "[P1L0T] Branch: $TargetBranch"
Write-Host "[P1L0T] Tag: $Tag"
Write-Host "[P1L0T] Asset: $resolvedAsset"
if ($DryRun) { Write-Host "[P1L0T] Mode: DRY-RUN" }

$branchRef = Invoke-RestMethod -Method Get -Uri "$apiBase/git/ref/heads/$TargetBranch" -Headers $headers
$targetSha = $branchRef.object.sha
Write-Host "[P1L0T] Branch SHA: $targetSha"

New-TagIfMissing -ApiBase $apiBase -Headers $headers -TagName $Tag -TargetSha $targetSha -DryRunMode:$DryRun
$release = Get-OrCreateRelease -ApiBase $apiBase -Headers $headers -TagName $Tag -ReleaseTitle $ReleaseName -Target $TargetBranch -IsPrerelease $PreRelease.IsPresent -IsDraft $Draft.IsPresent -DryRunMode:$DryRun

$assetName = [System.IO.Path]::GetFileName($resolvedAsset)
Remove-AssetIfExists -ApiBase $apiBase -Headers $headers -Release $release -AssetName $assetName -DryRunMode:$DryRun
Upload-Asset -Headers $headers -Release $release -PathValue $resolvedAsset -DryRunMode:$DryRun

Write-Host "[P1L0T] Done."
if ($release.html_url) {
  Write-Host "[P1L0T] Release URL: $($release.html_url)"
}
