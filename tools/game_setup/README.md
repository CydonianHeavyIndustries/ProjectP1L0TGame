# Project P1L0T Game Setup EXE

This setup tool bootstraps a fresh repo clone for game development.

Update policy:
- Game update downloads from GitHub are handled by the launcher only.
- This setup tool does not pull game updates/releases from GitHub; it builds from local repo files.

## Build

Run:

```bat
tools\game_setup\build_game_setup_exe.bat
```

Output:

`tools\game_setup\dist\ProjectP1L0T_Game_Setup.exe`

Build mode: single-file, self-contained (`win-x64`), so target machines do not need a preinstalled .NET runtime.

## What Setup Does

- Checks `node`, `npm`, and `.NET SDK`.
- Installs dependencies in:
  - `apps/launcher`
  - `apps/server-api`
- Builds launcher installer (`apps/launcher/release/ProjectP1L0T_Launcher_Setup_*.exe`)
- Builds `tools/ReleasePublisher`.
- Runs Godot headless import/validation (if Godot is found).
- Writes report to:
  - `tools/game_setup/setup_report.txt`

## Godot Detection Order

1. `GODOT_PATH` environment variable
2. Known local install paths (console exe preferred)
