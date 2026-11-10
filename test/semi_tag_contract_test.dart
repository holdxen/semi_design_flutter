import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  SemiThemeData theme = const SemiThemeData.light(),
}) => SemiTheme(
  data: theme,
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);
dynamic painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .firstWhere(
      (w) =>
          w.painter != null &&
          w.painter.runtimeType.toString() == '_TagPainter',
    )
    .painter;
void main() {
  // Actual CustomPainter arguments, not merely resolved token data.
  for (final dark in [false, true]) {
    final theme = dark
        ? const SemiThemeData.dark()
        : const SemiThemeData.light();
    final p = theme.palette;
    final levels = <SemiTagColor, List<Color>>{
      SemiTagColor.amber: [
        p.amber4.toColor(),
        p.amber5.toColor(),
        p.amber8.toColor(),
      ],
      SemiTagColor.blue: [
        p.blue4.toColor(),
        p.blue5.toColor(),
        p.blue8.toColor(),
      ],
      SemiTagColor.cyan: [
        p.cyan4.toColor(),
        p.cyan5.toColor(),
        p.cyan8.toColor(),
      ],
      SemiTagColor.green: [
        p.green4.toColor(),
        p.green5.toColor(),
        p.green8.toColor(),
      ],
      SemiTagColor.grey: [
        p.grey4.toColor(),
        p.grey5.toColor(),
        p.grey8.toColor(),
      ],
      SemiTagColor.indigo: [
        p.indigo4.toColor(),
        p.indigo5.toColor(),
        p.indigo8.toColor(),
      ],
      SemiTagColor.lightBlue: [
        p.lightBlue4.toColor(),
        p.lightBlue5.toColor(),
        p.lightBlue8.toColor(),
      ],
      SemiTagColor.lightGreen: [
        p.lightGreen4.toColor(),
        p.lightGreen5.toColor(),
        p.lightGreen8.toColor(),
      ],
      SemiTagColor.lime: [
        p.lime4.toColor(),
        p.lime5.toColor(),
        p.lime8.toColor(),
      ],
      SemiTagColor.orange: [
        p.orange4.toColor(),
        p.orange5.toColor(),
        p.orange8.toColor(),
      ],
      SemiTagColor.pink: [
        p.pink4.toColor(),
        p.pink5.toColor(),
        p.pink8.toColor(),
      ],
      SemiTagColor.purple: [
        p.purple4.toColor(),
        p.purple5.toColor(),
        p.purple8.toColor(),
      ],
      SemiTagColor.red: [p.red4.toColor(), p.red5.toColor(), p.red8.toColor()],
      SemiTagColor.teal: [
        p.teal4.toColor(),
        p.teal5.toColor(),
        p.teal8.toColor(),
      ],
      SemiTagColor.violet: [
        p.violet4.toColor(),
        p.violet5.toColor(),
        p.violet8.toColor(),
      ],
      SemiTagColor.yellow: [
        p.yellow4.toColor(),
        p.yellow5.toColor(),
        p.yellow8.toColor(),
      ],
    };
    for (final color in SemiTagColor.values) {
      for (final type in SemiTagType.values) {
        testWidgets('paint $dark $color $type', (tester) async {
          await tester.pumpWidget(
            host(
              SemiTag('paint', color: color, type: type),
              theme: theme,
            ),
          );
          final dynamic paint = painter(tester);
          final text = tester.widget<Text>(find.text('paint'));
          if (color == SemiTagColor.white) {
            expect(paint.background, theme.colors.colorBg4);
            expect(paint.border, p.grey2.toColor(.7));
            expect(paint.width, 1);
            expect(text.style!.color, theme.colors.colorText0);
          } else {
            final colors = levels[color]!;
            expect(
              paint.background,
              type == SemiTagType.light
                  ? colors[1].withValues(alpha: .15)
                  : type == SemiTagType.solid
                  ? colors[1]
                  : const Color(0x00000000),
            );
            expect(
              paint.border,
              type == SemiTagType.ghost ? colors[0] : const Color(0x00000000),
            );
            expect(paint.width, type == SemiTagType.ghost ? 1 : 0);
            expect(
              text.style!.color,
              type == SemiTagType.solid
                  ? theme.colors.colorWhite
                  : type == SemiTagType.light
                  ? colors[2]
                  : colors[1],
            );
          }
        });
      }
    }
  }
  testWidgets('arbitrarily narrow multislot layouts do not overflow', (
    tester,
  ) async {
    for (final width in [0.0, 1.0, 8.0, 20.0, 45.0]) {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: width,
            child: const SemiTag(
              '中文🙂',
              closable: true,
              prefixIcon: SizedBox.square(dimension: 50),
              suffixIcon: SizedBox.square(dimension: 50),
              avatar: SizedBox.square(dimension: 20),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });
  testWidgets('controlled release and regain preserve latest visibility', (
    tester,
  ) async {
    const key = ValueKey('tag');
    await tester.pumpWidget(
      host(const SemiTag('switch', key: key, visible: false)),
    );
    await tester.pumpWidget(host(const SemiTag('switch', key: key)));
    expect(find.text('switch'), findsNothing);
    await tester.pumpWidget(
      host(const SemiTag('switch', key: key, visible: true, closable: true)),
    );
    await tester.pumpWidget(
      host(const SemiTag('switch', key: key, closable: true)),
    );
    expect(find.text('switch'), findsOneWidget);
    await tester.tap(find.byType(SemiIcon));
    await tester.pump();
    expect(find.text('switch'), findsNothing);
    await tester.pumpWidget(
      host(const SemiTag('switch', key: key, visible: true)),
    );
    expect(find.text('switch'), findsOneWidget);
  });
  testWidgets('callback can synchronously remove its own element', (
    tester,
  ) async {
    late StateSetter update;
    var show = true;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return show
                ? SemiTag(
                    'dispose',
                    closable: true,
                    onClose: (_) => update(() => show = false),
                  )
                : const SizedBox();
          },
        ),
      ),
    );
    await tester.tap(find.byType(SemiIcon));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SemiTag), findsNothing);
  });
  testWidgets('semantic close and outer tap are distinct actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var taps = 0, closes = 0;
    await tester.pumpWidget(
      host(
        SemiTag(
          'label',
          semanticsLabel: 'Outer',
          closeSemanticsLabel: 'Remove',
          closable: true,
          visible: true,
          onTap: () => taps++,
          onClose: (_) => closes++,
        ),
      ),
    );
    expect(find.bySemanticsLabel('Remove'), findsOneWidget);
    await tester.tap(find.byType(SemiIcon));
    await tester.pump();
    expect(closes, 1);
    expect(taps, 0);
    await tester.tap(find.text('label'));
    await tester.pump();
    expect(taps, 1);
    expect(closes, 1);
    semantics.dispose();
  });
  testWidgets('close hover and press use source colors', (tester) async {
    await tester.pumpWidget(
      host(const SemiTag('hover', closable: true, visible: true)),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(SemiIcon)));
    await tester.pump();
    expect(
      tester.widget<SemiIcon>(find.byType(SemiIcon)).color,
      const SemiThemeData.light().colors.colorText1,
    );
    await mouse.down(tester.getCenter(find.byType(SemiIcon)));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.widget<SemiIcon>(find.byType(SemiIcon)).color,
      const SemiThemeData.light().colors.colorText0,
    );
    await mouse.up();
    await mouse.removePointer();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  for (final type in SemiTagType.values) {
    for (final gradient in [false, true]) {
      testWidgets('AI white avatar border specificity $type $gradient', (
        tester,
      ) async {
        const theme = SemiThemeData.light();
        await tester.pumpWidget(
          host(
            SemiTag(
              'AI borders',
              colorful: true,
              gradient: gradient,
              color: SemiTagColor.white,
              type: type,
              avatar: const SizedBox(),
            ),
            theme: theme,
          ),
        );
        final dynamic paint = painter(tester);
        expect(paint.width, 1);
        expect(paint.border, theme.colors.colorBorder);
        expect(
          paint.borderGradient,
          gradient && type == SemiTagType.ghost
              ? theme.colors.colorAiGeneral
              : null,
        );
        expect(
          tester.widget<Text>(find.text('AI borders')).style!.color,
          type == SemiTagType.solid
              ? theme.colors.colorWhite
              : theme.colors.colorAiPurple,
        );
      });
    }
  }
}
