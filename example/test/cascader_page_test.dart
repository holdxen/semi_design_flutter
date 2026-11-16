import 'package:example/pages/cascader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('cascader-status'),
  matching: find.textContaining(text),
);

/// 弹层内选项行（避开触发器回填同名文本）。
Finder rowOf(String key) => find.descendant(
  of: find.byKey(SemiCascader.listKey),
  matching: find.byKey(SemiCascader.optionKey(key)),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: CascaderPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('single: walk the columns and pick a leaf; status echoes the '
      'events', (tester) async {
    await start(tester);
    expect(statusContaining('点击触发器逐级选择'), findsOneWidget);
    await tester.tap(find.text('请选择'));
    await tester.pumpAndSettle();
    await tester.tap(rowOf('zhejiang'));
    await tester.pumpAndSettle();
    await tester.tap(rowOf('zhejiang_SEMI_CASCADER_SPLIT_hangzhou'));
    await tester.pumpAndSettle();
    await tester.tap(
      rowOf('zhejiang_SEMI_CASCADER_SPLIT_hangzhou_SEMI_CASCADER_SPLIT_xihu'),
    );
    await tester.pumpAndSettle();
    expect(statusContaining('onSelect xihu'), findsOneWidget);
    expect(
      statusContaining('onChange [zhejiang, hangzhou, xihu]'),
      findsOneWidget,
    );
  });

  testWidgets('multiple: checking Hangzhou cascades and reports the merged '
      'value', (tester) async {
    await start(tester);
    await tester.tap(find.text('多选'));
    await tester.pumpAndSettle();
    await tester.tap(rowOf('zhejiang'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(SemiCascader.listKey),
        matching: find.byKey(
          SemiCascader.optionCheckboxKey('zhejiang_SEMI_CASCADER_SPLIT_hangzhou'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      statusContaining('multiple onChange [[zhejiang, hangzhou]]'),
      findsOneWidget,
    );
  });

  testWidgets('search: typing filters the flat list; picking selects', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('搜索：试试「西」'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(SemiCascader.searchInputKey), '西湖');
    await tester.pumpAndSettle();
    expect(statusContaining('onSearch 西湖'), findsOneWidget);
    await tester.tap(
      rowOf('zhejiang_SEMI_CASCADER_SPLIT_hangzhou_SEMI_CASCADER_SPLIT_xihu'),
    );
    await tester.pumpAndSettle();
    expect(
      statusContaining('search onChange [zhejiang, hangzhou, xihu]'),
      findsOneWidget,
    );
  });
}
