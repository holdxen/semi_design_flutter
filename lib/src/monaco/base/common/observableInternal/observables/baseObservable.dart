// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/baseObservable.ts
// Translated 1:1. The module-splitting setters (_setDerivedOpts etc.) are
// top-level injectable function slots, exactly as in the source.
// ---------------------------------------------------------------------------

import '../base.dart'
    show IObservable, IObservableWithChange, IObserver, IReader;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugOwner, getFunctionName;
import '../logging/logging.dart' show getLogger, logObservable;

/// 1:1: `let _derived: typeof derivedOpts` + `_setDerivedOpts`
Object? Function(Object data, Object? Function(IReader reader) compute, [Object? debugLocation])?
    _derived;
void setDerivedOpts(Object? Function(Object data, Object? Function(IReader reader) compute,
        [Object? debugLocation]) fn) =>
    _derived = fn;

/// 1:1: `_setRecomputeInitiallyAndOnChange`
Object Function(IObservableWithChange<Object?, Object?> o, [void Function(Object? value)? handleValue])?
    _recomputeInitiallyAndOnChange;
void setRecomputeInitiallyAndOnChange(
        Object Function(IObservableWithChange<Object?, Object?> o, [void Function(Object? value)? handleValue]) fn) =>
    _recomputeInitiallyAndOnChange = fn;

/// 1:1: `_setKeepObserved`
Object Function(IObservableWithChange<Object?, Object?> o)? _keepObserved;
void setKeepObserved(Object Function(IObservableWithChange<Object?, Object?> o) fn) => _keepObserved = fn;

/// 1:1: `_setDebugGetObservableGraph`
String Function(Object observable, Object opts)? _debugGetObservableGraph;
void setDebugGetObservableGraph(String Function(Object observable, Object opts) fn) =>
    _debugGetObservableGraph = fn;

/// Dart-only typed view over an untyped derived observable.
///
/// TS erases generic arguments at runtime, so `map` can directly return its
/// derived observable as `IObservable<TNew>`. Dart reifies them: the derived
/// bridge produces `IObservableWithChange<Object?, Object?>`, which needs a
/// typed delegate to be used as `IObservable<TNew>`.
class _CastObservable<T> implements IObservable<T> {
  final IObservableWithChange<Object?, Object?> _source;
  _CastObservable(this._source);

  @override
  T get() => _source.get() as T;

  @override
  void reportChanges() => _source.reportChanges();

  @override
  void addObserver(IObserver observer) => _source.addObserver(observer);

  @override
  void removeObserver(IObserver observer) => _source.removeObserver(observer);

  @override
  T read(IReader? reader) => _source.read(reader) as T;

  @override
  IObservable<T> recomputeInitiallyAndOnChange(Object store,
          [void Function(T value)? handleValue]) =>
      _CastObservable<T>(_source.recomputeInitiallyAndOnChange(store,
          handleValue == null ? null : (Object? v) => handleValue(v as T)));

  @override
  IObservable<T> keepObserved(Object store) =>
      _CastObservable<T>(_source.keepObserved(store));

  @override
  IObservable<TNew> map<TNew>(TNew Function(T value, IReader reader) fn) =>
      _CastObservable<TNew>(
          _source.map<Object?>((Object? v, IReader r) => fn(v as T, r)));

  @override
  IObservable<TNew> flatten<TNew>() =>
      _CastObservable<TNew>(_source.flatten<Object?>());

  @override
  IObservableWithChange<T, Object?> log() =>
      _CastObservable<T>(_source.log());

  @override
  String get debugName => _source.debugName;
}

/// 1:1: `export abstract class ConvenientObservable<T, TChange>`
abstract class ConvenientObservable<T, TChange>
    implements IObservableWithChange<T, TChange> {
  /// 1:1: type-only `get TChange(): TChange { return null!; }` — marker omitted.

  @override
  T get();

  @override
  void reportChanges() {
    get();
  }

  @override
  void addObserver(IObserver observer);

  @override
  void removeObserver(IObserver observer);

  /// 1:1: `read(reader)`
  @override
  T read(IReader? reader) {
    if (reader != null) {
      return reader.readObservable(this as IObservableWithChange<T, Object?>);
    }
    return get();
  }

  /// 1:1: `map` (two overloads unified; owner is [fnOrOwner] when [fn] given).
  @override
  IObservable<TNew> map<TNew>(TNew Function(T value, IReader reader) fn,
      [DebugOwner? owner, DebugLocation? debugLocation]) {
    final derived = _derived;
    return _CastObservable<TNew>(derived!(
          <Object, Object?>{
            'owner': owner,
            'debugName': () {
              final name = getFunctionName(fn);
              if (name != null) {
                return name;
              }
              // regexp: `x => x.y` or `x => x?.y`
              final match = RegExp(
                      r'^\s*\(?\s*([a-zA-Z_$][a-zA-Z_$0-9]*)\s*\)?\s*=>\s*\1(?:\??)\.([a-zA-Z_$][a-zA-Z_$0-9]*)\s*$')
                  .firstMatch(fn.toString());
              if (match != null) {
                return '$debugName.${match.group(2)}';
              }
              if (owner == null) {
                return '$debugName (mapped)';
              }
              return null;
            },
            'debugReferenceFn': fn,
          },
          (IReader reader) => fn(read(reader), reader) as Object?,
          debugLocation,
        ) as IObservableWithChange<Object?, Object?>);
    // Dart: TS's erased generic return is re-typed through [_CastObservable].
  }

  @override
  IObservableWithChange<T, TChange> log();

  /// 1:1: `flatten()`
  @override
  IObservable<TNew> flatten<TNew>() {
    final derived = _derived;
    return _CastObservable<TNew>(derived!(
          <Object, Object?>{
            'owner': null,
            'debugName': () => '$debugName (flattened)',
          },
          (IReader reader) => (read(reader) as dynamic).read(reader) as Object?,
        ) as IObservableWithChange<Object?, Object?>);
  }

  @override
  IObservable<T> recomputeInitiallyAndOnChange(Object store,
      [void Function(T value)? handleValue]) {
    final fn = _recomputeInitiallyAndOnChange!;
    // store.add(...): the source adds the returned disposable to the store.
    (store as dynamic).add(fn(this,
        handleValue == null ? null : (Object? value) => handleValue(value as T)));
    return this as IObservable<T>;
  }

  @override
  IObservable<T> keepObserved(Object store) {
    final fn = _keepObserved!;
    (store as dynamic).add(fn(this));
    return this as IObservable<T>;
  }

  @override
  String get debugName;

  /// 1:1: `protected get debugValue()`
  Object? get debugValue => get();

  /// 1:1: `get debug()`
  DebugHelper get debug => DebugHelper(this as IObservableWithChange<Object?, Object?>);
}

/// 1:1: `class DebugHelper`
class DebugHelper {
  DebugHelper(this.observable);

  final IObservableWithChange<Object?, Object?> observable;

  String getDependencyGraph() =>
      _debugGetObservableGraph!(observable, <String, Object>{'type': 'dependencies'});

  String getObserverGraph() =>
      _debugGetObservableGraph!(observable, <String, Object>{'type': 'observers'});
}

/// 1:1: `export abstract class BaseObservable<T, TChange = void>`
abstract class BaseObservable<T, TChange> extends ConvenientObservable<T, TChange> {
  /// 1:1: `protected readonly _observers = new Set<IObserver>()`
  final Set<IObserver> _observers = <IObserver>{};

  BaseObservable(DebugLocation? debugLocation) {
    getLogger()?.handleObservableCreated(this, debugLocation);
  }

  @override
  void addObserver(IObserver observer) {
    final len = _observers.length;
    _observers.add(observer);
    if (len == 0) {
      onFirstObserverAdded();
    }
    if (len != _observers.length) {
      getLogger()?.handleOnListenerCountChanged(
          this, _observers.length);
    }
  }

  @override
  void removeObserver(IObserver observer) {
    final deleted = _observers.remove(observer);
    if (deleted && _observers.isEmpty) {
      onLastObserverRemoved();
    }
    if (deleted) {
      getLogger()?.handleOnListenerCountChanged(
          this, _observers.length);
    }
  }

  /// 1:1: hooks
  void onFirstObserverAdded() {}
  void onLastObserverRemoved() {}

  @override
  IObservableWithChange<T, TChange> log() {
    final hadLogger = getLogger() != null;
    logObservable(this);
    if (!hadLogger) {
      getLogger()?.handleObservableCreated(
          this, DebugLocation.ofCaller());
    }
    return this;
  }

  /// 1:1: `debugGetObservers()`
  Set<IObserver> debugGetObservers() => _observers;
}
