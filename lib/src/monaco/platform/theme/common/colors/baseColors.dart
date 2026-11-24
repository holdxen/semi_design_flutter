// 1:1 port of vscode/src/vs/platform/theme/common/colors/baseColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String foreground = registerColor(
    'foreground', ColorDefaults(light: '#616161', dark: '#CCCCCC', hcDark: '#FFFFFF', hcLight: '#292929'), 'Overall foreground color. This color is only used if not overridden by a component.');
final String strongForeground = registerColor(
    'strongForeground', ColorDefaults(light: '#000000', dark: '#FFFFFF', hcDark: '#FFFFFF', hcLight: '#000000'), 'Highest-contrast foreground color, intended for text or icons that need maximum legibility across various backgrounds. This color is only used if not overridden by a component.');
final String disabledForeground = registerColor(
    'disabledForeground', ColorDefaults(light: '#61616180', dark: '#CCCCCC80', hcDark: '#A5A5A5', hcLight: '#7F7F7F'), 'Overall foreground for disabled elements. This color is only used if not overridden by a component.');
final String errorForeground = registerColor(
    'errorForeground', ColorDefaults(light: '#A1260D', dark: '#F48771', hcDark: '#F48771', hcLight: '#B5200D'), 'Overall foreground color for error messages. This color is only used if not overridden by a component.');
final String descriptionForeground = registerColor(
    'descriptionForeground', ColorDefaults(light: '#717171', dark: transparent('foreground', 0.7), hcDark: transparent('foreground', 0.7), hcLight: transparent('foreground', 0.7)), 'Foreground color for description text providing additional information, for example for a label.');
final String iconForeground = registerColor(
    'icon.foreground', ColorDefaults(light: '#424242', dark: '#C5C5C5', hcDark: '#FFFFFF', hcLight: '#292929'), 'The default color for icons in the workbench.');
final String focusBorder = registerColor(
    'focusBorder', ColorDefaults(light: '#0090F1', dark: '#007FD4', hcDark: '#F38518', hcLight: '#006BBD'), 'Overall border color for focused elements. This color is only used if not overridden by a component.');
final String contrastBorder = registerColor(
    'contrastBorder', ColorDefaults(light: null, dark: null, hcDark: '#6FC3DF', hcLight: '#0F4A85'), 'An extra border around elements to separate them from others for greater contrast.');
final String activeContrastBorder = registerColor(
    'contrastActiveBorder', ColorDefaults(light: null, dark: null, hcDark: 'focusBorder', hcLight: 'focusBorder'), 'An extra border around active elements to separate them from others for greater contrast.');
final String selectionBackground = registerColor(
    'selection.background', null, 'The background color of text selections in the workbench (e.g. for input fields or text areas). Note that this does not apply to selections within the editor.');
final String textLinkForeground = registerColor(
    'textLink.foreground', ColorDefaults(light: '#006AB1', dark: '#3794FF', hcDark: '#21A6FF', hcLight: '#0F4A85'), 'Foreground color for links in text.');
final String textLinkActiveForeground = registerColor(
    'textLink.activeForeground', ColorDefaults(light: '#006AB1', dark: '#3794FF', hcDark: '#21A6FF', hcLight: '#0F4A85'), 'Foreground color for links in text when clicked on and on mouse hover.');
final String textSeparatorForeground = registerColor(
    'textSeparator.foreground', ColorDefaults(light: '#0000002e', dark: '#ffffff2e', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: '#292929'), 'Color for text separators.');
final String textPreformatForeground = registerColor(
    'textPreformat.foreground', ColorDefaults(light: '#A31515', dark: '#D7BA7D', hcDark: '#FFFFFF', hcLight: '#FFFFFF'), 'Foreground color for preformatted text segments.');
final String textPreformatBackground = registerColor(
    'textPreformat.background', ColorDefaults(light: '#0000001A', dark: '#FFFFFF1A', hcDark: null, hcLight: '#09345f'), 'Background color for preformatted text segments.');
final String textPreformatBorder = registerColor(
    'textPreformat.border', ColorDefaults(light: null, dark: null, hcDark: 'contrastBorder', hcLight: null), 'Border color for preformatted text segments.');
final String textBlockQuoteBackground = registerColor(
    'textBlockQuote.background', ColorDefaults(light: '#f2f2f2', dark: '#222222', hcDark: null, hcLight: '#F2F2F2'), 'Background color for block quotes in text.');
final String textBlockQuoteBorder = registerColor(
    'textBlockQuote.border', ColorDefaults(light: '#007acc80', dark: '#007acc80', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: '#292929'), 'Border color for block quotes in text.');
final String textCodeBlockBackground = registerColor(
    'textCodeBlock.background', ColorDefaults(light: '#dcdcdc66', dark: '#0a0a0a66', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: '#F2F2F2'), 'Background color for code blocks in text.');
