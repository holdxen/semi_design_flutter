import 'package:example/pages/carousel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder inDemo(String key, Finder matching) =>
    find.descendant(of: keyed(key), matching: matching);

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: keyed('carousel-status'),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .join();

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 3200));
  await tester.pumpWidget(const SemiApp(home: CarouselPage()));
  await tester.pump(const Duration(milliseconds: 60));
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

void main() {
  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in [
      '基础（slide + 自动播放）',
      '切换动画（fade）',
      '指示器类型',
      '指示器位置与主题色',
      '箭头',
      '控制器',
      'RTL',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);
    }
    expect(keyed('carousel-basic'), findsOneWidget);
    expect(keyed('carousel-fade'), findsOneWidget);
    expect(keyed('carousel-dot-small'), findsOneWidget);
    expect(keyed('carousel-line-medium'), findsOneWidget);
    expect(keyed('carousel-position-center'), findsOneWidget);
    expect(keyed('carousel-rtl'), findsOneWidget);
    expect(tester.getSize(keyed('carousel-basic')), const Size(640, 200));
  });

  testWidgets('fade demo swaps in the custom arrow icons', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('carousel-fade'));
    await tester.pump(const Duration(milliseconds: 60));
    expect(
      inDemo(
        'carousel-fade',
        find.byWidgetPredicate(
          (widget) => widget is SemiIcon && widget.data == SemiIcons.arrowRight,
        ),
      ),
      findsWidgets,
    );
    expect(
      inDemo(
        'carousel-fade',
        find.byWidgetPredicate(
          (widget) => widget is SemiIcon && widget.data == SemiIcons.arrowLeft,
        ),
      ),
      findsWidgets,
    );
  });

  testWidgets('controller buttons drive next/goto/prev', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('carousel-controller'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(keyed('carousel-next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(statusText(tester), contains('controller 0 -> 1'));
    await tester.tap(keyed('carousel-goto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(statusText(tester), contains('controller 1 -> 2'));
    await tester.tap(keyed('carousel-prev'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(statusText(tester), contains('controller 2 -> 1'));
  });

  testWidgets('clicking a columnar indicator selects that slide', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('carousel-controller'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(
      inDemo(
        'carousel-controller',
        find.byKey(const ValueKey('carousel-indicator-2')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(statusText(tester), contains('controller 0 -> 2'));
  });

  testWidgets('hover arrows reveal on pointer enter', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('carousel-arrows'));
    await tester.pump(const Duration(milliseconds: 60));
    final arrow = inDemo(
      'carousel-arrows',
      find.byKey(const ValueKey('carousel-arrow-next')),
    );
    final opacity = find.descendant(of: arrow, matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(opacity.first).opacity, 0);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(keyed('carousel-arrows')));
    await settle(tester);
    expect(tester.widget<Opacity>(opacity.first).opacity, 1);
  });

  testWidgets('RTL demo swaps arrow sides', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('carousel-rtl'));
    await tester.pump(const Duration(milliseconds: 60));
    final prev = tester.getCenter(
      inDemo('carousel-rtl', find.byKey(const ValueKey('carousel-arrow-prev'))),
    );
    final next = tester.getCenter(
      inDemo('carousel-rtl', find.byKey(const ValueKey('carousel-arrow-next'))),
    );
    expect(prev.dx, greaterThan(next.dx));
    expect(
      Directionality.of(tester.element(keyed('carousel-rtl'))),
      TextDirection.rtl,
    );
  });
}
