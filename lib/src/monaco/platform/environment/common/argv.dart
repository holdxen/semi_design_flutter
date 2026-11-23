// 1:1 translation of
// vscode/src/vs/platform/environment/common/argv.ts
// Pure interface declarations. Hyphenated keys camelized (original in comment);
// boolean->bool, string[]->List<String>, all fields optional. No runtime logic.

/// 1:1: `export interface INativeCliOptions`
class INativeCliOptions {
  final String? cliDataDir; // 'cli-data-dir'
  final bool? disableTelemetry; // 'disable-telemetry'
  final String? telemetryLevel; // 'telemetry-level'
  INativeCliOptions({this.cliDataDir, this.disableTelemetry, this.telemetryLevel});
}

/// 1:1: `tunnel.user.login`
class NativeTunnelLogin {
  final String? accessToken; // 'access-token'
  final String? provider; // 'provider'
  NativeTunnelLogin({this.accessToken, this.provider});
}

/// 1:1: `tunnel` subcommand
class NativeTunnelOptions extends INativeCliOptions {
  final NativeTunnelLogin? user;
  NativeTunnelOptions({super.cliDataDir, super.disableTelemetry, super.telemetryLevel, this.user});
}

/// 1:1: `chat` subcommand
class NativeChatOptions {
  final List<String>? underscore; // '_'
  final List<String>? addFile; // 'add-file'
  final String? mode;
  final bool? maximize;
  final bool? reuseWindow; // 'reuse-window'
  final bool? newWindow; // 'new-window'
  final String? profile;
  final bool? help;
  NativeChatOptions({
    this.underscore, this.addFile, this.mode, this.maximize,
    this.reuseWindow, this.newWindow, this.profile, this.help,
});
}

/// 1:1: `export interface NativeParsedArgs`
class NativeParsedArgs {
  final String? cliDataDir; // 'cli-data-dir'
  final bool? disableTelemetry; // 'disable-telemetry'
  final String? telemetryLevel; // 'telemetry-level'
  final String? serveWeb; // 'serve-web'
  final String? agent;
  final List<String>? underscore; // required in TS
  final List<String>? folderUri; // undefined or array of 1 or more
  final List<String>? fileUri; // undefined or array of 1 or more
  final List<String>? urls; // '_urls'
  final bool? help;
  final bool? version;
  final bool? telemetry;
  final bool? status;
  final bool? wait;
  final String? waitMarkerFilePath;
  final bool? diff;
  final bool? merge;
  final bool? add;
  final bool? remove;
  final bool? goto;
  final bool? newWindow; // 'new-window'
  final bool? reuseWindow; // 'reuse-window'
  final bool? agents;
  final String? sessionTitleBase64; // 'session-title-base64'
  final String? locale;
  final String? userDataDir; // 'user-data-dir'
  final bool? profStartup; // 'prof-startup'
  final String? profStartupPrefix; // 'prof-startup-prefix'
  final String? profAppendTimers; // 'prof-append-timers'
  final List<String>? profDurationMarkers; // 'prof-duration-markers'
  final String? profDurationMarkersFile; // 'prof-duration-markers-file'
  final bool? profV8Extensions; // 'prof-v8-extensions'
  final bool? noCachedData; // 'no-cached-data'
  final bool? verbose;
  final bool? trace;
  final bool? traceMemoryInfra; // 'trace-memory-infra'
  final String? traceCategoryFilter; // 'trace-category-filter'
  final String? traceOptions; // 'trace-options'
  final bool? openDevtools; // 'open-devtools'
  final List<String>? log;
  final bool? logExtensionHostCommunication;
  final String? extensionsDir; // 'extensions-dir'
  final String? extensionsDownloadDir; // 'extensions-download-dir'
  final String? builtinExtensionsDir; // 'builtin-extensions-dir'
  final String? sharedDataDir; // 'shared-data-dir'
  final String? agentPluginsDir; // 'agent-plugins-dir'
  final String? agentsUserDataDir; // 'agents-user-data-dir'
  final String? agentsExtensionsDir; // 'agents-extensions-dir'
  final List<String>? extensionDevelopmentPath; // undefined or array of 1 or more local paths or URIs
  final String? extensionTestsPath; // either a local path or a URI
  final bool? hiddenWindow; // only honored together with `extensionTestsPath`
  final List<String>? extensionDevelopmentKind;
  final String? extensionEnvironment; // JSON-stringified Record<string, string> object
  final String? inspectExtensions; // 'inspect-extensions'
  final String? inspectBrkExtensions; // 'inspect-brk-extensions'
  final String? debugId;
  final bool? debugRenderer; // whether we expect a debugger (js-debug) to attach to the renderer, incl webviews+webworker
  final String? inspectPtyhost; // 'inspect-ptyhost'
  final String? inspectBrkPtyhost; // 'inspect-brk-ptyhost'
  final String? inspectAgenthost; // 'inspect-agenthost'
  final String? inspectBrkAgenthost; // 'inspect-brk-agenthost'
  final String? inspectSharedprocess; // 'inspect-sharedprocess'
  final String? inspectBrkSharedprocess; // 'inspect-brk-sharedprocess'
  final bool? disableExtensions; // 'disable-extensions'
  final List<String>? disableExtension; // undefined or array of 1 or more
  final bool? listExtensions; // 'list-extensions'
  final bool? showVersions; // 'show-versions'
  final String? category;
  final List<String>? installExtension; // undefined or array of 1 or more
  final bool? preRelease; // 'pre-release'
  final List<String>? installBuiltinExtension; // undefined or array of 1 or more
  final List<String>? uninstallExtension; // undefined or array of 1 or more
  final bool? updateExtensions; // 'update-extensions'
  final bool? doNotIncludePackDependencies; // 'do-not-include-pack-dependencies'
  final List<String>? locateExtension; // undefined or array of 1 or more
  final List<String>? enableProposedApi; // undefined or array of 1 or more
  final bool? openUrl; // 'open-url'
  final bool? skipReleaseNotes; // 'skip-release-notes'
  final bool? skipWelcome; // 'skip-welcome'
  final String? exportDefaultConfiguration; // 'export-default-configuration'
  final String? exportPolicyData; // 'export-policy-data'
  final String? exportDefaultKeybindings; // 'export-default-keybindings'
  final String? installSource; // 'install-source'
  final List<String>? addMcp; // 'add-mcp'
  final bool? disableUpdates; // 'disable-updates'
  final bool? shareSecretsWithAgentsApp; // 'share-secrets-with-agents-app'
  final bool? transient;
  final bool? useInmemorySecretstorage; // 'use-inmemory-secretstorage'
  final String? passwordStore; // 'password-store'
  final bool? disableWorkspaceTrust; // 'disable-workspace-trust'
  final bool? disableCrashReporter; // 'disable-crash-reporter'
  final String? crashReporterDirectory; // 'crash-reporter-directory'
  final String? crashReporterId; // 'crash-reporter-id'
  final bool? skipAddToRecentlyOpened; // 'skip-add-to-recently-opened'
  final bool? fileWrite; // 'file-write'
  final bool? fileChmod; // 'file-chmod'
  final bool? enableSmokeTestDriver; // 'enable-smoke-test-driver'
  final bool? skipSessionsWelcome; // 'skip-sessions-welcome'
  final String? remote;
  final bool? force;
  final bool? doNotSync; // 'do-not-sync'
  final bool? preserveEnv; // 'preserve-env'
  final bool? forceUserEnv; // 'force-user-env'
  final bool? forceDisableUserEnv; // 'force-disable-user-env'
  final String? sync;
  final String? logsPath;
  final bool? enableFilePolicy; // '__enable-file-policy'
  final String? editSessionId;
  final String? continueOn;
  final String? locateShellIntegrationPath; // 'locate-shell-integration-path'
  final String? profile;
  final bool? profileTemp; // 'profile-temp'
  final bool? disableChromiumSandbox; // 'disable-chromium-sandbox'
  final bool? sandbox;
  final bool? enableCoi; // 'enable-coi'
  final String? unresponsiveSampleInterval; // 'unresponsive-sample-interval'
  final String? unresponsiveSamplePeriod; // 'unresponsive-sample-period'
  final bool? enableRdpDisplayTracking; // 'enable-rdp-display-tracking'
  final bool? disableLayoutRestore; // 'disable-layout-restore'
  final bool? disableExperiments; // 'disable-experiments'
  final bool? noProxyServer; // 'no-proxy-server'
  final bool? noSandbox; // 'no-sandbox'
  final String? proxyServer; // 'proxy-server'
  final String? proxyBypassList; // 'proxy-bypass-list'
  final String? proxyPacUrl; // 'proxy-pac-url'
  final String? inspect;
  final String? inspectBrk; // 'inspect-brk'
  final String? jsFlags; // 'js-flags'
  final bool? disableLcdText; // 'disable-lcd-text'
  final bool? disableGpu; // 'disable-gpu'
  final bool? disableGpuSandbox; // 'disable-gpu-sandbox'
  final bool? nolazy;
  final String? forceDeviceScaleFactor; // 'force-device-scale-factor'
  final bool? forceRendererAccessibility; // 'force-renderer-accessibility'
  final bool? ignoreCertificateErrors; // 'ignore-certificate-errors'
  final bool? allowInsecureLocalhost; // 'allow-insecure-localhost'
  final String? logNetLog; // 'log-net-log'
  final String? vmodule;
  final bool? disableDevShmUsage; // 'disable-dev-shm-usage'
  final String? ozonePlatform; // 'ozone-platform'
  final String? enableTracing; // 'enable-tracing'
  final String? traceStartupFormat; // 'trace-startup-format'
  final String? traceStartupFile; // 'trace-startup-file'
  final String? traceStartupDuration; // 'trace-startup-duration'
  final String? xdgPortalRequiredVersion; // 'xdg-portal-required-version'
  NativeParsedArgs({
    this.cliDataDir,
    this.disableTelemetry,
    this.telemetryLevel,
    this.serveWeb,
    this.agent,
    this.underscore,
    this.folderUri,
    this.fileUri,
    this.urls,
    this.help,
    this.version,
    this.telemetry,
    this.status,
    this.wait,
    this.waitMarkerFilePath,
    this.diff,
    this.merge,
    this.add,
    this.remove,
    this.goto,
    this.newWindow,
    this.reuseWindow,
    this.agents,
    this.sessionTitleBase64,
    this.locale,
    this.userDataDir,
    this.profStartup,
    this.profStartupPrefix,
    this.profAppendTimers,
    this.profDurationMarkers,
    this.profDurationMarkersFile,
    this.profV8Extensions,
    this.noCachedData,
    this.verbose,
    this.trace,
    this.traceMemoryInfra,
    this.traceCategoryFilter,
    this.traceOptions,
    this.openDevtools,
    this.log,
    this.logExtensionHostCommunication,
    this.extensionsDir,
    this.extensionsDownloadDir,
    this.builtinExtensionsDir,
    this.sharedDataDir,
    this.agentPluginsDir,
    this.agentsUserDataDir,
    this.agentsExtensionsDir,
    this.extensionDevelopmentPath,
    this.extensionTestsPath,
    this.hiddenWindow,
    this.extensionDevelopmentKind,
    this.extensionEnvironment,
    this.inspectExtensions,
    this.inspectBrkExtensions,
    this.debugId,
    this.debugRenderer,
    this.inspectPtyhost,
    this.inspectBrkPtyhost,
    this.inspectAgenthost,
    this.inspectBrkAgenthost,
    this.inspectSharedprocess,
    this.inspectBrkSharedprocess,
    this.disableExtensions,
    this.disableExtension,
    this.listExtensions,
    this.showVersions,
    this.category,
    this.installExtension,
    this.preRelease,
    this.installBuiltinExtension,
    this.uninstallExtension,
    this.updateExtensions,
    this.doNotIncludePackDependencies,
    this.locateExtension,
    this.enableProposedApi,
    this.openUrl,
    this.skipReleaseNotes,
    this.skipWelcome,
    this.exportDefaultConfiguration,
    this.exportPolicyData,
    this.exportDefaultKeybindings,
    this.installSource,
    this.addMcp,
    this.disableUpdates,
    this.shareSecretsWithAgentsApp,
    this.transient,
    this.useInmemorySecretstorage,
    this.passwordStore,
    this.disableWorkspaceTrust,
    this.disableCrashReporter,
    this.crashReporterDirectory,
    this.crashReporterId,
    this.skipAddToRecentlyOpened,
    this.fileWrite,
    this.fileChmod,
    this.enableSmokeTestDriver,
    this.skipSessionsWelcome,
    this.remote,
    this.force,
    this.doNotSync,
    this.preserveEnv,
    this.forceUserEnv,
    this.forceDisableUserEnv,
    this.sync,
    this.logsPath,
    this.enableFilePolicy,
    this.editSessionId,
    this.continueOn,
    this.locateShellIntegrationPath,
    this.profile,
    this.profileTemp,
    this.disableChromiumSandbox,
    this.sandbox,
    this.enableCoi,
    this.unresponsiveSampleInterval,
    this.unresponsiveSamplePeriod,
    this.enableRdpDisplayTracking,
    this.disableLayoutRestore,
    this.disableExperiments,
    this.noProxyServer,
    this.noSandbox,
    this.proxyServer,
    this.proxyBypassList,
    this.proxyPacUrl,
    this.inspect,
    this.inspectBrk,
    this.jsFlags,
    this.disableLcdText,
    this.disableGpu,
    this.disableGpuSandbox,
    this.nolazy,
    this.forceDeviceScaleFactor,
    this.forceRendererAccessibility,
    this.ignoreCertificateErrors,
    this.allowInsecureLocalhost,
    this.logNetLog,
    this.vmodule,
    this.disableDevShmUsage,
    this.ozonePlatform,
    this.enableTracing,
    this.traceStartupFormat,
    this.traceStartupFile,
    this.traceStartupDuration,
    this.xdgPortalRequiredVersion,
  });
}
