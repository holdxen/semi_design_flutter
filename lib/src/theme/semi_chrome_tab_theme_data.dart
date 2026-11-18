import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/token_types.dart';
import 'semi_theme_data.dart';

/// Nullable overrides for [SemiChromeTab].
///
/// Every field mirrors a CSS custom property of the upstream qn-chrome-tabs
/// `styles.css`. A null value falls back to the Chrome default recorded in
/// [SemiResolvedChromeTabThemeData]. Unlike other Semi ports these defaults are
/// literal Chrome colors, not `SemiThemeData` tokens: qn-chrome-tabs is a
/// browser-chrome clone whose palette does not derive from Semi.
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

  /// `--chrome-tabs-height: 38px`.
  final double? chromeTabsHeight;

  /// `--chrome-tabs-background: #dee1e6`.
  final Color? chromeTabsBackground;

  /// `--chrome-tabs-font: 12px Arial, sans-serif` (size part only; Arial is
  /// not bundled and is documented as a platform difference).
  final double? chromeTabsFontSize;

  /// `--chrome-tab-min-width: 52px`.
  final double? chromeTabMinWidth;

  /// `--chrome-tab-max-width: 120px`.
  final double? chromeTabMaxWidth;

  /// `--chrome-tab-radius: 8px`.
  final double? chromeTabRadius;

  /// `--chrome-tab-text-color: #5f6368`.
  final Color? chromeTabTextColor;

  /// `--chrome-tab-active-text-color: #202124`.
  final Color? chromeTabActiveTextColor;

  /// `--chrome-tab-hover-background: #f4f5f6`.
  final Color? chromeTabHoverBackground;

  /// `--chrome-tab-active-background: #fff`.
  final Color? chromeTabActiveBackground;

  /// `--chrome-tab-divider-color: #aeb5c64f`.
  final Color? chromeTabDividerColor;

  /// `--chrome-tab-close-hover-background: #dadce0`.
  final Color? chromeTabCloseHoverBackground;

  /// `--chrome-tabs-accent-color: #1a73e8`.
  final Color? chromeTabsAccentColor;

  /// `--chrome-tabs-menu-background: #fff`.
  final Color? chromeTabsMenuBackground;

  /// `--chrome-tabs-menu-border-color: #dadce0`.
  final Color? chromeTabsMenuBorderColor;

  /// `--chrome-tabs-menu-hover-background: #f1f3f4`.
  final Color? chromeTabsMenuHoverBackground;

  /// `--chrome-tabs-menu-text-color` (defaults to [chromeTabTextColor]).
  final Color? chromeTabsMenuTextColor;

  /// `--chrome-tabs-menu-icon-color` (defaults to [chromeTabTextColor]).
  final Color? chromeTabsMenuIconColor;

  /// `--chrome-tabs-menu-icon-background: rgb(255 255 255 / 62%)`.
  final Color? chromeTabsMenuIconBackground;

  /// `--chrome-tabs-menu-shadow: 0 6px 18px rgb(60 64 67 / 24%)`.
  final SemiShadows? chromeTabsMenuShadow;

  /// `--chrome-tabs-tooltip-background: #fff`.
  final Color? chromeTabsTooltipBackground;

  /// `--chrome-tabs-tooltip-border-color: #dadce0`.
  final Color? chromeTabsTooltipBorderColor;

  /// `--chrome-tabs-tooltip-text-color` (defaults to [chromeTabTextColor]).
  final Color? chromeTabsTooltipTextColor;

  /// `--chrome-tabs-tooltip-shadow: 0 2px 4px rgba(60, 64, 67, 0.067)`.
  final SemiShadows? chromeTabsTooltipShadow;

  /// `chrome-tab-enter` animation duration.
  ///
  /// Defaults to 340ms so that a new tab's total entrance (content fade plus
  /// the 200ms bounds transition) matches the close sequence (140ms content
  /// exit plus the 200ms bounds reflow). Upstream CSS uses 160ms.
  final Duration? chromeTabEnterDuration;

  /// `chrome-tab-close` animation duration (`140ms ease-in` upstream).
  final Duration? chromeTabCloseDuration;

  /// Tab layout transition duration (`200ms` upstream Chromium behavior).
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
    final height = chromeTabsHeight ?? 38;
    final tabTextColor = chromeTabTextColor ?? const Color(0xff5f6368);
    return SemiResolvedChromeTabThemeData(
      chromeTabsHeight: height,
      chromeTabsBackground: chromeTabsBackground ?? const Color(0xffdee1e6),
      chromeTabsFontSize: chromeTabsFontSize ?? 12,
      chromeTabHeight: math.max(height, 28),
      chromeTabMinWidth: chromeTabMinWidth ?? 52,
      chromeTabMaxWidth: chromeTabMaxWidth ?? 120,
      chromeTabRadius: chromeTabRadius ?? 8,
      chromeTabTextColor: tabTextColor,
      chromeTabActiveTextColor:
          chromeTabActiveTextColor ?? const Color(0xff202124),
      chromeTabHoverBackground:
          chromeTabHoverBackground ?? const Color(0xfff4f5f6),
      chromeTabActiveBackground:
          chromeTabActiveBackground ?? const Color(0xffffffff),
      chromeTabDividerColor: chromeTabDividerColor ?? const Color(0x4faeb5c6),
      chromeTabCloseHoverBackground:
          chromeTabCloseHoverBackground ?? const Color(0xffdadce0),
      chromeTabsAccentColor: chromeTabsAccentColor ?? const Color(0xff1a73e8),
      chromeTabsMenuBackground:
          chromeTabsMenuBackground ?? const Color(0xffffffff),
      chromeTabsMenuBorderColor:
          chromeTabsMenuBorderColor ?? const Color(0xffdadce0),
      chromeTabsMenuHoverBackground:
          chromeTabsMenuHoverBackground ?? const Color(0xfff1f3f4),
      chromeTabsMenuTextColor: chromeTabsMenuTextColor ?? tabTextColor,
      chromeTabsMenuIconColor: chromeTabsMenuIconColor ?? tabTextColor,
      chromeTabsMenuIconBackground:
          chromeTabsMenuIconBackground ?? const Color(0x9effffff),
      chromeTabsMenuShadow:
          chromeTabsMenuShadow ??
          SemiShadows(const <SemiShadowLayer>[
            SemiShadowLayer(false, 0, 6, 18, 0, Color(0x3d3c4043)),
          ]),
      chromeTabsTooltipBackground:
          chromeTabsTooltipBackground ?? const Color(0xffffffff),
      chromeTabsTooltipBorderColor:
          chromeTabsTooltipBorderColor ?? const Color(0xffdadce0),
      chromeTabsTooltipTextColor: chromeTabsTooltipTextColor ?? tabTextColor,
      chromeTabsTooltipShadow:
          chromeTabsTooltipShadow ??
          SemiShadows(const <SemiShadowLayer>[
            SemiShadowLayer(false, 0, 2, 4, 0, Color(0x113c4043)),
          ]),
      chromeTabEnterDuration:
          chromeTabEnterDuration ?? const Duration(milliseconds: 340),
      chromeTabCloseDuration:
          chromeTabCloseDuration ?? const Duration(milliseconds: 140),
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
