import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

/// Opens a dropdown and lets the overlay entry + motion settle.
Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
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
    for (final title in ['基础用法', '触发方式', '类型与状态', '选中对勾', '自定义弹层与嵌套', '局部主题']) {
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

  testWidgets('basic dropdown opens with grouped items and tick', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('操作一'), findsNothing);
    await tap(tester, keyed('basic-target'));
    expect(find.text('分组一'), findsOneWidget);
    expect(find.text('操作一'), findsOneWidget);
    expect(find.text('操作二'), findsOneWidget);
    expect(find.text('分组二'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('click trigger opens and item taps report status', (
    tester,
  ) async {
    await start(tester);
    expect(find.textContaining('点击或悬停'), findsOneWidget);
    await tap(tester, keyed('click-target'));
    expect(find.text('点击项一'), findsOneWidget);
    await tap(tester, find.text('点击项一'));
    expect(find.textContaining('点击了「点击项一」'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('types disabled icons and tick demos expose menu data', (
    tester,
  ) async {
    await start(tester);
    final types = tester.widget<SemiDropdown>(keyed('types-target-dropdown'));
    final items = types.menu!.whereType<SemiDropdownItemData>().toList();
    expect(items.map((item) => item.type), [
      SemiDropdownItemType.primary,
      SemiDropdownItemType.secondary,
      SemiDropdownItemType.tertiary,
      SemiDropdownItemType.warning,
      SemiDropdownItemType.danger,
      null,
      null,
    ]);
    expect(items[5].disabled, isTrue);
    expect(items[6].icon, isA<SemiIcon>());
    expect(types.showTick, isNull);

    final nested = tester.widget<SemiDropdown>(keyed('nested-dropdown'));
    expect(nested.menu, hasLength(2));
    expect(nested.menu![1], isA<SemiDropdownItemData>());
    expect((nested.menu![1] as SemiDropdownItemData).name, isA<SemiDropdown>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme dropdown', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-target'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiDropdownTheme.resolve(
      tester.element(keyed('theme-target')),
    );
    expect(theme.colorDropdownBgDefault, const Color(0xff2b2340));
    expect(theme.colorDropdownItemBgHover, const Color(0xff453a63));
    expect(theme.radiusDropdown, 12);
    expect(theme.widthDropdown, 240);
    expect(tester.takeException(), isNull);
  });
}
