import 'package:example/pages/select.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder editable(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

SemiSelect select(WidgetTester tester, String key) =>
    tester.widget<SemiSelect>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: SelectPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  // See docs/known_issues.md #1 — absorb the one dropped hit test.
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Opens the select named by [key] and lets the panel settle.
Future<void> openPanel(WidgetTester tester, String key) async {
  await tester.ensureVisible(keyed(key));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tap(keyed(key));
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
      '基本使用',
      '多选',
      '分组',
      '尺寸与状态',
      '前缀、后缀与清除',
      '顶部/底部附加项',
      '受控与动态 Options',
      '搜索',
      '远程搜索',
      '创建条目',
      '自定义渲染',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('basic select opens, selects and closes the panel', (
    tester,
  ) async {
    await start(tester);
    await openPanel(tester, 'select-basic');
    // Panel option rows are in the overlay; 西瓜视频 is unique while open.
    expect(find.text('西瓜视频'), findsOneWidget);
    await tap(tester, find.text('西瓜视频'));
    // Selection lands in the trigger and the panel closes.
    expect(find.text('西瓜视频'), findsOneWidget);
    expect(
      find.descendant(of: keyed('select-basic'), matching: find.text('请选择')),
      findsNothing,
    );
    expect(select(tester, 'select-basic').onChanged, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiple tags toggle and max reports onExceed', (tester) async {
    await start(tester);
    await openPanel(tester, 'select-multi');
    // The two default tags render in the trigger.
    expect(find.text('抖音'), findsWidgets);
    expect(find.text('轻颜相机'), findsWidgets);
    // Selecting a third item hits max=2 → onExceed.
    await tap(tester, find.text('西瓜视频'));
    expect(find.text('最多只允许选择两项'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter narrows the panel and blocks unrelated rows', (
    tester,
  ) async {
    await start(tester);
    await openPanel(tester, 'select-filter');
    expect(find.text('剪映'), findsOneWidget);
    await tester.enterText(editable('select-filter'), '西瓜');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('西瓜视频'), findsOneWidget);
    expect(find.text('剪映'), findsNothing);
    expect(find.text('搜索：「西瓜」'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('allowCreate appends a create row and reports onCreate', (
    tester,
  ) async {
    await start(tester);
    await openPanel(tester, 'select-create');
    await tester.enterText(editable('select-create'), '新条目');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('新条目'), findsWidgets);
    await tap(tester, find.textContaining('新条目').last);
    expect(find.text('创建了：新条目'), findsOneWidget);
    // The renderCreateItem demo replaces the default 「创建」 row.
    await openPanel(tester, 'select-create-custom');
    await tester.enterText(editable('select-create-custom'), '贺岁版');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('新建「贺岁版」'), findsOneWidget);
    await tap(tester, find.text('新建「贺岁版」'));
    expect(find.text('创建了：贺岁版'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('group headers, sizes, states and custom render match', (
    tester,
  ) async {
    await start(tester);
    await openPanel(tester, 'select-group');
    expect(find.text('字节系'), findsOneWidget);
    expect(find.text('工具'), findsOneWidget);
    await tap(tester, find.text('字节系')); // 关闭面板
    await tester.pump(const Duration(milliseconds: 100));
    expect(select(tester, 'select-small').size, SemiInputSize.small);
    expect(select(tester, 'select-normal').size, SemiInputSize.normal);
    expect(select(tester, 'select-large').size, SemiInputSize.large);
    expect(select(tester, 'select-disabled').disabled, isTrue);
    expect(
      select(tester, 'select-warning').validateStatus,
      SemiInputStatus.warning,
    );
    expect(
      select(tester, 'select-error').validateStatus,
      SemiInputStatus.error,
    );
    expect(select(tester, 'select-prefix').showClear, isTrue);
    expect(select(tester, 'select-multi').maxTagCount, 2);
    expect(select(tester, 'select-multi').max, 2);
    expect(select(tester, 'select-create').allowCreate, isTrue);
    expect(select(tester, 'select-remote').remote, isTrue);
    expect(
      select(tester, 'select-filter-dropdown').searchPosition,
      SemiSelectSearchPosition.dropdown,
    );
    // Custom selected-item rendering shows in the trigger.
    expect(find.text('已选 · 抖音'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
