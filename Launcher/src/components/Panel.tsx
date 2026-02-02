import type { ReactNode } from 'react';

interface PanelProps {
  title?: string;
  children: ReactNode;
  variant?: 'default' | 'alt';
}

const Panel = ({ title, children, variant = 'default' }: PanelProps) => (
  <section className="panel" data-variant={variant === 'alt' ? 'alt' : undefined}>
    {title && <div className="panel-title">{title}</div>}
    {children}
  </section>
);

export default Panel;
