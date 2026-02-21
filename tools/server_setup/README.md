# Project P1L0T Server Setup (BAT + Host Branch)

## Build setup folder

```bat
tools\server_setup\build_server_setup.bat
```

Output default:

`F:\projectP1_server_setup`

## Run directly from repo (host branch source)

```bat
tools\server_setup\setup_server.bat
```

This always installs from:

- Repo: `CydonianHeavyIndustries/ProjectP1L0TGame`
- Branch: `host`

## Build standalone setup EXE (single file)

```bat
tools\server_setup\build_server_setup_exe.bat
```

Output default:

`F:\projectP1_server_setup.exe`

## Install on target machine

1. Copy `projectP1_server_setup` folder to target machine.
2. Run `setup_server.bat` as Administrator.
3. Choose install directory.

## Source of install files

Installer downloads server files from GitHub:

- Repo: `CydonianHeavyIndustries/ProjectP1L0TGame`
- Branch: `host` (fallback `Host` if needed)
- Paths expected in branch:
  - `apps/server-api`
  - `apps/website`

## What setup configures

- Windows service: `ProjectP1L0TServer`
- Auto-start task: `ProjectP1L0TServerAutoStart`
- Firewall rule for TCP `4280`
- Desktop/Start Menu/Startup shortcuts
- Server control scripts:
  - `server_manager\open_admin_ui.bat`
  - `server_manager\server_control.bat`

## Requirements

- Internet access during setup.
- If Node.js is not installed, setup auto-downloads Node LTS runtime.
