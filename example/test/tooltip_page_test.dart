import 'package:example/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('sections fit a narrow scaled screen and scroll to the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in ['基础用法', '定位', '触发方式', '显隐控制', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-target'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-target').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all twelve positions are demonstrated', (tester) async {
    await start(tester);
    final tooltips = tester
        .widgetList<SemiTooltip>(find.byType(SemiTooltip))
        .toList();
    expect(
      tooltips.map((tooltip) => tooltip.position).toSet(),
      SemiTooltipPosition.values.toSet(),
    );
    for (final position in SemiTooltipPosition.values) {
      expect(keyed('position-${position.name}'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('hover shows after delay and click toggles with outside close', (
    tester,
  ) async {
    await start(tester);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.ensureVisible(keyed('basic-target'));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(keyed('basic-target')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(find.text('这是一个悬停提示'), findsOneWidget);
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(find.text('这是一个悬停提示'), findsNothing);

    await tap(tester, keyed('click-target'));
    expect(find.text('点击显示，再点外部关闭'), findsOneWidget);
    await tester.tapAt(const Offset(2, 2));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('点击显示，再点外部关闭'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled tooltip follows the visible toggle', (tester) async {
    await start(tester);
    expect(find.text('受控提示：显隐由父级决定'), findsNothing);
    await tap(tester, keyed('toggle-visible'));
    expect(find.text('受控提示：显隐由父级决定'), findsOneWidget);
    expect(find.textContaining('已请求显示提示'), findsOneWidget);
    await tap(tester, keyed('toggle-visible'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(find.text('受控提示：显隐由父级决定'), findsNothing);
    expect(find.textContaining('已请求隐藏提示'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme tooltip', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-tooltip'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiTooltipTheme.resolve(
      tester.element(keyed('theme-tooltip')),
    );
    expect(theme.colorTooltipBgDefault, const Color(0xff7b61ff));
    expect(theme.radiusTooltip, 12);
    expect(theme.widthTooltip, 180);
    expect(theme.spacingTooltipContentPaddingTop, 16);
    expect(tester.takeException(), isNull);
  });
}
