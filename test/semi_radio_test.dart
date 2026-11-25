// Behavior matrix for SemiRadio / SemiRadioGroup plus coverage for the 103
// generated theme declarations (96 FIELDS + 6 motion + 1 INTERNAL): defaults,
// overrides, merge, copyWith, resolve, equality, provenance and local patch
// capture.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: direction,
        child: Center(child: child),
      ),
    );

BoxDecoration boxDecoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byKey(SemiRadio.innerBoxKey),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

BoxDecoration cardDecoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byKey(SemiRadio.outerBoxKey)).decoration
        as BoxDecoration;

Finder iconFinder(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

Finder member(Object value) =>
    find.byWidgetPredicate((w) => w is SemiRadio && w.value == value);

BoxDecoration memberCircle(WidgetTester tester, Object value) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.descendant(
                  of: member(value),
                  matching: find.byKey(SemiRadio.innerBoxKey),
                ),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

Focus memberFocus(WidgetTester tester, Object value) => tester.widget<Focus>(
  find.descendant(of: member(value), matching: find.byType(Focus)),
);

typedef _Patch = SemiRadioThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedRadioThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-radio_default-border-default: var(--semi-color-text-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioDefaultBorderDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultBorderDefault,
    (SemiThemeData theme) => theme.colors.colorText3,
  ),
  (
    r'$color-radio_default-bg-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDefaultBgDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultBgDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-radio_default-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDefaultBgHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultBgHover,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-radio_default-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDefaultBgActive: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultBgActive,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-radio_default-border-hover: var(--semi-color-focus-border)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDefaultBorderHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultBorderHover,
    (SemiThemeData theme) => theme.colors.colorFocusBorder,
  ),
  (
    r'$color-radio_checked-border-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCheckedBorderHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCheckedBorderHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryHover,
  ),
  (
    r'$color-radio_checked-border-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCheckedBorderActive: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCheckedBorderActive,
    (SemiThemeData theme) => theme.colors.colorPrimaryActive,
  ),
  (
    r'$color-radio_default-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDefaultTextDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultTextDefault,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-radio_extra-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioExtraTextDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioExtraTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-radio_primary-bg-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioPrimaryBgHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioPrimaryBgHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryHover,
  ),
  (
    r'$color-radio_primary-bg-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioPrimaryBgActive: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioPrimaryBgActive,
    (SemiThemeData theme) => theme.colors.colorPrimaryActive,
  ),
  (
    r'$color-radio_primary-border-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioPrimaryBorderDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioPrimaryBorderDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-radio_primary-bg-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioPrimaryBgDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioPrimaryBgDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-radio_primary-text-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioPrimaryTextDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioPrimaryTextDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-radio_checked-bg-disabled: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCheckedBgDisabled: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCheckedBgDisabled,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-radio_default-border-disabled: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioDefaultBorderDisabled: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDefaultBorderDisabled,
    (SemiThemeData theme) => theme.colors.colorBorder,
  ),
  (
    r'$color-radio_checked-border-disabled: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCheckedBorderDisabled: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCheckedBorderDisabled,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-radio_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDisabledBgDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDisabledBgDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledFill,
  ),
  (
    r'$color-radio_disabled-bg-hover: transparent',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDisabledBgHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDisabledBgHover,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-radio_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioDisabledTextDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDisabledTextDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledText,
  ),
  (
    r'$color-radio_disabled-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioDisabledBorderDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioDisabledBorderDefault,
    (SemiThemeData theme) => theme.colors.colorBorder,
  ),
  (
    r'$color-radio_checked-icon-disabled: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCheckedIconDisabled: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCheckedIconDisabled,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-radio_buttonRadio-text-default: var(--semi-color-text-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioButtonRadioTextDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioButtonRadioTextDefault,
    (SemiThemeData theme) => theme.colors.colorText1,
  ),
  (
    r'$color-radio_buttonRadio-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioButtonRadioBgDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioButtonRadioBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-radio_buttonRadio-text-disabled: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioButtonRadioTextDisabled: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioButtonRadioTextDisabled,
    (SemiThemeData theme) => theme.colors.colorDisabledText,
  ),
  (
    r'$color-radio_addon_buttonRadio-bg-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioAddonButtonRadioBgHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioAddonButtonRadioBgHover,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-radio_addon_buttonRadio-text-checked: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioAddonButtonRadioTextChecked: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioAddonButtonRadioTextChecked,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-radio_addon_buttonRadio-bg-checked: var(--semi-color-bg-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioAddonButtonRadioBgChecked: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioAddonButtonRadioBgChecked,
    (SemiThemeData theme) => theme.colors.colorBg3,
  ),
  (
    r'$color-radio_cardRadioGroup-bg-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCardRadioGroupBgDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardRadioGroupBgDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-radio_cardRadioGroup-bg-checked: var(--semi-color-primary-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCardRadioGroupBgChecked: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardRadioGroupBgChecked,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-radio_cardRadioGroup_disabled-bg-checked: var(--semi-color-primary-light-default)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupDisabledBgChecked: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupDisabledBgChecked,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-radio_cardRadioGroup_disabled-bg-active: transparent',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupDisabledBgActive: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupDisabledBgActive,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-radio_cardRadioGroup-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCardRadioGroupBgHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardRadioGroupBgHover,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-radio_cardRadioGroup-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCardRadioGroupBgActive: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardRadioGroupBgActive,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-radio_cardRadioGroup_border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCardRadioGroupBorderDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardRadioGroupBorderDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-radio_cardRadioGroup_border-active: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiRadioThemeData(colorRadioCardRadioGroupBorderActive: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardRadioGroupBorderActive,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-radio_cardRadioGroup_checked_border-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupCheckedBorderActive: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupCheckedBorderActive,
    (SemiThemeData theme) => theme.colors.colorPrimaryActive,
  ),
  (
    r'$color-radio_cardRadioGroup_checked_border-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupCheckedBorderHover: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupCheckedBorderHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryHover,
  ),
  (
    r'$color-radio_cardRadioGroup_border_disabled-active: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupBorderDisabledActive: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupBorderDisabledActive,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-radio_cardRadioGroup_addon-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupAddonTextDefault: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupAddonTextDefault,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-radio_cardRadioGroup_extra-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupExtraTextDefault: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupExtraTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-radio_cardRadioGroup_checked_disabled-border-default: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupCheckedDisabledBorderDefault: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupCheckedDisabledBorderDefault,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-radio_cardRadioGroup_checked_disabled-border-hover: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(
      colorRadioCardRadioGroupCheckedDisabledBorderHover: v as Color,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.colorRadioCardRadioGroupCheckedDisabledBorderHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-radio_card-bg-hover: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCardBgHover: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardBgHover,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-radio_card-bg-active: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCardBgActive: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardBgActive,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-radio_card-bg-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioCardBgDefault: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioCardBgDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-radio_primary-outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiRadioThemeData(colorRadioPrimaryOutlineFocus: v as Color),
    (SemiResolvedRadioThemeData d) => d.colorRadioPrimaryOutlineFocus,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightActive,
  ),
  (
    r'$radius-radio_cardRadioGroup: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiRadioThemeData(radiusRadioCardRadioGroup: v as double),
    (SemiResolvedRadioThemeData d) => d.radiusRadioCardRadioGroup,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-radio_addon_buttonRadio: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiRadioThemeData(radiusRadioAddonButtonRadio: v as double),
    (SemiResolvedRadioThemeData d) => d.radiusRadioAddonButtonRadio,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-radio_buttonRadio: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiRadioThemeData(radiusRadioButtonRadio: v as double),
    (SemiResolvedRadioThemeData d) => d.radiusRadioButtonRadio,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$width-radio_cardRadioGroup_checked-border: 1px',
    4.5,
    (Object v) =>
        SemiRadioThemeData(widthRadioCardRadioGroupCheckedBorder: v as double),
    (SemiResolvedRadioThemeData d) => d.widthRadioCardRadioGroupCheckedBorder,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-radio_cardRadioGroup_checked_disabled-border: 1px',
    4.5,
    (Object v) => SemiRadioThemeData(
      widthRadioCardRadioGroupCheckedDisabledBorder: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.widthRadioCardRadioGroupCheckedDisabledBorder,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-radio_hover-border: $border-thickness-control',
    4.5,
    (Object v) => SemiRadioThemeData(widthRadioHoverBorder: v as double),
    (SemiResolvedRadioThemeData d) => d.widthRadioHoverBorder,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-radio_disabled-border: $border-thickness-control',
    4.5,
    (Object v) => SemiRadioThemeData(widthRadioDisabledBorder: v as double),
    (SemiResolvedRadioThemeData d) => d.widthRadioDisabledBorder,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-radio_innder-border: $border-thickness-control',
    4.5,
    (Object v) => SemiRadioThemeData(widthRadioInnderBorder: v as double),
    (SemiResolvedRadioThemeData d) => d.widthRadioInnderBorder,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-radio-outline: 2px',
    4.5,
    (Object v) => SemiRadioThemeData(widthRadioOutline: v as double),
    (SemiResolvedRadioThemeData d) => d.widthRadioOutline,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$height-radio_inner_min: 20px',
    4.5,
    (Object v) => SemiRadioThemeData(heightRadioInnerMin: v as double),
    (SemiResolvedRadioThemeData d) => d.heightRadioInnerMin,
    (SemiThemeData theme) => 20.0,
  ),
  (
    r'$width-radio_inner: $width-icon-medium',
    4.5,
    (Object v) => SemiRadioThemeData(widthRadioInner: v as double),
    (SemiResolvedRadioThemeData d) => d.widthRadioInner,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_addon-paddingLeft: $spacing-tight',
    4.5,
    (Object v) => SemiRadioThemeData(spacingRadioAddonPaddingLeft: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioAddonPaddingLeft,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$spacing-radio_addon-marginLeft: $width-radio_inner',
    4.5,
    (Object v) => SemiRadioThemeData(spacingRadioAddonMarginLeft: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioAddonMarginLeft,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_large-paddingX: $spacing-loose',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioAddonButtonRadioLargePaddingX: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioAddonButtonRadioLargePaddingX,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_large-paddingY: $spacing-base-tight * 0.5',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioAddonButtonRadioLargePaddingY: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioAddonButtonRadioLargePaddingY,
    (SemiThemeData theme) => 6.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_small-paddingX: $spacing-base',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioAddonButtonRadioSmallPaddingX: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioAddonButtonRadioSmallPaddingX,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_small-paddingY: $spacing-super-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioAddonButtonRadioSmallPaddingY: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioAddonButtonRadioSmallPaddingY,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_middle-paddingX: $spacing-base',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioAddonButtonRadioMiddlePaddingX: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioAddonButtonRadioMiddlePaddingX,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_middle-paddingY: $spacing-extra-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioAddonButtonRadioMiddlePaddingY: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioAddonButtonRadioMiddlePaddingY,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-radio_addon_buttonRadio_marginLeft: $spacing-none',
    4.5,
    (Object v) =>
        SemiRadioThemeData(spacingRadioAddonButtonRadioMarginLeft: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioAddonButtonRadioMarginLeft,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-radio_extra-paddingLeft: $width-radio_inner + $spacing-tight',
    4.5,
    (Object v) => SemiRadioThemeData(spacingRadioExtraPaddingLeft: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioExtraPaddingLeft,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$spacing-radio_content-rowGap: 4px',
    4.5,
    (Object v) => SemiRadioThemeData(spacingRadioContentRowGap: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioContentRowGap,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-radio_group_vertical-marginBottom: $spacing-base-tight',
    4.5,
    (Object v) =>
        SemiRadioThemeData(spacingRadioGroupVerticalMarginBottom: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioGroupVerticalMarginBottom,
    (SemiThemeData theme) => 12.0,
  ),
  (
    r'$spacing-radio_card_group_vertical-marginBottom: $spacing-base',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioCardGroupVerticalMarginBottom: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioCardGroupVerticalMarginBottom,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_group_horizontal-marginRight: $spacing-base',
    4.5,
    (Object v) =>
        SemiRadioThemeData(spacingRadioGroupHorizontalMarginRight: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioGroupHorizontalMarginRight,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_buttonRadio-padding: $spacing-extra-tight',
    4.5,
    (Object v) =>
        SemiRadioThemeData(spacingRadioButtonRadioPadding: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioButtonRadioPadding,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-radio_buttonRadioGroup_small-paddingX: $spacing-super-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioButtonRadioGroupSmallPaddingX: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioButtonRadioGroupSmallPaddingX,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-radio_buttonRadioGroup_small-paddingY: $spacing-extra-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioButtonRadioGroupSmallPaddingY: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioButtonRadioGroupSmallPaddingY,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-radio_buttonRadioGroup_middle-padding: $spacing-extra-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioButtonRadioGroupMiddlePadding: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioButtonRadioGroupMiddlePadding,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-radio_buttonRadioGroup_large-padding: $spacing-extra-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioButtonRadioGroupLargePadding: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioButtonRadioGroupLargePadding,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-radio_buttonRadioGroup-paddingRight: $spacing-none',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioButtonRadioGroupPaddingRight: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioButtonRadioGroupPaddingRight,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-radio_cardRadioGroup-paddingX: $spacing-base',
    4.5,
    (Object v) =>
        SemiRadioThemeData(spacingRadioCardRadioGroupPaddingX: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioCardRadioGroupPaddingX,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-radio_cardRadioGroup-paddingY: $spacing-base-tight',
    4.5,
    (Object v) =>
        SemiRadioThemeData(spacingRadioCardRadioGroupPaddingY: v as double),
    (SemiResolvedRadioThemeData d) => d.spacingRadioCardRadioGroupPaddingY,
    (SemiThemeData theme) => 12.0,
  ),
  (
    r'$spacing-radio_cardRadioGroup_inner-marginRight: $spacing-tight',
    4.5,
    (Object v) => SemiRadioThemeData(
      spacingRadioCardRadioGroupInnerMarginRight: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.spacingRadioCardRadioGroupInnerMarginRight,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$font-radio_buttonRadio_large-default-size: $font-size-regular',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioButtonRadioLargeDefaultSize: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioButtonRadioLargeDefaultSize,
    (SemiThemeData theme) => theme.typography.fontSizeRegular,
  ),
  (
    r'$font-radio_buttonRadio_small-default-size: $font-size-small',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioButtonRadioSmallDefaultSize: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioButtonRadioSmallDefaultSize,
    (SemiThemeData theme) => theme.typography.fontSizeSmall,
  ),
  (
    r'$font-radio_buttonRadio_middle-default-size: $font-size-small',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioButtonRadioMiddleDefaultSize: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioButtonRadioMiddleDefaultSize,
    (SemiThemeData theme) => theme.typography.fontSizeSmall,
  ),
  (
    r'$font-radio_buttonRadio-default-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (Object v) => SemiRadioThemeData(
      fontRadioButtonRadioDefaultFontWeight: v as FontWeight,
    ),
    (SemiResolvedRadioThemeData d) => d.fontRadioButtonRadioDefaultFontWeight,
    (SemiThemeData theme) => theme.typography.fontWeightBold,
  ),
  (
    r'$font-radio_buttonRadio-hover-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (Object v) => SemiRadioThemeData(
      fontRadioButtonRadioHoverFontWeight: v as FontWeight,
    ),
    (SemiResolvedRadioThemeData d) => d.fontRadioButtonRadioHoverFontWeight,
    (SemiThemeData theme) => theme.typography.fontWeightBold,
  ),
  (
    r'$font-radio_buttonRadio-checked-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (Object v) => SemiRadioThemeData(
      fontRadioButtonRadioCheckedFontWeight: v as FontWeight,
    ),
    (SemiResolvedRadioThemeData d) => d.fontRadioButtonRadioCheckedFontWeight,
    (SemiThemeData theme) => theme.typography.fontWeightBold,
  ),
  (
    r'$font-radio_buttonRadioGroup_small-lineHeight: 16px',
    4.5,
    (Object v) => SemiRadioThemeData(
      fontRadioButtonRadioGroupSmallLineHeight: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.fontRadioButtonRadioGroupSmallLineHeight,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$font-radio_buttonRadioGroup_middle-lineHeight: 16px',
    4.5,
    (Object v) => SemiRadioThemeData(
      fontRadioButtonRadioGroupMiddleLineHeight: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.fontRadioButtonRadioGroupMiddleLineHeight,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$font-radio_buttonRadioGroup_large-lineHeight: 20px',
    4.5,
    (Object v) => SemiRadioThemeData(
      fontRadioButtonRadioGroupLargeLineHeight: v as double,
    ),
    (SemiResolvedRadioThemeData d) =>
        d.fontRadioButtonRadioGroupLargeLineHeight,
    (SemiThemeData theme) => 20.0,
  ),
  (
    r'$font-radio_cardRadioGroup_addon-size: $font-size-regular',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioCardRadioGroupAddonSize: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioCardRadioGroupAddonSize,
    (SemiThemeData theme) => theme.typography.fontSizeRegular,
  ),
  (
    r'$font-radio_cardRadioGroup_addon-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (Object v) => SemiRadioThemeData(
      fontRadioCardRadioGroupAddonFontWeight: v as FontWeight,
    ),
    (SemiResolvedRadioThemeData d) => d.fontRadioCardRadioGroupAddonFontWeight,
    (SemiThemeData theme) => theme.typography.fontWeightBold,
  ),
  (
    r'$font-radio_cardRadioGroup_addon-lineHeight: 20px',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioCardRadioGroupAddonLineHeight: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioCardRadioGroupAddonLineHeight,
    (SemiThemeData theme) => 20.0,
  ),
  (
    r'$font-radio_cardRadioGroup_extra-size: $font-size-regular',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioCardRadioGroupExtraSize: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioCardRadioGroupExtraSize,
    (SemiThemeData theme) => theme.typography.fontSizeRegular,
  ),
  (
    r'$font-radio_cardRadioGroup_extra-fontWeight: normal',
    FontWeight.w900,
    (Object v) => SemiRadioThemeData(
      fontRadioCardRadioGroupExtraFontWeight: v as FontWeight,
    ),
    (SemiResolvedRadioThemeData d) => d.fontRadioCardRadioGroupExtraFontWeight,
    (SemiThemeData theme) => theme.typography.fontWeightRegular,
  ),
  (
    r'$font-radio_cardRadioGroup_extra-lineHeight: 20px',
    4.5,
    (Object v) =>
        SemiRadioThemeData(fontRadioCardRadioGroupExtraLineHeight: v as double),
    (SemiResolvedRadioThemeData d) => d.fontRadioCardRadioGroupExtraLineHeight,
    (SemiThemeData theme) => 20.0,
  ),
  (
    r'$transition_duration-radio-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiRadioThemeData(transitionDurationRadioBg: v as Duration),
    (SemiResolvedRadioThemeData d) => d.transitionDurationRadioBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-radio-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiRadioThemeData(transitionFunctionRadioBg: v as Curve),
    (SemiResolvedRadioThemeData d) => d.transitionFunctionRadioBg,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-radio-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiRadioThemeData(transitionDelayRadioBg: v as Duration),
    (SemiResolvedRadioThemeData d) => d.transitionDelayRadioBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_duration-radio-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiRadioThemeData(transitionDurationRadioBorder: v as Duration),
    (SemiResolvedRadioThemeData d) => d.transitionDurationRadioBorder,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-radio-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiRadioThemeData(transitionFunctionRadioBorder: v as Curve),
    (SemiResolvedRadioThemeData d) => d.transitionFunctionRadioBorder,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-radio-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiRadioThemeData(transitionDelayRadioBorder: v as Duration),
    (SemiResolvedRadioThemeData d) => d.transitionDelayRadioBorder,
    (SemiThemeData theme) => Duration.zero,
  ),
];

SemiResolvedRadioThemeData resolved() =>
    const SemiRadioThemeData().resolve(const SemiThemeData.light());

void main() {
  group('standalone controlled/uncontrolled', () {
    testWidgets('uncontrolled: defaultChecked and tap toggle', (tester) async {
      await tester.pumpWidget(host(const SemiRadio('A')));
      expect(iconFinder(SemiIcons.radio), findsNothing);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.pumpWidget(host(const SemiRadio('A', defaultChecked: true)));
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
    });

    testWidgets('controlled: checked drives rendering, tap only notifies', (
      tester,
    ) async {
      final log = <SemiRadioChangeEvent>[];
      await tester.pumpWidget(
        host(SemiRadio('A', checked: true, onChanged: log.add)),
      );
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, hasLength(1));
      expect(log.single.checked, isFalse);
      // Still rendered checked: the parent owns the value.
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
    });

    testWidgets('checked -> null keeps the last controlled value', (
      tester,
    ) async {
      Widget build(bool? checked) => host(SemiRadio('A', checked: checked));
      await tester.pumpWidget(build(true));
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.pumpWidget(build(null));
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsNothing);
    });

    testWidgets('preventDefault vetoes the uncontrolled toggle', (
      tester,
    ) async {
      final events = <SemiRadioChangeEvent>[];
      await tester.pumpWidget(
        host(
          SemiRadio(
            'A',
            onChanged: (e) {
              events.add(e);
              e.preventDefault();
            },
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(events, hasLength(1));
      expect(events.single.checked, isTrue);
      expect(events.single.defaultPrevented, isTrue);
      expect(iconFinder(SemiIcons.radio), findsNothing);
    });

    testWidgets('event is sealed after dispatch', (tester) async {
      late SemiRadioChangeEvent seen;
      await tester.pumpWidget(host(SemiRadio('A', onChanged: (e) => seen = e)));
      await tester.tap(find.text('A'));
      await tester.pump();
      seen.preventDefault();
      seen.stopPropagation();
      expect(seen.defaultPrevented, isFalse);
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
    });

    testWidgets('extra renders the second line under the label', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiRadio('A', extra: 'extra line')));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('extra line'), findsOneWidget);
    });

    testWidgets('Space and Enter toggle', (tester) async {
      await tester.pumpWidget(host(const SemiRadio('A', autofocus: true)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsNothing);
    });
  });

  group('group mutual exclusion', () {
    testWidgets('value equality is strict and exclusive', (tester) async {
      // 1 (int) and '1' (String): only the strict `==` match is checked.
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            value: 1,
            direction: SemiRadioDirection.vertical,
            children: [
              SemiRadio('one', value: 1),
              SemiRadio('str', value: '1'),
            ],
          ),
        ),
      );
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        lessThan(tester.getCenter(find.text('str')).dy),
      );
    });

    testWidgets('injection priority: group value wins over checked and '
        'defaultChecked', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            value: 'a',
            direction: SemiRadioDirection.vertical,
            children: [
              SemiRadio('A', value: 'a', checked: false),
              SemiRadio('B', value: 'b', defaultChecked: true),
            ],
          ),
        ),
      );
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      // The dot belongs to row A (above row B), as in the checkbox suite.
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        lessThan(tester.getCenter(find.text('B')).dy),
      );
    });

    testWidgets('disabled: group OR member', (tester) async {
      final log = <SemiRadioChangeEvent>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            disabled: true,
            onChanged: log.add,
            children: const [SemiRadio('A', value: 'a')],
          ),
        ),
      );
      await tester.tap(find.text('A'), warnIfMissed: false);
      await tester.pump();
      expect(log, isEmpty);
      expect(iconFinder(SemiIcons.radio), findsNothing);
      expect(memberFocus(tester, 'a').canRequestFocus, isFalse);
    });
  });

  group('change chain', () {
    testWidgets('group callback fires before the member callback', (
      tester,
    ) async {
      final order = <String>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: (_) => order.add('group'),
            children: [
              SemiRadio('A', value: 'a', onChanged: (_) => order.add('member')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(order, ['group', 'member']);
    });

    testWidgets('stopPropagation in the group callback breaks the chain', (
      tester,
    ) async {
      final order = <String>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: (e) {
              order.add('group');
              e.stopPropagation();
            },
            children: [
              SemiRadio('A', value: 'a', onChanged: (_) => order.add('member')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(order, ['group']);
    });

    testWidgets('re-clicking the selected member notifies nobody', (
      tester,
    ) async {
      final log = <SemiRadioChangeEvent>[];
      final memberLog = <SemiRadioChangeEvent>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            defaultValue: 'a',
            onChanged: log.add,
            children: [
              SemiRadio('A', value: 'a', onChanged: memberLog.add),
              SemiRadio('B', value: 'b'),
            ],
          ),
        ),
      );
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, isEmpty);
      expect(memberLog, isEmpty);
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
    });

    testWidgets('advanced mode cancels the selection on the checked member', (
      tester,
    ) async {
      final log = <(bool, Object?)>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            mode: SemiRadioMode.advanced,
            defaultValue: 'a',
            onChanged: (e) => log.add((e.checked, e.value)),
            children: const [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      // 组值置 null、event.checked=false、event.value=null.
      expect(log, [(false, null)]);
      expect(iconFinder(SemiIcons.radio), findsNothing);
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log.last, (true, 'b'));
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dx,
        greaterThan(tester.getCenter(find.text('A')).dx),
      );
    });

    testWidgets('controlled advanced cancel only notifies', (tester) async {
      final log = <(bool, Object?)>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            mode: SemiRadioMode.advanced,
            value: 'a',
            onChanged: (e) => log.add((e.checked, e.value)),
            children: const [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, [(false, null)]);
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
    });

    testWidgets('preventDefault vetoes the uncontrolled group landing', (
      tester,
    ) async {
      final log = <SemiRadioChangeEvent>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            defaultValue: 'a',
            onChanged: log.add,
            children: [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b', onChanged: (e) => e.preventDefault()),
            ],
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      // The chain fires (group first, member second) but the value is not
      // applied.
      expect(log, hasLength(1));
      expect(log.single.value, 'b');
      // The dot stays on row A (left of B in the horizontal wrap).
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dx,
        lessThan(tester.getCenter(find.text('B')).dx),
      );
    });

    testWidgets('controlled group value syncs and retains on release', (
      tester,
    ) async {
      final log = <SemiRadioChangeEvent>[];
      Widget build(Object? value) => host(
        SemiRadioGroup(
          value: value,
          direction: SemiRadioDirection.vertical,
          onChanged: log.add,
          options: const [
            SemiRadioOption(label: 'A', value: 'a'),
            SemiRadioOption(label: 'B', value: 'b'),
          ],
        ),
      );
      await tester.pumpWidget(build('a'));
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        lessThan(tester.getCenter(find.text('B')).dy),
      );
      await tester.pumpWidget(build('b'));
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        greaterThan(tester.getCenter(find.text('A')).dy),
      );
      // Controlled clicks only notify.
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log.last.value, 'a');
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        greaterThan(tester.getCenter(find.text('A')).dy),
      );
      // Releasing control retains the last value (checkbox :141 convention).
      await tester.pumpWidget(build(null));
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        greaterThan(tester.getCenter(find.text('A')).dy),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log.last.value, 'a');
      expect(
        tester.getCenter(iconFinder(SemiIcons.radio)).dy,
        lessThan(tester.getCenter(find.text('B')).dy),
      );
    });
  });

  group('keyboard roving', () {
    testWidgets('Tab stop is the selected member', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            value: 'b',
            children: [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b'),
              SemiRadio('C', value: 'c'),
            ],
          ),
        ),
      );
      expect(memberFocus(tester, 'a').skipTraversal, isTrue);
      expect(memberFocus(tester, 'b').skipTraversal, isFalse);
      expect(memberFocus(tester, 'c').skipTraversal, isTrue);
    });

    testWidgets('Tab stop falls back to the first member when nothing is '
        'selected', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            children: [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b'),
              SemiRadio('C', value: 'c'),
            ],
          ),
        ),
      );
      expect(memberFocus(tester, 'a').skipTraversal, isFalse);
      expect(memberFocus(tester, 'b').skipTraversal, isTrue);
      expect(memberFocus(tester, 'c').skipTraversal, isTrue);
    });

    testWidgets('Tab stop derivation skips disabled members', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            children: [
              SemiRadio('A', value: 'a', disabled: true),
              SemiRadio('B', value: 'b'),
              SemiRadio('C', value: 'c'),
            ],
          ),
        ),
      );
      expect(memberFocus(tester, 'a').skipTraversal, isTrue);
      expect(memberFocus(tester, 'b').skipTraversal, isFalse);
    });

    testWidgets('arrow keys move and select with wrap and disabled skip', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: (e) => log.add(e.value),
            children: const [
              SemiRadio('A', value: 'a', autofocus: true),
              SemiRadio('B', value: 'b'),
              SemiRadio('C', value: 'c', disabled: true),
              SemiRadio('D', value: 'd'),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(log, ['a']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(log.last, 'b');
      expect(memberCircle(tester, 'b').boxShadow, hasLength(1));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // C is disabled: the movement skips it and lands on D.
      expect(log.last, 'd');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // Wraps around to A.
      expect(log, ['a', 'b', 'd', 'a']);
    });

    testWidgets('arrowLeft/arrowUp move to the previous enabled member', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: (e) => log.add(e.value),
            children: const [
              SemiRadio('A', value: 'a', autofocus: true),
              SemiRadio('B', value: 'b'),
              SemiRadio('C', value: 'c'),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      // Wraps backwards to C.
      expect(log, ['c']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(log, ['c', 'b']);
    });

    testWidgets('Space selects the initial focus when nothing is selected', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: (e) => log.add(e.value),
            children: const [
              SemiRadio('A', value: 'a', autofocus: true),
              SemiRadio('B', value: 'b'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(log, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(log, ['a']);
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
    });

    testWidgets('Enter is not intercepted inside a group', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: (e) => log.add(e.value),
            children: const [
              SemiRadio('A', value: 'a', autofocus: true),
              SemiRadio('B', value: 'b'),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, isEmpty);
      expect(iconFinder(SemiIcons.radio), findsNothing);
    });

    testWidgets('standalone members keep the Space/Enter toggle', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            children: [
              SemiRadio('solo', autofocus: true),
              SemiRadio('A', value: 'a'),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsNothing);
    });
  });

  group('focus ring', () {
    testWidgets('focus ring is keyboard-gated and clicks clear it', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiRadio('A', autofocus: true)));
      await tester.pump();
      // Mouse/focus-without-keys paints no ring.
      expect(boxDecoration(tester).boxShadow, isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(boxDecoration(tester).boxShadow, hasLength(1));
      expect(
        boxDecoration(tester).boxShadow!.single.color,
        resolved().colorRadioPrimaryOutlineFocus,
      );
      expect(
        boxDecoration(tester).boxShadow!.single.spreadRadius,
        resolved().widthRadioOutline,
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(boxDecoration(tester).boxShadow, isNull);
    });

    testWidgets('card focus ring paints on the outer frame', (tester) async {
      await tester.pumpWidget(
        host(const SemiRadio('A', autofocus: true, type: SemiRadioType.card)),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(cardDecoration(tester).boxShadow, hasLength(1));
      expect(boxDecoration(tester).boxShadow, isNull);
    });

    testWidgets('disabled radio is not focusable and ignores taps', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiRadio('A', value: 'a', disabled: true, autofocus: true)),
      );
      await tester.pump();
      expect(memberFocus(tester, 'a').canRequestFocus, isFalse);
      await tester.tap(find.text('A'), warnIfMissed: false);
      await tester.pump();
      expect(iconFinder(SemiIcons.radio), findsNothing);
    });
  });

  group('type visuals', () {
    Future<void> buttonGeometry(
      WidgetTester tester,
      SemiRadioButtonSize size,
      double itemV,
      double itemH,
      double addonV,
      double addonH,
      double fontSize,
      double lineHeight,
    ) async {
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            type: SemiRadioType.button,
            buttonSize: size,
            children: const [SemiRadio('A', value: 'a')],
          ),
        ),
      );
      final item =
          tester
                  .widget<Padding>(
                    find.ancestor(
                      of: find.byType(SemiRadio),
                      matching: find.byType(Padding),
                    ),
                  )
                  .padding
              as EdgeInsetsDirectional;
      expect(item.top, itemV, reason: 'item padding (vertical)');
      expect(item.start, itemH, reason: 'item padding (horizontal)');
      final addon =
          tester
                  .widget<Padding>(
                    find.descendant(
                      of: find.byKey(SemiRadio.outerBoxKey),
                      matching: find.byType(Padding),
                    ),
                  )
                  .padding
              as EdgeInsetsDirectional;
      expect(addon.top, addonV, reason: 'addon padding (vertical)');
      expect(addon.start, addonH, reason: 'addon padding (horizontal)');
      final style = tester.widget<Text>(find.text('A')).style!;
      expect(style.fontSize, fontSize);
      expect(style.height, isNull);
      expect(style.fontWeight, FontWeight.w600);
    }

    testWidgets('button small: paddings 2/4 + 2/16, font 12/16', (
      tester,
    ) async {
      final t = resolved();
      await buttonGeometry(
        tester,
        SemiRadioButtonSize.small,
        t.spacingRadioButtonRadioGroupSmallPaddingX,
        t.spacingRadioButtonRadioGroupSmallPaddingY,
        t.spacingRadioAddonButtonRadioSmallPaddingY,
        t.spacingRadioAddonButtonRadioSmallPaddingX,
        t.fontRadioButtonRadioSmallDefaultSize,
        t.fontRadioButtonRadioGroupSmallLineHeight,
      );
    });

    testWidgets('button middle: paddings 4 + 4/16, font 12/16', (tester) async {
      final t = resolved();
      await buttonGeometry(
        tester,
        SemiRadioButtonSize.middle,
        t.spacingRadioButtonRadioGroupMiddlePadding,
        t.spacingRadioButtonRadioGroupMiddlePadding,
        t.spacingRadioAddonButtonRadioMiddlePaddingY,
        t.spacingRadioAddonButtonRadioMiddlePaddingX,
        t.fontRadioButtonRadioMiddleDefaultSize,
        t.fontRadioButtonRadioGroupMiddleLineHeight,
      );
    });

    testWidgets('button large: paddings 4 + 6/24, font 14/20', (tester) async {
      final t = resolved();
      await buttonGeometry(
        tester,
        SemiRadioButtonSize.large,
        t.spacingRadioButtonRadioGroupLargePadding,
        t.spacingRadioButtonRadioGroupLargePadding,
        t.spacingRadioAddonButtonRadioLargePaddingY,
        t.spacingRadioAddonButtonRadioLargePaddingX,
        t.fontRadioButtonRadioLargeDefaultSize,
        t.fontRadioButtonRadioGroupLargeLineHeight,
      );
    });

    testWidgets('button colors: unchecked/checked/disabled', (tester) async {
      final t = resolved();
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            type: SemiRadioType.button,
            children: [SemiRadio('A', value: 'a')],
          ),
        ),
      );
      final surface =
          tester
                  .widget<DecoratedBox>(find.byKey(SemiRadio.outerBoxKey))
                  .decoration
              as BoxDecoration;
      expect(surface.color, const Color(0x00000000));
      expect(
        tester.widget<Text>(find.text('A')).style!.color,
        t.colorRadioButtonRadioTextDefault,
      );

      await tester.tap(find.text('A'));
      await tester.pump();
      final checked =
          tester
                  .widget<DecoratedBox>(find.byKey(SemiRadio.outerBoxKey))
                  .decoration
              as BoxDecoration;
      expect(checked.color, t.colorRadioAddonButtonRadioBgChecked);
      expect(
        tester.widget<Text>(find.text('A')).style!.color,
        t.colorRadioAddonButtonRadioTextChecked,
      );

      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            type: SemiRadioType.button,
            children: [SemiRadio('A', value: 'a', disabled: true)],
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('A')).style!.color,
        t.colorRadioButtonRadioTextDisabled,
      );
    });

    testWidgets('card frame: checked bg/border and white circle', (
      tester,
    ) async {
      final t = resolved();
      await tester.pumpWidget(
        host(const SemiRadio('A', type: SemiRadioType.card)),
      );
      expect(boxDecoration(tester).color, t.colorRadioCardBgDefault);
      var card = cardDecoration(tester);
      expect(
        card.borderRadius,
        BorderRadius.circular(t.radiusRadioCardRadioGroup),
      );
      expect(card.border!.top.width, t.widthRadioCardRadioGroupCheckedBorder);
      expect(card.border!.top.color, t.colorRadioCardRadioGroupBorderDefault);
      final pad =
          tester
                  .widget<Padding>(
                    find.descendant(
                      of: find.byKey(SemiRadio.outerBoxKey),
                      matching: find.byType(Padding),
                    ),
                  )
                  .padding
              as EdgeInsetsDirectional;
      expect(pad.top, t.spacingRadioCardRadioGroupPaddingY);
      expect(pad.start, t.spacingRadioCardRadioGroupPaddingX);

      await tester.pumpWidget(
        host(const SemiRadio('A', type: SemiRadioType.card, checked: true)),
      );
      card = cardDecoration(tester);
      expect(card.color, t.colorRadioCardRadioGroupBgChecked);
      expect(card.border!.top.color, t.colorRadioCardRadioGroupBorderActive);
      expect(card.border!.top.width, t.widthRadioCardRadioGroupCheckedBorder);
      // The checked circle keeps the primary fill and the white dot.
      expect(boxDecoration(tester).color, t.colorRadioPrimaryBgDefault);
      expect(
        tester.widget<SemiIcon>(iconFinder(SemiIcons.radio)).color,
        t.colorRadioPrimaryTextDefault,
      );
    });

    testWidgets('pureCard renders no circle', (tester) async {
      await tester.pumpWidget(
        host(const SemiRadio('A', type: SemiRadioType.pureCard, checked: true)),
      );
      expect(find.byKey(SemiRadio.innerBoxKey), findsNothing);
      expect(iconFinder(SemiIcons.radio), findsNothing);
      expect(find.text('A'), findsOneWidget);
      expect(find.byKey(SemiRadio.outerBoxKey), findsOneWidget);
    });

    testWidgets('direction layouts: vertical row gap and horizontal wrap gap', (
      tester,
    ) async {
      final t = resolved();
      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            direction: SemiRadioDirection.vertical,
            children: [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b'),
              SemiRadio('C', value: 'c'),
            ],
          ),
        ),
      );
      expect(find.byType(Wrap), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.height == t.spacingRadioGroupVerticalMarginBottom,
        ),
        findsNWidgets(2),
      );

      await tester.pumpWidget(
        host(
          const SemiRadioGroup(
            children: [
              SemiRadio('A', value: 'a'),
              SemiRadio('B', value: 'b'),
            ],
          ),
        ),
      );
      expect(
        tester.widget<Wrap>(find.byType(Wrap)).spacing,
        t.spacingRadioGroupHorizontalMarginRight,
      );
    });
  });

  group('options rendering', () {
    testWidgets('string content, OptionItem and disabled entries', (
      tester,
    ) async {
      final log = <SemiRadioChangeEvent>[];
      await tester.pumpWidget(
        host(
          SemiRadioGroup(
            onChanged: log.add,
            options: const [
              SemiRadioOption(label: 'A', value: 'a'),
              SemiRadioOption(
                label: 'B',
                value: 'b',
                extra: 'bee',
                disabled: true,
              ),
              SemiRadioOption(label: 42, value: 'c'),
            ],
          ),
        ),
      );
      expect(find.byType(SemiRadio), findsNWidgets(3));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('bee'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log, isEmpty);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log.single.value, 'a');
    });
  });

  group('theme fields (96 + 6 + 1)', () {
    test('102 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(102));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(6),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(96),
      );
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiRadioThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiRadioThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiRadioThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_radio_theme_data.dart')
          .readAsStringSync();
      final widgetSource = File('lib/src/components/semi_radio.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(102));
      // The 103rd declaration stays widget-internal.
      expect(
        widgetSource,
        contains(r'$transform_scale-radio: var(--semi-transform_scale-none)'),
      );
    });

    test('type coverage: 47 Color + 44 double + 5 FontWeight + 4 Duration'
        ' + 2 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 47);
      expect(counts['double'], 44);
      expect(counts['FontWeight'], 5);
      expect(counts['Duration'], 4);
      // Curves.bounceIn is a ParametricCurve.
      expect(fields.where((f) => f.$2 is Curve), hasLength(2));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().radio, const SemiRadioThemeData());
      const patch = SemiRadioThemeData(
        colorRadioPrimaryBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(radio: patch);
      expect(const SemiComponentThemes().copyWith(radio: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.radio, patch);
    });

    testWidgets('SemiRadioTheme local patch applies to the radio', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiRadioTheme(
            data: const SemiRadioThemeData(
              colorRadioPrimaryBgDefault: Color(0xff00ff00),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiRadioTheme(
                  data: const SemiRadioThemeData(widthRadioInnderBorder: 5),
                  child: const SemiRadio('x', checked: true),
                ),
              ),
            ),
          ),
        ),
      );
      final deco = boxDecoration(tester);
      // Nested local patches merge; the inner patch wins its own field only.
      expect(deco.color, const Color(0xff00ff00));
      expect(deco.border!.top.width, 5);
    });
  });
}
