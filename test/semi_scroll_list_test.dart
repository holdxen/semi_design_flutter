import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {bool rtl = false, SemiThemeData? theme}) =>
    SemiTheme(
      data: theme ?? const SemiThemeData.light(),
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Center(
          // 根宽随父约束（`width: 100%`）——测试给定宽盒；列高随 body（300）。
          child: SizedBox(width: 320, child: child),
        ),
      ),
    );

List<SemiScrollItemData> items(
  int count, {
  int? disabled,
  String prefix = '行',
}) => [
  for (var i = 0; i < count; i++)
    SemiScrollItemData(value: i, text: '$prefix$i', disabled: i == disabled),
];

Finder rowBox(Finder text) =>
    find.ancestor(of: text, matching: find.byType(AnimatedContainer));

/// 行底色（li `background-color`——AnimatedContainer 内层 DecoratedBox）。
Color? rowColorOf(WidgetTester tester, Finder text) {
  for (final box in tester.widgetList<DecoratedBox>(
    find.ancestor(of: text, matching: find.byType(DecoratedBox)),
  )) {
    final decoration = box.decoration;
    if (decoration is BoxDecoration && decoration.border == null) {
      return decoration.color;
    }
  }
  return null;
}

void main() {
  testWidgets('header/footer/body 几何与 bodyHeight 覆盖', (tester) async {
    await tester.pumpWidget(
      host(
        SemiScrollList(
          header: const Text('标题'),
          footer: const Text('底部'),
          children: [
            SemiScrollItem(mode: SemiScrollItemMode.normal, list: items(3)),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('标题'), findsOneWidget);
    expect(find.text('底部'), findsOneWidget);
    // body 高缺省 `$height-scrollList: 300px`。
    expect(tester.getSize(find.byType(SemiScrollItem)).height, 300);

    await tester.pumpWidget(
      host(
        SemiScrollList(
          bodyHeight: 264,
          children: [
            SemiScrollItem(mode: SemiScrollItemMode.normal, list: items(3)),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(SemiScrollItem)).height, 264);

    // 主题覆盖 `heightScrollList`。
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(mode: SemiScrollItemMode.normal, list: items(3)),
          ],
        ),
        theme: const SemiThemeData.light(
          components: SemiComponentThemes(
            scrollList: SemiScrollListThemeData(heightScrollList: 220),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(SemiScrollItem)).height, 220);
  });

  testWidgets('normal 点选即通知、不去重；禁用行不通知', (tester) async {
    final selections = <SemiScrollItemSelection>[];
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              mode: SemiScrollItemMode.normal,
              list: items(6, disabled: 2),
              type: 'col',
              onSelect: selections.add,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    // `this.foundation.selectIndex(index, this.list)`——即点即通知。
    await tester.tap(find.text('行3'));
    await tester.pump();
    expect(selections, hasLength(1));
    expect(selections[0].index, 3);
    expect(selections[0].item.value, 3);
    expect(selections[0].type, 'col');

    // 不去重：重复点同一行仍通知（normal 无 `_cachedSelectedNode` 门）。
    await tester.tap(find.text('行3'));
    await tester.pump();
    expect(selections, hasLength(2));

    // 禁用行不出手势（`cursor: not-allowed`）。
    await tester.tap(find.text('行2'), warnIfMissed: false);
    await tester.pump();
    expect(selections, hasLength(2));
  });

  testWidgets('transform 只作用于 selectedIndex 行（严格相等门）', (tester) async {
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              mode: SemiScrollItemMode.normal,
              list: items(3),
              selectedIndex: 1,
              transform: (value, text) => '选中:$value',
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('选中:1'), findsOneWidget);
    expect(find.text('行0'), findsOneWidget);
    expect(find.text('行1'), findsNothing);
  });

  testWidgets('normal 选中行底色 + 非末列分隔描边（rtl 翻侧）', (tester) async {
    final colors = SemiThemeData.light().colors;
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              mode: SemiScrollItemMode.normal,
              list: items(3),
              selectedIndex: 1,
            ),
            SemiScrollItem(
              mode: SemiScrollItemMode.normal,
              list: items(3, prefix: 'B'),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    // `-item-sel`：底 `$color-scrollList_selected_item-bg`。
    expect(
      rowColorOf(tester, find.text('行1')),
      colors.colorPrimaryLightDefault,
    );
    expect(
      rowColorOf(tester, find.text('行0')),
      isNot(colors.colorPrimaryLightDefault),
    );

    // `&:not(:last-child)`：非末列出 `BorderDirectional`（rtl.scss 翻侧等价），
    // 末列不出。
    BoxDecoration? borderOf(SemiScrollItem item) {
      for (final box in tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byWidget(item),
          matching: find.byType(DecoratedBox),
        ),
      )) {
        final decoration = box.decoration;
        if (decoration is BoxDecoration && decoration.border != null) {
          return decoration;
        }
      }
      return null;
    }

    final both = tester
        .widgetList<SemiScrollItem>(find.byType(SemiScrollItem))
        .toList();
    expect(borderOf(both[0])?.border, isA<BorderDirectional>());
    expect(borderOf(both[1])?.border, isNull);
  });

  testWidgets('行高取 heightScrollListItem（36）与主题覆盖', (tester) async {
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(mode: SemiScrollItemMode.normal, list: items(3)),
          ],
        ),
      ),
    );
    await tester.pump();
    // `$height-scrollList_item: 36px`（box-sizing: border-box 等价）。
    expect(tester.getSize(rowBox(find.text('行0'))).height, 36);

    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(mode: SemiScrollItemMode.normal, list: items(3)),
          ],
        ),
        theme: const SemiThemeData.light(
          components: SemiComponentThemes(
            scrollList: SemiScrollListThemeData(heightScrollListItem: 48),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(rowBox(find.text('行0'))).height, 48);
  });

  testWidgets('wheel mount 落选发一次 onSelect 初值 + 定选样式', (tester) async {
    final colors = SemiThemeData.light().colors;
    final typography = SemiThemeData.light().typography;
    final selections = <SemiScrollItemSelection>[];
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              list: items(6),
              selectedIndex: 0,
              onSelect: selections.add,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    // mount 链：滚动事件 → debouncedSelect → selectNode——`_cachedSelectedNode`
    // 初值 null 去重门放行，33ms 后通知一次初值（差异清单 #8）。
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(selections, hasLength(1));
    expect(selections[0].index, 0);
    // `semi-scrolllist-item-selected`：font-weight bold + 主色（B 表
    // `color: var(--semi-color-primary) !important`）。
    final style = tester.widget<Text>(find.text('行0')).style;
    expect(style?.fontWeight, typography.fontWeightBold);
    expect(style?.color, colors.colorPrimary);
  });

  testWidgets('wheel 滚动停滚定选、吸附居中、同下标去重', (tester) async {
    final selections = <SemiScrollItemSelection>[];
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              list: items(6),
              selectedIndex: 0,
              onSelect: selections.add,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    selections.clear(); // 丢弃 mount 初值通知。

    final scrollable = find.descendant(
      of: find.byType(SemiScrollItem),
      matching: find.byType(Scrollable),
    );
    await tester.drag(scrollable, const Offset(0, -140));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    final position = tester.state<ScrollableState>(scrollable).position;
    // 吸附居中（scrollToNode 公式：行中线对齐视口中线 → 偏移 = index*36）。
    expect(position.pixels, closeTo(36 * (position.pixels / 36).round(), 0.5));
    final expected = (position.pixels / 36).round();
    expect(selections, isNotEmpty);
    expect(selections.last.index, expected);
    // 定选行高亮。
    final style = tester.widget<Text>(find.text('行$expected')).style;
    expect(style?.fontWeight, SemiThemeData.light().typography.fontWeightBold);

    // 微移回同一行：同数据下标去重不再通知。
    final before = selections.length;
    await tester.drag(scrollable, const Offset(0, -25));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    final after = tester.state<ScrollableState>(scrollable).position;
    expect((after.pixels / 36).round(), expected);
    expect(selections, hasLength(before));
  });

  testWidgets('wheel 禁用行跳过定选', (tester) async {
    final selections = <SemiScrollItemSelection>[];
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              list: [
                for (var i = 0; i < 6; i++)
                  SemiScrollItemData(
                    value: i,
                    text: '行$i',
                    disabled: i == 1 || i == 2,
                  ),
              ],
              selectedIndex: 0,
              onSelect: selections.add,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    selections.clear();

    // 滚到禁用区附近——`isDisabledIndex` 跳过，取最近非禁用行。
    final scrollable = find.descendant(
      of: find.byType(SemiScrollItem),
      matching: find.byType(Scrollable),
    );
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(selections, isNotEmpty);
    for (final selection in selections) {
      expect(selection.index, isNot(1));
      expect(selection.index, isNot(2));
    }
  });

  testWidgets('wheel cycled 无限循环轮回下标', (tester) async {
    final selections = <SemiScrollItemSelection>[];
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              cycled: true,
              list: items(3),
              selectedIndex: 1,
              onSelect: selections.add,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    selections.clear();

    final scrollable = find.descendant(
      of: find.byType(SemiScrollItem),
      matching: find.byType(Scrollable),
    );
    // 大幅上滚（超过一轮）——虚拟循环不触顶，`indexInList % data.length`
    // 轮回下标恒在 [0, 3)。
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(selections, isNotEmpty);
    for (final selection in selections) {
      expect(selection.index, inInclusiveRange(0, 2));
    }
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.pixels, greaterThan(0));
  });

  testWidgets('wheel selectedIndex prop 变化滚动定位并通知', (tester) async {
    final selections = <SemiScrollItemSelection>[];
    Widget build(int selectedIndex) => host(
      SemiScrollList(
        children: [
          SemiScrollItem(
            list: items(6),
            selectedIndex: selectedIndex,
            onSelect: selections.add,
          ),
        ],
      ),
    );
    await tester.pumpWidget(build(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    selections.clear();

    await tester.pumpWidget(build(3));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(selections, hasLength(1));
    expect(selections.last.index, 3);
    final scrollable = find.descendant(
      of: find.byType(SemiScrollItem),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.pixels, closeTo(108, 0.5)); // 3 * 36
  });

  testWidgets('wheel 点选吸附居中并通知（clickToSelectItem 链）', (tester) async {
    final selections = <SemiScrollItemSelection>[];
    await tester.pumpWidget(
      host(
        SemiScrollList(
          children: [
            SemiScrollItem(
              list: items(6),
              selectedIndex: 0,
              onSelect: selections.add,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    selections.clear();

    await tester.tap(find.text('行4'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(selections, hasLength(1));
    expect(selections.last.index, 4);
    final scrollable = find.descendant(
      of: find.byType(SemiScrollItem),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.pixels, closeTo(144, 0.5)); // 4 * 36 吸附居中
  });
}
