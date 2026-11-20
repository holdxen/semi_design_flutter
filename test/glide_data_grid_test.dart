import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

// ---------------------------------------------------------------------------
// Selection (`internal/data-grid/glide_selection.dart`)
// ---------------------------------------------------------------------------

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
}
