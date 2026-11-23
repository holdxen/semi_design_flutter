// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/edit.ts
// Translated 1:1 from TypeScript.
//   - TS self-referential generics `T extends BaseReplacement<T>` map directly
//     to Dart's bounded generics.
//   - `X[]` queues with shift/unshift -> `ListQueue` (removeFirst/addFirst).
//   - `.at(-1)` -> `.last`.
//   - `sumBy` -> `sumBy(...).toInt()` (Dart `num` -> `int`).
// ---------------------------------------------------------------------------

import 'dart:collection';

import '../../../../base/common/arrays.dart' as arrays;
import '../../../../base/common/errors.dart';
import '../ranges/offsetRange.dart';

/// 1:1: `BaseEdit<T, TEdit>`
abstract class BaseEdit<T extends BaseReplacement<T>, TEdit extends BaseEdit<T, TEdit>> {
  final List<T> replacements;

  BaseEdit(this.replacements) {
    int lastEndEx = -1;
    for (final T replacement in replacements) {
      if (!(replacement.replaceRange.start >= lastEndEx)) {
        throw BugIndicatingError('Edits must be disjoint and sorted. Found $replacement after $lastEndEx');
      }
      lastEndEx = replacement.replaceRange.endExclusive;
    }
  }

  TEdit createNew(List<T> replacements);

  /// Returns true if and only if this edit and the given edit are structurally equal.
  bool equals(TEdit other) {
    if (this.replacements.length != other.replacements.length) {
      return false;
    }
    for (int i = 0; i < this.replacements.length; i++) {
      if (!this.replacements[i].equals(other.replacements[i])) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    final String edits = this.replacements.map((T e) => e.toString()).join(', ');
    return '[$edits]';
  }

  /// Normalizes the edit by removing empty replacements and joining touching replacements.
  TEdit normalize() {
    final List<T> newReplacements = <T>[];
    T? lastReplacement;
    for (final T r in this.replacements) {
      if (r.getNewLength() == 0 && r.replaceRange.length == 0) {
        continue;
      }
      if (lastReplacement != null && lastReplacement.replaceRange.endExclusive == r.replaceRange.start) {
        final T? joined = lastReplacement.tryJoinTouching(r);
        if (joined != null) {
          lastReplacement = joined;
          continue;
        }
      }

      if (lastReplacement != null) {
        newReplacements.add(lastReplacement);
      }
      lastReplacement = r;
    }

    if (lastReplacement != null) {
      newReplacements.add(lastReplacement);
    }
    return this.createNew(newReplacements);
  }

  /// Combines two edits into one with the same effect.
  /// `other.apply(this.apply(s0)) = this.compose(other).apply(s0)`
  TEdit compose(TEdit other) {
    final TEdit edits1 = this.normalize();
    final TEdit edits2 = other.normalize();

    if (edits1.isEmpty()) {
      return edits2;
    }
    if (edits2.isEmpty()) {
      return edits1;
    }

    final ListQueue<T> edit1Queue = ListQueue<T>.from(edits1.replacements);
    final List<T> result = <T>[];

    int edit1ToEdit2 = 0;

    for (final T r2 in edits2.replacements) {
      // Copy over edit1 unmodified until it touches edit2.
      while (true) {
        final T? r1 = edit1Queue.isEmpty ? null : edit1Queue.first;
        if (r1 == null || r1.replaceRange.start + edit1ToEdit2 + r1.getNewLength() >= r2.replaceRange.start) {
          break;
        }
        edit1Queue.removeFirst();

        result.add(r1);
        edit1ToEdit2 += r1.getNewLength() - r1.replaceRange.length;
      }

      final int firstEdit1ToEdit2 = edit1ToEdit2;
      T? firstIntersecting; // or touching
      T? lastIntersecting; // or touching

      while (true) {
        final T? r1 = edit1Queue.isEmpty ? null : edit1Queue.first;
        if (r1 == null || r1.replaceRange.start + edit1ToEdit2 > r2.replaceRange.endExclusive) {
          break;
        }
        // else we intersect, because the new end of edit1 is after or equal to our start

        if (firstIntersecting == null) {
          firstIntersecting = r1;
        }
        lastIntersecting = r1;
        edit1Queue.removeFirst();

        edit1ToEdit2 += r1.getNewLength() - r1.replaceRange.length;
      }

      if (firstIntersecting == null) {
        result.add(r2.delta(-edit1ToEdit2));
      } else {
        final int newReplaceRangeStart = _min(firstIntersecting.replaceRange.start, r2.replaceRange.start - firstEdit1ToEdit2);

        final int prefixLength = r2.replaceRange.start - (firstIntersecting.replaceRange.start + firstEdit1ToEdit2);
        if (prefixLength > 0) {
          final T prefix = firstIntersecting.slice(OffsetRange.emptyAt(newReplaceRangeStart), OffsetRange(0, prefixLength));
          result.add(prefix);
        }
        if (lastIntersecting == null) {
          throw BugIndicatingError('Invariant violation: lastIntersecting is undefined');
        }
        final int suffixLength = (lastIntersecting.replaceRange.endExclusive + edit1ToEdit2) - r2.replaceRange.endExclusive;
        if (suffixLength > 0) {
          final T e = lastIntersecting.slice(
            OffsetRange.ofStartAndLength(lastIntersecting.replaceRange.endExclusive, 0),
            OffsetRange(lastIntersecting.getNewLength() - suffixLength, lastIntersecting.getNewLength()),
          );
          edit1Queue.addFirst(e);
          edit1ToEdit2 -= e.getNewLength() - e.replaceRange.length;
        }

        final OffsetRange newReplaceRange = OffsetRange(
          newReplaceRangeStart,
          r2.replaceRange.endExclusive - edit1ToEdit2,
        );
        final T middle = r2.slice(newReplaceRange, OffsetRange(0, r2.getNewLength()));
        result.add(middle);
      }
    }

    while (true) {
      if (edit1Queue.isEmpty) {
        break;
      }
      final T item = edit1Queue.removeFirst();
      result.add(item);
    }

    return this.createNew(result).normalize();
  }

  /// Splits this edit into two edits by [shouldBeInE1].
  ({TEdit e1, TEdit e2}) decomposeSplit(bool Function(T repl) shouldBeInE1) {
    final List<T> e1 = <T>[];
    final List<T> e2 = <T>[];

    int e2delta = 0;
    for (final T edit in this.replacements) {
      if (shouldBeInE1(edit)) {
        e1.add(edit);
        e2delta += edit.getNewLength() - edit.replaceRange.length;
      } else {
        e2.add(edit.slice(edit.replaceRange.delta(e2delta), OffsetRange(0, edit.getNewLength())));
      }
    }
    return (e1: this.createNew(e1), e2: this.createNew(e2));
  }

  /// Returns the range of each replacement in the applied value.
  List<OffsetRange> getNewRanges() {
    final List<OffsetRange> ranges = <OffsetRange>[];
    int offset = 0;
    for (final T e in this.replacements) {
      ranges.add(OffsetRange.ofStartAndLength(e.replaceRange.start + offset, e.getNewLength()));
      offset += e.getLengthDelta();
    }
    return ranges;
  }

  OffsetRange? getJoinedReplaceRange() {
    if (this.replacements.isEmpty) {
      return null;
    }
    return this.replacements.first.replaceRange.join(this.replacements.last.replaceRange);
  }

  bool isEmpty() => this.replacements.isEmpty;

  int getLengthDelta() => arrays.sumBy(this.replacements, (T replacement) => replacement.getLengthDelta()).toInt();

  int getNewDataLength(int dataLength) => dataLength + this.getLengthDelta();

  int applyToOffset(int originalOffset) {
    int accumulatedDelta = 0;
    for (final T r in this.replacements) {
      if (r.replaceRange.start <= originalOffset) {
        if (originalOffset < r.replaceRange.endExclusive) {
          // the offset is in the replaced range
          return r.replaceRange.start + accumulatedDelta;
        }
        accumulatedDelta += r.getNewLength() - r.replaceRange.length;
      } else {
        break;
      }
    }
    return originalOffset + accumulatedDelta;
  }

  OffsetRange applyToOffsetRange(OffsetRange originalRange) {
    return OffsetRange(
      this.applyToOffset(originalRange.start),
      this.applyToOffset(originalRange.endExclusive),
    );
  }

  int applyInverseToOffset(int postEditsOffset) {
    int accumulatedDelta = 0;
    for (final T edit in this.replacements) {
      final int editLength = edit.getNewLength();
      if (edit.replaceRange.start <= postEditsOffset - accumulatedDelta) {
        if (postEditsOffset - accumulatedDelta < edit.replaceRange.start + editLength) {
          // the offset is in the replaced range
          return edit.replaceRange.start;
        }
        accumulatedDelta += editLength - edit.replaceRange.length;
      } else {
        break;
      }
    }
    return postEditsOffset - accumulatedDelta;
  }

  /// Return null if the originalOffset is within an edit.
  int? applyToOffsetOrUndefined(int originalOffset) {
    int accumulatedDelta = 0;
    for (final T edit in this.replacements) {
      if (edit.replaceRange.start <= originalOffset) {
        if (originalOffset < edit.replaceRange.endExclusive) {
          // the offset is in the replaced range
          return null;
        }
        accumulatedDelta += edit.getNewLength() - edit.replaceRange.length;
      } else {
        break;
      }
    }
    return originalOffset + accumulatedDelta;
  }

  /// Return null if the originalRange is within an edit.
  OffsetRange? applyToOffsetRangeOrUndefined(OffsetRange originalRange) {
    final int? start = this.applyToOffsetOrUndefined(originalRange.start);
    if (start == null) {
      return null;
    }
    final int? end = this.applyToOffsetOrUndefined(originalRange.endExclusive);
    if (end == null) {
      return null;
    }
    return OffsetRange(start, end);
  }
}

int _min(int a, int b) => a < b ? a : b;

/// 1:1: `BaseReplacement<TSelf>`
abstract class BaseReplacement<TSelf extends BaseReplacement<TSelf>> {
  /// The range to be replaced.
  final OffsetRange replaceRange;

  BaseReplacement(this.replaceRange);

  int getNewLength();

  /// Precondition: `replaceRange.endExclusive === other.replaceRange.start`
  TSelf? tryJoinTouching(TSelf other);

  TSelf slice(OffsetRange newReplaceRange, [OffsetRange? rangeInReplacement]);

  TSelf delta(int offset) => this.slice(this.replaceRange.delta(offset), OffsetRange(0, this.getNewLength()));

  int getLengthDelta() => this.getNewLength() - this.replaceRange.length;

  bool equals(TSelf other);

  @override
  String toString() => '{ ${this.replaceRange.toString()} -> ${this.getNewLength()} }';

  bool get isEmpty => this.getNewLength() == 0 && this.replaceRange.length == 0;

  OffsetRange getRangeAfterReplace() => OffsetRange(this.replaceRange.start, this.replaceRange.start + this.getNewLength());
}

/// 1:1: `AnyReplacement` / `AnyEdit`.
/// TS uses `never` as the erased type; Dart's F-bounded generics cannot be
/// instantiated with `dynamic`/`never`, so a minimal concrete carrier is used.
class AnyReplacement extends BaseReplacement<AnyReplacement> {
  AnyReplacement(super.replaceRange);

  @override
  int getNewLength() => this.replaceRange.length;

  @override
  AnyReplacement? tryJoinTouching(AnyReplacement other) => null;

  @override
  AnyReplacement slice(OffsetRange newReplaceRange, [OffsetRange? rangeInReplacement]) => AnyReplacement(newReplaceRange);

  @override
  bool equals(AnyReplacement other) => this.replaceRange.equals(other.replaceRange);
}

typedef AnyEdit = Edit<AnyReplacement>;

/// 1:1: `Edit<T>`
class Edit<T extends BaseReplacement<T>> extends BaseEdit<T, Edit<T>> {
  /// Represents a set of edits to a string. All these edits are applied at once.
  static final Edit<AnyReplacement> empty = Edit<AnyReplacement>(<AnyReplacement>[]);

  Edit(super.replacements);

  static Edit<T> create<T extends BaseReplacement<T>>(List<T> replacements) => Edit<T>(replacements);

  static Edit<T> single<T extends BaseReplacement<T>>(T replacement) => Edit<T>(<T>[replacement]);

  @override
  Edit<T> createNew(List<T> replacements) => Edit<T>(replacements);
}

/// 1:1: `AnnotationReplacement<TAnnotation>`
class AnnotationReplacement<TAnnotation> extends BaseReplacement<AnnotationReplacement<TAnnotation>> {
  final int newLength;
  final TAnnotation annotation;

  AnnotationReplacement(OffsetRange range, this.newLength, this.annotation) : super(range);

  @override
  bool equals(AnnotationReplacement<TAnnotation> other) =>
      this.replaceRange.equals(other.replaceRange) && this.newLength == other.newLength && this.annotation == other.annotation;

  @override
  int getNewLength() => this.newLength;

  @override
  AnnotationReplacement<TAnnotation>? tryJoinTouching(AnnotationReplacement<TAnnotation> other) {
    if (this.annotation != other.annotation) {
      return null;
    }
    return AnnotationReplacement<TAnnotation>(
      this.replaceRange.joinRightTouching(other.replaceRange),
      this.newLength + other.newLength,
      this.annotation,
    );
  }

  @override
  AnnotationReplacement<TAnnotation> slice(OffsetRange range, [OffsetRange? rangeInReplacement]) {
    return AnnotationReplacement<TAnnotation>(
      range,
      rangeInReplacement != null ? rangeInReplacement.length : this.newLength,
      this.annotation,
    );
  }
}
