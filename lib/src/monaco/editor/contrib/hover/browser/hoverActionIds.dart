// 1:1 port of vs/editor/contrib/hover/browser/hoverActionIds.ts

import '../../../../nls.dart' show localize;

const String SHOW_OR_FOCUS_HOVER_ACTION_ID = 'editor.action.showHover';
const String SHOW_DEFINITION_PREVIEW_HOVER_ACTION_ID =
    'editor.action.showDefinitionPreviewHover';
const String HIDE_HOVER_ACTION_ID = 'editor.action.hideHover';
const String SCROLL_UP_HOVER_ACTION_ID = 'editor.action.scrollUpHover';
const String SCROLL_DOWN_HOVER_ACTION_ID = 'editor.action.scrollDownHover';
const String SCROLL_LEFT_HOVER_ACTION_ID = 'editor.action.scrollLeftHover';
const String SCROLL_RIGHT_HOVER_ACTION_ID = 'editor.action.scrollRightHover';
const String PAGE_UP_HOVER_ACTION_ID = 'editor.action.pageUpHover';
const String PAGE_DOWN_HOVER_ACTION_ID = 'editor.action.pageDownHover';
const String GO_TO_TOP_HOVER_ACTION_ID = 'editor.action.goToTopHover';
const String GO_TO_BOTTOM_HOVER_ACTION_ID = 'editor.action.goToBottomHover';
const String INCREASE_HOVER_VERBOSITY_ACTION_ID =
    'editor.action.increaseHoverVerbosityLevel';
const String INCREASE_HOVER_VERBOSITY_ACCESSIBLE_ACTION_ID =
    'editor.action.increaseHoverVerbosityLevelFromAccessibleView';

/// Source: `nls.localize({ key: ..., comment: [...] }, "Increase Hover Verbosity Level")`.
/// The object metadata is carried as a Map to preserve the 1:1 call shape.
final String INCREASE_HOVER_VERBOSITY_ACTION_LABEL = localize(
  <String, Object?>{
    'key': 'increaseHoverVerbosityLevel',
    'comment': <Object?>['Label for action that will increase the hover verbosity level.'],
  },
  'Increase Hover Verbosity Level',
);

const String DECREASE_HOVER_VERBOSITY_ACTION_ID =
    'editor.action.decreaseHoverVerbosityLevel';
const String DECREASE_HOVER_VERBOSITY_ACCESSIBLE_ACTION_ID =
    'editor.action.decreaseHoverVerbosityLevelFromAccessibleView';

/// Source: `nls.localize({ key: ..., comment: [...] }, "Decrease Hover Verbosity Level")`.
final String DECREASE_HOVER_VERBOSITY_ACTION_LABEL = localize(
  <String, Object?>{
    'key': 'decreaseHoverVerbosityLevel',
    'comment': <Object?>['Label for action that will decrease the hover verbosity level.'],
  },
  'Decrease Hover Verbosity Level',
);

const String HIDE_LONG_LINE_WARNING_HOVER_ACTION_ID =
    'editor.action.hideLongLineWarningHover';
