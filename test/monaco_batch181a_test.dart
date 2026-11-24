// Truth-driven tests for batch181a: verifyLinesDiff.ts,
// defaultLinesDiffComputer/utils.ts, dynamicProgrammingDiffing.ts,
// linesSliceCharSequence.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart' show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart' show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart' show OffsetRange;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/algorithms/diffAlgorithm.dart' as da;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/algorithms/dynamicProgrammingDiffing.dart' as dp;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/linesSliceCharSequence.dart' as ls;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/utils.dart' as utils;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/linesDiffComputer.dart' as ldc;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/rangeMapping.dart' as rm;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/verifyLinesDiff.dart' as verify;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch181a_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _Seq implements da.ISequence {
  _Seq(this.values);
  final List<int> values;
  @override
  int getElement(int offset) => values[offset];
  @override
  int get length => values.length;
  @override
  int getBoundaryScore(int length) => 0;
  @override
  bool isStronglyEqual(int offset1, int offset2) =>
      values[offset1] == values[offset2];
}

class _Timeout implements da.ITimeout {
  _Timeout(this.limit);
  int calls = 0;
  final int limit;
  @override
  bool isValid() => ++calls < limit;
}

Map<String, Object?> jdiffResult(da.DiffAlgorithmResult result) => <String, Object?>{
      'diffs': result.diffs
          .map((da.SequenceDiff d) => <String, Object?>{
                'seq1': <String, Object?>{
                  'start': d.seq1Range.start,
                  'endExclusive': d.seq1Range.endExclusive,
                },
                'seq2': <String, Object?>{
                  'start': d.seq2Range.start,
                  'endExclusive': d.seq2Range.endExclusive,
                },
                'text': d.toString(),
              })
          .toList(),
      'hitTimeout': result.hitTimeout,
    };

Map<String, Object?>? jrange(OffsetRange? r) =>
    r == null ? null : <String, Object?>{'start': r.start, 'endExclusive': r.endExclusive};

void main() {
  group('batch181a (truth-driven)', () {
    test('exports', () {
      final Map<String, dynamic> e = truth['exports'] as Map<String, dynamic>;
      expect(e['verifyLinesDiff'], <dynamic>['verifyLinesDiff']);
      expect(e['utils'], <dynamic>['Array2D', 'LineRangeFragment', 'isSpace']);
      expect(e['dynamicProgrammingDiffing'], <dynamic>['DynamicProgrammingDiffing']);
      expect(e['linesSliceCharSequence'], <dynamic>['LinesSliceCharSequence']);
    });

    test('verifyLinesDiff', () {
      final Map<String, dynamic> t = truth['verifyLinesDiff'] as Map<String, dynamic>;
      final List<String> original = <String>['aaa', 'bbb', 'ccc'];
      final List<String> modified = <String>['aaa', 'XX', 'ccc'];

      ldc.LinesDiff makeDiff([bool withInner = true]) => ldc.LinesDiff(
            <rm.DetailedLineRangeMapping>[
              rm.DetailedLineRangeMapping(
                LineRange(2, 3),
                LineRange(2, 3),
                withInner
                    ? <rm.RangeMapping>[
                        rm.RangeMapping(
                            Range(2, 1, 2, 4), Range(2, 1, 2, 3))
                      ]
                    : null,
              ),
            ],
            <ldc.MovedText>[],
            false,
          );

      expect(verify.verifyLinesDiff(makeDiff(), original, modified, false),
          t['valid']);
      expect(
        verify.verifyLinesDiff(
          ldc.LinesDiff(
            <rm.DetailedLineRangeMapping>[
              rm.DetailedLineRangeMapping(
                LineRange(1, 2),
                LineRange(2, 3),
                <rm.RangeMapping>[
                  rm.RangeMapping(Range(1, 1, 1, 4), Range(2, 1, 2, 3)),
                ],
              ),
            ],
            <ldc.MovedText>[],
            false,
          ),
          original,
          modified,
          false,
        ),
        t['invalid'],
      );
      expect(verify.verifyLinesDiff(makeDiff(false), original, modified, false),
          t['unverified']);

      final rm.DetailedLineRangeMapping trimMapping = rm.DetailedLineRangeMapping(
        LineRange(1, 4),
        LineRange(1, 4),
        <rm.RangeMapping>[
          rm.RangeMapping(Range(1, 4, 1, 6), Range(1, 4, 1, 5)),
        ],
      );
      final ldc.LinesDiff trimDiff = ldc.LinesDiff(
          <rm.DetailedLineRangeMapping>[trimMapping], <ldc.MovedText>[], false);
      expect(
        verify.verifyLinesDiff(trimDiff, <String>['aaa  ', 'bbb', 'ccc'],
            <String>['aaa ', 'bbb', 'ccc'], true),
        t['trimValid'],
      );
      expect(
        verify.verifyLinesDiff(trimDiff, <String>['aaa  ', 'bbb', 'ccc'],
            <String>['aaa ', 'ZZZ', 'ccc'], true),
        t['trimInvalid'],
      );
    });

    test('Array2D, isSpace and LineRangeFragment similarity', () {
      final Map<String, dynamic> t = truth['utils'] as Map<String, dynamic>;
      final utils.Array2D<int> a = utils.Array2D<int>(3, 2);
      for (int y = 0; y < 2; y++) {
        for (int x = 0; x < 3; x++) {
          a.set(x, y, x + y * 3 + 1);
        }
      }
      expect(<int>[a.get(0, 0), a.get(2, 0), a.get(0, 1), a.get(2, 1)],
          t['array2D']);
      expect(<bool>[utils.isSpace(32), utils.isSpace(9), utils.isSpace(97)],
          t['isSpace']);
      expect(<int>[
        utils.LineRangeFragment.getKey('a'),
        utils.LineRangeFragment.getKey('b'),
        utils.LineRangeFragment.getKey('a'),
        utils.LineRangeFragment.getKey('\n'),
      ], t['keys']);

      final List<String> lines = <String>['abc', 'abd', 'xyz'];
      final rm.DetailedLineRangeMapping src = rm.DetailedLineRangeMapping(
          LineRange(1, 3), LineRange(1, 3), null);
      final utils.LineRangeFragment f1 =
          utils.LineRangeFragment(LineRange(1, 3), lines, src);
      final utils.LineRangeFragment f2 =
          utils.LineRangeFragment(LineRange(1, 2), lines, src);
      final utils.LineRangeFragment f3 =
          utils.LineRangeFragment(LineRange(3, 4), lines, src);
      expect(<double>[
        f1.computeSimilarity(f1),
        f1.computeSimilarity(f2),
        f1.computeSimilarity(f3),
      ], t['similarity']);
    });

    test('DynamicProgrammingDiffing', () {
      final Map<String, dynamic> t =
          truth['dynamicProgramming'] as Map<String, dynamic>;
      final dp.DynamicProgrammingDiffing algo = dp.DynamicProgrammingDiffing();
      expect(jdiffResult(algo.compute(_Seq(<int>[1, 2, 3]), _Seq(<int>[1, 2, 3]))),
          t['identical']);
      expect(jdiffResult(algo.compute(_Seq(<int>[1, 3]), _Seq(<int>[1, 2, 3]))),
          t['insert']);
      expect(jdiffResult(algo.compute(_Seq(<int>[1, 2, 3]), _Seq(<int>[1, 9, 3]))),
          t['replace']);
      expect(jdiffResult(algo.compute(_Seq(<int>[]), _Seq(<int>[1, 2]))),
          t['empty']);
      final dp.DynamicProgrammingDiffing scored = dp.DynamicProgrammingDiffing(
          equalityScore: (int a, int b) => a == b ? 2 : 0);
      expect(
        jdiffResult(scored.compute(
            _Seq(<int>[1, 2, 3]), _Seq(<int>[1, 2, 4]))),
        t['scored'],
      );
      expect(
        jdiffResult(algo.compute(
            _Seq(<int>[1, 2, 3, 4]), _Seq(<int>[4, 3, 2, 1]), _Timeout(3))),
        t['timeout'],
      );
    });

    test('LinesSliceCharSequence', () {
      final Map<String, dynamic> t = truth['linesSlice'] as Map<String, dynamic>;
      final List<String> lines = <String>['  abc', 'def ghi', '  jkl'];
      final ls.LinesSliceCharSequence s =
          ls.LinesSliceCharSequence(lines, Range(1, 1, 3, 6), true);
      final ls.LinesSliceCharSequence sTrim =
          ls.LinesSliceCharSequence(lines, Range(1, 1, 3, 6), false);
      expect(s.text, t['text']);
      expect(sTrim.text, t['trimText']);
      expect(s.length, t['length']);
      expect(List<int>.generate(12, (int i) => s.getElement(i)), t['elements']);

      final List<int> offsets =
          (t['translateOffset'] as List<dynamic>).map((dynamic o) => o['o'] as int).toList();
      expect(offsets.map((int o) => s.getBoundaryScore(o)).toList(),
          t['boundaryScores']);
      expect(
        offsets
            .map((int o) => <String, Object?>{
                  'o': o,
                  'right': <int>[
                    s.translateOffset(o).lineNumber,
                    s.translateOffset(o).column,
                  ],
                  'left': <int>[
                    s.translateOffset(o, 'left').lineNumber,
                    s.translateOffset(o, 'left').column,
                  ],
                })
            .toList(),
        t['translateOffset'],
      );
      expect(
        <List<int>>[
          <int>[0, 3],
          <int>[3, 6],
          <int>[6, 8],
          <int>[8, s.length],
        ]
            .map((List<int> pair) {
              final Range r = s.translateRange(
                  OffsetRange(pair[0], pair[1]));
              return <int>[
                r.startLineNumber,
                r.startColumn,
                r.endLineNumber,
                r.endColumn,
              ];
            })
            .toList(),
        t['translateRange'],
      );
      expect(<int>[0, 2, 3, 6, 8, s.length]
          .map((int o) => jrange(s.findWordContaining(o)))
          .toList(), t['findWord']);
      expect(<int>[2, 6, 9]
          .map((int o) => jrange(s.findSubWordContaining(o)))
          .toList(), t['findSubWord']);
      expect(s.countLinesIn(OffsetRange(2, 10)), t['countLines']);
      expect(<bool>[s.isStronglyEqual(0, 0), s.isStronglyEqual(0, 1)],
          t['stronglyEqual']);
      expect(<List<int>>[
        <int>[0, 1],
        <int>[2, 7],
        <int>[6, s.length],
      ]
          .map((List<int> pair) =>
              jrange(s.extendToFullLines(OffsetRange(pair[0], pair[1]))))
          .toList(), t['extendToFullLines']);
    });
  });
}
