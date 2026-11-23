// Port of `packages/core/src/internal/data-grid/use-selection-behavior.ts`.
//
// The upstream file is a React hook over three `useCallback`s; the callbacks
// only capture `gridSelection` and the blending config, so this is a plain
// class the editor re-instantiates whenever the selection changes.
import 'semi_types.dart';

/// `SelectionBlending` (`use-selection-behavior.ts:12`).
enum SemiSelectionBlending {
  /// Only one type of selection can be made at a time.
  exclusive,

  /// Multiple types can be made at once, but only with a multi-key held.
  mixed,

  /// Multiple types can be made at once and accumulate without a modifier.
  additive,
}

/// `SelectionTrigger` (`use-selection-behavior.ts:14`).
enum SemiSelectionTrigger { click, drag, keyboardNav, keyboardSelect, edit }

/// `rangeSelect` (`use-selection-behavior.ts:22`).
enum SemiRangeSelect { none, cell, rect, multiCell, multiRect }

/// `SetCallback` (`use-selection-behavior.ts:4`).
typedef SemiSetSelectionCallback =
    void Function(SemiGridSelection newVal, bool expand);

class SemiSelectionBehavior {
  SemiSelectionBehavior({
    required this.gridSelection,
    required this.setGridSelection,
    required this.rangeBehavior,
    required this.columnBehavior,
    required this.rowBehavior,
    required this.rangeSelect,
    required this.rangeSelectionColumnSpanning,
  });

  final SemiGridSelection gridSelection;
  final SemiSetSelectionCallback setGridSelection;
  final SemiSelectionBlending rangeBehavior;
  final SemiSelectionBlending columnBehavior;
  final SemiSelectionBlending rowBehavior;
  final SemiRangeSelect rangeSelect;
  final bool rangeSelectionColumnSpanning;

  /// `setCurrent` (`use-selection-behavior.ts:26-93`).
  ///
  /// `value == null` clears the current range.
  void setCurrent({
    required ({SemiItem cell, SemiRectangle range})? value,
    required bool expand,
    required bool append,
    required SemiSelectionTrigger trigger,
  }) {
    var v = value;

    if ((rangeSelect == SemiRangeSelect.cell ||
            rangeSelect == SemiRangeSelect.multiCell) &&
        v != null) {
      v = (
        cell: v.cell,
        range: SemiRectangle(
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
        range: SemiRectangle(
          x: v.cell.col.toDouble(),
          y: v.range.y,
          width: 1,
          height: v.range.height,
        ),
      );
    }

    final rangeMixable =
        (rangeBehavior == SemiSelectionBlending.mixed &&
            (append || trigger == SemiSelectionTrigger.drag)) ||
        rangeBehavior == SemiSelectionBlending.additive;
    final allowColumnCoSelect =
        (columnBehavior == SemiSelectionBlending.mixed ||
            columnBehavior == SemiSelectionBlending.additive) &&
        rangeMixable;
    final allowRowCoSelect =
        (rowBehavior == SemiSelectionBlending.mixed ||
            rowBehavior == SemiSelectionBlending.additive) &&
        rangeMixable;

    var newVal = SemiGridSelection(
      current: v == null
          ? null
          : SemiGridSelectionCurrent(
              cell: v.cell,
              range: v.range,
              rangeStack: trigger == SemiSelectionTrigger.drag
                  ? (gridSelection.current?.rangeStack ?? const [])
                  : const [],
            ),
      columns: allowColumnCoSelect
          ? gridSelection.columns
          : const SemiCompactSelection.empty(),
      rows: allowRowCoSelect
          ? gridSelection.rows
          : const SemiCompactSelection.empty(),
    );

    final addLastRange =
        append &&
        (rangeSelect == SemiRangeSelect.multiRect ||
            rangeSelect == SemiRangeSelect.multiCell);
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
    required SemiCompactSelection? newRows,
    required Object? append,
    required bool allowMixed,
  }) {
    var rows = newRows ?? gridSelection.rows;
    if (append != null) rows = rows.add(append);

    final SemiGridSelection newVal;
    if (rowBehavior == SemiSelectionBlending.exclusive &&
        rows.length > 0) {
      newVal = SemiGridSelection(
        current: null,
        columns: const SemiCompactSelection.empty(),
        rows: rows,
      );
    } else {
      final rangeMixed =
          (allowMixed &&
              rangeBehavior == SemiSelectionBlending.mixed) ||
          rangeBehavior == SemiSelectionBlending.additive;
      final columnMixed =
          (allowMixed &&
              columnBehavior == SemiSelectionBlending.mixed) ||
          columnBehavior == SemiSelectionBlending.additive;
      newVal = SemiGridSelection(
        current: !rangeMixed ? null : gridSelection.current,
        columns: columnMixed
            ? gridSelection.columns
            : const SemiCompactSelection.empty(),
        rows: rows,
      );
    }
    setGridSelection(newVal, false);
  }

  /// `setSelectedColumns` (`use-selection-behavior.ts:123-149`).
  void setSelectedColumns({
    required SemiCompactSelection? newCols,
    required Object? append,
    required bool allowMixed,
  }) {
    var cols = newCols ?? gridSelection.columns;
    if (append != null) cols = cols.add(append);

    final SemiGridSelection newVal;
    if (columnBehavior == SemiSelectionBlending.exclusive &&
        cols.length > 0) {
      newVal = SemiGridSelection(
        current: null,
        rows: const SemiCompactSelection.empty(),
        columns: cols,
      );
    } else {
      final rangeMixed =
          (allowMixed &&
              rangeBehavior == SemiSelectionBlending.mixed) ||
          rangeBehavior == SemiSelectionBlending.additive;
      final rowMixed =
          (allowMixed && rowBehavior == SemiSelectionBlending.mixed) ||
          rowBehavior == SemiSelectionBlending.additive;
      newVal = SemiGridSelection(
        current: !rangeMixed ? null : gridSelection.current,
        rows: rowMixed
            ? gridSelection.rows
            : const SemiCompactSelection.empty(),
        columns: cols,
      );
    }
    setGridSelection(newVal, false);
  }
}
