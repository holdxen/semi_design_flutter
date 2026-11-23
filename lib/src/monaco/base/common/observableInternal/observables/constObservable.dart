// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/observables/constObservable.ts
// Translated 1:1.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservable, IObservableWithChange, IObserver;
import 'baseObservable.dart' show ConvenientObservable;

/// 1:1: `export function constObservable<T>(value): IObservable<T>`
IObservable<T> constObservable<T>(T value) => ConstObservable<T>(value);

/// 1:1: `class ConstObservable<T> extends ConvenientObservable<T, void>`
class ConstObservable<T> extends ConvenientObservable<T, Object?>
    implements IObservable<T> {
  ConstObservable(this.value) : super();

  final T value;

  @override
  String get debugName => toString();

  @override
  T get() => value;

  @override
  void addObserver(IObserver observer) {
    // NO OP
  }

  @override
  void removeObserver(IObserver observer) {
    // NO OP
  }

  @override
  IObservableWithChange<T, Object?> log() => this;

  @override
  String toString() => 'Const: $value';
}
