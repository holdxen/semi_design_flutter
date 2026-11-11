import 'package:example/pages/collapse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: CollapsePage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  // The height animation starts in the next frame; then let 250ms elapse.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
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
    for (final title in ['基础用法', '手风琴', '受控模式', '生命周期', '自定义与禁用', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-collapse'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-collapse').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic panels toggle and default panel starts open', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Hi, bytedance dance dance.'), findsOneWidget);
    expect(find.text('第二个面板的内容，可同时展开多个面板。'), findsNothing);

    await tap(tester, find.text('This is panel header 2'));
    expect(find.text('第二个面板的内容，可同时展开多个面板。'), findsOneWidget);
    expect(find.text('Hi, bytedance dance dance.'), findsOneWidget);

    await tap(tester, find.text('This is panel header 1'));
    expect(find.text('Hi, bytedance dance dance.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accordion keeps one panel open and closes all on re-tap', (
    tester,
  ) async {
    await start(tester);
    await tap(tester, find.text('手风琴面板 A'));
    expect(find.text('内容 A'), findsOneWidget);
    await tap(tester, find.text('手风琴面板 B'));
    expect(find.text('内容 A'), findsNothing);
    expect(find.text('内容 B'), findsOneWidget);
    await tap(tester, find.text('手风琴面板 B'));
    expect(find.text('内容 B'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled collapse reports ordered keys back to the page', (
    tester,
  ) async {
    await start(tester);
    expect(find.textContaining('当前展开：1'), findsOneWidget);
    await tap(tester, find.text('受控面板二'));
    expect(find.textContaining('当前展开：1、2'), findsOneWidget);
    expect(find.textContaining('最近回调：1、2'), findsOneWidget);
    await tap(tester, find.text('受控面板一'));
    expect(find.textContaining('当前展开：2'), findsOneWidget);
    expect(find.textContaining('最近回调：2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lifecycle and custom sections expose their configuration', (
    tester,
  ) async {
    await start(tester);
    final collapseWidgets = tester
        .widgetList<SemiCollapse>(find.byType(SemiCollapse))
        .toList();
    expect(collapseWidgets.any((c) => c.keepDOM), isTrue);
    expect(collapseWidgets.any((c) => c.lazyRender), isTrue);
    final custom = tester.widget<SemiCollapse>(keyed('custom-collapse'));
    expect(custom.expandIconPosition, SemiCollapseIconPosition.left);
    expect(custom.clickHeaderToExpand, isFalse);

    // clickHeaderToExpand=false: header text does not toggle.
    await tap(tester, find.text('箭头在左侧、点击头部不展开'));
    expect(find.text('clickHeaderToExpand: false'), findsNothing);
    // The disabled panel stays collapsed, so its content is never built.
    await tap(tester, find.text('禁用面板'));
    expect(find.text('不可交互'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme collapse', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-collapse'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiCollapseTheme.resolve(
      tester.element(keyed('theme-collapse')),
    );
    expect(theme.colorCollapseHeaderTextDefault, const Color(0xff7b61ff));
    expect(theme.colorCollapseContentTextDefault, const Color(0xff0a7a2f));
    expect(theme.colorCollapseItemBorderDefault, const Color(0xffff8c00));
    expect(theme.radiusCollapseHeader, 8);
    expect(tester.takeException(), isNull);
  });
}
