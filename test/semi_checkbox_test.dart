// Behavior matrix for SemiCheckbox / SemiCheckboxGroup plus coverage for the
// 66 generated theme fields (60 FIELDS + 6 motion): defaults, overrides,
// merge, copyWith, resolve, equality, provenance and local patch capture.
import 'dart:io';
import 'dart:ui' as ui;

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
                of: find.byKey(SemiCheckbox.innerBoxKey),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

BoxDecoration cardDecoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byKey(SemiCheckbox.outerBoxKey)).decoration
        as BoxDecoration;

Finder iconFinder(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

typedef _Patch = SemiCheckboxThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedCheckboxThemeData data);

final List<(String, Object, _Patch, _Read)> fields = [
  (
    r'$color-checkbox_label-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxLabelTextDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxLabelTextDefault,
  ),
  (
    r'$color-checkbox_default-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDefaultBgHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDefaultBgHover,
  ),
  (
    r'$color-checkbox_default-bg-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDefaultBgDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDefaultBgDefault,
  ),
  (
    r'$color-checkbox_default-border-hover: var(--semi-color-focus-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDefaultBorderHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDefaultBorderHover,
  ),
  (
    r'$color-checkbox_default-border-default: var(--semi-color-text-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDefaultBorderDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDefaultBorderDefault,
  ),
  (
    r'$color-checkbox_default-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDefaultBgActive: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDefaultBgActive,
  ),
  (
    r'$color-checkbox_label-text-disabled: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxLabelTextDisabled: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxLabelTextDisabled,
  ),
  (
    r'$color-checkbox_checked-bg-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBgDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBgDefault,
  ),
  (
    r'$color-checkbox_checked-bg-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBgHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBgHover,
  ),
  (
    r'$color-checkbox_checked-bg-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBgActive: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBgActive,
  ),
  (
    r'$color-checkbox_checked-icon-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedIconDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedIconDefault,
  ),
  (
    r'$color-checkbox_checked-icon-hover: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedIconHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedIconHover,
  ),
  (
    r'$color-checkbox_checked-icon-active: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedIconActive: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedIconActive,
  ),
  (
    r'$color-checkbox_checked-border-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBorderDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBorderDefault,
  ),
  (
    r'$color-checkbox_checked-border-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBorderHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBorderHover,
  ),
  (
    r'$color-checkbox_checked-border-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBorderActive: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBorderActive,
  ),
  (
    r'$color-checkbox_cardType_checked-bg: var(--semi-color-primary-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeCheckedBg: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeCheckedBg,
  ),
  (
    r'$color-checkbox_cardType_checked_disabled-bg: var(--semi-color-primary-light-default)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeCheckedDisabledBg: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeCheckedDisabledBg,
  ),
  (
    r'$color-checkbox_cardType-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeBgHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeBgHover,
  ),
  (
    r'$color-checkbox_cardType-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeBgActive: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeBgActive,
  ),
  (
    r'$color-checkbox_cardType_checked_border-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeCheckedBorderDefault: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeCheckedBorderDefault,
  ),
  (
    r'$color-checkbox_cardType_checked_border-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeCheckedBorderHover: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeCheckedBorderHover,
  ),
  (
    r'$color-checkbox_cardType_checked_border-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeCheckedBorderActive: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeCheckedBorderActive,
  ),
  (
    r'$color-checkbox_cardType_checked_disabled_border-default: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeCheckedDisabledBorderDefault: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeCheckedDisabledBorderDefault,
  ),
  (
    r'$color-checkbox_cardType_addon-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeAddonTextDefault: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeAddonTextDefault,
  ),
  (
    r'$color-checkbox_cardType_extra-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiCheckboxThemeData(
      colorCheckboxCardTypeExtraTextDefault: v as Color,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.colorCheckboxCardTypeExtraTextDefault,
  ),
  (
    r'$color-checkbox_cardType_inner-bg-hover: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeInnerBgHover: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeInnerBgHover,
  ),
  (
    r'$color-checkbox_cardType_inner-bg-active: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeInnerBgActive: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeInnerBgActive,
  ),
  (
    r'$color-checkbox_cardType_inner-bg-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeInnerBgDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeInnerBgDefault,
  ),
  (
    r'$color-checkbox_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDisabledBgDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDisabledBgDefault,
  ),
  (
    r'$color-checkbox_disabled-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxDisabledBorderDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxDisabledBorderDefault,
  ),
  (
    r'$color-checkbox_checked-bg-disabled: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedBgDisabled: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedBgDisabled,
  ),
  (
    r'$color-checkbox_checked-icon-disabled: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCheckedIconDisabled: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCheckedIconDisabled,
  ),
  (
    r'$color-checkbox_primary-outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxPrimaryOutlineFocus: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxPrimaryOutlineFocus,
  ),
  (
    r'$color-checkbox_cardType-border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxCardTypeBorderDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxCardTypeBorderDefault,
  ),
  (
    r'$color-checkbox_extra-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiCheckboxThemeData(colorCheckboxExtraTextDefault: v as Color),
    (SemiResolvedCheckboxThemeData d) => d.colorCheckboxExtraTextDefault,
  ),
  (
    r'$font-checkbox_label-lineHeight: 20px',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(fontCheckboxLabelLineHeight: v as double),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxLabelLineHeight,
  ),
  (
    r'$font-checkbox_cardType_addon-size: $font-size-regular',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(fontCheckboxCardTypeAddonSize: v as double),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxCardTypeAddonSize,
  ),
  (
    r'$font-checkbox_cardType_addon-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (Object v) => SemiCheckboxThemeData(
      fontCheckboxCardTypeAddonFontWeight: v as FontWeight,
    ),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxCardTypeAddonFontWeight,
  ),
  (
    r'$font-checkbox_cardType_addon-lineHeight: 20px',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(fontCheckboxCardTypeAddonLineHeight: v as double),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxCardTypeAddonLineHeight,
  ),
  (
    r'$font-checkbox_cardType_extra-size: $font-size-regular',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(fontCheckboxCardTypeExtraSize: v as double),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxCardTypeExtraSize,
  ),
  (
    r'$font-checkbox_cardType_extra-fontWeight: normal',
    FontWeight.w900,
    (Object v) => SemiCheckboxThemeData(
      fontCheckboxCardTypeExtraFontWeight: v as FontWeight,
    ),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxCardTypeExtraFontWeight,
  ),
  (
    r'$font-checkbox_cardType_extra-lineHeight: 20px',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(fontCheckboxCardTypeExtraLineHeight: v as double),
    (SemiResolvedCheckboxThemeData d) => d.fontCheckboxCardTypeExtraLineHeight,
  ),
  (
    r'$spacing-checkbox_label-paddingLeft: $spacing-tight',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(spacingCheckboxLabelPaddingLeft: v as double),
    (SemiResolvedCheckboxThemeData d) => d.spacingCheckboxLabelPaddingLeft,
  ),
  (
    r'$spacing-checkbox_extra-marginTop: $spacing-extra-tight',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(spacingCheckboxExtraMarginTop: v as double),
    (SemiResolvedCheckboxThemeData d) => d.spacingCheckboxExtraMarginTop,
  ),
  (
    r'$spacing-checkbox_cardType-paddingX: $spacing-base',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(spacingCheckboxCardTypePaddingX: v as double),
    (SemiResolvedCheckboxThemeData d) => d.spacingCheckboxCardTypePaddingX,
  ),
  (
    r'$spacing-checkbox_cardType-paddingY: $spacing-base-tight',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(spacingCheckboxCardTypePaddingY: v as double),
    (SemiResolvedCheckboxThemeData d) => d.spacingCheckboxCardTypePaddingY,
  ),
  (
    r'$spacing-checkbox_cardType_inner-marginRight: $spacing-tight',
    4.5,
    (Object v) => SemiCheckboxThemeData(
      spacingCheckboxCardTypeInnerMarginRight: v as double,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.spacingCheckboxCardTypeInnerMarginRight,
  ),
  (
    r'$spacing-checkbox_card_group_vertical-marginBottom: $spacing-base',
    4.5,
    (Object v) => SemiCheckboxThemeData(
      spacingCheckboxCardGroupVerticalMarginBottom: v as double,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.spacingCheckboxCardGroupVerticalMarginBottom,
  ),
  (
    r'$spacing-checkbox_group_vertical-marginBottom: $spacing-base',
    4.5,
    (Object v) => SemiCheckboxThemeData(
      spacingCheckboxGroupVerticalMarginBottom: v as double,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.spacingCheckboxGroupVerticalMarginBottom,
  ),
  (
    r'$spacing-checkbox_group_vertical_item-marginBottom: $spacing-base-tight',
    4.5,
    (Object v) => SemiCheckboxThemeData(
      spacingCheckboxGroupVerticalItemMarginBottom: v as double,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.spacingCheckboxGroupVerticalItemMarginBottom,
  ),
  (
    r'$spacing-checkbox_group_horizontal-marginRight: $spacing-base',
    4.5,
    (Object v) => SemiCheckboxThemeData(
      spacingCheckboxGroupHorizontalMarginRight: v as double,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.spacingCheckboxGroupHorizontalMarginRight,
  ),
  (
    r'$size-checkbox_inner-shadow: $border-thickness-control',
    4.5,
    (Object v) => SemiCheckboxThemeData(sizeCheckboxInnerShadow: v as double),
    (SemiResolvedCheckboxThemeData d) => d.sizeCheckboxInnerShadow,
  ),
  (
    r'$width-checkbox_inner: $width-icon-medium',
    4.5,
    (Object v) => SemiCheckboxThemeData(widthCheckboxInner: v as double),
    (SemiResolvedCheckboxThemeData d) => d.widthCheckboxInner,
  ),
  (
    r'$height-checkbox_inner: 20px',
    4.5,
    (Object v) => SemiCheckboxThemeData(heightCheckboxInner: v as double),
    (SemiResolvedCheckboxThemeData d) => d.heightCheckboxInner,
  ),
  (
    r'$width-checkbox_cardType_checked-border: 1px',
    4.5,
    (Object v) =>
        SemiCheckboxThemeData(widthCheckboxCardTypeCheckedBorder: v as double),
    (SemiResolvedCheckboxThemeData d) => d.widthCheckboxCardTypeCheckedBorder,
  ),
  (
    r'$width-checkbox_cardType_checked_disabled-border: 1px',
    4.5,
    (Object v) => SemiCheckboxThemeData(
      widthCheckboxCardTypeCheckedDisabledBorder: v as double,
    ),
    (SemiResolvedCheckboxThemeData d) =>
        d.widthCheckboxCardTypeCheckedDisabledBorder,
  ),
  (
    r'$width-checkbox-outline: 2px',
    4.5,
    (Object v) => SemiCheckboxThemeData(widthCheckboxOutline: v as double),
    (SemiResolvedCheckboxThemeData d) => d.widthCheckboxOutline,
  ),
  (
    r'$radius-checkbox_cardType: 3px',
    4.5,
    (Object v) => SemiCheckboxThemeData(radiusCheckboxCardType: v as double),
    (SemiResolvedCheckboxThemeData d) => d.radiusCheckboxCardType,
  ),
  (
    r'$radius-checkbox_inner: var(--semi-border-radius-extra-small)',
    4.5,
    (Object v) => SemiCheckboxThemeData(radiusCheckboxInner: v as double),
    (SemiResolvedCheckboxThemeData d) => d.radiusCheckboxInner,
  ),
  (
    r'$transition_duration-checkbox-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiCheckboxThemeData(transitionDurationCheckboxBg: v as Duration),
    (SemiResolvedCheckboxThemeData d) => d.transitionDurationCheckboxBg,
  ),
  (
    r'$transition_function-checkbox-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiCheckboxThemeData(transitionFunctionCheckboxBg: v as Curve),
    (SemiResolvedCheckboxThemeData d) => d.transitionFunctionCheckboxBg,
  ),
  (
    r'$transition_delay-checkbox-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiCheckboxThemeData(transitionDelayCheckboxBg: v as Duration),
    (SemiResolvedCheckboxThemeData d) => d.transitionDelayCheckboxBg,
  ),
  (
    r'$transition_duration-checkbox-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiCheckboxThemeData(transitionDurationCheckboxBorder: v as Duration),
    (SemiResolvedCheckboxThemeData d) => d.transitionDurationCheckboxBorder,
  ),
  (
    r'$transition_function-checkbox-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiCheckboxThemeData(transitionFunctionCheckboxBorder: v as Curve),
    (SemiResolvedCheckboxThemeData d) => d.transitionFunctionCheckboxBorder,
  ),
  (
    r'$transition_delay-checkbox-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiCheckboxThemeData(transitionDelayCheckboxBorder: v as Duration),
    (SemiResolvedCheckboxThemeData d) => d.transitionDelayCheckboxBorder,
  ),
];

SemiResolvedCheckboxThemeData resolved() =>
    const SemiCheckboxThemeData().resolve(const SemiThemeData.light());

void main() {
  group('standalone controlled/uncontrolled', () {
    testWidgets('uncontrolled: defaultChecked and tap toggle', (tester) async {
      await tester.pumpWidget(host(const SemiCheckbox(label: 'A')));
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', defaultChecked: true)),
      );
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
    });

    testWidgets('controlled: checked drives rendering, tap only notifies', (
      tester,
    ) async {
      final log = <bool>[];
      await tester.pumpWidget(
        host(
          SemiCheckbox(
            label: 'A',
            checked: true,
            onChanged: (e) => log.add(e.checked),
          ),
        ),
      );
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, [false]);
      // Still rendered checked: the parent owns the value.
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
    });

    testWidgets('checked -> null keeps the last controlled value', (
      tester,
    ) async {
      Widget build(bool? checked) =>
          host(SemiCheckbox(label: 'A', checked: checked));
      await tester.pumpWidget(build(true));
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      await tester.pumpWidget(build(null));
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
    });

    testWidgets('preventDefault vetoes the uncontrolled toggle', (
      tester,
    ) async {
      final events = <SemiCheckboxChangeEvent>[];
      await tester.pumpWidget(
        host(
          SemiCheckbox(
            label: 'A',
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
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
    });

    testWidgets('event is sealed after dispatch', (tester) async {
      late SemiCheckboxChangeEvent seen;
      await tester.pumpWidget(
        host(SemiCheckbox(label: 'A', onChanged: (e) => seen = e)),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      seen.preventDefault();
      seen.stopPropagation();
      expect(seen.defaultPrevented, isFalse);
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
    });
  });

  group('indeterminate', () {
    testWidgets('three states: icon rendering and checked priority', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiCheckbox(label: 'A')));
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
      expect(iconFinder(SemiIcons.checkboxIndeterminate), findsNothing);

      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', indeterminate: true)),
      );
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
      expect(iconFinder(SemiIcons.checkboxIndeterminate), findsOneWidget);
      expect(
        boxDecoration(tester).color,
        resolved().colorCheckboxCheckedBgDefault,
      );

      await tester.pumpWidget(
        host(
          const SemiCheckbox(label: 'A', checked: true, indeterminate: true),
        ),
      );
      // checked wins the icon over indeterminate.
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      expect(iconFinder(SemiIcons.checkboxIndeterminate), findsNothing);

      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', checked: true)),
      );
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
    });

    testWidgets('Semantics: checked vs mixed', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiCheckbox(key: ValueKey('s1'), label: 'A', checked: true),
        ),
      );
      var node = tester.getSemantics(find.byType(SemiCheckbox));
      expect(node.flagsCollection.isChecked, ui.CheckedState.isTrue);
      await tester.pumpWidget(
        host(
          const SemiCheckbox(
            key: ValueKey('s2'),
            label: 'A',
            indeterminate: true,
          ),
        ),
      );
      node = tester.getSemantics(find.byType(SemiCheckbox));
      expect(node.flagsCollection.isChecked, ui.CheckedState.mixed);
      await tester.pumpWidget(
        host(const SemiCheckbox(key: ValueKey('s3'), label: 'A')),
      );
      node = tester.getSemantics(find.byType(SemiCheckbox));
      expect(node.flagsCollection.isChecked, ui.CheckedState.isFalse);
    });
  });

  group('geometry and state matrix', () {
    testWidgets('inner box is 16x20 line-height slot with 16x16 paint box', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiCheckbox(label: SizedBox(width: 40, height: 20))),
      );
      expect(
        tester.getSize(find.byKey(SemiCheckbox.innerBoxKey)),
        const Size(16, 20),
      );
      expect(
        tester.getSize(
          find.descendant(
            of: find.byKey(SemiCheckbox.innerBoxKey),
            matching: find.byType(DecoratedBox),
          ),
        ),
        const Size(16, 16),
      );
      // Row height equals the 20px label line height.
      expect(tester.getSize(find.byType(SemiCheckbox)).height, 20);
    });

    testWidgets('normal checked/disabled matrix', (tester) async {
      final t = resolved();
      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', checked: true)),
      );
      var deco = boxDecoration(tester);
      expect(deco.color, t.colorCheckboxCheckedBgDefault);
      expect(deco.border!.top.color, t.colorCheckboxCheckedBorderDefault);
      expect(deco.border!.top.width, t.sizeCheckboxInnerShadow);
      expect(deco.borderRadius, BorderRadius.circular(t.radiusCheckboxInner));
      expect(
        tester.widget<SemiIcon>(iconFinder(SemiIcons.checkboxTick)).color,
        t.colorCheckboxCheckedIconDefault,
      );

      await tester.pumpWidget(
        host(
          const SemiCheckbox(
            key: ValueKey('m2'),
            label: 'A',
            checked: true,
            disabled: true,
          ),
        ),
      );
      deco = boxDecoration(tester);
      expect(deco.color, t.colorCheckboxCheckedBgDisabled);
      expect(
        find.descendant(
          of: find.byKey(SemiCheckbox.innerBoxKey),
          matching: find.byWidgetPredicate(
            (w) => w is Opacity && w.opacity == 0.75,
          ),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', disabled: true)),
      );
      deco = boxDecoration(tester);
      expect(deco.color, t.colorCheckboxDisabledBgDefault);
      expect(deco.border!.top.color, t.colorCheckboxDisabledBorderDefault);
    });

    testWidgets('card geometry and checked/disabled matrix', (tester) async {
      final t = resolved();
      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', type: SemiCheckboxType.card)),
      );
      final card = cardDecoration(tester);
      expect(
        card.borderRadius,
        BorderRadius.circular(t.radiusCheckboxCardType),
      );
      expect(card.border!.top.width, t.widthCheckboxCardTypeCheckedBorder);
      expect(card.border!.top.color, t.colorCheckboxCardTypeBorderDefault);
      expect(
        tester.getSize(find.byKey(SemiCheckbox.outerBoxKey)).height,
        t.spacingCheckboxCardTypePaddingY * 2 + 20,
      );
      // Unchecked inner box is forced white in card mode.
      expect(
        boxDecoration(tester).color,
        t.colorCheckboxCardTypeInnerBgDefault,
      );

      await tester.pumpWidget(
        host(
          const SemiCheckbox(
            label: 'A',
            checked: true,
            type: SemiCheckboxType.card,
          ),
        ),
      );
      var outer = cardDecoration(tester);
      expect(outer.color, t.colorCheckboxCardTypeCheckedBg);
      expect(
        outer.border!.top.color,
        t.colorCheckboxCardTypeCheckedBorderDefault,
      );
      expect(outer.border!.top.width, t.widthCheckboxCardTypeCheckedBorder);
      // Checked keeps the checked fill + white tick (upstream CSS cascade).
      expect(boxDecoration(tester).color, t.colorCheckboxCheckedBgDefault);

      await tester.pumpWidget(
        host(
          const SemiCheckbox(
            label: 'A',
            checked: true,
            disabled: true,
            type: SemiCheckboxType.card,
          ),
        ),
      );
      outer = cardDecoration(tester);
      expect(outer.color, t.colorCheckboxCardTypeCheckedDisabledBg);
      expect(
        outer.border!.top.color,
        t.colorCheckboxCardTypeCheckedDisabledBorderDefault,
      );
      expect(
        outer.border!.top.width,
        t.widthCheckboxCardTypeCheckedDisabledBorder,
      );
    });

    testWidgets('pureCard hides the box: opacity 0, width 0, gap 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiCheckbox(
            label: SizedBox(width: 40, height: 20),
            type: SemiCheckboxType.pureCard,
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(SemiCheckbox),
          matching: find.byWidgetPredicate(
            (w) => w is Opacity && w.opacity == 0,
          ),
        ),
        findsOneWidget,
      );
      expect(tester.getSize(find.byKey(SemiCheckbox.innerBoxKey)).width, 0);
      // Gap 0: the label starts at the row start (the card frame padding
      // 12/16 still wraps the row, as in upstream cardType).
      expect(
        tester.getTopLeft(find.byKey(SemiCheckbox.innerBoxKey)),
        tester.getTopLeft(find.byType(Row)),
      );
    });

    testWidgets('hover drives fill states and onHover', (tester) async {
      final t = resolved();
      final hovers = <bool>[];
      await tester.pumpWidget(
        host(
          SemiCheckbox(label: 'A', onHover: hovers.add, defaultChecked: true),
        ),
      );
      expect(boxDecoration(tester).color, t.colorCheckboxCheckedBgDefault);
      final mouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(SemiCheckbox)));
      await tester.pump();
      expect(hovers, [true]);
      expect(boxDecoration(tester).color, t.colorCheckboxCheckedBgHover);
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(hovers, [true, false]);
      expect(boxDecoration(tester).color, t.colorCheckboxCheckedBgDefault);
    });
  });

  group('group membership and injection', () {
    testWidgets('options mode renders and notifies the group value', (
      tester,
    ) async {
      final log = <List<Object>>[];
      await tester.pumpWidget(
        host(
          SemiCheckboxGroup(
            options: const [
              SemiCheckboxOption(label: 'A', value: 'a'),
              SemiCheckboxOption(label: 'B', value: 'b', extra: 'bee'),
              SemiCheckboxOption(label: 'C', value: 'c', disabled: true),
            ],
            onChanged: log.add,
          ),
        ),
      );
      expect(find.byType(SemiCheckbox), findsNWidgets(3));
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, [
        ['a'],
      ]);
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log, [
        ['a'],
        ['a', 'b'],
      ]);
      // Disabled option swallows taps.
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(log, hasLength(2));
    });

    testWidgets('children mode joins through the scope', (tester) async {
      final log = <List<Object>>[];
      await tester.pumpWidget(
        host(
          SemiCheckboxGroup(
            onChanged: log.add,
            children: const [
              SemiCheckbox(label: 'A', value: 'a'),
              SemiCheckbox(label: 'B', value: 'b'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log, [
        ['b'],
      ]);
    });

    testWidgets('a checkbox without value stays independent', (tester) async {
      final log = <List<Object>>[];
      await tester.pumpWidget(
        host(
          SemiCheckboxGroup(
            onChanged: log.add,
            children: const [SemiCheckbox(label: 'solo')],
          ),
        ),
      );
      await tester.tap(find.text('solo'));
      await tester.pump();
      expect(log, isEmpty);
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
    });

    testWidgets('injection priority: checked/type/disabled', (tester) async {
      final t = resolved();
      // checked: group value wins over the child's own checked/defaultChecked.
      await tester.pumpWidget(
        host(
          const SemiCheckboxGroup(
            value: ['a'],
            children: [
              SemiCheckbox(label: 'A', value: 'a', checked: false),
              SemiCheckbox(label: 'B', value: 'b', defaultChecked: true),
            ],
          ),
        ),
      );
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      // The tick belongs to row A (above row B).
      expect(
        tester.getCenter(iconFinder(SemiIcons.checkboxTick)).dy,
        lessThan(tester.getCenter(find.text('B')).dy),
      );

      // type: the group's card type overrides the child's normal type.
      await tester.pumpWidget(
        host(
          const SemiCheckboxGroup(
            type: SemiCheckboxType.card,
            children: [SemiCheckbox(label: 'A', value: 'a')],
          ),
        ),
      );
      expect(find.byKey(SemiCheckbox.outerBoxKey), findsOneWidget);
      expect(
        cardDecoration(tester).borderRadius,
        BorderRadius.circular(t.radiusCheckboxCardType),
      );

      // disabled: group OR child.
      await tester.pumpWidget(
        host(
          const SemiCheckboxGroup(
            disabled: true,
            children: [SemiCheckbox(label: 'A', value: 'a')],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
      expect(
        tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(SemiCheckbox),
                matching: find.byType(Focus),
              ),
            )
            .canRequestFocus,
        isFalse,
      );
    });

    testWidgets('child then group notification order and stopPropagation', (
      tester,
    ) async {
      final order = <String>[];
      await tester.pumpWidget(
        host(
          SemiCheckboxGroup(
            onChanged: (_) => order.add('group'),
            children: [
              SemiCheckbox(
                label: 'A',
                value: 'a',
                onChanged: (_) => order.add('child'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(order, ['child', 'group']);

      order.clear();
      await tester.pumpWidget(
        host(
          SemiCheckboxGroup(
            onChanged: (_) => order.add('group'),
            children: [
              SemiCheckbox(
                label: 'A',
                value: 'a',
                onChanged: (e) {
                  order.add('child');
                  e.stopPropagation();
                },
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(order, ['child']);
    });

    testWidgets('controlled group value syncs and resets on release', (
      tester,
    ) async {
      final log = <List<Object>>[];
      Widget build(List<Object>? value) => host(
        SemiCheckboxGroup(
          value: value,
          onChanged: log.add,
          options: const [
            SemiCheckboxOption(label: 'A', value: 'a'),
            SemiCheckboxOption(label: 'B', value: 'b'),
          ],
        ),
      );
      await tester.pumpWidget(build(const ['a']));
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      await tester.pumpWidget(build(const ['a', 'b']));
      expect(iconFinder(SemiIcons.checkboxTick), findsNWidgets(2));
      // Controlled clicks only notify.
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, [
        ['b'],
      ]);
      expect(iconFinder(SemiIcons.checkboxTick), findsNWidgets(2));
      // Releasing control resets to empty (upstream handlePropValueChange).
      await tester.pumpWidget(build(null));
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, [
        ['b'],
        ['a'],
      ]);
    });

    testWidgets('preventDefault vetoes the uncontrolled group mutation', (
      tester,
    ) async {
      final log = <List<Object>>[];
      await tester.pumpWidget(
        host(
          SemiCheckboxGroup(
            onChanged: log.add,
            children: [
              SemiCheckbox(
                label: 'A',
                value: 'a',
                onChanged: (e) => e.preventDefault(),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(log, isEmpty);
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
    });
  });

  group('keyboard, focus, hit target, RTL, text scaling', () {
    testWidgets('Space and Enter toggle', (tester) async {
      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', autofocus: true)),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(iconFinder(SemiIcons.checkboxTick), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
    });

    testWidgets('focus ring is keyboard-gated and clicks clear it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', autofocus: true)),
      );
      await tester.pump();
      // Mouse/focus-without-keys paints no ring.
      expect(boxDecoration(tester).boxShadow, isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(boxDecoration(tester).boxShadow, hasLength(1));
      expect(
        boxDecoration(tester).boxShadow!.single.color,
        resolved().colorCheckboxPrimaryOutlineFocus,
      );
      expect(
        boxDecoration(tester).boxShadow!.single.spreadRadius,
        resolved().widthCheckboxOutline,
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(boxDecoration(tester).boxShadow, isNull);
    });

    testWidgets('card focus ring paints on the outer frame', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiCheckbox(
            label: 'A',
            autofocus: true,
            type: SemiCheckboxType.card,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(cardDecoration(tester).boxShadow, hasLength(1));
      expect(boxDecoration(tester).boxShadow, isNull);
    });

    testWidgets('disabled checkbox is not focusable and ignores taps', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiCheckbox(label: 'A', disabled: true, autofocus: true)),
      );
      await tester.pump();
      expect(
        tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(SemiCheckbox),
                matching: find.byType(Focus),
              ),
            )
            .canRequestFocus,
        isFalse,
      );
      await tester.tap(find.text('A'), warnIfMissed: false);
      await tester.pump();
      expect(iconFinder(SemiIcons.checkboxTick), findsNothing);
    });

    testWidgets('the whole row (label and extra) is the click target', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        host(
          SemiCheckbox(
            label: 'A',
            extra: 'extra line',
            onChanged: (_) => count++,
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('extra line'));
      await tester.pump();
      await tester.tap(find.byKey(SemiCheckbox.innerBoxKey));
      await tester.pump();
      expect(count, 3);
    });

    testWidgets('RTL mirrors the row without overflow', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiCheckbox(label: SizedBox(width: 40, height: 20)),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
      // RTL flips the Row: the check box sits at the right edge of the row.
      expect(
        tester.getTopRight(find.byKey(SemiCheckbox.innerBoxKey)).dx,
        tester.getTopRight(find.byType(SemiCheckbox)).dx,
      );
      expect(
        tester.getCenter(find.byKey(SemiCheckbox.innerBoxKey)).dx,
        greaterThan(tester.getCenter(find.byType(SemiCheckbox)).dx),
      );
    });

    testWidgets('text scaling keeps the row overflow-free', (tester) async {
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: 120,
                child: const SemiCheckbox(
                  label: '很长很长很长很长很长很长的标签文字',
                  extra: '很长很长很长很长很长很长的副标题文字',
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('theme fields (60 + 6)', () {
    test('66 fields: merge, copyWith, resolve, equality', () {
      expect(fields, hasLength(66));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(6),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(60),
      );
      for (final (sass, value, make, read) in fields) {
        final patch = make(value);
        expect(const SemiCheckboxThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final defaults = const SemiCheckboxThemeData().resolve(
          const SemiThemeData.light(),
        );
        expect(read(defaults), isNotNull, reason: sass);
        final overridden = const SemiCheckboxThemeData().resolve(
          const SemiThemeData.dark(),
        );
        expect(read(overridden), isNotNull, reason: sass);
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_checkbox_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(66));
    });

    test('type coverage: 36 Color + 22 double + 2 FontWeight + 4 Duration'
        ' + 2 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 36);
      expect(counts['double'], 22);
      expect(counts['FontWeight'], 2);
      expect(counts['Duration'], 4);
      // Curves.bounceIn is a ParametricCurve.
      expect(fields.where((f) => f.$2 is Curve), hasLength(2));
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().checkbox,
        const SemiCheckboxThemeData(),
      );
      const patch = SemiCheckboxThemeData(
        colorCheckboxCheckedBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(checkbox: patch);
      expect(const SemiComponentThemes().copyWith(checkbox: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.checkbox, patch);
    });

    testWidgets('SemiCheckboxTheme local patch applies to the check box', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiCheckboxTheme(
            data: const SemiCheckboxThemeData(
              colorCheckboxCheckedBgDefault: Color(0xff00ff00),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiCheckboxTheme(
                  data: const SemiCheckboxThemeData(radiusCheckboxInner: 5),
                  child: const SemiCheckbox(label: 'x', checked: true),
                ),
              ),
            ),
          ),
        ),
      );
      final deco = boxDecoration(tester);
      // Nested local patches merge; the inner patch wins its own field only.
      expect(deco.color, const Color(0xff00ff00));
      expect(deco.borderRadius, BorderRadius.circular(5));
    });
  });
}
