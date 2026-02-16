const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const crypto = require('crypto');
const path = require('path');
const fs = require('fs');
const { DatabaseSync } = require('node:sqlite');

const ROOT = __dirname;
const DATA_DIR = process.env.P1LOT_DATA_DIR || path.join(ROOT, 'data');
const PUBLIC_DIR = path.join(ROOT, 'public');
const LOG_DIR = process.env.P1LOT_LOG_DIR || path.join(DATA_DIR, 'logs');
const DB_PATH = process.env.P1LOT_DB_PATH || path.join(DATA_DIR, 'p1lot.db');
const PORT = Number(process.env.P1LOT_SERVER_PORT || 4280);
const ALLOW_ORIGIN = process.env.P1LOT_ALLOW_ORIGIN || '*';
const ONLINE_TTL_MS = 45 * 1000;

const ensureDir = (dir) => fs.mkdirSync(dir, { recursive: true });
ensureDir(DATA_DIR);
ensureDir(LOG_DIR);

const envFile = path.join(ROOT, 'server.env');
if (fs.existsSync(envFile)) {
  const lines = fs.readFileSync(envFile, 'utf-8').split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const [key, ...rest] = trimmed.split('=');
    if (!key || process.env[key]) continue;
    process.env[key] = rest.join('=').trim();
  }
}

const db = new DatabaseSync(DB_PATH);

db.exec(`
  PRAGMA journal_mode = WAL;

  CREATE TABLE IF NOT EXISTS profiles (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    bio TEXT DEFAULT '',
    status_message TEXT DEFAULT '',
    discord_username TEXT DEFAULT '',
    avatar_data_url TEXT DEFAULT '',
    created_at TEXT NOT NULL,
    updated_at TEXT,
    last_seen_at TEXT
  );

  CREATE TABLE IF NOT EXISTS friend_requests (
    id TEXT PRIMARY KEY,
    from_id TEXT NOT NULL,
    to_id TEXT NOT NULL,
    created_at TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS friendships (
    id TEXT PRIMARY KEY,
    user_a TEXT NOT NULL,
    user_b TEXT NOT NULL,
    created_at TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    level TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TEXT NOT NULL
  );
`);

const app = express();
app.use(helmet());
app.use(cors({ origin: ALLOW_ORIGIN }));
app.use(express.json({ limit: '2mb' }));
app.use(express.static(PUBLIC_DIR));

const nowIso = () => new Date().toISOString();
const normalizeQuery = (value) => String(value || '').trim().toLowerCase();
const isOnline = (lastSeenAt) => {
  if (!lastSeenAt) return false;
  const stamp = Date.parse(lastSeenAt);
  if (Number.isNaN(stamp)) return false;
  return Date.now() - stamp <= ONLINE_TTL_MS;
};

const mapProfile = (row) => ({
  id: row.id,
  username: row.username,
  status: isOnline(row.last_seen_at) ? 'online' : 'offline',
  lastSeenAt: row.last_seen_at || undefined,
  statusMessage: row.status_message || '',
  discordUsername: row.discord_username || '',
  avatarDataUrl: row.avatar_data_url || ''
});

app.post('/api/social/create-profile', (req, res) => {
  const { id, username, email } = req.body || {};
  if (!id || !username || !email) {
    return res.status(400).json({ error: 'invalid_payload' });
  }
  const existing = db.prepare('SELECT id FROM profiles WHERE id = ?').get(id);
  if (existing) {
    db.prepare('UPDATE profiles SET username = ?, email = ?, updated_at = ? WHERE id = ?')
      .run(username, email, nowIso(), id);
  } else {
    db.prepare(
      'INSERT INTO profiles (id, username, email, created_at) VALUES (?, ?, ?, ?)'
    ).run(id, username, email, nowIso());
  }
  return res.json({ ok: true });
});

app.post('/api/social/update-profile', (req, res) => {
  const { userId, bio, statusMessage, discordUsername, avatarDataUrl } = req.body || {};
  if (!userId) return res.status(400).json({ error: 'invalid_payload' });
  const profile = db.prepare('SELECT id FROM profiles WHERE id = ?').get(userId);
  if (!profile) return res.status(404).json({ error: 'not_found' });
  db.prepare(
    `UPDATE profiles
     SET bio = ?, status_message = ?, discord_username = ?, avatar_data_url = ?, updated_at = ?
     WHERE id = ?`
  ).run(
    String(bio ?? ''),
    String(statusMessage ?? ''),
    String(discordUsername ?? ''),
    String(avatarDataUrl ?? ''),
    nowIso(),
    userId
  );
  return res.json({ ok: true });
});

app.post('/api/social/presence', (req, res) => {
  const { userId } = req.body || {};
  if (!userId) return res.status(400).json({ error: 'invalid_payload' });
  db.prepare('UPDATE profiles SET last_seen_at = ? WHERE id = ?').run(nowIso(), userId);
  return res.json({ ok: true });
});

app.get('/api/social/search', (req, res) => {
  const query = normalizeQuery(req.query.query);
  const requesterId = req.query.requesterId;
  if (!query) return res.json({ results: [] });
  const rows = db.prepare(
    'SELECT * FROM profiles WHERE (LOWER(username) LIKE ? OR LOWER(id) LIKE ?) AND id != ? LIMIT 25'
  ).all(`%${query}%`, `%${query}%`, requesterId || '');
  return res.json({ results: rows.map(mapProfile) });
});

app.post('/api/social/request', (req, res) => {
  const { fromId, toId } = req.body || {};
  if (!fromId || !toId) return res.status(400).json({ error: 'invalid_payload' });
  if (fromId === toId) return res.status(400).json({ error: 'self_request' });
  const exists = db.prepare(
    `SELECT id FROM friendships
     WHERE (user_a = ? AND user_b = ?) OR (user_a = ? AND user_b = ?)`
  ).get(fromId, toId, toId, fromId);
  if (exists) return res.status(400).json({ error: 'already_friends' });
  const pending = db.prepare(
    `SELECT id FROM friend_requests
     WHERE (from_id = ? AND to_id = ?) OR (from_id = ? AND to_id = ?)`
  ).get(fromId, toId, toId, fromId);
  if (pending) return res.status(400).json({ error: 'already_pending' });
  const id = `req_${Date.now().toString(36)}_${crypto.randomBytes(3).toString('hex')}`;
  db.prepare('INSERT INTO friend_requests (id, from_id, to_id, created_at) VALUES (?, ?, ?, ?)')
    .run(id, fromId, toId, nowIso());
  return res.json({ ok: true });
});

app.post('/api/social/respond', (req, res) => {
  const { requestId, accept } = req.body || {};
  if (!requestId) return res.status(400).json({ error: 'invalid_payload' });
  const request = db.prepare('SELECT * FROM friend_requests WHERE id = ?').get(requestId);
  if (!request) return res.status(404).json({ error: 'not_found' });
  db.prepare('DELETE FROM friend_requests WHERE id = ?').run(requestId);
  if (accept) {
    const id = `fr_${Date.now().toString(36)}_${crypto.randomBytes(3).toString('hex')}`;
    db.prepare('INSERT INTO friendships (id, user_a, user_b, created_at) VALUES (?, ?, ?, ?)')
      .run(id, request.from_id, request.to_id, nowIso());
  }
  return res.json({ ok: true });
});

app.get('/api/social/requests', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'invalid_payload' });
  const rows = db.prepare(
    `SELECT fr.id, fr.from_id, fr.created_at, p.username
     FROM friend_requests fr
     LEFT JOIN profiles p ON p.id = fr.from_id
     WHERE fr.to_id = ?
     ORDER BY fr.created_at DESC`
  ).all(userId);
  const requests = rows.map((row) => ({
    id: row.id,
    fromId: row.from_id,
    fromUsername: row.username || 'Unknown',
    createdAt: row.created_at
  }));
  return res.json({ requests });
});

app.get('/api/social/friends', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'invalid_payload' });
  const rows = db.prepare(
    `SELECT p.*
     FROM friendships f
     JOIN profiles p ON p.id = CASE WHEN f.user_a = ? THEN f.user_b ELSE f.user_a END
     WHERE f.user_a = ? OR f.user_b = ?`
  ).all(userId, userId, userId);
  return res.json({ friends: rows.map(mapProfile) });
});

app.post('/api/logs', (req, res) => {
  const { userId, level, message } = req.body || {};
  if (!level || !message) return res.status(400).json({ error: 'invalid_payload' });
  db.prepare('INSERT INTO logs (user_id, level, message, created_at) VALUES (?, ?, ?, ?)')
    .run(userId || null, String(level), String(message), nowIso());
  return res.json({ ok: true });
});

app.get('/api/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, () => {
  console.log(`[P1LOT] Server listening on ${PORT}`);
});
