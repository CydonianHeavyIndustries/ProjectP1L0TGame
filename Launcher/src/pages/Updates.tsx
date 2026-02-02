import type { LauncherState } from '../types/launcher';
import Button from '../components/Button';
import Panel from '../components/Panel';
import ProgressBar from '../components/ProgressBar';
import KeyValue from '../components/KeyValue';
import { formatBytes, formatDate } from '../utils/format';

const Updates = ({ state }: { state: LauncherState }) => {
  const { release, install, actions } = state;
  const isBusy = install.state === 'Updating' || install.state === 'Repairing';
  const payloadSize = release?.asset?.size ? formatBytes(release.asset.size) : '—';
  const releaseDate = release?.publishedAt ? formatDate(release.publishedAt) : '—';

  return (
    <div className="page">
      <Panel title="Update Pipeline">
        <div className="stack">
          <KeyValue label="Current Step" value={install.step} />
          <KeyValue label="State" value={install.state} />
          <ProgressBar value={install.progress} />
          <div className="row">
            <Button variant="primary" onClick={() => actions.startUpdate()} disabled={isBusy}>
              Start Update
            </Button>
            <Button variant="ghost" onClick={() => actions.startRepair()} disabled={isBusy}>
              Repair Install
            </Button>
            <Button variant="ghost" onClick={() => actions.openInstallDir()}>
              Open Install Folder
            </Button>
            <Button variant="ghost" onClick={() => actions.openLogs()}>
              Open Logs
            </Button>
          </div>
        </div>
      </Panel>

      <div className="page-grid">
        <Panel title="Release Details" variant="alt">
          <div className="stack">
            <KeyValue label="Release" value={releaseDate} />
            <KeyValue label="Payload Size" value={payloadSize} />
            <KeyValue label="Asset" value={release?.asset?.name ?? '—'} />
            <KeyValue label="URL" value={release?.asset?.url ?? '—'} />
          </div>
        </Panel>

        <Panel title="Install Contract" variant="alt">
          <div className="notice">
            Atomic installs: download to /cache, extract into /staging, validate, then swap /install in one move.
            Install stays playable even if staging fails.
          </div>
        </Panel>
      </div>
    </div>
  );
};

export default Updates;
