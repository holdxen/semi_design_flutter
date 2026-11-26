// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/commands/columnSelectionPasteCommand.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch429).
// ---------------------------------------------------------------------------

import '../core/cursorColumns.dart' show CursorColumns;
import '../core/range.dart' show Range;
import '../core/selection.dart' show Selection;
import 'commandInterfaces.dart'
    show
        ICommand,
        ICursorStateComputerData,
        IEditOperationBuilder,
        ITextModelForCommand;
import 'replaceCommand.dart' show ReplaceCommand, ReplaceOvertypeCommand;

/// 1:1: `ColumnSelectionPasteCommand implements ICommand`.
class ColumnSelectionPasteCommand implements ICommand {
  final Selection _selection;
  final List<String> _text;
  final int _tabSize;
  final bool _overtype;

  ColumnSelectionPasteCommand(
    this._selection,
    this._text,
    this._tabSize,
    this._overtype,
  );

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    final int visibleColumn = CursorColumns.visibleColumnFromColumn(
      model.getLineContent(_selection.startLineNumber),
      _selection.startColumn,
      _tabSize,
    );
    final List<String> text = _padTextToBlockWidth(visibleColumn);
    final int lineCount = model.getLineCount();
    final ICommand Function(Range, String) chosenReplaceCommand =
        _overtype
            ? (Range range, String lineText) =>
                ReplaceOvertypeCommand(range, lineText)
            : (Range range, String lineText) => ReplaceCommand(range, lineText);

    for (int i = 0; i < text.length; i++) {
      final int lineNumber = _selection.endLineNumber + i;
      if (lineNumber > lineCount) {
        final int endColumn = model.getLineMaxColumn(lineCount);
        final String padding = ''.padRight(visibleColumn);
        final String appendedText =
            '\n$padding${text.sublist(i).join('\n$padding')}';
        builder.addTrackedEditOperation(
          Range(lineCount, endColumn, lineCount, endColumn),
          appendedText,
        );
        break;
      }

      late Range range;
      String lineText = text[i];
      if (i == 0) {
        range = _selection;
      } else {
        final String lineContent = model.getLineContent(lineNumber);
        final int column = CursorColumns.columnFromVisibleColumn(
          lineContent,
          visibleColumn,
          _tabSize,
        );
        range = Range(lineNumber, column, lineNumber, column);
        if (column == model.getLineMaxColumn(lineNumber)) {
          final int endVisibleColumn = CursorColumns.visibleColumnFromColumn(
            lineContent,
            column,
            _tabSize,
          );
          final int pad = visibleColumn - endVisibleColumn;
          lineText = ''.padRight(pad > 0 ? pad : 0) + lineText;
        }
      }
      chosenReplaceCommand(range, lineText).getEditOperations(model, builder);
    }
  }

  /// 1:1: `_padTextToBlockWidth`.
  List<String> _padTextToBlockWidth(int visibleColumn) {
    final String prefix = ''.padRight(visibleColumn);
    final List<int> endVisibleColumns = <int>[];
    int blockEndVisibleColumn = visibleColumn;

    for (final String text in _text) {
      final String textWithPrefix = prefix + text;
      final int endVisibleColumn = CursorColumns.visibleColumnFromColumn(
        textWithPrefix,
        textWithPrefix.length + 1,
        _tabSize,
      );
      endVisibleColumns.add(endVisibleColumn);
      if (endVisibleColumn > blockEndVisibleColumn) {
        blockEndVisibleColumn = endVisibleColumn;
      }
    }

    return _text
        .asMap()
        .map((int index, String text) => MapEntry<int, String>(
              index,
              text + ''.padRight(blockEndVisibleColumn - endVisibleColumns[index]),
            ))
        .values
        .toList();
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final List<Object?> operations = helper.getInverseEditOperations();
    final Object op = operations.last!;
    final dynamic range = op is Map ? op['range'] : (op as dynamic).range;
    return Selection.fromPositions(range.getEndPosition() as dynamic);
  }
}
