// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/files/browser/webFileSystemAccess.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// Injectable property reader, standing in for JS `(obj as T)?.prop`.
///
/// The default handles `Map` carriers (the common opaque-object shape used
/// throughout this port); hosts may override it for DOM-like objects.
dynamic Function(dynamic obj, String name) webFileSystemAccessGetProp =
    (dynamic obj, String name) {
  if (obj == null) {
    return null;
  }
  if (obj is Map) {
    return obj[name];
  }
  return null;
};

dynamic _prop(dynamic obj, String name) => webFileSystemAccessGetProp(obj, name);

/// 1:1: `export namespace WebFileSystemAccess`
class WebFileSystemAccess {
  WebFileSystemAccess._();

  /// 1:1: `supported(obj: typeof globalThis): boolean`
  ///
  /// `typeof x === 'function'` -> `x is Function`; the optional property access
  /// on a dynamic carrier preserves the source's `(obj as ...)?` guard.
  static bool supported(dynamic obj) {
    if (obj == null) {
      return false;
    }
    final dynamic showDirectoryPicker = _prop(obj, 'showDirectoryPicker');
    if (showDirectoryPicker is Function) {
      return true;
    }

    return false;
  }

  /// 1:1: `isFileSystemHandle(handle: unknown): handle is FileSystemHandle`
  static bool isFileSystemHandle(dynamic handle) {
    final dynamic candidate = handle;
    if (candidate == null) {
      return false;
    }

    final dynamic kind = _prop(candidate, 'kind');
    final dynamic queryPermission = _prop(candidate, 'queryPermission');
    final dynamic requestPermission = _prop(candidate, 'requestPermission');
    return kind is String && queryPermission is Function && requestPermission is Function;
  }

  /// 1:1: `isFileSystemFileHandle(handle: FileSystemHandle): handle is FileSystemFileHandle`
  static bool isFileSystemFileHandle(dynamic handle) {
    return _prop(handle, 'kind') == 'file';
  }

  /// 1:1: `isFileSystemDirectoryHandle(handle: FileSystemHandle): handle is FileSystemDirectoryHandle`
  static bool isFileSystemDirectoryHandle(dynamic handle) {
    return _prop(handle, 'kind') == 'directory';
  }
}

/// 1:1: `export namespace WebFileSystemObserver`
class WebFileSystemObserver {
  WebFileSystemObserver._();

  /// 1:1: `supported(obj: typeof globalThis): boolean`
  static bool supported(dynamic obj) {
    if (obj == null) {
      return false;
    }
    final dynamic ctor = _prop(obj, 'FileSystemObserver');
    return ctor is Function;
  }
}

/// 1:1: `export interface FileSystemObserver` (type-only; opaque carrier).
abstract class FileSystemObserver {
  Future<void> observe(dynamic handle, [Map<String, bool>? options]);
  void unobserve(dynamic handle);
  void disconnect();
}

/// 1:1: `export interface FileSystemObserverRecord` (type-only; value carrier).
class FileSystemObserverRecord {
  FileSystemObserverRecord({
    required this.root,
    required this.changedHandle,
    required this.relativePathComponents,
    required this.type,
    this.relativePathMovedFrom,
  });

  final dynamic root;
  final dynamic changedHandle;
  final List<String> relativePathComponents;
  final String type;
  final List<String>? relativePathMovedFrom;
}
