// batch85: treeSitter stub services + structuredLogger + forwardingTelemetry +
// debugVisualization — data-driven from batch85_truth.json (Node vm against
// real TS sources with faithful stubs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, toDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/observable.dart'
    show autorun;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/structuredLogger.dart'
    as logger;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/view/inlineEdits/inlineEditsViews/debugVisualization.dart'
    as dv;
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/rect.dart'
    show Rect;
import 'package:semi_design_flutter/src/monaco/editor/standalone/browser/standaloneTreeSitterLibraryService.dart'
    as standalone;
import 'package:semi_design_flutter/src/monaco/editor/test/common/services/testTreeSitterLibraryService.dart'
    as testlib;
import 'package:semi_design_flutter/src/monaco/platform/dataChannel/browser/forwardingTelemetryService.dart'
    as fwd;
import 'package:semi_design_flutter/src/monaco/platform/dataChannel/common/dataChannel.dart'
    show CoreDataChannel, IDataChannelServiceType;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetry.dart'
    show ITelemetryData, ITelemetryServiceType;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch85_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

void main() {
  final t = _truth();

  group('treeSitter stub services', () {
    test('TestTreeSitterLibraryService returns match TS truth', () async {
      final e = (t['testTreeSitterService'] as Map) as Map<String, dynamic>;
      final svc = testlib.TestTreeSitterLibraryService();
      expect(svc.supportsLanguage('ts', null), e['supportsLanguage']);
      expect(svc.getLanguage('ts', false, null), isNull);
      expect(svc.getInjectionQueries('ts', null), e['getInjectionQueries']);
      expect(svc.getHighlightingQueries('ts', null), e['getHighlightingQueries']);
      expect(await _settleFut(() => svc.getParserClass()), e['getParserClass']);
      expect(await _settleFut(() => svc.getLanguagePromise('ts')),
          e['getLanguagePromise']);
      expect(await _settleFut(() => svc.createQuery(Object(), 'q')),
          e['createQuery']);
    });

    test('StandaloneTreeSitterLibraryService returns match TS truth', () async {
      final e = (t['standaloneTreeSitterService'] as Map) as Map<String, dynamic>;
      final svc = standalone.StandaloneTreeSitterLibraryService();
      expect(svc.supportsLanguage('ts', null), e['supportsLanguage']);
      expect(svc.getLanguage('ts', false, null), isNull);
      expect(svc.getInjectionQueries('ts', null), e['getInjectionQueries']);
      expect(svc.getHighlightingQueries('ts', null), e['getHighlightingQueries']);
      expect(await _settleFut(() => svc.getParserClass()), e['getParserClass']);
      expect(await _settleFut(() => svc.getLanguagePromise('ts')),
          e['getLanguagePromise']);
      expect(await _settleFut(() => svc.createQuery(Object(), 'q')),
          e['createQuery']);
    });
  });

  group('formatRecordableLogEntry', () {
    test('formats sourceId dropped + modelUri toString', () {
      final expected = (t['formatRecordableLogEntry'] as List).cast<String>();
      final entries = <Map<String, Object?>>[
        <String, Object?>{'sourceId': 'A', 'time': 1},
        <String, Object?>{'sourceId': 'B', 'time': 2, 'extra': 'x'},
        <String, Object?>{'sourceId': 'C', 'time': 3, 'modelUri': _Uri('file:///a.ts')},
      ];
      for (int i = 0; i < entries.length; i++) {
        expect(logger.formatRecordableLogEntry(entries[i]), expected[i]);
      }
    });
  });

  group('forwardingTelemetry pure funcs', () {
    test('forwardToChannelIf carries the symbol marker', () {
      final f = (t['forwarding'] as Map) as Map<String, dynamic>;
      final mTrue = fwd.forwardToChannelIf(true);
      final mFalse = fwd.forwardToChannelIf(false);
      // TS truth records `JSON.stringify` of the object: symbol keys are
      // dropped, so both serialize to `{}`. Verify that JSON-visible shape and
      // the in-memory symbol marker separately.
      expect((f['forwardToChannelIfTrue'] as Map).isEmpty, isTrue);
      expect(mTrue.keys.where((k) => k is String).isEmpty, isTrue);
      expect(mFalse.keys.where((k) => k is String).isEmpty, isTrue);
      expect(mTrue.containsKey(fwd.shouldForwardToChannel), isTrue);
      expect(mTrue[fwd.shouldForwardToChannel], true);
      expect(mFalse[fwd.shouldForwardToChannel], false);
    });

    test('isCopilotLikeExtension matches TS truth', () {
      final e = (t['forwarding'] as Map)['isCopilot'] as List;
      final ids = <String?>[
        'github.copilot',
        'GitHub.Copilot',
        'github.copilot-chat',
        'other.ext',
        null,
        '',
      ];
      for (int i = 0; i < ids.length; i++) {
        expect(fwd.isCopilotLikeExtension(ids[i]), e[i], reason: 'id $i');
      }
    });
  });

  group('InterceptingTelemetryService delegation', () {
    test('props, calls and intercepts match TS', () {
      final e = (t['intercepting'] as Map) as Map<String, dynamic>;
      final calls = <List<Object?>>[];
      final intercepts = <List<Object?>>[];
      final base = _BaseTelemetry(calls);
      final svc = fwd.InterceptingTelemetryService(base,
          (String n, Object? d) => intercepts.add(<Object?>[n, d]));
      svc.publicLog('e1', _MapTelemetryData(<String, Object?>{'a': 1}));
      svc.publicLog2('e2');
      svc.publicLogError('e3', _MapTelemetryData(<String, Object?>{'b': 2}));
      svc.publicLogError2('e4');
      svc.setExperimentProperty('x', 'y');
      svc.setCommonProperty('c', true);

      final props = (e['props'] as Map) as Map<String, dynamic>;
      expect(svc.telemetryLevel, props['telemetryLevel']);
      expect(svc.sessionId, props['sessionId']);
      expect(svc.machineId, props['machineId']);
      expect(svc.sqmId, props['sqmId']);
      expect(svc.devDeviceId, props['devDeviceId']);
      expect(svc.firstSessionDate, props['firstSessionDate']);
      expect(svc.msftInternal, props['msftInternal']);
      expect(svc.sendErrorTelemetry, props['sendErrorTelemetry']);

      _expectCallLists(calls, e['calls'] as List);
      _expectCallLists(intercepts, e['intercepts'] as List);
    });
  });

  group('debugVisualization', () {
    test('setVisualization marker + debugView triggers visualize once', () {
      final e = (t['debugViz'] as Map) as Map<String, dynamic>;
      int visualized = 0;
      final dv.IVisualizationEffect vis = _CountingVisualization(() => visualized++);
      final Map<String, Object?> data = <String, Object?>{'x': 1};
      dv.setVisualization(data, vis);
      // The marker key is `$$visualization` (JS literal, raw string).
      final bool realMark = data.containsKey(r'$$visualization') &&
          data[r'$$visualization'] == vis;
      expect(realMark, e['hasMark']);

      final d = autorun((reader) {
        dv.debugView(data, reader);
      });
      d.dispose();
      final plain = <String, Object?>{'y': 2};
      final d2 = autorun((reader) {
        dv.debugView(plain, reader);
      });
      d2.dispose();
      expect(visualized, e['visualizedAfterDebugView']);
    });

    test('debugLogRects converts array to record with visualization marker', () {
      final e = (t['debugViz'] as Map) as Map<String, dynamic>;
      final elem = _MockVizElement();
      final rects = <Rect>[
        Rect.fromLeftTopWidthHeight(0, 0, 1, 1),
        Rect.fromLeftTopWidthHeight(1, 1, 2, 2),
      ];
      final result = dv.debugLogRects(rects, elem) as Map;
      final keys = result.keys.map((k) => k.toString()).toList();
      expect(keys, e['debugLogRectsRecordKeys']);
      // visualize() disposes cleanly (no-op DOM carrier by default).
      (result[r'$$visualization'] as dv.IVisualizationEffect).visualize().dispose();
    });
  });
}

/// Settles a Future-or-sync-throw call into a truth-style string.
Future<String> _settleFut(Future<Object?> Function() thunk) async {
  try {
    final v = await thunk();
    return v == null ? 'undefined' : 'resolved';
  } catch (e) {
    return 'error:${e.toString().replaceFirst('Bad state: ', '')}';
  }
}

void _expectCallLists(List<List<Object?>> actual, List expected) {
  expect(actual.length, expected.length);
  for (int i = 0; i < expected.length; i++) {
    final exp = (expected[i] as List).cast<Object?>();
    for (int j = 0; j < exp.length; j++) {
      Object? a = actual[i][j];
      if (a is _MapTelemetryData) a = a.map;
      expect(a, exp[j], reason: 'call $i arg $j');
    }
  }
}

/// Carrier for the JS object-literal ITelemetryData payloads used in truth.
class _MapTelemetryData implements ITelemetryData {
  final Map<String, Object?> map;
  _MapTelemetryData(this.map);
  @override
  String? get from => map['from'] as String?;
  @override
  String? get target => map['target'] as String?;
}

class _Uri {
  final String v;
  _Uri(this.v);
  @override
  String toString() => v;
}

class _CountingVisualization implements dv.IVisualizationEffect {
  final void Function() onVisualize;
  _CountingVisualization(this.onVisualize);
  @override
  IDisposable visualize() {
    onVisualize();
    return toDisposable(() {});
  }
}

class _BaseTelemetry implements ITelemetryServiceType {
  final List<List<Object?>> calls;
  _BaseTelemetry(this.calls);
  @override
  Object? get _serviceBrand => null;
  @override
  int get telemetryLevel => 2;
  @override
  String get sessionId => 's';
  @override
  String get machineId => 'm';
  @override
  String get sqmId => 'q';
  @override
  String get devDeviceId => 'd';
  @override
  String get firstSessionDate => 'f';
  @override
  bool? get msftInternal => true;
  @override
  bool get sendErrorTelemetry => false;
  @override
  void publicLog(String eventName, [ITelemetryData? data]) =>
      calls.add(<Object?>['publicLog', eventName, data]);
  @override
  void publicLog2(String eventName, [Object? data]) =>
      calls.add(<Object?>['publicLog2', eventName, data]);
  @override
  void publicLogError(String errorEventName, [ITelemetryData? data]) =>
      calls.add(<Object?>['publicLogError', errorEventName, data]);
  @override
  void publicLogError2(String errorEventName, [Object? data]) =>
      calls.add(<Object?>['publicLogError2', errorEventName, data]);
  @override
  void setExperimentProperty(String name, String value) =>
      calls.add(<Object?>['setExperimentProperty', name, value]);
  @override
  void setCommonProperty(String name, Object? value) =>
      calls.add(<Object?>['setCommonProperty', name, value]);
}

class _MockVizElement implements dv.VizElement {
  @override
  dv.VizElement createElement(String tag) => _MockVizElement();
  @override
  void setStyle(dv.VizElement el, String key, String value) {}
  @override
  void setText(dv.VizElement el, String text) {}
  @override
  void appendChild(dv.VizElement parent, dv.VizElement child) {}
  @override
  void appendToBody(dv.VizElement el) {}
  @override
  void remove(dv.VizElement el) {}
  @override
  Map<String, num> getBoundingClientRect(dv.VizElement el) =>
      <String, num>{'left': 10, 'top': 20};
}
