// Truth-driven tests for batch180: editor/common/diff/{linesDiffComputer,
// rangeMapping,legacyLinesDiffComputer}.ts.
// Truth source: tool/ts2dart/batch180_truth.json — executes the real transpiled
// TS sources and their real transpiled dependency chain.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/diff/diff.dart' as diff;
import 'package:semi_design_flutter/src/monaco/base/common/diff/diffChange.dart' show DiffChange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/edits/textEdit.dart' show TextEdit, TextReplacement;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart' show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart' show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/text/abstractText.dart' show StringText;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/legacyLinesDiffComputer.dart' as legacy;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/linesDiffComputer.dart' as ldc;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/rangeMapping.dart' as rm;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch180_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, Object?> jlr(LineRange lr) => <String, Object?>{
      'start': lr.startLineNumber,
      'endExclusive': lr.endLineNumberExclusive,
      'isEmpty': lr.isEmpty,
      'length': lr.length,
      'text': lr.toString(),
    };

Map<String, Object?> jr(Range r) => <String, Object?>{
      'startLineNumber': r.startLineNumber,
      'startColumn': r.startColumn,
      'endLineNumber': r.endLineNumber,
      'endColumn': r.endColumn,
      'text': r.toString(),
    };

Map<String, Object?> jmap(rm.LineRangeMapping m) => <String, Object?>{
      'original': jlr(m.original),
      'modified': jlr(m.modified),
      'innerChanges': m is rm.DetailedLineRangeMapping && m.innerChanges != null
          ? m.innerChanges!.map(jmapInner).toList()
          : null,
      'text': m.toString(),
      'changedLineCount': m.changedLineCount,
    };

Map<String, Object?> jmapInner(rm.RangeMapping m) => <String, Object?>{
      'original': null,
      'modified': null,
      'innerChanges': null,
      'text': m.toString(),
    };

Map<String, Object?> jrangeMap(rm.RangeMapping m) => <String, Object?>{
      'originalRange': jr(m.originalRange),
      'modifiedRange': jr(m.modifiedRange),
      'text': m.toString(),
    };

List<Map<String, Object?>> jtextEdit(TextEdit edit) => edit.replacements
    .map((TextReplacement r) => <String, Object?>{
          'range': jr(r.range),
          'newText': r.text,
        })
    .toList();

List<Map<String, Object?>> jmaps(List<rm.LineRangeMapping> mappings) =>
    mappings.map(jmap).toList();

List<Map<String, Object?>> jrangeMaps(List<rm.RangeMapping> mappings) =>
    mappings.map(jrangeMap).toList();

String? capture(void Function() fn) {
  try {
    fn();
    return null;
  } catch (e) {
    return e.toString().replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '');
  }
}

void main() {
  group('editor/common/diff (truth-driven)', () {
    test('exports match the source modules', () {
      expect(truth['missingModules'], isEmpty);
      final Map<String, dynamic> e = truth['exports'] as Map<String, dynamic>;
      expect(e['linesDiffComputer'], <dynamic>['LinesDiff', 'MovedText']);
      expect(e['rangeMapping'], contains('DetailedLineRangeMapping'));
      expect(e['legacyLinesDiffComputer'],
          <dynamic>['DiffComputer', 'LegacyLinesDiffComputer']);
    });

    test('LinesDiff and MovedText.flip', () {
      final Map<String, dynamic> t = truth['linesDiff'] as Map<String, dynamic>;
      final rm.LineRangeMapping m1 =
          rm.LineRangeMapping(LineRange(2, 4), LineRange(3, 5));
      final rm.DetailedLineRangeMapping d1 = rm.DetailedLineRangeMapping(
          LineRange(2, 4),
          LineRange(3, 5),
          <rm.RangeMapping>[
            rm.RangeMapping(Range(2, 1, 2, 3), Range(3, 1, 3, 4)),
          ]);
      final ldc.MovedText moved = ldc.MovedText(m1, <rm.DetailedLineRangeMapping>[d1]);
      final ldc.LinesDiff diff = ldc.LinesDiff(
          <rm.DetailedLineRangeMapping>[d1],
          <ldc.MovedText>[moved],
          true);
      expect(jmap(moved.flip().lineRangeMapping), t['movedFlip']);
      expect(jmaps(moved.flip().changes), t['movedFlipInner']);
      expect(jmaps(diff.changes), t['diffChanges']);
      expect(jmaps(diff.moves.map((ldc.MovedText m) => m.lineRangeMapping).toList()),
          t['diffMovesOriginal']);
      expect(diff.hitTimeout, true);
    });

    test('LineRangeMapping inverse/clip/flip/join/toRangeMapping', () {
      final Map<String, dynamic> t =
          truth['lineRangeMapping'] as Map<String, dynamic>;
      final List<rm.LineRangeMapping> base = <rm.LineRangeMapping>[
        rm.LineRangeMapping(LineRange(1, 3), LineRange(1, 3)),
        rm.LineRangeMapping(LineRange(5, 7), LineRange(6, 8)),
      ];
      expect(
          jmaps(rm.LineRangeMapping.inverse(base, 10, 10)), t['inverse']);
      expect(
          jmaps(rm.LineRangeMapping.clip(
              base, LineRange(2, 6), LineRange(3, 7))),
          t['clip']);
      expect(jmap(base[1].flip()), t['flip']);
      expect(jmap(base[0].join(base[1])), t['join']);
      expect(base[1].changedLineCount, t['changedLineCount']);
      expect(
        jrangeMaps([
          rm.LineRangeMapping(LineRange(2, 4), LineRange(3, 5)).toRangeMapping(),
          rm.LineRangeMapping(LineRange(1, 1), LineRange(1, 3)).toRangeMapping(),
          rm.LineRangeMapping(LineRange(3, 3), LineRange(4, 6)).toRangeMapping(),
        ]),
        t['toRangeMapping'],
      );
      expect(
        capture(() =>
            rm.LineRangeMapping(LineRange(1, 1), LineRange(3, 4)).toRangeMapping()),
        isNotNull,
      );
    });

    test('toRangeMapping2 and range mapping functions', () {
      final Map<String, dynamic> t =
          truth['lineRangeMapping'] as Map<String, dynamic>;
      expect(
        jrangeMaps([
          rm.LineRangeMapping(LineRange(2, 4), LineRange(2, 4)).toRangeMapping2(
              <String>['aaaa', 'bbbb', 'cccc', 'dddd'],
              <String>['aaaa', 'BB', 'cccc', 'dddd']),
          rm.LineRangeMapping(LineRange(2, 3), LineRange(2, 3)).toRangeMapping2(
              <String>['aaaa', 'bbbb', 'cccc'],
              <String>['aaaa', 'BB', 'cccc']),
        ]),
        t['toRangeMapping2'],
      );

      final StringText original = StringText('aaaa\nbbbb\ncccc\ndddd');
      final StringText modified = StringText('aaaa\nBB\ncccc\ndddd');
      final List<rm.RangeMapping> alignments = <rm.RangeMapping>[
        rm.RangeMapping(Range(2, 1, 2, 4), Range(2, 1, 2, 2)),
      ];
      final Map<String, dynamic> f = t['functions'] as Map<String, dynamic>;
      expect(
        jmaps(rm.lineRangeMappingFromRangeMappings(
            alignments, original, modified)),
        f['lineRangeMappingFromRangeMappings'],
      );
      expect(jmap(rm.getLineRangeMapping(alignments[0], original, modified)),
          f['getLineRangeMapping']);
      expect(
        jmaps([
          rm.lineRangeMappingFromChange(const rm.IChange(
              originalStartLineNumber: 1,
              originalEndLineNumber: 2,
              modifiedStartLineNumber: 1,
              modifiedEndLineNumber: 2)),
          rm.lineRangeMappingFromChange(const rm.IChange(
              originalStartLineNumber: 3,
              originalEndLineNumber: 0,
              modifiedStartLineNumber: 4,
              modifiedEndLineNumber: 4)),
          rm.lineRangeMappingFromChange(const rm.IChange(
              originalStartLineNumber: 3,
              originalEndLineNumber: 3,
              modifiedStartLineNumber: 4,
              modifiedEndLineNumber: 0)),
        ]),
        f['fromChange'],
      );
    });

    test('DetailedLineRangeMapping and RangeMapping', () {
      final Map<String, dynamic> dt =
          truth['detailedLineRangeMapping'] as Map<String, dynamic>;
      final StringText modified = StringText('aaaa\nBB\ncccc\ndddd');
      final rm.DetailedLineRangeMapping detailed = rm.DetailedLineRangeMapping(
          LineRange(2, 3),
          LineRange(2, 3),
          <rm.RangeMapping>[
            rm.RangeMapping(Range(2, 1, 2, 3), Range(2, 1, 2, 2)),
          ]);
      expect(jmap(detailed.flip()), dt['flip']);
      expect(jmap(detailed.withInnerChangesFromLineRanges()),
          dt['withInnerChanges']);
      expect(
        jtextEdit(rm.DetailedLineRangeMapping.toTextEdit(
            <rm.DetailedLineRangeMapping>[detailed], modified)),
        dt['toTextEdit'],
      );
      expect(
        jmap(rm.DetailedLineRangeMapping.fromRangeMappings(<rm.RangeMapping>[
          rm.RangeMapping(Range(2, 1, 2, 3), Range(2, 1, 2, 2)),
          rm.RangeMapping(Range(3, 1, 3, 2), Range(3, 1, 3, 4)),
        ])),
        dt['fromRangeMappings'],
      );

      final Map<String, dynamic> t = truth['rangeMapping'] as Map<String, dynamic>;
      final TextEdit edit = TextEdit(<TextReplacement>[
        TextReplacement(Range(1, 2, 1, 4), 'X'),
        TextReplacement(Range(3, 1, 3, 2), 'YY'),
      ]);
      final List<rm.RangeMapping> mappings = rm.RangeMapping.fromEdit(edit);
      expect(jrangeMaps(mappings), t['fromEdit']);
      expect(jrangeMap(rm.RangeMapping.fromEditJoin(edit)), t['fromEditJoin']);
      expect(jrangeMap(rm.RangeMapping.joinStatic(mappings)), t['join']);
      expect(jrangeMap(mappings[0].flip()), t['flip']);
      expect(mappings[0].toString(), t['toString']);
      expect(capture(() => rm.RangeMapping.joinStatic(<rm.RangeMapping>[])),
          isNotNull);
      expect(capture(() => rm.RangeMapping.assertSorted(mappings)), isNull);
      expect(capture(() => rm.RangeMapping.assertSorted(<rm.RangeMapping>[
            mappings[1],
            mappings[0],
          ])),
          isNotNull);
      expect(
        jtextEdit(TextEdit(<TextReplacement>[
          mappings[0].toTextEdit(StringText('aaaa\nbbbb\ncccc')),
        ])),
        t['toTextEdit'],
      );
    });

    test('LegacyLinesDiffComputer scenarios match truth', () {
      final List<dynamic> scenarios = truth['legacy'] as List<dynamic>;
      for (final dynamic s in scenarios) {
        final Map<String, dynamic> scenario = s as Map<String, dynamic>;
        final Map<String, dynamic>? opts =
            scenario['options'] as Map<String, dynamic>?;
        final ldc.ILinesDiffComputerOptions options =
            ldc.ILinesDiffComputerOptions(
          ignoreTrimWhitespace: opts?['ignoreTrimWhitespace'] as bool? ?? false,
          maxComputationTimeMs: 5000,
          computeMoves: false,
        );
        final List<String> original = (scenario['original'] as List<dynamic>)
            .cast<String>();
        final List<String> modified = (scenario['modified'] as List<dynamic>)
            .cast<String>();
        final ldc.LinesDiff diff = legacy.LegacyLinesDiffComputer()
            .computeDiff(original, modified, options);
        expect(jmaps(diff.changes), scenario['changes'],
            reason: 'changes for ${scenario['name']}');
        expect(
          diff.changes
              .map((rm.DetailedLineRangeMapping c) => c.innerChanges == null
                  ? null
                  : jrangeMaps(c.innerChanges!))
              .toList(),
          scenario['charChanges'],
          reason: 'char changes for ${scenario['name']}',
        );
        expect(diff.hitTimeout, scenario['hitTimeout']);
      }
    });

    test('LcsDiff raw change coordinates', () {
      final Map<String, dynamic> t = truth['lcs'] as Map<String, dynamic>;
      final diff.IDiffResult result = diff.LcsDiff(
        legacy.LineSequence(<String>['a', 'b', 'c']),
        legacy.LineSequence(<String>['a', 'X', 'c']),
        (int furthestOriginalIndex, num matchLengthOfLongest) => true,
      ).ComputeDiff(true);
      expect(result.quitEarly, t['quitEarly']);
      expect(
        result.changes
            .map((DiffChange c) => <String, Object?>{
                  'oStart': c.originalStart,
                  'oLength': c.originalLength,
                  'mStart': c.modifiedStart,
                  'mLength': c.modifiedLength,
                })
            .toList(),
        t['changes'],
      );
    });
  });
}
