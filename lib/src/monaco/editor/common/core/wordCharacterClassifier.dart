// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/wordCharacterClassifier.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - `const enum WordCharacterClass` -> class with static const int.
//   - Dart has no `Intl.Segmenter`; `date.dart` provides a carrier. The
//     `segment()` extension below supplies the word-granularity segments
//     consumed by this file (only `isWordLike` segments are used by source).
// ---------------------------------------------------------------------------

import '../../../base/common/charCode.dart' as charCode;
import '../../../base/common/date.dart' as date;
import '../../../base/common/lazy.dart' as lazy;
import '../../../base/common/map.dart' as map;
import 'characterClassifier.dart' as classifier;

/// 1:1: `export const enum WordCharacterClass`
class WordCharacterClass {
  const WordCharacterClass._();

  static const int Regular = 0;
  static const int Whitespace = 1;
  static const int WordSeparator = 2;
}

/// 1:1: `export interface IntlWordSegmentData extends Intl.SegmentData`
class IntlWordSegmentData {
  final String segment;
  final int index;
  final bool isWordLike;

  IntlWordSegmentData(this.segment, this.index, this.isWordLike);
}

/// Word-granularity `Intl.Segmenter.segment(line)` carrier for Dart.
extension IntlSegmenterWordSegments on date.IntlSegmenter {
  Iterable<IntlWordSegmentData> segment(String line) sync* {
    final RegExp wordRe = RegExp(
        r'[\p{Letter}\p{Number}\p{Mark}_]+', unicode: true);
    for (final Match match in wordRe.allMatches(line)) {
      yield IntlWordSegmentData(match.group(0)!, match.start, true);
    }
  }
}

/// 1:1: `export class WordCharacterClassifier`
class WordCharacterClassifier
    extends classifier.CharacterClassifier<int> {
  final List<String> intlSegmenterLocales;
  final lazy.Lazy<date.IntlSegmenter>? _segmenter;
  String? _cachedLine;
  List<IntlWordSegmentData> _cachedSegments = <IntlWordSegmentData>[];

  WordCharacterClassifier(
      String wordSeparators, List<String> intlSegmenterLocales)
      : intlSegmenterLocales = intlSegmenterLocales,
        _segmenter = intlSegmenterLocales.isNotEmpty
            ? date.safeIntl.Segmenter(intlSegmenterLocales,
                <String, Object>{'granularity': 'word'})
            : null,
        super(WordCharacterClass.Regular) {
    for (int i = 0, len = wordSeparators.length; i < len; i++) {
      set(wordSeparators.codeUnitAt(i), WordCharacterClass.WordSeparator);
    }

    set(charCode.CharCode.Space, WordCharacterClass.Whitespace);
    set(charCode.CharCode.Tab, WordCharacterClass.Whitespace);
  }

  /// 1:1: `findPrevIntlWordBeforeOrAtOffset`
  IntlWordSegmentData? findPrevIntlWordBeforeOrAtOffset(
      String line, int offset) {
    IntlWordSegmentData? candidate;
    for (final IntlWordSegmentData segment in _getIntlSegmenterWordsOnLine(line)) {
      if (segment.index > offset) {
        break;
      }
      candidate = segment;
    }
    return candidate;
  }

  /// 1:1: `findNextIntlWordAtOrAfterOffset`
  IntlWordSegmentData? findNextIntlWordAtOrAfterOffset(
      String lineContent, int offset) {
    for (final IntlWordSegmentData segment
        in _getIntlSegmenterWordsOnLine(lineContent)) {
      if (segment.index < offset) {
        continue;
      }
      return segment;
    }
    return null;
  }

  List<IntlWordSegmentData> _getIntlSegmenterWordsOnLine(String line) {
    final lazy.Lazy<date.IntlSegmenter>? segmenter = _segmenter;
    if (segmenter == null) {
      return <IntlWordSegmentData>[];
    }
    if (_cachedLine == line) {
      return _cachedSegments;
    }
    _cachedLine = line;
    _cachedSegments = _filterWordSegments(segmenter.value.segment(line));
    return _cachedSegments;
  }

  List<IntlWordSegmentData> _filterWordSegments(
      Iterable<IntlWordSegmentData> segments) {
    final List<IntlWordSegmentData> result = <IntlWordSegmentData>[];
    for (final IntlWordSegmentData segment in segments) {
      if (_isWordLike(segment)) {
        result.add(segment);
      }
    }
    return result;
  }

  bool _isWordLike(IntlWordSegmentData segment) {
    if (segment.isWordLike) {
      return true;
    }
    return false;
  }
}

final map.LRUCache<String, WordCharacterClassifier> wordClassifierCache =
    map.LRUCache<String, WordCharacterClassifier>(10);

/// 1:1: `export function getMapForWordSeparators`
WordCharacterClassifier getMapForWordSeparators(
    String wordSeparators, List<String> intlSegmenterLocales) {
  final String key = '$wordSeparators/${intlSegmenterLocales.join(',')}';
  WordCharacterClassifier? result = wordClassifierCache.get(key);
  if (result == null) {
    result = WordCharacterClassifier(wordSeparators, intlSegmenterLocales);
    wordClassifierCache.set(key, result);
  }
  return result;
}
