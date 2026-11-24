// batch147 truth tests: codiconsLibrary.ts + codicons.ts ported 1:1.
// Truth captured from real transpiled TS (codiconsUtil.register is REAL),
// so alias resolution + the global font-character map are authoritative.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/codicons.dart' as c;
import 'package:semi_design_flutter/src/monaco/base/common/codiconsLibrary.dart' as lib;
import 'package:semi_design_flutter/src/monaco/base/common/codiconsUtil.dart' as util;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart' show ThemeIcon;

Map<String, dynamic> _loadTruth() {
  final f = File(
      'tool/ts2dart/batch147_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

Map<String, String> _stringMap(Map<String, dynamic> src) =>
    src.map((k, v) => MapEntry(k, v as String));

Map<String, int> _intMap(Map<String, dynamic> src) =>
    src.map((k, v) => MapEntry(k, (v as num).toInt()));

void main() {
  final t = _loadTruth();

  test('font-character map matches truth exactly (all registered ids)', () {
    final expected = _intMap(t['chars'] as Map<String, dynamic>);
    final actual = util.getCodiconFontCharacters();
    // Touch Codicon first to force library+derived registration (Dart is lazy).
    expect(c.Codicon.isNotEmpty, isTrue);
    expect(actual.length, expected.length);
    for (final entry in expected.entries) {
      expect(actual[entry.key], entry.value, reason: 'char ${entry.key}');
    }
  });

  test('codiconsLibrary: 764 keys, id mapping matches truth', () {
    final expected = _stringMap(t['library'] as Map<String, dynamic>);
    expect(lib.codiconsLibrary.length, t['library_count']);
    expect(lib.codiconsLibrary.length, expected.length);
    for (final entry in expected.entries) {
      expect(lib.codiconsLibrary[entry.key]?.id, entry.value,
          reason: 'library ${entry.key}');
      expect(lib.codiconsLibrary[entry.key], isA<ThemeIcon>());
    }
  });

  test('codiconsDerived: 32 keys, id mapping + string-alias resolution', () {
    final expected = _stringMap(t['derived'] as Map<String, dynamic>);
    expect(c.codiconsDerived.length, t['derived_count']);
    expect(c.codiconsDerived.length, expected.length);
    for (final entry in expected.entries) {
      expect(c.codiconsDerived[entry.key]?.id, entry.value,
          reason: 'derived ${entry.key}');
    }
    // 18 string aliases must resolve to the same codepoint as their target.
    expect(util.getCodiconFontCharacters()['dialog-error'],
        util.getCodiconFontCharacters()['error']);
    expect(util.getCodiconFontCharacters()['check'],
        util.getCodiconFontCharacters()['check']);
  });

  test('Codicon: merged 793 keys, id mapping + overlap override', () {
    final expected = _stringMap(t['codicon'] as Map<String, dynamic>);
    expect(c.Codicon.length, t['codicon_count']);
    expect(c.Codicon.length, expected.length);
    for (final entry in expected.entries) {
      expect(c.Codicon[entry.key]?.id, entry.value,
          reason: 'codicon ${entry.key}');
    }
    // 3 overlapping keys: derived's id wins (spread order).
    for (final k in <String>['chatExport', 'chatImport', 'gitFetch']) {
      expect(c.Codicon[k]?.id, c.codiconsDerived[k]?.id,
          reason: 'override $k');
    }
  });

  test('getAllCodicons: count + id sequence match truth', () {
    final all = c.getAllCodicons();
    final expectedIds = (t['all_codicons_ids'] as List)
        .map((e) => e as String)
        .toList();
    expect(all.length, t['all_codicons_count']);
    expect(all.length, expectedIds.length);
    expect(all.map((i) => i.id).toList(), expectedIds);
  });
}
