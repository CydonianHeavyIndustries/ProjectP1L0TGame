import { useMemo, useState } from 'react';
import type { LauncherState } from '../types/launcher';
import Button from '../components/Button';
import KeyValue from '../components/KeyValue';
import Panel from '../components/Panel';

const fallbackInitials = (username: string): string => {
  const parts = username
    .split(/\s+/)
    .map((part) => part.trim())
    .filter(Boolean);
  if (parts.length === 0) return 'P';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
};

const Account = ({ state }: { state: LauncherState }) => {
  const { authUser, actions } = state;
  const [notice, setNotice] = useState<string>('');
  const [bio, setBio] = useState(authUser?.bio ?? '');
  const [statusMessage, setStatusMessage] = useState(authUser?.statusMessage ?? 'Online');
  const [avatarDataUrl, setAvatarDataUrl] = useState(authUser?.avatarDataUrl ?? '');

  const initials = useMemo(() => fallbackInitials(authUser?.username ?? ''), [authUser?.username]);

  if (!authUser) {
    return (
      <div className="page">
        <Panel title="Account Settings" variant="alt">
          <div className="notice">Sign in from the Social tab to edit profile settings.</div>
        </Panel>
      </div>
    );
  }

  const handleAvatarFile = (file?: File) => {
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      setNotice('Avatar must be an image file.');
      return;
    }
    const reader = new FileReader();
    reader.onload = () => {
      const next = typeof reader.result === 'string' ? reader.result : '';
      setAvatarDataUrl(next);
      setNotice('Avatar loaded. Click Save Profile.');
    };
    reader.onerror = () => setNotice('Failed to read avatar file.');
    reader.readAsDataURL(file);
  };

  const handleSave = () => {
    const result = actions.updateAccountProfile({
      bio,
      statusMessage,
      avatarDataUrl
    });
    setNotice(result.message);
  };

  return (
    <div className="page">
      <div className="page-grid">
        <Panel title="Account Settings">
          <div className="stack">
            <label className="stack">
              Status
              <input
                type="text"
                maxLength={80}
                value={statusMessage}
                onChange={(event) => setStatusMessage(event.target.value)}
                placeholder="Online, Away, Busy..."
              />
            </label>

            <label className="stack">
              Bio
              <textarea
                className="account-bio"
                maxLength={280}
                value={bio}
                onChange={(event) => setBio(event.target.value)}
                placeholder="Tell other pilots about your role and playstyle."
              />
            </label>

            <label className="stack">
              Profile Picture
              <input type="file" accept="image/*" onChange={(event) => handleAvatarFile(event.target.files?.[0])} />
            </label>

            <div className="row">
              <Button variant="primary" onClick={handleSave}>
                Save Profile
              </Button>
              <Button
                variant="ghost"
                onClick={() => {
                  setAvatarDataUrl('');
                  setNotice('Avatar cleared. Click Save Profile.');
                }}
              >
                Clear Avatar
              </Button>
            </div>

            {notice ? <div className="notice">{notice}</div> : null}
          </div>
        </Panel>

        <Panel title="Profile Preview" variant="alt">
          <div className="stack">
            <div className="account-avatar">
              {avatarDataUrl ? <img src={avatarDataUrl} alt="Pilot avatar" className="account-avatar-image" /> : <span>{initials}</span>}
            </div>
            <KeyValue label="Player ID" value={authUser.id} />
            <KeyValue label="Username" value={authUser.username} />
            <KeyValue label="Email" value={authUser.email} />
            <KeyValue label="Status" value={statusMessage || 'Online'} />
            <div className="notice">{bio || 'No bio set.'}</div>
          </div>
        </Panel>
      </div>
    </div>
  );
};

export default Account;
