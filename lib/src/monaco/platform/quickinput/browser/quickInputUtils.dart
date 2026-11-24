// 1:1 port of vscode/src/vs/platform/quickinput/browser/quickInputUtils.ts
//
// Carriers: DOM, `domStylesheets.createCSSRule`, `cssValue.asCSSUrl`,
// `iconLabels.renderLabelWithIcons`, `linkedText.parseLinkedText`,
// `IdGenerator`, `DomEmitter`/`Gesture` and `IAction` are the existing ports.
//
// Adaptations (documented inline):
//  * `quickInput.css` side-effect import dropped (styling lives in the Flutter
//    widget layer).
//  * `{ dark: URI; light?: URI }` / `{ checked: boolean }` bags →
//    `IconPath` / `QuickInputToggle` carriers from quickInput.dart.
//  * The plain action object literal → [_QuickInputButtonAction].
import '../../../base/browser/cssValue.dart' as cssJs;
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/domStylesheets.dart' as domStylesheetsJs;
import '../../../base/browser/event.dart' show DomEmitter;
import '../../../base/browser/keyboardEvent.dart' as keyboard
    show StandardKeyboardEvent, KeyboardEvent;
import '../../../base/browser/touch.dart' as touch;
import '../../../base/browser/ui/iconLabel/iconLabels.dart'
    show renderLabelWithIcons;
import '../../../base/common/actions.dart' show IAction;
import '../../../base/common/event.dart' show Event, eventAny, eventChain;
import '../../../base/common/idGenerator.dart' show IdGenerator;
import '../../../base/common/keyCodes.dart' show KeyCode;
import '../../../base/common/linkedText.dart' show ILink, parseLinkedText;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../nls.dart' show localize;
import '../common/quickInput.dart' show IQuickInputButton, IconPath, QuickInputToggle;

final Map<String, String> iconPathToClass = <String, String>{};
final IdGenerator iconClassGenerator =
    IdGenerator('quick-input-button-icon-');

String? _getIconClass(IconPath? iconPath) {
  if (iconPath == null) {
    return null;
  }
  String iconClass;

  final String key = iconPath.dark.toString();
  final String? cached = iconPathToClass[key];
  if (cached != null) {
    iconClass = cached;
  } else {
    iconClass = iconClassGenerator.nextId();
    domStylesheetsJs.createCSSRule(
      '.$iconClass, .hc-light .$iconClass',
      'background-image: ${cssJs.asCSSUrl(
        iconPath.light ?? iconPath.dark,
      )}',
    );
    domStylesheetsJs.createCSSRule(
      '.vs-dark .$iconClass, .hc-black .$iconClass',
      'background-image: ${cssJs.asCSSUrl(iconPath.dark)}',
    );
    iconPathToClass[key] = iconClass;
  }

  return iconClass;
}

/// 1:1: `class QuickInputToggleButtonAction implements IAction`.
class QuickInputToggleButtonAction implements IAction {
  QuickInputToggleButtonAction(
    this.id,
    this.label,
    this.tooltip,
    String? className,
    this.enabled,
    bool checked,
    this._run,
  ) : _checked = checked,
      cssClass = className;

  @override
  final String id;
  @override
  String label;
  @override
  String tooltip;
  @override
  final String? cssClass;
  @override
  final bool enabled;

  final Object? Function() _run;

  bool _checked;

  @override
  bool? get checked => _checked;
  set checked(bool? value) {
    _checked = value ?? false;
    // Toggles behave like buttons. When clicked, they run... the only
    // difference is that their checked state also changes.
    _run();
  }

  @override
  IAction? get alt => null;

  @override
  Object? run([Object? event, Object? data]) {
    _checked = !_checked;
    return _run();
  }
}

/// TS plain action object literal `{ id, label, tooltip, class, enabled, run }`.
class _QuickInputButtonAction implements IAction {
  _QuickInputButtonAction({
    required this.id,
    required String label,
    required this.tooltip,
    required this.cssClass,
    required this.enabled,
    required this.runFn,
  }) : _label = label;

  @override
  final String id;
  String _label;
  @override
  String get label => _label;
  set label(String value) => _label = value;
  @override
  final String tooltip;
  @override
  final String? cssClass;
  @override
  final bool enabled;
  final Object? Function() runFn;

  @override
  bool? get checked => null;
  set checked(bool? value) {}

  @override
  IAction? get alt => null;

  @override
  Object? run([Object? event, Object? data]) => runFn();
}

IAction quickInputButtonToAction(
  IQuickInputButton button,
  String id,
  Object? Function() run,
) {
  String? cssClasses = button.iconClass ?? _getIconClass(button.iconPath);
  if (button.alwaysVisible == true) {
    cssClasses = cssClasses != null ? '$cssClasses always-visible' : 'always-visible';
  }

  Object? handler() {
    final QuickInputToggle? toggle = button.toggle;
    if (toggle != null) {
      toggle.checked = !toggle.checked;
    }
    return run();
  }

  final QuickInputToggle? toggle = button.toggle;
  final IAction action = toggle != null
      ? QuickInputToggleButtonAction(
          id,
          button.tooltip ?? '',
          '',
          cssClasses,
          true,
          toggle.checked,
          () => handler(),
        )
      : _QuickInputButtonAction(
          id: id,
          label: '',
          tooltip: button.tooltip ?? '',
          cssClass: cssClasses,
          enabled: true,
          runFn: () => handler(),
        );

  return action;
}

QuickInputActions quickInputButtonsToActionArrays(
  List<IQuickInputButton> buttons,
  String idPrefix,
  Object? Function(IQuickInputButton button) onTrigger,
) {
  final List<IAction> primary = <IAction>[];
  final List<IAction> secondary = <IAction>[];

  for (int index = 0; index < buttons.length; index++) {
    final IQuickInputButton button = buttons[index];
    final IAction action = quickInputButtonToAction(
      button,
      '$idPrefix-$index',
      () async => onTrigger(button),
    );

    if (button.label != null) {
      // TS mutates the action literal; both Dart carriers expose a public
      // `label` setter, reached structurally here.
      (action as dynamic).label = button.label!;
    }

    if (button.secondary == true) {
      secondary.add(action);
    } else {
      primary.add(action);
    }
  }

  return QuickInputActions(primary: primary, secondary: secondary);
}

/// `{ primary: IAction[]; secondary: IAction[] }`.
class QuickInputActions {
  QuickInputActions({required this.primary, required this.secondary});

  final List<IAction> primary;
  final List<IAction> secondary;
}

/// `{ callback; disposables }` action-handler bag.
class IQuickInputDescriptionActionHandler {
  IQuickInputDescriptionActionHandler({
    required this.callback,
    required this.disposables,
  });

  final void Function(String content) callback;
  final lifecycle.DisposableStore disposables;
}

void renderQuickInputDescription(
  String description,
  dom.DomElement container,
  IQuickInputDescriptionActionHandler actionHandler,
) {
  dom.reset(container, <Object>[]);
  final parsed = parseLinkedText(description);
  int tabIndex = 0;
  for (final Object node in parsed.nodes) {
    if (node is String) {
      for (final Object rendered in renderLabelWithIcons(node)) {
        if (rendered is String) {
          container.append(rendered);
        } else if (rendered is dom.DomNode) {
          container.appendChild(rendered);
        }
      }
    } else {
      final ILink link = node as ILink;
      String? title = link.title;

      if (title == null && link.href.startsWith('command:')) {
        title = localize('executeCommand',
            "Click to execute command '{0}'",
            <Object?>[link.href.substring('command:'.length)]);
      } else if (title == null) {
        title = link.href;
      }

      final dom.DomElement anchor = dom.$(
        'a',
        <String, Object?>{
          'href': link.href,
          'title': title,
          'tabIndex': tabIndex++,
        },
        <Object>[link.label],
      );
      anchor.style['textDecoration'] = 'underline';
      void handleOpen(Object e) {
        if (dom.isEventLike(e)) {
          dom.EventHelper.stop(e as dom.EventLike, true);
        }

        actionHandler.callback(link.href);
      }

      final Event<Object> onClick = actionHandler.disposables
          .add(DomEmitter<Object>(anchor, dom.EventType.CLICK))
          .event;
      final Event<Object> onKeydown = actionHandler.disposables
          .add(DomEmitter<Object>(anchor, dom.EventType.KEY_DOWN))
          .event;
      final Event<Object> onSpaceOrEnter = eventChain<Object, Object>(
        onKeydown,
        (dynamic synthesis) => (synthesis as dynamic)
            .filter((dynamic e) {
              // Dart carrier adaptation of `new StandardKeyboardEvent(e)`,
              // mirroring dom.ts `_wrapAsStandardKeyboardEvent`.
              final dom.DomKeyboardEvent keyEvent = e is dom.DomKeyboardEvent
                  ? e
                  : dom.DomKeyboardEvent((e as dom.DomEvent).type);
              final keyboard.StandardKeyboardEvent event = keyboard.StandardKeyboardEvent(
                keyboard.KeyboardEvent(
                  type: keyEvent.type,
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
                ),
              );
              return event.equals(KeyCode.Space) ||
                  event.equals(KeyCode.Enter);
            }),
      );

      actionHandler.disposables
          .add(touch.Gesture.addTarget(anchor));
      final Event<Object> onTap = actionHandler.disposables
          .add(DomEmitter<Object>(anchor, touch.EventType.Tap))
          .event;

      eventAny<Object>(<Event<Object>>[onClick, onTap, onSpaceOrEnter])(
          (Object e) => handleOpen(e));
      container.appendChild(anchor);
    }
  }
}