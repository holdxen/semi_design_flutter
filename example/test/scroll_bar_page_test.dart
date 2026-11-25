import 'package:example/pages/scroll_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Future<void> start(
  WidgetTester tester, {
  SemiThemeMode themeMode = SemiThemeMode.light,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(
    SemiApp(themeMode: themeMode, home: const ScrollBarPage()),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in ['垂直滚动', '横向滚动', '常显与自定义样式']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(SemiScrollBar), findsNWidgets(3));
    expect(find.byType(SemiSwitch), findsOneWidget);
  });

  testWidgets('always-visible switch controls the custom scrollbar', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(find.byType(SemiSwitch));
    await tester.pump(const Duration(milliseconds: 100));

    List<RawScrollbar> bars() => tester
        .widgetList<RawScrollbar>(
          find.byWidgetPredicate((widget) => widget is RawScrollbar),
        )
        .toList();
    expect(bars(), hasLength(3));
    expect(bars().last.thumbVisibility, isTrue);

    await tester.tap(find.byType(SemiSwitch));
    await tester.pumpAndSettle();
    expect(bars().last.thumbVisibility, isFalse);
  });

  testWidgets('dark theme renders the page', (tester) async {
    await start(tester, themeMode: SemiThemeMode.dark);
    expect(find.text('垂直滚动'), findsOneWidget);
    expect(find.byType(SemiScrollBar), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
