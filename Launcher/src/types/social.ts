export type SocialPresence = 'online' | 'offline';

export interface SocialProfile {
  id: string;
  username: string;
  status: SocialPresence;
  lastSeenAt?: string;
  statusMessage?: string;
  discordUsername?: string;
  avatarDataUrl?: string;
}

export interface SocialFriendRequest {
  id: string;
  fromId: string;
  fromUsername: string;
  createdAt: string;
}

export interface SocialFriend {
  id: string;
  username: string;
  status: SocialPresence;
  lastSeenAt?: string;
  statusMessage?: string;
  discordUsername?: string;
  avatarDataUrl?: string;
}
