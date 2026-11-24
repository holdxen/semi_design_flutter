// Truth-driven tests for base/browser/ui/scrollbar/abstractScrollbar.ts.
// Truth: tool/ts2dart/batch166_truth.json (real transpiled TypeScript module).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/globalPointerMoveMonitor.dart'
    as gpmm;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart'
    as mouse;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/abstractScrollbar.dart'
    as abs;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollbarArrow.dart'
    as sbarrow;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollbarState.dart'
    as sbstate;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollbarVisibilityController.dart'
    as svc;
import 'package:semi_design_flutter/src/monaco/base/browser/fastDomNode.dart' as fdn;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart' as scr;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart'
    as themables;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch166_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _map(Object? v) => (v as Map).cast<String, dynamic>();
List<dynamic> _list(Object? v) => (v as List).cast<dynamic>();

class FakeHost implements abs.ScrollbarHost {
  int dragStarts = 0;
  int dragEnds = 0;
  @override
  void onMouseWheel(mouse.StandardWheelEvent e) {}
  @override
  void onDragStart() => dragStarts++;
  @override
  void onDragEnd() => dragEnds++;
}

class FakeScrollable extends scr.Scrollable {
  FakeScrollable()
      : super(scr.ScrollableOptions(
            forceIntegerValues: false,
            smoothScrollDuration: 0,
            scheduleAtNextAnimationFrame: (cb) {
              cb();
              return lifecycle.Disposable.none;
            }));
  scr.NewScrollPosition? lastSet;
  @override
  void setScrollPositionNow(scr.NewScrollPosition update) {
    lastSet = update;
  }
}

/// Scripted ScrollbarState: overrides the geometry methods with numbers that
/// mirror the JS truth harness fakeState.
class ScriptedState extends sbstate.ScrollbarState {
  ScriptedState(this.cfg)
      : super(0, 0, 0, 0, 0, 0);

  final Map<String, dynamic> cfg;

  @override
  bool setVisibleSize(num visibleSize) => cfg['setVisibleSize'] ?? false;
  @override
  bool setScrollSize(num scrollSize) => cfg['setScrollSize'] ?? false;
  @override
  bool setScrollPosition(num scrollPosition) => cfg['setScrollPosition'] ?? false;
  @override
  void setScrollbarSize(num scrollbarSize) {}
  @override
  bool isNeeded() => cfg['isNeeded'] ?? true;
  @override
  num getRectangleLargeSize() => (cfg['large'] ?? 100) as num;
  @override
  num getRectangleSmallSize() => (cfg['small'] ?? 10) as num;
  @override
  num getSliderSize() => (cfg['sliderSize'] ?? 40) as num;
  @override
  num getArrowSize() => (cfg['arrowSize'] ?? 11) as num;
  @override
  num getSliderPosition() => (cfg['sliderPos'] ?? 5) as num;
  @override
  num getScrollPosition() => (cfg['scrollPos'] ?? 0) as num;
  @override
  sbstate.ScrollbarState clone() => this;
  @override
  num getDesiredScrollPositionFromOffset(num offset) => offset * 10;
  @override
  num getDesiredScrollPositionFromOffsetPaged(num offset) => offset * 20;
  @override
  num getDesiredScrollPositionFromDelta(num delta) => delta * 2;
}

/// Visibility controller that logs calls (mirrors JS VisibilityStub).
class LoggingVisibility extends svc.ScrollbarVisibilityController {
  LoggingVisibility(this.log, int visibility, String visible, String invisible)
      : super(visibility, visible, invisible);
  final List<List<Object?>> log;
  @override
  void setIsNeeded(bool isNeeded) => log.add(<Object?>['setIsNeeded', isNeeded]);
  @override
  void setDomNode(fdn.FastDomNode domNode) =>
      log.add(<Object?>['setDomNode', 'fdn']);
  @override
  void setShouldBeVisible(bool v) =>
      log.add(<Object?>['setShouldBeVisible', v]);
}

/// Pointer monitor that captures move/stop callbacks.
class FakeMonitor extends gpmm.GlobalPointerMoveMonitor {
  final List<Map<String, Object?>> starts = <Map<String, Object?>>[];
  gpmm.IPointerMoveCallback? moveCb;
  gpmm.IOnStopCallback? stopCb;
  @override
  void startMonitoring(
    dom.DomElement initialElement,
    int pointerId,
    int initialButtons,
    gpmm.IPointerMoveCallback pointerMoveCallback,
    gpmm.IOnStopCallback onStopCallback,
  ) {
    starts.add(<String, Object?>{'pointerId': pointerId, 'buttons': initialButtons});
    moveCb = pointerMoveCallback;
    stopCb = onStopCallback;
  }
}

class Concrete extends abs.AbstractScrollbar {
  Concrete(this.cfg, {this.lazy = false, required this.host})
      : super(abs.AbstractScrollbarOptions(
            lazyRender: lazy,
            host: host,
            scrollbarState: ScriptedState(cfg),
            visibility: scr.ScrollbarVisibility.Auto,
            extraScrollbarClassName: 'horizontal',
            scrollable: FakeScrollable(),
            scrollByPage: false));

  final Map<String, dynamic> cfg;
  final bool lazy;
  @override
  final FakeHost host;
  final List<List<Object?>> hooks = <List<Object?>>[];

  @override
  void renderDomNode(num largeSize, num smallSize) =>
      hooks.add(<Object?>['_renderDomNode', largeSize, smallSize]);
  @override
  void updateSlider(num sliderSize, num sliderPosition) =>
      hooks.add(<Object?>['_updateSlider', sliderSize, sliderPosition]);
  @override
  num pointerDownRelativePosition(num offsetX, num offsetY) {
    hooks.add(<Object?>['_pointerDownRelativePosition', offsetX, offsetY]);
    return offsetX + offsetY;
  }
  @override
  num sliderPointerPosition(Object e) {
    hooks.add(<Object?>['_sliderPointerPosition', _f(e, 'pageX'), _f(e, 'pageY')]);
    return _f(e, 'pageX');
  }
  @override
  num sliderOrthogonalPointerPosition(Object e) {
    hooks.add(<Object?>['_sliderOrthogonalPointerPosition', _f(e, 'pageX'), _f(e, 'pageY')]);
    return _f(e, 'pageY');
  }
  @override
  void updateScrollbarSizeImpl(num size) =>
      hooks.add(<Object?>['_updateScrollbarSize', size]);
  @override
  void writeScrollPosition(scr.NewScrollPosition target, num scrollPosition) =>
      hooks.add(<Object?>['writeScrollPosition', scrollPosition]);

  static num _f(Object e, String k) {
    if (e is Map) return (e[k] as num?) ?? 0;
    final dynamic d = e;
    final Object? v = k == 'pageX' ? d.pageX : d.pageY;
    return (v as num?) ?? 0;
  }
}

class PtrEvent {
  PtrEvent(this.fields);
  final Map<String, Object?> fields;
  Object? get target => fields['target'];
  int get button => (fields['button'] as num?)?.toInt() ?? 0;
  int get buttons => (fields['buttons'] as num?)?.toInt() ?? 0;
  int get pointerId => (fields['pointerId'] as num?)?.toInt() ?? 0;
  String? get pointerType => fields['pointerType'] as String?;
  num get pageX => (fields['pageX'] as num?) ?? 0;
  num get pageY => (fields['pageY'] as num?) ?? 0;
  void preventDefault() {
    final void Function()? f = fields['preventDefault'] as void Function()?;
    f?.call();
  }
}

void main() {
  List<List<Object?>> visLog = <List<Object?>>[];
  FakeMonitor? monitor;

  setUp(() {
    visLog = <List<Object?>>[];
    monitor = FakeMonitor();
    abs.visibilityControllerFactory = (int v, String vis, String inv) =>
        LoggingVisibility(visLog, v, vis, inv);
    abs.pointerMoveMonitorFactory = () => monitor!;
  });

  void expectHooks(List<List<Object?>> actual, List<dynamic> truth) {
    expect(actual.length, truth.length, reason: 'hook count');
    for (int i = 0; i < truth.length; i++) {
      final List<dynamic> t = _list(truth[i]);
      final List<Object?> a = actual[i];
      expect(a.length, t.length, reason: 'hook[$i] len');
      for (int j = 0; j < t.length; j++) {
        if (t[j] is num && a[j] is num) {
          expect((a[j] as num).toDouble(),
              closeTo((t[j] as num).toDouble(), 0.001),
              reason: 'hook[$i][$j]');
        } else {
          expect(a[j].toString(), t[j].toString(), reason: 'hook[$i][$j]');
        }
      }
    }
  }

  group('abstractScrollbar', () {
    test('constructor wiring matches truth', () {
      final Concrete c = Concrete(<String, dynamic>{'isNeeded': true},
          host: FakeHost());
      final Map<String, dynamic> t = _map(T['constructor']);
      final dom.DomElement real = c.realDomNode;
      expect(real.getAttribute('role'), t['domAttrs']['role']);
      expect(real.getAttribute('aria-hidden'), t['domAttrs']['aria-hidden']);
      expect(real.style['position'], _list(t['domPositionCall'])[1]);
      expect(
          visLog.map((e) => e.first).toList(),
          _list(t['visibilityLog']).map((e) => _list(e).first).toList());
      expect(c.hooks.where((h) => h.first == '_renderDomNode'), isEmpty);
    });

    test('render is idempotent via shouldRender', () {
      final Concrete c = Concrete(<String, dynamic>{
        'large': 200,
        'small': 12,
        'sliderSize': 50,
        'arrowSize': 11,
        'sliderPos': 7,
      }, lazy: true, host: FakeHost());
      c.hooks.clear();
      c.render();
      final List<List<Object?>> first = List<List<Object?>>.from(c.hooks);
      c.render();
      final List<List<Object?>> second = c.hooks.sublist(first.length);
      expectHooks(first, _list(_map(T['render'])['first']));
      expect(second, isEmpty);
    });

    test('onElementSize / ScrollSize / ScrollPosition return shouldRender', () {
      final Map<String, dynamic> cfg = <String, dynamic>{
        'setVisibleSize': true,
        'setScrollSize': true,
        'setScrollPosition': true,
      };
      final Map<String, bool Function(Concrete)> calls = <String, bool Function(Concrete)>{
        'onElementSize': (c) => c.onElementSize(300),
        'onElementScrollSize': (c) => c.onElementScrollSize(400),
        'onElementScrollPosition': (c) => c.onElementScrollPosition(12),
      };
      for (final String name in calls.keys) {
        final Concrete c = Concrete(cfg, lazy: true, host: FakeHost());
        expect(calls[name]!(c), _map(T[name])['ret']);
      }
    });

    test('beginReveal / beginHide call setShouldBeVisible', () {
      final Concrete c = Concrete(<String, dynamic>{}, host: FakeHost());
      visLog.clear();
      c.beginReveal();
      c.beginHide();
      final List<dynamic> t = _list(T['revealHide']);
      expect(visLog.length, t.length);
      expect(_list(t[0])[0], 'setShouldBeVisible');
      expect(visLog[0][1], _list(t[0])[1]);
      expect(visLog[1][1], _list(t[1])[1]);
    });

    test('updateScrollbarSize re-renders and isNeeded', () {
      final Concrete c = Concrete(<String, dynamic>{'isNeeded': true},
          host: FakeHost());
      c.hooks.clear();
      c.updateScrollbarSize(15);
      expectHooks(c.hooks, _list(_map(T['updateScrollbarSize'])['hooks']));
      expect(c.isNeeded(), _map(T['updateScrollbarSize'])['isNeeded']);
    });

    test('createArrow / createSlider wire DOM children and listeners', () {
      final Concrete c = Concrete(<String, dynamic>{}, host: FakeHost());
      c.createArrow(sbarrow.ScrollbarArrowOptions(
        onActivate: () {},
        className: 'a',
        icon: themables.ThemeIcon('chevron-up'),
        bgWidth: 11,
        bgHeight: 11,
      ));
      c.createSlider(3, 4, 20, null);
      final Map<String, dynamic> t = _map(T['createNodes']);
      expect(c.realDomNode.childNodes.length, t['domChildren']);
      expect(_list(t['sliderCalls']).first.first, 'setClassName');
    });

    test('delegatePointerDown inside slider -> slider drag', () {
      final Concrete c = Concrete(<String, dynamic>{
        'sliderPos': 5,
        'sliderSize': 40,
      }, host: FakeHost());
      c.createSlider(3, 4, 20, 40);
      // truth domNode.getClientRects()[0].top == 100
      c.realDomNode.clientRectsOverride = <dom.DomRect>[
        dom.DomRect(top: 100)
      ];
      c.hooks.clear();
      int prevented = 0;
      c.delegatePointerDown(PtrEvent(<String, Object?>{
        'target': Object(),
        'button': 0,
        'buttons': 1,
        'pageX': 120,
        'pageY': 130,
        'pointerId': 1,
        'pointerType': 'mouse',
        'preventDefault': () => prevented++,
      }));
      final Map<String, dynamic> t = _map(T['delegateInside']);
      expect(prevented, t['prevented']);
      expectHooks(c.hooks, _list(t['hooks']));
    });

    test('delegatePointerDown outside slider -> page jump', () {
      final Concrete c = Concrete(<String, dynamic>{
        'sliderPos': 5,
        'sliderSize': 40,
      }, host: FakeHost());
      c.createSlider(3, 4, 20, 40);
      c.realDomNode.clientRectsOverride = <dom.DomRect>[
        dom.DomRect(top: 100)
      ];
      c.realDomNode.rect = dom.DomRect(left: 10, top: 20);
      c.hooks.clear();
      int prevented = 0;
      c.delegatePointerDown(PtrEvent(<String, Object?>{
        'target': Object(),
        'button': 0,
        'buttons': 1,
        'pageX': 200,
        'pageY': 130,
        'pointerId': 1,
        'pointerType': 'mouse',
        'preventDefault': () => prevented++,
      }));
      final Map<String, dynamic> t = _map(T['delegateOutside']);
      expect(prevented, t['prevented']);
      expectHooks(c.hooks, _list(t['hooks']));
    });

    test('sliderPointerDown full drag path: monitor, move, stop', () {
      final FakeHost host = FakeHost();
      final Concrete c = Concrete(<String, dynamic>{}, host: host);
      c.createSlider(3, 4, 20, 40);
      c.hooks.clear();
      final dom.DomElement target = dom.DomElement('div');
      c.sliderPointerDown(PtrEvent(<String, Object?>{
        'target': target,
        'pointerId': 9,
        'buttons': 1,
        'pageX': 120,
        'pageY': 130,
      }));
      final Map<String, dynamic> t = _map(T['sliderDrag']);
      expect(monitor!.starts.first['pointerId'],
          _map(_list(t['monitors']).first)['pointerId']);
      expect(host.dragStarts, t['dragStarts']);
      expect(c.realSlider.classList.contains('active'), t['activeAfterStart']);

      c.hooks.clear();
      // Drive the move callback with a DomEvent carrying pageX/pageY.
      final dom.DomEvent move = dom.DomEvent('pointermove', target: target)
        ..pageX = 145
        ..pageY = 130;
      monitor!.moveCb!(move);
      expectHooks(c.hooks, _list(t['moveHooks']));

      monitor!.stopCb!();
      expect(c.realSlider.classList.contains('active'), t['activeAfterStop']);
      expect(host.dragEnds, t['dragEnds']);
    });
  });
}
