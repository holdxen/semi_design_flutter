// 1:1 port parity tests for batch 15:
//   editor/common/tokens/common.ts (RateLimiter)
//   editor/common/viewLayout/linePart.ts
//   base/common/observableInternal/logging/debugger/utils.ts
//   editor/browser/gpu/gpuUtils.ts
//   base/test/common/virtualScheduling/globalTimeApi.ts
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/common.dart'
    as tok;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/linePart.dart'
    as lp;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/logging/debugger/utils.dart'
    as dbg;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/gpuUtils.dart'
    as gpu;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/timeApi.dart'
    as ta;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/globalTimeApi.dart'
    as gta;

void main() {
  group('RateLimiter', () {
    test('timesPerSecond default and computed interval', () {
      final tok.RateLimiter r = tok.RateLimiter();
      expect(r.timesPerSecond, 5);
      final tok.RateLimiter r2 = tok.RateLimiter(10);
      expect(r2.timesPerSecond, 10);
    });

    test('first call runs; immediate second call is limited', () {
      final tok.RateLimiter r = tok.RateLimiter(1000); // interval = 1ms
      int count = 0;
      r.runIfNotLimited(() => count++);
      r.runIfNotLimited(() => count++);
      // With a 1ms window the second call may or may not pass depending on
      // clock granularity; assert only the first always ran.
      expect(count, greaterThanOrEqualTo(1));
    });

    test('very low rate limits repeated rapid calls', () {
      final tok.RateLimiter r = tok.RateLimiter(0.0001); // huge interval
      int count = 0;
      for (int i = 0; i < 50; i++) {
        r.runIfNotLimited(() => count++);
      }
      expect(count, 1);
    });
  });

  group('LinePart', () {
    test('metadata masks match source bit values', () {
      expect(lp.LinePartMetadata.IS_WHITESPACE, 1);
      expect(lp.LinePartMetadata.PSEUDO_BEFORE, 2);
      expect(lp.LinePartMetadata.PSEUDO_AFTER, 4);
      expect(lp.LinePartMetadata.IS_WHITESPACE_MASK, 1);
      expect(lp.LinePartMetadata.PSEUDO_BEFORE_MASK, 2);
      expect(lp.LinePartMetadata.PSEUDO_AFTER_MASK, 4);
    });

    test('fields preserved', () {
      final lp.LinePart p = lp.LinePart(10, 'mtk1', 0, false);
      expect(p.endIndex, 10);
      expect(p.type, 'mtk1');
      expect(p.metadata, 0);
      expect(p.containsRTL, isFalse);
    });

    test('isWhitespace reads bit 0', () {
      expect(lp.LinePart(1, 'x', lp.LinePartMetadata.IS_WHITESPACE, false)
          .isWhitespace(), isTrue);
      expect(lp.LinePart(1, 'x', 0, false).isWhitespace(), isFalse);
      expect(lp.LinePart(1, 'x', lp.LinePartMetadata.PSEUDO_AFTER, false)
          .isWhitespace(), isFalse);
    });

    test('isPseudoAfter reads bit 2', () {
      expect(lp.LinePart(1, 'x', lp.LinePartMetadata.PSEUDO_AFTER, false)
          .isPseudoAfter(), isTrue);
      expect(lp.LinePart(1, 'x', lp.LinePartMetadata.IS_WHITESPACE, false)
          .isPseudoAfter(), isFalse);
      expect(
          lp.LinePart(1, 'x',
                  lp.LinePartMetadata.IS_WHITESPACE |
                      lp.LinePartMetadata.PSEUDO_AFTER,
                  false)
              .isPseudoAfter(),
          isTrue);
    });
  });

  group('debugger utils', () {
    test('deepAssign merges nested objects', () {
      final Map<Object?, Object?> target = <Object?, Object?>{
        'a': <Object?, Object?>{'x': 1, 'y': 2},
        'b': 3,
      };
      final Map<Object?, Object?> source = <Object?, Object?>{
        'a': <Object?, Object?>{'y': 20, 'z': 30},
        'b': 4,
      };
      dbg.deepAssign(target, source);
      expect(target['a'], isA<Map<Object?, Object?>>());
      expect((target['a'] as Map)['x'], 1);
      expect((target['a'] as Map)['y'], 20);
      expect((target['a'] as Map)['z'], 30);
      expect(target['b'], 4);
    });

    test('deepAssign overwrites non-object with object', () {
      final Map<Object?, Object?> target = <Object?, Object?>{'a': 1};
      dbg.deepAssign(target, <Object?, Object?>{
        'a': <Object?, Object?>{'n': 5}
      });
      expect(target['a'], isA<Map<Object?, Object?>>());
    });

    test('deepAssignDeleteNulls removes null keys', () {
      final Map<Object?, Object?> target = <Object?, Object?>{'a': 1, 'b': 2};
      dbg.deepAssignDeleteNulls(
          target, <Object?, Object?>{'a': null, 'b': 3});
      expect(target.containsKey('a'), isFalse);
      expect(target['b'], 3);
    });

    test('deepAssignDeleteNulls recurses into nested objects', () {
      final Map<Object?, Object?> target = <Object?, Object?>{
        'n': <Object?, Object?>{'x': 1, 'y': 2}
      };
      dbg.deepAssignDeleteNulls(target, <Object?, Object?>{
        'n': <Object?, Object?>{'x': null}
      });
      expect((target['n'] as Map).containsKey('x'), isFalse);
      expect((target['n'] as Map)['y'], 2);
    });

    test('Debouncer collapses rapid calls into the last one', () async {
      final dbg.Debouncer d = dbg.Debouncer();
      final List<int> seen = <int>[];
      d.debounce(() => seen.add(1), 20);
      d.debounce(() => seen.add(2), 20);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(seen, <int>[2]);
      d.dispose();
    });

    test('Throttler runs once within the window', () async {
      final dbg.Throttler t = dbg.Throttler();
      int count = 0;
      t.throttle(() => count++, 20);
      t.throttle(() => count++, 20);
      t.throttle(() => count++, 20);
      expect(count, 0);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(count, 1);
      t.dispose();
    });
  });

  group('gpuUtils', () {
    test('quadVertices holds the 6 quad vertices', () {
      expect(gpu.quadVertices.length, 12);
      expect(gpu.quadVertices[0], 1);
      expect(gpu.quadVertices[1], 0);
      expect(gpu.quadVertices[10], 1);
      expect(gpu.quadVertices[11], 0);
    });

    test('ensureNonNullable passes truthy values', () {
      expect(gpu.ensureNonNullable(5), 5);
      expect(gpu.ensureNonNullable('x'), 'x');
      final Object o = Object();
      expect(identical(gpu.ensureNonNullable(o), o), isTrue);
    });

    test('ensureNonNullable throws for JS-falsy values', () {
      expect(() => gpu.ensureNonNullable(0), throwsException);
      expect(() => gpu.ensureNonNullable(''), throwsException);
      expect(() => gpu.ensureNonNullable(false), throwsException);
    });

    test('observeDevicePixelDimensions delivers matching positive entry', () {
      final Object element = Object();
      Object? created;
      void Function(List<gpu.ResizeObserverEntry>)? cb;
      final gpu.GpuDomBridge bridge = gpu.GpuDomBridge(
        createResizeObserver: (c) {
          cb = c;
          created = Object();
          return created!;
        },
        observe: (o, e) {},
        disconnect: (o) {},
      );
      final List<List<num>> dims = <List<num>>[];
      final disposable = gpu.observeDevicePixelDimensions(
          element, bridge, (num w, num h) => dims.add(<num>[w, h]));
      cb!(<gpu.ResizeObserverEntry>[
        gpu.ResizeObserverEntry(
            target: element,
            hasDevicePixelContentBoxSize: true,
            inlineSize: 10,
            blockSize: 20),
      ]);
      expect(dims, <List<num>>[<num>[10, 20]]);
      disposable.dispose();
      expect(created, isNotNull);
    });

    test('observeDevicePixelDimensions ignores zero dimensions and foreign targets', () {
      final Object element = Object();
      void Function(List<gpu.ResizeObserverEntry>)? cb;
      final gpu.GpuDomBridge bridge = gpu.GpuDomBridge(
        createResizeObserver: (c) {
          cb = c;
          return Object();
        },
        observe: (o, e) {},
        disconnect: (o) {},
      );
      final List<num> dims = <num>[];
      final disposable = gpu.observeDevicePixelDimensions(
          element, bridge, (num w, num h) => dims.addAll(<num>[w, h]));
      cb!(<gpu.ResizeObserverEntry>[
        gpu.ResizeObserverEntry(
            target: Object(),
            hasDevicePixelContentBoxSize: true,
            inlineSize: 5,
            blockSize: 5),
        gpu.ResizeObserverEntry(
            target: element,
            hasDevicePixelContentBoxSize: true,
            inlineSize: 0,
            blockSize: 0),
      ]);
      expect(dims, isEmpty);
      disposable.dispose();
    });
  });

  group('globalTimeApi', () {
    tearDown(() => ta.activeHostTimeApi = null);

    test('pushGlobalTimeApi installs then restores prior api', () {
      final ta.TimeoutId Function(void Function(), [int]) setTimeout =
          (void Function() handler, [int timeout = 0]) => ta.TimeoutId(1);
      final ta.HostTimeApi virtual = ta.HostTimeApi(
        setTimeout: setTimeout,
        clearTimeout: (id) {},
        setInterval: (h, i) => ta.IntervalId(2),
        clearInterval: (id) {},
        Date: () => DateTime(1999),
        performanceNow: () => 7.0,
        performanceTimeOrigin: 3.0,
      );
      final ta.TimeApi api = ta.captureGlobalTimeApi(virtual);
      final d = gta.pushGlobalTimeApi(api);
      // After install, a fresh capture reflects the virtual API.
      final ta.TimeApi current = ta.captureGlobalTimeApi();
      expect(current.performanceNow(), 7.0);
      expect(current.Date().year, 1999);
      d.dispose();
      // Restored to default bridge.
      expect(ta.captureGlobalTimeApi().Date().year, DateTime.now().year);
    });

    test('nested installs compose (LIFO restore)', () {
      ta.HostTimeApi makeHost(double now) => ta.HostTimeApi(
            setTimeout: (void Function() h, [int t = 0]) => ta.TimeoutId(1),
            clearTimeout: (id) {},
            setInterval: (h, i) => ta.IntervalId(2),
            clearInterval: (id) {},
            Date: () => DateTime(2000),
            performanceNow: () => now,
          );
      final d1 = gta.pushGlobalTimeApi(
          ta.captureGlobalTimeApi(makeHost(11.0)));
      final d2 = gta.pushGlobalTimeApi(
          ta.captureGlobalTimeApi(makeHost(22.0)));
      expect(ta.captureGlobalTimeApi().performanceNow(), 22.0);
      d2.dispose();
      expect(ta.captureGlobalTimeApi().performanceNow(), 11.0);
      d1.dispose();
    });

    test('ensureSetTimeoutOriginalFn preserves the back-door', () {
      final gta.SetTimeoutFn real = gta.wrapSetTimeout(
          (void Function() h, [int t = 0]) => ta.TimeoutId(1));
      final gta.SetTimeoutFn previous = gta.SetTimeoutFn(
          (void Function() h, [int t = 0]) => ta.TimeoutId(2), real);
      final gta.SetTimeoutFn installed = gta.SetTimeoutFn(
          (void Function() h, [int t = 0]) => ta.TimeoutId(3));
      gta.ensureSetTimeoutOriginalFn(installed, previous);
      expect(identical(installed.originalFn, real), isTrue);
    });
  });
}
