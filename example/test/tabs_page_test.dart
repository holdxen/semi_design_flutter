import 'package:example/pages/tabs.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder inDemo(String key, Finder matching) =>
    find.descendant(of: keyed(key), matching: matching);

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: keyed('tabs-status'), matching: find.byType(Text)),
    )
    .map((t) => t.data ?? '')
    .join();

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 3000));
  await tester.pumpWidget(const SemiApp(home: TabsPage()));
  await tester.pump(const Duration(milliseconds: 60));
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 30));
  }
}

void main() {
  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in [
      '线条（line）',
      '卡片（card）',
      '按钮（button）',
      '斜线（slash）',
      '滚动折叠（collapsible）',
      '更多下拉（more）',
      'RTL 与动效',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);
    }
    expect(keyed('tabs-line'), findsOneWidget);
    expect(keyed('tabs-card-top'), findsOneWidget);
    expect(keyed('tabs-card-left'), findsOneWidget);
    expect(keyed('tabs-button'), findsOneWidget);
    expect(keyed('tabs-slash'), findsOneWidget);
  });

  testWidgets('clicking a line tab switches the pane and logs onChange', (
    tester,
  ) async {
    await start(tester);
    expect(inDemo('tabs-line', find.text('文档内容：线形态页签的基础信息。')), findsOneWidget);
    await tester.tap(inDemo('tabs-line', find.text('快速入门')));
    await tester.pump();
    expect(statusText(tester), contains('line onChange=2'));
    expect(statusText(tester), contains('line onTabClick=2'));
    expect(inDemo('tabs-line', find.text('快速入门内容：安装与初始化。')), findsOneWidget);
  });

  testWidgets('closable tab reports onTabClose without switching', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('tabs-closable'));
    await tester.pump(const Duration(milliseconds: 60));
    final close = inDemo(
      'tabs-closable',
      find.byWidgetPredicate(
        (widget) => widget is SemiIcon && widget.data == SemiIcons.close,
      ),
    );
    expect(close, findsNWidgets(2));
    await tester.tap(close.first);
    await tester.pump();
    expect(statusText(tester), contains('line onTabClose=a'));
    expect(inDemo('tabs-closable', find.text('A 的内容')), findsOneWidget);
  });

  testWidgets('more dropdown exposes the remaining tabs', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('tabs-more'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(inDemo('tabs-more', find.text('更多 1')), findsOneWidget);
    expect(inDemo('tabs-more', find.text('更多 2')), findsOneWidget);
    expect(find.text('更多 8'), findsNothing);

    final trigger = inDemo('tabs-more', find.text('更多'));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(trigger));
    await settle(tester);
    expect(find.text('更多 8'), findsOneWidget);
    await tester.tap(find.text('更多 8'));
    await tester.pump();
    expect(statusText(tester), contains('more onChange=更多-8'));
    expect(find.text('更多 内容 8'), findsOneWidget);
  });

  testWidgets('collapsible bar shows scrolling arrows', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('tabs-collapsible'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      inDemo(
        'tabs-collapsible',
        find.byWidgetPredicate(
          (widget) =>
              widget is SemiIcon &&
              (widget.data == SemiIcons.chevronLeft ||
                  widget.data == SemiIcons.chevronRight),
        ),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('RTL demo renders mirrored tabs', (tester) async {
    await start(tester);
    final rtl = keyed('tabs-rtl');
    await tester.ensureVisible(rtl);
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      Directionality.of(tester.element(inDemo('tabs-rtl', find.text('文档')))),
      TextDirection.rtl,
    );
    expect(
      Directionality.of(tester.element(inDemo('tabs-line', find.text('文档')))),
      TextDirection.ltr,
    );
  });
}
