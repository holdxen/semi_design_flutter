// 1:1 port of vscode/src/vs/platform/theme/common/colors/listColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final String listFocusBackground = registerColor(
    'list.focusBackground', null, 'List/Tree background color for the focused item when the list/tree is active. An active list/tree has keyboard focus, an inactive does not.');
final String listFocusForeground = registerColor(
    'list.focusForeground', null, 'List/Tree foreground color for the focused item when the list/tree is active. An active list/tree has keyboard focus, an inactive does not.');
final String listFocusOutline = registerColor(
    'list.focusOutline', ColorDefaults(light: 'focusBorder', dark: 'focusBorder', hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'List/Tree outline color for the focused item when the list/tree is active. An active list/tree has keyboard focus, an inactive does not.');
final String listFocusAndSelectionOutline = registerColor(
    'list.focusAndSelectionOutline', null, 'List/Tree outline color for the focused item when the list/tree is active and selected. An active list/tree has keyboard focus, an inactive does not.');
final String listActiveSelectionBackground = registerColor(
    'list.activeSelectionBackground', ColorDefaults(light: '#0060C0', dark: '#04395E', hcDark: null, hcLight: Color(RGBA(15, 74, 133, 0.1))), 'List/Tree background color for the selected item when the list/tree is active. An active list/tree has keyboard focus, an inactive does not.');
final String listActiveSelectionForeground = registerColor(
    'list.activeSelectionForeground', ColorDefaults(light: Color(RGBA(255, 255, 255, 1)), dark: Color(RGBA(255, 255, 255, 1)), hcDark: null, hcLight: null), 'List/Tree foreground color for the selected item when the list/tree is active. An active list/tree has keyboard focus, an inactive does not.');
final String listActiveSelectionIconForeground = registerColor(
    'list.activeSelectionIconForeground', null, 'List/Tree icon foreground color for the selected item when the list/tree is active. An active list/tree has keyboard focus, an inactive does not.');
final String listInactiveSelectionBackground = registerColor(
    'list.inactiveSelectionBackground', ColorDefaults(light: '#E4E6F1', dark: '#37373D', hcDark: null, hcLight: Color(RGBA(15, 74, 133, 0.1))), 'List/Tree background color for the selected item when the list/tree is inactive. An active list/tree has keyboard focus, an inactive does not.');
final String listInactiveSelectionForeground = registerColor(
    'list.inactiveSelectionForeground', null, 'List/Tree foreground color for the selected item when the list/tree is inactive. An active list/tree has keyboard focus, an inactive does not.');
final String listInactiveSelectionIconForeground = registerColor(
    'list.inactiveSelectionIconForeground', null, 'List/Tree icon foreground color for the selected item when the list/tree is inactive. An active list/tree has keyboard focus, an inactive does not.');
final String listInactiveFocusBackground = registerColor(
    'list.inactiveFocusBackground', null, 'List/Tree background color for the focused item when the list/tree is inactive. An active list/tree has keyboard focus, an inactive does not.');
final String listInactiveFocusOutline = registerColor(
    'list.inactiveFocusOutline', null, 'List/Tree outline color for the focused item when the list/tree is inactive. An active list/tree has keyboard focus, an inactive does not.');
final String listHoverBackground = registerColor(
    'list.hoverBackground', ColorDefaults(light: '#F0F0F0', dark: '#2A2D2E', hcDark: Color(RGBA(255, 255, 255, 0.1)), hcLight: Color(RGBA(15, 74, 133, 0.1))), 'List/Tree background when hovering over items using the mouse.');
final String listHoverForeground = registerColor(
    'list.hoverForeground', null, 'List/Tree foreground when hovering over items using the mouse.');
final String listDropOverBackground = registerColor(
    'list.dropBackground', ColorDefaults(light: '#D6EBFF', dark: '#062F4A', hcDark: null, hcLight: null), 'List/Tree drag and drop background when moving items over other items when using the mouse.');
final String listDropBetweenBackground = registerColor(
    'list.dropBetweenBackground', ColorDefaults(light: 'icon.foreground', dark: 'icon.foreground', hcDark: null, hcLight: null), 'List/Tree drag and drop border color when moving items between items when using the mouse.');
final String listHighlightForeground = registerColor(
    'list.highlightForeground', ColorDefaults(light: '#0066BF', dark: '#2AAAFF', hcDark: 'focusBorder', hcLight: 'focusBorder'), 'List/Tree foreground color of the match highlights when searching inside the list/tree.');
final String listFocusHighlightForeground = registerColor(
    'list.focusHighlightForeground', ColorDefaults(light: ifDefinedThenElse('list.activeSelectionBackground', 'list.highlightForeground', '#BBE7FF'), dark: 'list.highlightForeground', hcDark: 'list.highlightForeground', hcLight: 'list.highlightForeground'), 'List/Tree foreground color of the match highlights on actively focused items when searching inside the list/tree.');
final String listInvalidItemForeground = registerColor(
    'list.invalidItemForeground', ColorDefaults(light: '#B89500', dark: '#B89500', hcDark: '#B89500', hcLight: '#B5200D'), 'List/Tree foreground color for invalid items, for example an unresolved root in explorer.');
final String listErrorForeground = registerColor(
    'list.errorForeground', ColorDefaults(light: '#B01011', dark: '#F88070', hcDark: null, hcLight: null), 'Foreground color of list items containing errors.');
final String listWarningForeground = registerColor(
    'list.warningForeground', ColorDefaults(light: '#855F00', dark: '#CCA700', hcDark: null, hcLight: null), 'Foreground color of list items containing warnings.');
final String listFilterWidgetBackground = registerColor(
    'listFilterWidget.background', ColorDefaults(light: darken('editorWidget.background', 0), dark: lighten('editorWidget.background', 0), hcDark: 'editorWidget.background', hcLight: 'editorWidget.background'), 'Background color of the type filter widget in lists and trees.');
final String listFilterWidgetOutline = registerColor(
    'listFilterWidget.outline', ColorDefaults(light: Color(RGBA(0, 0, 0, 0)), dark: Color(RGBA(0, 0, 0, 0)), hcDark: '#f38518', hcLight: '#007ACC'), 'Outline color of the type filter widget in lists and trees.');
final String listFilterWidgetNoMatchesOutline = registerColor(
    'listFilterWidget.noMatchesOutline', ColorDefaults(light: '#BE1100', dark: '#BE1100', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Outline color of the type filter widget in lists and trees, when there are no matches.');
final String listFilterWidgetShadow = registerColor(
    'listFilterWidget.shadow', 'widget.shadow', 'Shadow color of the type filter widget in lists and trees.');
final String listFilterMatchHighlight = registerColor(
    'list.filterMatchBackground', ColorDefaults(light: 'editor.findMatchHighlightBackground', dark: 'editor.findMatchHighlightBackground', hcDark: null, hcLight: null), 'Background color of the filtered match.');
final String listFilterMatchHighlightBorder = registerColor(
    'list.filterMatchBorder', ColorDefaults(light: 'editor.findMatchHighlightBorder', dark: 'editor.findMatchHighlightBorder', hcDark: 'contrastBorder', hcLight: 'contrastActiveBorder'), 'Border color of the filtered match.');
final String listDeemphasizedForeground = registerColor(
    'list.deemphasizedForeground', ColorDefaults(light: '#8E8E90', dark: '#8C8C8C', hcDark: '#A7A8A9', hcLight: '#666666'), 'List/Tree foreground color for items that are deemphasized.');
final String treeIndentGuidesStroke = registerColor(
    'tree.indentGuidesStroke', ColorDefaults(light: '#a9a9a9', dark: '#585858', hcDark: '#a9a9a9', hcLight: '#a5a5a5'), 'Tree stroke color for the indentation guides.');
final String treeInactiveIndentGuidesStroke = registerColor(
    'tree.inactiveIndentGuidesStroke', transparent('tree.indentGuidesStroke', 0.4), 'Tree stroke color for the indentation guides that are not active.');
final String tableColumnsBorder = registerColor(
    'tree.tableColumnsBorder', ColorDefaults(light: '#61616120', dark: '#CCCCCC20', hcDark: null, hcLight: null), 'Table border color between columns.');
final String tableOddRowsBackgroundColor = registerColor(
    'tree.tableOddRowsBackground', ColorDefaults(light: transparent('foreground', 0.04), dark: transparent('foreground', 0.04), hcDark: null, hcLight: null), 'Background color for odd table rows.');
final String editorActionListBackground = registerColor(
    'editorActionList.background', 'editorWidget.background', 'Action List background color.');
final String editorActionListForeground = registerColor(
    'editorActionList.foreground', 'editorWidget.foreground', 'Action List foreground color.');
final String editorActionListFocusForeground = registerColor(
    'editorActionList.focusForeground', 'list.activeSelectionForeground', 'Action List foreground color for the focused item.');
final String editorActionListFocusBackground = registerColor(
    'editorActionList.focusBackground', 'list.activeSelectionBackground', 'Action List background color for the focused item.');
