// 1:1 port of vscode/src/vs/base/common/filters.ts
// 严格 1:1 翻译，勿改类名/API。
import 'charCode.dart' show CharCode;
import 'map.dart' show LRUCache;
import 'naturalLanguage/korean.dart' show getKoreanAltChars;
import 'normalization.dart' show tryNormalizeToBase;
import 'strings.dart' as strings;

/// 1:1: `export interface IFilter` (callable)
typedef IFilter = List<IMatch>? Function(String word, String wordToMatchAgainst);

/// 1:1: `export interface IMatch`
class IMatch {
  int start;
  int end;
  IMatch(this.start, this.end);

  @override
  String toString() => '{start: $start, end: $end}';

  @override
  bool operator ==(Object other) =>
      other is IMatch && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// 1:1: `export const emptyMatches` — 源码 Object.freeze 数组及其元素。
/// Dart 用不可增长、元素不可变的方式承载；测试通过捕获 StateError 验证冻结语义。
final List<IMatch> emptyMatches = List<IMatch>.unmodifiable(<IMatch>[
  _FrozenMatch(0, 0),
]);

class _FrozenMatch extends IMatch {
  _FrozenMatch(int start, int end) : super(start, end);
}

/// 1:1: `export function or`
IFilter or(List<IFilter> filter) {
  return (String word, String wordToMatchAgainst) {
    for (int i = 0, len = filter.length; i < len; i++) {
      final List<IMatch>? match = filter[i](word, wordToMatchAgainst);
      if (match != null) {
        return match;
      }
    }
    return null;
  };
}

/// 1:1: `_matchesPrefix`
List<IMatch>? _matchesPrefix(bool ignoreCase, String word, String wordToMatchAgainst) {
  if (wordToMatchAgainst.isEmpty || wordToMatchAgainst.length < word.length) {
    return null;
  }

  final bool matches;
  if (ignoreCase) {
    matches = strings.startsWithIgnoreCase(wordToMatchAgainst, word);
  } else {
    matches = wordToMatchAgainst.indexOf(word) == 0;
  }

  if (!matches) {
    return null;
  }

  return word.length > 0 ? <IMatch>[IMatch(0, word.length)] : <IMatch>[];
}

/// 1:1: `export const matchesStrictPrefix`
final IFilter matchesStrictPrefix = (String word, String wordToMatchAgainst) =>
    _matchesPrefix(false, word, wordToMatchAgainst);
/// 1:1: `export const matchesPrefix`
final IFilter matchesPrefix = (String word, String wordToMatchAgainst) =>
    _matchesPrefix(true, word, wordToMatchAgainst);

/// 1:1: `export function matchesContiguousSubString`
List<IMatch>? matchesContiguousSubString(String word, String wordToMatchAgainst) {
  if (word.isEmpty) {
    return emptyMatches;
  }
  if (word.length > wordToMatchAgainst.length) {
    return null;
  }
  final int index = wordToMatchAgainst.toLowerCase().indexOf(word.toLowerCase());
  if (index == -1) {
    return null;
  }
  return <IMatch>[IMatch(index, index + word.length)];
}

/// 1:1: `export function matchesBaseContiguousSubString`
List<IMatch>? matchesBaseContiguousSubString(String word, String wordToMatchAgainst) {
  if (word.isEmpty) {
    return emptyMatches;
  }
  if (word.length > wordToMatchAgainst.length) {
    return null;
  }
  final String w = tryNormalizeToBase(word);
  final String t = tryNormalizeToBase(wordToMatchAgainst);
  final int index = t.indexOf(w);
  if (index == -1) {
    return null;
  }
  return <IMatch>[IMatch(index, index + w.length)];
}

/// 1:1: `export function matchesSubString`
List<IMatch>? matchesSubString(String word, String wordToMatchAgainst) {
  if (word.length > wordToMatchAgainst.length) {
    return null;
  }
  return _matchesSubString(word.toLowerCase(), wordToMatchAgainst.toLowerCase(), 0, 0);
}

List<IMatch>? _matchesSubString(String word, String wordToMatchAgainst, int i, int j) {
  if (i == word.length) {
    return <IMatch>[];
  } else if (j == wordToMatchAgainst.length) {
    return null;
  } else {
    if (word[i] == wordToMatchAgainst[j]) {
      final List<IMatch>? result = _matchesSubString(word, wordToMatchAgainst, i + 1, j + 1);
      if (result != null) {
        return join(IMatch(j, j + 1), result);
      }
      return null;
    }
    return _matchesSubString(word, wordToMatchAgainst, i, j + 1);
  }
}

bool isLower(int code) => CharCode.a <= code && code <= CharCode.z;

/// 1:1: `export function isUpper`
bool isUpper(int code) => CharCode.A <= code && code <= CharCode.Z;

bool isNumber(int code) => CharCode.Digit0 <= code && code <= CharCode.Digit9;

bool isWhitespace(int code) =>
    code == CharCode.Space ||
    code == CharCode.Tab ||
    code == CharCode.LineFeed ||
    code == CharCode.CarriageReturn;

final Set<int> wordSeparators = <int>{
  ...'()[]{}<>`\'"-/;:,.?!'.split('').map((String s) => s.codeUnitAt(0)),
};

bool isWordSeparator(int code) => isWhitespace(code) || wordSeparators.contains(code);

bool charactersMatch(int codeA, int codeB) =>
    (codeA == codeB) || (isWordSeparator(codeA) && isWordSeparator(codeB));

/// 1:1: `alternateCharsCache`
final Map<int, List<int>?> alternateCharsCache = <int, List<int>?>{};

/// 1:1: `getAlternateCodes`
List<int>? getAlternateCodes(int code) {
  if (alternateCharsCache.containsKey(code)) {
    return alternateCharsCache[code];
  }
  List<int>? result;
  final List<int>? codes = getKoreanAltChars(code);
  if (codes != null) {
    result = codes;
  }
  alternateCharsCache[code] = result;
  return result;
}

bool isAlphanumeric(int code) => isLower(code) || isUpper(code) || isNumber(code);

/// 1:1: `join`
List<IMatch> join(IMatch head, List<IMatch> tail) {
  if (tail.isEmpty) {
    tail = <IMatch>[head];
  } else if (head.end == tail[0].start) {
    tail[0].start = head.start;
  } else {
    tail.insert(0, head);
  }
  return tail;
}

/// 1:1: `nextAnchor`
int nextAnchor(String camelCaseWord, int start) {
  for (int i = start; i < camelCaseWord.length; i++) {
    final int c = camelCaseWord.codeUnitAt(i);
    if (isUpper(c) || isNumber(c) || (i > 0 && !isAlphanumeric(camelCaseWord.codeUnitAt(i - 1)))) {
      return i;
    }
  }
  return camelCaseWord.length;
}

/// 1:1: `_matchesCamelCase`
List<IMatch>? _matchesCamelCase(String word, String camelCaseWord, int i, int j) {
  if (i == word.length) {
    return <IMatch>[];
  } else if (j == camelCaseWord.length) {
    return null;
  } else if (word[i] != camelCaseWord[j].toLowerCase()) {
    return null;
  } else {
    List<IMatch>? result;
    int nextUpperIndex = j + 1;
    result = _matchesCamelCase(word, camelCaseWord, i + 1, j + 1);
    while (result == null && (nextUpperIndex = nextAnchor(camelCaseWord, nextUpperIndex)) < camelCaseWord.length) {
      result = _matchesCamelCase(word, camelCaseWord, i + 1, nextUpperIndex);
      nextUpperIndex++;
    }
    return result == null ? null : join(IMatch(j, j + 1), result);
  }
}

/// 1:1: `ICamelCaseAnalysis`
class ICamelCaseAnalysis {
  final double upperPercent;
  final double lowerPercent;
  final double alphaPercent;
  final double numericPercent;
  ICamelCaseAnalysis(this.upperPercent, this.lowerPercent, this.alphaPercent, this.numericPercent);
}

/// 1:1: `analyzeCamelCaseWord`
ICamelCaseAnalysis analyzeCamelCaseWord(String word) {
  int upper = 0, lower = 0, alpha = 0, numeric = 0, code = 0;
  for (int i = 0; i < word.length; i++) {
    code = word.codeUnitAt(i);
    if (isUpper(code)) upper++;
    if (isLower(code)) lower++;
    if (isAlphanumeric(code)) alpha++;
    if (isNumber(code)) numeric++;
  }
  return ICamelCaseAnalysis(
    upper / word.length,
    lower / word.length,
    alpha / word.length,
    numeric / word.length,
  );
}

bool isUpperCaseWord(ICamelCaseAnalysis a) => a.lowerPercent == 0 && a.upperPercent > 0.6;

bool isCamelCaseWord(ICamelCaseAnalysis a) =>
    a.lowerPercent > 0.2 && a.upperPercent < 0.8 && a.alphaPercent > 0.6 && a.numericPercent < 0.2;

/// 1:1: `isCamelCasePattern`
bool isCamelCasePattern(String word) {
  int upper = 0, lower = 0, code = 0, whitespace = 0;
  for (int i = 0; i < word.length; i++) {
    code = word.codeUnitAt(i);
    if (isUpper(code)) upper++;
    if (isLower(code)) lower++;
    if (isWhitespace(code)) whitespace++;
  }
  if ((upper == 0 || lower == 0) && whitespace == 0) {
    return word.length <= 30;
  } else {
    return upper <= 5;
  }
}

/// 1:1: `export function matchesCamelCase`
List<IMatch>? matchesCamelCase(String word, String camelCaseWord) {
  if (camelCaseWord.isEmpty) {
    return null;
  }
  camelCaseWord = camelCaseWord.trim();
  if (camelCaseWord.isEmpty) {
    return null;
  }
  if (!isCamelCasePattern(word)) {
    return null;
  }
  if (camelCaseWord.length > 60) {
    camelCaseWord = camelCaseWord.substring(0, 60);
  }
  final ICamelCaseAnalysis analysis = analyzeCamelCaseWord(camelCaseWord);
  if (!isCamelCaseWord(analysis)) {
    if (!isUpperCaseWord(analysis)) {
      return null;
    }
    camelCaseWord = camelCaseWord.toLowerCase();
  }

  List<IMatch>? result;
  int i = 0;
  word = word.toLowerCase();
  while (i < camelCaseWord.length &&
      (result = _matchesCamelCase(word, camelCaseWord, 0, i)) == null) {
    i = nextAnchor(camelCaseWord, i + 1);
  }
  return result;
}

/// 1:1: `export function matchesWords`
List<IMatch>? matchesWords(String word, String target, [bool contiguous = false]) {
  if (target.isEmpty) {
    return null;
  }
  List<IMatch>? result;
  int targetIndex = 0;
  word = tryNormalizeToBase(word);
  target = tryNormalizeToBase(target);
  final Map<int, List<IMatch>?> memo = <int, List<IMatch>?>{};
  while (targetIndex < target.length) {
    result = _matchesWords(word, target, 0, targetIndex, contiguous, memo);
    if (result != null) {
      break;
    }
    targetIndex = nextWord(target, targetIndex + 1);
  }
  return result;
}

List<IMatch>? cloneMatches(List<IMatch>? matches) {
  if (matches == null) {
    return null;
  }
  final List<IMatch> result = <IMatch>[];
  for (final IMatch m in matches) {
    result.add(IMatch(m.start, m.end));
  }
  return result;
}

List<IMatch>? _matchesWords(String word, String target, int wordIndex, int targetIndex,
    bool contiguous, Map<int, List<IMatch>?> memo) {
  if (wordIndex == word.length) {
    return <IMatch>[];
  } else if (targetIndex == target.length) {
    return null;
  }
  final int memoKey = wordIndex * (target.length + 1) + targetIndex;
  if (memo.containsKey(memoKey)) {
    return cloneMatches(memo[memoKey]);
  }
  final List<IMatch>? computed =
      _matchesWordsCompute(word, target, wordIndex, targetIndex, contiguous, memo);
  memo[memoKey] = cloneMatches(computed);
  return computed;
}

List<IMatch>? _matchesWordsCompute(String word, String target, int wordIndex, int targetIndex,
    bool contiguous, Map<int, List<IMatch>?> memo) {
  int targetIndexOffset = 0;
  if (!charactersMatch(word.codeUnitAt(wordIndex), target.codeUnitAt(targetIndex))) {
    final List<int>? altChars = getAlternateCodes(word.codeUnitAt(wordIndex));
    if (altChars == null) {
      return null;
    }
    for (int k = 0; k < altChars.length; k++) {
      if (!charactersMatch(altChars[k], target.codeUnitAt(targetIndex + k))) {
        return null;
      }
    }
    targetIndexOffset += altChars.length - 1;
  }

  List<IMatch>? result;
  int nextWordIndex = targetIndex + targetIndexOffset + 1;
  result = _matchesWords(word, target, wordIndex + 1, nextWordIndex, contiguous, memo);
  if (!contiguous) {
    while (result == null && (nextWordIndex = nextWord(target, nextWordIndex)) < target.length) {
      result = _matchesWords(word, target, wordIndex + 1, nextWordIndex, contiguous, memo);
      nextWordIndex++;
    }
  }
  if (result == null) {
    return null;
  }

  if (word.codeUnitAt(wordIndex) != target.codeUnitAt(targetIndex)) {
    final List<int>? altChars = getAlternateCodes(word.codeUnitAt(wordIndex));
    if (altChars == null) {
      return result;
    }
    for (int k = 0; k < altChars.length; k++) {
      if (altChars[k] != target.codeUnitAt(targetIndex + k)) {
        return result;
      }
    }
  }

  return join(IMatch(targetIndex, targetIndex + targetIndexOffset + 1), result);
}

int nextWord(String word, int start) {
  for (int i = start; i < word.length; i++) {
    if (isWordSeparator(word.codeUnitAt(i)) ||
        (i > 0 && isWordSeparator(word.codeUnitAt(i - 1)))) {
      return i;
    }
  }
  return word.length;
}

/// 1:1: `fuzzyContiguousFilter` / `fuzzySeparateFilter`
final IFilter _fuzzyContiguousFilter =
    or(<IFilter>[matchesPrefix, matchesCamelCase, matchesContiguousSubString]);
final IFilter _fuzzySeparateFilter =
    or(<IFilter>[matchesPrefix, matchesCamelCase, matchesSubString]);

/// 1:1: `fuzzyRegExpCache`
final LRUCache<String, RegExp> fuzzyRegExpCache = LRUCache<String, RegExp>(10000);

/// 1:1: `export function matchesFuzzy`
List<IMatch>? matchesFuzzy(String word, String wordToMatchAgainst,
    [bool enableSeparateSubstringMatching = false]) {
  if (word.isEmpty) {
    return emptyMatches;
  }

  RegExp? regexp = fuzzyRegExpCache.get(word);
  if (regexp == null) {
    regexp = RegExp(strings.convertSimple2RegExpPattern(word), caseSensitive: false);
    fuzzyRegExpCache.set(word, regexp);
  }

  final RegExpMatch? match = regexp.firstMatch(wordToMatchAgainst);
  if (match != null) {
    return <IMatch>[IMatch(match.start, match.start + match.group(0)!.length)];
  }

  return enableSeparateSubstringMatching
      ? _fuzzySeparateFilter(word, wordToMatchAgainst)
      : _fuzzyContiguousFilter(word, wordToMatchAgainst);
}

/// 1:1: `export function matchesFuzzy2`
List<IMatch>? matchesFuzzy2(String pattern, String word) {
  final List<int>? score = fuzzyScore(pattern, pattern.toLowerCase(), 0,
      word, word.toLowerCase(), 0,
      FuzzyScoreOptions(true, true));
  return score != null ? createMatches(score) : null;
}

/// 1:1: `export function anyScore`
List<int> anyScore(String pattern, String lowPattern, int patternPos, String word, String lowWord, int wordPos) {
  final int max = 13 < pattern.length ? 13 : pattern.length;
  for (; patternPos < max; patternPos++) {
    final List<int>? result = fuzzyScore(pattern, lowPattern, patternPos, word, lowWord, wordPos,
        FuzzyScoreOptions(true, true));
    if (result != null) {
      return result;
    }
  }
  return <int>[0, wordPos];
}

/// 1:1: `export function createMatches`
List<IMatch> createMatches(List<int>? score) {
  if (score == null) {
    return <IMatch>[];
  }
  final List<IMatch> res = <IMatch>[];
  final int wordPos = score[1];
  for (int i = score.length - 1; i > 1; i--) {
    final int pos = score[i] + wordPos;
    final IMatch? last = res.isEmpty ? null : res[res.length - 1];
    if (last != null && last.end == pos) {
      last.end = pos + 1;
    } else {
      res.add(IMatch(pos, pos + 1));
    }
  }
  return res;
}

const int _maxLen = 128;

List<List<int>> _initTable() {
  final List<List<int>> table = <List<int>>[];
  for (int i = 0; i <= _maxLen; i++) {
    table.add(List<int>.filled(_maxLen + 1, 0));
  }
  return table;
}

List<int> _initArr(int maxLen) => List<int>.filled(maxLen + 1, 0);

final List<int> _minWordMatchPos = _initArr(2 * _maxLen);
final List<int> _maxWordMatchPos = _initArr(2 * _maxLen);
final List<List<int>> _diag = _initTable();
final List<List<int>> _table = _initTable();
final List<List<int>> _arrows = _initTable();
const bool _debug = false;

/// 1:1: `isSeparatorAtPos`
bool isSeparatorAtPos(String value, int index) {
  if (index < 0 || index >= value.length) {
    return false;
  }
  // JS codePointAt(index) 合并代理对；Dart runes 需按 UTF-16 offset 取。
  final int code = _codePointAt(value, index);
  switch (code) {
    case CharCode.Underline:
    case CharCode.Dash:
    case CharCode.Period:
    case CharCode.Space:
    case CharCode.Slash:
    case CharCode.Backslash:
    case CharCode.SingleQuote:
    case CharCode.DoubleQuote:
    case CharCode.Colon:
    case CharCode.DollarSign:
    case CharCode.LessThan:
    case CharCode.GreaterThan:
    case CharCode.OpenParen:
    case CharCode.CloseParen:
    case CharCode.OpenSquareBracket:
    case CharCode.CloseSquareBracket:
    case CharCode.OpenCurlyBrace:
    case CharCode.CloseCurlyBrace:
      return true;
    case -1:
      return false;
    default:
      return strings.isEmojiImprecise(code);
  }
}

/// JS `String.prototype.codePointAt`，越界返回 -1，代理对合并。
int _codePointAt(String s, int index) {
  if (index < 0 || index >= s.length) return -1;
  final int first = s.codeUnitAt(index);
  if (first >= 0xD800 && first <= 0xDBFF && index + 1 < s.length) {
    final int second = s.codeUnitAt(index + 1);
    if (second >= 0xDC00 && second <= 0xDFFF) {
      return 0x10000 + ((first - 0xD800) << 10) + (second - 0xDC00);
    }
  }
  return first;
}

/// 1:1: `isWhitespaceAtPos`
bool isWhitespaceAtPos(String value, int index) {
  if (index < 0 || index >= value.length) {
    return false;
  }
  final int code = value.codeUnitAt(index);
  return code == CharCode.Space || code == CharCode.Tab;
}

/// 1:1: `isUpperCaseAtPos`
bool isUpperCaseAtPos(int pos, String word, String wordLow) => word[pos] != wordLow[pos];

/// 1:1: `export function isPatternInWord`
bool isPatternInWord(String patternLow, int patternPos, int patternLen, String wordLow,
    int wordPos, int wordLen, [bool fillMinWordPosArr = false]) {
  while (patternPos < patternLen && wordPos < wordLen) {
    if (patternLow[patternPos] == wordLow[wordPos]) {
      if (fillMinWordPosArr) {
        _minWordMatchPos[patternPos] = wordPos;
      }
      patternPos += 1;
    }
    wordPos += 1;
  }
  return patternPos == patternLen;
}

/// 1:1: `const enum Arrow`
class Arrow {
  static const int Diag = 1;
  static const int Left = 2;
  static const int LeftLeft = 3;
}

/// 1:1: `export type FuzzyScore` — TS tuple，Dart 用 List<int> 承载。
typedef FuzzyScore = List<int>;

/// 1:1: `export namespace FuzzyScore`
class FuzzyScoreNS {
  static final List<int> Default = <int>[-100, 0];
  static bool isDefault(List<int>? score) =>
      score == null || (score.length == 2 && score[0] == -100 && score[1] == 0);
}

/// 1:1: `export abstract class FuzzyScoreOptions`
class FuzzyScoreOptions {
  final bool firstMatchCanBeWeak;
  final bool boostFullMatch;
  static final FuzzyScoreOptions defaultOptions =
      FuzzyScoreOptions(true, false); // source: { boostFullMatch: true, firstMatchCanBeWeak: false }
  FuzzyScoreOptions(this.firstMatchCanBeWeak, this.boostFullMatch);
}

/// 1:1: `export interface FuzzyScorer`
typedef FuzzyScorer = List<int>? Function(
    String pattern, String lowPattern, int patternPos,
    String word, String lowWord, int wordPos,
    [FuzzyScoreOptions? options]);

/// 1:1: `export function fuzzyScore`
List<int>? fuzzyScore(String pattern, String patternLow, int patternStart,
    String word, String wordLow, int wordStart,
    [FuzzyScoreOptions? options]) {
  options ??= FuzzyScoreOptions.defaultOptions;
  final int patternLen = pattern.length > _maxLen ? _maxLen : pattern.length;
  final int wordLen = word.length > _maxLen ? _maxLen : word.length;

  if (patternStart >= patternLen ||
      wordStart >= wordLen ||
      (patternLen - patternStart) > (wordLen - wordStart)) {
    return null;
  }

  if (!isPatternInWord(patternLow, patternStart, patternLen, wordLow, wordStart, wordLen, true)) {
    return null;
  }

  _fillInMaxWordMatchPos(patternLen, wordLen, patternStart, wordStart, patternLow, wordLow);

  int row = 1;
  int column = 1;
  int patternPos = patternStart;
  int wordPos = wordStart;

  final List<bool> hasStrongFirstMatch = <bool>[false];

  row = 1;
  patternPos = patternStart;
  for (; patternPos < patternLen; row++, patternPos++) {
    final int minWordMatchPos = _minWordMatchPos[patternPos];
    final int maxWordMatchPos = _maxWordMatchPos[patternPos];
    final int nextMaxWordMatchPos =
        ((patternPos + 1) < patternLen ? _maxWordMatchPos[patternPos + 1] : wordLen);

    column = minWordMatchPos - wordStart + 1;
    wordPos = minWordMatchPos;
    for (; wordPos < nextMaxWordMatchPos; column++, wordPos++) {
      int score = -9007199254740991; // Number.MIN_SAFE_INTEGER
      bool canComeDiag = false;

      if (wordPos <= maxWordMatchPos) {
        score = _doScore(
          pattern, patternLow, patternPos, patternStart,
          word, wordLow, wordPos, wordLen, wordStart,
          _diag[row - 1][column - 1] == 0,
          hasStrongFirstMatch,
        );
      }

      int diagScore = 0;
      if (score != -9007199254740991) {
        canComeDiag = true;
        diagScore = score + _table[row - 1][column - 1];
      }

      final bool canComeLeft = wordPos > minWordMatchPos;
      final int leftScore = canComeLeft
          ? _table[row][column - 1] + (_diag[row][column - 1] > 0 ? -5 : 0)
          : 0;

      final bool canComeLeftLeft =
          wordPos > minWordMatchPos + 1 && _diag[row][column - 1] > 0;
      final int leftLeftScore = canComeLeftLeft
          ? _table[row][column - 2] + (_diag[row][column - 2] > 0 ? -5 : 0)
          : 0;

      if (canComeLeftLeft &&
          (!canComeLeft || leftLeftScore >= leftScore) &&
          (!canComeDiag || leftLeftScore >= diagScore)) {
        _table[row][column] = leftLeftScore;
        _arrows[row][column] = Arrow.LeftLeft;
        _diag[row][column] = 0;
      } else if (canComeLeft && (!canComeDiag || leftScore >= diagScore)) {
        _table[row][column] = leftScore;
        _arrows[row][column] = Arrow.Left;
        _diag[row][column] = 0;
      } else if (canComeDiag) {
        _table[row][column] = diagScore;
        _arrows[row][column] = Arrow.Diag;
        _diag[row][column] = _diag[row - 1][column - 1] + 1;
      } else {
        throw StateError('not possible');
      }
    }
  }

  if (_debug) {
    // printTables omitted (debug only)
  }

  if (!hasStrongFirstMatch[0] && !options.firstMatchCanBeWeak) {
    return null;
  }

  row--;
  column--;

  final List<int> result = <int>[_table[row][column], wordStart];

  int backwardsDiagLength = 0;
  int maxMatchColumn = 0;

  while (row >= 1) {
    int diagColumn = column;
    do {
      final int arrow = _arrows[row][diagColumn];
      if (arrow == Arrow.LeftLeft) {
        diagColumn = diagColumn - 2;
      } else if (arrow == Arrow.Left) {
        diagColumn = diagColumn - 1;
      } else {
        break;
      }
    } while (diagColumn >= 1);

    if (backwardsDiagLength > 1 &&
        patternLow[patternStart + row - 1] == wordLow[wordStart + column - 1] &&
        !isUpperCaseAtPos(diagColumn + wordStart - 1, word, wordLow) &&
        backwardsDiagLength + 1 > _diag[row][diagColumn]) {
      diagColumn = column;
    }

    if (diagColumn == column) {
      backwardsDiagLength++;
    } else {
      backwardsDiagLength = 1;
    }

    if (maxMatchColumn == 0) {
      maxMatchColumn = diagColumn;
    }

    row--;
    column = diagColumn - 1;
    result.add(column);
  }

  if (wordLen - wordStart == patternLen && options.boostFullMatch) {
    result[0] += 2;
  }

  final int skippedCharsCount = maxMatchColumn - patternLen;
  result[0] -= skippedCharsCount;

  return result;
}

/// 1:1: `_fillInMaxWordMatchPos`
void _fillInMaxWordMatchPos(int patternLen, int wordLen, int patternStart, int wordStart,
    String patternLow, String wordLow) {
  int patternPos = patternLen - 1;
  int wordPos = wordLen - 1;
  while (patternPos >= patternStart && wordPos >= wordStart) {
    if (patternLow[patternPos] == wordLow[wordPos]) {
      _maxWordMatchPos[patternPos] = wordPos;
      patternPos--;
    }
    wordPos--;
  }
}

/// 1:1: `_doScore`
int _doScore(
  String pattern, String patternLow, int patternPos, int patternStart,
  String word, String wordLow, int wordPos, int wordLen, int wordStart,
  bool newMatchStart,
  List<bool> outFirstMatchStrong,
) {
  if (patternLow[patternPos] != wordLow[wordPos]) {
    return -9007199254740991;
  }

  int score = 1;
  bool isGapLocation = false;
  if (wordPos == (patternPos - patternStart)) {
    score = pattern[patternPos] == word[wordPos] ? 7 : 5;
  } else if (isUpperCaseAtPos(wordPos, word, wordLow) &&
      (wordPos == 0 || !isUpperCaseAtPos(wordPos - 1, word, wordLow))) {
    score = pattern[patternPos] == word[wordPos] ? 7 : 5;
    isGapLocation = true;
  } else if (isSeparatorAtPos(wordLow, wordPos) &&
      (wordPos == 0 || !isSeparatorAtPos(wordLow, wordPos - 1))) {
    score = 5;
  } else if (isSeparatorAtPos(wordLow, wordPos - 1) ||
      isWhitespaceAtPos(wordLow, wordPos - 1)) {
    score = 5;
    isGapLocation = true;
  }

  if (score > 1 && patternPos == patternStart) {
    outFirstMatchStrong[0] = true;
  }

  if (!isGapLocation) {
    isGapLocation = isUpperCaseAtPos(wordPos, word, wordLow) ||
        isSeparatorAtPos(wordLow, wordPos - 1) ||
        isWhitespaceAtPos(wordLow, wordPos - 1);
  }

  if (patternPos == patternStart) {
    if (wordPos > wordStart) {
      score -= isGapLocation ? 3 : 5;
    }
  } else {
    if (newMatchStart) {
      score += isGapLocation ? 2 : 0;
    } else {
      score += isGapLocation ? 0 : 1;
    }
  }

  if (wordPos + 1 == wordLen) {
    score -= isGapLocation ? 3 : 5;
  }

  return score;
}

/// 1:1: `export function fuzzyScoreGracefulAggressive`
List<int>? fuzzyScoreGracefulAggressive(String pattern, String lowPattern, int patternPos,
    String word, String lowWord, int wordPos, [FuzzyScoreOptions? options]) =>
    fuzzyScoreWithPermutations(pattern, lowPattern, patternPos, word, lowWord, wordPos, true, options);

/// 1:1: `export function fuzzyScoreGraceful`
List<int>? fuzzyScoreGraceful(String pattern, String lowPattern, int patternPos,
    String word, String lowWord, int wordPos, [FuzzyScoreOptions? options]) =>
    fuzzyScoreWithPermutations(pattern, lowPattern, patternPos, word, lowWord, wordPos, false, options);

/// 1:1: `fuzzyScoreWithPermutations`
List<int>? fuzzyScoreWithPermutations(String pattern, String lowPattern, int patternPos,
    String word, String lowWord, int wordPos, bool aggressive, [FuzzyScoreOptions? options]) {
  List<int>? top = fuzzyScore(pattern, lowPattern, patternPos, word, lowWord, wordPos, options);

  if (top != null && !aggressive) {
    return top;
  }

  if (pattern.length >= 3) {
    final int tries = 7 < pattern.length - 1 ? 7 : pattern.length - 1;
    for (int movingPatternPos = patternPos + 1; movingPatternPos < tries; movingPatternPos++) {
      final String? newPattern = nextTypoPermutation(pattern, movingPatternPos);
      if (newPattern != null) {
        final List<int>? candidate = fuzzyScore(newPattern, newPattern.toLowerCase(),
            patternPos, word, lowWord, wordPos, options);
        if (candidate != null) {
          candidate[0] -= 3;
          if (top == null || candidate[0] > top[0]) {
            top = candidate;
          }
        }
      }
    }
  }

  return top;
}

/// 1:1: `nextTypoPermutation`
String? nextTypoPermutation(String pattern, int patternPos) {
  if (patternPos + 1 >= pattern.length) {
    return null;
  }
  final String swap1 = pattern[patternPos];
  final String swap2 = pattern[patternPos + 1];
  if (swap1 == swap2) {
    return null;
  }
  return pattern.substring(0, patternPos) +
      swap2 +
      swap1 +
      pattern.substring(patternPos + 2);
}
