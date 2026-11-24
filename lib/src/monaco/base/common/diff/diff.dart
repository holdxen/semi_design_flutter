// 1:1 port of vscode/src/vs/base/common/diff/diff.ts
// 严格 1:1 翻译，勿改类名/API。
import 'dart:typed_data';

import '../hash.dart' show stringHash;
import '../strings.dart' show computeCodePoint, isHighSurrogate, isLowSurrogate;
import '../uint.dart' show Constants;
import 'diffChange.dart' show DiffChange;

// ---- JS int32 位运算适配 ----------------------------------------------------
// Dart int 是 64 位，JS 位运算是 32 位有符号。`~`/`<<` 结果需截断为 int32；
// `>>>` 是无符号右移，结果落在 [0, 2^32)。

/// JS `x | 0`：截断为 int32 有符号。
int _i32(int x) {
  final int m = x & 0xFFFFFFFF;
  return m >= 0x80000000 ? m - 0x100000000 : m;
}

/// JS `x >>> n`：无符号右移（返回非负 int32 表示的无符号值）。
int _ushr(int x, int n) => (x & 0xFFFFFFFF) >> n;

/// JS `~x` 的 int32 结果。
int _bitnot(int x) => _i32(~x);

/// JS `x << n` 的 int32 结果。
int _shl(int x, int n) => _i32(x << n);

/// 1:1: `export class StringDiffSequence implements ISequence`
class StringDiffSequence implements ISequence {
  final String source;
  StringDiffSequence(this.source);

  @override
  Object getElements() {
    final String source = this.source;
    final Int32List characters = Int32List(source.length);
    for (int i = 0, len = source.length; i < len; i++) {
      characters[i] = source.codeUnitAt(i);
    }
    return characters;
  }

  @override
  String? getStrictElement(int index) => null;
}

/// 1:1: `class CodePointDiffSequence implements ISequence`
class CodePointDiffSequence implements ISequence {
  final Int32List elements;
  final Int32List offsets;

  CodePointDiffSequence(String source) : elements = Int32List(_countElements(source)), offsets = Int32List(_countElements(source) + 1) {
    int elementIndex = 0;
    for (int offset = 0; offset < source.length; elementIndex++) {
      offsets[elementIndex] = offset;
      final int charCode = source.codeUnitAt(offset);
      if (isHighSurrogate(charCode) && offset + 1 < source.length) {
        final int nextCharCode = source.codeUnitAt(offset + 1);
        if (isLowSurrogate(nextCharCode)) {
          elements[elementIndex] = computeCodePoint(charCode, nextCharCode);
          offset += 2;
          continue;
        }
      }
      elements[elementIndex] = charCode;
      offset++;
    }
    offsets[_countElements(source)] = source.length;
  }

  @override
  Object getElements() => elements;

  /// 1:1: `getOffset`
  int getOffset(int elementIndex) => offsets[elementIndex];

  @override
  String? getStrictElement(int index) => null;
}

int _countElements(String source) {
  int elementCount = 0;
  for (int offset = 0; offset < source.length;) {
    final int charCode = source.codeUnitAt(offset);
    offset += (isHighSurrogate(charCode) &&
            offset + 1 < source.length &&
            isLowSurrogate(source.codeUnitAt(offset + 1)))
        ? 2
        : 1;
    elementCount++;
  }
  return elementCount;
}

/// 1:1: `export function stringDiff`
List<IDiffChange> stringDiff(String original, String modified, bool pretty) {
  if (!containsSurrogatePair(original) && !containsSurrogatePair(modified)) {
    return LcsDiff(StringDiffSequence(original), StringDiffSequence(modified))
        .ComputeDiff(pretty)
        .changes;
  }

  final CodePointDiffSequence originalSequence = CodePointDiffSequence(original);
  final CodePointDiffSequence modifiedSequence = CodePointDiffSequence(modified);
  return LcsDiff(originalSequence, modifiedSequence).ComputeDiff(pretty).changes.map((change) {
    final int originalStart = originalSequence.getOffset(change.originalStart);
    final int originalEnd = originalSequence.getOffset(change.originalStart + change.originalLength);
    final int modifiedStart = modifiedSequence.getOffset(change.modifiedStart);
    final int modifiedEnd = modifiedSequence.getOffset(change.modifiedStart + change.modifiedLength);
    return IDiffChange(
      originalStart,
      originalEnd - originalStart,
      modifiedStart,
      modifiedEnd - modifiedStart,
    );
  }).toList();
}

/// 1:1: `function containsSurrogatePair`
bool containsSurrogatePair(String value) {
  for (int i = 0; i + 1 < value.length; i++) {
    if (isHighSurrogate(value.codeUnitAt(i)) && isLowSurrogate(value.codeUnitAt(i + 1))) {
      return true;
    }
  }
  return false;
}

/// 1:1: `export interface ISequence`
abstract class ISequence {
  /// 源码返回 `Int32Array | number[] | string[]`，Dart 用 Object 承载实际类型。
  Object getElements();
  String? getStrictElement(int index) => null;
}

/// 1:1: `export interface IDiffChange` — 源码 DiffChange 结构相同，直接 typedef 复用。
typedef IDiffChange = DiffChange;

/// 1:1: `export interface IContinueProcessingPredicate`
typedef IContinueProcessingPredicate = bool Function(int furthestOriginalIndex, num matchLengthOfLongest);

/// 1:1: `export interface IDiffResult`
class IDiffResult {
  final bool quitEarly;
  final List<DiffChange> changes;
  IDiffResult(this.quitEarly, this.changes);
}

/// 1:1: `class Debug`
class Debug {
  static void Assert(bool condition, String message) {
    if (!condition) {
      throw StateError(message);
    }
  }
}

/// 1:1: `class MyArray`
class MyArray {
  static void Copy(List sourceArray, int sourceIndex, List destinationArray, int destinationIndex, int length) {
    for (int i = 0; i < length; i++) {
      destinationArray[destinationIndex + i] = sourceArray[sourceIndex + i];
    }
  }

  static void Copy2(Int32List sourceArray, int sourceIndex, Int32List destinationArray, int destinationIndex, int length) {
    for (int i = 0; i < length; i++) {
      destinationArray[destinationIndex + i] = sourceArray[sourceIndex + i];
    }
  }
}

/// 1:1: `const enum LocalConstants`
class LocalConstants {
  static const int MaxDifferencesHistory = 1447;
}

/// 1:1: `class DiffChangeHelper`
class DiffChangeHelper {
  final List<DiffChange> m_changes = <DiffChange>[];
  int m_originalStart = Constants.MAX_SAFE_SMALL_INTEGER;
  int m_modifiedStart = Constants.MAX_SAFE_SMALL_INTEGER;
  int m_originalCount = 0;
  int m_modifiedCount = 0;

  void MarkNextChange() {
    if (m_originalCount > 0 || m_modifiedCount > 0) {
      m_changes.add(DiffChange(m_originalStart, m_originalCount, m_modifiedStart, m_modifiedCount));
    }
    m_originalCount = 0;
    m_modifiedCount = 0;
    m_originalStart = Constants.MAX_SAFE_SMALL_INTEGER;
    m_modifiedStart = Constants.MAX_SAFE_SMALL_INTEGER;
  }

  void AddOriginalElement(int originalIndex, int modifiedIndex) {
    m_originalStart = m_originalStart < originalIndex ? m_originalStart : originalIndex;
    m_modifiedStart = m_modifiedStart < modifiedIndex ? m_modifiedStart : modifiedIndex;
    m_originalCount++;
  }

  void AddModifiedElement(int originalIndex, int modifiedIndex) {
    m_originalStart = m_originalStart < originalIndex ? m_originalStart : originalIndex;
    m_modifiedStart = m_modifiedStart < modifiedIndex ? m_modifiedStart : modifiedIndex;
    m_modifiedCount++;
  }

  List<DiffChange> getChanges() {
    if (m_originalCount > 0 || m_modifiedCount > 0) {
      MarkNextChange();
    }
    return m_changes;
  }

  List<DiffChange> getReverseChanges() {
    if (m_originalCount > 0 || m_modifiedCount > 0) {
      MarkNextChange();
    }
    return m_changes.reversed.toList();
  }
}

/// out 参数承载：源码 `arr[0]` 引用传递。
class _IntBox {
  int value;
  _IntBox(this.value);
}

/// out 参数承载：源码 `mergedChangeArr[0]` 引用传递。
class _ChangeBox {
  DiffChange? value;
  _ChangeBox(this.value);
}

/// 1:1: `export class LcsDiff` — Myers O(ND) diff 算法。
class LcsDiff {
  final IContinueProcessingPredicate? ContinueProcessingPredicate;

  final ISequence _originalSequence;
  final ISequence _modifiedSequence;
  final bool _hasStrings;
  final List<String> _originalStringElements;
  final Int32List _originalElementsOrHash;
  final List<String> _modifiedStringElements;
  final Int32List _modifiedElementsOrHash;

  final List<Int32List> m_forwardHistory = <Int32List>[];
  final List<Int32List> m_reverseHistory = <Int32List>[];

  /// 1:1: `constructor`
  LcsDiff(ISequence originalSequence, ISequence modifiedSequence,
      [IContinueProcessingPredicate? continueProcessingPredicate])
      : ContinueProcessingPredicate = continueProcessingPredicate,
        _originalSequence = originalSequence,
        _modifiedSequence = modifiedSequence,
        _originalStringElements = _getElements(originalSequence).$1,
        _originalElementsOrHash = _getElements(originalSequence).$2,
        _modifiedStringElements = _getElements(modifiedSequence).$1,
        _modifiedElementsOrHash = _getElements(modifiedSequence).$2,
        _hasStrings = _getElements(originalSequence).$3 && _getElements(modifiedSequence).$3;

  /// 1:1: `_isStringArray`
  static bool _isStringArray(Object arr) {
    if (arr is List<String>) return arr.isNotEmpty;
    return false;
  }

  /// 1:1: `_getElements` — 返回 `[stringElements, elementsOrHash, hasStrings]`。
  static (List<String>, Int32List, bool) _getElements(ISequence sequence) {
    final Object elements = sequence.getElements();

    if (_isStringArray(elements)) {
      final List<String> strElements = elements as List<String>;
      final Int32List hashes = Int32List(strElements.length);
      for (int i = 0, len = strElements.length; i < len; i++) {
        hashes[i] = stringHash(strElements[i], 0);
      }
      return (strElements, hashes, true);
    }

    if (elements is Int32List) {
      return (<String>[], elements, false);
    }

    if (elements is List<int>) {
      return (<String>[], Int32List.fromList(elements), false);
    }

    throw StateError('Unexpected sequence element type: ${elements.runtimeType}');
  }

  bool ElementsAreEqual(int originalIndex, int newIndex) {
    if (_originalElementsOrHash[originalIndex] != _modifiedElementsOrHash[newIndex]) {
      return false;
    }
    return _hasStrings
        ? _originalStringElements[originalIndex] == _modifiedStringElements[newIndex]
        : true;
  }

  bool ElementsAreStrictEqual(int originalIndex, int newIndex) {
    if (!ElementsAreEqual(originalIndex, newIndex)) {
      return false;
    }
    final String? originalElement = _getStrictElement(_originalSequence, originalIndex);
    final String? modifiedElement = _getStrictElement(_modifiedSequence, newIndex);
    return originalElement == modifiedElement;
  }

  static String? _getStrictElement(ISequence sequence, int index) {
    // 源码检测 `typeof getStrictElement === 'function'`，Dart 接口默认返回 null 即等价。
    return sequence.getStrictElement(index);
  }

  bool OriginalElementsAreEqual(int index1, int index2) {
    if (_originalElementsOrHash[index1] != _originalElementsOrHash[index2]) {
      return false;
    }
    return _hasStrings
        ? _originalStringElements[index1] == _originalStringElements[index2]
        : true;
  }

  bool ModifiedElementsAreEqual(int index1, int index2) {
    if (_modifiedElementsOrHash[index1] != _modifiedElementsOrHash[index2]) {
      return false;
    }
    return _hasStrings
        ? _modifiedStringElements[index1] == _modifiedStringElements[index2]
        : true;
  }

  /// 1:1: `ComputeDiff`
  IDiffResult ComputeDiff(bool pretty) =>
      _ComputeDiff(0, _originalElementsOrHash.length - 1, 0, _modifiedElementsOrHash.length - 1, pretty);

  IDiffResult _ComputeDiff(int originalStart, int originalEnd, int modifiedStart, int modifiedEnd, bool pretty) {
    final _IntBox quitEarlyArr = _IntBox(0);
    List<DiffChange> changes = ComputeDiffRecursive(originalStart, originalEnd, modifiedStart, modifiedEnd, quitEarlyArr);

    if (pretty) {
      changes = PrettifyChanges(changes);
    }

    return IDiffResult(quitEarlyArr.value != 0, changes);
  }

  /// 1:1: `ComputeDiffRecursive`
  List<DiffChange> ComputeDiffRecursive(int originalStart, int originalEnd, int modifiedStart, int modifiedEnd, _IntBox quitEarlyArr) {
    quitEarlyArr.value = 0;

    while (originalStart <= originalEnd && modifiedStart <= modifiedEnd &&
        ElementsAreEqual(originalStart, modifiedStart)) {
      originalStart++;
      modifiedStart++;
    }
    while (originalEnd >= originalStart && modifiedEnd >= modifiedStart &&
        ElementsAreEqual(originalEnd, modifiedEnd)) {
      originalEnd--;
      modifiedEnd--;
    }

    if (originalStart > originalEnd || modifiedStart > modifiedEnd) {
      late final List<DiffChange> changes;
      if (modifiedStart <= modifiedEnd) {
        Debug.Assert(originalStart == originalEnd + 1, 'originalStart should only be one more than originalEnd');
        changes = <DiffChange>[
          DiffChange(originalStart, 0, modifiedStart, modifiedEnd - modifiedStart + 1),
        ];
      } else if (originalStart <= originalEnd) {
        Debug.Assert(modifiedStart == modifiedEnd + 1, 'modifiedStart should only be one more than modifiedEnd');
        changes = <DiffChange>[
          DiffChange(originalStart, originalEnd - originalStart + 1, modifiedStart, 0),
        ];
      } else {
        changes = <DiffChange>[];
      }
      return changes;
    }

    final _IntBox midOriginalArr = _IntBox(0);
    final _IntBox midModifiedArr = _IntBox(0);
    final List<DiffChange>? result = ComputeRecursionPoint(
        originalStart, originalEnd, modifiedStart, modifiedEnd,
        midOriginalArr, midModifiedArr, quitEarlyArr);

    final int midOriginal = midOriginalArr.value;
    final int midModified = midModifiedArr.value;

    if (result != null) {
      return result;
    } else if (quitEarlyArr.value == 0) {
      final List<DiffChange> leftChanges =
          ComputeDiffRecursive(originalStart, midOriginal, modifiedStart, midModified, quitEarlyArr);
      late final List<DiffChange> rightChanges;
      if (quitEarlyArr.value == 0) {
        rightChanges = ComputeDiffRecursive(midOriginal + 1, originalEnd, midModified + 1, modifiedEnd, quitEarlyArr);
      } else {
        rightChanges = <DiffChange>[
          DiffChange(midOriginal + 1, originalEnd - (midOriginal + 1) + 1,
              midModified + 1, modifiedEnd - (midModified + 1) + 1),
        ];
      }
      return ConcatenateChanges(leftChanges, rightChanges);
    }

    return <DiffChange>[
      DiffChange(originalStart, originalEnd - originalStart + 1,
          modifiedStart, modifiedEnd - modifiedStart + 1),
    ];
  }


  /// 1:1: `WALKTRACE`
  List<DiffChange> WALKTRACE(
      int diagonalForwardBase, int diagonalForwardStart, int diagonalForwardEnd, int diagonalForwardOffset,
      int diagonalReverseBase, int diagonalReverseStart, int diagonalReverseEnd, int diagonalReverseOffset,
      Int32List forwardPoints, Int32List reversePoints,
      int originalIndex, int originalEnd, _IntBox midOriginalArr,
      int modifiedIndex, int modifiedEnd, _IntBox midModifiedArr,
      bool deltaIsEven, _IntBox quitEarlyArr) {
    List<DiffChange>? forwardChanges;
    List<DiffChange>? reverseChanges;

    DiffChangeHelper changeHelper = DiffChangeHelper();
    int diagonalMin = diagonalForwardStart;
    int diagonalMax = diagonalForwardEnd;
    int diagonalRelative = (midOriginalArr.value - midModifiedArr.value) - diagonalForwardOffset;
    int lastOriginalIndex = Constants.MIN_SAFE_SMALL_INTEGER;
    int historyIndex = m_forwardHistory.length - 1;

    do {
      final int diagonal = diagonalRelative + diagonalForwardBase;
      if (diagonal == diagonalMin || (diagonal < diagonalMax && forwardPoints[diagonal - 1] < forwardPoints[diagonal + 1])) {
        originalIndex = forwardPoints[diagonal + 1];
        modifiedIndex = originalIndex - diagonalRelative - diagonalForwardOffset;
        if (originalIndex < lastOriginalIndex) {
          changeHelper.MarkNextChange();
        }
        lastOriginalIndex = originalIndex;
        changeHelper.AddModifiedElement(originalIndex + 1, modifiedIndex);
        diagonalRelative = (diagonal + 1) - diagonalForwardBase;
      } else {
        originalIndex = forwardPoints[diagonal - 1] + 1;
        modifiedIndex = originalIndex - diagonalRelative - diagonalForwardOffset;
        if (originalIndex < lastOriginalIndex) {
          changeHelper.MarkNextChange();
        }
        lastOriginalIndex = originalIndex - 1;
        changeHelper.AddOriginalElement(originalIndex, modifiedIndex + 1);
        diagonalRelative = (diagonal - 1) - diagonalForwardBase;
      }

      if (historyIndex >= 0) {
        forwardPoints = m_forwardHistory[historyIndex];
        diagonalForwardBase = forwardPoints[0];
        diagonalMin = 1;
        diagonalMax = forwardPoints.length - 1;
      }
    } while (--historyIndex >= -1);

    forwardChanges = changeHelper.getReverseChanges();

    if (quitEarlyArr.value != 0) {
      int originalStartPoint = midOriginalArr.value + 1;
      int modifiedStartPoint = midModifiedArr.value + 1;

      if (forwardChanges.isNotEmpty) {
        final DiffChange lastForwardChange = forwardChanges[forwardChanges.length - 1];
        originalStartPoint = originalStartPoint > lastForwardChange.getOriginalEnd() ? originalStartPoint : lastForwardChange.getOriginalEnd();
        modifiedStartPoint = modifiedStartPoint > lastForwardChange.getModifiedEnd() ? modifiedStartPoint : lastForwardChange.getModifiedEnd();
      }

      reverseChanges = <DiffChange>[
        DiffChange(originalStartPoint, originalEnd - originalStartPoint + 1,
            modifiedStartPoint, modifiedEnd - modifiedStartPoint + 1),
      ];
    } else {
      changeHelper = DiffChangeHelper();
      diagonalMin = diagonalReverseStart;
      diagonalMax = diagonalReverseEnd;
      diagonalRelative = (midOriginalArr.value - midModifiedArr.value) - diagonalReverseOffset;
      lastOriginalIndex = Constants.MAX_SAFE_SMALL_INTEGER;
      historyIndex = deltaIsEven ? m_reverseHistory.length - 1 : m_reverseHistory.length - 2;

      do {
        final int diagonal = diagonalRelative + diagonalReverseBase;
        if (diagonal == diagonalMin || (diagonal < diagonalMax && reversePoints[diagonal - 1] >= reversePoints[diagonal + 1])) {
          originalIndex = reversePoints[diagonal + 1] - 1;
          modifiedIndex = originalIndex - diagonalRelative - diagonalReverseOffset;
          if (originalIndex > lastOriginalIndex) {
            changeHelper.MarkNextChange();
          }
          lastOriginalIndex = originalIndex + 1;
          changeHelper.AddOriginalElement(originalIndex + 1, modifiedIndex + 1);
          diagonalRelative = (diagonal + 1) - diagonalReverseBase;
        } else {
          originalIndex = reversePoints[diagonal - 1];
          modifiedIndex = originalIndex - diagonalRelative - diagonalReverseOffset;
          if (originalIndex > lastOriginalIndex) {
            changeHelper.MarkNextChange();
          }
          lastOriginalIndex = originalIndex;
          changeHelper.AddModifiedElement(originalIndex + 1, modifiedIndex + 1);
          diagonalRelative = (diagonal - 1) - diagonalReverseBase;
        }

        if (historyIndex >= 0) {
          reversePoints = m_reverseHistory[historyIndex];
          diagonalReverseBase = reversePoints[0];
          diagonalMin = 1;
          diagonalMax = reversePoints.length - 1;
        }
      } while (--historyIndex >= -1);

      reverseChanges = changeHelper.getChanges();
    }

    return ConcatenateChanges(forwardChanges, reverseChanges);
  }

  /// 1:1: `ComputeRecursionPoint`
  List<DiffChange>? ComputeRecursionPoint(
      int originalStart, int originalEnd, int modifiedStart, int modifiedEnd,
      _IntBox midOriginalArr, _IntBox midModifiedArr, _IntBox quitEarlyArr) {
    int originalIndex = 0, modifiedIndex = 0;
    int diagonalForwardStart = 0, diagonalForwardEnd = 0;
    int diagonalReverseStart = 0, diagonalReverseEnd = 0;

    originalStart--;
    modifiedStart--;

    midOriginalArr.value = 0;
    midModifiedArr.value = 0;

    m_forwardHistory.clear();
    m_reverseHistory.clear();

    final int maxDifferences = (originalEnd - originalStart) + (modifiedEnd - modifiedStart);
    final int numDiagonals = maxDifferences + 1;
    final Int32List forwardPoints = Int32List(numDiagonals);
    final Int32List reversePoints = Int32List(numDiagonals);

    final int diagonalForwardBase = (modifiedEnd - modifiedStart);
    final int diagonalReverseBase = (originalEnd - originalStart);
    final int diagonalForwardOffset = (originalStart - modifiedStart);
    final int diagonalReverseOffset = (originalEnd - modifiedEnd);

    final int delta = diagonalReverseBase - diagonalForwardBase;
    final bool deltaIsEven = (delta % 2 == 0);

    forwardPoints[diagonalForwardBase] = originalStart;
    reversePoints[diagonalReverseBase] = originalEnd;

    quitEarlyArr.value = 0;

    for (int numDifferences = 1; numDifferences <= (maxDifferences / 2) + 1; numDifferences++) {
      int furthestOriginalIndex = 0;
      int furthestModifiedIndex = 0;

      diagonalForwardStart = ClipDiagonalBound(diagonalForwardBase - numDifferences, numDifferences, diagonalForwardBase, numDiagonals);
      diagonalForwardEnd = ClipDiagonalBound(diagonalForwardBase + numDifferences, numDifferences, diagonalForwardBase, numDiagonals);
      for (int diagonal = diagonalForwardStart; diagonal <= diagonalForwardEnd; diagonal += 2) {
        if (diagonal == diagonalForwardStart || (diagonal < diagonalForwardEnd && forwardPoints[diagonal - 1] < forwardPoints[diagonal + 1])) {
          originalIndex = forwardPoints[diagonal + 1];
        } else {
          originalIndex = forwardPoints[diagonal - 1] + 1;
        }
        modifiedIndex = originalIndex - (diagonal - diagonalForwardBase) - diagonalForwardOffset;

        final int tempOriginalIndex = originalIndex;

        while (originalIndex < originalEnd && modifiedIndex < modifiedEnd &&
            ElementsAreEqual(originalIndex + 1, modifiedIndex + 1)) {
          originalIndex++;
          modifiedIndex++;
        }
        forwardPoints[diagonal] = originalIndex;

        if (originalIndex + modifiedIndex > furthestOriginalIndex + furthestModifiedIndex) {
          furthestOriginalIndex = originalIndex;
          furthestModifiedIndex = modifiedIndex;
        }

        if (!deltaIsEven && (diagonal - diagonalReverseBase).abs() <= (numDifferences - 1)) {
          if (originalIndex >= reversePoints[diagonal]) {
            midOriginalArr.value = originalIndex;
            midModifiedArr.value = modifiedIndex;

            if (tempOriginalIndex <= reversePoints[diagonal] &&
                LocalConstants.MaxDifferencesHistory > 0 &&
                numDifferences <= (LocalConstants.MaxDifferencesHistory + 1)) {
              return WALKTRACE(diagonalForwardBase, diagonalForwardStart, diagonalForwardEnd, diagonalForwardOffset,
                  diagonalReverseBase, diagonalReverseStart, diagonalReverseEnd, diagonalReverseOffset,
                  forwardPoints, reversePoints,
                  originalIndex, originalEnd, midOriginalArr,
                  modifiedIndex, modifiedEnd, midModifiedArr,
                  deltaIsEven, quitEarlyArr);
            } else {
              return null;
            }
          }
        }
      }

      final num matchLengthOfLongest = ((furthestOriginalIndex - originalStart) + (furthestModifiedIndex - modifiedStart) - numDifferences) / 2;

      final IContinueProcessingPredicate? predicate = ContinueProcessingPredicate;
      if (predicate != null && !predicate(furthestOriginalIndex, matchLengthOfLongest)) {
        quitEarlyArr.value = 1;
        midOriginalArr.value = furthestOriginalIndex;
        midModifiedArr.value = furthestModifiedIndex;

        if (matchLengthOfLongest > 0 &&
            LocalConstants.MaxDifferencesHistory > 0 &&
            numDifferences <= (LocalConstants.MaxDifferencesHistory + 1)) {
          return WALKTRACE(diagonalForwardBase, diagonalForwardStart, diagonalForwardEnd, diagonalForwardOffset,
              diagonalReverseBase, diagonalReverseStart, diagonalReverseEnd, diagonalReverseOffset,
              forwardPoints, reversePoints,
              originalIndex, originalEnd, midOriginalArr,
              modifiedIndex, modifiedEnd, midModifiedArr,
              deltaIsEven, quitEarlyArr);
        } else {
          originalStart++;
          modifiedStart++;
          return <DiffChange>[
            DiffChange(originalStart, originalEnd - originalStart + 1,
                modifiedStart, modifiedEnd - modifiedStart + 1),
          ];
        }
      }

      diagonalReverseStart = ClipDiagonalBound(diagonalReverseBase - numDifferences, numDifferences, diagonalReverseBase, numDiagonals);
      diagonalReverseEnd = ClipDiagonalBound(diagonalReverseBase + numDifferences, numDifferences, diagonalReverseBase, numDiagonals);
      for (int diagonal = diagonalReverseStart; diagonal <= diagonalReverseEnd; diagonal += 2) {
        if (diagonal == diagonalReverseStart || (diagonal < diagonalReverseEnd && reversePoints[diagonal - 1] >= reversePoints[diagonal + 1])) {
          originalIndex = reversePoints[diagonal + 1] - 1;
        } else {
          originalIndex = reversePoints[diagonal - 1];
        }
        modifiedIndex = originalIndex - (diagonal - diagonalReverseBase) - diagonalReverseOffset;

        final int tempOriginalIndex = originalIndex;

        while (originalIndex > originalStart && modifiedIndex > modifiedStart &&
            ElementsAreEqual(originalIndex, modifiedIndex)) {
          originalIndex--;
          modifiedIndex--;
        }
        reversePoints[diagonal] = originalIndex;

        if (deltaIsEven && (diagonal - diagonalForwardBase).abs() <= numDifferences) {
          if (originalIndex <= forwardPoints[diagonal]) {
            midOriginalArr.value = originalIndex;
            midModifiedArr.value = modifiedIndex;

            if (tempOriginalIndex >= forwardPoints[diagonal] &&
                LocalConstants.MaxDifferencesHistory > 0 &&
                numDifferences <= (LocalConstants.MaxDifferencesHistory + 1)) {
              return WALKTRACE(diagonalForwardBase, diagonalForwardStart, diagonalForwardEnd, diagonalForwardOffset,
                  diagonalReverseBase, diagonalReverseStart, diagonalReverseEnd, diagonalReverseOffset,
                  forwardPoints, reversePoints,
                  originalIndex, originalEnd, midOriginalArr,
                  modifiedIndex, modifiedEnd, midModifiedArr,
                  deltaIsEven, quitEarlyArr);
            } else {
              return null;
            }
          }
        }
      }

      if (numDifferences <= LocalConstants.MaxDifferencesHistory) {
        Int32List temp = Int32List(diagonalForwardEnd - diagonalForwardStart + 2);
        temp[0] = diagonalForwardBase - diagonalForwardStart + 1;
        MyArray.Copy2(forwardPoints, diagonalForwardStart, temp, 1, diagonalForwardEnd - diagonalForwardStart + 1);
        m_forwardHistory.add(temp);

        temp = Int32List(diagonalReverseEnd - diagonalReverseStart + 2);
        temp[0] = diagonalReverseBase - diagonalReverseStart + 1;
        MyArray.Copy2(reversePoints, diagonalReverseStart, temp, 1, diagonalReverseEnd - diagonalReverseStart + 1);
        m_reverseHistory.add(temp);
      }
    }

    return WALKTRACE(diagonalForwardBase, diagonalForwardStart, diagonalForwardEnd, diagonalForwardOffset,
        diagonalReverseBase, diagonalReverseStart, diagonalReverseEnd, diagonalReverseOffset,
        forwardPoints, reversePoints,
        originalIndex, originalEnd, midOriginalArr,
        modifiedIndex, modifiedEnd, midModifiedArr,
        deltaIsEven, quitEarlyArr);
  }

  /// 1:1: `PrettifyChanges`
  List<DiffChange> PrettifyChanges(List<DiffChange> changes) {
    for (int i = 0; i < changes.length; i++) {
      final DiffChange change = changes[i];
      final int originalStop = (i < changes.length - 1) ? changes[i + 1].originalStart : _originalElementsOrHash.length;
      final int modifiedStop = (i < changes.length - 1) ? changes[i + 1].modifiedStart : _modifiedElementsOrHash.length;
      final bool checkOriginal = change.originalLength > 0;
      final bool checkModified = change.modifiedLength > 0;

      while (
        change.originalStart + change.originalLength < originalStop &&
        change.modifiedStart + change.modifiedLength < modifiedStop &&
        (!checkOriginal || OriginalElementsAreEqual(change.originalStart, change.originalStart + change.originalLength)) &&
        (!checkModified || ModifiedElementsAreEqual(change.modifiedStart, change.modifiedStart + change.modifiedLength))
      ) {
        final bool startStrictEqual = ElementsAreStrictEqual(change.originalStart, change.modifiedStart);
        final bool endStrictEqual = ElementsAreStrictEqual(change.originalStart + change.originalLength, change.modifiedStart + change.modifiedLength);
        if (endStrictEqual && !startStrictEqual) {
          break;
        }
        change.originalStart++;
        change.modifiedStart++;
      }

      final _ChangeBox mergedChangeArr = _ChangeBox(null);
      if (i < changes.length - 1 && ChangesOverlap(changes[i], changes[i + 1], mergedChangeArr)) {
        changes[i] = mergedChangeArr.value!;
        changes.removeAt(i + 1);
        i--;
        continue;
      }
    }

    for (int i = changes.length - 1; i >= 0; i--) {
      final DiffChange change = changes[i];

      int originalStop = 0;
      int modifiedStop = 0;
      if (i > 0) {
        final DiffChange prevChange = changes[i - 1];
        originalStop = prevChange.originalStart + prevChange.originalLength;
        modifiedStop = prevChange.modifiedStart + prevChange.modifiedLength;
      }

      final bool checkOriginal = change.originalLength > 0;
      final bool checkModified = change.modifiedLength > 0;

      int bestDelta = 0;
      int bestScore = _boundaryScore(change.originalStart, change.originalLength, change.modifiedStart, change.modifiedLength);

      for (int delta = 1; ; delta++) {
        final int originalStart = change.originalStart - delta;
        final int modifiedStart = change.modifiedStart - delta;

        if (originalStart < originalStop || modifiedStart < modifiedStop) {
          break;
        }
        if (checkOriginal && !OriginalElementsAreEqual(originalStart, originalStart + change.originalLength)) {
          break;
        }
        if (checkModified && !ModifiedElementsAreEqual(modifiedStart, modifiedStart + change.modifiedLength)) {
          break;
        }

        final bool touchingPreviousChange = (originalStart == originalStop && modifiedStart == modifiedStop);
        final int score = (touchingPreviousChange ? 5 : 0) +
            _boundaryScore(originalStart, change.originalLength, modifiedStart, change.modifiedLength);

        if (score > bestScore) {
          bestScore = score;
          bestDelta = delta;
        }
      }

      change.originalStart -= bestDelta;
      change.modifiedStart -= bestDelta;

      final _ChangeBox mergedChangeArr = _ChangeBox(null);
      if (i > 0 && ChangesOverlap(changes[i - 1], changes[i], mergedChangeArr)) {
        changes[i - 1] = mergedChangeArr.value!;
        changes.removeAt(i);
        i++;
        continue;
      }
    }

    if (_hasStrings) {
      for (int i = 1, len = changes.length; i < len; i++) {
        final DiffChange aChange = changes[i - 1];
        final DiffChange bChange = changes[i];
        final int matchedLength = bChange.originalStart - aChange.originalStart - aChange.originalLength;
        final int aOriginalStart = aChange.originalStart;
        final int bOriginalEnd = bChange.originalStart + bChange.originalLength;
        final int abOriginalLength = bOriginalEnd - aOriginalStart;
        final int aModifiedStart = aChange.modifiedStart;
        final int bModifiedEnd = bChange.modifiedStart + bChange.modifiedLength;
        final int abModifiedLength = bModifiedEnd - aModifiedStart;
        if (matchedLength < 5 && abOriginalLength < 20 && abModifiedLength < 20) {
          final (int, int)? t = _findBetterContiguousSequence(
              aOriginalStart, abOriginalLength, aModifiedStart, abModifiedLength, matchedLength);
          if (t != null) {
            final int originalMatchStart = t.$1;
            final int modifiedMatchStart = t.$2;
            if (originalMatchStart != aChange.originalStart + aChange.originalLength ||
                modifiedMatchStart != aChange.modifiedStart + aChange.modifiedLength) {
              aChange.originalLength = originalMatchStart - aChange.originalStart;
              aChange.modifiedLength = modifiedMatchStart - aChange.modifiedStart;
              bChange.originalStart = originalMatchStart + matchedLength;
              bChange.modifiedStart = modifiedMatchStart + matchedLength;
              bChange.originalLength = bOriginalEnd - bChange.originalStart;
              bChange.modifiedLength = bModifiedEnd - bChange.modifiedStart;
            }
          }
        }
      }
    }

    return changes;
  }

  /// 1:1: `_findBetterContiguousSequence`
  (int, int)? _findBetterContiguousSequence(int originalStart, int originalLength, int modifiedStart, int modifiedLength, int desiredLength) {
    if (originalLength < desiredLength || modifiedLength < desiredLength) {
      return null;
    }
    final int originalMax = originalStart + originalLength - desiredLength + 1;
    final int modifiedMax = modifiedStart + modifiedLength - desiredLength + 1;
    int bestScore = 0;
    int bestOriginalStart = 0;
    int bestModifiedStart = 0;
    for (int i = originalStart; i < originalMax; i++) {
      for (int j = modifiedStart; j < modifiedMax; j++) {
        final int score = _contiguousSequenceScore(i, j, desiredLength);
        if (score > 0 && score > bestScore) {
          bestScore = score;
          bestOriginalStart = i;
          bestModifiedStart = j;
        }
      }
    }
    if (bestScore > 0) {
      return (bestOriginalStart, bestModifiedStart);
    }
    return null;
  }

  /// 1:1: `_contiguousSequenceScore`
  int _contiguousSequenceScore(int originalStart, int modifiedStart, int length) {
    int score = 0;
    for (int l = 0; l < length; l++) {
      if (!ElementsAreEqual(originalStart + l, modifiedStart + l)) {
        return 0;
      }
      score += _originalStringElements[originalStart + l].length;
    }
    return score;
  }

  /// 1:1: `_OriginalIsBoundary`
  bool _OriginalIsBoundary(int index) {
    if (index <= 0 || index >= _originalElementsOrHash.length - 1) {
      return true;
    }
    return _hasStrings && RegExp(r'^\s*$').hasMatch(_originalStringElements[index]);
  }

  /// 1:1: `_OriginalRegionIsBoundary`
  bool _OriginalRegionIsBoundary(int originalStart, int originalLength) {
    if (_OriginalIsBoundary(originalStart) || _OriginalIsBoundary(originalStart - 1)) {
      return true;
    }
    if (originalLength > 0) {
      final int originalEnd = originalStart + originalLength;
      if (_OriginalIsBoundary(originalEnd - 1) || _OriginalIsBoundary(originalEnd)) {
        return true;
      }
    }
    return false;
  }

  /// 1:1: `_ModifiedIsBoundary`
  bool _ModifiedIsBoundary(int index) {
    if (index <= 0 || index >= _modifiedElementsOrHash.length - 1) {
      return true;
    }
    return _hasStrings && RegExp(r'^\s*$').hasMatch(_modifiedStringElements[index]);
  }

  /// 1:1: `_ModifiedRegionIsBoundary`
  bool _ModifiedRegionIsBoundary(int modifiedStart, int modifiedLength) {
    if (_ModifiedIsBoundary(modifiedStart) || _ModifiedIsBoundary(modifiedStart - 1)) {
      return true;
    }
    if (modifiedLength > 0) {
      final int modifiedEnd = modifiedStart + modifiedLength;
      if (_ModifiedIsBoundary(modifiedEnd - 1) || _ModifiedIsBoundary(modifiedEnd)) {
        return true;
      }
    }
    return false;
  }

  /// 1:1: `_boundaryScore`
  int _boundaryScore(int originalStart, int originalLength, int modifiedStart, int modifiedLength) {
    final int originalScore = _OriginalRegionIsBoundary(originalStart, originalLength) ? 1 : 0;
    final int modifiedScore = _ModifiedRegionIsBoundary(modifiedStart, modifiedLength) ? 1 : 0;
    return originalScore + modifiedScore;
  }

  /// 1:1: `ConcatenateChanges`
  List<DiffChange> ConcatenateChanges(List<DiffChange> left, List<DiffChange> right) {
    final _ChangeBox mergedChangeArr = _ChangeBox(null);

    if (left.isEmpty || right.isEmpty) {
      return right.isNotEmpty ? right : left;
    } else if (ChangesOverlap(left[left.length - 1], right[0], mergedChangeArr)) {
      final List<DiffChange> result = List<DiffChange>.filled(left.length + right.length - 1, left[0], growable: true);
      MyArray.Copy(left, 0, result, 0, left.length - 1);
      result[left.length - 1] = mergedChangeArr.value!;
      MyArray.Copy(right, 1, result, left.length, right.length - 1);
      return result;
    } else {
      final List<DiffChange> result = List<DiffChange>.filled(left.length + right.length, left[0], growable: true);
      MyArray.Copy(left, 0, result, 0, left.length);
      MyArray.Copy(right, 0, result, left.length, right.length);
      return result;
    }
  }

  /// 1:1: `ChangesOverlap`
  bool ChangesOverlap(DiffChange left, DiffChange right, _ChangeBox mergedChangeArr) {
    Debug.Assert(left.originalStart <= right.originalStart, 'Left change is not less than or equal to right change');
    Debug.Assert(left.modifiedStart <= right.modifiedStart, 'Left change is not less than or equal to right change');

    if (left.originalStart + left.originalLength >= right.originalStart ||
        left.modifiedStart + left.modifiedLength >= right.modifiedStart) {
      final int originalStart = left.originalStart;
      int originalLength = left.originalLength;
      final int modifiedStart = left.modifiedStart;
      int modifiedLength = left.modifiedLength;

      if (left.originalStart + left.originalLength >= right.originalStart) {
        originalLength = right.originalStart + right.originalLength - left.originalStart;
      }
      if (left.modifiedStart + left.modifiedLength >= right.modifiedStart) {
        modifiedLength = right.modifiedStart + right.modifiedLength - left.modifiedStart;
      }

      mergedChangeArr.value = DiffChange(originalStart, originalLength, modifiedStart, modifiedLength);
      return true;
    } else {
      mergedChangeArr.value = null;
      return false;
    }
  }

  /// 1:1: `ClipDiagonalBound`
  int ClipDiagonalBound(int diagonal, int numDifferences, int diagonalBaseIndex, int numDiagonals) {
    if (diagonal >= 0 && diagonal < numDiagonals) {
      return diagonal;
    }

    final int diagonalsBelow = diagonalBaseIndex;
    final int diagonalsAbove = numDiagonals - diagonalBaseIndex - 1;
    final bool diffEven = (numDifferences % 2 == 0);

    if (diagonal < 0) {
      final bool lowerBoundEven = (diagonalsBelow % 2 == 0);
      return (diffEven == lowerBoundEven) ? 0 : 1;
    } else {
      final bool upperBoundEven = (diagonalsAbove % 2 == 0);
      return (diffEven == upperBoundEven) ? numDiagonals - 1 : numDiagonals - 2;
    }
  }
}

/// 1:1: `const precomputedEqualityArray = new Uint32Array(0x10000)`
final Uint32List precomputedEqualityArray = Uint32List(0x10000);

/// 1:1: `computeLevenshteinDistanceForShortStrings`
int computeLevenshteinDistanceForShortStrings(String firstString, String secondString) {
  final int firstStringLength = firstString.length;
  final int secondStringLength = secondString.length;
  final int lastBitMask = 1 << (firstStringLength - 1);
  int positiveVector = -1;
  int negativeVector = 0;
  int distance = firstStringLength;
  int index = firstStringLength;

  while (index-- > 0) {
    precomputedEqualityArray[firstString.codeUnitAt(index)] |= 1 << index;
  }

  for (index = 0; index < secondStringLength; index++) {
    int equalityMask = precomputedEqualityArray[secondString.codeUnitAt(index)];
    final int combinedVector = equalityMask | negativeVector;
    equalityMask |= ((equalityMask & positiveVector) + positiveVector) ^ positiveVector;
    negativeVector |= _bitnot(equalityMask | positiveVector);
    positiveVector &= equalityMask;
    if (negativeVector & lastBitMask != 0) {
      distance++;
    }
    if (positiveVector & lastBitMask != 0) {
      distance--;
    }
    negativeVector = _shl(negativeVector, 1) | 1;
    positiveVector = _shl(positiveVector, 1) | _bitnot(combinedVector | negativeVector);
    negativeVector &= combinedVector;
  }

  index = firstStringLength;
  while (index-- > 0) {
    precomputedEqualityArray[firstString.codeUnitAt(index)] = 0;
  }

  return distance;
}

/// 1:1: `computeLevenshteinDistanceForLongStrings`
int computeLevenshteinDistanceForLongStrings(String firstString, String secondString) {
  final int firstStringLength = firstString.length;
  final int secondStringLength = secondString.length;
  final List<int> horizontalBitArray = <int>[];
  final List<int> verticalBitArray = <int>[];
  final int horizontalSize = (firstStringLength / 32).ceil();
  final int verticalSize = (secondStringLength / 32).ceil();

  for (int i = 0; i < horizontalSize; i++) {
    horizontalBitArray.add(-1);
    verticalBitArray.add(0);
  }

  int verticalIndex = 0;
  for (; verticalIndex < verticalSize - 1; verticalIndex++) {
    int negativeVector = 0;
    int positiveVector = -1;
    final int start = verticalIndex * 32;
    final int verticalLength = (32 < secondStringLength ? 32 : secondStringLength) + start;

    for (int k = start; k < verticalLength; k++) {
      precomputedEqualityArray[secondString.codeUnitAt(k)] |= 1 << (k % 32);
    }

    for (int i = 0; i < firstStringLength; i++) {
      final int equalityMask = precomputedEqualityArray[firstString.codeUnitAt(i)];
      final int previousBit = (_ushr(horizontalBitArray[i >> 5], i % 32)) & 1;
      final int matchBit = (_ushr(verticalBitArray[i >> 5], i % 32)) & 1;
      final int combinedVector = equalityMask | negativeVector;
      final int combinedHorizontalVector = ((((equalityMask | matchBit) & positiveVector) + positiveVector) ^ positiveVector) | equalityMask | matchBit;
      int positiveHorizontalVector = negativeVector | _bitnot(combinedHorizontalVector | positiveVector);
      int negativeHorizontalVector = positiveVector & combinedHorizontalVector;
      if ((_ushr(positiveHorizontalVector, 31)) ^ previousBit != 0) {
        horizontalBitArray[i >> 5] ^= 1 << (i % 32);
      }
      if ((_ushr(negativeHorizontalVector, 31)) ^ matchBit != 0) {
        verticalBitArray[i >> 5] ^= 1 << (i % 32);
      }
      positiveHorizontalVector = _shl(positiveHorizontalVector, 1) | previousBit;
      negativeHorizontalVector = _shl(negativeHorizontalVector, 1) | matchBit;
      positiveVector = negativeHorizontalVector | _bitnot(combinedVector | positiveHorizontalVector);
      negativeVector = positiveHorizontalVector & combinedVector;
    }

    for (int k = start; k < verticalLength; k++) {
      precomputedEqualityArray[secondString.codeUnitAt(k)] = 0;
    }
  }

  int negativeVector = 0;
  int positiveVector = -1;
  final int start = verticalIndex * 32;
  final int verticalLength = (32 < secondStringLength - start ? 32 : secondStringLength - start) + start;

  for (int k = start; k < verticalLength; k++) {
    precomputedEqualityArray[secondString.codeUnitAt(k)] |= 1 << (k % 32);
  }

  int distance = secondStringLength;

  for (int i = 0; i < firstStringLength; i++) {
    final int equalityMask = precomputedEqualityArray[firstString.codeUnitAt(i)];
    final int previousBit = (_ushr(horizontalBitArray[i >> 5], i % 32)) & 1;
    final int matchBit = (_ushr(verticalBitArray[i >> 5], i % 32)) & 1;
    final int combinedVector = equalityMask | negativeVector;
    final int combinedHorizontalVector = ((((equalityMask | matchBit) & positiveVector) + positiveVector) ^ positiveVector) | equalityMask | matchBit;
    int positiveHorizontalVector = negativeVector | _bitnot(combinedHorizontalVector | positiveVector);
    int negativeHorizontalVector = positiveVector & combinedHorizontalVector;
    distance += (_ushr(positiveHorizontalVector, (secondStringLength - 1) % 32)) & 1;
    distance -= (_ushr(negativeHorizontalVector, (secondStringLength - 1) % 32)) & 1;
    if ((_ushr(positiveHorizontalVector, 31)) ^ previousBit != 0) {
      horizontalBitArray[i >> 5] ^= 1 << (i % 32);
    }
    if ((_ushr(negativeHorizontalVector, 31)) ^ matchBit != 0) {
      verticalBitArray[i >> 5] ^= 1 << (i % 32);
    }
    positiveHorizontalVector = _shl(positiveHorizontalVector, 1) | previousBit;
    negativeHorizontalVector = _shl(negativeHorizontalVector, 1) | matchBit;
    positiveVector = negativeHorizontalVector | _bitnot(combinedVector | positiveHorizontalVector);
    negativeVector = positiveHorizontalVector & combinedVector;
  }

  for (int k = start; k < verticalLength; k++) {
    precomputedEqualityArray[secondString.codeUnitAt(k)] = 0;
  }

  return distance;
}

/// 1:1: `export function computeLevenshteinDistance`
int computeLevenshteinDistance(String firstString, String secondString) {
  if (firstString.length < secondString.length) {
    final String temp = secondString;
    secondString = firstString;
    firstString = temp;
  }
  if (secondString.isEmpty) {
    return firstString.length;
  }
  if (firstString.length <= 32) {
    return computeLevenshteinDistanceForShortStrings(firstString, secondString);
  }
  return computeLevenshteinDistanceForLongStrings(firstString, secondString);
}
