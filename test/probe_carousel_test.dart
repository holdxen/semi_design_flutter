import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: direction,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 600, height: 300, child: child),
        ),
      ),
    );

void main() {
  testWidgets('render + next', (tester) async {
    final changes = <List<int>>[];
    await tester.pumpWidget(host(SemiCarousel(
      autoPlay: false,
      speed: const Duration(milliseconds: 100),
      onChange: (i, p) => changes.add([i, p]),
      children: const [
        SizedBox(key: ValueKey('s1'), child: ColoredBox(color: Color(0xFF111111))),
        SizedBox(key: ValueKey('s2'), child: ColoredBox(color: Color(0xFF222222))),
        SizedBox(key: ValueKey('s3'), child: ColoredBox(color: Color(0xFF333333))),
      ],
    )));
    await tester.pump();
    expect(tester.takeException(), isNull);
    debugPrint('size=${tester.getSize(find.byType(SemiCarousel))}');
    await tester.tap(find.byKey(const ValueKey('carousel-arrow-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(const Duration(milliseconds: 60));
    debugPrint('changes=$changes');
    expect(changes, [[1, 0]]);
  });

  for (final type in SemiCarouselIndicatorType.values) {
    testWidgets('indicator $type', (tester) async {
      await tester.pumpWidget(host(SemiCarousel(
        autoPlay: false,
        indicatorType: type,
        children: const [Text('a'), Text('b'), Text('c')],
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey('carousel-indicator-$i')), findsOneWidget);
      }
    });
  }

  testWidgets('fade + rtl', (tester) async {
    await tester.pumpWidget(host(
      SemiCarousel(
        autoPlay: false,
        animation: SemiCarouselAnimation.fade,
        children: const [Text('a'), Text('b')],
      ),
      direction: TextDirection.rtl,
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('carousel-arrow-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}
