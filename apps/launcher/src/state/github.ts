import type { GitHubRelease } from '../types/github';
import type { UpdateCheckResult } from '../types/update';
import { compareSemver } from '../utils/format';

const REPO = 'CydonianHeavyIndustries/ProjectP1L0TGame';
const API_BASE = `https://api.github.com/repos/${REPO}`;
interface RawRelease {
  tag_name: string;
  name: string | null;
  body: string | null;
  prerelease: boolean;
  draft: boolean;
  published_at: string;
  assets: { name: string; size: number; browser_download_url: string }[];
}

const normalizeVersion = (tag: string) => tag.replace(/^v/i, '');

const isSemver = (value: string) => /^\d+\.\d+\.\d+$/.test(normalizeVersion(value));
const isTimestampVersion = (value: string) => /^\d{4}\.\d{2}\.\d{2}\.\d{4}$/.test(normalizeVersion(value));

const shouldUpdateWithDates = (installedAt?: string, publishedAt?: string) => {
  if (!installedAt || !publishedAt) return false;
  const installedTime = Date.parse(installedAt);
  const releaseTime = Date.parse(publishedAt);
  if (Number.isNaN(installedTime) || Number.isNaN(releaseTime)) return false;
  return releaseTime > installedTime;
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

const getReleaseOrCommit = async (channel: string): Promise<GitHubRelease> => {
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
};

export const checkGitHubUpdate = async (
  channel: string,
  installedVersion: string,
  installedAt?: string
): Promise<UpdateCheckResult> => {
  try {
    const release = await getReleaseOrCommit(channel);
    const compare = compareSemver(installedVersion, release.version);
    let updateAvailable = compare < 0;
    if (!updateAvailable && compare > 0) {
      const semverMismatch = isSemver(release.version) && isTimestampVersion(installedVersion);
      if (semverMismatch || !isSemver(installedVersion)) {
        updateAvailable = shouldUpdateWithDates(installedAt, release.publishedAt);
      }
    }
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
