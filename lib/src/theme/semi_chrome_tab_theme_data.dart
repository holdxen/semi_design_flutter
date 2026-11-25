import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/token_types.dart';
import 'semi_theme_data.dart';

/// Nullable overrides for [SemiChromeTab].
///
/// Every field mirrors a CSS custom property of the upstream qn-chrome-tabs
/// `styles.css`. A null value falls back to the Semi-styled defaults resolved
/// in [resolve]: colors, radius, and shadows come from the ambient
/// [SemiThemeData] tokens, so the component follows the light/dark theme by
/// default. Geometry and Chromium motion remain upstream constants because they
/// describe the tab-strip layout rather than the palette.
@immutable
class SemiChromeTabThemeData {
  const SemiChromeTabThemeData({
    this.chromeTabsHeight,
    this.chromeTabsBackground,
    this.chromeTabsFontSize,
    this.chromeTabMinWidth,
    this.chromeTabMaxWidth,
    this.chromeTabRadius,
    this.chromeTabTextColor,
    this.chromeTabActiveTextColor,
    this.chromeTabHoverBackground,
    this.chromeTabActiveBackground,
    this.chromeTabDividerColor,
    this.chromeTabCloseHoverBackground,
    this.chromeTabsAccentColor,
    this.chromeTabsMenuBackground,
    this.chromeTabsMenuBorderColor,
    this.chromeTabsMenuHoverBackground,
    this.chromeTabsMenuTextColor,
    this.chromeTabsMenuIconColor,
    this.chromeTabsMenuIconBackground,
    this.chromeTabsMenuShadow,
    this.chromeTabsTooltipBackground,
    this.chromeTabsTooltipBorderColor,
    this.chromeTabsTooltipTextColor,
    this.chromeTabsTooltipShadow,
    this.chromeTabEnterDuration,
    this.chromeTabCloseDuration,
    this.chromeTabLayoutDuration,
    this.chromeTabTooltipMoveDuration,
  });

  /// `--chrome-tabs-height: 38px` (upstream layout constant, not themed).
  final double? chromeTabsHeight;

  /// `--chrome-tabs-background`; defaults to `colors.colorFill1`.
  final Color? chromeTabsBackground;

  /// `--chrome-tabs-font` (size part only; Arial is not bundled and is
  /// documented as a platform difference). Defaults to `typography.fontSizeSmall`.
  final double? chromeTabsFontSize;

  /// `--chrome-tab-min-width: 52px` (upstream layout constant, not themed).
  final double? chromeTabMinWidth;

  /// `--chrome-tab-max-width: 120px` (upstream layout constant, not themed).
  final double? chromeTabMaxWidth;

  /// `--chrome-tab-radius`; defaults to `radius.borderRadiusMedium`.
  final double? chromeTabRadius;

  /// `--chrome-tab-text-color`; defaults to `colors.colorText2`.
  final Color? chromeTabTextColor;

  /// `--chrome-tab-active-text-color`; defaults to `colors.colorText0`.
  final Color? chromeTabActiveTextColor;

  /// `--chrome-tab-hover-background`; defaults to `colors.colorFill2`.
  final Color? chromeTabHoverBackground;

  /// `--chrome-tab-active-background`; defaults to the elevated surface
  /// `colors.colorBg3`.
  final Color? chromeTabActiveBackground;

  /// `--chrome-tab-divider-color`; defaults to `colors.colorBorder`.
  final Color? chromeTabDividerColor;

  /// `--chrome-tab-close-hover-background`; defaults to `colors.colorFill2`.
  final Color? chromeTabCloseHoverBackground;

  /// `--chrome-tabs-accent-color`; defaults to `colors.colorPrimary`.
  final Color? chromeTabsAccentColor;

  /// `--chrome-tabs-menu-background`; defaults to `colors.colorBg3`.
  final Color? chromeTabsMenuBackground;

  /// `--chrome-tabs-menu-border-color`; defaults to `colors.colorBorder`.
  final Color? chromeTabsMenuBorderColor;

  /// `--chrome-tabs-menu-hover-background`; defaults to `colors.colorFill0`.
  final Color? chromeTabsMenuHoverBackground;

  /// `--chrome-tabs-menu-text-color`; defaults to [chromeTabTextColor], then
  /// `colors.colorText1`.
  final Color? chromeTabsMenuTextColor;

  /// `--chrome-tabs-menu-icon-color`; defaults to [chromeTabTextColor], then
  /// `colors.colorText2`.
  final Color? chromeTabsMenuIconColor;

  /// `--chrome-tabs-menu-icon-background`; defaults to `colors.colorFill0`.
  final Color? chromeTabsMenuIconBackground;

  /// `--chrome-tabs-menu-shadow`; defaults to `shadows.shadowElevated`.
  final SemiShadows? chromeTabsMenuShadow;

  /// `--chrome-tabs-tooltip-background`; defaults to `colors.colorBg3`.
  final Color? chromeTabsTooltipBackground;

  /// `--chrome-tabs-tooltip-border-color`; defaults to `colors.colorBorder`.
  final Color? chromeTabsTooltipBorderColor;

  /// `--chrome-tabs-tooltip-text-color`; defaults to [chromeTabTextColor], then
  /// `colors.colorText0`.
  final Color? chromeTabsTooltipTextColor;

  /// `--chrome-tabs-tooltip-shadow`; defaults to `shadows.shadowElevated`.
  final SemiShadows? chromeTabsTooltipShadow;

  /// Duration of the Chromium-style insertion animation (the new tab's bounds
  /// expansion and the strip reflow). Chromium uses 200ms ease-out in
  /// `TabContainer::StartInsertTabAnimation`; the upstream web component fades
  /// the tab in over 160ms instead.
  final Duration? chromeTabEnterDuration;

  /// Duration of the Chromium-style close animation (the closing tab collapses
  /// to the insertion point while the remaining tabs reflow). Chromium uses
  /// 200ms in `TabContainer::StartRemoveTabAnimation`; the upstream web
  /// component fades the tab out over 140ms instead.
  final Duration? chromeTabCloseDuration;

  /// Tab layout transition duration (`200ms` upstream Chromium behavior).
  ///
  /// Inserting a tab uses [chromeTabEnterDuration] for that update instead,
  /// so the new tab and the strip reflow share one duration.
  final Duration? chromeTabLayoutDuration;

  /// `left 140ms ease-out` when a tooltip moves between two tabs.
  final Duration? chromeTabTooltipMoveDuration;

  SemiChromeTabThemeData copyWith({
    double? chromeTabsHeight,
    Color? chromeTabsBackground,
    double? chromeTabsFontSize,
    double? chromeTabMinWidth,
    double? chromeTabMaxWidth,
    double? chromeTabRadius,
    Color? chromeTabTextColor,
    Color? chromeTabActiveTextColor,
    Color? chromeTabHoverBackground,
    Color? chromeTabActiveBackground,
    Color? chromeTabDividerColor,
    Color? chromeTabCloseHoverBackground,
    Color? chromeTabsAccentColor,
    Color? chromeTabsMenuBackground,
    Color? chromeTabsMenuBorderColor,
    Color? chromeTabsMenuHoverBackground,
    Color? chromeTabsMenuTextColor,
    Color? chromeTabsMenuIconColor,
    Color? chromeTabsMenuIconBackground,
    SemiShadows? chromeTabsMenuShadow,
    Color? chromeTabsTooltipBackground,
    Color? chromeTabsTooltipBorderColor,
    Color? chromeTabsTooltipTextColor,
    SemiShadows? chromeTabsTooltipShadow,
    Duration? chromeTabEnterDuration,
    Duration? chromeTabCloseDuration,
    Duration? chromeTabLayoutDuration,
    Duration? chromeTabTooltipMoveDuration,
  }) => SemiChromeTabThemeData(
    chromeTabsHeight: chromeTabsHeight ?? this.chromeTabsHeight,
    chromeTabsBackground: chromeTabsBackground ?? this.chromeTabsBackground,
    chromeTabsFontSize: chromeTabsFontSize ?? this.chromeTabsFontSize,
    chromeTabMinWidth: chromeTabMinWidth ?? this.chromeTabMinWidth,
    chromeTabMaxWidth: chromeTabMaxWidth ?? this.chromeTabMaxWidth,
    chromeTabRadius: chromeTabRadius ?? this.chromeTabRadius,
    chromeTabTextColor: chromeTabTextColor ?? this.chromeTabTextColor,
    chromeTabActiveTextColor:
        chromeTabActiveTextColor ?? this.chromeTabActiveTextColor,
    chromeTabHoverBackground:
        chromeTabHoverBackground ?? this.chromeTabHoverBackground,
    chromeTabActiveBackground:
        chromeTabActiveBackground ?? this.chromeTabActiveBackground,
    chromeTabDividerColor: chromeTabDividerColor ?? this.chromeTabDividerColor,
    chromeTabCloseHoverBackground:
        chromeTabCloseHoverBackground ?? this.chromeTabCloseHoverBackground,
    chromeTabsAccentColor: chromeTabsAccentColor ?? this.chromeTabsAccentColor,
    chromeTabsMenuBackground:
        chromeTabsMenuBackground ?? this.chromeTabsMenuBackground,
    chromeTabsMenuBorderColor:
        chromeTabsMenuBorderColor ?? this.chromeTabsMenuBorderColor,
    chromeTabsMenuHoverBackground:
        chromeTabsMenuHoverBackground ?? this.chromeTabsMenuHoverBackground,
    chromeTabsMenuTextColor:
        chromeTabsMenuTextColor ?? this.chromeTabsMenuTextColor,
    chromeTabsMenuIconColor:
        chromeTabsMenuIconColor ?? this.chromeTabsMenuIconColor,
    chromeTabsMenuIconBackground:
        chromeTabsMenuIconBackground ?? this.chromeTabsMenuIconBackground,
    chromeTabsMenuShadow: chromeTabsMenuShadow ?? this.chromeTabsMenuShadow,
    chromeTabsTooltipBackground:
        chromeTabsTooltipBackground ?? this.chromeTabsTooltipBackground,
    chromeTabsTooltipBorderColor:
        chromeTabsTooltipBorderColor ?? this.chromeTabsTooltipBorderColor,
    chromeTabsTooltipTextColor:
        chromeTabsTooltipTextColor ?? this.chromeTabsTooltipTextColor,
    chromeTabsTooltipShadow:
        chromeTabsTooltipShadow ?? this.chromeTabsTooltipShadow,
    chromeTabEnterDuration:
        chromeTabEnterDuration ?? this.chromeTabEnterDuration,
    chromeTabCloseDuration:
        chromeTabCloseDuration ?? this.chromeTabCloseDuration,
    chromeTabLayoutDuration:
        chromeTabLayoutDuration ?? this.chromeTabLayoutDuration,
    chromeTabTooltipMoveDuration:
        chromeTabTooltipMoveDuration ?? this.chromeTabTooltipMoveDuration,
  );

  SemiChromeTabThemeData merge(SemiChromeTabThemeData? other) => other == null
      ? this
      : copyWith(
          chromeTabsHeight: other.chromeTabsHeight,
          chromeTabsBackground: other.chromeTabsBackground,
          chromeTabsFontSize: other.chromeTabsFontSize,
          chromeTabMinWidth: other.chromeTabMinWidth,
          chromeTabMaxWidth: other.chromeTabMaxWidth,
          chromeTabRadius: other.chromeTabRadius,
          chromeTabTextColor: other.chromeTabTextColor,
          chromeTabActiveTextColor: other.chromeTabActiveTextColor,
          chromeTabHoverBackground: other.chromeTabHoverBackground,
          chromeTabActiveBackground: other.chromeTabActiveBackground,
          chromeTabDividerColor: other.chromeTabDividerColor,
          chromeTabCloseHoverBackground: other.chromeTabCloseHoverBackground,
          chromeTabsAccentColor: other.chromeTabsAccentColor,
          chromeTabsMenuBackground: other.chromeTabsMenuBackground,
          chromeTabsMenuBorderColor: other.chromeTabsMenuBorderColor,
          chromeTabsMenuHoverBackground: other.chromeTabsMenuHoverBackground,
          chromeTabsMenuTextColor: other.chromeTabsMenuTextColor,
          chromeTabsMenuIconColor: other.chromeTabsMenuIconColor,
          chromeTabsMenuIconBackground: other.chromeTabsMenuIconBackground,
          chromeTabsMenuShadow: other.chromeTabsMenuShadow,
          chromeTabsTooltipBackground: other.chromeTabsTooltipBackground,
          chromeTabsTooltipBorderColor: other.chromeTabsTooltipBorderColor,
          chromeTabsTooltipTextColor: other.chromeTabsTooltipTextColor,
          chromeTabsTooltipShadow: other.chromeTabsTooltipShadow,
          chromeTabEnterDuration: other.chromeTabEnterDuration,
          chromeTabCloseDuration: other.chromeTabCloseDuration,
          chromeTabLayoutDuration: other.chromeTabLayoutDuration,
          chromeTabTooltipMoveDuration: other.chromeTabTooltipMoveDuration,
        );

  SemiResolvedChromeTabThemeData resolve(SemiThemeData theme) {
    final colors = theme.colors;
    final height = chromeTabsHeight ?? 38;
    final tabTextColor = chromeTabTextColor ?? colors.colorText2;
    return SemiResolvedChromeTabThemeData(
      chromeTabsHeight: height,
      chromeTabsBackground: chromeTabsBackground ?? colors.colorFill1,
      chromeTabsFontSize: chromeTabsFontSize ?? theme.typography.fontSizeSmall,
      chromeTabHeight: math.max(height, 28),
      chromeTabMinWidth: chromeTabMinWidth ?? 52,
      chromeTabMaxWidth: chromeTabMaxWidth ?? 120,
      chromeTabRadius: chromeTabRadius ?? theme.radius.borderRadiusMedium.value,
      chromeTabTextColor: tabTextColor,
      chromeTabActiveTextColor: chromeTabActiveTextColor ?? colors.colorText0,
      chromeTabHoverBackground: chromeTabHoverBackground ?? colors.colorFill2,
      chromeTabActiveBackground: chromeTabActiveBackground ?? colors.colorBg3,
      chromeTabDividerColor: chromeTabDividerColor ?? colors.colorBorder,
      chromeTabCloseHoverBackground:
          chromeTabCloseHoverBackground ?? colors.colorFill2,
      chromeTabsAccentColor: chromeTabsAccentColor ?? colors.colorPrimary,
      chromeTabsMenuBackground: chromeTabsMenuBackground ?? colors.colorBg3,
      chromeTabsMenuBorderColor:
          chromeTabsMenuBorderColor ?? colors.colorBorder,
      chromeTabsMenuHoverBackground:
          chromeTabsMenuHoverBackground ?? colors.colorFill0,
      chromeTabsMenuTextColor:
          chromeTabsMenuTextColor ?? chromeTabTextColor ?? colors.colorText1,
      chromeTabsMenuIconColor:
          chromeTabsMenuIconColor ?? chromeTabTextColor ?? colors.colorText2,
      chromeTabsMenuIconBackground:
          chromeTabsMenuIconBackground ?? colors.colorFill0,
      chromeTabsMenuShadow:
          chromeTabsMenuShadow ?? theme.shadows.shadowElevated,
      chromeTabsTooltipBackground:
          chromeTabsTooltipBackground ?? colors.colorBg3,
      chromeTabsTooltipBorderColor:
          chromeTabsTooltipBorderColor ?? colors.colorBorder,
      chromeTabsTooltipTextColor:
          chromeTabsTooltipTextColor ?? chromeTabTextColor ?? colors.colorText0,
      chromeTabsTooltipShadow:
          chromeTabsTooltipShadow ?? theme.shadows.shadowElevated,
      chromeTabEnterDuration:
          chromeTabEnterDuration ?? const Duration(milliseconds: 200),
      chromeTabCloseDuration:
          chromeTabCloseDuration ?? const Duration(milliseconds: 200),
      chromeTabLayoutDuration:
          chromeTabLayoutDuration ?? const Duration(milliseconds: 200),
      chromeTabTooltipMoveDuration:
          chromeTabTooltipMoveDuration ?? const Duration(milliseconds: 140),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiChromeTabThemeData &&
          chromeTabsHeight == other.chromeTabsHeight &&
          chromeTabsBackground == other.chromeTabsBackground &&
          chromeTabsFontSize == other.chromeTabsFontSize &&
          chromeTabMinWidth == other.chromeTabMinWidth &&
          chromeTabMaxWidth == other.chromeTabMaxWidth &&
          chromeTabRadius == other.chromeTabRadius &&
          chromeTabTextColor == other.chromeTabTextColor &&
          chromeTabActiveTextColor == other.chromeTabActiveTextColor &&
          chromeTabHoverBackground == other.chromeTabHoverBackground &&
          chromeTabActiveBackground == other.chromeTabActiveBackground &&
          chromeTabDividerColor == other.chromeTabDividerColor &&
          chromeTabCloseHoverBackground ==
              other.chromeTabCloseHoverBackground &&
          chromeTabsAccentColor == other.chromeTabsAccentColor &&
          chromeTabsMenuBackground == other.chromeTabsMenuBackground &&
          chromeTabsMenuBorderColor == other.chromeTabsMenuBorderColor &&
          chromeTabsMenuHoverBackground ==
              other.chromeTabsMenuHoverBackground &&
          chromeTabsMenuTextColor == other.chromeTabsMenuTextColor &&
          chromeTabsMenuIconColor == other.chromeTabsMenuIconColor &&
          chromeTabsMenuIconBackground == other.chromeTabsMenuIconBackground &&
          chromeTabsMenuShadow == other.chromeTabsMenuShadow &&
          chromeTabsTooltipBackground == other.chromeTabsTooltipBackground &&
          chromeTabsTooltipBorderColor == other.chromeTabsTooltipBorderColor &&
          chromeTabsTooltipTextColor == other.chromeTabsTooltipTextColor &&
          chromeTabsTooltipShadow == other.chromeTabsTooltipShadow &&
          chromeTabEnterDuration == other.chromeTabEnterDuration &&
          chromeTabCloseDuration == other.chromeTabCloseDuration &&
          chromeTabLayoutDuration == other.chromeTabLayoutDuration &&
          chromeTabTooltipMoveDuration == other.chromeTabTooltipMoveDuration;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    chromeTabsHeight,
    chromeTabsBackground,
    chromeTabsFontSize,
    chromeTabMinWidth,
    chromeTabMaxWidth,
    chromeTabRadius,
    chromeTabTextColor,
    chromeTabActiveTextColor,
    chromeTabHoverBackground,
    chromeTabActiveBackground,
    chromeTabDividerColor,
    chromeTabCloseHoverBackground,
    chromeTabsAccentColor,
    chromeTabsMenuBackground,
    chromeTabsMenuBorderColor,
    chromeTabsMenuHoverBackground,
    chromeTabsMenuTextColor,
    chromeTabsMenuIconColor,
    chromeTabsMenuIconBackground,
    chromeTabsMenuShadow,
    chromeTabsTooltipBackground,
    chromeTabsTooltipBorderColor,
    chromeTabsTooltipTextColor,
    chromeTabsTooltipShadow,
    chromeTabEnterDuration,
    chromeTabCloseDuration,
    chromeTabLayoutDuration,
    chromeTabTooltipMoveDuration,
  ]);
}

/// Non-null values consumed by [SemiChromeTab] after defaults are resolved.
@immutable
class SemiResolvedChromeTabThemeData {
  const SemiResolvedChromeTabThemeData({
    required this.chromeTabsHeight,
    required this.chromeTabsBackground,
    required this.chromeTabsFontSize,
    required this.chromeTabHeight,
    required this.chromeTabMinWidth,
    required this.chromeTabMaxWidth,
    required this.chromeTabRadius,
    required this.chromeTabTextColor,
    required this.chromeTabActiveTextColor,
    required this.chromeTabHoverBackground,
    required this.chromeTabActiveBackground,
    required this.chromeTabDividerColor,
    required this.chromeTabCloseHoverBackground,
    required this.chromeTabsAccentColor,
    required this.chromeTabsMenuBackground,
    required this.chromeTabsMenuBorderColor,
    required this.chromeTabsMenuHoverBackground,
    required this.chromeTabsMenuTextColor,
    required this.chromeTabsMenuIconColor,
    required this.chromeTabsMenuIconBackground,
    required this.chromeTabsMenuShadow,
    required this.chromeTabsTooltipBackground,
    required this.chromeTabsTooltipBorderColor,
    required this.chromeTabsTooltipTextColor,
    required this.chromeTabsTooltipShadow,
    required this.chromeTabEnterDuration,
    required this.chromeTabCloseDuration,
    required this.chromeTabLayoutDuration,
    required this.chromeTabTooltipMoveDuration,
  });

  final double chromeTabsHeight;
  final Color chromeTabsBackground;
  final double chromeTabsFontSize;

  /// `max(--chrome-tabs-height, 28px)` from the upstream stylesheet.
  final double chromeTabHeight;
  final double chromeTabMinWidth;
  final double chromeTabMaxWidth;
  final double chromeTabRadius;
  final Color chromeTabTextColor;
  final Color chromeTabActiveTextColor;
  final Color chromeTabHoverBackground;
  final Color chromeTabActiveBackground;
  final Color chromeTabDividerColor;
  final Color chromeTabCloseHoverBackground;
  final Color chromeTabsAccentColor;
  final Color chromeTabsMenuBackground;
  final Color chromeTabsMenuBorderColor;
  final Color chromeTabsMenuHoverBackground;
  final Color chromeTabsMenuTextColor;
  final Color chromeTabsMenuIconColor;
  final Color chromeTabsMenuIconBackground;
  final SemiShadows chromeTabsMenuShadow;
  final Color chromeTabsTooltipBackground;
  final Color chromeTabsTooltipBorderColor;
  final Color chromeTabsTooltipTextColor;
  final SemiShadows chromeTabsTooltipShadow;
  final Duration chromeTabEnterDuration;
  final Duration chromeTabCloseDuration;
  final Duration chromeTabLayoutDuration;
  final Duration chromeTabTooltipMoveDuration;
}
