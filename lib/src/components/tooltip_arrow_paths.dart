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
