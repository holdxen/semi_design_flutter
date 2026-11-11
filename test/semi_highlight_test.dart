import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

List<TextSpan> spansOf(WidgetTester tester) {
  final text = tester.widget<Text>(find.byType(Text));
  return (text.textSpan! as TextSpan).children!.cast<TextSpan>();
}

Widget host(
  Widget child, {
  SemiThemeData theme = const SemiThemeData.light(),
}) => SemiTheme(
  data: theme,
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  test('all Sass defaults and live global references', () {
    const patch = SemiHighlightThemeData();
    const theme = SemiThemeData.light();
    final resolved = patch.resolve(theme);
    expect(resolved.colorHighlightTextDefault, theme.colors.colorHighlight);
    expect(resolved.colorHighlightTextBgDefault, theme.colors.colorHighlightBg);
    expect(resolved.fontHighlightTextFontWeight, FontWeight.w600);
    expect(theme.typography.fontWeightBold, FontWeight.w600);
    final updated = theme.copyWith(
      typography: theme.typography.copyWith(fontWeightBold: FontWeight.w900),
    );
    expect(patch.resolve(updated).fontHighlightTextFontWeight, FontWeight.w900);
    final dark = const SemiThemeData.dark();
    expect(
      patch.resolve(dark).colorHighlightTextDefault,
      dark.colors.colorHighlight,
    );
    expect(
      patch.resolve(dark).colorHighlightTextBgDefault,
      dark.colors.colorHighlightBg,
    );
  });
  test('all fields copy merge equality hash and resolution', () {
    const patch = SemiHighlightThemeData(
      colorHighlightTextDefault: Color(0xff000001),
      colorHighlightTextBgDefault: Color(0xff000002),
      fontHighlightTextFontWeight: FontWeight.w100,
    );
    expect(const SemiHighlightThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(null), patch);
    expect(patch.hashCode, patch.copyWith().hashCode);
    final resolved = patch.resolve(const SemiThemeData.dark());
    expect(resolved.colorHighlightTextDefault, patch.colorHighlightTextDefault);
    expect(
      resolved.colorHighlightTextBgDefault,
      patch.colorHighlightTextBgDefault,
    );
    expect(
      resolved.fontHighlightTextFontWeight,
      patch.fontHighlightTextFontWeight,
    );
    expect(
      const SemiComponentThemes().copyWith(highlight: patch).highlight,
      patch,
    );
  });
  testWidgets('text spans follow the strict style merge chain', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiHighlight(
          'Semi Design',
          searchWords: [
            SemiHighlightWord(
              'Semi',
              style: TextStyle(
                color: Color(0xffff0000),
                fontWeight: FontWeight.w200,
              ),
            ),
            SemiHighlightWord('Design'),
          ],
          highlightStyle: TextStyle(color: Color(0xff00ffff), fontSize: 30),
        ),
        theme: const SemiThemeData.light(
          components: SemiComponentThemes(
            highlight: SemiHighlightThemeData(
              colorHighlightTextDefault: Color(0xff0000ff),
              colorHighlightTextBgDefault: Color(0xff00ff00),
            ),
          ),
        ),
      ),
    );
    final spans = spansOf(tester);
    expect(spans.map((s) => s.text).toList(), ['Semi', ' ', 'Design']);
    final semi = spans[0], gap = spans[1], design = spans[2];
    // word.style > highlightStyle > theme defaults > base.
    expect(semi.style!.inherit, isFalse);
    expect(semi.style!.color, const Color(0xffff0000));
    expect(semi.style!.fontWeight, FontWeight.w200);
    expect(semi.style!.fontSize, 30);
    expect(semi.style!.backgroundColor, const Color(0xff00ff00));
    // highlightStyle > theme defaults where the word stays silent.
    expect(design.style!.inherit, isFalse);
    expect(design.style!.color, const Color(0xff00ffff));
    expect(design.style!.fontWeight, FontWeight.w600);
    expect(design.style!.backgroundColor, const Color(0xff00ff00));
    // Plain spans carry only the base style.
    expect(gap.style!.color, isNull);
    expect(gap.style!.backgroundColor, isNull);
    expect(gap.style!.fontWeight, isNull);
  });
  testWidgets('light and dark highlight colors come from theme colors', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      final theme = dark
          ? const SemiThemeData.dark()
          : const SemiThemeData.light();
      await tester.pumpWidget(
        host(
          const SemiHighlight('do it', searchWords: [SemiHighlightWord('do')]),
          theme: theme,
        ),
      );
      final semi = spansOf(tester).first;
      expect(semi.style!.color, theme.colors.colorHighlight);
      expect(semi.style!.backgroundColor, theme.colors.colorHighlightBg);
      expect(semi.style!.fontWeight, FontWeight.w600);
    }
  });
  testWidgets('application-level components.highlight overrides defaults', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiHighlight('do it', searchWords: [SemiHighlightWord('do')]),
        theme: const SemiThemeData.light(
          components: SemiComponentThemes(
            highlight: SemiHighlightThemeData(
              colorHighlightTextDefault: Color(0xff010203),
              colorHighlightTextBgDefault: Color(0xff040506),
              fontHighlightTextFontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
    final semi = spansOf(tester).first;
    expect(semi.style!.color, const Color(0xff010203));
    expect(semi.style!.backgroundColor, const Color(0xff040506));
    expect(semi.style!.fontWeight, FontWeight.w900);
  });
  testWidgets('nested local patches merge outer to inner', (tester) async {
    late SemiResolvedHighlightThemeData resolved;
    await tester.pumpWidget(
      host(
        SemiHighlightTheme(
          data: const SemiHighlightThemeData(
            colorHighlightTextDefault: Color(0xff112233),
            fontHighlightTextFontWeight: FontWeight.w100,
          ),
          child: SemiHighlightTheme(
            data: const SemiHighlightThemeData(
              fontHighlightTextFontWeight: FontWeight.w900,
            ),
            child: Builder(
              builder: (context) {
                resolved = SemiHighlightTheme.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    expect(resolved.colorHighlightTextDefault, const Color(0xff112233));
    expect(resolved.fontHighlightTextFontWeight, FontWeight.w900);
  });
  testWidgets('capture keeps local patches and rebinds destination globals', (
    tester,
  ) async {
    late CapturedThemes captured;
    await tester.pumpWidget(
      host(
        SemiHighlightTheme(
          data: const SemiHighlightThemeData(
            colorHighlightTextDefault: Color(0xff112233),
          ),
          child: SemiHighlightTheme(
            data: const SemiHighlightThemeData(
              fontHighlightTextFontWeight: FontWeight.w900,
            ),
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
    late Widget Function(Widget) wrap;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (outer) => SemiHighlightTheme(
            data: const SemiHighlightThemeData(
              colorHighlightTextDefault: Color(0xff112233),
            ),
            child: SemiHighlightTheme(
              data: const SemiHighlightThemeData(
                fontHighlightTextFontWeight: FontWeight.w900,
              ),
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
    for (final color in [const Color(0xffaabbcc), const Color(0xffddeeff)]) {
      await tester.pumpWidget(
        host(
          wrap(
            Builder(
              builder: (context) {
                final theme = SemiHighlightTheme.resolve(context);
                expect(
                  theme.colorHighlightTextDefault,
                  const Color(0xff112233),
                );
                expect(theme.fontHighlightTextFontWeight, FontWeight.w900);
                expect(theme.colorHighlightTextBgDefault, color);
                return const SizedBox();
              },
            ),
          ),
          theme: SemiThemeData.light(
            colors: SemiColors(colorHighlightBg: color),
          ),
        ),
      );
    }
  });
  testWidgets('same-mode theme updates notify dependents', (tester) async {
    var builds = 0;
    late SemiResolvedHighlightThemeData resolved;
    Widget tree(SemiHighlightThemeData data) => host(
      SemiHighlightTheme(
        data: data,
        child: Builder(
          builder: (context) {
            builds++;
            resolved = SemiHighlightTheme.resolve(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      tree(
        const SemiHighlightThemeData(
          fontHighlightTextFontWeight: FontWeight.w200,
        ),
      ),
    );
    expect(resolved.fontHighlightTextFontWeight, FontWeight.w200);
    final before = builds;
    await tester.pumpWidget(
      tree(
        const SemiHighlightThemeData(
          fontHighlightTextFontWeight: FontWeight.w900,
        ),
      ),
    );
    expect(builds, greaterThan(before));
    expect(resolved.fontHighlightTextFontWeight, FontWeight.w900);
  });
  testWidgets('maxLines overflow and constructor assertion', (tester) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: SizedBox(
            width: 100,
            child: SemiHighlight(
              'Semi Design keeps highlighting words across lines',
              searchWords: [SemiHighlightWord('highlighting')],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byType(RichText),
    );
    expect(paragraph.didExceedMaxLines, isTrue);
    expect(paragraph.size.width, lessThanOrEqualTo(100));
    expect(() => SemiHighlight('x', maxLines: 0), throwsAssertionError);
  });
  testWidgets('RTL text direction reaches the paragraph', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiHighlight(
          'Semi Design',
          searchWords: [SemiHighlightWord('Semi')],
          textDirection: TextDirection.rtl,
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byType(RichText),
    );
    expect(paragraph.textDirection, TextDirection.rtl);
  });
  testWidgets('text scaling scales rendered size', (tester) async {
    Future<double> renderedHeight(TextScaler scaler) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: scaler),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SemiHighlight(
                'Semi Design',
                searchWords: [SemiHighlightWord('Semi')],
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(RichText)).height;
    }

    final plain = await renderedHeight(TextScaler.noScaling);
    final scaled = await renderedHeight(const TextScaler.linear(2));
    expect(scaled, greaterThan(plain));
  });
  testWidgets('renders without Material and keeps semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SemiHighlight(
          'Semi Design',
          searchWords: [SemiHighlightWord('Semi')],
          semanticsLabel: 'Semi label',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Semi Design'), findsOneWidget);
    expect(find.bySemanticsLabel('Semi label'), findsOneWidget);
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xff000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        ),
        home: const Directionality(
          textDirection: TextDirection.ltr,
          child: SemiHighlight(
            'Semi Design',
            searchWords: [SemiHighlightWord('Semi')],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Semi Design'), findsOneWidget);
    semantics.dispose();
  });
}
