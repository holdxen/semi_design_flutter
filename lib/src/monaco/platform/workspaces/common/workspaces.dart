// 1:1 port of vscode/src/vs/platform/workspaces/common/workspaces.ts

import 'dart:convert';

import '../../../base/common/event.dart' as events;
import '../../../base/common/extpath.dart' as extpath;
import '../../../base/common/json.dart' as json;
import '../../../base/common/jsonEdit.dart' as jsonEdit;
import '../../../base/common/jsonFormatter.dart' as jsonFormatter;
import '../../../base/common/labels.dart' as labels;
import '../../../base/common/network.dart' as network;
import '../../../base/common/path.dart' as paths;
import '../../../base/common/platform.dart' as platform;
import '../../../base/common/resources.dart' as resources;
import '../../../base/common/uri.dart' as uriLib;
import '../../instantiation/common/instantiation.dart' as instantiation;
import '../../log/common/log.dart' as log;
import '../../remote/common/remoteHosts.dart' as remoteHosts;
import '../../workspace/common/workspace.dart' as workspace;

/// 1:1: `export const IWorkspacesService`
final instantiation.ServiceIdentifier<IWorkspacesServiceType> IWorkspacesService =
    instantiation.createDecorator<IWorkspacesServiceType>('workspacesService');

/// 1:1: `export interface IWorkspacesService`
abstract class IWorkspacesServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  Future<IEnterWorkspaceResult?> enterWorkspace(uriLib.URI workspaceUri);
  Future<workspace.IWorkspaceIdentifier> createUntitledWorkspace(
      [List<IWorkspaceFolderCreationData>? folders, String? remoteAuthority]);
  Future<void> deleteUntitledWorkspace(
      workspace.IWorkspaceIdentifier workspace);
  Future<workspace.IWorkspaceIdentifier> getWorkspaceIdentifier(
      uriLib.URI workspaceUri);
  events.Event<void> get onDidChangeRecentlyOpened;
  Future<void> addRecentlyOpened(List<Object?> recents);
  Future<void> removeRecentlyOpened(List<uriLib.URI> workspaces);
  Future<void> clearRecentlyOpened();
  Future<IRecentlyOpened> getRecentlyOpened();
  Future<List<Object?>> getDirtyWorkspaces();
}

// ---------------------------------------------------------------------------
// Recently opened
// ---------------------------------------------------------------------------

/// 1:1: `export interface IRecentlyOpened`
class IRecentlyOpened {
  IRecentlyOpened(this.workspaces, this.files);

  final List<Object?> workspaces;
  final List<Object?> files;
}

/// Common fields of the three recent-entry interfaces.
abstract class IRecent {
  String? label;
  String? remoteAuthority;
}

/// 1:1: `export interface IRecentWorkspace`
class IRecentWorkspace implements IRecent {
  IRecentWorkspace(this.identifier, {this.label, this.remoteAuthority});

  final workspace.IWorkspaceIdentifier identifier;

  @override
  String? label;
  @override
  String? remoteAuthority;
}

/// 1:1: `export interface IRecentFolder`
class IRecentFolder implements IRecent {
  IRecentFolder(this.folderUri, {this.label, this.remoteAuthority});

  final uriLib.URI folderUri;

  @override
  String? label;
  @override
  String? remoteAuthority;
}

/// 1:1: `export interface IRecentFile`
class IRecentFile implements IRecent {
  IRecentFile(this.fileUri, {this.label, this.remoteAuthority});

  final uriLib.URI fileUri;

  @override
  String? label;
  @override
  String? remoteAuthority;
}

bool _hasOwn(Object? obj, String key) {
  if (obj == null) return false;
  if (obj is Map<Object?, Object?>) return obj.containsKey(key);
  if (obj is Map<String, Object?>) return obj.containsKey(key);
  if (obj is IRecentWorkspace) return key == 'workspace';
  if (obj is IRecentFolder) return key == 'folderUri';
  if (obj is IRecentFile) return key == 'fileUri';
  return false;
}

Object? _field(Object? obj, String key) {
  if (obj is Map) return obj[key];
  if (obj is IRecentWorkspace && key == 'workspace') return obj.identifier;
  if (obj is IRecentFolder && key == 'folderUri') return obj.folderUri;
  if (obj is IRecentFile && key == 'fileUri') return obj.fileUri;
  if (obj is IStoredWorkspaceFolder && key == 'path') return obj.path;
  if (obj is IStoredWorkspaceFolder && key == 'uri') return obj.uriString;
  if (obj is IStoredWorkspaceFolder && key == 'name') return obj.name;
  if (obj is IRecent && key == 'label') return obj.label;
  if (obj is IRecent && key == 'remoteAuthority') return obj.remoteAuthority;
  return null;
}

/// 1:1: `export function isRecentWorkspace`
bool isRecentWorkspace(Object? curr) => _hasOwn(curr, 'workspace');

/// 1:1: `export function isRecentFolder`
bool isRecentFolder(Object? curr) => _hasOwn(curr, 'folderUri');

/// 1:1: `export function isRecentFile`
bool isRecentFile(Object? curr) => _hasOwn(curr, 'fileUri');

// ---------------------------------------------------------------------------
// Workspace file utilities
// ---------------------------------------------------------------------------

/// 1:1: `export type IStoredWorkspaceFolder`
class IStoredWorkspaceFolder {
  IStoredWorkspaceFolder({this.path, this.uriString, this.name});

  final String? path;
  final String? uriString;
  final String? name;
}

/// 1:1: `export interface IStoredWorkspace`
class IStoredWorkspace {
  IStoredWorkspace(this.folders, {this.remoteAuthority});

  List<IStoredWorkspaceFolder> folders;
  String? remoteAuthority;
}

/// 1:1: `export interface IWorkspaceFolderCreationData`
class IWorkspaceFolderCreationData {
  IWorkspaceFolderCreationData(this.resource, [this.name]);

  final uriLib.URI resource;
  final String? name;
}

/// 1:1: `export interface IUntitledWorkspaceInfo`
class IUntitledWorkspaceInfo {
  IUntitledWorkspaceInfo(this.identifier, [this.remoteAuthority]);

  final workspace.IWorkspaceIdentifier identifier;
  final String? remoteAuthority;
}

/// 1:1: `export interface IEnterWorkspaceResult`
class IEnterWorkspaceResult {
  IEnterWorkspaceResult(this.identifier, [this.backupPath]);

  final workspace.IWorkspaceIdentifier identifier;
  final String? backupPath;
}

/// 1:1: `export function isStoredWorkspaceFolder`
bool isStoredWorkspaceFolder(Object? obj) =>
    _isRawFileWorkspaceFolder(obj) || _isRawUriWorkspaceFolder(obj);

bool _isRawFileWorkspaceFolder(Object? obj) {
  final Object? path = _field(obj, 'path');
  final Object? name = _field(obj, 'name');
  return path is String && (name == null || name is String);
}

bool _isRawUriWorkspaceFolder(Object? obj) {
  final Object? value = _field(obj, 'uri');
  final Object? name = _field(obj, 'name');
  return value is String && (name == null || name is String);
}

/// 1:1: `getStoredWorkspaceFolder`
IStoredWorkspaceFolder getStoredWorkspaceFolder(
  uriLib.URI folderURI,
  bool forceAbsolute,
  String? folderName,
  uriLib.URI targetConfigFolderURI,
  resources.IExtUri extUri,
) {
  if (folderURI.scheme != targetConfigFolderURI.scheme) {
    return IStoredWorkspaceFolder(
        name: folderName, uriString: folderURI.toString(true));
  }

  String? folderPath = !forceAbsolute
      ? extUri.relativePath(targetConfigFolderURI, folderURI)
      : null;
  if (folderPath != null) {
    if (folderPath.isEmpty) {
      folderPath = '.';
    } else if (platform.isWindows) {
      folderPath = _massagePathForWindows(folderPath);
    }
  } else {
    if (folderURI.scheme == network.Schemas.file) {
      folderPath = folderURI.fsPath;
      if (platform.isWindows) {
        folderPath = _massagePathForWindows(folderPath);
      }
    } else if (!extUri.isEqualAuthority(
        folderURI.authority, targetConfigFolderURI.authority)) {
      return IStoredWorkspaceFolder(
          name: folderName, uriString: folderURI.toString(true));
    } else {
      folderPath = folderURI.path;
    }
  }

  return IStoredWorkspaceFolder(name: folderName, path: folderPath);
}

String _massagePathForWindows(String folderPath) {
  folderPath = labels.normalizeDriveLetter(folderPath);
  if (!extpath.isUNC(folderPath)) {
    folderPath = extpath.toSlashes(folderPath);
  }
  return folderPath;
}

/// 1:1: `toWorkspaceFolders`
List<workspace.WorkspaceFolder> toWorkspaceFolders(
  List<Object?> configuredFolders,
  uriLib.URI workspaceConfigFile,
  resources.IExtUri extUri,
) {
  final List<workspace.WorkspaceFolder> result =
      <workspace.WorkspaceFolder>[];
  final Set<String> seen = <String>{};

  final uriLib.URI relativeTo = extUri.dirname(workspaceConfigFile);
  for (final Object? configuredFolder in configuredFolders) {
    uriLib.URI? folderUri;
    if (_isRawFileWorkspaceFolder(configuredFolder)) {
      final String path = _field(configuredFolder, 'path') as String;
      if (path.isNotEmpty) {
        folderUri = extUri.resolvePath(relativeTo, path);
      }
    } else if (_isRawUriWorkspaceFolder(configuredFolder)) {
      try {
        folderUri = uriLib.URI.parse(_field(configuredFolder, 'uri') as String);
        if (folderUri.path.isEmpty ||
            folderUri.path[0] != paths.posix.sep) {
          folderUri = folderUri.withChanges(uriLib.UriChange(
              path: paths.posix.sep + folderUri.path));
        }
      } catch (e) {
        // console.warn(e) — ignore; see consoleWarnProvider.
        consoleWarnProvider(e);
      }
    }

    if (folderUri != null) {
      final String comparisonKey = extUri.getComparisonKey(folderUri);
      if (!seen.contains(comparisonKey)) {
        seen.add(comparisonKey);
        final String name = (_field(configuredFolder, 'name') as String?) ??
            extUri.basenameOrAuthority(folderUri);
        result.add(workspace.WorkspaceFolder(
          _WorkspaceFolderData(folderUri, name, result.length),
          configuredFolder,
        ));
      }
    }
  }

  return result;
}

class _WorkspaceFolderData implements workspace.IWorkspaceFolderData {
  _WorkspaceFolderData(this.resource, this.name, this.index);

  final uriLib.URI resource;

  @override
  uriLib.URI get uri => resource;
  @override
  final String name;
  @override
  final num index;
}

void Function(Object) consoleWarnProvider = (Object e) {};

/// 1:1: `rewriteWorkspaceFileForNewLocation`
String rewriteWorkspaceFileForNewLocation(
  String rawWorkspaceContents,
  uriLib.URI configPathURI,
  bool isFromUntitledWorkspace,
  uriLib.URI targetConfigPathURI,
  resources.IExtUri extUri,
) {
  final IStoredWorkspace storedWorkspace =
      _doParseStoredWorkspace(configPathURI, rawWorkspaceContents);

  final uriLib.URI sourceConfigFolder = extUri.dirname(configPathURI);
  final uriLib.URI targetConfigFolder = extUri.dirname(targetConfigPathURI);

  final List<IStoredWorkspaceFolder> rewrittenFolders =
      <IStoredWorkspaceFolder>[];
  for (final IStoredWorkspaceFolder folder in storedWorkspace.folders) {
    final uriLib.URI folderURI = _isRawFileWorkspaceFolder(folder)
        ? extUri.resolvePath(sourceConfigFolder, folder.path!)
        : uriLib.URI.parse(folder.uriString!);
    final bool absolute = isFromUntitledWorkspace
        ? false
        : !_isRawFileWorkspaceFolder(folder) ||
            paths.isAbsolute(folder.path!);
    rewrittenFolders.add(getStoredWorkspaceFolder(
        folderURI, absolute, folder.name, targetConfigFolder, extUri));
  }

  final jsonFormatter.FormattingOptions formattingOptions =
      jsonFormatter.FormattingOptions(
    insertSpaces: false,
    tabSize: 4,
    eol: (platform.isLinux || platform.isMacintosh) ? '\n' : '\r\n',
  );
  final List<jsonFormatter.Edit> edits = jsonEdit.setProperty(
      rawWorkspaceContents, <Object>['folders'], _foldersToJson(rewrittenFolders),
      formattingOptions);
  String newContent = jsonEdit.applyEdits(rawWorkspaceContents, edits);

  if (resources.isEqualAuthority(storedWorkspace.remoteAuthority,
      remoteHosts.getRemoteAuthority(targetConfigPathURI))) {
    newContent = jsonEdit.applyEdits(
        newContent,
        jsonEdit.removeProperty(
            newContent, <Object>['remoteAuthority'], formattingOptions));
  }

  return newContent;
}

List<Object?> _foldersToJson(List<IStoredWorkspaceFolder> folders) => folders
    .map((IStoredWorkspaceFolder f) => <String, Object?>{
          if (f.name != null) 'name': f.name,
          if (f.path != null) 'path': f.path,
          if (f.uriString != null) 'uri': f.uriString,
        })
    .toList(growable: false);

IStoredWorkspace _doParseStoredWorkspace(uriLib.URI path, String contents) {
  final Object? parsed = json.parse(contents);
  final Map<String, Object?> storedWorkspace =
      (parsed as Map?)?.cast<String, Object?>() ??
          <String, Object?>{};
  final Object? folders = storedWorkspace['folders'];
  if (folders is List<Object?>) {
    storedWorkspace['folders'] = folders
        .where((Object? folder) => isStoredWorkspaceFolder(folder))
        .map((Object? folder) => IStoredWorkspaceFolder(
              path: _field(folder, 'path') as String?,
              uriString: _field(folder, 'uri') as String?,
              name: _field(folder, 'name') as String?,
            ))
        .toList(growable: false);
  } else {
    throw StateError('$path looks like an invalid workspace file.');
  }

  return IStoredWorkspace(
    storedWorkspace['folders'] as List<IStoredWorkspaceFolder>,
    remoteAuthority: storedWorkspace['remoteAuthority'] as String?,
  );
}

// ---------------------------------------------------------------------------
// Workspace storage
// ---------------------------------------------------------------------------

bool _isSerializedRecentWorkspace(Object? data) {
  final Object? workspaceData = _field(data, 'workspace');
  if (workspaceData is! Map) return false;
  return _field(workspaceData, 'id') is String &&
      _field(workspaceData, 'configPath') is String;
}

bool _isSerializedRecentFolder(Object? data) =>
    _field(data, 'folderUri') is String;

bool _isSerializedRecentFile(Object? data) =>
    _field(data, 'fileUri') is String;

/// 1:1: `restoreRecentlyOpened`
IRecentlyOpened restoreRecentlyOpened(
    Object? data, log.ILogServiceType logService) {
  final IRecentlyOpened result =
      IRecentlyOpened(<Object?>[], <Object?>[]);
  if (data != null) {
    void restoreGracefully<T>(
        List<T> entries, void Function(T entry, int index) onEntry) {
      for (int i = 0; i < entries.length; i++) {
        try {
          onEntry(entries[i], i);
        } catch (e) {
          logService.warn(
              'Error restoring recent entry ${jsonEncode(entries[i])}: ${e.toString()}. Skip entry.');
        }
      }
    }

    final Map<String, Object?> storedRecents =
        (data as Map).cast<String, Object?>();
    final Object? entries = storedRecents['entries'];
    if (entries is List<Object?>) {
      restoreGracefully<Object?>(entries, (Object? entry, int index) {
        final Object? label = _field(entry, 'label');
        final Object? remoteAuthority = _field(entry, 'remoteAuthority');
        final String? labelString = label as String?;
        final String? authorityString = remoteAuthority as String?;

        if (_isSerializedRecentWorkspace(entry)) {
          final Map<String, Object?> w =
              (_field(entry, 'workspace') as Map).cast<String, Object?>();
          result.workspaces.add(IRecentWorkspace(
            _SerializedWorkspaceIdentifier(
              w['id'] as String,
              uriLib.URI.parse(w['configPath'] as String),
            ),
            label: labelString,
            remoteAuthority: authorityString,
          ));
        } else if (_isSerializedRecentFolder(entry)) {
          result.workspaces.add(IRecentFolder(
            uriLib.URI.parse(_field(entry, 'folderUri') as String),
            label: labelString,
            remoteAuthority: authorityString,
          ));
        } else if (_isSerializedRecentFile(entry)) {
          result.files.add(IRecentFile(
            uriLib.URI.parse(_field(entry, 'fileUri') as String),
            label: labelString,
            remoteAuthority: authorityString,
          ));
        }
      });
    }
  }

  return result;
}

class _SerializedWorkspaceIdentifier
    implements workspace.IWorkspaceIdentifier {
  _SerializedWorkspaceIdentifier(this.id, this.configPath);

  @override
  final String id;
  @override
  final uriLib.URI configPath;
}

bool _storeLabel(String? label, uriLib.URI resource) =>
    label != null &&
    label.isNotEmpty &&
    label != resource.fsPath &&
    label != resource.path;

/// 1:1: `toStoreData`
Map<String, Object?> toStoreData(IRecentlyOpened recents) {
  final Map<String, Object?> serialized = <String, Object?>{
    'entries': <Object?>[],
  };
  final List<Object?> entries = serialized['entries'] as List<Object?>;

  for (final Object? recent in recents.workspaces) {
    if (isRecentFolder(recent)) {
      final uriLib.URI folderUri = (recent as IRecentFolder).folderUri;
      entries.add(<String, Object?>{
        'folderUri': folderUri.toString(),
        'label':
            _storeLabel(recent.label, folderUri) ? recent.label : null,
        'remoteAuthority': recent.remoteAuthority,
      });
    } else {
      final IRecentWorkspace r = recent as IRecentWorkspace;
      entries.add(<String, Object?>{
        'workspace': <String, Object?>{
          'id': r.identifier.id,
          'configPath': r.identifier.configPath.toString(),
        },
        'label': _storeLabel(r.label, r.identifier.configPath) ? r.label : null,
        'remoteAuthority': r.remoteAuthority,
      });
    }
  }

  for (final Object? recent in recents.files) {
    final IRecentFile r = recent as IRecentFile;
    entries.add(<String, Object?>{
      'fileUri': r.fileUri.toString(),
      'label': _storeLabel(r.label, r.fileUri) ? r.label : null,
      'remoteAuthority': r.remoteAuthority,
    });
  }

  return serialized;
}
