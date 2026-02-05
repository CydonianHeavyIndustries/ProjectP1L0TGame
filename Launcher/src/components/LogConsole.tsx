interface LogConsoleProps {
  lines: string[];
}

const LogConsole = ({ lines }: LogConsoleProps) => (
  <div className="log-console">
    {lines.length === 0 ? 'No logs yet.' : lines.join('\n')}
  </div>
);

export default LogConsole;
