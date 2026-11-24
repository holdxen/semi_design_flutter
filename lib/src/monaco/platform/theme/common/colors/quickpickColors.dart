// 1:1 port of vscode/src/vs/platform/theme/common/colors/quickpickColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String quickInputBackground = registerColor(
    'quickInput.background', 'editorWidget.background', 'Quick picker background color. The quick picker widget is the container for pickers like the command palette.');
final String quickInputForeground = registerColor(
    'quickInput.foreground', 'editorWidget.foreground', 'Quick picker foreground color. The quick picker widget is the container for pickers like the command palette.');
final String quickInputTitleBackground = registerColor(
    'quickInputTitle.background', ColorDefaults(light: Color(RGBA(0, 0, 0, 0.06)), dark: Color(RGBA(255, 255, 255, 0.105)), hcDark: '#000000', hcLight: Color(RGBA(255, 255, 255, 1))), 'Quick picker title background color. The quick picker widget is the container for pickers like the command palette.');
final String pickerGroupForeground = registerColor(
    'pickerGroup.foreground', ColorDefaults(light: '#0066BF', dark: '#3794FF', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: '#0F4A85'), 'Quick picker color for grouping labels.');
final String pickerGroupBorder = registerColor(
    'pickerGroup.border', ColorDefaults(light: '#CCCEDB', dark: '#3F3F46', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: '#0F4A85'), 'Quick picker color for grouping borders.');
final String deprecatedQuickInputListFocusBackground = registerColor(
    'quickInput.list.focusBackground', null, '', false, 'Please use quickInputList.focusBackground instead');
final String quickInputListFocusForeground = registerColor(
    'quickInputList.focusForeground', 'list.activeSelectionForeground', 'Quick picker foreground color for the focused item.');
final String quickInputListFocusIconForeground = registerColor(
    'quickInputList.focusIconForeground', 'list.activeSelectionIconForeground', 'Quick picker icon foreground color for the focused item.');
final String quickInputListFocusBackground = registerColor(
    'quickInputList.focusBackground', ColorDefaults(light: oneOf(<Object?>['quickInput.list.focusBackground', 'list.activeSelectionBackground']), dark: oneOf(<Object?>['quickInput.list.focusBackground', 'list.activeSelectionBackground']), hcDark: null, hcLight: null), 'Quick picker background color for the focused item.');
final String quickInputListFocusHighlightForeground = registerColor(
    'quickInputList.focusHighlightForeground', 'list.focusHighlightForeground', 'Quick picker foreground color of the match highlights on the focused item.');
