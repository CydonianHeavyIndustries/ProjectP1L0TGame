# Manual Release Fallback

Use this when GitHub Actions release workflow is blocked/failing (for example billing lock).

## Quick run

```bat
tools\manual_release_fallback.bat
```

This uploads:
- `tools/game_setup/dist/ProjectP1L0T_Game_Setup.exe`

to a GitHub release on branch `main`.

## Token resolution

Order:
1. `GITHUB_TOKEN`
2. `GH_TOKEN`
3. `GITHUB_PAT`
4. Token file passed via `-TokenFile`

`tools\manual_release_fallback.bat` also auto-uses:
- `E:\OneDrive\Desktop\github token.txt`
if present.

## Optional examples

Dry run:

```bat
tools\manual_release_fallback.bat -DryRun
```

Custom tag:

```bat
tools\manual_release_fallback.bat -Tag v0.2.0-manual -ReleaseName "Manual Build v0.2.0"
```
