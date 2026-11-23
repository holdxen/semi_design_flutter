// batch73: observable value types — constObservable, observableValue,
// observableSignal, lazyObservableValue. Data-driven from batch73_truth.json.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/base.dart'
    show IObservableWithChange, IObserver, IReader;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/debugName.dart'
    show DebugNameData;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/logging/logging.dart'
    as logging;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/constObservable.dart'
    as c;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/lazyObservableValue.dart'
    as lazy;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableSignal.dart'
    as sig;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableValue.dart'
    as ov;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/transaction.dart'
    as tx;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch73_truth.json').readAsStringSync(),
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

class _Disposable implements IDisposable {
  _Disposable(this.counter);
  final List<int> counter;
  @override
  void dispose() => counter.add(1);
}

void main() {
  setUp(() {
    logging.globalObservableLogger = null;
    logging.globalObservableLoggerFn = null;
  });

  final t = _truth();

  test('b73 constObservable: value, debugName, read, log', () {
    final a = t['constObservable'] as Map<String, dynamic>;
    final o = c.constObservable<Object>(42);
    expect(o.get(), a['get']);
    expect(o.debugName, a['debugName']);
    expect(o.toString(), a['toString']);
    expect(o.read(null), a['readNoReader']);
    expect(o.read(_Reader()), a['readWithReader']);
    expect(identical(o.log(), o), a['logSame']);
  });

  test('b73 observableValue: get/set, equality, transaction batching', () {
    final a = t['observableValue'] as Map<String, dynamic>;
    final v = ov.observableValue<int, Object?>('counter', 0);
    expect(v.get(), a['initial']);
    expect(v.debugName, a['debugName']);
    expect(v.toString(), a['toString']);

    v.set(0, null, null); // same value -> no change
    expect(v.get(), a['setSameNoop']);

    final events = <List<Object?>>[];
    v.addObserver(_Obs('A', events));
    v.set(5, null, 'delta');
    expect(v.get(), (a['setNew'] as Map)['value']);
    expect(events, _asEvents((a['setNew'] as Map)['events']));

    // transaction batching
    final e2 = <List<Object?>>[];
    final v2 = ov.observableValue<int, Object?>('txv', 0);
    v2.addObserver(_Obs('B', e2));
    tx.transaction((itx) {
      v2.set(1, itx, null);
      v2.set(2, itx, null);
      e2.add(<Object?>['inside', v2.get()]);
    });
    expect(e2, _asEvents(a['transaction']));
  });

  test('b73 disposableObservableValue: disposes old + self', () {
    final a = t['disposableObservableValue'] as Map<String, dynamic>;
    final counter = <int>[];
    final d1 = _Disposable(counter);
    final v = ov.disposableObservableValue<_Disposable, Object?>('dv', d1);
    final d2 = _Disposable(counter);
    v.set(d2, null, null);
    (v as dynamic).dispose();
    expect(counter.length, a['disposed']);
    expect(identical(v.get(), d2), a['finalIsD2']);
  });

  test('b73 observableSignal: trigger wraps in transaction', () {
    final a = t['observableSignal'] as Map<String, dynamic>;
    final s = sig.observableSignal<Object?>('sig');
    final events = <List<Object?>>[];
    s.addObserver(_Obs('S', events));
    s.trigger(null, 'change1');
    expect(s.get(), isNull); // void
    expect(s.debugName, a['debugName']);
    expect(events, _asEvents(a['events']));
  });

  test('b73 lazyObservableValue: defers change until read', () {
    final a = t['lazyObservableValue'] as Map<String, dynamic>;
    final v = lazy.LazyObservableValue<Object?, Object?>(
      DebugNameData(null, 'lazy', null),
      0,
      (x, y) => x == y,
      null,
    );
    final events = <List<Object?>>[];
    v.addObserver(_Obs('L', events));
    tx.transaction((itx) {
      v.set(1, itx, 'd1');
      v.set(2, itx, 'd2');
      events.add(<Object?>['during', v.get()]);
    });
    expect(v.get(), a['afterRead']);
    expect(events, _asEvents(a['events']));
  });
}

class _Reader implements IReader {
  @override
  T readObservable<T>(covariant IObservableWithChange<T, Object?> o) =>
      'reader:${o.get()}' as T;
}
