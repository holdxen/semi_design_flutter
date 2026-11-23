// Port of `packages/core/src/common/styles.ts`.
//
// Web keeps colors as CSS strings and font specs as `"600 13px"` concatenated
// with a font family. Flutter has no CSS font shorthand, so the font part of
// `Theme` is split into its numeric parts (`headerFontSize`,
// `headerFontWeight`, ...) and realized into `TextStyle` by [resolve].
// Everything else keeps the upstream name and default value 1:1.
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../theme/semi_theme_data.dart';

/// Port of `Theme` (`common/styles.ts:57-101`).
///
/// Unlike [ThemeData] this is a plain value object: `DataEditor` merges
/// per-column / per-row / per-cell overlays over it with [merge] on every
/// draw, exactly like `mergeAndRealizeTheme` does.
@immutable
class SemiDataGridTheme {
  const SemiDataGridTheme({
    required this.accentColor,
    required this.accentFg,
    required this.accentLight,
    required this.textDark,
    required this.textMedium,
    required this.textLight,
    required this.textBubble,
    required this.bgIconHeader,
    required this.fgIconHeader,
    required this.textHeader,
    required this.textHeaderSelected,
    required this.bgCell,
    required this.bgCellMedium,
    required this.bgHeader,
    required this.bgHeaderHasFocus,
    required this.bgHeaderHovered,
    required this.bgBubble,
    required this.bgBubbleSelected,
    required this.bubbleHeight,
    required this.bubblePadding,
    required this.bubbleMargin,
    required this.bgSearchResult,
    required this.borderColor,
    required this.drilldownBorder,
    required this.linkColor,
    required this.cellHorizontalPadding,
    required this.cellVerticalPadding,
    required this.headerFontSize,
    required this.headerFontWeight,
    required this.headerIconSize,
    required this.baseFontSize,
    required this.markerFontSize,
    required this.fontFamily,
    required this.editorFontSize,
    required this.lineHeight,
    required this.checkboxMaxSize,
    this.textGroupHeader,
    this.bgGroupHeader,
    this.bgGroupHeaderHovered,
    this.resizeIndicatorColor,
    this.horizontalBorderColor,
    this.headerBottomBorderColor,
    this.roundingRadius,
    this.fontFamilyFallback,
  });

  /// `dataEditorBaseTheme` (`common/styles.ts:103-151`).
  factory SemiDataGridTheme.light() => _baseLight;

  /// Builds a Glide theme from the surrounding Semi Design theme.
  ///
  /// This is the default used by the data editor and grid when no explicit
  /// `SemiDataGridTheme` is supplied, so the grid follows the same light/dark switch,
  /// palette, typography and radius scale as every other Semi component.
  /// Passing a theme explicitly still wins.
  factory SemiDataGridTheme.fromSemiTheme(SemiThemeData semi) {
    final c = semi.colors;
    final t = semi.typography;
    final r = semi.radius;
    final bg = c.colorBg0;
    Color onBg(Color color) => Color.alphaBlend(color, bg);

    return SemiDataGridTheme(
      accentColor: c.colorPrimary,
      accentFg: c.colorWhite,
      accentLight: onBg(c.colorPrimaryLightDefault),
      textDark: c.colorText0,
      textMedium: c.colorText2,
      textLight: c.colorText3,
      textBubble: c.colorText1,
      bgIconHeader: c.colorText2,
      fgIconHeader: c.colorWhite,
      textHeader: c.colorText1,
      textGroupHeader: c.colorText1,
      textHeaderSelected: c.colorWhite,
      bgCell: bg,
      bgCellMedium: onBg(c.colorFill0),
      bgHeader: onBg(c.colorFill0),
      bgHeaderHasFocus: onBg(c.colorFill1),
      bgHeaderHovered: onBg(c.colorFill0),
      bgBubble: onBg(c.colorFill1),
      bgBubbleSelected: bg,
      bubbleHeight: 20,
      bubblePadding: 6,
      bubbleMargin: 4,
      bgSearchResult: Color.alphaBlend(
        c.colorHighlightBg.withValues(alpha: 0.25),
        bg,
      ),
      borderColor: c.colorBorder,
      drilldownBorder: const Color(0x00000000),
      linkColor: c.colorLink,
      cellHorizontalPadding: 8,
      cellVerticalPadding: 3,
      headerFontSize: t.fontSizeRegular,
      headerFontWeight: t.fontWeightBold,
      headerIconSize: 18,
      baseFontSize: t.fontSizeRegular,
      markerFontSize: t.fontSizeSmall,
      fontFamily: t.fontFamily ?? 'Inter',
      fontFamilyFallback: t.fontFamilyFallback,
      editorFontSize: t.fontSizeRegular,
      lineHeight: t.lineHeightRegular / t.fontSizeRegular,
      checkboxMaxSize: 18,
      roundingRadius: r.borderRadiusSmall.resolve(0),
    );
  }

  final Color accentColor;
  final Color accentFg;
  final Color accentLight;
  final Color textDark;
  final Color textMedium;
  final Color textLight;
  final Color textBubble;
  final Color bgIconHeader;
  final Color fgIconHeader;
  final Color textHeader;
  final Color? textGroupHeader;
  final Color? bgGroupHeader;
  final Color? bgGroupHeaderHovered;
  final Color textHeaderSelected;
  final Color bgCell;
  final Color bgCellMedium;
  final Color bgHeader;
  final Color bgHeaderHasFocus;
  final Color bgHeaderHovered;
  final Color bgBubble;
  final Color bgBubbleSelected;
  final double bubbleHeight;
  final double bubblePadding;
  final double bubbleMargin;
  final Color bgSearchResult;
  final Color borderColor;
  final Color drilldownBorder;
  final Color linkColor;
  final double cellHorizontalPadding;
  final double cellVerticalPadding;

  /// Upstream `headerFontStyle: "600 13px"`, split into parts.
  final double headerFontSize;
  final FontWeight headerFontWeight;

  final double headerIconSize;

  /// Upstream `baseFontStyle: "13px"`.
  final double baseFontSize;

  /// Upstream `markerFontStyle: "9px"`.
  final double markerFontSize;
  final String fontFamily;

  /// Font fallbacks from the Semi typography tokens. Glide's upstream CSS
  /// family list is kept in [fontFamily] for compatibility; Flutter needs the
  /// families split into this list to actually resolve them.
  final List<String>? fontFamilyFallback;

  /// Upstream `editorFontSize` is a CSS length string; kept numeric here.
  final double editorFontSize;

  /// Unitless line-height scaler (`theme.lineHeight`), multiplied by the em
  /// height when wrapping text.
  final double lineHeight;
  final double checkboxMaxSize;

  final Color? resizeIndicatorColor;
  final Color? horizontalBorderColor;
  final Color? headerBottomBorderColor;
  final double? roundingRadius;

  static const SemiDataGridTheme _baseLight = SemiDataGridTheme(
    accentColor: Color(0xFF4F5DFF),
    accentFg: Color(0xFFFFFFFF),
    accentLight: Color(0x1A3E74FD),
    textDark: Color(0xFF313139),
    textMedium: Color(0xFF737383),
    textLight: Color(0xFFB2B2C0),
    textBubble: Color(0xFF313139),
    bgIconHeader: Color(0xFF737383),
    fgIconHeader: Color(0xFFFFFFFF),
    textHeader: Color(0xFF313139),
    textGroupHeader: Color(0xBB313139),
    textHeaderSelected: Color(0xFFFFFFFF),
    bgCell: Color(0xFFFFFFFF),
    bgCellMedium: Color(0xFFFAFAFB),
    bgHeader: Color(0xFFF7F7F8),
    bgHeaderHasFocus: Color(0xFFE9E9EB),
    bgHeaderHovered: Color(0xFFEFEFF1),
    bgBubble: Color(0xFFEDEDF3),
    bgBubbleSelected: Color(0xFFFFFFFF),
    bubbleHeight: 20,
    bubblePadding: 6,
    bubbleMargin: 4,
    bgSearchResult: Color(0xFFFFF9E3),
    borderColor: Color(0x29737483),
    drilldownBorder: Color(0x00000000),
    linkColor: Color(0xFF353FB5),
    cellHorizontalPadding: 8,
    cellVerticalPadding: 3,
    headerFontSize: 13,
    headerFontWeight: FontWeight.w600,
    headerIconSize: 18,
    baseFontSize: 13,
    markerFontSize: 9,
    fontFamily:
        'Inter, Roboto, -apple-system, BlinkMacSystemFont, '
        'avenir next, avenir, segoe ui, helvetica neue, helvetica, Ubuntu, '
        'noto, arial, sans-serif',
    editorFontSize: 13,
    lineHeight: 1.4,
    checkboxMaxSize: 18,
  );

  TextStyle get baseTextStyle => TextStyle(
    fontSize: baseFontSize,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    color: textDark,
  );

  TextStyle get headerTextStyle => TextStyle(
    fontSize: headerFontSize,
    fontWeight: headerFontWeight,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    color: textHeader,
  );

  TextStyle get markerTextStyle => TextStyle(
    fontSize: markerFontSize,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// `mergeAndRealizeTheme` (`common/styles.ts:171-214`).
  ///
  /// Overlays are applied left to right; `bgCell` is alpha-blended rather than
  /// replaced (upstream calls `blend` for the same reason: a row theme with a
  /// translucent background must tint the cell, not hide it).
  SemiDataGridTheme merge(List<SemiDataGridTheme?> overlays) {
    var merged = this;
    for (final overlay in overlays) {
      if (overlay == null) continue;
      merged = merged._mergeOne(overlay);
    }
    return merged;
  }

  SemiDataGridTheme _mergeOne(SemiDataGridTheme o) => SemiDataGridTheme(
    accentColor: o.accentColor,
    accentFg: o.accentFg,
    accentLight: o.accentLight,
    textDark: o.textDark,
    textMedium: o.textMedium,
    textLight: o.textLight,
    textBubble: o.textBubble,
    bgIconHeader: o.bgIconHeader,
    fgIconHeader: o.fgIconHeader,
    textHeader: o.textHeader,
    textGroupHeader: o.textGroupHeader ?? textGroupHeader,
    bgGroupHeader: o.bgGroupHeader ?? bgGroupHeader,
    bgGroupHeaderHovered: o.bgGroupHeaderHovered ?? bgGroupHeaderHovered,
    textHeaderSelected: o.textHeaderSelected,
    bgCell: Color.alphaBlend(o.bgCell, bgCell),
    bgCellMedium: o.bgCellMedium,
    bgHeader: o.bgHeader,
    bgHeaderHasFocus: o.bgHeaderHasFocus,
    bgHeaderHovered: o.bgHeaderHovered,
    bgBubble: o.bgBubble,
    bgBubbleSelected: o.bgBubbleSelected,
    bubbleHeight: o.bubbleHeight,
    bubblePadding: o.bubblePadding,
    bubbleMargin: o.bubbleMargin,
    bgSearchResult: o.bgSearchResult,
    borderColor: o.borderColor,
    drilldownBorder: o.drilldownBorder,
    linkColor: o.linkColor,
    cellHorizontalPadding: o.cellHorizontalPadding,
    cellVerticalPadding: o.cellVerticalPadding,
    headerFontSize: o.headerFontSize,
    headerFontWeight: o.headerFontWeight,
    headerIconSize: o.headerIconSize,
    baseFontSize: o.baseFontSize,
    markerFontSize: o.markerFontSize,
    fontFamily: o.fontFamily,
    fontFamilyFallback: o.fontFamilyFallback ?? fontFamilyFallback,
    editorFontSize: o.editorFontSize,
    lineHeight: o.lineHeight,
    checkboxMaxSize: o.checkboxMaxSize,
    resizeIndicatorColor: o.resizeIndicatorColor ?? resizeIndicatorColor,
    horizontalBorderColor: o.horizontalBorderColor ?? horizontalBorderColor,
    headerBottomBorderColor:
        o.headerBottomBorderColor ?? headerBottomBorderColor,
    roundingRadius: o.roundingRadius ?? roundingRadius,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SemiDataGridTheme &&
        other.accentColor == accentColor &&
        other.accentFg == accentFg &&
        other.accentLight == accentLight &&
        other.textDark == textDark &&
        other.textMedium == textMedium &&
        other.textLight == textLight &&
        other.textBubble == textBubble &&
        other.bgIconHeader == bgIconHeader &&
        other.fgIconHeader == fgIconHeader &&
        other.textHeader == textHeader &&
        other.textGroupHeader == textGroupHeader &&
        other.bgGroupHeader == bgGroupHeader &&
        other.bgGroupHeaderHovered == bgGroupHeaderHovered &&
        other.textHeaderSelected == textHeaderSelected &&
        other.bgCell == bgCell &&
        other.bgCellMedium == bgCellMedium &&
        other.bgHeader == bgHeader &&
        other.bgHeaderHasFocus == bgHeaderHasFocus &&
        other.bgHeaderHovered == bgHeaderHovered &&
        other.bgBubble == bgBubble &&
        other.bgBubbleSelected == bgBubbleSelected &&
        other.bubbleHeight == bubbleHeight &&
        other.bubblePadding == bubblePadding &&
        other.bubbleMargin == bubbleMargin &&
        other.bgSearchResult == bgSearchResult &&
        other.borderColor == borderColor &&
        other.drilldownBorder == drilldownBorder &&
        other.linkColor == linkColor &&
        other.cellHorizontalPadding == cellHorizontalPadding &&
        other.cellVerticalPadding == cellVerticalPadding &&
        other.headerFontSize == headerFontSize &&
        other.headerFontWeight == headerFontWeight &&
        other.headerIconSize == headerIconSize &&
        other.baseFontSize == baseFontSize &&
        other.markerFontSize == markerFontSize &&
        other.fontFamily == fontFamily &&
        listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
        other.editorFontSize == editorFontSize &&
        other.lineHeight == lineHeight &&
        other.checkboxMaxSize == checkboxMaxSize &&
        other.resizeIndicatorColor == resizeIndicatorColor &&
        other.horizontalBorderColor == horizontalBorderColor &&
        other.headerBottomBorderColor == headerBottomBorderColor &&
        other.roundingRadius == roundingRadius;
  }

  @override
  int get hashCode => Object.hashAll([
    accentColor,
    accentFg,
    accentLight,
    textDark,
    textMedium,
    textLight,
    textBubble,
    bgIconHeader,
    fgIconHeader,
    textHeader,
    textGroupHeader,
    bgGroupHeader,
    bgGroupHeaderHovered,
    textHeaderSelected,
    bgCell,
    bgCellMedium,
    bgHeader,
    bgHeaderHasFocus,
    bgHeaderHovered,
    bgBubble,
    bgBubbleSelected,
    bubbleHeight,
    bubblePadding,
    bubbleMargin,
    bgSearchResult,
    borderColor,
    drilldownBorder,
    linkColor,
    cellHorizontalPadding,
    cellVerticalPadding,
    headerFontSize,
    headerFontWeight,
    headerIconSize,
    baseFontSize,
    markerFontSize,
    fontFamily,
    Object.hashAll(fontFamilyFallback ?? const <String>[]),
    editorFontSize,
    lineHeight,
    checkboxMaxSize,
    resizeIndicatorColor,
    horizontalBorderColor,
    headerBottomBorderColor,
    roundingRadius,
  ]);
}

/// Theme prefix for per-column / per-row / per-cell overrides.
///
/// Upstream models these as `Partial<Theme>`; Dart has no partial types, so a
/// patch carries nullable fields and only non-null entries are applied.
@immutable
class SemiThemeOverride {
  const SemiThemeOverride({
    this.accentColor,
    this.accentFg,
    this.accentLight,
    this.textDark,
    this.textMedium,
    this.textLight,
    this.textBubble,
    this.bgIconHeader,
    this.fgIconHeader,
    this.textHeader,
    this.textGroupHeader,
    this.bgGroupHeader,
    this.bgGroupHeaderHovered,
    this.textHeaderSelected,
    this.bgCell,
    this.bgCellMedium,
    this.bgHeader,
    this.bgHeaderHasFocus,
    this.bgHeaderHovered,
    this.bgBubble,
    this.bgBubbleSelected,
    this.bgSearchResult,
    this.borderColor,
    this.drilldownBorder,
    this.linkColor,
    this.cellHorizontalPadding,
    this.cellVerticalPadding,
    this.headerFontSize,
    this.headerFontWeight,
    this.headerIconSize,
    this.baseFontSize,
    this.markerFontSize,
    this.fontFamily,
    this.editorFontSize,
    this.lineHeight,
    this.checkboxMaxSize,
    this.resizeIndicatorColor,
    this.horizontalBorderColor,
    this.headerBottomBorderColor,
    this.roundingRadius,
  });

  final Color? accentColor;
  final Color? accentFg;
  final Color? accentLight;
  final Color? textDark;
  final Color? textMedium;
  final Color? textLight;
  final Color? textBubble;
  final Color? bgIconHeader;
  final Color? fgIconHeader;
  final Color? textHeader;
  final Color? textGroupHeader;
  final Color? bgGroupHeader;
  final Color? bgGroupHeaderHovered;
  final Color? textHeaderSelected;
  final Color? bgCell;
  final Color? bgCellMedium;
  final Color? bgHeader;
  final Color? bgHeaderHasFocus;
  final Color? bgHeaderHovered;
  final Color? bgBubble;
  final Color? bgBubbleSelected;
  final Color? bgSearchResult;
  final Color? borderColor;
  final Color? drilldownBorder;
  final Color? linkColor;
  final double? cellHorizontalPadding;
  final double? cellVerticalPadding;
  final double? headerFontSize;
  final FontWeight? headerFontWeight;
  final double? headerIconSize;
  final double? baseFontSize;
  final double? markerFontSize;
  final String? fontFamily;
  final double? editorFontSize;
  final double? lineHeight;
  final double? checkboxMaxSize;
  final Color? resizeIndicatorColor;
  final Color? horizontalBorderColor;
  final Color? headerBottomBorderColor;
  final double? roundingRadius;

  /// Applies this patch over [base]. Mirrors `mergeAndRealizeTheme`'s field
  /// loop for the fields this patch names.
  SemiDataGridTheme applyTo(SemiDataGridTheme base) => SemiDataGridTheme(
    accentColor: accentColor ?? base.accentColor,
    accentFg: accentFg ?? base.accentFg,
    accentLight: accentLight ?? base.accentLight,
    textDark: textDark ?? base.textDark,
    textMedium: textMedium ?? base.textMedium,
    textLight: textLight ?? base.textLight,
    textBubble: textBubble ?? base.textBubble,
    bgIconHeader: bgIconHeader ?? base.bgIconHeader,
    fgIconHeader: fgIconHeader ?? base.fgIconHeader,
    textHeader: textHeader ?? base.textHeader,
    textGroupHeader: textGroupHeader ?? base.textGroupHeader,
    bgGroupHeader: bgGroupHeader ?? base.bgGroupHeader,
    bgGroupHeaderHovered: bgGroupHeaderHovered ?? base.bgGroupHeaderHovered,
    textHeaderSelected: textHeaderSelected ?? base.textHeaderSelected,
    bgCell: bgCell == null
        ? base.bgCell
        : Color.alphaBlend(bgCell!, base.bgCell),
    bgCellMedium: bgCellMedium ?? base.bgCellMedium,
    bgHeader: bgHeader ?? base.bgHeader,
    bgHeaderHasFocus: bgHeaderHasFocus ?? base.bgHeaderHasFocus,
    bgHeaderHovered: bgHeaderHovered ?? base.bgHeaderHovered,
    bgBubble: bgBubble ?? base.bgBubble,
    bgBubbleSelected: bgBubbleSelected ?? base.bgBubbleSelected,
    bubbleHeight: base.bubbleHeight,
    bubblePadding: base.bubblePadding,
    bubbleMargin: base.bubbleMargin,
    bgSearchResult: bgSearchResult ?? base.bgSearchResult,
    borderColor: borderColor ?? base.borderColor,
    drilldownBorder: drilldownBorder ?? base.drilldownBorder,
    linkColor: linkColor ?? base.linkColor,
    cellHorizontalPadding: cellHorizontalPadding ?? base.cellHorizontalPadding,
    cellVerticalPadding: cellVerticalPadding ?? base.cellVerticalPadding,
    headerFontSize: headerFontSize ?? base.headerFontSize,
    headerFontWeight: headerFontWeight ?? base.headerFontWeight,
    headerIconSize: headerIconSize ?? base.headerIconSize,
    baseFontSize: baseFontSize ?? base.baseFontSize,
    markerFontSize: markerFontSize ?? base.markerFontSize,
    fontFamily: fontFamily ?? base.fontFamily,
    fontFamilyFallback: base.fontFamilyFallback,
    editorFontSize: editorFontSize ?? base.editorFontSize,
    lineHeight: lineHeight ?? base.lineHeight,
    checkboxMaxSize: checkboxMaxSize ?? base.checkboxMaxSize,
    resizeIndicatorColor: resizeIndicatorColor ?? base.resizeIndicatorColor,
    horizontalBorderColor: horizontalBorderColor ?? base.horizontalBorderColor,
    headerBottomBorderColor:
        headerBottomBorderColor ?? base.headerBottomBorderColor,
    roundingRadius: roundingRadius ?? base.roundingRadius,
  );
}
