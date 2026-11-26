// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/viewLines/rangeUtil.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch439).
//
// Adaptations: DOM elements / Range / DOMRectList are narrow carriers so the
// range math can be replayed without a browser.
// ---------------------------------------------------------------------------

import '../../../../base/common/uint.dart' show Constants;
import '../../view/renderingContext.dart' show FloatHorizontalRange;

/// 1:1 subset: a DOMRectList entry (`left`, `width`).
class ClientRect {
  final num left;
  final num width;
  ClientRect(this.left, this.width);
}

/// 1:1 subset: a DOM text Range over element/offset pairs.
abstract class IDomRange {
  void setStart(Object element, int offset);
  void setEnd(Object element, int offset);
  List<ClientRect>? getClientRects();
  void selectNodeContents(Object endNode);
}

/// Environment injecting `document.createRange()` and DOM element access.
class RangeUtilEnvironment {
  final IDomRange Function() createRange;
  RangeUtilEnvironment(this.createRange);
}

/// 1:1: `DomReadingContext` subset used here.
abstract class IRangeReadingContext {
  Object get endNode;
  num get clientRectDeltaLeft;
  num get clientRectScale;
  void markDidDomLayout();
}

/// Minimal DOM element carrier used by [RangeUtil].
abstract class IElementNode {
  Object? get firstChild;
  String? get textContent;
  List<IElementNode> get children;
  List<ClientRect> getClientRects();
}

/// 1:1: `RangeUtil`.
class RangeUtil {
  static IDomRange? _handyReadyRange;
  static RangeUtilEnvironment? _environment;

  /// Install the DOM environment (production supplies real DOM; replay fakes).
  static void configure(RangeUtilEnvironment environment) =>
      _environment = environment;

  static IDomRange _createRange() {
    final IDomRange? existing = _handyReadyRange;
    if (existing != null) return existing;
    final IDomRange created = _environment!.createRange();
    _handyReadyRange = created;
    return created;
  }

  static void _detachRange(IDomRange range, Object endNode) =>
      range.selectNodeContents(endNode);

  static List<ClientRect>? _readClientRects(
    Object startElement,
    int startOffset,
    Object endElement,
    int endOffset,
    Object endNode,
  ) {
    final IDomRange range = _createRange();
    try {
      range.setStart(startElement, startOffset);
      range.setEnd(endElement, endOffset);
      return range.getClientRects();
    } catch (_) {
      // This is life ...
      return null;
    } finally {
      _detachRange(range, endNode);
    }
  }

  static List<FloatHorizontalRange> _mergeAdjacentRanges(
    List<FloatHorizontalRange> ranges,
  ) {
    if (ranges.length == 1) {
      return ranges;
    }
    ranges.sort(FloatHorizontalRange.compare);

    final List<FloatHorizontalRange> result = <FloatHorizontalRange>[];
    FloatHorizontalRange prev = ranges[0];
    for (int i = 1, len = ranges.length; i < len; i++) {
      final FloatHorizontalRange range = ranges[i];
      if (prev.left + prev.width + 0.9 >= range.left) {
        final num width = range.left + range.width - prev.left;
        prev.width = prev.width > width ? prev.width : width;
      } else {
        result.add(prev);
        prev = range;
      }
    }
    result.add(prev);
    return result;
  }

  static List<FloatHorizontalRange>? _createHorizontalRangesFromClientRects(
    List<ClientRect>? clientRects,
    num clientRectDeltaLeft,
    num clientRectScale,
  ) {
    if (clientRects == null || clientRects.isEmpty) {
      return null;
    }
    final List<FloatHorizontalRange> result = <FloatHorizontalRange>[];
    for (int i = 0, len = clientRects.length; i < len; i++) {
      final ClientRect clientRect = clientRects[i];
      final num left = ((clientRect.left - clientRectDeltaLeft) / clientRectScale);
      result.add(FloatHorizontalRange(
        left < 0 ? 0 : left,
        clientRect.width / clientRectScale,
      ));
    }
    return _mergeAdjacentRanges(result);
  }

  /// Replay hooks exposing the internal range math (1:1 delegating aliases).
  static List<FloatHorizontalRange> mergeAdjacentRangesForReplay(
          List<FloatHorizontalRange> ranges) =>
      _mergeAdjacentRanges(ranges);

  static List<FloatHorizontalRange>? horizontalRangesFromRectsForReplay(
          List<ClientRect>? rects, num deltaLeft, num scale) =>
      _createHorizontalRangesFromClientRects(rects, deltaLeft, scale);

  /// 1:1: `readHorizontalRangeForElement`.
  static FloatHorizontalRange? readHorizontalRangeForElement(
    IElementNode domNode,
    int childIndex,
    IRangeReadingContext context,
  ) {
    if (childIndex < 0 || childIndex >= domNode.children.length) return null;
    final IElementNode child = domNode.children[childIndex];
    final List<ClientRect> clientRects = child.getClientRects();
    context.markDidDomLayout();
    final List<FloatHorizontalRange>? ranges =
        _createHorizontalRangesFromClientRects(
      clientRects,
      context.clientRectDeltaLeft,
      context.clientRectScale,
    );
    return ranges != null && ranges.isNotEmpty ? ranges[0] : null;
  }

  /// 1:1: `readHorizontalRanges`.
  static List<FloatHorizontalRange>? readHorizontalRanges(
    IElementNode domNode,
    int startChildIndex,
    int startOffset,
    int endChildIndex,
    int endOffset,
    IRangeReadingContext context,
  ) {
    // Panic check
    const int min = 0;
    final int max = domNode.children.length - 1;
    if (min > max) {
      return null;
    }
    startChildIndex = _clamp(startChildIndex, min, max);
    endChildIndex = _clamp(endChildIndex, min, max);

    if (startChildIndex == endChildIndex &&
        startOffset == endOffset &&
        startOffset == 0 &&
        domNode.children[startChildIndex].firstChild == null) {
      final List<ClientRect> clientRects =
          domNode.children[startChildIndex].getClientRects();
      context.markDidDomLayout();
      return _createHorizontalRangesFromClientRects(
        clientRects,
        context.clientRectDeltaLeft,
        context.clientRectScale,
      );
    }

    // If crossing over to a span only to select offset 0, use previous span's
    // maximum offset (Chrome bug with 0 offsets).
    if (startChildIndex != endChildIndex) {
      if (endChildIndex > 0 && endOffset == 0) {
        endChildIndex--;
        endOffset = Constants.MAX_SAFE_SMALL_INTEGER;
      }
    }

    Object? startElement = domNode.children[startChildIndex].firstChild;
    Object? endElement = domNode.children[endChildIndex].firstChild;

    if (startElement == null || endElement == null) {
      // Empty <span> (no text content): try the previous <span>.
      if (startElement == null && startOffset == 0 && startChildIndex > 0) {
        startElement = domNode.children[startChildIndex - 1].firstChild;
        startOffset = Constants.MAX_SAFE_SMALL_INTEGER;
      }
      if (endElement == null && endOffset == 0 && endChildIndex > 0) {
        endElement = domNode.children[endChildIndex - 1].firstChild;
        endOffset = Constants.MAX_SAFE_SMALL_INTEGER;
      }
    }

    if (startElement == null || endElement == null) {
      return null;
    }

    final int startTextLen = (startElement as IElementNode).textContent!.length;
    final int endTextLen = (endElement as IElementNode).textContent!.length;
    startOffset = _clamp(startOffset, 0, startTextLen);
    endOffset = _clamp(endOffset, 0, endTextLen);

    final List<ClientRect>? clientRects = _readClientRects(
      startElement,
      startOffset,
      endElement,
      endOffset,
      context.endNode,
    );
    context.markDidDomLayout();
    return _createHorizontalRangesFromClientRects(
      clientRects,
      context.clientRectDeltaLeft,
      context.clientRectScale,
    );
  }

  static int _clamp(int value, int min, int max) =>
      value < min ? min : (value > max ? max : value);
}
