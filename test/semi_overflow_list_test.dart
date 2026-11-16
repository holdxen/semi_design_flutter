// Behavior matrix for SemiOverflowList plus coverage for the zero-declaration
// Sass accounting (0 = 0 FIELDS + 0 MOTION + 0 INTERNAL) — the HARDCODES
// provenance anchors live in the widget's file-level note block / call sites.
// 0 dead variables (there are no declarations to die).
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  double width = 300,
  TextDirection direction = TextDirection.ltr,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: direction,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  double width = 300,
  TextDirection direction = TextDirection.ltr,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(800, 800));
  await tester.pumpWidget(host(child, width: width, direction: direction));
  await tester.pumpAndSettle();
}

List<String> names(int n) => [
  for (var i = 0; i < n; i++) String.fromCharCode(97 + i),
];

/// 固定 80 宽的可见项（测量宽确定，公式可预期）。
Widget fixedItem(String text) => SizedBox(width: 80, child: Text(text));

/// 溢出指示器：固定 40 宽，空溢出不渲染（上游 `overflowRenderer` 缺省 null）。
Widget? overflowNode(List<String> items) =>
    items.isEmpty ? null : SizedBox(width: 40, child: Text('+${items.length}'));

/// scroll 模式两端节点：固定 20 宽（滚动视口 = 宿主宽 - 40）。
List<Widget> scrollNodes(List<String> start, List<String> end) => [
  SizedBox(width: 20, child: Text('S${start.length}')),
  SizedBox(width: 20, child: Text('E${end.length}')),
];

void main() {
  group('sass 对账与锚点', () {
    test('对账 0 = 0 FIELDS + 0 MOTION + 0 INTERNAL；0 死变量', () {
      final docs = File('docs/semi_overflow_list.md').readAsStringSync();
      expect(docs, contains('0 = 0 FIELDS + 0 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
      expect(docs, contains('（上游未消费）'));
      final widgetSource = File('lib/src/components/semi_overflow_list.dart')
          .readAsStringSync();
      expect(widgetSource, contains('0 = 0 FIELDS + 0 MOTION + 0 INTERNAL'));
    });

    test('无主题产物：overflowList 零声明，不生成 ThemeData', () {
      expect(
        File('lib/src/theme/semi_overflow_list_theme_data.dart').existsSync(),
        isFalse,
      );
      expect(
        File('lib/src/theme/semi_overflow_list_theme.dart').existsSync(),
        isFalse,
      );
    });

    test('the 30 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_overflow_list.dart')
          .readAsStringSync();
      const anchors = <String>[
        'display: flex',
        'flex-wrap: nowrap',
        'min-width: 0',
        'flex-shrink: 1',
        'width: 1px',
        'flex: 1',
        'overflow-x: scroll',
        'direction: rtl',
        'MINIMUM_HTML_ELEMENT_WIDTH: 4',
        'threshold: 0.75',
        'minVisibleItems: 0',
        "collapseFrom: 'end'",
        "renderMode: 'collapse'",
        'overflowRenderDirection: "both"',
        "maxWidth: '100%'",
        'visibility: overflowStatus === "calculating" && this.state.pivot < 0',
        'newState.lastOverflowCount = props.renderMode === RenderMode.SCROLL '
            '? 0 : -1',
        'if (itemWidths > containerWidth)',
        'if (_pivot === items.length - 1)',
        'Math.max(minVisibleItems, _pivot)',
        'scrollOverflow',
        'items.slice(0, visibleStart)',
        'items.slice(visibleEnd + 1, items.length)',
        'previousY',
        "get(item, itemKey || 'key', defaultKey)",
        "'data-scrollkey'",
        'isScrollOverflowCalculating',
        'direction: PropTypes.oneOf(strings.POSITION_SET)',
        'strings.OVERFLOW_DIR',
        'reference to https://github.com/palantir/blueprint/blob/1aa71605/'
            'packages/core/src/components/overflow-list/overflowList.tsx#L34',
      ];
      expect(anchors, hasLength(30));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });
  });

  group('collapse 行为', () {
    testWidgets('尾部折叠：300 宽放下 3 项 + 溢出节点，onOverflow 通知', (tester) async {
      final overflowCalls = <List<String>>[];
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(6),
          overflowRenderer: overflowNode,
          visibleItemRenderer: (item, index) => fixedItem(item),
          onOverflow: overflowCalls.add,
        ),
      );
      // 40 + 80×3 = 280 ≤ 300；+80 = 360 > 300 → pivot 3。
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(find.text('d'), findsNothing);
      expect(find.text('+3'), findsOneWidget);
      expect(overflowCalls, [
        ['d', 'e', 'f'],
      ]);
      // 溢出节点在行尾（collapseFrom: end）。
      expect(
        tester.getTopLeft(find.text('+3')).dx,
        greaterThan(tester.getTopLeft(find.text('c')).dx),
      );
    });

    testWidgets('collapseFrom: start —— 保留尾部、溢出节点在行首，index 为'
        '可见数组内下标', (tester) async {
      final indexes = <int>[];
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(6),
          collapseFrom: SemiOverflowListCollapseFrom.start,
          overflowRenderer: overflowNode,
          visibleItemRenderer: (item, index) {
            indexes.add(index);
            return fixedItem(item);
          },
        ),
      );
      expect(find.text('d'), findsOneWidget);
      expect(find.text('e'), findsOneWidget);
      expect(find.text('f'), findsOneWidget);
      expect(find.text('a'), findsNothing);
      expect(find.text('+3'), findsOneWidget);
      // ★上游 visible.map((item, idx) => ...) —— idx 是可见数组内下标
      //（收敛后最后一轮渲染为 [0, 1, 2]；猜测期曾全量渲染一遍）。
      expect(indexes.sublist(indexes.length - 3), [0, 1, 2]);
      expect(
        tester.getTopLeft(find.text('+3')).dx,
        lessThan(tester.getTopLeft(find.text('d')).dx),
      );
    });

    testWidgets('容器宽度变化重算（220 → 2 项、460 → 5 项）', (tester) async {
      Widget list() => SemiOverflowList<String>(
        items: names(6),
        overflowRenderer: overflowNode,
        visibleItemRenderer: (item, index) => fixedItem(item),
      );
      await pumpHost(tester, list(), width: 220);
      // 40 + 80×2 = 200 ≤ 220；+80 = 280 > 220 → pivot 2。
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsNothing);
      expect(find.text('+4'), findsOneWidget);

      await pumpHost(tester, list(), width: 460);
      // 40 + 80×5 = 440 ≤ 460；+80 = 520 > 460 → pivot 5。
      expect(find.text('e'), findsOneWidget);
      expect(find.text('f'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('全部放下：溢出渲染收空列表、onOverflow([]) 补发', (tester) async {
      final rendered = <List<String>>[];
      final notified = <List<String>>[];
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(3),
          overflowRenderer: (items) {
            rendered.add(items);
            return overflowNode(items);
          },
          visibleItemRenderer: (item, index) => fixedItem(item),
          onOverflow: notified.add,
        ),
      );
      // 40 + 80×3 = 280 ≤ 300，遍历到末项 → normal 全量可见。
      for (final name in names(3)) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('+3'), findsNothing);
      expect(rendered.last, isEmpty);
      // lastOverflowCount 初始 -1 ≠ 0 → 强制补发一次空溢出。
      expect(notified, [const <String>[]]);
    });

    testWidgets('onOverflow 仅在变化时通知；items 变化强制补发', (tester) async {
      final overflowCalls = <List<String>>[];
      Widget list(List<String> items) => SemiOverflowList<String>(
        items: items,
        overflowRenderer: overflowNode,
        visibleItemRenderer: (item, index) => fixedItem(item),
        onOverflow: overflowCalls.add,
      );
      await pumpHost(tester, list(names(6)));
      expect(overflowCalls, hasLength(1));

      // 相同 items 重建：不再通知。
      await pumpHost(tester, list(names(6)));
      expect(overflowCalls, hasLength(1));

      // 换 items（同为 3 项溢出）：lastOverflowCount = -1 强制补发。
      await pumpHost(tester, list(const ['g', 'h', 'i', 'j', 'k', 'l']));
      expect(overflowCalls, hasLength(2));
      expect(overflowCalls.last, ['j', 'k', 'l']);
    });

    testWidgets('minVisibleItems 强保 5 项可见（超宽整行画出容器外，同 CSS '
        'overflow: visible）', (tester) async {
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(6),
          minVisibleItems: 5,
          overflowRenderer: overflowNode,
          visibleItemRenderer: (item, index) => fixedItem(item),
        ),
      );
      // pivot = max(5, 3) = 5 → 可见 a-e、溢出 [f]。
      for (final name in ['a', 'b', 'c', 'd', 'e']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('f'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
      // 40 + 80×5 = 440 > 300 —— 子项保持固有宽（flex min-width: auto 不
      // 收缩）、整行画出 300 容器外（CSS overflow: visible）。
      final row = find.descendant(
        of: find.byType(SemiOverflowList<String>),
        matching: find.byType(Row),
      );
      expect(row, findsOneWidget);
      expect(tester.getSize(row).width, greaterThan(300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('缺省渲染器渲染空盒子（上游 nullRenderer 语义）', (tester) async {
      await pumpHost(
        tester,
        const SemiOverflowList<String>(items: ['hidden', 'visible']),
      );
      expect(find.text('hidden'), findsNothing);
      expect(find.text('visible'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('items 更新后保持可见（上游 overflowList.test.js：'
        'pivot 不重置、不闪隐）', (tester) async {
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(2),
          overflowRenderer: overflowNode,
          visibleItemRenderer: (item, index) => fixedItem(item),
        ),
      );
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(3),
          overflowRenderer: overflowNode,
          visibleItemRenderer: (item, index) => fixedItem(item),
        ),
      );
      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, isTrue);
    });

    testWidgets('RTL：collapseFrom: start 时溢出节点落在行首（视觉右侧）', (tester) async {
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(6),
          collapseFrom: SemiOverflowListCollapseFrom.start,
          overflowRenderer: overflowNode,
          visibleItemRenderer: (item, index) => fixedItem(item),
        ),
        direction: TextDirection.rtl,
      );
      expect(find.text('+3'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('+3')).dx,
        greaterThan(tester.getTopLeft(find.text('f')).dx),
      );
    });
  });

  group('scroll 行为', () {
    testWidgets('视口相交决定溢出分组（贴边/部分可见算可见）', (tester) async {
      final visibleCalls = <Map<String, bool>>[];
      final intersectCalls = <Map<String, SemiOverflowListIntersectEntry>>[];
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(6),
          renderMode: SemiOverflowListRenderMode.scroll,
          itemKey: (item) => item,
          scrollOverflowRenderer: (start, end) => scrollNodes(start, end),
          visibleItemRenderer: (item, index) => fixedItem(item),
          onVisibleStateChange: visibleCalls.add,
          onIntersect: intersectCalls.add,
        ),
        width: 210,
      );
      // 视口 210-40 = 170：a[0,80]、b[80,160] 全可见，c[160,240] 部分
      // 相交（ratio 0.125 < 0.75 但 isIntersecting 真）→ 可见；d 起溢出。
      expect(find.text('S0'), findsOneWidget);
      expect(find.text('E3'), findsOneWidget);
      expect(visibleCalls, isNotEmpty);
      expect(visibleCalls.last, {
        'a': true,
        'b': true,
        'c': true,
        'd': false,
        'e': false,
        'f': false,
      });
      // 首次观察：全部条目批量回调（IntersectionObserver 初始回调）。
      expect(intersectCalls.first.keys.toSet(), {'a', 'b', 'c', 'd', 'e', 'f'});
      final entry = intersectCalls.first['c']!;
      expect(entry.isIntersecting, isTrue);
      expect(entry.intersectionRatio, closeTo(0.125, 0.001));
    });

    testWidgets('滚动后溢出分组跟随视口，onIntersect 只带变化条目', (tester) async {
      final intersectCalls = <Map<String, SemiOverflowListIntersectEntry>>[];
      await pumpHost(
        tester,
        SemiOverflowList<String>(
          items: names(6),
          renderMode: SemiOverflowListRenderMode.scroll,
          itemKey: (item) => item,
          scrollOverflowRenderer: (start, end) => scrollNodes(start, end),
          visibleItemRenderer: (item, index) => fixedItem(item),
          onIntersect: intersectCalls.add,
        ),
        width: 210,
      );
      intersectCalls.clear();

      // 向右滚 120px（分步手势，避免甩动惯性）。
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SingleChildScrollView)),
      );
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump(const Duration(milliseconds: 30));
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump(const Duration(milliseconds: 30));
      await gesture.up();
      await tester.pumpAndSettle();

      final pixels = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .pixels;
      // 按实际滚动偏移推导期望分组（对甩动残留鲁棒）。
      var visibleStart = -1;
      var visibleEnd = -1;
      for (var i = 0; i < 6; i++) {
        final left = i * 80 - pixels;
        final right = left + 80;
        final hit = right >= 0 && left <= 170;
        if (hit) {
          visibleStart = visibleStart < 0 ? i : visibleStart;
          visibleEnd = i;
        }
      }
      expect(find.text('S$visibleStart'), findsOneWidget);
      expect(find.text('E${5 - visibleEnd}'), findsOneWidget);
      // 变化条目应远少于 6 个（只报阈值索引跨越或 isIntersecting 翻转）。
      expect(intersectCalls, isNotEmpty);
      expect(intersectCalls.last.length, lessThan(6));
    });

    testWidgets('overflowRenderDirection 决定两个溢出节点的摆放', (tester) async {
      Future<void> pump(SemiOverflowListOverflowRenderDirection dir) {
        return pumpHost(
          tester,
          SemiOverflowList<String>(
            items: names(6),
            renderMode: SemiOverflowListRenderMode.scroll,
            itemKey: (item) => item,
            overflowRenderDirection: dir,
            scrollOverflowRenderer: (start, end) => scrollNodes(start, end),
            visibleItemRenderer: (item, index) => fixedItem(item),
          ),
          width: 210,
        );
      }

      double scrollerLeft() =>
          tester.getTopLeft(find.byType(SingleChildScrollView)).dx;
      double left(String text) => tester.getTopLeft(find.text(text)).dx;

      await pump(SemiOverflowListOverflowRenderDirection.both);
      // [起点, 滚动容器, 终点]。
      expect(left('S0'), lessThan(scrollerLeft()));
      expect(scrollerLeft(), lessThan(left('E3')));

      await pump(SemiOverflowListOverflowRenderDirection.start);
      // [起点, 终点, 滚动容器] —— 两个节点都在滚动容器左侧。
      expect(left('S0'), lessThan(left('E3')));
      expect(left('E3'), lessThan(scrollerLeft()));

      await pump(SemiOverflowListOverflowRenderDirection.end);
      // [滚动容器, 起点, 终点] —— 两个节点都在滚动容器右侧。
      expect(scrollerLeft(), lessThan(left('S0')));
      expect(left('S0'), lessThan(left('E3')));
    });

    testWidgets('threshold 变化重建观察：全部条目补发一次', (tester) async {
      final intersectCalls = <Map<String, SemiOverflowListIntersectEntry>>[];
      Widget list(double threshold) => SemiOverflowList<String>(
        items: names(6),
        renderMode: SemiOverflowListRenderMode.scroll,
        itemKey: (item) => item,
        threshold: threshold,
        scrollOverflowRenderer: (start, end) => scrollNodes(start, end),
        visibleItemRenderer: (item, index) => fixedItem(item),
        onIntersect: intersectCalls.add,
      );
      await pumpHost(tester, list(0.75), width: 210);
      intersectCalls.clear();
      await pumpHost(tester, list(0.25), width: 210);
      expect(intersectCalls, isNotEmpty);
      expect(intersectCalls.last.keys.toSet(), {'a', 'b', 'c', 'd', 'e', 'f'});
    });

    testWidgets('items 变化清空可见状态并按新键重算', (tester) async {
      final visibleCalls = <Map<String, bool>>[];
      Widget list(List<String> items) => SemiOverflowList<String>(
        items: items,
        renderMode: SemiOverflowListRenderMode.scroll,
        itemKey: (item) => item,
        scrollOverflowRenderer: (start, end) => scrollNodes(start, end),
        visibleItemRenderer: (item, index) => fixedItem(item),
        onVisibleStateChange: visibleCalls.add,
      );
      await pumpHost(tester, list(names(6)), width: 210);
      visibleCalls.clear();
      await pumpHost(tester, list(const ['x', 'y', 'z']), width: 210);
      expect(visibleCalls, isNotEmpty);
      expect(visibleCalls.last.keys.toSet(), {'x', 'y', 'z'});
    });
  });
}
