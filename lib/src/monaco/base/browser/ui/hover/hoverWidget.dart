// 1:1 port of vscode/src/vs/base/browser/ui/hover/hoverWidget.ts
import '../../dom.dart' as dom;
import '../../keyboardEvent.dart' as keyboard;
import '../scrollbar/scrollableElement.dart' show DomScrollableElement;
import '../scrollbar/scrollableElementOptions.dart' show ScrollableElementCreationOptions;
import '../../../common/keyCodes.dart' show KeyCode;
import '../../../common/lifecycle.dart' show Disposable;
import '../../../../nls.dart' as nls;

/// 1:1: `const enum HoverPosition`
class HoverPosition {
  static const int LEFT = 0;
  static const int RIGHT = 1;
  static const int BELOW = 2;
  static const int ABOVE = 3;
}

/// Action options carrier for [HoverAction.render].
class HoverActionOptions {
  HoverActionOptions({
    required this.label,
    this.iconClass,
    required this.run,
    required this.commandId,
  });
  final String label;
  final String? iconClass;
  final void Function(dom.DomElement target) run;
  final String commandId;
}

/// 1:1: `export class HoverWidget extends Disposable`
class HoverWidget extends Disposable {
  HoverWidget(bool fadeIn) : super() {
    containerDomNode = dom.document.createElement('div');
    containerDomNode.className = 'monaco-hover';
    containerDomNode.classList.toggle('fade-in', !!fadeIn);
    containerDomNode.tabIndex = 0;
    containerDomNode.setAttribute('role', 'tooltip');

    contentsDomNode = dom.document.createElement('div');
    contentsDomNode.className = 'monaco-hover-content';

    scrollbar = register(DomScrollableElement(contentsDomNode,
        ScrollableElementCreationOptions()
          ..consumeMouseWheelIfScrollbarIsNeeded = true));
    containerDomNode.appendChild(scrollbar.getDomNode());
  }

  late final dom.DomElement containerDomNode;
  late final dom.DomElement contentsDomNode;
  late final DomScrollableElement scrollbar;

  /// 1:1: `onContentsChanged()`
  void onContentsChanged() => scrollbar.scanDomNode();
}

/// 1:1: `export class HoverAction extends Disposable`
class HoverAction extends Disposable {
  HoverAction._(
    dom.DomElement parent,
    HoverActionOptions actionOptions,
    String? keybindingLabel,
  ) : super() {
    actionLabel = actionOptions.label;
    actionKeybindingLabel = keybindingLabel;

    actionContainer = dom.append(
        parent, <Object>[dom.$('div.action-container')]) as dom.DomElement;
    actionContainer.setAttribute('tabindex', '0');

    action = dom.append(actionContainer, <Object>[dom.$('a.action')])
        as dom.DomElement;
    action.setAttribute('role', 'button');
    if (actionOptions.iconClass != null) {
      final dom.DomElement iconElement = dom.append(
          action, <Object>[dom.$('span.icon')]) as dom.DomElement;
      for (final String cls in actionOptions.iconClass!.split(' ')) {
        iconElement.classList.add(cls);
      }
    }
    actionRenderedLabel = keybindingLabel != null
        ? '${actionOptions.label} ($keybindingLabel)'
        : actionOptions.label;
    final dom.DomElement label =
        dom.append(action, <Object>[dom.$('span')]) as dom.DomElement;
    label.textContent = actionRenderedLabel;

    register(ClickAction(actionContainer, actionOptions.run));
    register(KeyDownAction(actionContainer, actionOptions.run, <int>[
      KeyCode.Enter,
      KeyCode.Space
    ]));
    setEnabled(true);
  }

  /// 1:1: `static render(parent, actionOptions, keybindingLabel)`
  static HoverAction render(dom.DomElement parent,
          HoverActionOptions actionOptions, String? keybindingLabel) =>
      HoverAction._(parent, actionOptions, keybindingLabel);

  late final String actionLabel;
  late final String? actionKeybindingLabel;
  late final String actionRenderedLabel;
  late final dom.DomElement actionContainer;
  late final dom.DomElement action;

  /// 1:1: `setEnabled(enabled)`
  void setEnabled(bool enabled) {
    if (enabled) {
      actionContainer.classList.remove('disabled');
      actionContainer.removeAttribute('aria-disabled');
    } else {
      actionContainer.classList.add('disabled');
      actionContainer.setAttribute('aria-disabled', 'true');
    }
  }
}

/// 1:1: `getHoverAccessibleViewHint`
String getHoverAccessibleViewHint(
    [bool? shouldHaveHint, String? keybinding]) {
  if (shouldHaveHint == true && keybinding != null) {
    return nls.localize('acessibleViewHint',
        'Inspect this in the accessible view with {0}.', <Object?>[keybinding]);
  }
  if (shouldHaveHint == true) {
    return nls.localize(
        'acessibleViewHintNoKbOpen',
        'Inspect this in the accessible view via the command Open Accessible View which is currently not triggerable via keybinding.');
  }
  return '';
}

/// 1:1: `export class ClickAction extends Disposable`
class ClickAction extends Disposable {
  ClickAction(dom.DomElement container, void Function(dom.DomElement target) run)
      : super() {
    register(dom.addDisposableListener(
        container, dom.EventType.CLICK, (dom.DomEvent e) {
      e.stopPropagation();
      e.preventDefault();
      run(container);
    }));
  }
}

/// 1:1: `export class KeyDownAction extends Disposable`
class KeyDownAction extends Disposable {
  KeyDownAction(dom.DomElement container,
      void Function(dom.DomElement target) run, List<int> keyCodes)
      : super() {
    register(dom.addDisposableListener(
        container, dom.EventType.KEY_DOWN, (dom.DomEvent e) {
      final dom.DomKeyboardEvent keyEvent = e is dom.DomKeyboardEvent
          ? e
          : dom.DomKeyboardEvent(e.type)..keyCode = e.keyCode;
      final keyboard.StandardKeyboardEvent event =
          keyboard.StandardKeyboardEvent(keyboard.KeyboardEvent(
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
      if (keyCodes.any((int keyCode) => event.equals(keyCode))) {
        e.stopPropagation();
        e.preventDefault();
        run(container);
      }
    }));
  }
}
