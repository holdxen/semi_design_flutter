// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/layout.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. `const enum` -> class + static const;
// interfaces -> classes (value objects); object literals -> class instances.
// ---------------------------------------------------------------------------

import './range.dart';

class IAnchor {
  num x;
  num y;
  num? width;
  num? height;
  IAnchor(this.x, this.y, [this.width, this.height]);
}

class AnchorAlignment {
  static const int LEFT = 0;
  static const int RIGHT = 1;
}

class AnchorPosition {
  static const int BELOW = 0;
  static const int ABOVE = 1;
}

class AnchorAxisAlignment {
  static const int VERTICAL = 0;
  static const int HORIZONTAL = 1;
}

class IPosition {
  final num top;
  final num left;
  IPosition(this.top, this.left);
}

class ISize {
  final num width;
  final num height;
  ISize(this.width, this.height);
}

class IRect implements IPosition, ISize {
  @override
  final num top;
  @override
  final num left;
  @override
  final num width;
  @override
  final num height;
  IRect(this.top, this.left, this.width, this.height);
}

class LayoutAnchorPosition {
  static const int Before = 0;
  static const int After = 1;
}

class LayoutAnchorMode {
  static const int AVOID = 0;
  static const int ALIGN = 1;
}

class ILayoutAnchor {
  num offset;
  num size;
  int? mode; // default: AVOID
  int position;
  ILayoutAnchor(this.offset, this.size, this.position, [this.mode]);
}

class ILayoutResult {
  num position;
  String result; // 'ok' | 'flipped' | 'overlap'
  ILayoutResult(this.position, this.result);
}

/// Lays out a one dimensional view next to an anchor in a viewport.
///
/// @returns The view offset within the viewport.
ILayoutResult layout(num viewportSize, num viewSize, ILayoutAnchor anchor) {
  final num layoutAfterAnchorBoundary = anchor.mode == LayoutAnchorMode.ALIGN ? anchor.offset : anchor.offset + anchor.size;
  final num layoutBeforeAnchorBoundary = anchor.mode == LayoutAnchorMode.ALIGN ? anchor.offset + anchor.size : anchor.offset;

  if (anchor.position == LayoutAnchorPosition.Before) {
    if (viewSize <= viewportSize - layoutAfterAnchorBoundary) {
      return ILayoutResult(layoutAfterAnchorBoundary, 'ok'); // happy case, lay it out after the anchor
    }

    if (viewSize <= layoutBeforeAnchorBoundary) {
      return ILayoutResult(layoutBeforeAnchorBoundary - viewSize, 'flipped'); // ok case, lay it out before the anchor
    }

    return ILayoutResult(mathMax(viewportSize - viewSize, 0), 'overlap'); // sad case, lay it over the anchor
  } else {
    if (viewSize <= layoutBeforeAnchorBoundary) {
      return ILayoutResult(layoutBeforeAnchorBoundary - viewSize, 'ok'); // happy case, lay it out before the anchor
    }

    if (viewSize <= viewportSize - layoutAfterAnchorBoundary && layoutBeforeAnchorBoundary < viewSize / 2) {
      return ILayoutResult(layoutAfterAnchorBoundary, 'flipped'); // ok case, lay it out after the anchor
    }

    return ILayoutResult(0, 'overlap'); // sad case, lay it over the anchor
  }
}

class ILayout2DOptions {
  final int? anchorAlignment; // default: left
  final int? anchorPosition; // default: above
  final int? anchorAxisAlignment; // default: vertical
  ILayout2DOptions({this.anchorAlignment, this.anchorPosition, this.anchorAxisAlignment});
}

class ILayout2DResult {
  num top;
  num left;
  num bottom;
  num right;
  int anchorAlignment;
  int anchorPosition;
  ILayout2DResult(this.top, this.left, this.bottom, this.right, this.anchorAlignment, this.anchorPosition);
}

ILayout2DResult layout2d(IRect viewport, ISize view, IRect anchor, [ILayout2DOptions? options]) {
  int anchorAlignment = options?.anchorAlignment ?? AnchorAlignment.LEFT;
  int anchorPosition = options?.anchorPosition ?? AnchorPosition.BELOW;
  final int anchorAxisAlignment = options?.anchorAxisAlignment ?? AnchorAxisAlignment.VERTICAL;

  late final num top;
  late final num left;

  if (anchorAxisAlignment == AnchorAxisAlignment.VERTICAL) {
    final ILayoutAnchor verticalAnchor = ILayoutAnchor(anchor.top - viewport.top, anchor.height, anchorPosition == AnchorPosition.BELOW ? LayoutAnchorPosition.Before : LayoutAnchorPosition.After);
    final ILayoutAnchor horizontalAnchor = ILayoutAnchor(anchor.left, anchor.width, anchorAlignment == AnchorAlignment.LEFT ? LayoutAnchorPosition.Before : LayoutAnchorPosition.After, LayoutAnchorMode.ALIGN);

    final ILayoutResult verticalLayoutResult = layout(viewport.height, view.height, verticalAnchor);
    top = verticalLayoutResult.position + viewport.top;

    if (verticalLayoutResult.result == 'flipped') {
      anchorPosition = anchorPosition == AnchorPosition.BELOW ? AnchorPosition.ABOVE : AnchorPosition.BELOW;
    }

    // if view intersects vertically with anchor, we must avoid the anchor
    if (Range.intersects(IRange(top, top + view.height), IRange(verticalAnchor.offset, verticalAnchor.offset + verticalAnchor.size))) {
      horizontalAnchor.mode = LayoutAnchorMode.AVOID;
    }

    final ILayoutResult horizontalLayoutResult = layout(viewport.width, view.width, horizontalAnchor);
    left = horizontalLayoutResult.position;

    if (horizontalLayoutResult.result == 'flipped') {
      anchorAlignment = anchorAlignment == AnchorAlignment.LEFT ? AnchorAlignment.RIGHT : AnchorAlignment.LEFT;
    }
  } else {
    final ILayoutAnchor horizontalAnchor = ILayoutAnchor(anchor.left, anchor.width, anchorAlignment == AnchorAlignment.LEFT ? LayoutAnchorPosition.Before : LayoutAnchorPosition.After);
    final ILayoutAnchor verticalAnchor = ILayoutAnchor(anchor.top, anchor.height, anchorPosition == AnchorPosition.BELOW ? LayoutAnchorPosition.Before : LayoutAnchorPosition.After, LayoutAnchorMode.ALIGN);

    final ILayoutResult horizontalLayoutResult = layout(viewport.width, view.width, horizontalAnchor);
    left = horizontalLayoutResult.position;

    if (horizontalLayoutResult.result == 'flipped') {
      anchorAlignment = anchorAlignment == AnchorAlignment.LEFT ? AnchorAlignment.RIGHT : AnchorAlignment.LEFT;
    }

    // if view intersects horizontally with anchor, we must avoid the anchor
    if (Range.intersects(IRange(left, left + view.width), IRange(horizontalAnchor.offset, horizontalAnchor.offset + horizontalAnchor.size))) {
      verticalAnchor.mode = LayoutAnchorMode.AVOID;
    }

    final ILayoutResult verticalLayoutResult = layout(viewport.height, view.height, verticalAnchor);
    top = verticalLayoutResult.position + viewport.top;

    if (verticalLayoutResult.result == 'flipped') {
      anchorPosition = anchorPosition == AnchorPosition.BELOW ? AnchorPosition.ABOVE : AnchorPosition.BELOW;
    }
  }

  final num right = viewport.width - (left + view.width);
  final num bottom = viewport.height - (top + view.height);

  return ILayout2DResult(top, left, bottom, right, anchorAlignment, anchorPosition);
}

num mathMax(num a, num b) => a > b ? a : b;
