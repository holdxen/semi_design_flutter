// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/utils/utilsCancellation.ts
// Translated 1:1. TS `new Promise((resolve, reject) => ...)` maps to a
// Completer; the ignore-early-dispose logic (`isImmediateRun`/`shouldDispose`)
// is preserved verbatim.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../base.dart' show IObservable, IReader;
import '../commonFacade/cancellation.dart'
    show CancellationError, CancellationToken, CancellationTokenSource;
import '../commonFacade/deps.dart' show strictEquals;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, DebugOwner;
import '../observables/derived.dart' show derived, ensureDerivedOptsRegistered;
import '../observables/derivedImpl.dart' show Derived;
import '../reactions/autorun.dart' show autorun;

/// Carrier for `{ isFinished, error, state }` from the mapped state observable.
class _WaitState<T> {
  _WaitState(this.isFinished, this.error, this.state);
  final bool isFinished;
  final Object? error;
  final T state;
}

/// 1:1: `waitForState` (3 overloads unified).
Future<T> waitForState<T>(
  IObservable<T> observable, [
  bool Function(T state)? predicate,
  Object? Function(T state)? isError,
  CancellationToken? cancellationToken,
]) {
  ensureDerivedOptsRegistered();
  final effectivePredicate = predicate ?? (state) =>
      (state as Object?) != null && state != null;
  final completer = Completer<T>();
  bool isImmediateRun = true;
  bool shouldDispose = false;

  // 1:1: `observable.map(...)` — Dart instantiates derived directly to keep
  // the concrete generic (the shared derived-opts bridge erases it to Object?).
  final IObservable<_WaitState<T>> stateObs = derived<_WaitState<T>, Object?>(
    observable,
    (IReader reader) => _WaitState<T>(
      effectivePredicate(observable.read(reader)),
      isError != null ? isError(observable.read(reader)) : false,
      observable.read(reader),
    ),
  );

  late final dynamic d;
  d = autorun((reader) {
    final _WaitState<T> value = stateObs.read(reader);
    final bool finished = value.isFinished;
    final Object? error = value.error;
    if (finished || (error != null && error != false)) {
      if (isImmediateRun) {
        shouldDispose = true;
      } else {
        (d as dynamic).dispose();
      }
      if (error != null && error != false) {
        final Object? rejectValue = identical(error, true) ? value.state : error;
        if (!completer.isCompleted) {
          completer.completeError(rejectValue as Object);
        }
      } else {
        if (!completer.isCompleted) completer.complete(value.state);
      }
    }
  });

  if (cancellationToken != null) {
    dynamic dc;
    dc = cancellationToken.onCancellationRequested((Object? _) {
      (d as dynamic).dispose();
      (dc as dynamic).dispose();
      if (!completer.isCompleted) completer.completeError(CancellationError());
    });
    if (cancellationToken.isCancellationRequested) {
      (d as dynamic).dispose();
      (dc as dynamic).dispose();
      if (!completer.isCompleted) completer.completeError(CancellationError());
      return completer.future;
    }
  }
  isImmediateRun = false;
  if (shouldDispose) {
    (d as dynamic).dispose();
  }
  return completer.future;
}

/// 1:1: `derivedWithCancellationToken` (2 overloads unified).
IObservable<T> derivedWithCancellationToken<T>(
  Object computeFnOrOwner, [
  Function? computeFn,
]) {
  late Function computeFnResolved;
  late DebugOwner owner;
  if (computeFn == null) {
    computeFnResolved = computeFnOrOwner as Function;
    owner = null;
  } else {
    owner = computeFnOrOwner;
    computeFnResolved = computeFn;
  }

  CancellationTokenSource? cancellationTokenSource;
  return Derived<T, Object?, Object?>(
    DebugNameData(owner, null, computeFnResolved),
    (reader, changeSummary) {
      if (cancellationTokenSource != null) {
        cancellationTokenSource!.dispose(true);
      }
      cancellationTokenSource = CancellationTokenSource();
      return (computeFnResolved as Function)(reader, cancellationTokenSource!.token) as T;
    },
    null,
    () => cancellationTokenSource?.dispose(),
    strictEquals,
    DebugLocation.ofCaller(),
  );
}
