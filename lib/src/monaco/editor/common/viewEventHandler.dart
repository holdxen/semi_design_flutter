// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewEventHandler.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `ViewEvent` is an `Object` carrier in viewEvents.dart; each concrete
//     event exposes a `type` field read dynamically in [handleEvents].
//   - Handler event parameter types are the concrete viewEvents.dart classes.
// ---------------------------------------------------------------------------

import '../../base/common/lifecycle.dart' show Disposable;
import 'viewEvents.dart' show ViewEvent, ViewEventType;

/// 1:1: `export class ViewEventHandler extends Disposable`.
class ViewEventHandler extends Disposable {
  late bool _shouldRender;

  ViewEventHandler() {
    _shouldRender = true;
  }

  /// 1:1: `public shouldRender(): boolean`.
  bool shouldRender() => _shouldRender;

  /// 1:1: `public forceShouldRender(): void`.
  void forceShouldRender() {
    _shouldRender = true;
  }

  /// 1:1: `protected setShouldRender(): void`.
  void setShouldRender() {
    _shouldRender = true;
  }

  /// 1:1: `public onDidRender(): void`.
  void onDidRender() {
    _shouldRender = false;
  }

  // --- begin event handlers (all default false, 1:1) ---

  bool onCompositionStart(Object e) => false;
  bool onCompositionEnd(Object e) => false;
  bool onConfigurationChanged(Object e) => false;
  bool onCursorStateChanged(Object e) => false;
  bool onDecorationsChanged(Object e) => false;
  bool onFlushed(Object e) => false;
  bool onFocusChanged(Object e) => false;
  bool onLanguageConfigurationChanged(Object e) => false;
  bool onLineMappingChanged(Object e) => false;
  bool onLinesChanged(Object e) => false;
  bool onLinesDeleted(Object e) => false;
  bool onLinesInserted(Object e) => false;
  bool onRevealRangeRequest(Object e) => false;
  bool onScrollChanged(Object e) => false;
  bool onThemeChanged(Object e) => false;
  bool onTokensChanged(Object e) => false;
  bool onTokensColorsChanged(Object e) => false;
  bool onZonesChanged(Object e) => false;

  // --- end event handlers ---

  /// 1:1: `public handleEvents(events: ViewEvent[]): void`.
  void handleEvents(List<ViewEvent> events) {
    bool shouldRender = false;

    for (int i = 0, len = events.length; i < len; i++) {
      final ViewEvent e = events[i];
      final int type = (e as dynamic).type as int;

      switch (type) {
        case ViewEventType.ViewCompositionStart:
          if (onCompositionStart(e)) shouldRender = true;
          break;
        case ViewEventType.ViewCompositionEnd:
          if (onCompositionEnd(e)) shouldRender = true;
          break;
        case ViewEventType.ViewConfigurationChanged:
          if (onConfigurationChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewCursorStateChanged:
          if (onCursorStateChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewDecorationsChanged:
          if (onDecorationsChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewFlushed:
          if (onFlushed(e)) shouldRender = true;
          break;
        case ViewEventType.ViewFocusChanged:
          if (onFocusChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewLanguageConfigurationChanged:
          if (onLanguageConfigurationChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewLineMappingChanged:
          if (onLineMappingChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewLinesChanged:
          if (onLinesChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewLinesDeleted:
          if (onLinesDeleted(e)) shouldRender = true;
          break;
        case ViewEventType.ViewLinesInserted:
          if (onLinesInserted(e)) shouldRender = true;
          break;
        case ViewEventType.ViewRevealRangeRequest:
          if (onRevealRangeRequest(e)) shouldRender = true;
          break;
        case ViewEventType.ViewScrollChanged:
          if (onScrollChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewThemeChanged:
          if (onThemeChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewTokensChanged:
          if (onTokensChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewTokensColorsChanged:
          if (onTokensColorsChanged(e)) shouldRender = true;
          break;
        case ViewEventType.ViewZonesChanged:
          if (onZonesChanged(e)) shouldRender = true;
          break;
        default:
          // TS: console.info('View received unknown event: '); console.info(e);
          break;
      }
    }

    if (shouldRender) {
      _shouldRender = true;
    }
  }
}
