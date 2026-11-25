// Port of `packages/core/src/internal/data-grid/data-grid.tsx`.
//
// Upstream this is a `<canvas>` plus window-level pointer/key listeners that
// translate DOM events into `GridMouseEventArgs` and hand them to the owner
// (`data-editor`). Here the same job is done by a Flutter `Listener` +
// `Focus` + `CustomPaint`; the DOM-only concerns (dpr, sprite manager,
// `getBoundingClientRect` scaling, HTML5 drag and drop, accessibility tree)
// are dropped or deferred.
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../cells/semi_cell_types.dart';
import '../../common/semi_image_window_loader.dart';
import '../../../theme/semi_theme.dart';
import 'semi_sprite_manager.dart';
import 'semi_sprites.dart';
import '../../common/semi_utils.dart';
import '../../common/semi_math.dart';
import '../../common/semi_is_hotkey.dart';
import 'semi_animation_manager.dart';
import 'semi_event_args.dart';
import 'render/semi_data_grid_painter.dart';
import 'render/semi_draw_grid_arg.dart';

/// `DataGridProps` (`data-grid.tsx:63-312`), narrowed to what the Flutter
/// port draws and routes. Fields that only exist for DOM concerns are
/// documented where they would have appeared.
@immutable
class SemiDataGridProps {
  const SemiDataGridProps({
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    required this.rowHeight,
    required this.getCellContent,
    required this.getCellRenderer,
    this.theme,
    required this.verticalBorder,
    required this.onItemHovered,
    required this.onMouseMove,
    required this.onMouseDown,
    this.onPointerMoveRaw,
    required this.onMouseUp,
    required this.onContextMenu,
    required this.onCanvasFocused,
    required this.onCanvasBlur,
    required this.onCellFocused,
    required this.onKeyDown,
    this.onKeyUp,
    this.cellXOffset = 0,
    this.cellYOffset = 0,
    this.translateX = 0,
    this.translateY = 0,
    this.freezeColumns = 0,
    this.freezeTrailingRows = 0,
    this.hasAppendRow = false,
    this.headerHeight = 36,
    this.groupHeaderHeight = 36,
    this.enableGroups = false,
    this.isFocused = false,
    this.isResizing = false,
    this.isDragging = false,
    this.isFilling = false,
    this.dragAndDropState,
    this.resizeIndicator = SemiResizeIndicator.full,
    this.allowResize,
    this.resizeColumn,
    this.selection = SemiGridSelection.empty,
    this.disabledRows = const SemiCompactSelection.empty(),
    this.prelightCells,
    this.highlightRegions,
    this.fillHandle,
    this.getGroupDetails,
    this.getRowThemeOverride,
    this.drawFocusRing = true,
    this.smoothScrollX = false,
    this.smoothScrollY = false,
    this.hyperWrapping = false,
    this.touchMode = false,
    this.metrics,
    this.enqueue,
    this.minimumCellWidth = 10,
    this.onHeaderMenuClick,
    this.onHeaderIndicatorClick,
    this.drawHeader,
    this.drawCell,
    this.fixedShadowX = true,
    this.fixedShadowY = true,
    this.imageLoader,
    this.headerIcons,
    this.firstColAccessible = true,
    this.disableAccessibilityTree = false,
    this.a11yRevision = 0,
  });

  final double width;
  final double height;
  final int cellXOffset;
  final int cellYOffset;
  final double translateX;
  final double translateY;

  final int freezeColumns;
  final int freezeTrailingRows;
  final bool hasAppendRow;

  final bool? allowResize;
  final bool isResizing;
  final int? resizeColumn;
  final bool isDragging;
  final bool isFilling;

  /// `dragAndDropState` (`data-grid.tsx:234-238`): `{src, dest}` column pair
  /// while a column is being dragged.
  final SemiColumnDndState? dragAndDropState;
  final SemiResizeIndicator resizeIndicator;
  final bool isFocused;

  final List<SemiGridColumn> columns;
  final int rows;

  final double headerHeight;
  final double groupHeaderHeight;
  final bool enableGroups;
  final SemiRowHeight rowHeight;

  /// `getCellContent(cell, forceStrict?)` (`data-grid.tsx:114`); the second
  /// argument is only meaningful to `data-editor`'s strict mode.
  final SemiGridCell Function(SemiItem cell, [bool? forceStrict])
  getCellContent;
  final SemiGroupDetails Function(String group)? getGroupDetails;
  final SemiGetRowThemeOverride? getRowThemeOverride;

  final void Function(int col, SemiRectangle screenPosition)?
  onHeaderMenuClick;
  final void Function(int col, SemiRectangle screenPosition)?
  onHeaderIndicatorClick;

  /// `drawHeader` / `drawCell` (`data-grid.tsx:223,225`): take over the paint
  /// of a header or a cell. Indices are *mangled*; `SemiDataEditorProps`
  /// strips the row-marker column first.
  final SemiDrawHeaderCallback? drawHeader;
  final SemiDrawCellCallback? drawCell;

  /// `fixedShadowX` / `fixedShadowY` (`data-grid.tsx:84,89`): the soft inset
  /// shadow that fades in where the frozen columns (or the header) meet the
  /// scrolling content.
  final bool fixedShadowX;
  final bool fixedShadowY;

  /// `imageWindowLoader` (`data-grid.tsx`): when null the grid owns one and
  /// disposes it with itself.
  final SemiImageWindowLoader? imageLoader;

  /// `headerIcons` (`data-grid.tsx:282`): extra sprites keyed by name, merged
  /// over the built-in set by the editor the same way `DataEditorAll` does
  /// (`data-editor-all.tsx:13-15`). Null means "built-ins only".
  final Map<String, SemiSpriteFn>? headerIcons;

  /// `firstColAccessible` (`data-grid.tsx:1745`): false hides the row-marker
  /// column from the accessibility tree.
  final bool firstColAccessible;

  /// `experimental.disableAccessibilityTree` (`data-grid.tsx:1739`).
  final bool disableAccessibilityTree;

  /// Bumped by the owner whenever cell content changed outside of
  /// `onCellsEdited`, so the cached accessibility tree is rebuilt.
  final int a11yRevision;

  final SemiGridSelection selection;
  final List<SemiItem>? prelightCells;
  final List<SemiDataGridHighlight>? highlightRegions;
  final SemiFillHandleConfig? fillHandle;
  final SemiCompactSelection? disabledRows;

  final void Function(SemiGridMouseArgs args) onItemHovered;
  final void Function(SemiGridMouseArgs args) onMouseMove;

  /// Window-level `mousemove` (`data-grid.tsx`), used by column resizing
  /// which must keep tracking after the pointer leaves the header.
  final void Function(Offset position)? onPointerMoveRaw;
  final void Function(SemiGridMouseArgs args) onMouseDown;
  final void Function(SemiGridMouseArgs args, bool isOutside) onMouseUp;
  final void Function(SemiGridMouseArgs args, void Function() preventDefault)
  onContextMenu;

  final void Function() onCanvasFocused;
  final void Function() onCanvasBlur;
  final void Function(SemiItem args) onCellFocused;

  final void Function(SemiGridKeyArgs event) onKeyDown;
  final void Function(SemiGridKeyArgs event)? onKeyUp;

  final bool Function(int col) verticalBorder;
  final bool drawFocusRing;

  /// Null derives the theme from the nearest SemiTheme.
  final SemiDataGridTheme? theme;
  final SemiGetCellRenderer getCellRenderer;

  final bool smoothScrollX;
  final bool smoothScrollY;
  final bool hyperWrapping;
  final bool touchMode;

  /// `TextMetrics` cache shared across the grid; when null a private one is
  /// created per paint.
  final SemiTextMetrics? metrics;

  /// Overrides the built-in animation queue (`use-animation-queue.ts`).
  /// Upstream owns that internally; it is a prop here only so a caller can
  /// substitute its own damage scheduling. Null keeps the grid's own queue,
  /// which is what drives the `lastUpdated` flash to completion.
  final void Function(SemiItem item)? enqueue;
  final double minimumCellWidth;
}

/// `DataGridRef` (`data-grid.tsx:319-325`).
class SemiDataGridController extends ChangeNotifier {
  _SemiDataGridState? _state;

  /// `focus()` (`data-grid.tsx:320`).
  void focus() => _state?._focusNode.requestFocus();

  /// `getBounds(col, row)` (`data-grid.tsx:321`): canvas-local bounds, or
  /// null when the cell is off-screen.
  SemiRectangle? getBounds(int? col, int? row) =>
      _state?._getBoundsForItem(col ?? -1, row ?? -1);

  /// `damage(cells)` (`data-grid.tsx:322`): request a repaint of specific
  /// cells. Flutter repaints the whole painter, so this is a no-op kept for
  /// API parity.
  void damage(Iterable<SemiItem> cells) => notifyListeners();
}

class SemiDataGrid extends StatefulWidget {
  const SemiDataGrid({super.key, required this.props, this.controller});

  final SemiDataGridProps props;
  final SemiDataGridController? controller;

  @override
  State<SemiDataGrid> createState() => _SemiDataGridState();
}

/// `[columns, freezeColumns] -> mappedColumns`, mirroring the dependency
/// array of upstream's `useMemo` (`data-grid.tsx:432`).
class _MappedColumnsMemo {
  const _MappedColumnsMemo({
    this.columns,
    this.freezeColumns,
    this.mapped = const [],
  });

  final List<SemiGridColumn>? columns;
  final int? freezeColumns;
  final List<SemiMappedColumn> mapped;
}

class _SemiDataGridState extends State<SemiDataGrid>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'SemiDataGrid');

  /// `AnimationManager` (`data-grid.tsx:415`, `:768-787`).
  final SemiAnimationManager _hoverAnimation = SemiAnimationManager();
  Map<SemiItem, double> _hoverValues = const {};
  late final Ticker _hoverTicker;
  Duration _lastHoverTick = Duration.zero;

  /// `useAnimationQueue` (`use-animation-queue.ts`): the Web version batches
  /// damaged cells and redraws them on the next animation frame. Flutter's
  /// painter redraws the whole surface anyway, so the queue collapses to
  /// "request one more frame" — which is what lets a `lastUpdated` flash
  /// advance to completion instead of freezing on the frame it started on.
  ///
  /// Deviation: upstream damages only the enqueued cells; here every request
  /// repaints the full viewport.
  bool _enqueueScheduled = false;
  final GlobalKey _paintKey = GlobalKey(debugLabel: 'SemiDataGridPainter');

  void _enqueue(SemiItem item) {
    if (_enqueueScheduled) return;
    _enqueueScheduled = true;
    // `enqueue` runs from inside `paint`, so the repaint is deferred to the
    // end of this frame — the Flutter equivalent of `requestAnimationFrame`.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _enqueueScheduled = false;
      if (!mounted) return;
      final render = _paintKey.currentContext?.findRenderObject();
      if (render != null && render.attached) render.markNeedsPaint();
    });
  }

  /// `imageWindowLoader` (`data-grid.tsx:157`).
  late SemiImageWindowLoader _imageLoader;
  bool _ownsImageLoader = false;

  /// `spriteManager` (`data-grid.tsx:427-433`): rebuilt when `headerIcons`
  /// changes, exactly as upstream's `useMemo(..., [headerIcons])`. Its
  /// `onSettled` is upstream's `lastDrawRef.current()` — repaint once every
  /// in-flight sprite has landed.
  late SemiSpriteManager _spriteManager;
  Offset? _pointer;
  bool _pointerInside = false;
  SemiGridMouseArgs? _hoveredArgs;
  bool _hoveredOnEdge = false;
  bool _lastWasTouch = false;
  // Flutter's pointer-up event no longer carries the released button.
  final _pointerPresses =
      <
        int,
        ({
          int button,
          int time,
          SemiItem location,
          ({bool? menu, int? groupAction})? control,
        })
      >{};
  int _lastUpTime = 0;
  bool _cursorIsPointer = false;

  /// `useMemo(() => mapColumns(columns, freezeColumns), [columns,
  /// freezeColumns])` — the Web version derives the mapped list once per
  /// column change, but this port re-derived it on every call, so
  /// `mappedColumns` was a fresh list each build. That alone made
  /// [SemiDataGridPainter.shouldRepaint]'s identity check always fail, i.e.
  /// the painter repainted on every rebuild no matter what changed.
  ///
  /// Keyed the same way React's dependency array is: by reference. A caller
  /// that mutates its `columns` list in place and rebuilds without replacing
  /// it keeps the stale mapping, exactly as upstream does.
  _MappedColumnsMemo _mappedMemo = const _MappedColumnsMemo();

  /// `arg.metrics` used to be `p.metrics ?? SemiTextMetrics()`, allocating a
  /// cache per build. One shared instance keeps the text cache warm and lets
  /// the painter's equality check hold across rebuilds.
  SemiTextMetrics? _defaultMetrics;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _hoverTicker = createTicker(_onHoverTick);
    _resolveImageLoader();
    _resolveSpriteManager();
  }

  List<SemiMappedColumn> _mappedColumnsOf(SemiDataGridProps p) {
    final memo = _mappedMemo;
    if (identical(memo.columns, p.columns) &&
        memo.freezeColumns == p.freezeColumns) {
      return memo.mapped;
    }
    return (_mappedMemo = _MappedColumnsMemo(
      columns: p.columns,
      freezeColumns: p.freezeColumns,
      mapped: mapColumns(p.columns, p.freezeColumns),
    )).mapped;
  }

  SemiTextMetrics get _metrics =>
      widget.props.metrics ?? (_defaultMetrics ??= SemiTextMetrics());

  void _resolveSpriteManager() {
    _spriteManager = SemiSpriteManager(
      icons: widget.props.headerIcons ?? const {},
      settled: _onSpritesSettled,
    );
  }

  void _onSpritesSettled() {
    if (!mounted) return;
    final render = _paintKey.currentContext?.findRenderObject();
    if (render != null && render.attached) render.markNeedsPaint();
  }

  void _resolveImageLoader() {
    final injected = widget.props.imageLoader;
    if (injected != null) {
      _imageLoader = injected;
      _ownsImageLoader = false;
    } else {
      _imageLoader = SemiImageWindowLoader();
      _ownsImageLoader = true;
    }
    _imageLoader.onLoaded = (_) {
      if (mounted) setState(() {});
    };
  }

  @override
  void didUpdateWidget(SemiDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
    if (!identical(oldWidget.props.imageLoader, widget.props.imageLoader)) {
      if (_ownsImageLoader) _imageLoader.dispose();
      _resolveImageLoader();
    }
    if (!identical(oldWidget.props.headerIcons, widget.props.headerIcons)) {
      _spriteManager.dispose();
      _resolveSpriteManager();
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _spriteManager.dispose();
    if (_ownsImageLoader) _imageLoader.dispose();
    _imageLoader.onLoaded = null;
    _hoverTicker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// `setWindow` (`image-window-loader.ts:52-66`): the visible cell rect,
  /// derived from the offsets the grid already has instead of a scroll
  /// position it does not own.
  void _updateImageWindow(List<SemiMappedColumn> mapped) {
    final p = widget.props;

    var endCol = p.cellXOffset;
    var x = p.translateX;
    while (endCol < mapped.length && x <= p.width) {
      x += mapped[endCol].width;
      endCol++;
    }

    var endRow = p.cellYOffset;
    var y = p.translateY;
    while (endRow < p.rows && y <= p.height) {
      y += p.rowHeight(endRow);
      endRow++;
    }

    _imageLoader.setWindow(
      SemiRectangle(
        x: p.cellXOffset.toDouble(),
        y: p.cellYOffset.toDouble(),
        width: math.max(0, endCol - p.cellXOffset).toDouble(),
        height: math.max(0, endRow - p.cellYOffset).toDouble(),
      ),
      p.freezeColumns,
      const [],
    );
  }

  /// `onAnimationFrame` (`data-grid.tsx:1266-1272`).
  void _onHoverTick(Duration elapsed) {
    if (_lastHoverTick == Duration.zero) {
      _lastHoverTick = elapsed;
      return;
    }
    final dtMs = (elapsed - _lastHoverTick).inMicroseconds / 1000.0;
    _lastHoverTick = elapsed;

    _hoverAnimation.step(dtMs, (values) {
      _hoverValues = {for (final v in values) v.item: v.amount};
      setState(() {});
    });

    if (!_hoverAnimation.shouldStep) {
      _hoverTicker.stop();
      _lastHoverTick = Duration.zero;
    }
  }

  /// `useLayoutEffect` over `hoveredItem` (`data-grid.tsx:768-787`): only
  /// renderers that opt into hover animate, headers always do.
  void _updateHoveredItem(SemiGridMouseArgs? args) {
    SemiItem? item;
    if (args is SemiGridCellMouseArgs) {
      item = args.location;
    } else if (args is SemiGridHeaderMouseArgs) {
      item = args.location;
    } else if (args is SemiGridGroupHeaderMouseArgs) {
      item = args.location;
    }

    if (item == null || item.row < 0) {
      _hoverAnimation.setHovered(item);
    } else {
      final cell = widget.props.getCellContent(item, true);
      final renderer = widget.props.getCellRenderer(cell);
      final needsHover = renderer == null
          ? cell.kind == SemiCellKind.custom
          : renderer.needsHoverFor(cell);
      _hoverAnimation.setHovered(needsHover ? item : null);
    }

    if (_hoverAnimation.shouldStep && !_hoverTicker.isActive) {
      _lastHoverTick = Duration.zero;
      _hoverTicker.start();
    }
  }

  // -------------------------------------------------------------------------
  // getBoundsForItem (`data-grid.tsx:459-514`)
  // -------------------------------------------------------------------------

  SemiRectangle? _getBoundsForItem(int col, int row) {
    final p = widget.props;
    if (col >= p.columns.length || row >= p.rows) return null;
    if (col < 0 &&
        row != SemiItem.headerRow &&
        row != SemiItem.groupHeaderRow) {
      return null;
    }

    final mapped = _mappedColumnsOf(p);
    final totalHeaderHeight = p.enableGroups
        ? p.groupHeaderHeight + p.headerHeight
        : p.headerHeight;

    return computeBounds(
      col: col,
      row: row,
      width: p.width,
      height: p.height,
      // `computeBounds` derives the header strip as
      // `totalHeaderHeight - groupHeaderHeight`, so the two have to be
      // guarded the same way. Passing the raw prop here (as upstream's
      // `getBoundsForItem` does) yields a negative header height whenever the
      // caller leaves `groupHeaderHeight` at its default while groups are off
      // — which is this port's default combination.
      groupHeaderHeight: p.enableGroups ? p.groupHeaderHeight : 0,
      totalHeaderHeight: totalHeaderHeight,
      cellXOffset: p.cellXOffset,
      cellYOffset: p.cellYOffset,
      translateX: p.translateX,
      translateY: p.translateY,
      rows: p.rows,
      freezeColumns: p.freezeColumns,
      freezeTrailingRows: p.freezeTrailingRows,
      mappedColumns: mapped,
      rowHeight: p.rowHeight,
    );
  }

  /// `args.location` — the field lives on each [SemiGridMouseArgs] subclass
  /// rather than on the base type, so it has to be narrowed by kind first.
  SemiItem _locationOf(SemiGridMouseArgs args) => switch (args) {
    SemiGridCellMouseArgs a => a.location,
    SemiGridHeaderMouseArgs a => a.location,
    SemiGridGroupHeaderMouseArgs a => a.location,
    SemiGridOutOfBoundsMouseArgs a => a.location,
  };

  // -------------------------------------------------------------------------
  // isOverHeaderElement (`data-grid.tsx:1024-1070`)
  // ------------------------------------------------------------------------

  /// Whether [args] is a header sitting on its column's resize edge.
  ///
  /// Upstream folds this into `hoveredOnEdge` (`data-grid.tsx:1355`:
  /// `kind === headerKind && isEdge && notRowMarkerCol && allowResize ===
  /// true`) and reads it from both the menu guard and the cursor, so the two
  /// sites share this one predicate.
  bool _onHeaderResizeEdge(SemiGridMouseArgs args) =>
      args is SemiGridHeaderMouseArgs &&
      args.isEdge &&
      widget.props.allowResize == true &&
      args.location.col >= (widget.props.firstColAccessible ? 0 : 1);

  /// Whether ([x], [y]) lands on [col]'s header menu button or indicator icon.
  ///
  /// Upstream compares viewport coordinates against `getBoundsForItem`, which
  /// adds the canvas's `getBoundingClientRect()` offset; here both sides are
  /// grid-internal ([_getBoundsForItem] and `PointerEvent.localPosition`), so
  /// the comparison needs no offset.
  ({bool menu, SemiRectangle bounds})? _isOverHeaderElement(
    int col,
    double x,
    double y,
    bool onResizeEdge,
  ) {
    final p = widget.props;
    // `if (!isDragging && !isResizing && !(hoveredOnEdge ?? false))`
    // (`data-grid.tsx:1044`).
    //
    // Upstream derives `hoveredOnEdge` from the header's own resize edge
    // (`data-grid.tsx:1355`), so that is what is tested here. This port's
    // [_hoveredOnEdge] tracks the out-of-bounds padding instead — a different
    // region that never overlaps the menu button — so reading it would leave
    // this arm silently dead.
    if (p.isDragging || p.isResizing || onResizeEdge) return null;

    final headerBounds = _getBoundsForItem(col, SemiItem.headerRow);
    if (headerBounds == null) return null;

    final mapped = _mappedColumnsOf(p);
    if (col >= mapped.length) return null;
    final header = mapped[col];

    // Upstream passes `ctx: undefined` here, which only affects the measured
    // title width used to place the indicator; see [computeHeaderLayout].
    //
    // The width is the column's, not `headerBounds.width`: `computeBounds`
    // reports `width + 1` so a cell's hit box covers its grid line, but
    // `drawGridHeaders` paints the header with the raw width
    // (`data-grid-render.header.ts:114`). Using the inflated width here would
    // put the menu button's hit box one pixel right of the button that is
    // actually on screen — upstream has exactly that off-by-one; this port
    // keeps the two aligned instead.
    final layout = computeHeaderLayout(
      c: header,
      x: headerBounds.x,
      y: headerBounds.y,
      width: header.width,
      height: headerBounds.height,
      theme: _resolvedTheme,
      metrics: _metrics,
    );

    if (header.hasMenu && pointInRect(layout.menuBounds, x, y)) {
      return (menu: true, bounds: layout.menuBounds);
    }
    final indicator = layout.indicatorIconBounds;
    if (header.indicatorIcon != null &&
        indicator != null &&
        pointInRect(indicator, x, y)) {
      return (menu: false, bounds: indicator);
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // getMouseArgsForPosition (`data-grid.tsx:516-...`)
  // -------------------------------------------------------------------------

  SemiGridMouseArgs _getMouseArgsForPosition(
    double posX,
    double posY, {
    required int button,
    required int buttons,
    required bool shiftKey,
    required bool ctrlKey,
    required bool metaKey,
    required bool isTouch,
    bool isLongTouch = false,
    bool isDoubleClick = false,
  }) {
    final p = widget.props;
    final x = posX;
    final y = posY;
    const edgeDetectionBuffer = 5;

    final mapped = _mappedColumnsOf(p);
    final effectiveCols = getEffectiveColumns(
      mapped,
      p.cellXOffset,
      p.width,
      null,
      p.translateX,
    );

    // -1 === off right edge.
    final col = getColumnIndexForX(x, effectiveCols, p.translateX);

    // -1: header or above; null: off bottom.
    final row = getRowIndexForY(
      targetY: y,
      height: p.height,
      hasGroups: p.enableGroups,
      headerHeight: p.headerHeight,
      // `data-editor.tsx:4276` passes `groupHeaderHeight` as 0 when groups
      // are off, which is what makes `getRowIndexForY`'s unconditional
      // `headerHeight + groupHeaderHeight` add up correctly.
      groupHeaderHeight: p.enableGroups ? p.groupHeaderHeight : 0,
      rows: p.rows,
      rowHeight: p.rowHeight,
      cellYOffset: p.cellYOffset,
      translateY: p.translateY,
      freezeTrailingRows: p.freezeTrailingRows,
    );

    final totalHeaderHeight = p.enableGroups
        ? p.groupHeaderHeight + p.headerHeight
        : p.headerHeight;

    final scrollEdge = (
      x < 0 ? -1 : (p.width < x ? 1 : 0),
      y < totalHeaderHeight ? -1 : (p.height < y ? 1 : 0),
    );

    bool edge(int colIndex, int rowIndex) {
      final b = _getBoundsForItem(colIndex, rowIndex);
      if (b == null) return false;
      return x < b.x + b.width + edgeDetectionBuffer;
    }

    bool isMaybeScrollbar = false;

    if (col == -1 ||
        y < 0 ||
        x < 0 ||
        row == null ||
        x > p.width ||
        y > p.height) {
      var horizontal = x > p.width ? 1 : (x < 0 ? -1 : 0);
      var vertical = y > p.height ? 1 : (y < 0 ? -1 : 0);
      if (horizontal != 0) horizontal *= 2;
      if (vertical != 0) vertical *= 2;

      var innerHorizontal = horizontal;
      var innerVertical = vertical;
      if (x <= p.width && x >= 0) {
        innerHorizontal = col == -1
            ? SemiOutOfBoundsRegionAxis.endPadding.value
            : SemiOutOfBoundsRegionAxis.center.value;
      }
      if (y <= p.height && y >= 0) {
        innerVertical = row == null
            ? SemiOutOfBoundsRegionAxis.endPadding.value
            : SemiOutOfBoundsRegionAxis.center.value;
      }

      var isEdge = false;
      if (col == -1 && row == SemiItem.headerRow) {
        isEdge = edge(p.columns.length - 1, SemiItem.headerRow);
      } else if (row != null) {
        isEdge = edge(col < 0 ? p.columns.length - 1 : col, row);
      }

      // Clicking the scrollbar must not clear the selection; upstream detects
      // this by checking whether the point is past the content extent.
      if (!isEdge) isMaybeScrollbar = scrollEdge.$1 != 0 || scrollEdge.$2 != 0;

      return SemiGridOutOfBoundsMouseArgs(
        shiftKey: shiftKey,
        ctrlKey: ctrlKey,
        metaKey: metaKey,
        isTouch: isTouch,
        isLongTouch: isLongTouch,
        isDoubleClick: isDoubleClick,
        isEdge: isEdge,
        button: button,
        buttons: buttons,
        scrollEdge: scrollEdge,
        location: SemiItem(
          col < 0 ? p.columns.length - 1 : col,
          row ?? (y < totalHeaderHeight ? SemiItem.headerRow : p.rows - 1),
        ),
        isMaybeScrollbar: isMaybeScrollbar,
        region: (
          SemiOutOfBoundsRegionAxis.values.firstWhere(
            (e) => e.value == innerHorizontal,
          ),
          SemiOutOfBoundsRegionAxis.values.firstWhere(
            (e) => e.value == innerVertical,
          ),
        ),
      );
    }

    // Header rows (`data-grid.tsx:613-656`): the left edge of a column is
    // reported as the right edge of the previous one.
    if (row <= -1) {
      var bounds = _getBoundsForItem(col, row)!;
      var isEdge = bounds.x + bounds.width - x <= edgeDetectionBuffer;
      var targetCol = col;
      final previousCol = col - 1;
      if (x - bounds.x <= edgeDetectionBuffer && previousCol >= 0) {
        isEdge = true;
        targetCol = previousCol;
        bounds = _getBoundsForItem(previousCol, row)!;
      }

      final group = targetCol < p.columns.length
          ? p.columns[targetCol].group ?? ''
          : '';
      final common = (
        shiftKey: shiftKey,
        ctrlKey: ctrlKey,
        metaKey: metaKey,
        isTouch: isTouch,
        isLongTouch: isLongTouch,
        isDoubleClick: isDoubleClick,
        isEdge: isEdge,
        button: button,
        buttons: buttons,
        scrollEdge: scrollEdge,
        location: SemiItem(targetCol, row),
        bounds: bounds,
        group: group,
        localEventX: x - bounds.x,
        localEventY: y - bounds.y,
      );

      if (row == SemiItem.groupHeaderRow) {
        return SemiGridGroupHeaderMouseArgs(
          shiftKey: common.shiftKey,
          ctrlKey: common.ctrlKey,
          metaKey: common.metaKey,
          isTouch: common.isTouch,
          isLongTouch: common.isLongTouch,
          isDoubleClick: common.isDoubleClick,
          isEdge: common.isEdge,
          button: common.button,
          buttons: common.buttons,
          scrollEdge: common.scrollEdge,
          location: common.location,
          bounds: common.bounds,
          group: common.group,
          localEventX: common.localEventX,
          localEventY: common.localEventY,
        );
      }
      return SemiGridHeaderMouseArgs(
        shiftKey: common.shiftKey,
        ctrlKey: common.ctrlKey,
        metaKey: common.metaKey,
        isTouch: common.isTouch,
        isLongTouch: common.isLongTouch,
        isDoubleClick: common.isDoubleClick,
        isEdge: common.isEdge,
        button: common.button,
        buttons: common.buttons,
        scrollEdge: common.scrollEdge,
        location: common.location,
        bounds: common.bounds,
        group: common.group,
        localEventX: common.localEventX,
        localEventY: common.localEventY,
      );
    }

    final bounds = _getBoundsForItem(col, row)!;
    final isEdge = bounds.x + bounds.width - x < edgeDetectionBuffer;

    return SemiGridCellMouseArgs(
      shiftKey: shiftKey,
      ctrlKey: ctrlKey,
      metaKey: metaKey,
      isTouch: isTouch,
      isLongTouch: isLongTouch,
      isDoubleClick: isDoubleClick,
      isEdge: isEdge,
      button: button,
      buttons: buttons,
      scrollEdge: scrollEdge,
      location: SemiItem(col, row),
      bounds: bounds,
      isFillHandle: _isFillHandleAt(x, y),
      localEventX: x - bounds.x,
      localEventY: y - bounds.y,
    );
  }

  /// Fill-handle hit test (`data-grid.tsx:662-687`): the handle center sits
  /// exactly on the bottom-right corner of the selected range, offset by half
  /// a pixel to line up with the grid lines.
  bool _isFillHandleAt(double posX, double posY) {
    final p = widget.props;
    final config = p.fillHandle;
    final current = p.selection.current;
    if (config == null || current == null || !p.drawFocusRing) return false;

    final bottomRight = rectBottomRight(current.range);
    final fillBounds = _getBoundsForItem(bottomRight.col, bottomRight.row);
    if (fillBounds == null) return false;

    final half = config.size / 2;
    final centerX =
        fillBounds.x + fillBounds.width + config.offsetX - half + 0.5;
    final centerY =
        fillBounds.y + fillBounds.height + config.offsetY - half + 0.5;
    return (centerX - posX).abs() < config.size &&
        (centerY - posY).abs() < config.size;
  }

  // -------------------------------------------------------------------------
  // Pointer wiring (`onPointerDown/Move/Up`, `data-grid.tsx:1076-1375`)
  // -------------------------------------------------------------------------

  /// `getRowData` (`data-grid.tsx:330-336`).
  String _accessibilityLabel(SemiGridCell cell) {
    if (cell is SemiCustomCell) return cell.copyData ?? '';
    return widget.props.getCellRenderer(cell)?.getAccessibilityString(cell) ??
        '';
  }

  /// The `td`'s `onClick` (`data-grid.tsx:1818-1835`): focusing a cell from
  /// the accessibility tree selects it first (the editor's `onCellFocused`,
  /// `data-editor.tsx:4124-4145`) and then activates it with Enter.
  void _accessibilityActivate(int col, int row) {
    final p = widget.props;
    final item = SemiItem(col, row);
    p.onCellFocused(item);
    p.onKeyDown(
      SemiGridKeyArgs(
        bounds: _getBoundsForItem(col, row),
        key: 'Enter',
        keyCode: 13,
        altKey: false,
        shiftKey: false,
        ctrlKey: false,
        metaKey: false,
        cancel: () {},
        stopPropagation: () {},
        preventDefault: () {},
        location: item,
      ),
    );
  }

  /// Cached so a parent rebuild that only changed hover values (which the
  /// semantics tree does not depend on) hands Flutter the very same widget
  /// instance and the ~144 nodes are left alone.
  ///
  /// Staleness matches upstream's `useDebouncedMemo` (`data-grid.ts:1737`),
  /// whose deps also exclude cell values: the tree refreshes when the
  /// selection, offsets, columns, renderer or content callback change.
  /// [SemiDataGridProps.a11yRevision] exists so the owner can force one.
  Widget? _accessibilityTreeCache;
  ({Object? key})? _accessibilityTreeKey;

  /// The `<table role="grid">` (`data-grid.tsx:1737-1856`), limited to the
  /// visible columns and rows exactly like the upstream virtualized tree.
  Widget _accessibilityTree(
    SemiDataGridProps p,
    List<SemiMappedColumn> effectiveCols,
  ) {
    final key = (
      p.width,
      p.cellXOffset,
      p.cellYOffset,
      p.translateX,
      p.rows,
      p.selection,
      p.firstColAccessible,
      p.disableAccessibilityTree,
      p.getCellContent,
      p.getCellRenderer,
      p.a11yRevision,
      Object.hashAll([for (final c in effectiveCols) c.sourceIndex]),
    );
    final cached = _accessibilityTreeCache;
    if (cached != null && _accessibilityTreeKey?.key == key) return cached;
    _accessibilityTreeKey = (key: key);
    final built = _buildAccessibilityTree(p, effectiveCols);
    _accessibilityTreeCache = built;
    return built;
  }

  Widget _buildAccessibilityTree(
    SemiDataGridProps p,
    List<SemiMappedColumn> effectiveCols,
  ) {
    if (p.width < 50 || p.disableAccessibilityTree) {
      return const SizedBox.shrink();
    }

    final cols = [...effectiveCols];
    if (!p.firstColAccessible &&
        cols.isNotEmpty &&
        cols.first.sourceIndex == 0) {
      cols.removeAt(0);
    }

    var endRow = p.cellYOffset;
    var y = p.translateY;
    while (endRow < p.rows && y <= p.height) {
      y += p.rowHeight(endRow);
      endRow++;
    }

    final range = p.selection.current?.range;
    final focused = p.selection.current?.cell;

    return Positioned.fill(
      child: IgnorePointer(
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: 'Grid',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                container: true,
                explicitChildNodes: true,
                label: 'Column headers',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final c in cols)
                      Semantics(
                        container: true,
                        button: true,
                        label: c.title,
                        selected: p.selection.columns.hasIndex(c.sourceIndex),
                        focused:
                            focused != null &&
                            focused.col == c.sourceIndex &&
                            focused.row < 0,
                        onTap: () => _accessibilityActivate(
                          c.sourceIndex,
                          SemiItem.headerRow,
                        ),
                        child: const SizedBox(width: 1, height: 1),
                      ),
                  ],
                ),
              ),
              for (var row = p.cellYOffset; row < endRow; row++)
                Semantics(
                  container: true,
                  explicitChildNodes: true,
                  label: 'Row ${row + 1}',
                  selected: p.selection.rows.hasIndex(row),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in cols)
                        _cellSemantics(p, c.sourceIndex, row, range, focused),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cellSemantics(
    SemiDataGridProps p,
    int col,
    int row,
    SemiRectangle? range,
    SemiItem? focused,
  ) {
    final cell = p.getCellContent(SemiItem(col, row), true);
    final selected =
        range != null &&
        col >= range.x &&
        col < range.x + range.width &&
        row >= range.y &&
        row < range.y + range.height;
    return Semantics(
      container: true,
      button: true,
      label: _accessibilityLabel(cell),
      selected: selected,
      readOnly: semiIsInnerOnlyCell(cell) || !semiIsReadWriteCell(cell),
      focused: focused != null && focused.col == col && focused.row == row,
      onTap: () => _accessibilityActivate(col, row),
      child: const SizedBox(width: 1, height: 1),
    );
  }

  /// `groupHeaderActionForEvent` (`data-grid.tsx:1004-1020`).
  ///
  /// Upstream compares `localEventY + box.y`, which only ever lands inside the
  /// top 26px of the header; the bounds-relative form is used here instead.
  ({int index, SemiGroupAction action})? _groupHeaderAction(
    SemiGridGroupHeaderMouseArgs args,
  ) {
    final details = widget.props.getGroupDetails?.call(args.group);
    final actions = details?.actions;
    if (actions == null || actions.isEmpty) return null;
    final boxes = getActionBoundsForGroup(args.bounds, actions);
    for (var i = 0; i < boxes.length; i++) {
      final hit = pointInRect(
        boxes[i],
        args.bounds.x + args.localEventX,
        args.bounds.y + args.localEventY,
      );
      if (hit) return (index: i, action: actions[i]);
    }
    return null;
  }

  ({({bool? menu, int? groupAction}) key, VoidCallback activate})?
  _headerControlAt(SemiGridMouseArgs args, Offset at) {
    if (args is SemiGridGroupHeaderMouseArgs) {
      if (widget.props.isDragging || widget.props.isResizing) return null;
      final hit = _groupHeaderAction(args);
      if (hit == null) return null;
      return (
        key: (menu: null, groupAction: hit.index),
        activate: () => hit.action.onClick(args.bounds),
      );
    }
    if (args is! SemiGridHeaderMouseArgs) return null;
    final col = args.location.col;
    final hit = _isOverHeaderElement(
      col,
      at.dx,
      at.dy,
      _onHeaderResizeEdge(args),
    );
    if (hit == null) return null;
    return (
      key: (menu: hit.menu, groupAction: null),
      activate: () {
        final p = widget.props;
        final callback = hit.menu
            ? p.onHeaderMenuClick
            : p.onHeaderIndicatorClick;
        callback?.call(col, hit.bounds);
      },
    );
  }

  int _pointerButton(int buttons) => switch (buttons) {
    kPrimaryButton => 0,
    kMiddleMouseButton => 1,
    kSecondaryButton => 2,
    _ => -1,
  };

  SemiGridMouseArgs _pointerArgs(
    PointerEvent event, {
    required int button,
    bool isLongTouch = false,
    bool isDoubleClick = false,
  }) {
    final isTouch = event.kind == PointerDeviceKind.touch;
    final keyboard = HardwareKeyboard.instance;
    return _getMouseArgsForPosition(
      event.localPosition.dx,
      event.localPosition.dy,
      button: button,
      buttons: event.buttons,
      shiftKey: !isTouch && keyboard.isShiftPressed,
      ctrlKey: !isTouch && keyboard.isControlPressed,
      metaKey: !isTouch && keyboard.isMetaPressed,
      isTouch: isTouch,
      isLongTouch: isLongTouch,
      isDoubleClick: isDoubleClick,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    _focusNode.requestFocus();
    _lastWasTouch = event.kind == PointerDeviceKind.touch;
    final button = _pointerButton(event.buttons);
    final args = _pointerArgs(event, button: button);
    final control = button == 0
        ? _headerControlAt(args, event.localPosition)
        : null;
    _pointerPresses[event.pointer] = (
      button: button,
      time: DateTime.now().millisecondsSinceEpoch,
      location: _locationOf(args),
      control: control?.key,
    );
    // Header controls own their press and never start selection or dragging.
    if (control == null) widget.props.onMouseDown(args);
  }

  /// Shared by [Listener.onPointerMove] and [Listener.onPointerHover].
  ///
  /// Upstream has a single `onMouseMove` that fires for hover and drag alike
  /// (`data-grid.tsx:1337`), and it is what keeps `hoveredOnEdge` — and
  /// therefore the col-resize cursor — tracking the pointer while no button
  /// is down. Without the hover arm this port only updated the cursor during
  /// a drag, so the resize affordance never appeared on plain hover.
  void _handlePointerMove(PointerEvent event) {
    final p = widget.props;
    p.onPointerMoveRaw?.call(event.localPosition);
    final args = _pointerArgs(
      event,
      button:
          _pointerPresses[event.pointer]?.button ??
          (event.buttons == 0 ? 0 : _pointerButton(event.buttons)),
    );
    final isEdge = args is SemiGridOutOfBoundsMouseArgs && args.isEdge;

    final hoverInfo = args is SemiGridCellMouseArgs
        ? args.location
        : (args is SemiGridHeaderMouseArgs
              ? args.location
              : (args is SemiGridGroupHeaderMouseArgs ? args.location : null));

    final same = semiMouseArgsAreEqual(_hoveredArgs, args);
    _hoveredArgs = args;
    _pointer = event.localPosition;
    _pointerInside = true;
    _hoveredOnEdge = isEdge;
    if (!same) _updateHoveredItem(args);

    if (!same || hoverInfo != null) {
      p.onItemHovered(args);
      _updateCursor(args);
    }
    p.onMouseMove(args);
  }

  void _handlePointerUp(PointerUpEvent event) {
    final press = _pointerPresses.remove(event.pointer);
    if (press == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isTouch = event.kind == PointerDeviceKind.touch;
    final longTouch = isTouch && now - press.time > 500;
    final doubleClick =
        press.button == 0 &&
        press.control == null &&
        _lastUpTime != 0 &&
        now - _lastUpTime < (isTouch ? 1000 : 500);
    if (press.button == 0 && press.control == null) _lastUpTime = now;
    final args = _pointerArgs(
      event,
      button: press.button,
      isLongTouch: longTouch,
      isDoubleClick: doubleClick,
    );
    final control = press.button == 0
        ? _headerControlAt(args, event.localPosition)
        : null;
    if (press.control != null) {
      if (press.location == _locationOf(args) &&
          control?.key == press.control) {
        control?.activate();
      }
      return;
    }

    // Don’t turn a normal press that ended over a control into a click.
    // The editor still gets the release so it can finish an active drag.
    widget.props.onMouseUp(args, control != null);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    final press = _pointerPresses.remove(event.pointer);
    if (press != null && press.control == null) {
      widget.props.onMouseUp(_pointerArgs(event, button: press.button), true);
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    _pointerInside = false;
    _hoveredArgs = null;
    _updateHoveredItem(null);
    widget.props.onItemHovered(
      SemiGridOutOfBoundsMouseArgs(
        shiftKey: false,
        ctrlKey: false,
        metaKey: false,
        isTouch: _lastWasTouch,
        isEdge: false,
        button: 0,
        buttons: 0,
        scrollEdge: (0, 0),
        location: const SemiItem(0, 0),
        isMaybeScrollbar: false,
        region: (
          SemiOutOfBoundsRegionAxis.center,
          SemiOutOfBoundsRegionAxis.center,
        ),
      ),
    );
  }

  void _handleSecondaryTap(TapUpDetails details) {
    var prevented = false;
    final keyboard = HardwareKeyboard.instance;
    widget.props.onContextMenu(
      _getMouseArgsForPosition(
        details.localPosition.dx,
        details.localPosition.dy,
        button: 2,
        buttons: kSecondaryButton,
        shiftKey: keyboard.isShiftPressed,
        ctrlKey: keyboard.isControlPressed,
        metaKey: keyboard.isMetaPressed,
        isTouch: false,
      ),
      () => prevented = true,
    );
    if (!prevented) {
      // The platform context menu is left to the owner; nothing to do here.
    }
  }

  void _updateCursor(SemiGridMouseArgs args) {
    final p = widget.props;
    // `canDrag || isResizing ? "col-resize"` (`data-grid.tsx:977-980`), where
    // `canDrag = hoveredOnEdge` (`:973`). Both edge kinds count: this port's
    // [_hoveredOnEdge] is the out-of-bounds padding that `_detectResizeStart`
    // uses to resize the last column, and [_onHeaderResizeEdge] is upstream's.
    // The old `cell && allowResize` arm showed a resize cursor over every
    // cell the moment `allowResize` is wired, which upstream never does.
    final wantsResize =
        p.isResizing || _hoveredOnEdge || _onHeaderResizeEdge(args);
    if (wantsResize != _cursorIsPointer) {
      _cursorIsPointer = wantsResize;
      setState(() {});
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final p = widget.props;
    if (event is KeyDownEvent || event is KeyUpEvent) {
      final bounds = _currentBounds();
      var cancelCalled = false;
      var stopCalled = false;
      var preventCalled = false;
      final keyArgs = SemiGridKeyArgs(
        bounds: bounds,
        // DOM `KeyboardEvent.key` / `.keyCode`, so the `is-hotkey`
        // grammar in `semi_is_hotkey.dart` reads the same as upstream.
        key: semiDomKey(event.logicalKey),
        keyCode: semiDomKeyCode(event.logicalKey),
        altKey: HardwareKeyboard.instance.isAltPressed,
        shiftKey: HardwareKeyboard.instance.isShiftPressed,
        ctrlKey: HardwareKeyboard.instance.isControlPressed,
        metaKey: HardwareKeyboard.instance.isMetaPressed,
        cancel: () => cancelCalled = true,
        stopPropagation: () => stopCalled = true,
        preventDefault: () => preventCalled = true,
        location: _currentItem(),
        rawEvent: event,
      );
      if (event is KeyDownEvent) {
        p.onKeyDown(keyArgs);
      } else {
        p.onKeyUp?.call(keyArgs);
      }
      if (cancelCalled || stopCalled || preventCalled) {
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  SemiRectangle? _currentBounds() {
    final item = _currentItem();
    if (item == null) return null;
    return _getBoundsForItem(item.col, item.row);
  }

  SemiItem? _currentItem() {
    final current = widget.props.selection.current;
    if (current == null) return null;
    return SemiItem(current.range.x.toInt(), current.range.y.toInt());
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  /// The grid's theme: an explicit one wins, otherwise follow SemiTheme.
  SemiDataGridTheme get _resolvedTheme =>
      widget.props.theme ?? SemiDataGridTheme.fromSemiTheme(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) {
    final p = widget.props;
    final mapped = _mappedColumnsOf(p);
    _updateImageWindow(mapped);

    final arg = SemiDrawGridArg(
      width: p.width,
      height: p.height,
      headerHeight: p.headerHeight,
      groupHeaderHeight: p.groupHeaderHeight,
      enableGroups: p.enableGroups,
      cellXOffset: p.cellXOffset,
      cellYOffset: p.cellYOffset,
      translateX: p.translateX,
      translateY: p.translateY,
      mappedColumns: mapped,
      freezeColumns: p.freezeColumns,
      freezeTrailingRows: p.freezeTrailingRows,
      rows: p.rows,
      rowHeight: p.rowHeight,
      theme: _resolvedTheme,
      selection: p.selection,
      isFocused: p.isFocused,
      drawFocus: p.drawFocusRing,
      verticalBorder: p.verticalBorder,
      getCellContent: p.getCellContent,
      getCellRenderer: p.getCellRenderer,
      metrics: _metrics,
      getRowThemeOverride: p.getRowThemeOverride,
      getGroupDetails: p.getGroupDetails,
      hoverValues: _hoverValues,
      hoverInfo: _hoveredArgs is SemiGridCellMouseArgs
          ? (_hoveredArgs! as SemiGridCellMouseArgs).location
          : null,
      hoverPosition: _pointerInside ? _pointer : null,
      hasAppendRow: p.hasAppendRow,
      touchMode: p.touchMode,
      fillHandle: p.fillHandle,
      dragAndDropState: p.dragAndDropState,
      isResizing: p.isResizing,
      resizeColumn: p.resizeColumn,
      resizeIndicator: p.resizeIndicator,
      disabledRows: p.disabledRows ?? const SemiCompactSelection.empty(),
      prelightCells: p.prelightCells,
      highlightRegions: p.highlightRegions,
      drawHeaderCallback: p.drawHeader,
      drawCellCallback: p.drawCell,
      fixedShadowX: p.fixedShadowX,
      fixedShadowY: p.fixedShadowY,
      hyperWrapping: p.hyperWrapping,
      enqueue: p.enqueue ?? _enqueue,
      minimumCellWidth: p.minimumCellWidth,
      spriteManager: _spriteManager,
    );

    return Focus(
      focusNode: _focusNode,
      autofocus: false,
      onFocusChange: (focused) {
        if (focused) {
          p.onCanvasFocused();
        } else {
          p.onCanvasBlur();
        }
      },
      onKeyEvent: _handleKeyEvent,
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerHover: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onSecondaryTapUp: _handleSecondaryTap,
          child: MouseRegion(
            cursor: _cursorIsPointer
                ? SystemMouseCursors.resizeColumn
                : MouseCursor.defer,
            onExit: (_) => _handlePointerExit(PointerExitEvent()),
            child: SizedBox(
              width: p.width,
              height: p.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    key: _paintKey,
                    painter: SemiDataGridPainter(arg),
                    isComplex: true,
                    willChange: true,
                  ),
                  _accessibilityTree(p, mapped),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
