import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

// Regression: writing resized widths back must rebuild the grid's columns.
// The grid compares `props.columns` by identity, so an in-place list mutation
// leaves rendered widths stale (only callbacks fire). The demo now replaces
// the list; this test proves that path actually repaints.
void main() {
  Widget buildHarness({
    required bool replaceList,
    required List<(int, double)> startLog,
    required List<double> resizeLog,
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
                  theme: SemiDataGridTheme.light(),
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

  testWidgets('mutating the list in place leaves width stale', (tester) async {
    final start = await scenario(tester, replaceList: false);
    expect(
      start,
      isEmpty,
      reason: 'stale edge stays at x=100; x=167 is not an edge',
    );
  });
}
