// 1:1 port of vscode/src/vs/platform/theme/common/colors/searchColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String searchResultsInfoForeground = registerColor(
    'search.resultsInfoForeground', ColorDefaults(light: 'foreground', dark: transparent('foreground', 0.65), hcDark: 'foreground', hcLight: 'foreground'), 'Color of the text in the search viewlet\'s completion message.');
final String searchEditorFindMatch = registerColor(
    'searchEditor.findMatchBackground', ColorDefaults(light: transparent('editor.findMatchHighlightBackground', 0.66), dark: transparent('editor.findMatchHighlightBackground', 0.66), hcDark: 'editor.findMatchHighlightBackground', hcLight: 'editor.findMatchHighlightBackground'), 'Color of the Search Editor query matches.');
final String searchEditorFindMatchBorder = registerColor(
    'searchEditor.findMatchBorder', ColorDefaults(light: transparent('editor.findMatchHighlightBorder', 0.66), dark: transparent('editor.findMatchHighlightBorder', 0.66), hcDark: 'editor.findMatchHighlightBorder', hcLight: 'editor.findMatchHighlightBorder'), 'Border color of the Search Editor query matches.');
