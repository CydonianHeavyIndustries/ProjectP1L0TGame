import { useEffect, useMemo, useState } from 'react';
import type { Channel } from '../types/channel';
import type { InstallStatus, InstallState, InstallStep } from '../types/install';
import type { LauncherSettings } from '../types/settings';
import type { LauncherState } from '../types/launcher';
import type { GitHubRelease } from '../types/github';
import type { ServerState } from '../types/server';
import type { UpdateCheckResult, UpdateResult } from '../types/update';
import { formatDate } from '../utils/format';
import { checkGitHubUpdate } from './github';
import { defaultSettings, readInstalled, readSettings, resetSettings, writeInstalled, writeSettings } from './storage';

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

export const useLauncherState = (): LauncherState => {
  const installedRecord = useMemo(() => readInstalled(), []);
  const installedAt = installedRecord?.installedAt;
  const [channel, setChannel] = useState<Channel>('dev');
  const [release, setRelease] = useState<GitHubRelease | null>(null);
  const [install, setInstall] = useState<InstallStatus>(() => initialInstallStatus(installedRecord?.version ?? null));
  const [server, setServer] = useState<ServerState>(initialServerState);
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

  return {
    channel,
    setChannel,
    release,
    install,
    server,
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
      resetSettings: resetLauncherSettings,
      requestLaunch,
      requestLocalLaunch,
      requestJoinServer,
      startServer,
      stopServer,
      openInstallDir,
      chooseInstallDir,
      openLogs
    }
  };
};
