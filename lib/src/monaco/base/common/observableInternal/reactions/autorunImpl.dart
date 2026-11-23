// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/reactions/autorunImpl.ts
// Translated 1:1. `const enum AutorunState` -> static const ints (with the
// state-to-string helper preserved); `Set<IObservable<any>>` ->
// Set<IObservableWithChange<Object?, Object?>>; the inline IChangeContext
// literal in handleChange -> a private carrier implementing IChangeContext.
// ---------------------------------------------------------------------------

import '../base.dart'
    show
        IObservableWithChange,
        IObserver,
        IReaderWithStore;
import '../changeTracker.dart' show IChangeContext, IChangeTracker;
import '../commonFacade/deps.dart'
    show
        BugIndicatingError,
        DisposableStore,
        IDisposable,
        assertFn,
        markAsDisposed,
        onBugIndicatingError,
        trackDisposable;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData;
import '../logging/logging.dart' show getLogger;

/// 1:1: `export const enum AutorunState`
class AutorunState {
  static const int dependenciesMightHaveChanged = 1;
  static const int stale = 2;
  static const int upToDate = 3;
}

/// 1:1: `function autorunStateToString(state)`
String autorunStateToString(int state) {
  switch (state) {
    case AutorunState.dependenciesMightHaveChanged:
      return 'dependenciesMightHaveChanged';
    case AutorunState.stale:
      return 'stale';
    case AutorunState.upToDate:
      return 'upToDate';
    default:
      return '<unknown>';
  }
}

/// 1:1: `export class AutorunObserver<TChangeSummary = any>`
class AutorunObserver<TChangeSummary>
    implements IObserver, IReaderWithStore, IDisposable {
  int _state = AutorunState.stale;
  int _updateCount = 0;
  bool _disposed = false;
  Set<IObservableWithChange<Object?, Object?>> _dependencies =
      <IObservableWithChange<Object?, Object?>>{};
  Set<IObservableWithChange<Object?, Object?>> _dependenciesToBeRemoved =
      <IObservableWithChange<Object?, Object?>>{};
  TChangeSummary? _changeSummary;
  bool _isRunning = false;
  int _iteration = 0;

  String get debugName =>
      _debugNameData.getDebugName(this) ?? '(anonymous)';

  AutorunObserver(
    this._debugNameData,
    this._runFn,
    this._changeTracker,
    DebugLocation? debugLocation,
  ) {
    _changeSummary = _changeTracker?.createChangeSummary(null);
    getLogger()?.handleAutorunCreated(this, debugLocation);
    _run();
    trackDisposable(this);
  }

  final DebugNameData _debugNameData;
  final void Function(IReaderWithStore reader, TChangeSummary changeSummary)
      _runFn;
  final IChangeTracker<TChangeSummary>? _changeTracker;

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final o in _dependencies) {
      o.removeObserver(this); // Warning: external call!
    }
    _dependencies.clear();

    if (_store != null) {
      _store!.dispose();
    }
    if (_delayedStore != null) {
      _delayedStore!.dispose();
    }

    getLogger()?.handleAutorunDisposed(this);
    markAsDisposed(this);
  }

  void _run() {
    final Set<IObservableWithChange<Object?, Object?>> emptySet =
        _dependenciesToBeRemoved;
    _dependenciesToBeRemoved = _dependencies;
    _dependencies = emptySet;

    _state = AutorunState.upToDate;

    try {
      if (!_disposed) {
        getLogger()?.handleAutorunStarted(this);
        final TChangeSummary changeSummary = _changeSummary as TChangeSummary;
        final DisposableStore? delayedStore = _delayedStore;
        if (delayedStore != null) {
          _delayedStore = null;
        }
        try {
          _isRunning = true;
          if (_changeTracker != null) {
            _changeTracker.beforeUpdate(this, changeSummary);
            _changeSummary =
                _changeTracker.createChangeSummary(changeSummary);
          }
          if (_store != null) {
            _store!.dispose();
            _store = null;
          }

          _runFn(this, changeSummary); // Warning: external call!
        } catch (e) {
          onBugIndicatingError(e);
        } finally {
          _isRunning = false;
          if (delayedStore != null) {
            delayedStore.dispose();
          }
        }
      }
    } finally {
      if (!_disposed) {
        getLogger()?.handleAutorunFinished(this);
      }
      // We don't want our observed observables to think that they are (not even
      // temporarily) not being observed. Thus only unsubscribe from observables
      // that are definitely not read anymore.
      for (final o in _dependenciesToBeRemoved) {
        o.removeObserver(this); // Warning: external call!
      }
      _dependenciesToBeRemoved.clear();
    }
  }

  @override
  String toString() => 'Autorun<$debugName>';

  // IObserver implementation

  @override
  void beginUpdate<T>(covariant IObservableWithChange<T, Object?> observable) {
    if (_state == AutorunState.upToDate) {
      _checkIterations();
      _state = AutorunState.dependenciesMightHaveChanged;
    }
    _updateCount++;
  }

  @override
  void endUpdate<T>(covariant IObservableWithChange<T, Object?> observable) {
    try {
      if (_updateCount == 1) {
        _iteration = 1;
        do {
          if (_checkIterations()) {
            return;
          }
          if (_state == AutorunState.dependenciesMightHaveChanged) {
            _state = AutorunState.upToDate;
            for (final d in _dependencies) {
              d.reportChanges(); // Warning: external call!
              if (_state == AutorunState.stale) {
                // The other dependencies will refresh on demand
                break;
              }
            }
          }

          _iteration++;
          if (_state != AutorunState.upToDate) {
            _run(); // Warning: indirect external call!
          }
        } while (_state != AutorunState.upToDate);
      }
    } finally {
      _updateCount--;
    }

    assertFn(() => _updateCount >= 0);
  }

  @override
  void handlePossibleChange<T>(
      covariant IObservableWithChange<T, Object?> observable) {
    if (_state == AutorunState.upToDate && _isDependency(observable)) {
      _checkIterations();
      _state = AutorunState.dependenciesMightHaveChanged;
    }
  }

  @override
  void handleChange<T, TChange>(
      covariant IObservableWithChange<T, TChange> observable, TChange change) {
    if (_isDependency(observable)) {
      getLogger()?.handleAutorunDependencyChanged(this, observable, change);
      try {
        final bool shouldReact = _changeTracker != null
            ? _changeTracker.handleChange(
                _ChangeContext(
                  changedObservable: observable as dynamic,
                  change: change,
                  onDidChange: (o) => identical(o, observable),
                ),
                _changeSummary as TChangeSummary,
              )
            : true;
        if (shouldReact) {
          _checkIterations();
          _state = AutorunState.stale;
        }
      } catch (e) {
        onBugIndicatingError(e);
      }
    }
  }

  bool _isDependency(IObservableWithChange<Object?, Object?> observable) {
    return _dependencies.contains(observable) &&
        !_dependenciesToBeRemoved.contains(observable);
  }

  // IReader implementation

  void _ensureNoRunning() {
    if (!_isRunning) {
      throw BugIndicatingError(
          'The reader object cannot be used outside its compute function!');
    }
  }

  @override
  T readObservable<T>(covariant IObservableWithChange<T, Object?> observable) {
    _ensureNoRunning();

    // In case the run action disposes the autorun
    if (_disposed) {
      return observable.get(); // warning: external call!
    }

    observable.addObserver(this); // warning: external call!
    final T value = observable.get(); // warning: external call!
    _dependencies.add(observable as dynamic);
    _dependenciesToBeRemoved.remove(observable as dynamic);
    return value;
  }

  DisposableStore? _store;
  @override
  DisposableStore get store {
    _ensureNoRunning();
    if (_disposed) {
      throw BugIndicatingError('Cannot access store after dispose');
    }
    if (_store == null) {
      _store = DisposableStore();
    }
    return _store!;
  }

  DisposableStore? _delayedStore;
  @override
  DisposableStore get delayedStore {
    _ensureNoRunning();
    if (_disposed) {
      throw BugIndicatingError('Cannot access store after dispose');
    }
    if (_delayedStore == null) {
      _delayedStore = DisposableStore();
    }
    return _delayedStore!;
  }

  Map<String, Object?> debugGetState() => <String, Object?>{
        'isRunning': _isRunning,
        'updateCount': _updateCount,
        'dependencies': _dependencies,
        'state': _state,
        'stateStr': autorunStateToString(_state),
      };

  void debugRerun() {
    if (!_isRunning) {
      _run();
    } else {
      _state = AutorunState.stale;
    }
  }

  bool _checkIterations() {
    if (_iteration > 100) {
      onBugIndicatingError(BugIndicatingError(
          "Autorun '$debugName' is stuck in an infinite update loop."));
      return true;
    }
    return false;
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
