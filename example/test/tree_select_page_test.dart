import 'dart:ui' show PointerDeviceKind;

import 'package:example/pages/tree_select.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('treeSelect-status'),
  matching: find.textContaining(text),
);

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: keyed('treeSelect-status'), matching: find.byType(Text)),
    )
    .map((t) => t.data ?? '')
    .join();

/// 弹层内文本（避开触发器回填的同名文本）。
Finder rowText(String text) => find.descendant(
  of: find.byKey(SemiTreeSelect.listKey),
  matching: find.text(text),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(const SemiApp(home: TreeSelectPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> settle(WidgetTester tester) async {
  // 弹层内容更新走 SemiTooltip post-frame，入场定位需 4+ 帧（未定位前 park +
  // opacity 0 防闪）——多泵几拍再断言。
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('page mounts every demo', (tester) async {
    await start(tester);
    expect(tester.takeException(), isNull);
    expect(keyed('treeSelect-status'), findsOneWidget);
    expect(keyed('basic-single'), findsOneWidget);
    expect(keyed('basic-multiple'), findsOneWidget);
    expect(keyed('search-dropdown'), findsOneWidget);
    expect(keyed('search-trigger'), findsOneWidget);
    expect(keyed('size-small'), findsOneWidget);
    expect(keyed('form-borderless'), findsOneWidget);
    expect(keyed('controlled'), findsOneWidget);
    expect(keyed('lazy'), findsOneWidget);
  });

  testWidgets('single pick notifies and fills back the label', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('basic-single'));
    await tester.tap(find.text('请选择部门'));
    await settle(tester);
    await tester.tap(rowText('运营'));
    await settle(tester);
    expect(statusContaining('onSelect:c:true'), findsOneWidget);
    expect(statusContaining('onChange:c'), findsOneWidget);
    // 触发器回填 label（value ?? key → 'c' 走 label 渲染为「运营」）。
    expect(find.text('运营'), findsOneWidget);
  });

  testWidgets('multiple cascades checks and closes tags', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('basic-multiple'));
    await tester.tap(find.text('请选择成员'));
    await settle(tester);
    // 展开「研发」后勾选「前端」（弹层行在 Overlay 内——用全局 key）。
    await tester.tap(find.byKey(const ValueKey('treeSelect-expand-a')));
    await settle(tester);
    await tester.tap(rowText('前端'));
    await settle(tester);
    expect(statusContaining('onSelect:a-1:true'), findsOneWidget);
    // 触发器出现标签（限定触发器范围——弹层行同名）。
    expect(
      find.descendant(
        of: keyed('basic-multiple'),
        matching: find.text('前端'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('dropdown search reports onSearch', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('search-dropdown'));
    await tester.tap(keyed('search-dropdown'));
    await settle(tester);
    await tester.enterText(
      find.byKey(SemiTreeSelect.searchInputKey),
      '设计',
    );
    await settle(tester);
    expect(statusContaining('onSearch:设计'), findsOneWidget);
    expect(rowText('设计'), findsOneWidget);
    // ★上游口径：未开 showFilteredOnly 时顶层行不裁剪，只折叠未命中分支
    //（flatten 的 shown 仅在 showFilteredOnly 生效）——「前端」在折叠分支内不可见。
    expect(rowText('前端'), findsNothing);
  });

  testWidgets('trigger search filters in place', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('search-trigger'));
    await tester.tap(find.text('搜索并多选'));
    await settle(tester);
    await tester.enterText(find.byType(SemiInput), '运营');
    await settle(tester);
    expect(statusContaining('onSearch:运营'), findsOneWidget);
    expect(rowText('运营'), findsOneWidget);
  });

  testWidgets('sizes and statuses paint', (tester) async {
    await start(tester);
    expect(find.text('small 24'), findsOneWidget);
    expect(find.text('default 32'), findsOneWidget);
    expect(find.text('large 40'), findsOneWidget);
    expect(find.text('warning'), findsOneWidget);
    expect(find.text('error'), findsOneWidget);
  });

  testWidgets('lazy load completes with onLoad', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('lazy'));
    await tester.tap(keyed('lazy'));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('treeSelect-expand-lazy-root')));
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(statusContaining('onLoad:lazy-root'), findsOneWidget);
  });

  testWidgets('clear reports onClear', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('basic-clear'));
    // 限定 basic-clear 触发器（form-slots 的标签也有「前端」）。
    await tester.tap(
      find.descendant(of: keyed('basic-clear'), matching: find.text('前端')),
    );
    await settle(tester);
    // hover 触发器显示清空按钮。
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(keyed('basic-clear')));
    await settle(tester);
    await tester.tap(find.byKey(SemiTreeSelect.clearButtonKey));
    await settle(tester);
    expect(statusContaining('onClear'), findsOneWidget);
  });
}
