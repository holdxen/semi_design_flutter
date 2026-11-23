// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/logging/debugger/devToolsLogger.ts
// Translated 1:1. The debug channel's `createClient` callback installs the
// notification/request handlers; those mirror the source object literals via
// the value classes in debuggerApi.d.dart. State updates are `Map<String,Object?>`
// carriers (TS `ObsStateUpdate`).
// ---------------------------------------------------------------------------

import 'dart:collection';

import '../../../errors.dart' show BugIndicatingError, onUnexpectedError;
import '../../base.dart' show IObservable, IObservableWithChange, IObserver;
import '../../debugLocation.dart' show DebugLocation, ILocation;
import '../../observables/baseObservable.dart' show BaseObservable;
import '../../observables/derivedImpl.dart' show Derived, DerivedState;
import '../../observables/observableFromEvent.dart' show FromEventObservable;
import '../../observables/observableValue.dart' show ObservableValue;
import '../../reactions/autorunImpl.dart' show AutorunObserver, AutorunState;
import '../../transaction.dart' show TransactionImpl;
import '../consoleObservableLogger.dart' show formatValue;
import '../logging.dart' show IChangeInformation, IObservableLogger;
import 'debuggerApi.d.dart'
    show
        DerivedObservableState,
        IObsDeclaration,
        ITransactionState,
        ObserverInstanceState,
        ObsInstanceId;
import 'debuggerApi.d.dart' as dbg_api show AutorunState;
import 'utils.dart' show Throttler, deepAssign, deepAssignDeleteNulls;

/// 1:1: `interface IInstanceInfo`
class IInstanceInfo {
  IInstanceInfo({required this.declarationId, required this.instanceId});
  final int declarationId;
  final int instanceId;
}

/// 1:1: `interface IObservableInfo extends IInstanceInfo`
class IObservableInfo extends IInstanceInfo {
  IObservableInfo({
    required super.declarationId,
    required super.instanceId,
    required this.listenerCount,
    this.lastValue,
    required this.updateCount,
    required this.changedObservables,
  });
  int listenerCount;
  String? lastValue;
  int updateCount;
  final Set<IObservable<Object?>> changedObservables;
}

/// 1:1: `interface IAutorunInfo extends IInstanceInfo`
class IAutorunInfo extends IInstanceInfo {
  IAutorunInfo({
    required super.declarationId,
    required super.instanceId,
    required this.updateCount,
    required this.changedObservables,
  });
  int updateCount;
  final Set<IObservable<Object?>> changedObservables;
}

/// 1:1: `class DevToolsLogger implements IObservableLogger`
class DevToolsLogger implements IObservableLogger {
  DevToolsLogger._() {
    DebugLocation.enable();
    final client = _createClient();
    _clientNotifications =
        (client as Map<String, Object?>)['notifications'] as Map<String, Object?>;
    _requests = (client as Map<String, Object?>)['requests'] as Map<String, Function>;
  }

  static DevToolsLogger? _instance;
  static DevToolsLogger getInstance() => _instance ??= DevToolsLogger._();

  int _declarationId = 0;
  int _instanceId = 0;

  final Map<String, IObsDeclaration> _declarations =
      <String, IObsDeclaration>{};
  final Map<Object, Object> _instanceInfos = HashMap<Object, Object>.identity();
  final Map<ObsInstanceId, Object> _aliveInstances =
      <ObsInstanceId, Object>{};
  final Set<TransactionImpl> _activeTransactions = <TransactionImpl>{};

  /// 1:1: the object literal passed to registerDebugChannel's createClient
  /// (the channel registration is represented by storing the client directly;
  /// the RPC transport is platform-specific and carried by debuggerRpc.dart).
  Object _createClient() {
    return <String, Object?>{
      'notifications': <String, Object?>{
        'setDeclarationIdFilter': (Object? ids) {},
        'logObservableValue': (Object? observableId) {
          // console.log in source; no-op in Dart host-neutral port.
        },
        'flushUpdates': () => _flushUpdates(),
        'resetUpdates': () {
          _pendingChanges = null;
          _notifyHandleChange(_fullState, true);
        },
      },
      'requests': <String, Function>{
        'getDeclarations': () {
          final result = <ObsInstanceId, IObsDeclaration>{};
          for (final decl in _declarations.values) {
            result[decl.id] = decl;
          }
          return <String, Object?>{'decls': result};
        },
        'getSummarizedInstances': () => null,
        'getObservableValueInfo': (ObsInstanceId instanceId) {
          final obs = _aliveInstances[instanceId] as BaseObservable;
          return <String, Object?>{
            'observers': obs.debugGetObservers()
                  .map<dynamic>((e) => _formatObserver(e))
                .where((e) => e != null)
                .toList(),
          };
        },
        'getDerivedInfo': (ObsInstanceId instanceId) {
          final d = _aliveInstances[instanceId] as Derived;
          final state = d.debugGetState();
          return <String, Object?>{
            'dependencies': (state['dependencies'] as Iterable)
                  .map<dynamic>((e) => _formatObservable(e))
                .where((e) => e != null)
                .toList(),
            'observers': d.debugGetObservers()
                  .map<dynamic>((e) => _formatObserver(e))
                .where((e) => e != null)
                .toList(),
          };
        },
        'getAutorunInfo': (ObsInstanceId instanceId) {
          final ar = _aliveInstances[instanceId] as AutorunObserver;
          final state = ar.debugGetState();
          return <String, Object?>{
            'dependencies': (state['dependencies'] as Iterable)
                  .map<dynamic>((e) => _formatObservable(e))
                .where((e) => e != null)
                .toList(),
          };
        },
        'getTransactionState': () => getTransactionState(),
        'setValue': (ObsInstanceId instanceId, Object? jsonValue) {
          final obs = _aliveInstances[instanceId] as BaseObservable;
          if (obs is Derived) {
            obs.debugSetValue(jsonValue);
          } else if (obs is ObservableValue) {
            obs.debugSetValue(jsonValue);
          } else if (obs is FromEventObservable) {
            obs.debugSetValue(jsonValue);
          } else {
            throw BugIndicatingError('Observable is not supported');
          }
          final observers = obs.debugGetObservers().toList();
          for (final o in observers) {
            o.beginUpdate(obs as dynamic);
          }
          for (final o in observers) {
            o.handleChange(obs as dynamic, null);
          }
          for (final o in observers) {
            o.endUpdate(obs as dynamic);
          }
        },
        'getValue': (ObsInstanceId instanceId) {
          final obs = _aliveInstances[instanceId] as BaseObservable;
          if (obs is Derived) {
            return formatValue(obs.debugGetState()['value'], 200);
          } else if (obs is ObservableValue) {
            return formatValue(obs.debugGetState()['value'], 200);
          }
          return null;
        },
        'logValue': (ObsInstanceId instanceId) {
          final obs = _aliveInstances[instanceId];
          if (obs is IObservable) {
            // console.log in source; host-neutral no-op.
          } else {
            throw BugIndicatingError('Observable is not supported');
          }
        },
        'rerun': (ObsInstanceId instanceId) {
          final obs = _aliveInstances[instanceId];
          if (obs is Derived) {
            obs.debugRecompute();
          } else if (obs is AutorunObserver) {
            obs.debugRerun();
          } else {
            throw BugIndicatingError('Observable is not supported');
          }
        },
      },
    };
  }

  late Map<String, Function> _requests;

  /// 1:1: `registerDebugChannel(...)` — installs the notification/request
  /// handlers. Exposed so a host can wire the RPC transport.
  Object get channelClient => <String, Object?>{
        'notifications': _clientNotifications,
        'requests': _requests,
      };

  void _notifyHandleChange(Map<String, Object?> state, bool isFull) {
    final notifications = _clientNotifications;
    final fn = notifications['handleChange'] as void Function(Map<String, Object?>, bool)?;
    fn?.call(state, isFull);
  }

  late Map<String, Object?> _clientNotifications;

  ITransactionState? getTransactionState() {
    final affected = <ObserverInstanceState>[];
    final txs = _activeTransactions.toList();
    if (txs.isEmpty) return null;
    final observerQueue = <IObserver>[];
    for (final t in txs) {
      final updating = t.debugGetUpdatingObservers();
      if (updating != null) {
        for (final o in updating) {
          observerQueue.add(o.observer);
        }
      }
    }
    final processedObservers = <IObserver>{};
    while (observerQueue.isNotEmpty) {
      final observer = observerQueue.removeAt(0);
      if (processedObservers.contains(observer)) continue;
      processedObservers.add(observer);
      final state = _getInfo(observer, (o) {
        if (!processedObservers.contains(o)) observerQueue.add(o);
      });
      if (state != null) affected.add(state);
    }
    return ITransactionState(
      txs.map((t) => t.getDebugName() ?? 'tx').toList(),
      affected,
    );
  }

  IObservableInfo? _getObservableInfo(IObservable<Object?> observable) {
    final info = _instanceInfos[observable];
    if (info == null) {
      onUnexpectedError(BugIndicatingError('No info found'));
      return null;
    }
    return info as IObservableInfo;
  }

  IAutorunInfo? _getAutorunInfo(AutorunObserver autorun) {
    final info = _instanceInfos[autorun];
    if (info == null) {
      onUnexpectedError(BugIndicatingError('No info found'));
      return null;
    }
    return info as IAutorunInfo;
  }

  ObserverInstanceState? _getInfo(
    IObserver observer,
    void Function(IObserver) queue,
  ) {
    if (observer is Derived) {
      for (final o in observer.debugGetObservers()) {
        queue(o);
      }
      final info = _getObservableInfo(observer);
      if (info == null) return null;
      final observerState = observer.debugGetState();
      final name = observer.debugName;
      final instanceId = info.instanceId;
      final updateCount = observerState['updateCount'] as int;
      final changedDependencies = info.changedObservables
          .map((o) => (_instanceInfos[o] as IInstanceInfo?)?.instanceId)
          .where((i) => i != null)
          .map((i) => i!)
          .toList();
      if (observerState['isComputing'] == true) {
        return DerivedObservableState(instanceId, name, updateCount, 'updating',
            changedDependencies, false);
      }
      switch (observerState['state']) {
        case DerivedState.initial:
          return DerivedObservableState(instanceId, name, updateCount, 'noValue');
        case DerivedState.upToDate:
          return DerivedObservableState(instanceId, name, updateCount, 'upToDate');
        case DerivedState.stale:
          return DerivedObservableState(
              instanceId, name, updateCount, 'stale', changedDependencies);
        case DerivedState.dependenciesMightHaveChanged:
          return DerivedObservableState(
              instanceId, name, updateCount, 'possiblyStale');
      }
    } else if (observer is AutorunObserver) {
      final info = _getAutorunInfo(observer);
      if (info == null) return null;
      final name = observer.debugName;
      final instanceId = info.instanceId;
      final updateCount = info.updateCount;
      final changedDependencies = info.changedObservables
          .map((o) => (_instanceInfos[o] as IInstanceInfo?)?.instanceId)
          .where((i) => i != null)
          .map((i) => i!)
          .toList();
      final state = observer.debugGetState();
      if (state['isRunning'] == true) {
        return dbg_api.AutorunState(
            instanceId, name, updateCount, 'updating', changedDependencies);
      }
      switch (state['state']) {
        case AutorunState.upToDate:
          return dbg_api.AutorunState(instanceId, name, updateCount, 'upToDate');
        case AutorunState.stale:
          return dbg_api.AutorunState(
              instanceId, name, updateCount, 'stale', changedDependencies);
        case AutorunState.dependenciesMightHaveChanged:
          return dbg_api.AutorunState(instanceId, name, updateCount, 'possiblyStale');
      }
    }
    return null;
  }

  Map<String, Object?>? _formatObservable(IObservable<Object?> obs) {
    final info = _getObservableInfo(obs);
    if (info == null) return null;
    return <String, Object?>{'name': obs.debugName, 'instanceId': info.instanceId};
  }

  Map<String, Object?>? _formatObserver(IObserver obs) {
    if (obs is Derived) {
      final info = _getObservableInfo(obs);
      return <String, Object?>{
        'name': obs.toString(),
        'instanceId': info?.instanceId,
      };
    }
    final autorunInfo = _getAutorunInfo(obs as AutorunObserver);
    if (autorunInfo != null) {
      return <String, Object?>{
        'name': obs.toString(),
        'instanceId': autorunInfo.instanceId,
      };
    }
    return null;
  }

  Map<String, Object?>? _pendingChanges;
  final Throttler _changeThrottler = Throttler();
  final Map<String, Object?> _fullState = <String, Object?>{};

  void _handleChange(Map<String, Object?> update) {
    deepAssignDeleteNulls(_fullState, update);
    if (_pendingChanges == null) {
      _pendingChanges = update;
    } else {
      deepAssign(_pendingChanges!, update);
    }
    _changeThrottler.throttle(() {
      _flushUpdates();
    }, 10);
  }

  void _flushUpdates() {
    final pending = _pendingChanges;
    if (pending != null) {
      _notifyHandleChange(pending, false);
      _pendingChanges = null;
    }
  }

  int _getDeclarationId(String type, DebugLocation? location) {
    if (location == null) return -1;
    final loc = location as ILocation;
    final key = loc.id;
    IObsDeclaration? decInfo = _declarations[key];
    if (decInfo == null) {
      decInfo = IObsDeclaration(_declarationId++, type, loc.fileName,
          loc.line, loc.column);
      _declarations[key] = decInfo;
      _handleChange(<String, Object?>{
        'decls': <int, IObsDeclaration>{decInfo.id: decInfo},
      });
    }
    return decInfo.id;
  }

  @override
  void handleObservableCreated(
    IObservableWithChange<Object?, Object?> observable,
    DebugLocation? location,
  ) {
    final declarationId = _getDeclarationId('observable/value', location);
    final info = IObservableInfo(
      declarationId: declarationId,
      instanceId: _instanceId++,
      listenerCount: 0,
      updateCount: 0,
      changedObservables: <IObservable<Object?>>{},
    );
    _instanceInfos[observable] = info;
  }

  @override
  void handleOnListenerCountChanged(
    IObservableWithChange<Object?, Object?> observable,
    int newCount,
  ) {
    final info = _getObservableInfo(observable);
    if (info == null) return;
    if (info.listenerCount == 0 && newCount > 0) {
      final type = observable is Derived ? 'observable/derived' : 'observable/value';
      _aliveInstances[info.instanceId] = observable;
      _handleChange(<String, Object?>{
        'instances': <int, Object?>{
          info.instanceId: <String, Object?>{
            'instanceId': info.instanceId,
            'declarationId': info.declarationId,
            'type': type,
            'name': observable.debugName,
          },
        },
      });
    } else if (info.listenerCount > 0 && newCount == 0) {
      _handleChange(<String, Object?>{
        'instances': <int, Object?>{info.instanceId: null},
      });
      _aliveInstances.remove(info.instanceId);
    }
    info.listenerCount = newCount;
  }

  @override
  void handleObservableUpdated(
    IObservableWithChange<Object?, Object?> observable,
    IChangeInformation info,
  ) {
    if (observable is Derived) {
      _handleDerivedRecomputed(observable, info);
      return;
    }
    final i = _getObservableInfo(observable);
    if (i != null && info.didChange) {
      i.lastValue = formatValue(info.newValue, 30);
      if (i.listenerCount > 0) {
        _handleChange(<String, Object?>{
          'instances': <int, Object?>{
            i.instanceId: <String, Object?>{'formattedValue': i.lastValue},
          },
        });
      }
    }
  }

  @override
  void handleAutorunCreated(Object autorun, DebugLocation? location) {
    final declarationId = _getDeclarationId('autorun', location);
    final ar = autorun as AutorunObserver;
    final info = IAutorunInfo(
      declarationId: declarationId,
      instanceId: _instanceId++,
      updateCount: 0,
      changedObservables: <IObservable<Object?>>{},
    );
    _instanceInfos[autorun] = info;
    _aliveInstances[info.instanceId] = autorun;
    _handleChange(<String, Object?>{
      'instances': <int, Object?>{
        info.instanceId: <String, Object?>{
          'instanceId': info.instanceId,
          'declarationId': info.declarationId,
          'runCount': 0,
          'type': 'autorun',
          'name': ar.debugName,
        },
      },
    });
  }

  @override
  void handleAutorunDisposed(Object autorun) {
    final info = _getAutorunInfo(autorun as AutorunObserver);
    if (info == null) return;
    _handleChange(<String, Object?>{
      'instances': <int, Object?>{info.instanceId: null},
    });
    _instanceInfos.remove(autorun);
    _aliveInstances.remove(info.instanceId);
  }

  @override
  void handleAutorunDependencyChanged(
    Object autorun,
    IObservableWithChange<Object?, Object?> observable,
    Object? change,
  ) {
    final info = _getAutorunInfo(autorun as AutorunObserver);
    if (info == null) return;
    info.changedObservables.add(observable);
  }

  @override
  void handleAutorunStarted(Object autorun) {}

  @override
  void handleAutorunFinished(Object autorun) {
    final info = _getAutorunInfo(autorun as AutorunObserver);
    if (info == null) return;
    info.changedObservables.clear();
    info.updateCount++;
    _handleChange(<String, Object?>{
      'instances': <int, Object?>{
        info.instanceId: <String, Object?>{'runCount': info.updateCount},
      },
    });
  }

  @override
  void handleDerivedDependencyChanged(
    Object derived,
    IObservableWithChange<Object?, Object?> observable,
    Object? change,
  ) {
    final info = _getObservableInfo(derived as IObservable<Object?>);
    if (info != null) info.changedObservables.add(observable);
  }

  void _handleDerivedRecomputed(Derived derived, IChangeInformation changeInfo) {
    final info = _getObservableInfo(derived);
    if (info == null) return;
    final formattedValue = formatValue(changeInfo.newValue, 30);
    info.updateCount++;
    info.changedObservables.clear();
    info.lastValue = formattedValue;
    if (info.listenerCount > 0) {
      _handleChange(<String, Object?>{
        'instances': <int, Object?>{
          info.instanceId: <String, Object?>{
            'formattedValue': formattedValue,
            'recomputationCount': info.updateCount,
          },
        },
      });
    }
  }

  @override
  void handleDerivedCleared(Object observable) {
    final info = _getObservableInfo(observable as IObservable<Object?>);
    if (info == null) return;
    info.lastValue = null;
    info.changedObservables.clear();
    if (info.listenerCount > 0) {
      _handleChange(<String, Object?>{
        'instances': <int, Object?>{
          info.instanceId: <String, Object?>{'formattedValue': null},
        },
      });
    }
  }

  @override
  void handleBeginTransaction(Object transaction) {
    _activeTransactions.add(transaction as TransactionImpl);
  }

  @override
  void handleEndTransaction(Object transaction) {
    _activeTransactions.remove(transaction as TransactionImpl);
  }
}
