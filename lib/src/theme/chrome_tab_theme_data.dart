import 'package:flutter/widgets.dart';

import '../tokens/token_types.dart';
import 'semi_theme_data.dart';

/// Nullable ChromeTab overrides. A null value inherits the global Semi theme
/// default when [resolve] is called.
@immutable
class ChromeTabThemeData {
  const ChromeTabThemeData({
    this.stripHeight,
    this.stripBackgroundColor,
    this.tabHeight,
    this.tabMinWidth,
    this.tabMaxWidth,
    this.tabRadius,
    this.tabTextColor,
    this.tabActiveTextColor,
    this.tabHoverTextColor,
    this.tabPressedTextColor,
    this.tabDisabledTextColor,
    this.tabBackgroundColor,
    this.tabHoverBackgroundColor,
    this.tabActiveBackgroundColor,
    this.tabPressedBackgroundColor,
    this.tabDisabledBackgroundColor,
    this.tabDividerColor,
    this.accentColor,
    this.closeButtonHoverBackgroundColor,
    this.menuBackgroundColor,
    this.menuBorderColor,
    this.menuHoverBackgroundColor,
    this.menuTextColor,
    this.menuIconColor,
    this.menuIconBackgroundColor,
    this.menuShadow,
    this.tooltipBackgroundColor,
    this.tooltipBorderColor,
    this.tooltipTextColor,
    this.tooltipShadow,
    this.scrollButtonWidth,
    this.closeButtonWidth,
    this.closeButtonHeight,
    this.iconSize,
    this.newTabButtonSize,
    this.groupButtonSize,
    this.tabDividerWidth,
    this.tabDividerHeight,
    this.menuRadius,
    this.tooltipRadius,
    this.controlRadius,
    this.tabContentPaddingX,
    this.tabIconGap,
    this.tabCloseRight,
    this.groupContentPaddingRight,
    this.menuPadding,
    this.menuItemPaddingX,
    this.menuItemPaddingY,
    this.tooltipPaddingX,
    this.tooltipPaddingY,
    this.tabEnterDuration,
    this.tabCloseDuration,
    this.tooltipMoveDuration,
  });

  /// Height of the complete tab strip.
  final double? stripHeight;

  /// Background behind the tab list and controls.
  final Color? stripBackgroundColor;

  /// Height of each tab. Defaults to [stripHeight].
  final double? tabHeight;
  final double? tabMinWidth;
  final double? tabMaxWidth;
  final double? tabRadius;
  final Color? tabTextColor;
  final Color? tabActiveTextColor;
  final Color? tabHoverTextColor;
  final Color? tabPressedTextColor;
  final Color? tabDisabledTextColor;
  final Color? tabBackgroundColor;
  final Color? tabHoverBackgroundColor;
  final Color? tabActiveBackgroundColor;
  final Color? tabPressedBackgroundColor;
  final Color? tabDisabledBackgroundColor;
  final Color? tabDividerColor;
  final Color? accentColor;
  final Color? closeButtonHoverBackgroundColor;
  final Color? menuBackgroundColor;
  final Color? menuBorderColor;
  final Color? menuHoverBackgroundColor;
  final Color? menuTextColor;
  final Color? menuIconColor;
  final Color? menuIconBackgroundColor;
  final SemiShadows? menuShadow;
  final Color? tooltipBackgroundColor;
  final Color? tooltipBorderColor;
  final Color? tooltipTextColor;
  final SemiShadows? tooltipShadow;
  final double? scrollButtonWidth;
  final double? closeButtonWidth;
  final double? closeButtonHeight;
  final double? iconSize;
  final double? newTabButtonSize;
  final double? groupButtonSize;
  final double? tabDividerWidth;
  final double? tabDividerHeight;
  final double? menuRadius;
  final double? tooltipRadius;
  final double? controlRadius;
  final double? tabContentPaddingX;
  final double? tabIconGap;
  final double? tabCloseRight;
  final double? groupContentPaddingRight;
  final double? menuPadding;
  final double? menuItemPaddingX;
  final double? menuItemPaddingY;
  final double? tooltipPaddingX;
  final double? tooltipPaddingY;
  final Duration? tabEnterDuration;
  final Duration? tabCloseDuration;
  final Duration? tooltipMoveDuration;

  ChromeTabThemeData copyWith({
    double? stripHeight,
    Color? stripBackgroundColor,
    double? tabHeight,
    double? tabMinWidth,
    double? tabMaxWidth,
    double? tabRadius,
    Color? tabTextColor,
    Color? tabActiveTextColor,
    Color? tabHoverTextColor,
    Color? tabPressedTextColor,
    Color? tabDisabledTextColor,
    Color? tabBackgroundColor,
    Color? tabHoverBackgroundColor,
    Color? tabActiveBackgroundColor,
    Color? tabPressedBackgroundColor,
    Color? tabDisabledBackgroundColor,
    Color? tabDividerColor,
    Color? accentColor,
    Color? closeButtonHoverBackgroundColor,
    Color? menuBackgroundColor,
    Color? menuBorderColor,
    Color? menuHoverBackgroundColor,
    Color? menuTextColor,
    Color? menuIconColor,
    Color? menuIconBackgroundColor,
    SemiShadows? menuShadow,
    Color? tooltipBackgroundColor,
    Color? tooltipBorderColor,
    Color? tooltipTextColor,
    SemiShadows? tooltipShadow,
    double? scrollButtonWidth,
    double? closeButtonWidth,
    double? closeButtonHeight,
    double? iconSize,
    double? newTabButtonSize,
    double? groupButtonSize,
    double? tabDividerWidth,
    double? tabDividerHeight,
    double? menuRadius,
    double? tooltipRadius,
    double? controlRadius,
    double? tabContentPaddingX,
    double? tabIconGap,
    double? tabCloseRight,
    double? groupContentPaddingRight,
    double? menuPadding,
    double? menuItemPaddingX,
    double? menuItemPaddingY,
    double? tooltipPaddingX,
    double? tooltipPaddingY,
    Duration? tabEnterDuration,
    Duration? tabCloseDuration,
    Duration? tooltipMoveDuration,
  }) => ChromeTabThemeData(
    stripHeight: stripHeight ?? this.stripHeight,
    stripBackgroundColor: stripBackgroundColor ?? this.stripBackgroundColor,
    tabHeight: tabHeight ?? this.tabHeight,
    tabMinWidth: tabMinWidth ?? this.tabMinWidth,
    tabMaxWidth: tabMaxWidth ?? this.tabMaxWidth,
    tabRadius: tabRadius ?? this.tabRadius,
    tabTextColor: tabTextColor ?? this.tabTextColor,
    tabActiveTextColor: tabActiveTextColor ?? this.tabActiveTextColor,
    tabHoverTextColor: tabHoverTextColor ?? this.tabHoverTextColor,
    tabPressedTextColor: tabPressedTextColor ?? this.tabPressedTextColor,
    tabDisabledTextColor: tabDisabledTextColor ?? this.tabDisabledTextColor,
    tabBackgroundColor: tabBackgroundColor ?? this.tabBackgroundColor,
    tabHoverBackgroundColor:
        tabHoverBackgroundColor ?? this.tabHoverBackgroundColor,
    tabActiveBackgroundColor:
        tabActiveBackgroundColor ?? this.tabActiveBackgroundColor,
    tabPressedBackgroundColor:
        tabPressedBackgroundColor ?? this.tabPressedBackgroundColor,
    tabDisabledBackgroundColor:
        tabDisabledBackgroundColor ?? this.tabDisabledBackgroundColor,
    tabDividerColor: tabDividerColor ?? this.tabDividerColor,
    accentColor: accentColor ?? this.accentColor,
    closeButtonHoverBackgroundColor:
        closeButtonHoverBackgroundColor ?? this.closeButtonHoverBackgroundColor,
    menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
    menuBorderColor: menuBorderColor ?? this.menuBorderColor,
    menuHoverBackgroundColor:
        menuHoverBackgroundColor ?? this.menuHoverBackgroundColor,
    menuTextColor: menuTextColor ?? this.menuTextColor,
    menuIconColor: menuIconColor ?? this.menuIconColor,
    menuIconBackgroundColor:
        menuIconBackgroundColor ?? this.menuIconBackgroundColor,
    menuShadow: menuShadow ?? this.menuShadow,
    tooltipBackgroundColor:
        tooltipBackgroundColor ?? this.tooltipBackgroundColor,
    tooltipBorderColor: tooltipBorderColor ?? this.tooltipBorderColor,
    tooltipTextColor: tooltipTextColor ?? this.tooltipTextColor,
    tooltipShadow: tooltipShadow ?? this.tooltipShadow,
    scrollButtonWidth: scrollButtonWidth ?? this.scrollButtonWidth,
    closeButtonWidth: closeButtonWidth ?? this.closeButtonWidth,
    closeButtonHeight: closeButtonHeight ?? this.closeButtonHeight,
    iconSize: iconSize ?? this.iconSize,
    newTabButtonSize: newTabButtonSize ?? this.newTabButtonSize,
    groupButtonSize: groupButtonSize ?? this.groupButtonSize,
    tabDividerWidth: tabDividerWidth ?? this.tabDividerWidth,
    tabDividerHeight: tabDividerHeight ?? this.tabDividerHeight,
    menuRadius: menuRadius ?? this.menuRadius,
    tooltipRadius: tooltipRadius ?? this.tooltipRadius,
    controlRadius: controlRadius ?? this.controlRadius,
    tabContentPaddingX: tabContentPaddingX ?? this.tabContentPaddingX,
    tabIconGap: tabIconGap ?? this.tabIconGap,
    tabCloseRight: tabCloseRight ?? this.tabCloseRight,
    groupContentPaddingRight:
        groupContentPaddingRight ?? this.groupContentPaddingRight,
    menuPadding: menuPadding ?? this.menuPadding,
    menuItemPaddingX: menuItemPaddingX ?? this.menuItemPaddingX,
    menuItemPaddingY: menuItemPaddingY ?? this.menuItemPaddingY,
    tooltipPaddingX: tooltipPaddingX ?? this.tooltipPaddingX,
    tooltipPaddingY: tooltipPaddingY ?? this.tooltipPaddingY,
    tabEnterDuration: tabEnterDuration ?? this.tabEnterDuration,
    tabCloseDuration: tabCloseDuration ?? this.tabCloseDuration,
    tooltipMoveDuration: tooltipMoveDuration ?? this.tooltipMoveDuration,
  );

  ChromeTabThemeData merge(ChromeTabThemeData? other) => other == null
      ? this
      : copyWith(
          stripHeight: other.stripHeight,
          stripBackgroundColor: other.stripBackgroundColor,
          tabHeight: other.tabHeight,
          tabMinWidth: other.tabMinWidth,
          tabMaxWidth: other.tabMaxWidth,
          tabRadius: other.tabRadius,
          tabTextColor: other.tabTextColor,
          tabActiveTextColor: other.tabActiveTextColor,
          tabHoverTextColor: other.tabHoverTextColor,
          tabPressedTextColor: other.tabPressedTextColor,
          tabDisabledTextColor: other.tabDisabledTextColor,
          tabBackgroundColor: other.tabBackgroundColor,
          tabHoverBackgroundColor: other.tabHoverBackgroundColor,
          tabActiveBackgroundColor: other.tabActiveBackgroundColor,
          tabPressedBackgroundColor: other.tabPressedBackgroundColor,
          tabDisabledBackgroundColor: other.tabDisabledBackgroundColor,
          tabDividerColor: other.tabDividerColor,
          accentColor: other.accentColor,
          closeButtonHoverBackgroundColor:
              other.closeButtonHoverBackgroundColor,
          menuBackgroundColor: other.menuBackgroundColor,
          menuBorderColor: other.menuBorderColor,
          menuHoverBackgroundColor: other.menuHoverBackgroundColor,
          menuTextColor: other.menuTextColor,
          menuIconColor: other.menuIconColor,
          menuIconBackgroundColor: other.menuIconBackgroundColor,
          menuShadow: other.menuShadow,
          tooltipBackgroundColor: other.tooltipBackgroundColor,
          tooltipBorderColor: other.tooltipBorderColor,
          tooltipTextColor: other.tooltipTextColor,
          tooltipShadow: other.tooltipShadow,
          scrollButtonWidth: other.scrollButtonWidth,
          closeButtonWidth: other.closeButtonWidth,
          closeButtonHeight: other.closeButtonHeight,
          iconSize: other.iconSize,
          newTabButtonSize: other.newTabButtonSize,
          groupButtonSize: other.groupButtonSize,
          tabDividerWidth: other.tabDividerWidth,
          tabDividerHeight: other.tabDividerHeight,
          menuRadius: other.menuRadius,
          tooltipRadius: other.tooltipRadius,
          controlRadius: other.controlRadius,
          tabContentPaddingX: other.tabContentPaddingX,
          tabIconGap: other.tabIconGap,
          tabCloseRight: other.tabCloseRight,
          groupContentPaddingRight: other.groupContentPaddingRight,
          menuPadding: other.menuPadding,
          menuItemPaddingX: other.menuItemPaddingX,
          menuItemPaddingY: other.menuItemPaddingY,
          tooltipPaddingX: other.tooltipPaddingX,
          tooltipPaddingY: other.tooltipPaddingY,
          tabEnterDuration: other.tabEnterDuration,
          tabCloseDuration: other.tabCloseDuration,
          tooltipMoveDuration: other.tooltipMoveDuration,
        );

  SemiResolvedChromeTabThemeData resolve(SemiThemeData theme) {
    final height = stripHeight ?? 38;
    return SemiResolvedChromeTabThemeData(
      stripHeight: height,
      stripBackgroundColor: stripBackgroundColor ?? theme.colors.colorBg2,
      tabHeight: tabHeight ?? height,
      tabMinWidth: tabMinWidth ?? 52,
      tabMaxWidth: tabMaxWidth ?? 120,
      tabRadius: tabRadius ?? 8,
      tabTextColor: tabTextColor ?? theme.colors.colorText2,
      tabActiveTextColor: tabActiveTextColor ?? theme.colors.colorText0,
      tabHoverTextColor: tabHoverTextColor ?? theme.colors.colorText0,
      tabPressedTextColor: tabPressedTextColor ?? theme.colors.colorText0,
      tabDisabledTextColor:
          tabDisabledTextColor ?? theme.colors.colorDisabledText,
      tabBackgroundColor: tabBackgroundColor ?? const Color(0x00000000),
      tabHoverBackgroundColor:
          tabHoverBackgroundColor ?? theme.colors.colorFill0,
      tabActiveBackgroundColor:
          tabActiveBackgroundColor ?? theme.colors.colorBg1,
      tabPressedBackgroundColor:
          tabPressedBackgroundColor ?? theme.colors.colorFill1,
      tabDisabledBackgroundColor:
          tabDisabledBackgroundColor ?? theme.colors.colorDisabledBg,
      tabDividerColor: tabDividerColor ?? theme.colors.colorBorder,
      accentColor: accentColor ?? theme.colors.colorPrimary,
      closeButtonHoverBackgroundColor:
          closeButtonHoverBackgroundColor ?? theme.colors.colorFill1,
      menuBackgroundColor: menuBackgroundColor ?? theme.colors.colorBg1,
      menuBorderColor: menuBorderColor ?? theme.colors.colorBorder,
      menuHoverBackgroundColor:
          menuHoverBackgroundColor ?? theme.colors.colorFill0,
      menuTextColor: menuTextColor ?? theme.colors.colorText0,
      menuIconColor: menuIconColor ?? theme.colors.colorText2,
      menuIconBackgroundColor:
          menuIconBackgroundColor ?? theme.colors.colorFill0,
      menuShadow: menuShadow ?? theme.shadows.shadowElevated,
      tooltipBackgroundColor: tooltipBackgroundColor ?? theme.colors.colorBg1,
      tooltipBorderColor: tooltipBorderColor ?? theme.colors.colorBorder,
      tooltipTextColor: tooltipTextColor ?? theme.colors.colorText2,
      tooltipShadow: tooltipShadow ?? theme.shadows.shadowElevated,
      scrollButtonWidth: scrollButtonWidth ?? 36,
      closeButtonWidth: closeButtonWidth ?? 18,
      closeButtonHeight: closeButtonHeight ?? 18,
      iconSize: iconSize ?? 16,
      newTabButtonSize: newTabButtonSize ?? 30,
      groupButtonSize: groupButtonSize ?? 30,
      tabDividerWidth: tabDividerWidth ?? 2,
      tabDividerHeight: tabDividerHeight ?? 18,
      menuRadius: menuRadius ?? 8,
      tooltipRadius: tooltipRadius ?? 12,
      controlRadius: controlRadius ?? 9,
      tabContentPaddingX: tabContentPaddingX ?? 6,
      tabIconGap: tabIconGap ?? 6,
      tabCloseRight: tabCloseRight ?? 4,
      groupContentPaddingRight: groupContentPaddingRight ?? 8,
      menuPadding: menuPadding ?? 6,
      menuItemPaddingX: menuItemPaddingX ?? 9,
      menuItemPaddingY: menuItemPaddingY ?? 7,
      tooltipPaddingX: tooltipPaddingX ?? 12,
      tooltipPaddingY: tooltipPaddingY ?? 8,
      tabEnterDuration: tabEnterDuration ?? const Duration(milliseconds: 160),
      tabCloseDuration: tabCloseDuration ?? const Duration(milliseconds: 140),
      tooltipMoveDuration:
          tooltipMoveDuration ?? const Duration(milliseconds: 140),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChromeTabThemeData &&
          stripHeight == other.stripHeight &&
          stripBackgroundColor == other.stripBackgroundColor &&
          tabHeight == other.tabHeight &&
          tabMinWidth == other.tabMinWidth &&
          tabMaxWidth == other.tabMaxWidth &&
          tabRadius == other.tabRadius &&
          tabTextColor == other.tabTextColor &&
          tabActiveTextColor == other.tabActiveTextColor &&
          tabHoverTextColor == other.tabHoverTextColor &&
          tabPressedTextColor == other.tabPressedTextColor &&
          tabDisabledTextColor == other.tabDisabledTextColor &&
          tabBackgroundColor == other.tabBackgroundColor &&
          tabHoverBackgroundColor == other.tabHoverBackgroundColor &&
          tabActiveBackgroundColor == other.tabActiveBackgroundColor &&
          tabPressedBackgroundColor == other.tabPressedBackgroundColor &&
          tabDisabledBackgroundColor == other.tabDisabledBackgroundColor &&
          tabDividerColor == other.tabDividerColor &&
          accentColor == other.accentColor &&
          closeButtonHoverBackgroundColor ==
              other.closeButtonHoverBackgroundColor &&
          menuBackgroundColor == other.menuBackgroundColor &&
          menuBorderColor == other.menuBorderColor &&
          menuHoverBackgroundColor == other.menuHoverBackgroundColor &&
          menuTextColor == other.menuTextColor &&
          menuIconColor == other.menuIconColor &&
          menuIconBackgroundColor == other.menuIconBackgroundColor &&
          menuShadow == other.menuShadow &&
          tooltipBackgroundColor == other.tooltipBackgroundColor &&
          tooltipBorderColor == other.tooltipBorderColor &&
          tooltipTextColor == other.tooltipTextColor &&
          tooltipShadow == other.tooltipShadow &&
          scrollButtonWidth == other.scrollButtonWidth &&
          closeButtonWidth == other.closeButtonWidth &&
          closeButtonHeight == other.closeButtonHeight &&
          iconSize == other.iconSize &&
          newTabButtonSize == other.newTabButtonSize &&
          groupButtonSize == other.groupButtonSize &&
          tabDividerWidth == other.tabDividerWidth &&
          tabDividerHeight == other.tabDividerHeight &&
          menuRadius == other.menuRadius &&
          tooltipRadius == other.tooltipRadius &&
          controlRadius == other.controlRadius &&
          tabContentPaddingX == other.tabContentPaddingX &&
          tabIconGap == other.tabIconGap &&
          tabCloseRight == other.tabCloseRight &&
          groupContentPaddingRight == other.groupContentPaddingRight &&
          menuPadding == other.menuPadding &&
          menuItemPaddingX == other.menuItemPaddingX &&
          menuItemPaddingY == other.menuItemPaddingY &&
          tooltipPaddingX == other.tooltipPaddingX &&
          tooltipPaddingY == other.tooltipPaddingY &&
          tabEnterDuration == other.tabEnterDuration &&
          tabCloseDuration == other.tabCloseDuration &&
          tooltipMoveDuration == other.tooltipMoveDuration;

  @override
  int get hashCode => Object.hashAll([
    stripHeight,
    stripBackgroundColor,
    tabHeight,
    tabMinWidth,
    tabMaxWidth,
    tabRadius,
    tabTextColor,
    tabActiveTextColor,
    tabHoverTextColor,
    tabPressedTextColor,
    tabDisabledTextColor,
    tabBackgroundColor,
    tabHoverBackgroundColor,
    tabActiveBackgroundColor,
    tabPressedBackgroundColor,
    tabDisabledBackgroundColor,
    tabDividerColor,
    accentColor,
    closeButtonHoverBackgroundColor,
    menuBackgroundColor,
    menuBorderColor,
    menuHoverBackgroundColor,
    menuTextColor,
    menuIconColor,
    menuIconBackgroundColor,
    menuShadow,
    tooltipBackgroundColor,
    tooltipBorderColor,
    tooltipTextColor,
    tooltipShadow,
    scrollButtonWidth,
    closeButtonWidth,
    closeButtonHeight,
    iconSize,
    newTabButtonSize,
    groupButtonSize,
    tabDividerWidth,
    tabDividerHeight,
    menuRadius,
    tooltipRadius,
    controlRadius,
    tabContentPaddingX,
    tabIconGap,
    tabCloseRight,
    groupContentPaddingRight,
    menuPadding,
    menuItemPaddingX,
    menuItemPaddingY,
    tooltipPaddingX,
    tooltipPaddingY,
    tabEnterDuration,
    tabCloseDuration,
    tooltipMoveDuration,
  ]);
}

/// Non-null values consumed by ChromeTab after theme defaults are resolved.
@immutable
class SemiResolvedChromeTabThemeData {
  const SemiResolvedChromeTabThemeData({
    required this.stripHeight,
    required this.stripBackgroundColor,
    required this.tabHeight,
    required this.tabMinWidth,
    required this.tabMaxWidth,
    required this.tabRadius,
    required this.tabTextColor,
    required this.tabActiveTextColor,
    required this.tabHoverTextColor,
    required this.tabPressedTextColor,
    required this.tabDisabledTextColor,
    required this.tabBackgroundColor,
    required this.tabHoverBackgroundColor,
    required this.tabActiveBackgroundColor,
    required this.tabPressedBackgroundColor,
    required this.tabDisabledBackgroundColor,
    required this.tabDividerColor,
    required this.accentColor,
    required this.closeButtonHoverBackgroundColor,
    required this.menuBackgroundColor,
    required this.menuBorderColor,
    required this.menuHoverBackgroundColor,
    required this.menuTextColor,
    required this.menuIconColor,
    required this.menuIconBackgroundColor,
    required this.menuShadow,
    required this.tooltipBackgroundColor,
    required this.tooltipBorderColor,
    required this.tooltipTextColor,
    required this.tooltipShadow,
    required this.scrollButtonWidth,
    required this.closeButtonWidth,
    required this.closeButtonHeight,
    required this.iconSize,
    required this.newTabButtonSize,
    required this.groupButtonSize,
    required this.tabDividerWidth,
    required this.tabDividerHeight,
    required this.menuRadius,
    required this.tooltipRadius,
    required this.controlRadius,
    required this.tabContentPaddingX,
    required this.tabIconGap,
    required this.tabCloseRight,
    required this.groupContentPaddingRight,
    required this.menuPadding,
    required this.menuItemPaddingX,
    required this.menuItemPaddingY,
    required this.tooltipPaddingX,
    required this.tooltipPaddingY,
    required this.tabEnterDuration,
    required this.tabCloseDuration,
    required this.tooltipMoveDuration,
  });

  final double stripHeight;
  final Color stripBackgroundColor;
  final double tabHeight;
  final double tabMinWidth;
  final double tabMaxWidth;
  final double tabRadius;
  final Color tabTextColor;
  final Color tabActiveTextColor;
  final Color tabHoverTextColor;
  final Color tabPressedTextColor;
  final Color tabDisabledTextColor;
  final Color tabBackgroundColor;
  final Color tabHoverBackgroundColor;
  final Color tabActiveBackgroundColor;
  final Color tabPressedBackgroundColor;
  final Color tabDisabledBackgroundColor;
  final Color tabDividerColor;
  final Color accentColor;
  final Color closeButtonHoverBackgroundColor;
  final Color menuBackgroundColor;
  final Color menuBorderColor;
  final Color menuHoverBackgroundColor;
  final Color menuTextColor;
  final Color menuIconColor;
  final Color menuIconBackgroundColor;
  final SemiShadows menuShadow;
  final Color tooltipBackgroundColor;
  final Color tooltipBorderColor;
  final Color tooltipTextColor;
  final SemiShadows tooltipShadow;
  final double scrollButtonWidth;
  final double closeButtonWidth;
  final double closeButtonHeight;
  final double iconSize;
  final double newTabButtonSize;
  final double groupButtonSize;
  final double tabDividerWidth;
  final double tabDividerHeight;
  final double menuRadius;
  final double tooltipRadius;
  final double controlRadius;
  final double tabContentPaddingX;
  final double tabIconGap;
  final double tabCloseRight;
  final double groupContentPaddingRight;
  final double menuPadding;
  final double menuItemPaddingX;
  final double menuItemPaddingY;
  final double tooltipPaddingX;
  final double tooltipPaddingY;
  final Duration tabEnterDuration;
  final Duration tabCloseDuration;
  final Duration tooltipMoveDuration;
}
