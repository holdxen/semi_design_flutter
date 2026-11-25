import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/semi_data_grid/internal/data_grid/render/semi_data_grid_painter.dart';

// Regression: writing resized widths back must rebuild the grid's columns.
// The grid compares `props.columns` by identity, so an in-place list mutation
// leaves rendered widths stale (only callbacks fire). The demo now replaces
// the list; this test proves that path actually repaints.
void main() {
  Widget buildHarness({
    required bool replaceList,
    required List<(int, double)> startLog,
    required List<double> resizeLog,
    SemiResizeIndicator resizeIndicator = SemiResizeIndicator.full,
    int freezeColumns = 0,
    SemiRowMarkerOptions? rowMarkers,
    SemiDataGridTheme? theme,
  }) {
    var columns = [
      SemiGridColumn(title: 'C0', width: 100),
      SemiGridColumn(title: 'C1', width: 100),
    ];
    return StatefulBuilder(
      builder: (context, setState) {
        return MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: SemiDataEditor(
                props: SemiDataEditorProps(
                  columns: columns,
                  rows: 200,
                  theme: theme ?? SemiDataGridTheme.light(),
                  freezeColumns: freezeColumns,
                  rowMarkers: rowMarkers,
                  resizeIndicator: resizeIndicator,
                  rowHeight: const SemiRowHeight.fixed(32),
                  headerHeight: 32,
                  onColumnResizeStart: (column, width, col, _) {
                    startLog.add((col, width));
                  },
                  onColumnResize: (column, newSize, col, _) {
                    resizeLog.add(newSize);
                    setState(() {
                      if (replaceList) {
                        columns = [
                          for (var i = 0; i < columns.length; i++)
                            i == col
                                ? column.copyWith(width: newSize)
                                : columns[i],
                        ];
                      } else {
                        columns[col] = column.copyWith(width: newSize);
                      }
                    });
                  },
                  getCellContent: (item, [_]) => SemiTextCell(
                    data: 'r${item.row}',
                    displayData: 'r${item.row}',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<(int, double)>> scenario(
    WidgetTester tester, {
    required bool replaceList,
  }) async {
    final startLog = <(int, double)>[];
    final resizeLog = <double>[];
    await tester.pumpWidget(
      buildHarness(
        replaceList: replaceList,
        startLog: startLog,
        resizeLog: resizeLog,
      ),
    );
    await tester.pumpAndSettle();

    // Column 0 right edge x=100, resize buffer starts at 95. Resize to x=170.
    final drag = await tester.startGesture(
      const Offset(97, 15),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await drag.moveTo(const Offset(170, 15));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();
    expect(resizeLog.last, 170);

    startLog.clear();
    // If the grid repainted with width 170, re-pressing near x=167 hits
    // column 0's edge and reports col=0, width~171. If stale (edge still 100),
    // x=167 lands inside column 1 -> no resize start fires.
    final drag2 = await tester.startGesture(
      const Offset(167, 15),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await drag2.up();
    await tester.pumpAndSettle();
    return List.of(startLog);
  }

  testWidgets('replacing the list repaints the resized column', (tester) async {
    final start = await scenario(tester, replaceList: true);
    expect(
      start,
      isNotEmpty,
      reason: 'new width should expose a resize edge at x~170',
    );
    expect(start.first.$1, 0);
  });

  for (final mode in SemiResizeIndicator.values) {
    testWidgets('paints the frozen-column resize indicator in $mode mode', (
      tester,
    ) async {
      const indicatorColor = Color(0xFFFF00AA);
      final gridPaint = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is SemiDataGridPainter,
      );
      PaintPattern indicator({Offset? from, Offset? to}) => paints
        ..something(
          (method, args) =>
              method == #drawLine &&
              (args[2] as Paint).color.toARGB32() == indicatorColor.toARGB32() &&
              (from == null || args[0] == from) &&
              (to == null || args[1] == to),
        );
      await tester.pumpWidget(
        buildHarness(
          replaceList: true,
          startLog: [],
          resizeLog: [],
          freezeColumns: 1,
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          resizeIndicator: mode,
          theme: const SemiThemeOverride(resizeIndicatorColor: indicatorColor)
              .applyTo(SemiDataGridTheme.light()),
        ),
      );
      await tester.pumpAndSettle();
      expect(gridPaint, isNot(indicator()));

      // The marker and the first data column are both frozen. The marker
      // shifts that column's edge from x=100 to x=140.
      final drag = await tester.startGesture(
        const Offset(137, 15),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      if (mode != SemiResizeIndicator.none) {
        expect(gridPaint, indicator(from: const Offset(140, 0)));
      }
      await drag.moveTo(const Offset(210, 15));
      await tester.pump();

      if (mode == SemiResizeIndicator.none) {
        expect(gridPaint, isNot(indicator()));
      } else {
        expect(
          gridPaint,
          indicator(from: const Offset(210, 0), to: const Offset(210, 33)),
        );
        expect(gridPaint, isNot(indicator(from: const Offset(140, 0))));
        final body = indicator(
          from: const Offset(210, 32),
          to: const Offset(210, 400),
        );
        expect(
          gridPaint,
          mode == SemiResizeIndicator.full ? body : isNot(body),
        );
      }

      // Both normal release and cancellation must remove the indicator.
      if (mode == SemiResizeIndicator.header) {
        await drag.cancel();
      } else {
        await drag.up();
      }
      await tester.pumpAndSettle();
      expect(gridPaint, isNot(indicator()));
    });
  }

  testWidgets('column drag paints a preview without committing the order', (
    tester,
  ) async {
    final headerX = <int, double>{};
    final cellX = <int, double>{};
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: SemiDataEditor(
              props: SemiDataEditorProps(
                columns: [
                  for (var i = 0; i < 3; i++)
                    SemiGridColumn(title: 'C$i', width: 100),
                ],
                rows: 2,
                rowHeight: const SemiRowHeight.fixed(32),
                headerHeight: 32,
                rowMarkers: const SemiRowMarkerOptions(width: 40),
                freezeColumns: 1,
                getCellContent: (item, [_]) => SemiTextCell(
                  data: 'C${item.col}',
                  displayData: 'C${item.col}',
                ),
                onColumnMoved: (from, to) => moves.add((from, to)),
                drawHeader: (args, draw) {
                  if (args.columnIndex >= 0) {
                    headerX[args.columnIndex] = args.rect.x;
                  }
                  draw();
                },
                drawCell: (args, draw) {
                  if (args.row == 0 && args.col >= 0) {
                    cellX[args.col] = args.rect.x;
                  }
                  draw();
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    const original = {0: 40.0, 1: 140.0, 2: 240.0};
    expect(headerX, original);
    expect(cellX, original);

    final drag = await tester.startGesture(
      const Offset(190, 15),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(headerX, original);
    await drag.moveTo(const Offset(290, 15));
    await tester.pump();
    const preview = {0: 40.0, 1: 240.0, 2: 140.0};
    expect(headerX, preview);
    expect(cellX, preview);
    expect(moves, isEmpty);

    await drag.up();
    await tester.pumpAndSettle();
    expect(moves, hasLength(1));
    // The caller did not write back a new columns list, so only the preview
    // was reordered. The next paint uses the original order again.
    expect(headerX, original);
    expect(cellX, original);
  });

  testWidgets('mutating the list in place leaves width stale', (tester) async {
    final start = await scenario(tester, replaceList: false);
    expect(
      start,
      isEmpty,
      reason: 'stale edge stays at x=100; x=167 is not an edge',
    );
  });
}
