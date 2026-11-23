// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/arrayEdit.ts
// Translated 1:1 from TypeScript.
//   - `readonly T[]` -> `List<T>`, spread `...data.slice(a, b)` -> `addAll(sublist)`.
//   - `ArrayEdit<never>.empty` -> concrete `ArrayEdit<Object?>.empty` carrier
//     (Dart F-bounded generics cannot be instantiated with `never`).
// ---------------------------------------------------------------------------

import '../ranges/offsetRange.dart';
import 'edit.dart';

/// 1:1: `ArrayEdit<T>`
class ArrayEdit<T> extends BaseEdit<ArrayReplacement<T>, ArrayEdit<T>> {
  /// 1:1: `static readonly empty = new ArrayEdit<never>([])`
  static final ArrayEdit<Object?> empty = ArrayEdit<Object?>(<ArrayReplacement<Object?>>[]);

  ArrayEdit(super.replacements);

  static ArrayEdit<T> create<T>(List<ArrayReplacement<T>> replacements) => ArrayEdit<T>(replacements);

  static ArrayEdit<T> single<T>(ArrayReplacement<T> replacement) => ArrayEdit<T>(<ArrayReplacement<T>>[replacement]);

  static ArrayEdit<T> replace<T>(OffsetRange range, List<T> replacement) =>
      ArrayEdit<T>(<ArrayReplacement<T>>[ArrayReplacement<T>(range, replacement)]);

  static ArrayEdit<T> insert<T>(int offset, List<T> replacement) =>
      ArrayEdit<T>(<ArrayReplacement<T>>[ArrayReplacement<T>(OffsetRange.emptyAt(offset), replacement)]);

  static ArrayEdit<T> delete<T>(OffsetRange range) =>
      ArrayEdit<T>(<ArrayReplacement<T>>[ArrayReplacement<T>(range, <T>[])]);

  @override
  ArrayEdit<T> createNew(List<ArrayReplacement<T>> replacements) => ArrayEdit<T>(replacements);

  /// 1:1: `apply`
  List<T> apply(List<T> data) {
    final List<T> resultData = <T>[];
    int pos = 0;
    for (final ArrayReplacement<T> edit in this.replacements) {
      resultData.addAll(data.sublist(pos, edit.replaceRange.start));
      resultData.addAll(edit.newValue);
      pos = edit.replaceRange.endExclusive;
    }
    resultData.addAll(data.sublist(pos));
    return resultData;
  }

  /// 1:1: `inverse`
  ArrayEdit<T> inverse(List<T> baseVal) {
    final List<ArrayReplacement<T>> edits = <ArrayReplacement<T>>[];
    int offset = 0;
    for (final ArrayReplacement<T> e in this.replacements) {
      edits.add(ArrayReplacement<T>(
        OffsetRange.ofStartAndLength(e.replaceRange.start + offset, e.newValue.length),
        baseVal.sublist(e.replaceRange.start, e.replaceRange.endExclusive),
      ));
      offset += e.newValue.length - e.replaceRange.length;
    }
    return ArrayEdit<T>(edits);
  }
}

/// 1:1: `ArrayReplacement<T>`
class ArrayReplacement<T> extends BaseReplacement<ArrayReplacement<T>> {
  final List<T> newValue;

  ArrayReplacement(super.range, this.newValue);

  @override
  bool equals(ArrayReplacement<T> other) {
    if (!this.replaceRange.equals(other.replaceRange)) {
      return false;
    }
    if (this.newValue.length != other.newValue.length) {
      return false;
    }
    for (int i = 0; i < this.newValue.length; i++) {
      if (this.newValue[i] != other.newValue[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int getNewLength() => this.newValue.length;

  @override
  ArrayReplacement<T>? tryJoinTouching(ArrayReplacement<T> other) {
    return ArrayReplacement<T>(
      this.replaceRange.joinRightTouching(other.replaceRange),
      <T>[...this.newValue, ...other.newValue],
    );
  }

  @override
  ArrayReplacement<T> slice(OffsetRange range, [OffsetRange? rangeInReplacement]) {
    return ArrayReplacement<T>(range, rangeInReplacement!.slice(this.newValue));
  }
}
