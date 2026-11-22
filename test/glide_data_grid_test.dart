import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/glide/internal/data_grid/render/glide_data_grid_painter.dart';
import 'package:semi_design_flutter/src/glide/internal/data_grid/render/glide_draw_grid_arg.dart';

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
// Selection (`internal/data-grid/glide_selection.dart`)
// ---------------------------------------------------------------------------

/// Records every `draw` and the `frameTime` it was given, so a test can tell
/// a live clock (`data-grid-render.cells.ts:113`) from the constant `0` this
/// port used to ship.
class FrameCountingRenderer extends GlideCellRenderer {
  FrameCountingRenderer(this.frameTimes);

  final List<int> frameTimes;

  @override
  GlideCellKind get kind => GlideCellKind.text;

  @override
  void draw(GlideDrawCellArgs args) => frameTimes.add(args.frameTime);
}

/// Stable tear-offs for the repaint fixture: `GlideDrawGridArg` compares
/// function props by identity, so a closure created per build would force a
/// repaint and hide the very thing under test.
GlideGridCell _stableContent(GlideItem item, [bool? getSticky]) =>
    const GlideTextCell(data: '', displayData: '');

bool _stableBorder(int col) => true;

/// Top-level so `const GlideRowHeight.variable(...)` is a constant: local
/// function tear-offs are not.
double _shortRowHeight(int row) => 24;
double _tallRowHeight(int row) => 48;

class FakeClipboard extends GlideClipboard {
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
  group('GlideCompactSelection', () {
    test('add merges overlapping slices', () {
      var sel = const GlideCompactSelection.empty();
      sel = sel.add(3);
      sel = sel.add(GlideSlice(4, 7));
      expect(sel.toArray(), [3, 4, 5, 6]);
      expect(sel.length, 4);
      expect(sel.firstIndex, 3);
      expect(sel.lastIndex, 6);
    });

    test('remove subtracts a range', () {
      final sel = GlideCompactSelection.fromArray([0, 1, 2, 3, 4])
          .remove(GlideSlice(1, 4));
      expect(sel.toArray(), [0, 4]);
      expect(sel.hasIndex(2), isFalse);
      expect(sel.hasIndex(4), isTrue);
    });

    test('hasAll and some', () {
      final sel = GlideCompactSelection.fromArray([2, 3, 9]);
      expect(sel.hasAll(const GlideSlice(2, 4)), isTrue);
      expect(sel.hasAll(const GlideSlice(2, 5)), isFalse);
      expect(sel.some((i) => i > 5), isTrue);
      expect(sel.some((i) => i > 99), isFalse);
    });

    test('offset shifts every slice', () {
      final sel = GlideCompactSelection.fromArray([0, 1]).offset(10);
      expect(sel.toArray(), [10, 11]);
    });
  });

  // -------------------------------------------------------------------------
  // Visible region (`internal/scrolling-data-grid/scrolling-data-grid.tsx`)
  // -------------------------------------------------------------------------

  group('computeVisibleRegion', () {
    final columns = [
      for (var i = 0; i < 10; i++)
        GlideMappedColumn(
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
        rowHeight: const GlideRowHeight.fixed(34),
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
        rowHeight: const GlideRowHeight.fixed(34),
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
        rowHeight: const GlideRowHeight.fixed(34),
        rows: 100,
        freezeColumns: 0,
        smoothScrollY: true,
      );
      expect(region.y, 0);
      expect(region.translateY, -17);
    });

    test('horizontal scrolling with frozen columns keeps the sticky pane', () {
      final frozen = [
        GlideMappedColumn(
          sourceIndex: 0,
          sticky: true,
          title: 'Frozen',
          width: 100,
        ),
        for (var i = 1; i < 10; i++)
          GlideMappedColumn(
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
        rowHeight: const GlideRowHeight.fixed(34),
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

  group('GlideDataGrid', () {
    late List<GlideGridColumn> columns;
    late List<List<GlideGridCell>> cells;
    late List<GlideItem> locationLog;

    Widget buildGrid({
      bool groups = false,
      GlideDrawCellCallback? drawCell,
      GlideGetCellRenderer? getCellRenderer,
    }) {
      locationLog = [];
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: GlideDataGrid(
            props: GlideDataGridProps(
              width: 400,
              height: 300,
              columns: columns,
              rows: 10,
              rowHeight: const GlideRowHeight.fixed(30),
              headerHeight: 30,
              enableGroups: groups,
              getCellContent: (item, [_]) => cells[item.row][item.col],
              getCellRenderer:
                  getCellRenderer ?? GlideDefaultRendererLookup().forCell,
              drawCell: drawCell,
              theme: GlideTheme.light(),
              verticalBorder: (_) => true,
              onItemHovered: (_) {},
              onMouseMove: (_) {},
              onMouseDown: (args) {
                if (args is GlideGridCellMouseArgs) {
                  locationLog.add(args.location);
                } else if (args is GlideGridHeaderMouseArgs) {
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
      void Function(GlideItem item)? enqueue,
    }) {
      final renderer = FrameCountingRenderer(frameTimes);
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: GlideDataGrid(
            props: GlideDataGridProps(
              width: 400,
              height: 300,
              columns: [
                for (var i = 0; i < 4; i++)
                  GlideGridColumn(title: 'C$i', width: 100),
              ],
              rows: 10,
              rowHeight: const GlideRowHeight.fixed(30),
              headerHeight: 30,
              getCellContent: (item, [_]) => GlideTextCell(
                data: 'r${item.row} c${item.col}',
                displayData: 'r${item.row} c${item.col}',
                lastUpdated: lastUpdated,
              ),
              getCellRenderer: (cell) => renderer,
              theme: GlideTheme.light(),
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
        for (var i = 0; i < 4; i++) GlideGridColumn(title: 'C$i', width: 100),
      ];
      cells = [
        for (var row = 0; row < 10; row++)
          [
            for (var col = 0; col < 4; col++)
              GlideTextCell(data: 'r$row c$col', displayData: 'r$row c$col'),
          ],
      ];
    });

    testWidgets('a running lastUpdated flash asks for the next frame', (
      tester,
    ) async {
      final frameTimes = <int>[];
      final enqueued = <GlideItem>[];
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
      final enqueued = <GlideItem>[];

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
      final seen = <GlideItem>[];
      final draws = <int>[];

      // A consumer that never calls `drawContent` owns the paint entirely
      // (`data-grid-render.cells.ts:545-547`).
      await tester.pumpWidget(
        buildGrid(
          drawCell: (args, draw) => seen.add(GlideItem(args.col, args.row)),
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
      final seen = <GlideItem>[];
      final draws = <int>[];

      await tester.pumpWidget(
        buildGrid(
          drawCell: (args, draw) {
            seen.add(GlideItem(args.col, args.row));
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
      final lookup = GlideDefaultRendererLookup();
      expect(lookup.forCell(cells[0][0]), isA<GlideTextCellRenderer>());
      expect(
        lookup.forCell(const GlideBooleanCell(data: GlideBooleanValue.checked)),
        isA<GlideBooleanCellRenderer>(),
      );
      expect(
        lookup.forCell(const GlideNumberCell(data: 1, displayData: '1')),
        isA<GlideNumberCellRenderer>(),
      );
      expect(
        lookup.forCell(const GlideBubbleCell(data: ['a'])),
        isA<GlideBubbleCellRenderer>(),
      );
      expect(
        lookup.forCell(const GlideLoadingCell()),
        isA<GlideLoadingCellRenderer>(),
      );
      expect(
        lookup.forCell(const GlideProtectedCell()),
        isA<GlideProtectedCellRenderer>(),
      );
      expect(
        lookup.forCell(
          const GlideMarkerCell(
            row: 0,
            drawHandle: false,
            checked: GlideBooleanValue.empty,
            checkboxStyle: GlideMarkerCheckboxStyle.square,
            markerKind: GlideMarkerKind.checkbox,
          ),
        ),
        isA<GlideMarkerCellRenderer>(),
      );
      expect(
        lookup.forCell(const GlideNewRowCell(hint: 'Add row')),
        isA<GlideNewRowCellRenderer>(),
      );
    });

    testWidgets('tapping a cell reports its location', (tester) async {
      await tester.pumpWidget(buildGrid());

      // Row 0 occupies y in [30, 60); column 1 occupies x in [100, 200).
      final gesture = await tester.startGesture(const Offset(150, 45));
      await gesture.up();
      await tester.pump();

      expect(locationLog, hasLength(1));
      expect(locationLog.single, const GlideItem(1, 0));
    });

    testWidgets('tapping the header reports the header row', (tester) async {
      await tester.pumpWidget(buildGrid());

      final gesture = await tester.startGesture(const Offset(150, 15));
      await gesture.up();
      await tester.pump();

      expect(locationLog, hasLength(1));
      expect(locationLog.single.row, GlideItem.headerRow);
      expect(locationLog.single.col, 1);
    });
  });

  // -------------------------------------------------------------------------
  // Cell renderers (`cells/*.tsx`)
  // -------------------------------------------------------------------------

  group('cell renderers', () {
    test('boolean toggle follows data-editor-fns', () {
      expect(
        toggleBoolean(GlideBooleanValue.checked),
        GlideBooleanValue.unchecked,
      );
      expect(
        toggleBoolean(GlideBooleanValue.unchecked),
        GlideBooleanValue.checked,
      );
      expect(toggleBoolean(GlideBooleanValue.empty), GlideBooleanValue.checked);
      expect(
        toggleBoolean(GlideBooleanValue.indeterminate),
        GlideBooleanValue.checked,
      );
    });

    test('text renderer measures wrapped and single-line widths', () {
      const renderer = GlideTextCellRenderer();
      final theme = GlideTheme.light();
      final metrics = GlideTextMetrics();

      const single = GlideTextCell(data: 'hello', displayData: 'hello');
      const wrapped = GlideTextCell(
        data: 'hello\nhi',
        displayData: 'hello\nhi',
        allowWrapping: true,
      );

      // A wrapping cell measures its widest line; a non-wrapping one only
      // ever measures the first line (`text-cell.tsx:24-31`).
      final singleWidth = renderer.measure(single, theme, metrics)!;
      final wrappedWidth = renderer.measure(wrapped, theme, metrics)!;
      expect(wrappedWidth, singleWidth);

      const clipped = GlideTextCell(
        data: 'hi\nhello',
        displayData: 'hi\nhello',
      );
      expect(renderer.measure(clipped, theme, metrics)!, lessThan(singleWidth));
      expect(singleWidth, greaterThan(theme.cellHorizontalPadding * 2));
    });

    test('boolean renderer always measures 50', () {
      const renderer = GlideBooleanCellRenderer();
      final width = renderer.measure(
        const GlideBooleanCell(data: GlideBooleanValue.checked),
        GlideTheme.light(),
        GlideTextMetrics(),
      );
      expect(width, 50);
    });
  });

  // -------------------------------------------------------------------------
  // Clipboard (`data-editor/copy-paste.ts`, `data-editor-fns.ts`)
  // -------------------------------------------------------------------------

  group('copy-paste', () {
    List<List<GlideGridCell>> sample() => [
      [
        const GlideTextCell(data: 'a\tb', displayData: 'a\tb'),
        const GlideNumberCell(data: 12.5, displayData: '12.5'),
        const GlideBooleanCell(data: GlideBooleanValue.checked),
        const GlideBooleanCell(data: GlideBooleanValue.indeterminate),
        const GlideBubbleCell(data: ['x', 'y']),
        const GlideUriCell(data: 'https://a.b/c', displayData: 'a.b/c'),
      ],
      [
        const GlideTextCell(data: 'say "hi"', displayData: 'say "hi"'),
        const GlideNumberCell(data: -3, displayData: '-3'),
        const GlideBooleanCell(data: GlideBooleanValue.unchecked),
        const GlideBooleanCell(data: GlideBooleanValue.empty),
        const GlideTextCell(data: 'p,q', displayData: 'p,q'),
        const GlideLoadingCell(),
      ],
    ];

    test('text buffer escapes tabs, quotes and commas', () {
      final contents = glideGetCopyBufferContents(sample(), const []);
      final lines = contents.textPlain.split('\n');
      expect(lines, hasLength(2));
      expect(lines[0], '"a\tb"\t12.5\tTRUE\tINDETERMINATE\tx,y\thttps://a.b/c');
      // A plain text cell is only escaped for tabs/newlines/quotes; commas
      // are escaped solely inside string-array cells (`copy-paste.ts:130`).
      expect(lines[1], '"say ""hi"""\t-3\tFALSE\t\tp,q\t#LOADING');
    });

    test('unquote round trips the text buffer', () {
      final contents = glideGetCopyBufferContents(sample(), const []);
      final parsed = glideUnquote(contents.textPlain);
      expect(parsed, hasLength(2));
      final first = parsed[0].cast<GlideBasicCellBuffer>();
      expect(first[0].formatted, 'a\tb');
      expect(first[1].formatted, '12.5');
      expect(first[2].formatted, 'TRUE');
      expect(first[4].formatted, 'x,y');

      final second = parsed[1].cast<GlideBasicCellBuffer>();
      expect(second[0].formatted, 'say "hi"');
      expect(second[4].formatted, 'p,q');
    });

    test('html buffer round trips through decodeHtml', () {
      final contents = glideGetCopyBufferContents(sample(), const []);
      final decoded = glideDecodeHtml(contents.textHtml);
      expect(decoded, isNotNull);
      expect(decoded, hasLength(2));

      final first = decoded![0].cast<GlideCellBuffer>();
      // Tabs become four spaces on the way to HTML so Sheets and Excel
      // keep them (`copy-paste.ts:155-162`).
      expect((first[0] as GlideBasicCellBuffer).formatted, 'a    b');
      expect((first[1] as GlideBasicCellBuffer).formatted, '12.5');
      expect((first[4] as GlideStringArrayCellBuffer).formatted, ['x', 'y']);
      expect((first[5] as GlideBasicCellBuffer).rawValue, 'https://a.b/c');

      final second = decoded[1].cast<GlideCellBuffer>();
      expect((second[0] as GlideBasicCellBuffer).formatted, 'say "hi"');
    });

    test('copyData bypasses escaping', () {
      final cell = const GlideTextCell(
        data: 'raw,\tvalue',
        displayData: 'ignored',
        copyData: 'raw,\tvalue',
      );
      final buffer = glideCreateBufferFromGridCells([
        [cell],
      ], const []);
      final basic = buffer[0][0] as GlideBasicCellBuffer;
      expect(basic.doNotEscape, isTrue);
      expect(glideCreateTextBuffer(buffer), 'raw,\tvalue');
    });
  });

  // -------------------------------------------------------------------------
  // Keybinds (`data-editor/data-editor-keybindings.ts`, `common/is-hotkey.ts`)
  // -------------------------------------------------------------------------

  group('keybindings', () {
    GlideGridKeyArgs key(
      String key,
      int keyCode, {
      bool alt = false,
      bool shift = false,
      bool ctrl = false,
      bool meta = false,
    }) => GlideGridKeyArgs(
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
      final keys = glideKeysWithDefaults(null);
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
      final keys = glideKeysWithDefaults(
        const GlideKeybinds(goDownCell: false, search: 'primary+k'),
      );
      expect(keys.goDownCell, '');
      expect(keys.search, 'primary+k');
      expect(keys.goUpCell, 'ArrowUp');
    });

    test('back-compat aliases fill in missing bindings', () {
      final keys = glideKeysWithDefaults(const GlideKeybinds(pageDown: true));
      expect(keys.goToNextPage, 'PageDown');
      expect(keys.goToPreviousPage, 'PageUp');
    });

    test('isHotkey matches modifiers, alternatives and key codes', () {
      final down = key('ArrowDown', 40);
      expect(glideIsHotkey('ArrowDown', down), isTrue);
      expect(glideIsHotkey('ArrowUp|ArrowDown', down), isTrue);
      expect(glideIsHotkey('ArrowUp', down), isFalse);
      expect(glideIsHotkey('alt+ArrowDown', down), isFalse);
      expect(
        glideIsHotkey('alt+ArrowDown', key('ArrowDown', 40, alt: true)),
        isTrue,
      );
      // `any+Escape` ignores modifiers entirely.
      expect(
        glideIsHotkey('any+Escape', key('Escape', 27, ctrl: true, alt: true)),
        isTrue,
      );
      // `_68` is the legacy key code for `d`.
      // `primary` still demands Ctrl (or Cmd on macOS) to be held.
      expect(glideIsHotkey('primary+_68', key('d', 68)), isFalse);
      expect(glideIsHotkey('primary+_68', key('d', 68, ctrl: true)), isTrue);
      expect(glideIsHotkey('primary+_68', key('d', 68, shift: true)), isFalse);
      // Single lower-case letters compare against the upper-case key code.
      expect(glideIsHotkey('primary+a', key('a', 65, ctrl: true)), isTrue);
      expect(glideIsHotkey('primary+a', key('a', 65)), isFalse);
      // Space is a literal space in the grammar.
      expect(glideIsHotkey('shift+ ', key(' ', 32, shift: true)), isTrue);
      expect(glideIsHotkey('ctrl+ ', key(' ', 32, ctrl: true)), isTrue);
      expect(glideIsHotkey('ctrl+ ', key(' ', 32, shift: true)), isFalse);
      // Empty expressions never match.
      expect(glideIsHotkey('', down), isFalse);
    });

    test('DOM key and key code translation', () {
      expect(glideDomKey(LogicalKeyboardKey.arrowDown), 'ArrowDown');
      expect(glideDomKeyCode(LogicalKeyboardKey.arrowDown), 40);
      expect(glideDomKey(LogicalKeyboardKey.enter), 'Enter');
      expect(glideDomKeyCode(LogicalKeyboardKey.enter), 13);
      expect(glideDomKey(LogicalKeyboardKey.space), ' ');
      expect(glideDomKeyCode(LogicalKeyboardKey.keyD), 68);
      expect(glideDomKey(LogicalKeyboardKey.keyD), 'd');
      expect(glideDomKeyCode(LogicalKeyboardKey.digit5), 53);
    });
  });

  // -------------------------------------------------------------------------
  // Selection behavior (`internal/data-grid/use-selection-behavior.ts`,
  // `data-editor.tsx:1838`)
  // -------------------------------------------------------------------------

  group('selection behavior', () {
    GlideDataEditorSelection editor({
      GlideSelectionBlending range = GlideSelectionBlending.exclusive,
      GlideSelectionBlending column = GlideSelectionBlending.exclusive,
      GlideRangeSelect rangeSelect = GlideRangeSelect.multiRect,
      bool columnSelectEnabled = true,
    }) => GlideDataEditorSelection(
      behaviorConfig: GlideBehaviorConfig(
        rangeBehavior: range,
        columnBehavior: column,
        rangeSelect: rangeSelect,
        columnSelectEnabled: columnSelectEnabled,
      ),
      rows: 100,
      rowSelectMulti: true,
      columnSelectMulti: true,
    );

    GlideGridMouseArgs cellClick(int col, int row, {bool shift = false}) =>
        GlideGridCellMouseArgs(
          shiftKey: shift,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
          isEdge: false,
          button: 0,
          buttons: 1,
          scrollEdge: (0, 0),
          location: GlideItem(col, row),
          bounds: GlideRectangle(
            x: col.toDouble(),
            y: row.toDouble(),
            width: 1,
            height: 1,
          ),
          isFillHandle: false,
          localEventX: 10,
          localEventY: 10,
        );

    GlideGridMouseArgs headerClick(int col, {bool shift = false}) =>
        GlideGridHeaderMouseArgs(
          shiftKey: shift,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
          isEdge: false,
          button: 0,
          buttons: 1,
          scrollEdge: (0, 0),
          location: GlideItem(col, GlideItem.headerRow),
          bounds: GlideRectangle(
            x: col.toDouble(),
            y: 0,
            width: 100,
            height: 30,
          ),
          group: '',
          localEventX: 10,
          localEventY: 10,
        );

    const noopCell = GlideTextCell(data: '', displayData: '');

    GlideSelectOutcome select(
      GlideDataEditorSelection state,
      GlideGridMouseArgs args,
    ) => state.handleSelect(
      args,
      getCellRenderer: (_) => null,
      getCellContent: (_) => noopCell,
      themeForCell: (_, _) => GlideTheme.light(),
    );

    test('clicking a cell moves the current range', () {
      final state = editor();
      select(state, cellClick(3, 7));
      expect(state.selection.current!.cell, const GlideItem(3, 7));
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
      expect(state.selection.current!.cell, const GlideItem(3, 7));
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
        GlideGridOutOfBoundsMouseArgs(
          shiftKey: false,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
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
      expect(state.selection.current, isNull);
      expect(outcome.onSelectionCleared, isTrue);
      expect(outcome.clearOverlay, isTrue);
    });

    test('clicking the scrollbar keeps the selection', () {
      final state = editor();
      select(state, cellClick(3, 7));
      select(
        state,
        GlideGridOutOfBoundsMouseArgs(
          shiftKey: false,
          ctrlKey: false,
          metaKey: false,
          isTouch: false,
          isEdge: false,
          button: 0,
          buttons: 0,
          scrollEdge: (1, 0),
          location: const GlideItem(0, 0),
          isMaybeScrollbar: true,
          region: (
            GlideOutOfBoundsRegionAxis.center,
            GlideOutOfBoundsRegionAxis.center,
          ),
        ),
      );
      expect(state.selection.current!.cell, const GlideItem(3, 7));
    });

    test('rangeSelect cell collapses every range to 1x1', () {
      final state = editor(rangeSelect: GlideRangeSelect.cell);
      select(state, cellClick(3, 7));
      select(state, cellClick(6, 5, shift: true));
      // `rangeSelect: cell` forces the range onto the anchor, so a
      // shift-click cannot grow it (`use-selection-behavior.ts:33-43`).
      final range = state.selection.current!.range;
      expect(range.width, 1);
      expect(range.height, 1);
      expect(range.x, 3);
      expect(range.y, 7);
      expect(state.selection.current!.cell, const GlideItem(3, 7));
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
    late List<GlideEditListItem> edits;
    late List<GlideScrollTarget> scrolls;

    GlideKeyHandler handler({
      GlideRangeSelect rangeSelect = GlideRangeSelect.multiRect,
      int columnCount = 10,
      int rows = 50,
      GlideGridSelection? initial,
      GlideGetCellsForSelection? getCellsForSelection,
      GlideDeleteCallback? onDelete,
      bool scrollToActiveCell = true,
      void Function(GlideItem location, GlideCellActivation activation)?
      onCellActivated,
    }) {
      edits = [];
      scrolls = [];
      return GlideKeyHandler(
        keys: glideKeysWithDefaults(null),
        selection:
            initial ??
            const GlideGridSelection(
              current: GlideGridSelectionCurrent(
                cell: GlideItem(2, 3),
                range: GlideRectangle(x: 2, y: 3, width: 1, height: 1),
              ),
            ),
        setGridSelection: (newVal, expand) {},
        columnCount: columnCount,
        rows: rows,
        rowMarkerOffset: 0,
        overlayOpen: false,
        columnSelect: GlideSelectMode.multi,
        rowSelect: GlideSelectMode.multi,
        rangeSelect: rangeSelect,
        visibleRegion: const GlideRectangle(x: 0, y: 0, width: 8, height: 20),
        getCellContent: (item) =>
            GlideTextCell(data: 'v${item.col}-${item.row}', displayData: 'x'),
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        getCellsForSelection: getCellsForSelection,
        scrollToActiveCell: scrollToActiveCell,
        onCellsEdited: (items) => edits.addAll(items),
        scrollTo: (target) => scrolls.add(target),
        onCellActivated: onCellActivated,
        onDelete: onDelete,
      );
    }

    GlideGridKeyArgs key(
      String key,
      int keyCode, {
      bool alt = false,
      bool shift = false,
      bool ctrl = false,
      bool meta = false,
      GlideRectangle? bounds,
    }) => GlideGridKeyArgs(
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
      expect(h.selection.current!.cell, const GlideItem(2, 4));

      h.handleFixedKeybindings(key('ArrowRight', 39));
      expect(h.selection.current!.cell, const GlideItem(3, 4));

      h.handleFixedKeybindings(key('ArrowUp', 38));
      h.handleFixedKeybindings(key('ArrowLeft', 37));
      expect(h.selection.current!.cell, const GlideItem(2, 3));
    });

    test('navigation clamps to the table bounds', () {
      final h = handler(
        columnCount: 4,
        rows: 5,
        initial: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(3, 4),
            range: GlideRectangle(x: 3, y: 4, width: 1, height: 1),
          ),
        ),
      );
      h.handleFixedKeybindings(key('ArrowDown', 40));
      expect(h.selection.current!.cell, const GlideItem(3, 4));

      h.handleFixedKeybindings(key('Home', 36));
      expect(h.selection.current!.cell.col, 0);
    });

    test('shift+arrow grows the range instead of moving the cell', () {
      final h = handler();
      h.handleFixedKeybindings(key('ArrowDown', 40, shift: true));
      final range = h.selection.current!.range;
      expect(h.selection.current!.cell, const GlideItem(2, 3));
      expect(range.height, 2);
      expect(scrolls.last.axis, GlideScrollAxis.vertical);
    });

    test('scrollToActiveCell false keeps the viewport put', () {
      // A plain arrow moves the cell, so it reaches the `scrollTo` at the
      // end of `updateSelectedCell` (`data-editor.tsx:3066-3068`).
      final still = handler(scrollToActiveCell: false);
      still.handleFixedKeybindings(key('ArrowDown', 40));
      expect(still.selection.current!.cell, const GlideItem(2, 4));
      expect(scrolls, isEmpty);

      // The default still follows the selection.
      final follows = handler();
      follows.handleFixedKeybindings(key('ArrowDown', 40));
      expect(follows.selection.current!.cell, const GlideItem(2, 4));
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
      expect(h.selection.current!.cell, const GlideItem(2, 3));
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
        initial: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(1, 1),
            range: GlideRectangle(x: 1, y: 1, width: 2, height: 2),
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
        const GlideItem(1, 1),
        const GlideItem(2, 1),
        const GlideItem(1, 2),
        const GlideItem(2, 2),
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
          final key = activation is GlideKeyboardCellActivation
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
            bounds: const GlideRectangle(x: 2, y: 3, width: 1, height: 1),
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
      expect(h.selection.current!.cell, const GlideItem(3, 5));
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
      final spanning = const GlideTextCell(
        data: 'wide',
        displayData: 'wide',
        span: (start: 0, end: 3),
      );
      final selection = const GlideGridSelection(
        current: GlideGridSelectionCurrent(
          cell: GlideItem(1, 0),
          range: GlideRectangle(x: 1, y: 0, width: 1, height: 1),
        ),
      );
      final expanded = glideExpandSelection(
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

    test('shiftSelection moves columns for the public API', () {
      const selection = GlideGridSelection(
        current: GlideGridSelectionCurrent(
          cell: GlideItem(2, 5),
          range: GlideRectangle(x: 2, y: 5, width: 3, height: 1),
        ),
        columns: GlideCompactSelection.empty(),
      );
      final shifted = glideShiftSelection(selection, -1);
      expect(shifted.current!.cell, const GlideItem(1, 5));
      expect(shifted.current!.range.x, 1);
    });

    test('getSpanStops reports every spanned column', () {
      final stops = glideGetSpanStops([
        [
          const GlideTextCell(
            data: 'a',
            displayData: 'a',
            span: (start: 1, end: 3),
          ),
          const GlideTextCell(data: 'b', displayData: 'b'),
        ],
      ]);
      expect(stops, [2, 3, 4]);
    });
  });

  // -------------------------------------------------------------------------
  // Clipboard (`data-editor.tsx:3583-3901`)
  // -------------------------------------------------------------------------

  group('clipboard', () {
    List<List<GlideGridCell>> table() => [
      for (var row = 0; row < 5; row++)
        [
          for (var col = 0; col < 4; col++)
            GlideTextCell(data: 'r$row c$col', displayData: 'r$row c$col'),
        ],
    ];

    GlideGetCellsForSelection reader(List<List<GlideGridCell>> cells) =>
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
      await glideCopy(
        focused: true,
        copyEnabled: true,
        selection: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(1, 1),
            range: GlideRectangle(x: 1, y: 1, width: 2, height: 2),
          ),
        ),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++) GlideGridColumn(title: 'C$i', width: 100),
        ],
        getCellsForSelection: reader(cells),
        clipboard: fake,
      );
      expect(fake.writtenPlain, 'r1 c1\tr1 c2\nr2 c1\tr2 c2');
      expect(fake.writtenHtml, contains('<table>'));
    });

    test('copy prepends headers when asked', () async {
      final fake = FakeClipboard();
      await glideCopy(
        focused: true,
        copyEnabled: true,
        selection: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(0, 0),
            range: GlideRectangle(x: 0, y: 0, width: 1, height: 1),
          ),
        ),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++) GlideGridColumn(title: 'C$i', width: 100),
        ],
        getCellsForSelection: reader(table()),
        copyHeaders: true,
        clipboard: fake,
      );
      expect(fake.writtenPlain, 'C0\nr0 c0');
    });

    test('copy of a column selection zips the columns together', () async {
      final fake = FakeClipboard();
      await glideCopy(
        focused: true,
        copyEnabled: true,
        selection: const GlideGridSelection(
          columns: GlideCompactSelection.empty(),
        ).copyWith(columns: GlideCompactSelection.fromArray([0, 2])),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++) GlideGridColumn(title: 'C$i', width: 100),
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
      const selection = GlideGridSelection(
        current: GlideGridSelectionCurrent(
          cell: GlideItem(0, 0),
          range: GlideRectangle(x: 0, y: 0, width: 1, height: 1),
        ),
      );
      await glideCopy(
        focused: false,
        copyEnabled: true,
        selection: selection,
        rows: 5,
        rowMarkerOffset: 0,
        columns: [GlideGridColumn(title: 'C', width: 100)],
        getCellsForSelection: reader(table()),
        clipboard: fake,
      );
      await glideCopy(
        focused: true,
        copyEnabled: false,
        selection: selection,
        rows: 5,
        rowMarkerOffset: 0,
        columns: [GlideGridColumn(title: 'C', width: 100)],
        getCellsForSelection: reader(table()),
        clipboard: fake,
      );
      expect(fake.writtenPlain, isNull);
    });

    test('paste without onPaste writes a single cell', () async {
      final edits = <GlideEditListItem>[];
      final fake = FakeClipboard()..nextText = 'pasted value';
      await glidePaste(
        focused: true,
        selection: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(1, 2),
            range: GlideRectangle(x: 1, y: 2, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (item) => GlideTextCell(
          data: 'old ${item.col}-${item.row}',
          displayData: 'old',
        ),
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        clipboard: fake,
      );
      expect(edits, hasLength(1));
      expect(edits.single.location, const GlideItem(1, 2));
      final pasted = edits.single.value as GlideTextCell;
      expect(pasted.data, 'pasted value');
      // Upstream's default paste path passes `formatted: undefined`, and
      // `text-cell.tsx` then keeps the previous `displayData`.
      expect(pasted.displayData, 'old');
    });

    test('paste with onPaste fills the target rectangle', () async {
      final edits = <GlideEditListItem>[];
      final fake = FakeClipboard()..nextText = 'a\tb\nc\td';
      List<List<String>>? seen;
      await glidePaste(
        focused: true,
        selection: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(1, 1),
            range: GlideRectangle(x: 1, y: 1, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (item) =>
            GlideTextCell(data: 'old', displayData: 'old'),
        getCellRenderer: GlideDefaultRendererLookup().forCell,
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
        const GlideItem(1, 1),
        const GlideItem(2, 1),
        const GlideItem(1, 2),
        const GlideItem(2, 2),
      });
    });

    test('onPaste returning false aborts the paste', () async {
      final edits = <GlideEditListItem>[];
      final fake = FakeClipboard()..nextText = 'a\tb';
      await glidePaste(
        focused: true,
        selection: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(0, 0),
            range: GlideRectangle(x: 0, y: 0, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (_) =>
            const GlideTextCell(data: 'old', displayData: 'old'),
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        onPaste: (_, _) => false,
        clipboard: fake,
      );
      expect(edits, isEmpty);
    });

    test('paste respects the table bounds', () async {
      final edits = <GlideEditListItem>[];
      final fake = FakeClipboard()..nextText = 'a\tb\tc\td\te\tf\tg\th\ti';
      await glidePaste(
        focused: true,
        selection: const GlideGridSelection(
          current: GlideGridSelectionCurrent(
            cell: GlideItem(3, 4),
            range: GlideRectangle(x: 3, y: 4, width: 1, height: 1),
          ),
        ),
        rows: 5,
        columnCount: 4,
        rowMarkerOffset: 0,
        getCellContent: (_) =>
            const GlideTextCell(data: 'old', displayData: 'old'),
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        clipboard: fake,
      );
      expect(edits, hasLength(1));
      expect(edits.single.location, const GlideItem(3, 4));
    });

    test('pasteIntoCell coerces through the renderer', () {
      final booleanCell = const GlideBooleanCell(
        data: GlideBooleanValue.unchecked,
      );
      final edit = glidePasteToCell(
        inner: booleanCell,
        target: const GlideItem(2, 2),
        rawValue: 'true',
        getCellRenderer: GlideDefaultRendererLookup().forCell,
      );
      expect(edit, isNotNull);
      expect((edit!.value as GlideBooleanCell).data, GlideBooleanValue.checked);
    });

    test('pasteIntoCell leaves read-only cells alone', () {
      final edit = glidePasteToCell(
        inner: const GlideTextCell(data: 'x', displayData: 'x', readonly: true),
        target: const GlideItem(0, 0),
        rawValue: 'y',
        getCellRenderer: GlideDefaultRendererLookup().forCell,
      );
      expect(edit, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Overlay editor (`internal/data-grid-overlay-editor/`)
  // -------------------------------------------------------------------------

  group('overlay editor', () {
    late GlideGridCell? finishedValue;
    late GlideEditorMovement? finishedMovement;

    Widget buildEditor({
      bool forceEditMode = false,
      String? initialValue,
      Object? Function(GlideItem, GlideGridCell, GlideGridCell)? validateCell,
      GlideGridCell? content,
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
                GlideDataGridOverlayEditor(
                  target: const GlideRectangle(
                    x: 10,
                    y: 10,
                    width: 120,
                    height: 30,
                  ),
                  cell: const GlideItem(0, 0),
                  content:
                      content ??
                      const GlideTextCell(data: 'hello', displayData: 'hello'),
                  theme: GlideTheme.light(),
                  onFinishEditing: (cell, movement) {
                    finishedValue = cell;
                    finishedMovement = movement;
                  },
                  forceEditMode: forceEditMode,
                  highlight: false,
                  getCellRenderer: GlideDefaultRendererLookup().forCell,
                  initialValue: initialValue,
                  validateCell: validateCell,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('enter commits and moves down', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(finishedMovement, GlideEditorMovement.down);
      expect((finishedValue as GlideTextCell).data, 'hello');
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
      expect(finishedMovement, GlideEditorMovement.down);
    });

    testWidgets('escape discards the edit', (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(finishedValue, isNull);
      expect(finishedMovement, GlideEditorMovement.none);
    });

    testWidgets('tab commits and moves right', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(finishedMovement, GlideEditorMovement.right);
      expect(finishedValue, isNotNull);
    });

    testWidgets('tapping outside commits the current value', (tester) async {
      await tester.pumpWidget(buildEditor(forceEditMode: true));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(350, 250));
      await tester.pump();

      expect(finishedValue, isNotNull);
      expect(finishedMovement, GlideEditorMovement.none);
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
      expect(finishedMovement, GlideEditorMovement.down);
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
    late List<GlideEditListItem> edits;
    late List<GlideGridSelection> selectionLog;
    late List<String> activationLog;

    List<List<GlideGridCell>> table() => [
      for (var row = 0; row < 200; row++)
        [
          for (var col = 0; col < 6; col++)
            GlideTextCell(data: 'r$row c$col', displayData: 'r$row c$col'),
        ],
    ];

    Widget buildEditor({
      GlideGridCell Function(GlideItem item)? content,
      bool editOnType = true,
      GlideKeybinds? keybindings,
      GlideFillHandleConfig? fillHandle,
      void Function(GlideFillPatternArgs args)? onFillPattern,
      void Function(
        GlideGridColumn column,
        double newSize,
        int colIndex,
        double newSizeWithGrow,
      )?
      onColumnResize,
      void Function(
        GlideGridColumn column,
        double newSize,
        int colIndex,
        double newSizeWithGrow,
      )?
      onColumnResizeStart,
      void Function(
        GlideGridColumn column,
        double newSize,
        int colIndex,
        double newSizeWithGrow,
      )?
      onColumnResizeEnd,
      void Function(int from, int to)? onColumnMoved,
      bool? Function(int from, int to)? onColumnProposeMove,
      void Function(int from, int to)? onRowMoved,
      GlideRowMarkerOptions? rowMarkers,
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
      GlideKeybinds? keybindingsOverride,
      String? group,
      void Function(String groupName, String newVal)? onGroupHeaderRenamed,
      void Function(GlideItem location)? onCellFocused,
      void Function(GlideVisibleRegion region, GlideVisibleRegionExtras extras)?
      onVisibleRegionChanged,
      void Function(GlideGridCell? newValue, GlideEditorMovement movement)?
      onFinishedEditing,
      void Function(int col, GlideHeaderClickedEventArgs args)?
      onHeaderContextMenu,
      bool hasMenu = false,
      void Function(int col, GlideRectangle bounds)? onHeaderMenuClick,
      void Function(GlideGridMouseArgs args)? onMouseMove,
      GlideRowGroupingOptions? rowGrouping,
      GlideTrailingRowOptions? trailingRowOptions,
      void Function()? onRowAppended,
      Object? Function()? onColumnAppended,
      GlideGetCellsForSelection? cellsForSelection,
      GlideSpanRangeBehavior spanRangeBehavior =
          GlideSpanRangeBehavior.standard,
      void Function(List<GlideItem> results, int navIndex)?
      onSearchResultsChanged,
      GlideDrawCellCallback? drawCell,
      GlideDrawHeaderCallback? drawHeader,
      GlideRendererLookup? rendererLookup,
    }) {
      edits = [];
      selectionLog = [];
      activationLog = [];
      final cells = table();
      var currentRows = rows;
      var currentCols = columnCount;
      return StatefulBuilder(
        builder: (context, setRows) {
          final p = GlideDataEditorProps(
            columns: [
              for (var i = 0; i < currentCols; i++)
                unsizedColumns
                    ? GlideGridColumn(
                        title: 'C$i',
                        id: 'c$i',
                        group: group,
                        // No `width`: `useColumnSizer` skips columns that are
                        // already sized (`use-column-sizer.ts:100-107`).
                      )
                    : GlideGridColumn(
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
            drawCell: drawCell,
            drawHeader: drawHeader,
            keybindings: keybindingsOverride ?? keybindings,
            onCellFocused: onCellFocused,
            onVisibleRegionChanged: onVisibleRegionChanged,
            onFinishedEditing: onFinishedEditing,
            onHeaderContextMenu: onHeaderContextMenu,
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
                : () {
                    setRows(() => currentRows++);
                    onRowAppended?.call();
                  },
            getCellContent: (item, [_]) {
              if (content != null) return content(item);
              if (item.row >= cells.length ||
                  item.col >= cells[item.row].length) {
                return const GlideTextCell(data: 'new', displayData: 'new');
              }
              return cells[item.row][item.col];
            },
            theme: GlideTheme.light(),
            rowHeight: const GlideRowHeight.fixed(32),
            headerHeight: 32,
            onKeyDown: (_) {},
            onCellsEdited: (items) {
              edits.addAll(items);
              return true;
            },
            onGridSelectionChange: selectionLog.add,
            onCellActivated: (location, activation) {
              final key = activation is GlideKeyboardCellActivation
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
                child: GlideDataEditor(props: p),
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
      await tester.pumpWidget(
        buildEditor(
          hasMenu: true,
          rowMarkers: const GlideRowMarkerOptions(width: 40),
          onHeaderMenuClick: (col, bounds) => fired.add(col),
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
      expect(current!.cell, const GlideItem(1, 0));
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
      expect(selectionLog.last.current!.cell, const GlideItem(1, 1));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selectionLog.last.current!.cell, const GlideItem(2, 1));
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
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideTextCell(data: 'old', displayData: 'old')
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
      final value = edits.single.value as GlideTextCell;
      expect(value.data, 'z');
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
      expect(selectionLog.last.current!.cell, const GlideItem(5, 199));

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
        buildEditor(keybindings: const GlideKeybinds(downFill: true)),
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
        const GlideItem(0, 1),
        const GlideItem(0, 2),
      ]);
      expect((edits.first.value as GlideTextCell).data, 'r0 c0');
    });

    testWidgets('ctrl+r fills the selection rightward', (tester) async {
      await tester.pumpWidget(
        buildEditor(keybindings: const GlideKeybinds(rightFill: true)),
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
        const GlideItem(1, 0),
        const GlideItem(2, 0),
      ]);
      expect((edits.first.value as GlideTextCell).data, 'r0 c0');
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
      expect(selectionLog.last.current!.cell, const GlideItem(0, 0));
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
      expect(selectionLog.last.current!.cell, const GlideItem(0, 0));

      // The handle sits on the bottom-right corner of cell (0,0):
      // x = 0 + 101 - 2, y = 32 + 33 - 2.
      final handle = await tester.startGesture(
        const Offset(99, 63),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      // Pressing the handle must not move the selection.
      expect(selectionLog.last.current!.cell, const GlideItem(0, 0));

      await handle.moveTo(const Offset(99, 200));
      await tester.pump();
      await handle.up();
      await tester.pumpAndSettle();

      expect(edits, hasLength(5));
      expect(edits.map((e) => e.location).toList(), [
        const GlideItem(0, 1),
        const GlideItem(0, 2),
        const GlideItem(0, 3),
        const GlideItem(0, 4),
        const GlideItem(0, 5),
      ]);
      expect((edits.first.value as GlideTextCell).data, 'r0 c0');
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
        buildEditor(rowMarkers: const GlideRowMarkerOptions()),
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
      expect(selectionLog.last.current!.cell, const GlideItem(1, 0));
    });

    testWidgets('user column coordinates exclude the marker column', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(rowMarkers: const GlideRowMarkerOptions()),
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

      expect(selectionLog.last.current!.cell, const GlideItem(1, 0));
    });

    testWidgets('clicking the header marker selects every row', (tester) async {
      await tester.pumpWidget(
        buildEditor(rowMarkers: const GlideRowMarkerOptions()),
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
          rowMarkers: const GlideRowMarkerOptions(),
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
          rowMarkers: const GlideRowMarkerOptions(
            kind: GlideRowMarkerKind.number,
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
          content: (item) => GlideTextCell(
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
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideNumberCell(data: 1234.5, displayData: '1,234.5')
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
      final value = edits.single.value as GlideNumberCell;
      expect(value.data, 42);
      expect(value.displayData, '42');
    });

    testWidgets('uri cells show the preview until the pencil is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideUriCell(
                  data: 'https://example.com/a',
                  displayData: 'example.com/a',
                )
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideBubbleCell(data: ['alpha', 'beta'])
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideImageCell(data: ['a.png'])
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
      expect(find.byType(GlideDataGridOverlayEditor), findsOneWidget);
    });

    testWidgets('clicking the trailing row appends and focuses it', (
      tester,
    ) async {
      var appended = 0;
      await tester.pumpWidget(
        buildEditor(
          rows: 3,
          trailingRowOptions: const GlideTrailingRowOptions(hint: 'New row'),
          onRowAppended: () => appended++,
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
      expect(selectionLog.last.current!.cell, const GlideItem(0, 3));
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
          trailingRowOptions: const GlideTrailingRowOptions(),
          onRowAppended: () => appended++,
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
      expect(selectionLog.last.current!.cell, const GlideItem(0, 3));
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
          trailingRowOptions: const GlideTrailingRowOptions(),
          onRowAppended: () => appended++,
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
      expect(selectionLog.last.current!.cell, const GlideItem(2, 0));
      expect(appended, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(appended, 1);
      // The editor closed and the new column is selected.
      expect(find.byType(EditableText), findsNothing);
      expect(selectionLog.last.current!.cell, const GlideItem(3, 0));
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
      expect(selectionLog.last.current!.cell, const GlideItem(0, 0));
    });

    testWidgets('image cells open the overlay viewer', (tester) async {
      await tester.pumpWidget(
        buildEditor(
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideImageCell(data: ['https://example.com/a.png'])
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
          content: (item) => item == const GlideItem(1, 0)
              ? const GlideDrilldownCell(
                  data: [
                    GlideDrilldownCellData(text: 'Alpha'),
                    GlideDrilldownCellData(text: 'Beta'),
                  ],
                )
              : const GlideTextCell(data: 'x', displayData: 'x'),
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
            0 => const GlideLoadingCell(skeletonWidth: 40),
            1 => const GlideProtectedCell(),
            _ => const GlideTextCell(data: 'x', displayData: 'x'),
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
          rowGrouping: const GlideRowGroupingOptions(
            groups: [
              GlideRowGroup(headerIndex: 0, isCollapsed: false),
              GlideRowGroup(headerIndex: 3, isCollapsed: false),
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
        buildEditor(keybindingsOverride: const GlideKeybinds(search: true)),
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
        buildEditor(keybindingsOverride: const GlideKeybinds(search: true)),
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
                of: find.byType(GlideSearchBar),
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
      expect(find.byType(GlideSearchBar), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 75));
      final mid = offsetOf();
      expect(mid.dx, greaterThan(0));
      expect(mid.dx, lessThan(400));

      // The owner's timer unmounts it once the outro is done.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GlideSearchBar), findsNothing);
    });

    testWidgets(
      'the bar is hidden from focus and semantics while it slides out',
      (tester) async {
        await tester.pumpWidget(
          buildEditor(keybindingsOverride: const GlideKeybinds(search: true)),
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
                of: find.byType(GlideSearchBar),
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
                of: find.byType(GlideSearchBar),
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
          trailingRowOptions: const GlideTrailingRowOptions(
            hint: 'New row',
            tint: true,
          ),
          onRowAppended: () => appended++,
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
      expect(selectionLog.last.current!.cell, const GlideItem(0, 3));
    });

    testWidgets('the reported region is in user coordinates', (tester) async {
      final regions = <GlideVisibleRegion>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const GlideRowMarkerOptions(),
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
      final regions = <GlideVisibleRegion>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          rows: 5,
          trailingRowOptions: const GlideTrailingRowOptions(hint: 'New row'),
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
      final reports = <(GlideVisibleRegion, GlideVisibleRegionExtras)>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rows: 200,
          rowMarkers: const GlideRowMarkerOptions(),
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
      final seen = <GlideItem>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rows: 200,
          rowMarkers: const GlideRowMarkerOptions(),
          freezeTrailingRows: 2,
          strict: true,
          scrollOffsetX: 100,
          content: (item) {
            seen.add(item);
            return GlideTextCell(
              data: 'cell-${item.col}-${item.row}',
              displayData: 'cell-${item.col}-${item.row}',
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Row 198 sits well below `region.y + region.height`, so without the
      // freeze rect the guard would hand back a loading cell.
      expect(seen, contains(const GlideItem(1, 198)));
      expect(seen, contains(const GlideItem(1, 199)));
    });

    testWidgets('forceStrict does not blank the first visible column', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const GlideRowMarkerOptions(),
          scrollOffsetX: 100,
          content: (item) => GlideTextCell(
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
      final spanning = const GlideTextCell(
        data: 'wide',
        displayData: 'wide',
        span: (start: 0, end: 3),
      );
      Future<GlideRectangle> grow(GlideSpanRangeBehavior behavior) async {
        final log = <GlideRectangle>[];
        await tester.pumpWidget(
          buildEditor(
            columnCount: 6,
            spanRangeBehavior: behavior,
            content: (item) => item == const GlideItem(1, 0)
                ? spanning
                : const GlideTextCell(data: 'x', displayData: 'x'),
            cellsForSelection: (region) => [
              [
                for (var x = region.x.toInt(); x < region.x + region.width; x++)
                  if (x == 1)
                    spanning
                  else
                    const GlideTextCell(data: 'x', displayData: 'x'),
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
      final partial = await grow(GlideSpanRangeBehavior.allowPartial);
      expect(partial.x, 1);
      expect(partial.width, 2);

      // The default keeps growing until the span is fully covered
      // (`data-editor-fns.ts:5-98`).
      final grown = await grow(GlideSpanRangeBehavior.standard);
      expect(grown.x, 0);
      expect(grown.width, 4);
    });

    testWidgets('spanRangeBehavior allowPartial stops a drag growing', (
      tester,
    ) async {
      // The drag path expands in the editor's own `_setGridSelection`
      // (`_dragSelect` -> `setCurrent(expand: true)`), not through
      // `GlideKeyHandler`, so it covers the other of the port's two
      // expansion points.
      final spanning = const GlideTextCell(
        data: 'wide',
        displayData: 'wide',
        span: (start: 0, end: 3),
      );
      Future<GlideRectangle> drag(GlideSpanRangeBehavior behavior) async {
        await tester.pumpWidget(
          buildEditor(
            columnCount: 6,
            spanRangeBehavior: behavior,
            content: (item) => item.row == 0 && item.col <= 3
                ? spanning
                : const GlideTextCell(data: 'x', displayData: 'x'),
            cellsForSelection: (region) => [
              [
                for (var x = region.x.toInt(); x < region.x + region.width; x++)
                  if (x <= 3)
                    spanning
                  else
                    const GlideTextCell(data: 'x', displayData: 'x'),
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
      final grown = await drag(GlideSpanRangeBehavior.standard);
      expect(grown.x, 0);
      expect(grown.width, 4);

      // `"allowPartial"` stops at the dragged edge.
      final partial = await drag(GlideSpanRangeBehavior.allowPartial);
      expect(partial.x, 0);
      expect(partial.width, 2);
    });

    testWidgets('search results reach the consumer in user coordinates', (
      tester,
    ) async {
      final reported = <(List<GlideItem>, int)>[];
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const GlideRowMarkerOptions(),
          keybindingsOverride: const GlideKeybinds(search: true),
          onSearchResultsChanged: (results, navIndex) =>
              reported.add((results, navIndex)),
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

      await tester.enterText(find.byType(EditableText), 'r0 c1');
      await tester.pumpAndSettle();

      // The first run reports `navIndex: -1` and upstream bails out on it
      // (`data-editor.tsx:3921`); Enter steps to index 0.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(reported, isNotEmpty);
      final (results, navIndex) = reported.last;
      expect(navIndex, 0);
      // The runner indexes `_getCellsForSelection`'s rows, which still carry
      // the marker column, so the consumer must see the marker stripped
      // (`data-editor.tsx:3913-3915`).
      expect(results, [const GlideItem(1, 0)]);
      // ...and never a negative column.
      expect(results.every((r) => r.col >= 0), isTrue);
    });

    testWidgets('search without a consumer moves the selection to the match', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditor(
          columnCount: 6,
          rowMarkers: const GlideRowMarkerOptions(),
          keybindingsOverride: const GlideKeybinds(search: true),
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
      expect(selectionLog.last.current!.cell, const GlideItem(2, 3));
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
                  const GlideTextCell(
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
        expect(find.byType(GlideDataGridOverlayEditor), findsOneWidget);

        final overlay = tester.widget<GlideDataGridOverlayEditor>(
          find.byType(GlideDataGridOverlayEditor),
        );
        final positioned = tester.widget<Positioned>(
          find
              .descendant(
                of: find.byType(GlideDataGridOverlayEditor),
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
                  const GlideTextCell(data: 'x', displayData: 'x'),
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
      // `GlideKeyHandler` made this three.
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
      expect(find.byType(GlideDataGridOverlayEditor), findsOneWidget);

      // The box must be *inside* the grid, not merely built: the Stack clips,
      // so an overflowing editor would be cut off rather than crash.
      final overlay = tester.getRect(find.byType(GlideDataGridOverlayEditor));
      final box = tester.getRect(
        find
            .descendant(
              of: find.byType(GlideDataGridOverlayEditor),
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
      expect(find.byType(GlideDataGridOverlayEditor), findsOneWidget);
    });

    testWidgets('drawCell and drawHeader strip the row-marker column', (
      tester,
    ) async {
      final cells = <GlideItem>[];
      final headers = <GlideDrawHeaderArgs>[];

      // 3 columns + the marker = 4 mangled columns, all inside the 400px
      // viewport, so nothing is clipped away and the indices are exact.
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          rowMarkers: const GlideRowMarkerOptions(),
          drawCell: (args, draw) {
            cells.add(GlideItem(args.col, args.row));
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

      expect(find.byType(GlideGroupRename), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Team B');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(renamed, ['Team A=Team B']);
      expect(find.byType(GlideGroupRename), findsNothing);
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

    testWidgets('an edit refreshes the accessibility labels', (tester) async {
      final handle = tester.ensureSemantics();

      // `content` reads the shared `edits` log, so the label only changes
      // once the editor has routed a real edit through `_onCellsEdited`.
      await tester.pumpWidget(
        buildEditor(
          columnCount: 3,
          content: (item) {
            final label = edits.isEmpty ? 'before' : 'after';
            return GlideTextCell(data: label, displayData: label);
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
      final lookup = GlideDefaultRendererLookup();
      GlideGridCell content(GlideItem item, [bool? forceStrict]) =>
          GlideTextCell(data: label, displayData: label);

      Widget build() => Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: GlideDataGrid(
            props: GlideDataGridProps(
              width: 400,
              height: 300,
              columns: [
                for (var i = 0; i < 4; i++)
                  GlideGridColumn(title: 'C$i', width: 100),
              ],
              rows: 10,
              rowHeight: const GlideRowHeight.fixed(30),
              headerHeight: 30,
              getCellContent: content,
              getCellRenderer: lookup.forCell,
              a11yRevision: revision,
              theme: GlideTheme.light(),
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
  });

  group('column sizer', () {
    test('measureColumn takes the widest cell, floored and capped', () {
      final theme = GlideTheme.light();
      final cells = <List<GlideGridCell>>[
        [
          const GlideTextCell(data: 'hi', displayData: 'hi'),
          const GlideTextCell(data: 'a', displayData: 'a'),
        ],
        [
          const GlideTextCell(data: 'much longer text', displayData: 'x'),
          const GlideTextCell(data: 'a', displayData: 'a'),
        ],
      ];

      final width = glideMeasureColumn(
        theme: theme,
        column: const GlideGridColumn(title: 'C', width: 100),
        colIndex: 0,
        selectedData: cells,
        minColumnWidth: 50,
        maxColumnWidth: 500,
        removeOutliers: false,
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        metrics: GlideTextMetrics(),
      );

      expect(width, greaterThanOrEqualTo(50));
      expect(width, lessThanOrEqualTo(500));
      // The header title is part of the measurement too.
      expect(width, greaterThanOrEqualTo(theme.cellHorizontalPadding * 2 + 8));
    });

    test('measureColumn respects the configured bounds', () {
      final theme = GlideTheme.light();
      final tiny = glideMeasureColumn(
        theme: theme,
        column: const GlideGridColumn(title: 'C', width: 10),
        colIndex: 0,
        selectedData: const [
          [GlideTextCell(data: 'a', displayData: 'a')],
        ],
        minColumnWidth: 120,
        maxColumnWidth: 500,
        removeOutliers: false,
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        metrics: GlideTextMetrics(),
      );
      expect(tiny, 120);

      final huge = glideMeasureColumn(
        theme: theme,
        column: const GlideGridColumn(title: 'C', width: 10),
        colIndex: 0,
        selectedData: const [
          [
            GlideTextCell(
              data: 'a very long piece of text that will not fit at all',
              displayData: 'a very long piece of text that will not fit at all',
            ),
          ],
        ],
        minColumnWidth: 10,
        maxColumnWidth: 60,
        removeOutliers: false,
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        metrics: GlideTextMetrics(),
      );
      expect(huge, 60);
    });
  });

  // -------------------------------------------------------------------------
  // Column sizer (`data-editor/use-column-sizer.ts`)
  // -------------------------------------------------------------------------

  group('column sizer', () {
    GlideSizedColumns size({
      required List<GlideGridColumn> columns,
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
              GlideTextCell(data: 'r$y c$x', displayData: 'r$y c$x'),
          ],
      ],
      clientWidth: clientWidth,
      minColumnWidth: minColumnWidth,
      maxColumnWidth: maxColumnWidth,
      theme: GlideTheme.light(),
      getCellRenderer: GlideDefaultRendererLookup().forCell,
      metrics: GlideTextMetrics(),
      memo: memo,
    );

    test('already sized columns pass through untouched', () {
      final columns = [
        for (var i = 0; i < 3; i++)
          GlideGridColumn(title: 'C$i', width: 100, id: 'c$i'),
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
        for (var i = 0; i < 3; i++) GlideGridColumn(title: 'C$i', id: 'c$i'),
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
        GlideGridColumn(title: 'A', width: 100, id: 'a'),
        GlideGridColumn(title: 'B', width: 100, id: 'b', grow: 1),
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
      final columns = [GlideGridColumn(title: 'C', id: 'c')];
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
        const GlideRectangle(x: 0, y: 0, width: 1, height: 1),
        const GlideRectangle(x: 0, y: 1, width: 1, height: 5),
      );
      expect(combined.x, 0);
      expect(combined.y, 0);
      expect(combined.width, 1);
      expect(combined.height, 6);
    });

    test('getClosestRect grows toward the nearest edge', () {
      const source = GlideRectangle(x: 0, y: 0, width: 1, height: 1);

      final down = getClosestRect(
        source,
        0,
        5,
        GlideFillHandleDirection.orthogonal,
      );
      expect(down!.y, 1);
      expect(down.height, 5);

      final right = getClosestRect(
        source,
        5,
        0,
        GlideFillHandleDirection.orthogonal,
      );
      expect(right!.x, 1);
      expect(right.width, 5);

      // Inside the source → nothing to grow.
      expect(
        getClosestRect(source, 0, 0, GlideFillHandleDirection.orthogonal),
        isNull,
      );

      // `vertical` pins the horizontal axis, so only rows change.
      final onlyRows = getClosestRect(
        source,
        9,
        4,
        GlideFillHandleDirection.vertical,
      );
      expect(onlyRows!.x, 0);
      expect(onlyRows.width, 1);
      expect(onlyRows.height, 4);
    });
  });

  group('autoscroll', () {
    test('ramps from zero to full speed over 1300ms', () {
      final auto = GlideAutoscroll();
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
    test('glideNumberToDisplay drops the .0 of integral doubles', () {
      expect(glideNumberToDisplay(1234, null), '1234');
      expect(glideNumberToDisplay(1234.0, null), '1234');
      expect(glideNumberToDisplay(1234.5, null), '1234.5');
      expect(glideNumberToDisplay(1234.567, 2), '1234.57');
      expect(glideNumberToDisplay(-42, null), '-42');
    });
  });

  // -------------------------------------------------------------------------
  // Image cell + window loader (`cells/image-cell.tsx`,
  // `common/image-window-loader.ts`)
  // -------------------------------------------------------------------------

  group('image cell', () {
    test('measure is the url count times 50', () {
      const renderer = GlideImageCellRenderer();
      final width = renderer.measure(
        const GlideImageCell(data: ['a', 'b', 'c']),
        GlideTheme.light(),
        GlideTextMetrics(),
      );
      expect(width, 150);
    });

    test('delete empties the url list', () {
      const renderer = GlideImageCellRenderer();
      final deleted = renderer.onDelete(
        const GlideImageCell(data: ['a', 'b']),
      ) as GlideImageCell;
      expect(deleted.data, isEmpty);
    });

    test('paste only keeps parseable urls', () {
      const renderer = GlideImageCellRenderer();
      const cell = GlideImageCell(data: ['https://a/b.png']);

      final changed = renderer.onPaste(
        'https://a/b.png, https://c/d.png',
        cell,
        const GlidePasteDetails(),
      ) as GlideImageCell;
      expect(changed.data, ['https://a/b.png', 'https://c/d.png']);

      // Identical url set is a no-op (`image-cell.tsx:74`).
      expect(
        renderer.onPaste('https://a/b.png', cell, const GlidePasteDetails()),
        isNull,
      );

      // `not a url` has no scheme and is dropped; what is left differs from
      // the current set, so the cell is updated.
      final filtered = renderer.onPaste(
        'nope, https://c/d.png',
        cell,
        const GlidePasteDetails(),
      ) as GlideImageCell;
      expect(filtered.data, ['https://c/d.png']);

      // Dropping the only unparseable entry can leave the set unchanged.
      expect(
        renderer.onPaste(
          'nope, https://a/b.png',
          cell,
          const GlidePasteDetails(),
        ),
        isNull,
      );
    });
  });

  group('image window loader', () {
    late List<void Function(ui.Image?)> completions;
    late int loads;

    GlideImageWindowLoader makeLoader() {
      completions = [];
      loads = 0;
      return GlideImageWindowLoader(
        loadImage: (url, onComplete) {
          loads++;
          completions.add(onComplete);
        },
      );
    }

    test('caches by url and reports the decoded cell once', () async {
      final loader = makeLoader();
      final loaded = <GlideCellSet>[];
      loader.onLoaded = loaded.add;
      loader.setWindow(
        const GlideRectangle(x: 0, y: 0, width: 10, height: 10),
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
        const GlideRectangle(x: 0, y: 0, width: 10, height: 10),
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
        const GlideRectangle(x: 0, y: 0, width: 10, height: 10),
        0,
        const [],
      );
      loader.loadOrGetImage('a.png', 0, 0);
      final image = await _fakeImage();
      completions.single(image);
      expect(loader.cachedCount, 1);

      // Nothing in the new window → the entry goes.
      loader.setWindow(
        const GlideRectangle(x: 50, y: 50, width: 10, height: 10),
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
        const GlideRectangle(x: 0, y: 0, width: 1, height: 1),
        2,
        const [],
      );
      loader.loadOrGetImage('frozen.png', 0, 0);
      final image = await _fakeImage();
      completions.single(image);

      // Only the column axis moves: column 0 is frozen, and the row is still
      // inside the window (`image-window-loader.ts:41-48`).
      loader.setWindow(
        const GlideRectangle(x: 50, y: 0, width: 10, height: 10),
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
    const options = GlideRowGroupingOptions(
      groups: [
        GlideRowGroup(headerIndex: 0, isCollapsed: true),
        GlideRowGroup(headerIndex: 3, isCollapsed: false),
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
        rowHeightIn: const GlideRowHeight.fixed(32),
        getRowThemeOverrideIn: null,
      );
      // 1 collapsed header + (2 content + 1 header) = 4 grid rows.
      expect(result.rows, 4);
    });

    test('rowHeight swaps group headers to the group height', () {
      final result = useRowGroupingInner(
        options: options,
        rows: 6,
        rowHeightIn: const GlideRowHeight.fixed(32),
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
        rowHeightIn: const GlideRowHeight.fixed(32),
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
        rowHeightIn: const GlideRowHeight.fixed(32),
        getRowThemeOverrideIn: null,
      );
      expect(result.rows, 7);
      expect(result.flattened, isEmpty);
      expect(result.rowHeight, isNull);
      expect(result.rowNumberMapper, isNull);
      expect(result.getRowThemeOverride, isNull);
    });

    test('block-spanning pins the selection to one group', () {
      const blockable = GlideRowGroupingOptions(
        groups: [GlideRowGroup(headerIndex: 0, isCollapsed: false)],
        height: 60,
        selectionBehavior: GlideRowGroupSelectionBehavior.blockSpanning,
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
    GlideRemAdjustment adjust({bool scaleToRem = true, double remSize = 16}) =>
        glideRemAdjuster(
          scaleToRem: scaleToRem,
          remSize: remSize,
          rowHeightIn: const GlideRowHeight.fixed(30),
          headerHeightIn: 36,
          groupHeaderHeightIn: 36,
          themeIn: GlideTheme.light(),
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
      expect(identical(sixteen.theme, GlideTheme.light()), isTrue);
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
        GlideTheme.light().cellHorizontalPadding * 2,
      );
      expect(
        scaled.theme.cellVerticalPadding,
        GlideTheme.light().cellVerticalPadding * 2,
      );
      // Everything else is untouched.
      expect(scaled.theme.bgCell, GlideTheme.light().bgCell);
    });

    test('variable row heights are scaled and ceiled', () {
      final scaled = glideRemAdjuster(
        scaleToRem: true,
        remSize: 24,
        rowHeightIn: const GlideRowHeight.variable(_oddHeight),
        headerHeightIn: 36,
        groupHeaderHeightIn: 36,
        themeIn: GlideTheme.light(),
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
    test('glideSearchRegex escapes the pattern but stays case insensitive', () {
      final regex = glideSearchRegex('a.b');
      expect(regex.hasMatch('a.b'), isTrue);
      expect(regex.hasMatch('axb'), isFalse);
      expect(regex.hasMatch('A.B'), isTrue);

      expect(glideSearchRegex('r2').hasMatch('R2 c1'), isTrue);
    });

    test('glideSearchTestString mirrors the upstream switch', () {
      expect(
        glideSearchTestString(
          const GlideTextCell(data: 'x', displayData: 'hi'),
        ),
        'hi',
      );
      expect(
        glideSearchTestString(const GlideNumberCell(data: 5, displayData: '5')),
        '5',
      );
      expect(
        glideSearchTestString(const GlideUriCell(data: 'https://a')),
        'https://a',
      );
      expect(
        glideSearchTestString(
          const GlideBooleanCell(data: GlideBooleanValue.checked),
        ),
        'true',
      );
      // Indeterminate has no boolean rendering upstream.
      expect(
        glideSearchTestString(
          const GlideBooleanCell(data: GlideBooleanValue.indeterminate),
        ),
        isNull,
      );
      expect(
        glideSearchTestString(const GlideBubbleCell(data: ['a', 'b'])),
        'a\u{1F433}b',
      );
      // Protected/loading cells are not searchable.
      expect(glideSearchTestString(const GlideProtectedCell()), isNull);
      expect(glideSearchTestString(const GlideLoadingCell()), isNull);
    });

    test('the runner walks every row and reports progress', () async {
      final runner = GlideSearchRunner();
      final statuses = <GlideSearchStatus>[];
      List<GlideItem>? results;

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
                GlideTextCell(data: 'r$y c$x', displayData: 'r$y c$x'),
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
      expect(results, contains(const GlideItem(2, 3)));
      expect(statuses.last.rowsSearched, 5);
      expect(statuses.last.results, 5);
    });

    test('an empty pattern resets without scanning', () async {
      final runner = GlideSearchRunner();
      var scanned = 0;
      List<GlideItem>? results = const [GlideItem(0, 0)];

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
      final runner = GlideSearchRunner();
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
                GlideTextCell(data: 'r0 c$x', displayData: 'r0 c$x'),
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
      final manager = GlideAnimationManager();
      expect(manager.shouldStep, isFalse);

      manager.setHovered(const GlideItem(1, 1));
      expect(manager.shouldStep, isTrue);

      var emitted = <GlideHoverValue>[];
      manager.step(40, (values) => emitted = values);
      expect(emitted.single.item, const GlideItem(1, 1));
      expect(emitted.single.amount, closeTo(0.5, 0.001));

      manager.step(40, (values) => emitted = values);
      expect(emitted.single.amount, 1.0);
      expect(manager.shouldStep, isFalse);
    });

    test('the previous item fades out with easeOutCubic', () {
      final manager = GlideAnimationManager();
      manager.setHovered(const GlideItem(1, 1));
      manager.step(80, (_) {});
      expect(manager.shouldStep, isFalse);

      manager.setHovered(const GlideItem(2, 1));
      expect(manager.shouldStep, isTrue);

      var emitted = <GlideHoverValue>[];
      manager.step(40, (values) => emitted = values);
      expect(emitted, hasLength(2));
      final leaving = emitted.firstWhere(
        (v) => v.item == const GlideItem(1, 1),
      );
      final entering = emitted.firstWhere(
        (v) => v.item == const GlideItem(2, 1),
      );
      expect(leaving.amount, closeTo(0.5, 0.001));
      expect(entering.amount, closeTo(0.5, 0.001));

      // With nothing hovered any more, leaving items are eased instead of
      // raw (`animation-manager.ts:48-55`).
      manager.setHovered(null);
      manager.step(20, (values) => emitted = values);
      expect(emitted, hasLength(2));
      final eased = emitted.firstWhere((v) => v.item == const GlideItem(2, 1));
      expect(eased.amount, closeTo(glideEaseOutCubic(0.25), 0.001));
    });

    test('re-hovering resumes from the leaving amount', () {
      final manager = GlideAnimationManager();
      manager.setHovered(const GlideItem(1, 1));
      manager.step(80, (_) {});
      manager.setHovered(const GlideItem(2, 1));
      manager.step(40, (_) {}); // item 1 is now leaving at 0.5

      manager.setHovered(const GlideItem(1, 1));
      var emitted = <GlideHoverValue>[];
      manager.step(1, (values) => emitted = values);
      final resumed = emitted.firstWhere(
        (v) => v.item == const GlideItem(1, 1),
      );
      expect(resumed.amount, greaterThan(0.5));
    });

    test('setting the same hovered item is a no-op', () {
      final manager = GlideAnimationManager();
      manager.setHovered(const GlideItem(1, 1));
      manager.step(80, (_) {});
      manager.setHovered(const GlideItem(1, 1));
      expect(manager.shouldStep, isFalse);
      // The current item stays in the list at full amount even when idle.
      expect(manager.animatingItems, hasLength(1));
      expect(manager.animatingItems.single.amount, 1.0);
    });

    test('clearing the hovered item fades it out', () {
      final manager = GlideAnimationManager();
      manager.setHovered(const GlideItem(1, 1));
      manager.step(80, (_) {});
      manager.setHovered(null);
      expect(manager.shouldStep, isTrue);

      var emitted = <GlideHoverValue>[];
      for (var i = 0; i < 10; i++) {
        manager.step(20, (values) => emitted = values);
      }
      expect(emitted, isEmpty);
      expect(manager.shouldStep, isFalse);
    });

    test('easeOutCubic matches the upstream curve', () {
      expect(glideEaseOutCubic(0), 0);
      expect(glideEaseOutCubic(1), 1);
      expect(glideEaseOutCubic(0.5), closeTo(0.875, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // Sticky shadows (`data-grid.tsx:1878-1917`)
  // -------------------------------------------------------------------------

  group('sticky shadows', () {
    test('opacityX ramps only while the scroll is inside the frozen region', () {
      // No frozen columns: nothing to cast a shadow from.
      expect(
        glideStickyShadowOpacityX(
          freezeColumns: 0,
          cellXOffset: 0,
          translateX: -50,
          fixedShadowX: true,
        ),
        0,
      );
      // `fixedShadowX: false` turns it off outright.
      expect(
        glideStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 5,
          translateX: -50,
          fixedShadowX: false,
        ),
        0,
      );
      // Once past the frozen region it snaps to full.
      expect(
        glideStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 3,
          translateX: 0,
          fixedShadowX: true,
        ),
        1,
      );
      // Otherwise it ramps over the first 100px of horizontal scroll.
      expect(
        glideStickyShadowOpacityX(
          freezeColumns: 2,
          cellXOffset: 2,
          translateX: -50,
          fixedShadowX: true,
        ),
        closeTo(0.5, 0.001),
      );
      expect(
        glideStickyShadowOpacityX(
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
        glideStickyShadowOpacityY(
          cellYOffset: 0,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: true,
        ),
        0,
      );
      expect(
        glideStickyShadowOpacityY(
          cellYOffset: 1,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: false,
        ),
        0,
      );
      // `-cellYOffset * 32` over100 (`data-grid.tsx:1881-1882`).
      expect(
        glideStickyShadowOpacityY(
          cellYOffset: 1,
          translateY: 0,
          rowHeight: 32,
          fixedShadowY: true,
        ),
        closeTo(0.32, 0.001),
      );
      expect(
        glideStickyShadowOpacityY(
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
                child: GlideDataGrid(
                  props: GlideDataGridProps(
                    width: 400,
                    height: 300,
                    columns: [
                      for (var i = 0; i < 4; i++)
                        GlideGridColumn(title: 'C$i', width: 100),
                    ],
                    rows: 10,
                    rowHeight: const GlideRowHeight.fixed(30),
                    headerHeight: 30,
                    freezeColumns: 1,
                    cellXOffset: 2,
                    fixedShadowX: fixedShadowX,
                    getCellContent: (item, [_]) =>
                        const GlideTextCell(data: 'x', displayData: 'x'),
                    getCellRenderer: GlideDefaultRendererLookup().forCell,
                    theme: GlideTheme.light(),
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
      expect(glideSprites.keys, hasLength(29));
      expect(
        glideSprites.keys,
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
        glideSprites['headerAudioUri']!((fgColor: 'f', bgColor: 'b')),
        glideSprites['headerUri']!((fgColor: 'f', bgColor: 'b')),
      );
    });

    test('every sprite interpolates both colors into its markup', () {
      const props = (fgColor: '#111111', bgColor: '#222222');
      for (final entry in glideSprites.entries) {
        final svg = entry.value(props);
        expect(svg.trimLeft(), startsWith('<svg'), reason: entry.key);
        expect(svg, contains('#222222'), reason: entry.key);
        // `renameIcon` only paints with `bgColor` (`sprites.ts:65-73`).
        if (entry.key != 'renameIcon') {
          expect(svg, contains('#111111'), reason: entry.key);
        }
      }
    });

    test('glideSpriteColors follows the upstream variant table', () {
      final theme = GlideTheme.light();
      // `getColors` (`data-grid-sprites.ts:30-40`).
      final normal = glideSpriteColors(GlideSpriteVariant.normal, theme);
      expect(normal.bg, '#737383'); // theme.bgIconHeader
      expect(normal.fg, '#ffffff'); // theme.fgIconHeader

      final selected = glideSpriteColors(GlideSpriteVariant.selected, theme);
      expect(selected.bg, '#ffffff'); // upstream's literal "white"
      expect(selected.fg, '#4f5dff'); // theme.accentColor

      final special = glideSpriteColors(GlideSpriteVariant.special, theme);
      expect(special.bg, '#4f5dff'); // theme.accentColor
      expect(special.fg, '#f7f7f8'); // theme.bgHeader
    });

    testWidgets('a sprite lands on the canvas once its decode settles', (
      tester,
    ) async {
      final theme = GlideTheme.light();
      final settled = Completer<void>();
      final manager = GlideSpriteManager(
        icons: glideSprites,
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
        GlideSpriteVariant.normal,
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
        GlideSpriteVariant.normal,
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
      final manager = GlideSpriteManager(
        icons: {
          'counted': (props) {
            calls++;
            return glideSprites['headerString']!(props);
          },
        },
        settled: () {},
      );
      addTearDown(manager.dispose);

      for (var i = 0; i < 3; i++) {
        manager.drawSprite(
          'counted',
          GlideSpriteVariant.normal,
          Canvas(ui.PictureRecorder()),
          0,
          0,
          20,
          GlideTheme.light(),
        );
      }
      expect(calls, 1, reason: 'one key, one load');
    });

    testWidgets('an unknown sprite name draws nothing', (tester) async {
      final theme = GlideTheme.light();
      final manager = GlideSpriteManager(
        icons: glideSprites,
        settled: () {},
      );
      addTearDown(manager.dispose);

      final rec = ui.PictureRecorder();
      final recCanvas = Canvas(rec)
        ..drawColor(const Color(0xFFFFFFFF), BlendMode.srcOver);
      manager.drawSprite(
        'nope',
        GlideSpriteVariant.normal,
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
      final theme = GlideTheme.light();
      final metrics = GlideTextMetrics();
      final plain = computeHeaderLayout(
        c: mapColumns(const [GlideGridColumn(title: 'A', width: 100)], 0)[0],
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
          const [GlideGridColumn(title: 'A', width: 100, icon: 'headerString')],
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
      final theme = GlideTheme.light();
      final layout = computeHeaderLayout(
        c: mapColumns(
          const [
            GlideGridColumn(
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
        metrics: GlideTextMetrics(),
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
      final theme = GlideTheme.light();
      final metrics = GlideTextMetrics();
      final layout = computeHeaderLayout(
        c: mapColumns(
          const [
            GlideGridColumn(
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
      required List<GlideGridColumn> columns,
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
              child: GlideDataGrid(
                props: GlideDataGridProps(
                  width: 400,
                  height: 300,
                  columns: columns,
                  rows: 3,
                  rowHeight: const GlideRowHeight.fixed(30),
                  headerHeight: 30,
                  theme: GlideTheme.light(),
                  verticalBorder: (_) => true,
                  // `DataGrid` does not merge the built-in sprites — only
                  // `DataEditorAll` does (`data-editor-all.tsx:13-15`) — so a
                  // raw grid needs them handed over explicitly.
                  headerIcons: glideSprites,
                  getCellRenderer: GlideDefaultRendererLookup().forCell,
                  getCellContent: (item, [_]) => const GlideTextCell(
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
      const plain = GlideGridColumn(title: 'A', width: 100);
      const withIcon = GlideGridColumn(
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

      Widget build(Map<String, GlideSpriteFn>? icons) => Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 300,
          child: RepaintBoundary(
            key: key,
            child: GlideDataGrid(
              props: GlideDataGridProps(
                width: 400,
                height: 300,
                columns: const [
                  GlideGridColumn(
                    title: 'A',
                    width: 100,
                    icon: 'headerString',
                  ),
                ],
                rows: 3,
                rowHeight: const GlideRowHeight.fixed(30),
                headerHeight: 30,
                theme: GlideTheme.light(),
                verticalBorder: (_) => true,
                headerIcons: icons,
                getCellRenderer: GlideDefaultRendererLookup().forCell,
                getCellContent: (item, [_]) => const GlideTextCell(
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

      await tester.pumpWidget(build(glideSprites));
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
    Future<List<(int, GlideRectangle)>> press(
      WidgetTester tester, {
      required List<GlideGridColumn> columns,
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
      final fired = <(int, GlideRectangle)>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: GlideDataGrid(
              props: GlideDataGridProps(
                width: 400,
                height: 300,
                columns: columns,
                rows: 10,
                rowHeight: const GlideRowHeight.fixed(30),
                headerHeight: 30,
                theme: GlideTheme.light(),
                verticalBorder: (_) => true,
                headerIcons: glideSprites,
                isDragging: isDragging,
                isResizing: isResizing,
                allowResize: allowResize,
                getCellRenderer: GlideDefaultRendererLookup().forCell,
                getCellContent: (item, [_]) => const GlideTextCell(
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
          const GlideGridColumn(title: 'C1', width: 100),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
          const GlideGridColumn(title: 'C1', width: 100, hasMenu: true),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
        columns: [const GlideGridColumn(title: 'C0', width: 100)],
        down: menuCenter,
      );
      expect(fired, isEmpty);
    });

    testWidgets('pressing the indicator icon reports the indicator', (
      tester,
    ) async {
      const column = GlideGridColumn(
        title: 'C0',
        width: 100,
        indicatorIcon: 'headerString',
      );
      // `computeHeaderLayout`: xPad, then the measured title, then xPad again
      // before the icon box (`data-grid-render.header.ts:388-404`).
      final theme = GlideTheme.light();
      final textWidth = GlideTextMetrics().width(
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
          const GlideGridColumn(title: 'C0', width: 100, hasMenu: true),
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
          const GlideGridColumn(
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
  // Gallery configuration (`example/lib/pages/glide_data_grid.dart`)
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
        expect(glideSprites, contains(name), reason: 'unknown sprite $name');
      }

      // Groups are assigned per four columns, as the demo does.
      final grouped = [
        for (var i = 0; i < 12; i++)
          GlideGridColumn(
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
              child: GlideDataEditor(
                props: GlideDataEditorProps(
                  columns: grouped,
                  rows: 40,
                  getCellContent: (item, [_]) => GlideTextCell(
                    data: 'r${item.row}c${item.col}',
                    displayData: 'r${item.row}c${item.col}',
                  ),
                  theme: GlideTheme.light(),
                  rowHeight: const GlideRowHeight.fixed(34),
                  headerHeight: 38,
                  enableGroups: true,
                  groupHeaderHeight: 30,
                  verticalBorder: (_) => true,
                  freezeColumns: 1,
                  rowMarkers: const GlideRowMarkerOptions(width: 40),
                  trailingRowOptions: const GlideTrailingRowOptions(
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
    GlideDrawGridArg baseArg() => GlideDrawGridArg(
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
        GlideMappedColumn(
          sourceIndex: 0,
          sticky: false,
          title: 'C0',
          width: 100,
        ),
      ],
      freezeColumns: 0,
      freezeTrailingRows: 0,
      rows: 10,
      rowHeight: const GlideRowHeight.fixed(30),
      theme: GlideTheme.light(),
      selection: GlideGridSelection.empty,
      isFocused: false,
      drawFocus: true,
      verticalBorder: (_) => true,
      getCellContent: (item) => const GlideTextCell(data: '', displayData: ''),
      getCellRenderer: GlideDefaultRendererLookup().forCell,
      metrics: GlideTextMetrics(),
      getRowThemeOverride: null,
      getGroupDetails: null,
      hoverValues: const {},
      hoverInfo: null,
      hoverPosition: null,
      damage: null,
      hasAppendRow: false,
      touchMode: false,
      fillHandle: null,
      disabledRows: const GlideCompactSelection.empty(),
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
      resizeIndicator: GlideResizeIndicator.full,
      imageLoader: null,
      spriteManager: null,
    );

  GlideDrawGridArg copyArg(
    GlideDrawGridArg base,
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
    return GlideDrawGridArg(
    width: width as double? ?? base.width,
    height: height as double? ?? base.height,
    headerHeight: headerHeight as double? ?? base.headerHeight,
    groupHeaderHeight: groupHeaderHeight as double? ?? base.groupHeaderHeight,
    enableGroups: enableGroups as bool? ?? base.enableGroups,
    cellXOffset: cellXOffset as int? ?? base.cellXOffset,
    cellYOffset: cellYOffset as int? ?? base.cellYOffset,
    translateX: translateX as double? ?? base.translateX,
    translateY: translateY as double? ?? base.translateY,
    mappedColumns: mappedColumns as List<GlideMappedColumn>? ?? base.mappedColumns,
    freezeColumns: freezeColumns as int? ?? base.freezeColumns,
    freezeTrailingRows: freezeTrailingRows as int? ?? base.freezeTrailingRows,
    rows: rows as int? ?? base.rows,
    rowHeight: rowHeight as GlideRowHeight? ?? base.rowHeight,
    theme: theme as GlideTheme? ?? base.theme,
    selection: selection as GlideGridSelection? ?? base.selection,
    isFocused: isFocused as bool? ?? base.isFocused,
    drawFocus: drawFocus as bool? ?? base.drawFocus,
    verticalBorder: verticalBorder as bool Function(int col)? ?? base.verticalBorder,
    getCellContent: getCellContent as GlideGridCell Function(GlideItem item)? ?? base.getCellContent,
    getCellRenderer: getCellRenderer as GlideGetCellRenderer? ?? base.getCellRenderer,
    metrics: metrics as GlideTextMetrics? ?? base.metrics,
    getRowThemeOverride: getRowThemeOverride as GlideGetRowThemeOverride? ?? base.getRowThemeOverride,
    getGroupDetails: getGroupDetails as GlideGroupDetails Function(String group)? ?? base.getGroupDetails,
    hoverValues: hoverValues as GlideHoverValues? ?? base.hoverValues,
    hoverInfo: hoverInfo as GlideItem? ?? base.hoverInfo,
    hoverPosition: hoverPosition as Offset? ?? base.hoverPosition,
    damage: damage as GlideCellSet? ?? base.damage,
    hasAppendRow: hasAppendRow as bool? ?? base.hasAppendRow,
    touchMode: touchMode as bool? ?? base.touchMode,
    fillHandle: fillHandle as GlideFillHandleConfig? ?? base.fillHandle,
    disabledRows: disabledRows as GlideCompactSelection? ?? base.disabledRows,
    prelightCells: prelightCells as List<GlideItem>? ?? base.prelightCells,
    highlightRegions: highlightRegions as List<GlideHighlight>? ?? base.highlightRegions,
    drawHeaderCallback: drawHeaderCallback as GlideDrawHeaderCallback? ?? base.drawHeaderCallback,
    drawCellCallback: drawCellCallback as GlideDrawCellCallback? ?? base.drawCellCallback,
    fixedShadowX: fixedShadowX as bool? ?? base.fixedShadowX,
    fixedShadowY: fixedShadowY as bool? ?? base.fixedShadowY,
    hyperWrapping: hyperWrapping as bool? ?? base.hyperWrapping,
    enqueue: enqueue as void Function(GlideItem item)? ?? base.enqueue,
    minimumCellWidth: minimumCellWidth as double? ?? base.minimumCellWidth,
    dragAndDropState: dragAndDropState as GlideColumnDndState? ?? base.dragAndDropState,
    isResizing: isResizing as bool? ?? base.isResizing,
    resizeColumn: resizeColumn as int? ?? base.resizeColumn,
    resizeIndicator: resizeIndicator as GlideResizeIndicator? ?? base.resizeIndicator,
    imageLoader: imageLoader as GlideImageWindowLoader? ?? base.imageLoader,
    spriteManager: spriteManager as GlideSpriteManager? ?? base.spriteManager,
    );
  }

    /// One entry per field of [GlideDrawGridArg]: each rebuilds the arg with
    /// exactly that field changed, which must flip `shouldRepaint`.
    final changes = <String, GlideDrawGridArg Function(GlideDrawGridArg)>{
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
      'rowHeight': (base) => copyArg(base, rowHeight: const GlideRowHeight.fixed(31)),
      'theme': (base) => copyArg(base, theme: const GlideThemeOverride(bgCell: Color(0xFF000000)).applyTo(GlideTheme.light())),
      'selection': (base) => copyArg(base, selection: const GlideGridSelection(
            current: GlideGridSelectionCurrent(
              cell: GlideItem(1, 1),
              range: GlideRectangle(x: 1, y: 1, width: 1, height: 1),
            ),
          )),
      'isFocused': (base) => copyArg(base, isFocused: !base.isFocused),
      'drawFocus': (base) => copyArg(base, drawFocus: !base.drawFocus),
      'verticalBorder': (base) => copyArg(base, verticalBorder: (_) => false),
      'getCellContent': (base) => copyArg(base, getCellContent: (item) => const GlideTextCell(data: 'x', displayData: 'x')),
      'getCellRenderer': (base) => copyArg(base, getCellRenderer: (_) => null),
      'metrics': (base) => copyArg(base, metrics: GlideTextMetrics()),
      'getRowThemeOverride': (base) => copyArg(base, getRowThemeOverride: (_) => null),
      'getGroupDetails': (base) => copyArg(base, getGroupDetails: (_) => const GlideGroupDetails(name: 'g')),
      'hoverValues': (base) => copyArg(base, hoverValues: {const GlideItem(0, 0): 1.0}),
      'hoverInfo': (base) => copyArg(base, hoverInfo: const GlideItem(0, 0)),
      'hoverPosition': (base) => copyArg(base, hoverPosition: const Offset(1, 1)),
      'damage': (base) => copyArg(base, damage: GlideCellSet(const [GlideItem(0, 0)])),
      'hasAppendRow': (base) => copyArg(base, hasAppendRow: !base.hasAppendRow),
      'touchMode': (base) => copyArg(base, touchMode: !base.touchMode),
      'fillHandle': (base) => copyArg(base, fillHandle: const GlideFillHandleConfig(shape: GlideFillHandleShape.circle)),
      'disabledRows': (base) => copyArg(base, disabledRows: const GlideCompactSelection.empty().add(0)),
      'prelightCells': (base) => copyArg(base, prelightCells: const [GlideItem(0, 0)]),
      'highlightRegions': (base) => copyArg(base, highlightRegions: const [
            GlideHighlight(
              range: GlideRectangle(x: 0, y: 0, width: 1, height: 1),
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
      'dragAndDropState': (base) => copyArg(base, dragAndDropState: const GlideColumnDndState(src: 0, dest: 1)),
      'isResizing': (base) => copyArg(base, isResizing: !base.isResizing),
      'resizeColumn': (base) => copyArg(base, resizeColumn: 0),
      'resizeIndicator': (base) => copyArg(base, resizeIndicator: GlideResizeIndicator.none),
      'imageLoader': (base) => copyArg(base, imageLoader: GlideImageWindowLoader()),
      'spriteManager': (base) => copyArg(base, spriteManager: GlideSpriteManager(icons: const {}, settled: () {})),
    };

    test('an arg rebuilt from equal values does not repaint', () {
      final base = baseArg();
      expect(
        GlideDataGridPainter(copyArg(base)).shouldRepaint(
          GlideDataGridPainter(base),
        ),
        isFalse,
        reason: 'value-equal args must reuse the previous frame',
      );
      expect(
        GlideDataGridPainter(base).shouldRepaint(GlideDataGridPainter(base)),
        isFalse,
      );
    });

    test('a variable row height compares its function', () {
      // `GlideRowHeight.==` used to look only at the fixed branch, so two
      // different row-height formulas were "equal" and a grid that swapped
      // them would never repaint.
      expect(
        const GlideRowHeight.variable(_shortRowHeight) ==
            const GlideRowHeight.variable(_tallRowHeight),
        isFalse,
      );
      expect(
        const GlideRowHeight.variable(_shortRowHeight) ==
            const GlideRowHeight.variable(_shortRowHeight),
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
        dragAndDropState: GlideColumnDndState(src: 0, dest: 1),
        fillHandle: GlideFillHandleConfig(shape: GlideFillHandleShape.circle),
      );
      final equalAgain = copyArg(
        base,
        dragAndDropState: GlideColumnDndState(src: 0, dest: 1),
        fillHandle: GlideFillHandleConfig(shape: GlideFillHandleShape.circle),
      );
      expect(
        GlideDataGridPainter(withValues).shouldRepaint(
          GlideDataGridPainter(equalAgain),
        ),
        isFalse,
      );

      final moved = copyArg(
        base,
        dragAndDropState: GlideColumnDndState(src: 0, dest: 2),
      );
      expect(
        GlideDataGridPainter(moved).shouldRepaint(
          GlideDataGridPainter(withValues),
        ),
        isTrue,
      );
    });

    test('every field gates a repaint when it changes', () {
      final base = baseArg();
      final painter = GlideDataGridPainter(base);
      for (final entry in changes.entries) {
        expect(
          GlideDataGridPainter(entry.value(base)).shouldRepaint(painter),
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
        'lib/src/glide/internal/data_grid/render/glide_draw_grid_arg.dart',
      ).readAsStringSync();
      final painterSource = File(
        'lib/src/glide/internal/data_grid/render/glide_data_grid_painter.dart',
      ).readAsStringSync();

      final classStart = argSource.indexOf('class GlideDrawGridArg');
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
      required List<GlideGridColumn> from,
      required List<GlideGridColumn> to,
      int fromOffset = 0,
      int toOffset = 0,
      GlideTheme? fromTheme,
      GlideTheme? toTheme,
    }) async {
      final draws = <int>[];
      // Hoisted: a fresh closure per build would make `getCellRenderer`
      // differ by identity and force a repaint, which is exactly what the
      // first case here must not do.
      GlideCellRenderer renderer(GlideGridCell cell) =>
          FrameCountingRenderer(draws);

      Widget build(List<GlideGridColumn> columns, int offset, GlideTheme theme) =>
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 300,
              child: GlideDataGrid(
                props: GlideDataGridProps(
                  width: 400,
                  height: 300,
                  columns: columns,
                  rows: 10,
                  rowHeight: const GlideRowHeight.fixed(30),
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
        build(from, fromOffset, fromTheme ?? GlideTheme.light()),
      );
      await tester.pumpAndSettle();
      final first = draws.length;
      await tester.pumpWidget(
        build(to, toOffset, toTheme ?? GlideTheme.light()),
      );
      await tester.pumpAndSettle();
      return draws.length - first;
    }

    List<GlideGridColumn> columnsOf(double width) => [
      for (var i = 0; i < 4; i++) GlideGridColumn(title: 'C$i', width: width),
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
          fromTheme: GlideTheme.light(),
          toTheme: const GlideThemeOverride(
            bgCell: Color(0xFF000000),
          ).applyTo(GlideTheme.light()),
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
      final lookup = GlideDefaultRendererLookup(
        extra: {GlideCellKind.text: FrameCountingRenderer(draws)},
      );
      final columns = [
        for (var i = 0; i < 4; i++) GlideGridColumn(title: 'C$i', width: 100),
      ];

      // Function props hoisted: a closure per build differs by `==` and would
      // force a repaint for reasons that have nothing to do with the editor.
      bool border(int col) => true;
      GlideGridCell content(GlideItem item, [bool? strict]) =>
          const GlideTextCell(data: '', displayData: '');
      void drawCell(GlideDrawCellArgs args, VoidCallback draw) => draw();
      void drawHeader(GlideDrawHeaderArgs args, VoidCallback draw) => draw();

      Widget build() => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: GlideDataEditor(
              props: GlideDataEditorProps(
                columns: columns,
                rows: 10,
                getCellContent: content,
                theme: GlideTheme.light(),
                verticalBorder: border,
                rendererLookup: lookup,
                rowHeight: const GlideRowHeight.fixed(32),
                headerHeight: 32,
                enableGroups: true,
                groupHeaderHeight: 30,
                freezeColumns: 1,
                rowMarkers: const GlideRowMarkerOptions(width: 40),
                drawCell: drawCell,
                drawHeader: drawHeader,
                // A non-empty highlight list: the editor derives a fresh
                // list (and fresh `GlideHighlight`s) on every build, so this
                // is what forces the value comparison rather than identity.
                highlightRegions: const [
                  GlideHighlight(
                    range: GlideRectangle(x: 0, y: 0, width: 2, height: 2),
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
            child: GlideDataGrid(
              props: GlideDataGridProps(
                width: 400,
                height: 300,
                columns: const [GlideGridColumn(title: 'C0', width: 100)],
                rows: 10,
                rowHeight: const GlideRowHeight.fixed(30),
                headerHeight: 30,
                theme: GlideTheme.light(),
                verticalBorder: _stableBorder,
                allowResize: allowResize,
                getCellRenderer: GlideDefaultRendererLookup().forCell,
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
}
