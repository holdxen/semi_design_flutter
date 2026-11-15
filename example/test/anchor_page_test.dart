import 'package:example/pages/anchor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('anchor-status'),
  matching: find.textContaining(text),
);

Finder titleOf(String demoKey, String title) =>
    find.descendant(of: keyed(demoKey), matching: find.text(title));

Color? titleColor(WidgetTester tester, String demoKey, String title) =>
    tester.widget<Text>(titleOf(demoKey, title)).style?.color;

double offsetOf(WidgetTester tester, String key) => tester
    .state<ScrollableState>(
      find.descendant(of: keyed(key), matching: find.byType(Scrollable)),
    )
    .position
    .pixels;

Finder trackOf(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiAnchor.slideTrackKey),
);

Finder barOf(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiAnchor.slideBarKey),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: AnchorPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Tap [finder] until [done] holds. The one-shot retry absorbs the dropped hit
/// of docs/known_issues.md #1 without double-firing non-idempotent actions:
/// [done] is checked after each tap. [wait] lets animations settle before the
/// check (the scrollMotion demo animates 300ms).
Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 150),
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
  testWidgets('page renders every demo section and the unsupported note', (
    tester,
  ) async {
    await start(tester);
    for (final title in [
      '基础用法',
      '嵌套层级',
      'size 两档',
      'railTheme 三态',
      'autoCollapse 自动折叠',
      'showTooltip 悬停提示',
      'scrollMotion 与 targetOffset',
      '禁用项',
      'defaultAnchor 初始高亮',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'anchor-basic',
      'anchor-nested',
      'anchor-size-small',
      'anchor-size-default',
      'anchor-theme-primary',
      'anchor-theme-tertiary',
      'anchor-theme-muted',
      'anchor-auto-collapse',
      'anchor-tooltip',
      'anchor-motion',
      'anchor-disabled',
      'anchor-default',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(keyed('anchor-unsupported-note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('defaultAnchor highlights the target link without callbacks', (
    tester,
  ) async {
    await start(tester);
    final t = SemiAnchorTheme.resolve(tester.element(keyed('anchor-basic')));
    // 基础用法：defaultAnchor 首项 → 首行 active 色、次行默认色。
    expect(
      titleColor(tester, 'anchor-basic', '基础概述'),
      t.colorAnchorTitleTextActive,
    );
    expect(
      titleColor(tester, 'anchor-basic', '基础安装'),
      t.colorAnchorTitleTextDefault,
    );
    // defaultAnchor 初始高亮：非首项高亮 + 内容滚到该节（300）。
    expect(
      titleColor(tester, 'anchor-default', '默认锚点乙'),
      t.colorAnchorTitleTextActive,
    );
    expect(
      titleColor(tester, 'anchor-default', '默认锚点甲'),
      t.colorAnchorTitleTextDefault,
    );
    expect(offsetOf(tester, 'anchor-default-scroll'), closeTo(300, 0.5));
    // ★defaultAnchor 不发 onChanged/onClick（shouldNotify=false）。
    expect(statusContaining('onChanged'), findsNothing);
    expect(statusContaining('onClick'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clicking a link scrolls the content and logs the events', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      titleOf('anchor-basic', '基础安装'),
      () => (offsetOf(tester, 'anchor-basic-scroll') - 300).abs() < 0.5,
    );
    // 点击落点 = 目标顶 - targetOffset（基础用法 targetOffset: 0）。
    expect(offsetOf(tester, 'anchor-basic-scroll'), closeTo(300, 0.5));
    expect(statusContaining('onClick #basic-2'), findsOneWidget);
    expect(statusContaining('onChanged #basic-2 ← #basic-1'), findsOneWidget);
    final t = SemiAnchorTheme.resolve(tester.element(keyed('anchor-basic')));
    expect(
      titleColor(tester, 'anchor-basic', '基础安装'),
      t.colorAnchorTitleTextActive,
    );
    expect(
      titleColor(tester, 'anchor-basic', '基础概述'),
      t.colorAnchorTitleTextDefault,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll spy migrates the highlight and logs onChanged', (
    tester,
  ) async {
    await start(tester);
    // defaultAnchor 的 mount 激活也置点击抑制旗标（100ms 静止复位）——等复位后
    // 滚动事件才会跑 spy。
    await tester.pump(const Duration(milliseconds: 150));
    await tester.drag(keyed('anchor-basic-scroll'), const Offset(0, -450));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    // 越过阈值（sec2 顶 < 0）→ 高亮迁移 + onChanged(current, previous)。
    expect(offsetOf(tester, 'anchor-basic-scroll'), greaterThan(350));
    expect(statusContaining('onChanged #basic-2 ← #basic-1'), findsOneWidget);
    expect(statusContaining('onClick'), findsNothing);
    final t = SemiAnchorTheme.resolve(tester.element(keyed('anchor-basic')));
    expect(
      titleColor(tester, 'anchor-basic', '基础安装'),
      t.colorAnchorTitleTextActive,
    );
    expect(
      titleColor(tester, 'anchor-basic', '基础概述'),
      t.colorAnchorTitleTextDefault,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested links indent by eight pixels per level', (tester) async {
    await start(tester);
    await tester.ensureVisible(titleOf('anchor-nested', '嵌套三级一'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(titleOf('anchor-nested', '嵌套二级一'), findsOneWidget);
    expect(titleOf('anchor-nested', '嵌套三级一'), findsOneWidget);
    double dxOf(String title) =>
        tester.getTopLeft(titleOf('anchor-nested', title)).dx;
    // 缩进 8 * level（link.tsx:150 HARDCODE）：二级 - 一级 = 8、三级 - 二级 = 8。
    expect(dxOf('嵌套二级一') - dxOf('嵌套父级一'), moreOrLessEquals(8, epsilon: 0.1));
    expect(dxOf('嵌套三级一') - dxOf('嵌套二级一'), moreOrLessEquals(8, epsilon: 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('autoCollapse keeps only the active branch expanded', (
    tester,
  ) async {
    await start(tester);
    // 初态无 active（''）→ 全部折叠。
    expect(find.text('折叠子项一'), findsNothing);
    expect(find.text('折叠子项三'), findsNothing);
    await tapUntil(
      tester,
      find.text('折叠父级一'),
      () => find.text('折叠子项一').evaluate().isNotEmpty,
    );
    expect(find.text('折叠子项一'), findsOneWidget);
    expect(find.text('折叠子项二'), findsOneWidget);
    expect(find.text('折叠子项三'), findsNothing);
    await tapUntil(
      tester,
      find.text('折叠父级二'),
      () => find.text('折叠子项三').evaluate().isNotEmpty,
    );
    expect(find.text('折叠子项三'), findsOneWidget);
    // 非激活分支整棵折叠。
    expect(find.text('折叠子项一'), findsNothing);
    expect(find.text('折叠子项二'), findsNothing);
    expect(statusContaining('onClick #collapse-2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('size switches font size and slide bar height', (tester) async {
    await start(tester);
    expect(
      tester.widget<Text>(titleOf('anchor-size-small', '尺寸小甲')).style?.fontSize,
      12,
    );
    expect(
      tester
          .widget<Text>(titleOf('anchor-size-default', '尺寸默认甲'))
          .style
          ?.fontSize,
      14,
    );
    // 滑杆高 = 选项高 + 2 × 间距：small 24 / default 28。
    expect(tester.getSize(barOf('anchor-size-small')).height, 24);
    expect(tester.getSize(barOf('anchor-size-default')).height, 28);
    expect(tester.takeException(), isNull);
  });

  testWidgets('railTheme muted hides the slide rail entirely', (tester) async {
    await start(tester);
    expect(trackOf('anchor-theme-primary'), findsOneWidget);
    expect(barOf('anchor-theme-primary'), findsOneWidget);
    expect(trackOf('anchor-theme-tertiary'), findsOneWidget);
    expect(barOf('anchor-theme-tertiary'), findsOneWidget);
    // ★muted 轨道 display: none quirk：整棵滑轨子树不渲染。
    expect(trackOf('anchor-theme-muted'), findsNothing);
    expect(barOf('anchor-theme-muted'), findsNothing);
    final t = SemiAnchorTheme.resolve(
      tester.element(keyed('anchor-theme-primary')),
    );
    BoxDecoration decorationOf(Finder finder) =>
        tester.widget<DecoratedBox>(finder).decoration as BoxDecoration;
    expect(
      decorationOf(barOf('anchor-theme-primary')).color,
      t.colorAnchorSlidePrimaryBgActive,
    );
    expect(
      decorationOf(barOf('anchor-theme-tertiary')).color,
      t.colorAnchorSlideTertiaryBgActive,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled link ignores taps but still receives spy highlight', (
    tester,
  ) async {
    await start(tester);
    // 同演示可点项先证点击生效。
    await tapUntil(
      tester,
      find.text('禁用演示一'),
      () => statusContaining('onClick #disabled-1').evaluate().isNotEmpty,
    );
    expect(statusContaining('onClick #disabled-1'), findsOneWidget);
    // 禁用项点击惰性：无 onClick、无 onChanged。
    await tester.tap(find.text('禁用项（不可点）'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(statusContaining('onClick #disabled-2'), findsNothing);
    expect(statusContaining('onChanged #disabled-2'), findsNothing);
    // ★disabled 照常参与 spy 高亮（注册不受 disabled 影响）。
    await tester.drag(keyed('anchor-disabled-scroll'), const Offset(0, -450));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      statusContaining('onChanged #disabled-2 ← #disabled-1'),
      findsOneWidget,
    );
    // ★-disabled 覆盖 -active 色 quirk：高亮行仍显 disabled 色。
    final t = SemiAnchorTheme.resolve(tester.element(keyed('anchor-disabled')));
    expect(
      titleColor(tester, 'anchor-disabled', '禁用项（不可点）'),
      t.colorAnchorTitleTextDisabled,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('showTooltip reveals the title tooltip on hover', (tester) async {
    await start(tester);
    final tooltip = tester.widget<SemiTooltip>(
      find
          .descendant(
            of: keyed('anchor-tooltip'),
            matching: find.byType(SemiTooltip),
          )
          .first,
    );
    expect(tooltip.position, SemiTooltipPosition.right);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.ensureVisible(keyed('anchor-tooltip'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('提示项甲'), findsOneWidget);
    await gesture.moveTo(tester.getCenter(find.text('提示项甲')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    // 悬停出 tooltip：行内 Text + tooltip 内容 Text。
    expect(find.text('提示项甲'), findsNWidgets(2));
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(find.text('提示项甲'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scrollMotion animates scrolling with targetOffset compensation',
    (tester) async {
      await start(tester);
      await tapUntil(
        tester,
        find.text('动效丙'),
        () => offsetOf(tester, 'anchor-motion-scroll') > 500,
        wait: const Duration(milliseconds: 400),
      );
      // 落点 = 目标顶(600) - targetOffset(60) = 540（animateTo 300ms 后到达）。
      expect(offsetOf(tester, 'anchor-motion-scroll'), closeTo(540, 0.5));
      expect(statusContaining('onClick #motion-3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
