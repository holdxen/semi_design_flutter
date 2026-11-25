// batch271: language.ts truth replay — declaration-only truth.
// Truth from tool/ts2dart/batch271_truth.json (recursive TS transpile+vm
// for decorator; source AST for erased interfaces).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/languages/language.dart'
    show ILanguageService;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch271_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final t = _truth();

  test('b271 decorator id + memoize match truth', () {
    final d = t['decorator'] as Map<String, dynamic>;
    expect(d['exportedName'], 'ILanguageService');
    expect(d['serviceId'], 'languageService');
    expect(ILanguageService.toString(), d['id']);
    expect(
      identical(createDecorator(d['serviceId'] as String), ILanguageService),
      isTrue,
    );
    expect(d['memoized'], isTrue);
    expect(d['typeOf'], 'function');
  });

  test('b271 TS runtime export is only the decorator', () {
    expect(t['exportKeys'], <String>['ILanguageService']);
  });

  test('b271 interface AST shapes match 1:1 Dart declarations', () {
    final interfaces = t['interfaces'] as Map<String, dynamic>;
    expect(interfaces.keys.toList(), <String>[
      'ILanguageExtensionPoint',
      'ILanguageSelection',
      'ILanguageNameIdPair',
      'ILanguageIcon',
      'ILanguageService',
    ]);

    final src = File(
      'lib/src/monaco/editor/common/languages/language.dart',
    ).readAsStringSync();

    final expected = <String, List<String>>{
      'ILanguageExtensionPoint': <String>[
        'id',
        'extensions',
        'filenames',
        'filenamePatterns',
        'firstLine',
        'aliases',
        'mimetypes',
        'configuration',
        'icon',
      ],
      'ILanguageSelection': <String>['languageId', 'onDidChange'],
      'ILanguageNameIdPair': <String>['languageName', 'languageId'],
      'ILanguageIcon': <String>['light', 'dark'],
      'ILanguageService': <String>[
        '_serviceBrand',
        'languageIdCodec',
        'onDidRequestBasicLanguageFeatures',
        'onDidRequestRichLanguageFeatures',
        'onDidChange',
        'registerLanguage',
        'isRegisteredLanguageId',
        'getRegisteredLanguageIds',
        'getSortedRegisteredLanguageNames',
        'getLanguageName',
        'getMimeType',
        'getIcon',
        'getExtensions',
        'getFilenames',
        'getConfigurationFiles',
        'getLanguageIdByLanguageName',
        'getLanguageIdByMimeType',
        'guessLanguageIdByFilepathOrFirstLine',
        'createById',
        'createByMimeType',
        'createByFilepathOrFirstLine',
        'requestBasicLanguageFeatures',
        'requestRichLanguageFeatures',
      ],
    };

    for (final entry in expected.entries) {
      final fromTruth = (interfaces[entry.key] as List)
          .map((e) => e['name'] as String)
          .toList();
      expect(fromTruth, entry.value, reason: entry.key);
      for (final name in entry.value) {
        expect(src.contains(name), isTrue,
            reason: '${entry.key} missing Dart member: $name');
      }
    }

    expect(src, contains('ILanguageIdCodec get languageIdCodec'));
    expect(src, contains('Event<String> get onDidRequestBasicLanguageFeatures'));
    expect(src, contains('Event<void> get onDidChange'));
    expect(src, contains('IDisposable registerLanguage(ILanguageExtensionPoint def)'));
  });
}
