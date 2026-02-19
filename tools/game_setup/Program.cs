using System.Diagnostics;
using System.Text;

internal static class Program
{
    private static readonly List<string> Errors = new();
    private static readonly List<string> Warnings = new();
    private static readonly List<string> Steps = new();

    private static int Main()
    {
        Console.OutputEncoding = Encoding.UTF8;
        WriteTitle();

        var repoRoot = ResolveRepoRoot();
        if (string.IsNullOrWhiteSpace(repoRoot))
        {
            Error("Could not resolve repository root. Setup aborted.");
            return 1;
        }

        Info($"Repo root: {repoRoot}");
        var reportPath = Path.Combine(repoRoot, "tools", "game_setup", "setup_report.txt");
        Directory.CreateDirectory(Path.GetDirectoryName(reportPath)!);

        if (!File.Exists(Path.Combine(repoRoot, "apps", "game-godot", "project.godot")))
        {
            Error("Missing apps/game-godot/project.godot. This does not look like a valid Project P1L0T repo.");
            WriteReport(reportPath, repoRoot);
            return 1;
        }

        Info("Update policy: only the launcher pulls game updates from GitHub releases.");
        Info("This setup prepares local tooling and builds installers from local repo state.");

        RunStep("Checking Node.js", () => EnsureTool("node", "--version"));
        RunStep("Checking npm", () => EnsureTool("npm", "--version"));
        RunStep("Installing launcher dependencies", () => RunOrThrow("npm", "install", Path.Combine(repoRoot, "apps", "launcher")));
        RunStep("Installing server-api dependencies", () => RunOrThrow("npm", "install", Path.Combine(repoRoot, "apps", "server-api")));
        RunStep("Building launcher setup installer (local repo state)", () =>
        {
            var launcherDir = Path.Combine(repoRoot, "apps", "launcher");
            RunOrThrow("npm", "run dist:win", launcherDir);
            var installer = FindLatestLauncherInstaller(launcherDir);
            if (string.IsNullOrWhiteSpace(installer))
            {
                throw new InvalidOperationException("Launcher setup .exe was not generated in apps/launcher/release.");
            }

            Info($"Launcher setup: {installer}");
        });
        RunStep("Checking .NET SDK", () => EnsureTool("dotnet", "--version"));
        RunStep("Building ReleasePublisher tool", () =>
            RunOrThrow("dotnet", "build tools/ReleasePublisher/ReleasePublisher.csproj -nologo", repoRoot));

        RunStep("Godot import/validation", () =>
        {
            var godot = FindGodotExe();
            if (string.IsNullOrWhiteSpace(godot))
            {
                Warn("Godot executable not found. Skipping import step.");
                return;
            }

            Info($"Godot: {godot}");
            var result = RunCommand(godot, "--headless --editor --import --path \"apps/game-godot\" --quit", repoRoot, true);
            if (result.ExitCode != 0)
            {
                Warn($"Godot import reported exit code {result.ExitCode}. Review project scripts/scenes.");
            }
        });

        WriteReport(reportPath, repoRoot);
        PrintSummary(reportPath);

        return Errors.Count == 0 ? 0 : 2;
    }

    private static void WriteTitle()
    {
        Console.WriteLine("==============================================================");
        Console.WriteLine(" Project P1L0T - Game Repo Setup");
        Console.WriteLine("==============================================================");
        Console.WriteLine();
    }

    private static string ResolveRepoRoot()
    {
        var exeDir = AppContext.BaseDirectory;
        var current = new DirectoryInfo(exeDir);
        while (current is not null)
        {
            if (LooksLikeRepoRoot(current.FullName))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        Console.Write("Enter ProjectP1L0T repo path (or press Enter to cancel): ");
        var input = Console.ReadLine()?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(input))
        {
            return string.Empty;
        }

        var full = Path.GetFullPath(input);
        return LooksLikeRepoRoot(full) ? full : string.Empty;
    }

    private static bool LooksLikeRepoRoot(string path)
    {
        return Directory.Exists(Path.Combine(path, ".git"))
               && File.Exists(Path.Combine(path, "apps", "game-godot", "project.godot"));
    }

    private static void RunStep(string label, Action action)
    {
        Console.WriteLine();
        Console.WriteLine($"[STEP] {label}");
        Steps.Add(label);
        try
        {
            action();
            Ok($"{label} complete.");
        }
        catch (Exception ex)
        {
            Error($"{label} failed: {ex.Message}");
        }
    }

    private static void EnsureTool(string fileName, string args)
    {
        var result = RunCommand(fileName, args, Environment.CurrentDirectory, false);
        if (result.ExitCode != 0)
        {
            throw new InvalidOperationException($"{fileName} is not available.");
        }
    }

    private static ProcessResult RunCommand(string fileName, string args, string workingDir, bool streamOutput)
    {
        var psi = new ProcessStartInfo
        {
            FileName = fileName,
            Arguments = args,
            WorkingDirectory = workingDir,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using var proc = new Process { StartInfo = psi };
        var stdout = new StringBuilder();
        var stderr = new StringBuilder();

        proc.OutputDataReceived += (_, e) =>
        {
            if (e.Data is null) return;
            stdout.AppendLine(e.Data);
            if (streamOutput) Console.WriteLine($"  {e.Data}");
        };
        proc.ErrorDataReceived += (_, e) =>
        {
            if (e.Data is null) return;
            stderr.AppendLine(e.Data);
            if (streamOutput) Console.WriteLine($"  {e.Data}");
        };

        if (!proc.Start())
        {
            throw new InvalidOperationException($"Could not start process: {fileName}");
        }

        proc.BeginOutputReadLine();
        proc.BeginErrorReadLine();
        proc.WaitForExit();

        return new ProcessResult(proc.ExitCode, stdout.ToString(), stderr.ToString());
    }

    private static void RunOrThrow(string fileName, string args, string workingDir)
    {
        var result = RunCommand(fileName, args, workingDir, true);
        if (result.ExitCode != 0)
        {
            throw new InvalidOperationException($"{fileName} {args} failed with exit code {result.ExitCode}.");
        }
    }

    private static string FindGodotExe()
    {
        var candidates = new[]
        {
            Environment.GetEnvironmentVariable("GODOT_PATH"),
            @"C:\Users\Beurkson\Downloads\Godot_v4.6-stable_win64.exe\Godot_v4.6-stable_win64_console.exe",
            @"C:\Program Files\Godot\Godot_v4.6-stable_win64_console.exe",
            @"C:\Program Files\Godot\Godot.exe",
            @"C:\Program Files\Godot Engine\Godot.exe"
        };

        foreach (var c in candidates.Where(x => !string.IsNullOrWhiteSpace(x)))
        {
            if (File.Exists(c))
            {
                return c!;
            }
        }

        return string.Empty;
    }

    private static string FindLatestLauncherInstaller(string launcherDir)
    {
        var releaseDir = Path.Combine(launcherDir, "release");
        if (!Directory.Exists(releaseDir))
        {
            return string.Empty;
        }

        var installer = new DirectoryInfo(releaseDir)
            .GetFiles("ProjectP1L0T_Launcher_Setup_*.exe", SearchOption.TopDirectoryOnly)
            .OrderByDescending(f => f.LastWriteTimeUtc)
            .FirstOrDefault();

        return installer?.FullName ?? string.Empty;
    }

    private static void WriteReport(string reportPath, string repoRoot)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Project P1L0T - Setup Report");
        sb.AppendLine($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
        sb.AppendLine($"Repo: {repoRoot}");
        sb.AppendLine();
        sb.AppendLine("Steps:");
        foreach (var step in Steps) sb.AppendLine($"- {step}");
        sb.AppendLine();
        sb.AppendLine("Warnings:");
        if (Warnings.Count == 0) sb.AppendLine("- none");
        else foreach (var warning in Warnings) sb.AppendLine($"- {warning}");
        sb.AppendLine();
        sb.AppendLine("Errors:");
        if (Errors.Count == 0) sb.AppendLine("- none");
        else foreach (var error in Errors) sb.AppendLine($"- {error}");
        File.WriteAllText(reportPath, sb.ToString(), Encoding.UTF8);
    }

    private static void PrintSummary(string reportPath)
    {
        Console.WriteLine();
        Console.WriteLine("==============================================================");
        if (Errors.Count == 0)
        {
            Console.WriteLine("Setup completed.");
        }
        else
        {
            Console.WriteLine("Setup completed with errors.");
            foreach (var error in Errors) Console.WriteLine($"- {error}");
        }

        if (Warnings.Count > 0)
        {
            Console.WriteLine("Warnings:");
            foreach (var warning in Warnings) Console.WriteLine($"- {warning}");
        }

        Console.WriteLine($"Report: {reportPath}");
        Console.WriteLine("==============================================================");
        Console.WriteLine("Press any key to exit...");
        Console.ReadKey(true);
    }

    private static void Info(string message) => Console.WriteLine($"[INFO] {message}");
    private static void Ok(string message) => Console.WriteLine($"[OK] {message}");
    private static void Warn(string message)
    {
        Warnings.Add(message);
        Console.WriteLine($"[WARN] {message}");
    }

    private static void Error(string message)
    {
        Errors.Add(message);
        Console.WriteLine($"[ERROR] {message}");
    }

    private readonly record struct ProcessResult(int ExitCode, string StdOut, string StdErr);
}
