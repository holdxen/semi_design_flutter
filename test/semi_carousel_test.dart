// Behavior matrix for SemiCarousel plus coverage for the 40 Sass declarations
// (34 FIELDS + 6 MOTION + 0 INTERNAL) — the 25 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. 0 死变量.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
  double height = 300,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: direction,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        height: height,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
  double height = 300,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await tester.pumpWidget(
    host(child, direction: direction, width: width, height: height),
  );
  await tester.pump();
}

BoxDecoration indicatorDecoration(WidgetTester tester, int index) =>
    tester
            .widget<AnimatedContainer>(
              find.descendant(
                of: find.byKey(ValueKey('carousel-indicator-$index')),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .decoration
        as BoxDecoration;

double slideDx(WidgetTester tester, String key) => tester
    .widget<FractionalTranslation>(
      find
          .ancestor(
            of: find.byKey(ValueKey(key)),
            matching: find.byType(FractionalTranslation),
          )
          .first,
    )
    .translation
    .dx;

Opacity arrowOpacity(WidgetTester tester, String side) =>
    tester.widget<Opacity>(
      find
          .descendant(
            of: find.byKey(ValueKey('carousel-arrow-$side')),
            matching: find.byType(Opacity),
          )
          .first,
    );

const slides = [
  SizedBox(
    key: ValueKey('s1'),
    child: ColoredBox(color: Color(0xFF111111)),
  ),
  SizedBox(
    key: ValueKey('s2'),
    child: ColoredBox(color: Color(0xFF222222)),
  ),
  SizedBox(
    key: ValueKey('s3'),
    child: ColoredBox(color: Color(0xFF333333)),
  ),
];

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiCarouselThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedCarouselThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-carousel_indicator_theme_dark-bg-default: rgba(var(--semi-black), .5)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemeDarkBgDefault: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemeDarkBgDefault,
    (t) => t.palette.black.toColor(0.5),
  ),
  (
    r'$color-carousel_indicator_theme_dark-bg-hover: rgba(var(--semi-black), .7)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemeDarkBgHover: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemeDarkBgHover,
    (t) => t.palette.black.toColor(0.7),
  ),
  (
    r'$color-carousel_indicator_theme_dark-bg-active: rgba(var(--semi-black), 1)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemeDarkBgActive: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemeDarkBgActive,
    (t) => t.palette.black.toColor(1),
  ),
  (
    r'$color-carousel_indicator_theme_primary-bg-default: rgba(var(--semi-blue-6), .4)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemePrimaryBgDefault: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemePrimaryBgDefault,
    (t) => t.palette.blue6.toColor(0.4),
  ),
  (
    r'$color-carousel_indicator_theme_primary-bg-hover: rgba(var(--semi-blue-6), .7)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemePrimaryBgHover: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemePrimaryBgHover,
    (t) => t.palette.blue6.toColor(0.7),
  ),
  (
    r'$color-carousel_indicator_theme_primary-bg-active: rgba(var(--semi-blue-6), 1)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemePrimaryBgActive: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemePrimaryBgActive,
    (t) => t.palette.blue6.toColor(1),
  ),
  (
    r'$color-carousel_indicator_theme_light-bg-default: rgba(var(--semi-white), .4)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemeLightBgDefault: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemeLightBgDefault,
    (t) => t.palette.white.toColor(0.4),
  ),
  (
    r'$color-carousel_indicator_theme_light-bg-hover: rgba(var(--semi-white), .7)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemeLightBgHover: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemeLightBgHover,
    (t) => t.palette.white.toColor(0.7),
  ),
  (
    r'$color-carousel_indicator_theme_light-bg-active: rgba(var(--semi-white), 1)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselIndicatorThemeLightBgActive: v as Color,
    ),
    (d) => d.colorCarouselIndicatorThemeLightBgActive,
    (t) => t.palette.white.toColor(1),
  ),
  (
    r'$color-carousel_arrow_theme_dark-bg-default: rgba(var(--semi-black), .5)',
    _c,
    (v) =>
        SemiCarouselThemeData(colorCarouselArrowThemeDarkBgDefault: v as Color),
    (d) => d.colorCarouselArrowThemeDarkBgDefault,
    (t) => t.palette.black.toColor(0.5),
  ),
  (
    r'$color-carousel_arrow_theme_dark-bg-hover: rgba(var(--semi-black), 1)',
    _c,
    (v) =>
        SemiCarouselThemeData(colorCarouselArrowThemeDarkBgHover: v as Color),
    (d) => d.colorCarouselArrowThemeDarkBgHover,
    (t) => t.palette.black.toColor(1),
  ),
  (
    r'$color-carousel_arrow_theme_primary-bg-default:  rgba(var(--semi-blue-6), .4)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselArrowThemePrimaryBgDefault: v as Color,
    ),
    (d) => d.colorCarouselArrowThemePrimaryBgDefault,
    (t) => t.palette.blue6.toColor(0.4),
  ),
  (
    r'$color-carousel_arrow_theme_primary-bg-hover:  rgba(var(--semi-blue-6), 1)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselArrowThemePrimaryBgHover: v as Color,
    ),
    (d) => d.colorCarouselArrowThemePrimaryBgHover,
    (t) => t.palette.blue6.toColor(1),
  ),
  (
    r'$color-carousel_arrow_theme_light-bg-default: rgba(var(--semi-white), .4)',
    _c,
    (v) => SemiCarouselThemeData(
      colorCarouselArrowThemeLightBgDefault: v as Color,
    ),
    (d) => d.colorCarouselArrowThemeLightBgDefault,
    (t) => t.palette.white.toColor(0.4),
  ),
  (
    r'$color-carousel_arrow_theme_light-bg-hover: rgba(var(--semi-white), 1)',
    _c,
    (v) =>
        SemiCarouselThemeData(colorCarouselArrowThemeLightBgHover: v as Color),
    (d) => d.colorCarouselArrowThemeLightBgHover,
    (t) => t.palette.white.toColor(1),
  ),
  (
    r'$width-carousel_indicator_line: 240px',
    77.5,
    (v) => SemiCarouselThemeData(widthCarouselIndicatorLine: v as double),
    (d) => d.widthCarouselIndicatorLine,
    (t) => 240.0,
  ),
  (
    r'$width-carousel_indicator_columnar_small: 4px',
    77.5,
    (v) =>
        SemiCarouselThemeData(widthCarouselIndicatorColumnarSmall: v as double),
    (d) => d.widthCarouselIndicatorColumnarSmall,
    (t) => 4.0,
  ),
  (
    r'$width-carousel_indicator_columnar_medium: 6px',
    77.5,
    (v) => SemiCarouselThemeData(
      widthCarouselIndicatorColumnarMedium: v as double,
    ),
    (d) => d.widthCarouselIndicatorColumnarMedium,
    (t) => 6.0,
  ),
  (
    r'$width-carousel_indicator_dot_small:8px',
    77.5,
    (v) => SemiCarouselThemeData(widthCarouselIndicatorDotSmall: v as double),
    (d) => d.widthCarouselIndicatorDotSmall,
    (t) => 8.0,
  ),
  (
    r'$width-carousel_indicator_dot_medium: 12px',
    77.5,
    (v) => SemiCarouselThemeData(widthCarouselIndicatorDotMedium: v as double),
    (d) => d.widthCarouselIndicatorDotMedium,
    (t) => 12.0,
  ),
  (
    r'$width-carousel_arrow: 32px',
    77.5,
    (v) => SemiCarouselThemeData(widthCarouselArrow: v as double),
    (d) => d.widthCarouselArrow,
    (t) => 32.0,
  ),
  (
    r'$height-carousel_indicator_columnar_small_default: 12px',
    77.5,
    (v) => SemiCarouselThemeData(
      heightCarouselIndicatorColumnarSmallDefault: v as double,
    ),
    (d) => d.heightCarouselIndicatorColumnarSmallDefault,
    (t) => 12.0,
  ),
  (
    r'$height-carousel_indicator_columnar_small_active: 20px',
    77.5,
    (v) => SemiCarouselThemeData(
      heightCarouselIndicatorColumnarSmallActive: v as double,
    ),
    (d) => d.heightCarouselIndicatorColumnarSmallActive,
    (t) => 20.0,
  ),
  (
    r'$height-carousel_indicator_columnar_medium_default: 20px',
    77.5,
    (v) => SemiCarouselThemeData(
      heightCarouselIndicatorColumnarMediumDefault: v as double,
    ),
    (d) => d.heightCarouselIndicatorColumnarMediumDefault,
    (t) => 20.0,
  ),
  (
    r'$height-carousel_indicator_columnar_medium_active: 28px',
    77.5,
    (v) => SemiCarouselThemeData(
      heightCarouselIndicatorColumnarMediumActive: v as double,
    ),
    (d) => d.heightCarouselIndicatorColumnarMediumActive,
    (t) => 28.0,
  ),
  (
    r'$height-carousel_indicator_line_small: 4px',
    77.5,
    (v) => SemiCarouselThemeData(heightCarouselIndicatorLineSmall: v as double),
    (d) => d.heightCarouselIndicatorLineSmall,
    (t) => 4.0,
  ),
  (
    r'$height-carousel_indicator_line_medium: 6px',
    77.5,
    (v) =>
        SemiCarouselThemeData(heightCarouselIndicatorLineMedium: v as double),
    (d) => d.heightCarouselIndicatorLineMedium,
    (t) => 6.0,
  ),
  (
    r'$radius-carousel_indicator_dot: 50%',
    77.5,
    (v) => SemiCarouselThemeData(radiusCarouselIndicatorDot: v as double),
    (d) => d.radiusCarouselIndicatorDot,
    (t) => 50.0,
  ),
  (
    r'$spacing-carousel_indicator-padding: 32px',
    77.5,
    (v) => SemiCarouselThemeData(spacingCarouselIndicatorPadding: v as double),
    (d) => d.spacingCarouselIndicatorPadding,
    (t) => 32.0,
  ),
  (
    r'$spacing-carousel_indicator_columnar-marginX: 4px',
    77.5,
    (v) => SemiCarouselThemeData(
      spacingCarouselIndicatorColumnarMarginX: v as double,
    ),
    (d) => d.spacingCarouselIndicatorColumnarMarginX,
    (t) => 4.0,
  ),
  (
    r'$spacing-carousel_indicator_line-marginX: 4px',
    77.5,
    (v) =>
        SemiCarouselThemeData(spacingCarouselIndicatorLineMarginX: v as double),
    (d) => d.spacingCarouselIndicatorLineMarginX,
    (t) => 4.0,
  ),
  (
    r'$spacing-carousel_indicator_dot-marginX: 8px',
    77.5,
    (v) =>
        SemiCarouselThemeData(spacingCarouselIndicatorDotMarginX: v as double),
    (d) => d.spacingCarouselIndicatorDotMarginX,
    (t) => 8.0,
  ),
  (
    r'$spacing-carousel_arrow-left: 20px',
    77.5,
    (v) => SemiCarouselThemeData(spacingCarouselArrowLeft: v as double),
    (d) => d.spacingCarouselArrowLeft,
    (t) => 20.0,
  ),
  (
    r'$spacing-carousel_arrow-right: 20px',
    77.5,
    (v) => SemiCarouselThemeData(spacingCarouselArrowRight: v as double),
    (d) => d.spacingCarouselArrowRight,
    (t) => 20.0,
  ),
  (
    r'$transition_duration_carousel_indicator-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiCarouselThemeData(
      transitionDurationCarouselIndicatorBg: v as Duration,
    ),
    (d) => d.transitionDurationCarouselIndicatorBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function_carousel_indicator-bg: var(--semi-transition_function-easeOut)',
    Curves.easeInCubic,
    (v) => SemiCarouselThemeData(
      transitionFunctionCarouselIndicatorBg: v as Curve,
    ),
    (d) => d.transitionFunctionCarouselIndicatorBg,
    (t) => Curves.easeOut,
  ),
  (
    r'$transition_delay_carousel_indicator-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiCarouselThemeData(
      transitionDelayCarouselIndicatorBg: v as Duration,
    ),
    (d) => d.transitionDelayCarouselIndicatorBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration_carousel_arrow-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) =>
        SemiCarouselThemeData(transitionDurationCarouselArrowBg: v as Duration),
    (d) => d.transitionDurationCarouselArrowBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_funciton_carousel_arrow-bg: var(--semi-transition_function-easeOut)',
    Curves.easeInCubic,
    (v) => SemiCarouselThemeData(transitionFuncitonCarouselArrowBg: v as Curve),
    (d) => d.transitionFuncitonCarouselArrowBg,
    (t) => Curves.easeOut,
  ),
  (
    r'$transition_delay_carousel_arrow-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiCarouselThemeData(transitionDelayCarouselArrowBg: v as Duration),
    (d) => d.transitionDelayCarouselArrowBg,
    (t) => Duration.zero,
  ),
];

void main() {
  group('theme fields (40 = 34 FIELDS + 6 MOTION + 0 INTERNAL)', () {
    test('40 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(40));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiCarouselThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiCarouselThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiCarouselThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_carousel_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(40));
      expect(
        source,
        contains('packages/semi-foundation/carousel/variables.scss'),
      );
      expect(
        source,
        contains('packages/semi-foundation/carousel/animation.scss'),
      );
      expect(source, contains('Generated by tool/generate_carousel.py'));
      expect(source, contains('funciton'));
      expect(source, isNot(contains('# dead variable (上游未消费)')));
    });

    test('the 25 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_carousel.dart')
          .readAsStringSync();
      const anchors = <String>[
        'DEFAULT_ACTIVE_INDEX: 0',
        'DEFAULT_INTERVAL: 2000',
        'DEFAULT_SPEED: 300',
        "ANIMATION_MAP: ['slide', 'fade']",
        "TYPE_MAP: ['columnar', 'line', 'dot']",
        "THEME_MAP: ['dark', 'primary', 'light']",
        "POSITION_MAP: ['left', 'center', 'right']",
        "ARROW_MAP: ['always', 'hover']",
        "SIZE: ['small', 'medium']",
        "TRIGGER: ['click', 'hover']",
        'translateX(100%)',
        'translateX(-100%)',
        "transitionTimingFunction: 'ease'",
        'visibility: hidden',
        'IconChevronLeft',
        'IconChevronRight',
        'aria-label="Previous index"',
        'aria-label="Next index"',
        'scaleX(-1)',
        'opacity: 0',
        '&:hover',
        'debounce(..., 400)',
        ':not(:last-child)',
        'children.length > 1',
        'interval + speed',
      ];
      expect(anchors, hasLength(25));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 15 Color + 19 double + 4 Duration + 2 Curve = 40', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 15);
      expect(counts['double'], 19);
      expect(counts['Duration'], 4);
      expect(counts['Cubic'], 2);
    });

    test('0 dead variables: every field name appears in the widget source', () {
      final widgetSource = File('lib/src/components/semi_carousel.dart')
          .readAsStringSync();
      for (final (sass, _, _, _, _) in fields) {
        final name = sass.split(':').first.substring(1);
        var camel = '';
        var upper = false;
        for (final char in name.split('')) {
          if (char == '-' || char == '_') {
            upper = true;
          } else if (upper) {
            camel += char.toUpperCase();
            upper = false;
          } else {
            camel += char;
          }
        }
        expect(widgetSource, contains(camel), reason: camel);
      }
      final docs = File('docs/semi_carousel.md').readAsStringSync();
      expect(docs, contains('40 = 34 FIELDS + 6 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.carousel, const SemiCarouselThemeData());
      expect(
        themes.copyWith(
          carousel: const SemiCarouselThemeData(widthCarouselArrow: 40),
        ),
        const SemiComponentThemes(
          carousel: SemiCarouselThemeData(widthCarouselArrow: 40),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('renders only the active slide initially', (tester) async {
      await pumpHost(
        tester,
        const SemiCarousel(autoPlay: false, children: slides),
      );
      expect(find.byKey(const ValueKey('s1')), findsOneWidget);
      expect(find.byKey(const ValueKey('s2')), findsNothing);
      expect(find.byKey(const ValueKey('s3')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('next slides to the following child and reports change', (
      tester,
    ) async {
      final changes = <List<int>>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          speed: const Duration(milliseconds: 200),
          children: slides,
          onChange: (index, previous) => changes.add([index, previous]),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('carousel-arrow-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(changes, [
        [1, 0],
      ]);
      expect(find.byKey(const ValueKey('s1')), findsOneWidget);
      expect(find.byKey(const ValueKey('s2')), findsOneWidget);
      // 非 reverse：新项从 +100% 滑入、旧项滑向 -100%。
      expect(slideDx(tester, 's2'), greaterThan(0));
      expect(slideDx(tester, 's1'), lessThan(0));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const ValueKey('s1')), findsNothing);
      expect(find.byKey(const ValueKey('s2')), findsOneWidget);
    });

    testWidgets('prev wraps to the last child and slides in reverse', (
      tester,
    ) async {
      final changes = <List<int>>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          speed: const Duration(milliseconds: 200),
          children: slides,
          onChange: (index, previous) => changes.add([index, previous]),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('carousel-arrow-prev')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(changes, [
        [2, 0],
      ]);
      // reverse：新项从 -100% 滑入（dx < 0），旧项滑出到 +100%（dx > 0）。
      expect(slideDx(tester, 's3'), lessThan(0));
      expect(slideDx(tester, 's1'), greaterThan(0));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const ValueKey('s3')), findsOneWidget);
    });

    testWidgets('slideDirection right inverts the travel direction', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          speed: Duration(milliseconds: 200),
          slideDirection: SemiCarouselDirection.right,
          children: slides,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('carousel-arrow-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // slideDirection: right 把方向取反：新项从 -100% 滑入。
      expect(slideDx(tester, 's2'), lessThan(0));
      expect(slideDx(tester, 's1'), greaterThan(0));
    });

    testWidgets('fade crosses the outgoing and incoming opacities', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          speed: Duration(milliseconds: 200),
          animation: SemiCarouselAnimation.fade,
          children: slides,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('carousel-arrow-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final opacities = tester
          .widgetList<Opacity>(
            find.descendant(
              of: find.byType(SemiCarousel),
              matching: find.byType(Opacity),
            ),
          )
          .map((widget) => widget.opacity)
          .toList();
      expect(opacities.where((value) => value > 0 && value < 1), hasLength(2));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const ValueKey('s1')), findsNothing);
    });

    testWidgets('indicator click goes to the index', (tester) async {
      final changes = <List<int>>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          children: slides,
          onChange: (index, previous) => changes.add([index, previous]),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('carousel-indicator-2')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(changes, [
        [2, 0],
      ]);
      expect(find.byKey(const ValueKey('s3')), findsOneWidget);
    });

    testWidgets('hover trigger switches on pointer enter', (tester) async {
      final changes = <int>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          indicatorTrigger: SemiCarouselTrigger.hover,
          children: slides,
          onChange: (index, _) => changes.add(index),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(
        tester.getCenter(find.byKey(const ValueKey('carousel-indicator-1'))),
      );
      await tester.pump();
      expect(changes, [1]);
    });

    testWidgets('controlled activeIndex only reports changes', (tester) async {
      final changes = <List<int>>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          activeIndex: 0,
          children: slides,
          onChange: (index, previous) => changes.add([index, previous]),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('carousel-arrow-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(changes, [
        [1, 0],
      ]);
      expect(find.byKey(const ValueKey('s1')), findsOneWidget);
      expect(find.byKey(const ValueKey('s2')), findsNothing);

      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          activeIndex: 1,
          children: slides,
          onChange: (index, previous) => changes.add([index, previous]),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('s2')), findsOneWidget);
    });

    testWidgets('dot indicator sizes and theme colors come from the theme', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiCarousel(autoPlay: false, children: slides),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('carousel-indicator-0'))),
        const Size(8, 8),
      );
      expect(
        indicatorDecoration(tester, 0).color,
        light.palette.white.toColor(1),
      );
      expect(
        indicatorDecoration(tester, 1).color,
        light.palette.white.toColor(0.4),
      );

      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          indicatorSize: SemiCarouselSize.medium,
          theme: SemiCarouselThemeColor.primary,
          children: slides,
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('carousel-indicator-0'))),
        const Size(12, 12),
      );
      expect(
        indicatorDecoration(tester, 0).color,
        light.palette.blue6.toColor(1),
      );
      expect(
        indicatorDecoration(tester, 1).color,
        light.palette.blue6.toColor(0.4),
      );
    });

    testWidgets('line and columnar indicators take their Sass geometry', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          indicatorType: SemiCarouselIndicatorType.line,
          children: slides,
        ),
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('carousel-indicator-0')))
            .height,
        4,
      );
      final lineWidth = tester
          .getSize(find.byKey(const ValueKey('carousel-indicator-0')))
          .width;
      expect((lineWidth - 232 / 3).abs(), lessThan(1));

      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          indicatorType: SemiCarouselIndicatorType.columnar,
          children: slides,
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('carousel-indicator-0'))),
        const Size(4, 20),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('carousel-indicator-1'))),
        const Size(4, 12),
      );
    });

    testWidgets('hover arrows stay hidden until the pointer enters', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          arrowType: SemiCarouselArrowType.hover,
          children: slides,
        ),
      );
      expect(arrowOpacity(tester, 'prev').opacity, 0);
      expect(arrowOpacity(tester, 'next').opacity, 0);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(SemiCarousel)));
      await tester.pump();
      expect(arrowOpacity(tester, 'prev').opacity, 1);
      expect(arrowOpacity(tester, 'next').opacity, 1);
    });

    testWidgets('arrows sit on opposite sides in RTL', (tester) async {
      await pumpHost(
        tester,
        const SemiCarousel(autoPlay: false, children: slides),
        direction: TextDirection.rtl,
      );
      final prev = tester.getCenter(
        find.byKey(const ValueKey('carousel-arrow-prev')),
      );
      final next = tester.getCenter(
        find.byKey(const ValueKey('carousel-arrow-next')),
      );
      expect(prev.dx, greaterThan(next.dx));
    });

    testWidgets('autoplay advances after interval + speed', (tester) async {
      final changes = <int>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlayInterval: const Duration(milliseconds: 100),
          speed: const Duration(milliseconds: 50),
          children: slides,
          onChange: (index, _) => changes.add(index),
        ),
      );
      // 切换间隔 = interval + speed（100 + 50）：130ms 时还没到。
      await tester.pump(const Duration(milliseconds: 130));
      expect(changes, isEmpty);
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pump(const Duration(milliseconds: 60));
      expect(changes, [1]);
    });

    testWidgets('hover pauses autoplay and leaving resumes it', (tester) async {
      final changes = <int>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlayInterval: const Duration(milliseconds: 500),
          speed: const Duration(milliseconds: 100),
          children: slides,
          onChange: (index, _) => changes.add(index),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(SemiCarousel)));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(changes, isEmpty);
      await gesture.moveTo(const Offset(700, 700));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 800));
      expect(changes, isNotEmpty);
    });

    testWidgets('controller commands drive the carousel', (tester) async {
      final controller = SemiCarouselController();
      final changes = <int>[];
      await pumpHost(
        tester,
        SemiCarousel(
          autoPlay: false,
          controller: controller,
          children: slides,
          onChange: (index, _) => changes.add(index),
        ),
      );
      expect(controller.isAttached, isTrue);
      controller.next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      controller.goTo(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(changes, [1, 0]);
      controller.stop();
      expect(controller.isAttached, isTrue);
    });

    testWidgets('single child hides indicator and arrows', (tester) async {
      await pumpHost(
        tester,
        const SemiCarousel(
          autoPlay: false,
          children: [SizedBox(key: ValueKey('only'))],
        ),
      );
      expect(find.byKey(const ValueKey('only')), findsOneWidget);
      expect(find.byKey(const ValueKey('carousel-arrow-next')), findsNothing);
      expect(find.byKey(const ValueKey('carousel-indicator-0')), findsNothing);
    });

    testWidgets('a local theme patch drives indicator geometry', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCarouselTheme(
          data: const SemiCarouselThemeData(
            widthCarouselIndicatorDotSmall: 24,
            colorCarouselIndicatorThemeLightBgDefault: Color(0xFF00FF00),
          ),
          child: const SemiCarousel(autoPlay: false, children: slides),
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('carousel-indicator-0'))),
        const Size(24, 24),
      );
      expect(indicatorDecoration(tester, 1).color, const Color(0xFF00FF00));
    });
  });
}
