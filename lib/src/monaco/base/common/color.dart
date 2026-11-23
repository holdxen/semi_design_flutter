/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 port of vs/base/common/color.ts
//
// PORT NOTES (JS number semantics without changing the algorithms):
// - `x | 0` truncates toward zero to int32 → `_trunc` (clamped inputs are small positives).
// - `>>> 0` unsigned → `& 0xFFFFFFFF`.
// - `toFixed(2)` / `toFixed(2)` string → `_toFixed`.
// - JS `+x.toFixed(2)` strips trailing zeros → `_fixedNum`.
// - JS `parseInt`/`parseFloat` (regex groups guaranteed numeric) → int.parse/double.parse.

import 'dart:math' as math;
import 'package:semi_design_flutter/src/monaco/base/common/charCode.dart';

double roundFloat(double number, int decimalPoints) {
  final double decimal = math.pow(10, decimalPoints).toDouble();
  return (number * decimal).round() / decimal;
}

String _toFixed(num value, int digits) => value.toStringAsFixed(digits);

/// JS `+num.toFixed(2)`: fixed with trailing zeros removed, rendered as a JS number string.
String _fixedNum(num value) {
  final String s = value.toStringAsFixed(2);
  if (!s.contains('.')) return s;
  final String trimmed = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return trimmed;
}

/// 1:1: `export class RGBA`
class RGBA {
  final int r;
  final int g;
  final int b;
  final double a;

  RGBA(num r, num g, num b, [num a = 1])
      : r = math.min(255, math.max(0, r)).toInt(),
        g = math.min(255, math.max(0, g)).toInt(),
        b = math.min(255, math.max(0, b)).toInt(),
        a = roundFloat(math.max(math.min(1, a.toDouble()), 0), 3);

  static bool equals(RGBA a, RGBA b) => a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

/// 1:1: `export class HSLA`
class HSLA {
  final int h;
  final double s;
  final double l;
  final double a;

  HSLA(num h, num s, num l, num a)
      : h = math.max(math.min(360, h), 0).toInt(),
        s = roundFloat(math.max(math.min(1, s.toDouble()), 0), 3),
        l = roundFloat(math.max(math.min(1, l.toDouble()), 0), 3),
        a = roundFloat(math.max(math.min(1, a.toDouble()), 0), 3);

  static bool equals(HSLA a, HSLA b) => a.h == b.h && a.s == b.s && a.l == b.l && a.a == b.a;

  static HSLA fromRGBA(RGBA rgba) {
    final double r = rgba.r / 255;
    final double g = rgba.g / 255;
    final double b = rgba.b / 255;
    final double a = rgba.a;

    final double max = math.max(r, math.max(g, b));
    final double min = math.min(r, math.min(g, b));
    double h = 0;
    double s = 0;
    final double l = (min + max) / 2;
    final double chroma = max - min;

    if (chroma > 0) {
      s = math.min(l <= 0.5 ? chroma / (2 * l) : chroma / (2 - (2 * l)), 1);

      if (max == r) {
        h = (g - b) / chroma + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / chroma + 2;
      } else if (max == b) {
        h = (r - g) / chroma + 4;
      }

      h *= 60;
      h = h.roundToDouble();
    }
    return HSLA(h, s, l, a);
  }

  static double _hue2rgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  static RGBA toRGBA(HSLA hsla) {
    final double h = hsla.h / 360;
    final double s = hsla.s;
    final double l = hsla.l;
    final double a = hsla.a;
    late final double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      final double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final double p = 2 * l - q;
      r = _hue2rgb(p, q, h + 1 / 3);
      g = _hue2rgb(p, q, h);
      b = _hue2rgb(p, q, h - 1 / 3);
    }

    return RGBA((r * 255).round(), (g * 255).round(), (b * 255).round(), a);
  }
}

/// 1:1: `export class HSVA`
class HSVA {
  final int h;
  final double s;
  final double v;
  final double a;

  HSVA(num h, num s, num v, num a)
      : h = math.max(math.min(360, h), 0).toInt(),
        s = roundFloat(math.max(math.min(1, s.toDouble()), 0), 3),
        v = roundFloat(math.max(math.min(1, v.toDouble()), 0), 3),
        a = roundFloat(math.max(math.min(1, a.toDouble()), 0), 3);

  static bool equals(HSVA a, HSVA b) => a.h == b.h && a.s == b.s && a.v == b.v && a.a == b.a;

  static HSVA fromRGBA(RGBA rgba) {
    final double r = rgba.r / 255;
    final double g = rgba.g / 255;
    final double b = rgba.b / 255;
    final double cmax = math.max(r, math.max(g, b));
    final double cmin = math.min(r, math.min(g, b));
    final double delta = cmax - cmin;
    final double s = cmax == 0 ? 0 : (delta / cmax);
    late final double m;

    if (delta == 0) {
      m = 0;
    } else if (cmax == r) {
      m = ((((g - b) / delta) % 6) + 6) % 6;
    } else if (cmax == g) {
      m = ((b - r) / delta) + 2;
    } else {
      m = ((r - g) / delta) + 4;
    }

    return HSVA((m * 60).round(), s, cmax, rgba.a);
  }

  static RGBA toRGBA(HSVA hsva) {
    final int h = hsva.h;
    final double s = hsva.s;
    final double v = hsva.v;
    final double a = hsva.a;
    final double c = v * s;
    final double x = c * (1 - (((h / 60) % 2) - 1).abs());
    final double m = v - c;
    double r = 0, g = 0, b = 0;

    if (h < 60) {
      r = c; g = x;
    } else if (h < 120) {
      r = x; g = c;
    } else if (h < 180) {
      g = c; b = x;
    } else if (h < 240) {
      g = x; b = c;
    } else if (h < 300) {
      r = x; b = c;
    } else if (h <= 360) {
      r = c; b = x;
    }

    r = ((r + m) * 255).roundToDouble();
    g = ((g + m) * 255).roundToDouble();
    b = ((b + m) * 255).roundToDouble();

    return RGBA(r, g, b, a);
  }
}

/// 1:1: `export class Color`
class Color {
  static Color fromHex(String hex) => ColorFormatCSS.parseHex(hex) ?? Color.red;

  static bool equalsStatic(Color? a, Color? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.equals(b);
  }

  late final RGBA rgba;
  HSLA? _hsla;
  HSLA get hsla => _hsla ?? HSLA.fromRGBA(rgba);
  HSVA? _hsva;
  HSVA get hsva => _hsva ?? HSVA.fromRGBA(rgba);

  Color(Object arg) {
    if (arg is RGBA) {
      rgba = arg;
    } else if (arg is HSLA) {
      _hsla = arg;
      rgba = HSLA.toRGBA(arg);
    } else if (arg is HSVA) {
      _hsva = arg;
      rgba = HSVA.toRGBA(arg);
    } else {
      throw ArgumentError('Invalid color ctor argument');
    }
  }

  bool equals(Color? other) => other != null && RGBA.equals(rgba, other.rgba) && HSLA.equals(hsla, other.hsla) && HSVA.equals(hsva, other.hsva);

  double getRelativeLuminance() {
    final double R = _relativeLuminanceForComponent(rgba.r);
    final double G = _relativeLuminanceForComponent(rgba.g);
    final double B = _relativeLuminanceForComponent(rgba.b);
    final double luminance = 0.2126 * R + 0.7152 * G + 0.0722 * B;
    return roundFloat(luminance, 4);
  }

  Color reduceRelativeLuminace(Color foreground, double ratio) {
    int fgR = foreground.rgba.r, fgG = foreground.rgba.g, fgB = foreground.rgba.b;
    double cr = getContrastRatio(foreground);
    while (cr < ratio && (fgR > 0 || fgG > 0 || fgB > 0)) {
      fgR -= math.max(0, (fgR * 0.1).ceil());
      fgG -= math.max(0, (fgG * 0.1).ceil());
      fgB -= math.max(0, (fgB * 0.1).ceil());
      cr = getContrastRatio(Color(RGBA(fgR, fgG, fgB)));
    }
    return Color(RGBA(fgR, fgG, fgB));
  }

  Color increaseRelativeLuminace(Color foreground, double ratio) {
    int fgR = foreground.rgba.r, fgG = foreground.rgba.g, fgB = foreground.rgba.b;
    double cr = getContrastRatio(foreground);
    while (cr < ratio && (fgR < 0xFF || fgG < 0xFF || fgB < 0xFF)) {
      fgR = math.min(0xFF, fgR + ((255 - fgR) * 0.1).ceil());
      fgG = math.min(0xFF, fgG + ((255 - fgG) * 0.1).ceil());
      fgB = math.min(0xFF, fgB + ((255 - fgB) * 0.1).ceil());
      cr = getContrastRatio(Color(RGBA(fgR, fgG, fgB)));
    }
    return Color(RGBA(fgR, fgG, fgB));
  }

  static double _relativeLuminanceForComponent(num color) {
    final double c = color / 255;
    return (c <= 0.03928) ? c / 12.92 : math.pow(((c + 0.055) / 1.055), 2.4).toDouble();
  }

  double getContrastRatio(Color another) {
    final double lum1 = getRelativeLuminance();
    final double lum2 = another.getRelativeLuminance();
    return lum1 > lum2 ? (lum1 + 0.05) / (lum2 + 0.05) : (lum2 + 0.05) / (lum1 + 0.05);
  }

  bool isDarker() => (rgba.r * 299 + rgba.g * 587 + rgba.b * 114) / 1000 < 128;
  bool isLighter() => (rgba.r * 299 + rgba.g * 587 + rgba.b * 114) / 1000 >= 128;
  bool isLighterThan(Color another) => getRelativeLuminance() > another.getRelativeLuminance();
  bool isDarkerThan(Color another) => getRelativeLuminance() < another.getRelativeLuminance();

  Color ensureConstrast(Color foreground, double ratio) {
    final double bgL = getRelativeLuminance();
    final double fgL = foreground.getRelativeLuminance();
    final double cr = getContrastRatio(foreground);
    if (cr < ratio) {
      if (fgL < bgL) {
        final Color resultA = reduceRelativeLuminace(foreground, ratio);
        final double resultARatio = getContrastRatio(resultA);
        if (resultARatio < ratio) {
          final Color resultB = increaseRelativeLuminace(foreground, ratio);
          final double resultBRatio = getContrastRatio(resultB);
          return resultARatio > resultBRatio ? resultA : resultB;
        }
        return resultA;
      }
      final Color resultA = increaseRelativeLuminace(foreground, ratio);
      final double resultARatio = getContrastRatio(resultA);
      if (resultARatio < ratio) {
        final Color resultB = reduceRelativeLuminace(foreground, ratio);
        final double resultBRatio = getContrastRatio(resultB);
        return resultARatio > resultBRatio ? resultA : resultB;
      }
      return resultA;
    }
    return foreground;
  }

  Color lighten(num factor) => Color(HSLA(hsla.h, hsla.s, hsla.l + hsla.l * factor, hsla.a));
  Color darken(num factor) => Color(HSLA(hsla.h, hsla.s, hsla.l - hsla.l * factor, hsla.a));
  Color transparent(num factor) => Color(RGBA(rgba.r, rgba.g, rgba.b, rgba.a * factor));
  bool isTransparent() => rgba.a == 0;
  bool isOpaque() => rgba.a == 1;
  Color opposite() => Color(RGBA(255 - rgba.r, 255 - rgba.g, 255 - rgba.b, rgba.a));

  Color blend(Color c) {
    final RGBA rgba = c.rgba;
    final double thisA = this.rgba.a;
    final double colorA = rgba.a;
    final double a = thisA + colorA * (1 - thisA);
    if (a < 1e-6) return Color.transparentColor;
    final double r = this.rgba.r * thisA / a + rgba.r * colorA * (1 - thisA) / a;
    final double g = this.rgba.g * thisA / a + rgba.g * colorA * (1 - thisA) / a;
    final double b = this.rgba.b * thisA / a + rgba.b * colorA * (1 - thisA) / a;
    return Color(RGBA(r, g, b, a));
  }

  Color mix(Color color, [num factor = 0.5]) {
    final double normalize = math.min(math.max(factor.toDouble(), 0), 1);
    final RGBA thisRGBA = this.rgba;
    final RGBA otherRGBA = color.rgba;
    final double r = thisRGBA.r + (otherRGBA.r - thisRGBA.r) * normalize;
    final double g = thisRGBA.g + (otherRGBA.g - thisRGBA.g) * normalize;
    final double b = thisRGBA.b + (otherRGBA.b - thisRGBA.b) * normalize;
    final double a = thisRGBA.a + (otherRGBA.a - thisRGBA.a) * normalize;
    return Color(RGBA(r, g, b, a));
  }

  Color makeOpaque(Color opaqueBackground) {
    if (isOpaque() || opaqueBackground.rgba.a != 1) return this;
    final int r = rgba.r, g = rgba.g, b = rgba.b;
    final double a = rgba.a;
    return Color(RGBA(
      opaqueBackground.rgba.r - a * (opaqueBackground.rgba.r - r),
      opaqueBackground.rgba.g - a * (opaqueBackground.rgba.g - g),
      opaqueBackground.rgba.b - a * (opaqueBackground.rgba.b - b),
      1,
    ));
  }

  Color flatten(List<Color> backgrounds) {
    Color background = backgrounds.last;
    for (int i = backgrounds.length - 2; i >= 0; i--) {
      background = _flatten(backgrounds[i], background);
    }
    return _flatten(this, background);
  }

  static Color _flatten(Color foreground, Color background) {
    final double backgroundAlpha = 1 - foreground.rgba.a;
    return Color(RGBA(
      backgroundAlpha * background.rgba.r + foreground.rgba.a * foreground.rgba.r,
      backgroundAlpha * background.rgba.g + foreground.rgba.a * foreground.rgba.g,
      backgroundAlpha * background.rgba.b + foreground.rgba.a * foreground.rgba.b,
    ));
  }

  String? _toString;
  @override
  String toString() => _toString ??= ColorFormatCSS.format(this);

  int? _toNumber32Bit;
  int toNumber32Bit() => _toNumber32Bit ??= ((rgba.r << 24) | (rgba.g << 16) | (rgba.b << 8) | ((rgba.a * 0xFF).toInt() << 0)) & 0xFFFFFFFF;

  static Color getLighterColor(Color of, Color relative, [num? factor]) {
    if (of.isLighterThan(relative)) return of;
    factor = factor != null && factor != 0 ? factor : 0.5;
    final double lum1 = of.getRelativeLuminance();
    final double lum2 = relative.getRelativeLuminance();
    factor = factor * (lum2 - lum1) / lum2;
    return of.lighten(factor);
  }

  static Color getDarkerColor(Color of, Color relative, [num? factor]) {
    if (of.isDarkerThan(relative)) return of;
    factor = factor != null && factor != 0 ? factor : 0.5;
    final double lum1 = of.getRelativeLuminance();
    final double lum2 = relative.getRelativeLuminance();
    factor = factor * (lum1 - lum2) / lum1;
    return of.darken(factor);
  }

  static final Color white = Color(RGBA(255, 255, 255, 1));
  static final Color black = Color(RGBA(0, 0, 0, 1));
  static final Color red = Color(RGBA(255, 0, 0, 1));
  static final Color blue = Color(RGBA(0, 0, 255, 1));
  static final Color green = Color(RGBA(0, 255, 0, 1));
  static final Color cyan = Color(RGBA(0, 255, 255, 1));
  static final Color lightgrey = Color(RGBA(211, 211, 211, 1));
  static final Color transparentColor = Color(RGBA(0, 0, 0, 0));
}

/// 1:1: `namespace Color.Format.CSS` — flat carrier class preserving all members.
class ColorFormatCSS {
  static String formatRGB(Color color) {
    if (color.rgba.a == 1) return 'rgb(${color.rgba.r}, ${color.rgba.g}, ${color.rgba.b})';
    return formatRGBA(color);
  }

  static String formatRGBA(Color color) => 'rgba(${color.rgba.r}, ${color.rgba.g}, ${color.rgba.b}, ${_fixedNum(color.rgba.a)})';

  static String formatHSL(Color color) {
    if (color.hsla.a == 1) return 'hsl(${color.hsla.h}, ${(color.hsla.s * 100).round()}%, ${(color.hsla.l * 100).round()}%)';
    return formatHSLA(color);
  }

  static String formatHSLA(Color color) => 'hsla(${color.hsla.h}, ${(color.hsla.s * 100).round()}%, ${(color.hsla.l * 100).round()}%, ${_toFixed(color.hsla.a, 2)})';

  static String _toTwoDigitHex(int n) {
    final String r = n.toRadixString(16);
    return r.length != 2 ? '0' + r : r;
  }

  static String formatHex(Color color) => '#${_toTwoDigitHex(color.rgba.r)}${_toTwoDigitHex(color.rgba.g)}${_toTwoDigitHex(color.rgba.b)}';

  static String formatHexA(Color color, [bool compact = false]) {
    if (compact && color.rgba.a == 1) return formatHex(color);
    return '#${_toTwoDigitHex(color.rgba.r)}${_toTwoDigitHex(color.rgba.g)}${_toTwoDigitHex(color.rgba.b)}${_toTwoDigitHex((color.rgba.a * 255).round())}';
  }

  static String format(Color color) {
    if (color.isOpaque()) return formatHex(color);
    return formatRGBA(color);
  }

  static Color? parse(String css) {
    if (css == 'transparent') return Color.transparentColor;
    if (css.startsWith('#')) return parseHex(css);
    if (css.startsWith('rgba(')) {
      final RegExpMatch? color = RegExp(r'^rgba\(([+-]?\d+), *([+-]?\d+), *([+-]?\d+), *([+-]?\d+(\.\d+)?)\)$').firstMatch(css);
      if (color == null) throw ArgumentError('Invalid color format $css');
      final int r = int.parse(color.group(1)!);
      final int g = int.parse(color.group(2)!);
      final int b = int.parse(color.group(3)!);
      final double a = double.parse(color.group(4)!);
      return Color(RGBA(r, g, b, a));
    }
    if (css.startsWith('rgb(')) {
      final RegExpMatch? color = RegExp(r'^rgb\(([+-]?\d+), *([+-]?\d+), *([+-]?\d+)\)$').firstMatch(css);
      if (color == null) throw ArgumentError('Invalid color format $css');
      final int r = int.parse(color.group(1)!);
      final int g = int.parse(color.group(2)!);
      final int b = int.parse(color.group(3)!);
      return Color(RGBA(r, g, b));
    }
    return _parseNamedKeyword(css);
  }

  static Color? _parseNamedKeyword(String css) {
    switch (css) {
      case 'aliceblue': return Color(RGBA(240, 248, 255, 1));
      case 'antiquewhite': return Color(RGBA(250, 235, 215, 1));
      case 'aqua': return Color(RGBA(0, 255, 255, 1));
      case 'aquamarine': return Color(RGBA(127, 255, 212, 1));
      case 'azure': return Color(RGBA(240, 255, 255, 1));
      case 'beige': return Color(RGBA(245, 245, 220, 1));
      case 'bisque': return Color(RGBA(255, 228, 196, 1));
      case 'black': return Color(RGBA(0, 0, 0, 1));
      case 'blanchedalmond': return Color(RGBA(255, 235, 205, 1));
      case 'blue': return Color(RGBA(0, 0, 255, 1));
      case 'blueviolet': return Color(RGBA(138, 43, 226, 1));
      case 'brown': return Color(RGBA(165, 42, 42, 1));
      case 'burlywood': return Color(RGBA(222, 184, 135, 1));
      case 'cadetblue': return Color(RGBA(95, 158, 160, 1));
      case 'chartreuse': return Color(RGBA(127, 255, 0, 1));
      case 'chocolate': return Color(RGBA(210, 105, 30, 1));
      case 'coral': return Color(RGBA(255, 127, 80, 1));
      case 'cornflowerblue': return Color(RGBA(100, 149, 237, 1));
      case 'cornsilk': return Color(RGBA(255, 248, 220, 1));
      case 'crimson': return Color(RGBA(220, 20, 60, 1));
      case 'cyan': return Color(RGBA(0, 255, 255, 1));
      case 'darkblue': return Color(RGBA(0, 0, 139, 1));
      case 'darkcyan': return Color(RGBA(0, 139, 139, 1));
      case 'darkgoldenrod': return Color(RGBA(184, 134, 11, 1));
      case 'darkgray': return Color(RGBA(169, 169, 169, 1));
      case 'darkgreen': return Color(RGBA(0, 100, 0, 1));
      case 'darkgrey': return Color(RGBA(169, 169, 169, 1));
      case 'darkkhaki': return Color(RGBA(189, 183, 107, 1));
      case 'darkmagenta': return Color(RGBA(139, 0, 139, 1));
      case 'darkolivegreen': return Color(RGBA(85, 107, 47, 1));
      case 'darkorange': return Color(RGBA(255, 140, 0, 1));
      case 'darkorchid': return Color(RGBA(153, 50, 204, 1));
      case 'darkred': return Color(RGBA(139, 0, 0, 1));
      case 'darksalmon': return Color(RGBA(233, 150, 122, 1));
      case 'darkseagreen': return Color(RGBA(143, 188, 143, 1));
      case 'darkslateblue': return Color(RGBA(72, 61, 139, 1));
      case 'darkslategray': return Color(RGBA(47, 79, 79, 1));
      case 'darkslategrey': return Color(RGBA(47, 79, 79, 1));
      case 'darkturquoise': return Color(RGBA(0, 206, 209, 1));
      case 'darkviolet': return Color(RGBA(148, 0, 211, 1));
      case 'deeppink': return Color(RGBA(255, 20, 147, 1));
      case 'deepskyblue': return Color(RGBA(0, 191, 255, 1));
      case 'dimgray': return Color(RGBA(105, 105, 105, 1));
      case 'dimgrey': return Color(RGBA(105, 105, 105, 1));
      case 'dodgerblue': return Color(RGBA(30, 144, 255, 1));
      case 'firebrick': return Color(RGBA(178, 34, 34, 1));
      case 'floralwhite': return Color(RGBA(255, 250, 240, 1));
      case 'forestgreen': return Color(RGBA(34, 139, 34, 1));
      case 'fuchsia': return Color(RGBA(255, 0, 255, 1));
      case 'gainsboro': return Color(RGBA(220, 220, 220, 1));
      case 'ghostwhite': return Color(RGBA(248, 248, 255, 1));
      case 'gold': return Color(RGBA(255, 215, 0, 1));
      case 'goldenrod': return Color(RGBA(218, 165, 32, 1));
      case 'gray': return Color(RGBA(128, 128, 128, 1));
      case 'green': return Color(RGBA(0, 128, 0, 1));
      case 'greenyellow': return Color(RGBA(173, 255, 47, 1));
      case 'grey': return Color(RGBA(128, 128, 128, 1));
      case 'honeydew': return Color(RGBA(240, 255, 240, 1));
      case 'hotpink': return Color(RGBA(255, 105, 180, 1));
      case 'indianred': return Color(RGBA(205, 92, 92, 1));
      case 'indigo': return Color(RGBA(75, 0, 130, 1));
      case 'ivory': return Color(RGBA(255, 255, 240, 1));
      case 'khaki': return Color(RGBA(240, 230, 140, 1));
      case 'lavender': return Color(RGBA(230, 230, 250, 1));
      case 'lavenderblush': return Color(RGBA(255, 240, 245, 1));
      case 'lawngreen': return Color(RGBA(124, 252, 0, 1));
      case 'lemonchiffon': return Color(RGBA(255, 250, 205, 1));
      case 'lightblue': return Color(RGBA(173, 216, 230, 1));
      case 'lightcoral': return Color(RGBA(240, 128, 128, 1));
      case 'lightcyan': return Color(RGBA(224, 255, 255, 1));
      case 'lightgoldenrodyellow': return Color(RGBA(250, 250, 210, 1));
      case 'lightgray': return Color(RGBA(211, 211, 211, 1));
      case 'lightgreen': return Color(RGBA(144, 238, 144, 1));
      case 'lightgrey': return Color(RGBA(211, 211, 211, 1));
      case 'lightpink': return Color(RGBA(255, 182, 193, 1));
      case 'lightsalmon': return Color(RGBA(255, 160, 122, 1));
      case 'lightseagreen': return Color(RGBA(32, 178, 170, 1));
      case 'lightskyblue': return Color(RGBA(135, 206, 250, 1));
      case 'lightslategray': return Color(RGBA(119, 136, 153, 1));
      case 'lightslategrey': return Color(RGBA(119, 136, 153, 1));
      case 'lightsteelblue': return Color(RGBA(176, 196, 222, 1));
      case 'lightyellow': return Color(RGBA(255, 255, 224, 1));
      case 'lime': return Color(RGBA(0, 255, 0, 1));
      case 'limegreen': return Color(RGBA(50, 205, 50, 1));
      case 'linen': return Color(RGBA(250, 240, 230, 1));
      case 'magenta': return Color(RGBA(255, 0, 255, 1));
      case 'maroon': return Color(RGBA(128, 0, 0, 1));
      case 'mediumaquamarine': return Color(RGBA(102, 205, 170, 1));
      case 'mediumblue': return Color(RGBA(0, 0, 205, 1));
      case 'mediumorchid': return Color(RGBA(186, 85, 211, 1));
      case 'mediumpurple': return Color(RGBA(147, 112, 219, 1));
      case 'mediumseagreen': return Color(RGBA(60, 179, 113, 1));
      case 'mediumslateblue': return Color(RGBA(123, 104, 238, 1));
      case 'mediumspringgreen': return Color(RGBA(0, 250, 154, 1));
      case 'mediumturquoise': return Color(RGBA(72, 209, 204, 1));
      case 'mediumvioletred': return Color(RGBA(199, 21, 133, 1));
      case 'midnightblue': return Color(RGBA(25, 25, 112, 1));
      case 'mintcream': return Color(RGBA(245, 255, 250, 1));
      case 'mistyrose': return Color(RGBA(255, 228, 225, 1));
      case 'moccasin': return Color(RGBA(255, 228, 181, 1));
      case 'navajowhite': return Color(RGBA(255, 222, 173, 1));
      case 'navy': return Color(RGBA(0, 0, 128, 1));
      case 'oldlace': return Color(RGBA(253, 245, 230, 1));
      case 'olive': return Color(RGBA(128, 128, 0, 1));
      case 'olivedrab': return Color(RGBA(107, 142, 35, 1));
      case 'orange': return Color(RGBA(255, 165, 0, 1));
      case 'orangered': return Color(RGBA(255, 69, 0, 1));
      case 'orchid': return Color(RGBA(218, 112, 214, 1));
      case 'palegoldenrod': return Color(RGBA(238, 232, 170, 1));
      case 'palegreen': return Color(RGBA(152, 251, 152, 1));
      case 'paleturquoise': return Color(RGBA(175, 238, 238, 1));
      case 'palevioletred': return Color(RGBA(219, 112, 147, 1));
      case 'papayawhip': return Color(RGBA(255, 239, 213, 1));
      case 'peachpuff': return Color(RGBA(255, 218, 185, 1));
      case 'peru': return Color(RGBA(205, 133, 63, 1));
      case 'pink': return Color(RGBA(255, 192, 203, 1));
      case 'plum': return Color(RGBA(221, 160, 221, 1));
      case 'powderblue': return Color(RGBA(176, 224, 230, 1));
      case 'purple': return Color(RGBA(128, 0, 128, 1));
      case 'rebeccapurple': return Color(RGBA(102, 51, 153, 1));
      case 'red': return Color(RGBA(255, 0, 0, 1));
      case 'rosybrown': return Color(RGBA(188, 143, 143, 1));
      case 'royalblue': return Color(RGBA(65, 105, 225, 1));
      case 'saddlebrown': return Color(RGBA(139, 69, 19, 1));
      case 'salmon': return Color(RGBA(250, 128, 114, 1));
      case 'sandybrown': return Color(RGBA(244, 164, 96, 1));
      case 'seagreen': return Color(RGBA(46, 139, 87, 1));
      case 'seashell': return Color(RGBA(255, 245, 238, 1));
      case 'sienna': return Color(RGBA(160, 82, 45, 1));
      case 'silver': return Color(RGBA(192, 192, 192, 1));
      case 'skyblue': return Color(RGBA(135, 206, 235, 1));
      case 'slateblue': return Color(RGBA(106, 90, 205, 1));
      case 'slategray': return Color(RGBA(112, 128, 144, 1));
      case 'slategrey': return Color(RGBA(112, 128, 144, 1));
      case 'snow': return Color(RGBA(255, 250, 250, 1));
      case 'springgreen': return Color(RGBA(0, 255, 127, 1));
      case 'steelblue': return Color(RGBA(70, 130, 180, 1));
      case 'tan': return Color(RGBA(210, 180, 140, 1));
      case 'teal': return Color(RGBA(0, 128, 128, 1));
      case 'thistle': return Color(RGBA(216, 191, 216, 1));
      case 'tomato': return Color(RGBA(255, 99, 71, 1));
      case 'turquoise': return Color(RGBA(64, 224, 208, 1));
      case 'violet': return Color(RGBA(238, 130, 238, 1));
      case 'wheat': return Color(RGBA(245, 222, 179, 1));
      case 'white': return Color(RGBA(255, 255, 255, 1));
      case 'whitesmoke': return Color(RGBA(245, 245, 245, 1));
      case 'yellow': return Color(RGBA(255, 255, 0, 1));
      case 'yellowgreen': return Color(RGBA(154, 205, 50, 1));
      default: return null;
    }
  }

  static Color? parseHex(String hex) {
    final int length = hex.length;
    if (length == 0) return null;
    if (hex.codeUnitAt(0) != CharCode.Hash) return null;

    if (length == 7) {
      final int r = 16 * _parseHexDigit(hex.codeUnitAt(1)) + _parseHexDigit(hex.codeUnitAt(2));
      final int g = 16 * _parseHexDigit(hex.codeUnitAt(3)) + _parseHexDigit(hex.codeUnitAt(4));
      final int b = 16 * _parseHexDigit(hex.codeUnitAt(5)) + _parseHexDigit(hex.codeUnitAt(6));
      return Color(RGBA(r, g, b, 1));
    }
    if (length == 9) {
      final int r = 16 * _parseHexDigit(hex.codeUnitAt(1)) + _parseHexDigit(hex.codeUnitAt(2));
      final int g = 16 * _parseHexDigit(hex.codeUnitAt(3)) + _parseHexDigit(hex.codeUnitAt(4));
      final int b = 16 * _parseHexDigit(hex.codeUnitAt(5)) + _parseHexDigit(hex.codeUnitAt(6));
      final int a = 16 * _parseHexDigit(hex.codeUnitAt(7)) + _parseHexDigit(hex.codeUnitAt(8));
      return Color(RGBA(r, g, b, a / 255));
    }
    if (length == 4) {
      final int r = _parseHexDigit(hex.codeUnitAt(1));
      final int g = _parseHexDigit(hex.codeUnitAt(2));
      final int b = _parseHexDigit(hex.codeUnitAt(3));
      return Color(RGBA(16 * r + r, 16 * g + g, 16 * b + b));
    }
    if (length == 5) {
      final int r = _parseHexDigit(hex.codeUnitAt(1));
      final int g = _parseHexDigit(hex.codeUnitAt(2));
      final int b = _parseHexDigit(hex.codeUnitAt(3));
      final int a = _parseHexDigit(hex.codeUnitAt(4));
      return Color(RGBA(16 * r + r, 16 * g + g, 16 * b + b, (16 * a + a) / 255));
    }
    return null;
  }

  static int _parseHexDigit(int charCode) {
    switch (charCode) {
      case CharCode.Digit0: return 0;
      case CharCode.Digit1: return 1;
      case CharCode.Digit2: return 2;
      case CharCode.Digit3: return 3;
      case CharCode.Digit4: return 4;
      case CharCode.Digit5: return 5;
      case CharCode.Digit6: return 6;
      case CharCode.Digit7: return 7;
      case CharCode.Digit8: return 8;
      case CharCode.Digit9: return 9;
      case CharCode.a: return 10;
      case CharCode.A: return 10;
      case CharCode.b: return 11;
      case CharCode.B: return 11;
      case CharCode.c: return 12;
      case CharCode.C: return 12;
      case CharCode.d: return 13;
      case CharCode.D: return 13;
      case CharCode.e: return 14;
      case CharCode.E: return 14;
      case CharCode.f: return 15;
      case CharCode.F: return 15;
    }
    return 0;
  }
}
