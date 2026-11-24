// 1:1 port of
// vscode/src/vs/editor/browser/controller/editContext/native/nativeEditContextUtils.ts
//
// Browser DOM/log boundaries are injectable providers so that the port can be
// driven by the real TypeScript runtime truth in tests.

import '../../../../../base/browser/dom.dart' as dom;
import '../../../../../base/common/lifecycle.dart' as lifecycle;
import '../../../../../platform/log/common/log.dart' as log;

/// 1:1: `export interface ITypeData`
class ITypeData {
  ITypeData({
    required this.text,
    required this.replacePrevCharCnt,
    required this.replaceNextCharCnt,
    required this.positionDelta,
  });

  final String text;
  final int replacePrevCharCnt;
  final int replaceNextCharCnt;
  final int positionDelta;
}

/// 1:1: `addDisposableListener` from `base/browser/dom.js`.
lifecycle.IDisposable Function(
    dom.DomNode node, String type, void Function(dom.DomEvent e) handler)
    addDisposableListenerProvider = (dom.DomNode node, String type,
            void Function(dom.DomEvent e) handler) =>
        dom.addDisposableListener(node, type, handler);

/// 1:1: `getShadowRoot` from `base/browser/dom.js`.
dom.DomShadowRoot? Function(dom.DomNode domNode) getShadowRootProvider =
    dom.getShadowRoot;

/// 1:1: `export class FocusTracker extends Disposable`
class FocusTracker extends lifecycle.Disposable {
  FocusTracker(
    log.ILogServiceType logService,
    this._domNode,
    this._onFocusChange,
  ) : super() {
    register(addDisposableListenerProvider(_domNode, 'focus', (dom.DomEvent e) {
      logService.trace('NativeEditContext.focus');
      if (_isPaused) {
        return;
      }
      // Here we don't trust the browser and instead we check
      // that the active element is the one we are tracking
      // (this happens when cmd+tab is used to switch apps)
      refreshFocusState();
    }));
    register(addDisposableListenerProvider(_domNode, 'blur', (dom.DomEvent e) {
      logService.trace('NativeEditContext.blur');
      if (_isPaused) {
        return;
      }
      _handleFocusedChanged(false);
    }));
  }

  final dom.DomElement _domNode;
  final void Function(bool newFocusValue) _onFocusChange;

  bool _isFocused = false;
  bool _isPaused = false;

  /// 1:1: `public pause(): void`
  void pause() {
    _isPaused = true;
  }

  /// 1:1: `public resume(): void`
  void resume() {
    _isPaused = false;
    refreshFocusState();
  }

  void _handleFocusedChanged(bool focused) {
    if (_isFocused == focused) {
      return;
    }
    _isFocused = focused;
    _onFocusChange(_isFocused);
  }

  /// 1:1: `public focus(): void`
  void focus() {
    _domNode.focus();
    refreshFocusState();
  }

  /// 1:1: `public refreshFocusState(): void`
  void refreshFocusState() {
    final dom.DomShadowRoot? shadowRoot = getShadowRootProvider(_domNode);
    final Object? activeElement = shadowRoot != null
        ? shadowRoot.activeElement
        : _domNode.ownerDocument?.activeElement;
    final bool focused = identical(_domNode, activeElement);
    _handleFocusedChanged(focused);
  }

  /// 1:1: `get isFocused(): boolean`
  bool get isFocused => _isFocused;
}

/// 1:1: `editContextAddDisposableListener`
///
/// In the Dart DOM carrier, `DomNode` is the `EventTarget`. The native edit
/// context events are ordinary named events from the carrier's point of view.
lifecycle.IDisposable editContextAddDisposableListener(
  dom.DomNode target,
  String type,
  void Function(dom.DomEvent e) listener, [
  Object? options,
]) {
  target.addEventListener(type, listener, options);
  return _EditContextListenerDisposable(target, type, listener);
}

/// 1:1: the plain disposable literal returned by
/// `editContextAddDisposableListener` (no once-guard, unlike `toDisposable`).
class _EditContextListenerDisposable implements lifecycle.IDisposable {
  _EditContextListenerDisposable(this._target, this._type, this._listener);

  final dom.DomNode _target;
  final String _type;
  final void Function(dom.DomEvent e) _listener;

  @override
  void dispose() {
    _target.removeEventListener(_type, _listener);
  }
}
