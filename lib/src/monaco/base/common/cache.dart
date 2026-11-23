// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/cache.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - Promise<T> -> Future<T>
//   - WeakMap<WeakKey, TComputed> -> HashMap.identity()
//   - TS constructor overloads collapsed to a single optional-options signature
// ---------------------------------------------------------------------------

import 'dart:collection';

import 'cancellation.dart' as cancellation;
import 'lifecycle.dart' as lifecycle;

/// 1:1: `export interface CacheResult<T> extends IDisposable`
abstract class CacheResult<T> implements lifecycle.IDisposable {
  Future<T> get promise;
}

/// 1:1: `export class Cache<T>`
class Cache<T> {
  _CacheResultImpl<T>? result;
  final Future<T> Function(cancellation.CancellationToken token) task;

  Cache(this.task);

  /// 1:1: `get(): CacheResult<T>`
  _CacheResultImpl<T> get() {
    final _CacheResultImpl<T>? existing = result;
    if (existing != null) {
      return existing;
    }
    final cancellation.CancellationTokenSource cts = cancellation.CancellationTokenSource();
    final Future<T> promise = task(cts.token);
    final _CacheResultImpl<T> r = _CacheResultImpl<T>(
      promise,
      () {
        result = null;
        cts.cancel();
        cts.dispose();
      },
    );
    result = r;
    return r;
  }
}

class _CacheResultImpl<T> implements CacheResult<T> {
  @override
  final Future<T> promise;
  final void Function() _dispose;
  _CacheResultImpl(this.promise, this._dispose);

  @override
  void dispose() => _dispose();
}

/// 1:1: `export function identity<T>(t)`
T identity<T>(T t) => t;

/// Fallback key selector for the `identity` overload: `(arg) => identity(arg)`,
/// typed to Object so it fits `Object Function(TArg)`.
Object _identityKey<TArg>(TArg arg) => arg as Object;

/// 1:1: `interface ICacheOptions<TArg>`
class ICacheOptions<TArg> {
  final Object Function(TArg arg) getCacheKey;
  ICacheOptions({required this.getCacheKey});
}

/// 1:1: `export class LRUCachedFunction` (caches just the last key/value)
class LRUCachedFunction<TArg, TComputed> {
  TComputed? lastCache;
  Object? lastArgKey;

  final TComputed Function(TArg arg) _fn;
  final Object Function(TArg arg) _computeKey;

  LRUCachedFunction(TComputed Function(TArg arg) fn)
      : _fn = fn,
        _computeKey = _identityKey<TArg>;

  LRUCachedFunction.withOptions(
    ICacheOptions<TArg> options,
    TComputed Function(TArg arg) fn,
  )   : _fn = fn,
        _computeKey = options.getCacheKey;

  TComputed get(TArg arg) {
    final Object key = _computeKey(arg);
    if (lastArgKey != key) {
      lastArgKey = key;
      lastCache = _fn(arg);
    }
    return lastCache as TComputed;
  }
}

/// 1:1: `export class CachedFunction` (unbounded)
class CachedFunction<TArg, TComputed> {
  final Map<TArg, TComputed> _map = <TArg, TComputed>{};
  final Map<Object, TComputed> _map2 = <Object, TComputed>{};

  Map<TArg, TComputed> get cachedValues => _map;

  final TComputed Function(TArg arg) _fn;
  final Object Function(TArg arg) _computeKey;

  CachedFunction(TComputed Function(TArg arg) fn)
      : _fn = fn,
        _computeKey = _identityKey<TArg>;

  CachedFunction.withOptions(
    ICacheOptions<TArg> options,
    TComputed Function(TArg arg) fn,
  )   : _fn = fn,
        _computeKey = options.getCacheKey;

  TComputed get(TArg arg) {
    final Object key = _computeKey(arg);
    final TComputed? mapped = _map2[key];
    if (mapped != null) {
      return mapped;
    }
    final TComputed value = _fn(arg);
    _map[arg] = value;
    _map2[key] = value;
    return value;
  }
}

/// 1:1: `export class WeakCachedFunction`
class WeakCachedFunction<TArg, TComputed> {
  final Map<Object, TComputed> _map = HashMap<Object, TComputed>.identity();

  final TComputed Function(TArg arg) _fn;
  final Object Function(TArg arg) _computeKey;

  WeakCachedFunction(TComputed Function(TArg arg) fn)
      : _fn = fn,
        _computeKey = _identityKey<TArg>;

  WeakCachedFunction.withOptions(
    ICacheOptions<TArg> options,
    TComputed Function(TArg arg) fn,
  )   : _fn = fn,
        _computeKey = options.getCacheKey;

  TComputed get(TArg arg) {
    final Object key = _computeKey(arg);
    final TComputed? mapped = _map[key];
    if (mapped != null) {
      return mapped;
    }
    final TComputed value = _fn(arg);
    _map[key] = value;
    return value;
  }
}
