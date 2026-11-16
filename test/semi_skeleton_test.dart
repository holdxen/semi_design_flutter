// Behavior matrix for SemiSkeleton plus coverage for the 17 Sass declarations
// (15 FIELDS + 2 MOTION + 0 INTERNAL) — the 14 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. 0 dead variables.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: direction,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 600,
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    );

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(800, 800));
  await tester.pumpWidget(host(child, direction: direction));
}

BoxDecoration decorationOf(WidgetTester tester, Finder shape) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(of: shape, matching: find.byType(DecoratedBox)),
            )
            .decoration
        as BoxDecoration;

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiSkeletonThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedSkeletonThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-skeleton_default-bg-default: var(--semi-color-fill-0)',
    _c,
    (v) => SemiSkeletonThemeData(colorSkeletonDefaultBgDefault: v as Color),
    (d) => d.colorSkeletonDefaultBgDefault,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-skeleton_loading-gradient-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) =>
        SemiSkeletonThemeData(colorSkeletonLoadingGradientBgActive: v as Color),
    (d) => d.colorSkeletonLoadingGradientBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$width-skeleton_avatar_extra_extra_small: 20px',
    20.0,
    (v) =>
        SemiSkeletonThemeData(widthSkeletonAvatarExtraExtraSmall: v as double),
    (d) => d.widthSkeletonAvatarExtraExtraSmall,
    (t) => 20.0,
  ),
  (
    r'$width-skeleton_avatar_extra_small: 24px',
    24.0,
    (v) => SemiSkeletonThemeData(widthSkeletonAvatarExtraSmall: v as double),
    (d) => d.widthSkeletonAvatarExtraSmall,
    (t) => 24.0,
  ),
  (
    r'$width-skeleton_avatar_small: 32px',
    32.0,
    (v) => SemiSkeletonThemeData(widthSkeletonAvatarSmall: v as double),
    (d) => d.widthSkeletonAvatarSmall,
    (t) => 32.0,
  ),
  (
    r'$width-skeleton_avatar_medium: 48px',
    48.0,
    (v) => SemiSkeletonThemeData(widthSkeletonAvatarMedium: v as double),
    (d) => d.widthSkeletonAvatarMedium,
    (t) => 48.0,
  ),
  (
    r'$width-skeleton_avatar_large: 72px',
    72.0,
    (v) => SemiSkeletonThemeData(widthSkeletonAvatarLarge: v as double),
    (d) => d.widthSkeletonAvatarLarge,
    (t) => 72.0,
  ),
  (
    r'$width-skeleton_avatar_extra_large: 128px',
    128.0,
    (v) => SemiSkeletonThemeData(widthSkeletonAvatarExtraLarge: v as double),
    (d) => d.widthSkeletonAvatarExtraLarge,
    (t) => 128.0,
  ),
  (
    r'$width-skeleton_button: 115px',
    115.0,
    (v) => SemiSkeletonThemeData(widthSkeletonButton: v as double),
    (d) => d.widthSkeletonButton,
    (t) => 115.0,
  ),
  (
    r'$height-skeleton_li: 16px',
    16.0,
    (v) => SemiSkeletonThemeData(heightSkeletonLi: v as double),
    (d) => d.heightSkeletonLi,
    (t) => 16.0,
  ),
  (
    r'$height-skeleton_title: $height-control-small',
    24.0,
    (v) => SemiSkeletonThemeData(heightSkeletonTitle: v as double),
    (d) => d.heightSkeletonTitle,
    (t) => 24.0,
  ),
  (
    r'$height-skeleton_button: $height-control-default',
    32.0,
    (v) => SemiSkeletonThemeData(heightSkeletonButton: v as double),
    (d) => d.heightSkeletonButton,
    (t) => 32.0,
  ),
  (
    r'$spacing-skeleton_li-marginBottom: 10px',
    10.0,
    (v) => SemiSkeletonThemeData(spacingSkeletonLiMarginBottom: v as double),
    (d) => d.spacingSkeletonLiMarginBottom,
    (t) => 10.0,
  ),
  (
    r'$radius-skeleton_item: var(--semi-border-radius-small)',
    77.0,
    (v) => SemiSkeletonThemeData(radiusSkeletonItem: v as double),
    (d) => d.radiusSkeletonItem,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-skeleton_li: var(--semi-border-radius-small)',
    77.0,
    (v) => SemiSkeletonThemeData(radiusSkeletonLi: v as double),
    (d) => d.radiusSkeletonLi,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$animation_duration-skeleton-highlight: 1400ms',
    const Duration(milliseconds: 1400),
    (v) => SemiSkeletonThemeData(
      animationDurationSkeletonHighlight: v as Duration,
    ),
    (d) => d.animationDurationSkeletonHighlight,
    (t) => const Duration(milliseconds: 1400),
  ),
  (
    r'$animation_function-skeleton-highlight: ease',
    Curves.ease,
    (v) =>
        SemiSkeletonThemeData(animationFunctionSkeletonHighlight: v as Curve),
    (d) => d.animationFunctionSkeletonHighlight,
    (t) => Curves.ease,
  ),
];

void main() {
  group('theme fields (17 = 15 FIELDS + 2 MOTION + 0 INTERNAL)', () {
    test('17 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(17));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiSkeletonThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiSkeletonThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiSkeletonThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_skeleton_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(17));
      expect(
        source,
        contains('packages/semi-foundation/skeleton/variables.scss'),
      );
      expect(
        source,
        contains('packages/semi-foundation/skeleton/animation.scss'),
      );
      expect(source, contains('Generated by tool/generate_skeleton.py'));
      expect(source, isNot(contains('# dead variable (上游未消费)')));
    });

    test('the 14 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_skeleton.dart')
          .readAsStringSync();
      const anchors = <String>[
        'background-size: 400% 100%',
        'background-position: 100% 50%',
        'background-position: 0 50%',
        'animation-fill-mode: forwards',
        'infinite',
        'linear-gradient(90deg',
        'border-radius: 50%',
        'width: 60%',
        'width: 100%',
        'list-style-type: none',
        'rows: 4',
        "size: 'medium'",
        "shape: 'circle'",
        "'extra-extra-small', 'extra-small', 'small', 'default', 'medium', "
            "'large', 'extra-large'",
      ];
      expect(anchors, hasLength(14));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 2 Color + 13 double + 1 Duration + 1 Curve = 17', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 2);
      expect(counts['double'], 13);
      expect(counts['Duration'], 1);
      expect(counts['Cubic'], 1);
    });

    test('0 dead variables: every field name appears in the widget source', () {
      final widgetSource = File('lib/src/components/semi_skeleton.dart')
          .readAsStringSync();
      for (final name in [
        'colorSkeletonDefaultBgDefault',
        'colorSkeletonLoadingGradientBgActive',
        'widthSkeletonAvatarExtraExtraSmall',
        'widthSkeletonAvatarExtraSmall',
        'widthSkeletonAvatarSmall',
        'widthSkeletonAvatarMedium',
        'widthSkeletonAvatarLarge',
        'widthSkeletonAvatarExtraLarge',
        'widthSkeletonButton',
        'heightSkeletonLi',
        'heightSkeletonTitle',
        'heightSkeletonButton',
        'spacingSkeletonLiMarginBottom',
        'radiusSkeletonItem',
        'radiusSkeletonLi',
        'animationDurationSkeletonHighlight',
        'animationFunctionSkeletonHighlight',
      ]) {
        expect(widgetSource, contains(name), reason: name);
      }
      final docs = File('docs/semi_skeleton.md').readAsStringSync();
      expect(docs, contains('17 = 15 FIELDS + 2 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.skeleton, const SemiSkeletonThemeData());
      expect(
        themes.copyWith(
          skeleton: const SemiSkeletonThemeData(widthSkeletonButton: 200),
        ),
        const SemiComponentThemes(
          skeleton: SemiSkeletonThemeData(widthSkeletonButton: 200),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('loading swaps placeholder for child', (tester) async {
      await pumpHost(
        tester,
        const SemiSkeleton(
          placeholder: SemiSkeletonTitle(),
          child: Text('content'),
        ),
      );
      expect(find.byType(SemiSkeletonTitle), findsOneWidget);
      expect(find.text('content'), findsNothing);

      await pumpHost(
        tester,
        const SemiSkeleton(
          loading: false,
          placeholder: SemiSkeletonTitle(),
          child: Text('content'),
        ),
      );
      expect(find.byType(SemiSkeletonTitle), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('static shapes use the default fill color', (tester) async {
      await pumpHost(
        tester,
        const SemiSkeleton(placeholder: SemiSkeletonTitle()),
      );
      final decoration = decorationOf(tester, find.byType(SemiSkeletonTitle));
      expect(decoration.color, const SemiThemeData.light().colors.colorFill0);
      expect(decoration.gradient, isNull);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(
          const SemiThemeData.light().radius.borderRadiusSmall.value,
        ),
      );
    });

    testWidgets('active paints a three-stop shimmer that advances', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSkeleton(active: true, placeholder: SemiSkeletonTitle()),
      );
      final first = decorationOf(tester, find.byType(SemiSkeletonTitle));
      final gradient = first.gradient! as LinearGradient;
      final light = const SemiThemeData.light();
      expect(first.color, isNull);
      expect(gradient.colors, [
        light.colors.colorFill0,
        light.colors.colorFill1,
        light.colors.colorFill0,
      ]);
      expect(gradient.stops, const [0.25, 0.44, 0.88]);
      await tester.pump(const Duration(milliseconds: 350));
      final second = decorationOf(tester, find.byType(SemiSkeletonTitle));
      expect((second.gradient! as LinearGradient).begin, isNot(gradient.begin));
    });

    testWidgets('theme duration and curve drive the shimmer geometry', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiSkeletonTheme(
          data: const SemiSkeletonThemeData(
            animationDurationSkeletonHighlight: Duration(milliseconds: 100),
            animationFunctionSkeletonHighlight: Curves.linear,
          ),
          child: const SemiSkeleton(
            active: true,
            placeholder: SemiSkeletonTitle(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      final gradient =
          decorationOf(tester, find.byType(SemiSkeletonTitle)).gradient!
              as LinearGradient;
      // t = 0.5 → offset = -1.5 → begin.x = 2 * -1.5 - 1 = -4.
      expect((gradient.begin as Alignment).x, closeTo(-4, 0.05));
      expect((gradient.end as Alignment).x, closeTo(4, 0.05));
    });

    testWidgets('active does not paint when loading is false', (tester) async {
      await pumpHost(
        tester,
        const SemiSkeleton(
          active: true,
          loading: false,
          placeholder: SemiSkeletonTitle(),
          child: Text('content'),
        ),
      );
      expect(find.byType(SemiSkeletonTitle), findsNothing);
      expect(find.byType(DecoratedBox), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('avatar sizes and shapes come from the theme', (tester) async {
      const sizes = {
        SemiSkeletonAvatarSize.extraExtraSmall: 20.0,
        SemiSkeletonAvatarSize.extraSmall: 24.0,
        SemiSkeletonAvatarSize.small: 32.0,
        SemiSkeletonAvatarSize.medium: 48.0,
        SemiSkeletonAvatarSize.large: 72.0,
        SemiSkeletonAvatarSize.extraLarge: 128.0,
      };
      for (final entry in sizes.entries) {
        await pumpHost(
          tester,
          SemiSkeleton(placeholder: SemiSkeletonAvatar(size: entry.key)),
        );
        final avatar = find.byType(SemiSkeletonAvatar);
        expect(tester.getSize(avatar), Size(entry.value, entry.value));
        expect(
          decorationOf(tester, avatar).borderRadius,
          BorderRadius.circular(entry.value / 2),
          reason: '${entry.key} circle',
        );
      }
      await pumpHost(
        tester,
        const SemiSkeleton(
          placeholder: SemiSkeletonAvatar(
            shape: SemiSkeletonAvatarShape.square,
          ),
        ),
      );
      final avatar = find.byType(SemiSkeletonAvatar);
      expect(tester.getSize(avatar), const Size(48, 48));
      expect(
        decorationOf(tester, avatar).borderRadius,
        BorderRadius.circular(
          const SemiThemeData.light().radius.borderRadiusSmall.value,
        ),
      );
    });

    testWidgets('paragraph rows: height 16, gap 10, last row 60%', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSkeleton(placeholder: SemiSkeletonParagraph()),
      );
      final rows = find.descendant(
        of: find.byType(SemiSkeletonParagraph),
        matching: find.byType(DecoratedBox),
      );
      expect(rows, findsNWidgets(4));
      final sizes = [for (var i = 0; i < 4; i++) tester.getSize(rows.at(i))];
      for (final size in sizes) {
        expect(size.height, 16);
      }
      expect(sizes.take(3).map((s) => s.width), everyElement(300.0));
      expect(sizes[3].width, closeTo(180, 0.01));
      final tops = [
        for (var i = 0; i < 4; i++) tester.getTopLeft(rows.at(i)).dy,
      ];
      for (var i = 1; i < 4; i++) {
        expect(tops[i] - tops[i - 1], 26);
      }
    });

    testWidgets('single row is 100% wide (CSS first-child wins)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSkeleton(placeholder: SemiSkeletonParagraph(rows: 1)),
      );
      final row = find.descendant(
        of: find.byType(SemiSkeletonParagraph),
        matching: find.byType(DecoratedBox),
      );
      expect(row, findsOneWidget);
      expect(tester.getSize(row).width, 300);
    });

    testWidgets('paragraph last row aligns to the start in RTL', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSkeleton(placeholder: SemiSkeletonParagraph()),
        direction: TextDirection.rtl,
      );
      final rows = find.descendant(
        of: find.byType(SemiSkeletonParagraph),
        matching: find.byType(DecoratedBox),
      );
      final last = tester.getRect(rows.at(3));
      final first = tester.getRect(rows.at(0));
      expect(first.left, 0);
      expect(last.width, closeTo(180, 0.01));
      expect(last.right, 300);
    });

    testWidgets('title, button and image take their declared geometry', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSkeleton(
          placeholder: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemiSkeletonTitle(),
              SemiSkeletonButton(),
              SizedBox(width: 200, height: 120, child: SemiSkeletonImage()),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(SemiSkeletonTitle)),
        const Size(300, 24),
      );
      expect(
        tester.getSize(find.byType(SemiSkeletonButton)),
        const Size(115, 32),
      );
      expect(
        tester.getSize(find.byType(SemiSkeletonImage)),
        const Size(200, 120),
      );
    });

    testWidgets('a local theme patch overrides shape geometry', (tester) async {
      await pumpHost(
        tester,
        SemiSkeletonTheme(
          data: const SemiSkeletonThemeData(
            widthSkeletonAvatarExtraLarge: 200,
            heightSkeletonLi: 8,
          ),
          child: const SemiSkeleton(
            placeholder: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.extraLarge),
                SemiSkeletonParagraph(rows: 1),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(SemiSkeletonAvatar)),
        const Size(200, 200),
      );
      final row = find.descendant(
        of: find.byType(SemiSkeletonParagraph),
        matching: find.byType(DecoratedBox),
      );
      expect(tester.getSize(row).height, 8);
    });
  });
}
