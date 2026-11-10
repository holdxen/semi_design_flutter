import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {bool dark = false}) => SemiTheme(
  data: dark ? const SemiThemeData.dark() : const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);
void main() {
  for (final dark in [false, true]) {
    for (final color in SemiTagColor.values) {
      for (final type in SemiTagType.values) {
        testWidgets('$dark $color $type', (tester) async {
          await tester.pumpWidget(
            host(
              SemiTag('中文 emoji🙂', color: color, type: type),
              dark: dark,
            ),
          );
          expect(find.text('中文 emoji🙂'), findsOneWidget);
          expect(tester.getSize(find.byType(SemiTag)).height, 20);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final type in SemiTagType.values) {
    for (final gradient in [false, true]) {
      testWidgets('AI $type gradient $gradient', (tester) async {
        await tester.pumpWidget(
          host(
            SemiTag(
              'AI',
              colorful: true,
              gradient: gradient,
              type: type,
              prefixIcon: const SizedBox.square(dimension: 12),
              suffixIcon: const SizedBox.square(dimension: 12),
              avatar: const Text('A'),
              avatarShape: SemiTagShape.circle,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          find.byType(ShaderMask),
          gradient && type != SemiTagType.solid ? findsOneWidget : findsNothing,
        );
      });
    }
  }
  testWidgets('uncontrolled close does not bubble and exposes key', (
    tester,
  ) async {
    var taps = 0;
    SemiTagCloseEvent? event;
    await tester.pumpWidget(
      host(
        SemiTag(
          'tag',
          closable: true,
          tagKey: 42,
          onTap: () => taps++,
          onClose: (e) => event = e,
        ),
      ),
    );
    await tester.tap(find.byType(SemiIcon));
    await tester.pump();
    expect(event!.text, 'tag');
    expect(event!.tagKey, 42);
    expect(taps, 0);
    expect(find.text('tag'), findsNothing);
  });
  testWidgets('synchronous cancellation and controlled visibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiTag('cancel', closable: true, onClose: (e) => e.preventDefault()),
      ),
    );
    await tester.tap(find.byType(SemiIcon));
    await tester.pump();
    expect(find.text('cancel'), findsOneWidget);
    await tester.pumpWidget(
      host(const SemiTag('controlled', closable: true, visible: true)),
    );
    await tester.tap(find.byType(SemiIcon));
    await tester.pump();
    expect(find.text('controlled'), findsOneWidget);
  });
  testWidgets('keyboard enter delete escape', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(SemiTag('keys', closable: true, onTap: () => taps++)),
    );
    Focus.of(tester.element(find.text('keys'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    Focus.of(tester.element(find.text('keys'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();
    expect(find.text('keys'), findsNothing);
  });
  for (final size in SemiTagSize.values) {
    for (final shape in SemiTagShape.values) {
      testWidgets('$size $shape scaled bounded and unbounded', (tester) async {
        for (final width in [60.0, double.infinity]) {
          await tester.pumpWidget(
            host(
              MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(3)),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SizedBox(
                    width: width.isFinite ? width : null,
                    child: SemiTag('中文 long🙂 text', size: size, shape: shape),
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(SemiTag)).height,
            size == SemiTagSize.large ? 24 : 20,
          );
        }
      });
    }
  }
}
