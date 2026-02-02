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

export const checkGitHubUpdate = async (channel: string, installedVersion: string): Promise<UpdateCheckResult> => {
  try {
    const response = await fetch(`${API_BASE}/releases`, {
      headers: {
        Accept: 'application/vnd.github+json'
      }
    });
    if (!response.ok) {
      return { status: 'error', reason: `GitHub request failed (${response.status})` };
    }
    const releases = (await response.json()) as RawRelease[];
    if (!Array.isArray(releases) || releases.length === 0) {
      return { status: 'error', reason: 'No releases found' };
    }
    const picked = pickRelease(releases, channel);
    if (!picked) {
      return { status: 'error', reason: `No releases available for ${channel}` };
    }
    const release = mapRelease(picked);
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
