import { useEffect, useState } from 'react';
import type { LauncherState } from '../types/launcher';
import type { SocialProfile } from '../types/social';
import Button from '../components/Button';
import KeyValue from '../components/KeyValue';
import Panel from '../components/Panel';

const Social = ({ state }: { state: LauncherState }) => {
  const { authUser, authMode, pendingVerificationIdentity, friends, friendRequests, actions } = state;
  const [tab, setTab] = useState<'login' | 'create' | 'verify'>('login');
  const [identity, setIdentity] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [createPassword, setCreatePassword] = useState('');
  const [verifyIdentity, setVerifyIdentity] = useState('');
  const [verifyCode, setVerifyCode] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SocialProfile[]>([]);
  const [notice, setNotice] = useState<string | null>(null);

  useEffect(() => {
    if (!pendingVerificationIdentity) return;
    setVerifyIdentity(pendingVerificationIdentity);
    setTab('verify');
  }, [pendingVerificationIdentity]);

  useEffect(() => {
    if (!authUser) return;
    actions.refreshSocial().catch(() => null);
  }, [authUser?.id]);

  const buildNotice = (message: string, devCode?: string): string =>
    devCode ? `${message} (DEV validation code: ${devCode})` : message;

  const handleLogin = () => {
    const result = actions.loginUser({ identity, password: loginPassword });
    setNotice(buildNotice(result.message, result.devCode));
    if (result.requiresVerification) {
      setTab('verify');
      setVerifyIdentity(identity.trim());
    }
    if (result.ok) {
      setIdentity('');
      setLoginPassword('');
      actions.refreshSocial().catch(() => null);
    }
  };

  const handleCreate = () => {
    const result = actions.createUserAccount({ username, email, password: createPassword });
    setNotice(buildNotice(result.message, result.devCode));
    if (result.requiresVerification) {
      setTab('verify');
      setVerifyIdentity(email.trim());
    }
    if (result.ok) {
      setUsername('');
      setEmail('');
      setCreatePassword('');
    }
  };

  const handleVerify = () => {
    const result = actions.verifyEmailCode({ identity: verifyIdentity, code: verifyCode });
    setNotice(buildNotice(result.message, result.devCode));
    if (result.ok) {
      setVerifyCode('');
      actions.refreshSocial().catch(() => null);
    }
  };

  const handleResend = () => {
    const result = actions.resendVerificationCode(verifyIdentity);
    setNotice(buildNotice(result.message, result.devCode));
  };

  const handleSearch = async () => {
    const results = await actions.searchPlayers(searchQuery);
    setSearchResults(results);
    if (results.length === 0) {
      setNotice('No pilots found for that query.');
    }
  };

  if (!authUser) {
    return (
      <div className="page">
        <Panel title="Pilot Access" variant="alt">
          <div className="row">
            <Button variant={tab === 'login' ? 'primary' : 'ghost'} onClick={() => setTab('login')}>
              Login
            </Button>
            <Button variant={tab === 'create' ? 'primary' : 'ghost'} onClick={() => setTab('create')}>
              Create User
            </Button>
            <Button variant={tab === 'verify' ? 'primary' : 'ghost'} onClick={() => setTab('verify')}>
              Verify Email
            </Button>
          </div>

          {tab === 'login' && (
            <div className="stack">
              <label className="stack">
                Username or Email
                <input
                  type="text"
                  value={identity}
                  onChange={(event) => setIdentity(event.target.value)}
                  placeholder="pilot_name or pilot@email.com"
                />
              </label>
              <label className="stack">
                Password
                <input type="password" value={loginPassword} onChange={(event) => setLoginPassword(event.target.value)} />
              </label>
              <div className="row">
                <Button variant="primary" onClick={handleLogin}>
                  Sign In
                </Button>
              </div>
            </div>
          )}

          {tab === 'create' && (
            <div className="stack">
              <label className="stack">
                Username
                <input type="text" value={username} onChange={(event) => setUsername(event.target.value)} placeholder="min 3 chars" />
              </label>
              <label className="stack">
                Email
                <input type="email" value={email} onChange={(event) => setEmail(event.target.value)} />
              </label>
              <label className="stack">
                Password
                <input
                  type="password"
                  value={createPassword}
                  onChange={(event) => setCreatePassword(event.target.value)}
                  placeholder="min 8 chars"
                />
              </label>
              <div className="row">
                <Button variant="primary" onClick={handleCreate}>
                  Create Account
                </Button>
              </div>
            </div>
          )}

          {tab === 'verify' && (
            <div className="stack">
              <label className="stack">
                Username or Email
                <input
                  type="text"
                  value={verifyIdentity}
                  onChange={(event) => setVerifyIdentity(event.target.value)}
                  placeholder="pilot_name or pilot@email.com"
                />
              </label>
              <label className="stack">
                Validation Code
                <input
                  type="text"
                  inputMode="numeric"
                  value={verifyCode}
                  onChange={(event) => setVerifyCode(event.target.value.replace(/\D/g, '').slice(0, 6))}
                  placeholder="6-digit code"
                />
              </label>
              <div className="row">
                <Button variant="primary" onClick={handleVerify}>
                  Verify Email
                </Button>
                <Button variant="ghost" onClick={handleResend}>
                  Resend Code
                </Button>
              </div>
            </div>
          )}

          {notice && <div className="notice">{notice}</div>}
        </Panel>

        <Panel title="Roadmap Link" variant="alt">
          <div className="notice">
            Social systems are locally simulated for now. Next step is wiring the Project-P1L0T backend for real pilot presence and matchmaking.
          </div>
        </Panel>
      </div>
    );
  }

  return (
    <div className="page">
      {notice && <div className="notice">{notice}</div>}
      <div className="page-grid">
        <Panel title="Pilot Profile">
          <div className="stack">
            <KeyValue label="Player ID" value={authUser.id} />
            <KeyValue label="Username" value={authUser.username} />
            <KeyValue label="Provider" value={authMode} />
            <div className="row">
              <Button variant="ghost" onClick={() => actions.logoutUser()}>
                Sign Out
              </Button>
            </div>
          </div>
        </Panel>

        <Panel title="Find Pilots" variant="alt">
          <div className="stack">
            <label className="stack">
              Search by username or player ID
              <input
                type="text"
                value={searchQuery}
                onChange={(event) => setSearchQuery(event.target.value)}
                placeholder="pilot or usr_..."
              />
            </label>
            <div className="row">
              <Button variant="primary" onClick={handleSearch}>
                Search
              </Button>
            </div>
            {searchResults.length > 0 && (
              <div className="stack">
                {searchResults.map((profile) => (
                  <div key={profile.id} className="kv">
                    <strong>{profile.username}</strong>
                    <span>{profile.status === 'online' ? 'Online' : 'Offline'}</span>
                    <Button
                      variant="ghost"
                      onClick={() => actions.sendFriendRequest(profile.id).then((result) => setNotice(result.message))}
                    >
                      Add
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </Panel>

        <Panel title="Friend Requests" variant="alt">
          <div className="stack">
            {friendRequests.length === 0 && <div className="notice">No incoming requests.</div>}
            {friendRequests.map((request) => (
              <div key={request.id} className="row" style={{ justifyContent: 'space-between' }}>
                <span>{request.fromUsername}</span>
                <div className="row">
                  <Button
                    variant="primary"
                    onClick={() => actions.acceptFriendRequest(request.id).then((result) => setNotice(result.message))}
                  >
                    Accept
                  </Button>
                  <Button
                    variant="ghost"
                    onClick={() => actions.rejectFriendRequest(request.id).then((result) => setNotice(result.message))}
                  >
                    Decline
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </Panel>

        <Panel title="Friends Online">
          <div className="stack">
            {friends.length === 0 && <div className="notice">No friends added yet.</div>}
            {friends.map((friend) => (
              <div key={friend.id} className="row" style={{ justifyContent: 'space-between' }}>
                <span>{friend.username}</span>
                <span>{friend.status === 'online' ? 'Online' : 'Offline'}</span>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </div>
  );
};

export default Social;
