import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('nested capture keeps patches and rebinds destination globals', (
    tester,
  ) async {
    late CapturedThemes captured;
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.light(),
        child: SemiTagTheme(
          data: const SemiTagThemeData(widthTagBorder: 3),
          child: SemiTagTheme(
            data: const SemiTagThemeData(heightTagSmall: 23),
            child: Builder(
              builder: (context) {
                captured = InheritedTheme.capture(from: context, to: null);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    // Capture only local Tag themes, excluding the source SemiTheme itself.
    late Widget Function(Widget) wrap;
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.light(),
        child: Builder(
          builder: (outer) => SemiTagTheme(
            data: const SemiTagThemeData(widthTagBorder: 3),
            child: SemiTagTheme(
              data: const SemiTagThemeData(heightTagSmall: 23),
              child: Builder(
                builder: (inner) {
                  captured = InheritedTheme.capture(from: inner, to: outer);
                  wrap = captured.wrap;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
    for (final color in [const Color(0xff112233), const Color(0xff556677)]) {
      await tester.pumpWidget(
        SemiTheme(
          data: SemiThemeData.light(colors: SemiColors(colorBg4: color)),
          child: wrap(
            Builder(
              builder: (context) {
                final t = SemiTagTheme.resolve(context);
                expect(t.widthTagBorder, 3);
                expect(t.heightTagSmall, 23);
                expect(t.colorTagWhiteBgDefault, color);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    }
  });
  test('default references and avatar border dependency remain live', () {
    const color = Color(0xff123456);
    const theme = SemiThemeData.dark(colors: SemiColors(colorBg4: color));
    final resolved = const SemiTagThemeData(widthTagBorder: 7).resolve(theme);
    expect(resolved.colorTagWhiteBgDefault, color);
    expect(resolved.widthTagAvatarBorder, 7);
    expect(
      const SemiTagThemeData().resolve(theme).colorTagWhiteBorderDefault,
      theme.palette.grey2.toColor(.7),
    );
    expect(
      const SemiTagThemeData().resolve(theme).colorTagColorfulSolidGradientBg,
      theme.colors.colorAiGeneral,
    );
  });
}
