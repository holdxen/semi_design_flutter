// 1:1 replay of `editor/common/viewLayout/lineDecorations.ts`.
// Truth: `tool/ts2dart/_batch411_truth.cjs` -> `batch411_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/viewLayout/lineDecorations.dart';
import '../lib/src/monaco/editor/common/viewModel/inlineDecorations.dart'
    show InlineDecoration, InlineDecorationType;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch411_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

LineDecoration dec(Map<String, dynamic> m) => LineDecoration(
      m['startColumn'] as int,
      m['endColumn'] as int,
      m['className'] as String,
      m['type'] as int,
    );

Map<String, Object?> decJson(LineDecoration d) => <String, Object?>{
      'startColumn': d.startColumn,
      'endColumn': d.endColumn,
      'className': d.className,
      'type': d.type,
    };

Map<String, Object?> segJson(DecorationSegment s) => <String, Object?>{
      'startOffset': s.startOffset,
      'endOffset': s.endOffset,
      'className': s.className,
      'metadata': s.metadata,
    };

InlineDecoration inlineDec(int sl, int sc, int el, int ec, String cls, int type) =>
    InlineDecoration(Range(sl, sc, el, ec), cls, type);

void main() {
  final Map<String, dynamic> truth = _truth();

  test('line decorations replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // equalsArr
    final LineDecoration a = LineDecoration(1, 3, 'a', InlineDecorationType.Regular);
    final LineDecoration b = LineDecoration(4, 6, 'b', InlineDecorationType.Before);
    actual['equals-arr'] = <String, Object?>{
      'equal': LineDecoration.equalsArr(
        <LineDecoration>[a, b],
        <LineDecoration>[
          LineDecoration(1, 3, 'a', InlineDecorationType.Regular),
          LineDecoration(4, 6, 'b', InlineDecorationType.Before),
        ],
      ),
      'diffType': LineDecoration.equalsArr(
        <LineDecoration>[a, b],
        <LineDecoration>[
          LineDecoration(1, 3, 'a', InlineDecorationType.Regular),
          LineDecoration(4, 6, 'b', InlineDecorationType.After),
        ],
      ),
      'diffLen': LineDecoration.equalsArr(
        <LineDecoration>[a, b],
        <LineDecoration>[LineDecoration(1, 3, 'a', InlineDecorationType.Regular)],
      ),
    };

    // extractWrapped
    final List<LineDecoration> arr = <LineDecoration>[
      LineDecoration(1, 5, 'a', InlineDecorationType.Regular),
      LineDecoration(3, 8, 'b', InlineDecorationType.Before),
      LineDecoration(9, 12, 'c', InlineDecorationType.After),
    ];
    actual['extract-wrapped'] = <String, Object?>{
      'empty': LineDecoration.extractWrapped(<LineDecoration>[], 2, 6).length,
      'wrapped': LineDecoration.extractWrapped(arr, 2, 6)
          .map(decJson)
          .toList(),
    };

    // filter
    final List<InlineDecoration> decs = <InlineDecoration>[
      inlineDec(1, 2, 1, 5, 'onLine', InlineDecorationType.Regular),
      inlineDec(2, 1, 2, 4, 'otherLine', InlineDecorationType.Regular),
      inlineDec(1, 3, 1, 3, 'empty', InlineDecorationType.Regular),
      inlineDec(1, 3, 1, 3, 'emptyWidth', InlineDecorationType.WidthOnly),
      inlineDec(1, 1, 3, 1, 'multi', InlineDecorationType.Before),
    ];
    actual['filter'] = <String, Object?>{
      'line1': LineDecoration.filter(decs, 1, 1, 20).map(decJson).toList(),
      'line2': LineDecoration.filter(decs, 2, 1, 20).map(decJson).toList(),
    };

    // compare
    final List<LineDecoration> cmp = <LineDecoration>[
      LineDecoration(2, 5, 'z', InlineDecorationType.Before),
      LineDecoration(1, 9, 'a', InlineDecorationType.Regular),
      LineDecoration(1, 5, 'a', InlineDecorationType.After),
      LineDecoration(1, 5, 'a', InlineDecorationType.Before),
      LineDecoration(1, 5, 'b', InlineDecorationType.Before),
    ];
    cmp.sort(LineDecoration.compare);
    actual['compare'] = <String, Object?>{
      'sorted': cmp.map(decJson).toList(),
    };

    // normalize overlap
    actual['normalize-overlap'] = <String, Object?>{
      'segments': LineDecorationsNormalizer.normalize(
        'hello world',
        <LineDecoration>[
          LineDecoration(1, 6, 'a', InlineDecorationType.Regular),
          LineDecoration(4, 9, 'b', InlineDecorationType.Regular),
        ],
      ).map(segJson).toList(),
    };

    // normalize pseudo
    actual['normalize-pseudo'] = <String, Object?>{
      'segments': LineDecorationsNormalizer.normalize(
        'abcdef',
        <LineDecoration>[
          LineDecoration(1, 2, 'before', InlineDecorationType.Before),
          LineDecoration(5, 6, 'after', InlineDecorationType.After),
        ],
      ).map(segJson).toList(),
    };

    // normalize surrogate
    actual['normalize-surrogate'] = <String, Object?>{
      'segments': LineDecorationsNormalizer.normalize(
        '😀x',
        <LineDecoration>[
          LineDecoration(2, 3, 'emoji', InlineDecorationType.Regular),
        ],
      ).map(segJson).toList(),
    };

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
