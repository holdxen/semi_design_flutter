// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/coordinatesConverter.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// TS interfaces (`ICoordinatesConverter`, `ITextModel`) are erased per repo
// convention. `ICoordinatesConverter` is kept as a Dart contract so the runtime
// class can implement it; `ITextModel` is reduced to the three members the
// converter actually reads (`validatePosition`/`validateRange`/`getLineCount`).
// ---------------------------------------------------------------------------

import 'core/position.dart';
import 'core/range.dart';
import 'model.dart' show PositionAffinity;

/// Minimal Dart contract for the members of `ITextModel` read by
/// [IdentityCoordinatesConverter]. Mirrors TS structural typing: any object
/// exposing these members can drive the converter.
abstract class ITextModelForCoordinatesConverter {
  Position validatePosition(Position pos);
  Range validateRange(Range range);
  int getLineCount();
}

/// 1:1: `export interface ICoordinatesConverter`
abstract class ICoordinatesConverter {
  Position convertViewPositionToModelPosition(Position viewPosition);
  Range convertViewRangeToModelRange(Range viewRange);
  Position validateViewPosition(Position viewPosition, Position expectedModelPosition);
  Range validateViewRange(Range viewRange, Range expectedModelRange);
  Position convertModelPositionToViewPosition(Position modelPosition,
      {PositionAffinity? affinity,
      bool allowZeroLineNumber = false,
      bool belowHiddenRanges = false});
  Range convertModelRangeToViewRange(Range modelRange, {PositionAffinity? affinity});
  bool modelPositionIsVisible(Position modelPosition);
  int getModelLineViewLineCount(int modelLineNumber);
  int getViewLineNumberOfModelPosition(int modelLineNumber, int modelColumn);
}

/// 1:1: `export class IdentityCoordinatesConverter implements ICoordinatesConverter`
class IdentityCoordinatesConverter implements ICoordinatesConverter {
  final ITextModelForCoordinatesConverter _model;

  IdentityCoordinatesConverter(this._model);

  Position _validPosition(Position pos) => _model.validatePosition(pos);
  Range _validRange(Range range) => _model.validateRange(range);

  @override
  Position convertViewPositionToModelPosition(Position viewPosition) =>
      _validPosition(viewPosition);

  @override
  Range convertViewRangeToModelRange(Range viewRange) => _validRange(viewRange);

  @override
  Position validateViewPosition(
          Position _viewPosition, Position expectedModelPosition) =>
      _validPosition(expectedModelPosition);

  @override
  Range validateViewRange(Range _viewRange, Range expectedModelRange) =>
      _validRange(expectedModelRange);

  @override
  Position convertModelPositionToViewPosition(Position modelPosition,
      {PositionAffinity? affinity,
      bool allowZeroLineNumber = false,
      bool belowHiddenRanges = false}) {
    // Identity converter ignores affinity/zero-line/hidden-range flags.
    return _validPosition(modelPosition);
  }

  @override
  Range convertModelRangeToViewRange(Range modelRange, {PositionAffinity? affinity}) =>
      _validRange(modelRange);

  @override
  bool modelPositionIsVisible(Position modelPosition) {
    final int lineCount = _model.getLineCount();
    if (modelPosition.lineNumber < 1 || modelPosition.lineNumber > lineCount) {
      return false;
    }
    return true;
  }

  /// 1:1: `public modelRangeIsVisible(modelRange: Range): boolean`
  /// (not part of `ICoordinatesConverter`, but present on the runtime class).
  bool modelRangeIsVisible(Range modelRange) {
    final int lineCount = _model.getLineCount();
    if (modelRange.startLineNumber < 1 || modelRange.startLineNumber > lineCount) {
      return false;
    }
    if (modelRange.endLineNumber < 1 || modelRange.endLineNumber > lineCount) {
      return false;
    }
    return true;
  }

  @override
  int getModelLineViewLineCount(int modelLineNumber) => 1;

  @override
  int getViewLineNumberOfModelPosition(int modelLineNumber, int modelColumn) =>
      modelLineNumber;
}
