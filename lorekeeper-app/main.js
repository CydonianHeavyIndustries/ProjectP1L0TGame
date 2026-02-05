const electron = require('electron');
const path = require('path');
const fs = require('fs');
const { execSync, spawn } = require('child_process');
const { log, logFile } = require('./logger');

if (Object.prototype.hasOwnProperty.call(process.env, 'ELECTRON_RUN_AS_NODE')) {
  const { spawnSync } = require('child_process');
  const electronBinary = process.env.ELECTRON_BINARY || path.join(__dirname, 'node_modules', '.bin', 'electron.cmd');
  spawnSync(electronBinary, [__dirname], {
    stdio: 'inherit',
    env: { ...process.env, ELECTRON_RUN_AS_NODE: '' }
  });
  process.exit(0);
}

const { app, BrowserWindow, ipcMain } = electron;
if (!app || !BrowserWindow || !ipcMain) {
  console.error('Electron app bootstrap failed: app is undefined. Ensure ELECTRON_RUN_AS_NODE is not set.');
  process.exit(1);
}

const DEFAULT_REPO_URL = 'https://github.com/CydonianHeavyIndustries/Project-P1L0T.wiki.git';
const CANON_RULES = [
  'ED leader is always referenced as: ED:[REDACTED]',
  'Avoid introducing new canon facts unless explicitly asked',
  'Edits should be minimal diffs; do not rewrite entire pages unless asked'
];

const WIKI_STRUCTURE_GUIDE = [
  'Core index pages: Home, Lore, Tech, Archive, Factions, Timeline.',
  'Wiki naming standard uses "Category - Topic" to simulate folders.',
  'If the user mentions a year or specific date, add/update the Timeline page with that event.',
  'If the user mentions CHII or Cydonian Heavy Industries, update the CHII page (prefer existing pages like "Cydonian-Heavy-Industries-Incorporated-(CHII)" or "Lore - CHII").',
  'If the user mentions ED or Ethereum Dynamics, update the ED page (prefer existing pages like "Ethereum-Dynamics-(ED)" or "Lore - Ethereum Dynamics").',
  'If the user mentions the Null Accord, update the TNA page (prefer existing pages like "The-Null-Accord-(TNA)" or "Lore - The Null Accord").',
  'If the user mentions Chorus, update the Chorus page (prefer existing pages like "Chorus" or "Lore - Chorus").',
  'If the user mentions a tech system, update the relevant Tech page (e.g., "Tech - <System>").',
  'Always prefer existing pages from the Available pages list; create pages only when needed.'
];

function logInfo(message, meta) {
  log('info', message, meta);
}

function logWarn(message, meta) {
  log('warn', message, meta);
}

function logError(message, meta) {
  log('error', message, meta);
}

let ollamaProcess = null;
let startedOllama = false;

const appRoot = path.resolve(__dirname);
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

function mergeSettings(partial) {
  const current = readSettings();
  writeSettings({ ...current, ...partial });
}

function getOpenAIConfig(settings) {
  const envFallback = process.env.OPENAI_FALLBACK;
  return {
    apiKey: process.env.OPENAI_API_KEY || settings.openaiApiKey || '',
    model: process.env.OPENAI_MODEL || settings.openaiModel || 'gpt-4o',
    stream: settings.openaiStream !== false,
    fallback: envFallback ? envFallback.toLowerCase() !== 'false' : settings.openaiFallback !== false,
    fallbackModel: process.env.OPENAI_FALLBACK_MODEL || settings.openaiFallbackModel || 'gpt-4o-mini'
  };
}

function getOllamaConfig(settings) {
  return {
    host: process.env.OLLAMA_HOST || settings.ollamaHost || 'http://localhost:11434',
    model: process.env.OLLAMA_MODEL || settings.ollamaModel || ''
  };
}

function getAIConfig() {
  const settings = readSettings();
  const openai = getOpenAIConfig(settings);
  const ollama = getOllamaConfig(settings);
  const envProvider = process.env.AI_PROVIDER;
  let provider = envProvider || settings.aiProvider || (openai.apiKey ? 'openai' : 'ollama');
  if (provider === 'openai' && !openai.apiKey) {
    provider = 'ollama';
  }
  return { provider, openai, ollama };
}

function isLocalHost(host) {
  try {
    const url = new URL(host);
    return url.hostname === 'localhost' || url.hostname === '127.0.0.1';
  } catch {
    return false;
  }
}

function getOllamaBinaryPath() {
  const envPath = process.env.OLLAMA_PATH;
  if (envPath && fs.existsSync(envPath)) return envPath;
  const localAppData = process.env.LOCALAPPDATA || '';
  const defaultPath = path.join(localAppData, 'Programs', 'Ollama', 'ollama.exe');
  if (defaultPath && fs.existsSync(defaultPath)) return defaultPath;
  return 'ollama';
}

async function probeOllama(host, timeoutMs = 1200) {
  if (typeof fetch !== 'function') return false;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(`${host}/api/tags`, { signal: controller.signal });
    return res.ok;
  } catch {
    return false;
  } finally {
    clearTimeout(timeout);
  }
}

async function waitForOllama(host, attempts = 12, delayMs = 500) {
  for (let i = 0; i < attempts; i += 1) {
    if (await probeOllama(host)) return true;
    await new Promise((resolve) => setTimeout(resolve, delayMs));
  }
  return false;
}

async function startOllamaServer() {
  const { ollama } = getAIConfig();
  if (!ollama.host) return;
  if (!isLocalHost(ollama.host)) {
    logInfo('ollama_host_remote', { host: ollama.host });
    return;
  }
  if (await probeOllama(ollama.host)) {
    logInfo('ollama_already_running');
    return;
  }

  try {
    logInfo('ollama_starting');
    const binary = getOllamaBinaryPath();
    ollamaProcess = spawn(binary, ['serve'], {
      detached: true,
      stdio: 'ignore',
      windowsHide: true
    });
    startedOllama = true;
    ollamaProcess.unref();
  } catch (err) {
    logError('ollama_start_failed', { message: err.message || String(err) });
    return;
  }

  const ready = await waitForOllama(ollama.host);
  if (ready) {
    logInfo('ollama_ready');
  } else {
    logWarn('ollama_start_timeout');
  }
}

function stopOllamaServer() {
  if (!startedOllama || !ollamaProcess || !ollamaProcess.pid) return;
  logInfo('ollama_stopping', { pid: ollamaProcess.pid });
  try {
    process.kill(ollamaProcess.pid);
  } catch (err) {
    try {
      execSync(`taskkill /PID ${ollamaProcess.pid} /T /F`);
    } catch (killErr) {
      logError('ollama_stop_failed', { message: killErr.message || String(killErr) });
    }
  }
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

function normalizePlan(plan) {
  if (!plan || typeof plan !== 'object') throw new Error('Invalid plan payload.');
  if (Array.isArray(plan.actions)) {
    return { assistant_message: plan.assistant_message || '', actions: plan.actions };
  }
  if (plan.action) {
    return {
      assistant_message: plan.assistant_message || '',
      actions: [
        {
          action: plan.action,
          page: plan.page,
          mode: plan.mode,
          target_heading: plan.target_heading,
          content_markdown: plan.content_markdown
        }
      ]
    };
  }
  throw new Error('Plan missing required fields.');
}

function validatePlan(plan) {
  const normalized = normalizePlan(plan);
  if (!Array.isArray(normalized.actions) || normalized.actions.length === 0) {
    throw new Error('Plan must include at least one action.');
  }
  for (const action of normalized.actions) {
    if (!action.action || !action.page || !action.mode || !action.content_markdown) {
      throw new Error('Plan action missing required fields.');
    }
    if (action.mode === 'replace_section' && !action.target_heading) {
      throw new Error('replace_section requires target_heading.');
    }
  }
  return normalized;
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
  const normalized = validatePlan(plan);
  for (const action of normalized.actions) {
    validateCanon(action.content_markdown);
    const filePath = pagePathFromTitle(action.page);
    const exists = fs.existsSync(filePath);

    if (action.action === 'create_page') {
      if (exists) {
        throw new Error(`Page already exists: ${action.page}`);
      }
      fs.writeFileSync(filePath, action.content_markdown.replace(/\s*$/g, '') + '\n', 'utf8');
      continue;
    }

    if (!exists) {
      throw new Error(`Page not found for update: ${action.page}`);
    }

    const current = fs.readFileSync(filePath, 'utf8');
    let updated = current;

    if (action.mode === 'append') {
      const trimmed = current.replace(/\s*$/g, '');
      updated = `${trimmed}\n\n${action.content_markdown.replace(/\s*$/g, '')}\n`;
    } else if (action.mode === 'replace_section') {
      updated = replaceSection(current, action.target_heading, action.content_markdown);
      updated = updated.replace(/\s*$/g, '') + '\n';
    } else {
      throw new Error(`Unsupported mode: ${action.mode}`);
    }

    fs.writeFileSync(filePath, updated, 'utf8');
  }
}

function gitStatusPorcelain() {
  return runGit('status --porcelain');
}

function commitAndPush(message) {
  configureGitIdentity();
  if (!getAuthHeader()) {
    throw new Error('GITHUB_USER and GITHUB_TOKEN are required to push changes.');
  }
  const status = gitStatusPorcelain();
  if (!status.trim()) {
    throw new Error('No changes to commit.');
  }
  runGit('add -A');
  runGit(`commit -m "Lorekeeper: ${message}"`);
  runGit('push');
}

function extractPageTitle(text) {
  const quoted = text.match(/\"([^\"]+)\"|\'([^\']+)\'/);
  if (quoted) return (quoted[1] || quoted[2] || '').trim();

  const prefixes = ['Home', 'Lore', 'Tech', 'Archive', 'Factions'];
  for (const prefix of prefixes) {
    const match = text.match(new RegExp(`\\b${prefix}(?:\\s-\\s[^\\n]+)?`, 'i'));
    if (match) return match[0].trim();
  }

  return null;
}

function generatePlanFallback(userMessage, selectedPage) {
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

  const actionItem = {
    action,
    page,
    mode,
    content_markdown: content
  };

  if (mode === 'replace_section') {
    actionItem.target_heading = targetHeading;
  }

  return {
    assistant_message: 'Drafted a minimal update plan based on your request.',
    actions: [actionItem]
  };
}

function getResponseFormat(model) {
  const schema = {
    type: 'object',
    additionalProperties: false,
    properties: {
      assistant_message: { type: 'string' },
      actions: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          properties: {
            action: { type: 'string', enum: ['update_page', 'create_page'] },
            page: { type: 'string' },
            mode: { type: 'string', enum: ['append', 'replace_section'] },
            target_heading: { type: 'string' },
            content_markdown: { type: 'string' }
          },
          required: ['action', 'page', 'mode', 'content_markdown']
        },
        minItems: 1
      }
    },
    required: ['assistant_message', 'actions']
  };

  if (/gpt-4o-mini|gpt-4o-2024-08-06/i.test(model)) {
    return { type: 'json_schema', name: 'lorekeeper_plan', schema, strict: true };
  }

  return { type: 'json_object' };
}

function buildSystemPrompt() {
  return [
    'You are Lorekeeper, a careful lore editor for the Project P1L0T wiki.',
    'You must follow these canon rules:',
    ...CANON_RULES.map((rule) => `- ${rule}`),
    'Wiki structure rules:',
    ...WIKI_STRUCTURE_GUIDE.map((rule) => `- ${rule}`),
    'You must propose minimal diffs and avoid rewriting entire pages unless explicitly asked.',
    'Do not introduce new canon facts unless explicitly requested.',
    'Use the full conversation history as the source of facts, even if the latest user message is just a go-ahead.',
    'Return only a JSON object that matches the required schema.',
    'The JSON must include an assistant_message for the user and an actions array.',
    'If mode is replace_section, include target_heading with the full markdown heading (e.g., \"## Heading\").',
    'When a user message implies multiple updates, include multiple actions.'
  ].join('\n');
}

function buildChatSystemPrompt() {
  return [
    'You are Lorekeeper, a lore conversation partner for the Project P1L0T wiki.',
    'Follow canon rules strictly:',
    ...CANON_RULES.map((rule) => `- ${rule}`),
    'Wiki structure guidance:',
    ...WIKI_STRUCTURE_GUIDE.map((rule) => `- ${rule}`),
    'When the user shares lore facts, infer which existing pages should be updated and say so plainly.',
    'Do not output JSON or a formal plan here. Instead summarize intended updates in natural language.',
    'If the user mentions a year or date, explicitly mention adding it to Timeline.',
    'If the user mentions CHII/ED/TNA/Chorus/Tech topics, mention the relevant page(s) you would update.',
    'Ask clarifying questions only when needed to avoid introducing new canon facts.',
    'End with a short prompt like: "Say start edits when you want me to draft the changes."',
    'Keep responses concise and helpful.'
  ].join('\n');
}

function buildWikiContext(userMessage, selectedPage) {
  const pages = listPages();
  if (pages.length === 0) {
    return {
      context: 'No wiki pages found yet.',
      selectedPage: selectedPage || extractPageTitle(userMessage) || 'Home'
    };
  }

  const contextBlocks = [];
  let totalChars = 0;
  const maxChars = 12000;

  for (const page of pages) {
    if (totalChars > maxChars) break;
    const filePath = pagePathFromTitle(page);
    if (!fs.existsSync(filePath)) continue;
    const content = fs.readFileSync(filePath, 'utf8').trim();
    const excerpt = content.slice(0, 1200);
    contextBlocks.push(`### ${page}\n${excerpt}${content.length > excerpt.length ? '\n...[truncated]' : ''}`);
    totalChars += excerpt.length;
  }

  return {
    context: contextBlocks.join('\n\n'),
    selectedPage: selectedPage || extractPageTitle(userMessage) || 'Home'
  };
}

function formatHistory(history) {
  if (!Array.isArray(history) || history.length === 0) return 'No prior conversation.';
  return history
    .slice(-12)
    .map((item) => `${item.role === 'user' ? 'User' : 'Assistant'}: ${item.text}`)
    .join('\n');
}

function buildUserPrompt(userMessage, selectedPage, history) {
  const pages = listPages().join(', ') || '(no pages found)';
  const wiki = buildWikiContext(userMessage, selectedPage);

  return [
    'Conversation history:',
    formatHistory(history),
    `User request: ${userMessage}`,
    `Selected page: ${wiki.selectedPage}`,
    `Available pages: ${pages}`,
    'Wiki excerpts:',
    '<<<',
    wiki.context,
    '>>>'
  ].join('\n');
}

function extractTextFromResponse(responseJson) {
  if (responseJson.output_text && typeof responseJson.output_text === 'string') {
    return responseJson.output_text;
  }
  if (Array.isArray(responseJson.output)) {
    const chunks = [];
    for (const item of responseJson.output) {
      if (item.type === 'message' && Array.isArray(item.content)) {
        for (const content of item.content) {
          if (content.type === 'output_text') chunks.push(content.text || '');
        }
      }
    }
    if (chunks.length) return chunks.join('');
  }
  return '';
}

function isModelAccessError(errorText) {
  return /model_not_found|does not have access to model/i.test(errorText);
}

function isAbortError(err) {
  return err && (err.name === 'AbortError' || /aborted|timeout/i.test(err.message || ''));
}

async function fetchWithTimeout(url, options = {}, timeoutMs = 45000) {
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(url, { ...options, signal: controller.signal });
  } catch (err) {
    if (isAbortError(err)) {
      const timeoutErr = new Error(`Request timed out after ${timeoutMs}ms.`);
      timeoutErr.name = 'TimeoutError';
      throw timeoutErr;
    }
    throw err;
  } finally {
    clearTimeout(timeout);
  }
}

async function listOpenAIModels() {
  const { openai } = getAIConfig();
  const { apiKey } = openai;
  if (!apiKey) {
    throw new Error('OpenAI API key missing. Add it in Settings or set OPENAI_API_KEY.');
  }
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }

  const res = await fetch('https://api.openai.com/v1/models', {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${apiKey}`
    }
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`OpenAI request failed (${res.status}): ${errorText}`);
  }

  const json = await res.json();
  const models = Array.isArray(json.data) ? json.data.map((item) => item.id) : [];
  return models
    .filter((id) => typeof id === 'string')
    .sort((a, b) => a.localeCompare(b));
}

async function listOllamaModels() {
  const { ollama } = getAIConfig();
  if (!ollama.host) {
    throw new Error('Ollama host not set.');
  }
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }

  try {
    const res = await fetch(`${ollama.host}/api/tags`, {
      method: 'GET'
    });

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`Ollama request failed (${res.status}): ${errorText}`);
    }

    const json = await res.json();
    const models = Array.isArray(json.models) ? json.models.map((item) => item.name) : [];
    return models
      .filter((id) => typeof id === 'string')
      .sort((a, b) => a.localeCompare(b));
  } catch (err) {
    logWarn('ollama_list_fallback', { message: err.message || String(err) });
    return listOllamaModelsFromDisk();
  }
}

function listOllamaModelsFromDisk() {
  const root = path.join(process.env.USERPROFILE || '', '.ollama', 'models', 'manifests');
  if (!root || !fs.existsSync(root)) {
    throw new Error('Ollama not running and local models not found.');
  }

  const models = new Set();
  const files = [];
  const stack = [root];
  while (stack.length) {
    const current = stack.pop();
    if (!current) continue;
    const entries = fs.readdirSync(current, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(current, entry.name);
      if (entry.isDirectory()) {
        stack.push(fullPath);
      } else {
        files.push(fullPath);
      }
    }
  }

  for (const filePath of files) {
    const parts = filePath.split(path.sep);
    const idx = parts.indexOf('library');
    if (idx >= 0 && parts.length > idx + 2) {
      const name = parts[idx + 1];
      const tag = parts[idx + 2];
      if (name && tag) {
        models.add(`${name}:${tag}`);
      }
    }
  }

  const list = [...models];
  if (list.length === 0) {
    throw new Error('No local Ollama models found.');
  }
  return list.sort((a, b) => a.localeCompare(b));
}

function pickBestOllamaModel(models) {
  if (!Array.isArray(models) || models.length === 0) return '';
  const preferred = [
    'llama3.1:8b',
    'llama3:latest',
    'qwen2.5-coder:7b',
    'qwen2.5-coder:latest',
    'codellama:13b',
    'codellama:7b'
  ];
  for (const name of preferred) {
    const match = models.find((m) => m.toLowerCase() === name);
    if (match) return match;
  }
  return models[0];
}

async function requestOpenAIPlan(event, userMessage, selectedPage, options = {}) {
  const { openai } = getAIConfig();
  const { apiKey, model, stream, fallback, fallbackModel } = openai;
  if (!apiKey) {
    throw new Error('OpenAI API key missing. Add it in Settings or set OPENAI_API_KEY.');
  }
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }
  logInfo('openai_plan_request', { model, stream: options.stream !== false && stream });

  const systemPrompt = buildSystemPrompt();
  const userPrompt = buildUserPrompt(userMessage, selectedPage, options.history);
  const responseFormat = getResponseFormat(model);

  const payload = {
    model,
    instructions: systemPrompt,
    input: userPrompt,
    text: { format: responseFormat },
    temperature: 0.2,
    stream: options.stream !== false && stream
  };
  let res;
  try {
    res = await fetchWithTimeout(
      'https://api.openai.com/v1/responses',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`
        },
        body: JSON.stringify(payload)
      },
      120000
    );
  } catch (err) {
    if (err && err.name === 'TimeoutError') {
      logError('openai_plan_timeout', { model });
      throw new Error('OpenAI request timed out. Try again or reduce the request size.');
    }
    throw err;
  }

  if (!res.ok) {
    const errorText = await res.text();
    logError('openai_plan_error', { status: res.status, model, message: errorText });
    if (res.status === 403 && fallback && isModelAccessError(errorText)) {
      logWarn('openai_plan_fallback', { from: model, to: fallbackModel });
      const fallbackPayload = { ...payload, model: fallbackModel, text: { format: getResponseFormat(fallbackModel) } };
      let retry;
      try {
        retry = await fetchWithTimeout(
          'https://api.openai.com/v1/responses',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${apiKey}`
            },
            body: JSON.stringify(fallbackPayload)
          },
          120000
        );
      } catch (err) {
        if (err && err.name === 'TimeoutError') {
          logError('openai_plan_timeout', { model: fallbackModel });
          throw new Error('OpenAI fallback request timed out. Try again or reduce the request size.');
        }
        throw err;
      }
      if (!retry.ok) {
        const retryText = await retry.text();
        throw new Error(`OpenAI request failed (${retry.status}): ${retryText}`);
      }
      const fallbackResult = await handleResponsesResult(event, retry, fallbackPayload);
      logInfo('openai_plan_complete', { model: fallbackModel, actions: fallbackResult.actions.length });
      return fallbackResult;
    }
    throw new Error(`OpenAI request failed (${res.status}): ${errorText}`);
  }
  const result = await handleResponsesResult(event, res, payload);
  logInfo('openai_plan_complete', { model, actions: result.actions.length });
  return result;
}

async function handleResponsesResult(event, res, payload) {
  if (!payload.stream) {
    const json = await res.json();
    const text = extractTextFromResponse(json);
    if (!text) throw new Error('OpenAI response was empty.');
    const plan = JSON.parse(text);
    const normalized = validatePlan(plan);
    for (const action of normalized.actions) {
      validateCanon(action.content_markdown);
    }
    return normalized;
  }

  const reader = res.body.getReader();
  const decoder = new TextDecoder('utf-8');
  let buffer = '';
  let outputText = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });

    const parts = buffer.split('\n\n');
    buffer = parts.pop() || '';

    for (const part of parts) {
      const lines = part.split('\n').filter(Boolean);
      for (const line of lines) {
        if (!line.startsWith('data:')) continue;
        const data = line.replace(/^data:\s*/, '');
        if (data === '[DONE]') continue;
        let eventPayload = null;
        try {
          eventPayload = JSON.parse(data);
        } catch {
          continue;
        }
        if (eventPayload.type === 'response.output_text.delta' && typeof eventPayload.delta === 'string') {
          outputText += eventPayload.delta;
          event.sender.send('ai:plan-delta', eventPayload.delta);
        }
        if (eventPayload.type === 'response.output_text.done' && typeof eventPayload.text === 'string') {
          outputText += eventPayload.text;
        }
        if (eventPayload.type === 'response.completed' && eventPayload.response) {
          const finalText = extractTextFromResponse(eventPayload.response);
          if (finalText) outputText = finalText;
        }
      }
    }
  }

  if (!outputText.trim()) {
    throw new Error('OpenAI response was empty.');
  }

  const plan = JSON.parse(outputText);
  const normalized = validatePlan(plan);
  for (const action of normalized.actions) {
    validateCanon(action.content_markdown);
  }
  return normalized;
}

async function requestOpenAIChat(userMessage, options = {}) {
  const { openai } = getAIConfig();
  const { apiKey, model, fallback, fallbackModel } = openai;
  if (!apiKey) {
    throw new Error('OpenAI API key missing. Add it in Settings or set OPENAI_API_KEY.');
  }
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }
  logInfo('openai_chat_request', { model });

  const systemPrompt = buildChatSystemPrompt();
  const userPrompt = buildUserPrompt(userMessage, null, options.history);

  const payload = {
    model,
    instructions: systemPrompt,
    input: userPrompt,
    temperature: 0.4,
    stream: false
  };

  let res;
  try {
    res = await fetchWithTimeout(
      'https://api.openai.com/v1/responses',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`
        },
        body: JSON.stringify(payload)
      },
      90000
    );
  } catch (err) {
    if (err && err.name === 'TimeoutError') {
      logError('openai_chat_timeout', { model });
      throw new Error('OpenAI request timed out. Try again or reduce the request size.');
    }
    throw err;
  }

  if (!res.ok) {
    const errorText = await res.text();
    logError('openai_chat_error', { status: res.status, model, message: errorText });
    if (res.status === 403 && fallback && isModelAccessError(errorText)) {
      logWarn('openai_chat_fallback', { from: model, to: fallbackModel });
      const fallbackPayload = { ...payload, model: fallbackModel };
      let retry;
      try {
        retry = await fetchWithTimeout(
          'https://api.openai.com/v1/responses',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${apiKey}`
            },
            body: JSON.stringify(fallbackPayload)
          },
          45000
        );
      } catch (err) {
        if (err && err.name === 'TimeoutError') {
          logError('openai_chat_timeout', { model: fallbackModel });
          throw new Error('OpenAI fallback request timed out. Try again or reduce the request size.');
        }
        throw err;
      }
      if (!retry.ok) {
        const retryText = await retry.text();
        throw new Error(`OpenAI request failed (${retry.status}): ${retryText}`);
      }
      const retryJson = await retry.json();
      const retryText = extractTextFromResponse(retryJson);
      if (!retryText) throw new Error('OpenAI response was empty.');
      logInfo('openai_chat_complete', { model: fallbackModel, chars: retryText.length });
      return retryText;
    }
    throw new Error(`OpenAI request failed (${res.status}): ${errorText}`);
  }

  const json = await res.json();
  const text = extractTextFromResponse(json);
  if (!text) throw new Error('OpenAI response was empty.');
  logInfo('openai_chat_complete', { model, chars: text.length });
  return text;
}

function extractJsonFromText(text) {
  const trimmed = (text || '').trim();
  if (!trimmed) return '';
  if (trimmed.startsWith('{') && trimmed.endsWith('}')) return trimmed;
  const first = trimmed.indexOf('{');
  const last = trimmed.lastIndexOf('}');
  if (first >= 0 && last > first) {
    return trimmed.slice(first, last + 1);
  }
  return '';
}

function buildOllamaMessages(userMessage, history, systemPrompt) {
  const messages = [];
  if (systemPrompt) {
    messages.push({ role: 'system', content: systemPrompt });
  }
  if (Array.isArray(history)) {
    for (const item of history.slice(-12)) {
      const role = item.role === 'user' ? 'user' : 'assistant';
      messages.push({ role, content: item.text });
    }
  }
  messages.push({ role: 'user', content: userMessage });
  return messages;
}

async function requestOllamaChat(userMessage, options = {}) {
  const { ollama } = getAIConfig();
  if (!ollama.host) {
    throw new Error('Ollama host not set.');
  }
  if (!ollama.model) {
    throw new Error('Ollama model not set. Use Settings to select a model.');
  }
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }
  logInfo('ollama_chat_request', { model: ollama.model, host: ollama.host });

  const payload = {
    model: ollama.model,
    messages: buildOllamaMessages(userMessage, options.history, buildChatSystemPrompt()),
    stream: false
  };

  let res;
  try {
    res = await fetchWithTimeout(
      `${ollama.host}/api/chat`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      },
      45000
    );
  } catch (err) {
    if (err && err.name === 'TimeoutError') {
      logError('ollama_chat_timeout', { model: ollama.model, host: ollama.host });
      throw new Error('Ollama request timed out. Check that the model is running and try again.');
    }
    throw err;
  }

  if (!res.ok) {
    const errorText = await res.text();
    logError('ollama_chat_error', { status: res.status, model: ollama.model, message: errorText });
    throw new Error(`Ollama request failed (${res.status}): ${errorText}`);
  }

  const json = await res.json();
  const reply = json && json.message && typeof json.message.content === 'string' ? json.message.content : '';
  if (!reply) throw new Error('Ollama response was empty.');
  logInfo('ollama_chat_complete', { model: ollama.model, chars: reply.length });
  return reply;
}

async function requestOllamaPlan(userMessage, selectedPage, options = {}) {
  const { ollama } = getAIConfig();
  if (!ollama.host) {
    throw new Error('Ollama host not set.');
  }
  if (!ollama.model) {
    throw new Error('Ollama model not set. Use Settings to select a model.');
  }
  if (typeof fetch !== 'function') {
    throw new Error('Fetch API not available in this runtime.');
  }
  logInfo('ollama_plan_request', { model: ollama.model, host: ollama.host });

  const userPrompt = buildUserPrompt(userMessage, selectedPage, options.history);
  const payload = {
    model: ollama.model,
    messages: buildOllamaMessages(userPrompt, [], buildSystemPrompt()),
    stream: false
  };

  let res;
  try {
    res = await fetchWithTimeout(
      `${ollama.host}/api/chat`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      },
      180000
    );
  } catch (err) {
    if (err && err.name === 'TimeoutError') {
      logError('ollama_plan_timeout', { model: ollama.model, host: ollama.host });
      throw new Error('Ollama request timed out while generating the plan. Try again or reduce the request size.');
    }
    throw err;
  }

  if (!res.ok) {
    const errorText = await res.text();
    logError('ollama_plan_error', { status: res.status, model: ollama.model, message: errorText });
    throw new Error(`Ollama request failed (${res.status}): ${errorText}`);
  }

  const json = await res.json();
  const reply = json && json.message && typeof json.message.content === 'string' ? json.message.content : '';
  if (!reply) throw new Error('Ollama response was empty.');
  logInfo('ollama_plan_complete', { model: ollama.model, chars: reply.length });

  const jsonText = extractJsonFromText(reply);
  if (!jsonText) {
    throw new Error('Ollama response did not include valid JSON.');
  }
  const plan = JSON.parse(jsonText);
  const normalized = validatePlan(plan);
  for (const action of normalized.actions) {
    validateCanon(action.content_markdown);
  }
  return normalized;
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  win.loadFile('index.html');
}

process.on('uncaughtException', (err) => {
  logError('uncaughtException', { message: err.message || String(err), stack: err.stack });
});

process.on('unhandledRejection', (reason) => {
  logError('unhandledRejection', { reason: reason && reason.message ? reason.message : String(reason) });
});

app.whenReady().then(() => {
  logInfo('app_ready', { logFile });
  startOllamaServer();
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('before-quit', () => {
  stopOllamaServer();
});

ipcMain.handle('repo:get-status', () => {
  const settings = readSettings();
  const repoUrl = settings.repoUrl || DEFAULT_REPO_URL;
  const gitDir = path.join(wikiDir, '.git');
  return {
    exists: fs.existsSync(gitDir),
    repoUrl,
    dataDir: wikiDir,
    canonRules: CANON_RULES
  };
});

ipcMain.handle('repo:setup', (_event, repoUrl) => {
  const url = (repoUrl || DEFAULT_REPO_URL).trim();
  mergeSettings({ repoUrl: url });
  ensureRepo(url);
  return { success: true };
});

ipcMain.handle('repo:sync', () => {
  try {
    if (!fs.existsSync(path.join(wikiDir, '.git'))) {
      throw new Error('Wiki repo not initialized.');
    }
    logInfo('repo_sync_start');
    const output = runGit('pull --ff-only');
    logInfo('repo_sync_complete');
    return { output };
  } catch (err) {
    logError('repo_sync_error', { message: err.message || String(err) });
    throw err;
  }
});

ipcMain.handle('pages:list', () => listPages());

ipcMain.handle('pages:read', (_event, title) => {
  const filePath = pagePathFromTitle(title);
  if (!fs.existsSync(filePath)) throw new Error('Page not found.');
  return fs.readFileSync(filePath, 'utf8');
});

ipcMain.handle('settings:get', () => {
  const settings = readSettings();
  const { provider, openai, ollama } = getAIConfig();
  return {
    repoUrl: settings.repoUrl || DEFAULT_REPO_URL,
    aiProvider: provider,
    openaiModel: openai.model,
    openaiStream: openai.stream,
    hasOpenAIKey: Boolean(openai.apiKey),
    openaiFallback: openai.fallback,
    openaiFallbackModel: openai.fallbackModel,
    ollamaHost: ollama.host,
    ollamaModel: ollama.model
  };
});

ipcMain.handle('settings:save', (_event, payload) => {
  const next = { ...readSettings() };
  if (payload.repoUrl) next.repoUrl = payload.repoUrl.trim();
  if (typeof payload.aiProvider === 'string' && payload.aiProvider.trim()) {
    next.aiProvider = payload.aiProvider.trim();
  }
  if (typeof payload.openaiModel === 'string' && payload.openaiModel.trim()) {
    next.openaiModel = payload.openaiModel.trim();
  }
  if (typeof payload.openaiStream === 'boolean') {
    next.openaiStream = payload.openaiStream;
  }
  if (typeof payload.openaiFallback === 'boolean') {
    next.openaiFallback = payload.openaiFallback;
  }
  if (typeof payload.openaiFallbackModel === 'string' && payload.openaiFallbackModel.trim()) {
    next.openaiFallbackModel = payload.openaiFallbackModel.trim();
  }
  if (typeof payload.ollamaHost === 'string' && payload.ollamaHost.trim()) {
    next.ollamaHost = payload.ollamaHost.trim();
  }
  if (typeof payload.ollamaModel === 'string') {
    next.ollamaModel = payload.ollamaModel.trim();
  }
  if (typeof payload.openaiApiKey === 'string') {
    if (payload.openaiApiKey.trim()) {
      next.openaiApiKey = payload.openaiApiKey.trim();
    } else {
      delete next.openaiApiKey;
    }
  }
  writeSettings(next);
  return { success: true };
});

ipcMain.handle('ai:generate-plan', (event, message, selectedPage, options) => {
  const { provider } = getAIConfig();
  if (provider === 'ollama') {
    return requestOllamaPlan(message, selectedPage, options);
  }
  return requestOpenAIPlan(event, message, selectedPage, options);
});

ipcMain.handle('ai:chat', (_event, message, options) => {
  const { provider } = getAIConfig();
  if (provider === 'ollama') {
    return requestOllamaChat(message, options);
  }
  return requestOpenAIChat(message, options);
});

ipcMain.handle('openai:list-models', () => {
  return listOpenAIModels();
});

ipcMain.handle('ollama:list-models', () => {
  return listOllamaModels();
});

ipcMain.handle('log:write', (_event, level, message, meta) => {
  log(level || 'info', message || '', meta);
  return { success: true };
});

ipcMain.handle('log:path', () => ({ path: logFile }));

ipcMain.handle('wiki:apply-draft', (_event, plan) => {
  if (!fs.existsSync(path.join(wikiDir, '.git'))) {
    throw new Error('Wiki repo not initialized.');
  }

  applyUpdate(plan);
  return { success: true };
});

ipcMain.handle('wiki:diff', () => {
  if (!fs.existsSync(path.join(wikiDir, '.git'))) {
    throw new Error('Wiki repo not initialized.');
  }
  return runGit('diff');
});

ipcMain.handle('wiki:commit-push', (_event, plan) => {
  if (!fs.existsSync(path.join(wikiDir, '.git'))) {
    throw new Error('Wiki repo not initialized.');
  }
  const normalized = validatePlan(plan);
  const pages = [...new Set(normalized.actions.map((action) => action.page))];
  const message = pages.length ? `update ${pages.join(', ')}` : 'update lore';
  commitAndPush(message);
  return { success: true };
});

