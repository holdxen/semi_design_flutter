import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Gallery page for the Glide Data Grid port.
///
/// The page drives [GlideDataGrid] directly (the `DataEditor` layer is the
/// next port) so selection, hover and cell rendering can be exercised on
/// their own.
class GlideDataGridPage extends StatefulWidget {
  const GlideDataGridPage({super.key});

  @override
  State<GlideDataGridPage> createState() => _GlideDataGridPageState();
}

class _GlideDataGridPageState extends State<GlideDataGridPage> {
  static const int _rows = 400;

  late final List<GlideGridColumn> _columns;
  late final List<List<GlideGridCell>> _cells;

  GlideGridSelection _selection = GlideGridSelection(
    current: const GlideGridSelectionCurrent(
      cell: GlideItem(0, 0),
      range: GlideRectangle(x: 0, y: 0, width: 1, height: 1),
    ),
  );

  int _cellXOffset = 0;
  int _cellYOffset = 0;
  double _translateX = 0;
  double _translateY = 0;

  final GlideRendererLookup _renderers = GlideDefaultRendererLookup();

  @override
  void initState() {
    super.initState();
    _columns = [
      for (var i = 0; i < 12; i++)
        GlideGridColumn(
          title: 'Column ${String.fromCharCode(65 + i)}',
          width: 120 + (i % 3) * 40,
          hasMenu: i == 0,
          group: i < 4 ? 'Group A' : (i < 8 ? 'Group B' : 'Group C'),
        ),
    ];

    _cells = [
      for (var row = 0; row < _rows; row++)
        [
          for (var col = 0; col < _columns.length; col++)
            _makeCell(col, row),
        ],
    ];
  }

  GlideGridCell _makeCell(int col, int row) {
    if (row % 25 == 24) {
      return const GlideLoadingCell(skeletonWidth: 80);
    }
    if (row % 25 == 23) {
      return const GlideProtectedCell();
    }
    if (col == 0) {
      return GlideTextCell(
        data: 'Row $row',
        displayData: 'Row $row',
        hoverEffect: true,
      );
    }
    if (col == 1) {
      return GlideNumberCell(
        data: row * 13.5,
        displayData: '${row * 13.5}',
        hoverEffect: true,
      );
    }
    if (col == 2) {
      return GlideBooleanCell(data: row.isEven
          ? GlideBooleanValue.checked
          : GlideBooleanValue.unchecked);
    }
    if (col == 3) {
      return const GlideBubbleCell(data: ['tag one', 'tag two']);
    }
    if (col == 4) {
      return GlideUriCell(
        data: 'https://example.com/$row',
        displayData: 'example.com/$row',
      );
    }
    if (col == 5) {
      return GlideMarkdownCell(data: '**bold** row $row');
    }
    return GlideTextCell(
      data: 'cell $col-$row',
      displayData: 'cell $col-$row',
      contentAlign: col.isEven ? GlideContentAlign.left : GlideContentAlign.right,
    );
  }

  void _onMouseDown(GlideGridMouseArgs args) {
    if (args is! GlideGridCellMouseArgs) return;
    final item = args.location;
    setState(() {
      _selection = GlideGridSelection(
        current: GlideGridSelectionCurrent(
          cell: item,
          range: GlideRectangle(
            x: item.col.toDouble(),
            y: item.row.toDouble(),
            width: 1,
            height: 1,
          ),
        ),
      );
    });
  }

  void _onVisibleRegionChanged(
    GlideRectangle region,
    double width,
    double height,
    double paddingRight,
    double translateX,
    double translateY,
  ) {
    setState(() {
      _cellXOffset = region.x.toInt();
      _cellYOffset = region.y.toInt();
      _translateX = translateX;
      _translateY = translateY;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = GlideTheme.light();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight.clamp(320.0, 720.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '当前选中：${_selection.current?.cell ?? '无'}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              child: _GlideGridHost(
                width: width,
                height: height,
                columns: _columns,
                rows: _rows,
                cells: _cells,
                selection: _selection,
                cellXOffset: _cellXOffset,
                cellYOffset: _cellYOffset,
                translateX: _translateX,
                translateY: _translateY,
                theme: theme,
                renderers: _renderers,
                onMouseDown: _onMouseDown,
                onVisibleRegionChanged: _onVisibleRegionChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Owns the visible-region bookkeeping so the grid can be rebuilt without
/// re-entering `setState` from inside a paint.
class _GlideGridHost extends StatefulWidget {
  const _GlideGridHost({
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    required this.cells,
    required this.selection,
    required this.cellXOffset,
    required this.cellYOffset,
    required this.translateX,
    required this.translateY,
    required this.theme,
    required this.renderers,
    required this.onMouseDown,
    required this.onVisibleRegionChanged,
  });

  final double width;
  final double height;
  final List<GlideGridColumn> columns;
  final int rows;
  final List<List<GlideGridCell>> cells;
  final GlideGridSelection selection;
  final int cellXOffset;
  final int cellYOffset;
  final double translateX;
  final double translateY;
  final GlideTheme theme;
  final GlideRendererLookup renderers;
  final void Function(GlideGridMouseArgs args) onMouseDown;
  final GlideOnVisibleRegionChanged onVisibleRegionChanged;

  @override
  State<_GlideGridHost> createState() => _GlideGridHostState();
}

class _GlideGridHostState extends State<_GlideGridHost> {
  static const double _rowHeight = 34;
  static const double _headerHeight = 38;

  /// The grid is cell-aligned (no `smoothScrollY`), so the wheel moves in
  /// whole rows and the sub-cell translate stays 0.
  double _scrollY = 0;

  double get _bodyHeight => widget.height - _headerHeight;

  double get _maxScrollY => math.max(
    0.0,
    widget.rows * _rowHeight - _bodyHeight,
  );

  void _handleSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final next = (_scrollY + event.scrollDelta.dy)
        .clamp(0.0, _maxScrollY)
        .toDouble();
    if (next == _scrollY) return;
    setState(() => _scrollY = next);

    final region = computeVisibleRegion(
      scrollX: 0,
      scrollY: _scrollY,
      clientWidth: widget.width,
      clientHeight: _bodyHeight,
      columns: mapColumns(widget.columns, 0),
      rowHeight: const GlideRowHeight.fixed(_rowHeight),
      rows: widget.rows,
      freezeColumns: 0,
    );
    widget.onVisibleRegionChanged(
      region.rect,
      widget.width,
      widget.height,
      0,
      region.translateX,
      region.translateY,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handleSignal,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: GlideDataGrid(
          props: GlideDataGridProps(
            width: widget.width,
            height: widget.height,
            columns: widget.columns,
            rows: widget.rows,
            rowHeight: const GlideRowHeight.fixed(_rowHeight),
            headerHeight: _headerHeight,
            getCellContent: (item, [forceStrict]) => widget.cells[item.row][item.col],
            getCellRenderer: widget.renderers.forCell,
            theme: widget.theme,
            verticalBorder: (_) => true,
            onItemHovered: (_) {},
            onMouseMove: (_) {},
            onMouseDown: widget.onMouseDown,
            onMouseUp: (_, _) {},
            onContextMenu: (_, _) {},
            onCanvasFocused: () {},
            onCanvasBlur: () {},
            onCellFocused: (_) {},
            onKeyDown: (_) {},
            cellXOffset: widget.cellXOffset,
            cellYOffset: widget.cellYOffset,
            translateX: widget.translateX,
            translateY: widget.translateY,
            selection: widget.selection,
            isFocused: true,
          ),
        ),
      ),
    );
  }
}
