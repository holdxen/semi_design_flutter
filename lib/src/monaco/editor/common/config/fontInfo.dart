// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/fontInfo.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `EditorOption` / `FindComputedEditorOptionValueById` come from
//    `editorOptions.ts`, which is still pending; `IValidatedEditorOptions.get`
//    is carried with the erasure (`Object? get(Object id)`).
//  * Object literals (`{ pixelRatio, fontFamily, ... }` constructor options and
//    `EDITOR_FONT_DEFAULTS`) → value classes with the same fields; the exported
//    constant keeps its name.
//  * `opts.lineHeight | 0` → `toInt()` (both truncate toward zero, and line
//    heights are non-negative here).
//  * `Math.round` → `round()` (identical for the non-negative values used).
//  * Unicode-property regex → `RegExp(..., unicode: true)`.
// ---------------------------------------------------------------------------
import '../../../base/common/platform.dart' as platform;

import 'editorZoom.dart' show EditorZoom;

/// Determined from empirical observations.
/// @internal
final double GOLDEN_LINE_HEIGHT_RATIO =
    platform.isMacintosh ? 1.5 : 1.35;

/// @internal
const int MINIMUM_LINE_HEIGHT = 8;

/// @internal
/// 1:1: `export interface IValidatedEditorOptions`.
abstract class IValidatedEditorOptions {
  Object? get(Object id);
}

/// 1:1: the `{ pixelRatio, fontFamily, ..., letterSpacing }` object literal
/// accepted by `BareFontInfo`'s constructor.
class BareFontInfoOptions {
  BareFontInfoOptions({
    required this.pixelRatio,
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    required this.fontFeatureSettings,
    required this.fontVariationSettings,
    required this.lineHeight,
    required this.letterSpacing,
  });

  final double pixelRatio;
  final String fontFamily;
  final String fontWeight;
  final double fontSize;
  final String fontFeatureSettings;
  final String fontVariationSettings;
  final double lineHeight;
  final double letterSpacing;
}

/// JS `String(number)` semantics: integer-valued numbers carry no `.0`.
String _jsNum(num value) {
  if (value is int) {
    return value.toString();
  }
  final double asDouble = value.toDouble();
  if (asDouble == asDouble.truncateToDouble() && asDouble.isFinite) {
    return asDouble.toInt().toString();
  }
  return asDouble.toString();
}

class BareFontInfo {
  // ignore: unused_field
  final Object? _bareFontInfoBrand = null;

  /// @internal
  ///
  /// TS `_create` is `@internal`; Dart library privacy would make it
  /// unreachable from tests, so it is public here (same precedent as
  /// `getWorker` in `internal/common/workers.dart`).
  static BareFontInfo create(
    String fontFamily,
    String fontWeight,
    double fontSize,
    String fontFeatureSettings,
    String fontVariationSettings,
    double lineHeight,
    double letterSpacing,
    double pixelRatio,
    bool ignoreEditorZoom,
  ) {
    if (lineHeight == 0) {
      lineHeight = GOLDEN_LINE_HEIGHT_RATIO * fontSize;
    } else if (lineHeight < MINIMUM_LINE_HEIGHT) {
      // Values too small to be line heights in pixels are in ems.
      lineHeight = lineHeight * fontSize;
    }

    // Enforce integer, minimum constraints
    lineHeight = lineHeight.roundToDouble();
    if (lineHeight < MINIMUM_LINE_HEIGHT) {
      lineHeight = MINIMUM_LINE_HEIGHT.toDouble();
    }

    final double editorZoomLevelMultiplier =
        1 + (ignoreEditorZoom ? 0 : EditorZoom.getZoomLevel() * 0.1);
    fontSize *= editorZoomLevelMultiplier;
    lineHeight *= editorZoomLevelMultiplier;

    if (fontVariationSettings == FONT_VARIATION_TRANSLATE) {
      if (fontWeight == 'normal' || fontWeight == 'bold') {
        fontVariationSettings = FONT_VARIATION_OFF;
      } else {
        final int fontWeightAsNumber = int.parse(fontWeight);
        fontVariationSettings = "'wght' $fontWeightAsNumber";
        fontWeight = 'normal';
      }
    }

    return BareFontInfo._(BareFontInfoOptions(
      pixelRatio: pixelRatio,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      fontFeatureSettings: fontFeatureSettings,
      fontVariationSettings: fontVariationSettings,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
    ));
  }

  final double pixelRatio;
  final String fontFamily;
  final String fontWeight;
  final double fontSize;
  final String fontFeatureSettings;
  final String fontVariationSettings;
  final double lineHeight;
  final double letterSpacing;

  /// @internal
  BareFontInfo._(BareFontInfoOptions opts)
      : pixelRatio = opts.pixelRatio,
        fontFamily = opts.fontFamily.toString(),
        fontWeight = opts.fontWeight.toString(),
        fontSize = opts.fontSize,
        fontFeatureSettings = opts.fontFeatureSettings,
        fontVariationSettings = opts.fontVariationSettings,
        lineHeight = opts.lineHeight.toInt().toDouble(),
        letterSpacing = opts.letterSpacing;

  /// @internal
  String getId() {
    // JS number → string drops the fraction for integer-valued numbers
    // (`${1}` is `"1"`, whereas Dart prints `1.0`).
    return '${_jsNum(pixelRatio)}-$fontFamily-$fontWeight-${_jsNum(fontSize)}-$fontFeatureSettings-$fontVariationSettings-${_jsNum(lineHeight)}-${_jsNum(letterSpacing)}';
  }

  /// @internal
  String getMassagedFontFamily() {
    final String fallbackFontFamily = EDITOR_FONT_DEFAULTS.fontFamily;
    final String fontFamily = BareFontInfo._wrapInQuotes(this.fontFamily);
    if (fallbackFontFamily.isNotEmpty && this.fontFamily != fallbackFontFamily) {
      return '$fontFamily, $fallbackFontFamily';
    }
    return fontFamily;
  }

  static String _wrapInQuotes(String fontFamily) {
    if (RegExp('[,"\']').hasMatch(fontFamily)) {
      // Looks like the font family might be already escaped
      return fontFamily;
    }
    if (RegExp(r'[+ ]').hasMatch(fontFamily)) {
      // Wrap a font family using + or <space> with quotes
      return '"$fontFamily"';
    }
    return fontFamily;
  }
}

// change this whenever `FontInfo` members are changed
const int SERIALIZED_FONT_INFO_VERSION = 2;

/// 1:1: the `{ ..., isMonospace, ... }` object literal accepted by
/// `FontInfo`'s constructor.
class FontInfoOptions extends BareFontInfoOptions {
  FontInfoOptions({
    required super.pixelRatio,
    required super.fontFamily,
    required super.fontWeight,
    required super.fontSize,
    required super.fontFeatureSettings,
    required super.fontVariationSettings,
    required super.lineHeight,
    required super.letterSpacing,
    required this.isMonospace,
    required this.typicalHalfwidthCharacterWidth,
    required this.typicalFullwidthCharacterWidth,
    required this.canUseHalfwidthRightwardsArrow,
    required this.spaceWidth,
    required this.middotWidth,
    required this.wsmiddotWidth,
    required this.maxDigitWidth,
  });

  final bool isMonospace;
  final double typicalHalfwidthCharacterWidth;
  final double typicalFullwidthCharacterWidth;
  final bool canUseHalfwidthRightwardsArrow;
  final double spaceWidth;
  final double middotWidth;
  final double wsmiddotWidth;
  final double maxDigitWidth;
}

class FontInfo extends BareFontInfo {
  // ignore: unused_field
  final Object? _editorStylingBrand = null;

  final int version = SERIALIZED_FONT_INFO_VERSION;
  final bool isTrusted;
  final bool isMonospace;
  final double typicalHalfwidthCharacterWidth;
  final double typicalFullwidthCharacterWidth;
  final bool canUseHalfwidthRightwardsArrow;
  final double spaceWidth;
  final double middotWidth;
  final double wsmiddotWidth;
  final double maxDigitWidth;

  /// @internal
  FontInfo(FontInfoOptions opts, bool isTrusted)
      : isTrusted = isTrusted,
        isMonospace = opts.isMonospace,
        typicalHalfwidthCharacterWidth = opts.typicalHalfwidthCharacterWidth,
        typicalFullwidthCharacterWidth = opts.typicalFullwidthCharacterWidth,
        canUseHalfwidthRightwardsArrow = opts.canUseHalfwidthRightwardsArrow,
        spaceWidth = opts.spaceWidth,
        middotWidth = opts.middotWidth,
        wsmiddotWidth = opts.wsmiddotWidth,
        maxDigitWidth = opts.maxDigitWidth,
        super._(opts);

  /// @internal
  bool equals(FontInfo other) {
    return (fontFamily == other.fontFamily &&
        fontWeight == other.fontWeight &&
        fontSize == other.fontSize &&
        fontFeatureSettings == other.fontFeatureSettings &&
        fontVariationSettings == other.fontVariationSettings &&
        lineHeight == other.lineHeight &&
        letterSpacing == other.letterSpacing &&
        typicalHalfwidthCharacterWidth ==
            other.typicalHalfwidthCharacterWidth &&
        typicalFullwidthCharacterWidth ==
            other.typicalFullwidthCharacterWidth &&
        canUseHalfwidthRightwardsArrow ==
            other.canUseHalfwidthRightwardsArrow &&
        spaceWidth == other.spaceWidth &&
        middotWidth == other.middotWidth &&
        wsmiddotWidth == other.wsmiddotWidth &&
        maxDigitWidth == other.maxDigitWidth);
  }
}

/// @internal
const String FONT_VARIATION_OFF = 'normal';

/// @internal
const String FONT_VARIATION_TRANSLATE = 'translate';

/// @internal
const String DEFAULT_WINDOWS_FONT_FAMILY = 'Consolas, \'Courier New\', monospace';

/// @internal
const String DEFAULT_MAC_FONT_FAMILY = 'Menlo, Monaco, \'Courier New\', monospace';

/// @internal
const String DEFAULT_LINUX_FONT_FAMILY = '\'Droid Sans Mono\', monospace';

/// 1:1: `export const EDITOR_FONT_DEFAULTS`.
class EditorFontDefaults {
  const EditorFontDefaults({
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    required this.lineHeight,
    required this.letterSpacing,
  });

  final String fontFamily;
  final String fontWeight;
  final num fontSize;
  final num lineHeight;
  final num letterSpacing;
}

final EditorFontDefaults EDITOR_FONT_DEFAULTS = EditorFontDefaults(
  fontFamily: platform.isMacintosh
      ? DEFAULT_MAC_FONT_FAMILY
      : (platform.isWindows
          ? DEFAULT_WINDOWS_FONT_FAMILY
          : DEFAULT_LINUX_FONT_FAMILY),
  fontWeight: 'normal',
  fontSize: platform.isMacintosh ? 12 : 14,
  lineHeight: 0,
  letterSpacing: 0,
);

// `\p{L}`, `\p{M}`, and `\p{N}` match any Unicode letter, combining mark, or
// number; the remaining characters are punctuation commonly used in CSS
// font-family lists.
final RegExp allowedFontFamilyPattern =
    RegExp("^[\\p{L}\\p{M}\\p{N} _+'\",.-]+\$", unicode: true);

String sanitizeFontFamily(String fontFamily) {
  return allowedFontFamilyPattern.hasMatch(fontFamily)
      ? fontFamily
      : EDITOR_FONT_DEFAULTS.fontFamily;
}