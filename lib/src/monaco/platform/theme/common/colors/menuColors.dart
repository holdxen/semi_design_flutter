// 1:1 port of vscode/src/vs/platform/theme/common/colors/menuColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String menuBorder = registerColor(
    'menu.border', ColorDefaults(light: null, dark: null, hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Border color of menus.');
final String menuForeground = registerColor(
    'menu.foreground', 'dropdown.foreground', 'Foreground color of menu items.');
final String menuBackground = registerColor(
    'menu.background', 'dropdown.background', 'Background color of menu items.');
final String menuSelectionForeground = registerColor(
    'menu.selectionForeground', 'list.activeSelectionForeground', 'Foreground color of the selected menu item in menus.');
final String menuSelectionBackground = registerColor(
    'menu.selectionBackground', 'list.activeSelectionBackground', 'Background color of the selected menu item in menus.');
final String menuSelectionBorder = registerColor(
    'menu.selectionBorder', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Border color of the selected menu item in menus.');
final String menuSeparatorBackground = registerColor(
    'menu.separatorBackground', ColorDefaults(light: transparent('foreground', 0.2), dark: transparent('foreground', 0.2), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Color of a separator menu item in menus.');
