export type ServerStatus = 'Stopped' | 'Starting' | 'Running' | 'Stopping' | 'Error';

export interface ServerState {
  status: ServerStatus;
  pid?: number;
  port?: number;
  startedAt?: string;
  message?: string;
}
