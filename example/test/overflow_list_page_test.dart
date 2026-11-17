import 'package:example/pages/overflow_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: OverflowListPage()));
  await tester.pumpAndSettle();
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
    for (final title in ['折叠模式 - 默认', '折叠模式 - 方向', '折叠模式 - 最小展示的数目', '滚动模式']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('width slider collapses and restores the basic demo', (
    tester,
  ) async {
    await start(tester);
    // 拖到最窄（10% → 40px）—— 全部折叠成 "+N"。
    await tester.drag(keyed('overflow-width'), const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: keyed('overflow-basic'),
        matching: keyed('overflow-n'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    // 拖到最宽（100% → 400px）—— 溢出收起或数量减少。
    await tester.drag(keyed('overflow-width'), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapse-from-start keeps the tail items visible', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('overflow-from-start'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll mode renders two-sided overflow indicators', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('overflow-scroll'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('overflow-scroll-start'), findsOneWidget);
    expect(keyed('overflow-scroll-end'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chips inside a list are evenly spaced (incl. the "+N" one)', (
    tester,
  ) async {
    await start(tester);
    for (final key in [
      'overflow-basic',
      'overflow-from-start',
      'overflow-min-visible',
      'overflow-scroll',
    ]) {
      final chips = <Rect>[];
      for (final tag in [
        'alarm',
        'bookmark',
        'camera',
        'duration',
        'edit',
        'folder',
      ]) {
        final f = find.descendant(of: keyed(key), matching: find.text(tag));
        if (f.evaluate().isEmpty) continue;
        chips.add(
          tester.getRect(
            find.ancestor(of: f, matching: find.byType(SemiTag)).first,
          ),
        );
      }
      final plus = find.descendant(
        of: keyed(key),
        matching: find.textContaining('+'),
      );
      if (plus.evaluate().isNotEmpty) {
        chips.add(
          tester.getRect(
            find.ancestor(of: plus.first, matching: find.byType(SemiTag)).first,
          ),
        );
      }
      chips.sort((a, b) => a.left.compareTo(b.left));
      // 行内相邻 chip 的间隔全部相等（示例约定 8px —— 含 "+N" 指示器）。
      final gaps = <double>[
        for (var i = 1; i < chips.length; i++)
          chips[i].left - chips[i - 1].right,
      ];
      expect(gaps, isNotEmpty);
      for (final gap in gaps) {
        expect(gap, closeTo(8, 0.01), reason: '$key gaps: $gaps');
      }
    }
    expect(tester.takeException(), isNull);
  });
}
