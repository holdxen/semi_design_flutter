// 1:1 port of
// vscode/src/vs/editor/contrib/insertFinalNewLine/browser/insertFinalNewLineCommand.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `ICommand` / `IEditOperationBuilder` / `ICursorStateComputerData` /
//     `ITextModel` are erased; their runtime contracts live in
//     `editor/common/commands/commandInterfaces.dart`.
//   - `ISingleEditOperation | undefined` -> `ISingleEditOperation?`.

import '../../../common/commands/commandInterfaces.dart';
import '../../../common/core/editOperation.dart'
    show EditOperation, ISingleEditOperation;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/selection.dart' show Selection;

/// 1:1: `export class InsertFinalNewLineCommand implements ICommand`
class InsertFinalNewLineCommand implements ICommand {
  InsertFinalNewLineCommand(this._selection);

  final Selection _selection;
  String? _selectionId;

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    final ISingleEditOperation? op = insertFinalNewLine(model);
    if (op != null) {
      builder.addEditOperation(op.range, op.text);
    }
    _selectionId = builder.trackSelection(_selection);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    return helper.getTrackedSelection(_selectionId!);
  }
}

/// Generate edit operations for inserting a final new line if needed.
/// Returns null if no edit is needed.
///
/// 1:1: `export function insertFinalNewLine`
ISingleEditOperation? insertFinalNewLine(ITextModelForCommand model) {
  final int lineCount = model.getLineCount();
  return EditOperation.insert(
    Position(lineCount, model.getLineMaxColumn(lineCount)),
    model.getEOL(),
  );
}
