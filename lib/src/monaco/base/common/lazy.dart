// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/lazy.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `enum LazyValueState` -> class + static const
// (call sites keep the same `LazyValueState.X` shape). JS `throw new Error(msg)`
// -> Dart `StateError(msg)`; structure, names, state machine and control flow
// are otherwise identical.
// ---------------------------------------------------------------------------

/// The states a [Lazy] value can be in.
class LazyValueState {
  const LazyValueState._();

  static const int Uninitialized = 0;
  static const int Running = 1;
  static const int Completed = 2;
}

/// A value that is computed at most once, on first access.
class Lazy<T> {
  int _state = LazyValueState.Uninitialized;
  T? _value;
  Object? _error;

  Lazy(this._executor);

  final T Function() _executor;

  /// True if the lazy value has been resolved.
  bool get hasValue => _state == LazyValueState.Completed;

  /// Get the wrapped value.
  ///
  /// This will force evaluation of the lazy value if it has not been resolved
  /// yet. Lazy values are only resolved once. `getValue` will re-throw
  /// exceptions that are hit while resolving the value.
  T get value {
    if (_state == LazyValueState.Uninitialized) {
      _state = LazyValueState.Running;
      try {
        _value = _executor();
      } catch (err) {
        _error = err;
      } finally {
        _state = LazyValueState.Completed;
      }
    } else if (_state == LazyValueState.Running) {
      throw StateError('Cannot read the value of a lazy that is being initialized');
    }

    if (_error != null) {
      throw _error!;
    }
    return _value!;
  }

  /// Get the wrapped value without forcing evaluation.
  T? get rawValue => _value;
}
