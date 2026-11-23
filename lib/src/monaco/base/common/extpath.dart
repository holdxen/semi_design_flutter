// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/extpath.ts
// Translated 1:1 from TypeScript.
//   - `isNaN(charCodeAt)` for out-of-range -> explicit index check (-1 sentinel).
//   - `Number(segment)` -> `_jsNumber` (empty string / hex / Infinity semantics).
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import 'charCode.dart';
import 'path.dart' as path;
import 'platform.dart' as platform;
import 'strings.dart' as strings;
import 'types.dart' as types;

/// 1:1: `isPathSeparator`
bool isPathSeparator(int code) =>
    code == CharCode.Slash || code == CharCode.Backslash;

/// 1:1: `toSlashes`
String toSlashes(String osPath) =>
    osPath.replaceAllMapped(RegExp(r'[\\/]'), (Match m) => path.posix.sep);

final RegExp _driveLetterRe = RegExp(r'^[a-zA-Z]:(/|$)');

/// 1:1: `toPosixPath`
String toPosixPath(String osPath) {
  if (!osPath.contains('/')) {
    osPath = toSlashes(osPath);
  }
  if (_driveLetterRe.hasMatch(osPath)) {
    osPath = '/$osPath';
  }
  return osPath;
}

/// JS charCodeAt returns NaN for out-of-range; -1 sentinel here (isNaN → true).
int _charCodeAt(String s, int i) =>
    (i >= 0 && i < s.length) ? s.codeUnitAt(i) : -1;

/// 1:1: `getRoot`
String getRoot(String pathValue, [String sep = '/']) {
  if (pathValue.isEmpty) {
    return '';
  }

  final int len = pathValue.length;
  final int firstLetter = pathValue.codeUnitAt(0);
  if (isPathSeparator(firstLetter)) {
    if (isPathSeparator(_charCodeAt(pathValue, 1))) {
      // UNC candidate \\localhost\shares\ddd
      if (!isPathSeparator(_charCodeAt(pathValue, 2))) {
        int pos = 3;
        final int start = pos;
        for (; pos < len; pos++) {
          if (isPathSeparator(pathValue.codeUnitAt(pos))) {
            break;
          }
        }
        if (start != pos && !isPathSeparator(_charCodeAt(pathValue, pos + 1))) {
          pos += 1;
          for (; pos < len; pos++) {
            if (isPathSeparator(pathValue.codeUnitAt(pos))) {
              return pathValue
                  .substring(0, pos + 1)
                  .replaceAllMapped(RegExp(r'[\\/]'), (Match m) => sep);
            }
          }
        }
      }
    }
    // /user/far
    return sep;
  } else if (isWindowsDriveLetter(firstLetter)) {
    if (_charCodeAt(pathValue, 1) == CharCode.Colon) {
      if (isPathSeparator(_charCodeAt(pathValue, 2))) {
        // C:\fff
        return '${pathValue.substring(0, 2)}$sep';
      } else {
        // C:
        return pathValue.substring(0, 2);
      }
    }
  }

  // check for URI scheme://authority/path
  int pos = pathValue.indexOf('://');
  if (pos != -1) {
    pos += 3;
    for (; pos < len; pos++) {
      if (isPathSeparator(pathValue.codeUnitAt(pos))) {
        return pathValue.substring(0, pos + 1);
      }
    }
  }

  return '';
}

/// 1:1: `isUNC`
bool isUNC(String pathValue) {
  if (!platform.isWindows) {
    return false;
  }
  if (pathValue.isEmpty || pathValue.length < 5) {
    return false;
  }

  int code = pathValue.codeUnitAt(0);
  if (code != CharCode.Backslash) {
    return false;
  }
  code = pathValue.codeUnitAt(1);
  if (code != CharCode.Backslash) {
    return false;
  }

  int pos = 2;
  final int start = pos;
  for (; pos < pathValue.length; pos++) {
    code = pathValue.codeUnitAt(pos);
    if (code == CharCode.Backslash) {
      break;
    }
  }
  if (start == pos) {
    return false;
  }

  code = _charCodeAt(pathValue, pos + 1);
  if (code < 0 || code == CharCode.Backslash) {
    return false;
  }
  return true;
}

final RegExp _windowsInvalidFileChars = RegExp(r'[\\/:\*\?"<>\|]');
final RegExp _unixInvalidFileChars = RegExp(r'[/]');
final RegExp _windowsForbiddenNames =
    RegExp(r'^(con|prn|aux|clock\$|nul|lpt[0-9]|com[0-9])(\.(.*?))?$',
        caseSensitive: false);
final RegExp _onlyWhitespace = RegExp(r'^\s+$');

/// 1:1: `isValidBasename`
bool isValidBasename(String? name, [bool? isWindowsOS]) {
  final bool win = isWindowsOS ?? platform.isWindows;
  final RegExp invalidFileChars = win ? _windowsInvalidFileChars : _unixInvalidFileChars;

  if (name == null || name.isEmpty || _onlyWhitespace.hasMatch(name)) {
    return false;
  }
  if (invalidFileChars.hasMatch(name)) {
    return false;
  }
  if (win && _windowsForbiddenNames.hasMatch(name)) {
    return false;
  }
  if (name == '.' || name == '..') {
    return false;
  }
  if (win && name.endsWith('.')) {
    return false;
  }
  if (win && name.length != name.trim().length) {
    return false;
  }
  if (name.length > 255) {
    return false;
  }
  return true;
}

/// 1:1: `isEqual`
bool isEqual(String pathA, String pathB, [bool? ignoreCase]) {
  final bool identityEquals = pathA == pathB;
  if (ignoreCase != true || identityEquals) {
    return identityEquals;
  }
  if (pathA.isEmpty || pathB.isEmpty) {
    return false;
  }
  return strings.equalsIgnoreCase(pathA, pathB);
}

/// 1:1: `isEqualOrParent`
bool isEqualOrParent(String base, String parentCandidate,
    [bool? ignoreCase, bool forcePosixSemantics = false]) {
  final String separator = forcePosixSemantics ? path.posix.sep : path.sep;

  if (base == parentCandidate) {
    return true;
  }
  if (base.isEmpty || parentCandidate.isEmpty) {
    return false;
  }

  if (base.contains('..') || parentCandidate.contains('..')) {
    base = forcePosixSemantics
        ? path.posix.normalize(base)
        : path.normalize(base);
    parentCandidate = forcePosixSemantics
        ? path.posix.normalize(parentCandidate)
        : path.normalize(parentCandidate);
  }

  if (parentCandidate.length > base.length) {
    return false;
  }

  if (ignoreCase == true) {
    final bool beginsWith = strings.startsWithIgnoreCase(base, parentCandidate);
    if (!beginsWith) {
      return false;
    }
    if (parentCandidate.length == base.length) {
      return true;
    }
    int sepOffset = parentCandidate.length;
    if (_charAt(parentCandidate, parentCandidate.length - 1) == separator) {
      sepOffset--;
    }
    return _charAt(base, sepOffset) == separator;
  }

  if (_charAt(parentCandidate, parentCandidate.length - 1) != separator) {
    parentCandidate += separator;
  }
  return base.indexOf(parentCandidate) == 0;
}

String _charAt(String s, int i) =>
    (i >= 0 && i < s.length) ? s[i] : '';

/// 1:1: `isWindowsDriveLetter`
bool isWindowsDriveLetter(int char0) =>
    (char0 >= CharCode.A && char0 <= CharCode.Z) ||
    (char0 >= CharCode.a && char0 <= CharCode.z);

/// 1:1: `sanitizeFilePath`
String sanitizeFilePath(String candidate, String cwd) {
  if (platform.isWindows && candidate.endsWith(':')) {
    candidate += path.sep;
  }
  if (!path.isAbsolute(candidate)) {
    candidate = path.join(<String>[cwd, candidate]);
  }
  candidate = path.normalize(candidate);
  return removeTrailingPathSeparator(candidate);
}

/// 1:1: `removeTrailingPathSeparator`
String removeTrailingPathSeparator(String candidate) {
  if (platform.isWindows) {
    candidate = strings.rtrim(candidate, path.sep);
    if (candidate.endsWith(':')) {
      candidate += path.sep;
    }
  } else {
    candidate = strings.rtrim(candidate, path.sep);
    if (candidate.isEmpty) {
      candidate = path.sep;
    }
  }
  return candidate;
}

/// 1:1: `isRootOrDriveLetter`
bool isRootOrDriveLetter(String pathValue) {
  final String pathNormalized = path.normalize(pathValue);

  if (platform.isWindows) {
    if (pathValue.length > 3) {
      return false;
    }
    return hasDriveLetter(pathNormalized) &&
        (pathValue.length == 2 ||
            _charCodeAt(pathNormalized, 2) == CharCode.Backslash);
  }
  return pathNormalized == path.posix.sep;
}

/// 1:1: `hasDriveLetter`
bool hasDriveLetter(String pathValue, [bool? isWindowsOS]) {
  if (isWindowsOS ?? platform.isWindows) {
    return isWindowsDriveLetter(_charCodeAt(pathValue, 0)) &&
        _charCodeAt(pathValue, 1) == CharCode.Colon;
  }
  return false;
}

/// 1:1: `getDriveLetter`
String? getDriveLetter(String pathValue, [bool? isWindowsOS]) =>
    hasDriveLetter(pathValue, isWindowsOS) ? pathValue[0] : null;

/// 1:1: `indexOfPath`
int indexOfPath(String pathValue, String candidate, [bool? ignoreCase]) {
  if (candidate.length > pathValue.length) {
    return -1;
  }
  if (pathValue == candidate) {
    return 0;
  }
  if (ignoreCase == true) {
    pathValue = pathValue.toLowerCase();
    candidate = candidate.toLowerCase();
  }
  return pathValue.indexOf(candidate);
}

/// JS `Number(string)` semantics used by `parseLineAndColumnAware`.
num _jsNumber(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 0;
  }
  if (trimmed == 'Infinity' || trimmed == '+Infinity') {
    return double.infinity;
  }
  if (trimmed == '-Infinity') {
    return double.negativeInfinity;
  }
  final String lower = trimmed.toLowerCase();
  if (lower.startsWith('0x') || lower.startsWith('-0x') || lower.startsWith('+0x')) {
    final bool negative = lower.startsWith('-');
    final String digits = trimmed.startsWith('-') || trimmed.startsWith('+')
        ? trimmed.substring(3)
        : trimmed.substring(2);
    final int? parsed = int.tryParse(digits, radix: 16);
    if (parsed == null) {
      return double.nan;
    }
    return negative ? -parsed : parsed;
  }
  if (lower.startsWith('0b') || lower.startsWith('-0b') || lower.startsWith('+0b')) {
    final bool negative = lower.startsWith('-');
    final String digits = trimmed.startsWith('-') || trimmed.startsWith('+')
        ? trimmed.substring(3)
        : trimmed.substring(2);
    final int? parsed = int.tryParse(digits, radix: 2);
    if (parsed == null) {
      return double.nan;
    }
    return negative ? -parsed : parsed;
  }
  if (lower.startsWith('0o') || lower.startsWith('-0o') || lower.startsWith('+0o')) {
    final bool negative = lower.startsWith('-');
    final String digits = trimmed.startsWith('-') || trimmed.startsWith('+')
        ? trimmed.substring(3)
        : trimmed.substring(2);
    final int? parsed = int.tryParse(digits, radix: 8);
    if (parsed == null) {
      return double.nan;
    }
    return negative ? -parsed : parsed;
  }
  return num.tryParse(trimmed) ?? double.nan;
}

/// 1:1: `IPathWithLineAndColumn`
class IPathWithLineAndColumn {
  final String path;
  final num? line;
  final num? column;

  IPathWithLineAndColumn(this.path, this.line, this.column);

  @override
  String toString() => 'IPathWithLineAndColumn(path: $path, line: $line, column: $column)';
}

/// 1:1: `parseLineAndColumnAware`
IPathWithLineAndColumn parseLineAndColumnAware(String rawPath) {
  final List<String> segments = rawPath.split(':'); // C:\file.txt:<line>:<column>

  String? resultPath;
  num? line;
  num? column;

  for (final String segment in segments) {
    final num segmentAsNumber = _jsNumber(segment);
    if (!types.isNumber(segmentAsNumber)) {
      // A colon can well be part of a path (e.g. C:\...).
      resultPath = resultPath != null && resultPath.isNotEmpty
          ? '$resultPath:$segment'
          : segment;
    } else if (line == null) {
      line = segmentAsNumber;
    } else {
      column ??= segmentAsNumber;
    }
  }

  if (resultPath == null || resultPath.isEmpty) {
    throw StateError('Format for `--goto` should be: `FILE:LINE(:COLUMN)`');
  }

  return IPathWithLineAndColumn(
    resultPath,
    line,
    column ?? (line != null ? 1 : null),
  );
}

const String _pathChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const String _windowsSafePathFirstChars =
    'BDEFGHIJKMOQRSTUVWXYZbdefghijkmoqrstuvwxyz0123456789';

final math.Random _randomPathRandom = math.Random();

/// 1:1: `randomPath`
String randomPath([String? parent, String? prefix, int randomLength = 8]) {
  final StringBuffer suffix = StringBuffer();
  for (int i = 0; i < randomLength; i++) {
    final String pathCharsTouse;
    if (i == 0 && platform.isWindows && prefix == null && (randomLength == 3 || randomLength == 4)) {
      pathCharsTouse = _windowsSafePathFirstChars;
    } else {
      pathCharsTouse = _pathChars;
    }
    suffix.write(pathCharsTouse[_randomPathRandom.nextInt(pathCharsTouse.length)]);
  }

  // JS truthiness: empty strings are falsy as well.
  final String randomFileName =
      prefix != null && prefix.isNotEmpty ? '$prefix-$suffix' : suffix.toString();
  if (parent != null && parent.isNotEmpty) {
    return path.join(<String>[parent, randomFileName]);
  }
  return randomFileName;
}
