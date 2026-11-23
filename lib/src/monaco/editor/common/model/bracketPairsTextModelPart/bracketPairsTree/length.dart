// 1:1 port of vscode/src/vs/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/length.ts
// 严格 1:1 翻译，勿改 API。Length 是 TS 的 number brand，运行时即 number → Dart int 承载。
import '../../../../../base/common/strings.dart' show splitLines;
import '../../../core/position.dart' show Position;
import '../../../core/range.dart' show Range;
import '../../../core/text/textLength.dart' show TextLength;

/// 1:1: `export type Length = { _brand: 'Length' }` — 运行时是 number。
typedef Length = int;

/// 1:1: `function lengthDiff`
Length lengthDiff(int startLineCount, int startColumnCount, int endLineCount, int endColumnCount) =>
    startLineCount != endLineCount
        ? toLength(endLineCount - startLineCount, endColumnCount)
        : toLength(0, endColumnCount - startColumnCount);

/// 1:1: `export const lengthZero`
const Length lengthZero = 0;

/// 1:1: `lengthIsZero`
bool lengthIsZero(Length length) => length == 0;

/// 52 bits 可用：高 26 位存 line，低 26 位存 column。
const int factor = 1 << 26;

/// 1:1: `toLength`
Length toLength(int lineCount, int columnCount) => lineCount * factor + columnCount;

/// 1:1: `lengthToObj`
TextLength lengthToObj(Length length) {
  final int lineCount = (length / factor).floor();
  final int columnCount = length - lineCount * factor;
  return TextLength(lineCount, columnCount);
}

/// 1:1: `lengthGetLineCount`
int lengthGetLineCount(Length length) => (length / factor).floor();

/// 1:1: `lengthGetColumnCountIfZeroLineCount`
int lengthGetColumnCountIfZeroLineCount(Length length) => length;

/// 1:1: `lengthAdd`
Length lengthAdd(Length l1, Length l2) {
  int r = l1 + l2;
  if (l2 >= factor) {
    r = r - (l1 % factor);
  }
  return r;
}

/// 1:1: `sumLengths`
Length sumLengths<T>(List<T> items, Length Function(T item) lengthFn) =>
    items.fold<Length>(lengthZero, (Length a, T b) => lengthAdd(a, lengthFn(b)));

/// 1:1: `lengthEquals`
bool lengthEquals(Length length1, Length length2) => length1 == length2;

/// 1:1: `lengthDiffNonNegative`
Length lengthDiffNonNegative(Length length1, Length length2) {
  final int l1 = length1;
  final int l2 = length2;
  final int diff = l2 - l1;
  if (diff <= 0) {
    return lengthZero;
  }
  final int lineCount1 = (l1 / factor).floor();
  final int lineCount2 = (l2 / factor).floor();
  final int colCount2 = l2 - lineCount2 * factor;
  if (lineCount1 == lineCount2) {
    final int colCount1 = l1 - lineCount1 * factor;
    return toLength(0, colCount2 - colCount1);
  } else {
    return toLength(lineCount2 - lineCount1, colCount2);
  }
}

/// 1:1: `lengthLessThan`
bool lengthLessThan(Length length1, Length length2) => length1 < length2;

/// 1:1: `lengthLessThanEqual`
bool lengthLessThanEqual(Length length1, Length length2) => length1 <= length2;

/// 1:1: `lengthGreaterThanEqual`
bool lengthGreaterThanEqual(Length length1, Length length2) => length1 >= length2;

/// 1:1: `lengthToPosition`
Position lengthToPosition(Length length) {
  final int l = length;
  final int lineCount = (l / factor).floor();
  final int colCount = l - lineCount * factor;
  return Position(lineCount + 1, colCount + 1);
}

/// 1:1: `positionToLength`
Length positionToLength(Position position) => toLength(position.lineNumber - 1, position.column - 1);

/// 1:1: `lengthsToRange`
Range lengthsToRange(Length lengthStart, Length lengthEnd) {
  final int l = lengthStart;
  final int lineCount = (l / factor).floor();
  final int colCount = l - lineCount * factor;
  final int l2 = lengthEnd;
  final int lineCount2 = (l2 / factor).floor();
  final int colCount2 = l2 - lineCount2 * factor;
  return Range(lineCount + 1, colCount + 1, lineCount2 + 1, colCount2 + 1);
}

/// 1:1: `lengthOfRange`
TextLength lengthOfRange(Range range) {
  if (range.startLineNumber == range.endLineNumber) {
    return TextLength(0, range.endColumn - range.startColumn);
  } else {
    return TextLength(range.endLineNumber - range.startLineNumber, range.endColumn - 1);
  }
}

/// 1:1: `lengthCompare`
int lengthCompare(Length length1, Length length2) => length1 - length2;

/// 1:1: `lengthOfString`
Length lengthOfString(String str) {
  final List<String> lines = splitLines(str);
  return toLength(lines.length - 1, lines[lines.length - 1].length);
}

/// 1:1: `lengthOfStringObj`
TextLength lengthOfStringObj(String str) {
  final List<String> lines = splitLines(str);
  return TextLength(lines.length - 1, lines[lines.length - 1].length);
}

/// 1:1: `lengthHash`
int lengthHash(Length length) => length;

/// 1:1: `lengthMax`
Length lengthMax(Length length1, Length length2) => length1 > length2 ? length1 : length2;
