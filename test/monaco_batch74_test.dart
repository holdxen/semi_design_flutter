// batch74: observable core types — observableValueOpts, observableSignalFromEvent,
// observableFromEvent, reactions/autorunImpl. Data-driven from batch74_truth.json.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/base.dart'
    show IObservableWithChange, IObserver, IReader, ITransaction;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/changeTracker.dart'
    show IChangeTracker, IChangeContext;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/debugName.dart'
    show DebugNameData;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableValue.dart'
    as ov;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableValueOpts.dart'
    as ovo;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableSignalFromEvent.dart'
    as ose;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableFromEvent.dart'
    as ofe;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/reactions/autorunImpl.dart'
    as au;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/transaction.dart'
    as tx;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch74_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

List<List<Object?>> _asEvents(Object? v) => (v as List)
    .map((e) => (e as List).map((x) => x as Object?).toList())
    .toList();

class _Obs implements IObserver {
  _Obs(this.tag, this.events);
  final String tag;
  final List<List<Object?>> events;
  String _name(Object o) => (o as dynamic).debugName as String;
  @override
  void beginUpdate<T>(covariant IObservableWithChange<T, Object?> o) =>
      events.add(<Object?>[tag, 'begin', _name(o)]);
  @override
  void endUpdate<T>(covariant IObservableWithChange<T, Object?> o) =>
      events.add(<Object?>[tag, 'end', _name(o)]);
  @override
  void handleChange<T, C>(covariant IObservableWithChange<T, C> o, C change) =>
      events.add(<Object?>[tag, 'change', _name(o), change]);
  @override
  void handlePossibleChange<T>(covariant IObservableWithChange<T, Object?> o) =>
      events.add(<Object?>[tag, 'possible', _name(o)]);
}

/// Structurally-disposable listener registration, mirroring the JS Event fn.
class _EventFn {
  final List<_Listener> _listeners = <_Listener>[];

  IDisposable call(dynamic listener, [dynamic thisArgs, dynamic disposables]) {
    final l = _Listener(listener as void Function([Object?]));
    _listeners.add(l);
    return _Disp(() => l.disposed = true);
  }

  void fire([Object? arg]) {
    for (final l in _listeners) {
      if (!l.disposed) l.listener(arg);
    }
  }

  int get listenerCount => _listeners.where((l) => !l.disposed).length;
}

class _Listener {
  _Listener(this.listener);
  final void Function([Object?]) listener;
  bool disposed = false;
}

class _Disp implements IDisposable {
  _Disp(this.fn);
  final void Function() fn;
  @override
  void dispose() => fn();
}

void main() {
  final t = _truth();

  test('b74 observableValueOpts: eager vs lazy, equalsFn, debugName', () {
    final a = (t['observableValueOpts'] as Map<String, dynamic>);
    final eagerTruth = (a['eager'] as Map<String, dynamic>);

    final eager = ovo.observableValueOpts<int, Object?>(
      ovo.ObservableValueOpts<int>(debugName: 'ev', lazy: false),
      0,
    );
    final events = <List<Object?>>[];
    eager.addObserver(_Obs('A', events));
    eager.set(5, null, null);
    expect(eager.get(), eagerTruth['get']);
    expect(eager.debugName, eagerTruth['debugName']);
    expect(events, _asEvents(eagerTruth['events']));

    final lazyTruth = (a['lazy'] as Map<String, dynamic>);
    final lazy = ovo.observableValueOpts<int, Object?>(
      ovo.ObservableValueOpts<int>(debugName: 'lv', lazy: true),
      1,
    );
    expect(lazy.get(), lazyTruth['get']);
    expect(lazy.debugName, lazyTruth['debugName']);
    // Dart appends generic args to runtimeType.toString(); JS constructor.name
    // has none. Compare the base type name only.
    expect(lazy.runtimeType.toString().split('<').first, lazyTruth['isLazy']);
  });

  test('b74 observableSignalFromEvent: subscribe/fire/unsubscribe', () {
    final a = t['observableSignalFromEvent'] as Map<String, dynamic>;
    final ev = _EventFn();
    final s = ose.observableSignalFromEvent('sig', ev.call);
    final events = <List<Object?>>[];
    final ob = _Obs('S', events);
    s.addObserver(ob);

    final add = a['afterAdd'] as Map<String, dynamic>;
    expect(ev.listenerCount, add['listeners']);
    expect(s.debugName, add['debugName']);
    s.get(); // void (no observable value)

    ev.fire('x');
    expect(events, _asEvents(a['afterFire']));

    s.removeObserver(ob);
    expect(ev.listenerCount, a['afterRemove']);
  });

  test('b74 observableFromEvent: overloads, get, fire, equality, batch', () {
    final a = t['observableFromEvent'] as Map<String, dynamic>;

    final ev = _EventFn();
    int counter = 0;
    final o = ofe.observableFromEvent<int, Object?>(
      ev.call,
      (args) {
        counter++;
        return ((args as int?) ?? 0) * 10 + counter;
      },
    );
    final noObs = a['noObs'] as Map<String, dynamic>;
    expect(o.get(), noObs['value']);
    expect(counter, noObs['calls']);

    final events = <List<Object?>>[];
    final ob = _Obs('E', events);
    o.addObserver(ob);
    final add = a['afterAdd'] as Map<String, dynamic>;
    expect(ev.listenerCount, add['listeners']);
    expect(o.debugName, add['debugName']);

    ev.fire(2);
    final first = a['first'] as Map<String, dynamic>;
    expect(o.get(), first['value']);
    expect(events, _asEvents(first['events'])); // empty: first fire only caches

    ev.fire(3);
    final second = a['second'] as Map<String, dynamic>;
    expect(o.get(), second['value']);
    expect(events, _asEvents(second['events'])); // begin/change/end

    final state = a['state'] as Map<String, dynamic>;
    final ds = (o as dynamic).debugGetState() as Map<String, Object?>;
    expect(ds['value'], state['value']);
    expect(ds['hasValue'], state['hasValue']);

    o.removeObserver(ob);
    final rm = a['afterRemove'] as Map<String, dynamic>;
    expect(ev.listenerCount, rm['listeners']);
    final ds2 = (o as dynamic).debugGetState() as Map<String, Object?>;
    expect(ds2['hasValue'], (rm['state'] as Map)['hasValue']);

    // observableFromEventOpts with a never-equal comparer
    final ev2 = _EventFn();
    final o2 = ofe.observableFromEventOpts<String, Object?>(
      ofe.ObservableFromEventOpts(debugName: 'opt', equalsFn: (_, __) => false),
      ev2.call,
      (args) => (args as String?) ?? 'none',
    );
    final e2 = <List<Object?>>[];
    o2.addObserver(_Obs('O', e2));
    ev2.fire('A');
    ev2.fire('A');
    final opts = a['optsResult'] as Map<String, dynamic>;
    expect(o2.get(), opts['value']);
    expect(o2.debugName, opts['debugName']);
    expect(e2, _asEvents(opts['events']));

    // namespace batchEventsGlobally
    final b = a['batch'] as Map<String, dynamic>;
    expect(ofe.FromEventObservable.globalTransaction, isNull, reason: 'before');
    final itx = _ITx();
    ofe.batchEventsGlobally(itx, () {
      expect(identical(ofe.FromEventObservable.globalTransaction, itx), b['during']);
    });
    expect(ofe.FromEventObservable.globalTransaction, isNull, reason: 'after');
  });

  test('b74 autorunImpl: run/set/dispose, transaction, tracker, rerun', () {
    final a = t['autorunImpl'] as Map<String, dynamic>;
    final values = <Object?>[];
    final obs = ov.observableValue<int, Object?>('x', 1);
    final ar = au.AutorunObserver<Object?>(
      DebugNameData(null, 'ar', null),
      (reader, summary) {
        values.add(reader.readObservable(obs));
      },
      null,
      null,
    );
    final initial = a['initial'] as Map<String, dynamic>;
    final st = ar.debugGetState();
    expect(values, initial['values']);
    expect(st['stateStr'], initial['stateStr']);
    expect(st['updateCount'], initial['updateCount']);
    expect(st['isRunning'], initial['isRunning']);
    expect((st['dependencies'] as Set).length, initial['deps']);
    expect(ar.toString(), initial['toString']);
    expect(ar.debugName, initial['debugName']);

    obs.set(2, null, null);
    final afterSet = a['afterSet'] as Map<String, dynamic>;
    expect(values, afterSet['values']);
    expect(ar.debugGetState()['stateStr'], afterSet['stateStr']);

    ar.dispose();
    obs.set(3, null, null);
    expect(values, (a['afterDispose'] as Map<String, dynamic>)['values']);

    // transaction batching
    final valuesB = <Object?>[];
    final obsB = ov.observableValue<int, Object?>('t', 0);
    final arB = au.AutorunObserver<Object?>(
      DebugNameData(null, 'ar', null),
      (reader, summary) {
        valuesB.add(reader.readObservable(obsB));
      },
      null,
      null,
    );
    tx.transaction((itx) {
      obsB.set(1, itx, null);
      obsB.set(2, itx, null);
      valuesB.add('inside:${obsB.get()}');
    });
    expect(valuesB, (a['batch'] as Map<String, dynamic>)['values']);
    arB.dispose();

    // changeTracker
    final obsC = ov.observableValue<int, Object?>('c', 0);
    final calls = <String, int>{'before': 0, 'handle': 0};
    final tracker = _Tracker(calls);
    Object? seenSummary;
    final arC = au.AutorunObserver<Map<String, Object?>>(
      DebugNameData(null, 'ar', null),
      (reader, summary) {
        seenSummary = summary;
        reader.readObservable(obsC);
      },
      tracker,
      null,
    );
    obsC.set(5, null, 'delta');
    final tr = a['trackerResult'] as Map<String, dynamic>;
    expect(calls, tr['calls']);
    expect((seenSummary as Map)['changes'], tr['seenChanges']);
    arC.dispose();

    // debugRerun + store/delayedStore
    final valuesD = <Object?>[];
    final obsD = ov.observableValue<int, Object?>('d', 7);
    bool storeOk = false;
    bool delayedOk = false;
    final arD = au.AutorunObserver<Object?>(
      DebugNameData(null, 'ar', null),
      (reader, summary) {
        storeOk = reader.store is IDisposable;
        delayedOk = reader.delayedStore is IDisposable;
        valuesD.add(reader.readObservable(obsD));
      },
      null,
      null,
    );
    arD.debugRerun();
    final rerun = a['rerun'] as Map<String, dynamic>;
    expect(valuesD, rerun['values']);
    expect(storeOk, rerun['storeOk']);
    expect(delayedOk, rerun['delayedOk']);
    arD.dispose();
  });
}

class _ITx implements ITransaction {
  @override
  void updateObserver(IObserver observer, IObservableWithChange<Object?, Object?> observable) {}
}

class _Tracker implements IChangeTracker<Map<String, Object?>> {
  _Tracker(this.calls);
  final Map<String, int> calls;

  @override
  Map<String, Object?> createChangeSummary(Map<String, Object?>? previous) {
    final n = previous == null ? 1 : ((previous['n'] as int) + 1);
    return <String, Object?>{'n': n, 'changes': <Object?>[]};
  }

  @override
  bool handleChange(IChangeContext ctx, Map<String, Object?> change) {
    calls['handle'] = (calls['handle'] ?? 0) + 1;
    (change['changes'] as List).add(ctx.change);
    return true;
  }

  @override
  void beforeUpdate(IReader reader, Map<String, Object?> change) {
    calls['before'] = (calls['before'] ?? 0) + 1;
  }
}
