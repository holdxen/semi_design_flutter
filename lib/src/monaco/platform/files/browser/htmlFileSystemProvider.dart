// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/files/browser/htmlFileSystemProvider.ts
// Translated 1:1. DOM FileSystemHandle / IndexedDB / FileSystemObserver have no
// Dart equivalents; they stay opaque `dynamic` carriers behind injectable
// accessors, matching the conventions already used in webFileSystemAccess.dart
// and indexedDB.dart. Runtime truth:
//   tool/ts2dart/_batch159_truth.cjs -> tool/ts2dart/batch159_truth.json
// ---------------------------------------------------------------------------

import 'dart:async' show Future;
import 'dart:typed_data' show Uint8List;

import '../../../base/browser/indexedDB.dart' as idb;
import '../../../base/common/buffer.dart' as buffer;
import '../../../base/common/cancellation.dart' as cancellation;
import '../../../base/common/event.dart' as event;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/network.dart' as network;
import '../../../base/common/path.dart' as path;
import '../../../base/common/platform.dart' as platform;
import '../../../base/common/resources.dart' as resources;
import '../../../base/common/stream.dart' as stream;
import '../../../base/common/uri.dart' as uri;
import '../../../nls.dart' show localize;
import '../../log/common/log.dart' as log;
import '../common/files.dart' as files;
import 'webFileSystemAccess.dart' as wfsa;

/// Injectable property reader for opaque DOM carriers (1:1 with the
/// `webFileSystemAccessGetProp` convention). Hosts may override it for real
/// browser `FileSystemHandle` objects.
dynamic Function(dynamic obj, String name) htmlFileSystemProviderGetProp =
    (dynamic obj, String name) {
  if (obj == null) return null;
  if (obj is Map) return obj[name];
  return null;
};

dynamic _prop(dynamic obj, String name) =>
    htmlFileSystemProviderGetProp(obj, name);

/// 1:1 helper for `await obj.method(args...)` on DOM carriers.
Future<dynamic> _callAsync(dynamic obj, String name,
        [List<Object?> args = const <Object?>[]]) async {
  final dynamic fn = _prop(obj, name);
  if (fn is! Function) return null;
  return await Function.apply(fn, args);
}

/// The DOM directory async iterator (`for await (const [name, child] of handle)`)
/// has no Dart counterpart. Tests and hosts inject a reader that returns the
/// same `[name, child]` pairs.
typedef HtmlDirectoryEntriesReader =
    Future<List<List<Object?>>> Function(dynamic handle);

HtmlDirectoryEntriesReader htmlFileSystemDirectoryEntries =
    (dynamic handle) async {
  final dynamic entriesFn = _prop(handle, 'entries');
  if (entriesFn is Function) {
    final dynamic value = await Function.apply(entriesFn, const <Object?>[]);
    if (value is List) {
      return value
          .map((dynamic e) => List<Object?>.from(e as List))
          .toList();
    }
  }
  return const <List<Object?>>[];
};

/// 1:1: the `globalThis` captured by `WebFileSystemObserver.supported(globalThis)`
/// and `new (globalThis as any).FileSystemObserver(...)`.
dynamic htmlFileSystemGlobalThis = <String, Object?>{};

bool Function(dynamic opts, String name) _boolProp =
    (dynamic opts, String name) {
  if (opts == null) return false;
  if (opts is Map) return opts[name] == true;
  return _prop(opts, name) == true;
};

Object? Function(dynamic opts, String name) _valueProp =
    (dynamic opts, String name) {
  if (opts == null) return null;
  if (opts is Map) return opts[name];
  return _prop(opts, name);
};

String _errorName(Object error) {
  if (error is files.FileError) return error.name;
  return _prop(error, 'name') as String? ?? 'Error';
}


/// 1:1: `IStat` (plain object in TS, carrier in Dart).
class HtmlFileSystemStat {
  const HtmlFileSystemStat(this.type, this.mtime, this.ctime, this.size);

  final int type;
  final num mtime;
  final num ctime;
  final num size;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'mtime': mtime,
        'ctime': ctime,
        'size': size,
      };
}

/// 1:1: `IFileChange` emitted by the observer callback.
class _FileChange implements files.IFileChange {
  const _FileChange(this.resource, this.type);

  @override
  final uri.URI resource;

  @override
  final int type;

  @override
  int? get cId => null;
}

/// 1:1: `export class HTMLFileSystemProvider extends Disposable implements ...`
class HTMLFileSystemProvider extends lifecycle.Disposable {
  /// 1:1: `constructor(indexedDB, store, logService)`
  HTMLFileSystemProvider(
    this.indexedDB,
    this.store,
    this.logService,
  );

  final idb.IndexedDB? indexedDB;
  final String store;
  final log.ILogServiceType logService;

  /// 1:1: `readonly onDidChangeCapabilities = Event.None`
  event.Event<void> get onDidChangeCapabilities => event.eventNone;

  /// 1:1: `private extUri = isLinux ? extUri : extUriIgnorePathCase`
  final resources.ExtUri _extUri =
      platform.isLinux ? resources.extUri : resources.extUriIgnorePathCase;

  int? _capabilities;

  /// 1:1: `get capabilities()`
  int get capabilities {
    final int? cached = _capabilities;
    if (cached == null) {
      int value = files.FileSystemProviderCapabilities.FileReadWrite |
          files.FileSystemProviderCapabilities.FileReadStream;
      if (platform.isLinux) {
        value |= files.FileSystemProviderCapabilities.PathCaseSensitive;
      }
      _capabilities = value;
      return value;
    }
    return cached;
  }

  // #region File Metadata Resolving

  /// 1:1: `async stat(resource)`
  Future<HtmlFileSystemStat> stat(uri.URI resource) async {
    try {
      final dynamic handle = await getHandle(resource);
      if (handle == null) {
        throw createFileSystemProviderError(resource,
            'No such file or directory, stat', files.FileSystemProviderErrorCode.FileNotFound);
      }
      if (wfsa.WebFileSystemAccess.isFileSystemFileHandle(handle)) {
        final dynamic file = await _callAsync(handle, 'getFile');
        return HtmlFileSystemStat(
          files.FileType.File,
          (_prop(file, 'lastModified') as num?) ?? 0,
          0,
          (_prop(file, 'size') as num?) ?? 0,
        );
      }
      return const HtmlFileSystemStat(files.FileType.Directory, 0, 0, 0);
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  /// 1:1: `async readdir(resource)`
  Future<List<List<Object?>>> readdir(uri.URI resource) async {
    try {
      final dynamic handle = await getDirectoryHandle(resource);
      if (handle == null) {
        throw createFileSystemProviderError(resource,
            'No such file or directory, readdir', files.FileSystemProviderErrorCode.FileNotFound);
      }
      final List<List<Object?>> result = <List<Object?>>[];
      for (final List<Object?> entry
          in await htmlFileSystemDirectoryEntries(handle)) {
        final dynamic child = entry.length > 1 ? entry[1] : null;
        result.add(<Object?>[
          entry[0],
          wfsa.WebFileSystemAccess.isFileSystemFileHandle(child)
              ? files.FileType.File
              : files.FileType.Directory,
        ]);
      }
      return result;
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  // #endregion

  // #region File Reading/Writing

  /// 1:1: `readFileStream(resource, opts, token)`
  stream.WriteableStream<Uint8List> readFileStream(
    uri.URI resource,
    Object? opts,
    cancellation.CancellationToken token,
  ) {
    final stream.WriteableStream<Uint8List> s =
        stream.newWriteableStream<Uint8List>(
      (List<Uint8List> data) => buffer.VSBuffer.concat(
        data.map((Uint8List d) => buffer.VSBuffer.wrap(d)).toList(),
      ).buffer,
      stream.WriteableStreamOptions(10),
    );

    // TS fire-and-forget async IIFE; errors are delivered via stream.error.
    () async {
      try {
        final dynamic handle = await getFileHandle(resource);
        if (handle == null) {
          throw createFileSystemProviderError(resource,
              'No such file or directory, readFile', files.FileSystemProviderErrorCode.FileNotFound);
        }
        final dynamic file = await _callAsync(handle, 'getFile');

        // Partial file: implemented simply via `readFile`
        if (_valueProp(opts, 'length') is num || _valueProp(opts, 'position') is num) {
          Uint8List bytes = Uint8List.fromList(
            await _callAsync(file, 'arrayBuffer') as List<int>,
          );
          final Object? position = _valueProp(opts, 'position');
          if (position is num) {
            bytes = bytes.sublist(position.toInt());
          }
          final Object? length = _valueProp(opts, 'length');
          if (length is num) {
            bytes = bytes.sublist(0, length.toInt());
          }
          s.end(bytes);
        }

        // Entire file
        else {
          final dynamic readable = await _callAsync(file, 'stream');
          final dynamic reader = await _callAsync(readable, 'getReader');
          dynamic res = await _callAsync(reader, 'read');
          while (_prop(res, 'done') != true) {
            if (token.isCancellationRequested) break;
            await s.write(_prop(res, 'value') as Uint8List);
            if (token.isCancellationRequested) break;
            res = await _callAsync(reader, 'read');
          }
          s.end(); // TS: stream.end(undefined)
        }
      } catch (error) {
        s.error(toFileSystemProviderError(error));
        s.end();
      }
    }();
    return s;
  }

  /// 1:1: `async readFile(resource)`
  Future<Uint8List> readFile(uri.URI resource) async {
    try {
      final dynamic handle = await getFileHandle(resource);
      if (handle == null) {
        throw createFileSystemProviderError(resource,
            'No such file or directory, readFile', files.FileSystemProviderErrorCode.FileNotFound);
      }
      final dynamic file = await _callAsync(handle, 'getFile');
      return Uint8List.fromList(
        await _callAsync(file, 'arrayBuffer') as List<int>,
      );
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  /// 1:1: `async writeFile(resource, content, opts)`
  Future<void> writeFile(
    uri.URI resource,
    Uint8List content,
    Object? opts,
  ) async {
    try {
      dynamic handle = await getFileHandle(resource);

      // Validate target unless { create: true, overwrite: true }
      if (!_boolProp(opts, 'create') || !_boolProp(opts, 'overwrite')) {
        if (handle != null) {
          if (!_boolProp(opts, 'overwrite')) {
            throw createFileSystemProviderError(resource,
                'File already exists, writeFile', files.FileSystemProviderErrorCode.FileExists);
          }
        } else if (!_boolProp(opts, 'create')) {
          throw createFileSystemProviderError(resource,
              'No such file, writeFile', files.FileSystemProviderErrorCode.FileNotFound);
        }
      }

      // Create target as needed
      if (handle == null) {
        final dynamic parent =
            await getDirectoryHandle(_extUri.dirname(resource));
        if (parent == null) {
          throw createFileSystemProviderError(resource,
              'No such parent directory, writeFile', files.FileSystemProviderErrorCode.FileNotFound);
        }
        handle = await _callAsync(parent, 'getFileHandle',
            <Object?>[_extUri.basename(resource), <String, Object?>{'create': true}]);
        if (handle == null) {
          throw createFileSystemProviderError(resource,
              'Unable to create file , writeFile', files.FileSystemProviderErrorCode.Unknown);
        }
      }

      // Write to target overwriting any existing contents
      final dynamic writable = await _callAsync(handle, 'createWritable');
      await _callAsync(writable, 'write', <Object?>[content]);
      await _callAsync(writable, 'close');
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  // #endregion

  // #region Move/Copy/Delete/Create Folder

  /// 1:1: `async mkdir(resource)`
  Future<void> mkdir(uri.URI resource) async {
    try {
      final dynamic parent =
          await getDirectoryHandle(_extUri.dirname(resource));
      if (parent == null) {
        throw createFileSystemProviderError(resource,
            'No such parent directory, mkdir', files.FileSystemProviderErrorCode.FileNotFound);
      }
      await _callAsync(parent, 'getDirectoryHandle', <Object?>[
        _extUri.basename(resource),
        <String, Object?>{'create': true},
      ]);
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  /// 1:1: `async delete(resource, opts)`
  Future<void> delete(uri.URI resource, Object? opts) async {
    try {
      final dynamic parent =
          await getDirectoryHandle(_extUri.dirname(resource));
      if (parent == null) {
        throw createFileSystemProviderError(resource,
            'No such parent directory, delete', files.FileSystemProviderErrorCode.FileNotFound);
      }
      await _callAsync(parent, 'removeEntry', <Object?>[
        _extUri.basename(resource),
        <String, Object?>{'recursive': _boolProp(opts, 'recursive')},
      ]);
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  /// 1:1: `async rename(from, to, opts)`
  Future<void> rename(uri.URI from, uri.URI to, Object? opts) async {
    try {
      if (_extUri.isEqual(from, to)) {
        return; // no-op if the paths are the same
      }

      // Implement file rename by write + delete
      final dynamic fileHandle = await getFileHandle(from);
      if (fileHandle != null) {
        final dynamic file = await _callAsync(fileHandle, 'getFile');
        final Uint8List contents = Uint8List.fromList(
          await _callAsync(file, 'arrayBuffer') as List<int>,
        );
        await writeFile(
          to,
          contents,
          <String, Object?>{
            'create': true,
            'overwrite': _boolProp(opts, 'overwrite'),
            'unlock': false,
            'atomic': false,
          },
        );
        await delete(
          from,
          <String, Object?>{
            'recursive': false,
            'useTrash': false,
            'atomic': false,
          },
        );
      } else {
        throw createFileSystemProviderError(
          from,
          localize('fileSystemRenameError', 'Rename is only supported for files.'),
          files.FileSystemProviderErrorCode.Unavailable,
        );
      }
    } catch (error) {
      throw toFileSystemProviderError(error);
    }
  }

  // #endregion

  // #region File Watching

  final event.Emitter<List<files.IFileChange>> _onDidChangeFileEmitter =
      event.Emitter<List<files.IFileChange>>();

  /// 1:1: `readonly onDidChangeFile`
  event.Event<List<files.IFileChange>> get onDidChangeFile =>
      _onDidChangeFileEmitter.event;

  /// 1:1: `watch(resource, opts)`
  lifecycle.IDisposable watch(uri.URI resource, Object? opts) {
    final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();
    _doWatch(resource, opts, disposables).catchError((Object error) {
      logService.error(
        "[File Watcher ('FileSystemObserver')] Error: $error ($resource)",
      );
    });
    return disposables;
  }

  /// 1:1: `private async doWatch(resource, opts, disposables)`
  Future<void> _doWatch(
    uri.URI resource,
    Object? opts,
    lifecycle.DisposableStore disposables,
  ) async {
    if (!wfsa.WebFileSystemObserver.supported(htmlFileSystemGlobalThis)) {
      return;
    }
    final dynamic handle = await getHandle(resource);
    if (handle == null || disposables.isDisposed) {
      return;
    }

    // 1:1: `new (globalThis as any).FileSystemObserver(callback)`
    final dynamic ctor = _prop(htmlFileSystemGlobalThis, 'FileSystemObserver');
    final dynamic observer = Function.apply(ctor as Function, <Object?>[
      (List<dynamic> records) {
        if (disposables.isDisposed) return;
        final List<files.IFileChange> events = <files.IFileChange>[];
        for (final dynamic record in records) {
          final String type = _prop(record, 'type') as String;
          final List<dynamic> rawParts =
              (_prop(record, 'relativePathComponents') as List?) ??
                  <dynamic>[];
          final List<String> parts = rawParts
              .map((dynamic p) => p.toString())
              .toList(growable: false);
          final uri.URI target = resources.joinPath(resource, parts);
          if (logService.getLevel() == log.LogLevel.Trace) {
            logService.trace(
              "[File Watcher ('FileSystemObserver')] [$type] $target",
            );
          }
          switch (type) {
            case 'appeared':
              events.add(_FileChange(target, files.FileChangeType.ADDED));
              break;
            case 'disappeared':
              events.add(_FileChange(target, files.FileChangeType.DELETED));
              break;
            case 'modified':
              events.add(_FileChange(target, files.FileChangeType.UPDATED));
              break;
            case 'errored':
              logService.trace(
                "[File Watcher ('FileSystemObserver')] errored, disposing observer ($resource)",
              );
              disposables.dispose();
              break;
          }
        }
        if (events.isNotEmpty) {
          _onDidChangeFileEmitter.fire(events);
        }
      },
    ]);

    try {
      await _callAsync(
        observer,
        'observe',
        <Object?>[
          handle,
          _boolProp(opts, 'recursive')
              ? <String, Object?>{'recursive': true}
              : null,
        ],
      );
    } finally {
      if (disposables.isDisposed) {
        await _callAsync(observer, 'disconnect');
      } else {
        disposables.add(lifecycle.toDisposable(() {
          _callAsync(observer, 'disconnect');
        }));
      }
    }
  }

  // #endregion

  // #region File/Directory Handle Registry

  final Map<String, dynamic> _files = <String, dynamic>{};
  final Map<String, dynamic> _directories = <String, dynamic>{};

  /// 1:1: `registerFileHandle(handle)`
  Future<uri.URI> registerFileHandle(dynamic handle) =>
      registerHandle(handle, _files);

  /// 1:1: `registerDirectoryHandle(handle)`
  Future<uri.URI> registerDirectoryHandle(dynamic handle) =>
      registerHandle(handle, _directories);

  /// 1:1: `get directories()`
  Iterable<dynamic> get directories => _directories.values;

  /// 1:1: `private async registerHandle(handle, map)`
  Future<uri.URI> registerHandle(
    dynamic handle,
    Map<String, dynamic> map,
  ) async {
    final String name = _prop(handle, 'name') as String;
    String handleId = '/$name';

    // Compute a valid handle ID in case this exists already
    if (map.containsKey(handleId) &&
        !await _isSameEntry(map[handleId], handle)) {
      final String fileExt = path.posix.extname(name);
      final String fileName = path.posix.basename(name, fileExt);
      int handleIdCounter = 1;
      do {
        handleId = '/$fileName-${handleIdCounter++}$fileExt';
      } while (map.containsKey(handleId) &&
          !await _isSameEntry(map[handleId], handle));
    }

    map[handleId] = handle;

    // Remember in IndexedDB for future lookup
    try {
      await indexedDB?.runInTransaction(
        store,
        'readwrite',
        (idb.IDBObjectStore objectStore) =>
            _idbPut(objectStore, handle, handleId),
      );
    } catch (error) {
      logService.error(error);
    }

    return uri.URI.from(
      uri.UriComponents(scheme: network.Schemas.file, path: handleId),
    );
  }

  Future<bool> _isSameEntry(dynamic existing, dynamic handle) async =>
      await _callAsync(existing, 'isSameEntry', <Object?>[handle]) == true;

  idb.IDBRequest _idbPut(
    idb.IDBObjectStore objectStore,
    dynamic handle,
    Object key,
  ) =>
      objectStore.put(handle, key);

  idb.IDBRequest _idbGet(idb.IDBObjectStore objectStore, Object key) =>
      objectStore.get(key);

  /// 1:1: `async getHandle(resource)`
  Future<dynamic> getHandle(uri.URI resource) async {
    // First: try to find a well known handle first
    dynamic handle = await doGetHandle(resource);

    // Second: walk up parent directories and resolve handle if possible
    if (handle == null) {
      final dynamic parent =
          await getDirectoryHandle(_extUri.dirname(resource));
      if (parent != null) {
        final String name = resources.extUri.basename(resource);
        try {
          handle = await _callAsync(parent, 'getFileHandle', <Object?>[name]);
        } catch (_) {
          try {
            handle =
                await _callAsync(parent, 'getDirectoryHandle', <Object?>[name]);
          } catch (_) {
            // Ignore
          }
        }
      }
    }
    return handle;
  }

  /// 1:1: `private async getFileHandle(resource)`
  Future<dynamic> getFileHandle(uri.URI resource) async {
    dynamic handle = await doGetHandle(resource);
    if (wfsa.WebFileSystemAccess.isFileSystemFileHandle(handle)) {
      return handle;
    }

    final dynamic parent =
        await getDirectoryHandle(_extUri.dirname(resource));
    try {
      return await _callAsync(parent, 'getFileHandle',
          <Object?>[resources.extUri.basename(resource)]);
    } catch (_) {
      return null; // guard against possible DOMException
    }
  }

  /// 1:1: `async getDirectoryHandle(resource)`
  Future<dynamic> getDirectoryHandle(uri.URI resource) async {
    final dynamic handle = await doGetHandle(resource);
    if (handle != null &&
        wfsa.WebFileSystemAccess.isFileSystemDirectoryHandle(handle)) {
      return handle;
    }

    final uri.URI parentUri = _extUri.dirname(resource);
    if (_extUri.isEqual(parentUri, resource)) {
      return null; // return when root is reached to prevent infinite recursion
    }

    final dynamic parent = await getDirectoryHandle(parentUri);
    try {
      return await _callAsync(parent, 'getDirectoryHandle',
          <Object?>[resources.extUri.basename(resource)]);
    } catch (_) {
      return null; // guard against possible DOMException
    }
  }

  /// 1:1: `private async doGetHandle(resource)`
  Future<dynamic> doGetHandle(uri.URI resource) async {
    // We store file system handles with the `handle.name`
    // and as such require the resource to be on the root
    if (_extUri.dirname(resource).path != '/') {
      return null;
    }

    final String handleId = resource.path.replaceAll(RegExp(r'/$'), '');

    // First: check if we have a known handle stored in memory
    final dynamic inMemoryHandle = _files[handleId] ?? _directories[handleId];
    if (inMemoryHandle != null) {
      return inMemoryHandle;
    }

    // Second: check if we have a persisted handle in IndexedDB
    final dynamic persistedHandle = await indexedDB?.runInTransaction(
      store,
      'readonly',
      (idb.IDBObjectStore store) => _idbGet(store, handleId),
    );
    if (wfsa.WebFileSystemAccess.isFileSystemHandle(persistedHandle)) {
      bool hasPermissions =
          await _callAsync(persistedHandle, 'queryPermission') == 'granted';
      try {
        if (!hasPermissions) {
          hasPermissions =
              await _callAsync(persistedHandle, 'requestPermission') ==
                  'granted';
        }
      } catch (error) {
        logService.error(error); // this can fail with a DOMException
      }

      if (hasPermissions) {
        if (wfsa.WebFileSystemAccess.isFileSystemFileHandle(persistedHandle)) {
          _files[handleId] = persistedHandle;
        } else if (wfsa.WebFileSystemAccess
            .isFileSystemDirectoryHandle(persistedHandle)) {
          _directories[handleId] = persistedHandle;
        }
        return persistedHandle;
      }
    }

    // Third: fail with an error
    throw createFileSystemProviderError(
      resource,
      'No file system handle registered',
      files.FileSystemProviderErrorCode.Unavailable,
    );
  }

  // #endregion

  /// 1:1: `private toFileSystemProviderError(error)`
  files.FileSystemProviderError toFileSystemProviderError(Object error) {
    if (error is files.FileSystemProviderError) {
      return error; // avoid double conversion
    }

    String code = files.FileSystemProviderErrorCode.Unknown;
    Object converted = error;
    if (_errorName(error) == 'NotAllowedError') {
      converted = files.FileError(localize(
        'fileSystemNotAllowedError',
        'Insufficient permissions. Please retry and allow the operation.',
      ));
      code = files.FileSystemProviderErrorCode.Unavailable;
    }
    return files.createFileSystemProviderError(converted, code);
  }

  /// 1:1: `private createFileSystemProviderError(resource, msg, code)`
  files.FileSystemProviderError createFileSystemProviderError(
    uri.URI resource,
    String msg,
    String code,
  ) {
    return files.createFileSystemProviderError(
      files.FileError('$msg (${path.posix.normalize(resource.path)})'),
      code,
    );
  }
}
