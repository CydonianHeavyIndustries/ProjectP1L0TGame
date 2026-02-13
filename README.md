# ProjectP1L0T

Standalone Godot 4.2 project for Project-P1L0T (not a Titanfall mod).

**Quick Start**
1. Open `project.godot` in Godot 4.2 (GL Compatibility renderer enabled).
2. Run the project (F5). Main scene is `res://scenes/Main.tscn`.

**Controls**
- `WASD` move
- `Space` jump
- `Shift` sprint
- `C` slide
- `LMB` fire
- `R` reload
- `Esc` toggle mouse capture
- `F` open Faction Select (UI placeholder)
- `K` debug kill (respawns at ship home)

**Debug Toggles**
Edit `scripts/core_systems/DebugConfig.gd` to change:
- `BOOT_TO_GAMEPLAY`: start in gameplay or title screen
- `SHOW_SAFEZONE_GIZMO`: show safe-zone volume mesh
- `AUTO_SAVE_ON_CHANGE`: auto-save when data changes

**Logging**
- On-screen log overlay appears in the bottom-left.
- Log file: `user://logs/latest.log`
- Typical Windows path: `C:\Users\<you>\AppData\Roaming\Godot\app_userdata\ProjectP1L0T\logs\latest.log`

**Export (Windows)**
1. Open Project > Export in Godot.
2. Use the Windows preset from `export_presets.cfg`.
3. Export to a local folder.
