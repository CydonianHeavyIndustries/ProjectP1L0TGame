import type { Channel } from '../types/channel';

interface ChannelTagProps {
  channel: Channel;
}

const ChannelTag = ({ channel }: ChannelTagProps) => (
  <span className="tag" data-channel={channel}>
    {channel}
  </span>
);

export default ChannelTag;
