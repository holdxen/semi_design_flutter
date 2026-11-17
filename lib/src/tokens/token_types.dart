import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';

/// RGB or RGBA channels; alpha is kept separately from the RGB values.
class SemiChannels {
  const SemiChannels(this.red, this.green, this.blue, this.alpha);
  final int red, green, blue;
  final double alpha;
  Color toColor([double? opacity]) =>
      Color.fromRGBO(red, green, blue, opacity ?? alpha);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiChannels &&
          red == other.red &&
          green == other.green &&
          blue == other.blue &&
          alpha == other.alpha;
  @override
  int get hashCode => Object.hashAll([red, green, blue, alpha]);
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiLength &&
          value == other.value &&
          isPercent == other.isPercent;
  @override
  int get hashCode => Object.hashAll([value, isPercent]);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiGradient &&
          degrees == other.degrees &&
          listEquals(colors, other.colors) &&
          listEquals(stops, other.stops);
  @override
  int get hashCode =>
      Object.hashAll([degrees, Object.hashAll(colors), Object.hashAll(stops)]);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiShadowLayer &&
          inset == other.inset &&
          x == other.x &&
          y == other.y &&
          blur == other.blur &&
          spread == other.spread &&
          color == other.color;
  @override
  int get hashCode => Object.hashAll([inset, x, y, blur, spread, color]);
}

class SemiShadows {
  SemiShadows(List<SemiShadowLayer> layers)
    : layers = List.unmodifiable(layers);
  final List<SemiShadowLayer> layers;

  /// Refuses inset rather than silently dropping it.
  List<BoxShadow> toBoxShadows() =>
      layers.map((e) => e.toBoxShadow()).toList(growable: false);

  /// Explicit drop-only conversion: skips inset layers *on purpose* — they
  /// are rendered by the dedicated painter (SemiInsetShadow, the "dedicated
  /// painter" [toBoxShadow] points at), not silently lost.
  List<BoxShadow> toDropBoxShadows() => [
    for (final e in layers)
      if (!e.inset) e.toBoxShadow(),
  ];
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiShadows && listEquals(layers, other.layers);
  @override
  int get hashCode => Object.hashAll([Object.hashAll(layers)]);
}

/// Restricted upstream scale/rotation model, not a CSS transform interpreter.
class SemiTransform {
  const SemiTransform.scale(this.scaleX, this.scaleY) : degrees = 0;
  const SemiTransform.rotate(this.degrees) : scaleX = 1, scaleY = 1;
  final double scaleX, scaleY, degrees;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiTransform &&
          scaleX == other.scaleX &&
          scaleY == other.scaleY &&
          degrees == other.degrees;
  @override
  int get hashCode => Object.hashAll([scaleX, scaleY, degrees]);
}

/// Cubic curves compare their control points; other Curve implementations use
/// their own equality contract (custom curves should implement value equality).
/// Nullability matches nullable theme patch fields (null == null is true).
bool semiCurveEquals(Curve? a, Curve? b) =>
    a == b ||
    a is Cubic &&
        b is Cubic &&
        a.a == b.a &&
        a.b == b.b &&
        a.c == b.c &&
        a.d == b.d;
int semiCurveHash(Curve? curve) => curve == null
    ? 0
    : curve is Cubic
    ? Object.hash(curve.a, curve.b, curve.c, curve.d)
    : curve.hashCode;
