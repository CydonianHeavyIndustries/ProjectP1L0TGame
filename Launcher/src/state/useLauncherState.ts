import { useEffect, useMemo, useRef, useState } from 'react';
import type { Channel } from '../types/channel';
import type { InstallStatus, InstallState, InstallStep } from '../types/install';
import type { LauncherSettings } from '../types/settings';
import type { AuthActionResult, LauncherState } from '../types/launcher';
import type { GitHubRelease } from '../types/github';
import type { ServerState } from '../types/server';
import type { AuthSession, AuthUser, AuthUserRecord } from '../types/auth';
import type { SocialFriend, SocialFriendRequest, SocialProfile } from '../types/social';
import type { UpdateCheckResult, UpdateResult } from '../types/update';
import { formatDate } from '../utils/format';
import { checkGitHubUpdate } from './github';
import {
  defaultSettings,
  readAuthSession,
  readAuthUsers,
  readInstalled,
  readSettings,
  resetSettings,
  writeAuthSession,
  writeAuthUsers,
  writeInstalled,
  writeSettings
} from './storage';

const initialInstallStatus = (installedVersion: string | null): InstallStatus => ({
  state: installedVersion && installedVersion !== '0.0.0' ? 'Installed' : 'NotInstalled',
  step: 'Idle',
  progress: 0
});

const initialServerState: ServerState = {
  status: 'Stopped'
};

const coerceStep = (value?: string): InstallStep => {
  if (value === 'Downloading') return 'Downloading';
  if (value === 'Verifying') return 'Verifying';
  if (value === 'Installing') return 'Installing';
  if (value === 'Cleaning') return 'Cleaning';
  return 'Idle';
};

const coerceState = (value?: string): InstallState | undefined => {
  if (!value) return undefined;
  if (
    value === 'NotInstalled' ||
    value === 'Installed' ||
    value === 'UpdateAvailable' ||
    value === 'RepairRecommended' ||
    value === 'Updating' ||
    value === 'Repairing' ||
    value === 'Error'
  ) {
    return value;
  }
  return undefined;
};

const VERIFICATION_TTL_MS = 15 * 60 * 1000;
const VERIFICATION_RESEND_COOLDOWN_MS = 30 * 1000;
const PRESENCE_HEARTBEAT_MS = 20 * 1000;

const normalizeIdentity = (value: string): string => value.trim().toLowerCase();
const isLikelyEmailAddress = (value: string): boolean => value.includes('@') && value.includes('.');

const hashPassword = (password: string): string => {
  let hash = 5381;
  for (let i = 0; i < password.length; i += 1) {
    hash = (hash * 33) ^ password.charCodeAt(i);
  }
  return `h${(hash >>> 0).toString(16)}`;
};

const toPublicUser = (user: AuthUserRecord): AuthUser => ({
  id: user.id,
  username: user.username,
  email: user.email,
  emailVerified: user.emailVerified,
  bio: user.bio,
  statusMessage: user.statusMessage,
  discordUsername: user.discordUsername,
  avatarDataUrl: user.avatarDataUrl,
  createdAt: user.createdAt,
  lastLoginAt: user.lastLoginAt
});

const buildSession = (userId: string): AuthSession => ({
  userId,
  signedInAt: new Date().toISOString()
});

const generateVerificationCode = (): string => `${Math.floor(100000 + Math.random() * 900000)}`;

const maskEmail = (email: string): string => {
  const [name, domain] = email.split('@');
  if (!name || !domain) return email;
  const visible = name.length <= 2 ? name : `${name.slice(0, 2)}***`;
  return `${visible}@${domain}`;
};

const isoTimeToMs = (value?: string): number => {
  if (!value) return 0;
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? 0 : parsed;
};

const getResendCooldownSeconds = (sentAt?: string): number => {
  const sentMs = isoTimeToMs(sentAt);
  if (!sentMs) return 0;
  const elapsed = Date.now() - sentMs;
  if (elapsed >= VERIFICATION_RESEND_COOLDOWN_MS) return 0;
  return Math.ceil((VERIFICATION_RESEND_COOLDOWN_MS - elapsed) / 1000);
};

const isVerificationExpired = (sentAt?: string): boolean => {
  const sentMs = isoTimeToMs(sentAt);
  if (!sentMs) return true;
  return Date.now() - sentMs > VERIFICATION_TTL_MS;
};

export const useLauncherState = (): LauncherState => {
  const installedRecord = useMemo(() => readInstalled(), []);
  const installedAt = installedRecord?.installedAt;
  const autoUpdateTriggeredRef = useRef(false);
  const socialRefreshRef = useRef<number | null>(null);
  const [channel, setChannel] = useState<Channel>('dev');
  const [release, setRelease] = useState<GitHubRelease | null>(null);
  const [install, setInstall] = useState<InstallStatus>(() => initialInstallStatus(installedRecord?.version ?? null));
  const [server, setServer] = useState<ServerState>(initialServerState);
  const [installedVersion, setInstalledVersion] = useState(installedRecord?.version ?? '0.0.0');
  const [settings, setSettings] = useState<LauncherSettings>(() => readSettings());
  const [authUsers, setAuthUsers] = useState<AuthUserRecord[]>(() => readAuthUsers());
  const [authSession, setAuthSession] = useState<AuthSession | null>(() => readAuthSession());
  const [pendingVerificationIdentity, setPendingVerificationIdentity] = useState('');
  const [friends, setFriends] = useState<SocialFriend[]>([]);
  const [friendRequests, setFriendRequests] = useState<SocialFriendRequest[]>([]);
  const [logs, setLogs] = useState<string[]>([`[${formatDate(new Date().toISOString())}] Launcher booted`]);

  const pushLog = (message: string) => {
    setLogs((prev) => [`[${formatDate(new Date().toISOString())}] ${message}`, ...prev]);
  };

  const authUser = useMemo<AuthUser | null>(() => {
    if (!authSession) return null;
    const user = authUsers.find((entry) => entry.id === authSession.userId);
    return user ? toPublicUser(user) : null;
  }, [authSession, authUsers]);

  const queueVerificationEmail = (payload: { username: string; email: string; code: string }) => {
    if (!window.launcher?.sendVerificationEmail) {
      pushLog(`Validation email skipped: mail bridge unavailable (DEV CODE ${payload.code})`);
      return;
    }

    window.launcher
      .sendVerificationEmail(payload)
      .then((result) => {
        if (result.status === 'ok') {
          pushLog(`Validation email sent to ${maskEmail(payload.email)} from noreply.`);
          return;
        }
        pushLog(`Validation email failed (${result.reason}) (DEV CODE ${payload.code})`);
      })
      .catch((error) => {
        pushLog(`Validation email failed (${error instanceof Error ? error.message : String(error)}) (DEV CODE ${payload.code})`);
      });
  };

  const runUpdateCheck = async (logOutcome: boolean): Promise<UpdateCheckResult> => {
    const payload = { channel, installedVersion, installedAt };
    const result: UpdateCheckResult = window.launcher?.checkForUpdate
      ? ((await window.launcher.checkForUpdate(payload)) as UpdateCheckResult)
      : await checkGitHubUpdate(payload.channel, payload.installedVersion, payload.installedAt);

    if (result.status === 'error') {
      if (logOutcome) {
        pushLog(`Update failed (${result.reason})`);
      }
      return result;
    }

    setRelease(result.release ?? null);

    setInstall((prev) => {
      if (prev.state === 'Updating' || prev.state === 'Repairing') return prev;
      if (prev.state === 'NotInstalled') return prev;
      if (result.updateAvailable) {
        return { ...prev, state: 'UpdateAvailable' };
      }
      return { ...prev, state: 'Installed' };
    });

    if (logOutcome) {
      if (!result.updateAvailable) {
        pushLog('No update necessary');
      } else {
        pushLog(`Update available (${result.latestVersion})`);
      }
    }

    return result;
  };

  useEffect(() => {
    runUpdateCheck(false).catch((error) => {
      pushLog(`Update failed (${error instanceof Error ? error.message : String(error)})`);
    });
  }, [channel]);

  useEffect(() => {
    if (authSession && !authUser) {
      setAuthSession(null);
      writeAuthSession(null);
    }
  }, [authSession, authUser]);

  useEffect(() => {
    if (settings.useLocalBuild) return;
    const updated = { ...settings, useLocalBuild: true };
    setSettings(updated);
    writeSettings(updated);
    pushLog('Local Godot build enforced');
  }, []);

  useEffect(() => {
    let active = true;

    const syncLocalVersion = async () => {
      if (!settings.useLocalBuild || !window.launcher?.getBuildInfo) return;
      const result = await window.launcher.getBuildInfo();
      if (!active || result.status !== 'ok') return;
      const localVersion = result.gameVersion?.trim();
      if (!localVersion || localVersion === installedVersion) return;

      setInstalledVersion(localVersion);
      setInstall((prev) => ({ ...prev, state: 'Installed' }));
      writeInstalled({
        version: localVersion,
        channel,
        installedAt: new Date().toISOString(),
        path: settings.installDir
      });
      pushLog(`Local version synced (${localVersion})`);
    };

    syncLocalVersion().catch((error) => {
      pushLog(`Version sync failed (${error instanceof Error ? error.message : String(error)})`);
    });

    return () => {
      active = false;
    };
  }, [settings.useLocalBuild, settings.installDir, channel, installedVersion]);

  useEffect(() => {
    if (!window.launcher?.onUpdateProgress) return undefined;
    const unsubscribe = window.launcher.onUpdateProgress((payload) => {
      setInstall((prev) => ({
        ...prev,
        state: coerceState(payload.state) ?? prev.state,
        step: coerceStep(payload.step),
        progress: payload.progress ?? prev.progress,
        message: payload.message ?? prev.message
      }));
    });
    return () => {
      if (unsubscribe) unsubscribe();
    };
  }, []);

  useEffect(() => {
    let mounted = true;

    const hydrateServerStatus = async () => {
      if (!window.launcher?.getServerStatus) return;
      const result = await window.launcher.getServerStatus();
      if (!mounted || result.status !== 'ok') return;
      setServer(result.server);
    };

    hydrateServerStatus().catch((error) => {
      pushLog(`Server status failed (${error instanceof Error ? error.message : String(error)})`);
    });

    if (!window.launcher?.onServerStatus) {
      return () => {
        mounted = false;
      };
    }

    const unsubscribe = window.launcher.onServerStatus((payload) => {
      if (!mounted) return;
      setServer(payload);
      if (payload.status === 'Running' && payload.port) {
        pushLog(`Server running on port ${payload.port}`);
      }
      if (payload.status === 'Stopped') {
        pushLog('Server stopped');
      }
      if (payload.status === 'Error' && payload.message) {
        pushLog(`Server error (${payload.message})`);
      }
    });

    return () => {
      mounted = false;
      if (unsubscribe) unsubscribe();
    };
  }, []);

  const refreshSocial = async () => {
    if (!authUser || !window.launcher?.socialListFriends || !window.launcher?.socialListFriendRequests) {
      return;
    }
    const [friendsResult, requestsResult] = await Promise.all([
      window.launcher.socialListFriends({ userId: authUser.id }),
      window.launcher.socialListFriendRequests({ userId: authUser.id })
    ]);
    if (friendsResult.status === 'ok') {
      setFriends(friendsResult.friends);
    }
    if (requestsResult.status === 'ok') {
      setFriendRequests(requestsResult.requests);
    }
  };

  useEffect(() => {
    if (!authUser || !window.launcher?.socialSetPresence) {
      setFriends([]);
      setFriendRequests([]);
      return undefined;
    }

    const heartbeat = () => {
      window.launcher?.socialSetPresence?.({
        userId: authUser.id,
        online: true
      });
    };

    refreshSocial().catch((error) => {
      pushLog(`Social sync failed (${error instanceof Error ? error.message : String(error)})`);
    });

    heartbeat();
    const interval = window.setInterval(heartbeat, PRESENCE_HEARTBEAT_MS);
    socialRefreshRef.current = interval;

    return () => {
      window.clearInterval(interval);
      socialRefreshRef.current = null;
      window.launcher?.socialSetPresence?.({ userId: authUser.id, online: false });
    };
  }, [authUser?.id]);

  const finalizeInstall = (version: string) => {
    setInstalledVersion(version);
    writeInstalled({
      version,
      channel,
      installedAt: new Date().toISOString(),
      path: settings.installDir
    });
    setInstall({ state: 'Installed', step: 'Idle', progress: 0 });
  };

  const attemptUpdate = async (mode: 'update' | 'repair') => {
    setInstall({ state: mode === 'repair' ? 'Repairing' : 'Updating', step: 'Downloading', progress: 0 });
    const check = await runUpdateCheck(true);
    if (check.status === 'error') {
      setInstall({ state: 'Error', step: 'Idle', progress: 0, error: check.reason });
      return;
    }

    if (!check.updateAvailable && mode !== 'repair') {
      setInstall({ state: 'Installed', step: 'Idle', progress: 0 });
      return;
    }

    if (!window.launcher?.performUpdate) {
      const reason = 'Updater unavailable in this environment';
      pushLog(`Update failed (${reason})`);
      setInstall({ state: 'Error', step: 'Idle', progress: 0, error: reason });
      return;
    }

    const result: UpdateResult = await window.launcher.performUpdate({
      channel,
      installDir: settings.installDir,
      gameExeRelative: settings.gameExeRelative
    });

    if (result.status === 'error') {
      pushLog(`Update failed (${result.reason})`);
      setInstall({ state: 'Error', step: 'Idle', progress: 0, error: result.reason });
      return;
    }

    finalizeInstall(result.version);
    pushLog(`Update complete (${result.version})`);
  };

  useEffect(() => {
    if (autoUpdateTriggeredRef.current) return;
    if (!settings.autoUpdate || settings.useLocalBuild) return;
    autoUpdateTriggeredRef.current = true;

    attemptUpdate('update').catch((error) => {
      pushLog(`Auto-update failed (${error instanceof Error ? error.message : String(error)})`);
      setInstall({ state: 'Error', step: 'Idle', progress: 0, error: String(error) });
    });
  }, [settings.autoUpdate, settings.useLocalBuild]);
  const startInstall = () => {
    (async () => {
      if (install.state === 'NotInstalled') {
        const chosen = await chooseInstallDir();
        if (!chosen) {
          pushLog('Install cancelled (no download directory selected)');
          return;
        }
      }

      await attemptUpdate('update');
    })().catch((error) => {
      pushLog(`Update failed (${error instanceof Error ? error.message : String(error)})`);
      setInstall({ state: 'Error', step: 'Idle', progress: 0, error: String(error) });
    });
  };

  const startRepair = () => {
    attemptUpdate('repair').catch((error) => {
      pushLog(`Update failed (${error instanceof Error ? error.message : String(error)})`);
      setInstall({ state: 'Error', step: 'Idle', progress: 0, error: String(error) });
    });
  };

  const packageBuild = async () => {
    if (!window.launcher?.packageBuild) {
      pushLog('Packaging failed (Launcher bridge unavailable)');
      return;
    }
    pushLog('Packaging started');
    const result = await window.launcher.packageBuild({
      installDir: settings.installDir,
      configuration: 'Development'
    });
    if (result.status === 'error') {
      pushLog(`Packaging failed (${result.reason})`);
      return;
    }
    pushLog('Packaging complete');
  };

  const markCorrupt = () => {
    setInstall({ state: 'RepairRecommended', step: 'Idle', progress: 0, message: 'Integrity check failed' });
    pushLog('Integrity mismatch detected');
  };

  const triggerError = (message: string) => {
    setInstall({ state: 'Error', step: 'Idle', progress: 0, error: message });
    pushLog(`Update failed (${message})`);
  };

  const updateSettings = (next: Partial<LauncherSettings>) => {
    setSettings((prev) => {
      const updated = { ...prev, ...next };
      writeSettings(updated);
      return updated;
    });
  };

  const chooseInstallDir = async (): Promise<boolean> => {
    if (!window.launcher?.pickDirectory) {
      pushLog('Directory picker unavailable in this environment');
      return false;
    }

    const result = await window.launcher.pickDirectory({
      title: 'Choose where Project P1L0T will be downloaded',
      defaultPath: settings.installDir
    });

    if (result.status !== 'ok' || !result.path) {
      return false;
    }

    updateSettings({ installDir: result.path });
    pushLog(`Install directory set (${result.path})`);
    return true;
  };

  const resetLauncherSettings = () => {
    const next = resetSettings();
    setSettings(next);
    pushLog('Settings reset');
  };

  const clearLogs = () => {
    setLogs([`[${formatDate(new Date().toISOString())}] Logs cleared`]);
  };

  const requestLaunch = async () => {
    if (!window.launcher?.launchGame) {
      pushLog('Launch failed (Launcher bridge unavailable)');
      return;
    }
    const result = await window.launcher.launchGame({
      channel,
      installDir: settings.installDir,
      gameExeRelative: settings.gameExeRelative,
      useLocalBuild: settings.useLocalBuild,
      localBuildRelative: settings.localBuildRelative,
      launchArgs: settings.launchArgs,
      safeMode: settings.safeMode,
      buildVersion: installedVersion
    });
    if (result.status === 'error') {
      pushLog(`Launch failed (${result.reason})`);
      setInstall((prev) => ({ ...prev, state: 'Error', error: result.reason }));
      return;
    }
    pushLog('Launch initiated');
  };

  const requestLocalLaunch = async () => {
    if (!window.launcher?.launchGame) {
      pushLog('Launch failed (Launcher bridge unavailable)');
      return;
    }
    const result = await window.launcher.launchGame({
      channel,
      installDir: settings.installDir,
      gameExeRelative: settings.gameExeRelative,
      useLocalBuild: true,
      localBuildRelative: settings.localBuildRelative || defaultSettings.localBuildRelative,
      launchArgs: settings.launchArgs,
      safeMode: settings.safeMode,
      buildVersion: installedVersion
    });
    if (result.status === 'error') {
      pushLog(`Launch failed (${result.reason})`);
      setInstall((prev) => ({ ...prev, state: 'Error', error: result.reason }));
      return;
    }
    pushLog('Local launch initiated');
  };

  const requestJoinServer = async () => {
    if (!window.launcher?.launchGame) {
      pushLog('Launch failed (Launcher bridge unavailable)');
      return;
    }

    const joinArgs = `--connect ${settings.serverAddress} --port ${settings.serverPort}`;
    const launchArgs = [settings.launchArgs.trim(), joinArgs].filter(Boolean).join(' ');

    const result = await window.launcher.launchGame({
      channel,
      installDir: settings.installDir,
      gameExeRelative: settings.gameExeRelative,
      useLocalBuild: settings.useLocalBuild,
      localBuildRelative: settings.localBuildRelative,
      launchArgs,
      safeMode: settings.safeMode,
      buildVersion: installedVersion
    });

    if (result.status === 'error') {
      pushLog(`Launch failed (${result.reason})`);
      setInstall((prev) => ({ ...prev, state: 'Error', error: result.reason }));
      return;
    }

    pushLog(`Join initiated (${settings.serverAddress}:${settings.serverPort})`);
  };

  const startServer = async () => {
    if (!window.launcher?.startServer) {
      pushLog('Server start failed (Launcher bridge unavailable)');
      return;
    }
    const useAllHardware = window.confirm(
      'Enable max performance mode for hosted server?\n\nThis will request high process priority and full hardware utilization.'
    );
    const result = await window.launcher.startServer({
      channel,
      installDir: settings.installDir,
      gameExeRelative: settings.gameExeRelative,
      useLocalBuild: settings.useLocalBuild,
      localBuildRelative: settings.localBuildRelative,
      serverPort: settings.serverPort,
      serverArgs: settings.serverArgs,
      useAllHardware
    });
    if (result.status === 'error') {
      pushLog(`Server start failed (${result.reason})`);
      setServer({ status: 'Error', message: result.reason });
      return;
    }
    pushLog(useAllHardware ? 'Server started (max performance mode)' : 'Server started (standard mode)');
    setServer(result.server);
  };

  const stopServer = async () => {
    if (!window.launcher?.stopServer) {
      pushLog('Server stop failed (Launcher bridge unavailable)');
      return;
    }
    const result = await window.launcher.stopServer();
    if (result.status === 'error') {
      pushLog(`Server stop failed (${result.reason})`);
      setServer((prev) => ({ ...prev, status: 'Error', message: result.reason }));
      return;
    }
    setServer(result.server);
  };

  const openInstallDir = () => {
    if (window.launcher?.openPath) {
      window.launcher.openPath(settings.installDir);
    }
  };

  const openLogs = () => {
    if (window.launcher?.openLogs) {
      window.launcher.openLogs();
    }
  };

  const createUserAccount = (payload: { username: string; email: string; password: string }): AuthActionResult => {
    const username = payload.username.trim();
    const email = normalizeIdentity(payload.email);
    const password = payload.password;

    if (username.length < 3) return { ok: false, message: 'Username must be at least 3 characters.' };
    if (!email.includes('@') || email.length < 5) return { ok: false, message: 'Enter a valid email address.' };
    if (password.length < 8) return { ok: false, message: 'Password must be at least 8 characters.' };

    const usernameTaken = authUsers.some((user) => normalizeIdentity(user.username) === normalizeIdentity(username));
    if (usernameTaken) return { ok: false, message: 'Username already exists.' };
    const emailTaken = authUsers.some((user) => normalizeIdentity(user.email) === email);
    if (emailTaken) return { ok: false, message: 'Email already in use.' };

    const verificationCode = generateVerificationCode();
    const now = new Date().toISOString();
    const nextUser: AuthUserRecord = {
      id: `usr_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`,
      username,
      email,
      emailVerified: false,
      bio: '',
      statusMessage: 'Online',
      discordUsername: '',
      avatarDataUrl: '',
      passwordHash: hashPassword(password),
      createdAt: now,
      verificationCodeHash: hashPassword(verificationCode),
      verificationSentAt: now
    };
    const nextUsers = [...authUsers, nextUser];
    setAuthUsers(nextUsers);
    writeAuthUsers(nextUsers);

    if (window.launcher?.socialCreateProfile) {
      window.launcher
        .socialCreateProfile({
          id: nextUser.id,
          username: nextUser.username,
          email: nextUser.email
        })
        .catch((error) => {
          pushLog(`Social profile create failed (${error instanceof Error ? error.message : String(error)})`);
        });
    }

    setPendingVerificationIdentity(email);
    pushLog(`Account created (${username})`);
    queueVerificationEmail({ username, email, code: verificationCode });
    return {
      ok: true,
      requiresVerification: true,
      devCode: verificationCode,
      message: `Validation email queued to ${maskEmail(email)} from noreply@cydonianheavyindustries.inc.`
    };
  };

  const loginUser = (payload: { identity: string; password: string }): AuthActionResult => {
    const identity = normalizeIdentity(payload.identity);
    const passwordHash = hashPassword(payload.password);
    const matched = authUsers.find(
      (user) => normalizeIdentity(user.username) === identity || normalizeIdentity(user.email) === identity
    );
    if (!matched || matched.passwordHash !== passwordHash) {
      return { ok: false, message: 'Invalid username/email or password.' };
    }

    if (!matched.emailVerified) {
      setPendingVerificationIdentity(isLikelyEmailAddress(identity) ? identity : matched.email);
      return {
        ok: false,
        requiresVerification: true,
        message: 'Email not verified. Enter your validation code.'
      };
    }

    const now = new Date().toISOString();
    const nextUsers = authUsers.map((user) => (user.id === matched.id ? { ...user, lastLoginAt: now } : user));
    setAuthUsers(nextUsers);
    writeAuthUsers(nextUsers);

    const session = buildSession(matched.id);
    setAuthSession(session);
    writeAuthSession(session);
    setPendingVerificationIdentity('');
    pushLog(`Signed in (${matched.username})`);

    if (window.launcher?.socialSetPresence) {
      window.launcher.socialSetPresence({ userId: matched.id, online: true }).catch(() => null);
    }

    refreshSocial().catch(() => null);
    return { ok: true, message: `Signed in as ${matched.username}.` };
  };

  const verifyEmailCode = (payload: { identity: string; code: string }): AuthActionResult => {
    const identity = normalizeIdentity(payload.identity);
    const code = payload.code.trim();
    if (!identity) return { ok: false, message: 'Enter username or email.' };
    if (!/^\d{6}$/.test(code)) return { ok: false, message: 'Validation code must be 6 digits.' };

    const matched = authUsers.find(
      (user) => normalizeIdentity(user.username) === identity || normalizeIdentity(user.email) === identity
    );
    if (!matched) return { ok: false, message: 'User not found for verification.' };
    if (matched.emailVerified) return { ok: true, message: 'Email already verified.' };
    if (!matched.verificationCodeHash) return { ok: false, message: 'No active code. Request a new one.' };
    if (isVerificationExpired(matched.verificationSentAt)) {
      return { ok: false, message: 'Validation code expired. Request a new code.' };
    }
    if (matched.verificationCodeHash !== hashPassword(code)) {
      return { ok: false, message: 'Invalid validation code.' };
    }

    const now = new Date().toISOString();
    const nextUsers = authUsers.map((user) =>
      user.id === matched.id
        ? {
            ...user,
            emailVerified: true,
            verificationCodeHash: undefined,
            verificationSentAt: undefined,
            lastLoginAt: now
          }
        : user
    );
    setAuthUsers(nextUsers);
    writeAuthUsers(nextUsers);

    const session = buildSession(matched.id);
    setAuthSession(session);
    writeAuthSession(session);
    setPendingVerificationIdentity('');
    pushLog(`Email verified (${matched.username})`);

    if (window.launcher?.socialSetPresence) {
      window.launcher.socialSetPresence({ userId: matched.id, online: true }).catch(() => null);
    }

    refreshSocial().catch(() => null);
    return { ok: true, message: `Email verified. Signed in as ${matched.username}.` };
  };

  const resendVerificationCode = (identityValue: string): AuthActionResult => {
    const identity = normalizeIdentity(identityValue);
    if (!identity) return { ok: false, message: 'Enter username or email.' };

    const matched = authUsers.find(
      (user) => normalizeIdentity(user.username) === identity || normalizeIdentity(user.email) === identity
    );
    if (!matched) return { ok: false, message: 'User not found.' };
    if (matched.emailVerified) return { ok: true, message: 'Email already verified.' };

    const cooldownSeconds = getResendCooldownSeconds(matched.verificationSentAt);
    if (cooldownSeconds > 0) {
      return {
        ok: false,
        requiresVerification: true,
        message: `Please wait ${cooldownSeconds}s before requesting another code.`
      };
    }

    const code = generateVerificationCode();
    const now = new Date().toISOString();
    const nextUsers = authUsers.map((user) =>
      user.id === matched.id
        ? {
            ...user,
            verificationCodeHash: hashPassword(code),
            verificationSentAt: now
          }
        : user
    );
    setAuthUsers(nextUsers);
    writeAuthUsers(nextUsers);
    setPendingVerificationIdentity(matched.email);
    queueVerificationEmail({ username: matched.username, email: matched.email, code });
    return {
      ok: true,
      requiresVerification: true,
      devCode: code,
      message: `Validation code re-sent to ${maskEmail(matched.email)} from noreply@cydonianheavyindustries.inc.`
    };
  };

  const updateAccountProfile = (payload: {
    bio: string;
    statusMessage: string;
    discordUsername: string;
    avatarDataUrl?: string;
  }): AuthActionResult => {
    if (!authSession) {
      return { ok: false, message: 'Sign in required.' };
    }

    const bio = payload.bio.trim().slice(0, 280);
    const statusMessage = payload.statusMessage.trim().slice(0, 80);
    const discordUsername = payload.discordUsername.trim().slice(0, 64);
    const avatarDataUrl = (payload.avatarDataUrl ?? '').trim();

    if (!statusMessage) {
      return { ok: false, message: 'Status cannot be empty.' };
    }

    const nextUsers = authUsers.map((user) =>
      user.id === authSession.userId
        ? {
            ...user,
            bio,
            statusMessage,
            discordUsername,
            avatarDataUrl
          }
        : user
    );
    setAuthUsers(nextUsers);
    writeAuthUsers(nextUsers);

    if (window.launcher?.socialUpdateProfile) {
      window.launcher
        .socialUpdateProfile({
          userId: authSession.userId,
          bio,
          statusMessage,
          discordUsername,
          avatarDataUrl
        })
        .catch((error) => {
          pushLog(`Profile sync failed (${error instanceof Error ? error.message : String(error)})`);
        });
    }

    pushLog('Account profile updated');
    return { ok: true, message: 'Profile updated.' };
  };

  const logoutUser = () => {
    if (authUser) {
      pushLog(`Signed out (${authUser.username})`);
      window.launcher?.socialSetPresence?.({ userId: authUser.id, online: false });
    }
    setAuthSession(null);
    writeAuthSession(null);
    setPendingVerificationIdentity('');
    setFriends([]);
    setFriendRequests([]);
  };

  const searchPlayers = async (query: string): Promise<SocialProfile[]> => {
    if (!window.launcher?.socialSearchPlayers) return [];
    if (!authUser) return [];
    const result = await window.launcher.socialSearchPlayers({ query, requesterId: authUser.id });
    if (result.status === 'ok') return result.results;
    return [];
  };

  const sendFriendRequest = async (targetId: string): Promise<AuthActionResult> => {
    if (!authUser || !window.launcher?.socialSendFriendRequest) {
      return { ok: false, message: 'Sign in required.' };
    }
    const result = await window.launcher.socialSendFriendRequest({ fromId: authUser.id, toId: targetId });
    if (result.status === 'ok') {
      await refreshSocial();
      return { ok: true, message: 'Friend request sent.' };
    }
    return { ok: false, message: result.reason || 'Unable to send request.' };
  };

  const acceptFriendRequest = async (requestId: string): Promise<AuthActionResult> => {
    if (!authUser || !window.launcher?.socialRespondFriendRequest) {
      return { ok: false, message: 'Sign in required.' };
    }
    const result = await window.launcher.socialRespondFriendRequest({ requestId, accept: true });
    if (result.status === 'ok') {
      await refreshSocial();
      return { ok: true, message: 'Friend request accepted.' };
    }
    return { ok: false, message: result.reason || 'Unable to accept request.' };
  };

  const rejectFriendRequest = async (requestId: string): Promise<AuthActionResult> => {
    if (!authUser || !window.launcher?.socialRespondFriendRequest) {
      return { ok: false, message: 'Sign in required.' };
    }
    const result = await window.launcher.socialRespondFriendRequest({ requestId, accept: false });
    if (result.status === 'ok') {
      await refreshSocial();
      return { ok: true, message: 'Friend request declined.' };
    }
    return { ok: false, message: result.reason || 'Unable to decline request.' };
  };

  return {
    channel,
    setChannel,
    release,
    install,
    server,
    installedVersion,
    settings,
    logs,
    authUser,
    authMode: 'local',
    pendingVerificationIdentity,
    friends,
    friendRequests,
    actions: {
      startInstall,
      startUpdate: startInstall,
      startRepair,
      packageBuild,
      markCorrupt,
      triggerError,
      clearLogs,
      updateSettings,
      resetSettings: resetLauncherSettings,
      requestLaunch,
      requestLocalLaunch,
      requestJoinServer,
      startServer,
      stopServer,
      openInstallDir,
      chooseInstallDir,
      openLogs,
      createUserAccount,
      loginUser,
      verifyEmailCode,
      resendVerificationCode,
      updateAccountProfile,
      logoutUser,
      refreshSocial,
      searchPlayers,
      sendFriendRequest,
      acceptFriendRequest,
      rejectFriendRequest
    }
  };
};
