// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/experimental/utils.ts
// Translated 1:1. The object-literal dispose member in latestChangedValue is
// represented by `toDisposable`; the debugName closure passes through a
// DebugNameDataLike carrier.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservable, IReader;
import '../commonFacade/deps.dart'
    show BugIndicatingError, DisposableStore, toDisposable;
import '../debugName.dart'
    show DebugNameData, DebugNameDataLike, DebugOwner, getDebugName;
import '../observables/observableFromEvent.dart' show observableFromEvent;
import '../reactions/autorun.dart' show autorunOpts;
import '../utils/utils.dart' show derivedObservableWithCache;

/// 1:1: `latestChangedValue`
IObservable<T> latestChangedValue<T>(
  DebugOwner owner,
  List<IObservable<Object?>> observables,
) {
  if (observables.isEmpty) {
    throw BugIndicatingError();
  }

  bool hasLastChangedValue = false;
  Object? lastChangedValue;

  late final IObservable<T> result;
  result = observableFromEvent<T, void>(
    owner,
    (dynamic cb, [dynamic thisArgs, dynamic disposables]) {
      final DisposableStore store = DisposableStore();
      for (final o in observables) {
        store.add(autorunOpts(
          DebugNameDataLike(
            debugName: () =>
                '${getDebugName(result, DebugNameData(owner, null, null)) ?? ''}.updateLastChangedValue',
          ),
          (IReader reader) {
            hasLastChangedValue = true;
            lastChangedValue = o.read(reader);
            (cb as void Function())();
          },
        ));
      }
      store.add(toDisposable(() {
        hasLastChangedValue = false;
        lastChangedValue = null;
      }));
      return store;
    },
    (void _) {
      if (hasLastChangedValue) {
        return lastChangedValue as T;
      } else {
        return observables[observables.length - 1].get() as T;
      }
    },
  );
  return result;
}

/// 1:1: `derivedConstOnceDefined`
IObservable<T?> derivedConstOnceDefined<T>(
  DebugOwner owner,
  T Function(IReader reader) fn,
) {
  return derivedObservableWithCache<T?>(
    owner,
    (IReader reader, T? lastValue) => lastValue ?? fn(reader),
  );
}
