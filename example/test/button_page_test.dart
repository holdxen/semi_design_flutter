import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiButton button(WidgetTester tester, String label) =>
    tester.widget<SemiButton>(find.widgetWithText(SemiButton, label).first);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
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
      '类型',
      '变体',
      '尺寸与块级',
      '图标',
      '状态',
      'AI 彩色',
      '按钮组合',
      '局部主题',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(find.text('主题按钮'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('types variants and sizes expose their configuration', (
    tester,
  ) async {
    await start(tester);
    expect(button(tester, '主要').type, SemiButtonType.primary);
    expect(button(tester, '次要').type, SemiButtonType.secondary);
    expect(button(tester, '辅助').type, SemiButtonType.tertiary);
    expect(button(tester, '警告').type, SemiButtonType.warning);
    expect(button(tester, '危险').type, SemiButtonType.danger);

    expect(button(tester, 'small').size, SemiButtonSize.small);
    expect(button(tester, 'normal').size, SemiButtonSize.normal);
    expect(button(tester, 'large').size, SemiButtonSize.large);
    expect(button(tester, 'block 占满整行').block, isTrue);

    final icons = button(tester, '左侧图标');
    expect(icons.icon, isA<SemiIcon>());
    expect(icons.iconPosition, SemiButtonIconPosition.left);
    expect(button(tester, '右侧图标').iconPosition, SemiButtonIconPosition.right);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading toggles across buttons and intercepts taps', (
    tester,
  ) async {
    await start(tester);
    expect(button(tester, '可点击').loading, isFalse);
    await tap(tester, keyed('toggle-loading'));
    expect(button(tester, '可点击').loading, isTrue);
    expect(button(tester, '带图标').loading, isTrue);
    expect(find.text('停止 loading'), findsOneWidget);

    // Loading intercepts pointer taps.
    await tap(tester, find.widgetWithText(SemiButton, '可点击'));
    expect(find.textContaining('点击了「可点击」'), findsNothing);

    await tap(tester, keyed('toggle-loading'));
    await tap(tester, find.widgetWithText(SemiButton, '可点击'));
    expect(find.textContaining('点击了「可点击」'), findsOneWidget);
    expect(button(tester, '禁用').disabled, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('colorful group and local theme sections render', (tester) async {
    await start(tester);
    final colorful = tester
        .widgetList<SemiButton>(find.byType(SemiButton))
        .where((b) => b.colorful == true)
        .toList();
    expect(colorful, hasLength(8));
    expect(colorful.map((b) => b.type).toSet(), {
      SemiButtonType.primary,
      SemiButtonType.tertiary,
    });

    final groups = tester.widgetList<SemiButtonGroup>(
      find.byType(SemiButtonGroup),
    );
    expect(groups, hasLength(2));

    final splits = tester.widgetList<SemiSplitButtonGroup>(
      find.byType(SemiSplitButtonGroup),
    );
    expect(splits, hasLength(2));
    expect(find.text('主要操作'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);

    await tester.ensureVisible(find.text('主题按钮'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiButtonTheme.resolve(tester.element(find.text('主题按钮')));
    expect(theme.radiusButton, 12);
    expect(theme.colorButtonPrimaryBgDefault, const Color(0xff7b61ff));
    expect(tester.takeException(), isNull);
  });
}
