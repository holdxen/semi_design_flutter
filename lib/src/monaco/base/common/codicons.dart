// 1:1 port of vscode/src/vs/base/common/codicons.ts

import 'codiconsLibrary.dart' show codiconsLibrary;
import 'codiconsUtil.dart' show register;
import 'themables.dart' show ThemeIcon;

/// 1:1: `export const codiconsDerived = { ... } as const`
// ignore: non_constant_identifier_names
final Map<String, ThemeIcon> codiconsDerived = <String, ThemeIcon>{
  'dialogError': register('dialog-error', 'error'),
  'dialogWarning': register('dialog-warning', 'warning'),
  'dialogInfo': register('dialog-info', 'info'),
  'dialogClose': register('dialog-close', 'close'),
  'treeItemExpanded': register('tree-item-expanded', 'chevron-down'),
  'treeFilterOnTypeOn': register('tree-filter-on-type-on', 'list-filter'),
  'treeFilterOnTypeOff': register('tree-filter-on-type-off', 'list-selection'),
  'treeFilterClear': register('tree-filter-clear', 'close'),
  'treeItemLoading': register('tree-item-loading', 'loading'),
  'menuSelection': register('menu-selection', 'check'),
  'menuSubmenu': register('menu-submenu', 'chevron-right'),
  'menuBarMore': register('menubar-more', 'more'),
  'scrollbarButtonLeft': register('scrollbar-button-left', 'triangle-left'),
  'scrollbarButtonRight': register('scrollbar-button-right', 'triangle-right'),
  'scrollbarButtonUp': register('scrollbar-button-up', 'triangle-up'),
  'scrollbarButtonDown': register('scrollbar-button-down', 'triangle-down'),
  'toolBarMore': register('toolbar-more', 'more'),
  'quickInputBack': register('quick-input-back', 'arrow-left'),
  'dropDownButton': register('drop-down-button', 0xeab4),
  'symbolCustomColor': register('symbol-customcolor', 0xeb5c),
  'exportIcon': register('export', 0xebac),
  'workspaceUnspecified': register('workspace-unspecified', 0xebc3),
  'newLine': register('newline', 0xebea),
  'thumbsDownFilled': register('thumbsdown-filled', 0xec13),
  'thumbsUpFilled': register('thumbsup-filled', 0xec14),
  'gitFetch': register('git-fetch', 0xec1d),
  'lightbulbSparkleAutofix': register('lightbulb-sparkle-autofix', 0xec1f),
  'debugBreakpointPending': register('debug-breakpoint-pending', 0xebd9),
  'chatImport': register('chat-import', 0xec86),
  'chatExport': register('chat-export', 0xec87),
  'compare': register('compare', 0xecfa),
  'gitBranchCheckout': register('git-branch-checkout', 0xecfb),
};

/// 1:1: `export const Codicon = { ...codiconsLibrary, ...codiconsDerived } as const`
///
/// Spread order is significant (mirrors TS): library registers first, then
/// derived aliases resolve against the filled font-character map; overlapping
/// keys (chatExport/chatImport/gitFetch) are overridden by derived.
// ignore: non_constant_identifier_names
final Map<String, ThemeIcon> Codicon = <String, ThemeIcon>{
  ...codiconsLibrary,
  ...codiconsDerived,
};

/// 1:1: `export function getAllCodicons(): ThemeIcon[]`
List<ThemeIcon> getAllCodicons() => Codicon.values.toList();
