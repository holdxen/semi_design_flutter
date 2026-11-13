// Behavior matrix for SemiSwitch plus coverage for the 66 Sass declarations
// (63 FIELDS + 3 MOTION + 0 INTERNAL) — the 8 HARDCODES provenance anchors
// live in the widget's `_SwitchMetrics` / call sites.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Center(child: child),
      ),
    ),
  );
}

Finder track() => find.byKey(SemiSwitch.trackKey);

SemiResolvedSwitchThemeData resolved([SemiThemeData? theme]) =>
    const SemiSwitchThemeData().resolve(theme ?? const SemiThemeData.light());

/// The track frame decoration: the 1px border + the focus ring (foreground
/// paint over the background edge).
BoxDecoration trackFrameDecoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(track()).decoration as BoxDecoration;

/// The animated track background color decoration.
BoxDecoration trackColorDecoration(WidgetTester tester) =>
    tester
            .widget<AnimatedContainer>(
              find.descendant(
                of: track(),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .decoration!
        as BoxDecoration;

/// The knob: the only AnimatedPositioned in the track (the spin slot and the
/// text slots are plain Positioned / PositionedDirectional — upstream knob
/// transitions, spin/text jump).
Finder knob() =>
    find.descendant(of: track(), matching: find.byType(AnimatedPositioned));

Finder spinSlot() =>
    find.ancestor(of: find.byType(SemiSpin), matching: find.byType(Positioned));

BoxDecoration knobDecoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(of: knob(), matching: find.byType(DecoratedBox)),
            )
            .decoration
        as BoxDecoration;

Future<void> focusSwitch(WidgetTester tester) async {
  tester
      .widget<Focus>(
        find.descendant(
          of: find.byType(SemiSwitch),
          matching: find.byType(Focus),
        ),
      )
      .focusNode!
      .requestFocus();
  await tester.pump();
}

bool ringPresent(WidgetTester tester) {
  final shadows = trackFrameDecoration(tester).boxShadow;
  return shadows != null &&
      shadows.isNotEmpty &&
      shadows.first.color == resolved().colorSwitchPrimaryOutlineFocus;
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

typedef _Patch = SemiSwitchThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedSwitchThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

/// All 66 upstream declarations: 63 FIELDS (variables.scss, incl. the
/// Duration-typed `$motion-switch-transitionDuration`) + 3 MOTION
/// (animation.scss). INTERNAL is empty (no transform token upstream).
final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-switch_default-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchDefaultBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDefaultBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-switch_default-bg-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchDefaultBgHover: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDefaultBgHover,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-switch_default-bg-active: var(--semi-color-fill-2)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchDefaultBgActive: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDefaultBgActive,
    (SemiThemeData theme) => theme.colors.colorFill2,
  ),
  (
    r'$color-switch_default-border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchDefaultBorderDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDefaultBorderDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-switch_checked-bg-default: var(--semi-color-success)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchCheckedBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchCheckedBgDefault,
    (SemiThemeData theme) => theme.colors.colorSuccess,
  ),
  (
    r'$color-switch_checked-bg-hover: var(--semi-color-success-hover)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchCheckedBgHover: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchCheckedBgHover,
    (SemiThemeData theme) => theme.colors.colorSuccessHover,
  ),
  (
    r'$color-switch_checked-bg-active: var(--semi-color-success-active)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchCheckedBgActive: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchCheckedBgActive,
    (SemiThemeData theme) => theme.colors.colorSuccessActive,
  ),
  (
    r'$color-switch_disabled-bg-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchDisabledBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDisabledBgDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-switch_disabled-bg-hover: transparent',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchDisabledBgHover: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDisabledBgHover,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-switch_disabled-bg-active: transparent',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchDisabledBgActive: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDisabledBgActive,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-switch_disabled-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchDisabledBorderDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchDisabledBorderDefault,
    (SemiThemeData theme) => theme.colors.colorBorder,
  ),
  (
    r'$color-switch_checked_disabled-bg-default: var(--semi-color-success-disabled)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchCheckedDisabledBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchCheckedDisabledBgDefault,
    (SemiThemeData theme) => theme.colors.colorSuccessDisabled,
  ),
  (
    r'$color-switch_checked_disabled-border-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(
      colorSwitchCheckedDisabledBorderDefault: v as Color,
    ),
    (SemiResolvedSwitchThemeData d) =>
        d.colorSwitchCheckedDisabledBorderDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-switch_knob-bg-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchKnobBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchKnobBgDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-switch_knob-bg-checked: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchKnobBgChecked: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchKnobBgChecked,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-switch_knob-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) => SemiSwitchThemeData(colorSwitchKnobBorderDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchKnobBorderDefault,
    (SemiThemeData theme) => theme.colors.colorBorder,
  ),
  (
    r'$color-switch_checked-text-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchCheckedTextDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchCheckedTextDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-switch_unchecked-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchUncheckedTextDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchUncheckedTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-switch_loading_spin-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchLoadingSpinDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchLoadingSpinDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-switch_spin_checked-bg-default: var(--semi-color-success-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchSpinCheckedBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchSpinCheckedBgDefault,
    (SemiThemeData theme) => theme.colors.colorSuccessHover,
  ),
  (
    r'$color-switch_spin_unchecked-bg-default: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchSpinUncheckedBgDefault: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchSpinUncheckedBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-switch_primary-outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiSwitchThemeData(colorSwitchPrimaryOutlineFocus: v as Color),
    (SemiResolvedSwitchThemeData d) => d.colorSwitchPrimaryOutlineFocus,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightActive,
  ),
  (
    r'$spacing-switch_unchecked-translateX: 2px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchUncheckedTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchUncheckedTranslateX,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-switch_spin_unchecked-translateX: 2px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchSpinUncheckedTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchSpinUncheckedTranslateX,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-switch_checked-translateX: 18px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchCheckedTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchCheckedTranslateX,
    (SemiThemeData theme) => 18.0,
  ),
  (
    r'$spacing-switch_spin_checked-translateX: 16px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchSpinCheckedTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchSpinCheckedTranslateX,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$spacing-switch_expand_large-translateX: 10px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchExpandLargeTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchExpandLargeTranslateX,
    (SemiThemeData theme) => 10.0,
  ),
  (
    r'$spacing-switch_unchecked_large-translateX: 3px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchUncheckedLargeTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchUncheckedLargeTranslateX,
    (SemiThemeData theme) => 3.0,
  ),
  (
    r'$spacing-switch_spin_unchecked_large-translateX: 2px',
    4.5,
    (Object v) => SemiSwitchThemeData(
      spacingSwitchSpinUncheckedLargeTranslateX: v as double,
    ),
    (SemiResolvedSwitchThemeData d) =>
        d.spacingSwitchSpinUncheckedLargeTranslateX,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-switch_checked_large-translateX: 26px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchCheckedLargeTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchCheckedLargeTranslateX,
    (SemiThemeData theme) => 26.0,
  ),
  (
    r'$spacing-switch_spin_checked_large-translateX: 22px',
    4.5,
    (Object v) => SemiSwitchThemeData(
      spacingSwitchSpinCheckedLargeTranslateX: v as double,
    ),
    (SemiResolvedSwitchThemeData d) =>
        d.spacingSwitchSpinCheckedLargeTranslateX,
    (SemiThemeData theme) => 22.0,
  ),
  (
    r'$spacing-switch_expand_small-translateX: 2px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchExpandSmallTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchExpandSmallTranslateX,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-switch_unchecked_small-translateX: 1px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchUncheckedSmallTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchUncheckedSmallTranslateX,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$spacing-switch_spin_unchecked_small-translateX: 2px',
    4.5,
    (Object v) => SemiSwitchThemeData(
      spacingSwitchSpinUncheckedSmallTranslateX: v as double,
    ),
    (SemiResolvedSwitchThemeData d) =>
        d.spacingSwitchSpinUncheckedSmallTranslateX,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-switch_checked_small-translateX: 11px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchCheckedSmallTranslateX: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchCheckedSmallTranslateX,
    (SemiThemeData theme) => 11.0,
  ),
  (
    r'$spacing-switch_spin_checked_small-translateX: 10px',
    4.5,
    (Object v) => SemiSwitchThemeData(
      spacingSwitchSpinCheckedSmallTranslateX: v as double,
    ),
    (SemiResolvedSwitchThemeData d) =>
        d.spacingSwitchSpinCheckedSmallTranslateX,
    (SemiThemeData theme) => 10.0,
  ),
  (
    r'$spacing-switch_knob-padding: 2px',
    4.5,
    (Object v) => SemiSwitchThemeData(spacingSwitchKnobPadding: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchKnobPadding,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-switch_knob_large-padding: 3px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchKnobLargePadding: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchKnobLargePadding,
    (SemiThemeData theme) => 3.0,
  ),
  (
    r'$spacing-switch_knob_small-padding: 1px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(spacingSwitchKnobSmallPadding: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchKnobSmallPadding,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$spacing-switch_knob-left: 0px',
    4.5,
    (Object v) => SemiSwitchThemeData(spacingSwitchKnobLeft: v as double),
    (SemiResolvedSwitchThemeData d) => d.spacingSwitchKnobLeft,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$width-switch: 40px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitch: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitch,
    (SemiThemeData theme) => 40.0,
  ),
  (
    r'$width-switch_knob_expand: 6px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobExpand: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobExpand,
    (SemiThemeData theme) => 6.0,
  ),
  (
    r'$width-switch_knob_default: 18px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobDefault: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobDefault,
    (SemiThemeData theme) => 18.0,
  ),
  (
    r'$width-switch_knob_active: $width-switch_knob_default + $width-switch_knob_expand',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobActive: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobActive,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$width-switch_large: 54px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchLarge: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchLarge,
    (SemiThemeData theme) => 54.0,
  ),
  (
    r'$width-switch_knob_large: 24px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobLarge: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobLarge,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$width-switch_knob_large_active: $width-switch_knob_large + $spacing-switch_expand_large-translateX',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobLargeActive: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobLargeActive,
    (SemiThemeData theme) => 34.0,
  ),
  (
    r'$width-switch_small: 26px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchSmall: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchSmall,
    (SemiThemeData theme) => 26.0,
  ),
  (
    r'$width-switch_knob_large_small: 12px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobLargeSmall: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobLargeSmall,
    (SemiThemeData theme) => 12.0,
  ),
  (
    r'$width-switch_knob_small_active: $width-switch_knob_large_small + $spacing-switch_expand_small-translateX',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchKnobSmallActive: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobSmallActive,
    (SemiThemeData theme) => 14.0,
  ),
  (
    r'$width-switch_knob_disabled-border: 1px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(widthSwitchKnobDisabledBorder: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchKnobDisabledBorder,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-switch_checked_unchecked_text: 26px',
    4.5,
    (Object v) =>
        SemiSwitchThemeData(widthSwitchCheckedUncheckedText: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchCheckedUncheckedText,
    (SemiThemeData theme) => 26.0,
  ),
  (
    r'$width-switch_spin-small: 10px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchSpinSmall: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchSpinSmall,
    (SemiThemeData theme) => 10.0,
  ),
  (
    r'$width-switch_spin-default: 18px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchSpinDefault: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchSpinDefault,
    (SemiThemeData theme) => 18.0,
  ),
  (
    r'$width-switch_spin-large: 28px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchSpinLarge: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchSpinLarge,
    (SemiThemeData theme) => 28.0,
  ),
  (
    r'$width-switch-outline: 2px',
    4.5,
    (Object v) => SemiSwitchThemeData(widthSwitchOutline: v as double),
    (SemiResolvedSwitchThemeData d) => d.widthSwitchOutline,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$height-switch: 24px',
    4.5,
    (Object v) => SemiSwitchThemeData(heightSwitch: v as double),
    (SemiResolvedSwitchThemeData d) => d.heightSwitch,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$height-switch_large: 32px',
    4.5,
    (Object v) => SemiSwitchThemeData(heightSwitchLarge: v as double),
    (SemiResolvedSwitchThemeData d) => d.heightSwitchLarge,
    (SemiThemeData theme) => 32.0,
  ),
  (
    r'$height-switch_small: 16px',
    4.5,
    (Object v) => SemiSwitchThemeData(heightSwitchSmall: v as double),
    (SemiResolvedSwitchThemeData d) => d.heightSwitchSmall,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$radius-switch: $height-switch * 0.5',
    4.5,
    (Object v) => SemiSwitchThemeData(radiusSwitch: v as double),
    (SemiResolvedSwitchThemeData d) => d.radiusSwitch,
    (SemiThemeData theme) => 12.0,
  ),
  (
    r'$radius-switch_large: $height-switch_large * 0.5',
    4.5,
    (Object v) => SemiSwitchThemeData(radiusSwitchLarge: v as double),
    (SemiResolvedSwitchThemeData d) => d.radiusSwitchLarge,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$radius-switch_small: $height-switch_small * 0.5',
    4.5,
    (Object v) => SemiSwitchThemeData(radiusSwitchSmall: v as double),
    (SemiResolvedSwitchThemeData d) => d.radiusSwitchSmall,
    (SemiThemeData theme) => 8.0,
  ),
  (
    // ★ Duration-typed FIELDS entry — it lives in variables.scss, not
    // animation.scss (the knob width/transform transition).
    r'$motion-switch-transitionDuration: 200ms',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiSwitchThemeData(motionSwitchTransitionDuration: v as Duration),
    (SemiResolvedSwitchThemeData d) => d.motionSwitchTransitionDuration,
    (SemiThemeData theme) => const Duration(milliseconds: 200),
  ),
  (
    r'$transition_duration-switch-bg: 200ms',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiSwitchThemeData(transitionDurationSwitchBg: v as Duration),
    (SemiResolvedSwitchThemeData d) => d.transitionDurationSwitchBg,
    (SemiThemeData theme) => const Duration(milliseconds: 200),
  ),
  (
    r'$transition_function-switch-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiSwitchThemeData(transitionFunctionSwitchBg: v as Curve),
    (SemiResolvedSwitchThemeData d) => d.transitionFunctionSwitchBg,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-switch-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiSwitchThemeData(transitionDelaySwitchBg: v as Duration),
    (SemiResolvedSwitchThemeData d) => d.transitionDelaySwitchBg,
    (SemiThemeData theme) => Duration.zero,
  ),
];

void main() {
  group('geometry', () {
    testWidgets('three sizes: track/knob/radius/top/translate', (tester) async {
      const cases = [
        // size, trackW, trackH, radius, knobW, knobTop, uncheckedTx, checkedTx
        (SemiSwitchSize.normal, 40.0, 24.0, 12.0, 18.0, 2.0, 2.0, 18.0),
        (SemiSwitchSize.large, 54.0, 32.0, 16.0, 24.0, 3.0, 3.0, 26.0),
        (SemiSwitchSize.small, 26.0, 16.0, 8.0, 12.0, 1.0, 1.0, 11.0),
      ];
      for (final (size, tw, th, radius, kw, top, utx, ctx) in cases) {
        for (final checked in [false, true]) {
          await tester.pumpWidget(
            host(SemiSwitch(size: size, checked: checked)),
          );
          await tester.pumpAndSettle();
          final trackRect = tester.getRect(track());
          expect(trackRect.size, Size(tw, th), reason: '$size/$checked');
          expect(
            trackFrameDecoration(tester).borderRadius,
            BorderRadius.circular(radius),
          );
          final knobRect = tester.getRect(knob());
          expect(knobRect.size, Size(kw, kw));
          expect(knobRect.top - trackRect.top, top);
          expect(knobRect.left - trackRect.left, checked ? ctx : utx);
          // Knob radius = knob width / 2 (constant — the pressed knob keeps
          // it while only the width stretches).
          expect(
            (knobDecoration(tester).borderRadius! as BorderRadius).topLeft,
            Radius.circular(kw / 2),
          );
        }
      }
    });
  });

  group('toggle', () {
    testWidgets('tap flips: uncontrolled lands and reports', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        host(SemiSwitch(defaultChecked: false, onChanged: log.add)),
      );
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 2.0);
      await tester.tap(track());
      await tester.pumpAndSettle();
      expect(log, [true]);
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 18.0);
      await tester.tap(track());
      await tester.pumpAndSettle();
      expect(log, [true, false]);
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 2.0);
    });

    testWidgets('Space toggles; Enter does not', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(host(SemiSwitch(onChanged: log.add)));
      await focusSwitch(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(log, [true]);
      // ★ Enter does NOT toggle (native checkbox semantics).
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(log, [true]);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(log, [true, false]);
    });

    testWidgets('controlled notifies only; display follows the prop', (
      tester,
    ) async {
      final log = <bool>[];
      await tester.pumpWidget(
        host(SemiSwitch(checked: false, onChanged: log.add)),
      );
      await tester.tap(track());
      await tester.pumpAndSettle();
      // Reports the toggled value but does not land (foundation.ts:33-34).
      expect(log, [true]);
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 2.0);
      // Display follows the prop.
      await tester.pumpWidget(
        host(SemiSwitch(checked: true, onChanged: log.add)),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 18.0);
      // ★ Releasing control keeps the last controlled value (rating
      // semi_rating.dart:122-129).
      await tester.pumpWidget(host(SemiSwitch(onChanged: log.add)));
      await tester.pumpAndSettle();
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 18.0);
    });
  });

  group('disabled and loading', () {
    testWidgets('disabled blocks tap and is unfocusable', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        host(SemiSwitch(disabled: true, onChanged: log.add)),
      );
      await tester.tap(track());
      await tester.pumpAndSettle();
      expect(log, isEmpty);
      expect(
        tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(SemiSwitch),
                matching: find.byType(Focus),
              ),
            )
            .canRequestFocus,
        isFalse,
      );
    });

    testWidgets('loading blocks tap and is unfocusable', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        host(SemiSwitch(loading: true, onChanged: log.add)),
      );
      await tester.tap(track());
      await tester.pump();
      expect(log, isEmpty);
      expect(
        tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(SemiSwitch),
                matching: find.byType(Focus),
              ),
            )
            .canRequestFocus,
        isFalse,
      );
    });

    testWidgets('disabled knob: 1px border + shadow-0; checked+disabled bg', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiSwitch(disabled: true)));
      var knobDeco = knobDecoration(tester);
      final knobBorder = knobDeco.border! as Border;
      expect(knobBorder.top.width, resolved().widthSwitchKnobDisabledBorder);
      expect(knobBorder.top.color, resolved().colorSwitchKnobBorderDefault);
      expect(knobDeco.boxShadow, isEmpty);
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchDisabledBgDefault,
      );
      expect(
        (trackFrameDecoration(tester).border! as Border).top.color,
        resolved().colorSwitchDisabledBorderDefault,
      );
      await tester.pumpWidget(
        host(const SemiSwitch(disabled: true, checked: true)),
      );
      knobDeco = knobDecoration(tester);
      // checked+disabled: knob `border: none` and still shadow-0.
      expect(knobDeco.border, isNull);
      expect(knobDeco.boxShadow, isEmpty);
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchCheckedDisabledBgDefault,
      );
      expect(
        (trackFrameDecoration(tester).border! as Border).top.color,
        resolved().colorSwitchCheckedDisabledBorderDefault,
      );
    });

    testWidgets('loading renders SemiSpin in the knob slot with the '
        'width-switch_spin-* geometry', (tester) async {
      // No pumpAndSettle — the spin rotates forever.
      await tester.pumpWidget(host(const SemiSwitch(loading: true)));
      expect(find.byType(SemiSpin), findsOneWidget);
      expect(
        tester.widget<SemiSpin>(find.byType(SemiSpin)).size,
        SemiSpinSize.middle,
      );
      expect(
        tester.widget<SemiIcon>(find.byType(SemiIcon)).customSize,
        resolved().widthSwitchSpinDefault,
      );
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchSpinUncheckedBgDefault,
      );
      final trackRect = tester.getRect(track());
      final slot = tester.getRect(spinSlot());
      // Unchecked spin translate 2, vertically centered.
      expect(
        slot.left - trackRect.left,
        resolved().spacingSwitchSpinUncheckedTranslateX,
      );
      expect(slot.top - trackRect.top, (24 - 18) / 2);
      await tester.pumpWidget(
        host(const SemiSwitch(loading: true, checked: true)),
      );
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchSpinCheckedBgDefault,
      );
      expect(
        tester.getRect(spinSlot()).left - trackRect.left,
        resolved().spacingSwitchSpinCheckedTranslateX,
      );
      // Size mapping: small/large (index.tsx:154).
      await tester.pumpWidget(
        host(
          const SemiSwitch(
            loading: true,
            checked: false,
            size: SemiSwitchSize.small,
          ),
        ),
      );
      expect(
        tester.widget<SemiSpin>(find.byType(SemiSpin)).size,
        SemiSpinSize.small,
      );
      expect(
        tester.widget<SemiIcon>(find.byType(SemiIcon)).customSize,
        resolved().widthSwitchSpinSmall,
      );
      expect(
        tester.getRect(spinSlot()).left - tester.getRect(track()).left,
        resolved().spacingSwitchSpinUncheckedSmallTranslateX,
      );
      await tester.pumpWidget(
        host(const SemiSwitch(loading: true, size: SemiSwitchSize.large)),
      );
      expect(
        tester.widget<SemiSpin>(find.byType(SemiSpin)).size,
        SemiSpinSize.large,
      );
      expect(
        tester.widget<SemiIcon>(find.byType(SemiIcon)).customSize,
        resolved().widthSwitchSpinLarge,
      );
    });
  });

  group('hover', () {
    testWidgets('hover deepens the track (fill-1 / success-hover)', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiSwitch()));
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchDefaultBgDefault,
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(track()));
      await tester.pumpAndSettle();
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchDefaultBgHover,
      );
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchDefaultBgDefault,
      );
      await tester.pumpWidget(host(const SemiSwitch(checked: true)));
      await gesture.moveTo(tester.getCenter(track()));
      await tester.pumpAndSettle();
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchCheckedBgHover,
      );
    });

    testWidgets('hover does not deepen when disabled or loading', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiSwitch(disabled: true)));
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(track()));
      await tester.pumpAndSettle();
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchDisabledBgDefault,
      );
      await tester.pumpWidget(host(const SemiSwitch(loading: true)));
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(track()));
      await tester.pump();
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchSpinUncheckedBgDefault,
      );
    });
  });

  group('pressed', () {
    testWidgets('knob widens to the active width; checked translate shifts '
        'back; ★checked-pressed bg stays success', (tester) async {
      await tester.pumpWidget(host(const SemiSwitch()));
      // Touch (not mouse): a hovered press would legitimately show the hover
      // bg (`:hover` + `:active` upstream composition).
      var gesture = await tester.startGesture(tester.getCenter(track()));
      await tester.pumpAndSettle();
      expect(tester.getRect(knob()).width, 24.0);
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 2.0);
      // Unchecked-pressed border -> fill-2 (`color-switch_default-bg-active`).
      expect(
        (trackFrameDecoration(tester).border! as Border).top.color,
        resolved().colorSwitchDefaultBgActive,
      );
      // `:active` touches only the border — the unchecked bg stays fill-0.
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchDefaultBgDefault,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getRect(knob()).width, 18.0);

      await tester.pumpWidget(host(const SemiSwitch(checked: true)));
      gesture = await tester.startGesture(tester.getCenter(track()));
      await tester.pumpAndSettle();
      expect(tester.getRect(knob()).width, 24.0);
      // Checked-pressed translate 18 - 6 = 12 (`spacingSwitchCheckedTranslateX
      // - widthSwitchKnobExpand`).
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 12.0);
      // ★ The checked-pressed track BACKGROUND stays `success` (the `&-active`
      // field is effectively dead, 上游未消费).
      expect(
        trackColorDecoration(tester).color,
        resolved().colorSwitchCheckedBgDefault,
      );
      expect(
        (trackFrameDecoration(tester).border! as Border).top.color,
        resolved().colorSwitchDefaultBgActive,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 18.0);
    });

    testWidgets('pressed knob widths per size (24/34/14) and small/large '
        'checked translate back (16/9)', (tester) async {
      const cases = [
        // size, pressedKnobW, pressedCheckedTx
        (SemiSwitchSize.normal, 24.0, 12.0),
        (SemiSwitchSize.large, 34.0, 16.0),
        (SemiSwitchSize.small, 14.0, 9.0),
      ];
      for (final (size, pressedW, pressedTx) in cases) {
        await tester.pumpWidget(host(SemiSwitch(size: size, checked: true)));
        await tester.pumpAndSettle();
        // Touch (not mouse): a hovered press would show the hover bg.
        final gesture = await tester.startGesture(tester.getCenter(track()));
        await tester.pumpAndSettle();
        expect(tester.getRect(knob()).width, pressedW, reason: '$size');
        expect(
          tester.getRect(knob()).left - tester.getRect(track()).left,
          pressedTx,
          reason: '$size',
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }
    });
  });

  group('texts', () {
    testWidgets('checked/unchecked texts are mutually exclusive and '
        'side-positioned', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiSwitch(
            checked: true,
            checkedText: 'On',
            uncheckedText: 'Off',
          ),
        ),
      );
      expect(find.text('On'), findsOneWidget);
      expect(find.text('Off'), findsNothing);
      final trackRect = tester.getRect(track());
      // Checked text at the start side (20px box centered content).
      expect(tester.getCenter(find.text('On')).dx, trackRect.left + 10);
      await tester.pumpWidget(
        host(
          const SemiSwitch(
            checked: false,
            checkedText: 'On',
            uncheckedText: 'Off',
          ),
        ),
      );
      expect(find.text('On'), findsNothing);
      expect(find.text('Off'), findsOneWidget);
      // Unchecked text at the end side (`right: 0` upstream).
      expect(tester.getCenter(find.text('Off')).dx, trackRect.right - 10);
    });

    testWidgets('small renders neither text', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiSwitch(
            size: SemiSwitchSize.small,
            checked: true,
            checkedText: 'On',
            uncheckedText: 'Off',
          ),
        ),
      );
      expect(find.text('On'), findsNothing);
      expect(find.text('Off'), findsNothing);
    });

    testWidgets('text colors (white/text-2) and font sizes (12 default, '
        '14 large)', (tester) async {
      await tester.pumpWidget(
        host(const SemiSwitch(checked: true, checkedText: 'On')),
      );
      var style = tester.widget<Text>(find.text('On')).style!;
      expect(style.color, resolved().colorSwitchCheckedTextDefault);
      expect(style.fontSize, 12.0);
      await tester.pumpWidget(
        host(const SemiSwitch(checked: false, uncheckedText: 'Off')),
      );
      style = tester.widget<Text>(find.text('Off')).style!;
      expect(style.color, resolved().colorSwitchUncheckedTextDefault);
      expect(style.fontSize, 12.0);
      // Large: 26px box (`width-switch_checked_unchecked_text`), 14px text.
      await tester.pumpWidget(
        host(
          const SemiSwitch(
            size: SemiSwitchSize.large,
            checked: true,
            checkedText: 'On',
          ),
        ),
      );
      style = tester.widget<Text>(find.text('On')).style!;
      expect(style.fontSize, 14.0);
      expect(
        tester.getCenter(find.text('On')).dx,
        tester.getRect(track()).left + 13,
      );
    });
  });

  group('focus ring and blur', () {
    testWidgets('the ring is keyboard-gated and taps clear it', (tester) async {
      await tester.pumpWidget(host(const SemiSwitch()));
      await focusSwitch(tester);
      // Mouse-free programmatic focus draws no ring before any key press.
      expect(ringPresent(tester), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(ringPresent(tester), isTrue);
      final shadows = trackFrameDecoration(tester).boxShadow!;
      expect(shadows.first.spreadRadius, resolved().widthSwitchOutline);
      expect(shadows.first.color, resolved().colorSwitchPrimaryOutlineFocus);
      // Tap clears the keyboard gate (no ring after mouse interaction).
      await tester.tap(track());
      await tester.pumpAndSettle();
      expect(ringPresent(tester), isFalse);
    });

    testWidgets('blur clears the ring before firing onBlur (order)', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(
          SemiSwitch(
            onBlur: () {
              // ★ index.tsx:126-129 order: `foundation.handleBlur()` clears
              // the ring state (setState) BEFORE `props.onBlur` runs — the
              // switch's element is already marked dirty (queued to rebuild
              // with the cleared ring) when the callback fires. Finder
              // .evaluate is tester-guard-free (focus changes fire inside the
              // pump's TestAsyncUtils guard).
              final element = find.byType(SemiSwitch).evaluate().first;
              log.add(
                element.dirty ? 'ring-cleared-then-blur' : 'blur-before-clear',
              );
            },
          ),
        ),
      );
      await focusSwitch(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(ringPresent(tester), isTrue);
      final outside = FocusNode(debugLabel: 'outside', skipTraversal: true);
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemiSwitch(
                onBlur: () {
                  final element = find.byType(SemiSwitch).evaluate().first;
                  log.add(
                    element.dirty
                        ? 'ring-cleared-then-blur'
                        : 'blur-before-clear',
                  );
                },
              ),
              Focus(focusNode: outside, child: const SizedBox()),
            ],
          ),
        ),
      );
      await focusSwitch(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(ringPresent(tester), isTrue);
      outside.requestFocus();
      await tester.pump();
      await tester.pump();
      expect(log, ['ring-cleared-then-blur']);
      expect(ringPresent(tester), isFalse);
      outside.dispose();
    });
  });

  group('RTL', () {
    testWidgets('knob translates negate and texts swap sides', (tester) async {
      await tester.pumpWidget(
        host(const SemiSwitch(checked: true), direction: TextDirection.rtl),
      );
      final trackRect = tester.getRect(track());
      // Checked knob at the end side: 40 - 18 - 18 = 4 (mirrored).
      expect(tester.getRect(knob()).left - trackRect.left, 4.0);
      await tester.pumpWidget(
        host(const SemiSwitch(checked: false), direction: TextDirection.rtl),
      );
      await tester.pumpAndSettle();
      // Unchecked: 40 - 2 - 18 = 20.
      expect(tester.getRect(knob()).left - trackRect.left, 20.0);
      // Texts swap sides: checked text to the visual right (directional
      // start), unchecked text to the visual left (directional end).
      await tester.pumpWidget(
        host(
          const SemiSwitch(checked: true, checkedText: 'On'),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.getCenter(find.text('On')).dx, trackRect.right - 10);
      await tester.pumpWidget(
        host(
          const SemiSwitch(checked: false, uncheckedText: 'Off'),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.getCenter(find.text('Off')).dx, trackRect.left + 10);
    });

    testWidgets('loading spin translates negate in RTL', (tester) async {
      await tester.pumpWidget(
        host(const SemiSwitch(loading: true), direction: TextDirection.rtl),
      );
      final trackRect = tester.getRect(track());
      // Unchecked spin anchored at the end side + 2px mirror inset.
      expect(
        trackRect.right - tester.getRect(spinSlot()).right,
        resolved().spacingSwitchSpinUncheckedTranslateX,
      );
      await tester.pumpWidget(
        host(
          const SemiSwitch(loading: true, checked: true),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        trackRect.right - tester.getRect(spinSlot()).right,
        resolved().spacingSwitchSpinCheckedTranslateX,
      );
    });
  });

  group('semantics', () {
    testWidgets('toggled value; enabled=!disabled (★loading not reflected)', (
      tester,
    ) async {
      SemanticsNode node() => tester.getSemantics(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.toggled != null,
        ),
      );
      await tester.pumpWidget(host(const SemiSwitch(checked: true)));
      expect(node().flagsCollection.isToggled, ui.Tristate.isTrue);
      expect(node().flagsCollection.isEnabled, ui.Tristate.isTrue);
      await tester.pumpWidget(host(const SemiSwitch(checked: false)));
      expect(node().flagsCollection.isToggled, ui.Tristate.isFalse);
      // ★ loading is NOT reflected (upstream `aria-disabled={disabled}`).
      await tester.pumpWidget(host(const SemiSwitch(loading: true)));
      expect(node().flagsCollection.isEnabled, ui.Tristate.isTrue);
      await tester.pumpWidget(host(const SemiSwitch(disabled: true)));
      expect(node().flagsCollection.isEnabled, ui.Tristate.isFalse);
    });
  });

  group('theme fields (63 + 3 + 0)', () {
    test('66 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(66));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(3),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(63),
      );
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiSwitchThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiSwitchThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiSwitchThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_switch_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(66));
      // The one duplicated declaration notes both declaration lines.
      expect(
        source,
        contains('Declared twice (variables.scss lines 27 and 30'),
      );
    });

    test('the 8 HARDCODES anchors live in the widget', () {
      final widgetSource = File('lib/src/components/semi_switch.dart')
          .readAsStringSync();
      const anchors = [
        'box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 0 1px rgba(0, 0, 0, 0.3);',
        'box-shadow: none;',
        'width: 20px',
        'ease-in-out',
        r'$border-thickness-control: 1px',
        r'$font-size-small: 12px',
        r'$font-size-regular: 14px',
        'display: flex; justify-content: center; align-items: center;',
      ];
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
      // The effectively-dead field is never consumed (net effect faithful).
      expect(widgetSource, isNot(contains('colorSwitchCheckedBgActive')));
    });

    test('type coverage: 22 Color + 40 double + 3 Duration + 1 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 22);
      expect(counts['double'], 40);
      expect(counts['Duration'], 3);
      expect(fields.where((f) => f.$2 is Curve), hasLength(1));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().switcher, const SemiSwitchThemeData());
      const patch = SemiSwitchThemeData(
        colorSwitchCheckedBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(switcher: patch);
      expect(const SemiComponentThemes().copyWith(switcher: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.switcher, patch);
    });

    testWidgets('SemiSwitchTheme local patch applies (nested merge, inner '
        'wins its own field)', (tester) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiSwitchTheme(
            data: const SemiSwitchThemeData(widthSwitchKnobDefault: 24),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiSwitchTheme(
                  data: const SemiSwitchThemeData(
                    spacingSwitchCheckedTranslateX: 30,
                  ),
                  child: const SemiSwitch(checked: true),
                ),
              ),
            ),
          ),
        ),
      );
      // Outer patch field (knob width) still applies; the inner patch wins
      // its own field (checked translate) only.
      expect(tester.getSize(knob()), const Size(24, 24));
      expect(tester.getRect(knob()).left - tester.getRect(track()).left, 30.0);
    });
  });
}
