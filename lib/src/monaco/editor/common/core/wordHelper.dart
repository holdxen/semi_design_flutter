// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/wordHelper.ts
// Translated 1:1 from TypeScript.
//   - JS RegExp with mutable `lastIndex` + stateful `exec()` -> `WordDefinition`
//     carrier wrapping a Dart RegExp and an explicit `lastIndex` cursor.
//     Dart RegExp is immutable and has no `lastIndex`; `DartRegExp.execFrom`
//     finds the first match at/after a start index, mirroring JS `g` exec.
//   - `IWordAtPosition` -> carrier class.
//   - `setDefaultGetWordAtTextConfig` uses LinkedList.unshift disposer.
//   - `Date.now()` -> DateTime.now().millisecondsSinceEpoch.
// ---------------------------------------------------------------------------

import '../../../base/common/iterator.dart' as iterator;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/linkedList.dart' as linkedList;

/// 1:1: `USUAL_WORD_SEPARATORS`
/// Runtime value matches TS `'...\\|;:\'",.<>/?'` (single backslash + quotes).
const String USUAL_WORD_SEPARATORS = r'`~!@#$%^&*()-=+[{]}\|;:' "'" '"' r',.<>/?';

/// The result of a JS-style `RegExp.exec`: index, end, and the matched text.
class RegExpExecResult {
  final int index;
  final int end;
  final String text;
  RegExpExecResult(this.index, this.end, this.text);
}

/// 1:1: a JS `RegExp` with stateful `lastIndex` and global exec semantics.
/// Dart's [RegExp] has no mutable `lastIndex`, so this carrier reproduces the
/// stateful `exec(text)` loop used by getWordAtText / _findRegexMatchEnclosingPosition.
class WordDefinition {
  final RegExp regexp;
  int lastIndex = 0;

  WordDefinition(this.regexp);

  /// Mirrors JS `regexp.exec(text)` with the `g` flag: find the first match
  /// whose start is >= lastIndex, advance lastIndex to the match end.
  RegExpExecResult? exec(String text) {
    if (this.lastIndex > text.length) {
      this.lastIndex = 0;
      return null;
    }
    // Dart RegExp.allMatches(text, start) enumerates matches starting at/after
    // `start`; the first one is the JS `g` exec result.
    for (final Match m in this.regexp.allMatches(text, this.lastIndex)) {
      this.lastIndex = m.end;
      return RegExpExecResult(m.start, m.end, m.group(0) ?? '');
    }
    this.lastIndex = 0;
    return null;
  }

  /// 1:1: `new RegExp(wordDefinition.source, flags)` for flag reconstruction.
  WordDefinition withFlags(bool ignoreCase, bool multiline, bool unicode) {
    // Dart RegExp flags: caseSensitive == !i, multiLine == m; `g`/`u` have no
    // Dart equivalent (g is always-on via allMatches, u is Dart's default).
    return WordDefinition(RegExp(this.regexp.pattern, caseSensitive: !ignoreCase, multiLine: multiline));
  }
}

/// 1:1: `IWordAtPosition`
class IWordAtPosition {
  final String word;
  final int startColumn;
  final int endColumn;
  const IWordAtPosition({required this.word, required this.startColumn, required this.endColumn});

  @override
  String toString() => 'IWordAtPosition($word, $startColumn, $endColumn)';
}

/// 1:1: `createWordRegExp(allowInWords)`
WordDefinition _createWordRegExp([String allowInWords = '']) {
  String source = r'(-?\d*\.\d\w*)|([^';
  for (final String sep in USUAL_WORD_SEPARATORS.split('')) {
    if (allowInWords.contains(sep)) {
      continue;
    }
    source += '\\' + sep;
  }
  source += r'\s]+)';
  return WordDefinition(RegExp(source));
}

/// 1:1: `DEFAULT_WORD_REGEXP`
final WordDefinition DEFAULT_WORD_REGEXP = _createWordRegExp();

/// 1:1: `ensureValidWordDefinition(wordDefinition?)`
/// JS forces the `g` flag; Dart exec is always global, so the meaningful work
/// is resetting lastIndex. Flag reconstruction is kept for fidelity.
WordDefinition ensureValidWordDefinition([WordDefinition? wordDefinition]) {
  WordDefinition result = DEFAULT_WORD_REGEXP;
  if (wordDefinition != null) {
    // In the source, `global` false triggers reconstruction with 'g' + preserved
    // i/m/u flags. Dart RegExp has no `global`; a fresh WordDefinition is always
    // global, so we reconstruct only to reset mutable cursor state.
    result = wordDefinition;
  }
  result.lastIndex = 0;
  return result;
}

/// 1:1: `IGetWordAtTextConfig`
class IGetWordAtTextConfig {
  final int maxLen;
  final int windowSize;
  final int timeBudget;
  const IGetWordAtTextConfig({required this.maxLen, required this.windowSize, required this.timeBudget});
}

/// 1:1: `_defaultConfig` LinkedList.
final linkedList.LinkedList<IGetWordAtTextConfig> _defaultConfig = linkedList.LinkedList<IGetWordAtTextConfig>()
  ..unshift(const IGetWordAtTextConfig(maxLen: 1000, windowSize: 15, timeBudget: 150));

/// 1:1: `setDefaultGetWordAtTextConfig(value)`
lifecycle.IDisposable setDefaultGetWordAtTextConfig(IGetWordAtTextConfig value) {
  final void Function() rm = _defaultConfig.unshift(value);
  return lifecycle.toDisposable(rm);
}

/// 1:1: `getWordAtText(column, wordDefinition, text, textOffset, config?)`
IWordAtPosition? getWordAtText(
  int column,
  WordDefinition wordDefinition,
  String text,
  int textOffset, [
  IGetWordAtTextConfig? config,
]) {
  // Ensure the regex has the 'g' flag, otherwise this will loop forever.
  wordDefinition = ensureValidWordDefinition(wordDefinition);

  config ??= iterator.IterableX.first<IGetWordAtTextConfig>(_defaultConfig.iterable)!;

  if (text.length > config.maxLen) {
    // Don't throw strings that long at the regexp; use a substring in which a
    // word must occur.
    num start = column - config.maxLen / 2;
    if (start < 0) {
      start = 0;
    } else {
      textOffset += start.toInt();
    }
    text = text.substring(start.toInt(), (column + config.maxLen / 2).toInt());
    return getWordAtText(column, wordDefinition, text, textOffset, config);
  }

  final int t1 = DateTime.now().millisecondsSinceEpoch;
  final int pos = column - 1 - textOffset;

  int prevRegexIndex = -1;
  RegExpExecResult? match;

  for (int i = 1; ; i++) {
    // check time budget
    if (DateTime.now().millisecondsSinceEpoch - t1 >= config.timeBudget) {
      break;
    }

    final int regexIndex = pos - config.windowSize * i;
    wordDefinition.lastIndex = regexIndex > 0 ? regexIndex : 0;
    final RegExpExecResult? thisMatch = _findRegexMatchEnclosingPosition(wordDefinition, text, pos, prevRegexIndex);

    if (thisMatch == null && match != null) {
      // stop: we have something
      break;
    }

    match = thisMatch;

    // stop: searched at start
    if (regexIndex <= 0) {
      break;
    }
    prevRegexIndex = regexIndex;
  }

  if (match != null) {
    final IWordAtPosition result = IWordAtPosition(
      word: match.text,
      startColumn: textOffset + 1 + match.index,
      endColumn: textOffset + 1 + match.index + match.text.length,
    );
    wordDefinition.lastIndex = 0;
    return result;
  }

  return null;
}

/// 1:1: `_findRegexMatchEnclosingPosition(wordDefinition, text, pos, stopPos)`
RegExpExecResult? _findRegexMatchEnclosingPosition(
  WordDefinition wordDefinition,
  String text,
  int pos,
  int stopPos,
) {
  RegExpExecResult? match;
  while (true) {
    match = wordDefinition.exec(text);
    if (match == null) {
      break;
    }
    final int matchIndex = match.index; // match.index || 0 (JS index is always >= 0 here)
    if (matchIndex <= pos && wordDefinition.lastIndex >= pos) {
      return match;
    } else if (stopPos > 0 && matchIndex > stopPos) {
      return null;
    }
  }
  return null;
}
