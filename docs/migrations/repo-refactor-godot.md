# Repo Refactor: Monorepo Apps Migration

## Scope
- Moved launcher to `apps/launcher`
- Moved Godot project to `apps/game-godot`
- Moved server API to `apps/server-api`
- Moved website assets to `apps/website`

## Compatibility
- Root `run.bat`, `run_debug.bat`, and `build_and_package.bat` are wrapper entrypoints.
- Godot canonical runtime paths are `res://game/*`.

## Follow-up
- Remove temporary legacy folders after one release cycle.
- Keep server setup scripts aligned with `apps/*` paths.
