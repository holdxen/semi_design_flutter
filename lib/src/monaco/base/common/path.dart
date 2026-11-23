// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/path.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// VS Code's copy of the Node.js path library (v22.15.0). Translated 1:1.
// Adaptations (no algorithm changes):
//   - `str.charCodeAt(i)` -> `str.codeUnitAt(i)`; `slice` -> `substring`.
//   - varargs `...paths: string[]` -> `List<String> paths` parameters.
//   - object literals `win32`/`posix` -> `Win32Path`/`PosixPath` class instances
//     implementing `IPath`; method bodies are byte-for-byte control-flow equivalents.
//   - `{root,dir,base,ext,name}` -> mutable `ParsedPath` class.
//   - `_format.bind(null, sep)` -> `format()` calling `_format(sep, obj)`.
//   - `'x'.repeat(n)` -> `'x' * n`; `ErrorInvalidArgType` -> implements Exception.
// ---------------------------------------------------------------------------

import './process.dart' as process;

const int CHAR_UPPERCASE_A = 65; /* A */
const int CHAR_LOWERCASE_A = 97; /* a */
const int CHAR_UPPERCASE_Z = 90; /* Z */
const int CHAR_LOWERCASE_Z = 122; /* z */
const int CHAR_DOT = 46; /* . */
const int CHAR_FORWARD_SLASH = 47; /* / */
const int CHAR_BACKWARD_SLASH = 92; /* \ */
const int CHAR_COLON = 58; /* : */
const int CHAR_QUESTION_MARK = 63; /* ? */

class ErrorInvalidArgType implements Exception {
  final String code;
  final String message;
  ErrorInvalidArgType(String name, String expected, Object? actual)
      : code = 'ERR_INVALID_ARG_TYPE',
        message = _build(name, expected, actual);

  static String _build(String name, String expected, Object? actual) {
    // determiner: 'must be' or 'must not be'
    late String determiner;
    String exp = expected;
    if (exp.indexOf('not ') == 0) {
      determiner = 'must not be';
      exp = exp.replaceFirst(RegExp(r'^not '), '');
    } else {
      determiner = 'must be';
    }

    final String type = name.indexOf('.') != -1 ? 'property' : 'argument';
    String msg = 'The "$name" $type $determiner of type $exp';

    msg += '. Received type ${_typeof(actual)}';
    return msg;
  }

  @override
  String toString() => message;
}

String _typeof(Object? actual) {
  if (actual == null) return 'object';
  if (actual is String) return 'string';
  if (actual is num) return 'number';
  if (actual is bool) return 'boolean';
  if (actual is Function) return 'function';
  return 'object';
}

void validateObject(Object? pathObject, String name) {
  if (pathObject == null || pathObject is! Map && pathObject is! ParsedPath) {
    throw ErrorInvalidArgType(name, 'Object', pathObject);
  }
}

void validateString(Object? value, String name) {
  if (value is! String) {
    throw ErrorInvalidArgType(name, 'string', value);
  }
}

final bool platformIsWin32 = (process.platform == 'win32');

bool isPathSeparator(int? code) =>
    code == CHAR_FORWARD_SLASH || code == CHAR_BACKWARD_SLASH;

bool isPosixPathSeparator(int? code) => code == CHAR_FORWARD_SLASH;

bool isWindowsDeviceRoot(int code) =>
    (code >= CHAR_UPPERCASE_A && code <= CHAR_UPPERCASE_Z) ||
    (code >= CHAR_LOWERCASE_A && code <= CHAR_LOWERCASE_Z);

// Resolves . and .. elements in a path with directory names
String normalizeString(String path, bool allowAboveRoot, String separator,
    bool Function(int?) pathSep) {
  String res = '';
  int lastSegmentLength = 0;
  int lastSlash = -1;
  int dots = 0;
  int code = 0;
  for (int i = 0; i <= path.length; ++i) {
    if (i < path.length) {
      code = path.codeUnitAt(i);
    } else if (pathSep(code)) {
      break;
    } else {
      code = CHAR_FORWARD_SLASH;
    }

    if (pathSep(code)) {
      if (lastSlash == i - 1 || dots == 1) {
        // NOOP
      } else if (dots == 2) {
        if (res.length < 2 ||
            lastSegmentLength != 2 ||
            res.codeUnitAt(res.length - 1) != CHAR_DOT ||
            res.codeUnitAt(res.length - 2) != CHAR_DOT) {
          if (res.length > 2) {
            final int lastSlashIndex = res.lastIndexOf(separator);
            if (lastSlashIndex == -1) {
              res = '';
              lastSegmentLength = 0;
            } else {
              res = res.substring(0, lastSlashIndex);
              lastSegmentLength = res.length - 1 - res.lastIndexOf(separator);
            }
            lastSlash = i;
            dots = 0;
            continue;
          } else if (res.length != 0) {
            res = '';
            lastSegmentLength = 0;
            lastSlash = i;
            dots = 0;
            continue;
          }
        }
        if (allowAboveRoot) {
          res += res.length > 0 ? '$separator..' : '..';
          lastSegmentLength = 2;
        }
      } else {
        if (res.length > 0) {
          res += '$separator${path.substring(lastSlash + 1, i)}';
        } else {
          res = path.substring(lastSlash + 1, i);
        }
        lastSegmentLength = i - lastSlash - 1;
      }
      lastSlash = i;
      dots = 0;
    } else if (code == CHAR_DOT && dots != -1) {
      ++dots;
    } else {
      dots = -1;
    }
  }
  return res;
}

String formatExt(String ext) =>
    ext.isNotEmpty ? '${ext[0] == '.' ? '' : '.'}$ext' : '';

String _format(String sep, ParsedPath pathObject) {
  validateObject(pathObject, 'pathObject');
  final String dir = pathObject.dir.isNotEmpty ? pathObject.dir : pathObject.root;
  final String base = pathObject.base.isNotEmpty
      ? pathObject.base
      : '${pathObject.name.isNotEmpty ? pathObject.name : ''}${formatExt(pathObject.ext)}';
  if (dir.isEmpty) {
    return base;
  }
  return dir == pathObject.root ? '$dir$base' : '$dir$sep$base';
}

class ParsedPath {
  String root;
  String dir;
  String base;
  String ext;
  String name;
  ParsedPath({this.root = '', this.dir = '', this.base = '', this.ext = '', this.name = ''});
}

abstract class IPath {
  String normalize(String path);
  bool isAbsolute(String path);
  String join(List<String> paths);
  String resolve(List<String> pathSegments);
  String relative(String from, String to);
  String dirname(String path);
  String basename(String path, [String? suffix]);
  String extname(String path);
  String format(ParsedPath pathObject);
  ParsedPath parse(String path);
  String toNamespacedPath(String path);
  String get sep;
  String get delimiter;
  IPath? get win32;
  IPath? get posix;
}

// ---------------------------------------------------------------------------
// win32 implementation (TS `export const win32: IPath = { ... }`)
// ---------------------------------------------------------------------------
class Win32Path implements IPath {
  const Win32Path();

  @override
  String resolve(List<String> pathSegments) {
    String resolvedDevice = '';
    String resolvedTail = '';
    bool resolvedAbsolute = false;

    for (int i = pathSegments.length - 1; i >= -1; i--) {
      late String path;
      if (i >= 0) {
        path = pathSegments[i];
        validateString(path, 'paths[$i]');

        if (path.isEmpty) {
          continue;
        }
      } else if (resolvedDevice.isEmpty) {
        path = process.cwd();
      } else {
        path = process.env['=$resolvedDevice'] ?? process.cwd();

        if (path.length == 0 ||
            (path.substring(0, 2).toLowerCase() != resolvedDevice.toLowerCase() &&
                (path.length > 2 ? path.codeUnitAt(2) : 0) == CHAR_BACKWARD_SLASH)) {
          path = '$resolvedDevice\\';
        }
      }

      final int len = path.length;
      int rootEnd = 0;
      String device = '';
      bool isAbsolute = false;
      final int code = path.codeUnitAt(0);

      if (len == 1) {
        if (isPathSeparator(code)) {
          rootEnd = 1;
          isAbsolute = true;
        }
      } else if (isPathSeparator(code)) {
        isAbsolute = true;

        if (isPathSeparator(path.codeUnitAt(1))) {
          int j = 2;
          int last = j;
          while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
            j++;
          }
          if (j < len && j != last) {
            final String firstPart = path.substring(last, j);
            last = j;
            while (j < len && isPathSeparator(path.codeUnitAt(j))) {
              j++;
            }
            if (j < len && j != last) {
              last = j;
              while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
                j++;
              }
              if (j == len || j != last) {
                device = '\\\\$firstPart\\${path.substring(last, j)}';
                rootEnd = j;
              }
            }
          }
        } else {
          rootEnd = 1;
        }
      } else if (isWindowsDeviceRoot(code) && path.codeUnitAt(1) == CHAR_COLON) {
        device = path.substring(0, 2);
        rootEnd = 2;
        if (len > 2 && isPathSeparator(path.codeUnitAt(2))) {
          isAbsolute = true;
          rootEnd = 3;
        }
      }

      if (device.isNotEmpty) {
        if (resolvedDevice.isNotEmpty) {
          if (device.toLowerCase() != resolvedDevice.toLowerCase()) {
            continue;
          }
        } else {
          resolvedDevice = device;
        }
      }

      if (resolvedAbsolute) {
        if (resolvedDevice.isNotEmpty) {
          break;
        }
      } else {
        resolvedTail = '${path.substring(rootEnd)}\\$resolvedTail';
        resolvedAbsolute = isAbsolute;
        if (isAbsolute && resolvedDevice.isNotEmpty) {
          break;
        }
      }
    }

    resolvedTail = normalizeString(resolvedTail, !resolvedAbsolute, '\\', isPathSeparator);

    final String result = resolvedAbsolute
        ? '$resolvedDevice\\$resolvedTail'
        : '$resolvedDevice$resolvedTail';
    return result.isNotEmpty ? result : '.';
  }

  @override
  String normalize(String path) {
    validateString(path, 'path');
    final int len = path.length;
    if (len == 0) {
      return '.';
    }
    int rootEnd = 0;
    String? device;
    bool isAbsolute = false;
    final int code = path.codeUnitAt(0);

    if (len == 1) {
      return isPosixPathSeparator(code) ? '\\' : path;
    }
    if (isPathSeparator(code)) {
      isAbsolute = true;

      if (isPathSeparator(path.codeUnitAt(1))) {
        int j = 2;
        int last = j;
        while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
          j++;
        }
        if (j < len && j != last) {
          final String firstPart = path.substring(last, j);
          last = j;
          while (j < len && isPathSeparator(path.codeUnitAt(j))) {
            j++;
          }
          if (j < len && j != last) {
            last = j;
            while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
              j++;
            }
            if (j == len) {
              return '\\\\$firstPart\\${path.substring(last)}\\';
            }
            if (j != last) {
              device = '\\\\$firstPart\\${path.substring(last, j)}';
              rootEnd = j;
            }
          }
        }
      } else {
        rootEnd = 1;
      }
    } else if (isWindowsDeviceRoot(code) && path.codeUnitAt(1) == CHAR_COLON) {
      device = path.substring(0, 2);
      rootEnd = 2;
      if (len > 2 && isPathSeparator(path.codeUnitAt(2))) {
        isAbsolute = true;
        rootEnd = 3;
      }
    }

    String tail = rootEnd < len
        ? normalizeString(path.substring(rootEnd), !isAbsolute, '\\', isPathSeparator)
        : '';
    if (tail.isEmpty && !isAbsolute) {
      tail = '.';
    }
    if (tail.isNotEmpty && isPathSeparator(path.codeUnitAt(len - 1))) {
      tail += '\\';
    }
    if (!isAbsolute && device == null && path.contains(':')) {
      if (tail.length >= 2 &&
          isWindowsDeviceRoot(tail.codeUnitAt(0)) &&
          tail.codeUnitAt(1) == CHAR_COLON) {
        return '.\\$tail';
      }
      int index = path.indexOf(':');
      do {
        if (index == len - 1 ||
            (index + 1 < len && isPathSeparator(path.codeUnitAt(index + 1)))) {
          return '.\\$tail';
        }
      } while ((index = path.indexOf(':', index + 1)) != -1);
    }
    if (device == null) {
      return isAbsolute ? '\\$tail' : tail;
    }
    return isAbsolute ? '$device\\$tail' : '$device$tail';
  }

  @override
  bool isAbsolute(String path) {
    validateString(path, 'path');
    final int len = path.length;
    if (len == 0) {
      return false;
    }
    final int code = path.codeUnitAt(0);
    return isPathSeparator(code) ||
        (len > 2 &&
            isWindowsDeviceRoot(code) &&
            path.codeUnitAt(1) == CHAR_COLON &&
            isPathSeparator(path.codeUnitAt(2)));
  }

  @override
  String join(List<String> paths) {
    if (paths.isEmpty) {
      return '.';
    }

    String? joined;
    String? firstPart;
    for (int i = 0; i < paths.length; ++i) {
      final String arg = paths[i];
      validateString(arg, 'path');
      if (arg.isNotEmpty) {
        if (joined == null) {
          joined = firstPart = arg;
        } else {
          joined += '\\$arg';
        }
      }
    }

    if (joined == null) {
      return '.';
    }

    bool needsReplace = true;
    int slashCount = 0;
    if (firstPart != null && isPathSeparator(firstPart.codeUnitAt(0))) {
      ++slashCount;
      final int firstLen = firstPart.length;
      if (firstLen > 1 && isPathSeparator(firstPart.codeUnitAt(1))) {
        ++slashCount;
        if (firstLen > 2) {
          if (isPathSeparator(firstPart.codeUnitAt(2))) {
            ++slashCount;
          } else {
            needsReplace = false;
          }
        }
      }
    }
    if (needsReplace) {
      while (slashCount < joined.length && isPathSeparator(joined.codeUnitAt(slashCount))) {
        slashCount++;
      }
      if (slashCount >= 2) {
        joined = '\\${joined.substring(slashCount)}';
      }
    }

    return normalize(joined);
  }

  @override
  String relative(String from, String to) {
    validateString(from, 'from');
    validateString(to, 'to');

    if (from == to) {
      return '';
    }

    final String fromOrig = resolve([from]);
    final String toOrig = resolve([to]);

    if (fromOrig == toOrig) {
      return '';
    }

    from = fromOrig.toLowerCase();
    to = toOrig.toLowerCase();

    if (from == to) {
      return '';
    }

    if (fromOrig.length != from.length || toOrig.length != to.length) {
      final List<String> fromSplit = fromOrig.split('\\');
      final List<String> toSplit = toOrig.split('\\');
      if (fromSplit.last.isEmpty) {
        fromSplit.removeLast();
      }
      if (toSplit.last.isEmpty) {
        toSplit.removeLast();
      }

      final int fromLen = fromSplit.length;
      final int toLen = toSplit.length;
      final int length = fromLen < toLen ? fromLen : toLen;

      int i = 0;
      for (; i < length; i++) {
        if (fromSplit[i].toLowerCase() != toSplit[i].toLowerCase()) {
          break;
        }
      }

      if (i == 0) {
        return toOrig;
      } else if (i == length) {
        if (toLen > length) {
          return toSplit.sublist(i).join('\\');
        }
        if (fromLen > length) {
          return '..\\' * (fromLen - 1 - i) + '..';
        }
        return '';
      }

      return '..\\' * (fromLen - i) + toSplit.sublist(i).join('\\');
    }

    int fromStart = 0;
    while (fromStart < from.length && from.codeUnitAt(fromStart) == CHAR_BACKWARD_SLASH) {
      fromStart++;
    }
    int fromEnd = from.length;
    while (fromEnd - 1 > fromStart && from.codeUnitAt(fromEnd - 1) == CHAR_BACKWARD_SLASH) {
      fromEnd--;
    }
    final int fromLen = fromEnd - fromStart;

    int toStart = 0;
    while (toStart < to.length && to.codeUnitAt(toStart) == CHAR_BACKWARD_SLASH) {
      toStart++;
    }
    int toEnd = to.length;
    while (toEnd - 1 > toStart && to.codeUnitAt(toEnd - 1) == CHAR_BACKWARD_SLASH) {
      toEnd--;
    }
    final int toLen = toEnd - toStart;

    final int length = fromLen < toLen ? fromLen : toLen;
    int lastCommonSep = -1;
    int i = 0;
    for (; i < length; i++) {
      final int fromCode = from.codeUnitAt(fromStart + i);
      if (fromCode != to.codeUnitAt(toStart + i)) {
        break;
      } else if (fromCode == CHAR_BACKWARD_SLASH) {
        lastCommonSep = i;
      }
    }

    if (i != length) {
      if (lastCommonSep == -1) {
        return toOrig;
      }
    } else {
      if (toLen > length) {
        if (to.codeUnitAt(toStart + i) == CHAR_BACKWARD_SLASH) {
          return toOrig.substring(toStart + i + 1);
        }
        if (i == 2) {
          return toOrig.substring(toStart + i);
        }
      }
      if (fromLen > length) {
        if (from.codeUnitAt(fromStart + i) == CHAR_BACKWARD_SLASH) {
          lastCommonSep = i;
        } else if (i == 2) {
          lastCommonSep = 3;
        }
      }
      if (lastCommonSep == -1) {
        lastCommonSep = 0;
      }
    }

    String out = '';
    for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
      if (i == fromEnd || from.codeUnitAt(i) == CHAR_BACKWARD_SLASH) {
        out += out.isEmpty ? '..' : '\\..';
      }
    }

    toStart += lastCommonSep;

    if (out.isNotEmpty) {
      return '$out${toOrig.substring(toStart, toEnd)}';
    }

    if (toOrig.codeUnitAt(toStart) == CHAR_BACKWARD_SLASH) {
      ++toStart;
    }

    return toOrig.substring(toStart, toEnd);
  }

  @override
  String toNamespacedPath(String path) {
    if (path.isEmpty) {
      return path;
    }

    final String resolvedPath = resolve([path]);

    if (resolvedPath.length <= 2) {
      return path;
    }

    if (resolvedPath.codeUnitAt(0) == CHAR_BACKWARD_SLASH) {
      if (resolvedPath.codeUnitAt(1) == CHAR_BACKWARD_SLASH) {
        final int code = resolvedPath.codeUnitAt(2);
        if (code != CHAR_QUESTION_MARK && code != CHAR_DOT) {
          return '\\\\?\\UNC\\${resolvedPath.substring(2)}';
        }
      }
    } else if (isWindowsDeviceRoot(resolvedPath.codeUnitAt(0)) &&
        resolvedPath.codeUnitAt(1) == CHAR_COLON &&
        resolvedPath.codeUnitAt(2) == CHAR_BACKWARD_SLASH) {
      return '\\\\?\\$resolvedPath';
    }

    return resolvedPath;
  }

  @override
  String dirname(String path) {
    validateString(path, 'path');
    final int len = path.length;
    if (len == 0) {
      return '.';
    }
    int rootEnd = -1;
    int offset = 0;
    final int code = path.codeUnitAt(0);

    if (len == 1) {
      return isPathSeparator(code) ? path : '.';
    }

    if (isPathSeparator(code)) {
      rootEnd = offset = 1;

      if (isPathSeparator(path.codeUnitAt(1))) {
        int j = 2;
        int last = j;
        while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
          j++;
        }
        if (j < len && j != last) {
          last = j;
          while (j < len && isPathSeparator(path.codeUnitAt(j))) {
            j++;
          }
          if (j < len && j != last) {
            last = j;
            while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
              j++;
            }
            if (j == len) {
              return path;
            }
            if (j != last) {
              rootEnd = offset = j + 1;
            }
          }
        }
      }
    } else if (isWindowsDeviceRoot(code) && path.codeUnitAt(1) == CHAR_COLON) {
      rootEnd = len > 2 && isPathSeparator(path.codeUnitAt(2)) ? 3 : 2;
      offset = rootEnd;
    }

    int end = -1;
    bool matchedSlash = true;
    for (int i = len - 1; i >= offset; --i) {
      if (isPathSeparator(path.codeUnitAt(i))) {
        if (!matchedSlash) {
          end = i;
          break;
        }
      } else {
        matchedSlash = false;
      }
    }

    if (end == -1) {
      if (rootEnd == -1) {
        return '.';
      }
      end = rootEnd;
    }
    return path.substring(0, end);
  }

  @override
  String basename(String path, [String? suffix]) {
    if (suffix != null) {
      validateString(suffix, 'suffix');
    }
    validateString(path, 'path');
    int start = 0;
    int end = -1;
    bool matchedSlash = true;
    int i;

    if (path.length >= 2 &&
        isWindowsDeviceRoot(path.codeUnitAt(0)) &&
        path.codeUnitAt(1) == CHAR_COLON) {
      start = 2;
    }

    if (suffix != null && suffix.isNotEmpty && suffix.length <= path.length) {
      if (suffix == path) {
        return '';
      }
      int extIdx = suffix.length - 1;
      int firstNonSlashEnd = -1;
      for (i = path.length - 1; i >= start; --i) {
        final int code = path.codeUnitAt(i);
        if (isPathSeparator(code)) {
          if (!matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd == -1) {
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            if (code == suffix.codeUnitAt(extIdx)) {
              if (--extIdx == -1) {
                end = i;
              }
            } else {
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }

      if (start == end) {
        end = firstNonSlashEnd;
      } else if (end == -1) {
        end = path.length;
      }
      return path.substring(start, end);
    }
    for (i = path.length - 1; i >= start; --i) {
      if (isPathSeparator(path.codeUnitAt(i))) {
        if (!matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end == -1) {
        matchedSlash = false;
        end = i + 1;
      }
    }

    if (end == -1) {
      return '';
    }
    return path.substring(start, end);
  }

  @override
  String extname(String path) {
    validateString(path, 'path');
    int start = 0;
    int startDot = -1;
    int startPart = 0;
    int end = -1;
    bool matchedSlash = true;
    int preDotState = 0;

    if (path.length >= 2 &&
        path.codeUnitAt(1) == CHAR_COLON &&
        isWindowsDeviceRoot(path.codeUnitAt(0))) {
      start = startPart = 2;
    }

    for (int i = path.length - 1; i >= start; --i) {
      final int code = path.codeUnitAt(i);
      if (isPathSeparator(code)) {
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        if (startDot == -1) {
          startDot = i;
        } else if (preDotState != 1) {
          preDotState = 1;
        }
      } else if (startDot != -1) {
        preDotState = -1;
      }
    }

    if (startDot == -1 ||
        end == -1 ||
        preDotState == 0 ||
        (preDotState == 1 && startDot == end - 1 && startDot == startPart + 1)) {
      return '';
    }
    return path.substring(startDot, end);
  }

  @override
  String format(ParsedPath pathObject) => _format('\\', pathObject);

  @override
  ParsedPath parse(String path) {
    validateString(path, 'path');

    final ParsedPath ret = ParsedPath();
    if (path.isEmpty) {
      return ret;
    }

    final int len = path.length;
    int rootEnd = 0;
    int code = path.codeUnitAt(0);

    if (len == 1) {
      if (isPathSeparator(code)) {
        ret.root = ret.dir = path;
        return ret;
      }
      ret.base = ret.name = path;
      return ret;
    }
    if (isPathSeparator(code)) {
      rootEnd = 1;
      if (isPathSeparator(path.codeUnitAt(1))) {
        int j = 2;
        int last = j;
        while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
          j++;
        }
        if (j < len && j != last) {
          last = j;
          while (j < len && isPathSeparator(path.codeUnitAt(j))) {
            j++;
          }
          if (j < len && j != last) {
            last = j;
            while (j < len && !isPathSeparator(path.codeUnitAt(j))) {
              j++;
            }
            if (j == len) {
              rootEnd = j;
            } else if (j != last) {
              rootEnd = j + 1;
            }
          }
        }
      }
    } else if (isWindowsDeviceRoot(code) && path.codeUnitAt(1) == CHAR_COLON) {
      if (len <= 2) {
        ret.root = ret.dir = path;
        return ret;
      }
      rootEnd = 2;
      if (isPathSeparator(path.codeUnitAt(2))) {
        if (len == 3) {
          ret.root = ret.dir = path;
          return ret;
        }
        rootEnd = 3;
      }
    }
    if (rootEnd > 0) {
      ret.root = path.substring(0, rootEnd);
    }

    int startDot = -1;
    int startPart = rootEnd;
    int end = -1;
    bool matchedSlash = true;
    int i = path.length - 1;

    int preDotState = 0;

    for (; i >= rootEnd; --i) {
      code = path.codeUnitAt(i);
      if (isPathSeparator(code)) {
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        if (startDot == -1) {
          startDot = i;
        } else if (preDotState != 1) {
          preDotState = 1;
        }
      } else if (startDot != -1) {
        preDotState = -1;
      }
    }

    if (end != -1) {
      if (startDot == -1 ||
          preDotState == 0 ||
          (preDotState == 1 && startDot == end - 1 && startDot == startPart + 1)) {
        ret.base = ret.name = path.substring(startPart, end);
      } else {
        ret.name = path.substring(startPart, startDot);
        ret.base = path.substring(startPart, end);
        ret.ext = path.substring(startDot, end);
      }
    }

    if (startPart > 0 && startPart != rootEnd) {
      ret.dir = path.substring(0, startPart - 1);
    } else {
      ret.dir = ret.root;
    }

    return ret;
  }

  @override
  String get sep => '\\';
  @override
  String get delimiter => ';';
  @override
  IPath? get win32 => _win32Ref();
  @override
  IPath? get posix => _posixRef();
}

// ---------------------------------------------------------------------------
// posix implementation (TS `export const posix: IPath = { ... }`)
// ---------------------------------------------------------------------------
String _posixCwd() {
  if (platformIsWin32) {
    final RegExp regexp = RegExp(r'\\');
    final String cwd = process.cwd().replaceAll(regexp, '/');
    return cwd.substring(cwd.indexOf('/'));
  }
  return process.cwd();
}

class PosixPath implements IPath {
  const PosixPath();

  @override
  String resolve(List<String> pathSegments) {
    String resolvedPath = '';
    bool resolvedAbsolute = false;

    for (int i = pathSegments.length - 1; i >= 0 && !resolvedAbsolute; i--) {
      final String path = pathSegments[i];
      validateString(path, 'paths[$i]');

      if (path.isEmpty) {
        continue;
      }

      resolvedPath = '$path/$resolvedPath';
      resolvedAbsolute = path.codeUnitAt(0) == CHAR_FORWARD_SLASH;
    }

    if (!resolvedAbsolute) {
      final String cwd = _posixCwd();
      resolvedPath = '$cwd/$resolvedPath';
      resolvedAbsolute = cwd.codeUnitAt(0) == CHAR_FORWARD_SLASH;
    }

    resolvedPath = normalizeString(resolvedPath, !resolvedAbsolute, '/', isPosixPathSeparator);

    if (resolvedAbsolute) {
      return '/$resolvedPath';
    }
    return resolvedPath.isNotEmpty ? resolvedPath : '.';
  }

  @override
  String normalize(String path) {
    validateString(path, 'path');

    if (path.isEmpty) {
      return '.';
    }

    final bool isAbsolute = path.codeUnitAt(0) == CHAR_FORWARD_SLASH;
    final bool trailingSeparator =
        path.codeUnitAt(path.length - 1) == CHAR_FORWARD_SLASH;

    path = normalizeString(path, !isAbsolute, '/', isPosixPathSeparator);

    if (path.isEmpty) {
      if (isAbsolute) {
        return '/';
      }
      return trailingSeparator ? './' : '.';
    }
    if (trailingSeparator) {
      path += '/';
    }

    return isAbsolute ? '/$path' : path;
  }

  @override
  bool isAbsolute(String path) {
    validateString(path, 'path');
    return path.isNotEmpty && path.codeUnitAt(0) == CHAR_FORWARD_SLASH;
  }

  @override
  String join(List<String> paths) {
    if (paths.isEmpty) {
      return '.';
    }

    final List<String> parts = [];
    for (int i = 0; i < paths.length; ++i) {
      final String arg = paths[i];
      validateString(arg, 'path');
      if (arg.isNotEmpty) {
        parts.add(arg);
      }
    }

    if (parts.isEmpty) {
      return '.';
    }

    return normalize(parts.join('/'));
  }

  @override
  String relative(String from, String to) {
    validateString(from, 'from');
    validateString(to, 'to');

    if (from == to) {
      return '';
    }

    from = resolve([from]);
    to = resolve([to]);

    if (from == to) {
      return '';
    }

    const int fromStart = 1;
    final int fromEnd = from.length;
    final int fromLen = fromEnd - fromStart;
    const int toStart = 1;
    final int toLen = to.length - toStart;

    final int length = (fromLen < toLen ? fromLen : toLen);
    int lastCommonSep = -1;
    int i = 0;
    for (; i < length; i++) {
      final int fromCode = from.codeUnitAt(fromStart + i);
      if (fromCode != to.codeUnitAt(toStart + i)) {
        break;
      } else if (fromCode == CHAR_FORWARD_SLASH) {
        lastCommonSep = i;
      }
    }
    if (i == length) {
      if (toLen > length) {
        if (to.codeUnitAt(toStart + i) == CHAR_FORWARD_SLASH) {
          return to.substring(toStart + i + 1);
        }
        if (i == 0) {
          return to.substring(toStart + i);
        }
      } else if (fromLen > length) {
        if (from.codeUnitAt(fromStart + i) == CHAR_FORWARD_SLASH) {
          lastCommonSep = i;
        } else if (i == 0) {
          lastCommonSep = 0;
        }
      }
    }

    String out = '';
    for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
      if (i == fromEnd || from.codeUnitAt(i) == CHAR_FORWARD_SLASH) {
        out += out.isEmpty ? '..' : '/..';
      }
    }

    return '$out${to.substring(toStart + lastCommonSep)}';
  }

  @override
  String toNamespacedPath(String path) => path;

  @override
  String dirname(String path) {
    validateString(path, 'path');
    if (path.isEmpty) {
      return '.';
    }
    final bool hasRoot = path.codeUnitAt(0) == CHAR_FORWARD_SLASH;
    int end = -1;
    bool matchedSlash = true;
    for (int i = path.length - 1; i >= 1; --i) {
      if (path.codeUnitAt(i) == CHAR_FORWARD_SLASH) {
        if (!matchedSlash) {
          end = i;
          break;
        }
      } else {
        matchedSlash = false;
      }
    }

    if (end == -1) {
      return hasRoot ? '/' : '.';
    }
    if (hasRoot && end == 1) {
      return '//';
    }
    return path.substring(0, end);
  }

  @override
  String basename(String path, [String? suffix]) {
    if (suffix != null) {
      validateString(suffix, 'suffix');
    }
    validateString(path, 'path');

    int start = 0;
    int end = -1;
    bool matchedSlash = true;
    int i;

    if (suffix != null && suffix.isNotEmpty && suffix.length <= path.length) {
      if (suffix == path) {
        return '';
      }
      int extIdx = suffix.length - 1;
      int firstNonSlashEnd = -1;
      for (i = path.length - 1; i >= 0; --i) {
        final int code = path.codeUnitAt(i);
        if (code == CHAR_FORWARD_SLASH) {
          if (!matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd == -1) {
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            if (code == suffix.codeUnitAt(extIdx)) {
              if (--extIdx == -1) {
                end = i;
              }
            } else {
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }

      if (start == end) {
        end = firstNonSlashEnd;
      } else if (end == -1) {
        end = path.length;
      }
      return path.substring(start, end);
    }
    for (i = path.length - 1; i >= 0; --i) {
      if (path.codeUnitAt(i) == CHAR_FORWARD_SLASH) {
        if (!matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end == -1) {
        matchedSlash = false;
        end = i + 1;
      }
    }

    if (end == -1) {
      return '';
    }
    return path.substring(start, end);
  }

  @override
  String extname(String path) {
    validateString(path, 'path');
    int startDot = -1;
    int startPart = 0;
    int end = -1;
    bool matchedSlash = true;
    int preDotState = 0;
    for (int i = path.length - 1; i >= 0; --i) {
      final String char = path[i];
      if (char == '/') {
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        matchedSlash = false;
        end = i + 1;
      }
      if (char == '.') {
        if (startDot == -1) {
          startDot = i;
        } else if (preDotState != 1) {
          preDotState = 1;
        }
      } else if (startDot != -1) {
        preDotState = -1;
      }
    }

    if (startDot == -1 ||
        end == -1 ||
        preDotState == 0 ||
        (preDotState == 1 && startDot == end - 1 && startDot == startPart + 1)) {
      return '';
    }
    return path.substring(startDot, end);
  }

  @override
  String format(ParsedPath pathObject) => _format('/', pathObject);

  @override
  ParsedPath parse(String path) {
    validateString(path, 'path');

    final ParsedPath ret = ParsedPath();
    if (path.isEmpty) {
      return ret;
    }
    final bool isAbsolute = path.codeUnitAt(0) == CHAR_FORWARD_SLASH;
    late int start;
    if (isAbsolute) {
      ret.root = '/';
      start = 1;
    } else {
      start = 0;
    }
    int startDot = -1;
    int startPart = 0;
    int end = -1;
    bool matchedSlash = true;
    int i = path.length - 1;

    int preDotState = 0;

    for (; i >= start; --i) {
      final int code = path.codeUnitAt(i);
      if (code == CHAR_FORWARD_SLASH) {
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        if (startDot == -1) {
          startDot = i;
        } else if (preDotState != 1) {
          preDotState = 1;
        }
      } else if (startDot != -1) {
        preDotState = -1;
      }
    }

    if (end != -1) {
      final int s = startPart == 0 && isAbsolute ? 1 : startPart;
      if (startDot == -1 ||
          preDotState == 0 ||
          (preDotState == 1 && startDot == end - 1 && startDot == startPart + 1)) {
        ret.base = ret.name = path.substring(s, end);
      } else {
        ret.name = path.substring(s, startDot);
        ret.base = path.substring(s, end);
        ret.ext = path.substring(startDot, end);
      }
    }

    if (startPart > 0) {
      ret.dir = path.substring(0, startPart - 1);
    } else if (isAbsolute) {
      ret.dir = '/';
    }

    return ret;
  }

  @override
  String get sep => '/';
  @override
  String get delimiter => ':';
  @override
  IPath? get win32 => _win32Ref();
  @override
  IPath? get posix => _posixRef();
}

// posix.win32 = win32.win32 = win32; posix.posix = win32.posix = posix;
final IPath win32 = const Win32Path();
final IPath posix = const PosixPath();
IPath _win32Ref() => win32;
IPath _posixRef() => posix;

// Platform-selected exports (TS `export const normalize = ...`).
final String Function(String) normalize =
    platformIsWin32 ? win32.normalize : posix.normalize;
final bool Function(String) isAbsolute =
    platformIsWin32 ? win32.isAbsolute : posix.isAbsolute;
final String Function(List<String>) join =
    platformIsWin32 ? win32.join : posix.join;
final String Function(List<String>) resolve =
    platformIsWin32 ? win32.resolve : posix.resolve;
final String Function(String, String) relative =
    platformIsWin32 ? win32.relative : posix.relative;
final String Function(String) dirname =
    platformIsWin32 ? win32.dirname : posix.dirname;
final String Function(String, [String?]) basename =
    platformIsWin32 ? win32.basename : posix.basename;
final String Function(String) extname =
    platformIsWin32 ? win32.extname : posix.extname;
final String Function(ParsedPath) format =
    platformIsWin32 ? win32.format : posix.format;
final ParsedPath Function(String) parse =
    platformIsWin32 ? win32.parse : posix.parse;
final String Function(String) toNamespacedPath =
    platformIsWin32 ? win32.toNamespacedPath : posix.toNamespacedPath;
final String sep = platformIsWin32 ? win32.sep : posix.sep;
final String delimiter = platformIsWin32 ? win32.delimiter : posix.delimiter;
