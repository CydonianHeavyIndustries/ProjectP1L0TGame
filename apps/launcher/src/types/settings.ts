export interface LauncherSettings {
  installDir: string;
  bandwidthLimitMbps: number;
  autoUpdate: boolean;
  runOnStartup: boolean;
  launchArgs: string;
  safeMode: boolean;
  gameExeRelative: string;
  useLocalBuild: boolean;
  localBuildRelative: string;
  serverAddress: string;
  serverPort: number;
  serverArgs: string;
}
