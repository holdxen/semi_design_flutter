// Behavior matrix for SemiAnchor plus coverage for the 30 Sass declarations
// (26 FIELDS + 4 MOTION + 0 INTERNAL) — the 22 HARDCODES provenance anchors
// live in the widget's `_AnchorMetrics` / call sites, the 2 dead FIELDS
// (上游未消费) must NOT appear in the widget, and the docs mark them.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (the
/// semi_tag_input_test.dart host precedent).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(
                  child: SizedBox(width: width, height: height, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Pump [host] on a tall test surface.
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(
    host(child, direction: direction, width: width, height: height),
  );
}

/// known_issues.md #1（滚动贴边 tap 失效一次怪癖）：滚动列表贴边点击前补一次
/// 中性 tap（外场空白处），吃掉那一次失效命中。
Future<void> neutralTap(WidgetTester tester) async {
  await tester.tapAt(const Offset(1180, 20));
  await tester.pump();
}

// -- fixtures ----------------------------------------------------------------

/// 宿主页面：锚点 + 可滚内容（Column + SingleChildScrollView——★ListView
/// 惰性卸载 caveat 见 docs 差异清单 20）。各 section 高度足量。
Widget anchorPage({
  required Widget anchor,
  required ScrollController controller,
  List<(String, double)> sections = const [
    ('sec1', 500),
    ('sec2', 500),
    ('sec3', 500),
    ('sec4', 500),
  ],
}) => Row(
  children: [
    anchor,
    Expanded(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (id, height) in sections)
              SemiAnchorTarget(
                id: id,
                child: SizedBox(height: height, child: Text('content $id')),
              ),
          ],
        ),
      ),
    ),
  ],
);

Widget anchor({
  List<Widget> children = const [],
  SemiAnchorRailTheme railTheme = SemiAnchorRailTheme.primary,
  SemiAnchorSize size = SemiAnchorSize.defaultSize,
  bool autoCollapse = false,
  bool showTooltip = false,
  bool scrollMotion = false,
  String? defaultAnchor,
  double targetOffset = 0,
  double offsetTop = 0,
  double maxWidth = 200,
  double maxHeight = 750,
  ScrollController? scrollController,
  void Function(String? current, String? previous)? onChanged,
  ValueChanged<String>? onClick,
}) => SemiAnchor(
  scrollController: scrollController,
  defaultAnchor: defaultAnchor,
  targetOffset: targetOffset,
  offsetTop: offsetTop,
  scrollMotion: scrollMotion,
  railTheme: railTheme,
  size: size,
  autoCollapse: autoCollapse,
  showTooltip: showTooltip,
  maxWidth: maxWidth,
  maxHeight: maxHeight,
  onChanged: onChanged,
  onClick: onClick,
  children: children,
);

List<SemiAnchorLink> basicLinks() => const [
  SemiAnchorLink(href: '#sec1', title: '第一节'),
  SemiAnchorLink(href: '#sec2', title: '第二节'),
  SemiAnchorLink(href: '#sec3', title: '第三节'),
  SemiAnchorLink(href: '#sec4', title: '第四节'),
];

// -- finders / measurements --------------------------------------------------

Color? titleColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

double titleFontSize(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.fontSize!;

double barHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(SemiAnchor.slideBarKey)).height;

Offset barTopLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(SemiAnchor.slideBarKey));

Color? barColor(WidgetTester tester) =>
    (tester.widget<DecoratedBox>(find.byKey(SemiAnchor.slideBarKey)).decoration
            as BoxDecoration)
        .color;

Color? trackColor(WidgetTester tester) =>
    (tester
                .widget<DecoratedBox>(find.byKey(SemiAnchor.slideTrackKey))
                .decoration
            as BoxDecoration)
        .color;

Finder titleRow(String text) => find.ancestor(
  of: find.text(text),
  matching: find.byType(AnimatedContainer),
);

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiAnchorThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedAnchorThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-anchor_slide_default-bg-default: var(--semi-color-border)',
    const Color(0xff010101),
    (v) => SemiAnchorThemeData(colorAnchorSlideDefaultBgDefault: v as Color),
    (d) => d.colorAnchorSlideDefaultBgDefault,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-anchor_slide_primary-bg-active: var(--semi-color-primary)',
    const Color(0xff020202),
    (v) => SemiAnchorThemeData(colorAnchorSlidePrimaryBgActive: v as Color),
    (d) => d.colorAnchorSlidePrimaryBgActive,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-anchor_slide_tertiary-bg-active: var(--semi-color-tertiary)',
    const Color(0xff030303),
    (v) => SemiAnchorThemeData(colorAnchorSlideTertiaryBgActive: v as Color),
    (d) => d.colorAnchorSlideTertiaryBgActive,
    (t) => t.colors.colorTertiary,
  ),
  (
    r'$color-anchor_slide_muted-bg-active: var(--semi-color-white)',
    const Color(0xff040404),
    (v) => SemiAnchorThemeData(colorAnchorSlideMutedBgActive: v as Color),
    (d) => d.colorAnchorSlideMutedBgActive,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-anchor_title-text-default: var(--semi-color-text-2)',
    const Color(0xff050505),
    (v) => SemiAnchorThemeData(colorAnchorTitleTextDefault: v as Color),
    (d) => d.colorAnchorTitleTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-anchor_title-text-hover: var(--semi-color-tertiary-hover)',
    const Color(0xff060606),
    (v) => SemiAnchorThemeData(colorAnchorTitleTextHover: v as Color),
    (d) => d.colorAnchorTitleTextHover,
    (t) => t.colors.colorTertiaryHover,
  ),
  (
    r'$color-anchor_title_active-text-hover: $color-anchor_title-text-hover',
    const Color(0xff070707),
    (v) => SemiAnchorThemeData(colorAnchorTitleActiveTextHover: v as Color),
    (d) => d.colorAnchorTitleActiveTextHover,
    (t) => t.colors.colorTertiaryHover,
  ),
  (
    r'$color-anchor_title-text-active: var(--semi-color-text-0)',
    const Color(0xff080808),
    (v) => SemiAnchorThemeData(colorAnchorTitleTextActive: v as Color),
    (d) => d.colorAnchorTitleTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-anchor_title-text-disabled: var(--semi-color-disabled-text)',
    const Color(0xff090909),
    (v) => SemiAnchorThemeData(colorAnchorTitleTextDisabled: v as Color),
    (d) => d.colorAnchorTitleTextDisabled,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-anchor_title-bg-default: transparent',
    const Color(0xff0a0a0a),
    (v) => SemiAnchorThemeData(colorAnchorTitleBgDefault: v as Color),
    (d) => d.colorAnchorTitleBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-anchor_title-bg-active: transparent',
    const Color(0xff0b0b0b),
    (v) => SemiAnchorThemeData(colorAnchorTitleBgActive: v as Color),
    (d) => d.colorAnchorTitleBgActive,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-anchor_title-outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff0c0c0c),
    (v) => SemiAnchorThemeData(colorAnchorTitleOutlineFocus: v as Color),
    (d) => d.colorAnchorTitleOutlineFocus,
    (t) => t.colors.colorPrimaryLightActive,
  ),
  (
    r'$spacing-anchor_slide-left: $spacing-none',
    101.0,
    (v) => SemiAnchorThemeData(spacingAnchorSlideLeft: v as double),
    (d) => d.spacingAnchorSlideLeft,
    (t) => 0.0,
  ),
  (
    r'$spacing-anchor_slide-top: $spacing-none',
    102.0,
    (v) => SemiAnchorThemeData(spacingAnchorSlideTop: v as double),
    (d) => d.spacingAnchorSlideTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-anchor_slide_default-Y: $spacing-extra-tight',
    103.0,
    (v) => SemiAnchorThemeData(spacingAnchorSlideDefaultY: v as double),
    (d) => d.spacingAnchorSlideDefaultY,
    (t) => 4.0,
  ),
  (
    r'$spacing-anchor_slide_small-Y: $spacing-extra-tight',
    104.0,
    (v) => SemiAnchorThemeData(spacingAnchorSlideSmallY: v as double),
    (d) => d.spacingAnchorSlideSmallY,
    (t) => 4.0,
  ),
  (
    r'$spacing-anchor_link-paddingLeft: $spacing-tight',
    105.0,
    (v) => SemiAnchorThemeData(spacingAnchorLinkPaddingLeft: v as double),
    (d) => d.spacingAnchorLinkPaddingLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-anchor_link_title-paddingTop: $spacing-extra-tight',
    106.0,
    (v) => SemiAnchorThemeData(spacingAnchorLinkTitlePaddingTop: v as double),
    (d) => d.spacingAnchorLinkTitlePaddingTop,
    (t) => 4.0,
  ),
  (
    r'$spacing-anchor_link_title-paddingBottom: $spacing-extra-tight',
    107.0,
    (v) =>
        SemiAnchorThemeData(spacingAnchorLinkTitlePaddingBottom: v as double),
    (d) => d.spacingAnchorLinkTitlePaddingBottom,
    (t) => 4.0,
  ),
  (
    r'$width-anchor_slide_default: 2px',
    108.0,
    (v) => SemiAnchorThemeData(widthAnchorSlideDefault: v as double),
    (d) => d.widthAnchorSlideDefault,
    (t) => 2.0,
  ),
  (
    r'$height-anchor_slide_default: 20px',
    109.0,
    (v) => SemiAnchorThemeData(heightAnchorSlideDefault: v as double),
    (d) => d.heightAnchorSlideDefault,
    (t) => 20.0,
  ),
  (
    r'$height-anchor_slide_small: 16px',
    110.0,
    (v) => SemiAnchorThemeData(heightAnchorSlideSmall: v as double),
    (d) => d.heightAnchorSlideSmall,
    (t) => 16.0,
  ),
  (
    r'$radius-anchor_slide: 1px',
    111.0,
    (v) => SemiAnchorThemeData(radiusAnchorSlide: v as double),
    (d) => d.radiusAnchorSlide,
    (t) => 1.0,
  ),
  (
    r'$width-anchor-outline: 2px',
    112.0,
    (v) => SemiAnchorThemeData(widthAnchorOutline: v as double),
    (d) => d.widthAnchorOutline,
    (t) => 2.0,
  ),
  (
    r'$width-anchor-outlineOffset: -2px',
    113.0,
    (v) => SemiAnchorThemeData(widthAnchorOutlineOffset: v as double),
    (d) => d.widthAnchorOutlineOffset,
    (t) => -2.0,
  ),
  (
    r'$width-anchor-outline_border_radius: 3px',
    114.0,
    (v) => SemiAnchorThemeData(widthAnchorOutlineBorderRadius: v as double),
    (d) => d.widthAnchorOutlineBorderRadius,
    (t) => 3.0,
  ),
  (
    r'$transition_duration-anchor_title-text: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 5),
    (v) =>
        SemiAnchorThemeData(transitionDurationAnchorTitleText: v as Duration),
    (d) => d.transitionDurationAnchorTitleText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-anchor_title-text: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiAnchorThemeData(transitionFunctionAnchorTitleText: v as Curve),
    (d) => d.transitionFunctionAnchorTitleText,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-anchor_title-text: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 6),
    (v) => SemiAnchorThemeData(transitionDelayAnchorTitleText: v as Duration),
    (d) => d.transitionDelayAnchorTitleText,
    (t) => Duration.zero,
  ),
  (
    r'$transform_scale-anchor_title-text: var(--semi-transform_scale-none)',
    const SemiTransform.scale(2, 3),
    (v) =>
        SemiAnchorThemeData(transformScaleAnchorTitleText: v as SemiTransform),
    (d) => d.transformScaleAnchorTitleText,
    (t) => const SemiTransform.scale(1, 1),
  ),
];

void main() {
  group('theme fields (30 = 26 FIELDS + 4 MOTION + 0 INTERNAL)', () {
    test('30 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(30));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiAnchorThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiAnchorThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiAnchorThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_anchor_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(30));
      // ★provenance 拼写 quirk 照抄（含上游注释拼写错误）。
      expect(source, contains('Tietrary'));
      expect(source, contains('Witdh'));
    });

    test('the 22 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_anchor.dart')
          .readAsStringSync();
      final anchors = <String>[
        '8 * level',
        'overflow: hidden; text-overflow: ellipsis; white-space: nowrap;',
        'cursor: pointer',
        'cursor: not-allowed',
        'outline: \$width-anchor-outline solid \$color-anchor_title-outline-focus',
        'outline-offset: \$width-anchor-outlineOffset',
        "content: ' '",
        'display: none',
        'height: \$height-anchor_slide_default + 2 * \$spacing-anchor_slide_default-Y',
        'height: \$height-anchor_slide_small + 2 * \$spacing-anchor_slide_small-Y',
        'transform: scale(\$transform_scale-anchor_title-text)',
        'transition: color \$transition_duration-anchor_title-text \$transition_function-anchor_title-text \$transition_delay-anchor_title-text',
        'color: \$color-anchor_title-text-default !important',
        'color: \$color-anchor_title-text-hover !important',
        'color: \$color-anchor_title-text-active !important',
        'color: \$color-anchor_title-text-disabled !important',
        r'$font-size-small: 12px',
        r'$font-size-regular: 14px',
        "'Side navigation'",
        "MAX_WIDTH: '200px'",
        "MAX_HEIGHT: '750px'",
        'padding-left: auto',
      ];
      expect(anchors, hasLength(22));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 12 Color + 14 double + 2 Duration + 1 Curve + '
        '1 SemiTransform', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = value is SemiTransform
            ? 'SemiTransform'
            : value is Curve
            ? 'Curve'
            : value.runtimeType.toString();
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 12);
      expect(counts['double'], 14);
      expect(counts['Duration'], 2);
      expect(counts['Curve'], 1);
      expect(counts['SemiTransform'], 1);
    });

    test('dead FIELDS stay out of the widget; docs mark them (上游未消费)', () {
      const dead = [
        'color-anchor_slide_muted-bg-active',
        'spacing-anchor_link-paddingLeft',
      ];
      const deadFields = [
        'colorAnchorSlideMutedBgActive',
        'spacingAnchorLinkPaddingLeft',
      ];
      final widgetSource = File('lib/src/components/semi_anchor.dart')
          .readAsStringSync();
      for (final name in deadFields) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      final docs = File('docs/semi_anchor.md').readAsStringSync();
      for (final name in dead) {
        final rows = docs
            .split('\n')
            .where((line) => line.contains('\$$name:'))
            .toList();
        expect(rows, isNotEmpty, reason: name);
        expect(
          rows.any((row) => row.contains('（上游未消费）')),
          isTrue,
          reason: name,
        );
      }
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().anchor, const SemiAnchorThemeData());
      const patch = SemiAnchorThemeData(heightAnchorSlideDefault: 40);
      const themes = SemiComponentThemes(anchor: patch);
      expect(const SemiComponentThemes().copyWith(anchor: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.anchor, patch);
    });

    testWidgets('SemiAnchorTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiAnchorTheme(
            data: const SemiAnchorThemeData(heightAnchorSlideDefault: 40),
            child: SemiAnchorTheme(
              data: const SemiAnchorThemeData(spacingAnchorSlideDefaultY: 5),
              child: anchorPage(
                controller: controller,
                anchor: anchor(
                  defaultAnchor: '#sec1',
                  scrollController: controller,
                  children: basicLinks(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Outer patch field (slide height 40) + inner patch field (spacing 5) →
      // bar height = 40 + 2 * 5 = 50（内层只赢自己的字段）。
      expect(barHeight(tester), 50.0);
    });
  });

  group('scroll-spy 与高亮', () {
    testWidgets('defaultAnchor 初始高亮 + 滚动，不发 onChanged/onClick', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final changes = <(String?, String?)>[];
      final clicks = <String>[];
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            defaultAnchor: '#sec2',
            scrollController: controller,
            onChanged: (c, p) => changes.add((c, p)),
            onClick: clicks.add,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = const SemiThemeData.light();
      expect(titleColor(tester, '第二节'), t.colors.colorText0);
      expect(titleColor(tester, '第一节'), t.colors.colorText2);
      expect(controller.offset, 500.0);
      // shouldNotify=false：onChanged/onClick 都不发（foundation.ts:50/:125）。
      expect(changes, isEmpty);
      expect(clicks, isEmpty);
    });

    testWidgets('滚动越过阈值 → active 迁移 + onChanged(current, previous)；'
        '★滚回首项以上 → active=null quirk + onChanged(null, …)', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final changes = <(String?, String?)>[];
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            scrollController: controller,
            onChanged: (c, p) => changes.add((c, p)),
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = const SemiThemeData.light();
      // sec2 顶 = 500 - 550 = -50（最大负值）→ active '#sec2'。
      // ★上游 activeLink 初值 '' → 首个 previous 为 ''。
      controller.jumpTo(550);
      await tester.pump();
      expect(titleColor(tester, '第二节'), t.colors.colorText0);
      expect(changes, [('#sec2', '')]);
      // sec3 顶 = 1000 - 1050 = -50 → active '#sec3'。
      controller.jumpTo(1050);
      await tester.pump();
      expect(titleColor(tester, '第三节'), t.colors.colorText0);
      expect(titleColor(tester, '第二节'), t.colors.colorText2);
      expect(changes, [('#sec2', ''), ('#sec3', '#sec2')]);
      // ★全 ≥0 → active = null quirk（滑杆隐藏、onChanged(null, prev) 照发）。
      controller.jumpTo(0);
      await tester.pump();
      expect(titleColor(tester, '第一节'), t.colors.colorText2);
      expect(find.byKey(SemiAnchor.slideBarKey), findsNothing);
      expect(changes.last, (null, '#sec3'));
    });

    testWidgets('offsetTop 阈值补偿（目标 top 再减 offsetTop）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final changes = <(String?, String?)>[];
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            offsetTop: 100,
            scrollController: controller,
            onChanged: (c, p) => changes.add((c, p)),
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // sec1 顶 = 0 - 450 - 100 = -550、sec2 = -50 → active '#sec2'。
      controller.jumpTo(450);
      await tester.pump();
      expect(changes.last, ('#sec2', ''));
    });
  });

  group('点击滚动', () {
    testWidgets('tap title → 自算 offset + onClick(href) + 抑制旗标（滚动中高亮不跳，'
        '静止后恢复）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final changes = <(String?, String?)>[];
      final clicks = <String>[];
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            scrollController: controller,
            onChanged: (c, p) => changes.add((c, p)),
            onClick: clicks.add,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.text('第三节'));
      await tester.pump();
      // 自算 targetScroll = pixels + linkTop - containerTop - targetOffset
      // = 0 + 1000 - 0 = 1000（未触 clamp）。
      expect(controller.offset, 1000.0);
      expect(clicks, ['#sec3']);
      expect(changes.last, ('#sec3', ''));
      // ★抑制旗标：100ms 静止窗口内手动滚动，spy 不迁升高亮。
      controller.jumpTo(100);
      await tester.pump();
      final t = const SemiThemeData.light();
      expect(titleColor(tester, '第三节'), t.colors.colorText0);
      expect(changes.last, ('#sec3', ''));
      // 静止 100ms 后旗标复位 → spy 恢复（sec1 顶 = -100 → active '#sec1'）。
      await tester.pump(const Duration(milliseconds: 110));
      controller.jumpTo(200);
      await tester.pump();
      expect(titleColor(tester, '第一节'), t.colors.colorText0);
      expect(changes.last, ('#sec1', '#sec3'));
    });

    testWidgets('targetOffset 落点补偿 + clamp 到滚动范围', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            targetOffset: 20,
            scrollController: controller,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.text('第三节'));
      await tester.pump();
      expect(controller.offset, 980.0);
      // maxScrollExtent = 2000 - 900 = 1100 → clamp。
      await neutralTap(tester);
      await tester.tap(find.text('第四节'));
      await tester.pump();
      expect(controller.offset, 1100.0);
    });

    testWidgets('scrollMotion animateTo vs jumpTo', (tester) async {
      // jumpTo：tap 后 offset 立即到位。
      final jump = ScrollController();
      addTearDown(jump.dispose);
      await pumpHost(
        tester,
        anchorPage(
          controller: jump,
          anchor: anchor(scrollController: jump, children: basicLinks()),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.text('第四节'));
      await tester.pump();
      expect(jump.offset, 1100.0);
      // animateTo：tap 后仍在途中，pumpAndSettle 后到位。
      final smooth = ScrollController();
      addTearDown(smooth.dispose);
      await pumpHost(
        tester,
        anchorPage(
          controller: smooth,
          anchor: anchor(
            scrollMotion: true,
            scrollController: smooth,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.text('第四节'));
      await tester.pump();
      expect(smooth.offset, lessThan(1100.0));
      await tester.pumpAndSettle();
      expect(smooth.offset, 1100.0);
    });
  });

  group('autoCollapse', () {
    testWidgets('非激活分支隐藏、激活/含后代时展开（descendantMap 口径）', (tester) async {
      await pumpHost(
        tester,
        anchor(
          autoCollapse: true,
          children: const [
            SemiAnchorLink(
              href: '#p1',
              title: 'Parent1',
              children: [
                SemiAnchorLink(href: '#c1', title: 'Child1'),
                SemiAnchorLink(href: '#c2', title: 'Child2'),
              ],
            ),
            SemiAnchorLink(
              href: '#p2',
              title: 'Parent2',
              children: [SemiAnchorLink(href: '#c3', title: 'Child3')],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      // 初始（active ''）子级全隐。
      expect(find.text('Child1'), findsNothing);
      expect(find.text('Child3'), findsNothing);
      await neutralTap(tester);
      await tester.tap(find.text('Parent1'));
      await tester.pump();
      expect(find.text('Child1'), findsOneWidget);
      expect(find.text('Child2'), findsOneWidget);
      expect(find.text('Child3'), findsNothing);
      // 含 active 后代 → 分支保持展开。
      await neutralTap(tester);
      await tester.tap(find.text('Child2'));
      await tester.pump();
      expect(find.text('Child2'), findsOneWidget);
      // 兄弟分支切换。
      await neutralTap(tester);
      await tester.tap(find.text('Parent2'));
      await tester.pump();
      expect(find.text('Child1'), findsNothing);
      expect(find.text('Child2'), findsNothing);
      expect(find.text('Child3'), findsOneWidget);
    });
  });

  group('showTooltip', () {
    testWidgets('hover title 出 tooltip（trigger: hover）', (tester) async {
      await pumpHost(tester, anchor(showTooltip: true, children: basicLinks()));
      await tester.pumpAndSettle();
      expect(find.text('第一节'), findsOneWidget);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text('第一节')));
      // ★tooltip 首帧停泊需 ~4-5 泵（仓库硬规则 12）；勿起第二个鼠标手势。
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      // title + tooltip content 各一份。
      expect(find.text('第一节'), findsNWidgets(2));
    });
  });

  group('railTheme', () {
    testWidgets('primary/tertiary 滑杆色、muted 轨道隐藏（display:none quirk）', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final t = const SemiThemeData.light();
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            railTheme: SemiAnchorRailTheme.primary,
            defaultAnchor: '#sec1',
            scrollController: controller,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(barColor(tester), t.colors.colorPrimary);
      expect(trackColor(tester), t.colors.colorBorder);
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            railTheme: SemiAnchorRailTheme.tertiary,
            defaultAnchor: '#sec1',
            scrollController: controller,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(barColor(tester), t.colors.colorTertiary);
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            railTheme: SemiAnchorRailTheme.muted,
            defaultAnchor: '#sec1',
            scrollController: controller,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // ★muted：轨道 `display: none` + bar 无背景规则——整棵滑轨子树不渲染。
      expect(find.byKey(SemiAnchor.slideTrackKey), findsNothing);
      expect(find.byKey(SemiAnchor.slideBarKey), findsNothing);
    });
  });

  group('size 与几何', () {
    testWidgets('size 两档：字号 12/14、滑杆高 24/28', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            defaultAnchor: '#sec1',
            scrollController: controller,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(titleFontSize(tester, '第一节'), 14.0);
      expect(barHeight(tester), 28.0);
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          anchor: anchor(
            size: SemiAnchorSize.small,
            defaultAnchor: '#sec1',
            scrollController: controller,
            children: basicLinks(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(titleFontSize(tester, '第一节'), 12.0);
      expect(barHeight(tester), 24.0);
    });

    testWidgets('maxWidth/maxHeight 约束（constants.ts:10-11 常量锚点）', (
      tester,
    ) async {
      await pumpHost(
        tester,
        // Align 传宽松约束（宿主 SizedBox 是 tight，会顶掉 ConstrainedBox 的
        // max——宽松下 100/50 才生效）。
        Align(
          alignment: Alignment.topLeft,
          child: anchor(
            maxWidth: 100,
            maxHeight: 50,
            children: const [
              SemiAnchorLink(href: '#a', title: '这是一个很长很长很长很长很长的标题'),
              SemiAnchorLink(href: '#b', title: 'B'),
              SemiAnchorLink(href: '#c', title: 'C'),
              SemiAnchorLink(href: '#d', title: 'D'),
              SemiAnchorLink(href: '#e', title: 'E'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final size = tester.getSize(find.byKey(SemiAnchor.rootKey));
      expect(size.width, 100.0);
      expect(size.height, 50.0);
    });
  });

  group('disabled', () {
    testWidgets('不可点/Enter 无效但滚动到时照高亮 quirk', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final clicks = <String>[];
      final changes = <(String?, String?)>[];
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          sections: const [('sec1', 500), ('sec2', 500), ('pad', 1000)],
          anchor: anchor(
            scrollController: controller,
            onChanged: (c, p) => changes.add((c, p)),
            onClick: clicks.add,
            children: const [
              SemiAnchorLink(href: '#sec1', title: '第一节'),
              SemiAnchorLink(href: '#sec2', title: '禁用节', disabled: true),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = const SemiThemeData.light();
      // 不可点：tap 不激活、不发 onClick。
      await neutralTap(tester);
      await tester.tap(find.text('禁用节'));
      await tester.pump();
      expect(clicks, isEmpty);
      expect(changes, isEmpty);
      expect(titleColor(tester, '禁用节'), t.colors.colorDisabledText);
      // Enter 无效（link.tsx:78 `!disabled && onClick`）。
      final ctx = tester.element(find.text('禁用节'));
      Focus.of(ctx).requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(clicks, isEmpty);
      // ★滚动到时照高亮（linkFoundation.ts:21-24 注册不受 disabled 影响）：
      // 滑杆照移，但 -disabled 覆盖 -active 色 quirk（anchor.scss:98-101）。
      controller.jumpTo(600);
      await tester.pump();
      await tester.pump();
      expect(changes.last, ('#sec2', ''));
      expect(titleColor(tester, '禁用节'), t.colors.colorDisabledText);
      expect(
        barTopLeft(tester).dy,
        moreOrLessEquals(tester.getTopLeft(titleRow('禁用节')).dy, epsilon: 1),
      );
    });
  });

  group('缩进 8 * level', () {
    testWidgets('level 1/2 缩进 8/16（link.tsx:150）', (tester) async {
      await pumpHost(
        tester,
        anchor(
          children: const [
            SemiAnchorLink(
              href: '#p',
              title: 'L1',
              children: [SemiAnchorLink(href: '#c', title: 'L2')],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final rootLeft = tester.getTopLeft(find.byKey(SemiAnchor.rootKey)).dx;
      expect(
        tester.getTopLeft(find.text('L1')).dx - rootLeft,
        moreOrLessEquals(8, epsilon: 1),
      );
      expect(
        tester.getTopLeft(find.text('L2')).dx - rootLeft,
        moreOrLessEquals(16, epsilon: 1),
      );
    });
  });

  group('键盘激活', () {
    testWidgets('Enter 激活、Space/可打印键忽略（keyboardActivation 口径）', (tester) async {
      final clicks = <String>[];
      await pumpHost(
        tester,
        anchor(onClick: clicks.add, children: basicLinks()),
      );
      await tester.pumpAndSettle();
      final ctx = tester.element(find.text('第一节'));
      Focus.of(ctx).requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(clicks, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(clicks, ['#sec1']);
    });
  });

  group('quirks', () {
    testWidgets('重复 href 双高亮 quirk、#/非法 id 永不激活 quirk（spy -Infinity）', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final clicks = <String>[];
      final changes = <(String?, String?)>[];
      await pumpHost(
        tester,
        anchorPage(
          controller: controller,
          sections: const [('sec1', 500), ('pad', 1500)],
          anchor: anchor(
            scrollController: controller,
            onChanged: (c, p) => changes.add((c, p)),
            onClick: clicks.add,
            children: const [
              SemiAnchorLink(href: '#sec1', title: 'Dup A'),
              SemiAnchorLink(href: '#sec1', title: 'Dup B'),
              SemiAnchorLink(href: '#', title: 'Hash'),
              SemiAnchorLink(href: '#ghost', title: 'Ghost'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = const SemiThemeData.light();
      // 重复 href 双高亮：active 按 href 匹配 → 两行同时高亮。
      controller.jumpTo(100);
      await tester.pump();
      expect(titleColor(tester, 'Dup A'), t.colors.colorText0);
      expect(titleColor(tester, 'Dup B'), t.colors.colorText0);
      // ★`'#'`/非法 id（缺目标）→ spy 恒 -Infinity 永不激活
      // （index.tsx:172-176 try/catch quirk）。
      for (final offset in [0.0, 100.0, 400.0]) {
        controller.jumpTo(offset);
        await tester.pump();
        expect(titleColor(tester, 'Hash'), t.colors.colorText2);
        expect(titleColor(tester, 'Ghost'), t.colors.colorText2);
      }
      // ★`'#'` 点击惰性（上游 document.querySelector('#') 抛出 quirk）：
      // 不激活、不发 onClick。
      await neutralTap(tester);
      await tester.tap(find.text('Hash'));
      await tester.pump();
      expect(clicks, isEmpty);
      expect(titleColor(tester, 'Hash'), t.colors.colorText2);
      // ★缺目标的合法 id 点击仍高亮 + 发 onClick、不滚动
      // （current-location.test.js 口径照搬）。
      final offsetBefore = controller.offset;
      await neutralTap(tester);
      await tester.tap(find.text('Ghost'));
      await tester.pump();
      expect(clicks, ['#ghost']);
      expect(titleColor(tester, 'Ghost'), t.colors.colorText0);
      expect(controller.offset, offsetBefore);
    });

    testWidgets('RTL：缩进/滑轨翻边（rtl.scss:8-15 + link.tsx:146-151）', (
      tester,
    ) async {
      await pumpHost(
        tester,
        anchor(
          defaultAnchor: '#p',
          children: const [
            SemiAnchorLink(
              href: '#p',
              title: 'L1',
              children: [SemiAnchorLink(href: '#c', title: 'L2')],
            ),
          ],
        ),
        direction: TextDirection.rtl,
      );
      await tester.pumpAndSettle();
      final rootRight = tester.getTopRight(find.byKey(SemiAnchor.rootKey)).dx;
      // 缩进翻 paddingRight：8 * level 自右缘量。
      expect(
        rootRight - tester.getTopRight(find.text('L1')).dx,
        moreOrLessEquals(8, epsilon: 1),
      );
      expect(
        rootRight - tester.getTopRight(find.text('L2')).dx,
        moreOrLessEquals(16, epsilon: 1),
      );
      // 滑轨翻右边（rtl.scss:8-11 `right: $spacing-anchor_slide-left`）。
      final trackRight = tester
          .getTopRight(find.byKey(SemiAnchor.slideTrackKey))
          .dx;
      expect(trackRight, moreOrLessEquals(rootRight, epsilon: 2));
    });
  });
}
