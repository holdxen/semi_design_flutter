import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('example shell is a SemiNavigation base with official icons', (
    tester,
  ) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    // 基座 + 官方分组/标题。
    expect(find.byType(SemiNavigation), findsOneWidget);
    expect(find.text('基础'), findsOneWidget);
    expect(find.text('Button 按钮'), findsOneWidget);
    // 官方侧栏图标（doc-*.svg）与 Semi logo。
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SemiIcon && w.assetName == 'assets/doc_icons/doc-button.svg',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is SemiIcon && w.assetName == 'assets/semi-logo.svg',
      ),
      findsOneWidget,
    );
    final context = tester.element(find.byType(SemiNavigation));
    expect(Directionality.of(context), TextDirection.ltr);
    expect(SemiTheme.of(context).dark, isFalse);
    // 初始页 = 首个条目（Button）。
    expect(find.text('点击按钮查看交互。'), findsOneWidget);
  });

  testWidgets('nav selection switches the demo page', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Tabs 标签栏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('tabs-status')), findsOneWidget);
    expect(find.text('点击按钮查看交互。'), findsNothing);
  });

  testWidgets('sidebar search box filters the component list', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 50));
    final search = find.descendant(
      of: find.byKey(const ValueKey('demo-search')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(search, 'Tabs');
    await tester.pump();
    expect(find.text('Tabs 标签栏'), findsOneWidget);
    expect(find.text('Button 按钮'), findsNothing);
    // 无命中时给禁用占位条目。
    await tester.enterText(search, 'zzz-无此组件');
    await tester.pump();
    expect(find.text('无匹配组件'), findsOneWidget);
    expect(find.text('Tabs 标签栏'), findsNothing);
    // 清空恢复全量。
    await tester.enterText(search, '');
    await tester.pump();
    expect(find.text('Button 按钮'), findsOneWidget);
    expect(find.text('Tabs 标签栏'), findsOneWidget);
  });

  testWidgets('theme switch toggles light/dark', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 50));
    final navContext = tester.element(find.byType(SemiNavigation));
    expect(SemiTheme.of(navContext).dark, isFalse);
    await tester.tap(find.byType(SemiSwitch));
    await tester.pump();
    expect(SemiTheme.of(navContext).dark, isTrue);
    await tester.tap(find.byType(SemiSwitch));
    await tester.pump();
    expect(SemiTheme.of(navContext).dark, isFalse);
  });
}
