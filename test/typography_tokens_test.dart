import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, SemiThemeData data) => Directionality(
  textDirection: TextDirection.ltr,
  child: SemiTheme(data: data, child: child),
);
TextStyle resolved(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).style!;

void main() {
  test('fontSizeSmall defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeSmall, 12.0);
    expect(const SemiThemeData.dark().typography.fontSizeSmall, 12.0);
    final direct = SemiTypographyTokens(fontSizeSmall: 15.0);
    final copied = base.typography.copyWith(fontSizeSmall: 15.0);
    expect(direct.fontSizeSmall, 15.0);
    expect(copied.fontSizeSmall, 15.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeRegular defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeRegular, 14.0);
    expect(const SemiThemeData.dark().typography.fontSizeRegular, 14.0);
    final direct = SemiTypographyTokens(fontSizeRegular: 17.0);
    final copied = base.typography.copyWith(fontSizeRegular: 17.0);
    expect(direct.fontSizeRegular, 17.0);
    expect(copied.fontSizeRegular, 17.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeHeading1 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeHeading1, 32.0);
    expect(const SemiThemeData.dark().typography.fontSizeHeading1, 32.0);
    final direct = SemiTypographyTokens(fontSizeHeading1: 33.0);
    final copied = base.typography.copyWith(fontSizeHeading1: 33.0);
    expect(direct.fontSizeHeading1, 33.0);
    expect(copied.fontSizeHeading1, 33.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeHeading2 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeHeading2, 28.0);
    expect(const SemiThemeData.dark().typography.fontSizeHeading2, 28.0);
    final direct = SemiTypographyTokens(fontSizeHeading2: 29.0);
    final copied = base.typography.copyWith(fontSizeHeading2: 29.0);
    expect(direct.fontSizeHeading2, 29.0);
    expect(copied.fontSizeHeading2, 29.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeHeading3 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeHeading3, 24.0);
    expect(const SemiThemeData.dark().typography.fontSizeHeading3, 24.0);
    final direct = SemiTypographyTokens(fontSizeHeading3: 25.0);
    final copied = base.typography.copyWith(fontSizeHeading3: 25.0);
    expect(direct.fontSizeHeading3, 25.0);
    expect(copied.fontSizeHeading3, 25.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeHeading4 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeHeading4, 20.0);
    expect(const SemiThemeData.dark().typography.fontSizeHeading4, 20.0);
    final direct = SemiTypographyTokens(fontSizeHeading4: 21.0);
    final copied = base.typography.copyWith(fontSizeHeading4: 21.0);
    expect(direct.fontSizeHeading4, 21.0);
    expect(copied.fontSizeHeading4, 21.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeHeading5 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeHeading5, 18.0);
    expect(const SemiThemeData.dark().typography.fontSizeHeading5, 18.0);
    final direct = SemiTypographyTokens(fontSizeHeading5: 19.0);
    final copied = base.typography.copyWith(fontSizeHeading5: 19.0);
    expect(direct.fontSizeHeading5, 19.0);
    expect(copied.fontSizeHeading5, 19.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontSizeHeading6 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontSizeHeading6, 16.0);
    expect(const SemiThemeData.dark().typography.fontSizeHeading6, 16.0);
    final direct = SemiTypographyTokens(fontSizeHeading6: 17.0);
    final copied = base.typography.copyWith(fontSizeHeading6: 17.0);
    expect(direct.fontSizeHeading6, 17.0);
    expect(copied.fontSizeHeading6, 17.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightSmall defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightSmall, 16.0);
    expect(const SemiThemeData.dark().typography.lineHeightSmall, 16.0);
    final direct = SemiTypographyTokens(lineHeightSmall: 19.0);
    final copied = base.typography.copyWith(lineHeightSmall: 19.0);
    expect(direct.lineHeightSmall, 19.0);
    expect(copied.lineHeightSmall, 19.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightRegular defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightRegular, 20.0);
    expect(const SemiThemeData.dark().typography.lineHeightRegular, 20.0);
    final direct = SemiTypographyTokens(lineHeightRegular: 23.0);
    final copied = base.typography.copyWith(lineHeightRegular: 23.0);
    expect(direct.lineHeightRegular, 23.0);
    expect(copied.lineHeightRegular, 23.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightHeading1 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightHeading1, 44.0);
    expect(const SemiThemeData.dark().typography.lineHeightHeading1, 44.0);
    final direct = SemiTypographyTokens(lineHeightHeading1: 45.0);
    final copied = base.typography.copyWith(lineHeightHeading1: 45.0);
    expect(direct.lineHeightHeading1, 45.0);
    expect(copied.lineHeightHeading1, 45.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightHeading2 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightHeading2, 40.0);
    expect(const SemiThemeData.dark().typography.lineHeightHeading2, 40.0);
    final direct = SemiTypographyTokens(lineHeightHeading2: 41.0);
    final copied = base.typography.copyWith(lineHeightHeading2: 41.0);
    expect(direct.lineHeightHeading2, 41.0);
    expect(copied.lineHeightHeading2, 41.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightHeading3 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightHeading3, 32.0);
    expect(const SemiThemeData.dark().typography.lineHeightHeading3, 32.0);
    final direct = SemiTypographyTokens(lineHeightHeading3: 33.0);
    final copied = base.typography.copyWith(lineHeightHeading3: 33.0);
    expect(direct.lineHeightHeading3, 33.0);
    expect(copied.lineHeightHeading3, 33.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightHeading4 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightHeading4, 28.0);
    expect(const SemiThemeData.dark().typography.lineHeightHeading4, 28.0);
    final direct = SemiTypographyTokens(lineHeightHeading4: 29.0);
    final copied = base.typography.copyWith(lineHeightHeading4: 29.0);
    expect(direct.lineHeightHeading4, 29.0);
    expect(copied.lineHeightHeading4, 29.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightHeading5 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightHeading5, 24.0);
    expect(const SemiThemeData.dark().typography.lineHeightHeading5, 24.0);
    final direct = SemiTypographyTokens(lineHeightHeading5: 25.0);
    final copied = base.typography.copyWith(lineHeightHeading5: 25.0);
    expect(direct.lineHeightHeading5, 25.0);
    expect(copied.lineHeightHeading5, 25.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('lineHeightHeading6 defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.lineHeightHeading6, 22.0);
    expect(const SemiThemeData.dark().typography.lineHeightHeading6, 22.0);
    final direct = SemiTypographyTokens(lineHeightHeading6: 23.0);
    final copied = base.typography.copyWith(lineHeightHeading6: 23.0);
    expect(direct.lineHeightHeading6, 23.0);
    expect(copied.lineHeightHeading6, 23.0);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontWeightLight defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontWeightLight, FontWeight.w200);
    expect(
      const SemiThemeData.dark().typography.fontWeightLight,
      FontWeight.w200,
    );
    final direct = SemiTypographyTokens(fontWeightLight: FontWeight.w900);
    final copied = base.typography.copyWith(fontWeightLight: FontWeight.w900);
    expect(direct.fontWeightLight, FontWeight.w900);
    expect(copied.fontWeightLight, FontWeight.w900);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontWeightRegular defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontWeightRegular, FontWeight.w400);
    expect(
      const SemiThemeData.dark().typography.fontWeightRegular,
      FontWeight.w400,
    );
    final direct = SemiTypographyTokens(fontWeightRegular: FontWeight.w900);
    final copied = base.typography.copyWith(fontWeightRegular: FontWeight.w900);
    expect(direct.fontWeightRegular, FontWeight.w900);
    expect(copied.fontWeightRegular, FontWeight.w900);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontWeightBold defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontWeightBold, FontWeight.w600);
    expect(
      const SemiThemeData.dark().typography.fontWeightBold,
      FontWeight.w600,
    );
    final direct = SemiTypographyTokens(fontWeightBold: FontWeight.w900);
    final copied = base.typography.copyWith(fontWeightBold: FontWeight.w900);
    expect(direct.fontWeightBold, FontWeight.w900);
    expect(copied.fontWeightBold, FontWeight.w900);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontFamily defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontFamily, 'Inter');
    expect(const SemiThemeData.dark().typography.fontFamily, 'Inter');
    final direct = SemiTypographyTokens(fontFamily: 'Custom');
    final copied = base.typography.copyWith(fontFamily: 'Custom');
    expect(direct.fontFamily, 'Custom');
    expect(copied.fontFamily, 'Custom');
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  test('fontFamilyFallback defaults, constructor, copy and equality', () {
    const base = SemiThemeData.light();
    expect(base.typography.fontFamilyFallback, const [
      '-apple-system',
      'BlinkMacSystemFont',
      'PingFang SC',
      'Hiragino Sans GB',
      'Microsoft YaHei',
      'Segoe UI',
      'Helvetica Neue',
      'Helvetica',
      'Arial',
      'sans-serif',
    ]);
    expect(const SemiThemeData.dark().typography.fontFamilyFallback, const [
      '-apple-system',
      'BlinkMacSystemFont',
      'PingFang SC',
      'Hiragino Sans GB',
      'Microsoft YaHei',
      'Segoe UI',
      'Helvetica Neue',
      'Helvetica',
      'Arial',
      'sans-serif',
    ]);
    final direct = SemiTypographyTokens(fontFamilyFallback: const ['Custom']);
    final copied = base.typography.copyWith(
      fontFamilyFallback: const ['Custom'],
    );
    expect(direct.fontFamilyFallback, const ['Custom']);
    expect(copied.fontFamilyFallback, const ['Custom']);
    expect(direct, copied);
    expect(direct.hashCode, copied.hashCode);
    expect(copied, isNot(base.typography));
    expect(
      base.copyWith(typography: copied).copyWith(dark: true).typography,
      copied,
    );
  });

  testWidgets(
    'all heading levels use overridden theme metrics even with regular weight',
    (tester) async {
      final t = SemiTypographyTokens(
        fontSizeHeading1: 41,
        fontSizeHeading2: 37,
        fontSizeHeading3: 33,
        fontSizeHeading4: 29,
        fontSizeHeading5: 25,
        fontSizeHeading6: 21,
        lineHeightHeading1: 60,
        lineHeightHeading2: 56,
        lineHeightHeading3: 52,
        lineHeightHeading4: 48,
        lineHeightHeading5: 44,
        lineHeightHeading6: 40,
        fontWeightBold: FontWeight.w800,
      );
      for (var h = 1; h <= 6; h++) {
        await tester.pumpWidget(
          host(
            SemiTitle('title', heading: h),
            SemiThemeData.light(typography: t),
          ),
        );
        expect(resolved(tester).fontSize, 45 - 4 * h);
        expect(resolved(tester).height, (64 - 4 * h) / (45 - 4 * h));
        expect(resolved(tester).fontWeight, FontWeight.w800);
        await tester.pumpWidget(
          host(
            SemiTitle('title', heading: h, weight: FontWeight.normal),
            SemiThemeData.light(typography: t),
          ),
        );
        expect(resolved(tester).fontSize, 45 - 4 * h);
        expect(resolved(tester).height, (64 - 4 * h) / (45 - 4 * h));
        expect(resolved(tester).fontWeight, FontWeight.normal);
      }
    },
  );

  test('font fallback is defensively immutable and nullable family retains on copy', () {
    final input = ['A', 'B'];
    final t = SemiTypographyTokens(fontFamily: null, fontFamilyFallback: input);
    input.add('C');
    expect(t.fontFamilyFallback, ['A', 'B']);
    expect(() => t.fontFamilyFallback.add('C'), throwsUnsupportedError);
    expect(t.copyWith(fontFamily: null).fontFamily, isNull);
    final copied = t.copyWith();
    expect(copied, t);
    expect(copied.hashCode, t.hashCode);
    final named = t.copyWith(fontFamily: 'Custom');
    expect(named.copyWith(fontFamily: null).fontFamily, 'Custom');
  });

  testWidgets('theme fonts, independent size and height, explicit priority', (
    tester,
  ) async {
    final t = SemiTypographyTokens(
      fontFamily: 'Custom',
      fontFamilyFallback: ['Fallback'],
      fontSizeRegular: 25,
      lineHeightRegular: 30,
      fontWeightRegular: FontWeight.w300,
      fontWeightBold: FontWeight.w800,
    );
    final theme = SemiThemeData.light(typography: t);
    await tester.pumpWidget(host(const SemiText('text'), theme));
    expect(resolved(tester).fontSize, 25);
    expect(resolved(tester).height, 30 / 25);
    expect(resolved(tester).fontWeight, FontWeight.w300);
    expect(resolved(tester).fontFamily, 'Custom');
    expect(resolved(tester).fontFamilyFallback, ['Fallback']);
    await tester.pumpWidget(host(const SemiText('text', strong: true), theme));
    expect(resolved(tester).fontWeight, FontWeight.w800);
    await tester.pumpWidget(
      host(
        const SemiText(
          'text',
          strong: true,
          weight: FontWeight.w500,
          style: TextStyle(fontWeight: FontWeight.w900, height: 3),
        ),
        theme,
      ),
    );
    expect(resolved(tester).fontWeight, FontWeight.w900);
    expect(resolved(tester).height, 3);
    await tester.pumpWidget(
      host(const SemiText('text', weight: FontWeight.w500), theme),
    );
    expect(resolved(tester).fontWeight, FontWeight.w500);
    await tester.pumpWidget(
      host(
        const SemiText('text'),
        theme.copyWith(typography: t.copyWith(fontSizeRegular: 10)),
      ),
    );
    expect(resolved(tester).height, 30 / 10);
  });

  testWidgets('inherit retains DefaultTextStyle family size and height', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Inherited',
            fontFamilyFallback: ['Ancestor'],
            fontSize: 27,
            height: 2,
          ),
          child: SemiText('text', size: SemiTextSize.inherit),
        ),
        SemiThemeData.light(
          typography: SemiTypographyTokens(fontFamily: 'Theme'),
        ),
      ),
    );
    final s = resolved(tester);
    expect(s.fontFamily, 'Inherited');
    expect(s.fontFamilyFallback, ['Ancestor']);
    expect(s.fontSize, 27);
    expect(s.height, 2);
  });

  testWidgets(
    'same brightness typography notifies constant child and dark preserves overrides',
    (tester) async {
      const child = SemiText('text');
      final base = SemiThemeData.light(
        typography: SemiTypographyTokens(fontSizeRegular: 17),
      );
      await tester.pumpWidget(host(child, base));
      expect(resolved(tester).fontSize, 17);
      final next = base.copyWith(
        typography: base.typography.copyWith(fontSizeRegular: 21),
      );
      expect(next, isNot(base));
      await tester.pumpWidget(host(child, next));
      expect(resolved(tester).fontSize, 21);
      final dark = next.copyWith(dark: true);
      expect(dark.typography, next.typography);
      await tester.pumpWidget(host(child, dark));
      expect(resolved(tester).fontSize, 21);
      expect(dark.copyWith(dark: false), next);
    },
  );

  testWidgets('local theme derives parent typography', (tester) async {
    final parent = SemiThemeData.light(
      typography: SemiTypographyTokens(
        fontSizeRegular: 19,
        fontFamily: 'Parent',
      ),
    );
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            final theme = SemiTheme.of(context);
            return SemiTheme(
              data: theme.copyWith(
                typography: theme.typography.copyWith(lineHeightRegular: 38),
              ),
              child: const SemiText('local'),
            );
          },
        ),
        parent,
      ),
    );
    expect(resolved(tester).fontSize, 19);
    expect(resolved(tester).height, 2);
    expect(resolved(tester).fontFamily, 'Parent');
  });
}
