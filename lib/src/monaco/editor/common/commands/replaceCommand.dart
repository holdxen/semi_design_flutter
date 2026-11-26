// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/commands/replaceCommand.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch428).
// ---------------------------------------------------------------------------

import '../core/position.dart' show Position;
import '../core/range.dart' show Range;
import '../core/selection.dart' show Selection, SelectionDirection;
import 'commandInterfaces.dart'
    show
        ICommand,
        ICursorStateComputerData,
        IEditOperationBuilder,
        ITextModelForCommand;

/// Read `inverseEditOperations[i].range` from a Map or named-field carrier.
Range _inverseRange(Object op) {
  if (op is Map) return op['range'] as Range;
  return (op as dynamic).range as Range;
}

/// 1:1: `ReplaceCommand`.
class ReplaceCommand implements ICommand {
  final Range _range;
  final String _text;
  /// Optional TS member (`insertsAutoWhitespace?`), not in the local ICommand.
  final bool insertsAutoWhitespace;

  ReplaceCommand(this._range, this._text, [this.insertsAutoWhitespace = false]);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(_range, _text);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final Object op = helper.getInverseEditOperations()[0]!;
    final Range srcRange = _inverseRange(op);
    return Selection.fromPositions(srcRange.getEndPosition());
  }
}

/// 1:1: `ReplaceOvertypeCommand`.
class ReplaceOvertypeCommand implements ICommand {
  final Range _range;
  final String _text;
  /// Optional TS member (`insertsAutoWhitespace?`), not in the local ICommand.
  final bool insertsAutoWhitespace;

  ReplaceOvertypeCommand(this._range, this._text,
      [this.insertsAutoWhitespace = false]);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    final Position initialStartPosition = _range.getStartPosition();
    final Position initialEndPosition = _range.getEndPosition();
    final int initialEndLineNumber = initialEndPosition.lineNumber;
    final int offsetDelta = _text.length + (_range.isEmpty() ? 0 : -1);
    Position endPosition =
        addPositiveOffsetToModelPosition(model, initialEndPosition, offsetDelta);
    if (endPosition.lineNumber > initialEndLineNumber) {
      endPosition = Position(
        initialEndLineNumber,
        model.getLineMaxColumn(initialEndLineNumber),
      );
    }
    final Range replaceRange =
        Range.fromPositions(initialStartPosition, end: endPosition);
    builder.addTrackedEditOperation(replaceRange, _text);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final Object op = helper.getInverseEditOperations()[0]!;
    final Range srcRange = _inverseRange(op);
    return Selection.fromPositions(srcRange.getEndPosition());
  }
}

/// 1:1: `ReplaceCommandThatSelectsText`.
class ReplaceCommandThatSelectsText implements ICommand {
  final Range _range;
  final String _text;

  ReplaceCommandThatSelectsText(this._range, this._text);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(_range, _text);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final Object op = helper.getInverseEditOperations()[0]!;
    final Range srcRange = _inverseRange(op);
    return Selection.fromRange(srcRange, SelectionDirection.LTR);
  }
}

/// 1:1: `ReplaceCommandWithoutChangingPosition`.
class ReplaceCommandWithoutChangingPosition implements ICommand {
  final Range _range;
  final String _text;
  /// Optional TS member (`insertsAutoWhitespace?`), not in the local ICommand.
  final bool insertsAutoWhitespace;

  ReplaceCommandWithoutChangingPosition(this._range, this._text,
      [this.insertsAutoWhitespace = false]);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(_range, _text);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final Object op = helper.getInverseEditOperations()[0]!;
    final Range srcRange = _inverseRange(op);
    return Selection.fromPositions(srcRange.getStartPosition());
  }
}

/// 1:1: `ReplaceCommandWithOffsetCursorState`.
class ReplaceCommandWithOffsetCursorState implements ICommand {
  final Range _range;
  final String _text;
  final int _columnDeltaOffset;
  final int _lineNumberDeltaOffset;
  /// Optional TS member (`insertsAutoWhitespace?`), not in the local ICommand.
  final bool insertsAutoWhitespace;

  ReplaceCommandWithOffsetCursorState(
    this._range,
    this._text,
    this._lineNumberDeltaOffset,
    this._columnDeltaOffset, [
    this.insertsAutoWhitespace = false,
  ]);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(_range, _text);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final Object op = helper.getInverseEditOperations()[0]!;
    final Range srcRange = _inverseRange(op);
    return Selection.fromPositions(srcRange.getEndPosition().delta(
      deltaLineNumber: _lineNumberDeltaOffset,
      deltaColumn: _columnDeltaOffset,
    ));
  }
}

/// 1:1: `ReplaceOvertypeCommandOnCompositionEnd`.
class ReplaceOvertypeCommandOnCompositionEnd implements ICommand {
  final Range _range;

  ReplaceOvertypeCommandOnCompositionEnd(this._range);

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    final String text = model.getValueInRange(_range);
    final Position initialEndPosition = _range.getEndPosition();
    final int initialEndLineNumber = initialEndPosition.lineNumber;
    Position endPosition =
        addPositiveOffsetToModelPosition(model, initialEndPosition, text.length);
    if (endPosition.lineNumber > initialEndLineNumber) {
      endPosition = Position(
        initialEndLineNumber,
        model.getLineMaxColumn(initialEndLineNumber),
      );
    }
    final Range replaceRange =
        Range.fromPositions(initialEndPosition, end: endPosition);
    builder.addTrackedEditOperation(replaceRange, '');
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    final Object op = helper.getInverseEditOperations()[0]!;
    final Range srcRange = _inverseRange(op);
    return Selection.fromPositions(srcRange.getEndPosition());
  }
}

/// 1:1: `ReplaceCommandThatPreservesSelection`.
class ReplaceCommandThatPreservesSelection implements ICommand {
  final Range _range;
  final String _text;
  final Selection _initialSelection;
  final bool _forceMoveMarkers;
  String? _selectionId;

  ReplaceCommandThatPreservesSelection(
    Range editRange,
    this._text,
    this._initialSelection, [
    this._forceMoveMarkers = false,
  ]) : _range = editRange;

  @override
  void getEditOperations(
    ITextModelForCommand model,
    IEditOperationBuilder builder,
  ) {
    builder.addTrackedEditOperation(_range, _text, _forceMoveMarkers);
    _selectionId = builder.trackSelection(_initialSelection);
  }

  @override
  Selection computeCursorState(
    ITextModelForCommand model,
    ICursorStateComputerData helper,
  ) {
    return helper.getTrackedSelection(_selectionId!);
  }
}

/// 1:1: `addPositiveOffsetToModelPosition`.
Position addPositiveOffsetToModelPosition(
  ITextModelForCommand model,
  Position position,
  int offset,
) {
  if (offset < 0) {
    throw StateError('Unexpected negative delta');
  }
  final int lineCount = model.getLineCount();
  Position endPosition =
      Position(lineCount, model.getLineMaxColumn(lineCount));
  for (int lineNumber = position.lineNumber; lineNumber <= lineCount; lineNumber++) {
    if (lineNumber == position.lineNumber) {
      final int futureOffset =
          offset - model.getLineMaxColumn(position.lineNumber) + position.column;
      if (futureOffset <= 0) {
        endPosition = Position(position.lineNumber, position.column + offset);
        break;
      }
      offset = futureOffset;
    } else {
      final int futureOffset = offset - model.getLineMaxColumn(lineNumber);
      if (futureOffset <= 0) {
        endPosition = Position(lineNumber, offset);
        break;
      }
      offset = futureOffset;
    }
  }
  return endPosition;
}
