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
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

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
import 'glide_group_rename.dart';
import 'glide_handle_select.dart';
import 'glide_column_sizer.dart';
import 'glide_key_handler.dart';
import 'glide_keybindings.dart';
import 'glide_rem_adjuster.dart';
import 'glide_row_grouping.dart';
import '../internal/data_grid_search/glide_data_grid_search.dart';

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
    this.rowMarkers,
    this.rowGrouping,
    this.trailingRowOptions,
    this.onRowAppended,
    this.onColumnAppended,
    this.rowSelectionMode = GlideSelectMode.auto,
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
    this.onRowMoved,
    this.lockColumns = 0,
    this.resizeIndicator = GlideResizeIndicator.full,
    this.onGridSelectionChange,
    this.onSelectionCleared,
    this.onDelete,
    this.onCellActivated,
    this.onCellClicked,
    this.onCellContextMenu,
    this.onHeaderClicked,
    this.onHeaderContextMenu,
    this.onGroupHeaderClicked,
    this.onGroupHeaderContextMenu,
    this.onFinishedEditing,
    this.onVisibleRegionChanged,
    this.onCellFocused,
    this.onGroupHeaderRenamed,
    this.onMouseMove,
    this.getRowThemeOverride,
    this.getGroupDetails,
    this.highlightRegions,
    this.fillHandle,
    this.allowedFillDirections = GlideFillHandleDirection.orthogonal,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 500,
    this.overscrollY = 0,
    this.overscrollX = 0,
    this.scaleToRem = false,
    this.remSize,
    this.scrollOffsetX,
    this.scrollOffsetY,
    this.smoothScrollX = false,
    this.smoothScrollY = false,
    this.showSearch,
    this.searchValue,
    this.searchResults,
    this.onSearchValueChange,
    this.onSearchResultsChanged,
    this.onSearchClose,
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

  /// `rowMarkers` (`data-editor.tsx:331`): null/`none` adds no marker
  /// column.
  final GlideRowMarkerOptions? rowMarkers;

  /// `trailingRowOptions` (`data-editor.tsx:291-306`): non-null adds the
  /// "new row" row at the bottom (`:955`).
  final GlideTrailingRowOptions? trailingRowOptions;

  /// `onRowAppended` (`data-editor.tsx:221`): the owner inserts a row and
  /// rebuilds; the editor waits for `rows` to grow before focusing it.
  final void Function()? onRowAppended;

  /// `onColumnAppended` (`data-editor.tsx:225`): return `"left"`, `"right"`
  /// or a column index to control where the new column lands; null appends on
  /// the right. The editor waits for the column count to grow.
  final Object? Function()? onColumnAppended;

  /// `rowGrouping` (`data-editor.tsx:936`): group headers, collapse state
  /// and the per-group theme/height overrides.
  final GlideRowGroupingOptions? rowGrouping;

  /// `rowSelectionMode` (`data-editor.tsx:849`).
  final GlideSelectMode rowSelectionMode;

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
  final void Function(int col, GlideGridHeaderMouseArgs args)? onHeaderClicked;

  /// `onHeaderContextMenu` / `onGroupHeaderClicked` /
  /// `onGroupHeaderContextMenu` (`data-editor.tsx:260`, `:233`, `:264`).
  final void Function(int col, GlideHeaderClickedEventArgs args)?
  onHeaderContextMenu;
  final void Function(int col, GlideGroupHeaderClickedEventArgs args)?
  onGroupHeaderClicked;
  final void Function(int col, GlideGroupHeaderClickedEventArgs args)?
  onGroupHeaderContextMenu;

  /// `onFinishedEditing` (`data-editor.tsx:256`, `:3125`).
  final void Function(GlideGridCell? newValue, GlideEditorMovement movement)?
  onFinishedEditing;

  /// `onVisibleRegionChanged` (`data-editor.ts:521`, `:2645`).
  final void Function(GlideVisibleRegion region, GlideVisibleRegionExtras extras)?
  onVisibleRegionChanged;

  /// `onCellFocused` (`data-grid.tsx:171`): upstream fires it from the
  /// accessibility tree, which is not ported; here it reports the active cell
  /// whenever the selection moves.
  final void Function(GlideItem location)? onCellFocused;

  /// `onGroupHeaderRenamed` (`data-editor.tsx:241`): enabling it adds a
  /// "Rename" action to every group header (`mangledGetGroupDetails`,
  /// `:1401-1423`).
  final void Function(String groupName, String newVal)? onGroupHeaderRenamed;

  /// `onMouseMove` (`data-grid.tsx:1359`).
  final void Function(GlideGridMouseArgs args)? onMouseMove;

  /// `getRowThemeOverride` (`row-grouping.ts:298-310`): the indexed form
  /// `(row, groupIndex, contentIndex)` upstream exposes.
  final GlideGetRowThemeOverrideIndexed? getRowThemeOverride;
  final GlideGroupDetails Function(String group)? getGroupDetails;
  final List<GlideHighlight>? highlightRegions;

  /// `fillHandle` (`data-editor.tsx:150`): null disables the handle.
  final GlideFillHandleConfig? fillHandle;

  /// `allowedFillDirections` (`data-editor.tsx:868`).
  final GlideFillHandleDirection allowedFillDirections;

  /// `onColumnResize` / `...Start` / `...End` (`data-grid-dnd.tsx:40-70`).
  final void Function(
    GlideGridColumn column,
    double newSize,
    int colIndex,
    double newSizeWithGrow,
  )?
  onColumnResize;
  final void Function(
    GlideGridColumn column,
    double newSize,
    int colIndex,
    double newSizeWithGrow,
  )?
  onColumnResizeStart;
  final void Function(
    GlideGridColumn column,
    double newSize,
    int colIndex,
    double newSizeWithGrow,
  )?
  onColumnResizeEnd;

  /// `minColumnWidthIn`/`maxColumnWidthIn` (`data-editor.tsx:862-863`).
  final double minColumnWidth;
  final double maxColumnWidth;

  /// `onColumnMoved` / `onColumnProposeMove` (`data-grid-dnd.tsx:44-57`).
  /// Returning false from [onColumnProposeMove] rejects the move.
  final void Function(int from, int to)? onColumnMoved;
  final bool? Function(int from, int to)? onColumnProposeMove;

  /// `onRowMoved` (`data-editor.tsx`): also enables the marker drag handle.
  final void Function(int from, int to)? onRowMoved;

  /// `lockColumns` (`data-grid-dnd.tsx:133`): columns before this index are
  /// not drop targets.
  final int lockColumns;

  final GlideResizeIndicator resizeIndicator;

  /// `onFillPattern` (`data-editor.tsx:2258`): called before the fill runs;
  /// call `preventDefault()` to cancel it.
  final void Function(GlideFillPatternArgs args)? onFillPattern;

  final double overscrollY;

  /// `overscrollX` (`data-editor.tsx`): extra horizontal scroll extent.
  final double overscrollX;

  /// `scaleToRem` / `remSize` (`data-editor.tsx:657`, `:896`): multiply every
  /// dimension by `remSize / 16`. Flutter has no root font size, so [remSize]
  /// is supplied by the caller (or derived from the platform text scaler).
  final bool scaleToRem;
  final double? remSize;

  /// `scrollOffsetX` / `scrollOffsetY` (`data-editor.tsx:415-420`): initial
  /// scroll position applied once the grid has been laid out.
  final double? scrollOffsetX;
  final double? scrollOffsetY;

  final bool smoothScrollX;
  final bool smoothScrollY;

  /// `showSearch` (`data-grid-search.ts:71`): null lets the editor own the
  /// visibility (toggled by the `search` keybinding).
  final bool? showSearch;

  /// Controlled search state (`data-grid-search.ts:59-87`).
  final String? searchValue;
  final List<GlideItem>? searchResults;
  final void Function(String newVal)? onSearchValueChange;
  final void Function(List<GlideItem> results, int navIndex)?
  onSearchResultsChanged;
  final void Function()? onSearchClose;
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

  /// Search state (`data-grid-search.ts:109-149`).
  bool _showSearchInner = false;
  String _searchValueInner = '';
  List<GlideItem> _searchResultsInner = const [];
  GlideSearchStatus? _searchStatus;
  int _searchSelectedIndex = -1;
  final GlideSearchRunner _searchRunner = GlideSearchRunner();
  late final TextEditingController _searchTextController;
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'GlideSearch');

  bool get _showSearch => widget.props.showSearch ?? _showSearchInner;
  String get _searchValue => widget.props.searchValue ?? _searchValueInner;
  List<GlideItem> get _searchResults =>
      widget.props.searchResults ?? _searchResultsInner;

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

  /// `dragRow` / `dropRow` / `dragStartY` / `dragRowActive`
  /// (`data-grid-dnd.tsx:88-94`).
  int? _dragRow;
  int? _dropRow;
  double? _dragStartY;
  bool _dragRowActive = false;

  bool get _canDragCol => widget.props.onColumnMoved != null;

  /// `visibleRegionRef` (`data-editor.tsx:2831`).
  GlideVisibleRegion? _visible;
  GlideVisibleRegionExtras? _visibleExtras;

  late final Ticker _autoscrollTicker;
  Duration _lastTick = Duration.zero;
  final GlideAutoscroll _autoscroll = GlideAutoscroll();

  @override
  void initState() {
    super.initState();
    _selection = GlideGridSelection.empty;
    _rebuildRowGrouping();
    _rebuildRemAdjustment(16);
    _rebuildSizedColumns();
    _rebuildMangledColumns();
    _selectionState = _makeSelectionState();
    _searchTextController = TextEditingController();
    _autoscrollTicker = createTicker(_onAutoscrollTick);

    // `useInitialScrollOffset` (`use-initial-scroll-offset.ts:38-71`): the
    // offsets only take effect once the viewport exists, so they are applied
    // after the first frame has been laid out.
    final initialX = widget.props.scrollOffsetX;
    final initialY = widget.props.scrollOffsetY;
    if (initialX != null) _scrollX = initialX;
    if (initialY != null) _scrollY = initialY;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyScroll();
    });
  }

  @override
  void dispose() {
    _searchRunner.cancel();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _autoscrollTicker.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Search (`internal/data-grid-search/data-grid-search.tsx`)
  // -------------------------------------------------------------------------

  void _openSearch() {
    setState(() {
      _showSearchInner = true;
      _searchValueInner = '';
      _searchStatus = null;
      _searchSelectedIndex = -1;
      _searchResultsInner = const [];
    });
    _searchTextController.clear();
    _searchRunner.cancel();
    widget.props.onSearchResultsChanged?.call(const [], -1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchRunner.cancel();
    setState(() {
      _showSearchInner = false;
      _searchValueInner = '';
      _searchStatus = null;
      _searchSelectedIndex = -1;
      _searchResultsInner = const [];
    });
    _searchTextController.clear();
    widget.props.onSearchClose?.call();
    widget.props.onSearchResultsChanged?.call(const [], -1);
    _gridController.focus();
  }

  /// `onSearchChange` (`data-grid-search.ts:285-298`).
  void _onSearchChanged(String value) {
    widget.props.onSearchValueChange?.call(value);
    if (widget.props.searchResults != null) return;

    setState(() => _searchValueInner = value);
    if (value.isEmpty) {
      _searchRunner.cancel();
      setState(() {
        _searchStatus = null;
        _searchResultsInner = const [];
      });
      return;
    }
    _runSearch(value);
  }

  Future<void> _runSearch(String value) async {
    if (widget.props.getCellsForSelection == null) return;
    await _searchRunner.search(
      pattern: value,
      rows: _mangledRows,
      columnCount: _mangledColumns.length,
      startY: _cellYOffset,
      getCells: _getCellsForSelection,
      onResults: (results) => setState(() => _searchResultsInner = results),
      onStatus: (status) => setState(() => _searchStatus = status),
      onResultsChanged: (results, navIndex) =>
          widget.props.onSearchResultsChanged?.call(results, navIndex),
      selectedIndex: _searchSelectedIndex,
    );
  }

  /// `onNext` / `onPrev` (`data-grid-search.ts:321-348`).
  void _searchStep(int delta) {
    final status = _searchStatus;
    if (status == null || status.results == 0) return;
    var newIndex = (status.selectedIndex + delta) % status.results;
    if (newIndex < 0) newIndex += status.results;

    setState(() {
      _searchSelectedIndex = newIndex;
      _searchStatus = GlideSearchStatus(
        rowsSearched: status.rowsSearched,
        results: status.results,
        selectedIndex: newIndex,
      );
    });

    final results = _searchResults;
    widget.props.onSearchResultsChanged?.call(results, newIndex);
    if (newIndex >= 0 && newIndex < results.length) {
      // Upstream leaves the scroll to `onSearchResultsChanged`'s consumer;
      // this port has no consumer, so the editor does it itself.
      final item = results[newIndex];
      _scrollTo(GlideScrollTarget(item.col - _markerOffset, item.row));
    }
  }

  /// `onSearchKeyDown` (`data-grid-search.ts:350-365`).
  KeyEventResult _handleSearchKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape ||
        ((HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
            key == LogicalKeyboardKey.keyF)) {
      _closeSearch();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        _searchStep(-1);
      } else {
        _searchStep(1);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void didUpdateWidget(GlideDataEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.props.columns != widget.props.columns ||
        oldWidget.props.rows != widget.props.rows ||
        oldWidget.props.rowMarkers != widget.props.rowMarkers ||
        oldWidget.props.rowGrouping != widget.props.rowGrouping ||
        oldWidget.props.rowHeight != widget.props.rowHeight) {
      _rebuildRowGrouping();
      _rebuildRemAdjustment(16);
      _rebuildSizedColumns();
      _rebuildMangledColumns();
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
    rows: _groupedRows,
    rowSelectMulti: widget.props.rowSelect == GlideSelectMode.multi,
    columnSelectMulti: widget.props.columnSelect == GlideSelectMode.multi,
    rowMarkerOffset: _markerOffset,
    hasRowMarkers: _hasRowMarkers,
    rowMarkersAreNumbers:
        _rowMarkers == GlideRowMarkerKind.number ||
        _rowMarkers == GlideRowMarkerKind.none,
    rowSelectEnabled: widget.props.rowSelect != GlideSelectMode.none,
    rowSelectionModeMulti:
        widget.props.rowSelectionMode == GlideSelectMode.multi,
    rowDragEnabled: widget.props.onRowMoved != null,
    headerRowMarkerDisabled: _headerRowMarkerDisabled,
    rowGroupingNavBehavior: widget.props.rowGrouping?.navigationBehavior,
    isGroupHeaderRow: _isGroupHeaderRow,
    showTrailingBlankRow: _showTrailingBlankRow,
    userRows: _groupedRows,
    appendRow: (col) => _appendRow(col),
    getCustomNewRowTargetColumn: _customNewRowTargetColumn,
    initial: _selection,
  );

  // -------------------------------------------------------------------------
  // Row markers (`data-editor.tsx:911-956`, `:1141-1169`)
  // -------------------------------------------------------------------------

  GlideRowMarkerOptions? get _rowMarkerOpts => widget.props.rowMarkers;
  GlideRowMarkerKind get _rowMarkers =>
      _rowMarkerOpts?.kind ?? GlideRowMarkerKind.none;
  bool get _hasRowMarkers => _rowMarkers != GlideRowMarkerKind.none;
  int get _markerOffset => _hasRowMarkers ? 1 : 0;

  int get _rowMarkerWidth {
    final explicit = _rowMarkerOpts?.width;
    if (explicit != null) return explicit.toInt();
    final rows = widget.props.rows;
    return rows > 10000
        ? 48
        : rows > 1000
        ? 44
        : rows > 100
        ? 36
        : 32;
  }

  bool get _headerRowMarkerDisabled =>
      widget.props.rowSelect != GlideSelectMode.multi ||
      (_rowMarkerOpts?.headerDisabled ?? false);

  /// `rowMarkerChecked` (`data-editor.tsx:1139`).
  GlideBooleanValue get _headerRowMarkerChecked {
    final selected = _selection.rows.length;
    if (selected == 0) return GlideBooleanValue.unchecked;
    if (selected == _groupedRows) return GlideBooleanValue.checked;
    return GlideBooleanValue.empty;
  }

  GlideMarkerKind get _markerKind => switch (_rowMarkers) {
    GlideRowMarkerKind.checkbox => GlideMarkerKind.checkbox,
    GlideRowMarkerKind.number ||
    GlideRowMarkerKind.clickableNumber => GlideMarkerKind.number,
    GlideRowMarkerKind.checkboxVisible => GlideMarkerKind.checkboxVisible,
    GlideRowMarkerKind.both => GlideMarkerKind.both,
    GlideRowMarkerKind.none => GlideMarkerKind.checkbox,
  };

  /// `useRemAdjuster` result (`use-rem-adjuster.ts:15-47`); set in
  /// `initState`, which can already take the identity path.
  late GlideRemAdjustment _remAdjustment;

  /// `useRowGroupingInner` result (`row-grouping.ts:247-326`).
  GlideRowGroupingResult _rowGrouping = const GlideRowGroupingResult(
    rows: 0,
    flattened: [],
  );
  GlideRowGroupingOptions? _rowGroupingOpts;
  int _rowGroupingRawRows = -1;
  GlideRowHeight? _rowGroupingBaseHeight;

  /// The row count the grid works in: the raw count, or the grouped count
  /// when `rowGrouping` is set (`data-editor.tsx:936`).
  int get _groupedRows => _rowGrouping.rows;

  /// `rowHeight` after `useRowGroupingInner` (`row-grouping.ts:270`) and
  /// `useRemAdjuster` (`use-rem-adjuster.ts:21`) have both wrapped it.
  GlideRowHeight get _effectiveRowHeight => _remAdjustment.rowHeight;

  /// The rem-scaled theme (`use-rem-adjuster.ts:34-40`).
  GlideTheme get _theme => _remAdjustment.theme;

  /// `getRowThemeOverride` adapted to the grid's one-argument signature.
  GlideGetRowThemeOverride? get _rowThemeOverride =>
      _rowGrouping.getRowThemeOverride;

  void _rebuildRowGrouping() {
    final p = widget.props;
    if (_rowGroupingRawRows == p.rows &&
        identical(_rowGroupingOpts, p.rowGrouping) &&
        _rowGroupingBaseHeight == p.rowHeight) {
      return;
    }
    _rowGroupingOpts = p.rowGrouping;
    _rowGroupingRawRows = p.rows;
    _rowGroupingBaseHeight = p.rowHeight;
    _rowGrouping = useRowGroupingInner(
      options: p.rowGrouping,
      rows: p.rows,
      rowHeightIn: p.rowHeight,
      getRowThemeOverrideIn: p.getRowThemeOverride,
    );
  }

  /// `useColumnSizer` result (`use-column-sizer.ts:78-253`).
  GlideSizedColumns _sizedColumns = const GlideSizedColumns(
    columns: [],
    nonGrowWidth: 0,
  );
  List<GlideGridColumn>? _sizedKeyColumns;
  double _sizedKeyWidth = -1;
  int _sizedKeyRows = -1;
  final Map<String, double> _columnSizeMemo = {};

  /// `mangledCols` (`data-editor.tsx:1141-1169`); rebuilt whenever the
  /// columns or the marker options change.
  List<GlideGridColumn> _mangledColumns = const [];

  /// `useColumnSizer` (`use-column-sizer.ts:108-217`).
  /// `useRemAdjuster` (`data-editor.tsx:939-948`), which runs after
  /// `useRowGroupingInner` (`:936`).
  void _rebuildRemAdjustment(double remSize) {
    final p = widget.props;
    final grouped = _rowGrouping.rowHeight == null
        ? p.rowHeight
        : GlideRowHeight.variable(_rowGrouping.rowHeight!);
    _remAdjustment = glideRemAdjuster(
      scaleToRem: p.scaleToRem,
      remSize: remSize,
      rowHeightIn: grouped,
      headerHeightIn: p.headerHeight,
      groupHeaderHeightIn: p.groupHeaderHeight,
      themeIn: p.theme,
      overscrollXIn: p.overscrollX,
      overscrollYIn: p.overscrollY,
    );
  }

  void _rebuildSizedColumns() {
    final p = widget.props;
    if (identical(_sizedKeyColumns, p.columns) &&
        _sizedKeyWidth == _viewportWidth &&
        _sizedKeyRows == p.rows) {
      return;
    }
    _sizedKeyColumns = p.columns;
    _sizedKeyWidth = _viewportWidth;
    _sizedKeyRows = p.rows;
    _sizedColumns = useColumnSizer(
      columns: p.columns,
      rows: p.rows,
      getCellsForSelection: _getCellsForSelection,
      clientWidth: _viewportWidth,
      minColumnWidth: p.minColumnWidth,
      maxColumnWidth: p.maxColumnWidth,
      theme: _theme,
      getCellRenderer: _renderers.forCell,
      metrics: _metrics,
      memo: _columnSizeMemo,
    );
  }

  void _rebuildMangledColumns() {
    final opts = _rowMarkerOpts;
    if (!_hasRowMarkers || opts == null) {
      _mangledColumns = _sizedColumns.columns;
      return;
    }
    _mangledColumns = [
      GlideGridColumn(
        title: '',
        width: _rowMarkerWidth.toDouble(),
        hasMenu: false,
        style: GlideCellStyle.normal,
        themeOverride: opts.theme,
        extension: GlideInnerColumnExtension(
          rowMarker: opts.checkboxStyle,
          rowMarkerChecked: _headerRowMarkerChecked,
          headerRowMarkerTheme: opts.headerTheme,
          headerRowMarkerAlwaysVisible: opts.headerAlwaysVisible,
          headerRowMarkerDisabled: _headerRowMarkerDisabled,
        ),
      ),
      ..._sizedColumns.columns,
    ];
  }

  bool get _showTrailingBlankRow => widget.props.trailingRowOptions != null;

  /// `mangledRows` (`data-editor.tsx:1205`).
  int get _mangledRows =>
      _showTrailingBlankRow ? _groupedRows + 1 : _groupedRows;

  /// `lockColumns={rowMarkerOffset}` (`data-editor.tsx:4263`; the marker
  /// column is never a drop target.
  int get _lockColumns => math.max(widget.props.lockColumns, _markerOffset);

  /// `mangledFreezeColumns` (`data-editor.tsx:3994`).
  int get _mangledFreezeColumns => math.min(
    _mangledColumns.length,
    widget.props.freezeColumns + (_hasRowMarkers ? 1 : 0),
  );

  /// `rowNumberMapper(row) === undefined` means the row is a group header,
  /// which gets a loading placeholder in the marker column
  /// (`data-editor.tsx:1317-1319`).
  GlideGridCell _markerCellFor(int row) {
    final mapper = _rowGrouping.rowNumberMapper;
    final mappedRow = mapper == null ? row : mapper(row);
    if (mappedRow == null) return const GlideLoadingCell();
    return _markerCellAt(mappedRow, row);
  }

  GlideMarkerCell _markerCellAt(int mappedRow, int row) => GlideMarkerCell(
    row: (_rowMarkerOpts?.startIndex ?? 1) + mappedRow,
    drawHandle: widget.props.onRowMoved != null,
    checked: _selection.rows.hasIndex(row)
        ? GlideBooleanValue.checked
        : GlideBooleanValue.unchecked,
    checkboxStyle:
        _rowMarkerOpts?.checkboxStyle ?? GlideMarkerCheckboxStyle.square,
    markerKind: _markerKind,
  );

  /// `onCellFocused` (`data-editor.tsx:4124-4145`): the accessibility tree
  /// reporting that a cell (or header) took focus — the editor turns that
  /// into a selection.
  void _onAccessibilityFocused(GlideItem cell) {
    if (cell.row == GlideItem.headerRow) {
      if (widget.props.columnSelect == GlideSelectMode.none) return;
      _selectionState.createBehavior().setSelectedColumns(
        newCols: GlideCompactSelection.fromSingleSelection(cell.col),
        append: null,
        allowMixed: false,
      );
      _setGridSelection(_selectionState.selection, false);
      _gridController.focus();
      return;
    }

    final current = _selection.current;
    if (current != null && current.cell == cell) return;
    _selectionState.createBehavior().setCurrent(
      value: (
        cell: cell,
        range: GlideRectangle(
          x: cell.col.toDouble(),
          y: cell.row.toDouble(),
          width: 1,
          height: 1,
        ),
      ),
      expand: true,
      append: false,
      trigger: GlideSelectionTrigger.keyboardNav,
    );
    _setGridSelection(_selectionState.selection, true);
    _scrollTo(GlideScrollTarget(cell.col - _markerOffset, cell.row));
  }

  /// `mangledGetGroupDetails` (`data-editor.tsx:1401-1423`): the user's
  /// callback plus the Rename action when `onGroupHeaderRenamed` is set.
  GlideGroupDetails _groupDetails(String group) {
    final base = widget.props.getGroupDetails?.call(group) ??
        GlideGroupDetails(name: group);
    final onRename = widget.props.onGroupHeaderRenamed;
    if (onRename == null) return base;

    return GlideGroupDetails(
      name: base.name,
      icon: base.icon,
      overrideTheme: base.overrideTheme,
      actions: [
        ...?base.actions,
        GlideGroupAction(
          title: 'Rename',
          icon: Icons.edit,
          onClick: (bounds) => _beginGroupRename(group, bounds),
        ),
      ],
    );
  }

  /// `setRenameGroup` (`data-editor.tsx:1435-1438`).
  void _beginGroupRename(String group, GlideRectangle bounds) {
    setState(() => _renameGroup = (group: group, bounds: bounds));
  }

  ({String group, GlideRectangle bounds})? _renameGroup;

  void _finishGroupRename(String newValue) {
    final renaming = _renameGroup;
    setState(() => _renameGroup = null);
    if (renaming == null) return;
    widget.props.onGroupHeaderRenamed?.call(renaming.group, newValue);
  }

  /// `onVisibleRegionChangedImpl`'s `extras` (`data-editor.tsx:2594-2627`).
  GlideVisibleRegionExtras _computeVisibleExtras(GlideVisibleRegion region) {
    final p = widget.props;
    final selected = _selection.current?.cell;

    final freezeRegion = p.freezeColumns == 0
        ? null
        : GlideRectangle(
            x: 0,
            y: region.y.toDouble(),
            width: p.freezeColumns.toDouble(),
            height: region.height.toDouble(),
          );

    final freezeRegions = <GlideRectangle>[];
    if (freezeRegion != null) freezeRegions.add(freezeRegion);
    if (p.freezeTrailingRows > 0) {
      freezeRegions.add(
        GlideRectangle(
          x: region.x.toDouble(),
          y: (_groupedRows - p.freezeTrailingRows).toDouble(),
          width: region.width.toDouble(),
          height: p.freezeTrailingRows.toDouble(),
        ),
      );
      if (p.freezeColumns > 0) {
        freezeRegions.add(
          GlideRectangle(
            x: 0,
            y: (_groupedRows - p.freezeTrailingRows).toDouble(),
            width: p.freezeColumns.toDouble(),
            height: p.freezeTrailingRows.toDouble(),
          ),
        );
      }
    }

    return GlideVisibleRegionExtras(
      selected: selected == null
          ? null
          : GlideItem(selected.col - _markerOffset, selected.row),
      freezeRegion: freezeRegion,
      freezeRegions: freezeRegions,
    );
  }

  /// The `forceStrict` guard (`data-grid.tsx:966`, `:1282`): cells outside
  /// the visible window resolve to a loading placeholder so off-screen work
  /// never touches the consumer's data.
  bool _isOutsideVisibleArea(int col, int row) {
    final region = _visible;
    if (region == null) return false;
    final outerCol = col - _markerOffset;
    if (region.x > outerCol ||
        outerCol > region.x + region.width ||
        region.y > row ||
        row > region.y + region.height ||
        row >= _groupedRows) {
      final extras = _visibleExtras;
      final selected = extras?.selected;
      if (selected != null && selected.col == outerCol && selected.row == row) {
        return false;
      }
      for (final rect in extras?.freezeRegions ?? const <GlideRectangle>[]) {
        if (pointInRect(rect, outerCol.toDouble(), row.toDouble())) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  /// `trailingRowOptions.tint` (`data-editor.ts:3961-3965`): the trailing
  /// row joins `disabledRows`, which the painter tints with `bgHeader`.
  GlideCompactSelection get _disabledRows =>
      _showTrailingBlankRow && widget.props.trailingRowOptions?.tint == true
      ? GlideCompactSelection.fromArray([_mangledRows - 1])
      : const GlideCompactSelection.empty();

  /// `mapper(row).isGroupHeader` (`row-grouping.ts:190-238`).
  bool _isGroupHeaderRow(int row) =>
      mapRowIndexToPath(row, _rowGrouping.flattened).isGroupHeader;

  /// `getSelectionRowLimits` (`data-editor.tsx:2708-2725`).
  (int, int)? _getSelectionRowLimits(int row) => getSelectionRowLimits(
    options: widget.props.rowGrouping,
    flattened: _rowGrouping.flattened,
    selectedRow: row,
  );

  /// The `NewRow` cell for the trailing row (`data-editor.tsx:1330-1347`).
  GlideGridCell _newRowCell(int col) {
    final column = _mangledColumns[col];
    if (column.trailingRowOptions?.disabled == true) {
      return const GlideLoadingCell();
    }
    final editorOpts = widget.props.trailingRowOptions;
    final isFirst = col == _markerOffset;
    final maybeFirstColumnHint = isFirst ? (editorOpts?.hint ?? '') : '';
    final hint = column.trailingRowOptions?.hint ?? maybeFirstColumnHint;
    return GlideNewRowCell(
      hint: hint,
      icon: column.trailingRowOptions?.addIcon ?? editorOpts?.addIcon,
    );
  }

  /// `getCustomNewRowTargetColumn` (`data-editor.tsx:1795-1813`).
  int? _customNewRowTargetColumn(int col) {
    final p = widget.props;
    if (col < 0 || col >= _mangledColumns.length) return null;
    final custom =
        _mangledColumns[col].trailingRowOptions?.targetColumn ??
        p.trailingRowOptions?.targetColumn;
    final offset = _markerOffset;
    if (custom is int) return custom + offset;
    if (custom is GlideGridColumn) {
      final index = p.columns.indexOf(custom);
      if (index >= 0) return index + offset;
    }
    return null;
  }

  /// `appendRow` (`data-editor.tsx:1687-1742`). The Web version awaits the
  /// consumer's promise and retries with a backoff; here the same job is a
  /// post-frame check that `rows` grew.
  void _appendRow(int col, {bool openOverlay = true}) {
    final p = widget.props;
    if (col < 0 || col >= _mangledColumns.length) return;
    if (_mangledColumns[col].trailingRowOptions?.disabled == true) return;

    final rowsBefore = _groupedRows;
    p.onRowAppended?.call();
    _focusAfterAppend(col, rowsBefore, openOverlay, 0);
  }

  void _focusAfterAppend(
    int col,
    int rowsBefore,
    bool openOverlay,
    int attempt,
  ) {
    if (!mounted) return;
    if (_groupedRows > rowsBefore) {
      _selectAppendedRow(col, rowsBefore, openOverlay);
      return;
    }
    if (attempt >= 10) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusAfterAppend(col, rowsBefore, openOverlay, attempt + 1);
      }
    });
  }

  /// `doFocus`'s `setCurrent` + `scrollTo` (`data-editor.tsx:1716-1740`).
  void _selectAppendedRow(int col, int row, bool openOverlay) {
    final behavior = _selectionState.createBehavior();
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
      expand: false,
      append: false,
      trigger: GlideSelectionTrigger.edit,
    );
    _setGridSelection(_selectionState.selection, false);
    _scrollTo(GlideScrollTarget(col - _markerOffset, row));

    if (openOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusOnRowFromTrailingBlankRow(col, row);
      });
    }
  }

  /// `focusOnRowFromTrailingBlankRow` (`data-editor.tsx:1499-1522`).
  void _focusOnRowFromTrailingBlankRow(int col, int row) {
    final bounds = _gridController.getBounds(col, row);
    if (bounds == null) return;
    final location = GlideItem(col, row);
    final content = _getCellContent(location);
    if (!content.allowOverlay) return;
    _setOverlay(
      _OverlayState(
        target: bounds,
        content: content,
        cell: location,
        initialValue: null,
        highlight: true,
        forceEditMode: true,
        activation: const GlideKeyboardCellActivation('Enter'),
        theme: _themeForCell(content, location),
      ),
    );
  }

  /// `appendColumn` (`data-editor.tsx:1744-1793`).
  void _appendColumn(int row, {bool openOverlay = true}) {
    final p = widget.props;
    final append = p.onColumnAppended;
    if (append == null) return;

    final colsBefore = _mangledColumns.length;
    final result = append();
    _focusAfterColumnAppend(colsBefore, row, result, openOverlay, 0);
  }

  void _focusAfterColumnAppend(
    int colsBefore,
    int row,
    Object? result,
    bool openOverlay,
    int attempt,
  ) {
    if (!mounted) return;
    if (_mangledColumns.length > colsBefore) {
      _selectAppendedColumn(colsBefore, row, result, openOverlay);
      return;
    }
    if (attempt >= 10) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusAfterColumnAppend(
          colsBefore,
          row,
          result,
          openOverlay,
          attempt + 1,
        );
      }
    });
  }

  /// `doFocus` of `appendColumn` (`data-editor.tsx:1763-1786`).
  void _selectAppendedColumn(
    int colsBefore,
    int row,
    Object? result,
    bool openOverlay,
  ) {
    var col = colsBefore;
    if (result is int) {
      col = result;
    } else if (result == 'left') {
      col = 0;
    }
    col = clampInt(col, 0, math.max(0, _mangledColumns.length - 1));
    row = clampInt(row, 0, math.max(0, _mangledRows - 1));

    final behavior = _selectionState.createBehavior();
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
      expand: false,
      append: false,
      trigger: GlideSelectionTrigger.edit,
    );
    _setGridSelection(_selectionState.selection, false);
    _scrollTo(GlideScrollTarget(col - _markerOffset, row));

    if (openOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusOnRowFromTrailingBlankRow(col, row);
      });
    }
  }

  /// `getCellsForSelectionMangled` (`use-cells-for-selection.ts:42-67`).
  GlideCellArray? _getCellsForSelection(GlideRectangle region) {
    final direct = widget.props.getCellsForSelection;
    if (direct == null) return null;
    final offset = _markerOffset;
    if (offset == 0) return direct(region);

    final newX = region.x - offset;
    if (newX < 0) {
      final r = direct(region.copyWith(x: 0, width: region.width - 1));
      if (r == null) return null;
      return [
        for (final row in r) [const GlideLoadingCell(), ...row],
      ];
    }
    return direct(region.copyWith(x: newX));
  }

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
    final mangled = _mangledColumns;
    final column = location.col < mangled.length ? mangled[location.col] : null;
    var theme = p.theme;
    final group = column?.group;
    final groupOverride = group == null
        ? null
        : _groupDetails(group).overrideTheme;
    theme = theme.merge([
      groupOverride?.applyTo(theme),
      column?.themeOverride?.applyTo(theme),
      _rowThemeOverride?.call(location.row)?.applyTo(theme),
      cell.themeOverride?.applyTo(theme),
    ]);
    return theme;
  }

  /// `getMangledCellContent` (`data-editor.tsx:1309-1381`), wrapped by
  /// `DataGridDnd`'s row-remap (`data-grid-dnd.tsx:347-363`).
  GlideGridCell _getCellContent(GlideItem item, [bool? forceStrict]) {
    var col = item.col;
    var row = item.row;

    final dragRow = _dragRow;
    final dropRow = _dropRow;
    if (dragRow != null && dropRow != null) {
      if (row == dropRow) {
        row = dragRow;
      } else {
        if (row > dropRow) row -= 1;
        if (row >= dragRow) row += 1;
      }
    }

    if (_markerOffset == 1 && col == 0) return _markerCellFor(row);

    // `isTrailing` (`data-editor.tsx:1329-1347`).
    if (_showTrailingBlankRow && row == _mangledRows - 1) {
      return _newRowCell(col);
    }

    final outerCol = col - _markerOffset;
    if (forceStrict == true && _isOutsideVisibleArea(col, row)) {
      return const GlideLoadingCell();
    }

    var cell = widget.props.getCellContent(
      GlideItem(outerCol, row),
      forceStrict,
    );
    final span = cell.span;
    if (_markerOffset != 0 && span != null) {
      // Spans are reported in user coordinates (`data-editor.tsx:1374-1379`).
      cell = cell is GlideTextCell
          ? cell.copyWith(
              span: (
                start: span.start + _markerOffset,
                end: span.end + _markerOffset,
              ),
            )
          : cell;
    }
    return cell;
  }

  /// `mangledOnCellsEdited` (`data-editor.tsx:1207-1225`). Row markers are
  //  not ported, so the mangle is a pass-through today.
  bool _onCellsEdited(List<GlideEditListItem> items) {
    if (items.isEmpty) return true;
    final p = widget.props;
    final offset = _markerOffset;
    final mangled = offset == 0
        ? items
        : [
            for (final i in items)
              GlideEditListItem(
                location: GlideItem(i.location.col - offset, i.location.row),
                value: i.value,
              ),
          ];
    final r = p.onCellsEdited?.call(mangled);
    if (r != true) {
      for (final i in mangled) {
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
        getCellsForSelection: _getCellsForSelection,
        rowMarkerOffset: _markerOffset,
        allowPartial: false,
      );
    }
    // `selectionOutOfBounds` (`data-editor.ts:3951-3957`): a selection that
    // no longer fits the grid is dropped.
    final current = v.current;
    if (current != null &&
        (current.cell.col >= _mangledColumns.length ||
            current.cell.row >= _mangledRows)) {
      v = GlideGridSelection.empty;
    }

    setState(() {
      _selection = v;
      _selectionState.selection = v;
    });
    // `setGridSelection` hands the public API marker-free coordinates
    // (`data-editor.tsx:1009`).
    widget.props.onGridSelectionChange?.call(
      glideShiftSelection(v, -_markerOffset),
    );

    final focused = v.current?.cell;
    if (focused != null && focused != _lastFocusedCell) {
      _lastFocusedCell = focused;
      widget.props.onCellFocused?.call(focused);
    }
  }

  GlideItem? _lastFocusedCell;

  GlideKeyHandler _makeKeyHandler() =>
      GlideKeyHandler(
          keys: glideKeysWithDefaults(widget.props.keybindings),
          selection: _selection,
          setGridSelection: _setGridSelection,
          columnCount: _mangledColumns.length,
          rows: _mangledRows,
          rowMarkerOffset: _markerOffset,
          showTrailingBlankRow: _showTrailingBlankRow,
          userRows: widget.props.rows,
          appendRow: (col, openOverlay) =>
              _appendRow(col, openOverlay: openOverlay),
          getCustomNewRowTargetColumn: _customNewRowTargetColumn,
          onSearch: _openSearch,
          rowGroupingNavBehavior: widget.props.rowGrouping?.navigationBehavior,
          isGroupHeaderRow: _isGroupHeaderRow,
          getSelectionRowLimits: _getSelectionRowLimits,
          overlayOpen: _overlay != null,
          columnSelect: widget.props.columnSelect,
          rowSelect: widget.props.rowSelect,
          rangeSelect: widget.props.rangeSelect,
          visibleRegion: GlideRectangle(
            x: _cellXOffset.toDouble(),
            y: _cellYOffset.toDouble(),
            width: math
                .max(0, widget.props.columns.length - _cellXOffset)
                .toDouble(),
            height: math.max(1, _visibleRowCount).toDouble(),
          ),
          // `handleFixedKeybindings` works in user coordinates
          // (`data-editor.tsx:3515`, `:3154`).
          getCellContent: widget.props.getCellContent,
          getCellRenderer: _renderers.forCell,
          rangeBehavior: widget.props.rangeSelectionBlending,
          columnBehavior: widget.props.columnSelectionBlending,
          rowBehavior: widget.props.rowSelectionBlending,
          rangeSelectionColumnSpanning:
              widget.props.rangeSelectionColumnSpanning,
          getCellsForSelection: _getCellsForSelection,
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
          GlideTextCell value => value.copyWith(
            data: initialValue,
            displayData: initialValue,
          ),
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
          value: (c as GlideBooleanCell).copyWith(data: toggleBoolean(c.data)),
        ),
      ]);
    }
  }

  /// Keyboard Enter/click activation on the already-selected cell.
  void _reselectForKeyboard(
    GlideItem location,
    GlideCellActivation activation,
  ) {
    final bounds = _gridController.getBounds(location.col, location.row);
    if (bounds == null) return;
    _reselect(bounds, activation);
  }

  static double _parseFloat(String value) {
    if (value == '-') return -0.0;
    return double.tryParse(value) ?? 0.0;
  }

  void _finishEditing(GlideGridCell? newCell, GlideEditorMovement movement) {
    widget.props.onFinishedEditing?.call(newCell, movement);
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

    // `isEditingLastRow && movY === 1` (`data-editor.tsx:3101-3110`) and
    // `isEditingLastCol && movX === 1` (`:3111-3115`): moving out of the last
    // row/column appends instead of moving the selection.
    var updateSelected = true;
    if (newCell != null &&
        movement.row == 1 &&
        _showTrailingBlankRow &&
        widget.props.onRowAppended != null &&
        cell.row == _mangledRows - 1) {
      updateSelected = false;
      _appendRow(cell.col + movement.col, openOverlay: false);
    }
    if (newCell != null &&
        movement.col == 1 &&
        widget.props.onColumnAppended != null &&
        cell.col == _mangledColumns.length - 1) {
      updateSelected = false;
      _appendColumn(cell.row + movement.row, openOverlay: false);
    }
    if (!updateSelected) return;

    _updateSelectedCell(cell.col + movement.col, cell.row + movement.row);
  }

  void _updateSelectedCell(int col, int row) {
    final handler = _makeKeyHandler();
    handler.updateSelectedCell(
      col,
      row,
      fromEditingTrailingRow: false,
      freeMove: false,
    );
    if (handler.selection != _selection) {
      _setGridSelection(handler.selection, false);
    }
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
    if (patternRange == null || currentRange == null || getCells == null) {
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
            pattern[y % patternRange.height.toInt()][x %
                patternRange.width.toInt()];
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
        current: current.copyWith(range: current.range.copyWith(height: 1)),
      ),
      _selection,
    );
  }

  void _fillRight() {
    final current = _selection.current;
    if (current == null || current.range.width <= 1) return;
    _fillPattern(
      _selection.copyWith(
        current: current.copyWith(range: current.range.copyWith(width: 1)),
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
    final trailingHeight = _effectiveRowHeight.trailingHeight(
      _groupedRows,
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
        target.row >= _groupedRows - widget.props.freezeTrailingRows) {
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
    if (col < _lockColumns || col < 0 || col >= columns.length) {
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
    } else if (_dragRow != null && _dragStartY != null) {
      if ((position.dy - _dragStartY!).abs() > 20 && !_dragRowActive) {
        setState(() => _dragRowActive = true);
      }
    } else {
      _resizeDrag(position);
    }
  }

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
    _dragRow = null;
    _dropRow = null;
    _dragStartY = null;
    _dragRowActive = false;
  }

  /// `normalSizeColumn` (`data-editor.tsx:2193-2241`).
  void _normalSizeColumn(int col) {
    final p = widget.props;
    final getCells = _getCellsForSelection;
    final onResize = p.onColumnResize;
    if (p.getCellsForSelection == null || onResize == null) return;
    if (col < 0 || col >= p.columns.length) return;

    final start = _visible?.y ?? 0;
    final height = math.min(
      _visible?.height ?? 1,
      math.max(1, _groupedRows - start),
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
        hoveredCol >= _lockColumns) {
      setState(() {
        _dragColActive = true;
        _dropCol = hoveredCol;
      });
      return;
    }
    if (_dragCol != null && _dragColActive) return;

    // `dragRow !== undefined && row !== undefined` (`data-grid-dnd.tsx:136`).
    final hoveredRow = _locationOf(args).row;
    if (_dragRow != null && hoveredRow >= 0) {
      setState(() {
        _dragRowActive = true;
        _dropRow = math.max(0, hoveredRow);
        _scrollDir = args.scrollEdge;
      });
      _autoscroll.setDirection(args.scrollEdge.$1, args.scrollEdge.$2);
      _setAutoscrollActive(args.scrollEdge != (0, 0));
      return;
    }

    if (_dragColActive || _resizeCol != null || _dragRowActive) return;

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
      final row = math.min(hovered.row, _groupedRows - 1);
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
        (elapsed - _lastTick).inMicroseconds /
        1000.0; // ignore: avoid_multiple_declarations
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
      row = math.min(_groupedRows - 1, visible.y + visible.height);
    }

    col = clampInt(col, 0, widget.props.columns.length - 1);
    row = clampInt(row, 0, _mangledRows - 1);

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

    // `kind === "cell" && lockColumns > 0 && col === 0` — row dragging is
    // armed from the marker column (`data-grid-dnd.tsx:172-181`).
    if (!isFillHandle &&
        args.kind == GlideGridCellKind.cell &&
        _lockColumns > 0 &&
        _locationOf(args).col == 0 &&
        widget.props.onRowMoved != null) {
      _dragStartY = (args as GlideGridCellMouseArgs).bounds.y;
      _dragRow = _locationOf(args).row;
      _dropRow = null;
      _dragRowActive = false;
    }

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
    final isValidClick =
        a.isTouch == true ||
        (mouseDown != null &&
            mouseDown.location.col == a.location.col &&
            mouseDown.location.row == a.location.row);

    if (isValidClick) {
      p.onCellClicked?.call(
        a.location,
        GlideCellClickedEventArgs(
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
        ),
      );
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

    final activationBehavior =
        c.activationBehaviorOverride ?? p.cellActivationBehavior;
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
      final dragRow = _dragRow;
      final dropRow = _dropRow;
      if (dragRow != null && dropRow != null && _dragRowActive) {
        widget.props.onRowMoved?.call(dragRow, dropRow);
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
          final adjustedCol = groupHeader.location.col - _markerOffset;
          if (adjustedCol < 0) return;

          // `onGroupHeaderClicked` runs first; a `preventDefault` skips the
          // selection (`data-editor.ts:2504-2507`).
          var prevented = false;
          widget.props.onGroupHeaderClicked?.call(
            adjustedCol,
            GlideGroupHeaderClickedEventArgs(
              col: adjustedCol,
              args: groupHeader,
              preventDefault: () => prevented = true,
            ),
          );
          if (prevented) return;

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
        current != null && current.range.width * current.range.height > 1
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
            _mangledColumns.length - r.range.x.toInt() - _markerOffset;
        if (maxWidth > 0) {
          regions.add(
            GlideHighlight(
              color: r.color,
              range: GlideRectangle(
                x: r.range.x + _markerOffset,
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
    if (widget.props.getCellsForSelection == null) return;
    await glideCut(
      focused: _focused,
      cutEnabled: glideKeysWithDefaults(widget.props.keybindings).cut,
      selection: _selection,
      rows: widget.props.rows,
      rowMarkerOffset: _markerOffset,
      columns: widget.props.columns,
      getCellsForSelection: _getCellsForSelection,
      onDelete: (selection) => widget.props.onDelete?.call(selection) ?? true,
      copyHeaders: widget.props.copyHeaders,
    );
  }

  Future<void> _copy() async {
    if (widget.props.getCellsForSelection == null) return;
    await glideCopy(
      focused: _focused,
      copyEnabled: glideKeysWithDefaults(widget.props.keybindings).copy,
      selection: _selection,
      rows: widget.props.rows,
      rowMarkerOffset: _markerOffset,
      columns: widget.props.columns,
      getCellsForSelection: _getCellsForSelection,
      copyHeaders: widget.props.copyHeaders,
    );
  }

  Future<void> _paste() async {
    if (widget.props.getCellsForSelection == null) return;
    await glidePaste(
      focused: _focused,
      selection: _selection,
      rows: _mangledRows,
      columnCount: _mangledColumns.length,
      rowMarkerOffset: _markerOffset,
      getCellContent: widget.props.getCellContent,
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
    return (bodyHeight / _effectiveRowHeight(0)).ceil() + 1;
  }

  double get _headerHeight => widget.props.enableGroups
      ? widget.props.headerHeight + widget.props.groupHeaderHeight
      : widget.props.headerHeight;

  double _viewportHeight = 400;

  double get _rowsHeight {
    final rh = _effectiveRowHeight;
    final rows = _mangledRows;
    if (rh.isFixed) return rows * rh(0);
    var total = 0.0;
    for (var i = 0; i < rows; i++) {
      total += rh(i);
    }
    return total;
  }

  double get _maxScrollY => math.max(
    0.0,
    _rowsHeight +
        _remAdjustment.overscrollY -
        (_viewportHeight - _headerHeight),
  );

  /// `useColumnSizer`'s `nonGrowWidth` (`data-editor.tsx:1118`): the width of
  /// the columns themselves, which is what the horizontal extent is derived
  /// from (`scrolling-data-grid.tsx:105`).
  /// `nonGrowWidth` (`use-column-sizer.ts:248-250`) plus the marker column
  /// (`data-editor.tsx:1129`): the horizontal scroll extent.
  double get _columnsWidth =>
      _sizedColumns.nonGrowWidth +
      (_markerOffset == 1 ? _rowMarkerWidth : 0) +
      _remAdjustment.overscrollX;

  double get _stickyWidth {
    var total = 0.0;
    for (var i = 0; i < widget.props.freezeColumns; i++) {
      total += widget.props.columns[i].width ?? 0;
    }
    return total;
  }

  double get _maxScrollX =>
      math.max(0.0, _columnsWidth - (_viewportWidth - _stickyWidth));

  /// Derives `cellXOffset`/`cellYOffset`/`translateX`/`translateY` from the
  /// current scroll offsets (`scrolling-data-grid.tsx:121-240`).
  void _applyScroll() {
    final region = computeVisibleRegion(
      scrollX: _scrollX,
      scrollY: _scrollY,
      clientWidth: _viewportWidth,
      clientHeight: math.max(1, _viewportHeight - _headerHeight),
      // The visible region must be walked over the same columns the grid
      // draws (sized + marker), otherwise auto-sized columns report width 0
      // and every cell lands out of bounds.
      columns: mapColumns(_mangledColumns, _mangledFreezeColumns),
      rowHeight: _effectiveRowHeight,
      rows: _mangledRows,
      freezeColumns: _mangledFreezeColumns,
      smoothScrollX: widget.props.smoothScrollX,
      smoothScrollY: widget.props.smoothScrollY,
    );
    setState(() {
      _visible = region;
      _visibleExtras = _computeVisibleExtras(region);
      _cellXOffset = region.x;
      _cellYOffset = region.y;
      _translateX = region.translateX;
      _translateY = region.translateY;
    });
    widget.props.onVisibleRegionChanged?.call(region, _visibleExtras!);
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
        _rebuildRowGrouping();
        _rebuildRemAdjustment(
          p.remSize ?? MediaQuery.textScalerOf(context).scale(16),
        );
        _rebuildSizedColumns();
        _rebuildMangledColumns();

        final gridProps = GlideDataGridProps(
          width: _viewportWidth,
          height: _viewportHeight,
          columns: _mangledColumns,
          rows: _mangledRows,
          hasAppendRow: _showTrailingBlankRow,
          rowHeight: _effectiveRowHeight,
          headerHeight: _remAdjustment.headerHeight,
          // `data-editor.tsx:4276` forwards 0 when groups are off, which is
          // what keeps `computeBounds`' `totalHeaderHeight - groupHeaderHeight`
          // consistent for header rows.
          groupHeaderHeight: p.enableGroups
              ? _remAdjustment.groupHeaderHeight
              : 0,
          enableGroups: p.enableGroups,
          freezeColumns: _mangledFreezeColumns,
          freezeTrailingRows: p.freezeTrailingRows,
          cellXOffset: _cellXOffset,
          cellYOffset: _cellYOffset,
          translateX: _translateX,
          translateY: _translateY,
          getCellContent: _getCellContent,
          getCellRenderer: _renderers.forCell,
          theme: _theme,
          verticalBorder: p.verticalBorder,
          onItemHovered: _onItemHovered,
          onMouseMove: p.onMouseMove ?? (_) {},
          onPointerMoveRaw: _onPointerMoveRaw,
          onMouseDown: _onMouseDown,
          onMouseUp: _onMouseUp,
          onContextMenu: _onContextMenu,
          onCanvasFocused: () => setState(() => _focused = true),
          onCanvasBlur: () => setState(() => _focused = false),
          onCellFocused: _onAccessibilityFocused,
          onKeyDown: _handleKeyDown,
          onKeyUp: p.onKeyUp,
          selection: _selection,
          isFocused: _focused,
          drawFocusRing: p.drawFocusRing,
          fillHandle: p.fillHandle,
          disabledRows: _disabledRows,
          isResizing: _resizeCol != null,
          resizeColumn: _resizeCol,
          resizeIndicator: p.resizeIndicator,
          dragAndDropState: _dragCol != null && _dropCol != null
              ? GlideColumnDndState(src: _dragCol!, dest: _dropCol!)
              : null,
          highlightRegions: _highlightRegions(),
          getRowThemeOverride: _rowThemeOverride,
          getGroupDetails: _groupDetails,
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
                  if (_renameGroup != null)
                    GlideGroupRename(
                      bounds: _renameGroup!.bounds,
                      group: _renameGroup!.group,
                      theme: _theme,
                      onClose: () => setState(() => _renameGroup = null),
                      onFinish: _finishGroupRename,
                    ),
                  if (_showSearch)
                    GlideSearchBar(
                      value: _searchValue,
                      onChanged: _onSearchChanged,
                      status: _searchStatus,
                      rows: _mangledRows,
                      theme: _theme,
                      focusNode: _searchFocusNode,
                      textController: _searchTextController,
                      onKeyDown: _handleSearchKey,
                      onPrev: () => _searchStep(-1),
                      onNext: () => _searchStep(1),
                      showClose: widget.props.onSearchClose != null,
                      onClose: _closeSearch,
                      onCancelPointer: () {},
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// `onContextMenu` (`data-editor.tsx:3547-3571`).
  void _onContextMenu(GlideGridMouseArgs args, void Function() preventDefault) {
    final adjustedCol = _locationOf(args).col - _markerOffset;

    if (args is GlideGridHeaderMouseArgs) {
      widget.props.onHeaderContextMenu?.call(
        adjustedCol,
        GlideHeaderClickedEventArgs(
          col: adjustedCol,
          args: args,
          preventDefault: preventDefault,
        ),
      );
      return;
    }

    if (args is GlideGridGroupHeaderMouseArgs) {
      if (adjustedCol < 0) return;
      widget.props.onGroupHeaderContextMenu?.call(
        adjustedCol,
        GlideGroupHeaderClickedEventArgs(
          col: adjustedCol,
          args: args,
          preventDefault: preventDefault,
        ),
      );
      return;
    }

    if (args is GlideGridCellMouseArgs) {
      final location = args.location;
      widget.props.onCellContextMenu?.call(
        GlideItem(location.col - _markerOffset, location.row),
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
          location: location,
          bounds: args.bounds,
          isFillHandle: args.isFillHandle,
          localEventX: args.localEventX,
          localEventY: args.localEventY,
          preventDefault: preventDefault,
        ),
      );

      // Right-clicking outside the selection moves it there first.
      if (!_selection.hasItem(location)) {
        _updateSelectedCell(location.col, location.row);
      }
    }
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
