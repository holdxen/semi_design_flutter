// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/ranges/columnRange.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure/members/semantics preserved.
// ---------------------------------------------------------------------------

import '../../../../base/common/errors.dart';
import './offsetRange.dart';
import '../range.dart';

/// Represents a 1-based range of columns.
/// Use OffsetRange to represent a 0-based range.
class ColumnRange {
  static ColumnRange fromOffsetRange(OffsetRange offsetRange) =>
      ColumnRange(offsetRange.start + 1, offsetRange.endExclusive + 1);

  /// 1-based
  final int startColumn;
  final int endColumnExclusive;

  ColumnRange(int startColumn, int endColumnExclusive)
      : startColumn = startColumn,
        endColumnExclusive = endColumnExclusive {
    if (startColumn > endColumnExclusive) {
      throw BugIndicatingError('startColumn ' +
          startColumn.toString() +
          ' cannot be after endColumnExclusive ' +
          endColumnExclusive.toString());
    }
  }

  Range toRange(int lineNumber) =>
      Range(lineNumber, this.startColumn, lineNumber, this.endColumnExclusive);

  bool equals(ColumnRange other) =>
      this.startColumn == other.startColumn && this.endColumnExclusive == other.endColumnExclusive;

  OffsetRange toZeroBasedOffsetRange() =>
      OffsetRange(this.startColumn - 1, this.endColumnExclusive - 1);
}
