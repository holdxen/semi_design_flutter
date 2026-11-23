// Data-driven verification of batch111 port against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart'
    show DomDocument, DomElement, DomEvent, windowCarrier;
import 'package:semi_design_flutter/src/monaco/base/browser/pixelRatio.dart'
    show DomMediaQueryList, matchMediaProvider;
import 'package:semi_design_flutter/src/monaco/base/browser/touch.dart' as touch;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show mainWindow;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch111_truth.json').readAsStringSync())
        as Map<String, dynamic>;

/// Recording element: overrides dispatchEvent to capture gesture payloads.
class _RecElement extends DomElement {
  final String id;
  final List<Map<String, Object?>> records;
  _RecElement(this.id, this.records) : super(id.toUpperCase());

  @override
  void dispatchEvent(String type, DomEvent event) {
    final Object? g = event.gestureEvent;
    records.add(<String, Object?>{
      'type': type,
      'tapCount': g == null ? 0 : (g as dynamic).tapCount,
      'tx': g == null ? 0 : (g as dynamic).translationX,
      'ty': g == null ? 0 : (g as dynamic).translationY,
      'pageX': g == null ? 0 : (g as dynamic).pageX,
      'pageY': g == null ? 0 : (g as dynamic).pageY,
      'target': id,
    });
  }
}

touch.DomTouchEvent _te(List<touch.DomTouch> touches) =>
    touch.DomTouchEvent(touch.DomTouchList(touches), touch.DomTouchList(touches));

touch.DomTouch _t(int id, num x, num y, Object target) =>
    touch.DomTouch(id, target, x, y);


/// JS truth omits undefined fields (JSON.stringify), Dart records default 0.
/// Project actual records onto the exact key set of each expected record.
List<Map<String, Object?>> _normalize(
  List<dynamic> expected,
  List<Map<String, Object?>> actual,
) {
  final List<Map<String, Object?>> out = <Map<String, Object?>>[];
  for (int i = 0; i < expected.length; i++) {
    final Map<String, dynamic> e = expected[i] as Map<String, dynamic>;
    final Map<String, Object?> a = Map<String, Object?>.from(actual[i]);
    out.add(Map<String, Object?>.fromEntries(
      e.keys.map((String k) => MapEntry<String, Object?>(k, a[k])),
    ));
  }
  return out;
}

void main() {
  group('Gesture (truth-driven)', () {
    test('event types and device detection', () {
      expect(touch.EventType.Tap, truth['eventType']['Tap']);
      expect(touch.EventType.Change, truth['eventType']['Change']);
      expect(touch.EventType.Start, truth['eventType']['Start']);
      expect(touch.EventType.End, truth['eventType']['End']);
      expect(touch.EventType.Contextmenu, truth['eventType']['Contextmenu']);

      // Inject device providers before first memoized access.
      touch.touchDeviceProvider = () => true;
      matchMediaProvider = (_, __) {
        final DomMediaQueryList mq = DomMediaQueryList('(hover: hover)');
        mq.matches = false;
        return mq;
      };
      expect(touch.Gesture.isTouchDevice(), truth['isTouchDevice']);
      expect(touch.Gesture.isHoverDevice(), truth['isHoverDevice']);
    });

    test('full touch lifecycle: tap / hold / move / inertia', () {
      int now = 1000;
      touch.touchNowProvider = () => now;
      touch.gestureEventFactory = (type) => touch.GestureEvent(type);

      final List<Map<String, Object?>> records = <Map<String, Object?>>[];
      final _RecElement root = _RecElement('root', records);
      final _RecElement child = _RecElement('child', records);
      root.appendChild(child);

      final _RecElement ignore = _RecElement('ignore', records);
      final ignoreDisp = touch.Gesture.ignoreTarget(ignore);
      final addDisp = touch.Gesture.addTarget(root);

      final DomDocument doc = windowCarrier(mainWindow).document;

      // --- tap sequence ---
      records.clear();
      doc.dispatchEvent('touchstart', _asDom(_te([_t(1, 10, 20, child)])));
      expect(_normalize(truth['afterStart'] as List<dynamic>, records),
          truth['afterStart'] as List<dynamic>);

      now = 1050;
      doc.dispatchEvent('touchend', _asDom(_te([_t(1, 10, 20, child)])));
      expect(_normalize(truth['afterTap'] as List<dynamic>, records),
          truth['afterTap'] as List<dynamic>);
      expect((truth['tapCounts'] as List<dynamic>).first, 1);

      // --- long hold => contextmenu ---
      records.clear();
      now = 2000;
      doc.dispatchEvent('touchstart', _asDom(_te([_t(2, 30, 40, child)])));
      now = 2800;
      doc.dispatchEvent('touchend', _asDom(_te([_t(2, 30, 40, child)])));
      expect(_normalize(truth['afterHold'] as List<dynamic>, records),
          truth['afterHold'] as List<dynamic>);

      // --- move => change events ---
      records.clear();
      now = 3000;
      doc.dispatchEvent('touchstart', _asDom(_te([_t(3, 50, 60, child)])));
      now = 3010;
      doc.dispatchEvent('touchmove', _asDom(_te([_t(3, 55, 68, child)])));
      expect(_normalize(truth['afterMove'] as List<dynamic>, records),
          truth['afterMove'] as List<dynamic>);

      // touchend triggers inertia scheduling; flush rAF queue.
      now = 3020;
      doc.dispatchEvent('touchend', _asDom(_te([_t(3, 55, 68, child)])));
      final carrier = windowCarrier(mainWindow);
      for (int i = 0; i < 20 && carrier.rafCount > 0; i++) {
        now += 16;
        carrier.flushAnimationFrame();
      }
      expect(records.map((r) => r['type']).toList(),
          truth['afterInertiaTypes'] as List<dynamic>);

      addDisp.dispose();
      ignoreDisp.dispose();
    });
  });
}

DomEvent _asDom(touch.DomTouchEvent e) {
  final DomEvent ev = DomEvent('touch');
  ev.touchEvent = e;
  return ev;
}
