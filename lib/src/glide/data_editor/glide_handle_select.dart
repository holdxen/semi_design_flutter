// Port of the `handleSelect` callback in
// `packages/core/src/data-editor/data-editor.tsx:1838-2087`.
//
// The row-marker and trailing-blank-row branches (`:1853-1914`) are left
// out: they depend on `rowMarkers`/`showTrailingBlankRow`, which are
// `data-editor` chrome layered on top of the grid. Everything else — cell
// range selection, header column selection, group headers and out-of-bounds
// clearing — is ported line by line.
import 'package:flutter/foundation.dart';

import '../cells/glide_cell_types.dart';
import '../internal/data_grid/glide_event_args.dart';
import '../internal/data_grid/glide_selection_behavior.dart';

/// What a `handleSelect` call asked the owner to do after mutating the
/// selection.
@immutable
class GlideSelectOutcome {
  const GlideSelectOutcome({
    this.clearOverlay = false,
    this.focus = false,
    this.prevented = false,
    this.onSelectionCleared = false,
  });

  final bool clearOverlay;
  final bool focus;

  /// A renderer's `onSelect` called `preventDefault`; the selection must not
  /// move (`data-editor.tsx:1931`).
  final bool prevented;

  final bool onSelectionCleared;
}

/// The `data-editor` knobs `handleSelect` reads.
@immutable
class GlideBehaviorConfig {
  const GlideBehaviorConfig({
    this.rangeBehavior = GlideSelectionBlending.exclusive,
    this.columnBehavior = GlideSelectionBlending.exclusive,
    this.rowBehavior = GlideSelectionBlending.exclusive,
    this.rangeSelect = GlideRangeSelect.multiRect,
    this.rangeSelectionColumnSpanning = true,
    this.columnSelectEnabled = true,
    this.columnSelectionModeMulti = false,
  });

  final GlideSelectionBlending rangeBehavior;
  final GlideSelectionBlending columnBehavior;
  final GlideSelectionBlending rowBehavior;
  final GlideRangeSelect rangeSelect;
  final bool rangeSelectionColumnSpanning;

  /// `columnSelect !== "none"` (`data-editor.tsx:2036`).
  final bool columnSelectEnabled;

  /// `columnSelectionMode === "multi"` (`data-editor.tsx:2019`).
  final bool columnSelectionModeMulti;
}

/// Holds the selection plus the `lastSelectedCol`/`lastSelectedRow` refs the
/// header shift-click path needs (`data-editor.tsx:1885`, `:2009`).
class GlideDataEditorSelection {
  GlideDataEditorSelection({
    required this.behaviorConfig,
    required this.rows,
    required this.rowSelectMulti,
    required this.columnSelectMulti,
    this.rowMarkerOffset = 0,
    this.hasRowMarkers = false,
    this.rowMarkersAreNumbers = false,
    this.rowSelectEnabled = true,
    this.rowSelectionModeMulti = false,
    this.rowDragEnabled = false,
    this.headerRowMarkerDisabled = false,
    this.showTrailingBlankRow = false,
    this.userRows = 0,
    this.appendRow,
    this.getCustomNewRowTargetColumn,
    GlideGridSelection initial = GlideGridSelection.empty,
  }) : selection = initial;

  final GlideBehaviorConfig behaviorConfig;
  final int rows;
  final bool rowSelectMulti;
  final bool columnSelectMulti;
  final int rowMarkerOffset;

  /// `rowMarkers !== "none"` (`data-editor.tsx:953`); enables the marker
  /// branch of `handleSelect`.
  final bool hasRowMarkers;

  /// `rowMarkers === "number"` — numbers are not clickable
  /// (`data-editor.tsx:1856`).
  final bool rowMarkersAreNumbers;

  /// `rowSelect !== "none"` (`data-editor.tsx:1857`).
  final bool rowSelectEnabled;

  /// `rowSelectionMode === "multi"` (`data-editor.tsx:1894`).
  final bool rowSelectionModeMulti;

  /// `onRowMoved !== undefined` (`data-editor.tsx:1866`): the checkbox also
  /// acts as the drag handle's hit test.
  final bool rowDragEnabled;

  /// `headerRowMarkerDisabled` (`data-editor.tsx:919`).
  final bool headerRowMarkerDisabled;

  /// `showTrailingBlankRow` (`data-editor.tsx:955`).
  final bool showTrailingBlankRow;

  /// The user row count; the trailing row sits at index `userRows`.
  final int userRows;

  /// `appendRow` (`data-editor.tsx:1687`).
  final void Function(int col)? appendRow;

  /// `getCustomNewRowTargetColumn` (`data-editor.tsx:1795`).
  final int? Function(int col)? getCustomNewRowTargetColumn;

  GlideGridSelection selection;
  int? lastSelectedCol;
  int? lastSelectedRow;

  GlideSelectionBehavior createBehavior() => GlideSelectionBehavior(
    gridSelection: selection,
    setGridSelection: (newVal, expand) => selection = newVal,
    rangeBehavior: behaviorConfig.rangeBehavior,
    columnBehavior: behaviorConfig.columnBehavior,
    rowBehavior: behaviorConfig.rowBehavior,
    rangeSelect: behaviorConfig.rangeSelect,
    rangeSelectionColumnSpanning: behaviorConfig.rangeSelectionColumnSpanning,
  );

  /// `handleSelect` (`data-editor.tsx:1838-2087`).
  GlideSelectOutcome handleSelect(
    GlideGridMouseArgs args, {
    required GlideGetCellRenderer getCellRenderer,
    required GlideGridCell Function(GlideItem location) getCellContent,
    required GlideTheme Function(GlideGridCell cell, GlideItem location)
    themeForCell,
  }) {
    final isMultiKey = defaultTargetPlatform == TargetPlatform.macOS
        ? args.metaKey
        : args.ctrlKey;
    final behavior = createBehavior();

    final (col, row) = switch (args) {
      GlideGridCellMouseArgs a => (a.location.col, a.location.row),
      GlideGridHeaderMouseArgs a => (a.location.col, a.location.row),
      GlideGridGroupHeaderMouseArgs a => (a.location.col, a.location.row),
      GlideGridOutOfBoundsMouseArgs a => (a.location.col, a.location.row),
    };

    final selectedColumns = selection.columns;
    final selectedRows = selection.rows;
    final cellCol = selection.current?.cell.col;
    final cellRow = selection.current?.cell.row;

    switch (args.kind) {
      case GlideGridCellKind.cell:
        lastSelectedCol = null;

        // `col === 0 && hasRowMarkers` (`data-editor.tsx:1853-1911`).
        if (hasRowMarkers && col == 0) {
          if (rowMarkersAreNumbers || !rowSelectEnabled) break;

          final cellArgs = args as GlideGridCellMouseArgs;
          final markerCell = getCellContent(cellArgs.location);
          if (markerCell is! GlideMarkerCell) break;

          // With row dragging enabled the checkbox doubles as the drag
          // handle's hit test (`data-editor.tsx:1866-1879`).
          if (rowDragEnabled) {
            final bounds = cellArgs.bounds;
            final centerX = markerCell.drawHandle
                ? 7 + (bounds.width - 7) / 2
                : bounds.width / 2;
            final centerY = bounds.height / 2;
            final localX = cellArgs.localEventX - bounds.x;
            final localY = cellArgs.localEventY - bounds.y;
            final onCheckbox = (localX - centerX).abs() <= 10 &&
                (localY - centerY).abs() <= 10;
            if (!onCheckbox) break;
          }

          final isSelected = selectedRows.hasIndex(row);
          final lastHighlighted = lastSelectedRow;

          if (rowSelectMulti &&
              (cellArgs.shiftKey || cellArgs.isLongTouch == true) &&
              lastHighlighted != null &&
              selectedRows.hasIndex(lastHighlighted)) {
            final newSlice = GlideSlice(
              lastHighlighted < row ? lastHighlighted : row,
              (lastHighlighted > row ? lastHighlighted : row) + 1,
            );
            if (isMultiKey || cellArgs.isTouch || rowSelectionModeMulti) {
              behavior.setSelectedRows(
                newRows: null,
                append: newSlice,
                allowMixed: true,
              );
            } else {
              behavior.setSelectedRows(
                newRows: GlideCompactSelection.fromSingleSelection(newSlice),
                append: null,
                allowMixed: isMultiKey,
              );
            }
          } else if (rowSelectMulti &&
              (isMultiKey ||
                  cellArgs.isTouch ||
                  rowSelectionModeMulti)) {
            if (isSelected) {
              behavior.setSelectedRows(
                newRows: selectedRows.remove(row),
                append: null,
                allowMixed: true,
              );
            } else {
              behavior.setSelectedRows(
                newRows: null,
                append: row,
                allowMixed: true,
              );
              lastSelectedRow = row;
            }
          } else if (isSelected && selectedRows.length == 1) {
            behavior.setSelectedRows(
              newRows: const GlideCompactSelection.empty(),
              append: null,
              allowMixed: isMultiKey,
            );
          } else {
            behavior.setSelectedRows(
              newRows: GlideCompactSelection.fromSingleSelection(row),
              append: null,
              allowMixed: isMultiKey,
            );
            lastSelectedRow = row;
          }
          return const GlideSelectOutcome(clearOverlay: true, focus: true);
        }

        // `col >= rowMarkerOffset && showTrailingBlankRow && row === rows`
        // (`data-editor.tsx:1912-1915`).
        if (showTrailingBlankRow && row == userRows && col >= rowMarkerOffset) {
          final custom = getCustomNewRowTargetColumn?.call(col);
          appendRow?.call(custom ?? col);
          return const GlideSelectOutcome(clearOverlay: true, focus: true);
        }

        if (col < rowMarkerOffset) break;
        if (cellCol == col && cellRow == row) break;

        final cell = getCellContent(GlideItem(col, row));
        final renderer = getCellRenderer(cell);

        var prevented = false;
        renderer?.onSelect(
          GlideCellEventArgs(
            cell: cell,
            posX: (args as GlideGridCellMouseArgs).localEventX,
            posY: args.localEventY,
            bounds: args.bounds,
            location: args.location,
            theme: themeForCell(cell, args.location),
            preventDefault: () => prevented = true,
            isTouch: args.isTouch,
            isLongTouch: args.isLongTouch ?? false,
            shiftKey: args.shiftKey,
            ctrlKey: args.ctrlKey,
            metaKey: args.metaKey,
          ),
        );
        if (prevented) return const GlideSelectOutcome(prevented: true);

        if ((args.shiftKey || args.isLongTouch == true) &&
            cellCol != null &&
            cellRow != null &&
            selection.current != null) {
          final left = col < cellCol ? col : cellCol;
          final right = col > cellCol ? col : cellCol;
          final top = row < cellRow ? row : cellRow;
          final bottom = row > cellRow ? row : cellRow;
          behavior.setCurrent(
            value: (
              cell: selection.current!.cell,
              range: GlideRectangle(
                x: left.toDouble(),
                y: top.toDouble(),
                width: (right - left + 1).toDouble(),
                height: (bottom - top + 1).toDouble(),
              ),
            ),
            expand: true,
            append: isMultiKey,
            trigger: GlideSelectionTrigger.click,
          );
          lastSelectedRow = null;
          return const GlideSelectOutcome(focus: true);
        }

        behavior.setCurrent(
          value: (
            cell: GlideItem(col, row),
            range: GlideRectangle(
              x: col.toDouble(),
              y: row.toDouble(),
              width: 1,
              height: 1,
            ),
          ),
          expand: true,
          append: isMultiKey,
          trigger: GlideSelectionTrigger.click,
        );
        lastSelectedRow = null;
        return const GlideSelectOutcome(clearOverlay: true, focus: true);

      case GlideGridCellKind.header:
        // The marker header selects (or clears) every row
        // (`data-editor.tsx:1997-2007`).
        if (hasRowMarkers && col == 0) {
          lastSelectedRow = null;
          lastSelectedCol = null;
          if (!headerRowMarkerDisabled && rowSelectMulti) {
            if (selectedRows.length != rows) {
              behavior.setSelectedRows(
                newRows: GlideCompactSelection.fromSingleSelection(
                  GlideSlice(0, rows),
                ),
                append: null,
                allowMixed: isMultiKey,
              );
            } else {
              behavior.setSelectedRows(
                newRows: const GlideCompactSelection.empty(),
                append: null,
                allowMixed: isMultiKey,
              );
            }
          }
          return const GlideSelectOutcome(clearOverlay: true, focus: true);
        }

        final lastCol = lastSelectedCol;
        if (columnSelectMulti &&
            (args.shiftKey || args.isLongTouch == true) &&
            lastCol != null &&
            selectedColumns.hasIndex(lastCol)) {
          // Support for selecting a slice of columns:
          final newSlice = GlideSlice(
            lastCol < col ? lastCol : col,
            (lastCol > col ? lastCol : col) + 1,
          );

          if (isMultiKey ||
              args.isTouch ||
              behaviorConfig.columnSelectionModeMulti) {
            behavior.setSelectedColumns(
              newCols: null,
              append: newSlice,
              allowMixed: isMultiKey,
            );
          } else {
            behavior.setSelectedColumns(
              newCols: GlideCompactSelection.fromSingleSelection(newSlice),
              append: null,
              allowMixed: isMultiKey,
            );
          }
        } else if (columnSelectMulti &&
            (isMultiKey ||
                args.isTouch ||
                behaviorConfig.columnSelectionModeMulti)) {
          // Support for selecting a single column additively:
          if (selectedColumns.hasIndex(col)) {
            behavior.setSelectedColumns(
              newCols: selectedColumns.remove(col),
              append: null,
              allowMixed: isMultiKey,
            );
          } else {
            behavior.setSelectedColumns(
              newCols: null,
              append: col,
              allowMixed: isMultiKey,
            );
          }
          lastSelectedCol = col;
        } else if (behaviorConfig.columnSelectEnabled) {
          if (selectedColumns.hasIndex(col)) {
            behavior.setSelectedColumns(
              newCols: selectedColumns.remove(col),
              append: null,
              allowMixed: isMultiKey,
            );
          } else {
            behavior.setSelectedColumns(
              newCols: GlideCompactSelection.fromSingleSelection(col),
              append: null,
              allowMixed: isMultiKey,
            );
          }
          lastSelectedCol = col;
        }
        lastSelectedRow = null;
        return const GlideSelectOutcome(clearOverlay: true, focus: true);

      case GlideGridCellKind.groupHeader:
        // `handleGroupHeaderSelection` (`:2140-2189`) runs separately; the
        // click itself only records the location.
        return const GlideSelectOutcome();

      case GlideGridCellKind.outOfBounds:
        final out = args as GlideGridOutOfBoundsMouseArgs;
        if (!out.isMaybeScrollbar) {
          selection = GlideGridSelection.empty;
          lastSelectedRow = null;
          lastSelectedCol = null;
          return const GlideSelectOutcome(
            clearOverlay: true,
            focus: true,
            onSelectionCleared: true,
          );
        }
        return const GlideSelectOutcome();
    }

    // Reached when a cell click did not change anything (`cellCol == col`).
    return const GlideSelectOutcome();
  }

  /// `handleGroupHeaderSelection` (`data-editor.tsx:2140-2189`), reduced to
  /// the group-span computation; the `mangledCols`/row-marker pieces are not
  /// ported.
  GlideSelectOutcome handleGroupHeaderSelection(
    GlideGridGroupHeaderMouseArgs args, {
    required List<GlideGridColumn> columns,
    required int rowMarkerOffset,
  }) {
    if (!columnSelectMulti) return const GlideSelectOutcome();

    final isMultiKey = defaultTargetPlatform == TargetPlatform.macOS
        ? args.metaKey
        : args.ctrlKey;
    final col = args.location.col;
    final behavior = createBehavior();
    final selectedColumns = selection.columns;

    if (col < rowMarkerOffset) return const GlideSelectOutcome();

    final needle = columns[col];
    var start = col;
    var end = col;
    for (var i = col - 1; i >= rowMarkerOffset; i--) {
      if (!isGroupEqual(needle.group, columns[i].group)) break;
      start--;
    }
    for (var i = col + 1; i < columns.length; i++) {
      if (!isGroupEqual(needle.group, columns[i].group)) break;
      end++;
    }

    if (isMultiKey ||
        args.isTouch ||
        behaviorConfig.columnSelectionModeMulti) {
      if (selectedColumns.hasAll(GlideSlice(start, end + 1))) {
        var newVal = selectedColumns;
        for (var index = start; index <= end; index++) {
          newVal = newVal.remove(index);
        }
        behavior.setSelectedColumns(
          newCols: newVal,
          append: null,
          allowMixed: isMultiKey,
        );
      } else {
        behavior.setSelectedColumns(
          newCols: null,
          append: GlideSlice(start, end + 1),
          allowMixed: isMultiKey,
        );
      }
    } else {
      behavior.setSelectedColumns(
        newCols: GlideCompactSelection.fromSingleSelection(
          GlideSlice(start, end + 1),
        ),
        append: null,
        allowMixed: isMultiKey,
      );
    }
    return const GlideSelectOutcome(focus: true);
  }
}
