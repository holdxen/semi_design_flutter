import 'package:flutter/painting.dart';

/// Canonical tooltip arrow shape (24×7, tip pointing down), transcribed
/// verbatim from upstream `packages/semi-ui/tooltip/TriangleArrow.tsx`:
///
/// ```text
/// M24 0V1C20 1 18.5 2 16.5 4C14.5 6 14 7 12 7C10 7 9.5 6 7.5 4C5.5 2 4 1 0 1V0H24Z
/// ```
///
/// It is a smooth concave "wing", not a straight-sided triangle: a 1px flat
/// attachment strip across the top edge and two cubic shoulders sweeping down
/// to a rounded tip at (12, 7). Upstream rotates this path 180° for the
/// upward-pointing variant.
Path tooltipArrowWingHorizontal() => Path()
  ..moveTo(24, 0)
  ..lineTo(24, 1)
  ..cubicTo(20, 1, 18.5, 2, 16.5, 4)
  ..cubicTo(14.5, 6, 14, 7, 12, 7)
  ..cubicTo(10, 7, 9.5, 6, 7.5, 4)
  ..cubicTo(5.5, 2, 4, 1, 0, 1)
  ..lineTo(0, 0)
  ..close();

/// Canonical side arrow shape (7×24, tip pointing right), transcribed verbatim
/// from upstream `packages/semi-ui/tooltip/TriangleArrowVertical.tsx`:
///
/// ```text
/// M0 0L1 0C1 4, 2 5.5, 4 7.5S7,10 7,12S6 14.5, 4 16.5S1,20 1,24L0 24L0 0z
/// ```
///
/// The SVG `S` (smooth-cubic) commands are expanded to explicit cubics using
/// the reflected control points: (6,9.5), (7,14), (2,18.5). Upstream rotates
/// this path 180° for the left-pointing variant.
Path tooltipArrowWingVertical() => Path()
  ..moveTo(0, 0)
  ..lineTo(1, 0)
  ..cubicTo(1, 4, 2, 5.5, 4, 7.5)
  ..cubicTo(6, 9.5, 7, 10, 7, 12)
  ..cubicTo(7, 14, 6, 14.5, 4, 16.5)
  ..cubicTo(2, 18.5, 1, 20, 1, 24)
  ..lineTo(0, 24)
  ..close();

/// Popover-family arrow fringe (24×8, tip pointing down), transcribed verbatim
/// from upstream `packages/semi-ui/popover/Arrow.tsx` (the `path:nth-child(1)`
/// behind `fill: var(--semi-color-border)`):
///
/// ```text
/// M0 0.5L0 1.5C4 1.5, 5.5 3, 7.5 5S10,8 12,8S14.5 7, 16.5 5S20,1.5 24,1.5L24 0.5L0 0.5z
/// ```
///
/// The same wing lifted 0.5px off the bubble edge so the 0.5–1px outline
/// shows around the fill path (`path:nth-child(2)`, the plain
/// [tooltipArrowWingHorizontal] behind `fill: var(--semi-color-bg-3)`).
/// The SVG `S` commands are expanded to explicit cubics using the reflected
/// control points: (9.5,7), (14,8), (18.5,3).
Path tooltipArrowFringeHorizontal() => Path()
  ..moveTo(0, 0.5)
  ..lineTo(0, 1.5)
  ..cubicTo(4, 1.5, 5.5, 3, 7.5, 5)
  ..cubicTo(9.5, 7, 10, 8, 12, 8)
  ..cubicTo(14, 8, 14.5, 7, 16.5, 5)
  ..cubicTo(18.5, 3, 20, 1.5, 24, 1.5)
  ..lineTo(24, 0.5)
  ..lineTo(0, 0.5)
  ..close();

/// Popover-family side arrow fringe (8×24, tip pointing right), transcribed
/// verbatim from upstream `packages/semi-ui/popover/Arrow.tsx`
/// (`path:nth-child(1)` of the vertical variant):
///
/// ```text
/// M0.5 0L1.5 0C1.5 4, 3 5.5, 5 7.5S8,10 8,12S7 14.5, 5 16.5S1.5,20 1.5,24L0.5 24L0.5 0z
/// ```
///
/// Reflected `S` control points: (7,9.5), (8,14), (3,18.5). Fill path is the
/// plain [tooltipArrowWingVertical].
Path tooltipArrowFringeVertical() => Path()
  ..moveTo(0.5, 0)
  ..lineTo(1.5, 0)
  ..cubicTo(1.5, 4, 3, 5.5, 5, 7.5)
  ..cubicTo(7, 9.5, 8, 10, 8, 12)
  ..cubicTo(8, 14, 7, 14.5, 5, 16.5)
  ..cubicTo(3, 18.5, 1.5, 20, 1.5, 24)
  ..lineTo(0.5, 24)
  ..close();
