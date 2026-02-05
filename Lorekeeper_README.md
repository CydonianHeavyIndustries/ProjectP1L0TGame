# Lorekeeper Setup

## Prerequisites
- Windows 11
- Git installed and available on PATH
- Node.js 18+ (includes npm)
- GitHub Personal Access Token with access to the wiki repo (typically `repo` scope)
- Discord bot token (for the chatbot)

## Environment Variables
Set these before running the seed script or the app:
- `GITHUB_USER`: your GitHub username
- `GITHUB_TOKEN`: your GitHub PAT
- `GITHUB_EMAIL` (optional): commit email (defaults to `<user>@users.noreply.github.com`)
- `DISCORD_TOKEN`: bot token for the Lorekeeper Discord bot
- `DISCORD_CLIENT_ID`: Discord application client ID
- `DISCORD_GUILD_ID` (optional): register commands to a single guild for faster updates
- `OPENAI_API_KEY` (optional): OpenAI key (can also be set in the app Settings)
- `OPENAI_MODEL` (optional): override model (defaults to `gpt-4o`)
- `OPENAI_FALLBACK` (optional): set to `false` to disable fallback
- `OPENAI_FALLBACK_MODEL` (optional): fallback model (defaults to `gpt-4o-mini`)
- `AI_PROVIDER` (optional): `openai` or `ollama`
- `OLLAMA_HOST` (optional): default `http://localhost:11434`
- `OLLAMA_MODEL` (optional): default empty; set in Settings or via env var

### PowerShell example
```
$env:GITHUB_USER = "your-username"
$env:GITHUB_TOKEN = "your-token"
$env:GITHUB_EMAIL = "you@example.com"
$env:DISCORD_TOKEN = "your-discord-token"
$env:DISCORD_CLIENT_ID = "your-discord-client-id"
$env:DISCORD_GUILD_ID = "optional-guild-id"
$env:OPENAI_API_KEY = "your-openai-key"
$env:OPENAI_MODEL = "gpt-4o"
$env:OPENAI_FALLBACK = "true"
$env:OPENAI_FALLBACK_MODEL = "gpt-4o-mini"
$env:AI_PROVIDER = "ollama"
$env:OLLAMA_HOST = "http://localhost:11434"
$env:OLLAMA_MODEL = "llama3.1"
```

## Wiki Seed Script
Seeds the index pages into the GitHub Wiki repo.

From the repo root:
```
cd wiki-seed
npm run seed
```

Optional overrides:
- `WIKI_URL` env var
- CLI: `node seed_wiki_pages.js --repo https://github.com/owner/repo.wiki.git`

## Lorekeeper Electron App
Minimal editor that syncs, previews, and applies wiki edits.

From the repo root:
```
cd lorekeeper-app
npm install
npm start
```

On first run, provide the wiki repo URL (defaults to Project-P1L0T.wiki.git). The app stores the clone at `lorekeeper-app/data/wiki/`.
Use the **Settings** button in the app to store your OpenAI API key and model. The app will use the Responses API to draft edit plans.
If you see a model access error, use **Fetch Models** in Settings to list the models your key can access, then pick one.
If you want to use Ollama, set **AI Provider** to `Ollama (Local)` and click **Fetch Models** to pick one of your installed models.
On launch, the app auto-syncs the wiki and auto-selects the best local Ollama model if none is set.
The app also attempts to start a local Ollama server on launch (and stops it on exit) when using a local host.

## Logging
Logs are written to `lorekeeper-app/data/logs/lorekeeper.log`. You can copy the path from Settings.
Workflow:
1. Talk to Lorekeeper in the chat area.
2. Tell it **"start edits"** (or similar) when you want a multi-page plan.
3. Click **Apply Draft** to write changes locally.
4. Click **Check Mods** to review the git diff.
5. Click **Commit & Push** when approved.

## Lorekeeper Discord Bot
Chatbot that drafts update plans and only applies changes after you confirm.

From the repo root:
```
cd lorekeeper-bot
npm install
npm run register
npm start
```

Usage:
- Run `/lorekeeper` in a channel to start a session.
- Send messages with your requested changes.
- The bot responds with a JSON plan and buttons: `Apply Update` or `Cancel`.
- Type `exit` to end the session.

The bot stores the wiki clone at `lorekeeper-bot/data/wiki/`.
Make sure the bot has the `Message Content` intent enabled in the Discord Developer Portal so it can read your messages after the slash command.

## Canon Rules Enforced
- ED leader is always referenced as: `ED:[REDACTED]`
- Avoid introducing new canon facts unless explicitly asked
- Keep edits minimal; do not rewrite entire pages unless asked

## Notes
- `Sync` runs `git pull`.
- `Apply Draft` writes markdown locally. `Commit & Push` pushes with message `Lorekeeper: update <Page Title>`.
- If you need strict JSON schema output, use a model snapshot like `gpt-4o-2024-08-06` or `gpt-4o-mini` via Settings.
