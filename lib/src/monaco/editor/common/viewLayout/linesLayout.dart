// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewLayout/linesLayout.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * TS interfaces from `viewModel.ts` are erased to concrete carriers
//    (repo convention for erased interfaces).
//  * `number` -> `num`; JS `| 0` -> `.toInt()`, `>>> 1` -> `>> 1`.
//  * `Array.prototype.sort` is stable in JS but `List.sort` is not in Dart;
//    the rebuild path sorts by (afterLineNumber, ordinal, original index).
//  * `Array.splice` -> `List.insert` / `List.removeAt`.
// ---------------------------------------------------------------------------

import '../../../base/common/strings.dart' show singleLetterHash;
import 'lineHeights.dart' show CustomLineHeightData, LineHeightsManager;

/// 1:1: `ILineHeightChangeAccessor` (from `../viewModel.ts`, erased interface).
abstract class ILineHeightChangeAccessor {
  void insertOrChangeCustomLineHeight(String decorationId, int startLineNumber,
      int endLineNumber, num lineHeight);
  void removeCustomLineHeight(String decorationId);
}

/// 1:1: `IWhitespaceChangeAccessor` (from `../viewModel.ts`, erased interface).
abstract class IWhitespaceChangeAccessor {
  String insertWhitespace(
      int afterLineNumber, int ordinal, num heightInPx, num minWidth);
  void changeOneWhitespace(String id, int newAfterLineNumber, num newHeight);
  void removeWhitespace(String id);
}

/// 1:1: `IViewWhitespaceViewportData` (from `../viewModel.ts`, erased interface).
class ViewWhitespaceViewportData {
  String id;
  int afterLineNumber;
  num verticalOffset;
  num height;

  ViewWhitespaceViewportData(
      this.id, this.afterLineNumber, this.verticalOffset, this.height);
}

/// 1:1: `IPartialViewLinesViewportData` (from `../viewModel.ts`, erased interface).
class PartialViewLinesViewportData {
  num bigNumbersDelta;
  int startLineNumber;
  int endLineNumber;
  List<num> relativeVerticalOffset;
  int centeredLineNumber;
  int completelyVisibleStartLineNumber;
  int completelyVisibleEndLineNumber;
  num lineHeight;

  PartialViewLinesViewportData(
    this.bigNumbersDelta,
    this.startLineNumber,
    this.endLineNumber,
    this.relativeVerticalOffset,
    this.centeredLineNumber,
    this.completelyVisibleStartLineNumber,
    this.completelyVisibleEndLineNumber,
    this.lineHeight,
  );
}

/// 1:1: `interface IPendingChange`.
class IPendingChange {
  String id;
  int newAfterLineNumber;
  num newHeight;

  IPendingChange(this.id, this.newAfterLineNumber, this.newHeight);
}

/// 1:1: `interface IPendingRemove`.
class IPendingRemove {
  String id;

  IPendingRemove(this.id);
}

class PendingChanges {
  bool _hasPending;
  List<EditorWhitespace> _inserts;
  List<IPendingChange> _changes;
  List<IPendingRemove> _removes;

  PendingChanges()
      : _hasPending = false,
        _inserts = <EditorWhitespace>[],
        _changes = <IPendingChange>[],
        _removes = <IPendingRemove>[];

  void insert(EditorWhitespace x) {
    _hasPending = true;
    _inserts.add(x);
  }

  void change(IPendingChange x) {
    _hasPending = true;
    _changes.add(x);
  }

  void remove(IPendingRemove x) {
    _hasPending = true;
    _removes.add(x);
  }

  void commit(LinesLayout linesLayout) {
    if (!_hasPending) {
      return;
    }

    final List<EditorWhitespace> inserts = _inserts;
    final List<IPendingChange> changes = _changes;
    final List<IPendingRemove> removes = _removes;

    _hasPending = false;
    _inserts = <EditorWhitespace>[];
    _changes = <IPendingChange>[];
    _removes = <IPendingRemove>[];

    linesLayout._commitPendingChanges(inserts, changes, removes);
  }
}

/// 1:1: `export class EditorWhitespace implements IEditorWhitespace`.
class EditorWhitespace {
  String id;
  int afterLineNumber;
  int ordinal;
  num height;
  num minWidth;
  num prefixSum;

  EditorWhitespace(
      this.id, this.afterLineNumber, this.ordinal, this.height, this.minWidth)
      : prefixSum = 0;
}

/// Layouting of objects that take vertical space (by having a height) and
/// push down other objects.
class LinesLayout {
  static int _instanceCount = 0;

  final String _instanceId;
  final PendingChanges _pendingChanges;
  int _lastWhitespaceId;
  List<EditorWhitespace> _arr;
  int _prefixSumValidIndex;
  num _minWidth;
  int _lineCount;
  num _paddingTop;
  num _paddingBottom;
  LineHeightsManager _lineHeightsManager;

  LinesLayout(int lineCount, num defaultLineHeight, num paddingTop,
      num paddingBottom, List<CustomLineHeightData> customLineHeightData)
      : _instanceId = singleLetterHash(++_instanceCount),
        _pendingChanges = PendingChanges(),
        _lastWhitespaceId = 0,
        _arr = <EditorWhitespace>[],
        _prefixSumValidIndex = -1,
        _minWidth = -1,
        _lineCount = lineCount,
        _paddingTop = paddingTop,
        _paddingBottom = paddingBottom,
        _lineHeightsManager = LineHeightsManager(
            defaultLineHeight, customLineHeightData);

  /// Find the insertion index for a new value inside a sorted array of values.
  /// If the value is already present, the insertion index is after it.
  static int findInsertionIndex(List<EditorWhitespace> arr,
      int afterLineNumber, int ordinal) {
    int low = 0;
    int high = arr.length;

    while (low < high) {
      final int mid = (low + high) >> 1;

      if (afterLineNumber == arr[mid].afterLineNumber) {
        if (ordinal < arr[mid].ordinal) {
          high = mid;
        } else {
          low = mid + 1;
        }
      } else if (afterLineNumber < arr[mid].afterLineNumber) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }

    return low;
  }

  /// Change the height of a line in pixels.
  void setDefaultLineHeight(num lineHeight) {
    _lineHeightsManager.defaultLineHeight = lineHeight;
  }

  /// Changes the padding used to calculate vertical offsets.
  void setPadding(num paddingTop, num paddingBottom) {
    _paddingTop = paddingTop;
    _paddingBottom = paddingBottom;
  }

  /// Set the number of lines.
  void onFlushed(int lineCount, List<CustomLineHeightData> customLineHeightData) {
    _lineCount = lineCount;
    _lineHeightsManager = LineHeightsManager(
        _lineHeightsManager.defaultLineHeight, customLineHeightData);
  }

  bool changeLineHeights(void Function(ILineHeightChangeAccessor) callback) {
    bool hadAChange = false;
    final ILineHeightChangeAccessor accessor = _LineHeightChangeAccessor(
      (String decorationId, int startLineNumber, int endLineNumber,
          num lineHeight) {
        hadAChange = true;
        _lineHeightsManager.insertOrChangeCustomLineHeight(
            decorationId, startLineNumber, endLineNumber, lineHeight);
      },
      (String decorationId) {
        hadAChange = true;
        _lineHeightsManager.removeCustomLineHeight(decorationId);
      },
    );
    callback(accessor);
    return hadAChange;
  }

  bool changeWhitespace(void Function(IWhitespaceChangeAccessor) callback) {
    bool hadAChange = false;
    try {
      final IWhitespaceChangeAccessor accessor = _WhitespaceChangeAccessor(
        (int afterLineNumber, int ordinal, num heightInPx, num minWidth) {
          hadAChange = true;
          afterLineNumber = afterLineNumber.toInt();
          ordinal = ordinal.toInt();
          heightInPx = heightInPx.toInt();
          minWidth = minWidth.toInt();
          final String id = _instanceId + (++_lastWhitespaceId).toString();
          _pendingChanges.insert(EditorWhitespace(
              id, afterLineNumber, ordinal, heightInPx, minWidth));
          return id;
        },
        (String id, int newAfterLineNumber, num newHeight) {
          hadAChange = true;
          newAfterLineNumber = newAfterLineNumber.toInt();
          newHeight = newHeight.toInt();
          _pendingChanges.change(
              IPendingChange(id, newAfterLineNumber, newHeight));
        },
        (String id) {
          hadAChange = true;
          _pendingChanges.remove(IPendingRemove(id));
        },
      );
      callback(accessor);
    } finally {
      _pendingChanges.commit(this);
    }
    return hadAChange;
  }

  void _commitPendingChanges(List<EditorWhitespace> inserts,
      List<IPendingChange> changes, List<IPendingRemove> removes) {
    if (inserts.isNotEmpty || removes.isNotEmpty) {
      _minWidth = -1; /* marker for not being computed */
    }

    if (inserts.length + changes.length + removes.length <= 1) {
      // when only one thing happened, handle it "delicately"
      for (final EditorWhitespace insert in inserts) {
        _insertWhitespace(insert);
      }
      for (final IPendingChange change in changes) {
        _changeOneWhitespace(
            change.id, change.newAfterLineNumber, change.newHeight);
      }
      for (final IPendingRemove remove in removes) {
        final int index = _findWhitespaceIndex(remove.id);
        if (index == -1) {
          continue;
        }
        _removeWhitespace(index);
      }
      return;
    }

    // simply rebuild the entire datastructure
    final Set<String> toRemove = <String>{};
    for (final IPendingRemove remove in removes) {
      toRemove.add(remove.id);
    }

    final Map<String, IPendingChange> toChange = <String, IPendingChange>{};
    for (final IPendingChange change in changes) {
      toChange[change.id] = change;
    }

    List<EditorWhitespace> applyRemoveAndChange(
        List<EditorWhitespace> whitespaces) {
      final List<EditorWhitespace> result = <EditorWhitespace>[];
      for (final EditorWhitespace whitespace in whitespaces) {
        if (toRemove.contains(whitespace.id)) {
          continue;
        }
        if (toChange.containsKey(whitespace.id)) {
          final IPendingChange change = toChange[whitespace.id]!;
          whitespace.afterLineNumber = change.newAfterLineNumber;
          whitespace.height = change.newHeight;
        }
        result.add(whitespace);
      }
      return result;
    }

    final List<EditorWhitespace> result = applyRemoveAndChange(_arr) +
        applyRemoveAndChange(inserts);
    // Dart: JS `Array.sort` is stable; preserve the original order on ties.
    final List<(EditorWhitespace, int)> indexed = <(EditorWhitespace, int)>[];
    for (int i = 0; i < result.length; i++) {
      indexed.add((result[i], i));
    }
    indexed.sort((a, b) {
      if (a.$1.afterLineNumber == b.$1.afterLineNumber) {
        final int ordinalCmp = a.$1.ordinal - b.$1.ordinal;
        return ordinalCmp != 0 ? ordinalCmp : a.$2 - b.$2;
      }
      return a.$1.afterLineNumber - b.$1.afterLineNumber;
    });
    _arr = indexed.map((e) => e.$1).toList();
    _prefixSumValidIndex = -1;
  }

  void _insertWhitespace(EditorWhitespace whitespace) {
    final int insertIndex = LinesLayout.findInsertionIndex(
        _arr, whitespace.afterLineNumber, whitespace.ordinal);
    _arr.insert(insertIndex, whitespace);
    _prefixSumValidIndex =
        _prefixSumValidIndex < insertIndex - 1 ? _prefixSumValidIndex : insertIndex - 1;
  }

  int _findWhitespaceIndex(String id) {
    final List<EditorWhitespace> arr = _arr;
    for (int i = 0, len = arr.length; i < len; i++) {
      if (arr[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  void _changeOneWhitespace(
      String id, int newAfterLineNumber, num newHeight) {
    final int index = _findWhitespaceIndex(id);
    if (index == -1) {
      return;
    }
    if (_arr[index].height != newHeight) {
      _arr[index].height = newHeight;
      _prefixSumValidIndex = _prefixSumValidIndex < index - 1
          ? _prefixSumValidIndex
          : index - 1;
    }
    if (_arr[index].afterLineNumber != newAfterLineNumber) {
      // `afterLineNumber` changed for this whitespace
      final EditorWhitespace whitespace = _arr[index];
      // Since changing `afterLineNumber` can trigger a reordering, remove it
      _removeWhitespace(index);
      whitespace.afterLineNumber = newAfterLineNumber;
      // And add it again
      _insertWhitespace(whitespace);
    }
  }

  void _removeWhitespace(int removeIndex) {
    _arr.removeAt(removeIndex);
    _prefixSumValidIndex = _prefixSumValidIndex < removeIndex - 1
        ? _prefixSumValidIndex
        : removeIndex - 1;
  }

  /// Notify the layouter that lines have been deleted (continuous zone).
  void onLinesDeleted(int fromLineNumber, int toLineNumber) {
    fromLineNumber = fromLineNumber.toInt();
    toLineNumber = toLineNumber.toInt();

    _lineCount -= (toLineNumber - fromLineNumber + 1);
    for (int i = 0, len = _arr.length; i < len; i++) {
      final int afterLineNumber = _arr[i].afterLineNumber;

      if (fromLineNumber <= afterLineNumber && afterLineNumber <= toLineNumber) {
        _arr[i].afterLineNumber = fromLineNumber - 1;
      } else if (afterLineNumber > toLineNumber) {
        _arr[i].afterLineNumber -= (toLineNumber - fromLineNumber + 1);
      }
    }
    _lineHeightsManager.onLinesDeleted(fromLineNumber, toLineNumber);
  }

  /// Notify the layouter that lines have been inserted (continuous zone).
  void onLinesInserted(int fromLineNumber, int toLineNumber) {
    fromLineNumber = fromLineNumber.toInt();
    toLineNumber = toLineNumber.toInt();

    _lineCount += (toLineNumber - fromLineNumber + 1);
    for (int i = 0, len = _arr.length; i < len; i++) {
      final int afterLineNumber = _arr[i].afterLineNumber;

      if (fromLineNumber <= afterLineNumber) {
        _arr[i].afterLineNumber += (toLineNumber - fromLineNumber + 1);
      }
    }
    _lineHeightsManager.onLinesInserted(fromLineNumber, toLineNumber);
  }

  /// Get the sum of all the whitespaces.
  num getWhitespacesTotalHeight() {
    if (_arr.isEmpty) {
      return 0;
    }
    return getWhitespacesAccumulatedHeight(_arr.length - 1);
  }

  /// Return the sum of heights of the whitespaces at [0..index].
  num getWhitespacesAccumulatedHeight(int index) {
    index = index.toInt();

    int startIndex = _prefixSumValidIndex + 1 > 0 ? _prefixSumValidIndex + 1 : 0;
    if (startIndex == 0) {
      _arr[0].prefixSum = _arr[0].height;
      startIndex++;
    }

    for (int i = startIndex; i <= index; i++) {
      _arr[i].prefixSum = _arr[i - 1].prefixSum + _arr[i].height;
    }
    _prefixSumValidIndex = _prefixSumValidIndex < index ? index : _prefixSumValidIndex;
    return _arr[index].prefixSum;
  }

  /// Get the sum of heights for all objects.
  num getLinesTotalHeight() {
    final num linesHeight =
        _lineHeightsManager.getAccumulatedLineHeightsIncludingLineNumber(_lineCount);
    final num whitespacesHeight = getWhitespacesTotalHeight();

    return linesHeight + whitespacesHeight + _paddingTop + _paddingBottom;
  }

  /// Returns the accumulated height of whitespaces before the given line number.
  num getWhitespaceAccumulatedHeightBeforeLineNumber(int lineNumber) {
    lineNumber = lineNumber.toInt();

    final int lastWhitespaceBeforeLineNumber =
        _findLastWhitespaceBeforeLineNumber(lineNumber);

    if (lastWhitespaceBeforeLineNumber == -1) {
      return 0;
    }

    return getWhitespacesAccumulatedHeight(lastWhitespaceBeforeLineNumber);
  }

  int _findLastWhitespaceBeforeLineNumber(int lineNumber) {
    lineNumber = lineNumber.toInt();

    final List<EditorWhitespace> arr = _arr;
    int low = 0;
    int high = arr.length - 1;

    while (low <= high) {
      final int delta = (high - low).toInt();
      final int halfDelta = (delta / 2).toInt();
      final int mid = (low + halfDelta).toInt();

      if (arr[mid].afterLineNumber < lineNumber) {
        if (mid + 1 >= arr.length || arr[mid + 1].afterLineNumber >= lineNumber) {
          return mid;
        } else {
          low = (mid + 1).toInt();
        }
      } else {
        high = (mid - 1).toInt();
      }
    }

    return -1;
  }

  int _findFirstWhitespaceAfterLineNumber(int lineNumber) {
    lineNumber = lineNumber.toInt();

    final int lastWhitespaceBeforeLineNumber =
        _findLastWhitespaceBeforeLineNumber(lineNumber);
    final int firstWhitespaceAfterLineNumber = lastWhitespaceBeforeLineNumber + 1;

    if (firstWhitespaceAfterLineNumber < _arr.length) {
      return firstWhitespaceAfterLineNumber;
    }

    return -1;
  }

  /// Find the index of the first whitespace with `afterLineNumber` >= lineNumber.
  int getFirstWhitespaceIndexAfterLineNumber(int lineNumber) {
    lineNumber = lineNumber.toInt();

    return _findFirstWhitespaceAfterLineNumber(lineNumber);
  }

  /// Get the vertical offset a certain line number.
  num getVerticalOffsetForLineNumber(int lineNumber, [bool includeViewZones = false]) {
    lineNumber = lineNumber.toInt();

    late num previousLinesHeight;
    if (lineNumber > 1) {
      previousLinesHeight = _lineHeightsManager
          .getAccumulatedLineHeightsIncludingLineNumber(lineNumber - 1);
    } else {
      previousLinesHeight = 0;
    }

    final num previousWhitespacesHeight =
        getWhitespaceAccumulatedHeightBeforeLineNumber(
            lineNumber - (includeViewZones ? 1 : 0));

    return previousLinesHeight + previousWhitespacesHeight + _paddingTop;
  }

  int getLineHeightForLineNumber(int lineNumber) {
    return _lineHeightsManager.heightForLineNumber(lineNumber);
  }

  /// Get the vertical offset after a certain line number and its line height.
  num getVerticalOffsetAfterLineNumber(int lineNumber,
      [bool includeViewZones = false]) {
    lineNumber = lineNumber.toInt();
    final num previousLinesHeight = _lineHeightsManager
        .getAccumulatedLineHeightsIncludingLineNumber(lineNumber);
    final num previousWhitespacesHeight =
        getWhitespaceAccumulatedHeightBeforeLineNumber(
            lineNumber + (includeViewZones ? 1 : 0));
    return previousLinesHeight + previousWhitespacesHeight + _paddingTop;
  }

  /// Returns if there is any whitespace in the document.
  bool hasWhitespace() {
    return getWhitespacesCount() > 0;
  }

  /// The maximum min width for all whitespaces.
  num getWhitespaceMinWidth() {
    if (_minWidth == -1) {
      num minWidth = 0;
      for (int i = 0, len = _arr.length; i < len; i++) {
        final num v = _arr[i].minWidth;
        minWidth = minWidth > v ? minWidth : v;
      }
      _minWidth = minWidth;
    }
    return _minWidth;
  }

  /// Check if `verticalOffset` is below all lines.
  bool isAfterLines(num verticalOffset) {
    final num totalHeight = getLinesTotalHeight();
    return verticalOffset > totalHeight;
  }

  bool isInTopPadding(num verticalOffset) {
    if (_paddingTop == 0) {
      return false;
    }
    return (verticalOffset < _paddingTop);
  }

  bool isInBottomPadding(num verticalOffset) {
    if (_paddingBottom == 0) {
      return false;
    }
    final num totalHeight = getLinesTotalHeight();
    return (verticalOffset >= totalHeight - _paddingBottom);
  }

  /// Find the first line number that is at or after vertical offset `verticalOffset`.
  int getLineNumberAtOrAfterVerticalOffset(num verticalOffset) {
    verticalOffset = verticalOffset.toInt();

    if (verticalOffset < 0) {
      return 1;
    }

    final int linesCount = _lineCount.toInt();
    int minLineNumber = 1;
    int maxLineNumber = linesCount;

    while (minLineNumber < maxLineNumber) {
      final int midLineNumber = ((minLineNumber + maxLineNumber) / 2).toInt();

      final int lineHeight = getLineHeightForLineNumber(midLineNumber);
      final int midLineNumberVerticalOffset =
          getVerticalOffsetForLineNumber(midLineNumber).toInt();

      if (verticalOffset >= midLineNumberVerticalOffset + lineHeight) {
        minLineNumber = midLineNumber + 1;
      } else if (verticalOffset >= midLineNumberVerticalOffset) {
        return midLineNumber;
      } else {
        maxLineNumber = midLineNumber;
      }
    }

    if (minLineNumber > linesCount) {
      return linesCount;
    }

    return minLineNumber;
  }

  /// Get all lines and their relative vertical offsets between two offsets.
  PartialViewLinesViewportData getLinesViewportData(
      num verticalOffset1, num verticalOffset2) {
    verticalOffset1 = verticalOffset1.toInt();
    verticalOffset2 = verticalOffset2.toInt();

    final int startLineNumber =
        getLineNumberAtOrAfterVerticalOffset(verticalOffset1).toInt();
    final int startLineNumberVerticalOffset =
        getVerticalOffsetForLineNumber(startLineNumber).toInt();

    int endLineNumber = _lineCount.toInt();

    int whitespaceIndex =
        getFirstWhitespaceIndexAfterLineNumber(startLineNumber).toInt();
    final int whitespaceCount = getWhitespacesCount().toInt();
    late num currentWhitespaceHeight;
    late int currentWhitespaceAfterLineNumber;

    if (whitespaceIndex == -1) {
      whitespaceIndex = whitespaceCount;
      currentWhitespaceAfterLineNumber = endLineNumber + 1;
      currentWhitespaceHeight = 0;
    } else {
      currentWhitespaceAfterLineNumber =
          getAfterLineNumberForWhitespaceIndex(whitespaceIndex).toInt();
      currentWhitespaceHeight =
          getHeightForWhitespaceIndex(whitespaceIndex);
    }

    num currentVerticalOffset = startLineNumberVerticalOffset;
    num currentLineRelativeOffset = startLineNumberVerticalOffset;

    // IE (all versions) cannot handle units above about 1,533,908 px, so
    // every 500k pixels bring numbers down
    const int stepSize = 500000;
    num bigNumbersDelta = 0;
    if (startLineNumberVerticalOffset >= stepSize) {
      bigNumbersDelta = (startLineNumberVerticalOffset / stepSize).floor() * stepSize;
      final num defaultLineHeight = _lineHeightsManager.defaultLineHeight;
      bigNumbersDelta =
          (bigNumbersDelta / defaultLineHeight).floor() * defaultLineHeight;
      currentLineRelativeOffset -= bigNumbersDelta;
    }

    final List<num> linesOffsets = <num>[];

    final num verticalCenter =
        verticalOffset1 + (verticalOffset2 - verticalOffset1) / 2;
    int centeredLineNumber = -1;

    for (int lineNumber = startLineNumber;
        lineNumber <= endLineNumber;
        lineNumber++) {
      final int lineHeight = getLineHeightForLineNumber(lineNumber);
      if (centeredLineNumber == -1) {
        final num currentLineTop = currentVerticalOffset;
        final num currentLineBottom = currentVerticalOffset + lineHeight;
        if ((currentLineTop <= verticalCenter &&
                verticalCenter < currentLineBottom) ||
            currentLineTop > verticalCenter) {
          centeredLineNumber = lineNumber;
        }
      }

      currentVerticalOffset += lineHeight;
      // Dart: JS sparse write `linesOffsets[lineNumber - startLineNumber] = v`
      // is sequential here, so `add` is equivalent.
      linesOffsets.add(currentLineRelativeOffset);

      currentLineRelativeOffset += lineHeight;
      while (currentWhitespaceAfterLineNumber == lineNumber) {
        currentLineRelativeOffset += currentWhitespaceHeight;
        currentVerticalOffset += currentWhitespaceHeight;
        whitespaceIndex++;

        if (whitespaceIndex >= whitespaceCount) {
          currentWhitespaceAfterLineNumber = endLineNumber + 1;
        } else {
          currentWhitespaceAfterLineNumber =
              getAfterLineNumberForWhitespaceIndex(whitespaceIndex).toInt();
          currentWhitespaceHeight =
              getHeightForWhitespaceIndex(whitespaceIndex);
        }
      }

      if (currentVerticalOffset >= verticalOffset2) {
        endLineNumber = lineNumber;
        break;
      }
    }

    if (centeredLineNumber == -1) {
      centeredLineNumber = endLineNumber;
    }

    final int endLineNumberVerticalOffset =
        getVerticalOffsetForLineNumber(endLineNumber).toInt();

    int completelyVisibleStartLineNumber = startLineNumber;
    int completelyVisibleEndLineNumber = endLineNumber;

    if (completelyVisibleStartLineNumber < completelyVisibleEndLineNumber) {
      if (startLineNumberVerticalOffset < verticalOffset1) {
        completelyVisibleStartLineNumber++;
      }
    }
    if (completelyVisibleStartLineNumber < completelyVisibleEndLineNumber) {
      final int endLineHeight = getLineHeightForLineNumber(endLineNumber);
      if (endLineNumberVerticalOffset + endLineHeight > verticalOffset2) {
        completelyVisibleEndLineNumber--;
      }
    }

    return PartialViewLinesViewportData(
      bigNumbersDelta,
      startLineNumber,
      endLineNumber,
      linesOffsets,
      centeredLineNumber,
      completelyVisibleStartLineNumber,
      completelyVisibleEndLineNumber,
      _lineHeightsManager.defaultLineHeight,
    );
  }

  num getVerticalOffsetForWhitespaceIndex(int whitespaceIndex) {
    whitespaceIndex = whitespaceIndex.toInt();

    final int afterLineNumber =
        getAfterLineNumberForWhitespaceIndex(whitespaceIndex);

    late num previousLinesHeight;
    if (afterLineNumber >= 1) {
      previousLinesHeight = _lineHeightsManager
          .getAccumulatedLineHeightsIncludingLineNumber(afterLineNumber);
    } else {
      previousLinesHeight = 0;
    }

    late num previousWhitespacesHeight;
    if (whitespaceIndex > 0) {
      previousWhitespacesHeight =
          getWhitespacesAccumulatedHeight(whitespaceIndex - 1);
    } else {
      previousWhitespacesHeight = 0;
    }
    return previousLinesHeight + previousWhitespacesHeight + _paddingTop;
  }

  int getWhitespaceIndexAtOrAfterVerticallOffset(num verticalOffset) {
    verticalOffset = verticalOffset.toInt();

    int minWhitespaceIndex = 0;
    int maxWhitespaceIndex = getWhitespacesCount() - 1;

    if (maxWhitespaceIndex < 0) {
      return -1;
    }

    final num maxWhitespaceVerticalOffset =
        getVerticalOffsetForWhitespaceIndex(maxWhitespaceIndex);
    final num maxWhitespaceHeight =
        getHeightForWhitespaceIndex(maxWhitespaceIndex);
    if (verticalOffset >= maxWhitespaceVerticalOffset + maxWhitespaceHeight) {
      return -1;
    }

    while (minWhitespaceIndex < maxWhitespaceIndex) {
      final int midWhitespaceIndex =
          ((minWhitespaceIndex + maxWhitespaceIndex) / 2).floor();

      final num midWhitespaceVerticalOffset =
          getVerticalOffsetForWhitespaceIndex(midWhitespaceIndex);
      final num midWhitespaceHeight =
          getHeightForWhitespaceIndex(midWhitespaceIndex);

      if (verticalOffset >= midWhitespaceVerticalOffset + midWhitespaceHeight) {
        minWhitespaceIndex = midWhitespaceIndex + 1;
      } else if (verticalOffset >= midWhitespaceVerticalOffset) {
        return midWhitespaceIndex;
      } else {
        maxWhitespaceIndex = midWhitespaceIndex;
      }
    }
    return minWhitespaceIndex;
  }

  /// Get exactly the whitespace that is layouted at `verticalOffset`.
  ViewWhitespaceViewportData? getWhitespaceAtVerticalOffset(num verticalOffset) {
    verticalOffset = verticalOffset.toInt();

    final int candidateIndex =
        getWhitespaceIndexAtOrAfterVerticallOffset(verticalOffset);

    if (candidateIndex < 0) {
      return null;
    }

    if (candidateIndex >= getWhitespacesCount()) {
      return null;
    }

    final num candidateTop =
        getVerticalOffsetForWhitespaceIndex(candidateIndex);

    if (candidateTop > verticalOffset) {
      return null;
    }

    final num candidateHeight = getHeightForWhitespaceIndex(candidateIndex);
    final String candidateId = getIdForWhitespaceIndex(candidateIndex);
    final int candidateAfterLineNumber =
        getAfterLineNumberForWhitespaceIndex(candidateIndex);

    return ViewWhitespaceViewportData(
        candidateId, candidateAfterLineNumber, candidateTop, candidateHeight);
  }

  /// Get a list of whitespaces positioned between two vertical offsets.
  List<ViewWhitespaceViewportData> getWhitespaceViewportData(
      num verticalOffset1, num verticalOffset2) {
    verticalOffset1 = verticalOffset1.toInt();
    verticalOffset2 = verticalOffset2.toInt();

    final int startIndex =
        getWhitespaceIndexAtOrAfterVerticallOffset(verticalOffset1);
    final int endIndex = getWhitespacesCount() - 1;

    if (startIndex < 0) {
      return <ViewWhitespaceViewportData>[];
    }

    final List<ViewWhitespaceViewportData> result =
        <ViewWhitespaceViewportData>[];
    for (int i = startIndex; i <= endIndex; i++) {
      final num top = getVerticalOffsetForWhitespaceIndex(i);
      final num height = getHeightForWhitespaceIndex(i);
      if (top >= verticalOffset2) {
        break;
      }

      result.add(ViewWhitespaceViewportData(
        getIdForWhitespaceIndex(i),
        getAfterLineNumberForWhitespaceIndex(i),
        top,
        height,
      ));
    }

    return result;
  }

  /// Get all whitespaces.
  List<EditorWhitespace> getWhitespaces() {
    return _arr.sublist(0);
  }

  /// The number of whitespaces.
  int getWhitespacesCount() {
    return _arr.length;
  }

  /// Get the `id` for whitespace at index `index`.
  String getIdForWhitespaceIndex(int index) {
    index = index.toInt();

    return _arr[index].id;
  }

  /// Get the `afterLineNumber` for whitespace at index `index`.
  int getAfterLineNumberForWhitespaceIndex(int index) {
    index = index.toInt();

    return _arr[index].afterLineNumber;
  }

  /// Get the `height` for whitespace at index `index`.
  num getHeightForWhitespaceIndex(int index) {
    index = index.toInt();

    return _arr[index].height;
  }
}

class _LineHeightChangeAccessor implements ILineHeightChangeAccessor {
  final void Function(String, int, int, num) _insertOrChange;
  final void Function(String) _remove;

  _LineHeightChangeAccessor(this._insertOrChange, this._remove);

  @override
  void insertOrChangeCustomLineHeight(String decorationId, int startLineNumber,
      int endLineNumber, num lineHeight) {
    _insertOrChange(decorationId, startLineNumber, endLineNumber, lineHeight);
  }

  @override
  void removeCustomLineHeight(String decorationId) {
    _remove(decorationId);
  }
}

class _WhitespaceChangeAccessor implements IWhitespaceChangeAccessor {
  final String Function(int, int, num, num) _insert;
  final void Function(String, int, num) _change;
  final void Function(String) _remove;

  _WhitespaceChangeAccessor(this._insert, this._change, this._remove);

  @override
  String insertWhitespace(
      int afterLineNumber, int ordinal, num heightInPx, num minWidth) {
    return _insert(afterLineNumber, ordinal, heightInPx, minWidth);
  }

  @override
  void changeOneWhitespace(String id, int newAfterLineNumber, num newHeight) {
    _change(id, newAfterLineNumber, newHeight);
  }

  @override
  void removeWhitespace(String id) {
    _remove(id);
  }
}
