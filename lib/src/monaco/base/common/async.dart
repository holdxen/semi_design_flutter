import 'dart:async';

// ---------------------------------------------------------------------------
// Incremental skeleton for vscode/src/vs/base/common/async.ts (1:1 API subset).
//
// Only the type needed by dependents is declared so far: CancelablePromise
// (source lines 20-22). The full async.ts implementation will be filled in
// when the base/common core SCC batch is ported.
// ---------------------------------------------------------------------------

/// 1:1: `export interface CancelablePromise<T> extends Promise<T> { cancel(): void }`
/// Dart Future cannot be structurally extended, so the carrier exposes the
/// source API: the promise operations plus `cancel()`. The concrete carrier is
/// created by event.ts `toPromise` (and later by async.ts createCancelablePromise).
abstract class CancelablePromise<T> {
  void cancel();
  Future<void> get done;
  Future<R> then<R>(FutureOr<R> Function(T value) action, {Function? onError});
  Future<T> catchError(Function onError, {bool Function(Object error)? test});
  Future<T> whenComplete(FutureOr<void> Function() action);
}
