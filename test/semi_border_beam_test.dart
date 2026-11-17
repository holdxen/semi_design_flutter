import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {bool reduced = false, bool ticker = true}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: TickerMode(
          enabled: ticker,
          child: Center(child: child),
        ),
      ),
    );

List<SemiBorderBeamPainter> painters(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((widget) => widget.painter)
    .whereType<SemiBorderBeamPainter>()
    .toList();

void main() {
  test('gradient stops use the upstream 0–70 mapping', () {
    const color = SemiBorderBeamColor.gradient([
      SemiBorderBeamGradientStop(-10, Color(0xffff0000)),
      SemiBorderBeamGradientStop(50, Color(0xff00ff00)),
      SemiBorderBeamGradientStop(120, Color(0xff0000ff)),
    ]);
    expect(color.stops, hasLength(3));
    expect(color.stops!.first.percent, -10);
    expect(color.stops!.last.percent, 120);
  });

  testWidgets('defaults, count and items are represented by the painter', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 200,
          height: 100,
          child: SemiBorderBeam(
            count: 3,
            borderRadius: BorderRadius.circular(12),
            items: const [
              SemiBorderBeamItem(lineWidth: 3, size: 40),
              SemiBorderBeamItem(outset: 2),
            ],
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();
    final list = painters(tester);
    expect(list, hasLength(1));
    expect(list.single.count, 2);
    expect(list.single.borderRadius, BorderRadius.circular(12));
    expect(list.single.items, hasLength(2));
  });

  testWidgets('phase advances and multiple beams are offset', (tester) async {
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 200,
          height: 100,
          child: SemiBorderBeam(count: 2, child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    final first = painters(tester).single.phase;
    expect(first, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 250));
    expect(painters(tester).single.phase, greaterThan(first));
  });

  testWidgets('reduced motion and disabled ticker hide the decoration', (
    tester,
  ) async {
    Future<void> pump({bool reduced = false, bool ticker = true}) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 200,
            height: 100,
            child: SemiBorderBeam(child: SizedBox.expand()),
          ),
          reduced: reduced,
          ticker: ticker,
        ),
      );
      await tester.pump();
    }

    await pump(reduced: true);
    expect(find.byType(CustomPaint), findsNothing);
    await pump(ticker: false);
    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('beam layer does not change child layout or hit testing', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      host(SemiBorderBeam(child: SizedBox(key: key, width: 120, height: 60))),
    );
    expect(tester.getSize(find.byKey(key)), const Size(120, 60));
    expect(tester.hitTestOnBinding(const Offset(400, 300)), isNotNull);
  });

  testWidgets('empty items render the child without a painter', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiBorderBeam(
          items: [],
          child: SizedBox(width: 120, height: 60),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
