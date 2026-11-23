// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/cursorColumns.ts
// Translated 1:1 from TypeScript. Uses strings.dart's GraphemeIterator /
// CodePointIterator / getNextCodePoint / isFullWidthCharacter / isEmojiImprecise.
// ---------------------------------------------------------------------------

import '../../../base/common/charCode.dart';
import '../../../base/common/strings.dart' as strings;

/// 1:1: `export class CursorColumns`
class CursorColumns {
  /// 1:1: `_nextVisibleColumn`
  static int _nextVisibleColumn(int codePoint, int visibleColumn, int tabSize) {
    if (codePoint == CharCode.Tab) {
      return nextRenderTabStop(visibleColumn, tabSize);
    }
    if (strings.isFullWidthCharacter(codePoint) ||
        strings.isEmojiImprecise(codePoint)) {
      return visibleColumn + 2;
    }
    return visibleColumn + 1;
  }

  /// 1:1: `visibleColumnFromColumn`
  static int visibleColumnFromColumn(
      String lineContent, int column, int tabSize) {
    final int textLen =
        (column - 1) < lineContent.length ? (column - 1) : lineContent.length;
    final String text = lineContent.substring(0, textLen < 0 ? 0 : textLen);
    final strings.GraphemeIterator iterator = strings.GraphemeIterator(text);

    int result = 0;
    while (!iterator.eol()) {
      final int codePoint =
          strings.getNextCodePoint(text, textLen, iterator.offset);
      iterator.nextGraphemeLength();

      result = _nextVisibleColumn(codePoint, result, tabSize);
    }

    return result;
  }

  /// 1:1: `toStatusbarColumn`
  static int toStatusbarColumn(
      String lineContent, int column, int tabSize) {
    final int textEnd =
        (column - 1) < lineContent.length ? (column - 1) : lineContent.length;
    final String text = lineContent.substring(0, textEnd < 0 ? 0 : textEnd);
    final strings.CodePointIterator iterator = strings.CodePointIterator(text);

    int result = 0;
    while (!iterator.eol()) {
      final int codePoint = iterator.nextCodePoint();

      if (codePoint == CharCode.Tab) {
        result = nextRenderTabStop(result, tabSize);
      } else {
        result = result + 1;
      }
    }

    return result + 1;
  }

  /// 1:1: `columnFromVisibleColumn`
  static int columnFromVisibleColumn(
      String lineContent, int visibleColumn, int tabSize) {
    if (visibleColumn <= 0) {
      return 1;
    }

    final int lineContentLength = lineContent.length;
    final strings.GraphemeIterator iterator =
        strings.GraphemeIterator(lineContent);

    int beforeVisibleColumn = 0;
    int beforeColumn = 1;
    while (!iterator.eol()) {
      final int codePoint = strings.getNextCodePoint(
          lineContent, lineContentLength, iterator.offset);
      iterator.nextGraphemeLength();

      final int afterVisibleColumn =
          _nextVisibleColumn(codePoint, beforeVisibleColumn, tabSize);
      final int afterColumn = iterator.offset + 1;

      if (afterVisibleColumn >= visibleColumn) {
        final int beforeDelta = visibleColumn - beforeVisibleColumn;
        final int afterDelta = afterVisibleColumn - visibleColumn;
        if (afterDelta < beforeDelta) {
          return afterColumn;
        } else {
          return beforeColumn;
        }
      }

      beforeVisibleColumn = afterVisibleColumn;
      beforeColumn = afterColumn;
    }

    // walked the entire string
    return lineContentLength + 1;
  }

  /// 1:1: `nextRenderTabStop` (0-based columns)
  static int nextRenderTabStop(int visibleColumn, int tabSize) =>
      visibleColumn + tabSize - visibleColumn % tabSize;

  /// 1:1: `nextIndentTabStop` (0-based columns)
  static int nextIndentTabStop(int visibleColumn, int indentSize) =>
      nextRenderTabStop(visibleColumn, indentSize);

  /// 1:1: `prevRenderTabStop` (0-based columns)
  static int prevRenderTabStop(int column, int tabSize) {
    final int v = column - 1 - (column - 1) % tabSize;
    return v > 0 ? v : 0;
  }

  /// 1:1: `prevIndentTabStop` (0-based columns)
  static int prevIndentTabStop(int column, int indentSize) =>
      prevRenderTabStop(column, indentSize);
}
