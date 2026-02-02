export type InstallState =
  | 'NotInstalled'
  | 'Installed'
  | 'UpdateAvailable'
  | 'RepairRecommended'
  | 'Updating'
  | 'Repairing'
  | 'Error';

export type InstallStep =
  | 'Idle'
  | 'Downloading'
  | 'Verifying'
  | 'Installing'
  | 'Cleaning';

export interface InstallStatus {
  state: InstallState;
  step: InstallStep;
  progress: number;
  message?: string;
  error?: string;
}

export interface InstalledRecord {
  version: string;
  channel: string;
  installedAt: string;
  path: string;
}
