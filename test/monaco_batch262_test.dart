// batch262: documentDiffProvider.ts truth replay.
// Truth from tool/ts2dart/batch262_truth.json (recursive TS transpile+vm runtime
// for nullDocumentDiff; source AST for erased interfaces/type alias).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/diff/documentDiffProvider.dart'
    show
        DiffFallbackReason,
        IDocumentDiff,
        IDocumentDiffProviderOptions,
        nullDocumentDiff;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch262_truth.json').readAsStringSync())
    as Map<String, dynamic>;

List<String> _memberNames(Map<String, dynamic> interfaces, String name) =>
    (interfaces[name] as List)
        .map((e) => e['name'] as String)
        .toList(growable: false);

List<String> _memberTypes(Map<String, dynamic> interfaces, String name) =>
    (interfaces[name] as List)
        .map((e) => e['type'] as String)
        .toList(growable: false);

void main() {
  final t = _truth();

  test('b262 TS runtime export is only nullDocumentDiff', () {
    expect(t['exportKeys'], <String>['nullDocumentDiff']);
    expect(nullDocumentDiff, isA<IDocumentDiff>());
  });

  test('b262 nullDocumentDiff values match frozen TS truth', () {
    final d = t['nullDocumentDiff'] as Map<String, dynamic>;
    expect(d['keys'], <String>['changes', 'identical', 'moves', 'quitEarly']);
    expect(d['identical'], isTrue);
    expect(d['quitEarly'], isFalse);
    expect(d['changes'], isEmpty);
    expect(d['moves'], isEmpty);
    expect(d['hasValidity'], isFalse);
    expect(d['hasFallback'], isFalse);
    expect(d['validity'], isNull);
    expect(d['fallback'], isNull);
    expect(d['isFrozen'], isTrue);
    expect(d['changesFrozen'], isTrue);
    expect(d['movesFrozen'], isTrue);

    expect(nullDocumentDiff.identical, d['identical']);
    expect(nullDocumentDiff.quitEarly, d['quitEarly']);
    expect(nullDocumentDiff.changes, isEmpty);
    expect(nullDocumentDiff.moves, isEmpty);
    expect(nullDocumentDiff.validity, isNull);
    expect(nullDocumentDiff.fallback, isNull);
  });

  test('b262 nullDocumentDiff is immutable like Object.freeze', () {
    // Dart's unmodifiable const list may throw TypeError on a wrong element
    // type before UnsupportedError; either way mutation is rejected.
    expect(() => (nullDocumentDiff.changes as List<dynamic>).add(null),
        throwsA(isA<Error>()));
    expect(() => (nullDocumentDiff.moves as List<dynamic>).add(null),
        throwsA(isA<Error>()));
    expect(() {
      (nullDocumentDiff as dynamic).identical = false;
    }, throwsA(isA<NoSuchMethodError>()));
  });

  test('b262 interface AST shapes match 1:1 Dart declarations', () {
    final interfaces = t['interfaces'] as Map<String, dynamic>;
    expect(_memberNames(interfaces, 'IDocumentDiffProvider'), <String>[
      'computeDiff',
      'onDidChange',
    ]);
    expect(_memberTypes(interfaces, 'IDocumentDiffProvider'), <String>[
      'Promise<IDocumentDiff>',
      'Event<void>',
    ]);
    expect(_memberNames(interfaces, 'IDocumentDiffProviderOptions'), <String>[
      'ignoreTrimWhitespace',
      'maxComputationTimeMs',
      'computeMoves',
      'extendToSubwords',
    ]);
    expect(_memberTypes(interfaces, 'IDocumentDiffProviderOptions'), <String>[
      'boolean',
      'number',
      'boolean',
      'boolean',
    ]);
    expect(_memberNames(interfaces, 'IDocumentDiff'), <String>[
      'identical',
      'quitEarly',
      'changes',
      'moves',
      'validity',
      'fallback',
    ]);
    expect(_memberTypes(interfaces, 'IDocumentDiff'), <String>[
      'boolean',
      'boolean',
      'readonly DetailedLineRangeMapping[]',
      'readonly MovedText[]',
      'LinesDiffValidity',
      'DiffFallbackReason',
    ]);

    final src = File(
      'lib/src/monaco/editor/common/diff/documentDiffProvider.dart',
    ).readAsStringSync();
    for (final name in <String>[
      'computeDiff',
      'onDidChange',
      'ignoreTrimWhitespace',
      'maxComputationTimeMs',
      'computeMoves',
      'extendToSubwords',
      'identical',
      'quitEarly',
      'changes',
      'moves',
      'validity',
      'fallback',
    ]) {
      expect(src.contains(name), isTrue, reason: 'missing Dart member: $name');
    }
    expect(src, contains('Future<IDocumentDiff> computeDiff'));
    expect(src, contains('List<DetailedLineRangeMapping> get changes'));
    expect(src, contains('List<MovedText> get moves'));
    expect(src, contains('LinesDiffValidity? get validity'));
  });

  test('b262 DiffFallbackReason string union + options carrier', () {
    final alias =
        (t['typeAliases'] as Map<String, dynamic>)['DiffFallbackReason']
            as Map<String, dynamic>;
    expect(alias['text'], "'error' | 'invalid'");
    expect(alias['literals'], <String>['error', 'invalid']);

    final DiffFallbackReason error = 'error';
    final DiffFallbackReason invalid = 'invalid';
    expect(error, 'error');
    expect(invalid, 'invalid');

    final options = IDocumentDiffProviderOptions(
      ignoreTrimWhitespace: true,
      maxComputationTimeMs: 1000,
      computeMoves: false,
      extendToSubwords: true,
    );
    expect(options.ignoreTrimWhitespace, isTrue);
    expect(options.maxComputationTimeMs, 1000);
    expect(options.computeMoves, isFalse);
    expect(options.extendToSubwords, isTrue);
  });
}
