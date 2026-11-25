// 1:1 replay of
//   `editor/common/core/text/getPositionOffsetTransformerFromTextModel.ts` (26 lines),
//   `editor/contrib/inlineCompletions/browser/model/singleTextEditHelpers.ts` (34 lines),
//   `editor/contrib/inlineCompletions/browser/model/inlineCompletionIsVisible.ts` (50 lines).
// Truth: `tool/ts2dart/_batch331_truth.cjs` -> `batch331_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/edits/textEdit.dart'
    show TextReplacement;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import '../lib/src/monaco/editor/common/core/text/getPositionOffsetTransformerFromTextModel.dart'
    show
        getPositionOffsetTransformerFromTextModel,
        ITextModelForPositionOffsetTransformer;
import '../lib/src/monaco/editor/common/core/text/positionToOffset.dart'
    show ensureDependenciesAreSet;
import '../lib/src/monaco/editor/common/model.dart' show EndOfLinePreference;
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/inlineCompletionIsVisible.dart'
    as visible;
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/singleTextEditHelpers.dart'
    as helpers;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
  jsonDecode(File('tool/ts2dart/batch331_truth.json').readAsStringSync()),
);

const String _text =
    'function test() {\r\n    const abc = 1;\r\n    return abc;\r\n}\r\n';

class _FakeModel
    implements
        visible.ITextModelForInlineCompletionIsVisible,
        ITextModelForPositionOffsetTransformer {
  _FakeModel(this.value) {
    _starts = <int>[0];
    for (int i = 0; i < value.length; i++) {
      if (value[i] == '\n') _starts.add(i + 1);
    }
  }

  final String value;
  late final List<int> _starts;

  int getLineCount() => _starts.length;

  String getLineContent(int lineNumber) {
    final int s = _starts[lineNumber - 1];
    int e = lineNumber < _starts.length
        ? _starts[lineNumber] - 1
        : value.length;
    if (e > s && value[e - 1] == '\r') e--;
    return value.substring(s, e);
  }

  @override
  int getOffsetAt(Position position) =>
      _starts[position.lineNumber - 1] + position.column - 1;

  @override
  Position getPositionAt(int offset) {
    int lo = 0;
    int hi = _starts.length - 1;
    while (lo < hi) {
      final int mid = (lo + hi + 1) >> 1;
      if (_starts[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return Position(lo + 1, offset - _starts[lo] + 1);
  }

  @override
  String getValueInRange(Range range, [int? endOfLinePreference]) {
    final int s = getOffsetAt(range.getStartPosition());
    final int e = getOffsetAt(range.getEndPosition());
    String v = value.substring(s, e);
    if (endOfLinePreference == EndOfLinePreference.LF) {
      v = v.replaceAll('\r\n', '\n');
    }
    return v;
  }

  @override
  int getLineIndentColumn(int lineNumber) {
    final String c = getLineContent(lineNumber);
    int i = 0;
    while (i < c.length && (c[i] == ' ' || c[i] == '\t')) {
      i++;
    }
    return i + 1;
  }
}

TextReplacement _edit(int a, int b, int c, int d, String text) =>
    TextReplacement(Range(a, b, c, d), text);

List<int> _range(Range r) => <int>[
  r.startLineNumber,
  r.startColumn,
  r.endLineNumber,
  r.endColumn,
];

Map<String, Object?> _rep(TextReplacement e) => <String, Object?>{
  'range': _range(e.range),
  'text': e.text,
  'empty': e.isEmpty,
};

void main() {
  final truth = _truth();
  final model = _FakeModel(_text);

  final baseEdit = _edit(2, 11, 2, 14, 'abcdef');
  final crlfEdit = _edit(2, 11, 2, 14, 'abcdef\r\n');
  final truncatingEdit = _edit(2, 11, 2, 14, 'abcdef');
  final insertEdit = _edit(3, 1, 3, 1, '    ');
  final emptyEdit = _edit(2, 11, 2, 14, 'abc');
  final indentEdit = _edit(2, 1, 2, 4, '     const');
  final divergentEdit = _edit(2, 11, 2, 14, 'abZZZ');
  final midTextEdit = _edit(3, 12, 3, 15, 'abcXYZ');
  final reversedEdit = _edit(3, 15, 3, 12, 'abcXYZ');

  test('fake model measures the truth text', () {
    expect(
      <int>[1, 2, 3, 4, 5].map(model.getLineIndentColumn).toList(),
      truth['lineIndentColumns'],
    );
    expect(
      <int>[1, 2, 3, 4, 5].map(model.getLineContent).toList(),
      truth['lineContents'],
    );
  });

  test(
    'singleTextRemoveCommonPrefix mirrors prefix/CRLF/intersection rules',
    () {
      final basic = _map(truth['commonPrefixBasic']);
      expect(
        _rep(helpers.singleTextRemoveCommonPrefix(baseEdit, model)),
        _map(basic['value']),
      );

      final crlf = _map(truth['commonPrefixCrlf']);
      expect(
        _rep(helpers.singleTextRemoveCommonPrefix(crlfEdit, model)),
        _map(crlf['value']),
      );

      final truncated = _map(truth['commonPrefixTruncated']);
      expect(
        _rep(
          helpers.singleTextRemoveCommonPrefix(
            truncatingEdit,
            model,
            Range(2, 11, 2, 12),
          ),
        ),
        _map(truncated['value']),
      );

      final noIntersection = _map(truth['commonPrefixNoIntersection']);
      expect(
        _rep(
          helpers.singleTextRemoveCommonPrefix(
            truncatingEdit,
            model,
            Range(3, 1, 3, 2),
          ),
        ),
        _map(noIntersection['value']),
      );

      final insertIndent = _map(truth['commonPrefixInsertOfIndent']);
      expect(
        _rep(helpers.singleTextRemoveCommonPrefix(insertEdit, model)),
        _map(insertIndent['value']),
      );

      final empty = _map(truth['commonPrefixEmpty']);
      expect(
        _rep(helpers.singleTextRemoveCommonPrefix(emptyEdit, model)),
        _map(empty['value']),
      );
    },
  );

  Object? valueOf(String key) => _map(truth[key])['value'];

  test('singleTextEditAugments mirrors text and range containment', () {
    expect(
      helpers.singleTextEditAugments(
        TextReplacement(Range(2, 11, 2, 16), 'abcdef'),
        TextReplacement(Range(2, 11, 2, 14), 'abc'),
      ),
      valueOf('augmentsTrue'),
    );
    expect(
      helpers.singleTextEditAugments(
        TextReplacement(Range(2, 11, 2, 16), 'xyz'),
        TextReplacement(Range(2, 11, 2, 14), 'abc'),
      ),
      valueOf('augmentsTextFalse'),
    );
    expect(
      helpers.singleTextEditAugments(
        TextReplacement(Range(2, 11, 2, 16), 'abcdef'),
        TextReplacement(Range(2, 10, 2, 14), 'abc'),
      ),
      valueOf('augmentsStartFalse'),
    );
    expect(
      helpers.singleTextEditAugments(
        TextReplacement(Range(2, 11, 2, 14), 'ab'),
        TextReplacement(Range(2, 11, 2, 14), 'abc'),
      ),
      valueOf('augmentsBaseLonger'),
    );
  });

  test(
    'inlineCompletionIsVisible mirrors every early return and trim branch',
    () {
      expect(
        visible.inlineCompletionIsVisible(
          baseEdit,
          Range(2, 11, 2, 14),
          model,
          Position(2, 14),
        ),
        valueOf('visibleBasic'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          emptyEdit,
          Range(2, 11, 2, 14),
          model,
          Position(2, 14),
        ),
        valueOf('visibleEmptyAfterPrefix'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          baseEdit,
          Range(2, 11, 2, 14),
          model,
          Position(3, 5),
        ),
        valueOf('visibleWrongCursorLine'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          baseEdit,
          Range(2, 10, 2, 14),
          model,
          Position(2, 14),
        ),
        valueOf('visibleOriginalRangeMismatch'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          indentEdit,
          Range(2, 1, 2, 4),
          model,
          Position(2, 4),
        ),
        valueOf('visibleIndentTrim'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          divergentEdit,
          Range(2, 11, 2, 14),
          model,
          Position(2, 14),
        ),
        valueOf('visibleDivergentPrefix'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          midTextEdit,
          Range(3, 12, 3, 15),
          model,
          Position(3, 16),
        ),
        valueOf('visibleMidText'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          divergentEdit,
          null,
          model,
          Position(2, 14),
        ),
        valueOf('visibleNoOriginalRange'),
      );
      expect(
        visible.inlineCompletionIsVisible(
          reversedEdit,
          Range(3, 12, 3, 15),
          model,
          Position(3, 14),
        ),
        valueOf('visibleReversedRange'),
      );
    },
  );

  test('text-model transformer forwards offsets and positions', () {
    ensureDependenciesAreSet();
    final transformer = getPositionOffsetTransformerFromTextModel(model);

    final positions = <List<int>>[
      <int>[1, 1],
      <int>[1, 5],
      <int>[2, 1],
      <int>[2, 5],
      <int>[2, 19],
      <int>[3, 12],
      <int>[4, 1],
      <int>[5, 1],
    ];
    expect(
      positions
          .map((p) => transformer.getOffset(Position(p[0], p[1])))
          .toList(),
      truth['transformerOffsets'],
    );

    final List<dynamic> offsets = truth['transformerPositions'] as List;
    final List<List<int>> actualPositions =
        <int>[0, 4, 17, 18, 19, 37, 41, _text.length].map((int o) {
          final Position p = transformer.getPosition(o);
          return <int>[p.lineNumber, p.column];
        }).toList();
    expect(
      actualPositions,
      offsets.map((dynamic p) => (p as List).cast<int>().toList()).toList(),
    );

    final offsetRange = transformer.getOffsetRange(Range(2, 5, 3, 7));
    expect(<int>[
      offsetRange.start,
      offsetRange.endExclusive,
    ], truth['transformerOffsetRange']);

    final range = transformer.getRange(OffsetRange(4, 37));
    expect(_range(range), truth['transformerRange']);

    expect(
      <int>[
        0,
        17,
        18,
        37,
        41,
        _text.length,
      ].map((o) => transformer.getOffset(transformer.getPosition(o))).toList(),
      truth['transformerRoundTrip'],
    );
  });
}
