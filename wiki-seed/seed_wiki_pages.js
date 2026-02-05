const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const DEFAULT_REPO_URL = 'https://github.com/CydonianHeavyIndustries/Project-P1L0T.wiki.git';

const args = process.argv.slice(2);
const argRepoIndex = args.findIndex((a) => a === '--repo');
const repoUrl = (argRepoIndex >= 0 && args[argRepoIndex + 1]) || process.env.WIKI_URL || DEFAULT_REPO_URL;

const rootDir = __dirname;
const wikiDir = path.join(rootDir, '.wiki');
const pagesDir = path.join(rootDir, 'pages');

function getAuthHeader() {
  const user = process.env.GITHUB_USER;
  const token = process.env.GITHUB_TOKEN;
  if (!user || !token) return null;
  const basic = Buffer.from(`${user}:${token}`, 'utf8').toString('base64');
  return `AUTHORIZATION: basic ${basic}`;
}

function runGit(args, opts = {}) {
  const env = { ...process.env, GIT_TERMINAL_PROMPT: '0' };
  const authHeader = getAuthHeader();
  const cmd = authHeader ? `git -c http.extraHeader="${authHeader}" ${args}` : `git ${args}`;
  execSync(cmd, { stdio: 'inherit', cwd: opts.cwd || wikiDir, env });
}

function ensureRepo() {
  const gitDir = path.join(wikiDir, '.git');
  if (fs.existsSync(gitDir)) {
    runGit('pull --ff-only');
    return;
  }

  if (!fs.existsSync(wikiDir)) {
    fs.mkdirSync(wikiDir, { recursive: true });
  }

  const authHeader = getAuthHeader();
  const env = { ...process.env, GIT_TERMINAL_PROMPT: '0' };
  const cmd = authHeader
    ? `git -c http.extraHeader="${authHeader}" clone ${repoUrl} "${wikiDir}"`
    : `git clone ${repoUrl} "${wikiDir}"`;
  execSync(cmd, { stdio: 'inherit', env });
}

function configureGitIdentity() {
  const user = process.env.GITHUB_USER;
  if (!user) return;
  const email = process.env.GITHUB_EMAIL || `${user}@users.noreply.github.com`;
  runGit(`config user.name "${user}"`);
  runGit(`config user.email "${email}"`);
}

function syncPages() {
  if (!fs.existsSync(pagesDir)) {
    throw new Error(`pages directory not found: ${pagesDir}`);
  }

  const pageFiles = fs.readdirSync(pagesDir).filter((f) => f.toLowerCase().endsWith('.md'));
  for (const file of pageFiles) {
    const sourcePath = path.join(pagesDir, file);
    const targetPath = path.join(wikiDir, file);
    const content = fs.readFileSync(sourcePath, 'utf8');
    fs.writeFileSync(targetPath, content.replace(/\s*$/g, '') + '\n', 'utf8');
  }
}

function hasChanges() {
  const output = execSync('git status --porcelain', { cwd: wikiDir }).toString('utf8').trim();
  return output.length > 0;
}

function requireAuthForPush() {
  if (!getAuthHeader()) {
    throw new Error('GITHUB_USER and GITHUB_TOKEN are required to push changes.');
  }
}

function main() {
  ensureRepo();
  configureGitIdentity();
  syncPages();

  if (!hasChanges()) {
    console.log('No changes detected.');
    return;
  }

  runGit('add -A');
  runGit('commit -m "Wiki seed: initialize index pages"');
  requireAuthForPush();
  runGit('push');
}

try {
  main();
} catch (err) {
  console.error(err.message || err);
  process.exit(1);
}
