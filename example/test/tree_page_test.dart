import 'package:example/pages/tree.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('tree-status'),
  matching: find.textContaining(text),
);

Finder nameOf(String demoKey, String text) =>
    find.descendant(of: keyed(demoKey), matching: find.text(text));

Finder arrowIn(String demoKey, String nodeKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(ValueKey('tree-expand-$nodeKey')),
);

Finder checkboxIn(String demoKey, String nodeKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(ValueKey('tree-checkbox-$nodeKey')),
);

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: keyed('tree-status'), matching: find.byType(Text)),
    )
    .map((t) => t.data ?? '')
    .join();

int eventCount(WidgetTester tester, String exact) =>
    statusText(tester).split('；').where((e) => e == exact).length;

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2000));
  await tester.pumpWidget(const SemiApp(home: TreePage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 200),
}) async {
  for (var i = 0; i < 2; i++) {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
    await tester.pump(wait);
    await tester.pump();
    if (done()) return;
  }
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('page renders every demo section and variant', (tester) async {
    await start(tester);
    for (final title in [
      '基础',
      '目录 / 引导线',
      '多选与过滤',
      '异步加载 / 空态',
      '虚拟化 / 自定义渲染',
      '受控与 RTL',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'tree-basic',
      'tree-click-expand',
      'tree-double-expand',
      'tree-directory',
      'tree-line-label',
      'tree-multiple',
      'tree-filter',
      'tree-filter-only',
      'tree-lazy',
      'tree-empty',
      'tree-empty-custom',
      'tree-virtual',
      'tree-custom-render',
      'tree-controlled',
      'tree-rtl',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic demo expands, selects and logs callbacks', (tester) async {
    await start(tester);
    await settle(tester);
    expect(nameOf('tree-basic', '子节点 A'), findsOneWidget);
    // 选择子节点 A。
    await tapUntil(
      tester,
      nameOf('tree-basic', '子节点 A'),
      () => statusContaining('onChange child-1').evaluate().isNotEmpty,
    );
    expect(statusContaining('onSelect child-1/true'), findsOneWidget);
    expect(statusContaining('onChange child-1'), findsOneWidget);
    // 禁用 C 不可选。
    await tapUntil(tester, nameOf('tree-basic', '子节点 C（禁用）'), () => false);
    expect(statusContaining('onChange child-3'), findsNothing);
    // 收起父级。
    await tapUntil(
      tester,
      arrowIn('tree-basic', 'parent'),
      () => statusContaining('onExpand parent/false').evaluate().isNotEmpty,
    );
    await settle(tester);
    expect(nameOf('tree-basic', '子节点 A'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expandAction click and doubleClick demos expand differently', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      nameOf('tree-click-expand', '父节点'),
      () => nameOf('tree-click-expand', '子节点 A').evaluate().isNotEmpty,
    );
    expect(nameOf('tree-click-expand', '子节点 A'), findsOneWidget);
    // doubleClick：单击不展开，双击展开。
    await tester.ensureVisible(nameOf('tree-double-expand', '父节点'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(nameOf('tree-double-expand', '父节点'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(nameOf('tree-double-expand', '子节点 A'), findsNothing);
    await tester.tap(nameOf('tree-double-expand', '父节点'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(nameOf('tree-double-expand', '子节点 A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('directory demo renders folder/file icons and guide lines', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('tree-directory'));
    await tester.pump(const Duration(milliseconds: 100));
    final icons = tester
        .widgetList<SemiIcon>(
          find.descendant(
            of: keyed('tree-directory'),
            matching: find.byType(SemiIcon),
          ),
        )
        .map((icon) => icon.data);
    expect(icons, containsAll([SemiIcons.folderOpen, SemiIcons.file]));
    expect(find.byType(SemiTree), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiple demo cascades checks and logs merged payload', (
    tester,
  ) async {
    await start(tester);
    await settle(tester);
    // 勾子节点 A：父级半选。
    await tapUntil(
      tester,
      checkboxIn('tree-multiple', 'child-1'),
      () => statusContaining('onChange [child-1]').evaluate().isNotEmpty,
    );
    expect(statusContaining('onSelect child-1/true'), findsOneWidget);
    // 勾父级：级联全选（leafOnly → 只回传叶子键）。
    await tapUntil(
      tester,
      checkboxIn('tree-multiple', 'parent'),
      () =>
          statusContaining('onChange [child-1, child-2]').evaluate().isNotEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter demos expand ancestors and highlight matches', (
    tester,
  ) async {
    await start(tester);
    final input = find.descendant(
      of: find.descendant(
        of: keyed('tree-filter'),
        matching: find.byKey(SemiTree.searchInputKey),
      ),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(input);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(input, 'API');
    await tester.pump();
    expect(find.byType(SemiHighlight), findsWidgets);
    expect(
      find.descendant(of: keyed('tree-filter'), matching: find.text('API.md')),
      findsOneWidget,
    );
    // showFilteredOnly：只留命中链。
    final onlyInput = find.descendant(
      of: find.descendant(
        of: keyed('tree-filter-only'),
        matching: find.byKey(SemiTree.searchInputKey),
      ),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(onlyInput);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(onlyInput, 'API');
    await tester.pump();
    expect(
      find.descendant(
        of: keyed('tree-filter-only'),
        matching: find.text('README.md'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('lazy demo shows a spin then fills children and logs onLoad', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('tree-lazy'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(arrowIn('tree-lazy', 'remote'));
    await tester.pump();
    expect(
      find.descendant(of: keyed('tree-lazy'), matching: find.byType(SemiSpin)),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 600));
    await settle(tester);
    expect(statusContaining('onLoad remote'), findsOneWidget);
    expect(nameOf('tree-lazy', '加载子一'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and virtual demos render', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('tree-empty'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('暂无数据'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('tree-empty-custom'),
        matching: find.text('没有数据'),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(keyed('tree-virtual'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(of: keyed('tree-virtual'), matching: find.text('虚拟行 1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom render and controlled demos follow props', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('tree-custom-render'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(
        of: keyed('tree-custom-render'),
        matching: find.text('· 父节点'),
      ),
      findsOneWidget,
    );
    // 受控：点击子节点只发 onChange，选中不跟随。
    await tapUntil(
      tester,
      nameOf('tree-controlled', '受控叶子'),
      () => statusContaining('onChange c2').evaluate().isNotEmpty,
    );
    expect(statusContaining('onChange c2'), findsOneWidget);
    await tapUntil(
      tester,
      find.text('选中受控子二'),
      () => statusContaining('onChange c1-2').evaluate().isNotEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL demo renders mirrored tree', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('tree-rtl'));
    await tester.pump(const Duration(milliseconds: 100));
    final rotates = tester
        .widgetList<SemiIcon>(
          find.descendant(
            of: keyed('tree-rtl'),
            matching: find.byType(SemiIcon),
          ),
        )
        .where((icon) => icon.data == SemiIcons.treeTriangleDown)
        .map((icon) => icon.rotate);
    // 收起节点在 RTL 下 rotate 90（LTR 是 270）。
    expect(rotates, contains(90));
    expect(tester.takeException(), isNull);
  });
}
