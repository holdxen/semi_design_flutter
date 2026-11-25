// batch265: languageFeatures.ts truth replay — declaration-only truth.
// Truth from tool/ts2dart/batch265_truth.json (recursive TS transpile+vm
// for the decorator; source AST for the erased interface shape).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/services/languageFeatures.dart'
    show ILanguageFeaturesService;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch265_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final t = _truth();

  test('b265 decorator id + memoize match truth', () {
    final d = t['decorator'] as Map<String, dynamic>;
    expect(d['exportedName'], 'ILanguageFeaturesService');
    expect(d['serviceId'], 'ILanguageFeaturesService');
    expect(ILanguageFeaturesService.toString(), d['id']);
    expect(
      identical(createDecorator(d['serviceId'] as String),
          ILanguageFeaturesService),
      isTrue,
    );
    expect(d['memoized'], isTrue);
    expect(d['typeOf'], 'function');
  });

  test('b265 TS runtime export is only the decorator', () {
    expect(t['exportKeys'], <String>['ILanguageFeaturesService']);
  });

  test('b265 interface AST shape matches 1:1 Dart declarations', () {
    final iface = t['interface'] as Map<String, dynamic>;
    expect(iface['name'], 'ILanguageFeaturesService');
    expect(iface['memberCount'], 34);

    final registries = iface['registryNames'] as List<dynamic>;
    expect(registries.length, 32);
    expect(registries.first, 'referenceProvider');
    expect(registries.last, 'documentDropEditProvider');
    expect(iface['methods'], <String>['setNotebookTypeResolver']);

    final members = iface['members'] as List<dynamic>;
    final registryTyped = members
        .map((e) => e['type'] as String?)
        .where((type) => type != null && type.startsWith('LanguageFeatureRegistry<'))
        .length;
    expect(registryTyped, 32);

    final src = File(
      'lib/src/monaco/editor/common/services/languageFeatures.dart',
    ).readAsStringSync();
    for (final member in members) {
      final name = member['name'] as String;
      expect(src.contains(name), isTrue, reason: 'missing Dart member: $name');
    }
    expect(src, contains('LanguageFeatureRegistry<Object?> get referenceProvider'));
    expect(src, contains('LanguageFeatureRegistry<Object?> get documentDropEditProvider'));
    expect(src, contains('void setNotebookTypeResolver(NotebookInfoResolver? resolver)'));
  });
}
