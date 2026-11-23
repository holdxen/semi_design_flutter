// Port of `packages/core/src/internal/data-grid/event-args.ts`.
import 'package:flutter/widgets.dart';

import 'semi_types.dart';

/// The `kind` discriminators used by `GridMouseEventArgs`
/// (`event-args.ts:86-90`): `"cell" | "header" | "group-header" |
/// "out-of-bounds"`.
enum SemiGridCellKind {
  cell('cell'),
  header('header'),
  groupHeader('group-header'),
  outOfBounds('out-of-bounds');

  const SemiGridCellKind(this.value);
  final String value;
}

/// `BaseGridMouseEventArgs` (`event-args.ts:4-15`).
@immutable
class SemiBaseGridMouseArgs {
  const SemiBaseGridMouseArgs({
    required this.shiftKey,
    required this.ctrlKey,
    required this.metaKey,
    required this.isTouch,
    this.isLongTouch,
    this.isDoubleClick,
    required this.isEdge,
    required this.button,
    required this.buttons,
    required this.scrollEdge,
  });

  final bool shiftKey;
  final bool ctrlKey;
  final bool metaKey;
  final bool isTouch;
  final bool? isLongTouch;
  final bool? isDoubleClick;
  final bool isEdge;
  final int button;
  final int buttons;

  /// `[xDir, yDir]` where each is `-1 | 0 | 1`.
  final (int, int) scrollEdge;
}

/// `PositionableMouseEventArgs` (`event-args.ts:17-20`).
mixin SemiPositionableMouseArgs {
  double get localEventX;
  double get localEventY;
}

/// `GridMouseCellEventArgs` (`event-args.ts:23-28`).
@immutable
class SemiGridCellMouseArgs extends SemiGridMouseArgs {
  const SemiGridCellMouseArgs({
    required super.shiftKey,
    required super.ctrlKey,
    required super.metaKey,
    required super.isTouch,
    super.isLongTouch,
    super.isDoubleClick,
    required super.isEdge,
    required super.button,
    required super.buttons,
    required super.scrollEdge,
    required this.location,
    required this.bounds,
    required this.isFillHandle,
    required this.localEventX,
    required this.localEventY,
  });

  @override
  SemiGridCellKind get kind => SemiGridCellKind.cell;

  final SemiItem location;
  final SemiRectangle bounds;
  final bool isFillHandle;
  final double localEventX;
  final double localEventY;
}

/// `GridMouseHeaderEventArgs` (`event-args.ts:33-38`).
@immutable
class SemiGridHeaderMouseArgs extends SemiGridMouseArgs {
  const SemiGridHeaderMouseArgs({
    required super.shiftKey,
    required super.ctrlKey,
    required super.metaKey,
    required super.isTouch,
    super.isLongTouch,
    super.isDoubleClick,
    required super.isEdge,
    required super.button,
    required super.buttons,
    required super.scrollEdge,
    required this.location,
    required this.bounds,
    required this.group,
    required this.localEventX,
    required this.localEventY,
  });

  @override
  SemiGridCellKind get kind => SemiGridCellKind.header;

  final SemiItem location;
  final SemiRectangle bounds;
  final String group;
  final double localEventX;
  final double localEventY;
}

/// `GridMouseGroupHeaderEventArgs` (`event-args.ts:43-48`).
@immutable
class SemiGridGroupHeaderMouseArgs extends SemiGridMouseArgs {
  const SemiGridGroupHeaderMouseArgs({
    required super.shiftKey,
    required super.ctrlKey,
    required super.metaKey,
    required super.isTouch,
    super.isLongTouch,
    super.isDoubleClick,
    required super.isEdge,
    required super.button,
    required super.buttons,
    required super.scrollEdge,
    required this.location,
    required this.bounds,
    required this.group,
    required this.localEventX,
    required this.localEventY,
  });

  @override
  SemiGridCellKind get kind => SemiGridCellKind.groupHeader;

  final SemiItem location;
  final SemiRectangle bounds;
  final String group;
  final double localEventX;
  final double localEventY;
}

/// `OutOfBoundsRegionAxis` (`event-args.ts:54-60`).
enum SemiOutOfBoundsRegionAxis {
  start(-2),
  startPadding(-1),
  center(0),
  endPadding(1),
  end(2);

  const SemiOutOfBoundsRegionAxis(this.value);
  final int value;
}

/// `GridMouseOutOfBoundsEventArgs` (`event-args.ts:62-67`).
@immutable
class SemiGridOutOfBoundsMouseArgs extends SemiGridMouseArgs {
  const SemiGridOutOfBoundsMouseArgs({
    required super.shiftKey,
    required super.ctrlKey,
    required super.metaKey,
    required super.isTouch,
    super.isLongTouch,
    super.isDoubleClick,
    required super.isEdge,
    required super.button,
    required super.buttons,
    required super.scrollEdge,
    required this.location,
    required this.isMaybeScrollbar,
    required this.region,
  });

  @override
  SemiGridCellKind get kind => SemiGridCellKind.outOfBounds;

  final SemiItem location;
  final bool isMaybeScrollbar;
  final (SemiOutOfBoundsRegionAxis, SemiOutOfBoundsRegionAxis) region;
}

/// `GridMouseEventArgs` (`event-args.ts:86-90`).
sealed class SemiGridMouseArgs extends SemiBaseGridMouseArgs {
  const SemiGridMouseArgs({
    required super.shiftKey,
    required super.ctrlKey,
    required super.metaKey,
    required super.isTouch,
    super.isLongTouch,
    super.isDoubleClick,
    required super.isEdge,
    required super.button,
    required super.buttons,
    required super.scrollEdge,
  });

  SemiGridCellKind get kind;
}

/// `mouseEventArgsAreEqual` (`event-args.ts:139-157`).
bool semiMouseArgsAreEqual(SemiGridMouseArgs? a, SemiGridMouseArgs? b) {
  if (identical(a, b)) return true;

  final left = a;
  final right = b;

  if (left is SemiGridOutOfBoundsMouseArgs) {
    if (right is! SemiGridOutOfBoundsMouseArgs) return false;
    return left.location == right.location && left.region == right.region;
  }
  if (right is SemiGridOutOfBoundsMouseArgs) return false;

  final leftLocation = _locationOf(left);
  final rightLocation = _locationOf(right);
  if (left == null || right == null) return left == null && right == null;
  if (left.kind != right.kind) return false;
  if (leftLocation == null || rightLocation == null) {
    return leftLocation == null && rightLocation == null;
  }
  return leftLocation.col == rightLocation.col &&
      leftLocation.row == rightLocation.row;
}

SemiItem? _locationOf(SemiGridMouseArgs? args) => switch (args) {
  SemiGridCellMouseArgs value => value.location,
  SemiGridHeaderMouseArgs value => value.location,
  SemiGridGroupHeaderMouseArgs value => value.location,
  _ => null,
};

/// `CellActivatedEventArgs` (`event-args.ts:104-121`): how a cell was
/// activated.
sealed class SemiCellActivation {
  const SemiCellActivation();
}

/// `KeyboardCellActivatedEvent` (`event-args.ts:107-111`).
class SemiKeyboardCellActivation extends SemiCellActivation {
  const SemiKeyboardCellActivation(this.key);

  /// The key that started the edit, or `null` for Enter-driven activation.
  final String? key;
}

/// `PointerCellActivatedEvent` (`event-args.ts:114-117`).
class SemiPointerCellActivation extends SemiCellActivation {
  const SemiPointerCellActivation(this.pointerActivation, {this.pointerType});

  final SemiCellActivationBehavior pointerActivation;
  final String? pointerType;
}

/// `HeaderClickedEventArgs` (`event-args.ts:99`).
@immutable
class SemiHeaderClickedEventArgs {
  const SemiHeaderClickedEventArgs({
    required this.col,
    required this.args,
    required this.preventDefault,
  });

  /// The column index with the row-marker offset removed.
  final int col;
  final SemiGridHeaderMouseArgs args;
  final void Function() preventDefault;
}

/// `GroupHeaderClickedEventArgs` (`event-args.ts:102`).
@immutable
class SemiGroupHeaderClickedEventArgs {
  const SemiGroupHeaderClickedEventArgs({
    required this.col,
    required this.args,
    required this.preventDefault,
  });

  /// The column index with the row-marker offset removed.
  final int col;
  final SemiGridGroupHeaderMouseArgs args;
  final void Function() preventDefault;
}

/// `GridKeyEventArgs` (`event-args.ts:70-83`). `rawEvent` is a Flutter
/// `KeyEvent` instead of a DOM event.
@immutable
class SemiGridKeyArgs {
  const SemiGridKeyArgs({
    required this.bounds,
    required this.key,
    required this.keyCode,
    required this.altKey,
    required this.shiftKey,
    required this.ctrlKey,
    required this.metaKey,
    required this.cancel,
    required this.stopPropagation,
    required this.preventDefault,
    required this.location,
    this.rawEvent,
  });

  final SemiRectangle? bounds;
  final String key;
  final int keyCode;
  final bool altKey;
  final bool shiftKey;
  final bool ctrlKey;
  final bool metaKey;
  final void Function() cancel;
  final void Function() stopPropagation;
  final void Function() preventDefault;
  final KeyEvent? rawEvent;
  final SemiItem? location;
}

/// `CellClickedEventArgs` (`event-args.ts:96`).
@immutable
class SemiCellClickedEventArgs extends SemiGridCellMouseArgs {
  const SemiCellClickedEventArgs({
    required super.shiftKey,
    required super.ctrlKey,
    required super.metaKey,
    required super.isTouch,
    super.isLongTouch,
    super.isDoubleClick,
    required super.isEdge,
    required super.button,
    required super.buttons,
    required super.scrollEdge,
    required super.location,
    required super.bounds,
    required super.isFillHandle,
    required super.localEventX,
    required super.localEventY,
    required this.preventDefault,
  });

  final void Function() preventDefault;
}
