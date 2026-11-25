// batch267: languageFeaturesService.ts truth replay.
// Truth from tool/ts2dart/batch267_truth.json (recursive TS transpile+vm,
// real LanguageFeaturesService with shared notebook resolver).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, NotebookInfo;
import 'package:semi_design_flutter/src/monaco/editor/common/services/languageFeaturesService.dart'
    show LanguageFeaturesService;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch267_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Model implements ILanguageFeatureModel {
  @override
  final URI uri;

  _Model(String value) : uri = URI.parse(value);

  @override
  String getLanguageId() => 'python';

  @override
  bool isTooLargeForSyncing() => false;

  @override
  bool get isForSimpleWidget => false;
}

void main() {
  final t = _truth();

  test('b267 TS runtime export is only LanguageFeaturesService', () {
    expect(t['exportKeys'], <String>['LanguageFeaturesService']);
  });

  test('b267 service declares 32 distinct registries', () {
    final names = (t['registryNames'] as List<dynamic>).cast<String>();
    expect(t['registryCount'], 32);
    expect(t['distinctRegistries'], isTrue);
    expect(names.length, 32);
    expect(names.first, 'referenceProvider');
    expect(names.last, 'documentPasteEditProvider');

    final src = File(
      'lib/src/monaco/editor/common/services/languageFeaturesService.dart',
    ).readAsStringSync();
    for (final name in names) {
      expect(src.contains('$name;'), isTrue, reason: 'missing registry: $name');
    }
  });

  test('b267 shared resolver + candidate cache match TS truth', () {
    final service = LanguageFeaturesService();
    final selector = <String, Object?>{'notebookType': 'nb'};
    service.referenceProvider.register(selector, Object());
    service.hoverProvider.register(selector, Object());

    final outputs = <bool>[
      service.referenceProvider.has(_Model('vscode-notebook-cell:///n1#c1')),
      service.hoverProvider.has(_Model('vscode-notebook-cell:///n2#c1')),
    ];

    final calls = <String>[];
    NotebookInfo? resolver(URI uri) {
      final s = uri.toString();
      calls.add(s);
      if (s.startsWith('vscode-notebook-cell:')) {
        return NotebookInfo(URI.parse('vscode-notebook-cell:///notebook'), 'nb');
      }
      return null;
    }
    service.setNotebookTypeResolver(resolver);

    outputs.addAll(<bool>[
      service.referenceProvider.has(_Model('vscode-notebook-cell:///n1#c1')),
      service.referenceProvider.has(_Model('vscode-notebook-cell:///n3#c1')),
      service.hoverProvider.has(_Model('vscode-notebook-cell:///n4#c1')),
    ]);

    service.setNotebookTypeResolver(null);
    outputs.add(
      service.referenceProvider.has(_Model('vscode-notebook-cell:///n5#c1')),
    );

    expect(outputs, t['outputs']);
    expect(calls, t['resolverCalls']);
  });
}
