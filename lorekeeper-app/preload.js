const { contextBridge, ipcRenderer } = require('electron');
let markedParser = null;
try {
  ({ marked: markedParser } = require('marked'));
} catch (err) {
  markedParser = null;
}

contextBridge.exposeInMainWorld('lorekeeper', {
  getRepoStatus: () => ipcRenderer.invoke('repo:get-status'),
  setupRepo: (repoUrl) => ipcRenderer.invoke('repo:setup', repoUrl),
  syncRepo: () => ipcRenderer.invoke('repo:sync'),
  listPages: () => ipcRenderer.invoke('pages:list'),
  readPage: (title) => ipcRenderer.invoke('pages:read', title),
  generatePlan: (message, page, options) => ipcRenderer.invoke('ai:generate-plan', message, page, options),
  chat: (message, options) => ipcRenderer.invoke('ai:chat', message, options),
  applyDraft: (plan) => ipcRenderer.invoke('wiki:apply-draft', plan),
  getDiff: () => ipcRenderer.invoke('wiki:diff'),
  commitAndPush: (plan) => ipcRenderer.invoke('wiki:commit-push', plan),
  getSettings: () => ipcRenderer.invoke('settings:get'),
  saveSettings: (settings) => ipcRenderer.invoke('settings:save', settings),
  listModels: () => ipcRenderer.invoke('openai:list-models'),
  listOllamaModels: () => ipcRenderer.invoke('ollama:list-models'),
  log: (level, message, meta) => ipcRenderer.invoke('log:write', level, message, meta),
  getLogPath: () => ipcRenderer.invoke('log:path'),
  onPlanDelta: (handler) => {
    const listener = (_event, delta) => handler(delta);
    ipcRenderer.on('ai:plan-delta', listener);
    return () => ipcRenderer.removeListener('ai:plan-delta', listener);
  },
  renderMarkdown: (markdown) => (markedParser ? markedParser.parse(markdown || '') : `<pre>${markdown || ''}</pre>`)
});
