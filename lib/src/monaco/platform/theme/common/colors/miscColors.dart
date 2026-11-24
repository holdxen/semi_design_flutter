// 1:1 port of vscode/src/vs/platform/theme/common/colors/miscColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String sashHoverBorder = registerColor(
    'sash.hoverBorder', 'focusBorder', 'Border color of active sashes.');
final String badgeBackground = registerColor(
    'badge.background', ColorDefaults(light: '#C4C4C4', dark: '#4D4D4D', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: '#0F4A85'), 'Badge background color. Badges are small information labels, e.g. for search results count.');
final String badgeForeground = registerColor(
    'badge.foreground', ColorDefaults(light: '#333', dark: Color(RGBA(255, 255, 255, 1)), hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Badge foreground color. Badges are small information labels, e.g. for search results count.');
final String activityWarningBadgeForeground = registerColor(
    'activityWarningBadge.foreground', ColorDefaults(light: Color(RGBA(255, 255, 255, 1)), dark: Color(RGBA(255, 255, 255, 1)), hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Foreground color of the warning activity badge');
final String activityWarningBadgeBackground = registerColor(
    'activityWarningBadge.background', ColorDefaults(light: '#B27C00', dark: '#B27C00', hcDark: null, hcLight: '#B27C00'), 'Background color of the warning activity badge');
final String activityErrorBadgeForeground = registerColor(
    'activityErrorBadge.foreground', ColorDefaults(light: Color(RGBA(255, 255, 255, 1)), dark: Color(RGBA(0, 0, 0, 1)), hcDark: null, hcLight: Color(RGBA(0, 0, 0, 1))), 'Foreground color of the error activity badge');
final String activityErrorBadgeBackground = registerColor(
    'activityErrorBadge.background', ColorDefaults(light: '#E51400', dark: '#F14C4C', hcDark: null, hcLight: '#F14C4C'), 'Background color of the error activity badge');
final String scrollbarShadow = registerColor(
    'scrollbar.shadow', ColorDefaults(light: '#DDDDDD', dark: '#000000', hcDark: null, hcLight: null), 'Scrollbar shadow to indicate that the view is scrolled.');
final String scrollbarSliderBackground = registerColor(
    'scrollbarSlider.background', ColorDefaults(light: Color(RGBA(100, 100, 100, 0.4)), dark: Color(RGBA(121, 121, 121, 0.4)), hcDark: transparent('contrastBorder', 0.6), hcLight: transparent('contrastBorder', 0.4)), 'Scrollbar slider background color.');
final String scrollbarSliderHoverBackground = registerColor(
    'scrollbarSlider.hoverBackground', ColorDefaults(light: Color(RGBA(100, 100, 100, 0.7)), dark: Color(RGBA(100, 100, 100, 0.7)), hcDark: transparent('contrastBorder', 0.8), hcLight: transparent('contrastBorder', 0.8)), 'Scrollbar slider background color when hovering.');
final String scrollbarSliderActiveBackground = registerColor(
    'scrollbarSlider.activeBackground', ColorDefaults(light: Color(RGBA(0, 0, 0, 0.6)), dark: Color(RGBA(191, 191, 191, 0.4)), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Scrollbar slider background color when clicked on.');
final String scrollbarBackground = registerColor(
    'scrollbar.background', null, 'Scrollbar track background color.');
final String progressBarBackground = registerColor(
    'progressBar.background', ColorDefaults(light: Color(RGBA(14, 112, 192, 1)), dark: Color(RGBA(14, 112, 192, 1)), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Background color of the progress bar that can show for long running operations.');
final String chartLine = registerColor(
    'chart.line', ColorDefaults(light: '#236B8E', dark: '#236B8E', hcDark: '#236B8E', hcLight: '#236B8E'), 'Line color for the chart.');
final String chartAxis = registerColor(
    'chart.axis', ColorDefaults(light: Color(RGBA(0, 0, 0, 0.6)), dark: Color(RGBA(191, 191, 191, 0.4)), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Axis color for the chart.');
final String chartGuide = registerColor(
    'chart.guide', ColorDefaults(light: Color(RGBA(0, 0, 0, 0.2)), dark: Color(RGBA(191, 191, 191, 0.2)), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Guide line for the chart.');
