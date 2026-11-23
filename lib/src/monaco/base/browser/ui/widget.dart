// 1:1 port of vscode/src/vs/base/browser/ui/widget.ts
//
// Runtime surface: `Widget` — a Disposable that registers DOM listeners and
// wraps raw browser events into the port's StandardMouseEvent /
// StandardKeyboardEvent carriers. Protected methods keep their TS names.

import '../../common/lifecycle.dart' show Disposable, IDisposable;
import '../dom.dart' as dom;
import '../keyboardEvent.dart' as keyboard;
import '../mouseEvent.dart' as mouse;
import '../touch.dart' show Gesture;

/// 1:1: `export abstract class Widget extends Disposable`
abstract class Widget extends Disposable {
  /// 1:1: `protected onclick(domNode, listener)`
  void onclick(
      dom.DomElement domNode, void Function(mouse.IMouseEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.CLICK, (dom.DomEvent e) {
      listener(_standardMouseEvent(domNode, e));
    }));
  }

  /// 1:1: `protected onmousedown(domNode, listener)`
  void onmousedown(
      dom.DomElement domNode, void Function(mouse.IMouseEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.MOUSE_DOWN, (dom.DomEvent e) {
      listener(_standardMouseEvent(domNode, e));
    }));
  }

  /// 1:1: `protected onmouseover(domNode, listener)`
  void onmouseover(
      dom.DomElement domNode, void Function(mouse.IMouseEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.MOUSE_OVER, (dom.DomEvent e) {
      listener(_standardMouseEvent(domNode, e));
    }));
  }

  /// 1:1: `protected onmouseleave(domNode, listener)`
  void onmouseleave(
      dom.DomElement domNode, void Function(mouse.IMouseEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.MOUSE_LEAVE, (dom.DomEvent e) {
      listener(_standardMouseEvent(domNode, e));
    }));
  }

  /// 1:1: `protected onkeydown(domNode, listener)`
  void onkeydown(
      dom.DomElement domNode, void Function(keyboard.IKeyboardEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.KEY_DOWN, (dom.DomEvent e) {
      listener(_standardKeyboardEvent(e));
    }));
  }

  /// 1:1: `protected onkeyup(domNode, listener)`
  void onkeyup(
      dom.DomElement domNode, void Function(keyboard.IKeyboardEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.KEY_UP, (dom.DomEvent e) {
      listener(_standardKeyboardEvent(e));
    }));
  }

  /// 1:1: `protected oninput(domNode, listener)`
  void oninput(dom.DomElement domNode, void Function(dom.DomEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.INPUT, (dom.DomEvent e) => listener(e)));
  }

  /// 1:1: `protected onblur(domNode, listener)`
  void onblur(dom.DomElement domNode, void Function(dom.DomEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.BLUR, (dom.DomEvent e) => listener(e)));
  }

  /// 1:1: `protected onfocus(domNode, listener)`
  void onfocus(dom.DomElement domNode, void Function(dom.DomEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.FOCUS, (dom.DomEvent e) => listener(e)));
  }

  /// 1:1: `protected onchange(domNode, listener)`
  void onchange(dom.DomElement domNode, void Function(dom.DomEvent e) listener) {
    register(dom.addDisposableListener(
        domNode, dom.EventType.CHANGE, (dom.DomEvent e) => listener(e)));
  }

  /// 1:1: `protected ignoreGesture(domNode): IDisposable`
  IDisposable ignoreGesture(dom.DomElement domNode) =>
      Gesture.ignoreTarget(domNode);

  /// Dart carrier adaptation of `new StandardMouseEvent(getWindow(domNode), e)`.
  /// Mirrors dom.ts `_wrapAsStandardMouseEvent` field mapping 1:1.
  mouse.StandardMouseEvent _standardMouseEvent(
      dom.DomNode domNode, dom.DomEvent e) {
    final dom.DomMouseEvent mouseEvent = e is dom.DomMouseEvent
        ? e
        : dom.DomMouseEvent(e.type)
          ..button = 0
          ..pageX = 0
          ..pageY = 0;
    final targetWindow = dom.getWindow(domNode);
    final iframeWindow = dom.domIframeWindowProvider(targetWindow);
    mouseEvent.view ??= targetWindow;
    return mouse.StandardMouseEvent(
      iframeWindow,
      mouse.MouseEvent(
        button: mouseEvent.button,
        buttons: mouseEvent.buttons,
        detail: mouseEvent.detail,
        type: mouseEvent.type,
        target: mouseEvent.target,
        view: iframeWindow,
        ctrlKey: mouseEvent.ctrlKey,
        shiftKey: mouseEvent.shiftKey,
        altKey: mouseEvent.altKey,
        metaKey: mouseEvent.metaKey,
        defaultPrevented: mouseEvent.defaultPrevented,
        pageX: mouseEvent.pageX,
        pageY: mouseEvent.pageY,
        preventDefaultFn: mouseEvent.preventDefaultFn,
        stopPropagationFn: mouseEvent.stopPropagationFn,
      ),
    );
  }

  /// Dart carrier adaptation of `new StandardKeyboardEvent(e)`.
  /// Mirrors dom.ts `_wrapAsStandardKeyboardEvent` field mapping 1:1.
  keyboard.StandardKeyboardEvent _standardKeyboardEvent(dom.DomEvent e) {
    final dom.DomKeyboardEvent keyEvent = e is dom.DomKeyboardEvent
        ? e
        : dom.DomKeyboardEvent(e.type);
    return keyboard.StandardKeyboardEvent(keyboard.KeyboardEvent(
      keyCode: keyEvent.keyCode,
      ctrlKey: keyEvent.ctrlKey,
      shiftKey: keyEvent.shiftKey,
      altKey: keyEvent.altKey,
      metaKey: keyEvent.metaKey,
      code: keyEvent.code,
      key: keyEvent.key,
      isComposing: keyEvent.isComposing,
      target: keyEvent.target,
      getModifierState: keyEvent.getModifierState,
      preventDefaultFn: keyEvent.preventDefaultFn,
      stopPropagationFn: keyEvent.stopPropagationFn,
    ));
  }
}
