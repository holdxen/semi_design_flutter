// 1:1 port of vscode/src/vs/platform/theme/common/colors/editorColors.ts
// Generated from tool/ts2dart/batch174b_truth.json (executed TS truth).

import '../../../../base/common/color.dart' show Color, RGBA;
import '../colorUtils.dart' show registerColor, ColorDefaults, ColorTransform,
    ColorTransformType, darken, lighten, transparent, withOpacity, opaque,
    oneOf, ifDefinedThenElse, lessProminent;

final Color defaultInsertColor = Color(RGBA(155, 185, 85, 0.2));
final Color defaultRemoveColor = Color(RGBA(255, 0, 0, 0.2));
final String editorBackground = registerColor(
    'editor.background', ColorDefaults(light: '#ffffff', dark: '#1E1E1E', hcDark: Color(RGBA(0, 0, 0, 1)), hcLight: Color(RGBA(255, 255, 255, 1))), 'Editor background color.');
final String editorForeground = registerColor(
    'editor.foreground', ColorDefaults(light: '#333333', dark: '#BBBBBB', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: 'foreground'), 'Editor default foreground color.');
final String editorStickyScrollBackground = registerColor(
    'editorStickyScroll.background', 'editor.background', 'Background color of sticky scroll in the editor');
final String editorStickyScrollGutterBackground = registerColor(
    'editorStickyScrollGutter.background', 'editor.background', 'Background color of the gutter part of sticky scroll in the editor');
final String editorStickyScrollHoverBackground = registerColor(
    'editorStickyScrollHover.background', ColorDefaults(light: '#F0F0F0', dark: '#2A2D2E', hcDark: null, hcLight: Color(RGBA(15, 74, 133, 0.1))), 'Background color of sticky scroll on hover in the editor');
final String editorStickyScrollBorder = registerColor(
    'editorStickyScroll.border', ColorDefaults(light: null, dark: null, hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Border color of sticky scroll in the editor');
final String editorStickyScrollShadow = registerColor(
    'editorStickyScroll.shadow', 'scrollbar.shadow', ' Shadow color of sticky scroll in the editor');
final String editorWidgetBackground = registerColor(
    'editorWidget.background', ColorDefaults(light: '#F3F3F3', dark: '#252526', hcDark: '#0C141F', hcLight: Color(RGBA(255, 255, 255, 1))), 'Background color of editor widgets, such as find/replace.');
final String editorWidgetForeground = registerColor(
    'editorWidget.foreground', 'foreground', 'Foreground color of editor widgets, such as find/replace.');
final String editorWidgetBorder = registerColor(
    'editorWidget.border', ColorDefaults(light: transparent('editorWidget.foreground', 0.2), dark: transparent('editorWidget.foreground', 0.2), hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Border color of editor widgets. The color is only used if the widget chooses to have a border and if the color is not overridden by a widget.');
final String editorWidgetResizeBorder = registerColor(
    'editorWidget.resizeBorder', null, 'Border color of the resize bar of editor widgets. The color is only used if the widget chooses to have a resize border and if the color is not overridden by a widget.');
final String editorErrorBackground = registerColor(
    'editorError.background', null, 'Background color of error text in the editor. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorErrorForeground = registerColor(
    'editorError.foreground', ColorDefaults(light: '#E51400', dark: '#F14C4C', hcDark: '#F48771', hcLight: '#B5200D'), 'Foreground color of error squigglies in the editor.');
final String editorErrorBorder = registerColor(
    'editorError.border', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(228, 119, 119, 0.8)), hcLight: '#B5200D'), 'If set, color of double underlines for errors in the editor.');
final String editorWarningBackground = registerColor(
    'editorWarning.background', null, 'Background color of warning text in the editor. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorWarningForeground = registerColor(
    'editorWarning.foreground', ColorDefaults(light: '#BF8803', dark: '#CCA700', hcDark: '#FFD370', hcLight: '#895503'), 'Foreground color of warning squigglies in the editor.');
final String editorWarningBorder = registerColor(
    'editorWarning.border', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(255, 204, 0, 0.8)), hcLight: Color(RGBA(255, 204, 0, 0.8))), 'If set, color of double underlines for warnings in the editor.');
final String editorInfoBackground = registerColor(
    'editorInfo.background', null, 'Background color of info text in the editor. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorInfoForeground = registerColor(
    'editorInfo.foreground', ColorDefaults(light: '#0063d3', dark: '#59a4f9', hcDark: '#59a4f9', hcLight: '#0063d3'), 'Foreground color of info squigglies in the editor.');
final String editorInfoBorder = registerColor(
    'editorInfo.border', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(89, 164, 249, 0.8)), hcLight: '#292929'), 'If set, color of double underlines for infos in the editor.');
final String editorHintForeground = registerColor(
    'editorHint.foreground', ColorDefaults(light: '#6c6c6c', dark: Color(RGBA(238, 238, 238, 0.7)), hcDark: null, hcLight: null), 'Foreground color of hint squigglies in the editor.');
final String editorHintBorder = registerColor(
    'editorHint.border', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(238, 238, 238, 0.8)), hcLight: '#292929'), 'If set, color of double underlines for hints in the editor.');
final String editorActiveLinkForeground = registerColor(
    'editorLink.activeForeground', ColorDefaults(light: Color(RGBA(0, 0, 255, 1)), dark: '#4E94CE', hcDark: Color(RGBA(0, 255, 255, 1)), hcLight: '#292929'), 'Color of active links.');
final String editorSelectionBackground = registerColor(
    'editor.selectionBackground', ColorDefaults(light: '#ADD6FF', dark: '#264F78', hcDark: '#f3f518', hcLight: '#0F4A85'), 'Color of the editor selection.');
final String editorSelectionForeground = registerColor(
    'editor.selectionForeground', ColorDefaults(light: null, dark: null, hcDark: '#000000', hcLight: Color(RGBA(255, 255, 255, 1))), 'Color of the selected text for high contrast.');
final String editorInactiveSelection = registerColor(
    'editor.inactiveSelectionBackground', ColorDefaults(light: transparent('editor.selectionBackground', 0.5), dark: transparent('editor.selectionBackground', 0.5), hcDark: transparent('editor.selectionBackground', 0.7), hcLight: transparent('editor.selectionBackground', 0.5)), 'Color of the selection in an inactive editor. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorSelectionHighlight = registerColor(
    'editor.selectionHighlightBackground', ColorDefaults(light: lessProminent('editor.selectionBackground', 'editor.background', 0.3, 0.6), dark: lessProminent('editor.selectionBackground', 'editor.background', 0.3, 0.6), hcDark: null, hcLight: null), 'Color for regions with the same content as the selection. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorSelectionHighlightBorder = registerColor(
    'editor.selectionHighlightBorder', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Border color for regions with the same content as the selection.');
final String editorCompositionBorder = registerColor(
    'editor.compositionBorder', ColorDefaults(light: '#000000', dark: '#ffffff', hcDark: '#ffffff', hcLight: '#000000'), 'The border color for an IME composition.');
final String editorFindMatch = registerColor(
    'editor.findMatchBackground', ColorDefaults(light: '#A8AC94', dark: '#515C6A', hcDark: null, hcLight: null), 'Color of the current search match.');
final String editorFindMatchForeground = registerColor(
    'editor.findMatchForeground', null, 'Text color of the current search match.');
final String editorFindMatchHighlight = registerColor(
    'editor.findMatchHighlightBackground', ColorDefaults(light: '#EA5C0055', dark: '#EA5C0055', hcDark: null, hcLight: null), 'Color of the other search matches. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorFindMatchHighlightForeground = registerColor(
    'editor.findMatchHighlightForeground', null, 'Foreground color of the other search matches.', true);
final String editorFindRangeHighlight = registerColor(
    'editor.findRangeHighlightBackground', ColorDefaults(light: '#b4b4b44d', dark: '#3a3d4166', hcDark: null, hcLight: null), 'Color of the range limiting the search. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorFindMatchBorder = registerColor(
    'editor.findMatchBorder', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Border color of the current search match.');
final String editorFindMatchHighlightBorder = registerColor(
    'editor.findMatchHighlightBorder', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Border color of the other search matches.');
final String editorFindRangeHighlightBorder = registerColor(
    'editor.findRangeHighlightBorder', ColorDefaults(light: null, dark: null, hcDark: transparent('contrastActiveBorder', 0.4), hcLight: transparent('contrastActiveBorder', 0.4)), 'Border color of the range limiting the search. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorHoverHighlight = registerColor(
    'editor.hoverHighlightBackground', ColorDefaults(light: '#ADD6FF26', dark: '#264f7840', hcDark: '#ADD6FF26', hcLight: null), 'Highlight below the word for which a hover is shown. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorHoverBackground = registerColor(
    'editorHoverWidget.background', 'editorWidget.background', 'Background color of the editor hover.');
final String editorHoverForeground = registerColor(
    'editorHoverWidget.foreground', 'editorWidget.foreground', 'Foreground color of the editor hover.');
final String editorHoverBorder = registerColor(
    'editorHoverWidget.border', 'editorWidget.border', 'Border color of the editor hover.');
final String editorHoverStatusBarBackground = registerColor(
    'editorHoverWidget.statusBarBackground', ColorDefaults(light: darken('editorHoverWidget.background', 0.05), dark: lighten('editorHoverWidget.background', 0.2), hcDark: 'editorWidget.background', hcLight: 'editorWidget.background'), 'Background color of the editor hover status bar.');
final String editorInlayHintForeground = registerColor(
    'editorInlayHint.foreground', ColorDefaults(light: '#969696', dark: '#969696', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: Color(RGBA(0, 0, 0, 1))), 'Foreground color of inline hints');
final String editorInlayHintBackground = registerColor(
    'editorInlayHint.background', ColorDefaults(light: transparent('badge.background', 0.1), dark: transparent('badge.background', 0.1), hcDark: transparent(Color(RGBA(255, 255, 255, 1)), 0.1), hcLight: transparent('badge.background', 0.1)), 'Background color of inline hints');
final String editorInlayHintTypeForeground = registerColor(
    'editorInlayHint.typeForeground', 'editorInlayHint.foreground', 'Foreground color of inline hints for types');
final String editorInlayHintTypeBackground = registerColor(
    'editorInlayHint.typeBackground', 'editorInlayHint.background', 'Background color of inline hints for types');
final String editorInlayHintParameterForeground = registerColor(
    'editorInlayHint.parameterForeground', 'editorInlayHint.foreground', 'Foreground color of inline hints for parameters');
final String editorInlayHintParameterBackground = registerColor(
    'editorInlayHint.parameterBackground', 'editorInlayHint.background', 'Background color of inline hints for parameters');
final String editorLightBulbForeground = registerColor(
    'editorLightBulb.foreground', ColorDefaults(light: '#DDB100', dark: '#FFCC00', hcDark: '#FFCC00', hcLight: '#007ACC'), 'The color used for the lightbulb actions icon.');
final String editorLightBulbAutoFixForeground = registerColor(
    'editorLightBulbAutoFix.foreground', ColorDefaults(light: '#007ACC', dark: '#75BEFF', hcDark: '#75BEFF', hcLight: '#007ACC'), 'The color used for the lightbulb auto fix actions icon.');
final String editorLightBulbAiForeground = registerColor(
    'editorLightBulbAi.foreground', 'editorLightBulb.foreground', 'The color used for the lightbulb AI icon.');
final String snippetTabstopHighlightBackground = registerColor(
    'editor.snippetTabstopHighlightBackground', ColorDefaults(light: Color(RGBA(10, 50, 100, 0.2)), dark: Color(RGBA(124, 124, 124, 0.3)), hcDark: Color(RGBA(124, 124, 124, 0.3)), hcLight: Color(RGBA(10, 50, 100, 0.2))), 'Highlight background color of a snippet tabstop.');
final String snippetTabstopHighlightBorder = registerColor(
    'editor.snippetTabstopHighlightBorder', null, 'Highlight border color of a snippet tabstop.');
final String snippetFinalTabstopHighlightBackground = registerColor(
    'editor.snippetFinalTabstopHighlightBackground', null, 'Highlight background color of the final tabstop of a snippet.');
final String snippetFinalTabstopHighlightBorder = registerColor(
    'editor.snippetFinalTabstopHighlightBorder', ColorDefaults(light: Color(RGBA(10, 50, 100, 0.5)), dark: '#525252', hcDark: '#525252', hcLight: '#292929'), 'Highlight border color of the final tabstop of a snippet.');
final String diffInserted = registerColor(
    'diffEditor.insertedTextBackground', ColorDefaults(light: '#9ccc2c40', dark: '#9ccc2c33', hcDark: null, hcLight: null), 'Background color for text that got inserted. The color must not be opaque so as not to hide underlying decorations.', true);
final String diffRemoved = registerColor(
    'diffEditor.removedTextBackground', ColorDefaults(light: '#ff000033', dark: '#ff000033', hcDark: null, hcLight: null), 'Background color for text that got removed. The color must not be opaque so as not to hide underlying decorations.', true);
final String diffInsertedLine = registerColor(
    'diffEditor.insertedLineBackground', ColorDefaults(light: Color(RGBA(155, 185, 85, 0.2)), dark: Color(RGBA(155, 185, 85, 0.2)), hcDark: null, hcLight: null), 'Background color for lines that got inserted. The color must not be opaque so as not to hide underlying decorations.', true);
final String diffRemovedLine = registerColor(
    'diffEditor.removedLineBackground', ColorDefaults(light: Color(RGBA(255, 0, 0, 0.2)), dark: Color(RGBA(255, 0, 0, 0.2)), hcDark: null, hcLight: null), 'Background color for lines that got removed. The color must not be opaque so as not to hide underlying decorations.', true);
final String diffInsertedLineGutter = registerColor(
    'diffEditorGutter.insertedLineBackground', null, 'Background color for the margin where lines got inserted.');
final String diffRemovedLineGutter = registerColor(
    'diffEditorGutter.removedLineBackground', null, 'Background color for the margin where lines got removed.');
final String diffOverviewRulerInserted = registerColor(
    'diffEditorOverview.insertedForeground', null, 'Diff overview ruler foreground for inserted content.');
final String diffOverviewRulerRemoved = registerColor(
    'diffEditorOverview.removedForeground', null, 'Diff overview ruler foreground for removed content.');
final String diffInsertedOutline = registerColor(
    'diffEditor.insertedTextBorder', ColorDefaults(light: null, dark: null, hcDark: '#33ff2eff', hcLight: '#374E06'), 'Outline color for the text that got inserted.');
final String diffRemovedOutline = registerColor(
    'diffEditor.removedTextBorder', ColorDefaults(light: null, dark: null, hcDark: '#FF008F', hcLight: '#AD0707'), 'Outline color for text that got removed.');
final String diffBorder = registerColor(
    'diffEditor.border', ColorDefaults(light: null, dark: null, hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Border color between the two text editors.');
final String diffDiagonalFill = registerColor(
    'diffEditor.diagonalFill', ColorDefaults(light: '#22222233', dark: '#cccccc33', hcDark: null, hcLight: null), 'Color of the diff editor\'s diagonal fill. The diagonal fill is used in side-by-side diff views.');
final String diffUnchangedRegionBackground = registerColor(
    'diffEditor.unchangedRegionBackground', 'sideBar.background', 'The background color of unchanged blocks in the diff editor.');
final String diffUnchangedRegionForeground = registerColor(
    'diffEditor.unchangedRegionForeground', 'foreground', 'The foreground color of unchanged blocks in the diff editor.');
final String diffUnchangedTextBackground = registerColor(
    'diffEditor.unchangedCodeBackground', ColorDefaults(light: '#b8b8b829', dark: '#74747429', hcDark: null, hcLight: null), 'The background color of unchanged code in the diff editor.');
final String widgetShadow = registerColor(
    'widget.shadow', ColorDefaults(light: transparent(Color(RGBA(0, 0, 0, 1)), 0.16), dark: transparent(Color(RGBA(0, 0, 0, 1)), 0.36), hcDark: null, hcLight: null), 'Shadow color of widgets such as find/replace inside the editor.');
final String widgetBorder = registerColor(
    'widget.border', ColorDefaults(light: null, dark: null, hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Border color of widgets such as find/replace inside the editor.');
final String toolbarHoverBackground = registerColor(
    'toolbar.hoverBackground', ColorDefaults(light: '#b8b8b850', dark: '#5a5d5e50', hcDark: null, hcLight: null), 'Toolbar background when hovering over actions using the mouse');
final String toolbarHoverOutline = registerColor(
    'toolbar.hoverOutline', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Toolbar outline when hovering over actions using the mouse');
final String toolbarActiveBackground = registerColor(
    'toolbar.activeBackground', ColorDefaults(light: darken('toolbar.hoverBackground', 0.1), dark: lighten('toolbar.hoverBackground', 0.1), hcDark: null, hcLight: null), 'Toolbar background when holding the mouse over actions');
final String breadcrumbsForeground = registerColor(
    'breadcrumb.foreground', transparent('foreground', 0.8), 'Color of focused breadcrumb items.');
final String breadcrumbsBackground = registerColor(
    'breadcrumb.background', 'editor.background', 'Background color of breadcrumb items.');
final String breadcrumbsFocusForeground = registerColor(
    'breadcrumb.focusForeground', ColorDefaults(light: darken('foreground', 0.2), dark: lighten('foreground', 0.1), hcDark: lighten('foreground', 0.1), hcLight: lighten('foreground', 0.1)), 'Color of focused breadcrumb items.');
final String breadcrumbsActiveSelectionForeground = registerColor(
    'breadcrumb.activeSelectionForeground', ColorDefaults(light: darken('foreground', 0.2), dark: lighten('foreground', 0.1), hcDark: lighten('foreground', 0.1), hcLight: lighten('foreground', 0.1)), 'Color of selected breadcrumb items.');
final String breadcrumbsPickerBackground = registerColor(
    'breadcrumbPicker.background', 'editorWidget.background', 'Background color of breadcrumb item picker.');
final String mergeCurrentHeaderBackground = registerColor(
    'merge.currentHeaderBackground', ColorDefaults(light: Color(RGBA(64, 200, 174, 0.5)), dark: Color(RGBA(64, 200, 174, 0.5)), hcDark: null, hcLight: null), 'Current header background in inline merge-conflicts. The color must not be opaque so as not to hide underlying decorations.', true);
final String mergeCurrentContentBackground = registerColor(
    'merge.currentContentBackground', transparent('merge.currentHeaderBackground', 0.4), 'Current content background in inline merge-conflicts. The color must not be opaque so as not to hide underlying decorations.', true);
final String mergeIncomingHeaderBackground = registerColor(
    'merge.incomingHeaderBackground', ColorDefaults(light: Color(RGBA(64, 166, 255, 0.5)), dark: Color(RGBA(64, 166, 255, 0.5)), hcDark: null, hcLight: null), 'Incoming header background in inline merge-conflicts. The color must not be opaque so as not to hide underlying decorations.', true);
final String mergeIncomingContentBackground = registerColor(
    'merge.incomingContentBackground', transparent('merge.incomingHeaderBackground', 0.4), 'Incoming content background in inline merge-conflicts. The color must not be opaque so as not to hide underlying decorations.', true);
final String mergeCommonHeaderBackground = registerColor(
    'merge.commonHeaderBackground', ColorDefaults(light: Color(RGBA(96, 96, 96, 0.4)), dark: Color(RGBA(96, 96, 96, 0.4)), hcDark: null, hcLight: null), 'Common ancestor header background in inline merge-conflicts. The color must not be opaque so as not to hide underlying decorations.', true);
final String mergeCommonContentBackground = registerColor(
    'merge.commonContentBackground', transparent('merge.commonHeaderBackground', 0.4), 'Common ancestor content background in inline merge-conflicts. The color must not be opaque so as not to hide underlying decorations.', true);
final String mergeBorder = registerColor(
    'merge.border', ColorDefaults(light: null, dark: null, hcDark: '#C3DF6F', hcLight: '#007ACC'), 'Border color on headers and the splitter in inline merge-conflicts.');
final String overviewRulerCurrentContentForeground = registerColor(
    'editorOverviewRuler.currentContentForeground', ColorDefaults(light: transparent('merge.currentHeaderBackground', 1), dark: transparent('merge.currentHeaderBackground', 1), hcDark: 'merge.border', hcLight: 'merge.border'), 'Current overview ruler foreground for inline merge-conflicts.');
final String overviewRulerIncomingContentForeground = registerColor(
    'editorOverviewRuler.incomingContentForeground', ColorDefaults(light: transparent('merge.incomingHeaderBackground', 1), dark: transparent('merge.incomingHeaderBackground', 1), hcDark: 'merge.border', hcLight: 'merge.border'), 'Incoming overview ruler foreground for inline merge-conflicts.');
final String overviewRulerCommonContentForeground = registerColor(
    'editorOverviewRuler.commonContentForeground', ColorDefaults(light: transparent('merge.commonHeaderBackground', 1), dark: transparent('merge.commonHeaderBackground', 1), hcDark: 'merge.border', hcLight: 'merge.border'), 'Common ancestor overview ruler foreground for inline merge-conflicts.');
final String overviewRulerFindMatchForeground = registerColor(
    'editorOverviewRuler.findMatchForeground', ColorDefaults(light: '#d186167e', dark: '#d186167e', hcDark: '#AB5A00', hcLight: '#AB5A00'), 'Overview ruler marker color for find matches. The color must not be opaque so as not to hide underlying decorations.', true);
final String overviewRulerSelectionHighlightForeground = registerColor(
    'editorOverviewRuler.selectionHighlightForeground', '#A0A0A0CC', 'Overview ruler marker color for selection highlights. The color must not be opaque so as not to hide underlying decorations.', true);
final String problemsErrorIconForeground = registerColor(
    'problemsErrorIcon.foreground', 'editorError.foreground', 'The color used for the problems error icon.');
final String problemsWarningIconForeground = registerColor(
    'problemsWarningIcon.foreground', 'editorWarning.foreground', 'The color used for the problems warning icon.');
final String problemsInfoIconForeground = registerColor(
    'problemsInfoIcon.foreground', 'editorInfo.foreground', 'The color used for the problems info icon.');
