import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

// ---------------------------------------------------------------------------
// Selection (`internal/data-grid/glide_selection.dart`)
// ---------------------------------------------------------------------------

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
      final sel = GlideCompactSelection.fromArray([0, 1, 2, 3, 4]).remove(
        GlideSlice(1, 4),
      );
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

    Widget buildGrid({bool groups = false}) {
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
              getCellRenderer: GlideDefaultRendererLookup().forCell,
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

    setUp(() {
      columns = [
        for (var i = 0; i < 4; i++)
          GlideGridColumn(title: 'C$i', width: 100),
      ];
      cells = [
        for (var row = 0; row < 10; row++)
          [
            for (var col = 0; col < 4; col++)
              GlideTextCell(
                data: 'r$row c$col',
                displayData: 'r$row c$col',
              ),
          ],
      ];
    });

    testWidgets('paints headers and cells', (tester) async {
      await tester.pumpWidget(buildGrid());
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);

      // Every cell has a renderer in the default lookup.
      final lookup = GlideDefaultRendererLookup();
      expect(lookup.forCell(cells[0][0]), isA<GlideTextCellRenderer>());
      expect(
        lookup.forCell(
          const GlideBooleanCell(data: GlideBooleanValue.checked),
        ),
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
      expect(lookup.forCell(const GlideLoadingCell()), isA<GlideLoadingCellRenderer>());
      expect(lookup.forCell(const GlideProtectedCell()), isA<GlideProtectedCellRenderer>());
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
      expect(toggleBoolean(GlideBooleanValue.checked), GlideBooleanValue.unchecked);
      expect(toggleBoolean(GlideBooleanValue.unchecked), GlideBooleanValue.checked);
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
      expect(
        lines[0],
        '"a\tb"\t12.5\tTRUE\tINDETERMINATE\tx,y\thttps://a.b/c',
      );
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
      expect(
        (first[4] as GlideStringArrayCellBuffer).formatted,
        ['x', 'y'],
      );
      expect(
        (first[5] as GlideBasicCellBuffer).rawValue,
        'https://a.b/c',
      );

      final second = decoded[1].cast<GlideCellBuffer>();
      expect((second[0] as GlideBasicCellBuffer).formatted, 'say "hi"');
    });

    test('copyData bypasses escaping', () {
      final cell = const GlideTextCell(
        data: 'raw,\tvalue',
        displayData: 'ignored',
        copyData: 'raw,\tvalue',
      );
      final buffer = glideCreateBufferFromGridCells(
        [
          [cell],
        ],
        const [],
      );
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
      expect(glideIsHotkey('alt+ArrowDown', key('ArrowDown', 40, alt: true)),
          isTrue);
      // `any+Escape` ignores modifiers entirely.
      expect(glideIsHotkey('any+Escape', key('Escape', 27, ctrl: true, alt: true)),
          isTrue);
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
      void Function(GlideItem location, GlideCellActivation activation)?
      onCellActivated,
    }) {
      edits = [];
      scrolls = [];
      return GlideKeyHandler(
        keys: glideKeysWithDefaults(null),
        selection: initial ??
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
      expect(
        h.handleFixedKeybindings(key('ArrowDown', 40)),
        isTrue,
      );
      expect(h.selection.current!.cell, const GlideItem(2, 4));

      h.handleFixedKeybindings(key('ArrowRight', 39));
      expect(h.selection.current!.cell, const GlideItem(3, 4));

      h.handleFixedKeybindings(key('ArrowUp', 38));
      h.handleFixedKeybindings(key('ArrowLeft', 37));
      expect(h.selection.current!.cell, const GlideItem(2, 3));
    });

    test('navigation clamps to the table bounds', () {
      final h = handler(columnCount: 4, rows: 5, initial:
          const GlideGridSelection(
            current: GlideGridSelectionCurrent(
              cell: GlideItem(3, 4),
              range: GlideRectangle(x: 3, y: 4, width: 1, height: 1),
            ),
          ));
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

    test('escape clears the selection', () {
      final h = handler();
      expect(
        h.handleFixedKeybindings(key('Escape', 27, ctrl: true)),
        isTrue,
      );
      expect(h.selection.current, isNull);
      expect(h.selection.columns.length, 0);
    });

    test('ctrl+a selects the whole table', () {
      final h = handler(columnCount: 7, rows: 11);
      expect(
        h.handleFixedKeybindings(key('a', 65, ctrl: true)),
        isTrue,
      );
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
      expect(
        h.handleFixedKeybindings(key(' ', 32, ctrl: true)),
        isTrue,
      );
      expect(h.selection.columns.toArray(), [2]);
      // `columnBehavior: exclusive` drops `current`, and a missing current
      // range short-circuits the handler — matching `data-editor.tsx:3272`.
      expect(h.selection.current, isNull);
      expect(
        h.handleFixedKeybindings(key(' ', 32, ctrl: true)),
        isFalse,
      );
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
      expect(
        h.handleFixedKeybindings(key('Delete', 46)),
        isTrue,
      );
      expect(called, 1);
      expect(edits, hasLength(4));
      expect(
        edits.map((e) => e.location).toSet(),
        {
          const GlideItem(1, 1),
          const GlideItem(2, 1),
          const GlideItem(1, 2),
          const GlideItem(2, 2),
        },
      );
    });

    test('delete can be aborted by the owner', () {
      final h = handler(
        onDelete: (_) => false,
      );
      expect(
        h.handleFixedKeybindings(key('Delete', 46)),
        isTrue,
      );
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
          [
            if (region.x.toInt() <= 1 && 1 < region.x + region.width)
              spanning,
          ],
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
            GlideTextCell(
              data: 'r$row c$col',
              displayData: 'r$row c$col',
            ),
        ],
    ];

    GlideGetCellsForSelection reader(List<List<GlideGridCell>> cells) =>
        (region) => [
          for (var y = region.y.toInt();
              y < region.y + region.height && y < cells.length;
              y++)
            [
              for (var x = region.x.toInt();
                  x < region.x + region.width && x < cells[y].length;
                  x++)
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
          for (var i = 0; i < 4; i++)
            GlideGridColumn(title: 'C$i', width: 100),
        ],
        getCellsForSelection: reader(cells),
        clipboard: fake,
      );
      expect(
        fake.writtenPlain,
        'r1 c1\tr1 c2\nr2 c1\tr2 c2',
      );
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
          for (var i = 0; i < 4; i++)
            GlideGridColumn(title: 'C$i', width: 100),
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
        ).copyWith(
          columns: GlideCompactSelection.fromArray([0, 2]),
        ),
        rows: 5,
        rowMarkerOffset: 0,
        columns: [
          for (var i = 0; i < 4; i++)
            GlideGridColumn(title: 'C$i', width: 100),
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
      final fake = FakeClipboard()
        ..nextText = 'a\tb\nc\td';
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
        getCellContent: (item) => GlideTextCell(
          data: 'old',
          displayData: 'old',
        ),
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
      expect(
        edits.map((e) => e.location).toSet(),
        {
          const GlideItem(1, 1),
          const GlideItem(2, 1),
          const GlideItem(1, 2),
          const GlideItem(2, 2),
        },
      );
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
        getCellContent: (_) => const GlideTextCell(
          data: 'old',
          displayData: 'old',
        ),
        getCellRenderer: GlideDefaultRendererLookup().forCell,
        onCellsEdited: edits.addAll,
        onPaste: (_, _) => false,
        clipboard: fake,
      );
      expect(edits, isEmpty);
    });

    test('paste respects the table bounds', () async {
      final edits = <GlideEditListItem>[];
      final fake = FakeClipboard()
        ..nextText = 'a\tb\tc\td\te\tf\tg\th\ti';
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
        getCellContent: (_) => const GlideTextCell(
          data: 'old',
          displayData: 'old',
        ),
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
      expect(
        (edit!.value as GlideBooleanCell).data,
        GlideBooleanValue.checked,
      );
    });

    test('pasteIntoCell leaves read-only cells alone', () {
      final edit = glidePasteToCell(
        inner: const GlideTextCell(
          data: 'x',
          displayData: 'x',
          readonly: true,
        ),
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
                  target: const GlideRectangle(x: 10, y: 10, width: 120, height: 30),
                  cell: const GlideItem(0, 0),
                  content: content ??
                      const GlideTextCell(
                        data: 'hello',
                        displayData: 'hello',
                      ),
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
      expect(find.byType(TextField), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(finishedMovement, GlideEditorMovement.down);
      expect((finishedValue as GlideTextCell).data, 'hello');
    });

    testWidgets('enter without forceEditMode moves without committing',
        (tester) async {
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
            GlideTextCell(
              data: 'r$row c$col',
              displayData: 'r$row c$col',
            ),
        ],
    ];

    Widget buildEditor({
      GlideGridCell Function(GlideItem item)? content,
      bool editOnType = true,
    }) {
      edits = [];
      selectionLog = [];
      activationLog = [];
      final cells = table();
      final p = GlideDataEditorProps(
        columns: [
          for (var i = 0; i < 6; i++)
            GlideGridColumn(title: 'C$i', width: 100),
        ],
        rows: 200,
        getCellContent: (item, [_]) =>
            content?.call(item) ?? cells[item.row][item.col],
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
        getCellsForSelection: (region) => [
          for (var y = region.y.toInt();
              y < region.y + region.height && y < cells.length;
              y++)
            [
              for (var x = region.x.toInt();
                  x < region.x + region.width && x < cells[y].length;
                  x++)
                cells[y][x],
            ],
        ],
      );
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 400, height: 400, child: GlideDataEditor(props: p)),
        ),
      );
    }

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

    testWidgets('a second click on the selected cell opens the editor',
        (tester) async {
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

      expect(find.byType(TextField), findsOneWidget);
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

    testWidgets('typing a letter opens the editor with that letter',
        (tester) async {
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

      expect(find.byType(TextField), findsOneWidget);
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

      expect(find.byType(TextField), findsNothing);
      expect(edits, hasLength(1));
      final value = edits.single.value as GlideTextCell;
      expect(value.data, 'z');
    });
  });
}
