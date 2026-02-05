const fs = require('fs');
const path = require('path');

const logDir = path.join(__dirname, 'data', 'logs');
const logFile = path.join(logDir, 'lorekeeper.log');

function ensureLogDir() {
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
}

function formatLine(level, message, meta) {
  const time = new Date().toISOString();
  const base = { time, level, message };
  const payload = meta ? { ...base, meta } : base;
  return JSON.stringify(payload);
}

function log(level, message, meta) {
  try {
    ensureLogDir();
    const line = formatLine(level, message, meta);
    fs.appendFileSync(logFile, line + '\n', 'utf8');
  } catch (err) {
    // Fall back to console if file logging fails
    console.error('Logging failed:', err.message || err);
  }
}

module.exports = {
  log,
  logFile
};
