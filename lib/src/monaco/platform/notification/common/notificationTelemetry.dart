// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/notification/common/notificationTelemetry.ts
// Translated 1:1. TypeScript `enum` -> Dart `enum`. `WeakMap` -> HashMap.identity()
// (Dart has no weak refs). `Symbol` brand -> opaque sentinel object stored on a
// branded carrier class. `Object.freeze` -> immutable final field classes.
// Runtime truth: tool/ts2dart/_batch151_truth.cjs (real transpiled source).
// ---------------------------------------------------------------------------

import 'dart:collection' show HashMap;

import '../../../base/common/actions.dart' show IAction;
import '../../extensionManagement/common/extensionManagement.dart'
    show EXTENSION_IDENTIFIER_REGEX;

/// 1:1: `export enum NotificationTelemetryId`.
enum NotificationTelemetryId {
  AgentHostProgress('agentHost.progress'),
  AuthenticationSignIn('authentication.signIn'),
  AuthenticationContinue('authentication.continue'),
  ExtensionsActivation('extensions.activation'),
  ExtensionInstall('extensions.install'),
  ExtensionDownload('extensions.downloadVsix'),
  ExtensionDownloadComplete('extensions.downloadVsix.complete'),
  ExtensionDownloadError('extensions.downloadVsix.error'),
  ExtensionsDisabled('extensions.disabled'),
  ExtensionDependencyLoop('extensions.dependencyLoop'),
  ExtensionsAutoRestart('extensions.autoRestart'),
  ExtensionHostUnresponsive('extensions.host.unresponsive'),
  ExtensionHostVersionMismatch('extensions.host.versionMismatch'),
  ExtensionHostCrashRepeated('extensions.host.crashRepeated'),
  RemoteExtensionHostCrashRepeated('extensions.remoteHost.crashRepeated'),
  RemoteReconnect('remote.reconnect'),
  RemoteAgentHostSSHConnect('remoteAgentHost.ssh.connect'),
  RemoteAgentHostSSHConnectError('remoteAgentHost.ssh.connectError'),
  RemoteAgentHostTunnelConnect('remoteAgentHost.tunnel.connect'),
  RemoteAgentHostTunnelConnectError('remoteAgentHost.tunnel.connectError'),
  RemoteAgentHostTunnelAuthenticationError('remoteAgentHost.tunnel.authenticationError'),
  RemoteAgentHostWSLConnect('remoteAgentHost.wsl.connect'),
  RemoteAgentHostWSLConnectError('remoteAgentHost.wsl.connectError'),
  RemoteAgentHostUpdate('remoteAgentHost.update'),
  RemoteAgentHostReconnect('remoteAgentHost.reconnect'),
  PluginPackageOperation('plugins.packageOperation'),
  PluginUpdate('plugins.update'),
  PluginRepositoryClone('plugins.repository.clone'),
  PluginRepositoryUpdate('plugins.repository.update'),
  PluginRepositoryRepair('plugins.repository.repair'),
  PluginManagedRetry('plugins.managed.retry'),
  PluginManagedRetryComplete('plugins.managed.retry.complete'),
  PluginManagedRetryError('plugins.managed.retry.error'),
  CustomizationMigration('customizations.migration'),
  DictationModelPrepare('dictation.model.prepare'),
  DictationModelImport('dictation.model.import'),
  FileSaveParticipants('files.saveParticipants'),
  WorkingCopySaveParticipants('files.workingCopySaveParticipants'),
  FileOperationParticipants('files.operationParticipants'),
  UpdateOutdatedBuildReminder('update.outdatedBuildReminder');

  const NotificationTelemetryId(this.value);
  final String value;
}

/// 1:1: `export enum NotificationActionTelemetryId`.
enum NotificationActionTelemetryId {
  ProgressCancel('progress.cancel'),
  ManageExtension('manageExtension'),
  NeverShowAgain('neverShowAgain'),
  Reload('reload'),
  Relaunch('relaunch'),
  RestartExtensionHost('restartExtensionHost'),
  Continue('continue'),
  Decline('decline'),
  Copy('copy'),
  Configure('configure');

  const NotificationActionTelemetryId(this.value);
  final String value;
}

/// 1:1: `export enum ExtensionNotificationTelemetryId`.
enum ExtensionNotificationTelemetryId {
  GitHubSignInBrowser('githubAuthentication.signIn.browser'),
  GitHubSignInDeviceCode('githubAuthentication.signIn.deviceCode'),
  GitHubSignInRetryAfterCancel('githubAuthentication.signIn.retryAfterCancel'),
  GitHubSignInRetryAfterFailure('githubAuthentication.signIn.retryAfterFailure'),
  GitHubSignInFailed('githubAuthentication.signIn.failed'),
  GitHubSignOutFailed('githubAuthentication.signOut.failed'),
  GitHubEnterpriseInvalidUri('githubAuthentication.enterprise.invalidUri'),
  GitHubEnterpriseUpdateFailed('githubAuthentication.enterprise.updateFailed'),
  GitHubEnterpriseInitializationFailed('githubAuthentication.enterprise.initializationFailed'),
  GitMissing('git.missing'),
  GitLegacyVersion('git.legacyVersion'),
  GitWindowsVersion('git.windowsVersion'),
  GitParentRepository('git.parentRepository'),
  GitUnsafeRepository('git.unsafeRepository'),
  GitSubmoduleLimit('git.submoduleLimit'),
  GitWorktreeLimit('git.worktreeLimit'),
  GitAutoFetch('git.autoFetch'),
  TypeScriptWorkspaceVersion('typescript.workspaceVersion'),
  TypeScriptWorkspaceNode('typescript.workspaceNode'),
  TypeScriptNativePreview('typescript.nativePreview'),
  TypeScriptInvalidServerPath('typescript.invalidServerPath');

  const ExtensionNotificationTelemetryId(this.value);
  final String value;
}

/// 1:1: `const extensionNotificationIds = new Map<string, ...>([...])`.
final Map<String, List<ExtensionNotificationTelemetryId>> extensionNotificationIds =
    <String, List<ExtensionNotificationTelemetryId>>{
  'vscode.github-authentication/message': <ExtensionNotificationTelemetryId>[
    ExtensionNotificationTelemetryId.GitHubSignInRetryAfterCancel,
    ExtensionNotificationTelemetryId.GitHubSignInRetryAfterFailure,
    ExtensionNotificationTelemetryId.GitHubSignInFailed,
    ExtensionNotificationTelemetryId.GitHubSignOutFailed,
    ExtensionNotificationTelemetryId.GitHubEnterpriseInvalidUri,
    ExtensionNotificationTelemetryId.GitHubEnterpriseUpdateFailed,
    ExtensionNotificationTelemetryId.GitHubEnterpriseInitializationFailed,
  ],
  'vscode.github-authentication/progress': <ExtensionNotificationTelemetryId>[
    ExtensionNotificationTelemetryId.GitHubSignInBrowser,
    ExtensionNotificationTelemetryId.GitHubSignInDeviceCode,
  ],
  'vscode.git/message': <ExtensionNotificationTelemetryId>[
    ExtensionNotificationTelemetryId.GitMissing,
    ExtensionNotificationTelemetryId.GitLegacyVersion,
    ExtensionNotificationTelemetryId.GitWindowsVersion,
    ExtensionNotificationTelemetryId.GitParentRepository,
    ExtensionNotificationTelemetryId.GitUnsafeRepository,
    ExtensionNotificationTelemetryId.GitSubmoduleLimit,
    ExtensionNotificationTelemetryId.GitWorktreeLimit,
    ExtensionNotificationTelemetryId.GitAutoFetch,
  ],
  'vscode.typescript-language-features/message': <ExtensionNotificationTelemetryId>[
    ExtensionNotificationTelemetryId.TypeScriptWorkspaceVersion,
    ExtensionNotificationTelemetryId.TypeScriptWorkspaceNode,
    ExtensionNotificationTelemetryId.TypeScriptNativePreview,
    ExtensionNotificationTelemetryId.TypeScriptInvalidServerPath,
  ],
};

/// 1:1: `const extensionTelemetryBrand = Symbol('extensionNotificationTelemetry')`.
/// Dart has no symbol-keyed properties; the brand is an opaque token held by the
/// [IExtensionNotificationTelemetry] carrier, sufficient to distinguish identity.
final Object extensionTelemetryBrand = Object();

/// 1:1: `export interface IExtensionNotificationTelemetry`.
/// Frozen carrier with the brand marker.
class IExtensionNotificationTelemetry {
  IExtensionNotificationTelemetry._(this._brand);
  factory IExtensionNotificationTelemetry() =>
      IExtensionNotificationTelemetry._(extensionTelemetryBrand);

  /// 1:1: `readonly [extensionTelemetryBrand]: true`.
  final Object _brand;
  bool get branded => identical(_brand, extensionTelemetryBrand);

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

/// 1:1: `export type NotificationTelemetry = NotificationTelemetryId |
/// IExtensionNotificationTelemetry`.
typedef NotificationTelemetry = Object;

/// 1:1: `export interface INotificationTelemetrySource`.
class INotificationTelemetrySource {
  const INotificationTelemetrySource({
    required this.origin,
    required this.notificationId,
    required this.extensionId,
  });

  /// `'core' | 'extension' | 'unknown'`.
  final String origin;

  /// NotificationTelemetryId | ExtensionNotificationTelemetryId | ... | 'unknown'.
  final String notificationId;
  final String extensionId;
}

/// 1:1: `const notificationIds = new Set<string>(Object.values(...))`.
final Set<String> notificationIds =
    NotificationTelemetryId.values.map((e) => e.value).toSet();

/// 1:1: `const actionIds = new Set<string>(Object.values(...))`.
final Set<String> actionIds =
    NotificationActionTelemetryId.values.map((e) => e.value).toSet();

/// 1:1: `const extensionSources = new WeakMap<...>()`.
final Map<IExtensionNotificationTelemetry, INotificationTelemetrySource>
    extensionSources =
    HashMap<IExtensionNotificationTelemetry, INotificationTelemetrySource>.identity();

/// 1:1: `const unknownSource = Object.freeze({...})`.
const INotificationTelemetrySource unknownSource = INotificationTelemetrySource(
  origin: 'unknown',
  notificationId: 'unknown',
  extensionId: 'unknown',
);

/// 1:1: `export function extensionNotificationTelemetry(extensionId, kind, notificationId?)`.
IExtensionNotificationTelemetry extensionNotificationTelemetry(
  String? extensionId,
  String kind, [
  String? notificationId,
]) {
  final IExtensionNotificationTelemetry telemetry =
      IExtensionNotificationTelemetry();
  final String source =
      extensionId is String && extensionId.length <= 255 && EXTENSION_IDENTIFIER_REGEX.hasMatch(extensionId)
          ? extensionId.toLowerCase()
          : 'unknown';
  final List<ExtensionNotificationTelemetryId>? ids =
      extensionNotificationIds['$source/$kind'];
  final String resolvedNotificationId;
  final String? matched = ids == null
      ? null
      : ids
          .map((id) => id.value)
          .cast<String?>()
          .firstWhere((id) => id == notificationId, orElse: () => null);
  if (matched != null) {
    resolvedNotificationId = matched;
  } else {
    resolvedNotificationId =
        kind == 'message' ? 'extension.message' : 'extension.progress';
  }
  extensionSources[telemetry] = INotificationTelemetrySource(
    origin: 'extension',
    notificationId: resolvedNotificationId,
    extensionId: source,
  );
  return telemetry;
}

/// 1:1: `export function getNotificationTelemetrySource(telemetry?)`.
INotificationTelemetrySource getNotificationTelemetrySource(
    NotificationTelemetry? telemetry) {
  // TS string enums are plain strings at runtime; in Dart an enum value carries
  // its `.value`, so accept both forms.
  final Object? t = telemetry is NotificationTelemetryId
      ? telemetry.value
      : telemetry;
  if (t is String && notificationIds.contains(t)) {
    return INotificationTelemetrySource(
      origin: 'core',
      notificationId: t,
      extensionId: 'none',
    );
  }
  if (telemetry is IExtensionNotificationTelemetry) {
    return extensionSources[telemetry] ?? unknownSource;
  }
  return unknownSource;
}

/// 1:1: `export type NotificationActionTelemetry = NotificationActionTelemetryId |
/// { readonly extensionButtonIndex: number }`.
typedef NotificationActionTelemetry = Object;

/// 1:1: `const actionTelemetry = new WeakMap<IAction, NotificationActionTelemetry>()`.
final Map<IAction, NotificationActionTelemetry> actionTelemetry =
    HashMap<IAction, NotificationActionTelemetry>.identity();

/// TS `Number.isSafeInteger(n)`: n is an integer within ±(2^53 - 1).
bool _isSafeInteger(Object? n) {
  if (n is! num) return false;
  if (n is double && !n.isFinite) return false;
  if (n != n.truncate()) return false;
  const int maxSafe = 0x1FFFFFFFFFFFFF; // 2^53 - 1
  return n >= -maxSafe && n <= maxSafe;
}

/// 1:1: `export function withNotificationActionTelemetry<T extends IAction>`.
T withNotificationActionTelemetry<T extends IAction>(
  T action,
  NotificationActionTelemetry? telemetry,
) {
  final Object? tel = telemetry is NotificationActionTelemetryId
      ? telemetry.value
      : telemetry;
  if (tel is String && actionIds.contains(tel)) {
    actionTelemetry[action] = tel;
  } else if (tel is Map &&
      _isSafeInteger(tel['extensionButtonIndex']) &&
      (tel['extensionButtonIndex'] as num) >= 0 &&
      (tel['extensionButtonIndex'] as num) <= 1000) {
    actionTelemetry[action] = <String, Object?>{
      'extensionButtonIndex': tel['extensionButtonIndex'],
    };
  }
  return action;
}

/// 1:1: `export function getNotificationActionTelemetry(action)`.
NotificationActionTelemetry? getNotificationActionTelemetry(IAction action) =>
    actionTelemetry[action];
