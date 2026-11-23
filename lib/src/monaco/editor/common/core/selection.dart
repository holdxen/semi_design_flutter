// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/selection.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. `const enum` -> Dart `enum`; TS static-member
// `@override fromPositions` is emitted as a plain static (Dart statics are not
// inherited/overridable). Structure/members/semantics preserved.
// ---------------------------------------------------------------------------

import './position.dart';
import './range.dart';

/// A selection in the editor.
/// The selection is a range that has an orientation.
abstract class ISelection {
  /// The line number on which the selection has started.
  int get selectionStartLineNumber;

  /// The column on `selectionStartLineNumber` where the selection has started.
  int get selectionStartColumn;

  /// The line number on which the selection has ended.
  int get positionLineNumber;

  /// The column on `positionLineNumber` where the selection has ended.
  int get positionColumn;
}

/// The direction of a selection.
enum SelectionDirection {
  /// The selection starts above where it ends.
  LTR,
  /// The selection starts below where it ends.
  RTL,
}

/// A selection in the editor.
/// The selection is a range that has an orientation.
class Selection extends Range implements ISelection {
  /// The line number on which the selection has started.
  @override
  late final int selectionStartLineNumber;

  /// The column on `selectionStartLineNumber` where the selection has started.
  @override
  late final int selectionStartColumn;

  /// The line number on which the selection has ended.
  @override
  late final int positionLineNumber;

  /// The column on `positionLineNumber` where the selection has ended.
  @override
  late final int positionColumn;

  Selection(int selectionStartLineNumber, int selectionStartColumn, int positionLineNumber, int positionColumn)
      : super(selectionStartLineNumber, selectionStartColumn, positionLineNumber, positionColumn) {
    this.selectionStartLineNumber = selectionStartLineNumber;
    this.selectionStartColumn = selectionStartColumn;
    this.positionLineNumber = positionLineNumber;
    this.positionColumn = positionColumn;
  }

  /// Transform to a human-readable representation.
  @override
  String toString() => '[' + this.selectionStartLineNumber.toString() + ',' + this.selectionStartColumn.toString() +
      ' -> ' + this.positionLineNumber.toString() + ',' + this.positionColumn.toString() + ']';

  /// Test if equals other selection.
  bool equalsSelection(ISelection other) => Selection.selectionsEqual(this, other);

  /// Test if the two selections are equal. (source: static selectionsEqual)
  static bool selectionsEqual(ISelection a, ISelection b) {
    return a.selectionStartLineNumber == b.selectionStartLineNumber &&
        a.selectionStartColumn == b.selectionStartColumn &&
        a.positionLineNumber == b.positionLineNumber &&
        a.positionColumn == b.positionColumn;
  }

  /// Get directions (LTR or RTL).
  SelectionDirection getDirection() {
    if (this.selectionStartLineNumber == this.startLineNumber &&
        this.selectionStartColumn == this.startColumn) {
      return SelectionDirection.LTR;
    }
    return SelectionDirection.RTL;
  }

  /// Create a new selection with a different `positionLineNumber` and `positionColumn`.
  @override
  Selection setEndPosition(int endLineNumber, int endColumn) {
    if (this.getDirection() == SelectionDirection.LTR) {
      return Selection(this.startLineNumber, this.startColumn, endLineNumber, endColumn);
    }
    return Selection(endLineNumber, endColumn, this.startLineNumber, this.startColumn);
  }

  /// Get the position at `positionLineNumber` and `positionColumn`.
  Position getPosition() => Position(this.positionLineNumber, this.positionColumn);

  /// Get the position at the start of the selection.
  Position getSelectionStart() => Position(this.selectionStartLineNumber, this.selectionStartColumn);

  /// Create a new selection with a different `selectionStartLineNumber` and `selectionStartColumn`.
  @override
  Selection setStartPosition(int startLineNumber, int startColumn) {
    if (this.getDirection() == SelectionDirection.LTR) {
      return Selection(startLineNumber, startColumn, this.endLineNumber, this.endColumn);
    }
    return Selection(this.endLineNumber, this.endColumn, startLineNumber, startColumn);
  }

  // ----

  /// Create a `Selection` from one or two positions. (source: static override fromPositions)
  /// TS signature: `fromPositions(start, end = start)`. [end] is named optional.
  static Selection fromPositions(IPosition start, {IPosition? end}) {
    final IPosition e = end ?? start;
    return Selection(start.lineNumber, start.column, e.lineNumber, e.column);
  }

  /// Creates a `Selection` from a range, given a direction.
  static Selection fromRange(Range range, SelectionDirection direction) {
    if (direction == SelectionDirection.LTR) {
      return Selection(range.startLineNumber, range.startColumn, range.endLineNumber, range.endColumn);
    } else {
      return Selection(range.endLineNumber, range.endColumn, range.startLineNumber, range.startColumn);
    }
  }

  /// Create a `Selection` from an `ISelection`.
  static Selection liftSelection(ISelection sel) =>
      Selection(sel.selectionStartLineNumber, sel.selectionStartColumn, sel.positionLineNumber, sel.positionColumn);

  /// `a` equals `b`.
  static bool selectionsArrEqual(List<ISelection>? a, List<ISelection>? b) {
    if ((a != null && b == null) || (a == null && b != null)) {
      return false;
    }
    if (a == null && b == null) {
      return true;
    }
    if (a!.length != b!.length) {
      return false;
    }
    for (int i = 0, len = a.length; i < len; i++) {
      if (!Selection.selectionsEqual(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  /// Test if `obj` is an `ISelection`.
  static bool isISelection(Object? obj) {
    if (obj == null) {
      return false;
    }
    if (obj is ISelection) {
      return true;
    }
    if (obj is Map) {
      return obj['selectionStartLineNumber'] is num &&
          obj['selectionStartColumn'] is num &&
          obj['positionLineNumber'] is num &&
          obj['positionColumn'] is num;
    }
    return false;
  }

  /// Create with a direction.
  static Selection createWithDirection(int startLineNumber, int startColumn, int endLineNumber, int endColumn,
      SelectionDirection direction) {
    if (direction == SelectionDirection.LTR) {
      return Selection(startLineNumber, startColumn, endLineNumber, endColumn);
    }
    return Selection(endLineNumber, endColumn, startLineNumber, startColumn);
  }
}
