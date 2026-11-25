// 1:1 port of
// vscode/src/vs/editor/contrib/inPlaceReplace/browser/inPlaceReplaceCommand.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `ICommand` / `IEditOperationBuilder` / `ICursorStateComputerData` /
//     `ITextModel` are erased; their runtime contracts live in
//     `editor/common/commands/commandInterfaces.dart`.
//   - `getInverseEditOperations()` is typed `List<Object?>` on that shared
//     contract, so the first entry is cast back to `ISingleEditOperation`.
//   - `Math.min` -> `math.min`.

import 'dart:math' as math;

import '../../../common/commands/commandInterfaces.dart';
import '../../../common/core/editOperation.dart' show ISingleEditOperation;
import '../../../common/core/range.dart' show IRange, Range;
import '../../../common/core/selection.dart' show Selection;

/// 1:1: `export class InPlaceReplaceCommand implements ICommand`
class InPlaceReplaceCommand implements ICommand {
  InPlaceReplaceCommand(this._editRange, this._originalSelection, this._text);

  final Range _editRange;
  final Selection _originalSelection;
  final String _text;

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(_editRange, _text);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final List<Object?> inverseEditOperations = helper
        .getInverseEditOperations();
    final IRange srcRange =
        (inverseEditOperations[0]! as ISingleEditOperation).range;

    if (!_originalSelection.isEmpty()) {
      // Preserve selection and extends to typed text
      return Selection(
        srcRange.endLineNumber,
        srcRange.endColumn - _text.length,
        srcRange.endLineNumber,
        srcRange.endColumn,
      );
    }

    return Selection(
      srcRange.endLineNumber,
      math.min(_originalSelection.positionColumn, srcRange.endColumn),
      srcRange.endLineNumber,
      math.min(_originalSelection.positionColumn, srcRange.endColumn),
    );
  }
}
