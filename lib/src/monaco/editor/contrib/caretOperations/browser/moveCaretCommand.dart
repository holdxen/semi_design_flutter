// 1:1 port of `editor/contrib/caretOperations/browser/moveCaretCommand.ts`.
// Interfaces ICommand / IEditOperationBuilder / ICursorStateComputerData /
// ITextModel are erased per repo convention; their runtime contracts live in
// `editor/common/commands/commandInterfaces.dart`.
import '../../../common/commands/commandInterfaces.dart';
import '../../../common/core/range.dart';
import '../../../common/core/selection.dart';

/// 1:1: `export class MoveCaretCommand implements ICommand`.
class MoveCaretCommand implements ICommand {
  final Selection _selection;
  final bool _isMovingLeft;

  MoveCaretCommand(this._selection, this._isMovingLeft);

  @override
  void getEditOperations(ITextModelForCommand model, IEditOperationBuilder builder) {
    if (_selection.startLineNumber != _selection.endLineNumber || _selection.isEmpty()) {
      return;
    }
    final lineNumber = _selection.startLineNumber;
    final startColumn = _selection.startColumn;
    final endColumn = _selection.endColumn;
    if (_isMovingLeft && startColumn == 1) {
      return;
    }
    if (!_isMovingLeft && endColumn == model.getLineMaxColumn(lineNumber)) {
      return;
    }

    if (_isMovingLeft) {
      final rangeBefore = Range(lineNumber, startColumn - 1, lineNumber, startColumn);
      final charBefore = model.getValueInRange(rangeBefore);
      builder.addEditOperation(rangeBefore, null);
      builder.addEditOperation(Range(lineNumber, endColumn, lineNumber, endColumn), charBefore);
    } else {
      final rangeAfter = Range(lineNumber, endColumn, lineNumber, endColumn + 1);
      final charAfter = model.getValueInRange(rangeAfter);
      builder.addEditOperation(rangeAfter, null);
      builder.addEditOperation(Range(lineNumber, startColumn, lineNumber, startColumn), charAfter);
    }
  }

  @override
  Selection computeCursorState(ITextModelForCommand model, ICursorStateComputerData helper) {
    if (_isMovingLeft) {
      return Selection(
        _selection.startLineNumber, _selection.startColumn - 1,
        _selection.endLineNumber, _selection.endColumn - 1,
      );
    }
    return Selection(
      _selection.startLineNumber, _selection.startColumn + 1,
      _selection.endLineNumber, _selection.endColumn + 1,
    );
  }
}
