// Port of `drawCheckbox` (`packages/core/src/internal/data-grid/render/
// draw-checkbox.ts`). Canvas 2D paths map to `Path` + `Canvas.drawPath`.
import 'package:flutter/widgets.dart';

import '../../../common/glide_theme.dart';
import '../../../common/glide_utils.dart';
import '../glide_geometry.dart';
import '../glide_types.dart';

/// `drawCheckbox` (`draw-checkbox.ts:7-122`).
void drawCheckbox(
  Canvas canvas,
  GlideTheme theme,
  GlideBooleanValue checked,
  double x,
  double y,
  double width,
  double height, {
  bool highlighted = false,
  double hoverX = -20,
  double hoverY = -20,
  double? maxSize,
  GlideContentAlign alignment = GlideContentAlign.center,
  GlideMarkerCheckboxStyle style = GlideMarkerCheckboxStyle.square,
}) {
  final centerY = (y + height / 2).floorToDouble();
  final rectBorderRadius = style == GlideMarkerCheckboxStyle.circle
      ? 10000.0
      : (theme.roundingRadius ?? 4);

  var checkBoxWidth = getSquareWidth(
    maxSize ?? theme.checkboxMaxSize,
    height,
    theme.cellVerticalPadding,
  );
  var checkBoxHalfWidth = checkBoxWidth / 2;
  final posX = getSquareXPosFromAlign(
    alignment,
    x,
    width,
    theme.cellHorizontalPadding,
    checkBoxWidth,
  );
  final bb = getSquareBb(posX, centerY, checkBoxWidth);
  final hovered = pointIsWithinBb(x + hoverX, y + hoverY, bb);

  switch (checked) {
    case GlideBooleanValue.checked:
      final checkPath = roundedRectPath(
        GlideRectangle(
          x: posX - checkBoxWidth / 2,
          y: centerY - checkBoxWidth / 2,
          width: checkBoxWidth,
          height: checkBoxWidth,
        ),
        rectBorderRadius,
      );

      if (style == GlideMarkerCheckboxStyle.circle) {
        checkBoxHalfWidth *= 0.8;
        checkBoxWidth *= 0.8;
      }

      canvas.drawPath(
        checkPath,
        Paint()..color = highlighted ? theme.accentColor : theme.textMedium,
      );

      final tick = Path()
        ..moveTo(
          posX - checkBoxHalfWidth + checkBoxWidth / 4.23,
          centerY - checkBoxHalfWidth + checkBoxWidth / 1.97,
        )
        ..lineTo(
          posX - checkBoxHalfWidth + checkBoxWidth / 2.42,
          centerY - checkBoxHalfWidth + checkBoxWidth / 1.44,
        )
        ..lineTo(
          posX - checkBoxHalfWidth + checkBoxWidth / 1.29,
          centerY - checkBoxHalfWidth + checkBoxWidth / 3.25,
        );
      canvas.drawPath(
        tick,
        Paint()
          ..color = theme.bgCell
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.9,
      );

    case GlideBooleanValue.empty || GlideBooleanValue.unchecked:
      final path = roundedRectPath(
        GlideRectangle(
          x: posX - checkBoxWidth / 2 + 0.5,
          y: centerY - checkBoxWidth / 2 + 0.5,
          width: checkBoxWidth - 1,
          height: checkBoxWidth - 1,
        ),
        rectBorderRadius,
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = hovered ? theme.textDark : theme.textMedium,
      );

    case GlideBooleanValue.indeterminate:
      final path = roundedRectPath(
        GlideRectangle(
          x: posX - checkBoxWidth / 2,
          y: centerY - checkBoxWidth / 2,
          width: checkBoxWidth,
          height: checkBoxWidth,
        ),
        rectBorderRadius,
      );
      canvas.drawPath(
        path,
        Paint()..color = hovered ? theme.textMedium : theme.textLight,
      );

      if (style == GlideMarkerCheckboxStyle.circle) {
        checkBoxHalfWidth *= 0.8;
        checkBoxWidth *= 0.8;
      }

      canvas.drawLine(
        Offset(posX - checkBoxWidth / 3, centerY),
        Offset(posX + checkBoxWidth / 3, centerY),
        Paint()
          ..color = theme.bgCell
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.9,
      );
  }
}
