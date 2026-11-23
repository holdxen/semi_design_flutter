// Data-driven port test for batch94: base/browser/pixelRatio.ts.
// Truth: tool/ts2dart/batch94_truth.json (generated from the real TS module).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/pixelRatio.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';

const String truthJson = r"""
{
  "exports": [
    "PixelRatio"
  ],
  "ratios": [
    {
      "ratio": 0,
      "backing": null,
      "value": 1
    },
    {
      "ratio": 0,
      "backing": 1,
      "value": 1
    },
    {
      "ratio": 0,
      "backing": 2,
      "value": 0.5
    },
    {
      "ratio": 1,
      "backing": null,
      "value": 1
    },
    {
      "ratio": 1,
      "backing": 1,
      "value": 1
    },
    {
      "ratio": 1,
      "backing": 2,
      "value": 0.5
    },
    {
      "ratio": 1.25,
      "backing": null,
      "value": 1.25
    },
    {
      "ratio": 1.25,
      "backing": 1,
      "value": 1.25
    },
    {
      "ratio": 1.25,
      "backing": 2,
      "value": 0.625
    },
    {
      "ratio": 2,
      "backing": null,
      "value": 2
    },
    {
      "ratio": 2,
      "backing": 1,
      "value": 2
    },
    {
      "ratio": 2,
      "backing": 2,
      "value": 1
    }
  ],
  "monitor": {
    "before": [
      1.5,
      true
    ],
    "queries": [
      "(resolution: 2dppx)",
      "(resolution: 3dppx)"
    ],
    "afterChanges": [
      2,
      3
    ],
    "beforeDispose": 1,
    "afterDispose": 0
  },
  "unregister": {
    "same": true,
    "value": 1
  }
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> list(Object? v) => (v as List).cast<Object?>();

CodeWindow windowOf(int id, double dpr) {
  final CodeWindow w = CodeWindow(Object(), id);
  windowCarrier(w).devicePixelRatio = dpr;
  return w;
}

void main() {
  test('batch94 exports', () {
    expect(truth['exports'], <Object?>['PixelRatio']);
    expect(PixelRatio, isA<PixelRatioMonitorFacade>());
  });

  test('batch94 ratio computation matrix', () {
    final List<BackingStoreContext?> contexts = <BackingStoreContext?>[
      null,
      BackingStoreContext()..backingStorePixelRatio = 1,
      BackingStoreContext()..backingStorePixelRatio = 2,
    ];
    int i = 0;
    for (final Object? raw in list(truth['ratios'])!) {
      final Map<String, Object?> c = obj(raw)!;
      final int backingIndex = c['backing'] == null ? 0 : (c['backing'] as num).toInt();
      canvasContextProvider = () => contexts[backingIndex];
      final CodeWindow w = windowOf(3000 + i, (c['ratio'] as num).toDouble());
      expect(PixelRatio.getInstance(w).value, c['value'], reason: c.toString());
      i++;
    }
    canvasContextProvider = () => null;
  });

  test('batch94 matchMedia monitoring and facade cache', () {
    final List<String> queries = <String>[];
    final Map<int, DomMediaQueryList> latest = <int, DomMediaQueryList>{};
    matchMediaProvider = (CodeWindow w, String query) {
      queries.add(query);
      final DomMediaQueryList mql = DomMediaQueryList(query);
      latest[w.vscodeWindowId] = mql;
      return mql;
    };
    canvasContextProvider = () => null;

    final CodeWindow w1 = windowOf(42, 1.5);
    final IPixelRatioMonitor monitor = PixelRatio.getInstance(w1);
    final IPixelRatioMonitor again = PixelRatio.getInstance(w1);
    final Map<String, Object?> mTruth = obj(truth['monitor'])!;
    expect(<Object?>[monitor.value, identical(monitor, again)], mTruth['before']);

    final int start = queries.length;
    final List<num> changes = <num>[];
    final l = monitor.onDidChange((dynamic v) => changes.add(v as num));
    windowCarrier(w1).devicePixelRatio = 2;
    latest[42]!.fireChange();
    windowCarrier(w1).devicePixelRatio = 3;
    latest[42]!.fireChange();
    expect(changes, mTruth['afterChanges']);
    expect(queries.sublist(start), mTruth['queries']);
    l.dispose();

    final CodeWindow w2 = windowOf(43, 1);
    final IPixelRatioMonitor m2 = PixelRatio.getInstance(w2);
    final IPixelRatioMonitor m2Again = PixelRatio.getInstance(windowOf(43, 1));
    final Map<String, Object?> uTruth = obj(truth['unregister'])!;
    expect(identical(m2, m2Again), uTruth['same']);
    expect(m2Again.value, uTruth['value']);

    matchMediaProvider = (CodeWindow w, String query) => DomMediaQueryList(query);
    canvasContextProvider = () => null;
  });
}
