// Port of `packages/core/src/internal/data-grid/use-selection-behavior.ts`.
//
// The upstream file is a React hook over three `useCallback`s; the callbacks
// only capture `gridSelection` and the blending config, so this is a plain
// class the editor re-instantiates whenever the selection changes.
import 'glide_types.dart';

/// `SelectionBlending` (`use-selection-behavior.ts:12`).
enum GlideSelectionBlending {
  /// Only one type of selection can be made at a time.
  exclusive,

  /// Multiple types can be made at once, but only with a multi-key held.
  mixed,

  /// Multiple types can be made at once and accumulate without a modifier.
  additive,
}

/// `SelectionTrigger` (`use-selection-behavior.ts:14`).
enum GlideSelectionTrigger { click, drag, keyboardNav, keyboardSelect, edit }

/// `rangeSelect` (`use-selection-behavior.ts:22`).
enum GlideRangeSelect { none, cell, rect, multiCell, multiRect }

/// `SetCallback` (`use-selection-behavior.ts:4`).
typedef GlideSetSelectionCallback =
    void Function(GlideGridSelection newVal, bool expand);

class GlideSelectionBehavior {
  GlideSelectionBehavior({
    required this.gridSelection,
    required this.setGridSelection,
    required this.rangeBehavior,
    required this.columnBehavior,
    required this.rowBehavior,
    required this.rangeSelect,
    required this.rangeSelectionColumnSpanning,
  });

  final GlideGridSelection gridSelection;
  final GlideSetSelectionCallback setGridSelection;
  final GlideSelectionBlending rangeBehavior;
  final GlideSelectionBlending columnBehavior;
  final GlideSelectionBlending rowBehavior;
  final GlideRangeSelect rangeSelect;
  final bool rangeSelectionColumnSpanning;

  /// `setCurrent` (`use-selection-behavior.ts:26-93`).
  ///
  /// `value == null` clears the current range.
  void setCurrent({
    required ({GlideItem cell, GlideRectangle range})? value,
    required bool expand,
    required bool append,
    required GlideSelectionTrigger trigger,
  }) {
    var v = value;

    if ((rangeSelect == GlideRangeSelect.cell ||
            rangeSelect == GlideRangeSelect.multiCell) &&
        v != null) {
      v = (
        cell: v.cell,
        range: GlideRectangle(
          x: v.cell.col.toDouble(),
          y: v.cell.row.toDouble(),
          width: 1,
          height: 1,
        ),
      );
    }

    if (!rangeSelectionColumnSpanning &&
        v != null &&
        v.range.width > 1) {
      v = (
        cell: v.cell,
        range: GlideRectangle(
          x: v.cell.col.toDouble(),
          y: v.range.y,
          width: 1,
          height: v.range.height,
        ),
      );
    }

    final rangeMixable =
        (rangeBehavior == GlideSelectionBlending.mixed &&
            (append || trigger == GlideSelectionTrigger.drag)) ||
        rangeBehavior == GlideSelectionBlending.additive;
    final allowColumnCoSelect =
        (columnBehavior == GlideSelectionBlending.mixed ||
            columnBehavior == GlideSelectionBlending.additive) &&
        rangeMixable;
    final allowRowCoSelect =
        (rowBehavior == GlideSelectionBlending.mixed ||
            rowBehavior == GlideSelectionBlending.additive) &&
        rangeMixable;

    var newVal = GlideGridSelection(
      current: v == null
          ? null
          : GlideGridSelectionCurrent(
              cell: v.cell,
              range: v.range,
              rangeStack: trigger == GlideSelectionTrigger.drag
                  ? (gridSelection.current?.rangeStack ?? const [])
                  : const [],
            ),
      columns: allowColumnCoSelect
          ? gridSelection.columns
          : const GlideCompactSelection.empty(),
      rows: allowRowCoSelect
          ? gridSelection.rows
          : const GlideCompactSelection.empty(),
    );

    final addLastRange =
        append &&
        (rangeSelect == GlideRangeSelect.multiRect ||
            rangeSelect == GlideRangeSelect.multiCell);
    if (addLastRange &&
        newVal.current != null &&
        gridSelection.current != null) {
      newVal = newVal.copyWith(
        current: newVal.current!.copyWith(
          rangeStack: [
            ...gridSelection.current!.rangeStack,
            gridSelection.current!.range,
          ],
        ),
      );
    }

    setGridSelection(newVal, expand);
  }

  /// `setSelectedRows` (`use-selection-behavior.ts:95-121`).
  void setSelectedRows({
    required GlideCompactSelection? newRows,
    required Object? append,
    required bool allowMixed,
  }) {
    var rows = newRows ?? gridSelection.rows;
    if (append != null) rows = rows.add(append);

    final GlideGridSelection newVal;
    if (rowBehavior == GlideSelectionBlending.exclusive &&
        rows.length > 0) {
      newVal = GlideGridSelection(
        current: null,
        columns: const GlideCompactSelection.empty(),
        rows: rows,
      );
    } else {
      final rangeMixed =
          (allowMixed &&
              rangeBehavior == GlideSelectionBlending.mixed) ||
          rangeBehavior == GlideSelectionBlending.additive;
      final columnMixed =
          (allowMixed &&
              columnBehavior == GlideSelectionBlending.mixed) ||
          columnBehavior == GlideSelectionBlending.additive;
      newVal = GlideGridSelection(
        current: !rangeMixed ? null : gridSelection.current,
        columns: columnMixed
            ? gridSelection.columns
            : const GlideCompactSelection.empty(),
        rows: rows,
      );
    }
    setGridSelection(newVal, false);
  }

  /// `setSelectedColumns` (`use-selection-behavior.ts:123-149`).
  void setSelectedColumns({
    required GlideCompactSelection? newCols,
    required Object? append,
    required bool allowMixed,
  }) {
    var cols = newCols ?? gridSelection.columns;
    if (append != null) cols = cols.add(append);

    final GlideGridSelection newVal;
    if (columnBehavior == GlideSelectionBlending.exclusive &&
        cols.length > 0) {
      newVal = GlideGridSelection(
        current: null,
        rows: const GlideCompactSelection.empty(),
        columns: cols,
      );
    } else {
      final rangeMixed =
          (allowMixed &&
              rangeBehavior == GlideSelectionBlending.mixed) ||
          rangeBehavior == GlideSelectionBlending.additive;
      final rowMixed =
          (allowMixed && rowBehavior == GlideSelectionBlending.mixed) ||
          rowBehavior == GlideSelectionBlending.additive;
      newVal = GlideGridSelection(
        current: !rangeMixed ? null : gridSelection.current,
        rows: rowMixed
            ? gridSelection.rows
            : const GlideCompactSelection.empty(),
        columns: cols,
      );
    }
    setGridSelection(newVal, false);
  }
}
