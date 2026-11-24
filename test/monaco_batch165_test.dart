// Truth-driven tests for base/browser/ui/scrollbar/scrollbarArrow.ts.
// Truth: tool/ts2dart/batch165_truth.json (real transpiled TypeScript module).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/globalPointerMoveMonitor.dart'
    as gpmm;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollbarArrow.dart'
    as sa;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart'
    as themables;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch165_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _map(Object? v) => (v as Map).cast<String, dynamic>();
List<dynamic> _list(Object? v) => (v as List).cast<dynamic>();

class _FakeTimer implements sa.ScrollbarArrowTimer {
  final List<Object?> calls = <Object?>[];
  void Function()? runner;
  @override
  void cancel() => calls.add('cancel');
  @override
  void cancelAndSet(void Function() runner, num value, [Object? context]) {
    calls.add(<Object?>['cancelAndSet', value, context]);
    this.runner = runner;
  }
  @override
  void dispose() {}
}

class _FakeMonitor extends gpmm.GlobalPointerMoveMonitor {
  final List<Map<String, Object?>> starts = <Map<String, Object?>>[];
  gpmm.IOnStopCallback? stopCb;
  @override
  void startMonitoring(
    dom.DomElement initialElement,
    int pointerId,
    int initialButtons,
    gpmm.IPointerMoveCallback pointerMoveCallback,
    gpmm.IOnStopCallback onStopCallback,
  ) {
    starts.add(<String, Object?>{
      'pointerId': pointerId,
      'buttons': initialButtons,
      'targetIsElement': true,
    });
    stopCb = onStopCallback;
  }
}

void main() {
  late _FakeTimer repeat;
  late _FakeTimer schedule;
  late _FakeMonitor monitor;

  setUp(() {
    repeat = _FakeTimer();
    schedule = _FakeTimer();
    monitor = _FakeMonitor();
    sa.repeatTimerFactory = () => repeat;
    sa.scheduleTimerFactory = () => schedule;
    sa.pointerMoveMonitorFactory = () => monitor;
  });

  group('scrollbarArrow', () {
    test('exports and ARROW_IMG_SIZE match truth', () {
      expect(sa.ARROW_IMG_SIZE, T['ARROW_IMG_SIZE']);
      final List<String> expected =
          _list(T['exports']).map((Object? e) => e as String).toList()..sort();
      expect(<String>['ARROW_IMG_SIZE', 'ScrollbarArrow'], expected);
    });

    sa.ScrollbarArrow build(Map<String, dynamic> sc) {
      final Map<String, dynamic> o = _map(sc['o']);
      final List<String> iconParts = _list(o['icon']).cast<String>();
      final themables.ThemeIcon icon = themables.ThemeIcon(iconParts[0]);
      int? optNum(String k) =>
          o.containsKey(k) ? (o[k] as num).toInt() : null;
      return sa.ScrollbarArrow(sa.ScrollbarArrowOptions(
        onActivate: () {},
        className: o['className'] as String,
        icon: icon,
        bgWidth: (o['bgWidth'] as num).toInt(),
        bgHeight: (o['bgHeight'] as num).toInt(),
        top: optNum('top'),
        left: optNum('left'),
        bottom: optNum('bottom'),
        right: optNum('right'),
      ));
    }

    void expectEl(dom.DomElement el, Map<String, dynamic> truthEl) {
      expect(el.className, truthEl['className']);
      final List<String> classes = _list(truthEl['classes']).cast<String>();
      expect(el.classList.toList(), classes);
      final Map<String, dynamic> style = _map(truthEl['style']);
      style.forEach((String k, dynamic v) {
        expect(el.style[k], v, reason: 'style[$k]');
      });
    }

    for (final String name in _map(T['construct']).keys) {
      test('constructor DOM structure: $name', () {
        final Map<String, dynamic> sc = _map(_map(T['construct'])[name]);
        // Rebuild the options from a compact literal keyed by scenario name.
        final Map<String, dynamic> opts = _scenarioOpts(name);
        final Map<String, dynamic> wrapped = <String, dynamic>{
          'o': opts,
        };
        final sa.ScrollbarArrow arrow = build(wrapped);
        expectEl(arrow.bgDomNode, _map(sc['bg']));
        expectEl(arrow.domNode, _map(sc['dom']));
        expect(sc['timers'], 2);
        final List<dynamic> listeners = _list(sc['listeners']);
        expect(listeners.length, 2);
        expect(_map(listeners[0])['node'], 'bg');
        expect(_map(listeners[0])['type'], dom.EventType.POINTER_DOWN);
        expect(_map(listeners[1])['node'], 'dom');
      });
    }

    test('pointerdown activates once and prevents default', () {
      int activations = 0;
      final sa.ScrollbarArrowOptions opts = sa.ScrollbarArrowOptions(
        onActivate: () => activations++,
        className: 'scrollbar-arrow up',
        icon: themables.ThemeIcon('arrow-up'),
        bgWidth: 11,
        bgHeight: 11,
      );
      final sa.ScrollbarArrow arrow = sa.ScrollbarArrow(opts);
      final Map<String, Object?> ptr = <String, Object?>{
        'target': arrow.bgDomNode,
        'pointerId': 7,
        'buttons': 2,
      };
      int prevented = 0;
      arrow.arrowPointerDown(_PtrEvent(ptr, () => prevented++));
      expect(activations, 1);
      expect(prevented, 1);
    });

    test('pointerdown timer/monitor calls match truth', () {
      final sa.ScrollbarArrow arrow = build(<String, dynamic>{
        'o': _scenarioOpts('basic'),
      });
      final Map<String, Object?> ptr = <String, Object?>{
        'target': arrow.bgDomNode,
        'pointerId': 7,
        'buttons': 2,
      };
      arrow.arrowPointerDown(_PtrEvent(ptr, () {}));

      final Map<String, dynamic> valid = _map(_map(T['pointerDown'])['valid']);
      expect(monitor.starts.length, 1);
      expect(_map(monitor.starts.first)['pointerId'],
          valid['monitor'][0]['pointerId']);
      expect(_map(monitor.starts.first)['buttons'],
          valid['monitor'][0]['buttons']);
      // repeat: cancel ; schedule: cancelAndSet(200)
      expect(repeat.calls.first, 'cancel');
      final List<dynamic> schedCall = _list(schedule.calls.first).cast<dynamic>();
      expect(schedCall[0], 'cancelAndSet');
      expect((schedCall[1] as num).toInt(),
          (valid['schedule'][0][1] as num).toInt());

      // firing the scheduled repeater -> repeat.cancelAndSet(1000/24, window)
      schedule.runner!();
      final List<dynamic> repCall = _list(repeat.calls[1]).cast<dynamic>();
      expect(repCall[0], 'cancelAndSet');
      expect((repCall[1] as num).round(),
          ((_map(_map(T['pointerDown'])['afterRepeater'])['repeat'][1][1] as num).round()));
      expect(repCall[2], isNotNull);
    });

    test('pointerdown with null / non-element target is ignored', () {
      final sa.ScrollbarArrow arrow = build(<String, dynamic>{
        'o': _scenarioOpts('basic'),
      });
      arrow.arrowPointerDown(<String, Object?>{
        'target': null,
        'pointerId': 1,
        'buttons': 0,
      });
      arrow.arrowPointerDown(<String, Object?>{
        'target': Object(),
        'pointerId': 1,
        'buttons': 0,
      });
      expect(repeat.calls, isEmpty);
      expect(schedule.calls, isEmpty);
      expect(monitor.starts, isEmpty);

      final Map<String, dynamic> pd = _map(T['pointerDown']);
      expect(_map(pd['noTarget'])['activations'], 0);
      expect(_list(_map(pd['nonElementTarget'])['repeat']), isEmpty);
    });
  });
}

/// Scenario option literals mirroring the truth harness (values only; the
/// onActivate callback is supplied by [build]).
Map<String, dynamic> _scenarioOpts(String name) {
  switch (name) {
    case 'basic':
      return <String, dynamic>{
        'className': 'scrollbar-arrow up',
        'icon': <String>['arrow-up'],
        'bgWidth': 11,
        'bgHeight': 11,
      };
    case 'allEdges':
      return <String, dynamic>{
        'className': 'scrollbar-arrow down',
        'icon': <String>['chevron-down~inverted'],
        'bgWidth': 20,
        'bgHeight': 30,
        'top': 5,
        'left': 6,
        'bottom': 7,
        'right': 8,
      };
    case 'topOnly':
      return <String, dynamic>{
        'className': 'x',
        'icon': <String>['z'],
        'bgWidth': 1,
        'bgHeight': 2,
        'top': 3,
      };
    case 'leftOnly':
      return <String, dynamic>{
        'className': 'x',
        'icon': <String>['z'],
        'bgWidth': 1,
        'bgHeight': 2,
        'left': 4,
      };
    case 'bottomOnly':
      return <String, dynamic>{
        'className': 'x',
        'icon': <String>['z'],
        'bgWidth': 1,
        'bgHeight': 2,
        'bottom': 9,
      };
    case 'rightOnly':
      return <String, dynamic>{
        'className': 'x',
        'icon': <String>['z'],
        'bgWidth': 1,
        'bgHeight': 2,
        'right': 10,
      };
    case 'invalidIcon':
      return <String, dynamic>{
        'className': 'y',
        'icon': <String>['bad id!'],
        'bgWidth': 9,
        'bgHeight': 9,
      };
    default:
      throw StateError('unknown scenario $name');
  }
}

class _PtrEvent {
  _PtrEvent(this.fields, this.onPrevent);
  final Map<String, Object?> fields;
  final void Function() onPrevent;
  Object? get target => fields['target'];
  int get pointerId => (fields['pointerId'] as num).toInt();
  int get buttons => (fields['buttons'] as num).toInt();
  void preventDefault() => onPrevent();
}
