const { contextBridge, ipcRenderer } = require('electron');

const onUpdateProgress = (callback) => {
  const handler = (_event, payload) => callback(payload);
  ipcRenderer.on('launcher:updateProgress', handler);
  return () => ipcRenderer.removeListener('launcher:updateProgress', handler);
};

const onServerStatus = (callback) => {
  const handler = (_event, payload) => callback(payload);
  ipcRenderer.on('launcher:serverStatus', handler);
  return () => ipcRenderer.removeListener('launcher:serverStatus', handler);
};

contextBridge.exposeInMainWorld('launcher', {
  isDev: process.env.NODE_ENV === 'development',
  platform: process.platform,
  version: process.versions.electron,
  getBuildInfo: () => ipcRenderer.invoke('launcher:getBuildInfo'),
  checkForUpdate: (payload) => ipcRenderer.invoke('launcher:checkUpdate', payload),
  performUpdate: (payload) => ipcRenderer.invoke('launcher:performUpdate', payload),
  launchGame: (payload) => ipcRenderer.invoke('launcher:launchGame', payload),
  packageBuild: (payload) => ipcRenderer.invoke('launcher:packageBuild', payload),
  sendVerificationEmail: (payload) => ipcRenderer.invoke('launcher:sendVerificationEmail', payload),
  getServerStatus: () => ipcRenderer.invoke('launcher:getServerStatus'),
  startServer: (payload) => ipcRenderer.invoke('launcher:startServer', payload),
  stopServer: () => ipcRenderer.invoke('launcher:stopServer'),
  openPath: (targetPath) => ipcRenderer.invoke('launcher:openPath', targetPath),
  openLogs: () => ipcRenderer.invoke('launcher:openLogs'),
  pickDirectory: (payload) => ipcRenderer.invoke('launcher:pickDirectory', payload),
  socialCreateProfile: (payload) => ipcRenderer.invoke('launcher:socialCreateProfile', payload),
  socialUpdateProfile: (payload) => ipcRenderer.invoke('launcher:socialUpdateProfile', payload),
  socialSetPresence: (payload) => ipcRenderer.invoke('launcher:socialSetPresence', payload),
  socialSearchPlayers: (payload) => ipcRenderer.invoke('launcher:socialSearchPlayers', payload),
  socialSendFriendRequest: (payload) => ipcRenderer.invoke('launcher:socialSendFriendRequest', payload),
  socialRespondFriendRequest: (payload) => ipcRenderer.invoke('launcher:socialRespondFriendRequest', payload),
  socialListFriendRequests: (payload) => ipcRenderer.invoke('launcher:socialListFriendRequests', payload),
  socialListFriends: (payload) => ipcRenderer.invoke('launcher:socialListFriends', payload),
  onUpdateProgress,
  onServerStatus
});
