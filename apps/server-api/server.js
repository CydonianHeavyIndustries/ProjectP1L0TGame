const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const multer = require('multer');
const os = require('os');

const ROOT = __dirname;
const DATA_DIR = process.env.P1LOT_DATA_DIR || path.join(ROOT, 'data');
const USER_FILES_ROOT = path.join(DATA_DIR, 'user_files');
const CONFIG_PATH = path.join(DATA_DIR, 'server.config.json');
const USERS_PATH = path.join(DATA_DIR, 'users.json');
const LOG_PATH = path.join(DATA_DIR, 'server.log');
const ADMIN_STATIC = path.join(ROOT, 'public', 'admin');
const SITE_STATIC = path.join(ROOT, 'public', 'site');
const WEBSITE_SOURCE_CANDIDATES = [
  path.resolve(ROOT, '..', '..', 'website', 'cydonianheavyindustries.inc'),
  path.resolve(ROOT, '..', '..', 'website', 'dist'),
  path.resolve(ROOT, '..', '..', 'website')
];

const resolveFirstExistingDir = (candidates, fallback) => {
  for (const candidate of candidates) {
    if (candidate && fs.existsSync(candidate) && fs.statSync(candidate).isDirectory()) {
      return candidate;
    }
  }
  return fallback;
};

const WEBSITE_SOURCE = resolveFirstExistingDir(WEBSITE_SOURCE_CANDIDATES, SITE_STATIC);

const ensureDir = (dirPath) => fs.mkdirSync(dirPath, { recursive: true });
ensureDir(DATA_DIR);
ensureDir(USER_FILES_ROOT);

const nowIso = () => new Date().toISOString();
const safeId = () => crypto.randomBytes(8).toString('hex');
const safeName = (value) => String(value || '').replace(/[^a-zA-Z0-9._-]/g, '_');
const clamp = (value, min, max, fallback) => {
  const num = Number(value);
  if (Number.isNaN(num)) return fallback;
  return Math.max(min, Math.min(max, num));
};
const pickEnum = (value, accepted, fallback) => {
  const normalized = String(value || '').trim().toLowerCase();
  return accepted.includes(normalized) ? normalized : fallback;
};

const defaultConfig = {
  serverName: 'Project P1L0T Host',
  websiteTitle: 'Cydonian Heavy Industries',
  motd: 'Welcome to Project P1L0T infrastructure.',
  allowSignup: true,
  maintenanceMode: false,
  maxUploadMb: 64,
  maxPlayers: 64,
  tickRate: 60,
  autosaveSeconds: 30,
  hardwareProfile: 'recommended',
  telemetryEnabled: true,
  adminToken: process.env.P1LOT_ADMIN_TOKEN || 'change-me-now',
  webPort: Number(process.env.P1LOT_SERVER_PORT || 4280)
};

const readJson = (filePath, fallback) => {
  try {
    if (!fs.existsSync(filePath)) return fallback;
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch {
    return fallback;
  }
};

const writeJson = (filePath, value) => {
  const temp = `${filePath}.tmp`;
  fs.writeFileSync(temp, JSON.stringify(value, null, 2), 'utf-8');
  fs.renameSync(temp, filePath);
};

let config = { ...defaultConfig, ...readJson(CONFIG_PATH, {}) };
if (!config.webPort || Number.isNaN(Number(config.webPort))) {
  config.webPort = defaultConfig.webPort;
}
writeJson(CONFIG_PATH, config);

let users = readJson(USERS_PATH, []);
if (!Array.isArray(users)) users = [];
if (users.length === 0) {
  users.push({
    id: 'admin',
    username: 'admin',
    email: 'admin@cydonianheavyindustries.inc',
    isAdmin: true,
    enabled: true,
    status: 'Owner account',
    bio: '',
    createdAt: nowIso(),
    updatedAt: nowIso()
  });
  writeJson(USERS_PATH, users);
}

const log = (level, message, meta = '') => {
  const line = `[${nowIso()}] [${level}] ${message}${meta ? ` | ${meta}` : ''}\n`;
  fs.appendFileSync(LOG_PATH, line, 'utf-8');
  process.stdout.write(line);
};

const app = express();
app.use(express.json({ limit: '10mb' }));

const authAdmin = (req, res, next) => {
  const headerToken = req.header('x-admin-token') || req.header('authorization')?.replace(/^Bearer\s+/i, '');
  if (!headerToken || headerToken !== config.adminToken) {
    res.status(401).json({ error: 'unauthorized' });
    return;
  }
  next();
};

const storage = multer.diskStorage({
  destination: (req, _file, cb) => {
    const userId = safeName(req.params.userId);
    const target = path.join(USER_FILES_ROOT, userId);
    ensureDir(target);
    cb(null, target);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    const base = path.basename(file.originalname || 'file', ext);
    cb(null, `${safeName(base)}_${Date.now()}${safeName(ext)}`);
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: Math.max(1, Number(config.maxUploadMb || 64)) * 1024 * 1024
  }
});

app.get('/api/health', (_req, res) => {
  res.json({
    ok: true,
    serverName: config.serverName,
    hardwareProfile: config.hardwareProfile,
    maxPlayers: config.maxPlayers,
    tickRate: config.tickRate,
    cpuCount: os.cpus().length,
    uptimeSec: Math.floor(process.uptime()),
    now: nowIso()
  });
});

app.get('/api/public/config', (_req, res) => {
  res.json({
    serverName: config.serverName,
    websiteTitle: config.websiteTitle,
    motd: config.motd,
    maintenanceMode: Boolean(config.maintenanceMode),
    allowSignup: Boolean(config.allowSignup),
    maxPlayers: Number(config.maxPlayers),
    tickRate: Number(config.tickRate)
  });
});

app.get('/api/admin/settings', authAdmin, (_req, res) => {
  const { adminToken, ...safe } = config;
  res.json({ settings: safe });
});

app.put('/api/admin/settings', authAdmin, (req, res) => {
  const next = req.body || {};
  config = {
    ...config,
    serverName: String(next.serverName ?? config.serverName),
    websiteTitle: String(next.websiteTitle ?? config.websiteTitle),
    motd: String(next.motd ?? config.motd),
    allowSignup: Boolean(next.allowSignup ?? config.allowSignup),
    maintenanceMode: Boolean(next.maintenanceMode ?? config.maintenanceMode),
    maxUploadMb: clamp(next.maxUploadMb ?? config.maxUploadMb, 1, 2048, 64),
    maxPlayers: clamp(next.maxPlayers ?? config.maxPlayers, 1, 512, 64),
    tickRate: clamp(next.tickRate ?? config.tickRate, 10, 240, 60),
    autosaveSeconds: clamp(next.autosaveSeconds ?? config.autosaveSeconds, 5, 600, 30),
    telemetryEnabled: Boolean(next.telemetryEnabled ?? config.telemetryEnabled),
    hardwareProfile: pickEnum(next.hardwareProfile ?? config.hardwareProfile, ['recommended', 'max'], 'recommended')
  };
  writeJson(CONFIG_PATH, config);
  log('INFO', 'Server settings updated');
  const { adminToken, ...safe } = config;
  res.json({ ok: true, settings: safe });
});

app.get('/api/admin/users', authAdmin, (_req, res) => {
  users = readJson(USERS_PATH, users);
  res.json({ users });
});

app.get('/api/admin/users/:userId', authAdmin, (req, res) => {
  const user = users.find((u) => u.id === req.params.userId);
  if (!user) {
    res.status(404).json({ error: 'user_not_found' });
    return;
  }
  res.json({ user });
});

app.post('/api/admin/users', authAdmin, (req, res) => {
  const { username, email } = req.body || {};
  const name = String(username || '').trim();
  const mail = String(email || '').trim();
  if (name.length < 3 || !mail.includes('@')) {
    res.status(400).json({ error: 'invalid_payload' });
    return;
  }
  if (users.some((u) => u.username.toLowerCase() === name.toLowerCase() || u.email.toLowerCase() === mail.toLowerCase())) {
    res.status(400).json({ error: 'duplicate_user' });
    return;
  }
  const user = {
    id: safeId(),
    username: name,
    email: mail,
    isAdmin: false,
    enabled: true,
    status: '',
    bio: '',
    createdAt: nowIso(),
    updatedAt: nowIso()
  };
  users.push(user);
  writeJson(USERS_PATH, users);
  log('INFO', 'User created', user.id);
  res.json({ ok: true, user });
});

app.patch('/api/admin/users/:userId', authAdmin, (req, res) => {
  const userId = req.params.userId;
  const targetIndex = users.findIndex((u) => u.id === userId);
  if (targetIndex < 0) {
    res.status(404).json({ error: 'user_not_found' });
    return;
  }
  const prev = users[targetIndex];
  users[targetIndex] = {
    ...prev,
    isAdmin: req.body?.isAdmin === undefined ? prev.isAdmin : Boolean(req.body.isAdmin),
    enabled: req.body?.enabled === undefined ? prev.enabled : Boolean(req.body.enabled),
    status: req.body?.status === undefined ? prev.status : String(req.body.status ?? ''),
    bio: req.body?.bio === undefined ? prev.bio : String(req.body.bio ?? ''),
    discord: req.body?.discord === undefined ? prev.discord : String(req.body.discord ?? ''),
    updatedAt: nowIso()
  };
  writeJson(USERS_PATH, users);
  log('INFO', 'User updated', userId);
  res.json({ ok: true, user: users[targetIndex] });
});

app.get('/api/admin/users/:userId/files', authAdmin, (req, res) => {
  const userId = safeName(req.params.userId);
  const dirPath = path.join(USER_FILES_ROOT, userId);
  ensureDir(dirPath);
  const files = fs.readdirSync(dirPath).map((name) => {
    const full = path.join(dirPath, name);
    const stat = fs.statSync(full);
    return { name, size: stat.size, modifiedAt: stat.mtime.toISOString() };
  });
  res.json({ files });
});

app.post('/api/admin/users/:userId/files', authAdmin, upload.array('files'), (req, res) => {
  const files = (req.files || []).map((f) => ({
    name: f.filename,
    size: f.size
  }));
  log('INFO', 'User files uploaded', `${req.params.userId} count=${files.length}`);
  res.json({ ok: true, files });
});

app.delete('/api/admin/users/:userId/files/:fileName', authAdmin, (req, res) => {
  const userId = safeName(req.params.userId);
  const fileName = safeName(req.params.fileName);
  const target = path.join(USER_FILES_ROOT, userId, fileName);
  if (!fs.existsSync(target)) {
    res.status(404).json({ error: 'file_not_found' });
    return;
  }
  fs.unlinkSync(target);
  log('INFO', 'User file deleted', `${userId}/${fileName}`);
  res.json({ ok: true });
});

app.get('/api/admin/logs', authAdmin, (_req, res) => {
  const count = 200;
  if (!fs.existsSync(LOG_PATH)) {
    res.json({ lines: [] });
    return;
  }
  const lines = fs.readFileSync(LOG_PATH, 'utf-8').split(/\r?\n/).filter(Boolean);
  res.json({ lines: lines.slice(-count) });
});

app.get('/api/admin/bootstrap', authAdmin, (_req, res) => {
  res.json({
    ok: true,
    serverName: config.serverName
  });
});

// Host CHII website and admin dashboard.
app.use('/admin/assets', express.static(path.join(ROOT, 'public', 'assets')));
app.use('/admin', express.static(ADMIN_STATIC));
app.use('/chii', express.static(WEBSITE_SOURCE));
app.use('/', express.static(WEBSITE_SOURCE));
if (WEBSITE_SOURCE !== SITE_STATIC) {
  app.use('/', express.static(SITE_STATIC));
}

app.use('/api', (_req, res) => {
  res.status(404).json({ error: 'not_found' });
});

app.listen(config.webPort, () => {
  log('INFO', `Server listening on ${config.webPort}`);
});
