// Pure Dart port of packages/semi-foundation/highlight/foundation.ts:
// findAll = findChunks -> combineChunks -> fillInChunks.
//
// This file intentionally has zero Flutter dependencies so the algorithm can
// be exercised in isolation. Offsets are UTF-16 code unit indices and align
// with String.substring slicing.

/// One search word to highlight inside a source string.
///
/// [style] is opaque to the algorithm. When matched ranges overlap, the
/// combined chunk carries `{...prev.style, ...next.style}` semantics: keys
/// already present on the earlier word are kept, and the later word overrides
/// the same key. The built-in combiner calls `prev.merge(next)` (the
/// [TextStyle.merge] contract), so any style type exposing
/// `T merge(T other)` works; that is exactly what `TextStyle` provides.
class SemiHighlightWord<T> {
  const SemiHighlightWord(this.text, {this.style});

  /// The literal (or, with `autoEscape: false`, regex) pattern to match.
  /// Empty texts are ignored.
  final String text;

  /// Opaque per-word style payload carried onto matching chunks.
  final T? style;
}

/// A piece of [sourceString]: highlighted or plain.
class HighlightChunk<T> {
  const HighlightChunk({
    required this.start,
    required this.end,
    required this.highlight,
    this.style,
  });

  /// UTF-16 code unit start offset, inclusive.
  final int start;

  /// UTF-16 code unit end offset, exclusive.
  final int end;

  /// Whether this range matched at least one search word.
  final bool highlight;

  /// Style payload; only set on highlighted chunks, merged across overlapping
  /// words as described on [SemiHighlightWord.style].
  final T? style;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightChunk<T> &&
          start == other.start &&
          end == other.end &&
          highlight == other.highlight &&
          style == other.style;

  @override
  int get hashCode => Object.hash(start, end, highlight, style);

  @override
  String toString() =>
      'HighlightChunk($start, $end, highlight: $highlight, style: $style)';
}

/// Matches [searchWords] inside [sourceString] and returns the full chunk
/// cover: highlighted matches interleaved with the plain gaps around them.
///
/// findAll(['z'], 'aaazaaazaaa')
///     #=> [
///            { start: 0, end: 3, highlight: false },
///            { start: 3, end: 4, highlight: true },
///            { start: 4, end: 7, highlight: false },
///            { start: 7, end: 8, highlight: true },
///            { start: 8, end: 11, highlight: false },
///         ]
///
/// findAll(['do', 'dollar'], 'aaa do dollar aaa')
///     #=> [
///            { start: 0, end: 4, highlight: false },
///            { start: 4, end: 6, highlight: true },
///            { start: 6, end: 7, highlight: false },
///            { start: 7, end: 13, highlight: true },
///            { start: 13, end: 17, highlight: false },
///         ]
///
/// With [autoEscape] true (default) each word is matched literally after
/// escaping the RegExp charset `-[]/{}()*+?.\^$|`; with false the word text
/// is used as a regular expression pattern. [caseSensitive] false (default)
/// matches case-insensitively. Empty words are dropped. Overlapping or nested
/// matches merge into a single chunk taking the widest end; merged styles use
/// the later word's value for shared keys. When nothing matches, a single
/// non-highlighted chunk covers the whole source string.
List<HighlightChunk<T>> findAll<T>({
  required String sourceString,
  required List<SemiHighlightWord<T>> searchWords,
  bool autoEscape = true,
  bool caseSensitive = false,
}) {
  final chunks = findChunks(
    autoEscape: autoEscape,
    caseSensitive: caseSensitive,
    searchWords: searchWords,
    sourceString: sourceString,
  );
  final chunksToHighlight = combineChunks(chunks: chunks);
  return fillInChunks(
    chunksToHighlight: chunksToHighlight,
    totalLength: sourceString.length,
  );
}

/// Escapes the RegExp charset `-[]/{}()*+?.\^$|`, mirroring upstream
/// `escapeRegExpFn`.
String escapeRegExp(String string) => string.replaceAllMapped(
  RegExp(r'[-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]'),
  (match) => '\\${match[0]}',
);

/// Examines text for any matches and collects one raw chunk per non-empty
/// match, in search word order then ascending position.
List<HighlightChunk<T>> findChunks<T>({
  required bool autoEscape,
  required bool caseSensitive,
  required List<SemiHighlightWord<T>> searchWords,
  required String sourceString,
}) {
  final chunks = <HighlightChunk<T>>[];
  for (final searchWord in searchWords) {
    if (searchWord.text.isEmpty) continue; // Remove empty words.
    final searchText = autoEscape
        ? escapeRegExp(searchWord.text)
        : searchWord.text;
    final regex = RegExp(searchText, caseSensitive: caseSensitive);
    for (final match in regex.allMatches(sourceString)) {
      // Only accept real ranges; zero-length matches (e.g. 'a*') are dropped
      // so they can never accumulate as empty chunks.
      if (match.end > match.start) {
        chunks.add(
          HighlightChunk<T>(
            highlight: true,
            start: match.start,
            end: match.end,
            style: searchWord.style,
          ),
        );
      }
    }
  }
  return chunks;
}

/// Combines chunks that overlap or nest into single chunks. Sorting by start
/// is stable, so words listed earlier in [findChunks] win the style merge for
/// keys the later words do not define; later words override shared keys
/// (`{...prev.style, ...next.style}`).
List<HighlightChunk<T>> combineChunks<T>({
  required List<HighlightChunk<T>> chunks,
}) {
  final sorted = chunks.indexed.toList()
    ..sort((first, second) {
      final byStart = first.$2.start.compareTo(second.$2.start);
      return byStart != 0 ? byStart : first.$1.compareTo(second.$1);
    });
  final processedChunks = <HighlightChunk<T>>[];
  for (final (_, nextChunk) in sorted) {
    // First chunk just goes straight in the array...
    if (processedChunks.isEmpty) {
      processedChunks.add(nextChunk);
      continue;
    }
    // ... subsequent chunks get checked to see if they overlap...
    final prevChunk = processedChunks.removeLast();
    if (nextChunk.start <= prevChunk.end) {
      // It may be the case that prevChunk completely surrounds nextChunk, so
      // take the largest of the end indices.
      processedChunks.add(
        HighlightChunk<T>(
          highlight: true,
          start: prevChunk.start,
          end: prevChunk.end > nextChunk.end ? prevChunk.end : nextChunk.end,
          style: _mergeStyles<T>(prevChunk.style, nextChunk.style),
        ),
      );
    } else {
      processedChunks
        ..add(prevChunk)
        ..add(nextChunk);
    }
  }
  return processedChunks;
}

/// Fills the gaps between highlighted chunks so every code unit of
/// `sourceString` is covered exactly once. Chunks with `end - start <= 0` are
/// dropped; with nothing highlighted a single plain chunk covers everything.
List<HighlightChunk<T>> fillInChunks<T>({
  required List<HighlightChunk<T>> chunksToHighlight,
  required int totalLength,
}) {
  final allChunks = <HighlightChunk<T>>[];
  void append(int start, int end, bool highlight, [T? style]) {
    if (end - start > 0) {
      allChunks.add(
        HighlightChunk<T>(
          start: start,
          end: end,
          highlight: highlight,
          style: style,
        ),
      );
    }
  }

  if (chunksToHighlight.isEmpty) {
    append(0, totalLength, false);
  } else {
    var lastIndex = 0;
    for (final chunk in chunksToHighlight) {
      append(lastIndex, chunk.start, false);
      append(chunk.start, chunk.end, true, chunk.style);
      lastIndex = chunk.end;
    }
    append(lastIndex, totalLength, false);
  }
  return allChunks;
}

/// `{...prev.style, ...next.style}` for styles following the
/// `T merge(T other)` contract ([TextStyle.merge] semantics: non-null fields
/// of the later style override, everything else is kept).
T? _mergeStyles<T>(T? prevStyle, T? nextStyle) {
  if (prevStyle == null) return nextStyle;
  if (nextStyle == null) return prevStyle;
  // Dynamic dispatch keeps this file Flutter-free; TextStyle and any style
  // type with a `merge` method follow the same spread semantics.
  return (prevStyle as dynamic).merge(nextStyle) as T?;
}
