// batch72: observable foundation — logging.ts, transaction.ts, baseObservable.ts.
// Data-driven from Node TS transpile+vm truth JSONs.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/base.dart'
    show IObservable, IObservableWithChange, IObserver, IReader, ITransaction;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/logging/logging.dart'
    as logging;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/baseObservable.dart'
    as bo;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/transaction.dart'
    as tx;

Map<String, dynamic> _truth(String name) => jsonDecode(
      File('tool/ts2dart/$name').readAsStringSync(),
    ) as Map<String, dynamic>;

List<List<Object?>> _asEvents(Object? v) => (v as List)
    .map((e) => (e as List).map((x) => x as Object?).toList())
    .toList();

/// Recording logger implementing all handlers by pushing [tag, method, argc].
class _RecLogger implements logging.IObservableLogger {
  _RecLogger(this.tag, this.log);
  final String tag;
  final List<List<Object?>> log;
  void _push(String m, int n) => log.add(<Object?>[tag, m, n]);

  @override
  void handleObservableCreated(covariant IObservableWithChange<Object?, Object?> o, Object? l) => _push('handleObservableCreated', 2);
  @override
  void handleOnListenerCountChanged(covariant IObservableWithChange<Object?, Object?> o, int n) => _push('handleOnListenerCountChanged', 2);
  @override
  void handleObservableUpdated(covariant IObservableWithChange<Object?, Object?> o, logging.IChangeInformation i) => _push('handleObservableUpdated', 2);
  @override
  void handleAutorunCreated(Object a, Object? l) => _push('handleAutorunCreated', 2);
  @override
  void handleAutorunDisposed(Object a) => _push('handleAutorunDisposed', 1);
  @override
  void handleAutorunDependencyChanged(Object a, covariant IObservableWithChange<Object?, Object?> o, Object? c) => _push('handleAutorunDependencyChanged', 3);
  @override
  void handleAutorunStarted(Object a) => _push('handleAutorunStarted', 1);
  @override
  void handleAutorunFinished(Object a) => _push('handleAutorunFinished', 1);
  @override
  void handleDerivedDependencyChanged(Object d, covariant IObservableWithChange<Object?, Object?> o, Object? c) => _push('handleDerivedDependencyChanged', 3);
  @override
  void handleDerivedCleared(Object o) => _push('handleDerivedCleared', 1);
  @override
  void handleBeginTransaction(Object t) => _push('handleBeginTransaction', 1);
  @override
  void handleEndTransaction(Object t) => _push('handleEndTransaction', 1);
}

/// Observer stub recording begin/end updates with an observable name.
class _Obs implements IObserver {
  _Obs(this.tag, this.events);
  final String tag;
  final List<List<Object?>> events;
  String _name(Object observable) => (observable as dynamic).name as String;

  @override
  void beginUpdate<T>(covariant IObservableWithChange<T, Object?> observable) =>
      events.add(<Object?>[tag, 'begin', _name(observable)]);
  @override
  void endUpdate<T>(covariant IObservableWithChange<T, Object?> observable) =>
      events.add(<Object?>[tag, 'end', _name(observable)]);
  @override
  void handlePossibleChange<T>(covariant IObservableWithChange<T, Object?> observable) {}
  @override
  void handleChange<T, C>(covariant IObservableWithChange<T, C> observable, C change) {}
}

class _NamedObservable<T> implements IObservable<T> {
  _NamedObservable(this.name);
  final String name;
  @override
  T get() => null as T;
  @override
  void reportChanges() {}
  @override
  void addObserver(IObserver o) {}
  @override
  void removeObserver(IObserver o) {}
  @override
  T read(IReader? reader) => null as T;
  @override
  IObservable<T> recomputeInitiallyAndOnChange(Object store, [void Function(T value)? h]) => this;
  @override
  IObservable<T> keepObserved(Object store) => this;
  @override
  IObservable<TNew> map<TNew>(TNew Function(T value, IReader reader) fn) => throw UnimplementedError();
  @override
  IObservable<TNew> flatten<TNew>() => throw UnimplementedError();
  @override
  IObservableWithChange<T, Object?> log() => this;
  @override
  String get debugName => name;
}

class _Reader implements IReader {
  @override
  T readObservable<T>(covariant IObservableWithChange<T, Object?> observable) =>
      'read:${(observable as dynamic).debugName}' as T;
}

class _Store {
  _Store(this.events);
  final List<List<Object?>> events;
  void add(Object d) => events.add(<Object?>['store.add', d]);
}

class _TestObs extends bo.BaseObservable<Object?, Object?> implements IObservable<Object?> {
  _TestObs(this.name, this.v, this.events) : super(null);
  final String name;
  Object? v;
  final List<List<Object?>> events;
  @override
  Object? get() => v;
  @override
  String get debugName => name;
  @override
  void onFirstObserverAdded() => events.add(<Object?>['first', name]);
  @override
  void onLastObserverRemoved() => events.add(<Object?>['last', name]);
}

void main() {
  // ---------- logging ----------
  test('b72 logging: single logger, composed fanout, logObservable', () {
    final t = _truth('batch72_logging_truth.json');
    logging.globalObservableLogger = null;
    logging.globalObservableLoggerFn = null;
    expect(logging.getLogger() == null, t['initialLogger']);

    final calls1 = <List<Object?>>[];
    final l1 = _RecLogger('L1', calls1);
    logging.addLogger(l1);
    expect(identical(logging.getLogger(), l1), t['singleLoggerIsSame']);
    logging.getLogger()!.handleOnListenerCountChanged(_NamedObservable<Object>('x'), 3);
    expect(calls1, _asEvents(t['singleCall']));

    final calls2 = <List<Object?>>[];
    logging.addLogger(_RecLogger('L2', calls2));
    final composed = logging.getLogger();
    expect(identical(composed, l1), t['composedIsDistinct'] == true ? false : true);
    composed!.handleObservableCreated(_NamedObservable<Object>('x'), null);
    expect(calls1.where((e) => e[1] == 'handleObservableCreated').length, t['composedFanout1']);
    expect(calls2.where((e) => e[1] == 'handleObservableCreated').length, t['composedFanout2']);

    final calls3 = <List<Object?>>[];
    logging.addLogger(_RecLogger('L3', calls3));
    logging.getLogger()!.handleBeginTransaction(Object());
    expect(<int>[
      calls1.where((e) => e[1] == 'handleBeginTransaction').length,
      calls2.where((e) => e[1] == 'handleBeginTransaction').length,
      calls3.where((e) => e[1] == 'handleBeginTransaction').length,
    ], t['threeLoggers']);

    final observed = <Object?>[];
    logging.logObservable(_NamedObservable<Object>('obsA'));
    expect(observed.length, t['logObservableNoop']);
    logging.setLogObservableFn((o) => observed.add(o));
    logging.logObservable(_NamedObservable<Object>('obsB'));
    expect(observed.length, (t['logObservableAfterSet'] as List).length);
  });

  // ---------- transaction ----------
  test('b72 transaction: batch begin/end, global nested, sub', () {
    final t = _truth('batch72_transaction_truth.json');
    final events = <List<Object?>>[];
    final obs = _Obs('A', events);
    final o = _NamedObservable<Object>('o1');
    var ran = 0;
    tx.transaction((itx) {
      ran++;
      itx.updateObserver(obs, o);
      events.add(<Object?>['inside', 'afterUpdate']);
    });
    expect(ran, (t['transaction'] as Map)['ran']);
    expect(events, _asEvents((t['transaction'] as Map)['events']));

    final gEvents = <List<Object?>>[];
    final gObs = _Obs('B', gEvents);
    final go = _NamedObservable<Object>('g');
    tx.globalTransaction((outer) {
      outer.updateObserver(gObs, go);
      tx.globalTransaction((inner) {
        gEvents.add(<Object?>['nestedSame', identical(inner, outer)]);
        inner.updateObserver(gObs, go);
      });
      gEvents.add(<Object?>['beforeOuterEnd']);
    });
    expect(gEvents, _asEvents(t['globalTransaction']));

    final sEvents = <List<Object?>>[];
    final sObs = _Obs('C', sEvents);
    ITransaction? seen;
    tx.subtransaction(null, (itx) {
      seen = itx;
      itx.updateObserver(sObs, _NamedObservable<Object>('s'));
    });
    expect(seen, isNotNull);
    expect(sEvents, _asEvents((t['subtransaction'] as Map)['events']));
    var reused = false;
    tx.transaction((itx) {
      tx.subtransaction(itx, (inner) => reused = identical(inner, itx));
    });
    expect(reused, (t['subtransaction'] as Map)['reused']);
  });

  // ---------- baseObservable ----------
  test('b72 baseObservable: read dispatch, observer first/last, log, helpers', () {
    final t = _truth('batch72_baseObservable_truth.json');
    final derivedCalls = <List<Object?>>[];
    bo.setDerivedOpts((data, compute, [loc]) {
      final d = data as Map;
      derivedCalls.add(<Object?>[
        'derived',
        (d['debugName'] as Object? Function())(),
        compute.toString().substring(0, 40 > compute.toString().length ? compute.toString().length : 40),
      ]);
      return _NamedObservable<Object>('derived-result');
    });
    final events = <List<Object?>>[];
    bo.setRecomputeInitiallyAndOnChange((o, [h]) {
      events.add(<Object?>['recompute', (o as _TestObs).name]);
      return 'disposable-r';
    });
    bo.setKeepObserved((o) {
      events.add(<Object?>['keepObserved', (o as _TestObs).name]);
      return 'disposable-k';
    });
    bo.setDebugGetObservableGraph((o, opts) {
      final m = opts as Map;
      return 'graph2:${(o as _TestObs).name}:${m['type']}';
    });
    logging.setLogObservableFn((o) => events.add(<Object?>['logObservable', (o as _TestObs).name]));
    logging.globalObservableLogger = null;

    final o = _TestObs('o', 42, <List<Object?>>[]);
    expect(o.read(null), (t['read'] as Map)['direct']);
    expect(o.read(_Reader()), (t['read'] as Map)['withReader']);

    final o2 = _TestObs('obs2', 1, events);
    events.clear();
    final a = _Obs('a', events), b = _Obs('b', events);
    o2.addObserver(a);
    o2.addObserver(a);
    o2.addObserver(b);
    expect(events, _asEvents((t['observers'] as Map)['afterAdd']));
    o2.removeObserver(a);
    o2.removeObserver(a);
    expect(events, _asEvents((t['observers'] as Map)['afterRemoveA']));
    o2.removeObserver(b);
    expect(events, _asEvents((t['observers'] as Map)['afterAll']));

    final o3 = _TestObs('logobs', 1, <List<Object?>>[]);
    events.clear();
    o3.log();
    expect(events, _asEvents(t['logNoLogger']));

    final o4 = _TestObs('src', 1, <List<Object?>>[]);
    derivedCalls.clear();
    o4.map<Object>((v, r) => v ?? 0);
    expect(derivedCalls.isNotEmpty, isTrue);

    final o5 = _TestObs('r', 1, events);
    events.clear();
    final store = _Store(events);
    final r1 = o5.recomputeInitiallyAndOnChange(store);
    final r2 = o5.keepObserved(store);
    expect(identical(r1, o5) && identical(r2, o5), (t['helpers'] as Map)['sameReturn']);
    expect(events, _asEvents((t['helpers'] as Map)['events']));

    final o6 = _TestObs('dg', 1, <List<Object?>>[]);
    expect(o6.debug.getDependencyGraph(), (t['debugGraph'] as Map)['deps']);
    expect(o6.debug.getObserverGraph(), (t['debugGraph'] as Map)['obs']);
  });
}
