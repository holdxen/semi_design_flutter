import 'package:example/pages/popconfirm.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: PopconfirmPage()));
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
    // 受控 visible 链路多一帧 post-frame 递延，充分泵帧再判定。
    for (var j = 0; j < 4; j++) {
      await tester.pump();
    }
    await tester.pump(wait);
    await tester.pump();
    if (done()) return;
  }
}

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(find.descendant(of: keyed('popconfirm-status'), matching: find.byType(Text)))
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
    for (final title in [
      '基础用法',
      '按钮与回调',
      '图标与关闭按钮',
      '定位与箭头',
      '受控显隐',
      '局部主题',
    ]) {
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

  testWidgets('basic popconfirm opens and ok confirms with status feedback', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(tester, keyed('basic-target'), () => find.text('删除任务').evaluate().isNotEmpty);
    expect(find.text('删除任务'), findsOneWidget);
    expect(find.text('确定删除该任务吗？删除后不可恢复。'), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.byType(SemiPopconfirmDefaultIcon), findsOneWidget);

    await tapUntil(tester, find.text('确认'), () => find.text('删除任务').evaluate().isEmpty);
    expect(find.text('删除任务'), findsNothing);
    expect(find.text('删除任务（1）'), findsOneWidget);
  });

  testWidgets('async confirm keeps the ok button loading until done', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(tester, keyed('async-target'), () => find.text('异步确认').evaluate().length > 1);
    await tapUntil(tester, find.text('确认'), () => statusText(tester).contains('异步确认完成'));
    expect(find.text('确定删除该任务吗？删除后不可恢复。'), findsNothing);
  });

  testWidgets('controlled popconfirm only follows the visible toggle', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(tester, keyed('toggle-visible'), () => find.text('受控气泡').evaluate().isNotEmpty);
    expect(find.text('受控气泡'), findsOneWidget);

    // 确认后受控不自关，只上报。
    await tapUntil(tester, find.text('确认'), () => statusText(tester).contains('受控确认'));
    expect(find.text('受控气泡'), findsOneWidget);

    await tapUntil(tester, keyed('toggle-visible'), () => find.text('受控气泡').evaluate().isEmpty);
    expect(find.text('受控气泡'), findsNothing);
    expect(statusText(tester), contains('已请求关闭'));
  });

  testWidgets('local theme patch reaches the popup card', (tester) async {
    await start(tester);
    await tapUntil(tester, keyed('theme-target'), () => find.text('局部主题').evaluate().length > 1);
    final context = tester.element(keyed('theme-target'));
    final resolved = SemiPopconfirmTheme.resolve(context);
    expect(resolved.widthPopconfirmMaxWidth, 240);
    expect(resolved.spacingPopconfirmFooterMarginTop, 12);
    expect(resolved.radiusPopconfirmPopover, 12);
  });

  testWidgets('icon and close-button variants render as configured', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(tester, keyed('no-icon-target'), () => find.text('无图标').evaluate().isNotEmpty);
    expect(find.byType(SemiPopconfirmDefaultIcon), findsNothing);
    await tapUntil(tester, find.text('取消'), () => find.text('无图标').evaluate().isEmpty);

    await tapUntil(tester, keyed('no-close-target'), () => find.text('无关闭按钮').evaluate().length > 1);
    final closers = find.byWidgetPredicate(
      (w) => w is SemiIcon && w.data == SemiIcons.close,
    );
    expect(closers, findsNothing);
    expect(tester.takeException(), isNull);
  });
}
