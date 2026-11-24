// Truth-driven tests for batch181c: defaultLinesDiffComputer.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart' show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart' show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/defaultLinesDiffComputer.dart' as dc;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/linesDiffComputer.dart' as ldc;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/rangeMapping.dart' as rm;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch181c_truth.json').readAsStringSync())
        as Map<String, dynamic>;

ldc.ILinesDiffComputerOptions options([
  Map<String, dynamic> patch = const <String, dynamic>{},
]) =>
    ldc.ILinesDiffComputerOptions(
      ignoreTrimWhitespace: patch['ignoreTrimWhitespace'] as bool? ?? false,
      maxComputationTimeMs: patch['maxComputationTimeMs'] as int? ?? 0,
      computeMoves: patch['computeMoves'] as bool? ?? false,
      extendToSubwords: patch['extendToSubwords'] as bool?,
    );

List<int> jlr(LineRange r) => <int>[
      r.startLineNumber,
      r.endLineNumberExclusive,
    ];

List<int> jrange(Range r) => <int>[
      r.startLineNumber,
      r.startColumn,
      r.endLineNumber,
      r.endColumn,
    ];

Map<String, Object?> jrm(rm.RangeMapping m) => <String, Object?>{
      'original': jrange(m.originalRange),
      'modified': jrange(m.modifiedRange),
    };

Map<String, Object?> jchange(rm.DetailedLineRangeMapping c) =>
    <String, Object?>{
      'original': jlr(c.original),
      'modified': jlr(c.modified),
      'innerChanges': c.innerChanges?.map(jrm).toList(),
    };

Map<String, Object?> jmove(ldc.MovedText m) => <String, Object?>{
      'lineRangeMapping': <String, Object?>{
        'original': jlr(m.lineRangeMapping.original),
        'modified': jlr(m.lineRangeMapping.modified),
      },
      'changes': m.changes.map(jchange).toList(),
    };

Map<String, Object?> jdiff(ldc.LinesDiff d) => <String, Object?>{
      'changes': d.changes.map(jchange).toList(),
      'moves': d.moves.map(jmove).toList(),
      'hitTimeout': d.hitTimeout,
    };

void main() {
  group('batch181c (truth-driven)', () {
    final dc.DefaultLinesDiffComputer computer =
        dc.DefaultLinesDiffComputer();

    test('exports', () {
      expect(truth['exports'], <dynamic>['DefaultLinesDiffComputer']);
    });

    test('special cases', () {
      expect(
        jdiff(computer.computeDiff(
            <String>['same'], <String>['same'], options())),
        truth['identicalOneLine'],
      );
      expect(
        jdiff(computer.computeDiff(
            <String>[''], <String>['x'], options())),
        truth['emptyLine'],
      );
    });

    test('simple line differences', () {
      expect(
        jdiff(computer.computeDiff(<String>['foo', 'bar', 'baz'],
            <String>['foo', 'qux', 'baz'], options())),
        truth['simpleReplace'],
      );
      expect(
        jdiff(computer.computeDiff(<String>['a', 'b', 'c'],
            <String>['a', 'X', 'b', 'c'], options())),
        truth['insertion'],
      );
      expect(
        jdiff(computer.computeDiff(
            <String>['a', 'b', 'c'], <String>['a', 'c'], options())),
        truth['deletion'],
      );
    });

    test('whitespace handling', () {
      expect(
        jdiff(computer.computeDiff(
          <String>['  foo', 'bar'],
          <String>['foo', 'bar'],
          options(<String, dynamic>{'ignoreTrimWhitespace': true}),
        )),
        truth['whitespaceIgnored'],
      );
      expect(
        jdiff(computer.computeDiff(<String>['  foo', 'bar'],
            <String>['foo', 'bar'], options())),
        truth['whitespaceConsidered'],
      );
    });

    test('move detection', () {
      expect(
        jdiff(computer.computeDiff(
          <String>['alpha', 'one', 'two', 'three', 'four', 'omega'],
          <String>['alpha', 'omega', 'one', 'two', 'three', 'four'],
          options(<String, dynamic>{'computeMoves': true}),
        )),
        truth['moves'],
      );
    });

    test('computeDiffWithRawChanges', () {
      final ({ldc.LinesDiff diff, List<rm.RangeMapping> rawChanges}) result =
          computer.computeDiffWithRawChanges(
        <String>['foo', 'bar', 'baz'],
        <String>['foo', 'qux', 'baz'],
        options(),
      );
      expect(
        <String, Object?>{
          'diff': jdiff(result.diff),
          'rawChanges': result.rawChanges.map(jrm).toList(),
        },
        truth['rawChanges'],
      );
    });

    test('extendToSubwords', () {
      expect(
        jdiff(computer.computeDiff(
          <String>['fooBarBaz'],
          <String>['fooQuxBaz'],
          options(<String, dynamic>{'extendToSubwords': true}),
        )),
        truth['extendToSubwords'],
      );
    });

    test('large Myers branch', () {
      final List<String> originalLines = <String>[];
      final List<String> modifiedLines = <String>[];
      for (int i = 0; i < 900; i++) {
        originalLines.add('line $i common');
        modifiedLines.add('line $i common');
      }
      modifiedLines[450] = 'line 450 changed';

      final Map<String, Object?> serialized =
          jdiff(computer.computeDiff(originalLines, modifiedLines, options()));
      final Map<String, dynamic> expected =
          (truth['largeMyersBranch'] as Map<String, dynamic>);
      final List<Object?> changes =
          (serialized['changes'] as List<Object?>?) ?? <Object?>[];
      final List<Object?> moves =
          (serialized['moves'] as List<Object?>?) ?? <Object?>[];
      expect(changes.length, expected['changeCount']);
      expect(moves.length, expected['moveCount']);
      expect(serialized['hitTimeout'], expected['hitTimeout']);
      expect(changes.first, expected['firstChange']);
      expect(changes.last, expected['lastChange']);
    });
  });
}
