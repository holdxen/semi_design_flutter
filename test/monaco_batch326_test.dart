// 1:1 replay of
// `editor/common/languages/supports/inplaceReplaceSupport.ts` (99 lines).
//
// Truth: `tool/ts2dart/_batch326_truth.cjs` -> `batch326_truth.json`.
// `doNavigateValueSet` is private in the source, so the truth for it is replayed
// through `navigateValueSet` with a truthy range (same branch, same value).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/languages/supports/inplaceReplaceSupport.dart'
    as inplace;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch326_truth.json').readAsStringSync()));

Map<String, Object?>? _proj(inplace.IInplaceReplaceSupportResult? result) =>
    result == null
        ? null
        : <String, Object?>{
            'range': <int>[
              result.range.startLineNumber,
              result.range.startColumn,
              result.range.endLineNumber,
              result.range.endColumn,
            ],
            'value': result.value,
          };

void main() {
  final truth = _truth();
  final instance = inplace.BasicInplaceReplace.INSTANCE;

  test('INSTANCE is a shared singleton', () {
    expect(truth['instanceIsShared'], isTrue);
    expect(identical(instance, inplace.BasicInplaceReplace.INSTANCE), isTrue);
  });

  test('number and text navigation match the real implementation', () {
    final range = Range(1, 1, 1, 2);
    for (final raw in (truth['navigate'] as List)) {
      final entry = raw as List;
      final String text = entry[0] as String;
      final expected = entry[1] as List;
      final up =
          instance.navigateValueSet(range, text, null, null, true)?.value;
      final down =
          instance.navigateValueSet(range, text, null, null, false)?.value;
      expect(<String?, String?>{'up': up, 'down': down},
          <String?, String?>{'up': expected[0], 'down': expected[1]},
          reason: 'navigate "$text"');
    }
  });

  test('navigateValueSet falls through range/text pairs', () {
    final range1 = Range(1, 1, 1, 5);
    final range2 = Range(2, 2, 2, 6);
    final expected = <String, Map<String, dynamic>?>{
      for (final entry in (truth['navigateValueSet'] as List))
        (entry as List)[0] as String: entry[1] == null
            ? null
            : _map(entry[1]),
    };

    final results = <String, Map<String, Object?>?>{
      'both': _proj(
          instance.navigateValueSet(range1, 'true', range2, 'false', true)),
      'firstHits': _proj(
          instance.navigateValueSet(range1, 'true', range2, 'nope', true)),
      'secondHits': _proj(
          instance.navigateValueSet(range1, 'nope', range2, 'false', true)),
      'neither': _proj(
          instance.navigateValueSet(range1, 'nope', range2, 'nope', true)),
      'emptyFirstText': _proj(
          instance.navigateValueSet(range1, '', range2, 'false', false)),
      'nullText1': _proj(
          instance.navigateValueSet(range1, null, range2, 'false', false)),
      'nullSecondText': _proj(
          instance.navigateValueSet(range1, 'true', range2, null, false)),
      'nullRanges':
          _proj(instance.navigateValueSet(null, 'true', null, null, true)),
      'downZero':
          _proj(instance.navigateValueSet(range1, '0', range2, '0', false)),
    };

    for (final entry in results.entries) {
      expect(entry.value, expected[entry.key], reason: entry.key);
    }
  });
}
