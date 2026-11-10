import 'package:flutter/widgets.dart';

import 'semi_theme_data.dart';

/// Nullable overrides; null keeps inheritance and live global token defaults.
@immutable
class SemiTypographyThemeData {
  const SemiTypographyThemeData({
    this.defaultTextColor,
    this.secondaryTextColor,
    this.tertiaryTextColor,
    this.quaternaryTextColor,
    this.warningTextColor,
    this.dangerTextColor,
    this.successTextColor,
    this.disabledTextColor,
    this.markBackgroundColor,
    this.codeBackgroundColor,
    this.codeTextColor,
    this.linkTextColor,
    this.linkVisitedColor,
    this.linkHoverColor,
    this.linkActiveColor,
    this.linkDisabledColor,
    this.copiedTextColor,
    this.copiedIconColor,
    this.codeBorderColor,
    this.titleFontWeight,
    this.linkFontWeight,
    this.strongFontWeight,
    this.paragraphExtendedLineHeight,
    this.normalTextRegularFontWeight,
    this.smallTextRegularFontWeight,
    this.normalParagraphRegularFontWeight,
    this.smallParagraphRegularFontWeight,
    this.title1FontWeight,
    this.title2FontWeight,
    this.title3FontWeight,
    this.title4FontWeight,
    this.title5FontWeight,
    this.title6FontWeight,
    this.title1LightFontWeight,
    this.title2LightFontWeight,
    this.title3LightFontWeight,
    this.title4LightFontWeight,
    this.title5LightFontWeight,
    this.title6LightFontWeight,
    this.title1RegularFontWeight,
    this.title2RegularFontWeight,
    this.title3RegularFontWeight,
    this.title4RegularFontWeight,
    this.title5RegularFontWeight,
    this.title6RegularFontWeight,
    this.title1MediumFontWeight,
    this.title2MediumFontWeight,
    this.title3MediumFontWeight,
    this.title4MediumFontWeight,
    this.title5MediumFontWeight,
    this.title6MediumFontWeight,
    this.title1SemiboldFontWeight,
    this.title2SemiboldFontWeight,
    this.title3SemiboldFontWeight,
    this.title4SemiboldFontWeight,
    this.title5SemiboldFontWeight,
    this.title6SemiboldFontWeight,
    this.title1BoldFontWeight,
    this.title2BoldFontWeight,
    this.title3BoldFontWeight,
    this.title4BoldFontWeight,
    this.title5BoldFontWeight,
    this.title6BoldFontWeight,
    this.iconPrefixMarginRight,
    this.expandTextMarginLeft,
    this.copyIconMarginLeft,
    this.copyIconPadding,
    this.titleH1Margin,
    this.titleH2Margin,
    this.titleH3Margin,
    this.titleH4Margin,
    this.titleH5Margin,
    this.titleH6Margin,
    this.titleParagraphMargin,
    this.codeBorderWidth,
    this.linkBorderWidth,
    this.codeBorderRadius,
    this.fontSizeRegular,
    this.fontSizeSmall,
    this.lineHeightRegular,
    this.lineHeightSmall,
    this.fontSizeHeading1,
    this.lineHeightHeading1,
    this.fontSizeHeading2,
    this.lineHeightHeading2,
    this.fontSizeHeading3,
    this.lineHeightHeading3,
    this.fontSizeHeading4,
    this.lineHeightHeading4,
    this.fontSizeHeading5,
    this.lineHeightHeading5,
    this.fontSizeHeading6,
    this.lineHeightHeading6,
    this.codePadding,
  });

  /// `$color-typography_default-text-default` defaults to `var(--semi-color-text-0)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? defaultTextColor;

  /// `$color-typography_secondary-text-default` defaults to `var(--semi-color-text-1)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? secondaryTextColor;

  /// `$color-typography_tertiary-text-default` defaults to `var(--semi-color-text-2)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? tertiaryTextColor;

  /// `$color-typography_quaternary-text-default` defaults to `var(--semi-color-text-3)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? quaternaryTextColor;

  /// `$color-typography_warning-text-default` defaults to `var(--semi-color-warning)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? warningTextColor;

  /// `$color-typography_danger-text-default` defaults to `var(--semi-color-danger)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? dangerTextColor;

  /// `$color-typography_success-text-default` defaults to `var(--semi-color-success)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? successTextColor;

  /// `$color-typography_disabled-text-default` defaults to `var(--semi-color-disabled-text)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? disabledTextColor;

  /// `$color-typography_mark-bg-default` defaults to `var(--semi-color-primary-light-default)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? markBackgroundColor;

  /// `$color-typography_code-bg-default` defaults to `var(--semi-color-fill-1)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? codeBackgroundColor;

  /// `$color-typography_code-text-default` defaults to `var(--semi-color-text-2)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? codeTextColor;

  /// `$color-typography_link-text-default` defaults to `var(--semi-color-link)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkTextColor;

  /// `$color-typography_link-text-visited` defaults to `var(--semi-color-link-visited)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkVisitedColor;

  /// `$color-typography_link-text-hover` defaults to `var(--semi-color-link-hover)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkHoverColor;

  /// `$color-typography_link-text-active` defaults to `var(--semi-color-link-active)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkActiveColor;

  /// `$color-typography_link-text-disabled` defaults to `var(--semi-color-link)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkDisabledColor;

  /// `$color-typography_copied-text-success` defaults to `var(--semi-color-text-2)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? copiedTextColor;

  /// `$color-typography_copied-icon-success` defaults to `var(--semi-color-success)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? copiedIconColor;

  /// `$color-typography_code-border-default` defaults to `var(--semi-color-border)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? codeBorderColor;

  /// `$font-typography_title-fontWeight` defaults to `$font-weight-bold`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? titleFontWeight;

  /// `$font-typography_link-fontWeight` defaults to `$font-weight-bold`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? linkFontWeight;

  /// `$font-typography_strong-fontWeight` defaults to `$font-weight-bold`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? strongFontWeight;

  /// `$font-typography_paragraph_extended-lineHeight` defaults to `24px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? paragraphExtendedLineHeight;

  /// `$font-typography_normalText-regular-fontWeight` defaults to `$font-weight-regular`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? normalTextRegularFontWeight;

  /// `$font-typography_smallText-regular-fontWeight` defaults to `$font-weight-regular`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? smallTextRegularFontWeight;

  /// `$font-typography_normalParagraph-regular-fontWeight` defaults to `$font-weight-regular`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? normalParagraphRegularFontWeight;

  /// `$font-typography_smallParagraph-regular-fontWeight` defaults to `$font-weight-regular`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? smallParagraphRegularFontWeight;

  /// `$font-typography_title1-fontWeight` defaults to `$font-typography_title-fontWeight`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title1FontWeight;

  /// `$font-typography_title2-fontWeight` defaults to `$font-typography_title-fontWeight`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title2FontWeight;

  /// `$font-typography_title3-fontWeight` defaults to `$font-typography_title-fontWeight`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title3FontWeight;

  /// `$font-typography_title4-fontWeight` defaults to `$font-typography_title-fontWeight`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title4FontWeight;

  /// `$font-typography_title5-fontWeight` defaults to `$font-typography_title-fontWeight`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title5FontWeight;

  /// `$font-typography_title6-fontWeight` defaults to `$font-typography_title-fontWeight`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title6FontWeight;

  /// `$font-typography_title1-light-fontWeight` defaults to `200`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title1LightFontWeight;

  /// `$font-typography_title2-light-fontWeight` defaults to `200`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title2LightFontWeight;

  /// `$font-typography_title3-light-fontWeight` defaults to `200`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title3LightFontWeight;

  /// `$font-typography_title4-light-fontWeight` defaults to `200`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title4LightFontWeight;

  /// `$font-typography_title5-light-fontWeight` defaults to `200`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title5LightFontWeight;

  /// `$font-typography_title6-light-fontWeight` defaults to `200`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title6LightFontWeight;

  /// `$font-typography_title1-regular-fontWeight` defaults to `400`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title1RegularFontWeight;

  /// `$font-typography_title2-regular-fontWeight` defaults to `400`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title2RegularFontWeight;

  /// `$font-typography_title3-regular-fontWeight` defaults to `400`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title3RegularFontWeight;

  /// `$font-typography_title4-regular-fontWeight` defaults to `400`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title4RegularFontWeight;

  /// `$font-typography_title5-regular-fontWeight` defaults to `400`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title5RegularFontWeight;

  /// `$font-typography_title6-regular-fontWeight` defaults to `400`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title6RegularFontWeight;

  /// `$font-typography_title1-medium-fontWeight` defaults to `500`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title1MediumFontWeight;

  /// `$font-typography_title2-medium-fontWeight` defaults to `500`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title2MediumFontWeight;

  /// `$font-typography_title3-medium-fontWeight` defaults to `500`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title3MediumFontWeight;

  /// `$font-typography_title4-medium-fontWeight` defaults to `500`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title4MediumFontWeight;

  /// `$font-typography_title5-medium-fontWeight` defaults to `500`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title5MediumFontWeight;

  /// `$font-typography_title6-medium-fontWeight` defaults to `500`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title6MediumFontWeight;

  /// `$font-typography_title1-semibold-fontWeight` defaults to `600`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title1SemiboldFontWeight;

  /// `$font-typography_title2-semibold-fontWeight` defaults to `600`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title2SemiboldFontWeight;

  /// `$font-typography_title3-semibold-fontWeight` defaults to `600`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title3SemiboldFontWeight;

  /// `$font-typography_title4-semibold-fontWeight` defaults to `600`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title4SemiboldFontWeight;

  /// `$font-typography_title5-semibold-fontWeight` defaults to `600`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title5SemiboldFontWeight;

  /// `$font-typography_title6-semibold-fontWeight` defaults to `600`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title6SemiboldFontWeight;

  /// `$font-typography_title1-bold-fontWeight` defaults to `700`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title1BoldFontWeight;

  /// `$font-typography_title2-bold-fontWeight` defaults to `700`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title2BoldFontWeight;

  /// `$font-typography_title3-bold-fontWeight` defaults to `700`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title3BoldFontWeight;

  /// `$font-typography_title4-bold-fontWeight` defaults to `700`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title4BoldFontWeight;

  /// `$font-typography_title5-bold-fontWeight` defaults to `700`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title5BoldFontWeight;

  /// `$font-typography_title6-bold-fontWeight` defaults to `700`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final FontWeight? title6BoldFontWeight;

  /// `$spacing-typography_iconPrefix-marginRight` defaults to `4px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? iconPrefixMarginRight;

  /// `$spacing-typography_expandText-marginLeft` defaults to `8px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? expandTextMarginLeft;

  /// `$spacing-typography_copyIcon-marginLeft` defaults to `4px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? copyIconMarginLeft;

  /// `$spacing-typography_copyIcon-padding` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? copyIconPadding;

  /// `$spacing-typography_title_h1-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleH1Margin;

  /// `$spacing-typography_title_h2-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleH2Margin;

  /// `$spacing-typography_title_h3-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleH3Margin;

  /// `$spacing-typography_title_h4-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleH4Margin;

  /// `$spacing-typography_title_h5-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleH5Margin;

  /// `$spacing-typography_title_h6-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleH6Margin;

  /// `$spacing-typography_title_paragraph-margin` defaults to `0`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final EdgeInsets? titleParagraphMargin;

  /// `$width-typography_code-border` defaults to `1px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? codeBorderWidth;

  /// `$width-typography_link-border` defaults to `1px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? linkBorderWidth;

  /// `$radius-typography_code` defaults to `2px`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final double? codeBorderRadius;

  /// font-size-regular mixin; live global SemiTypographyTokens.fontSizeRegular.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeRegular;

  /// font-size-small mixin; live global SemiTypographyTokens.fontSizeSmall.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeSmall;

  /// font-size-regular mixin; live global SemiTypographyTokens.lineHeightRegular.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightRegular;

  /// font-size-small mixin; live global SemiTypographyTokens.lineHeightSmall.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightSmall;

  /// font-size-header-1 mixin; live global SemiTypographyTokens.fontSizeHeading1.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeHeading1;

  /// font-size-header-1 mixin; live global SemiTypographyTokens.lineHeightHeading1.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightHeading1;

  /// font-size-header-2 mixin; live global SemiTypographyTokens.fontSizeHeading2.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeHeading2;

  /// font-size-header-2 mixin; live global SemiTypographyTokens.lineHeightHeading2.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightHeading2;

  /// font-size-header-3 mixin; live global SemiTypographyTokens.fontSizeHeading3.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeHeading3;

  /// font-size-header-3 mixin; live global SemiTypographyTokens.lineHeightHeading3.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightHeading3;

  /// font-size-header-4 mixin; live global SemiTypographyTokens.fontSizeHeading4.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeHeading4;

  /// font-size-header-4 mixin; live global SemiTypographyTokens.lineHeightHeading4.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightHeading4;

  /// font-size-header-5 mixin; live global SemiTypographyTokens.fontSizeHeading5.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeHeading5;

  /// font-size-header-5 mixin; live global SemiTypographyTokens.lineHeightHeading5.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightHeading5;

  /// font-size-header-6 mixin; live global SemiTypographyTokens.fontSizeHeading6.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? fontSizeHeading6;

  /// font-size-header-6 mixin; live global SemiTypographyTokens.lineHeightHeading6.
  /// Consumed in `packages/semi-foundation/typography/typography.scss`;
  /// defined in `packages/semi-theme-default/scss/_font.scss` (sizes reference variables.scss).
  final double? lineHeightHeading6;

  /// `$spacing-super-tight $spacing-extra-tight` defaults to `2px 4px`.
  /// Source: `packages/semi-foundation/typography/typography.scss`.
  final EdgeInsets? codePadding;

  /// Null arguments preserve overrides. Use a new configuration to reset.
  SemiTypographyThemeData copyWith({
    Color? defaultTextColor,
    Color? secondaryTextColor,
    Color? tertiaryTextColor,
    Color? quaternaryTextColor,
    Color? warningTextColor,
    Color? dangerTextColor,
    Color? successTextColor,
    Color? disabledTextColor,
    Color? markBackgroundColor,
    Color? codeBackgroundColor,
    Color? codeTextColor,
    Color? linkTextColor,
    Color? linkVisitedColor,
    Color? linkHoverColor,
    Color? linkActiveColor,
    Color? linkDisabledColor,
    Color? copiedTextColor,
    Color? copiedIconColor,
    Color? codeBorderColor,
    FontWeight? titleFontWeight,
    FontWeight? linkFontWeight,
    FontWeight? strongFontWeight,
    double? paragraphExtendedLineHeight,
    FontWeight? normalTextRegularFontWeight,
    FontWeight? smallTextRegularFontWeight,
    FontWeight? normalParagraphRegularFontWeight,
    FontWeight? smallParagraphRegularFontWeight,
    FontWeight? title1FontWeight,
    FontWeight? title2FontWeight,
    FontWeight? title3FontWeight,
    FontWeight? title4FontWeight,
    FontWeight? title5FontWeight,
    FontWeight? title6FontWeight,
    FontWeight? title1LightFontWeight,
    FontWeight? title2LightFontWeight,
    FontWeight? title3LightFontWeight,
    FontWeight? title4LightFontWeight,
    FontWeight? title5LightFontWeight,
    FontWeight? title6LightFontWeight,
    FontWeight? title1RegularFontWeight,
    FontWeight? title2RegularFontWeight,
    FontWeight? title3RegularFontWeight,
    FontWeight? title4RegularFontWeight,
    FontWeight? title5RegularFontWeight,
    FontWeight? title6RegularFontWeight,
    FontWeight? title1MediumFontWeight,
    FontWeight? title2MediumFontWeight,
    FontWeight? title3MediumFontWeight,
    FontWeight? title4MediumFontWeight,
    FontWeight? title5MediumFontWeight,
    FontWeight? title6MediumFontWeight,
    FontWeight? title1SemiboldFontWeight,
    FontWeight? title2SemiboldFontWeight,
    FontWeight? title3SemiboldFontWeight,
    FontWeight? title4SemiboldFontWeight,
    FontWeight? title5SemiboldFontWeight,
    FontWeight? title6SemiboldFontWeight,
    FontWeight? title1BoldFontWeight,
    FontWeight? title2BoldFontWeight,
    FontWeight? title3BoldFontWeight,
    FontWeight? title4BoldFontWeight,
    FontWeight? title5BoldFontWeight,
    FontWeight? title6BoldFontWeight,
    double? iconPrefixMarginRight,
    double? expandTextMarginLeft,
    double? copyIconMarginLeft,
    EdgeInsets? copyIconPadding,
    EdgeInsets? titleH1Margin,
    EdgeInsets? titleH2Margin,
    EdgeInsets? titleH3Margin,
    EdgeInsets? titleH4Margin,
    EdgeInsets? titleH5Margin,
    EdgeInsets? titleH6Margin,
    EdgeInsets? titleParagraphMargin,
    double? codeBorderWidth,
    double? linkBorderWidth,
    double? codeBorderRadius,
    double? fontSizeRegular,
    double? fontSizeSmall,
    double? lineHeightRegular,
    double? lineHeightSmall,
    double? fontSizeHeading1,
    double? lineHeightHeading1,
    double? fontSizeHeading2,
    double? lineHeightHeading2,
    double? fontSizeHeading3,
    double? lineHeightHeading3,
    double? fontSizeHeading4,
    double? lineHeightHeading4,
    double? fontSizeHeading5,
    double? lineHeightHeading5,
    double? fontSizeHeading6,
    double? lineHeightHeading6,
    EdgeInsets? codePadding,
  }) => SemiTypographyThemeData(
    defaultTextColor: defaultTextColor ?? this.defaultTextColor,
    secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
    tertiaryTextColor: tertiaryTextColor ?? this.tertiaryTextColor,
    quaternaryTextColor: quaternaryTextColor ?? this.quaternaryTextColor,
    warningTextColor: warningTextColor ?? this.warningTextColor,
    dangerTextColor: dangerTextColor ?? this.dangerTextColor,
    successTextColor: successTextColor ?? this.successTextColor,
    disabledTextColor: disabledTextColor ?? this.disabledTextColor,
    markBackgroundColor: markBackgroundColor ?? this.markBackgroundColor,
    codeBackgroundColor: codeBackgroundColor ?? this.codeBackgroundColor,
    codeTextColor: codeTextColor ?? this.codeTextColor,
    linkTextColor: linkTextColor ?? this.linkTextColor,
    linkVisitedColor: linkVisitedColor ?? this.linkVisitedColor,
    linkHoverColor: linkHoverColor ?? this.linkHoverColor,
    linkActiveColor: linkActiveColor ?? this.linkActiveColor,
    linkDisabledColor: linkDisabledColor ?? this.linkDisabledColor,
    copiedTextColor: copiedTextColor ?? this.copiedTextColor,
    copiedIconColor: copiedIconColor ?? this.copiedIconColor,
    codeBorderColor: codeBorderColor ?? this.codeBorderColor,
    titleFontWeight: titleFontWeight ?? this.titleFontWeight,
    linkFontWeight: linkFontWeight ?? this.linkFontWeight,
    strongFontWeight: strongFontWeight ?? this.strongFontWeight,
    paragraphExtendedLineHeight:
        paragraphExtendedLineHeight ?? this.paragraphExtendedLineHeight,
    normalTextRegularFontWeight:
        normalTextRegularFontWeight ?? this.normalTextRegularFontWeight,
    smallTextRegularFontWeight:
        smallTextRegularFontWeight ?? this.smallTextRegularFontWeight,
    normalParagraphRegularFontWeight:
        normalParagraphRegularFontWeight ??
        this.normalParagraphRegularFontWeight,
    smallParagraphRegularFontWeight:
        smallParagraphRegularFontWeight ?? this.smallParagraphRegularFontWeight,
    title1FontWeight: title1FontWeight ?? this.title1FontWeight,
    title2FontWeight: title2FontWeight ?? this.title2FontWeight,
    title3FontWeight: title3FontWeight ?? this.title3FontWeight,
    title4FontWeight: title4FontWeight ?? this.title4FontWeight,
    title5FontWeight: title5FontWeight ?? this.title5FontWeight,
    title6FontWeight: title6FontWeight ?? this.title6FontWeight,
    title1LightFontWeight: title1LightFontWeight ?? this.title1LightFontWeight,
    title2LightFontWeight: title2LightFontWeight ?? this.title2LightFontWeight,
    title3LightFontWeight: title3LightFontWeight ?? this.title3LightFontWeight,
    title4LightFontWeight: title4LightFontWeight ?? this.title4LightFontWeight,
    title5LightFontWeight: title5LightFontWeight ?? this.title5LightFontWeight,
    title6LightFontWeight: title6LightFontWeight ?? this.title6LightFontWeight,
    title1RegularFontWeight:
        title1RegularFontWeight ?? this.title1RegularFontWeight,
    title2RegularFontWeight:
        title2RegularFontWeight ?? this.title2RegularFontWeight,
    title3RegularFontWeight:
        title3RegularFontWeight ?? this.title3RegularFontWeight,
    title4RegularFontWeight:
        title4RegularFontWeight ?? this.title4RegularFontWeight,
    title5RegularFontWeight:
        title5RegularFontWeight ?? this.title5RegularFontWeight,
    title6RegularFontWeight:
        title6RegularFontWeight ?? this.title6RegularFontWeight,
    title1MediumFontWeight:
        title1MediumFontWeight ?? this.title1MediumFontWeight,
    title2MediumFontWeight:
        title2MediumFontWeight ?? this.title2MediumFontWeight,
    title3MediumFontWeight:
        title3MediumFontWeight ?? this.title3MediumFontWeight,
    title4MediumFontWeight:
        title4MediumFontWeight ?? this.title4MediumFontWeight,
    title5MediumFontWeight:
        title5MediumFontWeight ?? this.title5MediumFontWeight,
    title6MediumFontWeight:
        title6MediumFontWeight ?? this.title6MediumFontWeight,
    title1SemiboldFontWeight:
        title1SemiboldFontWeight ?? this.title1SemiboldFontWeight,
    title2SemiboldFontWeight:
        title2SemiboldFontWeight ?? this.title2SemiboldFontWeight,
    title3SemiboldFontWeight:
        title3SemiboldFontWeight ?? this.title3SemiboldFontWeight,
    title4SemiboldFontWeight:
        title4SemiboldFontWeight ?? this.title4SemiboldFontWeight,
    title5SemiboldFontWeight:
        title5SemiboldFontWeight ?? this.title5SemiboldFontWeight,
    title6SemiboldFontWeight:
        title6SemiboldFontWeight ?? this.title6SemiboldFontWeight,
    title1BoldFontWeight: title1BoldFontWeight ?? this.title1BoldFontWeight,
    title2BoldFontWeight: title2BoldFontWeight ?? this.title2BoldFontWeight,
    title3BoldFontWeight: title3BoldFontWeight ?? this.title3BoldFontWeight,
    title4BoldFontWeight: title4BoldFontWeight ?? this.title4BoldFontWeight,
    title5BoldFontWeight: title5BoldFontWeight ?? this.title5BoldFontWeight,
    title6BoldFontWeight: title6BoldFontWeight ?? this.title6BoldFontWeight,
    iconPrefixMarginRight: iconPrefixMarginRight ?? this.iconPrefixMarginRight,
    expandTextMarginLeft: expandTextMarginLeft ?? this.expandTextMarginLeft,
    copyIconMarginLeft: copyIconMarginLeft ?? this.copyIconMarginLeft,
    copyIconPadding: copyIconPadding ?? this.copyIconPadding,
    titleH1Margin: titleH1Margin ?? this.titleH1Margin,
    titleH2Margin: titleH2Margin ?? this.titleH2Margin,
    titleH3Margin: titleH3Margin ?? this.titleH3Margin,
    titleH4Margin: titleH4Margin ?? this.titleH4Margin,
    titleH5Margin: titleH5Margin ?? this.titleH5Margin,
    titleH6Margin: titleH6Margin ?? this.titleH6Margin,
    titleParagraphMargin: titleParagraphMargin ?? this.titleParagraphMargin,
    codeBorderWidth: codeBorderWidth ?? this.codeBorderWidth,
    linkBorderWidth: linkBorderWidth ?? this.linkBorderWidth,
    codeBorderRadius: codeBorderRadius ?? this.codeBorderRadius,
    fontSizeRegular: fontSizeRegular ?? this.fontSizeRegular,
    fontSizeSmall: fontSizeSmall ?? this.fontSizeSmall,
    lineHeightRegular: lineHeightRegular ?? this.lineHeightRegular,
    lineHeightSmall: lineHeightSmall ?? this.lineHeightSmall,
    fontSizeHeading1: fontSizeHeading1 ?? this.fontSizeHeading1,
    lineHeightHeading1: lineHeightHeading1 ?? this.lineHeightHeading1,
    fontSizeHeading2: fontSizeHeading2 ?? this.fontSizeHeading2,
    lineHeightHeading2: lineHeightHeading2 ?? this.lineHeightHeading2,
    fontSizeHeading3: fontSizeHeading3 ?? this.fontSizeHeading3,
    lineHeightHeading3: lineHeightHeading3 ?? this.lineHeightHeading3,
    fontSizeHeading4: fontSizeHeading4 ?? this.fontSizeHeading4,
    lineHeightHeading4: lineHeightHeading4 ?? this.lineHeightHeading4,
    fontSizeHeading5: fontSizeHeading5 ?? this.fontSizeHeading5,
    lineHeightHeading5: lineHeightHeading5 ?? this.lineHeightHeading5,
    fontSizeHeading6: fontSizeHeading6 ?? this.fontSizeHeading6,
    lineHeightHeading6: lineHeightHeading6 ?? this.lineHeightHeading6,
    codePadding: codePadding ?? this.codePadding,
  );

  /// Applies only non-null fields from [patch].
  SemiTypographyThemeData merge(SemiTypographyThemeData patch) => copyWith(
    defaultTextColor: patch.defaultTextColor,
    secondaryTextColor: patch.secondaryTextColor,
    tertiaryTextColor: patch.tertiaryTextColor,
    quaternaryTextColor: patch.quaternaryTextColor,
    warningTextColor: patch.warningTextColor,
    dangerTextColor: patch.dangerTextColor,
    successTextColor: patch.successTextColor,
    disabledTextColor: patch.disabledTextColor,
    markBackgroundColor: patch.markBackgroundColor,
    codeBackgroundColor: patch.codeBackgroundColor,
    codeTextColor: patch.codeTextColor,
    linkTextColor: patch.linkTextColor,
    linkVisitedColor: patch.linkVisitedColor,
    linkHoverColor: patch.linkHoverColor,
    linkActiveColor: patch.linkActiveColor,
    linkDisabledColor: patch.linkDisabledColor,
    copiedTextColor: patch.copiedTextColor,
    copiedIconColor: patch.copiedIconColor,
    codeBorderColor: patch.codeBorderColor,
    titleFontWeight: patch.titleFontWeight,
    linkFontWeight: patch.linkFontWeight,
    strongFontWeight: patch.strongFontWeight,
    paragraphExtendedLineHeight: patch.paragraphExtendedLineHeight,
    normalTextRegularFontWeight: patch.normalTextRegularFontWeight,
    smallTextRegularFontWeight: patch.smallTextRegularFontWeight,
    normalParagraphRegularFontWeight: patch.normalParagraphRegularFontWeight,
    smallParagraphRegularFontWeight: patch.smallParagraphRegularFontWeight,
    title1FontWeight: patch.title1FontWeight,
    title2FontWeight: patch.title2FontWeight,
    title3FontWeight: patch.title3FontWeight,
    title4FontWeight: patch.title4FontWeight,
    title5FontWeight: patch.title5FontWeight,
    title6FontWeight: patch.title6FontWeight,
    title1LightFontWeight: patch.title1LightFontWeight,
    title2LightFontWeight: patch.title2LightFontWeight,
    title3LightFontWeight: patch.title3LightFontWeight,
    title4LightFontWeight: patch.title4LightFontWeight,
    title5LightFontWeight: patch.title5LightFontWeight,
    title6LightFontWeight: patch.title6LightFontWeight,
    title1RegularFontWeight: patch.title1RegularFontWeight,
    title2RegularFontWeight: patch.title2RegularFontWeight,
    title3RegularFontWeight: patch.title3RegularFontWeight,
    title4RegularFontWeight: patch.title4RegularFontWeight,
    title5RegularFontWeight: patch.title5RegularFontWeight,
    title6RegularFontWeight: patch.title6RegularFontWeight,
    title1MediumFontWeight: patch.title1MediumFontWeight,
    title2MediumFontWeight: patch.title2MediumFontWeight,
    title3MediumFontWeight: patch.title3MediumFontWeight,
    title4MediumFontWeight: patch.title4MediumFontWeight,
    title5MediumFontWeight: patch.title5MediumFontWeight,
    title6MediumFontWeight: patch.title6MediumFontWeight,
    title1SemiboldFontWeight: patch.title1SemiboldFontWeight,
    title2SemiboldFontWeight: patch.title2SemiboldFontWeight,
    title3SemiboldFontWeight: patch.title3SemiboldFontWeight,
    title4SemiboldFontWeight: patch.title4SemiboldFontWeight,
    title5SemiboldFontWeight: patch.title5SemiboldFontWeight,
    title6SemiboldFontWeight: patch.title6SemiboldFontWeight,
    title1BoldFontWeight: patch.title1BoldFontWeight,
    title2BoldFontWeight: patch.title2BoldFontWeight,
    title3BoldFontWeight: patch.title3BoldFontWeight,
    title4BoldFontWeight: patch.title4BoldFontWeight,
    title5BoldFontWeight: patch.title5BoldFontWeight,
    title6BoldFontWeight: patch.title6BoldFontWeight,
    iconPrefixMarginRight: patch.iconPrefixMarginRight,
    expandTextMarginLeft: patch.expandTextMarginLeft,
    copyIconMarginLeft: patch.copyIconMarginLeft,
    copyIconPadding: patch.copyIconPadding,
    titleH1Margin: patch.titleH1Margin,
    titleH2Margin: patch.titleH2Margin,
    titleH3Margin: patch.titleH3Margin,
    titleH4Margin: patch.titleH4Margin,
    titleH5Margin: patch.titleH5Margin,
    titleH6Margin: patch.titleH6Margin,
    titleParagraphMargin: patch.titleParagraphMargin,
    codeBorderWidth: patch.codeBorderWidth,
    linkBorderWidth: patch.linkBorderWidth,
    codeBorderRadius: patch.codeBorderRadius,
    fontSizeRegular: patch.fontSizeRegular,
    fontSizeSmall: patch.fontSizeSmall,
    lineHeightRegular: patch.lineHeightRegular,
    lineHeightSmall: patch.lineHeightSmall,
    fontSizeHeading1: patch.fontSizeHeading1,
    lineHeightHeading1: patch.lineHeightHeading1,
    fontSizeHeading2: patch.fontSizeHeading2,
    lineHeightHeading2: patch.lineHeightHeading2,
    fontSizeHeading3: patch.fontSizeHeading3,
    lineHeightHeading3: patch.lineHeightHeading3,
    fontSizeHeading4: patch.fontSizeHeading4,
    lineHeightHeading4: patch.lineHeightHeading4,
    fontSizeHeading5: patch.fontSizeHeading5,
    lineHeightHeading5: patch.lineHeightHeading5,
    fontSizeHeading6: patch.fontSizeHeading6,
    lineHeightHeading6: patch.lineHeightHeading6,
    codePadding: patch.codePadding,
  );
  SemiResolvedTypographyThemeData resolve(SemiThemeData theme) {
    final c = theme.colors;
    return SemiResolvedTypographyThemeData(
      defaultTextColor: defaultTextColor ?? c.colorText0,
      secondaryTextColor: secondaryTextColor ?? c.colorText1,
      tertiaryTextColor: tertiaryTextColor ?? c.colorText2,
      quaternaryTextColor: quaternaryTextColor ?? c.colorText3,
      warningTextColor: warningTextColor ?? c.colorWarning,
      dangerTextColor: dangerTextColor ?? c.colorDanger,
      successTextColor: successTextColor ?? c.colorSuccess,
      disabledTextColor: disabledTextColor ?? c.colorDisabledText,
      markBackgroundColor: markBackgroundColor ?? c.colorPrimaryLightDefault,
      codeBackgroundColor: codeBackgroundColor ?? c.colorFill1,
      codeTextColor: codeTextColor ?? c.colorText2,
      linkTextColor: linkTextColor ?? c.colorLink,
      linkVisitedColor: linkVisitedColor ?? c.colorLinkVisited,
      linkHoverColor: linkHoverColor ?? c.colorLinkHover,
      linkActiveColor: linkActiveColor ?? c.colorLinkActive,
      linkDisabledColor: linkDisabledColor ?? c.colorLink,
      copiedTextColor: copiedTextColor ?? c.colorText2,
      copiedIconColor: copiedIconColor ?? c.colorSuccess,
      codeBorderColor: codeBorderColor ?? c.colorBorder,
      titleFontWeight: titleFontWeight ?? theme.typography.fontWeightBold,
      linkFontWeight: linkFontWeight ?? theme.typography.fontWeightBold,
      strongFontWeight: strongFontWeight ?? theme.typography.fontWeightBold,
      paragraphExtendedLineHeight: paragraphExtendedLineHeight ?? 24.0,
      normalTextRegularFontWeight:
          normalTextRegularFontWeight ?? theme.typography.fontWeightRegular,
      smallTextRegularFontWeight:
          smallTextRegularFontWeight ?? theme.typography.fontWeightRegular,
      normalParagraphRegularFontWeight:
          normalParagraphRegularFontWeight ??
          theme.typography.fontWeightRegular,
      smallParagraphRegularFontWeight:
          smallParagraphRegularFontWeight ?? theme.typography.fontWeightRegular,
      title1FontWeight:
          title1FontWeight ??
          titleFontWeight ??
          theme.typography.fontWeightBold,
      title2FontWeight:
          title2FontWeight ??
          titleFontWeight ??
          theme.typography.fontWeightBold,
      title3FontWeight:
          title3FontWeight ??
          titleFontWeight ??
          theme.typography.fontWeightBold,
      title4FontWeight:
          title4FontWeight ??
          titleFontWeight ??
          theme.typography.fontWeightBold,
      title5FontWeight:
          title5FontWeight ??
          titleFontWeight ??
          theme.typography.fontWeightBold,
      title6FontWeight:
          title6FontWeight ??
          titleFontWeight ??
          theme.typography.fontWeightBold,
      title1LightFontWeight: title1LightFontWeight ?? FontWeight.w200,
      title2LightFontWeight: title2LightFontWeight ?? FontWeight.w200,
      title3LightFontWeight: title3LightFontWeight ?? FontWeight.w200,
      title4LightFontWeight: title4LightFontWeight ?? FontWeight.w200,
      title5LightFontWeight: title5LightFontWeight ?? FontWeight.w200,
      title6LightFontWeight: title6LightFontWeight ?? FontWeight.w200,
      title1RegularFontWeight: title1RegularFontWeight ?? FontWeight.w400,
      title2RegularFontWeight: title2RegularFontWeight ?? FontWeight.w400,
      title3RegularFontWeight: title3RegularFontWeight ?? FontWeight.w400,
      title4RegularFontWeight: title4RegularFontWeight ?? FontWeight.w400,
      title5RegularFontWeight: title5RegularFontWeight ?? FontWeight.w400,
      title6RegularFontWeight: title6RegularFontWeight ?? FontWeight.w400,
      title1MediumFontWeight: title1MediumFontWeight ?? FontWeight.w500,
      title2MediumFontWeight: title2MediumFontWeight ?? FontWeight.w500,
      title3MediumFontWeight: title3MediumFontWeight ?? FontWeight.w500,
      title4MediumFontWeight: title4MediumFontWeight ?? FontWeight.w500,
      title5MediumFontWeight: title5MediumFontWeight ?? FontWeight.w500,
      title6MediumFontWeight: title6MediumFontWeight ?? FontWeight.w500,
      title1SemiboldFontWeight: title1SemiboldFontWeight ?? FontWeight.w600,
      title2SemiboldFontWeight: title2SemiboldFontWeight ?? FontWeight.w600,
      title3SemiboldFontWeight: title3SemiboldFontWeight ?? FontWeight.w600,
      title4SemiboldFontWeight: title4SemiboldFontWeight ?? FontWeight.w600,
      title5SemiboldFontWeight: title5SemiboldFontWeight ?? FontWeight.w600,
      title6SemiboldFontWeight: title6SemiboldFontWeight ?? FontWeight.w600,
      title1BoldFontWeight: title1BoldFontWeight ?? FontWeight.w700,
      title2BoldFontWeight: title2BoldFontWeight ?? FontWeight.w700,
      title3BoldFontWeight: title3BoldFontWeight ?? FontWeight.w700,
      title4BoldFontWeight: title4BoldFontWeight ?? FontWeight.w700,
      title5BoldFontWeight: title5BoldFontWeight ?? FontWeight.w700,
      title6BoldFontWeight: title6BoldFontWeight ?? FontWeight.w700,
      iconPrefixMarginRight: iconPrefixMarginRight ?? 4.0,
      expandTextMarginLeft: expandTextMarginLeft ?? 8.0,
      copyIconMarginLeft: copyIconMarginLeft ?? 4.0,
      copyIconPadding: copyIconPadding ?? EdgeInsets.zero,
      titleH1Margin: titleH1Margin ?? EdgeInsets.zero,
      titleH2Margin: titleH2Margin ?? EdgeInsets.zero,
      titleH3Margin: titleH3Margin ?? EdgeInsets.zero,
      titleH4Margin: titleH4Margin ?? EdgeInsets.zero,
      titleH5Margin: titleH5Margin ?? EdgeInsets.zero,
      titleH6Margin: titleH6Margin ?? EdgeInsets.zero,
      titleParagraphMargin: titleParagraphMargin ?? EdgeInsets.zero,
      codeBorderWidth: codeBorderWidth ?? 1.0,
      linkBorderWidth: linkBorderWidth ?? 1.0,
      codeBorderRadius: codeBorderRadius ?? 2.0,
      fontSizeRegular: fontSizeRegular ?? theme.typography.fontSizeRegular,
      fontSizeSmall: fontSizeSmall ?? theme.typography.fontSizeSmall,
      lineHeightRegular:
          lineHeightRegular ?? theme.typography.lineHeightRegular,
      lineHeightSmall: lineHeightSmall ?? theme.typography.lineHeightSmall,
      fontSizeHeading1: fontSizeHeading1 ?? theme.typography.fontSizeHeading1,
      lineHeightHeading1:
          lineHeightHeading1 ?? theme.typography.lineHeightHeading1,
      fontSizeHeading2: fontSizeHeading2 ?? theme.typography.fontSizeHeading2,
      lineHeightHeading2:
          lineHeightHeading2 ?? theme.typography.lineHeightHeading2,
      fontSizeHeading3: fontSizeHeading3 ?? theme.typography.fontSizeHeading3,
      lineHeightHeading3:
          lineHeightHeading3 ?? theme.typography.lineHeightHeading3,
      fontSizeHeading4: fontSizeHeading4 ?? theme.typography.fontSizeHeading4,
      lineHeightHeading4:
          lineHeightHeading4 ?? theme.typography.lineHeightHeading4,
      fontSizeHeading5: fontSizeHeading5 ?? theme.typography.fontSizeHeading5,
      lineHeightHeading5:
          lineHeightHeading5 ?? theme.typography.lineHeightHeading5,
      fontSizeHeading6: fontSizeHeading6 ?? theme.typography.fontSizeHeading6,
      lineHeightHeading6:
          lineHeightHeading6 ?? theme.typography.lineHeightHeading6,
      codePadding:
          codePadding ?? const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiTypographyThemeData &&
          defaultTextColor == other.defaultTextColor &&
          secondaryTextColor == other.secondaryTextColor &&
          tertiaryTextColor == other.tertiaryTextColor &&
          quaternaryTextColor == other.quaternaryTextColor &&
          warningTextColor == other.warningTextColor &&
          dangerTextColor == other.dangerTextColor &&
          successTextColor == other.successTextColor &&
          disabledTextColor == other.disabledTextColor &&
          markBackgroundColor == other.markBackgroundColor &&
          codeBackgroundColor == other.codeBackgroundColor &&
          codeTextColor == other.codeTextColor &&
          linkTextColor == other.linkTextColor &&
          linkVisitedColor == other.linkVisitedColor &&
          linkHoverColor == other.linkHoverColor &&
          linkActiveColor == other.linkActiveColor &&
          linkDisabledColor == other.linkDisabledColor &&
          copiedTextColor == other.copiedTextColor &&
          copiedIconColor == other.copiedIconColor &&
          codeBorderColor == other.codeBorderColor &&
          titleFontWeight == other.titleFontWeight &&
          linkFontWeight == other.linkFontWeight &&
          strongFontWeight == other.strongFontWeight &&
          paragraphExtendedLineHeight == other.paragraphExtendedLineHeight &&
          normalTextRegularFontWeight == other.normalTextRegularFontWeight &&
          smallTextRegularFontWeight == other.smallTextRegularFontWeight &&
          normalParagraphRegularFontWeight ==
              other.normalParagraphRegularFontWeight &&
          smallParagraphRegularFontWeight ==
              other.smallParagraphRegularFontWeight &&
          title1FontWeight == other.title1FontWeight &&
          title2FontWeight == other.title2FontWeight &&
          title3FontWeight == other.title3FontWeight &&
          title4FontWeight == other.title4FontWeight &&
          title5FontWeight == other.title5FontWeight &&
          title6FontWeight == other.title6FontWeight &&
          title1LightFontWeight == other.title1LightFontWeight &&
          title2LightFontWeight == other.title2LightFontWeight &&
          title3LightFontWeight == other.title3LightFontWeight &&
          title4LightFontWeight == other.title4LightFontWeight &&
          title5LightFontWeight == other.title5LightFontWeight &&
          title6LightFontWeight == other.title6LightFontWeight &&
          title1RegularFontWeight == other.title1RegularFontWeight &&
          title2RegularFontWeight == other.title2RegularFontWeight &&
          title3RegularFontWeight == other.title3RegularFontWeight &&
          title4RegularFontWeight == other.title4RegularFontWeight &&
          title5RegularFontWeight == other.title5RegularFontWeight &&
          title6RegularFontWeight == other.title6RegularFontWeight &&
          title1MediumFontWeight == other.title1MediumFontWeight &&
          title2MediumFontWeight == other.title2MediumFontWeight &&
          title3MediumFontWeight == other.title3MediumFontWeight &&
          title4MediumFontWeight == other.title4MediumFontWeight &&
          title5MediumFontWeight == other.title5MediumFontWeight &&
          title6MediumFontWeight == other.title6MediumFontWeight &&
          title1SemiboldFontWeight == other.title1SemiboldFontWeight &&
          title2SemiboldFontWeight == other.title2SemiboldFontWeight &&
          title3SemiboldFontWeight == other.title3SemiboldFontWeight &&
          title4SemiboldFontWeight == other.title4SemiboldFontWeight &&
          title5SemiboldFontWeight == other.title5SemiboldFontWeight &&
          title6SemiboldFontWeight == other.title6SemiboldFontWeight &&
          title1BoldFontWeight == other.title1BoldFontWeight &&
          title2BoldFontWeight == other.title2BoldFontWeight &&
          title3BoldFontWeight == other.title3BoldFontWeight &&
          title4BoldFontWeight == other.title4BoldFontWeight &&
          title5BoldFontWeight == other.title5BoldFontWeight &&
          title6BoldFontWeight == other.title6BoldFontWeight &&
          iconPrefixMarginRight == other.iconPrefixMarginRight &&
          expandTextMarginLeft == other.expandTextMarginLeft &&
          copyIconMarginLeft == other.copyIconMarginLeft &&
          copyIconPadding == other.copyIconPadding &&
          titleH1Margin == other.titleH1Margin &&
          titleH2Margin == other.titleH2Margin &&
          titleH3Margin == other.titleH3Margin &&
          titleH4Margin == other.titleH4Margin &&
          titleH5Margin == other.titleH5Margin &&
          titleH6Margin == other.titleH6Margin &&
          titleParagraphMargin == other.titleParagraphMargin &&
          codeBorderWidth == other.codeBorderWidth &&
          linkBorderWidth == other.linkBorderWidth &&
          codeBorderRadius == other.codeBorderRadius &&
          fontSizeRegular == other.fontSizeRegular &&
          fontSizeSmall == other.fontSizeSmall &&
          lineHeightRegular == other.lineHeightRegular &&
          lineHeightSmall == other.lineHeightSmall &&
          fontSizeHeading1 == other.fontSizeHeading1 &&
          lineHeightHeading1 == other.lineHeightHeading1 &&
          fontSizeHeading2 == other.fontSizeHeading2 &&
          lineHeightHeading2 == other.lineHeightHeading2 &&
          fontSizeHeading3 == other.fontSizeHeading3 &&
          lineHeightHeading3 == other.lineHeightHeading3 &&
          fontSizeHeading4 == other.fontSizeHeading4 &&
          lineHeightHeading4 == other.lineHeightHeading4 &&
          fontSizeHeading5 == other.fontSizeHeading5 &&
          lineHeightHeading5 == other.lineHeightHeading5 &&
          fontSizeHeading6 == other.fontSizeHeading6 &&
          lineHeightHeading6 == other.lineHeightHeading6 &&
          codePadding == other.codePadding;
  @override
  int get hashCode => Object.hashAll([
    defaultTextColor,
    secondaryTextColor,
    tertiaryTextColor,
    quaternaryTextColor,
    warningTextColor,
    dangerTextColor,
    successTextColor,
    disabledTextColor,
    markBackgroundColor,
    codeBackgroundColor,
    codeTextColor,
    linkTextColor,
    linkVisitedColor,
    linkHoverColor,
    linkActiveColor,
    linkDisabledColor,
    copiedTextColor,
    copiedIconColor,
    codeBorderColor,
    titleFontWeight,
    linkFontWeight,
    strongFontWeight,
    paragraphExtendedLineHeight,
    normalTextRegularFontWeight,
    smallTextRegularFontWeight,
    normalParagraphRegularFontWeight,
    smallParagraphRegularFontWeight,
    title1FontWeight,
    title2FontWeight,
    title3FontWeight,
    title4FontWeight,
    title5FontWeight,
    title6FontWeight,
    title1LightFontWeight,
    title2LightFontWeight,
    title3LightFontWeight,
    title4LightFontWeight,
    title5LightFontWeight,
    title6LightFontWeight,
    title1RegularFontWeight,
    title2RegularFontWeight,
    title3RegularFontWeight,
    title4RegularFontWeight,
    title5RegularFontWeight,
    title6RegularFontWeight,
    title1MediumFontWeight,
    title2MediumFontWeight,
    title3MediumFontWeight,
    title4MediumFontWeight,
    title5MediumFontWeight,
    title6MediumFontWeight,
    title1SemiboldFontWeight,
    title2SemiboldFontWeight,
    title3SemiboldFontWeight,
    title4SemiboldFontWeight,
    title5SemiboldFontWeight,
    title6SemiboldFontWeight,
    title1BoldFontWeight,
    title2BoldFontWeight,
    title3BoldFontWeight,
    title4BoldFontWeight,
    title5BoldFontWeight,
    title6BoldFontWeight,
    iconPrefixMarginRight,
    expandTextMarginLeft,
    copyIconMarginLeft,
    copyIconPadding,
    titleH1Margin,
    titleH2Margin,
    titleH3Margin,
    titleH4Margin,
    titleH5Margin,
    titleH6Margin,
    titleParagraphMargin,
    codeBorderWidth,
    linkBorderWidth,
    codeBorderRadius,
    fontSizeRegular,
    fontSizeSmall,
    lineHeightRegular,
    lineHeightSmall,
    fontSizeHeading1,
    lineHeightHeading1,
    fontSizeHeading2,
    lineHeightHeading2,
    fontSizeHeading3,
    lineHeightHeading3,
    fontSizeHeading4,
    lineHeightHeading4,
    fontSizeHeading5,
    lineHeightHeading5,
    fontSizeHeading6,
    lineHeightHeading6,
    codePadding,
  ]);
}

/// Complete colors and metrics resolved against the current global tokens.
@immutable
class SemiResolvedTypographyThemeData {
  const SemiResolvedTypographyThemeData({
    required this.defaultTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
    required this.quaternaryTextColor,
    required this.warningTextColor,
    required this.dangerTextColor,
    required this.successTextColor,
    required this.disabledTextColor,
    required this.markBackgroundColor,
    required this.codeBackgroundColor,
    required this.codeTextColor,
    required this.linkTextColor,
    required this.linkVisitedColor,
    required this.linkHoverColor,
    required this.linkActiveColor,
    required this.linkDisabledColor,
    required this.copiedTextColor,
    required this.copiedIconColor,
    required this.codeBorderColor,
    required this.titleFontWeight,
    required this.linkFontWeight,
    required this.strongFontWeight,
    required this.paragraphExtendedLineHeight,
    required this.normalTextRegularFontWeight,
    required this.smallTextRegularFontWeight,
    required this.normalParagraphRegularFontWeight,
    required this.smallParagraphRegularFontWeight,
    required this.title1FontWeight,
    required this.title2FontWeight,
    required this.title3FontWeight,
    required this.title4FontWeight,
    required this.title5FontWeight,
    required this.title6FontWeight,
    required this.title1LightFontWeight,
    required this.title2LightFontWeight,
    required this.title3LightFontWeight,
    required this.title4LightFontWeight,
    required this.title5LightFontWeight,
    required this.title6LightFontWeight,
    required this.title1RegularFontWeight,
    required this.title2RegularFontWeight,
    required this.title3RegularFontWeight,
    required this.title4RegularFontWeight,
    required this.title5RegularFontWeight,
    required this.title6RegularFontWeight,
    required this.title1MediumFontWeight,
    required this.title2MediumFontWeight,
    required this.title3MediumFontWeight,
    required this.title4MediumFontWeight,
    required this.title5MediumFontWeight,
    required this.title6MediumFontWeight,
    required this.title1SemiboldFontWeight,
    required this.title2SemiboldFontWeight,
    required this.title3SemiboldFontWeight,
    required this.title4SemiboldFontWeight,
    required this.title5SemiboldFontWeight,
    required this.title6SemiboldFontWeight,
    required this.title1BoldFontWeight,
    required this.title2BoldFontWeight,
    required this.title3BoldFontWeight,
    required this.title4BoldFontWeight,
    required this.title5BoldFontWeight,
    required this.title6BoldFontWeight,
    required this.iconPrefixMarginRight,
    required this.expandTextMarginLeft,
    required this.copyIconMarginLeft,
    required this.copyIconPadding,
    required this.titleH1Margin,
    required this.titleH2Margin,
    required this.titleH3Margin,
    required this.titleH4Margin,
    required this.titleH5Margin,
    required this.titleH6Margin,
    required this.titleParagraphMargin,
    required this.codeBorderWidth,
    required this.linkBorderWidth,
    required this.codeBorderRadius,
    required this.fontSizeRegular,
    required this.fontSizeSmall,
    required this.lineHeightRegular,
    required this.lineHeightSmall,
    required this.fontSizeHeading1,
    required this.lineHeightHeading1,
    required this.fontSizeHeading2,
    required this.lineHeightHeading2,
    required this.fontSizeHeading3,
    required this.lineHeightHeading3,
    required this.fontSizeHeading4,
    required this.lineHeightHeading4,
    required this.fontSizeHeading5,
    required this.lineHeightHeading5,
    required this.fontSizeHeading6,
    required this.lineHeightHeading6,
    required this.codePadding,
  });
  final Color defaultTextColor;
  final Color secondaryTextColor;
  final Color tertiaryTextColor;
  final Color quaternaryTextColor;
  final Color warningTextColor;
  final Color dangerTextColor;
  final Color successTextColor;
  final Color disabledTextColor;
  final Color markBackgroundColor;
  final Color codeBackgroundColor;
  final Color codeTextColor;
  final Color linkTextColor;
  final Color linkVisitedColor;
  final Color linkHoverColor;
  final Color linkActiveColor;
  final Color linkDisabledColor;
  final Color copiedTextColor;
  final Color copiedIconColor;
  final Color codeBorderColor;
  final FontWeight titleFontWeight;
  final FontWeight linkFontWeight;
  final FontWeight strongFontWeight;
  final double paragraphExtendedLineHeight;
  final FontWeight normalTextRegularFontWeight;
  final FontWeight smallTextRegularFontWeight;
  final FontWeight normalParagraphRegularFontWeight;
  final FontWeight smallParagraphRegularFontWeight;
  final FontWeight title1FontWeight;
  final FontWeight title2FontWeight;
  final FontWeight title3FontWeight;
  final FontWeight title4FontWeight;
  final FontWeight title5FontWeight;
  final FontWeight title6FontWeight;
  final FontWeight title1LightFontWeight;
  final FontWeight title2LightFontWeight;
  final FontWeight title3LightFontWeight;
  final FontWeight title4LightFontWeight;
  final FontWeight title5LightFontWeight;
  final FontWeight title6LightFontWeight;
  final FontWeight title1RegularFontWeight;
  final FontWeight title2RegularFontWeight;
  final FontWeight title3RegularFontWeight;
  final FontWeight title4RegularFontWeight;
  final FontWeight title5RegularFontWeight;
  final FontWeight title6RegularFontWeight;
  final FontWeight title1MediumFontWeight;
  final FontWeight title2MediumFontWeight;
  final FontWeight title3MediumFontWeight;
  final FontWeight title4MediumFontWeight;
  final FontWeight title5MediumFontWeight;
  final FontWeight title6MediumFontWeight;
  final FontWeight title1SemiboldFontWeight;
  final FontWeight title2SemiboldFontWeight;
  final FontWeight title3SemiboldFontWeight;
  final FontWeight title4SemiboldFontWeight;
  final FontWeight title5SemiboldFontWeight;
  final FontWeight title6SemiboldFontWeight;
  final FontWeight title1BoldFontWeight;
  final FontWeight title2BoldFontWeight;
  final FontWeight title3BoldFontWeight;
  final FontWeight title4BoldFontWeight;
  final FontWeight title5BoldFontWeight;
  final FontWeight title6BoldFontWeight;
  final double iconPrefixMarginRight;
  final double expandTextMarginLeft;
  final double copyIconMarginLeft;
  final EdgeInsets copyIconPadding;
  final EdgeInsets titleH1Margin;
  final EdgeInsets titleH2Margin;
  final EdgeInsets titleH3Margin;
  final EdgeInsets titleH4Margin;
  final EdgeInsets titleH5Margin;
  final EdgeInsets titleH6Margin;
  final EdgeInsets titleParagraphMargin;
  final double codeBorderWidth;
  final double linkBorderWidth;
  final double codeBorderRadius;
  final double fontSizeRegular;
  final double fontSizeSmall;
  final double lineHeightRegular;
  final double lineHeightSmall;
  final double fontSizeHeading1;
  final double lineHeightHeading1;
  final double fontSizeHeading2;
  final double lineHeightHeading2;
  final double fontSizeHeading3;
  final double lineHeightHeading3;
  final double fontSizeHeading4;
  final double lineHeightHeading4;
  final double fontSizeHeading5;
  final double lineHeightHeading5;
  final double fontSizeHeading6;
  final double lineHeightHeading6;
  final EdgeInsets codePadding;
}
