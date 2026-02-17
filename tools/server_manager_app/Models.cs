namespace ProjectP1ServerManager;

internal sealed class AdminSession
{
    public required string ServerUrl { get; init; }
    public required string Token { get; init; }
}

internal sealed class HealthResponse
{
    public bool Ok { get; set; }
    public string ServerName { get; set; } = "";
    public string HardwareProfile { get; set; } = "";
    public int MaxPlayers { get; set; }
    public int TickRate { get; set; }
    public int CpuCount { get; set; }
    public int UptimeSec { get; set; }
    public string Now { get; set; } = "";
}

internal sealed class SettingsEnvelope
{
    public ServerSettings Settings { get; set; } = new();
}

internal sealed class ServerSettings
{
    public string ServerName { get; set; } = "";
    public string WebsiteTitle { get; set; } = "";
    public string Motd { get; set; } = "";
    public bool AllowSignup { get; set; }
    public bool MaintenanceMode { get; set; }
    public int MaxUploadMb { get; set; }
    public int MaxPlayers { get; set; }
    public int TickRate { get; set; }
    public int AutosaveSeconds { get; set; }
    public string HardwareProfile { get; set; } = "recommended";
    public bool TelemetryEnabled { get; set; }
}

internal sealed class UsersEnvelope
{
    public List<ServerUser> Users { get; set; } = [];
}

internal sealed class UserEnvelope
{
    public ServerUser User { get; set; } = new();
}

internal sealed class ServerUser
{
    public string Id { get; set; } = "";
    public string Username { get; set; } = "";
    public string Email { get; set; } = "";
    public bool IsAdmin { get; set; }
    public bool Enabled { get; set; }
    public string Status { get; set; } = "";
    public string Bio { get; set; } = "";
    public string Discord { get; set; } = "";
    public string CreatedAt { get; set; } = "";
    public string UpdatedAt { get; set; } = "";
}

internal sealed class LogsEnvelope
{
    public List<string> Lines { get; set; } = [];
}
