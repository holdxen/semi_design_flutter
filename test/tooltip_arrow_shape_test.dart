import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/components/tooltip_arrow_paths.dart';

/// Independent transcription of upstream `TriangleArrow.tsx` (24×7):
/// `M24 0V1C20 1 18.5 2 16.5 4C14.5 6 14 7 12 7C10 7 9.5 6 7.5 4C5.5 2 4 1 0 1V0H24Z`
Path _expectedHorizontal() => Path()
  ..moveTo(24, 0)
  ..lineTo(24, 1)
  ..cubicTo(20, 1, 18.5, 2, 16.5, 4)
  ..cubicTo(14.5, 6, 14, 7, 12, 7)
  ..cubicTo(10, 7, 9.5, 6, 7.5, 4)
  ..cubicTo(5.5, 2, 4, 1, 0, 1)
  ..lineTo(0, 0)
  ..close();

/// Independent transcription of upstream `TriangleArrowVertical.tsx` (7×24):
/// `M0 0L1 0C1 4, 2 5.5, 4 7.5S7,10 7,12S6 14.5, 4 16.5S1,20 1,24L0 24L0 0z`
/// with the `S` commands expanded via reflected control points.
Path _expectedVertical() => Path()
  ..moveTo(0, 0)
  ..lineTo(1, 0)
  ..cubicTo(1, 4, 2, 5.5, 4, 7.5)
  ..cubicTo(6, 9.5, 7, 10, 7, 12)
  ..cubicTo(7, 14, 6, 14.5, 4, 16.5)
  ..cubicTo(2, 18.5, 1, 20, 1, 24)
  ..lineTo(0, 24)
  ..close();

bool _sameShape(Path a, Path b) =>
    Path.combine(PathOperation.xor, a, b).getBounds().isEmpty;

void main() {
  test('horizontal wing matches the upstream SVG shape exactly', () {
    final path = tooltipArrowWingHorizontal();
    expect(path.getBounds(), const Rect.fromLTWH(0, 0, 24, 7));
    expect(_sameShape(path, _expectedHorizontal()), isTrue);
  });

  test('vertical wing matches the upstream SVG shape exactly', () {
    final path = tooltipArrowWingVertical();
    expect(path.getBounds(), const Rect.fromLTWH(0, 0, 7, 24));
    expect(_sameShape(path, _expectedVertical()), isTrue);
  });

  test('wings are curved, not straight-sided triangles', () {
    // A straight triangle through the same extents has a different contour
    // than the bezier wing; the XOR keeps a non-empty region.
    final triangle = Path()
      ..moveTo(24, 0)
      ..lineTo(24, 1)
      ..lineTo(12, 7)
      ..lineTo(0, 1)
      ..lineTo(0, 0)
      ..close();
    expect(_sameShape(tooltipArrowWingHorizontal(), triangle), isFalse);
    final sideTriangle = Path()
      ..moveTo(0, 0)
      ..lineTo(1, 0)
      ..lineTo(7, 12)
      ..lineTo(1, 24)
      ..lineTo(0, 24)
      ..close();
    expect(_sameShape(tooltipArrowWingVertical(), sideTriangle), isFalse);
  });
}
