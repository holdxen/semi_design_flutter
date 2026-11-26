// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/dnd/browser/dragAndDropCommand.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch432).
// ---------------------------------------------------------------------------

import '../../../common/commands/commandInterfaces.dart'
    show
        ICommand,
        ICursorStateComputerData,
        IEditOperationBuilder,
        ITextModelForCommand;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/selection.dart' show Selection;

/// 1:1: `DragAndDropCommand implements ICommand`.
class DragAndDropCommand implements ICommand {
  final Selection selection;
  final Position targetPosition;
  Selection? targetSelection;
  final bool copy;

  DragAndDropCommand(this.selection, this.targetPosition, this.copy);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    final String text = model.getValueInRange(selection);
    if (!copy) {
      builder.addEditOperation(selection, null);
    }
    builder.addEditOperation(
      Range(
        targetPosition.lineNumber,
        targetPosition.column,
        targetPosition.lineNumber,
        targetPosition.column,
      ),
      text,
    );

    if (selection.containsPosition(targetPosition) &&
        !(copy &&
            (selection.getEndPosition().equals(targetPosition) ||
                selection.getStartPosition().equals(targetPosition)))) {
      // we allow users to paste content beside the selection
      targetSelection = selection;
      return;
    }

    if (copy) {
      targetSelection = Selection(
        targetPosition.lineNumber,
        targetPosition.column,
        selection.endLineNumber - selection.startLineNumber +
            targetPosition.lineNumber,
        selection.startLineNumber == selection.endLineNumber
            ? targetPosition.column + selection.endColumn - selection.startColumn
            : selection.endColumn,
      );
      return;
    }

    if (targetPosition.lineNumber > selection.endLineNumber) {
      // Drag the selection downwards
      targetSelection = Selection(
        targetPosition.lineNumber - selection.endLineNumber +
            selection.startLineNumber,
        targetPosition.column,
        targetPosition.lineNumber,
        selection.startLineNumber == selection.endLineNumber
            ? targetPosition.column + selection.endColumn - selection.startColumn
            : selection.endColumn,
      );
      return;
    }

    if (targetPosition.lineNumber < selection.endLineNumber) {
      // Drag the selection upwards
      targetSelection = Selection(
        targetPosition.lineNumber,
        targetPosition.column,
        targetPosition.lineNumber + selection.endLineNumber -
            selection.startLineNumber,
        selection.startLineNumber == selection.endLineNumber
            ? targetPosition.column + selection.endColumn - selection.startColumn
            : selection.endColumn,
      );
      return;
    }

    // The target position is at the same line as the selection's end position.
    if (selection.endColumn <= targetPosition.column) {
      // The target position is after the selection's end position
      targetSelection = Selection(
        targetPosition.lineNumber - selection.endLineNumber +
            selection.startLineNumber,
        selection.startLineNumber == selection.endLineNumber
            ? targetPosition.column - selection.endColumn + selection.startColumn
            : targetPosition.column - selection.endColumn + selection.startColumn,
        targetPosition.lineNumber,
        selection.startLineNumber == selection.endLineNumber
            ? targetPosition.column
            : selection.endColumn,
      );
    } else {
      // The target position is before the selection's end position. Since the
      // selection doesn't contain the target position, the selection is one-line
      // and target position is before this selection.
      targetSelection = Selection(
        targetPosition.lineNumber - selection.endLineNumber +
            selection.startLineNumber,
        targetPosition.column,
        targetPosition.lineNumber,
        targetPosition.column + selection.endColumn - selection.startColumn,
      );
    }
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    return targetSelection!;
  }
}
