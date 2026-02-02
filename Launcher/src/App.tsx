import { useMemo, useState } from 'react';
import Home from './pages/Home';
import Updates from './pages/Updates';
import Settings from './pages/Settings';
import Social from './pages/Social';
import Debug from './pages/Debug';
import { useLauncherState } from './state/useLauncherState';

const App = () => {
  const state = useLauncherState();
  const isDev = typeof window !== 'undefined' && window.launcher?.isDev;
  const [active, setActive] = useState('home');

  const tabs = useMemo(
    () =>
      [
        { id: 'home', label: 'Home' },
        { id: 'updates', label: 'Updates' },
        { id: 'settings', label: 'Settings' },
        { id: 'social', label: 'Social' },
        ...(isDev ? [{ id: 'debug', label: 'Debug' }] : [])
      ],
    [isDev]
  );

  return (
    <div className="app">
      <header className="topbar">
        <div className="brand">
          <div className="brand-mark" />
          <div className="brand-text">
            <span>Cydonian Heavy Industries</span>
            <strong>Project P1L0T</strong>
          </div>
        </div>
        <nav className="nav">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              className="nav-button"
              data-active={active === tab.id}
              onClick={() => setActive(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </nav>
        <div className="status-strip">
          <span className="stat-chip" data-accent="cyan">
            Env {state.channel}
          </span>
          <span className="stat-chip" data-accent="magenta">
            {state.install.state}
          </span>
        </div>
      </header>

      <main className="content">
        {active === 'home' && <Home state={state} />}
        {active === 'updates' && <Updates state={state} />}
        {active === 'settings' && <Settings state={state} />}
        {active === 'social' && <Social />}
        {active === 'debug' && <Debug state={state} />}
      </main>
    </div>
  );
};

export default App;
