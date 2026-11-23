// Checkbox cells are painted on the grid Canvas, so they cannot host a
// SemiCheckbox widget. This is the Canvas translation of the SemiCheckbox
// inner box: 16px box, small radius, primary fill + white SVG tick, and a
// 1px border when unchecked. The SVG paths are copied 1:1 from
// assets/icons/checkbox_tick.svg and checkbox_indeterminate.svg (24x24
// viewBox) and scaled to the box size.
import 'package:flutter/widgets.dart';

import '../../../common/semi_data_grid_theme.dart';
import '../../../common/semi_utils.dart';
import '../semi_geometry.dart';
import '../semi_types.dart';

/// `$radius-checkbox_inner` = `borderRadiusExtraSmall` (3px at the default
/// Semi token scale).
const double _semiCheckboxRadius = 3;

/// `assets/icons/checkbox_tick.svg`, in its 24x24 viewBox.
final Path _semiCheckboxTick = Path()
  ..moveTo(17.4111, 7.30848)
  ..cubicTo(18.0692, 7.81171, 18.1947, 8.75312, 17.6915, 9.41119)
  ..lineTo(11.1915, 17.9112)
  ..cubicTo(10.909, 18.2806, 10.4711, 18.4981, 10.0061, 18.5)
  ..cubicTo(9.54105, 18.5019, 9.10143, 18.288, 8.81592, 17.9209)
  ..lineTo(5.31592, 13.4209)
  ..cubicTo(4.80731, 12.767, 4.92512, 11.8246, 5.57904, 11.316)
  ..cubicTo(6.23296, 10.8074, 7.17537, 10.9252, 7.68398, 11.5791)
  ..lineTo(9.98988, 14.5438)
  ..lineTo(15.3084, 7.58884)
  ..cubicTo(15.8116, 6.93077, 16.7531, 6.80525, 17.4111, 7.30848)
  ..close();

/// `assets/icons/checkbox_indeterminate.svg`, in its 24x24 viewBox.
final Path _semiCheckboxIndeterminate = Path()
  ..moveTo(5, 12.5)
  ..cubicTo(5, 11.6716, 5.67157, 11, 6.5, 11)
  ..lineTo(17.5, 11)
  ..cubicTo(18.3284, 11, 19, 11.6716, 19, 12.5)
  ..cubicTo(19, 13.3284, 18.3284, 14, 17.5, 14)
  ..lineTo(6.5, 14)
  ..cubicTo(5.67157, 14, 5, 13.3284, 5, 12.5)
  ..close();

void _drawSemiIcon(
  Canvas canvas,
  Path icon,
  double size,
  Offset center,
  Color color,
) {
  final scale = size / 24;
  canvas.save();
  canvas.translate(center.dx - size / 2, center.dy - size / 2);
  canvas.scale(scale, scale);
  canvas.drawPath(icon, Paint()..color = color);
  canvas.restore();
}

/// `drawCheckbox` (`draw-checkbox.ts:7-122`) painted with SemiCheckbox's
/// inner-box appearance. Geometry and hit testing stay upstream-compatible.
void drawCheckbox(
  Canvas canvas,
  SemiDataGridTheme theme,
  SemiBooleanValue checked,
  double x,
  double y,
  double width,
  double height, {
  bool highlighted = false,
  double hoverX = -20,
  double hoverY = -20,
  double? maxSize,
  SemiContentAlign alignment = SemiContentAlign.center,
  SemiMarkerCheckboxStyle style = SemiMarkerCheckboxStyle.square,
}) {
  final centerY = (y + height / 2).floorToDouble();
  final radius = style == SemiMarkerCheckboxStyle.circle
      ? 10000.0
      : _semiCheckboxRadius;

  var checkBoxWidth = getSquareWidth(
    maxSize ?? theme.checkboxMaxSize,
    height,
    theme.cellVerticalPadding,
  );
  final posX = getSquareXPosFromAlign(
    alignment,
    x,
    width,
    theme.cellHorizontalPadding,
    checkBoxWidth,
  );
  final bb = getSquareBb(posX, centerY, checkBoxWidth);
  final hovered = pointIsWithinBb(x + hoverX, y + hoverY, bb);
  final center = Offset(posX, centerY);

  switch (checked) {
    case SemiBooleanValue.checked:
    case SemiBooleanValue.indeterminate:
      // SemiCheckbox: primary-filled inner box with the white tick/bar.
      canvas.drawPath(
        roundedRectPath(
          SemiRectangle(
            x: posX - checkBoxWidth / 2,
            y: centerY - checkBoxWidth / 2,
            width: checkBoxWidth,
            height: checkBoxWidth,
          ),
          radius,
        ),
        Paint()..color = theme.accentColor,
      );
      if (style == SemiMarkerCheckboxStyle.circle) {
        checkBoxWidth *= 0.8;
      }
      _drawSemiIcon(
        canvas,
        checked == SemiBooleanValue.checked
            ? _semiCheckboxTick
            : _semiCheckboxIndeterminate,
        checkBoxWidth,
        center,
        theme.bgCell,
      );

    case SemiBooleanValue.empty || SemiBooleanValue.unchecked:
      canvas.drawPath(
        roundedRectPath(
          SemiRectangle(
            x: posX - checkBoxWidth / 2 + 0.5,
            y: centerY - checkBoxWidth / 2 + 0.5,
            width: checkBoxWidth - 1,
            height: checkBoxWidth - 1,
          ),
          radius,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = hovered ? theme.accentColor : theme.textMedium,
      );
  }
}
