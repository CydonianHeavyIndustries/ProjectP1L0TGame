using System.Diagnostics;
using System.Reflection;
using System.Text;

const string ScriptResourceName = "install_server.ps1";

var exeDir = AppContext.BaseDirectory;
var tempRoot = Path.Combine(Path.GetTempPath(), $"ProjectP1L0T_ServerSetup_{Guid.NewGuid():N}");
Directory.CreateDirectory(tempRoot);

var installerPath = Path.Combine(tempRoot, "install_server.ps1");
WriteEmbeddedInstaller(installerPath);

var passthroughArgs = Environment.GetCommandLineArgs().Skip(1).ToList();
if (!passthroughArgs.Any(arg => arg.Equals("-InstallerRoot", StringComparison.OrdinalIgnoreCase))) {
  passthroughArgs.Add("-InstallerRoot");
  passthroughArgs.Add(exeDir.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar));
}

var argLine = BuildPowerShellArgs(installerPath, passthroughArgs);

var psi = new ProcessStartInfo {
  FileName = "powershell.exe",
  Arguments = argLine,
  WorkingDirectory = tempRoot,
  UseShellExecute = false,
  CreateNoWindow = false
};

using var process = Process.Start(psi) ?? throw new InvalidOperationException("Failed to start powershell.exe");
process.WaitForExit();
var exitCode = process.ExitCode;

try {
  Directory.Delete(tempRoot, recursive: true);
} catch {
  // best effort cleanup
}

Environment.Exit(exitCode);

static void WriteEmbeddedInstaller(string outputPath) {
  using var stream = ResolveResourceStream() ?? throw new InvalidOperationException("Embedded install_server.ps1 not found.");
  using var reader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);
  var content = reader.ReadToEnd();
  File.WriteAllText(outputPath, content, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
}

static Stream? ResolveResourceStream() {
  var assembly = Assembly.GetExecutingAssembly();
  var exact = assembly.GetManifestResourceStream(ScriptResourceName);
  if (exact is not null) {
    return exact;
  }

  var fallback = assembly.GetManifestResourceNames()
    .FirstOrDefault(name => name.EndsWith($".{ScriptResourceName}", StringComparison.OrdinalIgnoreCase));
  return fallback is null ? null : assembly.GetManifestResourceStream(fallback);
}

static string BuildPowerShellArgs(string installerPath, IEnumerable<string> passthroughArgs) {
  static string Quote(string value) => $"\"{value.Replace("\"", "\\\"")}\"";

  var args = new List<string> {
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-STA",
    "-File", Quote(installerPath)
  };

  args.AddRange(passthroughArgs.Select(Quote));
  return string.Join(" ", args);
}

