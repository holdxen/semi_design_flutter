// 1:1 port of `editor/contrib/linesOperations/browser/copyLinesCommand.ts`.
import '../../../common/commands/commandInterfaces.dart';
import '../../../common/core/range.dart';
import '../../../common/core/selection.dart';

/// 1:1: `export class CopyLinesCommand implements ICommand`.
class CopyLinesCommand implements ICommand {
  final Selection _selection;
  final bool _isCopyingDown;
  final bool _noop;

  SelectionDirection _selectionDirection = SelectionDirection.LTR;
  String? _selectionId;
  int _startLineNumberDelta = 0;
  int _endLineNumberDelta = 0;

  CopyLinesCommand(this._selection, this._isCopyingDown, [bool? noop])
      : _noop = noop ?? false;

  @override
  void getEditOperations(ITextModelForCommand model, IEditOperationBuilder builder) {
    Selection s = _selection;

    _startLineNumberDelta = 0;
    _endLineNumberDelta = 0;
    if (s.startLineNumber < s.endLineNumber && s.endColumn == 1) {
      _endLineNumberDelta = 1;
      s = s.setEndPosition(s.endLineNumber - 1, model.getLineMaxColumn(s.endLineNumber - 1));
    }

    final sourceLines = <String>[];
    for (int i = s.startLineNumber; i <= s.endLineNumber; i++) {
      sourceLines.add(model.getLineContent(i));
    }
    final sourceText = sourceLines.join('\n');

    if (sourceText.isEmpty) {
      // Duplicating empty line
      if (_isCopyingDown) {
        _startLineNumberDelta++;
        _endLineNumberDelta++;
      }
    }

    if (_noop) {
      builder.addEditOperation(
        Range(s.endLineNumber, model.getLineMaxColumn(s.endLineNumber), s.endLineNumber + 1, 1),
        s.endLineNumber == model.getLineCount() ? '' : '\n',
      );
    } else if (!_isCopyingDown) {
      builder.addEditOperation(
        Range(s.endLineNumber, model.getLineMaxColumn(s.endLineNumber),
              s.endLineNumber, model.getLineMaxColumn(s.endLineNumber)),
        '\n' + sourceText,
      );
    } else {
      builder.addEditOperation(
        Range(s.startLineNumber, 1, s.startLineNumber, 1),
        sourceText + '\n',
      );
    }

    _selectionId = builder.trackSelection(s);
    _selectionDirection = _selection.getDirection();
  }

  @override
  Selection computeCursorState(ITextModelForCommand model, ICursorStateComputerData helper) {
    Selection result = helper.getTrackedSelection(_selectionId!);

    if (_startLineNumberDelta != 0 || _endLineNumberDelta != 0) {
      int startLineNumber = result.startLineNumber;
      int startColumn = result.startColumn;
      int endLineNumber = result.endLineNumber;
      int endColumn = result.endColumn;

      if (_startLineNumberDelta != 0) {
        startLineNumber = startLineNumber + _startLineNumberDelta;
        startColumn = 1;
      }

      if (_endLineNumberDelta != 0) {
        endLineNumber = endLineNumber + _endLineNumberDelta;
        endColumn = 1;
      }

      result = Selection.createWithDirection(
        startLineNumber, startColumn, endLineNumber, endColumn, _selectionDirection,
      );
    }

    return result;
  }
}
