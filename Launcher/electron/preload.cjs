const { contextBridge, ipcRenderer } = require('electron');

const onUpdateProgress = (callback) => {
  const handler = (_event, payload) => callback(payload);
  ipcRenderer.on('launcher:updateProgress', handler);
  return () => ipcRenderer.removeListener('launcher:updateProgress', handler);
};

contextBridge.exposeInMainWorld('launcher', {
  isDev: process.env.NODE_ENV === 'development',
  platform: process.platform,
  version: process.versions.electron,
  checkForUpdate: (payload) => ipcRenderer.invoke('launcher:checkUpdate', payload),
  performUpdate: (payload) => ipcRenderer.invoke('launcher:performUpdate', payload),
  launchGame: (payload) => ipcRenderer.invoke('launcher:launchGame', payload),
  packageBuild: (payload) => ipcRenderer.invoke('launcher:packageBuild', payload),
  openPath: (targetPath) => ipcRenderer.invoke('launcher:openPath', targetPath),
  openLogs: () => ipcRenderer.invoke('launcher:openLogs'),
  onUpdateProgress
});
