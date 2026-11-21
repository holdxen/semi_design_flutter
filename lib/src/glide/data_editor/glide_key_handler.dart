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

import '../cells/glide_cell_types.dart';
import '../common/glide_is_hotkey.dart';
import '../internal/data_grid/glide_event_args.dart';
import '../common/glide_utils.dart';
import '../internal/data_grid/glide_selection_behavior.dart';
import 'glide_data_editor_fns.dart';
import 'glide_keybindings.dart';

/// `columnSelect` / `rowSelect` (`"none" | "single" | "multi"`).
enum GlideSelectMode { none, single, multi }

/// `scrollTo(col, row, axis?)`.
@immutable
class GlideScrollTarget {
  const GlideScrollTarget(
    this.col,
    this.row, {
    this.axis = GlideScrollAxis.both,
  });

  final int col;
  final int row;
  final GlideScrollAxis axis;
}

enum GlideScrollAxis { vertical, horizontal, both }

/// `mangledOnCellsEdited` / `onCellsEdited` payload.
typedef GlideCellsEditedCallback = void Function(
  List<GlideEditListItem> items,
);

/// `onDelete` (`data-editor.tsx:3230`): `true` (or null) deletes the
/// selection as-is, `false` aborts, a [GlideGridSelection] replaces it.
typedef GlideDeleteCallback =
    Object? Function(GlideGridSelection selection);

class GlideKeyHandler {
  GlideKeyHandler({
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
    this.rangeBehavior = GlideSelectionBlending.exclusive,
    this.columnBehavior = GlideSelectionBlending.exclusive,
    this.rowBehavior = GlideSelectionBlending.exclusive,
    this.rangeSelectionColumnSpanning = true,
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
    this.trapFocus = false,
  });

  final GlideRealizedKeybinds keys;

  /// Current selection; the handler reads and replaces it directly, exactly
  /// like the `gridSelection` ref upstream.
  GlideGridSelection selection;

  final void Function(GlideGridSelection newVal, bool expand) setGridSelection;
  final int columnCount;
  final int rows;
  final int rowMarkerOffset;
  final bool overlayOpen;
  final GlideSelectMode columnSelect;
  final GlideSelectMode rowSelect;
  final GlideRangeSelect rangeSelect;
  final GlideRectangle visibleRegion;
  final GlideGridCell Function(GlideItem item) getCellContent;
  final GlideGetCellRenderer getCellRenderer;

  final GlideSelectionBlending rangeBehavior;
  final GlideSelectionBlending columnBehavior;
  final GlideSelectionBlending rowBehavior;
  final bool rangeSelectionColumnSpanning;

  final GlideGetCellsForSelection? getCellsForSelection;
  final void Function()? onSelectionCleared;
  final void Function()? onSearch;
  final GlideDeleteCallback? onDelete;
  final GlideCellsEditedCallback? onCellsEdited;
  final void Function(GlideItem location, GlideCellActivation activation)?
  onCellActivated;
  final void Function()? fillDown;
  final void Function()? fillRight;
  final void Function(GlideScrollTarget target)? scrollTo;

  /// Row-grouping navigation (`"normal" | "skip-up" | "skip-down" | "skip" |
  /// "block"`); null disables the restriction.
  final String? rowGroupingNavBehavior;

  /// `mapper(row).isGroupHeader`.
  final bool Function(int row)? isGroupHeaderRow;
  final bool trapFocus;

  /// Builds the behavior over [base].
  ///
  /// Upstream every `useSelectionBehavior` callback closes over the
  /// `gridSelection` value of the render that started the key handling, so
  /// successive mutations in one handler run all derive from the same
  /// snapshot rather than from each other.
  GlideSelectionBehavior _behaviorFor(GlideGridSelection base) =>
      GlideSelectionBehavior(
    gridSelection: base,
    setGridSelection: (newVal, expand) {
      var v = newVal;
      if (expand) {
        v = glideExpandSelection(
          newVal: v,
          getCellsForSelection: getCellsForSelection,
          rowMarkerOffset: rowMarkerOffset,
          allowPartial: false,
        );
      }
      selection = v;
      setGridSelection(v, expand);
    },
    rangeBehavior: rangeBehavior,
    columnBehavior: columnBehavior,
    rowBehavior: rowBehavior,
    rangeSelect: rangeSelect,
    rangeSelectionColumnSpanning: rangeSelectionColumnSpanning,
  );

  GlideSelectionBehavior _behavior() => _behaviorFor(selection);

  /// `handleFixedKeybindings` (`data-editor.tsx:3188-3482`).
  ///
  /// Returns true when the event was consumed.
  bool handleFixedKeybindings(GlideGridKeyArgs event) {
    void cancel() {
      event.stopPropagation();
      event.preventDefault();
    }

    final details = GlideHotkeyDetails();

    // React hands this callback the selection of the render that started the
    // key handling; keep that snapshot for the whole run.
    final base = selection;
    final behavior = _behaviorFor(base);
    final selectedColumns = base.columns;
    final selectedRows = base.rows;
    final k = keys;

    if (!overlayOpen && glideIsHotkey(k.clear, event, details)) {
      behavior.setGridSelection(GlideGridSelection.empty, false);
      onSelectionCleared?.call();
    } else if (!overlayOpen &&
        glideIsHotkey(k.selectAll, event, details)) {
      behavior.setGridSelection(
        GlideGridSelection(
        columns: const GlideCompactSelection.empty(),
        rows: const GlideCompactSelection.empty(),
        current: GlideGridSelectionCurrent(
          cell: base.current?.cell ?? GlideItem(rowMarkerOffset, 0),
          range: GlideRectangle(
            x: rowMarkerOffset.toDouble(),
            y: 0,
            width: columnCount.toDouble(),
            height: rows.toDouble(),
          ),
        ),
      ),
        false,
      );
    } else if (glideIsHotkey(k.search, event, details)) {
      onSearch?.call();
    } else if (glideIsHotkey(k.delete, event, details)) {
      final callbackResult = onDelete?.call(selection) ?? true;
      if (callbackResult != false) {
        final toDelete = callbackResult is GlideGridSelection
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
            GlideRectangle(
              x: rowMarkerOffset.toDouble(),
              y: r.toDouble(),
              width: columnCount.toDouble(),
              height: 1,
            ),
          );
        }

        for (final col in toDelete.columns.indices) {
          deleteRange(
            GlideRectangle(
              x: col.toDouble(),
              y: 0,
              width: 1,
              height: rows.toDouble(),
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

    if (glideIsHotkey(k.scrollToSelectedCell, event, details)) {
      scrollTo?.call(
        GlideScrollTarget(col - rowMarkerOffset, row),
      );
    } else if (columnSelect != GlideSelectMode.none &&
        glideIsHotkey(k.selectColumn, event, details)) {
      if (selectedColumns.hasIndex(col)) {
        behavior.setSelectedColumns(
          newCols: selectedColumns.remove(col),
          append: null,
          allowMixed: true,
        );
      } else if (columnSelect == GlideSelectMode.single) {
        behavior.setSelectedColumns(
          newCols: GlideCompactSelection.fromSingleSelection(col),
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
    } else if (rowSelect != GlideSelectMode.none &&
        glideIsHotkey(k.selectRow, event, details)) {
      if (selectedRows.hasIndex(row)) {
        behavior.setSelectedRows(
          newRows: selectedRows.remove(row),
          append: null,
          allowMixed: true,
        );
      } else if (rowSelect == GlideSelectMode.single) {
        behavior.setSelectedRows(
          newRows: GlideCompactSelection.fromSingleSelection(row),
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
        glideIsHotkey(k.activateCell, event, details)) {
      onCellActivated?.call(
        GlideItem(col - rowMarkerOffset, row),
        const GlideKeyboardCellActivation(null),
      );
    } else if (current.range.height > 1 &&
        glideIsHotkey(k.downFill, event, details)) {
      fillDown?.call();
    } else if (current.range.width > 1 &&
        glideIsHotkey(k.rightFill, event, details)) {
      fillRight?.call();
    } else if (glideIsHotkey(k.goToNextPage, event, details)) {
      // Partial cell accounting.
      row += math.max(1, visibleRegion.height.toInt() - 4);
    } else if (glideIsHotkey(k.goToPreviousPage, event, details)) {
      row -= math.max(1, visibleRegion.height.toInt() - 4);
    } else if (glideIsHotkey(k.goToFirstCell, event, details)) {
      row = 0;
      col = 0;
    } else if (glideIsHotkey(k.goToLastCell, event, details)) {
      row = 1 << 30;
      col = 1 << 30;
    } else if (glideIsHotkey(k.selectToFirstCell, event, details)) {
      _adjustSelection((-2, -2), behavior);
    } else if (glideIsHotkey(k.selectToLastCell, event, details)) {
      _adjustSelection((2, 2), behavior);
    } else if (!overlayOpen) {
      if (glideIsHotkey(k.goDownCell, event, details)) {
        row += 1;
      } else if (glideIsHotkey(k.goUpCell, event, details)) {
        row -= 1;
      } else if (glideIsHotkey(k.goRightCell, event, details)) {
        col += 1;
      } else if (glideIsHotkey(k.goLeftCell, event, details)) {
        col -= 1;
      } else if (glideIsHotkey(k.goDownCellRetainSelection, event, details)) {
        row += 1;
        freeMove = true;
      } else if (glideIsHotkey(k.goUpCellRetainSelection, event, details)) {
        row -= 1;
        freeMove = true;
      } else if (glideIsHotkey(k.goRightCellRetainSelection, event, details)) {
        col += 1;
        freeMove = true;
      } else if (glideIsHotkey(k.goLeftCellRetainSelection, event, details)) {
        col -= 1;
        freeMove = true;
      } else if (glideIsHotkey(k.goToLastRow, event, details)) {
        row = rows - 1;
      } else if (glideIsHotkey(k.goToFirstRow, event, details)) {
        row = -(1 << 30);
      } else if (glideIsHotkey(k.goToLastColumn, event, details)) {
        col = 1 << 30;
      } else if (glideIsHotkey(k.goToFirstColumn, event, details)) {
        col = -(1 << 30);
      } else if (rangeSelect == GlideRangeSelect.rect ||
          rangeSelect == GlideRangeSelect.multiRect) {
        if (glideIsHotkey(k.selectGrowDown, event, details)) {
          _adjustSelection((0, 1), behavior);
        } else if (glideIsHotkey(k.selectGrowUp, event, details)) {
          _adjustSelection((0, -1), behavior);
        } else if (glideIsHotkey(k.selectGrowRight, event, details)) {
          _adjustSelection((1, 0), behavior);
        } else if (glideIsHotkey(k.selectGrowLeft, event, details)) {
          _adjustSelection((-1, 0), behavior);
        } else if (glideIsHotkey(k.selectToLastRow, event, details)) {
          _adjustSelection((0, 2), behavior);
        } else if (glideIsHotkey(k.selectToFirstRow, event, details)) {
          _adjustSelection((0, -2), behavior);
        } else if (glideIsHotkey(k.selectToLastColumn, event, details)) {
          _adjustSelection((2, 0), behavior);
        } else if (glideIsHotkey(k.selectToFirstColumn, event, details)) {
          _adjustSelection((-2, 0), behavior);
        }
      }
      cancelOnlyOnMove = details.didMatch;
    } else {
      if (glideIsHotkey(k.closeOverlay, event, details)) {
        // The overlay owner closes it; see `onFinishedEditing`.
        onOverlayClosed?.call();
      }
      if (glideIsHotkey(k.acceptOverlayDown, event, details)) {
        onOverlayClosed?.call();
        row++;
      }
      if (glideIsHotkey(k.acceptOverlayUp, event, details)) {
        onOverlayClosed?.call();
        row--;
      }
      if (glideIsHotkey(k.acceptOverlayLeft, event, details)) {
        onOverlayClosed?.call();
        col--;
      }
      if (glideIsHotkey(k.acceptOverlayRight, event, details)) {
        onOverlayClosed?.call();
        col++;
      }
    }

    // Row-grouping navigation (`:3412-3441`).
    final mustRestrictRow =
        rowGroupingNavBehavior != null && rowGroupingNavBehavior != 'normal';
    if (mustRestrictRow && row != startRow) {
      final mapper = isGroupHeaderRow;
      final skipUp = rowGroupingNavBehavior == 'skip-up' ||
          rowGroupingNavBehavior == 'skip' ||
          rowGroupingNavBehavior == 'block';
      final skipDown = rowGroupingNavBehavior == 'skip-down' ||
          rowGroupingNavBehavior == 'skip' ||
          rowGroupingNavBehavior == 'block';
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
  /// reference is owned by `GlideDataEditor`).
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
    required GlideSelectionBehavior behavior,
    required GlideGridSelection base,
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
      final v = GlideGridSelection(
        columns: base.columns,
        rows: base.rows,
        current: GlideGridSelectionCurrent(
          cell: GlideItem(col, row),
          range: GlideRectangle(
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
          cell: GlideItem(col, row),
          range: GlideRectangle(
            x: col.toDouble(),
            y: row.toDouble(),
            width: 1,
            height: 1,
          ),
        ),
        expand: true,
        append: false,
        trigger: GlideSelectionTrigger.keyboardNav,
      );
    }

    scrollTo?.call(
      GlideScrollTarget(col - rowMarkerOffset, row),
    );
    return true;
  }

  /// `adjustSelection` (`data-editor.tsx:2854-3019`).
  ///
  /// `direction` entries mirror upstream's `0 | 1 | -1 | 2 | -2` encoding.
  void _adjustSelection(
    (int, int) direction,
    GlideSelectionBehavior behavior,
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

    // `getSelectionRowLimits` defaults to the full table.
    const minRow = 0;
    final maxRowRaw = rows - 1;
    final maxRow = maxRowRaw + 1; // inclusive

    // Vertical first, in case new spans come in.
    if (y != 0) {
      switch (y) {
        case 2:
          bottom = maxRow;
          top = row;
          scrollTo?.call(
            GlideScrollTarget(0, bottom, axis: GlideScrollAxis.vertical),
          );
        case -2:
          top = minRow;
          bottom = row + 1;
          scrollTo?.call(
            GlideScrollTarget(0, top, axis: GlideScrollAxis.vertical),
          );
        case 1:
          if (top < row) {
            top++;
            scrollTo?.call(
              GlideScrollTarget(0, top, axis: GlideScrollAxis.vertical),
            );
          } else {
            bottom = math.min(maxRow, bottom + 1);
            scrollTo?.call(
              GlideScrollTarget(0, bottom, axis: GlideScrollAxis.vertical),
            );
          }
        case -1:
          if (bottom > row + 1) {
            bottom--;
            scrollTo?.call(
              GlideScrollTarget(0, bottom, axis: GlideScrollAxis.vertical),
            );
          } else {
            top = math.max(minRow, top - 1);
            scrollTo?.call(
              GlideScrollTarget(0, top, axis: GlideScrollAxis.vertical),
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
          GlideScrollTarget(
            right - 1 - rowMarkerOffset,
            0,
            axis: GlideScrollAxis.horizontal,
          ),
        );
      } else if (x == -2) {
        left = rowMarkerOffset;
        right = col + 1;
        scrollTo?.call(
          GlideScrollTarget(
            left - rowMarkerOffset,
            0,
            axis: GlideScrollAxis.horizontal,
          ),
        );
      } else {
        var disallowed = const <int>[];
        final getCells = getCellsForSelection;
        if (getCells != null) {
          final cells = getCells(
            GlideRectangle(
              x: left.toDouble(),
              y: top.toDouble(),
              width: (right - left - rowMarkerOffset).toDouble(),
              height: (bottom - top).toDouble(),
            ),
          );
          if (cells != null) disallowed = glideGetSpanStops(cells);
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
                GlideScrollTarget(
                  left,
                  0,
                  axis: GlideScrollAxis.horizontal,
                ),
              );
            }
          }
          if (!done) {
            right = math.min(columnCount, right + 1);
            scrollTo?.call(
              GlideScrollTarget(
                right - 1 - rowMarkerOffset,
                0,
                axis: GlideScrollAxis.horizontal,
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
                GlideScrollTarget(
                  right - rowMarkerOffset,
                  0,
                  axis: GlideScrollAxis.horizontal,
                ),
              );
            }
          }
          if (!done) {
            left = math.max(rowMarkerOffset, left - 1);
            scrollTo?.call(
              GlideScrollTarget(
                left - rowMarkerOffset,
                0,
                axis: GlideScrollAxis.horizontal,
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
        range: GlideRectangle(
          x: left.toDouble(),
          y: top.toDouble(),
          width: (right - left).toDouble(),
          height: (bottom - top).toDouble(),
        ),
      ),
      expand: true,
      append: false,
      trigger: GlideSelectionTrigger.keyboardSelect,
    );
  }

  /// Set by `onKeyDown` when a printable key should open the editor on the
  /// current cell (`data-editor.tsx:3523-3530`, upstream `reselect`).
  void Function(GlideRectangle bounds, String key)? onTypeToEdit;

  /// `onKeyDown` (`data-editor.tsx:3484-3545`).
  ///
  /// Returns true when the event was consumed.
  bool handleKeyDown(GlideGridKeyArgs event, {required bool editOnType}) {
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
    final target = getCellContent(
      GlideItem(col - rowMarkerOffset, clampInt(row, 0, rows - 1)),
    );
    if (!glideIsEditableGridCell(target) ||
        target.kind == GlideCellKind.boolean) {
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
      GlideItem(col - rowMarkerOffset, row),
      GlideKeyboardCellActivation(key),
    );
    onTypeToEdit?.call(bounds, key);
    event.stopPropagation();
    event.preventDefault();
    return true;
  }

  /// `deleteRange` (`data-editor.tsx:3148-3184`).
  void deleteRange(GlideRectangle r) {
    final editList = <GlideEditListItem>[];
    for (var x = r.x.toInt(); x < r.x + r.width; x++) {
      for (var y = r.y.toInt(); y < r.y + r.height; y++) {
        final cellValue = getCellContent(
          GlideItem(x - rowMarkerOffset, y),
        );
        if (!cellValue.allowOverlay &&
            cellValue.kind != GlideCellKind.boolean) {
          continue;
        }

        GlideGridCell? newVal;
        final renderer = getCellRenderer(cellValue);
        newVal = renderer?.onDelete(cellValue);
        if (newVal == null && renderer != null) {
          // `editor?.deletedValue?.(cellValue)` (`data-editor.tsx:3166`).
          final provider = renderer.provideEditor(
            cellValue,
            GlideItem(x - rowMarkerOffset, y),
          );
          if (provider is GlideObjectEditor) {
            newVal = provider.deletedValue?.call(cellValue);
          }
        }

        if (newVal != null && glideIsEditableGridCell(newVal)) {
          editList.add(
            GlideEditListItem(location: GlideItem(x, y), value: newVal),
          );
        }
      }
    }
    onCellsEdited?.call(editList);
  }
}

