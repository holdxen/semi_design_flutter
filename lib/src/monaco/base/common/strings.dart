// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/strings.ts (1434 lines)
// Translated 1:1 from TypeScript. Large Unicode data tables live in the
// `part` file strings_data.dart (generated from source).
//
// Adaptations:
//   - `RegExp.exec('')`/`lastIndex` -> `firstMatch` where no state is needed.
//   - `String.matchAll` -> `RegExp.allMatches`; `str.matchAll(re)` invalidates
//     re.lastIndex, so we mirror by using allMatches on a fresh RegExp.
//   - `String.substr(start,len)` (JS) -> `_substr` with JS clamp semantics.
//   - `String.codePointAt(i)` -> `_codePointAt` (combines surrogate pairs).
//   - `*generator` -> `Iterable` via sync*.
//   - `btoa(toBinary(str))` -> base64 of the UTF-16 code-unit bytes.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'cache.dart';
import 'charCode.dart';
import 'lazy.dart';
import 'uint.dart';

part 'strings_data.dart';

/// 1:1: `isFalsyOrWhitespace`
bool isFalsyOrWhitespace(String? str) {
  if (str == null || str.isEmpty) {
    return true;
  }
  return str.trim().isEmpty;
}

final RegExp _formatRegexp = RegExp(r'{(\d+)}');

/// 1:1: `format` (TS rest args -> optional list)
String format(String value, [List<Object?>? args]) {
  if (args == null || args.isEmpty) {
    return value;
  }
  return value.replaceAllMapped(_formatRegexp, (Match match) {
    final String group = match.group(1)!;
    final int idx = int.tryParse(group) ?? -1;
    return (idx < 0 || idx >= args.length) ? match.group(0)! : '${args[idx]}';
  });
}

final RegExp _format2Regexp = RegExp(r'{([^}]+)}');

/// 1:1: `format2`
String format2(String template, Map<String, Object?> values) {
  if (values.isEmpty) {
    return template;
  }
  return template.replaceAllMapped(_format2Regexp, (Match match) {
    final String group = match.group(1)!;
    final Object? v = values[group];
    return v != null ? '$v' : match.group(0)!;
  });
}

/// 1:1: `htmlAttributeEncodeValue`
String htmlAttributeEncodeValue(String value) =>
    value.replaceAllMapped(RegExp(r'''[<>"'&]'''), (Match m) {
      switch (m.group(0)!) {
        case '<':
          return '&lt;';
        case '>':
          return '&gt;';
        case '"':
          return '&quot;';
        case "'":
          return '&apos;';
        case '&':
          return '&amp;';
      }
      return m.group(0)!;
    });

/// 1:1: `escape`
String escape(String html) => html.replaceAllMapped(RegExp(r'[<>&]'), (Match m) {
      switch (m.group(0)!) {
        case '<':
          return '&lt;';
        case '>':
          return '&gt;';
        case '&':
          return '&amp;';
        default:
          return m.group(0)!;
      }
    });

/// 1:1: `escapeRegExpCharacters`
String escapeRegExpCharacters(String value) =>
    value.replaceAllMapped(RegExp(r'[\\\{\}\*\+\?\|\^\$\.\[\]\(\)]'),
        (Match m) => '\\${m.group(0)}');

/// 1:1: `count`
int count(String value, String substr) {
  int result = 0;
  int index = value.indexOf(substr);
  while (index != -1) {
    result++;
    index = value.indexOf(substr, index + substr.length);
  }
  return result;
}

const String Ellipsis = '\u2026';

/// JS `String.substr` with clamp semantics (negative/overflow start).
String _substr(String s, int start, [int? length]) {
  final int len = s.length;
  int from = start < 0 ? (len + start) : start;
  if (from < 0) {
    from = 0;
  }
  if (from > len) {
    return '';
  }
  final int end = length == null
      ? len
      : (length < 0 ? from : (from + length).clamp(from, len).toInt());
  return s.substring(from, end);
}

/// 1:1: `truncate`
String truncate(String value, int maxLength, [String suffix = Ellipsis]) {
  if (value.length <= maxLength) {
    return value;
  }
  return '${_substr(value, 0, maxLength)}$suffix';
}

/// 1:1: `truncateMiddle`
String truncateMiddle(String value, int maxLength, [String suffix = Ellipsis]) {
  if (value.length <= maxLength) {
    return value;
  }

  int prefixLength = ( ((maxLength / 2).ceil()) - (suffix.length / 2)).floor();
  final int suffixLength = (((maxLength / 2).floor()) - (suffix.length / 2)).ceil();
  int suffixStart = value.length - suffixLength;

  if (isHighSurrogate(_charCodeAt(value, prefixLength - 1)) &&
      isLowSurrogate(_charCodeAt(value, prefixLength))) {
    prefixLength--;
  }
  if (isHighSurrogate(_charCodeAt(value, suffixStart - 1)) &&
      isLowSurrogate(_charCodeAt(value, suffixStart))) {
    suffixStart++;
  }

  return '${value.substring(0, prefixLength)}$suffix${value.substring(suffixStart)}';
}

/// JS charCodeAt returns NaN (-1 here) for out-of-range indices.
int _charCodeAt(String s, int i) =>
    (i >= 0 && i < s.length) ? s.codeUnitAt(i) : -1;

/// 1:1: `trim`
String trim(String haystack, [String needle = ' ']) =>
    rtrim(ltrim(haystack, needle), needle);

/// 1:1: `ltrim`
String ltrim(String haystack, String needle) {
  if (haystack.isEmpty || needle.isEmpty) {
    return haystack;
  }

  final int needleLen = needle.length;
  int offset = 0;
  if (needleLen == 1) {
    final int ch = needle.codeUnitAt(0);
    while (offset < haystack.length && haystack.codeUnitAt(offset) == ch) {
      offset++;
    }
  } else {
    while (offset + needleLen <= haystack.length &&
        haystack.startsWith(needle, offset)) {
      offset += needleLen;
    }
  }
  return haystack.substring(offset);
}

/// 1:1: `rtrim`
String rtrim(String haystack, String needle) {
  if (haystack.isEmpty || needle.isEmpty) {
    return haystack;
  }

  final int needleLen = needle.length;
  final int haystackLen = haystack.length;

  if (needleLen == 1) {
    int end = haystackLen;
    final int ch = needle.codeUnitAt(0);
    while (end > 0 && haystack.codeUnitAt(end - 1) == ch) {
      end--;
    }
    return haystack.substring(0, end);
  }

  int offset = haystackLen;
  while (offset > 0 && _endsWithAt(haystack, needle, offset)) {
    offset -= needleLen;
  }
  return haystack.substring(0, offset);
}

/// JS `str.endsWith(needle, position)`: does `str[0..position)` end with needle?
bool _endsWithAt(String str, String needle, int position) {
  if (needle.length > position) {
    return false;
  }
  final int start = position - needle.length;
  return str.startsWith(needle, start);
}

/// 1:1: `convertSimple2RegExpPattern`
String convertSimple2RegExpPattern(String pattern) => pattern
    .replaceAllMapped(RegExp(r'[\-\\\{\}\+\?\|\^\$\.\,\[\]\(\)\#\s]'),
        (Match m) => '\\${m.group(0)}')
    .replaceAllMapped(RegExp(r'[*]'), (Match m) => '.*');

/// 1:1: `RegExpOptions`
class RegExpOptions {
  bool? matchCase;
  bool? wholeWord;
  bool? multiline;
  bool? global;
  bool? unicode;

  RegExpOptions({
    this.matchCase,
    this.wholeWord,
    this.multiline,
    this.global,
    this.unicode,
  });
}

final RegExp _wordBoundary = RegExp(r'\B');

/// 1:1: `createRegExp`
RegExp createRegExp(String searchString, bool isRegex,
    [RegExpOptions? options]) {
  final RegExpOptions opts = options ?? RegExpOptions();
  if (searchString.isEmpty) {
    throw StateError('Cannot create regex from empty string');
  }
  if (!isRegex) {
    searchString = escapeRegExpCharacters(searchString);
  }
  if (opts.wholeWord == true) {
    if (!_wordBoundary.hasMatch(_charAt(searchString, 0))) {
      searchString = '\\b$searchString';
    }
    if (!_wordBoundary.hasMatch(_charAt(searchString, searchString.length - 1))) {
      searchString = '$searchString\\b';
    }
  }
  final StringBuffer modifiers = StringBuffer();
  if (opts.global == true) {
    modifiers.write('g');
  }
  if (opts.matchCase != true) {
    modifiers.write('i');
  }
  if (opts.multiline == true) {
    modifiers.write('m');
  }
  if (opts.unicode == true) {
    modifiers.write('u');
  }

  // Dart RegExp flags: g is implicit; unsupported flags are ignored.
  return RegExp(
    searchString,
    caseSensitive: opts.matchCase == true,
    multiLine: opts.multiline == true,
  );
}

String _charAt(String s, int i) =>
    (i >= 0 && i < s.length) ? s[i] : '';

/// 1:1: `regExpLeadsToEndlessLoop`
bool regExpLeadsToEndlessLoop(RegExp regexp) {
  final String source = regexp.pattern;
  if (source == '^' ||
      source == r'^$' ||
      source == r'$' ||
      source == r'^\s*$') {
    return false;
  }
  final Match? match = regexp.firstMatch('');
  return match != null && match.start == 0;
}

/// 1:1: `joinStrings`
String joinStrings(List<Object?> items, String separator) => items
    .where((Object? item) => item != null && item != false)
    .map((Object? item) => '$item')
    .join(separator);

/// 1:1: `splitLines`
List<String> splitLines(String str) =>
    str.split(RegExp(r'\r\n|\r|\n'));

/// 1:1: `splitLinesIncludeSeparators`
List<String> splitLinesIncludeSeparators(String str) {
  final List<String> linesWithSeparators = <String>[];
  final List<String> parts = str.split(RegExp(r'(\r\n|\r|\n)'));
  for (int i = 0; i < ((parts.length / 2).ceil()); i++) {
    final String a = parts[2 * i];
    final String b = (2 * i + 1 < parts.length) ? parts[2 * i + 1] : '';
    linesWithSeparators.add(a + b);
  }
  return linesWithSeparators;
}

/// 1:1: `indexOfPattern`
int indexOfPattern(String str, RegExp re) {
  final Match? match = re.firstMatch(str);
  return match != null ? match.start : -1;
}

/// 1:1: `firstNonWhitespaceIndex`
int firstNonWhitespaceIndex(String str) {
  for (int i = 0, len = str.length; i < len; i++) {
    final int chCode = str.codeUnitAt(i);
    if (chCode != CharCode.Space && chCode != CharCode.Tab) {
      return i;
    }
  }
  return -1;
}

/// 1:1: `getLeadingWhitespace`
String getLeadingWhitespace(String str, [int start = 0, int? end]) {
  final int e = end ?? str.length;
  for (int i = start; i < e; i++) {
    final int chCode = str.codeUnitAt(i);
    if (chCode != CharCode.Space && chCode != CharCode.Tab) {
      return str.substring(start, i);
    }
  }
  return str.substring(start, e);
}

/// 1:1: `lastNonWhitespaceIndex`
int lastNonWhitespaceIndex(String str, [int? startIndex]) {
  int i = startIndex ?? str.length - 1;
  for (; i >= 0; i--) {
    final int chCode = str.codeUnitAt(i);
    if (chCode != CharCode.Space && chCode != CharCode.Tab) {
      return i;
    }
  }
  return -1;
}

/// 1:1: `getIndentationLength`
int getIndentationLength(String str) {
  final int idx = firstNonWhitespaceIndex(str);
  return idx == -1 ? str.length : idx;
}

/// 1:1: `replaceAsync`
Future<String> replaceAsync(
  String str,
  RegExp search,
  Future<String> Function(String match, List<Object?> rest) replacer,
) async {
  final List<Object?> parts = <Object?>[];

  int last = 0;
  for (final Match match in search.allMatches(str)) {
    parts.add(str.substring(last, match.start));
    final int matchIndex = match.start;
    last = matchIndex + match.group(0)!.length;
    final List<Object?> rest = <Object?>[];
    for (int i = 1; i <= match.groupCount; i++) {
      rest.add(match.group(i));
    }
    rest.add(matchIndex);
    rest.add(str);
    parts.add(replacer(match.group(0)!, rest));
  }

  parts.add(str.substring(last));

  final List<Object?> resolved = await Future.wait(parts.map((Object? p) async {
    if (p is Future<String>) {
      return await p;
    }
    return p;
  }));
  return resolved.join('');
}

/// 1:1: `compare`
int compare(String a, String b) {
  if (a.compareTo(b) < 0) {
    return -1;
  } else if (a.compareTo(b) > 0) {
    return 1;
  }
  return 0;
}

/// 1:1: `compareSubstring`
int compareSubstring(String a, String b,
    [int aStart = 0, int? aEnd, int bStart = 0, int? bEnd]) {
  final int ae = aEnd ?? a.length;
  final int be = bEnd ?? b.length;
  for (; aStart < ae && bStart < be; aStart++, bStart++) {
    final int codeA = a.codeUnitAt(aStart);
    final int codeB = b.codeUnitAt(bStart);
    if (codeA < codeB) {
      return -1;
    } else if (codeA > codeB) {
      return 1;
    }
  }
  final int aLen = ae - aStart;
  final int bLen = be - bStart;
  if (aLen < bLen) {
    return -1;
  } else if (aLen > bLen) {
    return 1;
  }
  return 0;
}

/// 1:1: `compareIgnoreCase`
int compareIgnoreCase(String a, String b) =>
    compareSubstringIgnoreCase(a, b, 0, a.length, 0, b.length);

/// 1:1: `compareSubstringIgnoreCase`
int compareSubstringIgnoreCase(String a, String b,
    [int aStart = 0, int? aEnd, int bStart = 0, int? bEnd]) {
  final int ae = aEnd ?? a.length;
  final int be = bEnd ?? b.length;
  for (; aStart < ae && bStart < be; aStart++, bStart++) {
    int codeA = a.codeUnitAt(aStart);
    int codeB = b.codeUnitAt(bStart);

    if (codeA == codeB) {
      continue;
    }

    if (codeA >= 128 || codeB >= 128) {
      return compare(
        a.substring(aStart, ae).toLowerCase(),
        b.substring(bStart, be).toLowerCase(),
      );
    }

    if (isLowerAsciiLetter(codeA)) {
      codeA -= 32;
    }
    if (isLowerAsciiLetter(codeB)) {
      codeB -= 32;
    }

    final int diff = codeA - codeB;
    if (diff == 0) {
      continue;
    }
    return diff;
  }

  final int aLen = ae - aStart;
  final int bLen = be - bStart;

  if (aLen < bLen) {
    return -1;
  } else if (aLen > bLen) {
    return 1;
  }
  return 0;
}

/// 1:1: `isAsciiDigit`
bool isAsciiDigit(int code) =>
    code >= CharCode.Digit0 && code <= CharCode.Digit9;

/// 1:1: `isLowerAsciiLetter`
bool isLowerAsciiLetter(int code) => code >= CharCode.a && code <= CharCode.z;

/// 1:1: `isUpperAsciiLetter`
bool isUpperAsciiLetter(int code) => code >= CharCode.A && code <= CharCode.Z;

/// 1:1: `equalsIgnoreCase`
bool equalsIgnoreCase(String a, String b) =>
    a.length == b.length && compareSubstringIgnoreCase(a, b) == 0;

/// 1:1: `equals`
bool equals(String? a, String? b, [bool? ignoreCase]) =>
    a == b ||
    (ignoreCase == true &&
        a != null &&
        b != null &&
        equalsIgnoreCase(a, b));

/// 1:1: `startsWithIgnoreCase`
bool startsWithIgnoreCase(String str, String candidate) {
  final int len = candidate.length;
  return len <= str.length &&
      compareSubstringIgnoreCase(str, candidate, 0, len) == 0;
}

/// 1:1: `endsWithIgnoreCase`
bool endsWithIgnoreCase(String str, String candidate) {
  final int len = str.length;
  final int start = len - candidate.length;
  return start >= 0 && compareSubstringIgnoreCase(str, candidate, start, len) == 0;
}

/// 1:1: `commonPrefixLength`
int commonPrefixLength(String a, String b) {
  final int len = a.length < b.length ? a.length : b.length;
  int i;
  for (i = 0; i < len; i++) {
    if (a.codeUnitAt(i) != b.codeUnitAt(i)) {
      return i;
    }
  }
  return len;
}

/// 1:1: `commonSuffixLength`
int commonSuffixLength(String a, String b) {
  final int len = a.length < b.length ? a.length : b.length;
  int i;
  final int aLastIndex = a.length - 1;
  final int bLastIndex = b.length - 1;
  for (i = 0; i < len; i++) {
    if (a.codeUnitAt(aLastIndex - i) != b.codeUnitAt(bLastIndex - i)) {
      return i;
    }
  }
  return len;
}

/// 1:1: `isHighSurrogate`
bool isHighSurrogate(int charCode) => 0xD800 <= charCode && charCode <= 0xDBFF;

/// 1:1: `isLowSurrogate`
bool isLowSurrogate(int charCode) => 0xDC00 <= charCode && charCode <= 0xDFFF;

/// 1:1: `computeCodePoint`
int computeCodePoint(int highSurrogate, int lowSurrogate) =>
    ((highSurrogate - 0xD800) << 10) + (lowSurrogate - 0xDC00) + 0x10000;

/// 1:1: `getNextCodePoint`
int getNextCodePoint(String str, int len, int offset) {
  final int charCode = str.codeUnitAt(offset);
  if (isHighSurrogate(charCode) && offset + 1 < len) {
    final int nextCharCode = str.codeUnitAt(offset + 1);
    if (isLowSurrogate(nextCharCode)) {
      return computeCodePoint(charCode, nextCharCode);
    }
  }
  return charCode;
}

/// 1:1: `getPrevCodePoint`
int getPrevCodePoint(String str, int offset) {
  final int charCode = str.codeUnitAt(offset - 1);
  if (isLowSurrogate(charCode) && offset > 1) {
    final int prevCharCode = str.codeUnitAt(offset - 2);
    if (isHighSurrogate(prevCharCode)) {
      return computeCodePoint(prevCharCode, charCode);
    }
  }
  return charCode;
}

/// 1:1: `CodePointIterator`
class CodePointIterator {
  final String _str;
  final int _len;
  int _offset;

  int get offset => _offset;

  CodePointIterator(this._str, [int offset = 0])
      : _len = _str.length,
        _offset = offset;

  void setOffset(int offset) => _offset = offset;

  int prevCodePoint() {
    final int codePoint = getPrevCodePoint(_str, _offset);
    _offset -= (codePoint >= Constants.UNICODE_SUPPLEMENTARY_PLANE_BEGIN ? 2 : 1);
    return codePoint;
  }

  int nextCodePoint() {
    final int codePoint = getNextCodePoint(_str, _len, _offset);
    _offset += (codePoint >= Constants.UNICODE_SUPPLEMENTARY_PLANE_BEGIN ? 2 : 1);
    return codePoint;
  }

  bool eol() => _offset >= _len;
}

/// 1:1: `GraphemeIterator`
class GraphemeIterator {
  final CodePointIterator _iterator;

  int get offset => _iterator.offset;

  GraphemeIterator(String str, [int offset = 0])
      : _iterator = CodePointIterator(str, offset);

  int nextGraphemeLength() {
    final GraphemeBreakTree tree = GraphemeBreakTree.getInstance();
    final CodePointIterator iterator = _iterator;
    final int initialOffset = iterator.offset;

    int type = tree.getGraphemeBreakType(iterator.nextCodePoint());
    while (!iterator.eol()) {
      final int offset = iterator.offset;
      final int nextType = tree.getGraphemeBreakType(iterator.nextCodePoint());
      if (breakBetweenGraphemeBreakType(type, nextType)) {
        iterator.setOffset(offset);
        break;
      }
      type = nextType;
    }
    return iterator.offset - initialOffset;
  }

  int prevGraphemeLength() {
    final GraphemeBreakTree tree = GraphemeBreakTree.getInstance();
    final CodePointIterator iterator = _iterator;
    final int initialOffset = iterator.offset;

    int type = tree.getGraphemeBreakType(iterator.prevCodePoint());
    while (iterator.offset > 0) {
      final int offset = iterator.offset;
      final int prevType = tree.getGraphemeBreakType(iterator.prevCodePoint());
      if (breakBetweenGraphemeBreakType(prevType, type)) {
        iterator.setOffset(offset);
        break;
      }
      type = prevType;
    }
    return initialOffset - iterator.offset;
  }

  bool eol() => _iterator.eol();
}

/// 1:1: `nextCharLength`
int nextCharLength(String str, int initialOffset) =>
    GraphemeIterator(str, initialOffset).nextGraphemeLength();

/// 1:1: `prevCharLength`
int prevCharLength(String str, int initialOffset) =>
    GraphemeIterator(str, initialOffset).prevGraphemeLength();

/// 1:1: `getCharContainingOffset`
List<int> getCharContainingOffset(String str, int offset) {
  if (offset > 0 && isLowSurrogate(_charCodeAt(str, offset))) {
    offset--;
  }
  final int endOffset = offset + nextCharLength(str, offset);
  final int startOffset = endOffset - prevCharLength(str, endOffset);
  return <int>[startOffset, endOffset];
}

/// 1:1: `charCount`
int charCount(String str) {
  final GraphemeIterator iterator = GraphemeIterator(str);
  int length = 0;
  while (!iterator.eol()) {
    length++;
    iterator.nextGraphemeLength();
  }
  return length;
}

RegExp? _containsRtl;

/// 1:1: `makeContainsRtl`
RegExp _makeContainsRtl() => RegExp(
    r'(?:[\u05BE\u05C0\u05C3\u05C6\u05D0-\u05F4\u0608\u060B\u060D\u061B-\u064A\u066D-\u066F\u0671-\u06D5\u06E5\u06E6\u06EE\u06EF\u06FA-\u0710\u0712-\u072F\u074D-\u07A5\u07B1-\u07EA\u07F4\u07F5\u07FA\u07FE-\u0815\u081A\u0824\u0828\u0830-\u0858\u085E-\u088E\u08A0-\u08C9\u200F\uFB1D\uFB1F-\uFB28\uFB2A-\uFD3D\uFD50-\uFDC7\uFDF0-\uFDFC\uFE70-\uFEFC]|\uD802[\uDC00-\uDD1B\uDD20-\uDE00\uDE10-\uDE35\uDE40-\uDEE4\uDEEB-\uDF35\uDF40-\uDFFF]|\uD803[\uDC00-\uDD23\uDE80-\uDEA9\uDEAD-\uDF45\uDF51-\uDF81\uDF86-\uDFF6]|\uD83A[\uDC00-\uDCCF\uDD00-\uDD43\uDD4B-\uDFFF]|\uD83B[\uDC00-\uDEBB])');

/// 1:1: `containsRTL`
bool containsRTL(String str) {
  _containsRtl ??= _makeContainsRtl();
  return _containsRtl!.hasMatch(str);
}

final RegExp _isBasicAscii = RegExp(r'^[\t\n\r\x20-\x7E]*$');

/// 1:1: `isBasicASCII`
bool isBasicASCII(String str) => _isBasicAscii.hasMatch(str);

final RegExp UNUSUAL_LINE_TERMINATORS = RegExp(r'[\u2028\u2029]');

/// 1:1: `containsUnusualLineTerminators`
bool containsUnusualLineTerminators(String str) =>
    UNUSUAL_LINE_TERMINATORS.hasMatch(str);

/// 1:1: `escapeControlAndFormatCharacters`
String escapeControlAndFormatCharacters(String str) =>
    str.replaceAllMapped(RegExp(r'[\p{Cc}\p{Cf}\p{Zl}\p{Zp}]', unicode: true),
        (Match m) {
      final int? cp = m.group(0)!.runes.isEmpty ? null : m.group(0)!.runes.first;
      return '\\u{${cp != null ? cp.toRadixString(16) : ''}}';
    });

/// 1:1: `isFullWidthCharacter`
bool isFullWidthCharacter(int charCode) =>
    (charCode >= 0x2E80 && charCode <= 0xD7AF) ||
    (charCode >= 0xF900 && charCode <= 0xFAFF) ||
    (charCode >= 0xFF01 && charCode <= 0xFF5E) ||
    (charCode >= 0xFFE0 && charCode <= 0xFFE6);

/// 1:1: `isEmojiImprecise`
bool isEmojiImprecise(int x) =>
    (x >= 0x1F1E6 && x <= 0x1F1FF) ||
    x == 8986 ||
    x == 8987 ||
    x == 9200 ||
    x == 9203 ||
    (x >= 9728 && x <= 10175) ||
    x == 11088 ||
    x == 11093 ||
    (x >= 127744 && x <= 128591) ||
    (x >= 128640 && x <= 128764) ||
    (x >= 128992 && x <= 129008) ||
    (x >= 129280 && x <= 129535) ||
    (x >= 129648 && x <= 129782);

/// 1:1: `lcut`
String lcut(String text, int n, [String prefix = '']) {
  final String trimmed = text.trimLeft();

  if (trimmed.length < n) {
    return trimmed;
  }

  final RegExp re = RegExp(r'\b');
  int i = 0;
  Iterable<Match> matches = re.allMatches(trimmed);
  for (final Match m in matches) {
    final int lastIndex = m.end;
    if (trimmed.length - lastIndex < n) {
      break;
    }
    i = lastIndex;
  }

  if (i == 0) {
    return trimmed;
  }
  return prefix + trimmed.substring(i).trimLeft();
}

/// 1:1: `rcut`
String rcut(String text, int n, [String suffix = '']) {
  final String trimmed = text.trimRight();

  if (trimmed.length <= n) {
    return trimmed;
  }

  final RegExp re = RegExp(r'\b');
  int lastGoodBreak = 0;
  bool foundBoundaryAfterN = false;
  for (final Match m in re.allMatches(trimmed)) {
    final int lastIndex = m.end;
    if (lastIndex > n) {
      foundBoundaryAfterN = true;
      break;
    }
    lastGoodBreak = lastIndex;
  }

  if (!foundBoundaryAfterN) {
    return trimmed;
  }
  if (lastGoodBreak == 0) {
    return suffix;
  }

  final String result = trimmed.substring(0, lastGoodBreak).trimRight();
  if (result.length < lastGoodBreak / 2) {
    return trimmed;
  }
  return result + suffix;
}

final RegExp _csiSequence =
    RegExp(r''' (?:\x1b\[|\x9b)[=?>!]?[\d;:]*["$#'* ]?[a-zA-Z@^`{}|~]'''.trim());
final RegExp _oscSequence = RegExp(r'(?:\x1b\]|\x9d).*?(?:\x1b\\|\x07|\x9c)');
final RegExp _escSequence = RegExp(r'\x1b(?:[ #%\(\)\*\+\-\.\/]?[a-zA-Z0-9\|}~@])');
final RegExp _controlSequences = RegExp([
  _csiSequence.pattern,
  _oscSequence.pattern,
  _escSequence.pattern,
].join('|'));

/// 1:1: `forAnsiStringParts` (generator) -> Iterable
Iterable<Map<String, Object>> forAnsiStringParts(String str) sync* {
  int last = 0;
  for (final Match match in _controlSequences.allMatches(str)) {
    if (last != match.start) {
      yield <String, Object>{'isCode': false, 'str': str.substring(last, match.start)};
    }
    yield <String, Object>{'isCode': true, 'str': match.group(0)!};
    last = match.start + match.group(0)!.length;
  }
  if (last != str.length) {
    yield <String, Object>{'isCode': false, 'str': str.substring(last)};
  }
}

/// 1:1: `removeAnsiEscapeCodes`
String removeAnsiEscapeCodes(String str) {
  if (str.isNotEmpty) {
    str = str.replaceAll(_controlSequences, '');
  }
  return str;
}

final RegExp _promptNonPrintable = RegExp(r'\\\[.*?\\\]');

/// 1:1: `removeAnsiEscapeCodesFromPrompt`
String removeAnsiEscapeCodesFromPrompt(String str) =>
    removeAnsiEscapeCodes(str).replaceAll(_promptNonPrintable, '');

const String UTF8_BOM_CHARACTER = '\uFEFF';

/// 1:1: `startsWithUTF8BOM`
bool startsWithUTF8BOM(String str) =>
    str.isNotEmpty && str.codeUnitAt(0) == CharCode.UTF8_BOM;

/// 1:1: `stripUTF8BOM`
String stripUTF8BOM(String str) =>
    startsWithUTF8BOM(str) ? _substr(str, 1) : str;

/// 1:1: `fuzzyContains`
bool fuzzyContains(String target, String query) {
  if (target.isEmpty || query.isEmpty) {
    return false;
  }
  if (target.length < query.length) {
    return false;
  }

  final String targetLower = target.toLowerCase();
  final String queryLower = query.toLowerCase();
  final int queryLen = queryLower.length;

  int index = 0;
  int lastIndexOf = -1;
  while (index < queryLen) {
    final int indexOf = targetLower.indexOf(queryLower[index], lastIndexOf + 1);
    if (indexOf < 0) {
      return false;
    }
    lastIndexOf = indexOf;
    index++;
  }
  return true;
}

/// 1:1: `containsUppercaseCharacter`
bool containsUppercaseCharacter(String target,
    [bool ignoreEscapedChars = false]) {
  if (target.isEmpty) {
    return false;
  }
  if (ignoreEscapedChars) {
    target = target.replaceAllMapped(RegExp(r'\\.'), (Match m) => '');
  }
  return target.toLowerCase() != target;
}

/// 1:1: `uppercaseFirstLetter`
String uppercaseFirstLetter(String str) =>
    '${_charAt(str, 0).toUpperCase()}${_substr(str, 1)}';

/// 1:1: `getNLines`
String getNLines(String str, [int n = 1]) {
  if (n == 0) {
    return '';
  }

  int idx = -1;
  do {
    idx = str.indexOf('\n', idx + 1);
    n--;
  } while (n > 0 && idx >= 0);

  if (idx == -1) {
    return str;
  }
  if (idx > 0 && str.codeUnitAt(idx - 1) == CharCode.CarriageReturn) {
    idx--;
  }
  return _substr(str, 0, idx);
}

/// 1:1: `singleLetterHash`
String singleLetterHash(int n) {
  final int lettersCnt = CharCode.Z - CharCode.A + 1;

  n = n % (2 * lettersCnt);

  if (n < lettersCnt) {
    return String.fromCharCode(CharCode.a + n);
  }
  return String.fromCharCode(CharCode.A + n - lettersCnt);
}

// ---- Unicode Grapheme Break ----

/// 1:1: `getGraphemeBreakType`
int getGraphemeBreakType(int codePoint) =>
    GraphemeBreakTree.getInstance().getGraphemeBreakType(codePoint);

/// 1:1: `const enum GraphemeBreakType`
class GraphemeBreakType {
  static const int Other = 0;
  static const int Prepend = 1;
  static const int CR = 2;
  static const int LF = 3;
  static const int Control = 4;
  static const int Extend = 5;
  static const int Regional_Indicator = 6;
  static const int SpacingMark = 7;
  static const int L = 8;
  static const int V = 9;
  static const int T = 10;
  static const int LV = 11;
  static const int LVT = 12;
  static const int ZWJ = 13;
  static const int Extended_Pictographic = 14;
}

/// 1:1: `breakBetweenGraphemeBreakType`
bool breakBetweenGraphemeBreakType(int a, int b) {
  if (a == GraphemeBreakType.Other) {
    return b != GraphemeBreakType.Extend && b != GraphemeBreakType.SpacingMark;
  }
  if (a == GraphemeBreakType.CR) {
    if (b == GraphemeBreakType.LF) {
      return false;
    }
  }
  if (a == GraphemeBreakType.Control ||
      a == GraphemeBreakType.CR ||
      a == GraphemeBreakType.LF) {
    return true;
  }
  if (b == GraphemeBreakType.Control ||
      b == GraphemeBreakType.CR ||
      b == GraphemeBreakType.LF) {
    return true;
  }
  if (a == GraphemeBreakType.L) {
    if (b == GraphemeBreakType.L ||
        b == GraphemeBreakType.V ||
        b == GraphemeBreakType.LV ||
        b == GraphemeBreakType.LVT) {
      return false;
    }
  }
  if (a == GraphemeBreakType.LV || a == GraphemeBreakType.V) {
    if (b == GraphemeBreakType.V || b == GraphemeBreakType.T) {
      return false;
    }
  }
  if (a == GraphemeBreakType.LVT || a == GraphemeBreakType.T) {
    if (b == GraphemeBreakType.T) {
      return false;
    }
  }
  if (b == GraphemeBreakType.Extend || b == GraphemeBreakType.ZWJ) {
    return false;
  }
  if (b == GraphemeBreakType.SpacingMark) {
    return false;
  }
  if (a == GraphemeBreakType.Prepend) {
    return false;
  }
  if (a == GraphemeBreakType.ZWJ &&
      b == GraphemeBreakType.Extended_Pictographic) {
    return false;
  }
  if (a == GraphemeBreakType.Regional_Indicator &&
      b == GraphemeBreakType.Regional_Indicator) {
    return false;
  }
  return true;
}

/// 1:1: `GraphemeBreakTree`
class GraphemeBreakTree {
  static GraphemeBreakTree? _instance;
  static GraphemeBreakTree getInstance() {
    _instance ??= GraphemeBreakTree();
    return _instance!;
  }

  final List<int> _data;
  GraphemeBreakTree() : _data = _graphemeBreakRawData;

  int getGraphemeBreakType(int codePoint) {
    if (codePoint < 32) {
      if (codePoint == CharCode.LineFeed) {
        return GraphemeBreakType.LF;
      }
      if (codePoint == CharCode.CarriageReturn) {
        return GraphemeBreakType.CR;
      }
      return GraphemeBreakType.Control;
    }
    if (codePoint < 127) {
      return GraphemeBreakType.Other;
    }

    final List<int> data = _data;
    final int nodeCount = data.length ~/ 3;
    int nodeIndex = 1;
    while (nodeIndex <= nodeCount) {
      if (codePoint < data[3 * nodeIndex]) {
        nodeIndex = 2 * nodeIndex;
      } else if (codePoint > data[3 * nodeIndex + 1]) {
        nodeIndex = 2 * nodeIndex + 1;
      } else {
        return data[3 * nodeIndex + 2];
      }
    }
    return GraphemeBreakType.Other;
  }
}

/// 1:1: `getLeftDeleteOffset`
int getLeftDeleteOffset(int offset, String str) {
  if (offset == 0) {
    return 0;
  }
  final int? emojiOffset = _getOffsetBeforeLastEmojiComponent(offset, str);
  if (emojiOffset != null) {
    return emojiOffset;
  }
  final CodePointIterator iterator = CodePointIterator(str, offset);
  iterator.prevCodePoint();
  return iterator.offset;
}

/// 1:1: `getOffsetBeforeLastEmojiComponent`
int? _getOffsetBeforeLastEmojiComponent(int initialOffset, String str) {
  final CodePointIterator iterator = CodePointIterator(str, initialOffset);
  int codePoint = iterator.prevCodePoint();

  while (_isEmojiModifier(codePoint) ||
      codePoint == CodePoint.emojiVariantSelector ||
      codePoint == CodePoint.enclosingKeyCap) {
    if (iterator.offset == 0) {
      return null;
    }
    codePoint = iterator.prevCodePoint();
  }

  if (!isEmojiImprecise(codePoint)) {
    return null;
  }

  int resultOffset = iterator.offset;

  if (resultOffset > 0) {
    final int optionalZwjCodePoint = iterator.prevCodePoint();
    if (optionalZwjCodePoint == CodePoint.zwj) {
      resultOffset = iterator.offset;
    }
  }
  return resultOffset;
}

bool _isEmojiModifier(int cp) => 0x1F3FB <= cp && cp <= 0x1F3FF;

/// 1:1: `const enum CodePoint`
class CodePoint {
  static const int zwj = 0x200D;
  static const int emojiVariantSelector = 0xFE0F;
  static const int enclosingKeyCap = 0x20E3;
  static const int space = 0x0020;
}

const String noBreakWhitespace = '\xa0';

/// 1:1: `AmbiguousCharacters`
class AmbiguousCharacters {
  static final Lazy<Map<String, List<int>>> _ambiguousCharacterData =
      Lazy<Map<String, List<int>>>(() => _ambiguousData);

  static final LRUCachedFunction<String, AmbiguousCharacters> _cache =
      LRUCachedFunction<String, AmbiguousCharacters>((String localesStr) {
    final List<String> locales = localesStr.split(',');

    Map<int, int> arrayToMap(List<int> arr) {
      final Map<int, int> result = <int, int>{};
      for (int i = 0; i < arr.length; i += 2) {
        result[arr[i]] = arr[i + 1];
      }
      return result;
    }

    Map<int, int> mergeMaps(Map<int, int> map1, Map<int, int> map2) {
      final Map<int, int> result = Map<int, int>.from(map1);
      map2.forEach((int key, int value) => result[key] = value);
      return result;
    }

    Map<int, int> intersectMaps(Map<int, int>? map1, Map<int, int> map2) {
      if (map1 == null) {
        return map2;
      }
      final Map<int, int> result = <int, int>{};
      map1.forEach((int key, int value) {
        if (map2.containsKey(key)) {
          result[key] = value;
        }
      });
      return result;
    }

    final Map<String, List<int>> data = _ambiguousCharacterData.value;

    List<String> filteredLocales = locales
        .where((String l) => !l.startsWith('_') && data.containsKey(l))
        .toList();
    if (filteredLocales.isEmpty) {
      filteredLocales = <String>['_default'];
    }

    Map<int, int>? languageSpecificMap;
    for (final String locale in filteredLocales) {
      final Map<int, int> map = arrayToMap(data[locale]!);
      languageSpecificMap = intersectMaps(languageSpecificMap, map);
    }

    final Map<int, int> commonMap = arrayToMap(data['_common']!);
    final Map<int, int> map = mergeMaps(commonMap, languageSpecificMap!);

    return AmbiguousCharacters._(map);
  });

  static final Lazy<List<String>> _locales = Lazy<List<String>>(
    () => _ambiguousData.keys.where((String k) => !k.startsWith('_')).toList(),
  );

  static AmbiguousCharacters getInstance(Iterable<String> locales) =>
      _cache.get(locales.join(','));

  static List<String> getLocales() => _locales.value;

  final Map<int, int> _confusableDictionary;
  AmbiguousCharacters._(this._confusableDictionary);

  bool isAmbiguous(int codePoint) => _confusableDictionary.containsKey(codePoint);

  bool containsAmbiguousCharacter(String str) {
    for (int i = 0; i < str.length; i++) {
      final int codePoint = _codePointAt(str, i);
      if (isAmbiguous(codePoint)) {
        return true;
      }
    }
    return false;
  }

  /// JS `String.codePointAt(i)` combines surrogate pairs.
  int _codePointAt(String s, int i) {
    final int cp = s.codeUnitAt(i);
    if (isHighSurrogate(cp) && i + 1 < s.length) {
      final int next = s.codeUnitAt(i + 1);
      if (isLowSurrogate(next)) {
        return computeCodePoint(cp, next);
      }
    }
    return cp;
  }

  int? getPrimaryConfusable(int codePoint) => _confusableDictionary[codePoint];

  Set<int> getConfusableCodePoints() => _confusableDictionary.keys.toSet();
}

/// 1:1: `InvisibleCharacters`
class InvisibleCharacters {
  static final Set<int> _data = <int>{
    ..._invisibleRawData,
  };

  static bool isInvisibleCharacter(int codePoint) => _data.contains(codePoint);

  static bool containsInvisibleCharacter(String str) {
    for (int i = 0; i < str.length; i++) {
      final int codePoint = _codePointAt(str, i);
      if (isInvisibleCharacter(codePoint) || codePoint == CodePoint.space) {
        return true;
      }
    }
    return false;
  }

  static int _codePointAt(String s, int i) {
    final int cp = s.codeUnitAt(i);
    if (isHighSurrogate(cp) && i + 1 < s.length) {
      final int next = s.codeUnitAt(i + 1);
      if (isLowSurrogate(next)) {
        return computeCodePoint(cp, next);
      }
    }
    return cp;
  }

  static Set<int> get codePoints => _data;
}

/// 1:1: `toBinary` - each UTF-16 code unit occupies one byte pair in a Uint16
/// view, reinterpreted as bytes.
String _toBinary(String str) {
  final Uint16List codeUnits = Uint16List(str.length);
  for (int i = 0; i < codeUnits.length; i++) {
    codeUnits[i] = str.codeUnitAt(i);
  }
  final Uint8List uint8array = Uint8List.view(codeUnits.buffer);
  final StringBuffer binary = StringBuffer();
  for (int i = 0; i < uint8array.length; i++) {
    binary.writeCharCode(uint8array[i]);
  }
  return binary.toString();
}

/// 1:1: `multibyteAwareBtoa`
String multibyteAwareBtoa(String str) => base64.encode(_toBinary(str).codeUnits
    .map((int c) => c & 0xFF)
    .toList());
