// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/bracketPairsTextModelPart/
// bracketPairsTree/beforeEditPositionMapper.ts
// Translated 1:1 from TypeScript. `Length` is an int typedef; `TextLength`
// is a carrier; `Range.lift` returns nullable in the Dart port (source
// assumes non-null) so `!` is used. `readonly` arrays -> `List.unmodifiable`.
// ---------------------------------------------------------------------------

import '../../../core/range.dart' show Range;
import '../../../core/text/textLength.dart' show TextLength;
import '../../mirrorTextModel.dart' show IModelContentChange;
import 'length.dart'
    show
        Length,
        lengthAdd,
        lengthDiffNonNegative,
        lengthLessThanEqual,
        lengthOfString,
        lengthToObj,
        positionToLength,
        toLength;

/// 1:1: `export class TextEditInfo`
class TextEditInfo {
  /// 1:1: `static fromModelContentChanges`
  static List<TextEditInfo> fromModelContentChanges(
      List<IModelContentChange> changes) {
    // Must be sorted in ascending order
    final List<TextEditInfo> edits = changes.map((IModelContentChange c) {
      final Range range = Range.lift(c.range)!;
      return TextEditInfo(
        positionToLength(range.getStartPosition()),
        positionToLength(range.getEndPosition()),
        lengthOfString(c.text),
      );
    }).toList().reversed.toList();
    return edits;
  }

  final Length startOffset;
  final Length endOffset;
  final Length newLength;

  TextEditInfo(this.startOffset, this.endOffset, this.newLength);

  @override
  String toString() =>
      '[${lengthToObj(startOffset)}...${lengthToObj(endOffset)}) -> ${lengthToObj(newLength)}';
}

/// 1:1: `export class BeforeEditPositionMapper`
class BeforeEditPositionMapper {
  int _nextEditIdx = 0;
  int _deltaOldToNewLineCount = 0;
  int _deltaOldToNewColumnCount = 0;
  int _deltaLineIdxInOld = -1;
  final List<TextEditInfoCache> _edits;

  /// @param edits Must be sorted by offset in ascending order.
  BeforeEditPositionMapper(List<TextEditInfo> edits)
      : _edits = edits.map((TextEditInfo edit) => TextEditInfoCache.from(edit)).toList();

  /// @param offset Must be equal to or greater than the last offset this
  /// method has been called with.
  Length getOffsetBeforeChange(Length offset) {
    _adjustNextEdit(offset);
    return _translateCurToOld(offset);
  }

  /// Returns null if there is no edit anymore.
  Length? getDistanceToNextChange(Length offset) {
    _adjustNextEdit(offset);

    final TextEditInfoCache? nextEdit = _nextEditIdx < _edits.length
        ? _edits[_nextEditIdx]
        : null;
    final Length? nextChangeOffset =
        nextEdit != null ? _translateOldToCur(nextEdit.offsetObj) : null;
    if (nextChangeOffset == null) {
      return null;
    }

    return lengthDiffNonNegative(offset, nextChangeOffset);
  }

  Length _translateOldToCur(TextLength oldOffsetObj) {
    if (oldOffsetObj.lineCount == _deltaLineIdxInOld) {
      return toLength(
          oldOffsetObj.lineCount + _deltaOldToNewLineCount,
          oldOffsetObj.columnCount + _deltaOldToNewColumnCount);
    } else {
      return toLength(oldOffsetObj.lineCount + _deltaOldToNewLineCount,
          oldOffsetObj.columnCount);
    }
  }

  Length _translateCurToOld(Length newOffset) {
    final TextLength offsetObj = lengthToObj(newOffset);
    if (offsetObj.lineCount - _deltaOldToNewLineCount == _deltaLineIdxInOld) {
      return toLength(
          offsetObj.lineCount - _deltaOldToNewLineCount,
          offsetObj.columnCount - _deltaOldToNewColumnCount);
    } else {
      return toLength(offsetObj.lineCount - _deltaOldToNewLineCount,
          offsetObj.columnCount);
    }
  }

  void _adjustNextEdit(Length offset) {
    while (_nextEditIdx < _edits.length) {
      final TextEditInfoCache nextEdit = _edits[_nextEditIdx];

      // After applying the edit, what is its end offset (considering all
      // previous edits)?
      final Length nextEditEndOffsetInCur =
          _translateOldToCur(nextEdit.endOffsetAfterObj);

      if (lengthLessThanEqual(nextEditEndOffsetInCur, offset)) {
        // We are after the edit, skip it
        _nextEditIdx++;

        final TextLength nextEditEndOffsetInCurObj =
            lengthToObj(nextEditEndOffsetInCur);

        // Before applying the edit, what is its end offset (considering all
        // previous edits)?
        final TextLength nextEditEndOffsetBeforeInCurObj =
            lengthToObj(_translateOldToCur(nextEdit.endOffsetBeforeObj));

        final int lineDelta = nextEditEndOffsetInCurObj.lineCount -
            nextEditEndOffsetBeforeInCurObj.lineCount;
        _deltaOldToNewLineCount += lineDelta;

        final int previousColumnDelta = _deltaLineIdxInOld ==
                nextEdit.endOffsetBeforeObj.lineCount
            ? _deltaOldToNewColumnCount
            : 0;
        final int columnDelta = nextEditEndOffsetInCurObj.columnCount -
            nextEditEndOffsetBeforeInCurObj.columnCount;
        _deltaOldToNewColumnCount = previousColumnDelta + columnDelta;
        _deltaLineIdxInOld = nextEdit.endOffsetBeforeObj.lineCount;
      } else {
        // We are in or before the edit.
        break;
      }
    }
  }
}

/// 1:1: `class TextEditInfoCache`
class TextEditInfoCache {
  static TextEditInfoCache from(TextEditInfo edit) =>
      TextEditInfoCache(edit.startOffset, edit.endOffset, edit.newLength);

  final TextLength endOffsetBeforeObj;
  final TextLength endOffsetAfterObj;
  final TextLength offsetObj;

  TextEditInfoCache(
    Length startOffset,
    Length endOffset,
    Length textLength,
  )   : endOffsetBeforeObj = lengthToObj(endOffset),
        endOffsetAfterObj = lengthToObj(lengthAdd(startOffset, textLength)),
        offsetObj = lengthToObj(startOffset);
}
