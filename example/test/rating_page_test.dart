import 'package:example/pages/rating.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiRating rating(WidgetTester tester, String key) =>
    tester.widget<SemiRating>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: RatingPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  // See docs/known_issues.md #1 — one dropped hit test can follow
  // focus-driven rebuilds at a scroll viewport edge.
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Tap the star at [index] within the rating named by [key]; [fraction] is the
/// horizontal position inside the star (0 = left edge, 0.75 = right half).
Future<void> tapStar(
  WidgetTester tester,
  String key,
  int index, {
  required int count,
  required double starSize,
  double fraction = 0.5,
}) async {
  final rect = tester.getRect(keyed(key));
  final stride = count > 1 ? (rect.width - starSize) / (count - 1) : 0.0;
  // See docs/known_issues.md #1 — absorb the one dropped hit test.
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tapAt(
    Offset(rect.left + index * stride + starSize * fraction, rect.center.dy),
  );
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
    for (final title in ['基本用法', '半星', '只读', '点击清除', '文案展现', '自定义']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('clicking stars sets values and hovering previews', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('rating-basic'));
    await tester.pump(const Duration(milliseconds: 50));
    // The demo starts at 5; clicking star 5 would clear it (allowClear).
    await tapStar(tester, 'rating-basic', 3, count: 5, starSize: 24);
    expect(find.text('值：4'), findsOneWidget);
    await tapStar(tester, 'rating-basic', 2, count: 5, starSize: 24);
    expect(find.text('值：3'), findsOneWidget);
    // Hover preview over star 1.
    final rect = tester.getRect(keyed('rating-basic'));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset(rect.left + 12, rect.center.dy));
    await tester.pump();
    expect(find.text('悬浮：1'), findsOneWidget);
    await gesture.removePointer();
    await tester.pump();
    expect(find.text('离开评分条'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('half stars resolve left and right halves', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('rating-half'));
    await tester.pump(const Duration(milliseconds: 50));
    await tapStar(
      tester,
      'rating-half',
      2,
      count: 5,
      starSize: 24,
      fraction: 0.25,
    );
    expect(find.text('值：2.5'), findsOneWidget);
    await tapStar(
      tester,
      'rating-half',
      3,
      count: 5,
      starSize: 24,
      fraction: 0.75,
    );
    expect(find.text('值：4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('allowClear toggles the clear-on-reclick behaviour', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('rating-clear'));
    await tester.pump(const Duration(milliseconds: 50));
    // Re-clicking the current value (3) clears to 0.
    await tapStar(tester, 'rating-clear', 2, count: 5, starSize: 24);
    expect(find.text('值：0'), findsOneWidget);
    // allowClear=false keeps the value on a re-click.
    await tapStar(tester, 'rating-no-clear', 2, count: 5, starSize: 24);
    expect(find.text('值：3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard arrows move the controlled text demo', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('rating-text'));
    await tester.pump(const Duration(milliseconds: 50));
    await tapStar(tester, 'rating-text', 0, count: 5, starSize: 24);
    expect(find.textContaining('terrible'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.textContaining('bad'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(find.textContaining('normal'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(find.textContaining('bad'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom characters, numeric sizes and count match the demos', (
    tester,
  ) async {
    await start(tester);
    expect(rating(tester, 'rating-custom-big').size, 48.0);
    expect(rating(tester, 'rating-custom-text').size, 18.0);
    expect(rating(tester, 'rating-custom-big').allowHalf, isTrue);
    expect(rating(tester, 'rating-count10').count, 10);
    expect(rating(tester, 'rating-small').size, SemiRatingSize.small);
    expect(rating(tester, 'rating-readonly').disabled, isTrue);
    expect(rating(tester, 'rating-no-clear').allowClear, isFalse);
    // Custom heart characters render in place of stars.
    expect(
      find.descendant(
        of: keyed('rating-custom-heart'),
        matching: find.byWidgetPredicate(
          (w) => w is SemiIcon && w.data == SemiIcons.likeHeart,
        ),
      ),
      findsWidgets,
    );
    // The custom text character.
    expect(
      find.descendant(
        of: keyed('rating-custom-text'),
        matching: find.text('赞'),
      ),
      findsNWidgets(10), // 5 stars × (bottom + clipped top layer)
    );
    expect(tester.takeException(), isNull);
  });
}
