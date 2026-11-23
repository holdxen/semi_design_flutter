// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/misc/eolCounter.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. `const enum StringEOL` -> class static const;
// the returned TS tuple `[number,number,number,StringEOL]` -> Dart record.
// ---------------------------------------------------------------------------

import '../../../../base/common/charCode.dart';

class StringEOL {
  const StringEOL._();
  static const int Unknown = 0;
  static const int Invalid = 3;
  static const int LF = 1;
  static const int CRLF = 2;
}

(int, int, int, int) countEOL(String text) {
  int eolCount = 0;
  int firstLineLength = 0;
  int lastLineStart = 0;
  int eol = StringEOL.Unknown;
  for (int i = 0, len = text.length; i < len; i++) {
    final int chr = text.codeUnitAt(i);

    if (chr == CharCode.CarriageReturn) {
      if (eolCount == 0) {
        firstLineLength = i;
      }
      eolCount++;
      if (i + 1 < len && text.codeUnitAt(i + 1) == CharCode.LineFeed) {
        // \r\n... case
        eol |= StringEOL.CRLF;
        i++; // skip \n
      } else {
        // \r... case
        eol |= StringEOL.Invalid;
      }
      lastLineStart = i + 1;
    } else if (chr == CharCode.LineFeed) {
      // \n... case
      eol |= StringEOL.LF;
      if (eolCount == 0) {
        firstLineLength = i;
      }
      eolCount++;
      lastLineStart = i + 1;
    }
  }
  if (eolCount == 0) {
    firstLineLength = text.length;
  }
  return (eolCount, firstLineLength, text.length - lastLineStart, eol);
}
