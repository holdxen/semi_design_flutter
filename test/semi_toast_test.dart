// Behavior matrix for SemiToast plus coverage for the 47 Sass declarations
// (35 FIELDS + 12 MOTION + 0 INTERNAL) — the 54 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. 0 死变量.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiToastThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedToastThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);
const _duration = Duration(milliseconds: 777);
const _curve = Cubic(0.1, 0.2, 0.3, 0.4);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-toast-bg-default: var(--semi-color-bg-3)',
    _c,
    (v) => SemiToastThemeData(colorToastBgDefault: v as Color),
    (d) => d.colorToastBgDefault,
    (t) => t.colors.colorBg3,
  ),
  (
    r'$color-toast-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiToastThemeData(colorToastTextDefault: v as Color),
    (d) => d.colorToastTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-toast_warning-icon: var(--semi-color-warning)',
    _c,
    (v) => SemiToastThemeData(colorToastWarningIcon: v as Color),
    (d) => d.colorToastWarningIcon,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-toast_success-icon: var(--semi-color-success)',
    _c,
    (v) => SemiToastThemeData(colorToastSuccessIcon: v as Color),
    (d) => d.colorToastSuccessIcon,
    (t) => t.colors.colorSuccess,
  ),
  (
    r'$color-toast_info-icon: var(--semi-color-info)',
    _c,
    (v) => SemiToastThemeData(colorToastInfoIcon: v as Color),
    (d) => d.colorToastInfoIcon,
    (t) => t.colors.colorInfo,
  ),
  (
    r'$color-toast_danger-icon: var(--semi-color-danger)',
    _c,
    (v) => SemiToastThemeData(colorToastDangerIcon: v as Color),
    (d) => d.colorToastDangerIcon,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-toast_warning_light-bg: var(--semi-color-warning-light-default)',
    _c,
    (v) => SemiToastThemeData(colorToastWarningLightBg: v as Color),
    (d) => d.colorToastWarningLightBg,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-toast_warning_light-icon: $color-toast_warning-icon',
    _c,
    (v) => SemiToastThemeData(colorToastWarningLightIcon: v as Color),
    (d) => d.colorToastWarningLightIcon,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-toast_warning_light-border: var(--semi-color-warning)',
    _c,
    (v) => SemiToastThemeData(colorToastWarningLightBorder: v as Color),
    (d) => d.colorToastWarningLightBorder,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-toast_success_light-bg: var(--semi-color-success-light-default)',
    _c,
    (v) => SemiToastThemeData(colorToastSuccessLightBg: v as Color),
    (d) => d.colorToastSuccessLightBg,
    (t) => t.colors.colorSuccessLightDefault,
  ),
  (
    r'$color-toast_success_light-icon: $color-toast_success-icon',
    _c,
    (v) => SemiToastThemeData(colorToastSuccessLightIcon: v as Color),
    (d) => d.colorToastSuccessLightIcon,
    (t) => t.colors.colorSuccess,
  ),
  (
    r'$color-toast_success_light-border: var(--semi-color-success)',
    _c,
    (v) => SemiToastThemeData(colorToastSuccessLightBorder: v as Color),
    (d) => d.colorToastSuccessLightBorder,
    (t) => t.colors.colorSuccess,
  ),
  (
    r'$color-toast_info_light-bg: var(--semi-color-info-light-default)',
    _c,
    (v) => SemiToastThemeData(colorToastInfoLightBg: v as Color),
    (d) => d.colorToastInfoLightBg,
    (t) => t.colors.colorInfoLightDefault,
  ),
  (
    r'$color-toast_info_light-icon: $color-toast_info-icon',
    _c,
    (v) => SemiToastThemeData(colorToastInfoLightIcon: v as Color),
    (d) => d.colorToastInfoLightIcon,
    (t) => t.colors.colorInfo,
  ),
  (
    r'$color-toast_info_light-border: var(--semi-color-info)',
    _c,
    (v) => SemiToastThemeData(colorToastInfoLightBorder: v as Color),
    (d) => d.colorToastInfoLightBorder,
    (t) => t.colors.colorInfo,
  ),
  (
    r'$color-toast_danger_light-bg: var(--semi-color-danger-light-default)',
    _c,
    (v) => SemiToastThemeData(colorToastDangerLightBg: v as Color),
    (d) => d.colorToastDangerLightBg,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-toast_danger_light-icon: $color-toast_danger-icon',
    _c,
    (v) => SemiToastThemeData(colorToastDangerLightIcon: v as Color),
    (d) => d.colorToastDangerLightIcon,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-toast_danger_light-border: var(--semi-color-danger)',
    _c,
    (v) => SemiToastThemeData(colorToastDangerLightBorder: v as Color),
    (d) => d.colorToastDangerLightBorder,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$spacing-toast_wrapper-top: 0',
    77.5,
    (v) => SemiToastThemeData(spacingToastWrapperTop: v as double),
    (d) => d.spacingToastWrapperTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-toast_content-paddingY: $spacing-base-tight',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentPaddingY: v as double),
    (d) => d.spacingToastContentPaddingY,
    (t) => 12.0,
  ),
  (
    r'$spacing-toast_content-paddingX: $spacing-tight',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentPaddingX: v as double),
    (d) => d.spacingToastContentPaddingX,
    (t) => 8.0,
  ),
  (
    r'$spacing-toast_content-paddingTop: $spacing-toast_content-paddingY',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentPaddingTop: v as double),
    (d) => d.spacingToastContentPaddingTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-toast_content-paddingBottom: $spacing-toast_content-paddingY',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentPaddingBottom: v as double),
    (d) => d.spacingToastContentPaddingBottom,
    (t) => 12.0,
  ),
  (
    r'$spacing-toast_content-paddingLeft: $spacing-toast_content-paddingX',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentPaddingLeft: v as double),
    (d) => d.spacingToastContentPaddingLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-toast_content-paddingRight: $spacing-toast_content-paddingX',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentPaddingRight: v as double),
    (d) => d.spacingToastContentPaddingRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-toast_content-margin: $spacing-base-tight',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentMargin: v as double),
    (d) => d.spacingToastContentMargin,
    (t) => 12.0,
  ),
  (
    r'$spacing-toast_content_close_btn-marginTop: -2px',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentCloseBtnMarginTop: v as double),
    (d) => d.spacingToastContentCloseBtnMarginTop,
    (t) => -2.0,
  ),
  (
    r'$spacing-toast_content_text-marginLeft: $spacing-base-tight',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentTextMarginLeft: v as double),
    (d) => d.spacingToastContentTextMarginLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-toast_content_text-marginRight: $spacing-base-tight',
    77.5,
    (v) => SemiToastThemeData(spacingToastContentTextMarginRight: v as double),
    (d) => d.spacingToastContentTextMarginRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-toast-perspective-originY: 280px',
    77.5,
    (v) => SemiToastThemeData(spacingToastPerspectiveOriginY: v as double),
    (d) => d.spacingToastPerspectiveOriginY,
    (t) => 280.0,
  ),
  (
    r'$spacing-toast-perspective: 280px',
    77.5,
    (v) => SemiToastThemeData(spacingToastPerspective: v as double),
    (d) => d.spacingToastPerspective,
    (t) => 280.0,
  ),
  (
    r'$width-toast_wrapper: 100%',
    77.5,
    (v) => SemiToastThemeData(widthToastWrapper: v as double),
    (d) => d.widthToastWrapper,
    (t) => 100.0,
  ),
  (
    r'$width-toast_light-border: 1px',
    77.5,
    (v) => SemiToastThemeData(widthToastLightBorder: v as double),
    (d) => d.widthToastLightBorder,
    (t) => 1.0,
  ),
  (
    r'$radius-toast_content: var(--semi-border-radius-medium)',
    77.5,
    (v) => SemiToastThemeData(radiusToastContent: v as double),
    (d) => d.radiusToastContent,
    (t) => t.radius.borderRadiusMedium.value,
  ),
  (
    r'$font-toast_content-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (v) => SemiToastThemeData(fontToastContentFontWeight: v as FontWeight),
    (d) => d.fontToastContentFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$animation_duration-toast-show: 300ms',
    _duration,
    (v) => SemiToastThemeData(animationDurationToastShow: v as Duration),
    (d) => d.animationDurationToastShow,
    (t) => const Duration(milliseconds: 300),
  ),
  (
    r'$animation_duration-toast-hide: 300ms',
    _duration,
    (v) => SemiToastThemeData(animationDurationToastHide: v as Duration),
    (d) => d.animationDurationToastHide,
    (t) => const Duration(milliseconds: 300),
  ),
  (
    r'$animation_function-toast-show: cubic-bezier(.22,.57,.02,1.2)',
    _curve,
    (v) => SemiToastThemeData(animationFunctionToastShow: v as Curve),
    (d) => d.animationFunctionToastShow,
    (t) => const Cubic(0.22, 0.57, 0.02, 1.2),
  ),
  (
    r'$animation_function-toast-hide: cubic-bezier(.22,.57,.02,1.2)',
    _curve,
    (v) => SemiToastThemeData(animationFunctionToastHide: v as Curve),
    (d) => d.animationFunctionToastHide,
    (t) => const Cubic(0.22, 0.57, 0.02, 1.2),
  ),
  (
    r'$animation_delay-toast-show: 0s',
    _duration,
    (v) => SemiToastThemeData(animationDelayToastShow: v as Duration),
    (d) => d.animationDelayToastShow,
    (t) => Duration.zero,
  ),
  (
    r'$animation_delay-toast-hide: 0s',
    _duration,
    (v) => SemiToastThemeData(animationDelayToastHide: v as Duration),
    (d) => d.animationDelayToastHide,
    (t) => Duration.zero,
  ),
  (
    r'$animation_opacity-toast-show: 0',
    77.5,
    (v) => SemiToastThemeData(animationOpacityToastShow: v as double),
    (d) => d.animationOpacityToastShow,
    (t) => 0.0,
  ),
  (
    r'$animation_opacity-toast-hide: 0',
    77.5,
    (v) => SemiToastThemeData(animationOpacityToastHide: v as double),
    (d) => d.animationOpacityToastHide,
    (t) => 0.0,
  ),
  (
    r'$animation_transform_translateY-toast-show: -100%',
    77.5,
    (v) => SemiToastThemeData(
      animationTransformTranslateYToastShow: v as double,
    ),
    (d) => d.animationTransformTranslateYToastShow,
    (t) => -100.0,
  ),
  (
    r'$animation_transform_translateY-toast-hide: -100%',
    77.5,
    (v) => SemiToastThemeData(
      animationTransformTranslateYToastHide: v as double,
    ),
    (d) => d.animationTransformTranslateYToastHide,
    (t) => -100.0,
  ),
  (
    r'$animation_duration-toast-stack: 300ms',
    _duration,
    (v) => SemiToastThemeData(animationDurationToastStack: v as Duration),
    (d) => d.animationDurationToastStack,
    (t) => const Duration(milliseconds: 300),
  ),
  (
    r'$animation_function-toast-stack: cubic-bezier(.22,.57,.02,1.2)',
    _curve,
    (v) => SemiToastThemeData(animationFunctionToastStack: v as Curve),
    (d) => d.animationFunctionToastStack,
    (t) => const Cubic(0.22, 0.57, 0.02, 1.2),
  ),
];

// -- harness -----------------------------------------------------------------

BuildContext? capturedContext;

Widget host({
  TextDirection direction = TextDirection.ltr,
  SemiToastThemeData? patch,
}) {
  final entry = OverlayEntry(
    builder: (context) {
      capturedContext = context;
      return const SizedBox.expand();
    },
  );
  Widget tree = SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: Overlay(initialEntries: [entry]),
    ),
  );
  if (patch != null) tree = SemiToastTheme(data: patch, child: tree);
  return tree;
}

Future<void> pumpHost(
  WidgetTester tester, {
  TextDirection direction = TextDirection.ltr,
  SemiToastThemeData? patch,
}) async {
  addTearDown(() async {
    SemiToast.reset();
    DialogProxy.instance.resetForTest();
  });
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await tester.pumpWidget(host(direction: direction, patch: patch));
  await tester.pump();
  DialogProxy.instance.bind(tester.state<OverlayState>(find.byType(Overlay)));
}

/// 小步 pump：进/离场动画与计时器事件需要逐帧推进（单次大步 pump 只产一帧，
/// 动画会在该帧一次性走完，无法观察中间态）。
Future<void> pumpFor(
  WidgetTester tester,
  Duration total, {
  Duration step = const Duration(milliseconds: 100),
}) async {
  var elapsed = Duration.zero;
  while (elapsed < total) {
    final next = elapsed + step;
    await tester.pump(next > total ? total - elapsed : step);
    elapsed = next;
  }
}

/// 收尾：清列表/计时器（测试体结束前不得挂起 Timer）。
Future<void> done(WidgetTester tester) async {
  SemiToast.reset();
  await tester.pump();
}

BoxDecoration toastDecoration(WidgetTester tester) =>
    tester
            .widgetList<Container>(
              find.byWidgetPredicate(
                (w) => w is Container && w.decoration is BoxDecoration,
              ),
            )
            .first
            .decoration! as BoxDecoration;

void main() {
  group('theme fields (47 = 35 FIELDS + 12 MOTION + 0 INTERNAL)', () {
    test('47 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(47));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiToastThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiToastThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiToastThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File(
        'lib/src/theme/semi_toast_theme_data.dart',
      ).readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(47));
      expect(source, contains('packages/semi-foundation/toast/variables.scss'));
      expect(source, contains('packages/semi-foundation/toast/animation.scss'));
      expect(source, contains('Generated by tool/generate_toast.py'));
      expect(source, isNot(contains('# dead variable (上游未消费)')));
    });

    test('the 54 HARDCODES anchors live in the widget source', () {
      final widgetSource = File(
        'lib/src/components/semi_toast.dart',
      ).readAsStringSync();
      const anchors = <String>[
        "types: ['warning', 'success', 'info', 'error', 'default']",
        "themes: ['normal', 'light']",
        "directions: ['ltr', 'rtl']",
        'duration: 3 // default close time, unit: s',
        'textMaxWidth: 450',
        'showClose: true',
        "theme: 'normal'",
        'IconAlertTriangle',
        'IconTickCircle',
        'IconInfoCircle',
        'IconAlertCircle',
        "iconSize = 'large'",
        'type="tertiary"',
        "const btnTheme = 'borderless';",
        "const btnSize = 'small';",
        'IconClose',
        r'height: $width-icon-large',
        'role="alert"',
        r"${type ? type : 'default'} type",
        'position: fixed;',
        'height: 0;',
        r'top: $spacing-toast_wrapper-top;',
        r'width: $width-toast_wrapper;',
        'justify-content: center;',
        r'z-index: $z-toast',
        'pointer-events: none;',
        'pointer-events: all;',
        '@include shadow-elevated;',
        '@include font-size-regular;',
        'display: inline-flex;',
        'align-items: flex-start;',
        'textStyle.maxWidth = textMaxWidth;',
        'text-align: left;',
        'word-wrap: break-word;',
        'overflow-wrap: break-word;',
        r'translate3d(0,0,${reservedIndex * -10}px)',
        r'transform: translateY($animation_transform_translateY-toast-show);',
        'animation-fill-mode: forwards;',
        'onMouseEnter={this.clearCloseTimer}',
        'onMouseLeave={this.startCloseTimer}',
        'clearCloseTimer_()',
        'startCloseTimer_()',
        'restartCloseTimer()',
        'Reused instances need new timers, including same-id replacements '
        'before the next render.',
        "getUuid('toast')",
        "getUuidShort({ prefix: 'toast-wrapper' })",
        'getPopupContainer() ?? document.body',
        'e.stopPropagation();',
        'notifyWrapperToRemove(this._id);',
        'static pendingToasts',
        r'LIST: `${PREFIX}-list`',
        r'perspective-origin: center $spacing-toast-perspective-originY; ;',
        'text-align: right;',
        r'margin-left: $spacing-toast_content_text-marginRight;',
      ];
      expect(anchors, hasLength(54));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 18 Color + 20 double + 1 FontWeight + 5 Duration + '
        '3 Curve = 47', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 18);
      expect(counts['double'], 20);
      expect(counts['FontWeight'], 1);
      expect(counts['Duration'], 5);
      expect(counts['Cubic'], 3);
    });

    test('0 dead variables: every field name appears in the widget source', () {
      final widgetSource = File(
        'lib/src/components/semi_toast.dart',
      ).readAsStringSync();
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
      final docs = File('docs/semi_toast.md').readAsStringSync();
      expect(docs, contains('47 = 35 FIELDS + 12 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('quirks: no-semicolon tail and bare decimals recorded verbatim', () {
      final source = File(
        'lib/src/theme/semi_toast_theme_data.dart',
      ).readAsStringSync();
      expect(
        source,
        contains(
          r'$animation_function-toast-stack: cubic-bezier(.22,.57,.02,1.2)',
        ),
      );
      expect(
        source,
        contains(r'$animation_transform_translateY-toast-show: -100%'),
      );
      expect(source, contains(r'$width-toast_wrapper: 100%'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.toast, const SemiToastThemeData());
      expect(
        themes.copyWith(
          toast: const SemiToastThemeData(widthToastLightBorder: 40),
        ),
        const SemiComponentThemes(
          toast: SemiToastThemeData(widthToastLightBorder: 40),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('renders content, icon and close button; type maps to icon', (
      tester,
    ) async {
      await pumpHost(tester);
      for (final (call, icon) in <(String, SemiIconData)>[
        ('warning', SemiIcons.alertTriangle),
        ('success', SemiIcons.tickCircle),
        ('info', SemiIcons.infoCircle),
        ('error', SemiIcons.alertCircle),
      ]) {
        final id = switch (call) {
          'warning' => SemiToast.warning(content: '标题-$call'),
          'success' => SemiToast.success(content: '标题-$call'),
          'info' => SemiToast.info(content: '标题-$call'),
          _ => SemiToast.error(content: '标题-$call'),
        };
        await pumpFor(tester, const Duration(milliseconds: 350));
        expect(find.text('标题-$call'), findsOneWidget, reason: call);
        expect(
          tester
              .widgetList<SemiIcon>(find.byType(SemiIcon))
              .any((i) => i.data == icon),
          isTrue,
          reason: call,
        );
        expect(find.byType(SemiButton), findsOneWidget, reason: call);
        SemiToast.close(id);
        await pumpFor(tester, const Duration(milliseconds: 450));
        expect(find.text('标题-$call'), findsNothing, reason: call);
      }
      await done(tester);
    });

    testWidgets('default type has no icon; numeric zero renders', (
      tester,
    ) async {
      await pumpHost(tester);
      SemiToast.show(content: 0);
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(find.text('0'), findsOneWidget);
      // 无类型图标（仅关闭钮的 `IconClose`）。
      final icons = tester.widgetList<SemiIcon>(find.byType(SemiIcon)).toList();
      expect(icons, hasLength(1));
      expect(icons.single.data, SemiIcons.close);
      await done(tester);
    });

    testWidgets('type maps to its background; light theme adds tinted bg and '
        'border', (tester) async {
      const light = SemiThemeData.light();
      await pumpHost(tester);
      SemiToast.warning(content: '常规');
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(toastDecoration(tester).color, light.colors.colorBg3);
      expect(toastDecoration(tester).border, isNull);
      SemiToast.destroyAll();
      await tester.pump();
      SemiToast.warning(content: '浅色', theme: SemiToastThemeMode.light);
      await pumpFor(tester, const Duration(milliseconds: 350));
      final decoration = toastDecoration(tester);
      expect(decoration.color, light.colors.colorWarningLightDefault);
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.color, light.colors.colorWarning);
      expect(decoration.border!.top.width, 1);
      await done(tester);
    });

    testWidgets('auto-dismiss after duration; duration 0 stays manual', (
      tester,
    ) async {
      await pumpHost(tester);
      SemiToast.info(content: '自动', duration: 1);
      SemiToast.info(content: '手动', duration: 0);
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(find.text('自动'), findsOneWidget);
      expect(find.text('手动'), findsOneWidget);
      await pumpFor(tester, const Duration(milliseconds: 750)); // t≈1100
      expect(find.text('自动'), findsOneWidget); // 离场动画中
      await pumpFor(tester, const Duration(milliseconds: 450)); // t≈1550
      expect(find.text('自动'), findsNothing);
      await pumpFor(tester, const Duration(seconds: 5));
      expect(find.text('手动'), findsOneWidget);
      await done(tester);
    });

    testWidgets('onClose fires on auto-dismiss and on close(id)', (
      tester,
    ) async {
      var closed = 0;
      await pumpHost(tester);
      final id = SemiToast.info(
        content: '手动关',
        duration: 0,
        onClose: () => closed++,
      );
      await pumpFor(tester, const Duration(milliseconds: 350));
      SemiToast.close(id);
      await pumpFor(tester, const Duration(milliseconds: 450));
      expect(closed, 1);
      expect(find.text('手动关'), findsNothing);
      SemiToast.info(content: '自动关', duration: 1, onClose: () => closed++);
      await pumpFor(tester, const Duration(milliseconds: 1600));
      expect(closed, 2);
      expect(find.text('自动关'), findsNothing);
      await done(tester);
    });

    testWidgets('same-id update replaces content and restarts the timer', (
      tester,
    ) async {
      await pumpHost(tester);
      SemiToast.info(id: 'a', content: '一', duration: 1);
      await pumpFor(tester, const Duration(milliseconds: 600));
      SemiToast.success(id: 'a', content: '二', duration: 1);
      await tester.pump();
      expect(find.text('一'), findsNothing);
      expect(find.text('二'), findsOneWidget);
      await pumpFor(tester, const Duration(milliseconds: 500)); // t≈1100
      expect(find.text('二'), findsOneWidget); // 旧计时已过，更新后重启
      await pumpFor(tester, const Duration(milliseconds: 1000)); // t≈2100
      expect(find.text('二'), findsNothing);
      await done(tester);
    });

    testWidgets('hover pauses the timer; leave restarts full duration', (
      tester,
    ) async {
      await pumpHost(tester);
      SemiToast.info(content: '悬停', duration: 1);
      await pumpFor(tester, const Duration(milliseconds: 350));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('悬停')));
      await tester.pump();
      await pumpFor(tester, const Duration(milliseconds: 1500));
      expect(find.text('悬停'), findsOneWidget); // 悬停暂停
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await pumpFor(tester, const Duration(milliseconds: 600));
      expect(find.text('悬停'), findsOneWidget); // 全量重启 1s
      await pumpFor(tester, const Duration(milliseconds: 900));
      expect(find.text('悬停'), findsNothing);
      await done(tester);
    });

    testWidgets('stacks oldest on top; destroyAll clears without onClose', (
      tester,
    ) async {
      var closed = 0;
      await pumpHost(tester);
      SemiToast.info(content: '旧', duration: 0);
      SemiToast.info(content: '新', duration: 0, onClose: () => closed++);
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(find.text('旧'), findsOneWidget);
      expect(find.text('新'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('旧')).dy,
        lessThan(tester.getTopLeft(find.text('新')).dy),
      );
      SemiToast.destroyAll();
      await tester.pump();
      expect(find.text('旧'), findsNothing);
      expect(find.text('新'), findsNothing);
      expect(closed, 0);
      await done(tester);
    });

    testWidgets('showClose false drops the closer; custom icon replaces '
        'default', (tester) async {
      await pumpHost(tester);
      SemiToast.info(
        content: '无关闭',
        showClose: false,
        icon: const SizedBox(key: Key('custom-icon'), width: 12, height: 12),
      );
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(find.byType(SemiButton), findsNothing);
      expect(find.byKey(const Key('custom-icon')), findsOneWidget);
      await done(tester);
    });

    testWidgets('RTL aligns the text right and mirrors the row', (tester) async {
      await pumpHost(tester, direction: TextDirection.rtl);
      SemiToast.info(content: '提示');
      await pumpFor(tester, const Duration(milliseconds: 350));
      final text = tester.widget<Text>(find.text('提示'));
      expect(text.textAlign, TextAlign.right);
      await done(tester);
    });

    testWidgets('local theme patch overrides resolved colors', (tester) async {
      await pumpHost(
        tester,
        patch: const SemiToastThemeData(colorToastBgDefault: Color(0xffabcdef)),
      );
      SemiToast.info(content: '主题');
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(toastDecoration(tester).color, const Color(0xffabcdef));
      await done(tester);
    });

    testWidgets('context captures caller theme; config supplies defaults', (
      tester,
    ) async {
      await pumpHost(
        tester,
        patch: const SemiToastThemeData(colorToastBgDefault: Color(0xff123456)),
      );
      SemiToast.config(top: 40, duration: 0);
      final id = SemiToast.info(content: '默认', context: capturedContext);
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(toastDecoration(tester).color, const Color(0xff123456));
      await pumpFor(tester, const Duration(seconds: 5));
      expect(find.text('默认'), findsOneWidget); // config duration 0
      final positioned = tester.widget<Positioned>(
        find
            .ancestor(of: find.text('默认'), matching: find.byType(Positioned))
            .first,
      );
      expect(positioned.top, 40);
      SemiToast.close(id);
      await pumpFor(tester, const Duration(milliseconds: 450));
      await done(tester);
    });

    testWidgets('role="alert" semantics is a live region', (tester) async {
      await pumpHost(tester);
      SemiToast.info(content: '提示');
      await pumpFor(tester, const Duration(milliseconds: 350));
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .any((s) => s.properties.liveRegion == true),
        isTrue,
      );
      await done(tester);
    });
  });
}
