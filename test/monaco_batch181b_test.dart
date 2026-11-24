// Truth-driven tests for batch181b:
// heuristicSequenceOptimizations.ts, computeMovedLines.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart' show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart' show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart' show OffsetRange;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/algorithms/diffAlgorithm.dart' as da;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/computeMovedLines.dart' as cml;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/heuristicSequenceOptimizations.dart' as h;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/lineSequence.dart' as ls;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/linesSliceCharSequence.dart' as lschar;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/rangeMapping.dart' as rm;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch181b_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _TextSeq implements da.ISequence {
  _TextSeq(this.text) : values = text.codeUnits;

  final String text;
  final List<int> values;

  @override
  int getElement(int offset) => values[offset];

  @override
  int get length => values.length;

  @override
  int getBoundaryScore(int length) =>
      length >= 0 && length <= values.length ? length : 0;

  @override
  bool isStronglyEqual(int offset1, int offset2) =>
      values[offset1] == values[offset2];
}

class _ConstTimeout implements da.ITimeout {
  _ConstTimeout(this.value);

  final bool value;

  @override
  bool isValid() => value;
}

Map<String, Object?> jdiff(da.SequenceDiff d) => <String, Object?>{
      'seq1': <String, Object?>{
        'start': d.seq1Range.start,
        'endExclusive': d.seq1Range.endExclusive,
      },
      'seq2': <String, Object?>{
        'start': d.seq2Range.start,
        'endExclusive': d.seq2Range.endExclusive,
      },
      'text': d.toString(),
    };

List<Object?> jdiffs(List<da.SequenceDiff> diffs) =>
    diffs.map((da.SequenceDiff d) => jdiff(d)).toList();

List<int> hashesFor(List<String> lines) {
  final Map<String, int> map = <String, int>{};
  return lines.map((String line) {
    final String key = line.trim();
    final int? existing = map[key];
    if (existing != null) return existing;
    final int next = map.length;
    map[key] = next;
    return next;
  }).toList();
}

ls.LineSequence lineSeq(List<String> lines) =>
    ls.LineSequence(hashesFor(lines), lines);

lschar.LinesSliceCharSequence sliceSeq(List<String> lines) =>
    lschar.LinesSliceCharSequence(
      lines,
      Range(1, 1, lines.length, lines[lines.length - 1].length),
      true,
    );

da.SequenceDiff D(int a, int b, int c, int d) => da.SequenceDiff(
      OffsetRange(a, b),
      OffsetRange(c, d),
    );

rm.DetailedLineRangeMapping det(int ol, int od, int ml, int md) =>
    rm.DetailedLineRangeMapping(
      LineRange(ol, od),
      LineRange(ml, md),
      null,
    );

List<Object?> jlml(List<rm.LineRangeMapping> moves) => moves
    .map((rm.LineRangeMapping m) => <String, Object?>{
          'original': <int>[
            m.original.startLineNumber,
            m.original.endLineNumberExclusive,
          ],
          'modified': <int>[
            m.modified.startLineNumber,
            m.modified.endLineNumberExclusive,
          ],
        })
    .toList();

void main() {
  group('batch181b (truth-driven)', () {
    test('exports', () {
      final Map<String, dynamic> e = truth['exports'] as Map<String, dynamic>;
      expect(e['heuristic'], <dynamic>[
        'extendDiffsToEntireWordIfAppropriate',
        'optimizeSequenceDiffs',
        'removeShortMatches',
        'removeVeryShortMatchingLinesBetweenDiffs',
        'removeVeryShortMatchingTextBetweenLongDiffs',
      ]);
      expect(e['computeMovedLines'], <dynamic>['computeMovedLines']);
    });

    test('optimizeSequenceDiffs', () {
      final Map<String, dynamic> t =
          truth['optimizeSequenceDiffs'] as Map<String, dynamic>;
      final _TextSeq seq1 = _TextSeq('import { Baz, Bar } from "foo";');
      final _TextSeq seq2 = _TextSeq('import { Baz, Bar, Foo } from "foo";');
      final List<da.SequenceDiff> input = <da.SequenceDiff>[
        D(17, 17, 17, 18),
        D(18, 18, 19, 23),
      ];
      expect(jdiffs(input), t['unchangedInput']);
      expect(
        jdiffs(h.optimizeSequenceDiffs(
            seq1, seq2, List<da.SequenceDiff>.from(input))),
        t['importInsert'],
      );
      expect(
        jdiffs(h.optimizeSequenceDiffs(
            _TextSeq('abc'), _TextSeq('abc'), <da.SequenceDiff>[])),
        t['empty'],
      );
    });

    test('removeShortMatches', () {
      final Map<String, dynamic> t =
          truth['removeShortMatches'] as Map<String, dynamic>;
      final List<da.SequenceDiff> input = <da.SequenceDiff>[
        D(1, 3, 1, 3),
        D(4, 6, 4, 6),
        D(12, 14, 12, 14),
      ];
      expect(jdiffs(input), t['input']);
      expect(
        jdiffs(h.removeShortMatches(
            _TextSeq('x'), _TextSeq('x'), List<da.SequenceDiff>.from(input))),
        t['output'],
      );
      expect(
        jdiffs(h.removeShortMatches(
            _TextSeq('x'), _TextSeq('x'), <da.SequenceDiff>[])),
        t['empty'],
      );
    });

    test('extendDiffsToEntireWordIfAppropriate', () {
      final Map<String, dynamic> t = truth['extendDiffsToEntireWord']
          as Map<String, dynamic>;
      final lschar.LinesSliceCharSequence s1 = sliceSeq(<String>['fooBarBaz']);
      final lschar.LinesSliceCharSequence s2 = sliceSeq(<String>['fooQuxBaz']);
      final List<da.SequenceDiff> input = <da.SequenceDiff>[D(3, 6, 3, 6)];
      expect(jdiffs(input), t['input']);
      expect(
        jdiffs(h.extendDiffsToEntireWordIfAppropriate(
          s1,
          s2,
          List<da.SequenceDiff>.from(input),
          (lschar.LinesSliceCharSequence seq, int idx) =>
              seq.findWordContaining(idx),
        )),
        t['word'],
      );
      expect(
        jdiffs(h.extendDiffsToEntireWordIfAppropriate(
          s1,
          s2,
          List<da.SequenceDiff>.from(input),
          (lschar.LinesSliceCharSequence seq, int idx) =>
              seq.findSubWordContaining(idx),
          true,
        )),
        t['subWordForced'],
      );
      expect(
        jdiffs(h.extendDiffsToEntireWordIfAppropriate(
          s1,
          s2,
          <da.SequenceDiff>[],
          (lschar.LinesSliceCharSequence seq, int idx) =>
              seq.findWordContaining(idx),
        )),
        t['empty'],
      );
    });

    test('removeVeryShortMatchingLinesBetweenDiffs', () {
      final Map<String, dynamic> t = truth['removeVeryShortMatchingLinesBetweenDiffs']
          as Map<String, dynamic>;
      final List<String> lines = <String>[
        'aaa',
        'bbb',
        'ccc',
        'x',
        'ddd',
        'eee'
      ];
      final ls.LineSequence s1 = lineSeq(lines);
      final ls.LineSequence s2 = lineSeq(lines);
      final List<da.SequenceDiff> input = <da.SequenceDiff>[
        D(0, 3, 0, 3),
        D(4, 6, 4, 6),
      ];
      expect(jdiffs(input), t['input']);
      expect(
        jdiffs(h.removeVeryShortMatchingLinesBetweenDiffs(
            s1, s2, List<da.SequenceDiff>.from(input))),
        t['output'],
      );
      expect(
        jdiffs(h.removeVeryShortMatchingLinesBetweenDiffs(
            s1, s2, <da.SequenceDiff>[])),
        t['empty'],
      );
    });

    test('removeVeryShortMatchingTextBetweenLongDiffs', () {
      final Map<String, dynamic> t = truth['removeVeryShortMatchingTextBetweenLongDiffs']
          as Map<String, dynamic>;
      final String longA = 'a' * 140;
      final String longB = 'b' * 140;
      final List<String> lines1 = <String>[longA, 'x', longB];
      final List<String> lines2 = <String>[longA, 'x', longB];
      final lschar.LinesSliceCharSequence s1 = sliceSeq(lines1);
      final lschar.LinesSliceCharSequence s2 = sliceSeq(lines2);
      final List<da.SequenceDiff> input = <da.SequenceDiff>[
        D(0, 141, 0, 141),
        D(142, s1.length, 142, s2.length),
      ];
      expect(jdiffs(input), t['input']);
      expect(
        jdiffs(h.removeVeryShortMatchingTextBetweenLongDiffs(
            s1, s2, List<da.SequenceDiff>.from(input))),
        t['output'],
      );
      expect(
        jdiffs(h.removeVeryShortMatchingTextBetweenLongDiffs(
            s1, s2, <da.SequenceDiff>[])),
        t['empty'],
      );
    });

    test('computeMovedLines', () {
      final Map<String, dynamic> t =
          truth['computeMovedLines'] as Map<String, dynamic>;

      final List<String> simpleOriginal = <String>[
        'alpha',
        'one',
        'two',
        'three',
        'four',
        'omega',
      ];
      final List<String> simpleModified = <String>[
        'alpha',
        'omega',
        'one',
        'two',
        'three',
        'four',
      ];
      expect(
        jlml(cml.computeMovedLines(
          <rm.DetailedLineRangeMapping>[det(2, 6, 1, 1), det(6, 6, 3, 7)],
          simpleOriginal,
          simpleModified,
          hashesFor(simpleOriginal),
          hashesFor(simpleModified),
          da.InfiniteTimeout.instance,
        )),
        t['simpleDeletionInsertion'],
      );

      final List<String> threeOriginal = <String>[
        'head',
        'alpha',
        'bravo',
        'charlie',
        'delta',
        'tail',
      ];
      final List<String> threeModified = <String>[
        'head',
        'zulu',
        'alpha',
        'bravo',
        'charlie',
        'tail',
      ];
      expect(
        jlml(cml.computeMovedLines(
          <rm.DetailedLineRangeMapping>[det(2, 6, 1, 1), det(6, 6, 2, 6)],
          threeOriginal,
          threeModified,
          hashesFor(threeOriginal),
          hashesFor(threeModified),
          da.InfiniteTimeout.instance,
        )),
        t['threeLineHashMove'],
      );

      expect(
        jlml(cml.computeMovedLines(
          <rm.DetailedLineRangeMapping>[det(2, 6, 1, 1), det(6, 6, 3, 7)],
          simpleOriginal,
          simpleModified,
          hashesFor(simpleOriginal),
          hashesFor(simpleModified),
          _ConstTimeout(false),
        )),
        t['timeoutInvalid'],
      );

      final List<String> shortOriginal = <String>['h', 'a', 'b', 'c', 't'];
      final List<String> shortModified = <String>['h', 't', 'a', 'b', 'c'];
      expect(
        jlml(cml.computeMovedLines(
          <rm.DetailedLineRangeMapping>[det(2, 5, 1, 1), det(5, 5, 3, 6)],
          shortOriginal,
          shortModified,
          hashesFor(shortOriginal),
          hashesFor(shortModified),
          da.InfiniteTimeout.instance,
        )),
        t['tooShort'],
      );

      expect(
        jlml(cml.computeMovedLines(
          <rm.DetailedLineRangeMapping>[],
          simpleOriginal,
          simpleModified,
          hashesFor(simpleOriginal),
          hashesFor(simpleModified),
          da.InfiniteTimeout.instance,
        )),
        t['noChanges'],
      );
    });
  });
}
