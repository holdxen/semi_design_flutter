import 'package:example/pages/semi_chrome_tab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget _host() => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(1200, 1600)),
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(
            builder: (_) => const SizedBox(
              width: 1200,
              height: 1600,
              child: SemiChromeTabPage(),
            ),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('SemiChromeTab gallery page renders every showcase section', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('SemiChromeTab'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-theme-presets')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-theme-editor')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-overflow')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-tooltip')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-icon-demo')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-state-json')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-event-log')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('semi-chrome-tab-quick-start')),
      findsOneWidget,
    );
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('订单中心'), findsOneWidget);
    expect(find.byType(SemiChromeTab), findsNWidgets(4));
  });

  testWidgets('preview activates and closes controlled tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('订单中心'));
    await tester.pump();
    expect(find.text('tab-activate → orders'), findsWidgets);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('semi-chrome-tab-orders'))),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('semi-chrome-tab-close-orders')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('订单中心'), findsNothing);
    expect(find.text('tab-close → orders'), findsWidgets);
  });

  testWidgets('theme preset and editor update the preview', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    final before = tester
        .getSize(find.byKey(const ValueKey('semi-chrome-tab-preview')))
        .height;
    await tester.tap(find.text('Sea Salt Blue'));
    await tester.pump();
    final after = tester
        .getSize(find.byKey(const ValueKey('semi-chrome-tab-preview')))
        .height;
    expect(before, 38);
    expect(after, 44);
  });
}
