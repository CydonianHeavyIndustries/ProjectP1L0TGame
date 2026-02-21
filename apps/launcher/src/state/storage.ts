import type { InstalledRecord } from '../types/install';
import type { LauncherSettings } from '../types/settings';
import type { AuthSession, AuthUserRecord } from '../types/auth';

const INSTALLED_KEY = 'p1lot_installed';
const SETTINGS_KEY = 'p1lot_settings';
const AUTH_USERS_KEY = 'p1lot_auth_users_v1';
const AUTH_SESSION_KEY = 'p1lot_auth_session_v1';

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
  installDir: 'C:/dev/ProjectP1L0T_godot',
  bandwidthLimitMbps: 0,
  autoUpdate: true,
  runOnStartup: false,
  launchArgs: '',
  safeMode: false,
  gameExeRelative: 'ProjectP1L0T.exe',
  useLocalBuild: true,
  localBuildRelative: 'Builds/Godot/ProjectP1L0T.exe',
  serverAddress: '127.0.0.1',
  serverPort: 7777,
  serverArgs: ''
};

const normalizeSettings = (settings: LauncherSettings): LauncherSettings => {
  const normalized = { ...settings };
  const normalizedLocalPath = (normalized.localBuildRelative || '').replace(/\\/g, '/');
  const normalizedLocalPathLower = normalizedLocalPath.toLowerCase();

  const isLegacyAbsolutePath =
    normalizedLocalPathLower.includes('/builds/godot/projectp1l0t.exe') ||
    normalizedLocalPathLower.includes('/projectp1l0t_godot/projectp1l0t.exe') ||
    normalizedLocalPathLower.includes('/onedrive/');

  const isLegacyRelativePath = normalizedLocalPath === 'ProjectP1L0T.exe';

  const isEmbeddedPath =
    normalizedLocalPathLower === 'game/projectp1l0t.exe' ||
    normalizedLocalPathLower.includes('node_modules/electron/dist/resources') ||
    normalizedLocalPathLower.includes('/resources/game/projectp1l0t.exe');

  const usingLegacyDefaults =
    normalized.installDir === 'C:/ProjectP1L0T' &&
    normalized.localBuildRelative === 'Builds/Godot/ProjectP1L0T.exe';

  if (usingLegacyDefaults) {
    normalized.installDir = defaultSettings.installDir;
    normalized.useLocalBuild = defaultSettings.useLocalBuild;
    normalized.localBuildRelative = defaultSettings.localBuildRelative;
  } else if (!normalizedLocalPath || isLegacyRelativePath || isLegacyAbsolutePath || isEmbeddedPath) {
    normalized.useLocalBuild = true;
    normalized.localBuildRelative = defaultSettings.localBuildRelative;
  }

  return normalized;
};

export const readSettings = (): LauncherSettings => {
  if (typeof window === 'undefined') return defaultSettings;
  try {
    const raw = window.localStorage.getItem(SETTINGS_KEY);
    const merged = raw ? { ...defaultSettings, ...(JSON.parse(raw) as LauncherSettings) } : defaultSettings;
    return normalizeSettings(merged);
  } catch {
    return defaultSettings;
  }
};

export const resetSettings = (): LauncherSettings => {
  if (typeof window === 'undefined') return { ...defaultSettings };
  window.localStorage.removeItem(SETTINGS_KEY);
  return { ...defaultSettings };
};

export const writeSettings = (settings: LauncherSettings): void => {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
};

export const readAuthUsers = (): AuthUserRecord[] => {
  if (typeof window === 'undefined') return [];
  try {
    const raw = window.localStorage.getItem(AUTH_USERS_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed as AuthUserRecord[];
  } catch {
    return [];
  }
};

export const writeAuthUsers = (users: AuthUserRecord[]): void => {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(AUTH_USERS_KEY, JSON.stringify(users));
};

export const readAuthSession = (): AuthSession | null => {
  if (typeof window === 'undefined') return null;
  try {
    const raw = window.localStorage.getItem(AUTH_SESSION_KEY);
    return raw ? (JSON.parse(raw) as AuthSession) : null;
  } catch {
    return null;
  }
};

export const writeAuthSession = (session: AuthSession | null): void => {
  if (typeof window === 'undefined') return;
  if (!session) {
    window.localStorage.removeItem(AUTH_SESSION_KEY);
    return;
  }
  window.localStorage.setItem(AUTH_SESSION_KEY, JSON.stringify(session));
};
