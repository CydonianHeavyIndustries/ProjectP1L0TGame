import type { LauncherState } from '../types/launcher';
import Panel from '../components/Panel';

const Settings = ({ state }: { state: LauncherState }) => {
  const { settings, actions } = state;

  return (
    <div className="page">
      <div className="page-grid">
        <Panel title="Launcher Settings">
          <div className="stack">
            <label className="stack">
              Install Directory
              <input
                type="text"
                value={settings.installDir}
                onChange={(event) => actions.updateSettings({ installDir: event.target.value })}
              />
            </label>
            <label className="stack">
              Game Executable (relative to /install)
              <input
                type="text"
                value={settings.gameExeRelative}
                onChange={(event) => actions.updateSettings({ gameExeRelative: event.target.value })}
              />
            </label>
            <label className="stack">
              Local Build Executable (relative to repo)
              <input
                type="text"
                value={settings.localBuildRelative}
                onChange={(event) => actions.updateSettings({ localBuildRelative: event.target.value })}
              />
            </label>
            <label className="toggle">
              <input
                type="checkbox"
                checked={settings.preferLocalBuild}
                onChange={(event) => actions.updateSettings({ preferLocalBuild: event.target.checked })}
              />
              Prefer local build for Play
            </label>
            <label className="stack">
              Bandwidth Limit (Mbps, 0 = unlimited)
              <input
                type="text"
                value={settings.bandwidthLimitMbps}
                onChange={(event) => actions.updateSettings({ bandwidthLimitMbps: Number(event.target.value) || 0 })}
              />
            </label>
            <label className="toggle">
              <input
                type="checkbox"
                checked={settings.autoUpdate}
                onChange={(event) => actions.updateSettings({ autoUpdate: event.target.checked })}
              />
              Auto-update
            </label>
            <label className="toggle">
              <input
                type="checkbox"
                checked={settings.runOnStartup}
                onChange={(event) => actions.updateSettings({ runOnStartup: event.target.checked })}
              />
              Run on startup
            </label>
          </div>
        </Panel>

        <Panel title="Game Settings" variant="alt">
          <div className="stack">
            <label className="stack">
              Launch Args
              <input
                type="text"
                value={settings.launchArgs}
                onChange={(event) => actions.updateSettings({ launchArgs: event.target.value })}
              />
            </label>
            <label className="toggle">
              <input
                type="checkbox"
                checked={settings.safeMode}
                onChange={(event) => actions.updateSettings({ safeMode: event.target.checked })}
              />
              Safe mode
            </label>
            <div className="row">
              <button className="button button-ghost" type="button" onClick={() => actions.resetSettings()}>
                Reset Settings
              </button>
              <button className="button button-primary" type="button" onClick={() => actions.launchLocalBuild()}>
                Launch Local Build
              </button>
            </div>
          </div>
        </Panel>
      </div>
    </div>
  );
};

export default Settings;
