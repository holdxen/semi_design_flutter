import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);
void main() {
  test('seven defaults and override value semantics', () {
    const base = SemiSpinThemeData();
    final resolved = base.resolve(const SemiThemeData.light());
    expect(resolved.color, const SemiThemeData.light().colors.colorPrimary);
    expect(
      [
        resolved.smallSize,
        resolved.middleSize,
        resolved.largeSize,
        resolved.childrenOpacity,
      ],
      [14, 20, 32, .5],
    );
    expect(resolved.rotationDuration, const Duration(milliseconds: 600));
    expect(
      resolved.customIndicatorRotationDuration,
      const Duration(milliseconds: 1600),
    );
    const patch = SemiSpinThemeData(
      color: Color(0xff123456),
      smallSize: 1,
      middleSize: 2,
      largeSize: 3,
      childrenOpacity: .2,
      rotationDuration: Duration.zero,
      customIndicatorRotationDuration: Duration(seconds: 2),
    );
    expect(base.merge(patch), patch);
    expect(base.merge(patch).hashCode, patch.hashCode);
    expect(patch.copyWith(), patch);
    expect(patch.merge(null), patch);
    expect(() => SemiSpinThemeData(smallSize: -1), throwsAssertionError);
    expect(() => SemiSpinThemeData(childrenOpacity: 2), throwsAssertionError);
    expect(
      () =>
          SemiSpinThemeData(rotationDuration: const Duration(microseconds: -1))
              .resolve(const SemiThemeData.light()),
      throwsArgumentError,
    );
  });
  testWidgets('standalone placeholder and overflowing tip', (tester) async {
    await tester.pumpWidget(host(Center(child: SemiSpin(spinning: false))));
    expect(tester.getSize(find.byType(SemiSpin)), const Size(20, 20));
    await tester.pumpWidget(
      host(Center(child: SemiSpin(tip: Text('A long loading tip')))),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(SemiIcon), findsOneWidget);
  });
  testWidgets('delay rerenders changes zero cancellation and dispose', (
    tester,
  ) async {
    Widget spin({bool spinning = true, int delay = 1000, String tip = 'tip'}) =>
        host(
          Center(
            child: SemiSpin(
              spinning: spinning,
              delay: Duration(milliseconds: delay),
              tip: Text(tip),
            ),
          ),
        );
    await tester.pumpWidget(spin());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(spin(tip: 'changed'));
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.byType(SemiIcon), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(SemiIcon), findsOneWidget);
    await tester.pumpWidget(spin(delay: 2000));
    expect(find.byType(SemiIcon), findsOneWidget);
    await tester.pumpWidget(spin(spinning: false));
    expect(find.byType(SemiIcon), findsNothing);
    await tester.pumpWidget(spin());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(spin(delay: 2000));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(SemiIcon), findsNothing);
    await tester.pumpWidget(spin(delay: 0));
    expect(find.byType(SemiIcon), findsOneWidget);
    await tester.pumpWidget(spin(spinning: false));
    await tester.pumpWidget(spin());
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'content remains mounted and nested barrier blocks taps only while loading',
    (tester) async {
      var taps = 0;
      final key = GlobalKey();
      Widget tree(bool spinning) => host(
        Center(
          child: SemiSpin(
            spinning: spinning,
            child: SemiSpin(
              spinning: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: SizedBox(key: key, width: 100, height: 80),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(tree(false));
      final element = key.currentContext;
      await tester.tap(find.byType(GestureDetector));
      expect(taps, 1);
      await tester.pumpWidget(tree(true));
      expect(key.currentContext, same(element));
      expect(
        tester.widgetList<Opacity>(find.byType(Opacity)).first.opacity,
        .5,
      );
      await tester.tap(find.byKey(key), warnIfMissed: false);
      expect(taps, 1);
      await tester.pumpWidget(tree(false));
      await tester.tap(find.byType(GestureDetector));
      expect(taps, 2);
    },
  );
  testWidgets(
    'animation periods reduced motion ticker mode and dynamic duration',
    (tester) async {
      Widget tree({
        bool custom = false,
        bool enabled = true,
        bool reduced = false,
        Duration? duration,
      }) => host(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: TickerMode(
            enabled: enabled,
            child: SemiSpinTheme(
              data: SemiSpinThemeData(rotationDuration: duration),
              child: Center(
                child: SemiSpin(
                  indicator: custom
                      ? const SizedBox(width: 12, height: 12)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
      double turns() => tester
          .widget<RotationTransition>(find.byType(RotationTransition))
          .turns
          .value;
      await tester.pumpWidget(tree());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(turns(), closeTo(.5, .01));
      await tester.pumpWidget(tree(custom: true));
      await tester.pump();
      final start = turns();
      await tester.pump(const Duration(milliseconds: 800));
      expect((turns() - start) % 1, closeTo(.5, .01));
      await tester.pumpWidget(tree(enabled: false));
      expect(turns(), 0);
      await tester.pumpWidget(tree(reduced: true));
      expect(turns(), 0);
      await tester.pumpWidget(tree(duration: Duration.zero));
      await tester.pump(const Duration(seconds: 1));
      expect(turns(), 0);
      await tester.pumpWidget(tree(duration: const Duration(seconds: 2)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(turns(), closeTo(.5, .01));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('nested theme patches and live global color', (tester) async {
    SemiResolvedSpinThemeData? value;
    Widget tree(Color color) => host(
      SemiSpinTheme(
        data: const SemiSpinThemeData(smallSize: 17),
        child: SemiTheme(
          data: SemiThemeData.light(colors: SemiColors(colorPrimary: color)),
          child: SemiSpinTheme(
            data: const SemiSpinThemeData(largeSize: 41),
            child: Builder(
              builder: (context) {
                value = SemiSpinTheme.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(tree(const Color(0xff123456)));
    expect(value!.smallSize, 17);
    expect(value!.largeSize, 41);
    expect(value!.color, const Color(0xff123456));
    await tester.pumpWidget(tree(const Color(0xffabcdef)));
    expect(value!.color, const Color(0xffabcdef));
  });
}
