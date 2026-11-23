// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/decorators.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//   - TypeScript decorators do not exist in Dart. Each decorator is exposed as
//     an explicit wrapper factory taking `(instance, key, originalMethod)` and
//     returning a callable wrapper. The wrapper is bound to `instance`, which
//     is the Dart equivalent of the dynamic `this` in the source closures.
//   - Per-instance state (`this[$xxx$key]`) -> `HashMap.identity()` keyed by the
//     instance, matching the source's own-property semantics.
//   - `setTimeout` / `clearTimeout` -> `Timer` / `Timer.cancel`.
//   - `Date.now()` -> `DateTime.now().millisecondsSinceEpoch`.
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:collection';

export 'decorators/cancelPreviousCalls.dart';

/// Wrapped method returned by the Dart decorator factories.
///
/// Dart has no rest parameters on a closure value, so arguments are passed as
/// a single list.
typedef DecoratedMethod = Object? Function([List<Object?> args]);

/// Internal invoker shape used by [createDecorator].
typedef DecoratedInvoker = void Function(
    Object instance, List<Object?> args);

/// Decorator factory in Dart: `(instance, key, originalMethod) -> wrapper`.
typedef DecoratorFactory = DecoratedMethod Function(
    Object instance, String key, Function originalMethod);

/// 1:1: `function createDecorator(mapFn)`
DecoratorFactory createDecorator(
    DecoratedInvoker Function(Function fn, String key) mapFn) {
  return (Object instance, String key, Function originalMethod) {
    final DecoratedInvoker invoker = mapFn(originalMethod, key);
    return ([List<Object?> args = const []]) {
      invoker(instance, List<Object?>.from(args));
      return null;
    };
  };
}

/// 1:1: `export function memoize`
///
/// In TypeScript this mutates the property descriptor; in Dart it returns the
/// wrapped method, which the caller stores on the target.
DecoratedMethod memoize(Object instance, String key, Function originalMethod) {
  final String memoizeKey = r'$memoize$' + key;
  assert(memoizeKey.isNotEmpty);
  final Map<Object, Object?> cache = HashMap<Object, Object?>.identity();
  return ([List<Object?> args = const []]) {
    if (!cache.containsKey(instance)) {
      cache[instance] = Function.apply(originalMethod, args);
    }
    return cache[instance];
  };
}

/// 1:1: `export interface IDebounceReducer<T>`
typedef IDebounceReducer<T> = T Function(T previousValue, List<Object?> args);

/// 1:1: `export function debounce<T>`
DecoratorFactory debounce<T>(
  num delay, {
  IDebounceReducer<T>? reducer,
  T? Function()? initialValueProvider,
}) {
  return createDecorator((Function fn, String key) {
    final String timerKey = r'$debounce$' + key;
    final String resultKey = r'$debounce$result$' + key;
    final Map<Object, Timer> timers = HashMap<Object, Timer>.identity();
    final Map<Object, Object?> results = HashMap<Object, Object?>.identity();

    // Keep the keys referenced so the translation mirrors the source names.
    assert(timerKey.isNotEmpty && resultKey.isNotEmpty);

    return (Object instance, List<Object?> args) {
      if (!results.containsKey(instance)) {
        results[instance] = initialValueProvider?.call();
      }

      timers[instance]?.cancel();

      List<Object?> callArgs = List<Object?>.from(args);
      if (reducer != null) {
        results[instance] = reducer(results[instance] as T, args);
        callArgs = <Object?>[results[instance]];
      }

      timers[instance] = Timer(Duration(milliseconds: delay.toInt()), () {
        Function.apply(fn, callArgs);
        results[instance] = initialValueProvider?.call();
      });
    };
  });
}

/// 1:1: `export function throttle<T>`
DecoratorFactory throttle<T>(
  num delay, {
  IDebounceReducer<T>? reducer,
  T? Function()? initialValueProvider,
}) {
  return createDecorator((Function fn, String key) {
    final String timerKey = r'$throttle$timer$' + key;
    final String resultKey = r'$throttle$result$' + key;
    final String lastRunKey = r'$throttle$lastRun$' + key;
    final String pendingKey = r'$throttle$pending$' + key;
    final Map<Object, Timer> timers = HashMap<Object, Timer>.identity();
    final Map<Object, Object?> results = HashMap<Object, Object?>.identity();
    final Map<Object, num> lastRuns = HashMap<Object, num>.identity();
    final Map<Object, bool> pendings = HashMap<Object, bool>.identity();

    assert(timerKey.isNotEmpty &&
        resultKey.isNotEmpty &&
        lastRunKey.isNotEmpty &&
        pendingKey.isNotEmpty);

    return (Object instance, List<Object?> args) {
      if (!results.containsKey(instance)) {
        results[instance] = initialValueProvider?.call();
      }
      if (!lastRuns.containsKey(instance)) {
        lastRuns[instance] = -double.maxFinite;
      }

      if (reducer != null) {
        results[instance] = reducer(results[instance] as T, args);
      }

      if (pendings[instance] == true) {
        return;
      }

      final num now = DateTime.now().millisecondsSinceEpoch;
      final num nextTime = lastRuns[instance]! + delay;
      if (nextTime <= now) {
        lastRuns[instance] = now;
        Function.apply(fn, <Object?>[results[instance]]);
        results[instance] = initialValueProvider?.call();
      } else {
        pendings[instance] = true;
        timers[instance] = Timer(
            Duration(milliseconds: (nextTime - now).toInt()), () {
          pendings[instance] = false;
          lastRuns[instance] = DateTime.now().millisecondsSinceEpoch;
          Function.apply(fn, <Object?>[results[instance]]);
          results[instance] = initialValueProvider?.call();
        });
      }
    };
  });
}
