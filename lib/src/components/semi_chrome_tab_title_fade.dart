import 'package:flutter/widgets.dart';

/// Applies an alpha-only shader to a single-line title without tinting its text.
class SemiChromeTabTitleFade extends StatelessWidget {
  const SemiChromeTabTitleFade({
    super.key,
    required this.title,
    required this.style,
    required this.textDirection,
    required this.enabled,
  });

  final String title;
  final TextStyle style;
  final TextDirection textDirection;
  final bool enabled;

  double _measure(String value, TextScaler textScaler) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final contentWidth = _measure(title, scaler);
        final text = Text(
          title,
          style: style,
          textDirection: textDirection,
          textScaler: scaler,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
        );
        if (!enabled || !width.isFinite || width <= 0 || contentWidth <= width) {
          return text;
        }
        final fadeWidth = _measure('000', scaler).clamp(0.0, width / 3);
        if (fadeWidth <= 0) return text;
        final fourGlyphWidth = _measure('0000', scaler);
        final fadeAlpha = fourGlyphWidth <= 0 || width >= fourGlyphWidth
            ? 0.0
            : ((1 - width / fourGlyphWidth) * 0.2).clamp(0.0, 0.2);
        final transparent = Color.fromARGB(
          (fadeAlpha * 255).round(),
          255,
          255,
          255,
        );
        const opaque = Color(0xffffffff);
        final fadeFraction = (fadeWidth / width).clamp(0.0, 1.0);
        final colors = textDirection == TextDirection.rtl
            ? <Color>[transparent, opaque, opaque]
            : <Color>[opaque, opaque, transparent];
        final stops = textDirection == TextDirection.rtl
            ? <double>[0, fadeFraction, 1]
            : <double>[0, 1 - fadeFraction, 1];
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: colors,
            stops: stops,
          ).createShader(bounds),
          child: text,
        );
      },
    );
  }
}
