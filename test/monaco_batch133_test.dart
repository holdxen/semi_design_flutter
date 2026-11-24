// Truth-driven tests for batch133:
// editor/browser/controller/editContext/native/nativeEditContextUtils.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/editor/browser/controller/editContext/native/nativeEditContextUtils.dart'
    as native;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch133_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _section(String key) =>
    _truth[key] as Map<String, Object?>;

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

List<String> _traces(Object? value) => (value as List)
    .map((Object? e) => (e as List).cast<Object?>().first as String)
    .toList();

class _RecordingLogService extends log.NullLogService {
  final List<String> traces = <String>[];

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    traces.add(message);
  }
}

class _CountingElement extends dom.DomElement {
  _CountingElement(super.tagName);

  int focusCalls = 0;

  @override
  void focus() {
    focusCalls++;
    super.focus();
  }
}

class _RecordingTarget extends dom.DomNode {
  final List<Object?> added = <Object?>[];
  final List<Object?> removed = <Object?>[];
  void Function(dom.DomEvent e)? lastListener;

  @override
  void addEventListener(String type, void Function(dom.DomEvent e) handler,
      [Object? options]) {
    lastListener = handler;
    added.add(<Object?>[type, options, identical(handler, lastListener)]);
  }

  @override
  void removeEventListener(String type, void Function(dom.DomEvent e) handler,
      [Object? options]) {
    removed.add(<Object?>[type, identical(handler, lastListener)]);
  }
}

void main() {
  late _RecordingLogService logger;
  late dom.DomDocument doc;
  late _CountingElement element;
  late List<bool> changes;
  late native.FocusTracker tracker;

  setUp(() {
    logger = _RecordingLogService();
    doc = dom.DomDocument();
    element = _CountingElement('div')..ownerDocument = doc;
    doc.body.appendChild(element);
    doc.activeElement = element;
    changes = <bool>[];
    tracker = native.FocusTracker(logger, element, changes.add);
  });

  void expectState(Map<String, Object?> e) {
    expect(tracker.isFocused, e['focused']);
    expect(changes, _list(e['changes']));
    expect(logger.traces, _traces(e['traces']));
  }

  test('initial state', () {
    expectState(_section('initial'));
  });

  test('focus event checks active element', () {
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    expectState(_section('focusActive'));
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    expectState(_section('focusDuplicate'));
  });

  test('pause ignores blur and resume refreshes', () {
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    tracker.pause();
    element.dispatchEvent('blur', dom.DomEvent('blur'));
    expectState(_section('pausedBlur'));
    tracker.resume();
    expectState(_section('resumed'));
  });

  test('blur while not paused', () {
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    element.dispatchEvent('blur', dom.DomEvent('blur'));
    expectState(_section('blur'));
  });

  test('focus calls dom focus then refreshes', () {
    tracker.focus();
    final Map<String, Object?> e = _section('focusMethod');
    expectState(e);
    expect(element.focusCalls, e['focusCalls']);
  });

  test('shadow root shadows owner document', () {
    final dom.DomShadowRoot shadow = dom.DomShadowRoot(dom.DomElement('div'));
    shadow.appendChild(element);
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    expectState(_section('shadowRootInactive'));
    shadow.activeElement = element;
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    expectState(_section('shadowRootActive'));
  });

  test('dispose removes listeners', () {
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    tracker.dispose();
    element.dispatchEvent('blur', dom.DomEvent('blur'));
    element.dispatchEvent('focus', dom.DomEvent('focus'));
    final Map<String, Object?> e = _section('disposed');
    expect(tracker.isFocused, e['focused']);
    expect(changes.length - 1, e['changesAfter']);
  });

  test('editContextAddDisposableListener add/remove', () {
    final Map<String, Object?> e = _section('editContextListener');
    final _RecordingTarget target = _RecordingTarget();
    void listener(dom.DomEvent ev) {}
    final Object disposable = native.editContextAddDisposableListener(
        target, 'textupdate', listener, true);
    final List<Object?> added = _list(e['added']);
    expect(target.added.length, added.length);
    final List<Object?> actualAdded = target.added.first as List<Object?>;
    expect(actualAdded[0], 'textupdate');
    expect(actualAdded[1], true);
    expect(actualAdded[2], true);
    (disposable as dynamic).dispose();
    (disposable as dynamic).dispose();
    expect(target.removed.length, _list(e['removed']).length);
    for (final Object? removed in target.removed) {
      final List<Object?> row = removed as List<Object?>;
      expect(row[0], 'textupdate');
      expect(row[1], true);
    }
  });
}
