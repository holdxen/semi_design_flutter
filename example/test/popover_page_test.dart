import 'dart:ui' show PointerDeviceKind;

import 'package:example/pages/popover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: PopoverPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// docs/known_issues.md #1 掉点击的一次性重试。
Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 600),
}) async {
  for (var i = 0; i < 2; i++) {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    for (var j = 0; j < 4; j++) {
      await tester.pump();
    }
    await tester.pump(wait);
    await tester.pump();
    if (done()) return;
  }
}

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: keyed('popover-status'), matching: find.byType(Text)),
    )
    .map((t) => t.data ?? '')
    .join();

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
    for (final title in ['基础用法', '点击与受控', '带箭头', '定位']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('popover-status'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('popover-status').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hover popover shows the content and reports onVisibleChange', (
    tester,
  ) async {
    await start(tester);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.ensureVisible(keyed('basic-target'));
    await gesture.moveTo(tester.getCenter(keyed('basic-target')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }
    expect(find.text('Hi Bytedancer, this is a popover.'), findsOneWidget);
    expect(statusText(tester), contains('基础用法 onVisibleChange: true'));
  });

  testWidgets('click popover opens and outside click closes', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      keyed('click-target'),
      () => find.text('点击触发的气泡卡片。').evaluate().isNotEmpty,
    );
    expect(find.text('点击触发的气泡卡片。'), findsOneWidget);
    expect(statusText(tester), contains('点击用法 onVisibleChange: true'));

    await tapUntil(
      tester,
      keyed('popover-status'),
      () => find.text('点击触发的气泡卡片。').evaluate().isEmpty,
    );
    expect(find.text('点击触发的气泡卡片。'), findsNothing);
  });

  testWidgets('controlled popover follows the visible toggle', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      keyed('toggle-visible'),
      () => find.text('受控气泡：开关在使用方手里。').evaluate().isNotEmpty,
    );
    expect(find.text('受控气泡：开关在使用方手里。'), findsOneWidget);

    await tapUntil(
      tester,
      keyed('toggle-visible'),
      () => find.text('受控气泡：开关在使用方手里。').evaluate().isEmpty,
    );
    expect(find.text('受控气泡：开关在使用方手里。'), findsNothing);
  });

  testWidgets('arrow popover renders the wing and the arrowStyle variant', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      keyed('arrow-target'),
      () => find.text('带箭头的气泡卡片（外层 12px 内边距）。').evaluate().isNotEmpty,
    );
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    final popup = tester.widget<SemiTooltipPopup>(
      find.byType(SemiTooltipPopup),
    );
    expect(popup.showArrow, isTrue);

    await tapUntil(
      tester,
      keyed('arrow-target'),
      () => find.text('带箭头的气泡卡片（外层 12px 内边距）。').evaluate().isEmpty,
    );
    await tapUntil(
      tester,
      keyed('arrow-style-target'),
      () => find.text('arrowStyle 自定义着色。').evaluate().isNotEmpty,
    );
    final styled = tester.widget<SemiTooltipPopup>(
      find.byType(SemiTooltipPopup),
    );
    expect(styled.arrowColor, const Color(0xff4cc3fa));
    expect(styled.arrowFringeColor, const Color(0xff324350));
    expect(tester.takeException(), isNull);
  });
}
