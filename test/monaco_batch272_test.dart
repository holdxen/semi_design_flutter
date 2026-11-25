// batch272: services/model.ts truth replay — declaration-only truth.
// Truth from tool/ts2dart/batch272_truth.json (recursive TS transpile+vm
// for decorator; source AST for interface/alias shapes).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/services/model.dart'
    show IModelService;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch272_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final t = _truth();

  test('b272 decorator id + memoize match truth', () {
    final d = t['decorator'] as Map<String, dynamic>;
    expect(d['exportedName'], 'IModelService');
    expect(d['serviceId'], 'modelService');
    expect(IModelService.toString(), d['id']);
    expect(
      identical(createDecorator(d['serviceId'] as String), IModelService),
      isTrue,
    );
    expect(d['memoized'], isTrue);
    expect(d['typeOf'], 'function');
  });

  test('b272 TS runtime export is only the decorator', () {
    expect(t['exportKeys'], <String>['IModelService']);
  });

  test('b272 interface + alias AST shapes match Dart declarations', () {
    final interfaces = t['interfaces'] as Map<String, dynamic>;
    final members = interfaces['IModelService'] as List<dynamic>;
    final names = members.map((e) => e['name'] as String).toList();
    expect(names, <String>[
      '_serviceBrand',
      'createModel',
      'updateModel',
      'destroyModel',
      'getModels',
      'getCreationOptions',
      'getModel',
      'onModelAdded',
      'onModelRemoved',
      'onModelLanguageChanged',
    ]);

    final alias =
        (t['aliases'] as Map<String, dynamic>)['DocumentTokensProvider']
            as Map<String, dynamic>;
    expect(alias['text'],
        'DocumentSemanticTokensProvider | DocumentRangeSemanticTokensProvider');
    expect(alias['union'], <String>[
      'DocumentSemanticTokensProvider',
      'DocumentRangeSemanticTokensProvider',
    ]);

    final src = File('lib/src/monaco/editor/common/services/model.dart')
        .readAsStringSync();
    for (final name in names) {
      expect(src.contains(name), isTrue, reason: 'missing Dart member: $name');
    }
    expect(src, contains('typedef DocumentTokensProvider = Object?'));
    expect(src, contains('Event<ITextModelForModelService> get onModelAdded'));
    expect(src, contains(
        'Event<({ITextModelForModelService model, String oldLanguageId})>'));
  });
}
