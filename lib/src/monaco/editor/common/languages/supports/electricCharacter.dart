// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/supports/electricCharacter.ts
// Translated 1:1. RichEditBrackets / ScopedLineTokens are erased interfaces and
// are local carriers; the reversed-bracket search mirrors BracketsUtils.
// ---------------------------------------------------------------------------
import '../../core/range.dart' show Range;

/// 1:1: `IElectricAction`.
class IElectricAction {
  final String matchOpenBracket;

  IElectricAction(this.matchOpenBracket);
}

/// 1:1: `IProcessedBracketPair` carrier.
class ProcessedBracketPairForElectric {
  final String open;
  final String close;
  final RegExp openRegExp;
  final RegExp closeRegExp;

  ProcessedBracketPairForElectric(
      this.open, this.close, this.openRegExp, this.closeRegExp);
}

/// 1:1: `RichEditBrackets` surface read here.
abstract class IRichBracketsForElectric {
  List<ProcessedBracketPairForElectric> get brackets;
  RegExp get reversedRegex;
  Map<String, bool> get textIsOpenBracket;
}

/// 1:1: `ScopedLineTokens` surface read here.
abstract class IScopedLineTokensForElectric {
  int findTokenIndexAtOffset(int offset);
  int getStandardTokenType(int tokenIndex);
  String getLineContent();
  String getActualLineContentBefore(int offset);
}

/// 1:1: `IgnoreBracketsInTokens.value`.
const int _ignoreBracketsInTokens = 7;

bool ignoreBracketsInToken(int standardTokenType) =>
    (standardTokenType & _ignoreBracketsInTokens) != 0;

/// 1:1: `BracketsUtils.findPrevBracketInRange` (logic folded in).
Range? _findPrevBracketInRange(
    RegExp reversedRegex, int lineNumber, String lineText,
    int startOffset, int endOffset) {
  final String reversedLineText =
      lineText.split('').reversed.join();
  final String reversedSubstr = reversedLineText.substring(
      lineText.length - endOffset, lineText.length - startOffset);
  final RegExpMatch? m = reversedRegex.firstMatch(reversedSubstr);
  if (m == null) {
    return null;
  }
  final int matchOffset = reversedSubstr.length - m.start;
  final int matchLength = m.group(0)!.length;
  final int absoluteMatchOffset = startOffset + matchOffset;
  return Range(
    lineNumber,
    absoluteMatchOffset - matchLength + 1,
    lineNumber,
    absoluteMatchOffset + 1,
  );
}

/// 1:1: `export class BracketElectricCharacterSupport`.
class BracketElectricCharacterSupport {
  final IRichBracketsForElectric? _richEditBrackets;

  BracketElectricCharacterSupport(this._richEditBrackets);

  /// 1:1: `getElectricCharacters()`.
  List<String> getElectricCharacters() {
    final List<String> result = <String>[];
    final IRichBracketsForElectric? brackets = _richEditBrackets;
    if (brackets != null) {
      for (final ProcessedBracketPairForElectric bracket in brackets.brackets) {
        // The source iterates characters of `close`, not the whole string.
        for (int i = 0; i < bracket.close.length; i++) {
          result.add(bracket.close[i]);
        }
      }
    }
    return result.toSet().toList();
  }

  /// 1:1: `onElectricCharacter`.
  IElectricAction? onElectricCharacter(String character,
      IScopedLineTokensForElectric context, int column) {
    final IRichBracketsForElectric? brackets = _richEditBrackets;
    if (brackets == null || brackets.brackets.isEmpty) {
      return null;
    }

    final int tokenIndex = context.findTokenIndexAtOffset(column - 1);
    if (ignoreBracketsInToken(context.getStandardTokenType(tokenIndex))) {
      return null;
    }

    final RegExp reversedBracketRegex = brackets.reversedRegex;
    final String lineContent = context.getLineContent();
    final String text = lineContent.substring(0, column - 1) + character;
    final Range? r =
        _findPrevBracketInRange(reversedBracketRegex, 1, text, 0, text.length);
    if (r == null) {
      return null;
    }

    final String bracketText =
        text.substring(r.startColumn - 1, r.endColumn - 1).toLowerCase();
    final bool isOpen = brackets.textIsOpenBracket[bracketText] == true;
    if (isOpen) {
      return null;
    }

    final String textBeforeBracket =
        context.getActualLineContentBefore(r.startColumn - 1);
    if (!RegExp(r'^\s*$').hasMatch(textBeforeBracket)) {
      return null;
    }

    return IElectricAction(bracketText);
  }
}
