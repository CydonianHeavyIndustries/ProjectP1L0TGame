export interface AuthUser {
  id: string;
  username: string;
  email: string;
  emailVerified: boolean;
  bio?: string;
  statusMessage?: string;
  discordUsername?: string;
  avatarDataUrl?: string;
  createdAt: string;
  lastLoginAt?: string;
}

export interface AuthUserRecord extends AuthUser {
  passwordHash: string;
  verificationCodeHash?: string;
  verificationSentAt?: string;
}

export interface AuthSession {
  userId: string;
  signedInAt: string;
}
