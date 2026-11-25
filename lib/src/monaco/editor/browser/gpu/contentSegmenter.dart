// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/gpu/contentSegmenter.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch423).
// ---------------------------------------------------------------------------

/// 1:1: `Intl.SegmentData` (the fields this port reads).
class SegmentData {
  final String segment;
  final int index;
  final bool? isWordLike;

  SegmentData(this.segment, this.index, this.isWordLike);
}

/// 1:1: `IContentSegmenter`.
abstract class IContentSegmenter {
  /// Gets the content segment at an index within the line data's contents.
  /// Returns null when the index should not be rendered (e.g. the tail end of
  /// an emoji, or the line is not that long).
  String? getSegmentAtIndex(int index);

  SegmentData? getSegmentData(int index);
}

/// Grapheme segmenter provider. Dart has no `Intl.Segmenter`, so a host/test
/// supplies the grapheme segments for a content string as UTF-16-indexed data.
/// Each entry is the segment that starts at its `index` (UTF-16 code units).
typedef GraphemeSegmentsProvider = List<SegmentData> Function(String content);

/// 1:1: `createContentSegmenter`.
IContentSegmenter createContentSegmenter(
  Object lineData,
  Object options, [
  GraphemeSegmentsProvider? graphemeProvider,
]) {
  final dynamic ld = lineData;
  final dynamic opt = options;
  final bool basicAscii = ld.isBasicASCII as bool;
  final bool mono = opt.useMonospaceOptimizations as bool;
  if (basicAscii && mono) {
    return AsciiContentSegmenter(lineData);
  }
  return GraphemeContentSegmenter(lineData, graphemeProvider);
}

/// 1:1: `AsciiContentSegmenter`.
class AsciiContentSegmenter implements IContentSegmenter {
  final String _content;

  AsciiContentSegmenter(Object lineData)
      : _content = (lineData as dynamic).content as String;

  @override
  String? getSegmentAtIndex(int index) {
    // JS `this._content[index]`: UTF-16 code unit at `index`, as a string;
    // out-of-range yields `undefined` in JS.
    if (index < 0 || index >= _content.length) return null;
    final int unit = _content.codeUnitAt(index);
    return String.fromCharCode(unit);
  }

  @override
  SegmentData? getSegmentData(int index) => null;
}

/// 1:1: `GraphemeContentSegmenter`.
class GraphemeContentSegmenter implements IContentSegmenter {
  final List<SegmentData?> _segments = <SegmentData?>[];

  GraphemeContentSegmenter(Object lineData, GraphemeSegmentsProvider? provider) {
    final String content = (lineData as dynamic).content as String;
    // `Array.from(segmenter.segment(content))` — segments start at UTF-16
    // indices. The provider returns them in ascending index order.
    final List<SegmentData> segmentedContent =
        provider != null ? provider(content) : <SegmentData>[];
    int segmenterIndex = 0;

    // JS iterates UTF-16 code units; Dart strings are UTF-16 indexed through
    // codeUnitAt/length, so use those directly for 1:1 index semantics.
    for (int x = 0; x < content.length; x++) {
      final SegmentData? segment = segmenterIndex < segmentedContent.length
          ? segmentedContent[segmenterIndex]
          : null;

      // No more segments in the string (e.g. an emoji is the last segment).
      if (segment == null) {
        break;
      }

      // The segment isn't renderable (e.g. the tail end of an emoji).
      if (segment.index != x) {
        _segments.add(null);
        continue;
      }

      segmenterIndex++;
      _segments.add(segment);
    }
  }

  @override
  String? getSegmentAtIndex(int index) {
    if (index < 0 || index >= _segments.length) return null;
    return _segments[index]?.segment;
  }

  @override
  SegmentData? getSegmentData(int index) {
    if (index < 0 || index >= _segments.length) return null;
    return _segments[index];
  }
}
