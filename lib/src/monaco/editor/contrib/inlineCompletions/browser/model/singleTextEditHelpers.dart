// 1:1 port of
// vscode/src/vs/editor/contrib/inlineCompletions/browser/model/singleTextEditHelpers.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `ITextModel` is erased; the structural contract below declares the one
//     member these helpers read (`getValueInRange` with an EOL preference).
//   - `replaceAll('\r\n', '\n')` maps to Dart `String.replaceAll`.
//   - `Range.fromPositions(start, end)` uses Dart's named `end` argument.

import '../../../../../base/common/strings.dart' as strings;
import '../../../../common/core/edits/textEdit.dart' show TextReplacement;
import '../../../../common/core/range.dart' show Range;
import '../../../../common/core/text/textLength.dart' show TextLength;
import '../../../../common/model.dart' show EndOfLinePreference;

/// 1:1: the `ITextModel` surface read by [singleTextRemoveCommonPrefix].
abstract class ITextModelForSingleTextEditHelpers {
  String getValueInRange(Range range, [int? endOfLinePreference]);
}

/// 1:1: `export function singleTextRemoveCommonPrefix`
TextReplacement singleTextRemoveCommonPrefix(
  TextReplacement edit,
  ITextModelForSingleTextEditHelpers model, [
  Range? validModelRange,
]) {
  final Range? modelRange = validModelRange != null
      ? edit.range.intersectRanges(validModelRange)
      : edit.range;
  if (modelRange == null) {
    return edit;
  }
  final String normalizedText = edit.text.replaceAll('\r\n', '\n');
  final String valueToReplace = model.getValueInRange(
    modelRange,
    EndOfLinePreference.LF,
  );
  final int commonPrefixLen = strings.commonPrefixLength(
    valueToReplace,
    normalizedText,
  );
  final start = TextLength.ofText(valueToReplace.substring(0, commonPrefixLen))
      .addToPosition(edit.range.getStartPosition());
  final String text = normalizedText.substring(commonPrefixLen);
  final Range range = Range.fromPositions(
    start,
    end: edit.range.getEndPosition(),
  );
  return TextReplacement(range, text);
}

/// 1:1: `export function singleTextEditAugments`
bool singleTextEditAugments(TextReplacement edit, TextReplacement base) {
  // The augmented completion must replace the base range, but can replace even more
  return edit.text.startsWith(base.text) &&
      _rangeExtends(edit.range, base.range);
}

/// 1:1: `function rangeExtends`
bool _rangeExtends(Range extendingRange, Range rangeToExtend) {
  return rangeToExtend.getStartPosition().equals(
        extendingRange.getStartPosition(),
      ) &&
      rangeToExtend.getEndPosition().isBeforeOrEqual(
        extendingRange.getEndPosition(),
      );
}
