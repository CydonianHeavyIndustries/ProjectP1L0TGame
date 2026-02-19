# ProjectP1L0T Game (Godot)

Standalone Godot 4 project for Project-P1L0T.

## Quick Start
1. Open `apps/game-godot/project.godot` in Godot 4.2+.
2. Run (F5). Main scene: `res://game/scenes/core/Main.tscn`.

## Structure
- `game/scenes/core` runtime entry, gameplay flow, title/tutorial/core systems
- `game/scenes/entities` player + AI actors
- `game/scenes/interactables` ammo box, zipline, safe zone trigger
- `game/scenes/projectiles` grenade/rocket/turret projectile scenes
- `game/scenes/resources` shared scene meshes/shapes/environment resources
- `game/scenes/ui` UI-only scenes (log overlay)
- `game/scenes/world` world/home scenes
- `game/scripts/core` gameplay flow scripts (`Main`, `Gameplay`, `Tutorial`)
- `game/scripts/ui` HUD/pause/title scripts
- `game/scripts/entities` player/dummy/turret behavior
- `game/scripts/interactables` world interaction scripts
- `game/scripts/combat` projectile/weapon scripts
- `game/scripts/core_systems` persistent systems (save, factions, parties, etc.)

## Controls
- `WASD` move
- `Space` jump
- `Shift` sprint
- `C` crouch/slide
- `LMB` fire
- `R` reload
- `Esc` pause/mouse capture toggle

## Debug Toggles
Edit `apps/game-godot/game/scripts/core_systems/DebugConfig.gd`.
