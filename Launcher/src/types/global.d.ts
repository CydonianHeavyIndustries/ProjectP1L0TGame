export {};

declare global {
  type LauncherServerState = {
    status: 'Stopped' | 'Starting' | 'Running' | 'Stopping' | 'Error';
    pid?: number;
    port?: number;
    startedAt?: string;
    message?: string;
  };

  type LauncherServerResult = { status: 'ok'; server: LauncherServerState } | { status: 'error'; reason: string };

  interface Window {
    launcher?: {
      isDev: boolean;
      platform: string;
      version: string;
      getBuildInfo: () => Promise<
        | { status: 'ok'; launcherVersion: string; gameVersion?: string | null }
        | { status: 'error'; reason: string }
      >;
      checkForUpdate: (payload: { channel: string; installedVersion: string; installedAt?: string }) => Promise<
        | {
            status: 'ok';
            updateAvailable: boolean;
            latestVersion: string;
            release?: unknown;
          }
        | { status: 'error'; reason: string }
      >;
      performUpdate: (payload: { channel: string; installDir: string; gameExeRelative: string }) => Promise<
        | { status: 'ok'; version: string; installDir: string }
        | { status: 'error'; reason: string }
      >;
      launchGame: (payload: {
        channel: string;
        installDir: string;
        gameExeRelative: string;
        useLocalBuild: boolean;
        localBuildRelative: string;
        launchArgs: string;
        safeMode: boolean;
        buildVersion: string;
      }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      packageBuild: (payload: {
        installDir: string;
        configuration?: string;
        zip?: boolean;
      }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      getServerStatus: () => Promise<LauncherServerResult>;
      startServer: (payload: {
        channel: string;
        installDir: string;
        gameExeRelative: string;
        useLocalBuild: boolean;
        localBuildRelative: string;
        serverPort: number;
        serverArgs: string;
      }) => Promise<LauncherServerResult>;
      stopServer: () => Promise<LauncherServerResult>;
      openPath: (targetPath: string) => Promise<void>;
      openLogs: () => Promise<void>;
      onUpdateProgress: (
        callback: (payload: { step: string; progress: number; message?: string; state?: string }) => void
      ) => () => void;
      onServerStatus: (callback: (payload: LauncherServerState) => void) => () => void;
    };
  }
}
