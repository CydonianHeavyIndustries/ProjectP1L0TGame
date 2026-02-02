import type { GitHubRelease } from './github';

export type UpdateCheckResult =
  | {
      status: 'ok';
      updateAvailable: boolean;
      latestVersion: string;
      release?: GitHubRelease;
    }
  | { status: 'error'; reason: string };

export type UpdateResult =
  | { status: 'ok'; version: string; installDir: string }
  | { status: 'error'; reason: string };
