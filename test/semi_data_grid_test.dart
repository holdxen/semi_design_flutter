import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/semi_data_grid/internal/data_grid/render/semi_data_grid_painter.dart';
import 'package:semi_design_flutter/src/semi_data_grid/internal/data_grid/render/semi_draw_grid_arg.dart';

double _oddHeight(int row) => row.isEven ? 32.0 : 33.0;

/// A 10x10 red square, used to stand in for a decoded network image.
Future<ui.Image> _fakeImage() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 10, 10),
    Paint()..color = const Color(0xFFFF0000),
  );
  return recorder.endRecording().toImage(10, 10);
}

// ---------------------------------------------------------------------------
// Selection (`internal/data-grid/semi_selection.dart`)
// ---------------------------------------------------------------------------

/// Records every `draw` and the `frameTime` it was given, so a test can tell
/// a live clock (`data-grid-render.cells.ts:113`) from the constant `0` this
/// port used to ship.
class FrameCountingRenderer extends SemiCellRenderer {
  FrameCountingRenderer(this.frameTimes);

  final List<int> frameTimes;

  @override
  SemiCellKind get kind => SemiCellKind.text;

  @override
  void draw(SemiDrawCellArgs args) => frameTimes.add(args.frameTime);
}

/// Stable tear-offs for the repaint fixture: `SemiDrawGridArg` compares
/// function props by identity, so a closure created per build would force a
/// repaint and hide the very thing under test.
SemiGridCell _stableContent(SemiItem item, [bool? getSticky]) =>
    const SemiTextCell(data: '', displayData: '');

bool _stableBorder(int col) => true;

Widget _standaloneGrid({
  required SemiGridCell Function(SemiItem, [bool?]) content,
  required SemiGetCellRenderer renderer,
  SemiDataGridController? controller,
  SemiDrawCellCallback? drawCell,
  SemiImageWindowLoader? imageLoader,
  int a11yRevision = 0,
  int rows = 10,
  int cellYOffset = 0,
  int freezeTrailingRows = 0,
}) => Directionality(
  textDirection: TextDirection.ltr,
  child: SizedBox(
    width: 400,
    height: 300,
    child: SemiDataGrid(
      controller: controller,
      props: SemiDataGridProps(
        width: 400,
        height: 300,
        columns: const [
          SemiGridColumn(title: 'C0', width: 100),
          SemiGridColumn(title: 'C1', width: 100),
          SemiGridColumn(title: 'C2', width: 100),
          SemiGridColumn(title: 'C3', width: 100),
        ],
        rows: rows,
        rowHeight: const SemiRowHeight.fixed(30),
        headerHeight: 30,
        cellYOffset: cellYOffset,
        freezeTrailingRows: freezeTrailingRows,
        getCellContent: content,
        getCellRenderer: renderer,
        drawCell: drawCell,
        imageLoader: imageLoader,
        a11yRevision: a11yRevision,
        theme: SemiDataGridTheme.light(),
        verticalBorder: _stableBorder,
        onItemHovered: (_) {},
        onMouseMove: (_) {},
        onMouseDown: (_) {},
        onMouseUp: (_, _) {},
        onContextMenu: (_, _) {},
        onCanvasFocused: () {},
        onCanvasBlur: () {},
        onCellFocused: (_) {},
        onKeyDown: (_) {},
        isFocused: true,
      ),
    ),
  ),
);

/// Top-level so `const SemiRowHeight.variable(...)` is a constant: local
/// function tear-offs are not.
double _shortRowHeight(int row) => 24;
double _tallRowHeight(int row) => 48;

class FakeClipboard extends SemiClipboard {
  String? writtenPlain;
  String? writtenHtml;
  String? nextText;
  String? nextHtml;

  @override
  Future<String?> readText() async => nextText;

  @override
  Future<String?> readHtml() async => nextHtml;

  @override
  Future<void> write({
    required String textPlain,
    required String textHtml,
  }) async {
    writtenPlain = textPlain;
    writtenHtml = textHtml;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SemiCompactSelection', () {
    test('add merges overlapping slices', () {
      var sel = const SemiCompactSelection.empty();
      sel = sel.add(3);
      sel = sel.add(SemiSlice(4, 7));
      expect(sel.toArray(), [3, 4, 5, 6]);
      expect(sel.length, 4);
      expect(sel.firstIndex, 3);
      expect(sel.lastIndex, 6);
    });

    test('remove subtracts a range', () {
      final sel = SemiCompactSelection.fromArray([0, 1, 2, 3, 4])
          .remove(SemiSlice(1, 4));
      expect(sel.toArray(), [0, 4]);
      expect(sel.hasIndex(2), isFalse);
      expect(sel.hasIndex(4), isTrue);
    });

    test('hasAll and some', () {
      final sel = SemiCompactSelection.fromArray([2, 3, 9]);
      expect(sel.hasAll(const SemiSlice(2, 4)), isTrue);
      expect(sel.hasAll(const SemiSlice(2, 5)), isFalse);
      expect(sel.some((i) => i > 5), isTrue);
      expect(sel.some((i) => i > 99), isFalse);
    });

    test('offset shifts every slice', () {
      final sel = SemiCompactSelection.fromArray([0, 1]).offset(10);
      expect(sel.toArray(), [10, 11]);
    });
  });

  // -------------------------------------------------------------------------
  // Visible region (`internal/scrolling-data-grid/scrolling-data-grid.tsx`)
  // -------------------------------------------------------------------------

  group('computeVisibleRegion', () {
    final columns = [
      for (var i = 0; i < 10; i++)
        SemiMappedColumn(
          sourceIndex: i,
          sticky: false,
          title: 'C$i',
          width: 100,
        ),
    ];

    test('starts at the origin', () {
      final region = computeVisibleRegion(
        scrollX: 0,
        scrollY: 0,
        clientWidth: 500,
        clientHeight: 340,
        columns: columns,
        rowHeight: const SemiRowHeight.fixed(34),
        rows: 100,
        freezeColumns: 0,
      );
      expect(region.x, 0);
      expect(region.y, 0);
      expect(region.width, 5);
      expect(region.height, 10);
      expect(region.translateX, 0);
      expect(region.translateY, 0);
    });

    test('advances cell offsets with the scroll position', () {
      final region = computeVisibleRegion(
        scrollX: 0,
        scrollY: 340,
        clientWidth: 500,
        clientHeight: 340,
        columns: columns,
        rowHeight: const SemiRowHeight.fixed(34),
        rows: 100,
        freezeColumns: 0,
      );
      expect(region.y, 10);
      expect(region.height, 10);
      expect(region.translateY, 0);
    });

    test('smooth scrolling produces a sub-cell translate', () {
      final region = computeVisibleRegion(
        scrollX: 0,
        scrollY: 17,
        clientWidth: 500,
        clientHeight: 340,
        columns: columns,
        rowHeight: const SemiRowHeight.fixed(34),
        rows: 100,
        freezeColumns: 0,
        smoothScrollY: true,
      );
      expect(region.y, 0);
      expect(region.translateY, -17);
    });

    test('horizontal scrolling with frozen columns keeps the sticky pane', () {
      final frozen = [
        SemiMappedColumn(
          sourceIndex: 0,
          sticky: true,
          title: 'Frozen',
          width: 100,
        ),
        for (var i = 1; i < 10; i++)
          SemiMappedColumn(
            sourceIndex: i,
            sticky: false,
            title: 'C$i',
            width: 100,
          ),
      ];
      final region = computeVisibleRegion(
        scrollX: 250,
        scrollY: 0,
        clientWidth: 500,
        clientHeight: 340,
        columns: frozen,
        rowHeight: const SemiRowHeight.fixed(34),
        rows: 100,
        freezeColumns: 1,
      );
      // Cell-aligned scrolling snaps past the partially visible column, so
      // the offset lands on the first fully visible non-frozen column.
      expect(region.x, 4);
      expect(region.translateX, 0);
    });
  });

  // -------------------------------------------------------------------------
  // Widget (`internal/data-grid/data-grid.tsx`)
  // -------------------------------------------------------------------------

  group('SemiDataGrid', () {
    late List<SemiGridColumn> columns;
    late List<List<SemiGridCell>> cells;
    late List<SemiItem> locationLog;

    Widget buildGrid({
      bool groups = false,
      SemiDrawCellCallback? drawCell,
      SemiGetCellRenderer? getCellRenderer,
    }) {
      locationLog = [];
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: SemiDataGrid(
            props: SemiDataGridProps(
              width: 400,
              height: 300,
              columns: columns,
              rows: 10,
              rowHeight: const SemiRowHeight.fixed(30),
              headerHeight: 30,
              enableGroups: groups,
              getCellContent: (item, [_]) => cells[item.row][item.col],
              getCellRenderer:
                  getCellRenderer ?? SemiDefaultRendererLookup().forCell,
              drawCell: drawCell,
              theme: SemiDataGridTheme.light(),
              verticalBorder: (_) => true,
              onItemHovered: (_) {},
              onMouseMove: (_) {},
              onMouseDown: (args) {
                if (args is SemiGridCellMouseArgs) {
                  locationLog.add(args.location);
                } else if (args is SemiGridHeaderMouseArgs) {
                  locationLog.add(args.location);
                }
              },
              onMouseUp: (_, _) {},
              onContextMenu: (_, _) {},
              onCanvasFocused: () {},
              onCanvasBlur: () {},
              onCellFocused: (_) {},
              onKeyDown: (_) {},
              isFocused: true,
            ),
          ),
        ),
      );
    }

    /// A grid whose cells all carry [lastUpdated], with the paint clock and
    /// the animation queue exposed so a test can observe both.
    Widget flashingGrid({
      required int? lastUpdated,
      required List<int> frameTimes,
      void Function(SemiItem item)? enqueue,
    }) {
      final renderer = FrameCountingRenderer(frameTimes);
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: SemiDataGrid(
            props: SemiDataGridProps(
              width: 400,
              height: 300,
              columns: [
                for (var i = 0; i < 4; i++)
                  SemiGridColumn(title: 'C$i', width: 100),
              ],
              rows: 10,
              rowHeight: const SemiRowHeight.fixed(30),
              headerHeight: 30,
              getCellContent: (item, [_]) => SemiTextCell(
                data: 'r${item.row} c${item.col}',
                displayData: 'r${item.row} c${item.col}',
                lastUpdated: lastUpdated,
              ),
              getCellRenderer: (cell) => renderer,
              theme: SemiDataGridTheme.light(),
              verticalBorder: (_) => true,
              onItemHovered: (_) {},
              onMouseMove: (_) {},
              onMouseDown: (_) {},
              onMouseUp: (_, _) {},
              onContextMenu: (_, _) {},
              onCanvasFocused: () {},
              onCanvasBlur: () {},
              onCellFocused: (_) {},
              onKeyDown: (_) {},
              isFocused: true,
              enqueue: enqueue,
            ),
          ),
        ),
      );
    }

    setUp(() {
      columns = [
        for (var i = 0; i < 4; i++) SemiGridColumn(title: 'C$i', width: 100),
      ];
      cells = [
        for (var row = 0; row < 10; row++)
          [
            for (var col = 0; col < 4; col++)
              SemiTextCell(data: 'r$row c$col', displayData: 'r$row c$col'),
          ],
      ];
    });

    testWidgets('a running lastUpdated flash asks for the next frame', (
      tester,
    ) async {
      final frameTimes = <int>[];
      final enqueued = <SemiItem>[];
      final now = DateTime.now().millisecondsSinceEpoch;

      await tester.pumpWidget(
        flashingGrid(
          lastUpdated: now,
          frameTimes: frameTimes,
          enqueue: enqueued.add,
        ),
      );
      await tester.pump();

      expect(frameTimes, isNotEmpty);
      // `performance.now()` per paint (`data-grid-render.cells.ts:113`),
      // not the constant `0` this port used to pass in.
      expect((frameTimes.last - now).abs(), lessThan(5000));
      // `if (needsAnim || animationFrameRequested) enqueue?.(...)`
      // (`data-grid-render.cells.ts:561`).
      expect(enqueued, isNotEmpty);
    });

    testWidgets('a finished lastUpdated flash stops asking for frames', (
      tester,
    ) async {
      final frameTimes = <int>[];
      final enqueued = <SemiItem>[];

      await tester.pumpWidget(
        flashingGrid(
          lastUpdated: DateTime.now().millisecondsSinceEpoch - 60_000,
          frameTimes: frameTimes,
          enqueue: enqueued.add,
        ),
      );
      await tester.pump();

      // The cell still paints, but past `lastUpdateAnimationMs` there is
      // nothing left to animate, so it must not keep the queue busy.
      expect(frameTimes, isNotEmpty);
      expect(enqueued, isEmpty);
    });

    testWidgets('the grid drives repaints itself when no enqueue is given', (
      tester,
    ) async {
      final frameTimes = <int>[];

      await tester.pumpWidget(
        flashingGrid(
          lastUpdated: DateTime.now().millisecondsSinceEpoch,
          frameTimes: frameTimes,
        ),
      );
      await tester.pump();
      final afterFirstFrame = frameTimes.length;
      expect(afterFirstFrame, greaterThan(0));

      // Without the built-in queue (`use-animation-queue.ts`) nothing would
      // mark the painter dirty, so the flash would freeze on frame one.
      await tester.pump();
      await tester.pump();
      expect(frameTimes.length, greaterThan(afterFirstFrame));
    });

    testWidgets('drawCell can take over a cell and skip the default paint', (
      tester,
    ) async {
      final seen = <SemiItem>[];
      final draws = <int>[];

      // A consumer that never calls `drawContent` owns the paint entirely
      // (`data-grid-render.cells.ts:545-547`).
      await tester.pumpWidget(
        buildGrid(
          drawCell: (args, draw) => seen.add(SemiItem(args.col, args.row)),
          getCellRenderer: (cell) => FrameCountingRenderer(draws),
        ),
      );
      await tester.pumpAndSettle();

      expect(seen, isNotEmpty);
      expect(
        draws,
        isEmpty,
        reason: 'skipping drawContent must skip the renderer too',
      );
    });

    testWidgets('drawContent runs the default renderer paint', (tester) async {
      final seen = <SemiItem>[];
      final draws = <int>[];

      await tester.pumpWidget(
        buildGrid(
          drawCell: (args, draw) {
            seen.add(SemiItem(args.col, args.row));
            draw();
          },
          getCellRenderer: (cell) => FrameCountingRenderer(draws),
        ),
      );
      await tester.pumpAndSettle();

      expect(seen, isNotEmpty);
      // Marker/new-row cells are inner-only and paint through the `else`
      // branch, so the renderer is called at least as often as the consumer.
      expect(draws.length, greaterThanOrEqualTo(seen.length));
    });

    testWidgets('paints headers and cells', (tester) async {
      await tester.pumpWidget(buildGrid());
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);

      // Every cell has a renderer in the default lookup.
      final lookup = SemiDefaultRendererLookup();
      expect(lookup.forCell(cells[0][0]), isA<SemiTextCellRenderer>());
      expect(
        lookup.forCell(const SemiBooleanCell(data: SemiBooleanValue.checked)),
        isA<SemiBooleanCellRenderer>(),
      );
      expect(
        lookup.forCell(const SemiNumberCell(data: 1, displayData: '1')),
        isA<SemiNumberCellRenderer>(),
      );
      expect(
        lookup.forCell(const SemiBubbleCell(data: ['a'])),
        isA<SemiBubbleCellRenderer>(),
      );
      expect(
        lookup.forCell(const SemiLoadingCell()),
        isA<SemiLoadingCellRenderer>(),
      );
      expect(
        lookup.forCell(const SemiProtectedCell()),
        isA<SemiProtectedCellRenderer>(),
      );
      expect(
        lookup.forCell(
          const SemiMarkerCell(
            row: 0,
            drawHandle: false,
            checked: SemiBooleanValue.empty,
            checkboxStyle: SemiMarkerCheckboxStyle.square,
            markerKind: SemiMarkerKind.checkbox,
          ),
        ),
        isA<SemiMarkerCellRenderer>(),
      );
      expect(
        lookup.forCell(const SemiNewRowCell(hint: 'Add row')),
        isA<SemiNewRowCellRenderer>(),
      );
    });

    testWidgets('tapping a cell reports its location', (tester) async {
      await tester.pumpWidget(buildGrid());

      // Row 0 occupies y in [30, 60); column 1 occupies x in [100, 200).
      final gesture = await tester.startGesture(const Offset(150, 45));
      await gesture.up();
      await tester.pump();

      expect(locationLog, hasLength(1));
      expect(locationLog.single, const SemiItem(1, 0));
    });

    testWidgets('tapping the header reports the header row', (tester) async {
      await tester.pumpWidget(buildGrid());

      final gesture = await tester.startGesture(const Offset(150, 15));
      await gesture.up();
      await tester.pump();

      expect(locationLog, hasLength(1));
      expect(locationLog.single.row, SemiItem.headerRow);
      expect(locationLog.single.col, 1);
    });
  });

  // -------------------------------------------------------------------------
  // Cell renderers (`cells/*.tsx`)
  // -------------------------------------------------------------------------

  group('cell renderers', () {
    test('boolean toggle follows data-editor-fns', () {
      expect(
        toggleBoolean(SemiBooleanValue.checked),
        SemiBooleanValue.unchecked,
      );
      expect(
        toggleBoolean(SemiBooleanValue.unchecked),
        SemiBooleanValue.checked,
      );
      expect(toggleBoolean(SemiBooleanValue.empty), SemiBooleanValue.checked);
      expect(
        toggleBoolean(SemiBooleanValue.indeterminate),
        SemiBooleanValue.checked,
      );
    });

    test('text renderer measures wrapped and single-line widths', () {
      const renderer = SemiTextCellRenderer();
      final theme = SemiDataGridTheme.light();
      final metrics = SemiTextMetrics();

      const single = SemiTextCell(data: 'hello', displayData: 'hello');
      const wrapped = SemiTextCell(
        data: 'hello\nhi',
        displayData: 'hello\nhi',
        allowWrapping: true,
      );

      // A wrapping cell measures its widest line; a non-wrapping one only
      // ever measures the first line (`text-cell.tsx:24-31`).
      final singleWidth = renderer.measure(single, theme, metrics)!;
      final wrappedWidth = renderer.measure(wrapped, theme, metrics)!;
      expect(wrappedWidth, singleWidth);

      const clipped = SemiTextCell(
        data: 'hi\nhello',
        displayData: 'hi\nhello',
      );
      expect(renderer.measure(clipped, theme, metrics)!, lessThan(singleWidth));
      expect(singleWidth, greaterThan(theme.cellHorizontalPadding * 2));
    });

    test('boolean renderer always measures 50', () {
      const renderer = SemiBooleanCellRenderer();
      final width = renderer.measure(
        const SemiBooleanCell(data: SemiBooleanValue.checked),
        SemiDataGridTheme.light(),
        SemiTextMetrics(),
      );
      expect(width, 50);
    });
  });

  // -------------------------------------------------------------------------
  // Clipboard (`data-editor/copy-paste.ts`, `data-editor-fns.ts`)
  // -------------------------------------------------------------------------

  group('copy-paste', () {
    List<List<SemiGridCell>> sample() => [
      [
        const SemiTextCell(data: 'a\tb', displayData: 'a\tb'),
        const SemiNumberCell(data: 12.5, displayData: '12.5'),
        const SemiBooleanCell(data: SemiBooleanValue.checked),
        const SemiBooleanCell(data: SemiBooleanValue.indeterminate),
        const SemiBubbleCell(data: ['x', 'y']),
        const SemiUriCell(data: 'https://a.b/c', displayData: 'a.b/c'),
      ],
      [
        const SemiTextCell(data: 'say "hi"', displayData: 'say "hi"'),
        const SemiNumberCell(data: -3, displayData: '-3'),
        const SemiBooleanCell(data: SemiBooleanValue.unchecked),
        const SemiBooleanCell(data: SemiBooleanValue.empty),
        const SemiTextCell(data: 'p,q', displayData: 'p,q'),
        const SemiLoadingCell(),
      ],
    ];

    test('text buffer escapes tabs, quotes and commas', () {
      final contents = semiGetCopyBufferContents(sample(), const []);
      final lines = contents.textPlain.split('\n');
      expect(lines, hasLength(2));
      expect(lines[0], '"a\tb"\t12.5\tTRUE\tINDETERMINATE\tx,y\thttps://a.b/c');
      // A plain text cell is only escaped for tabs/newlines/quotes; commas
      // are escaped solely inside string-array cells (`copy-paste.ts:130`).
      expect(lines[1], '"say ""hi"""\t-3\tFALSE\t\tp,q\t#LOADING');
    });

    test('unquote round trips the text buffer', () {
      final contents = semiGetCopyBufferContents(sample(), const []);
      final parsed = semiUnquote(contents.textPlain);
      expect(parsed, hasLength(2));
      final first = parsed[0].cast<SemiBasicCellBuffer>();
      expect(first[0].formatted, 'a\tb');
      expect(first[1].formatted, '12.5');
      expect(first[2].formatted, 'TRUE');
      expect(first[4].formatted, 'x,y');

      final second = parsed[1].cast<SemiBasicCellBuffer>();
      expect(second[0].formatted, 'say "hi"');
      expect(second[4].formatted, 'p,q');
    });

    test('html buffer round trips through decodeHtml', () {
      final contents = semiGetCopyBufferContents(sample(), const []);
      final decoded = semiDecodeHtml(contents.textHtml);
      expect(decoded, isNotNull);
      expect(decoded, hasLength(2));

      final first = decoded![0].cast<SemiCellBuffer>();
      // Tabs become four spaces on the way to HTML so Sheets and Excel
      // keep them (`copy-paste.ts:155-162`).
      expect((first[0] as SemiBasicCellBuffer).formatted, 'a    b');
      expect((first[1] as SemiBasicCellBuffer).formatted, '12.5');
      expect((first[4] as SemiStringArrayCellBuffer).formatted, ['x', 'y']);
      expect((first[5] as SemiBasicCellBuffer).rawValue, 'https://a.b/c');

      final second = decoded[1].cast<SemiCellBuffer>();
      expect((second[0] as SemiBasicCellBuffer).formatted, 'say "hi"');
    });

    test('copyData bypasses escaping', () {
      final cell = const SemiTextCell(
        data: 'raw,\tvalue',
        displayData: 'ignored',
        copyData: 'raw,\tvalue',
      );
      final buffer = semiCreateBufferFromGridCells([
        [cell],
      ], const []);
      final basic = buffer[0][0] as SemiBasicCellBuffer;
      expect(basic.doNotEscape, isTrue);
      expect(semiCreateTextBuffer(buffer), 'raw,\tvalue');
    });
  });

  // -------------------------------------------------------------------------
  // Keybinds (`data-editor/data-editor-keybindings.ts`, `common/is-hotkey.ts`)
  // -------------------------------------------------------------------------

  group('keybindings', () {
    SemiGridKeyArgs key(
      String key,
      int keyCode, {
      bool alt = false,
      bool shift = false,
      bool ctrl = false,
      bool meta = false,
    }) => SemiGridKeyArgs(
      bounds: null,
      key: key,
      keyCode: keyCode,
      altKey: alt,
      shiftKey: shift,
      ctrlKey: ctrl,
      metaKey: meta,
      cancel: () {},
      stopPropagation: () {},
      preventDefault: () {},
      location: null,
    );

    test('defaults realize to the documented expressions', () {
      final keys = semiKeysWithDefaults(null);
      expect(keys.goDownCell, 'ArrowDown');
      expect(keys.goLeftCell, 'ArrowLeft|shift+Tab');
      expect(keys.goRightCell, 'ArrowRight|Tab');
      expect(keys.selectAll, 'primary+a');
      expect(keys.selectRow, 'shift+ ');
      expect(keys.selectColumn, 'ctrl+ ');
      expect(keys.downFill, '');
      expect(keys.search, '');
      expect(keys.copy, isTrue);
      expect(keys.paste, isTrue);
    });

    test('custom and disabled binds override the default', () {
      final keys = semiKeysWithDefaults(
        const SemiKeybinds(goDownCell: false, search: 'primary+k'),
      );
      expect(keys.goDownCell, '');
      expect(keys.search, 'primary+k');
      expect(keys.goUpCell, 'ArrowUp');
    });

    test('back-compat aliases fill in missing bindings', () {
      final keys = semiKeysWithDefaults(const SemiKeybinds(pageDown: true));
      expect(keys.goToNextPage, 'PageDown');
      expect(keys.goToPreviousPage, 'PageUp');
    });

    test('isHotkey matches modifiers, alternatives and key codes', () {
      final down = key('ArrowDown', 40);
      expect(semiIsHotkey('ArrowDown', down), isTrue);
      expect(semiIsHotkey('ArrowUp|ArrowDown', down), isTrue);
      expect(semiIsHotkey('ArrowUp', down), isFalse);
      expect(semiIsHotkey('alt+ArrowDown', down), isFalse);
      expect(
        semiIsHotkey('alt+ArrowDown', key('ArrowDown', 40, alt: true)),
        isTrue,
      );
      // `any+Escape` ignores modifiers entirely.
      expect(
        semiIsHotkey('any+Escape', key('Escape', 27, ctrl: true, alt: true)),
        isTrue,
      );
      // `_68` is the legacy key code for `d`.
      // `primary` still demands Ctrl (or Cmd on macOS) to be held.
      expect(semiIsHotkey('primary+_68', key('d', 68)), isFalse);
      expect(semiIsHotkey('primary+_68', key('d', 68, ctrl: true)), isTrue);
      expect(semiIsHotkey('primary+_68', key('d', 68, shift: true)), isFalse);
      // Single lower-case letters compare against the upper-case key code.
      expect(semiIsHotkey('primary+a', key('a', 65, ctrl: true)), isTrue);
      expect(semiIsHotkey('primary+a', key('a', 65)), isFalse);
      // Space is a literal space in the grammar.
      expect(semiIsHotkey('shift+ ', key(' ', 32, shift: true)), isTrue);
      expect(semiIsHotkey('ctrl+ ', key(' ', 32, ctrl: true)), isTrue);
      expect(semiIsHotkey('ctrl+ ', key(' ', 32, shift: true)), isFalse);
      // Empty expressions never match.
      expect(semiIsHotkey('', down), isFalse);
    });

    test('DOM key and key code translation', () {
      expect(semiDomKey(LogicalKeyboardKey.arrowDown), 'ArrowDown');
      expect(semiDomKeyCode(LogicalKeyboardKey.arrowDown), 40);
      expect(semiDomKey(LogicalKeyboardKey.enter), 'Enter');
      expect(semiDomKeyCode(LogicalKeyboardKey.enter), 13);
      expect(semiDomKey(LogicalKeyboardKey.space), ' ');
      expect(semiDomKeyCode(LogicalKeyboardKey.keyD), 68);
      expect(semiDomKey(LogicalKeyboardKey.keyD), 'd');
      expect(semiDomKeyCode(LogicalKeyboardKey.digit5), 53);
    });
  });

  // -------------------------------------------------------------------------
  // Selection behavior (`internal/data-grid/use-selection-behavior.ts`,
  // `data-editor.tsx:1838`)
  // -------------------------------------------------------------------------

  group('selection behavior', () {
    SemiDataEditorSelection editor({
      SemiSelectionBlending range = SemiSelectionBlending.exclusive,
      SemiSelectionBlending column = SemiSelectionBlending.exclusive,
      SemiRangeSelect rangeSelect = SemiRangeSelect.multiRect,
      bool columnSelectEnabled = true,
    }) => SemiDataEditorSelection(
      behaviorConfig: SemiBehaviorConfig(
        rangeBehavior: range,
        columnBehavior: column,
        rangeSelect: rangeSelect,
        columnSelectEnabled: columnSelectEnabled,
      ),
      rows: 100,
      rowSelectMulti: true,
      columnSelectMulti: true,
    );

    SemiGridMouseArgs cellClick(int col, int row, {bool shift = false}) =>
        SemiGridCellMouseArgs(
          shiftKey: shift,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
          isEdge: false,
          button: 0,
          buttons: 1,
          scrollEdge: (0, 0),
          location: SemiItem(col, row),
          bounds: SemiRectangle(
            x: col.toDouble(),
            y: row.toDouble(),
            width: 1,
            height: 1,
          ),
          isFillHandle: false,
          localEventX: 10,
          localEventY: 10,
        );

    SemiGridMouseArgs headerClick(int col, {bool shift = false}) =>
        SemiGridHeaderMouseArgs(
          shiftKey: shift,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
          isEdge: false,
          button: 0,
          buttons: 1,
          scrollEdge: (0, 0),
          location: SemiItem(col, SemiItem.headerRow),
          bounds: SemiRectangle(
            x: col.toDouble(),
            y: 0,
            width: 100,
            height: 30,
          ),
          group: '',
          localEventX: 10,
          localEventY: 10,
        );

    const noopCell = SemiTextCell(data: '', displayData: '');

    SemiSelectOutcome select(
      SemiDataEditorSelection state,
      SemiGridMouseArgs args,
    ) => state.handleSelect(
      args,
      getCellRenderer: (_) => null,
      getCellContent: (_) => noopCell,
      themeForCell: (_, _) => SemiDataGridTheme.light(),
    );

    test('clicking a cell moves the current range', () {
      final state = editor();
      select(state, cellClick(3, 7));
      expect(state.selection.current!.cell, const SemiItem(3, 7));
      expect(state.selection.current!.range.width, 1);
      expect(state.selection.current!.range.height, 1);
      expect(state.selection.rows.length, 0);
      expect(state.selection.columns.length, 0);
    });

    test('shift-clicking grows the range from the anchor', () {
      final state = editor();
      select(state, cellClick(3, 7));
      select(state, cellClick(6, 5, shift: true));
      final range = state.selection.current!.range;
      expect(range.x, 3);
      expect(range.y, 5);
      expect(range.width, 4);
      expect(range.height, 3);
      // The anchor cell does not move on a shift-click.
      expect(state.selection.current!.cell, const SemiItem(3, 7));
    });

    test('a header click selects exactly one column', () {
      final state = editor();
      select(state, headerClick(2));
      expect(state.selection.columns.toArray(), [2]);
      expect(state.selection.current, isNull);
    });

    test('a second header click without modifiers replaces the selection', () {
      final state = editor();
      select(state, headerClick(2));
      select(state, headerClick(5));
      expect(state.selection.columns.toArray(), [5]);
    });

    test('shift-clicking the header selects a column slice', () {
      final state = editor();
      select(state, headerClick(2));
      select(state, headerClick(5, shift: true));
      expect(state.selection.columns.toArray(), [2, 3, 4, 5]);
      expect(state.lastSelectedCol, 2);
    });

    test('clicking off the grid clears the selection', () {
      final state = editor();
      select(state, cellClick(3, 7));
      final outcome = select(
        state,
        SemiGridOutOfBoundsMouseArgs(
          shiftKey: false,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
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
      expect(state.selection.current, isNull);
      expect(outcome.onSelectionCleared, isTrue);
      expect(outcome.clearOverlay, isTrue);
    });

    test('clicking the scrollbar keeps the selection', () {
      final state = editor();
      select(state, cellClick(3, 7));
      select(
        state,
        SemiGridOutOfBoundsMouseArgs(
          shiftKey: false,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
          isEdge: false,
          button: 0,
          buttons: 0,
          scrollEdge: (1, 0),
          location: const SemiItem(0, 0),
          isMaybeScrollbar: true,
          region: (
            SemiOutOfBoundsRegionAxis.center,
            SemiOutOfBoundsRegionAxis.center,
          ),
        ),
      );
      expect(state.selection.current!.cell, const SemiItem(3, 7));
    });

    test('rangeSelect cell collapses every range to 1x1', () {
      final state = editor(rangeSelect: SemiRangeSelect.cell);
      select(state, cellClick(3, 7));
      select(state, cellClick(6, 5, shift: true));
      // `rangeSelect: cell` forces the range onto the anchor, so a
      // shift-click cannot grow it (`use-selection-behavior.ts:33-43`).
      final range = state.selection.current!.range;
      expect(range.width, 1);
      expect(range.height, 1);
      expect(range.x, 3);
      expect(range.y, 7);
      expect(state.selection.current!.cell, const SemiItem(3, 7));
    });

    test('exclusive column behavior drops the current range', () {
      final state = editor();
      select(state, cellClick(3, 7));
      expect(state.selection.current, isNotNull);
      select(state, headerClick(2));
      expect(state.selection.current, isNull);
      expect(state.selection.columns.toArray(), [2]);
    });
  });

  // -------------------------------------------------------------------------
  // Keyboard (`data-editor.tsx:2854-3482`)
  // -------------------------------------------------------------------------

  group('key handler', () {
    late List<SemiEditListItem> edits;
    late List<SemiScrollTarget> scrolls;

    SemiKeyHandler handler({
      SemiRangeSelect rangeSelect = SemiRangeSelect.multiRect,
      int columnCount = 10,
      int rows = 50,
      SemiGridSelection? initial,
      SemiGetCellsForSelection? getCellsForSelection,
      SemiDeleteCallback? onDelete,
      bool scrollToActiveCell = true,
      void Function(SemiItem location, SemiCellActivation activation)?
      onCellActivated,
    }) {
      edits = [];
      scrolls = [];
      return SemiKeyHandler(
        keys: semiKeysWithDefaults(null),
        selection:
            initial ??
            const SemiGridSelection(
              current: SemiGridSelectionCurrent(
                cell: SemiItem(2, 3),
                range: SemiRectangle(x: 2, y: 3, width: 1, height: 1),
              ),
            ),
        setGridSelection: (newVal, expand) {},
        columnCount: columnCount,
        rows: rows,
        rowMarkerOffset: 0,
        overlayOpen: false,
        columnSelect: SemiSelectMode.multi,
        rowSelect: SemiSelectMode.multi,
        rangeSelect: rangeSelect,
        visibleRegion: const SemiRectangle(x: 0, y: 0, width: 8, height: 20),
        getCellContent: (item) =>
            SemiTextCell(data: 'v${item.col}-${item.row}', displayData: 'x'),
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        getCellsForSelection: getCellsForSelection,
        scrollToActiveCell: scrollToActiveCell,
        onCellsEdited: (items) => edits.addAll(items),
        scrollTo: (target) => scrolls.add(target),
        onCellActivated: onCellActivated,
        onDelete: onDelete,
      );
    }

    SemiGridKeyArgs key(
      String key,
      int keyCode, {
      bool alt = false,
      bool shift = false,
      bool ctrl = false,
      bool meta = false,
      SemiRectangle? bounds,
    }) => SemiGridKeyArgs(
      bounds: bounds,
      key: key,
      keyCode: keyCode,
      altKey: alt,
      shiftKey: shift,
      ctrlKey: ctrl,
      metaKey: meta,
      cancel: () {},
      stopPropagation: () {},
      preventDefault: () {},
      location: null,
    );

    test('arrow keys move the current cell', () {
      final h = handler();
      expect(h.handleFixedKeybindings(key('ArrowDown', 40)), isTrue);
      expect(h.selection.current!.cell, const SemiItem(2, 4));

      h.handleFixedKeybindings(key('ArrowRight', 39));
      expect(h.selection.current!.cell, const SemiItem(3, 4));

      h.handleFixedKeybindings(key('ArrowUp', 38));
      h.handleFixedKeybindings(key('ArrowLeft', 37));
      expect(h.selection.current!.cell, const SemiItem(2, 3));
    });

    test('navigation clamps to the table bounds', () {
      final h = handler(
        columnCount: 4,
        rows: 5,
        initial: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(3, 4),
            range: SemiRectangle(x: 3, y: 4, width: 1, height: 1),
          ),
        ),
      );
      h.handleFixedKeybindings(key('ArrowDown', 40));
      expect(h.selection.current!.cell, const SemiItem(3, 4));

      h.handleFixedKeybindings(key('Home', 36));
      expect(h.selection.current!.cell.col, 0);
    });

    test('shift+arrow grows the range instead of moving the cell', () {
      final h = handler();
      h.handleFixedKeybindings(key('ArrowDown', 40, shift: true));
      final range = h.selection.current!.range;
      expect(h.selection.current!.cell, const SemiItem(2, 3));
      expect(range.height, 2);
      expect(scrolls.last.axis, SemiScrollAxis.vertical);
    });

    test('scrollToActiveCell false keeps the viewport put', () {
      // A plain arrow moves the cell, so it reaches the `scrollTo` at the
      // end of `updateSelectedCell` (`data-editor.tsx:3066-3068`).
      final still = handler(scrollToActiveCell: false);
      still.handleFixedKeybindings(key('ArrowDown', 40));
      expect(still.selection.current!.cell, const SemiItem(2, 4));
      expect(scrolls, isEmpty);

      // The default still follows the selection.
      final follows = handler();
      follows.handleFixedKeybindings(key('ArrowDown', 40));
      expect(follows.selection.current!.cell, const SemiItem(2, 4));
      expect(scrolls, isNotEmpty);
      expect(scrolls.last.row, 4);
    });

    test('escape clears the selection', () {
      final h = handler();
      expect(h.handleFixedKeybindings(key('Escape', 27, ctrl: true)), isTrue);
      expect(h.selection.current, isNull);
      expect(h.selection.columns.length, 0);
    });

    test('ctrl+a selects the whole table', () {
      final h = handler(columnCount: 7, rows: 11);
      expect(h.handleFixedKeybindings(key('a', 65, ctrl: true)), isTrue);
      final range = h.selection.current!.range;
      expect(range.x, 0);
      expect(range.y, 0);
      expect(range.width, 7);
      expect(range.height, 11);
      expect(h.selection.current!.cell, const SemiItem(2, 3));
    });

    test('page keys jump by the visible height minus four', () {
      final h = handler();
      h.handleFixedKeybindings(key('PageDown', 34));
      expect(h.selection.current!.cell.row, 3 + 16);
      h.handleFixedKeybindings(key('PageUp', 33));
      expect(h.selection.current!.cell.row, 3);
    });

    test('alt+arrow moves without collapsing the selection', () {
      final h = handler();
      // Grow a range first so the old range lands on the stack.
      h.handleFixedKeybindings(key('ArrowDown', 40, shift: true));
      final stackSize = h.selection.current!.rangeStack.length;

      h.handleFixedKeybindings(key('ArrowDown', 40, alt: true));
      expect(h.selection.current!.cell.row, 4);
      expect(h.selection.current!.range.height, 1);
      expect(h.selection.current!.rangeStack.length, stackSize + 1);
    });

    test('ctrl+space selects a column (exclusive blending)', () {
      final h = handler(columnCount: 10);
      expect(h.handleFixedKeybindings(key(' ', 32, ctrl: true)), isTrue);
      expect(h.selection.columns.toArray(), [2]);
      // `columnBehavior: exclusive` drops `current`, and a missing current
      // range short-circuits the handler — matching `data-editor.tsx:3272`.
      expect(h.selection.current, isNull);
      expect(h.handleFixedKeybindings(key(' ', 32, ctrl: true)), isFalse);
      expect(h.selection.columns.toArray(), [2]);
    });

    test('delete walks the renderer onDelete over the range', () {
      var called = 0;
      final h = handler(
        initial: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(1, 1),
            range: SemiRectangle(x: 1, y: 1, width: 2, height: 2),
          ),
        ),
        onDelete: (selection) {
          called++;
          return true;
        },
      );
      expect(h.handleFixedKeybindings(key('Delete', 46)), isTrue);
      expect(called, 1);
      expect(edits, hasLength(4));
      expect(edits.map((e) => e.location).toSet(), {
        const SemiItem(1, 1),
        const SemiItem(2, 1),
        const SemiItem(1, 2),
        const SemiItem(2, 2),
      });
    });

    test('delete can be aborted by the owner', () {
      final h = handler(onDelete: (_) => false);
      expect(h.handleFixedKeybindings(key('Delete', 46)), isTrue);
      expect(edits, isEmpty);
    });

    test('a printable key activates the editor', () {
      String? activated;
      final h = handler(
        onCellActivated: (location, activation) {
          final key = activation is SemiKeyboardCellActivation
              ? activation.key
              : null;
          activated = '$location:$key';
        },
      );
      expect(
        h.handleKeyDown(
          key(
            'x',
            88,
            bounds: const SemiRectangle(x: 2, y: 3, width: 1, height: 1),
          ),
          editOnType: true,
        ),
        isTrue,
      );
      expect(activated, '[2, 3]:x');
    });

    test('goToLastCell clamps into the table', () {
      final h = handler(columnCount: 4, rows: 6);
      h.handleFixedKeybindings(key('End', 35, ctrl: true));
      expect(h.selection.current!.cell, const SemiItem(3, 5));
    });

    test('adjustSelection grows to the table edge', () {
      final h = handler(columnCount: 6, rows: 9);
      h.handleFixedKeybindings(key('ArrowDown', 68 + 0, shift: true));
      h.handleFixedKeybindings(key('ArrowDown', 40, shift: true));
      var range = h.selection.current!.range;
      expect(range.height, 3);

      // primary+shift+ArrowDown → selectToLastRow ([0, 2]).
      h.handleFixedKeybindings(key('ArrowDown', 40, shift: true, ctrl: true));
      range = h.selection.current!.range;
      expect(range.y, 3);
      expect(range.height, 9 - 3);
    });

    test('expandSelection grows the range across spans', () {
      final spanning = const SemiTextCell(
        data: 'wide',
        displayData: 'wide',
        span: (start: 0, end: 3),
      );
      final selection = const SemiGridSelection(
        current: SemiGridSelectionCurrent(
          cell: SemiItem(1, 0),
          range: SemiRectangle(x: 1, y: 0, width: 1, height: 1),
        ),
      );
      final expanded = semiExpandSelection(
        newVal: selection,
        getCellsForSelection: (region) => [
          [if (region.x.toInt() <= 1 && 1 < region.x + region.width) spanning],
        ],
        rowMarkerOffset: 0,
        allowPartial: false,
      );
      expect(expanded.current!.range.x, 0);
      expect(expanded.current!.range.width, 4);
    });

    test('expandSelection leaves the selection alone for an async sample', () {
      const selection = SemiGridSelection(
        current: SemiGridSelectionCurrent(
          cell: SemiItem(1, 0),
          range: SemiRectangle(x: 1, y: 0, width: 1, height: 1),
        ),
      );
      final expanded = semiExpandSelection(
        newVal: selection,
        // A thunk has no synchronous answer; upstream returns the input
        // instead of blocking (`data-editor-fns.ts:31-33`).
        getCellsForSelection: (region) async => <List<SemiGridCell>>[
          [
            const SemiTextCell(
              data: 'wide',
              displayData: 'wide',
              span: (start: 0, end: 3),
            ),
          ],
        ],
        rowMarkerOffset: 0,
        allowPartial: false,
      );
      expect(identical(expanded, selection), isTrue);
    });

    test('shiftSelection moves columns for the public API', () {
      const selection = SemiGridSelection(
        current: SemiGridSelectionCurrent(
          cell: SemiItem(2, 5),
          range: SemiRectangle(x: 2, y: 5, width: 3, height: 1),
        ),
        columns: SemiCompactSelection.empty(),
      );
      final shifted = semiShiftSelection(selection, -1);
      expect(shifted.current!.cell, const SemiItem(1, 5));
      expect(shifted.current!.range.x, 1);
    });

    test('getSpanStops reports every spanned column', () {
      final stops = semiGetSpanStops([
        [
          const SemiTextCell(
            data: 'a',
            displayData: 'a',
            span: (start: 1, end: 3),
          ),
          const SemiTextCell(data: 'b', displayData: 'b'),
        ],
      ]);
      expect(stops, [2, 3, 4]);
    });
  });

  // -------------------------------------------------------------------------
  // Clipboard (`data-editor.tsx:3583-3901`)
  // -------------------------------------------------------------------------

  group('clipboard', () {
    List<List<SemiGridCell>> table() => [
      for (var row = 0; row < 5; row++)
        [
          for (var col = 0; col < 4; col++)
            SemiTextCell(data: 'r$row c$col', displayData: 'r$row c$col'),
        ],
    ];

    SemiGetCellsForSelection reader(List<List<SemiGridCell>> cells) =>
        (region) => [
          for (
            var y = region.y.toInt();
            y < region.y + region.height && y < cells.length;
            y++
          )
            [
              for (
                var x = region.x.toInt();
                x < region.x + region.width && x < cells[y].length;
                x++
              )
                cells[y][x],
            ],
        ];

    test('copy writes the current range as TSV', () async {
      final fake = FakeClipboard();
      final cells = table();
      await semiCopy(
        focused: true,
        copyEnabled: true,
        selection: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(1, 1),
            range: SemiRectangle(x: 1, y: 1, width: 2, height: 2),
          ),
        ),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++) SemiGridColumn(title: 'C$i', width: 100),
        ],
        getCellsForSelection: reader(cells),
        clipboard: fake,
      );
      expect(fake.writtenPlain, 'r1 c1\tr1 c2\nr2 c1\tr2 c2');
      expect(fake.writtenHtml, contains('<table>'));
    });

    test('copy prepends headers when asked', () async {
      final fake = FakeClipboard();
      await semiCopy(
        focused: true,
        copyEnabled: true,
        selection: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(0, 0),
            range: SemiRectangle(x: 0, y: 0, width: 1, height: 1),
          ),
        ),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++) SemiGridColumn(title: 'C$i', width: 100),
        ],
        getCellsForSelection: reader(table()),
        copyHeaders: true,
        clipboard: fake,
      );
      expect(fake.writtenPlain, 'C0\nr0 c0');
    });

    test('copy of a column selection zips the columns together', () async {
      final fake = FakeClipboard();
      await semiCopy(
        focused: true,
        copyEnabled: true,
        selection: const SemiGridSelection(
          columns: SemiCompactSelection.empty(),
        ).copyWith(columns: SemiCompactSelection.fromArray([0, 2])),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++) SemiGridColumn(title: 'C$i', width: 100),
        ],
        getCellsForSelection: reader(table()),
        clipboard: fake,
      );
      expect(
        fake.writtenPlain,
        'r0 c0\tr0 c2\n'
        'r1 c0\tr1 c2\n'
        'r2 c0\tr2 c2\n'
        'r3 c0\tr3 c2\n'
        'r4 c0\tr4 c2',
      );
    });

    test('copy is a no-op when unfocused or disabled', () async {
      final fake = FakeClipboard();
      const selection = SemiGridSelection(
        current: SemiGridSelectionCurrent(
          cell: SemiItem(0, 0),
          range: SemiRectangle(x: 0, y: 0, width: 1, height: 1),
        ),
      );
      await semiCopy(
        focused: false,
        copyEnabled: true,
        selection: selection,
        rows: 5,
        rowMarkerOffset: 0,
        columns: [SemiGridColumn(title: 'C', width: 100)],
        getCellsForSelection: reader(table()),
        clipboard: fake,
      );
      await semiCopy(
        focused: true,
        copyEnabled: false,
        selection: selection,
        rows: 5,
        rowMarkerOffset: 0,
        columns: [SemiGridColumn(title: 'C', width: 100)],
        getCellsForSelection: reader(table()),
        clipboard: fake,
      );
      expect(fake.writtenPlain, isNull);
    });

    test('paste without onPaste writes a single cell', () async {
      final edits = <SemiEditListItem>[];
      final fake = FakeClipboard()..nextText = 'pasted value';
      await semiPaste(
        focused: true,
        selection: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(1, 2),
            range: SemiRectangle(x: 1, y: 2, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (item) => SemiTextCell(
          data: 'old ${item.col}-${item.row}',
          displayData: 'old',
        ),
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        clipboard: fake,
      );
      expect(edits, hasLength(1));
      expect(edits.single.location, const SemiItem(1, 2));
      final pasted = edits.single.value as SemiTextCell;
      expect(pasted.data, 'pasted value');
      // Upstream's default paste path passes `formatted: undefined`, and
      // `text-cell.tsx` then keeps the previous `displayData`.
      expect(pasted.displayData, 'old');
    });

    test('paste with onPaste fills the target rectangle', () async {
      final edits = <SemiEditListItem>[];
      final fake = FakeClipboard()..nextText = 'a\tb\nc\td';
      List<List<String>>? seen;
      await semiPaste(
        focused: true,
        selection: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(1, 1),
            range: SemiRectangle(x: 1, y: 1, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (item) =>
            SemiTextCell(data: 'old', displayData: 'old'),
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        onPaste: (location, data) {
          seen = data;
          return true;
        },
        clipboard: fake,
      );
      expect(seen, [
        ['a', 'b'],
        ['c', 'd'],
      ]);
      expect(edits, hasLength(4));
      expect(edits.map((e) => e.location).toSet(), {
        const SemiItem(1, 1),
        const SemiItem(2, 1),
        const SemiItem(1, 2),
        const SemiItem(2, 2),
      });
    });

    test('onPaste returning false aborts the paste', () async {
      final edits = <SemiEditListItem>[];
      final fake = FakeClipboard()..nextText = 'a\tb';
      await semiPaste(
        focused: true,
        selection: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(0, 0),
            range: SemiRectangle(x: 0, y: 0, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (_) =>
            const SemiTextCell(data: 'old', displayData: 'old'),
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        onPaste: (_, _) => false,
        clipboard: fake,
      );
      expect(edits, isEmpty);
    });

    test('paste respects the table bounds', () async {
      final edits = <SemiEditListItem>[];
      final fake = FakeClipboard()..nextText = 'a\tb\tc\td\te\tf\tg\th\ti';
      await semiPaste(
        focused: true,
        selection: const SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(3, 4),
            range: SemiRectangle(x: 3, y: 4, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (_) =>
            const SemiTextCell(data: 'old', displayData: 'old'),
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        clipboard: fake,
      );
      expect(edits, hasLength(1));
      expect(edits.single.location, const SemiItem(3, 4));
    });

    test('pasteIntoCell coerces through the renderer', () {
      final booleanCell = const SemiBooleanCell(
        data: SemiBooleanValue.unchecked,
      );
      final edit = semiPasteToCell(
        inner: booleanCell,
        target: const SemiItem(2, 2),
        rawValue: 'true',
        getCellRenderer: SemiDefaultRendererLookup().forCell,
      );
      expect(edit, isNotNull);
      expect((edit!.value as SemiBooleanCell).data, SemiBooleanValue.checked);
    });

    test('pasteIntoCell leaves read-only cells alone', () {
      final edit = semiPasteToCell(
        inner: const SemiTextCell(data: 'x', displayData: 'x', readonly: true),
        target: const SemiItem(0, 0),
        rawValue: 'y',
        getCellRenderer: SemiDefaultRendererLookup().forCell,
      );
      expect(edit, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Overlay editor (`internal/data-grid-overlay-editor/`)
  // -------------------------------------------------------------------------

  group('overlay editor', () {
    late SemiGridCell? finishedValue;
    late SemiEditorMovement? finishedMovement;

    Widget buildEditor({
      bool forceEditMode = false,
      String? initialValue,
      Object? Function(SemiItem, SemiGridCell, SemiGridCell)? validateCell,
      SemiGridCell? content,
    }) {
      finishedValue = null;
      finishedMovement = null;
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SemiDataGridOverlayEditor(
                  target: const SemiRectangle(
                    x: 10,
                    y: 10,
                    width: 120,
                    height: 30,
                  ),
                  cell: const SemiItem(0, 0),
                  content:
                      content ??
                      const SemiTextCell(data: 'hello', displayData: 'hello'),
                  theme: SemiDataGridTheme.light(),
                  onFinishEditing: (cell, movement) {
                    finishedValue = cell;
                    finishedMovement = movement;
                  },
                  forceEditMode: forceEditMode,
                  highlight: false,
                  getCellRenderer: SemiDefaultRendererLookup().forCell,
                  initialValue: initialValue,
                  validateCell: validateCell,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('overlay width follows content like CSS max-content', (
      tester,
    ) async {
      Rect boxRect() => tester.getRect(
            find
                .descendant(
                  of: find.byType(SemiDataGridOverlayEditor),
                  matching: find.byType(ConstrainedBox),
                )
                .first,
          );

      // `width: max-content` clamps a short value up to the cell width
      // (120px + 1px bloom on each side), not to the 400px cap.
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();
      expect(boxRect().width, 122.0);

      // Longer values grow the box, still capped by the available space.
      // Tear the old editor down first: `_tempValue` is initialised once in
      // initState, so reusing the same State would keep the old content.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final longText = 'x' * 200;
      await tester.pumpWidget(
        buildEditor(
          forceEditMode: true,
          content: SemiTextCell(data: longText, displayData: longText),
        ),
      );
      await tester.pumpAndSettle();
      expect(boxRect().width, greaterThan(122.0));
      expect(boxRect().width, lessThanOrEqualTo(391.0));
    });

    testWidgets('enter commits and moves down', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(finishedMovement, SemiEditorMovement.down);
      expect((finishedValue as SemiTextCell).data, 'hello');
    });

    testWidgets('enter without forceEditMode moves without committing', (
      tester,
    ) async {
      // `tempValue` is undefined until the user types, so upstream finishes
      // with `undefined` and `data-editor.tsx:3086` skips the write.
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(finishedValue, isNull);
      expect(finishedMovement, SemiEditorMovement.down);
    });

    testWidgets('escape discards the edit', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(finishedValue, isNull);
      expect(finishedMovement, SemiEditorMovement.none);
    });

    testWidgets('tab commits and moves right', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(finishedMovement, SemiEditorMovement.right);
      expect(finishedValue, isNotNull);
    });

    testWidgets('tapping outside commits the current value', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(350, 250));
      await tester.pump();

      expect(finishedValue, isNotNull);
      expect(finishedMovement, SemiEditorMovement.none);
    });

    testWidgets('invalid cells finish with null', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          forceEditMode: true,
          validateCell: (cell, newValue, prev) => false,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(finishedValue, isNull);
      expect(finishedMovement, SemiEditorMovement.down);
    });

    testWidgets('forceEditMode opens with the cell value', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();

      expect(find.text('hello'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Data editor (`data-editor/data-editor.tsx`)
  // -------------------------------------------------------------------------

  group('data editor', () {
    late List<SemiEditListItem> edits;
    late List<SemiGridSelection> selectionLog;
    late List<String> activationLog;
    const desktopSearch = TargetPlatformVariant({TargetPlatform.windows});
    final searchTheme = const SemiThemeOverride(
      bgSearchResult: Color(0xFFFF00E5),
    ).applyTo(SemiDataGridTheme.light());

    List<List<SemiGridCell>> table() => [
      for (var row = 0; row < 200; row++)
        [
          for (var col = 0; col < 6; col++)
            SemiTextCell(data: 'r$row c$col', displayData: 'r$row c$col'),
        ],
    ];

    Widget buildEditor({
      SemiGridCell Function(SemiItem item)? content,
      bool editOnType = true,
      SemiKeybinds? keybindings,
      SemiFillHandleConfig? fillHandle,
      void Function(SemiFillPatternArgs args)? onFillPattern,
      void Function(
        SemiGridColumn column,
        double newSize,
        int colIndex,
        double newSizeWithGrow,
      )?
      onColumnResize,
      void Function(
        SemiGridColumn column,
        double newSize,
        int colIndex,
        double newSizeWithGrow,
      )?
      onColumnResizeStart,
      void Function(
        SemiGridColumn column,
        double newSize,
        int colIndex,
        double newSizeWithGrow,
      )?
      onColumnResizeEnd,
      void Function(int from, int to)? onColumnMoved,
      bool? Function(int from, int to)? onColumnProposeMove,
      void Function(int from, int to)? onRowMoved,
      SemiRowMarkerOptions? rowMarkers,
      SemiGridSelection? gridSelection,
      bool scrollToActiveCell = true,
      int rows = 200,
      int columnCount = 6,
      bool unsizedColumns = false,
      double minColumnWidth = 50,
      double maxColumnWidth = 500,
      double? maxColumnAutoWidth,
      (double, double)? editorBloom,
      double? scrollOffsetY,
      double? scrollOffsetX,
      bool strict = false,
      int freezeTrailingRows = 0,
      SemiKeybinds? keybindingsOverride,
      String? group,
      void Function(String groupName, String newVal)? onGroupHeaderRenamed,
      void Function(SemiItem location)? onCellFocused,
      void Function(SemiVisibleRegion region, SemiVisibleRegionExtras extras)?
      onVisibleRegionChanged,
      void Function(SemiGridCell? newValue, SemiEditorMovement movement)?
      onFinishedEditing,
      SemiRangeSelect rangeSelect = SemiRangeSelect.rect,
      void Function(SemiItem location, SemiCellClickedEventArgs args)?
      onCellClicked,
      void Function(SemiItem location, SemiCellClickedEventArgs args)?
      onCellContextMenu,
      void Function(int col, SemiGridHeaderMouseArgs args)? onHeaderClicked,
      void Function(int col, SemiHeaderClickedEventArgs args)?
      onHeaderContextMenu,
      void Function(int col, SemiGroupHeaderClickedEventArgs args)?
      onGroupHeaderClicked,
      bool hasMenu = false,
      void Function(int col, SemiRectangle bounds)? onHeaderMenuClick,
      void Function(SemiGridMouseArgs args)? onMouseMove,
      SemiRowGroupingOptions? rowGrouping,
      SemiTrailingRowOptions? trailingRowOptions,
      FutureOr<Object?> Function()? onRowAppended,
      Object? Function()? onColumnAppended,
      SemiGetCellsForSelection? cellsForSelection,
      SemiDeleteCallback? onDelete,
      SemiPasteCallback? onPaste,
      SemiSpanRangeBehavior spanRangeBehavior =
          SemiSpanRangeBehavior.standard,
      SemiDataGridTheme? theme,
      bool? showSearch,
      String? searchValue,
      List<SemiItem>? searchResults,
      ValueChanged<String>? onSearchValueChange,
      void Function(List<SemiItem> results, int navIndex)?
      onSearchResultsChanged,
      SemiDrawCellCallback? drawCell,
      SemiDrawHeaderCallback? drawHeader,
      SemiRendererLookup? rendererLookup,
      Object? Function(SemiItem cell, SemiGridCell newValue, SemiGridCell prevValue)?
      validateCell,
      SemiEditorProvider? Function(SemiGridCell cell, SemiItem location)?
      provideEditor,
      SemiDataEditorController? controller,
      void Function(SemiGridKeyArgs event)? onKeyDown,
    }) {
      edits = [];
      selectionLog = [];
      activationLog = [];
      final cells = table();
      var currentRows = rows;
      var currentCols = columnCount;
      return StatefulBuilder(
        builder: (context, setRows) {
          final p = SemiDataEditorProps(
            columns: [
              for (var i = 0; i < currentCols; i++)
                unsizedColumns
                    ? SemiGridColumn(
                        title: 'C$i',
                        id: 'c$i',
                        group: group,
                        // No `width`: `useColumnSizer` skips columns that are
                        // already sized (`use-column-sizer.ts:100-107`).
                      )
                    : SemiGridColumn(
                        title: 'C$i',
                        width: 100,
                        group: group,
                        hasMenu: hasMenu,
                      ),
            ],
            enableGroups: group != null,
            groupHeaderHeight: 30,
            onGroupHeaderRenamed: onGroupHeaderRenamed,
            rows: currentRows,
            rowGrouping: rowGrouping,
            minColumnWidth: minColumnWidth,
            maxColumnWidth: maxColumnWidth,
            maxColumnAutoWidth: maxColumnAutoWidth,
            editorBloom: editorBloom,
            scrollOffsetY: scrollOffsetY,
            scrollOffsetX: scrollOffsetX,
            strict: strict,
            freezeTrailingRows: freezeTrailingRows,
            rendererLookup: rendererLookup,
            validateCell: validateCell,
            provideEditor: provideEditor,
            drawCell: drawCell,
            drawHeader: drawHeader,
            keybindings: keybindingsOverride ?? keybindings,
            onCellFocused: onCellFocused,
            onVisibleRegionChanged: onVisibleRegionChanged,
            onFinishedEditing: onFinishedEditing,
            rangeSelect: rangeSelect,
            onCellClicked: onCellClicked,
            onCellContextMenu: onCellContextMenu,
            onHeaderClicked: onHeaderClicked,
            onHeaderContextMenu: onHeaderContextMenu,
            onGroupHeaderClicked: onGroupHeaderClicked,
            onHeaderMenuClick: onHeaderMenuClick,
            onMouseMove: onMouseMove,
            onColumnAppended: onColumnAppended == null
                ? null
                : () {
                    setRows(() => currentCols++);
                    return onColumnAppended();
                  },
            trailingRowOptions: trailingRowOptions,
            onRowAppended: trailingRowOptions == null
                ? null
                : () async {
                    setRows(() => currentRows++);
                    return await onRowAppended?.call();
                  },
            getCellContent: (item, [_]) {
              if (content != null) return content(item);
              if (item.row >= cells.length ||
                  item.col >= cells[item.row].length) {
                return const SemiTextCell(data: 'new', displayData: 'new');
              }
              return cells[item.row][item.col];
            },
            theme: theme ?? SemiDataGridTheme.light(),
            rowHeight: const SemiRowHeight.fixed(32),
            headerHeight: 32,
            onKeyDown: onKeyDown ?? (_) {},
            onDelete: onDelete,
            onPaste: onPaste,
            onCellsEdited: (items) {
              edits.addAll(items);
              return true;
            },
            gridSelection: gridSelection,
            onGridSelectionChange: selectionLog.add,
            scrollToActiveCell: scrollToActiveCell,
            onCellActivated: (location, activation) {
              final key = activation is SemiKeyboardCellActivation
                  ? activation.key
                  : 'pointer';
              activationLog.add('$location:$key');
            },
            editOnType: editOnType,
            fillHandle: fillHandle,
            onFillPattern: onFillPattern,
            onColumnResize: onColumnResize,
            onColumnResizeStart: onColumnResizeStart,
            onColumnResizeEnd: onColumnResizeEnd,
            onColumnMoved: onColumnMoved,
            onColumnProposeMove: onColumnProposeMove,
            onRowMoved: onRowMoved,
            rowMarkers: rowMarkers,
            spanRangeBehavior: spanRangeBehavior,
            showSearch: showSearch,
            searchValue: searchValue,
            searchResults: searchResults,
            onSearchValueChange: onSearchValueChange,
            onSearchResultsChanged: onSearchResultsChanged,
            getCellsForSelection:
                cellsForSelection ??
                (region) => [
                  for (
                    var y = region.y.toInt();
                    y < region.y + region.height && y < cells.length;
                    y++
                  )
                    [
                      for (
                        var x = region.x.toInt();
                        x < region.x + region.width && x < cells[y].length;
                        x++
                      )
                        cells[y][x],
                    ],
                ],
          );
          return MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: SemiDataEditor(props: p, controller: controller),
              ),
            ),
          );
        },
      );
    }

    testWidgets('the editor strips the row-marker offset from the menu col', (
      tester,
    ) async {
      final fired = <int>[];
      final headerClicks = <int>[];
      await tester.pumpWidget(
        buildEditor(
          hasMenu: true,
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          onHeaderMenuClick: (col, bounds) => fired.add(col),
          onHeaderClicked: (col, _) => headerClicks.add(col),
        ),
      );
      await tester.pumpAndSettle();

      // The marker column owns x in [0, 40), so user column 0 is mangled
      // column 1 spanning [40, 140). Its menu button is right-aligned in the
      // 100px column: x in [110, 140); headerHeight 32 puts y in [1, 31).
      final gesture = await tester.startGesture(
        const Offset(125, 16),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        fired,
        [0],
        reason: 'the callback must report the user column, not the mangled one',
      );
      expect(headerClicks, isEmpty);
      expect(selectionLog, isEmpty);
    });

    testWidgets('a normal header click reports the business column', (
      tester,
    ) async {
      final clicks = <int>[];
      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          onHeaderClicked: (col, _) => clicks.add(col),
        ),
      );
      await tester.tapAt(const Offset(190, 16), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(clicks, [1]);
      expect(selectionLog.last.columns.toArray(), [1]);
    });

    testWidgets('group header selection skips row markers and is cancelable', (
      tester,
    ) async {
      final clicks = <(int, int)>[];
      var preventSelection = true;
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          group: 'Team A',
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          onGroupHeaderClicked: (col, args) {
            clicks.add((col, args.col));
            if (preventSelection) args.preventDefault();
          },
        ),
      );
      const groupHeader = Offset(290, 15);
      await tester.tapAt(groupHeader, kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(clicks, [(2, 2)]);
      expect(selectionLog, isEmpty);

      preventSelection = false;
      await tester.tapAt(groupHeader, kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(clicks, [(2, 2), (2, 2)]);
      expect(selectionLog.last.columns.toArray(), [0, 1, 2]);
    });

    testWidgets('unmatched mouse releases do not fire header clicks', (
      tester,
    ) async {
      final clicks = <int>[];
      await tester.pumpWidget(
        buildEditor(onHeaderClicked: (col, _) => clicks.add(col)),
      );

      // One press starts on a different column, the other on a different row.
      for (final down in [const Offset(150, 16), const Offset(50, 45)]) {
        final gesture = await tester.startGesture(
          down,
          kind: PointerDeviceKind.mouse,
        );
        await gesture.moveTo(const Offset(50, 16));
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(clicks, isEmpty);
    });

    testWidgets('cancelled header press does not leak to the next click', (
      tester,
    ) async {
      final clicks = <int>[];
      await tester.pumpWidget(
        buildEditor(onHeaderClicked: (col, _) => clicks.add(col)),
      );
      final gesture = await tester.startGesture(
        const Offset(50, 16),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(clicks, isEmpty);

      await tester.tapAt(const Offset(150, 16), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(clicks, [1]);
    });

    testWidgets('releasing over the menu mid-drag does not fire it', (
      tester,
    ) async {
      final fired = <int>[];
      await tester.pumpWidget(
        buildEditor(
          hasMenu: true,
          onColumnMoved: (_, _) {},
          onHeaderMenuClick: (col, bounds) => fired.add(col),
        ),
      );
      await tester.pumpAndSettle();

      // Press on column 0's header (off its resize edge), travel past the 20px
      // threshold so `dragColActive` arms, then come back over the menu button
      // and release. Upstream has two layers here — `isDragging` on the grid
      // (`data-grid-dnd.tsx:436`) and the guard in the callback wrapper
      // (`:190`) — and both must hold.
      final gesture = await tester.startGesture(
        const Offset(50, 16),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveTo(const Offset(150, 16));
      await gesture.moveTo(const Offset(85, 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(fired, isEmpty, reason: 'an active drag owns the click');
    });

    testWidgets('clicking a cell selects it', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog, isNotEmpty);
      final current = selectionLog.last.current;
      expect(current, isNotNull);
      expect(current!.cell, const SemiItem(1, 0));
    });

    testWidgets('Shift-click expands the range from the original cell', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.tapAt(const Offset(50, 45), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tapAt(const Offset(250, 109), kind: PointerDeviceKind.mouse);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      final current = selectionLog.last.current!;
      expect(current.cell, const SemiItem(0, 0));
      expect(current.range, const SemiRectangle(x: 0, y: 0, width: 3, height: 3));
      expect(current.rangeStack, isEmpty);
    });

    testWidgets('Ctrl/Meta-click appends a multiRect range', (tester) async {
      await tester.pumpWidget(
        buildEditor(rangeSelect: SemiRangeSelect.multiRect),
      );
      await tester.tapAt(const Offset(50, 45), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      final modifier = defaultTargetPlatform == TargetPlatform.macOS
          ? LogicalKeyboardKey.metaLeft
          : LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(modifier);
      await tester.tapAt(const Offset(250, 109), kind: PointerDeviceKind.mouse);
      await tester.sendKeyUpEvent(modifier);
      await tester.pumpAndSettle();

      final current = selectionLog.last.current!;
      expect(current.cell, const SemiItem(2, 2));
      expect(current.range, const SemiRectangle(x: 2, y: 2, width: 1, height: 1));
      expect(current.rangeStack, [
        const SemiRectangle(x: 0, y: 0, width: 1, height: 1),
      ]);
    }, variant: const TargetPlatformVariant({
      TargetPlatform.windows,
      TargetPlatform.macOS,
    }));

    testWidgets('middle clicks do not edit; right clicks go to context menu', (
      tester,
    ) async {
      final clicks = <(SemiItem, int, int)>[];
      final contextMenus = <SemiItem>[];
      await tester.pumpWidget(
        buildEditor(
          content: (_) => const SemiTextCell(
            data: 'editable',
            displayData: 'editable',
            activationBehaviorOverride: SemiCellActivationBehavior.singleClick,
          ),
          onCellClicked: (item, args) =>
              clicks.add((item, args.button, args.buttons)),
          onCellContextMenu: (item, _) => contextMenus.add(item),
        ),
      );
      await tester.tapAt(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
        buttons: kMiddleMouseButton,
      );
      await tester.pumpAndSettle();

      expect(clicks, [(const SemiItem(0, 0), 1, 0)]);
      expect(contextMenus, isEmpty);
      expect(selectionLog, isEmpty);
      expect(activationLog, isEmpty);
      expect(edits, isEmpty);
      expect(find.byType(SemiDataGridOverlayEditor), findsNothing);

      final secondary = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
      expect(selectionLog, isEmpty);
      await secondary.up();
      await tester.pumpAndSettle();

      expect(contextMenus, [const SemiItem(1, 0)]);
      expect(clicks, hasLength(1));
      // A context menu outside the selection makes that cell current, as
      // Glide does, without going through the primary click or editor.
      expect(selectionLog.single.current!.cell, const SemiItem(1, 0));
      expect(activationLog, isEmpty);
      expect(edits, isEmpty);
    });

    testWidgets('a second click on the selected cell opens the editor', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('arrow keys move the selection', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell, const SemiItem(1, 1));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell, const SemiItem(2, 1));
    });

    void mockGridClipboard({
      String? text,
      Future<void> Function(String text)? write,
    }) {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData' &&
            call.arguments == Clipboard.kTextPlain &&
            text != null) {
          return {'text': text};
        }
        if (call.method == 'Clipboard.setData') {
          await write?.call((call.arguments as Map)['text'] as String);
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      });
    }

    Future<void> focusClipboardCell(WidgetTester tester, double x) async {
      final gesture = await tester.startGesture(
        Offset(x, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
    }

    Future<void> sendClipboardShortcut(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(key);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
    }

    group('controlled grid selection', () {
      SemiGridSelection renderedSelection(WidgetTester tester) => tester
          .widget<SemiDataGrid>(find.byType(SemiDataGrid))
          .props
          .selection;

      SemiGridSelection singleCell(int col, int row) => SemiGridSelection(
        current: SemiGridSelectionCurrent(
          cell: SemiItem(col, row),
          range: SemiRectangle(
            x: col.toDouble(),
            y: row.toDouble(),
            width: 1,
            height: 1,
          ),
        ),
      );

      testWidgets('renders initial, updated, and explicitly empty values', (
        tester,
      ) async {
        final initial = singleCell(1, 2);
        await tester.pumpWidget(buildEditor(gridSelection: initial));
        await tester.pumpAndSettle();
        final editor = tester.state(find.byType(SemiDataEditor));
        expect(renderedSelection(tester), initial);
        expect(selectionLog, isEmpty);

        final updated = singleCell(2, 3);
        await tester.pumpWidget(buildEditor(gridSelection: updated));
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(SemiDataEditor)), same(editor));
        expect(renderedSelection(tester), updated);
        expect(selectionLog, isEmpty);

        await tester.pumpWidget(
          buildEditor(gridSelection: SemiGridSelection.empty),
        );
        await tester.pumpAndSettle();
        expect(renderedSelection(tester), SemiGridSelection.empty);
        expect(selectionLog, isEmpty);

        await focusClipboardCell(tester, 50);
        expect(selectionLog, [singleCell(0, 0)]);
        expect(renderedSelection(tester), SemiGridSelection.empty);
      });

      testWidgets('reports focus after the parent accepts a proposal', (
        tester,
      ) async {
        final focused = <SemiItem>[];
        await tester.pumpWidget(
          buildEditor(
            gridSelection: singleCell(1, 0),
            onCellFocused: focused.add,
          ),
        );
        await tester.pumpAndSettle();
        expect(focused, [const SemiItem(1, 0)]);

        await focusClipboardCell(tester, 50);
        final proposed = selectionLog.single;
        expect(focused, [const SemiItem(1, 0)]);

        await tester.pumpWidget(
          buildEditor(gridSelection: proposed, onCellFocused: focused.add),
        );
        await tester.pumpAndSettle();
        expect(renderedSelection(tester), proposed);
        expect(focused, [const SemiItem(1, 0), const SemiItem(0, 0)]);
        expect(selectionLog, isEmpty);
      });

      testWidgets('uses the committed selection for proposals and copy', (
        tester,
      ) async {
        const committed = SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(1, 2),
            range: SemiRectangle(x: 1, y: 2, width: 2, height: 2),
          ),
        );
        final writes = <String>[];
        mockGridClipboard(write: (text) async => writes.add(text));
        await tester.pumpWidget(buildEditor(gridSelection: committed));
        await tester.pumpAndSettle();

        await focusClipboardCell(tester, 50);
        expect(selectionLog, [singleCell(0, 0)]);
        expect(renderedSelection(tester), committed);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.tapAt(const Offset(50, 80), kind: PointerDeviceKind.mouse);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        const extend = SemiGridSelection(
          current: SemiGridSelectionCurrent(
            cell: SemiItem(1, 2),
            range: SemiRectangle(x: 0, y: 1, width: 2, height: 2),
          ),
        );
        expect(selectionLog, [singleCell(0, 0), extend]);
        expect(renderedSelection(tester), committed);

        final moveRight = singleCell(2, 2);
        for (var i = 0; i < 2; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          expect(renderedSelection(tester), committed);
        }
        expect(selectionLog, [singleCell(0, 0), extend, moveRight, moveRight]);

        await sendClipboardShortcut(tester, LogicalKeyboardKey.keyC);
        expect(writes, ['r2 c1\tr2 c2\nr3 c1\tr3 c2']);
      });

      testWidgets('shifts current, range stack, and columns for row markers', (
        tester,
      ) async {
        final committed = SemiGridSelection(
          current: const SemiGridSelectionCurrent(
            cell: SemiItem(1, 2),
            range: SemiRectangle(x: 1, y: 2, width: 2, height: 1),
            rangeStack: [
              SemiRectangle(x: 0, y: 0, width: 1, height: 2),
              SemiRectangle(x: 2, y: 4, width: 2, height: 1),
            ],
          ),
          columns: SemiCompactSelection.fromArray([0, 2]),
          rows: SemiCompactSelection.fromArray([1, 4]),
        );
        await tester.pumpWidget(
          buildEditor(
            gridSelection: committed,
            rowMarkers: const SemiRowMarkerOptions(width: 40),
          ),
        );
        await tester.pumpAndSettle();
        final rendered = renderedSelection(tester);
        expect(
          rendered.current,
          const SemiGridSelectionCurrent(
            cell: SemiItem(2, 2),
            range: SemiRectangle(x: 2, y: 2, width: 2, height: 1),
            rangeStack: [
              SemiRectangle(x: 1, y: 0, width: 1, height: 2),
              SemiRectangle(x: 3, y: 4, width: 2, height: 1),
            ],
          ),
        );
        expect(rendered.columns.toArray(), [1, 3]);
        expect(rendered.rows.toArray(), [1, 4]);

        // The marker takes the first 40px, so this click is in data column 0.
        await focusClipboardCell(tester, 90);
        expect(selectionLog, [singleCell(0, 0)]);
        expect(renderedSelection(tester), rendered);

        await tester.pumpWidget(buildEditor(gridSelection: committed));
        await tester.pumpAndSettle();
        expect(renderedSelection(tester), committed);
        expect(selectionLog, isEmpty);
      });

      for (final scrollToActiveCell in [true, false]) {
        testWidgets(
          'external selection follows scrollToActiveCell=$scrollToActiveCell',
          (tester) async {
            final regions = <SemiVisibleRegion>[];
            Widget editor(SemiGridSelection selection) => buildEditor(
              gridSelection: selection,
              scrollToActiveCell: scrollToActiveCell,
              onVisibleRegionChanged: (region, _) => regions.add(region),
            );

            await tester.pumpWidget(editor(singleCell(0, 0)));
            await tester.pumpAndSettle();
            final initialRegion = regions.last;
            const target = SemiItem(5, 60);
            expect(initialRegion.rect.containsItem(target), isFalse);

            final updated = singleCell(target.col, target.row);
            await tester.pumpWidget(editor(updated));
            await tester.pumpAndSettle();
            expect(renderedSelection(tester), updated);
            if (scrollToActiveCell) {
              expect(regions.last.rect.containsItem(target), isTrue);
            } else {
              expect(regions.last, initialRegion);
            }
            expect(selectionLog, isEmpty);
          },
        );
      }

      testWidgets('clips the committed selection when the grid shrinks', (
        tester,
      ) async {
        final committed = SemiGridSelection(
          current: const SemiGridSelectionCurrent(
            cell: SemiItem(1, 1),
            range: SemiRectangle(x: 1, y: 1, width: 3, height: 3),
            rangeStack: [
              SemiRectangle(x: 2, y: 0, width: 2, height: 2),
              SemiRectangle(x: 0, y: 3, width: 1, height: 1),
            ],
          ),
          columns: SemiCompactSelection.fromArray([0, 2, 3]),
          rows: SemiCompactSelection.fromArray([0, 1, 3]),
        );
        await tester.pumpWidget(
          buildEditor(gridSelection: committed, rows: 4, columnCount: 4),
        );
        await tester.pumpAndSettle();
        expect(renderedSelection(tester), committed);

        await tester.pumpWidget(
          buildEditor(gridSelection: committed, rows: 2, columnCount: 3),
        );
        await tester.pumpAndSettle();
        final rendered = renderedSelection(tester);
        expect(
          rendered.current,
          const SemiGridSelectionCurrent(
            cell: SemiItem(1, 1),
            range: SemiRectangle(x: 1, y: 1, width: 2, height: 1),
            rangeStack: [SemiRectangle(x: 2, y: 0, width: 1, height: 2)],
          ),
        );
        expect(rendered.columns.toArray(), [0, 2]);
        expect(rendered.rows.toArray(), [0, 1]);
        expect(selectionLog, isEmpty);
      });
    });

    group('DataEditorRef controller', () {
      SemiGridSelection renderedSelection(WidgetTester tester) => tester
          .widget<SemiDataGrid>(find.byType(SemiDataGrid))
          .props
          .selection;

      testWidgets('appendRow and appendColumn select the new data', (
        tester,
      ) async {
        final controller = SemiDataEditorController();
        var appended = 0;
        await tester.pumpWidget(
          buildEditor(
            controller: controller,
            rows: 3,
            columnCount: 3,
            trailingRowOptions: const SemiTrailingRowOptions(),
            onRowAppended: () {
              appended++;
              return null;
            },
            onColumnAppended: () {
              appended++;
              return null;
            },
          ),
        );
        await tester.pumpAndSettle();

        final rowFuture = controller.appendRow(1, openOverlay: false);
        await tester.pumpAndSettle();
        await rowFuture;
        expect(appended, 1);
        expect(renderedSelection(tester).current!.cell, const SemiItem(1, 3));

        final colFuture = controller.appendColumn(0, openOverlay: false);
        await tester.pumpAndSettle();
        await colFuture;
        expect(appended, 2);
        expect(renderedSelection(tester).current!.cell, const SemiItem(3, 0));
      });

      testWidgets('emit copy and delete operate on the selection', (
        tester,
      ) async {
        final controller = SemiDataEditorController();
        final writes = <String>[];
        mockGridClipboard(write: (text) async => writes.add(text));
        await tester.pumpWidget(
          buildEditor(controller: controller, rows: 2, columnCount: 2),
        );
        await tester.pumpAndSettle();
        await focusClipboardCell(tester, 50);

        await controller.emit(SemiEmitEvent.copy);
        await tester.pumpAndSettle();
        expect(writes, ['r0 c0']);

        await controller.emit(SemiEmitEvent.delete);
        await tester.pumpAndSettle();
        expect(edits.single.location, const SemiItem(0, 0));
        expect((edits.single.value as SemiTextCell).data, isEmpty);
      });

      testWidgets('emit paste writes the clipboard data', (tester) async {
        final controller = SemiDataEditorController();
        mockGridClipboard(text: 'pasted');
        await tester.pumpWidget(
          buildEditor(controller: controller, rows: 2, columnCount: 2),
        );
        await tester.pumpAndSettle();
        await focusClipboardCell(tester, 50);

        await controller.emit(SemiEmitEvent.paste);
        await tester.pumpAndSettle();
        expect(edits.single.location, const SemiItem(0, 0));
        expect((edits.single.value as SemiTextCell).data, 'pasted');
      });

      testWidgets('emit fill-right fills the selected range', (tester) async {
        final controller = SemiDataEditorController();
        await tester.pumpWidget(
          buildEditor(
            controller: controller,
            rows: 2,
            columnCount: 3,
            // Fill is unbound by default upstream too
            // (`data-editor-keybindings.ts:77-78`).
            keybindings: const SemiKeybinds(downFill: true, rightFill: true),
          ),
        );
        await tester.pumpAndSettle();

        await focusClipboardCell(tester, 50);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.tapAt(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        expect(renderedSelection(tester).current!.range.width, 2);
        edits.clear();

        await controller.emit(SemiEmitEvent.fillRight);
        await tester.pumpAndSettle();
        expect(edits, hasLength(1));
        expect(edits.single.location, const SemiItem(1, 0));
        expect((edits.single.value as SemiTextCell).data, 'r0 c0');
      });

      testWidgets('emit delete is cancelled by onKeyDown', (tester) async {
        final controller = SemiDataEditorController();
        var keyDowns = 0;
        await tester.pumpWidget(
          buildEditor(
            controller: controller,
            rows: 2,
            columnCount: 2,
            onKeyDown: (event) {
              keyDowns++;
              event.cancel();
            },
          ),
        );
        await tester.pumpAndSettle();
        await focusClipboardCell(tester, 50);

        await controller.emit(SemiEmitEvent.delete);
        await tester.pumpAndSettle();
        expect(keyDowns, 1);
        expect(edits, isEmpty);
      });

      testWidgets('getBounds, scrollTo and mouse args use business coords', (
        tester,
      ) async {
        final controller = SemiDataEditorController();
        final regions = <SemiVisibleRegion>[];
        await tester.pumpWidget(
          buildEditor(
            controller: controller,
            rows: 80,
            columnCount: 3,
            rowMarkers: const SemiRowMarkerOptions(width: 40),
            onVisibleRegionChanged: (region, _) => regions.add(region),
          ),
        );
        await tester.pumpAndSettle();

        // Marker (40) + 3 x 100 wide, 80 x 32 tall.
        expect(
          controller.getBounds(null, null),
          const SemiRectangle(x: 0, y: 0, width: 340, height: 2560),
        );
        // Business col 1 is grid col 2: marker 40 + first data column 100.
        final cell = controller.getBounds(1, 0)!;
        expect(cell.x, 140);
        // `computeBounds` inflates by a pixel so the hit box covers the grid
        // line, matching the painter's own cell rects.
        expect(cell.width, 101);

        // Grid column 1 (the marker owns 0..40) is business column 0.
        final args = controller.getMouseArgsForPosition(90, 45);
        expect(args, isA<SemiGridCellMouseArgs>());
        expect(
          (args! as SemiGridCellMouseArgs).location,
          const SemiItem(0, 0),
        );

        final initial = regions.last;
        controller.scrollTo(2, 60);
        await tester.pumpAndSettle();
        expect(regions.last, isNot(initial));
        expect(regions.last.rect.containsItem(const SemiItem(2, 60)), isTrue);
      });

      testWidgets('remeasureColumns reports business column indices', (
        tester,
      ) async {
        final controller = SemiDataEditorController();
        final measured = <(String, int)>[];
        await tester.pumpWidget(
          buildEditor(
            controller: controller,
            rows: 3,
            columnCount: 3,
            rowMarkers: const SemiRowMarkerOptions(width: 40),
            onColumnResize: (column, width, col, grow) =>
                measured.add((column.title, col)),
          ),
        );
        await tester.pumpAndSettle();

        controller.remeasureColumns(SemiCompactSelection.fromArray([1]));
        await tester.pumpAndSettle();

        expect(measured, [('C1', 1)]);
      });

      testWidgets('a replaced or disposed editor detaches the controller', (
        tester,
      ) async {
        final first = SemiDataEditorController();
        final second = SemiDataEditorController();
        await tester.pumpWidget(buildEditor(controller: first));
        await tester.pumpAndSettle();
        expect(first.getBounds(0, 0), isNotNull);

        await tester.pumpWidget(buildEditor(controller: second));
        await tester.pumpAndSettle();
        expect(first.getBounds(0, 0), isNull);
        expect(second.getBounds(0, 0), isNotNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(second.getBounds(0, 0), isNull);
      });
    });

    group('append positions', () {
      SemiItem selectedCell(WidgetTester tester) => tester
          .widget<SemiDataGrid>(find.byType(SemiDataGrid))
          .props
          .selection
          .current!
          .cell;

      testWidgets('onRowAppended chooses where the new row is focused', (
        tester,
      ) async {
        Future<SemiItem> appendedAt(Object? answer) async {
          final controller = SemiDataEditorController();
          await tester.pumpWidget(
            buildEditor(
              controller: controller,
              rows: 3,
              columnCount: 2,
              trailingRowOptions: const SemiTrailingRowOptions(),
              onRowAppended: () => answer,
            ),
          );
          await tester.pumpAndSettle();

          final appended = controller.appendRow(1, openOverlay: false);
          await tester.pumpAndSettle();
          await appended;
          return selectedCell(tester);
        }

        // `row = typeof r === "number" ? r : bottom ? rows : 0`
        // (`data-editor.tsx:1710-1714`).
        expect(await appendedAt(null), const SemiItem(1, 3));
        expect(await appendedAt('bottom'), const SemiItem(1, 3));
        expect(await appendedAt('top'), const SemiItem(1, 0));
        expect(await appendedAt(1), const SemiItem(1, 1));
      });

      testWidgets('onColumnAppended may resolve asynchronously', (
        tester,
      ) async {
        final controller = SemiDataEditorController();
        var appended = 0;
        await tester.pumpWidget(
          buildEditor(
            controller: controller,
            rows: 3,
            columnCount: 3,
            onColumnAppended: () async {
              appended++;
              return null;
            },
          ),
        );
        await tester.pumpAndSettle();

        final future = controller.appendColumn(0, openOverlay: false);
        await tester.pumpAndSettle();
        await future;

        expect(appended, 1);
        expect(selectedCell(tester), const SemiItem(3, 0));
      });

      testWidgets('a sticky trailing row counts as a frozen trailing row', (
        tester,
      ) async {
        Widget grid(int freeze, {required bool sticky}) => buildEditor(
          rows: 20,
          columnCount: 2,
          freezeTrailingRows: freeze,
          trailingRowOptions: SemiTrailingRowOptions(sticky: sticky),
        );

        await tester.pumpWidget(grid(1, sticky: false));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SemiDataGrid>(find.byType(SemiDataGrid)).props
              .freezeTrailingRows,
          1,
        );

        await tester.pumpWidget(grid(1, sticky: true));
        await tester.pumpAndSettle();
        // The sticky "new row" row joins the frozen trailing rows
        // (`data-editor.tsx:4278`).
        expect(
          tester.widget<SemiDataGrid>(find.byType(SemiDataGrid)).props
              .freezeTrailingRows,
          2,
        );
      });
    });

    testWidgets(
      'cut writes before clearing text and numbers, but skips readonly cells',
      (tester) async {
        const cells = <SemiGridCell>[
          SemiTextCell(data: 'source', displayData: 'source'),
          SemiNumberCell(data: 42, displayData: '42'),
          SemiTextCell(
            data: 'readonly',
            displayData: 'readonly',
            readonly: true,
          ),
        ];
        final writeCompleted = Completer<void>();
        final writes = <String>[];
        mockGridClipboard(
          write: (text) {
            writes.add(text);
            return writeCompleted.future;
          },
        );
        await tester.pumpWidget(
          buildEditor(
            rows: 1,
            columnCount: cells.length,
            rowMarkers: const SemiRowMarkerOptions(width: 40),
            content: (item) => cells[item.col],
            cellsForSelection: (r) => [
              cells.sublist(r.x.toInt(), (r.x + r.width).toInt()),
            ],
          ),
        );
        await tester.pumpAndSettle();
        await focusClipboardCell(tester, 70);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();

        await sendClipboardShortcut(tester, LogicalKeyboardKey.keyX);
        expect(writes, ['source\t42\treadonly']);
        expect(edits, isEmpty);

        writeCompleted.complete();
        await tester.pumpAndSettle();
        expect(edits.map((edit) => edit.location), [
          const SemiItem(0, 0),
          const SemiItem(1, 0),
        ]);
        expect((edits[0].value as SemiTextCell).data, isEmpty);
        final clearedNumber = edits[1].value as SemiNumberCell;
        expect(clearedNumber.data, isNull);
        expect(clearedNumber.displayData, isEmpty);
      },
    );

    testWidgets('cut copies but does not clear when onDelete rejects it', (
      tester,
    ) async {
      final writes = <String>[];
      final deleteRequests = <SemiGridSelection>[];
      mockGridClipboard(write: (text) async => writes.add(text));
      await tester.pumpWidget(
        buildEditor(
          onDelete: (selection) {
            deleteRequests.add(selection);
            return false;
          },
        ),
      );
      await tester.pumpAndSettle();
      await focusClipboardCell(tester, 50);
      await sendClipboardShortcut(tester, LogicalKeyboardKey.keyX);

      expect(writes, ['r0 c0']);
      expect(deleteRequests.single.current!.cell, const SemiItem(0, 0));
      expect(edits, isEmpty);
    });

    testWidgets('cut clears the replacement range returned by onDelete', (
      tester,
    ) async {
      final writes = <String>[];
      mockGridClipboard(write: (text) async => writes.add(text));
      await tester.pumpWidget(
        buildEditor(
          onDelete: (_) {
            return SemiGridSelection(
              current: SemiGridSelectionCurrent(
                cell: const SemiItem(1, 0),
                range: const SemiRectangle(x: 1, y: 0, width: 1, height: 1),
                rangeStack: const [],
              ),
              rows: const SemiCompactSelection.empty(),
              columns: const SemiCompactSelection.empty(),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      await focusClipboardCell(tester, 50);
      await sendClipboardShortcut(tester, LogicalKeyboardKey.keyX);

      expect(writes, ['r0 c0']);
      expect(edits.single.location, const SemiItem(1, 0));
      expect((edits.single.value as SemiTextCell).data, isEmpty);
    });

    for (final missingData in [false, true]) {
      testWidgets(
        missingData
            ? 'cut does not clear when source data is unavailable'
            : 'cut does not clear when the clipboard write fails',
        (tester) async {
          var writes = 0;
          var deleteRequests = 0;
          mockGridClipboard(
            write: (_) async {
              writes++;
              throw PlatformException(code: 'clipboard-unavailable');
            },
          );
          await tester.pumpWidget(
            buildEditor(
              cellsForSelection: missingData ? (_) => null : null,
              onDelete: (_) {
                deleteRequests++;
                return true;
              },
            ),
          );
          await tester.pumpAndSettle();
          await focusClipboardCell(tester, 50);
          await sendClipboardShortcut(tester, LogicalKeyboardKey.keyX);

          expect(writes, missingData ? 0 : 1);
          expect(deleteRequests, 0);
          expect(edits, isEmpty);
        },
      );
    }

    testWidgets(
      'single-cell paste reads the first data column with row markers',
      (tester) async {
        const cells = <SemiGridCell>[
          SemiTextCell(data: 'old', displayData: 'old'),
          SemiNumberCell(data: 1, displayData: '1'),
        ];
        mockGridClipboard(text: 'new text');
        await tester.pumpWidget(
          buildEditor(
            columnCount: cells.length,
            rowMarkers: const SemiRowMarkerOptions(width: 40),
            content: (item) => cells[item.col],
          ),
        );
        await tester.pumpAndSettle();
        await focusClipboardCell(tester, 70);
        await sendClipboardShortcut(tester, LogicalKeyboardKey.keyV);

        expect(edits.single.location, const SemiItem(0, 0));
        expect((edits.single.value as SemiTextCell).data, 'new text');
      },
    );

    testWidgets('batch paste reaches the last data column with row markers', (
      tester,
    ) async {
      const cells = <SemiGridCell>[
        SemiTextCell(data: 'old', displayData: 'old'),
        SemiNumberCell(data: 1, displayData: '1'),
      ];
      final pasteTargets = <SemiItem>[];
      mockGridClipboard(text: '42\toverflow');
      await tester.pumpWidget(
        buildEditor(
          columnCount: cells.length,
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          content: (item) => cells[item.col],
          onPaste: (target, data) {
            pasteTargets.add(target);
            expect(data, [
              ['42', 'overflow'],
            ]);
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();
      await focusClipboardCell(tester, 190);
      await sendClipboardShortcut(tester, LogicalKeyboardKey.keyV);

      expect(pasteTargets.single, const SemiItem(1, 0));
      expect(edits.single.location, const SemiItem(1, 0));
      expect((edits.single.value as SemiNumberCell).data, 42);
    });

    testWidgets('ctrl+a selects the whole table', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      final range = selectionLog.last.current!.range;
      expect(range.width, 6);
      expect(range.height, 200);
    });

    testWidgets('escape clears the selection', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(selectionLog.last.current, isNull);
    });

    testWidgets('typing a letter opens the editor with that letter', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('z'), findsOneWidget);
      expect(activationLog, contains('[1, 0]:z'));
    });

    testWidgets('enter in the editor commits the cell', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiTextCell(data: 'old', displayData: 'old')
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      // Open with forceEditMode via a typed character.
      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsNothing);
      expect(edits, hasLength(1));
      final value = edits.single.value as SemiTextCell;
      expect(value.data, 'z');
    });

    testWidgets('validateCell rejects the edit and sees business coordinates', (
      tester,
    ) async {
      final validations = <(SemiItem, SemiGridCell)>[];
      final finished = <SemiGridCell?>[];
      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          onFinishedEditing: (value, _) => finished.add(value),
          validateCell: (cell, newValue, prev) {
            validations.add((cell, newValue));
            return false;
          },
        ),
      );
      await tester.pumpAndSettle();

      // x=90 is mangled column 1 (the marker owns 0..40), i.e. business col 0.
      final gesture = await tester.startGesture(
        const Offset(90, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();

      expect(validations, isNotEmpty);
      expect(validations.first.$1, const SemiItem(0, 0));
      expect(
        validations.every((entry) => entry.$1 == const SemiItem(0, 0)),
        isTrue,
      );

      await tester.enterText(find.byType(EditableText), 'rejected');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(finished, [null]);
      expect(edits, isEmpty);
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('validateCell can rewrite the value before it commits', (
      tester,
    ) async {
      final rewritten = const SemiTextCell(data: 'rewritten', displayData: 'rewritten');
      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          validateCell: (cell, newValue, prev) => rewritten,
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(90, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'typed');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(edits, hasLength(1));
      // `_onCellsEdited` strips the marker column for the caller.
      expect(edits.single.location, const SemiItem(0, 0));
      expect(edits.single.value, rewritten);
    });

    testWidgets('provideEditor overrides the renderer with business coords', (
      tester,
    ) async {
      final provided = <SemiItem>[];
      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(width: 40),
          provideEditor: (cell, location) {
            provided.add(location);
            return SemiComponentEditor((_) => const Text('custom-editor'));
          },
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(90, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();

      // The editor resolves its provider on every build, so only the
      // coordinates matter here.
      expect(provided, isNotEmpty);
      expect(provided, everyElement(const SemiItem(0, 0)));
      expect(find.text('custom-editor'), findsOneWidget);
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('the overlay hands the activation source to custom editors', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          provideEditor: (cell, location) => SemiComponentEditor(
            (props) => Text('${props.activation.runtimeType}'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();
      expect(find.text('SemiKeyboardCellActivation'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SemiDataGridOverlayEditor), findsNothing);

      for (var i = 0; i < 2; i++) {
        final click = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await click.up();
        await tester.pumpAndSettle();
      }
      expect(find.text('SemiPointerCellActivation'), findsOneWidget);
    });

    testWidgets('navigating to a far cell scrolls it into view', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      // Select a cell in the first screenful.
      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell.row, 0);

      // ctrl+End → last cell.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell, const SemiItem(5, 199));

      // Without scrolling this point would still map to row 2; with the
      // scroller having moved to the bottom it maps near the last row.
      final after = await tester.startGesture(
        const Offset(150, 100),
        kind: PointerDeviceKind.mouse,
      );
      await after.up();
      await tester.pumpAndSettle();
      final row = selectionLog.last.current!.cell.row;
      expect(row, greaterThan(180));
    });

    testWidgets('ctrl+d fills the selection downward', (tester) async {
      await tester.pumpWidget(
        buildEditor(keybindings: const SemiKeybinds(downFill: true)),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
      }
      final range = selectionLog.last.current!.range;
      expect(range.height, 3);
      expect(edits, isEmpty);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(edits, hasLength(2));
      expect(edits.map((e) => e.location).toList(), [
        const SemiItem(0, 1),
        const SemiItem(0, 2),
      ]);
      expect((edits.first.value as SemiTextCell).data, 'r0 c0');
    });

    testWidgets('ctrl+r fills the selection rightward', (tester) async {
      await tester.pumpWidget(
        buildEditor(keybindings: const SemiKeybinds(rightFill: true)),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
      }
      expect(selectionLog.last.current!.range.width, 3);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(edits, hasLength(2));
      expect(edits.map((e) => e.location).toList(), [
        const SemiItem(1, 0),
        const SemiItem(2, 0),
      ]);
      expect((edits.first.value as SemiTextCell).data, 'r0 c0');
    });

    testWidgets('dragging from a selected cell grows the range', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.range.width, 1);

      // Press again on (0,0) and drag to (2, 3).
      final drag = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      await drag.moveTo(const Offset(250, 140));
      await tester.pumpAndSettle();
      await drag.up();
      await tester.pumpAndSettle();

      final range = selectionLog.last.current!.range;
      expect(range.x, 0);
      expect(range.y, 0);
      expect(range.width, 3);
      expect(range.height, 4);
      // The anchor cell does not move while dragging.
      expect(selectionLog.last.current!.cell, const SemiItem(0, 0));
    });

    testWidgets('autoscroll ramps up while the pointer sits on an edge', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      final drag = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();

      // Below the last row's body: y > height puts `scrollEdge` on +1.
      await drag.moveTo(const Offset(50, 410));
      await tester.pump();
      final before = selectionLog.last.current!.range.height;

      // The autoscroll ticker keeps scheduling frames, so `pumpAndSettle`
      // would never return; pump fixed durations instead.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await drag.up();
      await tester.pumpAndSettle();

      final after = selectionLog.last.current!.range.height;
      expect(after, greaterThan(before));
    });

    testWidgets('dragging the fill handle fills the range', (tester) async {
      await tester.pumpWidget(buildEditor(fillHandle: defaultFillHandle));
      await tester.pumpAndSettle();

      final select = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await select.up();
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell, const SemiItem(0, 0));

      // The handle sits on the bottom-right corner of cell (0,0):
      // x = 0 + 101 - 2, y = 32 + 33 - 2.
      final handle = await tester.startGesture(
        const Offset(99, 63),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      // Pressing the handle must not move the selection.
      expect(selectionLog.last.current!.cell, const SemiItem(0, 0));

      await handle.moveTo(const Offset(99, 200));
      await tester.pump();
      await handle.up();
      await tester.pumpAndSettle();

      expect(edits, hasLength(5));
      expect(edits.map((e) => e.location).toList(), [
        const SemiItem(0, 1),
        const SemiItem(0, 2),
        const SemiItem(0, 3),
        const SemiItem(0, 4),
        const SemiItem(0, 5),
      ]);
      expect((edits.first.value as SemiTextCell).data, 'r0 c0');
      // The selection grows to the filled range.
      expect(selectionLog.last.current!.range.height, 6);
    });

    testWidgets('onFillPattern can cancel the fill', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildEditor(
          fillHandle: defaultFillHandle,
          onFillPattern: (args) {
            called = true;
            args.preventDefault();
          },
        ),
      );
      await tester.pumpAndSettle();

      final select = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await select.up();
      await tester.pumpAndSettle();

      final handle = await tester.startGesture(
        const Offset(99, 63),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await handle.moveTo(const Offset(99, 200));
      await tester.pump();
      await handle.up();
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(edits, isEmpty);
    });

    testWidgets('clicking a header selects that column', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 15),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog, isNotEmpty);
      expect(selectionLog.last.columns.toArray(), [1]);
      expect(selectionLog.last.current, isNull);
    });

    testWidgets('dragging a header edge resizes the column', (tester) async {
      final startLog = <double>[];
      final resizeLog = <double>[];
      final endLog = <double>[];

      await tester.pumpWidget(
        buildEditor(
          onColumnResizeStart: (c, w, i, g) => startLog.add(w),
          onColumnResize: (c, w, i, g) => resizeLog.add(w),
          onColumnResizeEnd: (c, w, i, g) => endLog.add(w),
        ),
      );
      await tester.pumpAndSettle();

      // The right edge of column 0 is at x = 100; the 5px buffer starts at 95.
      final drag = await tester.startGesture(
        const Offset(97, 15),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      // `bounds.width` carries the +1 grid line (`data-grid-lib.ts`), which is
      // what upstream reports from `onColumnResizeStart` too.
      expect(startLog, [101]);

      await drag.moveTo(const Offset(170, 15));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(resizeLog, isNotEmpty);
      expect(resizeLog.last, 170);
      expect(endLog, [170]);
      // The resize press is an edge press, so it must not change the selection.
      expect(selectionLog, isEmpty);
    });

    testWidgets('resize callbacks report user columns with markers', (
      tester,
    ) async {
      final titles = <String>[];
      final indices = <int>[];
      final widths = <double>[];

      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(),
          onColumnResizeStart: (column, width, col, _) {
            titles.add(column.title);
            indices.add(col);
            widths.add(width);
          },
          onColumnResize: (column, width, col, _) {
            titles.add(column.title);
            indices.add(col);
            widths.add(width);
          },
          onColumnResizeEnd: (column, width, col, _) {
            titles.add(column.title);
            indices.add(col);
            widths.add(width);
          },
        ),
      );
      await tester.pumpAndSettle();

      // The marker column occupies x=0..36 (200 rows); column 0 runs from
      // x=36 to 136 and its resize edge starts five pixels before x=136.
      final drag = await tester.startGesture(
        const Offset(133, 15),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await drag.moveTo(const Offset(186, 15));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(titles, everyElement('C0'));
      expect(indices, everyElement(0));
      expect(widths.first, 101); // bounds.width carries the +1 grid line.
      expect(widths.last, 150);
    });

    testWidgets('dragging a header reorders the column', (tester) async {
      final moved = <(int, int)>[];
      await tester.pumpWidget(
        buildEditor(onColumnMoved: (from, to) => moved.add((from, to))),
      );
      await tester.pumpAndSettle();

      // Press in the middle of column 1's header (not on either edge).
      final drag = await tester.startGesture(
        const Offset(150, 15),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(moved, isEmpty);

      await drag.moveTo(const Offset(50, 15));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(moved, [(1, 0)]);
    });

    testWidgets('a plain header click does not reorder', (tester) async {
      final moved = <(int, int)>[];
      await tester.pumpWidget(
        buildEditor(onColumnMoved: (from, to) => moved.add((from, to))),
      );
      await tester.pumpAndSettle();

      final click = await tester.startGesture(
        const Offset(150, 15),
        kind: PointerDeviceKind.mouse,
      );
      await click.up();
      await tester.pumpAndSettle();

      expect(moved, isEmpty);
      // The header click still selects the column.
      expect(selectionLog.last.columns.toArray(), [1]);
    });

    testWidgets('moving within the same column is not a reorder', (
      tester,
    ) async {
      final moved = <(int, int)>[];
      await tester.pumpWidget(
        buildEditor(onColumnMoved: (from, to) => moved.add((from, to))),
      );
      await tester.pumpAndSettle();

      final drag = await tester.startGesture(
        const Offset(150, 15),
        kind: PointerDeviceKind.mouse,
      );
      await drag.moveTo(const Offset(190, 15));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(moved, isEmpty);
    });

    testWidgets('onColumnProposeMove can reject a move', (tester) async {
      final moved = <(int, int)>[];
      await tester.pumpWidget(
        buildEditor(
          onColumnMoved: (from, to) => moved.add((from, to)),
          onColumnProposeMove: (from, to) => false,
        ),
      );
      await tester.pumpAndSettle();

      final drag = await tester.startGesture(
        const Offset(150, 15),
        kind: PointerDeviceKind.mouse,
      );
      await drag.moveTo(const Offset(50, 15));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(moved, isEmpty);
    });

    testWidgets('row markers add a leading column that selects the row', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(rowMarkers: const SemiRowMarkerOptions()),
      );
      await tester.pumpAndSettle();

      // The marker column is 36px wide for >100 rows.
      final gesture = await tester.startGesture(
        const Offset(18, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog.last.rows.toArray(), [0]);
      expect(selectionLog.last.current, isNull);
      // A normal cell click leaves the row selection alone.
      final other = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await other.up();
      await tester.pumpAndSettle();
      // Clicking a body cell replaces the selection and drops the row set.
      expect(selectionLog.last.rows.length, 0);
      expect(selectionLog.last.current!.cell, const SemiItem(1, 0));
    });

    testWidgets('user column coordinates exclude the marker column', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(rowMarkers: const SemiRowMarkerOptions()),
      );
      await tester.pumpAndSettle();

      // x = 150 lands on the *second* user column once the 36px marker column
      // is in front of it, but `onGridSelectionChange` reports user indices.
      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog.last.current!.cell, const SemiItem(1, 0));
    });

    testWidgets('clicking the header marker selects every row', (tester) async {
      await tester.pumpWidget(
        buildEditor(rowMarkers: const SemiRowMarkerOptions()),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(18, 15),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog.last.rows.length, 200);
      expect(selectionLog.last.current, isNull);

      // Clicking it again clears the rows.
      final again = await tester.startGesture(
        const Offset(18, 15),
        kind: PointerDeviceKind.mouse,
      );
      await again.up();
      await tester.pumpAndSettle();
      expect(selectionLog.last.rows.length, 0);
    });

    testWidgets('dragging a row by its marker calls onRowMoved', (
      tester,
    ) async {
      final moved = <(int, int)>[];
      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(),
          onRowMoved: (from, to) => moved.add((from, to)),
        ),
      );
      await tester.pumpAndSettle();

      final drag = await tester.startGesture(
        const Offset(18, 45),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();

      await drag.moveTo(const Offset(18, 140));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(moved, [(0, 3)]);
    });

    testWidgets('row markers of kind number are not clickable rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          rowMarkers: const SemiRowMarkerOptions(
            kind: SemiRowMarkerKind.number,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(18, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      // `rowMarkers === "number"` bails out of the marker branch entirely
      // (`data-editor.tsx:1856`), so nothing is selected.
      expect(selectionLog, isEmpty);
    });

    testWidgets('hover animation runs and then settles', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => SemiTextCell(
            data: 'hover ${item.col}-${item.row}',
            displayData: 'hover',
            hoverEffect: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(2, 0));
      await tester.pump();

      // The ramp is running, so `pumpAndSettle` would hang; step manually.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(tester.takeException(), isNull);

      await gesture.moveTo(const Offset(380, 280));
      await gesture.up();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }

      // The ticker must stop once everything has settled, otherwise this
      // never returns.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('number cells open the number editor and commit', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiNumberCell(data: 1234.5, displayData: '1,234.5')
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      // Second click activates the already-selected cell.
      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('1,234.5'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '42');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(edits, hasLength(1));
      final value = edits.single.value as SemiNumberCell;
      expect(value.data, 42);
      expect(value.displayData, '42');
    });

    testWidgets('uri cells show the preview until the pencil is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiUriCell(
                  data: 'https://example.com/a',
                  displayData: 'example.com/a',
                )
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(find.byType(EditableText), findsNothing);
      expect(find.text('example.com/a'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('https://example.com/a'), findsOneWidget);
    });

    testWidgets('bubble cells open a read-only editor', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiBubbleCell(data: ['alpha', 'beta'])
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(find.byType(EditableText), findsNothing);
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    });

    testWidgets('a cell without an editor still opens the overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiImageCell(data: ['a.png'])
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      // `editorProvider === undefined` renders an empty clip region rather
      // than failing (`data-grid-overlay-editor.tsx:164-173`).
      expect(tester.takeException(), isNull);
      expect(find.byType(SemiDataGridOverlayEditor), findsOneWidget);
    });

    testWidgets('clicking the trailing row appends and focuses it', (
      tester,
    ) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          rows: 3,
          trailingRowOptions: const SemiTrailingRowOptions(hint: 'New row'),
          onRowAppended: () {
              appended++;
              return null;
            },
        ),
      );
      await tester.pumpAndSettle();

      // The trailing row sits right after the three user rows:
      // y = 32 (header) + 3 * 32 = 128.
      final gesture = await tester.startGesture(
        const Offset(50, 140),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(appended, 1);
      expect(selectionLog.last.current!.cell, const SemiItem(0, 3));
      // `focusOnRowFromTrailingBlankRow` opens the editor in force-edit mode.
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('r3 c0'), findsOneWidget);
    });

    testWidgets('enter on the trailing row appends instead of editing', (
      tester,
    ) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          rows: 3,
          trailingRowOptions: const SemiTrailingRowOptions(),
          onRowAppended: () {
              appended++;
              return null;
            },
        ),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
      }
      expect(selectionLog.last.current!.cell, const SemiItem(0, 3));
      expect(appended, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(appended, 1);
    });

    testWidgets('typing on the trailing row does not open an editor', (
      tester,
    ) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          rows: 3,
          trailingRowOptions: const SemiTrailingRowOptions(),
          onRowAppended: () {
              appended++;
              return null;
            },
        ),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsNothing);
      expect(activationLog, isEmpty);
      expect(appended, 0);
    });

    testWidgets('tab in the last column appends a column', (tester) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          onColumnAppended: () {
            appended++;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
      }
      expect(selectionLog.last.current!.cell, const SemiItem(2, 0));
      expect(appended, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(appended, 1);
      // The editor closed and the new column is selected.
      expect(find.byType(EditableText), findsNothing);
      expect(selectionLog.last.current!.cell, const SemiItem(3, 0));
      expect(edits, hasLength(1));
    });

    testWidgets('the appended column can be targeted from the left', (
      tester,
    ) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          onColumnAppended: () {
            appended++;
            return 'left';
          },
        ),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(appended, 1);
      expect(selectionLog.last.current!.cell, const SemiItem(0, 0));
    });

    testWidgets('image cells open the overlay viewer', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiImageCell(data: ['https://example.com/a.png'])
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      // The test binding has no network, so the placeholder shows instead of
      // the decoded image.
      expect(find.text('image failed'), findsOneWidget);
    });

    testWidgets('drilldown cells open a read-only chip editor', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const SemiItem(1, 0)
              ? const SemiDrilldownCell(
                  data: [
                    SemiDrilldownCellData(text: 'Alpha'),
                    SemiDrilldownCellData(text: 'Beta'),
                  ],
                )
              : const SemiTextCell(data: 'x', displayData: 'x'),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      // Read-only: no input, just the chips.
      expect(find.byType(EditableText), findsNothing);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('loading and protected cells never open an overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => switch (item.row) {
            0 => const SemiLoadingCell(skeletonWidth: 40),
            1 => const SemiProtectedCell(),
            _ => const SemiTextCell(data: 'x', displayData: 'x'),
          },
        ),
      );
      await tester.pumpAndSettle();

      for (final row in [45, 77]) {
        for (var i = 0; i < 2; i++) {
          final gesture = await tester.startGesture(
            Offset(150, row.toDouble()),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.up();
          await tester.pumpAndSettle();
        }
        expect(find.byType(EditableText), findsNothing);
      }
    });

    testWidgets('row grouping changes which row a y maps to', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          rowGrouping: const SemiRowGroupingOptions(
            groups: [
              SemiRowGroup(headerIndex: 0, isCollapsed: false),
              SemiRowGroup(headerIndex: 3, isCollapsed: false),
            ],
            height: 60,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // y = 120 falls inside the second group header (32 + 60 .. 32 + 120),
      // which is grid row 1 — without grouping the same y is row 2.
      final gesture = await tester.startGesture(
        const Offset(150, 120),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog.last.current!.cell.row, 1);
    });

    testWidgets('whole-column copy spans the grouped display rows', (
      tester,
    ) async {
      final requested = <SemiRectangle>[];
      mockGridClipboard(write: (_) async {});
      await tester.pumpWidget(
        buildEditor(
          rows: 200,
          columnCount: 2,
          rowGrouping: const SemiRowGroupingOptions(
            groups: [
              SemiRowGroup(headerIndex: 0, isCollapsed: true),
              SemiRowGroup(headerIndex: 3, isCollapsed: false),
            ],
            height: 60,
          ),
          cellsForSelection: (region) {
            requested.add(region);
            return [
              for (
                var y = region.y.toInt();
                y < region.y + region.height;
                y++
              )
                [
                  for (
                    var x = region.x.toInt();
                    x < region.x + region.width;
                    x++
                  )
                    SemiTextCell(data: '$x/$y', displayData: '$x/$y'),
                ],
            ];
          },
        ),
      );
      await tester.pumpAndSettle();

      // The header owns y in [0, 32); clicking it selects column 0 and focuses
      // the grid, which is what `semiCopy` needs to run.
      final gesture = await tester.startGesture(
        const Offset(50, 16),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await sendClipboardShortcut(tester, LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();

      final displayRows =
          tester.widget<SemiDataGrid>(find.byType(SemiDataGrid)).props.rows;
      // The collapsed group hides its content rows, so the grid has fewer
      // display rows than the 200 data rows the caller declared.
      expect(displayRows, lessThan(200));
      expect(requested, hasLength(1));
      expect(requested.single.y, 0);
      expect(
        requested.single.height,
        displayRows,
        reason: 'a whole-column copy must span the grouped display rows',
      );
    });

    testWidgets('shrinking the grid clears an out-of-bounds selection', (
      tester,
    ) async {
      SemiGridSelection rendered() => tester
          .widget<SemiDataGrid>(find.byType(SemiDataGrid))
          .props
          .selection;

      await tester.pumpWidget(buildEditor(rows: 4, columnCount: 2));
      await tester.pumpAndSettle();

      // Header 32 + 3 rows of 32 + half a row lands on row 3.
      final gesture = await tester.startGesture(
        const Offset(50, 144),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(rendered().current!.cell, const SemiItem(0, 3));

      await tester.pumpWidget(buildEditor(rows: 2, columnCount: 2));
      await tester.pumpAndSettle();

      expect(rendered().current, isNull);
      expect(rendered().columns.isEmpty, isTrue);
      expect(rendered().rows.isEmpty, isTrue);
    });

    testWidgets('touch dragging scrolls both axes without selecting', (
      tester,
    ) async {
      final regions = <SemiVisibleRegion>[];
      await tester.pumpWidget(
        buildEditor(
          rows: 200,
          columnCount: 6,
          onVisibleRegionChanged: (region, _) => regions.add(region),
        ),
      );
      await tester.pumpAndSettle();
      final initial = regions.last;

      final gesture = await tester.startGesture(
        const Offset(200, 200),
        kind: PointerDeviceKind.touch,
      );
      // Finger up scrolls the rows down; finger left scrolls the columns right.
      await gesture.moveBy(const Offset(0, -120));
      await tester.pump();
      await gesture.moveBy(const Offset(-80, 0));
      await tester.pump();

      final afterDrag = regions.last;
      expect(afterDrag.y, greaterThan(initial.y));
      expect(afterDrag.x, greaterThan(initial.x));
      expect(selectionLog, isEmpty);
      expect(find.byType(SemiDataGridOverlayEditor), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();

      // A drag is a scroll, never a tap: no selection and no editor.
      expect(selectionLog, isEmpty);
      expect(find.byType(SemiDataGridOverlayEditor), findsNothing);
    });

    testWidgets('a touch tap still selects on release', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.touch,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog.last.current!.cell, const SemiItem(1, 0));
    });

    testWidgets('a flung touch keeps scrolling after release', (tester) async {
      final regions = <SemiVisibleRegion>[];
      await tester.pumpWidget(
        buildEditor(
          rows: 200,
          onVisibleRegionChanged: (region, _) => regions.add(region),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(200, 300),
        kind: PointerDeviceKind.touch,
      );
      await gesture.moveBy(const Offset(0, -40));
      await gesture.moveBy(const Offset(0, -60));
      await tester.pump();
      final afterDrag = regions.last;

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        regions.last.y,
        greaterThan(afterDrag.y),
        reason: 'inertia must keep scrolling after the finger lifts',
      );

      await tester.pumpAndSettle();
      expect(regions.last.y, greaterThan(afterDrag.y));
      expect(selectionLog, isEmpty);
    });

    testWidgets('an async getCellsForSelection still drives copy', (
      tester,
    ) async {
      final writes = <String>[];
      mockGridClipboard(write: (text) async => writes.add(text));
      await tester.pumpWidget(
        buildEditor(
          rows: 2,
          columnCount: 2,
          cellsForSelection: (region) async => [
            for (
              var y = region.y.toInt();
              y < region.y + region.height;
              y++
            )
              [
                for (
                  var x = region.x.toInt();
                  x < region.x + region.width;
                  x++
                )
                  SemiTextCell(data: 'async $x/$y', displayData: 'async $x/$y'),
              ],
          ],
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await sendClipboardShortcut(tester, LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();

      expect(writes, ['async 0/0']);
    });

    testWidgets('unsized columns resolve their width from an async sample', (
      tester,
    ) async {
      final controller = SemiDataEditorController();
      final wide = 'x' * 400;
      await tester.pumpWidget(
        buildEditor(
          controller: controller,
          rows: 4,
          columnCount: 2,
          unsizedColumns: true,
          cellsForSelection: (region) async => [
            for (
              var y = region.y.toInt();
              y < region.y + region.height;
              y++
            )
              [
                for (
                  var x = region.x.toInt();
                  x < region.x + region.width;
                  x++
                )
                  SemiTextCell(data: wide, displayData: wide),
              ],
          ],
        ),
      );
      await tester.pumpAndSettle();

      // `semiDefaultCellMeasure` (150) + the one-pixel grid line is the
      // placeholder; the resolved sample measures up to `maxColumnWidth`.
      final width = controller.getBounds(0, 0)!.width;
      expect(width, greaterThan(151));
    });

    testWidgets('unsized columns are measured and become hit-testable', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(columnCount: 3, unsizedColumns: true, minColumnWidth: 100),
      );
      await tester.pumpAndSettle();

      // Without the sizer these columns would have width 0 and every click
      // would land out of bounds.
      final first = await tester.startGesture(
        const Offset(10, 45),
        kind: PointerDeviceKind.mouse,
      );
      await first.up();
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell.col, 0);

      // `minColumnWidth` floors the measurement to 100, so three columns end
      // at x = 300 — past that the click falls out of bounds. The 150px
      // `defaultSize` placeholder would have covered this point instead.
      final past = await tester.startGesture(
        const Offset(350, 45),
        kind: PointerDeviceKind.mouse,
      );
      await past.up();
      await tester.pumpAndSettle();
      expect(selectionLog.last.current, isNull);
    });

    testWidgets('scrollOffsetY starts the grid scrolled down', (tester) async {
      await tester.pumpWidget(buildEditor(scrollOffsetY: 640));
      await tester.pumpAndSettle();

      // 640 / 32 = 20 rows in, so y = 45 is grid row 20 rather than row 0.
      final gesture = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectionLog.last.current!.cell.row, 20);
    });

    testWidgets('search opens with the binding, finds matches and closes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(keybindingsOverride: const SemiKeybinds(search: true)),
      );
      await tester.pumpAndSettle();

      final cell = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await cell.up();
      await tester.pumpAndSettle();

      // `primary+f` opens the bar (`keybindingDefaults.search`).
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('Type to search'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'r1 c2');
      await tester.pumpAndSettle();

      expect(find.text('1 result'), findsOneWidget);

      // Enter advances to the first (and only) match.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('1 of 1 result'), findsOneWidget);

      // Escape closes the bar.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Type to search'), findsNothing);
    });

    testWidgets('the search bar slides out over 150ms before unmounting', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(keybindingsOverride: const SemiKeybinds(search: true)),
      );
      await tester.pumpAndSettle();

      final cell = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await cell.up();
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // `gdg-search-fadein` has run to `translateX(0)`
      // (`data-grid-search-style.tsx:86-94`).
      Offset offsetOf() {
        final transform = tester.widget<Transform>(
          find
              .descendant(
                of: find.byType(SemiSearchBar),
                matching: find.byType(Transform),
              )
              .first,
        );
        final t = transform.transform.getTranslation();
        return Offset(t.x, t.y);
      }

      expect(offsetOf(), Offset.zero);

      // Escape starts `gdg-search-fadeout` (`:78-84`), but the bar is still
      // mounted — `isAnimatingOut` holds it for the 150ms duration.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(SemiSearchBar), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 75));
      final mid = offsetOf();
      expect(mid.dx, greaterThan(0));
      expect(mid.dx, lessThan(400));

      // The owner's timer unmounts it once the outro is done.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SemiSearchBar), findsNothing);
    });

    testWidgets(
      'the bar is hidden from focus and semantics while it slides out',
      (tester) async {
        await tester.pumpWidget(
          buildEditor(keybindingsOverride: const SemiKeybinds(search: true)),
        );
        await tester.pumpAndSettle();

        final cell = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await cell.up();
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(find.byType(ExcludeFocus, skipOffstage: false), findsWidgets);
        final shown = tester.widget<ExcludeFocus>(
          find
              .descendant(
                of: find.byType(SemiSearchBar),
                matching: find.byType(ExcludeFocus),
              )
              .first,
        );
        expect(shown.excluding, isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        final hidden = tester.widget<ExcludeFocus>(
          find
              .descendant(
                of: find.byType(SemiSearchBar),
                matching: find.byType(ExcludeFocus),
              )
              .first,
        );
        expect(hidden.excluding, isTrue);
      },
    );

    testWidgets('a tinted trailing row does not disturb appending', (
      tester,
    ) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          rows: 3,
          trailingRowOptions: const SemiTrailingRowOptions(
            hint: 'New row',
            tint: true,
          ),
          onRowAppended: () {
              appended++;
              return null;
            },
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(50, 140),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(appended, 1);
      expect(selectionLog.last.current!.cell, const SemiItem(0, 3));
    });

    testWidgets('the reported region is in user coordinates', (tester) async {
      final regions = <SemiVisibleRegion>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const SemiRowMarkerOptions(),
          // 100px scrolls past the 36px marker column and all of C0, so the
          // first visible column is C1 — user index 1, mangled index 2.
          scrollOffsetX: 100,
          onVisibleRegionChanged: (region, _) => regions.add(region),
        ),
      );
      await tester.pumpAndSettle();

      expect(regions, isNotEmpty);
      final region = regions.last;
      // `newRegion.x = region.x - rowMarkerOffset` (`data-editor.tsx:2630`).
      expect(region.x, 1);
      // `cellXOffset = visibleRegion.x + rowMarkerOffset` (`:1190`) — the
      // grid still draws in mangled space, so the two must differ by the
      // marker offset.
      expect(region.x + 1, 2);
      // `tx`/`ty` ride along on the region (`data-editor.tsx:2634-2635`).
      expect(region.translateX, isNotNull);
      expect(region.translateY, isNotNull);
    });

    testWidgets('the reported region drops the trailing blank row', (
      tester,
    ) async {
      final regions = <SemiVisibleRegion>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          rows: 5,
          trailingRowOptions: const SemiTrailingRowOptions(hint: 'New row'),
          onVisibleRegionChanged: (region, _) => regions.add(region),
        ),
      );
      await tester.pumpAndSettle();

      expect(regions, isNotEmpty);
      final region = regions.last;
      // The window covers all 6 mangled rows (5 data + the trailing row), but
      // `height: region.height - 1` (`data-editor.tsx:2633`) reports only the
      // data rows to the consumer.
      expect(region.height, 5);
      expect(region.y + region.height, 5);
    });

    testWidgets('freezeRegions share the region\'s user coordinates', (
      tester,
    ) async {
      final reports = <(SemiVisibleRegion, SemiVisibleRegionExtras)>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rows: 200,
          rowMarkers: const SemiRowMarkerOptions(),
          freezeTrailingRows: 2,
          strict: true,
          // Scrolled so the first visible *user* column is 1 while the
          // mangled index is 2 — the two spaces the guard mixes.
          scrollOffsetX: 100,
          onVisibleRegionChanged: (region, extras) =>
              reports.add((region, extras)),
        ),
      );
      await tester.pumpAndSettle();

      expect(reports, isNotEmpty);
      final (region, extras) = reports.last;

      // `freezeRegions.push({ x: region.x - rowMarkerOffset, ... })`
      // (`data-editor.tsx:2613`) uses the *same* strip that becomes
      // `newRegion.x` (`:2630`), so the two agree by construction. Keeping
      // `x` in mangled space would shift the rect one column right and the
      // `pointInRect` rescue in `_isOutsideVisibleArea` would miss.
      final trailing = extras.freezeRegions;
      expect(trailing, hasLength(1));
      expect(trailing.single.x, region.x.toDouble());
      expect(trailing.single.y, 198);
      expect(trailing.single.height, 2);

      // The rescue actually works: the pinned rows are outside the scrolled
      // window but still reach the consumer instead of a loading cell.
      final seen = <SemiItem>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rows: 200,
          rowMarkers: const SemiRowMarkerOptions(),
          freezeTrailingRows: 2,
          strict: true,
          scrollOffsetX: 100,
          content: (item) {
            seen.add(item);
            return SemiTextCell(
              data: 'cell-${item.col}-${item.row}',
              displayData: 'cell-${item.col}-${item.row}',
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Row 198 sits well below `region.y + region.height`, so without the
      // freeze rect the guard would hand back a loading cell.
      expect(seen, contains(const SemiItem(1, 198)));
      expect(seen, contains(const SemiItem(1, 199)));
    });

    testWidgets('forceStrict does not blank the first visible column', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const SemiRowMarkerOptions(),
          scrollOffsetX: 100,
          content: (item) => SemiTextCell(
            data: 'cell-${item.col}-${item.row}',
            displayData: 'cell-${item.col}-${item.row}',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The accessibility tree always queries with `forceStrict`
      // (`_cellSemantics`), so this is where the guard bites. With `x` still
      // in mangled space the guard read `2 > 1` and replaced C1 with a
      // loading cell.
      expect(find.bySemanticsLabel('cell-1-0'), findsOneWidget);
      // ...and the column just off the left edge stays hidden.
      expect(find.bySemanticsLabel('cell-0-0'), findsNothing);
      handle.dispose();
    });

    testWidgets('spanRangeBehavior allowPartial stops a keyboard grow', (
      tester,
    ) async {
      final spanning = const SemiTextCell(
        data: 'wide',
        displayData: 'wide',
        span: (start: 0, end: 3),
      );
      Future<SemiRectangle> grow(SemiSpanRangeBehavior behavior) async {
        final log = <SemiRectangle>[];
        await tester.pumpWidget(
          buildEditor(
            columnCount: 6,
            spanRangeBehavior: behavior,
            content: (item) => item == const SemiItem(1, 0)
                ? spanning
                : const SemiTextCell(data: 'x', displayData: 'x'),
            cellsForSelection: (region) => [
              [
                for (var x = region.x.toInt(); x < region.x + region.width; x++)
                  if (x == 1)
                    spanning
                  else
                    const SemiTextCell(data: 'x', displayData: 'x'),
              ],
            ],
          ),
        );
        await tester.pumpAndSettle();

        final start = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await start.up();
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();

        log.add(selectionLog.last.current!.range);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        return log.single;
      }

      // `"allowPartial"` short-circuits `expandSelection`
      // (`data-editor-fns.ts:13`), so the drag stops at column 2.
      final partial = await grow(SemiSpanRangeBehavior.allowPartial);
      expect(partial.x, 1);
      expect(partial.width, 2);

      // The default keeps growing until the span is fully covered
      // (`data-editor-fns.ts:5-98`).
      final grown = await grow(SemiSpanRangeBehavior.standard);
      expect(grown.x, 0);
      expect(grown.width, 4);
    });

    testWidgets('spanRangeBehavior allowPartial stops a drag growing', (
      tester,
    ) async {
      // The drag path expands in the editor's own `_setGridSelection`
      // (`_dragSelect` -> `setCurrent(expand: true)`), not through
      // `SemiKeyHandler`, so it covers the other of the port's two
      // expansion points.
      final spanning = const SemiTextCell(
        data: 'wide',
        displayData: 'wide',
        span: (start: 0, end: 3),
      );
      Future<SemiRectangle> drag(SemiSpanRangeBehavior behavior) async {
        await tester.pumpWidget(
          buildEditor(
            columnCount: 6,
            spanRangeBehavior: behavior,
            content: (item) => item.row == 0 && item.col <= 3
                ? spanning
                : const SemiTextCell(data: 'x', displayData: 'x'),
            cellsForSelection: (region) => [
              [
                for (var x = region.x.toInt(); x < region.x + region.width; x++)
                  if (x <= 3)
                    spanning
                  else
                    const SemiTextCell(data: 'x', displayData: 'x'),
              ],
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Select (0,0)...
        final first = await tester.startGesture(
          const Offset(50, 45),
          kind: PointerDeviceKind.mouse,
        );
        await first.up();
        await tester.pumpAndSettle();

        // ...then drag from it to (1,0), which only half-covers the span.
        final dragGesture = await tester.startGesture(
          const Offset(50, 45),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        await dragGesture.moveTo(const Offset(150, 45));
        await tester.pumpAndSettle();
        await dragGesture.up();
        await tester.pumpAndSettle();

        final range = selectionLog.last.current!.range;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        return range;
      }

      // Without the prop the range grows to swallow the whole span.
      final grown = await drag(SemiSpanRangeBehavior.standard);
      expect(grown.x, 0);
      expect(grown.width, 4);

      // `"allowPartial"` stops at the dragged edge.
      final partial = await drag(SemiSpanRangeBehavior.allowPartial);
      expect(partial.x, 0);
      expect(partial.width, 2);
    });

    testWidgets(
      'scanned matches are painted and reported in user coordinates',
      (tester) async {
        const match = SemiItem(1, 2);
        const neighbor = SemiItem(2, 2);
        final reported = <(List<SemiItem>, int)>[];
        final fills = <SemiItem, Color?>{};
        await tester.pumpWidget(
          buildEditor(
            rows: 4,
            columnCount: 3,
            rowMarkers: const SemiRowMarkerOptions(),
            theme: searchTheme,
            keybindingsOverride: const SemiKeybinds(search: true),
            onSearchResultsChanged: (results, navIndex) =>
                reported.add((results, navIndex)),
            drawCell: (args, draw) {
              fills[SemiItem(args.col, args.row)] = args.cellFillColor;
              draw();
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(fills[match], searchTheme.bgCell);

        await tester.tapAt(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'r2 c1');
        await tester.pumpAndSettle();
        expect(fills[match], searchTheme.bgSearchResult);
        expect(fills[neighbor], searchTheme.bgCell);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        // Both the draw hook and the navigation callback expose marker-free
        // coordinates even though the scanner and painter include the marker.
        final (results, navIndex) = reported.last;
        expect(results, [match]);
        expect(navIndex, 0);
      },
      variant: desktopSearch,
    );

    testWidgets('external search values update the input and scanned matches', (
      tester,
    ) async {
      const first = SemiItem(1, 1);
      const second = SemiItem(0, 2);
      final values = <String>[];
      final fills = <SemiItem, Color?>{};
      final query = ValueNotifier('r1 c1');
      addTearDown(query.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<String>(
          valueListenable: query,
          builder: (_, value, _) => buildEditor(
            rows: 4,
            columnCount: 3,
            theme: searchTheme,
            showSearch: true,
            searchValue: value,
            onSearchValueChange: values.add,
            drawCell: (args, draw) {
              fills[SemiItem(args.col, args.row)] = args.cellFillColor;
              draw();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byType(EditableText);
      expect(tester.widget<EditableText>(input).controller.text, 'r1 c1');
      expect(find.text('1 result'), findsOneWidget);
      expect(fills[first], searchTheme.bgSearchResult);
      expect(fills[second], searchTheme.bgCell);
      expect(values, isEmpty);

      query.value = 'r2 c0';
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(input).controller.text, 'r2 c0');
      expect(find.text('1 result'), findsOneWidget);
      expect(fills[first], searchTheme.bgCell);
      expect(fills[second], searchTheme.bgSearchResult);
      expect(values, isEmpty);
    }, variant: desktopSearch);

    testWidgets('controlled results drive painting, count, and navigation', (
      tester,
    ) async {
      const scanMatch = SemiItem(1, 0);
      const first = SemiItem(2, 2);
      const second = SemiItem(0, 1);
      const third = SemiItem(1, 3);
      const replacement = SemiItem(2, 3);
      const initialResults = [first, second, third];
      final results = ValueNotifier<List<SemiItem>>(initialResults);
      addTearDown(results.dispose);
      final reported = <(List<SemiItem>, int)>[];
      final fills = <SemiItem, Color?>{};

      await tester.pumpWidget(
        ValueListenableBuilder<List<SemiItem>>(
          valueListenable: results,
          builder: (_, matches, _) => buildEditor(
            rows: 4,
            columnCount: 3,
            rowMarkers: const SemiRowMarkerOptions(),
            theme: searchTheme,
            showSearch: true,
            searchValue: 'r0 c1',
            searchResults: matches,
            onSearchResultsChanged: (items, index) =>
                reported.add((items, index)),
            drawCell: (args, draw) {
              fills[SemiItem(args.col, args.row)] = args.cellFillColor;
              draw();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // This query would find only scanMatch; the supplied cells and count
      // must win instead, with the row-marker offset applied only to painting.
      expect(find.text('3 results'), findsOneWidget);
      expect(fills[scanMatch], searchTheme.bgCell);
      for (final match in initialResults) {
        expect(fills[match], searchTheme.bgSearchResult);
      }
      expect(selectionLog, isEmpty);

      Finder resultButton(String label) => find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == label,
      );
      final next = resultButton('Next Result');
      final previous = resultButton('Previous Result');
      Future<void> step(Finder button, int index) async {
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('${index + 1} of 3 results'), findsOneWidget);
        expect(reported.last.$1, initialResults);
        expect(reported.last.$2, index);
      }

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(find.text('3 of 3 results'), findsOneWidget);
      expect(reported.last.$1, initialResults);
      expect(reported.last.$2, 2);

      await step(next, 0);
      await step(previous, 2);
      await step(next, 0);

      results.value = const [replacement];
      await tester.pumpAndSettle();
      expect(find.textContaining('1 result'), findsOneWidget);
      expect(fills[replacement], searchTheme.bgSearchResult);
      for (final match in initialResults) {
        expect(fills[match], searchTheme.bgCell);
      }
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(reported.last.$1, [replacement]);
      expect(reported.last.$2, 0);

      results.value = const [];
      await tester.pumpAndSettle();
      expect(fills[replacement], searchTheme.bgCell);
      expect(fills[scanMatch], searchTheme.bgCell);
      expect(tester.widget<IconButton>(previous).onPressed, isNull);
      expect(tester.widget<IconButton>(next).onPressed, isNull);
      expect(selectionLog, isEmpty);
    }, variant: desktopSearch);

    testWidgets('controlled results cancel the pending internal batches', (
      tester,
    ) async {
      final results = ValueNotifier<List<SemiItem>?>(null);
      addTearDown(results.dispose);
      final batches = <int>[];
      const externalMatch = SemiItem(2, 1);

      await tester.pumpWidget(
        ValueListenableBuilder<List<SemiItem>?>(
          valueListenable: results,
          builder: (_, matches, _) => buildEditor(
            showSearch: true,
            searchValue: 'c0',
            searchResults: matches,
            onSearchResultsChanged: (hits, _) => batches.add(hits.length),
          ),
        ),
      );
      expect(batches, [10], reason: 'only the initial scan batch has run');

      results.value = const [externalMatch];
      await tester.pump();
      await tester.pumpAndSettle();

      expect(batches, [
        10,
      ], reason: 'the remaining scan batches were cancelled');
      expect(find.text('1 result'), findsOneWidget);
      expect(
        tester
            .widget<SemiDataGrid>(find.byType(SemiDataGrid))
            .props
            .prelightCells,
        [externalMatch],
      );
    });

    testWidgets('hidden controlled matches paint without selecting a cell', (
      tester,
    ) async {
      const matches = [SemiItem(2, 2), SemiItem(0, 1), SemiItem(1, 3)];
      final showSearch = ValueNotifier(false);
      addTearDown(showSearch.dispose);
      final fills = <SemiItem, Color?>{};

      await tester.pumpWidget(
        ValueListenableBuilder<bool>(
          valueListenable: showSearch,
          builder: (_, show, _) => buildEditor(
            rows: 4,
            columnCount: 3,
            rowMarkers: const SemiRowMarkerOptions(),
            theme: searchTheme,
            showSearch: show,
            searchResults: matches,
            drawCell: (args, draw) {
              fills[SemiItem(args.col, args.row)] = args.cellFillColor;
              draw();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SemiSearchBar), findsNothing);
      for (final match in matches) {
        expect(fills[match], searchTheme.bgSearchResult);
      }
      expect(selectionLog, isEmpty);

      showSearch.value = true;
      await tester.pumpAndSettle();
      expect(find.text('3 results'), findsOneWidget);
      expect(selectionLog, isEmpty);
      await tester.tap(find.byTooltip('Previous Result'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 3 results'), findsOneWidget);
    }, variant: desktopSearch);

    testWidgets('search without a consumer moves the selection to the match', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const SemiRowMarkerOptions(),
          keybindingsOverride: const SemiKeybinds(search: true),
        ),
      );
      await tester.pumpAndSettle();

      final cell = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await cell.up();
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'r3 c2');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // `updateSelectedCell(col, row, false, false)` (`data-editor.tsx:3926`)
      // selects the match; the old port only scrolled to it. The runner's
      // column is mangled, and `onGridSelectionChange` reports marker-free
      // coordinates (`data-editor.tsx:1009`), so `r3 c2` lands on [2, 3].
      expect(selectionLog.last.current!.cell, const SemiItem(2, 3));
    });

    testWidgets('maxColumnAutoWidth caps auto-sized columns', (tester) async {
      // One very long cell so the measurement wants to run away; only the
      // auto-sizing cap keeps the column narrow.
      Future<double> widthWith(double? autoCap) async {
        await tester.pumpWidget(
          buildEditor(
            columnCount: 1,
            unsizedColumns: true,
            minColumnWidth: 10,
            maxColumnWidth: 500,
            maxColumnAutoWidth: autoCap,
            cellsForSelection: (region) => [
              [
                for (
                  var x = region.x.toInt();
                  x < region.x + region.width;
                  x++
                )
                  const SemiTextCell(
                    data: 'a very long piece of text that will not fit at all',
                    displayData:
                        'a very long piece of text that will not fit at all',
                  ),
              ],
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Click at x=150: lands in the column while it is wide, and falls
        // out of bounds entirely once the cap narrows it to 60px (which
        // logs nothing at all, hence the `isNotEmpty` guard).
        final past = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await past.up();
        await tester.pumpAndSettle();
        final reached =
            selectionLog.isNotEmpty && selectionLog.last.current != null;

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        return reached ? 200.0 : 60.0;
      }

      // No cap: `maxColumnAutoWidth` falls back to `maxColumnWidth` and the
      // long text is measured all the way out (`data-editor.tsx:924`).
      expect(await widthWith(null), 200.0);

      // With the cap the column stops at 60px, so the same click misses.
      expect(await widthWith(60), 60.0);
    });

    testWidgets('editorBloom grows the overlay past the cell', (tester) async {
      Future<(double, double)> bloomOf((double, double)? bloom) async {
        await tester.pumpWidget(
          buildEditor(columnCount: 3, editorBloom: bloom),
        );
        await tester.pumpAndSettle();

        // Two clicks on the same cell open the overlay.
        for (var i = 0; i < 2; i++) {
          final gesture = await tester.startGesture(
            const Offset(150, 45),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.up();
          await tester.pumpAndSettle();
        }
        expect(find.byType(SemiDataGridOverlayEditor), findsOneWidget);

        final overlay = tester.widget<SemiDataGridOverlayEditor>(
          find.byType(SemiDataGridOverlayEditor),
        );
        final positioned = tester.widget<Positioned>(
          find
              .descendant(
                of: find.byType(SemiDataGridOverlayEditor),
                matching: find.byType(Positioned),
              )
              .first,
        );
        // `left = target.x - bloomX` (`data-grid-overlay-editor.tsx:231-251`).
        final result = (
          overlay.target.x - (positioned.left ?? 0),
          overlay.target.y - (positioned.top ?? 0),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        return result;
      }

      // The default bloom is [1, 1].
      expect(await bloomOf(null), (1.0, 1.0));
      // ...and `editorBloom` overrides both axes.
      expect(await bloomOf((10, 20)), (10.0, 20.0));
    });

    testWidgets('a keyboard range grow expands exactly once', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          cellsForSelection: (region) {
            calls++;
            return [
              [
                for (
                  var x = region.x.toInt();
                  x < region.x + region.width;
                  x++
                )
                  const SemiTextCell(data: 'x', displayData: 'x'),
              ],
            ];
          },
        ),
      );
      await tester.pumpAndSettle();

      final start = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await start.up();
      await tester.pumpAndSettle();

      // The sizer and the click have already settled; count only the grow.
      calls = 0;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(selectionLog.last.current!.range.width, 2);
      // Two calls, both upstream's: the span probe in `adjustSelection`
      // (`data-editor.tsx:2929`) and the single `expandSelection` inside
      // `setGridSelection` (`:1000`). Expanding a second time in
      // `SemiKeyHandler` made this three.
      expect(calls, 2);
    });

    testWidgets('the overlay is pulled back inside when the cell is at the '
        'right edge', (tester) async {
      await tester.pumpWidget(buildEditor(columnCount: 4));
      await tester.pumpAndSettle();

      // Column 3 spans x=300..400 in the 400px-wide grid, so the overlay's
      // `minWidth` (cell width + bloom) no longer fits in the space to its
      // right. `useStayOnScreen` (`use-stay-on-screen.ts:40`) is what pulls
      // the box back until its far edge is 10px inside the viewport.
      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(350, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      expect(find.byType(SemiDataGridOverlayEditor), findsOneWidget);

      // The box must be *inside* the grid, not merely built: the Stack clips,
      // so an overflowing editor would be cut off rather than crash.
      final overlay = tester.getRect(find.byType(SemiDataGridOverlayEditor));
      final box = tester.getRect(
        find
            .descendant(
              of: find.byType(SemiDataGridOverlayEditor),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(box.left, greaterThanOrEqualTo(overlay.left));
      expect(box.right, lessThanOrEqualTo(overlay.right));
    });

    testWidgets('a column wider than the overlay cap does not blow up the '
        'constraints', (tester) async {
      // `maxColumnWidth` defaults to 500, so a column may legitimately be
      // wider than the overlay's own `max-width: 400px`. CSS lets
      // `min-width` win over `max-width` (`data-grid-overlay-editor-style.tsx`);
      // `BoxConstraints` asserts instead. Such a box cannot fit in the grid,
      // so only the assert is in scope here.
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          unsizedColumns: true,
          minColumnWidth: 450,
          maxColumnWidth: 500,
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        final gesture = await tester.startGesture(
          const Offset(50, 45),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      expect(find.byType(SemiDataGridOverlayEditor), findsOneWidget);
    });

    testWidgets('drawCell and drawHeader strip the row-marker column', (
      tester,
    ) async {
      final cells = <SemiItem>[];
      final headers = <SemiDrawHeaderArgs>[];

      // 3 columns + the marker = 4 mangled columns, all inside the 400px
      // viewport, so nothing is clipped away and the indices are exact.
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          rowMarkers: const SemiRowMarkerOptions(),
          drawCell: (args, draw) {
            cells.add(SemiItem(args.col, args.row));
            draw();
          },
          drawHeader: (args, draw) {
            headers.add(args);
            draw();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(cells, isNotEmpty);
      // `col - rowMarkerOffset` (`data-editor.tsx:1062`): mangled 1..3 must
      // arrive as 0..2. Without the strip the set would be {1,2,3}.
      expect(cells.map((i) => i.col).toSet(), {0, 1, 2});
      // The marker column is inner-only and never reaches a consumer
      // (`data-grid-render.cells.ts:545`), so -1 never shows up.
      expect(cells.any((i) => i.col < 0), isFalse);

      expect(headers, isNotEmpty);
      // `columnIndex - rowMarkerOffset` (`data-editor.tsx:1052`). The marker
      // column's own header lands on -1, exactly as upstream does.
      expect(headers.map((h) => h.columnIndex).toSet(), {-1, 0, 1, 2});
      // `getHeaderMenuBounds` (`data-grid-render.header.ts:289-297`).
      expect(headers.first.menuBounds.width, 30);
      expect(headers.first.rect.width, greaterThan(0));
    });

    testWidgets('the remaining data-editor callbacks all fire', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        buildEditor(
          onCellFocused: (item) => log.add('focus:$item'),
          onVisibleRegionChanged: (region, _) => log.add('region:${region.y}'),
          onFinishedEditing: (_, movement) => log.add('done'),
          onHeaderContextMenu: (col, _) => log.add('headerMenu:$col'),
          onMouseMove: (_) => log.add('move'),
        ),
      );
      await tester.pumpAndSettle();

      // The initial post-frame region pass.
      expect(log, contains('region:0'));

      final cell = await tester.startGesture(
        const Offset(150, 45),
        kind: PointerDeviceKind.mouse,
      );
      await cell.moveBy(const Offset(1, 0));
      await tester.pumpAndSettle();

      expect(log, contains('move'));
      expect(log, contains('focus:[1, 0]'));

      // Right-clicking a header reports the header context menu.
      final header = await tester.startGesture(
        const Offset(150, 15),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await header.up();
      await tester.pumpAndSettle();
      expect(log, contains('headerMenu:1'));

      // Opening and escaping the overlay reports the finish.
      for (var i = 0; i < 2; i++) {
        final second = await tester.startGesture(
          const Offset(150, 45),
          kind: PointerDeviceKind.mouse,
        );
        await second.up();
        await tester.pumpAndSettle();
      }
      expect(find.byType(EditableText), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(log, contains('done'));
    });

    testWidgets('a group header exposes the rename action', (tester) async {
      final renamed = <String>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          group: 'Team A',
          onGroupHeaderRenamed: (group, value) => renamed.add('$group=$value'),
        ),
      );
      await tester.pumpAndSettle();

      // Hovering the group header reveals its actions
      // (`data-grid-render.header.ts:218`).
      await tester.startGesture(
        const Offset(100, 15),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 200));

      // The single action sits 26px in from the right edge of the 300px-wide
      // group span (`getActionBoundsForGroup`).
      final action = await tester.startGesture(
        const Offset(285, 15),
        kind: PointerDeviceKind.mouse,
      );
      await action.up();
      await tester.pumpAndSettle();

      expect(find.byType(SemiGroupRename), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Team B');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(renamed, ['Team A=Team B']);
      expect(find.byType(SemiGroupRename), findsNothing);
    });

    testWidgets('exposes an accessibility tree for the visible cells', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(buildEditor(columnCount: 3));
      await tester.pumpAndSettle();

      // `data-grid.tsx:1769-1855`: a table of column headers plus one node
      // per visible row and cell.
      expect(find.bySemanticsLabel('Grid'), findsOneWidget);
      expect(find.bySemanticsLabel('Column headers'), findsOneWidget);
      expect(find.bySemanticsLabel('C0'), findsOneWidget);
      expect(find.bySemanticsLabel('C2'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 1'), findsOneWidget);
      expect(find.bySemanticsLabel('r0 c0'), findsOneWidget);

      // The row-marker column is hidden when it is not accessible
      // (`data-grid.tsx:1745-1748`); without markers nothing changes here.
      final gesture = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      final node = tester.getSemantics(find.bySemanticsLabel('r0 c0'));
      expect(
        // ignore: deprecated_member_use
        node.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
        isTrue,
      );
      // Cells that cannot be edited are marked read-only.
      final readonly = tester.getSemantics(find.bySemanticsLabel('r1 c1'));
      expect(
        // ignore: deprecated_member_use
        readonly.getSemanticsData().hasFlag(SemanticsFlag.isReadOnly),
        isFalse,
      );
      handle.dispose();
    });

    testWidgets('semantics carry the real cell geometry', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildEditor(rows: 3, columnCount: 6, scrollOffsetX: 200),
      );
      await tester.pumpAndSettle();

      // Only the columns the painter walks are exposed.
      expect(find.bySemanticsLabel('C0'), findsNothing);
      expect(find.bySemanticsLabel('C2'), findsOneWidget);

      // The node has the cell's box instead of collapsing to 1x1.
      final cell = tester.getSemantics(find.bySemanticsLabel('r0 c2'));
      expect(cell.rect.size, const Size(100, 32));
      final row = tester.getSemantics(find.bySemanticsLabel('Row 1'));
      expect(row.rect.size, const Size(400, 32));
      handle.dispose();
    });

    testWidgets('frozen trailing rows stay exposed to readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildEditor(rows: 30, columnCount: 2, freezeTrailingRows: 1),
      );
      await tester.pumpAndSettle();

      // Row 30 (the last data row) is pinned below the viewport; the painter
      // still draws it, so it needs a node.
      expect(find.bySemanticsLabel('Row 30'), findsOneWidget);
      // Row 12 is neither visible nor frozen.
      expect(find.bySemanticsLabel('Row 12'), findsNothing);
      handle.dispose();
    });

    testWidgets('the row-marker column is not exposed to readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildEditor(
          rows: 3,
          columnCount: 2,
          rowMarkers: const SemiRowMarkerOptions(width: 40),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<SemiDataGrid>(find.byType(SemiDataGrid)).props
            .firstColAccessible,
        isFalse,
      );
      // The marker column is chrome with an empty title; no header node is
      // emitted for it, so the tree's headers are exactly the data columns.
      final headers = tester.getSemantics(
        find.bySemanticsLabel('Column headers'),
      );
      final titles = [
        for (final child
            in headers.debugListChildrenInOrder(
              DebugSemanticsDumpOrder.traversalOrder,
            ))
          child.label,
      ];
      expect(titles, ['C0', 'C1']);
      handle.dispose();
    });

    testWidgets('an edit refreshes the accessibility labels', (tester) async {
      final handle = tester.ensureSemantics();

      // `content` reads the shared `edits` log, so the label only changes
      // once the editor has routed a real edit through `_onCellsEdited`.
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          content: (item) {
            final label = edits.isEmpty ? 'before' : 'after';
            return SemiTextCell(data: label, displayData: label);
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('before'), findsWidgets);

      // Select (0,0) then type: `editOnType` opens the overlay and Enter
      // commits, routing the value through `_onCellsEdited`, which bumps
      // `a11yRevision`. This covers the editor half of the contract — the
      // grid half (the key actually containing it) is pinned by the test
      // below. (`data-grid.ts:1737`)
      final gesture = await tester.startGesture(
        const Offset(50, 45),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(edits, isNotEmpty);
      // Every visible cell shares the label, so a single survivor would mean
      // part of the cached tree was served stale.
      expect(find.bySemanticsLabel('after'), findsWidgets);
      expect(find.bySemanticsLabel('before'), findsNothing);
      handle.dispose();
    });

    testWidgets('a stale tree is served until a11yRevision moves', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      var label = 'first';
      var revision = 0;
      // Hoisted so the key's `getCellContent`/`getCellRenderer` components
      // are identical across pumps — only `a11yRevision` may change.
      final lookup = SemiDefaultRendererLookup();
      SemiGridCell content(SemiItem item, [bool? forceStrict]) =>
          SemiTextCell(data: label, displayData: label);

      Widget build() => _standaloneGrid(
        content: content,
        renderer: lookup.forCell,
        a11yRevision: revision,
      );

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('first'), findsWidgets);

      // The backing data changed but the owner did not bump the revision:
      // `useDebouncedMemo`'s deps exclude cell values (`data-grid.ts:1737`),
      // so the cached labels are what the screen reader keeps reading.
      label = 'second';
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('first'), findsWidgets);
      expect(find.bySemanticsLabel('second'), findsNothing);

      // The revision bump is the invalidation signal.
      revision++;
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('second'), findsWidgets);
      expect(find.bySemanticsLabel('first'), findsNothing);

      handle.dispose();
    });

    testWidgets('controller damage refreshes paint and semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final controller = SemiDataGridController();
      addTearDown(controller.dispose);
      final lookup = SemiDefaultRendererLookup();
      const item = SemiItem(0, 0);
      final paintedLabels = <String>[];
      var label = 'before damage';

      SemiGridCell content(SemiItem location, [bool? forceStrict]) =>
          location == item
          ? SemiTextCell(data: label, displayData: label)
          : _stableContent(location);

      await tester.pumpWidget(
        _standaloneGrid(
          controller: controller,
          content: content,
          renderer: lookup.forCell,
          drawCell: (args, draw) {
            if (args.col == item.col && args.row == item.row) {
              paintedLabels.add((args.cell as SemiTextCell).displayData);
            }
            draw();
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(paintedLabels.last, 'before damage');
      expect(find.bySemanticsLabel('before damage'), findsOneWidget);

      label = 'after damage';
      paintedLabels.clear();
      controller.damage(const [item]);
      await tester.pumpAndSettle();

      expect(paintedLabels, contains('after damage'));
      expect(find.bySemanticsLabel('after damage'), findsOneWidget);
      expect(find.bySemanticsLabel('before damage'), findsNothing);
      handle.dispose();
    });
  });

  group('column sizer', () {
    test('measureColumn takes the widest cell, floored and capped', () {
      final theme = SemiDataGridTheme.light();
      final cells = <List<SemiGridCell>>[
        [
          const SemiTextCell(data: 'hi', displayData: 'hi'),
          const SemiTextCell(data: 'a', displayData: 'a'),
        ],
        [
          const SemiTextCell(data: 'much longer text', displayData: 'x'),
          const SemiTextCell(data: 'a', displayData: 'a'),
        ],
      ];

      final width = semiMeasureColumn(
        theme: theme,
        column: const SemiGridColumn(title: 'C', width: 100),
        colIndex: 0,
        selectedData: cells,
        minColumnWidth: 50,
        maxColumnWidth: 500,
        removeOutliers: false,
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        metrics: SemiTextMetrics(),
      );

      expect(width, greaterThanOrEqualTo(50));
      expect(width, lessThanOrEqualTo(500));
      // The header title is part of the measurement too.
      expect(width, greaterThanOrEqualTo(theme.cellHorizontalPadding * 2 + 8));
    });

    test('measureColumn respects the configured bounds', () {
      final theme = SemiDataGridTheme.light();
      final tiny = semiMeasureColumn(
        theme: theme,
        column: const SemiGridColumn(title: 'C', width: 10),
        colIndex: 0,
        selectedData: const [
          [SemiTextCell(data: 'a', displayData: 'a')],
        ],
        minColumnWidth: 120,
        maxColumnWidth: 500,
        removeOutliers: false,
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        metrics: SemiTextMetrics(),
      );
      expect(tiny, 120);

      final huge = semiMeasureColumn(
        theme: theme,
        column: const SemiGridColumn(title: 'C', width: 10),
        colIndex: 0,
        selectedData: const [
          [
            SemiTextCell(
              data: 'a very long piece of text that will not fit at all',
              displayData: 'a very long piece of text that will not fit at all',
            ),
          ],
        ],
        minColumnWidth: 10,
        maxColumnWidth: 60,
        removeOutliers: false,
        getCellRenderer: SemiDefaultRendererLookup().forCell,
        metrics: SemiTextMetrics(),
      );
      expect(huge, 60);
    });
  });

  // -------------------------------------------------------------------------
  // Column sizer (`data-editor/use-column-sizer.ts`)
  // -------------------------------------------------------------------------

  group('column sizer', () {
    SemiSizedColumns size({
      required List<SemiGridColumn> columns,
      required int rows,
      required double clientWidth,
      required double minColumnWidth,
      double maxColumnWidth = 500,
      Map<String, double>? memo,
    }) => useColumnSizer(
      columns: columns,
      rows: rows,
      getCellsForSelection: (region) => [
        for (
          var y = region.y.toInt();
          y < region.y + region.height && y < rows;
          y++
        )
          [
            for (var x = region.x.toInt(); x < region.x + region.width; x++)
              SemiTextCell(data: 'r$y c$x', displayData: 'r$y c$x'),
          ],
      ],
      clientWidth: clientWidth,
      minColumnWidth: minColumnWidth,
      maxColumnWidth: maxColumnWidth,
      theme: SemiDataGridTheme.light(),
      getCellRenderer: SemiDefaultRendererLookup().forCell,
      metrics: SemiTextMetrics(),
      memo: memo,
    );

    test('already sized columns pass through untouched', () {
      final columns = [
        for (var i = 0; i < 3; i++)
          SemiGridColumn(title: 'C$i', width: 100, id: 'c$i'),
      ];
      final result = size(
        columns: columns,
        rows: 5,
        clientWidth: 400,
        minColumnWidth: 50,
      );
      expect(identical(result.columns, columns), isTrue);
      expect(result.nonGrowWidth, 300);
    });

    test('unsized columns are measured from the sampled rows', () {
      final columns = [
        for (var i = 0; i < 3; i++) SemiGridColumn(title: 'C$i', id: 'c$i'),
      ];
      final result = size(
        columns: columns,
        rows: 5,
        clientWidth: 400,
        minColumnWidth: 50,
      );
      expect(result.columns, hasLength(3));
      for (final c in result.columns) {
        expect(c.width, isNotNull);
        // `minColumnWidth` floors every measurement.
        expect(c.width, greaterThanOrEqualTo(50));
      }
      expect(result.nonGrowWidth, greaterThan(0));
    });

    test('grow columns absorb the leftover width', () {
      final columns = [
        SemiGridColumn(title: 'A', width: 100, id: 'a'),
        SemiGridColumn(title: 'B', width: 100, id: 'b', grow: 1),
      ];
      final result = size(
        columns: columns,
        rows: 5,
        clientWidth: 400,
        minColumnWidth: 50,
      );
      // The extent is measured before the distribution (`:248-250`).
      expect(result.nonGrowWidth, 200);
      expect(result.columns[1].width, 300);
      expect(result.columns[1].extension?.growOffset, 200);
    });

    test('the memo is keyed by column id', () {
      final memo = <String, double>{};
      final columns = [SemiGridColumn(title: 'C', id: 'c')];
      size(
        columns: columns,
        rows: 5,
        clientWidth: 400,
        minColumnWidth: 50,
        memo: memo,
      );
      expect(memo.keys, ['c']);
      expect(memo['c'], greaterThanOrEqualTo(50));
    });
  });
  group('fill math', () {
    test('combineRects takes the union', () {
      final combined = combineRects(
        const SemiRectangle(x: 0, y: 0, width: 1, height: 1),
        const SemiRectangle(x: 0, y: 1, width: 1, height: 5),
      );
      expect(combined.x, 0);
      expect(combined.y, 0);
      expect(combined.width, 1);
      expect(combined.height, 6);
    });

    test('getClosestRect grows toward the nearest edge', () {
      const source = SemiRectangle(x: 0, y: 0, width: 1, height: 1);

      final down = getClosestRect(
        source,
        0,
        5,
        SemiFillHandleDirection.orthogonal,
      );
      expect(down!.y, 1);
      expect(down.height, 5);

      final right = getClosestRect(
        source,
        5,
        0,
        SemiFillHandleDirection.orthogonal,
      );
      expect(right!.x, 1);
      expect(right.width, 5);

      // Inside the source → nothing to grow.
      expect(
        getClosestRect(source, 0, 0, SemiFillHandleDirection.orthogonal),
        isNull,
      );

      // `vertical` pins the horizontal axis, so only rows change.
      final onlyRows = getClosestRect(
        source,
        9,
        4,
        SemiFillHandleDirection.vertical,
      );
      expect(onlyRows!.x, 0);
      expect(onlyRows.width, 1);
      expect(onlyRows.height, 4);
    });
  });

  group('autoscroll', () {
    test('ramps from zero to full speed over 1300ms', () {
      final auto = SemiAutoscroll();
      expect(auto.isActive, isFalse);
      expect(auto.advance(16), (0.0, 0.0));

      auto.setDirection(0, 1);
      expect(auto.isActive, isTrue);

      // Early frames move slowly.
      var total = 0.0;
      for (var i = 0; i < 6; i++) {
        final (_, dy) = auto.advance(16);
        total += dy;
      }
      final early = total;

      // After the ramp window a frame moves much further.
      auto.advance(1400);
      final (_, full) = auto.advance(16);
      expect(full, greaterThan(early / 6));

      auto.setDirection(0, 0);
      expect(auto.isActive, isFalse);
      expect(auto.advance(16), (0.0, 0.0));
    });
  });

  group('number formatting', () {
    test('semiNumberToDisplay drops the .0 of integral doubles', () {
      expect(semiNumberToDisplay(1234, null), '1234');
      expect(semiNumberToDisplay(1234.0, null), '1234');
      expect(semiNumberToDisplay(1234.5, null), '1234.5');
      expect(semiNumberToDisplay(1234.567, 2), '1234.57');
      expect(semiNumberToDisplay(-42, null), '-42');
    });
  });

  // -------------------------------------------------------------------------
  // Image cell + window loader (`cells/image-cell.tsx`,
  // `common/image-window-loader.ts`)
  // -------------------------------------------------------------------------

  group('image cell', () {
    const thumbnail = SemiImageCell(
      data: ['thumbnail.png'],
      contentAlign: SemiContentAlign.center,
    );
    const boundaryKey = ValueKey('image grid');
    const redPixel = 0xFF0000FF;

    SemiGridCell thumbnailContent(SemiItem item, [bool? forceStrict]) =>
        item == const SemiItem(0, 0) ? thumbnail : _stableContent(item);

    Future<int?> gridPixel(WidgetTester tester, int x, int y) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      // Rasterize the last painted layer without invoking the painter again.
      return tester.runAsync(() async {
        final snapshot = await boundary.toImage();
        try {
          final bytes = await snapshot.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          return bytes!.getUint32((y * snapshot.width + x) * 4);
        } finally {
          snapshot.dispose();
        }
      });
    }

    testWidgets('an idle image grid paints after a deferred load', (
      tester,
    ) async {
      final image = (await tester.runAsync(_fakeImage))!;
      addTearDown(image.dispose);
      final requests = <String>[];
      final completions = <void Function(ui.Image?)>[];
      final loader = SemiImageWindowLoader(
        loadImage: (url, complete) {
          requests.add(url);
          completions.add(complete);
        },
      );
      addTearDown(loader.dispose);
      final lookup = SemiDefaultRendererLookup();

      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: _standaloneGrid(
            content: thumbnailContent,
            renderer: lookup.forCell,
            imageLoader: loader,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(requests, ['thumbnail.png']);
      expect(await gridPixel(tester, 50, 45), isNot(redPixel));
      expect(tester.binding.hasScheduledFrame, isFalse);

      completions.single(image);
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpAndSettle();
      expect(await gridPixel(tester, 50, 45), redPixel);
      expect(requests, ['thumbnail.png']);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is SemiDataGridPainter,
        ),
        paints..drawImageRect(image: image),
      );
    });

    testWidgets('an image can complete synchronously during grid paint', (
      tester,
    ) async {
      final image = (await tester.runAsync(_fakeImage))!;
      addTearDown(image.dispose);
      final requests = <String>[];
      final loader = SemiImageWindowLoader(
        loadImage: (url, complete) {
          requests.add(url);
          complete(image);
        },
      );
      addTearDown(loader.dispose);
      final lookup = SemiDefaultRendererLookup();

      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: _standaloneGrid(
            content: thumbnailContent,
            renderer: lookup.forCell,
            imageLoader: loader,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(await gridPixel(tester, 50, 45), redPixel);
      expect(requests, ['thumbnail.png']);
    });

    testWidgets('swapping external image loaders detaches their callbacks', (
      tester,
    ) async {
      final image = (await tester.runAsync(_fakeImage))!;
      addTearDown(image.dispose);
      final oldCompletions = <void Function(ui.Image?)>[];
      final newCompletions = <void Function(ui.Image?)>[];
      final oldLoader = SemiImageWindowLoader(
        loadImage: (_, complete) => oldCompletions.add(complete),
      );
      final newLoader = SemiImageWindowLoader(
        loadImage: (_, complete) => newCompletions.add(complete),
      );
      addTearDown(oldLoader.dispose);
      addTearDown(newLoader.dispose);
      final lookup = SemiDefaultRendererLookup();

      Widget build(SemiImageWindowLoader loader) => _standaloneGrid(
        content: thumbnailContent,
        renderer: lookup.forCell,
        imageLoader: loader,
      );

      await tester.pumpWidget(build(oldLoader));
      expect(oldLoader.onLoaded, isNotNull);
      expect(oldCompletions, hasLength(1));

      await tester.pumpWidget(build(newLoader));
      await tester.pumpAndSettle();
      expect(oldLoader.onLoaded, isNull);
      expect(newLoader.onLoaded, isNotNull);
      expect(newCompletions, hasLength(1));

      oldCompletions.single(image);
      expect(oldLoader.loadOrGetImage('thumbnail.png', 0, 0), same(image));
      expect(newLoader.loadOrGetImage('thumbnail.png', 0, 0), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(newLoader.onLoaded, isNull);
      newCompletions.single(image);
      expect(newLoader.loadOrGetImage('thumbnail.png', 0, 0), same(image));
    });

    testWidgets('a frozen trailing row keeps its thumbnail across windows', (
      tester,
    ) async {
      final image = (await tester.runAsync(_fakeImage))!;
      addTearDown(image.dispose);
      final requests = <String>[];
      final completions = <String, void Function(ui.Image?)>{};
      final loader = SemiImageWindowLoader(
        loadImage: (url, complete) {
          requests.add(url);
          completions[url] = complete;
        },
      );
      addTearDown(loader.dispose);
      final lookup = SemiDefaultRendererLookup();

      SemiGridCell content(SemiItem item, [bool? forceStrict]) =>
          switch (item) {
            SemiItem(col: 0, row: 29) => thumbnail,
            SemiItem(col: 0, row: 24) =>
              const SemiImageCell(data: ['scroll.png']),
            _ => _stableContent(item),
          };

      Widget build(int rowOffset) => RepaintBoundary(
        key: boundaryKey,
        child: _standaloneGrid(
          content: content,
          renderer: lookup.forCell,
          imageLoader: loader,
          rows: 30,
          cellYOffset: rowOffset,
          freezeTrailingRows: 1,
        ),
      );

      await tester.pumpWidget(build(24));
      await tester.pumpAndSettle();
      expect(requests, unorderedEquals(['scroll.png', 'thumbnail.png']));
      completions['scroll.png']!(image);
      completions['thumbnail.png']!(image);
      await tester.pumpAndSettle();
      expect(loader.cachedCount, 2);
      expect(await gridPixel(tester, 50, 285), redPixel);

      for (final rowOffset in [0, 10]) {
        await tester.pumpWidget(build(rowOffset));
        await tester.pumpAndSettle();
        expect(loader.cachedCount, 1);
        expect(await gridPixel(tester, 50, 285), redPixel);
        expect(requests, unorderedEquals(['scroll.png', 'thumbnail.png']));
      }
    });

    test('measure is the url count times 50', () {
      const renderer = SemiImageCellRenderer();
      final width = renderer.measure(
        const SemiImageCell(data: ['a', 'b', 'c']),
        SemiDataGridTheme.light(),
        SemiTextMetrics(),
      );
      expect(width, 150);
    });

    test('delete empties the url list', () {
      const renderer = SemiImageCellRenderer();
      final deleted = renderer.onDelete(
        const SemiImageCell(data: ['a', 'b']),
      ) as SemiImageCell;
      expect(deleted.data, isEmpty);
    });

    test('paste only keeps parseable urls', () {
      const renderer = SemiImageCellRenderer();
      const cell = SemiImageCell(data: ['https://a/b.png']);

      final changed = renderer.onPaste(
        'https://a/b.png, https://c/d.png',
        cell,
        const SemiPasteDetails(),
      ) as SemiImageCell;
      expect(changed.data, ['https://a/b.png', 'https://c/d.png']);

      // Identical url set is a no-op (`image-cell.tsx:74`).
      expect(
        renderer.onPaste('https://a/b.png', cell, const SemiPasteDetails()),
        isNull,
      );

      // `not a url` has no scheme and is dropped; what is left differs from
      // the current set, so the cell is updated.
      final filtered = renderer.onPaste(
        'nope, https://c/d.png',
        cell,
        const SemiPasteDetails(),
      ) as SemiImageCell;
      expect(filtered.data, ['https://c/d.png']);

      // Dropping the only unparseable entry can leave the set unchanged.
      expect(
        renderer.onPaste(
          'nope, https://a/b.png',
          cell,
          const SemiPasteDetails(),
        ),
        isNull,
      );
    });
  });

  group('image window loader', () {
    late List<void Function(ui.Image?)> completions;
    late int loads;

    SemiImageWindowLoader makeLoader() {
      completions = [];
      loads = 0;
      return SemiImageWindowLoader(
        loadImage: (url, onComplete) {
          loads++;
          completions.add(onComplete);
        },
      );
    }

    test('caches by url and reports the decoded cell once', () async {
      final loader = makeLoader();
      final loaded = <SemiCellSet>[];
      loader.onLoaded = loaded.add;
      loader.setWindow(
        const SemiRectangle(x: 0, y: 0, width: 10, height: 10),
        0,
        const [],
      );

      expect(loader.loadOrGetImage('a.png', 1, 2), isNull);
      expect(loader.loadOrGetImage('a.png', 1, 3), isNull);
      expect(loads, 1);
      expect(loader.cachedCount, 1);

      final image = await _fakeImage();
      completions.single(image);

      expect(loaded, hasLength(1));
      expect(loaded.single.hasAt(1, 2), isTrue);
      expect(loaded.single.hasAt(1, 3), isTrue);
      expect(loader.loadOrGetImage('a.png', 1, 2), same(image));
      expect(loads, 1);
    });

    test('a failed load is remembered instead of retried', () {
      final loader = makeLoader();
      loader.setWindow(
        const SemiRectangle(x: 0, y: 0, width: 10, height: 10),
        0,
        const [],
      );

      expect(loader.loadOrGetImage('bad.png', 0, 0), isNull);
      completions.single(null);

      expect(loader.loadOrGetImage('bad.png', 0, 0), isNull);
      expect(loads, 1);
    });

    test('an empty url never starts a load', () {
      final loader = makeLoader();
      expect(loader.loadOrGetImage('', 0, 0), isNull);
      expect(loads, 0);
      expect(loader.cachedCount, 0);
    });

    test('evicts entries whose cells leave the window', () async {
      final loader = makeLoader();
      loader.setWindow(
        const SemiRectangle(x: 0, y: 0, width: 10, height: 10),
        0,
        const [],
      );
      loader.loadOrGetImage('a.png', 0, 0);
      final image = await _fakeImage();
      completions.single(image);
      expect(loader.cachedCount, 1);

      // Nothing in the new window → the entry goes.
      loader.setWindow(
        const SemiRectangle(x: 50, y: 50, width: 10, height: 10),
        0,
        const [],
      );
      expect(loader.cachedCount, 0);

      // Loading it again starts a fresh load.
      expect(loader.loadOrGetImage('a.png', 50, 50), isNull);
      expect(loads, 2);
    });

    test('a frozen column keeps its entry alive', () async {
      final loader = makeLoader();
      loader.setWindow(
        const SemiRectangle(x: 0, y: 0, width: 1, height: 1),
        2,
        const [],
      );
      loader.loadOrGetImage('frozen.png', 0, 0);
      final image = await _fakeImage();
      completions.single(image);

      // Only the column axis moves: column 0 is frozen, and the row is still
      // inside the window (`image-window-loader.ts:41-48`).
      loader.setWindow(
        const SemiRectangle(x: 50, y: 0, width: 10, height: 10),
        2,
        const [],
      );
      expect(loader.cachedCount, 1);
      expect(loader.loadOrGetImage('frozen.png', 0, 0), same(image));
    });
  });

  // -------------------------------------------------------------------------
  // Row grouping (`data-editor/row-grouping.ts`, `row-grouping-api.ts`)
  // -------------------------------------------------------------------------

  group('row grouping', () {
    const options = SemiRowGroupingOptions(
      groups: [
        SemiRowGroup(headerIndex: 0, isCollapsed: true),
        SemiRowGroup(headerIndex: 3, isCollapsed: false),
      ],
      height: 60,
    );

    test('flattenRowGroups computes row and content indices', () {
      final flattened = flattenRowGroups(options, 6);
      expect(flattened, hasLength(2));

      expect(flattened[0].rowIndex, 0);
      expect(flattened[0].isCollapsed, isTrue);
      expect(flattened[0].rows, 2);
      expect(flattened[0].contentIndex, 0);

      // The collapsed first group occupies a single grid row, so the second
      // header lands at grid row 1 while its content starts at index 2.
      expect(flattened[1].rowIndex, 1);
      expect(flattened[1].isCollapsed, isFalse);
      expect(flattened[1].contentIndex, 2);
      expect(flattened[1].rows, 2);
    });

    test('effective rows shrink when a group is collapsed', () {
      final result = useRowGroupingInner(
        options: options,
        rows: 6,
        rowHeightIn: const SemiRowHeight.fixed(32),
        getRowThemeOverrideIn: null,
      );
      // 1 collapsed header + (2 content + 1 header) = 4 grid rows.
      expect(result.rows, 4);
    });

    test('rowHeight swaps group headers to the group height', () {
      final result = useRowGroupingInner(
        options: options,
        rows: 6,
        rowHeightIn: const SemiRowHeight.fixed(32),
        getRowThemeOverrideIn: null,
      );
      final rowHeight = result.rowHeight;
      expect(rowHeight, isNotNull);
      expect(rowHeight!(0), 60);
      expect(rowHeight(1), 60);
      expect(rowHeight(2), 32);
      expect(rowHeight(3), 32);
    });

    test('mapRowIndexToPath distinguishes headers from content', () {
      final flattened = flattenRowGroups(options, 6);

      final header = mapRowIndexToPath(0, flattened);
      expect(header.isGroupHeader, isTrue);
      expect(header.originalIndex, 0);

      final secondHeader = mapRowIndexToPath(1, flattened);
      expect(secondHeader.isGroupHeader, isTrue);
      expect(secondHeader.originalIndex, 3);

      final content = mapRowIndexToPath(2, flattened);
      expect(content.isGroupHeader, isFalse);
      expect(content.originalIndex, 4);
      expect(content.groupIndex, 0);
      expect(content.contentIndex, 2);
    });

    test('rowNumberMapper numbers content rows and skips headers', () {
      final result = useRowGroupingInner(
        options: options,
        rows: 6,
        rowHeightIn: const SemiRowHeight.fixed(32),
        getRowThemeOverrideIn: null,
      );
      final mapper = result.rowNumberMapper;
      expect(mapper, isNotNull);
      // Grid rows 0 and 1 are group headers.
      expect(mapper!(0), isNull);
      expect(mapper(1), isNull);
      expect(mapper(2), 2);
      expect(mapper(3), 3);
    });

    test('without grouping everything is the identity', () {
      final result = useRowGroupingInner(
        options: null,
        rows: 7,
        rowHeightIn: const SemiRowHeight.fixed(32),
        getRowThemeOverrideIn: null,
      );
      expect(result.rows, 7);
      expect(result.flattened, isEmpty);
      expect(result.rowHeight, isNull);
      expect(result.rowNumberMapper, isNull);
      expect(result.getRowThemeOverride, isNull);
    });

    test('block-spanning pins the selection to one group', () {
      const blockable = SemiRowGroupingOptions(
        groups: [SemiRowGroup(headerIndex: 0, isCollapsed: false)],
        height: 60,
        selectionBehavior: SemiRowGroupSelectionBehavior.blockSpanning,
      );
      final flattened = flattenRowGroups(blockable, 6);

      // Row 0 is the header: the selection cannot move at all.
      expect(
        getSelectionRowLimits(
          options: blockable,
          flattened: flattened,
          selectedRow: 0,
        ),
        (0, 0),
      );

      // Content rows stay inside their own group (rows 1..5 here).
      final limits = getSelectionRowLimits(
        options: blockable,
        flattened: flattened,
        selectedRow: 2,
      );
      expect(limits?.$1, 1);
      expect(limits?.$2, 5);
    });
  });

  // -------------------------------------------------------------------------
  // Rem adjuster (`data-editor/use-rem-adjuster.ts`)
  // -------------------------------------------------------------------------

  group('rem adjuster', () {
    SemiRemAdjustment adjust({bool scaleToRem = true, double remSize = 16}) =>
        semiRemAdjuster(
          scaleToRem: scaleToRem,
          remSize: remSize,
          rowHeightIn: const SemiRowHeight.fixed(30),
          headerHeightIn: 36,
          groupHeaderHeightIn: 36,
          themeIn: SemiDataGridTheme.light(),
          overscrollXIn: 10,
          overscrollYIn: 10,
        );

    test('is the identity when scaleToRem is off or remSize is 16', () {
      final off = adjust(scaleToRem: false, remSize: 32);
      expect(off.rowHeight(0), 30);
      expect(off.headerHeight, 36);
      expect(off.overscrollY, 10);

      final sixteen = adjust(remSize: 16);
      expect(sixteen.rowHeight(0), 30);
      expect(sixteen.headerHeight, 36);
      expect(sixteen.overscrollX, 10);
      expect(identical(sixteen.theme, SemiDataGridTheme.light()), isTrue);
    });

    test('multiplies every dimension by remSize / 16', () {
      final scaled = adjust(remSize: 32);
      expect(scaled.rowHeight(0), 60);
      expect(scaled.headerHeight, 72);
      expect(scaled.groupHeaderHeight, 72);
      expect(scaled.overscrollX, 20);
      expect(scaled.overscrollY, 20);
      expect(
        scaled.theme.cellHorizontalPadding,
        SemiDataGridTheme.light().cellHorizontalPadding * 2,
      );
      expect(
        scaled.theme.cellVerticalPadding,
        SemiDataGridTheme.light().cellVerticalPadding * 2,
      );
      // Everything else is untouched.
      expect(scaled.theme.bgCell, SemiDataGridTheme.light().bgCell);
    });

    test('variable row heights are scaled and ceiled', () {
      final scaled = semiRemAdjuster(
        scaleToRem: true,
        remSize: 24,
        rowHeightIn: const SemiRowHeight.variable(_oddHeight),
        headerHeightIn: 36,
        groupHeaderHeightIn: 36,
        themeIn: SemiDataGridTheme.light(),
        overscrollXIn: 0,
        overscrollYIn: 0,
      );
      expect(scaled.rowHeight(0), 48); // 32 * 1.5
      expect(scaled.rowHeight(1), 50); // 33 * 1.5 = 49.5, ceiled
    });
  });

  // -------------------------------------------------------------------------
  // Search (`internal/data-grid-search/data-grid-search.tsx`)
  // -------------------------------------------------------------------------

  group('search', () {
    test('semiSearchRegex escapes the pattern but stays case insensitive', () {
      final regex = semiSearchRegex('a.b');
      expect(regex.hasMatch('a.b'), isTrue);
      expect(regex.hasMatch('axb'), isFalse);
      expect(regex.hasMatch('A.B'), isTrue);

      expect(semiSearchRegex('r2').hasMatch('R2 c1'), isTrue);
    });

    test('semiSearchTestString mirrors the upstream switch', () {
      expect(
        semiSearchTestString(
          const SemiTextCell(data: 'x', displayData: 'hi'),
        ),
        'hi',
      );
      expect(
        semiSearchTestString(const SemiNumberCell(data: 5, displayData: '5')),
        '5',
      );
      expect(
        semiSearchTestString(const SemiUriCell(data: 'https://a')),
        'https://a',
      );
      expect(
        semiSearchTestString(
          const SemiBooleanCell(data: SemiBooleanValue.checked),
        ),
        'true',
      );
      // Indeterminate has no boolean rendering upstream.
      expect(
        semiSearchTestString(
          const SemiBooleanCell(data: SemiBooleanValue.indeterminate),
        ),
        isNull,
      );
      expect(
        semiSearchTestString(const SemiBubbleCell(data: ['a', 'b'])),
        'a\u{1F433}b',
      );
      // Protected/loading cells are not searchable.
      expect(semiSearchTestString(const SemiProtectedCell()), isNull);
      expect(semiSearchTestString(const SemiLoadingCell()), isNull);
    });

    test('the runner walks every row and reports progress', () async {
      final runner = SemiSearchRunner();
      final statuses = <SemiSearchStatus>[];
      List<SemiItem>? results;

      await runner.search(
        pattern: 'c2',
        rows: 5,
        columnCount: 3,
        startY: 0,
        getCells: (region) => [
          for (
            var y = region.y.toInt();
            y < region.y + region.height && y < 5;
            y++
          )
            [
              for (
                var x = region.x.toInt();
                x < region.x + region.width && x < 3;
                x++
              )
                SemiTextCell(data: 'r$y c$x', displayData: 'r$y c$x'),
            ],
        ],
        onResults: (r) => results = r,
        onStatus: statuses.add,
        onResultsChanged: (_, _) {},
        selectedIndex: -1,
      );

      expect(results, isNotNull);
      // Column 2 of every row.
      expect(results, hasLength(5));
      expect(results, contains(const SemiItem(2, 3)));
      expect(statuses.last.rowsSearched, 5);
      expect(statuses.last.results, 5);
    });

    test('an empty pattern resets without scanning', () async {
      final runner = SemiSearchRunner();
      var scanned = 0;
      List<SemiItem>? results = const [SemiItem(0, 0)];

      await runner.search(
        pattern: '',
        rows: 100,
        columnCount: 3,
        startY: 0,
        getCells: (region) {
          scanned++;
          return const [];
        },
        onResults: (r) => results = r,
        onStatus: (_) {},
        onResultsChanged: (_, _) {},
        selectedIndex: -1,
      );

      expect(scanned, 0);
      expect(results, isEmpty);
    });

    test('a cancelled search stops mid-flight', () async {
      final runner = SemiSearchRunner();
      var scanned = 0;
      final search = runner.search(
        pattern: 'c',
        rows: 1000,
        columnCount: 3,
        startY: 0,
        getCells: (region) {
          scanned++;
          return [
            [
              for (var x = 0; x < 3; x++)
                SemiTextCell(data: 'r0 c$x', displayData: 'r0 c$x'),
            ],
          ];
        },
        onResults: (_) {},
        onStatus: (_) {},
        onResultsChanged: (_, _) {},
        selectedIndex: -1,
      );
      runner.cancel();
      await search;

      expect(scanned, lessThan(1000));
    });
  });
  group('animation manager', () {
    test('ramps the hovered item in over 80ms', () {
      final manager = SemiAnimationManager();
      expect(manager.shouldStep, isFalse);

      manager.setHovered(const SemiItem(1, 1));
      expect(manager.shouldStep, isTrue);

      var emitted = <SemiHoverValue>[];
      manager.step(40, (values) => emitted = values);
      expect(emitted.single.item, const SemiItem(1, 1));
      expect(emitted.single.amount, closeTo(0.5, 0.001));

      manager.step(40, (values) => emitted = values);
      expect(emitted.single.amount, 1.0);
      expect(manager.shouldStep, isFalse);
    });

    test('the previous item fades out with easeOutCubic', () {
      final manager = SemiAnimationManager();
      manager.setHovered(const SemiItem(1, 1));
      manager.step(80, (_) {});
      expect(manager.shouldStep, isFalse);

      manager.setHovered(const SemiItem(2, 1));
      expect(manager.shouldStep, isTrue);

      var emitted = <SemiHoverValue>[];
      manager.step(40, (values) => emitted = values);
      expect(emitted, hasLength(2));
      final leaving = emitted.firstWhere(
        (v) => v.item == const SemiItem(1, 1),
      );
      final entering = emitted.firstWhere(
        (v) => v.item == const SemiItem(2, 1),
      );
      expect(leaving.amount, closeTo(0.5, 0.001));
      expect(entering.amount, closeTo(0.5, 0.001));

      // With nothing hovered any more, leaving items are eased instead of
      // raw (`animation-manager.ts:48-55`).
      manager.setHovered(null);
      manager.step(20, (values) => emitted = values);
      expect(emitted, hasLength(2));
      final eased = emitted.firstWhere((v) => v.item == const SemiItem(2, 1));
      expect(eased.amount, closeTo(semiEaseOutCubic(0.25), 0.001));
    });

    test('re-hovering resumes from the leaving amount', () {
      final manager = SemiAnimationManager();
      manager.setHovered(const SemiItem(1, 1));
      manager.step(80, (_) {});
      manager.setHovered(const SemiItem(2, 1));
      manager.step(40, (_) {}); // item 1 is now leaving at 0.5

      manager.setHovered(const SemiItem(1, 1));
      var emitted = <SemiHoverValue>[];
      manager.step(1, (values) => emitted = values);
      final resumed = emitted.firstWhere(
        (v) => v.item == const SemiItem(1, 1),
      );
      expect(resumed.amount, greaterThan(0.5));
    });

    test('setting the same hovered item is a no-op', () {
      final manager = SemiAnimationManager();
      manager.setHovered(const SemiItem(1, 1));
      manager.step(80, (_) {});
      manager.setHovered(const SemiItem(1, 1));
      expect(manager.shouldStep, isFalse);
      // The current item stays in the list at full amount even when idle.
      expect(manager.animatingItems, hasLength(1));
      expect(manager.animatingItems.single.amount, 1.0);
    });

    test('clearing the hovered item fades it out', () {
      final manager = SemiAnimationManager();
      manager.setHovered(const SemiItem(1, 1));
      manager.step(80, (_) {});
      manager.setHovered(null);
      expect(manager.shouldStep, isTrue);

      var emitted = <SemiHoverValue>[];
      for (var i = 0; i < 10; i++) {
        manager.step(20, (values) => emitted = values);
      }
      expect(emitted, isEmpty);
      expect(manager.shouldStep, isFalse);
    });

    test('easeOutCubic matches the upstream curve', () {
      expect(semiEaseOutCubic(0), 0);
      expect(semiEaseOutCubic(1), 1);
      expect(semiEaseOutCubic(0.5), closeTo(0.875, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // Sticky shadows (`data-grid.tsx:1878-1917`)
  // -------------------------------------------------------------------------

  group('sticky shadows', () {
    test('opacityX ramps only while the scroll is inside the frozen region', () {
      // No frozen columns: nothing to cast a shadow from.
      expect(
        semiStickyShadowOpacityX(
          freezeColumns: 0,
          cellXOffset: 0,
          translateX: -50,
          fixedShadowX: true,
        ),
        0,
      );
      // `fixedShadowX: false` turns it off outright.
      expect(
        semiStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 5,
          translateX: -50,
          fixedShadowX: false,
        ),
        0,
      );
      // Once past the frozen region it snaps to full.
      expect(
        semiStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 3,
          translateX: 0,
          fixedShadowX: true,
        ),
        1,
      );
      // Otherwise it ramps over the first 100px of horizontal scroll.
      expect(
        semiStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 2,
          translateX: -50,
          fixedShadowX: true,
        ),
        closeTo(0.5, 0.001),
      );
      expect(
        semiStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 2,
          translateX: -400,
          fixedShadowX: true,
        ),
        1,
      );
    });

    test('opacityY ramps over the first 100px of vertical scroll', () {
      expect(
        semiStickyShadowOpacityY(
          cellYOffset: 0,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: true,
        ),
        0,
      );
      expect(
        semiStickyShadowOpacityY(
          cellYOffset: 1,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: false,
        ),
        0,
      );
      // `-cellYOffset * 32` over100 (`data-grid.tsx:1881-1882`).
      expect(
        semiStickyShadowOpacityY(
          cellYOffset: 1,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: true,
        ),
        closeTo(0.32, 0.001),
      );
      expect(
        semiStickyShadowOpacityY(
          cellYOffset: 10,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: true,
        ),
        1,
      );
    });

    testWidgets('the frozen-column shadow is painted, and skipped when off', (
      tester,
    ) async {
      /// Renders the grid and returns two pixels: one inside the shadow band
      /// just right of the frozen column, one well inside the shadow's hole.
      Future<List<int>?> shoot({required bool fixedShadowX}) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                width: 400,
                height: 300,
                child: SemiDataGrid(
                  props: SemiDataGridProps(
                    width: 400,
                    height: 300,
                    columns: [
                      for (var i = 0; i < 4; i++)
                        SemiGridColumn(title: 'C$i', width: 100),
                    ],
                    rows: 10,
                    rowHeight: const SemiRowHeight.fixed(30),
                    headerHeight: 30,
                    freezeColumns: 1,
                    cellXOffset: 2,
                    fixedShadowX: fixedShadowX,
                    getCellContent: (item, [_]) =>
                        const SemiTextCell(data: 'x', displayData: 'x'),
                    getCellRenderer: SemiDefaultRendererLookup().forCell,
                    theme: SemiDataGridTheme.light(),
                    verticalBorder: (_) => true,
                    onItemHovered: (_) {},
                    onMouseMove: (_) {},
                    onMouseDown: (_) {},
                    onMouseUp: (_, _) {},
                    onContextMenu: (_, _) {},
                    onCanvasFocused: () {},
                    onCanvasBlur: () {},
                    onCellFocused: (_) {},
                    onKeyDown: (_) {},
                    isFocused: true,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // `toImage` awaits a real engine frame, which never resolves inside
        // the fake-async zone a `testWidgets` body runs in.
        return await tester.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          if (data == null) return <int>[];

          int at(int x, int y) {
            final o = (y * 400 + x) * 4;
            return data.getUint8(o) +
                data.getUint8(o + 1) +
                data.getUint8(o + 2);
          }

          // The frozen column is 100px wide and `cellXOffset > freezeColumns`,
          // so `opacityX` is 1 and the band starts at x=100 (`box-shadow:
          // inset 13px ... -13px` reaches ~26px in).
          return [at(105, 150), at(250, 150)];
        });
      }

      final withShadow = await shoot(fixedShadowX: true);
      final withoutShadow = await shoot(fixedShadowX: false);
      expect(withShadow, hasLength(2));
      expect(withoutShadow, hasLength(2));
      final band = withShadow!;
      final control = withoutShadow!;

      expect(
        band[0],
        lessThan(control[0]),
        reason: 'the band right of the frozen column must be darkened',
      );
      expect(
        band[1],
        control[1],
        reason: 'deep inside the shadow the grid must be untouched',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Sprites (`internal/data-grid/sprites.ts`, `data-grid-sprites.ts`)
  // -------------------------------------------------------------------------

  group('sprites', () {
    test('the built-in set has one entry per upstream sprite', () {
      // `sprites` (`sprites.ts:289-319`).
      expect(semiSprites.keys, hasLength(29));
      expect(
        semiSprites.keys,
        containsAll([
          'headerRowID',
          'headerString',
          'headerNumber',
          'renameIcon',
          'rowOwnerOverlay',
          'protectedColumnOverlay',
        ]),
      );
      // `headerAudioUri = headerUri` (`sprites.ts:75`).
      expect(
        semiSprites['headerAudioUri']!((fgColor: 'f', bgColor: 'b')),
        semiSprites['headerUri']!((fgColor: 'f', bgColor: 'b')),
      );
    });

    test('every sprite interpolates both colors into its markup', () {
      const props = (fgColor: '#111111', bgColor: '#222222');
      for (final entry in semiSprites.entries) {
        final svg = entry.value(props);
        expect(svg.trimLeft(), startsWith('<svg'), reason: entry.key);
        expect(svg, contains('#222222'), reason: entry.key);
        // `renameIcon` only paints with `bgColor` (`sprites.ts:65-73`).
        if (entry.key != 'renameIcon') {
          expect(svg, contains('#111111'), reason: entry.key);
        }
      }
    });

    test('semiSpriteColors follows the upstream variant table', () {
      final theme = SemiDataGridTheme.light();
      // `getColors` (`data-grid-sprites.ts:30-40`).
      final normal = semiSpriteColors(SemiSpriteVariant.normal, theme);
      expect(normal.bg, '#737383'); // theme.bgIconHeader
      expect(normal.fg, '#ffffff'); // theme.fgIconHeader

      final selected = semiSpriteColors(SemiSpriteVariant.selected, theme);
      expect(selected.bg, '#ffffff'); // upstream's literal "white"
      expect(selected.fg, '#4f5dff'); // theme.accentColor

      final special = semiSpriteColors(SemiSpriteVariant.special, theme);
      expect(special.bg, '#4f5dff'); // theme.accentColor
      expect(special.fg, '#f7f7f8'); // theme.bgHeader
    });

    testWidgets('a sprite lands on the canvas once its decode settles', (
      tester,
    ) async {
      final theme = SemiDataGridTheme.light();
      final settled = Completer<void>();
      final manager = SemiSpriteManager(
        icons: semiSprites,
        settled: () {
          if (!settled.isCompleted) settled.complete();
        },
      );
      addTearDown(manager.dispose);

      // The first draw only starts the load: upstream's canvas is still empty
      // at this point (`data-grid-sprites.ts:64-80`).
      final cold = ui.PictureRecorder();
      final coldCanvas = Canvas(cold)
        ..drawColor(const Color(0xFFFFFFFF), BlendMode.srcOver);
      manager.drawSprite(
        'headerString',
        SemiSpriteVariant.normal,
        coldCanvas,
        0,
        0,
        20,
        theme,
      );
      final coldPixels = await tester.runAsync(
        () => cold.endRecording().toImage(20, 20),
      );
      final coldData = (await tester.runAsync(
        () => coldPixels!.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      expect(
        coldData.getUint32(0),
        0xFFFFFFFF,
        reason: 'nothing is painted before the sprite has decoded',
      );

      // `onSettled` fires when the last in-flight sprite lands.
      await tester.runAsync(() => settled.future);

      final warm = ui.PictureRecorder();
      final warmCanvas = Canvas(warm)
        ..drawColor(const Color(0xFFFFFFFF), BlendMode.srcOver);
      manager.drawSprite(
        'headerString',
        SemiSpriteVariant.normal,
        warmCanvas,
        0,
        0,
        20,
        theme,
      );
      final img = await tester.runAsync(
        () => warm.endRecording().toImage(20, 20),
      );
      final data = (await tester.runAsync(
        () => img!.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;

      int at(int x, int y) {
        final o = (y * 20 + x) * 4;
        return data.getUint8(o) << 16 |
            data.getUint8(o + 1) << 8 |
            data.getUint8(o + 2);
      }

      // The rounded-rect plate is `bgIconHeader`.
      expect(at(10, 4), 0x737383, reason: 'the plate must be painted');
      // The corner falls outside the rounded rect, so it stays untouched.
      expect(at(1, 1), 0xFFFFFF, reason: 'outside the plate');
    });

    test('a second draw before the load lands does not start a second load', () {
      // The reservation (`_cache[key] = null` before awaiting) is what stops
      // two draws in the same frame from decoding the same sprite twice.
      var calls = 0;
      final manager = SemiSpriteManager(
        icons: {
          'counted': (props) {
            calls++;
            return semiSprites['headerString']!(props);
          },
        },
        settled: () {},
      );
      addTearDown(manager.dispose);

      for (var i = 0; i < 3; i++) {
        manager.drawSprite(
          'counted',
          SemiSpriteVariant.normal,
          Canvas(ui.PictureRecorder()),
          0,
          0,
          20,
          SemiDataGridTheme.light(),
        );
      }
      expect(calls, 1, reason: 'one key, one load');
    });

    testWidgets('an unknown sprite name draws nothing', (tester) async {
      final theme = SemiDataGridTheme.light();
      final manager = SemiSpriteManager(
        icons: semiSprites,
        settled: () {},
      );
      addTearDown(manager.dispose);

      final rec = ui.PictureRecorder();
      final recCanvas = Canvas(rec)
        ..drawColor(const Color(0xFFFFFFFF), BlendMode.srcOver);
      manager.drawSprite(
        'nope',
        SemiSpriteVariant.normal,
        recCanvas,
        0,
        0,
        20,
        theme,
      );
      // No cache slot is reserved, so no load starts and nothing settles.
      final img = await tester.runAsync(
        () => rec.endRecording().toImage(20, 20),
      );
      final data = (await tester.runAsync(
        () => img!.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      expect(data.getUint32(0), 0xFFFFFFFF);
    });
  });

  group('computeHeaderLayout', () {
    test('the title starts after the icon when there is one', () {
      final theme = SemiDataGridTheme.light();
      final metrics = SemiTextMetrics();
      final plain = computeHeaderLayout(
        c: mapColumns(const [SemiGridColumn(title: 'A', width: 100)], 0)[0],
        x: 0,
        y: 0,
        width: 100,
        height: 30,
        theme: theme,
        metrics: metrics,
      );
      expect(plain.iconBounds, isNull);
      expect(plain.textBounds.x, theme.cellHorizontalPadding);

      final withIcon = computeHeaderLayout(
        c: mapColumns(
          const [SemiGridColumn(title: 'A', width: 100, icon: 'headerString')],
          0,
        )[0],
        x: 0,
        y: 0,
        width: 100,
        height: 30,
        theme: theme,
        metrics: metrics,
      );
      final icon = withIcon.iconBounds!;
      // `drawX += Math.ceil(headerIconSize * 1.3)` (`:377-379`).
      expect(icon.x, theme.cellHorizontalPadding);
      expect(icon.width, theme.headerIconSize);
      expect(icon.y, (30 - theme.headerIconSize) / 2);
      expect(
        withIcon.textBounds.x,
        theme.cellHorizontalPadding + (theme.headerIconSize * 1.3).ceil(),
      );
    });

    test('the overlay icon hangs off the icon by 9,6 at 18x18', () {
      final theme = SemiDataGridTheme.light();
      final layout = computeHeaderLayout(
        c: mapColumns(
          const [
            SemiGridColumn(
              title: 'A',
              width: 100,
              icon: 'headerArray',
              overlayIcon: 'rowOwnerOverlay',
            ),
          ],
          0,
        )[0],
        x: 0,
        y: 0,
        width: 100,
        height: 30,
        theme: theme,
        metrics: SemiTextMetrics(),
      );
      final icon = layout.iconBounds!;
      final overlay = layout.iconOverlayBounds!;
      expect(overlay.x, icon.x + 9);
      expect(overlay.y, icon.y + 6);
      expect(overlay.width, 18);
      expect(overlay.height, 18);
      // No indicator: nothing is measured and the bounds stay null.
      expect(layout.indicatorIconBounds, isNull);
    });

    test('the indicator icon sits after the measured title', () {
      final theme = SemiDataGridTheme.light();
      final metrics = SemiTextMetrics();
      final layout = computeHeaderLayout(
        c: mapColumns(
          const [
            SemiGridColumn(
              title: 'Title',
              width: 200,
              indicatorIcon: 'headerString',
            ),
          ],
          0,
        )[0],
        x: 0,
        y: 0,
        width: 200,
        height: 30,
        theme: theme,
        metrics: metrics,
      );
      final textWidth = metrics.width('Title', theme.headerTextStyle);
      expect(layout.textBounds.width, textWidth);
      final indicator = layout.indicatorIconBounds!;
      expect(
        indicator.x,
        theme.cellHorizontalPadding +
            textWidth +
            theme.cellHorizontalPadding,
      );
      expect(indicator.width, theme.headerIconSize);
      // The menu box is always produced, icon or not.
      expect(layout.menuBounds.width, 30);
      expect(layout.menuBounds.x, 200 - 30);
    });
  });

  group('header icons', () {
    /// Renders [columns] and returns the pixel at (x, y) of the header.
    Future<int> shootHeader(
      WidgetTester tester, {
      required List<SemiGridColumn> columns,
      required int x,
      required int y,
    }) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: RepaintBoundary(
              key: key,
              child: SemiDataGrid(
                props: SemiDataGridProps(
                  width: 400,
                  height: 300,
                  columns: columns,
                  rows: 3,
                  rowHeight: const SemiRowHeight.fixed(30),
                  headerHeight: 30,
                  theme: SemiDataGridTheme.light(),
                  verticalBorder: (_) => true,
                  // `DataGrid` does not merge the built-in sprites — only
                  // `DataEditorAll` does (`data-editor-all.tsx:13-15`) — so a
                  // raw grid needs them handed over explicitly.
                  headerIcons: semiSprites,
                  getCellRenderer: SemiDefaultRendererLookup().forCell,
                  getCellContent: (item, [_]) => const SemiTextCell(
                    data: '',
                    displayData: '',
                  ),
                  onItemHovered: (_) {},
                  onMouseMove: (_) {},
                  onMouseDown: (_) {},
                  onMouseUp: (_, _) {},
                  onContextMenu: (_, _) {},
                  onCanvasFocused: () {},
                  onCanvasBlur: () {},
                  onCellFocused: (_) {},
                  onKeyDown: (_) {},
                  isFocused: true,
                ),
              ),
            ),
          ),
        ),
      );
      // Let the sprite decode land, then let `onSettled` repaint.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      return await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final img = await boundary.toImage(pixelRatio: 1);
        final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        // The boundary is the 800x600 test surface, not the 400x300 grid, so
        // the stride has to come from the captured image.
        final o = (y * img.width + x) * 4;
        return data.getUint8(o) << 16 |
            data.getUint8(o + 1) << 8 |
            data.getUint8(o + 2);
      }).then((v) => v ?? -1);
    }

    testWidgets('a column icon is painted in the header', (tester) async {
      const plain = SemiGridColumn(title: 'A', width: 100);
      const withIcon = SemiGridColumn(
        title: 'A',
        width: 100,
        icon: 'headerString',
      );
      // (22, 9) sits on the icon's plate — inside the 18px box that starts at
      // x = 8, right of the glyph and above the title — where a header with
      // no icon is plain `bgHeader`.
      final withIconPixel = await shootHeader(
        tester,
        columns: [withIcon, plain],
        x: 22,
        y: 9,
      );
      final plainPixel = await shootHeader(
        tester,
        columns: [plain, plain],
        x: 22,
        y: 9,
      );
      expect(
        withIconPixel,
        0x737383,
        reason: 'the sprite plate must be painted in the header',
      );
      expect(plainPixel, 0xF7F7F8, reason: 'an empty header is just bgHeader');
      expect(withIconPixel, isNot(plainPixel));
    });

    testWidgets('dropping headerIcons repaints the stale sprites away', (
      tester,
    ) async {
      // One key for both pumps: the subtree has to be *updated* so that
      // `didUpdateWidget` swaps the manager and `shouldRepaint` runs. A fresh
      // key would tear the grid down and rebuild it from scratch, which
      // exercises neither.
      final key = GlobalKey();

      Widget build(Map<String, SemiSpriteFn>? icons) => Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: RepaintBoundary(
            key: key,
            child: SemiDataGrid(
              props: SemiDataGridProps(
                width: 400,
                height: 300,
                columns: const [
                  SemiGridColumn(
                    title: 'A',
                    width: 100,
                    icon: 'headerString',
                  ),
                ],
                rows: 3,
                rowHeight: const SemiRowHeight.fixed(30),
                headerHeight: 30,
                theme: SemiDataGridTheme.light(),
                verticalBorder: (_) => true,
                headerIcons: icons,
                getCellRenderer: SemiDefaultRendererLookup().forCell,
                getCellContent: (item, [_]) => const SemiTextCell(
                  data: '',
                  displayData: '',
                ),
                onItemHovered: (_) {},
                onMouseMove: (_) {},
                onMouseDown: (_) {},
                onMouseUp: (_, _) {},
                onContextMenu: (_, _) {},
                onCanvasFocused: () {},
                onCanvasBlur: () {},
                onCellFocused: (_) {},
                onKeyDown: (_) {},
                isFocused: true,
              ),
            ),
          ),
        ),
      );

      Future<int> shoot() => tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final img = await boundary.toImage(pixelRatio: 1);
        final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final o = (9 * img.width + 22) * 4;
        return data.getUint8(o) << 16 |
            data.getUint8(o + 1) << 8 |
            data.getUint8(o + 2);
      }).then((v) => v ?? -1);

      Future<void> settle({bool expectDirty = false}) async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        if (expectDirty) {
          // `onSettled` has to mark the grid dirty, or the decoded sprite
          // never reaches the screen — no widget rebuild is coming.
          expect(
            key.currentContext!.findRenderObject()!.debugNeedsPaint,
            isTrue,
            reason: 'a landed sprite must schedule a repaint',
          );
        }
        await tester.pump();
      }

      await tester.pumpWidget(build(semiSprites));
      await settle(expectDirty: true);
      expect(await shoot(), 0x737383, reason: 'painted first');

      // Same grid, `headerIcons` withdrawn: `didUpdateWidget` swaps in a fresh
      // manager and `_argEquals` has to notice, or the plate stays forever.
      await tester.pumpWidget(build(null));
      await settle();
      expect(
        await shoot(),
        0xF7F7F8,
        reason: 'the stale sprite must be painted over',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Header menu / indicator clicks (`internal/data-grid/data-grid.tsx`)
  // -------------------------------------------------------------------------

  group('header menu clicks', () {
    /// Pumps a grid wired with both header-element callbacks and performs a
    /// press at [down] followed by a release at [up] (defaults to [down]).
    /// Returns every `(col, bounds)` the grid reported.
    Future<List<(int, SemiRectangle)>> press(
      WidgetTester tester, {
      required List<SemiGridColumn> columns,
      required Offset down,
      Offset? up,
      int buttons = kPrimaryButton,
      bool isDragging = false,
      bool isResizing = false,
      // Upstream's dnd layer forwards `allowResize={canResize}`
      // (`data-grid-dnd.tsx:440`), which is what arms the resize-edge arm of
      // `isOverHeaderElement`.
      bool allowResize = false,
    }) async {
      final fired = <(int, SemiRectangle)>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: SemiDataGrid(
              props: SemiDataGridProps(
                width: 400,
                height: 300,
                columns: columns,
                rows: 10,
                rowHeight: const SemiRowHeight.fixed(30),
                headerHeight: 30,
                theme: SemiDataGridTheme.light(),
                verticalBorder: (_) => true,
                headerIcons: semiSprites,
                isDragging: isDragging,
                isResizing: isResizing,
                allowResize: allowResize,
                getCellRenderer: SemiDefaultRendererLookup().forCell,
                getCellContent: (item, [_]) => const SemiTextCell(
                  data: '',
                  displayData: '',
                ),
                onHeaderMenuClick: (col, bounds) => fired.add((col, bounds)),
                onHeaderIndicatorClick: (col, bounds) =>
                    fired.add((col, bounds)),
                onItemHovered: (_) {},
                onMouseMove: (_) {},
                onMouseDown: (_) {},
                onMouseUp: (_, _) {},
                onContextMenu: (_, _) {},
                onCanvasFocused: () {},
                onCanvasBlur: () {},
                onCellFocused: (_) {},
                onKeyDown: (_) {},
                isFocused: true,
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(down, buttons: buttons);
      if (up != null && up != down) await gesture.moveTo(up);
      await gesture.up();
      await tester.pump();
      return fired;
    }

    /// The menu button of a 100px-wide header: `menuButtonSize` is 30 and it
    /// is right-aligned, so it spans x in [70, 100) and the full header height.
    const menuCenter = Offset(85, 15);

    testWidgets('pressing the menu button reports the column and its bounds', (
      tester,
    ) async {
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
          const SemiGridColumn(title: 'C1', width: 100),
        ],
        down: menuCenter,
      );

      expect(fired, hasLength(1));
      expect(fired.single.$1, 0, reason: 'the mangled column index');
      final bounds = fired.single.$2;
      expect(bounds.x, 70, reason: 'right-aligned by menuButtonSize');
      expect(bounds.y, 0);
      expect(bounds.width, 30);
      expect(bounds.height, 30);
    });

    testWidgets('a press that started on a cell does not fire it', (
      tester,
    ) async {
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: const Offset(85, 45), // row 0
        up: menuCenter,
      );
      expect(fired, isEmpty, reason: 'downPosition.row must be the header');
    });

    testWidgets('a press that started on another header does not fire it', (
      tester,
    ) async {
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
          const SemiGridColumn(title: 'C1', width: 100, hasMenu: true),
        ],
        down: const Offset(150, 15), // header of column 1
        up: menuCenter, // release on column 0's menu
      );
      expect(fired, isEmpty, reason: 'downPosition.col must match');
    });

    testWidgets('a non-left-button release does not fire it', (tester) async {
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: menuCenter,
        buttons: kSecondaryButton,
      );
      // Upstream's `click` event never fires for the right button, but
      // Flutter's `onPointerUp` does — the press button is what gates it.
      expect(fired, isEmpty);
    });

    testWidgets('a header without hasMenu never fires it', (tester) async {
      final fired = await press(
        tester,
        columns: [const SemiGridColumn(title: 'C0', width: 100)],
        down: menuCenter,
      );
      expect(fired, isEmpty);
    });

    testWidgets('pressing the indicator icon reports the indicator', (
      tester,
    ) async {
      const column = SemiGridColumn(
        title: 'C0',
        width: 100,
        indicatorIcon: 'headerString',
      );
      // `computeHeaderLayout`: xPad, then the measured title, then xPad again
      // before the icon box (`data-grid-render.header.ts:388-404`).
      final theme = SemiDataGridTheme.light();
      final textWidth = SemiTextMetrics().width(
        column.title,
        theme.headerTextStyle,
      );
      final iconLeft =
          theme.cellHorizontalPadding + textWidth + theme.cellHorizontalPadding;
      final center = Offset(
        iconLeft + theme.headerIconSize / 2,
        (30 - theme.headerIconSize) / 2 + theme.headerIconSize / 2,
      );

      final fired = await press(
        tester,
        columns: [column],
        down: center,
      );

      expect(fired, hasLength(1));
      expect(fired.single.$1, 0);
      final bounds = fired.single.$2;
      expect(bounds.x, iconLeft);
      expect(bounds.width, theme.headerIconSize);
      expect(bounds.height, theme.headerIconSize);
    });

    testWidgets('an active column drag suppresses the menu click', (
      tester,
    ) async {
      // `isOverHeaderElement` bails on `!isDragging && !isResizing`
      // (`data-grid.tsx:1044`); the editor wires this from `dragColActive`.
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: menuCenter,
        isDragging: true,
      );
      expect(fired, isEmpty);
    });

    testWidgets('hovering the resize edge suppresses the menu click', (
      tester,
    ) async {
      // The third arm of the same guard: `!(hoveredOnEdge ?? false)`
      // (`data-grid.tsx:1044`). Column 0's edge sits at x = 100, so a pointer
      // at 98 is inside the 5px buffer — and inside the menu button too.
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: menuCenter,
        up: const Offset(98, 16),
        allowResize: true,
      );
      expect(fired, isEmpty, reason: 'a resize edge is not a menu click');
    });

    testWidgets('the edge only suppresses when resizing is allowed', (
      tester,
    ) async {
      // Same gesture as the suppression test, but `allowResize` is off:
      // upstream's `allowResize === true` (`data-grid.tsx:1355`) means an edge
      // you cannot resize through is just part of the button.
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: menuCenter,
        up: const Offset(98, 16),
        allowResize: false,
      );
      expect(fired, hasLength(1));
    });

    testWidgets('the same press away from the edge does fire it', (
      tester,
    ) async {
      // Control for the test above: without the edge under the pointer the
      // identical gesture reports the menu.
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: menuCenter,
        up: const Offset(85, 16),
        allowResize: true,
      );
      expect(fired, hasLength(1), reason: 'off the edge the menu still fires');
    });

    testWidgets('an active resize suppresses the menu click', (tester) async {
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(title: 'C0', width: 100, hasMenu: true),
        ],
        down: menuCenter,
        isResizing: true,
      );
      expect(fired, isEmpty);
    });

    testWidgets('the indicator does not shadow a real menu press', (
      tester,
    ) async {
      // Both set: the menu button wins where they overlap, exactly as
      // `isOverHeaderElement` checks menu before indicator (`:1050-1063`).
      final fired = await press(
        tester,
        columns: [
          const SemiGridColumn(
            title: 'C0',
            width: 100,
            hasMenu: true,
            indicatorIcon: 'headerString',
          ),
        ],
        down: menuCenter,
      );
      expect(fired, hasLength(1));
      expect(fired.single.$1, 0);
    });
  });

  // -------------------------------------------------------------------------
  // Gallery configuration (`example/lib/pages/semi_data_grid.dart`)
  // -------------------------------------------------------------------------

  group('gallery configuration', () {
    /// The demo page's exact shape: a frozen first column, three column
    /// groups, row markers, header icons, a disclosure button and `drawCell`.
    /// `enableGroups` had no widget coverage at all before this.
    testWidgets('the frozen grouped header still hits its menu button', (
      tester,
    ) async {
      final menuHits = <int>[];
      var drewCell = false;

      // A mistyped sprite name draws nothing and raises no error — upstream's
      // `drawSprite` returns early on an unknown key
      // (`data-grid-sprites.ts:64-66`). These are the names the gallery page
      // passes, so a typo there fails here instead of silently vanishing.
      for (final name in [
        'headerString',
        'headerNumber',
        'headerBoolean',
        'headerArray',
        'headerDate',
        'rowOwnerOverlay',
      ]) {
        expect(semiSprites, contains(name), reason: 'unknown sprite $name');
      }

      // Groups are assigned per four columns, as the demo does.
      final grouped = [
        for (var i = 0; i < 12; i++)
          SemiGridColumn(
            title: 'Column ${String.fromCharCode(65 + i)}',
            width: 120 + (i % 3) * 40,
            hasMenu: i == 0 || i == 2,
            group: 'Group ${String.fromCharCode(65 + i ~/ 4)}',
            icon: switch (i) {
              0 => 'headerString',
              1 => 'headerNumber',
              2 => 'headerBoolean',
              _ => null,
            },
            overlayIcon: i == 1 ? 'rowOwnerOverlay' : null,
            indicatorIcon: i == 2 ? 'headerDate' : null,
          ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: SemiDataEditor(
                props: SemiDataEditorProps(
                  columns: grouped,
                  rows: 40,
                  getCellContent: (item, [_]) => SemiTextCell(
                    data: 'r${item.row}c${item.col}',
                    displayData: 'r${item.row}c${item.col}',
                  ),
                  theme: SemiDataGridTheme.light(),
                  rowHeight: const SemiRowHeight.fixed(34),
                  headerHeight: 38,
                  enableGroups: true,
                  groupHeaderHeight: 30,
                  verticalBorder: (_) => true,
                  freezeColumns: 1,
                  rowMarkers: const SemiRowMarkerOptions(width: 40),
                  trailingRowOptions: const SemiTrailingRowOptions(
                    hint: 'New row',
                  ),
                  drawCell: (args, draw) {
                    drewCell = true;
                    draw();
                  },
                  onHeaderMenuClick: (col, bounds) => menuHits.add(col),
                  onGridSelectionChange: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'the demo must not crash');
      expect(drewCell, isTrue, reason: 'drawCell must run for visible cells');

      // Column 0's icon plate sits at x = 40 (marker) + 8 (padding) and
      // y = 30 (group header) + 10, painted `bgIconHeader`. Scanning the
      // whole header band keeps the assertion independent of that arithmetic.
      final plate = await tester.runAsync(() async {
        final boundary = tester
            .renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary)
                .first);
        final img = await boundary.toImage(pixelRatio: 1);
        final data =
            (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        var found = 0;
        for (var y = 30; y < 68 && found == 0; y++) {
          for (var x = 40; x < 160; x++) {
            final o = (y * img.width + x) * 4;
            final rgb = data.getUint8(o) << 16 |
                data.getUint8(o + 1) << 8 |
                data.getUint8(o + 2);
            if (rgb == 0x737383) {
              found = 1;
              break;
            }
          }
        }
        return found;
      });
      expect(plate, 1, reason: 'the header icon must actually paint');

      // Menu button of the frozen column: marker [0,40), column 0 [40,160),
      // `menuButtonSize` 30 right-aligned -> [130,160) x [34,64).
      final gesture = await tester.startGesture(const Offset(145, 49));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        menuHits,
        [0],
        reason: 'the frozen, grouped, marked column must report user col 0',
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Repaint gating (`render/data-grid-render.blit.ts:233`)
  // -------------------------------------------------------------------------

  group('painter equality', () {
    /// The smallest arg that paints. Every field is overridable so a table can
    /// flip one at a time.
    SemiDrawGridArg baseArg() => SemiDrawGridArg(
      width: 400,
      height: 300,
      headerHeight: 30,
      groupHeaderHeight: 0,
      enableGroups: false,
      cellXOffset: 0,
      cellYOffset: 0,
      translateX: 0,
      translateY: 0,
      mappedColumns: const [
        SemiMappedColumn(
          sourceIndex: 0,
          sticky: false,
          title: 'C0',
          width: 100,
        ),
      ],
      freezeColumns: 0,
      freezeTrailingRows: 0,
      rows: 10,
      rowHeight: const SemiRowHeight.fixed(30),
      theme: SemiDataGridTheme.light(),
      selection: SemiGridSelection.empty,
      isFocused: false,
      drawFocus: true,
      verticalBorder: (_) => true,
      getCellContent: (item) => const SemiTextCell(data: '', displayData: ''),
      getCellRenderer: SemiDefaultRendererLookup().forCell,
      metrics: SemiTextMetrics(),
      getRowThemeOverride: null,
      getGroupDetails: null,
      hoverValues: const {},
      hoverInfo: null,
      hoverPosition: null,
      damage: null,
      hasAppendRow: false,
      touchMode: false,
      fillHandle: null,
      disabledRows: const SemiCompactSelection.empty(),
      prelightCells: null,
      highlightRegions: null,
      drawHeaderCallback: null,
      drawCellCallback: null,
      fixedShadowX: true,
      fixedShadowY: true,
      hyperWrapping: false,
      enqueue: null,
      minimumCellWidth: 10,
      dragAndDropState: null,
      isResizing: false,
      resizeColumn: null,
      resizeIndicator: SemiResizeIndicator.full,
      imageLoader: null,
      spriteManager: null,
    );

  SemiDrawGridArg copyArg(
    SemiDrawGridArg base,
    {
    Object? width,
    Object? height,
    Object? headerHeight,
    Object? groupHeaderHeight,
    Object? enableGroups,
    Object? cellXOffset,
    Object? cellYOffset,
    Object? translateX,
    Object? translateY,
    Object? mappedColumns,
    Object? freezeColumns,
    Object? freezeTrailingRows,
    Object? rows,
    Object? rowHeight,
    Object? theme,
    Object? selection,
    Object? isFocused,
    Object? drawFocus,
    Object? verticalBorder,
    Object? getCellContent,
    Object? getCellRenderer,
    Object? metrics,
    Object? getRowThemeOverride,
    Object? getGroupDetails,
    Object? hoverValues,
    Object? hoverInfo,
    Object? hoverPosition,
    Object? damage,
    Object? hasAppendRow,
    Object? touchMode,
    Object? fillHandle,
    Object? disabledRows,
    Object? prelightCells,
    Object? highlightRegions,
    Object? drawHeaderCallback,
    Object? drawCellCallback,
    Object? fixedShadowX,
    Object? fixedShadowY,
    Object? hyperWrapping,
    Object? enqueue,
    Object? minimumCellWidth,
    Object? dragAndDropState,
    Object? isResizing,
    Object? resizeColumn,
    Object? resizeIndicator,
    Object? imageLoader,
    Object? spriteManager,
  }
  ) {
    return SemiDrawGridArg(
    width: width as double? ?? base.width,
    height: height as double? ?? base.height,
    headerHeight: headerHeight as double? ?? base.headerHeight,
    groupHeaderHeight: groupHeaderHeight as double? ?? base.groupHeaderHeight,
    enableGroups: enableGroups as bool? ?? base.enableGroups,
    cellXOffset: cellXOffset as int? ?? base.cellXOffset,
    cellYOffset: cellYOffset as int? ?? base.cellYOffset,
    translateX: translateX as double? ?? base.translateX,
    translateY: translateY as double? ?? base.translateY,
    mappedColumns: mappedColumns as List<SemiMappedColumn>? ?? base.mappedColumns,
    freezeColumns: freezeColumns as int? ?? base.freezeColumns,
    freezeTrailingRows: freezeTrailingRows as int? ?? base.freezeTrailingRows,
    rows: rows as int? ?? base.rows,
    rowHeight: rowHeight as SemiRowHeight? ?? base.rowHeight,
    theme: theme as SemiDataGridTheme? ?? base.theme,
    selection: selection as SemiGridSelection? ?? base.selection,
    isFocused: isFocused as bool? ?? base.isFocused,
    drawFocus: drawFocus as bool? ?? base.drawFocus,
    verticalBorder: verticalBorder as bool Function(int col)? ?? base.verticalBorder,
    getCellContent: getCellContent as SemiGridCell Function(SemiItem item)? ?? base.getCellContent,
    getCellRenderer: getCellRenderer as SemiGetCellRenderer? ?? base.getCellRenderer,
    metrics: metrics as SemiTextMetrics? ?? base.metrics,
    getRowThemeOverride: getRowThemeOverride as SemiGetRowThemeOverride? ?? base.getRowThemeOverride,
    getGroupDetails: getGroupDetails as SemiGroupDetails Function(String group)? ?? base.getGroupDetails,
    hoverValues: hoverValues as SemiHoverValues? ?? base.hoverValues,
    hoverInfo: hoverInfo as SemiItem? ?? base.hoverInfo,
    hoverPosition: hoverPosition as Offset? ?? base.hoverPosition,
    damage: damage as SemiCellSet? ?? base.damage,
    hasAppendRow: hasAppendRow as bool? ?? base.hasAppendRow,
    touchMode: touchMode as bool? ?? base.touchMode,
    fillHandle: fillHandle as SemiFillHandleConfig? ?? base.fillHandle,
    disabledRows: disabledRows as SemiCompactSelection? ?? base.disabledRows,
    prelightCells: prelightCells as List<SemiItem>? ?? base.prelightCells,
    highlightRegions: highlightRegions as List<SemiDataGridHighlight>? ?? base.highlightRegions,
    drawHeaderCallback: drawHeaderCallback as SemiDrawHeaderCallback? ?? base.drawHeaderCallback,
    drawCellCallback: drawCellCallback as SemiDrawCellCallback? ?? base.drawCellCallback,
    fixedShadowX: fixedShadowX as bool? ?? base.fixedShadowX,
    fixedShadowY: fixedShadowY as bool? ?? base.fixedShadowY,
    hyperWrapping: hyperWrapping as bool? ?? base.hyperWrapping,
    enqueue: enqueue as void Function(SemiItem item)? ?? base.enqueue,
    minimumCellWidth: minimumCellWidth as double? ?? base.minimumCellWidth,
    dragAndDropState: dragAndDropState as SemiColumnDndState? ?? base.dragAndDropState,
    isResizing: isResizing as bool? ?? base.isResizing,
    resizeColumn: resizeColumn as int? ?? base.resizeColumn,
    resizeIndicator: resizeIndicator as SemiResizeIndicator? ?? base.resizeIndicator,
    imageLoader: imageLoader as SemiImageWindowLoader? ?? base.imageLoader,
    spriteManager: spriteManager as SemiSpriteManager? ?? base.spriteManager,
    );
  }

    /// One entry per field of [SemiDrawGridArg]: each rebuilds the arg with
    /// exactly that field changed, which must flip `shouldRepaint`.
    final changes = <String, SemiDrawGridArg Function(SemiDrawGridArg)>{
      'width': (base) => copyArg(base, width: base.width + 1),
      'height': (base) => copyArg(base, height: base.height + 1),
      'headerHeight': (base) => copyArg(base, headerHeight: base.headerHeight + 1),
      'groupHeaderHeight': (base) => copyArg(base, groupHeaderHeight: base.groupHeaderHeight + 1),
      'enableGroups': (base) => copyArg(base, enableGroups: !base.enableGroups),
      'cellXOffset': (base) => copyArg(base, cellXOffset: base.cellXOffset + 1),
      'cellYOffset': (base) => copyArg(base, cellYOffset: base.cellYOffset + 1),
      'translateX': (base) => copyArg(base, translateX: base.translateX + 1),
      'translateY': (base) => copyArg(base, translateY: base.translateY + 1),
      // Deliberately a *non*-const list with equal content: `mappedColumns`
      // is compared by identity (as upstream compares the array), so a fresh
      // instance has to repaint even though every column matches. A `const`
      // literal would be canonicalized onto the same instance and prove
      // nothing.
      'mappedColumns': (base) => copyArg(base, mappedColumns: [
        base.mappedColumns.first,
      ]),
      'freezeColumns': (base) => copyArg(base, freezeColumns: base.freezeColumns + 1),
      'freezeTrailingRows': (base) => copyArg(base, freezeTrailingRows: base.freezeTrailingRows + 1),
      'rows': (base) => copyArg(base, rows: base.rows + 1),
      'rowHeight': (base) => copyArg(base, rowHeight: const SemiRowHeight.fixed(31)),
      'theme': (base) => copyArg(base, theme: const SemiThemeOverride(bgCell: Color(0xFF000000)).applyTo(SemiDataGridTheme.light())),
      'selection': (base) => copyArg(base, selection: const SemiGridSelection(
            current: SemiGridSelectionCurrent(
              cell: SemiItem(1, 1),
              range: SemiRectangle(x: 1, y: 1, width: 1, height: 1),
            ),
          )),
      'isFocused': (base) => copyArg(base, isFocused: !base.isFocused),
      'drawFocus': (base) => copyArg(base, drawFocus: !base.drawFocus),
      'verticalBorder': (base) => copyArg(base, verticalBorder: (_) => false),
      'getCellContent': (base) => copyArg(base, getCellContent: (item) => const SemiTextCell(data: 'x', displayData: 'x')),
      'getCellRenderer': (base) => copyArg(base, getCellRenderer: (_) => null),
      'metrics': (base) => copyArg(base, metrics: SemiTextMetrics()),
      'getRowThemeOverride': (base) => copyArg(base, getRowThemeOverride: (_) => null),
      'getGroupDetails': (base) => copyArg(base, getGroupDetails: (_) => const SemiGroupDetails(name: 'g')),
      'hoverValues': (base) => copyArg(base, hoverValues: {const SemiItem(0, 0): 1.0}),
      'hoverInfo': (base) => copyArg(base, hoverInfo: const SemiItem(0, 0)),
      'hoverPosition': (base) => copyArg(base, hoverPosition: const Offset(1, 1)),
      'damage': (base) => copyArg(base, damage: SemiCellSet(const [SemiItem(0, 0)])),
      'hasAppendRow': (base) => copyArg(base, hasAppendRow: !base.hasAppendRow),
      'touchMode': (base) => copyArg(base, touchMode: !base.touchMode),
      'fillHandle': (base) => copyArg(base, fillHandle: const SemiFillHandleConfig(shape: SemiFillHandleShape.circle)),
      'disabledRows': (base) => copyArg(base, disabledRows: const SemiCompactSelection.empty().add(0)),
      'prelightCells': (base) => copyArg(base, prelightCells: const [SemiItem(0, 0)]),
      'highlightRegions': (base) => copyArg(base, highlightRegions: const [
            SemiDataGridHighlight(
              range: SemiRectangle(x: 0, y: 0, width: 1, height: 1),
              color: Color(0xFFFF0000),
            ),
          ]),
      'drawHeaderCallback': (base) => copyArg(base, drawHeaderCallback: (_, _) {}),
      'drawCellCallback': (base) => copyArg(base, drawCellCallback: (_, _) {}),
      'fixedShadowX': (base) => copyArg(base, fixedShadowX: !base.fixedShadowX),
      'fixedShadowY': (base) => copyArg(base, fixedShadowY: !base.fixedShadowY),
      'hyperWrapping': (base) => copyArg(base, hyperWrapping: !base.hyperWrapping),
      'enqueue': (base) => copyArg(base, enqueue: (_) {}),
      'minimumCellWidth': (base) => copyArg(base, minimumCellWidth: base.minimumCellWidth + 1),
      'dragAndDropState': (base) => copyArg(base, dragAndDropState: const SemiColumnDndState(src: 0, dest: 1)),
      'isResizing': (base) => copyArg(base, isResizing: !base.isResizing),
      'resizeColumn': (base) => copyArg(base, resizeColumn: 0),
      'resizeIndicator': (base) => copyArg(base, resizeIndicator: SemiResizeIndicator.none),
      'imageLoader': (base) => copyArg(base, imageLoader: SemiImageWindowLoader()),
      'spriteManager': (base) => copyArg(base, spriteManager: SemiSpriteManager(icons: const {}, settled: () {})),
    };

    test('an arg rebuilt from equal values does not repaint', () {
      final base = baseArg();
      expect(
        SemiDataGridPainter(copyArg(base)).shouldRepaint(
          SemiDataGridPainter(base),
        ),
        isFalse,
        reason: 'value-equal args must reuse the previous frame',
      );
      expect(
        SemiDataGridPainter(base).shouldRepaint(SemiDataGridPainter(base)),
        isFalse,
      );
    });

    test('a variable row height compares its function', () {
      // `SemiRowHeight.==` used to look only at the fixed branch, so two
      // different row-height formulas were "equal" and a grid that swapped
      // them would never repaint.
      expect(
        const SemiRowHeight.variable(_shortRowHeight) ==
            const SemiRowHeight.variable(_tallRowHeight),
        isFalse,
      );
      expect(
        const SemiRowHeight.variable(_shortRowHeight) ==
            const SemiRowHeight.variable(_shortRowHeight),
        isTrue,
      );
    });

    test('value types compare by value, not by identity', () {
      final base = baseArg();
      // Built without `const` so the two sides are genuinely distinct
      // instances: without an `==` on these types every drag frame and every
      // fill-handle tweak would repaint.
      final withValues = copyArg(
        base,
        dragAndDropState: SemiColumnDndState(src: 0, dest: 1),
        fillHandle: SemiFillHandleConfig(shape: SemiFillHandleShape.circle),
      );
      final equalAgain = copyArg(
        base,
        dragAndDropState: SemiColumnDndState(src: 0, dest: 1),
        fillHandle: SemiFillHandleConfig(shape: SemiFillHandleShape.circle),
      );
      expect(
        SemiDataGridPainter(withValues).shouldRepaint(
          SemiDataGridPainter(equalAgain),
        ),
        isFalse,
      );

      final moved = copyArg(
        base,
        dragAndDropState: SemiColumnDndState(src: 0, dest: 2),
      );
      expect(
        SemiDataGridPainter(moved).shouldRepaint(
          SemiDataGridPainter(withValues),
        ),
        isTrue,
      );
    });

    test('every field gates a repaint when it changes', () {
      final base = baseArg();
      final painter = SemiDataGridPainter(base);
      for (final entry in changes.entries) {
        expect(
          SemiDataGridPainter(entry.value(base)).shouldRepaint(painter),
          isTrue,
          reason: 'changing ${entry.key} must repaint',
        );
      }
      expect(changes, hasLength(47));
    });

    test('the arg declares no field that _argEquals ignores', () {
      // A source-level guard: the behavioural table above can only cover the
      // fields someone remembered to list, so the list is checked against the
      // real declaration. One omission here means "that prop changed and the
      // grid never repainted".
      final argSource = File(
        'lib/src/semi_data_grid/internal/data_grid/render/semi_draw_grid_arg.dart',
      ).readAsStringSync();
      final painterSource = File(
        'lib/src/semi_data_grid/internal/data_grid/render/semi_data_grid_painter.dart',
      ).readAsStringSync();

      final classStart = argSource.indexOf('class SemiDrawGridArg');
      expect(classStart, greaterThan(0));
      final declared = RegExp(
        r'^\s+final\s+(.*?)\s+(\w+);',
        multiLine: true,
      )
          .allMatches(argSource.substring(classStart))
          .map((m) => m.group(2)!)
          .toSet();

      final eqStart = painterSource.indexOf('bool _argEquals');
      expect(eqStart, greaterThan(0));
      final eqBody = painterSource.substring(
        eqStart,
        painterSource.indexOf('\n  }', eqStart),
      );

      for (final field in declared) {
        expect(
          eqBody.contains('a.$field'),
          isTrue,
          reason: '$field is declared but never compared in _argEquals',
        );
      }
      expect(changes.keys, unorderedEquals(declared));
    });
  });

  // -------------------------------------------------------------------------
  // Rebuild cost (`data-grid-render.blit.ts:233`)
  // -------------------------------------------------------------------------

  group('repaint on rebuild', () {
    /// Pumps the grid twice — once with the [from] props, once with the
    /// [to] props — and reports how many cell draws the second pump added.
    /// Zero means the painter recognised the frame as unchanged and skipped
    /// it; anything else is a real repaint.
    Future<int> rebuildCost(
      WidgetTester tester, {
      required List<SemiGridColumn> from,
      required List<SemiGridColumn> to,
      int fromOffset = 0,
      int toOffset = 0,
      SemiDataGridTheme? fromTheme,
      SemiDataGridTheme? toTheme,
    }) async {
      final draws = <int>[];
      // Hoisted: a fresh closure per build would make `getCellRenderer`
      // differ by identity and force a repaint, which is exactly what the
      // first case here must not do.
      SemiCellRenderer renderer(SemiGridCell cell) =>
          FrameCountingRenderer(draws);

      Widget build(List<SemiGridColumn> columns, int offset, SemiDataGridTheme theme) =>
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 300,
              child: SemiDataGrid(
                props: SemiDataGridProps(
                  width: 400,
                  height: 300,
                  columns: columns,
                  rows: 10,
                  rowHeight: const SemiRowHeight.fixed(30),
                  headerHeight: 30,
                  theme: theme,
                  verticalBorder: _stableBorder,
                  cellXOffset: offset,
                  getCellRenderer: renderer,
                  getCellContent: _stableContent,
                  onItemHovered: (_) {},
                  onMouseMove: (_) {},
                  onMouseDown: (_) {},
                  onMouseUp: (_, _) {},
                  onContextMenu: (_, _) {},
                  onCanvasFocused: () {},
                  onCanvasBlur: () {},
                  onCellFocused: (_) {},
                  onKeyDown: (_) {},
                ),
              ),
            ),
          );

      await tester.pumpWidget(
        build(from, fromOffset, fromTheme ?? SemiDataGridTheme.light()),
      );
      await tester.pumpAndSettle();
      final first = draws.length;
      await tester.pumpWidget(
        build(to, toOffset, toTheme ?? SemiDataGridTheme.light()),
      );
      await tester.pumpAndSettle();
      return draws.length - first;
    }

    List<SemiGridColumn> columnsOf(double width) => [
      for (var i = 0; i < 4; i++) SemiGridColumn(title: 'C$i', width: width),
    ];

    testWidgets('rebuilding with identical props does not repaint', (
      tester,
    ) async {
      final columns = columnsOf(100);
      expect(
        await rebuildCost(tester, from: columns, to: columns),
        0,
        reason: 'nothing visible changed, so the layer is reused',
      );
    });

    testWidgets('a resized column does repaint', (tester) async {
      expect(
        await rebuildCost(
          tester,
          from: columnsOf(100),
          to: columnsOf(150),
        ),
        greaterThan(0),
      );
    });

    testWidgets('a new columns list with equal content does repaint', (
      tester,
    ) async {
      // `mappedColumns` is keyed by reference, exactly as upstream's
      // `useMemo(..., [columns])`: a caller that rebuilds its list pays for
      // a redraw even when every value happens to match.
      expect(
        await rebuildCost(tester, from: columnsOf(100), to: columnsOf(100)),
        greaterThan(0),
      );
    });

    testWidgets('a different scroll offset does repaint', (tester) async {
      expect(
        await rebuildCost(
          tester,
          from: columnsOf(100),
          to: columnsOf(100),
          toOffset: 1,
        ),
        greaterThan(0),
      );
    });

    testWidgets('a different theme does repaint', (tester) async {
      expect(
        await rebuildCost(
          tester,
          from: columnsOf(100),
          to: columnsOf(100),
          fromTheme: SemiDataGridTheme.light(),
          toTheme: const SemiThemeOverride(
            bgCell: Color(0xFF000000),
          ).applyTo(SemiDataGridTheme.light()),
        ),
        greaterThan(0),
      );
    });

    testWidgets('rebuilding the editor with identical props does not repaint', (
      tester,
    ) async {
      // The editor path, where the per-build allocations live: the merged
      // `headerIcons` map, the `drawCell` marker-offset wrapper, the derived
      // highlight list and the `_mangledColumns` list. Each of them used to
      // be a fresh object per build, so an editor never reused a frame.
      final draws = <int>[];
      final lookup = SemiDefaultRendererLookup(
        extra: {SemiCellKind.text: FrameCountingRenderer(draws)},
      );
      final columns = [
        for (var i = 0; i < 4; i++) SemiGridColumn(title: 'C$i', width: 100),
      ];

      // Function props hoisted: a closure per build differs by `==` and would
      // force a repaint for reasons that have nothing to do with the editor.
      bool border(int col) => true;
      SemiGridCell content(SemiItem item, [bool? strict]) =>
          const SemiTextCell(data: '', displayData: '');
      void drawCell(SemiDrawCellArgs args, VoidCallback draw) => draw();
      void drawHeader(SemiDrawHeaderArgs args, VoidCallback draw) => draw();

      Widget build() => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: SemiDataEditor(
              props: SemiDataEditorProps(
                columns: columns,
                rows: 10,
                getCellContent: content,
                theme: SemiDataGridTheme.light(),
                verticalBorder: border,
                rendererLookup: lookup,
                rowHeight: const SemiRowHeight.fixed(32),
                headerHeight: 32,
                enableGroups: true,
                groupHeaderHeight: 30,
                freezeColumns: 1,
                rowMarkers: const SemiRowMarkerOptions(width: 40),
                drawCell: drawCell,
                drawHeader: drawHeader,
                // A non-empty highlight list: the editor derives a fresh
                // list (and fresh `SemiDataGridHighlight`s) on every build, so this
                // is what forces the value comparison rather than identity.
                highlightRegions: const [
                  SemiDataGridHighlight(
                    range: SemiRectangle(x: 0, y: 0, width: 2, height: 2),
                    color: Color(0xFF4F5DFF),
                  ),
                ],
                onGridSelectionChange: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      final first = draws.length;
      expect(first, greaterThan(0), reason: 'the fixture must paint cells');

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(
        draws.length - first,
        0,
        reason: 'nothing visible changed, so the layer is reused',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Cursor (`data-grid.tsx:973-985`)
  // -------------------------------------------------------------------------

  group('cursor', () {
    /// Hovers [at] and reports the cursor the grid's `MouseRegion` asks for.
    Future<MouseCursor> cursorAt(
      WidgetTester tester, {
      required Offset at,
      required bool allowResize,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: SemiDataGrid(
              props: SemiDataGridProps(
                width: 400,
                height: 300,
                columns: const [SemiGridColumn(title: 'C0', width: 100)],
                rows: 10,
                rowHeight: const SemiRowHeight.fixed(30),
                headerHeight: 30,
                theme: SemiDataGridTheme.light(),
                verticalBorder: _stableBorder,
                allowResize: allowResize,
                getCellRenderer: SemiDefaultRendererLookup().forCell,
                getCellContent: _stableContent,
                onItemHovered: (_) {},
                onMouseMove: (_) {},
                onMouseDown: (_) {},
                onMouseUp: (_, _) {},
                onContextMenu: (_, _) {},
                onCanvasFocused: () {},
                onCanvasBlur: () {},
                onCellFocused: (_) {},
                onKeyDown: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(at);
      await tester.pump();
      return tester.widget<MouseRegion>(find.byType(MouseRegion)).cursor;
    }

    testWidgets('the resize edge of a resizable header shows the resize '
        'cursor', (tester) async {
      expect(
        await cursorAt(
          tester,
          at: const Offset(99, 15),
          allowResize: true,
        ),
        SystemMouseCursors.resizeColumn,
      );
    });

    testWidgets('a plain cell never shows the resize cursor', (tester) async {
      // The regression this guards: `_updateCursor` used to read
      // `cell && allowResize`, so wiring `allowResize` (as the editor does)
      // painted a resize cursor over every cell.
      expect(
        await cursorAt(tester, at: const Offset(50, 45), allowResize: true),
        MouseCursor.defer,
      );
    });

    testWidgets('an edge you cannot resize through is not a resize edge', (
      tester,
    ) async {
      expect(
        await cursorAt(tester, at: const Offset(99, 15), allowResize: false),
        MouseCursor.defer,
      );
    });
  });

  group('Semi theming', () {
    test('SemiDataGridTheme.fromSemiTheme maps palette, type and radius', () {
      const light = SemiThemeData.light();
      final theme = SemiDataGridTheme.fromSemiTheme(light);

      expect(theme.accentColor, light.colors.colorPrimary);
      expect(theme.bgCell, light.colors.colorBg0);
      expect(theme.borderColor, light.colors.colorBorder);
      expect(theme.linkColor, light.colors.colorLink);
      expect(theme.baseFontSize, light.typography.fontSizeRegular);
      expect(theme.headerFontWeight, light.typography.fontWeightBold);
      expect(theme.fontFamily, light.typography.fontFamily);
      expect(theme.fontFamilyFallback, light.typography.fontFamilyFallback);
      expect(theme.roundingRadius, 3);

      const dark = SemiThemeData.dark();
      final darkTheme = SemiDataGridTheme.fromSemiTheme(dark);
      expect(darkTheme.bgCell, dark.colors.colorBg0);
      expect(darkTheme.textDark, dark.colors.colorText0);
      expect(darkTheme.accentColor, dark.colors.colorPrimary);
    });

    testWidgets('the editor follows SemiTheme unless a theme is supplied', (
      tester,
    ) async {
      Widget build(SemiThemeData semi, {SemiDataGridTheme? theme}) => MaterialApp(
        home: SemiTheme(
          data: semi,
          child: SizedBox(
            width: 400,
            height: 300,
            child: SemiDataEditor(
              props: SemiDataEditorProps(
                columns: const [
                  SemiGridColumn(title: 'A', width: 100),
                ],
                rows: 2,
                getCellContent: (item, [_]) => const SemiTextCell(
                  data: 'x',
                  displayData: 'x',
                ),
                theme: theme,
              ),
            ),
          ),
        ),
      );

      const light = SemiThemeData.light();
      await tester.pumpWidget(build(light));
      SemiDataGridTheme resolved() =>
          tester.widget<SemiDataGrid>(find.byType(SemiDataGrid)).props.theme!;
      expect(resolved().accentColor, light.colors.colorPrimary);
      expect(resolved().bgCell, light.colors.colorBg0);

      const dark = SemiThemeData.dark();
      await tester.pumpWidget(build(dark));
      expect(resolved().accentColor, dark.colors.colorPrimary);
      expect(resolved().bgCell, dark.colors.colorBg0);

      final custom = SemiDataGridTheme.light();
      await tester.pumpWidget(build(dark, theme: custom));
      expect(identical(resolved(), custom), isTrue);
    });
  });
}
