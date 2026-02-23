const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const multer = require('multer');
const os = require('os');
const { spawn } = require('child_process');
const nodemailer = require('nodemailer');

const ROOT = __dirname;
const INSTALL_ROOT = path.resolve(ROOT, '..', '..');
const DATA_DIR = process.env.P1LOT_DATA_DIR || path.join(ROOT, 'data');
const USER_FILES_ROOT = path.join(DATA_DIR, 'user_files');
const PROFILE_PICS_ROOT = path.join(DATA_DIR, 'profile_pictures');
const CONFIG_PATH = path.join(DATA_DIR, 'server.config.json');
const USERS_PATH = path.join(DATA_DIR, 'users.json');
const SESSIONS_PATH = path.join(DATA_DIR, 'sessions.json');
const LOG_PATH = path.join(DATA_DIR, 'server.log');
const UPDATE_STATUS_PATH = path.join(DATA_DIR, 'update_status.json');
const EMAIL_OUTBOX_PATH = path.join(DATA_DIR, 'email_outbox.log');
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
const UPDATE_SCRIPT_PATH = path.join(INSTALL_ROOT, 'server_manager', 'update_from_host.ps1');

const ensureDir = (dirPath) => fs.mkdirSync(dirPath, { recursive: true });
ensureDir(DATA_DIR);
ensureDir(USER_FILES_ROOT);
ensureDir(PROFILE_PICS_ROOT);

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
  requireEmailVerification: true,
  verificationTokenTtlHours: 24,
  authSessionTtlHours: 72,
  publicBaseUrl: process.env.P1LOT_PUBLIC_BASE_URL || 'http://127.0.0.1:4280',
  smtpHost: process.env.P1LOT_SMTP_HOST || '',
  smtpPort: Number(process.env.P1LOT_SMTP_PORT || 587),
  smtpSecure: String(process.env.P1LOT_SMTP_SECURE || 'false').toLowerCase() === 'true',
  smtpUser: process.env.P1LOT_SMTP_USER || '',
  smtpPass: process.env.P1LOT_SMTP_PASS || '',
  smtpFrom: process.env.P1LOT_SMTP_FROM || 'noreply@cydonianheavyindustries.inc',
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

const defaultUpdateStatus = {
  state: 'idle',
  message: 'No update has run yet.',
  timestamp: nowIso()
};

const readUpdateStatus = () => readJson(UPDATE_STATUS_PATH, defaultUpdateStatus);
const writeUpdateStatus = (state, message) => {
  writeJson(UPDATE_STATUS_PATH, { state, message, timestamp: nowIso() });
};

let config = { ...defaultConfig, ...readJson(CONFIG_PATH, {}) };
if (!config.webPort || Number.isNaN(Number(config.webPort))) {
  config.webPort = defaultConfig.webPort;
}
writeJson(CONFIG_PATH, config);

let users = readJson(USERS_PATH, []);
if (!Array.isArray(users)) users = [];
let sessions = readJson(SESSIONS_PATH, []);
if (!Array.isArray(sessions)) sessions = [];
if (users.length === 0) {
  users.push({
    id: 'admin',
    username: 'admin',
    email: 'admin@cydonianheavyindustries.inc',
    isAdmin: true,
    enabled: true,
    status: 'Owner account',
    bio: '',
    emailVerified: true,
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

const sha256 = (value) => crypto.createHash('sha256').update(String(value)).digest('hex');
const normalizeEmail = (value) => String(value || '').trim().toLowerCase();
const usernameValid = (value) => /^[a-zA-Z0-9_.-]{3,32}$/.test(String(value || '').trim());
const PASSWORD_MIN_LENGTH = 8;
const AVATAR_MAX_MB = 5;

const hashPassword = (password) => {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(String(password), salt, 64).toString('hex');
  return `scrypt$${salt}$${hash}`;
};

const verifyPassword = (password, encoded) => {
  if (!encoded || typeof encoded !== 'string') return false;
  const [algo, salt, expectedHash] = encoded.split('$');
  if (algo !== 'scrypt' || !salt || !expectedHash) return false;
  const hash = crypto.scryptSync(String(password), salt, 64).toString('hex');
  const left = Buffer.from(hash, 'hex');
  const right = Buffer.from(expectedHash, 'hex');
  if (left.length !== right.length) return false;
  return crypto.timingSafeEqual(left, right);
};

const addHoursIso = (hours) => new Date(Date.now() + Math.max(1, Number(hours || 1)) * 3600000).toISOString();
const isExpiredIso = (iso) => !iso || Number.isNaN(Date.parse(iso)) || Date.now() > Date.parse(iso);

const makeVerificationToken = () => {
  const raw = crypto.randomBytes(32).toString('hex');
  return { raw, hash: sha256(raw) };
};

const makeSessionToken = () => {
  const raw = crypto.randomBytes(48).toString('hex');
  return { raw, hash: sha256(raw) };
};

const saveUsers = () => writeJson(USERS_PATH, users);
const saveSessions = () => writeJson(SESSIONS_PATH, sessions);

const pruneSessions = () => {
  sessions = sessions.filter((session) => !isExpiredIso(session.expiresAt));
  saveSessions();
};

const sanitizeAuthUser = (user) => ({
  id: user.id,
  username: user.username,
  email: user.email,
  emailVerified: !!user.emailVerified,
  isAdmin: !!user.isAdmin,
  status: user.status || '',
  bio: user.bio || '',
  discord: user.discord || '',
  avatarUrl: user.avatarFile ? `/api/user/profile-picture/${encodeURIComponent(user.id)}?v=${encodeURIComponent(user.avatarUpdatedAt || '')}` : null
});

const sanitizeAdminUser = (user) => ({
  id: user.id,
  username: user.username,
  email: user.email,
  emailVerified: !!user.emailVerified,
  isAdmin: !!user.isAdmin,
  enabled: !!user.enabled,
  status: user.status || '',
  bio: user.bio || '',
  discord: user.discord || '',
  avatarUrl: user.avatarFile ? `/api/user/profile-picture/${encodeURIComponent(user.id)}?v=${encodeURIComponent(user.avatarUpdatedAt || '')}` : null,
  createdAt: user.createdAt || '',
  updatedAt: user.updatedAt || ''
});

const sendVerificationEmail = async (user, rawToken) => {
  const verifyUrl = `${String(config.publicBaseUrl || 'http://127.0.0.1:4280').replace(/\/+$/, '')}/api/auth/verify-email?token=${encodeURIComponent(rawToken)}`;
  const subject = 'Verify your Project P1L0T account';
  const text = [
    `Hello ${user.username},`,
    '',
    'Please verify your account by opening this link:',
    verifyUrl,
    '',
    'If you did not create this account, you can ignore this email.'
  ].join('\n');

  if (config.smtpHost && config.smtpFrom) {
    try {
      const transporter = nodemailer.createTransport({
        host: String(config.smtpHost),
        port: Number(config.smtpPort || 587),
        secure: Boolean(config.smtpSecure),
        auth: config.smtpUser ? { user: String(config.smtpUser), pass: String(config.smtpPass || '') } : undefined
      });
      await transporter.sendMail({
        from: String(config.smtpFrom),
        to: user.email,
        subject,
        text
      });
      log('INFO', 'Verification email sent', user.email);
      return { sent: true, mode: 'smtp' };
    } catch (error) {
      log('ERROR', 'Verification email send failed', `${user.email} ${error.message}`);
      return { sent: false, mode: 'smtp_error', error: error.message, verifyUrl };
    }
  }

  const outboxLine = `[${nowIso()}] to=${user.email} subject="${subject}" link=${verifyUrl}\n`;
  fs.appendFileSync(EMAIL_OUTBOX_PATH, outboxLine, 'utf-8');
  log('INFO', 'Verification email written to outbox', user.email);
  return { sent: true, mode: 'outbox', verifyUrl };
};

const app = express();
app.use(express.json({ limit: '10mb' }));

const extractAdminToken = (req) => {
  const headerToken = req.header('x-admin-token') || req.header('authorization')?.replace(/^Bearer\s+/i, '');
  if (headerToken) return String(headerToken).trim();
  const queryToken = req.query?.token;
  if (queryToken) return String(queryToken).trim();
  return '';
};

const authAdmin = (req, res, next) => {
  const token = extractAdminToken(req);
  if (!token || token !== config.adminToken) {
    res.status(401).json({ error: 'unauthorized' });
    return;
  }
  next();
};

const authUser = (req, res, next) => {
  pruneSessions();
  const bearer = req.header('authorization')?.replace(/^Bearer\s+/i, '').trim();
  if (!bearer) {
    res.status(401).json({ error: 'unauthorized' });
    return;
  }
  const hashed = sha256(bearer);
  const session = sessions.find((s) => s.tokenHash === hashed && !isExpiredIso(s.expiresAt));
  if (!session) {
    res.status(401).json({ error: 'invalid_session' });
    return;
  }
  const user = users.find((u) => u.id === session.userId);
  if (!user || user.enabled === false) {
    res.status(401).json({ error: 'user_unavailable' });
    return;
  }
  req.auth = { tokenHash: hashed, session, user };
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

const avatarStorage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, PROFILE_PICS_ROOT),
  filename: (req, file, cb) => {
    const userId = safeName(req.auth?.user?.id || 'user');
    const extMap = {
      'image/png': '.png',
      'image/jpeg': '.jpg',
      'image/webp': '.webp'
    };
    const ext = extMap[file.mimetype] || path.extname(file.originalname || '').toLowerCase() || '.img';
    cb(null, `${userId}${ext}`);
  }
});

const avatarUpload = multer({
  storage: avatarStorage,
  fileFilter: (_req, file, cb) => {
    const allowed = ['image/png', 'image/jpeg', 'image/webp'];
    if (!allowed.includes(file.mimetype)) {
      cb(new Error('unsupported_avatar_type'));
      return;
    }
    cb(null, true);
  },
  limits: {
    fileSize: AVATAR_MAX_MB * 1024 * 1024
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

app.get('/api/public/auth-config', (_req, res) => {
  res.json({
    allowSignup: Boolean(config.allowSignup),
    requireEmailVerification: Boolean(config.requireEmailVerification),
    passwordMinLength: PASSWORD_MIN_LENGTH
  });
});

app.post('/api/auth/signup', async (req, res) => {
  if (!config.allowSignup) {
    res.status(403).json({ error: 'signup_disabled' });
    return;
  }
  const username = String(req.body?.username || '').trim();
  const email = normalizeEmail(req.body?.email);
  const password = String(req.body?.password || '');
  if (!usernameValid(username) || !email.includes('@') || password.length < PASSWORD_MIN_LENGTH) {
    res.status(400).json({ error: 'invalid_payload', minPasswordLength: PASSWORD_MIN_LENGTH });
    return;
  }
  if (users.some((u) => String(u.username || '').toLowerCase() === username.toLowerCase() || normalizeEmail(u.email) === email)) {
    res.status(409).json({ error: 'duplicate_user' });
    return;
  }

  const verify = makeVerificationToken();
  const user = {
    id: safeId(),
    username,
    email,
    passwordHash: hashPassword(password),
    emailVerified: false,
    emailVerificationTokenHash: verify.hash,
    emailVerificationExpiresAt: addHoursIso(clamp(config.verificationTokenTtlHours, 1, 168, 24)),
    isAdmin: false,
    enabled: true,
    status: '',
    bio: '',
    discord: '',
    createdAt: nowIso(),
    updatedAt: nowIso()
  };
  users.push(user);
  saveUsers();

  const delivery = await sendVerificationEmail(user, verify.raw);
  res.json({
    ok: true,
    requiresVerification: Boolean(config.requireEmailVerification),
    user: sanitizeAuthUser(user),
    emailDelivery: delivery.mode,
    verifyUrlPreview: delivery.mode === 'outbox' ? delivery.verifyUrl : undefined
  });
});

app.post('/api/auth/resend-verification', async (req, res) => {
  const email = normalizeEmail(req.body?.email);
  const user = users.find((u) => normalizeEmail(u.email) === email);
  if (!user) {
    res.json({ ok: true });
    return;
  }
  if (user.emailVerified) {
    res.json({ ok: true, alreadyVerified: true });
    return;
  }
  const verify = makeVerificationToken();
  user.emailVerificationTokenHash = verify.hash;
  user.emailVerificationExpiresAt = addHoursIso(clamp(config.verificationTokenTtlHours, 1, 168, 24));
  user.updatedAt = nowIso();
  saveUsers();
  const delivery = await sendVerificationEmail(user, verify.raw);
  res.json({ ok: true, emailDelivery: delivery.mode, verifyUrlPreview: delivery.mode === 'outbox' ? delivery.verifyUrl : undefined });
});

app.get('/api/auth/verify-email', (req, res) => {
  const token = String(req.query?.token || '').trim();
  if (!token) {
    res.status(400).json({ error: 'missing_token' });
    return;
  }
  const tokenHash = sha256(token);
  const user = users.find((u) => u.emailVerificationTokenHash === tokenHash);
  if (!user) {
    res.status(400).json({ error: 'invalid_token' });
    return;
  }
  if (isExpiredIso(user.emailVerificationExpiresAt)) {
    res.status(400).json({ error: 'token_expired' });
    return;
  }
  user.emailVerified = true;
  delete user.emailVerificationTokenHash;
  delete user.emailVerificationExpiresAt;
  user.updatedAt = nowIso();
  saveUsers();
  log('INFO', 'Email verified', user.id);
  res.send('<html><body style="font-family:Segoe UI;background:#0a0f1a;color:#d8f7ff;padding:24px"><h2>Project P1L0T</h2><p>Email verified successfully. You can return to the launcher.</p></body></html>');
});

app.post('/api/auth/login', (req, res) => {
  const login = String(req.body?.login || req.body?.username || req.body?.email || '').trim();
  const password = String(req.body?.password || '');
  if (!login || !password) {
    res.status(400).json({ error: 'missing_credentials' });
    return;
  }
  const normalizedLogin = login.toLowerCase();
  const user = users.find((u) => String(u.username || '').toLowerCase() === normalizedLogin || normalizeEmail(u.email) === normalizedLogin);
  if (!user || !user.passwordHash || !verifyPassword(password, user.passwordHash)) {
    res.status(401).json({ error: 'invalid_credentials' });
    return;
  }
  if (user.enabled === false) {
    res.status(403).json({ error: 'user_disabled' });
    return;
  }
  if (config.requireEmailVerification && !user.emailVerified) {
    res.status(403).json({ error: 'email_not_verified' });
    return;
  }
  pruneSessions();
  const token = makeSessionToken();
  sessions.push({
    id: safeId(),
    userId: user.id,
    tokenHash: token.hash,
    createdAt: nowIso(),
    expiresAt: addHoursIso(clamp(config.authSessionTtlHours, 1, 720, 72))
  });
  saveSessions();
  res.json({ ok: true, token: token.raw, user: sanitizeAuthUser(user) });
});

app.get('/api/auth/me', authUser, (req, res) => {
  res.json({ ok: true, user: sanitizeAuthUser(req.auth.user) });
});

app.post('/api/auth/logout', authUser, (req, res) => {
  sessions = sessions.filter((s) => s.tokenHash !== req.auth.tokenHash);
  saveSessions();
  res.json({ ok: true });
});

app.get('/api/user/profile', authUser, (req, res) => {
  res.json({ ok: true, user: sanitizeAuthUser(req.auth.user) });
});

app.patch('/api/user/profile', authUser, (req, res) => {
  const user = req.auth.user;
  const payload = req.body || {};

  if (payload.username !== undefined) {
    const nextUsername = String(payload.username || '').trim();
    if (!usernameValid(nextUsername)) {
      res.status(400).json({ error: 'invalid_username' });
      return;
    }
    const duplicate = users.some((u) => u.id !== user.id && String(u.username || '').toLowerCase() === nextUsername.toLowerCase());
    if (duplicate) {
      res.status(409).json({ error: 'username_taken' });
      return;
    }
    user.username = nextUsername;
  }

  if (payload.status !== undefined) {
    user.status = String(payload.status || '').slice(0, 140);
  }
  if (payload.bio !== undefined) {
    user.bio = String(payload.bio || '').slice(0, 1000);
  }
  if (payload.discord !== undefined) {
    user.discord = String(payload.discord || '').slice(0, 64);
  }

  if (payload.newPassword !== undefined) {
    const currentPassword = String(payload.currentPassword || '');
    const newPassword = String(payload.newPassword || '');
    if (!verifyPassword(currentPassword, user.passwordHash)) {
      res.status(401).json({ error: 'invalid_current_password' });
      return;
    }
    if (newPassword.length < PASSWORD_MIN_LENGTH) {
      res.status(400).json({ error: 'password_too_short', minPasswordLength: PASSWORD_MIN_LENGTH });
      return;
    }
    user.passwordHash = hashPassword(newPassword);
    sessions = sessions.filter((s) => s.userId !== user.id || s.tokenHash === req.auth.tokenHash);
    saveSessions();
  }

  user.updatedAt = nowIso();
  saveUsers();
  res.json({ ok: true, user: sanitizeAuthUser(user) });
});

app.post('/api/user/profile-picture', authUser, (req, res) => {
  avatarUpload.single('avatar')(req, res, (err) => {
    if (err) {
      const detail = err.message === 'unsupported_avatar_type'
        ? 'Only png, jpg, jpeg, webp are allowed.'
        : err.message === 'File too large'
          ? `Max avatar size is ${AVATAR_MAX_MB} MB.`
          : err.message;
      res.status(400).json({ error: 'avatar_upload_failed', detail });
      return;
    }
    if (!req.file) {
      res.status(400).json({ error: 'avatar_missing' });
      return;
    }

    const user = req.auth.user;
    const prefix = `${safeName(user.id)}.`;
    const allFiles = fs.readdirSync(PROFILE_PICS_ROOT).filter((name) => name.startsWith(prefix));
    for (const fileName of allFiles) {
      if (fileName !== req.file.filename) {
        try { fs.unlinkSync(path.join(PROFILE_PICS_ROOT, fileName)); } catch {}
      }
    }

    user.avatarFile = req.file.filename;
    user.avatarUpdatedAt = nowIso();
    user.updatedAt = nowIso();
    saveUsers();
    res.json({ ok: true, user: sanitizeAuthUser(user) });
  });
});

app.delete('/api/user/profile-picture', authUser, (req, res) => {
  const user = req.auth.user;
  if (user.avatarFile) {
    const target = path.join(PROFILE_PICS_ROOT, user.avatarFile);
    if (fs.existsSync(target)) {
      try { fs.unlinkSync(target); } catch {}
    }
  }
  delete user.avatarFile;
  delete user.avatarUpdatedAt;
  user.updatedAt = nowIso();
  saveUsers();
  res.json({ ok: true, user: sanitizeAuthUser(user) });
});

app.get('/api/user/profile-picture/:userId', authUser, (req, res) => {
  const userId = String(req.params.userId || '').trim();
  const user = users.find((u) => u.id === userId);
  if (!user || !user.avatarFile) {
    res.status(404).json({ error: 'avatar_not_found' });
    return;
  }
  const target = path.join(PROFILE_PICS_ROOT, user.avatarFile);
  if (!fs.existsSync(target)) {
    res.status(404).json({ error: 'avatar_not_found' });
    return;
  }
  res.sendFile(target);
});

app.get('/api/admin/settings', authAdmin, (_req, res) => {
  const { adminToken, smtpPass, ...safe } = config;
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
    hardwareProfile: pickEnum(next.hardwareProfile ?? config.hardwareProfile, ['recommended', 'max'], 'recommended'),
    requireEmailVerification: Boolean(next.requireEmailVerification ?? config.requireEmailVerification),
    verificationTokenTtlHours: clamp(next.verificationTokenTtlHours ?? config.verificationTokenTtlHours, 1, 168, 24),
    authSessionTtlHours: clamp(next.authSessionTtlHours ?? config.authSessionTtlHours, 1, 720, 72),
    publicBaseUrl: String(next.publicBaseUrl ?? config.publicBaseUrl),
    smtpHost: String(next.smtpHost ?? config.smtpHost),
    smtpPort: clamp(next.smtpPort ?? config.smtpPort, 1, 65535, 587),
    smtpSecure: Boolean(next.smtpSecure ?? config.smtpSecure),
    smtpUser: String(next.smtpUser ?? config.smtpUser),
    smtpPass: String(next.smtpPass ?? config.smtpPass),
    smtpFrom: String(next.smtpFrom ?? config.smtpFrom)
  };
  writeJson(CONFIG_PATH, config);
  log('INFO', 'Server settings updated');
  const { adminToken, smtpPass, ...safe } = config;
  res.json({ ok: true, settings: safe });
});

app.get('/api/admin/users', authAdmin, (_req, res) => {
  users = readJson(USERS_PATH, users);
  res.json({ users: users.map(sanitizeAdminUser) });
});

app.get('/api/admin/users/:userId', authAdmin, (req, res) => {
  const user = users.find((u) => u.id === req.params.userId);
  if (!user) {
    res.status(404).json({ error: 'user_not_found' });
    return;
  }
  res.json({ user: sanitizeAdminUser(user) });
});

app.post('/api/admin/users', authAdmin, (req, res) => {
  const { username, email, password } = req.body || {};
  const name = String(username || '').trim();
  const mail = normalizeEmail(email);
  if (!usernameValid(name) || !mail.includes('@')) {
    res.status(400).json({ error: 'invalid_payload' });
    return;
  }
  if (users.some((u) => String(u.username || '').toLowerCase() === name.toLowerCase() || normalizeEmail(u.email) === mail)) {
    res.status(400).json({ error: 'duplicate_user' });
    return;
  }
  const hasPassword = typeof password === 'string' && password.length >= PASSWORD_MIN_LENGTH;
  const user = {
    id: safeId(),
    username: name,
    email: mail,
    passwordHash: hasPassword ? hashPassword(password) : undefined,
    emailVerified: hasPassword ? false : true,
    isAdmin: false,
    enabled: true,
    status: '',
    bio: '',
    createdAt: nowIso(),
    updatedAt: nowIso()
  };
  users.push(user);
  saveUsers();
  log('INFO', 'User created', user.id);
  res.json({ ok: true, user: sanitizeAdminUser(user) });
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
    emailVerified: req.body?.emailVerified === undefined ? prev.emailVerified : Boolean(req.body.emailVerified),
    status: req.body?.status === undefined ? prev.status : String(req.body.status ?? ''),
    bio: req.body?.bio === undefined ? prev.bio : String(req.body.bio ?? ''),
    discord: req.body?.discord === undefined ? prev.discord : String(req.body.discord ?? ''),
    passwordHash: req.body?.newPassword === undefined
      ? prev.passwordHash
      : (typeof req.body.newPassword === 'string' && req.body.newPassword.length >= PASSWORD_MIN_LENGTH
          ? hashPassword(req.body.newPassword)
          : prev.passwordHash),
    updatedAt: nowIso()
  };
  if (req.body?.resetVerificationToken) {
    delete users[targetIndex].emailVerificationTokenHash;
    delete users[targetIndex].emailVerificationExpiresAt;
  }
  saveUsers();
  log('INFO', 'User updated', userId);
  res.json({ ok: true, user: sanitizeAdminUser(users[targetIndex]) });
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

app.get('/api/admin/update/status', authAdmin, (_req, res) => {
  res.json({ status: readUpdateStatus() });
});

app.post('/api/admin/update', authAdmin, (_req, res) => {
  const status = readUpdateStatus();
  if (status.state === 'running') {
    res.json({ ok: true, started: false, status });
    return;
  }

  if (!fs.existsSync(UPDATE_SCRIPT_PATH)) {
    res.status(500).json({ error: 'update_script_missing', path: UPDATE_SCRIPT_PATH });
    return;
  }

  try {
    writeUpdateStatus('running', 'Starting host branch update...');
    const args = [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      UPDATE_SCRIPT_PATH,
      '-InstallRoot',
      INSTALL_ROOT,
      '-Repo',
      'CydonianHeavyIndustries/ProjectP1L0TGame',
      '-Branch',
      'host',
      '-ServiceName',
      'ProjectP1L0TServer'
    ];
    const child = spawn('powershell.exe', args, {
      detached: true,
      stdio: 'ignore'
    });
    child.unref();
    log('INFO', 'Host update requested from admin UI');
    res.json({ ok: true, started: true, status: readUpdateStatus() });
  } catch (error) {
    writeUpdateStatus('failed', `Failed to launch update process: ${error.message}`);
    res.status(500).json({ error: 'update_launch_failed', detail: error.message });
  }
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
