// Behavior matrix for SemiInput / SemiTextArea plus coverage for the
// 94 generated theme fields (85 FIELDS + 9 motion) and the
// 97 = 94 themed + 3 INTERNAL accounting (the 3 INTERNAL provenance anchors
// live in the widget's `_InputMetrics`).
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 240,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: direction,
    child: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

BoxDecoration wrapperDecoration(WidgetTester tester, {bool textarea = false}) =>
    tester
            .widget<DecoratedBox>(
              find.byKey(
                textarea ? SemiTextArea.wrapperKey : SemiInput.wrapperKey,
              ),
            )
            .decoration
        as BoxDecoration;

String shownText(WidgetTester tester, {int index = 0}) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .toList()[index]
    .controller
    .text;

bool hasFocus(WidgetTester tester, {int index = 0}) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .toList()[index]
    .focusNode
    .hasFocus;

Finder iconFinder(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

typedef _Patch = SemiInputThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedInputThemeData data);

final List<(String, Object, _Patch, _Read)> fields = [
  (
    r'$color-input_default-border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiInputThemeData(colorInputDefaultBorderDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBorderDefault,
  ),
  (
    r'$color-input_default-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBgDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBgDefault,
  ),
  (
    r'$color-input_default-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultTextDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultTextDefault,
  ),
  (
    r'$color-input_default-bg-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBgHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBgHover,
  ),
  (
    r'$color-input_default-border-hover: transparent',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBorderHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBorderHover,
  ),
  (
    r'$color-input_default-bg-active: var(--semi-color-fill-2)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBgActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBgActive,
  ),
  (
    r'$color-input_default-border-active: $color-input_default-bg-active',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBorderActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBorderActive,
  ),
  (
    r'$color-input_default-bg-focus: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBgFocus: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBgFocus,
  ),
  (
    r'$color-input_default-border-focus: var(--semi-color-focus-border)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBorderFocus: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBorderFocus,
  ),
  (
    r'$color-input_icon-outline: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputIconOutline: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputIconOutline,
  ),
  (
    r'$color-input_default-bg-focus-hover: $color-input_default-bg-focus',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDefaultBgFocusHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBgFocusHover,
  ),
  (
    r'$color-input_danger-bg-default: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBgDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBgDefault,
  ),
  (
    r'$color-input_danger-border-default: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBorderDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBorderDefault,
  ),
  (
    r'$color-input_danger-bg-hover: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBgHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBgHover,
  ),
  (
    r'$color-input_danger-border-hover: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBorderHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBorderHover,
  ),
  (
    r'$color-input_danger-bg-focus: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBgFocus: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBgFocus,
  ),
  (
    r'$color-input_danger-border-focus: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBorderFocus: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBorderFocus,
  ),
  (
    r'$color-input_danger-bg-active: var(--semi-color-danger-light-active)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBgActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBgActive,
  ),
  (
    r'$color-input_danger-border-active: var(--semi-color-danger-light-active)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDangerBorderActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDangerBorderActive,
  ),
  (
    r'$color-input_warning-bg-default: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBgDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBgDefault,
  ),
  (
    r'$color-input_warning-border-default: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiInputThemeData(colorInputWarningBorderDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBorderDefault,
  ),
  (
    r'$color-input_warning-bg-hover: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBgHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBgHover,
  ),
  (
    r'$color-input_warning-border-hover: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBorderHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBorderHover,
  ),
  (
    r'$color-input_warning-bg-focus: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBgFocus: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBgFocus,
  ),
  (
    r'$color-input_warning-border-focus: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBorderFocus: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBorderFocus,
  ),
  (
    r'$color-input_warning-bg-active: var(--semi-color-warning-light-active)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBgActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBgActive,
  ),
  (
    r'$color-input_warning-border-active: var(--semi-color-warning-light-active)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputWarningBorderActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputWarningBorderActive,
  ),
  (
    r'$color-input_disabled-border-default: var(--semi-color-disabled-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiInputThemeData(colorInputDisabledBorderDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDisabledBorderDefault,
  ),
  (
    r'$color-input_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDisabledBgDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDisabledBgDefault,
  ),
  (
    r'$color-input_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputDisabledTextDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDisabledTextDefault,
  ),
  (
    r'$color-input_placeholder-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiInputThemeData(colorInputPlaceholderTextDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputPlaceholderTextDefault,
  ),
  (
    r'$color-input_prefix-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputPrefixTextDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputPrefixTextDefault,
  ),
  (
    r'$color-input-icon-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputIconDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputIconDefault,
  ),
  (
    r'$color-input-icon-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputIconHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputIconHover,
  ),
  (
    r'$color-input-icon-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputIconActive: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputIconActive,
  ),
  (
    r'$color-input_counter-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputCounterTextDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputCounterTextDefault,
  ),
  (
    r'$color-input_counter_danger-text-default: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) =>
        SemiInputThemeData(colorInputCounterDangerTextDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputCounterDangerTextDefault,
  ),
  (
    r'$color-input_group-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorInputGroupBorderDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputGroupBorderDefault,
  ),
  (
    r'$color_input-default-border-only_border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(
      colorInputDefaultBorderOnlyBorderDefault: v as Color,
    ),
    (SemiResolvedInputThemeData d) =>
        d.colorInputDefaultBorderOnlyBorderDefault,
  ),
  (
    r'$color_input-default-border-only_border-hover: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiInputThemeData(colorInputDefaultBorderOnlyBorderHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorInputDefaultBorderOnlyBorderHover,
  ),
  (
    r'$color-textarea-border-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorTextareaBorderDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorTextareaBorderDefault,
  ),
  (
    r'$color-textarea-border-hover: $color-textarea-border-default',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorTextareaBorderHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorTextareaBorderHover,
  ),
  (
    r'$color-textarea-icon-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorTextareaIconDefault: v as Color),
    (SemiResolvedInputThemeData d) => d.colorTextareaIconDefault,
  ),
  (
    r'$color-textarea-icon-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiInputThemeData(colorTextareaIconHover: v as Color),
    (SemiResolvedInputThemeData d) => d.colorTextareaIconHover,
  ),
  (
    r'$height-input_large: $height-control-large - 2px',
    4.5,
    (Object v) => SemiInputThemeData(heightInputLarge: v as double),
    (SemiResolvedInputThemeData d) => d.heightInputLarge,
  ),
  (
    r'$height-input_small: $height-control-small - 2px',
    4.5,
    (Object v) => SemiInputThemeData(heightInputSmall: v as double),
    (SemiResolvedInputThemeData d) => d.heightInputSmall,
  ),
  (
    r'$height-input_default: $height-control-default - 2px',
    4.5,
    (Object v) => SemiInputThemeData(heightInputDefault: v as double),
    (SemiResolvedInputThemeData d) => d.heightInputDefault,
  ),
  (
    r'$height-input_wrapper_large: $height-control-large',
    4.5,
    (Object v) => SemiInputThemeData(heightInputWrapperLarge: v as double),
    (SemiResolvedInputThemeData d) => d.heightInputWrapperLarge,
  ),
  (
    r'$height-input_wrapper_small: $height-control-small',
    4.5,
    (Object v) => SemiInputThemeData(heightInputWrapperSmall: v as double),
    (SemiResolvedInputThemeData d) => d.heightInputWrapperSmall,
  ),
  (
    r'$height-input_wrapper_default: $height-control-default',
    4.5,
    (Object v) => SemiInputThemeData(heightInputWrapperDefault: v as double),
    (SemiResolvedInputThemeData d) => d.heightInputWrapperDefault,
  ),
  (
    r'$height-textarea_counter: 24px',
    4.5,
    (Object v) => SemiInputThemeData(heightTextareaCounter: v as double),
    (SemiResolvedInputThemeData d) => d.heightTextareaCounter,
  ),
  (
    r'$height-textarea-default: 32px',
    4.5,
    (Object v) => SemiInputThemeData(heightTextareaDefault: v as double),
    (SemiResolvedInputThemeData d) => d.heightTextareaDefault,
  ),
  (
    r'$width-input-icon: $width-icon-medium + $spacing-tight * 2',
    4.5,
    (Object v) => SemiInputThemeData(widthInputIcon: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputIcon,
  ),
  (
    r'$width-input-icon_clear_before_suffix: $width-icon-medium + $spacing-tight',
    4.5,
    (Object v) =>
        SemiInputThemeData(widthInputIconClearBeforeSuffix: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputIconClearBeforeSuffix,
  ),
  (
    r'$width-input-icon_clear_before_modebtn: $width-icon-medium',
    4.5,
    (Object v) =>
        SemiInputThemeData(widthInputIconClearBeforeModebtn: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputIconClearBeforeModebtn,
  ),
  (
    r'$width-input_append-border: $border-thickness-control',
    4.5,
    (Object v) => SemiInputThemeData(widthInputAppendBorder: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputAppendBorder,
  ),
  (
    r'$width-input_prepend-border: $border-thickness-control',
    4.5,
    (Object v) => SemiInputThemeData(widthInputPrependBorder: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputPrependBorder,
  ),
  (
    r'$width-input_group_pseudo-border: $border-thickness-control',
    4.5,
    (Object v) => SemiInputThemeData(widthInputGroupPseudoBorder: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputGroupPseudoBorder,
  ),
  (
    r'$width-input_wrapper-border: $border-thickness-control-focus',
    4.5,
    (Object v) => SemiInputThemeData(widthInputWrapperBorder: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputWrapperBorder,
  ),
  (
    r'$width-input_wrapper_focus-border: $border-thickness-control-focus',
    4.5,
    (Object v) => SemiInputThemeData(widthInputWrapperFocusBorder: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputWrapperFocusBorder,
  ),
  (
    r'$width-input_icon-outline: 2px',
    4.5,
    (Object v) => SemiInputThemeData(widthInputIconOutline: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputIconOutline,
  ),
  (
    r'$width-input_icon-outlineOffset: -1px',
    4.5,
    (Object v) => SemiInputThemeData(widthInputIconOutlineOffset: v as double),
    (SemiResolvedInputThemeData d) => d.widthInputIconOutlineOffset,
  ),
  (
    r'$width-textarea-border: $border-thickness',
    4.5,
    (Object v) => SemiInputThemeData(widthTextareaBorder: v as double),
    (SemiResolvedInputThemeData d) => d.widthTextareaBorder,
  ),
  (
    r'$width-textarea-icon: $width-icon-medium + $spacing-tight',
    4.5,
    (Object v) => SemiInputThemeData(widthTextareaIcon: v as double),
    (SemiResolvedInputThemeData d) => d.widthTextareaIcon,
  ),
  (
    r'$spacing-input_icon-marginLeft: -$spacing-base-tight',
    const EdgeInsetsDirectional.only(start: -3),
    (Object v) => SemiInputThemeData(
      spacingInputIconMarginLeft: v as EdgeInsetsDirectional,
    ),
    (SemiResolvedInputThemeData d) => d.spacingInputIconMarginLeft,
  ),
  (
    r'$spacing-input-paddingLeft: $spacing-base-tight',
    4.5,
    (Object v) => SemiInputThemeData(spacingInputPaddingLeft: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPaddingLeft,
  ),
  (
    r'$spacing-input-paddingRight: $spacing-base-tight',
    4.5,
    (Object v) => SemiInputThemeData(spacingInputPaddingRight: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPaddingRight,
  ),
  (
    r'$spacing-input_prefix_suffix-marginX: $spacing-base-tight',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingInputPrefixSuffixMarginX: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPrefixSuffixMarginX,
  ),
  (
    r'$spacing-input_prefix_icon-marginY: 0',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingInputPrefixIconMarginY: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPrefixIconMarginY,
  ),
  (
    r'$spacing-input_prefix_icon-marginX: $spacing-tight',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingInputPrefixIconMarginX: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPrefixIconMarginX,
  ),
  (
    r'$spacing-input_clearBtn_withSuffix-marginLeft: -$spacing-base-tight',
    const EdgeInsetsDirectional.only(start: -3),
    (Object v) => SemiInputThemeData(
      spacingInputClearBtnWithSuffixMarginLeft: v as EdgeInsetsDirectional,
    ),
    (SemiResolvedInputThemeData d) =>
        d.spacingInputClearBtnWithSuffixMarginLeft,
  ),
  (
    r'$spacing-input_prepend-paddingY: 0',
    4.5,
    (Object v) => SemiInputThemeData(spacingInputPrependPaddingY: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPrependPaddingY,
  ),
  (
    r'$spacing-input_prepend-paddingX: $spacing-base-tight',
    4.5,
    (Object v) => SemiInputThemeData(spacingInputPrependPaddingX: v as double),
    (SemiResolvedInputThemeData d) => d.spacingInputPrependPaddingX,
  ),
  (
    r'$spacing-textarea-paddingY: 5px',
    4.5,
    (Object v) => SemiInputThemeData(spacingTextareaPaddingY: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaPaddingY,
  ),
  (
    r'$spacing-textarea-paddingX: $spacing-base-tight',
    4.5,
    (Object v) => SemiInputThemeData(spacingTextareaPaddingX: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaPaddingX,
  ),
  (
    r'$spacing-textarea_counter-paddingTop: 3px',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingTextareaCounterPaddingTop: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaCounterPaddingTop,
  ),
  (
    r'$spacing-textarea_counter-paddingRight: 12px',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingTextareaCounterPaddingRight: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaCounterPaddingRight,
  ),
  (
    r'$spacing-textarea_counter-paddingBottom: 5px',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingTextareaCounterPaddingBottom: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaCounterPaddingBottom,
  ),
  (
    r'$spacing-textarea_counter-paddingLeft: 12px',
    4.5,
    (Object v) =>
        SemiInputThemeData(spacingTextareaCounterPaddingLeft: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaCounterPaddingLeft,
  ),
  (
    r'$spacing-textarea_withShowClear-paddingRight: 36px',
    4.5,
    (Object v) => SemiInputThemeData(
      spacingTextareaWithShowClearPaddingRight: v as double,
    ),
    (SemiResolvedInputThemeData d) =>
        d.spacingTextareaWithShowClearPaddingRight,
  ),
  (
    r'$spacing-textarea-icon-right: $spacing-extra-tight',
    4.5,
    (Object v) => SemiInputThemeData(spacingTextareaIconRight: v as double),
    (SemiResolvedInputThemeData d) => d.spacingTextareaIconRight,
  ),
  (
    r'$font-input_prefix_suffix-fontWeight: $font-weight-bold',
    FontWeight.w700,
    (Object v) =>
        SemiInputThemeData(fontInputPrefixSuffixFontWeight: v as FontWeight),
    (SemiResolvedInputThemeData d) => d.fontInputPrefixSuffixFontWeight,
  ),
  (
    r'$radius-input_wrapper: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiInputThemeData(radiusInputWrapper: v as double),
    (SemiResolvedInputThemeData d) => d.radiusInputWrapper,
  ),
  (
    r'$motion-scale_size-active: .97',
    4.5,
    (Object v) => SemiInputThemeData(motionScaleSizeActive: v as double),
    (SemiResolvedInputThemeData d) => d.motionScaleSizeActive,
  ),
  (
    r'$motion-scale_size-inactive: 1',
    4.5,
    (Object v) => SemiInputThemeData(motionScaleSizeInactive: v as double),
    (SemiResolvedInputThemeData d) => d.motionScaleSizeInactive,
  ),
  (
    r'$transition_duration-input-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiInputThemeData(transitionDurationInputBg: v as Duration),
    (SemiResolvedInputThemeData d) => d.transitionDurationInputBg,
  ),
  (
    r'$transition_function-input-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiInputThemeData(transitionFunctionInputBg: v as Curve),
    (SemiResolvedInputThemeData d) => d.transitionFunctionInputBg,
  ),
  (
    r'$transition_delay-input-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiInputThemeData(transitionDelayInputBg: v as Duration),
    (SemiResolvedInputThemeData d) => d.transitionDelayInputBg,
  ),
  (
    r'$transition_duration-input-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiInputThemeData(transitionDurationInputBorder: v as Duration),
    (SemiResolvedInputThemeData d) => d.transitionDurationInputBorder,
  ),
  (
    r'$transition_function-input-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiInputThemeData(transitionFunctionInputBorder: v as Curve),
    (SemiResolvedInputThemeData d) => d.transitionFunctionInputBorder,
  ),
  (
    r'$transition_delay-input-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiInputThemeData(transitionDelayInputBorder: v as Duration),
    (SemiResolvedInputThemeData d) => d.transitionDelayInputBorder,
  ),
  (
    r'$transition_duration-input-text: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiInputThemeData(transitionDurationInputText: v as Duration),
    (SemiResolvedInputThemeData d) => d.transitionDurationInputText,
  ),
  (
    r'$transition_function-input-text: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiInputThemeData(transitionFunctionInputText: v as Curve),
    (SemiResolvedInputThemeData d) => d.transitionFunctionInputText,
  ),
  (
    r'$transition_delay-input-text: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiInputThemeData(transitionDelayInputText: v as Duration),
    (SemiResolvedInputThemeData d) => d.transitionDelayInputText,
  ),
];

SemiResolvedInputThemeData resolved() =>
    const SemiInputThemeData().resolve(const SemiThemeData.light());

void main() {
  group('controlled and uncontrolled', () {
    testWidgets('uncontrolled: initialValue, edits land and notify', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(SemiInput(initialValue: 'hi', onChanged: log.add)),
      );
      expect(shownText(tester), 'hi');
      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pump();
      expect(shownText(tester), 'hello');
      expect(log, ['hello']);
    });

    testWidgets('controlled: value drives rendering, edits only notify', (
      tester,
    ) async {
      final log = <String>[];
      Widget build() => host(SemiInput(value: 'a', onChanged: log.add));
      await tester.pumpWidget(build());
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(log, ['abc']);
      // The parent rebuilds without accepting the edit: strict reconciliation
      // restores the controlled value (the approved `value != controller.text`
      // rule).
      await tester.pumpWidget(build());
      await tester.pump();
      expect(shownText(tester), 'a');
    });

    testWidgets('controlled sync never clobbers an IME composition', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'old');
      await tester.pumpWidget(
        host(SemiInput(value: 'old', controller: controller)),
      );
      // Simulate pinyin composition in progress.
      controller.value = const TextEditingValue(
        text: 'pinyin',
        composing: TextRange(start: 0, end: 6),
      );
      await tester.pump();
      await tester.pumpWidget(
        host(SemiInput(value: 'new', controller: controller)),
      );
      await tester.pump();
      expect(controller.text, 'pinyin');
      // Composition ends: the next reconcile syncs.
      controller.value = const TextEditingValue(text: 'pinyin');
      await tester.pumpWidget(
        host(SemiInput(value: 'new', controller: controller)),
      );
      await tester.pump();
      expect(controller.text, 'new');
    });

    testWidgets('releasing control retains the value; entering control syncs', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiInput(value: 'x')));
      expect(shownText(tester), 'x');
      await tester.pumpWidget(host(const SemiInput()));
      await tester.pump();
      expect(shownText(tester), 'x');
      await tester.enterText(find.byType(EditableText), 'typed');
      await tester.pump();
      expect(shownText(tester), 'typed');
      await tester.pumpWidget(host(const SemiInput(value: 'synced')));
      await tester.pump();
      expect(shownText(tester), 'synced');
    });

    testWidgets('textarea mirrors the same value conventions', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(SemiTextArea(initialValue: 'hi', onChanged: log.add)),
      );
      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pump();
      expect(shownText(tester), 'hello');
      expect(log, ['hello']);
      await tester.pumpWidget(host(const SemiTextArea(value: 'controlled')));
      await tester.pump();
      expect(shownText(tester), 'controlled');
    });
  });

  group('password mode', () {
    testWidgets('eye button toggles obscureText and preserves selection', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'secret');
      await tester.pumpWidget(
        host(SemiInput(mode: SemiInputMode.password, controller: controller)),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
      expect(iconFinder(SemiIcons.eyeClosedSolid), findsOneWidget);
      expect(iconFinder(SemiIcons.eyeOpened), findsNothing);
      controller.selection = const TextSelection.collapsed(offset: 3);
      await tester.pump();
      await tester.tap(find.byKey(SemiInput.modeButtonKey));
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      expect(iconFinder(SemiIcons.eyeOpened), findsOneWidget);
      expect(controller.selection.baseOffset, 3);
    });

    testWidgets('Enter and Space activate the eye button', (tester) async {
      final controller = TextEditingController(text: 'secret');
      await tester.pumpWidget(
        host(SemiInput(mode: SemiInputMode.password, controller: controller)),
      );
      Focus.of(tester.element(find.byKey(SemiInput.modeButtonKey)))
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      // Upstream handleClickEye refocuses the input: re-focus the button.
      Focus.of(tester.element(find.byKey(SemiInput.modeButtonKey)))
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
    });

    testWidgets('eye button hides when disabled and shows otherwise', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiInput(mode: SemiInputMode.password, disabled: true)),
      );
      expect(find.byKey(SemiInput.modeButtonKey), findsNothing);
      await tester.pumpWidget(
        host(const SemiInput(mode: SemiInputMode.password)),
      );
      expect(find.byKey(SemiInput.modeButtonKey), findsOneWidget);
      await tester.pumpWidget(host(const SemiInput()));
      expect(find.byKey(SemiInput.modeButtonKey), findsNothing);
    });
  });

  group('clear button', () {
    testWidgets('visibility: text + focus/hover, hidden readonly/disabled', (
      tester,
    ) async {
      final mouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pumpWidget(
        host(const SemiInput(showClear: true, initialValue: 'abc')),
      );
      expect(find.byKey(SemiInput.clearButtonKey), findsNothing);
      await mouse.moveTo(tester.getCenter(find.byKey(SemiInput.wrapperKey)));
      await tester.pump();
      expect(find.byKey(SemiInput.clearButtonKey), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(find.byKey(SemiInput.clearButtonKey), findsNothing);
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(find.byKey(SemiInput.clearButtonKey), findsOneWidget);
      await tester.pumpWidget(
        host(
          const SemiInput(showClear: true, initialValue: 'abc', readonly: true),
        ),
      );
      await tester.pump();
      expect(find.byKey(SemiInput.clearButtonKey), findsNothing);
      await tester.pumpWidget(
        host(
          const SemiInput(showClear: true, initialValue: 'abc', disabled: true),
        ),
      );
      await tester.pump();
      expect(find.byKey(SemiInput.clearButtonKey), findsNothing);
    });

    testWidgets('uncontrolled clear lands, notifies and keeps focus', (
      tester,
    ) async {
      final log = <String>[];
      var cleared = 0;
      await tester.pumpWidget(
        host(
          SemiInput(
            showClear: true,
            initialValue: 'abc',
            onChanged: log.add,
            onClear: () => cleared += 1,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.tap(find.byKey(SemiInput.clearButtonKey));
      await tester.pump();
      expect(shownText(tester), '');
      expect(log, ['']);
      expect(cleared, 1);
      expect(hasFocus(tester), isTrue);
    });

    testWidgets('controlled clear only notifies onChanged + onClear', (
      tester,
    ) async {
      final log = <String>[];
      var cleared = 0;
      await tester.pumpWidget(
        host(
          SemiInput(
            showClear: true,
            value: 'abc',
            onChanged: log.add,
            onClear: () => cleared += 1,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.tap(find.byKey(SemiInput.clearButtonKey));
      await tester.pump();
      expect(log, ['']);
      expect(cleared, 1);
      // The parent owns the value: the display is untouched.
      expect(shownText(tester), 'abc');
    });

    testWidgets('hideSuffix hides the suffix; clear+suffix coexistence '
        'applies the -12 slot inset', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiInput(
            showClear: true,
            hideSuffix: true,
            initialValue: 'abc',
            suffix: Text('S'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(find.text('S'), findsNothing);
      // Suffix hidden: no coexistence inset, the plain 32px slot applies.
      expect(tester.getSize(find.byKey(SemiInput.clearButtonKey)).width, 32);
      await tester.pumpWidget(
        host(
          const SemiInput(
            showClear: true,
            initialValue: 'abc',
            suffix: Text('S'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(find.text('S'), findsOneWidget);
      // 32 - 12 (`margin-left: -$spacing-base-tight` semantics).
      expect(tester.getSize(find.byKey(SemiInput.clearButtonKey)).width, 20);
    });

    testWidgets('textarea clear mirrors the input semantics', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(
          SemiTextArea(
            showClear: true,
            initialValue: 'abc',
            onChanged: log.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(find.byKey(SemiTextArea.clearButtonKey), findsOneWidget);
      await tester.tap(find.byKey(SemiTextArea.clearButtonKey));
      await tester.pump();
      expect(shownText(tester), '');
      expect(log, ['']);
    });
  });

  group('maxLength', () {
    testWidgets('code-unit truncation and maxLength 0', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(SemiInput(maxLength: 3, onChanged: log.add)),
      );
      await tester.enterText(find.byType(EditableText), 'abcdef');
      await tester.pump();
      expect(shownText(tester), 'abc');
      expect(log, ['abc']);
      final zeroLog = <String>[];
      await tester.pumpWidget(
        host(SemiInput(maxLength: 0, onChanged: zeroLog.add)),
      );
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(shownText(tester), '');
      expect(zeroLog, ['']);
    });

    testWidgets('blur re-check truncates pinyin residue', (tester) async {
      final log = <String>[];
      final controller = TextEditingController();
      await tester.pumpWidget(
        host(
          Column(
            children: [
              SemiInput(
                maxLength: 2,
                controller: controller,
                onChanged: log.add,
              ),
              const SemiInput(),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      await tester.pump();
      // Simulate composition residue that bypassed the formatter.
      controller.value = const TextEditingValue(text: '拼音残留');
      await tester.pump();
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(controller.text, '拼音');
      expect(log, ['拼音']);
    });

    testWidgets('textarea maxLength truncates too', (tester) async {
      await tester.pumpWidget(host(const SemiTextArea(maxLength: 3)));
      await tester.enterText(find.byType(EditableText), 'abcdef');
      await tester.pump();
      expect(shownText(tester), 'abc');
    });
  });

  group('validateStatus visuals and semantics', () {
    testWidgets('error and warning matrices plus focus borders', (
      tester,
    ) async {
      final t = resolved();
      await tester.pumpWidget(
        host(const SemiInput(validateStatus: SemiInputStatus.error)),
      );
      await tester.pumpWidget(
        host(const SemiInput(validateStatus: SemiInputStatus.warning)),
      );
      var deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputWarningBgDefault);
      expect(deco.border!.top.color, t.colorInputWarningBorderDefault);
      await tester.pumpWidget(
        host(const SemiInput(validateStatus: SemiInputStatus.error)),
      );
      deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputDangerBgDefault);
      expect(deco.border!.top.color, t.colorInputDangerBorderDefault);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputDangerBgFocus);
      expect(deco.border!.top.color, t.colorInputDangerBorderFocus);
      await tester.pumpWidget(
        host(const SemiInput(validateStatus: SemiInputStatus.warning)),
      );
      await tester.pump();
      // Focus persists across updates: the warning border is the focused one.
      deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputWarningBgFocus);
      expect(deco.border!.top.color, t.colorInputWarningBorderFocus);
      await tester.pumpWidget(host(const SemiInput()));
      await tester.pump();
      deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputDefaultBgDefault);
    });

    testWidgets('borderless drops the fill but error/warning keep the border', (
      tester,
    ) async {
      final t = resolved();
      await tester.pumpWidget(host(const SemiInput(borderless: true)));
      var deco = wrapperDecoration(tester);
      expect(deco.color, const Color(0x00000000));
      expect(deco.border!.top.color, const Color(0x00000000));
      await tester.pumpWidget(
        host(
          const SemiInput(
            borderless: true,
            validateStatus: SemiInputStatus.error,
          ),
        ),
      );
      await tester.pump();
      deco = wrapperDecoration(tester);
      expect(deco.color, const Color(0x00000000));
      expect(deco.border!.top.color, t.colorInputDangerBorderFocus);
      await tester.pumpWidget(
        host(
          const SemiInput(
            borderless: true,
            validateStatus: SemiInputStatus.warning,
          ),
        ),
      );
      await tester.pump();
      deco = wrapperDecoration(tester);
      expect(deco.border!.top.color, t.colorInputWarningBorderFocus);
    });

    testWidgets('success has no dedicated visuals; semantics carry the '
        'validation result', (tester) async {
      final t = resolved();
      await tester.pumpWidget(
        host(
          const SemiInput(
            validateStatus: SemiInputStatus.success,
            semanticsLabel: 'name',
          ),
        ),
      );
      final deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputDefaultBgDefault);
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'name',
        ),
      );
      expect(semantics.properties.textField, isTrue);
      expect(
        semantics.properties.validationResult,
        SemanticsValidationResult.valid,
      );
      await tester.pumpWidget(
        host(
          const SemiInput(
            validateStatus: SemiInputStatus.error,
            semanticsLabel: 'name',
          ),
        ),
      );
      final errorSemantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'name',
        ),
      );
      expect(
        errorSemantics.properties.validationResult,
        SemanticsValidationResult.invalid,
      );
    });

    testWidgets('disabled fills with the disabled palette', (tester) async {
      final t = resolved();
      await tester.pumpWidget(
        host(
          const SemiInput(
            disabled: true,
            validateStatus: SemiInputStatus.error,
          ),
        ),
      );
      final deco = wrapperDecoration(tester);
      expect(deco.color, t.colorInputDisabledBgDefault);
      expect(deco.border!.top.color, t.colorInputDefaultBorderDefault);
    });
  });

  group('geometry', () {
    testWidgets('three sizes: wrapper 24/32/40, font 14/14/16, line 22', (
      tester,
    ) async {
      const cases = [
        (SemiInputSize.small, 24.0, 14.0),
        (SemiInputSize.normal, 32.0, 14.0),
        (SemiInputSize.large, 40.0, 16.0),
      ];
      for (final (size, height, fontSize) in cases) {
        await tester.pumpWidget(host(SemiInput(size: size)));
        expect(
          tester.getSize(find.byKey(SemiInput.wrapperKey)).height,
          height,
          reason: '$size',
        );
        final style = tester
            .widget<EditableText>(find.byType(EditableText))
            .style;
        expect(style.fontSize, fontSize, reason: '$size');
        expect(style.height! * fontSize, 22, reason: '$size');
      }
    });

    testWidgets('1px border and 3px radius at every state', (tester) async {
      final t = resolved();
      await tester.pumpWidget(host(const SemiInput()));
      final deco = wrapperDecoration(tester);
      expect(deco.border!.top.width, t.widthInputWrapperBorder);
      expect(deco.border!.top.width, 1);
      expect(
        (deco.borderRadius as BorderRadius).topLeft,
        Radius.circular(t.radiusInputWrapper),
      );
      expect(t.radiusInputWrapper, 3);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      // Focus keeps 1px: no layout shift.
      final focused = wrapperDecoration(tester);
      expect(focused.border!.top.width, t.widthInputWrapperFocusBorder);
      expect(focused.border!.top.width, 1);
    });
  });

  group('prefix, suffix, insetLabel and addons', () {
    testWidgets('slot order and insetLabel bold w600', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiInput(
            prefix: Text('P'),
            suffix: Text('S'),
            addonBefore: Text('B'),
            addonAfter: Text('A'),
          ),
        ),
      );
      final b = tester.getTopLeft(find.text('B')).dx;
      final p = tester.getTopLeft(find.text('P')).dx;
      final s = tester.getTopLeft(find.text('S')).dx;
      final a = tester.getTopLeft(find.text('A')).dx;
      expect(b, lessThan(p));
      expect(p, lessThan(s));
      expect(s, lessThan(a));
      await tester.pumpWidget(host(const SemiInput(insetLabel: 'L')));
      final label = tester.widget<Text>(find.text('L'));
      expect(label.style!.fontWeight, FontWeight.w600);
    });

    testWidgets('prefix and addon blocks carry the 1px inner borders', (
      tester,
    ) async {
      final t = resolved();
      await tester.pumpWidget(
        host(const SemiInput(addonBefore: Text('B'), addonAfter: Text('A'))),
      );
      final before = tester.widget<DecoratedBox>(
        find.ancestor(of: find.text('B'), matching: find.byType(DecoratedBox)),
      );
      final beforeDeco = before.decoration as BoxDecoration;
      expect(
        (beforeDeco.border as Border).right.width,
        t.widthInputPrependBorder,
      );
      expect((beforeDeco.border as Border).left, BorderSide.none);
      final after = tester.widget<DecoratedBox>(
        find.ancestor(of: find.text('A'), matching: find.byType(DecoratedBox)),
      );
      final afterDeco = after.decoration as BoxDecoration;
      expect((afterDeco.border as Border).left.width, t.widthInputAppendBorder);
      expect((afterDeco.border as Border).right, BorderSide.none);
    });

    testWidgets('tapping the prefix focuses the input', (tester) async {
      await tester.pumpWidget(host(const SemiInput(prefix: Text('P'))));
      expect(hasFocus(tester), isFalse);
      await tester.tap(find.text('P'));
      await tester.pump();
      expect(hasFocus(tester), isTrue);
    });
  });

  group('readonly, disabled and borderless interaction', () {
    testWidgets('disabled rejects focus and typing', (tester) async {
      await tester.pumpWidget(
        host(const SemiInput(disabled: true, initialValue: 'x')),
      );
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      expect(hasFocus(tester), isFalse);
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(shownText(tester), 'x');
    });

    testWidgets('readonly keeps the text uneditable', (tester) async {
      await tester.pumpWidget(
        host(const SemiInput(readonly: true, initialValue: 'x')),
      );
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(shownText(tester), 'x');
    });

    testWidgets('textarea readonly keeps the text uneditable', (tester) async {
      await tester.pumpWidget(
        host(const SemiTextArea(readonly: true, initialValue: 'x')),
      );
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(shownText(tester), 'x');
    });
  });

  group('enter, focus and blur', () {
    testWidgets('input onEnterPress rides the engine done action', (
      tester,
    ) async {
      var enters = 0;
      await tester.pumpWidget(host(SemiInput(onEnterPress: () => enters += 1)));
      await tester.enterText(find.byType(EditableText), 'x');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(enters, 1);
    });

    testWidgets('textarea Enter notifies and disabledEnterStartNewLine '
        'consumes plain Enter while Shift+Enter propagates', (tester) async {
      var enters = 0;
      final probed = <KeyEvent>[];
      await tester.pumpWidget(
        host(
          Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) probed.add(event);
              return KeyEventResult.ignored;
            },
            child: SemiTextArea(
              disabledEnterStartNewLine: true,
              onEnterPress: () => enters += 1,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(enters, 1);
      // Plain Enter is consumed by the textarea: the outer probe is silent.
      expect(probed, isEmpty);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(enters, 2);
      // Shift+Enter propagates (and the newline is inserted downstream).
      expect(probed, isNotEmpty);
    });

    testWidgets('onFocusChange and onBlur fire across inputs', (tester) async {
      final focusLog = <bool>[];
      var blurred = 0;
      await tester.pumpWidget(
        host(
          Column(
            children: [
              SemiInput(
                onFocusChange: focusLog.add,
                onBlur: () => blurred += 1,
              ),
              const SemiInput(),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      await tester.pump();
      expect(focusLog, [true]);
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(focusLog, [true, false]);
      expect(blurred, 1);
    });
  });

  group('textarea rows, autosize and counter', () {
    testWidgets('rows drives the fallback height', (tester) async {
      await tester.pumpWidget(host(const SemiTextArea()));
      // 4 rows * 22 line + 5/5 padding + 2 * 1px wrapper border.
      expect(tester.getSize(find.byKey(SemiTextArea.wrapperKey)).height, 100);
      await tester.pumpWidget(host(const SemiTextArea(rows: 2)));
      expect(tester.getSize(find.byKey(SemiTextArea.wrapperKey)).height, 56);
    });

    testWidgets('autosize grows with content and honors min/maxRows', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiTextArea(autosize: true)));
      // autosize keeps the rows floor (4 rows).
      expect(tester.getSize(find.byKey(SemiTextArea.wrapperKey)).height, 100);
      await tester.enterText(
        find.byType(EditableText),
        'a\nb\nc\nd\ne\nf\ng\nh',
      );
      await tester.pump();
      expect(tester.getSize(find.byKey(SemiTextArea.wrapperKey)).height, 188);
      await tester.pumpWidget(
        host(
          const SemiTextArea(
            autosize: SemiTextAreaAutosize(minRows: 1, maxRows: 2),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byKey(SemiTextArea.wrapperKey)).height, 56);
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(tester.getSize(find.byKey(SemiTextArea.wrapperKey)).height, 34);
    });

    testWidgets('counter formats current/total and turns danger past '
        'maxCount', (tester) async {
      final t = resolved();
      await tester.pumpWidget(host(const SemiTextArea(showCounter: true)));
      Text counterText(WidgetTester tester) => tester.widget<Text>(
        find.descendant(
          of: find.byKey(SemiTextArea.counterKey),
          matching: find.byType(Text),
        ),
      );
      expect(counterText(tester).data, '0');
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(counterText(tester).data, 'abc'.length.toString());
      expect(counterText(tester).style!.color, t.colorInputCounterTextDefault);
      await tester.pumpWidget(host(const SemiTextArea(maxCount: 5)));
      await tester.pump();
      expect(counterText(tester).data, '3/5');
      await tester.enterText(find.byType(EditableText), 'abcdef');
      await tester.pump();
      expect(counterText(tester).data, '6/5');
      expect(
        counterText(tester).style!.color,
        t.colorInputCounterDangerTextDefault,
      );
    });
  });

  group('RTL and text scaling', () {
    testWidgets('RTL mirrors the slots without overflow', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiInput(prefix: Text('P'), suffix: Text('S')),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
      // The prefix slot sits on the right side in RTL.
      expect(
        tester.getCenter(find.text('P')).dx,
        greaterThan(tester.getCenter(find.byKey(SemiInput.wrapperKey)).dx),
      );
      expect(
        tester.getCenter(find.text('S')).dx,
        lessThan(tester.getCenter(find.byKey(SemiInput.wrapperKey)).dx),
      );
    });

    testWidgets('text scaling keeps inputs and textareas overflow-free', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SemiInput(initialValue: '很长很长很长很长的输入内容'),
                      SizedBox(height: 8),
                      SemiTextArea(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('theme fields (85 + 9) and 97 accounting', () {
    test('94 fields: merge, copyWith, resolve, equality', () {
      expect(fields, hasLength(94));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(9),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(85),
      );
      for (final (sass, value, make, read) in fields) {
        final patch = make(value);
        expect(const SemiInputThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final defaults = const SemiInputThemeData().resolve(
          const SemiThemeData.light(),
        );
        expect(read(defaults), isNotNull, reason: sass);
        final overridden = const SemiInputThemeData().resolve(
          const SemiThemeData.dark(),
        );
        expect(read(overridden), isNotNull, reason: sass);
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_input_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(94));
    });

    test('97 = 94 themed + 3 INTERNAL; internals carry provenance in the '
        'widget', () {
      final widget = File('lib/src/components/semi_input.dart')
          .readAsStringSync();
      const internals = [
        r'$transform_scale-input: var(--semi-transform_scale-none)',
        r'$spacing-input_group_withTopLabel-marginTop: $spacing-base',
        r'$spacing-input_group_withTopLabel-marginBottom: $spacing-base',
      ];
      for (final snippet in internals) {
        expect(widget, contains(snippet));
      }
      expect(fields, hasLength(94));
      expect(94 + internals.length, 97);
    });

    test('type coverage: 44 Color + 38 double + 1 FontWeight + 2 '
        'EdgeInsetsDirectional + 6 Duration + 3 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 44);
      expect(counts['double'], 38);
      expect(counts['FontWeight'], 1);
      expect(counts['EdgeInsetsDirectional'], 2);
      expect(counts['Duration'], 6);
      // Curves.bounceIn is a ParametricCurve.
      expect(fields.where((f) => f.$2 is Curve), hasLength(3));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().input, const SemiInputThemeData());
      const patch = SemiInputThemeData(
        colorInputDefaultBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(input: patch);
      expect(const SemiComponentThemes().copyWith(input: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.input, patch);
    });

    testWidgets('SemiInputTheme local patches apply and capture correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiInputTheme(
            data: const SemiInputThemeData(
              colorInputDefaultBgDefault: Color(0xff00ff00),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SizedBox(
                  width: 200,
                  child: SemiInputTheme(
                    data: const SemiInputThemeData(radiusInputWrapper: 5),
                    child: Builder(
                      builder: (context) {
                        final resolved = SemiInputTheme.resolve(context);
                        expect(
                          resolved.colorInputDefaultBgDefault,
                          const Color(0xff00ff00),
                        );
                        expect(resolved.radiusInputWrapper, 5);
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });

    testWidgets('theme overrides reach the wrapper decoration', (tester) async {
      await tester.pumpWidget(host(const SemiInput()));
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiInputTheme(
            data: const SemiInputThemeData(
              colorInputDefaultBgDefault: Color(0xffabcdef),
              radiusInputWrapper: 7,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SizedBox(width: 200, child: const SemiInput()),
              ),
            ),
          ),
        ),
      );
      final deco = wrapperDecoration(tester);
      expect(deco.color, const Color(0xffabcdef));
      expect(
        (deco.borderRadius as BorderRadius).topLeft,
        const Radius.circular(7),
      );
    });
  });

  testWidgets('drag-select works after typing (desktop mouse)', (tester) async {
    // Regression: a bare EditableText only has rudimentary gestures; the
    // TextSelectionGestureDetectorBuilder wrapper (TextField's recipe) is
    // what makes mouse drag-select work — without it typed text could not
    // be selected.
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(host(const SemiInput(placeholder: 'pick')));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'hello world');
    await tester.pump(const Duration(milliseconds: 50));
    final rect = tester.getRect(find.byType(EditableText));
    final gesture = await tester.startGesture(
      Offset(rect.left + 16, rect.center.dy),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(Offset(rect.left + 60, rect.center.dy));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText))
          .controller
          .selection,
      const TextSelection(baseOffset: 1, extentOffset: 4),
    );
  }, variant: TargetPlatformVariant.desktop());

  testWidgets('selection highlight follows the theme primary', (tester) async {
    // Regression: RenderEditable paints no selection band at all when
    // selectionColor is null — drag-selected text was invisible ("text
    // can't be selected"). Both fields derive the Material-convention
    // `primary @ 40%` tint (see `_InputMetrics.selectionHighlight`).
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    final expected = const SemiThemeData.light().colors.colorPrimary.withValues(
      alpha: 0.4,
    );
    await tester.pumpWidget(host(const SemiInput()));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).selectionColor,
      expected,
    );
    await tester.pumpWidget(host(const SemiTextArea()));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).selectionColor,
      expected,
    );
  });
}
