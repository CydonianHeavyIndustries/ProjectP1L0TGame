import type { InstallState } from '../types/install';
import StatChip from './StatChip';

const installStateAccent = (state: InstallState) => {
  if (state === 'UpdateAvailable') return 'magenta';
  if (state === 'RepairRecommended' || state === 'Error') return 'orange';
  if (state === 'Installed') return 'cyan';
  return undefined;
};

const InstallStateBadge = ({ state }: { state: InstallState }) => (
  <StatChip label="State" value={state.replace(/([A-Z])/g, ' $1').trim()} accent={installStateAccent(state)} />
);

export default InstallStateBadge;
