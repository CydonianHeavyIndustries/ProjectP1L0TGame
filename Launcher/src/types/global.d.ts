export {};

declare global {
  interface Window {
    launcher?: {
      isDev: boolean;
      platform: string;
      version: string;
      checkForUpdate: (payload: { channel: string; installedVersion: string }) => Promise<
        | {
            status: 'ok';
            updateAvailable: boolean;
            latestVersion: string;
            release?: unknown;
          }
        | { status: 'error'; reason: string }
      >;
      performUpdate: (payload: { channel: string; installDir: string }) => Promise<
        | { status: 'ok'; version: string; installDir: string }
        | { status: 'error'; reason: string }
      >;
      openPath: (targetPath: string) => Promise<void>;
      openLogs: () => Promise<void>;
      onUpdateProgress: (
        callback: (payload: { step: string; progress: number; message?: string; state?: string }) => void
      ) => () => void;
    };
  }
}
