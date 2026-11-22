import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Gallery page for the Glide Data Grid port.
///
/// The page drives [GlideDataEditor] — the whole stack: canvas, selection,
/// keyboard navigation, the overlay editor and clipboard.
class GlideDataGridPage extends StatefulWidget {
  const GlideDataGridPage({super.key});

  @override
  State<GlideDataGridPage> createState() => _GlideDataGridPageState();
}

class _GlideDataGridPageState extends State<GlideDataGridPage> {
  static const int _rows = 400;

  late List<GlideGridColumn> _columns;
  late final List<List<GlideGridCell>> _cells;

  /// Three groups of four columns; renamed through the group-header action.
  final List<String> _groupNames = ['Group A', 'Group B', 'Group C'];

  String _status = '点击单元格，第二次点击或回车进入编辑';

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _cells = [
      for (var row = 0; row < _rows; row++)
        [for (var col = 0; col < _columns.length; col++) _makeCell(col, row)],
    ];
  }

  /// Column 0 carries the disclosure button (and a type icon), column 1 an
  /// overlay badge, column 2 both a button and a post-title indicator so both
  /// header callbacks have something to hit.
  List<GlideGridColumn> _buildColumns() => [
    for (var i = 0; i < 12; i++)
      GlideGridColumn(
        title: 'Column ${String.fromCharCode(65 + i)}',
        width: 120 + (i % 3) * 40,
        hasMenu: i == 0 || i == 2,
        group: _groupNames[i ~/ 4],
        // `GridColumn.icon` / `overlayIcon` / `indicatorIcon`
        // (`data-grid-types.ts:151-154`), drawn as sprites by the editor's
        // merged built-in set (`data-editor-all.tsx:13-15`).
        icon: switch (i) {
          0 => 'headerString',
          1 => 'headerNumber',
          2 => 'headerBoolean',
          3 => 'headerArray',
          _ => null,
        },
        overlayIcon: i == 1 ? 'rowOwnerOverlay' : null,
        indicatorIcon: i == 2 ? 'headerDate' : null,
      ),
  ];

  void _renameGroup(String group, String value) {
    final index = _groupNames.indexOf(group);
    if (index < 0) return;
    setState(() {
      _groupNames[index] = value;
      _columns = _buildColumns();
      _status = '分组 $group 已重命名为 $value';
    });
  }

  GlideGridCell _makeCell(int col, int row) {
    if (row % 25 == 24) return const GlideLoadingCell(skeletonWidth: 80);
    if (row % 25 == 23) return const GlideProtectedCell();
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
      return GlideBooleanCell(
        data: row.isEven
            ? GlideBooleanValue.checked
            : GlideBooleanValue.unchecked,
      );
    }
    if (col == 3) return const GlideBubbleCell(data: ['tag one', 'tag two']);
    if (col == 4) {
      return GlideUriCell(
        data: 'https://example.com/$row',
        displayData: 'example.com/$row',
      );
    }
    if (col == 5) return GlideMarkdownCell(data: '**bold** row $row');
    return GlideTextCell(
      data: 'cell $col-$row',
      displayData: 'cell $col-$row',
      contentAlign: col.isEven
          ? GlideContentAlign.left
          : GlideContentAlign.right,
    );
  }

  bool _onCellsEdited(List<GlideEditListItem> items) {
    setState(() {
      for (final item in items) {
        final row = item.location.row;
        final col = item.location.col;
        if (row < _rows && col < _columns.length) {
          _cells[row][col] = item.value;
        }
      }
      final first = items.first.location;
      _status = '已提交 ${items.length} 个单元格，最后修改 [${first.col}, ${first.row}]';
    });
    return true;
  }

  /// `onHeaderMenuClick` (`data-editor.tsx:2569-2574`): the column arrives in
  /// user space — the row-marker offset has already been stripped.
  void _onHeaderMenuClick(int col, GlideRectangle bounds) {
    setState(
      () => _status =
          '点击了 ${String.fromCharCode(65 + col)} 列的菜单按钮'
          '（x=${bounds.x.toInt()}，${bounds.width.toInt()}px 宽）',
    );
  }

  /// `onHeaderIndicatorClick` (`data-editor.tsx:2576-2581`).
  void _onHeaderIndicatorClick(int col, GlideRectangle bounds) {
    setState(
      () => _status =
          '点击了 ${String.fromCharCode(65 + col)} 列的指示图标'
          '（x=${bounds.x.toInt()}，${bounds.width.toInt()}px 宽）',
    );
  }

  /// `drawCell` (`data-grid-types.ts:61-76`): runs the default paint first so
  /// the accent rail lands on top of the content.
  void _drawCell(GlideDrawCellArgs args, VoidCallback drawContent) {
    drawContent();
    if (args.col != 0) return;
    final rect = args.rect;
    args.canvas.drawRect(
      Rect.fromLTWH(rect.x, rect.y, 3, rect.height),
      Paint()..color = SemiTheme.of(context).colors.colorPrimary,
    );
  }

  void _onSelectionChanged(GlideGridSelection selection) {
    final cell = selection.current?.cell;
    setState(() {
      _status = cell == null
          ? '选区已清空'
          : '选中 [$cell]，范围 '
                '${selection.current!.range.width.toInt()}×'
                '${selection.current!.range.height.toInt()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _status,
            style: TextStyle(
              fontSize: 13,
              color: SemiTheme.of(context).colors.colorText1,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: GlideDataEditor(
                props: GlideDataEditorProps(
                  columns: _columns,
                  rows: _rows,
                  getCellContent: (item, [_]) => _cells[item.row][item.col],
                  // No explicit theme: the grid follows SemiTheme (including
                  // the light/dark switch in the demo shell).
                  rowHeight: const GlideRowHeight.fixed(34),
                  headerHeight: 38,
                  enableGroups: true,
                  groupHeaderHeight: 30,
                  verticalBorder: (_) => true,
                  // Freezing the first column draws the sticky boundary line
                  // at its right edge and gives `fixedShadowX` something to
                  // fade in over: the inset shadow only reaches full opacity
                  // once content scrolls underneath it, so scroll sideways to
                  // see it.
                  freezeColumns: 1,
                  rowMarkers: const GlideRowMarkerOptions(),
                  trailingRowOptions: const GlideTrailingRowOptions(
                    hint: 'New row',
                  ),
                  drawCell: _drawCell,
                  onGroupHeaderRenamed: _renameGroup,
                  onCellsEdited: _onCellsEdited,
                  onGridSelectionChange: _onSelectionChanged,
                  onHeaderMenuClick: _onHeaderMenuClick,
                  onHeaderIndicatorClick: _onHeaderIndicatorClick,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
