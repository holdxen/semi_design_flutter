// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/defaultLinesDiffComputer.ts
// 严格 1:1 翻译；禁止自作主张改写算法语义。

import 'dart:math' as math;

import '../../../../base/common/arrays.dart' show equals;
import '../../../../base/common/assert.dart' show assertFn;
import '../../core/position.dart' show Position;
import '../../core/range.dart' show Range;
import '../../core/ranges/lineRange.dart' show LineRange;
import '../../core/ranges/offsetRange.dart' show OffsetRange;
import '../../core/text/abstractText.dart' show ArrayText;
import '../linesDiffComputer.dart'
    show
        ILinesDiffComputer,
        ILinesDiffComputerOptions,
        LinesDiff,
        MovedText;
import '../rangeMapping.dart'
    show
      DetailedLineRangeMapping,
      LineRangeMapping,
      RangeMapping,
      lineRangeMappingFromRangeMappings;
import 'algorithms/diffAlgorithm.dart'
    show
      DateTimeout,
      DiffAlgorithmResult,
      InfiniteTimeout,
      ITimeout,
      SequenceDiff;
import 'algorithms/dynamicProgrammingDiffing.dart'
    show DynamicProgrammingDiffing;
import 'algorithms/myersDiffAlgorithm.dart' show MyersDiffAlgorithm;
import 'computeMovedLines.dart' show computeMovedLines;
import 'heuristicSequenceOptimizations.dart'
    show
      extendDiffsToEntireWordIfAppropriate,
      optimizeSequenceDiffs,
      removeShortMatches,
      removeVeryShortMatchingLinesBetweenDiffs,
      removeVeryShortMatchingTextBetweenLongDiffs;
import 'lineSequence.dart' show LineSequence;
import 'linesSliceCharSequence.dart' show LinesSliceCharSequence;

// Mirrors the source's `const check = false` debug switch without letting
// the analyzer treat the guarded branches as statically dead code.
bool _defaultLinesDiffComputerCheck = false;

class _RefineDiffResult {
  final List<RangeMapping> mappings;
  final bool hitTimeout;

  _RefineDiffResult(this.mappings, this.hitTimeout);
}

/// 1:1: `export class DefaultLinesDiffComputer implements ILinesDiffComputer`
class DefaultLinesDiffComputer implements ILinesDiffComputer {
  final DynamicProgrammingDiffing _dynamicProgrammingDiffing =
      DynamicProgrammingDiffing();
  final MyersDiffAlgorithm _myersDiffingAlgorithm = MyersDiffAlgorithm();

  @override
  LinesDiff computeDiff(
    List<String> originalLines,
    List<String> modifiedLines,
    ILinesDiffComputerOptions options,
  ) {
    return _computeDiff(originalLines, modifiedLines, options);
  }

  /// Also returns unweighted character changes, reusing the character diff for large slices.
  ({LinesDiff diff, List<RangeMapping> rawChanges}) computeDiffWithRawChanges(
    List<String> originalLines,
    List<String> modifiedLines,
    ILinesDiffComputerOptions options,
  ) {
    final List<RangeMapping> rawChanges = <RangeMapping>[];
    final LinesDiff diff =
        _computeDiff(originalLines, modifiedLines, options, rawChanges);
    return (diff: diff, rawChanges: rawChanges);
  }

  LinesDiff _computeDiff(
    List<String> originalLines,
    List<String> modifiedLines,
    ILinesDiffComputerOptions options, [
    List<RangeMapping>? rawChanges,
  ]) {
    if (originalLines.length <= 1 &&
        equals<String>(
            originalLines, modifiedLines, (String a, String b) => a == b)) {
      return LinesDiff(<DetailedLineRangeMapping>[], <MovedText>[], false);
    }

    if ((originalLines.length == 1 && originalLines[0].isEmpty) ||
        (modifiedLines.length == 1 && modifiedLines[0].isEmpty)) {
      final RangeMapping rangeMapping = RangeMapping(
        Range(1, 1, originalLines.length,
            originalLines[originalLines.length - 1].length + 1),
        Range(1, 1, modifiedLines.length,
            modifiedLines[modifiedLines.length - 1].length + 1),
      );
      rawChanges?.add(rangeMapping);
      return LinesDiff(
        <DetailedLineRangeMapping>[
          DetailedLineRangeMapping(
            LineRange(1, originalLines.length + 1),
            LineRange(1, modifiedLines.length + 1),
            <RangeMapping>[rangeMapping],
          ),
        ],
        <MovedText>[],
        false,
      );
    }

    final ITimeout timeout = options.maxComputationTimeMs == 0
        ? InfiniteTimeout.instance
        : DateTimeout(options.maxComputationTimeMs);
    final bool considerWhitespaceChanges = !options.ignoreTrimWhitespace;

    final Map<String, int> perfectHashes = <String, int>{};
    int getOrCreateHash(String text) {
      int? hash = perfectHashes[text];
      if (hash == null) {
        hash = perfectHashes.length;
        perfectHashes[text] = hash;
      }
      return hash;
    }

    final List<int> originalLinesHashes = originalLines
        .map((String l) => getOrCreateHash(l.trim()))
        .toList();
    final List<int> modifiedLinesHashes = modifiedLines
        .map((String l) => getOrCreateHash(l.trim()))
        .toList();

    final LineSequence sequence1 =
        LineSequence(originalLinesHashes, originalLines);
    final LineSequence sequence2 =
        LineSequence(modifiedLinesHashes, modifiedLines);

    late final DiffAlgorithmResult lineAlignmentResult;
    if (sequence1.length + sequence2.length < 1700) {
      // Use the improved algorithm for small files
      lineAlignmentResult = DynamicProgrammingDiffing(
        equalityScore: (int offset1, int offset2) {
          if (originalLines[offset1] == modifiedLines[offset2]) {
            return modifiedLines[offset2].isEmpty
                ? 0.1
                : 1 + math.log(1 + modifiedLines[offset2].length);
          }
          return 0.99;
        },
      ).compute(sequence1, sequence2, timeout);
    } else {
      lineAlignmentResult =
          _myersDiffingAlgorithm.compute(sequence1, sequence2, timeout);
    }

    List<SequenceDiff> lineAlignments = lineAlignmentResult.diffs;
    bool hitTimeout = lineAlignmentResult.hitTimeout;
    lineAlignments =
        optimizeSequenceDiffs(sequence1, sequence2, lineAlignments);
    lineAlignments = removeVeryShortMatchingLinesBetweenDiffs(
        sequence1, sequence2, lineAlignments);

    final List<RangeMapping> alignments = <RangeMapping>[];

    int seq1LastStart = 0;
    int seq2LastStart = 0;

    void scanForWhitespaceChanges(int equalLinesCount) {
      if (!considerWhitespaceChanges) {
        return;
      }

      for (int i = 0; i < equalLinesCount; i++) {
        final int seq1Offset = seq1LastStart + i;
        final int seq2Offset = seq2LastStart + i;
        if (originalLines[seq1Offset] != modifiedLines[seq2Offset]) {
          // This is because of whitespace changes, diff these lines
          final _RefineDiffResult characterDiffs = _refineDiff(
            originalLines,
            modifiedLines,
            SequenceDiff(
              OffsetRange(seq1Offset, seq1Offset + 1),
              OffsetRange(seq2Offset, seq2Offset + 1),
            ),
            timeout,
            considerWhitespaceChanges,
            options,
            rawChanges,
          );
          for (final RangeMapping a in characterDiffs.mappings) {
            alignments.add(a);
          }
          if (characterDiffs.hitTimeout) {
            hitTimeout = true;
          }
        }
      }
    }

    for (final SequenceDiff diff in lineAlignments) {
      assertFn(() =>
          diff.seq1Range.start - seq1LastStart ==
          diff.seq2Range.start - seq2LastStart);

      final int equalLinesCount = diff.seq1Range.start - seq1LastStart;

      scanForWhitespaceChanges(equalLinesCount);

      seq1LastStart = diff.seq1Range.endExclusive;
      seq2LastStart = diff.seq2Range.endExclusive;

      final _RefineDiffResult characterDiffs = _refineDiff(
        originalLines,
        modifiedLines,
        diff,
        timeout,
        considerWhitespaceChanges,
        options,
        rawChanges,
      );
      if (characterDiffs.hitTimeout) {
        hitTimeout = true;
      }
      for (final RangeMapping a in characterDiffs.mappings) {
        alignments.add(a);
      }
    }

    scanForWhitespaceChanges(originalLines.length - seq1LastStart);

    final ArrayText original = ArrayText(originalLines);
    final ArrayText modified = ArrayText(modifiedLines);

    final List<DetailedLineRangeMapping> changes =
        lineRangeMappingFromRangeMappings(alignments, original, modified);

    List<MovedText> moves = <MovedText>[];
    if (options.computeMoves) {
      moves = _computeMoves(
        changes,
        originalLines,
        modifiedLines,
        originalLinesHashes,
        modifiedLinesHashes,
        timeout,
        considerWhitespaceChanges,
        options,
      );
    }

    // Make sure all ranges are valid
    assertFn(() {
      bool validatePosition(Position pos, List<String> lines) {
        if (pos.lineNumber < 1 || pos.lineNumber > lines.length) {
          return false;
        }
        final String line = lines[pos.lineNumber - 1];
        if (pos.column < 1 || pos.column > line.length + 1) {
          return false;
        }
        return true;
      }

      bool validateRange(LineRange range, List<String> lines) {
        if (range.startLineNumber < 1 ||
            range.startLineNumber > lines.length + 1) {
          return false;
        }
        if (range.endLineNumberExclusive < 1 ||
            range.endLineNumberExclusive > lines.length + 1) {
          return false;
        }
        return true;
      }

      for (final DetailedLineRangeMapping c in changes) {
        if (c.innerChanges == null) {
          return false;
        }
        for (final RangeMapping ic in c.innerChanges!) {
          final bool valid = validatePosition(
                  ic.modifiedRange.getStartPosition(), modifiedLines) &&
              validatePosition(
                  ic.modifiedRange.getEndPosition(), modifiedLines) &&
              validatePosition(
                  ic.originalRange.getStartPosition(), originalLines) &&
              validatePosition(
                  ic.originalRange.getEndPosition(), originalLines);
          if (!valid) {
            return false;
          }
        }
        if (!validateRange(c.modified, modifiedLines) ||
            !validateRange(c.original, originalLines)) {
          return false;
        }
      }
      return true;
    });

    return LinesDiff(changes, moves, hitTimeout);
  }

  List<MovedText> _computeMoves(
    List<DetailedLineRangeMapping> changes,
    List<String> originalLines,
    List<String> modifiedLines,
    List<int> hashedOriginalLines,
    List<int> hashedModifiedLines,
    ITimeout timeout,
    bool considerWhitespaceChanges,
    ILinesDiffComputerOptions options,
  ) {
    final List<LineRangeMapping> moves = computeMovedLines(
      changes,
      originalLines,
      modifiedLines,
      hashedOriginalLines,
      hashedModifiedLines,
      timeout,
    );
    final List<MovedText> movesWithDiffs = moves.map((LineRangeMapping m) {
      final _RefineDiffResult moveChanges = _refineDiff(
        originalLines,
        modifiedLines,
        SequenceDiff(
          m.original.toOffsetRange(),
          m.modified.toOffsetRange(),
        ),
        timeout,
        considerWhitespaceChanges,
        options,
      );
      final List<DetailedLineRangeMapping> mappings =
          lineRangeMappingFromRangeMappings(
              moveChanges.mappings,
              ArrayText(originalLines),
              ArrayText(modifiedLines),
              true);
      return MovedText(m, mappings);
    }).toList();
    return movesWithDiffs;
  }

  _RefineDiffResult _refineDiff(
    List<String> originalLines,
    List<String> modifiedLines,
    SequenceDiff diff,
    ITimeout timeout,
    bool considerWhitespaceChanges,
    ILinesDiffComputerOptions options, [
    List<RangeMapping>? rawChanges,
  ]) {
    final LineRangeMapping lineRangeMapping = _toLineRangeMapping(diff);
    final RangeMapping rangeMapping =
        lineRangeMapping.toRangeMapping2(originalLines, modifiedLines);

    final LinesSliceCharSequence slice1 = LinesSliceCharSequence(
        originalLines, rangeMapping.originalRange, considerWhitespaceChanges);
    final LinesSliceCharSequence slice2 = LinesSliceCharSequence(
        modifiedLines, rangeMapping.modifiedRange, considerWhitespaceChanges);

    final bool useDynamicProgramming = slice1.length + slice2.length < 500;
    final DiffAlgorithmResult diffResult = useDynamicProgramming
        ? _dynamicProgrammingDiffing.compute(slice1, slice2, timeout)
        : _myersDiffingAlgorithm.compute(slice1, slice2, timeout);

    bool hitTimeout = diffResult.hitTimeout;
    if (rawChanges != null) {
      // The small-slice display algorithm favors consecutive matches over the longest common subsequence.
      final DiffAlgorithmResult rawResult = useDynamicProgramming && !hitTimeout
          ? _myersDiffingAlgorithm.compute(slice1, slice2, timeout)
          : diffResult;
      hitTimeout = hitTimeout || rawResult.hitTimeout;
      for (final SequenceDiff change in rawResult.diffs) {
        rawChanges.add(RangeMapping(
          slice1.translateRange(change.seq1Range),
          slice2.translateRange(change.seq2Range),
        ));
      }
    }

    List<SequenceDiff> diffs = diffResult.diffs;
    if (_defaultLinesDiffComputerCheck) {
      SequenceDiff.assertSorted(diffs);
    }
    diffs = optimizeSequenceDiffs(slice1, slice2, diffs);
    if (_defaultLinesDiffComputerCheck) {
      SequenceDiff.assertSorted(diffs);
    }
    diffs = extendDiffsToEntireWordIfAppropriate(
        slice1, slice2, diffs, (LinesSliceCharSequence seq, int idx) {
      final OffsetRange? r = seq.findWordContaining(idx);
      return r;
    });
    if (_defaultLinesDiffComputerCheck) {
      SequenceDiff.assertSorted(diffs);
    }

    if (options.extendToSubwords == true) {
      diffs = extendDiffsToEntireWordIfAppropriate(
          slice1, slice2, diffs, (LinesSliceCharSequence seq, int idx) {
        final OffsetRange? r = seq.findSubWordContaining(idx);
        return r;
      }, true);
      if (_defaultLinesDiffComputerCheck) {
        SequenceDiff.assertSorted(diffs);
      }
    }

    diffs = removeShortMatches(slice1, slice2, diffs);
    if (_defaultLinesDiffComputerCheck) {
      SequenceDiff.assertSorted(diffs);
    }
    diffs = removeVeryShortMatchingTextBetweenLongDiffs(slice1, slice2, diffs);
    if (_defaultLinesDiffComputerCheck) {
      SequenceDiff.assertSorted(diffs);
    }

    final List<RangeMapping> result = diffs
        .map((SequenceDiff d) => RangeMapping(
              slice1.translateRange(d.seq1Range),
              slice2.translateRange(d.seq2Range),
            ))
        .toList();

    if (_defaultLinesDiffComputerCheck) {
      RangeMapping.assertSorted(result);
    }

    // Assert: result applied on original should be the same as diff applied to original

    return _RefineDiffResult(result, hitTimeout);
  }
}

/// 1:1: `function toLineRangeMapping`
LineRangeMapping _toLineRangeMapping(SequenceDiff sequenceDiff) =>
    LineRangeMapping(
      LineRange(
        sequenceDiff.seq1Range.start + 1,
        sequenceDiff.seq1Range.endExclusive + 1,
      ),
      LineRange(
        sequenceDiff.seq2Range.start + 1,
        sequenceDiff.seq2Range.endExclusive + 1,
      ),
    );
