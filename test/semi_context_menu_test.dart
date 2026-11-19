import 'package:flutter/gestures.dart';
// Only for the "renders without any Material dependency" assertion.
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Opaque box so presses always hit the trigger subtree.
Widget _trigger() => SizedBox(key: const Key('trigger'), width: 600, height: 500);

Widget _app(Widget body, {TextDirection textDirection = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: textDirection,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) =>
                  Align(alignment: Alignment.center, child: body),
            ),
          ],
        ),
      ),
    );

/// Bounded frame pumping: the overlay insert plus the measure/reposition pass
/// take a few frames; timers are pumped explicitly by each test.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

/// Opens the context menu at [point]. `kind: touch` keeps the mouse device
/// free for hover gestures later in the same test (the mouse tracker asserts
/// Added/Removed pairing per device).
Future<void> _rightClickAt(
  WidgetTester tester,
  Offset point, {
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) async {
  await tester.tapAt(point, kind: kind, buttons: kSecondaryMouseButton);
  await _settle(tester);
}

/// Motion off: show/hide is synchronous so assertions need no animation
/// settling.
SemiContextMenu _menu({
  required List<SemiDropdownNode> nodes,
  required Widget child,
  bool closeOnEsc = true,
  bool enabled = true,
  bool? visible,
  ValueChanged<bool>? onVisibleChange,
  VoidCallback? onClickOutSide,
  VoidCallback? onEscKeyDown,
}) => SemiContextMenu(
  nodes: nodes,
  child: child,
  motion: false,
  closeOnEsc: closeOnEsc,
  enabled: enabled,
  visible: visible,
  onVisibleChange: onVisibleChange,
  onClickOutSide: onClickOutSide,
  onEscKeyDown: onEscKeyDown,
);

List<SemiDropdownNode> _basicNodes(List<String> hits) => [
  SemiDropdownItemData(name: 'Item A', onTap: () => hits.add('A')),
  SemiDropdownDividerData(),
  SemiDropdownItemData(name: 'Item B', onTap: () => hits.add('B')),
];

void main() {
  group('open and close', () {
    testWidgets('right-click opens the menu at the pointer point', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      expect(find.byType(SemiMenuSurface), findsOneWidget);
      // Radix `sideOffset: 2`: the menu's preferred corner sits 2px off the
      // pointer point.
      expect(
        tester.getRect(find.byType(SemiMenuSurface)).topLeft,
        const Offset(152, 122),
        reason: 'top-left should sit at the pointer + 2px gap',
      );
    });

    testWidgets('the menu flips and clamps near the viewport edge', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(695, 545));
      final rect = tester.getRect(find.byType(SemiMenuSurface));
      expect(rect.left, greaterThanOrEqualTo(8));
      expect(rect.top, greaterThanOrEqualTo(8));
      expect(rect.right, lessThanOrEqualTo(800 - 8));
      expect(rect.bottom, lessThanOrEqualTo(600 - 8));
    });

    testWidgets('right-click again re-anchors the open menu', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await _rightClickAt(tester, const Offset(300, 200));
      expect(find.byType(SemiMenuSurface), findsOneWidget);
      final rect = tester.getRect(find.byType(SemiMenuSurface));
      expect(rect.topLeft, const Offset(302, 202));
    });

    testWidgets('an outside press closes the menu and reports it', (
      tester,
    ) async {
      var outside = 0;
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: _basicNodes(hits),
            onClickOutSide: () => outside++,
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tapAt(const Offset(60, 60));
      await _settle(tester);
      expect(find.byType(SemiMenuSurface), findsNothing);
      expect(outside, 1);
    });

    testWidgets('Escape closes the whole menu and reports', (tester) async {
      var escapes = 0;
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: _basicNodes(hits),
            onEscKeyDown: () => escapes++,
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.byType(SemiMenuSurface), findsNothing);
      expect(escapes, 1);
    });

    testWidgets('closeOnEsc false keeps the menu open', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: _basicNodes(hits),
            closeOnEsc: false,
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(SemiMenuSurface), findsOneWidget);
    });

    testWidgets('a disabled trigger never opens the menu', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: _basicNodes(hits),
            enabled: false,
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      expect(find.byType(SemiMenuSurface), findsNothing);
    });

    testWidgets('the touch long-press opens the menu after 700ms', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      final gesture = await tester.startGesture(
        const Offset(150, 120),
        kind: PointerDeviceKind.touch,
      );
      await tester.pump(const Duration(milliseconds: 700));
      await _settle(tester);
      expect(find.byType(SemiMenuSurface), findsOneWidget);
      expect(
        tester.getRect(find.byType(SemiMenuSurface)).topLeft,
        const Offset(152, 122),
      );
      await gesture.up();
    });

    testWidgets('moving the finger cancels the long-press', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      final gesture = await tester.startGesture(
        const Offset(150, 120),
        kind: PointerDeviceKind.touch,
      );
      await gesture.moveBy(const Offset(20, 20));
      await tester.pump(const Duration(milliseconds: 700));
      await _settle(tester);
      expect(find.byType(SemiMenuSurface), findsNothing);
      await gesture.up();
    });

    testWidgets('controlled visible drives the menu', (tester) async {
      final changes = <bool>[];
      final hits = <String>[];
      final visible = ValueNotifier<bool>(false);
      await tester.pumpWidget(
        _app(
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, value, _) => _menu(
              nodes: _basicNodes(hits),
              visible: value,
              onVisibleChange: changes.add,
              child: _trigger(),
            ),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      expect(find.byType(SemiMenuSurface), findsNothing);
      expect(changes, [true]);
      // Controlled mode: the parent drives visibility, interactions only
      // report.
      visible.value = true;
      await _settle(tester);
      expect(find.byType(SemiMenuSurface), findsOneWidget);
      visible.value = false;
      await _settle(tester);
      expect(find.byType(SemiMenuSurface), findsNothing);
      expect(changes, [true, false]);
    });

    testWidgets('renders without any Material dependency', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      expect(find.byType(SemiMenuSurface), findsOneWidget);
      expect(find.byType(MaterialApp), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('items', () {
    testWidgets('tapping an item fires onTap and closes', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: _basicNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tap(find.text('Item A'));
      await _settle(tester);
      expect(hits, ['A']);
      expect(find.byType(SemiMenuSurface), findsNothing);
    });

    testWidgets('disabled items never fire and keep the menu open', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              SemiDropdownItemData(
                name: 'Off',
                disabled: true,
                onTap: () => hits.add('off'),
              ),
              SemiDropdownItemData(name: 'On', onTap: () => hits.add('on')),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tap(find.text('Off'));
      await tester.pump();
      expect(hits, isEmpty);
      expect(find.byType(SemiMenuSurface), findsOneWidget);
    });

    testWidgets('titles and dividers render', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              const SemiDropdownTitleData('Group 1'),
              ..._basicNodes(hits),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      expect(find.text('Group 1'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.height == 1),
        findsOneWidget,
      );
    });

    testWidgets('checkbox rows toggle and close', (tester) async {
      final checkedChanges = <bool>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              SemiDropdownCheckboxItemData(
                name: 'Option',
                checked: true,
                onCheckedChange: checkedChanges.add,
              ),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tap(find.text('Option'));
      await _settle(tester);
      expect(checkedChanges, [false]);
      expect(find.byType(SemiMenuSurface), findsNothing);
    });

    testWidgets('indeterminate checkbox activates to true', (tester) async {
      final checkedChanges = <bool>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              SemiDropdownCheckboxItemData(
                name: 'Option',
                indeterminate: true,
                onCheckedChange: checkedChanges.add,
              ),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tap(find.text('Option'));
      await _settle(tester);
      expect(checkedChanges, [true]);
    });

    testWidgets('radio rows report their value', (tester) async {
      final values = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              SemiDropdownRadioGroupData(
                value: 'a',
                onValueChange: values.add,
                children: const [
                  SemiDropdownRadioItemData(value: 'a', name: 'Choice A'),
                  SemiDropdownRadioItemData(value: 'b', name: 'Choice B'),
                ],
              ),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tap(find.text('Choice B'));
      await _settle(tester);
      expect(values, ['b']);
      expect(find.byType(SemiMenuSurface), findsNothing);
    });
  });

  group('submenu', () {
    List<SemiDropdownNode> submenuNodes(List<String> hits) => [
      SemiDropdownItemData(name: 'Plain', onTap: () => hits.add('plain')),
      SemiDropdownSubmenuItemData(
        name: 'Open more',
        children: [
          SemiDropdownItemData(name: 'Nested', onTap: () => hits.add('nested')),
        ],
      ),
      SemiDropdownItemData(name: 'Tail', onTap: () => hits.add('tail')),
    ];

    testWidgets('hovering a submenu row opens it after 100ms', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: submenuNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(
        tester,
        const Offset(150, 120),
        kind: PointerDeviceKind.touch,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(-10, -10));
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Open more')));
      await tester.pump();
      expect(find.text('Nested'), findsNothing);
      await tester.pump(kSemiContextMenuSubmenuOpenDelay);
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
    });

    testWidgets('hovering another row closes the open submenu', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: submenuNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(
        tester,
        const Offset(150, 120),
        kind: PointerDeviceKind.touch,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(-10, -10));
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Open more')));
      await tester.pump();
      await tester.pump(kSemiContextMenuSubmenuOpenDelay);
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
      await mouse.moveTo(tester.getCenter(find.text('Tail')));
      await tester.pump();
      await _settle(tester);
      expect(find.text('Nested'), findsNothing);
    });

    testWidgets('leaving every row keeps the submenu for the 300ms grace', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: submenuNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(
        tester,
        const Offset(150, 120),
        kind: PointerDeviceKind.touch,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(-10, -10));
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Open more')));
      await tester.pump();
      await tester.pump(kSemiContextMenuSubmenuOpenDelay);
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
      await mouse.moveTo(const Offset(-10, -10));
      await tester.pump();
      await tester.pump(kSemiContextMenuSubmenuCloseDelay - const Duration(milliseconds: 1));
      expect(find.text('Nested'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      await _settle(tester);
      expect(find.text('Nested'), findsNothing);
    });

    testWidgets('clicking a submenu row toggles its child menu', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: submenuNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.tap(find.text('Open more'));
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
      await tester.tap(find.text('Open more'));
      await _settle(tester);
      expect(find.text('Nested'), findsNothing);
    });

    testWidgets('keyboard opens and closes the submenu', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: submenuNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      // Down → Plain, Down → Open more, ArrowRight opens with focus inside.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(hits, ['nested']);
      expect(find.byType(SemiMenuSurface), findsNothing);
    });

    testWidgets('ArrowLeft closes the submenu and refocuses its trigger', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(nodes: submenuNodes(hits), child: _trigger()),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await _settle(tester);
      expect(find.text('Nested'), findsNothing);
      // Enter re-opens the submenu: the highlight is back on its trigger row.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(find.text('Nested'), findsOneWidget);
    });
  });

  group('keyboard', () {
    testWidgets('arrows cycle the highlight and Enter activates', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              SemiDropdownItemData(name: 'A', onTap: () => hits.add('A')),
              SemiDropdownItemData(
                name: 'Off',
                disabled: true,
                onTap: () => hits.add('Off'),
              ),
              SemiDropdownItemData(name: 'B', onTap: () => hits.add('B')),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['A']);
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['A', 'B']);
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      // Disabled rows are skipped: the second Down lands on B.
      expect(hits, ['A', 'B', 'B']);
    });

    testWidgets('Home and End jump to the edge rows', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              for (final name in ['A', 'B', 'C'])
                SemiDropdownItemData(name: name, onTap: () => hits.add(name)),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C']);
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C', 'A']);
    });

    testWidgets('typeahead matches the typed prefix with wrap-around', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          _menu(
            nodes: [
              for (final name in ['Apple', 'Bravo', 'Bridge', 'Cherry'])
                SemiDropdownItemData(name: name, onTap: () => hits.add(name)),
            ],
            child: _trigger(),
          ),
        ),
      );
      await _rightClickAt(tester, const Offset(150, 120));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['Bravo']);
    });
  });
}
