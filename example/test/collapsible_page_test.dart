import 'package:example/pages/collapsible.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

/// Scoped text finder — sections share the same line fixtures.
Finder textIn(String key, String text) =>
    find.descendant(of: keyed(key), matching: find.text(text));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: CollapsiblePage()));
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

double heightOf(WidgetTester tester, String key) =>
    tester.getSize(keyed(key)).height;

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
    for (final title in [
      '基本用法',
      '自定义动画时间',
      '嵌套使用',
      '自定义折叠高度',
      '生命周期与淡入淡出',
      '局部主题',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-collapsible'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic toggle expands and collapses the content', (tester) async {
    await start(tester);
    expect(heightOf(tester, 'basic-collapsible'), 0);
    expect(textIn('basic-collapsible', 'Semi Design 以内容优先进行设计。'), findsNothing);

    await tap(tester, keyed('toggle-basic'));
    expect(heightOf(tester, 'basic-collapsible'), greaterThan(0));
    expect(textIn('basic-collapsible', '更容易地自定义主题。'), findsOneWidget);

    await tap(tester, keyed('toggle-basic'));
    expect(heightOf(tester, 'basic-collapsible'), 0);
    expect(textIn('basic-collapsible', '更容易地自定义主题。'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested collapsibles toggle independently', (tester) async {
    await start(tester);
    await tap(tester, keyed('toggle-outer'));
    expect(heightOf(tester, 'outer-collapsible'), greaterThan(0));
    expect(find.text('Semi Design 的设计原则包括：'), findsOneWidget);

    await tap(tester, keyed('toggle-inner'));
    expect(heightOf(tester, 'inner-collapsible'), greaterThan(0));
    // 内层展开后外层高度跟随内容增长（无陈旧缓存高）。
    expect(heightOf(tester, 'outer-collapsible'), greaterThan(100));
    expect(textIn('inner-collapsible', '适用国际化场景。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapseHeight keeps a 60px preview and show-more expands', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('preview-collapsible'));
    await tester.pump(const Duration(milliseconds: 100));
    // 收起态保留 60px 预览（内容恒构建）。
    expect(heightOf(tester, 'preview-collapsible'), 60);
    expect(
      textIn('preview-collapsible', 'Semi Design 以内容优先进行设计。'),
      findsOneWidget,
    );

    await tap(tester, keyed('show-more'));
    expect(heightOf(tester, 'preview-collapsible'), greaterThan(60));
    expect(keyed('show-more'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lifecycle and fade sections expose their configuration', (
    tester,
  ) async {
    await start(tester);
    final life = tester.widget<SemiCollapsible>(keyed('life-collapsible'));
    expect(life.keepDOM, isTrue);
    expect(life.lazyRender, isTrue);
    expect(life.fade, isTrue);
    final fade = tester.widget<SemiCollapsible>(keyed('fade-collapsible'));
    expect(fade.fade, isTrue);
    // lazyRender: true — 首次展开前内容不构建。
    expect(textIn('life-collapsible', '适用国际化场景。'), findsNothing);
    await tap(tester, keyed('toggle-life'));
    expect(textIn('life-collapsible', '适用国际化场景。'), findsOneWidget);
    await tap(tester, keyed('toggle-life'));
    // keepDOM: true — 收起后仍保持构建（高度裁 0）。
    expect(textIn('life-collapsible', '适用国际化场景。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duration and motion knobs reach the collapsible', (
    tester,
  ) async {
    await start(tester);
    final duration = tester.widget<SemiCollapsible>(
      keyed('duration-collapsible'),
    );
    expect(duration.duration, const Duration(milliseconds: 250));
    expect(duration.motion, isTrue);
    await tester.ensureVisible(keyed('toggle-motion'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(keyed('toggle-motion'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      tester.widget<SemiCollapsible>(keyed('duration-collapsible')).motion,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme collapsible', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-collapsible'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiCollapsibleTheme.resolve(
      tester.element(keyed('theme-collapsible')),
    );
    expect(
      theme.transitionDurationCollapsibleHeight,
      const Duration(milliseconds: 800),
    );
    expect(theme.transitionFunctionCollapsibleOpacity, Curves.linear);
    expect(tester.takeException(), isNull);
  });
}
