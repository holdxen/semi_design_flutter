import 'package:flutter/widgets.dart';

class SemiChromeTabAddButtonPainter extends CustomPainter {
  const SemiChromeTabAddButtonPainter({
    required this.color,
    required this.hoverColor,
    required this.hovered,
  });

  final Color color;
  final Color hoverColor;
  final bool hovered;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    if (hovered) {
      // Match Chromium's 28px circular ink-drop highlight.
      canvas.drawCircle(
        center,
        size.shortestSide / 2,
        Paint()..color = hoverColor,
      );
    }
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    // Chromium's add.icon spans 4.56..11.44 in a 16px canvas.
    const half = 3.44;
    canvas.drawLine(
      Offset(center.dx - half, center.dy),
      Offset(center.dx + half, center.dy),
      stroke,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - half),
      Offset(center.dx, center.dy + half),
      stroke,
    );
  }

  @override
  bool shouldRepaint(SemiChromeTabAddButtonPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.hoverColor != hoverColor ||
      oldDelegate.hovered != hovered;
}
