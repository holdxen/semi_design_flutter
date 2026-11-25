import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/gpu/contentSegmenter.dart'
    show
        GraphemeSegmentsProvider,
        IContentSegmenter,
        SegmentData,
        createContentSegmenter;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch423_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: r as Map<String, dynamic>,
  };
}

class _LineData {
  final String content;
  final bool isBasicASCII;
  _LineData(this.content, this.isBasicASCII);
}

class _Options {
  final bool useMonospaceOptimizations;
  _Options(this.useMonospaceOptimizations);
}

/// Rebuild the grapheme segments (UTF-16 indexed) from the truth rows: each
/// row with non-null `data` is a segment start with that index/segment/wordLike.
GraphemeSegmentsProvider _providerFromRows(List<dynamic> rows) {
  return (String content) => rows
      .where((dynamic r) => (r as Map)['data'] != null)
      .map((dynamic r) {
        final Map d = (r as Map)['data'] as Map;
        return SegmentData(
          d['segment'] as String,
          (d['index'] as num).toInt(),
          d['isWordLike'] as bool?,
        );
      })
      .toList();
}

Object? _segDataJson(SegmentData? d) {
  if (d == null) return null;
  return <String, Object?>{
    'segment': d.segment,
    'index': d.index,
    'isWordLike': d.isWordLike,
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  // (label, content, isBasicASCII, useMonospaceOptimizations)
  const List<List<Object>> cases = <List<Object>>[
    <Object>['ascii-mono', 'hello world', true, true],
    <Object>['ascii-no-mono', 'abc', true, false],
    <Object>['emoji', 'a😀b', false, true],
    <Object>['combining', 'e\u0301x', false, true],
    <Object>['cjk', '你a好', false, true],
    <Object>['empty', '', true, true],
  ];

  test('content segmenter truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    for (final List<Object> c in cases) {
      final String label = c[0] as String;
      final String content = c[1] as String;
      final bool basicAscii = c[2] as bool;
      final bool mono = c[3] as bool;
      final List<dynamic> truthRows =
          truth[label]!['rows'] as List<dynamic>;

      final IContentSegmenter seg = createContentSegmenter(
        _LineData(content, basicAscii),
        _Options(mono),
        _providerFromRows(truthRows),
      );

      final List<Object?> rows = <Object?>[];
      // JS iterates UTF-16 code units; Dart `content.length` is also UTF-16.
      for (int i = 0; i <= content.length; i++) {
        final String? at = seg.getSegmentAtIndex(i);
        final Map<String, Object?> row = <String, Object?>{'index': i};
        if (at != null) row['at'] = at;
        // Truth always emits `data` (null when absent); `at` is omitted only
        // when JS returns undefined (JSON.stringify drops undefined).
        row['data'] = _segDataJson(seg.getSegmentData(i));
        rows.add(row);
      }
      actual[label] = <String, Object?>{'rows': rows};
    }

    // Build expected: strip `label` from each truth case (already absent here)
    final Map<String, Object?> expected = <String, Object?>{
      for (final MapEntry<String, dynamic> e in truth.entries)
        e.key: <String, Object?>{'rows': e.value['rows']},
    };

    expect(jsonEncode(actual), jsonEncode(expected));
  });
}
