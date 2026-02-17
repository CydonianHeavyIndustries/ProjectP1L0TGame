param(
  [string]$OutputExe = "F:\projectP1_server_setup.exe",
  [string]$NodeExe = ""
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..\..")
$serverRoot = Join-Path $repoRoot "services\server-api"
$websiteRoot = Join-Path $repoRoot "website\cydonianheavyindustries.inc"
$installScript = Join-Path $scriptDir "install_server.ps1"
$serverManagerProject = Join-Path $repoRoot "tools\server_manager_app\ProjectP1ServerManager.csproj"
$buildRoot = Join-Path $env:TEMP "p1lot_server_setup_build"
$staging = Join-Path $buildRoot "staging"
$payload = Join-Path $staging "payload"
$payloadZip = Join-Path $staging "payload.zip"
$bootstrapRoot = Join-Path $buildRoot "bootstrap"
$bootstrapAssets = Join-Path $bootstrapRoot "Assets"
$publishDir = Join-Path $buildRoot "publish"
$serverManagerPublishDir = Join-Path $buildRoot "server_manager_publish"
$intermediateExe = Join-Path $publishDir "projectP1_server_setup.exe"

if (-not (Test-Path $serverRoot)) {
  throw "Missing server source: $serverRoot"
}
if (-not (Test-Path $installScript)) {
  throw "Missing installer script: $installScript"
}
if (-not (Test-Path $serverManagerProject)) {
  throw "Missing server manager project: $serverManagerProject"
}

if ([string]::IsNullOrWhiteSpace($NodeExe)) {
  $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
  if (-not $nodeCmd) {
    throw "node.exe not found. Install Node.js or pass -NodeExe."
  }
  $NodeExe = $nodeCmd.Source
}
if (-not (Test-Path $NodeExe)) {
  throw "node.exe not found at: $NodeExe"
}

$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCmd) {
  throw "npm not found. Install Node.js with npm."
}

$dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnetCmd) {
  throw "dotnet CLI not found. Install .NET SDK 8+."
}

if (Test-Path $buildRoot) {
  Remove-Item -Path $buildRoot -Recurse -Force
}
New-Item -Path $payload -ItemType Directory -Force | Out-Null
New-Item -Path $bootstrapAssets -ItemType Directory -Force | Out-Null

Write-Host "[P1LOT] Installing backend dependencies..."
Push-Location $serverRoot
try {
  & npm install --omit=dev --no-audit --no-fund | Out-Null
} finally {
  Pop-Location
}

Write-Host "[P1LOT] Preparing payload..."
Copy-Item -Path $NodeExe -Destination (Join-Path $payload "node.exe") -Force
Copy-Item -Path $serverRoot -Destination (Join-Path $payload "services\server-api") -Recurse -Force
if (Test-Path $websiteRoot) {
  Copy-Item -Path $websiteRoot -Destination (Join-Path $payload "website\cydonianheavyindustries.inc") -Recurse -Force
}

Write-Host "[P1LOT] Building server manager UI..."
& dotnet publish $serverManagerProject -c Release -r win-x64 -o $serverManagerPublishDir -p:PublishSingleFile=true -p:SelfContained=true -p:EnableCompressionInSingleFile=true -p:DebugType=None -p:DebugSymbols=false | Out-Null
$serverManagerExe = Join-Path $serverManagerPublishDir "ProjectP1ServerManager.exe"
if (-not (Test-Path $serverManagerExe)) {
  throw "Server manager build failed: $serverManagerExe not found."
}
New-Item -Path (Join-Path $payload "server_manager") -ItemType Directory -Force | Out-Null
Copy-Item -Path $serverManagerExe -Destination (Join-Path $payload "server_manager\ProjectP1ServerManager.exe") -Force

# Ship a clean runtime data folder; generated files are created on first launch.
$runtimeData = Join-Path $payload "services\server-api\data"
if (Test-Path $runtimeData) {
  Remove-Item -Path $runtimeData -Recurse -Force
}
New-Item -Path (Join-Path $runtimeData "user_files") -ItemType Directory -Force | Out-Null

Write-Host "[P1LOT] Compressing payload..."
Compress-Archive -Path (Join-Path $payload "*") -DestinationPath $payloadZip -CompressionLevel Optimal -Force
Copy-Item -Path $payloadZip -Destination (Join-Path $bootstrapAssets "payload.zip") -Force
Copy-Item -Path $installScript -Destination (Join-Path $bootstrapAssets "install_server.ps1") -Force

$projectFile = Join-Path $bootstrapRoot "projectP1_server_setup.csproj"
$programFile = Join-Path $bootstrapRoot "Program.cs"

$csproj = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <AssemblyName>projectP1_server_setup</AssemblyName>
  </PropertyGroup>
  <ItemGroup>
    <EmbeddedResource Include="Assets\payload.zip" LogicalName="payload.zip" />
    <EmbeddedResource Include="Assets\install_server.ps1" LogicalName="install_server.ps1" />
  </ItemGroup>
</Project>
"@

$program = @"
using System.Diagnostics;
using System.Reflection;

try
{
    var assembly = Assembly.GetExecutingAssembly();
    var tempRoot = Path.Combine(Path.GetTempPath(), "ProjectP1L0T_ServerSetup_" + Guid.NewGuid().ToString("N"));
    Directory.CreateDirectory(tempRoot);

    ExtractResource(assembly, "payload.zip", Path.Combine(tempRoot, "payload.zip"));
    ExtractResource(assembly, "install_server.ps1", Path.Combine(tempRoot, "install_server.ps1"));

    var scriptPath = Path.Combine(tempRoot, "install_server.ps1");
    var process = Process.Start(new ProcessStartInfo
    {
        FileName = "powershell.exe",
        Arguments = "-NoProfile -ExecutionPolicy Bypass -STA -File \"" + scriptPath + "\"",
        WorkingDirectory = tempRoot,
        UseShellExecute = true
    });

    if (process is null)
    {
        Console.Error.WriteLine("Failed to start install_server.ps1");
        return 1;
    }

    process.WaitForExit();
    return process.ExitCode;
}
catch (Exception ex)
{
    Console.Error.WriteLine(ex.ToString());
    return 1;
}

static void ExtractResource(Assembly assembly, string resourceName, string destination)
{
    using var stream = assembly.GetManifestResourceStream(resourceName)
        ?? throw new InvalidOperationException("Missing resource: " + resourceName);
    using var file = File.Create(destination);
    stream.CopyTo(file);
}
"@

Set-Content -Path $projectFile -Value $csproj -Encoding UTF8
Set-Content -Path $programFile -Value $program -Encoding UTF8

Write-Host "[P1LOT] Building one-file installer..."
& dotnet publish $projectFile -c Release -r win-x64 -o $publishDir -p:PublishSingleFile=true -p:SelfContained=true -p:EnableCompressionInSingleFile=true -p:DebugType=None -p:DebugSymbols=false | Out-Null

if (-not (Test-Path $intermediateExe)) {
  throw "Installer was not created: $intermediateExe"
}

$targetDir = Split-Path -Parent $OutputExe
if (-not (Test-Path $targetDir)) {
  New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
}
if (Test-Path $OutputExe) {
  Remove-Item -Path $OutputExe -Force
}

Copy-Item -Path $intermediateExe -Destination $OutputExe -Force
$item = Get-Item $OutputExe
Write-Host "[P1LOT] Created $($item.FullName) ($([math]::Round($item.Length / 1MB, 2)) MB)"
