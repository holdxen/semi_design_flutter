// 1:1 port of vscode/src/vs/editor/browser/widget/multiDiffEditor/colors.ts
// Generated from tool/ts2dart/batch176_truth.json (executed TS truth).

import '../../../../platform/theme/common/colorUtils.dart' show ColorDefaults, registerColor;

final String multiDiffEditorHeaderBackground = registerColor(
    'multiDiffEditor.headerBackground', ColorDefaults(light: 'tab.inactiveBackground', dark: '#262626', hcDark: 'tab.inactiveBackground', hcLight: 'tab.inactiveBackground'), 'The background color of the diff editor\'s header');
final String multiDiffEditorBackground = registerColor(
    'multiDiffEditor.background', 'editor.background', 'The background color of the multi file diff editor');
final String multiDiffEditorBorder = registerColor(
    'multiDiffEditor.border', ColorDefaults(light: '#cccccc', dark: 'sideBarSectionHeader.border', hcDark: 'sideBarSectionHeader.border', hcLight: '#cccccc'), 'The border color of the multi file diff editor');
