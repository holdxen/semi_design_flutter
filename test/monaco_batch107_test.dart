// Data-driven port test for batch107: base/browser/globalPointerMoveMonitor.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/globalPointerMoveMonitor.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show CodeWindow, windowCarrier;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch107_truth.json').readAsStringSync())
        as Map<String, dynamic>;

DomElement _element(CodeWindow win) {
  final DomDocument doc = DomDocument()..defaultView = win;
  return doc.createElement('div');
}

void main() {
  test('exports and capture-based monitoring', () {
    expect(truth['exports'], <dynamic>['GlobalPointerMoveMonitor']);
    final CodeWindow win = CodeWindow(Object(), 21001);
    final DomElement el = _element(win);
    final GlobalPointerMoveMonitor monitor = GlobalPointerMoveMonitor();
    final List<int> moves = <int>[];
    final List<Object?> stops = <Object?>[];

    expect(monitor.isMonitoring(), truth['initial']['monitoring']);
    monitor.startMonitoring(el, 42, 1, (DomEvent e) => moves.add(e.buttons),
        ([Object? e]) => stops.add(e));
    expect(monitor.isMonitoring(), truth['started']['monitoring']);
    expect(el.pointerCaptures.contains(42), isTrue);

    final DomEvent matchEvent = DomEvent(EventType.POINTER_MOVE)
      ..buttons = 1;
    el.dispatchEvent(EventType.POINTER_MOVE, matchEvent);
    expect(moves, truth['matchMove']['moves']);
    expect(matchEvent.defaultPrevented, isTrue);

    final DomEvent changedEvent = DomEvent(EventType.POINTER_MOVE)
      ..buttons = 2;
    el.dispatchEvent(EventType.POINTER_MOVE, changedEvent);
    expect(moves, truth['buttonChange']['moves']);
    expect(changedEvent.defaultPrevented, isFalse);
    expect(monitor.isMonitoring(), truth['buttonChange']['monitoring']);
    expect(stops.length, (truth['buttonChange']['stops'] as List<dynamic>).length);
    expect(stops.single, isNull);
    expect(el.pointerCaptures.contains(42), isFalse);

    monitor.stopMonitoring(true, 'manual');
    expect(stops.length, (truth['afterExtraStop']['stops'] as List<dynamic>).length);
    monitor.dispose();
  });

  test('pointer up stops monitoring without forwarding the event', () {
    final CodeWindow win = CodeWindow(Object(), 21002);
    final DomElement el = _element(win);
    final GlobalPointerMoveMonitor monitor = GlobalPointerMoveMonitor();
    final List<int> moves = <int>[];
    final List<Object?> stops = <Object?>[];
    monitor.startMonitoring(el, 7, 4, (DomEvent e) => moves.add(e.buttons),
        ([Object? e]) => stops.add(e));

    el.dispatchEvent(EventType.POINTER_UP, DomEvent(EventType.POINTER_UP));
    expect(moves, truth['pointerUp']['moves']);
    expect(stops.length, (truth['pointerUp']['stops'] as List<dynamic>).length);
    expect(stops.single, isNull);
    expect(monitor.isMonitoring(), truth['pointerUp']['monitoring']);
    expect(el.pointerCaptures.contains(7), isFalse);

    monitor.dispose();
    expect(stops.length,
        (truth['disposeAfterStop']['stops'] as List<dynamic>).length);
  });

  test('setPointerCapture failure falls back to window listeners', () {
    final CodeWindow win = CodeWindow(Object(), 21003);
    final DomElement el = _element(win)
      ..failSetPointerCapture = true;
    final GlobalPointerMoveMonitor monitor = GlobalPointerMoveMonitor();
    final List<int> moves = <int>[];
    monitor.startMonitoring(el, 9, 1, (DomEvent e) => moves.add(e.buttons),
        ([Object? e]) {});

    expect(el.pointerCaptures, isEmpty);
    expect(monitor.isMonitoring(), truth['captureFallback']['monitoring']);
    windowCarrier(win).document.dispatchEvent(
        EventType.POINTER_MOVE, DomEvent(EventType.POINTER_MOVE)..buttons = 1);
    expect(moves, truth['windowMove']['moves']);

    monitor.dispose();
    expect(monitor.isMonitoring(), truth['fallbackDispose']['monitoring']);
    moves.clear();
    windowCarrier(win).document.dispatchEvent(
        EventType.POINTER_MOVE, DomEvent(EventType.POINTER_MOVE)..buttons = 1);
    expect(moves, isEmpty);
  });

  test('restart unhooks previous capture and listeners', () {
    final CodeWindow win = CodeWindow(Object(), 21004);
    final DomElement el = _element(win);
    final GlobalPointerMoveMonitor monitor = GlobalPointerMoveMonitor();
    monitor.startMonitoring(el, 1, 1, (DomEvent e) {}, ([Object? e]) {});
    monitor.startMonitoring(el, 2, 1, (DomEvent e) {}, ([Object? e]) {});
    expect(el.pointerCaptures, <int>{2});

    monitor.dispose();
    expect(el.pointerCaptures, isEmpty);
    expect(monitor.isMonitoring(), isFalse);
  });
}
