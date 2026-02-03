import { useEffect, useMemo, useState } from 'react';
import type { Channel } from '../types/channel';
import type { InstallStatus, InstallState, InstallStep } from '../types/install';
import type { LauncherSettings } from '../types/settings';
import type { LauncherState } from '../types/launcher';
import type { GitHubRelease } from '../types/github';
import type { UpdateCheckResult, UpdateResult } from '../types/update';
import { formatDate } from '../utils/format';
import { checkGitHubUpdate } from './github';
import { readInstalled, readSettings, writeInstalled, writeSettings } from './storage';

const initialInstallStatus = (installedVersion: string | null): InstallStatus => ({
  state: installedVersion && installedVersion !== '0.0.0' ? 'Installed' : 'NotInstalled',
  step: 'Idle',
  progress: 0
});

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

export const useLauncherState = (): LauncherState => {
  const installedRecord = useMemo(() => readInstalled(), []);
  const installedAt = installedRecord?.installedAt;
  const [channel, setChannel] = useState<Channel>('dev');
  const [release, setRelease] = useState<GitHubRelease | null>(null);
  const [install, setInstall] = useState<InstallStatus>(() => initialInstallStatus(installedRecord?.version ?? null));
  const [installedVersion, setInstalledVersion] = useState(installedRecord?.version ?? '0.0.0');
  const [settings, setSettings] = useState<LauncherSettings>(() => readSettings());
  const [logs, setLogs] = useState<string[]>([`[${formatDate(new Date().toISOString())}] Launcher booted`]);

  const pushLog = (message: string) => {
    setLogs((prev) => [`[${formatDate(new Date().toISOString())}] ${message}`, ...prev]);
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

  const startInstall = () => {
    attemptUpdate('update').catch((error) => {
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

  return {
    channel,
    setChannel,
    release,
    install,
    installedVersion,
    settings,
    logs,
    actions: {
      startInstall,
      startUpdate: startInstall,
      startRepair,
      packageBuild,
      markCorrupt,
      triggerError,
      clearLogs,
      updateSettings,
      requestLaunch,
      openInstallDir,
      openLogs
    }
  };
};
