// batch84: treeSitter service interfaces + dataChannel + wrap classes +
// base/browser/performance (inputLatency) — data-driven from
// batch84_truth.json (Node vm against the real TS sources with faithful stubs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/performance.dart' as perf;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, toDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/observable.dart'
    show IObservable, IReader;
import 'package:semi_design_flutter/src/monaco/editor/common/services/treeSitter/treeSitterThemeService.dart'
    as theme;
import 'package:semi_design_flutter/src/monaco/editor/common/services/treeSitter/treeSitterLibraryService.dart'
    as libsvc;
import 'package:semi_design_flutter/src/monaco/platform/dataChannel/common/dataChannel.dart'
    as dc;
import 'package:semi_design_flutter/src/monaco/platform/observable/common/wrapInReloadableClass.dart'
    as wrapRel;
import 'package:semi_design_flutter/src/monaco/platform/observable/common/wrapInHotClass.dart'
    as wrapHot;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch84_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

void main() {
  final t = _truth();

  group('decorators (service id identity)', () {
    test('createDecorator ids match TS truth', () {
      final d = t['decorators'] as Map<String, dynamic>;
      expect(theme.ITreeSitterThemeService.serviceId,
          d['ITreeSitterThemeService']);
      expect(libsvc.ITreeSitterLibraryService.serviceId,
          d['ITreeSitterLibraryService']);
      expect(dc.IDataChannelService.serviceId, d['IDataChannelService']);
      expect(dc.ILinkPresentationService.serviceId,
          d['ILinkPresentationService']);
    });
  });

  group('parseLinkPresentation', () {
    final p = t['parseLinkPresentation'] as Map<String, dynamic>;

    Map<String, dynamic>? tryParse(Object? value) {
      try {
        return <String, dynamic>{'ok': true, 'value': dc.parseLinkPresentation(value)};
      } catch (e) {
        // TS truth stores the raw Error.message.
        final msg = e.toString().replaceFirst('Bad state: ', '');
        return <String, dynamic>{'ok': false, 'error': msg};
      }
    }

    void expectCase(String key, Object? value) {
      final expected = (p[key] as Map) as Map<String, dynamic>;
      final actual = tryParse(value)!;
      expect(actual['ok'], expected['ok'], reason: 'case $key ok');
      if (expected['ok'] == true) {
        expect(actual['value'], expected['value'], reason: 'case $key value');
      } else {
        expect(actual['error'], expected['error'], reason: 'case $key error');
      }
    }

    test('valid minimal / full / optional-wrong-types', () {
      expectCase('minimal', <String, Object?>{'kind': 'resource'});
      expectCase('full', <String, Object?>{
        'kind': 'pullRequest',
        'title': 't',
        'detail': 'd',
        'reference': '#1',
        'status': <String, Object?>{'kind': 'success', 'label': 'ok'},
        'secondaryStatus': <String, Object?>{'kind': 'pending', 'label': 'wait'},
        'changes': <String, Object?>{'insertions': 5, 'deletions': 2},
        'tooltip': 'tip',
        'ariaLabel': 'aria',
        'isLoading': true,
      });
      expectCase('optionalWrongTypes', <String, Object?>{
        'kind': 'issue',
        'title': 5,
        'detail': null,
        'reference': <Object?>[],
        'tooltip': <String, Object?>{},
        'ariaLabel': 0,
        'isLoading': 'yes',
      });
    });

    test('invalid payloads throw the TS messages', () {
      expectCase('nullValue', null);
      expectCase('numberValue', 42);
      expectCase('arrayValue', <Object?>[]);
      expectCase('missingKind', <String, Object?>{'title': 'x'});
      expectCase('badKind', <String, Object?>{'kind': 'nope'});
    });

    test('status validation', () {
      expectCase('statusBad', <String, Object?>{
        'kind': 'resource',
        'status': <String, Object?>{'kind': 'bad', 'label': 'x'},
      });
      expectCase('statusMissingLabel', <String, Object?>{
        'kind': 'resource',
        'status': <String, Object?>{'kind': 'success'},
      });
      expectCase('statusNull', <String, Object?>{
        'kind': 'resource',
        'status': null,
      });
    });

    test('changes validation', () {
      expectCase('changesBad', <String, Object?>{
        'kind': 'resource',
        'changes': <String, Object?>{'insertions': 'a', 'deletions': 2},
      });
      expectCase('changesMissing', <String, Object?>{
        'kind': 'resource',
        'changes': <String, Object?>{'insertions': 1},
      });
      expectCase('changesNull', <String, Object?>{
        'kind': 'resource',
        'changes': null,
      });
    });

    test('every LinkPresentationKind is accepted', () {
      final each = (p['kindEach'] as List).cast<Map<String, dynamic>>();
      for (final entry in each) {
        final actual = tryParse(<String, Object?>{'kind': entry['k']})!;
        expect(actual['ok'], entry['ok'], reason: 'kind ${entry['k']}');
      }
    });
  });

  group('NullDataChannelService', () {
    test('onDidSendData is Event.None and sendData is a no-op', () {
      final n = (t['nullDataChannel'] as Map) as Map<String, dynamic>;
      final svc = dc.NullDataChannelService();
      // Both Dart eventNone and the TS Event.None are the shared no-op event.
      bool same = false;
      final d = svc.onDidSendData((_) {
        same = true;
        return toDisposable(() {});
      });
      d.dispose();
      expect(!same, n['onDidSendDataIsNone']);
      bool threw = false;
      try {
        svc.getDataChannel('anything').sendData(<String, Object?>{'x': 1});
      } catch (_) {
        threw = true;
      }
      expect(!threw, n['sendDataNoop']);
    });
  });

  group('wrap classes (disabled hot-reload path)', () {
    test('wrap0/wrap1 return the original; hotClassGetOriginalInstance is identity', () {
      final w = (t['wrapDisabled'] as Map) as Map<String, dynamic>;
      final Object original = Object();
      final Object Function() getClass = () => original;
      expect(identical(wrapRel.wrapInReloadableClass0(getClass), original),
          w['reloadable0Same']);
      expect(identical(wrapRel.wrapInReloadableClass1(getClass), original),
          w['reloadable1Same']);
      final IObservable<Object> obs = _ConstObservable<Object>(original);
      expect(identical(wrapHot.wrapInHotClass0(obs), original), w['hot0Same']);
      expect(identical(wrapHot.wrapInHotClass1(obs), original), w['hot1Same']);
      expect(
          identical(wrapHot.hotClassGetOriginalInstance(original), original),
          w['getOriginalIdentity']);
    });
  });

  group('inputLatency state machine', () {
    test('full sample recorded; sampleCount and measurements match TS', () {
      final il = (t['inputLatency'] as Map) as Map<String, dynamic>;
      final carrier = _SyncPerformance();
      final micro = <void Function()>[];
      final macro = <void Function()>[];

      final oldPerf = perf.inputLatencyPerformance;
      final oldMicro = perf.inputLatencyQueueMicrotask;
      final oldMacro = perf.inputLatencySetTimeout;
      perf.inputLatencyPerformance = carrier;
      perf.inputLatencyQueueMicrotask = micro.add;
      perf.inputLatencySetTimeout = macro.add;
      void flush() {
        while (micro.isNotEmpty) micro.removeAt(0)();
        while (macro.isNotEmpty) macro.removeAt(0)();
      }

      try {
        expect(perf.inputLatency.sampleCount.get(), il['initialSampleCount']);

        perf.inputLatency.onKeyDown();
        flush();
        perf.inputLatency.onBeforeInput();
        perf.inputLatency.onInput();
        flush();
        expect(perf.inputLatency.sampleCount.get(), il['midSampleCount']);

        perf.inputLatency.onKeyUp();
        perf.inputLatency.onRenderStart();
        flush();
        expect(perf.inputLatency.sampleCount.get(), il['finalSampleCount']);

        final measurements = perf.inputLatency.getAndClearMeasurements();
        final expectedM = (il['measurements'] as Map) as Map<String, dynamic>;
        expect(measurements, isNotNull);
        for (final key in expectedM.keys) {
          expect(measurements![key], expectedM[key], reason: 'measure $key');
        }
        // afterClear is TS `undefined` -> Dart null.
        expect(perf.inputLatency.getAndClearMeasurements(), isNull);
      } finally {
        perf.inputLatencyPerformance = oldPerf;
        perf.inputLatencyQueueMicrotask = oldMicro;
        perf.inputLatencySetTimeout = oldMacro;
      }
    });
  });
}

/// Minimal IObservable whose `get`/`read` always returns a fixed value.
class _ConstObservable<T> implements IObservable<T> {
  final T value;
  _ConstObservable(this.value);

  @override
  T get() => value;

  @override
  T read(IReader? reader) => value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Synchronous performance carrier: `measure` yields duration 1 to match the
/// TS truth stub (which returns duration: 1 for every measure).
class _SyncPerformance implements perf.InputLatencyPerformance {
  final List<String> _marks = <String>[];
  final List<perf.InputLatencyMeasureEntry> _measures =
      <perf.InputLatencyMeasureEntry>[];

  @override
  void mark(String name) => _marks.add(name);

  @override
  void measure(String name, String start, String end) =>
      _measures.add(perf.InputLatencyMeasureEntry(name, 1));

  @override
  List<perf.InputLatencyMeasureEntry> getEntriesByName(String name) =>
      _measures.where((e) => e.name == name).toList();

  @override
  void clearMarks([String? name]) {
    if (name == null) {
      _marks.clear();
    } else {
      _marks.removeWhere((m) => m == name);
    }
  }

  @override
  void clearMeasures([String? name]) {
    if (name == null) {
      _measures.clear();
    } else {
      _measures.removeWhere((e) => e.name == name);
    }
  }
}
