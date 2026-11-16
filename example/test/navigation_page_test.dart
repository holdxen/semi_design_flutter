import 'package:example/pages/navigation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('navigation-status'),
  matching: find.textContaining(text),
);

Finder nameOf(String demoKey, String text) =>
    find.descendant(of: keyed(demoKey), matching: find.text(text));

/// Scoped root (the page hosts several SemiNavigation instances sharing the
/// static anchor keys — always resolve through the demo container).
Finder navIn(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiNavigation.rootKey),
);

Finder collapseButtonIn(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiNavigation.collapseButtonKey),
);

Finder iconsIn(String demoKey) =>
    find.descendant(of: keyed(demoKey), matching: find.byType(SemiIcon));

double textDx(WidgetTester tester, Finder text) => tester.getTopLeft(text).dx;

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: keyed('navigation-status'),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .join();

/// 读行级 Semantics 的 selected 属性（aria 近似，见 widget 差异清单 28）。
bool selectedFlag(WidgetTester tester, Finder text) {
  final rows = find
      .ancestor(of: text, matching: find.byType(Semantics))
      .evaluate()
      .map((e) => e.widget as Semantics)
      .where((w) => w.properties.selected != null);
  return rows.isNotEmpty && rows.first.properties.selected!;
}

int eventCount(WidgetTester tester, String exact) =>
    statusText(tester).split('；').where((e) => e == exact).length;

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: NavigationPage()));
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

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Hover [finder] until [done] holds（tooltip/弹层首帧约 4-5 pump——
/// known_issues.md #4）。collapsed/horizontal 的 Sub 弹层悬停/点按均可
/// 开启（标题点按对可见性惰性——见页面尾注与 docs 差异清单 30）。
Future<void> hoverUntil(
  WidgetTester tester,
  TestGesture gesture,
  Finder finder,
  bool Function() done,
) async {
  // ★瞄准行命中区（MouseRegion 祖先）而非文字中心——collapsed 行文字按
  // CSS overflow 可见语义溢出行盒外（SizedBox 截断宽 0），Flutter 命中检测
  // 不越盒（上游 DOM 会命中溢出区）。
  final aim = find
      .ancestor(of: finder, matching: find.byType(MouseRegion))
      .first;
  for (var i = 0; i < 2; i++) {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(aim));
    for (var j = 0; j < 5; j++) {
      await tester.pump(const Duration(milliseconds: 30));
      if (done()) return;
    }
  }
}

void main() {
  testWidgets('page renders every demo section and the unsupported note', (
    tester,
  ) async {
    await start(tester);
    for (final title in [
      '垂直基础',
      '收起模式',
      '水平模式',
      '受控',
      '禁用',
      'toggleIconPosition',
      'limitIndent 与 indent',
      '自定义 expandIcon',
      'Header 与 Footer',
      'numeric itemKey',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'navigation-basic',
      'navigation-collapsed',
      'navigation-horizontal',
      'navigation-controlled',
      'navigation-controlled-open',
      'navigation-controlled-collapse',
      'navigation-disabled',
      'navigation-toggle-left',
      'navigation-toggle-right',
      'navigation-limit-indent',
      'navigation-expand-icon',
      'navigation-header-footer',
      'navigation-numeric-key',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(keyed('navigation-unsupported-note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic vertical demo auto-opens selected ancestors and logs '
      'onSelect before onClick', (tester) async {
    await start(tester);
    await tester.pump(const Duration(milliseconds: 300));
    // defaultSelectedKeys 自动展开选中项祖先。
    expect(nameOf('navigation-basic', '基础子二'), findsOneWidget);
    expect(selectedFlag(tester, nameOf('navigation-basic', '基础子二')), isTrue);
    // ★选中自动附一级父 key——Sub 标题亮 selected（载荷不含父 key）。
    expect(selectedFlag(tester, nameOf('navigation-basic', '基础Sub')), isTrue);
    // 点击选中：onSelect 先、onClick 后（itemFoundation.ts:67-96）。
    await tapUntil(
      tester,
      nameOf('navigation-basic', '基础子一'),
      () => statusContaining('onClick 基础子一').evaluate().isNotEmpty,
    );
    expect(statusContaining('onSelect 基础子一'), findsOneWidget);
    final status = statusText(tester);
    expect(
      status.indexOf('onSelect 基础子一'),
      lessThan(status.indexOf('onClick 基础子一')),
    );
    expect(selectedFlag(tester, nameOf('navigation-basic', '基础子一')), isTrue);
    expect(selectedFlag(tester, nameOf('navigation-basic', '基础子二')), isFalse);
    // ★已选中再点不触发 onSelect 不移除——onClick 照发。
    await tapUntil(
      tester,
      nameOf('navigation-basic', '基础子一'),
      () => eventCount(tester, 'onClick 基础子一') == 2,
    );
    expect(eventCount(tester, 'onSelect 基础子一'), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sub title toggles the inline list with onOpenChange and '
      'onClick', (tester) async {
    await start(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(nameOf('navigation-basic', '基础子一'), findsOneWidget);
    await tapUntil(
      tester,
      nameOf('navigation-basic', '基础Sub'),
      () =>
          statusContaining('onOpenChange 基础Sub open:false')
              .evaluate()
              .isNotEmpty,
    );
    expect(nameOf('navigation-basic', '基础子一'), findsNothing);
    expect(nameOf('navigation-basic', '基础子二'), findsNothing);
    await tapUntil(
      tester,
      nameOf('navigation-basic', '基础Sub'),
      () => eventCount(tester, 'onOpenChange 基础Sub open:true') == 1,
    );
    expect(nameOf('navigation-basic', '基础子一'), findsOneWidget);
    // ★sub 路 onClick payload {itemKey, openKeys, isOpen}（与 item 路不一致）。
    expect(statusContaining('onClick 基础Sub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed mode keeps a 60px rail and wraps items in a tooltip', (
    tester,
  ) async {
    await start(tester);
    expect(tester.getSize(navIn('navigation-collapsed')).width, 60);
    // 平铺 item hover 出右侧 Tooltip（tooltip 首帧约 4-5 pump——known_issues #4）。
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    // ★locale 缺省文案只活在按钮 tooltip 里（收起态 icon-only——
    // CollapseButton.tsx:39-43），悬停按钮出「展开侧边栏」。
    await tester.ensureVisible(collapseButtonIn('navigation-collapsed'));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(
      tester.getCenter(collapseButtonIn('navigation-collapsed')),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(find.text('展开侧边栏'), findsOneWidget);
    final item = nameOf('navigation-collapsed', '收起项一');
    await tester.ensureVisible(item);
    await tester.pump(const Duration(milliseconds: 50));
    // ★瞄准行命中区（文字溢出行盒外——见 hoverUntil 注）。
    final aim = find
        .ancestor(of: item, matching: find.byType(MouseRegion))
        .first;
    await gesture.moveTo(tester.getCenter(aim));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(find.text('收起项一'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed sub hovers open the popup menu and an item tap '
      'selects and closes it', (tester) async {
    await start(tester);
    final gesture = await startMouse(tester);
    // Sub 悬停弹出层菜单（★点按打不开——touch-tap 兜底双触发 bug，见尾注）。
    await hoverUntil(
      tester,
      gesture,
      nameOf('navigation-collapsed', '收起Sub'),
      () => find.byKey(SemiNavigation.subPopupKey).evaluate().isNotEmpty,
    );
    expect(find.byKey(SemiNavigation.subPopupKey), findsOneWidget);
    expect(find.text('收起子一'), findsOneWidget);
    // ★弹层条目文字可见——收起渐隐只命中导航根子树，不得泄漏进弹层
    // （否则弹层空白只剩悬浮条变底色）。
    final fading = tester.widgetList<AnimatedOpacity>(
      find.ancestor(
        of: find.text('收起子一'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(fading, isNotEmpty);
    for (final w in fading) {
      expect(w.opacity, 1.0);
    }
    expect(statusContaining('onOpenChange 收起Sub open:true'), findsOneWidget);
    // 弹层内点条目即收起（差异清单 23）。
    await tapUntil(
      tester,
      find.text('收起子一'),
      () => statusContaining('onSelect 收起子一').evaluate().isNotEmpty,
    );
    expect(find.byKey(SemiNavigation.subPopupKey), findsNothing);
    expect(statusContaining('onOpenChange 收起Sub open:false'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed footer collapse button expands the rail to 240', (
    tester,
  ) async {
    await start(tester);
    expect(tester.getSize(navIn('navigation-collapsed')).width, 60);
    await tapUntil(
      tester,
      collapseButtonIn('navigation-collapsed'),
      () => statusContaining('onCollapseChange false').evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(navIn('navigation-collapsed')).width, 240);
    expect(nameOf('navigation-collapsed', '收起侧边栏'), findsOneWidget);
    expect(nameOf('navigation-collapsed', '展开侧边栏'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal mode is one 60px row and subs hover open popups', (
    tester,
  ) async {
    await start(tester);
    expect(tester.getSize(navIn('navigation-horizontal')).height, 60);
    // 一行排布：水平三 在 水平Sub 右侧。
    expect(
      textDx(tester, nameOf('navigation-horizontal', '水平三')) >
          textDx(tester, nameOf('navigation-horizontal', '水平Sub')),
      isTrue,
    );
    // ★Footer.tsx:64 quirk：horizontal 不渲染 collapseButton。
    expect(collapseButtonIn('navigation-horizontal'), findsNothing);
    final gesture = await startMouse(tester);
    await hoverUntil(
      tester,
      gesture,
      nameOf('navigation-horizontal', '水平Sub'),
      () => find.byKey(SemiNavigation.subPopupKey).evaluate().isNotEmpty,
    );
    expect(find.byKey(SemiNavigation.subPopupKey), findsOneWidget);
    expect(find.text('水平子一'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled selectedKeys follows buttons not taps', (
    tester,
  ) async {
    await start(tester);
    expect(
      selectedFlag(tester, nameOf('navigation-controlled', '受控甲')),
      isTrue,
    );
    // 点击只发 onSelect——受控渲染不跟随。
    await tapUntil(
      tester,
      nameOf('navigation-controlled', '受控乙'),
      () => statusContaining('onSelect 受控乙').evaluate().isNotEmpty,
    );
    expect(
      selectedFlag(tester, nameOf('navigation-controlled', '受控乙')),
      isFalse,
    );
    expect(
      selectedFlag(tester, nameOf('navigation-controlled', '受控甲')),
      isTrue,
    );
    // 按钮改 props 才换选中。
    await tapUntil(
      tester,
      find.text('选中受控乙'),
      () => selectedFlag(tester, nameOf('navigation-controlled', '受控乙')),
    );
    expect(
      selectedFlag(tester, nameOf('navigation-controlled', '受控乙')),
      isTrue,
    );
    expect(
      selectedFlag(tester, nameOf('navigation-controlled', '受控甲')),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled openKeys only changes through the buttons', (
    tester,
  ) async {
    await start(tester);
    expect(nameOf('navigation-controlled-open', '受控子一'), findsNothing);
    // Sub 点击只发 onOpenChange/onClick——★受控（vertical 未折叠）渲染不跟随。
    await tapUntil(
      tester,
      nameOf('navigation-controlled-open', '受控Sub'),
      () =>
          statusContaining('onOpenChange 受控Sub open:true')
              .evaluate()
              .isNotEmpty,
    );
    expect(nameOf('navigation-controlled-open', '受控子一'), findsNothing);
    await tapUntil(
      tester,
      find.text('打开受控Sub'),
      () => nameOf('navigation-controlled-open', '受控子一').evaluate().isNotEmpty,
    );
    expect(nameOf('navigation-controlled-open', '受控子一'), findsOneWidget);
    await tapUntil(
      tester,
      find.text('收起受控Sub'),
      () => nameOf('navigation-controlled-open', '受控子一').evaluate().isEmpty,
    );
    expect(nameOf('navigation-controlled-open', '受控子一'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled isCollapsed logs onCollapseChange and follows the '
      'handler value', (tester) async {
    await start(tester);
    expect(tester.getSize(navIn('navigation-controlled-collapse')).width, 240);
    // footer 收起按钮发 onCollapseChange（回传新值）——受控跟随 handler 改值。
    await tapUntil(
      tester,
      collapseButtonIn('navigation-controlled-collapse'),
      () => statusContaining('onCollapseChange true').evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(navIn('navigation-controlled-collapse')).width, 60);
    // 外部按钮切换 props 展开回来。
    await tapUntil(
      tester,
      find.text('切换受控折叠'),
      () => statusContaining('受控折叠 切为 false').evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(navIn('navigation-controlled-collapse')).width, 240);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled item and sub ignore taps and show the forbidden '
      'cursor', (tester) async {
    await start(tester);
    for (final text in ['禁用项', '禁用Sub']) {
      final region = tester.widget<MouseRegion>(
        find
            .ancestor(
              of: nameOf('navigation-disabled', text),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(region.cursor, SystemMouseCursors.forbidden);
    }
    // 点击/键盘均不响应——事件全不发。
    await tapOnce(tester, nameOf('navigation-disabled', '禁用项'));
    expect(statusContaining('onSelect 禁用项'), findsNothing);
    expect(statusContaining('onClick 禁用项'), findsNothing);
    await tapOnce(tester, nameOf('navigation-disabled', '禁用Sub'));
    expect(statusContaining('onOpenChange 禁用Sub'), findsNothing);
    expect(nameOf('navigation-disabled', '禁用子一'), findsNothing);
    // 正常条目回传对照。
    await tapUntil(
      tester,
      nameOf('navigation-disabled', '正常项'),
      () => statusContaining('onSelect 正常项').evaluate().isNotEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggleIconPosition moves the expand icon left of the title', (
    tester,
  ) async {
    await start(tester);
    double iconDx(String demoKey) => tester.getCenter(iconsIn(demoKey)).dx;
    // left：展开图标在标题前。
    expect(
      iconDx('navigation-toggle-left') <
          tester.getCenter(nameOf('navigation-toggle-left', '左置Sub')).dx,
      isTrue,
    );
    // right（缺省）：展开图标在标题后。
    expect(
      iconDx('navigation-toggle-right') >
          tester.getCenter(nameOf('navigation-toggle-right', '右置Sub')).dx,
      isTrue,
    );
    // ★left 空 toggle 槽 quirk：普通条目 toggleIcon 为 null 仍占一槽（文本右移）。
    expect(
      textDx(tester, nameOf('navigation-toggle-left', '左置项')) >
          textDx(tester, nameOf('navigation-toggle-right', '右置项')),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('limitIndent false counts indent placeholders per item', (
    tester,
  ) async {
    await start(tester);
    await tester.pump(const Duration(milliseconds: 300));
    // icon && !indent ? level : level-1（Item.tsx:213-215）：indent: true 少一槽。
    double dxF(String text) =>
        textDx(tester, nameOf('navigation-limit-indent', text));
    expect(dxF('手动甲') < dxF('手动乙'), isTrue);
    // ★indent: 0 falsy quirk——同「无 indent」。
    expect(dxF('手动丙'), moreOrLessEquals(dxF('手动乙'), epsilon: 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expandIcon replaces the default chevron', (tester) async {
    await start(tester);
    final icons = iconsIn('navigation-expand-icon');
    expect(icons, findsOneWidget);
    expect(tester.widget<SemiIcon>(icons).data, SemiIcons.chevronRight);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header and footer render logo, text and the collapse button', (
    tester,
  ) async {
    await start(tester);
    expect(nameOf('navigation-header-footer', 'Semi Design'), findsOneWidget);
    // logo + 收起按钮 sidebar 图标。
    expect(
      tester
          .widgetList<SemiIcon>(iconsIn('navigation-header-footer'))
          .map((icon) => icon.data),
      containsAll(<SemiIconData>[SemiIcons.semiLogo, SemiIcons.sidebar]),
    );
    // collapseText 固定串（上游函数形态收敛 String）。
    expect(find.text('收起导航'), findsOneWidget);
    await tapUntil(
      tester,
      collapseButtonIn('navigation-header-footer'),
      () => statusContaining('onCollapseChange true').evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(navIn('navigation-header-footer')).width, 60);
    // ★收起态 icon-only（CollapseButton.tsx:39-43）——固定串不随折叠态切换，
    // 只活在按钮 tooltip 里；悬停按钮出「收起导航」。
    expect(find.text('收起导航'), findsNothing);
    final g = await startMouse(tester);
    await tester.ensureVisible(collapseButtonIn('navigation-header-footer'));
    await tester.pump(const Duration(milliseconds: 50));
    await g.moveTo(
      tester.getCenter(collapseButtonIn('navigation-header-footer')),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(find.text('收起导航'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('numeric itemKey zero is a legal selectable key', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      nameOf('navigation-numeric-key', '零键条目'),
      () => statusContaining('onSelect 0').evaluate().isNotEmpty,
    );
    expect(statusContaining('onSelect 0'), findsOneWidget);
    expect(
      selectedFlag(tester, nameOf('navigation-numeric-key', '零键条目')),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
