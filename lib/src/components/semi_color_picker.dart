// SemiColorPicker — full-component port of React Semi Design's ColorPicker.
//
// Theme accounting (tool/generate_color_picker.py): the 20 declarations of
// packages/semi-foundation/colorPicker/variables.scss land as 20 theme fields
// (20 = 20 FIELDS + 0 MOTION + 0 INTERNAL — the module has no animation.scss
// and zero dead variables). The 另列 HARDCODES (SV double-gradient overlay,
// inset shadow, alpha checkerboard, hue rainbow, slider/handle sizes, 20x20
// demo block, `%` suffix, `rgbaToHex` lowercase, 2px handle border, the
// shadow-elevated pair on the usePopover surface) live in
// `_ColorPickerMetrics` / the call sites below, each with its raw snippet.
//
// Port notes (docs/semi_color_picker.md holds the full difference list):
// * `value`/`defaultValue` are `SemiColorValue?`; a non-null `value` is
//   controlled (project convention — ★upstream gates on truthiness instead,
//   foundation.ts `if (!this.getProp('value'))`).
// * ★No keyboard support upstream beyond the SemiInput/SemiSelect/
//   SemiInputNumber natives; ★no RTL (slider math is LTR-only, upstream has
//   no rtl.scss for colorPicker); no Form integration.
// * `className`/`style`/`inputProps`/`popoverProps` granularity is not
//   ported (差异清单); `position`/`autoAdjustOverflow`/`motion` surface as
//   direct widget parameters instead.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_color_picker_theme.dart';
import '../theme/semi_color_picker_theme_data.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_input.dart';
import 'semi_input_number.dart';
import 'semi_select.dart';
import 'semi_tooltip.dart';

/// Upstream `defaultFormat` union (DataPart format Select values — exactly
/// `hex|rgba|hsva`, labels equal values).
enum SemiColorFormat { hex, rgba, hsva }

/// JS `Number(...)` semantics for regex captures: `'' -> 0`, `.5 -> 0.5`,
/// `-.5 -> -0.5`, `5. -> 5`, garbage -> NaN (rejected by the callers' checks).
double _jsNum(String text) {
  if (text.isEmpty) return 0;
  var t = text;
  if (t.startsWith('-.')) {
    t = '-0${t.substring(1)}';
  } else if (t.startsWith('.')) {
    t = '0$t';
  }
  if (t.endsWith('.')) t = t.substring(0, t.length - 1);
  return double.tryParse(t) ?? double.nan;
}

/// utils/round.ts — `Math.round(base * number) / base`. JS `Math.round` is
/// `floor(x + 0.5)` (half towards +Infinity), NOT Dart's half-away-from-zero.
double _round(num number, [int digits = 0]) {
  final base = math.pow(10, digits).toDouble();
  return ((base * number) + 0.5).floorToDouble() / base;
}

/// JS `${number}` for display strings (ints print without a `.0` tail).
String _jsFmt(double n) => n == n.roundToDouble() ? '${n.round()}' : '$n';

/// `String.prototype.padStart(2, '0')` over `number.toString(16)` —
/// convert.ts `format()` (integer channels, lowercase).
String _formatHex(num number) {
  final hex = number.toInt().toRadixString(16);
  return hex.length < 2 ? '0$hex' : hex;
}

/// convert.ts `percentToHex` — ★
/// `intValue.toString(16).padStart(2, '0').toLowerCase()`.
String _percentToHex(num p) {
  final intValue = _round(p / 100 * 255);
  return intValue.toInt().toRadixString(16).padLeft(2, '0').toLowerCase();
}

/// convert.ts `hexToPercent`: `parseInt(str, 16) / 255`, ★missing/garbage ->
/// 1 (the `!isNaN(decimal)` fallback).
double _hexToPercent(String str) {
  final decimal = int.tryParse(str, radix: 16);
  if (decimal != null) return decimal / 255;
  return 1;
}

/// convert.ts `hexToRgba` — ★LENIENT: no validation at all. 3-char shorthand
/// yields missing components (JS NaN — the port collapses them to 0, NaN
/// cannot traverse Dart's num pipeline; see docs) and a missing alpha is 1.
({double r, double g, double b, double a}) _hexToRgba(String hex) {
  var h = hex;
  if (h.startsWith('#')) h = h.substring(1);
  double component(int start, int end) {
    final raw = start < h.length
        ? h.substring(start, math.min(end, h.length))
        : '';
    // JS `parseInt(raw, 16)` — unparsable/empty is NaN upstream; 0 here.
    return (int.tryParse(raw, radix: 16) ?? 0).toDouble();
  }

  return (
    r: component(0, 2),
    g: component(2, 4),
    b: component(4, 6),
    a: _hexToPercent(h.length > 6 ? h.substring(6, 8) : ''),
  );
}

/// convert.ts `rgbaToHsva` — h/s/v rounded to integers (utils/round), `a`
/// passes through untouched.
({double h, double s, double v, double a}) _rgbaToHsva(
  double r,
  double g,
  double b,
  double a,
) {
  final max = math.max(r, math.max(g, b));
  final delta = max - math.min(r, math.min(g, b));
  final double hh;
  if (delta == 0) {
    hh = 0;
  } else if (max == r) {
    hh = (g - b) / delta;
  } else if (max == g) {
    hh = 2 + (b - r) / delta;
  } else {
    hh = 4 + (r - g) / delta;
  }
  return (
    h: _round(60 * (hh < 0 ? hh + 6 : hh)),
    s: _round(max != 0 ? (delta / max) * 100 : 0),
    v: _round((max / 255) * 100),
    a: a,
  );
}

/// convert.ts `hsvaToRgba` — the vanilla-colorful 6-sector form; r/g/b are
/// rounded integers and ★`a` is rounded to 2 decimals (`round(a, 2)`).
({double r, double g, double b, double a}) _hsvaToRgba(
  double h,
  double s,
  double v,
  double a,
) {
  final hue = (h / 360) * 6;
  final sat = s / 100;
  final val = v / 100;
  final hh = hue.floor();
  final b = val * (1 - sat);
  final c = val * (1 - (hue - hh) * sat);
  final d = val * (1 - (1 - hue + hh) * sat);
  final module = hh % 6;
  // [v, c, b, b, d, v] / [d, v, v, c, b, b] / [b, b, d, v, v, c]
  double pick(List<double> slot) => slot[module];
  return (
    r: _round(pick([val, c, b, b, d, val]) * 255),
    g: _round(pick([d, val, val, c, b, b]) * 255),
    b: _round(pick([b, b, d, val, val, c]) * 255),
    a: _round(a, 2),
  );
}

/// convert.ts `rgbaToHex` — ★`a === undefined || a === 1` renders the 6-digit
/// form, anything else appends `percentToHex(a * 100)` (lowercase).
String _rgbaToHex(double r, double g, double b, double a) {
  final rgb = _formatHex(r) + _formatHex(g) + _formatHex(b);
  if (a == 1) return '#$rgb';
  return '#$rgb${_percentToHex(a * 100)}';
}

/// convert.ts `hsvaToHex` = `rgbaToHex(hsvaToRgba(hsva))`.
String _hsvaToHex(double h, double s, double v, double a) {
  final rgba = _hsvaToRgba(h, s, v, a);
  return _rgbaToHex(rgba.r, rgba.g, rgba.b, rgba.a);
}

/// convert.ts `hsvaToHslString` — `hsl(${h}, ${s}%, ${l}%)` (the SV area
/// background and hue handle color string upstream; the port renders the
/// same color through [HSLColor] instead of the string).
// ignore: unused_element
String _hsvaToHslString(double h, double s, double v, double a) {
  final hsla = _hsvaToHsla(h, s, v, a);
  return 'hsl(${hsla.h}, ${hsla.s}%, ${hsla.l}%)';
}

/// convert.ts `hsvaToRgbaString` — `rgba(${r}, ${g}, ${b}, ${a})` (the alpha
/// handle color string upstream; the port renders the same color directly).
// ignore: unused_element
String _hsvaToRgbaString(double h, double s, double v, double a) {
  final rgba = _hsvaToRgba(h, s, v, a);
  return 'rgba(${rgba.r}, ${rgba.g}, ${rgba.b}, ${rgba.a})';
}

/// convert.ts `hsvaToHsla` (h/s/l rounded, `a` to 2 decimals).
({double h, double s, double l, double a}) _hsvaToHsla(
  double h,
  double s,
  double v,
  double a,
) {
  final hh = ((200 - s) * v) / 100;
  return (
    h: _round(h),
    s: _round(
      hh > 0 && hh < 200
          ? ((s * v) / 100 / (hh <= 100 ? hh : 200 - hh)) * 100
          : 0,
    ),
    l: _round(hh / 2),
    a: _round(a, 2),
  );
}

/// convert.ts `hslaToHsva` (no rounding — upstream parity; the inverse of
/// `_hsvaToHsla`, kept as part of the verbatim conversion surface).
// ignore: unused_element
({double h, double s, double v, double a}) _hslaToHsva(
  double h,
  double s,
  double l,
  double a,
) {
  final ss = s * (l < 50 ? l : 100 - l) / 100;
  return (h: h, s: ss > 0 ? ((2 * ss) / (l + ss)) * 100 : 0, v: l + ss, a: a);
}

/// Valid CSS `<angle>` units of convert.ts `parseHue`/`angleUnits`.
double _parseHue(String value, String? unit) {
  const angleUnits = <String, double>{
    'grad': 360 / 400,
    'turn': 360,
    'rad': 360 / (math.pi * 2),
  };
  return _jsNum(value) * (angleUnits[unit] ?? 1);
}

final RegExp _rgbaStringMatcher = RegExp(
  r'rgba?\(?\s*(-?\d*\.?\d+)(%)?[,\s]+(-?\d*\.?\d+)(%)?[,\s]+'
  r'(-?\d*\.?\d+)(%)?,?\s*[/\s]*(-?\d*\.?\d+)?(%)?\s*\)?',
  caseSensitive: false,
);

/// convert.ts `rgbaStringToRgba` — unanchored regex; ★no match -> the
/// zero-ish `{r: 0, g: 0, b: 0, a: 1}` default.
({double r, double g, double b, double a}) _rgbaStringToRgba(String text) {
  final match = _rgbaStringMatcher.firstMatch(text);
  if (match == null) return (r: 0, g: 0, b: 0, a: 1);
  return (
    r: _jsNum(match.group(1)!) / (match.group(2) != null ? 100 / 255 : 1),
    g: _jsNum(match.group(3)!) / (match.group(4) != null ? 100 / 255 : 1),
    b: _jsNum(match.group(5)!) / (match.group(6) != null ? 100 / 255 : 1),
    a: match.group(7) == null
        ? 1
        : _jsNum(match.group(7)!) / (match.group(8) != null ? 100 : 1),
  );
}

final RegExp _hsvaStringMatcher = RegExp(
  r'hsva?\(?\s*(-?\d*\.?\d+)(deg|rad|grad|turn)?[,\s]+(-?\d*\.?\d+)%?[,\s]+'
  r'(-?\d*\.?\d+)%?,?\s*[/\s]*(-?\d*\.?\d+)?(%)?\s*\)?',
  caseSensitive: false,
);

/// convert.ts `hsvaStringToHsva` — regex + `roundHsva` (h/s/v integers, `a`
/// 2 decimals); ★no match -> `{h: 0, s: 0, v: 0, a: 1}`.
({double h, double s, double v, double a}) _hsvaStringToHsva(String text) {
  final match = _hsvaStringMatcher.firstMatch(text);
  if (match == null) return (h: 0, s: 0, v: 0, a: 1);
  final h = _parseHue(match.group(1)!, match.group(2));
  final s = _jsNum(match.group(3)!);
  final v = _jsNum(match.group(4)!);
  final a = match.group(5) == null
      ? 1.0
      : _jsNum(match.group(5)!) / (match.group(6) != null ? 100 : 1);
  return (h: _round(h), s: _round(s), v: _round(v), a: _round(a, 2));
}

/// utils/split.ts — the DataPart comma-triple parser. Anchored regex over
/// `r,g,b[,a]` / `h,s,v[,a]`; ★range-checked per mode (reject out of range,
/// no clamping; missing/empty 4th -> a = 1); hsva rejects h > 360.
({double x, double y, double z, double a})? _splitComma(
  String str, {
  required bool hsva,
}) {
  final res = RegExp(
    r'^\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,?\s*([\d.]*)\s*$',
  ).firstMatch(str);
  if (res == null) return null;
  final result = <double>[
    _jsNum(res.group(1)!),
    _jsNum(res.group(2)!),
    _jsNum(res.group(3)!),
    res.group(4) == null || res.group(4) == '' ? 1 : _jsNum(res.group(4)!),
  ];
  bool check(double a, double max) => !(a.isNaN || a < 0 || a > max);
  final ok =
      check(result[0], hsva ? 360 : 255) &&
      check(result[1], hsva ? 100 : 255) &&
      check(result[2], hsva ? 100 : 255) &&
      check(result[3], 1);
  if (!ok) return null;
  return (x: result[0], y: result[1], z: result[2], a: result[3]);
}

/// The picker value: the HSVA quadruple with its computed RGBA/hex channels.
///
/// ★Upstream `ColorValue` is the raw `{hsva, rgba, hex}` triple whose `hex`
/// keeps the input string (case and all) and whose `rgba`/`hsva` alphas can
/// diverge per change path. The port collapses the triple into one
/// quadruple (onChanged carries the full triple-equivalent): r/g/b are
/// computed integers (`hsvaToRgba` rounds) and `hex` is the canonical
/// lowercase `rgbaToHex` output — ★8-digit `#rrggbbaa` ONLY when a < 1, and
/// always lowercase (the user-typed casing is not preserved — 差异清单).
/// The rgba-side alpha is `round(a, 2)` (`hsvaToRgba` semantics).
@immutable
class SemiColorValue {
  const SemiColorValue({
    required this.h,
    required this.s,
    required this.v,
    this.a = 1,
  });

  /// Hue 0-360 (★the hue slider's right edge yields 360, not 0).
  final double h;

  /// Saturation 0-100.
  final double s;

  /// Value (brightness) 0-100.
  final double v;

  /// Alpha 0-1 (raw source alpha; the rgba channels round it to 2 decimals).
  final double a;

  /// convert.ts `hsvaToRgba` — integer channels.
  int get r => _hsvaToRgba(h, s, v, a).r.toInt();
  int get g => _hsvaToRgba(h, s, v, a).g.toInt();
  int get b => _hsvaToRgba(h, s, v, a).b.toInt();

  /// `hsvaToRgba`'s alpha — ★rounded to 2 decimals (`round(a, 2)`).
  double get rgbaAlpha => _round(a, 2);

  /// convert.ts `hsvaToHex` / `rgbaToHex`: lowercase `#rrggbb` when `a == 1`,
  /// ★8-digit `#rrggbbaa` otherwise.
  String get hex => _hsvaToHex(h, s, v, a);

  /// convert.ts `hsvaToRgbaString` (`rgba(r, g, b, a)`) for the call sites
  /// that render the raw CSS string semantics as a [Color].
  Color get color =>
      Color.fromRGBO(r, g, b, rgbaAlpha.clamp(0.0, 1.0).toDouble());

  /// Upstream `ColorPicker.colorStringToValue` (index.tsx:74-107): dispatch
  /// order `#…` / `rgba…` / `rgb…` / `hsv…`, [ArgumentError] otherwise.
  ///
  /// ★The hex branch is LENIENT (`hexToRgba` accepts anything — 3-char
  /// shorthand parses with missing components, collapsed to 0 here; a
  /// missing alpha is 1). The `rgb`/`hsv` string branches fall back to the
  /// zero-ish regex defaults on garbage (upstream does not throw).
  static SemiColorValue parse(String raw) {
    if (raw.startsWith('#')) return _fromHex(raw);
    if (raw.startsWith('rgba') || raw.startsWith('rgb')) {
      return _fromRgbaString(raw);
    }
    if (raw.startsWith('hsv')) return _fromHsvaString(raw);
    throw ArgumentError(
      'Semi ColorPicker: error on static colorStringToValue method, '
      'input value is invalid: $raw',
    );
  }

  /// [parse] returning null instead of throwing (only the prefix check can).
  static SemiColorValue? tryParse(String raw) {
    try {
      return parse(raw);
    } on ArgumentError {
      return null;
    }
  }

  /// Upstream DataPartFoundation.`getValueByInputValue` + utils/split.ts
  /// (★String-regex parsing): the DataPart text-input parser, stricter than
  /// [parse].
  ///
  /// * hex: ★auto-prepends `#` and accepts the UNANCHORED `#[\d\w]{6,8}`
  ///   shape — 3/4-digit shorthand is REJECTED (a 9-char run still passes
  ///   because the regex is unanchored).
  /// * comma inputs `r,g,b[,a]` / `h,s,v[,a]`: range-checked per [format]
  ///   (reject out-of-range, no clamp; missing 4th -> a = 1); ★hsva hue
  ///   above 360 is rejected.
  static SemiColorValue? tryParseInput(
    String raw, {
    required SemiColorFormat format,
  }) {
    switch (format) {
      case SemiColorFormat.hex:
        var value = raw;
        if (!value.startsWith('#')) value = '#$value';
        if (!RegExp(r'#[\d\w]{6,8}').hasMatch(value)) return null;
        return _fromHex(value);
      case SemiColorFormat.rgba:
        final parts = _splitComma(raw, hsva: false);
        return parts == null
            ? null
            : _fromRgba(parts.x, parts.y, parts.z, parts.a);
      case SemiColorFormat.hsva:
        final parts = _splitComma(raw, hsva: true);
        return parts == null
            ? null
            : SemiColorValue(h: parts.x, s: parts.y, v: parts.z, a: parts.a);
    }
  }

  /// `handleChange(color, 'hex')` — hexToHsva/hexToRgba parity.
  static SemiColorValue _fromHex(String hex) {
    final rgba = _hexToRgba(hex);
    final hsva = _rgbaToHsva(rgba.r, rgba.g, rgba.b, rgba.a);
    return SemiColorValue(h: hsva.h, s: hsva.s, v: hsva.v, a: rgba.a);
  }

  /// `handleChange(color, 'rgba')` — rgbaToHsva parity (a untouched).
  static SemiColorValue _fromRgba(double r, double g, double b, double a) {
    final hsva = _rgbaToHsva(r, g, b, a);
    return SemiColorValue(h: hsva.h, s: hsva.s, v: hsva.v, a: a);
  }

  /// `handleChange(color, 'hsva')` — the quadruple as typed (the hsva string
  /// form rounds via `roundHsva` first).
  static SemiColorValue _fromHsvaString(String raw) {
    final hsva = _hsvaStringToHsva(raw);
    return SemiColorValue(h: hsva.h, s: hsva.s, v: hsva.v, a: hsva.a);
  }

  /// `rgbaStringToRgba` + `rgbaStringToHsva` parity.
  static SemiColorValue _fromRgbaString(String raw) {
    final rgba = _rgbaStringToRgba(raw);
    return _fromRgba(rgba.r, rgba.g, rgba.b, rgba.a);
  }

  /// handleChangeA's ★`!alpha -> a = 1` normalization (and its
  /// `hex.slice(0, 7)` rule, subsumed: a = 1 renders the 6-digit hex).
  SemiColorValue _forceOpaque() => SemiColorValue(h: h, s: s, v: v, a: 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiColorValue &&
          h == other.h &&
          s == other.s &&
          v == other.v &&
          a == other.a;

  @override
  int get hashCode => Object.hash(h, s, v, a);

  @override
  String toString() => 'SemiColorValue(h: $h, s: $s, v: $v, a: $a)';
}

/// A source-sized, non-Material color picker (upstream Semi ColorPicker):
/// SV saturation/brightness area, hue slider, optional alpha slider and the
/// data part (swatch + text input + optional alpha `%` number + format
/// Select + eyedropper bridge).
///
/// See docs/semi_color_picker.md for the behavior contract and the
/// difference list.
class SemiColorPicker extends StatefulWidget {
  const SemiColorPicker({
    super.key,
    this.value,
    this.defaultValue,
    this.alpha = false,
    this.width = 280,
    this.height = 280,
    this.defaultFormat = SemiColorFormat.hex,
    this.usePopover = false,
    this.child,
    this.position = SemiTooltipPosition.bottom,
    this.autoAdjustOverflow = true,
    this.motion = true,
    this.eyeDropper = true,
    this.onEyeDropper,
    this.onChanged,
    this.onOpenChange,
    this.topSlot,
    this.bottomSlot,
  });

  /// Current value; non-null makes the picker controlled (★upstream truthiness
  /// — the project convention is null checks).
  final SemiColorValue? value;

  /// Uncontrolled seed; defaults to the Semi brand color
  /// `SemiColorValue(h: 176, s: 71, v: 77, a: 1)` (`#39c5bb`).
  final SemiColorValue? defaultValue;

  /// Renders the alpha slider and the `%` number input (upstream `alpha`;
  /// ★when false every commit is forced to `a = 1` / 6-digit hex).
  final bool alpha;

  /// Panel width — the SV area, both sliders and the data part all take it
  /// (upstream `width ?? 280`).
  final double width;

  /// SV area height (upstream `height ?? 280`).
  final double height;

  /// Initial DataPart format (upstream `defaultFormat`, default `hex`).
  final SemiColorFormat defaultFormat;

  /// Renders the panel inside a hover popover instead of inline
  /// (upstream `usePopover`).
  final bool usePopover;

  /// Popover trigger child; null renders the default 24x24 swatch
  /// (upstream `children ?? <div …-defaultChildren>`).
  final Widget? child;

  /// Popover placement (upstream Popover `position`, default `bottom`).
  final SemiTooltipPosition position;

  /// Popover auto flip/shift (upstream Popover `autoAdjustOverflow`).
  final bool autoAdjustOverflow;

  /// Whether the popover show/hide motion plays (upstream Popover `motion`).
  final bool motion;

  /// Renders the eyedropper button — ★only together with [onEyeDropper]
  /// (upstream gates on `window.EyeDropper`).
  final bool eyeDropper;

  /// Host bridge for the WICG EyeDropper (no Flutter channel exists —
  /// 差异清单): return a hex/`rgba(…)` string or a [SemiColorValue].
  /// ★`rgba(…)` results are forced to `a = 1`; other shapes are ignored and
  /// failures are swallowed (upstream try/catch).
  final Future<Object?>? Function()? onEyeDropper;

  /// Reports every value change (the full triple-equivalent).
  final ValueChanged<SemiColorValue>? onChanged;

  /// Popover open state (upstream Popover `onVisibleChange`).
  final ValueChanged<bool>? onOpenChange;

  /// Above the picker controls (upstream `topSlot`).
  final Widget? topSlot;

  /// Below the picker controls (upstream `bottomSlot`).
  final Widget? bottomSlot;

  /// Key of the SV saturation/brightness area.
  static const Key svAreaKey = Key('SemiColorPicker.svArea');

  /// Key of the hue slider track.
  static const Key hueSliderKey = Key('SemiColorPicker.hueSlider');

  /// Key of the alpha slider track.
  static const Key alphaSliderKey = Key('SemiColorPicker.alphaSlider');

  /// Key of the 20x20 data-part swatch.
  static const Key swatchKey = Key('SemiColorPicker.swatch');

  /// Key of the default popover trigger swatch.
  static const Key triggerSwatchKey = Key('SemiColorPicker.triggerSwatch');

  /// Key of the data-part color input.
  static const Key colorInputKey = Key('SemiColorPicker.colorInput');

  /// Key of the alpha `%` number input.
  static const Key alphaInputKey = Key('SemiColorPicker.alphaInput');

  /// Key of the format Select.
  static const Key formatSelectKey = Key('SemiColorPicker.formatSelect');

  /// Key of the eyedropper button.
  static const Key eyeDropperButtonKey = Key(
    'SemiColorPicker.eyeDropperButton',
  );

  @override
  State<SemiColorPicker> createState() => _SemiColorPickerState();
}

class _SemiColorPickerState extends State<SemiColorPicker> {
  /// Uncontrolled buffer (SemiRating convention: releasing control retains
  /// the last controlled value).
  late SemiColorValue _stateValue;

  /// Handle-position source — follows the displayed value on every deep
  /// change, but ★stays where a controlled drag dropped it until the
  /// controlled value itself changes (upstream ColorChooseArea/ColorSlider
  /// `handlePosition` state + `componentDidUpdate` JSON deep-diff resync).
  late SemiColorValue _posValue;

  /// Drag latches (upstream `isHandleGrabbing`) — drive the cursors.
  bool _draggingSv = false;
  bool _draggingHue = false;
  bool _draggingAlpha = false;

  @override
  void initState() {
    super.initState();
    _stateValue = _initialValue();
    _posValue = _stateValue;
  }

  SemiColorValue _initialValue() =>
      widget.value ??
      widget.defaultValue ??
      const SemiColorValue(h: 176, s: 71, v: 77, a: 1);

  @override
  void didUpdateWidget(SemiColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // SemiRating.value convention (semi_rating.dart:122-129): releasing
    // control retains the last controlled value instead of resetting.
    if (oldWidget.value != null && widget.value == null) {
      _stateValue = oldWidget.value!;
      _posValue = oldWidget.value!;
      return;
    }
    // ★lodash isEqual deep-diff semantics: an external (or echoed) value
    // change resyncs the buffers; a deep-equal one leaves the dropped handle
    // positions alone.
    if (widget.value != null && widget.value != oldWidget.value) {
      _stateValue = widget.value!;
      _posValue = widget.value!;
    }
  }

  /// The displayed value: the controlled `value`, else the internal buffer
  /// (upstream `getCurrentColor` — ★`value || currentColor` truthiness).
  SemiColorValue get _current => widget.value ?? _stateValue;

  bool get _controlled => widget.value != null;

  /// Commit path for every change. [fromDrag] moves the handle-position
  /// source even in controlled mode (the upstream handle state follows the
  /// pointer); non-drag commits only move it when the displayed value moves.
  /// ★`alpha == false` forces `a = 1` (handleChangeA normalization — see
  /// docs: upstream only reaches it from the alpha slider, which is hidden
  /// without `alpha`; the contract makes it observable on every commit).
  void _commit(SemiColorValue next, {required bool fromDrag}) {
    final value = widget.alpha ? next : next._forceOpaque();
    widget.onChanged?.call(value);
    setState(() {
      if (!_controlled) {
        _stateValue = value;
        _posValue = value;
      } else if (fromDrag) {
        _posValue = value;
      }
    });
  }

  // -- SV area (ColorChooseArea) --------------------------------------------

  /// ★out-of-bounds positions are REJECTED — upstream
  /// `getHandlePositionByMousePosition` returns null outside the box and
  /// nothing changes (no clamp). In-bounds: `s = round(x / width * 100)`,
  /// `v = round(100 - clamp(y / height, 0, 1) * 100)`.
  void _svUpdate(Offset local) {
    final w = widget.width;
    final h = widget.height;
    if (local.dx < 0 || local.dx > w || local.dy < 0 || local.dy > h) return;
    final s = _round(local.dx / w * 100);
    final v = _round(100 - (local.dy / h).clamp(0.0, 1.0) * 100);
    final current = _current;
    _commit(
      SemiColorValue(h: current.h, s: s, v: v, a: current.a),
      fromDrag: true,
    );
  }

  // -- hue slider (ColorSlider) ---------------------------------------------

  /// ★clamped (not rejected): `h = round(clamp(x / width, 0, 1) * 360)` —
  /// the right edge yields 360, not a 0/360 wrap.
  void _hueUpdate(Offset local) {
    final frac = (local.dx / widget.width).clamp(0.0, 1.0);
    final h = _round(frac * 360);
    final current = _current;
    _commit(
      SemiColorValue(h: h, s: current.s, v: current.v, a: current.a),
      fromDrag: true,
    );
  }

  // -- alpha slider (AlphaSlider) -------------------------------------------

  /// ★clamped with 2 decimals: `a = clamp(x / width, 0, 1).toFixed(2)` —
  /// handleChangeA parity (h/s/v untouched).
  void _alphaUpdate(Offset local) {
    final frac = (local.dx / widget.width).clamp(0.0, 1.0);
    final a = _round(frac, 2);
    final current = _current;
    _commit(
      SemiColorValue(h: current.h, s: current.s, v: current.v, a: a),
      fromDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiColorPickerTheme.resolve(context);
    final panel = _buildPanel(theme);
    if (!widget.usePopover) return panel;
    // `usePopover`: hover popover with a bare popup (showArrow: false,
    // popupBare: true). Upstream mounts the panel in a `Popover` whose own
    // surface paints the white background; `popupBare` skips that surface,
    // so the port draws it here — the semi_select.dart `_buildPanel` recipe:
    // popover.scss `$color-popover-bg-default: var(--semi-color-bg-3)` +
    // `$color-popover-border-default: var(--semi-color-border)` (1px) +
    // `$radius-popover: var(--semi-border-radius-medium)` + the
    // `@include shadow-elevated` pair. The 8px content padding inside is
    // colorPicker.scss `&-popover { padding:
    // $spacing-colorPicker_popover-padding; }`.
    final global = SemiTheme.of(context);
    final radius = global.radius.borderRadiusMedium.value;
    return Align(
      // Shrink-to-fit like the upstream Popover trigger container (an
      // inline-block): the trigger keeps its natural size — the 24x24
      // default swatch stays 24x24 (and its hover area with it) even under
      // a tight parent instead of stretching to the parent width.
      alignment: AlignmentDirectional.topStart,
      widthFactor: 1,
      heightFactor: 1,
      child: SemiTooltip(
        content: DecoratedBox(
          decoration: BoxDecoration(
            color: global.colors.colorBg3,
            border: Border.all(width: 1, color: global.colors.colorBorder),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: const [
              _ColorPickerMetrics.shadowElevatedBlur,
              _ColorPickerMetrics.shadowElevatedDrop,
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: EdgeInsets.all(theme.spacingColorPickerPopoverPadding),
              child: panel,
            ),
          ),
        ),
        trigger: SemiTooltipTrigger.hover,
        showArrow: false,
        popupBare: true,
        position: widget.position,
        autoAdjustOverflow: widget.autoAdjustOverflow,
        motion: widget.motion,
        onVisibleChange: widget.onOpenChange,
        child: widget.child ?? _buildDefaultTrigger(theme),
      ),
    );
  }

  /// Upstream `-popover-defaultChildren`: 24x24 (both sides
  /// `width-colorPicker-defaultTrigger`), 4px radius, background =
  /// `currentColor.hex` (the computed canonical hex — CSS would parse the
  /// 8-digit form too).
  Widget _buildDefaultTrigger(SemiResolvedColorPickerThemeData theme) {
    final rgba = _hexToRgba(_current.hex);
    return Container(
      key: SemiColorPicker.triggerSwatchKey,
      width: theme.widthColorPickerDefaultTrigger,
      height: theme.widthColorPickerDefaultTrigger,
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          rgba.r.toInt(),
          rgba.g.toInt(),
          rgba.b.toInt(),
          rgba.a.clamp(0.0, 1.0).toDouble(),
        ),
        borderRadius: BorderRadius.circular(
          theme.radiusColorPickerDefaultTrigger,
        ),
      ),
    );
  }

  Widget _buildPanel(SemiResolvedColorPickerThemeData theme) {
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.topSlot != null) widget.topSlot!,
          _buildSvArea(theme),
          // `margin-top: $spacing-colorPicker_slider-marginTop` on both
          // sliders (colorPicker.scss:37/62).
          SizedBox(height: theme.spacingColorPickerSliderMarginTop),
          _buildHueSlider(theme),
          if (widget.alpha) ...[
            SizedBox(height: theme.spacingColorPickerSliderMarginTop),
            _buildAlphaSlider(theme),
          ],
          // `margin-top: $spacing-colorPicker_dataPart-marginTop`
          // (colorPicker.scss:71).
          SizedBox(height: theme.spacingColorPickerDataPartMarginTop),
          _buildDataPart(theme),
          if (widget.bottomSlot != null) widget.bottomSlot!,
        ],
      ),
    );
  }

  // -- SV area ---------------------------------------------------------------

  Widget _buildSvArea(SemiResolvedColorPickerThemeData theme) {
    final pos = _posValue;
    final current = _current;
    final hueOfPos = _hsvaToRgba(pos.h, 100, 100, 1);
    final handle = Positioned(
      // `getHandlePositionByHSVA`: `x = s / 100 * width`, `y = (1 - v / 100)
      // * height`, each minus half the handle.
      left: pos.s / 100 * widget.width - _ColorPickerMetrics.svHandleSize / 2,
      top:
          (1 - pos.v / 100) * widget.height -
          _ColorPickerMetrics.svHandleSize / 2,
      child: MouseRegion(
        // `.semi-colorPicker-handle` — `cursor: grab` (colorPicker.scss:28),
        // grabbing while the drag latch is on.
        cursor: _draggingSv
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab,
        child: Container(
          width: _ColorPickerMetrics.svHandleSize,
          height: _ColorPickerMetrics.svHandleSize,
          decoration: BoxDecoration(
            // inline `backgroundColor: rgba(r, g, b, a)` (ColorChooseArea
            // index.tsx:113) over the 2px white border (theme fields).
            color: pos.color,
            shape: BoxShape.circle,
            border: Border.all(
              width: theme.widthColorPickerHandleBorder,
              color: theme.colorColorPickerHandleBorder,
            ),
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      // `aria-label="Color"` + `aria-valuetext={`Saturation …%, Brightness
      // …%`}` (ColorChooseArea index.tsx:100-105).
      label: 'Color',
      value:
          'Saturation ${_round(current.s).toInt()}%, '
          'Brightness ${_round(current.v).toInt()}%',
      child: MouseRegion(
        // `.semi-colorPicker-colorChooseArea` — `cursor` is `pointer`,
        // `grabbing` while dragging (index.tsx:99).
        cursor: _draggingSv
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.click,
        child: Listener(
          key: SemiColorPicker.svAreaKey,
          // Raw pointer listeners (slider precedent) — the down/move stream
          // is captured by the area itself (upstream `mousemove` on the area,
          // `mouseup` on window; Listener capture + the out-of-bounds
          // rejection nets the same).
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            setState(() => _draggingSv = true);
            _svUpdate(e.localPosition);
          },
          onPointerMove: (e) {
            if (e.down) _svUpdate(e.localPosition);
          },
          onPointerUp: (_) => setState(() => _draggingSv = false),
          onPointerCancel: (_) => setState(() => _draggingSv = false),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              // The handle may overflow the area (upstream absolute handle).
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    // `areaBgStyle = hsvaToHslString({ h, s: 100, v: 100,
                    // a: 1 })` — `hsl(h, 100%, 50%)`, the pure hue.
                    color: Color.fromARGB(
                      255,
                      hueOfPos.r.toInt(),
                      hueOfPos.g.toInt(),
                      hueOfPos.b.toInt(),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(theme.radiusColorPickerTopLeft),
                      topRight: Radius.circular(
                        theme.radiusColorPickerTopRight,
                      ),
                      bottomLeft: Radius.circular(
                        theme.radiusColorPickerBottomLeft,
                      ),
                      bottomRight: Radius.circular(
                        theme.radiusColorPickerBottomRight,
                      ),
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                // ★ colorPicker.scss:14 —
                // `box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05);`
                // (inset shadow has no Flutter decoration — a 1px inside
                // border paints the same ring).
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          theme.radiusColorPickerTopLeft,
                        ),
                        topRight: Radius.circular(
                          theme.radiusColorPickerTopRight,
                        ),
                        bottomLeft: Radius.circular(
                          theme.radiusColorPickerBottomLeft,
                        ),
                        bottomRight: Radius.circular(
                          theme.radiusColorPickerBottomRight,
                        ),
                      ),
                      border: Border.all(
                        width: 1,
                        color: _ColorPickerMetrics.svInsetColor,
                      ),
                    ),
                  ),
                ),
                // ★ colorPicker.scss:19 — `background-image: linear-gradient(to top, #000, rgba(0, 0, 0, 0)), linear-gradient(to right, #fff, rgba(255, 255, 255, 0));`
                // — two stacked layers; the first CSS layer paints on top.
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(theme.radiusColorPickerTopLeft),
                      topRight: Radius.circular(
                        theme.radiusColorPickerTopRight,
                      ),
                      bottomLeft: Radius.circular(
                        theme.radiusColorPickerBottomLeft,
                      ),
                      bottomRight: Radius.circular(
                        theme.radiusColorPickerBottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // `linear-gradient(to right, #fff, rgba(255, 255,
                        // 255, 0))` (bottom layer).
                        // ★ zero-size trap: a childless DecoratedBox
                        // collapses to 0×0 in the loose Stack constraints —
                        // the expand child is what makes the layer paint at
                        // all (the hue slider's gradient does the same).
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: _ColorPickerMetrics.svWhiteGradient,
                            ),
                          ),
                          child: SizedBox.expand(),
                        ),
                        // `linear-gradient(to top, #000, rgba(0, 0, 0, 0))`
                        // (top layer).
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: _ColorPickerMetrics.svBlackGradient,
                            ),
                          ),
                          child: SizedBox.expand(),
                        ),
                      ],
                    ),
                  ),
                ),
                handle,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- hue slider ------------------------------------------------------------

  Widget _buildHueSlider(SemiResolvedColorPickerThemeData theme) {
    final pos = _posValue;
    final hueColor = _hsvaToRgba(pos.h, 100, 100, 1);
    return Semantics(
      container: true,
      child: MouseRegion(
        // `.semi-colorSlider` — `cursor: pointer` (colorPicker.scss:63).
        cursor: _draggingHue
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.click,
        child: Listener(
          key: SemiColorPicker.hueSliderKey,
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            setState(() => _draggingHue = true);
            _hueUpdate(e.localPosition);
          },
          onPointerMove: (e) {
            if (e.down) _hueUpdate(e.localPosition);
          },
          onPointerUp: (_) => setState(() => _draggingHue = false),
          onPointerCancel: (_) => setState(() => _draggingHue = false),
          child: SizedBox(
            width: widget.width,
            height: _ColorPickerMetrics.sliderTrackHeight,
            child: Stack(
              // The 18px handle overflows the 10px track vertically
              // (top: 50% + translateY(-50%) upstream).
              clipBehavior: Clip.none,
              children: [
                // ★ colorPicker.scss:65 — `background: linear-gradient(to right, #f00 0%, #ff0 17%, #0f0 33%, #0ff 50%, #00f 67%, #f0f 83%, #f00 100%);`
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      theme.radiusColorPickerHandle,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: _ColorPickerMetrics.hueRainbowColors,
                      stops: _ColorPickerMetrics.hueRainbowStops,
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left:
                      pos.h / 360 * widget.width -
                      _ColorPickerMetrics.sliderHandleSize / 2,
                  top:
                      (_ColorPickerMetrics.sliderTrackHeight -
                          _ColorPickerMetrics.sliderHandleSize) /
                      2,
                  child: MouseRegion(
                    // `.semi-colorPicker-handle` — `cursor: grab`.
                    cursor: _draggingHue
                        ? SystemMouseCursors.grabbing
                        : SystemMouseCursors.grab,
                    child: Container(
                      width: _ColorPickerMetrics.sliderHandleSize,
                      height: _ColorPickerMetrics.sliderHandleSize,
                      decoration: BoxDecoration(
                        // `backgroundColor: hsvaToHslString({ h, s: 100,
                        // v: 100, a: 1 })` — `hsl(h, 100%, 50%)`.
                        color: Color.fromARGB(
                          255,
                          hueColor.r.toInt(),
                          hueColor.g.toInt(),
                          hueColor.b.toInt(),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: theme.widthColorPickerHandleBorder,
                          color: theme.colorColorPickerHandleBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- alpha slider ----------------------------------------------------------

  Widget _buildAlphaSlider(SemiResolvedColorPickerThemeData theme) {
    final pos = _posValue;
    final hsla = _hsvaToHsla(pos.h, pos.s, pos.v, pos.a);
    // `hsvaToHslaString({ ...hsva, a: 0 })` -> `hsla(h, s%, l%, 0)` and the
    // a: 1 twin (AlphaSlider index.tsx:77-80 `linear-gradient(90deg, …)`).
    final gradientColors = [
      HSLColor.fromAHSL(0, hsla.h, hsla.s / 100, hsla.l / 100).toColor(),
      HSLColor.fromAHSL(1, hsla.h, hsla.s / 100, hsla.l / 100).toColor(),
    ];
    return Semantics(
      container: true,
      // `aria-label="Alpha"` + `aria-valuetext={`${round(a * 100)}%`}`.
      label: 'Alpha',
      value: '${_round(pos.a * 100).toInt()}%',
      child: MouseRegion(
        // `.semi-colorPicker-alphaSlider` — `cursor: pointer`.
        cursor: _draggingAlpha
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.click,
        child: Listener(
          key: SemiColorPicker.alphaSliderKey,
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            setState(() => _draggingAlpha = true);
            _alphaUpdate(e.localPosition);
          },
          onPointerMove: (e) {
            if (e.down) _alphaUpdate(e.localPosition);
          },
          onPointerUp: (_) => setState(() => _draggingAlpha = false),
          onPointerCancel: (_) => setState(() => _draggingAlpha = false),
          child: SizedBox(
            width: widget.width,
            height: _ColorPickerMetrics.sliderTrackHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Checkerboard track + `alphaSliderInner` gradient overlay
                // (the transparent gradient side shows the checkerboard).
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    theme.radiusColorPickerHandle,
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _CheckerboardPainter()),
                      ),
                      // `linear-gradient(90deg, colorFrom, colorTo)` over
                      // the `-alphaSliderInner` radius.
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              theme.radiusColorPickerAlphaSliderInner,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: gradientColors,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left:
                      pos.a * widget.width -
                      _ColorPickerMetrics.sliderHandleSize / 2,
                  top:
                      (_ColorPickerMetrics.sliderTrackHeight -
                          _ColorPickerMetrics.sliderHandleSize) /
                      2,
                  child: MouseRegion(
                    // `.alphaHandle` — `cursor: grab`.
                    cursor: _draggingAlpha
                        ? SystemMouseCursors.grabbing
                        : SystemMouseCursors.grab,
                    child: Container(
                      width: _ColorPickerMetrics.sliderHandleSize,
                      height: _ColorPickerMetrics.sliderHandleSize,
                      decoration: BoxDecoration(
                        // inline `backgroundColor: hsvaToRgbaString(hsva)`.
                        color: pos.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: theme.widthColorPickerHandleBorder,
                          color: theme.colorColorPickerHandleBorder,
                        ),
                      ),
                      // The `-alphaHandle` checkerboard `background: url(…)`
                      // paints ON TOP of the inline background-color.
                      child: const CustomPaint(painter: _CheckerboardPainter()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- data part -------------------------------------------------------------

  Widget _buildDataPart(SemiResolvedColorPickerThemeData theme) {
    return _DataPart(
      value: _current,
      width: widget.width,
      alpha: widget.alpha,
      defaultFormat: widget.defaultFormat,
      eyeDropperButton: widget.eyeDropper && widget.onEyeDropper != null,
      onEyeDropper: widget.onEyeDropper,
      onValueChanged: (v) => _commit(v, fromDrag: false),
      theme: theme,
    );
  }
}

/// The data row (upstream DataPart): 20x20 demo block, color input, optional
/// alpha `%` number, format Select and the eyedropper button. Owns the format
/// and the input text; the text ★resyncs from the value only on a deep value
/// change or a format change (lodash isEqual semantics) — an invalid edit
/// keeps the user's text and fires nothing.
class _DataPart extends StatefulWidget {
  const _DataPart({
    required this.value,
    required this.width,
    required this.alpha,
    required this.defaultFormat,
    required this.eyeDropperButton,
    required this.onEyeDropper,
    required this.onValueChanged,
    required this.theme,
  });

  final SemiColorValue value;
  final double width;
  final bool alpha;
  final SemiColorFormat defaultFormat;
  final bool eyeDropperButton;
  final Future<Object?>? Function()? onEyeDropper;
  final ValueChanged<SemiColorValue> onValueChanged;
  final SemiResolvedColorPickerThemeData theme;

  @override
  State<_DataPart> createState() => _DataPartState();
}

class _DataPartState extends State<_DataPart> {
  late SemiColorFormat _format;
  late String _inputText;

  @override
  void initState() {
    super.initState();
    _format = widget.defaultFormat;
    _inputText = _displayString();
  }

  @override
  void didUpdateWidget(_DataPart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ★lodash isEqual deep-diff (componentDidUpdate): only a real value
    // change resyncs the text — a controlled parent echoing a deep-equal
    // value leaves the user's text alone.
    if (widget.value != oldWidget.value) {
      _inputText = _displayString();
    }
  }

  /// ★ALWAYS alpha-stripped (DataPartFoundation.getInputValue): hex ->
  /// `hex.slice(0, 7)` (7 chars), rgba -> `r,g,b`, hsva -> `h,s,v` — the
  /// alpha lives only in the `%` field.
  String _displayString() {
    final value = widget.value;
    switch (_format) {
      case SemiColorFormat.hex:
        return value.hex.substring(0, 7);
      case SemiColorFormat.rgba:
        return '${value.r},${value.g},${value.b}';
      case SemiColorFormat.hsva:
        return '${_jsFmt(value.h)},${_jsFmt(value.s)},${_jsFmt(value.v)}';
    }
  }

  void _handleTextChanged(String raw) {
    // ★invalid input keeps the user's text (no revert) and does NOT fire
    // onValueChanged (DataPart/index.tsx:74-80).
    final parsed = SemiColorValue.tryParseInput(raw, format: _format);
    if (parsed != null) widget.onValueChanged(parsed);
    setState(() => _inputText = raw);
  }

  void _handleFormatChanged(Object? value) {
    setState(() {
      _format = SemiColorFormat.values.byName(value! as String);
      // Format changes resync the text (componentDidUpdate).
      _inputText = _displayString();
    });
  }

  /// DataPart/index.tsx:86-99 `onNumberChange` — `a = (v / 100).toFixed(2)`
  /// then the format-specific handleChange; the hex format ★round-trips
  /// through `rgbaToHex` (the alpha requantizes to k/255).
  void _handleAlphaChanged(num raw) {
    final a = _round(raw / 100, 2);
    final value = widget.value;
    switch (_format) {
      case SemiColorFormat.rgba:
        widget.onValueChanged(
          SemiColorValue._fromRgba(
            value.r.toDouble(),
            value.g.toDouble(),
            value.b.toDouble(),
            a,
          ),
        );
      case SemiColorFormat.hex:
        widget.onValueChanged(
          SemiColorValue._fromHex(
            _rgbaToHex(
              value.r.toDouble(),
              value.g.toDouble(),
              value.b.toDouble(),
              a,
            ),
          ),
        );
      case SemiColorFormat.hsva:
        widget.onValueChanged(
          SemiColorValue(h: value.h, s: value.s, v: value.v, a: a),
        );
    }
  }

  /// DataPartFoundation.handlePickValueWithStraw — ★rgba-string results are
  /// forced to `a = 1`, other shapes than hex/`rgba` strings and
  /// [SemiColorValue]s are ignored, and failures are swallowed.
  Future<void> _handleEyeDropper() async {
    final Object? result;
    try {
      result = await widget.onEyeDropper!();
    } catch (_) {
      return;
    }
    if (result == null) return;
    if (result is SemiColorValue) {
      widget.onValueChanged(result);
      return;
    }
    if (result is String) {
      if (result.startsWith('#')) {
        widget.onValueChanged(SemiColorValue.parse(result));
      } else if (result.startsWith('rgba')) {
        final rgba = _rgbaStringToRgba(result);
        widget.onValueChanged(
          SemiColorValue._fromRgba(rgba.r, rgba.g, rgba.b, 1),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final value = widget.value;
    return Row(
      children: [
        // `minWidth: 20, minHeight: 20` demo block (DataPart/index.tsx:68)
        // with `backgroundColor: rgba(r, g, b, a)` and the demoBlock radius.
        Container(
          key: SemiColorPicker.swatchKey,
          width: _ColorPickerMetrics.demoBlockSize,
          height: _ColorPickerMetrics.demoBlockSize,
          decoration: BoxDecoration(
            color: value.color,
            borderRadius: BorderRadius.circular(
              theme.radiusColorPickerDemoBlock,
            ),
          ),
        ),
        // `margin-left: $spacing-colorPicker_inputGroup-marginLeft`.
        SizedBox(width: theme.spacingColorPickerInputGroupMarginLeft),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SemiInput(
                  key: SemiColorPicker.colorInputKey,
                  value: _inputText,
                  size: SemiInputSize.small,
                  onChanged: _handleTextChanged,
                ),
              ),
              if (widget.alpha)
                SizedBox(
                  width: theme.widthColorPickerColorPickerInputNumber,
                  child: SemiInputNumber(
                    key: SemiColorPicker.alphaInputKey,
                    size: SemiInputSize.small,
                    hideButtons: true,
                    min: 0,
                    max: 100,
                    value: _round(value.a * 100).toInt(),
                    onNumberChange: _handleAlphaChanged,
                    // ★ DataPart/index.tsx:101 `}>%</span>` — the `%`
                    // suffix span with the suffix font/padding theme trio.
                    suffix: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            theme.spacingColorPickerInputNumberSuffixVertical,
                        horizontal:
                            theme.spacingColorPickerInputNumberSuffixHorizontal,
                      ),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontSize:
                              theme.fontColorPickerInputNumberSuffixFontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: theme.widthColorPickerFormatSelect,
                child: SemiSelect(
                  key: SemiColorPicker.formatSelectKey,
                  size: SemiInputSize.small,
                  value: _format.name,
                  options: [
                    for (final format in SemiColorFormat.values)
                      SemiSelectOption(value: format.name),
                  ],
                  onChanged: _handleFormatChanged,
                ),
              ),
            ],
          ),
        ),
        if (widget.eyeDropperButton)
          SemiButton(
            null,
            key: SemiColorPicker.eyeDropperButtonKey,
            type: SemiButtonType.tertiary,
            variant: SemiButtonVariant.light,
            size: SemiButtonSize.small,
            icon: const SemiIcon(SemiIcons.eyedropper),
            onPressed: _handleEyeDropper,
          ),
      ],
    );
  }
}

/// The alpha checkerboard — ★ the colorPicker.scss:39/49 data-URI
/// `url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill-opacity=".05"><rect x="8" width="8" height="8"/><rect y="8" width="8" height="8"/></svg>')`
/// ported as a tiling 16x16 CustomPaint: two 8x8 black squares per tile at
/// 5% opacity.
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // `fill-opacity=".05"` over the default black fill.
    final paint = Paint()..color = _ColorPickerMetrics.checkerSquareColor;
    for (var y = 0.0; y < size.height; y += 16) {
      for (var x = 0.0; x < size.width; x += 16) {
        canvas.drawRect(Rect.fromLTWH(x + 8, y, 8, 8), paint);
        canvas.drawRect(Rect.fromLTWH(x, y + 8, 8, 8), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) => false;
}

/// Widget-internal metrics and provenance anchors (upstream values kept out
/// of the theme). See tool/generate_color_picker.py for the
/// 20 = 20 FIELDS + 0 MOTION + 0 INTERNAL accounting; the hardcodes below are
/// the 另列 entries.
abstract final class _ColorPickerMetrics {
  /// colorPicker.scss:14 —
  /// `box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05);` — the inset ring is
  /// ported as a 1px inside border (this is its color).
  static const Color svInsetColor = Color(0x0d000000);

  /// colorPicker.scss:19 — `background-image: linear-gradient(to top, #000,
  /// rgba(0, 0, 0, 0)), linear-gradient(to right, #fff, rgba(255, 255,
  /// 255, 0));` — bottom layer first (CSS paints the first listed on top).
  static const List<Color> svWhiteGradient = [
    Color(0xffffffff),
    Color(0x00ffffff),
  ];
  static const List<Color> svBlackGradient = [
    Color(0xff000000),
    Color(0x00000000),
  ];

  /// colorPicker.scss:65 — `background: linear-gradient(to right, #f00 0%, #ff0 17%, #0f0 33%, #0ff 50%, #00f 67%, #f0f 83%, #f00 100%);`
  static const List<Color> hueRainbowColors = [
    Color(0xffff0000),
    Color(0xffffff00),
    Color(0xff00ff00),
    Color(0xff00ffff),
    Color(0xff0000ff),
    Color(0xffff00ff),
    Color(0xffff0000),
  ];
  static const List<double> hueRainbowStops = [
    0,
    0.17,
    0.33,
    0.5,
    0.67,
    0.83,
    1,
  ];

  /// colorPicker.scss:39/49 checkerboard data-URI squares —
  /// `fill-opacity=".05"` black.
  static const Color checkerSquareColor = Color(0x0d000000);

  /// index.tsx:125/132 — both sliders hardcode `height={10}` (and
  /// `handleSize={18}` below / `handleSize={20}` for the SV area at
  /// index.tsx:123; the handle border is the 2px white theme pair
  /// widthColorPickerHandleBorder + colorColorPickerHandleBorder).
  static const double sliderTrackHeight = 10;
  static const double sliderHandleSize = 18;
  static const double svHandleSize = 20;

  /// DataPart/index.tsx:68 — `minWidth: 20, minHeight: 20` demo block.
  static const double demoBlockSize = 20;

  /// `0 0 1px rgba(0, 0, 0, .3)` / `0 4px 14px rgba(0, 0, 0, .1)` — the two
  /// box-shadow layers of the `@include shadow-elevated` mixin
  /// (packages/semi-theme-default/scss/global.scss) painting the Popover
  /// surface that hosts the panel (popover.scss); hardcoded to the light
  /// token values (same pair as _SelectMetrics.shadowElevated*,
  /// docs/semi_select.md).
  static const BoxShadow shadowElevatedBlur = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.3),
    blurRadius: 1,
  );
  static const BoxShadow shadowElevatedDrop = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 4),
    blurRadius: 14,
  );
}
