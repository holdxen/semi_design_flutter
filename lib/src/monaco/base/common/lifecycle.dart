// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/lifecycle.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - FinalizationRegistry (no weak refs in Dart) -> identity HashMap registry
//   - `Iterable.is` -> `IterableX.isIterable` (Dart `is` keyword)
//   - `[Symbol.iterator]()` -> `Iterable` base class / iterator getter
//   - `Object.freeze({dispose(){}})` singleton -> static final _NoneDisposable
//   - JS AggregateError -> local AggregateError class
//   - TS overload sets collapsed to single nullable/Iterable-accepting signatures
//   - RegExp stack parsing kept via RegExp; `String.replace('at ', '')` -> replaceFirst
// ---------------------------------------------------------------------------

import 'dart:collection';

import 'arrays.dart' as arrays;
import 'collections.dart' as collections;
import 'map.dart' as map;
import 'uri.dart' as uri;
import 'functional.dart' as functional;
import 'errors.dart' as errors;

const bool TRACK_DISPOSABLES = false;
IDisposableTracker? disposableTracker;

/// 1:1: `export interface IDisposableTracker`
abstract class IDisposableTracker {
  void trackDisposable(IDisposable disposable);
  void setParent(IDisposable child, IDisposable? parent);
  void markAsDisposed(IDisposable disposable);
  void markAsSingleton(IDisposable disposable);
}

/// 1:1: `export class GCBasedDisposableTracker`
/// Dart has no weak references; the registry is an identity map. register/unregister
/// mirror the source calls but retain objects (documented deviation, no GC semantics).
class GCBasedDisposableTracker implements IDisposableTracker {
  final Map<Object, String> _registry = HashMap<Object, String>.identity();

  @override
  void trackDisposable(IDisposable disposable) {
    // 1:1: heldValue is the allocation stack; in Dart we use a marker.
    _registry[disposable] = StackTrace.current.toString();
  }

  @override
  void setParent(IDisposable child, IDisposable? parent) {
    if (parent != null) {
      _registry.remove(child);
    } else {
      trackDisposable(child);
    }
  }

  @override
  void markAsDisposed(IDisposable disposable) {
    _registry.remove(disposable);
  }

  @override
  void markAsSingleton(IDisposable disposable) {
    _registry.remove(disposable);
  }
}

/// 1:1: `export interface DisposableInfo`
class DisposableInfo {
  IDisposable value;
  String? source;
  IDisposable? parent;
  bool isSingleton;
  int idx;

  DisposableInfo({
    required this.value,
    this.source,
    this.parent,
    this.isSingleton = false,
    required this.idx,
  });
}

/// 1:1: `export class DisposableTracker`
class DisposableTracker implements IDisposableTracker {
  static int idx = 0;

  final Map<IDisposable, DisposableInfo> livingDisposables =
      HashMap<IDisposable, DisposableInfo>.identity();

  DisposableInfo getDisposableData(IDisposable d) {
    DisposableInfo? val = livingDisposables[d];
    if (val == null) {
      val = DisposableInfo(
        parent: null,
        source: null,
        isSingleton: false,
        value: d,
        idx: DisposableTracker.idx++,
      );
      livingDisposables[d] = val;
    }
    return val;
  }

  @override
  void trackDisposable(IDisposable d, [Object? source]) {
    final DisposableInfo data = getDisposableData(d);
    if (data.source == null) {
      data.source = source?.toString() ?? StackTrace.current.toString();
    }
  }

  @override
  void setParent(IDisposable child, IDisposable? parent) {
    final DisposableInfo data = getDisposableData(child);
    data.parent = parent;
  }

  @override
  void markAsDisposed(IDisposable x) {
    livingDisposables.remove(x);
  }

  @override
  void markAsSingleton(IDisposable disposable) {
    getDisposableData(disposable).isSingleton = true;
  }

  DisposableInfo getRootParent(
    DisposableInfo data,
    Map<DisposableInfo, DisposableInfo> cache,
  ) {
    final DisposableInfo? cacheValue = cache[data];
    if (cacheValue != null) {
      return cacheValue;
    }

    final DisposableInfo result = data.parent != null
        ? getRootParent(getDisposableData(data.parent!), cache)
        : data;
    cache[data] = result;
    return result;
  }

  /// 1:1: `getTrackedDisposables(): IDisposable[]`
  List<IDisposable> getTrackedDisposables() {
    final Map<DisposableInfo, DisposableInfo> rootParentCache =
        <DisposableInfo, DisposableInfo>{};

    final List<IDisposable> leaking = livingDisposables.entries
        .where((MapEntry<IDisposable, DisposableInfo> entry) =>
            entry.value.source != null &&
            !getRootParent(entry.value, rootParentCache).isSingleton)
        .map((MapEntry<IDisposable, DisposableInfo> entry) => entry.key)
        .toList();

    return leaking;
  }

  /// 1:1: `computeLeakingDisposables(maxReported = 10, preComputedLeaks?)`
  ({List<DisposableInfo> leaks, String details})? computeLeakingDisposables(
      [int maxReported = 10, List<DisposableInfo>? preComputedLeaks]) {
    List<DisposableInfo>? uncoveredLeakingObjs;
    if (preComputedLeaks != null) {
      uncoveredLeakingObjs = preComputedLeaks;
    } else {
      final Map<DisposableInfo, DisposableInfo> rootParentCache =
          <DisposableInfo, DisposableInfo>{};

      final List<DisposableInfo> leakingObjects = livingDisposables.values
          .where((DisposableInfo info) =>
              info.source != null &&
              !getRootParent(info, rootParentCache).isSingleton)
          .toList();

      if (leakingObjects.isEmpty) {
        return null;
      }
      final Set<IDisposable> leakingObjsSet =
          leakingObjects.map((DisposableInfo o) => o.value).toSet();

      // Remove all objects that are a child of other leaking objects. Assumes no cycles.
      uncoveredLeakingObjs = leakingObjects.where((DisposableInfo l) {
        return !(l.parent != null && leakingObjsSet.contains(l.parent));
      }).toList();

      if (uncoveredLeakingObjs.isEmpty) {
        throw StateError('There are cyclic diposable chains!');
      }
    }

    List<String> getStackTracePath(DisposableInfo leaking) {
      void removePrefix(List<String> array, List<Object> linesToRemove) {
        while (array.isNotEmpty &&
            linesToRemove.any((Object regexp) => regexp is String
                ? regexp == array.first
                : (regexp as RegExp).hasMatch(array.first))) {
          array.removeAt(0);
        }
      }

      final String stackText = leaking.source ?? '';
      final List<String> lines = stackText
          .split('\n')
          .map((String p) => p.trim().replaceFirst('at ', ''))
          .where((String l) => l.isNotEmpty)
          .toList();
      removePrefix(lines, <Object>[
        'Error',
        RegExp(r'^trackDisposable \(.*\)$'),
        RegExp(r'^DisposableTracker.trackDisposable \(.*\)$'),
      ]);
      return lines.reversed.toList();
    }

    final map.SetMap<String, DisposableInfo> stackTraceStarts =
        map.SetMap<String, DisposableInfo>();
    for (final DisposableInfo leaking in uncoveredLeakingObjs) {
      final List<String> stackTracePath = getStackTracePath(leaking);
      for (int i = 0; i <= stackTracePath.length; i++) {
        stackTraceStarts.add(stackTracePath.sublist(0, i).join('\n'), leaking);
      }
    }

    // Put earlier leaks first
    uncoveredLeakingObjs.sort(
        arrays.compareBy((DisposableInfo l) => l.idx, arrays.numberComparator));

    String message = '';

    int i = 0;
    for (final DisposableInfo leaking in
        uncoveredLeakingObjs.length > maxReported
            ? uncoveredLeakingObjs.sublist(0, maxReported)
            : uncoveredLeakingObjs) {
      i++;
      final List<String> stackTracePath = getStackTracePath(leaking);
      final List<String> stackTraceFormattedLines = <String>[];

      for (int j = 0; j < stackTracePath.length; j++) {
        String line = stackTracePath[j];
        final Set<DisposableInfo> starts =
            stackTraceStarts.get(stackTracePath.sublist(0, j + 1).join('\n'));
        line = '(shared with ${starts.length}/${uncoveredLeakingObjs.length} leaks) at $line';

        final Set<DisposableInfo> prevStarts =
            stackTraceStarts.get(stackTracePath.sublist(0, j).join('\n'));
        final Map<String, List<String>> continuations = collections.groupBy(
          prevStarts.map((DisposableInfo d) {
            final List<String> p = getStackTracePath(d);
            return j < p.length ? p[j] : '';
          }).toList(),
          (String v) => v,
        );
        continuations.remove(stackTracePath[j]);
        for (final MapEntry<String, List<String>> entry in continuations.entries) {
          stackTraceFormattedLines.insert(
              0,
              '    - stacktraces of ${entry.value.length} other leaks continue with ${entry.key}');
        }

        stackTraceFormattedLines.insert(0, line);
      }

      message +=
          '\n\n\n==================== Leaking disposable $i/${uncoveredLeakingObjs.length}: ${leaking.value.runtimeType} ====================\n${stackTraceFormattedLines.join('\n')}\n============================================================\n\n';
    }

    if (uncoveredLeakingObjs.length > maxReported) {
      message +=
          '\n\n\n... and ${uncoveredLeakingObjs.length - maxReported} more leaking disposables\n\n';
    }

    return (leaks: uncoveredLeakingObjs, details: message);
  }
}

/// 1:1: `export function setDisposableTracker`
void setDisposableTracker(IDisposableTracker? tracker) {
  disposableTracker = tracker;
}

/// 1:1: `export function trackDisposable`
T trackDisposable<T extends IDisposable>(T x) {
  disposableTracker?.trackDisposable(x);
  return x;
}

/// 1:1: `export function markAsDisposed`
void markAsDisposed(IDisposable disposable) {
  disposableTracker?.markAsDisposed(disposable);
}

void setParentOfDisposable(IDisposable child, IDisposable? parent) {
  disposableTracker?.setParent(child, parent);
}

void setParentOfDisposables(List<IDisposable> children, IDisposable? parent) {
  final IDisposableTracker? tracker = disposableTracker;
  if (tracker == null) {
    return;
  }
  for (final IDisposable child in children) {
    tracker.setParent(child, parent);
  }
}

/// 1:1: `export function markAsSingleton`
T markAsSingleton<T extends IDisposable>(T singleton) {
  disposableTracker?.markAsSingleton(singleton);
  return singleton;
}

/// 1:1: `export interface IDisposable`
abstract class IDisposable {
  void dispose();
}

/// 1:1: JS `AggregateError` (used by dispose when multiple entries throw).
class AggregateError implements Exception {
  final List<Object> errors;
  final String message;
  AggregateError(this.errors, this.message);

  @override
  String toString() => '$message (${errors.length} errors)';
}

/// 1:1: `export function isDisposable`
bool isDisposable<E>(E thing) {
  return thing is Object && thing is! num && thing is! String && thing is! bool &&
      _hasZeroArgDispose(thing);
}

bool _hasZeroArgDispose(Object thing) {
  // Dart has no reflection; structural detection of a zero-arg dispose() is
  // approximated by the IDisposable interface check.
  return thing is IDisposable;
}

/// Internal alias: inside classes an instance method named `dispose()` shadows
/// the top-level function, so class bodies call this alias instead. 1:1 semantically.
Object? _disposeArg(Object? arg) => dispose(arg);

/// 1:1: `export function dispose` (overloads collapsed)
Object? dispose(Object? arg) {
  if (arg is Iterable) {
    final List<Object> errors = <Object>[];

    for (final Object? d in arg) {
      if (d != null) {
        try {
          (d as IDisposable).dispose();
        } catch (e) {
          errors.add(e);
        }
      }
    }

    if (errors.length == 1) {
      throw errors.first;
    } else if (errors.length > 1) {
      throw AggregateError(errors, 'Encountered errors while disposing of store');
    }

    return arg is List ? <Object>[] : arg;
  } else if (arg != null) {
    (arg as IDisposable).dispose();
    return arg;
  }
  return null;
}

/// 1:1: `export function disposeIfDisposable`
List<T> disposeIfDisposable<T extends Object>(List<T> disposables) {
  for (final T d in disposables) {
    if (isDisposable(d)) {
      (d as IDisposable).dispose();
    }
  }
  return <T>[];
}

/// 1:1: `export function combinedDisposable`
IDisposable combinedDisposable(List<IDisposable> disposables) {
  final IDisposable parent = toDisposable(() => dispose(disposables));
  setParentOfDisposables(disposables, parent);
  return parent;
}

/// 1:1: `class FunctionDisposable`
class FunctionDisposable implements IDisposable {
  bool _isDisposed;
  final void Function() _fn;

  FunctionDisposable(void Function() fn)
      : _isDisposed = false,
        _fn = fn {
    trackDisposable(this);
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    markAsDisposed(this);
    _fn();
  }
}

/// 1:1: `export function toDisposable`
IDisposable toDisposable(void Function() fn) => FunctionDisposable(fn);

class _NoneDisposable implements IDisposable {
  const _NoneDisposable();
  @override
  void dispose() {}
}

/// 1:1: `export class DisposableStore`
class DisposableStore implements IDisposable {
  static bool DISABLE_DISPOSED_WARNING = false;

  final Set<IDisposable> _toDispose = <IDisposable>{};
  bool _isDisposed = false;

  DisposableStore() {
    trackDisposable(this);
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    markAsDisposed(this);
    _isDisposed = true;
    clear();
  }

  bool get isDisposed => _isDisposed;

  void clear() {
    if (_toDispose.isEmpty) {
      return;
    }
    try {
      _disposeArg(_toDispose);
    } finally {
      _toDispose.clear();
    }
  }

  T add<T extends IDisposable>(T o) {
    if (identical(o, Disposable.none) || o is _NoneDisposable) {
      return o;
    }
    if (identical(o, this)) {
      throw StateError('Cannot register a disposable on itself!');
    }

    setParentOfDisposable(o, this);
    if (_isDisposed) {
      if (!DisposableStore.DISABLE_DISPOSED_WARNING) {
        // Source logs a warning with the stack; no-op in this port.
      }
    } else {
      _toDispose.add(o);
    }

    return o;
  }

  void delete<T extends IDisposable>(T o) {
    if (identical(o, this)) {
      throw StateError('Cannot dispose a disposable on itself!');
    }
    _toDispose.remove(o);
    o.dispose();
  }

  void deleteAndLeak<T extends IDisposable>(T o) {
    if (_toDispose.remove(o)) {
      setParentOfDisposable(o, null);
    }
  }

  void assertNotDisposed() {
    if (_isDisposed) {
      errors.onUnexpectedError(errors.BugIndicatingError('Object disposed'));
    }
  }
}

/// 1:1: `export abstract class Disposable`
abstract class Disposable implements IDisposable {
  static const IDisposable none = _NoneDisposable();

  final DisposableStore _store = DisposableStore();

  Disposable() {
    trackDisposable(this);
    setParentOfDisposable(_store, this);
  }

  @override
  void dispose() {
    markAsDisposed(this);
    _store.dispose();
  }

  T register<T extends IDisposable>(T o) {
    if (identical(o, this)) {
      throw StateError('Cannot register a disposable on itself!');
    }
    return _store.add(o);
  }
}

/// 1:1: `export class MutableDisposable`
class MutableDisposable<T extends IDisposable> implements IDisposable {
  T? _value;
  bool _isDisposed = false;

  MutableDisposable() {
    trackDisposable(this);
  }

  T? get value => _isDisposed ? null : _value;

  set value(T? value) {
    if (_isDisposed || value == _value) {
      return;
    }

    _value?.dispose();
    if (value != null) {
      setParentOfDisposable(value, this);
    }
    _value = value;
  }

  void clear() {
    value = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    markAsDisposed(this);
    _value?.dispose();
    _value = null;
  }

  T? clearAndLeak() {
    final T? oldValue = _value;
    _value = null;
    if (oldValue != null) {
      setParentOfDisposable(oldValue, null);
    }
    return oldValue;
  }
}

/// 1:1: `export class MandatoryMutableDisposable`
class MandatoryMutableDisposable<T extends IDisposable> implements IDisposable {
  final MutableDisposable<T> _disposable = MutableDisposable<T>();
  bool _isDisposed = false;

  MandatoryMutableDisposable(T initialValue) {
    _disposable.value = initialValue;
  }

  T get value => _disposable.value!;

  set value(T value) {
    if (_isDisposed || value == _disposable.value) {
      return;
    }
    _disposable.value = value;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposable.dispose();
  }
}

/// 1:1: `export class RefCountedDisposable`
class RefCountedDisposable {
  int _counter = 1;
  final IDisposable _disposable;

  RefCountedDisposable(this._disposable);

  RefCountedDisposable acquire() {
    _counter++;
    return this;
  }

  RefCountedDisposable release() {
    if (--_counter == 0) {
      _disposable.dispose();
    }
    return this;
  }
}

/// 1:1: `export interface IReference`
abstract class IReference<T> implements IDisposable {
  T get object;
}

/// 1:1: internal `{ object, counter }` record from ReferenceCollection.
class _ReferenceEntry<T> {
  final T object;
  int counter;
  _ReferenceEntry(this.object, this.counter);
}

/// 1:1: `export abstract class ReferenceCollection`
abstract class ReferenceCollection<T> {
  final Map<String, _ReferenceEntry<T>> references =
      <String, _ReferenceEntry<T>>{};

  IReference<T> acquire(String key, [List<Object?> args = const <Object?>[]]) {
    _ReferenceEntry<T>? reference = references[key];

    if (reference == null) {
      reference = _ReferenceEntry<T>(createReferencedObject(key, args), 0);
      references[key] = reference;
    }

    final T object = reference.object;
    final _ReferenceEntry<T> ref = reference;
    final void Function() disposeFn = functional.createSingleCallFunction(() {
      final int counter = ref.counter - 1;
      ref.counter = counter;
      if (counter == 0) {
        destroyReferencedObject(key, ref.object);
        references.remove(key);
      }
    });

    reference.counter++;

    return _ReferenceImpl<T>(object, disposeFn);
  }

  T createReferencedObject(String key, List<Object?> args);
  void destroyReferencedObject(String key, T object);
}

class _ReferenceImpl<T> implements IReference<T> {
  @override
  final T object;
  final void Function() _dispose;
  _ReferenceImpl(this.object, this._dispose);
  @override
  void dispose() => _dispose();
}

/// 1:1: `export class AsyncReferenceCollection`
class AsyncReferenceCollection<T> {
  final ReferenceCollection<Future<T>> referenceCollection;
  AsyncReferenceCollection(this.referenceCollection);

  Future<IReference<T>> acquire(String key, [List<Object?> args = const <Object?>[]]) async {
    final IReference<Future<T>> ref = referenceCollection.acquire(key, args);

    try {
      final T object = await ref.object;
      return _ReferenceImpl<T>(object, () => ref.dispose());
    } catch (error) {
      ref.dispose();
      rethrow;
    }
  }
}

/// 1:1: `export class ImmortalReference`
class ImmortalReference<T> implements IReference<T> {
  @override
  final T object;
  ImmortalReference(this.object);
  @override
  void dispose() {}
}

/// 1:1: `export function disposeOnReturn`
void disposeOnReturn(void Function(DisposableStore store) fn) {
  final DisposableStore store = DisposableStore();
  try {
    fn(store);
  } finally {
    store.dispose();
  }
}

/// 1:1: `export class DisposableMap`
class DisposableMap<K, V extends IDisposable> implements IDisposable {
  final Map<K, V> _store;
  bool _isDisposed = false;

  DisposableMap([Map<K, V>? store])
      : _store = store ?? <K, V>{} {
    trackDisposable(this);
  }

  @override
  void dispose() {
    markAsDisposed(this);
    _isDisposed = true;
    clearAndDisposeAll();
  }

  void clearAndDisposeAll() {
    if (_store.isEmpty) {
      return;
    }
    try {
      _disposeArg(_store.values);
    } finally {
      _store.clear();
    }
  }

  bool has(K key) => _store.containsKey(key);

  int get size => _store.length;

  V? get(K key) => _store[key];

  void set(K key, V value, [bool skipDisposeOnOverwrite = false]) {
    // 1:1: source warns when adding to an already disposed map.
    if (_isDisposed) {
      // console.warn(...) — no-op in this port.
    }
    if (!skipDisposeOnOverwrite) {
      _store[key]?.dispose();
    }
    _store[key] = value;
    setParentOfDisposable(value, this);
  }

  void deleteAndDispose(K key) {
    _store[key]?.dispose();
    _store.remove(key);
  }

  V? deleteAndLeak(K key) {
    final V? value = _store[key];
    if (value != null) {
      setParentOfDisposable(value, null);
    }
    _store.remove(key);
    return value;
  }

  Iterable<K> get keys => _store.keys;

  Iterable<V> get values => _store.values;

  Iterable<MapEntry<K, V>> get entries => _store.entries;
}

/// 1:1: `export class DisposableSet`
class DisposableSet<V extends IDisposable> with IterableMixin<V>
    implements IDisposable {
  final Set<V> _store;
  bool _isDisposed = false;

  DisposableSet([Set<V>? store])
      : _store = store ?? <V>{} {
    trackDisposable(this);
  }

  @override
  void dispose() {
    markAsDisposed(this);
    _isDisposed = true;
    clearAndDisposeAll();
  }

  void clearAndDisposeAll() {
    if (_store.isEmpty) {
      return;
    }
    try {
      _disposeArg(_store);
    } finally {
      _store.clear();
    }
  }

  bool has(V value) => _store.contains(value);

  int get size => _store.length;

  void add(V value) {
    // 1:1: source warns when adding to an already disposed set.
    if (_isDisposed) {
      // console.warn(...) — no-op in this port.
    }
    _store.add(value);
    setParentOfDisposable(value, this);
  }

  void deleteAndDispose(V value) {
    if (_store.remove(value)) {
      value.dispose();
    }
  }

  V? deleteAndLeak(V value) {
    if (_store.remove(value)) {
      setParentOfDisposable(value, null);
      return value;
    }
    return null;
  }

  @override
  Iterator<V> get iterator => _store.iterator;
}


/// 1:1: `export function thenIfNotDisposed`
IDisposable thenIfNotDisposed<T>(Future<T> promise, void Function(T result) then) {
  bool disposed = false;
  promise.then((T result) {
    if (disposed) {
      return;
    }
    then(result);
  });
  return toDisposable(() {
    disposed = true;
  });
}

/// 1:1: `export function thenRegisterOrDispose`
Future<T> thenRegisterOrDispose<T extends IDisposable>(
    Future<T> promise, DisposableStore store) {
  return promise.then((T disposable) {
    if (store.isDisposed) {
      disposable.dispose();
    } else {
      store.add(disposable);
    }
    return disposable;
  });
}

/// 1:1: `export class DisposableResourceMap`
/// Dart's ResourceMap is not a Map subclass; a thin Map adapter bridges it.
class DisposableResourceMap<V extends IDisposable> extends DisposableMap<uri.URI, V> {
  DisposableResourceMap() : super(_ResourceMapAdapter<V>());
}

class _ResourceMapAdapter<V> extends MapBase<uri.URI, V> {
  final Map<uri.URI, V> _map = <uri.URI, V>{};

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(uri.URI key, V value) => _map[key] = value;

  @override
  V? remove(Object? key) => _map.remove(key);

  @override
  Iterable<uri.URI> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  void clear() => _map.clear();
}
