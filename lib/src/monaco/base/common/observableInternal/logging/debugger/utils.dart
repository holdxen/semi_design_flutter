// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/logging/debugger/utils.ts
// Translated 1:1 from TypeScript. The Node/DOM global `Timeout` + setTimeout/
// clearTimeout -> dart:async `Timer`. Generic object indexing (`target[key]`,
// `for (const key in source)`) -> `Map<String, Object?>`; the TS
// `!!x && typeof x === 'object'` truthy-object check -> [_isTruthyObject].
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../../lifecycle.dart' show IDisposable;

/// JS truthiness for the `!!x` half of the source's `!!x && typeof x === 'object'`
/// check (Maps carry JS plain objects in the Dart port; `null` is falsy).
bool _isTruthy(Object? value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.isNotEmpty;
  return true;
}

/// 1:1: `export class Debouncer implements IDisposable`
class Debouncer implements IDisposable {
  Timer? _timeout;

  /// 1:1: `public debounce(fn, timeoutMs)`
  void debounce(void Function() fn, num timeoutMs) {
    if (_timeout != null) {
      _timeout!.cancel();
    }
    _timeout = Timer(Duration(milliseconds: timeoutMs.round()), () {
      _timeout = null;
      fn();
    });
  }

  @override
  void dispose() {
    if (_timeout != null) {
      _timeout!.cancel();
    }
  }
}

/// 1:1: `export class Throttler implements IDisposable`
class Throttler implements IDisposable {
  Timer? _timeout;

  /// 1:1: `public throttle(fn, timeoutMs)`
  void throttle(void Function() fn, num timeoutMs) {
    if (_timeout == null) {
      _timeout = Timer(Duration(milliseconds: timeoutMs.round()), () {
        _timeout = null;
        fn();
      });
    }
  }

  @override
  void dispose() {
    if (_timeout != null) {
      _timeout!.cancel();
    }
  }
}

/// 1:1: `export function deepAssign<T>(target: T, source: T): void`
void deepAssign(Map<Object?, Object?> target, Map<Object?, Object?> source) {
  for (final Object? key in source.keys) {
    final Object? t = target[key];
    final Object? s = source[key];
    if (_isTruthy(t) && t is Map<Object?, Object?> && _isTruthy(s) && s is Map<Object?, Object?>) {
      deepAssign(t, s);
    } else {
      target[key] = s;
    }
  }
}

/// 1:1: `export function deepAssignDeleteNulls<T>(target: T, source: T): void`
void deepAssignDeleteNulls(
    Map<Object?, Object?> target, Map<Object?, Object?> source) {
  for (final Object? key in source.keys) {
    final Object? s = source[key];
    if (s == null) {
      target.remove(key);
    } else {
      final Object? t = target[key];
      if (_isTruthy(t) && t is Map<Object?, Object?> && _isTruthy(s) && s is Map<Object?, Object?>) {
        deepAssignDeleteNulls(t, s);
      } else {
        target[key] = s;
      }
    }
  }
}
