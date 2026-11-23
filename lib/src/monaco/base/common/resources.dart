// 1:1 port of vscode/src/vs/base/common/resources.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Dart adaptations (no semantic change):
//   - `interface IExtUri` -> abstract class with getters only.
//   - `export const x = extUri.m.bind(extUri)` -> top-level forwarding functions.
//   - `namespace DataUri` -> class with static members.
//   - `uri.with({...})` -> `uri.withChanges(UriChange(...))`; an omitted TS
//     field keeps the current value, so `fragment: undefined` is expressed by
//     simply omitting that named argument.
//   - `console.error` -> `print`.

import 'charCode.dart';
import 'extpath.dart' as extpath;
import 'network.dart' show Schemas;
import 'path.dart' as paths;
import 'platform.dart' show isLinux, isWindows;
import 'strings.dart' as strings;
import 'uri.dart' show URI, UriChange, uriToFsPath;

/// 1:1: `export function originalFSPath`
String originalFSPath(URI uri) => uriToFsPath(uri, true);

//#region IExtUri

/// 1:1: `export interface IExtUri`
abstract class IExtUri {
  int compare(URI uri1, URI uri2, [bool ignoreFragment = false]);

  bool isEqual(URI? uri1, URI? uri2, [bool ignoreFragment = false]);

  bool isEqualOrParent(URI base, URI parentCandidate,
      [bool ignoreFragment = false, bool forcePosixSemantics = false]);

  String getComparisonKey(URI uri, [bool ignoreFragment = false]);

  bool ignorePathCasing(URI uri);

  String basenameOrAuthority(URI resource);

  String basename(URI resource, [String? suffix]);

  String extname(URI resource);

  URI dirname(URI resource);

  URI joinPath(URI resource, List<String> pathFragment);

  URI normalizePath(URI resource);

  String? relativePath(URI from, URI to);

  URI resolvePath(URI base, String path);

  bool isAbsolutePath(URI resource);

  bool isEqualAuthority(String? a1, String? a2);

  bool hasTrailingPathSeparator(URI resource, [String? sep]);

  URI removeTrailingPathSeparator(URI resource, [String? sep]);

  URI addTrailingPathSeparator(URI resource, [String? sep]);
}

/// 1:1: `export class ExtUri implements IExtUri`
class ExtUri implements IExtUri {
  final bool Function(URI uri) _ignorePathCasing;

  ExtUri(this._ignorePathCasing);

  @override
  int compare(URI uri1, URI uri2, [bool ignoreFragment = false]) {
    if (identical(uri1, uri2)) {
      return 0;
    }
    return strings.compare(
        getComparisonKey(uri1, ignoreFragment),
        getComparisonKey(uri2, ignoreFragment));
  }

  @override
  bool isEqual(URI? uri1, URI? uri2, [bool ignoreFragment = false]) {
    if (identical(uri1, uri2)) {
      return true;
    }
    if (uri1 == null || uri2 == null) {
      return false;
    }
    return getComparisonKey(uri1, ignoreFragment) ==
        getComparisonKey(uri2, ignoreFragment);
  }

  @override
  String getComparisonKey(URI uri, [bool ignoreFragment = false]) {
    final String path = _ignorePathCasing(uri) ? uri.path.toLowerCase() : uri.path;
    if (ignoreFragment) {
      // TS `fragment: ignoreFragment ? null : undefined`
      return uri.withChanges(UriChange(path: path, fragment: null)).toString();
    }
    return uri.withChanges(UriChange(path: path)).toString();
  }

  @override
  bool ignorePathCasing(URI uri) => _ignorePathCasing(uri);

  @override
  bool isEqualOrParent(URI base, URI parentCandidate,
      [bool ignoreFragment = false, bool forcePosixSemantics = false]) {
    if (base.scheme == parentCandidate.scheme) {
      if (base.scheme == Schemas.file) {
        return extpath.isEqualOrParent(originalFSPath(base),
                originalFSPath(parentCandidate), _ignorePathCasing(base)) &&
            base.query == parentCandidate.query &&
            (ignoreFragment || base.fragment == parentCandidate.fragment);
      }
      if (isEqualAuthority(base.authority, parentCandidate.authority)) {
        final bool ignoreCase = _ignorePathCasing(base);
        if (!extpath.isEqualOrParent(
            base.path, parentCandidate.path, ignoreCase, true)) {
          return false;
        }
        // Non-file URIs can still be backed by a Windows filesystem.
        if (!forcePosixSemantics &&
            (base.path.contains('\\') || parentCandidate.path.contains('\\'))) {
          final String basePath = extpath.toSlashes(
              paths.win32.normalize(originalFSPath(base)));
          final String parentPath = extpath.toSlashes(
              paths.win32.normalize(originalFSPath(parentCandidate)));
          if (!extpath.isEqualOrParent(basePath, parentPath, ignoreCase, true)) {
            return false;
          }
        }
        return base.query == parentCandidate.query &&
            (ignoreFragment || base.fragment == parentCandidate.fragment);
      }
    }
    return false;
  }

  // --- path math

  @override
  URI joinPath(URI resource, List<String> pathFragment) =>
      URI.joinPath(resource, pathFragment);

  @override
  String basenameOrAuthority(URI resource) =>
      basename(resource).isNotEmpty ? basename(resource) : resource.authority;

  @override
  String basename(URI resource, [String? suffix]) =>
      paths.posix.basename(resource.path, suffix);

  @override
  String extname(URI resource) => paths.posix.extname(resource.path);

  @override
  URI dirname(URI resource) {
    if (resource.path.isEmpty) {
      return resource;
    }
    late String dirnameValue;
    if (resource.scheme == Schemas.file) {
      dirnameValue = URI.file(paths.dirname(originalFSPath(resource))).path;
    } else {
      dirnameValue = paths.posix.dirname(resource.path);
      if (resource.authority.isNotEmpty &&
          dirnameValue.isNotEmpty &&
          dirnameValue.codeUnitAt(0) != CharCode.Slash) {
        // `console.error` -> `print`
        print('dirname("${resource.toString()}) resulted in a relative path');
        dirnameValue = '/'; // If a URI contains an authority component, then the path component must either be empty or begin with a CharCode.Slash ("/") character
      }
    }
    return resource.withChanges(UriChange(path: dirnameValue));
  }

  @override
  URI normalizePath(URI resource) {
    if (resource.path.isEmpty) {
      return resource;
    }
    late final String normalizedPath;
    if (resource.scheme == Schemas.file) {
      normalizedPath = URI.file(paths.normalize(originalFSPath(resource))).path;
    } else {
      normalizedPath = paths.posix.normalize(resource.path);
    }
    return resource.withChanges(UriChange(path: normalizedPath));
  }

  @override
  String? relativePath(URI from, URI to) {
    if (from.scheme != to.scheme ||
        !isEqualAuthority(from.authority, to.authority)) {
      return null;
    }
    if (from.scheme == Schemas.file) {
      final String relativePath =
          paths.relative(originalFSPath(from), originalFSPath(to));
      return isWindows ? extpath.toSlashes(relativePath) : relativePath;
    }
    String fromPath = from.path.isEmpty ? '/' : from.path;
    final String toPath = to.path.isEmpty ? '/' : to.path;
    if (_ignorePathCasing(from)) {
      // make casing of fromPath match toPath
      final int len = fromPath.length < toPath.length
          ? fromPath.length
          : toPath.length;
      int i = 0;
      for (; i < len; i++) {
        if (fromPath.codeUnitAt(i) != toPath.codeUnitAt(i)) {
          if (fromPath[i].toLowerCase() != toPath[i].toLowerCase()) {
            break;
          }
        }
      }
      fromPath = toPath.substring(0, i) + fromPath.substring(i);
    }
    return paths.posix.relative(fromPath, toPath);
  }

  @override
  URI resolvePath(URI base, String path) {
    if (base.scheme == Schemas.file) {
      final URI newURI =
          URI.file(paths.resolve(<String>[originalFSPath(base), path]));
      return base.withChanges(UriChange(
          authority: newURI.authority,
          path: newURI.path));
    }
    path = extpath.toPosixPath(path); // we allow path to be a windows path
    return base.withChanges(
        UriChange(path: paths.posix.resolve(<String>[base.path, path])));
  }

  // --- misc

  @override
  bool isAbsolutePath(URI resource) =>
      resource.path.isNotEmpty && resource.path[0] == '/';

  @override
  bool isEqualAuthority(String? a1, String? a2) =>
      a1 == a2 ||
      (a1 != null && a2 != null && strings.equalsIgnoreCase(a1, a2));

  @override
  bool hasTrailingPathSeparator(URI resource, [String? sep]) {
    final String separator = sep ?? paths.sep;
    if (resource.scheme == Schemas.file) {
      final String fsp = originalFSPath(resource);
      return fsp.length > extpath.getRoot(fsp).length &&
          fsp.isNotEmpty &&
          fsp[fsp.length - 1] == separator;
    } else {
      final String p = resource.path;
      return (p.length > 1 && p.codeUnitAt(p.length - 1) == CharCode.Slash) &&
          !RegExp(r'^[a-zA-Z]:(\/$|\\$)').hasMatch(resource.fsPath);
    }
  }

  @override
  URI removeTrailingPathSeparator(URI resource, [String? sep]) {
    final String separator = sep ?? paths.sep;
    // Make sure that the path isn't a drive letter. A trailing separator there is not removable.
    if (hasTrailingPathSeparator(resource, separator)) {
      return resource.withChanges(UriChange(
          path: resource.path.substring(0, resource.path.length - 1)));
    }
    return resource;
  }

  @override
  URI addTrailingPathSeparator(URI resource, [String? sep]) {
    String separator = sep ?? paths.sep;
    bool isRootSep = false;
    if (resource.scheme == Schemas.file) {
      final String fsp = originalFSPath(resource);
      isRootSep = fsp.isNotEmpty &&
          fsp.length == extpath.getRoot(fsp).length &&
          fsp[fsp.length - 1] == separator;
    } else {
      separator = '/';
      final String p = resource.path;
      isRootSep = p.length == 1 && p.codeUnitAt(p.length - 1) == CharCode.Slash;
    }
    if (!isRootSep && !hasTrailingPathSeparator(resource, separator)) {
      return resource.withChanges(UriChange(path: '${resource.path}/'));
    }
    return resource;
  }
}

/// Unbiased utility that takes uris "as they are". This means it can be
/// interchanged with `uri.toString()` usages.
///
/// 1:1: `export const extUri = new ExtUri(() => false)`
final ExtUri extUri = ExtUri((URI uri) => false);

/// BIASED utility that _mostly_ ignored the case of urs paths. ONLY use this
/// util if you understand what you are doing.
///
/// 1:1: `export const extUriBiasedIgnorePathCase`
final ExtUri extUriBiasedIgnorePathCase = ExtUri((URI uri) {
  // A file scheme resource is in the same platform as code, so ignore case for non linux platforms
  // Resource can be from another platform. Lowering the case as an hack. Should come from File system provider
  return uri.scheme == Schemas.file ? !isLinux : true;
});

/// BIASED utility that always ignores the casing of uris paths. ONLY use this
/// util if you understand what you are doing.
///
/// 1:1: `export const extUriIgnorePathCase`
final ExtUri extUriIgnorePathCase = ExtUri((URI uri) => true);

/// 1:1: `export const isEqual = extUri.isEqual.bind(extUri)`
bool isEqual(URI? uri1, URI? uri2, [bool ignoreFragment = false]) =>
    extUri.isEqual(uri1, uri2, ignoreFragment);

/// 1:1: `export const isEqualOrParent = extUri.isEqualOrParent.bind(extUri)`
bool isEqualOrParent(URI base, URI parentCandidate,
        [bool ignoreFragment = false, bool forcePosixSemantics = false]) =>
    extUri.isEqualOrParent(
        base, parentCandidate, ignoreFragment, forcePosixSemantics);

/// 1:1: `export const getComparisonKey`
String getComparisonKey(URI uri, [bool ignoreFragment = false]) =>
    extUri.getComparisonKey(uri, ignoreFragment);

/// 1:1: `export const basenameOrAuthority`
String basenameOrAuthority(URI resource) => extUri.basenameOrAuthority(resource);

/// 1:1: `export const basename`
String basename(URI resource, [String? suffix]) =>
    extUri.basename(resource, suffix);

/// 1:1: `export const extname`
String extname(URI resource) => extUri.extname(resource);

/// 1:1: `export const dirname`
URI dirname(URI resource) => extUri.dirname(resource);

/// 1:1: `export const joinPath`
URI joinPath(URI resource, List<String> pathFragment) =>
    extUri.joinPath(resource, pathFragment);

/// 1:1: `export const normalizePath`
URI normalizePath(URI resource) => extUri.normalizePath(resource);

/// 1:1: `export const relativePath`
String? relativePath(URI from, URI to) => extUri.relativePath(from, to);

/// 1:1: `export const resolvePath`
URI resolvePath(URI base, String path) => extUri.resolvePath(base, path);

/// 1:1: `export const isAbsolutePath`
bool isAbsolutePath(URI resource) => extUri.isAbsolutePath(resource);

/// 1:1: `export const isEqualAuthority`
bool isEqualAuthority(String? a1, String? a2) =>
    extUri.isEqualAuthority(a1, a2);

/// 1:1: `export const hasTrailingPathSeparator`
bool hasTrailingPathSeparator(URI resource, [String? sep]) =>
    extUri.hasTrailingPathSeparator(resource, sep);

/// 1:1: `export const removeTrailingPathSeparator`
URI removeTrailingPathSeparator(URI resource, [String? sep]) =>
    extUri.removeTrailingPathSeparator(resource, sep);

/// 1:1: `export const addTrailingPathSeparator`
URI addTrailingPathSeparator(URI resource, [String? sep]) =>
    extUri.addTrailingPathSeparator(resource, sep);

//#endregion

/// 1:1: `export function distinctParents<T>`
List<T> distinctParents<T>(
    List<T> items, URI Function(T item) resourceAccessor) {
  final List<T> distinctParents = <T>[];
  for (int i = 0; i < items.length; i++) {
    final URI candidateResource = resourceAccessor(items[i]);
    bool any = false;
    for (int index = 0; index < items.length; index++) {
      if (index == i) {
        continue;
      }
      if (isEqualOrParent(candidateResource, resourceAccessor(items[index]))) {
        any = true;
        break;
      }
    }
    if (any) {
      continue;
    }

    distinctParents.add(items[i]);
  }

  return distinctParents;
}

/// JS `String.prototype.substring` semantics: negative indices clamp to 0,
/// indices past the end clamp to the length, and the arguments are swapped
/// when `start > end`.
String _jsSubstring(String s, int start, int end) {
  final int len = s.length;
  int a = start < 0 ? 0 : (start > len ? len : start);
  int b = end < 0 ? 0 : (end > len ? len : end);
  if (a > b) {
    final int tmp = a;
    a = b;
    b = tmp;
  }
  return s.substring(a, b);
}

/// Data URI related helpers.
///
/// 1:1: `export namespace DataUri`
class DataUri {
  static const String META_DATA_LABEL = 'label';
  static const String META_DATA_DESCRIPTION = 'description';
  static const String META_DATA_SIZE = 'size';
  static const String META_DATA_MIME = 'mime';

  /// 1:1: `export function parseMetaData`
  static Map<String, String> parseMetaData(URI dataUri) {
    final Map<String, String> metadata = <String, String>{};

    // Given a URI of:  data:image/png;size:2313;label:SomeLabel;description:SomeDescription;base64,77+9UE5...
    // the metadata is: size:2313;label:SomeLabel;description:SomeDescription
    final String meta = _jsSubstring(dataUri.path,
        dataUri.path.indexOf(';') + 1, dataUri.path.lastIndexOf(';'));
    for (final String property in meta.split(';')) {
      final List<String> parts = property.split(':');
      final String key = parts[0];
      final String value = parts.length > 1 ? parts[1] : '';
      if (key.isNotEmpty && value.isNotEmpty) {
        metadata[key] = value;
      }
    }

    // Given a URI of:  data:image/png;size:2313;label:SomeLabel;description:SomeDescription;base64,77+9UE5...
    // the mime is: image/png
    final String mime =
        _jsSubstring(dataUri.path, 0, dataUri.path.indexOf(';'));
    if (mime.isNotEmpty) {
      metadata[META_DATA_MIME] = mime;
    }

    return metadata;
  }
}

/// 1:1: `export function toLocalResource`
URI toLocalResource(URI resource, String? authority, String localScheme) {
  if (authority != null && authority.isNotEmpty) {
    String path = resource.path;
    if (path.isNotEmpty && path[0] != paths.posix.sep) {
      path = paths.posix.sep + path;
    }

    return resource.withChanges(UriChange(
        scheme: localScheme, authority: authority, path: path));
  }

  return resource.withChanges(UriChange(scheme: localScheme));
}
