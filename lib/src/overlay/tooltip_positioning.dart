import 'dart:ui' show Offset;

/// Pure positioning engine for SemiTooltip.
///
/// Ported from `packages/semi-foundation/tooltip/foundation.ts`
/// (`calcPosStyle`, `adjustPosIfNeed`, the arrow clamp at lines 700-746 and the
/// small-trigger correction at lines 668-678). Every function is a pure
/// mapping from geometry inputs to outputs: no Flutter bindings, no widgets,
/// no platform channels, so the whole file is unit-testable directly.
///
/// Coordinate frames follow the web port: rects are screen/viewport
/// coordinates; results are container-relative (the container is normally the
/// full viewport, so both frames coincide). Web-only concerns (body margin,
/// scaled containers, inner container scrolling) are intentionally dropped and
/// documented in docs/semi_tooltip.md.

/// The 12 public placements.
///
/// The four `*Over` straddle states used by the auto-adjust engine are kept on
/// [TooltipPlacement]; [SemiTooltipPosition] is the public `position` API.
enum SemiTooltipPosition {
  top,
  topLeft,
  topRight,
  left,
  leftTop,
  leftBottom,
  right,
  rightTop,
  rightBottom,
  bottom,
  bottomLeft,
  bottomRight,
}

/// The 16 placements the engine works with: the 12 public ones plus the four
/// straddle (`*Over`) internal states used when both horizontal (or both
/// vertical) sides are blocked.
enum TooltipPlacement {
  top,
  topLeft,
  topRight,
  left,
  leftTop,
  leftBottom,
  right,
  rightTop,
  rightBottom,
  bottom,
  bottomLeft,
  bottomRight,
  leftTopOver,
  rightTopOver,
  leftBottomOver,
  rightBottomOver,
}

extension TooltipPlacementConversion on TooltipPlacement {
  /// The matching [SemiTooltipPosition]; `*Over` straddle states collapse to
  /// their left/right corner base.
  SemiTooltipPosition get publicPosition => switch (this) {
    TooltipPlacement.top => SemiTooltipPosition.top,
    TooltipPlacement.topLeft => SemiTooltipPosition.topLeft,
    TooltipPlacement.topRight => SemiTooltipPosition.topRight,
    TooltipPlacement.left => SemiTooltipPosition.left,
    TooltipPlacement.leftTop => SemiTooltipPosition.leftTop,
    TooltipPlacement.leftBottom => SemiTooltipPosition.leftBottom,
    TooltipPlacement.right => SemiTooltipPosition.right,
    TooltipPlacement.rightTop => SemiTooltipPosition.rightTop,
    TooltipPlacement.rightBottom => SemiTooltipPosition.rightBottom,
    TooltipPlacement.bottom => SemiTooltipPosition.bottom,
    TooltipPlacement.bottomLeft => SemiTooltipPosition.bottomLeft,
    TooltipPlacement.bottomRight => SemiTooltipPosition.bottomRight,
    TooltipPlacement.leftTopOver ||
    TooltipPlacement.leftBottomOver => SemiTooltipPosition.leftTop,
    TooltipPlacement.rightTopOver ||
    TooltipPlacement.rightBottomOver => SemiTooltipPosition.rightTop,
  };

  /// Whether the placement puts the popup above/below the trigger (web
  /// `isTB`, the lowercase-first name decides).
  bool get isVerticalAxis => switch (this) {
    TooltipPlacement.top ||
    TooltipPlacement.topLeft ||
    TooltipPlacement.topRight ||
    TooltipPlacement.bottom ||
    TooltipPlacement.bottomLeft ||
    TooltipPlacement.bottomRight => true,
    _ => false,
  };

  /// Whether the placement puts the popup left/right of the trigger (web
  /// `isLR`).
  bool get isHorizontalAxis => !isVerticalAxis;

  /// True for the four internal straddle states.
  bool get isOverState =>
      this == TooltipPlacement.leftTopOver ||
      this == TooltipPlacement.rightTopOver ||
      this == TooltipPlacement.leftBottomOver ||
      this == TooltipPlacement.rightBottomOver;

  /// True for center placements (top/bottom/left/right) that anchor the popup
  /// on the trigger center.
  bool get isCenter =>
      this == TooltipPlacement.top ||
      this == TooltipPlacement.bottom ||
      this == TooltipPlacement.left ||
      this == TooltipPlacement.right;

  /// The popup edge that carries the arrow.
  TooltipArrowEdge get arrowEdge => switch (this) {
    TooltipPlacement.top ||
    TooltipPlacement.topLeft ||
    TooltipPlacement.topRight => TooltipArrowEdge.bottom,
    TooltipPlacement.bottom ||
    TooltipPlacement.bottomLeft ||
    TooltipPlacement.bottomRight => TooltipArrowEdge.top,
    TooltipPlacement.left ||
    TooltipPlacement.leftTop ||
    TooltipPlacement.leftBottom ||
    TooltipPlacement.leftTopOver ||
    TooltipPlacement.leftBottomOver => TooltipArrowEdge.right,
    TooltipPlacement.right ||
    TooltipPlacement.rightTop ||
    TooltipPlacement.rightBottom ||
    TooltipPlacement.rightTopOver ||
    TooltipPlacement.rightBottomOver => TooltipArrowEdge.left,
  };
}

/// The popup edge the arrow is attached to.
enum TooltipArrowEdge { top, bottom, left, right }

/// Conversion from the public enum.
TooltipPlacement tooltipPlacementOf(SemiTooltipPosition position) =>
    TooltipPlacement.values.byName(position.name);

/// A DOM-`DOMRect`-alike: plain geometry, no Flutter types.
class TooltipRect {
  const TooltipRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TooltipRect &&
          left == other.left &&
          top == other.top &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() =>
      'TooltipRect(left: $left, top: $top, width: $width, height: $height)';
}

// ---------------------------------------------------------------------------
// Overflow predicates (foundation.ts isReverse / isOverFlow / isHalfOverFlow /
// isHalfAllEnough / getReverse).
// ---------------------------------------------------------------------------

/// Original space short, reverse space sufficient.
bool tooltipIsReverse(double rowSpace, double reverseSpace, double size) =>
    rowSpace < size && reverseSpace > size;

/// Both original and reverse space insufficient.
bool tooltipIsOverFlow(double rowSpace, double reverseSpace, double size) =>
    rowSpace < size && reverseSpace < size;

/// One of the two half spaces is insufficient (occluded).
bool tooltipIsHalfOverFlow(double posSpace, double negSpace, double size) =>
    posSpace < size || negSpace < size;

/// Web `isHalfAllEnough` (kept verbatim, note the `||`).
bool tooltipIsHalfAllEnough(double posSpace, double negSpace, double size) =>
    posSpace >= size || negSpace >= size;

/// Viewport and container votes combined (foundation.ts `getReverse`).
bool tooltipShouldReverse({
  required bool viewOverFlow,
  required bool containerOverFlow,
  required bool shouldReverseView,
  required bool shouldReverseContainer,
}) => (viewOverFlow && shouldReverseContainer) || shouldReverseView;

// ---------------------------------------------------------------------------
// Placement adjustment (foundation.ts _adjustPos / _reversePos / _expandPos /
// _reducePos and the adjustPosIfNeed switch).
// ---------------------------------------------------------------------------

/// `reverse` adjustment: top↔bottom when [vertical], left↔right otherwise.
TooltipPlacement reversePlacement(
  TooltipPlacement position, {
  required bool vertical,
}) {
  if (vertical) {
    return switch (position) {
      TooltipPlacement.top => TooltipPlacement.bottom,
      TooltipPlacement.bottom => TooltipPlacement.top,
      TooltipPlacement.topLeft => TooltipPlacement.bottomLeft,
      TooltipPlacement.bottomLeft => TooltipPlacement.topLeft,
      TooltipPlacement.topRight => TooltipPlacement.bottomRight,
      TooltipPlacement.bottomRight => TooltipPlacement.topRight,
      TooltipPlacement.leftTop => TooltipPlacement.leftBottom,
      TooltipPlacement.leftBottom => TooltipPlacement.leftTop,
      TooltipPlacement.rightTop => TooltipPlacement.rightBottom,
      TooltipPlacement.rightBottom => TooltipPlacement.rightTop,
      TooltipPlacement.leftTopOver => TooltipPlacement.leftBottomOver,
      TooltipPlacement.leftBottomOver => TooltipPlacement.leftTopOver,
      TooltipPlacement.rightTopOver => TooltipPlacement.rightBottomOver,
      TooltipPlacement.rightBottomOver => TooltipPlacement.rightTopOver,
      _ => position,
    };
  }
  return switch (position) {
    TooltipPlacement.left => TooltipPlacement.right,
    TooltipPlacement.right => TooltipPlacement.left,
    TooltipPlacement.leftTop => TooltipPlacement.rightTop,
    TooltipPlacement.rightTop => TooltipPlacement.leftTop,
    TooltipPlacement.leftBottom => TooltipPlacement.rightBottom,
    TooltipPlacement.rightBottom => TooltipPlacement.leftBottom,
    TooltipPlacement.leftTopOver => TooltipPlacement.rightTopOver,
    TooltipPlacement.rightTopOver => TooltipPlacement.leftTopOver,
    TooltipPlacement.leftBottomOver => TooltipPlacement.rightBottomOver,
    TooltipPlacement.rightBottomOver => TooltipPlacement.leftBottomOver,
    TooltipPlacement.topLeft => TooltipPlacement.topRight,
    TooltipPlacement.topRight => TooltipPlacement.topLeft,
    TooltipPlacement.bottomLeft => TooltipPlacement.bottomRight,
    TooltipPlacement.bottomRight => TooltipPlacement.bottomLeft,
    _ => position,
  };
}

/// Direction the `expand` adjustment concats (web passes `'Left'`/`'Right'`/
/// `'Top'`/`'Bottom'` strings).
enum TooltipExpandDirection { left, right, top, bottom }

/// `expand` adjustment: a center placement grows into the corner facing away
/// from the blocked side. Non-center placements pass through unchanged.
TooltipPlacement expandPlacement(
  TooltipPlacement position,
  TooltipExpandDirection direction,
) {
  return switch ((position, direction)) {
    (TooltipPlacement.top, TooltipExpandDirection.left) =>
      TooltipPlacement.topLeft,
    (TooltipPlacement.top, TooltipExpandDirection.right) =>
      TooltipPlacement.topRight,
    (TooltipPlacement.bottom, TooltipExpandDirection.left) =>
      TooltipPlacement.bottomLeft,
    (TooltipPlacement.bottom, TooltipExpandDirection.right) =>
      TooltipPlacement.bottomRight,
    (TooltipPlacement.left, TooltipExpandDirection.top) =>
      TooltipPlacement.leftTop,
    (TooltipPlacement.left, TooltipExpandDirection.bottom) =>
      TooltipPlacement.leftBottom,
    (TooltipPlacement.right, TooltipExpandDirection.top) =>
      TooltipPlacement.rightTop,
    (TooltipPlacement.right, TooltipExpandDirection.bottom) =>
      TooltipPlacement.rightBottom,
    _ => position,
  };
}

/// `reduce` adjustment: a corner placement converges back to its center when
/// the half spaces suffice. Center/Over placements pass through unchanged.
TooltipPlacement reducePlacement(TooltipPlacement position) {
  return switch (position) {
    TooltipPlacement.topLeft ||
    TooltipPlacement.topRight => TooltipPlacement.top,
    TooltipPlacement.bottomLeft ||
    TooltipPlacement.bottomRight => TooltipPlacement.bottom,
    TooltipPlacement.leftTop ||
    TooltipPlacement.leftBottom => TooltipPlacement.left,
    TooltipPlacement.rightTop ||
    TooltipPlacement.rightBottom => TooltipPlacement.right,
    _ => position,
  };
}

/// Result of `adjustPosIfNeed`.
class TooltipAdjustResult {
  const TooltipAdjustResult({
    required this.placement,
    required this.isHeightOverFlow,
    required this.isWidthOverFlow,
  });

  final TooltipPlacement placement;
  final bool isHeightOverFlow;
  final bool isWidthOverFlow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TooltipAdjustResult &&
          placement == other.placement &&
          isHeightOverFlow == other.isHeightOverFlow &&
          isWidthOverFlow == other.isWidthOverFlow;

  @override
  int get hashCode => Object.hash(placement, isHeightOverFlow, isWidthOverFlow);
}

/// Port of `adjustPosIfNeed` with the web `margin` prop fixed at 0 (the
/// Flutter API does not expose it).
///
/// Deviation from upstream, documented in docs/semi_tooltip.md: upstream
/// evaluates the `reduce` branches against `isWidthOverFlow`/`isHeightOverFlow`
/// *before* those flags are computed at the end of the function, so its reduce
/// code is dead. This port gates `reduce` on the same formula evaluated for the
/// original placement and recomputes the returned pin flags for the final
/// placement, so the documented reduce adjustment actually applies.
TooltipAdjustResult adjustPositionIfNeeded({
  required TooltipPlacement position,
  required TooltipRect triggerRect,
  required double popupWidth,
  required double popupHeight,
  required TooltipRect containerRect,
  required double viewportWidth,
  required double viewportHeight,
  double spacing = 8,
  double anoSpacing = 0,
}) {
  if (popupWidth <= 0 || popupHeight <= 0) {
    return TooltipAdjustResult(
      placement: position,
      isHeightOverFlow: false,
      isWidthOverFlow: false,
    );
  }

  final clientLeft = triggerRect.left;
  final clientRight = triggerRect.right;
  final clientTop = triggerRect.top;
  final clientBottom = triggerRect.bottom;

  final restClientLeft = viewportWidth - clientLeft;
  final restClientTop = viewportHeight - clientTop;
  final restClientRight = viewportWidth - clientRight;
  final restClientBottom = viewportHeight - clientBottom;

  final widthIsBigger = popupWidth > triggerRect.width;
  final heightIsBigger = popupHeight > triggerRect.height;

  // Viewport votes.
  final shouldViewReverseTop =
      clientTop < popupHeight + spacing &&
      restClientBottom > popupHeight + spacing;
  final shouldViewReverseLeft =
      clientLeft < popupWidth + spacing &&
      restClientRight > popupWidth + spacing;
  final shouldViewReverseBottom =
      restClientBottom < popupHeight + spacing &&
      clientTop > popupHeight + spacing;
  final shouldViewReverseRight =
      restClientRight < popupWidth + spacing &&
      clientLeft > popupWidth + spacing;
  final shouldViewReverseTopSide =
      restClientTop < popupHeight + anoSpacing &&
      clientBottom > popupHeight + anoSpacing;
  final shouldViewReverseBottomSide =
      clientBottom < popupHeight + anoSpacing &&
      restClientTop > popupHeight + anoSpacing;
  final shouldViewReverseLeftSide =
      restClientLeft < popupWidth + anoSpacing &&
      clientRight > popupWidth + anoSpacing;
  final shouldViewReverseRightSide =
      clientRight < popupWidth + anoSpacing &&
      restClientLeft > popupWidth + anoSpacing;

  final shouldReverseTopOver =
      restClientTop < popupHeight + spacing &&
      clientBottom > popupHeight + spacing;
  final shouldReverseBottomOver =
      clientBottom < popupHeight + spacing &&
      restClientTop > popupHeight + spacing;
  final shouldReverseLeftOver =
      restClientLeft < popupWidth && clientRight > popupWidth;
  final shouldReverseRightOver =
      clientRight < popupWidth && restClientLeft > popupWidth;

  // Container votes.
  final clientTopInContainer = clientTop - containerRect.top;
  final clientLeftInContainer = clientLeft - containerRect.left;
  final clientBottomInContainer = clientTopInContainer + triggerRect.height;
  final clientRightInContainer = clientLeftInContainer + triggerRect.width;
  final restClientBottomInContainer = containerRect.bottom - clientBottom;
  final restClientRightInContainer = containerRect.right - clientRight;
  final restClientTopInContainer =
      restClientBottomInContainer + triggerRect.height;
  final restClientLeftInContainer =
      restClientRightInContainer + triggerRect.width;

  final shouldContainerReverseTop = tooltipIsReverse(
    clientTopInContainer,
    restClientBottomInContainer,
    popupHeight + spacing,
  );
  final shouldContainerReverseLeft = tooltipIsReverse(
    clientLeftInContainer,
    restClientRightInContainer,
    popupWidth + spacing,
  );
  final shouldContainerReverseBottom = tooltipIsReverse(
    restClientBottomInContainer,
    clientTopInContainer,
    popupHeight + spacing,
  );
  final shouldContainerReverseRight = tooltipIsReverse(
    restClientRightInContainer,
    clientLeftInContainer,
    popupWidth + spacing,
  );
  final shouldContainerReverseTopSide = tooltipIsReverse(
    restClientTopInContainer,
    clientBottomInContainer,
    popupHeight + anoSpacing,
  );
  final shouldContainerReverseBottomSide = tooltipIsReverse(
    clientBottomInContainer,
    restClientTopInContainer,
    popupHeight + anoSpacing,
  );
  final shouldContainerReverseLeftSide = tooltipIsReverse(
    restClientLeftInContainer,
    clientRightInContainer,
    popupWidth + anoSpacing,
  );
  final shouldContainerReverseRightSide = tooltipIsReverse(
    clientRightInContainer,
    restClientLeftInContainer,
    popupWidth + anoSpacing,
  );

  final halfHeight = triggerRect.height / 2;
  final halfWidth = triggerRect.width / 2;

  // Viewport overflow flags.
  final isViewYOverFlow = tooltipIsOverFlow(
    clientTop,
    restClientBottom,
    popupHeight + spacing,
  );
  final isViewXOverFlow = tooltipIsOverFlow(
    clientLeft,
    restClientRight,
    popupWidth + spacing,
  );
  final isViewYOverFlowSide = tooltipIsOverFlow(
    clientBottom,
    restClientTop,
    popupHeight + spacing,
  );
  final isViewXOverFlowSide = tooltipIsOverFlow(
    clientRight,
    restClientLeft,
    popupWidth + spacing,
  );
  final isViewYOverFlowSideHalf = tooltipIsHalfOverFlow(
    clientBottom - halfHeight,
    restClientTop - halfHeight,
    (popupHeight + anoSpacing) / 2,
  );
  final isViewXOverFlowSideHalf = tooltipIsHalfOverFlow(
    clientRight - halfWidth,
    restClientLeft - halfWidth,
    (popupWidth + anoSpacing) / 2,
  );
  final isViewYEnoughSideHalf = tooltipIsHalfAllEnough(
    clientBottom - halfHeight,
    restClientTop - halfHeight,
    (popupHeight + anoSpacing) / 2,
  );
  final isViewXEnoughSideHalf = tooltipIsHalfAllEnough(
    clientRight - halfWidth,
    restClientLeft - halfWidth,
    (popupWidth + anoSpacing) / 2,
  );

  // Container overflow flags.
  final isContainerYOverFlow = tooltipIsOverFlow(
    clientTopInContainer,
    restClientBottomInContainer,
    popupHeight + spacing,
  );
  final isContainerXOverFlow = tooltipIsOverFlow(
    clientLeftInContainer,
    restClientRightInContainer,
    popupWidth + spacing,
  );
  final isContainerYOverFlowSide = tooltipIsOverFlow(
    clientBottomInContainer,
    restClientTopInContainer,
    popupHeight + spacing,
  );
  final isContainerXOverFlowSide = tooltipIsOverFlow(
    clientRightInContainer,
    restClientLeftInContainer,
    popupWidth + spacing,
  );
  final isContainerYOverFlowSideHalf = tooltipIsHalfOverFlow(
    clientBottomInContainer - halfHeight,
    restClientTopInContainer - halfHeight,
    (popupHeight + anoSpacing) / 2,
  );
  final isContainerXOverFlowSideHalf = tooltipIsHalfOverFlow(
    clientRightInContainer - halfWidth,
    restClientLeftInContainer - halfWidth,
    (popupWidth + anoSpacing) / 2,
  );
  final isContainerYEnoughSideHalf = tooltipIsHalfAllEnough(
    clientBottomInContainer - halfHeight,
    restClientTopInContainer - halfHeight,
    (popupHeight + anoSpacing) / 2,
  );
  final isContainerXEnoughSideHalf = tooltipIsHalfAllEnough(
    clientRightInContainer - halfWidth,
    restClientLeftInContainer - halfWidth,
    (popupWidth + anoSpacing) / 2,
  );

  // Combined votes.
  final shouldReverseTop = tooltipShouldReverse(
    viewOverFlow: isViewYOverFlow,
    containerOverFlow: isContainerYOverFlow,
    shouldReverseView: shouldViewReverseTop,
    shouldReverseContainer: shouldContainerReverseTop,
  );
  final shouldReverseLeft = tooltipShouldReverse(
    viewOverFlow: isViewXOverFlow,
    containerOverFlow: isContainerXOverFlow,
    shouldReverseView: shouldViewReverseLeft,
    shouldReverseContainer: shouldContainerReverseLeft,
  );
  final shouldReverseBottom = tooltipShouldReverse(
    viewOverFlow: isViewYOverFlow,
    containerOverFlow: isContainerYOverFlow,
    shouldReverseView: shouldViewReverseBottom,
    shouldReverseContainer: shouldContainerReverseBottom,
  );
  final shouldReverseRight = tooltipShouldReverse(
    viewOverFlow: isViewXOverFlow,
    containerOverFlow: isContainerXOverFlow,
    shouldReverseView: shouldViewReverseRight,
    shouldReverseContainer: shouldContainerReverseRight,
  );
  final shouldReverseTopSide = tooltipShouldReverse(
    viewOverFlow: isViewYOverFlowSide,
    containerOverFlow: isContainerYOverFlowSide,
    shouldReverseView: shouldViewReverseTopSide,
    shouldReverseContainer: shouldContainerReverseTopSide,
  );
  final shouldReverseBottomSide = tooltipShouldReverse(
    viewOverFlow: isViewYOverFlowSide,
    containerOverFlow: isContainerYOverFlowSide,
    shouldReverseView: shouldViewReverseBottomSide,
    shouldReverseContainer: shouldContainerReverseBottomSide,
  );
  final shouldReverseLeftSide = tooltipShouldReverse(
    viewOverFlow: isViewXOverFlowSide,
    containerOverFlow: isContainerXOverFlowSide,
    shouldReverseView: shouldViewReverseLeftSide,
    shouldReverseContainer: shouldContainerReverseLeftSide,
  );
  final shouldReverseRightSide = tooltipShouldReverse(
    viewOverFlow: isViewXOverFlowSide,
    containerOverFlow: isContainerXOverFlowSide,
    shouldReverseView: shouldViewReverseRightSide,
    shouldReverseContainer: shouldContainerReverseRightSide,
  );

  final isYOverFlowSideHalf =
      isViewYOverFlowSideHalf && isContainerYOverFlowSideHalf;
  final isXOverFlowSideHalf =
      isViewXOverFlowSideHalf && isContainerXOverFlowSideHalf;

  final blockedRight = clientRight < 0 || restClientRight < 0;
  final blockedTop = clientTop < 0 || restClientTop < 0;

  // Pin flags for a placement (foundation.ts final `isWidthOverFlow`/
  // `isHeightOverFlow` block). Center and corner placements use different
  // half-space formulas.
  bool widthFlagFor(TooltipPlacement p) {
    if (p.isHorizontalAxis) return isViewXOverFlow && isContainerXOverFlow;
    if (p == TooltipPlacement.top || p == TooltipPlacement.bottom) {
      return isXOverFlowSideHalf || blockedRight;
    }
    return (isViewXOverFlowSide && isContainerXOverFlowSide) || blockedRight;
  }

  bool heightFlagFor(TooltipPlacement p) {
    if (p.isVerticalAxis) return isViewYOverFlow && isContainerYOverFlow;
    if (p == TooltipPlacement.left || p == TooltipPlacement.right) {
      return isYOverFlowSideHalf || blockedTop;
    }
    return (isViewYOverFlowSide && isContainerYOverFlowSide) || blockedTop;
  }

  // Upstream evaluates its reduce branches against these flags before it
  // computes them at the end of the function, so its reduce code is dead. The
  // gate here is that same formula evaluated for the *original* placement; the
  // flags reported/used for pinning are recomputed after the switch for the
  // final placement (adjustments never change the axis class, but expand/
  // reduce do change the center/corner formula).
  final gateWidthOverFlow = widthFlagFor(position);
  final gateHeightOverFlow = heightFlagFor(position);

  var placement = position;
  switch (position) {
    case TooltipPlacement.top:
      if (shouldReverseTop) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (isXOverFlowSideHalf &&
          (shouldReverseLeftSide || shouldReverseRightSide)) {
        placement = expandPlacement(
          placement,
          shouldReverseLeftSide
              ? TooltipExpandDirection.right
              : TooltipExpandDirection.left,
        );
      }
    case TooltipPlacement.topLeft:
      if (shouldReverseTop) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseLeftSide && widthIsBigger) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (gateWidthOverFlow &&
          (isViewXEnoughSideHalf || isContainerXEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.topRight:
      if (shouldReverseTop) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseRightSide && widthIsBigger) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (gateWidthOverFlow &&
          (isViewXEnoughSideHalf || isContainerXEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.left:
      if (shouldReverseLeft) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (isYOverFlowSideHalf &&
          (shouldReverseTopSide || shouldReverseBottomSide)) {
        placement = expandPlacement(
          placement,
          shouldReverseTopSide
              ? TooltipExpandDirection.bottom
              : TooltipExpandDirection.top,
        );
      }
    case TooltipPlacement.leftTop:
      if (shouldReverseLeft) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (shouldReverseTopSide && heightIsBigger) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (gateHeightOverFlow &&
          (isViewYEnoughSideHalf || isContainerYEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.leftBottom:
      if (shouldReverseLeft) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (shouldReverseBottomSide && heightIsBigger) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (gateHeightOverFlow &&
          (isViewYEnoughSideHalf || isContainerYEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.bottom:
      if (shouldReverseBottom) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (isXOverFlowSideHalf &&
          (shouldReverseLeftSide || shouldReverseRightSide)) {
        placement = expandPlacement(
          placement,
          shouldReverseLeftSide
              ? TooltipExpandDirection.right
              : TooltipExpandDirection.left,
        );
      }
    case TooltipPlacement.bottomLeft:
      if (shouldReverseBottom) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseLeftSide && widthIsBigger) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (gateWidthOverFlow &&
          (isViewXEnoughSideHalf || isContainerXEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.bottomRight:
      if (shouldReverseBottom) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseRightSide && widthIsBigger) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (gateWidthOverFlow &&
          (isViewXEnoughSideHalf || isContainerXEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.right:
      if (shouldReverseRight) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (isYOverFlowSideHalf &&
          (shouldReverseTopSide || shouldReverseBottomSide)) {
        placement = expandPlacement(
          placement,
          shouldReverseTopSide
              ? TooltipExpandDirection.bottom
              : TooltipExpandDirection.top,
        );
      }
    case TooltipPlacement.rightTop:
      if (shouldReverseRight) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (shouldReverseTopSide && heightIsBigger) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (gateHeightOverFlow &&
          (isViewYEnoughSideHalf || isContainerYEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.rightBottom:
      if (shouldReverseRight) {
        placement = reversePlacement(placement, vertical: false);
      }
      if (shouldReverseBottomSide && heightIsBigger) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (gateHeightOverFlow &&
          (isViewYEnoughSideHalf || isContainerYEnoughSideHalf)) {
        placement = reducePlacement(placement);
      }
    case TooltipPlacement.leftTopOver:
      if (shouldReverseTopOver) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseLeftOver) {
        placement = reversePlacement(placement, vertical: false);
      }
    case TooltipPlacement.leftBottomOver:
      if (shouldReverseBottomOver) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseLeftOver) {
        placement = reversePlacement(placement, vertical: false);
      }
    case TooltipPlacement.rightTopOver:
      if (shouldReverseTopOver) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseRightOver) {
        placement = reversePlacement(placement, vertical: false);
      }
    case TooltipPlacement.rightBottomOver:
      if (shouldReverseBottomOver) {
        placement = reversePlacement(placement, vertical: true);
      }
      if (shouldReverseRightOver) {
        placement = reversePlacement(placement, vertical: false);
      }
  }

  return TooltipAdjustResult(
    placement: placement,
    isHeightOverFlow: heightFlagFor(placement),
    isWidthOverFlow: widthFlagFor(placement),
  );
}

// ---------------------------------------------------------------------------
// Arrow offset (foundation.ts lines 680-746).
// ---------------------------------------------------------------------------

/// Along-edge arrow placement.
///
/// [fraction] applies to center placements: the arrow center as a fraction of
/// the popup edge it sits on. `null` means "use the 50% runtime fallback"
/// (`SemiTooltipTokens.tooltipArrowOffsetX/Y`), matching the upstream rule that
/// stops within 1% of the center renders as the unset default.
///
/// [cornerInset] applies to corner placements: distance in px from the popup's
/// near corner to the arrow's near edge (upstream uses the fixed
/// `$spacing-tooltip_arrow_adjusted_offset-x/y` constants).
class TooltipArrowOffset {
  const TooltipArrowOffset({this.fraction, this.cornerInset});

  final double? fraction;
  final double? cornerInset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TooltipArrowOffset &&
          fraction == other.fraction &&
          cornerInset == other.cornerInset;

  @override
  int get hashCode => Object.hash(fraction, cornerInset);

  @override
  String toString() =>
      'TooltipArrowOffset(fraction: $fraction, cornerInset: $cornerInset)';
}

/// Port of the arrow clamp (foundation.ts 680-746).
///
/// For center placements with `arrowPointAtCenter`, the arrow points at the
/// trigger center: its along-edge fraction is derived from the anchor and
/// clamped to `[arrowSpan/2 + positionOffset, 1 - that]` of the popup edge so
/// the arrow cannot leave the popup. Fractions within 1% of 50% return
/// `fraction: null` (the `--semi-tooltip-arrow-offset-x/y` runtime fallback).
/// With `arrowPointAtCenter: false` the arrow hugs the popup edge facing the
/// trigger. Corner placements return the fixed `cornerInset` constants
/// (5.76 / 5 by default).
TooltipArrowOffset computeArrowOffset({
  required TooltipPlacement placement,
  required bool showArrow,
  required bool arrowPointAtCenter,
  required TooltipRect triggerRect,
  required double popupWidth,
  required double popupHeight,
  required double anchorLeft,
  required double anchorTop,
  required TooltipRect containerRect,
  double arrowSpan = 24,
  double positionOffset = 6,
  double cornerInsetHorizontal = 5.76,
  double cornerInsetVertical = 5,
}) {
  if (!showArrow) {
    return const TooltipArrowOffset();
  }
  final isTopBottom =
      placement == TooltipPlacement.top || placement == TooltipPlacement.bottom;
  final isLeftRight =
      placement == TooltipPlacement.left || placement == TooltipPlacement.right;

  if (!isTopBottom && !isLeftRight) {
    // Corner and Over placements anchor the arrow at the fixed inset.
    final inset = placement.isVerticalAxis
        ? cornerInsetHorizontal
        : cornerInsetVertical;
    return TooltipArrowOffset(cornerInset: inset);
  }

  final middleX = triggerRect.left + triggerRect.width / 2;
  final middleY = triggerRect.top + triggerRect.height / 2;
  final isTriggerNearLeft =
      middleX - containerRect.left < containerRect.right - middleX;
  final isTriggerNearTop =
      middleY - containerRect.top < containerRect.bottom - middleY;

  if (isTopBottom) {
    if (popupWidth <= 0) {
      return const TooltipArrowOffset();
    }
    if (arrowPointAtCenter) {
      // Arrow at the trigger center measured from the popup's left edge:
      // (middleX - left) / width + 0.5 with `left` the anchor point.
      final arrowOffsetPercent =
          (middleX - containerRect.left - anchorLeft) / popupWidth + 0.5;
      final minOffset = (arrowSpan / 2 + positionOffset) / popupWidth;
      final maxOffset = 1 - minOffset;
      final clamped = arrowOffsetPercent.clamp(minOffset, maxOffset).toDouble();
      if ((clamped - 0.5).abs() > 0.01) {
        return TooltipArrowOffset(fraction: clamped);
      }
      return const TooltipArrowOffset();
    }
    final offsetXWithArrow = positionOffset + arrowSpan / 2;
    final fraction = isTriggerNearLeft
        ? offsetXWithArrow / popupWidth
        : (popupWidth - offsetXWithArrow) / popupWidth;
    return TooltipArrowOffset(fraction: fraction);
  }

  if (popupHeight <= 0) {
    return const TooltipArrowOffset();
  }
  if (arrowPointAtCenter) {
    final arrowOffsetPercent =
        (middleY - containerRect.top - anchorTop) / popupHeight + 0.5;
    final minOffset = (arrowSpan / 2 + positionOffset) / popupHeight;
    final maxOffset = 1 - minOffset;
    final clamped = arrowOffsetPercent.clamp(minOffset, maxOffset).toDouble();
    if ((clamped - 0.5).abs() > 0.01) {
      return TooltipArrowOffset(fraction: clamped);
    }
    return const TooltipArrowOffset();
  }
  final offsetYWithArrow = positionOffset + arrowSpan / 2;
  final fraction = isTriggerNearTop
      ? offsetYWithArrow / popupHeight
      : (popupHeight - offsetYWithArrow) / popupHeight;
  return TooltipArrowOffset(fraction: fraction);
}

// ---------------------------------------------------------------------------
// Base style (foundation.ts calcPosStyle) and the public entry point.
// ---------------------------------------------------------------------------

class _Anchor {
  const _Anchor(this.left, this.top, this.translateX, this.translateY);
  final double left;
  final double top;
  final double translateX;
  final double translateY;
}

/// Final position of the popup.
class TooltipPositionResult {
  const TooltipPositionResult({
    required this.placement,
    required this.left,
    required this.top,
    required this.translateX,
    required this.translateY,
    required this.transformOrigin,
    required this.arrowOffset,
  });

  /// Placement after auto-adjust; may be one of the four `*Over` states.
  final TooltipPlacement placement;

  /// Rounded anchor point, container-relative. The popup's visual top-left is
  /// `(left + translateX * popupWidth, top + translateY * popupHeight)`.
  final double left;
  final double top;

  /// CSS-translate-equivalent fractions of the popup size.
  final double translateX;
  final double translateY;

  /// Scale/opacity animation origin as fractions of the popup size
  /// (web `transform-origin`).
  final Offset transformOrigin;

  /// Arrow placement along the popup edge (see [TooltipArrowOffset]).
  final TooltipArrowOffset arrowOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TooltipPositionResult &&
          placement == other.placement &&
          left == other.left &&
          top == other.top &&
          translateX == other.translateX &&
          translateY == other.translateY &&
          transformOrigin == other.transformOrigin &&
          arrowOffset == other.arrowOffset;

  @override
  int get hashCode => Object.hash(
    placement,
    left,
    top,
    translateX,
    translateY,
    transformOrigin,
    arrowOffset,
  );

  @override
  String toString() =>
      'TooltipPositionResult(placement: $placement, left: $left, top: $top, '
      'translateX: $translateX, translateY: $translateY, '
      'transformOrigin: $transformOrigin, arrowOffset: $arrowOffset)';
}

/// The 6px constant of foundation.ts (`positionOffsetX`/`positionOffsetY`).
const double tooltipPositionOffset = 6;

/// Small-trigger arrow correction constant: web `numbers.ARROW_BOUNDING.offsetY`.
const double tooltipArrowBoundingOffsetY = 2;

/// `transform-origin` port of `calcTransformOrigin` (foundation.ts 411-435),
/// returned as fractions of the popup size. With `transformFromCenter` the
/// origin snaps to the trigger-center-facing point of the popup for corner
/// placements; otherwise it is the anchor point itself.
Offset computeTransformOrigin({
  required TooltipPlacement placement,
  required TooltipRect triggerRect,
  required double popupWidth,
  required double popupHeight,
  required double translateX,
  required double translateY,
  bool transformFromCenter = true,
}) {
  if (transformFromCenter) {
    switch (placement) {
      case TooltipPlacement.topLeft:
      case TooltipPlacement.bottomLeft:
        return Offset(
          popupWidth > 0
              ? (triggerRect.width / 2).roundToDouble() / popupWidth
              : -translateX,
          -translateY,
        );
      case TooltipPlacement.topRight:
      case TooltipPlacement.bottomRight:
        return Offset(
          popupWidth > 0
              ? (popupWidth - (triggerRect.width / 2).roundToDouble()) /
                    popupWidth
              : -translateX,
          -translateY,
        );
      case TooltipPlacement.leftTop:
      case TooltipPlacement.rightTop:
        return Offset(
          -translateX,
          popupHeight > 0
              ? (triggerRect.height / 2).roundToDouble() / popupHeight
              : -translateY,
        );
      case TooltipPlacement.leftBottom:
      case TooltipPlacement.rightBottom:
        return Offset(
          -translateX,
          popupHeight > 0
              ? (popupHeight - (triggerRect.height / 2).roundToDouble()) /
                    popupHeight
              : -translateY,
        );
      default:
        break;
    }
  }
  return Offset(-translateX, -translateY);
}

_Anchor _baseAnchor({
  required TooltipPlacement placement,
  required TooltipRect triggerRect,
  required double popupWidth,
  required double popupHeight,
  required TooltipRect containerRect,
  required double viewportWidth,
  required double spacing,
  required double anoSpacing,
  required bool pointAtCenter,
  required bool isWidthOverFlow,
  required bool isHeightOverFlow,
  required double arrowSpan,
}) {
  final middleX = triggerRect.left + triggerRect.width / 2;
  final middleY = triggerRect.top + triggerRect.height / 2;
  final offsetXWithArrow = tooltipPositionOffset + arrowSpan / 2;
  final offsetYWithArrow = tooltipPositionOffset + arrowSpan / 2;

  final offsetHeight = popupHeight - containerRect.height > 0
      ? popupHeight - containerRect.height
      : 0.0;
  final offsetWidth = popupWidth - containerRect.width > 0
      ? popupWidth - containerRect.width
      : 0.0;
  final isTriggerNearLeft =
      middleX - containerRect.left < containerRect.right - middleX;
  final isTriggerNearTop =
      middleY - containerRect.top < containerRect.bottom - middleY;
  final isWrapperWidthOverflow = popupWidth > viewportWidth;

  var left = 0.0;
  var top = 0.0;
  var translateX = 0.0;
  var translateY = 0.0;

  switch (placement) {
    case TooltipPlacement.top:
      left = isWidthOverFlow
          ? (isTriggerNearLeft
                ? containerRect.left + popupWidth / 2
                : containerRect.right - popupWidth / 2 + offsetWidth)
          : middleX + anoSpacing;
      top = isHeightOverFlow ? containerRect.top : triggerRect.top - spacing;
      translateX = -0.5;
      translateY = isHeightOverFlow ? 0 : -1;
    case TooltipPlacement.topLeft:
      left = isWidthOverFlow
          ? (isWrapperWidthOverflow
                ? containerRect.left
                : containerRect.right - popupWidth)
          : (pointAtCenter
                ? middleX - offsetXWithArrow + anoSpacing
                : triggerRect.left + anoSpacing);
      top = isHeightOverFlow ? containerRect.top : triggerRect.top - spacing;
      translateY = isHeightOverFlow ? 0 : -1;
    case TooltipPlacement.topRight:
      left = isWidthOverFlow
          ? containerRect.right + offsetWidth
          : (pointAtCenter
                ? middleX + offsetXWithArrow + anoSpacing
                : triggerRect.right + anoSpacing);
      top = isHeightOverFlow ? containerRect.top : triggerRect.top - spacing;
      translateY = isHeightOverFlow ? 0 : -1;
      translateX = -1;
    case TooltipPlacement.left:
      left = isWidthOverFlow ? containerRect.left : triggerRect.left - spacing;
      top = isHeightOverFlow
          ? (isTriggerNearTop
                ? containerRect.top + popupHeight / 2
                : containerRect.bottom - popupHeight / 2 + offsetHeight)
          : middleY + anoSpacing;
      translateX = isWidthOverFlow ? 0 : -1;
      translateY = -0.5;
    case TooltipPlacement.leftTop:
      left = isWidthOverFlow ? containerRect.left : triggerRect.left - spacing;
      top = isHeightOverFlow
          ? containerRect.top
          : (pointAtCenter
                ? middleY - offsetYWithArrow + anoSpacing
                : triggerRect.top + anoSpacing);
      translateX = isWidthOverFlow ? 0 : -1;
    case TooltipPlacement.leftBottom:
      left = isWidthOverFlow ? containerRect.left : triggerRect.left - spacing;
      top = isHeightOverFlow
          ? containerRect.bottom
          : (pointAtCenter
                ? middleY + offsetYWithArrow + anoSpacing
                : triggerRect.bottom + anoSpacing);
      translateX = isWidthOverFlow ? 0 : -1;
      translateY = -1;
    case TooltipPlacement.bottom:
      left = isWidthOverFlow
          ? (isTriggerNearLeft
                ? containerRect.left + popupWidth / 2
                : containerRect.right - popupWidth / 2 + offsetWidth)
          : middleX + anoSpacing;
      top = isHeightOverFlow
          ? containerRect.bottom
          : triggerRect.top + triggerRect.height + spacing;
      translateX = -0.5;
      translateY = isHeightOverFlow ? -1 : 0;
    case TooltipPlacement.bottomLeft:
      left = isWidthOverFlow
          ? (isWrapperWidthOverflow
                ? containerRect.left
                : containerRect.right - popupWidth)
          : (pointAtCenter
                ? middleX - offsetXWithArrow + anoSpacing
                : triggerRect.left + anoSpacing);
      top = isHeightOverFlow
          ? containerRect.bottom
          : triggerRect.top + triggerRect.height + spacing;
      translateY = isHeightOverFlow ? -1 : 0;
    case TooltipPlacement.bottomRight:
      left = isWidthOverFlow
          ? containerRect.right + offsetWidth
          : (pointAtCenter
                ? middleX + offsetXWithArrow + anoSpacing
                : triggerRect.right + anoSpacing);
      top = isHeightOverFlow
          ? containerRect.bottom
          : triggerRect.top + triggerRect.height + spacing;
      translateX = -1;
      translateY = isHeightOverFlow ? -1 : 0;
    case TooltipPlacement.right:
      left = isWidthOverFlow
          ? containerRect.right
          : triggerRect.right + spacing;
      top = isHeightOverFlow
          ? (isTriggerNearTop
                ? containerRect.top + popupHeight / 2
                : containerRect.bottom - popupHeight / 2 + offsetHeight)
          : middleY + anoSpacing;
      translateX = isWidthOverFlow ? -1 : 0;
      translateY = -0.5;
    case TooltipPlacement.rightTop:
      left = isWidthOverFlow
          ? containerRect.right
          : triggerRect.right + spacing;
      top = isHeightOverFlow
          ? containerRect.top
          : (pointAtCenter
                ? middleY - offsetYWithArrow + anoSpacing
                : triggerRect.top + anoSpacing);
      translateX = isWidthOverFlow ? -1 : 0;
    case TooltipPlacement.rightBottom:
      left = isWidthOverFlow
          ? containerRect.right
          : triggerRect.right + spacing;
      top = isHeightOverFlow
          ? containerRect.bottom
          : (pointAtCenter
                ? middleY + offsetYWithArrow + anoSpacing
                : triggerRect.bottom + anoSpacing);
      translateX = isWidthOverFlow ? -1 : 0;
      translateY = -1;
    case TooltipPlacement.leftTopOver:
      left = isWidthOverFlow ? containerRect.left : triggerRect.left - spacing;
      top = isHeightOverFlow ? containerRect.top : triggerRect.top - spacing;
    case TooltipPlacement.rightTopOver:
      left = isWidthOverFlow
          ? containerRect.right
          : triggerRect.right + spacing;
      top = isHeightOverFlow ? containerRect.top : triggerRect.top - spacing;
      translateX = -1;
    case TooltipPlacement.leftBottomOver:
      left = isWidthOverFlow ? containerRect.left : triggerRect.left - spacing;
      top = isHeightOverFlow
          ? containerRect.bottom
          : triggerRect.bottom + spacing;
      translateY = -1;
    case TooltipPlacement.rightBottomOver:
      left = isWidthOverFlow
          ? containerRect.right
          : triggerRect.right + spacing;
      top = isHeightOverFlow
          ? containerRect.bottom
          : triggerRect.bottom + spacing;
      translateX = -1;
      translateY = -1;
  }
  return _Anchor(left, top, translateX, translateY);
}

/// Full positioning pipeline: base anchors for the requested placement,
/// overflow-driven placement adjustment, the small-trigger correction and the
/// arrow clamp. Mirrors foundation.ts `calcPosition` + `calcPosStyle`.
TooltipPositionResult positionTooltip({
  required TooltipRect triggerRect,
  required double popupWidth,
  required double popupHeight,
  required TooltipRect containerRect,
  required double viewportWidth,
  required double viewportHeight,
  SemiTooltipPosition position = SemiTooltipPosition.top,
  double spacing = 8,
  double anoSpacing = 0,
  bool autoAdjustOverflow = true,
  bool showArrow = true,
  bool arrowPointAtCenter = true,
  bool transformFromCenter = true,
  double arrowSpan = 24,
  double arrowBoundingOffsetY = tooltipArrowBoundingOffsetY,
  double positionOffset = tooltipPositionOffset,
  double cornerInsetHorizontal = 5.76,
  double cornerInsetVertical = 5,
}) {
  final pointAtCenter = showArrow && arrowPointAtCenter;
  var placement = tooltipPlacementOf(position);
  var isWidthOverFlow = false;
  var isHeightOverFlow = false;

  if (autoAdjustOverflow) {
    final adjusted = adjustPositionIfNeeded(
      position: placement,
      triggerRect: triggerRect,
      popupWidth: popupWidth,
      popupHeight: popupHeight,
      containerRect: containerRect,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
      spacing: spacing,
      anoSpacing: anoSpacing,
    );
    if (adjusted.placement != placement ||
        adjusted.isHeightOverFlow ||
        adjusted.isWidthOverFlow) {
      placement = adjusted.placement;
      isHeightOverFlow = adjusted.isHeightOverFlow;
      isWidthOverFlow = adjusted.isWidthOverFlow;
    }
  }

  final anchor = _baseAnchor(
    placement: placement,
    triggerRect: triggerRect,
    popupWidth: popupWidth,
    popupHeight: popupHeight,
    containerRect: containerRect,
    viewportWidth: viewportWidth,
    spacing: spacing,
    anoSpacing: anoSpacing,
    pointAtCenter: pointAtCenter,
    isWidthOverFlow: isWidthOverFlow,
    isHeightOverFlow: isHeightOverFlow,
    arrowSpan: arrowSpan,
  );

  // Container-relative (web subtracts the container origin and adds the
  // container scroll; the Flutter container is the overlay with no scroll).
  var left = anchor.left - containerRect.left;
  var top = anchor.top - containerRect.top;

  // Small-trigger correction (foundation.ts 668-678): when the trigger is
  // shorter than the arrow half-span plus offset doubled, shift the popup so
  // the corner-anchored arrow still overlaps the trigger.
  if (showArrow &&
      !arrowPointAtCenter &&
      triggerRect.height <= (arrowSpan / 2 + arrowBoundingOffsetY) * 2) {
    final offsetY =
        triggerRect.height / 2 - (arrowBoundingOffsetY + arrowSpan / 2);
    const verticalCorners = {
      TooltipPlacement.leftTop,
      TooltipPlacement.leftBottom,
      TooltipPlacement.rightTop,
      TooltipPlacement.rightBottom,
    };
    if (verticalCorners.contains(placement)) {
      top +=
          placement == TooltipPlacement.leftTop ||
              placement == TooltipPlacement.rightTop
          ? offsetY
          : -offsetY;
    }
  }

  final arrowOffset = computeArrowOffset(
    placement: placement,
    showArrow: showArrow,
    arrowPointAtCenter: arrowPointAtCenter,
    triggerRect: triggerRect,
    popupWidth: popupWidth,
    popupHeight: popupHeight,
    anchorLeft: anchor.left - containerRect.left,
    anchorTop: anchor.top - containerRect.top,
    containerRect: containerRect,
    arrowSpan: arrowSpan,
    positionOffset: positionOffset,
    cornerInsetHorizontal: cornerInsetHorizontal,
    cornerInsetVertical: cornerInsetVertical,
  );

  final transformOrigin = computeTransformOrigin(
    placement: placement,
    triggerRect: triggerRect,
    popupWidth: popupWidth,
    popupHeight: popupHeight,
    translateX: anchor.translateX,
    translateY: anchor.translateY,
    transformFromCenter: transformFromCenter,
  );

  return TooltipPositionResult(
    placement: placement,
    left: left.roundToDouble(),
    top: top.roundToDouble(),
    translateX: anchor.translateX,
    translateY: anchor.translateY,
    transformOrigin: transformOrigin,
    arrowOffset: arrowOffset,
  );
}
