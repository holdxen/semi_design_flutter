// 1:1 port of vs/editor/common/languages/textToHtmlTokenizer.ts
// Erased TS types (IState / ITokenizationSupport) are local carriers;
// runtime functions are ported verbatim.
// Runtime truth: tool/ts2dart/_batch275_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/charCode.dart' show CharCode;
import '../../../base/common/strings.dart' as strings;
import '../encodedTokenAttributes.dart' show LanguageId;
import '../languages.dart' show EncodedTokenizationResult, TokenizationRegistry;
import '../tokens/lineTokens.dart'
    show IViewLineTokens, ILanguageIdCodec, LineTokens;
import 'language.dart' show ILanguageServiceType;
import 'nullTokenize.dart' show NullState, nullTokenizeEncoded;

/// 1:1: `Omit<ITokenizationSupport, 'tokenize'>`
abstract class IReducedTokenizationSupport {
  Object getInitialState();
  EncodedTokenizationResult tokenizeEncoded(
      String buffer, bool hasEOL, Object state);
}

class _FallbackTokenizationSupport implements IReducedTokenizationSupport {
  @override
  Object getInitialState() => NullState.instance;

  @override
  EncodedTokenizationResult tokenizeEncoded(
          String buffer, bool hasEOL, Object state) =>
      nullTokenizeEncoded(LanguageId.nullId, state);
}

/// 1:1: `const fallback: IReducedTokenizationSupport`
final IReducedTokenizationSupport _fallback = _FallbackTokenizationSupport();

/// 1:1: `tokenizeToStringSync(languageService, text, languageId)`
String tokenizeToStringSync(
  ILanguageServiceType languageService,
  String text,
  String languageId,
) {
  final IReducedTokenizationSupport support =
      (TokenizationRegistry.get(languageId) as IReducedTokenizationSupport?) ??
          _fallback;
  return tokenizeToStringInternal(text, languageService.languageIdCodec, support);
}

/// 1:1: `tokenizeToString(languageService, text, languageId)`
Future<String> tokenizeToString(
  ILanguageServiceType languageService,
  String text,
  String? languageId,
) async {
  if (languageId == null) {
    return tokenizeToStringInternal(text, languageService.languageIdCodec, _fallback);
  }
  final Object? support = await TokenizationRegistry.getOrCreate(languageId);
  return tokenizeToStringInternal(
    text,
    languageService.languageIdCodec,
    (support as IReducedTokenizationSupport?) ?? _fallback,
  );
}

/// JS `String.charCodeAt` returns NaN out of range; `String.fromCharCode(NaN)`
/// produces a NUL code unit. Dart throws, so use -1 as a distinct sentinel
/// (actual NUL remains 0 and still takes the &#00; branch).
int _jsCharCodeAt(String text, int index) =>
    index < 0 || index >= text.length ? -1 : text.codeUnitAt(index);

/// 1:1: `tokenizeLineToHTML(...)`
String tokenizeLineToHTML(
  String text,
  IViewLineTokens viewLineTokens,
  List<String> colorMap,
  int startOffset,
  int endOffset,
  int tabSize,
  bool useNbsp,
) {
  String result = '<div>';
  int charIndex = 0;
  int width = 0;
  bool prevIsSpace = true;

  for (int tokenIndex = 0, tokenCount = viewLineTokens.getCount();
      tokenIndex < tokenCount;
      tokenIndex++) {
    final int tokenEndIndex = viewLineTokens.getEndOffset(tokenIndex);
    String partContent = '';

    for (; charIndex < tokenEndIndex && charIndex < endOffset; charIndex++) {
      final int charCode = _jsCharCodeAt(text, charIndex);
      final bool isTab = charCode == CharCode.Tab;

      width += strings.isFullWidthCharacter(charCode) ? 2 : (isTab ? 0 : 1);

      if (charIndex < startOffset) {
        if (isTab) {
          final int remainder = width % tabSize;
          width += remainder == 0 ? tabSize : tabSize - remainder;
        }
        continue;
      }

      switch (charCode) {
        case CharCode.Tab:
          final int remainder = width % tabSize;
          final int insertSpacesCount =
              remainder == 0 ? tabSize : tabSize - remainder;
          width += insertSpacesCount;
          int spacesRemaining = insertSpacesCount;
          while (spacesRemaining > 0) {
            if (useNbsp && prevIsSpace) {
              partContent += '&#160;';
              prevIsSpace = false;
            } else {
              partContent += ' ';
              prevIsSpace = true;
            }
            spacesRemaining--;
          }
          break;
        case CharCode.LessThan:
          partContent += '&lt;';
          prevIsSpace = false;
          break;
        case CharCode.GreaterThan:
          partContent += '&gt;';
          prevIsSpace = false;
          break;
        case CharCode.Ampersand:
          partContent += '&amp;';
          prevIsSpace = false;
          break;
        case CharCode.Null:
          partContent += '&#00;';
          prevIsSpace = false;
          break;
        case CharCode.UTF8_BOM:
        case CharCode.LINE_SEPARATOR:
        case CharCode.PARAGRAPH_SEPARATOR:
        case CharCode.NEXT_LINE:
          partContent += '\uFFFD';
          prevIsSpace = false;
          break;
        case CharCode.CarriageReturn:
          partContent += '&#8203';
          prevIsSpace = false;
          break;
        case CharCode.Space:
          if (useNbsp && prevIsSpace) {
            partContent += '&#160;';
            prevIsSpace = false;
          } else {
            partContent += ' ';
            prevIsSpace = true;
          }
          break;
        default:
          partContent += charCode < 0
              ? String.fromCharCode(0)
              : String.fromCharCode(charCode);
          prevIsSpace = false;
      }
    }

    if (tokenEndIndex <= startOffset) {
      continue;
    }

    result +=
        '<span style="${viewLineTokens.getInlineStyle(tokenIndex, colorMap)}">$partContent</span>';

    if (tokenEndIndex > endOffset || charIndex >= endOffset || startOffset >= endOffset) {
      break;
    }
  }

  result += '</div>';
  return result;
}

/// 1:1: `_tokenizeToString(text, languageIdCodec, tokenizationSupport)`
/// (Dart cannot expose a library-private name, so it is public here.)
String tokenizeToStringInternal(
  String text,
  ILanguageIdCodec languageIdCodec,
  IReducedTokenizationSupport tokenizationSupport,
) {
  String result = '<div class="monaco-tokenized-source">';
  final List<String> lines = strings.splitLines(text);
  Object currentState = tokenizationSupport.getInitialState();
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    if (i > 0) {
      result += '<br/>';
    }

    final EncodedTokenizationResult tokenizationResult =
        tokenizationSupport.tokenizeEncoded(line, true, currentState);
    LineTokens.convertToEndOffset(tokenizationResult.tokens, line.length);
    final LineTokens lineTokens =
        LineTokens(tokenizationResult.tokens, line, languageIdCodec);
    final IViewLineTokens viewLineTokens = lineTokens.inflate();

    int startOffset = 0;
    for (int j = 0; j < viewLineTokens.getCount(); j++) {
      final String type = viewLineTokens.getClassName(j);
      final int endIndex = viewLineTokens.getEndOffset(j);
      result +=
          '<span class="$type">${strings.escape(line.substring(startOffset, endIndex))}</span>';
      startOffset = endIndex;
    }

    currentState = tokenizationResult.endState!;
  }

  result += '</div>';
  return result;
}
