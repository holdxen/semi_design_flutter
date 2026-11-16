import 'package:example/pages/backtop.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('backtop-status'),
  matching: find.textContaining(text),
);

/// BackTop 按钮内容（SemiBackTop.contentKey 是 ClipRect 度量锚点）。
Finder backTopOf(String demoKey) => find.descendant(
  of: keyed(demoKey),
  matching: find.byKey(SemiBackTop.contentKey),
);

double offsetOf(WidgetTester tester, String key) => tester
    .state<ScrollableState>(
      find.descendant(of: keyed(key), matching: find.byType(Scrollable)),
    )
    .position
    .pixels;

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: BackTopPage()));
  await tester.pumpAndSettle();
}

/// Drag [demoKey]'s scroller to [target] pixels (拖动经过 touch slop，落点以
/// offsetOf 断言)。
Future<void> scrollTo(
  WidgetTester tester,
  String demoKey,
  double target,
) async {
  final scrollable = find.descendant(
    of: keyed(demoKey),
    matching: find.byType(Scrollable),
  );
  await tester.ensureVisible(scrollable);
  await tester.pump(const Duration(milliseconds: 50));
  final current = offsetOf(tester, demoKey);
  await tester.drag(scrollable, Offset(0, current - target));
  await tester.pumpAndSettle();
  expect(offsetOf(tester, demoKey), moreOrLessEquals(target, epsilon: 40));
}

/// Tap [finder] until [done] holds. The one-shot retry absorbs the dropped hit
/// of docs/known_issues.md #1 without double-firing non-idempotent actions:
/// [done] is checked after each tap. [wait] lets the 450ms scroll animation
/// settle before the check.
Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 600),
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

void main() {
  testWidgets('page renders every demo section and survives a narrow scaled '
      'screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in ['基本用法', '自定义内容与主题偏移', '阈值与动画时长', 'RTL']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(keyed('backtop-status'), findsOneWidget);
  });

  testWidgets('basic demo: past 400 shows the default button, tap scrolls '
      'back and hides it', (tester) async {
    await start(tester);
    await scrollTo(tester, 'backtop-basic', 800);
    expect(backTopOf('backtop-basic'), findsOneWidget);
    // 缺省 renderDefault：IconButton theme="light" + IconChevronUp。
    final button = tester.widget<SemiButton>(
      find.descendant(
        of: backTopOf('backtop-basic'),
        matching: find.byType(SemiButton),
      ),
    );
    expect(button.variant, SemiButtonVariant.light);
    await tapUntil(
      tester,
      backTopOf('backtop-basic'),
      () => offsetOf(tester, 'backtop-basic') == 0,
    );
    expect(offsetOf(tester, 'backtop-basic'), 0);
    expect(backTopOf('backtop-basic'), findsNothing);
    expect(statusContaining('onClick 基本用法'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('threshold demo: visibilityHeight 100 shows before the basic '
      'threshold', (tester) async {
    await start(tester);
    // 250px：> 100（阈值 demo 现）但 < 400（基本 demo 不现）。
    await scrollTo(tester, 'backtop-threshold', 250);
    expect(backTopOf('backtop-threshold'), findsOneWidget);
    expect(backTopOf('backtop-basic'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom demo: children replaces the default button', (
    tester,
  ) async {
    await start(tester);
    await scrollTo(tester, 'backtop-custom', 800);
    final content = backTopOf('backtop-custom');
    expect(content, findsOneWidget);
    expect(
      find.descendant(of: content, matching: find.byType(SemiButton)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: content,
        matching: find.byWidgetPredicate(
          (w) => w is SemiIcon && w.data == SemiIcons.arrowUp,
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('rtl demo: button lands bottom-left (rtl.scss:7-8)', (
    tester,
  ) async {
    await start(tester);
    await scrollTo(tester, 'backtop-rtl', 800);
    final stack = tester.getRect(keyed('backtop-rtl'));
    final rect = tester.getRect(backTopOf('backtop-rtl'));
    // `right: auto; left: $spacing-backtop-right` → 左偏移 100。
    expect(rect.left, stack.left + 100);
    expect(tester.takeException(), isNull);
  });
}
