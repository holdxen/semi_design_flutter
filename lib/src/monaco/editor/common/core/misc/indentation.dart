// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/misc/indentation.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../../../base/common/strings.dart' as strings;
import '../cursorColumns.dart';

/// 1:1: `_normalizeIndentationFromWhitespace`
String _normalizeIndentationFromWhitespace(
    String str, int indentSize, bool insertSpaces) {
  int spacesCnt = 0;
  for (int i = 0; i < str.length; i++) {
    if (str[i] == '\t') {
      spacesCnt = CursorColumns.nextIndentTabStop(spacesCnt, indentSize);
    } else {
      spacesCnt++;
    }
  }

  final StringBuffer result = StringBuffer();
  if (!insertSpaces) {
    final int tabsCnt = (spacesCnt / indentSize).floor();
    spacesCnt = spacesCnt % indentSize;
    for (int i = 0; i < tabsCnt; i++) {
      result.write('\t');
    }
  }

  for (int i = 0; i < spacesCnt; i++) {
    result.write(' ');
  }

  return result.toString();
}

/// 1:1: `normalizeIndentation`
String normalizeIndentation(String str, int indentSize, bool insertSpaces) {
  int firstNonWhitespaceIndex = strings.firstNonWhitespaceIndex(str);
  if (firstNonWhitespaceIndex == -1) {
    firstNonWhitespaceIndex = str.length;
  }
  return _normalizeIndentationFromWhitespace(
          str.substring(0, firstNonWhitespaceIndex), indentSize, insertSpaces) +
      str.substring(firstNonWhitespaceIndex);
}
