// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/bracketPairsTextModelPart/
// bracketPairsTree/combineTextEditInfos.ts
// Translated 1:1 from TypeScript. `Length` is an int typedef. `ArrayQueue` is
// the shared base queue. The TS sentinel object with `lengthBefore:
// undefined`/`lengthAfter: undefined` is represented by `_S1ToS2` with
// nullable lengths (null == "infinity"/undefined). Tuple returns -> records.
// ---------------------------------------------------------------------------

import '../../../../../base/common/arrays.dart' show ArrayQueue;
import 'beforeEditPositionMapper.dart' show TextEditInfo;
import 'length.dart'
    show
        Length,
        lengthAdd,
        lengthDiffNonNegative,
        lengthEquals,
        lengthIsZero,
        lengthToObj,
        lengthZero,
        sumLengths;

/// 1:1: `export function combineTextEditInfos`
List<TextEditInfo> combineTextEditInfos(List<TextEditInfo> textEditInfoFirst,
    List<TextEditInfo> textEditInfoSecond) {
  if (textEditInfoFirst.isEmpty) {
    return textEditInfoSecond;
  }
  if (textEditInfoSecond.isEmpty) {
    return textEditInfoFirst;
  }

  // s0: State before any edits
  final ArrayQueue<LengthMapping> s0ToS1Map =
      ArrayQueue<LengthMapping>(toLengthMapping(textEditInfoFirst));
  // s1: State after first edit, but before second edit
  final List<_S1ToS2> s1ToS2Map = toLengthMapping(textEditInfoSecond)
      .map((LengthMapping m) =>
          _S1ToS2(m.modified, m.lengthBefore, m.lengthAfter))
      .toList();
  // Copy everything from old to new (source pushes a sentinel with
  // lengthBefore/lengthAfter === undefined).
  s1ToS2Map.add(_S1ToS2(false, null, null));
  // s2: State after both edits

  LengthMapping? curItem = s0ToS1Map.dequeue();

  /// [s1Length] null is used for length "infinity".
  List<LengthMapping> nextS0ToS1MapWithS1LengthOf(Length? s1Length) {
    if (s1Length == null) {
      final List<LengthMapping> arr =
          s0ToS1Map.takeWhile((LengthMapping v) => true) ?? <LengthMapping>[];
      if (curItem != null) {
        arr.insert(0, curItem!);
      }
      return arr;
    }

    // Local non-nullable copy: Dart flow promotion on the nullable parameter
    // is lost once it is reassigned inside the loop (TS keeps the narrowing).
    final Length current = s1Length;
    final List<LengthMapping> result = <LengthMapping>[];
    Length remaining = current;
    while (curItem != null && !lengthIsZero(remaining)) {
      final (LengthMapping item, LengthMapping? remainingItem) =
          curItem!.splitAt(remaining);
      result.add(item);
      remaining = lengthDiffNonNegative(item.lengthAfter, remaining);
      curItem = remainingItem ?? s0ToS1Map.dequeue();
    }
    if (!lengthIsZero(remaining)) {
      result.add(LengthMapping(false, remaining, remaining));
    }
    return result;
  }

  final List<TextEditInfo> result = <TextEditInfo>[];

  void pushEdit(Length startOffset, Length endOffset, Length newLength) {
    if (result.isNotEmpty &&
        lengthEquals(result[result.length - 1].endOffset, startOffset)) {
      final TextEditInfo lastResult = result[result.length - 1];
      result[result.length - 1] = TextEditInfo(lastResult.startOffset,
          endOffset, lengthAdd(lastResult.newLength, newLength));
    } else {
      result.add(TextEditInfo(startOffset, endOffset, newLength));
    }
  }

  Length s0offset = lengthZero;
  for (final _S1ToS2 s1ToS2 in s1ToS2Map) {
    final List<LengthMapping> s0ToS1MapLocal =
        nextS0ToS1MapWithS1LengthOf(s1ToS2.lengthBefore);
    if (s1ToS2.modified) {
      final Length s0Length =
          sumLengths(s0ToS1MapLocal, (LengthMapping s) => s.lengthBefore);
      final Length s0EndOffset = lengthAdd(s0offset, s0Length);
      pushEdit(s0offset, s0EndOffset, s1ToS2.lengthAfter!);
      s0offset = s0EndOffset;
    } else {
      for (final LengthMapping s1 in s0ToS1MapLocal) {
        final Length s0startOffset = s0offset;
        s0offset = lengthAdd(s0offset, s1.lengthBefore);
        if (s1.modified) {
          pushEdit(s0startOffset, s0offset, s1.lengthAfter);
        }
      }
    }
  }

  return result;
}

/// 1:1: `class LengthMapping`
class LengthMapping {
  LengthMapping(this.modified, this.lengthBefore, this.lengthAfter);

  /// If false, length before and length after equal.
  final bool modified;
  final Length lengthBefore;
  final Length lengthAfter;

  (LengthMapping, LengthMapping?) splitAt(Length lengthAfter) {
    final Length remainingLengthAfter =
        lengthDiffNonNegative(lengthAfter, this.lengthAfter);
    if (lengthEquals(remainingLengthAfter, lengthZero)) {
      return (this, null);
    } else if (modified) {
      return (
        LengthMapping(modified, lengthBefore, lengthAfter),
        LengthMapping(modified, lengthZero, remainingLengthAfter)
      );
    } else {
      return (
        LengthMapping(modified, lengthAfter, lengthAfter),
        LengthMapping(modified, remainingLengthAfter, remainingLengthAfter)
      );
    }
  }

  @override
  String toString() =>
      '${modified ? 'M' : 'U'}:${lengthToObj(lengthBefore)} -> ${lengthToObj(lengthAfter)}';
}

/// Sentinel/entry carrier for the s1->s2 map: null length means the TS
/// `undefined` sentinel ("copy everything from old to new").
class _S1ToS2 {
  _S1ToS2(this.modified, this.lengthBefore, this.lengthAfter);

  final bool modified;
  final Length? lengthBefore;
  final Length? lengthAfter;
}

/// 1:1: `function toLengthMapping`
List<LengthMapping> toLengthMapping(List<TextEditInfo> textEditInfos) {
  final List<LengthMapping> result = <LengthMapping>[];
  Length lastOffset = lengthZero;
  for (final TextEditInfo textEditInfo in textEditInfos) {
    final Length spaceLength =
        lengthDiffNonNegative(lastOffset, textEditInfo.startOffset);
    if (!lengthIsZero(spaceLength)) {
      result.add(LengthMapping(false, spaceLength, spaceLength));
    }

    final Length lengthBefore =
        lengthDiffNonNegative(textEditInfo.startOffset, textEditInfo.endOffset);
    result.add(LengthMapping(true, lengthBefore, textEditInfo.newLength));
    lastOffset = textEditInfo.endOffset;
  }
  return result;
}
