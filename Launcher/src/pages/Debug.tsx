import type { LauncherState } from '../types/launcher';
import Button from '../components/Button';
import Panel from '../components/Panel';
import LogConsole from '../components/LogConsole';
import KeyValue from '../components/KeyValue';

const Debug = ({ state }: { state: LauncherState }) => {
  const { release, install, logs, actions } = state;

  return (
    <div className="page">
      <Panel title="Debug Controls">
        <div className="row">
          <Button variant="primary" onClick={() => actions.startUpdate()}>
            Simulate Update
          </Button>
          <Button variant="ghost" onClick={() => actions.startRepair()}>
            Simulate Repair
          </Button>
          <Button variant="ghost" onClick={() => actions.markCorrupt()}>
            Simulate Corrupt Install
          </Button>
          <Button variant="danger" onClick={() => actions.triggerError('Network timeout: GitHub unreachable')}>
            Trigger Error
          </Button>
          <Button variant="ghost" onClick={() => actions.clearLogs()}>
            Clear Logs
          </Button>
        </div>
      </Panel>

      <div className="page-grid">
        <Panel title="State Snapshot" variant="alt">
          <div className="stack">
            <KeyValue label="State" value={install.state} />
            <KeyValue label="Step" value={install.step} />
            <KeyValue label="Progress" value={`${install.progress}%`} />
            <KeyValue label="Release" value={release?.version ?? '—'} />
          </div>
        </Panel>

        <Panel title="Logs" variant="alt">
          <LogConsole lines={logs} />
        </Panel>
      </div>
    </div>
  );
};

export default Debug;
