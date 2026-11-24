// Truth-driven tests for horizontalScrollbar.ts + verticalScrollbar.ts.
// Truth: tool/ts2dart/batch167_truth.json (real transpiled TypeScript modules).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/abstractScrollbar.dart'
    as abs;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/horizontalScrollbar.dart'
    as hbar;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/verticalScrollbar.dart'
    as vbar;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElementOptions.dart'
    as seo;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart' as scr;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart'
    as mouse;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch167_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _map(Object? v) => (v as Map).cast<String, dynamic>();
List<dynamic> _list(Object? v) => (v as List).cast<dynamic>();

class FakeHost implements abs.ScrollbarHost {
  final List<List<num>> wheels = <List<num>>[];
  @override
  void onMouseWheel(mouse.StandardWheelEvent e) =>
      wheels.add(<num>[e.deltaX, e.deltaY]);
  @override
  void onDragStart() {}
  @override
  void onDragEnd() {}
}

class FakeDimensions implements scr.IScrollDimensions, scr.IScrollPosition {
  @override
  num get width => 300;
  @override
  num get scrollWidth => 900;
  @override
  num get height => 200;
  @override
  num get scrollHeight => 600;
  @override
  num get scrollLeft => 15;
  @override
  num get scrollTop => 25;
}

class FakeScrollable extends scr.Scrollable {
  FakeScrollable()
      : super(scr.ScrollableOptions(
            forceIntegerValues: false,
            smoothScrollDuration: 0,
            scheduleAtNextAnimationFrame: (cb) {
              cb();
              return _noop;
            }));
  static final lifecycle.IDisposable _noop = _NoopDisposable();
  @override
  scr.IScrollDimensions getScrollDimensions() => FakeDimensions();
  @override
  scr.IScrollPosition getCurrentScrollPosition() => FakeDimensions();
}

class _NoopDisposable implements lifecycle.IDisposable {
  @override
  void dispose() {}
}

seo.ScrollableElementResolvedOptions makeOptions([Map<String, dynamic> ov = const {}]) {
  bool b(String k, bool d) => ov.containsKey(k) ? ov[k] as bool : d;
  num n(String k, num d) => ov.containsKey(k) ? (ov[k] as num) : d;
  int vis(String k, int d) => ov.containsKey(k) ? (ov[k] as int) : d;
  return seo.ScrollableElementResolvedOptions(
    lazyRender: b('lazyRender', false),
    className: (ov['className'] as String?) ?? '',
    useShadows: true,
    handleMouseWheel: true,
    flipAxes: false,
    scrollYToX: false,
    consumeMouseWheelIfScrollbarIsNeeded: false,
    alwaysConsumeMouseWheel: false,
    mouseWheelScrollSensitivity: 1,
    fastScrollSensitivity: 5,
    scrollPredominantAxis: true,
    mouseWheelSmoothScroll: true,
    inertialScroll: false,
    arrowSize: 11,
    listenOnDomNode: null,
    horizontal: vis('horizontal', scr.ScrollbarVisibility.Auto),
    horizontalScrollbarSize: n('horizontalScrollbarSize', 10),
    horizontalSliderSize: n('horizontalSliderSize', 8),
    horizontalHasArrows: b('horizontalHasArrows', false),
    vertical: vis('vertical', scr.ScrollbarVisibility.Auto),
    verticalScrollbarSize: n('verticalScrollbarSize', 10),
    verticalSliderSize: n('verticalSliderSize', 8),
    verticalHasArrows: b('verticalHasArrows', false),
    scrollByPage: b('scrollByPage', false),
  );
}

void expectNum(Object? actual, Object? truth, String why) {
  expect((actual as num).toDouble(), closeTo((truth as num).toDouble(), 0.001),
      reason: why);
}

void verifyArrows(abs.AbstractScrollbar bar, List<dynamic> truthArrows,
    FakeHost host) {
  expect(bar.arrows.length, truthArrows.length);
  host.wheels.clear();
  for (int i = 0; i < truthArrows.length; i++) {
    final Map<String, dynamic> ta = _map(truthArrows[i]);
    final arrow = bar.arrows[i];
    expect(arrow.domNode.classList.toList(),
        contains('codicon-${ta['iconId']}'),
        reason: 'arrow[$i] icon');
    expectNum(
        double.parse(arrow.bgDomNode.style['width']!.replaceAll('px', '')),
        ta['bgWidth'],
        'arrow[$i] bgWidth');
    expectNum(
        double.parse(arrow.bgDomNode.style['height']!.replaceAll('px', '')),
        ta['bgHeight'],
        'arrow[$i] bgHeight');
    arrow.activate();
    final List<dynamic> act = _list(ta['activates']);
    expect(host.wheels.last[0], act[0][0], reason: 'arrow[$i] deltaX');
    expect(host.wheels.last[1], act[0][1], reason: 'arrow[$i] deltaY');
  }
}

num styleNum(String? v) =>
    v == null ? 0 : double.parse(v.replaceAll('px', ''));

void main() {
  group('horizontalScrollbar', () {
    test('truth: arrows (icon/geometry/wheel deltas)', () {
      final Map<String, dynamic> t = _map(T['horizontal']);
      final FakeHost host = FakeHost();
      final hbar.HorizontalScrollbar bar = hbar.HorizontalScrollbar(
          FakeScrollable(),
          makeOptions(<String, dynamic>{'horizontalHasArrows': true}),
          host);
      verifyArrows(bar, _list(t['arrows']), host);
    });

    test('truth: slider geometry matches', () {
      final Map<String, dynamic> t = _map(T['horizontal']);
      final hbar.HorizontalScrollbar bar = hbar.HorizontalScrollbar(
          FakeScrollable(),
          makeOptions(<String, dynamic>{'horizontalHasArrows': true}),
          FakeHost());
      final Map<String, dynamic> s0 = _map(_list(t['sliders'])[0]);
      expectNum(styleNum(bar.realSlider.style['top']), s0['top']!, 'slider top');
      expectNum(styleNum(bar.realSlider.style['left']), s0['left']!, 'slider left');
      expectNum(styleNum(bar.realSlider.style['height']), s0['height']!, 'slider height');
    });

    test('truth: onDidScroll / writeScrollPosition / updateOptions', () {
      final scr.ScrollEvent e = scr.ScrollEvent(
          inSmoothScrolling: false,
          oldWidth: 0, oldScrollWidth: 0, oldScrollLeft: 0,
          width: 310, scrollWidth: 950, scrollLeft: 20,
          oldHeight: 0, oldScrollHeight: 0, oldScrollTop: 0,
          height: 200, scrollHeight: 600, scrollTop: 15,
          widthChanged: true, scrollWidthChanged: true, scrollLeftChanged: true,
          heightChanged: false, scrollHeightChanged: false, scrollTopChanged: false);
      final hbar.HorizontalScrollbar bar = hbar.HorizontalScrollbar(
          FakeScrollable(), makeOptions(<String, dynamic>{'lazyRender': true}),
          FakeHost());
      expect(bar.onDidScroll(e), _map(T['horizontal'])['onDidScroll']);
      final scr.NewScrollPosition target = scr.NewScrollPosition();
      bar.writeScrollPosition(target, 99);
      expect(target.scrollLeft,
          _map(_map(T['horizontal'])['writeTarget'])['scrollLeft']);
      bar.updateOptions(makeOptions(<String, dynamic>{
        'horizontal': scr.ScrollbarVisibility.Hidden,
        'vertical': scr.ScrollbarVisibility.Hidden,
        'horizontalScrollbarSize': 6,
        'verticalScrollbarSize': 7,
        'scrollByPage': true,
      }));
      final List<dynamic> calls = _list(_map(T['horizontal'])['sliderCalls']);
      expect(_list(calls[calls.length - 3])[1], 0);
      expect(_list(calls[calls.length - 2])[1], 0);
      expect(_list(calls[calls.length - 1])[1], 2);
    });

    test('truth: no-arrows variant has zero arrows', () {
      final hbar.HorizontalScrollbar bar = hbar.HorizontalScrollbar(
          FakeScrollable(), makeOptions(<String, dynamic>{'horizontalHasArrows': false}),
          FakeHost());
      expect(bar.arrows, isEmpty);
      expect(_list(_map(T['horizontalNoArrows'])['arrows']), isEmpty);
    });
  });

  group('verticalScrollbar', () {
    test('truth: arrows (icon/geometry/wheel deltas)', () {
      final Map<String, dynamic> t = _map(T['vertical']);
      final FakeHost host = FakeHost();
      final vbar.VerticalScrollbar bar = vbar.VerticalScrollbar(
          FakeScrollable(),
          makeOptions(<String, dynamic>{'verticalHasArrows': true}),
          host);
      verifyArrows(bar, _list(t['arrows']), host);
    });

    test('truth: slider geometry matches', () {
      final Map<String, dynamic> t = _map(T['vertical']);
      final vbar.VerticalScrollbar bar = vbar.VerticalScrollbar(
          FakeScrollable(),
          makeOptions(<String, dynamic>{'verticalHasArrows': true}),
          FakeHost());
      final Map<String, dynamic> s0 = _map(_list(t['sliders'])[0]);
      expectNum(styleNum(bar.realSlider.style['top']), s0['top']!, 'slider top');
      expectNum(styleNum(bar.realSlider.style['left']), s0['left']!, 'slider left');
      expectNum(styleNum(bar.realSlider.style['width']), s0['width']!, 'slider width');
    });

    test('truth: writeScrollPosition sets scrollTop', () {
      final vbar.VerticalScrollbar bar = vbar.VerticalScrollbar(
          FakeScrollable(), makeOptions(), FakeHost());
      final scr.NewScrollPosition target = scr.NewScrollPosition();
      bar.writeScrollPosition(target, 99);
      expect(target.scrollTop,
          _map(_map(T['vertical'])['writeTarget'])['scrollTop']);
    });
  });
}
