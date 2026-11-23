// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/editOperation.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. The TS object-literal interface
// `ISingleEditOperation` is carried by a Dart class with the same fields.
// ---------------------------------------------------------------------------

import './position.dart';
import './range.dart';

/// A single edit operation, that acts as a simple replace.
/// i.e. Replace text at `range` with `text` in model.
class ISingleEditOperation {
  /// The range to replace. This can be empty to emulate a simple insert.
  IRange range;

  /// The text to replace with. This can be null to emulate a simple delete.
  String? text;

  /// This indicates that this operation has "insert" semantics.
  /// i.e. forceMoveMarkers = true => if `range` is collapsed, all markers at the position will be moved.
  bool? forceMoveMarkers;

  ISingleEditOperation(this.range, this.text, {this.forceMoveMarkers});
}

class EditOperation {
  static ISingleEditOperation insert(Position position, String text) {
    return ISingleEditOperation(
      Range(position.lineNumber, position.column, position.lineNumber, position.column),
      text,
      forceMoveMarkers: true,
    );
  }

  static ISingleEditOperation delete(Range range) {
    return ISingleEditOperation(range, null);
  }

  static ISingleEditOperation replace(Range range, String? text) {
    return ISingleEditOperation(range, text);
  }

  static ISingleEditOperation replaceMove(Range range, String? text) {
    return ISingleEditOperation(range, text, forceMoveMarkers: true);
  }
}
