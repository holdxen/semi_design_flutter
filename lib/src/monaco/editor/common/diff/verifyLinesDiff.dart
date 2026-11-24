// 1:1 port of vscode/src/vs/editor/common/diff/verifyLinesDiff.ts

import '../core/edits/textEdit.dart' show TextEdit;
import '../core/text/abstractText.dart' show ArrayText;
import 'linesDiffComputer.dart' show LinesDiff;
import 'rangeMapping.dart' show DetailedLineRangeMapping;

/// 1:1: `export type LinesDiffValidity = 'valid' | 'invalid' | 'unverified'`
class LinesDiffValidity {
  static const String valid = 'valid';
  static const String invalid = 'invalid';
  static const String unverified = 'unverified';
}

/// Checks that applying the inner changes of [diff] to the original reproduces
/// the modified text. When trim whitespace is ignored, lines only need to agree
/// after trimming.
String verifyLinesDiff(
  LinesDiff diff,
  List<String> originalLines,
  List<String> modifiedLines,
  bool ignoreTrimWhitespace,
) {
  if (diff.changes.any((DetailedLineRangeMapping c) => c.innerChanges == null)) {
    return LinesDiffValidity.unverified;
  }
  try {
    final TextEdit edit = DetailedLineRangeMapping.toTextEdit(
        diff.changes, ArrayText(modifiedLines));
    final String actual = edit.normalize().apply(ArrayText(originalLines));
    if (!ignoreTrimWhitespace) {
      return actual == modifiedLines.join('\n')
          ? LinesDiffValidity.valid
          : LinesDiffValidity.invalid;
    }
    final List<String> actualLines = actual.split('\n');
    return actualLines.length == modifiedLines.length &&
            actualLines.asMap().entries.every((MapEntry<int, String> e) =>
                e.value.trim() == modifiedLines[e.key].trim())
        ? LinesDiffValidity.valid
        : LinesDiffValidity.invalid;
  } catch (_) {
    return LinesDiffValidity.invalid;
  }
}
