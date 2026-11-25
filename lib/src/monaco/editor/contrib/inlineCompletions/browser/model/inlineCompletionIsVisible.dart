// 1:1 port of
// vscode/src/vs/editor/contrib/inlineCompletions/browser/model/inlineCompletionIsVisible.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `ITextModel` is erased; the structural contract below extends the one
//     used by `singleTextEditHelpers.dart` with `getLineIndentColumn`.
//   - `Math.max(0, x)` maps to `math.max(0, x)`.
//   - `matchesSubString` returns `List<IMatch>?`; truthiness maps to `!= null`.
//   - JS `String.substring` clamps out-of-range indices; `_substring` reproduces
//     that because a cursor can sit past the kept suffix.

import 'dart:math' as math;

import '../../../../../base/common/filters.dart' show matchesSubString;
import '../../../../common/core/edits/textEdit.dart' show TextReplacement;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import '../../../../common/model.dart' show EndOfLinePreference;
import 'singleTextEditHelpers.dart'
    show ITextModelForSingleTextEditHelpers, singleTextRemoveCommonPrefix;

/// JS `String.prototype.substring` semantics for non-negative ints: clamp to
/// `[0, length]` and swap when `start > end`.
String _substring(String value, int start, [int? end]) {
  final int len = value.length;
  int s = start < 0 ? 0 : (start > len ? len : start);
  int e = end == null ? len : (end < 0 ? 0 : (end > len ? len : end));
  if (s > e) {
    final int tmp = s;
    s = e;
    e = tmp;
  }
  return value.substring(s, e);
}

/// 1:1: the `ITextModel` surface read by [inlineCompletionIsVisible].
abstract class ITextModelForInlineCompletionIsVisible
    implements ITextModelForSingleTextEditHelpers {
  int getLineIndentColumn(int lineNumber);
}

/// 1:1: `export function inlineCompletionIsVisible`
bool inlineCompletionIsVisible(
  TextReplacement singleTextEdit,
  Range? originalRange,
  ITextModelForInlineCompletionIsVisible model,
  Position cursorPosition,
) {
  final TextReplacement minimizedReplacement = singleTextRemoveCommonPrefix(
    singleTextEdit,
    model,
  );
  final Range editRange = singleTextEdit.range;
  if ((originalRange != null &&
          !originalRange.getStartPosition().equals(
            editRange.getStartPosition(),
          )) ||
      cursorPosition.lineNumber != minimizedReplacement.range.startLineNumber ||
      // if the completion is empty after removing the common prefix of the
      // completion and the model, the completion item would not be visible
      minimizedReplacement.isEmpty) {
    return false;
  }

  // We might consider comparing by .toLowerText, but this requires GhostTextReplacement
  final String originalValue = model.getValueInRange(
    minimizedReplacement.range,
    EndOfLinePreference.LF,
  );
  final String filterText = minimizedReplacement.text;

  final int cursorPosIndex = math.max(
    0,
    cursorPosition.column - minimizedReplacement.range.startColumn,
  );

  String filterTextBefore = _substring(filterText, 0, cursorPosIndex);
  String filterTextAfter = _substring(filterText, cursorPosIndex);

  String originalValueBefore = _substring(originalValue, 0, cursorPosIndex);
  String originalValueAfter = _substring(originalValue, cursorPosIndex);

  final int originalValueIndent = model.getLineIndentColumn(
    minimizedReplacement.range.startLineNumber,
  );
  if (minimizedReplacement.range.startColumn <= originalValueIndent) {
    // Remove indentation
    originalValueBefore = originalValueBefore.trimLeft();
    if (originalValueBefore.isEmpty) {
      originalValueAfter = originalValueAfter.trimLeft();
    }
    filterTextBefore = filterTextBefore.trimLeft();
    if (filterTextBefore.isEmpty) {
      filterTextAfter = filterTextAfter.trimLeft();
    }
  }

  return filterTextBefore.startsWith(originalValueBefore) &&
      matchesSubString(originalValueAfter, filterTextAfter) != null;
}
