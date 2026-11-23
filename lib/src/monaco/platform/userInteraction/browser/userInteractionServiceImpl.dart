// 1:1 port of vs/platform/userInteraction/browser/userInteractionServiceImpl.ts
//
// Runtime surface: `UserInteractionService` with a WeakMap cache of per-window
// modifier observables, focus/hover trackers backed by `observableValue`, and
// the `registerSingleton` side effect at module load.

import '../../../base/browser/dom.dart'
    show
        DomDocument,
        DomElement,
        DomEvent,
        DomNode,
        DomShadowRoot,
        IFocusTracker,
        ModifierKeyEmitter,
        getShadowRoot,
        getWindow,
        isShadowRoot,
        trackFocus;
import 'dart:collection' show HashMap;

import '../../../base/common/lifecycle.dart' show DisposableStore, toDisposable;
import '../../../base/common/observable.dart'
    show IObservable, IReader, ISettableObservable, observableFromEvent, observableValue;
import '../../instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../instantiation/common/instantiation.dart' show ServiceIdentifier;
import 'userInteractionService.dart'
    show
        IModifierKeyStatus,
        IUserInteractionService,
        IUserInteractionServiceType;

/// 1:1: `export class UserInteractionService implements IUserInteractionService`
class UserInteractionService implements IUserInteractionServiceType {
  @override
  Object? get _serviceBrand => null;

  /// 1:1: `new WeakMap<Window, IObservable<...>>()`. Dart has no weak refs;
  /// `HashMap.identity()` mirrors JS object-identity keys (project convention).
  final HashMap<Object, IObservable<IModifierKeyStatus>> _modifierObservables =
      HashMap<Object, IObservable<IModifierKeyStatus>>.identity();

  @override
  IModifierKeyStatus readModifierKeyStatus(Object element, IReader? reader) {
    // TS: `element instanceof Window ? element : getWindow(element)`. The Dart
    // carrier has no `Window` global; window-like inputs resolve via getWindow.
    final Object win = getWindow(element);
    IObservable<IModifierKeyStatus>? obs = _modifierObservables[win];
    if (obs == null) {
      final ModifierKeyEmitter emitter = ModifierKeyEmitter.getInstance();
      obs = observableFromEvent<IModifierKeyStatus, Object?>(
          this, emitter.event, (Object? _) => _readKeyStatus(emitter));
      _modifierObservables[win] = obs;
    }
    return obs.read(reader);
  }

  IModifierKeyStatus _readKeyStatus(ModifierKeyEmitter emitter) =>
      IModifierKeyStatus(
        ctrlKey: emitter.keyStatus.ctrlKey,
        shiftKey: emitter.keyStatus.shiftKey,
        altKey: emitter.keyStatus.altKey,
        metaKey: emitter.keyStatus.metaKey,
      );

  @override
  IObservable<bool> createFocusTracker(
      Object element, DisposableStore store) {
    final IFocusTracker tracker = store.add(trackFocus(element));
    // 1:1: `hasFocusWithin(el)`.
    bool hasFocusWithin(Object el) {
      if (el is DomDocument) {
        return el.hasFocus();
      }
      if (el is DomElement) {
        final DomShadowRoot? shadowRoot = getShadowRoot(el);
        final DomElement? activeElement = shadowRoot != null
            ? shadowRoot.activeElement
            : (el.ownerDocument?.activeElement);
        return el.contains(activeElement);
      }
      return false;
    }

    final ISettableObservable<bool, Object?> value =
        observableValue<bool, Object?>('isFocused', hasFocusWithin(element));
    // ignore: avoid_dynamic_calls
    store.add(tracker.onDidFocus((_) => _setValue(value, true)));
    store.add(tracker.onDidBlur((_) => _setValue(value, false)));
    return value;
  }

  /// `observableValue.set` in Dart carries `(value, tx, change)`; the TS
  /// `value.set(v, undefined)` maps to `(v, null, null)`.
  void _setValue(ISettableObservable<bool, Object?> value, bool v) {
    value.set(v, null, null);
  }

  @override
  IObservable<bool> createHoverTracker(Object element, DisposableStore store) {
    final ISettableObservable<bool, Object?> value =
        observableValue<bool, Object?>('isHovered', false);
    void onEnter() => _setValue(value, true);
    void onLeave() => _setValue(value, false);
    if (element is DomElement) {
      final void Function(DomEvent) enterHandler = (DomEvent _) => onEnter();
      final void Function(DomEvent) leaveHandler = (DomEvent _) => onLeave();
      element.addEventListener('mouseenter', enterHandler);
      element.addEventListener('mouseleave', leaveHandler);
      store.add(toDisposable(() {
        element.removeEventListener('mouseenter', enterHandler);
        element.removeEventListener('mouseleave', leaveHandler);
      }));
    }
    return value;
  }

  @override
  IFocusTracker createDomFocusTracker(Object element) => trackFocus(element);
}

/// 1:1 top-level side effect: module-load `registerSingleton(...)`. Dart has no
/// top-level statements; a lazy-initialized `final` reproduces it on first
/// library access (same convention as treeViewsDndService.dart).
final ServiceIdentifier<IUserInteractionServiceType> registration = () {
  registerSingleton<IUserInteractionServiceType>(
    IUserInteractionService, UserInteractionService.new,
      InstantiationType.Delayed);
  return IUserInteractionService;
}();
