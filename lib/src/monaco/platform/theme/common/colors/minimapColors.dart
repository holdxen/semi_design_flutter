// 1:1 port of vscode/src/vs/platform/theme/common/colors/minimapColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String minimapFindMatch = registerColor(
    'minimap.findMatchHighlight', ColorDefaults(light: withOpacity('editorOverviewRuler.findMatchForeground', 0.8), dark: withOpacity('editorOverviewRuler.findMatchForeground', 0.8), hcDark: 'editor.findMatchHighlightBorder', hcLight: 'editor.findMatchHighlightBorder'), 'Minimap marker color for find matches. In light and dark themes, the default uses the overview ruler search match color at 80% opacity.', true);
final String minimapSelectionOccurrenceHighlight = registerColor(
    'minimap.selectionOccurrenceHighlight', 'editor.selectionHighlightBackground', 'Minimap marker color for repeating editor selections.', true);
final String minimapSelection = registerColor(
    'minimap.selectionHighlight', 'editor.selectionBackground', 'Minimap marker color for the editor selection.', true);
final String minimapInfo = registerColor(
    'minimap.infoHighlight', ColorDefaults(light: 'editorInfo.foreground', dark: 'editorInfo.foreground', hcDark: 'editorInfo.border', hcLight: 'editorInfo.border'), 'Minimap marker color for infos.');
final String minimapWarning = registerColor(
    'minimap.warningHighlight', ColorDefaults(light: 'editorWarning.foreground', dark: 'editorWarning.foreground', hcDark: 'editorWarning.border', hcLight: 'editorWarning.border'), 'Minimap marker color for warnings.');
final String minimapError = registerColor(
    'minimap.errorHighlight', ColorDefaults(light: Color(RGBA(255, 18, 18, 0.7)), dark: Color(RGBA(255, 18, 18, 0.7)), hcDark: Color(RGBA(255, 50, 50, 1)), hcLight: '#B5200D'), 'Minimap marker color for errors.');
final String minimapBackground = registerColor(
    'minimap.background', null, 'Minimap background color.');
final String minimapForegroundOpacity = registerColor(
    'minimap.foregroundOpacity', {}, 'Opacity of foreground elements rendered in the minimap. For example, "#000000c0" will render the elements with 75% opacity.');
final String minimapSliderBackground = registerColor(
    'minimapSlider.background', transparent('scrollbarSlider.background', 0.5), 'Minimap slider background color.');
final String minimapSliderHoverBackground = registerColor(
    'minimapSlider.hoverBackground', transparent('scrollbarSlider.hoverBackground', 0.5), 'Minimap slider background color when hovering.');
final String minimapSliderActiveBackground = registerColor(
    'minimapSlider.activeBackground', transparent('scrollbarSlider.activeBackground', 0.5), 'Minimap slider background color when clicked on.');
