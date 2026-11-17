// Behavior matrix for SemiFloatButton / SemiFloatButtonGroup plus coverage for
// the 39 Sass declarations (39 FIELDS + 0 MOTION + 0 INTERNAL) — the 31
// HARDCODES provenance anchors live in the widget's `_FloatButtonMetrics` /
// call sites; 2 FIELDS are dead variables (上游未消费 — the widget must not
// read them) and the 2 z fields are comment references only (★无 z-index
// Flutter 槽).
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

// -- fixtures ----------------------------------------------------------------

const _stackKey = ValueKey('SemiFloatButtonHostStack');

/// 宿主页面：Stack（★FloatButton/Group 是 PositionedDirectional——需 Stack
/// 直接子节点位）。
Widget floatPage(Widget float) =>
    Stack(key: _stackKey, children: [const SizedBox.expand(), float]);

Widget floatButton({
  SemiFloatButtonShape shape = SemiFloatButtonShape.round,
  SemiFloatButtonSize size = SemiFloatButtonSize.defaultSize,
  bool colorful = false,
  bool disabled = false,
  Widget? icon,
  SemiFloatButtonBadge? badge,
  VoidCallback? onClick,
  String? href,
  String? target,
  String? semanticsLabel,
}) => SemiFloatButton(
  shape: shape,
  size: size,
  colorful: colorful,
  disabled: disabled,
  icon: icon,
  badge: badge,
  onClick: onClick,
  href: href,
  target: target,
  semanticsLabel: semanticsLabel,
);

Widget floatGroup({
  List<SemiFloatButtonGroupItem> items = const [],
  bool disabled = false,
  void Function(String? value, SemiFloatButtonGroupClickEvent event)? onClick,
  String? semanticsLabel,
}) => SemiFloatButtonGroup(
  items: items,
  disabled: disabled,
  onClick: onClick,
  semanticsLabel: semanticsLabel,
);

Offset stackTopLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(_stackKey));

BoxDecoration bodyBox(WidgetTester tester) =>
    tester.widget<Container>(find.byKey(SemiFloatButton.bodyKey)).decoration!
        as BoxDecoration;

BoxDecoration groupBox(WidgetTester tester) =>
    tester
            .widget<Container>(find.byKey(SemiFloatButtonGroup.groupKey))
            .decoration!
        as BoxDecoration;

/// Text 构建的 RichText（DefaultTextStyle 解析后的生效样式）。
RichText richTextOf(WidgetTester tester, String text) =>
    tester.widget<RichText>(
      find.descendant(of: find.text(text), matching: find.byType(RichText)),
    );

Color? iconColor(WidgetTester tester, {String text = 'I'}) =>
    richTextOf(tester, text).text.style?.color;

SemiResolvedFloatButtonThemeData resolved() =>
    const SemiFloatButtonThemeData().resolve(const SemiThemeData.light());

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiFloatButtonThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedFloatButtonThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$spacing-floatButton-bottom: 24px',
    101.0,
    (v) => SemiFloatButtonThemeData(spacingFloatButtonBottom: v as double),
    (d) => d.spacingFloatButtonBottom,
    (t) => 24.0,
  ),
  (
    r'$spacing-floatButton-right: 24px',
    102.0,
    (v) => SemiFloatButtonThemeData(spacingFloatButtonRight: v as double),
    (d) => d.spacingFloatButtonRight,
    (t) => 24.0,
  ),
  (
    r'$spacing-floatButton_group-bottom: 24px',
    103.0,
    (v) => SemiFloatButtonThemeData(spacingFloatButtonGroupBottom: v as double),
    (d) => d.spacingFloatButtonGroupBottom,
    (t) => 24.0,
  ),
  (
    r'$spacing-floatButton_group-right: 24px',
    104.0,
    (v) => SemiFloatButtonThemeData(spacingFloatButtonGroupRight: v as double),
    (d) => d.spacingFloatButtonGroupRight,
    (t) => 24.0,
  ),
  (
    r'$spacing-floatButton_group-padding: 6px',
    105.0,
    (v) =>
        SemiFloatButtonThemeData(spacingFloatButtonGroupPadding: v as double),
    (d) => d.spacingFloatButtonGroupPadding,
    (t) => 6.0,
  ),
  (
    r'$spacing-floatButton_group-columnGap: 4px',
    106.0,
    (v) =>
        SemiFloatButtonThemeData(spacingFloatButtonGroupColumnGap: v as double),
    (d) => d.spacingFloatButtonGroupColumnGap,
    (t) => 4.0,
  ),
  (
    r'$spacing-floatButton_group_item-paddingX: 12px',
    107.0,
    (v) => SemiFloatButtonThemeData(
      spacingFloatButtonGroupItemPaddingX: v as double,
    ),
    (d) => d.spacingFloatButtonGroupItemPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-floatButton_group_item-paddingY: 6px',
    108.0,
    (v) => SemiFloatButtonThemeData(
      spacingFloatButtonGroupItemPaddingY: v as double,
    ),
    (d) => d.spacingFloatButtonGroupItemPaddingY,
    (t) => 6.0,
  ),
  (
    r'$spacing-floatButton_group_item-columnGap: 8px',
    109.0,
    (v) => SemiFloatButtonThemeData(
      spacingFloatButtonGroupItemColumnGap: v as double,
    ),
    (d) => d.spacingFloatButtonGroupItemColumnGap,
    (t) => 8.0,
  ),
  (
    r'$width-floatButton_small: 24px',
    110.0,
    (v) => SemiFloatButtonThemeData(widthFloatButtonSmall: v as double),
    (d) => d.widthFloatButtonSmall,
    (t) => 24.0,
  ),
  (
    r'$width-floatButton: 32px',
    111.0,
    (v) => SemiFloatButtonThemeData(widthFloatButton: v as double),
    (d) => d.widthFloatButton,
    (t) => 32.0,
  ),
  (
    r'$width-floatButton_large: 40px',
    112.0,
    (v) => SemiFloatButtonThemeData(widthFloatButtonLarge: v as double),
    (d) => d.widthFloatButtonLarge,
    (t) => 40.0,
  ),
  (
    r'$color-floatButton-bg:  var(--semi-color-fill-0)',
    const Color(0xFF010101),
    (v) => SemiFloatButtonThemeData(colorFloatButtonBg: v as Color),
    (d) => d.colorFloatButtonBg,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-floatButton-text:  var(--semi-color-primary)',
    const Color(0xFF020202),
    (v) => SemiFloatButtonThemeData(colorFloatButtonText: v as Color),
    (d) => d.colorFloatButtonText,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-floatButton-bg-hover:  var(--semi-color-fill-1)',
    const Color(0xFF030303),
    (v) => SemiFloatButtonThemeData(colorFloatButtonBgHover: v as Color),
    (d) => d.colorFloatButtonBgHover,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-floatButton-bg-active:  var(--semi-color-fill-2)',
    const Color(0xFF040404),
    (v) => SemiFloatButtonThemeData(colorFloatButtonBgActive: v as Color),
    (d) => d.colorFloatButtonBgActive,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-floatButton-disabled-bg:  var(--semi-color-disabled-bg)',
    const Color(0xFF050505),
    (v) => SemiFloatButtonThemeData(colorFloatButtonDisabledBg: v as Color),
    (d) => d.colorFloatButtonDisabledBg,
    (t) => t.colors.colorDisabledBg,
  ),
  (
    r'$color-floatButton-disabled-text:  var(--semi-color-disabled-text)',
    const Color(0xFF060606),
    (v) => SemiFloatButtonThemeData(colorFloatButtonDisabledText: v as Color),
    (d) => d.colorFloatButtonDisabledText,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-floatButton-colorful-bg:  var(--semi-color-ai-general)',
    SemiGradient(
      45,
      const [Color(0xFF070707), Color(0xFF171717)],
      const [0, 1],
    ),
    (v) =>
        SemiFloatButtonThemeData(colorFloatButtonColorfulBg: v as SemiGradient),
    (d) => d.colorFloatButtonColorfulBg,
    (t) => t.colors.colorAiGeneral,
  ),
  (
    r'$color-floatButton-colorful-text:  var(--semi-color-white)',
    const Color(0xFF080808),
    (v) => SemiFloatButtonThemeData(colorFloatButtonColorfulText: v as Color),
    (d) => d.colorFloatButtonColorfulText,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-floatButton-colorful-bg-hover:  var(--semi-color-ai-general-hover)',
    SemiGradient(
      60,
      const [Color(0xFF090909), Color(0xFF191919)],
      const [0, 1],
    ),
    (v) => SemiFloatButtonThemeData(
      colorFloatButtonColorfulBgHover: v as SemiGradient,
    ),
    (d) => d.colorFloatButtonColorfulBgHover,
    (t) => t.colors.colorAiGeneralHover,
  ),
  (
    r'$color-floatButton-colorful-bg-active:  var(--semi-color-ai-general-active)',
    SemiGradient(
      30,
      const [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
      const [0, 1],
    ),
    (v) => SemiFloatButtonThemeData(
      colorFloatButtonColorfulBgActive: v as SemiGradient,
    ),
    (d) => d.colorFloatButtonColorfulBgActive,
    (t) => t.colors.colorAiGeneralActive,
  ),
  (
    r'$color-floatButton_group-bg:  var(--semi-color-bg-0)',
    const Color(0xFF0B0B0B),
    (v) => SemiFloatButtonThemeData(colorFloatButtonGroupBg: v as Color),
    (d) => d.colorFloatButtonGroupBg,
    (t) => t.colors.colorBg0,
  ),
  (
    r'$color-floatButton_group_item-text:  var(--semi-color-text-0)',
    const Color(0xFF0C0C0C),
    (v) => SemiFloatButtonThemeData(colorFloatButtonGroupItemText: v as Color),
    (d) => d.colorFloatButtonGroupItemText,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-floatButton_group_item-bg-hover:  var(--semi-color-fill-1)',
    const Color(0xFF0D0D0D),
    (v) =>
        SemiFloatButtonThemeData(colorFloatButtonGroupItemBgHover: v as Color),
    (d) => d.colorFloatButtonGroupItemBgHover,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-floatButton_group_item-bg-active:  var(--semi-color-fill-2)',
    const Color(0xFF0E0E0E),
    (v) =>
        SemiFloatButtonThemeData(colorFloatButtonGroupItemBgActive: v as Color),
    (d) => d.colorFloatButtonGroupItemBgActive,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-floatButton_group-disabled-bg:  var(--semi-color-disabled-bg)',
    const Color(0xFF0F0F0F),
    (v) =>
        SemiFloatButtonThemeData(colorFloatButtonGroupDisabledBg: v as Color),
    (d) => d.colorFloatButtonGroupDisabledBg,
    (t) => t.colors.colorDisabledBg,
  ),
  (
    r'$color-floatButton_group-disabled-text:  var(--semi-color-disabled-text)',
    const Color(0xFF101010),
    (v) =>
        SemiFloatButtonThemeData(colorFloatButtonGroupDisabledText: v as Color),
    (d) => d.colorFloatButtonGroupDisabledText,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$z-floatButton: 1000',
    42,
    (v) => SemiFloatButtonThemeData(zFloatButton: v as int),
    (d) => d.zFloatButton,
    (t) => 1000,
  ),
  (
    r'$z-floatButton_group: 1000',
    43,
    (v) => SemiFloatButtonThemeData(zFloatButtonGroup: v as int),
    (d) => d.zFloatButtonGroup,
    (t) => 1000,
  ),
  (
    r'$radius-floatButton_square: 8px',
    113.0,
    (v) => SemiFloatButtonThemeData(radiusFloatButtonSquare: v as double),
    (d) => d.radiusFloatButtonSquare,
    (t) => 8.0,
  ),
  (
    r'$radius-floatButton_round: var(--semi-border-radius-full)',
    114.0,
    (v) => SemiFloatButtonThemeData(radiusFloatButtonRound: v as double),
    (d) => d.radiusFloatButtonRound,
    (t) => t.radius.borderRadiusFull.value,
  ),
  (
    r'$radius-floatButton_group-border-radius: 8px',
    115.0,
    (v) => SemiFloatButtonThemeData(
      radiusFloatButtonGroupBorderRadius: v as double,
    ),
    (d) => d.radiusFloatButtonGroupBorderRadius,
    (t) => 8.0,
  ),
  (
    r'$radius-floatButton_group_item-border-radius: 4px',
    116.0,
    (v) => SemiFloatButtonThemeData(
      radiusFloatButtonGroupItemBorderRadius: v as double,
    ),
    (d) => d.radiusFloatButtonGroupItemBorderRadius,
    (t) => 4.0,
  ),
  (
    r'$font-floatButton_group_item-fontWeight: 400',
    FontWeight.w700,
    (v) => SemiFloatButtonThemeData(
      fontFloatButtonGroupItemFontWeight: v as FontWeight,
    ),
    (d) => d.fontFloatButtonGroupItemFontWeight,
    (t) => FontWeight.w400,
  ),
  (
    r'$font-floatButton_group_item-lineHeight: 20px',
    117.0,
    (v) => SemiFloatButtonThemeData(
      fontFloatButtonGroupItemLineHeight: v as double,
    ),
    (d) => d.fontFloatButtonGroupItemLineHeight,
    (t) => 20.0,
  ),
  (
    r'$font-floatButton_group_item-fontSize: 14px',
    118.0,
    (v) =>
        SemiFloatButtonThemeData(fontFloatButtonGroupItemFontSize: v as double),
    (d) => d.fontFloatButtonGroupItemFontSize,
    (t) => 14.0,
  ),
  (
    r'$shadow-floatButton_group: var(--semi-shadow-elevated)',
    SemiShadows([const SemiShadowLayer(false, 1, 2, 3, 4, Color(0xFF111111))]),
    (v) => SemiFloatButtonThemeData(shadowFloatButtonGroup: v as SemiShadows),
    (d) => d.shadowFloatButtonGroup,
    (t) => t.shadows.shadowElevated,
  ),
  (
    r'$shadow-floatButton: var(--semi-shadow-elevated)',
    SemiShadows([const SemiShadowLayer(false, 5, 6, 7, 8, Color(0xFF121212))]),
    (v) => SemiFloatButtonThemeData(shadowFloatButton: v as SemiShadows),
    (d) => d.shadowFloatButton,
    (t) => t.shadows.shadowElevated,
  ),
];

const deadFieldNames = [
  'colorFloatButtonGroupDisabledBg',
  'colorFloatButtonGroupDisabledText',
];

void main() {
  group('theme fields (39 = 39 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('39 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(39));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiFloatButtonThemeData().merge(patch),
          patch,
          reason: sass,
        );
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
          read(const SemiFloatButtonThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiFloatButtonThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_float_button_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(39));
    });

    test('the 31 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_float_button.dart')
          .readAsStringSync();
      final anchors = <String>[
        "SHAPE: ['square', 'round']",
        "SIZE: ['small', 'default', 'large']",
        "shape: 'round'",
        'colorful: false',
        "size: 'default'",
        "window.open(href, '_blank')",
        'window.location.href = href',
        'position: fixed',
        'cursor: pointer',
        'cursor: not-allowed',
        'display: flex',
        'align-items: center',
        'justify-content: center',
        r'top: calc(0.29 * $radius-floatButton_square)',
        r'inset-inline-end: calc(0.29 * $radius-floatButton_square)',
        r'top: calc(0.29 * 0.5 * $width-floatButton)',
        r'inset-inline-end: calc(0.29 * 0.5 * $width-floatButton)',
        r'top: calc(0.29 * 0.5 * $width-floatButton_small)',
        r'inset-inline-end: calc(0.29 * 0.5 *$width-floatButton_small)',
        r'top: calc(0.29 * 0.5 * $width-floatButton_large)',
        r'inset-inline-end: calc(0.29 * 0.5 * $width-floatButton_large)',
        'display: inline-flex',
        'font-style: normal',
        "type: 'default'",
        "size: 'medium'",
        'e.target.closest',
        'item.dataset.value',
        'e.stopPropagation()',
        "window.open(item.href, '_blank')",
        'window.location.href = item.href',
        'this.props.onClick?.(value, e)',
      ];
      expect(anchors, hasLength(31));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 13 Color + 3 SemiGradient + 2 SemiShadows + '
        '1 FontWeight + 18 double + 2 int', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts, {
        'Color': 13,
        'SemiGradient': 3,
        'SemiShadows': 2,
        'FontWeight': 1,
        'double': 18,
        'int': 2,
      });
    });

    test('2 dead FIELDS (上游未消费) + 2 z 留档不消费', () {
      // floatButton.scss 的组容器无 `-disabled` 规则——两条 group disabled
      // 字段死变量留档不消费，widget 不得读。
      final source = File('lib/src/theme/semi_float_button_theme_data.dart')
          .readAsStringSync();
      expect(
        'dead variable (上游未消费)'.allMatches(source).length,
        greaterThanOrEqualTo(2),
      );
      final widgetSource = File('lib/src/components/semi_float_button.dart')
          .readAsStringSync();
      for (final name in deadFieldNames) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      // ★z 无 Flutter z-index 槽——注释引用（transitionDelayAnchorTitleText
      // 先例）。
      expect(widgetSource, contains('zFloatButton'));
      expect(widgetSource, contains('zFloatButtonGroup'));
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().floatButton,
        const SemiFloatButtonThemeData(),
      );
      const patch = SemiFloatButtonThemeData(spacingFloatButtonRight: 32);
      const themes = SemiComponentThemes(floatButton: patch);
      expect(const SemiComponentThemes().copyWith(floatButton: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.floatButton, patch);
    });

    testWidgets('SemiFloatButtonTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      await tester.pumpWidget(
        host(
          SemiTheme(
            data: const SemiThemeData.light(),
            child: SemiFloatButtonTheme(
              data: const SemiFloatButtonThemeData(spacingFloatButtonRight: 64),
              child: SemiFloatButtonTheme(
                data: const SemiFloatButtonThemeData(
                  spacingFloatButtonBottom: 16,
                ),
                child: floatPage(floatButton(onClick: () {})),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = tester.getRect(find.byKey(SemiFloatButton.bodyKey));
      // Outer patch field (right 64) + inner patch field (bottom 16)——
      // 内层只赢自己的字段。
      expect(rect.right, stack.dx + 900 - 64);
      expect(rect.bottom, stack.dy + 900 - 16);
    });
  });

  group('尺寸与形状', () {
    testWidgets('三尺寸 24/32/40（width-floatButton_small/默认/_large）', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      for (final (size, edge) in [
        (SemiFloatButtonSize.small, 24.0),
        (SemiFloatButtonSize.defaultSize, 32.0),
        (SemiFloatButtonSize.large, 40.0),
      ]) {
        await tester.pumpWidget(
          host(floatPage(floatButton(size: size, icon: const Text('I')))),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byKey(SemiFloatButton.bodyKey)),
          Size(edge, edge),
          reason: '$size',
        );
      }
    });

    testWidgets('square 8 圆角 / round 全圆（radius-floatButton_square/_round）', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      final t = resolved();
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              shape: SemiFloatButtonShape.square,
              icon: const Text('I'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(bodyBox(tester).borderRadius, BorderRadius.circular(8));
      expect(
        bodyBox(tester).borderRadius,
        BorderRadius.circular(t.radiusFloatButtonSquare),
      );

      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              shape: SemiFloatButtonShape.round,
              icon: const Text('I'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        bodyBox(tester).borderRadius,
        BorderRadius.circular(t.radiusFloatButtonRound),
      );
      expect(t.radiusFloatButtonRound, 9999.0);
    });
  });

  group('状态配色', () {
    testWidgets('缺省/hover/active/disabled 四态 + 状态字色', (tester) async {
      final t = resolved();
      final gesture = await startMouse(tester);
      await tester.pumpWidget(
        host(floatPage(floatButton(icon: const Text('I'), onClick: () {}))),
      );
      await tester.pumpAndSettle();
      expect(bodyBox(tester).color, t.colorFloatButtonBg);
      expect(iconColor(tester), t.colorFloatButtonText);

      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiFloatButton.bodyKey)),
      );
      await tester.pump();
      expect(bodyBox(tester).color, t.colorFloatButtonBgHover);

      await gesture.down(tester.getCenter(find.byKey(SemiFloatButton.bodyKey)));
      await tester.pump();
      expect(bodyBox(tester).color, t.colorFloatButtonBgActive);
      await gesture.up();
      await tester.pump();

      await tester.pumpWidget(
        host(floatPage(floatButton(disabled: true, icon: const Text('I')))),
      );
      await tester.pumpAndSettle();
      expect(bodyBox(tester).color, t.colorFloatButtonDisabledBg);
      expect(iconColor(tester), t.colorFloatButtonDisabledText);
    });

    testWidgets('colorful 渐变三态 + 白字（ai-general 渐变 token）', (tester) async {
      final t = resolved();
      final gesture = await startMouse(tester);
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(colorful: true, icon: const Text('I'), onClick: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      LinearGradient gradient() => bodyBox(tester).gradient! as LinearGradient;
      expect(gradient().colors, t.colorFloatButtonColorfulBg.colors);
      expect(iconColor(tester), t.colorFloatButtonColorfulText);

      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiFloatButton.bodyKey)),
      );
      await tester.pump();
      expect(gradient().colors, t.colorFloatButtonColorfulBgHover.colors);

      await gesture.down(tester.getCenter(find.byKey(SemiFloatButton.bodyKey)));
      await tester.pump();
      expect(gradient().colors, t.colorFloatButtonColorfulBgActive.colors);
      await gesture.up();
    });

    testWidgets('★colorful + disabled 类级联：多彩视觉胜出 + not-allowed 光标 '
        '（floatButton.scss:31-53 quirk）', (tester) async {
      final t = resolved();
      var clicks = 0;
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              colorful: true,
              disabled: true,
              icon: const Text('I'),
              onClick: () => clicks++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // `-colorful` 在 `-disabled` 后——多彩渐变胜出，字色白。
      expect(bodyBox(tester).gradient, isNotNull);
      expect(bodyBox(tester).color, isNull);
      expect(iconColor(tester), t.colorFloatButtonColorfulText);
      // `cursor: not-allowed` 残留。
      final region = tester.widget<MouseRegion>(
        find.ancestor(
          of: find.byKey(SemiFloatButton.bodyKey),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(region.cursor, SystemMouseCursors.forbidden);
      // 点击断路。
      await tester.tap(find.byKey(SemiFloatButton.bodyKey));
      await tester.pump();
      expect(clicks, 0);
    });

    testWidgets('鼠标光标 click / 禁用 forbidden（floatButton.scss:12/34）', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(floatPage(floatButton(icon: const Text('I'), onClick: () {}))),
      );
      await tester.pumpAndSettle();
      var region = tester.widget<MouseRegion>(
        find.ancestor(
          of: find.byKey(SemiFloatButton.bodyKey),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(region.cursor, SystemMouseCursors.click);

      await tester.pumpWidget(
        host(floatPage(floatButton(disabled: true, icon: const Text('I')))),
      );
      await tester.pumpAndSettle();
      region = tester.widget<MouseRegion>(
        find.ancestor(
          of: find.byKey(SemiFloatButton.bodyKey),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(region.cursor, SystemMouseCursors.forbidden);
    });
  });

  group('点击与禁用', () {
    testWidgets('点击回传 onClick；disabled 断路（index.tsx:30 口径）', (tester) async {
      var clicks = 0;
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(icon: const Text('I'), onClick: () => clicks++),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButton.bodyKey));
      await tester.pump();
      expect(clicks, 1);

      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              disabled: true,
              icon: const Text('I'),
              onClick: () => clicks++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiFloatButton.bodyKey),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(clicks, 1);
    });

    testWidgets('Enter 键盘激活（★上游无键盘激活补强）', (tester) async {
      var clicks = 0;
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(icon: const Text('I'), onClick: () => clicks++),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final focus = tester
          .widget<Focus>(
            find.byWidgetPredicate(
              (w) => w is Focus && w.focusNode?.debugLabel == 'SemiFloatButton',
            ),
          )
          .focusNode!;
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(clicks, 1);
    });

    testWidgets('semanticsLabel 上达 Semantics（★上游无 aria-label 补强）', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          floatPage(
            // 语义测试用无文本图标（Text 会把 label 并入文字节点）。
            floatButton(
              icon: const SizedBox(width: 16, height: 16),
              semanticsLabel: '悬浮',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('悬浮'), findsOneWidget);
    });
  });

  group('徽章骑圆角', () {
    testWidgets('方形：inset = 0.29 * 8（radius-floatButton_square）', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              shape: SemiFloatButtonShape.square,
              icon: const Text('I'),
              badge: const SemiFloatButtonBadge(dot: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final positioned = tester.widget<PositionedDirectional>(
        find.byKey(SemiFloatButton.badgeAnchorKey),
      );
      // floatButton.scss:64-65 `top: calc(0.29 * $radius-floatButton_square)`。
      expect(positioned.top, closeTo(0.29 * 8, 0.001));
      expect(positioned.end, closeTo(0.29 * 8, 0.001));
    });

    testWidgets('圆形：inset = 0.29 * 0.5 * 边长（三尺寸 calc 口径）', (tester) async {
      for (final (size, edge) in [
        (SemiFloatButtonSize.small, 24.0),
        (SemiFloatButtonSize.defaultSize, 32.0),
        (SemiFloatButtonSize.large, 40.0),
      ]) {
        await tester.pumpWidget(
          host(
            floatPage(
              floatButton(
                size: size,
                icon: const Text('I'),
                badge: const SemiFloatButtonBadge(dot: true),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final positioned = tester.widget<PositionedDirectional>(
          find.byKey(SemiFloatButton.badgeAnchorKey),
        );
        expect(
          positioned.top,
          closeTo(0.29 * 0.5 * edge, 0.001),
          reason: '$size',
        );
        expect(
          positioned.end,
          closeTo(0.29 * 0.5 * edge, 0.001),
          reason: '$size',
        );
      }
    });

    testWidgets('badge count/dot 渲染 + 默认角 translate(0.5, -0.5)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              icon: const Text('I'),
              badge: const SemiFloatButtonBadge(count: 3),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SemiBadge), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      final translation = tester.widget<FractionalTranslation>(
        find.ancestor(
          of: find.byType(SemiBadge),
          matching: find.byType(FractionalTranslation),
        ),
      );
      expect(translation.translation, const Offset(0.5, -0.5));

      await tester.pumpWidget(
        host(floatPage(floatButton(icon: const Text('I')))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SemiBadge), findsNothing);
    });
  });

  group('定位与 RTL', () {
    testWidgets('LTR：end 24 / bottom 24（floatButton.scss:9-10）', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(floatPage(floatButton(icon: const Text('I'), onClick: () {}))),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = tester.getRect(find.byKey(SemiFloatButton.bodyKey));
      expect(rect.right, stack.dx + 900 - 24);
      expect(rect.bottom, stack.dy + 900 - 24);
    });

    testWidgets('RTL：end 翻左 + badge translate 翻 -0.5', (tester) async {
      await tester.pumpWidget(
        host(
          floatPage(
            floatButton(
              icon: const Text('I'),
              badge: const SemiFloatButtonBadge(dot: true),
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = tester.getRect(find.byKey(SemiFloatButton.bodyKey));
      expect(rect.left, stack.dx + 24);
      final translation = tester.widget<FractionalTranslation>(
        find.ancestor(
          of: find.byType(SemiBadge),
          matching: find.byType(FractionalTranslation),
        ),
      );
      expect(translation.translation, const Offset(-0.5, -0.5));
    });

    testWidgets('主题覆盖 spacing 生效（全局 SemiComponentThemes）', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light().copyWith(
            components: const SemiComponentThemes(
              floatButton: SemiFloatButtonThemeData(
                spacingFloatButtonRight: 64,
                spacingFloatButtonBottom: 16,
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 900)),
              child: Center(
                child: SizedBox(
                  width: 900,
                  height: 900,
                  child: floatPage(
                    floatButton(icon: const Text('I'), onClick: () {}),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = tester.getRect(find.byKey(SemiFloatButton.bodyKey));
      expect(rect.right, stack.dx + 900 - 64);
      expect(rect.bottom, stack.dy + 900 - 16);
    });
  });

  group('悬浮按钮组', () {
    List<SemiFloatButtonGroupItem> items({
      void Function(SemiFloatButtonGroupClickEvent)? first,
    }) => [
      SemiFloatButtonGroupItem(
        value: 'help',
        icon: const Text('H'),
        content: '帮助',
        onClick: first,
      ),
      SemiFloatButtonGroupItem(
        value: 'search',
        icon: const Text('S'),
        content: '搜索',
      ),
    ];

    testWidgets('组盒：padding 6 / 圆角 8 / 背景与阴影（floatButton.scss:124-134）', (
      tester,
    ) async {
      final t = resolved();
      await tester.pumpWidget(host(floatPage(floatGroup(items: items()))));
      await tester.pumpAndSettle();
      final container = tester.widget<Container>(
        find.byKey(SemiFloatButtonGroup.groupKey),
      );
      expect(container.padding, const EdgeInsets.all(6));
      expect(
        container.padding,
        EdgeInsets.all(t.spacingFloatButtonGroupPadding),
      );
      final box = groupBox(tester);
      expect(box.color, t.colorFloatButtonGroupBg);
      expect(box.borderRadius, BorderRadius.circular(8));
      expect(box.boxShadow, t.shadowFloatButtonGroup.toBoxShadows());
    });

    testWidgets('子项行：padding 12×6 / 圆角 4 / 文字样式四件 / 内容间距 8', (tester) async {
      final t = resolved();
      await tester.pumpWidget(host(floatPage(floatGroup(items: items()))));
      await tester.pumpAndSettle();
      final itemContainer = tester.widget<Container>(
        find.descendant(
          of: find.byKey(SemiFloatButtonGroup.itemKey(0)),
          matching: find.byType(Container),
        ),
      );
      expect(
        itemContainer.padding,
        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      );
      expect(
        (itemContainer.decoration! as BoxDecoration).borderRadius,
        BorderRadius.circular(4),
      );
      // `content` 文字走 DefaultTextStyle 级联（color/fontSize/height/fontWeight）。
      final style = richTextOf(tester, '帮助').text.style!;
      expect(style.color, t.colorFloatButtonGroupItemText);
      expect(style.fontSize, t.fontFloatButtonGroupItemFontSize);
      expect(
        style.height,
        t.fontFloatButtonGroupItemLineHeight /
            t.fontFloatButtonGroupItemFontSize,
      );
      expect(style.fontWeight, t.fontFloatButtonGroupItemFontWeight);
      // 子项内容间距 8（column-gap）。
      final row = tester.widget<Row>(
        find.descendant(
          of: find.byKey(SemiFloatButtonGroup.itemKey(0)),
          matching: find.byType(Row),
        ),
      );
      expect(row.spacing, t.spacingFloatButtonGroupItemColumnGap);
    });

    testWidgets('子项派发 value + 子项回调先于组回调（itemProps.test.jsx '
        '`[item, group]` 口径）', (tester) async {
      final calls = <String>[];
      String? groupValue;
      await tester.pumpWidget(
        host(
          floatPage(
            floatGroup(
              items: [
                SemiFloatButtonGroupItem(
                  value: 'help',
                  icon: const Text('H'),
                  content: '帮助',
                  onClick: (event) => calls.add('item'),
                ),
              ],
              onClick: (value, event) {
                calls.add('group');
                groupValue = value;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
      expect(calls, ['item', 'group']);
      expect(groupValue, 'help');
    });

    testWidgets('stopPropagation 断组回调（itemProps.test.jsx 口径）', (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(
        host(
          floatPage(
            floatGroup(
              items: [
                SemiFloatButtonGroupItem(
                  value: 'help',
                  content: '帮助',
                  onClick: (event) {
                    calls.add('item');
                    event.stopPropagation();
                  },
                ),
              ],
              onClick: (value, event) => calls.add('group'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
      expect(calls, ['item']);
    });

    testWidgets('禁用断路：组禁用 / 子项禁用均不达（groupClicks + itemProps '
        '口径）', (tester) async {
      final calls = <String>[];
      Widget page({bool groupDisabled = false, bool itemDisabled = false}) =>
          floatPage(
            floatGroup(
              disabled: groupDisabled,
              items: [
                SemiFloatButtonGroupItem(
                  value: 'help',
                  content: '帮助',
                  disabled: itemDisabled,
                  onClick: (event) => calls.add('item'),
                ),
              ],
              onClick: (value, event) => calls.add('group'),
            ),
          );

      await tester.pumpWidget(host(page(groupDisabled: true)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
      expect(calls, isEmpty);

      await tester.pumpWidget(host(page(itemDisabled: true)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
      expect(calls, isEmpty);

      // ★禁用态切换后立即生效（itemProps `reads the latest item disabled state`）。
      await tester.pumpWidget(host(page()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
      expect(calls, ['item', 'group']);
    });

    testWidgets('组背景点击不出组回调（groupClicks `background` 口径）+ '
        'onClick 缺省不抛', (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(
        host(
          floatPage(
            floatGroup(
              items: items(),
              onClick: (value, event) => calls.add('$value'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // 点组 padding 角落（非子项）。
      await tester.tapAt(
        tester.getTopLeft(find.byKey(SemiFloatButtonGroup.groupKey)) +
            const Offset(3, 3),
      );
      await tester.pump();
      expect(calls, isEmpty);

      // onClick 缺省（`supports an omitted onClick callback`）。
      await tester.pumpWidget(host(floatPage(floatGroup(items: items()))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
    });

    testWidgets('value 缺省回传 null（`item.dataset.value` 口径）', (tester) async {
      String? groupValue = 'sentinel';
      await tester.pumpWidget(
        host(
          floatPage(
            floatGroup(
              items: const [SemiFloatButtonGroupItem(content: '帮助')],
              onClick: (value, event) => groupValue = value,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      await tester.pump();
      expect(groupValue, isNull);
    });

    testWidgets('子项 hover/active 底色（floatButton.scss:149-155）', (tester) async {
      final t = resolved();
      final gesture = await startMouse(tester);
      await tester.pumpWidget(host(floatPage(floatGroup(items: items()))));
      await tester.pumpAndSettle();
      BoxDecoration itemBox() =>
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byKey(SemiFloatButtonGroup.itemKey(0)),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      expect(itemBox().color, isNull);
      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiFloatButtonGroup.itemKey(0))),
      );
      await tester.pump();
      expect(itemBox().color, t.colorFloatButtonGroupItemBgHover);
      await gesture.down(
        tester.getCenter(find.byKey(SemiFloatButtonGroup.itemKey(0))),
      );
      await tester.pump();
      expect(itemBox().color, t.colorFloatButtonGroupItemBgActive);
      await gesture.up();
    });

    testWidgets('badge 包裹子项（标准 Badge 锚定）', (tester) async {
      await tester.pumpWidget(
        host(
          floatPage(
            floatGroup(
              items: const [
                SemiFloatButtonGroupItem(
                  value: 'search',
                  content: '搜索',
                  badge: SemiFloatButtonBadge(count: 3),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(SemiFloatButtonGroup.itemKey(0)),
          matching: find.byType(SemiBadge),
        ),
        findsOneWidget,
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('★组/子项禁用无视觉差（quirk——`-disabled` 无样式规则，死变量为证）', (tester) async {
      final t = resolved();
      await tester.pumpWidget(
        host(floatPage(floatGroup(disabled: true, items: items()))),
      );
      await tester.pumpAndSettle();
      // 背景/文字样式与非禁用一致。
      expect(groupBox(tester).color, t.colorFloatButtonGroupBg);
      final style = richTextOf(tester, '帮助').text.style!;
      expect(style.color, t.colorFloatButtonGroupItemText);
      // 光标保持 pointer（:137 无禁用覆盖）。
      final region = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byKey(SemiFloatButtonGroup.itemKey(0)),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(region.cursor, SystemMouseCursors.click);
    });

    testWidgets('组定位：end 24 / bottom 24 + 子项 gap 4（columnGap）', (tester) async {
      await tester.pumpWidget(host(floatPage(floatGroup(items: items()))));
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = tester.getRect(find.byKey(SemiFloatButtonGroup.groupKey));
      expect(rect.right, stack.dx + 900 - 24);
      expect(rect.bottom, stack.dy + 900 - 24);
      final first = tester.getRect(find.byKey(SemiFloatButtonGroup.itemKey(0)));
      final second = tester.getRect(
        find.byKey(SemiFloatButtonGroup.itemKey(1)),
      );
      expect(second.left - first.right, 4);
    });
  });

  // dark 模式回归：dark 默认 `--semi-shadow-elevated` 首层为 `inset 0 0 0 1px`
  // （tokens_test 合同：`toBoxShadows()` 拒绝 inset）——渲染仅转换 drop 层
  // （card 先例，docs/semi_float_button.md 差异清单），不得抛 UnsupportedError。
  testWidgets('dark 模式渲染跳过 inset 阴影层', (tester) async {
    const dark = SemiThemeData.dark();
    final expected = [
      for (final layer in dark.shadows.shadowElevated.layers)
        if (!layer.inset) layer.toBoxShadow(),
    ];
    expect(expected, hasLength(1), reason: 'dark elevated = 1 inset + 1 drop');
    await tester.pumpWidget(
      host(
        SemiTheme(
          data: dark,
          child: floatPage(
            Stack(children: [
              floatButton(),
              floatGroup(
                items: const [
                  SemiFloatButtonGroupItem(
                    value: 'help',
                    icon: Text('H'),
                    content: '帮助',
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(bodyBox(tester).boxShadow, expected);
    expect(groupBox(tester).boxShadow, expected);
  });
}
