import type { GitHubRelease } from '../types/github';
import type { UpdateCheckResult } from '../types/update';
import { compareSemver } from '../utils/format';

const REPO = 'CydonianHeavyIndustries/ProjectP1L0TGame';
const API_BASE = `https://api.github.com/repos/${REPO}`;
const CHANNEL_BRANCH: Record<string, string> = {
  dev: 'master',
  test: 'master',
  live: 'master'
};

interface RawRelease {
  tag_name: string;
  name: string | null;
  body: string | null;
  prerelease: boolean;
  draft: boolean;
  published_at: string;
  assets: { name: string; size: number; browser_download_url: string }[];
}

interface RawCommit {
  sha: string;
  commit: {
    message: string;
    author?: {
      date: string;
    };
  };
}

const normalizeVersion = (tag: string) => tag.replace(/^v/i, '');

const pad = (value: number, size = 2) => String(value).padStart(size, '0');

const versionFromDate = (isoDate: string) => {
  const date = new Date(isoDate);
  if (Number.isNaN(date.getTime())) {
    return '0.0.0.0';
  }
  const year = date.getUTCFullYear();
  const month = pad(date.getUTCMonth() + 1);
  const day = pad(date.getUTCDate());
  const hour = pad(date.getUTCHours());
  const minute = pad(date.getUTCMinutes());
  return `${year}.${month}.${day}.${hour}${minute}`;
};

const mapRelease = (release: RawRelease): GitHubRelease => {
  const asset = release.assets.find((item) => item.name.endsWith('.zip')) ?? release.assets[0];
  return {
    version: normalizeVersion(release.tag_name),
    name: release.name || release.tag_name,
    publishedAt: release.published_at,
    body: release.body,
    asset: asset
      ? {
          name: asset.name,
          size: asset.size,
          url: asset.browser_download_url
        }
      : null
  };
};

const mapCommitRelease = (commit: RawCommit): GitHubRelease => {
  const shortSha = commit.sha.slice(0, 7);
  const publishedAt = commit.commit?.author?.date ?? new Date().toISOString();
  return {
    version: versionFromDate(publishedAt),
    name: `Commit ${shortSha}`,
    publishedAt,
    body: commit.commit?.message ?? null,
    asset: {
      name: `ProjectP1L0TGame-${shortSha}.zip`,
      size: 0,
      url: `${API_BASE}/zipball/${commit.sha}`
    }
  };
};

const pickRelease = (releases: RawRelease[], channel: string): RawRelease | null => {
  const filtered = channel === 'dev' ? releases : releases.filter((rel) => !rel.prerelease && !rel.draft);
  if (filtered.length === 0) return null;
  return filtered.sort((a, b) => Date.parse(b.published_at) - Date.parse(a.published_at))[0];
};

const fetchReleases = async (): Promise<RawRelease[]> => {
  const response = await fetch(`${API_BASE}/releases`, {
    headers: {
      Accept: 'application/vnd.github+json'
    }
  });
  if (!response.ok) {
    throw new Error(`GitHub request failed (${response.status})`);
  }
  return (await response.json()) as RawRelease[];
};

const fetchCommit = async (channel: string): Promise<RawCommit> => {
  const branch = CHANNEL_BRANCH[channel] || 'master';
  const response = await fetch(`${API_BASE}/commits/${branch}`, {
    headers: {
      Accept: 'application/vnd.github+json'
    }
  });
  if (!response.ok) {
    throw new Error(`GitHub request failed (${response.status})`);
  }
  return (await response.json()) as RawCommit;
};

const getReleaseOrCommit = async (channel: string): Promise<GitHubRelease> => {
  try {
    const releases = await fetchReleases();
    if (!Array.isArray(releases) || releases.length === 0) {
      throw new Error('No releases found');
    }
    const picked = pickRelease(releases, channel);
    if (!picked) {
      throw new Error(`No releases available for ${channel}`);
    }
    const release = mapRelease(picked);
    if (!release.asset) {
      throw new Error('No downloadable assets on release');
    }
    return release;
  } catch (error) {
    const releaseReason = error instanceof Error ? error.message : String(error);
    try {
      const commit = await fetchCommit(channel);
      if (!commit?.sha) {
        throw new Error('No commit data found');
      }
      return mapCommitRelease(commit);
    } catch (commitError) {
      const commitReason = commitError instanceof Error ? commitError.message : String(commitError);
      throw new Error(`Release unavailable (${releaseReason}); commit fallback failed (${commitReason})`);
    }
  }
};

export const checkGitHubUpdate = async (channel: string, installedVersion: string): Promise<UpdateCheckResult> => {
  try {
    const release = await getReleaseOrCommit(channel);
    const updateAvailable = compareSemver(installedVersion, release.version) < 0;
    return {
      status: 'ok',
      updateAvailable,
      latestVersion: release.version,
      release
    };
  } catch (error) {
    return { status: 'error', reason: error instanceof Error ? error.message : String(error) };
  }
};
