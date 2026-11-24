// 1:1 port of
// vscode/src/vs/platform/history/browser/historyWidgetKeybindingHint.ts

import '../../keybinding/common/keybinding.dart' show IKeybindingServiceType;

/// 1:1: `export function showHistoryKeybindingHint(keybindingService): boolean`
bool showHistoryKeybindingHint(IKeybindingServiceType keybindingService) {
  return keybindingService
          .lookupKeybinding('history.showPrevious')
          ?.getElectronAccelerator() ==
      'Up' &&
      keybindingService
          .lookupKeybinding('history.showNext')
          ?.getElectronAccelerator() ==
      'Down';
}
