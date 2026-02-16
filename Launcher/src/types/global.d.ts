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
      sendVerificationEmail: (payload: {
        username: string;
        email: string;
        code: string;
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
        useAllHardware?: boolean;
      }) => Promise<LauncherServerResult>;
      stopServer: () => Promise<LauncherServerResult>;
      openPath: (targetPath: string) => Promise<void>;
      openLogs: () => Promise<void>;
      pickDirectory: (payload: { title?: string; defaultPath?: string }) => Promise<{ status: 'ok'; path: string } | { status: 'cancelled' }>;
      socialCreateProfile: (payload: { id: string; username: string; email: string }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      socialUpdateProfile: (payload: {
        userId: string;
        bio: string;
        statusMessage: string;
        discordUsername: string;
        avatarDataUrl?: string;
      }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      socialSetPresence: (payload: { userId: string; online: boolean }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      socialSearchPlayers: (payload: { query: string; requesterId: string }) => Promise<{ status: 'ok'; results: any[] } | { status: 'error'; reason: string }>;
      socialSendFriendRequest: (payload: { fromId: string; toId: string }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      socialRespondFriendRequest: (payload: { requestId: string; accept: boolean }) => Promise<{ status: 'ok' } | { status: 'error'; reason: string }>;
      socialListFriendRequests: (payload: { userId: string }) => Promise<{ status: 'ok'; requests: any[] } | { status: 'error'; reason: string }>;
      socialListFriends: (payload: { userId: string }) => Promise<{ status: 'ok'; friends: any[] } | { status: 'error'; reason: string }>;
      onUpdateProgress: (
        callback: (payload: { step: string; progress: number; message?: string; state?: string }) => void
      ) => () => void;
      onServerStatus: (callback: (payload: LauncherServerState) => void) => () => void;
    };
  }
}
