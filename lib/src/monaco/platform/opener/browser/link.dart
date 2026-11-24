// 1:1 port of vscode/src/vs/platform/opener/browser/link.ts
//
// Carriers: DOM/EventHelper/DomEmitter/StandardKeyboardEvent/Gesture are the
// existing base ports. `link.css` has no Dart counterpart (styling is carried
// by the Flutter widget layer), so that side-effect import is dropped.
//
// Language adaptations (no algorithm/control-flow change):
//  * TS parameter decorators `@IHoverService` / `@IOpenerService` become the
//    4th/5th positional constructor arguments in the same order.
//  * `el.style.pointerEvents = …` → `el.style['pointerEvents'] = …`
//    (the Dart carrier is a CSS-declaration map).
//  * `typeof link.label === 'string'` → `link.label is String`.
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/event.dart' show DomEmitter;
import '../../../base/browser/keyboardEvent.dart' as keyboard;
import '../../../base/browser/touch.dart' as touch;
import '../../../base/browser/ui/hover/hover.dart' show IManagedHover;
import '../../../base/browser/ui/hover/hoverDelegate.dart' show IHoverDelegate;
import '../../../base/browser/ui/hover/hoverDelegateFactory.dart'
    show getDefaultHoverDelegate;
import '../../../base/common/event.dart'
    show Event, IChainableSynthesis, eventAny, eventChain;
import '../../../base/common/keyCodes.dart' show KeyCode;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../hover/browser/hover.dart' show IHoverServiceType;
import '../common/opener.dart' show IOpenerServiceType, OpenOptions;

/// 1:1: `export interface ILinkDescriptor`.
class ILinkDescriptor {
  ILinkDescriptor({
    required this.label,
    required this.href,
    this.title,
    this.tabIndex,
  });

  /// TS: `string | HTMLElement`.
  final Object label;
  final String href;
  final String? title;
  final int? tabIndex;
}

/// 1:1: `export interface ILinkOptions`.
class ILinkOptions {
  ILinkOptions({
    this.opener,
    this.hoverDelegate,
    this.textLinkForeground,
  });

  final void Function(String href)? opener;
  final IHoverDelegate? hoverDelegate;
  final String? textLinkForeground;
}

/// Dart carrier adaptation of `new StandardKeyboardEvent(e)`, mirroring
/// `dom.ts` `_wrapAsStandardKeyboardEvent` field for field.
keyboard.StandardKeyboardEvent _standardKeyboardEvent(dom.DomEvent e) {
  final dom.DomKeyboardEvent keyEvent =
      e is dom.DomKeyboardEvent ? e : dom.DomKeyboardEvent(e.type);
  return keyboard.StandardKeyboardEvent(keyboard.KeyboardEvent(
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
  ));
}

/// 1:1: `export class Link extends Disposable`.
class Link extends lifecycle.Disposable {
  late final dom.DomElement el;
  IManagedHover? hover;
  late final IHoverDelegate hoverDelegate;

  bool _enabled = true;

  late ILinkDescriptor _link;

  /// 1:1: `@IHoverService private readonly _hoverService`.
  late final IHoverServiceType _hoverService;

  bool get enabled {
    return _enabled;
  }

  set enabled(bool enabled) {
    if (enabled) {
      el.setAttribute('aria-disabled', 'false');
      el.tabIndex = 0;
      el.style['pointerEvents'] = 'auto';
      el.style['opacity'] = '1';
      el.style['cursor'] = 'pointer';
      // Quirk preserved verbatim from the source: the branch writes the
      // opposite value, then the trailing assignment wins.
      _enabled = false;
    } else {
      el.setAttribute('aria-disabled', 'true');
      el.tabIndex = -1;
      el.style['pointerEvents'] = 'none';
      el.style['opacity'] = '0.4';
      el.style['cursor'] = 'default';
      // Quirk preserved verbatim from the source.
      _enabled = true;
    }

    _enabled = enabled;
  }

  set link(ILinkDescriptor link) {
    if (link.label is String) {
      el.textContent = link.label as String;
    } else {
      dom.clearNode(el);
      el.appendChild(link.label as dom.DomNode);
    }

    el.href = link.href;

    if (link.tabIndex != null) {
      el.tabIndex = link.tabIndex!;
    }

    setTooltip(link.title);

    _link = link;
  }

  Link(
    dom.DomElement container,
    this._link, [
    ILinkOptions? options,
    IHoverServiceType? hoverService,
    IOpenerServiceType? openerService,
  ]) : super() {
    // TS injects both services (`@IHoverService`, `@IOpenerService`); Dart has
    // no parameter decorators, so DI supplies them positionally in TS order.
    _hoverService = hoverService!;
    final IOpenerServiceType opener = openerService!;
    final ILinkOptions linkOptions = options ?? ILinkOptions();

    el = dom.append(container, <Object>[
      dom.$(
        'a.monaco-link',
        <String, Object?>{
          'tabIndex': _link.tabIndex ?? 0,
          'href': _link.href,
        },
        <Object>[_link.label],
      ),
    ]) as dom.DomElement;

    hoverDelegate =
        linkOptions.hoverDelegate ?? getDefaultHoverDelegate('mouse');
    setTooltip(_link.title);

    el.setAttribute('role', 'button');

    final DomEmitter<Object> onClickEmitter =
        register(DomEmitter<Object>(el, 'click'));
    final DomEmitter<Object> onKeyDown =
        register(DomEmitter<Object>(el, 'keydown'));
    final Event<Object> onKeyActivate = eventChain<Object, Object>(
      onKeyDown.event,
      (IChainableSynthesis<dynamic> synthesis) => synthesis
          .map((dynamic e) =>
              _standardKeyboardEvent(e as dom.DomEvent))
          .filter((dynamic e) {
        final keyboard.StandardKeyboardEvent keyboardEvent =
            e as keyboard.StandardKeyboardEvent;
        return keyboardEvent.keyCode == KeyCode.Enter ||
            keyboardEvent.keyCode == KeyCode.Space;
      }),
    );
    final Event<Object> onTap =
        register(DomEmitter<Object>(el, touch.EventType.Tap)).event;
    register(touch.Gesture.addTarget(el));
    final Event<Object> onOpen = eventAny<Object>(<Event<Object>>[
      onClickEmitter.event,
      onKeyActivate,
      onTap,
    ]);

    register(onOpen((Object e) {
      if (!enabled) {
        return;
      }

      dom.EventHelper.stop(e as dom.EventLike, true);

      final void Function(String href)? openerOption = linkOptions.opener;
      if (openerOption != null) {
        openerOption(_link.href);
      } else {
        opener.open(_link.href, OpenOptions(allowCommands: true));
      }
    }));

    enabled = true;
  }

  void setTooltip(String? title) {
    if (hover == null && title != null && title.isNotEmpty) {
      hover = register(
          _hoverService.setupManagedHover(hoverDelegate, el, title));
    } else if (hover != null) {
      hover!.update(title);
    }
  }
}