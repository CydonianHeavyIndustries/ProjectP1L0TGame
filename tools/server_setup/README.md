# Project P1L0T Server Setup

## Build Installer

Run:

```bat
tools\server_setup\build_server_setup.bat
```

Or:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\server_setup\build_server_setup.ps1 -OutputExe F:\projectP1_server_setup.exe
```

## What installer does

- Prompts for install directory
- Copies server runtime (`node.exe` + `services/server-api`)
- Copies `ProjectP1ServerManager.exe`
- Creates Windows service `ProjectP1L0TServer`
- Sets service to auto start
- Starts service immediately
- Adds firewall rule for TCP `4280`
- Creates startup scheduled task safety net
- Creates desktop/start menu/startup shortcuts to `ProjectP1ServerManager.exe`
- Prompts for hardware profile (`Recommended` or `Use All Hardware`)
- Launches `ProjectP1ServerManager.exe` after install

## Default admin token

Set in `services/server-api/data/server.config.json` after first run.

Default value is:

`change-me-now`

Change it immediately in production.

## Admin capabilities

- Server settings (name, MOTD, signup, maintenance, upload cap, max players, tick rate, autosave)
- Hardware profile switching
- User management (create user, admin toggle, enable/disable, status, bio, Discord)
- Per-user file uploads/deletes
- Recent server log viewing

## Server Manager EXE flow

`ProjectP1ServerManager.exe`:

- starts with login screen (server URL + admin token)
- opens local dashboard for server management
- minimizes to system tray with restore/exit actions
