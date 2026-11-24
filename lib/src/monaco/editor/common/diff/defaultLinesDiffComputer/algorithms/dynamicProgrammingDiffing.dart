// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/algorithms/dynamicProgrammingDiffing.ts

import 'dart:math' as math;

import '../../../core/ranges/offsetRange.dart' show OffsetRange;
import '../utils.dart' show Array2D;
import 'diffAlgorithm.dart'
    show
        DiffAlgorithmResult,
        IDiffAlgorithm,
        ISequence,
        ITimeout,
        InfiniteTimeout,
        SequenceDiff;

/// A O(MN) diffing algorithm that supports a score function.
class DynamicProgrammingDiffing implements IDiffAlgorithm {
  /// TS passes `equalityScore` as an optional 4th argument. Dart's
  /// [IDiffAlgorithm.compute] declares three parameters, so the same value is
  /// carried as a field instead; [compute] keeps the interface signature.
  /// The score is [num] (not [int]) because the default line diff passes
  /// fractional scores such as `0.1` and `1 + log(1 + lineLength)`.
  final num Function(int offset1, int offset2)? equalityScore;

  DynamicProgrammingDiffing({this.equalityScore});

  @override
  DiffAlgorithmResult compute(
    ISequence sequence1,
    ISequence sequence2, [
    ITimeout? timeout,
  ]) {
    final ITimeout effectiveTimeout = timeout ?? InfiniteTimeout.instance;
    if (sequence1.length == 0 || sequence2.length == 0) {
      return DiffAlgorithmResult.trivial(sequence1, sequence2);
    }

    final Array2D<num> lcsLengths =
        Array2D<num>(sequence1.length, sequence2.length);
    final Array2D<int> directions =
        Array2D<int>(sequence1.length, sequence2.length);
    final Array2D<int> lengths =
        Array2D<int>(sequence1.length, sequence2.length);

    for (int s1 = 0; s1 < sequence1.length; s1++) {
      for (int s2 = 0; s2 < sequence2.length; s2++) {
        if (!effectiveTimeout.isValid()) {
          return DiffAlgorithmResult.trivialTimedOut(sequence1, sequence2);
        }

        final num horizontalLen = s1 == 0 ? 0 : lcsLengths.get(s1 - 1, s2);
        final num verticalLen = s2 == 0 ? 0 : lcsLengths.get(s1, s2 - 1);

        num extendedSeqScore;
        if (sequence1.getElement(s1) == sequence2.getElement(s2)) {
          if (s1 == 0 || s2 == 0) {
            extendedSeqScore = 0;
          } else {
            extendedSeqScore = lcsLengths.get(s1 - 1, s2 - 1);
          }
          if (s1 > 0 && s2 > 0 && directions.get(s1 - 1, s2 - 1) == 3) {
            extendedSeqScore += lengths.get(s1 - 1, s2 - 1);
          }
          extendedSeqScore += equalityScore != null ? equalityScore!(s1, s2) : 1;
        } else {
          extendedSeqScore = -1;
        }

        final num newValue = math.max(
            horizontalLen, math.max(verticalLen, extendedSeqScore));

        if (newValue == extendedSeqScore) {
          final int prevLen =
              s1 > 0 && s2 > 0 ? lengths.get(s1 - 1, s2 - 1) : 0;
          lengths.set(s1, s2, prevLen + 1);
          directions.set(s1, s2, 3);
        } else if (newValue == horizontalLen) {
          lengths.set(s1, s2, 0);
          directions.set(s1, s2, 1);
        } else if (newValue == verticalLen) {
          lengths.set(s1, s2, 0);
          directions.set(s1, s2, 2);
        }

        lcsLengths.set(s1, s2, newValue);
      }
    }

    final List<SequenceDiff> result = <SequenceDiff>[];
    int lastAligningPosS1 = sequence1.length;
    int lastAligningPosS2 = sequence2.length;

    void reportDecreasingAligningPositions(int s1, int s2) {
      if (s1 + 1 != lastAligningPosS1 || s2 + 1 != lastAligningPosS2) {
        result.add(SequenceDiff(
          OffsetRange(s1 + 1, lastAligningPosS1),
          OffsetRange(s2 + 1, lastAligningPosS2),
        ));
      }
      lastAligningPosS1 = s1;
      lastAligningPosS2 = s2;
    }

    int s1 = sequence1.length - 1;
    int s2 = sequence2.length - 1;
    while (s1 >= 0 && s2 >= 0) {
      if (directions.get(s1, s2) == 3) {
        reportDecreasingAligningPositions(s1, s2);
        s1--;
        s2--;
      } else {
        if (directions.get(s1, s2) == 1) {
          s1--;
        } else {
          s2--;
        }
      }
    }
    reportDecreasingAligningPositions(-1, -1);
    final List<SequenceDiff> reversed = result.reversed.toList();
    return DiffAlgorithmResult(reversed, false);
  }
}
