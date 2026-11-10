import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// RGB or RGBA channels; alpha is kept separately from the RGB values.
class SemiChannels {
  const SemiChannels(this.red, this.green, this.blue, this.alpha);
  final int red, green, blue;
  final double alpha;
  Color toColor() => Color.fromRGBO(red, green, blue, alpha);
}

/// CSS px or percentage. Percentage requires the corresponding layout extent.
class SemiLength {
  const SemiLength.pixels(this.value) : isPercent = false;
  const SemiLength.percent(this.value) : isPercent = true;
  final double value;
  final bool isPercent;
  double resolve(double extent) => isPercent ? extent * value / 100 : value;
  Radius resolveRadius(Size size) =>
      Radius.elliptical(resolve(size.width), resolve(size.height));
}

/// CSS angle is clockwise from up. Endpoints depend on the actual box size.
class SemiGradient {
  SemiGradient(this.degrees, List<Color> colors, List<double> stops)
    : colors = List.unmodifiable(colors),
      stops = List.unmodifiable(stops);
  final double degrees;
  final List<Color> colors;
  final List<double> stops;
  LinearGradient forSize(Size size) {
    if (size.width <= 0 || size.height <= 0) {
      throw ArgumentError.value(size, 'size', 'Must have positive dimensions');
    }
    final angle = degrees * math.pi / 180;
    final dx = math.sin(angle), dy = -math.cos(angle);
    final half = (size.width * dx.abs() + size.height * dy.abs()) / 2;
    final end = Alignment(
      dx * half * 2 / size.width,
      dy * half * 2 / size.height,
    );
    return LinearGradient(
      begin: Alignment(-end.x, -end.y),
      end: end,
      colors: colors,
      stops: stops,
    );
  }
}

/// A single layer including the CSS inset flag. Inset needs a dedicated painter.
class SemiShadowLayer {
  const SemiShadowLayer(
    this.inset,
    this.x,
    this.y,
    this.blur,
    this.spread,
    this.color,
  );
  final bool inset;
  final double x, y, blur, spread;
  final Color color;
  BoxShadow toBoxShadow() {
    if (inset) {
      throw UnsupportedError('Inset shadows require a dedicated painter');
    }
    return BoxShadow(
      color: color,
      offset: Offset(x, y),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }
}

class SemiShadows {
  SemiShadows(List<SemiShadowLayer> layers)
    : layers = List.unmodifiable(layers);
  final List<SemiShadowLayer> layers;

  /// Refuses inset rather than silently dropping it.
  List<BoxShadow> toBoxShadows() =>
      layers.map((e) => e.toBoxShadow()).toList(growable: false);
}

/// Restricted upstream scale/rotation model, not a CSS transform interpreter.
class SemiTransform {
  const SemiTransform.scale(this.scaleX, this.scaleY) : degrees = 0;
  const SemiTransform.rotate(this.degrees) : scaleX = 1, scaleY = 1;
  final double scaleX, scaleY, degrees;
}
