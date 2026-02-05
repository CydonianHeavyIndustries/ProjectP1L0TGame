const { app, BrowserWindow, shell, ipcMain } = require('electron');
const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const { Readable } = require('stream');
const { pipeline } = require('stream/promises');
const { spawn } = require('child_process');
const extract = require('extract-zip');

const REPO = 'CydonianHeavyIndustries/ProjectP1L0TGame';
const API_BASE = `https://api.github.com/repos/${REPO}`;
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
const isSemver = (value) => /^\d+\.\d+\.\d+$/.test(normalizeVersion(value || ''));
const isTimestampVersion = (value) => /^\d{4}\.\d{2}\.\d{2}\.\d{4}$/.test(normalizeVersion(value || ''));

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

const shouldUpdateWithDates = (installedAt, publishedAt) => {
  if (!installedAt || !publishedAt) return false;
  const installedTime = Date.parse(installedAt);
  const releaseTime = Date.parse(publishedAt);
  if (Number.isNaN(installedTime) || Number.isNaN(releaseTime)) return false;
  return releaseTime > installedTime;
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

const getReleaseForChannel = async (channel) => {
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

const swapInstall = async (installDir, payloadDir, sender) => {
  sendProgress(sender, { state: 'Updating', step: 'Cleaning', progress: 96, message: 'Swapping build' });
  const backupDir = `${installDir}_old_${Date.now()}`;
  if (fs.existsSync(installDir)) {
    await fsp.rename(installDir, backupDir);
  }
  await fsp.rename(payloadDir, installDir);
  if (fs.existsSync(backupDir)) {
    await fsp.rm(backupDir, { recursive: true, force: true });
  }
  sendProgress(sender, { state: 'Updating', step: 'Cleaning', progress: 100, message: 'Cleanup complete' });
};

const parseArgs = (value) => {
  if (!value) return [];
  const args = [];
  let current = '';
  let quoted = false;
  for (let i = 0; i < value.length; i += 1) {
    const char = value[i];
    if (char === '"') {
      quoted = !quoted;
      continue;
    }
    if (char === ' ' && !quoted) {
      if (current.length > 0) {
        args.push(current);
        current = '';
      }
      continue;
    }
    current += char;
  }
  if (current.length > 0) {
    args.push(current);
  }
  return args;
};

const resolveExecutable = (installRoot, relativePath) => {
  const installDir = path.join(installRoot, 'install');
  const normalized = relativePath.replace(/^[\\/]+/, '');
  return path.join(installDir, normalized);
};

const resolveExecutableInDir = (baseDir, relativePath) => {
  const normalized = relativePath.replace(/^[\\/]+/, '');
  return path.join(baseDir, normalized);
};

const findPayloadRoot = async (stagingDir, relativePath) => {
  const direct = resolveExecutableInDir(stagingDir, relativePath);
  if (fs.existsSync(direct)) {
    return stagingDir;
  }
  const entries = await fsp.readdir(stagingDir, { withFileTypes: true });
  const dirs = entries.filter((entry) => entry.isDirectory());
  if (dirs.length === 1) {
    const candidate = path.join(stagingDir, dirs[0].name);
    const candidateExe = resolveExecutableInDir(candidate, relativePath);
    if (fs.existsSync(candidateExe)) {
      return candidate;
    }
  }
  return null;
};

const launchGame = (payload) => {
  const rootDir = payload.installDir && payload.installDir.trim().length > 0 ? payload.installDir : app.getPath('userData');
  const exePath = resolveExecutable(rootDir, payload.gameExeRelative || '');
  if (!payload.gameExeRelative || payload.gameExeRelative.trim().length === 0) {
    throw new Error('Game executable path is not configured');
  }
  if (!fs.existsSync(exePath)) {
    throw new Error(`Game executable not found: ${exePath}`);
  }

  const args = [];
  args.push(...parseArgs(payload.launchArgs || ''));
  if (payload.safeMode) {
    args.push('-safemode');
  }
  args.push(`-ENV=${payload.channel}`);
  if (payload.buildVersion) {
    args.push(`-BUILD_VERSION=${payload.buildVersion}`);
  }
  args.push('-LAUNCHER=CHII');

  writeLog('INFO', 'Launching game', `${exePath} ${args.join(' ')}`);

  const child = spawn(exePath, args, {
    cwd: path.dirname(exePath),
    detached: true,
    stdio: 'ignore'
  });
  child.unref();
};

const resolveRepoRoot = () => {
  if (process.env.P1LOT_REPO_ROOT) {
    return process.env.P1LOT_REPO_ROOT;
  }
  const appPath = app.getAppPath();
  return path.resolve(appPath, '..');
};

const runPackagingScript = (payload) => {
  const repoRoot = resolveRepoRoot();
  const godotPs1Path = path.join(repoRoot, 'tools', 'package_godot_build.ps1');
  const godotBatPath = path.join(repoRoot, 'tools', 'package_godot_build.bat');
  const uePs1Path = path.join(repoRoot, 'tools', 'package_dev_build.ps1');
  const ueBatPath = path.join(repoRoot, 'package_dev_build.bat');
  const hasGodotPs1 = fs.existsSync(godotPs1Path);
  const hasGodotBat = fs.existsSync(godotBatPath);
  const hasUePs1 = fs.existsSync(uePs1Path);
  const hasUeBat = fs.existsSync(ueBatPath);
  if (!hasGodotPs1 && !hasGodotBat && !hasUePs1 && !hasUeBat) {
    throw new Error(`Packaging script not found: ${godotPs1Path}, ${godotBatPath}, ${uePs1Path}, or ${ueBatPath}`);
  }

  const args = [];
  if (payload.installDir) {
    args.push('-InstallRoot', payload.installDir);
  }
  if (payload.configuration) {
    args.push('-Configuration', payload.configuration);
  }
  if (payload.zip) {
    args.push('-Zip');
  }

  return new Promise((resolve, reject) => {
    writeLog('INFO', 'Packaging started', hasPs1 ? ps1Path : batPath);

    let command = '';
    let commandArgs = [];
    if (hasGodotPs1) {
      command = 'powershell.exe';
      commandArgs = ['-ExecutionPolicy', 'Bypass', '-File', godotPs1Path, ...args];
    } else if (hasGodotBat) {
      command = godotBatPath;
      commandArgs = [...args];
    } else if (hasUePs1) {
      command = 'powershell.exe';
      commandArgs = ['-ExecutionPolicy', 'Bypass', '-File', uePs1Path, ...args];
    } else {
      command = ueBatPath;
      commandArgs = [...args];
    }

    writeLog('INFO', 'Packager', `${command} ${commandArgs.join(' ')}`.trim());
    const child = spawn(command, commandArgs, { cwd: repoRoot });

    child.stdout.on('data', (data) => {
      writeLog('INFO', 'Packager', data.toString().trim());
    });
    child.stderr.on('data', (data) => {
      writeLog('WARN', 'Packager', data.toString().trim());
    });
    child.on('error', (error) => reject(error));
    child.on('close', (code) => {
      if (code === 0) {
        writeLog('INFO', 'Packaging completed');
        resolve();
      } else {
        reject(new Error(`Packaging failed (exit ${code})`));
      }
    });
  });
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
    const installedVersion = payload.installedVersion || '0.0.0';
    const compare = compareSemver(installedVersion, release.version);
    let updateAvailable = compare < 0;
    if (!updateAvailable && compare > 0) {
      const semverMismatch = isSemver(release.version) && isTimestampVersion(installedVersion);
      if (semverMismatch || !isSemver(installedVersion)) {
        updateAvailable = shouldUpdateWithDates(payload.installedAt, release.publishedAt);
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

    const exeRelative = payload.gameExeRelative || '';
    if (!exeRelative) {
      throw new Error('Game executable path is not configured');
    }
    const payloadRoot = await findPayloadRoot(stagingDir, exeRelative);
    if (!payloadRoot) {
      await fsp.rm(stagingDir, { recursive: true, force: true });
      throw new Error(`Payload missing game executable (${exeRelative})`);
    }

    await swapInstall(installDir, payloadRoot, sender);
    if (payloadRoot !== stagingDir && fs.existsSync(stagingDir)) {
      await fsp.rm(stagingDir, { recursive: true, force: true });
    }

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

ipcMain.handle('launcher:launchGame', async (_event, payload) => {
  try {
    launchGame(payload);
    return { status: 'ok' };
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);
    writeLog('ERROR', 'Launch failed', reason);
    return { status: 'error', reason };
  }
});

ipcMain.handle('launcher:packageBuild', async (_event, payload) => {
  try {
    await runPackagingScript(payload || {});
    return { status: 'ok' };
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);
    writeLog('ERROR', 'Packaging failed', reason);
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
