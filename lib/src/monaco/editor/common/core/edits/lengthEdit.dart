// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/lengthEdit.ts
// Translated 1:1 from TypeScript.
//   - static `compose` -> `composeStatic` (Dart forbids a static member sharing
//     a name with the inherited instance method `BaseEdit.compose`).
//   - `new Array(n)` sparse array -> `List<T>.filled(n, fillItem)`; every slot
//     is written by the copy/fill loops, so the initial fill is always replaced.
// ---------------------------------------------------------------------------

import '../ranges/offsetRange.dart';
import 'edit.dart';

/// 1:1: `LengthEdit`
class LengthEdit extends BaseEdit<LengthReplacement, LengthEdit> {
  static final LengthEdit empty = LengthEdit(<LengthReplacement>[]);

  LengthEdit(super.replacements);

  /// 1:1: `fromEdit`
  static LengthEdit fromEdit(AnyEdit edit) {
    return LengthEdit(edit.replacements
        .map((BaseReplacement<Object?> r) => LengthReplacement(r.replaceRange, r.getNewLength()))
        .toList());
  }

  static LengthEdit create(List<LengthReplacement> replacements) => LengthEdit(replacements);

  static LengthEdit single(LengthReplacement replacement) => LengthEdit(<LengthReplacement>[replacement]);

  static LengthEdit replace(OffsetRange range, int newLength) =>
      LengthEdit(<LengthReplacement>[LengthReplacement(range, newLength)]);

  static LengthEdit insert(int offset, int newLength) =>
      LengthEdit(<LengthReplacement>[LengthReplacement(OffsetRange.emptyAt(offset), newLength)]);

  static LengthEdit delete(OffsetRange range) =>
      LengthEdit(<LengthReplacement>[LengthReplacement(range, 0)]);

  /// 1:1: `static compose`
  static LengthEdit composeStatic(List<LengthEdit> edits) {
    LengthEdit e = LengthEdit.empty;
    for (final LengthEdit edit in edits) {
      e = e.compose(edit);
    }
    return e;
  }

  /// 1:1: `inverse`
  LengthEdit inverse() {
    final List<LengthReplacement> edits = <LengthReplacement>[];
    int offset = 0;
    for (final LengthReplacement e in this.replacements) {
      edits.add(LengthReplacement(
        OffsetRange.ofStartAndLength(e.replaceRange.start + offset, e.newLength),
        e.replaceRange.length,
      ));
      offset += e.newLength - e.replaceRange.length;
    }
    return LengthEdit(edits);
  }

  @override
  LengthEdit createNew(List<LengthReplacement> replacements) => LengthEdit(replacements);

  /// 1:1: `applyArray`
  List<T> applyArray<T>(List<T> arr, T fillItem) {
    final List<T> newArr = List<T>.filled(this.getNewDataLength(arr.length), fillItem);

    int srcPos = 0;
    int dstPos = 0;

    for (final LengthReplacement replacement in this.replacements) {
      for (int i = srcPos; i < replacement.replaceRange.start; i++) {
        newArr[dstPos++] = arr[i];
      }
      srcPos = replacement.replaceRange.endExclusive;
      for (int i = 0; i < replacement.newLength; i++) {
        newArr[dstPos++] = fillItem;
      }
    }
    while (srcPos < arr.length) {
      newArr[dstPos++] = arr[srcPos++];
    }
    return newArr;
  }
}

/// 1:1: `LengthReplacement`
class LengthReplacement extends BaseReplacement<LengthReplacement> {
  static LengthReplacement create(int startOffset, int endOffsetExclusive, int newLength) {
    return LengthReplacement(OffsetRange(startOffset, endOffsetExclusive), newLength);
  }

  final int newLength;

  LengthReplacement(super.range, this.newLength);

  @override
  bool equals(LengthReplacement other) =>
      this.replaceRange.equals(other.replaceRange) && this.newLength == other.newLength;

  @override
  int getNewLength() => this.newLength;

  @override
  LengthReplacement? tryJoinTouching(LengthReplacement other) {
    return LengthReplacement(this.replaceRange.joinRightTouching(other.replaceRange), this.newLength + other.newLength);
  }

  @override
  LengthReplacement slice(OffsetRange range, [OffsetRange? rangeInReplacement]) {
    return LengthReplacement(range, rangeInReplacement != null ? rangeInReplacement.length : this.newLength);
  }

  @override
  String toString() => '[${this.replaceRange.start}, +${this.replaceRange.length}) -> +${this.newLength}}';
}
