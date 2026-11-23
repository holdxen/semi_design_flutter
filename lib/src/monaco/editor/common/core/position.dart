// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/position.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Syntax adapted to Dart (named optional
// parameters for TS defaults); structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// A position in the editor. This interface is suitable for serialization.
abstract class IPosition {
  /// line number (starts at 1)
  int get lineNumber;

  /// column (the first character in a line is between column 1 and column 2)
  int get column;
}

/// A position in the editor.
class Position implements IPosition {
  /// line number (starts at 1)
  @override
  final int lineNumber;

  /// column (the first character in a line is between column 1 and column 2)
  @override
  final int column;

  Position(this.lineNumber, this.column);

  /// Create a new position from this position.
  ///
  /// TS signature: `with(newLineNumber = this.lineNumber, newColumn = this.column)`.
  /// [newLineNumber] / [newColumn] are named optional to preserve the defaults.
  Position withPos({int? newLineNumber, int? newColumn}) {
    final int ln = newLineNumber ?? this.lineNumber;
    final int col = newColumn ?? this.column;
    if (ln == this.lineNumber && col == this.column) {
      return this;
    } else {
      return Position(ln, col);
    }
  }

  /// Derive a new position from this position.
  ///
  /// TS signature: `delta(deltaLineNumber = 0, deltaColumn = 0)`.
  Position delta({int deltaLineNumber = 0, int deltaColumn = 0}) {
    return withPos(
      newLineNumber: 1 > this.lineNumber + deltaLineNumber ? 1 : this.lineNumber + deltaLineNumber,
      newColumn: 1 > this.column + deltaColumn ? 1 : this.column + deltaColumn,
    );
  }

  // Dart forbids a static member and an instance member sharing a name (TS allows
  // it). The instance method keeps the source name; the static overload keeps its
  // semantics but is suffixed `Static`. Source names are noted on each static.

  /// Test if this position equals other position
  bool equals(IPosition other) => Position.equalsStatic(this, other);

  /// Test if position `a` equals position `b`  (source: static equals)
  static bool equalsStatic(IPosition? a, IPosition? b) {
    if (a == null && b == null) {
      return true;
    }
    return a != null &&
        b != null &&
        a.lineNumber == b.lineNumber &&
        a.column == b.column;
  }

  /// Test if this position is before other position.
  /// If the two positions are equal, the result will be false.
  bool isBefore(IPosition other) => Position.isBeforeStatic(this, other);

  /// Test if position `a` is before position `b`.  (source: static isBefore)
  /// If the two positions are equal, the result will be false.
  static bool isBeforeStatic(IPosition a, IPosition b) {
    if (a.lineNumber < b.lineNumber) {
      return true;
    }
    if (b.lineNumber < a.lineNumber) {
      return false;
    }
    return a.column < b.column;
  }

  /// Test if this position is before other position.
  /// If the two positions are equal, the result will be true.
  bool isBeforeOrEqual(IPosition other) => Position.isBeforeOrEqualStatic(this, other);

  /// Test if position `a` is before position `b`.  (source: static isBeforeOrEqual)
  /// If the two positions are equal, the result will be true.
  static bool isBeforeOrEqualStatic(IPosition a, IPosition b) {
    if (a.lineNumber < b.lineNumber) {
      return true;
    }
    if (b.lineNumber < a.lineNumber) {
      return false;
    }
    return a.column <= b.column;
  }

  /// A function that compares positions, useful for sorting.
  ///
  /// TS uses `| 0` to coerce to int; [lineNumber]/[column] are already [int].
  static int compare(IPosition a, IPosition b) {
    final int aLineNumber = a.lineNumber | 0;
    final int bLineNumber = b.lineNumber | 0;

    if (aLineNumber == bLineNumber) {
      final int aColumn = a.column | 0;
      final int bColumn = b.column | 0;
      return aColumn - bColumn;
    }

    return aLineNumber - bLineNumber;
  }

  /// Clone this position.
  Position clone() => Position(this.lineNumber, this.column);

  /// Convert to a human-readable representation.
  @override
  String toString() => '(' + this.lineNumber.toString() + ',' + this.column.toString() + ')';

  // ---

  /// Create a `Position` from an `IPosition`.
  static Position lift(IPosition pos) => Position(pos.lineNumber, pos.column);

  /// Test if `obj` is an `IPosition`.
  ///
  /// TS: `typeof obj.lineNumber === 'number' && typeof obj.column === 'number'`.
  static bool isIPosition(Object? obj) {
    if (obj == null) {
      return false;
    }
    if (obj is IPosition) {
      return true;
    }
    // structural check for plain JSON objects, matching the TS runtime test
    if (obj is Map) {
      return obj['lineNumber'] is num && obj['column'] is num;
    }
    return false;
  }

  /// TS: `toJSON(): IPosition { return { lineNumber, column }; }`
  Map<String, int> toJSON() => <String, int>{
        'lineNumber': this.lineNumber,
        'column': this.column,
      };
}
