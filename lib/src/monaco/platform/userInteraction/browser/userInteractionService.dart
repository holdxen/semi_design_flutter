// 1:1 port of vs/platform/userInteraction/browser/userInteractionService.ts
//
// Runtime surface: the `IUserInteractionService` decorator id, an almost
// stateless mock implementation returning `constObservable`s and a focus
// tracker that fires focus once on the next microtask when simulating focus.

import '../../../base/browser/dom.dart' show IFocusTracker;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, DisposableStore;
export '../../../base/common/lifecycle.dart' show DisposableStore;
import '../../../base/common/observable.dart'
    show IObservable, IReader, constObservable;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IUserInteractionService = createDecorator(...)`
final ServiceIdentifier<IUserInteractionServiceType> IUserInteractionService =
    createDecorator<IUserInteractionServiceType>('userInteractionService');

/// Phantom type carrier for the service interface.
abstract class IUserInteractionServiceType {
  Object? get _serviceBrand;
  IModifierKeyStatus readModifierKeyStatus(Object element, IReader? reader);
  IObservable<bool> createFocusTracker(Object element, DisposableStore store);
  IObservable<bool> createHoverTracker(Object element, DisposableStore store);
  IFocusTracker createDomFocusTracker(Object element);
}

/// 1:1: `export interface IModifierKeyStatus`
class IModifierKeyStatus {
  final bool ctrlKey;
  final bool shiftKey;
  final bool altKey;
  final bool metaKey;
  const IModifierKeyStatus({
    this.ctrlKey = false,
    this.shiftKey = false,
    this.altKey = false,
    this.metaKey = false,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'ctrlKey': ctrlKey,
        'shiftKey': shiftKey,
        'altKey': altKey,
        'metaKey': metaKey,
      };
}

/// 1:1: `export class MockUserInteractionService implements IUserInteractionService`
class MockUserInteractionService implements IUserInteractionServiceType {
  @override
  Object? get _serviceBrand => null;

  final bool _simulateFocus;
  final bool _simulateHover;
  final IModifierKeyStatus _modifiers;

  MockUserInteractionService([
    this._simulateFocus = true,
    this._simulateHover = false,
    this._modifiers = const IModifierKeyStatus(),
  ]);

  @override
  IModifierKeyStatus readModifierKeyStatus(Object element, IReader? reader) =>
      _modifiers;

  @override
  IObservable<bool> createFocusTracker(Object element, DisposableStore store) =>
      constObservable<bool>(_simulateFocus);

  @override
  IObservable<bool> createHoverTracker(Object element, DisposableStore store) =>
      constObservable<bool>(_simulateHover);

  @override
  IFocusTracker createDomFocusTracker(Object element) {
    final _MockFocusTracker tracker = _MockFocusTracker();
    if (_simulateFocus) {
      Future<void>.microtask(tracker.fireFocus);
    }
    return tracker;
  }
}

/// 1:1: the anonymous `new class extends Disposable implements IFocusTracker`.
class _MockFocusTracker extends Disposable implements IFocusTracker {
  final Emitter<void> _onDidFocus = Emitter<void>();
  final Emitter<void> _onDidBlur = Emitter<void>();

  @override
  Event<void> get onDidFocus => _onDidFocus.event;

  @override
  Event<void> get onDidBlur => _onDidBlur.event;

  @override
  void refreshState() {}

  void fireFocus() => _onDidFocus.fire(null);
}
