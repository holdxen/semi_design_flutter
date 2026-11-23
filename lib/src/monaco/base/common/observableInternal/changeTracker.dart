// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/changeTracker.ts
// Translated 1:1. TypeScript generic mapped/conditional types (which only
// shape compile-time summaries) are represented with `Object?` carriers and
// `Map<String, Object?>`; runtime behavior is preserved exactly.
// ---------------------------------------------------------------------------

import '../../common/errors.dart' show BugIndicatingError;
import 'base.dart' show IObservableWithChange, IReader;

/// 1:1: `interface IChangeContext`
abstract class IChangeContext {
  IObservableWithChange<Object?, Object?> get changedObservable;
  Object? get change;

  /// Returns if the given observable caused the change.
  bool didChange<T, TChange>(IObservableWithChange<T, TChange> observable);
}

/// 1:1: `interface IChangeTracker<TChangeSummary>`
abstract class IChangeTracker<TChangeSummary> {
  TChangeSummary createChangeSummary(TChangeSummary? previousChangeSummary);
  bool handleChange(IChangeContext ctx, TChangeSummary change);
  void beforeUpdate(IReader reader, TChangeSummary change);
}

/// Carrier for a recorded change: `{ key, change }`.
/// 1:1: `{ [TKey in keyof TObs]: { key: TKey; change: TObs[TKey]['TChange'] } }[keyof TObs]`
class RecordedChange {
  final String key;
  final Object? change;
  const RecordedChange(this.key, this.change);

  @override
  String toString() => 'RecordedChange($key, $change)';
}

/// Summary carrier: one entry per observable key plus the reserved
/// `changes` list. Mirrors the TypeScript intersection summary object.
class ChangeSummary {
  final List<RecordedChange> changes;
  final Map<String, Object?> values;
  ChangeSummary() : changes = <RecordedChange>[], values = <String, Object?>{};

  Object? operator [](String key) => key == 'changes' ? changes : values[key];
  void operator []=(String key, Object? value) {
    if (key == 'changes') {
      throw ArgumentError('property name "changes" is reserved for change tracking');
    }
    values[key] = value;
  }
}

/// 1:1: `interface IObservableRecord` — the `Record<any, IObservableWithChange>` shape.
/// A plain Dart map is used directly; this typedef documents the source type.
typedef ObservableRecord = Map<String, IObservableWithChange<Object?, Object?>>;

/// 1:1: `function recordChanges(obs: TObs): IChangeTracker<...>`
IChangeTracker<ChangeSummary> recordChanges(ObservableRecord obs) {
  return _ChangeTracker(obs, () => obs);
}

/// 1:1: `function recordChangesLazy(getObs: () => TObs): IChangeTracker<...>`
IChangeTracker<ChangeSummary> recordChangesLazy(ObservableRecord Function() getObs) {
  return _ChangeTracker(null, getObs);
}

class _ChangeTracker implements IChangeTracker<ChangeSummary> {
  ObservableRecord? _obs;
  final ObservableRecord Function() _getObs;
  _ChangeTracker(ObservableRecord? obs, this._getObs) : _obs = obs;

  ObservableRecord _ensureObs() => _obs ??= _getObs();

  @override
  ChangeSummary createChangeSummary(ChangeSummary? previousChangeSummary) {
    return ChangeSummary();
  }

  @override
  bool handleChange(IChangeContext ctx, ChangeSummary changeSummary) {
    final ObservableRecord obs = _ensureObs();
    for (final String key in obs.keys) {
      if (ctx.didChange(obs[key]!)) {
        changeSummary.changes.add(RecordedChange(key, ctx.change));
      }
    }
    return true;
  }

  @override
  void beforeUpdate(IReader reader, ChangeSummary changeSummary) {
    final ObservableRecord obs = _ensureObs();
    for (final String key in obs.keys) {
      if (key == 'changes') {
        throw BugIndicatingError('property name "changes" is reserved for change tracking');
      }
      changeSummary[key] = obs[key]!.read(reader);
    }
  }
}
