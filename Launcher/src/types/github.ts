export interface GitHubAsset {
  name: string;
  size: number;
  url: string;
}

export interface GitHubRelease {
  version: string;
  name: string;
  publishedAt: string;
  body?: string | null;
  asset?: GitHubAsset | null;
}
