// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/workspace/common/workspaceTrust.ts
// Translated 1:1 from TypeScript. Pure declarations: two enums (one `const
// enum`) -> classes of static const ints, and three service const/interface
// pairs -> const keeps the name, interface gets the `Type` suffix.
// `Promise<void>` -> Future<void>, `Event<T>` -> the already-ported Event<T>.
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export enum WorkspaceTrustScope { Local = 0, Remote = 1 }`
class WorkspaceTrustScope {
  static const int Local = 0;
  static const int Remote = 1;
}

/// 1:1: `export interface WorkspaceTrustRequestButton`
abstract class WorkspaceTrustRequestButton {
  String get label;

  /// TS `'ContinueWithTrust' | 'ContinueWithoutTrust' | 'Manage' | 'Cancel'`.
  String get type;
}

/// 1:1: `export interface ResourceTrustRequestOptions`
abstract class ResourceTrustRequestOptions {
  URI get uri;
  String? get message;
  String? get remoteHostLabel;
}

/// 1:1: `export interface WorkspaceTrustRequestOptions`
abstract class WorkspaceTrustRequestOptions {
  List<WorkspaceTrustRequestButton>? get buttons;
  String? get message;
}

/// 1:1: `export const IWorkspaceTrustEnablementService = createDecorator(...)`
final ServiceIdentifier<IWorkspaceTrustEnablementServiceType>
    IWorkspaceTrustEnablementService =
    createDecorator<IWorkspaceTrustEnablementServiceType>(
        'workspaceTrustEnablementService');

/// 1:1: `export interface IWorkspaceTrustEnablementService`
abstract class IWorkspaceTrustEnablementServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  bool isWorkspaceTrustEnabled();
}

/// 1:1: `export const IWorkspaceTrustManagementService = createDecorator(...)`
final ServiceIdentifier<IWorkspaceTrustManagementServiceType>
    IWorkspaceTrustManagementService =
    createDecorator<IWorkspaceTrustManagementServiceType>(
        'workspaceTrustManagementService');

/// 1:1: `export interface IWorkspaceTrustManagementService`
abstract class IWorkspaceTrustManagementServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<bool> get onDidChangeTrust;
  Event<void> get onDidChangeTrustedFolders;
  Future<void> get workspaceResolved;
  Future<void> get workspaceTrustInitialized;
  bool get acceptsOutOfWorkspaceFiles;
  set acceptsOutOfWorkspaceFiles(bool value);

  bool isWorkspaceTrusted();
  bool isWorkspaceTrustForced();

  bool canSetParentFolderTrust();
  Future<void> setParentFolderTrust(bool trusted);

  bool canSetWorkspaceTrust();
  Future<void> setWorkspaceTrust(bool trusted);

  bool isWorkspaceTrustSourceResolved();
  Future<void> resolveWorkspaceTrust();

  /// Rechecks changed source providers, returning untrusted if no stable source can be verified.
  Future<IWorkspaceTrustUriInfo> getUriTrustInfo(URI uri);

  /// Uses saved virtual identities directly; rejects if a required source provider changes before updating approvals.
  Future<void> setUrisTrust(List<URI> uri, bool trusted);

  /// Automatically trusts an exact scheme and authority for the registration's lifetime, without persisting user trust.
  IDisposable registerTrustedAuthority(String scheme, String authority);

  List<URI> getTrustedUris();

  /// Preserves unchanged approvals; rejects if a newly resolved source's provider changes before persistence.
  Future<void> setTrustedUris(List<URI> uris);

  IDisposable addWorkspaceTrustTransitionParticipant(
      IWorkspaceTrustTransitionParticipant participant);
}

/// 1:1: `export const enum WorkspaceTrustUriResponse`
class WorkspaceTrustUriResponse {
  static const int Open = 1;
  static const int OpenInNewWindow = 2;
  static const int Cancel = 3;
}

/// 1:1: `export const IWorkspaceTrustRequestService = createDecorator(...)`
final ServiceIdentifier<IWorkspaceTrustRequestServiceType>
    IWorkspaceTrustRequestService =
    createDecorator<IWorkspaceTrustRequestServiceType>(
        'workspaceTrustRequestService');

/// 1:1: `export interface IWorkspaceTrustRequestService`
abstract class IWorkspaceTrustRequestServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<void> get onDidInitiateOpenFilesTrustRequest;
  Event<WorkspaceTrustRequestOptions?> get onDidInitiateWorkspaceTrustRequest;
  Event<void> get onDidInitiateWorkspaceTrustRequestOnStartup;
  Event<ResourceTrustRequestOptions> get onDidInitiateResourcesTrustRequest;

  /// TS const enum value is a number at runtime -> Dart `int` at type positions.
  Future<void> completeOpenFilesTrustRequest(int result, [bool? saveResponse]);
  Future<int> requestOpenFilesTrust(List<URI> openFiles);

  Future<void> completeResourcesTrustRequest(URI uri, int result);
  Future<bool?> requestResourcesTrust(ResourceTrustRequestOptions options);

  void cancelWorkspaceTrustRequest();
  Future<void> completeWorkspaceTrustRequest([bool? trusted]);
  Future<bool?> requestWorkspaceTrust([WorkspaceTrustRequestOptions? options]);
  void requestWorkspaceTrustOnStartup();
}

/// 1:1: `export interface IWorkspaceTrustTransitionParticipant`
abstract class IWorkspaceTrustTransitionParticipant {
  Future<void> participate(bool trusted);
}

/// 1:1: `export interface IWorkspaceTrustUriInfo`
abstract class IWorkspaceTrustUriInfo {
  URI get uri;
  bool get trusted;
}

/// 1:1: `export interface IWorkspaceTrustInfo`
abstract class IWorkspaceTrustInfo {
  List<IWorkspaceTrustUriInfo> get uriTrustInfo;
}
