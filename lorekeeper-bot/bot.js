const { Client, GatewayIntentBits, Partials, Events, ActionRowBuilder, ButtonBuilder, ButtonStyle, SlashCommandBuilder, REST, Routes } = require('discord.js');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const DEFAULT_REPO_URL = 'https://github.com/CydonianHeavyIndustries/Project-P1L0T.wiki.git';
const CANON_RULES = [
  'ED leader is always referenced as: ED:[REDACTED]',
  'Avoid introducing new canon facts unless explicitly asked',
  'Edits should be minimal diffs; do not rewrite entire pages unless asked'
];

const DISCORD_TOKEN = process.env.DISCORD_TOKEN;
const DISCORD_CLIENT_ID = process.env.DISCORD_CLIENT_ID;
const GUILD_ID = process.env.DISCORD_GUILD_ID;

if (!DISCORD_TOKEN || !DISCORD_CLIENT_ID) {
  console.error('Missing DISCORD_TOKEN or DISCORD_CLIENT_ID env vars.');
  process.exit(1);
}

const appRoot = __dirname;
const dataDir = path.join(appRoot, 'data');
const settingsPath = path.join(dataDir, 'settings.json');
const wikiDir = path.join(dataDir, 'wiki');

function ensureDataDir() {
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
}

function readSettings() {
  if (!fs.existsSync(settingsPath)) return {};
  try {
    return JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
  } catch {
    return {};
  }
}

function writeSettings(settings) {
  ensureDataDir();
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2), 'utf8');
}

function getAuthHeader() {
  const user = process.env.GITHUB_USER;
  const token = process.env.GITHUB_TOKEN;
  if (!user || !token) return null;
  const basic = Buffer.from(`${user}:${token}`, 'utf8').toString('base64');
  return `AUTHORIZATION: basic ${basic}`;
}

function runGit(args, cwd = wikiDir) {
  const env = { ...process.env, GIT_TERMINAL_PROMPT: '0' };
  const authHeader = getAuthHeader();
  const cmd = authHeader ? `git -c http.extraHeader="${authHeader}" ${args}` : `git ${args}`;
  return execSync(cmd, { cwd, env, stdio: 'pipe' }).toString('utf8');
}

function ensureRepo(repoUrl) {
  ensureDataDir();
  const gitDir = path.join(wikiDir, '.git');
  if (fs.existsSync(gitDir)) return;

  if (fs.existsSync(wikiDir) && fs.readdirSync(wikiDir).length > 0) {
    throw new Error('Wiki directory exists and is not empty. Please clear data/wiki first.');
  }

  const authHeader = getAuthHeader();
  const env = { ...process.env, GIT_TERMINAL_PROMPT: '0' };
  const cmd = authHeader
    ? `git -c http.extraHeader="${authHeader}" clone ${repoUrl} "${wikiDir}"`
    : `git clone ${repoUrl} "${wikiDir}"`;
  execSync(cmd, { env, stdio: 'pipe' });
}

function configureGitIdentity() {
  const user = process.env.GITHUB_USER;
  if (!user) return;
  const email = process.env.GITHUB_EMAIL || `${user}@users.noreply.github.com`;
  runGit(`config user.name "${user}"`);
  runGit(`config user.email "${email}"`);
}

function listPages() {
  if (!fs.existsSync(wikiDir)) return [];
  return fs.readdirSync(wikiDir)
    .filter((name) => name.toLowerCase().endsWith('.md'))
    .map((name) => path.basename(name, '.md'))
    .sort((a, b) => a.localeCompare(b));
}

function sanitizeTitle(title) {
  return title.replace(/[<>:"/\\|?*]/g, '-').trim();
}

function pagePathFromTitle(title) {
  const safe = sanitizeTitle(title);
  return path.join(wikiDir, `${safe}.md`);
}

function validatePlan(plan) {
  if (!plan || typeof plan !== 'object') throw new Error('Invalid plan payload.');
  if (!plan.action || !plan.page || !plan.mode || !plan.content_markdown) {
    throw new Error('Plan missing required fields.');
  }
  if (plan.mode === 'replace_section' && !plan.target_heading) {
    throw new Error('replace_section requires target_heading.');
  }
}

function validateCanon(content) {
  const bad = /\bED:\s*(?!\[REDACTED\])/i;
  if (bad.test(content)) {
    throw new Error('Canon rule violation: ED leader must be referenced as ED:[REDACTED].');
  }
}

function replaceSection(markdown, targetHeading, newContent) {
  const lines = markdown.split(/\r?\n/);
  const target = targetHeading.trim();
  const start = lines.findIndex((line) => line.trim() === target);
  if (start === -1) {
    throw new Error(`Heading not found: ${targetHeading}`);
  }

  const levelMatch = target.match(/^#+/);
  const level = levelMatch ? levelMatch[0].length : 1;

  let end = lines.length;
  for (let i = start + 1; i < lines.length; i += 1) {
    const headingMatch = lines[i].match(/^(#+)\s+/);
    if (headingMatch && headingMatch[1].length <= level) {
      end = i;
      break;
    }
  }

  const before = lines.slice(0, start + 1);
  const after = lines.slice(end);
  const contentLines = newContent.replace(/\s*$/g, '').split(/\r?\n/);

  return [...before, ...contentLines, '', ...after].join('\n');
}

function applyUpdate(plan) {
  validatePlan(plan);
  validateCanon(plan.content_markdown);

  const filePath = pagePathFromTitle(plan.page);
  const exists = fs.existsSync(filePath);

  if (plan.action === 'create_page') {
    if (exists) {
      throw new Error('Page already exists.');
    }
    fs.writeFileSync(filePath, plan.content_markdown.replace(/\s*$/g, '') + '\n', 'utf8');
    return;
  }

  if (!exists) {
    throw new Error('Page not found for update.');
  }

  const current = fs.readFileSync(filePath, 'utf8');
  let updated = current;

  if (plan.mode === 'append') {
    const trimmed = current.replace(/\s*$/g, '');
    updated = `${trimmed}\n\n${plan.content_markdown.replace(/\s*$/g, '')}\n`;
  } else if (plan.mode === 'replace_section') {
    updated = replaceSection(current, plan.target_heading, plan.content_markdown);
    updated = updated.replace(/\s*$/g, '') + '\n';
  } else {
    throw new Error(`Unsupported mode: ${plan.mode}`);
  }

  fs.writeFileSync(filePath, updated, 'utf8');
}

function commitAndPush(pageTitle) {
  configureGitIdentity();
  if (!getAuthHeader()) {
    throw new Error('GITHUB_USER and GITHUB_TOKEN are required to push changes.');
  }
  const status = runGit('status --porcelain');
  if (!status.trim()) {
    throw new Error('No changes to commit.');
  }
  runGit('add -A');
  runGit(`commit -m "Lorekeeper: update ${pageTitle}"`);
  runGit('push');
}

function extractPageTitle(text) {
  const quoted = text.match(/"([^"]+)"|\'([^\']+)\'/);
  if (quoted) return (quoted[1] || quoted[2] || '').trim();

  const prefixes = ['Home', 'Lore', 'Tech', 'Archive', 'Factions'];
  for (const prefix of prefixes) {
    const match = text.match(new RegExp(`\b${prefix}(?:\s-\s[^\n]+)?`, 'i'));
    if (match) return match[0].trim();
  }

  return null;
}

function generatePlan(userMessage, selectedPage) {
  const text = (userMessage || '').trim();
  const inferredPage = extractPageTitle(text);
  const page = inferredPage || selectedPage || 'Home';

  const wantsCreate = /\b(create|new)\s+page\b/i.test(text);
  const wantsReplace = /\b(replace|update|edit)\s+section\b/i.test(text);
  const headingMatch = text.match(/(#+\s+[^\n]+)/);
  const targetHeading = headingMatch ? headingMatch[1].trim() : null;

  const action = wantsCreate ? 'create_page' : 'update_page';
  const mode = wantsReplace && targetHeading ? 'replace_section' : 'append';

  const safeSummary = text.length ? text : 'No user message provided.';

  const content = [
    mode === 'append' ? '## Update' : '## Replacement Content',
    '',
    `- Requested change: ${safeSummary}`,
    '- Canon note: ED leader is always referenced as ED:[REDACTED].',
    '- Draft only. Avoid adding new canon facts unless explicitly requested.'
  ].join('\n');

  const plan = {
    action,
    page,
    mode,
    content_markdown: content
  };

  if (mode === 'replace_section') {
    plan.target_heading = targetHeading;
  }

  return plan;
}

async function registerCommands() {
  const command = new SlashCommandBuilder()
    .setName('lorekeeper')
    .setDescription('Start a lorekeeper session in this channel.')
    .addStringOption((opt) =>
      opt
        .setName('repo')
        .setDescription('Wiki repo URL override')
        .setRequired(false)
    );

  const rest = new REST({ version: '10' }).setToken(DISCORD_TOKEN);
  const body = [command.toJSON()];

  if (GUILD_ID) {
    await rest.put(Routes.applicationGuildCommands(DISCORD_CLIENT_ID, GUILD_ID), { body });
  } else {
    await rest.put(Routes.applicationCommands(DISCORD_CLIENT_ID), { body });
  }
}

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent],
  partials: [Partials.Channel]
});

const activeSessions = new Map();
const pendingPlans = new Map();

function buildPlanMessage(plan) {
  return `Plan generated. Review and confirm.\n\n\`\`\`json\n${JSON.stringify(plan, null, 2)}\n\`\`\``;
}

function buildActionRow(userId) {
  return new ActionRowBuilder().addComponents(
    new ButtonBuilder()
      .setCustomId(`apply:${userId}`)
      .setLabel('Apply Update')
      .setStyle(ButtonStyle.Success),
    new ButtonBuilder()
      .setCustomId(`cancel:${userId}`)
      .setLabel('Cancel')
      .setStyle(ButtonStyle.Secondary)
  );
}

client.once(Events.ClientReady, async () => {
  try {
    await registerCommands();
    const settings = readSettings();
    const repoUrl = settings.repoUrl || DEFAULT_REPO_URL;
    ensureRepo(repoUrl);
    console.log(`Lorekeeper bot ready as ${client.user.tag}`);
  } catch (err) {
    console.error('Startup error:', err.message || err);
  }
});

client.on(Events.InteractionCreate, async (interaction) => {
  if (interaction.isChatInputCommand() && interaction.commandName === 'lorekeeper') {
    const repoUrl = interaction.options.getString('repo');
    const settings = readSettings();
    const targetRepo = (repoUrl || settings.repoUrl || DEFAULT_REPO_URL).trim();

    try {
      ensureRepo(targetRepo);
      writeSettings({ repoUrl: targetRepo });
      activeSessions.set(interaction.user.id, interaction.channelId);
      await interaction.reply({
        content: `Lorekeeper session started in this channel. Canon rules: ${CANON_RULES.join(' | ')}\nSend messages and I will draft a plan before applying any changes.`,
        ephemeral: true
      });
    } catch (err) {
      await interaction.reply({ content: err.message || 'Failed to start session.', ephemeral: true });
    }
  }

  if (interaction.isButton()) {
    const [action, userId] = interaction.customId.split(':');
    if (interaction.user.id !== userId) {
      await interaction.reply({ content: 'Only the requester can confirm this update.', ephemeral: true });
      return;
    }

    const plan = pendingPlans.get(userId);
    if (!plan) {
      await interaction.reply({ content: 'No pending plan found.', ephemeral: true });
      return;
    }

    if (action === 'cancel') {
      pendingPlans.delete(userId);
      await interaction.update({ content: 'Update canceled.', components: [] });
      return;
    }

    if (action === 'apply') {
      try {
        applyUpdate(plan);
        commitAndPush(plan.page);
        pendingPlans.delete(userId);
        await interaction.update({ content: `Update applied and pushed to wiki for **${plan.page}**.`, components: [] });
      } catch (err) {
        await interaction.update({ content: err.message || 'Failed to apply update.', components: [] });
      }
    }
  }
});

client.on(Events.MessageCreate, async (message) => {
  if (message.author.bot) return;
  const channelId = activeSessions.get(message.author.id);
  if (!channelId || channelId !== message.channelId) return;

  const text = message.content.trim();
  if (!text) return;

  if (text.toLowerCase() === 'exit') {
    activeSessions.delete(message.author.id);
    pendingPlans.delete(message.author.id);
    await message.reply('Lorekeeper session ended.');
    return;
  }

  try {
    const plan = generatePlan(text, null);
    pendingPlans.set(message.author.id, plan);
    await message.reply({
      content: buildPlanMessage(plan),
      components: [buildActionRow(message.author.id)]
    });
  } catch (err) {
    await message.reply(err.message || 'Failed to generate plan.');
  }
});

client.login(DISCORD_TOKEN);
