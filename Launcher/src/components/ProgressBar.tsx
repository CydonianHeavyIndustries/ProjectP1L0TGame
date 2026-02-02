interface ProgressBarProps {
  value: number;
}

const ProgressBar = ({ value }: ProgressBarProps) => {
  const clamped = Math.max(0, Math.min(100, value));
  return (
    <div className="progress" aria-valuenow={clamped} aria-valuemin={0} aria-valuemax={100}>
      <div className="progress-fill" style={{ width: `${clamped}%` }} />
    </div>
  );
};

export default ProgressBar;
