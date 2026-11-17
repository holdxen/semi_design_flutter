import 'package:example/pages/float_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('floatbutton-status'),
  matching: find.textContaining(text),
);

/// 演示盒里的悬浮按钮主体（SemiFloatButton.bodyKey 是度量锚点）。
Finder bodyOf(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiFloatButton.bodyKey),
);

Finder itemOf(String demoKey, int index) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiFloatButtonGroup.itemKey(index)),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: FloatButtonPage()));
  await tester.pumpAndSettle();
}

/// Tap [finder] until [done] holds. The one-shot retry absorbs the dropped hit
/// of docs/known_issues.md #1 without double-firing non-idempotent actions:
/// [done] is checked after each tap (backtop_page_test 同口径).
Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 120),
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
  testWidgets('page renders every demo section and survives a narrow scaled '
      'screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in ['基本用法', '尺寸与形状', '多彩与徽章', '悬浮按钮组', '禁用', 'RTL']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(keyed('floatbutton-status'), findsOneWidget);
  });

  testWidgets('basic demo: tap fires onClick and records the event', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      bodyOf('floatbutton-basic'),
      () => statusContaining('onClick 基本用法').evaluate().isNotEmpty,
    );
    expect(statusContaining('onClick 基本用法'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('size/shape demo: three sizes render 24/32/40 boxes', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('floatbutton-size-shape'));
    await tester.pump(const Duration(milliseconds: 50));
    final sizes = <double>[];
    for (var i = 0; i < 3; i++) {
      sizes.add(tester.getSize(bodyOf('floatbutton-size-shape').at(i)).width);
    }
    expect(sizes, containsAll(<double>[24, 32, 40]));
    expect(tester.takeException(), isNull);
  });

  testWidgets('group demo: item callback precedes the group callback; '
      'stopPropagation cuts the group (itemProps.test.jsx 口径)', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      itemOf('floatbutton-group', 0),
      () =>
          statusContaining('group onClick value=editor').evaluate().isNotEmpty,
    );
    // 子项回调先于组回调——日志顺序。
    expect(statusContaining('item editor'), findsOneWidget);
    final events = tester.widget<SemiText>(keyed('floatbutton-status')).data;
    expect(
      events.indexOf('item editor'),
      lessThan(events.indexOf('group onClick value=editor')),
    );

    // help 子项回调内 stopPropagation——组回调不达。
    await tapUntil(
      tester,
      itemOf('floatbutton-group', 2),
      () => statusContaining('item help').evaluate().isNotEmpty,
    );
    expect(statusContaining('item help'), findsOneWidget);
    expect(
      tester.widget<SemiText>(keyed('floatbutton-status')).data,
      isNot(contains('group onClick value=help')),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled demo: neither the button nor the group fires', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(bodyOf('floatbutton-disabled'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(bodyOf('floatbutton-disabled'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(itemOf('floatbutton-disabled', 0), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 120));
    expect(statusContaining('禁用不应达'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('badge demo: dot/count badges ride the rounded corner', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('floatbutton-colorful-badge'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.descendant(
        of: keyed('floatbutton-colorful-badge'),
        matching: find.byType(SemiBadge),
      ),
      findsNWidgets(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('rtl demo: button lands bottom-left of the demo box', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('floatbutton-rtl'));
    await tester.pump(const Duration(milliseconds: 50));
    final stack = tester.getRect(keyed('floatbutton-rtl'));
    final rect = tester.getRect(bodyOf('floatbutton-rtl'));
    // PositionedDirectional end 翻边 → 距左 24（spacingFloatButtonRight）。
    expect(rect.left, stack.left + 24);
    expect(tester.takeException(), isNull);
  });

  // 官方 stories 搬用冒烟（floatButton.stories.jsx）：4 个 story 渲染 +
  // Single 矩阵恰 45 枚按钮（9 列 × 5 行）。
  testWidgets('official stories demos render (Single/ HrefTarget / Group*)', (
    tester,
  ) async {
    await start(tester);
    expect(keyed('floatbutton-official-single'), findsOneWidget);
    expect(keyed('floatbutton-official-href'), findsOneWidget);
    expect(keyed('floatbutton-official-group-normal'), findsOneWidget);
    expect(keyed('floatbutton-official-group-click'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('floatbutton-official-single'),
        matching: find.byKey(SemiFloatButton.bodyKey),
      ),
      findsNWidgets(45),
    );
    expect(tester.takeException(), isNull);
  });

  // dark 模式回归：`--semi-shadow-elevated` 首层为 `inset 0 0 0 1px`，
  // 渲染仅转换 drop 层（docs/semi_float_button.md 差异清单 18）——
  // 曾直调 `toBoxShadows()` 抛 UnsupportedError（unsupported operation）。
  testWidgets('dark mode: page renders without inset shadow errors', (
    tester,
  ) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(
      const SemiApp(themeMode: SemiThemeMode.dark, home: FloatButtonPage()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(bodyOf('floatbutton-basic'), findsOneWidget);
    // 页面 6 个组演示：悬浮按钮组 / 禁用 / 官方 GroupNormal×3 / GroupItemClick。
    expect(find.byKey(SemiFloatButtonGroup.groupKey), findsNWidgets(6));
  });
}
