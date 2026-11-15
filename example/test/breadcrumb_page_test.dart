import 'package:example/pages/breadcrumb.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('breadcrumb-status'),
  matching: find.textContaining(text),
);

Finder nameOf(String demoKey, String name) =>
    find.descendant(of: keyed(demoKey), matching: find.text(name));

/// Effective text style of a breadcrumb item name (the item renders the name
/// Text under its own AnimatedDefaultTextStyle — fontSize/color/fontWeight all
/// live there).
TextStyle styleOf(WidgetTester tester, Finder name) =>
    DefaultTextStyle.of(tester.element(name)).style;

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: keyed('breadcrumb-status'),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .join();

Finder moreOf(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiBreadcrumb.moreKey),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: BreadcrumbPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Tap [finder] until [done] holds. The one-shot retry absorbs the dropped hit
/// of docs/known_issues.md #1 without double-firing non-idempotent actions:
/// [done] is checked after each tap.
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

/// One tap without retry — for negative assertions where a dropped hit is
/// indistinguishable from a swallowed one.
Future<void> tapOnce(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

void main() {
  testWidgets('page renders every demo section and the unsupported note', (
    tester,
  ) async {
    await start(tester);
    for (final title in [
      'routes 模式',
      'children 模式',
      '分隔符',
      '折叠',
      'renderMore',
      'activeIndex',
      'compact 两档',
      'icon 与 noLink',
      '长文本截断与 tooltip',
      'renderItem',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'breadcrumb-routes',
      'breadcrumb-children',
      'breadcrumb-sep-default',
      'breadcrumb-sep-custom',
      'breadcrumb-sep-item',
      'breadcrumb-collapse',
      'breadcrumb-collapse-popover',
      'breadcrumb-render-more',
      'breadcrumb-active-index',
      'breadcrumb-compact',
      'breadcrumb-loose',
      'breadcrumb-icon',
      'breadcrumb-no-link',
      'breadcrumb-tooltip',
      'breadcrumb-render-item',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(keyed('breadcrumb-unsupported-note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('routes mode logs item onClick before parent onClick', (
    tester,
  ) async {
    await start(tester);
    // 首项自身 onClick 先、父 onClick 后（itemFoundation.ts:29-33）。
    await tapUntil(
      tester,
      nameOf('breadcrumb-routes', '组件'),
      () => statusContaining('onClick 组件').evaluate().isNotEmpty,
    );
    expect(statusContaining('item:组件'), findsOneWidget);
    final status = statusText(tester);
    expect(status.indexOf('item:组件'), lessThan(status.indexOf('onClick 组件')));
    // String 条目自动包装：仅父 onClick。
    await tapUntil(
      tester,
      nameOf('breadcrumb-routes', '面包屑'),
      () => statusContaining('onClick 面包屑').evaluate().isNotEmpty,
    );
    expect(statusContaining('onClick 面包屑'), findsOneWidget);
    expect(statusContaining('item:面包屑'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('children mode renders items and fires the onClick chain', (
    tester,
  ) async {
    await start(tester);
    expect(nameOf('breadcrumb-children', '一级'), findsOneWidget);
    expect(nameOf('breadcrumb-children', '二级'), findsOneWidget);
    expect(nameOf('breadcrumb-children', '三级'), findsOneWidget);
    await tapUntil(
      tester,
      nameOf('breadcrumb-children', '二级'),
      () => statusContaining('onClick 二级').evaluate().isNotEmpty,
    );
    expect(statusContaining('item:二级'), findsOneWidget);
    final status = statusText(tester);
    expect(status.indexOf('item:二级'), lessThan(status.indexOf('onClick 二级')));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'separator defaults to slash with custom and per item overrides',
    (tester) async {
      await start(tester);
      // 缺省 '/'（3 项 → 2 个分隔）。
      expect(
        find.descendant(
          of: keyed('breadcrumb-sep-default'),
          matching: find.text('/'),
        ),
        findsNWidgets(2),
      );
      // 自定义：字符串 '>' + Widget 图标（各 3 项 → 2 个分隔）。
      expect(
        find.descendant(
          of: keyed('breadcrumb-sep-custom'),
          matching: find.text('>'),
        ),
        findsNWidgets(2),
      );
      final icons = find.descendant(
        of: keyed('breadcrumb-sep-custom'),
        matching: find.byType(SemiIcon),
      );
      expect(icons, findsNWidgets(2));
      for (final icon in tester.widgetList<SemiIcon>(icons)) {
        expect(icon.data, SemiIcons.chevronRight);
      }
      // item 级 separator 覆盖：首项 '>' 裸渲染、其余回退 context '/'。
      expect(
        find.descendant(
          of: keyed('breadcrumb-sep-item'),
          matching: find.text('>'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: keyed('breadcrumb-sep-item'),
          matching: find.text('/'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('collapse keeps first and tail items behind the more button', (
    tester,
  ) async {
    await start(tester);
    // 7 项 maxItemCount: 4 → 隐藏索引 1..3（首项恒显、末 3 项恒显）。
    expect(nameOf('breadcrumb-collapse', '折叠一'), findsOneWidget);
    expect(nameOf('breadcrumb-collapse', '折叠二'), findsNothing);
    expect(nameOf('breadcrumb-collapse', '折叠三'), findsNothing);
    expect(nameOf('breadcrumb-collapse', '折叠四'), findsNothing);
    expect(nameOf('breadcrumb-collapse', '折叠五'), findsOneWidget);
    expect(nameOf('breadcrumb-collapse', '折叠六'), findsOneWidget);
    expect(nameOf('breadcrumb-collapse', '折叠七'), findsOneWidget);
    expect(moreOf('breadcrumb-collapse'), findsOneWidget);
    // moreType: defaultType — 点 more 展开全部（★单向展开不可回收）。
    await tapUntil(
      tester,
      moreOf('breadcrumb-collapse'),
      () => nameOf('breadcrumb-collapse', '折叠二').evaluate().isNotEmpty,
    );
    for (final name in ['折叠一', '折叠二', '折叠三', '折叠四', '折叠五', '折叠六', '折叠七']) {
      expect(nameOf('breadcrumb-collapse', name), findsOneWidget);
    }
    expect(moreOf('breadcrumb-collapse'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('popover more opens a panel listing the hidden rest items', (
    tester,
  ) async {
    await start(tester);
    expect(nameOf('breadcrumb-collapse-popover', '弹层二'), findsNothing);
    expect(find.byKey(SemiBreadcrumb.popoverPanelKey), findsNothing);
    expect(moreOf('breadcrumb-collapse-popover'), findsOneWidget);
    // moreType: popover — 点 more 弹面板（SemiDropdown trigger: click）。
    await tapUntil(
      tester,
      moreOf('breadcrumb-collapse-popover'),
      () => find.byKey(SemiBreadcrumb.popoverPanelKey).evaluate().isNotEmpty,
      wait: const Duration(milliseconds: 300),
    );
    final panel = find.byKey(SemiBreadcrumb.popoverPanelKey);
    expect(panel, findsOneWidget);
    // 面板列 restItem（隐藏项），restItem 间自拼 separator（3 项 → 2 个）。
    expect(
      find.descendant(of: panel, matching: find.text('弹层二')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('弹层三')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('弹层四')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('/')),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderMore replaces the more area with custom content', (
    tester,
  ) async {
    await start(tester);
    // 自定义省略区：'更多»' + restItems 自拼 separator（2 项 → 1 个）+ more
    // 自带 separator（1 个）+ 可见单元 separator（2 个）= 4 个 '/'。
    expect(
      find.descendant(
        of: keyed('breadcrumb-render-more'),
        matching: find.text('更多»'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('breadcrumb-render-more'),
        matching: find.text('/'),
      ),
      findsNWidgets(4),
    );
    expect(nameOf('breadcrumb-render-more', '自定义二'), findsOneWidget);
    // 点按自定义省略区展开全部（more 单元整体消失）。
    await tapUntil(
      tester,
      find.descendant(
        of: keyed('breadcrumb-render-more'),
        matching: find.text('更多»'),
      ),
      () => find.text('更多»').evaluate().isEmpty,
    );
    expect(find.text('更多»'), findsNothing);
    for (final name in ['自定义一', '自定义二', '自定义三', '自定义四', '自定义五']) {
      expect(nameOf('breadcrumb-render-more', name), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('activeIndex marks the middle item active and swallows its tap', (
    tester,
  ) async {
    await start(tester);
    final t = SemiBreadcrumbTheme.resolve(
      tester.element(keyed('breadcrumb-active-index')),
    );
    // active 项：text-0 色 + 600 字重；非 active：text-2 色 + 400 字重。
    final activeStyle = styleOf(
      tester,
      nameOf('breadcrumb-active-index', '激活二'),
    );
    expect(activeStyle.color, t.colorBreadcrumbActiveTextDefault);
    expect(activeStyle.fontWeight, t.fontBreadcrumbActiveFontWeight);
    expect(activeStyle.fontWeight, FontWeight.w600);
    final idleStyle = styleOf(tester, nameOf('breadcrumb-active-index', '激活一'));
    expect(idleStyle.color, t.colorBreadcrumbDefaultTextDefault);
    expect(idleStyle.fontWeight, t.fontBreadcrumbDefaultFontWeight);
    // ★active 项点击不发 onClick（不跳转 quirk）。
    await tapOnce(tester, nameOf('breadcrumb-active-index', '激活二'));
    expect(statusContaining('onClick'), findsNothing);
    // 非 active 照常回传。
    await tapUntil(
      tester,
      nameOf('breadcrumb-active-index', '激活一'),
      () => statusContaining('onClick 激活一').evaluate().isNotEmpty,
    );
    expect(statusContaining('onClick 激活一'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact switches the font size between twelve and fourteen', (
    tester,
  ) async {
    await start(tester);
    final t = SemiBreadcrumbTheme.resolve(
      tester.element(keyed('breadcrumb-compact')),
    );
    expect(
      styleOf(tester, nameOf('breadcrumb-compact', '紧凑一')).fontSize,
      t.fontBreadcrumbCompactFontSize,
    );
    expect(styleOf(tester, nameOf('breadcrumb-compact', '紧凑一')).fontSize, 12);
    expect(
      styleOf(tester, nameOf('breadcrumb-loose', '宽松一')).fontSize,
      t.fontBreadcrumbLooseFontSize,
    );
    expect(styleOf(tester, nameOf('breadcrumb-loose', '宽松一')).fontSize, 14);
    expect(tester.takeException(), isNull);
  });

  testWidgets('icon renders before names and noLink keeps the onClick chain', (
    tester,
  ) async {
    await start(tester);
    // icon 项各带一枚 SemiIcon。
    expect(
      find.descendant(
        of: keyed('breadcrumb-icon'),
        matching: find.byType(SemiIcon),
      ),
      findsNWidgets(3),
    );
    expect(nameOf('breadcrumb-icon', '图标首页'), findsOneWidget);
    // noLink 项照发 onClick 链（差异清单 25）。
    await tapUntil(
      tester,
      nameOf('breadcrumb-no-link', '无链接甲'),
      () => statusContaining('onClick 无链接甲').evaluate().isNotEmpty,
    );
    expect(statusContaining('item:无链接甲'), findsOneWidget);
    // ★noLink 去 hover 色：悬停仍为默认色。
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    final name = nameOf('breadcrumb-no-link', '无链接乙');
    await tester.ensureVisible(name);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(name));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    final t = SemiBreadcrumbTheme.resolve(
      tester.element(keyed('breadcrumb-no-link')),
    );
    expect(styleOf(tester, name).color, t.colorBreadcrumbDefaultTextDefault);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long name truncates to itemMaxWidth and shows tooltip on hover',
    (tester) async {
      await start(tester);
      const longName = '这是一个非常长的面包屑条目名称用来演示截断宽度与悬停提示';
      final name = nameOf('breadcrumb-tooltip', longName);
      await tester.ensureVisible(name);
      await tester.pump(const Duration(milliseconds: 50));
      // 150px 截断（itemMaxWidth 缺省）。
      final width = tester.getSize(name).width;
      expect(width, lessThanOrEqualTo(150.0));
      expect(width, greaterThan(100.0));
      // hover 出 tooltip（行内 Text + tooltip 内容 Text）。
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(name));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      expect(find.text(longName), findsNWidgets(2));
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      expect(find.text(longName), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renderItem replaces the default name rendering', (tester) async {
    await start(tester);
    expect(
      find.descendant(
        of: keyed('breadcrumb-render-item'),
        matching: find.text('自定义 渲染一'),
      ),
      findsOneWidget,
    );
    expect(nameOf('breadcrumb-render-item', '渲染一'), findsNothing);
    // 自定义条目点击仍走 onClick 链。
    await tapUntil(
      tester,
      nameOf('breadcrumb-render-item', '自定义 渲染一'),
      () => statusContaining('onClick 渲染一').evaluate().isNotEmpty,
    );
    expect(statusContaining('onClick 渲染一'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
