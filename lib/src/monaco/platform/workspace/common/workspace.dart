// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/workspace/common/workspace.ts
// Translated 1:1. `const enum` -> class of static const ints; TS object-literal
// structural types (workspace identifiers) -> Map<String, Object?> carriers;
// union `IAnyWorkspaceIdentifier` -> Object carrier; TS overload signatures
// are documented verbatim and share the single real implementation (as in TS).
// Runtime truth: tool/ts2dart/_workspace_truth.cjs (recursive TS transpile+vm,
// real uri.ts / resources.ts / ternarySearchTree.ts / path.ts / network.ts).
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../base/common/event.dart' show Event;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/path.dart' show basename, extname;
import '../../../base/common/resources.dart'
    show basenameOrAuthority, joinPath, extUriBiasedIgnorePathCase;
import '../../../base/common/resources.dart' as resources show extname;
import '../../../base/common/ternarySearchTree.dart' show TernarySearchTree;
import '../../../base/common/uri.dart' show URI, UriComponents;
import '../../../nls.dart' show localize;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../environment/common/environment.dart' show IEnvironmentServiceType;

/// JS truthiness for `if (x)` on identifier ids.
bool _jsTruthy(Object? v) => v != null && v != false && v != 0 && v != '';

/// 1:1: `export const IWorkspaceContextService = createDecorator<IWorkspaceContextService>('contextService')`
final ServiceIdentifier<IWorkspaceContextServiceType> IWorkspaceContextService =
    createDecorator<IWorkspaceContextServiceType>('contextService');

/// 1:1: `export interface IWorkspaceContextService`
abstract class IWorkspaceContextServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// An event which fires on workbench state changes.
  Event<int> get onDidChangeWorkbenchState;

  /// An event which fires on workspace name changes.
  Event<void> get onDidChangeWorkspaceName;

  /// An event which fires before workspace folders change.
  Event<IWorkspaceFoldersWillChangeEvent> get onWillChangeWorkspaceFolders;

  /// An event which fires on workspace folders change.
  Event<IWorkspaceFoldersChangeEvent> get onDidChangeWorkspaceFolders;

  /// Provides access to the complete workspace object.
  Future<IWorkspace> getCompleteWorkspace();

  /// Provides access to the workspace object the window is running with.
  IWorkspace getWorkspace();

  /// Return the state of the workbench (EMPTY / FOLDER / WORKSPACE).
  int getWorkbenchState();

  /// Returns the folder for the given resource from the workspace.
  IWorkspaceFolder? getWorkspaceFolder(URI resource);

  /// Return `true` if the current workspace has the given identifier or root URI.
  bool isCurrentWorkspace(Object workspaceIdOrFolder);

  /// Returns if the provided resource is inside the workspace or not.
  bool isInsideWorkspace(URI resource);

  /// Return `true` if the current workspace has data that can be sent to the extension host.
  bool hasWorkspaceData();
}

/// 1:1: `export interface IResolvedWorkspace extends IWorkspaceIdentifier, IBaseWorkspace`
abstract class IResolvedWorkspace
    implements IWorkspaceIdentifier, IBaseWorkspace {
  List<IWorkspaceFolder> get folders;
}

/// 1:1: `export interface IBaseWorkspace`
abstract class IBaseWorkspace {
  String? get remoteAuthority;
  bool? get transient;
}

/// 1:1: `export interface IBaseWorkspaceIdentifier`
abstract class IBaseWorkspaceIdentifier {
  String get id;
}

/// 1:1: `export interface ISingleFolderWorkspaceIdentifier`
abstract class ISingleFolderWorkspaceIdentifier
    implements IBaseWorkspaceIdentifier {
  URI get uri;
}

/// 1:1: `export interface IWorkspaceIdentifier`
abstract class IWorkspaceIdentifier implements IBaseWorkspaceIdentifier {
  URI get configPath;
}

/// 1:1: `export interface IEmptyWorkspaceIdentifier`
abstract class IEmptyWorkspaceIdentifier implements IBaseWorkspaceIdentifier {}

/// 1:1: `export type IAnyWorkspaceIdentifier = IWorkspaceIdentifier | ISingleFolderWorkspaceIdentifier | IEmptyWorkspaceIdentifier`
typedef IAnyWorkspaceIdentifier = Object;

/// 1:1: `export function isSingleFolderWorkspaceIdentifier(obj: unknown): obj is ISingleFolderWorkspaceIdentifier`
bool isSingleFolderWorkspaceIdentifier(Object? obj) {
  final singleFolderIdentifier = obj is Map ? obj : null;
  return singleFolderIdentifier != null &&
      singleFolderIdentifier['id'] is String &&
      URI.isUri(singleFolderIdentifier['uri']);
}

/// 1:1: `export function isEmptyWorkspaceIdentifier(obj: unknown): obj is IEmptyWorkspaceIdentifier`
bool isEmptyWorkspaceIdentifier(Object? obj) {
  final emptyWorkspaceIdentifier = obj is Map ? obj : null;
  return emptyWorkspaceIdentifier != null &&
      emptyWorkspaceIdentifier['id'] is String &&
      !isSingleFolderWorkspaceIdentifier(obj) &&
      !isWorkspaceIdentifier(obj);
}

/// 1:1: `export const EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE: IEmptyWorkspaceIdentifier = { id: 'ext-dev' }`
const Map<String, Object?> EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE =
    <String, Object?>{'id': 'ext-dev'};

/// 1:1: `export const UNKNOWN_EMPTY_WINDOW_WORKSPACE: IEmptyWorkspaceIdentifier = { id: 'empty-window' }`
const Map<String, Object?> UNKNOWN_EMPTY_WINDOW_WORKSPACE =
    <String, Object?>{'id': 'empty-window'};

/// 1:1 overloads:
///   toWorkspaceIdentifier(workspace: IWorkspace): IAnyWorkspaceIdentifier
///   toWorkspaceIdentifier(backupPath: string | undefined, isExtensionDevelopment: boolean): IEmptyWorkspaceIdentifier
/// 1:1: `export function toWorkspaceIdentifier(arg0, isExtensionDevelopment?): IAnyWorkspaceIdentifier`
Map<String, Object?> toWorkspaceIdentifier(Object? arg0,
    [bool? isExtensionDevelopment]) {
  // Empty workspace
  if (arg0 is String || arg0 == null) {
    // With a backupPath, the basename is the empty workspace identifier
    if (arg0 is String) {
      return <String, Object?>{'id': basename(arg0)};
    }
    // Extension development empty windows have backups disabled
    if (isExtensionDevelopment ?? false) {
      return EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE;
    }
    return UNKNOWN_EMPTY_WINDOW_WORKSPACE;
  }

  final workspace = arg0 as IWorkspace;
  if (workspace.configuration != null) {
    return <String, Object?>{
      'id': workspace.id,
      'configPath': workspace.configuration
    };
  }
  if (workspace.uri != null) {
    return <String, Object?>{'id': workspace.id, 'uri': workspace.uri};
  }
  return <String, Object?>{'id': workspace.id};
}

/// 1:1: `export function isWorkspaceIdentifier(obj: unknown): obj is IWorkspaceIdentifier`
bool isWorkspaceIdentifier(Object? obj) {
  final workspaceIdentifier = obj is Map ? obj : null;
  return workspaceIdentifier != null &&
      workspaceIdentifier['id'] is String &&
      URI.isUri(workspaceIdentifier['configPath']);
}

/// 1:1: `export interface ISerializedSingleFolderWorkspaceIdentifier`
abstract class ISerializedSingleFolderWorkspaceIdentifier
    implements IBaseWorkspaceIdentifier {
  UriComponents get uri;
}

/// 1:1: `export interface ISerializedWorkspaceIdentifier`
abstract class ISerializedWorkspaceIdentifier
    implements IBaseWorkspaceIdentifier {
  UriComponents get configPath;
}

/// 1:1 overloads:
///   reviveIdentifier(identifier: undefined): undefined
///   reviveIdentifier(identifier: ISerializedWorkspaceIdentifier): IWorkspaceIdentifier
///   reviveIdentifier(identifier: ISerializedSingleFolderWorkspaceIdentifier): ISingleFolderWorkspaceIdentifier
///   reviveIdentifier(identifier: IEmptyWorkspaceIdentifier): IEmptyWorkspaceIdentifier
///   reviveIdentifier(identifier: ...): IAnyWorkspaceIdentifier | undefined
/// 1:1: `export function reviveIdentifier(identifier): IAnyWorkspaceIdentifier | undefined`
Map<String, Object?>? reviveIdentifier(Object? identifier) {
  final candidate = identifier is Map ? identifier : null;

  // Single Folder
  if (candidate != null && candidate['uri'] != null) {
    return <String, Object?>{
      'id': candidate['id'],
      'uri': URI.revive(candidate['uri'])
    };
  }

  // Multi folder
  if (candidate != null && candidate['configPath'] != null) {
    return <String, Object?>{
      'id': candidate['id'],
      'configPath': URI.revive(candidate['configPath'])
    };
  }

  // Empty — TS `if (identifier?.id)` is a truthiness check (empty string is falsy)
  if (candidate != null && _jsTruthy(candidate['id'])) {
    return <String, Object?>{'id': candidate['id']};
  }

  return null;
}

/// 1:1: `export const enum WorkbenchState { EMPTY = 1, FOLDER, WORKSPACE }`
class WorkbenchState {
  static const int EMPTY = 1;
  static const int FOLDER = 2;
  static const int WORKSPACE = 3;
}

/// 1:1: `export interface IWorkspaceFoldersWillChangeEvent`
abstract class IWorkspaceFoldersWillChangeEvent {
  IWorkspaceFoldersChangeEvent get changes;
  bool get fromCache;
  bool? get isFolderLocationChange;
  void join(Future<void> promise);
}

/// 1:1: `export interface IWorkspaceFoldersChangeEvent`
abstract class IWorkspaceFoldersChangeEvent {
  List<IWorkspaceFolder> get added;
  List<IWorkspaceFolder> get removed;
  List<IWorkspaceFolder> get changed;
}

/// 1:1: `export interface IWorkspace`
abstract class IWorkspace {
  String get id;
  URI? get uri;
  List<IWorkspaceFolder> get folders;
  bool? get transient;
  URI? get configuration;
  String? get name;
}

/// 1:1: `export function isWorkspace(thing: unknown): thing is IWorkspace`
bool isWorkspace(Object? thing) {
  final candidate = thing is Map ? thing : null;
  return candidate != null &&
      candidate['id'] is String &&
      candidate['folders'] is List;
}

/// 1:1: `export interface IWorkspaceFolderData`
abstract class IWorkspaceFolderData {
  URI get uri;
  String get name;
  num get index;
}

/// 1:1: `export interface IWorkspaceFolder extends IWorkspaceFolderData`
abstract class IWorkspaceFolder implements IWorkspaceFolderData {
  URI toResource(String relativePath);
}

/// 1:1: `export function isWorkspaceFolder(thing: unknown): thing is IWorkspaceFolder`
/// Dart has no structural `unknown` reflection: a real WorkspaceFolder is
/// already known to satisfy all three checks, Map carriers are checked field-wise.
bool isWorkspaceFolder(Object? thing) {
  if (thing is WorkspaceFolder) return true;
  final candidate = thing is Map ? thing : null;
  return candidate != null &&
      URI.isUri(candidate['uri']) &&
      candidate['name'] is String &&
      candidate['toResource'] is Function;
}

/// 1:1: `export class Workspace implements IWorkspace`
class Workspace implements IWorkspace {
  late TernarySearchTree<URI, WorkspaceFolder> foldersMap;

  late List<WorkspaceFolder> _folders;

  /// 1:1: `get folders(): WorkspaceFolder[]`
  @override
  List<WorkspaceFolder> get folders => _folders;

  /// 1:1: `set folders(folders: WorkspaceFolder[])`
  set folders(List<WorkspaceFolder> folders) {
    _folders = folders;
    updateFoldersMap();
  }

  String _id;
  bool _transient;
  URI? _configuration;

  /// 1:1: `private ignorePathCasing: (key: URI) => boolean`
  bool Function(URI) ignorePathCasing;
  String? _workspaceName;
  URI? _uri;

  /// 1:1: constructor(_id, folders, _transient, _configuration, ignorePathCasing, _workspaceName?, _uri?)
  Workspace(
    this._id,
    List<WorkspaceFolder> folders,
    this._transient,
    this._configuration,
    this.ignorePathCasing, [
    this._workspaceName,
    this._uri,
  ]) {
    _uri ??= _configuration ?? (folders.length == 1 ? folders[0].uri : null);
    foldersMap = TernarySearchTree.forUris<WorkspaceFolder>(
        ignorePathCasing, (_) => true);
    this.folders = folders;
  }

  /// 1:1: `update(workspace: Workspace)`
  void update(Workspace workspace) {
    _id = workspace.id;
    _configuration = workspace.configuration;
    _transient = workspace.transient;
    _workspaceName = workspace.name;
    _uri = workspace.uri;
    ignorePathCasing = workspace.ignorePathCasing;
    folders = workspace.folders;
  }

  @override
  String get id => _id;

  @override
  URI? get uri => _uri;

  @override
  bool get transient => _transient;

  @override
  URI? get configuration => _configuration;

  set configuration(URI? configuration) {
    _configuration = configuration;
  }

  @override
  String? get name => _workspaceName;

  /// 1:1: `getFolder(resource: URI): IWorkspaceFolder | null`
  IWorkspaceFolder? getFolder(URI? resource) {
    if (resource == null) {
      return null;
    }
    return foldersMap.findSubstr(resource);
  }

  /// 1:1: `private updateFoldersMap(): void`
  void updateFoldersMap() {
    foldersMap = TernarySearchTree.forUris<WorkspaceFolder>(
        ignorePathCasing, (_) => true);
    for (final folder in folders) {
      foldersMap.set(folder.uri, folder);
    }
  }

  /// 1:1: `toJSON(): IWorkspace`
  Map<String, Object?> toJSON() => <String, Object?>{
        'id': id,
        'uri': uri,
        'folders': folders,
        'transient': transient,
        'configuration': configuration,
        'name': name,
      };
}

/// 1:1: `export interface IRawFileWorkspaceFolder`
abstract class IRawFileWorkspaceFolder {
  String get path;
  String? get name;
}

/// 1:1: `export interface IRawUriWorkspaceFolder`
abstract class IRawUriWorkspaceFolder {
  String get uri;
  String? get name;
}

/// 1:1: `export class WorkspaceFolder implements IWorkspaceFolder`
class WorkspaceFolder implements IWorkspaceFolder {
  @override
  final URI uri;
  @override
  final String name;
  @override
  final num index;

  /// 1:1: `readonly raw?: IRawFileWorkspaceFolder | IRawUriWorkspaceFolder`
  final Object? raw;

  /// 1:1: constructor(data: IWorkspaceFolderData, raw?)
  WorkspaceFolder(IWorkspaceFolderData data, [this.raw])
      : uri = data.uri,
        index = data.index,
        name = data.name;

  @override
  /// TS `joinPath(uri, relativePath)`; the Dart port takes a path segment list.
  URI toResource(String relativePath) => joinPath(uri, <String>[relativePath]);

  /// 1:1: `toJSON(): IWorkspaceFolderData`
  Map<String, Object?> toJSON() => <String, Object?>{
        'uri': uri,
        'name': name,
        'index': index,
      };
}

/// 1:1: `export function toWorkspaceFolder(resource: URI): WorkspaceFolder`
WorkspaceFolder toWorkspaceFolder(URI resource) => WorkspaceFolder(
      _WorkspaceFolderData(
          resource, basenameOrAuthority(resource), 0),
      <String, Object?>{'uri': resource.toString()},
    );

/// Internal carrier for the `IWorkspaceFolderData` structural literal.
class _WorkspaceFolderData implements IWorkspaceFolderData {
  @override
  final URI uri;
  @override
  final String name;
  @override
  final num index;
  _WorkspaceFolderData(this.uri, this.name, this.index);
}

/// 1:1: `export const WORKSPACE_EXTENSION = 'code-workspace'`
const String WORKSPACE_EXTENSION = 'code-workspace';

/// 1:1: `export const WORKSPACE_SUFFIX = \`.${WORKSPACE_EXTENSION}\``
const String WORKSPACE_SUFFIX = '.$WORKSPACE_EXTENSION';

/// 1:1: `export const WORKSPACE_FILTER = [{ name: localize(...), extensions: [WORKSPACE_EXTENSION] }]`
final List<Map<String, Object?>> WORKSPACE_FILTER = <Map<String, Object?>>[
  <String, Object?>{
    'name': localize('codeWorkspace', 'Code Workspace'),
    'extensions': <String>[WORKSPACE_EXTENSION],
  },
];

/// 1:1: `export const UNTITLED_WORKSPACE_NAME = 'workspace.json'`
const String UNTITLED_WORKSPACE_NAME = 'workspace.json';

/// 1:1: `export function isUntitledWorkspace(path: URI, environmentService: IEnvironmentService): boolean`
bool isUntitledWorkspace(URI path, IEnvironmentServiceType environmentService) =>
    extUriBiasedIgnorePathCase.isEqualOrParent(
        path, environmentService.untitledWorkspacesHome);

/// 1:1 overloads:
///   isTemporaryWorkspace(workspace: IWorkspace): boolean
///   isTemporaryWorkspace(path: URI): boolean
/// 1:1: `export function isTemporaryWorkspace(arg1: IWorkspace | URI): boolean`
bool isTemporaryWorkspace(Object arg1) {
  URI? path;
  if (URI.isUri(arg1)) {
    path = arg1 as URI;
  } else {
    path = (arg1 as IWorkspace).configuration;
  }
  return path?.scheme == Schemas.tmp;
}

/// 1:1: `export const STANDALONE_EDITOR_WORKSPACE_ID = '4064...'`
const String STANDALONE_EDITOR_WORKSPACE_ID =
    '4064f6ec-cb38-4ad0-af64-ee6467e63c82';

/// 1:1: `export function isStandaloneEditorWorkspace(workspace: IWorkspace): boolean`
bool isStandaloneEditorWorkspace(IWorkspace workspace) =>
    workspace.id == STANDALONE_EDITOR_WORKSPACE_ID;

/// 1:1: `export function isSavedWorkspace(path: URI, environmentService: IEnvironmentService): boolean`
bool isSavedWorkspace(URI path, IEnvironmentServiceType environmentService) =>
    !isUntitledWorkspace(path, environmentService) &&
    !isTemporaryWorkspace(path);

/// 1:1: `export function hasWorkspaceFileExtension(path: string | URI)`
bool hasWorkspaceFileExtension(Object path) {
  final ext = path is String ? extname(path) : resources.extname(path as URI);
  return ext == WORKSPACE_SUFFIX;
}
