// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewModel/viewModelDecoration.ts
// Translated 1:1 from TypeScript.
//
// `ViewModelDecoration` is already declared in `viewModel.dart` (the port's
// earlier SCC layout); it is re-exported here so consumers use the canonical
// path without creating a duplicate type.
// ---------------------------------------------------------------------------

import '../core/range.dart' show Range;
import '../encodedTokenAttributes.dart' show StandardTokenType;

export '../viewModel.dart' show ViewModelDecoration;

/// 1:1: `isModelDecorationVisible`.
bool isModelDecorationVisible(Object model, Object decoration) {
  final dynamic d = decoration;
  final Object options = d.options as Object;
  bool flag(String name) => options is Map
      ? options[name] == true
      : (options as dynamic).$name == true;
  if (flag('hideInCommentTokens') &&
      isModelDecorationInComment(model, decoration)) {
    return false;
  }
  if (flag('hideInStringTokens') &&
      isModelDecorationInString(model, decoration)) {
    return false;
  }
  return true;
}

/// 1:1: `isModelDecorationInComment`.
bool isModelDecorationInComment(Object model, Object decoration) =>
    _testTokensInRange(
      model,
      (decoration as dynamic).range as Range,
      (int tokenType) => tokenType == StandardTokenType.comment,
    );

/// 1:1: `isModelDecorationInString`.
bool isModelDecorationInString(Object model, Object decoration) =>
    _testTokensInRange(
      model,
      (decoration as dynamic).range as Range,
      (int tokenType) => tokenType == StandardTokenType.string,
    );

/// 1:1: `testTokensInRange` — calls the callback for every token intersecting
/// the range; stops and returns false as soon as the callback returns false.
bool _testTokensInRange(
  Object model,
  Range range,
  bool Function(int tokenType) callback,
) {
  final dynamic tokenization = (model as dynamic).tokenization;
  for (int lineNumber = range.startLineNumber;
      lineNumber <= range.endLineNumber;
      lineNumber++) {
    final Object lineTokens =
        tokenization.getLineTokens(lineNumber) as Object;
    final bool isFirstLine = lineNumber == range.startLineNumber;
    final bool isEndLine = lineNumber == range.endLineNumber;

    int tokenIdx = isFirstLine
        ? (lineTokens as dynamic).findTokenIndexAtOffset(range.startColumn - 1) as int
        : 0;
    while (tokenIdx < ((lineTokens as dynamic).getCount() as int)) {
      if (isEndLine) {
        final int startOffset =
            (lineTokens as dynamic).getStartOffset(tokenIdx) as int;
        if (startOffset > range.endColumn - 1) break;
      }
      final int type =
          (lineTokens as dynamic).getStandardTokenType(tokenIdx) as int;
      if (!callback(type)) return false;
      tokenIdx++;
    }
  }
  return true;
}
