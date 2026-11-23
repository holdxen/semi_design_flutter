// Port of `packages/core/src/data-editor/data-editor-fns.ts`
// (`expandSelection`, `shiftSelection`) plus the small helpers
// `getSpanStops` (`data-editor.tsx:168-176`) and the abort-signal-shaped
// `getCellsForSelection` callback type
// (`internal/data-grid-search/data-grid-search.ts`).
import '../internal/data_grid/semi_types.dart';

/// `getCellsForSelection` (`data-grid-search.ts`): returns the cells inside
/// `region`, or `null` when the caller is async (the Web API can return a
/// thunk; Flutter callers are expected to resolve it before calling in).
typedef SemiGetCellsForSelection = SemiCellArray? Function(
  SemiRectangle region,
);

/// `getSpanStops` (`data-editor.tsx:168-176`): every column index that is
/// covered by a span in [cells].
List<int> semiGetSpanStops(SemiCellArray cells) {
  final stops = <int>{};
  for (final row in cells) {
    for (final cell in row) {
      final span = cell.span;
      if (span == null) continue;
      for (var i = span.start + 1; i <= span.end + 1; i++) {
        stops.add(i);
      }
    }
  }
  return stops.toList()..sort();
}

/// `spanRangeBehavior` (`data-editor.tsx:368`): `"default"` grows the range
/// until it fully covers every span it touches, `"allowPartial"` leaves the
/// user's range alone.
///
/// Dart has no `default` identifier, so upstream's `"default"` is spelled
/// [SemiSpanRangeBehavior.standard].
enum SemiSpanRangeBehavior { standard, allowPartial }

/// `expandSelection` (`data-editor-fns.ts:5-98`).
///
/// Grows the current range until it fully covers the spans of the cells it
/// touches. `getCellsForSelection == null` and
/// [SemiSpanRangeBehavior.allowPartial] both short circuit to the input,
/// matching upstream (`data-editor-fns.ts:13`).
SemiGridSelection semiExpandSelection({
  required SemiGridSelection newVal,
  required SemiGetCellsForSelection? getCellsForSelection,
  required int rowMarkerOffset,
  required bool allowPartial,
}) {
  final origVal = newVal;
  if (allowPartial || newVal.current == null || getCellsForSelection == null) {
    return newVal;
  }

  var selection = newVal;
  var isFilled = false;
  while (!isFilled) {
    final current = selection.current;
    if (current == null) break;
    final r = current.range;
    final cells = <List<SemiGridCell>>[];

    if (r.width > 2) {
      final leftCells = getCellsForSelection(
        SemiRectangle(x: r.x, y: r.y, width: 1, height: r.height),
      );
      if (leftCells == null) return origVal;
      cells.addAll(leftCells);

      final rightCells = getCellsForSelection(
        SemiRectangle(
          x: r.x + r.width - 1,
          y: r.y,
          width: 1,
          height: r.height,
        ),
      );
      if (rightCells == null) return origVal;
      cells.addAll(rightCells);
    } else {
      final rCells = getCellsForSelection(r);
      if (rCells == null) return origVal;
      cells.addAll(rCells);
    }

    var left = r.x.toInt() - rowMarkerOffset;
    var right = r.x.toInt() + r.width.toInt() - 1 - rowMarkerOffset;
    for (final row in cells) {
      for (final cell in row) {
        final span = cell.span;
        if (span == null) continue;
        if (span.start < left) left = span.start;
        if (span.end > right) right = span.end;
      }
    }

    if (left == r.x.toInt() - rowMarkerOffset &&
        right == r.x.toInt() + r.width.toInt() - 1 - rowMarkerOffset) {
      isFilled = true;
    } else {
      selection = SemiGridSelection(
        current: SemiGridSelectionCurrent(
          cell: current.cell,
          range: SemiRectangle(
            x: (left + rowMarkerOffset).toDouble(),
            y: r.y,
            width: (right - left + 1).toDouble(),
            height: r.height,
          ),
          rangeStack: current.rangeStack,
        ),
        columns: selection.columns,
        rows: selection.rows,
      );
    }
  }
  return selection;
}

/// `shiftSelection` (`data-editor.tsx:178-200`): moves a selection by
/// `offset` columns. Used to convert between the grid's internal indexing
/// (which may include a row-marker column) and the public API's.
SemiGridSelection semiShiftSelection(
  SemiGridSelection input,
  int offset,
) {
  if (offset == 0 ||
      (input.columns.length == 0 && input.current == null)) {
    return input;
  }

  final current = input.current;
  return SemiGridSelection(
    current: current == null
        ? null
        : SemiGridSelectionCurrent(
            cell: SemiItem(current.cell.col + offset, current.cell.row),
            range: current.range.translate(offset.toDouble(), 0),
            rangeStack: [
              for (final r in current.rangeStack)
                r.translate(offset.toDouble(), 0),
            ],
          ),
    rows: input.rows,
    columns: input.columns.offset(offset),
  );
}
