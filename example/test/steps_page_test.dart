import 'package:example/pages/steps.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder nameOf(String demoKey, String text) =>
    find.descendant(of: keyed(demoKey), matching: find.text(text));

Finder statusContaining(String text) => find.descendant(
  of: keyed('steps-status'),
  matching: find.textContaining(text),
);

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: keyed('steps-status'), matching: find.byType(Text)),
    )
    .map((t) => t.data ?? '')
    .join();

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2000));
  await tester.pumpWidget(const SemiApp(home: StepsPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 200),
}) async {
  for (var i = 0; i < 2; i++) {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
    await tester.pump(wait);
    await tester.pump();
    if (done()) return;
  }
}

void main() {
  testWidgets('page renders every demo section and variant', (tester) async {
    await start(tester);
    for (final title in [
      'fill（默认）',
      'basic 简版',
      'nav 导航式',
      '受控 current 与自定义图标',
      'RTL',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'steps-fill',
      'steps-fill-vertical',
      'steps-fill-status',
      'steps-basic',
      'steps-basic-vertical',
      'steps-basic-small',
      'steps-nav',
      'steps-nav-small',
      'steps-controlled',
      'steps-custom-icon',
      'steps-rtl-fill',
      'steps-rtl-basic',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('fill demo logs onChange for non-current steps only', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      nameOf('steps-fill', '等待中'),
      () => statusContaining('onChange 2').evaluate().isNotEmpty,
    );
    expect(statusContaining('onChange 2'), findsOneWidget);
    expect(statusText(tester), contains('onChange 2'));
    // 当前步骤不回调（current: 1 = 进行中）。
    await tester.ensureVisible(nameOf('steps-fill', '进行中'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(nameOf('steps-fill', '进行中'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(statusContaining('onChange 1'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fill statuses mix custom step.status values', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('steps-fill-status'));
    await tester.pump(const Duration(milliseconds: 100));
    final icons = tester
        .widgetList<SemiIcon>(
          find.descendant(
            of: keyed('steps-fill-status'),
            matching: find.byType(SemiIcon),
          ),
        )
        .map((icon) => icon.data);
    expect(
      icons,
      containsAll([SemiIcons.alertCircle, SemiIcons.alertTriangle]),
    );
    expect(icons, contains(SemiIcons.tickCircle));
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic vertical paints connectors', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('steps-basic-vertical'));
    await tester.pump(const Duration(milliseconds: 100));
    final painters = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: keyed('steps-basic-vertical'),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((p) => p.painter.runtimeType.toString())
        .where((name) => name.contains('BasicVerticalLinePainter'));
    expect(painters, hasLength(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nav demo logs onChange', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      nameOf('steps-nav', '第三步'),
      () => statusContaining('onChange 2').evaluate().isNotEmpty,
    );
    expect(statusContaining('onChange 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled demo follows buttons', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('steps-controlled'));
    await tester.pump(const Duration(milliseconds: 50));
    int currentStep(SemiSteps steps) => steps.current;
    SemiSteps demo() => tester.widget<SemiSteps>(keyed('steps-controlled'));
    expect(currentStep(demo()), 1);
    await tapUntil(tester, find.text('下一步'), () => currentStep(demo()) == 2);
    expect(currentStep(demo()), 2);
    await tapUntil(tester, find.text('上一步'), () => currentStep(demo()) == 1);
    expect(currentStep(demo()), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom icons and RTL render', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('steps-custom-icon'));
    await tester.pump(const Duration(milliseconds: 100));
    final icons = tester
        .widgetList<SemiIcon>(
          find.descendant(
            of: keyed('steps-custom-icon'),
            matching: find.byType(SemiIcon),
          ),
        )
        .map((icon) => icon.data);
    expect(icons, containsAll([SemiIcons.home, SemiIcons.setting]));
    expect(nameOf('steps-custom-icon', '3'), findsNothing);
    await tester.ensureVisible(keyed('steps-rtl-fill'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(nameOf('steps-rtl-fill', '进行中'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
