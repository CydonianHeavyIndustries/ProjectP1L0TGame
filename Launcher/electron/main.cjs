const { app, BrowserWindow, shell, ipcMain } = require('electron');
const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const { Readable } = require('stream');
const { pipeline } = require('stream/promises');
const extract = require('extract-zip');

const REPO = 'CydonianHeavyIndustries/ProjectP1L0TGame';
const API_BASE = `https://api.github.com/repos/${REPO}`;
const CHANNEL_BRANCH = {
  dev: 'master',
  test: 'master',
  live: 'master'
};

const logDir = path.join(app.getPath('userData'), 'logs');
const logFile = path.join(logDir, 'launcher.log');

const safeStringify = (value) => {
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
};

const writeLog = (level, message, meta) => {
  try {
    fs.mkdirSync(logDir, { recursive: true });
    const stamp = new Date().toISOString();
    const extra = meta ? ` | ${meta}` : '';
    fs.appendFileSync(logFile, `[${stamp}] [${level}] ${message}${extra}\n`);
  } catch (error) {
    console.error('Logger failure:', error);
  }
};

const normalizeVersion = (value) => value.replace(/^v/i, '');

const compareSemver = (a, b) => {
  const left = normalizeVersion(a).split('.').map((part) => Number(part) || 0);
  const right = normalizeVersion(b).split('.').map((part) => Number(part) || 0);
  const max = Math.max(left.length, right.length);
  for (let i = 0; i < max; i += 1) {
    const l = left[i] ?? 0;
    const r = right[i] ?? 0;
    if (l > r) return 1;
    if (l < r) return -1;
  }
  return 0;
};

const pad = (value, size = 2) => String(value).padStart(size, '0');

const versionFromDate = (isoDate) => {
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

const requestGitHub = async (endpoint) => {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      Accept: 'application/vnd.github+json',
      'User-Agent': 'ProjectP1L0TLauncher'
    }
  });
  if (!response.ok) {
    throw new Error(`GitHub request failed (${response.status})`);
  }
  return response.json();
};

const pickRelease = (releases, channel) => {
  const filtered = channel === 'dev' ? releases : releases.filter((rel) => !rel.prerelease && !rel.draft);
  if (filtered.length === 0) return null;
  return filtered.sort((a, b) => Date.parse(b.published_at) - Date.parse(a.published_at))[0];
};

const mapRelease = (release) => {
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

const mapCommitRelease = (commit) => {
  const shortSha = commit.sha.slice(0, 7);
  const publishedAt = commit.commit?.author?.date || new Date().toISOString();
  return {
    version: versionFromDate(publishedAt),
    name: `Commit ${shortSha}`,
    publishedAt,
    body: commit.commit?.message || null,
    asset: {
      name: `ProjectP1L0TGame-${shortSha}.zip`,
      size: 0,
      url: `${API_BASE}/zipball/${commit.sha}`
    }
  };
};

const getCommitForChannel = async (channel) => {
  const branch = CHANNEL_BRANCH[channel] || 'master';
  const commit = await requestGitHub(`/commits/${branch}`);
  if (!commit?.sha) {
    throw new Error(`No commit data for ${branch}`);
  }
  return mapCommitRelease(commit);
};

const getReleaseForChannel = async (channel) => {
  try {
    const releases = await requestGitHub('/releases');
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
    const reason = error instanceof Error ? error.message : String(error);
    writeLog('WARN', 'Release fetch failed, falling back to commit', reason);
    return getCommitForChannel(channel);
  }
};

const ensureDir = async (dir) => {
  await fsp.mkdir(dir, { recursive: true });
};

const sendProgress = (sender, payload) => {
  try {
    sender.send('launcher:updateProgress', payload);
  } catch (error) {
    writeLog('WARN', 'Failed to send progress', safeStringify(error));
  }
};

const downloadAsset = async (asset, destination, sender) => {
  writeLog('INFO', 'Download started', asset.url);
  const response = await fetch(asset.url);
  if (!response.ok || !response.body) {
    throw new Error(`Download failed (${response.status})`);
  }

  const total = Number(response.headers.get('content-length') || asset.size || 0);
  const fileStream = fs.createWriteStream(destination);
  const nodeStream = Readable.fromWeb(response.body);

  let downloaded = 0;
  nodeStream.on('data', (chunk) => {
    downloaded += chunk.length;
    const ratio = total > 0 ? Math.min(downloaded / total, 1) : 0;
    sendProgress(sender, {
      state: 'Updating',
      step: 'Downloading',
      progress: Math.round(ratio * 70),
      message: `Downloading ${Math.round(ratio * 100)}%`
    });
  });

  await pipeline(nodeStream, fileStream);
  const stats = await fsp.stat(destination);
  if (asset.size && stats.size !== asset.size) {
    throw new Error('Downloaded size mismatch');
  }
  writeLog('INFO', 'Download complete', destination);
};

const extractPayload = async (archivePath, stagingDir, sender) => {
  sendProgress(sender, { state: 'Updating', step: 'Verifying', progress: 75, message: 'Verifying payload' });
  await ensureDir(stagingDir);
  sendProgress(sender, { state: 'Updating', step: 'Installing', progress: 85, message: 'Extracting payload' });
  await extract(archivePath, { dir: stagingDir });
  sendProgress(sender, { state: 'Updating', step: 'Installing', progress: 92, message: 'Staging build' });
};

const swapInstall = async (installDir, stagingDir, sender) => {
  sendProgress(sender, { state: 'Updating', step: 'Cleaning', progress: 96, message: 'Swapping build' });
  const backupDir = `${installDir}_old_${Date.now()}`;
  if (fs.existsSync(installDir)) {
    await fsp.rename(installDir, backupDir);
  }
  await fsp.rename(stagingDir, installDir);
  if (fs.existsSync(backupDir)) {
    await fsp.rm(backupDir, { recursive: true, force: true });
  }
  sendProgress(sender, { state: 'Updating', step: 'Cleaning', progress: 100, message: 'Cleanup complete' });
};

process.on('uncaughtException', (error) => {
  writeLog('FATAL', 'Uncaught exception', error?.stack || String(error));
});

process.on('unhandledRejection', (reason) => {
  writeLog('FATAL', 'Unhandled rejection', safeStringify(reason));
});

const createWindow = () => {
  writeLog('INFO', 'Creating main window');

  const win = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 1080,
    minHeight: 700,
    backgroundColor: '#0b1114',
    show: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.cjs'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  const startUrl =
    process.env.ELECTRON_START_URL ||
    `file://${path.join(__dirname, '../dist/index.html')}`;

  writeLog('INFO', 'Loading URL', startUrl);
  win.loadURL(startUrl);

  win.once('ready-to-show', () => {
    writeLog('INFO', 'Window ready');
    win.show();
  });

  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  win.webContents.on('did-fail-load', (_event, code, description, validatedURL) => {
    writeLog('ERROR', 'Load failed', `${code} ${description} ${validatedURL}`);
  });
};

ipcMain.handle('launcher:checkUpdate', async (_event, payload) => {
  try {
    const release = await getReleaseForChannel(payload.channel);
    const updateAvailable = compareSemver(payload.installedVersion || '0.0.0', release.version) < 0;
    return {
      status: 'ok',
      updateAvailable,
      latestVersion: release.version,
      release
    };
  } catch (error) {
    return { status: 'error', reason: error instanceof Error ? error.message : String(error) };
  }
});

ipcMain.handle('launcher:performUpdate', async (event, payload) => {
  const sender = event.sender;
  try {
    const release = await getReleaseForChannel(payload.channel);
    if (!release.asset) {
      return { status: 'error', reason: 'No downloadable assets on release' };
    }

    const rootDir = payload.installDir && payload.installDir.trim().length > 0 ? payload.installDir : app.getPath('userData');
    const installDir = path.join(rootDir, 'install');
    const stagingDir = path.join(rootDir, 'staging');
    const cacheDir = path.join(rootDir, 'cache');
    const configDir = path.join(rootDir, 'config');

    await ensureDir(cacheDir);
    await ensureDir(configDir);
    await fsp.rm(stagingDir, { recursive: true, force: true });

    const archivePath = path.join(cacheDir, release.asset.name);

    sendProgress(sender, { state: 'Updating', step: 'Downloading', progress: 0, message: 'Contacting GitHub' });
    await downloadAsset(release.asset, archivePath, sender);
    await extractPayload(archivePath, stagingDir, sender);
    await swapInstall(installDir, stagingDir, sender);

    const installedRecord = {
      version: release.version,
      channel: payload.channel,
      installedAt: new Date().toISOString(),
      path: rootDir,
      asset: release.asset.name
    };
    await fsp.writeFile(path.join(configDir, 'installed.json'), JSON.stringify(installedRecord, null, 2), 'utf-8');

    writeLog('INFO', 'Update completed', release.version);
    return { status: 'ok', version: release.version, installDir: rootDir };
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);
    writeLog('ERROR', 'Update failed', reason);
    return { status: 'error', reason };
  }
});

ipcMain.handle('launcher:openPath', async (_event, targetPath) => {
  if (!targetPath) return;
  await shell.openPath(targetPath);
});

ipcMain.handle('launcher:openLogs', async () => {
  await ensureDir(logDir);
  await shell.openPath(logDir);
});

app.whenReady().then(() => {
  writeLog('INFO', 'App ready');
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('render-process-gone', (_event, _webContents, details) => {
  writeLog('ERROR', 'Renderer process gone', safeStringify(details));
});

app.on('child-process-gone', (_event, details) => {
  writeLog('ERROR', 'Child process gone', safeStringify(details));
});
