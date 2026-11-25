// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/services/renameSymbolTrackerService.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `ITextModel` is an erased carrier.
//  * `observableValue<T, TChange>` uses the real port's two-type-parameter form.
//  * `createDecorator` / `ServiceIdentifier` reused from the real port.
// ---------------------------------------------------------------------------

import '../../../base/common/observable.dart'
    show IObservable, observableValue;
import '../../common/core/position.dart' show Position;
import '../../common/core/range.dart' show Range;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `IRenameSymbolTrackerService` service decorator.
final ServiceIdentifier<IRenameSymbolTrackerServiceType>
    IRenameSymbolTrackerService =
    createDecorator<IRenameSymbolTrackerServiceType>(
        'renameSymbolTrackerService');

/// 1:1: `ITrackedWord`.
abstract class ITrackedWord {
  Object get model;
  String get originalWord;
  Position get originalPosition;
  Range get originalRange;
  String get currentWord;
  Range get currentRange;
}

/// 1:1: `IRenameSymbolTrackerService`.
abstract class IRenameSymbolTrackerServiceType {
  IObservable<ITrackedWord?> get trackedWord;
}

/// 1:1: `NullRenameSymbolTrackerService`.
class NullRenameSymbolTrackerService
    implements IRenameSymbolTrackerServiceType {
  final IObservable<ITrackedWord?> _trackedWord;

  NullRenameSymbolTrackerService()
      : _trackedWord = observableValue<ITrackedWord?, Object?>(
          'trackedWord',
          null,
        );

  @override
  IObservable<ITrackedWord?> get trackedWord => _trackedWord;
}
