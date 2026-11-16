// Behavior matrix for SemiTreeSelect plus coverage for the 74 Sass
// declarations (74 FIELDS + 0 MOTION + 0 INTERNAL) — the 22 HARDCODES
// provenance anchors live in the widget's `_TreeSelectMetrics` / call sites.
// ★1 死变量（上游未消费）：`$color-treeSelect_input_disabled-border-default`
// 仅被 treeSelect.scss:99 注释行引用——字段保留、widget 不消费（docs 标注）。
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

/// 2-level fixture: A [B, C(disabled)] + D(leaf).
const data = <SemiTreeNodeData>[
  SemiTreeNodeData(
    key: 'a',
    label: 'A',
    children: [
      SemiTreeNodeData(key: 'b', label: 'B'),
      SemiTreeNodeData(key: 'c', label: 'C', disabled: true),
    ],
  ),
  SemiTreeNodeData(key: 'd', label: 'D', isLeaf: true),
];

Finder expandArrow(String key) => find.byKey(ValueKey('treeSelect-expand-$key'));

/// 弹层内文本（避开触发器回填/标签的同名文本）。
Finder rowText(String text) => find.descendant(
  of: find.byKey(SemiTreeSelect.listKey),
  matching: find.text(text),
);

typedef _Patch = SemiTreeSelectThemeData Function(Object v);
typedef _Read = Object? Function(SemiResolvedTreeSelectThemeData d);
typedef _Expected = Object? Function(SemiThemeData t);

final List<(String, Object, _Patch, _Read, _Expected)> fields = [
  (
    r'$color-treeSelect_default-bg-default: var(--semi-color-fill-0)',
    const Color(0xFF000001),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDefaultBgDefault: v as Color),
    (d) => d.colorTreeSelectDefaultBgDefault,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-treeSelect_default-bg-hover: var(--semi-color-fill-1)',
    const Color(0xFF000002),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDefaultBgHover: v as Color),
    (d) => d.colorTreeSelectDefaultBgHover,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-treeSelect_default-bg-active: var(--semi-color-fill-2)',
    const Color(0xFF000003),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDefaultBgActive: v as Color),
    (d) => d.colorTreeSelectDefaultBgActive,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-treeSelect_default-bg-focus: var(--semi-color-fill-0)',
    const Color(0xFF000004),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDefaultBgFocus: v as Color),
    (d) => d.colorTreeSelectDefaultBgFocus,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-treeSelect_default-border-default: transparent',
    const Color(0xFF000005),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDefaultBorderDefault: v as Color),
    (d) => d.colorTreeSelectDefaultBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-treeSelect_selection-text-default: var(--semi-color-text-0)',
    const Color(0xFF000006),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectSelectionTextDefault: v as Color),
    (d) => d.colorTreeSelectSelectionTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-treeSelect_default-icon-default: var(--semi-color-text-2)',
    const Color(0xFF000007),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDefaultIconDefault: v as Color),
    (d) => d.colorTreeSelectDefaultIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-treeSelect_default-icon-hover: var(--semi-color-primary-hover)',
    const Color(0xFF000008),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDefaultIconHover: v as Color),
    (d) => d.colorTreeSelectDefaultIconHover,
    (t) => t.colors.colorPrimaryHover,
  ),
  (
    r'$color-treeSelect_default-icon-active: var(--semi-color-primary-active)',
    const Color(0xFF000009),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDefaultIconActive: v as Color),
    (d) => d.colorTreeSelectDefaultIconActive,
    (t) => t.colors.colorPrimaryActive,
  ),
  (
    r'$color-treeSelect_default-border-hover: transparent',
    const Color(0xFF00000A),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDefaultBorderHover: v as Color),
    (d) => d.colorTreeSelectDefaultBorderHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-treeSelect_default-border-focus: var(--semi-color-focus-border)',
    const Color(0xFF00000B),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDefaultBorderFocus: v as Color),
    (d) => d.colorTreeSelectDefaultBorderFocus,
    (t) => t.colors.colorFocusBorder,
  ),
  (
    r'$color-treeSelect_search-border-default: var(--semi-color-fill-0)',
    const Color(0xFF00000C),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectSearchBorderDefault: v as Color),
    (d) => d.colorTreeSelectSearchBorderDefault,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-treeSelect_tag_disabled-bg-default: transparent',
    const Color(0xFF00000D),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectTagDisabledBgDefault: v as Color),
    (d) => d.colorTreeSelectTagDisabledBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-treeSelect_input_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xFF00000E),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectInputDisabledBgDefault: v as Color,
    ),
    (d) => d.colorTreeSelectInputDisabledBgDefault,
    (t) => t.colors.colorDisabledFill,
  ),
  (
    r'$color-treeSelect_input_disabled-border-default: var(--semi-color-disabled-border)',
    const Color(0xFF00000F),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectInputDisabledBorderDefault: v as Color,
    ),
    (d) => d.colorTreeSelectInputDisabledBorderDefault,
    (t) => t.colors.colorDisabledBorder,
  ),
  (
    r'$color-treeSelect_input_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xFF000010),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectInputDisabledTextDefault: v as Color,
    ),
    (d) => d.colorTreeSelectInputDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-treeSelect_input_disabled-bg-hover: var(--semi-color-disabled-fill)',
    const Color(0xFF000011),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectInputDisabledBgHover: v as Color,
    ),
    (d) => d.colorTreeSelectInputDisabledBgHover,
    (t) => t.colors.colorDisabledFill,
  ),
  (
    r'$color-treeSelect_input_placeholder-text-default: var(--semi-color-text-2)',
    const Color(0xFF000012),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectInputPlaceholderTextDefault: v as Color,
    ),
    (d) => d.colorTreeSelectInputPlaceholderTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-treeSelect_warning-bg-default: var(--semi-color-warning-light-default)',
    const Color(0xFF000013),
    (v) => SemiTreeSelectThemeData(colorTreeSelectWarningBgDefault: v as Color),
    (d) => d.colorTreeSelectWarningBgDefault,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-treeSelect_warning-border-default: var(--semi-color-warning-light-default)',
    const Color(0xFF000014),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectWarningBorderDefault: v as Color),
    (d) => d.colorTreeSelectWarningBorderDefault,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-treeSelect_warning-bg-hover: var(--semi-color-warning-light-hover)',
    const Color(0xFF000015),
    (v) => SemiTreeSelectThemeData(colorTreeSelectWarningBgHover: v as Color),
    (d) => d.colorTreeSelectWarningBgHover,
    (t) => t.colors.colorWarningLightHover,
  ),
  (
    r'$color-treeSelect_warning-border-hover: var(--semi-color-warning-light-hover)',
    const Color(0xFF000016),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectWarningBorderHover: v as Color),
    (d) => d.colorTreeSelectWarningBorderHover,
    (t) => t.colors.colorWarningLightHover,
  ),
  (
    r'$color-treeSelect_warning-bg-focus: var(--semi-color-warning-light-default)',
    const Color(0xFF000017),
    (v) => SemiTreeSelectThemeData(colorTreeSelectWarningBgFocus: v as Color),
    (d) => d.colorTreeSelectWarningBgFocus,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-treeSelect_warning-border-focus: var(--semi-color-warning)',
    const Color(0xFF000018),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectWarningBorderFocus: v as Color),
    (d) => d.colorTreeSelectWarningBorderFocus,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-treeSelect_warning-bg-active: var(--semi-color-warning-light-active)',
    const Color(0xFF000019),
    (v) => SemiTreeSelectThemeData(colorTreeSelectWarningBgActive: v as Color),
    (d) => d.colorTreeSelectWarningBgActive,
    (t) => t.colors.colorWarningLightActive,
  ),
  (
    r'$color-treeSelect_warning-border-active: var(--semi-color-warning-light-active)',
    const Color(0xFF00001A),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectWarningBorderActive: v as Color),
    (d) => d.colorTreeSelectWarningBorderActive,
    (t) => t.colors.colorWarningLightActive,
  ),
  (
    r'$color-treeSelect_danger-bg-default: var(--semi-color-danger-light-default)',
    const Color(0xFF00001B),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDangerBgDefault: v as Color),
    (d) => d.colorTreeSelectDangerBgDefault,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-treeSelect_danger-border-default: var(--semi-color-danger-light-default)',
    const Color(0xFF00001C),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDangerBorderDefault: v as Color),
    (d) => d.colorTreeSelectDangerBorderDefault,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-treeSelect_danger-bg-hover: var(--semi-color-danger-light-hover)',
    const Color(0xFF00001D),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDangerBgHover: v as Color),
    (d) => d.colorTreeSelectDangerBgHover,
    (t) => t.colors.colorDangerLightHover,
  ),
  (
    r'$color-treeSelect_danger-border-hover: var(--semi-color-danger-light-hover)',
    const Color(0xFF00001E),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDangerBorderHover: v as Color),
    (d) => d.colorTreeSelectDangerBorderHover,
    (t) => t.colors.colorDangerLightHover,
  ),
  (
    r'$color-treeSelect_danger-bg-focus: var(--semi-color-danger-light-default)',
    const Color(0xFF00001F),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDangerBgFocus: v as Color),
    (d) => d.colorTreeSelectDangerBgFocus,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-treeSelect_danger-border-focus: var(--semi-color-danger)',
    const Color(0xFF000020),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDangerBorderFocus: v as Color),
    (d) => d.colorTreeSelectDangerBorderFocus,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-treeSelect_danger-bg-active: var(--semi-color-danger-light-active)',
    const Color(0xFF000021),
    (v) => SemiTreeSelectThemeData(colorTreeSelectDangerBgActive: v as Color),
    (d) => d.colorTreeSelectDangerBgActive,
    (t) => t.colors.colorDangerLightActive,
  ),
  (
    r'$color-treeSelect_danger-border-active: var(--semi-color-danger-light-active)',
    const Color(0xFF000022),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectDangerBorderActive: v as Color),
    (d) => d.colorTreeSelectDangerBorderActive,
    (t) => t.colors.colorDangerLightActive,
  ),
  (
    r'$radius-treeSelect: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiTreeSelectThemeData(radiusTreeSelect: v as double),
    (d) => d.radiusTreeSelect,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$width-treeSelect-border: 1px',
    102.0,
    (v) => SemiTreeSelectThemeData(widthTreeSelectBorder: v as double),
    (d) => d.widthTreeSelectBorder,
    (t) => 1.0,
  ),
  (
    r'$width-treeSelect_search_wrapper-border: 1px',
    103.0,
    (v) =>
        SemiTreeSelectThemeData(widthTreeSelectSearchWrapperBorder: v as double),
    (d) => d.widthTreeSelectSearchWrapperBorder,
    (t) => 1.0,
  ),
  (
    r'$width-treeSelect_hover-border: $border-thickness-control-focus',
    104.0,
    (v) => SemiTreeSelectThemeData(widthTreeSelectHoverBorder: v as double),
    (d) => d.widthTreeSelectHoverBorder,
    (t) => 1.0,
  ),
  (
    r'$width-treeSelect_focus-border: $width-treeSelect_hover-border',
    105.0,
    (v) => SemiTreeSelectThemeData(widthTreeSelectFocusBorder: v as double),
    (d) => d.widthTreeSelectFocusBorder,
    (t) => 1.0,
  ),
  (
    r'$width-treeSelect_default: 80px',
    106.0,
    (v) => SemiTreeSelectThemeData(widthTreeSelectDefault: v as double),
    (d) => d.widthTreeSelectDefault,
    (t) => 80.0,
  ),
  (
    r'$height-treeSelect_default: $height-control-default',
    107.0,
    (v) => SemiTreeSelectThemeData(heightTreeSelectDefault: v as double),
    (d) => d.heightTreeSelectDefault,
    (t) => 32.0,
  ),
  (
    r'$font-treeSelect_default-lineHeight: $height-treeSelect_default',
    108.0,
    (v) =>
        SemiTreeSelectThemeData(fontTreeSelectDefaultLineHeight: v as double),
    (d) => d.fontTreeSelectDefaultLineHeight,
    (t) => 32.0,
  ),
  (
    r'$font-treeSelect_default-fontWeight: $font-weight-regular',
    FontWeight.w300,
    (v) => SemiTreeSelectThemeData(
      fontTreeSelectDefaultFontWeight: v as FontWeight,
    ),
    (d) => d.fontTreeSelectDefaultFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-treeSelect_default-fontSize: 14px',
    109.0,
    (v) => SemiTreeSelectThemeData(fontTreeSelectDefaultFontSize: v as double),
    (d) => d.fontTreeSelectDefaultFontSize,
    (t) => 14.0,
  ),
  (
    r'$height-treeSelect_small: $height-control-small',
    110.0,
    (v) => SemiTreeSelectThemeData(heightTreeSelectSmall: v as double),
    (d) => d.heightTreeSelectSmall,
    (t) => 24.0,
  ),
  (
    r'$font-treeSelect_small-lineHeight: $height-treeSelect_small',
    111.0,
    (v) => SemiTreeSelectThemeData(fontTreeSelectSmallLineHeight: v as double),
    (d) => d.fontTreeSelectSmallLineHeight,
    (t) => 24.0,
  ),
  (
    r'$height-treeSelect_large: $height-control-large',
    112.0,
    (v) => SemiTreeSelectThemeData(heightTreeSelectLarge: v as double),
    (d) => d.heightTreeSelectLarge,
    (t) => 40.0,
  ),
  (
    r'$font-treeSelect_large-lineHeight: $height-treeSelect_large',
    113.0,
    (v) => SemiTreeSelectThemeData(fontTreeSelectLargeLineHeight: v as double),
    (d) => d.fontTreeSelectLargeLineHeight,
    (t) => 40.0,
  ),
  (
    r'$font-treeSelect_prefix_suffix_fontWeight: $font-weight-bold',
    FontWeight.w300,
    (v) => SemiTreeSelectThemeData(
      fontTreeSelectPrefixSuffixFontWeight: v as FontWeight,
    ),
    (d) => d.fontTreeSelectPrefixSuffixFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$spacing-treeSelect_selection_tagInput_wrapper-paddingX: $spacing-extra-tight',
    114.0,
    (v) => SemiTreeSelectThemeData(
      spacingTreeSelectSelectionTagInputWrapperPaddingX: v as double,
    ),
    (d) => d.spacingTreeSelectSelectionTagInputWrapperPaddingX,
    (t) => 4.0,
  ),
  (
    r'$spacing-treeSelect_selection_tagInput_empty-marginLeft: $spacing-extra-tight',
    115.0,
    (v) => SemiTreeSelectThemeData(
      spacingTreeSelectSelectionTagInputEmptyMarginLeft: v as double,
    ),
    (d) => d.spacingTreeSelectSelectionTagInputEmptyMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-treeSelect_selection_tagInput_notEmpty-marginLeft: - $spacing-extra-tight',
    116.0,
    (v) => SemiTreeSelectThemeData(
      spacingTreeSelectSelectionTagInputNotEmptyMarginLeft: v as double,
    ),
    (d) => d.spacingTreeSelectSelectionTagInputNotEmptyMarginLeft,
    (t) => -4.0,
  ),
  (
    r'$spacing-treeSelect_selection-paddingLeft: $spacing-base-tight',
    117.0,
    (v) =>
        SemiTreeSelectThemeData(spacingTreeSelectSelectionPaddingLeft: v as double),
    (d) => d.spacingTreeSelectSelectionPaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-treeSelect_tag-marginX: $spacing-super-tight',
    118.0,
    (v) => SemiTreeSelectThemeData(spacingTreeSelectTagMarginX: v as double),
    (d) => d.spacingTreeSelectTagMarginX,
    (t) => 2.0,
  ),
  (
    r'$spacing-treeSelect_tag-marginY: 1px',
    119.0,
    (v) => SemiTreeSelectThemeData(spacingTreeSelectTagMarginY: v as double),
    (d) => d.spacingTreeSelectTagMarginY,
    (t) => 1.0,
  ),
  (
    r'$spacing-treeSelect_selection_multiple-paddingLeft: 4px',
    120.0,
    (v) => SemiTreeSelectThemeData(
      spacingTreeSelectSelectionMultiplePaddingLeft: v as double,
    ),
    (d) => d.spacingTreeSelectSelectionMultiplePaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-treeSelect_placeholder_multiple-paddingLeft: 8px',
    121.0,
    (v) => SemiTreeSelectThemeData(
      spacingTreeSelectPlaceholderMultiplePaddingLeft: v as double,
    ),
    (d) => d.spacingTreeSelectPlaceholderMultiplePaddingLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-treeSelect_prefix_text-marginY: 0px',
    122.0,
    (v) => SemiTreeSelectThemeData(spacingTreeSelectPrefixTextMarginY: v as double),
    (d) => d.spacingTreeSelectPrefixTextMarginY,
    (t) => 0.0,
  ),
  (
    r'$spacing-treeSelect_prefix_text-marginX: $spacing-base-tight',
    123.0,
    (v) => SemiTreeSelectThemeData(spacingTreeSelectPrefixTextMarginX: v as double),
    (d) => d.spacingTreeSelectPrefixTextMarginX,
    (t) => 12.0,
  ),
  (
    r'$spacing-treeSelect_prefix_icon-marginY: 0px',
    124.0,
    (v) => SemiTreeSelectThemeData(spacingTreeSelectPrefixIconMarginY: v as double),
    (d) => d.spacingTreeSelectPrefixIconMarginY,
    (t) => 0.0,
  ),
  (
    r'$spacing-treeSelect_prefix_icon-marginX: $spacing-tight',
    125.0,
    (v) => SemiTreeSelectThemeData(spacingTreeSelectPrefixIconMarginX: v as double),
    (d) => d.spacingTreeSelectPrefixIconMarginX,
    (t) => 8.0,
  ),
  (
    r'$spacing-treeSelect_selection_withSuffix-paddingRight: 0px',
    126.0,
    (v) => SemiTreeSelectThemeData(
      spacingTreeSelectSelectionWithSuffixPaddingRight: v as double,
    ),
    (d) => d.spacingTreeSelectSelectionWithSuffixPaddingRight,
    (t) => 0.0,
  ),
  (
    r'$spacing-treeSelect_search_wrapper-paddingX: 12px',
    127.0,
    (v) =>
        SemiTreeSelectThemeData(spacingTreeSelectSearchWrapperPaddingX: v as double),
    (d) => d.spacingTreeSelectSearchWrapperPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-treeSelect_search_wrapper-paddingY: 8px',
    128.0,
    (v) =>
        SemiTreeSelectThemeData(spacingTreeSelectSearchWrapperPaddingY: v as double),
    (d) => d.spacingTreeSelectSearchWrapperPaddingY,
    (t) => 8.0,
  ),
  (
    r'$color-treeSelect_selection_TriggerSearchItem_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xFF000023),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectSelectionTriggerSearchItemDisabledTextDefault: v as Color,
    ),
    (d) => d.colorTreeSelectSelectionTriggerSearchItemDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-treeSelect_inputTrigger-border-default: none',
    const Color(0xFF000024),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectInputTriggerBorderDefault: v as Color,
    ),
    (d) => d.colorTreeSelectInputTriggerBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-treeSelect_inputTrigger-bg-default: transparent',
    const Color(0xFF000025),
    (v) =>
        SemiTreeSelectThemeData(colorTreeSelectInputTriggerBgDefault: v as Color),
    (d) => d.colorTreeSelectInputTriggerBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-treeSelect_prefix_suffix_text-default: var(--semi-color-text-2)',
    const Color(0xFF000026),
    (v) => SemiTreeSelectThemeData(
      colorTreeSelectPrefixSuffixTextDefault: v as Color,
    ),
    (d) => d.colorTreeSelectPrefixSuffixTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$width-treeSelect_arrow: 32px',
    129.0,
    (v) => SemiTreeSelectThemeData(widthTreeSelectArrow: v as double),
    (d) => d.widthTreeSelectArrow,
    (t) => 32.0,
  ),
  (
    r'$width-treeSelect_option:  230px',
    130.0,
    (v) => SemiTreeSelectThemeData(widthTreeSelectOption: v as double),
    (d) => d.widthTreeSelectOption,
    (t) => 230.0,
  ),
  (
    r'$height-treeSelect_popover: 300px',
    131.0,
    (v) => SemiTreeSelectThemeData(heightTreeSelectPopover: v as double),
    (d) => d.heightTreeSelectPopover,
    (t) => 300.0,
  ),
  (
    r'$height-treeSelect_selection_tagInput_wrapper_small: 22px',
    132.0,
    (v) => SemiTreeSelectThemeData(
      heightTreeSelectSelectionTagInputWrapperSmall: v as double,
    ),
    (d) => d.heightTreeSelectSelectionTagInputWrapperSmall,
    (t) => 22.0,
  ),
  (
    r'$height-treeSelect_selection_tagInput_wrapper_default: 30px',
    133.0,
    (v) => SemiTreeSelectThemeData(
      heightTreeSelectSelectionTagInputWrapperDefault: v as double,
    ),
    (d) => d.heightTreeSelectSelectionTagInputWrapperDefault,
    (t) => 30.0,
  ),
  (
    r'$height-treeSelect_selection_tagInput_wrapper_large: 38px',
    134.0,
    (v) => SemiTreeSelectThemeData(
      heightTreeSelectSelectionTagInputWrapperLarge: v as double,
    ),
    (d) => d.heightTreeSelectSelectionTagInputWrapperLarge,
    (t) => 38.0,
  ),
];

void main() {
  group('theme fields (74 = 74 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('74 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(74));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiTreeSelectThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiTreeSelectThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiTreeSelectThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_tree_select_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(74));
      // ★`none` border 简写 + 双空格原文照抄。
      expect(
        source,
        contains(r'$color-treeSelect_inputTrigger-border-default: none'),
      );
      expect(source, contains(r'$width-treeSelect_option:  230px'));
      expect(
        source,
        contains('packages/semi-foundation/treeSelect/variables.scss'),
      );
      expect(source, contains('Generated by tool/generate_tree_select.py'));
    });

    test('the 22 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_tree_select.dart')
          .readAsStringSync();
      const anchors = <String>[
        "SIZE_SET: ['small', 'large', 'default']",
        "SEARCH_POSITION_DROPDOWN: 'dropdown'",
        "SEARCH_POSITION_TRIGGER: 'trigger'",
        "'error' | 'warning' | 'default'",
        '<IconChevronDown />',
        '<IconClear />',
        "aria-label='Filter TreeSelect item'",
        'aria-label="Clear TreeSelect value"',
        "role='combobox'",
        'aria-haspopup="tree"',
        "'aria-label': 'TreeSelect'",
        "position ? position : 'bottomLeft'",
        'zIndex: popoverNumbers.DEFAULT_Z_INDEX',
        'e.key === ESC_KEY',
        'isEnterPress',
        'opacity: .6',
        '@include font-size-regular',
        '@include font-size-header-6',
        'cursor: pointer',
        'cursor: not-allowed',
        'user-select: none',
        "searchPlaceholder: '搜索'",
      ];
      expect(anchors, hasLength(22));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 38 Color + 34 double + 2 FontWeight = 74', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 38);
      expect(counts['double'], 34);
      expect(counts['FontWeight'], 2);
    });

    test('1 dead variable kept and marked; widget does not consume it', () {
      final widgetSource = File('lib/src/components/semi_tree_select.dart')
          .readAsStringSync();
      expect(
        widgetSource,
        isNot(contains('colorTreeSelectInputDisabledBorderDefault')),
      );
      final docs = File('docs/semi_tree_select.md').readAsStringSync();
      expect(docs, contains('74 = 74 FIELDS + 0 MOTION + 0 INTERNAL'));
      expect(docs, contains('1 死变量'));
      expect(
        docs,
        contains(r'$color-treeSelect_input_disabled-border-default:'),
      );
      expect(docs, contains('（上游未消费）'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.treeSelect, const SemiTreeSelectThemeData());
      expect(
        themes.copyWith(
          treeSelect: const SemiTreeSelectThemeData(widthTreeSelectArrow: 20),
        ),
        const SemiComponentThemes(
          treeSelect: SemiTreeSelectThemeData(widthTreeSelectArrow: 20),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('single: tap opens, pick notifies onSelect/onChange and '
        'closes; re-pick fires onSelect 恒 true but no onChange', (
      tester,
    ) async {
      final events = <String>[];
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          placeholder: '请选择',
          onSelect: (key, selected, node) => events.add('select:$key:$selected'),
          onChange: (value) => events.add('change:$value'),
          onVisibleChange: (open) => events.add('visible:$open'),
        ),
      );
      expect(find.text('请选择'), findsOneWidget);
      await tester.tap(find.text('请选择'));
      await tester.pumpAndSettle();
      expect(events, ['visible:true']);
      // 展开 A 后点 B 行。
      await tester.tap(expandArrow('a'));
      await tester.pumpAndSettle();
      await tester.tap(rowText('B'));
      await tester.pumpAndSettle();
      expect(events, [
        'visible:true',
        'select:b:true',
        'change:b',
        'visible:false',
      ]);
      expect(find.text('B'), findsOneWidget); // trigger 回填
      // Re-open and re-pick the same row.（收起时 clearInput 已把选中项祖先
      // 补进展开集——A 默认展开，无需再点箭头。）
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      await tester.tap(rowText('B'));
      await tester.pumpAndSettle();
      // ★已选中再点：仍发 onSelect 恒 true、不发 onChange；clickToHide 照常收起。
      expect(events.where((e) => e.startsWith('change:')), hasLength(1));
      expect(events.where((e) => e == 'select:b:true'), hasLength(2));
    });

    testWidgets('multiple related cascade, autoMergeValue/leafOnly payloads', (
      tester,
    ) async {
      Object? last;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          multiple: true,
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      // Expand A then check B → A half.
      await tester.tap(expandArrow('a'));
      await tester.pumpAndSettle();
      await tester.tap(rowText('B'));
      await tester.pumpAndSettle();
      expect(last, ['b']);
      // Check A → cascade to B + C（disabled 亦被级联——非严格模式）。
      await tester.tap(rowText('A'));
      await tester.pumpAndSettle();
      expect(last, ['a']);
    });

    testWidgets('unRelated toggles independently; ★autoMergeValue=false + '
        'unRelated renders no tags（上游 quirk）', (tester) async {
      Object? last;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          multiple: true,
          checkRelation: SemiTreeCheckRelation.unRelated,
          autoMergeValue: false,
          motion: false,
          onChange: (value) => last = value,
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      await tester.tap(rowText('D'));
      await tester.pumpAndSettle();
      expect(last, ['d']);
      // triggerRenderKeys 取 [...checkedKeys]（unRelated 下恒空）→ 无标签。
      expect(find.byType(SemiTag), findsNothing);
    });

    testWidgets('tag close reverts the cascade and reports onSelect false', (
      tester,
    ) async {
      final events = <String>[];
      Object? last;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          multiple: true,
          defaultValue: const ['b'],
          motion: false,
          onSelect: (key, selected, node) => events.add('select:$key:$selected'),
          onChange: (value) => last = value,
        ),
      );
      expect(find.text('B'), findsOneWidget); // tag
      // 标签关闭按钮 = 标签内唯一图标（SemiIcons.close）。
      await tester.tap(
        find.descendant(
          of: find.byType(SemiTag),
          matching: find.byType(SemiIcon),
        ),
      );
      await tester.pumpAndSettle();
      expect(last, <String>[]);
      expect(events, ['select:b:false']);
    });

    testWidgets('clear button replaces the arrow while open and resets value', (
      tester,
    ) async {
      Object? last;
      var cleared = 0;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          showClear: true,
          motion: false,
          defaultValue: 'b',
          onChange: (value) => last = value,
          onClear: () => cleared++,
        ),
      );
      expect(find.text('B'), findsOneWidget);
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiTreeSelect.clearButtonKey), findsOneWidget);
      await tester.tap(find.byKey(SemiTreeSelect.clearButtonKey));
      await tester.pumpAndSettle();
      expect(last, isNull);
      expect(cleared, 1);
    });

    testWidgets('filter expands ancestors, highlights and reports filtered '
        'nodes; showFilteredOnly prunes', (tester) async {
      final searches = <String>[];
      List<SemiTreeNodeData>? nodes;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          filterTreeNode: true,
          showFilteredOnly: true,
          onSearch: (input, keys, filtered) {
            searches.add(input);
            nodes = filtered;
          },
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(SemiTreeSelect.searchInputKey),
        'b',
      );
      await tester.pumpAndSettle();
      expect(searches, ['b']);
      expect(nodes!.map((e) => e.key), ['b']);
      // showFilteredOnly：只留命中 + 祖先。
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('D'), findsNothing);
    });

    testWidgets('remote skips local filtering and reports empty filter keys', (
      tester,
    ) async {
      final searches = <(String, int)>[];
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          remote: true,
          filterTreeNode: true,
          onSearch: (input, keys, nodes) => searches.add((input, keys.length)),
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(SemiTreeSelect.searchInputKey),
        'x',
      );
      await tester.pumpAndSettle();
      expect(searches, [('x', 0)]);
      // 本地列表未被过滤。
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('trigger search (single) overlays the item and filters', (
      tester,
    ) async {
      Object? last;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          filterTreeNode: true,
          searchPosition: SemiTreeSelectSearchPosition.trigger,
          placeholder: '请选择',
          onChange: (value) => last = value,
        ),
      );
      expect(find.text('请选择'), findsOneWidget);
      await tester.tap(find.text('请选择'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SemiInput), 'b');
      await tester.pumpAndSettle();
      await tester.tap(rowText('B'));
      await tester.pumpAndSettle();
      expect(last, 'b');
    });

    testWidgets('controlled value only notifies; controlled expandedKeys '
        'only notifies', (tester) async {
      Object? last;
      final expands = <String>[];
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          value: 'd',
          expandedKeys: const [],
          motion: false,
          onChange: (value) => last = value,
          onExpand: (keys, expanded, node) => expands.add(node.key),
        ),
      );
      expect(find.text('D'), findsOneWidget); // trigger 回填
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      // 点未选中的 A 行：onChange('a') 照发；★已选中再点不发 onChange（上游同）。
      await tester.tap(rowText('A'));
      await tester.pumpAndSettle();
      expect(last, 'a'); // 回调照发
      expect(find.text('D'), findsOneWidget); // 受控不改显示
      // 受控展开：重开面板后 A 的箭头只回调、不改展开态。
      await tester.tap(find.text('D'));
      await tester.pumpAndSettle();
      await tester.tap(expandArrow('a'));
      await tester.pumpAndSettle();
      expect(expands, ['a']);
      expect(find.text('B'), findsNothing);
    });

    testWidgets('disabled blocks the trigger and disabled rows only notify '
        'onSelect nothing; expand still works (quirk)', (tester) async {
      var changes = 0;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          disabled: true,
          motion: false,
          onChange: (_) => changes++,
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('B'), findsNothing); // 面板未开
      expect(changes, 0);
    });

    testWidgets('loadData shows the spin and reports onLoad', (tester) async {
      final loaded = <String>[];
      final gate = Completer<void>();
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: const [
            SemiTreeNodeData(key: 'p', label: 'P'),
          ],
          motion: false,
          loadData: (_) => gate.future,
          onLoad: (keys, node) => loaded.add(node.key),
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      await tester.tap(expandArrow('p'));
      // 弹层内容更新走 SemiTooltip post-frame（一帧延迟）——双 pump 后 Spin 上屏
      //（Spin 自带循环动画，不能 pumpAndSettle）。
      await tester.pump();
      await tester.pump();
      expect(find.byType(SemiSpin), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(loaded, ['p']);
    });

    testWidgets('expandAction click/doubleClick drive expand', (tester) async {
      var expands = 0;
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          expandAction: SemiTreeExpandAction.click,
          onExpand: (_, _, _) => expands++,
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      await tester.tap(rowText('A'));
      await tester.pumpAndSettle();
      expect(expands, 1);
      expect(rowText('B'), findsOneWidget);

      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          expandAction: SemiTreeExpandAction.doubleClick,
          onExpand: (_, _, _) => expands++,
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      await tester.tap(rowText('A'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(expands, 1); // 单击只选择
      final center = tester.getCenter(rowText('A'));
      await tester.tapAt(center);
      await tester.tapAt(center);
      await tester.pumpAndSettle();
      expect(expands, 2); // 双击展开
    });

    testWidgets('empty state honors emptyContent and locale default', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTreeSelect(treeData: [], motion: false),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiTreeSelect.emptyKey), findsOneWidget);
      expect(find.text('暂无数据'), findsOneWidget);

      await pumpHost(
        tester,
        const SemiTreeSelect(
          treeData: [],
          motion: false,
          emptyContent: '空空如也',
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      expect(find.text('空空如也'), findsOneWidget);
    });

    testWidgets('maxTagCount folds the rest into "+N" with a tooltip', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          multiple: true,
          motion: false,
          maxTagCount: 1,
          showRestTagsPopover: true,
          defaultValue: const ['b', 'd'],
        ),
      );
      expect(find.text('B'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text('+1')));
      await tester.pumpAndSettle();
      expect(find.text('D'), findsOneWidget); // tooltip 列出折叠标签
    });

    testWidgets('sizes map to the trigger min-heights', (tester) async {
      for (final (size, height) in [
        (SemiInputSize.small, 24.0),
        (SemiInputSize.normal, 32.0),
        (SemiInputSize.large, 40.0),
      ]) {
        await pumpHost(
          tester,
          SemiTreeSelect(
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
      BoxDecoration decoration(WidgetTester tester) => tester
          .widget<DecoratedBox>(
            find
                .ancestor(of: find.text('x'), matching: find.byType(DecoratedBox))
                .first,
          )
          .decoration as BoxDecoration;

      await pumpHost(
        tester,
        const SemiTreeSelect(
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
        const SemiTreeSelect(
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
        SemiTreeSelect(
          treeData: data,
          motion: false,
          onVisibleChange: (open) => events.add('visible:$open'),
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      expect(rowText('D'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(SemiTreeSelect.listKey), findsNothing);
      expect(events, ['visible:true', 'visible:false']);
    });

    testWidgets('defaultOpen mounts the panel open', (tester) async {
      await pumpHost(
        tester,
        const SemiTreeSelect(
          treeData: data,
          motion: false,
          defaultOpen: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(rowText('D'), findsOneWidget);
    });

    testWidgets('custom searchRender replaces the search input', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiTreeSelect(
          treeData: data,
          motion: false,
          filterTreeNode: true,
          searchRender: (props) => Text('custom-${props.placeholder}'),
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      expect(find.text('custom-搜索'), findsOneWidget);
      expect(find.byKey(SemiTreeSelect.searchInputKey), findsNothing);
    });

    testWidgets('searchRender false hides the search input', (tester) async {
      await pumpHost(
        tester,
        const SemiTreeSelect(
          treeData: data,
          motion: false,
          filterTreeNode: true,
          searchRender: false,
        ),
      );
      await tester.tap(find.byType(SemiTreeSelect));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiTreeSelect.searchInputKey), findsNothing);
    });
  });
}
