// 1:1 port of
// vscode/src/vs/editor/browser/view/renderingContext.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `IViewLayout` is erased in the port; the minimal structural contract
//     below carries the members this file reads.
//   - `ViewModelDecoration` is reused from `editor/common/viewModel.dart`
//     (the already-ported carrier), because the source's separate
//     `viewModelDecoration.ts` is still pending.
//   - `Math.round` is JS semantics (`floor(x + 0.5)`), not Dart's
//     half-away-from-zero `round()`.
//   - `concat(...).sort(...)` is replayed as a stable sort (TS `Array.sort` is
//     stable), so DOM ranges keep their position for equal line numbers.

import '../../common/core/position.dart' show Position;
import '../../common/core/range.dart' show Range;
import '../../common/viewLayout/viewLinesViewportData.dart' show ViewportData;
import '../../common/viewModel.dart' show ViewModelDecoration, Viewport;

/// JS `Math.round`.
int _jsRound(num value) => (value + 0.5).floor();

/// 1:1: `export interface IViewLines`.
abstract class IViewLines {
  List<LineVisibleRanges>? linesVisibleRangesForRange(
    Range range,
    bool includeNewLines,
  );

  HorizontalPosition? visibleRangeForPosition(Position position);
}

/// 1:1: erased `IViewLayout` — the members read by
/// [RestrictedRenderingContext].
abstract class IViewLayoutForRenderingContext {
  num getScrollWidth();

  num getScrollHeight();

  Viewport getCurrentViewport();

  num getVerticalOffsetForLineNumber(int lineNumber, [bool? includeViewZones]);

  num getVerticalOffsetAfterLineNumber(
    int lineNumber, [
    bool? includeViewZones,
  ]);

  num getLineHeightForLineNumber(int lineNumber);
}

/// 1:1: `export abstract class RestrictedRenderingContext`.
class RestrictedRenderingContext {
  final ViewportData viewportData;

  late final num scrollWidth;
  late final num scrollHeight;

  late final Range visibleRange;
  late final int bigNumbersDelta;

  late final num scrollTop;
  late final num scrollLeft;

  late final num viewportWidth;
  late final num viewportHeight;

  final IViewLayoutForRenderingContext _viewLayout;

  RestrictedRenderingContext(this._viewLayout, this.viewportData) {
    scrollWidth = _viewLayout.getScrollWidth();
    scrollHeight = _viewLayout.getScrollHeight();

    visibleRange = viewportData.visibleRange;
    bigNumbersDelta = viewportData.bigNumbersDelta;

    final Viewport vInfo = _viewLayout.getCurrentViewport();
    scrollTop = vInfo.top;
    scrollLeft = vInfo.left;
    viewportWidth = vInfo.width;
    viewportHeight = vInfo.height;
  }

  num getScrolledTopFromAbsoluteTop(num absoluteTop) {
    return absoluteTop - scrollTop;
  }

  num getVerticalOffsetForLineNumber(int lineNumber, [bool? includeViewZones]) {
    return _viewLayout.getVerticalOffsetForLineNumber(
      lineNumber,
      includeViewZones,
    );
  }

  num getVerticalOffsetAfterLineNumber(
    int lineNumber, [
    bool? includeViewZones,
  ]) {
    return _viewLayout.getVerticalOffsetAfterLineNumber(
      lineNumber,
      includeViewZones,
    );
  }

  num getLineHeightForLineNumber(int lineNumber) {
    return _viewLayout.getLineHeightForLineNumber(lineNumber);
  }

  List<ViewModelDecoration> getDecorationsInViewport() {
    // `ViewportData` exposes the model's decorations opaquely; the runtime
    // entries are `ViewModelDecoration` (carrier in viewModel.dart).
    return viewportData.getDecorationsInViewport().cast<ViewModelDecoration>();
  }
}

/// 1:1: `export class RenderingContext extends RestrictedRenderingContext`.
class RenderingContext extends RestrictedRenderingContext {
  final IViewLines _viewLines;
  final IViewLines? _viewLinesGpu;

  RenderingContext(
    IViewLayoutForRenderingContext viewLayout,
    ViewportData viewportData,
    IViewLines viewLines, [
    IViewLines? viewLinesGpu,
  ]) : _viewLines = viewLines,
       _viewLinesGpu = viewLinesGpu,
       super(viewLayout, viewportData);

  List<LineVisibleRanges>? linesVisibleRangesForRange(
    Range range,
    bool includeNewLines,
  ) {
    final List<LineVisibleRanges>? domRanges = _viewLines
        .linesVisibleRangesForRange(range, includeNewLines);
    final IViewLines? gpu = _viewLinesGpu;
    if (gpu == null) {
      return domRanges;
    }
    final List<LineVisibleRanges>? gpuRanges = gpu.linesVisibleRangesForRange(
      range,
      includeNewLines,
    );
    if (domRanges == null) {
      return gpuRanges;
    }
    if (gpuRanges == null) {
      return domRanges;
    }
    final List<LineVisibleRanges> merged = <LineVisibleRanges>[
      ...domRanges,
      ...gpuRanges,
    ];
    // Stable merge order: lineNumber asc, DOM-before-GPU on ties.
    final List<int> order = List<int>.generate(merged.length, (int i) => i);
    order.sort((int a, int b) {
      final int byLine = merged[a].lineNumber.compareTo(merged[b].lineNumber);
      return byLine != 0 ? byLine : a.compareTo(b);
    });
    return <LineVisibleRanges>[for (final int i in order) merged[i]];
  }

  HorizontalPosition? visibleRangeForPosition(Position position) {
    return _viewLines.visibleRangeForPosition(position) ??
        _viewLinesGpu?.visibleRangeForPosition(position);
  }
}

/// 1:1: `export class LineVisibleRanges`.
class LineVisibleRanges {
  LineVisibleRanges(
    this.outsideRenderedLine,
    this.lineNumber,
    this.ranges,
    this.continuesOnNextLine,
  );

  /// Returns the element with the smallest `lineNumber`.
  static LineVisibleRanges? firstLine(List<LineVisibleRanges>? ranges) {
    if (ranges == null) {
      return null;
    }
    LineVisibleRanges? result;
    for (final LineVisibleRanges range in ranges) {
      if (result == null || range.lineNumber < result.lineNumber) {
        result = range;
      }
    }
    return result;
  }

  /// Returns the element with the largest `lineNumber`.
  static LineVisibleRanges? lastLine(List<LineVisibleRanges>? ranges) {
    if (ranges == null) {
      return null;
    }
    LineVisibleRanges? result;
    for (final LineVisibleRanges range in ranges) {
      if (result == null || range.lineNumber > result.lineNumber) {
        result = range;
      }
    }
    return result;
  }

  final bool outsideRenderedLine;
  final int lineNumber;
  final List<HorizontalRange> ranges;

  /// Indicates if the requested range does not end in this line, but continues
  /// on the next line.
  final bool continuesOnNextLine;
}

/// 1:1: `export class HorizontalRange`.
class HorizontalRange {
  HorizontalRange(num left, num width)
    : left = _jsRound(left),
      width = _jsRound(width);

  num left;
  num width;

  static List<HorizontalRange> from(List<FloatHorizontalRange> ranges) {
    final List<HorizontalRange> result = List<HorizontalRange>.filled(
      ranges.length,
      HorizontalRange(0, 0),
    );
    for (int i = 0, len = ranges.length; i < len; i++) {
      final FloatHorizontalRange range = ranges[i];
      result[i] = HorizontalRange(range.left, range.width);
    }
    return result;
  }

  @override
  String toString() => '[$left,$width]';
}

/// 1:1: `export class FloatHorizontalRange`.
class FloatHorizontalRange {
  FloatHorizontalRange(this.left, this.width);

  num left;
  num width;

  @override
  String toString() => '[$left,$width]';

  static int compare(FloatHorizontalRange a, FloatHorizontalRange b) {
    final num diff = a.left - b.left;
    return diff < 0 ? -1 : (diff > 0 ? 1 : 0);
  }
}

/// 1:1: `export class HorizontalPosition`.
class HorizontalPosition {
  HorizontalPosition(this.outsideRenderedLine, num left)
    : originalLeft = left,
      left = _jsRound(left);

  final bool outsideRenderedLine;

  /// `Math.round(this.originalLeft)`
  final int left;
  final num originalLeft;
}

/// 1:1: `export class VisibleRanges`.
class VisibleRanges {
  VisibleRanges(this.outsideRenderedLine, this.ranges);

  final bool outsideRenderedLine;
  final List<FloatHorizontalRange> ranges;
}
