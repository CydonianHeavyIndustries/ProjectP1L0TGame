using System.Text.Json;

namespace ProjectP1ServerManager;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();

        var state = AppState.Load();
        using var login = new LoginForm(state);
        if (login.ShowDialog() != DialogResult.OK || login.Session is null)
        {
            return;
        }

        AppState.Save(login.State);
        Application.Run(new DashboardForm(login.Session));
    }
}

internal sealed class AppState
{
    public string ServerUrl { get; set; } = "http://127.0.0.1:4280";
    public string LastToken { get; set; } = "";

    private static string FilePath =>
        Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "ProjectP1L0TServerManager", "state.json");

    public static AppState Load()
    {
        try
        {
            if (!File.Exists(FilePath))
            {
                return new AppState();
            }

            var json = File.ReadAllText(FilePath);
            return JsonSerializer.Deserialize<AppState>(json) ?? new AppState();
        }
        catch
        {
            return new AppState();
        }
    }

    public static void Save(AppState state)
    {
        try
        {
            var dir = Path.GetDirectoryName(FilePath)!;
            Directory.CreateDirectory(dir);
            File.WriteAllText(FilePath, JsonSerializer.Serialize(state, new JsonSerializerOptions { WriteIndented = true }));
        }
        catch
        {
            // Non-fatal.
        }
    }
}
