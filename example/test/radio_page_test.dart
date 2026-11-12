import 'package:example/pages/radio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder checkedIcon = find.byWidgetPredicate(
  (w) => w is SemiIcon && w.data == SemiIcons.radio,
);

int checkedCount(WidgetTester tester, String key) =>
    find.descendant(of: keyed(key), matching: checkedIcon).evaluate().length;

SemiRadioGroup group(WidgetTester tester, String key) =>
    tester.widget<SemiRadioGroup>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: RadioPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  // See docs/known_issues.md #1: a neutral tap absorbs the one dropped hit
  // test that can follow focus-driven rebuilds at a scroll viewport edge.
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
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
      '基本用法',
      '带辅助文本',
      '禁用',
      '高级模式',
      '单选组合',
      '垂直排列',
      '按钮样式',
      '卡片样式',
      '无 radio 的纯卡片样式',
      '配置 options',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('standalone radio toggles and reports both directions', (
    tester,
  ) async {
    await start(tester);
    expect(checkedCount(tester, 'radio-basic'), 1);
    await tap(tester, find.text('单选框'));
    expect(find.text('基本用法：checked=false'), findsOneWidget);
    expect(checkedCount(tester, 'radio-basic'), 0);
    await tap(tester, find.text('单选框'));
    expect(find.text('基本用法：checked=true'), findsOneWidget);
    expect(checkedCount(tester, 'radio-basic'), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('group keeps one selection and stays silent on re-click', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('radio-group'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(checkedCount(tester, 'radio-group'), 1);
    await tap(
      tester,
      find.descendant(of: keyed('radio-group'), matching: find.text('定时推送')),
    );
    expect(find.text('组合选中：2'), findsOneWidget);
    expect(checkedCount(tester, 'radio-group'), 1);
    // Re-clicking the selected member notifies nothing.
    await tap(
      tester,
      find.descendant(of: keyed('radio-group'), matching: find.text('定时推送')),
    );
    expect(find.text('组合选中：2'), findsOneWidget);
    // The group is controlled: display follows the parent-held value.
    expect(group(tester, 'radio-group').value, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('advanced mode allows deselecting', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('radio-advanced'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(checkedCount(tester, 'radio-advanced'), 1);
    await tap(tester, find.text('允许取消选择'));
    expect(find.text('高级模式：checked=false'), findsOneWidget);
    expect(checkedCount(tester, 'radio-advanced'), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arrow keys move the group selection', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('radio-group'));
    await tester.pump(const Duration(milliseconds: 50));
    // Value 1 starts selected (clicking it would be silent by contract) —
    // select 2 first, then arrow right/down through the wrap-around.
    await tap(
      tester,
      find.descendant(of: keyed('radio-group'), matching: find.text('定时推送')),
    );
    expect(find.text('组合选中：2'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('组合选中：3'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('组合选中：1'), findsOneWidget);
    expect(checkedCount(tester, 'radio-group'), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('button sizes, cards and options match the demos', (
    tester,
  ) async {
    await start(tester);
    expect(
      group(tester, 'radio-button-small').buttonSize,
      SemiRadioButtonSize.small,
    );
    expect(
      group(tester, 'radio-button-middle').buttonSize,
      SemiRadioButtonSize.middle,
    );
    expect(
      group(tester, 'radio-button-large').buttonSize,
      SemiRadioButtonSize.large,
    );
    expect(group(tester, 'radio-button-small').type, SemiRadioType.button);
    expect(group(tester, 'radio-card').type, SemiRadioType.card);
    expect(group(tester, 'radio-pure-card').type, SemiRadioType.pureCard);
    expect(
      group(tester, 'radio-vertical').direction,
      SemiRadioDirection.vertical,
    );
    // options 渲染含禁用项；禁用项不可选中。
    expect(
      find.descendant(of: keyed('radio-options'), matching: find.text('选项 A')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('radio-options'),
        matching: find.text('选项 C（禁用）'),
      ),
      findsOneWidget,
    );
    await tap(
      tester,
      find.descendant(
        of: keyed('radio-options'),
        matching: find.text('选项 C（禁用）'),
      ),
    );
    expect(checkedCount(tester, 'radio-options'), 1);
    await tap(
      tester,
      find.descendant(of: keyed('radio-options'), matching: find.text('选项 A')),
    );
    expect(checkedCount(tester, 'radio-options'), 1);
    expect(tester.takeException(), isNull);
  });
}
