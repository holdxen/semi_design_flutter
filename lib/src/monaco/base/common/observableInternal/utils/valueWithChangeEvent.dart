// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/utils/valueWithChangeEvent.ts
// Translated 1:1. `Event.fromObservableLight` -> top-level
// `eventFromObservableLight`; `instanceof` -> Dart `is`.
// ---------------------------------------------------------------------------

import '../../event.dart' show eventFromObservableLight;
import '../base.dart' show IObservable;
import '../commonFacade/deps.dart' show Event, IValueWithChangeEvent;
import '../debugName.dart' show DebugOwner;
import '../observables/observableFromEvent.dart' show observableFromEvent;

/// 1:1: `export class ValueWithChangeEventFromObservable<T> implements IValueWithChangeEvent<T>`
class ValueWithChangeEventFromObservable<T>
    implements IValueWithChangeEvent<T> {
  final IObservable<T> observable;

  ValueWithChangeEventFromObservable(this.observable);

  @override
  Event<void> get onDidChange => eventFromObservableLight(observable);

  @override
  T get value => observable.get();
}

/// 1:1: `export function observableFromValueWithChangeEvent<T>(owner, value)`
IObservable<T> observableFromValueWithChangeEvent<T>(
  DebugOwner owner,
  IValueWithChangeEvent<T> value,
) {
  if (value is ValueWithChangeEventFromObservable<T>) {
    return value.observable;
  }
  return observableFromEvent<T, void>(owner, value.onDidChange, (arg) => value.value);
}
