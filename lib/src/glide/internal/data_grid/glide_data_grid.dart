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

import '../../cells/glide_cell_types.dart';
import '../../common/glide_image_window_loader.dart';
import 'glide_sprite_manager.dart';
import 'glide_sprites.dart';
import '../../common/glide_utils.dart';
import '../../common/glide_math.dart';
import '../../common/glide_is_hotkey.dart';
import 'glide_animation_manager.dart';
import 'glide_event_args.dart';
import 'render/glide_data_grid_painter.dart';
import 'render/glide_draw_grid_arg.dart';

/// `DataGridProps` (`data-grid.tsx:63-312`), narrowed to what the Flutter
/// port draws and routes. Fields that only exist for DOM concerns are
/// documented where they would have appeared.
@immutable
class GlideDataGridProps {
  const GlideDataGridProps({
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    required this.rowHeight,
    required this.getCellContent,
    required this.getCellRenderer,
    required this.theme,
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
    this.resizeIndicator = GlideResizeIndicator.full,
    this.allowResize,
    this.resizeColumn,
    this.selection = GlideGridSelection.empty,
    this.disabledRows = const GlideCompactSelection.empty(),
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
  final GlideColumnDndState? dragAndDropState;
  final GlideResizeIndicator resizeIndicator;
  final bool isFocused;

  final List<GlideGridColumn> columns;
  final int rows;

  final double headerHeight;
  final double groupHeaderHeight;
  final bool enableGroups;
  final GlideRowHeight rowHeight;

  /// `getCellContent(cell, forceStrict?)` (`data-grid.tsx:114`); the second
  /// argument is only meaningful to `data-editor`'s strict mode.
  final GlideGridCell Function(GlideItem cell, [bool? forceStrict])
  getCellContent;
  final GlideGroupDetails Function(String group)? getGroupDetails;
  final GlideGetRowThemeOverride? getRowThemeOverride;

  final void Function(int col, GlideRectangle screenPosition)?
  onHeaderMenuClick;
  final void Function(int col, GlideRectangle screenPosition)?
  onHeaderIndicatorClick;

  /// `drawHeader` / `drawCell` (`data-grid.tsx:223,225`): take over the paint
  /// of a header or a cell. Indices are *mangled*; `GlideDataEditorProps`
  /// strips the row-marker column first.
  final GlideDrawHeaderCallback? drawHeader;
  final GlideDrawCellCallback? drawCell;

  /// `fixedShadowX` / `fixedShadowY` (`data-grid.tsx:84,89`): the soft inset
  /// shadow that fades in where the frozen columns (or the header) meet the
  /// scrolling content.
  final bool fixedShadowX;
  final bool fixedShadowY;

  /// `imageWindowLoader` (`data-grid.tsx`): when null the grid owns one and
  /// disposes it with itself.
  final GlideImageWindowLoader? imageLoader;

  /// `headerIcons` (`data-grid.tsx:282`): extra sprites keyed by name, merged
  /// over the built-in set by the editor the same way `DataEditorAll` does
  /// (`data-editor-all.tsx:13-15`). Null means "built-ins only".
  final Map<String, GlideSpriteFn>? headerIcons;

  /// `firstColAccessible` (`data-grid.tsx:1745`): false hides the row-marker
  /// column from the accessibility tree.
  final bool firstColAccessible;

  /// `experimental.disableAccessibilityTree` (`data-grid.tsx:1739`).
  final bool disableAccessibilityTree;

  /// Bumped by the owner whenever cell content changed outside of
  /// `onCellsEdited`, so the cached accessibility tree is rebuilt.
  final int a11yRevision;

  final GlideGridSelection selection;
  final List<GlideItem>? prelightCells;
  final List<GlideHighlight>? highlightRegions;
  final GlideFillHandleConfig? fillHandle;
  final GlideCompactSelection? disabledRows;

  final void Function(GlideGridMouseArgs args) onItemHovered;
  final void Function(GlideGridMouseArgs args) onMouseMove;

  /// Window-level `mousemove` (`data-grid.tsx`), used by column resizing
  /// which must keep tracking after the pointer leaves the header.
  final void Function(Offset position)? onPointerMoveRaw;
  final void Function(GlideGridMouseArgs args) onMouseDown;
  final void Function(GlideGridMouseArgs args, bool isOutside) onMouseUp;
  final void Function(GlideGridMouseArgs args, void Function() preventDefault)
  onContextMenu;

  final void Function() onCanvasFocused;
  final void Function() onCanvasBlur;
  final void Function(GlideItem args) onCellFocused;

  final void Function(GlideGridKeyArgs event) onKeyDown;
  final void Function(GlideGridKeyArgs event)? onKeyUp;

  final bool Function(int col) verticalBorder;
  final bool drawFocusRing;

  final GlideTheme theme;
  final GlideGetCellRenderer getCellRenderer;

  final bool smoothScrollX;
  final bool smoothScrollY;
  final bool hyperWrapping;
  final bool touchMode;

  /// `TextMetrics` cache shared across the grid; when null a private one is
  /// created per paint.
  final GlideTextMetrics? metrics;

  /// Overrides the built-in animation queue (`use-animation-queue.ts`).
  /// Upstream owns that internally; it is a prop here only so a caller can
  /// substitute its own damage scheduling. Null keeps the grid's own queue,
  /// which is what drives the `lastUpdated` flash to completion.
  final void Function(GlideItem item)? enqueue;
  final double minimumCellWidth;
}

/// `DataGridRef` (`data-grid.tsx:319-325`).
class GlideDataGridController extends ChangeNotifier {
  _GlideDataGridState? _state;

  /// `focus()` (`data-grid.tsx:320`).
  void focus() => _state?._focusNode.requestFocus();

  /// `getBounds(col, row)` (`data-grid.tsx:321`): canvas-local bounds, or
  /// null when the cell is off-screen.
  GlideRectangle? getBounds(int? col, int? row) =>
      _state?._getBoundsForItem(col ?? -1, row ?? -1);

  /// `damage(cells)` (`data-grid.tsx:322`): request a repaint of specific
  /// cells. Flutter repaints the whole painter, so this is a no-op kept for
  /// API parity.
  void damage(Iterable<GlideItem> cells) => notifyListeners();
}

class GlideDataGrid extends StatefulWidget {
  const GlideDataGrid({super.key, required this.props, this.controller});

  final GlideDataGridProps props;
  final GlideDataGridController? controller;

  @override
  State<GlideDataGrid> createState() => _GlideDataGridState();
}

/// `[columns, freezeColumns] -> mappedColumns`, mirroring the dependency
/// array of upstream's `useMemo` (`data-grid.tsx:432`).
class _MappedColumnsMemo {
  const _MappedColumnsMemo({
    this.columns,
    this.freezeColumns,
    this.mapped = const [],
  });

  final List<GlideGridColumn>? columns;
  final int? freezeColumns;
  final List<GlideMappedColumn> mapped;
}

class _GlideDataGridState extends State<GlideDataGrid>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'GlideDataGrid');

  /// `AnimationManager` (`data-grid.tsx:415`, `:768-787`).
  final GlideAnimationManager _hoverAnimation = GlideAnimationManager();
  Map<GlideItem, double> _hoverValues = const {};
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
  final GlobalKey _paintKey = GlobalKey(debugLabel: 'GlideDataGridPainter');

  void _enqueue(GlideItem item) {
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
  late GlideImageWindowLoader _imageLoader;
  bool _ownsImageLoader = false;

  /// `spriteManager` (`data-grid.tsx:427-433`): rebuilt when `headerIcons`
  /// changes, exactly as upstream's `useMemo(..., [headerIcons])`. Its
  /// `onSettled` is upstream's `lastDrawRef.current()` — repaint once every
  /// in-flight sprite has landed.
  late GlideSpriteManager _spriteManager;
  Offset? _pointer;
  bool _pointerInside = false;
  GlideGridMouseArgs? _hoveredArgs;
  bool _hoveredOnEdge = false;
  bool _lastWasTouch = false;
  int _downTime = 0;

  /// `downPosition` (`data-grid.tsx:1074`): where the press landed, so a
  /// release only counts as a header-menu click when it started on the same
  /// header row.
  GlideItem? _downPosition;

  /// The button [_downPosition] was recorded with. Upstream's `click` event
  /// only fires for the left button (`data-grid.tsx:1236` checks
  /// `args.button === 0`), but Flutter's `onPointerUp` fires for every button,
  /// so the press button has to be carried over from the down.
  int _downButton = 0;
  int _lastUpTime = 0;
  bool _cursorIsPointer = false;

  /// `useMemo(() => mapColumns(columns, freezeColumns), [columns,
  /// freezeColumns])` — the Web version derives the mapped list once per
  /// column change, but this port re-derived it on every call, so
  /// `mappedColumns` was a fresh list each build. That alone made
  /// [GlideDataGridPainter.shouldRepaint]'s identity check always fail, i.e.
  /// the painter repainted on every rebuild no matter what changed.
  ///
  /// Keyed the same way React's dependency array is: by reference. A caller
  /// that mutates its `columns` list in place and rebuilds without replacing
  /// it keeps the stale mapping, exactly as upstream does.
  _MappedColumnsMemo _mappedMemo = const _MappedColumnsMemo();

  /// `arg.metrics` used to be `p.metrics ?? GlideTextMetrics()`, allocating a
  /// cache per build. One shared instance keeps the text cache warm and lets
  /// the painter's equality check hold across rebuilds.
  GlideTextMetrics? _defaultMetrics;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _hoverTicker = createTicker(_onHoverTick);
    _resolveImageLoader();
    _resolveSpriteManager();
  }

  List<GlideMappedColumn> _mappedColumnsOf(GlideDataGridProps p) {
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

  GlideTextMetrics get _metrics =>
      widget.props.metrics ?? (_defaultMetrics ??= GlideTextMetrics());

  void _resolveSpriteManager() {
    _spriteManager = GlideSpriteManager(
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
      _imageLoader = GlideImageWindowLoader();
      _ownsImageLoader = true;
    }
    _imageLoader.onLoaded = (_) {
      if (mounted) setState(() {});
    };
  }

  @override
  void didUpdateWidget(GlideDataGrid oldWidget) {
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
  void _updateImageWindow(List<GlideMappedColumn> mapped) {
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
      GlideRectangle(
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
  void _updateHoveredItem(GlideGridMouseArgs? args) {
    GlideItem? item;
    if (args is GlideGridCellMouseArgs) {
      item = args.location;
    } else if (args is GlideGridHeaderMouseArgs) {
      item = args.location;
    } else if (args is GlideGridGroupHeaderMouseArgs) {
      item = args.location;
    }

    if (item == null || item.row < 0) {
      _hoverAnimation.setHovered(item);
    } else {
      final cell = widget.props.getCellContent(item, true);
      final renderer = widget.props.getCellRenderer(cell);
      final needsHover = renderer == null
          ? cell.kind == GlideCellKind.custom
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

  GlideRectangle? _getBoundsForItem(int col, int row) {
    final p = widget.props;
    if (col >= p.columns.length || row >= p.rows) return null;
    if (col < 0 && row != GlideItem.headerRow && row != GlideItem.groupHeaderRow) {
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

  /// `args.location` — the field lives on each [GlideGridMouseArgs] subclass
  /// rather than on the base type, so it has to be narrowed by kind first.
  GlideItem _locationOf(GlideGridMouseArgs args) => switch (args) {
    GlideGridCellMouseArgs a => a.location,
    GlideGridHeaderMouseArgs a => a.location,
    GlideGridGroupHeaderMouseArgs a => a.location,
    GlideGridOutOfBoundsMouseArgs a => a.location,
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
  bool _onHeaderResizeEdge(GlideGridMouseArgs args) =>
      args is GlideGridHeaderMouseArgs &&
      args.isEdge &&
      widget.props.allowResize == true &&
      args.location.col >= (widget.props.firstColAccessible ? 0 : 1);

  /// Whether ([x], [y]) lands on [col]'s header menu button or indicator icon.
  ///
  /// Upstream compares viewport coordinates against `getBoundsForItem`, which
  /// adds the canvas's `getBoundingClientRect()` offset; here both sides are
  /// grid-internal ([_getBoundsForItem] and `PointerEvent.localPosition`), so
  /// the comparison needs no offset.
  ({bool menu, GlideRectangle bounds})? _isOverHeaderElement(
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

    final headerBounds = _getBoundsForItem(col, GlideItem.headerRow);
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
      theme: p.theme,
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

  GlideGridMouseArgs _getMouseArgsForPosition(
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
            ? GlideOutOfBoundsRegionAxis.endPadding.value
            : GlideOutOfBoundsRegionAxis.center.value;
      }
      if (y <= p.height && y >= 0) {
        innerVertical = row == null
            ? GlideOutOfBoundsRegionAxis.endPadding.value
            : GlideOutOfBoundsRegionAxis.center.value;
      }

      var isEdge = false;
      if (col == -1 && row == GlideItem.headerRow) {
        isEdge = edge(p.columns.length - 1, GlideItem.headerRow);
      } else if (row != null) {
        isEdge = edge(col < 0 ? p.columns.length - 1 : col, row);
      }

      // Clicking the scrollbar must not clear the selection; upstream detects
      // this by checking whether the point is past the content extent.
      if (!isEdge) isMaybeScrollbar = scrollEdge.$1 != 0 || scrollEdge.$2 != 0;

      return GlideGridOutOfBoundsMouseArgs(
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
        location: GlideItem(
          col < 0 ? p.columns.length - 1 : col,
          row ?? (y < totalHeaderHeight ? GlideItem.headerRow : p.rows - 1),
        ),
        isMaybeScrollbar: isMaybeScrollbar,
        region: (
          GlideOutOfBoundsRegionAxis.values.firstWhere(
            (e) => e.value == innerHorizontal,
          ),
          GlideOutOfBoundsRegionAxis.values.firstWhere(
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
        location: GlideItem(targetCol, row),
        bounds: bounds,
        group: group,
        localEventX: x - bounds.x,
        localEventY: y - bounds.y,
      );

      if (row == GlideItem.groupHeaderRow) {
        return GlideGridGroupHeaderMouseArgs(
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
      return GlideGridHeaderMouseArgs(
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

    return GlideGridCellMouseArgs(
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
      location: GlideItem(col, row),
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
    final centerX = fillBounds.x +
        fillBounds.width +
        config.offsetX -
        half +
        0.5;
    final centerY = fillBounds.y +
        fillBounds.height +
        config.offsetY -
        half +
        0.5;
    return (centerX - posX).abs() < config.size &&
        (centerY - posY).abs() < config.size;
  }

  // -------------------------------------------------------------------------
  // Pointer wiring (`onPointerDown/Move/Up`, `data-grid.tsx:1076-1375`)
  // -------------------------------------------------------------------------

  /// `getRowData` (`data-grid.tsx:330-336`).
  String _accessibilityLabel(GlideGridCell cell) {
    if (cell is GlideCustomCell) return cell.copyData ?? '';
    return widget.props.getCellRenderer(cell)?.getAccessibilityString(cell) ??
        '';
  }

  /// The `td`'s `onClick` (`data-grid.tsx:1818-1835`): focusing a cell from
  /// the accessibility tree selects it first (the editor's `onCellFocused`,
  /// `data-editor.tsx:4124-4145`) and then activates it with Enter.
  void _accessibilityActivate(int col, int row) {
    final p = widget.props;
    final item = GlideItem(col, row);
    p.onCellFocused(item);
    p.onKeyDown(
      GlideGridKeyArgs(
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
  /// [GlideDataGridProps.a11yRevision] exists so the owner can force one.
  Widget? _accessibilityTreeCache;
  ({Object? key})? _accessibilityTreeKey;

  /// The `<table role="grid">` (`data-grid.tsx:1737-1856`), limited to the
  /// visible columns and rows exactly like the upstream virtualized tree.
  Widget _accessibilityTree(
    GlideDataGridProps p,
    List<GlideMappedColumn> effectiveCols,
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
      Object.hashAll([
        for (final c in effectiveCols) c.sourceIndex,
      ]),
    );
    final cached = _accessibilityTreeCache;
    if (cached != null && _accessibilityTreeKey?.key == key) return cached;
    _accessibilityTreeKey = (key: key);
    final built = _buildAccessibilityTree(p, effectiveCols);
    _accessibilityTreeCache = built;
    return built;
  }

  Widget _buildAccessibilityTree(
    GlideDataGridProps p,
    List<GlideMappedColumn> effectiveCols,
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
                          GlideItem.headerRow,
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
    GlideDataGridProps p,
    int col,
    int row,
    GlideRectangle? range,
    GlideItem? focused,
  ) {
    final cell = p.getCellContent(GlideItem(col, row), true);
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
      readOnly: glideIsInnerOnlyCell(cell) || !glideIsReadWriteCell(cell),
      focused: focused != null && focused.col == col && focused.row == row,
      onTap: () => _accessibilityActivate(col, row),
      child: const SizedBox(width: 1, height: 1),
    );
  }

  /// `groupHeaderActionForEvent` (`data-grid.tsx:1004-1020`).
  ///
  /// Upstream compares `localEventY + box.y`, which only ever lands inside the
  /// top 26px of the header; the bounds-relative form is used here instead.
  GlideGroupAction? _groupHeaderAction(GlideGridGroupHeaderMouseArgs args) {
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
      if (hit) return actions[i];
    }
    return null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final p = widget.props;
    _focusNode.requestFocus();
    _lastWasTouch = event.kind == PointerDeviceKind.touch;
    _downTime = DateTime.now().millisecondsSinceEpoch;
    final args = _getMouseArgsForPosition(
      event.localPosition.dx,
      event.localPosition.dy,
      button: event.buttons == kPrimaryButton ? 0 : 1,
      buttons: event.buttons,
      shiftKey: false,
      ctrlKey: false,
      metaKey: false,
      isTouch: _lastWasTouch,
    );
    // `downPosition.current = args.location` (`data-grid.tsx:1092`), recorded
    // before the group-header check exactly as upstream does.
    _downPosition = _locationOf(args);
    _downButton = event.buttons == kPrimaryButton ? 0 : 1;
    // `groupHeaderActionForEvent` on press (`data-grid.tsx:1105-1111`): the
    // action owns the click, so the editor never sees it.
    if (args is GlideGridGroupHeaderMouseArgs &&
        _groupHeaderAction(args) != null) {
      return;
    }
    p.onMouseDown(args);
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
    final args = _getMouseArgsForPosition(
      event.localPosition.dx,
      event.localPosition.dy,
      button: 0,
      buttons: event.buttons,
      shiftKey: event.kind == PointerDeviceKind.touch ? false : false,
      ctrlKey: false,
      metaKey: false,
      isTouch: event.kind == PointerDeviceKind.touch,
    );
    final isEdge = args is GlideGridOutOfBoundsMouseArgs && args.isEdge;

    final hoverInfo = args is GlideGridCellMouseArgs
        ? args.location
        : (args is GlideGridHeaderMouseArgs
              ? args.location
              : (args is GlideGridGroupHeaderMouseArgs
                    ? args.location
                    : null));

    final same = glideMouseArgsAreEqual(_hoveredArgs, args);
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
    final p = widget.props;
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastUpTime = _lastUpTime;
    _lastUpTime = now;

    final isTouch = _lastWasTouch;
    var isLongTouch = false;
    var isDoubleClick = false;

    // `data-grid.tsx:1154-1166`: a held touch longer than 500ms is a long
    // touch, and a second release inside the window is a double click. The
    // flags are computed before the args so every `kind` gets them.
    if (isTouch && _downTime != 0 && now - _downTime > 500) {
      isLongTouch = true;
    }
    if (lastUpTime != 0 && now - lastUpTime < (isTouch ? 1000 : 500)) {
      isDoubleClick = true;
    }

    final args = _getMouseArgsForPosition(
      event.localPosition.dx,
      event.localPosition.dy,
      button: 0,
      buttons: 0,
      shiftKey: false,
      ctrlKey: false,
      metaKey: false,
      isTouch: isTouch,
      isLongTouch: isLongTouch,
      isDoubleClick: isDoubleClick,
    );

    // `groupHeaderActionForEvent` on release (`data-grid.tsx:1184-1192`).
    if (args is GlideGridGroupHeaderMouseArgs) {
      final action = _groupHeaderAction(args);
      if (action != null) {
        if (args.button == 0) action.onClick(args.bounds);
        return;
      }
    }

    // Fired before `onMouseUp` on purpose. Upstream clears its drag state in
    // `onMouseUpImpl` *before* forwarding to the editor's handler
    // (`data-grid-dnd.tsx:256`), so firing afterwards would find both drag
    // guards already reset and open a menu on top of a just-dropped column.
    // Upstream's two `click` listeners also register child-first, which puts
    // this menu ahead of `onHeaderClicked` — the same order.
    _maybeFireHeaderElementClick(args, event.localPosition);

    p.onMouseUp(args, false);
  }

  /// `onClickImpl` (`data-grid.tsx:1227-1246`): a release over the header's
  /// menu button or indicator icon fires the matching callback.
  ///
  /// Upstream runs this from a `click` listener, which fires after `pointerup`
  /// and only for the left button; the press must also have started on the
  /// same header row (`downPosition.current?.[1] === -1`). Both gates are
  /// reproduced here with [_downButton] and [_downPosition].
  void _maybeFireHeaderElementClick(GlideGridMouseArgs args, Offset at) {
    if (args is! GlideGridHeaderMouseArgs) return;
    if (_downButton != 0) return;
    final down = _downPosition;
    if (down == null) return;
    if (down.col != args.location.col ||
        down.row != GlideItem.headerRow) {
      return;
    }

    final hit = _isOverHeaderElement(
      args.location.col,
      at.dx,
      at.dy,
      _onHeaderResizeEdge(args),
    );
    if (hit == null) return;
    if (hit.menu) {
      widget.props.onHeaderMenuClick?.call(args.location.col, hit.bounds);
    } else {
      widget.props.onHeaderIndicatorClick?.call(args.location.col, hit.bounds);
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    _pointerInside = false;
    _hoveredArgs = null;
    _updateHoveredItem(null);
    widget.props.onItemHovered(
      GlideGridOutOfBoundsMouseArgs(
        shiftKey: false,
        ctrlKey: false,
        metaKey: false,
        isTouch: _lastWasTouch,
        isEdge: false,
        button: 0,
        buttons: 0,
        scrollEdge: (0, 0),
        location: const GlideItem(0, 0),
        isMaybeScrollbar: false,
        region: (
          GlideOutOfBoundsRegionAxis.center,
          GlideOutOfBoundsRegionAxis.center,
        ),
      ),
    );
  }

  void _handleSecondaryTap(TapUpDetails details) {
    var prevented = false;
    widget.props.onContextMenu(
      _getMouseArgsForPosition(
        details.localPosition.dx,
        details.localPosition.dy,
        button: 2,
        buttons: kSecondaryButton,
        shiftKey: false,
        ctrlKey: false,
        metaKey: false,
        isTouch: false,
      ),
      () => prevented = true,
    );
    if (!prevented) {
      // The platform context menu is left to the owner; nothing to do here.
    }
  }

  void _updateCursor(GlideGridMouseArgs args) {
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
      final keyArgs = GlideGridKeyArgs(
        bounds: bounds,
        // DOM `KeyboardEvent.key` / `.keyCode`, so the `is-hotkey`
        // grammar in `glide_is_hotkey.dart` reads the same as upstream.
        key: glideDomKey(event.logicalKey),
        keyCode: glideDomKeyCode(event.logicalKey),
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

  GlideRectangle? _currentBounds() {
    final item = _currentItem();
    if (item == null) return null;
    return _getBoundsForItem(item.col, item.row);
  }

  GlideItem? _currentItem() {
    final current = widget.props.selection.current;
    if (current == null) return null;
    return GlideItem(current.range.x.toInt(), current.range.y.toInt());
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final p = widget.props;
    final mapped = _mappedColumnsOf(p);
    _updateImageWindow(mapped);

    final arg = GlideDrawGridArg(
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
      theme: p.theme,
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
      hoverInfo: _hoveredArgs is GlideGridCellMouseArgs
          ? (_hoveredArgs! as GlideGridCellMouseArgs).location
          : null,
      hoverPosition: _pointerInside ? _pointer : null,
      hasAppendRow: p.hasAppendRow,
      touchMode: p.touchMode,
      fillHandle: p.fillHandle,
      disabledRows: p.disabledRows ?? const GlideCompactSelection.empty(),
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
                    painter: GlideDataGridPainter(arg),
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
