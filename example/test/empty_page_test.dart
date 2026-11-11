import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiEmpty empty(WidgetTester tester, String key) =>
    tester.widget<SemiEmpty>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
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
    for (final title in [
      '基础用法',
      '布局方向',
      '标题排版',
      '插图风格',
      '暗色主题',
      '自定义内容与局部主题',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-empty'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-empty').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic and horizontal layouts expose expected props', (
    tester,
  ) async {
    await start(tester);
    final basic = empty(tester, 'basic-empty');
    expect(basic.layout, SemiEmptyLayout.vertical);
    expect(basic.image, isA<SemiIllustration>());
    expect(basic.title, '暂无内容');
    expect(basic.description, '换个关键词试试');
    final horizontal = empty(tester, 'horizontal-empty');
    expect(horizontal.layout, SemiEmptyLayout.horizontal);
    expect(horizontal.title, '没有找到结果');
    expect(find.text('暂无内容'), findsOneWidget);
    expect(find.text('没有找到结果'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('title typography switches between with and without image', (
    tester,
  ) async {
    await start(tester);
    final withImage = tester.widget<SemiTitle>(
      find.descendant(
        of: keyed('title-with-image'),
        matching: find.byType(SemiTitle),
      ),
    );
    expect(withImage.heading, 4);
    expect(withImage.weight, FontWeight.w600);
    final withoutImage = tester.widget<SemiTitle>(
      find.descendant(
        of: keyed('title-without-image'),
        matching: find.byType(SemiTitle),
      ),
    );
    expect(withoutImage.heading, 6);
    expect(withoutImage.weight, FontWeight.w400);
    expect(tester.takeException(), isNull);
  });

  testWidgets('illustration grid renders all eight styles', (tester) async {
    await start(tester);
    for (final label in [
      '无内容',
      '无结果',
      '未找到',
      '加载失败',
      '无权限',
      '建设中',
      '空闲',
      '成功',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      tester.widgetList<SemiIllustration>(find.byType(SemiIllustration)).length,
      14,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark section resolves dark theme with darkModeImage', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('dark-empty'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(SemiTheme.of(tester.element(keyed('dark-empty'))).dark, isTrue);
    final illustration = tester.widget<SemiIllustration>(
      find.descendant(
        of: keyed('dark-empty'),
        matching: find.byType(SemiIllustration),
      ),
    );
    expect(illustration.dark, isNotNull);
    expect(find.text('暗色占位'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('footer links and local theme values apply', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-empty'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('reload-link').hitTestable(), findsOneWidget);
    expect(find.text('查看详情'), findsOneWidget);
    expect(find.text('请检查网络后重试'), findsOneWidget);
    final theme = SemiEmptyTheme.resolve(tester.element(keyed('theme-empty')));
    expect(theme.spacingEmptyContentVerticalMarginTop, 8);
    expect(theme.spacingEmptyTitleMarginTop, 4);
    expect(theme.spacingEmptyFooterMarginTop, 8);
    expect(theme.fontEmptyTitleFontWeight, FontWeight.w400);
    expect(theme.colorEmptyDescriptionTextDefault, const Color(0xff7b61ff));
    expect(tester.takeException(), isNull);
  });
}
