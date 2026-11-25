// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokenizationTextModelPart.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `export const enum` -> class with static const ints.
//  * `ITokenizationTextModelPart` is an interface: kept as a Dart contract.
//  * StandardTokenType is a TS const enum carried as `int` throughout the
//    ported codebase.
// ---------------------------------------------------------------------------
import 'core/range.dart' show Range;
import 'tokens/lineTokens.dart' show LineTokens;
import 'tokens/sparseMultilineTokens.dart' show SparseMultilineTokens;

/// 1:1: `export const enum BackgroundTokenizationState`.
class BackgroundTokenizationState {
  const BackgroundTokenizationState._();
  static const int InProgress = 1;
  static const int Completed = 2;
}

/// 1:1: `export interface ITokenizationTextModelPart`.
abstract class ITokenizationTextModelPart {
  bool get hasTokens;

  /// Replaces all semantic tokens with the provided `tokens`.
  void setSemanticTokens(List<SparseMultilineTokens>? tokens, bool isComplete);

  /// Merges the provided semantic tokens into existing semantic tokens.
  void setPartialSemanticTokens(
      Range range, List<SparseMultilineTokens>? tokens);

  bool hasCompleteSemanticTokens();

  bool hasSomeSemanticTokens();

  /// Flush all tokenization state.
  void resetTokenization();

  /// Force tokenization information for `lineNumber` to be accurate.
  void forceTokenization(int lineNumber);

  /// If it is cheap, force tokenization information for `lineNumber` to be
  /// accurate. This is based on a heuristic.
  void tokenizeIfCheap(int lineNumber);

  /// Check if tokenization information is accurate for `lineNumber`.
  bool hasAccurateTokensForLine(int lineNumber);

  /// Check if calling `forceTokenization` for this `lineNumber` will be cheap.
  bool isCheapToTokenize(int lineNumber);

  /// Get the tokens for the line `lineNumber`.
  LineTokens getLineTokens(int lineNumber);

  /// Returns the standard token type for a character inserted at a position.
  int getTokenTypeIfInsertingCharacter(
      int lineNumber, int column, String character);

  /// Tokenizes the lines as if they were inserted at [lineNumber, lineNumber).
  List<LineTokens>? tokenizeLinesAt(int lineNumber, List<String> lines);

  String getLanguageId();

  String getLanguageIdAtPosition(int lineNumber, int column);

  void setLanguageId(String languageId, [String? source]);

  int get backgroundTokenizationState;
}

