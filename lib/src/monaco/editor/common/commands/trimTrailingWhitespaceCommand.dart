// 1:1 port of `editor/common/commands/trimTrailingWhitespaceCommand.ts`.
import '../../../base/common/strings.dart' as strings;
import '../core/editOperation.dart';
import '../core/position.dart';
import '../core/range.dart';
import '../core/selection.dart';
import '../encodedTokenAttributes.dart';
import 'commandInterfaces.dart';

/// 1:1: `export class TrimTrailingWhitespaceCommand implements ICommand`.
class TrimTrailingWhitespaceCommand implements ICommand {
  final Selection _selection;
  String? _selectionId;
  final List<Position> _cursors;
  final bool _trimInRegexesAndStrings;

  TrimTrailingWhitespaceCommand(this._selection, this._cursors, this._trimInRegexesAndStrings);

  @override
  void getEditOperations(ITextModelForCommand model, IEditOperationBuilder builder) {
    final ops = trimTrailingWhitespace(model, _cursors, _trimInRegexesAndStrings);
    for (int i = 0, len = ops.length; i < len; i++) {
      final op = ops[i];
      builder.addEditOperation(op.range, op.text);
    }
    _selectionId = builder.trackSelection(_selection);
  }

  @override
  Selection computeCursorState(ITextModelForCommand model, ICursorStateComputerData helper) {
    return helper.getTrackedSelection(_selectionId!);
  }
}

/// 1:1: `export function trimTrailingWhitespace(model, cursors, trimInRegexesAndStrings)`.
List<ISingleEditOperation> trimTrailingWhitespace(
  ITextModelForCommand model,
  List<Position> cursors,
  bool trimInRegexesAndStrings,
) {
  // Sort cursors ascending
  cursors.sort((a, b) {
    if (a.lineNumber == b.lineNumber) {
      return a.column - b.column;
    }
    return a.lineNumber - b.lineNumber;
  });

  // Reduce multiple cursors on the same line and only keep the last one on the line
  for (int i = cursors.length - 2; i >= 0; i--) {
    if (cursors[i].lineNumber == cursors[i + 1].lineNumber) {
      // Remove cursor at `i`
      cursors.removeAt(i);
    }
  }

  final r = <ISingleEditOperation>[];
  int cursorIndex = 0;
  final int cursorLen = cursors.length;

  for (int lineNumber = 1, lineCount = model.getLineCount(); lineNumber <= lineCount; lineNumber++) {
    final lineContent = model.getLineContent(lineNumber);
    final int maxLineColumn = lineContent.length + 1;
    int minEditColumn = 0;

    if (cursorIndex < cursorLen && cursors[cursorIndex].lineNumber == lineNumber) {
      minEditColumn = cursors[cursorIndex].column;
      cursorIndex++;
      if (minEditColumn == maxLineColumn) {
        // The cursor is at the end of the line => no edits for sure on this line
        continue;
      }
    }

    if (lineContent.isEmpty) {
      continue;
    }

    final int lastNonWhitespaceIndex = strings.lastNonWhitespaceIndex(lineContent);

    int fromColumn = 0;
    if (lastNonWhitespaceIndex == -1) {
      // Entire line is whitespace
      fromColumn = 1;
    } else if (lastNonWhitespaceIndex != lineContent.length - 1) {
      // There is trailing whitespace
      fromColumn = lastNonWhitespaceIndex + 2;
    } else {
      // There is no trailing whitespace
      continue;
    }

    if (!trimInRegexesAndStrings) {
      if (!model.tokenization.hasAccurateTokensForLine(lineNumber)) {
        // We don't want to force line tokenization, as that can be expensive, but we also don't want to trim
        // trailing whitespace in lines that are not tokenized yet, as that can be wrong and trim whitespace from
        // lines that the user requested we don't. So we bail out if the tokens are not accurate for this line.
        continue;
      }

      final lineTokens = model.tokenization.getLineTokens(lineNumber);
      final int fromColumnType = lineTokens.getStandardTokenType(
        lineTokens.findTokenIndexAtOffset(fromColumn),
      );

      if (fromColumnType == StandardTokenType.string || fromColumnType == StandardTokenType.regEx) {
        continue;
      }
    }

    fromColumn = fromColumn > minEditColumn ? fromColumn : minEditColumn;
    r.add(EditOperation.delete(Range(lineNumber, fromColumn, lineNumber, maxLineColumn)));
  }

  return r;
}
