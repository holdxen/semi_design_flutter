// Data-driven verification of batch112 port against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart'
    show DomElement, DomEvent;
import 'package:semi_design_flutter/src/monaco/base/browser/event.dart'
    show DomEmitter;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch112_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _RecElement extends DomElement {
  final List<List<Object?>> calls = <List<Object?>>[];
  void Function(DomEvent)? _fn;
  _RecElement() : super('DIV');

  @override
  void addEventListener(String type, void Function(DomEvent e) handler,
      [Object? options]) {
    calls.add(<Object?>['add', 'el', type, options == true]);
    _fn = handler;
  }

  @override
  void removeEventListener(String type, void Function(DomEvent e) handler,
      [Object? options]) {
    calls.add(<Object?>['remove', 'el', type, options == true]);
  }

  void emit(String type) => _fn?.call(DomEvent(type));
}

List<List<Object?>> _norm(List<dynamic> src) => src
    .map((dynamic e) => (e as List<dynamic>).cast<Object?>())
    .toList();

void main() {
  group('DomEmitter (truth-driven)', () {
    test('lazy DOM listener binding / emission / rebinding', () {
      final el = _RecElement();
      final d = DomEmitter<DomEvent>(el, 'click', true);

      expect(el.calls, _norm(truth['stateAfterCtor'] as List<dynamic>));

      final received = <List<Object?>>[];
      final l1 = d.event((dynamic e) =>
          received.add(<Object?>['l1', (e as DomEvent).type]));
      final l2 = d.event((dynamic e) =>
          received.add(<Object?>['l2', (e as DomEvent).type]));
      expect(el.calls, _norm(truth['stateAfterTwo'] as List<dynamic>));

      el.emit('click');
      el.emit('click');
      expect(received, _norm(truth['received'] as List<dynamic>));

      l1.dispose();
      expect(el.calls, _norm(truth['stateAfterOne'] as List<dynamic>));
      l2.dispose();
      expect(el.calls, _norm(truth['stateAfterZero'] as List<dynamic>));

      d.event((dynamic e) {});
      expect(el.calls, _norm(truth['stateAfterRead'] as List<dynamic>));

      d.dispose();
      expect(el.calls, _norm(truth['finalCalls'] as List<dynamic>));
    });
  });
}
