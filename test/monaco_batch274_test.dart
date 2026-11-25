// batch274: resolverService.ts truth replay — declaration + runtime guard.
// Truth from tool/ts2dart/batch274_truth.json (recursive TS transpile+vm).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart'
    show Event, eventNone;
import 'package:semi_design_flutter/src/monaco/editor/common/services/resolverService.dart'
    show ITextEditorModel, ITextModelService, isResolvedTextEditorModel;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch274_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Model implements ITextEditorModel {
  @override
  final Object? textEditorModel;

  _Model(this.textEditorModel);

  @override
  Event<void> get onWillDispose => eventNone;

  @override
  Object? createSnapshot() => null;

  @override
  Object isReadonly() => false;

  @override
  String? getLanguageId() => null;

  @override
  bool isDisposed() => false;

  @override
  Future<void> resolve() async {}

  @override
  bool isResolved() => true;

  @override
  void dispose() {}
}

void main() {
  final t = _truth();

  test('b274 decorator id + memoize match truth', () {
    final d = t['decorator'] as Map<String, dynamic>;
    expect(d['exportedName'], 'ITextModelService');
    expect(d['serviceId'], 'textModelService');
    expect(ITextModelService.toString(), d['id']);
    expect(
      identical(createDecorator(d['serviceId'] as String), ITextModelService),
      isTrue,
    );
    expect(d['memoized'], isTrue);
    expect(d['typeOf'], 'function');
  });

  test('b274 runtime export keys match truth', () {
    expect(t['exportKeys'], <String>[
      'ITextModelService',
      'isResolvedTextEditorModel',
    ]);
  });

  test('b274 interface AST shapes match Dart declarations', () {
    final interfaces = t['interfaces'] as Map<String, dynamic>;
    expect(interfaces.keys.toList(), <String>[
      'ITextModelService',
      'ITextModelContentProvider',
      'ITextEditorModel',
      'IResolvedTextEditorModel',
    ]);
    final src = File(
      'lib/src/monaco/editor/common/services/resolverService.dart',
    ).readAsStringSync();
    for (final entry in interfaces.entries) {
      for (final m in entry.value as List<dynamic>) {
        final name = m['name'] as String;
        // createSnapshot is declared twice in TS via overloads.
        expect(src.contains(name), isTrue,
            reason: '${entry.key} missing member: $name');
      }
    }
    expect(src, contains('Future<IReference<IResolvedTextEditorModel>> createModelReference'));
    expect(src, contains('Event<void> get onWillDispose'));
    expect(src, contains('bool isResolvedTextEditorModel(ITextEditorModel model)'));
  });

  test('b274 isResolvedTextEditorModel truth cases', () {
    for (final raw in t['guard'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      Object? value;
      switch (c['name']) {
        case 'object-model':
          value = <String, Object?>{'marker': 'model'};
          break;
        case 'false-model':
          value = false;
          break;
        default:
          value = null;
      }
      expect(isResolvedTextEditorModel(_Model(value)), c['value'],
          reason: c['name'] as String);
    }
  });
}
