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
  installDir: 'C:/ProjectP1L0T',
  bandwidthLimitMbps: 0,
  autoUpdate: true,
  runOnStartup: false,
  launchArgs: '',
  safeMode: false,
  gameExeRelative: 'ProjectP1L0T.exe',
  useLocalBuild: false,
  localBuildRelative: 'Builds/Godot/ProjectP1L0T.exe',
  serverAddress: '127.0.0.1',
  serverPort: 7777,
  serverArgs: ''
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
    return Array.isArray(parsed) ? (parsed as AuthUserRecord[]) : [];
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
