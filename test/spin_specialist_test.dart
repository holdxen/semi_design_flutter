import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/components/spin_svg.dart';

Widget host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

class Counter extends StatefulWidget {
  const Counter({super.key});
  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => count++),
    child: SizedBox(width: 90, height: 60, child: Text('$count')),
  );
}

void main() {
  test(
    'dedicated SVG preserves upstream geometry gradient and decodes',
    () async {
      expect(semiSpinSvg, contains('viewBox="0 0 36 36"'));
      expect(
        semiSpinSvg,
        contains(
          'M34,18 C34,9.163444 26.836556,2 18,2 C11.6597233,2 6.18078805,5.68784135 3.59122325,11.0354951',
        ),
      );
      expect(RegExp('<stop ').allMatches(semiSpinSvg).length, 3);
      for (final token in [
        'stop-opacity="0"',
        'stop-opacity="0.50"',
        '39.9430698%',
        'currentColor',
        'stroke-width="4"',
        'stroke-linecap="round"',
      ]) {
        expect(semiSpinSvg, contains(token));
      }
      expect(
        File('lib/src/components/spin_svg.dart').readAsStringSync(),
        contains('packages/semi-ui/spin/icon.tsx'),
      );
      final picture = await vg.loadPicture(SvgStringLoader(semiSpinSvg), null);
      expect(picture.size, const Size(36, 36));
      picture.picture.dispose();
      final themeSource = File('lib/src/theme/semi_spin_theme_data.dart')
          .readAsStringSync();
      for (final variable in [
        'color-spin-bg',
        'width-spin_small',
        'width-spin_middle',
        'width-spin_large',
        'opacity-spin_children',
        'animation_duration-spin_wrapper-spin',
        'animation_duration-spin_customChildren-spin',
      ]) {
        expect(themeSource, contains('\$$variable'));
      }
    },
  );
  testWidgets('RTL scaling finite and unbounded natural content layouts', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      for (final child in <Widget?>[
        null,
        const SizedBox(width: 73, height: 41),
      ]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: direction,
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Center(
                child: UnconstrainedBox(
                  child: SemiSpin(tip: const Text('Loading'), child: child),
                ),
              ),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(SemiSpin)),
          child == null ? const Size(20, 20) : const Size(73, 41),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });
  testWidgets(
    'loading live label unique child semantics retained and removed on stop',
    (tester) async {
      final handle = tester.ensureSemantics();

      Widget tree(bool spinning) => host(
        Center(
          child: SemiSpin(
            spinning: spinning,
            semanticsLabel: 'Loading record',
            child: Semantics(
              label: 'Record content',
              child: SizedBox(width: 80, height: 60),
            ),
          ),
        ),
      );
      await tester.pumpWidget(tree(true));
      expect(find.bySemanticsLabel('Loading record'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Loading record'))
            .getSemanticsData()
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      expect(find.bySemanticsLabel('Record content'), findsOneWidget);
      expect(find.bySemanticsLabel('spin'), findsNothing);
      await tester.pumpWidget(tree(false));
      expect(find.bySemanticsLabel('Loading record'), findsNothing);
      expect(find.bySemanticsLabel('Record content'), findsOneWidget);
      handle.dispose();
    },
  );
  testWidgets(
    'barrier blocks pointer but focus and keyboard remain operational',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var keys = 0;
      var taps = 0;
      await tester.pumpWidget(
        host(
          Center(
            child: SemiSpin(
              child: Focus(
                focusNode: focus,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) keys++;
                  return KeyEventResult.handled;
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                  child: const SizedBox(width: 100, height: 60),
                ),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(keys, 1);
      await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
      expect(taps, 0);
      expect(focus.hasFocus, isTrue);
    },
  );
  testWidgets(
    'capture retains unresolved patches with destination live theme',
    (tester) async {
      late CapturedThemes captured;
      late BuildContext destination;
      SemiResolvedSpinThemeData? resolved;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              destination = context;
              return SemiSpinTheme(
                data: const SemiSpinThemeData(smallSize: 19),
                child: Builder(
                  builder: (inner) {
                    captured = InheritedTheme.capture(
                      from: inner,
                      to: destination,
                    );
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(
        host(
          SemiTheme(
            data: const SemiThemeData.light(
              colors: SemiColors(colorPrimary: Color(0xff123456)),
            ),
            child: captured.wrap(
              Builder(
                builder: (context) {
                  resolved = SemiSpinTheme.resolve(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(resolved!.smallSize, 19);
      expect(resolved!.color, const Color(0xff123456));
    },
  );
  testWidgets(
    'delay cancellation starts a fresh cycle and waiting allows interaction preserving State',
    (tester) async {
      final key = GlobalKey<CounterState>();
      Widget tree(bool spinning) => host(
        Center(
          child: SemiSpin(
            spinning: spinning,
            delay: const Duration(seconds: 1),
            child: SemiSpin(spinning: false, child: Counter(key: key)),
          ),
        ),
      );
      await tester.pumpWidget(tree(true));
      final state = key.currentState;
      await tester.tap(find.byType(GestureDetector));
      expect(state!.count, 1);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(tree(false));
      await tester.pumpWidget(tree(true));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SemiIcon), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SemiIcon), findsOneWidget);
      await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
      expect(state.count, 1);
      await tester.pumpWidget(tree(false));
      expect(key.currentState, same(state));
      expect(find.text('1'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'nested outer loading shields inner custom indicator and inner content',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          Center(
            child: SemiSpin(
              child: SemiSpin(
                indicator: GestureDetector(
                  onTap: () => taps++,
                  child: const SizedBox(width: 20, height: 20),
                ),
                child: const SizedBox(width: 100, height: 80),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
      expect(taps, 0);
    },
  );
  testWidgets('negative const delay throws a runtime ArgumentError', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SemiSpin(delay: Duration(microseconds: -1))),
    );
    expect(tester.takeException(), isArgumentError);
  });
  test(
    'negative const theme durations throw without relying on assertions',
    () {
      for (final patch in [
        const SemiSpinThemeData(rotationDuration: Duration(microseconds: -1)),
        const SemiSpinThemeData(
          customIndicatorRotationDuration: Duration(microseconds: -1),
        ),
      ]) {
        expect(
          () => patch.resolve(const SemiThemeData.light()),
          throwsArgumentError,
        );
      }
    },
  );
}
