// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/decorators/cancelPreviousCalls.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - TypeScript decorators do not exist in Dart. The decorator function is
//     exposed as a wrapper factory: `final decorated = cancelPreviousCalls(
//     object, 'methodName', object._method); decorated([arg1, arg2]);`
//     The wrapper keeps exactly the source's identity/WeakMap semantics.
//   - `WeakMap` -> `HashMap.identity()`; `Function.call(this, ...args)` ->
//     `Function.apply(originalMethod, args)` (Dart tear-offs are bound).
// ---------------------------------------------------------------------------

import 'dart:collection';

import '../cancellation.dart' as cancellation;
import '../lifecycle.dart' as lifecycle;
import '../types.dart' as types;

/// The wrapped method returned by [cancelPreviousCalls].
///
/// 1:1: TS `descriptor.value = function (this: TObject, ...args) { ... }`.
/// Dart has no rest parameters on a closure value, so arguments are passed as
/// a list; the token is still appended/replaced as the last argument.
typedef CancelPreviousCallsMethod = Object? Function([List<Object?> args]);

/// 1:1: `export function cancelPreviousCalls<...>(...)`
CancelPreviousCallsMethod cancelPreviousCalls<T extends lifecycle.Disposable>(
  T proto,
  String methodName,
  Function originalMethod,
) {
  types.assertDefined(originalMethod, "Method '$methodName' is not defined.");

  // The global map contains a `TObjectRecord` for each object instance that
  // uses this decorator, itself containing a {method name -> source} mapping.
  final Map<Object, lifecycle.DisposableMap<String,
      cancellation.CancellationTokenSource>> objectRecords =
      HashMap<Object,
          lifecycle.DisposableMap<String, cancellation.CancellationTokenSource>>
          .identity();

  return ([List<Object?> args = const []]) {
    // Dart's default `const []` is immutable; JS rest args are always mutable.
    final List<Object?> callArgs = List<Object?>.from(args);

    // Get or create the record for the current object instance.
    late lifecycle.DisposableMap<String, cancellation.CancellationTokenSource>
        record;
    final lifecycle.DisposableMap<String,
        cancellation.CancellationTokenSource>? existing = objectRecords[proto];
    if (existing == null) {
      record = lifecycle.DisposableMap<
          String, cancellation.CancellationTokenSource>();
      objectRecords[proto] = record;
      proto.register(lifecycle.toDisposable(() {
        objectRecords[proto]?.dispose();
        objectRecords.remove(proto);
      }));
    } else {
      record = existing;
    }

    // Cancel and dispose the source from the previous call.
    record.get(methodName)?.dispose(true);

    // Reuse the last argument as the parent token when it is a token.
    final Object? lastArgument =
        callArgs.isNotEmpty ? callArgs[callArgs.length - 1] : null;
    final cancellation.CancellationToken? token =
        cancellation.CancellationToken.isCancellationToken(lastArgument)
            ? lastArgument as cancellation.CancellationToken
            : null;

    final cancellation.CancellationTokenSource cancellationSource =
        cancellation.CancellationTokenSource(token);
    record.set(methodName, cancellationSource);

    if (cancellation.CancellationToken.isCancellationToken(lastArgument)) {
      callArgs[callArgs.length - 1] = cancellationSource.token;
    } else {
      callArgs.add(cancellationSource.token);
    }

    return Function.apply(originalMethod, callArgs);
  };
}
