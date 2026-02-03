using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

static string? GetToken()
{
    return Environment.GetEnvironmentVariable("GITHUB_TOKEN")
        ?? Environment.GetEnvironmentVariable("GH_TOKEN")
        ?? Environment.GetEnvironmentVariable("GITHUB_PAT");
}

static string FindRepoRoot()
{
    var baseDir = AppContext.BaseDirectory;
    var dir = new DirectoryInfo(baseDir);
    while (dir != null)
    {
        if (Directory.Exists(Path.Combine(dir.FullName, ".git")) ||
            File.Exists(Path.Combine(dir.FullName, "ProjectP1L0T.uproject")))
        {
            return dir.FullName;
        }
        dir = dir.Parent;
    }
    return Directory.GetCurrentDirectory();
}

static string? FindLatestZip(string repoRoot)
{
    var zipDir = Path.Combine(repoRoot, "Builds", "Zips");
    if (!Directory.Exists(zipDir)) return null;
    var latest = new DirectoryInfo(zipDir).GetFiles("*.zip")
        .OrderByDescending(f => f.LastWriteTimeUtc)
        .FirstOrDefault();
    return latest?.FullName;
}

static string? ReadVersionFile(string repoRoot)
{
    var versionPath = Path.Combine(repoRoot, "VERSION");
    if (!File.Exists(versionPath)) return null;
    var text = File.ReadAllText(versionPath).Trim();
    return string.IsNullOrWhiteSpace(text) ? null : text;
}

static string DeriveTag(string zipPath, string? version)
{
    if (!string.IsNullOrWhiteSpace(version))
    {
        return $"v{version}";
    }

    var name = Path.GetFileNameWithoutExtension(zipPath);
    var match = System.Text.RegularExpressions.Regex.Match(name, @"(\\d+\\.\\d+\\.\\d+)");
    return match.Success ? $"v{match.Groups[1].Value}" : $"v{DateTime.UtcNow:yyyy.MM.dd.HHmm}";
}

static string? GetArg(string[] args, string key)
{
    for (var i = 0; i < args.Length - 1; i++)
    {
        if (args[i].Equals(key, StringComparison.OrdinalIgnoreCase))
        {
            return args[i + 1];
        }
    }
    return null;
}

var token = GetToken();
if (string.IsNullOrWhiteSpace(token))
{
    Console.Error.WriteLine("Missing GitHub token. Set GITHUB_TOKEN (recommended), GH_TOKEN, or GITHUB_PAT.");
    return 1;
}

var owner = GetArg(args, "--owner") ?? "CydonianHeavyIndustries";
var repo = GetArg(args, "--repo") ?? "ProjectP1L0TGame";
var zipPath = GetArg(args, "--zip");
var tag = GetArg(args, "--tag");
var versionArg = GetArg(args, "--version");

var repoRoot = FindRepoRoot();
var version = versionArg ?? ReadVersionFile(repoRoot);
if (string.IsNullOrWhiteSpace(zipPath))
{
    zipPath = FindLatestZip(repoRoot);
}

if (string.IsNullOrWhiteSpace(zipPath) || !File.Exists(zipPath))
{
    Console.Error.WriteLine("Zip not found. Use --zip <path> or create one with tools/package_dev_build.ps1 -Zip.");
    return 1;
}

tag ??= DeriveTag(zipPath, version);

var apiBase = $"https://api.github.com/repos/{owner}/{repo}";
using var http = new HttpClient();
http.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("ProjectP1L0T-Release", "1.0"));
http.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));
http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

async Task<JsonElement> CreateOrFetchReleaseAsync()
{
    var payload = new
    {
        tag_name = tag,
        name = $"Auto Build {tag}",
        prerelease = true,
        draft = false,
        generate_release_notes = true
    };
    var body = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
    var createResp = await http.PostAsync($"{apiBase}/releases", body);
    if (createResp.IsSuccessStatusCode)
    {
        var json = await createResp.Content.ReadAsStringAsync();
        return JsonDocument.Parse(json).RootElement.Clone();
    }

    if ((int)createResp.StatusCode != 422)
    {
        var err = await createResp.Content.ReadAsStringAsync();
        throw new InvalidOperationException($"Release create failed ({(int)createResp.StatusCode}): {err}");
    }

    var fetchResp = await http.GetAsync($"{apiBase}/releases/tags/{tag}");
    if (!fetchResp.IsSuccessStatusCode)
    {
        var err = await fetchResp.Content.ReadAsStringAsync();
        throw new InvalidOperationException($"Release fetch failed ({(int)fetchResp.StatusCode}): {err}");
    }

    var fetchJson = await fetchResp.Content.ReadAsStringAsync();
    return JsonDocument.Parse(fetchJson).RootElement.Clone();
}

JsonElement release;
try
{
    release = await CreateOrFetchReleaseAsync();
}
catch (Exception ex)
{
    Console.Error.WriteLine(ex.Message);
    return 1;
}

if (!release.TryGetProperty("upload_url", out var uploadProp))
{
    Console.Error.WriteLine("Release response missing upload_url.");
    return 1;
}

var uploadUrl = uploadProp.GetString()?.Replace("{?name,label}", string.Empty);
if (string.IsNullOrWhiteSpace(uploadUrl))
{
    Console.Error.WriteLine("Release upload_url invalid.");
    return 1;
}

var assetName = Path.GetFileName(zipPath);
var assetUrl = $"{uploadUrl}?name={Uri.EscapeDataString(assetName)}";

await using var fs = File.OpenRead(zipPath);
using var content = new StreamContent(fs);
content.Headers.ContentType = new MediaTypeHeaderValue("application/zip");

var uploadResp = await http.PostAsync(assetUrl, content);
if (!uploadResp.IsSuccessStatusCode)
{
    var err = await uploadResp.Content.ReadAsStringAsync();
    Console.Error.WriteLine($"Asset upload failed ({(int)uploadResp.StatusCode}): {err}");
    return 1;
}

if (release.TryGetProperty("html_url", out var htmlProp))
{
    Console.WriteLine($"Release published: {htmlProp.GetString()}");
}
else
{
    Console.WriteLine("Release published.");
}

return 0;
