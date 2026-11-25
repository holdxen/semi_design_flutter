// 1:1 port of `editor/contrib/linesOperations/browser/sortLinesCommand.ts`.
import '../../../../base/common/date.dart' show safeIntl;
import '../../../../base/common/lazy.dart';
import '../../../common/commands/commandInterfaces.dart';
import '../../../common/core/editOperation.dart';
import '../../../common/core/range.dart';
import '../../../common/core/selection.dart';

/// 1:1: `export class SortLinesCommand implements ICommand`.
class SortLinesCommand implements ICommand {
  /// 1:1: `static _COLLATOR: Lazy<Intl.Collator> = safeIntl.Collator();`
  static final Lazy<dynamic> _COLLATOR = safeIntl.Collator();

  final Selection selection;
  final bool descending;
  String? selectionId;

  SortLinesCommand(this.selection, this.descending);

  @override
  void getEditOperations(ITextModelForCommand model, IEditOperationBuilder builder) {
    final op = _sortLines(model, selection, descending);
    if (op != null) {
      builder.addEditOperation(op.range, op.text);
    }
    selectionId = builder.trackSelection(selection);
  }

  @override
  Selection computeCursorState(ITextModelForCommand model, ICursorStateComputerData helper) {
    return helper.getTrackedSelection(selectionId!);
  }

  /// 1:1: `public static canRun(model, selection, descending): boolean`.
  static bool canRun(ITextModelForCommand? model, Selection selection, bool descending) {
    if (model == null) {
      return false;
    }
    final data = _getSortData(model, selection, descending);
    if (data == null) {
      return false;
    }
    for (int i = 0, len = data.before.length; i < len; i++) {
      if (data.before[i] != data.after[i]) {
        return true;
      }
    }
    return false;
  }
}

/// Carrier for the result of `_getSortData` (TS returns an inline object).
class _SortData {
  final int startLineNumber;
  final int endLineNumber;
  final List<String> before;
  final List<String> after;

  _SortData(this.startLineNumber, this.endLineNumber, this.before, this.after);
}

/// 1:1: `function getSortData(model, selection, descending)`.
_SortData? _getSortData(ITextModelForCommand model, Selection selection, bool descending) {
  final startLineNumber = selection.startLineNumber;
  int endLineNumber = selection.endLineNumber;

  if (selection.endColumn == 1) {
    endLineNumber--;
  }

  // Nothing to sort if user didn't select anything.
  if (startLineNumber >= endLineNumber) {
    return null;
  }

  final linesToSort = <String>[];
  // Get the contents of the selection to be sorted.
  for (int lineNumber = startLineNumber; lineNumber <= endLineNumber; lineNumber++) {
    linesToSort.add(model.getLineContent(lineNumber));
  }

  var sorted = List<String>.from(linesToSort);
  // 1:1: `sorted.sort(SortLinesCommand._COLLATOR.value.compare)`.
  final collator = SortLinesCommand._COLLATOR.value;
  sorted.sort((a, b) => (collator as dynamic).compare(a, b) as int);

  // If descending, reverse the order.
  if (descending == true) {
    sorted = sorted.reversed.toList();
  }

  return _SortData(startLineNumber, endLineNumber, linesToSort, sorted);
}

/// 1:1: `function sortLines(model, selection, descending): ISingleEditOperation | null`.
ISingleEditOperation? _sortLines(ITextModelForCommand model, Selection selection, bool descending) {
  final data = _getSortData(model, selection, descending);
  if (data == null) {
    return null;
  }
  return EditOperation.replace(
    Range(data.startLineNumber, 1, data.endLineNumber, model.getLineMaxColumn(data.endLineNumber)),
    data.after.join('\n'),
  );
}
