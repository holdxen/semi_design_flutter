import 'package:example/pages/descriptions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiDescriptions descriptions(WidgetTester tester, String key) =>
    tester.widget<SemiDescriptions>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: DescriptionsPage()));
  await tester.pump(const Duration(milliseconds: 50));
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
    for (final title in ['基础用法', '对齐方式', '水平布局', '双行模式', '自定义项', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-descriptions'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-descriptions').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic and align demos expose expected configuration', (
    tester,
  ) async {
    await start(tester);
    final basic = descriptions(tester, 'basic-descriptions');
    expect(basic.items, hasLength(5));
    expect(basic.layout, SemiDescriptionsLayout.vertical);
    expect(basic.semanticsLabel, '用户资料');
    for (final align in SemiDescriptionsAlign.values) {
      expect(descriptions(tester, 'align-${align.name}').align, align);
      expect(find.text(align.name), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal groups by column and span', (tester) async {
    await start(tester);
    final horizontal = descriptions(tester, 'horizontal-descriptions');
    expect(horizontal.layout, SemiDescriptionsLayout.horizontal);
    expect(horizontal.column, 3);
    expect(horizontal.items, hasLength(5));
    expect(
      horizontal.items
          .where((item) => item.span == 2)
          .map((item) => item.label),
      ['描述'],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('row mode renders all three sizes', (tester) async {
    await start(tester);
    for (final size in SemiDescriptionsSize.values) {
      final demo = descriptions(tester, 'row-${size.name}');
      expect(demo.row, isTrue);
      expect(demo.size, size);
      expect(demo.items, hasLength(3));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom items apply style lazy value and hide hidden', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('custom-descriptions'));
    await tester.pump(const Duration(milliseconds: 100));
    final custom = descriptions(tester, 'custom-descriptions');
    expect(custom.items[0].keyStyle, const TextStyle(color: Color(0xff7b61ff)));
    expect(custom.items[0].keyWidth, 96);
    expect(custom.items[1].value, isA<SemiText>());
    expect(custom.items[2].valueBuilder, isNotNull);
    expect(custom.items[3].hidden, isTrue);
    expect(find.text('自定义样式'), findsOneWidget);
    expect(find.text('渲染时才构建'), findsOneWidget);
    expect(find.text('隐藏项'), findsNothing);
    expect(find.text('不渲染也不进语义'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme descriptions', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-descriptions'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiDescriptionsTheme.resolve(
      tester.element(keyed('theme-descriptions')),
    );
    expect(theme.colorDescriptionsKeyTextDefault, const Color(0xff7b61ff));
    expect(theme.colorDescriptionsValueTextDefault, const Color(0xff0a7a2f));
    expect(theme.fontDescriptionsValueFontWeight, FontWeight.w800);
    expect(theme.spacingDescriptionsThPaddingRight, 40);
    expect(tester.takeException(), isNull);
  });
}
