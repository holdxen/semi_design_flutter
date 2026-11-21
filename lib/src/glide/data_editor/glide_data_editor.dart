// Port of `packages/core/src/data-editor/data-editor.tsx`.
//
// Scope of this file: the selection/overlay/keyboard/clipboard spine of the
// editor — `mangledOnCellsEdited` (:1207), `setOverlaySimple` (:1428),
// `reselect` (:1445), `handleMaybeClick`/`onMouseUp` (:2367-2541),
// `highlightRegions` (:1240-1305) and the wiring of `GlideKeyHandler`,
// `GlideDataEditorSelection` and the overlay editor.
//
// Not ported yet (all `data-editor` chrome layered on the grid):
// row markers, the trailing blank row, column resizing, drag and drop, fill
// handle dragging, autoscroll and `use-column-sizer`.
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../cells/glide_cell_registry.dart';
import '../cells/glide_cell_types.dart';
import '../common/glide_math.dart';
import '../common/glide_utils.dart';
import '../internal/data_grid/glide_data_grid.dart';
import '../internal/data_grid/glide_event_args.dart';
import '../internal/data_grid/glide_selection_behavior.dart';
import '../internal/data_grid/render/glide_draw_grid_arg.dart';
import '../internal/data_grid_overlay_editor/glide_data_grid_overlay_editor.dart';
import '../internal/scrolling_data_grid/glide_autoscroll.dart';
import '../internal/scrolling_data_grid/glide_scrolling_data_grid.dart';
import 'glide_clipboard.dart';
import 'glide_data_editor_fns.dart';
import 'glide_handle_select.dart';
import 'glide_column_sizer.dart';
import 'glide_key_handler.dart';
import 'glide_keybindings.dart';

/// `DataGridProps` subset the editor owns (`data-editor.tsx`).
@immutable
class GlideDataEditorProps {
  const GlideDataEditorProps({
    required this.columns,
    required this.rows,
    required this.getCellContent,
    required this.theme,
    this.onKeyDown,
    this.onKeyUp,
    this.onCellsEdited,
    this.onCellEdited,
    this.rowHeight = const GlideRowHeight.fixed(32),
    this.headerHeight = 36,
    this.groupHeaderHeight = 36,
    this.enableGroups = false,
    this.freezeColumns = 0,
    this.freezeTrailingRows = 0,
    this.verticalBorder = _alwaysTrue,
    this.drawFocusRing = true,
    this.rangeSelect = GlideRangeSelect.rect,
    this.columnSelect = GlideSelectMode.multi,
    this.rowSelect = GlideSelectMode.multi,
    this.rangeSelectionBlending = GlideSelectionBlending.exclusive,
    this.columnSelectionBlending = GlideSelectionBlending.exclusive,
    this.rowSelectionBlending = GlideSelectionBlending.exclusive,
    this.rangeSelectionColumnSpanning = true,
    this.columnSelectionModeMulti = false,
    this.keybindings,
    this.editOnType = true,
    this.copyHeaders = false,
    this.cellActivationBehavior = GlideCellActivationBehavior.secondClick,
    this.getCellsForSelection,
    this.coercePasteValue,
    this.onPaste,
    this.onItemHovered,
    this.onFillPattern,
    this.onColumnResize,
    this.onColumnResizeStart,
    this.onColumnResizeEnd,
    this.onColumnMoved,
    this.onColumnProposeMove,
    this.lockColumns = 0,
    this.resizeIndicator = GlideResizeIndicator.full,
    this.onGridSelectionChange,
    this.onSelectionCleared,
    this.onDelete,
    this.onCellActivated,
    this.onCellClicked,
    this.onCellContextMenu,
    this.onHeaderClicked,
    this.getRowThemeOverride,
    this.getGroupDetails,
    this.highlightRegions,
    this.fillHandle,
    this.allowedFillDirections = GlideFillHandleDirection.orthogonal,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 500,
    this.overscrollY = 0,
    this.smoothScrollX = false,
    this.smoothScrollY = false,
    this.showSearch = false,
    this.rendererLookup,
  });

  static bool _alwaysTrue(int col) => true;

  final List<GlideGridColumn> columns;
  final int rows;
  final GlideGridCell Function(GlideItem cell, [bool? forceStrict])
  getCellContent;

  /// `onKeyDownIn` (`data-editor.tsx:3487`) — call `cancel()` to swallow the
  /// event before the built-in keybindings run.
  final void Function(GlideGridKeyArgs event)? onKeyDown;
  final void Function(GlideGridKeyArgs event)? onKeyUp;

  /// `onCellsEdited` returning `true` suppresses the per-cell
  /// `onCellEdited` callbacks (`data-editor.tsx:1216-1220`).
  final bool Function(List<GlideEditListItem> items)? onCellsEdited;
  final void Function(GlideItem location, GlideGridCell value)? onCellEdited;

  final GlideTheme theme;
  final GlideRowHeight rowHeight;
  final double headerHeight;
  final double groupHeaderHeight;
  final bool enableGroups;
  final int freezeColumns;
  final int freezeTrailingRows;
  final bool Function(int col) verticalBorder;
  final bool drawFocusRing;

  final GlideRangeSelect rangeSelect;
  final GlideSelectMode columnSelect;
  final GlideSelectMode rowSelect;
  final GlideSelectionBlending rangeSelectionBlending;
  final GlideSelectionBlending columnSelectionBlending;
  final GlideSelectionBlending rowSelectionBlending;
  final bool rangeSelectionColumnSpanning;
  final bool columnSelectionModeMulti;

  final GlideKeybinds? keybindings;
  final bool editOnType;
  final bool copyHeaders;
  final GlideCellActivationBehavior cellActivationBehavior;

  final GlideGetCellsForSelection? getCellsForSelection;
  final GlideCoercePasteValue? coercePasteValue;
  final GlidePasteCallback? onPaste;

  final void Function(GlideGridMouseArgs args)? onItemHovered;
  final void Function(GlideGridSelection selection)? onGridSelectionChange;
  final void Function()? onSelectionCleared;
  final GlideDeleteCallback? onDelete;
  final void Function(GlideItem location, GlideCellActivation activation)?
  onCellActivated;
  final void Function(GlideItem location, GlideCellClickedEventArgs args)?
  onCellClicked;
  final void Function(GlideItem location, GlideCellClickedEventArgs args)?
  onCellContextMenu;
  final void Function(int col, GlideGridHeaderMouseArgs args)?
  onHeaderClicked;

  final GlideGetRowThemeOverride? getRowThemeOverride;
  final GlideGroupDetails Function(String group)? getGroupDetails;
  final List<GlideHighlight>? highlightRegions;

  /// `fillHandle` (`data-editor.tsx:150`): null disables the handle.
  final GlideFillHandleConfig? fillHandle;

  /// `allowedFillDirections` (`data-editor.tsx:868`).
  final GlideFillHandleDirection allowedFillDirections;

  /// `onColumnResize` / `...Start` / `...End` (`data-grid-dnd.tsx:40-70`).
  final void Function(GlideGridColumn column, double newSize, int colIndex,
      double newSizeWithGrow)?
  onColumnResize;
  final void Function(GlideGridColumn column, double newSize, int colIndex,
      double newSizeWithGrow)?
  onColumnResizeStart;
  final void Function(GlideGridColumn column, double newSize, int colIndex,
      double newSizeWithGrow)?
  onColumnResizeEnd;

  /// `minColumnWidthIn`/`maxColumnWidthIn` (`data-editor.tsx:862-863`).
  final double minColumnWidth;
  final double maxColumnWidth;

  /// `onColumnMoved` / `onColumnProposeMove` (`data-grid-dnd.tsx:44-57`).
  /// Returning false from [onColumnProposeMove] rejects the move.
  final void Function(int from, int to)? onColumnMoved;
  final bool? Function(int from, int to)? onColumnProposeMove;

  /// `lockColumns` (`data-grid-dnd.tsx:133`): columns before this index are
  /// not drop targets.
  final int lockColumns;

  final GlideResizeIndicator resizeIndicator;

  /// `onFillPattern` (`data-editor.tsx:2258`): called before the fill runs;
  /// call `preventDefault()` to cancel it.
  final void Function(GlideFillPatternArgs args)? onFillPattern;

  final double overscrollY;
  final bool smoothScrollX;
  final bool smoothScrollY;
  final bool showSearch;
  final GlideRendererLookup? rendererLookup;
}

/// `GlideDataEditor`: `DataGrid` + selection + overlay editor + clipboard.
class GlideDataEditor extends StatefulWidget {
  const GlideDataEditor({super.key, required this.props});

  final GlideDataEditorProps props;

  @override
  State<GlideDataEditor> createState() => _GlideDataEditorState();
}

class _GlideDataEditorState extends State<GlideDataEditor>
    with TickerProviderStateMixin {
  final GlideDataGridController _gridController = GlideDataGridController();

  late GlideGridSelection _selection;
  late GlideDataEditorSelection _selectionState;

  int _cellXOffset = 0;
  int _cellYOffset = 0;
  double _translateX = 0;
  double _translateY = 0;
  double _scrollY = 0;
  bool _focused = false;

  _OverlayState? _overlay;

  /// `lastMouseDownData` (`data-editor.tsx:2091`).
  ({int button, int time, GlideItem location})? _mouseDownData;

  /// `lastMouseSelectLocation` (`data-editor.tsx:2089`).
  GlideItem? _lastMouseSelectLocation;

  /// `mouseState.previousSelection` (`data-editor.tsx:2120`): the selection
  /// as it was *before* the press, which is what second-click activation
  /// compares against.
  GlideGridSelection? _previousSelection;

  /// `hoveredRef` (`data-editor.tsx:2729`).
  GlideGridMouseArgs? _hoveredArgs;

  /// `scrollDir` (`data-editor.tsx:2243`).
  (int, int)? _scrollDir;

  /// `mouseState.fillHandle` (`data-editor.tsx:2120`).
  bool _fillHandlePressed = false;

  /// `fillHighlightRegion` (`data-editor.tsx:1227`).
  GlideRectangle? _fillHighlightRegion;

  /// `resizeCol` / `resizeColStartX` (`data-grid-dnd.tsx:90-91`).
  int? _resizeCol;
  double? _resizeColStartX;
  double _lastResizeWidth = -1;

  /// `dragCol` / `dropCol` / `dragStartX` / `dragColActive`
  /// (`data-grid-dnd.tsx:87-93`).
  int? _dragCol;
  int? _dropCol;
  double? _dragStartX;
  bool _dragColActive = false;

  bool get _canDragCol => widget.props.onColumnMoved != null;

  /// `visibleRegionRef` (`data-editor.tsx:2831`).
  GlideVisibleRegion? _visible;

  late final Ticker _autoscrollTicker;
  Duration _lastTick = Duration.zero;
  final GlideAutoscroll _autoscroll = GlideAutoscroll();

  @override
  void initState() {
    super.initState();
    _selection = GlideGridSelection.empty;
    _selectionState = _makeSelectionState();
    _autoscrollTicker = createTicker(_onAutoscrollTick);
  }

  @override
  void dispose() {
    _autoscrollTicker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GlideDataEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.props.columns != widget.props.columns ||
        oldWidget.props.rows != widget.props.rows) {
      setState(() => _selectionState = _makeSelectionState());
    }
  }

  GlideDataEditorSelection _makeSelectionState() => GlideDataEditorSelection(
    behaviorConfig: GlideBehaviorConfig(
      rangeBehavior: widget.props.rangeSelectionBlending,
      columnBehavior: widget.props.columnSelectionBlending,
      rowBehavior: widget.props.rowSelectionBlending,
      rangeSelect: widget.props.rangeSelect,
      rangeSelectionColumnSpanning: widget.props.rangeSelectionColumnSpanning,
      columnSelectEnabled: widget.props.columnSelect != GlideSelectMode.none,
      columnSelectionModeMulti: widget.props.columnSelectionModeMulti,
    ),
    rows: widget.props.rows,
    rowSelectMulti: widget.props.rowSelect == GlideSelectMode.multi,
    columnSelectMulti: widget.props.columnSelect == GlideSelectMode.multi,
    initial: _selection,
  );

  GlideItem _locationOf(GlideGridMouseArgs args) => switch (args) {
    GlideGridCellMouseArgs a => a.location,
    GlideGridHeaderMouseArgs a => a.location,
    GlideGridGroupHeaderMouseArgs a => a.location,
    GlideGridOutOfBoundsMouseArgs a => a.location,
  };

  GlideRendererLookup get _renderers =>
      widget.props.rendererLookup ?? GlideDefaultRendererLookup();

  // -------------------------------------------------------------------------
  // Theme and content
  // -------------------------------------------------------------------------

  /// `themeForCell` (`data-editor.tsx`).
  GlideTheme _themeForCell(GlideGridCell cell, GlideItem location) {
    final p = widget.props;
    final column = location.col < p.columns.length
        ? p.columns[location.col]
        : null;
    var theme = p.theme;
    final group = column?.group;
    final groupOverride = group == null || p.getGroupDetails == null
        ? null
        : p.getGroupDetails!(group).overrideTheme;
    theme = theme.merge([
      groupOverride?.applyTo(theme),
      column?.themeOverride?.applyTo(theme),
      p.getRowThemeOverride?.call(location.row)?.applyTo(theme),
      cell.themeOverride?.applyTo(theme),
    ]);
    return theme;
  }

  GlideGridCell _getCellContent(GlideItem item, [bool? forceStrict]) =>
      widget.props.getCellContent(item, forceStrict);

  /// `mangledOnCellsEdited` (`data-editor.tsx:1207-1225`). Row markers are
  //  not ported, so the mangle is a pass-through today.
  bool _onCellsEdited(List<GlideEditListItem> items) {
    if (items.isEmpty) return true;
    final p = widget.props;
    final r = p.onCellsEdited?.call(items);
    if (r != true) {
      for (final i in items) {
        p.onCellEdited?.call(i.location, i.value);
      }
    }
    return r ?? false;
  }

  // -------------------------------------------------------------------------
  // Selection
  // -------------------------------------------------------------------------

  void _setGridSelection(GlideGridSelection newVal, bool expand) {
    var v = newVal;
    if (expand) {
      v = glideExpandSelection(
        newVal: v,
        getCellsForSelection: widget.props.getCellsForSelection,
        rowMarkerOffset: 0,
        allowPartial: false,
      );
    }
    setState(() {
      _selection = v;
      _selectionState.selection = v;
    });
    widget.props.onGridSelectionChange?.call(v);
  }

  GlideKeyHandler _makeKeyHandler() => GlideKeyHandler(
    keys: glideKeysWithDefaults(widget.props.keybindings),
    selection: _selection,
    setGridSelection: _setGridSelection,
    columnCount: widget.props.columns.length,
    rows: widget.props.rows,
    rowMarkerOffset: 0,
    overlayOpen: _overlay != null,
    columnSelect: widget.props.columnSelect,
    rowSelect: widget.props.rowSelect,
    rangeSelect: widget.props.rangeSelect,
    visibleRegion: GlideRectangle(
      x: _cellXOffset.toDouble(),
      y: _cellYOffset.toDouble(),
      width: math.max(0, widget.props.columns.length - _cellXOffset).toDouble(),
      height: math.max(1, _visibleRowCount).toDouble(),
    ),
    getCellContent: _getCellContent,
    getCellRenderer: _renderers.forCell,
    rangeBehavior: widget.props.rangeSelectionBlending,
    columnBehavior: widget.props.columnSelectionBlending,
    rowBehavior: widget.props.rowSelectionBlending,
    rangeSelectionColumnSpanning: widget.props.rangeSelectionColumnSpanning,
    getCellsForSelection: widget.props.getCellsForSelection,
    onSelectionCleared: widget.props.onSelectionCleared,
    onDelete: widget.props.onDelete,
    onCellsEdited: _onCellsEdited,
    onCellActivated: (location, activation) {
      widget.props.onCellActivated?.call(location, activation);
      if (activation is GlideKeyboardCellActivation) {
        _reselectForKeyboard(location, activation);
      }
    },
    fillDown: _fillDown,
    fillRight: _fillRight,
    scrollTo: _scrollTo,
  )
    ..onOverlayClosed = _closeOverlay
    ..onTypeToEdit = (bounds, key) {
    _reselect(
      bounds,
      const GlideKeyboardCellActivation(null),
      initialValue: key,
    );
  };

  // -------------------------------------------------------------------------
  // Overlay
  // -------------------------------------------------------------------------

  /// `setOverlaySimple` (`data-editor.tsx:1428-1443`).
  void _setOverlay(_OverlayState value) {
    setState(() {
      _overlay = _OverlayState(
        target: value.target,
        cell: value.cell,
        content: value.content,
        theme: _themeForCell(value.content, value.cell),
        initialValue: value.initialValue,
        highlight: value.highlight,
        forceEditMode: value.forceEditMode,
        activation: value.activation,
      );
    });
    // The overlay's own input takes focus; the grid gets it back when the
    // editor closes (`_finishEditing`).
  }

  void _closeOverlay() {
    if (_overlay != null) setState(() => _overlay = null);
  }

  /// `reselect` (`data-editor.tsx:1445-1497`).
  void _reselect(
    GlideRectangle bounds,
    GlideCellActivation activation, {
    String? initialValue,
  }) {
    final current = _selection.current;
    if (current == null) return;

    final location = current.cell;
    final c = _getCellContent(location);

    if (c.kind != GlideCellKind.boolean && c.allowOverlay) {
      var content = c;
      if (initialValue != null) {
        content = switch (content) {
          GlideNumberCell value => value.copyWith(
            data: _parseFloat(initialValue),
            displayData: initialValue,
          ),
          GlideTextCell value => value.copyWith(data: initialValue,
              displayData: initialValue),
          GlideMarkdownCell value => value.copyWith(data: initialValue),
          GlideUriCell value => value.copyWith(
            data: initialValue,
            displayData: initialValue,
          ),
          _ => content,
        };
      }

      _setOverlay(
        _OverlayState(
          target: bounds,
          content: content,
          cell: location,
          initialValue: initialValue,
          highlight: initialValue == null,
          forceEditMode: initialValue != null,
          activation: activation,
          theme: _themeForCell(content, location),
        ),
      );
    } else if (c.kind == GlideCellKind.boolean &&
        activation is GlideKeyboardCellActivation &&
        !c.isReadonly) {
      _onCellsEdited([
        GlideEditListItem(
          location: location,
          value: (c as GlideBooleanCell).copyWith(
            data: toggleBoolean(c.data),
          ),
        ),
      ]);
    }
  }

  /// Keyboard Enter/click activation on the already-selected cell.
  void _reselectForKeyboard(GlideItem location, GlideCellActivation activation) {
    final bounds = _gridController.getBounds(location.col, location.row);
    if (bounds == null) return;
    _reselect(bounds, activation);
  }

  static double _parseFloat(String value) {
    if (value == '-') return -0.0;
    return double.tryParse(value) ?? 0.0;
  }

  void _finishEditing(GlideGridCell? newCell, GlideEditorMovement movement) {
    final overlay = _overlay;
    setState(() => _overlay = null);
    if (overlay != null &&
        newCell != null &&
        glideIsEditableGridCell(newCell)) {
      _onCellsEdited([
        GlideEditListItem(location: overlay.cell, value: newCell),
      ]);
    }
    _gridController.focus();

    if (movement.col == 0 && movement.row == 0) return;
    final cell = overlay?.cell ?? _selection.current?.cell;
    if (cell == null) return;
    _updateSelectedCell(
      cell.col + movement.col,
      cell.row + movement.row,
    );
  }

  void _updateSelectedCell(int col, int row) {
    final handler = _makeKeyHandler();
    handler.updateSelectedCell(
      col,
      row,
      fromEditingTrailingRow: false,
      freeMove: false,
    );
    if (handler.selection != _selection) _setGridSelection(handler.selection, false);
  }

  // -------------------------------------------------------------------------
  // Fill (`data-editor.tsx:2245-2330`)
  // -------------------------------------------------------------------------

  /// `fillPattern` (`data-editor.tsx:2245-2296`).
  void _fillPattern(
    GlideGridSelection previousSelection,
    GlideGridSelection currentSelection,
  ) {
    final getCells = widget.props.getCellsForSelection;
    final patternRange = previousSelection.current?.range;
    final currentRange = currentSelection.current?.range;
    if (patternRange == null ||
        currentRange == null ||
        getCells == null) {
      return;
    }

    final onFillPattern = widget.props.onFillPattern;
    if (onFillPattern != null) {
      var canceled = false;
      onFillPattern(
        GlideFillPatternArgs(
          patternSource: patternRange,
          fillDestination: currentRange,
          preventDefault: () => canceled = true,
        ),
      );
      if (canceled) return;
    }

    final pattern = getCells(patternRange);
    if (pattern == null || pattern.isEmpty) return;

    final edits = <GlideEditListItem>[];
    for (var x = 0; x < currentRange.width; x++) {
      for (var y = 0; y < currentRange.height; y++) {
        final item = GlideItem(
          currentRange.x.toInt() + x,
          currentRange.y.toInt() + y,
        );
        if (itemIsInRect(item, patternRange)) continue;
        final patternCell =
            pattern[y % patternRange.height.toInt()]
                [x % patternRange.width.toInt()];
        if (glideIsInnerOnlyCell(patternCell) ||
            !glideIsReadWriteCell(patternCell)) {
          continue;
        }
        edits.add(GlideEditListItem(location: item, value: patternCell));
      }
    }
    if (edits.isNotEmpty) _onCellsEdited(edits);
  }

  /// `fillDown` (`data-editor.tsx:2315-2330`): the first row of the range is
  /// the pattern, the whole range is the destination.
  void _fillDown() {
    final current = _selection.current;
    if (current == null || current.range.height <= 1) return;
    _fillPattern(
      _selection.copyWith(
        current: current.copyWith(
          range: current.range.copyWith(height: 1),
        ),
      ),
      _selection,
    );
  }

  void _fillRight() {
    final current = _selection.current;
    if (current == null || current.range.width <= 1) return;
    _fillPattern(
      _selection.copyWith(
        current: current.copyWith(
          range: current.range.copyWith(width: 1),
        ),
      ),
      _selection,
    );
  }

  // -------------------------------------------------------------------------
  // scrollTo (`data-editor.tsx:1524-1674`)
  // -------------------------------------------------------------------------

  void _scrollTo(GlideScrollTarget target) {
    final bounds = _gridController.getBounds(target.col, target.row);
    if (bounds == null || bounds.width == 0 || bounds.height == 0) return;

    var frozenWidth = 0.0;
    for (var i = 0; i < widget.props.freezeColumns; i++) {
      frozenWidth += widget.props.columns[i].width ?? 0;
    }
    final trailingHeight = widget.props.rowHeight.trailingHeight(
      widget.props.rows,
      widget.props.freezeTrailingRows,
    );

    var sLeft = frozenWidth;
    var sRight = _viewportWidth;
    var sTop = _headerHeight;
    var sBottom = _viewportHeight - trailingHeight;

    var scrollX = 0.0;
    var scrollY = 0.0;
    if (sLeft > bounds.x) {
      scrollX = bounds.x - sLeft;
    } else if (sRight < bounds.right) {
      scrollX = bounds.right - sRight;
    }
    if (sTop > bounds.y) {
      scrollY = bounds.y - sTop;
    } else if (sBottom < bounds.bottom) {
      scrollY = bounds.bottom - sBottom;
    }

    final axis = target.axis;
    if (axis == GlideScrollAxis.vertical ||
        target.col < widget.props.freezeColumns) {
      scrollX = 0;
    } else if (axis == GlideScrollAxis.horizontal ||
        target.row >= widget.props.rows - widget.props.freezeTrailingRows) {
      scrollY = 0;
    }

    if (scrollX == 0 && scrollY == 0) return;
    setState(() {
      _scrollX = clampDouble(_scrollX + scrollX, 0, _maxScrollX);
      _scrollY = clampDouble(_scrollY + scrollY, 0, _maxScrollY);
    });
    _applyScroll();
  }

  // -------------------------------------------------------------------------
  // Column resizing (`internal/data-grid-dnd/data-grid-dnd.tsx:85-330`)
  // -------------------------------------------------------------------------

  bool get _canResize =>
      widget.props.onColumnResize != null ||
      widget.props.onColumnResizeEnd != null ||
      widget.props.onColumnResizeStart != null;

  /// `offsetColumnSize` (`data-grid-dnd.tsx:85-87`).
  double _offsetColumnSize(int col, double width) {
    final column = widget.props.columns[col];
    return clampDouble(
      (width - (column.extension?.growOffset ?? 0)).roundToDouble(),
      widget.props.minColumnWidth.ceilToDouble(),
      widget.props.maxColumnWidth.floorToDouble(),
    );
  }

  void _detectResizeStart(GlideGridMouseArgs args) {
    final columns = widget.props.columns;
    if (args.kind == GlideGridCellKind.outOfBounds && args.isEdge) {
      final bounds = _gridController.getBounds(
        columns.length - 1,
        GlideItem.headerRow,
      );
      if (bounds != null) {
        _resizeColStartX = bounds.x;
        _resizeCol = columns.length - 1;
      }
      return;
    }
    if (args.kind != GlideGridCellKind.header) return;
    final header = args as GlideGridHeaderMouseArgs;
    final col = header.location.col;
    if (col < widget.props.lockColumns || col < 0 || col >= columns.length) {
      return;
    }

    if (!header.isEdge) {
      // `else if (kind === "header" && canDragCol)` (`data-grid-dnd.tsx:168`).
      if (_canDragCol) {
        _dragStartX = header.bounds.x;
        _dragCol = col;
        _dropCol = null;
        _dragColActive = false;
      }
      return;
    }
    if (!_canResize) return;

    _resizeColStartX = header.bounds.x;
    _resizeCol = col;
    final width = header.bounds.width;
    widget.props.onColumnResizeStart?.call(
      columns[col],
      width,
      col,
      width + (columns[col].extension?.growOffset ?? 0).toDouble(),
    );
  }

  /// Window `mousemove` (`data-grid-dnd.tsx:299-330`).
  void _onPointerMoveRaw(Offset position) {
    // `onMouseMove` (`data-grid-dnd.tsx:299-330`): the drag arms only after
    // the pointer travels 20px, and a pending drag swallows resize motion.
    final dragCol = _dragCol;
    final dragStartX = _dragStartX;
    if (dragCol != null && dragStartX != null) {
      if ((position.dx - dragStartX).abs() > 20 && !_dragColActive) {
        setState(() => _dragColActive = true);
      }
    } else if (_dragRowActive) {
      // Row dragging lives with the row-marker port.
    } else {
      _resizeDrag(position);
    }
  }

  bool get _dragRowActive => false;

  void _resizeDrag(Offset position) {
    final col = _resizeCol;
    final startX = _resizeColStartX;
    if (col == null || startX == null) return;
    if (col < 0 || col >= widget.props.columns.length) return;

    final newWidth = position.dx - startX;
    final column = widget.props.columns[col];
    final ns = _offsetColumnSize(col, newWidth);
    widget.props.onColumnResize?.call(
      column,
      ns,
      col,
      ns + (column.extension?.growOffset ?? 0).toDouble(),
    );
    _lastResizeWidth = newWidth;

    // Resizing a column that is part of a multi-column selection resizes the
    // whole selection (`data-grid-dnd.tsx:321-331`).
    final selected = _selection.columns;
    if (selected.firstIndex == col) {
      for (final c in selected.indices) {
        if (c == col) continue;
        if (c < 0 || c >= widget.props.columns.length) continue;
        final other = widget.props.columns[c];
        final s = _offsetColumnSize(c, _lastResizeWidth);
        widget.props.onColumnResize?.call(
          other,
          s,
          c,
          s + (other.extension?.growOffset ?? 0).toDouble(),
        );
      }
    }
  }

  /// `onMouseUpImpl`'s resize tail (`data-grid-dnd.tsx:222-255`).
  void _commitResize() {
    final col = _resizeCol;
    _resizeCol = null;
    _resizeColStartX = null;
    if (col == null || col < 0 || col >= widget.props.columns.length) {
      _lastResizeWidth = -1;
      return;
    }

    final columns = widget.props.columns;
    final column = columns[col];
    final ns = _offsetColumnSize(col, _lastResizeWidth);
    widget.props.onColumnResizeEnd?.call(
      column,
      ns,
      col,
      ns + (column.extension?.growOffset ?? 0).toDouble(),
    );

    final selected = _selection.columns;
    if (selected.hasIndex(col)) {
      for (final c in selected.indices) {
        if (c == col) continue;
        if (c < 0 || c >= columns.length) continue;
        final other = columns[c];
        final s = _offsetColumnSize(c, _lastResizeWidth);
        widget.props.onColumnResizeEnd?.call(
          other,
          s,
          c,
          s + (other.extension?.growOffset ?? 0).toDouble(),
        );
      }
    }
    _lastResizeWidth = -1;
  }

  /// `clearAll` (`data-grid-dnd.tsx:206-218`), reduced to the column-drag
  /// fields the port has.
  void _clearDragState() {
    _dragCol = null;
    _dropCol = null;
    _dragStartX = null;
    _dragColActive = false;
  }

  /// `normalSizeColumn` (`data-editor.tsx:2193-2241`).
  void _normalSizeColumn(int col) {
    final p = widget.props;
    final getCells = p.getCellsForSelection;
    final onResize = p.onColumnResize;
    if (getCells == null || onResize == null) return;
    if (col < 0 || col >= p.columns.length) return;

    final start = _visible?.y ?? 0;
    final height = math.min(
      _visible?.height ?? 1,
      math.max(1, p.rows - start),
    );
    final cells = getCells(
      GlideRectangle(
        x: col.toDouble(),
        y: start.toDouble(),
        width: 1,
        height: height.toDouble(),
      ),
    );
    if (cells == null) return;

    final newWidth = glideMeasureColumn(
      theme: p.theme,
      column: p.columns[col],
      colIndex: col,
      selectedData: cells,
      minColumnWidth: p.minColumnWidth,
      maxColumnWidth: p.maxColumnWidth,
      removeOutliers: false,
      getCellRenderer: _renderers.forCell,
      metrics: _metrics,
    );
    onResize(p.columns[col], newWidth, col, newWidth);
  }

  // -------------------------------------------------------------------------
  // Hover, drag selection and autoscroll
  //   (`data-editor.tsx:2728-2850`, `data-editor/use-autoscroll.ts`)
  // -------------------------------------------------------------------------

  void _onItemHovered(GlideGridMouseArgs args) {
    // `DataGridDnd.onItemHoveredImpl` (`data-grid-dnd.tsx:130-146`) runs first
    // and only forwards to the editor when no drag or resize is in flight.
    final hoveredCol = _locationOf(args).col;
    if (_dragCol != null &&
        _dropCol != hoveredCol &&
        hoveredCol >= widget.props.lockColumns) {
      setState(() {
        _dragColActive = true;
        _dropCol = hoveredCol;
      });
      return;
    }
    if (_dragColActive || _resizeCol != null) return;

    if (glideMouseArgsAreEqual(args, _hoveredArgs)) return;
    _hoveredArgs = args;

    // `mouseState !== undefined` upstream; `_previousSelection` is only set
    // for presses that reached `setMouseState`.
    final dragging = _previousSelection != null;

    if (dragging &&
        args.buttons != 0 &&
        _fillHandlePressed &&
        _previousSelection?.current != null) {
      // `mouseState.fillHandle === true` (`data-editor.tsx:2765-2769`).
      final prevRange = _previousSelection!.current!.range;
      final hovered = _locationOf(args);
      final row = math.min(hovered.row, widget.props.rows - 1);
      final rect = getClosestRect(
        prevRange,
        hovered.col,
        row,
        widget.props.allowedFillDirections,
      );
      if (rect != _fillHighlightRegion) {
        setState(() => _fillHighlightRegion = rect);
      }
    } else if (dragging &&
        args.buttons != 0 &&
        _selection.current != null &&
        (widget.props.rangeSelect == GlideRangeSelect.rect ||
            widget.props.rangeSelect == GlideRangeSelect.multiRect)) {
      _dragSelect(args);
    }

    _updateScrollDir(args);
    widget.props.onItemHovered?.call(args);
  }

  /// The rect-drag branch of `onItemHoveredImpl` (`data-editor.tsx:2749-2805`).
  void _dragSelect(GlideGridMouseArgs args) {
    final current = _selection.current!;
    final selectedCol = current.cell.col;
    final selectedRow = current.cell.row;
    final hovered = _locationOf(args);
    var col = hovered.col;
    var row = hovered.row;

    if (row < 0) row = _cellYOffset;
    col = math.max(col, 0);

    final deltaX = col - selectedCol;
    final deltaY = row - selectedRow;
    final newRange = GlideRectangle(
      x: (deltaX >= 0 ? selectedCol : col).toDouble(),
      y: (deltaY >= 0 ? selectedRow : row).toDouble(),
      width: (deltaX.abs() + 1).toDouble(),
      height: (deltaY.abs() + 1).toDouble(),
    );

    _selectionState.selection = _selection;
    _selectionState.createBehavior().setCurrent(
      value: (cell: current.cell, range: newRange),
      expand: true,
      append: false,
      trigger: GlideSelectionTrigger.drag,
    );
    if (_selectionState.selection != _selection) {
      _setGridSelection(_selectionState.selection, true);
    }
  }

  /// `setScrollDir` (`data-editor.tsx:2556-2562`): only scroll while a
  /// button is held.
  void _updateScrollDir(GlideGridMouseArgs args) {
    final (x, y) = args.scrollEdge;
    final mouseDown = _mouseDownData;
    final next = mouseDown == null ? null : (x, y);
    if (next == _scrollDir) return;
    setState(() => _scrollDir = next);
    _autoscroll.setDirection(next?.$1 ?? 0, next?.$2 ?? 0);
    _setAutoscrollActive(next != null && next != (0, 0));
  }

  void _setAutoscrollActive(bool active) {
    if (active && !_autoscrollTicker.isActive) {
      _lastTick = Duration.zero;
      _autoscrollTicker.start();
    } else if (!active && _autoscrollTicker.isActive) {
      _autoscrollTicker.stop();
      _autoscroll.setDirection(0, 0);
    }
  }

  void _onAutoscrollTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dtMs =
        (elapsed - _lastTick).inMicroseconds / 1000.0; // ignore: avoid_multiple_declarations
    _lastTick = elapsed;

    final (dx, dy) = _autoscroll.advance(dtMs);
    if (dx == 0 && dy == 0) return;
    setState(() {
      _scrollX = clampDouble(_scrollX + dx, 0, _maxScrollX);
      _scrollY = clampDouble(_scrollY + dy, 0, _maxScrollY);
    });
    _applyScroll();
    _adjustSelectionOnScroll();
  }

  /// `adjustSelectionOnScroll` (`data-editor.tsx:2826-2848`).
  void _adjustSelectionOnScroll() {
    final args = _hoveredArgs;
    if (args == null) return;
    final (xDir, yDir) = args.scrollEdge;
    if (xDir == 0 && yDir == 0) return;

    final visible = _visible;
    if (visible == null) return;
    final hovered = _locationOf(args);
    var col = hovered.col;
    var row = hovered.row;

    if (xDir == -1) {
      col = visible.x;
    } else if (xDir == 1) {
      col = visible.x + visible.width;
    }
    if (yDir == -1) {
      row = math.max(0, visible.y);
    } else if (yDir == 1) {
      row = math.min(widget.props.rows - 1, visible.y + visible.height);
    }

    col = clampInt(col, 0, widget.props.columns.length - 1);
    row = clampInt(row, 0, widget.props.rows - 1);

    _onItemHovered(_withLocation(args, col, row));
  }

  /// Rebuilds [args] with a different `location`, mirroring
  /// `onItemHoveredImpl({...args, location})`.
  GlideGridMouseArgs _withLocation(GlideGridMouseArgs args, int col, int row) {
    final location = GlideItem(col, row);
    return switch (args) {
      GlideGridCellMouseArgs a => GlideGridCellMouseArgs(
        shiftKey: a.shiftKey,
        ctrlKey: a.ctrlKey,
        metaKey: a.metaKey,
        isTouch: a.isTouch,
        isLongTouch: a.isLongTouch,
        isDoubleClick: a.isDoubleClick,
        isEdge: a.isEdge,
        button: a.button,
        buttons: a.buttons,
        scrollEdge: a.scrollEdge,
        location: location,
        bounds: a.bounds,
        isFillHandle: a.isFillHandle,
        localEventX: a.localEventX,
        localEventY: a.localEventY,
      ),
      GlideGridHeaderMouseArgs a => GlideGridHeaderMouseArgs(
        shiftKey: a.shiftKey,
        ctrlKey: a.ctrlKey,
        metaKey: a.metaKey,
        isTouch: a.isTouch,
        isLongTouch: a.isLongTouch,
        isDoubleClick: a.isDoubleClick,
        isEdge: a.isEdge,
        button: a.button,
        buttons: a.buttons,
        scrollEdge: a.scrollEdge,
        location: location,
        bounds: a.bounds,
        group: a.group,
        localEventX: a.localEventX,
        localEventY: a.localEventY,
      ),
      GlideGridGroupHeaderMouseArgs a => GlideGridGroupHeaderMouseArgs(
        shiftKey: a.shiftKey,
        ctrlKey: a.ctrlKey,
        metaKey: a.metaKey,
        isTouch: a.isTouch,
        isLongTouch: a.isLongTouch,
        isDoubleClick: a.isDoubleClick,
        isEdge: a.isEdge,
        button: a.button,
        buttons: a.buttons,
        scrollEdge: a.scrollEdge,
        location: location,
        bounds: a.bounds,
        group: a.group,
        localEventX: a.localEventX,
        localEventY: a.localEventY,
      ),
      GlideGridOutOfBoundsMouseArgs a => GlideGridOutOfBoundsMouseArgs(
        shiftKey: a.shiftKey,
        ctrlKey: a.ctrlKey,
        metaKey: a.metaKey,
        isTouch: a.isTouch,
        isLongTouch: a.isLongTouch,
        isDoubleClick: a.isDoubleClick,
        isEdge: a.isEdge,
        button: a.button,
        buttons: a.buttons,
        scrollEdge: a.scrollEdge,
        location: location,
        isMaybeScrollbar: a.isMaybeScrollbar,
        region: a.region,
      ),
    };
  }

  // -------------------------------------------------------------------------
  // Mouse
  // -------------------------------------------------------------------------

  void _onMouseDown(GlideGridMouseArgs args) {
    if (args.button != 0 && args.button != 1) {
      _mouseDownData = null;
      return;
    }

    // `DataGridDnd.onMouseDownImpl` (`data-grid-dnd.tsx:149-186`) runs before
    // the editor's own handler.
    if (args.button == 0) {
      _detectResizeStart(args);
    }

    final isFillHandle = args is GlideGridCellMouseArgs && args.isFillHandle;
    _mouseDownData = (
      button: args.button,
      time: DateTime.now().millisecondsSinceEpoch,
      location: _locationOf(args),
    );

    // `!fh && kind !== "cell" && isEdge` returns before `setMouseState`, so a
    // resize press never arms selection dragging.
    if (!isFillHandle && args.kind != GlideGridCellKind.cell && args.isEdge) {
      return;
    }

    _previousSelection = _selection;
    _fillHandlePressed = isFillHandle;
    _lastMouseSelectLocation = null;

    if (!args.isTouch && args.button == 0 && !isFillHandle) {
      _handleSelect(args);
    } else if (!args.isTouch && args.button == 1) {
      _lastMouseSelectLocation = _locationOf(args);
    }
  }

  void _handleSelect(GlideGridMouseArgs args) {
    final outcome = _selectionState.handleSelect(
      args,
      getCellRenderer: _renderers.forCell,
      getCellContent: _getCellContent,
      themeForCell: _themeForCell,
    );
    if (outcome.onSelectionCleared) {
      widget.props.onSelectionCleared?.call();
    }
    if (_selectionState.selection != _selection) {
      _setGridSelection(_selectionState.selection, false);
    }
    if (outcome.clearOverlay) _closeOverlay();
    if (outcome.focus) _gridController.focus();
  }

  /// `handleMaybeClick` (`data-editor.tsx:2367-2435`).
  bool _handleMaybeClick(GlideGridCellMouseArgs a) {
    final p = widget.props;
    final mouseDown = _mouseDownData;
    final isValidClick = a.isTouch == true ||
        (mouseDown != null &&
            mouseDown.location.col == a.location.col &&
            mouseDown.location.row == a.location.row);

    if (isValidClick) {
      p.onCellClicked?.call(a.location, GlideCellClickedEventArgs(
        shiftKey: a.shiftKey,
        ctrlKey: a.ctrlKey,
        metaKey: a.metaKey,
        isTouch: a.isTouch,
        isLongTouch: a.isLongTouch,
        isDoubleClick: a.isDoubleClick,
        isEdge: a.isEdge,
        button: a.button,
        buttons: a.buttons,
        scrollEdge: a.scrollEdge,
        location: a.location,
        bounds: a.bounds,
        isFillHandle: a.isFillHandle,
        localEventX: a.localEventX,
        localEventY: a.localEventY,
        preventDefault: () {},
      ));
    }

    if (a.button == 1) return true;

    final c = _getCellContent(a.location);
    final r = _renderers.forCell(c);
    if (r != null && isValidClick) {
      var prevented = false;
      final newVal = r.onClick(
        GlideCellEventArgs(
          cell: c,
          posX: a.localEventX,
          posY: a.localEventY,
          bounds: a.bounds,
          location: a.location,
          theme: _themeForCell(c, a.location),
          preventDefault: () => prevented = true,
          isTouch: a.isTouch == true,
          isLongTouch: a.isLongTouch == true,
          shiftKey: a.shiftKey,
          ctrlKey: a.ctrlKey,
          metaKey: a.metaKey,
        ),
      );
      if (newVal != null &&
          !glideIsInnerOnlyCell(newVal) &&
          glideIsEditableGridCell(newVal)) {
        _onCellsEdited([
          GlideEditListItem(location: a.location, value: newVal),
        ]);
      }
      if (prevented) return false;
    }

    if (_selection.current == null) return false;

    final activationBehavior = c.activationBehaviorOverride ??
        p.cellActivationBehavior;
    var shouldActivate = false;
    switch (activationBehavior) {
      case GlideCellActivationBehavior.doubleClick ||
          GlideCellActivationBehavior.secondClick:
        final selected = _selection.current?.cell;
        final prev = _previousSelection?.current?.cell;
        if (selected == null || prev == null) break;
        final isClickOnSelected =
            a.location.col == selected.col &&
            a.location.col == prev.col &&
            a.location.row == selected.row &&
            a.location.row == prev.row;
        shouldActivate =
            isClickOnSelected &&
            (a.isDoubleClick == true ||
                p.cellActivationBehavior ==
                    GlideCellActivationBehavior.secondClick);
      case GlideCellActivationBehavior.singleClick:
        shouldActivate = true;
    }

    if (!shouldActivate) return false;

    final activation = GlidePointerCellActivation(
      a.isDoubleClick == true
          ? GlideCellActivationBehavior.doubleClick
          : activationBehavior,
      pointerType: a.isTouch == true ? 'touch' : 'mouse',
    );
    p.onCellActivated?.call(a.location, activation);
    _reselect(a.bounds, activation);
    return true;
  }

  void _onMouseUp(GlideGridMouseArgs args, bool isOutside) {
    if (isOutside) {
      _mouseDownData = null;
      _fillHandlePressed = false;
      return;
    }

    // `DataGridDnd.onMouseUpImpl` (`data-grid-dnd.tsx:220-266`).
    if (args.button == 0) {
      if (_resizeCol != null) _commitResize();

      final dragCol = _dragCol;
      final dropCol = _dropCol;
      if (dragCol != null &&
          dropCol != null &&
          dragCol != dropCol &&
          _dragColActive) {
        final propose = widget.props.onColumnProposeMove;
        if (propose == null || propose(dragCol, dropCol) != false) {
          widget.props.onColumnMoved?.call(dragCol, dropCol);
        }
      }
      _clearDragState();
    }

    // Fill handle release (`data-editor.tsx:2342-2358`).
    if (_fillHandlePressed) {
      final previous = _previousSelection;
      final highlight = _fillHighlightRegion;
      _fillHandlePressed = false;
      _fillHighlightRegion = null;
      if (_selection.current != null &&
          previous?.current != null &&
          highlight != null) {
        final newRange = _selection.copyWith(
          current: _selection.current!.copyWith(
            range: combineRects(previous!.current!.range, highlight),
          ),
        );
        _fillPattern(previous, newRange);
        _setGridSelection(newRange, true);
        return;
      }
      setState(() {});
      return;
    }

    // Touch pointers do their selection on release instead of on press
    // (`data-editor.tsx:2438-2482`).
    if (args.isTouch == true) {
      if (args.kind == GlideGridCellKind.cell) {
        if (!_handleMaybeClick(args as GlideGridCellMouseArgs)) {
          _handleSelect(args);
        }
      } else if (args.kind == GlideGridCellKind.header) {
        final header = args as GlideGridHeaderMouseArgs;
        widget.props.onHeaderClicked?.call(header.location.col, header);
        _handleSelect(args);
      } else if (args.kind == GlideGridCellKind.groupHeader) {
        _handleSelect(args);
      }
      _lastMouseSelectLocation = null;
      _mouseDownData = null;
      _previousSelection = null;
      return;
    }

    switch (args.kind) {
      case GlideGridCellKind.header:
        final header = args as GlideGridHeaderMouseArgs;
        final lastDown = _lastMouseSelectLocation;
        if (header.isEdge) {
          // Double-clicking a header edge re-measures the column
          // (`data-editor.tsx:2489-2492`).
          if (header.isDoubleClick == true) {
            _normalSizeColumn(header.location.col);
          }
        } else if (args.button == 0 &&
            lastDown != null &&
            lastDown.col == header.location.col &&
            lastDown.row == header.location.row) {
          widget.props.onHeaderClicked?.call(header.location.col, header);
        }
      case GlideGridCellKind.groupHeader:
        final groupHeader = args as GlideGridGroupHeaderMouseArgs;
        final lastDown = _lastMouseSelectLocation;
        if (args.button == 0 &&
            lastDown != null &&
            lastDown.col == groupHeader.location.col &&
            lastDown.row == groupHeader.location.row) {
          // `handleGroupHeaderSelection` runs for group headers.
          _selectionState.handleGroupHeaderSelection(
            groupHeader,
            columns: widget.props.columns,
            rowMarkerOffset: 0,
          );
          if (_selectionState.selection != _selection) {
            _setGridSelection(_selectionState.selection, false);
          }
        }
      case GlideGridCellKind.cell:
        if (args.button == 0 || args.button == 1) {
          _handleMaybeClick(args as GlideGridCellMouseArgs);
        }
      case GlideGridCellKind.outOfBounds:
        break;
    }
    _lastMouseSelectLocation = null;
    _mouseDownData = null;
    _previousSelection = null;
    _fillHighlightRegion = null;
    if (_scrollDir != null) {
      setState(() => _scrollDir = null);
      _setAutoscrollActive(false);
    }
  }

  // -------------------------------------------------------------------------
  // Highlight regions (`data-editor.tsx:1240-1305`)
  // -------------------------------------------------------------------------

  List<GlideHighlight>? _highlightRegions() {
    final p = widget.props;
    final accent = p.theme.accentColor;
    final current = _selection.current;
    final highlightRange =
        current != null &&
            current.range.width * current.range.height > 1
        ? current.range
        : null;
    final highlightFocus = p.drawFocusRing ? current?.cell : null;

    if ((p.highlightRegions == null || p.highlightRegions!.isEmpty) &&
        highlightRange == null &&
        highlightFocus == null &&
        _fillHighlightRegion == null) {
      return null;
    }

    final regions = <GlideHighlight>[];
    if (p.highlightRegions != null) {
      for (final r in p.highlightRegions!) {
        final maxWidth =
            p.columns.length - r.range.x.toInt() - 0;
        if (maxWidth > 0) {
          regions.add(
            GlideHighlight(
              color: r.color,
              range: GlideRectangle(
                x: r.range.x,
                y: r.range.y,
                width: math.min(maxWidth.toDouble(), r.range.width),
                height: r.range.height,
              ),
              style: r.style,
            ),
          );
        }
      }
    }
    if (_fillHighlightRegion != null) {
      regions.add(
        GlideHighlight(
          color: accent.withValues(alpha: 0),
          range: _fillHighlightRegion!,
          style: GlideHighlightStyle.dashedOutline,
        ),
      );
    }
    if (highlightRange != null) {
      regions.add(
        GlideHighlight(
          color: accent.withValues(alpha: 0.5),
          range: highlightRange,
        ),
      );
    }
    if (highlightFocus != null) {
      regions.add(
        GlideHighlight(
          color: accent,
          range: GlideRectangle(
            x: highlightFocus.col.toDouble(),
            y: highlightFocus.row.toDouble(),
            width: 1,
            height: 1,
          ),
        ),
      );
    }
    return regions.isEmpty ? null : regions;
  }

  // -------------------------------------------------------------------------
  // Keyboard / clipboard
  // -------------------------------------------------------------------------

  void _handleKeyDown(GlideGridKeyArgs event) {
    var cancelled = false;
    widget.props.onKeyDown?.call(
      GlideGridKeyArgs(
        bounds: event.bounds,
        key: event.key,
        keyCode: event.keyCode,
        altKey: event.altKey,
        shiftKey: event.shiftKey,
        ctrlKey: event.ctrlKey,
        metaKey: event.metaKey,
        cancel: () => cancelled = true,
        stopPropagation: event.stopPropagation,
        preventDefault: event.preventDefault,
        location: event.location,
        rawEvent: event.rawEvent,
      ),
    );
    if (cancelled) return;

    final handler = _makeKeyHandler();
    final handled = handler.handleKeyDown(
      event,
      editOnType: widget.props.editOnType,
    );
    if (handler.selection != _selection) {
      _setGridSelection(handler.selection, false);
    }
    if (!handled) return;
  }

  Future<void> _cut() async {
    final getCells = widget.props.getCellsForSelection;
    if (getCells == null) return;
    await glideCut(
      focused: _focused,
      cutEnabled: glideKeysWithDefaults(widget.props.keybindings).cut,
      selection: _selection,
      rows: widget.props.rows,
      rowMarkerOffset: 0,
      columns: widget.props.columns,
      getCellsForSelection: getCells,
      onDelete: (selection) =>
          widget.props.onDelete?.call(selection) ?? true,
      copyHeaders: widget.props.copyHeaders,
    );
  }

  Future<void> _copy() async {
    final getCells = widget.props.getCellsForSelection;
    if (getCells == null) return;
    await glideCopy(
      focused: _focused,
      copyEnabled: glideKeysWithDefaults(widget.props.keybindings).copy,
      selection: _selection,
      rows: widget.props.rows,
      rowMarkerOffset: 0,
      columns: widget.props.columns,
      getCellsForSelection: getCells,
      copyHeaders: widget.props.copyHeaders,
    );
  }

  Future<void> _paste() async {
    final getCells = widget.props.getCellsForSelection;
    if (getCells == null) return;
    await glidePaste(
      focused: _focused,
      selection: _selection,
      rows: widget.props.rows,
      columnCount: widget.props.columns.length,
      rowMarkerOffset: 0,
      getCellContent: _getCellContent,
      getCellRenderer: _renderers.forCell,
      onCellsEdited: _onCellsEdited,
      onPaste: widget.props.onPaste,
      coercePasteValue: widget.props.coercePasteValue,
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  int get _visibleRowCount {
    final bodyHeight = _viewportHeight - _headerHeight;
    if (bodyHeight <= 0) return 1;
    return (bodyHeight / widget.props.rowHeight(0)).ceil() + 1;
  }

  double get _headerHeight => widget.props.enableGroups
      ? widget.props.headerHeight + widget.props.groupHeaderHeight
      : widget.props.headerHeight;

  double _viewportHeight = 400;

  double get _rowsHeight {
    final rh = widget.props.rowHeight;
    if (rh.isFixed) return widget.props.rows * rh(0);
    var total = 0.0;
    for (var i = 0; i < widget.props.rows; i++) {
      total += rh(i);
    }
    return total;
  }

  double get _maxScrollY =>
      math.max(0.0, _rowsHeight - (_viewportHeight - _headerHeight));

  /// `useColumnSizer`'s `nonGrowWidth` (`data-editor.tsx:1118`): the width of
  /// the columns themselves, which is what the horizontal extent is derived
  /// from (`scrolling-data-grid.tsx:105`).
  double get _columnsWidth {
    var total = 0.0;
    for (final c in widget.props.columns) {
      total += c.width ?? 0;
    }
    return total;
  }

  double get _stickyWidth {
    var total = 0.0;
    for (var i = 0; i < widget.props.freezeColumns; i++) {
      total += widget.props.columns[i].width ?? 0;
    }
    return total;
  }

  double get _maxScrollX => math.max(
    0.0,
    _columnsWidth - (_viewportWidth - _stickyWidth),
  );

  /// Derives `cellXOffset`/`cellYOffset`/`translateX`/`translateY` from the
  /// current scroll offsets (`scrolling-data-grid.tsx:121-240`).
  void _applyScroll() {
    final region = computeVisibleRegion(
      scrollX: _scrollX,
      scrollY: _scrollY,
      clientWidth: _viewportWidth,
      clientHeight: math.max(1, _viewportHeight - _headerHeight),
      columns: mapColumns(widget.props.columns, widget.props.freezeColumns),
      rowHeight: widget.props.rowHeight,
      rows: widget.props.rows,
      freezeColumns: widget.props.freezeColumns,
      smoothScrollX: widget.props.smoothScrollX,
      smoothScrollY: widget.props.smoothScrollY,
    );
    setState(() {
      _visible = region;
      _cellXOffset = region.x;
      _cellYOffset = region.y;
      _translateX = region.translateX;
      _translateY = region.translateY;
    });
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    // Shift + wheel scrolls horizontally, matching the browser.
    final horizontal = HardwareKeyboard.instance.isShiftPressed;
    var dx = horizontal ? event.scrollDelta.dy : event.scrollDelta.dx;
    final dy = horizontal ? 0.0 : event.scrollDelta.dy;

    final nextY = clampDouble(_scrollY + dy, 0, _maxScrollY);
    final nextX = clampDouble(_scrollX + dx, 0, _maxScrollX);
    if (nextY == _scrollY && nextX == _scrollX) return;
    setState(() {
      _scrollY = nextY;
      _scrollX = nextX;
    });
    _applyScroll();
  }

  double _viewportWidth = 800;
  double _scrollX = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.props;

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportWidth = constraints.maxWidth;
        _viewportHeight = constraints.maxHeight;

        final gridProps = GlideDataGridProps(
          width: _viewportWidth,
          height: _viewportHeight,
          columns: p.columns,
          rows: p.rows,
          rowHeight: p.rowHeight,
          headerHeight: p.headerHeight,
          // `data-editor.tsx:4276` forwards 0 when groups are off, which is
          // what keeps `computeBounds`' `totalHeaderHeight - groupHeaderHeight`
          // consistent for header rows.
          groupHeaderHeight: p.enableGroups ? p.groupHeaderHeight : 0,
          enableGroups: p.enableGroups,
          freezeColumns: p.freezeColumns,
          freezeTrailingRows: p.freezeTrailingRows,
          cellXOffset: _cellXOffset,
          cellYOffset: _cellYOffset,
          translateX: _translateX,
          translateY: _translateY,
          getCellContent: _getCellContent,
          getCellRenderer: _renderers.forCell,
          theme: p.theme,
          verticalBorder: p.verticalBorder,
          onItemHovered: _onItemHovered,
          onMouseMove: (_) {},
          onPointerMoveRaw: _onPointerMoveRaw,
          onMouseDown: _onMouseDown,
          onMouseUp: _onMouseUp,
          onContextMenu: _onContextMenu,
          onCanvasFocused: () => setState(() => _focused = true),
          onCanvasBlur: () => setState(() => _focused = false),
          onCellFocused: (_) {},
          onKeyDown: _handleKeyDown,
          onKeyUp: p.onKeyUp,
          selection: _selection,
          isFocused: _focused,
          drawFocusRing: p.drawFocusRing,
          fillHandle: p.fillHandle,
          isResizing: _resizeCol != null,
          resizeColumn: _resizeCol,
          resizeIndicator: p.resizeIndicator,
          dragAndDropState: _dragCol != null && _dropCol != null
              ? GlideColumnDndState(src: _dragCol!, dest: _dropCol!)
              : null,
          highlightRegions: _highlightRegions(),
          getRowThemeOverride: p.getRowThemeOverride,
          getGroupDetails: p.getGroupDetails,
          metrics: _metrics,
          minimumCellWidth: 10,
        );

        return Shortcuts(
          shortcuts: _clipboardShortcuts,
          child: Actions(
            actions: {
              _CopyIntent: CallbackAction<_CopyIntent>(
                onInvoke: (_) {
                  _copy();
                  return null;
                },
              ),
              _PasteIntent: CallbackAction<_PasteIntent>(
                onInvoke: (_) {
                  _paste();
                  return null;
                },
              ),
              _CutIntent: CallbackAction<_CutIntent>(
                onInvoke: (_) {
                  _cut();
                  return null;
                },
              ),
            },
            child: Listener(
              onPointerSignal: _handleScroll,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  RepaintBoundary(
                    child: GlideDataGrid(
                      props: gridProps,
                      controller: _gridController,
                    ),
                  ),
                  if (_overlay != null) _buildOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onContextMenu(GlideGridMouseArgs args, void Function() preventDefault) {
    if (args is! GlideGridCellMouseArgs) return;
    widget.props.onCellContextMenu?.call(
      args.location,
      GlideCellClickedEventArgs(
        shiftKey: args.shiftKey,
        ctrlKey: args.ctrlKey,
        metaKey: args.metaKey,
        isTouch: args.isTouch,
        isLongTouch: args.isLongTouch,
        isDoubleClick: args.isDoubleClick,
        isEdge: args.isEdge,
        button: args.button,
        buttons: args.buttons,
        scrollEdge: args.scrollEdge,
        location: args.location,
        bounds: args.bounds,
        isFillHandle: args.isFillHandle,
        localEventX: args.localEventX,
        localEventY: args.localEventY,
        preventDefault: preventDefault,
      ),
    );
  }

  final GlideTextMetrics _metrics = GlideTextMetrics();

  /// Copy/cut/paste live on window-level `copy`/`paste` listeners upstream
  /// (`data-editor.tsx:3877`); Flutter has no such channel for a canvas, so
  /// they are ordinary shortcuts instead.
  Map<ShortcutActivator, Intent> get _clipboardShortcuts => {
    const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        const _CopyIntent(),
    const SingleActivator(LogicalKeyboardKey.keyC, control: true):
        const _CopyIntent(),
    const SingleActivator(LogicalKeyboardKey.keyX, meta: true):
        const _CutIntent(),
    const SingleActivator(LogicalKeyboardKey.keyX, control: true):
        const _CutIntent(),
    const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        const _PasteIntent(),
    const SingleActivator(LogicalKeyboardKey.keyV, control: true):
        const _PasteIntent(),
  };

  Widget _buildOverlay() {
    final overlay = _overlay!;
    return GlideDataGridOverlayEditor(
      target: overlay.target,
      cell: overlay.cell,
      content: overlay.content,
      theme: overlay.theme,
      onFinishEditing: _finishEditing,
      forceEditMode: overlay.forceEditMode,
      highlight: overlay.highlight,
      getCellRenderer: _renderers.forCell,
      initialValue: overlay.initialValue,
      validateCell: null,
      activation: overlay.activation is GlideKeyboardCellActivation
          ? null
          : null,
    );
  }
}

/// What the overlay is editing (`data-editor.tsx` `overlay` state).
@immutable
class _OverlayState {
  const _OverlayState({
    required this.target,
    required this.cell,
    required this.content,
    required this.theme,
    required this.highlight,
    required this.forceEditMode,
    required this.activation,
    this.initialValue,
  });

  final GlideRectangle target;
  final GlideItem cell;
  final GlideGridCell content;
  final GlideTheme theme;
  final String? initialValue;
  final bool highlight;
  final bool forceEditMode;
  final GlideCellActivation activation;
}

class _CopyIntent extends Intent {
  const _CopyIntent();
}

class _CutIntent extends Intent {
  const _CutIntent();
}

class _PasteIntent extends Intent {
  const _PasteIntent();
}
