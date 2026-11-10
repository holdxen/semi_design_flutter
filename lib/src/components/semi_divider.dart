import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/semi_divider_theme.dart';

enum SemiDividerLayout { horizontal, vertical }

enum SemiDividerAlign { left, center, right }

/// A decorative separator. Vertical layout ignores [text] and [child], as upstream.
class SemiDivider extends StatelessWidget {
  const SemiDivider({
    super.key,
    this.layout = SemiDividerLayout.horizontal,
    this.align = SemiDividerAlign.center,
    this.dashed = false,
    this.text,
    this.child,
    this.margin,
    this.color,
    this.thickness,
    this.height,
    this.textStyle,
  }) : assert(text == null || child == null),
       assert(margin == null || margin >= 0),
       assert(thickness == null || thickness >= 0),
       assert(height == null || height >= 0);
  final SemiDividerLayout layout;
  final SemiDividerAlign align;
  final bool dashed;
  final String? text;
  final Widget? child;

  /// Overrides top/bottom margins horizontally, left/right vertically (logical px).
  final double? margin;
  final Color? color;
  final double? thickness;

  /// Vertical line height, excluding margin.
  final double? height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = SemiDividerTheme.resolve(context);
    final vertical = layout == SemiDividerLayout.vertical;
    final stroke = thickness ?? theme.thickness;
    final paintColor = color ?? theme.color;
    var insets = vertical ? theme.verticalMargin : theme.horizontalMargin;
    if (margin != null) {
      insets = vertical
          ? insets.copyWith(left: margin, right: margin)
          : insets.copyWith(top: margin, bottom: margin);
    }
    Widget line(double width, double lineHeight, bool isVertical) =>
        ExcludeSemantics(
          child: CustomPaint(
            size: Size(width, lineHeight),
            painter: SemiDividerPainter(
              color: paintColor,
              thickness: stroke,
              dashed: dashed,
              vertical: isVertical,
            ),
          ),
        );
    if (vertical) {
      return Padding(
        padding: insets,
        child: line(stroke, height ?? theme.verticalHeight, true),
      );
    }
    final content = text != null && text!.isNotEmpty
        ? Text(text!, maxLines: 1, overflow: TextOverflow.clip)
        : child;
    return Padding(
      padding: insets,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // CSS percentage widths have no useful counterpart in a shrink-wrapped Row.
          // A finite minimum keeps this safe without introducing an arbitrary screen width.
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : constraints.minWidth;
          if (content == null) return line(width, stroke, false);
          final style = TextStyle(
            color: theme.textColor,
            fontWeight: theme.fontWeight,
            fontSize: theme.fontSize,
          ).merge(textStyle);
          Widget strokeLine() => SizedBox(
            height: stroke,
            child: LayoutBuilder(
              builder: (_, bounds) => line(bounds.maxWidth, stroke, false),
            ),
          );
          final fixed = math.min(
            width / 2,
            align == SemiDividerAlign.left
                ? theme.leftLineWidth
                : theme.rightLineWidth,
          );
          return SizedBox(
            width: width,
            child: ClipRect(
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  if (align == SemiDividerAlign.left)
                    SizedBox(width: fixed, child: strokeLine())
                  else
                    Expanded(child: strokeLine()),
                  Flexible(
                    flex: 0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.max(
                          0,
                          width -
                              (align == SemiDividerAlign.center ? 0 : fixed),
                        ),
                      ),
                      child: DefaultTextStyle(
                        style: DefaultTextStyle.of(context).style.merge(style),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        child: text != null || child is Text
                            ? Padding(
                                padding: theme.textPadding,
                                child: content,
                              )
                            : content,
                      ),
                    ),
                  ),
                  if (align == SemiDividerAlign.right)
                    SizedBox(width: fixed, child: strokeLine())
                  else
                    Expanded(child: strokeLine()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Paints decorative solid or dashed strokes; dash length is three stroke widths.
class SemiDividerPainter extends CustomPainter {
  const SemiDividerPainter({
    required this.color,
    required this.thickness,
    required this.dashed,
    required this.vertical,
  });
  final Color color;
  final double thickness;
  final bool dashed, vertical;
  @override
  void paint(Canvas canvas, Size size) {
    if (thickness <= 0 || size.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    final length = vertical ? size.height : size.width;
    void segment(double start, double end) => canvas.drawLine(
      vertical ? Offset(size.width / 2, start) : Offset(start, size.height / 2),
      vertical ? Offset(size.width / 2, end) : Offset(end, size.height / 2),
      paint,
    );
    if (!dashed) {
      segment(0, length);
      return;
    }
    final dash = math.max(1.0, thickness * 3);
    for (var start = 0.0; start < length; start += dash * 2) {
      segment(start, math.min(start + dash, length));
    }
  }

  @override
  bool shouldRepaint(SemiDividerPainter oldDelegate) =>
      color != oldDelegate.color ||
      thickness != oldDelegate.thickness ||
      dashed != oldDelegate.dashed ||
      vertical != oldDelegate.vertical;
}
