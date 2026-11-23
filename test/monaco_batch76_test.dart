// batch76: runOnChange — data-driven from batch76_truth.json (truth generated
// by Node vm against the real TS source + real autorunImpl/autorun).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/observables/observableValue.dart'
    as ov;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/utils/runOnChange.dart'
    as roc;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch76_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

void main() {
  group('batch76 runOnChange', () {
    final t = _truth()['runOnChange'] as Map<String, dynamic>;

    test('no cb on first run; cb with value/previousValue/deltas on change', () {
      final calls = <Map<String, Object?>>[];
      final obs = ov.observableValue<int, Object?>('c', 0);
      final d = roc.runOnChange<int, Object?>(obs, (value, previousValue, deltas) {
        calls.add(<String, Object?>{
          'value': value,
          'previousValue': previousValue,
          'deltas': deltas.toList(),
        });
      });
      expect(calls, t['afterFirst']);

      obs.set(5, null, 'delta1');
      expect(calls, t['afterFirstChange']);

      obs.set(9, null, 'delta2');
      obs.set(9, null, null); // same value, undefined change -> no set
      expect(calls, t['afterSecond']);

      d.dispose();
      obs.set(100, null, 'afterDispose');
      expect(calls, t['afterDispose']);
    });

    test('undefined deltas are filtered out', () {
      final calls = <Map<String, Object?>>[];
      final obs = ov.observableValue<String, Object?>('v', 'a');
      roc.runOnChange<String, Object?>(obs, (value, previousValue, deltas) {
        calls.add(<String, Object?>{
          'value': value,
          'previousValue': previousValue,
          'deltas': deltas.toList(),
        });
      });
      obs.set('b', null, 'D');
      obs.set('c', null, null); // different value, undefined change -> deltas empty
      final truthCalls =
          (_truth()['runOnChangeUndefinedDelta'] as Map<String, dynamic>)['calls'];
      expect(calls, truthCalls);
    });

    test('runOnChangeWithStore reuses one store across cb invocations', () {
      final stores = <Object>[];
      final obs = ov.observableValue<int, Object?>('ws', 0);
      roc.runOnChangeWithStore<int, Object?>(obs, (value, previousValue, deltas, store) {
        stores.add(store);
      });
      obs.set(1, null, 'd');
      obs.set(2, null, 'e');
      final tt = _truth()['runOnChangeWithStore'] as Map<String, dynamic>;
      expect(stores.length, tt['count']);
      expect(identical(stores[0], stores[1]), tt['sameStore']);
    });

    test('runOnChangeWithCancellationToken token cancels after dispose', () async {
      Object? token;
      final obs = ov.observableValue<int, Object?>('ct', 0);
      final d = roc.runOnChangeWithCancellationToken<int, Object?>(
        obs,
        (value, previousValue, deltas, tok) async {
          token = tok;
        },
      );
      obs.set(1, null, 'd');
      final before = (token as dynamic).isCancellationRequested as bool;
      final tt = _truth()['runOnChangeWithCancellationToken'] as Map<String, dynamic>;
      expect(before, tt['before']);
      d.dispose();
      final after = (token as dynamic).isCancellationRequested as bool;
      expect(after, tt['after']);
    });
  });
}
