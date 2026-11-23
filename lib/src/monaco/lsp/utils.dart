// ---------------------------------------------------------------------------
// Port of monaco-editor/monaco-lsp-client/src/utils.ts
// Translated 1:1 from TypeScript. This is the LSP client's own standalone copy
// of Disposable/DisposableStore (it does not import the base lifecycle module).
//   - `Object.freeze<IDisposable>({ dispose(){} })` -> const _NoneDisposable.
//   - `console.warn(new Error(...).stack)` -> injectable provider, default
//     no-op, so the warning stays observable in tests.
//   - JS `if (!t)` truthiness check is vacuous for a non-nullable `T extends
//     IDisposable` under Dart null safety; kept as a documented comment.
// ---------------------------------------------------------------------------

/// 1:1: `export interface IDisposable`
abstract class IDisposable {
  void dispose();
}

/// 1:1: frozen singleton behind `Disposable.None`.
class _NoneDisposable implements IDisposable {
  const _NoneDisposable();

  @override
  void dispose() {}
}

/// 1:1: `export class Disposable implements IDisposable`
class Disposable implements IDisposable {
  /// 1:1: `static None = Object.freeze<IDisposable>({ dispose(){} })`
  static const IDisposable None = _NoneDisposable();

  final DisposableStore _store = DisposableStore();

  Disposable();

  @override
  void dispose() {
    _store.dispose();
  }

  /// 1:1: `protected _register<T extends IDisposable>(t: T): T`
  // ignore: unused_element
  T _register<T extends IDisposable>(T t) {
    if (identical(t, this)) {
      throw StateError('Cannot register a disposable on itself!');
    }
    return _store.add(t);
  }
}

/// Injectable `console.warn` for the disposed-store warning.
void Function(String? message) lspDisposableWarn = (String? message) {};

/// 1:1: `export class DisposableStore implements IDisposable`
class DisposableStore implements IDisposable {
  /// 1:1: `static DISABLE_DISPOSED_WARNING = false`
  static bool DISABLE_DISPOSED_WARNING = false;

  final Set<IDisposable> _toDispose = <IDisposable>{};
  bool _isDisposed = false;

  DisposableStore();

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    clear();
  }

  /// 1:1: `public clear(): void`
  void clear() {
    if (_toDispose.isEmpty) {
      return;
    }
    try {
      for (final IDisposable item in _toDispose) {
        item.dispose();
      }
    } finally {
      _toDispose.clear();
    }
  }

  /// 1:1: `public add<T extends IDisposable>(t: T): T`
  T add<T extends IDisposable>(T t) {
    // Source: `if (!t) { return t; }` — vacuous under Dart null safety.
    if (identical(t, this)) {
      throw StateError('Cannot register a disposable on itself!');
    }

    if (_isDisposed) {
      if (!DisposableStore.DISABLE_DISPOSED_WARNING) {
        lspDisposableWarn(
          'Trying to add a disposable to a DisposableStore that has already been disposed of. The added object will be leaked!',
        );
      }
    } else {
      _toDispose.add(t);
    }

    return t;
  }
}
