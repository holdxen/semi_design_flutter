// 1:1 port of vscode/src/vs/editor/common/core/editorColorRegistry.ts
// Generated from tool/ts2dart/batch175_truth.json (executed TS truth).

import '../../../base/common/color.dart' show Color, RGBA;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../platform/theme/common/colorUtils.dart' show registerColor, ColorDefaults;
import '../../../platform/theme/common/colors/editorColors.dart' show editorBackground;
import '../../../platform/theme/common/themeService.dart' show IColorTheme, ICssStyleCollector, registerThemingParticipant;

final String editorLineHighlight = registerColor(
    'editor.lineHighlightBackground', null, 'Background color for the highlight of line at the cursor position.');
final String editorInactiveLineHighlight = registerColor(
    'editor.inactiveLineHighlightBackground', 'editor.lineHighlightBackground', 'Background color for the highlight of line at the cursor position when the editor is not focused.');
final String editorLineHighlightBorder = registerColor(
    'editor.lineHighlightBorder', ColorDefaults(light: '#eeeeee', dark: '#282828', hcDark: '#f38518', hcLight: 'contrastBorder'), 'Background color for the border around the line at the cursor position.');
final String editorRangeHighlight = registerColor(
    'editor.rangeHighlightBackground', ColorDefaults(light: '#fdff0033', dark: '#ffffff0b', hcDark: null, hcLight: null), 'Background color of highlighted ranges, like by quick open and find features. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorRangeHighlightBorder = registerColor(
    'editor.rangeHighlightBorder', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Background color of the border around highlighted ranges.');
final String editorSymbolHighlight = registerColor(
    'editor.symbolHighlightBackground', ColorDefaults(light: 'editor.findMatchHighlightBackground', dark: 'editor.findMatchHighlightBackground', hcDark: null, hcLight: null), 'Background color of highlighted symbol, like for go to definition or go next/previous symbol. The color must not be opaque so as not to hide underlying decorations.', true);
final String editorSymbolHighlightBorder = registerColor(
    'editor.symbolHighlightBorder', ColorDefaults(light: null, dark: null, hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Background color of the border around highlighted symbols.');
final String editorCursorForeground = registerColor(
    'editorCursor.foreground', ColorDefaults(light: Color(RGBA(0, 0, 0, 1)), dark: '#AEAFAD', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: '#0F4A85'), 'Color of the editor cursor.');
final String editorCursorBackground = registerColor(
    'editorCursor.background', null, 'The background color of the editor cursor. Allows customizing the color of a character overlapped by a block cursor.');
final String editorMultiCursorPrimaryForeground = registerColor(
    'editorMultiCursor.primary.foreground', 'editorCursor.foreground', 'Color of the primary editor cursor when multiple cursors are present.');
final String editorMultiCursorPrimaryBackground = registerColor(
    'editorMultiCursor.primary.background', 'editorCursor.background', 'The background color of the primary editor cursor when multiple cursors are present. Allows customizing the color of a character overlapped by a block cursor.');
final String editorMultiCursorSecondaryForeground = registerColor(
    'editorMultiCursor.secondary.foreground', 'editorCursor.foreground', 'Color of secondary editor cursors when multiple cursors are present.');
final String editorMultiCursorSecondaryBackground = registerColor(
    'editorMultiCursor.secondary.background', 'editorCursor.background', 'The background color of secondary editor cursors when multiple cursors are present. Allows customizing the color of a character overlapped by a block cursor.');
final String editorWhitespaces = registerColor(
    'editorWhitespace.foreground', ColorDefaults(light: '#33333333', dark: '#e3e4e229', hcDark: '#e3e4e229', hcLight: '#CCCCCC'), 'Color of whitespace characters in the editor.');
final String editorWordWrapIndicator = registerColor(
    'editorWordWrapIndicator.foreground', 'editorWhitespace.foreground', 'Color of the indicator shown at the end of a soft wrapped line in the editor.');
final String editorLineNumbers = registerColor(
    'editorLineNumber.foreground', ColorDefaults(light: '#237893', dark: '#858585', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: '#292929'), 'Color of editor line numbers.');
final String deprecatedEditorIndentGuides = registerColor(
    'editorIndentGuide.background', 'editorWhitespace.foreground', 'Color of the editor indentation guides.', false, '\'editorIndentGuide.background\' is deprecated. Use \'editorIndentGuide.background1\' instead.');
final String deprecatedEditorActiveIndentGuides = registerColor(
    'editorIndentGuide.activeBackground', 'editorWhitespace.foreground', 'Color of the active editor indentation guides.', false, '\'editorIndentGuide.activeBackground\' is deprecated. Use \'editorIndentGuide.activeBackground1\' instead.');
final String editorIndentGuide1 = registerColor(
    'editorIndentGuide.background1', 'editorIndentGuide.background', 'Color of the editor indentation guides (1).');
final String editorIndentGuide2 = registerColor(
    'editorIndentGuide.background2', '#00000000', 'Color of the editor indentation guides (2).');
final String editorIndentGuide3 = registerColor(
    'editorIndentGuide.background3', '#00000000', 'Color of the editor indentation guides (3).');
final String editorIndentGuide4 = registerColor(
    'editorIndentGuide.background4', '#00000000', 'Color of the editor indentation guides (4).');
final String editorIndentGuide5 = registerColor(
    'editorIndentGuide.background5', '#00000000', 'Color of the editor indentation guides (5).');
final String editorIndentGuide6 = registerColor(
    'editorIndentGuide.background6', '#00000000', 'Color of the editor indentation guides (6).');
final String editorActiveIndentGuide1 = registerColor(
    'editorIndentGuide.activeBackground1', 'editorIndentGuide.activeBackground', 'Color of the active editor indentation guides (1).');
final String editorActiveIndentGuide2 = registerColor(
    'editorIndentGuide.activeBackground2', '#00000000', 'Color of the active editor indentation guides (2).');
final String editorActiveIndentGuide3 = registerColor(
    'editorIndentGuide.activeBackground3', '#00000000', 'Color of the active editor indentation guides (3).');
final String editorActiveIndentGuide4 = registerColor(
    'editorIndentGuide.activeBackground4', '#00000000', 'Color of the active editor indentation guides (4).');
final String editorActiveIndentGuide5 = registerColor(
    'editorIndentGuide.activeBackground5', '#00000000', 'Color of the active editor indentation guides (5).');
final String editorActiveIndentGuide6 = registerColor(
    'editorIndentGuide.activeBackground6', '#00000000', 'Color of the active editor indentation guides (6).');
final String editorActiveLineNumberForeground = registerColor(
    'editorActiveLineNumber.foreground', ColorDefaults(light: '#0B216F', dark: '#c6c6c6', hcDark: 'contrastActiveBorder', hcLight: 'contrastActiveBorder'), 'Color of editor active line number', false, 'Id is deprecated. Use \'editorLineNumber.activeForeground\' instead.');
final String editorActiveLineNumber = registerColor(
    'editorLineNumber.activeForeground', 'editorActiveLineNumber.foreground', 'Color of editor active line number');
final String editorDimmedLineNumber = registerColor(
    'editorLineNumber.dimmedForeground', null, 'Color of the final editor line when editor.renderFinalNewline is set to dimmed.');
final String editorRuler = registerColor(
    'editorRuler.foreground', ColorDefaults(light: Color(RGBA(211, 211, 211, 1)), dark: '#5A5A5A', hcDark: Color(RGBA(255, 255, 255, 1)), hcLight: '#292929'), 'Color of the editor rulers.');
final String editorCodeLensForeground = registerColor(
    'editorCodeLens.foreground', ColorDefaults(light: '#919191', dark: '#999999', hcDark: '#999999', hcLight: '#292929'), 'Foreground color of editor CodeLens');
final String editorBracketMatchBackground = registerColor(
    'editorBracketMatch.background', ColorDefaults(light: '#0064001a', dark: '#0064001a', hcDark: '#0064001a', hcLight: '#0000'), 'Background color behind matching brackets');
final String editorBracketMatchBorder = registerColor(
    'editorBracketMatch.border', ColorDefaults(light: '#B9B9B9', dark: '#888', hcDark: 'contrastBorder', hcLight: 'contrastBorder'), 'Color for matching brackets boxes');
final String editorBracketMatchForeground = registerColor(
    'editorBracketMatch.foreground', null, 'Foreground color for matching brackets');
final String editorOverviewRulerBorder = registerColor(
    'editorOverviewRuler.border', ColorDefaults(light: '#7f7f7f4d', dark: '#7f7f7f4d', hcDark: '#7f7f7f4d', hcLight: '#666666'), 'Color of the overview ruler border.');
final String editorOverviewRulerBackground = registerColor(
    'editorOverviewRuler.background', null, 'Background color of the editor overview ruler.');
final String editorGutter = registerColor(
    'editorGutter.background', 'editor.background', 'Background color of the editor gutter. The gutter contains the glyph margins and the line numbers.');
final String editorUnnecessaryCodeBorder = registerColor(
    'editorUnnecessaryCode.border', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(255, 255, 255, 0.8)), hcLight: 'contrastBorder'), 'Border color of unnecessary (unused) source code in the editor.');
final String editorUnnecessaryCodeOpacity = registerColor(
    'editorUnnecessaryCode.opacity', ColorDefaults(light: Color(RGBA(0, 0, 0, 0.467)), dark: Color(RGBA(0, 0, 0, 0.667)), hcDark: null, hcLight: null), 'Opacity of unnecessary (unused) source code in the editor. For example, "#000000c0" will render the code with 75% opacity. For high contrast themes, use the  \'editorUnnecessaryCode.border\' theme color to underline unnecessary code instead of fading it out.');
final String ghostTextBorder = registerColor(
    'editorGhostText.border', ColorDefaults(light: null, dark: null, hcDark: Color(RGBA(255, 255, 255, 0.8)), hcLight: Color(RGBA(41, 41, 41, 0.8))), 'Border color of ghost text in the editor.');
final String ghostTextForeground = registerColor(
    'editorGhostText.foreground', ColorDefaults(light: Color(RGBA(0, 0, 0, 0.467)), dark: Color(RGBA(255, 255, 255, 0.337)), hcDark: null, hcLight: null), 'Foreground color of the ghost text in the editor.');
final String ghostTextBackground = registerColor(
    'editorGhostText.background', null, 'Background color of the ghost text in the editor.');
final String overviewRulerRangeHighlight = registerColor(
    'editorOverviewRuler.rangeHighlightForeground', Color(RGBA(0, 122, 204, 0.6)), 'Overview ruler marker color for range highlights. The color must not be opaque so as not to hide underlying decorations.', true);
final String overviewRulerError = registerColor(
    'editorOverviewRuler.errorForeground', ColorDefaults(light: Color(RGBA(255, 18, 18, 0.7)), dark: Color(RGBA(255, 18, 18, 0.7)), hcDark: Color(RGBA(255, 50, 50, 1)), hcLight: '#B5200D'), 'Overview ruler marker color for errors.');
final String overviewRulerWarning = registerColor(
    'editorOverviewRuler.warningForeground', ColorDefaults(light: 'editorWarning.foreground', dark: 'editorWarning.foreground', hcDark: 'editorWarning.border', hcLight: 'editorWarning.border'), 'Overview ruler marker color for warnings.');
final String overviewRulerInfo = registerColor(
    'editorOverviewRuler.infoForeground', ColorDefaults(light: 'editorInfo.foreground', dark: 'editorInfo.foreground', hcDark: 'editorInfo.border', hcLight: 'editorInfo.border'), 'Overview ruler marker color for infos.');
final String editorBracketHighlightingForeground1 = registerColor(
    'editorBracketHighlight.foreground1', ColorDefaults(light: '#0431FAFF', dark: '#FFD700', hcDark: '#FFD700', hcLight: '#0431FAFF'), 'Foreground color of brackets (1). Requires enabling bracket pair colorization.');
final String editorBracketHighlightingForeground2 = registerColor(
    'editorBracketHighlight.foreground2', ColorDefaults(light: '#319331FF', dark: '#DA70D6', hcDark: '#DA70D6', hcLight: '#319331FF'), 'Foreground color of brackets (2). Requires enabling bracket pair colorization.');
final String editorBracketHighlightingForeground3 = registerColor(
    'editorBracketHighlight.foreground3', ColorDefaults(light: '#7B3814FF', dark: '#179FFF', hcDark: '#87CEFA', hcLight: '#7B3814FF'), 'Foreground color of brackets (3). Requires enabling bracket pair colorization.');
final String editorBracketHighlightingForeground4 = registerColor(
    'editorBracketHighlight.foreground4', '#00000000', 'Foreground color of brackets (4). Requires enabling bracket pair colorization.');
final String editorBracketHighlightingForeground5 = registerColor(
    'editorBracketHighlight.foreground5', '#00000000', 'Foreground color of brackets (5). Requires enabling bracket pair colorization.');
final String editorBracketHighlightingForeground6 = registerColor(
    'editorBracketHighlight.foreground6', '#00000000', 'Foreground color of brackets (6). Requires enabling bracket pair colorization.');
final String editorBracketHighlightingUnexpectedBracketForeground = registerColor(
    'editorBracketHighlight.unexpectedBracket.foreground', ColorDefaults(light: Color(RGBA(255, 18, 18, 0.8)), dark: Color(RGBA(255, 18, 18, 0.8)), hcDark: Color(RGBA(255, 50, 50, 1)), hcLight: '#B5200D'), 'Foreground color of unexpected brackets.');
final String editorBracketPairGuideBackground1 = registerColor(
    'editorBracketPairGuide.background1', '#00000000', 'Background color of inactive bracket pair guides (1). Requires enabling bracket pair guides.');
final String editorBracketPairGuideBackground2 = registerColor(
    'editorBracketPairGuide.background2', '#00000000', 'Background color of inactive bracket pair guides (2). Requires enabling bracket pair guides.');
final String editorBracketPairGuideBackground3 = registerColor(
    'editorBracketPairGuide.background3', '#00000000', 'Background color of inactive bracket pair guides (3). Requires enabling bracket pair guides.');
final String editorBracketPairGuideBackground4 = registerColor(
    'editorBracketPairGuide.background4', '#00000000', 'Background color of inactive bracket pair guides (4). Requires enabling bracket pair guides.');
final String editorBracketPairGuideBackground5 = registerColor(
    'editorBracketPairGuide.background5', '#00000000', 'Background color of inactive bracket pair guides (5). Requires enabling bracket pair guides.');
final String editorBracketPairGuideBackground6 = registerColor(
    'editorBracketPairGuide.background6', '#00000000', 'Background color of inactive bracket pair guides (6). Requires enabling bracket pair guides.');
final String editorBracketPairGuideActiveBackground1 = registerColor(
    'editorBracketPairGuide.activeBackground1', '#00000000', 'Background color of active bracket pair guides (1). Requires enabling bracket pair guides.');
final String editorBracketPairGuideActiveBackground2 = registerColor(
    'editorBracketPairGuide.activeBackground2', '#00000000', 'Background color of active bracket pair guides (2). Requires enabling bracket pair guides.');
final String editorBracketPairGuideActiveBackground3 = registerColor(
    'editorBracketPairGuide.activeBackground3', '#00000000', 'Background color of active bracket pair guides (3). Requires enabling bracket pair guides.');
final String editorBracketPairGuideActiveBackground4 = registerColor(
    'editorBracketPairGuide.activeBackground4', '#00000000', 'Background color of active bracket pair guides (4). Requires enabling bracket pair guides.');
final String editorBracketPairGuideActiveBackground5 = registerColor(
    'editorBracketPairGuide.activeBackground5', '#00000000', 'Background color of active bracket pair guides (5). Requires enabling bracket pair guides.');
final String editorBracketPairGuideActiveBackground6 = registerColor(
    'editorBracketPairGuide.activeBackground6', '#00000000', 'Background color of active bracket pair guides (6). Requires enabling bracket pair guides.');
final String editorUnicodeHighlightBorder = registerColor(
    'editorUnicodeHighlight.border', 'editorWarning.foreground', 'Border color used to highlight unicode characters.');
final String editorUnicodeHighlightBackground = registerColor(
    'editorUnicodeHighlight.background', 'editorWarning.background', 'Background color used to highlight unicode characters.');

// contains all color rules that used to defined in editor/browser/widget/editor.css
// 1:1: top-level `registerThemingParticipant(...)`; the private Dart field is
// exposed so the registration can be forced in truth tests.
final IDisposable editorThemingParticipant =
    registerThemingParticipant((IColorTheme theme, ICssStyleCollector collector,
        dynamic _) {
  final Color? background = theme.getColor(editorBackground);
  final Color? lineHighlight = theme.getColor(editorLineHighlight);
  final Color? imeBackground =
      (lineHighlight != null && !lineHighlight.isTransparent())
          ? lineHighlight
          : background;
  if (imeBackground != null) {
    collector.addRule(
        '.monaco-editor .inputarea.ime-input { background-color: $imeBackground; }');
  }
});
