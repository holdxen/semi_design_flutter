import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget _host(Widget child) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Overlay(initialEntries: [OverlayEntry(builder: (_) => child)]),
    ),
  ),
);

void main() {
  testWidgets('renders tabs and activates through callback', (tester) async {
    String? active;
    await tester.pumpWidget(
      _host(
        ChromeTab(
          tabs: const [
            ChromeTabItem(id: 'one', title: 'One'),
            ChromeTabItem(id: 'two', title: 'Two'),
          ],
          activeTabId: 'one',
          onTabActivate: (id) => active = id,
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(tester.getSize(find.text('Two')).height, greaterThan(0));
    await tester.tap(find.text('Two'));
    await tester.pump(const Duration(milliseconds: 60));
    expect(active, 'two');
  });

  testWidgets('add and close callbacks do not mutate the source list', (
    tester,
  ) async {
    var added = false;
    String? closed;
    const tabs = [ChromeTabItem(id: 'one', title: 'One')];
    await tester.pumpWidget(
      _host(
        ChromeTab(
          tabs: tabs,
          activeTabId: 'one',
          onTabAdd: () => added = true,
          onTabClose: (id) => closed = id,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('chrome-tab-add')));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.byKey(const ValueKey('chrome-tab-close-one')));
    await tester.pump(const Duration(milliseconds: 60));
    expect(added, isTrue);
    expect(closed, 'one');
    expect(tabs, hasLength(1));
  });

  testWidgets('group menu switches the selected group', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _host(
        ChromeTab(
          tabs: const [ChromeTabItem(id: 'one', title: 'One')],
          groups: const [
            ChromeTabGroup(id: 'a', name: 'A'),
            ChromeTabGroup(id: 'b', name: 'B'),
          ],
          activeGroupId: 'a',
          onGroupSwitch: (id) => selected = id,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('chrome-tab-group')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    expect(selected, 'b');
  });

  testWidgets('supports local theme and disabled tabs', (tester) async {
    await tester.pumpWidget(
      _host(
        ChromeTabTheme(
          data: const ChromeTabThemeData(
            stripHeight: 48,
            tabActiveBackgroundColor: Color(0xff123456),
          ),
          child: ChromeTab(
            tabs: const [
              ChromeTabItem(id: 'one', title: 'One'),
              ChromeTabItem(id: 'two', title: 'Disabled', disabled: true),
            ],
            activeTabId: 'one',
          ),
        ),
      ),
    );

    expect(find.text('Disabled'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('chrome-tab-tap-one'))).height,
      48,
    );
  });
}
