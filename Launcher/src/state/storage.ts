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
  launchArgs: '',
  safeMode: false,
  gameExeRelative: 'ProjectP1L0T.exe',
  localBuildRelative: 'Builds/Godot/ProjectP1L0T.exe'
};

const normalizeGameExe = (value?: string): string => {
  if (!value) return defaultSettings.gameExeRelative;
  const normalized = value.replace(/\\/g, '/').toLowerCase();
  if (normalized === 'projectp1l0t/binaries/win64/projectp1l0t.exe') {
    return defaultSettings.gameExeRelative;
  }
  return value;
};

const normalizeLocalBuild = (value?: string): string => {
  if (!value) return defaultSettings.localBuildRelative;
  return value;
};

export const readSettings = (): LauncherSettings => {
  if (typeof window === 'undefined') return defaultSettings;
  try {
    const raw = window.localStorage.getItem(SETTINGS_KEY);
    const merged = raw ? { ...defaultSettings, ...(JSON.parse(raw) as LauncherSettings) } : defaultSettings;
    return {
      ...merged,
      gameExeRelative: normalizeGameExe(merged.gameExeRelative),
      localBuildRelative: normalizeLocalBuild(merged.localBuildRelative)
    };
  } catch {
    return defaultSettings;
  }
};

export const writeSettings = (settings: LauncherSettings): void => {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
};
