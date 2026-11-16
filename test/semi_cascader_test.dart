// Behavior matrix for SemiCascader plus coverage for the 115 Sass
// declarations (112 FIELDS + 3 MOTION + 0 INTERNAL) — the 30 HARDCODES
// provenance anchors live in the widget's `_CascaderMetrics` / call sites.
// ★2 死变量（上游未消费）：`$color-cascader_label-text-default`、
// `$font-cascader_label-fontWeight` 仅在 variables.scss 自身声明处出现——
// 字段保留、widget 不消费（docs 标注）。
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
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
                  child: SizedBox(width: 400, height: 600, child: child),
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

/// 值路径 key 拼接（constants.ts:33 `VALUE_SPLIT`）。
String k(String slashPath) =>
    slashPath.split('/').join('_SEMI_CASCADER_SPLIT_');

/// 2-level fixture: Zhejiang [Hangzhou [Xihu, Binjiang], Ningbo] +
/// Jiangsu [Nanjing(disabled), Suzhou].
const data = <SemiCascaderData>[
  SemiCascaderData(
    value: 'zhejiang',
    label: 'Zhejiang',
    children: [
      SemiCascaderData(
        value: 'hangzhou',
        label: 'Hangzhou',
        children: [
          SemiCascaderData(value: 'xihu', label: 'Xihu'),
          SemiCascaderData(value: 'binjiang', label: 'Binjiang'),
        ],
      ),
      SemiCascaderData(value: 'ningbo', label: 'Ningbo'),
    ],
  ),
  SemiCascaderData(
    value: 'jiangsu',
    label: 'Jiangsu',
    children: [
      SemiCascaderData(value: 'nanjing', label: 'Nanjing', disabled: true),
      SemiCascaderData(value: 'suzhou', label: 'Suzhou'),
    ],
  ),
];

/// 弹层内文本（避开触发器回填/标签的同名文本）。
Finder rowText(String text) => find.descendant(
  of: find.byKey(SemiCascader.listKey),
  matching: find.text(text),
);

typedef _Patch = SemiCascaderThemeData Function(Object v);
typedef _Read = Object? Function(SemiResolvedCascaderThemeData d);
typedef _Expected = Object? Function(SemiThemeData t);

final List<(String, Object, _Patch, _Read, _Expected)> fields = [
  (
    r'$radius-cascader: var(--semi-border-radius-small)',
    1000.25,
    (v) => SemiCascaderThemeData(radiusCascader: v as double),
    (d) => d.radiusCascader,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-cascader_option_empty: var(--semi-border-radius-medium)',
    1000.75,
    (v) => SemiCascaderThemeData(radiusCascaderOptionEmpty: v as double),
    (d) => d.radiusCascaderOptionEmpty,
    (t) => t.radius.borderRadiusMedium.value,
  ),
  (
    r'$color-cascader_default-border-default: transparent',
    const Color(0xFF000001),
    (v) => SemiCascaderThemeData(colorCascaderDefaultBorderDefault: v as Color),
    (d) => d.colorCascaderDefaultBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_default-border-hover: transparent',
    const Color(0xFF000002),
    (v) => SemiCascaderThemeData(colorCascaderDefaultBorderHover: v as Color),
    (d) => d.colorCascaderDefaultBorderHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_default-border-focus: var(--semi-color-focus-border)',
    const Color(0xFF000003),
    (v) => SemiCascaderThemeData(colorCascaderDefaultBorderFocus: v as Color),
    (d) => d.colorCascaderDefaultBorderFocus,
    (t) => t.colors.colorFocusBorder,
  ),
  (
    r'$color-cascader_default-bg-default: var(--semi-color-fill-0)',
    const Color(0xFF000004),
    (v) => SemiCascaderThemeData(colorCascaderDefaultBgDefault: v as Color),
    (d) => d.colorCascaderDefaultBgDefault,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-cascader_default-bg-hover: var(--semi-color-fill-1)',
    const Color(0xFF000005),
    (v) => SemiCascaderThemeData(colorCascaderDefaultBgHover: v as Color),
    (d) => d.colorCascaderDefaultBgHover,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-cascader_default-bg-active: var(--semi-color-fill-2)',
    const Color(0xFF000006),
    (v) => SemiCascaderThemeData(colorCascaderDefaultBgActive: v as Color),
    (d) => d.colorCascaderDefaultBgActive,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-cascader_option_list-border-default: var(--semi-color-fill-0)',
    const Color(0xFF000007),
    (v) =>
        SemiCascaderThemeData(colorCascaderOptionListBorderDefault: v as Color),
    (d) => d.colorCascaderOptionListBorderDefault,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-cascader_option_main-text-default: var(--semi-color-text-0)',
    const Color(0xFF000008),
    (v) =>
        SemiCascaderThemeData(colorCascaderOptionMainTextDefault: v as Color),
    (d) => d.colorCascaderOptionMainTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-cascader_option-bg-hover: var(--semi-color-fill-0)',
    const Color(0xFF000009),
    (v) => SemiCascaderThemeData(colorCascaderOptionBgHover: v as Color),
    (d) => d.colorCascaderOptionBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-cascader_option-bg-active: var(--semi-color-fill-1)',
    const Color(0xFF00000A),
    (v) => SemiCascaderThemeData(colorCascaderOptionBgActive: v as Color),
    (d) => d.colorCascaderOptionBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-cascader_option-bg-selected: var(--semi-color-primary-light-default)',
    const Color(0xFF00000B),
    (v) => SemiCascaderThemeData(colorCascaderOptionBgSelected: v as Color),
    (d) => d.colorCascaderOptionBgSelected,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-cascader_option_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xFF00000C),
    (v) => SemiCascaderThemeData(
      colorCascaderOptionDisabledTextDefault: v as Color,
    ),
    (d) => d.colorCascaderOptionDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-cascader_option_disabled-bg-hover: transparent',
    const Color(0xFF00000D),
    (v) =>
        SemiCascaderThemeData(colorCascaderOptionDisabledBgHover: v as Color),
    (d) => d.colorCascaderOptionDisabledBgHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_option_disabled-bg-active: transparent',
    const Color(0xFF00000E),
    (v) =>
        SemiCascaderThemeData(colorCascaderOptionDisabledBgActive: v as Color),
    (d) => d.colorCascaderOptionDisabledBgActive,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_tag_disabled-bg-default: transparent',
    const Color(0xFF00000F),
    (v) => SemiCascaderThemeData(colorCascaderTagDisabledBgDefault: v as Color),
    (d) => d.colorCascaderTagDisabledBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_warning-bg-default: var(--semi-color-warning-light-default)',
    const Color(0xFF000010),
    (v) => SemiCascaderThemeData(colorCascaderWarningBgDefault: v as Color),
    (d) => d.colorCascaderWarningBgDefault,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-cascader_warning-border-default: var(--semi-color-warning-light-default)',
    const Color(0xFF000011),
    (v) => SemiCascaderThemeData(colorCascaderWarningBorderDefault: v as Color),
    (d) => d.colorCascaderWarningBorderDefault,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-cascader_warning-bg-hover: var(--semi-color-warning-light-hover)',
    const Color(0xFF000012),
    (v) => SemiCascaderThemeData(colorCascaderWarningBgHover: v as Color),
    (d) => d.colorCascaderWarningBgHover,
    (t) => t.colors.colorWarningLightHover,
  ),
  (
    r'$color-cascader_warning-border-hover: var(--semi-color-warning-light-hover)',
    const Color(0xFF000013),
    (v) => SemiCascaderThemeData(colorCascaderWarningBorderHover: v as Color),
    (d) => d.colorCascaderWarningBorderHover,
    (t) => t.colors.colorWarningLightHover,
  ),
  (
    r'$color-cascader_warning-bg-focus: var(--semi-color-warning-light-default)',
    const Color(0xFF000014),
    (v) => SemiCascaderThemeData(colorCascaderWarningBgFocus: v as Color),
    (d) => d.colorCascaderWarningBgFocus,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-cascader_warning-border-focus: var(--semi-color-warning)',
    const Color(0xFF000015),
    (v) => SemiCascaderThemeData(colorCascaderWarningBorderFocus: v as Color),
    (d) => d.colorCascaderWarningBorderFocus,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-cascader_warning-bg-active: var(--semi-color-warning-light-active)',
    const Color(0xFF000016),
    (v) => SemiCascaderThemeData(colorCascaderWarningBgActive: v as Color),
    (d) => d.colorCascaderWarningBgActive,
    (t) => t.colors.colorWarningLightActive,
  ),
  (
    r'$color-cascader_warning-border-active: var(--semi-color-warning-light-active)',
    const Color(0xFF000017),
    (v) => SemiCascaderThemeData(colorCascaderWarningBorderActive: v as Color),
    (d) => d.colorCascaderWarningBorderActive,
    (t) => t.colors.colorWarningLightActive,
  ),
  (
    r'$color-cascader_danger-bg-default: var(--semi-color-danger-light-default)',
    const Color(0xFF000018),
    (v) => SemiCascaderThemeData(colorCascaderDangerBgDefault: v as Color),
    (d) => d.colorCascaderDangerBgDefault,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-cascader_danger-border-default: var(--semi-color-danger-light-default)',
    const Color(0xFF000019),
    (v) => SemiCascaderThemeData(colorCascaderDangerBorderDefault: v as Color),
    (d) => d.colorCascaderDangerBorderDefault,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-cascader_danger-bg-hover: var(--semi-color-danger-light-hover)',
    const Color(0xFF00001A),
    (v) => SemiCascaderThemeData(colorCascaderDangerBgHover: v as Color),
    (d) => d.colorCascaderDangerBgHover,
    (t) => t.colors.colorDangerLightHover,
  ),
  (
    r'$color-cascader_danger-border-hover: var(--semi-color-danger-light-hover)',
    const Color(0xFF00001B),
    (v) => SemiCascaderThemeData(colorCascaderDangerBorderHover: v as Color),
    (d) => d.colorCascaderDangerBorderHover,
    (t) => t.colors.colorDangerLightHover,
  ),
  (
    r'$color-cascader_danger-bg-focus: var(--semi-color-danger-light-default)',
    const Color(0xFF00001C),
    (v) => SemiCascaderThemeData(colorCascaderDangerBgFocus: v as Color),
    (d) => d.colorCascaderDangerBgFocus,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-cascader_danger-border-focus: var(--semi-color-danger)',
    const Color(0xFF00001D),
    (v) => SemiCascaderThemeData(colorCascaderDangerBorderFocus: v as Color),
    (d) => d.colorCascaderDangerBorderFocus,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-cascader_danger-bg-active: var(--semi-color-danger-light-active)',
    const Color(0xFF00001E),
    (v) => SemiCascaderThemeData(colorCascaderDangerBgActive: v as Color),
    (d) => d.colorCascaderDangerBgActive,
    (t) => t.colors.colorDangerLightActive,
  ),
  (
    r'$color-cascader_danger-border-active: var(--semi-color-danger-light-active)',
    const Color(0xFF00001F),
    (v) => SemiCascaderThemeData(colorCascaderDangerBorderActive: v as Color),
    (d) => d.colorCascaderDangerBorderActive,
    (t) => t.colors.colorDangerLightActive,
  ),
  (
    r'$color-cascader_prefix_suffix_text-default: var(--semi-color-text-2)',
    const Color(0xFF000020),
    (v) =>
        SemiCascaderThemeData(colorCascaderPrefixSuffixTextDefault: v as Color),
    (d) => d.colorCascaderPrefixSuffixTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$spacing-cascader_selection-paddingLeft: 12px',
    1001.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderSelectionPaddingLeft: v as double),
    (d) => d.spacingCascaderSelectionPaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_selection-paddingRight: 12px',
    1001.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionPaddingRight: v as double,
    ),
    (d) => d.spacingCascaderSelectionPaddingRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_small_selection-paddingLeft: 12px',
    1002.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderSmallSelectionPaddingLeft: v as double,
    ),
    (d) => d.spacingCascaderSmallSelectionPaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_small_selection-paddingRight: 12px',
    1002.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSmallSelectionPaddingRight: v as double,
    ),
    (d) => d.spacingCascaderSmallSelectionPaddingRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_large_selection-paddingLeft: 12px',
    1003.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderLargeSelectionPaddingLeft: v as double,
    ),
    (d) => d.spacingCascaderLargeSelectionPaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_large_selection-paddingRight: 12px',
    1003.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderLargeSelectionPaddingRight: v as double,
    ),
    (d) => d.spacingCascaderLargeSelectionPaddingRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_selection_multiple-paddingLeft: $spacing-extra-tight',
    1004.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionMultiplePaddingLeft: v as double,
    ),
    (d) => d.spacingCascaderSelectionMultiplePaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_selection_multiple-paddingRight: $spacing-extra-tight',
    1004.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionMultiplePaddingRight: v as double,
    ),
    (d) => d.spacingCascaderSelectionMultiplePaddingRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_small_selection_multiple-paddingLeft: $spacing-extra-tight',
    1005.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderSmallSelectionMultiplePaddingLeft: v as double,
    ),
    (d) => d.spacingCascaderSmallSelectionMultiplePaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_small_selection_multiple-paddingRight: $spacing-extra-tight',
    1005.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSmallSelectionMultiplePaddingRight: v as double,
    ),
    (d) => d.spacingCascaderSmallSelectionMultiplePaddingRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_large_selection_multiple-paddingLeft: $spacing-extra-tight',
    1006.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderLargeSelectionMultiplePaddingLeft: v as double,
    ),
    (d) => d.spacingCascaderLargeSelectionMultiplePaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_large_selection_multiple-paddingRight: $spacing-extra-tight',
    1006.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderLargeSelectionMultiplePaddingRight: v as double,
    ),
    (d) => d.spacingCascaderLargeSelectionMultiplePaddingRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_selection_tag-marginLeft: $spacing-none',
    1007.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionTagMarginLeft: v as double,
    ),
    (d) => d.spacingCascaderSelectionTagMarginLeft,
    (t) => 0.0,
  ),
  (
    r'$spacing-cascader_selection_tag-marginRight: $spacing-super-tight',
    1007.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionTagMarginRight: v as double,
    ),
    (d) => d.spacingCascaderSelectionTagMarginRight,
    (t) => 2.0,
  ),
  (
    r'$spacing-cascader_selection_tag-marginY: 1px',
    1008.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderSelectionTagMarginY: v as double),
    (d) => d.spacingCascaderSelectionTagMarginY,
    (t) => 1.0,
  ),
  (
    r'$spacing-cascader_selection_tagInput-marginLeft: - $spacing-extra-tight',
    1008.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionTagInputMarginLeft: v as double,
    ),
    (d) => d.spacingCascaderSelectionTagInputMarginLeft,
    (t) => -4.0,
  ),
  (
    r'$spacing-cascader_selection_input-marginLeft: $spacing-extra-tight',
    1009.25,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionInputMarginLeft: v as double,
    ),
    (d) => d.spacingCascaderSelectionInputMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_selection_n-marginRight: $spacing-extra-tight',
    1009.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderSelectionNMarginRight: v as double,
    ),
    (d) => d.spacingCascaderSelectionNMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-cascader_option-icon-marginLeft: 8px',
    1010.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderOptionIconMarginLeft: v as double),
    (d) => d.spacingCascaderOptionIconMarginLeft,
    (t) => 8.0,
  ),
  (
    r'$color-cascader_selection_n-text-default: var(--semi-color-text-0)',
    const Color(0xFF000021),
    (v) =>
        SemiCascaderThemeData(colorCascaderSelectionNTextDefault: v as Color),
    (d) => d.colorCascaderSelectionNTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-cascader_selection_n-text-disabled: var(--semi-color-disabled-text)',
    const Color(0xFF000022),
    (v) =>
        SemiCascaderThemeData(colorCascaderSelectionNTextDisabled: v as Color),
    (d) => d.colorCascaderSelectionNTextDisabled,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-cascader_selection_text_inactive: var(--semi-color-text-2)',
    const Color(0xFF000023),
    (v) =>
        SemiCascaderThemeData(colorCascaderSelectionTextInactive: v as Color),
    (d) => d.colorCascaderSelectionTextInactive,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-cascader_selection-text-default: var(--semi-color-text-0)',
    const Color(0xFF000024),
    (v) => SemiCascaderThemeData(colorCascaderSelectionTextDefault: v as Color),
    (d) => d.colorCascaderSelectionTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-cascader_placeholder-text-default: var(--semi-color-text-2)',
    const Color(0xFF000025),
    (v) =>
        SemiCascaderThemeData(colorCascaderPlaceholderTextDefault: v as Color),
    (d) => d.colorCascaderPlaceholderTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-cascader-icon-default: var(--semi-color-text-2)',
    const Color(0xFF000026),
    (v) => SemiCascaderThemeData(colorCascaderIconDefault: v as Color),
    (d) => d.colorCascaderIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-cascader-icon-hover: var(--semi-color-primary-hover)',
    const Color(0xFF000027),
    (v) => SemiCascaderThemeData(colorCascaderIconHover: v as Color),
    (d) => d.colorCascaderIconHover,
    (t) => t.colors.colorPrimaryHover,
  ),
  (
    r'$color-cascader-icon-active: var(--semi-color-primary-active)',
    const Color(0xFF000028),
    (v) => SemiCascaderThemeData(colorCascaderIconActive: v as Color),
    (d) => d.colorCascaderIconActive,
    (t) => t.colors.colorPrimaryActive,
  ),
  (
    r'$color-cascader_label-text-default: var(--semi-color-text-2)',
    const Color(0xFF000029),
    (v) => SemiCascaderThemeData(colorCascaderLabelTextDefault: v as Color),
    (d) => d.colorCascaderLabelTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-cascader_option-icon-default: $color-cascader-icon-default',
    const Color(0xFF00002A),
    (v) => SemiCascaderThemeData(colorCascaderOptionIconDefault: v as Color),
    (d) => d.colorCascaderOptionIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-cascader_input_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xFF00002B),
    (v) =>
        SemiCascaderThemeData(colorCascaderInputDisabledBgDefault: v as Color),
    (d) => d.colorCascaderInputDisabledBgDefault,
    (t) => t.colors.colorDisabledFill,
  ),
  (
    r'$color-cascader_input_disabled-bg-hover: var(--semi-color-disabled-fill)',
    const Color(0xFF00002C),
    (v) => SemiCascaderThemeData(colorCascaderInputDisabledBgHover: v as Color),
    (d) => d.colorCascaderInputDisabledBgHover,
    (t) => t.colors.colorDisabledFill,
  ),
  (
    r'$color-cascader_input_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xFF00002D),
    (v) => SemiCascaderThemeData(
      colorCascaderInputDisabledTextDefault: v as Color,
    ),
    (d) => d.colorCascaderInputDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-cascader_input_disabled-icon-default: var(--semi-color-disabled-text)',
    const Color(0xFF00002E),
    (v) => SemiCascaderThemeData(
      colorCascaderInputDisabledIconDefault: v as Color,
    ),
    (d) => d.colorCascaderInputDisabledIconDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-cascader_search-border-default: var(--semi-color-fill-0)',
    const Color(0xFF00002F),
    (v) => SemiCascaderThemeData(colorCascaderSearchBorderDefault: v as Color),
    (d) => d.colorCascaderSearchBorderDefault,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-cascader_option_empty-text-default: var(--semi-color-disabled-text)',
    const Color(0xFF000030),
    (v) =>
        SemiCascaderThemeData(colorCascaderOptionEmptyTextDefault: v as Color),
    (d) => d.colorCascaderOptionEmptyTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-cascader_input-bg-default: transparent',
    const Color(0xFF000031),
    (v) => SemiCascaderThemeData(colorCascaderInputBgDefault: v as Color),
    (d) => d.colorCascaderInputBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_input-border-default: none',
    const Color(0xFF000032),
    (v) => SemiCascaderThemeData(colorCascaderInputBorderDefault: v as Color),
    (d) => d.colorCascaderInputBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-cascader_select_highlight: var(--semi-color-primary)',
    const Color(0xFF000033),
    (v) => SemiCascaderThemeData(colorCascaderSelectHighlight: v as Color),
    (d) => d.colorCascaderSelectHighlight,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$font-cascader_select-fontWeight: $font-weight-bold',
    FontWeight.w400,
    (v) => SemiCascaderThemeData(fontCascaderSelectFontWeight: v as FontWeight),
    (d) => d.fontCascaderSelectFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-cascader-fontWeight: $font-weight-regular',
    FontWeight.w500,
    (v) => SemiCascaderThemeData(fontCascaderFontWeight: v as FontWeight),
    (d) => d.fontCascaderFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-cascader_label-fontWeight: 600',
    FontWeight.w600,
    (v) => SemiCascaderThemeData(fontCascaderLabelFontWeight: v as FontWeight),
    (d) => d.fontCascaderLabelFontWeight,
    (t) => FontWeight.w600,
  ),
  (
    r'$font-cascader_selection_n-fontSize: $font-size-small',
    1010.75,
    (v) => SemiCascaderThemeData(fontCascaderSelectionNFontSize: v as double),
    (d) => d.fontCascaderSelectionNFontSize,
    (t) => 12.0,
  ),
  (
    r'$font-cascader_prefix_suffix_fontWeight: $font-weight-bold',
    FontWeight.w700,
    (v) => SemiCascaderThemeData(
      fontCascaderPrefixSuffixFontWeight: v as FontWeight,
    ),
    (d) => d.fontCascaderPrefixSuffixFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$width-cascader-border: 1px',
    1011.25,
    (v) => SemiCascaderThemeData(widthCascaderBorder: v as double),
    (d) => d.widthCascaderBorder,
    (t) => 1.0,
  ),
  (
    r'$width-cascader_option_list-border: 1px',
    1011.75,
    (v) => SemiCascaderThemeData(widthCascaderOptionListBorder: v as double),
    (d) => d.widthCascaderOptionListBorder,
    (t) => 1.0,
  ),
  (
    r'$width-cascader:  80px',
    1012.25,
    (v) => SemiCascaderThemeData(widthCascader: v as double),
    (d) => d.widthCascader,
    (t) => 80.0,
  ),
  (
    r'$height-cascader_default:  $height-control-default',
    1012.75,
    (v) => SemiCascaderThemeData(heightCascaderDefault: v as double),
    (d) => d.heightCascaderDefault,
    (t) => 32.0,
  ),
  (
    r'$height-cascader_small: $height-control-small',
    1013.25,
    (v) => SemiCascaderThemeData(heightCascaderSmall: v as double),
    (d) => d.heightCascaderSmall,
    (t) => 24.0,
  ),
  (
    r'$height-cascader_large: $height-control-large',
    1013.75,
    (v) => SemiCascaderThemeData(heightCascaderLarge: v as double),
    (d) => d.heightCascaderLarge,
    (t) => 40.0,
  ),
  (
    r'$width-cascader_hover-border: $width-cascader-border',
    1014.25,
    (v) => SemiCascaderThemeData(widthCascaderHoverBorder: v as double),
    (d) => d.widthCascaderHoverBorder,
    (t) => 1.0,
  ),
  (
    r'$width-cascader_focus-border: $border-thickness-control-focus',
    1014.75,
    (v) => SemiCascaderThemeData(widthCascaderFocusBorder: v as double),
    (d) => d.widthCascaderFocusBorder,
    (t) => 1.0,
  ),
  (
    r'$width-cascader_search-border: 1px',
    1015.25,
    (v) => SemiCascaderThemeData(widthCascaderSearchBorder: v as double),
    (d) => d.widthCascaderSearchBorder,
    (t) => 1.0,
  ),
  (
    r'$width-cascader-icon: 32px',
    1015.75,
    (v) => SemiCascaderThemeData(widthCascaderIcon: v as double),
    (d) => d.widthCascaderIcon,
    (t) => 32.0,
  ),
  (
    r'$width-cascader-option-icon: 16px',
    1016.25,
    (v) => SemiCascaderThemeData(widthCascaderOptionIcon: v as double),
    (d) => d.widthCascaderOptionIcon,
    (t) => 16.0,
  ),
  (
    r'$width-cascader_option:  150px',
    1016.75,
    (v) => SemiCascaderThemeData(widthCascaderOption: v as double),
    (d) => d.widthCascaderOption,
    (t) => 150.0,
  ),
  (
    r'$height-cascader_option_list: 180px',
    1017.25,
    (v) => SemiCascaderThemeData(heightCascaderOptionList: v as double),
    (d) => d.heightCascaderOptionList,
    (t) => 180.0,
  ),
  (
    r'$height-cascader_selection_tagInput_wrapper_small: 22px',
    1017.75,
    (v) => SemiCascaderThemeData(
      heightCascaderSelectionTagInputWrapperSmall: v as double,
    ),
    (d) => d.heightCascaderSelectionTagInputWrapperSmall,
    (t) => 22.0,
  ),
  (
    r'$height-cascader_selection_tagInput_wrapper_default: 30px',
    1018.25,
    (v) => SemiCascaderThemeData(
      heightCascaderSelectionTagInputWrapperDefault: v as double,
    ),
    (d) => d.heightCascaderSelectionTagInputWrapperDefault,
    (t) => 30.0,
  ),
  (
    r'$height-cascader_selection_tagInput_wrapper_large: 38px',
    1018.75,
    (v) => SemiCascaderThemeData(
      heightCascaderSelectionTagInputWrapperLarge: v as double,
    ),
    (d) => d.heightCascaderSelectionTagInputWrapperLarge,
    (t) => 38.0,
  ),
  (
    r'$height-cascader_selection_wrapper_small: 22px',
    1019.25,
    (v) =>
        SemiCascaderThemeData(heightCascaderSelectionWrapperSmall: v as double),
    (d) => d.heightCascaderSelectionWrapperSmall,
    (t) => 22.0,
  ),
  (
    r'$height-cascader_selection_wrapper: 30px',
    1019.75,
    (v) => SemiCascaderThemeData(heightCascaderSelectionWrapper: v as double),
    (d) => d.heightCascaderSelectionWrapper,
    (t) => 30.0,
  ),
  (
    r'$height-cascader_selection_wrapper_large: 38px',
    1020.25,
    (v) =>
        SemiCascaderThemeData(heightCascaderSelectionWrapperLarge: v as double),
    (d) => d.heightCascaderSelectionWrapperLarge,
    (t) => 38.0,
  ),
  (
    r'$spacing-cascader_text-marginX: $spacing-base-tight',
    1020.75,
    (v) => SemiCascaderThemeData(spacingCascaderTextMarginX: v as double),
    (d) => d.spacingCascaderTextMarginX,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_icon-marginX: $spacing-tight',
    1021.25,
    (v) => SemiCascaderThemeData(spacingCascaderIconMarginX: v as double),
    (d) => d.spacingCascaderIconMarginX,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_label_checkbox-marginRight: $spacing-tight',
    1021.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderLabelCheckboxMarginRight: v as double,
    ),
    (d) => d.spacingCascaderLabelCheckboxMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_selection_n-paddingX: $spacing-tight',
    1022.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderSelectionNPaddingX: v as double),
    (d) => d.spacingCascaderSelectionNPaddingX,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_flatten_list-paddingRight: 64px',
    1022.75,
    (v) => SemiCascaderThemeData(
      spacingCascaderFlattenListPaddingRight: v as double,
    ),
    (d) => d.spacingCascaderFlattenListPaddingRight,
    (t) => 64.0,
  ),
  (
    r'$spacing-cascader_empty_icon-marginRight: 8px',
    1023.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderEmptyIconMarginRight: v as double),
    (d) => d.spacingCascaderEmptyIconMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-cacader_option_list-paddingY: 4px',
    1023.75,
    (v) => SemiCascaderThemeData(spacingCacaderOptionListPaddingY: v as double),
    (d) => d.spacingCacaderOptionListPaddingY,
    (t) => 4.0,
  ),
  (
    r'$spacing-cacader_option_list-paddingX: 0px',
    1024.25,
    (v) => SemiCascaderThemeData(spacingCacaderOptionListPaddingX: v as double),
    (d) => d.spacingCacaderOptionListPaddingX,
    (t) => 0.0,
  ),
  (
    r'$spacing-cascader_search-paddingX: 12px',
    1024.75,
    (v) => SemiCascaderThemeData(spacingCascaderSearchPaddingX: v as double),
    (d) => d.spacingCascaderSearchPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_search-paddingY: 8px',
    1025.25,
    (v) => SemiCascaderThemeData(spacingCascaderSearchPaddingY: v as double),
    (d) => d.spacingCascaderSearchPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_option_empty-paddingY: 8px',
    1025.75,
    (v) =>
        SemiCascaderThemeData(spacingCascaderOptionEmptyPaddingY: v as double),
    (d) => d.spacingCascaderOptionEmptyPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_option_empty-paddingX: 12px',
    1026.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderOptionEmptyPaddingX: v as double),
    (d) => d.spacingCascaderOptionEmptyPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_option-paddingTop: 8px',
    1026.75,
    (v) => SemiCascaderThemeData(spacingCascaderOptionPaddingTop: v as double),
    (d) => d.spacingCascaderOptionPaddingTop,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_option-paddingBottom: 8px',
    1027.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderOptionPaddingBottom: v as double),
    (d) => d.spacingCascaderOptionPaddingBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-cascader_option-paddingLeft: 12px',
    1027.75,
    (v) => SemiCascaderThemeData(spacingCascaderOptionPaddingLeft: v as double),
    (d) => d.spacingCascaderOptionPaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-cascader_option-paddingRight: 16px',
    1028.25,
    (v) =>
        SemiCascaderThemeData(spacingCascaderOptionPaddingRight: v as double),
    (d) => d.spacingCascaderOptionPaddingRight,
    (t) => 16.0,
  ),
  (
    r'$transition_duration-cascader_option-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 101),
    (v) => SemiCascaderThemeData(
      transitionDurationCascaderOptionBg: v as Duration,
    ),
    (d) => d.transitionDurationCascaderOptionBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-cascader_option-bg: var(--semi-transition_function-easeIn)',
    Curves.linear,
    (v) =>
        SemiCascaderThemeData(transitionFunctionCascaderOptionBg: v as Curve),
    (d) => d.transitionFunctionCascaderOptionBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-cascader_option-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 102),
    (v) =>
        SemiCascaderThemeData(transitionDelayCascaderOptionBg: v as Duration),
    (d) => d.transitionDelayCascaderOptionBg,
    (t) => Duration.zero,
  ),
];

String _kindOf(Object v) => switch (v) {
  Color() => 'Color',
  double() => 'double',
  FontWeight() => 'FontWeight',
  Duration() => 'Duration',
  Curve() => 'Curve',
  _ => 'other',
};

void main() {
  group('theme fields (115 = 112 FIELDS + 3 MOTION + 0 INTERNAL)', () {
    test('115 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(115));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiCascaderThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiCascaderThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiCascaderThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_cascader_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(115));
      // ★`none` border 简写 + 双空格 + cacader 拼写原文照抄。
      expect(source, contains(r'$color-cascader_input-border-default: none'));
      expect(source, contains(r'$width-cascader:  80px'));
      expect(
        source,
        contains(r'$height-cascader_default:  $height-control-default'),
      );
      expect(source, contains(r'$width-cascader_option:  150px'));
      expect(source, contains(r'$spacing-cacader_option_list-paddingY: 4px'));
      expect(
        source,
        contains('packages/semi-foundation/cascader/variables.scss'),
      );
      expect(
        source,
        contains('packages/semi-foundation/cascader/animation.scss'),
      );
      expect(source, contains('Generated by tool/generate_cascader.py'));
    });

    test('the 30 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_cascader.dart')
          .readAsStringSync();
      const anchors = <String>[
        "SIZE_SET: ['small', 'large', 'default']",
        "VALIDATE_STATUS: ['success', 'default', 'error', 'warning']",
        "SHOW_NEXT_BY_CLICK: 'click'",
        "SHOW_NEXT_BY_HOVER: 'hover'",
        "SEARCH_POSITION_TRIGGER: 'trigger'",
        "SEARCH_POSITION_CUSTOM: 'custom'",
        "RELATED: 'related'",
        "UN_RELATED: 'unRelated'",
        "LEAF_ONLY_MERGE_TYPE: 'leafOnly'",
        "AUTO_MERGE_VALUE_MERGE_TYPE: 'autoMergeValue'",
        "NONE_MERGE_TYPE: 'none'",
        "'_SEMI_CASCADER_SPLIT_'",
        '<IconChevronDown />',
        'clearIcon ? clearIcon : <IconClear />',
        '<IconChevronRight',
        '<IconTick',
        "separator: ' / '",
        "'aria-label': 'Cascader'",
        'role="combobox"',
        "'bottomRight' : 'bottomLeft'",
        'zIndex: popoverNumbers.DEFAULT_Z_INDEX',
        'e.key === ESC_KEY',
        'isEnterPress',
        "emptyText: '暂无数据'",
        'cursor: pointer',
        'cursor: not-allowed',
        'user-select: none',
        '@include font-size-regular',
        '@include font-size-header-6',
        'opacity: 0',
      ];
      expect(anchors, hasLength(30));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 51 Color + 57 double + 4 FontWeight + 2 Duration + '
        '1 Curve = 115', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(_kindOf(value), (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 51);
      expect(counts['double'], 57);
      expect(counts['FontWeight'], 4);
      expect(counts['Duration'], 2);
      expect(counts['Curve'], 1);
    });

    test('2 dead variables kept and marked; widget does not consume them', () {
      final widgetSource = File('lib/src/components/semi_cascader.dart')
          .readAsStringSync();
      expect(widgetSource, isNot(contains('colorCascaderLabelTextDefault')));
      expect(widgetSource, isNot(contains('fontCascaderLabelFontWeight')));
      final docs = File('docs/semi_cascader.md').readAsStringSync();
      expect(docs, contains('115 = 112 FIELDS + 3 MOTION + 0 INTERNAL'));
      expect(docs, contains('2 死变量'));
      expect(docs, contains(r'$color-cascader_label-text-default:'));
      expect(docs, contains(r'$font-cascader_label-fontWeight:'));
      expect(docs, contains('（上游未消费）'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.cascader, const SemiCascaderThemeData());
      expect(
        themes.copyWith(
          cascader: const SemiCascaderThemeData(widthCascaderIcon: 20),
        ),
        const SemiComponentThemes(
          cascader: SemiCascaderThemeData(widthCascaderIcon: 20),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets(
      'single: tap opens, walk the columns, pick a leaf notifies '
      'onSelect/onChange and closes; re-pick fires onSelect but no onChange',
      (tester) async {
        final events = <String>[];
        await pumpHost(
          tester,
          SemiCascader(
            treeData: data,
            motion: false,
            placeholder: '请选择',
            onSelect: (value) => events.add('select:$value'),
            onChange: (value) => events.add('change:$value'),
            onVisibleChange: (open) => events.add('visible:$open'),
          ),
        );
        expect(find.text('请选择'), findsOneWidget);
        await tester.tap(find.text('请选择'));
        await tester.pumpAndSettle();
        expect(events, ['visible:true']);
        // 非叶点击只展开下一级（changeOnSelect 缺省 false）。
        await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
        await tester.pumpAndSettle();
        expect(rowText('Hangzhou'), findsOneWidget);
        expect(events, ['visible:true']);
        await tester.tap(
          find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou'))),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou/xihu'))),
        );
        await tester.pumpAndSettle();
        expect(events, [
          'visible:true',
          'select:xihu',
          'change:[zhejiang, hangzhou, xihu]',
          'visible:false',
        ]);
        expect(find.text('Zhejiang / Hangzhou / Xihu'), findsOneWidget);
        // Re-open and re-pick the same leaf：仍发 onSelect、不发 onChange、照常收起。
        await tester.tap(find.text('Zhejiang / Hangzhou / Xihu'));
        await tester.pumpAndSettle();
        await tester.tap(rowText('Xihu'));
        await tester.pumpAndSettle();
        expect(events.where((e) => e.startsWith('change:')), hasLength(1));
        expect(events.where((e) => e == 'select:xihu'), hasLength(2));
        expect(find.byKey(SemiCascader.listKey), findsNothing);
      },
    );

    testWidgets('changeOnSelect picks non-leaf and keeps the panel open', (
      tester,
    ) async {
      final events = <String>[];
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          motion: false,
          changeOnSelect: true,
          onSelect: (value) => events.add('select:$value'),
          onChange: (value) => events.add('change:$value'),
          onVisibleChange: (open) => events.add('visible:$open'),
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
      await tester.pumpAndSettle();
      expect(events, ['visible:true', 'select:zhejiang', 'change:[zhejiang]']);
      expect(find.byKey(SemiCascader.listKey), findsOneWidget); // 面板保持
    });

    testWidgets('showNext hover expands the next column without clicking', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          motion: false,
          showNext: SemiCascaderShowNext.hover,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      expect(rowText('Hangzhou'), findsNothing);
      final gesture = await startMouse(tester);
      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiCascader.optionKey('zhejiang'))),
      );
      await tester.pumpAndSettle();
      expect(rowText('Hangzhou'), findsOneWidget);
    });

    testWidgets('multiple related cascade; autoMergeValue payload; half '
        'check on the parent', (tester) async {
      Object? last;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          multiple: true,
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionCheckboxKey(k('zhejiang/hangzhou'))),
      );
      await tester.pumpAndSettle();
      // 级联勾选 Xihu+Binjiang；autoMergeValue 去祖先 → 只回 Hangzhou 路径。
      expect(last, [
        ['zhejiang', 'hangzhou'],
      ]);
      // 父级半选。
      final parent = tester.widget<SemiCheckbox>(
        find.byKey(SemiCascader.optionCheckboxKey('zhejiang')),
      );
      expect(parent.indeterminate, isTrue);
      // 触发器标签回填（面板内行也有 Hangzhou——按 SemiTag 限定）。
      expect(
        find.descendant(
          of: find.byType(SemiTag),
          matching: find.text('Hangzhou'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('leafOnly payload keeps only leaf paths', (tester) async {
      Object? last;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          multiple: true,
          leafOnly: true,
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionCheckboxKey(k('zhejiang/hangzhou'))),
      );
      await tester.pumpAndSettle();
      expect(last, [
        ['zhejiang', 'hangzhou', 'xihu'],
        ['zhejiang', 'hangzhou', 'binjiang'],
      ]);
    });

    testWidgets('unRelated toggles independently', (tester) async {
      Object? last;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          multiple: true,
          checkRelation: SemiCascaderCheckRelation.unRelated,
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionCheckboxKey(k('zhejiang/hangzhou'))),
      );
      await tester.pumpAndSettle();
      // 无级联：只回 Hangzhou 自身。
      expect(last, [
        ['zhejiang', 'hangzhou'],
      ]);
      final parent = tester.widget<SemiCheckbox>(
        find.byKey(SemiCascader.optionCheckboxKey('zhejiang')),
      );
      expect(parent.indeterminate, isFalse);
      expect(parent.checked, isFalse);
    });

    testWidgets('max caps the selection and reports onExceed', (tester) async {
      Object? last;
      final exceeded = <List<SemiCascaderData>>[];
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          multiple: true,
          max: 1,
          motion: false,
          onChange: (value) => last = value,
          onExceed: exceeded.add,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionCheckboxKey(k('zhejiang/hangzhou'))),
      );
      await tester.pumpAndSettle();
      expect(last, [
        ['zhejiang', 'hangzhou'],
      ]);
      // 再选 Suzhou → 超限只回调不改值。
      await tester.tap(find.byKey(SemiCascader.optionKey('jiangsu')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionCheckboxKey(k('jiangsu/suzhou'))),
      );
      await tester.pumpAndSettle();
      expect(exceeded, hasLength(1));
      expect(exceeded.first.map((e) => e.value), ['hangzhou', 'suzhou']);
      expect(last, [
        ['zhejiang', 'hangzhou'],
      ]);
    });

    testWidgets('tag close reverts the checked node', (tester) async {
      Object? last;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          multiple: true,
          defaultValue: const [
            ['zhejiang', 'hangzhou', 'xihu'],
          ],
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      expect(find.text('Xihu'), findsOneWidget); // tag
      await tester.tap(
        find.descendant(
          of: find.byType(SemiTag),
          matching: find.byType(SemiIcon),
        ),
      );
      await tester.pumpAndSettle();
      expect(last, isEmpty);
    });

    testWidgets('clear button replaces the arrow while open and resets value', (
      tester,
    ) async {
      Object? last;
      var cleared = 0;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          showClear: true,
          motion: false,
          defaultValue: const ['zhejiang', 'ningbo'],
          onChange: (value) => last = value,
          onClear: () => cleared++,
        ),
      );
      expect(find.text('Zhejiang / Ningbo'), findsOneWidget);
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiCascader.clearButtonKey), findsOneWidget);
      await tester.tap(find.byKey(SemiCascader.clearButtonKey));
      await tester.pumpAndSettle();
      expect(last, isEmpty);
      expect(cleared, 1);
    });

    testWidgets('search flattens the matches (leaves only by default) and '
        'picking a result selects and closes', (tester) async {
      final searches = <String>[];
      Object? last;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          motion: false,
          filterTreeNode: true,
          onChange: (value) => last = value,
          onSearch: searches.add,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(SemiCascader.searchInputKey), 'xihu');
      await tester.pumpAndSettle();
      expect(searches, ['xihu']);
      // filterLeafOnly 缺省 true：只出叶子行。
      expect(
        find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou/xihu'))),
        findsOneWidget,
      );
      expect(
        find.byKey(SemiCascader.optionKey('zhejiang')),
        findsNothing, // 非叶不入结果
      );
      await tester.tap(
        find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou/xihu'))),
      );
      await tester.pumpAndSettle();
      expect(last, ['zhejiang', 'hangzhou', 'xihu']);
      expect(find.byKey(SemiCascader.listKey), findsNothing);
    });

    testWidgets('remote skips local matching and lists the leaves', (
      tester,
    ) async {
      final searches = <String>[];
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          motion: false,
          remote: true,
          filterTreeNode: true,
          onSearch: searches.add,
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(SemiCascader.searchInputKey), 'zzz');
      await tester.pumpAndSettle();
      expect(searches, ['zzz']);
      // 本地列表未被过滤（叶子全量；结果行是高亮 Text.rich——按行 key 断言）。
      expect(
        find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou/xihu'))),
        findsOneWidget,
      );
      expect(
        find.byKey(SemiCascader.optionKey(k('jiangsu/suzhou'))),
        findsOneWidget,
      );
    });

    testWidgets('loadData shows the spin and reports onLoad', (tester) async {
      final loaded = <String>[];
      final gate = Completer<void>();
      await pumpHost(
        tester,
        SemiCascader(
          treeData: const [SemiCascaderData(value: 'p', label: 'P')],
          motion: false,
          loadData: (_) => gate.future,
          onLoad: (keys, node) => loaded.add(node.value),
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('p')));
      // 弹层内容更新走 SemiTooltip post-frame（一帧延迟）——双 pump 后 Spin 上屏
      //（Spin 自带循环动画，不能 pumpAndSettle）。
      await tester.pump();
      await tester.pump();
      expect(find.byType(SemiSpin), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(loaded, ['p']);
    });

    testWidgets('empty state honors emptyContent and locale default', (
      tester,
    ) async {
      await pumpHost(tester, const SemiCascader(treeData: [], motion: false));
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiCascader.emptyKey), findsOneWidget);
      expect(find.text('暂无数据'), findsOneWidget);

      await pumpHost(
        tester,
        const SemiCascader(treeData: [], motion: false, emptyContent: '空空如也'),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      expect(find.text('空空如也'), findsOneWidget);
    });

    testWidgets('maxTagCount folds the rest into "+N" with a tooltip', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          multiple: true,
          leafOnly: true,
          motion: false,
          maxTagCount: 1,
          showRestTagsPopover: true,
          defaultValue: const [
            ['zhejiang', 'hangzhou', 'xihu'],
            ['zhejiang', 'hangzhou', 'binjiang'],
          ],
        ),
      );
      expect(find.text('Xihu'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text('+1')));
      await tester.pumpAndSettle();
      expect(find.text('Binjiang'), findsOneWidget); // tooltip 列出折叠标签
    });

    testWidgets('sizes map to the trigger min-heights', (tester) async {
      for (final (size, height) in [
        (SemiInputSize.small, 24.0),
        (SemiInputSize.normal, 32.0),
        (SemiInputSize.large, 40.0),
      ]) {
        await pumpHost(
          tester,
          SemiCascader(
            treeData: data,
            size: size,
            motion: false,
            placeholder: 'x',
          ),
        );
        final box = tester.renderObject<RenderBox>(find.text('x'));
        expect(box.size.height, greaterThanOrEqualTo(height - 0.01));
        expect(box.size.height, lessThanOrEqualTo(height + 0.01));
      }
    });

    testWidgets('validateStatus warning/danger paint the status border; '
        'borderless resting paints nothing', (tester) async {
      BoxDecoration decoration(WidgetTester tester) =>
          tester
                  .widget<DecoratedBox>(
                    find
                        .ancestor(
                          of: find.text('x'),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;

      await pumpHost(
        tester,
        const SemiCascader(
          treeData: [],
          motion: false,
          placeholder: 'x',
          validateStatus: SemiInputStatus.warning,
        ),
      );
      final warn = decoration(tester);
      expect(
        warn.border!.top.color,
        const SemiThemeData.light().colors.colorWarningLightDefault,
      );

      await pumpHost(
        tester,
        const SemiCascader(
          treeData: [],
          motion: false,
          borderless: true,
          placeholder: 'x',
        ),
      );
      final silent = decoration(tester);
      expect(silent.color, const Color(0x00000000));
      expect(silent.border!.top.color, const Color(0x00000000));
    });

    testWidgets('ESC closes the open panel', (tester) async {
      final events = <String>[];
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          motion: false,
          onVisibleChange: (open) => events.add('visible:$open'),
        ),
      );
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      expect(rowText('Jiangsu'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(SemiCascader.listKey), findsNothing);
      expect(events, ['visible:true', 'visible:false']);
    });

    testWidgets('defaultOpen mounts the panel open', (tester) async {
      await pumpHost(
        tester,
        const SemiCascader(treeData: data, motion: false, defaultOpen: true),
      );
      await tester.pumpAndSettle();
      expect(rowText('Jiangsu'), findsOneWidget);
    });

    testWidgets('controlled value only notifies and keeps the display', (
      tester,
    ) async {
      Object? last;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          value: const ['zhejiang', 'ningbo'],
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      expect(find.text('Zhejiang / Ningbo'), findsOneWidget); // trigger 回填
      await tester.tap(find.byType(SemiCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiCascader.optionKey('zhejiang')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(SemiCascader.optionKey(k('zhejiang/hangzhou/xihu'))),
      );
      await tester.pumpAndSettle();
      expect(last, ['zhejiang', 'hangzhou', 'xihu']); // 回调照发
      expect(find.text('Zhejiang / Ningbo'), findsOneWidget); // 受控不改显示
    });

    testWidgets('disabled blocks the trigger', (tester) async {
      var changes = 0;
      await pumpHost(
        tester,
        SemiCascader(
          treeData: data,
          disabled: true,
          motion: false,
          onChange: (_) => changes++,
        ),
      );
      await tester.tap(find.byType(SemiCascader), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byKey(SemiCascader.listKey), findsNothing); // 面板未开
      expect(changes, 0);
    });
  });
}
