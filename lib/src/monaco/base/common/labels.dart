// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/labels.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import 'extpath.dart' show hasDriveLetter, toSlashes;
import 'path.dart' show IPath, posix, sep, win32;
import 'platform.dart' show OS, OperatingSystem, isMacintosh, isWindows;
import 'resources.dart' show extUri, extUriIgnorePathCase;
import 'strings.dart' show rtrim, startsWithIgnoreCase;
import 'uri.dart' show UriChange, URI;

/// 1:1: `export interface IPathLabelFormatting`
class IPathLabelFormatting {
  final int os;
  final IUserHomeProvider? tildify;
  final IRelativePathProvider? relative;

  IPathLabelFormatting(this.os, {this.tildify, this.relative});
}

/// 1:1: `export interface IRelativePathProvider`
abstract class IRelativePathProvider {
  bool get noPrefix;
  IWorkspace getWorkspace();
  IWorkspaceFolder? getWorkspaceFolder(URI resource);
}

/// 1:1: `getWorkspace(): { folders: { uri, name? }[] }`
class IWorkspace {
  final List<IWorkspaceFolder> folders;
  IWorkspace(this.folders);
}

/// 1:1: `{ uri: URI; name?: string }`
class IWorkspaceFolder {
  final URI uri;
  final String? name;
  IWorkspaceFolder(this.uri, [this.name]);
}

/// 1:1: `export interface IUserHomeProvider`
abstract class IUserHomeProvider {
  URI get userHome;
}

/// 1:1: `export function getPathLabel`
String getPathLabel(URI resource, IPathLabelFormatting formatting) {
  final IUserHomeProvider? tildifier = formatting.tildify;
  final IRelativePathProvider? relatifier = formatting.relative;

  if (relatifier != null) {
    final String? relativePath = _getRelativePathLabel(resource, relatifier, formatting.os);
    if (relativePath != null) {
      return relativePath;
    }
  }

  String absolutePath = resource.fsPath;
  if (formatting.os == OperatingSystem.Windows && !isWindows) {
    absolutePath = absolutePath.replaceAll('/', '\\');
  } else if (formatting.os != OperatingSystem.Windows && isWindows) {
    absolutePath = absolutePath.replaceAll('\\', '/');
  }

  if (formatting.os != OperatingSystem.Windows && tildifier?.userHome != null) {
    final String userHome = tildifier!.userHome.fsPath;

    late final String userHomeCandidate;
    if (resource.scheme != tildifier.userHome.scheme && resource.path.length >= 2 && resource.path[0] == posix.sep && resource.path[1] != posix.sep) {
      userHomeCandidate = tildifier.userHome.withChanges(UriChange(path: resource.path)).fsPath;
    } else {
      userHomeCandidate = absolutePath;
    }

    absolutePath = tildify(userHomeCandidate, userHome, formatting.os);
  }

  final IPath pathLib = formatting.os == OperatingSystem.Windows ? win32 : posix;
  return pathLib.normalize(normalizeDriveLetter(absolutePath, formatting.os == OperatingSystem.Windows));
}

String? _getRelativePathLabel(URI resource, IRelativePathProvider relativePathProvider, int os) {
  final IPath pathLib = os == OperatingSystem.Windows ? win32 : posix;
  final Object extUriLib = os == OperatingSystem.Linux ? extUri : extUriIgnorePathCase;

  final IWorkspace workspace = relativePathProvider.getWorkspace();
  final IWorkspaceFolder? firstFolder = workspace.folders.isEmpty ? null : workspace.folders[0];
  if (firstFolder == null) {
    return null;
  }

  if (resource.scheme != firstFolder.uri.scheme && resource.path.length >= 2 && resource.path[0] == posix.sep && resource.path[1] != posix.sep) {
    resource = firstFolder.uri.withChanges(UriChange(path: resource.path));
  }

  final IWorkspaceFolder? folder = relativePathProvider.getWorkspaceFolder(resource);
  if (folder == null) {
    return null;
  }

  String? relativePathLabel;
  if (extUriLib == extUri ? extUri.isEqual(folder.uri, resource) : extUriIgnorePathCase.isEqual(folder.uri, resource)) {
    relativePathLabel = '';
  } else {
    relativePathLabel = (extUriLib == extUri ? extUri.relativePath(folder.uri, resource) : extUriIgnorePathCase.relativePath(folder.uri, resource)) ?? '';
  }

  if (relativePathLabel.isNotEmpty) {
    relativePathLabel = pathLib.normalize(relativePathLabel);
  }

  if (workspace.folders.length > 1 && !relativePathProvider.noPrefix) {
    final String rootName = folder.name ?? (extUriLib == extUri ? extUri.basenameOrAuthority(folder.uri) : extUriIgnorePathCase.basenameOrAuthority(folder.uri));
    relativePathLabel = relativePathLabel.isNotEmpty ? '$rootName • $relativePathLabel' : rootName;
  }

  return relativePathLabel;
}

/// 1:1: `export function normalizeDriveLetter`
String normalizeDriveLetter(String path, [bool? isWindowsOS]) {
  final bool resolved = isWindowsOS ?? isWindows;
  if (hasDriveLetter(path, resolved)) {
    return path[0].toUpperCase() + path.substring(1);
  }
  return path;
}

_MapEntry? normalizedUserHomeCached;

class _MapEntry {
  final String original;
  final String normalized;
  _MapEntry(this.original, this.normalized);
}

/// 1:1: `export function tildify`
String tildify(String path, String userHome, [int? os]) {
  final int resolvedOs = os ?? OS;
  if (resolvedOs == OperatingSystem.Windows || path.isEmpty || userHome.isEmpty) {
    return path;
  }

  String? normalizedUserHome = normalizedUserHomeCached?.original == userHome ? normalizedUserHomeCached!.normalized : null;
  if (normalizedUserHome == null) {
    normalizedUserHome = userHome;
    if (isWindows) {
      normalizedUserHome = toSlashes(normalizedUserHome);
    }
    normalizedUserHome = '${rtrim(normalizedUserHome, posix.sep)}${posix.sep}';
    normalizedUserHomeCached = _MapEntry(userHome, normalizedUserHome);
  }

  String normalizedPath = path;
  if (isWindows) {
    normalizedPath = toSlashes(normalizedPath);
  }

  if (resolvedOs == OperatingSystem.Linux ? normalizedPath.startsWith(normalizedUserHome) : startsWithIgnoreCase(normalizedPath, normalizedUserHome)) {
    return '~/${normalizedPath.substring(normalizedUserHome.length)}';
  }

  return path;
}

/// 1:1: `export function untildify`
String untildify(String path, String userHome) {
  // 1:1: `/^~($|\/|\\)/` with `$1` capture; replaceFirstMapped keeps the tail.
  final RegExp re = RegExp(r'^~($|/|\\)');
  return path.replaceFirstMapped(re, (Match m) => '$userHome${m.group(1) ?? ''}');
}

const String _ellipsis = '\u2026';
const String _unc = '\\\\';
final RegExp _urlSchemaRegexp = RegExp(r'^[^:/\\?#]+?://');
const String _home = '~';

/// 1:1: `export function shorten`
List<String> shorten(List<String> paths, [String? defaultPathSeparator]) {
  final String pathSeparator = defaultPathSeparator ?? sep;
  final List<String> shortenedPaths = List<String>.filled(paths.length, '');

  bool match = false;
  for (int pathIndex = 0; pathIndex < paths.length; pathIndex++) {
    String sepForPath = pathSeparator;
    final String originalPath = paths[pathIndex];

    if (originalPath.isEmpty) {
      shortenedPaths[pathIndex] = '.$sepForPath';
      continue;
    }

    // 1:1: `if (!originalPath)` — covers other JS falsy strings (none besides '').
    match = true;

    String prefix = '';
    String trimmedPath = originalPath;
    if (_urlSchemaRegexp.hasMatch(trimmedPath)) {
      final int idx = trimmedPath.indexOf('//');
      prefix = trimmedPath.substring(0, idx + 2);
      trimmedPath = trimmedPath.substring(idx + 2);
      sepForPath = '/';
    } else if (trimmedPath.indexOf(_unc) == 0) {
      final int idx = trimmedPath.indexOf(_unc);
      prefix = trimmedPath.substring(0, idx + _unc.length);
      trimmedPath = trimmedPath.substring(idx + _unc.length);
    } else if (trimmedPath.indexOf(sepForPath) == 0) {
      final int idx = trimmedPath.indexOf(sepForPath);
      prefix = trimmedPath.substring(0, idx + sepForPath.length);
      trimmedPath = trimmedPath.substring(idx + sepForPath.length);
    } else if (trimmedPath.indexOf(_home) == 0) {
      final int idx = trimmedPath.indexOf(_home);
      prefix = trimmedPath.substring(0, idx + _home.length);
      trimmedPath = trimmedPath.substring(idx + _home.length);
    }

    final List<String> segments = trimmedPath.split(sepForPath);
    for (int subpathLength = 1; match && subpathLength <= segments.length; subpathLength++) {
      for (int start = segments.length - subpathLength; match && start >= 0; start--) {
        match = false;
        String subpath = segments.sublist(start, start + subpathLength).join(sepForPath);

        for (int otherPathIndex = 0; !match && otherPathIndex < paths.length; otherPathIndex++) {
          if (otherPathIndex != pathIndex && paths[otherPathIndex].isNotEmpty && paths[otherPathIndex].indexOf(subpath) > -1) {
            final bool isSubpathEnding = (start + subpathLength == segments.length);
            final String subpathWithSep = (start > 0 && paths[otherPathIndex].indexOf(sepForPath) > -1) ? sepForPath + subpath : subpath;
            final bool isOtherPathEnding = paths[otherPathIndex].endsWith(subpathWithSep);
            match = !isSubpathEnding || isOtherPathEnding;
          }
        }

        if (!match) {
          String result = '';

          if (segments[0].endsWith(':') || prefix.isNotEmpty) {
            if (start == 1) {
              start = 0;
              subpathLength++;
              subpath = '${segments[0]}$sepForPath$subpath';
            }
            if (start > 0) {
              result = '${segments[0]}$sepForPath';
            }
            result = prefix + result;
          }

          if (start > 0) {
            result = result + _ellipsis + sepForPath;
          }

          result = result + subpath;

          if (start + subpathLength < segments.length) {
            if (start + subpathLength == segments.length - 1 && segments[segments.length - 1].isEmpty) {
              result = result + sepForPath;
            } else {
              result = result + sepForPath + _ellipsis;
            }
          }

          shortenedPaths[pathIndex] = result;
        }
      }
    }

    if (match) {
      shortenedPaths[pathIndex] = originalPath;
    }
  }

  return shortenedPaths;
}

/// 1:1: `export interface ISeparator`
class ISeparator {
  final String label;
  ISeparator(this.label);
}

class _Type {
  static const int TEXT = 0;
  static const int VARIABLE = 1;
  static const int SEPARATOR = 2;
}

class _Segment {
  final String value;
  final int type;
  _Segment(this.value, this.type);
}

/// 1:1: `export function template`
String template(String value, [Map<String, Object?>? values]) {
  final Map<String, Object?> resolved = values ?? <String, Object?>{};
  final List<_Segment> segments = <_Segment>[];

  bool inVariable = false;
  String curVal = '';
  for (int i = 0; i < value.length; i++) {
    final String char = value[i];
    if (char == r'$' || (inVariable && char == '{')) {
      if (curVal.isNotEmpty) {
        segments.add(_Segment(curVal, _Type.TEXT));
      }
      curVal = '';
      inVariable = true;
    } else if (char == '}' && inVariable) {
      final Object? resolvedValue = resolved[curVal];
      if (resolvedValue is String) {
        if (resolvedValue.isNotEmpty) {
          segments.add(_Segment(resolvedValue, _Type.VARIABLE));
        }
      } else if (resolvedValue != null) {
        final _Segment? prevSegment = segments.isEmpty ? null : segments[segments.length - 1];
        if (prevSegment == null || prevSegment.type != _Type.SEPARATOR) {
          segments.add(_Segment((resolvedValue as ISeparator).label, _Type.SEPARATOR));
        }
      }
      curVal = '';
      inVariable = false;
    } else {
      curVal += char;
    }
  }

  if (curVal.isNotEmpty && !inVariable) {
    segments.add(_Segment(curVal, _Type.TEXT));
  }

  return segments.where((_Segment segment) {
    if (segment.type == _Type.SEPARATOR) {
      final int index = segments.indexOf(segment);
      final _Segment? left = index > 0 ? segments[index - 1] : null;
      final _Segment? right = index + 1 < segments.length ? segments[index + 1] : null;
      return [left, right].every((_Segment? s) => s != null && (s.type == _Type.VARIABLE || s.type == _Type.TEXT) && s.value.isNotEmpty);
    }
    return true;
  }).map((_Segment segment) => segment.value).join();
}

/// 1:1: `export function mnemonicMenuLabel`
String mnemonicMenuLabel(String label, [bool? forceDisableMnemonics]) {
  if (isMacintosh || forceDisableMnemonics == true) {
    return label.replaceAllMapped(RegExp(r'\(&&\w\)|&&'), (_) => '').replaceAll('&', isMacintosh ? '&' : '&&');
  }
  return label.replaceAllMapped(RegExp(r'&&|&'), (Match m) => m.group(0) == '&' ? '&&' : '&');
}

/// 1:1: `export function mnemonicButtonLabel`
/// Source has two overloads returning either String or {withMnemonic, withoutMnemonic};
/// Dart carries both in one result object.
class MnemonicButtonLabelResult {
  final String withMnemonic;
  final String withoutMnemonic;
  MnemonicButtonLabelResult(this.withMnemonic, this.withoutMnemonic);
}

MnemonicButtonLabelResult mnemonicButtonLabel(String label, [bool forceDisableMnemonics = false]) {
  final String withoutMnemonic = label.replaceAllMapped(RegExp(r'\(&&\w\)|&&'), (_) => '');

  if (forceDisableMnemonics) {
    return MnemonicButtonLabelResult(withoutMnemonic, withoutMnemonic);
  }
  if (isMacintosh) {
    return MnemonicButtonLabelResult(withoutMnemonic, withoutMnemonic);
  }

  late final String withMnemonic;
  if (isWindows) {
    withMnemonic = label.replaceAllMapped(RegExp(r'&&|&'), (Match m) => m.group(0) == '&' ? '&&' : '&');
  } else {
    withMnemonic = label.replaceAll('&&', '_');
  }
  return MnemonicButtonLabelResult(withMnemonic, withoutMnemonic);
}

/// 1:1: `export function unmnemonicLabel`
String unmnemonicLabel(String label) => label.replaceAll('&', '&&');

/// 1:1: `export function splitRecentLabel`
Map<String, String> splitRecentLabel(String recentLabel) {
  if (recentLabel.endsWith(']')) {
    final int lastIndexOfSquareBracket = recentLabel.lastIndexOf(' [', recentLabel.length - 2);
    if (lastIndexOfSquareBracket != -1) {
      final Map<String, String> split = _splitName(recentLabel.substring(0, lastIndexOfSquareBracket));
      final String remoteNameWithSpace = recentLabel.substring(lastIndexOfSquareBracket);
      return <String, String>{'name': split['name']! + remoteNameWithSpace, 'parentPath': split['parentPath']!};
    }
  }
  return _splitName(recentLabel);
}

Map<String, String> _splitName(String fullPath) {
  final IPath p = fullPath.indexOf('/') != -1 ? posix : win32;
  final String name = p.basename(fullPath);
  final String parentPath = p.dirname(fullPath);
  if (name.isNotEmpty) {
    return <String, String>{'name': name, 'parentPath': parentPath};
  }
  return <String, String>{'name': parentPath, 'parentPath': ''};
}
