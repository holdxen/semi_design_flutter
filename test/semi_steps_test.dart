// Behavior matrix for SemiSteps plus coverage for the 104 Sass declarations
// (94 FIELDS + 10 MOTION + 0 INTERNAL) — the 18 HARDCODES provenance anchors
// live in the widget's `_StepsMetrics` / call sites. ★5 死变量
// (`$height-steps_basic_item`、`$width-steps_item_left_icon`、
// `$spacing-steps_basic_item-marginRight`、`$font-steps_item_title-fontWeight`、
// `$font-steps_item_left-fontWeight`) keep their theme fields but the widget
// must never mention them (word-boundary assertNotIn) and the docs rows are
// marked （上游未消费）.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) {
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
                  child: SizedBox(width: 600, height: 600, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(host(child, direction: direction));
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

SemiResolvedStepsThemeData resolve([SemiThemeData? theme]) =>
    const SemiStepsThemeData().resolve(theme ?? const SemiThemeData.light());

const steps = <SemiStepData>[
  SemiStepData(title: 'First', description: 'desc-1'),
  SemiStepData(title: 'Second', description: 'desc-2'),
  SemiStepData(title: 'Third', description: 'desc-3'),
];

/// 标题文字颜色（最近一层 DefaultTextStyle）。
Color? titleColor(WidgetTester tester, String text) {
  final style = tester
      .widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text(text),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style;
  return style.color;
}

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiStepsThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedStepsThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-steps-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiStepsThemeData(colorStepsBgActive: v as Color),
    (d) => d.colorStepsBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-steps-bg-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsBgDefault: v as Color),
    (d) => d.colorStepsBgDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiStepsThemeData(colorStepsBgHover: v as Color),
    (d) => d.colorStepsBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-steps-border-default: transparent',
    _c,
    (v) => SemiStepsThemeData(colorStepsBorderDefault: v as Color),
    (d) => d.colorStepsBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-steps-icon-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsIconDefault: v as Color),
    (d) => d.colorStepsIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps-text-default: rgba(var(--semi-white), 1)',
    _c,
    (v) => SemiStepsThemeData(colorStepsTextDefault: v as Color),
    (d) => d.colorStepsTextDefault,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-steps_danger-text-active: var(--semi-color-danger-active)',
    _c,
    (v) => SemiStepsThemeData(colorStepsDangerTextActive: v as Color),
    (d) => d.colorStepsDangerTextActive,
    (t) => t.colors.colorDangerActive,
  ),
  (
    r'$color-steps_danger-text-default: var(--semi-color-danger)',
    _c,
    (v) => SemiStepsThemeData(colorStepsDangerTextDefault: v as Color),
    (d) => d.colorStepsDangerTextDefault,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-steps_danger-text-hover: var(--semi-color-danger-hover)',
    _c,
    (v) => SemiStepsThemeData(colorStepsDangerTextHover: v as Color),
    (d) => d.colorStepsDangerTextHover,
    (t) => t.colors.colorDangerHover,
  ),
  (
    r'$color-steps_icon_after-bg: var(--semi-color-fill-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsIconAfterBg: v as Color),
    (d) => d.colorStepsIconAfterBg,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-steps_item_description-text-hover: var(--semi-color-focus-border)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemDescriptionTextHover: v as Color),
    (d) => d.colorStepsItemDescriptionTextHover,
    (t) => t.colors.colorFocusBorder,
  ),
  (
    r'$color-steps_item_done_after-bg: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemDoneAfterBg: v as Color),
    (d) => d.colorStepsItemDoneAfterBg,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_item_done_icon_after-bg: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemDoneIconAfterBg: v as Color),
    (d) => d.colorStepsItemDoneIconAfterBg,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_item_error_left-icon: var(--semi-color-danger)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemErrorLeftIcon: v as Color),
    (d) => d.colorStepsItemErrorLeftIcon,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-steps_item_error_left_number-icon: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemErrorLeftNumberIcon: v as Color),
    (d) => d.colorStepsItemErrorLeftNumberIcon,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_item_finish-icon: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemFinishIcon: v as Color),
    (d) => d.colorStepsItemFinishIcon,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_item_finish_number-icon: var(--semi-color-white)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemFinishNumberIcon: v as Color),
    (d) => d.colorStepsItemFinishNumberIcon,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-steps_item_left_number_icon-bg: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemLeftNumberIconBg: v as Color),
    (d) => d.colorStepsItemLeftNumberIconBg,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_item_left_number_icon-icon: var(--semi-color-white)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemLeftNumberIconIcon: v as Color),
    (d) => d.colorStepsItemLeftNumberIconIcon,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-steps_item_process_left-icon: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemProcessLeftIcon: v as Color),
    (d) => d.colorStepsItemProcessLeftIcon,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_item_process_left_number-icon: var(--semi-color-white)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemProcessLeftNumberIcon: v as Color),
    (d) => d.colorStepsItemProcessLeftNumberIcon,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-steps_item_title-text-hover: var(--semi-color-focus-border)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemTitleTextHover: v as Color),
    (d) => d.colorStepsItemTitleTextHover,
    (t) => t.colors.colorFocusBorder,
  ),
  (
    r'$color-steps_item_wait_left_icon-icon: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemWaitLeftIconIcon: v as Color),
    (d) => d.colorStepsItemWaitLeftIconIcon,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps_item_wait_left_number_icon-bg-hover: var(--semi-color-secondary-light-default)',
    _c,
    (v) =>
        SemiStepsThemeData(colorStepsItemWaitLeftNumberIconBgHover: v as Color),
    (d) => d.colorStepsItemWaitLeftNumberIconBgHover,
    (t) => t.colors.colorSecondaryLightDefault,
  ),
  (
    r'$color-steps_item_wait_left_number_icon-bg: var(--semi-color-fill-0)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemWaitLeftNumberIconBg: v as Color),
    (d) => d.colorStepsItemWaitLeftNumberIconBg,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-steps_item_wait_left_number_icon-icon-hover: var(--semi-color-focus-border)',
    _c,
    (v) => SemiStepsThemeData(
      colorStepsItemWaitLeftNumberIconIconHover: v as Color,
    ),
    (d) => d.colorStepsItemWaitLeftNumberIconIconHover,
    (t) => t.colors.colorFocusBorder,
  ),
  (
    r'$color-steps_item_wait_left_number_icon-icon: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemWaitLeftNumberIconIcon: v as Color),
    (d) => d.colorStepsItemWaitLeftNumberIconIcon,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps_item_wait_title-text: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemWaitTitleText: v as Color),
    (d) => d.colorStepsItemWaitTitleText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps_item_warning_left-icon: var(--semi-color-warning)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemWarningLeftIcon: v as Color),
    (d) => d.colorStepsItemWarningLeftIcon,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-steps_item_warning_left_number-icon: var(--semi-color-white)',
    _c,
    (v) => SemiStepsThemeData(colorStepsItemWarningLeftNumberIcon: v as Color),
    (d) => d.colorStepsItemWarningLeftNumberIcon,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-steps_main-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiStepsThemeData(colorStepsMainTextDefault: v as Color),
    (d) => d.colorStepsMainTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-steps_minor-text-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsMinorTextDefault: v as Color),
    (d) => d.colorStepsMinorTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps_nav_item_container-text: var(--semi-color-text-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsNavItemContainerText: v as Color),
    (d) => d.colorStepsNavItemContainerText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-steps_nav_item-icon: var(--semi-grey-3)',
    _c,
    (v) => SemiStepsThemeData(colorStepsNavItemIcon: v as Color),
    (d) => d.colorStepsNavItemIcon,
    (t) => t.palette.grey3.toColor(1),
  ),
  (
    r'$color-steps_nav_item_title-text-active: var(--semi-color-text-0)',
    _c,
    (v) => SemiStepsThemeData(colorStepsNavItemTitleTextActive: v as Color),
    (d) => d.colorStepsNavItemTitleTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-steps_primary-bg-default: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsPrimaryBgDefault: v as Color),
    (d) => d.colorStepsPrimaryBgDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_primary-icon-default: var(--semi-color-primary)',
    _c,
    (v) => SemiStepsThemeData(colorStepsPrimaryIconDefault: v as Color),
    (d) => d.colorStepsPrimaryIconDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-steps_process-bg-default: var(--semi-color-primary-light-default)',
    _c,
    (v) => SemiStepsThemeData(colorStepsProcessBgDefault: v as Color),
    (d) => d.colorStepsProcessBgDefault,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-steps_success-text-active: var(--semi-color-success-active)',
    _c,
    (v) => SemiStepsThemeData(colorStepsSuccessTextActive: v as Color),
    (d) => d.colorStepsSuccessTextActive,
    (t) => t.colors.colorSuccessActive,
  ),
  (
    r'$color-steps_success-text-default: var(--semi-color-success)',
    _c,
    (v) => SemiStepsThemeData(colorStepsSuccessTextDefault: v as Color),
    (d) => d.colorStepsSuccessTextDefault,
    (t) => t.colors.colorSuccess,
  ),
  (
    r'$color-steps_success-text-hover: var(--semi-color-success-hover)',
    _c,
    (v) => SemiStepsThemeData(colorStepsSuccessTextHover: v as Color),
    (d) => d.colorStepsSuccessTextHover,
    (t) => t.colors.colorSuccessHover,
  ),
  (
    r'$color-steps_title_after-bg: var(--semi-color-fill-2)',
    _c,
    (v) => SemiStepsThemeData(colorStepsTitleAfterBg: v as Color),
    (d) => d.colorStepsTitleAfterBg,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-steps_warning-text-active: var(--semi-color-warning-active)',
    _c,
    (v) => SemiStepsThemeData(colorStepsWarningTextActive: v as Color),
    (d) => d.colorStepsWarningTextActive,
    (t) => t.colors.colorWarningActive,
  ),
  (
    r'$color-steps_warning-text-default: var(--semi-color-warning)',
    _c,
    (v) => SemiStepsThemeData(colorStepsWarningTextDefault: v as Color),
    (d) => d.colorStepsWarningTextDefault,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-steps_warning-text-hover: var(--semi-color-warning-hover)',
    _c,
    (v) => SemiStepsThemeData(colorStepsWarningTextHover: v as Color),
    (d) => d.colorStepsWarningTextHover,
    (t) => t.colors.colorWarningHover,
  ),
  (
    r'$width-steps_basic_item_description: 100%',
    100.0,
    (v) => SemiStepsThemeData(widthStepsBasicItemDescription: v as double),
    (d) => d.widthStepsBasicItemDescription,
    (t) => 100,
  ),
  (
    r'$width-steps_basic_item_description-maxWidth: 268px',
    268.0,
    (v) =>
        SemiStepsThemeData(widthStepsBasicItemDescriptionMaxWidth: v as double),
    (d) => d.widthStepsBasicItemDescriptionMaxWidth,
    (t) => 268,
  ),
  (
    r'$width-steps_basic_item_title-maxWidth: 80%',
    80.0,
    (v) => SemiStepsThemeData(widthStepsBasicItemTitleMaxWidth: v as double),
    (d) => d.widthStepsBasicItemTitleMaxWidth,
    (t) => 80,
  ),
  (
    r'$height-steps_basic_vertical_icon_content-minHeight: 42px',
    42.0,
    (v) => SemiStepsThemeData(
      heightStepsBasicVerticalIconContentMinHeight: v as double,
    ),
    (d) => d.heightStepsBasicVerticalIconContentMinHeight,
    (t) => 42,
  ),
  (
    r'$width-steps_basic_vertical_item_title-maxWidth: 100%',
    100.0,
    (v) => SemiStepsThemeData(
      widthStepsBasicVerticalItemTitleMaxWidth: v as double,
    ),
    (d) => d.widthStepsBasicVerticalItemTitleMaxWidth,
    (t) => 100,
  ),
  (
    r'$width-steps_basic_vertical_item_description: 100%',
    100.0,
    (v) =>
        SemiStepsThemeData(widthStepsBasicVerticalItemDescription: v as double),
    (d) => d.widthStepsBasicVerticalItemDescription,
    (t) => 100,
  ),
  (
    r'$height-steps_basic_vertical_small_item_content-minHeight: 40px',
    40.0,
    (v) => SemiStepsThemeData(
      heightStepsBasicVerticalSmallItemContentMinHeight: v as double,
    ),
    (d) => d.heightStepsBasicVerticalSmallItemContentMinHeight,
    (t) => 40,
  ),
  (
    r'$height-steps_basic_item_left-icon: 24px',
    24.0,
    (v) => SemiStepsThemeData(heightStepsBasicItemLeftIcon: v as double),
    (d) => d.heightStepsBasicItemLeftIcon,
    (t) => 24,
  ),
  (
    r'$width-steps_basic_item_left_number-icon: 24px',
    24.0,
    (v) => SemiStepsThemeData(widthStepsBasicItemLeftNumberIcon: v as double),
    (d) => d.widthStepsBasicItemLeftNumberIcon,
    (t) => 24,
  ),
  (
    r'$height-steps_basic_item_left_number-icon: 24px',
    24.0,
    (v) => SemiStepsThemeData(heightStepsBasicItemLeftNumberIcon: v as double),
    (d) => d.heightStepsBasicItemLeftNumberIcon,
    (t) => 24,
  ),
  (
    r'$height-steps_basic_small_item_left-icon: 20px',
    20.0,
    (v) => SemiStepsThemeData(heightStepsBasicSmallItemLeftIcon: v as double),
    (d) => d.heightStepsBasicSmallItemLeftIcon,
    (t) => 20,
  ),
  (
    r'$width-steps_basic_small_item_left_number-icon: 20px',
    20.0,
    (v) =>
        SemiStepsThemeData(widthStepsBasicSmallItemLeftNumberIcon: v as double),
    (d) => d.widthStepsBasicSmallItemLeftNumberIcon,
    (t) => 20,
  ),
  (
    r'$height-steps_basic_item: 72px',
    72.0,
    (v) => SemiStepsThemeData(heightStepsBasicItem: v as double),
    (d) => d.heightStepsBasicItem,
    (t) => 72,
  ),
  (
    r'$height-steps_item: 72px',
    72.0,
    (v) => SemiStepsThemeData(heightStepsItem: v as double),
    (d) => d.heightStepsItem,
    (t) => 72,
  ),
  (
    r'$width-steps_item-border: 1px',
    1.0,
    (v) => SemiStepsThemeData(widthStepsItemBorder: v as double),
    (d) => d.widthStepsItemBorder,
    (t) => 1,
  ),
  (
    r'$width-steps_item_title: 100%',
    100.0,
    (v) => SemiStepsThemeData(widthStepsItemTitle: v as double),
    (d) => d.widthStepsItemTitle,
    (t) => 100,
  ),
  (
    r'$width-steps_item_description: 100%',
    100.0,
    (v) => SemiStepsThemeData(widthStepsItemDescription: v as double),
    (d) => d.widthStepsItemDescription,
    (t) => 100,
  ),
  (
    r'$width-steps_item_left_icon: 24px',
    24.0,
    (v) => SemiStepsThemeData(widthStepsItemLeftIcon: v as double),
    (d) => d.widthStepsItemLeftIcon,
    (t) => 24,
  ),
  (
    r'$width-steps_item_left: 24px',
    24.0,
    (v) => SemiStepsThemeData(widthStepsItemLeft: v as double),
    (d) => d.widthStepsItemLeft,
    (t) => 24,
  ),
  (
    r'$height-steps_item_left: 24px',
    24.0,
    (v) => SemiStepsThemeData(heightStepsItemLeft: v as double),
    (d) => d.heightStepsItemLeft,
    (t) => 24,
  ),
  (
    r'$width-steps_title_after: 9999px',
    9999.0,
    (v) => SemiStepsThemeData(widthStepsTitleAfter: v as double),
    (d) => d.widthStepsTitleAfter,
    (t) => 9999,
  ),
  (
    r'$height-steps_title_after: 1px',
    1.0,
    (v) => SemiStepsThemeData(heightStepsTitleAfter: v as double),
    (d) => d.heightStepsTitleAfter,
    (t) => 1,
  ),
  (
    r'$width-steps_vertical_icon_after: 1px',
    1.0,
    (v) => SemiStepsThemeData(widthStepsVerticalIconAfter: v as double),
    (d) => d.widthStepsVerticalIconAfter,
    (t) => 1,
  ),
  (
    r'$height-steps_vertical_icon_after: 9999px',
    9999.0,
    (v) => SemiStepsThemeData(heightStepsVerticalIconAfter: v as double),
    (d) => d.heightStepsVerticalIconAfter,
    (t) => 9999,
  ),
  (
    r'$width-steps_nav_item_icon-minWidth: 60px',
    60.0,
    (v) => SemiStepsThemeData(widthStepsNavItemIconMinWidth: v as double),
    (d) => d.widthStepsNavItemIconMinWidth,
    (t) => 60,
  ),
  (
    r'$width-steps_nav_item_title-maxWidth: 17em',
    17.0,
    (v) => SemiStepsThemeData(widthStepsNavItemTitleMaxWidth: v as double),
    (d) => d.widthStepsNavItemTitleMaxWidth,
    (t) => 17,
  ),
  (
    r'$spacing-steps_basic_item-paddingLeft: 16px',
    16.0,
    (v) => SemiStepsThemeData(spacingStepsBasicItemPaddingLeft: v as double),
    (d) => d.spacingStepsBasicItemPaddingLeft,
    (t) => 16,
  ),
  (
    r'$spacing-steps_basic_vertical_item-paddingTop: 9px',
    9.0,
    (v) => SemiStepsThemeData(
      spacingStepsBasicVerticalItemPaddingTop: v as double,
    ),
    (d) => d.spacingStepsBasicVerticalItemPaddingTop,
    (t) => 9,
  ),
  (
    r'$spacing-steps_basic_vertical_item_content-paddingBottom: 22px',
    22.0,
    (v) => SemiStepsThemeData(
      spacingStepsBasicVerticalItemContentPaddingBottom: v as double,
    ),
    (d) => d.spacingStepsBasicVerticalItemContentPaddingBottom,
    (t) => 22,
  ),
  (
    r'$spacing-steps_basic_vertical_item_icon-paddingBottom: 9px',
    9.0,
    (v) => SemiStepsThemeData(
      spacingStepsBasicVerticalItemIconPaddingBottom: v as double,
    ),
    (d) => d.spacingStepsBasicVerticalItemIconPaddingBottom,
    (t) => 9,
  ),
  (
    r'$spacing-steps_basic_item_left-marginRight: 8px',
    8.0,
    (v) =>
        SemiStepsThemeData(spacingStepsBasicItemLeftMarginRight: v as double),
    (d) => d.spacingStepsBasicItemLeftMarginRight,
    (t) => 8,
  ),
  (
    r'$spacing-steps_basic_item_title-paddingRight: 16px',
    16.0,
    (v) =>
        SemiStepsThemeData(spacingStepsBasicItemTitlePaddingRight: v as double),
    (d) => d.spacingStepsBasicItemTitlePaddingRight,
    (t) => 16,
  ),
  (
    r'$spacing-steps_basic_item_title-paddingBottom: 4px',
    4.0,
    (v) => SemiStepsThemeData(
      spacingStepsBasicItemTitlePaddingBottom: v as double,
    ),
    (d) => d.spacingStepsBasicItemTitlePaddingBottom,
    (t) => 4,
  ),
  (
    r'$spacing-steps_basic_item-marginRight: 16px',
    16.0,
    (v) => SemiStepsThemeData(spacingStepsBasicItemMarginRight: v as double),
    (d) => d.spacingStepsBasicItemMarginRight,
    (t) => 16,
  ),
  (
    r'$spacing-steps_item-marginRight: 16px',
    16.0,
    (v) => SemiStepsThemeData(spacingStepsItemMarginRight: v as double),
    (d) => d.spacingStepsItemMarginRight,
    (t) => 16,
  ),
  (
    r'$spacing-steps_item-paddingY: $spacing-base-tight',
    12.0,
    (v) => SemiStepsThemeData(spacingStepsItemPaddingY: v as double),
    (d) => d.spacingStepsItemPaddingY,
    (t) => 12,
  ),
  (
    r'$spacing-steps_item-paddingX: $spacing-base',
    16.0,
    (v) => SemiStepsThemeData(spacingStepsItemPaddingX: v as double),
    (d) => d.spacingStepsItemPaddingX,
    (t) => 16,
  ),
  (
    r'$spacing-steps_item_content-marginLeft: $spacing-base',
    16.0,
    (v) => SemiStepsThemeData(spacingStepsItemContentMarginLeft: v as double),
    (d) => d.spacingStepsItemContentMarginLeft,
    (t) => 16,
  ),
  (
    r'$radius-steps_basic_item_left_number_icon: var(--semi-border-radius-circle)',
    101.0,
    (v) => SemiStepsThemeData(radiusStepsBasicItemLeftNumberIcon: v as double),
    (d) => d.radiusStepsBasicItemLeftNumberIcon,
    (t) => t.radius.borderRadiusCircle.value,
  ),
  (
    r'$radius-steps_item: var(--semi-border-radius-medium)',
    101.0,
    (v) => SemiStepsThemeData(radiusStepsItem: v as double),
    (d) => d.radiusStepsItem,
    (t) => t.radius.borderRadiusMedium.value,
  ),
  (
    r'$radius-steps_item_left: 32px',
    32.0,
    (v) => SemiStepsThemeData(radiusStepsItemLeft: v as double),
    (d) => d.radiusStepsItemLeft,
    (t) => 32,
  ),
  (
    r'$font-steps_basic_item_left_number_icon-fontWeight: 600',
    FontWeight.w300,
    (v) => SemiStepsThemeData(
      fontStepsBasicItemLeftNumberIconFontWeight: v as FontWeight,
    ),
    (d) => d.fontStepsBasicItemLeftNumberIconFontWeight,
    (t) => FontWeight.w600,
  ),
  (
    r'$font-steps_basic_item_title-fontWeight: 600',
    FontWeight.w300,
    (v) =>
        SemiStepsThemeData(fontStepsBasicItemTitleFontWeight: v as FontWeight),
    (d) => d.fontStepsBasicItemTitleFontWeight,
    (t) => FontWeight.w600,
  ),
  (
    r'$font-steps_basic_item_title-lineHeight: 24px',
    24.0,
    (v) => SemiStepsThemeData(fontStepsBasicItemTitleLineHeight: v as double),
    (d) => d.fontStepsBasicItemTitleLineHeight,
    (t) => 24,
  ),
  (
    r'$font-steps_item_title-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (v) => SemiStepsThemeData(fontStepsItemTitleFontWeight: v as FontWeight),
    (d) => d.fontStepsItemTitleFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-steps_item_left-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (v) => SemiStepsThemeData(fontStepsItemLeftFontWeight: v as FontWeight),
    (d) => d.fontStepsItemLeftFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-steps_item_left-lineHeight: 32px',
    32.0,
    (v) => SemiStepsThemeData(fontStepsItemLeftLineHeight: v as double),
    (d) => d.fontStepsItemLeftLineHeight,
    (t) => 32,
  ),
  (
    r'$font-steps_nav_item_title-fontWeight: $font-weight-regular',
    FontWeight.w300,
    (v) => SemiStepsThemeData(fontStepsNavItemTitleFontWeight: v as FontWeight),
    (d) => d.fontStepsNavItemTitleFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-steps_nav_item_title_active-fontWeight: 600',
    FontWeight.w300,
    (v) => SemiStepsThemeData(
      fontStepsNavItemTitleActiveFontWeight: v as FontWeight,
    ),
    (d) => d.fontStepsNavItemTitleActiveFontWeight,
    (t) => FontWeight.w600,
  ),
  (
    r'$transition_duration-steps_item_title-text: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) =>
        SemiStepsThemeData(transitionDurationStepsItemTitleText: v as Duration),
    (d) => d.transitionDurationStepsItemTitleText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-steps_item_title-text: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiStepsThemeData(transitionFunctionStepsItemTitleText: v as Curve),
    (d) => d.transitionFunctionStepsItemTitleText,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-steps_item_title-text: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) => SemiStepsThemeData(transitionDelayStepsItemTitleText: v as Duration),
    (d) => d.transitionDelayStepsItemTitleText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-steps_item_title-icon: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) =>
        SemiStepsThemeData(transitionDurationStepsItemTitleIcon: v as Duration),
    (d) => d.transitionDurationStepsItemTitleIcon,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-steps_item_title-icon: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiStepsThemeData(transitionFunctionStepsItemTitleIcon: v as Curve),
    (d) => d.transitionFunctionStepsItemTitleIcon,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-steps_item_title-icon: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) => SemiStepsThemeData(transitionDelayStepsItemTitleIcon: v as Duration),
    (d) => d.transitionDelayStepsItemTitleIcon,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-steps_item_backgroundColor: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) => SemiStepsThemeData(
      transitionDurationStepsItemBackgroundColor: v as Duration,
    ),
    (d) => d.transitionDurationStepsItemBackgroundColor,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-steps_item_backgroundColor: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiStepsThemeData(
      transitionFunctionStepsItemBackgroundColor: v as Curve,
    ),
    (d) => d.transitionFunctionStepsItemBackgroundColor,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-steps_item_backgroundColor: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) => SemiStepsThemeData(
      transitionDelayStepsItemBackgroundColor: v as Duration,
    ),
    (d) => d.transitionDelayStepsItemBackgroundColor,
    (t) => Duration.zero,
  ),
  (
    r'$transform_scale-step-item: var(--semi-transform_scale-small)',
    const SemiTransform.scale(2, 3),
    (v) => SemiStepsThemeData(transformScaleStepItem: v as SemiTransform),
    (d) => d.transformScaleStepItem,
    (t) => const SemiTransform.scale(1, 1),
  ),
];

void main() {
  group('theme fields (104 = 94 FIELDS + 10 MOTION + 0 INTERNAL)', () {
    test('104 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(104));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiStepsThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiStepsThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiStepsThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_steps_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(104));
      expect(source, contains(r'rgba(var(--semi-white), 1)'));
      expect(source, contains('packages/semi-foundation/steps/variables.scss'));
      expect(source, contains('packages/semi-foundation/steps/animation.scss'));
      expect(source, contains('Generated by tool/generate_steps.py'));
      expect(source, contains('# dead variable (上游未消费)'));
    });

    test('the 18 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_steps.dart')
          .readAsStringSync();
      const anchors = <String>[
        '-next-error',
        'tabIndex={0}',
        "e.key === 'Enter'",
        "small = 'large'",
        'IconChevronRight size="small"',
        "title={typeof title === 'string' ? title : null}",
        'text-overflow-hidden',
        '@include font-size-header-6',
        '@include font-size-header-5',
        '@include font-size-header-4',
        r'width: `${100 / filteredChildren.length}%`',
        'aria-current',
        '17em',
        '9999px',
        'transform: scale(scale(1,1))',
        'rgba(var(--semi-white), 1)',
        r'$transition_duration-steps_item-backgroundColor',
        'hasLine = true',
      ];
      expect(anchors, hasLength(18));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 45 Color + 43 double + 6 FontWeight + 6 Duration + '
        '3 Curve + 1 SemiTransform = 104', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = switch (value) {
          Curve() => 'Curve',
          SemiTransform() => 'SemiTransform',
          _ => value.runtimeType.toString(),
        };
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 45);
      expect(counts['double'], 43);
      expect(counts['FontWeight'], 6);
      expect(counts['Duration'], 6);
      expect(counts['Curve'], 3);
      expect(counts['SemiTransform'], 1);
    });

    test('5 dead variables: word-boundary assertNotIn + docs marks', () {
      const deadFields = [
        'heightStepsBasicItem',
        'widthStepsItemLeftIcon',
        'spacingStepsBasicItemMarginRight',
        'fontStepsItemTitleFontWeight',
        'fontStepsItemLeftFontWeight',
      ];
      final widgetSource = File('lib/src/components/semi_steps.dart')
          .readAsStringSync();
      for (final name in deadFields) {
        final match = RegExp('(?<![A-Za-z])$name(?![A-Za-z])')
            .firstMatch(widgetSource);
        expect(match, isNull, reason: name);
      }
      final docs = File('docs/semi_steps.md').readAsStringSync();
      expect(docs, contains('104 = 94 FIELDS + 10 MOTION + 0 INTERNAL'));
      expect(docs, contains('5 死变量'));
      expect(docs, contains('（上游未消费）'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.steps, const SemiStepsThemeData());
      expect(
        themes.copyWith(steps: const SemiStepsThemeData(heightStepsItem: 80)),
        const SemiComponentThemes(
          steps: SemiStepsThemeData(heightStepsItem: 80),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('fill derives statuses and paints process/wait colors', (
      tester,
    ) async {
      final t = resolve();
      await pumpHost(tester, const SemiSteps(steps: steps, current: 1));
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('desc-2'), findsOneWidget);
      // 首个 done → tick 图标（finish）；当前 process 显示序号 2；第三个 wait 序号 3。
      final icons = tester
          .widgetList<SemiIcon>(find.byType(SemiIcon))
          .map((i) => i.data);
      expect(icons, contains(SemiIcons.tickCircle));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // process 标题 primary；wait 标题 text-0。
      expect(titleColor(tester, 'Second'), t.colorStepsPrimaryIconDefault);
      expect(titleColor(tester, 'Third'), t.colorStepsMainTextDefault);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fill number sits centered in the badge circle', (
      tester,
    ) async {
      final t = resolve();
      await pumpHost(tester, const SemiSteps(steps: steps, current: 1));
      // 自然盒方案（fluent_ui TextBox 先例，semi_input.md）：不设
      // `TextStyle.height`——height 按比例放大 ascent/descent、基线下移，
      // 数字偏下。
      final style = tester
          .widget<AnimatedDefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('2'),
                  matching: find.byType(AnimatedDefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(style.height, isNull);
      final paragraph = tester.renderObject<RenderParagraph>(find.text('2'));
      // 字形墨盒中心 vs 圆心（自然盒居中 = CSS 半行距均分行盒居中，单行
      // 基线重合、偏差 0）。
      final glyph = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 1),
          )
          .single
          .toRect();
      final glyphCenter = paragraph.localToGlobal(glyph.center);
      Rect? badge;
      for (final element
          in find
              .ancestor(of: find.text('2'), matching: find.byType(Container))
              .evaluate()) {
        final rect = tester.getRect(
          find.byElementPredicate((e) => e == element),
        );
        if (rect.size == Size(t.widthStepsItemLeft, t.heightStepsItemLeft)) {
          badge = rect;
        }
      }
      expect(badge, isNotNull, reason: '24×24 badge container not found');
      expect((glyphCenter.dy - badge!.center.dy).abs(), lessThan(1));
    });

    testWidgets('step.status overrides and custom icon replaces the badge', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSteps(
          steps: [
            SemiStepData(title: 'A', status: SemiStepStatus.error),
            SemiStepData(title: 'B', icon: SemiIcon(SemiIcons.home)),
          ],
          current: 0,
        ),
      );
      final icons = tester
          .widgetList<SemiIcon>(find.byType(SemiIcon))
          .map((i) => i.data);
      expect(icons, containsAll([SemiIcons.alertCircle, SemiIcons.home]));
      expect(tester.takeException(), isNull);
    });

    testWidgets('clicking a non-current step reports onChange; the current '
        'step and non-clickable steps do not', (tester) async {
      final changes = <int>[];
      await pumpHost(
        tester,
        SemiSteps(steps: steps, current: 1, onChange: changes.add),
      );
      await tester.tap(find.text('Third'));
      await tester.pump();
      expect(changes, [2]);
      await tester.tap(find.text('Second'));
      await tester.pump();
      expect(changes, [2]);
      // 无 onChange/onClick：不可点击。
      await pumpHost(tester, const SemiSteps(steps: steps, current: 1));
      await tester.tap(find.text('Third'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('basic horizontal paints connectors and their done colors', (
      tester,
    ) async {
      final t = resolve();
      await pumpHost(
        tester,
        const SemiSteps(type: SemiStepsType.basic, steps: steps, current: 1),
      );
      // 2 条连接线：first(done → primary) / second(wait 线 → fill-2)。
      final lineBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where(
            (box) =>
                box.height == t.heightStepsTitleAfter &&
                box.width == t.widthStepsTitleAfter,
          );
      expect(lineBoxes, hasLength(2));
      final colors = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .map((c) => c.color)
          .toList();
      expect(colors, contains(t.colorStepsItemDoneAfterBg));
      expect(colors, contains(t.colorStepsTitleAfterBg));
      expect(tester.takeException(), isNull);
    });

    testWidgets('basic vertical draws the vertical connector and min-height '
        'content', (tester) async {
      await pumpHost(
        tester,
        const SemiSteps(
          type: SemiStepsType.basic,
          direction: SemiStepsDirection.vertical,
          steps: steps,
          current: 0,
        ),
      );
      // 连接线由行级 painter 绘制：每步一个 painter（末项 visible=false 不画）。
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter.runtimeType.toString())
          .where((name) => name.contains('BasicVerticalLinePainter'));
      expect(painters, hasLength(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('basic small uses the 20 badge and regular title', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiSteps(
          type: SemiStepsType.basic,
          steps: steps,
          current: 0,
          size: SemiStepSize.small,
        ),
      );
      final box = tester.getSize(find.text('1'));
      expect(box.height, lessThan(24));
      final style = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('First'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(style.fontSize, 14);
      expect(tester.takeException(), isNull);
    });

    testWidgets('basic hover tints the clickable title', (tester) async {
      final gesture = await startMouse(tester);
      final t = resolve();
      await pumpHost(
        tester,
        SemiSteps(
          type: SemiStepsType.basic,
          steps: steps,
          current: 0,
          onChange: (_) {},
        ),
      );
      await gesture.moveTo(tester.getCenter(find.text('Third')));
      await tester.pump();
      expect(titleColor(tester, 'Third'), t.colorStepsItemTitleTextHover);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nav marks the active title and renders n-1 chevrons', (
      tester,
    ) async {
      final t = resolve();
      final changes = <int>[];
      await pumpHost(
        tester,
        SemiSteps(
          type: SemiStepsType.nav,
          steps: steps,
          current: 1,
          onChange: changes.add,
        ),
      );
      final chevrons = tester
          .widgetList<SemiIcon>(find.byType(SemiIcon))
          .where((icon) => icon.data == SemiIcons.chevronRight);
      expect(chevrons, hasLength(2));
      expect(titleColor(tester, 'Second'), t.colorStepsNavItemTitleTextActive);
      expect(titleColor(tester, 'First'), t.colorStepsNavItemContainerText);
      await tester.tap(find.text('Third'));
      await tester.pump();
      expect(changes, [2]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('first step shows nothing done; status error marks the current '
        'badge error', (tester) async {
      await pumpHost(
        tester,
        const SemiSteps(steps: steps, current: 0, status: SemiStepStatus.error),
      );
      final icons = tester
          .widgetList<SemiIcon>(find.byType(SemiIcon))
          .map((i) => i.data);
      expect(icons, contains(SemiIcons.alertCircle));
      expect(icons, isNot(contains(SemiIcons.tickCircle)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL renders without layout errors', (tester) async {
      await pumpHost(
        tester,
        const SemiSteps(steps: steps, current: 1),
        direction: TextDirection.rtl,
      );
      expect(find.text('First'), findsOneWidget);
      await pumpHost(
        tester,
        const SemiSteps(
          type: SemiStepsType.basic,
          direction: SemiStepsDirection.vertical,
          steps: steps,
          current: 1,
        ),
        direction: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
