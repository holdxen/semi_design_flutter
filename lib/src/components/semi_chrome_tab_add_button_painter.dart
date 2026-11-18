import 'package:flutter/widgets.dart';

class SemiChromeTabAddButtonPainter extends CustomPainter {
  const SemiChromeTabAddButtonPainter({
    required this.color,
    required this.hovered,
  });

  final Color color;
  final bool hovered;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    if (hovered) {
      canvas.drawCircle(
        center,
        size.shortestSide / 3,
        Paint()..color = const Color(0x14000000),
      );
    }
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final half = size.shortestSide * 0.15;
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
      oldDelegate.color != color || oldDelegate.hovered != hovered;
}
