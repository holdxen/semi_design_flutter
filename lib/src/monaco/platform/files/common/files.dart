// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/files/common/files.ts
// Translated 1:1. `const enum` -> class of static const ints (string enums ->
// class of static const String). Interfaces -> abstract classes. Error classes
// extend `Error` per project convention. `FileSystemProviderError` has a
// private constructor in TS -> Dart factory + private generative ctor.
// `instanceof` -> `is`. Runtime truth: tool/ts2dart/_batch146_truth.cjs (real
// files.ts + real recursive deps; instantiation stubbed).
// ---------------------------------------------------------------------------

import 'dart:async' show Completer, Future;

// ignore: unused_import
import '../../../base/common/buffer.dart' show VSBufferReadableStream;
// ignore: unused_import
import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/event.dart' show Event;
// ignore: unused_import
import '../../../base/common/glob.dart' show IExpression;
// ignore: unused_import
import '../../../base/common/htmlContent.dart' show IMarkdownString;
import '../../../base/common/lazy.dart' show Lazy;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/path.dart' show sep;
import '../../../base/common/platform.dart' show isWeb;
// ignore: unused_import
import '../../../base/common/stream.dart' show ReadableStreamEvents;
import '../../../base/common/strings.dart' show startsWithIgnoreCase;
import '../../../base/common/ternarySearchTree.dart' show TernarySearchTree;
import '../../../base/common/types.dart' show isNumber;
import '../../../base/common/uri.dart' show URI, UriComponents;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../nls.dart' show localize;

/// 1:1: `export const IFileService = createDecorator(...)`
final ServiceIdentifier<IFileServiceType> IFileService =
    createDecorator<IFileServiceType>('fileService');

/// 1:1: `export enum FileType`
class FileType {
  static const int Unknown = 0;
  static const int File = 1;
  static const int Directory = 2;
  static const int SymbolicLink = 64;
}

/// 1:1: `export enum FilePermission`
class FilePermission {
  static const int Readonly = 1;
  static const int Locked = 2;
  static const int Executable = 4;
}

/// 1:1: `export const enum FileChangeFilter`
class FileChangeFilter {
  static const int UPDATED = 1 << 1;
  static const int ADDED = 1 << 2;
  static const int DELETED = 1 << 3;
}

/// 1:1: `export const enum FileSystemProviderCapabilities`
class FileSystemProviderCapabilities {
  static const int None = 0;
  static const int FileReadWrite = 1 << 1;
  static const int FileOpenReadWriteClose = 1 << 2;
  static const int FileFolderCopy = 1 << 3;
  static const int FileReadStream = 1 << 4;
  static const int PathCaseSensitive = 1 << 10;
  static const int Readonly = 1 << 11;
  static const int Trash = 1 << 12;
  static const int FileWriteUnlock = 1 << 13;
  static const int FileAtomicRead = 1 << 14;
  static const int FileAtomicWrite = 1 << 15;
  static const int FileAtomicDelete = 1 << 16;
  static const int FileClone = 1 << 17;
  static const int FileRealpath = 1 << 18;
  static const int FileAppend = 1 << 19;
  static const int FileAtomicRename = 1 << 20;
}

/// 1:1: `export enum FileSystemProviderErrorCode` (string enum)
class FileSystemProviderErrorCode {
  static const String FileExists = 'EntryExists';
  static const String FileNotFound = 'EntryNotFound';
  static const String FileNotADirectory = 'EntryNotADirectory';
  static const String FileIsADirectory = 'EntryIsADirectory';
  static const String FileExceedsStorageQuota = 'EntryExceedsStorageQuota';
  static const String FileTooLarge = 'EntryTooLarge';
  static const String FileWriteLocked = 'EntryWriteLocked';
  static const String NoPermissions = 'NoPermissions';
  static const String Unavailable = 'Unavailable';
  static const String Unknown = 'Unknown';
}

/// 1:1: `export const enum FileOperation`
class FileOperation {
  static const int MOVE = 0;
  static const int COPY = 1;
  static const int DELETE = 2;
  static const int CREATE = 3;
}

/// 1:1: `export const enum FileChangeType`
class FileChangeType {
  static const int UPDATED = 0;
  static const int ADDED = 1;
  static const int DELETED = 2;
}

/// 1:1: `export const enum FileOperationResult`
class FileOperationResult {
  static const int FILE_IS_DIRECTORY = 0;
  static const int FILE_NOT_FOUND = 1;
  static const int FILE_NOT_MODIFIED_SINCE = 2;
  static const int FILE_MODIFIED_SINCE = 3;
  static const int FILE_MOVE_CONFLICT = 4;
  static const int FILE_WRITE_LOCKED = 5;
  static const int FILE_PERMISSION_DENIED = 6;
  static const int FILE_TOO_LARGE = 7;
  static const int FILE_INVALID_PATH = 8;
  static const int FILE_NOT_DIRECTORY = 9;
  static const int FILE_OTHER_ERROR = 10;
}

/// 1:1: `export enum FileKind`
class FileKind {
  static const int FILE = 0;
  static const int FOLDER = 1;
  static const int ROOT_FOLDER = 2;
}

/// 1:1: `export const AutoSaveConfiguration`
class AutoSaveConfiguration {
  static const String OFF = 'off';
  static const String AFTER_DELAY = 'afterDelay';
  static const String ON_FOCUS_CHANGE = 'onFocusChange';
  static const String ON_WINDOW_CHANGE = 'onWindowChange';
}

/// 1:1: `export const HotExitConfiguration`
class HotExitConfiguration {
  static const String OFF = 'off';
  static const String ON_EXIT = 'onExit';
  static const String ON_EXIT_AND_WINDOW_CLOSE = 'onExitAndWindowClose';
}

const String FILES_ASSOCIATIONS_CONFIG = 'files.associations';
const String FILES_EXCLUDE_CONFIG = 'files.exclude';
const String FILES_READONLY_INCLUDE_CONFIG = 'files.readonlyInclude';
const String FILES_READONLY_EXCLUDE_CONFIG = 'files.readonlyExclude';
const String FILES_READONLY_FROM_PERMISSIONS_CONFIG =
    'files.readonlyFromPermissions';
const String ETAG_DISABLED = '';

// ---- error classes ----
//
// Dart `Error` has no settable `name`/`message` (JS Error has both). Per the
// project convention (cf. ExtensionError), names/messages are carried on a
// subclass; `FileError` is the shared carrier so `markAsFileSystemProviderError`
// can mutate `name` exactly like the JS source.

/// Shared carrier for JS `Error` message + mutable name.
class FileError extends Error {
  FileError(this.message) : name = 'Error';

  final String message;
  String name;

  @override
  String toString() => '$name: $message';
}

/// 1:1: `export class FileSystemProviderError extends Error`
class FileSystemProviderError extends FileError {
  factory FileSystemProviderError.create(Object error, String code) {
    final FileSystemProviderError providerError =
        FileSystemProviderError._(error.toString(), code);
    markAsFileSystemProviderError(providerError, code);
    return providerError;
  }

  FileSystemProviderError._(String message, this.code) : super(message);

  final String code;
}

/// 1:1: `createFileSystemProviderError`
FileSystemProviderError createFileSystemProviderError(
        Object error, String code) =>
    FileSystemProviderError.create(error, code);

/// 1:1: `ensureFileSystemProviderError`
Error ensureFileSystemProviderError([Error? error]) {
  if (error == null) {
    return createFileSystemProviderError(
        localize('unknownError', 'Unknown Error'),
        FileSystemProviderErrorCode.Unknown);
  }
  return error;
}

/// 1:1: `markAsFileSystemProviderError`
Error markAsFileSystemProviderError(Error error, String code) {
  if (error is FileError) {
    error.name = code.isNotEmpty
        ? '$code (FileSystemError)'
        : 'FileSystemError';
  }
  return error;
}

final RegExp _fileSystemErrorName = RegExp(r'^(.+) \(FileSystemError\)$');

/// 1:1: `toFileSystemProviderErrorCode`
String toFileSystemProviderErrorCode(Object? error) {
  if (error == null) {
    return FileSystemProviderErrorCode.Unknown;
  }
  if (error is FileSystemProviderError) {
    return error.code;
  }
  final String name = error is FileError ? error.name : '';
  final RegExpMatch? match = _fileSystemErrorName.firstMatch(name);
  if (match == null) {
    return FileSystemProviderErrorCode.Unknown;
  }
  switch (match.group(1)) {
    case FileSystemProviderErrorCode.FileExists:
      return FileSystemProviderErrorCode.FileExists;
    case FileSystemProviderErrorCode.FileIsADirectory:
      return FileSystemProviderErrorCode.FileIsADirectory;
    case FileSystemProviderErrorCode.FileNotADirectory:
      return FileSystemProviderErrorCode.FileNotADirectory;
    case FileSystemProviderErrorCode.FileNotFound:
      return FileSystemProviderErrorCode.FileNotFound;
    case FileSystemProviderErrorCode.FileTooLarge:
      return FileSystemProviderErrorCode.FileTooLarge;
    case FileSystemProviderErrorCode.FileWriteLocked:
      return FileSystemProviderErrorCode.FileWriteLocked;
    case FileSystemProviderErrorCode.NoPermissions:
      return FileSystemProviderErrorCode.NoPermissions;
    case FileSystemProviderErrorCode.Unavailable:
      return FileSystemProviderErrorCode.Unavailable;
  }
  return FileSystemProviderErrorCode.Unknown;
}

/// 1:1: `export class FileOperationError extends Error`
class FileOperationError extends FileError {
  FileOperationError(String message, this.fileOperationResult, [this.options])
      : super(message);

  final int fileOperationResult;
  final Object? options;
}

/// 1:1: `export class TooLargeFileOperationError`
class TooLargeFileOperationError extends FileOperationError {
  TooLargeFileOperationError(String message, this.size, [Object? options])
      : super(message, FileOperationResult.FILE_TOO_LARGE, options);

  final num size;
}

/// 1:1: `export class NotModifiedSinceFileOperationError`
class NotModifiedSinceFileOperationError extends FileOperationError {
  NotModifiedSinceFileOperationError(String message, this.stat, [Object? options])
      : super(message, FileOperationResult.FILE_NOT_MODIFIED_SINCE, options);

  final Object stat;
}

/// 1:1: `toFileOperationResult`
int toFileOperationResult(Error error) {
  if (error is FileOperationError) {
    return error.fileOperationResult;
  }
  switch (toFileSystemProviderErrorCode(error)) {
    case FileSystemProviderErrorCode.FileNotFound:
      return FileOperationResult.FILE_NOT_FOUND;
    case FileSystemProviderErrorCode.FileIsADirectory:
      return FileOperationResult.FILE_IS_DIRECTORY;
    case FileSystemProviderErrorCode.FileNotADirectory:
      return FileOperationResult.FILE_NOT_DIRECTORY;
    case FileSystemProviderErrorCode.FileWriteLocked:
      return FileOperationResult.FILE_WRITE_LOCKED;
    case FileSystemProviderErrorCode.NoPermissions:
      return FileOperationResult.FILE_PERMISSION_DENIED;
    case FileSystemProviderErrorCode.FileExists:
      return FileOperationResult.FILE_MOVE_CONFLICT;
    case FileSystemProviderErrorCode.FileTooLarge:
      return FileOperationResult.FILE_TOO_LARGE;
    default:
      return FileOperationResult.FILE_OTHER_ERROR;
  }
}

// ---- capability guards ----

/// 1:1: structural provider carrier interface.
abstract class IFileSystemProvider {
  int get capabilities;
  Event<void> get onDidChangeCapabilities;
}

bool _hasCapability(IFileSystemProvider provider, int cap) =>
    (provider.capabilities & cap) != 0;

/// 1:1: `hasReadWriteCapability`
bool hasReadWriteCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileReadWrite);

/// 1:1: `hasFileAppendCapability`
bool hasFileAppendCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileAppend);

/// 1:1: `hasFileFolderCopyCapability`
bool hasFileFolderCopyCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileFolderCopy);

/// 1:1: `hasFileCloneCapability`
bool hasFileCloneCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileClone);

/// 1:1: `hasFileRealpathCapability`
bool hasFileRealpathCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileRealpath);

/// 1:1: `hasOpenReadWriteCloseCapability`
bool hasOpenReadWriteCloseCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileOpenReadWriteClose);

/// 1:1: `hasFileReadStreamCapability`
bool hasFileReadStreamCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileReadStream);

/// 1:1: `hasFileAtomicReadCapability` (requires FileReadWrite too)
bool hasFileAtomicReadCapability(IFileSystemProvider provider) {
  if (!hasReadWriteCapability(provider)) return false;
  return _hasCapability(provider, FileSystemProviderCapabilities.FileAtomicRead);
}

/// 1:1: `hasFileAtomicWriteCapability` (requires FileReadWrite too)
bool hasFileAtomicWriteCapability(IFileSystemProvider provider) {
  if (!hasReadWriteCapability(provider)) return false;
  return _hasCapability(provider, FileSystemProviderCapabilities.FileAtomicWrite);
}

/// 1:1: `hasFileAtomicDeleteCapability`
bool hasFileAtomicDeleteCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileAtomicDelete);

/// 1:1: `hasFileAtomicRenameCapability`
bool hasFileAtomicRenameCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.FileAtomicRename);

/// 1:1: `hasReadonlyCapability`
bool hasReadonlyCapability(IFileSystemProvider provider) =>
    _hasCapability(provider, FileSystemProviderCapabilities.Readonly);

/// 1:1: `isFileOpenForWriteOptions` — `options.create === true`
bool isFileOpenForWriteOptions(Object? options) {
  if (options == null) return false;
  if (options is Map) return options['create'] == true;
  final dynamic d = options;
  try {
    return d.create == true;
  } catch (_) {
    return false;
  }
}

/// 1:1: `isFileSystemWatcher`
bool isFileSystemWatcher(Object? thing) {
  if (thing == null) return false;
  final dynamic d = thing;
  try {
    return d.onDidChange is Function;
  } catch (_) {
    return false;
  }
}

// (part 2 continues: FileChangesEvent, isParent, etag, ByteSize, helpers)

// ---- IFileChange / FileChangesEvent ----

/// 1:1: `export interface IFileChange`
abstract class IFileChange {
  int get type;
  URI get resource;
  int? get cId;
}

/// 1:1: `export class FileChangesEvent`
class FileChangesEvent {
  // TS distinguishes `undefined` (not yet set), `number`, and `null`
  // (MIXED_CORRELATION). Dart null cannot hold both undefined and null, so an
  // internal sentinel stands in for `undefined`.
  static final Object MIXED_CORRELATION = Object(); // stands in for TS `null`
  static final Object _undefined = Object(); // stands in for TS `undefined`

  Object _correlationId = _undefined; // _undefined | int | MIXED_CORRELATION

  final bool _ignorePathCasing;

  FileChangesEvent(List<IFileChange> changes, this._ignorePathCasing) {
    for (final change in changes) {
      switch (change.type) {
        case FileChangeType.ADDED:
          rawAdded.add(change.resource);
          break;
        case FileChangeType.UPDATED:
          rawUpdated.add(change.resource);
          break;
        case FileChangeType.DELETED:
          rawDeleted.add(change.resource);
          break;
      }

      if (!identical(_correlationId, MIXED_CORRELATION)) {
        final int? cid = change.cId;
        if (cid != null) {
          if (identical(_correlationId, _undefined)) {
            _correlationId = cid;
          } else if (_correlationId != cid) {
            _correlationId = MIXED_CORRELATION;
          }
        } else {
          if (!identical(_correlationId, _undefined)) {
            _correlationId = MIXED_CORRELATION;
          }
        }
      }
    }
  }

  final List<URI> rawAdded = <URI>[];
  final List<URI> rawUpdated = <URI>[];
  final List<URI> rawDeleted = <URI>[];

  late final Lazy<TernarySearchTree<URI, bool>> _added = Lazy(() {
    final tree = TernarySearchTree.forUris<bool>((URI k) => _ignorePathCasing);
    tree.fill(<List<Object?>>[
      for (final resource in rawAdded) <Object?>[resource, true]
    ]);
    return tree;
  });

  late final Lazy<TernarySearchTree<URI, bool>> _updated = Lazy(() {
    final tree = TernarySearchTree.forUris<bool>((URI k) => _ignorePathCasing);
    tree.fill(<List<Object?>>[
      for (final resource in rawUpdated) <Object?>[resource, true]
    ]);
    return tree;
  });

  late final Lazy<TernarySearchTree<URI, bool>> _deleted = Lazy(() {
    final tree = TernarySearchTree.forUris<bool>((URI k) => _ignorePathCasing);
    tree.fill(<List<Object?>>[
      for (final resource in rawDeleted) <Object?>[resource, true]
    ]);
    return tree;
  });

  /// 1:1: `contains(resource, ...types)`
  bool contains(URI resource, [List<int> types = const <int>[]]) =>
      _doContains(resource, false, types);

  /// 1:1: `affects(resource, ...types)`
  bool affects(URI resource, [List<int> types = const <int>[]]) =>
      _doContains(resource, true, types);

  bool _doContains(URI resource, bool includeChildren, List<int> types) {
    // `if (!resource)` — URI object is always truthy in Dart.
    final bool hasTypesFilter = types.isNotEmpty;

    if (!hasTypesFilter || types.contains(FileChangeType.ADDED)) {
      if (_added.value.get(resource) == true) return true;
      if (includeChildren && _added.value.findSuperstr(resource) != null) {
        return true;
      }
    }

    if (!hasTypesFilter || types.contains(FileChangeType.UPDATED)) {
      if (_updated.value.get(resource) == true) return true;
      if (includeChildren && _updated.value.findSuperstr(resource) != null) {
        return true;
      }
    }

    if (!hasTypesFilter || types.contains(FileChangeType.DELETED)) {
      // deleted also considers parent folders
      if (_deleted.value.findSubstr(resource) != null) return true;
      if (includeChildren && _deleted.value.findSuperstr(resource) != null) {
        return true;
      }
    }

    return false;
  }

  bool gotAdded() => rawAdded.isNotEmpty;
  bool gotUpdated() => rawUpdated.isNotEmpty;
  bool gotDeleted() => rawDeleted.isNotEmpty;

  bool correlates(int correlationId) => _correlationId == correlationId;

  bool hasCorrelation() => _correlationId is int;
}

// ---- utilities ----

/// 1:1: `isParent(path, candidate, ignoreCase?)`
bool isParent(String path, String candidate, [bool ignoreCase = false]) {
  if (path.isEmpty || candidate.isEmpty || path == candidate) {
    return false;
  }
  if (candidate.length > path.length) {
    return false;
  }
  String cand = candidate;
  if (cand[cand.length - 1] != sep) {
    cand += sep;
  }
  if (ignoreCase) {
    return startsWithIgnoreCase(path, cand);
  }
  return path.indexOf(cand) == 0;
}

/// 1:1: `etag(stat)`
String? etag({num? mtime, num? size}) {
  if (size is! num || mtime is! num) {
    return null;
  }
  // JS (mtime).toString(29) + (size).toString(31) — radix string.
  return mtime.toInt().toRadixString(29) + size.toInt().toRadixString(31);
}

/// 1:1: `class ByteSize`
class ByteSize {
  static const int KB = 1024;
  static const int MB = KB * KB;
  static const int GB = MB * KB;
  static const int TB = GB * KB;

  /// 1:1: `ByteSize.formatSize(size)`
  static String formatSize(Object size) {
    num s = isNumber(size) ? size as num : 0;
    if (s < KB) {
      return localize('sizeB', '{0}B', <Object?>[s.toInt().toString()]);
    }
    if (s < MB) {
      return localize('sizeKB', '{0}KB',
          <Object?>[(s / KB).toStringAsFixed(2)]);
    }
    if (s < GB) {
      return localize('sizeMB', '{0}MB',
          <Object?>[(s / MB).toStringAsFixed(2)]);
    }
    if (s < TB) {
      return localize('sizeGB', '{0}GB',
          <Object?>[(s / GB).toStringAsFixed(2)]);
    }
    return localize('sizeTB', '{0}TB',
        <Object?>[(s / TB).toStringAsFixed(2)]);
  }
}

/// 1:1: `getLargeFileConfirmationLimit(arg?)`
int getLargeFileConfirmationLimit([Object? arg]) {
  final bool isRemote = arg is String || (arg is URI && arg.scheme == Schemas.vscodeRemote);
  final bool isLocal = arg is! String && arg is URI && arg.scheme == Schemas.file;

  if (isLocal) {
    return 1024 * ByteSize.MB;
  }
  if (isRemote) {
    return 10 * ByteSize.MB;
  }
  if (isWeb) {
    return 50 * ByteSize.MB;
  }
  return 1024 * ByteSize.MB;
}

/// 1:1: `whenProviderRegistered(file, fileService)`
Future<void> whenProviderRegistered(URI file, IFileServiceType fileService) async {
  if (fileService.hasProvider(URI.from(UriComponents(scheme: file.scheme)))) {
    return;
  }
  // Dart has no promise-style registration event; the listener form is
  // expressed via the service event (1:1 behavior).
  final completer = Completer<void>();
  late final IDisposable disposable;
  disposable = fileService.onDidChangeFileSystemProviderRegistrations((e) {
    if (e.scheme == file.scheme && e.added) {
      disposable.dispose();
      if (!completer.isCompleted) completer.complete();
    }
  });
  return completer.future;
}

// ---------------------------------------------------------------------------
// Structural interfaces (method signatures) — 1:1 names from files.ts.
// ---------------------------------------------------------------------------

abstract class IFileSystemProviderRegistrationEvent {
  String get scheme;
  bool get added;
}

abstract class IFileSystemProviderCapabilitiesChangeEvent {
  IFileSystemProvider get provider;
}

abstract class IFileSystemProviderActivationEvent {
  String get scheme;
}

/// 1:1: `export interface IFileService`
abstract class IFileServiceType {
  Event<IFileSystemProviderRegistrationEvent>
      get onDidChangeFileSystemProviderRegistrations;
  Event<IFileSystemProviderActivationEvent>
      get onWillActivateFileSystemProvider;
  Event<FileChangesEvent> get onDidFilesChange;
  bool hasProvider(URI schema);
  Future<void> activateProvider(String scheme);
  Future<bool> canHandleResource(URI resource);
}
