// 1:1 port of vscode/src/vs/platform/theme/common/colors/inputColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String inputBackground = registerColor(
    'input.background', ColorDefaults(light: Color(RGBA(255, 255, 255, 1)), dark: '#3C3C3C', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Input box background.');
final String inputForeground = registerColor(
    'input.foreground', 'foreground', 'Input box foreground.');
final String inputBorder = registerColor(
    'input.border', ColorDefaults(light: null, dark: null, hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Input box border.');
final String inputActiveOptionBorder = registerColor(
    'inputOption.activeBorder', ColorDefaults(light: '#007ACC', dark: '#007ACC', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Border color of activated options in input fields.');
final String inputActiveOptionHoverBackground = registerColor(
    'inputOption.hoverBackground', ColorDefaults(light: '#b8b8b850', dark: '#5a5d5e80', hcDark: null, hcLight: null), 'Background color of activated options in input fields.');
final String inputActiveOptionBackground = registerColor(
    'inputOption.activeBackground', ColorDefaults(light: transparent('focusBorder', 0.2), dark: transparent('focusBorder', 0.4), hcDark: Color(RGBA(0, 0, 0, 0)), hcLight: Color(RGBA(0, 0, 0, 0))), 'Background hover color of options in input fields.');
final String inputActiveOptionForeground = registerColor(
    'inputOption.activeForeground', ColorDefaults(light: Color(RGBA(0, 0, 0, 1)), dark: Color(RGBA(255, 255, 255, 1)), hcDark: 'foreground', hcLight: 'foreground'), 'Foreground color of activated options in input fields.');
final String inputPlaceholderForeground = registerColor(
    'input.placeholderForeground', ColorDefaults(light: transparent('foreground', 0.5), dark: transparent('foreground', 0.5), hcDark: transparent('foreground', 0.7), hcLight: transparent('foreground', 0.7)), 'Input box foreground color for placeholder text.');
final String inputValidationInfoBackground = registerColor(
    'inputValidation.infoBackground', ColorDefaults(light: '#D6ECF2', dark: '#063B49', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Input validation background color for information severity.');
final String inputValidationInfoForeground = registerColor(
    'inputValidation.infoForeground', ColorDefaults(light: null, dark: null, hcDark: null, hcLight: 'foreground'), 'Input validation foreground color for information severity.');
final String inputValidationInfoBorder = registerColor(
    'inputValidation.infoBorder', ColorDefaults(light: '#007acc', dark: '#007acc', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Input validation border color for information severity.');
final String inputValidationWarningBackground = registerColor(
    'inputValidation.warningBackground', ColorDefaults(light: '#F6F5D2', dark: '#352A05', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Input validation background color for warning severity.');
final String inputValidationWarningForeground = registerColor(
    'inputValidation.warningForeground', ColorDefaults(light: null, dark: null, hcDark: null, hcLight: 'foreground'), 'Input validation foreground color for warning severity.');
final String inputValidationWarningBorder = registerColor(
    'inputValidation.warningBorder', ColorDefaults(light: '#B89500', dark: '#B89500', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Input validation border color for warning severity.');
final String inputValidationErrorBackground = registerColor(
    'inputValidation.errorBackground', ColorDefaults(light: '#F2DEDE', dark: '#5A1D1D', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Input validation background color for error severity.');
final String inputValidationErrorForeground = registerColor(
    'inputValidation.errorForeground', ColorDefaults(light: null, dark: null, hcDark: null, hcLight: 'foreground'), 'Input validation foreground color for error severity.');
final String inputValidationErrorBorder = registerColor(
    'inputValidation.errorBorder', ColorDefaults(light: '#BE1100', dark: '#BE1100', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Input validation border color for error severity.');
final String selectBackground = registerColor(
    'dropdown.background', ColorDefaults(light: Color(RGBA(255, 255, 255, 1)), dark: '#3C3C3C', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Dropdown background.');
final String selectListBackground = registerColor(
    'dropdown.listBackground', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Dropdown list background.');
final String selectForeground = registerColor(
    'dropdown.foreground', ColorDefaults(light: 'foreground', dark: '#F0F0F0', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: 'foreground'), 'Dropdown foreground.');
final String selectBorder = registerColor(
    'dropdown.border', ColorDefaults(light: '#CECECE', dark: 'dropdown.background', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Dropdown border.');
final String buttonForeground = registerColor(
    'button.foreground', {}, 'Button foreground color.');
final String buttonSeparator = registerColor(
    'button.separator', ColorDefaults(light: transparent('button.foreground', 0.4), dark: transparent('button.foreground', 0.4), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Button separator color.');
final String buttonBackground = registerColor(
    'button.background', ColorDefaults(light: '#007ACC', dark: '#0E639C', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: '#0F4A85'), 'Button background color.');
final String buttonHoverBackground = registerColor(
    'button.hoverBackground', ColorDefaults(light: darken('button.background', 0.2), dark: lighten('button.background', 0.2), hcDark: 'button.background', hcLight: 'button.background'), 'Button background color when hovering.');
final String buttonBorder = registerColor(
    'button.border', 'contrastBorder', 'Button border color.');
final String buttonSecondaryForeground = registerColor(
    'button.secondaryForeground', ColorDefaults(light: 'foreground', dark: 'foreground', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: 'foreground'), 'Secondary button foreground color.');
final String buttonSecondaryBackground = registerColor(
    'button.secondaryBackground', ColorDefaults(light: 'list.hoverBackground', dark: 'list.hoverBackground', hcDark: null, hcLight: Color(RGBA(255, 255, 255, 1))), 'Secondary button background color.');
final String buttonSecondaryBorder = registerColor(
    'button.secondaryBorder', ColorDefaults(light: transparent('foreground', 0.15), dark: transparent('foreground', 0.15), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Secondary button border color.');
final String buttonSecondaryHoverBackground = registerColor(
    'button.secondaryHoverBackground', ColorDefaults(light: lighten('list.hoverBackground', 0.2), dark: lighten('list.hoverBackground', 0.2), hcDark: null, hcLight: null), 'Secondary button background color when hovering.');
final String radioActiveForeground = registerColor(
    'radio.activeForeground', 'inputOption.activeForeground', 'Foreground color of active radio option.');
final String radioActiveBackground = registerColor(
    'radio.activeBackground', 'inputOption.activeBackground', 'Background color of active radio option.');
final String radioActiveBorder = registerColor(
    'radio.activeBorder', 'inputOption.activeBorder', 'Border color of the active radio option.');
final String radioInactiveForeground = registerColor(
    'radio.inactiveForeground', null, 'Foreground color of inactive radio option.');
final String radioInactiveBackground = registerColor(
    'radio.inactiveBackground', null, 'Background color of inactive radio option.');
final String radioInactiveBorder = registerColor(
    'radio.inactiveBorder', ColorDefaults(light: transparent('radio.activeForeground', 0.2), dark: transparent('radio.activeForeground', 0.2), hcDark: transparent('radio.activeForeground', 0.4), hcLight: transparent('radio.activeForeground', 0.2)), 'Border color of the inactive radio option.');
final String radioInactiveHoverBackground = registerColor(
    'radio.inactiveHoverBackground', 'inputOption.hoverBackground', 'Background color of inactive active radio option when hovering.');
final String checkboxBackground = registerColor(
    'checkbox.background', 'dropdown.background', 'Background color of checkbox widget.');
final String checkboxSelectBackground = registerColor(
    'checkbox.selectBackground', 'editorWidget.background', 'Background color of checkbox widget when the element it\'s in is selected.');
final String checkboxForeground = registerColor(
    'checkbox.foreground', 'dropdown.foreground', 'Foreground color of checkbox widget.');
final String checkboxBorder = registerColor(
    'checkbox.border', 'dropdown.border', 'Border color of checkbox widget.');
final String checkboxSelectBorder = registerColor(
    'checkbox.selectBorder', 'icon.foreground', 'Border color of checkbox widget when the element it\'s in is selected.');
final String checkboxDisabledBackground = registerColor(
    'checkbox.disabled.background', ColorTransform(op: ColorTransformType.Mix, color: 'checkbox.background', withColor: 'checkbox.foreground', ratio: 0.33), 'Background of a disabled checkbox.');
final String checkboxDisabledForeground = registerColor(
    'checkbox.disabled.foreground', ColorTransform(op: ColorTransformType.Mix, color: 'checkbox.foreground', withColor: 'checkbox.background', ratio: 0.33), 'Foreground of a disabled checkbox.');
final String keybindingLabelBackground = registerColor(
    'keybindingLabel.background', ColorDefaults(light: Color(RGBA(221, 221, 221, 0.4)), dark: Color(RGBA(128, 128, 128, 0.17)), hcDark: Color(RGBA(0, 0, 0, 0)), hcLight: Color(RGBA(0, 0, 0, 0))), 'Keybinding label background color. The keybinding label is used to represent a keyboard shortcut.');
final String keybindingLabelForeground = registerColor(
    'keybindingLabel.foreground', ColorDefaults(light: Color(RGBA(85, 85, 85, 1)), dark: Color(RGBA(204, 204, 204, 1)), hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: 'foreground'), 'Keybinding label foreground color. The keybinding label is used to represent a keyboard shortcut.');
final String keybindingLabelBorder = registerColor(
    'keybindingLabel.border', ColorDefaults(light: Color(RGBA(204, 204, 204, 0.4)), dark: Color(RGBA(51, 51, 51, 0.6)), hcDark: Color(RGBA(111, 195, 223, 1)), hcLight: 'contrastBorder'), 'Keybinding label border color. The keybinding label is used to represent a keyboard shortcut.');
final String keybindingLabelBottomBorder = registerColor(
    'keybindingLabel.bottomBorder', ColorDefaults(light: Color(RGBA(187, 187, 187, 0.4)), dark: Color(RGBA(68, 68, 68, 0.6)), hcDark: Color(RGBA(111, 195, 223, 1)), hcLight: 'foreground'), 'Keybinding label border bottom color. The keybinding label is used to represent a keyboard shortcut.');
