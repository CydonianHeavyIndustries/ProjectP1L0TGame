import type { Channel } from './channel';
import type { GitHubRelease } from './github';
import type { InstallStatus } from './install';
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
  launchLocalBuild: () => void;
  openInstallDir: () => void;
  openLogs: () => void;
}

export interface LauncherState {
  channel: Channel;
  setChannel: (channel: Channel) => void;
  release: GitHubRelease | null;
  install: InstallStatus;
  installedVersion: string;
  settings: LauncherSettings;
  logs: string[];
  actions: LauncherActions;
}
