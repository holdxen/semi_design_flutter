import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiCheckbox checkbox(WidgetTester tester, String key) =>
    tester.widget<SemiCheckbox>(keyed(key));

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
    for (final title in ['基础用法', '卡片变体', '受控模式', '分组', '事件与禁用切换', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(find.text('主题卡片'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic states render checked indeterminate and disabled', (
    tester,
  ) async {
    await start(tester);
    final boxes = tester.widgetList<SemiCheckbox>(find.byType(SemiCheckbox));
    expect(boxes.length, greaterThanOrEqualTo(5));
    expect(find.text('未选中'), findsOneWidget);
    expect(find.text('已选中'), findsOneWidget);
    expect(find.text('半选（indeterminate）'), findsOneWidget);
    expect(find.text('禁用'), findsOneWidget);
    expect(find.text('禁用选中'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card variants render with extra content', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('card 未选'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('card 未选'), findsOneWidget);
    expect(find.text('带副标题的卡片选项'), findsOneWidget);
    expect(find.text('card 选中'), findsOneWidget);
    expect(find.text('pureCard'), findsOneWidget);
    final card = tester.widget<SemiCheckbox>(
      find
          .ancestor(
            of: find.text('card 选中'),
            matching: find.byType(SemiCheckbox),
          )
          .first,
    );
    expect(card.type, SemiCheckboxType.card);
    expect(card.checked, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled checkbox toggles through the parent state', (
    tester,
  ) async {
    await start(tester);
    expect(checkbox(tester, 'controlled-checkbox').checked, isTrue);
    await tap(tester, keyed('controlled-checkbox'));
    expect(checkbox(tester, 'controlled-checkbox').checked, isFalse);
    expect(find.textContaining('受控切换为：未选中'), findsOneWidget);
    await tap(tester, keyed('controlled-checkbox'));
    expect(checkbox(tester, 'controlled-checkbox').checked, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('group select-all computes indeterminate and updates options', (
    tester,
  ) async {
    await start(tester);
    final group = tester.widget<SemiCheckboxGroup>(keyed('option-group'));
    expect(group.value, ['a', 'b']);
    final all = checkbox(tester, 'select-all');
    expect(all.checked, isFalse);
    expect(all.indeterminate, isTrue); // 2/3 selected

    await tap(tester, keyed('select-all'));
    expect(tester.widget<SemiCheckboxGroup>(keyed('option-group')).value, [
      'a',
      'b',
      'c',
    ]);
    expect(checkbox(tester, 'select-all').checked, isTrue);
    expect(checkbox(tester, 'select-all').indeterminate, isFalse);

    await tap(tester, keyed('select-all'));
    expect(
      tester.widget<SemiCheckboxGroup>(keyed('option-group')).value,
      isEmpty,
    );
    expect(checkbox(tester, 'select-all').indeterminate, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preventDefault blocks the toggle while armed', (tester) async {
    await start(tester);
    await tap(tester, keyed('toggle-block'));
    expect(find.textContaining('preventDefault 已拦截'), findsOneWidget);
    await tap(tester, keyed('event-checkbox'));
    expect(find.textContaining('切换被 preventDefault 拦截'), findsOneWidget);
    await tap(tester, keyed('toggle-block'));
    await tap(tester, keyed('event-checkbox'));
    expect(find.textContaining('切换已放行'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme checkboxes', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(find.text('主题卡片'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiCheckboxTheme.resolve(tester.element(find.text('主题卡片')));
    expect(theme.colorCheckboxLabelTextDefault, const Color(0xff7b61ff));
    expect(theme.colorCheckboxCheckedBgDefault, const Color(0xff0aa5a5));
    expect(theme.radiusCheckboxCardType, 12);
    expect(tester.takeException(), isNull);
  });
}
