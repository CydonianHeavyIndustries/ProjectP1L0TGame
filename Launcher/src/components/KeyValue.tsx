import type { ReactNode } from 'react';

interface KeyValueProps {
  label: string;
  value: ReactNode;
}

const KeyValue = ({ label, value }: KeyValueProps) => (
  <div className="kv">
    <span>{label}</span>
    <strong>{value}</strong>
  </div>
);

export default KeyValue;
