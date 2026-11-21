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
    this.frameTime = 0,
    this.metrics,
    this.enqueue,
    this.minimumCellWidth = 10,
    this.onHeaderMenuClick,
    this.onHeaderIndicatorClick,
    this.imageLoader,
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

  /// `imageWindowLoader` (`data-grid.tsx`): when null the grid owns one and
  /// disposes it with itself.
  final GlideImageWindowLoader? imageLoader;

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
  final int frameTime;

  /// `TextMetrics` cache shared across the grid; when null a private one is
  /// created per paint.
  final GlideTextMetrics? metrics;
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

class _GlideDataGridState extends State<GlideDataGrid>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'GlideDataGrid');

  /// `AnimationManager` (`data-grid.tsx:415`, `:768-787`).
  final GlideAnimationManager _hoverAnimation = GlideAnimationManager();
  Map<GlideItem, double> _hoverValues = const {};
  late final Ticker _hoverTicker;
  Duration _lastHoverTick = Duration.zero;

  /// `imageWindowLoader` (`data-grid.tsx:157`).
  late GlideImageWindowLoader _imageLoader;
  bool _ownsImageLoader = false;
  Offset? _pointer;
  bool _pointerInside = false;
  GlideGridMouseArgs? _hoveredArgs;
  bool _hoveredOnEdge = false;
  bool _lastWasTouch = false;
  int _downTime = 0;
  int _lastUpTime = 0;
  bool _cursorIsPointer = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _hoverTicker = createTicker(_onHoverTick);
    _resolveImageLoader();
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
  }

  @override
  void dispose() {
    widget.controller?._state = null;
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

    final mapped = mapColumns(p.columns, p.freezeColumns);
    final totalHeaderHeight = p.enableGroups
        ? p.groupHeaderHeight + p.headerHeight
        : p.headerHeight;

    return computeBounds(
      col: col,
      row: row,
      width: p.width,
      height: p.height,
      groupHeaderHeight: p.groupHeaderHeight,
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

    final mapped = mapColumns(p.columns, p.freezeColumns);
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
    // `groupHeaderActionForEvent` on press (`data-grid.tsx:1105-1111`): the
    // action owns the click, so the editor never sees it.
    if (args is GlideGridGroupHeaderMouseArgs &&
        _groupHeaderAction(args) != null) {
      return;
    }
    p.onMouseDown(args);
  }

  void _handlePointerMove(PointerMoveEvent event) {
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

    p.onMouseUp(args, false);
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
    final wantsPointer = _hoveredOnEdge ||
        (args is GlideGridCellMouseArgs && p.allowResize == true);
    if (wantsPointer != _cursorIsPointer) {
      _cursorIsPointer = wantsPointer;
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
    final mapped = mapColumns(p.columns, p.freezeColumns);
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
      metrics: p.metrics ?? GlideTextMetrics(),
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
      frameTime: p.frameTime,
      hyperWrapping: p.hyperWrapping,
      enqueue: p.enqueue,
      minimumCellWidth: p.minimumCellWidth,
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
