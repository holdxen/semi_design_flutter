// Port of `packages/core/src/internal/data-grid/event-args.ts`.
import 'package:flutter/widgets.dart';

import 'glide_types.dart';

/// The `kind` discriminators used by `GridMouseEventArgs`
/// (`event-args.ts:86-90`): `"cell" | "header" | "group-header" |
/// "out-of-bounds"`.
enum GlideGridCellKind {
  cell('cell'),
  header('header'),
  groupHeader('group-header'),
  outOfBounds('out-of-bounds');

  const GlideGridCellKind(this.value);
  final String value;
}

/// `BaseGridMouseEventArgs` (`event-args.ts:4-15`).
@immutable
class GlideBaseGridMouseArgs {
  const GlideBaseGridMouseArgs({
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
mixin GlidePositionableMouseArgs {
  double get localEventX;
  double get localEventY;
}

/// `GridMouseCellEventArgs` (`event-args.ts:23-28`).
@immutable
class GlideGridCellMouseArgs extends GlideGridMouseArgs {
  const GlideGridCellMouseArgs({
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
  GlideGridCellKind get kind => GlideGridCellKind.cell;

  final GlideItem location;
  final GlideRectangle bounds;
  final bool isFillHandle;
  final double localEventX;
  final double localEventY;
}

/// `GridMouseHeaderEventArgs` (`event-args.ts:33-38`).
@immutable
class GlideGridHeaderMouseArgs extends GlideGridMouseArgs {
  const GlideGridHeaderMouseArgs({
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
  GlideGridCellKind get kind => GlideGridCellKind.header;

  final GlideItem location;
  final GlideRectangle bounds;
  final String group;
  final double localEventX;
  final double localEventY;
}

/// `GridMouseGroupHeaderEventArgs` (`event-args.ts:43-48`).
@immutable
class GlideGridGroupHeaderMouseArgs extends GlideGridMouseArgs {
  const GlideGridGroupHeaderMouseArgs({
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
  GlideGridCellKind get kind => GlideGridCellKind.groupHeader;

  final GlideItem location;
  final GlideRectangle bounds;
  final String group;
  final double localEventX;
  final double localEventY;
}

/// `OutOfBoundsRegionAxis` (`event-args.ts:54-60`).
enum GlideOutOfBoundsRegionAxis {
  start(-2),
  startPadding(-1),
  center(0),
  endPadding(1),
  end(2);

  const GlideOutOfBoundsRegionAxis(this.value);
  final int value;
}

/// `GridMouseOutOfBoundsEventArgs` (`event-args.ts:62-67`).
@immutable
class GlideGridOutOfBoundsMouseArgs extends GlideGridMouseArgs {
  const GlideGridOutOfBoundsMouseArgs({
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
  GlideGridCellKind get kind => GlideGridCellKind.outOfBounds;

  final GlideItem location;
  final bool isMaybeScrollbar;
  final (GlideOutOfBoundsRegionAxis, GlideOutOfBoundsRegionAxis) region;
}

/// `GridMouseEventArgs` (`event-args.ts:86-90`).
sealed class GlideGridMouseArgs extends GlideBaseGridMouseArgs {
  const GlideGridMouseArgs({
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

  GlideGridCellKind get kind;
}

/// `mouseEventArgsAreEqual` (`event-args.ts:139-157`).
bool glideMouseArgsAreEqual(GlideGridMouseArgs? a, GlideGridMouseArgs? b) {
  if (identical(a, b)) return true;

  final left = a;
  final right = b;

  if (left is GlideGridOutOfBoundsMouseArgs) {
    if (right is! GlideGridOutOfBoundsMouseArgs) return false;
    return left.location == right.location && left.region == right.region;
  }
  if (right is GlideGridOutOfBoundsMouseArgs) return false;

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

GlideItem? _locationOf(GlideGridMouseArgs? args) => switch (args) {
  GlideGridCellMouseArgs value => value.location,
  GlideGridHeaderMouseArgs value => value.location,
  GlideGridGroupHeaderMouseArgs value => value.location,
  _ => null,
};

/// `GridKeyEventArgs` (`event-args.ts:70-83`). `rawEvent` is a Flutter
/// `KeyEvent` instead of a DOM event.
@immutable
class GlideGridKeyArgs {
  const GlideGridKeyArgs({
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

  final GlideRectangle? bounds;
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
  final GlideItem? location;
}

/// `CellClickedEventArgs` (`event-args.ts:96`).
@immutable
class GlideCellClickedEventArgs extends GlideGridCellMouseArgs {
  const GlideCellClickedEventArgs({
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
