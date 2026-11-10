import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'semi_progress_test.dart' show host, painter;

void main() {
  testWidgets('capture retains two live local patches but uses target global', (
    tester,
  ) async {
    late CapturedThemes capture;
    Widget source(double height) => host(
      SemiTheme(
        data: const SemiThemeData.light(
          components: SemiComponentThemes(
            progress: SemiProgressThemeData(verticalWidth: 19),
          ),
        ),
        child: SemiProgressTheme(
          data: SemiProgressThemeData(horizontalHeight: height),
          child: SemiProgressTheme(
            data: const SemiProgressThemeData(lineTextMinWidth: 61),
            child: Builder(
              builder: (context) {
                BuildContext? boundary;
                context.visitAncestorElements((element) {
                  if (element.widget is SemiTheme) {
                    boundary = element;
                    return false;
                  }
                  return true;
                });
                capture = InheritedTheme.capture(from: context, to: boundary);
                return const SemiProgress(width: 200);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(source(8));
    await tester.pumpWidget(source(12));
    await tester.pumpWidget(
      host(
        SemiTheme(
          data: const SemiThemeData.dark(
            components: SemiComponentThemes(
              progress: SemiProgressThemeData(verticalWidth: 7),
            ),
          ),
          child: capture.wrap(const SemiProgress(width: 200)),
        ),
      ),
    );
    final context = tester.element(find.byType(SemiProgress));
    final resolved = SemiProgressTheme.resolve(context);
    expect(resolved.horizontalHeight, 12);
    expect(resolved.lineTextMinWidth, 61);
    expect(resolved.verticalWidth, 7);
    expect(
      resolved.strokeColor,
      const SemiThemeData.dark().colors.colorSuccess,
    );
  });

  testWidgets(
    'dynamic duration and zero stop geometry, numeric replacement uses old prop',
    (tester) async {
      Widget build(double value, Duration duration) => host(
        SemiProgressTheme(
          data: SemiProgressThemeData(transitionDuration: duration),
          child: SemiProgress(width: 200, percent: value, showInfo: true),
        ),
      );
      await tester.pumpWidget(build(0, const Duration(milliseconds: 300)));
      await tester.pumpWidget(build(90, const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 100));
      final before = painter(tester).fraction;
      await tester.pumpWidget(build(90, const Duration(milliseconds: 600)));
      expect(painter(tester).fraction, closeTo(before, 1e-8));
      await tester.pump(const Duration(milliseconds: 300));
      expect(painter(tester).fraction, greaterThan(before));
      expect(painter(tester).fraction, lessThan(.9));
      await tester.pumpWidget(build(30, Duration.zero));
      expect(painter(tester).fraction, .3);
      expect(find.text('90%'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('60%'), findsOneWidget);
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  for (final reduced in [true, false]) {
    testWidgets(
      'active determinate stops with ${reduced ? "reduced animations" : "TickerMode"}',
      (tester) async {
        Widget build(double percent, {bool stop = false}) => host(
          SemiProgress(width: 200, percent: percent, showInfo: true),
          reduced: reduced && stop,
          ticker: reduced || !stop,
        );
        await tester.pumpWidget(build(0));
        await tester.pumpWidget(build(100));
        await tester.pump(const Duration(milliseconds: 80));
        await tester.pumpWidget(build(100, stop: true));
        expect(painter(tester).fraction, 1);
        expect(find.text('100%'), findsOneWidget);
        expect(tester.hasRunningAnimations, isFalse);
        await tester.pumpWidget(build(100));
        expect(tester.hasRunningAnimations, isFalse);
        await tester.pumpWidget(host(const SizedBox()));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
