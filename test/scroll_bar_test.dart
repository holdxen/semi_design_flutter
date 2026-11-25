import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('Semi defaults resolve from live theme colors', () {
    const patch = SemiScrollBarThemeData();
    final light = const SemiThemeData.light();
    final resolved = patch.resolve(light);
    expect(resolved.thickness, 8);
    expect(resolved.radius, const Radius.circular(6));
    expect(resolved.thumbColor, light.colors.colorFill2);
    expect(resolved.thumbHoverColor, light.colors.colorFill1);
    expect(resolved.minThumbLength, 18);
    expect(resolved.crossAxisMargin, 0);
    expect(resolved.mainAxisMargin, 0);
    expect(resolved.fadeDuration, const Duration(seconds: 1));
    expect(resolved.timeToFade, Duration.zero);

    final dark = const SemiThemeData.dark();
    final darkResolved = patch.resolve(dark);
    expect(darkResolved.thumbColor, dark.colors.colorFill2);
    expect(darkResolved.thumbHoverColor, dark.colors.colorFill1);
    expect(darkResolved.thumbColor, isNot(resolved.thumbColor));
  });

  test('all fields copy merge equality hash and resolution', () {
    const patch = SemiScrollBarThemeData(
      thickness: 4,
      radius: Radius.circular(2),
      thumbColor: Color(0x11000000),
      thumbHoverColor: Color(0x22000000),
      minThumbLength: 10,
      crossAxisMargin: 1,
      mainAxisMargin: 2,
      fadeDuration: Duration(milliseconds: 100),
      timeToFade: Duration(milliseconds: 50),
    );
    final copied = const SemiScrollBarThemeData().merge(patch);
    expect(copied, patch);
    expect(copied.hashCode, patch.hashCode);
    expect(patch.copyWith(), patch);
    expect(patch.merge(null), patch);
    expect(patch == const SemiScrollBarThemeData(), isFalse);

    final resolved = patch.resolve(const SemiThemeData.dark());
    expect(resolved.thickness, 4);
    expect(resolved.radius, const Radius.circular(2));
    expect(resolved.thumbColor, patch.thumbColor);
    expect(resolved.thumbHoverColor, patch.thumbHoverColor);
    expect(resolved.minThumbLength, 10);
    expect(resolved.crossAxisMargin, 1);
    expect(resolved.mainAxisMargin, 2);
    expect(resolved.fadeDuration, const Duration(milliseconds: 100));
    expect(resolved.timeToFade, const Duration(milliseconds: 50));
    expect(
      const SemiComponentThemes().copyWith(scrollBar: patch).scrollBar,
      patch,
    );
  });

  testWidgets('nested patches across global boundaries update live', (
    tester,
  ) async {
    late SemiResolvedScrollBarThemeData resolved;
    Widget tree(double thickness) => SemiTheme(
      data: const SemiThemeData.light(),
      child: SemiScrollBarTheme(
        data: SemiScrollBarThemeData(thickness: thickness),
        child: SemiTheme(
          data: const SemiThemeData.dark(),
          child: SemiScrollBarTheme(
            data: const SemiScrollBarThemeData(minThumbLength: 33),
            child: Builder(
              builder: (context) {
                resolved = SemiScrollBarTheme.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(tree(2));
    expect(resolved.thickness, 2);
    expect(resolved.minThumbLength, 33);
    expect(resolved.thumbColor, const SemiThemeData.dark().colors.colorFill2);
    await tester.pumpWidget(tree(3));
    expect(resolved.thickness, 3);
  });

  testWidgets('hover reveals the thumb and thumb hover changes color', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SemiTheme(
          data: const SemiThemeData.light(),
          child: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: SemiScrollBar(
                controller: controller,
                child: ListView.builder(
                  controller: controller,
                  itemCount: 30,
                  itemBuilder: (_, index) =>
                      SizedBox(height: 40, child: Text('$index')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final barFinder = find.byWidgetPredicate(
      (widget) => widget is RawScrollbar,
    );
    RawScrollbar bar() => tester.widget<RawScrollbar>(barFinder);
    ScrollbarPainter painter() {
      final paint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.foregroundPainter is ScrollbarPainter,
        ),
      );
      return paint.foregroundPainter! as ScrollbarPainter;
    }

    final light = const SemiThemeData.light();
    expect(bar().thumbVisibility, isFalse);
    expect(bar().thickness, 8);
    expect(bar().radius, const Radius.circular(6));
    expect(bar().thumbColor, light.colors.colorFill2);
    expect(bar().fadeDuration, const Duration(seconds: 1));
    expect(bar().timeToFade, Duration.zero);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(SemiScrollBar)));
    await tester.pumpAndSettle();
    expect(bar().thumbVisibility, isTrue);
    expect(painter().color, light.colors.colorFill2);

    final rect = tester.getRect(find.byType(SemiScrollBar));
    await mouse.moveTo(Offset(rect.right - 4, rect.top + 10));
    await tester.pumpAndSettle();
    expect(painter().color, light.colors.colorFill1);

    await mouse.moveTo(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(bar().thumbVisibility, isFalse);
    await mouse.removePointer();
  });

  testWidgets('widget overrides theme and honors always-visible', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SemiTheme(
          data: const SemiThemeData.dark(),
          child: SemiScrollBarTheme(
            data: const SemiScrollBarThemeData(thickness: 5),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: SemiScrollBar(
                  controller: controller,
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(2),
                  child: ListView.builder(
                    controller: controller,
                    itemCount: 30,
                    itemBuilder: (_, index) =>
                        SizedBox(height: 40, child: Text('$index')),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bar = tester.widget<RawScrollbar>(
      find.byWidgetPredicate((widget) => widget is RawScrollbar),
    );
    expect(bar.thumbVisibility, isTrue);
    expect(bar.thickness, 4);
    expect(bar.radius, const Radius.circular(2));
    expect(bar.thumbColor, const SemiThemeData.dark().colors.colorFill2);
  });
}
