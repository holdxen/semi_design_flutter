// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/cancellation.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - TS `interface CancellationToken` + `namespace CancellationToken` merge ->
//     one abstract class with instance members (interface) + static members (namespace)
//   - Event<void> from event.dart
//   - AbortSignal/AbortController -> local carrier classes (Dart has no DOM)
//   - `Object.freeze` singletons -> final instances
//   - `callback.bind(context)` -> direct call (Dart has no `this` rebinding)
// ---------------------------------------------------------------------------

import 'dart:async';

import 'errors.dart' as errors;
import 'event.dart' as event;
import 'lifecycle.dart' as lifecycle;

/// 1:1: `export interface CancellationToken` + `export namespace CancellationToken`
abstract class CancellationToken {
  bool get isCancellationRequested;

  /// 1:1: `onCancellationRequested(listener, thisArgs?, disposables?)`
  lifecycle.IDisposable onCancellationRequested(
    dynamic listener, [
    dynamic thisArgs,
    List<lifecycle.IDisposable>? disposables,
  ]);

  /// 1:1: `export namespace CancellationToken` static members
  static bool isCancellationToken(Object? thing) {
    if (identical(thing, none) || identical(thing, cancelled)) {
      return true;
    }
    if (thing is MutableToken) {
      return true;
    }
    if (thing == null) {
      return false;
    }
    return thing is CancellationToken;
  }

  static final CancellationToken none = _NoneCancellationToken();
  static final CancellationToken cancelled = _CancelledCancellationToken();

  static void throwIfCanceled(CancellationToken token) {
    if (token.isCancellationRequested) {
      throw errors.CancellationError();
    }
  }

  /// 1:1: `CancellationToken.any(tokens, lifetime)`
  static CancellationToken any(
    List<CancellationToken> tokens,
    lifecycle.DisposableStore lifetime,
  ) {
    if (tokens.any((CancellationToken token) => token.isCancellationRequested)) {
      return cancelled;
    }
    final List<CancellationToken> active = <CancellationToken>{
      ...tokens.where((CancellationToken token) => !identical(token, none)),
    }.toList();
    if (active.length < 2) {
      return active.isEmpty ? none : active.first;
    }
    final CancellationTokenSource source = CancellationTokenSource();
    lifetime.add(lifecycle.toDisposable(() {
      if (!source.token.isCancellationRequested) {
        source.dispose();
      }
    }));
    final lifecycle.DisposableStore listeners =
        lifetime.add(lifecycle.DisposableStore());
    for (final CancellationToken token in active) {
      listeners.add(token.onCancellationRequested((Object? _) {
        listeners.dispose();
        source.cancel();
      }));
    }
    return source.token;
  }

  /// 1:1: `CancellationToken.fromAbortSignal(signal, lifetime)`
  static CancellationToken fromAbortSignal(
    _AbortSignal signal,
    lifecycle.DisposableStore lifetime,
  ) {
    if (signal.aborted) {
      return cancelled;
    }
    final MutableToken token = lifetime.add(MutableToken());
    final void Function() onAbort = () => token.cancel();
    signal.addEventListener('abort', onAbort);
    lifetime.add(
        lifecycle.toDisposable(() => signal.removeEventListener('abort', onAbort)));
    return token;
  }

  /// 1:1: `CancellationToken.toAbortSignal(token, lifetime)`
  static _AbortSignal toAbortSignal(
    CancellationToken token,
    lifecycle.DisposableStore lifetime,
  ) {
    if (identical(token, none)) {
      return _AbortSignal();
    }
    if (token.isCancellationRequested) {
      return _AbortSignal.abort(errors.CancellationError());
    }
    final _AbortController controller = _AbortController();
    lifetime.add(token.onCancellationRequested((Object? _) {
      controller.abort(errors.CancellationError());
    }));
    return controller.signal;
  }
}

/// 1:1: `const shortcutEvent: Event<void>`
final event.Event<void> shortcutEvent =
    (dynamic callback, [dynamic context, dynamic disposables]) {
  final Timer handle = Timer(Duration.zero, () {
    if (callback is Function) {
      callback();
    }
  });
  return lifecycle.toDisposable(handle.cancel);
};

class _NoneCancellationToken implements CancellationToken {
  @override
  bool get isCancellationRequested => false;

  @override
  lifecycle.IDisposable onCancellationRequested(
    dynamic listener, [
    dynamic thisArgs,
    List<lifecycle.IDisposable>? disposables,
  ]) =>
      lifecycle.Disposable.none;
}

class _CancelledCancellationToken implements CancellationToken {
  @override
  bool get isCancellationRequested => true;

  @override
  lifecycle.IDisposable onCancellationRequested(
    dynamic listener, [
    dynamic thisArgs,
    List<lifecycle.IDisposable>? disposables,
  ]) =>
      shortcutEvent(listener, thisArgs, disposables);
}

/// 1:1: `class MutableToken implements CancellationToken`
class MutableToken implements CancellationToken, lifecycle.IDisposable {
  bool _isCancelled = false;
  event.Emitter<void>? _emitter;

  void cancel() {
    if (!_isCancelled) {
      _isCancelled = true;
      if (_emitter != null) {
        _emitter!.fire(null);
        dispose();
      }
    }
  }

  @override
  bool get isCancellationRequested => _isCancelled;

  @override
  lifecycle.IDisposable onCancellationRequested(
    dynamic listener, [
    dynamic thisArgs,
    List<lifecycle.IDisposable>? disposables,
  ]) {
    if (_isCancelled) {
      return shortcutEvent(listener, thisArgs, disposables);
    }
    _emitter ??= event.Emitter<void>();
    return _emitter!.event(listener, thisArgs, disposables);
  }

  @override
  void dispose() {
    if (_emitter != null) {
      _emitter!.dispose();
      _emitter = null;
    }
  }
}

/// 1:1: `export class CancellationTokenSource`
class CancellationTokenSource implements lifecycle.IDisposable {
  CancellationToken? _token;
  lifecycle.IDisposable? _parentListener;

  CancellationTokenSource([CancellationToken? parent]) {
    if (parent != null) {
      _parentListener = parent.onCancellationRequested((Object? _) => cancel());
    }
  }

  CancellationToken get token {
    _token ??= MutableToken();
    return _token!;
  }

  void cancel() {
    if (_token == null) {
      _token = CancellationToken.cancelled;
    } else if (_token is MutableToken) {
      (_token as MutableToken).cancel();
    }
  }

  void dispose([bool cancel = false]) {
    if (cancel) {
      this.cancel();
    }
    _parentListener?.dispose();
    if (_token == null) {
      _token = CancellationToken.none;
    } else if (_token is MutableToken) {
      (_token as MutableToken).dispose();
    }
  }
}

/// 1:1: `export function cancelOnDispose(store)`
CancellationToken cancelOnDispose(lifecycle.DisposableStore store) {
  final CancellationTokenSource source = CancellationTokenSource();
  store.add(lifecycle.toDisposable(() => source.cancel()));
  return source.token;
}

/// 1:1: `abortOnDispose(store)`
_AbortSignal abortOnDispose(lifecycle.DisposableStore store) {
  final _AbortController controller = _AbortController();
  store.add(lifecycle.toDisposable(() => controller.abort(errors.CancellationError())));
  return controller.signal;
}

/// 1:1: `export class CancellationTokenPool`
class CancellationTokenPool {
  final CancellationTokenSource _source = CancellationTokenSource();
  final lifecycle.DisposableStore _listeners = lifecycle.DisposableStore();

  int _total = 0;
  int _cancelled = 0;
  bool _isDone = false;

  CancellationToken get token => _source.token;

  void add(CancellationToken token) {
    if (_isDone) {
      return;
    }
    _total++;
    if (token.isCancellationRequested) {
      _cancelled++;
      _check();
      return;
    }
    late final lifecycle.IDisposable d;
    d = token.onCancellationRequested((Object? _) {
      d.dispose();
      _cancelled++;
      _check();
    });
    _listeners.add(d);
  }

  void _check() {
    if (!_isDone && _total > 0 && _total == _cancelled) {
      _isDone = true;
      _listeners.dispose();
      _source.cancel();
    }
  }

  void dispose() {
    _listeners.dispose();
    _source.dispose();
  }
}

/// Dart carrier for JS AbortSignal (no DOM in Dart).
class _AbortSignal {
  bool _aborted = false;
  final Map<String, List<void Function()>> _listeners =
      <String, List<void Function()>>{};

  _AbortSignal();

  factory _AbortSignal.abort(Object? reason) {
    final _AbortSignal s = _AbortSignal();
    s._aborted = true;
    return s;
  }

  bool get aborted => _aborted;

  void addEventListener(String type, void Function() fn) {
    _listeners.putIfAbsent(type, () => <void Function()>[]).add(fn);
  }

  void removeEventListener(String type, void Function() fn) {
    _listeners[type]?.remove(fn);
  }

  void _abort(Object? reason) {
    if (_aborted) return;
    _aborted = true;
    for (final void Function() fn in List<void Function()>.from(_listeners['abort'] ?? <void Function()>[])) {
      fn();
    }
  }
}

/// Dart carrier for JS AbortController (no DOM in Dart).
class _AbortController {
  final _AbortSignal signal = _AbortSignal();
  void abort([Object? reason]) => signal._abort(reason);
}
