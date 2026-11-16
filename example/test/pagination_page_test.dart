import 'package:example/pages/pagination.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('pagination-status'),
  matching: find.textContaining(text),
);

Finder nameOf(String demoKey, String text) =>
    find.descendant(of: keyed(demoKey), matching: find.text(text));

/// Scoped root (the page hosts several SemiPagination instances sharing the
/// static keys — always resolve through the demo container).
Finder rootIn(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiPagination.rootKey),
);

Finder sizeChangerIn(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiPagination.sizeChangerKey),
);

Finder quickJumpIn(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiPagination.quickJumpInputKey),
);

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: keyed('pagination-status'),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .join();

int eventCount(WidgetTester tester, String exact) =>
    statusText(tester).split('；').where((e) => e == exact).length;

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 1400));
  await tester.pumpWidget(const SemiApp(home: PaginationPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Tap [finder] until [done] holds (the one-shot retry absorbs the dropped hit
/// of docs/known_issues.md #1 without double-firing non-idempotent actions).
Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 150),
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

/// One tap without retry — for negative assertions.
Future<void> tapOnce(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Overlay/panel pumping (hover tooltips run a 50ms enter delay).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 30));
  }
}

Color? itemBg(WidgetTester tester, Finder text) {
  final box = find
      .ancestor(of: text, matching: find.byType(AnimatedContainer))
      .first;
  final decoration =
      tester.widget<AnimatedContainer>(box).decoration as BoxDecoration?;
  return decoration?.color;
}

void main() {
  testWidgets('page renders every demo section and variant', (tester) async {
    await start(tester);
    for (final title in [
      '基础',
      '总页数 / 容量切换 / 快速跳转',
      'small 尺寸',
      '受控 currentPage',
      '禁用',
      '单页隐藏',
      '自定义 prevText / nextText 与 RTL',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'pagination-basic',
      'pagination-features',
      'pagination-prevent-page',
      'pagination-small',
      'pagination-small-plain',
      'pagination-controlled',
      'pagination-disabled',
      'pagination-hide-single',
      'pagination-hide-single-with-size',
      'pagination-custom-prev-next',
      'pagination-rtl',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic demo logs onPageChange before onChange and moves the '
      'selection', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      nameOf('pagination-basic', '3'),
      () => statusContaining('onChange 3/10').evaluate().isNotEmpty,
    );
    expect(statusContaining('onPageChange 3'), findsOneWidget);
    expect(statusContaining('onChange 3/10'), findsOneWidget);
    final status = statusText(tester);
    expect(
      status.indexOf('onPageChange 3'),
      lessThan(status.indexOf('onChange 3/10')),
    );
    final resolved = const SemiPaginationThemeData().resolve(
      const SemiThemeData.light(),
    );
    expect(
      itemBg(tester, nameOf('pagination-basic', '3')),
      resolved.colorPaginationItemBgSelected,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('truncation demos paint the 7-slot matrices', (tester) async {
    await start(tester);
    Finder demoText(String demoKey, String label) =>
        find.descendant(of: keyed(demoKey), matching: find.text(label));
    // 基础 demo（当前页 1）：[1,2,3,4,...,9,10]。
    expect(demoText('pagination-basic', '...'), findsOneWidget);
    expect(demoText('pagination-basic', '9'), findsOneWidget);
    // c=3（<4）：[1,2,3,4,...,9,10]——单省略号（右）。
    expect(demoText('pagination-truncate-3', '...'), findsOneWidget);
    // c=6（4<c<t-3）：[1,...,5,6,7,...,10]——双省略号。
    expect(demoText('pagination-truncate-6', '...'), findsNWidgets(2));
    // c=9（fallback）：[1,...,6,7,8,9,10]——单省略号（左）。
    expect(demoText('pagination-truncate-9', '...'), findsOneWidget);
    expect(demoText('pagination-truncate-9', '6'), findsOneWidget);
    expect(demoText('pagination-truncate-9', '10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('features demo: page tap, size changer and quick jump log the '
      'documented order', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      nameOf('pagination-features', '5'),
      () => statusContaining('onPageChange 5').evaluate().isNotEmpty,
    );
    expect(statusContaining('onChange 5/10'), findsOneWidget);

    // 容量切换 10 → 20：第 5 页首条 (5-1)*10+1 = 41 → ceil(41/20)=3。
    await tapUntil(
      tester,
      sizeChangerIn('pagination-features'),
      () => find.text('每页条数：20').evaluate().isNotEmpty,
    );
    await tester.ensureVisible(find.text('每页条数：20'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('每页条数：20'));
    await settle(tester);
    expect(statusContaining('onPageSizeChange 20'), findsOneWidget);
    expect(statusContaining('onPageChange 3'), findsOneWidget);
    expect(statusContaining('onChange 3/20'), findsOneWidget);

    // 快速跳转（Enter 提交，越界夹到总页数 15）。
    final input = find.descendant(
      of: quickJumpIn('pagination-features'),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(input);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(input, '999');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(statusContaining('onPageChange 15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preventPageChangeOnPageSizeChange logs size change only', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      sizeChangerIn('pagination-prevent-page'),
      () => find.text('每页条数：20').evaluate().isNotEmpty,
    );
    await tester.ensureVisible(find.text('每页条数：20'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('每页条数：20'));
    await settle(tester);
    expect(statusContaining('onPageSizeChange 20'), findsOneWidget);
    expect(statusContaining('onChange 4/20'), findsOneWidget);
    expect(statusContaining('onPageChange'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small demo hovers the summary into the all-pages popup', (
    tester,
  ) async {
    await start(tester);
    final summary = nameOf('pagination-small', '3/10');
    expect(summary, findsOneWidget);
    final gesture = await startMouse(tester);
    await tester.ensureVisible(summary);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(summary));
    await settle(tester);
    expect(find.byKey(SemiPagination.restListKey), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(SemiPagination.restListKey),
        matching: find.text('2'),
      ),
    );
    await tester.pumpAndSettle();
    expect(statusContaining('onPageChange 2'), findsOneWidget);
    expect(nameOf('pagination-small', '2/10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled demo follows props not taps', (tester) async {
    await start(tester);
    final resolved = const SemiPaginationThemeData().resolve(
      const SemiThemeData.light(),
    );
    expect(
      itemBg(tester, nameOf('pagination-controlled', '3')),
      resolved.colorPaginationItemBgSelected,
    );
    await tapOnce(tester, nameOf('pagination-controlled', '4'));
    expect(statusContaining('onPageChange 4（受控）'), findsOneWidget);
    // 渲染不跟随（仍选中 3）。
    expect(
      itemBg(tester, nameOf('pagination-controlled', '3')),
      resolved.colorPaginationItemBgSelected,
    );
    // 外部按钮改 props 才换页。
    await tapUntil(
      tester,
      find.text('跳到第 8 页'),
      () =>
          itemBg(tester, nameOf('pagination-controlled', '8')) ==
          resolved.colorPaginationItemBgSelected,
    );
    expect(
      itemBg(tester, nameOf('pagination-controlled', '8')),
      resolved.colorPaginationItemBgSelected,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled demo swallows taps', (tester) async {
    await start(tester);
    await tapOnce(tester, nameOf('pagination-disabled', '4'));
    expect(statusContaining('onPageChange'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hideOnSinglePage hides one page but yields to the size '
      'changer', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('单页隐藏'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(rootIn('pagination-hide-single'), findsNothing);
    expect(rootIn('pagination-hide-single-with-size'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom prev/next text and RTL chevron mirroring', (
    tester,
  ) async {
    await start(tester);
    expect(nameOf('pagination-custom-prev-next', '上一页'), findsOneWidget);
    expect(nameOf('pagination-custom-prev-next', '下一页'), findsOneWidget);
    final mirrored = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.descendant(
              of: keyed('pagination-rtl'),
              matching: find.byKey(SemiPagination.prevKey),
            ),
            matching: find.byType(Transform),
          ),
        )
        .where((t) => t.transform.storage[0] == -1);
    expect(mirrored, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
