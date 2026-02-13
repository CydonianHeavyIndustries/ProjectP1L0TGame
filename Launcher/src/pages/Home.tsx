import type { LauncherState } from '../types/launcher';
import Button from '../components/Button';
import ChannelTag from '../components/ChannelTag';
import InstallStateBadge from '../components/InstallStateBadge';
import Panel from '../components/Panel';
import ProgressBar from '../components/ProgressBar';
import StatChip from '../components/StatChip';
import KeyValue from '../components/KeyValue';
import { formatBytes, formatDate } from '../utils/format';

const primaryActionLabel = (state: string) => {
  if (state === 'NotInstalled') return 'Install';
  if (state === 'UpdateAvailable') return 'Update';
  if (state === 'RepairRecommended') return 'Repair';
  if (state === 'Error') return 'Recover';
  if (state === 'Updating' || state === 'Repairing') return 'Working';
  return 'Play';
};

const parseReleaseNotes = (body?: string | null) => {
  if (!body) return ['No release notes available.'];
  const lines = body.split('\n').map((line) => line.trim());
  const bullets = lines
    .filter((line) => line.startsWith('- ') || line.startsWith('* '))
    .map((line) => line.slice(2).trim())
    .filter(Boolean);
  return bullets.length > 0 ? bullets : [body.slice(0, 180) + (body.length > 180 ? '…' : '')];
};

const Home = ({ state }: { state: LauncherState }) => {
  const { channel, setChannel, release, install, server, installedVersion, actions, settings } = state;
  const isBusy = install.state === 'Updating' || install.state === 'Repairing';
  const isServerBusy = server.status === 'Starting' || server.status === 'Stopping';
  const isServerRunning = server.status === 'Running';
  const remoteVersion = release?.version ?? '—';
  const payloadSize = release?.asset?.size ? formatBytes(release.asset.size) : '—';
  const releaseDate = release?.publishedAt ? formatDate(release.publishedAt) : '—';
  const primaryLabel = settings.useLocalBuild && !isBusy ? 'Play (Local)' : primaryActionLabel(install.state);
  const notes = parseReleaseNotes(release?.body);

  const handlePrimary = () => {
    if (settings.useLocalBuild) return actions.requestLaunch();
    if (install.state === 'NotInstalled') return actions.startInstall();
    if (install.state === 'UpdateAvailable') return actions.startUpdate();
    if (install.state === 'RepairRecommended' || install.state === 'Error') return actions.startRepair();
    if (install.state === 'Updating' || install.state === 'Repairing') return;
    return actions.requestLaunch();
  };

  return (
    <div className="page">
      <div className="hero">
        <div className="row" style={{ justifyContent: 'space-between' }}>
          <div className="stack">
            <span className="tag" data-channel={channel}>
              {channel}
            </span>
            <h1>Project P1L0T Command Console</h1>
            <p>
              Cydonian Heavy Industries staging bay. Maintain operational builds, deploy updates, and launch with
              deterministic control.
            </p>
          </div>
          <div className="stack" style={{ alignItems: 'flex-end' }}>
            <InstallStateBadge state={install.state} />
            <StatChip label="Installed" value={installedVersion} />
            <StatChip label="Latest" value={remoteVersion} accent="cyan" />
          </div>
        </div>
        <div className="row" style={{ justifyContent: 'space-between' }}>
          <div className="row">
            <Button variant="primary" className="button-play" onClick={handlePrimary} disabled={isBusy}>
              {primaryLabel}
            </Button>
            <Button variant="ghost" onClick={() => actions.requestLocalLaunch()} disabled={isBusy}>
              Local Play
            </Button>
            <Button variant="ghost" onClick={() => actions.startRepair()} disabled={isBusy}>
              Repair
            </Button>
          </div>
          <div className="row">
            <label className="tag">Channel</label>
            <select value={channel} onChange={(event) => setChannel(event.target.value as typeof channel)}>
              <option value="dev">Dev</option>
              <option value="test">Test</option>
              <option value="live">Live</option>
            </select>
          </div>
        </div>
        {isBusy && (
          <div className="stack">
            <div className="row" style={{ justifyContent: 'space-between' }}>
              <span>{install.step}</span>
              <strong>{install.progress}%</strong>
            </div>
            <ProgressBar value={install.progress} />
          </div>
        )}
      </div>

      <div className="page-grid">
        <Panel title="Release Snapshot">
          <div className="stack">
            <KeyValue label="Release" value={releaseDate} />
            <KeyValue label="Payload" value={payloadSize} />
            <KeyValue label="Asset" value={release?.asset?.name ?? '—'} />
            <KeyValue label="Version" value={remoteVersion} />
          </div>
        </Panel>

        <Panel title="Patch Notes" variant="alt">
          <div className="stack">
            <strong>{release?.name ?? 'Awaiting release'}</strong>
            <div className="notice">
              {notes.map((note) => (
                <div key={note}>- {note}</div>
              ))}
            </div>
          </div>
        </Panel>

        <Panel title="Channel Status" variant="alt">
          <div className="stack">
            <ChannelTag channel={channel} />
            <div className="notice">
              {channel === 'dev'
                ? 'Dev builds ship fast and may break. Expect frequent release shifts.'
                : channel === 'test'
                ? 'Test builds are stabilized for squads and external pilots.'
                : 'Live is the public rail. Updates may be required before launch.'}
            </div>
          </div>
        </Panel>

        <Panel title="Server Host">
          <div className="stack">
            <KeyValue label="Status" value={server.status} />
            <KeyValue label="Port" value={server.port ? String(server.port) : String(settings.serverPort)} />
            <KeyValue label="PID" value={server.pid ? String(server.pid) : '—'} />
            <KeyValue label="Started" value={server.startedAt ? formatDate(server.startedAt) : '—'} />
            {server.message && <div className="notice">{server.message}</div>}
            <div className="row">
              <Button variant="primary" onClick={() => actions.startServer()} disabled={isServerBusy || isServerRunning}>
                Start Server
              </Button>
              <Button variant="ghost" onClick={() => actions.requestJoinServer()} disabled={isBusy || isServerBusy}>
                Join Server
              </Button>
              <Button variant="ghost" onClick={() => actions.stopServer()} disabled={isServerBusy || !isServerRunning}>
                Stop Server
              </Button>
            </div>
          </div>
        </Panel>
      </div>
    </div>
  );
};

export default Home;
