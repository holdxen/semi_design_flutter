// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/ranges/rangeSingleLine.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure/members/semantics preserved.
// ---------------------------------------------------------------------------

import './columnRange.dart';
import '../range.dart';

/// Represents a column range in a single line.
class RangeSingleLine {
  static RangeSingleLine? fromRange(Range range) {
    if (range.endLineNumber != range.startLineNumber) {
      return null;
    }
    return RangeSingleLine(range.startLineNumber, ColumnRange(range.startColumn, range.endColumn));
  }

  /// 1-based
  final int lineNumber;
  final ColumnRange columnRange;

  RangeSingleLine(this.lineNumber, this.columnRange);

  Range toRange() =>
      Range(this.lineNumber, this.columnRange.startColumn, this.lineNumber, this.columnRange.endColumnExclusive);
}
