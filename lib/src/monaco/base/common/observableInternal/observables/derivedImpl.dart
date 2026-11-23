// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/derivedImpl.ts
// Translated 1:1. `const enum DerivedState` -> static const ints (with the
// state-to-string helper preserved); the inline IChangeContext literal in
// handleChange -> a private carrier implementing IChangeContext. `Derived`
// extends BaseObservable, whose `_observers` set is library-private in Dart,
// so observer iteration uses `debugGetObservers()` (the same Set instance).
// ---------------------------------------------------------------------------

import '../base.dart'
    show
        IObservable,
        IObservableWithChange,
        IObserver,
        IReaderWithStore,
        ISettableObservable,
        ITransaction;
import '../changeTracker.dart' show IChangeContext, IChangeTracker;
import '../commonFacade/deps.dart'
    show
        BugIndicatingError,
        DisposableStore,
        EqualityComparer,
        assertFn,
        onBugIndicatingError;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData;
import '../logging/logging.dart' show IChangeInformation, getLogger;
import 'baseObservable.dart' show BaseObservable;

/// 1:1: `export interface IDerivedReader<TChange = void> extends IReaderWithStore`
abstract class IDerivedReader<TChange> implements IReaderWithStore {
  /// Call this to report a change delta or to force report a change, even if
  /// the new value is the same as the old value.
  void reportChange(TChange change);
}

/// 1:1: `export const enum DerivedState`
class DerivedState {
  static const int initial = 0;
  static const int dependenciesMightHaveChanged = 1;
  static const int stale = 2;
  static const int upToDate = 3;
}

/// 1:1: `function derivedStateToString(state)`
String derivedStateToString(int state) {
  switch (state) {
    case DerivedState.initial:
      return 'initial';
    case DerivedState.dependenciesMightHaveChanged:
      return 'dependenciesMightHaveChanged';
    case DerivedState.stale:
      return 'stale';
    case DerivedState.upToDate:
      return 'upToDate';
    default:
      return '<unknown>';
  }
}

/// 1:1: `export class Derived<T, TChangeSummary = any, TChange = void>`
class Derived<T, TChangeSummary, TChange> extends BaseObservable<T, TChange>
    implements IDerivedReader<TChange>, IObserver {
  int _state = DerivedState.initial;
  T? _value;
  int _updateCount = 0;
  Set<IObservable<Object?>> _dependencies = <IObservable<Object?>>{};
  Set<IObservable<Object?>> _dependenciesToBeRemoved = <IObservable<Object?>>{};
  TChangeSummary? _changeSummary;
  bool _isUpdating = false;
  bool _isComputing = false;
  bool _didReportChange = false;
  bool _isInBeforeUpdate = false;
  bool _isReaderValid = false;
  DisposableStore? _store;
  DisposableStore? _delayedStore;
  Set<IObserver>? _removedObserverToCallEndUpdateOn;

  @override
  String get debugName => _debugNameData.getDebugName(this) ?? '(anonymous)';

  Derived(
    this._debugNameData,
    this._computeFn,
    this._changeTracker,
    this._handleLastObserverRemoved,
    this._equalityComparator,
    DebugLocation? debugLocation,
  ) : super(debugLocation) {
    _changeSummary = _changeTracker?.createChangeSummary(null);
  }

  final DebugNameData _debugNameData;
  final T Function(IDerivedReader<TChange> reader, TChangeSummary changeSummary)
      _computeFn;
  final IChangeTracker<TChangeSummary>? _changeTracker;
  final void Function()? _handleLastObserverRemoved;
  final EqualityComparer<T> _equalityComparator;

  @override
  void onLastObserverRemoved() {
    // We are not tracking changes anymore, thus we have to assume that our
    // cache is invalid.
    _state = DerivedState.initial;
    _value = null;
    getLogger()?.handleDerivedCleared(this);
    for (final d in _dependencies) {
      d.removeObserver(this);
    }
    _dependencies.clear();

    if (_store != null) {
      _store!.dispose();
      _store = null;
    }
    if (_delayedStore != null) {
      _delayedStore!.dispose();
      _delayedStore = null;
    }

    _handleLastObserverRemoved?.call();
  }

  @override
  T get() {
    // 1:1: `const checkEnabled = false` (TODO in source). Kept verbatim; the
    // guard is intentionally inert until checkEnabled is turned on upstream.
    const bool checkEnabled = false;
    // ignore: dead_code
    if (_isComputing && checkEnabled) {
      // investigate why this fails in the diff editor!
      throw BugIndicatingError('Cyclic deriveds are not supported yet!');
    }

    if (debugGetObservers().isEmpty) {
      late T result;
      // Without observers, we don't know when to clean up stuff.
      // Thus, we don't cache anything to prevent memory leaks.
      try {
        _isReaderValid = true;
        TChangeSummary? changeSummary;
        if (_changeTracker != null) {
          changeSummary = _changeTracker.createChangeSummary(null);
          _changeTracker.beforeUpdate(this, changeSummary as TChangeSummary);
        }
        result = _computeFn(this, changeSummary as TChangeSummary);
      } finally {
        _isReaderValid = false;
      }
      // Clear new dependencies
      onLastObserverRemoved();
      return result;
    } else {
      do {
        // We might not get a notification for a dependency that changed while
        // it is updating, thus we also have to ask all our dependencies if they
        // changed in this case.
        if (_state == DerivedState.dependenciesMightHaveChanged) {
          for (final d in _dependencies) {
            // might call handleChange indirectly, which could make us stale
            d.reportChanges();
            if (_state == DerivedState.stale) {
              // The other dependencies will refresh on demand, so early break
              break;
            }
          }
        }

        // We called report changes of all dependencies.
        // If we are still not stale, we can assume to be up to date again.
        if (_state == DerivedState.dependenciesMightHaveChanged) {
          _state = DerivedState.upToDate;
        }

        if (_state != DerivedState.upToDate) {
          _recompute();
        }
        // In case recomputation changed one of our dependencies, we need to
        // recompute again.
      } while (_state != DerivedState.upToDate);
      return _value as T;
    }
  }

  void _recompute() {
    bool didChange = false;
    _isComputing = true;
    _didReportChange = false;

    final emptySet = _dependenciesToBeRemoved;
    _dependenciesToBeRemoved = _dependencies;
    _dependencies = emptySet;

    try {
      final TChangeSummary changeSummary = _changeSummary as TChangeSummary;

      _isReaderValid = true;
      if (_changeTracker != null) {
        _isInBeforeUpdate = true;
        _changeTracker.beforeUpdate(this, changeSummary);
        _isInBeforeUpdate = false;
        _changeSummary = _changeTracker.createChangeSummary(changeSummary);
      }

      final bool hadValue = _state != DerivedState.initial;
      final T? oldValue = _value;
      _state = DerivedState.upToDate;

      final DisposableStore? delayedStore = _delayedStore;
      if (delayedStore != null) {
        _delayedStore = null;
      }
      try {
        if (_store != null) {
          _store!.dispose();
          _store = null;
        }
        // might call handleChange indirectly, which could invalidate us
        _value = _computeFn(this, changeSummary);
      } finally {
        _isReaderValid = false;
        // We don't want our observed observables to think that they are (not
        // even temporarily) not being observed. Thus, we only unsubscribe from
        // observables that are definitely not read anymore.
        for (final o in _dependenciesToBeRemoved) {
          o.removeObserver(this);
        }
        _dependenciesToBeRemoved.clear();

        if (delayedStore != null) {
          delayedStore.dispose();
        }
      }

      didChange = _didReportChange ||
          (hadValue && !_equalityComparator(oldValue as T, _value as T));

      getLogger()?.handleObservableUpdated(
          this,
          IChangeInformation(
            oldValue: oldValue,
            newValue: _value,
            change: null,
            didChange: didChange,
            hadValue: hadValue,
          ));
    } catch (e) {
      onBugIndicatingError(e);
    }

    _isComputing = false;

    if (!_didReportChange && didChange) {
      for (final r in debugGetObservers()) {
        r.handleChange<T, Object?>(this, null);
      }
    } else {
      _didReportChange = false;
    }
  }

  @override
  String toString() => 'LazyDerived<$debugName>';

  // IObserver implementation

  @override
  void beginUpdate<T>(covariant IObservableWithChange<T, Object?> observable) {
    if (_isUpdating) {
      throw BugIndicatingError('Cyclic deriveds are not supported yet!');
    }

    _updateCount++;
    _isUpdating = true;
    try {
      final bool propagateBeginUpdate = _updateCount == 1;
      if (_state == DerivedState.upToDate) {
        _state = DerivedState.dependenciesMightHaveChanged;
        // If we propagate begin update, that will already signal a possible change.
        if (!propagateBeginUpdate) {
          for (final r in debugGetObservers()) {
            r.handlePossibleChange(this);
          }
        }
      }
      if (propagateBeginUpdate) {
        for (final r in debugGetObservers()) {
          r.beginUpdate(this); // This signals a possible change
        }
      }
    } finally {
      _isUpdating = false;
    }
  }

  @override
  void endUpdate<T>(covariant IObservableWithChange<T, Object?> observable) {
    _updateCount--;
    if (_updateCount == 0) {
      // End update could change the observer list.
      final observers = List<IObserver>.from(debugGetObservers());
      for (final r in observers) {
        r.endUpdate(this);
      }
      if (_removedObserverToCallEndUpdateOn != null) {
        final removed = List<IObserver>.from(_removedObserverToCallEndUpdateOn!);
        _removedObserverToCallEndUpdateOn = null;
        for (final r in removed) {
          r.endUpdate(this);
        }
      }
    }
    assertFn(() => _updateCount >= 0);
  }

  @override
  void handlePossibleChange<T>(
      covariant IObservableWithChange<T, Object?> observable) {
    // In all other states, observers already know that we might have changed.
    if (_state == DerivedState.upToDate &&
        _dependencies.contains(observable) &&
        !_dependenciesToBeRemoved.contains(observable)) {
      _state = DerivedState.dependenciesMightHaveChanged;
      for (final r in debugGetObservers()) {
        r.handlePossibleChange(this);
      }
    }
  }

  @override
  void handleChange<T, TChange>(
      covariant IObservableWithChange<T, TChange> observable, TChange change) {
    if ((_dependencies.contains(observable) &&
            !_dependenciesToBeRemoved.contains(observable)) ||
        _isInBeforeUpdate) {
      getLogger()?.handleDerivedDependencyChanged(this, observable, change);

      bool shouldReact = false;
      try {
        shouldReact = _changeTracker != null
            ? _changeTracker.handleChange(
                _ChangeContext(
                  changedObservable: observable as dynamic,
                  change: change,
                  onDidChange: (o) => identical(o, observable),
                ),
                _changeSummary as TChangeSummary,
              )
            : true;
      } catch (e) {
        onBugIndicatingError(e);
      }

      final bool wasUpToDate = _state == DerivedState.upToDate;
      if (shouldReact &&
          (_state == DerivedState.dependenciesMightHaveChanged ||
              wasUpToDate)) {
        _state = DerivedState.stale;
        if (wasUpToDate) {
          for (final r in debugGetObservers()) {
            r.handlePossibleChange(this);
          }
        }
      }
    }
  }

  // IReader implementation

  void _ensureReaderValid() {
    if (!_isReaderValid) {
      throw BugIndicatingError(
          'The reader object cannot be used outside its compute function!');
    }
  }

  @override
  T readObservable<T>(covariant IObservableWithChange<T, Object?> observable) {
    _ensureReaderValid();

    // Subscribe before getting the value to enable caching
    observable.addObserver(this);
    // This might call handleChange indirectly, which could invalidate us
    final T value = observable.get();
    // Which is why we only add the observable to the dependencies now.
    _dependencies.add(observable as IObservable<Object?>);
    _dependenciesToBeRemoved.remove(observable as IObservable<Object?>);
    return value;
  }

  @override
  void reportChange(TChange change) {
    _ensureReaderValid();

    _didReportChange = true;
    // TODO add logging
    for (final r in debugGetObservers()) {
      r.handleChange<TChange, TChange>(this as dynamic, change);
    }
  }

  @override
  DisposableStore get store {
    _ensureReaderValid();

    if (_store == null) {
      _store = DisposableStore();
    }
    return _store!;
  }

  @override
  DisposableStore get delayedStore {
    _ensureReaderValid();

    if (_delayedStore == null) {
      _delayedStore = DisposableStore();
    }
    return _delayedStore!;
  }

  @override
  void addObserver(IObserver observer) {
    final bool shouldCallBeginUpdate =
        !debugGetObservers().contains(observer) && _updateCount > 0;
    super.addObserver(observer);

    if (shouldCallBeginUpdate) {
      if (!(_removedObserverToCallEndUpdateOn?.remove(observer) ?? false)) {
        observer.beginUpdate(this);
      }
    }
  }

  @override
  void removeObserver(IObserver observer) {
    if (debugGetObservers().contains(observer) && _updateCount > 0) {
      _removedObserverToCallEndUpdateOn ??= <IObserver>{};
      _removedObserverToCallEndUpdateOn!.add(observer);
    }
    super.removeObserver(observer);
  }

  Map<String, Object?> debugGetState() => <String, Object?>{
        'state': _state,
        'stateStr': derivedStateToString(_state),
        'updateCount': _updateCount,
        'isComputing': _isComputing,
        'dependencies': _dependencies,
        'value': _value,
      };

  void debugSetValue(Object? newValue) {
    _value = newValue as T;
  }

  void debugRecompute() {
    beginUpdate(this as dynamic);
    try {
      if (!_isComputing) {
        _recompute();
      } else {
        _state = DerivedState.stale;
      }
    } finally {
      endUpdate(this as dynamic);
    }
  }

  void setValue(T newValue, ITransaction tx, TChange change) {
    _value = newValue;
    final observers = debugGetObservers();
    tx.updateObserver(this as dynamic, this as dynamic);
    for (final d in observers) {
      d.handleChange<TChange, TChange>(this as dynamic, change);
    }
  }
}

/// 1:1: the inline IChangeContext object literal in handleChange.
class _ChangeContext implements IChangeContext {
  _ChangeContext({
    required this.changedObservable,
    required this.change,
    required this.onDidChange,
  });

  @override
  final IObservableWithChange<Object?, Object?> changedObservable;
  @override
  final Object? change;
  final bool Function(IObservableWithChange<Object?, Object?> observable)
      onDidChange;

  @override
  bool didChange<T, TChange>(IObservableWithChange<T, TChange> observable) =>
      onDidChange(observable as dynamic);
}

/// 1:1: `export class DerivedWithSetter<T, TChangeSummary = any, TOutChanges = any>`
class DerivedWithSetter<T, TChangeSummary, TOutChanges>
    extends Derived<T, TChangeSummary, TOutChanges>
    implements ISettableObservable<T, TOutChanges> {
  DerivedWithSetter(
    DebugNameData debugNameData,
    T Function(IDerivedReader<TOutChanges> reader, TChangeSummary changeSummary)
        computeFn,
    IChangeTracker<TChangeSummary>? changeTracker,
    void Function()? handleLastObserverRemoved,
    EqualityComparer<T> equalityComparator,
    this._setFn,
    DebugLocation? debugLocation,
  ) : super(
          debugNameData,
          computeFn,
          changeTracker,
          handleLastObserverRemoved,
          equalityComparator,
          debugLocation,
        );

  /// 1:1: `public readonly set: (value, tx, change) => void`
  final void Function(T value, ITransaction? tx, TOutChanges change) _setFn;

  /// 1:1: the `set` field above satisfies `ISettableObservable.set`; in Dart a
  /// field and an interface method cannot share a name, so the method delegates.
  @override
  void set(T value, ITransaction? tx, TOutChanges change) =>
      _setFn(value, tx, change);
}
