// Port of `packages/core/src/data-editor/data-editor.tsx`.
//
// Scope of this file: the selection/overlay/keyboard/clipboard spine of the
// editor — `mangledOnCellsEdited` (:1207), `setOverlaySimple` (:1428),
// `reselect` (:1445), `handleMaybeClick`/`onMouseUp` (:2367-2541),
// `highlightRegions` (:1240-1305) and the wiring of `SemiKeyHandler`,
// `SemiDataEditorSelection` and the overlay editor.
//
// Not ported yet (all `data-editor` chrome layered on the grid):
// row markers, the trailing blank row, column resizing, drag and drop, fill
// handle dragging, autoscroll and `use-column-sizer`.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../cells/semi_cell_registry.dart';
import '../cells/semi_cell_types.dart';
import '../common/semi_is_hotkey.dart';
import '../common/semi_math.dart';
import '../common/semi_utils.dart';
import '../../theme/semi_theme.dart';
import '../../theme/semi_theme_data.dart';
import '../internal/data_grid/semi_data_grid.dart';
import '../internal/data_grid/semi_event_args.dart';
import '../internal/data_grid/semi_selection_behavior.dart';
import '../internal/data_grid/semi_sprites.dart';
import '../internal/data_grid/render/semi_draw_grid_arg.dart';
import '../internal/data_grid_overlay_editor/semi_data_grid_overlay_editor.dart';
import '../internal/scrolling_data_grid/semi_autoscroll.dart';
import '../internal/scrolling_data_grid/semi_scrolling_data_grid.dart';
import 'semi_clipboard.dart';
import 'semi_data_editor_fns.dart';
import 'semi_group_rename.dart';
import 'semi_handle_select.dart';
import 'semi_column_sizer.dart';
import 'semi_key_handler.dart';
import 'semi_keybindings.dart';
import 'semi_rem_adjuster.dart';
import 'semi_row_grouping.dart';
import '../internal/data_grid_search/semi_data_grid_search.dart';

/// `DataGridProps` subset the editor owns (`data-editor.tsx`).
@immutable
class SemiDataEditorProps {
  const SemiDataEditorProps({
    required this.columns,
    required this.rows,
    required this.getCellContent,
    this.theme,
    this.onKeyDown,
    this.onKeyUp,
    this.onCellsEdited,
    this.onCellEdited,
    this.rowHeight = const SemiRowHeight.fixed(32),
    this.headerHeight = 36,
    this.groupHeaderHeight = 36,
    this.enableGroups = false,
    this.freezeColumns = 0,
    this.freezeTrailingRows = 0,
    this.verticalBorder = _alwaysTrue,
    this.drawFocusRing = true,
    this.rangeSelect = SemiRangeSelect.rect,
    this.columnSelect = SemiSelectMode.multi,
    this.rowSelect = SemiSelectMode.multi,
    this.rangeSelectionBlending = SemiSelectionBlending.exclusive,
    this.columnSelectionBlending = SemiSelectionBlending.exclusive,
    this.rowSelectionBlending = SemiSelectionBlending.exclusive,
    this.rangeSelectionColumnSpanning = true,
    this.spanRangeBehavior = SemiSpanRangeBehavior.standard,
    this.scrollToActiveCell = true,
    this.editorBloom,
    this.strict = false,
    this.columnSelectionModeMulti = false,
    this.rowMarkers,
    this.rowGrouping,
    this.trailingRowOptions,
    this.onRowAppended,
    this.onColumnAppended,
    this.rowSelectionMode = SemiSelectMode.auto,
    this.keybindings,
    this.editOnType = true,
    this.copyHeaders = false,
    this.cellActivationBehavior = SemiCellActivationBehavior.secondClick,
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
    this.resizeIndicator = SemiResizeIndicator.full,
    this.gridSelection,
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
    this.drawHeader,
    this.drawCell,
    this.getGroupDetails,
    this.highlightRegions,
    this.fillHandle,
    this.allowedFillDirections = SemiFillHandleDirection.orthogonal,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 500,
    this.maxColumnAutoWidth,
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
    this.headerIcons,
    this.onHeaderMenuClick,
    this.onHeaderIndicatorClick,
    this.validateCell,
    this.provideEditor,
  });

  static bool _alwaysTrue(int col) => true;

  final List<SemiGridColumn> columns;
  final int rows;
  final SemiGridCell Function(SemiItem cell, [bool? forceStrict])
  getCellContent;

  /// `onKeyDownIn` (`data-editor.tsx:3487`) — call `cancel()` to swallow the
  /// event before the built-in keybindings run.
  final void Function(SemiGridKeyArgs event)? onKeyDown;
  final void Function(SemiGridKeyArgs event)? onKeyUp;

  /// `onCellsEdited` returning `true` suppresses the per-cell
  /// `onCellEdited` callbacks (`data-editor.tsx:1216-1220`).
  final bool Function(List<SemiEditListItem> items)? onCellsEdited;
  final void Function(SemiItem location, SemiGridCell value)? onCellEdited;

  /// Null derives the theme from the nearest [SemiTheme], so the grid follows
  /// the host app's palette/typography and dark-mode switch. Set it to a
  /// concrete theme to opt out.
  final SemiDataGridTheme? theme;
  final SemiRowHeight rowHeight;
  final double headerHeight;
  final double groupHeaderHeight;
  final bool enableGroups;
  final int freezeColumns;
  final int freezeTrailingRows;
  final bool Function(int col) verticalBorder;
  final bool drawFocusRing;

  final SemiRangeSelect rangeSelect;
  final SemiSelectMode columnSelect;
  final SemiSelectMode rowSelect;
  final SemiSelectionBlending rangeSelectionBlending;
  final SemiSelectionBlending columnSelectionBlending;
  final SemiSelectionBlending rowSelectionBlending;
  final bool rangeSelectionColumnSpanning;

  /// `spanRangeBehavior` (`data-editor.tsx:368`): `"allowPartial"` stops
  /// `setGridSelection(..., expand: true)` from growing the range over the
  /// spans of the cells it touches.
  final SemiSpanRangeBehavior spanRangeBehavior;

  /// `scrollToActiveCell` (`data-editor.tsx:691`): false keeps the viewport
  /// put when the selection moves, instead of following it.
  final bool scrollToActiveCell;

  /// `editorBloom` (`data-editor.tsx:684`): overrides how far the overlay
  /// editor grows past the target cell
  /// (`data-grid-overlay-editor.tsx:231-251`). Null keeps the `[1, 1]`
  /// default.
  final (double, double)? editorBloom;

  /// `experimental.strict` (`data-grid.ts:249`): every content lookup outside
  /// the visible window resolves to a loading cell, not just the ones the
  /// grid marks `forceStrict`.
  final bool strict;
  final bool columnSelectionModeMulti;

  /// `rowMarkers` (`data-editor.tsx:331`): null/`none` adds no marker
  /// column.
  final SemiRowMarkerOptions? rowMarkers;

  /// `trailingRowOptions` (`data-editor.tsx:291-306`): non-null adds the
  /// "new row" row at the bottom (`:955`).
  final SemiTrailingRowOptions? trailingRowOptions;

  /// `onRowAppended` (`data-editor.tsx:221`): the owner inserts a row and
  /// returns where it landed — `"top"`, `"bottom"` (the default) or the row
  /// index to focus. A [Future] is awaited, matching the upstream `Promise`
  /// return; the editor waits for `rows` to grow before focusing the new row.
  final FutureOr<Object?> Function()? onRowAppended;

  /// `onColumnAppended` (`data-editor.tsx:225`): return `"left"`, `"right"`
  /// (the default) or a column index to control where the new column lands.
  /// A [Future] is awaited; the editor waits for the column count to grow.
  final FutureOr<Object?> Function()? onColumnAppended;

  /// `rowGrouping` (`data-editor.tsx:936`): group headers, collapse state
  /// and the per-group theme/height overrides.
  final SemiRowGroupingOptions? rowGrouping;

  /// `rowSelectionMode` (`data-editor.tsx:849`).
  final SemiSelectMode rowSelectionMode;

  final SemiKeybinds? keybindings;
  final bool editOnType;
  final bool copyHeaders;
  final SemiCellActivationBehavior cellActivationBehavior;

  final SemiGetCellsForSelection? getCellsForSelection;
  final SemiCoercePasteValue? coercePasteValue;
  final SemiPasteCallback? onPaste;

  final void Function(SemiGridMouseArgs args)? onItemHovered;

  /// The selection in data coordinates, excluding the row-marker column.
  /// When supplied, changes are proposed through [onGridSelectionChange]
  /// and take effect when the caller supplies the updated selection.
  final SemiGridSelection? gridSelection;

  /// Reports selection changes in data coordinates. With [gridSelection],
  /// reports a proposed selection for the caller to accept or replace.
  final void Function(SemiGridSelection selection)? onGridSelectionChange;
  final void Function()? onSelectionCleared;
  final SemiDeleteCallback? onDelete;
  final void Function(SemiItem location, SemiCellActivation activation)?
  onCellActivated;
  final void Function(SemiItem location, SemiCellClickedEventArgs args)?
  onCellClicked;
  final void Function(SemiItem location, SemiCellClickedEventArgs args)?
  onCellContextMenu;
  final void Function(int col, SemiGridHeaderMouseArgs args)? onHeaderClicked;

  /// `onHeaderContextMenu` / `onGroupHeaderClicked` /
  /// `onGroupHeaderContextMenu` (`data-editor.tsx:260`, `:233`, `:264`).
  final void Function(int col, SemiHeaderClickedEventArgs args)?
  onHeaderContextMenu;
  final void Function(int col, SemiGroupHeaderClickedEventArgs args)?
  onGroupHeaderClicked;
  final void Function(int col, SemiGroupHeaderClickedEventArgs args)?
  onGroupHeaderContextMenu;

  /// `onFinishedEditing` (`data-editor.tsx:256`, `:3125`).
  final void Function(SemiGridCell? newValue, SemiEditorMovement movement)?
  onFinishedEditing;

  /// `onVisibleRegionChanged` (`data-editor.ts:521`, `:2645`).
  final void Function(
    SemiVisibleRegion region,
    SemiVisibleRegionExtras extras,
  )?
  onVisibleRegionChanged;

  /// `onCellFocused` (`data-grid.tsx:171`): upstream fires it from the
  /// accessibility tree, which is not ported; here it reports the active cell
  /// whenever the selection moves.
  final void Function(SemiItem location)? onCellFocused;

  /// `onGroupHeaderRenamed` (`data-editor.tsx:241`): enabling it adds a
  /// "Rename" action to every group header (`mangledGetGroupDetails`,
  /// `:1401-1423`).
  final void Function(String groupName, String newVal)? onGroupHeaderRenamed;

  /// `onMouseMove` (`data-grid.tsx:1359`).
  final void Function(SemiGridMouseArgs args)? onMouseMove;

  /// `getRowThemeOverride` (`row-grouping.ts:298-310`): the indexed form
  /// `(row, groupIndex, contentIndex)` upstream exposes.
  final SemiGetRowThemeOverrideIndexed? getRowThemeOverride;

  /// `drawHeader` / `drawCell` (`data-grid.tsx:223,225`, re-exported on
  /// `DataEditorProps` by `data-editor.tsx:1048-1065`): take over the paint
  /// of a header or a cell. The indices are *mangled* here too; the
  /// row-marker column is stripped before the consumer sees them, matching
  /// `columnIndex - rowMarkerOffset` / `col - rowMarkerOffset` upstream.
  final SemiDrawHeaderCallback? drawHeader;
  final SemiDrawCellCallback? drawCell;
  final SemiGroupDetails Function(String group)? getGroupDetails;
  final List<SemiDataGridHighlight>? highlightRegions;

  /// `fillHandle` (`data-editor.tsx:150`): null disables the handle.
  final SemiFillHandleConfig? fillHandle;

  /// `allowedFillDirections` (`data-editor.tsx:868`).
  final SemiFillHandleDirection allowedFillDirections;

  /// `onColumnResize` / `...Start` / `...End` (`data-grid-dnd.tsx:40-70`).
  final void Function(
    SemiGridColumn column,
    double newSize,
    int colIndex,
    double newSizeWithGrow,
  )?
  onColumnResize;
  final void Function(
    SemiGridColumn column,
    double newSize,
    int colIndex,
    double newSizeWithGrow,
  )?
  onColumnResizeStart;
  final void Function(
    SemiGridColumn column,
    double newSize,
    int colIndex,
    double newSizeWithGrow,
  )?
  onColumnResizeEnd;

  /// `minColumnWidthIn`/`maxColumnWidthIn` (`data-editor.tsx:862-863`).
  final double minColumnWidth;
  final double maxColumnWidth;

  /// `maxColumnAutoWidthIn` (`data-editor.tsx:450`): the cap on how wide an
  /// auto-*sized* column may grow. Defaults to [maxColumnWidth] (`:924`).
  /// Drag-resizing is unaffected — it keeps using [maxColumnWidth].
  final double? maxColumnAutoWidth;

  /// `onColumnMoved` / `onColumnProposeMove` (`data-grid-dnd.tsx:44-57`).
  /// Returning false from [onColumnProposeMove] rejects the move.
  final void Function(int from, int to)? onColumnMoved;
  final bool? Function(int from, int to)? onColumnProposeMove;

  /// `onRowMoved` (`data-editor.tsx`): also enables the marker drag handle.
  final void Function(int from, int to)? onRowMoved;

  /// `lockColumns` (`data-grid-dnd.tsx:133`): columns before this index are
  /// not drop targets.
  final int lockColumns;

  final SemiResizeIndicator resizeIndicator;

  /// `onFillPattern` (`data-editor.tsx:2258`): called before the fill runs;
  /// call `preventDefault()` to cancel it.
  final void Function(SemiFillPatternArgs args)? onFillPattern;

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

  /// External matches in data coordinates, without the row-marker column.
  final List<SemiItem>? searchResults;
  final void Function(String newVal)? onSearchValueChange;
  final void Function(List<SemiItem> results, int navIndex)?
  onSearchResultsChanged;
  final void Function()? onSearchClose;
  final SemiRendererLookup? rendererLookup;

  /// `onHeaderMenuClick` (`data-editor.tsx:2569-2574`): the header's menu
  /// button was clicked. The column arrives in *user* space; the editor strips
  /// the row-marker offset on the way out, exactly as upstream's
  /// `onHeaderMenuClickInner` does.
  final void Function(int col, SemiRectangle screenPosition)?
  onHeaderMenuClick;

  /// `onHeaderIndicatorClick` (`data-editor.tsx:2576-2581`): the header's
  /// indicator icon was clicked. Same offset handling as
  /// [onHeaderMenuClick].
  final void Function(int col, SemiRectangle screenPosition)?
  onHeaderIndicatorClick;

  /// `headerIcons` (`data-editor-all.tsx:13-15`): extra sprites layered over
  /// the built-in set, which is what `DataEditorAll` does before handing them
  /// to the grid. The editor owns that merge because it is the "all renderers"
  /// entry point of this port, exactly as `DataEditorAll` is upstream.
  final Map<String, SemiSpriteFn>? headerIcons;

  /// `validateCell` (`data-editor.tsx:277-281`): runs when the overlay editor
  /// opens and on every proposed value. Return `false` to reject the value
  /// (the editor is marked invalid and commits nothing), a cell to replace
  /// it with a coerced value, or anything else to accept. [cell] is in
  /// business coordinates, without the row-marker column.
  final Object? Function(
    SemiItem cell,
    SemiGridCell newValue,
    SemiGridCell prevValue,
  )?
  validateCell;

  /// `provideEditor` (`data-editor.tsx:478`): overrides the renderer's editor
  /// for every cell. Return null to fall back to the renderer. [location] is
  /// in business coordinates, without the row-marker column.
  final SemiEditorProvider? Function(SemiGridCell cell, SemiItem location)?
  provideEditor;
}

/// `SemiDataEditor`: `DataGrid` + selection + overlay editor + clipboard.
/// The events [SemiDataEditorController.emit] can fire, matching upstream's
/// `EmitEvents` (`data-editor.tsx:166`). `cut` is deliberately absent.
enum SemiEmitEvent { copy, paste, delete, fillRight, fillDown }

/// `DataEditorRef` (`data-editor.tsx:701-760`): programmatic control of the
/// editor. Every column/row index is a *business* coordinate — the row-marker
/// column is stripped before a value reaches the grid, and added back before
/// one is reported.
///
/// The controller is inert until it is handed to a mounted [SemiDataEditor];
/// calls made before that (or after the editor is disposed) are no-ops.
class SemiDataEditorController {
  _SemiDataEditorState? _state;

  void _attach(_SemiDataEditorState state) => _state = state;

  void _detach(_SemiDataEditorState state) {
    if (identical(_state, state)) _state = null;
  }

  /// `appendRow` (`data-editor.tsx:710`): appends a row focused at [col] and
  /// resolves once the caller has written the new row back and it has been
  /// selected (or the post-frame polling gives up).
  Future<void> appendRow(int col, {bool openOverlay = true}) {
    final state = _state;
    if (state == null) return Future<void>.value();
    return state._appendRow(
      col + state._markerOffset,
      openOverlay: openOverlay,
    );
  }

  /// `appendColumn` (`data-editor.tsx:716`): same contract as [appendRow].
  Future<void> appendColumn(int row, {bool openOverlay = true}) =>
      _state?._appendColumn(row, openOverlay: openOverlay) ??
      Future<void>.value();

  /// `updateCells` (`data-editor.tsx:721`): asks for a repaint of [cells].
  void updateCells(Iterable<SemiItem> cells) => _state?._updateCells(cells);

  /// `getBounds` (`data-editor.tsx:726`): canvas-local bounds of [col]/[row],
  /// or null when the cell is off-screen. With both omitted, returns the full
  /// scrollable content rectangle instead of a single cell.
  SemiRectangle? getBounds(int? col, int? row) =>
      _state?._controllerGetBounds(col, row);

  /// `focus` (`data-editor.tsx:731`): moves keyboard focus to the grid.
  void focus() => _state?._gridController.focus();

  /// `emit` (`data-editor.tsx:736`): fires an event as if the user had
  /// triggered it, so `props.onKeyDown` still gets the chance to cancel.
  Future<void> emit(SemiEmitEvent event) =>
      _state?._emit(event) ?? Future<void>.value();

  /// `scrollTo` (`data-editor.tsx:741`): scrolls the cell into view. Only the
  /// cell-addressed form of the upstream signature is ported; pixel amounts,
  /// alignment and `padding` have no equivalent here.
  void scrollTo(int col, int row, {SemiScrollAxis? axis}) => _state
      ?._scrollTo(
        SemiScrollTarget(
          col,
          row,
          axis: axis ?? SemiScrollAxis.both,
        ),
      );

  /// `remeasureColumns` (`data-editor.tsx:746`): re-measures each column in
  /// [cols] and re-emits `onColumnResize`.
  void remeasureColumns(SemiCompactSelection cols) =>
      _state?._remeasureColumns(cols);

  /// `getMouseArgsForPosition` (`data-editor.tsx:751`): hit-tests a pointer
  /// position with hover-style button state and the current keyboard
  /// modifiers. The returned event's location is marker-free.
  SemiGridMouseArgs? getMouseArgsForPosition(double x, double y) =>
      _state?._mouseArgsForPosition(x, y);
}

class SemiDataEditor extends StatefulWidget {
  const SemiDataEditor({super.key, required this.props, this.controller});

  final SemiDataEditorProps props;

  /// Optional programmatic handle; see [SemiDataEditorController].
  final SemiDataEditorController? controller;

  @override
  State<SemiDataEditor> createState() => _SemiDataEditorState();
}

class _SemiDataEditorState extends State<SemiDataEditor>
    with TickerProviderStateMixin {
  final SemiDataGridController _gridController = SemiDataGridController();

  late SemiGridSelection _selection;
  late SemiDataEditorSelection _selectionState;

  int _cellXOffset = 0;
  int _cellYOffset = 0;
  double _translateX = 0;
  double _translateY = 0;
  double _scrollY = 0;
  bool _focused = false;

  /// Resolved from the surrounding SemiTheme in [build]; before the first
  /// build (initState/didUpdateWidget) the default light Semi theme is used.
  SemiDataGridTheme _semiTheme = SemiDataGridTheme.fromSemiTheme(const SemiThemeData.light());

  _OverlayState? _overlay;

  /// Bumped whenever cells change so the grid's cached accessibility tree
  /// does not serve stale labels.
  int _a11yRevision = 0;

  /// Search state (`data-grid-search.ts:109-149`).
  bool _showSearchInner = false;
  String _searchValueInner = '';
  List<SemiItem> _searchResultsInner = const [];
  List<SemiItem>? _searchResultsControlled;
  SemiSearchStatus? _searchStatus;
  int _searchSelectedIndex = -1;
  int _searchRequest = 0;
  final SemiSearchRunner _searchRunner = SemiSearchRunner();
  late final TextEditingController _searchTextController;
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'SemiSearch');

  /// `isAnimatingOut` (`data-grid-search.ts:374-390`): the bar stays
  /// mounted for 150ms after `showSearch` goes false so `gdg-search-fadeout`
  /// has somewhere to run, and is unmounted the moment it comes back on.
  bool _searchAnimatingOut = false;
  Timer? _searchFadeTimer;

  bool get _showSearch => widget.props.showSearch ?? _showSearchInner;
  String get _searchValue => widget.props.searchValue ?? _searchValueInner;
  List<SemiItem> get _searchResults =>
      _searchResultsControlled ?? _searchResultsInner;

  /// `lastMouseDownData` (`data-editor.tsx:2091`).
  ({int button, SemiItem location})? _mouseDownData;

  /// `lastMouseSelectLocation` (`data-editor.tsx:2089`).

  /// `mouseState.previousSelection` (`data-editor.tsx:2120`): the selection
  /// as it was *before* the press, which is what second-click activation
  /// compares against.
  SemiGridSelection? _previousSelection;

  /// `hoveredRef` (`data-editor.tsx:2729`).
  SemiGridMouseArgs? _hoveredArgs;

  /// `scrollDir` (`data-editor.tsx:2243`).
  (int, int)? _scrollDir;

  /// `mouseState.fillHandle` (`data-editor.tsx:2120`).
  bool _fillHandlePressed = false;

  /// `fillHighlightRegion` (`data-editor.tsx:1227`).
  SemiRectangle? _fillHighlightRegion;

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
  SemiVisibleRegion? _visible;
  SemiVisibleRegionExtras? _visibleExtras;

  late final Ticker _autoscrollTicker;
  Duration _lastTick = Duration.zero;
  final SemiAutoscroll _autoscroll = SemiAutoscroll();

  /// Touch scrolling. The browser's native scroll that Glide relies on has no
  /// Flutter equivalent, so the editor drives `_scrollX`/`_scrollY` itself. A
  /// touch that moved past [kTouchSlop] is a drag: it scrolls instead of
  /// selecting, and on release the selection path is skipped — upstream does
  /// the same by comparing the visible region captured on press
  /// (`data-editor.tsx:2438-2443`).
  bool _touchDragged = false;
  Offset? _touchDownPosition;
  Offset? _touchLastPosition;
  Duration? _touchLastMoveTime;
  Offset _touchVelocity = Offset.zero;
  late final Ticker _inertiaTicker;
  Duration _lastInertiaTick = Duration.zero;
  Offset _inertiaVelocity = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _selection = SemiGridSelection.empty;
    _rebuildRowGrouping();
    _rebuildRemAdjustment(16);
    _rebuildSizedColumns();
    _rebuildMangledColumns();
    final controlled = widget.props.gridSelection;
    if (controlled != null) _selection = _controlledSelection(controlled);
    _selectionState = _makeSelectionState();
    _syncSelectionAnchors();
    _searchTextController = TextEditingController(text: _searchValue);
    _searchAnimatingOut = _showSearch;
    _autoscrollTicker = createTicker(_onAutoscrollTick);
    _inertiaTicker = createTicker(_onInertiaTick);

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
    if (controlled != null) _scheduleControlledSelectionChange(_selection.current?.cell);
    _refreshSearch();
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _searchFadeTimer?.cancel();
    _searchRunner.cancel();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _autoscrollTicker.dispose();
    _inertiaTicker.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Search (`internal/data-grid-search/data-grid-search.tsx`)
  // -------------------------------------------------------------------------

  void _openSearch() {
    setState(() {
      _showSearchInner = true;
      _searchValueInner = '';
      _refreshSearch();
    });
    _syncSearchText();
    widget.props.onSearchResultsChanged?.call(const [], -1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
    _syncSearchFade();
  }

  void _closeSearch() {
    setState(() {
      _showSearchInner = false;
      _searchValueInner = '';
      _refreshSearch(runInternal: false);
    });
    _syncSearchText();
    widget.props.onSearchClose?.call();
    widget.props.onSearchResultsChanged?.call(const [], -1);
    _gridController.focus();
    _syncSearchFade();
  }

  /// The `useEffect` on `showSearch` (`data-grid-search.ts:377-384`): on,
  /// mark the bar visible; off, give it 150ms to slide out before unmounting.
  void _syncSearchFade() {
    _searchFadeTimer?.cancel();
    _searchFadeTimer = null;
    if (_showSearch) {
      if (!_searchAnimatingOut) setState(() => _searchAnimatingOut = true);
      return;
    }
    if (!_searchAnimatingOut) return;
    _searchFadeTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _searchAnimatingOut = false);
    });
  }

  void _syncSearchText() {
    final value = _searchValue;
    if (_searchTextController.text == value) return;
    _searchTextController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  /// Resets navigation and switches between caller-provided and scanned hits.
  void _refreshSearch({bool runInternal = true}) {
    _searchRunner.cancel();
    final request = ++_searchRequest;
    _searchSelectedIndex = -1;
    _searchResultsInner = const [];
    _searchStatus = null;

    final external = widget.props.searchResults;
    _searchResultsControlled = external == null
        ? null
        : [
            for (final item in external)
              SemiItem(item.col + _markerOffset, item.row),
          ];
    if (external != null) {
      if (external.isNotEmpty) {
        _searchStatus = SemiSearchStatus(
          rowsSearched: _mangledRows,
          results: external.length,
          selectedIndex: -1,
        );
      }
      return;
    }

    final query = _searchValue;
    if (!runInternal ||
        !_showSearch ||
        query.isEmpty ||
        widget.props.getCellsForSelection == null) {
      return;
    }
    // Props can change during build. Start after layout so result callbacks
    // may update the parent and the scan can use the current viewport.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && request == _searchRequest) _runSearch(query);
    });
  }

  /// `onSearchChange` (`data-grid-search.ts:285-298`).
  void _onSearchChanged(String value) {
    final previouslyEffective = _searchValue;
    setState(() {
      _searchValueInner = value;
      if (_searchValue != previouslyEffective &&
          widget.props.searchResults == null) {
        _refreshSearch();
      }
    });
    widget.props.onSearchValueChange?.call(value);
    if (widget.props.searchValue != null) {
      // Let the owner accept the edit this frame; otherwise restore its value.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncSearchText();
      });
    }
  }

  Future<void> _runSearch(String value) async {
    await _searchRunner.search(
      pattern: value,
      rows: _mangledRows,
      columnCount: _mangledColumns.length,
      startY: clampInt(_cellYOffset, 0, math.max(0, _mangledRows - 1)),
      getCells: _getCellsForSelection,
      onResults: (results) => setState(() => _searchResultsInner = results),
      onStatus: (status) => setState(() {
        _searchStatus = SemiSearchStatus(
          rowsSearched: status.rowsSearched,
          results: status.results,
          selectedIndex: _searchSelectedIndex,
        );
      }),
      // Later batches grow the results but never undo an explicit step.
      onResultsChanged: (results, _) =>
          _onSearchResultsChanged(results, _searchSelectedIndex),
      selectedIndex: -1,
    );
  }

  /// `onSearchResultsChanged` (`data-editor.tsx:3910-3928`).
  ///
  /// The runner indexes the rows `_getCellsForSelection` hands back, which
  /// still carry the marker column, so its results are in *mangled* space
  /// (`semi_data_grid_search.dart:130`). A consumer therefore gets the
  /// marker stripped (`:3913-3915`); with no consumer the editor moves the
  /// selection itself, and that is also what scrolls to the match
  /// (`:3926`).
  ///
  /// Upstream's `lastSent` guard (`:3922-3924`, cleared at `:3062-3064`) is
  /// not ported: it only suppresses a repeat call to `updateSelectedCell`,
  /// which already returns without scrolling when the cell is unchanged, so
  /// nothing observable depends on it.
  void _onSearchResultsChanged(List<SemiItem> results, int navIndex) {
    final consumer = widget.props.onSearchResultsChanged;
    if (consumer != null) {
      consumer([
        for (final item in results)
          SemiItem(item.col - _markerOffset, item.row),
      ], navIndex);
      return;
    }
    if (results.isEmpty || navIndex < 0 || navIndex >= results.length) return;
    final item = results[navIndex];
    if (item.col < _markerOffset ||
        item.col >= _mangledColumns.length ||
        item.row < 0 ||
        item.row >= _mangledRows) {
      return;
    }
    _updateSelectedCell(item.col, item.row);
  }

  /// `onNext` / `onPrev` (`data-grid-search.ts:321-348`).
  void _searchStep(int delta) {
    final status = _searchStatus;
    if (status == null || status.results == 0) return;
    final selected = status.selectedIndex;
    final newIndex = selected < 0
        ? (delta < 0 ? status.results - 1 : 0)
        : (selected + delta) % status.results;

    setState(() {
      _searchSelectedIndex = newIndex;
      _searchStatus = SemiSearchStatus(
        rowsSearched: status.rowsSearched,
        results: status.results,
        selectedIndex: newIndex,
      );
    });

    // `onSearchResultsChanged?.(searchResults, newIndex)`
    // (`data-grid-search.tsx:331`, `:346`).
    _onSearchResultsChanged(_searchResults, newIndex);
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
  void didUpdateWidget(SemiDataEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    final old = oldWidget.props;
    final props = widget.props;
    final searchVisibilityChanged =
        (old.showSearch ?? _showSearchInner) != _showSearch;
    // A controlled `showSearch` flips without going through
    // `_openSearch`/`_closeSearch`, so the fade is synced here too.
    if (searchVisibilityChanged) _syncSearchFade();
    final oldMarkerOffset = _mangledColumns.length - old.columns.length;
    final previousSelection = _selection;
    final geometryChanged = old.columns != props.columns ||
        old.rows != props.rows ||
        old.rowMarkers != props.rowMarkers ||
        old.rowGrouping != props.rowGrouping ||
        old.rowHeight != props.rowHeight ||
        (old.onRowAppended == null) != (props.onRowAppended == null);
    if (geometryChanged) {
      _rebuildRowGrouping();
      _rebuildRemAdjustment(16);
      _rebuildSizedColumns();
      _rebuildMangledColumns();
    }
    final controlled = props.gridSelection;
    if (controlled != null) {
      _selection = _controlledSelection(controlled);
    } else if (geometryChanged) {
      _selection = _clipSelection(
        semiShiftSelection(_selection, _markerOffset - oldMarkerOffset),
        allowTrailingRow: true,
      );
    }
    if (geometryChanged || old.rangeSelect != props.rangeSelect ||
        old.columnSelect != props.columnSelect || old.rowSelect != props.rowSelect ||
        old.rangeSelectionBlending != props.rangeSelectionBlending ||
        old.columnSelectionBlending != props.columnSelectionBlending ||
        old.rowSelectionBlending != props.rowSelectionBlending ||
        old.rangeSelectionColumnSpanning != props.rangeSelectionColumnSpanning ||
        old.columnSelectionModeMulti != props.columnSelectionModeMulti ||
        old.rowSelectionMode != props.rowSelectionMode ||
        old.onRowMoved != props.onRowMoved) {
      _selectionState = _makeSelectionState();
    } else {
      _selectionState.selection = _selection;
    }
    if (_selection != previousSelection || geometryChanged) {
      _syncSelectionAnchors();
    }
    final focused = _selection.current?.cell;
    if (controlled != null && focused != previousSelection.current?.cell) {
      _scheduleControlledSelectionChange(focused);
    }
    final queryChanged = (old.searchValue ?? _searchValueInner) != _searchValue;
    if (queryChanged) _syncSearchText();
    final resultSourceChanged = !listEquals(
      old.searchResults,
      props.searchResults,
    );
    final searchGeometryChanged =
        old.columns.length != props.columns.length ||
        old.rows != props.rows ||
        old.rowMarkers != props.rowMarkers ||
        old.rowGrouping != props.rowGrouping;
    if (resultSourceChanged ||
        searchGeometryChanged ||
        (props.searchResults == null &&
            (queryChanged ||
                searchVisibilityChanged ||
                (old.getCellsForSelection == null) !=
                    (props.getCellsForSelection == null)))) {
      _refreshSearch();
    }
  }

  SemiDataEditorSelection _makeSelectionState() => SemiDataEditorSelection(
    behaviorConfig: SemiBehaviorConfig(
      rangeBehavior: widget.props.rangeSelectionBlending,
      columnBehavior: widget.props.columnSelectionBlending,
      rowBehavior: widget.props.rowSelectionBlending,
      rangeSelect: widget.props.rangeSelect,
      rangeSelectionColumnSpanning: widget.props.rangeSelectionColumnSpanning,
      columnSelectEnabled: widget.props.columnSelect != SemiSelectMode.none,
      columnSelectionModeMulti: widget.props.columnSelectionModeMulti,
    ),
    rows: _groupedRows,
    rowSelectMulti: widget.props.rowSelect == SemiSelectMode.multi,
    columnSelectMulti: widget.props.columnSelect == SemiSelectMode.multi,
    rowMarkerOffset: _markerOffset,
    hasRowMarkers: _hasRowMarkers,
    rowMarkersAreNumbers:
        _rowMarkers == SemiRowMarkerKind.number ||
        _rowMarkers == SemiRowMarkerKind.none,
    rowSelectEnabled: widget.props.rowSelect != SemiSelectMode.none,
    rowSelectionModeMulti:
        widget.props.rowSelectionMode == SemiSelectMode.multi,
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

  SemiRowMarkerOptions? get _rowMarkerOpts => widget.props.rowMarkers;
  SemiRowMarkerKind get _rowMarkers =>
      _rowMarkerOpts?.kind ?? SemiRowMarkerKind.none;
  bool get _hasRowMarkers => _rowMarkers != SemiRowMarkerKind.none;
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
      widget.props.rowSelect != SemiSelectMode.multi ||
      (_rowMarkerOpts?.headerDisabled ?? false);

  /// `rowMarkerChecked` (`data-editor.tsx:1139`).
  SemiBooleanValue get _headerRowMarkerChecked {
    final selected = _selection.rows.length;
    if (selected == 0) return SemiBooleanValue.unchecked;
    if (selected == _groupedRows) return SemiBooleanValue.checked;
    return SemiBooleanValue.empty;
  }

  SemiMarkerKind get _markerKind => switch (_rowMarkers) {
    SemiRowMarkerKind.checkbox => SemiMarkerKind.checkbox,
    SemiRowMarkerKind.number ||
    SemiRowMarkerKind.clickableNumber => SemiMarkerKind.number,
    SemiRowMarkerKind.checkboxVisible => SemiMarkerKind.checkboxVisible,
    SemiRowMarkerKind.both => SemiMarkerKind.both,
    SemiRowMarkerKind.none => SemiMarkerKind.checkbox,
  };

  /// `useRemAdjuster` result (`use-rem-adjuster.ts:15-47`); set in
  /// `initState`, which can already take the identity path.
  late SemiRemAdjustment _remAdjustment;

  /// `useRowGroupingInner` result (`row-grouping.ts:247-326`).
  SemiRowGroupingResult _rowGrouping = const SemiRowGroupingResult(
    rows: 0,
    flattened: [],
  );
  SemiRowGroupingOptions? _rowGroupingOpts;
  int _rowGroupingRawRows = -1;
  SemiRowHeight? _rowGroupingBaseHeight;

  /// The row count the grid works in: the raw count, or the grouped count
  /// when `rowGrouping` is set (`data-editor.tsx:936`).
  int get _groupedRows => _rowGrouping.rows;

  /// `rowHeight` after `useRowGroupingInner` (`row-grouping.ts:270`) and
  /// `useRemAdjuster` (`use-rem-adjuster.ts:21`) have both wrapped it.
  SemiRowHeight get _effectiveRowHeight => _remAdjustment.rowHeight;

  /// The rem-scaled theme (`use-rem-adjuster.ts:34-40`).
  SemiDataGridTheme get _theme => _remAdjustment.theme;

  /// `getRowThemeOverride` adapted to the grid's one-argument signature.
  SemiGetRowThemeOverride? get _rowThemeOverride =>
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
  SemiSizedColumns _sizedColumns = const SemiSizedColumns(
    columns: [],
    nonGrowWidth: 0,
  );
  List<SemiGridColumn>? _sizedKeyColumns;
  double _sizedKeyWidth = -1;
  int _sizedKeyRows = -1;
  final Map<String, double> _columnSizeMemo = {};

  /// `mangledCols` (`data-editor.tsx:1141-1169`); rebuilt whenever the
  /// columns or the marker options change.
  List<SemiGridColumn> _mangledColumns = const [];

  /// `useColumnSizer` (`use-column-sizer.ts:108-217`).
  /// `useRemAdjuster` (`data-editor.tsx:939-948`), which runs after
  /// `useRowGroupingInner` (`:936`).
  void _rebuildRemAdjustment(double remSize) {
    final p = widget.props;
    final grouped = _rowGrouping.rowHeight == null
        ? p.rowHeight
        : SemiRowHeight.variable(_rowGrouping.rowHeight!);
    _remAdjustment = semiRemAdjuster(
      scaleToRem: p.scaleToRem,
      remSize: remSize,
      rowHeightIn: grouped,
      headerHeightIn: p.headerHeight,
      groupHeaderHeightIn: p.groupHeaderHeight,
      themeIn: p.theme ?? _semiTheme,
      overscrollXIn: p.overscrollX,
      overscrollYIn: p.overscrollY,
    );
  }

  /// `minColumnWidth` / `maxColumnWidth` / `maxColumnAutoWidth`
  /// (`data-editor.tsx:922-924`): the raw props floored so the minimum can
  /// never exceed the maximum, plus the auto-sizing cap that defaults to
  /// `maxColumnWidth`.
  double get _minColumnWidth => math.max(widget.props.minColumnWidth, 20);

  double get _maxColumnWidth =>
      math.max(widget.props.maxColumnWidth, _minColumnWidth);

  double get _maxColumnAutoWidth => math.max(
    widget.props.maxColumnAutoWidth ?? _maxColumnWidth,
    _minColumnWidth,
  );

  void _rebuildSizedColumns() {
    final p = widget.props;
    if (identical(_sizedKeyColumns, p.columns) &&
        _sizedKeyWidth == _viewportWidth &&
        _sizedKeyRows == p.rows) {
      _resolveSizerSample();
      return;
    }
    _sizedKeyColumns = p.columns;
    _sizedKeyWidth = _viewportWidth;
    _sizedKeyRows = p.rows;
    _sizerResolved.clear();
    _sizedColumns = useColumnSizer(
      columns: p.columns,
      rows: p.rows,
      getCellsForSelection: _sizerFetchSample,
      clientWidth: _viewportWidth,
      minColumnWidth: _minColumnWidth,
      // `useColumnSizer`'s `maxColumnWidth` parameter is fed
      // `maxColumnAutoWidth` upstream (`data-editor.tsx:1118-1126`).
      maxColumnWidth: _maxColumnAutoWidth,
      theme: _theme,
      getCellRenderer: _renderers.forCell,
      metrics: _metrics,
      memo: _columnSizeMemo,
    );
    _resolveSizerSample();
  }

  /// Synchronous shim for [useColumnSizer]: remote data parks its sample here
  /// and [_resolveSizerSample] re-runs the sizer once it arrives, mirroring
  /// upstream's deferred layout-effect measurement. Resolved regions are
  /// remembered so the re-run cannot fetch them (and park them) again.
  SemiCellArray? _sizerFetchSample(SemiRectangle region) {
    final cached = _sizerResolved[region];
    if (cached != null) return cached;
    final result = widget.props.getCellsForSelection?.call(region);
    if (result is! Future<SemiCellArray?>) return result;
    _pendingSizerSample = result.then((cells) {
      final value = cells ?? const <List<SemiGridCell>>[];
      _sizerResolved[region] = value;
      return (region, value);
    });
    return null;
  }

  final Map<SemiRectangle, SemiCellArray> _sizerResolved = {};
  Future<(SemiRectangle, SemiCellArray)>? _pendingSizerSample;
  int _sizerGeneration = 0;

  void _resolveSizerSample() {
    final pending = _pendingSizerSample;
    if (pending == null) return;
    _pendingSizerSample = null;
    final generation = ++_sizerGeneration;
    pending.then((_) {
      if (!mounted || generation != _sizerGeneration) return;
      setState(() {
        _sizedColumns = useColumnSizer(
          columns: widget.props.columns,
          rows: widget.props.rows,
          getCellsForSelection: _sizerFetchSample,
          clientWidth: _viewportWidth,
          minColumnWidth: _minColumnWidth,
          maxColumnWidth: _maxColumnAutoWidth,
          theme: _theme,
          getCellRenderer: _renderers.forCell,
          metrics: _metrics,
          memo: _columnSizeMemo,
        );
        _rebuildMangledColumns();
      });
    });
  }

  List<SemiGridColumn>? _mangledKeySized;
  Object? _mangledKeyExtra;

  /// `mangledCols` (`data-editor.tsx:1141-1169`).
  ///
  /// Rebuilt only when the sized columns or the marker column's state change,
  /// so hover-driven rebuilds hand the grid (and the accessibility tree) the
  /// same list instance.
  void _rebuildMangledColumns() {
    final opts = _rowMarkerOpts;
    if (!_hasRowMarkers || opts == null) {
      if (!identical(_mangledKeySized, _sizedColumns.columns)) {
        _mangledKeySized = _sizedColumns.columns;
        _mangledKeyExtra = null;
        _mangledColumns = _sizedColumns.columns;
      }
      return;
    }

    final extra = (_headerRowMarkerChecked, _rowMarkerWidth, opts);
    if (identical(_mangledKeySized, _sizedColumns.columns) &&
        _mangledKeyExtra == extra) {
      return;
    }
    _mangledKeySized = _sizedColumns.columns;
    _mangledKeyExtra = extra;

    _mangledColumns = [
      SemiGridColumn(
        title: '',
        width: _rowMarkerWidth.toDouble(),
        hasMenu: false,
        style: SemiColumnStyle.normal,
        themeOverride: opts.theme,
        extension: SemiInnerColumnExtension(
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

  /// `onCellFocused` (`data-editor.tsx:4124-4145`): the accessibility tree
  /// reporting that a cell (or header) took focus — the editor turns that
  /// into a selection.
  void _onAccessibilityFocused(SemiItem cell) {
    if (cell.row == SemiItem.headerRow) {
      if (widget.props.columnSelect == SemiSelectMode.none) return;
      _selectionState.createBehavior().setSelectedColumns(
        newCols: SemiCompactSelection.fromSingleSelection(cell.col),
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
        range: SemiRectangle(
          x: cell.col.toDouble(),
          y: cell.row.toDouble(),
          width: 1,
          height: 1,
        ),
      ),
      expand: true,
      append: false,
      trigger: SemiSelectionTrigger.keyboardNav,
    );
    _setGridSelection(_selectionState.selection, true);
    _scrollTo(SemiScrollTarget(cell.col - _markerOffset, cell.row));
  }

  // -------------------------------------------------------------------------
  // Trailing row, row markers, group details and visible-region extras.
  // (`data-editor.tsx:953-956`, `:1141-1169`, `:1309-1423`, `:2594-2725`)
  // -------------------------------------------------------------------------

  /// `showTrailingBlankRow` (`data-editor.tsx:955`).
  bool get _showTrailingBlankRow => widget.props.trailingRowOptions != null;

  /// `mangledRows` (`data-editor.tsx:1205`).
  int get _mangledRows =>
      _showTrailingBlankRow ? _groupedRows + 1 : _groupedRows;

  /// `freezeTrailingRows + (showTrailingBlankRow && lastRowSticky ? 1 : 0)`
  /// (`data-editor.tsx:1581,4278`): a `trailingRowOptions.sticky` row is
  /// always visible, so it joins the frozen trailing rows.
  int get _effectiveFreezeTrailingRows =>
      widget.props.freezeTrailingRows +
      (_showTrailingBlankRow && widget.props.trailingRowOptions?.sticky == true
          ? 1
          : 0);

  /// `trailingRowOptions.tint` (`data-editor.ts:3961-3965`): the trailing
  /// row joins `disabledRows`, which the painter tints with `bgHeader`.
  SemiCompactSelection get _disabledRows =>
      _showTrailingBlankRow && widget.props.trailingRowOptions?.tint == true
      ? SemiCompactSelection.fromArray([_mangledRows - 1])
      : const SemiCompactSelection.empty();

  /// `lockColumns={rowMarkerOffset}` (`data-editor.tsx:4263`): the marker
  /// column is never a drop target.
  int get _lockColumns => math.max(widget.props.lockColumns, _markerOffset);

  /// `mangledFreezeColumns` (`data-editor.tsx:3994`).
  int get _mangledFreezeColumns => math.min(
    _mangledColumns.length,
    widget.props.freezeColumns + (_hasRowMarkers ? 1 : 0),
  );

  /// `mangledGetGroupDetails` (`data-editor.tsx:1401-1423`): the user's
  /// callback plus the Rename action when `onGroupHeaderRenamed` is set.
  SemiGroupDetails _groupDetails(String group) {
    final base =
        widget.props.getGroupDetails?.call(group) ??
        SemiGroupDetails(name: group);
    final onRename = widget.props.onGroupHeaderRenamed;
    if (onRename == null) return base;

    return SemiGroupDetails(
      name: base.name,
      icon: base.icon,
      overrideTheme: base.overrideTheme,
      actions: [
        ...?base.actions,
        SemiGroupAction(
          title: 'Rename',
          icon: Icons.edit,
          onClick: (bounds) => _beginGroupRename(group, bounds),
        ),
      ],
    );
  }

  /// `setRenameGroup` (`data-editor.tsx:1435-1438`).
  void _beginGroupRename(String group, SemiRectangle bounds) {
    setState(() => _renameGroup = (group: group, bounds: bounds));
  }

  ({String group, SemiRectangle bounds})? _renameGroup;

  void _finishGroupRename(String newValue) {
    final renaming = _renameGroup;
    setState(() => _renameGroup = null);
    if (renaming == null) return;
    widget.props.onGroupHeaderRenamed?.call(renaming.group, newValue);
  }

  /// `rowNumberMapper(row) === undefined` means the row is a group header,
  /// which gets a loading placeholder in the marker column
  /// (`data-editor.tsx:1317-1319`).
  SemiGridCell _markerCellFor(int row) {
    final mapper = _rowGrouping.rowNumberMapper;
    final mappedRow = mapper == null ? row : mapper(row);
    if (mappedRow == null) return const SemiLoadingCell();
    return _markerCellAt(mappedRow, row);
  }

  SemiMarkerCell _markerCellAt(int mappedRow, int row) => SemiMarkerCell(
    row: (_rowMarkerOpts?.startIndex ?? 1) + mappedRow,
    drawHandle: widget.props.onRowMoved != null,
    checked: _selection.rows.hasIndex(row)
        ? SemiBooleanValue.checked
        : SemiBooleanValue.unchecked,
    checkboxStyle:
        _rowMarkerOpts?.checkboxStyle ?? SemiMarkerCheckboxStyle.square,
    markerKind: _markerKind,
  );

  /// The `NewRow` cell for the trailing row (`data-editor.tsx:1330-1347`).
  SemiGridCell _newRowCell(int col) {
    final column = _mangledColumns[col];
    if (column.trailingRowOptions?.disabled == true) {
      return const SemiLoadingCell();
    }
    final editorOpts = widget.props.trailingRowOptions;
    final isFirst = col == _markerOffset;
    final maybeFirstColumnHint = isFirst ? (editorOpts?.hint ?? '') : '';
    final hint = column.trailingRowOptions?.hint ?? maybeFirstColumnHint;
    return SemiNewRowCell(
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
    if (custom is SemiGridColumn) {
      final index = p.columns.indexOf(custom);
      if (index >= 0) return index + offset;
    }
    return null;
  }

  /// `appendRow` (`data-editor.tsx:1687-1742`). The Web version awaits the
  /// consumer's promise and retries with a backoff; here the same job is a
  /// post-frame check that `rows` grew.
  Future<void> _appendRow(int col, {bool openOverlay = true}) async {
    final p = widget.props;
    if (col < 0 || col >= _mangledColumns.length) return;
    if (_mangledColumns[col].trailingRowOptions?.disabled == true) return;

    final rowsBefore = _groupedRows;
    final result = await p.onRowAppended?.call();
    final target = _appendRowTarget(result, rowsBefore);
    await _focusAfterAppend(col, rowsBefore, target, openOverlay, 0);
  }

  /// `const row = typeof r === "number" ? r : bottom ? rows : 0`
  /// (`data-editor.tsx:1710-1714`), where `rows` is the count from before the
  /// append.
  static int _appendRowTarget(Object? result, int rowsBefore) {
    if (result is int) return result;
    return result == 'top' ? 0 : rowsBefore;
  }

  Future<void> _focusAfterAppend(
    int col,
    int rowsBefore,
    int targetRow,
    bool openOverlay,
    int attempt,
  ) {
    if (!mounted) return Future<void>.value();
    if (_groupedRows > rowsBefore) {
      _selectAppendedRow(col, targetRow, openOverlay);
      return Future<void>.value();
    }
    if (attempt >= 10) return Future<void>.value();
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        completer.complete();
        return;
      }
      _focusAfterAppend(
        col,
        rowsBefore,
        targetRow,
        openOverlay,
        attempt + 1,
      ).whenComplete(completer.complete);
    });
    return completer.future;
  }

  /// `doFocus`'s `setCurrent` + `scrollTo` (`data-editor.tsx:1716-1740`).
  void _selectAppendedRow(int col, int row, bool openOverlay) {
    final behavior = _selectionState.createBehavior();
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
      expand: false,
      append: false,
      trigger: SemiSelectionTrigger.edit,
    );
    _setGridSelection(_selectionState.selection, false);
    _scrollTo(SemiScrollTarget(col - _markerOffset, row));

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
    final location = SemiItem(col, row);
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
        activation: const SemiKeyboardCellActivation('Enter'),
        theme: _themeForCell(content, location),
      ),
    );
  }

  /// `appendColumn` (`data-editor.tsx:1744-1793`).
  Future<void> _appendColumn(int row, {bool openOverlay = true}) async {
    final p = widget.props;
    final append = p.onColumnAppended;
    if (append == null) return;

    final colsBefore = _mangledColumns.length;
    final result = await append();
    await _focusAfterColumnAppend(colsBefore, row, result, openOverlay, 0);
  }

  Future<void> _focusAfterColumnAppend(
    int colsBefore,
    int row,
    Object? result,
    bool openOverlay,
    int attempt,
  ) {
    if (!mounted) return Future<void>.value();
    if (_mangledColumns.length > colsBefore) {
      _selectAppendedColumn(colsBefore, row, result, openOverlay);
      return Future<void>.value();
    }
    if (attempt >= 10) return Future<void>.value();
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        completer.complete();
        return;
      }
      _focusAfterColumnAppend(
        colsBefore,
        row,
        result,
        openOverlay,
        attempt + 1,
      ).whenComplete(completer.complete);
    });
    return completer.future;
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
        cell: SemiItem(col, row),
        range: SemiRectangle(
          x: col.toDouble(),
          y: row.toDouble(),
          width: 1,
          height: 1,
        ),
      ),
      expand: false,
      append: false,
      trigger: SemiSelectionTrigger.edit,
    );
    _setGridSelection(_selectionState.selection, false);
    _scrollTo(SemiScrollTarget(col - _markerOffset, row));

    if (openOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusOnRowFromTrailingBlankRow(col, row);
      });
    }
  }

  /// `onVisibleRegionChangedImpl`'s `extras` (`data-editor.tsx:2594-2627`).
  SemiVisibleRegionExtras _computeVisibleExtras(SemiVisibleRegion region) {
    final p = widget.props;
    final selected = _selection.current?.cell;

    final freezeRegion = p.freezeColumns == 0
        ? null
        : SemiRectangle(
            x: 0,
            y: region.y.toDouble(),
            width: p.freezeColumns.toDouble(),
            height: region.height.toDouble(),
          );

    final freezeRegions = <SemiRectangle>[];
    if (freezeRegion != null) freezeRegions.add(freezeRegion);
    if (p.freezeTrailingRows > 0) {
      freezeRegions.add(
        SemiRectangle(
          // `region.x - rowMarkerOffset` (`data-editor.tsx:2613`): the rects
          // are matched against user-space `outerCol`, so the marker column
          // must be stripped here too.
          x: (region.x - _markerOffset).toDouble(),
          y: (_groupedRows - p.freezeTrailingRows).toDouble(),
          width: region.width.toDouble(),
          height: p.freezeTrailingRows.toDouble(),
        ),
      );
      if (p.freezeColumns > 0) {
        freezeRegions.add(
          SemiRectangle(
            x: 0,
            y: (_groupedRows - p.freezeTrailingRows).toDouble(),
            width: p.freezeColumns.toDouble(),
            height: p.freezeTrailingRows.toDouble(),
          ),
        );
      }
    }

    return SemiVisibleRegionExtras(
      selected: selected == null
          ? null
          : SemiItem(selected.col - _markerOffset, selected.row),
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
      for (final rect in extras?.freezeRegions ?? const <SemiRectangle>[]) {
        if (pointInRect(rect, outerCol.toDouble(), row.toDouble())) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  /// `mapper(row).isGroupHeader` (`row-grouping.ts:190-238`).
  bool _isGroupHeaderRow(int row) =>
      mapRowIndexToPath(row, _rowGrouping.flattened).isGroupHeader;

  /// `getSelectionRowLimits` (`data-editor.tsx:2708-2725`).
  (int, int)? _getSelectionRowLimits(int row) => getSelectionRowLimits(
    options: widget.props.rowGrouping,
    flattened: _rowGrouping.flattened,
    selectedRow: row,
  );

  /// `getCellsForSelectionMangled` (`use-cells-for-selection.ts:42-67`).
  ///
  /// The marker column is inserted synchronously; an asynchronous sample is
  /// forwarded as-is and the caller awaits it.
  FutureOr<SemiCellArray?> _getCellsForSelection(SemiRectangle region) {
    final direct = widget.props.getCellsForSelection;
    if (direct == null) return null;
    final offset = _markerOffset;
    if (offset == 0) return direct(region);

    final newX = region.x - offset;
    if (newX < 0) {
      final r = direct(region.copyWith(x: 0, width: region.width - 1));
      SemiCellArray? prefix(SemiCellArray? cells) => cells == null
          ? null
          : [for (final row in cells) [const SemiLoadingCell(), ...row]];
      return r is Future<SemiCellArray?> ? r.then(prefix) : prefix(r);
    }
    return direct(region.copyWith(x: newX));
  }

  SemiItem _locationOf(SemiGridMouseArgs args) => switch (args) {
    SemiGridCellMouseArgs a => a.location,
    SemiGridHeaderMouseArgs a => a.location,
    SemiGridGroupHeaderMouseArgs a => a.location,
    SemiGridOutOfBoundsMouseArgs a => a.location,
  };

  SemiRendererLookup? _renderersCache;
  Object? _renderersKey;

  /// Memoized so the `forCell` tear-off handed to the grid is the same
  /// instance across builds — the accessibility tree's cache key compares
  /// `getCellRenderer` with `==`, and a fresh `SemiDefaultRendererLookup()`
  /// per call would defeat it.
  SemiRendererLookup get _renderers {
    final supplied = widget.props.rendererLookup;
    if (_renderersCache == null || !identical(_renderersKey, supplied)) {
      _renderersKey = supplied;
      _renderersCache = supplied ?? SemiDefaultRendererLookup();
    }
    return _renderersCache!;
  }

  // -------------------------------------------------------------------------
  // Theme and content
  // -------------------------------------------------------------------------

  /// `themeForCell` (`data-editor.tsx`).
  SemiDataGridTheme _themeForCell(SemiGridCell cell, SemiItem location) {
    final mangled = _mangledColumns;
    final column = location.col < mangled.length ? mangled[location.col] : null;
    var theme = _theme;
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
  SemiGridCell _getCellContent(SemiItem item, [bool? forceStrict]) =>
      _readCellContent(item, forceStrict: forceStrict);

  SemiGridCell _readCellContent(
    SemiItem item, {
    bool? forceStrict,
    bool forClipboard = false,
  }) {
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
    // Clipboard edits may reach beyond the rendered viewport.
    if (!forClipboard &&
        (forceStrict == true || widget.props.strict) &&
        _isOutsideVisibleArea(col, row)) {
      return const SemiLoadingCell();
    }

    var cell = widget.props.getCellContent(
      SemiItem(outerCol, row),
      forceStrict,
    );
    final span = cell.span;
    if (_markerOffset != 0 && span != null) {
      // Spans are reported in user coordinates (`data-editor.tsx:1374-1379`).
      cell = cell is SemiTextCell
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
  bool _onCellsEdited(List<SemiEditListItem> items) {
    if (items.isEmpty) return true;
    _a11yRevision++;
    final p = widget.props;
    final offset = _markerOffset;
    final mangled = offset == 0
        ? items
        : [
            for (final i in items)
              SemiEditListItem(
                location: SemiItem(i.location.col - offset, i.location.row),
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

  SemiGridSelection _controlledSelection(SemiGridSelection selection) =>
      _clipSelection(semiShiftSelection(selection, _markerOffset));

  SemiGridSelection _clipSelection(
    SemiGridSelection selection, {
    bool allowTrailingRow = false,
  }) {
    final firstCol = _markerOffset;
    final endCol = _mangledColumns.length;
    final endRow = allowTrailingRow ? _mangledRows : _groupedRows;

    SemiRectangle? clipRange(SemiRectangle range) {
      if (!range.x.isFinite || !range.y.isFinite ||
          !range.right.isFinite || !range.bottom.isFinite) {
        return null;
      }
      final left = math.max(firstCol.toDouble(), range.x);
      final top = math.max(0.0, range.y);
      final right = math.min(endCol.toDouble(), range.right);
      final bottom = math.min(endRow.toDouble(), range.bottom);
      if (right <= left || bottom <= top) return null;
      return SemiRectangle(
        x: left, y: top, width: right - left, height: bottom - top,
      );
    }

    SemiCompactSelection clipItems(SemiCompactSelection items, int start, int end) {
      return SemiCompactSelection.create([
        for (final slice in items.items)
          if (math.max(slice.start, start) < math.min(slice.end, end))
            SemiSlice(math.max(slice.start, start), math.min(slice.end, end)),
      ]);
    }

    final current = selection.current;
    SemiGridSelectionCurrent? clippedCurrent;
    if (current != null) {
      final cell = current.cell;
      if (cell.col >= firstCol && cell.col < endCol &&
          cell.row >= 0 && cell.row < endRow) {
        final range = clipRange(current.range);
        clippedCurrent = current.copyWith(
          range: range != null && range.containsItem(cell)
              ? range
              : SemiRectangle(x: cell.col.toDouble(), y: cell.row.toDouble(), width: 1, height: 1),
          rangeStack: List.unmodifiable(current.rangeStack.map(clipRange).nonNulls),
        );
      }
    }
    return SemiGridSelection(
      current: clippedCurrent,
      rows: clipItems(selection.rows, 0, _groupedRows),
      columns: clipItems(selection.columns, firstCol, endCol),
    );
  }

  void _syncSelectionAnchors() {
    final col = _selectionState.lastSelectedCol;
    final row = _selectionState.lastSelectedRow;
    if (col == null || !_selection.columns.hasIndex(col)) {
      _selectionState.lastSelectedCol = _selection.columns.firstIndex;
    }
    if (row == null || !_selection.rows.hasIndex(row)) {
      _selectionState.lastSelectedRow = _selection.rows.firstIndex;
    }
  }

  void _scheduleControlledSelectionChange(SemiItem? cell) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.props.gridSelection == null ||
          _selection.current?.cell != cell) {
        return;
      }
      if (cell != null && widget.props.scrollToActiveCell) {
        _scrollTo(SemiScrollTarget(cell.col - _markerOffset, cell.row));
      }
      _notifySelectionFocus(cell);
    });
  }

  void _setGridSelection(SemiGridSelection newVal, bool expand) {
    var v = newVal;
    if (expand) {
      v = semiExpandSelection(
        newVal: v,
        getCellsForSelection: _getCellsForSelection,
        rowMarkerOffset: _markerOffset,
        allowPartial:
            widget.props.spanRangeBehavior ==
            SemiSpanRangeBehavior.allowPartial,
      );
    }
    // `selectionOutOfBounds` (`data-editor.ts:3951-3957`): a selection that
    // no longer fits the grid is dropped.
    final current = v.current;
    if (current != null &&
        (current.cell.col >= _mangledColumns.length ||
            current.cell.row >= _mangledRows)) {
      v = SemiGridSelection.empty;
    }

    final controlled = widget.props.gridSelection != null;
    if (controlled) {
      // Mouse selection mutates the helper before submitting its proposal.
      _selectionState.selection = _selection;
    } else {
      setState(() {
        _selection = v;
        _selectionState.selection = v;
      });
    }
    widget.props.onGridSelectionChange?.call(
      semiShiftSelection(v, -_markerOffset),
    );
    if (controlled) return;

    _notifySelectionFocus(v.current?.cell);
  }

  SemiItem? _lastFocusedCell;

  void _notifySelectionFocus(SemiItem? cell) {
    if (cell == _lastFocusedCell) return;
    _lastFocusedCell = cell;
    if (cell != null) widget.props.onCellFocused?.call(cell);
  }

  SemiKeyHandler _makeKeyHandler() =>
      SemiKeyHandler(
          keys: semiKeysWithDefaults(widget.props.keybindings),
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
          visibleRegion: SemiRectangle(
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
          scrollToActiveCell: widget.props.gridSelection == null &&
              widget.props.scrollToActiveCell,
          getCellsForSelection: _getCellsForSelection,
          onSelectionCleared: widget.props.onSelectionCleared,
          onDelete: widget.props.onDelete,
          onCellsEdited: _onCellsEdited,
          onCellActivated: (location, activation) {
            widget.props.onCellActivated?.call(location, activation);
            if (activation is SemiKeyboardCellActivation) {
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
            const SemiKeyboardCellActivation(null),
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
    SemiRectangle bounds,
    SemiCellActivation activation, {
    String? initialValue,
  }) {
    final current = _selection.current;
    if (current == null) return;

    final location = current.cell;
    final c = _getCellContent(location);

    if (c.kind != SemiCellKind.boolean && c.allowOverlay) {
      var content = c;
      if (initialValue != null) {
        content = switch (content) {
          SemiNumberCell value => value.copyWith(
            data: _parseFloat(initialValue),
            displayData: initialValue,
          ),
          SemiTextCell value => value.copyWith(
            data: initialValue,
            displayData: initialValue,
          ),
          SemiMarkdownCell value => value.copyWith(data: initialValue),
          SemiUriCell value => value.copyWith(
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
    } else if (c.kind == SemiCellKind.boolean &&
        activation is SemiKeyboardCellActivation &&
        !c.isReadonly) {
      _onCellsEdited([
        SemiEditListItem(
          location: location,
          value: (c as SemiBooleanCell).copyWith(data: toggleBoolean(c.data)),
        ),
      ]);
    }
  }

  /// Keyboard Enter/click activation on the already-selected cell.
  void _reselectForKeyboard(
    SemiItem location,
    SemiCellActivation activation,
  ) {
    final bounds = _gridController.getBounds(location.col, location.row);
    if (bounds == null) return;
    _reselect(bounds, activation);
  }

  static double _parseFloat(String value) {
    if (value == '-') return -0.0;
    return double.tryParse(value) ?? 0.0;
  }

  void _finishEditing(SemiGridCell? newCell, SemiEditorMovement movement) {
    widget.props.onFinishedEditing?.call(newCell, movement);
    final overlay = _overlay;
    setState(() => _overlay = null);
    if (overlay != null &&
        newCell != null &&
        semiIsEditableGridCell(newCell)) {
      _onCellsEdited([
        SemiEditListItem(location: overlay.cell, value: newCell),
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
    // No write-back: the handler's `setGridSelection` is bound straight to
    // `_setGridSelection`, so the editor already holds the result. Pushing
    // `handler.selection` back would re-send the *unexpanded* value.
  }

  // -------------------------------------------------------------------------
  // Fill (`data-editor.tsx:2245-2330`)
  // -------------------------------------------------------------------------

  /// `fillPattern` (`data-editor.tsx:2245-2296`). The pattern may arrive
  /// asynchronously, which is why upstream marks this callback `async`.
  Future<void> _fillPattern(
    SemiGridSelection previousSelection,
    SemiGridSelection currentSelection,
  ) async {
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
        SemiFillPatternArgs(
          patternSource: patternRange,
          fillDestination: currentRange,
          preventDefault: () => canceled = true,
        ),
      );
      if (canceled) return;
    }

    final pattern = await getCells(patternRange);
    if (pattern == null || pattern.isEmpty) return;

    final edits = <SemiEditListItem>[];
    for (var x = 0; x < currentRange.width; x++) {
      for (var y = 0; y < currentRange.height; y++) {
        final item = SemiItem(
          currentRange.x.toInt() + x,
          currentRange.y.toInt() + y,
        );
        if (itemIsInRect(item, patternRange)) continue;
        final patternCell =
            pattern[y % patternRange.height.toInt()][x %
                patternRange.width.toInt()];
        if (semiIsInnerOnlyCell(patternCell) ||
            !semiIsReadWriteCell(patternCell)) {
          continue;
        }
        edits.add(SemiEditListItem(location: item, value: patternCell));
      }
    }
    if (edits.isNotEmpty) _onCellsEdited(edits);
  }

  /// `fillDown` (`data-editor.tsx:2315-2330`): the first row of the range is
  /// the pattern, the whole range is the destination.
  Future<void> _fillDown() async {
    final current = _selection.current;
    if (current == null || current.range.height <= 1) return;
    await _fillPattern(
      _selection.copyWith(
        current: current.copyWith(range: current.range.copyWith(height: 1)),
      ),
      _selection,
    );
  }

  Future<void> _fillRight() async {
    final current = _selection.current;
    if (current == null || current.range.width <= 1) return;
    await _fillPattern(
      _selection.copyWith(
        current: current.copyWith(range: current.range.copyWith(width: 1)),
      ),
      _selection,
    );
  }

  // -------------------------------------------------------------------------
  // scrollTo (`data-editor.tsx:1524-1674`)
  // -------------------------------------------------------------------------

  void _scrollTo(SemiScrollTarget target) {
    final col = target.col + _markerOffset;
    final bounds = _gridController.getBounds(col, target.row);
    if (bounds == null || bounds.width == 0 || bounds.height == 0) return;

    var frozenWidth = 0.0;
    for (var i = 0; i < _mangledFreezeColumns; i++) {
      frozenWidth += _mangledColumns[i].width ?? 0;
    }
    final frozenRows = _effectiveFreezeTrailingRows.clamp(0, _mangledRows);
    // `getFreezeTrailingHeight(mangledRows, freezeTrailingRowsEffective, ...)`
    // (`data-editor.tsx:1581-1586`).
    final trailingHeight = _effectiveRowHeight.trailingHeight(
      _mangledRows,
      frozenRows,
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
    if (axis == SemiScrollAxis.vertical || col < _mangledFreezeColumns) {
      scrollX = 0;
    }
    if (axis == SemiScrollAxis.horizontal ||
        target.row >= _mangledRows - frozenRows) {
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

  /// `offsetColumnSize` (`data-grid-dnd.tsx:85-87`). [col] is a mangled
  /// (marker-inclusive) index, because the grid reports events in that space.
  double _offsetColumnSize(int col, double width) {
    final column = _mangledColumns[col];
    return clampDouble(
      (width - (column.extension?.growOffset ?? 0)).roundToDouble(),
      _minColumnWidth.ceilToDouble(),
      _maxColumnWidth.floorToDouble(),
    );
  }

  /// Upstream's `DataEditor` strips the marker offset before forwarding the
  /// resize callbacks (`data-editor.tsx:1018-1046`). Grid events and
  /// [_resizeCol] stay mangled; callers see user columns and indices.
  void _emitResize(
    void Function(
      SemiGridColumn column,
      double newSize,
      int colIndex,
      double newSizeWithGrow,
    )?
    callback,
    int mangledCol,
    double newSize,
  ) {
    final col = mangledCol - _markerOffset;
    if (col < 0 || col >= widget.props.columns.length) return;
    final column = widget.props.columns[col];
    callback?.call(
      column,
      newSize,
      col,
      newSize + (column.extension?.growOffset ?? 0).toDouble(),
    );
  }

  void _detectResizeStart(SemiGridMouseArgs args) {
    if (args.kind == SemiGridCellKind.outOfBounds && args.isEdge) {
      // `data-grid-dnd.tsx:154`: the trailing edge is only a resize handle
      // when resizing is enabled, and `columns` there are mangled.
      if (!_canResize) return;
      final last = _mangledColumns.length - 1;
      final bounds = _gridController.getBounds(last, SemiItem.headerRow);
      if (bounds != null) {
        setState(() {
          _resizeColStartX = bounds.x;
          _resizeCol = last;
        });
      }
      return;
    }
    if (args.kind != SemiGridCellKind.header) return;
    final header = args as SemiGridHeaderMouseArgs;
    final col = header.location.col;
    if (col < _lockColumns || col < 0 || col >= _mangledColumns.length) {
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

    setState(() {
      _resizeColStartX = header.bounds.x;
      _resizeCol = col;
    });
    _emitResize(widget.props.onColumnResizeStart, col, header.bounds.width);
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
    if (col < 0 || col >= _mangledColumns.length) return;

    final newWidth = position.dx - startX;
    final ns = _offsetColumnSize(col, newWidth);
    _emitResize(widget.props.onColumnResize, col, ns);
    _lastResizeWidth = newWidth;

    // Resizing a column that is part of a multi-column selection resizes the
    // whole selection (`data-grid-dnd.tsx:321-331`). Selection columns share
    // the grid's mangled coordinate space.
    final selected = _selection.columns;
    if (selected.firstIndex == col) {
      for (final c in selected.indices) {
        if (c == col) continue;
        if (c < 0 || c >= _mangledColumns.length) continue;
        _emitResize(
          widget.props.onColumnResize,
          c,
          _offsetColumnSize(c, _lastResizeWidth),
        );
      }
    }
  }

  /// `onMouseUpImpl`'s resize tail (`data-grid-dnd.tsx:222-255`).
  void _commitResize() {
    final col = _resizeCol;
    _resizeCol = null;
    _resizeColStartX = null;
    if (col == null || col < 0 || col >= _mangledColumns.length) {
      _lastResizeWidth = -1;
      return;
    }

    _emitResize(
      widget.props.onColumnResizeEnd,
      col,
      _offsetColumnSize(col, _lastResizeWidth),
    );

    final selected = _selection.columns;
    if (selected.hasIndex(col)) {
      for (final c in selected.indices) {
        if (c == col) continue;
        if (c < 0 || c >= _mangledColumns.length) continue;
        _emitResize(
          widget.props.onColumnResizeEnd,
          c,
          _offsetColumnSize(c, _lastResizeWidth),
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

  /// `normalSizeColumn` (`data-editor.tsx:2193-2241`): [col] is the
  /// marker-inclusive grid index, which is what `getCellsForSelection` and
  /// the header hit-test report. The column itself and the emitted
  /// `onColumnResize` index are business columns
  /// (`columns[col - rowMarkerOffset]` upstream). The sample may arrive
  /// asynchronously, so this resolves before measuring.
  Future<void> _normalSizeColumn(int col) async {
    final p = widget.props;
    final getCells = _getCellsForSelection;
    final onResize = p.onColumnResize;
    if (p.getCellsForSelection == null || onResize == null) return;
    final userCol = col - _markerOffset;
    if (userCol < 0 || userCol >= p.columns.length) return;

    final start = _visible?.y ?? 0;
    final height = math.min(
      _visible?.height ?? 1,
      math.max(1, _groupedRows - start),
    );
    final cells = await getCells(
      SemiRectangle(
        x: col.toDouble(),
        y: start.toDouble(),
        width: 1,
        height: height.toDouble(),
      ),
    );
    if (cells == null || !mounted) return;
    // The sample may have arrived a frame later; re-read the current props.
    final current = widget.props;
    final resize = current.onColumnResize;
    if (resize == null || userCol >= current.columns.length) return;

    final newWidth = semiMeasureColumn(
      theme: _theme,
      column: current.columns[userCol],
      colIndex: userCol,
      selectedData: cells,
      minColumnWidth: _minColumnWidth,
      maxColumnWidth: _maxColumnWidth,
      removeOutliers: false,
      getCellRenderer: _renderers.forCell,
      metrics: _metrics,
    );
    resize(current.columns[userCol], newWidth, userCol, newWidth);
  }

  // -------------------------------------------------------------------------
  // DataEditorRef (`data-editor.tsx:701-760`)
  // -------------------------------------------------------------------------

  void _updateCells(Iterable<SemiItem> cells) {
    _gridController.damage([
      for (final cell in cells) SemiItem(cell.col + _markerOffset, cell.row),
    ]);
  }

  SemiRectangle? _controllerGetBounds(int? col, int? row) {
    if (col == null && row == null) {
      return SemiRectangle(
        x: 0,
        y: 0,
        width: _columnsWidth,
        height: _rowsHeight,
      );
    }
    return _gridController.getBounds((col ?? 0) + _markerOffset, row);
  }

  Future<void> _emit(SemiEmitEvent event) async {
    switch (event) {
      case SemiEmitEvent.copy:
        await _copy();
      case SemiEmitEvent.paste:
        await _paste();
      case SemiEmitEvent.delete:
        _emitHotkey('Delete', 46);
      case SemiEmitEvent.fillRight:
        _emitHotkey('r', 82, primary: true);
      case SemiEmitEvent.fillDown:
        _emitHotkey('d', 68, primary: true);
    }
  }

  /// Upstream `emit` synthesizes a DOM key event and hands it to the editor's
  /// own key handler (`data-editor.tsx:4032-4070`), which is what keeps
  /// `props.onKeyDown` able to cancel the action. The `primary` modifier is
  /// mapped per platform so `primary+_68` / `primary+_82` match on macOS too.
  void _emitHotkey(String key, int keyCode, {bool primary = false}) {
    final isMac = semiIsOSX();
    _handleKeyDown(
      SemiGridKeyArgs(
        bounds: null,
        key: key,
        keyCode: keyCode,
        altKey: false,
        shiftKey: false,
        ctrlKey: primary && !isMac,
        metaKey: primary && isMac,
        cancel: () {},
        stopPropagation: () {},
        preventDefault: () {},
        location: null,
      ),
    );
  }

  void _remeasureColumns(SemiCompactSelection cols) {
    for (final col in cols.indices) {
      unawaited(_normalSizeColumn(col + _markerOffset));
    }
  }

  SemiGridMouseArgs? _mouseArgsForPosition(double x, double y) {
    final args = _gridController.mouseArgsForPosition(x, y);
    if (args == null) return null;
    final location = _locationOf(args);
    return _withLocation(
      args,
      location.col - _markerOffset,
      location.row,
    );
  }

  // -------------------------------------------------------------------------
  // Hover, drag selection and autoscroll
  //   (`data-editor.tsx:2728-2850`, `data-editor/use-autoscroll.ts`)
  // -------------------------------------------------------------------------

  void _onItemHovered(SemiGridMouseArgs args) {
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

    if (semiMouseArgsAreEqual(args, _hoveredArgs)) return;
    _hoveredArgs = args;

    // `mouseState !== undefined` upstream; `_previousSelection` is only set
    // for presses that reached `setMouseState`.
    final dragging =
        _previousSelection != null && args.button == 0 && args.buttons != 0;

    if (dragging &&
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
        !args.isTouch &&
        _selection.current != null &&
        (widget.props.rangeSelect == SemiRangeSelect.rect ||
            widget.props.rangeSelect == SemiRangeSelect.multiRect)) {
      // Touch selects on release, not while the finger is down, so it never
      // rubber-bands a range here.
      _dragSelect(args);
    }

    // Edge autoscroll is a mouse-drag affordance; a touch scrolls itself.
    if (!args.isTouch) _updateScrollDir(args);
    widget.props.onItemHovered?.call(args);
  }

  /// The rect-drag branch of `onItemHoveredImpl` (`data-editor.tsx:2749-2805`).
  void _dragSelect(SemiGridMouseArgs args) {
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
    final newRange = SemiRectangle(
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
      trigger: SemiSelectionTrigger.drag,
    );
    if (_selectionState.selection != _selection) {
      _setGridSelection(_selectionState.selection, true);
    }
  }

  /// `setScrollDir` (`data-editor.tsx:2556-2562`): only scroll while a
  /// button is held.
  void _updateScrollDir(SemiGridMouseArgs args) {
    final (x, y) = args.scrollEdge;
    final mouseDown = _mouseDownData;
    final next = mouseDown?.button == 0 && args.button == 0 && args.buttons != 0
        ? (x, y)
        : null;
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

    // `visible.x` is user space now; `_withLocation`/`_onItemHovered` take
    // mangled coordinates, so the marker column is added back. Upstream writes
    // `visible.x` straight into `location`, which is an off-by-`rowMarkerOffset`
    // latent bug there — kept in grid space here instead (see the comment on
    // `_applyScroll`).
    if (xDir == -1) {
      col = visible.x + _markerOffset;
    } else if (xDir == 1) {
      col = visible.x + visible.width + _markerOffset;
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
  SemiGridMouseArgs _withLocation(SemiGridMouseArgs args, int col, int row) {
    final location = SemiItem(col, row);
    return switch (args) {
      SemiGridCellMouseArgs a => SemiGridCellMouseArgs(
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
      SemiGridHeaderMouseArgs a => SemiGridHeaderMouseArgs(
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
      SemiGridGroupHeaderMouseArgs a => SemiGridGroupHeaderMouseArgs(
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
      SemiGridOutOfBoundsMouseArgs a => SemiGridOutOfBoundsMouseArgs(
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

  void _onMouseDown(SemiGridMouseArgs args) {
    if (args.button != 0 && args.button != 1) return;

    _mouseDownData = (button: args.button, location: _locationOf(args));
    // Middle-click can notify the caller but never starts a grid gesture.
    if (args.button != 0) return;

    // `DataGridDnd.onMouseDownImpl` (`data-grid-dnd.tsx:149-186`) runs before
    // the editor's own handler.
    _detectResizeStart(args);

    final isFillHandle = args is SemiGridCellMouseArgs && args.isFillHandle;

    // `kind === "cell" && lockColumns > 0 && col === 0` — row dragging is
    // armed from the marker column (`data-grid-dnd.tsx:172-181`).
    if (!isFillHandle &&
        args.kind == SemiGridCellKind.cell &&
        _lockColumns > 0 &&
        _locationOf(args).col == 0 &&
        widget.props.onRowMoved != null) {
      _dragStartY = (args as SemiGridCellMouseArgs).bounds.y;
      _dragRow = _locationOf(args).row;
      _dropRow = null;
      _dragRowActive = false;
    }

    // `!fh && kind !== "cell" && isEdge` returns before `setMouseState`, so a
    // resize press never arms selection dragging.
    if (!isFillHandle && args.kind != SemiGridCellKind.cell && args.isEdge) {
      return;
    }

    _previousSelection = _selection;
    _fillHandlePressed = isFillHandle;
    if (!args.isTouch && !isFillHandle) _handleSelect(args);
  }

  void _handleSelect(SemiGridMouseArgs args) {
    final lastRow = _selectionState.lastSelectedRow;
    final lastCol = _selectionState.lastSelectedCol;
    final outcome = _selectionState.handleSelect(
      args,
      getCellRenderer: _renderers.forCell,
      getCellContent: _getCellContent,
      themeForCell: _themeForCell,
    );
    if (outcome.onSelectionCleared) {
      widget.props.onSelectionCleared?.call();
    }
    if (widget.props.gridSelection != null) {
      _selectionState.lastSelectedRow = lastRow;
      _selectionState.lastSelectedCol = lastCol;
    }
    if (_selectionState.selection != _selection) {
      _setGridSelection(_selectionState.selection, false);
    }
    if (outcome.clearOverlay) _closeOverlay();
    if (outcome.focus) _gridController.focus();
  }

  /// `handleMaybeClick` (`data-editor.tsx:2367-2435`).
  bool _handleMaybeClick(SemiGridCellMouseArgs a) {
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
        SemiCellClickedEventArgs(
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
        SemiCellEventArgs(
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
          !semiIsInnerOnlyCell(newVal) &&
          semiIsEditableGridCell(newVal)) {
        _onCellsEdited([
          SemiEditListItem(location: a.location, value: newVal),
        ]);
      }
      if (prevented) return false;
    }

    if (_selection.current == null) return false;

    final activationBehavior =
        c.activationBehaviorOverride ?? p.cellActivationBehavior;
    var shouldActivate = false;
    switch (activationBehavior) {
      case SemiCellActivationBehavior.doubleClick ||
          SemiCellActivationBehavior.secondClick:
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
                    SemiCellActivationBehavior.secondClick);
      case SemiCellActivationBehavior.singleClick:
        shouldActivate = true;
    }

    if (!shouldActivate) return false;

    final activation = SemiPointerCellActivation(
      a.isDoubleClick == true
          ? SemiCellActivationBehavior.doubleClick
          : activationBehavior,
      pointerType: a.isTouch == true ? 'touch' : 'mouse',
    );
    p.onCellActivated?.call(a.location, activation);
    _reselect(a.bounds, activation);
    return true;
  }

  void _onMouseUp(SemiGridMouseArgs args, bool isOutside) {
    final down = _mouseDownData;
    if (down == null || args.button != down.button) return;
    final matchesPress = down.location == _locationOf(args);
    final wasDragging = _dragColActive || _dragRowActive;
    final wasResizing = _resizeCol != null;
    if (isOutside) {
      _resizeCol = null;
      _resizeColStartX = null;
      _lastResizeWidth = -1;
      _clearDragState();
      _finishPointerGesture(refresh: wasDragging || wasResizing);
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
      _finishPointerGesture();
      if (_selection.current != null &&
          previous?.current != null &&
          highlight != null) {
        final newRange = _selection.copyWith(
          current: _selection.current!.copyWith(
            range: combineRects(previous!.current!.range, highlight),
          ),
        );
        unawaited(_fillPattern(previous, newRange));
        _setGridSelection(newRange, true);
        return;
      }
      setState(() {});
      return;
    }

    // Touch pointers do their selection on release instead of on press
    // (`data-editor.tsx:2438-2482`).
    if (args.isTouch == true) {
      final dragged = _touchDragged;
      final velocity = _touchVelocity;
      _resetTouchGesture();
      // A finger that scrolled is a scroll, not a tap: no selection, no cell
      // activation (`data-editor.tsx:2438-2443` aborts on a changed region).
      if (dragged) {
        _startInertia(velocity);
        _finishPointerGesture();
        return;
      }
      if (args.kind == SemiGridCellKind.cell) {
        if (!_handleMaybeClick(args as SemiGridCellMouseArgs)) {
          _handleSelect(args);
        }
      } else if (args case final SemiGridHeaderMouseArgs header) {
        final col = header.location.col - _markerOffset;
        if (col >= 0) widget.props.onHeaderClicked?.call(col, header);
        _handleSelect(args);
      } else if (args.kind == SemiGridCellKind.groupHeader) {
        _handleSelect(args);
      }
      _finishPointerGesture();
      return;
    }

    switch (args) {
      case SemiGridHeaderMouseArgs header:
        if (args.button != 0 || !matchesPress || wasDragging) break;
        if (header.isEdge) {
          // Double-clicking a header edge re-measures the column
          // (`data-editor.tsx:2489-2492`).
          if (header.isDoubleClick == true) {
            unawaited(_normalSizeColumn(header.location.col));
          }
        } else if (!wasResizing) {
          final col = header.location.col - _markerOffset;
          if (col >= 0) widget.props.onHeaderClicked?.call(col, header);
        }
      case SemiGridGroupHeaderMouseArgs groupHeader:
        if (args.button != 0 || !matchesPress || wasDragging || wasResizing) {
          break;
        }
        final adjustedCol = groupHeader.location.col - _markerOffset;
        if (adjustedCol < 0) break;

        // Let the callback cancel default group selection (`data-editor.tsx:2504-2507`).
        var prevented = false;
        widget.props.onGroupHeaderClicked?.call(
          adjustedCol,
          SemiGroupHeaderClickedEventArgs(
            col: adjustedCol,
            args: groupHeader,
            preventDefault: () => prevented = true,
          ),
        );
        if (prevented) break;

        _selectionState.handleGroupHeaderSelection(
          groupHeader,
          columns: _mangledColumns,
          rowMarkerOffset: _markerOffset,
        );
        if (_selectionState.selection != _selection) {
          _setGridSelection(_selectionState.selection, false);
        }
      case SemiGridCellMouseArgs cell:
        if (matchesPress && !wasDragging && !wasResizing) {
          _handleMaybeClick(cell);
        }
      case SemiGridOutOfBoundsMouseArgs():
        break;
    }
    _finishPointerGesture(refresh: wasDragging || wasResizing);
  }

  void _finishPointerGesture({bool refresh = false}) {
    _mouseDownData = null;
    _previousSelection = null;
    _fillHandlePressed = false;
    if (refresh || _fillHighlightRegion != null || _scrollDir != null) {
      setState(() {
        _fillHighlightRegion = null;
        _scrollDir = null;
      });
    }
    _setAutoscrollActive(false);
  }

  // -------------------------------------------------------------------------
  // Highlight regions (`data-editor.tsx:1240-1305`)
  // -------------------------------------------------------------------------

  List<SemiDataGridHighlight>? _highlightRegions() {
    final p = widget.props;
    final accent = _theme.accentColor;
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

    final regions = <SemiDataGridHighlight>[];
    if (p.highlightRegions != null) {
      for (final r in p.highlightRegions!) {
        final maxWidth =
            _mangledColumns.length - r.range.x.toInt() - _markerOffset;
        if (maxWidth > 0) {
          regions.add(
            SemiDataGridHighlight(
              color: r.color,
              range: SemiRectangle(
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
        SemiDataGridHighlight(
          color: accent.withValues(alpha: 0),
          range: _fillHighlightRegion!,
          style: SemiDataGridHighlightStyle.dashedOutline,
        ),
      );
    }
    if (highlightRange != null) {
      regions.add(
        SemiDataGridHighlight(
          color: accent.withValues(alpha: 0.5),
          range: highlightRange,
        ),
      );
    }
    if (highlightFocus != null) {
      regions.add(
        SemiDataGridHighlight(
          color: accent,
          range: SemiRectangle(
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

  void _handleKeyDown(SemiGridKeyArgs event) {
    var cancelled = false;
    widget.props.onKeyDown?.call(
      SemiGridKeyArgs(
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
    if (!handled) return;
  }

  Future<void> _cut() async {
    if (widget.props.getCellsForSelection == null) return;
    await semiCut(
      focused: _focused,
      cutEnabled: semiKeysWithDefaults(widget.props.keybindings).cut,
      selection: _selection,
      // Whole-column copies span the *display* rows, group headers included
      // (`data-editor.tsx:930-936,3837-3846`), so collapsing a group requests
      // fewer rows than `props.rows` and expanding one requests more.
      rows: _groupedRows,
      rowMarkerOffset: _markerOffset,
      columns: widget.props.columns,
      getCellsForSelection: _getCellsForSelection,
      onDelete: (selection) =>
          mounted ? widget.props.onDelete?.call(selection) ?? true : false,
      deleteRange: (range) {
        if (!mounted) return;
        _makeKeyHandler().deleteRange(range, respectReadonly: true);
      },
      copyHeaders: widget.props.copyHeaders,
    );
  }

  Future<void> _copy() async {
    if (widget.props.getCellsForSelection == null) return;
    await semiCopy(
      focused: _focused,
      copyEnabled: semiKeysWithDefaults(widget.props.keybindings).copy,
      selection: _selection,
      // Same display-row span as `_cut` (`data-editor.tsx:3837-3846`).
      rows: _groupedRows,
      rowMarkerOffset: _markerOffset,
      columns: widget.props.columns,
      getCellsForSelection: _getCellsForSelection,
      copyHeaders: widget.props.copyHeaders,
    );
  }

  Future<void> _paste() async {
    if (widget.props.getCellsForSelection == null) return;
    await semiPaste(
      focused: _focused,
      selection: _selection,
      rows: _mangledRows,
      columnCount: _mangledColumns.length,
      rowMarkerOffset: _markerOffset,
      getCellContent: (item) => _readCellContent(item, forClipboard: true),
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
    // `onVisibleRegionChangedImpl`'s `newRegion` (`data-editor.tsx:2629-2641`):
    // the region handed to consumers is in *user* space — the marker column
    // is stripped from `x`, and `height` drops the trailing blank row when the
    // window reaches the end of the data. `cellXOffset` below converts back
    // (`:1190`, `visibleRegion.x + rowMarkerOffset`).
    final newRegion = SemiVisibleRegion(
      x: region.x - _markerOffset,
      y: region.y,
      width: region.width,
      height: _showTrailingBlankRow && region.y + region.height >= _groupedRows
          ? region.height - 1
          : region.height,
      translateX: region.translateX,
      translateY: region.translateY,
    );

    setState(() {
      _visible = newRegion;
      _visibleExtras = _computeVisibleExtras(region);
      _cellXOffset = newRegion.x + _markerOffset;
      _cellYOffset = newRegion.y;
      _translateX = region.translateX;
      _translateY = region.translateY;
    });
    widget.props.onVisibleRegionChanged?.call(newRegion, _visibleExtras!);
  }

  // -------------------------------------------------------------------------
  // Touch scrolling and inertia
  // -------------------------------------------------------------------------

  void _handleEditorPointerDown(PointerDownEvent event) {
    _stopInertia();
    _resetTouchGesture();
    if (event.kind != PointerDeviceKind.touch) return;
    _touchDownPosition = event.localPosition;
    _touchLastPosition = event.localPosition;
  }

  void _handleEditorPointerMove(PointerMoveEvent event) {
    if (event.kind != PointerDeviceKind.touch || _touchDownPosition == null) {
      return;
    }
    _handleTouchDrag(event.localPosition, event.timeStamp);
  }

  /// A press that started on a drag/resize/fill affordance keeps its existing
  /// behaviour; only an otherwise free touch becomes a scroll.
  bool get _touchMayScroll =>
      _dragCol == null &&
      _dragRow == null &&
      _resizeCol == null &&
      !_fillHandlePressed;

  void _handleTouchDrag(Offset position, Duration timeStamp) {
    if (!_touchMayScroll) return;
    final down = _touchDownPosition;
    if (down == null) return;

    if (!_touchDragged) {
      final delta = position - down;
      if (delta.distance < kTouchSlop) return;
      _touchDragged = true;
      // The press was going to resize/drag a column, move a row or fill;
      // a scroll wins now, so none of those gestures may commit on release.
      _resizeCol = null;
      _resizeColStartX = null;
      _lastResizeWidth = -1;
      _fillHandlePressed = false;
      _fillHighlightRegion = null;
      _clearDragState();
      _scrollBy(-delta);
      _touchLastPosition = position;
      _touchLastMoveTime = timeStamp;
      return;
    }

    final last = _touchLastPosition ?? position;
    _touchLastPosition = position;
    final delta = position - last;
    if (delta == Offset.zero) return;
    _scrollBy(-delta);

    final lastTime = _touchLastMoveTime;
    var dt = 0.016;
    if (lastTime != null && timeStamp > lastTime) {
      final micros = (timeStamp - lastTime).inMicroseconds;
      if (micros > 0) dt = micros / 1e6;
    }
    _touchVelocity = delta / dt;
    _touchLastMoveTime = timeStamp;
  }

  void _resetTouchGesture() {
    _touchDragged = false;
    _touchDownPosition = null;
    _touchLastPosition = null;
    _touchLastMoveTime = null;
    _touchVelocity = Offset.zero;
  }

  void _scrollBy(Offset delta) {
    final nextX = clampDouble(_scrollX + delta.dx, 0, _maxScrollX);
    final nextY = clampDouble(_scrollY + delta.dy, 0, _maxScrollY);
    if (nextX == _scrollX && nextY == _scrollY) return;
    setState(() {
      _scrollX = nextX;
      _scrollY = nextY;
    });
    _applyScroll();
  }

  void _startInertia(Offset velocity) {
    if (velocity.distance < 80) return;
    _inertiaVelocity = velocity;
    _lastInertiaTick = Duration.zero;
    if (!_inertiaTicker.isActive) _inertiaTicker.start();
  }

  void _stopInertia() {
    _inertiaVelocity = Offset.zero;
    if (_inertiaTicker.isActive) _inertiaTicker.stop();
  }

  /// `advanceScroll` by frame; the browser gets this from the platform's own
  /// fling, so the decay here is a plain exponential friction curve.
  void _onInertiaTick(Duration elapsed) {
    if (!mounted) return;
    if (_lastInertiaTick == Duration.zero) {
      _lastInertiaTick = elapsed;
      return;
    }
    final dtMs = (elapsed - _lastInertiaTick).inMicroseconds / 1000.0;
    _lastInertiaTick = elapsed;

    final beforeX = _scrollX;
    final beforeY = _scrollY;
    _scrollBy(-_inertiaVelocity * (dtMs / 1000.0));
    _inertiaVelocity *= math.pow(0.95, dtMs / 16.0).toDouble();

    final moved = _scrollX != beforeX || _scrollY != beforeY;
    if (!moved || _inertiaVelocity.distance < 30) _stopInertia();
  }

  void _handleEditorPointerUp(PointerUpEvent event) {
    // The grid normally reports the release first and clears this; if it did
    // not (for example a header control swallowed it), finish here.
    if (!_touchDragged) return;
    final velocity = _touchVelocity;
    _resetTouchGesture();
    _startInertia(velocity);
  }

  void _handleEditorPointerCancel(PointerCancelEvent event) {
    _resetTouchGesture();
    _stopInertia();
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
        _semiTheme = SemiDataGridTheme.fromSemiTheme(SemiTheme.of(context));
        _rebuildRowGrouping();
        _rebuildRemAdjustment(
          p.remSize ?? MediaQuery.textScalerOf(context).scale(16),
        );
        _rebuildSizedColumns();
        _rebuildMangledColumns();

        final gridProps = SemiDataGridProps(
          width: _viewportWidth,
          height: _viewportHeight,
          // `{ ...sprites, ...p.headerIcons }` (`data-editor-all.tsx:13-15`).
          headerIcons: _mergedHeaderIcons,
          columns: _mangledColumns,
          rows: _mangledRows,
          hasAppendRow: _showTrailingBlankRow,
          // The row-marker column is chrome, so it is not exposed to readers
          // (`data-grid.tsx:1742-1744`).
          firstColAccessible: !_hasRowMarkers,
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
          freezeTrailingRows: _effectiveFreezeTrailingRows,
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
          prelightCells: _searchResults.isEmpty ? null : _searchResults,
          disabledRows: _disabledRows,
          isResizing: _resizeCol != null,
          // `isDragging={dragColActive}` (`data-grid-dnd.tsx:436`).
          isDragging: _dragColActive,
          // `allowResize={canResize}` (`data-grid-dnd.tsx:440`).
          allowResize: _canResize,
          resizeColumn: _resizeCol,
          // `onHeaderMenuClickMangled` / `onHeaderIndicatorClickMangled`
          // (`data-grid-dnd.tsx:188-201`) guard the drag, then
          // `onHeaderMenuClickInner` (`data-editor.tsx:2569-2581`) strips the
          // row-marker offset.
          onHeaderMenuClick: widget.props.onHeaderMenuClick == null
              ? null
              : (col, bounds) {
                  if (_dragColActive || _dragRowActive) return;
                  widget.props.onHeaderMenuClick!(col - _markerOffset, bounds);
                },
          onHeaderIndicatorClick: widget.props.onHeaderIndicatorClick == null
              ? null
              : (col, bounds) {
                  if (_dragColActive || _dragRowActive) return;
                  widget.props.onHeaderIndicatorClick!(
                    col - _markerOffset,
                    bounds,
                  );
                },
          resizeIndicator: p.resizeIndicator,
          dragAndDropState: _dragCol != null && _dropCol != null
              ? SemiColumnDndState(src: _dragCol!, dest: _dropCol!)
              : null,
          highlightRegions: _highlightRegions(),
          getRowThemeOverride: _rowThemeOverride,
          drawHeader: _wrapDrawHeader(widget.props.drawHeader),
          drawCell: _wrapDrawCell(widget.props.drawCell),
          getGroupDetails: _groupDetails,
          metrics: _metrics,
          minimumCellWidth: 10,
          a11yRevision: _a11yRevision,
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
              onPointerDown: _handleEditorPointerDown,
              onPointerMove: _handleEditorPointerMove,
              onPointerUp: _handleEditorPointerUp,
              onPointerCancel: _handleEditorPointerCancel,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  RepaintBoundary(
                    child: SemiDataGrid(
                      props: gridProps,
                      controller: _gridController,
                    ),
                  ),
                  if (_overlay != null) _buildOverlay(),
                  if (_renameGroup != null)
                    SemiGroupRename(
                      bounds: _renameGroup!.bounds,
                      group: _renameGroup!.group,
                      theme: _theme,
                      onClose: () => setState(() => _renameGroup = null),
                      onFinish: _finishGroupRename,
                    ),
                  if (_showSearch || _searchAnimatingOut)
                    SemiSearchBar(
                      show: _showSearch,
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
  void _onContextMenu(SemiGridMouseArgs args, void Function() preventDefault) {
    final adjustedCol = _locationOf(args).col - _markerOffset;

    if (args is SemiGridHeaderMouseArgs) {
      widget.props.onHeaderContextMenu?.call(
        adjustedCol,
        SemiHeaderClickedEventArgs(
          col: adjustedCol,
          args: args,
          preventDefault: preventDefault,
        ),
      );
      return;
    }

    if (args is SemiGridGroupHeaderMouseArgs) {
      if (adjustedCol < 0) return;
      widget.props.onGroupHeaderContextMenu?.call(
        adjustedCol,
        SemiGroupHeaderClickedEventArgs(
          col: adjustedCol,
          args: args,
          preventDefault: preventDefault,
        ),
      );
      return;
    }

    if (args is SemiGridCellMouseArgs) {
      final location = args.location;
      widget.props.onCellContextMenu?.call(
        SemiItem(location.col - _markerOffset, location.row),
        SemiCellClickedEventArgs(
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

  final SemiTextMetrics _metrics = SemiTextMetrics();

  /// `{ ...sprites, ...p.headerIcons }` (`data-editor-all.tsx:13-15`).
  ///
  /// Memoized on the caller's map: a fresh literal every build made
  /// `SemiDataGrid.didUpdateWidget`'s identity check think the sprites had
  /// changed, so it disposed and re-decoded the whole sprite manager on every
  /// rebuild (and defeated the painter's `spriteManager` equality check).
  Map<String, SemiSpriteFn>? _headerIconsCache;
  Map<String, SemiSpriteFn>? _headerIconsCacheSource;

  Map<String, SemiSpriteFn> get _mergedHeaderIcons {
    final extra = widget.props.headerIcons;
    if (_headerIconsCache != null &&
        identical(_headerIconsCacheSource, extra)) {
      return _headerIconsCache!;
    }
    _headerIconsCacheSource = extra;
    return _headerIconsCache = {...semiSprites, ...?extra};
  }

  /// `drawCellInner` / `drawHeaderInner` (`data-editor.tsx:4250-4270`): the
  /// marker offset is stripped from the args before the caller sees them.
  ///
  /// The wrapper is cached because `SemiDrawGridArg` compares draw callbacks
  /// by identity; a fresh closure per build would force a repaint on every
  /// rebuild for every grid that sets `drawCell` or `drawHeader`.
  SemiDrawCellCallback? _drawCellWrapper;
  SemiDrawCellCallback? _drawCellWrapperSource;
  int? _drawCellWrapperOffset;

  SemiDrawCellCallback? _wrapDrawCell(SemiDrawCellCallback? source) {
    if (source == null) return _drawCellWrapper = _drawCellWrapperSource = null;
    if (identical(source, _drawCellWrapperSource) &&
        _drawCellWrapperOffset == _markerOffset) {
      return _drawCellWrapper;
    }
    final offset = _markerOffset;
    _drawCellWrapperSource = source;
    _drawCellWrapperOffset = offset;
    return _drawCellWrapper = (args, draw) =>
        source(args.copyWith(col: args.col - offset), draw);
  }

  SemiDrawHeaderCallback? _drawHeaderWrapper;
  SemiDrawHeaderCallback? _drawHeaderWrapperSource;
  int? _drawHeaderWrapperOffset;

  SemiDrawHeaderCallback? _wrapDrawHeader(SemiDrawHeaderCallback? source) {
    if (source == null) {
      return _drawHeaderWrapper = _drawHeaderWrapperSource = null;
    }
    if (identical(source, _drawHeaderWrapperSource) &&
        _drawHeaderWrapperOffset == _markerOffset) {
      return _drawHeaderWrapper;
    }
    final offset = _markerOffset;
    _drawHeaderWrapperSource = source;
    _drawHeaderWrapperOffset = offset;
    return _drawHeaderWrapper = (args, draw) =>
        source(args.copyWith(columnIndex: args.columnIndex - offset), draw);
  }

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
    return SemiDataGridOverlayEditor(
      target: overlay.target,
      cell: overlay.cell,
      content: overlay.content,
      theme: overlay.theme,
      onFinishEditing: _finishEditing,
      forceEditMode: overlay.forceEditMode,
      highlight: overlay.highlight,
      getCellRenderer: _renderers.forCell,
      initialValue: overlay.initialValue,
      bloom: widget.props.editorBloom,
      // The overlay cell is mangled (marker-inclusive); callbacks handed to
      // the caller are marker-free (`data-editor.tsx:987-993`).
      validateCell: widget.props.validateCell == null
          ? null
          : (cell, newValue, prevValue) => widget.props.validateCell!(
              SemiItem(cell.col - _markerOffset, cell.row),
              newValue,
              prevValue,
            ),
      provideEditor: widget.props.provideEditor == null
          ? null
          : (cell, location) => widget.props.provideEditor!(
              cell,
              SemiItem(location.col - _markerOffset, location.row),
            ),
      activation: overlay.activation,
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

  final SemiRectangle target;
  final SemiItem cell;
  final SemiGridCell content;
  final SemiDataGridTheme theme;
  final String? initialValue;
  final bool highlight;
  final bool forceEditMode;
  final SemiCellActivation activation;
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
