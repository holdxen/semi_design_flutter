// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/commands/surroundSelectionCommand.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch425).
// ---------------------------------------------------------------------------

import '../core/position.dart' show Position;
import '../core/range.dart' show Range;
import '../core/selection.dart' show Selection;
import 'commandInterfaces.dart'
    show
        ICommand,
        ICursorStateComputerData,
        IEditOperationBuilder,
        ITextModelForCommand;

/// 1:1: `SurroundSelectionCommand implements ICommand`.
class SurroundSelectionCommand implements ICommand {
  final Selection _range;
  final String _charBeforeSelection;
  final String _charAfterSelection;

  SurroundSelectionCommand(
    this._range,
    this._charBeforeSelection,
    this._charAfterSelection,
  );

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(
      Range(
        _range.startLineNumber,
        _range.startColumn,
        _range.startLineNumber,
        _range.startColumn,
      ),
      _charBeforeSelection,
    );

    builder.addTrackedEditOperation(
      Range(
        _range.endLineNumber,
        _range.endColumn,
        _range.endLineNumber,
        _range.endColumn,
      ),
      // addTrackedEditOperation() ignores us if the text == ''. Causing a
      // chain of errors in computeCursorState().
      _charAfterSelection.isEmpty ? null : _charAfterSelection,
    );
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final List<Object?> inverseEditOperations = helper.getInverseEditOperations();
    final Object firstOp = inverseEditOperations[0]!;
    final Object secondOp = inverseEditOperations[1]!;
    final Range firstOperationRange = (firstOp as dynamic).range as Range;
    final Range secondOperationRange = (secondOp as dynamic).range as Range;

    return Selection(
      firstOperationRange.endLineNumber,
      firstOperationRange.endColumn,
      secondOperationRange.endLineNumber,
      secondOperationRange.endColumn - _charAfterSelection.length,
    );
  }
}

/// 1:1: `CompositionSurroundSelectionCommand implements ICommand` — a surround
/// selection command that runs after composition finished.
class CompositionSurroundSelectionCommand implements ICommand {
  final Position _position;
  final String _text;
  final String _charAfter;

  CompositionSurroundSelectionCommand(this._position, this._text, this._charAfter);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(
      Range(
        _position.lineNumber,
        _position.column,
        _position.lineNumber,
        _position.column,
      ),
      _text + _charAfter,
    );
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final List<Object?> inverseEditOperations = helper.getInverseEditOperations();
    final Object op = inverseEditOperations[0]!;
    final Range opRange = (op as dynamic).range as Range;

    return Selection(
      opRange.endLineNumber,
      opRange.startColumn,
      opRange.endLineNumber,
      opRange.endColumn - _charAfter.length,
    );
  }
}
