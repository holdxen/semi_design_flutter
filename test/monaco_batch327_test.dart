// 1:1 replay of `editor/common/model/decorationProvider.ts` (54 lines).
//
// Truth: `tool/ts2dart/_batch327_truth.cjs` -> `batch327_truth.json`.
// The interface is erased; only the two classes and their `toKey` matter.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/model/decorationProvider.dart' as dp;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch327_truth.json').readAsStringSync()));

void main() {
  final truth = _truth();

  test('LineHeightChangingDecoration keeps fields and formats its key', () {
    final expected = truth['lineHeight'] as List;
    for (var i = 0; i < expected.length; i++) {
      final entry = _map(expected[i]);
      final fields = entry['fields'] as List;
      final decoration = dp.LineHeightChangingDecoration(
        fields[0] as int,
        fields[1] as String,
        fields[2] as int,
        fields[3] as num?,
      );
      expect(<Object?>[
        decoration.ownerId,
        decoration.decorationId,
        decoration.lineNumber,
        decoration.lineHeight,
      ], fields, reason: 'fields #$i');
      expect(dp.LineHeightChangingDecoration.toKey(decoration), entry['key'],
          reason: 'key #$i');
    }
  });

  test('LineFontChangingDecoration keeps fields and shares the key format', () {
    final expected = truth['lineFont'] as List;
    for (var i = 0; i < expected.length; i++) {
      final entry = _map(expected[i]);
      final fields = entry['fields'] as List;
      final decoration = dp.LineFontChangingDecoration(
        fields[0] as int,
        fields[1] as String,
        fields[2] as int,
      );
      expect(<Object?>[
        decoration.ownerId,
        decoration.decorationId,
        decoration.lineNumber,
      ], fields, reason: 'fields #$i');
      expect(dp.LineFontChangingDecoration.toKey(decoration), entry['key'],
          reason: 'key #$i');
    }
  });

  test('the two decorations are unrelated types', () {
    final height = dp.LineHeightChangingDecoration(1, 'x', 1, null);
    final font = dp.LineFontChangingDecoration(1, 'x', 1);
    expect(truth['lineFontInstanceOfHeight'], isFalse);
    expect(truth['instancesAreDistinct'], isFalse);
    expect(height, isNot(isA<dp.LineFontChangingDecoration>()));
    expect(font, isA<dp.LineFontChangingDecoration>());
    expect(identical(height, font), isFalse);
  });
}
