// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/find/browser/replaceAllCommand.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch427).
// ---------------------------------------------------------------------------

import '../../../common/commands/commandInterfaces.dart'
    show
        ICommand,
        ICursorStateComputerData,
        IEditOperationBuilder,
        ITextModelForCommand;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/selection.dart' show Selection;

/// 1:1: `IEditOperation` (local carrier).
class _EditOperation {
  Range range;
  String text;

  _EditOperation(this.range, this.text);
}

/// 1:1: `ReplaceAllCommand implements ICommand`.
class ReplaceAllCommand implements ICommand {
  final Selection _editorSelection;
  String? _trackedEditorSelectionId;
  final List<Range> _ranges;
  final List<String> _replaceStrings;

  ReplaceAllCommand(
    this._editorSelection,
    this._ranges,
    this._replaceStrings,
  );

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    if (_ranges.isNotEmpty) {
      // Collect all edit operations.
      final List<_EditOperation> ops = <_EditOperation>[];
      for (int i = 0; i < _ranges.length; i++) {
        ops.add(_EditOperation(_ranges[i], _replaceStrings[i]));
      }

      // Sort them in ascending order by range starts.
      ops.sort((_EditOperation o1, _EditOperation o2) =>
          Range.compareRangesUsingStarts(o1.range, o2.range));

      // Merge operations that touch each other.
      final List<_EditOperation> resultOps = <_EditOperation>[];
      _EditOperation previousOp = ops[0];
      for (int i = 1; i < ops.length; i++) {
        if (previousOp.range.endLineNumber == ops[i].range.startLineNumber &&
            previousOp.range.endColumn == ops[i].range.startColumn) {
          // These operations are one after another and can be merged.
          previousOp.range = previousOp.range.plusRange(ops[i].range);
          previousOp.text = previousOp.text + ops[i].text;
        } else {
          resultOps.add(previousOp);
          previousOp = ops[i];
        }
      }
      resultOps.add(previousOp);

      for (final _EditOperation op in resultOps) {
        builder.addEditOperation(op.range, op.text);
      }
    }

    _trackedEditorSelectionId =
        builder.trackSelection(_editorSelection);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    return helper.getTrackedSelection(_trackedEditorSelectionId!);
  }
}
