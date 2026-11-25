// 1:1 port of `editor/contrib/smartSelect/browser/wordSelections.ts`.
// `SelectionRange` / `SelectionRangeProvider` / `ITextModel` are erased TS
// interfaces (per repo convention); only the runtime class is ported. The
// model members the provider reads are carried as a minimal contract so the
// 1:1 method bodies compile and can be replay-tested against TS truth.
import '../../../../base/common/charCode.dart';
import '../../../../base/common/strings.dart' as strings;
import '../../../common/core/position.dart';
import '../../../common/core/range.dart';
import '../../../common/core/wordHelper.dart' show IWordAtPosition;

/// 1:1: `SelectionRange` interface (`languages.ts`) — erased in Dart; this
/// carrier keeps its single `range` field for replay fidelity.
class SelectionRange {
  final IRange range;
  SelectionRange(this.range);
}

/// Minimal shape of the erased `ITextModel` (`model.ts`) consumed by
/// `WordSelectionRangeProvider`.
abstract class IWordSelectionModel {
  IRange getFullModelRange();

  IWordAtPosition? getWordAtPosition(Position pos);

  int getLineLength(int lineNumber);

  int getLineFirstNonWhitespaceColumn(int lineNumber);

  int getLineLastNonWhitespaceColumn(int lineNumber);

  int getLineMaxColumn(int lineNumber);
}

/// 1:1: `export class WordSelectionRangeProvider implements SelectionRangeProvider`.
class WordSelectionRangeProvider {
  final bool _selectSubwords;

  WordSelectionRangeProvider([bool? selectSubwords])
      : _selectSubwords = selectSubwords ?? true;

  /// 1:1: `provideSelectionRanges(model, positions)`.
  List<List<SelectionRange>> provideSelectionRanges(
    IWordSelectionModel model,
    List<Position> positions,
  ) {
    final result = <List<SelectionRange>>[];
    for (final position in positions) {
      final bucket = <SelectionRange>[];
      result.add(bucket);
      if (_selectSubwords) {
        _addInWordRanges(bucket, model, position);
      }
      _addWordRanges(bucket, model, position);
      _addWhitespaceLine(bucket, model, position);
      bucket.add(SelectionRange(model.getFullModelRange()));
    }
    return result;
  }

  void _addInWordRanges(List<SelectionRange> bucket, IWordSelectionModel model, Position pos) {
    final obj = model.getWordAtPosition(pos);
    if (obj == null) {
      return;
    }

    final word = obj.word;
    final startColumn = obj.startColumn;
    final offset = pos.column - startColumn;
    int start = offset;
    int end = offset;
    int lastCh = 0;

    // LEFT anchor (start)
    for (; start >= 0; start--) {
      final ch = word.codeUnitAt(start);
      if ((start != offset) && (ch == CharCode.Underline || ch == CharCode.Dash)) {
        // foo-bar OR foo_bar
        break;
      } else if (strings.isLowerAsciiLetter(ch) && strings.isUpperAsciiLetter(lastCh)) {
        // fooBar
        break;
      }
      lastCh = ch;
    }
    start += 1;

    // RIGHT anchor (end)
    for (; end < word.length; end++) {
      final ch = word.codeUnitAt(end);
      if (strings.isUpperAsciiLetter(ch) && strings.isLowerAsciiLetter(lastCh)) {
        // fooBar
        break;
      } else if (ch == CharCode.Underline || ch == CharCode.Dash) {
        // foo-bar OR foo_bar
        break;
      }
      lastCh = ch;
    }

    if (start < end) {
      bucket.add(SelectionRange(Range(pos.lineNumber, startColumn + start, pos.lineNumber, startColumn + end)));
    }
  }

  void _addWordRanges(List<SelectionRange> bucket, IWordSelectionModel model, Position pos) {
    final word = model.getWordAtPosition(pos);
    if (word != null) {
      bucket.add(SelectionRange(
        Range(pos.lineNumber, word.startColumn, pos.lineNumber, word.endColumn),
      ));
    }
  }

  void _addWhitespaceLine(List<SelectionRange> bucket, IWordSelectionModel model, Position pos) {
    if (model.getLineLength(pos.lineNumber) > 0 &&
        model.getLineFirstNonWhitespaceColumn(pos.lineNumber) == 0 &&
        model.getLineLastNonWhitespaceColumn(pos.lineNumber) == 0) {
      bucket.add(SelectionRange(Range(pos.lineNumber, 1, pos.lineNumber, model.getLineMaxColumn(pos.lineNumber))));
    }
  }
}
