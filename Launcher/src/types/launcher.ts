import type { Channel } from './channel';
import type { GitHubRelease } from './github';
import type { InstallStatus } from './install';
import type { ServerState } from './server';
import type { LauncherSettings } from './settings';

export interface LauncherActions {
  startInstall: () => void;
  startUpdate: () => void;
  startRepair: () => void;
  packageBuild: () => void;
  markCorrupt: () => void;
  triggerError: (message: string) => void;
  clearLogs: () => void;
  updateSettings: (next: Partial<LauncherSettings>) => void;
  resetSettings: () => void;
  requestLaunch: () => void;
  requestLocalLaunch: () => void;
  requestJoinServer: () => void;
  startServer: () => void;
  stopServer: () => void;
  openInstallDir: () => void;
  chooseInstallDir: () => Promise<boolean>;
  openLogs: () => void;
}

export interface LauncherState {
  channel: Channel;
  setChannel: (channel: Channel) => void;
  release: GitHubRelease | null;
  install: InstallStatus;
  server: ServerState;
  installedVersion: string;
  settings: LauncherSettings;
  logs: string[];
  actions: LauncherActions;
}
