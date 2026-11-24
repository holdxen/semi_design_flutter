// Truth-driven tests for base/browser/ui/scrollbar/scrollableElement.ts.
// Truth: tool/ts2dart/batch168_truth.json — real transpiled module + the
// official vscode MouseWheelClassifier test corpus.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElement.dart'
    as se;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElementOptions.dart'
    as seo;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart'
    as mouse;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart'
    as platform;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart'
    as scr;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch168_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _map(Object? v) => (v as Map).cast<String, dynamic>();
List<dynamic> _list(Object? v) => (v as List).cast<dynamic>();

void main() {
  group('scrollableElement exports/constants', () {
    test('exported symbols match truth', () {
      final List<String> expected =
          _list(T['exports']).map((Object? e) => e as String).toList()..sort();
      expect(<String>[
        'AbstractScrollableElement',
        'DEFAULT_SCROLLBAR_SIZE',
        'DomScrollableElement',
        'MouseWheelClassifier',
        'ScrollableElement',
        'SmoothScrollableElement',
        'disableScrollbarRevealOnScroll',
        'onDidChangeDefaultScrollbarSize',
        'setGlobalDefaultScrollbarSize',
      ], expected);
      expect(se.DEFAULT_SCROLLBAR_SIZE, T['DEFAULT_SCROLLBAR_SIZE']);
    });

    test('setGlobalDefaultScrollbarSize fires only on change, dispose stops', () {
      se.resetGlobalDefaultScrollbarSizeForTest();
      final List<int> seen = <int>[];
      final disposable = se.onDidChangeDefaultScrollbarSize((dynamic v) => seen.add(v as int));
      se.setGlobalDefaultScrollbarSize(24);
      se.setGlobalDefaultScrollbarSize(24); // no-op
      se.setGlobalDefaultScrollbarSize(30);
      disposable.dispose();
      se.setGlobalDefaultScrollbarSize(40); // after dispose
      expect(seen, _list(T['defaultSize']['seen']));
      se.resetGlobalDefaultScrollbarSizeForTest();
    });
  });

  group('MouseWheelClassifier (official vscode corpus)', () {
    for (final String name in _map(T['suites']).keys) {
      test(name, () {
        final Map<String, dynamic> suite = _map(_map(T['suites'])[name]);
        final List<dynamic> results = _list(suite['results']);
        final se.MouseWheelClassifier classifier = se.MouseWheelClassifier();
        final bool guarded = suite['guarded'] as bool;
        final bool expected = suite['expected'] as bool;
        final List<dynamic> events = _list(suite['events']);
        for (int i = 0; i < results.length; i++) {
          // Replay the exact official event: [timestamp, deltaY, deltaX].
          final List<dynamic> ev = _list(events[i]);
          classifier.accept(ev[0] as num, ev[2] as num, ev[1] as num);
          final bool actual = classifier.isPhysicalMouseWheel();
          final bool want = (guarded && i == 0) ? results[i] as bool : expected;
          expect(actual, want, reason: '$name i=$i');
        }
      });
    }
  });

  group('resolveOptions defaults', () {
    test('matches source-derived truth', () {
      se.resetGlobalDefaultScrollbarSizeForTest();
      final seo.ScrollableElementCreationOptions o =
          seo.ScrollableElementCreationOptions();
      final seo.ScrollableElementResolvedOptions r = se.resolveOptions(o);
      final Map<String, dynamic> d = _map(T['resolveDefaults']);
      void expectVal(Object? actual, String expr, String name) {
        switch (expr) {
          case 'true':
            expect(actual, true, reason: name);
            break;
          case 'false':
            expect(actual, false, reason: name);
            break;
          case "''":
            expect(actual, '', reason: name);
            break;
          case 'null':
            expect(actual, isNull, reason: name);
            break;
          default:
            expect((actual as num).toDouble(),
                closeTo(double.parse(expr), 0.001),
                reason: name);
        }
      }
      expectVal(r.lazyRender, d['lazyRender'] as String, 'lazyRender');
      if (platform.isMacintosh) {
        expect(r.className, ' mac', reason: 'className (mac)');
      } else {
        expectVal(r.className, d['className'] as String, 'className');
      }
      expectVal(r.useShadows, d['useShadows'] as String, 'useShadows');
      expectVal(r.handleMouseWheel, d['handleMouseWheel'] as String, 'handleMouseWheel');
      expectVal(r.flipAxes, d['flipAxes'] as String, 'flipAxes');
      expectVal(r.horizontal, d['horizontal'] as String, 'horizontal');
      expectVal(r.vertical, d['vertical'] as String, 'vertical');
      expectVal(r.arrowSize, d['arrowSize'] as String, 'arrowSize');
      expectVal(r.mouseWheelScrollSensitivity,
          d['mouseWheelScrollSensitivity'] as String, 'sensitivity');
      expectVal(r.fastScrollSensitivity,
          d['fastScrollSensitivity'] as String, 'fastSensitivity');
      expectVal(r.horizontalScrollbarSize,
          d['horizontalScrollbarSize'] as String, 'hBarSize');
      expectVal(r.verticalScrollbarSize,
          d['verticalScrollbarSize'] as String, 'vBarSize');
      expectVal(r.scrollByPage, d['scrollByPage'] as String, 'scrollByPage');
      // slider sizes fall back to bar sizes
      expect(r.horizontalSliderSize, r.horizontalScrollbarSize);
      expect(r.verticalSliderSize, r.verticalScrollbarSize);
      final Map<String, dynamic> fu = _map(T['resolveSliderFollowup']);
      expect(fu['horizontalSliderSizeFallsToBar'], true);
      expect(fu['verticalSliderSizeFallsToBar'], true);
    });

    test('mac class suffix follows platform', () {
      final seo.ScrollableElementResolvedOptions r =
          se.resolveOptions(seo.ScrollableElementCreationOptions());
      if (platform.isMacintosh) {
        expect(r.className.endsWith(' mac'), isTrue);
      } else {
        expect(r.className, '');
      }
    });
  });
}
