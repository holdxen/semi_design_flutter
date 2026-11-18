import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

const _hostWidth = 640.0;

final ValueNotifier<Widget> _body = ValueNotifier<Widget>(
  const SizedBox.shrink(),
);

Widget _host() => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(
            builder: (_) => Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: _hostWidth,
                child: ValueListenableBuilder<Widget>(
                  valueListenable: _body,
                  builder: (_, child, _) => child,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(800, 600));
  _body.value = child;
  await tester.pumpWidget(_host());
  await tester.pump();
}

Future<void> update(WidgetTester tester, Widget child) async {
  _body.value = child;
  await tester.pump();
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(1, 1));
  addTearDown(gesture.removePointer);
  return gesture;
}

List<SemiChromeTabItem> manyTabs(int count) => <SemiChromeTabItem>[
  for (var i = 0; i < count; i++) SemiChromeTabItem(id: 't$i', title: 'T$i'),
];

double tabWidth(WidgetTester tester, String id) =>
    tester.getSize(find.byKey(ValueKey<String>('semi-chrome-tab-$id'))).width;

/// The semantics tree requires a WidgetsApp host; these tests assert the
/// installed labels directly on the [Semantics] widgets instead.
Finder byLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

SemiChromeTab _tabs({
  required List<SemiChromeTabItem> tabs,
  String? activeTabId,
  List<SemiChromeTabGroup> groups = const <SemiChromeTabGroup>[],
  String? activeGroupId,
  SemiChromeTabLocale locale = SemiChromeTabLocale.en,
  bool hideAddButton = false,
  bool hideGroupButton = false,
  SemiChromeTabTooltipMode tooltipMode = SemiChromeTabTooltipMode.truncated,
  SemiChromeTabLayoutAnimation layoutAnimation =
      SemiChromeTabLayoutAnimation.chromium,
  ValueChanged<String>? onTabActivate,
  ValueChanged<String>? onTabEditAddress,
  ValueChanged<String>? onTabClose,
  VoidCallback? onTabAdd,
  ValueChanged<SemiChromeTabReorderInfo>? onTabReorder,
  ValueChanged<String>? onTabCloseLeft,
  ValueChanged<String>? onTabCloseRight,
  ValueChanged<String>? onTabCloseOthers,
  ValueChanged<String>? onGroupSwitch,
  VoidCallback? onGroupAdd,
  ValueChanged<String>? onGroupRename,
  ValueChanged<String>? onGroupDelete,
  Widget? Function(SemiChromeTabItem tab)? renderTabIcon,
  Widget? Function(SemiChromeTabItem tab)? renderTabTooltip,
}) => SemiChromeTab(
  tabs: tabs,
  activeTabId: activeTabId,
  groups: groups,
  activeGroupId: activeGroupId,
  locale: locale,
  hideAddButton: hideAddButton,
  hideGroupButton: hideGroupButton,
  tooltipMode: tooltipMode,
  layoutAnimation: layoutAnimation,
  onTabActivate: onTabActivate,
  onTabEditAddress: onTabEditAddress,
  onTabClose: onTabClose,
  onTabAdd: onTabAdd,
  onTabReorder: onTabReorder,
  onTabCloseLeft: onTabCloseLeft,
  onTabCloseRight: onTabCloseRight,
  onTabCloseOthers: onTabCloseOthers,
  onGroupSwitch: onGroupSwitch,
  onGroupAdd: onGroupAdd,
  onGroupRename: onGroupRename,
  onGroupDelete: onGroupDelete,
  renderTabIcon: renderTabIcon,
  renderTabTooltip: renderTabTooltip,
);

ScrollPosition _scrollPosition(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(SemiChromeTab),
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position;

void main() {
  test('resolved chrome defaults match the upstream stylesheet', () {
    final resolved = const SemiChromeTabThemeData().resolve(
      const SemiThemeData.light(),
    );
    expect(resolved.chromeTabsHeight, 38);
    expect(resolved.chromeTabHeight, 38);
    expect(resolved.chromeTabMinWidth, 52);
    expect(resolved.chromeTabMaxWidth, 120);
    expect(resolved.chromeTabRadius, 8);
    expect(resolved.chromeTabsBackground, const Color(0xffdee1e6));
    expect(resolved.chromeTabTextColor, const Color(0xff5f6368));
    expect(resolved.chromeTabActiveTextColor, const Color(0xff202124));
    expect(resolved.chromeTabHoverBackground, const Color(0xfff4f5f6));
    expect(resolved.chromeTabActiveBackground, const Color(0xffffffff));
    expect(resolved.chromeTabDividerColor, const Color(0x4faeb5c6));
    expect(resolved.chromeTabsAccentColor, const Color(0xff1a73e8));
    expect(resolved.chromeTabsMenuIconBackground, const Color(0x9effffff));
    expect(resolved.chromeTabsMenuTextColor, resolved.chromeTabTextColor);
    expect(resolved.chromeTabEnterDuration, const Duration(milliseconds: 480));
    expect(resolved.chromeTabCloseDuration, const Duration(milliseconds: 140));
    expect(
      resolved.chromeTabTooltipMoveDuration,
      const Duration(milliseconds: 140),
    );
  });

  test('chrome-tab-height is max(strip height, 28)', () {
    final short = const SemiChromeTabThemeData(chromeTabsHeight: 24)
        .resolve(const SemiThemeData.light());
    final tall = const SemiChromeTabThemeData(chromeTabsHeight: 46)
        .resolve(const SemiThemeData.light());
    expect(short.chromeTabHeight, 28);
    expect(tall.chromeTabHeight, 46);
  });

  test('layout animation duration defaults to Chromium bounds timing', () {
    final resolved = const SemiChromeTabThemeData().resolve(
      const SemiThemeData.light(),
    );
    expect(resolved.chromeTabLayoutDuration, const Duration(milliseconds: 200));
  });

  testWidgets('immediate layout mode updates widths without animation', (
    tester,
  ) async {
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
      ),
    );
    expect(tabWidth(tester, 't0'), 120);

    await update(
      tester,
      _tabs(
        tabs: manyTabs(10),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
      ),
    );
    expect(tabWidth(tester, 't0'), closeTo(56.2, 0.01));
  });

  testWidgets('Chromium layout mode animates tab width bounds', (tester) async {
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.chromium,
      ),
    );
    final startWidth = tabWidth(tester, 't0');

    await update(
      tester,
      _tabs(
        tabs: manyTabs(10),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.chromium,
      ),
    );
    final firstFrameWidth = tabWidth(tester, 't0');
    expect(firstFrameWidth, startWidth);

    await tester.pump(const Duration(milliseconds: 100));
    final middleWidth = tabWidth(tester, 't0');
    expect(middleWidth, lessThan(startWidth));
    expect(middleWidth, greaterThan(56.2));

    await tester.pump(const Duration(milliseconds: 400));
    expect(tabWidth(tester, 't0'), closeTo(56.2, 0.01));
  });

  testWidgets('tabs shrink from max to min width before overflowing', (
    tester,
  ) async {
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
      ),
    );
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
      ),
    );
    expect(tabWidth(tester, 't0'), 120);

    await update(
      tester,
      _tabs(
        tabs: manyTabs(10),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
      ),
    );
    expect(tabWidth(tester, 't0'), closeTo(56.2, 0.01));

    await update(
      tester,
      _tabs(
        tabs: manyTabs(12),
        activeTabId: 't0',
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
      ),
    );
    expect(tabWidth(tester, 't0'), 52);
    expect(_scrollPosition(tester).maxScrollExtent, greaterThan(0));
  });

  testWidgets('click activates and a second click reports edit-address', (
    tester,
  ) async {
    final activated = <String>[];
    final edited = <String>[];
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        onTabActivate: activated.add,
        onTabEditAddress: edited.add,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('semi-chrome-tab-t1')));
    await tester.pump();
    expect(activated, <String>['t1']);
    expect(edited, isEmpty);

    await tester.tap(find.byKey(const ValueKey('semi-chrome-tab-t1')));
    await tester.pump();
    expect(activated, <String>['t1', 't1']);
    expect(edited, <String>['t1']);

    await tester.pump(const Duration(milliseconds: 320));
    await tester.tap(find.byKey(const ValueKey('semi-chrome-tab-t1')));
    await tester.pump();
    expect(activated, <String>['t1', 't1', 't1']);
    expect(edited, <String>['t1']);
  });

  testWidgets('close animates then emits once and relayouts immediately', (
    tester,
  ) async {
    final closed = <String>[];
    final activated = <String>[];
    final mouse = await startMouse(tester);
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        onTabClose: closed.add,
        onTabActivate: activated.add,
      ),
    );
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-t2'))),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('semi-chrome-tab-close-t2')));
    await tester.pump();
    expect(closed, isEmpty);
    // A closing tab stops hit-testing immediately (`pointer-events: none`).
    await tester.tap(
      find.byKey(const ValueKey('semi-chrome-tab-t2')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(activated, isEmpty);
    // Closing starts a fresh layout immediately, while the item fades out.
    expect(tabWidth(tester, 't0'), 120);
    await tester.pump(const Duration(milliseconds: 80));
    expect(closed, isEmpty);
    await tester.pump(const Duration(milliseconds: 80));
    expect(closed, <String>['t2']);

    await update(tester, _tabs(tabs: manyTabs(2), activeTabId: 't0'));
    expect(tabWidth(tester, 't0'), 120);
  });

  testWidgets('closing a tab while remaining tabs widen does not overflow', (
    tester,
  ) async {
    final mouse = await startMouse(tester);
    var tabs = manyTabs(10);
    var activeTabId = 't0';
    final closed = <String>[];

    await pumpHost(
      tester,
      StatefulBuilder(
        builder: (context, setState) => _tabs(
          tabs: tabs,
          activeTabId: activeTabId,
          onTabActivate: (id) => setState(() => activeTabId = id),
          onTabClose: (id) {
            closed.add(id);
            setState(() {
              tabs = tabs.where((tab) => tab.id != id).toList();
              if (activeTabId == id) activeTabId = tabs.first.id;
            });
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final lastTab = find.byKey(const ValueKey('semi-chrome-tab-t9'));
    await mouse.moveTo(tester.getCenter(lastTab));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('semi-chrome-tab-close-t9')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(closed, isEmpty);

    // The close callback removes the tab; all remaining bounds animate toward
    // their wider targets. Check every intermediate frame for RenderFlex errors.
    for (var elapsed = 0; elapsed < 360; elapsed += 20) {
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.takeException(), isNull);
    }
    expect(closed, <String>['t9']);
    expect(tabs, hasLength(9));
    expect(tabWidth(tester, 't0'), greaterThan(56));
  });

  testWidgets('adding fewer than five tabs does not require an anchor', (
    tester,
  ) async {
    var added = false;
    await pumpHost(
      tester,
      _tabs(tabs: manyTabs(2), activeTabId: 't0', onTabAdd: () => added = true),
    );
    await tester.tap(byLabel('Add tab'));
    await tester.pump();
    expect(added, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'adding a tab keeps the add button anchored during bounds motion',
    (tester) async {
      final mouse = await startMouse(tester);
      var tabs = manyTabs(10);
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) => _tabs(
            tabs: tabs,
            activeTabId: 't0',
            onTabAdd: () => setState(() {
              tabs = <SemiChromeTabItem>[
                ...tabs,
                const SemiChromeTabItem(id: 't10', title: 'T10'),
              ];
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addButton = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Add tab',
      );
      final initialAddLeft = tester.getRect(addButton).left;
      final lastTab = find.byKey(const ValueKey('semi-chrome-tab-t9'));
      final initialLastWidth = tester.getSize(lastTab).width;
      expect(initialLastWidth, closeTo(56.2, 0.01));

      await mouse.moveTo(tester.getCenter(addButton));
      await tester.pump();
      await tester.tap(addButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.getRect(addButton).left, closeTo(initialAddLeft, 0.5));

      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(tester.getRect(addButton).left, closeTo(initialAddLeft, 0.5));
      expect(tester.getSize(lastTab).width, lessThan(initialLastWidth));

      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull);
      expect(tester.getRect(addButton).left, closeTo(initialAddLeft, 0.5));
      // The insert reflow now spans the enter duration, so it is still moving
      // past the old 200ms layout window.
      expect(tester.getSize(lastTab).width, greaterThan(52));

      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(tester.getRect(addButton).left, closeTo(initialAddLeft, 0.5));
      expect(tester.getSize(lastTab).width, 52);
    },
  );

  testWidgets('adding below the anchor threshold still calls onTabAdd', (
    tester,
  ) async {
    var added = false;
    await pumpHost(
      tester,
      _tabs(tabs: manyTabs(4), activeTabId: 't0', onTabAdd: () => added = true),
    );
    await tester.tap(byLabel('Add tab'));
    await tester.pump();
    expect(added, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a new tab enters with a scale/opacity animation', (
    tester,
  ) async {
    await pumpHost(tester, _tabs(tabs: manyTabs(2), activeTabId: 't0'));
    await update(tester, _tabs(tabs: manyTabs(3), activeTabId: 't0'));
    final animation = find.byKey(const ValueKey('semi-chrome-tab-entering-t2'));
    expect(tester.widget<Opacity>(animation).opacity, 0);
    await tester.pump(const Duration(milliseconds: 80));
    final mid = tester.widget<Opacity>(animation).opacity;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    // The entrance now lasts as long as the close sequence (140 + 200ms), so
    // it is still running past the old 160ms point.
    await tester.pump(const Duration(milliseconds: 200));
    expect(animation, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 240));
    expect(animation, findsNothing);
  });

  testWidgets('drag and drop reports before/after against the target', (
    tester,
  ) async {
    SemiChromeTabReorderInfo? reorder;
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't0',
        onTabReorder: (info) => reorder = info,
      ),
    );
    final mouse = await startMouse(tester);
    final source = tester.getCenter(
      find.byKey(const ValueKey('semi-chrome-tab-t0')),
    );
    final target = tester.getCenter(
      find.byKey(const ValueKey('semi-chrome-tab-t1')),
    );
    await mouse.moveTo(source);
    await mouse.down(source);
    await tester.pump();
    await mouse.moveTo(target + const Offset(30, 0));
    await tester.pump();
    await mouse.up();
    await tester.pump();
    expect(reorder, isNotNull);
    expect(reorder!.tabId, 't0');
    expect(reorder!.targetTabId, 't1');
    expect(reorder!.position, SemiChromeTabReorderPosition.after);
  });

  testWidgets('context menu emits batch close actions', (tester) async {
    String? closeLeft;
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(3),
        activeTabId: 't1',
        onTabCloseLeft: (id) => closeLeft = id,
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('semi-chrome-tab-t1')),
      buttons: kSecondaryButton,
    );
    await tester.pumpAndSettle();
    expect(find.text('Close all to the right'), findsOneWidget);
    expect(find.text('Close other tabs'), findsOneWidget);
    await tester.tap(find.text('Close all to the left'));
    await tester.pumpAndSettle();
    expect(closeLeft, 't1');
    expect(find.text('Close all to the left'), findsNothing);
  });

  testWidgets('long press opens the context menu on touch devices', (
    tester,
  ) async {
    await pumpHost(tester, _tabs(tabs: manyTabs(3), activeTabId: 't0'));
    await tester.longPress(find.byKey(const ValueKey('semi-chrome-tab-t1')));
    await tester.pumpAndSettle();
    expect(find.text('Close all to the left'), findsOneWidget);
    expect(find.text('Close other tabs'), findsOneWidget);
  });

  testWidgets('group menu switches groups and exposes row actions on hover', (
    tester,
  ) async {
    String? switched;
    String? renamed;
    var added = false;
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(2),
        activeTabId: 't0',
        groups: const <SemiChromeTabGroup>[
          SemiChromeTabGroup(id: 'work', name: 'Work'),
          SemiChromeTabGroup(id: 'study', name: 'Study'),
        ],
        activeGroupId: 'work',
        onGroupSwitch: (id) => switched = id,
        onGroupRename: (id) => renamed = id,
        onGroupAdd: () => added = true,
      ),
    );
    await tester.tap(byLabel('Select group'));
    await tester.pumpAndSettle();
    final work = tester.widget<Text>(find.text('Work'));
    expect(work.style?.color, const Color(0xff1a73e8));
    expect(work.style?.fontWeight, FontWeight.w600);
    expect(find.text('＋ New group'), findsOneWidget);
    expect(byLabel('Rename Work'), findsNothing);

    final mouse = await startMouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Work')));
    await tester.pump();
    expect(byLabel('Rename Work'), findsOneWidget);
    await tester.tap(byLabel('Rename Work'));
    await tester.pumpAndSettle();
    expect(renamed, 'work');
    expect(find.text('Study'), findsNothing);

    await tester.tap(byLabel('Select group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(switched, 'study');

    await tester.tap(byLabel('Select group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('＋ New group'));
    await tester.pumpAndSettle();
    expect(added, isTrue);
  });

  testWidgets('overflow buttons and hidden-tab popover', (tester) async {
    String? activated;
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(12),
        activeTabId: 't0',
        onTabActivate: (id) => activated = id,
      ),
    );
    await tester.pump();
    expect(byLabel('Scroll tabs left'), findsNothing);
    expect(byLabel('Scroll tabs right'), findsOneWidget);

    final mouse = await startMouse(tester);
    await mouse.moveTo(tester.getCenter(byLabel('Scroll tabs right')));
    await tester.pumpAndSettle();
    // The last tab is clipped to the right of the visible area.
    expect(find.text('T11'), findsNWidgets(2));
    await tester.tap(find.text('T11').last);
    await tester.pump();
    expect(activated, 't11');

    await tester.tap(byLabel('Scroll tabs right'));
    await tester.pumpAndSettle();
    expect(_scrollPosition(tester).pixels, greaterThan(0));
    expect(byLabel('Scroll tabs left'), findsOneWidget);
  });

  testWidgets('mouse wheel scrolls the strip horizontally', (tester) async {
    await pumpHost(tester, _tabs(tabs: manyTabs(12), activeTabId: 't0'));
    await tester.pump();
    final mouse = await startMouse(tester);
    final center = tester.getCenter(
      find.byKey(const ValueKey('semi-chrome-tab-t3')),
    );
    await mouse.moveTo(center);
    await tester.sendEventToBinding(
      PointerScrollEvent(position: center, scrollDelta: const Offset(0, 120)),
    );
    await tester.pump();
    expect(_scrollPosition(tester).pixels, 62);
  });

  testWidgets('active tab is revealed when it changes', (tester) async {
    await pumpHost(tester, _tabs(tabs: manyTabs(12), activeTabId: 't11'));
    await tester.pump();
    expect(_scrollPosition(tester).pixels, greaterThan(0));
    final scrolled = _scrollPosition(tester).pixels;

    await update(tester, _tabs(tabs: manyTabs(12), activeTabId: 't0'));
    await tester.pump();
    expect(_scrollPosition(tester).pixels, lessThan(scrolled));
    expect(_scrollPosition(tester).pixels, 0);
  });

  testWidgets('Chromium title tail fade only wraps overflowing title text', (
    tester,
  ) async {
    final mouse = await startMouse(tester);
    await pumpHost(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(
            id: 'long',
            title: 'A very long title that overflows the tab',
          ),
          SemiChromeTabItem(id: 'short', title: 'Short'),
        ],
        activeTabId: 'long',
        renderTabIcon: (tab) => const SizedBox.square(dimension: 16),
      ),
    );

    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-long'))),
    );
    await tester.pump();
    final fade = find.byKey(const ValueKey('semi-chrome-tab-title-fade'));
    expect(fade, findsOneWidget);
    final fadeRect = tester.getRect(fade);
    final titleRect = tester.getRect(
      find.byKey(const ValueKey('semi-chrome-tab-title-long')),
    );
    final tabRect = tester.getRect(
      find.byKey(const ValueKey('semi-chrome-tab-long')),
    );
    expect(fadeRect.left, greaterThanOrEqualTo(titleRect.left));
    expect(fadeRect.right, lessThanOrEqualTo(titleRect.right));
    expect(fadeRect.right, lessThanOrEqualTo(tabRect.right));
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('short titles do not create a Chromium fade mask', (
    tester,
  ) async {
    final mouse = await startMouse(tester);
    await pumpHost(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(id: 'short', title: 'Short'),
        ],
        activeTabId: 'short',
      ),
    );
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-short'))),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-title-fade')),
      findsNothing,
    );
  });

  testWidgets('Chromium title fade follows RTL tail direction', (tester) async {
    final mouse = await startMouse(tester);
    await pumpHost(
      tester,
      Directionality(
        textDirection: TextDirection.rtl,
        child: _tabs(
          tabs: const <SemiChromeTabItem>[
            SemiChromeTabItem(
              id: 'rtl',
              title: 'عنوان طويل جدا لا يتسع داخل اللسان',
            ),
          ],
          activeTabId: 'rtl',
        ),
      ),
    );
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-rtl'))),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-title-fade')),
      findsOneWidget,
    );
  });

  testWidgets('tooltip follows truncated/always/never and custom renderers', (
    tester,
  ) async {
    final mouse = await startMouse(tester);
    const longTitle = 'A very long tab title that cannot possibly fit';
    var rendererCalls = 0;

    await pumpHost(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(id: 'long', title: longTitle),
          SemiChromeTabItem(id: 'short', title: 'Short'),
        ],
        activeTabId: 'long',
        renderTabTooltip: (tab) {
          rendererCalls++;
          return Text('TIP ${tab.id}');
        },
      ),
    );
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-long'))),
    );
    await tester.pump();
    expect(find.text('TIP long'), findsOneWidget);

    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-short'))),
    );
    await tester.pump();
    expect(find.text('TIP short'), findsNothing);
    await tester.pump(const Duration(milliseconds: 140));
    expect(find.text('TIP long'), findsNothing);

    await update(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(id: 'short', title: 'Short'),
        ],
        activeTabId: 'short',
        tooltipMode: SemiChromeTabTooltipMode.always,
        layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
        renderTabTooltip: (_) => const Text('ALWAYS'),
      ),
    );
    await tester.pump();
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-short'))),
    );
    await tester.pump();
    expect(find.text('ALWAYS'), findsOneWidget);

    await update(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(id: 'long', title: longTitle),
        ],
        activeTabId: 'long',
        renderTabTooltip: (_) => null,
      ),
    );
    await tester.pump();
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(const Duration(milliseconds: 140));
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-long'))),
    );
    await tester.pump();
    expect(rendererCalls, greaterThan(0));
    expect(find.text('TIP long'), findsNothing);

    await update(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(id: 'long', title: longTitle),
        ],
        activeTabId: 'long',
        tooltipMode: SemiChromeTabTooltipMode.never,
        renderTabTooltip: (_) => const Text('NEVER'),
      ),
    );
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(const Duration(milliseconds: 140));
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-long'))),
    );
    await tester.pump();
    expect(find.text('NEVER'), findsNothing);
  });

  testWidgets('locale switches built-in accessibility labels', (tester) async {
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(1),
        activeTabId: 't0',
        locale: SemiChromeTabLocale.zh,
      ),
    );
    expect(byLabel('添加标签页'), findsOneWidget);

    await update(
      tester,
      _tabs(
        tabs: manyTabs(1),
        activeTabId: 't0',
        locale: SemiChromeTabLocale.ko,
      ),
    );
    expect(byLabel('탭 추가'), findsOneWidget);
  });

  testWidgets('hide flags remove the add and group controls', (tester) async {
    await pumpHost(
      tester,
      _tabs(
        tabs: manyTabs(2),
        activeTabId: 't0',
        hideAddButton: true,
        hideGroupButton: true,
      ),
    );
    expect(find.text('+'), findsNothing);
    expect(byLabel('Select group'), findsNothing);
    expect(byLabel('Add tab'), findsNothing);
  });

  testWidgets('empty tabs still show the add button and group menu', (
    tester,
  ) async {
    await pumpHost(
      tester,
      _tabs(
        tabs: const <SemiChromeTabItem>[],
        activeGroupId: 'work',
        groups: const <SemiChromeTabGroup>[
          SemiChromeTabGroup(id: 'work', name: 'Work'),
        ],
      ),
    );
    expect(byLabel('Add tab'), findsOneWidget);
    await tester.tap(byLabel('Select group'));
    await tester.pumpAndSettle();
    expect(find.text('＋ New group'), findsOneWidget);
  });

  testWidgets('local and nested themes merge before resolving', (tester) async {
    late SemiResolvedChromeTabThemeData resolved;
    await pumpHost(
      tester,
      SemiChromeTabTheme(
        data: const SemiChromeTabThemeData(chromeTabsHeight: 48),
        child: SemiChromeTabTheme(
          data: const SemiChromeTabThemeData(chromeTabRadius: 12),
          child: Builder(
            builder: (context) {
              resolved = SemiChromeTabTheme.resolve(context);
              return _tabs(
                tabs: manyTabs(2),
                activeTabId: 't0',
                hideAddButton: true,
                hideGroupButton: true,
              );
            },
          ),
        ),
      ),
    );
    expect(resolved.chromeTabsHeight, 48);
    expect(resolved.chromeTabHeight, 48);
    expect(resolved.chromeTabRadius, 12);
    expect(tester.getSize(find.byType(SemiChromeTab)).height, 48);
  });
}
