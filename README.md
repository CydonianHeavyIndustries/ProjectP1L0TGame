# Project P1L0T Monorepo

## Layout
- `apps/game-godot` - Godot 4 game project
- `apps/launcher` - Electron + React launcher
- `apps/server-api` - Node server API + admin UI
- `apps/website` - CHII web assets and templates
- `tools` - build/publish/server setup scripts
- `Builds` - packaged outputs (ignored)

## Quick Start
- Launcher dev: `run.bat`
- Launcher debug: `run_debug.bat`
- Game package build: `build_and_package.bat`

## Godot Runtime Canonical Paths
- `res://game/scenes/...`
- `res://game/scripts/...`
- `res://game/materials/...`
- `res://game/levels/...`

## Notes
- Legacy game folders were migrated under `apps/game-godot`.
- Build artifacts and dependency folders are intentionally excluded from git tracking.
