// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/observableValueOpts.ts
// Translated 1:1. `IDebugNameData & { equalsFn?, lazy? }` is expressed as a
// concrete options carrier implementing IDebugNameData (Dart has no structural
// object-literal intersection types).
// ---------------------------------------------------------------------------

import '../base.dart' show ISettableObservable;
import '../commonFacade/deps.dart' show EqualityComparer, strictEquals;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show DebugNameData, IDebugNameData;
import 'lazyObservableValue.dart' show LazyObservableValue;
import 'observableValue.dart' show ObservableValue;

/// 1:1: `IDebugNameData & { equalsFn?: EqualityComparer<T>; lazy?: boolean }`
class ObservableValueOpts<T> implements IDebugNameData {
  ObservableValueOpts({
    this.owner,
    this.debugName,
    this.debugReferenceFn,
    this.equalsFn,
    this.lazy = false,
  });

  @override
  final Object? owner;
  @override
  final Object? debugName;
  @override
  final Function? debugReferenceFn;
  final EqualityComparer<T>? equalsFn;
  final bool lazy;
}

/// 1:1: `observableValueOpts<T, TChange>(options, initialValue, debugLocation?)`
ISettableObservable<T, TChange> observableValueOpts<T, TChange>(
  ObservableValueOpts<T> options,
  T initialValue, [
  DebugLocation? debugLocation,
]) {
  final DebugNameData nameData =
      DebugNameData(options.owner, options.debugName, null);
  final EqualityComparer<T> equalsFn = options.equalsFn ?? strictEquals;
  final DebugLocation? loc = debugLocation ?? DebugLocation.ofCaller();

  if (options.lazy) {
    return LazyObservableValue<T, TChange>(nameData, initialValue, equalsFn, loc);
  }
  return ObservableValue<T, TChange>(nameData, initialValue, equalsFn, loc);
}
