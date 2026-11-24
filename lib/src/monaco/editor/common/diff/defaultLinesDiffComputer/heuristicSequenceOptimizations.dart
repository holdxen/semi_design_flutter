// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/heuristicSequenceOptimizations.ts
// 严格 1:1 翻译；禁止自作主张改写算法语义。

import 'dart:math' as math;

import '../../../../base/common/arrays.dart' show forEachWithNeighbors;
import '../../core/ranges/offsetRange.dart' show OffsetRange;
import 'algorithms/diffAlgorithm.dart' show ISequence, OffsetPair, SequenceDiff;
import 'lineSequence.dart' show LineSequence;
import 'linesSliceCharSequence.dart' show LinesSliceCharSequence;

/// 1:1: `export function optimizeSequenceDiffs`
List<SequenceDiff> optimizeSequenceDiffs(
  ISequence sequence1,
  ISequence sequence2,
  List<SequenceDiff> sequenceDiffs,
) {
  List<SequenceDiff> result = sequenceDiffs;
  result = _joinSequenceDiffsByShifting(sequence1, sequence2, result);
  // Sometimes, calling this function twice improves the result.
  // Uncomment the second invocation and run the tests to see the difference.
  result = _joinSequenceDiffsByShifting(sequence1, sequence2, result);
  result = _shiftSequenceDiffs(sequence1, sequence2, result);
  return result;
}

/// 1:1: `function joinSequenceDiffsByShifting`
List<SequenceDiff> _joinSequenceDiffsByShifting(
  ISequence sequence1,
  ISequence sequence2,
  List<SequenceDiff> sequenceDiffs,
) {
  if (sequenceDiffs.isEmpty) {
    return sequenceDiffs;
  }

  final List<SequenceDiff> result = <SequenceDiff>[];
  result.add(sequenceDiffs[0]);

  // First move them all to the left as much as possible and join them if possible
  for (int i = 1; i < sequenceDiffs.length; i++) {
    final SequenceDiff prevResult = result[result.length - 1];
    SequenceDiff cur = sequenceDiffs[i];

    if (cur.seq1Range.isEmpty || cur.seq2Range.isEmpty) {
      final int length = cur.seq1Range.start - prevResult.seq1Range.endExclusive;
      int d;
      for (d = 1; d <= length; d++) {
        if (sequence1.getElement(cur.seq1Range.start - d) !=
                sequence1.getElement(cur.seq1Range.endExclusive - d) ||
            sequence2.getElement(cur.seq2Range.start - d) !=
                sequence2.getElement(cur.seq2Range.endExclusive - d)) {
          break;
        }
      }
      d--;

      if (d == length) {
        // Merge previous and current diff
        result[result.length - 1] = SequenceDiff(
          OffsetRange(prevResult.seq1Range.start,
              cur.seq1Range.endExclusive - length),
          OffsetRange(prevResult.seq2Range.start,
              cur.seq2Range.endExclusive - length),
        );
        continue;
      }

      cur = cur.delta(-d);
    }

    result.add(cur);
  }

  final List<SequenceDiff> result2 = <SequenceDiff>[];
  // Then move them all to the right and join them again if possible
  for (int i = 0; i < result.length - 1; i++) {
    final SequenceDiff nextResult = result[i + 1];
    SequenceDiff cur = result[i];

    if (cur.seq1Range.isEmpty || cur.seq2Range.isEmpty) {
      final int length = nextResult.seq1Range.start - cur.seq1Range.endExclusive;
      int d;
      for (d = 0; d < length; d++) {
        if (!sequence1.isStronglyEqual(
                cur.seq1Range.start + d, cur.seq1Range.endExclusive + d) ||
            !sequence2.isStronglyEqual(
                cur.seq2Range.start + d, cur.seq2Range.endExclusive + d)) {
          break;
        }
      }

      if (d == length) {
        // Merge previous and current diff, write to result!
        result[i + 1] = SequenceDiff(
          OffsetRange(cur.seq1Range.start + length,
              nextResult.seq1Range.endExclusive),
          OffsetRange(cur.seq2Range.start + length,
              nextResult.seq2Range.endExclusive),
        );
        continue;
      }

      if (d > 0) {
        cur = cur.delta(d);
      }
    }

    result2.add(cur);
  }

  if (result.isNotEmpty) {
    result2.add(result[result.length - 1]);
  }

  return result2;
}

/// 1:1: `function shiftSequenceDiffs`
List<SequenceDiff> _shiftSequenceDiffs(
  ISequence sequence1,
  ISequence sequence2,
  List<SequenceDiff> sequenceDiffs,
) {
  // In TypeScript this is guarded by an optional `getBoundaryScore`.
  // In the 1:1 Dart port ISequence always provides the default implementation.
  for (int i = 0; i < sequenceDiffs.length; i++) {
    final SequenceDiff? prevDiff = i > 0 ? sequenceDiffs[i - 1] : null;
    final SequenceDiff diff = sequenceDiffs[i];
    final SequenceDiff? nextDiff = i + 1 < sequenceDiffs.length
        ? sequenceDiffs[i + 1]
        : null;

    final OffsetRange seq1ValidRange = OffsetRange(
      prevDiff != null ? prevDiff.seq1Range.endExclusive + 1 : 0,
      nextDiff != null ? nextDiff.seq1Range.start - 1 : sequence1.length,
    );
    final OffsetRange seq2ValidRange = OffsetRange(
      prevDiff != null ? prevDiff.seq2Range.endExclusive + 1 : 0,
      nextDiff != null ? nextDiff.seq2Range.start - 1 : sequence2.length,
    );

    if (diff.seq1Range.isEmpty) {
      sequenceDiffs[i] = _shiftDiffToBetterPosition(
        diff,
        sequence1,
        sequence2,
        seq1ValidRange,
        seq2ValidRange,
      );
    } else if (diff.seq2Range.isEmpty) {
      sequenceDiffs[i] = _shiftDiffToBetterPosition(
        diff.swap(),
        sequence2,
        sequence1,
        seq2ValidRange,
        seq1ValidRange,
      ).swap();
    }
  }

  return sequenceDiffs;
}

/// 1:1: `function shiftDiffToBetterPosition`
SequenceDiff _shiftDiffToBetterPosition(
  SequenceDiff diff,
  ISequence sequence1,
  ISequence sequence2,
  OffsetRange seq1ValidRange,
  OffsetRange seq2ValidRange,
) {
  const int maxShiftLimit = 100; // To prevent performance issues

  // don't touch previous or next!
  int deltaBefore = 1;
  while (diff.seq1Range.start - deltaBefore >= seq1ValidRange.start &&
      diff.seq2Range.start - deltaBefore >= seq2ValidRange.start &&
      sequence2.isStronglyEqual(
          diff.seq2Range.start - deltaBefore,
          diff.seq2Range.endExclusive - deltaBefore) &&
      deltaBefore < maxShiftLimit) {
    deltaBefore++;
  }
  deltaBefore--;

  int deltaAfter = 0;
  while (diff.seq1Range.start + deltaAfter < seq1ValidRange.endExclusive &&
      diff.seq2Range.endExclusive + deltaAfter < seq2ValidRange.endExclusive &&
      sequence2.isStronglyEqual(
          diff.seq2Range.start + deltaAfter,
          diff.seq2Range.endExclusive + deltaAfter) &&
      deltaAfter < maxShiftLimit) {
    deltaAfter++;
  }

  if (deltaBefore == 0 && deltaAfter == 0) {
    return diff;
  }

  int bestDelta = 0;
  int bestScore = -1;
  // find best scored delta
  for (int delta = -deltaBefore; delta <= deltaAfter; delta++) {
    final int seq2OffsetStart = diff.seq2Range.start + delta;
    final int seq2OffsetEndExclusive = diff.seq2Range.endExclusive + delta;
    final int seq1Offset = diff.seq1Range.start + delta;

    final int score = sequence1.getBoundaryScore(seq1Offset) +
        sequence2.getBoundaryScore(seq2OffsetStart) +
        sequence2.getBoundaryScore(seq2OffsetEndExclusive);
    if (score > bestScore) {
      bestScore = score;
      bestDelta = delta;
    }
  }

  return diff.delta(bestDelta);
}

/// 1:1: `export function removeShortMatches`
List<SequenceDiff> removeShortMatches(
  ISequence sequence1,
  ISequence sequence2,
  List<SequenceDiff> sequenceDiffs,
) {
  final List<SequenceDiff> result = <SequenceDiff>[];
  for (final SequenceDiff s in sequenceDiffs) {
    final SequenceDiff? last = result.isEmpty ? null : result[result.length - 1];
    if (last == null) {
      result.add(s);
      continue;
    }

    if (s.seq1Range.start - last.seq1Range.endExclusive <= 2 ||
        s.seq2Range.start - last.seq2Range.endExclusive <= 2) {
      result[result.length - 1] = SequenceDiff(
        last.seq1Range.join(s.seq1Range),
        last.seq2Range.join(s.seq2Range),
      );
    } else {
      result.add(s);
    }
  }

  return result;
}

/// 1:1: `export function extendDiffsToEntireWordIfAppropriate`
List<SequenceDiff> extendDiffsToEntireWordIfAppropriate(
  LinesSliceCharSequence sequence1,
  LinesSliceCharSequence sequence2,
  List<SequenceDiff> sequenceDiffs,
  OffsetRange? Function(LinesSliceCharSequence seq, int idx) findParent, [
  bool force = false,
]) {
  final List<SequenceDiff> equalMappings =
      SequenceDiff.invert(sequenceDiffs, sequence1.length);

  final List<SequenceDiff> additional = <SequenceDiff>[];

  OffsetPair lastPoint = OffsetPair.zero;

  void scanWord(OffsetPair pair, SequenceDiff equalMapping) {
    if (pair.offset1 < lastPoint.offset1 ||
        pair.offset2 < lastPoint.offset2) {
      return;
    }

    final OffsetRange? w1 = findParent(sequence1, pair.offset1);
    final OffsetRange? w2 = findParent(sequence2, pair.offset2);
    if (w1 == null || w2 == null) {
      return;
    }
    SequenceDiff w = SequenceDiff(w1, w2);
    final SequenceDiff? equalPart = w.intersect(equalMapping);
    // Source uses a non-null assertion; the callers guarantee an intersection.
    final SequenceDiff nonNullEqualPart = equalPart!;

    int equalChars1 = nonNullEqualPart.seq1Range.length;
    int equalChars2 = nonNullEqualPart.seq2Range.length;

    // The words do not touch previous equals mappings, as we would have processed them already.
    // But they might touch the next ones.
    while (equalMappings.isNotEmpty) {
      final SequenceDiff next = equalMappings[0];
      final bool intersects = next.seq1Range.intersects(w.seq1Range) ||
          next.seq2Range.intersects(w.seq2Range);
      if (!intersects) {
        break;
      }

      final OffsetRange? v1 = findParent(sequence1, next.seq1Range.start);
      final OffsetRange? v2 = findParent(sequence2, next.seq2Range.start);
      // Because there is an intersection, we know that the words are not empty.
      final SequenceDiff v = SequenceDiff(v1!, v2!);
      final SequenceDiff equalPart2 = v.intersect(next)!;

      equalChars1 += equalPart2.seq1Range.length;
      equalChars2 += equalPart2.seq2Range.length;

      w = w.join(v);

      if (w.seq1Range.endExclusive >= next.seq1Range.endExclusive) {
        // The word extends beyond the next equal mapping.
        equalMappings.removeAt(0);
      } else {
        break;
      }
    }

    if ((force && equalChars1 + equalChars2 <
            w.seq1Range.length + w.seq2Range.length) ||
        equalChars1 + equalChars2 <
            (w.seq1Range.length + w.seq2Range.length) * 2 / 3) {
      additional.add(w);
    }

    lastPoint = w.getEndExclusives();
  }

  while (equalMappings.isNotEmpty) {
    final SequenceDiff next = equalMappings.removeAt(0);
    if (next.seq1Range.isEmpty) {
      continue;
    }
    scanWord(next.getStarts(), next);
    // The equal parts are not empty, so -1 gives us a character that is equal in both parts.
    scanWord(next.getEndExclusives().delta(-1), next);
  }

  final List<SequenceDiff> merged =
      _mergeSequenceDiffs(sequenceDiffs, additional);
  return merged;
}

/// 1:1: `function mergeSequenceDiffs`
List<SequenceDiff> _mergeSequenceDiffs(
  List<SequenceDiff> sequenceDiffs1,
  List<SequenceDiff> sequenceDiffs2,
) {
  final List<SequenceDiff> result = <SequenceDiff>[];
  final List<SequenceDiff> a = List<SequenceDiff>.from(sequenceDiffs1);
  final List<SequenceDiff> b = List<SequenceDiff>.from(sequenceDiffs2);

  while (a.isNotEmpty || b.isNotEmpty) {
    final SequenceDiff? sd1 = a.isEmpty ? null : a[0];
    final SequenceDiff? sd2 = b.isEmpty ? null : b[0];

    late final SequenceDiff next;
    if (sd1 != null && (sd2 == null || sd1.seq1Range.start < sd2.seq1Range.start)) {
      next = a.removeAt(0);
    } else {
      next = b.removeAt(0);
    }

    if (result.isNotEmpty &&
        result[result.length - 1].seq1Range.endExclusive >=
            next.seq1Range.start) {
      result[result.length - 1] = result[result.length - 1].join(next);
    } else {
      result.add(next);
    }
  }

  return result;
}

/// 1:1: `export function removeVeryShortMatchingLinesBetweenDiffs`
List<SequenceDiff> removeVeryShortMatchingLinesBetweenDiffs(
  LineSequence sequence1,
  LineSequence _sequence2,
  List<SequenceDiff> sequenceDiffs,
) {
  List<SequenceDiff> diffs = sequenceDiffs;
  if (diffs.isEmpty) {
    return diffs;
  }

  int counter = 0;
  late bool shouldRepeat;
  do {
    shouldRepeat = false;

    final List<SequenceDiff> result = <SequenceDiff>[diffs[0]];

    for (int i = 1; i < diffs.length; i++) {
      final SequenceDiff cur = diffs[i];
      final SequenceDiff lastResult = result[result.length - 1];

      bool shouldJoinDiffs(SequenceDiff before, SequenceDiff after) {
        final OffsetRange unchangedRange =
            OffsetRange(lastResult.seq1Range.endExclusive, cur.seq1Range.start);

        final String unchangedText = sequence1.getText(unchangedRange);
        final String unchangedTextWithoutWs =
            unchangedText.replaceAll(RegExp(r'\s'), '');
        if (unchangedTextWithoutWs.length <= 4 &&
            (before.seq1Range.length + before.seq2Range.length > 5 ||
                after.seq1Range.length + after.seq2Range.length > 5)) {
          return true;
        }

        return false;
      }

      final bool shouldJoin = shouldJoinDiffs(lastResult, cur);
      if (shouldJoin) {
        shouldRepeat = true;
        result[result.length - 1] = result[result.length - 1].join(cur);
      } else {
        result.add(cur);
      }
    }

    diffs = result;
  } while (counter++ < 10 && shouldRepeat);

  return diffs;
}

/// 1:1: `export function removeVeryShortMatchingTextBetweenLongDiffs`
List<SequenceDiff> removeVeryShortMatchingTextBetweenLongDiffs(
  LinesSliceCharSequence sequence1,
  LinesSliceCharSequence sequence2,
  List<SequenceDiff> sequenceDiffs,
) {
  List<SequenceDiff> diffs = sequenceDiffs;
  if (diffs.isEmpty) {
    return diffs;
  }

  int counter = 0;
  late bool shouldRepeat;
  do {
    shouldRepeat = false;

    final List<SequenceDiff> result = <SequenceDiff>[diffs[0]];

    for (int i = 1; i < diffs.length; i++) {
      final SequenceDiff cur = diffs[i];
      final SequenceDiff lastResult = result[result.length - 1];

      bool shouldJoinDiffs(SequenceDiff before, SequenceDiff after) {
        final OffsetRange unchangedRange =
            OffsetRange(lastResult.seq1Range.endExclusive, cur.seq1Range.start);

        final int unchangedLineCount =
            sequence1.countLinesIn(unchangedRange);
        if (unchangedLineCount > 5 || unchangedRange.length > 500) {
          return false;
        }

        final String unchangedText =
            sequence1.getText(unchangedRange).trim();
        if (unchangedText.length > 20 ||
            unchangedText.split(RegExp(r'\r\n|\r|\n')).length > 1) {
          return false;
        }

        final int beforeLineCount1 = sequence1.countLinesIn(before.seq1Range);
        final int beforeSeq1Length = before.seq1Range.length;
        final int beforeLineCount2 = sequence2.countLinesIn(before.seq2Range);
        final int beforeSeq2Length = before.seq2Range.length;

        final int afterLineCount1 = sequence1.countLinesIn(after.seq1Range);
        final int afterSeq1Length = after.seq1Range.length;
        final int afterLineCount2 = sequence2.countLinesIn(after.seq2Range);
        final int afterSeq2Length = after.seq2Range.length;

        // TODO: Maybe a neural net can be used to derive the result from these numbers
        const int max = 2 * 40 + 50;
        int cap(int v) => math.min(v, max);

        final num left = math.pow(
                math.pow(cap(beforeLineCount1 * 40 + beforeSeq1Length), 1.5) +
                    math.pow(cap(beforeLineCount2 * 40 + beforeSeq2Length), 1.5),
                1.5);
        final num right = math.pow(
                math.pow(cap(afterLineCount1 * 40 + afterSeq1Length), 1.5) +
                    math.pow(cap(afterLineCount2 * 40 + afterSeq2Length), 1.5),
                1.5);
        final num threshold = math.pow(math.pow(max, 1.5), 1.5) * 1.3;
        if (left + right > threshold) {
          return true;
        }
        return false;
      }

      final bool shouldJoin = shouldJoinDiffs(lastResult, cur);
      if (shouldJoin) {
        shouldRepeat = true;
        result[result.length - 1] = result[result.length - 1].join(cur);
      } else {
        result.add(cur);
      }
    }

    diffs = result;
  } while (counter++ < 10 && shouldRepeat);

  final List<SequenceDiff> newDiffs = <SequenceDiff>[];

  // Remove short suffixes/prefixes
  forEachWithNeighbors<SequenceDiff>(diffs,
      (SequenceDiff? prev, SequenceDiff cur, SequenceDiff? next) {
    SequenceDiff newDiff = cur;

    bool shouldMarkAsChanged(String text) =>
        text.isNotEmpty &&
        text.trim().length <= 3 &&
        cur.seq1Range.length + cur.seq2Range.length > 100;

    final OffsetRange fullRange1 = sequence1.extendToFullLines(cur.seq1Range);
    final String prefix = sequence1.getText(
        OffsetRange(fullRange1.start, cur.seq1Range.start));
    if (shouldMarkAsChanged(prefix)) {
      newDiff = newDiff.deltaStart(-prefix.length);
    }
    final String suffix = sequence1.getText(
        OffsetRange(cur.seq1Range.endExclusive, fullRange1.endExclusive));
    if (shouldMarkAsChanged(suffix)) {
      newDiff = newDiff.deltaEnd(suffix.length);
    }

    final OffsetPair availableStart =
        prev != null ? prev.getEndExclusives() : OffsetPair.zero;
    final OffsetPair availableEnd =
        next != null ? next.getStarts() : OffsetPair.max;
    final SequenceDiff availableSpace =
        SequenceDiff.fromOffsetPairs(availableStart, availableEnd);
    final SequenceDiff result = newDiff.intersect(availableSpace)!;
    if (newDiffs.isNotEmpty &&
        result.getStarts().equals(newDiffs[newDiffs.length - 1].getEndExclusives())) {
      newDiffs[newDiffs.length - 1] =
          newDiffs[newDiffs.length - 1].join(result);
    } else {
      newDiffs.add(result);
    }
  });

  return newDiffs;
}
