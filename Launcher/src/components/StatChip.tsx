import type { ReactNode } from 'react';

interface StatChipProps {
  label: string;
  value?: ReactNode;
  accent?: 'cyan' | 'magenta' | 'orange';
}

const StatChip = ({ label, value, accent }: StatChipProps) => (
  <div className="stat-chip" data-accent={accent}>
    <span>{label}</span>
    {value && <strong>{value}</strong>}
  </div>
);

export default StatChip;
