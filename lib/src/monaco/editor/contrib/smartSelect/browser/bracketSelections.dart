// 1:1 port of `editor/contrib/smartSelect/browser/bracketSelections.ts`.
// Erased TS contracts (ITextModel / bracket pair types) are local carriers;
// `SelectionRange` is reused from the already-ported wordSelections.dart.
// The source's async time-slicing is preserved as round/duration checks; since
// Dart has no DOM timer need here, the continuation runs inline with identical
// observable output.
import '../../../../base/common/linkedList.dart' show LinkedList;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import './wordSelections.dart' show SelectionRange;

/// 1:1: `bracketInfo` shape used by `findNextBracket` / `findPrevBracket`.
abstract class IBracketInfo {
  bool get isOpeningBracket;
  String get bracketText;
  List<IBracketInfo> getOpeningBrackets();
}

/// 1:1: `{ bracketInfo, range }` returned by the bracket pair model.
abstract class IFoundBracket {
  IBracketInfo get bracketInfo;
  Range get range;
}

/// 1:1: `model.bracketPairs`.
abstract class IBracketPairs {
  IFoundBracket? findNextBracket(Position pos);
  IFoundBracket? findPrevBracket(Position pos);
}

/// 1:1: erased `ITextModel` members consumed by this provider.
abstract class IBracketSelectionModel {
  IBracketPairs get bracketPairs;
  int getLineFirstNonWhitespaceColumn(int lineNumber);
  int getLineLastNonWhitespaceColumn(int lineNumber);
}

/// 1:1: `BracketSelectionRangeProvider implements SelectionRangeProvider`
class BracketSelectionRangeProvider {
  /// 1:1: `public static _maxDuration = 30` (mutable in TS)
  // ignore: prefer_final_fields
  static int _maxDuration = 30;

  /// 1:1: `private static readonly _maxRounds = 2`
  static const int _maxRounds = 2;

  /// 1:1: `provideSelectionRanges(model, positions)`
  Future<List<List<SelectionRange>>> provideSelectionRanges(
    IBracketSelectionModel model,
    List<Position> positions,
  ) async {
    final List<List<SelectionRange>> result = <List<SelectionRange>>[];

    for (final Position position in positions) {
      final List<SelectionRange> bucket = <SelectionRange>[];
      result.add(bucket);

      final Map<String, LinkedList<Range>> ranges =
          <String, LinkedList<Range>>{};
      _bracketsRightYield(0, model, position, ranges);
      _bracketsLeftYield(0, model, position, ranges, bucket);
    }

    return result;
  }

  static void _bracketsRightYield(
    int round,
    IBracketSelectionModel model,
    Position pos,
    Map<String, LinkedList<Range>> ranges,
  ) {
    final Map<String, int> counts = <String, int>{};
    final int t1 = DateTime.now().millisecondsSinceEpoch;
    while (true) {
      if (round >= _maxRounds) {
        return;
      }
      final IFoundBracket? bracket = model.bracketPairs.findNextBracket(pos);
      if (bracket == null) {
        return;
      }
      final int d = DateTime.now().millisecondsSinceEpoch - t1;
      if (d > _maxDuration) {
        round++;
        continue;
      }
      if (bracket.bracketInfo.isOpeningBracket) {
        final String key = bracket.bracketInfo.bracketText;
        final int val = counts.containsKey(key) ? counts[key]! : 0;
        counts[key] = val + 1;
      } else {
        final String key = bracket.bracketInfo.getOpeningBrackets()[0].bracketText;
        int val = counts.containsKey(key) ? counts[key]! : 0;
        val -= 1;
        counts[key] = val < 0 ? 0 : val;
        if (val < 0) {
          LinkedList<Range>? list = ranges[key];
          if (list == null) {
            list = LinkedList<Range>();
            ranges[key] = list;
          }
          list.push(bracket.range);
        }
      }
      pos = bracket.range.getEndPosition();
    }
  }

  static void _bracketsLeftYield(
    int round,
    IBracketSelectionModel model,
    Position pos,
    Map<String, LinkedList<Range>> ranges,
    List<SelectionRange> bucket,
  ) {
    final Map<String, int> counts = <String, int>{};
    final int t1 = DateTime.now().millisecondsSinceEpoch;
    while (true) {
      if (round >= _maxRounds && ranges.isEmpty) {
        return;
      }
      final IFoundBracket? bracket = model.bracketPairs.findPrevBracket(pos);
      if (bracket == null) {
        return;
      }
      final int d = DateTime.now().millisecondsSinceEpoch - t1;
      if (d > _maxDuration) {
        round++;
        continue;
      }
      if (!bracket.bracketInfo.isOpeningBracket) {
        final String key = bracket.bracketInfo.getOpeningBrackets()[0].bracketText;
        final int val = counts.containsKey(key) ? counts[key]! : 0;
        counts[key] = val + 1;
      } else {
        final String key = bracket.bracketInfo.bracketText;
        int val = counts.containsKey(key) ? counts[key]! : 0;
        val -= 1;
        counts[key] = val < 0 ? 0 : val;
        if (val < 0) {
          final LinkedList<Range>? list = ranges[key];
          if (list != null) {
            final Range closing = list.shift()!;
            if (list.size == 0) {
              ranges.remove(key);
            }
            final Range innerBracket = Range.fromPositions(
                bracket.range.getEndPosition(),
                end: closing.getStartPosition());
            final Range outerBracket = Range.fromPositions(
                bracket.range.getStartPosition(),
                end: closing.getEndPosition());
            bucket.add(SelectionRange(innerBracket));
            bucket.add(SelectionRange(outerBracket));
            _addBracketLeading(model, outerBracket, bucket);
          }
        }
      }
      pos = bracket.range.getStartPosition();
    }
  }

  static void _addBracketLeading(
    IBracketSelectionModel model,
    Range bracket,
    List<SelectionRange> bucket,
  ) {
    if (bracket.startLineNumber == bracket.endLineNumber) {
      return;
    }
    // xxxxxxxx {
    //
    // }
    final int startLine = bracket.startLineNumber;
    final int column = model.getLineFirstNonWhitespaceColumn(startLine);
    if (column != 0 && column != bracket.startColumn) {
      bucket.add(SelectionRange(Range.fromPositions(
          Position(startLine, column), end: bracket.getEndPosition())));
      bucket.add(SelectionRange(Range.fromPositions(
          Position(startLine, 1), end: bracket.getEndPosition())));
    }

    // xxxxxxxx
    // {
    //
    // }
    final int aboveLine = startLine - 1;
    if (aboveLine > 0) {
      final int column = model.getLineFirstNonWhitespaceColumn(aboveLine);
      if (column == bracket.startColumn &&
          column != model.getLineLastNonWhitespaceColumn(aboveLine)) {
        bucket.add(SelectionRange(Range.fromPositions(
            Position(aboveLine, column), end: bracket.getEndPosition())));
        bucket.add(SelectionRange(Range.fromPositions(
            Position(aboveLine, 1), end: bracket.getEndPosition())));
      }
    }
  }
}
