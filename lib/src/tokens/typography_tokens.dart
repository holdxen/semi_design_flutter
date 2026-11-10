import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Sass typography configuration; font resources are supplied by the host.
@immutable
class SemiTypographyTokens {
  const SemiTypographyTokens.defaults()
    : fontFamily = 'Inter',
      fontFamilyFallback = const [
        '-apple-system',
        'BlinkMacSystemFont',
        'PingFang SC',
        'Hiragino Sans GB',
        'Microsoft YaHei',
        'Segoe UI',
        'Helvetica Neue',
        'Helvetica',
        'Arial',
        'sans-serif',
      ],
      fontSizeSmall = 12,
      fontSizeRegular = 14,
      fontSizeHeading1 = 32,
      fontSizeHeading2 = 28,
      fontSizeHeading3 = 24,
      fontSizeHeading4 = 20,
      fontSizeHeading5 = 18,
      fontSizeHeading6 = 16,
      lineHeightSmall = 16,
      lineHeightRegular = 20,
      lineHeightHeading1 = 44,
      lineHeightHeading2 = 40,
      lineHeightHeading3 = 32,
      lineHeightHeading4 = 28,
      lineHeightHeading5 = 24,
      lineHeightHeading6 = 22,
      fontWeightLight = FontWeight.w200,
      fontWeightRegular = FontWeight.w400,
      fontWeightBold = FontWeight.w600;
  SemiTypographyTokens({
    this.fontFamily = 'Inter',
    List<String> fontFamilyFallback = const [
      '-apple-system',
      'BlinkMacSystemFont',
      'PingFang SC',
      'Hiragino Sans GB',
      'Microsoft YaHei',
      'Segoe UI',
      'Helvetica Neue',
      'Helvetica',
      'Arial',
      'sans-serif',
    ],
    this.fontSizeSmall = 12,
    this.fontSizeRegular = 14,
    this.fontSizeHeading1 = 32,
    this.fontSizeHeading2 = 28,
    this.fontSizeHeading3 = 24,
    this.fontSizeHeading4 = 20,
    this.fontSizeHeading5 = 18,
    this.fontSizeHeading6 = 16,
    this.lineHeightSmall = 16,
    this.lineHeightRegular = 20,
    this.lineHeightHeading1 = 44,
    this.lineHeightHeading2 = 40,
    this.lineHeightHeading3 = 32,
    this.lineHeightHeading4 = 28,
    this.lineHeightHeading5 = 24,
    this.lineHeightHeading6 = 22,
    this.fontWeightLight = FontWeight.w200,
    this.fontWeightRegular = FontWeight.w400,
    this.fontWeightBold = FontWeight.w600,
  }) : fontFamilyFallback = List<String>.unmodifiable(fontFamilyFallback);

  /// `$font-family-regular`, packages/semi-theme-default/scss/variables.scss; first family.
  final String? fontFamily;

  /// `$font-family-regular`, packages/semi-theme-default/scss/variables.scss; remaining families, without platform alias translation.
  final List<String> fontFamilyFallback;

  /// `$font-size-small`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeSmall;

  /// `$font-size-regular`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeRegular;

  /// `$font-size-header-1`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeHeading1;

  /// `$font-size-header-2`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeHeading2;

  /// `$font-size-header-3`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeHeading3;

  /// `$font-size-header-4`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeHeading4;

  /// `$font-size-header-5`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeHeading5;

  /// `$font-size-header-6`, packages/semi-theme-default/scss/variables.scss.
  final double fontSizeHeading6;

  /// `font-size-small` mixin, packages/semi-theme-default/scss/_font.scss: 16px line-height literal, not a Sass variable.
  final double lineHeightSmall;

  /// `font-size-regular` mixin, packages/semi-theme-default/scss/_font.scss: 20px line-height literal, not a Sass variable.
  final double lineHeightRegular;

  /// `font-size-header-1` mixin, packages/semi-theme-default/scss/_font.scss: 44px line-height literal, not a Sass variable.
  final double lineHeightHeading1;

  /// `font-size-header-2` mixin, packages/semi-theme-default/scss/_font.scss: 40px line-height literal, not a Sass variable.
  final double lineHeightHeading2;

  /// `font-size-header-3` mixin, packages/semi-theme-default/scss/_font.scss: 32px line-height literal, not a Sass variable.
  final double lineHeightHeading3;

  /// `font-size-header-4` mixin, packages/semi-theme-default/scss/_font.scss: 28px line-height literal, not a Sass variable.
  final double lineHeightHeading4;

  /// `font-size-header-5` mixin, packages/semi-theme-default/scss/_font.scss: 24px line-height literal, not a Sass variable.
  final double lineHeightHeading5;

  /// `font-size-header-6` mixin, packages/semi-theme-default/scss/_font.scss: 22px line-height literal, not a Sass variable.
  final double lineHeightHeading6;

  /// `$font-weight-light`, packages/semi-theme-default/scss/variables.scss; typography/variables.scss references this weight.
  final FontWeight fontWeightLight;

  /// `$font-weight-regular`, packages/semi-theme-default/scss/variables.scss; typography/variables.scss references this weight.
  final FontWeight fontWeightRegular;

  /// `$font-weight-bold`, packages/semi-theme-default/scss/variables.scss; typography/variables.scss references this weight.
  final FontWeight fontWeightBold;

  /// Null retains the existing value, including fontFamily. Replace the group to clear it.
  SemiTypographyTokens copyWith({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double? fontSizeSmall,
    double? fontSizeRegular,
    double? fontSizeHeading1,
    double? fontSizeHeading2,
    double? fontSizeHeading3,
    double? fontSizeHeading4,
    double? fontSizeHeading5,
    double? fontSizeHeading6,
    double? lineHeightSmall,
    double? lineHeightRegular,
    double? lineHeightHeading1,
    double? lineHeightHeading2,
    double? lineHeightHeading3,
    double? lineHeightHeading4,
    double? lineHeightHeading5,
    double? lineHeightHeading6,
    FontWeight? fontWeightLight,
    FontWeight? fontWeightRegular,
    FontWeight? fontWeightBold,
  }) => SemiTypographyTokens(
    fontFamily: fontFamily ?? this.fontFamily,
    fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
    fontSizeSmall: fontSizeSmall ?? this.fontSizeSmall,
    fontSizeRegular: fontSizeRegular ?? this.fontSizeRegular,
    fontSizeHeading1: fontSizeHeading1 ?? this.fontSizeHeading1,
    fontSizeHeading2: fontSizeHeading2 ?? this.fontSizeHeading2,
    fontSizeHeading3: fontSizeHeading3 ?? this.fontSizeHeading3,
    fontSizeHeading4: fontSizeHeading4 ?? this.fontSizeHeading4,
    fontSizeHeading5: fontSizeHeading5 ?? this.fontSizeHeading5,
    fontSizeHeading6: fontSizeHeading6 ?? this.fontSizeHeading6,
    lineHeightSmall: lineHeightSmall ?? this.lineHeightSmall,
    lineHeightRegular: lineHeightRegular ?? this.lineHeightRegular,
    lineHeightHeading1: lineHeightHeading1 ?? this.lineHeightHeading1,
    lineHeightHeading2: lineHeightHeading2 ?? this.lineHeightHeading2,
    lineHeightHeading3: lineHeightHeading3 ?? this.lineHeightHeading3,
    lineHeightHeading4: lineHeightHeading4 ?? this.lineHeightHeading4,
    lineHeightHeading5: lineHeightHeading5 ?? this.lineHeightHeading5,
    lineHeightHeading6: lineHeightHeading6 ?? this.lineHeightHeading6,
    fontWeightLight: fontWeightLight ?? this.fontWeightLight,
    fontWeightRegular: fontWeightRegular ?? this.fontWeightRegular,
    fontWeightBold: fontWeightBold ?? this.fontWeightBold,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiTypographyTokens &&
          fontFamily == other.fontFamily &&
          listEquals(fontFamilyFallback, other.fontFamilyFallback) &&
          fontSizeSmall == other.fontSizeSmall &&
          fontSizeRegular == other.fontSizeRegular &&
          fontSizeHeading1 == other.fontSizeHeading1 &&
          fontSizeHeading2 == other.fontSizeHeading2 &&
          fontSizeHeading3 == other.fontSizeHeading3 &&
          fontSizeHeading4 == other.fontSizeHeading4 &&
          fontSizeHeading5 == other.fontSizeHeading5 &&
          fontSizeHeading6 == other.fontSizeHeading6 &&
          lineHeightSmall == other.lineHeightSmall &&
          lineHeightRegular == other.lineHeightRegular &&
          lineHeightHeading1 == other.lineHeightHeading1 &&
          lineHeightHeading2 == other.lineHeightHeading2 &&
          lineHeightHeading3 == other.lineHeightHeading3 &&
          lineHeightHeading4 == other.lineHeightHeading4 &&
          lineHeightHeading5 == other.lineHeightHeading5 &&
          lineHeightHeading6 == other.lineHeightHeading6 &&
          fontWeightLight == other.fontWeightLight &&
          fontWeightRegular == other.fontWeightRegular &&
          fontWeightBold == other.fontWeightBold;
  @override
  int get hashCode => Object.hashAll([
    fontFamily,
    Object.hashAll(fontFamilyFallback),
    fontSizeSmall,
    fontSizeRegular,
    fontSizeHeading1,
    fontSizeHeading2,
    fontSizeHeading3,
    fontSizeHeading4,
    fontSizeHeading5,
    fontSizeHeading6,
    lineHeightSmall,
    lineHeightRegular,
    lineHeightHeading1,
    lineHeightHeading2,
    lineHeightHeading3,
    lineHeightHeading4,
    lineHeightHeading5,
    lineHeightHeading6,
    fontWeightLight,
    fontWeightRegular,
    fontWeightBold,
  ]);
}
