const tokenInput = document.getElementById('admin-token');
const statusEl = document.getElementById('status');
const usersBody = document.querySelector('#users-table tbody');
const userSelect = document.getElementById('file-user-select');
const fileList = document.getElementById('file-list');
const logsEl = document.getElementById('logs');
const hostUpdatesButton = document.getElementById('open-host-updates');
const HOST_BRANCH_URL = 'https://github.com/CydonianHeavyIndustries/ProjectP1L0TGame/tree/host';

const field = (id) => document.getElementById(id);
const tokenKey = 'p1lot_admin_token';
let usersCache = [];
let selectedUserId = '';

const setStatus = (text) => {
  statusEl.textContent = text;
};

const getToken = () => tokenInput.value.trim();

const request = async (url, options = {}) => {
  const headers = { ...(options.headers || {}), 'x-admin-token': getToken() };
  const response = await fetch(url, { ...options, headers });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${response.status} ${response.statusText} - ${body}`);
  }
  return response.json();
};

const saveToken = () => {
  localStorage.setItem(tokenKey, getToken());
  setStatus('Admin token saved in browser.');
};

const loadToken = () => {
  const saved = localStorage.getItem(tokenKey);
  if (saved) tokenInput.value = saved;

  const params = new URLSearchParams(window.location.search);
  const tokenFromQuery = params.get('token');
  if (tokenFromQuery) {
    tokenInput.value = tokenFromQuery;
    localStorage.setItem(tokenKey, tokenFromQuery);
    setStatus('Admin token loaded from launch link.');
  }
};

const getSelectedUser = () => usersCache.find((u) => u.id === selectedUserId);

const fillUserDetail = () => {
  const user = getSelectedUser();
  const target = field('selected-user-id');
  if (!user) {
    target.textContent = 'No user selected.';
    field('detail-status').value = '';
    field('detail-bio').value = '';
    field('detail-discord').value = '';
    field('detail-admin').checked = false;
    field('detail-enabled').checked = false;
    return;
  }

  target.textContent = `${user.username} (${user.id})`;
  field('detail-status').value = user.status || '';
  field('detail-bio').value = user.bio || '';
  field('detail-discord').value = user.discord || '';
  field('detail-admin').checked = !!user.isAdmin;
  field('detail-enabled').checked = !!user.enabled;
};

const selectUser = (userId) => {
  selectedUserId = userId;
  userSelect.value = userId;
  fillUserDetail();
  loadUserFiles().catch((err) => setStatus(err.message));
};

const renderUsers = () => {
  usersBody.innerHTML = '';
  userSelect.innerHTML = '';

  usersCache.forEach((user) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${user.id}</td>
      <td>${user.username}</td>
      <td>${user.email}</td>
      <td>${user.isAdmin ? 'Yes' : 'No'}</td>
      <td>${user.enabled ? 'Yes' : 'No'}</td>
      <td><button class="btn" data-action="open" data-id="${user.id}">Open</button></td>
    `;
    usersBody.appendChild(tr);

    const option = document.createElement('option');
    option.value = user.id;
    option.textContent = `${user.username} (${user.id})`;
    userSelect.appendChild(option);
  });

  if (!selectedUserId && usersCache.length > 0) {
    selectedUserId = usersCache[0].id;
  }
  if (selectedUserId && !usersCache.some((u) => u.id === selectedUserId)) {
    selectedUserId = usersCache[0]?.id || '';
  }
  fillUserDetail();
  if (selectedUserId) {
    userSelect.value = selectedUserId;
  }
};

const loadSettings = async () => {
  const data = await request('/api/admin/settings');
  const s = data.settings;
  field('server-name').value = s.serverName || '';
  field('website-title').value = s.websiteTitle || '';
  field('hardware-profile').value = s.hardwareProfile || 'recommended';
  field('max-players').value = s.maxPlayers || 64;
  field('tick-rate').value = s.tickRate || 60;
  field('autosave-seconds').value = s.autosaveSeconds || 30;
  field('max-upload').value = s.maxUploadMb || 64;
  field('allow-signup').checked = !!s.allowSignup;
  field('maintenance').checked = !!s.maintenanceMode;
  field('telemetry-enabled').checked = s.telemetryEnabled !== false;
  field('motd').value = s.motd || '';
};

const saveSettings = async () => {
  await request('/api/admin/settings', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      serverName: field('server-name').value,
      websiteTitle: field('website-title').value,
      hardwareProfile: field('hardware-profile').value,
      maxPlayers: Number(field('max-players').value || 64),
      tickRate: Number(field('tick-rate').value || 60),
      autosaveSeconds: Number(field('autosave-seconds').value || 30),
      maxUploadMb: Number(field('max-upload').value || 64),
      allowSignup: field('allow-signup').checked,
      maintenanceMode: field('maintenance').checked,
      telemetryEnabled: field('telemetry-enabled').checked,
      motd: field('motd').value
    })
  });
  setStatus('Server settings saved.');
};

const loadUsers = async () => {
  const data = await request('/api/admin/users');
  usersCache = data.users || [];
  renderUsers();
};

const createUser = async () => {
  const username = field('new-username').value.trim();
  const email = field('new-email').value.trim();
  const response = await request('/api/admin/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, email })
  });
  field('new-username').value = '';
  field('new-email').value = '';
  await loadUsers();
  selectUser(response.user.id);
  setStatus(`Created user ${username}.`);
};

const saveUserDetail = async () => {
  if (!selectedUserId) {
    throw new Error('Select a user first.');
  }
  await request(`/api/admin/users/${encodeURIComponent(selectedUserId)}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      status: field('detail-status').value,
      bio: field('detail-bio').value,
      discord: field('detail-discord').value,
      isAdmin: field('detail-admin').checked,
      enabled: field('detail-enabled').checked
    })
  });
  await loadUsers();
  selectUser(selectedUserId);
  setStatus(`Updated ${selectedUserId}.`);
};

const loadUserFiles = async () => {
  const userId = userSelect.value;
  if (!userId) {
    fileList.innerHTML = '';
    return;
  }
  const data = await request(`/api/admin/users/${encodeURIComponent(userId)}/files`);
  fileList.innerHTML = '';
  (data.files || []).forEach((file) => {
    const li = document.createElement('li');
    const left = document.createElement('span');
    left.textContent = `${file.name} (${Math.round(file.size / 1024)} KB)`;
    const btn = document.createElement('button');
    btn.className = 'btn';
    btn.textContent = 'Delete';
    btn.addEventListener('click', async () => {
      await request(`/api/admin/users/${encodeURIComponent(userId)}/files/${encodeURIComponent(file.name)}`, {
        method: 'DELETE'
      });
      await loadUserFiles();
      setStatus(`Deleted ${file.name}.`);
    });
    li.appendChild(left);
    li.appendChild(btn);
    fileList.appendChild(li);
  });
};

const uploadFiles = async () => {
  const userId = userSelect.value;
  const files = field('file-upload').files;
  if (!userId || !files || files.length === 0) {
    throw new Error('Select a user and at least one file.');
  }
  const form = new FormData();
  for (const f of files) form.append('files', f);
  await request(`/api/admin/users/${encodeURIComponent(userId)}/files`, {
    method: 'POST',
    body: form
  });
  field('file-upload').value = '';
  await loadUserFiles();
  setStatus(`Uploaded ${files.length} file(s) for ${userId}.`);
};

const loadLogs = async () => {
  const data = await request('/api/admin/logs');
  logsEl.textContent = (data.lines || []).join('\n');
};

const refreshAll = async () => {
  setStatus('Refreshing...');
  await Promise.all([loadSettings(), loadUsers(), loadLogs()]);
  await loadUserFiles();
  setStatus('Ready.');
};

document.getElementById('save-token').addEventListener('click', saveToken);
document.getElementById('refresh-all').addEventListener('click', () => refreshAll().catch((err) => setStatus(err.message)));
document.getElementById('save-settings').addEventListener('click', () => saveSettings().catch((err) => setStatus(err.message)));
document.getElementById('create-user').addEventListener('click', () => createUser().catch((err) => setStatus(err.message)));
document.getElementById('save-user-detail').addEventListener('click', () => saveUserDetail().catch((err) => setStatus(err.message)));
document.getElementById('upload-files').addEventListener('click', () => uploadFiles().catch((err) => setStatus(err.message)));

if (hostUpdatesButton) {
  hostUpdatesButton.addEventListener('click', () => {
    window.open(HOST_BRANCH_URL, '_blank', 'noopener,noreferrer');
    setStatus('Opened GitHub host branch for server updates.');
  });
}

userSelect.addEventListener('change', () => {
  selectedUserId = userSelect.value;
  fillUserDetail();
  loadUserFiles().catch((err) => setStatus(err.message));
});

usersBody.addEventListener('click', (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;
  if (target.dataset.action === 'open' && target.dataset.id) {
    selectUser(target.dataset.id);
    setStatus(`Loaded ${target.dataset.id}.`);
  }
});

loadToken();
refreshAll().catch((err) => setStatus(`Startup error: ${err.message}`));
