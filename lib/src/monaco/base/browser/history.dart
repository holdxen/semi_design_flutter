// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/history.ts
// Translated 1:1 from TypeScript. `HTMLElement` (a DOM type unavailable in
// the Dart port) is represented as `Object`. `Event<void>` maps to the
// ported event type alias.
// ---------------------------------------------------------------------------

import '../common/event.dart' show Event;

/// 1:1: `export interface IHistoryNavigationWidget`
abstract class IHistoryNavigationWidget {
  /// 1:1: `readonly element: HTMLElement`
  Object get element;

  void showPreviousValue();

  void showNextValue();

  Event<void> get onDidFocus;

  Event<void> get onDidBlur;
}
