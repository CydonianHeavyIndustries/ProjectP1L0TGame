const state = {
  selectedPage: null,
  plan: null,
  chatHistory: []
};

const setupSection = document.getElementById('setup');
const mainSection = document.getElementById('main');
const repoInput = document.getElementById('repo-url');
const cloneBtn = document.getElementById('clone-btn');
const setupStatus = document.getElementById('setup-status');

const syncBtn = document.getElementById('sync-btn');
const pageList = document.getElementById('page-list');
const pageTitle = document.getElementById('page-title');
const pagePreview = document.getElementById('page-preview');
const canonRules = document.getElementById('canon-rules');
const applyBtn = document.getElementById('apply-btn');
const checkBtn = document.getElementById('check-btn');
const pushBtn = document.getElementById('push-btn');
const settingsBtn = document.getElementById('settings-btn');
const settingsPanel = document.getElementById('settings-panel');
const settingsClose = document.getElementById('settings-close');
const providerSelect = document.getElementById('ai-provider');
const ollamaSettings = document.getElementById('ollama-settings');
const openaiSettings = document.getElementById('openai-settings');
const ollamaHostInput = document.getElementById('ollama-host');
const ollamaModelInput = document.getElementById('ollama-model');
const fetchOllamaModelsBtn = document.getElementById('fetch-ollama-models');
const ollamaModelsList = document.getElementById('ollama-models');
const apiKeyInput = document.getElementById('openai-key');
const modelInput = document.getElementById('openai-model');
const fetchModelsBtn = document.getElementById('fetch-models');
const modelsList = document.getElementById('openai-models');
const streamToggle = document.getElementById('openai-stream');
const fallbackToggle = document.getElementById('openai-fallback');
const fallbackModelInput = document.getElementById('openai-fallback-model');
const saveSettingsBtn = document.getElementById('save-settings');
const settingsStatus = document.getElementById('settings-status');
const indexToggle = document.getElementById('index-toggle');
const indexPanel = document.getElementById('index-panel');
const chatPanel = document.getElementById('chat-panel');
const logPath = document.getElementById('log-path');
const copyLogBtn = document.getElementById('copy-log');

const chatLog = document.getElementById('chat-log');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-btn');
const chatStatus = document.getElementById('chat-status');
const planOutput = document.getElementById('plan-output');
const diffOutput = document.getElementById('diff-output');

let planDeltaCleanup = null;
let settingsSnapshot = { hasOpenAIKey: false };
let draftApplied = false;
const waxSeal = document.getElementById('wax-seal');

function logEvent(level, message, meta) {
  if (window.lorekeeper && typeof window.lorekeeper.log === 'function') {
    window.lorekeeper.log(level, message, meta).catch(() => {});
  }
}

function pickBestModel(models) {
  if (!Array.isArray(models) || models.length === 0) return '';
  const preferred = [
    'llama3.1:8b',
    'llama3:latest',
    'qwen2.5-coder:7b',
    'qwen2.5-coder:latest',
    'codellama:13b',
    'codellama:7b'
  ];
  const lower = models.map((m) => m.toLowerCase());
  for (const pref of preferred) {
    const idx = lower.indexOf(pref);
    if (idx >= 0) return models[idx];
  }
  return models[0];
}

function parseModelSize(modelId) {
  if (!modelId) return Number.POSITIVE_INFINITY;
  const match = modelId.toLowerCase().match(/(\d+(?:\.\d+)?)b/);
  if (!match) return Number.POSITIVE_INFINITY;
  const value = Number.parseFloat(match[1]);
  return Number.isFinite(value) ? value : Number.POSITIVE_INFINITY;
}

function pickFastModel(models, currentModel) {
  if (!Array.isArray(models) || models.length === 0) return '';
  const scored = models
    .map((model) => ({
      model,
      score: parseModelSize(model),
      isCurrent: model === currentModel
    }))
    .sort((a, b) => {
      if (a.score !== b.score) return a.score - b.score;
      if (a.isCurrent !== b.isCurrent) return a.isCurrent ? 1 : -1;
      return a.model.localeCompare(b.model);
    });
  const candidate = scored.find((item) => !item.isCurrent) || scored[0];
  return candidate ? candidate.model : models[0];
}

function updateProviderUI() {
  const provider = providerSelect.value;
  ollamaSettings.classList.toggle('hidden', provider !== 'ollama');
  openaiSettings.classList.toggle('hidden', provider !== 'openai');
}

function setStatus(el, text, isError = false) {
  el.textContent = text;
  el.classList.toggle('error', isError);
}

function showSetup(defaultUrl) {
  repoInput.value = defaultUrl;
  setupSection.classList.remove('hidden');
  mainSection.classList.add('hidden');
}

function showMain() {
  setupSection.classList.add('hidden');
  mainSection.classList.remove('hidden');
}

function toggleIndex(show) {
  indexPanel.classList.toggle('hidden', !show);
  chatPanel.classList.toggle('hidden', show);
  indexToggle.textContent = show ? 'Show Chat' : 'Show Index';
}

async function ensureOllamaModel(settings) {
  if (!settings || settings.aiProvider !== 'ollama') return settings;
  if (settings.ollamaModel) return settings;
  try {
    setStatus(settingsStatus, 'Detecting local Ollama models...');
    const models = await window.lorekeeper.listOllamaModels();
    if (models.length > 0) {
      const best = pickBestModel(models);
      await window.lorekeeper.saveSettings({ aiProvider: 'ollama', ollamaModel: best });
      settings.ollamaModel = best;
      ollamaModelInput.value = best;
      setStatus(settingsStatus, `Auto-selected ${best}.`);
      logEvent('info', 'ollama_auto_selected', { model: best });
    }
  } catch (err) {
    setStatus(settingsStatus, err.message || 'Failed to auto-select model.', true);
    logEvent('error', 'ollama_auto_select_failed', { message: err.message || String(err) });
  }
  return settings;
}

function toggleSettings(show) {
  settingsPanel.classList.toggle('hidden', !show);
}

function addChatMessage(role, text) {
  const item = document.createElement('div');
  item.className = `chat-item ${role}`;

  const row = document.createElement('div');
  row.className = 'chat-row';

  const avatar = document.createElement('div');
  avatar.className = `chat-avatar ${role}`;
  avatar.textContent = role === 'user' ? 'Y' : 'L';

  const content = document.createElement('div');
  content.className = 'chat-content';

  const meta = document.createElement('div');
  meta.className = 'chat-meta';

  const name = document.createElement('span');
  name.className = 'chat-name';
  name.textContent = role === 'user' ? 'You' : 'Lorekeeper';

  const time = document.createElement('span');
  time.className = 'chat-time';
  time.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  meta.appendChild(name);
  meta.appendChild(time);

  const bubble = document.createElement('div');
  bubble.className = 'chat-bubble';
  bubble.textContent = text;

  content.appendChild(meta);
  content.appendChild(bubble);

  if (role === 'user') {
    row.appendChild(content);
    row.appendChild(avatar);
  } else {
    row.appendChild(avatar);
    row.appendChild(content);
  }

  item.appendChild(row);
  chatLog.appendChild(item);
  chatLog.scrollTop = chatLog.scrollHeight;
  if (role === 'user' || role === 'ai') {
    state.chatHistory.push({ role, text });
    if (state.chatHistory.length > 12) {
      state.chatHistory.shift();
    }
  }
}

function isTimeoutError(err) {
  if (!err) return false;
  const message = err.message || String(err);
  return /timed out|timeout/i.test(message);
}

async function attemptOllamaFallback(reason) {
  try {
    const settings = await window.lorekeeper.getSettings();
    if (!settings || settings.aiProvider !== 'ollama') return null;
    const current = settings.ollamaModel || '';
    setStatus(chatStatus, 'Ollama timed out. Trying a lighter model...');
    const models = await window.lorekeeper.listOllamaModels();
    const nextModel = pickFastModel(models, current);
    if (!nextModel || nextModel === current) {
      setStatus(chatStatus, 'Ollama timed out. Try a smaller model in Settings.', true);
      return null;
    }
    await window.lorekeeper.saveSettings({ aiProvider: 'ollama', ollamaModel: nextModel });
    settingsSnapshot.ollamaModel = nextModel;
    ollamaModelInput.value = nextModel;
    logEvent('warn', 'ollama_model_fallback', { from: current, to: nextModel, reason });
    return nextModel;
  } catch (err) {
    logEvent('error', 'ollama_model_fallback_failed', { message: err.message || String(err) });
    setStatus(chatStatus, err.message || 'Ollama fallback failed.', true);
    return null;
  }
}

function renderPages(pages) {
  pageList.innerHTML = '';
  pages.forEach((title) => {
    const btn = document.createElement('button');
    btn.className = 'page-item';
    btn.textContent = title;
    if (state.selectedPage === title) {
      btn.classList.add('active');
    }
    btn.addEventListener('click', () => selectPage(title));
    pageList.appendChild(btn);
  });
}

async function loadPages() {
  const pages = await window.lorekeeper.listPages();
  renderPages(pages);
}

async function selectPage(title) {
  state.selectedPage = title;
  await loadPages();
  pageTitle.textContent = title;
  const markdown = await window.lorekeeper.readPage(title);
  pagePreview.innerHTML = window.lorekeeper.renderMarkdown(markdown);
}

function shouldStartEdits(message) {
  const text = message.toLowerCase();
  return (
    text.includes('start working on the edits') ||
    text.includes('start edits') ||
    text.includes('start edit') ||
    text.includes('begin edits') ||
    text.includes('work on the edits') ||
    text.includes('make the edits') ||
    text.includes('generate a plan') ||
    text.includes('draft the plan')
  );
}

async function generatePlan() {
  const rawMessage = userInput.value.trim();
  if (!rawMessage) {
    setStatus(chatStatus, 'Enter a request first.', true);
    return;
  }
  const message = shouldStartEdits(rawMessage)
    ? 'Create the edit plan based on the full conversation history above. Use all relevant lore facts already shared. Infer target pages from the available pages list and wiki structure guidance. Keep diffs minimal.'
    : rawMessage;

  addChatMessage('user', rawMessage);
  userInput.value = '';
  state.plan = null;
  state.planText = '';
  planOutput.textContent = 'Generating plan...';
  diffOutput.textContent = 'No changes yet.';
  draftApplied = false;
  if (waxSeal) waxSeal.classList.add('hidden');
  applyBtn.disabled = true;
  checkBtn.disabled = true;
  pushBtn.disabled = true;
  if (planDeltaCleanup) {
    planDeltaCleanup();
    planDeltaCleanup = null;
  }

  try {
    logEvent('info', 'plan_request', { message });
    planDeltaCleanup = window.lorekeeper.onPlanDelta((delta) => {
      state.planText += delta;
      planOutput.textContent = state.planText;
    });
    const plan = await window.lorekeeper.generatePlan(message, state.selectedPage, {
      stream: true,
      history: state.chatHistory
    });
    state.plan = plan;
    planOutput.textContent = JSON.stringify(plan, null, 2);
    if (plan.assistant_message) {
      addChatMessage('ai', plan.assistant_message);
    } else {
      addChatMessage('ai', 'Plan generated. Review the JSON then apply the draft.');
    }
    setStatus(chatStatus, 'Plan ready.');
    applyBtn.disabled = false;
    logEvent('info', 'plan_ready');
  } catch (err) {
    setStatus(chatStatus, err.message || 'Failed to generate plan.', true);
    logEvent('error', 'plan_failed', { message: err.message || String(err) });
  } finally {
    if (planDeltaCleanup) {
      planDeltaCleanup();
      planDeltaCleanup = null;
    }
  }
}

async function chatMessage() {
  const message = userInput.value.trim();
  if (!message) {
    setStatus(chatStatus, 'Enter a message first.', true);
    return;
  }

  if (shouldStartEdits(message)) {
    await generatePlan();
    return;
  }

  addChatMessage('user', message);
  userInput.value = '';

  try {
    setStatus(chatStatus, 'Thinking...');
    logEvent('info', 'chat_request', { message });
    let reply = await window.lorekeeper.chat(message, { history: state.chatHistory });
    addChatMessage('ai', reply);
    setStatus(chatStatus, 'Reply ready.');
    logEvent('info', 'chat_ready');
  } catch (err) {
    if (settingsSnapshot && settingsSnapshot.aiProvider === 'ollama' && isTimeoutError(err)) {
      const fallback = await attemptOllamaFallback('chat_timeout');
      if (fallback) {
        try {
          const reply = await window.lorekeeper.chat(message, { history: state.chatHistory });
          addChatMessage('ai', reply);
          setStatus(chatStatus, 'Reply ready.');
          logEvent('info', 'chat_ready_after_fallback');
          return;
        } catch (retryErr) {
          setStatus(chatStatus, retryErr.message || 'Failed to chat.', true);
          logEvent('error', 'chat_failed_after_fallback', { message: retryErr.message || String(retryErr) });
          return;
        }
      }
    }
    setStatus(chatStatus, err.message || 'Failed to chat.', true);
    logEvent('error', 'chat_failed', { message: err.message || String(err) });
  }
}

async function applyDraft() {
  if (!state.plan) {
    setStatus(chatStatus, 'Generate a plan first.', true);
    return;
  }

  try {
    applyBtn.disabled = true;
    setStatus(chatStatus, 'Applying draft...');
    logEvent('info', 'draft_apply_start');
    await window.lorekeeper.applyDraft(state.plan);
    draftApplied = true;
    if (waxSeal) waxSeal.classList.remove('hidden');
    setStatus(chatStatus, 'Draft applied locally. Check modifications before pushing.');
    addChatMessage('ai', 'Draft applied locally. Use Check Mods then Commit & Push if approved.');
    await loadPages();
    checkBtn.disabled = false;
    pushBtn.disabled = false;
    await checkMods();
    logEvent('info', 'draft_apply_complete');
  } catch (err) {
    setStatus(chatStatus, err.message || 'Failed to apply update.', true);
    logEvent('error', 'draft_apply_failed', { message: err.message || String(err) });
  } finally {
    applyBtn.disabled = false;
  }
}

async function checkMods() {
  try {
    setStatus(chatStatus, 'Collecting git diff...');
    logEvent('info', 'diff_request');
    const diff = await window.lorekeeper.getDiff();
    diffOutput.textContent = diff.trim() || 'No changes yet.';
    setStatus(chatStatus, 'Diff ready.');
    logEvent('info', 'diff_ready');
  } catch (err) {
    setStatus(chatStatus, err.message || 'Failed to get diff.', true);
    logEvent('error', 'diff_failed', { message: err.message || String(err) });
  }
}

async function commitAndPush() {
  if (!state.plan) {
    setStatus(chatStatus, 'Generate a plan first.', true);
    return;
  }
  if (!draftApplied) {
    setStatus(chatStatus, 'Apply the draft before pushing.', true);
    return;
  }
  try {
    pushBtn.disabled = true;
    setStatus(chatStatus, 'Committing and pushing...');
    logEvent('info', 'push_start');
    await window.lorekeeper.commitAndPush(state.plan);
    setStatus(chatStatus, 'Pushed to repo.');
    addChatMessage('ai', 'Changes committed and pushed to the wiki repo.');
    if (waxSeal) waxSeal.classList.add('hidden');
    logEvent('info', 'push_complete');
  } catch (err) {
    setStatus(chatStatus, err.message || 'Failed to push.', true);
    logEvent('error', 'push_failed', { message: err.message || String(err) });
  } finally {
    pushBtn.disabled = false;
  }
}

async function syncRepo() {
  try {
    setStatus(chatStatus, 'Syncing repo...');
    logEvent('info', 'repo_sync_start');
    await window.lorekeeper.syncRepo();
    await loadPages();
    setStatus(chatStatus, 'Repo synced.');
    logEvent('info', 'repo_sync_complete');
  } catch (err) {
    setStatus(chatStatus, err.message || 'Sync failed.', true);
    logEvent('error', 'repo_sync_error', { message: err.message || String(err) });
  }
}

async function init() {
  try {
    if (!window.lorekeeper) {
      setStatus(setupStatus, 'Preload failed. Run npm install and restart.', true);
      return;
    }
    logEvent('info', 'renderer_init');
    const status = await window.lorekeeper.getRepoStatus();
    canonRules.textContent = `Canon rules: ${status.canonRules.join(' | ')}`;
    const settings = await window.lorekeeper.getSettings();
    settingsSnapshot = await ensureOllamaModel(settings);
    modelInput.value = settings.openaiModel || 'gpt-4o';
    streamToggle.checked = settings.openaiStream !== false;
    fallbackToggle.checked = settings.openaiFallback !== false;
    fallbackModelInput.value = settings.openaiFallbackModel || 'gpt-4o-mini';
    apiKeyInput.value = settings.hasOpenAIKey ? '********' : '';
    providerSelect.value = settings.aiProvider || 'ollama';
    ollamaHostInput.value = settings.ollamaHost || 'http://localhost:11434';
    ollamaModelInput.value = settingsSnapshot.ollamaModel || settings.ollamaModel || '';
    updateProviderUI();
    const logInfo = await window.lorekeeper.getLogPath();
    if (logPath && logInfo && logInfo.path) {
      logPath.textContent = logInfo.path;
    }
    if (!status.exists) {
      try {
        setStatus(setupStatus, 'Auto-cloning wiki...');
        await window.lorekeeper.setupRepo(status.repoUrl);
        setStatus(setupStatus, 'Clone complete.');
        showMain();
        toggleIndex(false);
        await loadPages();
        await syncRepo();
        await greetOnLaunch();
        return;
      } catch (err) {
        setStatus(setupStatus, err.message || 'Auto-clone failed.', true);
        showSetup(status.repoUrl);
        return;
      }
    }
    showMain();
    toggleIndex(false);
    await loadPages();
    try {
      await syncRepo();
    } catch (err) {
      logEvent('warn', 'repo_sync_startup_failed', { message: err.message || String(err) });
    }
    await greetOnLaunch();
  } catch (err) {
    setStatus(setupStatus, err.message || 'Initialization failed.', true);
  }
}

cloneBtn.addEventListener('click', async () => {
  const repoUrl = repoInput.value.trim();
  if (!repoUrl) {
    setStatus(setupStatus, 'Provide a repo URL.', true);
    return;
  }

  try {
    setStatus(setupStatus, 'Cloning...');
    await window.lorekeeper.setupRepo(repoUrl);
    setStatus(setupStatus, 'Clone complete.');
    showMain();
    await loadPages();
  } catch (err) {
    setStatus(setupStatus, err.message || 'Clone failed.', true);
  }
});

settingsBtn.addEventListener('click', () => toggleSettings(true));
settingsClose.addEventListener('click', () => toggleSettings(false));
indexToggle.addEventListener('click', () => {
  const showingIndex = !indexPanel.classList.contains('hidden');
  toggleIndex(!showingIndex);
});
saveSettingsBtn.addEventListener('click', async () => {
  const payload = {
    aiProvider: providerSelect.value,
    openaiModel: modelInput.value.trim(),
    openaiStream: streamToggle.checked,
    openaiFallback: fallbackToggle.checked,
    openaiFallbackModel: fallbackModelInput.value.trim(),
    ollamaHost: ollamaHostInput.value.trim(),
    ollamaModel: ollamaModelInput.value.trim()
  };
  const rawKey = apiKeyInput.value.trim();
  if (!rawKey && settingsSnapshot.hasOpenAIKey) {
    payload.openaiApiKey = '';
  } else if (rawKey && rawKey !== '********') {
    payload.openaiApiKey = rawKey;
  }

  try {
    setStatus(settingsStatus, 'Saving...');
    await window.lorekeeper.saveSettings(payload);
    const settings = await window.lorekeeper.getSettings();
    settingsSnapshot = settings;
    apiKeyInput.value = settings.hasOpenAIKey ? '********' : '';
    setStatus(settingsStatus, 'Saved.');
  } catch (err) {
    setStatus(settingsStatus, err.message || 'Failed to save.', true);
  }
});

fetchModelsBtn.addEventListener('click', async () => {
  try {
    setStatus(settingsStatus, 'Fetching models...');
    const models = await window.lorekeeper.listModels();
    modelsList.innerHTML = '';
    models.forEach((id) => {
      const option = document.createElement('option');
      option.value = id;
      modelsList.appendChild(option);
    });
    setStatus(settingsStatus, `Loaded ${models.length} models.`);
  } catch (err) {
    setStatus(settingsStatus, err.message || 'Failed to fetch models.', true);
  }
});

fetchOllamaModelsBtn.addEventListener('click', async () => {
  try {
    setStatus(settingsStatus, 'Fetching Ollama models...');
    const models = await window.lorekeeper.listOllamaModels();
    ollamaModelsList.innerHTML = '';
    models.forEach((id) => {
      const option = document.createElement('option');
      option.value = id;
      ollamaModelsList.appendChild(option);
    });
    if (models.length > 0) {
      ollamaModelInput.value = pickBestModel(models);
    }
    setStatus(settingsStatus, `Loaded ${models.length} models.`);
  } catch (err) {
    setStatus(settingsStatus, err.message || 'Failed to fetch models.', true);
  }
});

providerSelect.addEventListener('change', updateProviderUI);

copyLogBtn.addEventListener('click', async () => {
  if (!logPath || !logPath.textContent) return;
  try {
    await navigator.clipboard.writeText(logPath.textContent);
    setStatus(settingsStatus, 'Log path copied.');
  } catch {
    setStatus(settingsStatus, 'Copy failed.', true);
  }
});

sendBtn.addEventListener('click', chatMessage);
applyBtn.addEventListener('click', applyDraft);
syncBtn.addEventListener('click', syncRepo);
checkBtn.addEventListener('click', checkMods);
pushBtn.addEventListener('click', commitAndPush);

userInput.addEventListener('keydown', (event) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    chatMessage();
  }
});

async function greetOnLaunch() {
  const prompt =
    'Introduce yourself briefly as Lorekeeper, greet the user, and ask what lore they want to discuss.';
  let fallbackShown = false;
  let resolved = false;
  const fallbackTimer = setTimeout(() => {
    if (resolved) return;
    fallbackShown = true;
    addChatMessage(
      'ai',
      "Greetings. I'm warming up now — you can start chatting, and I'll answer as soon as I'm ready."
    );
    setStatus(chatStatus, '');
    logEvent('warn', 'ai_greeting_timeout');
  }, 15000);

  try {
    setStatus(chatStatus, 'Lorekeeper is waking...');
    logEvent('info', 'ai_greeting_start');
    const greeting = await window.lorekeeper.chat(prompt);
    resolved = true;
    clearTimeout(fallbackTimer);
    if (!fallbackShown) {
      addChatMessage('ai', greeting);
    } else {
      logEvent('info', 'ai_greeting_late');
    }
    setStatus(chatStatus, '');
    logEvent('info', 'ai_greeting_complete');
  } catch (err) {
    resolved = true;
    clearTimeout(fallbackTimer);
    logEvent('error', 'ai_greeting_failed', { message: err.message || String(err) });
    if (settingsSnapshot && settingsSnapshot.aiProvider === 'ollama') {
      if (isTimeoutError(err)) {
        const fallback = await attemptOllamaFallback('greeting_timeout');
        if (fallback) {
          try {
            const retry = await window.lorekeeper.chat(prompt);
            if (!fallbackShown) {
              addChatMessage('ai', retry);
            } else {
              logEvent('info', 'ai_greeting_retry_late');
            }
            setStatus(chatStatus, '');
            logEvent('info', 'ai_greeting_retry_success');
            return;
          } catch (retryErr) {
            logEvent('error', 'ai_greeting_retry_failed', { message: retryErr.message || String(retryErr) });
          }
        }
      }
      try {
        await new Promise((resolve) => setTimeout(resolve, 1500));
        const retry = await window.lorekeeper.chat(prompt);
        if (!fallbackShown) {
          addChatMessage('ai', retry);
        } else {
          logEvent('info', 'ai_greeting_retry_late');
        }
        setStatus(chatStatus, '');
        logEvent('info', 'ai_greeting_retry_success');
        return;
      } catch (retryErr) {
        logEvent('error', 'ai_greeting_retry_failed', { message: retryErr.message || String(retryErr) });
      }
    }
    addChatMessage('ai', "Lorekeeper is ready. Tell me what you'd like to record in the lore.");
    setStatus(chatStatus, err.message || 'Greeting failed.', true);
  }
}

init();

