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

  late final List<GlideGridColumn> _columns;
  late final List<List<GlideGridCell>> _cells;

  String _status = '点击单元格，第二次点击或回车进入编辑';

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
        [for (var col = 0; col < _columns.length; col++) _makeCell(col, row)],
    ];
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
      _status =
          '已提交 ${items.length} 个单元格，最后修改 [${first.col}, ${first.row}]';
    });
    return true;
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
          child: Text(_status, style: const TextStyle(fontSize: 13)),
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
                  theme: GlideTheme.light(),
                  rowHeight: const GlideRowHeight.fixed(34),
                  headerHeight: 38,
                  enableGroups: true,
                  groupHeaderHeight: 30,
                  verticalBorder: (_) => true,
                  onCellsEdited: _onCellsEdited,
                  onGridSelectionChange: _onSelectionChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
