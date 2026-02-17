using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace ProjectP1ServerManager;

internal sealed class ServerApiClient : IDisposable
{
    private readonly HttpClient _http;
    private readonly JsonSerializerOptions _json = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public ServerApiClient(AdminSession session)
    {
        var baseUrl = session.ServerUrl.TrimEnd('/') + "/";
        _http = new HttpClient
        {
            BaseAddress = new Uri(baseUrl),
            Timeout = TimeSpan.FromSeconds(10)
        };
        _http.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        _http.DefaultRequestHeaders.Add("x-admin-token", session.Token);
    }

    public async Task<HealthResponse> GetHealthAsync(CancellationToken ct = default) =>
        await GetAsync<HealthResponse>("api/health", ct);

    public async Task<ServerSettings> GetSettingsAsync(CancellationToken ct = default)
    {
        var envelope = await GetAsync<SettingsEnvelope>("api/admin/settings", ct);
        return envelope.Settings;
    }

    public async Task SaveSettingsAsync(ServerSettings settings, CancellationToken ct = default) =>
        await SendJsonAsync(HttpMethod.Put, "api/admin/settings", settings, ct);

    public async Task<List<ServerUser>> GetUsersAsync(CancellationToken ct = default)
    {
        var envelope = await GetAsync<UsersEnvelope>("api/admin/users", ct);
        return envelope.Users;
    }

    public async Task<ServerUser> GetUserAsync(string userId, CancellationToken ct = default)
    {
        var envelope = await GetAsync<UserEnvelope>($"api/admin/users/{Uri.EscapeDataString(userId)}", ct);
        return envelope.User;
    }

    public async Task SaveUserAsync(ServerUser user, CancellationToken ct = default)
    {
        var payload = new
        {
            isAdmin = user.IsAdmin,
            enabled = user.Enabled,
            status = user.Status,
            bio = user.Bio,
            discord = user.Discord
        };
        await SendJsonAsync(HttpMethod.Patch, $"api/admin/users/{Uri.EscapeDataString(user.Id)}", payload, ct);
    }

    public async Task<List<string>> GetLogsAsync(CancellationToken ct = default)
    {
        var envelope = await GetAsync<LogsEnvelope>("api/admin/logs", ct);
        return envelope.Lines;
    }

    public async Task<bool> ValidateLoginAsync(CancellationToken ct = default)
    {
        try
        {
            var _ = await GetAsync<JsonElement>("api/admin/bootstrap", ct);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private async Task<T> GetAsync<T>(string path, CancellationToken ct)
    {
        using var response = await _http.GetAsync(path, ct);
        var body = await response.Content.ReadAsStringAsync(ct);
        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException($"API {response.StatusCode}: {body}");
        }

        return JsonSerializer.Deserialize<T>(body, _json)
               ?? throw new InvalidOperationException("Invalid JSON response.");
    }

    private async Task SendJsonAsync<T>(HttpMethod method, string path, T payload, CancellationToken ct)
    {
        var json = JsonSerializer.Serialize(payload);
        using var req = new HttpRequestMessage(method, path)
        {
            Content = new StringContent(json, Encoding.UTF8, "application/json")
        };
        using var response = await _http.SendAsync(req, ct);
        var body = await response.Content.ReadAsStringAsync(ct);
        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException($"API {response.StatusCode}: {body}");
        }
    }

    public void Dispose() => _http.Dispose();
}
