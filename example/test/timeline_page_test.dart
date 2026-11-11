import 'package:example/pages/timeline.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiTimeline timeline(WidgetTester tester, String key) =>
    tester.widget<SemiTimeline>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: TimelinePage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
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
    for (final title in ['基础用法', '布局模式', '节点类型', '自定义节点', '交互与元数据', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-timeline'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-timeline').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic and layout modes expose expected configuration', (
    tester,
  ) async {
    await start(tester);
    final basic = timeline(tester, 'basic-timeline');
    expect(basic.mode, SemiTimelineMode.left);
    expect(basic.items, hasLength(3));
    expect(basic.semanticsLabel, '发布流程');
    expect(timeline(tester, 'right-timeline').mode, SemiTimelineMode.right);
    expect(timeline(tester, 'center-timeline').mode, SemiTimelineMode.center);
    final alternate = timeline(tester, 'alternate-timeline');
    expect(alternate.mode, SemiTimelineMode.alternate);
    expect(alternate.items, hasLength(4));
    expect(alternate.items.last.position, SemiTimelinePosition.right);
    expect(tester.takeException(), isNull);
  });

  testWidgets('five node types and custom nodes render', (tester) async {
    await start(tester);
    expect(timeline(tester, 'types-timeline').items.map((item) => item.type), [
      SemiTimelineItemType.normal,
      SemiTimelineItemType.ongoing,
      SemiTimelineItemType.success,
      SemiTimelineItemType.warning,
      SemiTimelineItemType.error,
    ]);
    final custom = timeline(tester, 'custom-timeline');
    expect(custom.items[0].dot, isA<SemiIcon>());
    expect(custom.items[0].color, isNull);
    expect(custom.items[1].color, const Color(0xFFFFB4B4));
    expect(custom.items[2].dot, isA<SemiIcon>());
    expect(custom.items[2].color, const Color(0xFFB4D8FF));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap interaction updates status and zero metadata keeps zero', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('点击可交互的节点查看事件。'), findsOneWidget);
    await tap(tester, find.text('点击我'));
    expect(find.text('点击了「点击我」，time: 0 仍会渲染。'), findsOneWidget);
    await tap(tester, find.text('也可以点击'));
    expect(find.text('点击了「也可以点击」。'), findsOneWidget);
    await tester.ensureVisible(keyed('interactive-timeline'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('0'), findsOneWidget);
    expect(find.text('time 为 false 不渲染'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme timeline', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-timeline'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiTimelineTheme.resolve(
      tester.element(keyed('theme-timeline')),
    );
    expect(theme.colorTimelineDotDefaultBgDefault, const Color(0xff7b61ff));
    expect(theme.spacingTimelineContentMarginLeft, 32);
    expect(theme.spacingTimelineItemPaddingBottom, 32);
    expect(tester.takeException(), isNull);
  });
}
