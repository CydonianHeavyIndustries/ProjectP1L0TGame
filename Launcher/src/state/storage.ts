import type { InstalledRecord } from '../types/install';
import type { LauncherSettings } from '../types/settings';

const INSTALLED_KEY = 'p1lot_installed';
const SETTINGS_KEY = 'p1lot_settings';

export const readInstalled = (): InstalledRecord | null => {
  if (typeof window === 'undefined') return null;
  try {
    const raw = window.localStorage.getItem(INSTALLED_KEY);
    return raw ? (JSON.parse(raw) as InstalledRecord) : null;
  } catch {
    return null;
  }
};

export const writeInstalled = (record: InstalledRecord | null): void => {
  if (typeof window === 'undefined') return;
  if (!record) {
    window.localStorage.removeItem(INSTALLED_KEY);
    return;
  }
  window.localStorage.setItem(INSTALLED_KEY, JSON.stringify(record));
};

export const defaultSettings: LauncherSettings = {
  installDir: 'C:/ProjectP1L0T',
  bandwidthLimitMbps: 0,
  autoUpdate: true,
  runOnStartup: false,
  launchArgs: '-log -nosplash',
  safeMode: false,
  gameExeRelative: 'ProjectP1L0T/Binaries/Win64/ProjectP1L0T.exe'
};

export const readSettings = (): LauncherSettings => {
  if (typeof window === 'undefined') return defaultSettings;
  try {
    const raw = window.localStorage.getItem(SETTINGS_KEY);
    return raw ? { ...defaultSettings, ...(JSON.parse(raw) as LauncherSettings) } : defaultSettings;
  } catch {
    return defaultSettings;
  }
};

export const writeSettings = (settings: LauncherSettings): void => {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
};
