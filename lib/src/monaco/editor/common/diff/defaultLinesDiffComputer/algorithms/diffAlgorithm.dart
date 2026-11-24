// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/algorithms/diffAlgorithm.ts
// 严格 1:1 翻译，勿改类名/API。
import '../../../../../base/common/arrays.dart' show forEachAdjacent;
import '../../../../../base/common/errors.dart' show BugIndicatingError;
import '../../../core/ranges/offsetRange.dart' show OffsetRange;

/// 1:1: `export interface IDiffAlgorithm`
abstract class IDiffAlgorithm {
  DiffAlgorithmResult compute(ISequence sequence1, ISequence sequence2, [ITimeout? timeout]);
}

/// 1:1: `export class DiffAlgorithmResult`
class DiffAlgorithmResult {
  final List<SequenceDiff> diffs;
  final bool hitTimeout;
  DiffAlgorithmResult(this.diffs, this.hitTimeout);

  static DiffAlgorithmResult trivial(ISequence seq1, ISequence seq2) => DiffAlgorithmResult(
        <SequenceDiff>[
          SequenceDiff(
            OffsetRange.ofLength(seq1.length),
            OffsetRange.ofLength(seq2.length),
          )
        ],
        false,
      );

  static DiffAlgorithmResult trivialTimedOut(ISequence seq1, ISequence seq2) => DiffAlgorithmResult(
        <SequenceDiff>[
          SequenceDiff(
            OffsetRange.ofLength(seq1.length),
            OffsetRange.ofLength(seq2.length),
          )
        ],
        true,
      );
}

/// 1:1: `export class SequenceDiff`
class SequenceDiff {
  final OffsetRange seq1Range;
  final OffsetRange seq2Range;
  SequenceDiff(this.seq1Range, this.seq2Range);

  /// 1:1: `static invert`
  static List<SequenceDiff> invert(List<SequenceDiff> sequenceDiffs, int doc1Length) {
    final List<SequenceDiff> result = <SequenceDiff>[];
    forEachAdjacent<SequenceDiff>(sequenceDiffs, (SequenceDiff? a, SequenceDiff? b) {
      result.add(SequenceDiff.fromOffsetPairs(
        a != null ? a.getEndExclusives() : OffsetPair.zero,
        b != null
            ? b.getStarts()
            : OffsetPair(
                doc1Length,
                (a != null ? a.seq2Range.endExclusive - a.seq1Range.endExclusive : 0) + doc1Length,
              ),
      ));
    });
    return result;
  }

  /// 1:1: `static fromOffsetPairs`
  static SequenceDiff fromOffsetPairs(OffsetPair start, OffsetPair endExclusive) => SequenceDiff(
        OffsetRange(start.offset1, endExclusive.offset1),
        OffsetRange(start.offset2, endExclusive.offset2),
      );

  /// 1:1: `static assertSorted`
  static void assertSorted(List<SequenceDiff> sequenceDiffs) {
    SequenceDiff? last;
    for (final SequenceDiff cur in sequenceDiffs) {
      if (last != null) {
        if (!(last.seq1Range.endExclusive <= cur.seq1Range.start &&
            last.seq2Range.endExclusive <= cur.seq2Range.start)) {
          throw BugIndicatingError('Sequence diffs must be sorted');
        }
      }
      last = cur;
    }
  }

  SequenceDiff swap() => SequenceDiff(seq2Range, seq1Range);

  @override
  String toString() => '$seq1Range <-> $seq2Range';

  SequenceDiff join(SequenceDiff other) =>
      SequenceDiff(seq1Range.join(other.seq1Range), seq2Range.join(other.seq2Range));

  SequenceDiff delta(int offset) {
    if (offset == 0) return this;
    return SequenceDiff(seq1Range.delta(offset), seq2Range.delta(offset));
  }

  SequenceDiff deltaStart(int offset) {
    if (offset == 0) return this;
    return SequenceDiff(seq1Range.deltaStart(offset), seq2Range.deltaStart(offset));
  }

  SequenceDiff deltaEnd(int offset) {
    if (offset == 0) return this;
    return SequenceDiff(seq1Range.deltaEnd(offset), seq2Range.deltaEnd(offset));
  }

  bool intersectsOrTouches(SequenceDiff other) =>
      seq1Range.intersectsOrTouches(other.seq1Range) ||
      seq2Range.intersectsOrTouches(other.seq2Range);

  SequenceDiff? intersect(SequenceDiff other) {
    final OffsetRange? i1 = seq1Range.intersect(other.seq1Range);
    final OffsetRange? i2 = seq2Range.intersect(other.seq2Range);
    if (i1 == null || i2 == null) {
      return null;
    }
    return SequenceDiff(i1, i2);
  }

  OffsetPair getStarts() => OffsetPair(seq1Range.start, seq2Range.start);

  OffsetPair getEndExclusives() => OffsetPair(seq1Range.endExclusive, seq2Range.endExclusive);
}

/// 1:1: `export class OffsetPair`
class OffsetPair {
  static final OffsetPair zero = OffsetPair(0, 0);
  static final OffsetPair max = OffsetPair(9007199254740991, 9007199254740991); // Number.MAX_SAFE_INTEGER

  final int offset1;
  final int offset2;
  OffsetPair(this.offset1, this.offset2);

  @override
  String toString() => '$offset1 <-> $offset2';

  OffsetPair delta(int offset) {
    if (offset == 0) return this;
    return OffsetPair(offset1 + offset, offset2 + offset);
  }

  bool equals(OffsetPair other) => offset1 == other.offset1 && offset2 == other.offset2;
}

/// 1:1: `export interface ISequence`
abstract class ISequence {
  int getElement(int offset);
  int get length;

  /// 越高表示该 offset 越适合作为分割点。必须非负。
  int getBoundaryScore(int length) => 0;

  bool isStronglyEqual(int offset1, int offset2);
}

/// 1:1: `export interface ITimeout`
abstract class ITimeout {
  bool isValid();
}

/// 1:1: `export class InfiniteTimeout`
class InfiniteTimeout implements ITimeout {
  static final InfiniteTimeout instance = InfiniteTimeout();

  @override
  bool isValid() => true;
}

/// Test seam equivalent to `sinon.stub(DateTimeout.prototype, 'isValid').returns(false)`.
/// Mirrors the official test without introducing a browser timer dependency.
bool forceDateTimeoutInvalidForTesting = false;

/// 1:1: `export class DateTimeout`
class DateTimeout implements ITimeout {
  final int startTime = DateTime.now().millisecondsSinceEpoch;
  bool _valid = true;
  int timeout;

  DateTimeout(this.timeout) {
    if (timeout <= 0) {
      throw BugIndicatingError('timeout must be positive');
    }
  }

  @override
  bool isValid() {
    if (forceDateTimeoutInvalidForTesting) {
      _valid = false;
      return false;
    }
    if (_disabled) return true;
    final bool valid = DateTime.now().millisecondsSinceEpoch - startTime < timeout;
    if (!valid && _valid) {
      _valid = false;
    }
    return _valid;
  }

  void disable() {
    timeout = 9007199254740991;
    // 源码 `this.isValid = () => true` 替换实例方法；Dart 用标志承载。
    _disabled = true;
    _valid = true;
  }

  bool _disabled = false;

  /// 供调用方判断 disable 后的语义（源码直接替换了 isValid）。
  bool get isDisabled => _disabled;
}
