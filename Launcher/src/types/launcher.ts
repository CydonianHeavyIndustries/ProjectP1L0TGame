import type { Channel } from './channel';
import type { GitHubRelease } from './github';
import type { InstallStatus } from './install';
import type { ServerState } from './server';
import type { LauncherSettings } from './settings';
import type { AuthUser } from './auth';
import type { SocialFriend, SocialFriendRequest, SocialProfile } from './social';

export interface AuthActionResult {
  ok: boolean;
  message: string;
  requiresVerification?: boolean;
  devCode?: string;
}

export interface LauncherActions {
  startInstall: () => void;
  startUpdate: () => void;
  startRepair: () => void;
  packageBuild: () => void;
  markCorrupt: () => void;
  triggerError: (message: string) => void;
  clearLogs: () => void;
  updateSettings: (next: Partial<LauncherSettings>) => void;
  resetSettings: () => void;
  requestLaunch: () => void;
  requestLocalLaunch: () => void;
  requestJoinServer: () => void;
  startServer: () => void;
  stopServer: () => void;
  openInstallDir: () => void;
  chooseInstallDir: () => Promise<boolean>;
  openLogs: () => void;
  createUserAccount: (payload: { username: string; email: string; password: string }) => AuthActionResult;
  loginUser: (payload: { identity: string; password: string }) => AuthActionResult;
  verifyEmailCode: (payload: { identity: string; code: string }) => AuthActionResult;
  resendVerificationCode: (identity: string) => AuthActionResult;
  updateAccountProfile: (payload: {
    bio: string;
    statusMessage: string;
    discordUsername: string;
    avatarDataUrl?: string;
  }) => AuthActionResult;
  logoutUser: () => void;
  refreshSocial: () => Promise<void>;
  searchPlayers: (query: string) => Promise<SocialProfile[]>;
  sendFriendRequest: (targetId: string) => Promise<AuthActionResult>;
  acceptFriendRequest: (requestId: string) => Promise<AuthActionResult>;
  rejectFriendRequest: (requestId: string) => Promise<AuthActionResult>;
}

export interface LauncherState {
  channel: Channel;
  setChannel: (channel: Channel) => void;
  release: GitHubRelease | null;
  install: InstallStatus;
  server: ServerState;
  installedVersion: string;
  settings: LauncherSettings;
  logs: string[];
  authUser: AuthUser | null;
  authMode: 'local';
  pendingVerificationIdentity: string;
  friends: SocialFriend[];
  friendRequests: SocialFriendRequest[];
  actions: LauncherActions;
}
