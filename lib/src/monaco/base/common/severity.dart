// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/severity.ts
// Translated 1:1 from TypeScript.
//   - `enum Severity` + `namespace Severity` merged into one class.
//   - `Severity.toString(...)` -> `toStringStatic(...)` (Dart static/instance clash).
// ---------------------------------------------------------------------------

import 'strings.dart' as strings;

/// 1:1: `Severity` (enum merged with its namespace).
class Severity {
  static const int Ignore = 0;
  static const int Info = 1;
  static const int Warning = 2;
  static const int Error = 3;

  static const String _error = 'error';
  static const String _warning = 'warning';
  static const String _warn = 'warn';
  static const String _info = 'info';
  static const String _ignore = 'ignore';

  /// 1:1: `Severity.fromValue`
  static int fromValue(String value) {
    if (value.isEmpty) {
      return Ignore;
    }
    if (strings.equalsIgnoreCase(_error, value)) {
      return Error;
    }
    if (strings.equalsIgnoreCase(_warning, value) ||
        strings.equalsIgnoreCase(_warn, value)) {
      return Warning;
    }
    if (strings.equalsIgnoreCase(_info, value)) {
      return Info;
    }
    return Ignore;
  }

  /// 1:1: `Severity.toString` (renamed: static cannot hide Object.toString).
  static String toStringStatic(int severity) {
    switch (severity) {
      case Error:
        return _error;
      case Warning:
        return _warning;
      case Info:
        return _info;
      default:
        return _ignore;
    }
  }
}
