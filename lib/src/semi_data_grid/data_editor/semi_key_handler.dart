// Port of the keyboard half of
// `packages/core/src/data-editor/data-editor.tsx`:
// - `handleFixedKeybindings` (`:3188-3482`)
// - `updateSelectedCell` (`:3024-3082`)
// - `adjustSelection` (`:2854-3019`)
// - `deleteRange` (`:3148-3184`)
//
// Row-grouping navigation (`:3412-3441`), the trailing-blank-row append and
// `searchInputRef` focus are represented by optional callbacks so the caller
// can wire them when those features land.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../cells/semi_cell_types.dart';
import '../common/semi_is_hotkey.dart';
import '../internal/data_grid/semi_event_args.dart';
import '../common/semi_utils.dart';
import '../internal/data_grid/semi_selection_behavior.dart';
import 'semi_data_editor_fns.dart';
import 'semi_keybindings.dart';
import 'semi_row_grouping.dart';

/// `columnSelect` / `rowSelect` (`"none" | "single" | "multi"`) plus the
/// `rowSelectionMode` value `"auto"` (`data-editor.tsx:849`).
enum SemiSelectMode { none, single, multi, auto }

/// `scrollTo(col, row, axis?)`.
@immutable
class SemiScrollTarget {
  const SemiScrollTarget(
    this.col,
    this.row, {
    this.axis = SemiScrollAxis.both,
  });

  final int col;
  final int row;
  final SemiScrollAxis axis;
}

enum SemiScrollAxis { vertical, horizontal, both }

/// `mangledOnCellsEdited` / `onCellsEdited` payload.
typedef SemiCellsEditedCallback = void Function(
  List<SemiEditListItem> items,
);

/// `onDelete` (`data-editor.tsx:3230`): `true` (or null) deletes the
/// selection as-is, `false` aborts, a [SemiGridSelection] replaces it.
typedef SemiDeleteCallback =
    Object? Function(SemiGridSelection selection);

class SemiKeyHandler {
  SemiKeyHandler({
    required this.keys,
    required this.selection,
    required this.setGridSelection,
    required this.columnCount,
    required this.rows,
    required this.rowMarkerOffset,
    required this.overlayOpen,
    required this.columnSelect,
    required this.rowSelect,
    required this.rangeSelect,
    required this.visibleRegion,
    required this.getCellContent,
    required this.getCellRenderer,
    this.showTrailingBlankRow = false,
    this.userRows,
    this.appendRow,
    this.getCustomNewRowTargetColumn,
    this.rangeBehavior = SemiSelectionBlending.exclusive,
    this.columnBehavior = SemiSelectionBlending.exclusive,
    this.rowBehavior = SemiSelectionBlending.exclusive,
    this.rangeSelectionColumnSpanning = true,
    this.scrollToActiveCell = true,
    this.getCellsForSelection,
    this.onSelectionCleared,
    this.onSearch,
    this.onDelete,
    this.onCellsEdited,
    this.onCellActivated,
    this.fillDown,
    this.fillRight,
    this.scrollTo,
    this.rowGroupingNavBehavior,
    this.isGroupHeaderRow,
    this.getSelectionRowLimits,
    this.trapFocus = false,
  });

  final SemiRealizedKeybinds keys;

  /// Current selection; the handler reads and replaces it directly, exactly
  /// like the `gridSelection` ref upstream.
  SemiGridSelection selection;

  final void Function(SemiGridSelection newVal, bool expand) setGridSelection;
  final int columnCount;
  final int rows;
  final int rowMarkerOffset;
  final bool overlayOpen;
  final SemiSelectMode columnSelect;
  final SemiSelectMode rowSelect;
  final SemiRangeSelect rangeSelect;
  final SemiRectangle visibleRegion;
  final SemiGridCell Function(SemiItem item) getCellContent;
  final SemiGetCellRenderer getCellRenderer;

  /// `showTrailingBlankRow` (`data-editor.tsx:955`); [userRows] is the row
  /// count *without* the trailing row, so the trailing row sits at index
  /// `userRows`. Defaults to [rows], which is correct whenever there is no
  /// trailing row.
  final bool showTrailingBlankRow;
  final int? userRows;

  int get _userRows => userRows ?? rows;

  /// `appendRow` (`data-editor.tsx:1687`).
  final void Function(int col, bool openOverlay)? appendRow;

  /// `getCustomNewRowTargetColumn` (`data-editor.tsx:1795`).
  final int? Function(int col)? getCustomNewRowTargetColumn;

  final SemiSelectionBlending rangeBehavior;
  final SemiSelectionBlending columnBehavior;
  final SemiSelectionBlending rowBehavior;
  final bool rangeSelectionColumnSpanning;

  /// `scrollToActiveCell` (`data-editor.tsx:691`): gates the `scrollTo` at
  /// the end of `updateSelectedCell` (`:3066-3068`).
  final bool scrollToActiveCell;

  final SemiGetCellsForSelection? getCellsForSelection;
  final void Function()? onSelectionCleared;
  final void Function()? onSearch;
  final SemiDeleteCallback? onDelete;
  final SemiCellsEditedCallback? onCellsEdited;
  final void Function(SemiItem location, SemiCellActivation activation)?
  onCellActivated;
  final void Function()? fillDown;
  final void Function()? fillRight;
  final void Function(SemiScrollTarget target)? scrollTo;

  /// `navigationBehavior` (`row-grouping.ts:56`); null disables the
  /// restriction entirely.
  final SemiRowGroupNavigationBehavior? rowGroupingNavBehavior;

  /// `mapper(row).isGroupHeader` (`row-grouping.ts:190-238`).
  final bool Function(int row)? isGroupHeaderRow;

  /// `getSelectionRowLimits` (`data-editor.tsx:2708-2725`).
  final (int, int)? Function(int row)? getSelectionRowLimits;
  final bool trapFocus;

  /// Builds the behavior over [base].
  ///
  /// Upstream every `useSelectionBehavior` callback closes over the
  /// `gridSelection` value of the render that started the key handling, so
  /// successive mutations in one handler run all derive from the same
  /// snapshot rather than from each other.
  SemiSelectionBehavior _behaviorFor(SemiGridSelection base) =>
      SemiSelectionBehavior(
    gridSelection: base,
    setGridSelection: (newVal, expand) {
      // Upstream `useSelectionBehavior` does not expand
      // (`use-selection-behavior.ts` has no `expandSelection` call); the
      // single expansion point is the data editor's `setGridSelection`
      // (`data-editor.tsx:1000`), which [setGridSelection] is bound to.
      // Expanding here as well ran `getCellsForSelection` twice per key.
      selection = newVal;
      setGridSelection(newVal, expand);
    },
    rangeBehavior: rangeBehavior,
    columnBehavior: columnBehavior,
    rowBehavior: rowBehavior,
    rangeSelect: rangeSelect,
    rangeSelectionColumnSpanning: rangeSelectionColumnSpanning,
  );

  SemiSelectionBehavior _behavior() => _behaviorFor(selection);

  /// `handleFixedKeybindings` (`data-editor.tsx:3188-3482`).
  ///
  /// Returns true when the event was consumed.
  bool handleFixedKeybindings(SemiGridKeyArgs event) {
    void cancel() {
      event.stopPropagation();
      event.preventDefault();
    }

    final details = SemiHotkeyDetails();

    // React hands this callback the selection of the render that started the
    // key handling; keep that snapshot for the whole run.
    final base = selection;
    final behavior = _behaviorFor(base);
    final selectedColumns = base.columns;
    final selectedRows = base.rows;
    final k = keys;

    if (!overlayOpen && semiIsHotkey(k.clear, event, details)) {
      behavior.setGridSelection(SemiGridSelection.empty, false);
      onSelectionCleared?.call();
    } else if (!overlayOpen &&
        semiIsHotkey(k.selectAll, event, details)) {
      behavior.setGridSelection(
        SemiGridSelection(
        columns: const SemiCompactSelection.empty(),
        rows: const SemiCompactSelection.empty(),
        current: SemiGridSelectionCurrent(
          cell: base.current?.cell ?? SemiItem(rowMarkerOffset, 0),
          range: SemiRectangle(
            x: rowMarkerOffset.toDouble(),
            y: 0,
            width: columnCount.toDouble(),
            height: _userRows.toDouble(),
          ),
        ),
      ),
        false,
      );
    } else if (semiIsHotkey(k.search, event, details)) {
      onSearch?.call();
    } else if (semiIsHotkey(k.delete, event, details)) {
      final callbackResult = onDelete?.call(selection) ?? true;
      if (callbackResult != false) {
        final toDelete = callbackResult is SemiGridSelection
            ? callbackResult
            : selection;

        // Delete order: 1) primary range 2) secondary ranges 3) columns
        // 4) rows.
        final current = toDelete.current;
        if (current != null) {
          deleteRange(current.range);
          for (final r in current.rangeStack) {
            deleteRange(r);
          }
        }

        for (final r in toDelete.rows.indices) {
          deleteRange(
            SemiRectangle(
              x: rowMarkerOffset.toDouble(),
              y: r.toDouble(),
              width: columnCount.toDouble(),
              height: 1,
            ),
          );
        }

        for (final col in toDelete.columns.indices) {
          deleteRange(
            SemiRectangle(
              x: col.toDouble(),
              y: 0,
              width: 1,
              height: _userRows.toDouble(),
            ),
          );
        }
      }
    }

    if (details.didMatch) {
      cancel();
      return true;
    }

    final current = base.current;
    if (current == null) return false;

    var col = current.cell.col;
    var row = current.cell.row;
    final startRow = current.cell.row;
    var freeMove = false;
    var cancelOnlyOnMove = false;

    if (semiIsHotkey(k.scrollToSelectedCell, event, details)) {
      scrollTo?.call(
        SemiScrollTarget(col - rowMarkerOffset, row),
      );
    } else if (columnSelect != SemiSelectMode.none &&
        semiIsHotkey(k.selectColumn, event, details)) {
      if (selectedColumns.hasIndex(col)) {
        behavior.setSelectedColumns(
          newCols: selectedColumns.remove(col),
          append: null,
          allowMixed: true,
        );
      } else if (columnSelect == SemiSelectMode.single) {
        behavior.setSelectedColumns(
          newCols: SemiCompactSelection.fromSingleSelection(col),
          append: null,
          allowMixed: true,
        );
      } else {
        behavior.setSelectedColumns(
          newCols: null,
          append: col,
          allowMixed: true,
        );
      }
    } else if (rowSelect != SemiSelectMode.none &&
        semiIsHotkey(k.selectRow, event, details)) {
      if (selectedRows.hasIndex(row)) {
        behavior.setSelectedRows(
          newRows: selectedRows.remove(row),
          append: null,
          allowMixed: true,
        );
      } else if (rowSelect == SemiSelectMode.single) {
        behavior.setSelectedRows(
          newRows: SemiCompactSelection.fromSingleSelection(row),
          append: null,
          allowMixed: true,
        );
      } else {
        behavior.setSelectedRows(
          newRows: null,
          append: row,
          allowMixed: true,
        );
      }
    } else if (!overlayOpen &&
        event.bounds != null &&
        semiIsHotkey(k.activateCell, event, details)) {
      if (showTrailingBlankRow && row == _userRows) {
        // Enter on the trailing row appends instead of editing
        // (`data-editor.tsx:3301-3305`).
        appendRow?.call(getCustomNewRowTargetColumn?.call(col) ?? col, true);
      } else {
        onCellActivated?.call(
          SemiItem(col - rowMarkerOffset, row),
          const SemiKeyboardCellActivation(null),
        );
      }
    } else if (current.range.height > 1 &&
        semiIsHotkey(k.downFill, event, details)) {
      fillDown?.call();
    } else if (current.range.width > 1 &&
        semiIsHotkey(k.rightFill, event, details)) {
      fillRight?.call();
    } else if (semiIsHotkey(k.goToNextPage, event, details)) {
      // Partial cell accounting.
      row += math.max(1, visibleRegion.height.toInt() - 4);
    } else if (semiIsHotkey(k.goToPreviousPage, event, details)) {
      row -= math.max(1, visibleRegion.height.toInt() - 4);
    } else if (semiIsHotkey(k.goToFirstCell, event, details)) {
      row = 0;
      col = 0;
    } else if (semiIsHotkey(k.goToLastCell, event, details)) {
      row = 1 << 30;
      col = 1 << 30;
    } else if (semiIsHotkey(k.selectToFirstCell, event, details)) {
      _adjustSelection((-2, -2), behavior);
    } else if (semiIsHotkey(k.selectToLastCell, event, details)) {
      _adjustSelection((2, 2), behavior);
    } else if (!overlayOpen) {
      if (semiIsHotkey(k.goDownCell, event, details)) {
        row += 1;
      } else if (semiIsHotkey(k.goUpCell, event, details)) {
        row -= 1;
      } else if (semiIsHotkey(k.goRightCell, event, details)) {
        col += 1;
      } else if (semiIsHotkey(k.goLeftCell, event, details)) {
        col -= 1;
      } else if (semiIsHotkey(k.goDownCellRetainSelection, event, details)) {
        row += 1;
        freeMove = true;
      } else if (semiIsHotkey(k.goUpCellRetainSelection, event, details)) {
        row -= 1;
        freeMove = true;
      } else if (semiIsHotkey(k.goRightCellRetainSelection, event, details)) {
        col += 1;
        freeMove = true;
      } else if (semiIsHotkey(k.goLeftCellRetainSelection, event, details)) {
        col -= 1;
        freeMove = true;
      } else if (semiIsHotkey(k.goToLastRow, event, details)) {
        row = math.max(0, _userRows - 1);
      } else if (semiIsHotkey(k.goToFirstRow, event, details)) {
        row = -(1 << 30);
      } else if (semiIsHotkey(k.goToLastColumn, event, details)) {
        col = 1 << 30;
      } else if (semiIsHotkey(k.goToFirstColumn, event, details)) {
        col = -(1 << 30);
      } else if (rangeSelect == SemiRangeSelect.rect ||
          rangeSelect == SemiRangeSelect.multiRect) {
        if (semiIsHotkey(k.selectGrowDown, event, details)) {
          _adjustSelection((0, 1), behavior);
        } else if (semiIsHotkey(k.selectGrowUp, event, details)) {
          _adjustSelection((0, -1), behavior);
        } else if (semiIsHotkey(k.selectGrowRight, event, details)) {
          _adjustSelection((1, 0), behavior);
        } else if (semiIsHotkey(k.selectGrowLeft, event, details)) {
          _adjustSelection((-1, 0), behavior);
        } else if (semiIsHotkey(k.selectToLastRow, event, details)) {
          _adjustSelection((0, 2), behavior);
        } else if (semiIsHotkey(k.selectToFirstRow, event, details)) {
          _adjustSelection((0, -2), behavior);
        } else if (semiIsHotkey(k.selectToLastColumn, event, details)) {
          _adjustSelection((2, 0), behavior);
        } else if (semiIsHotkey(k.selectToFirstColumn, event, details)) {
          _adjustSelection((-2, 0), behavior);
        }
      }
      cancelOnlyOnMove = details.didMatch;
    } else {
      if (semiIsHotkey(k.closeOverlay, event, details)) {
        // The overlay owner closes it; see `onFinishedEditing`.
        onOverlayClosed?.call();
      }
      if (semiIsHotkey(k.acceptOverlayDown, event, details)) {
        onOverlayClosed?.call();
        row++;
      }
      if (semiIsHotkey(k.acceptOverlayUp, event, details)) {
        onOverlayClosed?.call();
        row--;
      }
      if (semiIsHotkey(k.acceptOverlayLeft, event, details)) {
        onOverlayClosed?.call();
        col--;
      }
      if (semiIsHotkey(k.acceptOverlayRight, event, details)) {
        onOverlayClosed?.call();
        col++;
      }
    }

    // Row-grouping navigation (`:3412-3441`).
    final navBehavior = rowGroupingNavBehavior;
    final mustRestrictRow =
        navBehavior != null &&
        navBehavior != SemiRowGroupNavigationBehavior.normal;
    if (mustRestrictRow && row != startRow) {
      final mapper = isGroupHeaderRow;
      final skipUp =
          navBehavior == SemiRowGroupNavigationBehavior.skipUp ||
          navBehavior == SemiRowGroupNavigationBehavior.skip ||
          navBehavior == SemiRowGroupNavigationBehavior.block;
      final skipDown =
          navBehavior == SemiRowGroupNavigationBehavior.skipDown ||
          navBehavior == SemiRowGroupNavigationBehavior.skip ||
          navBehavior == SemiRowGroupNavigationBehavior.block;
      final didMoveUp = row < startRow;
      if (didMoveUp && skipUp) {
        while (row >= 0 && mapper != null && mapper(row)) {
          row--;
        }
        if (row < 0) row = startRow;
      } else if (!didMoveUp && skipDown) {
        while (row < rows && mapper != null && mapper(row)) {
          row++;
        }
        if (row >= rows) row = startRow;
      }
    }

    final moved = _updateSelectedCell(
      col,
      row,
      fromEditingTrailingRow: false,
      freeMove: freeMove,
      behavior: behavior,
      base: base,
    );

    final didMatch = details.didMatch;
    if (didMatch && (moved || !cancelOnlyOnMove || trapFocus)) {
      cancel();
    }
    return didMatch;
  }

  /// Set when the overlay editor should close itself (the `overlay`
  /// reference is owned by `SemiDataEditor`).
  void Function()? onOverlayClosed;

  /// `updateSelectedCell` (`data-editor.tsx:3024-3082`).
  bool updateSelectedCell(
    int col,
    int row, {
    required bool fromEditingTrailingRow,
    required bool freeMove,
  }) => _updateSelectedCell(
    col,
    row,
    fromEditingTrailingRow: fromEditingTrailingRow,
    freeMove: freeMove,
    behavior: _behavior(),
    base: selection,
  );

  bool _updateSelectedCell(
    int col,
    int row, {
    required bool fromEditingTrailingRow,
    required bool freeMove,
    required SemiSelectionBehavior behavior,
    required SemiGridSelection base,
  }) {
    final rowMax = rows - (fromEditingTrailingRow ? 0 : 1);
    col = clampInt(col, rowMarkerOffset, columnCount - 1 + rowMarkerOffset);
    row = clampInt(row, 0, rowMax);

    final curCol = base.current?.cell.col;
    final curRow = base.current?.cell.row;

    if (col == curCol && row == curRow) return false;

    if (freeMove && base.current != null) {
      final newStack = [...base.current!.rangeStack];
      if (base.current!.range.width > 1 ||
          base.current!.range.height > 1) {
        newStack.add(base.current!.range);
      }
      final v = SemiGridSelection(
        columns: base.columns,
        rows: base.rows,
        current: SemiGridSelectionCurrent(
          cell: SemiItem(col, row),
          range: SemiRectangle(
            x: col.toDouble(),
            y: row.toDouble(),
            width: 1,
            height: 1,
          ),
          rangeStack: newStack,
        ),
      );
      behavior.setGridSelection(v, true);
    } else {
      behavior.setCurrent(
        value: (
          cell: SemiItem(col, row),
          range: SemiRectangle(
            x: col.toDouble(),
            y: row.toDouble(),
            width: 1,
            height: 1,
          ),
        ),
        expand: true,
        append: false,
        trigger: SemiSelectionTrigger.keyboardNav,
      );
    }

    // `if (scrollToActiveCellRef.current)` (`data-editor.tsx:3066-3068`).
    if (scrollToActiveCell) {
      scrollTo?.call(
        SemiScrollTarget(col - rowMarkerOffset, row),
      );
    }
    return true;
  }

  /// `adjustSelection` (`data-editor.tsx:2854-3019`).
  ///
  /// `direction` entries mirror upstream's `0 | 1 | -1 | 2 | -2` encoding.
  void _adjustSelection(
    (int, int) direction,
    SemiSelectionBehavior behavior,
  ) {
    final current = selection.current;
    if (current == null) return;

    final (x, y) = direction;
    final col = current.cell.col;
    final row = current.cell.row;
    final old = current.range;
    var left = old.x.toInt();
    var right = (old.x + old.width).toInt();
    var top = old.y.toInt();
    var bottom = (old.y + old.height).toInt();

    // `getSelectionRowLimits(row) ?? [0, rows - 1]` (`data-editor.tsx:2866`);
    // the default is the grouped row count without the trailing row.
    final limits = getSelectionRowLimits?.call(row);
    final minRow = limits?.$1 ?? 0;
    final maxRowRaw = limits?.$2 ?? math.max(0, _userRows - 1);
    final maxRow = maxRowRaw + 1; // inclusive

    // Vertical first, in case new spans come in.
    if (y != 0) {
      switch (y) {
        case 2:
          bottom = maxRow;
          top = row;
          scrollTo?.call(
            SemiScrollTarget(0, bottom, axis: SemiScrollAxis.vertical),
          );
        case -2:
          top = minRow;
          bottom = row + 1;
          scrollTo?.call(
            SemiScrollTarget(0, top, axis: SemiScrollAxis.vertical),
          );
        case 1:
          if (top < row) {
            top++;
            scrollTo?.call(
              SemiScrollTarget(0, top, axis: SemiScrollAxis.vertical),
            );
          } else {
            bottom = math.min(maxRow, bottom + 1);
            scrollTo?.call(
              SemiScrollTarget(0, bottom, axis: SemiScrollAxis.vertical),
            );
          }
        case -1:
          if (bottom > row + 1) {
            bottom--;
            scrollTo?.call(
              SemiScrollTarget(0, bottom, axis: SemiScrollAxis.vertical),
            );
          } else {
            top = math.max(minRow, top - 1);
            scrollTo?.call(
              SemiScrollTarget(0, top, axis: SemiScrollAxis.vertical),
            );
          }
        default:
          assert(false, 'unreachable direction $y');
      }
    }

    if (x != 0) {
      if (x == 2) {
        right = columnCount;
        left = col;
        scrollTo?.call(
          SemiScrollTarget(
            right - 1 - rowMarkerOffset,
            0,
            axis: SemiScrollAxis.horizontal,
          ),
        );
      } else if (x == -2) {
        left = rowMarkerOffset;
        right = col + 1;
        scrollTo?.call(
          SemiScrollTarget(
            left - rowMarkerOffset,
            0,
            axis: SemiScrollAxis.horizontal,
          ),
        );
      } else {
        var disallowed = const <int>[];
        final getCells = getCellsForSelection;
        if (getCells != null) {
          final cells = getCells(
            SemiRectangle(
              x: left.toDouble(),
              y: top.toDouble(),
              width: (right - left - rowMarkerOffset).toDouble(),
              height: (bottom - top).toDouble(),
            ),
          );
          if (cells != null) disallowed = semiGetSpanStops(cells);
        }

        if (x == 1) {
          // Motion right.
          var done = false;
          if (left < col) {
            if (disallowed.isNotEmpty) {
              int? target;
              for (var n = left + 1; n < col + 1; n++) {
                if (!disallowed.contains(n - rowMarkerOffset)) {
                  target = n;
                  break;
                }
              }
              if (target != null) {
                left = target;
                done = true;
              }
            } else {
              left++;
              done = true;
            }
            if (done) {
              scrollTo?.call(
                SemiScrollTarget(
                  left,
                  0,
                  axis: SemiScrollAxis.horizontal,
                ),
              );
            }
          }
          if (!done) {
            right = math.min(columnCount, right + 1);
            scrollTo?.call(
              SemiScrollTarget(
                right - 1 - rowMarkerOffset,
                0,
                axis: SemiScrollAxis.horizontal,
              ),
            );
          }
        } else if (x == -1) {
          // Motion left.
          var done = false;
          if (right > col + 1) {
            if (disallowed.isNotEmpty) {
              int? target;
              for (var n = right - 1; n > col; n--) {
                if (!disallowed.contains(n - rowMarkerOffset)) {
                  target = n;
                  break;
                }
              }
              if (target != null) {
                right = target;
                done = true;
              }
            } else {
              right--;
              done = true;
            }
            if (done) {
              scrollTo?.call(
                SemiScrollTarget(
                  right - rowMarkerOffset,
                  0,
                  axis: SemiScrollAxis.horizontal,
                ),
              );
            }
          }
          if (!done) {
            left = math.max(rowMarkerOffset, left - 1);
            scrollTo?.call(
              SemiScrollTarget(
                left - rowMarkerOffset,
                0,
                axis: SemiScrollAxis.horizontal,
              ),
            );
          }
        } else {
          assert(false, 'unreachable direction $x');
        }
      }
    }

    behavior.setCurrent(
      value: (
        cell: current.cell,
        range: SemiRectangle(
          x: left.toDouble(),
          y: top.toDouble(),
          width: (right - left).toDouble(),
          height: (bottom - top).toDouble(),
        ),
      ),
      expand: true,
      append: false,
      trigger: SemiSelectionTrigger.keyboardSelect,
    );
  }

  /// Set by `onKeyDown` when a printable key should open the editor on the
  /// current cell (`data-editor.tsx:3523-3530`, upstream `reselect`).
  void Function(SemiRectangle bounds, String key)? onTypeToEdit;

  /// `onKeyDown` (`data-editor.tsx:3484-3545`).
  ///
  /// Returns true when the event was consumed.
  bool handleKeyDown(SemiGridKeyArgs event, {required bool editOnType}) {
    if (handleFixedKeybindings(event)) return true;
    if (!editOnType) return false;
    if (event.metaKey || event.ctrlKey) return false;

    final current = selection.current;
    if (current == null) return false;

    final key = event.key;
    // `/[\p{L}\p{M}\p{N}\p{S}\p{P}]/u` upstream: everything that is
    // neither a control nor a separator. Dart has no Unicode property
    // escapes, so compare against the BMP control range instead.
    if (key.length != 1 || key.codeUnitAt(0) < 0x21) return false;

    final bounds = event.bounds;
    if (bounds == null) return false;

    final col = current.cell.col;
    final row = current.cell.row;

    // `(!showTrailingBlankRow || row !== rows)` (`data-editor.tsx:3518`).
    if (showTrailingBlankRow && row == _userRows) return false;

    final target = getCellContent(
      SemiItem(
        col - rowMarkerOffset,
        clampInt(row, 0, math.max(0, _userRows - 1)),
      ),
    );
    if (!semiIsEditableGridCell(target) ||
        target.kind == SemiCellKind.boolean) {
      return false;
    }

    final vr = visibleRegion;
    if (vr.y > row ||
        row > vr.y + vr.height ||
        vr.x > col ||
        col > vr.x + vr.width) {
      return false;
    }

    onCellActivated?.call(
      SemiItem(col - rowMarkerOffset, row),
      SemiKeyboardCellActivation(key),
    );
    onTypeToEdit?.call(bounds, key);
    event.stopPropagation();
    event.preventDefault();
    return true;
  }

  /// `deleteRange` (`data-editor.tsx:3148-3184`).
  void deleteRange(SemiRectangle r) {
    final editList = <SemiEditListItem>[];
    for (var x = r.x.toInt(); x < r.x + r.width; x++) {
      for (var y = r.y.toInt(); y < r.y + r.height; y++) {
        final cellValue = getCellContent(
          SemiItem(x - rowMarkerOffset, y),
        );
        if (!cellValue.allowOverlay &&
            cellValue.kind != SemiCellKind.boolean) {
          continue;
        }

        SemiGridCell? newVal;
        final renderer = getCellRenderer(cellValue);
        newVal = renderer?.onDelete(cellValue);
        if (newVal == null && renderer != null) {
          // `editor?.deletedValue?.(cellValue)` (`data-editor.tsx:3166`).
          final provider = renderer.provideEditor(
            cellValue,
            SemiItem(x - rowMarkerOffset, y),
          );
          if (provider is SemiObjectEditor) {
            newVal = provider.deletedValue?.call(cellValue);
          }
        }

        if (newVal != null && semiIsEditableGridCell(newVal)) {
          editList.add(
            SemiEditListItem(location: SemiItem(x, y), value: newVal),
          );
        }
      }
    }
    onCellsEdited?.call(editList);
  }
}

