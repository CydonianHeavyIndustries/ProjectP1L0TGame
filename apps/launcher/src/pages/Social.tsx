import { useEffect, useState } from 'react';
import type { LauncherState } from '../types/launcher';
import Button from '../components/Button';
import KeyValue from '../components/KeyValue';
import Panel from '../components/Panel';

const Social = ({ state }: { state: LauncherState }) => {
  const { authUser, authMode, pendingVerificationIdentity, actions } = state;
  const [tab, setTab] = useState<'login' | 'create' | 'verify'>('login');
  const [identity, setIdentity] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [createPassword, setCreatePassword] = useState('');
  const [verifyIdentity, setVerifyIdentity] = useState('');
  const [verifyCode, setVerifyCode] = useState('');
  const [notice, setNotice] = useState<string | null>(null);

  useEffect(() => {
    if (!pendingVerificationIdentity) return;
    setVerifyIdentity(pendingVerificationIdentity);
    setTab('verify');
  }, [pendingVerificationIdentity]);

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
    }
  };

  const handleResend = () => {
    const result = actions.resendVerificationCode(verifyIdentity);
    setNotice(buildNotice(result.message, result.devCode));
  };

  if (authUser) {
    return (
      <div className="page">
        <Panel title="Account" variant="alt">
          <div className="stack">
            <KeyValue label="Pilot" value={authUser.username} />
            <KeyValue label="Email" value={authUser.email} />
            <KeyValue label="Verified" value={authUser.emailVerified ? 'Yes' : 'No'} />
            <KeyValue label="Provider" value={authMode} />
            <KeyValue label="Created" value={new Date(authUser.createdAt).toLocaleString()} />
            <KeyValue label="Last Login" value={authUser.lastLoginAt ? new Date(authUser.lastLoginAt).toLocaleString() : '—'} />
            <div className="row">
              <Button variant="ghost" onClick={() => actions.logoutUser()}>
                Sign Out
              </Button>
            </div>
          </div>
        </Panel>

        <Panel title="Social Hub" variant="alt">
          <div className="notice">
            Social database is currently local-only for prototyping. When Project-P1L0T backend is online, this account flow will move to server-backed auth and persistent friends/clans/chat data.
          </div>
        </Panel>
      </div>
    );
  }

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
        <div className="stack">
          <div className="notice">
            Validation emails are currently simulated in local mode. Next step is wiring CHII backend auth + SMTP provider.
          </div>
          <div className="notice">
            Signup website target: <strong>CydonianHeavyIndustries.inc</strong>
          </div>
        </div>
      </Panel>
    </div>
  );
};

export default Social;
