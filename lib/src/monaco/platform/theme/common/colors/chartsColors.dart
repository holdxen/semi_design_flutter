// 1:1 port of vscode/src/vs/platform/theme/common/colors/chartsColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String chartsForeground = registerColor(
    'charts.foreground', 'foreground', 'The foreground color used in charts.');
final String chartsLines = registerColor(
    'charts.lines', transparent('foreground', 0.5), 'The color used for horizontal lines in charts.');
final String chartsRed = registerColor(
    'charts.red', 'editorError.foreground', 'The red color used in chart visualizations.');
final String chartsBlue = registerColor(
    'charts.blue', 'editorInfo.foreground', 'The blue color used in chart visualizations.');
final String chartsYellow = registerColor(
    'charts.yellow', 'editorWarning.foreground', 'The yellow color used in chart visualizations.');
final String chartsOrange = registerColor(
    'charts.orange', ColorDefaults(light: '#D18616', dark: '#D18616', hcDark: '#AB5A00', hcLight: '#0F4A85'), 'The orange color used in chart visualizations.');
final String chartsGreen = registerColor(
    'charts.green', ColorDefaults(light: '#388A34', dark: '#89D185', hcDark: '#89D185', hcLight: '#374e06'), 'The green color used in chart visualizations.');
final String chartsPurple = registerColor(
    'charts.purple', ColorDefaults(light: '#652D90', dark: '#B180D7', hcDark: '#B180D7', hcLight: '#652D90'), 'The purple color used in chart visualizations.');
