// Behavior matrix for SemiSlider plus coverage for the 61 Sass declarations
// (57 FIELDS + 3 MOTION + 1 INTERNAL) — the identity transform scale and the
// 5 HARDCODES provenance anchors live in the widget's `_SliderMetrics`.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Horizontal rail length for a 300-wide slider: 300 - 2*13 padding.
const double railLen = 274;

/// The host body is served through a notifier: `initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (and the
/// subtree element identity survives `pumpWidget` for didUpdateWidget).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  _hostBody.value = child;
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Overlay(
          // The handle tooltips insert overlay entries when they show.
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(child: child),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A 300-wide horizontal slider box (13px X padding -> 274px rail).
Widget boxed(Widget slider) => SizedBox(width: 300, child: slider);

Finder handle(int index) => find.byKey(SemiSlider.handleKey(index));
Finder rail() => find.byKey(SemiSlider.railKey);

SemiResolvedSliderThemeData resolved([SemiThemeData? theme]) =>
    const SemiSliderThemeData().resolve(theme ?? const SemiThemeData.light());

/// The fill track: the DecoratedBox carrying the resolved track color.
Finder track() => find.descendant(
  of: find.byType(SemiSlider),
  matching: find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).color ==
            resolved().colorSliderTrackBgDefault,
  ),
);

/// Step/mark dots: 4px circle Containers (`width-slider_dot`).
Finder dots() => find.descendant(
  of: find.byType(SemiSlider),
  matching: find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.constraints?.maxWidth == resolved().widthSliderDot &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle,
  ),
);

Color dotColor(WidgetTester tester, int index) =>
    (tester.widget<Container>(dots().at(index)).decoration as BoxDecoration)
        .color!;

BoxDecoration handleDecoration(WidgetTester tester, int index) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: handle(index),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

SemiTooltip handleTooltip(WidgetTester tester, int index) =>
    tester.widget<SemiTooltip>(
      find.descendant(of: handle(index), matching: find.byType(SemiTooltip)),
    );

double valueToX(
  WidgetTester tester,
  double value, {
  double min = 0,
  double max = 100,
}) {
  final r = tester.getRect(rail());
  return r.left + (value - min) / (max - min) * r.width;
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Focus a handle without any pointer interaction (no session side effects).
Future<void> focusHandle(WidgetTester tester, int index) async {
  final focus = tester.widget<Focus>(
    find.descendant(
      of: handle(index),
      matching: find.byWidgetPredicate(
        (w) => w is Focus && w.onKeyEvent != null && w.onFocusChange != null,
      ),
    ),
  );
  focus.focusNode!.requestFocus();
  await tester.pump();
}

/// The overlay entry body is served through a notifier (the select/autocomplete
/// harness pattern) so the tooltip popup can be inspected.
final _body = ValueNotifier<Widget>(const SizedBox.shrink());

Widget _app(Widget body) {
  _body.value = body;
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _body,
                builder: (context, body, _) =>
                    Center(child: SizedBox(width: 300, child: body)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

typedef _Patch = SemiSliderThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedSliderThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

/// All 61 upstream declarations: 60 theme fields (57 FIELDS + 3 MOTION) with
/// patch/read/default hooks, plus the 1 INTERNAL row (widget `_SliderMetrics`).
final List<(String, Object, _Patch?, _Read?, _Default?)> fields = [
  (
    r'$color-slider-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderTextDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderTextDefault,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-slider_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiSliderThemeData(colorSliderDisabledTextDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderDisabledTextDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledText,
  ),
  (
    r'$color-slider_dot-bg-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderDotBgDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderDotBgDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-slider_dot-border-active: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderDotBorderActive: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderDotBorderActive,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-slider_dot-border: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderDotBorder: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderDotBorder,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-slider_handle-bg-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderHandleBgDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleBgDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-slider_handle-bg-hover: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderHandleBgHover: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleBgHover,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-slider_handle-border-focus: var(--semi-color-focus-border)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderHandleBorderFocus: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleBorderFocus,
    (SemiThemeData theme) => theme.colors.colorFocusBorder,
  ),
  (
    r'$color-slider_handle_disabled-border-hover: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiSliderThemeData(colorSliderHandleDisabledBorderHover: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleDisabledBorderHover,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-slider_handle_disabled-border: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiSliderThemeData(colorSliderHandleDisabledBorder: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleDisabledBorder,
    (SemiThemeData theme) => theme.colors.colorBorder,
  ),
  (
    r'$color-slider_mark-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderMarkTextDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderMarkTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-slider_rail-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderRailBgDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderRailBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-slider_rail: rgba(0, 0, 0, 0.65)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderRail: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderRail,
    (SemiThemeData theme) => const Color(0xa6000000),
  ),
  (
    r'$color-slider_track-bg-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderTrackBgDefault: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderTrackBgDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-slider_track_disabled-bg: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderTrackDisabledBg: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderTrackDisabledBg,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-slider_handle-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderHandleFocus: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleFocus,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightActive,
  ),
  (
    r'$color-slider_handle_dot: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiSliderThemeData(colorSliderHandleDot: v as Color),
    (SemiResolvedSliderThemeData d) => d.colorSliderHandleDot,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$spacing-slider-paddingX: 13px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderPaddingX: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderPaddingX,
    (SemiThemeData theme) => 13.0,
  ),
  (
    r'$spacing-slider-paddingY: 0px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderPaddingY: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderPaddingY,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider-margin: 0px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderMargin: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderMargin,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_rail-margin: 0px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderRailMargin: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderRailMargin,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_rail-padding: 0px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderRailPadding: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderRailPadding,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_rail-top: 14px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderRailTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderRailTop,
    (SemiThemeData theme) => 14.0,
  ),
  (
    r'$spacing-slider_handle-marginTop: 4px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderHandleMarginTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderHandleMarginTop,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-slider_track-top: 14px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderTrackTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderTrackTop,
    (SemiThemeData theme) => 14.0,
  ),
  (
    r'$spacing-slider_tooltip-top: -40px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderTooltipTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderTooltipTop,
    (SemiThemeData theme) => -40.0,
  ),
  (
    r'$spacing-slider_dot-top: 14px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderDotTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderDotTop,
    (SemiThemeData theme) => 14.0,
  ),
  (
    r'$spacing-slider_marks-top: 23px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderMarksTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderMarksTop,
    (SemiThemeData theme) => 23.0,
  ),
  (
    r'$spacing-slider_marks-left: 0px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderMarksLeft: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderMarksLeft,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_boundary-top: 30px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderBoundaryTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderBoundaryTop,
    (SemiThemeData theme) => 30.0,
  ),
  (
    r'$spacing-slider_boundary_min-left: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderBoundaryMinLeft: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderBoundaryMinLeft,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_boundary_max-right: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderBoundaryMaxRight: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderBoundaryMaxRight,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_vertical_marks-marginTop: -30px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalMarksMarginTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalMarksMarginTop,
    (SemiThemeData theme) => -30.0,
  ),
  (
    r'$spacing-slider_vertical_marks-marginLeft: 29px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalMarksMarginLeft: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalMarksMarginLeft,
    (SemiThemeData theme) => 29.0,
  ),
  (
    r'$spacing-slider_vertical_marks-reverse-marginLeft: -26px',
    4.5,
    (Object v) => SemiSliderThemeData(
      spacingSliderVerticalMarksReverseMarginLeft: v as double,
    ),
    (SemiResolvedSliderThemeData d) =>
        d.spacingSliderVerticalMarksReverseMarginLeft,
    (SemiThemeData theme) => -26.0,
  ),
  (
    r'$spacing-slider_vertical_rail-top: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalRailTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalRailTop,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_vertical_handle-marginTop: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalHandleMarginTop: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalHandleMarginTop,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_vertical_handle-marginLeft: -10px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalHandleMarginLeft: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalHandleMarginLeft,
    (SemiThemeData theme) => -10.0,
  ),
  (
    r'$spacing-slider_handle-translateY: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderHandleTranslateY: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderHandleTranslateY,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_vertical_handle-translateX: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalHandleTranslateX: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalHandleTranslateX,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_dot-translateX: 0px',
    4.5,
    (Object v) => SemiSliderThemeData(spacingSliderDotTranslateX: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderDotTranslateX,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-slider_vertical_dot-translateY: 0px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(spacingSliderVerticalDotTranslateY: v as double),
    (SemiResolvedSliderThemeData d) => d.spacingSliderVerticalDotTranslateY,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$radius-slider_rail: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiSliderThemeData(radiusSliderRail: v as double),
    (SemiResolvedSliderThemeData d) => d.radiusSliderRail,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-slider_track: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiSliderThemeData(radiusSliderTrack: v as double),
    (SemiResolvedSliderThemeData d) => d.radiusSliderTrack,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$height-slider_wrapper: 32px',
    4.5,
    (Object v) => SemiSliderThemeData(heightSliderWrapper: v as double),
    (SemiResolvedSliderThemeData d) => d.heightSliderWrapper,
    (SemiThemeData theme) => 32.0,
  ),
  (
    r'$height-slider_vertical_wrapper: 4px',
    4.5,
    (Object v) => SemiSliderThemeData(heightSliderVerticalWrapper: v as double),
    (SemiResolvedSliderThemeData d) => d.heightSliderVerticalWrapper,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$height-slider_rail: 4px',
    4.5,
    (Object v) => SemiSliderThemeData(heightSliderRail: v as double),
    (SemiResolvedSliderThemeData d) => d.heightSliderRail,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$width-slider_handle: 24px',
    4.5,
    (Object v) => SemiSliderThemeData(widthSliderHandle: v as double),
    (SemiResolvedSliderThemeData d) => d.widthSliderHandle,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$width-slider_handle_clicked: 1px',
    4.5,
    (Object v) => SemiSliderThemeData(widthSliderHandleClicked: v as double),
    (SemiResolvedSliderThemeData d) => d.widthSliderHandleClicked,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$height-slider_track: 4px',
    4.5,
    (Object v) => SemiSliderThemeData(heightSliderTrack: v as double),
    (SemiResolvedSliderThemeData d) => d.heightSliderTrack,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$width-slider_dot: 4px',
    4.5,
    (Object v) => SemiSliderThemeData(widthSliderDot: v as double),
    (SemiResolvedSliderThemeData d) => d.widthSliderDot,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$width-slider_handle_border_disabled: 1px',
    4.5,
    (Object v) =>
        SemiSliderThemeData(widthSliderHandleBorderDisabled: v as double),
    (SemiResolvedSliderThemeData d) => d.widthSliderHandleBorderDisabled,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-slider_handle-focus: 2px',
    4.5,
    (Object v) => SemiSliderThemeData(widthSliderHandleFocus: v as double),
    (SemiResolvedSliderThemeData d) => d.widthSliderHandleFocus,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$width-slider_handle_dot: 4px',
    4.5,
    (Object v) => SemiSliderThemeData(widthSliderHandleDot: v as double),
    (SemiResolvedSliderThemeData d) => d.widthSliderHandleDot,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$font-slider_rail-fontSize: 14px',
    4.5,
    (Object v) => SemiSliderThemeData(fontSliderRailFontSize: v as double),
    (SemiResolvedSliderThemeData d) => d.fontSliderRailFontSize,
    (SemiThemeData theme) => theme.typography.fontSizeRegular,
  ),
  (
    r'$font-slider_marks-fontSize: 14px',
    4.5,
    (Object v) => SemiSliderThemeData(fontSliderMarksFontSize: v as double),
    (SemiResolvedSliderThemeData d) => d.fontSliderMarksFontSize,
    (SemiThemeData theme) => theme.typography.fontSizeRegular,
  ),
  (
    r'$font-slider_rail-lineHeight: 1.5',
    4.5,
    (Object v) => SemiSliderThemeData(fontSliderRailLineHeight: v as double),
    (SemiResolvedSliderThemeData d) => d.fontSliderRailLineHeight,
    (SemiThemeData theme) => 1.5,
  ),
  (
    r'$transition_duration-slider_handle-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiSliderThemeData(transitionDurationSliderHandleBg: v as Duration),
    (SemiResolvedSliderThemeData d) => d.transitionDurationSliderHandleBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-slider_handle-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiSliderThemeData(transitionFunctionSliderHandleBg: v as Curve),
    (SemiResolvedSliderThemeData d) => d.transitionFunctionSliderHandleBg,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-slider_handle-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiSliderThemeData(transitionDelaySliderHandleBg: v as Duration),
    (SemiResolvedSliderThemeData d) => d.transitionDelaySliderHandleBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    // The 61st declaration is widget-internal (`_SliderMetrics`), not a
    // theme field: no patch/read/default hooks.
    r'$transform_scale-slider_handle: var(--semi-transform_scale-small)',
    1.0,
    null,
    null,
    null,
  ),
];

void main() {
  group('value model and output rounding', () {
    testWidgets('drag output rounds to whole numbers (step 1)', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(SemiSlider(defaultValue: 100, max: 274, onChanged: log.add)),
        ),
      );
      final gesture = await startMouse(tester);
      final c = tester.getCenter(handle(0));
      await gesture.moveTo(c);
      await gesture.down(c);
      await gesture.moveBy(const Offset(33, 0));
      await gesture.up();
      await tester.pump();
      // 133.0 lands exactly; drag a fractional position and it rounds.
      expect(log, [133.0]);
      log.clear();
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await gesture.moveBy(const Offset(50, 0));
      await gesture.up();
      await tester.pump();
      expect(log, [183.0]);
    });

    testWidgets('outPutValue rounds to the step decimals (step 0.1 -> 1)', (
      tester,
    ) async {
      // ★ foundation.ts:420-447: multiplier = 10^decimals(step); the
      // keyboard path does not snap, only rounds (0.35 + 0.1 -> 0.45 -> 0.5).
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              defaultValue: 0.35,
              min: 0,
              max: 1,
              step: 0.1,
              onChanged: log.add,
            ),
          ),
        ),
      );
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(log, [0.5]);
    });

    testWidgets('step snap is relative to 0 (min=5 step=10 -> 10)', (
      tester,
    ) async {
      // ★ foundation.ts:349-351: `value = (v / step).round() * step` on the
      // 0-relative grid, then clamp — 5.95 snaps to 10 (not to a 5+10 grid
      // point like 15).
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              min: 5,
              max: 100,
              step: 10,
              defaultValue: 5,
              onChanged: log.add,
            ),
          ),
        ),
      );
      await tester.tapAt(
        Offset(valueToX(tester, 6), tester.getRect(rail()).center.dy),
      );
      await tester.pump();
      expect(log, [10.0]);
    });

    testWidgets('range onChange output is sorted ascending', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [100.0, 200.0],
              max: 274,
              onChanged: log.add,
            ),
          ),
        ),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.up();
      await tester.pump();
      expect(log, [
        [130.0, 200.0],
      ]);
    });
  });

  group('drag', () {
    testWidgets('press does not jump the handle; the offset is preserved', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(boxed(const SemiSlider(defaultValue: 100, max: 274))),
      );
      final c = tester.getCenter(handle(0));
      final gesture = await startMouse(tester);
      // Press off-center: the captured offset keeps the handle under the
      // pointer delta instead of snapping to the cursor.
      await gesture.moveTo(c + const Offset(5, 0));
      await gesture.down(c + const Offset(5, 0));
      await tester.pump();
      expect(tester.getCenter(handle(0)), c);
      await gesture.moveBy(const Offset(50, 0));
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      expect(
        tester.getCenter(handle(0)).dx,
        moreOrLessEquals(c.dx + 51, epsilon: 0.01),
      );
      await gesture.up();
      await tester.pump();
    });

    testWidgets('drag emits onChanged, then onMouseUp and onAfterChange', (
      tester,
    ) async {
      final events = <String>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              defaultValue: 100,
              max: 274,
              onChanged: (v) => events.add('change:$v'),
              onMouseUp: () => events.add('up'),
              onAfterChange: (v) => events.add('after:$v'),
            ),
          ),
        ),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pump();
      expect(events, ['change:140.0', 'change:150.0', 'up', 'after:150.0']);
    });

    testWidgets('dragging min past max collapses both to [max, max]', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [100.0, 200.0],
              max: 274,
              onChanged: log.add,
            ),
          ),
        ),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await gesture.moveBy(const Offset(150, 0));
      await tester.pump();
      // ★ handles may cross; the pass collapses both onto the stationary one.
      expect(log, [
        [200.0, 200.0],
      ]);
      expect(tester.getCenter(handle(0)), tester.getCenter(handle(1)));
      // Dragging back below the collapse point recovers the pair.
      await gesture.moveBy(const Offset(-80, 0));
      await tester.pump();
      expect(log, [
        [200.0, 200.0],
        [170.0, 200.0],
      ]);
      await gesture.up();
      await tester.pump();
    });

    testWidgets('dragging max past min collapses both to [min, min]', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [100.0, 200.0],
              max: 274,
              onChanged: log.add,
            ),
          ),
        ),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(1)));
      await gesture.down(tester.getCenter(handle(1)));
      await gesture.moveBy(const Offset(-150, 0));
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      expect(log.last, [100.0, 100.0]);
      expect(tester.getCenter(handle(0)), tester.getCenter(handle(1)));
      await gesture.up();
      await tester.pump();
    });

    testWidgets('controlled drag follows live; the prop snaps it back', (
      tester,
    ) async {
      final events = <String>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              value: 100.0,
              max: 274,
              onChanged: (v) => events.add('change:$v'),
              onAfterChange: (v) => events.add('after:$v'),
            ),
          ),
        ),
      );
      final c = tester.getCenter(handle(0));
      final gesture = await startMouse(tester);
      await gesture.moveTo(c);
      await gesture.down(c);
      await gesture.moveBy(const Offset(50, 0));
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      // Foundation.ts:552: the handle follows the drag live even controlled.
      expect(
        tester.getCenter(handle(0)).dx,
        moreOrLessEquals(c.dx + 51, epsilon: 0.01),
      );
      await gesture.up();
      await tester.pump();
      // The controlled value renders again on release (no landing).
      expect(tester.getCenter(handle(0)), c);
      expect(events, ['change:150.0', 'change:151.0', 'after:151.0']);
    });

    testWidgets('external controlled value changes fire onAfterChange', (
      tester,
    ) async {
      // ★ index.tsx:315 quirk: `trigger onAfterChange when value is
      // controlled and changed`.
      final events = <String>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              value: 30.0,
              onAfterChange: (v) => events.add('after:$v'),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              value: 60.0,
              onAfterChange: (v) => events.add('after:$v'),
            ),
          ),
        ),
      );
      expect(events, ['after:60.0']);
      // The handle snaps to the new prop value.
      expect(tester.getCenter(handle(0)).dx, valueToX(tester, 60));
    });
  });

  group('click', () {
    testWidgets('rail click jumps the nearest handle', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [20.0, 60.0],
              onChanged: log.add,
            ),
          ),
        ),
      );
      final y = tester.getRect(rail()).center.dy;
      // 80 is nearer to the max handle (60) than to the min handle (20).
      await tester.tapAt(Offset(valueToX(tester, 80), y));
      await tester.pump();
      expect(log, [
        [20.0, 80.0],
      ]);
      await tester.tapAt(Offset(valueToX(tester, 10), y));
      await tester.pump();
      expect(log, [
        [20.0, 80.0],
        [10.0, 80.0],
      ]);
    });

    testWidgets('uncontrolled jump completes with onAfterChange', (
      tester,
    ) async {
      final events = <String>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              defaultValue: 30,
              onChanged: (v) => events.add('change:$v'),
              onAfterChange: (v) => events.add('after:$v'),
            ),
          ),
        ),
      );
      await tester.tapAt(
        Offset(valueToX(tester, 80), tester.getRect(rail()).center.dy),
      );
      await tester.pump();
      expect(events, ['change:80.0', 'after:80.0']);
    });

    testWidgets('controlled click only notifies, never jumps', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(boxed(SemiSlider(value: 30.0, onChanged: log.add))),
      );
      final c = tester.getCenter(handle(0));
      await tester.tapAt(
        Offset(valueToX(tester, 80), tester.getRect(rail()).center.dy),
      );
      await tester.pump();
      expect(log, [80.0]);
      expect(tester.getCenter(handle(0)), c);
    });

    testWidgets('mark labels jump the nearest handle', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              defaultValue: 20,
              marks: {20: 'A', 80: 'B'},
              onChanged: log.add,
            ),
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log, [80.0]);
    });
  });

  group('keyboard', () {
    testWidgets('arrows step by step and KeyRepeat repeats', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(boxed(SemiSlider(defaultValue: 10, step: 2, onChanged: log.add))),
      );
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(log, [12.0, 14.0, 16.0, 14.0, 12.0]);
    });

    testWidgets('RTL inverts arrows and Page keys, not Home/End', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(SemiSlider(defaultValue: 10, onChanged: log.add)),
          direction: TextDirection.rtl,
        ),
      );
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      // ★ arrows/Page are RTL-inverted; Home/End are not (min/max unchanged).
      expect(log, [11.0, 10.0, 0.0, 10.0, 0.0, 100.0]);
    });

    testWidgets('PageUp/PageDown move 10x step', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(boxed(SemiSlider(defaultValue: 50, onChanged: log.add))),
      );
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();
      expect(log, [60.0, 50.0, 40.0]);
    });

    testWidgets('Home/End single -> min/max; range collapses per handle', (
      tester,
    ) async {
      final log = <Object?>[];
      // Distinct keys: defaultValue only applies at initState.
      var n = 0;
      Widget single() => host(
        boxed(
          SemiSlider(
            key: ValueKey('single${n++}'),
            defaultValue: 30,
            onChanged: log.add,
          ),
        ),
      );
      Widget range() => host(
        boxed(
          SemiSlider(
            key: ValueKey('range${n++}'),
            range: true,
            defaultValue: [30.0, 70.0],
            onChanged: log.add,
          ),
        ),
      );
      // Single: Home -> min, End -> max.
      await tester.pumpWidget(single());
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(log, [0.0, 100.0]);
      // ★ 'min' End collapses both onto v1.
      log.clear();
      await tester.pumpWidget(range());
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(log, [
        [70.0, 70.0],
      ]);
      // ★ 'max' Home collapses both onto v0.
      log.clear();
      await tester.pumpWidget(range());
      await focusHandle(tester, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(log, [
        [30.0, 30.0],
      ]);
      // ★ 'min' Home -> [min, v1]; 'max' End -> [v0, max].
      log.clear();
      await tester.pumpWidget(range());
      await focusHandle(tester, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(log, [
        [0.0, 70.0],
      ]);
      log.clear();
      await tester.pumpWidget(range());
      await focusHandle(tester, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(log, [
        [30.0, 100.0],
      ]);
    });

    testWidgets('range keyboard collision clamps and no-ops (diff gate)', (
      tester,
    ) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [30.0, 35.0],
              onChanged: log.add,
            ),
          ),
        ),
      );
      await focusHandle(tester, 1);
      for (var i = 0; i < 10; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      }
      await tester.pump();
      // The handles may meet but never cross; further presses are no-ops.
      expect(log, [
        [30.0, 34.0],
        [30.0, 33.0],
        [30.0, 32.0],
        [30.0, 31.0],
        [30.0, 30.0],
      ]);
    });

    testWidgets(
      'KeyUp of a recognized key fires onMouseUp then onAfterChange',
      (tester) async {
        final events = <String>[];
        await tester.pumpWidget(
          host(
            boxed(
              SemiSlider(
                defaultValue: 10,
                onChanged: (v) => events.add('change:$v'),
                onMouseUp: () => events.add('up'),
                onAfterChange: (v) => events.add('after:$v'),
              ),
            ),
          ),
        );
        await focusHandle(tester, 0);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(events, ['change:11.0', 'up', 'after:11.0']);
        // Unrelated keys do nothing at all.
        events.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        expect(events, isEmpty);
      },
    );

    testWidgets('blur only fires when focus leaves the whole slider', (
      tester,
    ) async {
      // ★ index.tsx:204-209 `notifyBlur`: focus moving between the two range
      // handles stays inside the slider and is not a blur.
      final blurs = <int>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [30.0, 70.0],
              onBlur: () => blurs.add(1),
            ),
          ),
        ),
      );
      await focusHandle(tester, 0);
      await focusHandle(tester, 1);
      await tester.pump();
      expect(blurs, isEmpty);
      // Focus leaving the slider fires onBlur exactly once.
      final outside = FocusNode(debugLabel: 'outside', skipTraversal: true);
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              boxed(
                SemiSlider(
                  range: true,
                  defaultValue: [30.0, 70.0],
                  onBlur: () => blurs.add(1),
                ),
              ),
              Focus(focusNode: outside, child: const SizedBox()),
            ],
          ),
        ),
      );
      await focusHandle(tester, 0);
      outside.requestFocus();
      await tester.pump();
      await tester.pump();
      expect(blurs, [1]);
      outside.dispose();
    });

    testWidgets('focus ring is keyboard-gated and taps clear it', (
      tester,
    ) async {
      await tester.pumpWidget(host(boxed(const SemiSlider(defaultValue: 30))));
      await focusHandle(tester, 0);
      // Only the knob shadow before any key press.
      expect(handleDecoration(tester, 0).boxShadow, hasLength(2));
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      final shadows = handleDecoration(tester, 0).boxShadow!;
      // The 2px outline ring plus the 2 knob shadows.
      expect(shadows, hasLength(3));
      expect(shadows.first.color, resolved().colorSliderHandleFocus);
      expect(shadows.first.spreadRadius, resolved().widthSliderHandleFocus);
      await tester.tap(handle(0));
      await tester.pump();
      expect(handleDecoration(tester, 0).boxShadow!.first.spreadRadius, 0);
    });

    testWidgets('mouse press draws the 1px clicked border', (tester) async {
      await tester.pumpWidget(host(boxed(const SemiSlider(defaultValue: 30))));
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await tester.pump();
      final border = handleDecoration(tester, 0).border! as Border;
      expect(border.top.width, resolved().widthSliderHandleClicked);
      expect(border.top.color, resolved().colorSliderHandleBorderFocus);
      await gesture.up();
      await tester.pump();
      expect(handleDecoration(tester, 0).border, isNull);
    });
  });

  group('marks and dots', () {
    testWidgets('marks outside [min, max] are hidden', (tester) async {
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(defaultValue: 20, marks: {10: 'A', 40: 'B', 120: 'C'}),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsNothing);
      // Dots render for every in-range mark only.
      expect(dots(), findsNWidgets(2));
    });

    testWidgets('dot highlight follows isMarkActive and the included quirk', (
      tester,
    ) async {
      // Single + included: dots at/below the value are highlighted.
      await tester.pumpWidget(
        host(boxed(SemiSlider(defaultValue: 50, marks: {20: 'A', 80: 'B'}))),
      );
      expect(dotColor(tester, 0), resolved().colorSliderDotBorderActive);
      expect(dotColor(tester, 1), resolved().colorSliderDotBgDefault);
      // ★ single + included:false -> always un-highlighted.
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              defaultValue: 50,
              included: false,
              marks: {20: 'A', 80: 'B'},
            ),
          ),
        ),
      );
      expect(dotColor(tester, 0), resolved().colorSliderDotBgDefault);
      expect(dotColor(tester, 1), resolved().colorSliderDotBgDefault);
      // ★ range + included:false -> always highlighted.
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              range: true,
              defaultValue: [40.0, 60.0],
              included: false,
              marks: {20: 'A', 80: 'B'},
            ),
          ),
        ),
      );
      expect(dotColor(tester, 0), resolved().colorSliderDotBorderActive);
      expect(dotColor(tester, 1), resolved().colorSliderDotBorderActive);
    });

    testWidgets('included:false hides the fill track', (tester) async {
      await tester.pumpWidget(host(boxed(const SemiSlider(defaultValue: 50))));
      // Value 50/100 fills half of the 274px rail.
      expect(tester.getSize(track()).width, 137.0);
      await tester.pumpWidget(
        host(boxed(const SemiSlider(defaultValue: 50, included: false))),
      );
      expect(tester.getSize(track()).width, 0.0);
    });

    testWidgets('showMarkLabel false hides the labels', (tester) async {
      await tester.pumpWidget(
        host(boxed(SemiSlider(marks: {20: 'A'}, showMarkLabel: false))),
      );
      expect(find.text('A'), findsNothing);
      expect(dots(), findsOneWidget);
    });

    testWidgets('tooltipOnMark wraps each dot in a tooltip', (tester) async {
      await tester.pumpWidget(
        host(boxed(SemiSlider(marks: {20: 'A'}, tooltipOnMark: true))),
      );
      final tooltip = tester.widget<SemiTooltip>(
        find.ancestor(of: dots(), matching: find.byType(SemiTooltip)),
      );
      expect((tooltip.content as Text).data, 'A');
    });
  });

  group('tooltip', () {
    testWidgets('tooltipVisible true/false overrides the state machine', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(boxed(const SemiSlider(value: 33.0, tooltipVisible: true))),
      );
      expect(handleTooltip(tester, 0).visible, isTrue);
      await tester.pumpWidget(
        host(boxed(const SemiSlider(value: 33.0, tooltipVisible: false))),
      );
      expect(handleTooltip(tester, 0).visible, isFalse);
      // Hover does not override a forced false.
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await tester.pump();
      expect(handleTooltip(tester, 0).visible, isFalse);
    });

    testWidgets('hover/drag shows the tooltip with the formatted content', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(boxed(const SemiSlider(value: 33.0, min: 0, max: 100, step: 1))),
      );
      expect(handleTooltip(tester, 0).visible, isFalse);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await tester.pump();
      expect(handleTooltip(tester, 0).visible, isTrue);
      // Default content is `'$value'` after outPutValue rounding.
      expect(((handleTooltip(tester, 0).content as Text).data), '33.0');
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(handleTooltip(tester, 0).visible, isFalse);
    });

    testWidgets('tipFormatter replaces the content; showArrow passes through', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              value: 33.0,
              showArrow: false,
              tipFormatter: (v) => 'v=$v',
              tooltipVisible: true,
            ),
          ),
        ),
      );
      expect((handleTooltip(tester, 0).content as Text).data, 'v=33.0');
      expect(handleTooltip(tester, 0).showArrow, isFalse);
    });

    testWidgets('showTooltip false hides every handle tooltip', (tester) async {
      await tester.pumpWidget(
        host(
          boxed(
            const SemiSlider(
              value: 33.0,
              showTooltip: false,
              tooltipVisible: true,
            ),
          ),
        ),
      );
      expect(handleTooltip(tester, 0).visible, isFalse);
    });
  });

  group('boundary', () {
    testWidgets('labels show only while hovered with showBoundary', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(boxed(const SemiSlider(min: 5, max: 50, showBoundary: true))),
      );
      expect(find.text('5.0'), findsNothing);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getRect(rail()).center);
      await tester.pump();
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('50.0'), findsOneWidget);
      // Hidden without showBoundary even while hovered.
      await tester.pumpWidget(host(boxed(const SemiSlider(min: 5, max: 50))));
      expect(find.text('5.0'), findsNothing);
    });
  });

  group('disabled', () {
    testWidgets('disabled blocks drag, click, keyboard and repaints', (
      tester,
    ) async {
      final events = <String>[];
      await tester.pumpWidget(
        host(
          boxed(
            SemiSlider(
              disabled: true,
              defaultValue: 30,
              marks: {30: 'A'},
              onChanged: (v) => events.add('change:$v'),
              onAfterChange: (v) => events.add('after:$v'),
            ),
          ),
        ),
      );
      // Drag does not start (no session end events either).
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await gesture.moveBy(const Offset(50, 0));
      await gesture.up();
      await tester.pump();
      // Click on the rail is a no-op.
      await tester.tapAt(
        Offset(valueToX(tester, 80), tester.getRect(rail()).center.dy),
      );
      await tester.pump();
      expect(events, isEmpty);
      expect(tester.getCenter(handle(0)).dx, valueToX(tester, 30));
      // Visuals: 1px disabled border and no shadow (shadow-0).
      final decoration = handleDecoration(tester, 0);
      final border = decoration.border! as Border;
      expect(border.top.width, resolved().widthSliderHandleBorderDisabled);
      expect(border.top.color, resolved().colorSliderHandleDisabledBorder);
      expect(decoration.boxShadow, isEmpty);
      // The disabled track fill color (`$color-slider_track_disabled-bg`).
      final disabledTrackFinder = find.descendant(
        of: find.byType(SemiSlider),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color ==
                  resolved().colorSliderTrackDisabledBg,
        ),
      );
      expect(tester.getSize(disabledTrackFinder).width, 82.2);
    });
  });

  group('vertical and verticalReverse', () {
    testWidgets('vertical maps values top-down; reverse flips the axis', (
      tester,
    ) async {
      Widget vertical({bool reverse = false, double value = 0}) => host(
        SizedBox(
          width: 40,
          height: 200,
          child: SemiSlider(
            vertical: true,
            verticalReverse: reverse,
            value: value,
          ),
        ),
      );
      await tester.pumpWidget(vertical(value: 0));
      var railRect = tester.getRect(rail());
      expect(railRect.height, 200.0);
      expect(
        tester.getCenter(handle(0)).dy,
        moreOrLessEquals(railRect.top, epsilon: 0.01),
      );
      await tester.pumpWidget(vertical(value: 100));
      expect(
        tester.getCenter(handle(0)).dy,
        moreOrLessEquals(railRect.top + 200, epsilon: 0.01),
      );
      // verticalReverse: min sits at the visual bottom.
      await tester.pumpWidget(vertical(value: 0, reverse: true));
      expect(
        tester.getCenter(handle(0)).dy,
        moreOrLessEquals(railRect.top + 200, epsilon: 0.01),
      );
      // The handle centers on the 4px rail (margin-left -10).
      expect(
        tester.getCenter(handle(0)).dx,
        moreOrLessEquals(railRect.left + 2, epsilon: 0.01),
      );
    });

    testWidgets('vertical drag moves along the cross axis', (tester) async {
      final log = <Object?>[];
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 40,
            height: 200,
            child: SemiSlider(
              vertical: true,
              defaultValue: 50,
              max: 200,
              onChanged: log.add,
            ),
          ),
        ),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(handle(0)));
      await gesture.down(tester.getCenter(handle(0)));
      await gesture.moveBy(const Offset(0, 40));
      await gesture.moveBy(const Offset(0, 1));
      await gesture.up();
      await tester.pump();
      expect(log, [90.0, 91.0]);
    });

    testWidgets('verticalReverse mark labels stay upright on the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 80,
            height: 200,
            child: SemiSlider(vertical: true, marks: {50: 'A'}),
          ),
        ),
      );
      var railRect = tester.getRect(rail());
      // Normal vertical: labels sit right of the rail (margin-left 29),
      // vertically centered on the mark.
      expect(
        tester.getCenter(find.text('A')).dx,
        moreOrLessEquals(railRect.left + 29, epsilon: 0.01),
      );
      // Label top edge at marksTop + verticalMarksMarginTop + pos (23-30+100).
      expect(
        tester.getTopLeft(find.text('A')).dy,
        moreOrLessEquals(railRect.top + 93, epsilon: 0.01),
      );
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 80,
            height: 200,
            child: SemiSlider(
              vertical: true,
              verticalReverse: true,
              marks: {50: 'A'},
            ),
          ),
        ),
      );
      // Reverse: labels move to the left side (margin-left -26).
      expect(
        tester.getCenter(find.text('A')).dx,
        moreOrLessEquals(railRect.left - 26, epsilon: 0.01),
      );
    });
  });

  group('geometry and semantics', () {
    testWidgets('horizontal geometry follows the scss', (tester) async {
      await tester.pumpWidget(
        host(boxed(SemiSlider(defaultValue: 50, marks: {50: 'A'}))),
      );
      final railRect = tester.getRect(rail());
      final sliderRect = tester.getRect(find.byType(SemiSlider));
      // Wrapper: 32 high with 13px X padding around the 274px rail.
      expect(railRect.width, railLen);
      expect(railRect.height, resolved().heightSliderRail);
      expect(sliderRect.height, resolved().heightSliderWrapper);
      expect(railRect.left - sliderRect.left, 13.0);
      // Handle 24x24 centered on the value and on the rail.
      expect(tester.getSize(handle(0)), const Size(24, 24));
      expect(tester.getCenter(handle(0)).dx, valueToX(tester, 50));
      expect(tester.getCenter(handle(0)).dy, railRect.center.dy);
      // Dot: 4x4 at top 14 (center y == rail center), x centered on the mark.
      expect(tester.getSize(dots().first), const Size(4, 4));
      expect(tester.getCenter(dots().first).dy, railRect.center.dy);
      expect(tester.getCenter(dots().first).dx, valueToX(tester, 50));
      // Marks at top 23 (top edge).
      expect(tester.getTopLeft(find.text('A')).dy, sliderRect.top + 23);
    });

    testWidgets('semantics: slider role, value text, disabled', (tester) async {
      await tester.pumpWidget(
        host(
          boxed(SemiSlider(value: 30.0, getAriaValueText: (v, i) => 'v$v-$i')),
        ),
      );
      final node = tester.getSemantics(
        find.descendant(
          of: handle(0),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.slider == true,
          ),
        ),
      );
      expect(node.flagsCollection.isSlider, isTrue);
      expect(node.value, 'v30.0-0');
      await tester.pumpWidget(
        host(boxed(const SemiSlider(value: 30.0, disabled: true))),
      );
      final disabledNode = tester.getSemantics(
        find.descendant(
          of: handle(0),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.slider == true,
          ),
        ),
      );
      expect(disabledNode.flagsCollection.isEnabled, ui.Tristate.isFalse);
    });
  });

  group('theme fields (57 + 3 + 1)', () {
    test('61 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(61));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(3),
      );
      expect(
        fields.where((f) => f.$1.startsWith(r'$transform_')),
        hasLength(1),
      );
      expect(
        fields.where(
          (f) =>
              !f.$1.startsWith(r'$transition_') &&
              !f.$1.startsWith(r'$transform_'),
        ),
        hasLength(57),
      );
      for (final (sass, value, make, read, expected) in fields) {
        if (make == null || read == null || expected == null) {
          // INTERNAL — `_SliderMetrics.transformScaleSliderHandle`.
          continue;
        }
        final patch = make(value);
        expect(const SemiSliderThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiSliderThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiSliderThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_slider_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        if (sass.startsWith(r'$transform_')) continue;
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(60));
    });

    test('the 1 INTERNAL and 5 HARDCODES anchors live in the widget', () {
      final widgetSource = File('lib/src/components/semi_slider.dart')
          .readAsStringSync();
      const anchors = [
        r'$transform_scale-slider_handle: var(--semi-transform_scale-small)',
        'box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 0 1px rgba(0, 0, 0, 0.3);',
        'box-shadow: none;',
        r'calc(${markPercent * 100}% - 2px)',
        "zIndex: chooseMovePos === 'min' && isDrag ? 2 : 1",
        r'font-size: $font-size-small',
      ];
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 17 Color + 40 double + 2 Duration + 1 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, make, _, _) in fields) {
        if (make == null) continue;
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 17);
      expect(counts['double'], 40);
      expect(counts['Duration'], 2);
      // Curves.bounceIn is a ParametricCurve.
      expect(fields.where((f) => f.$2 is Curve && f.$3 != null), hasLength(1));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().slider, const SemiSliderThemeData());
      const patch = SemiSliderThemeData(
        colorSliderHandleBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(slider: patch);
      expect(const SemiComponentThemes().copyWith(slider: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.slider, patch);
    });

    testWidgets('SemiSliderTheme local patch applies to the slider', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiSliderTheme(
            data: const SemiSliderThemeData(widthSliderHandle: 30),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiSliderTheme(
                  data: const SemiSliderThemeData(
                    colorSliderRailBgDefault: Color(0xff00ff00),
                  ),
                  child: boxed(const SemiSlider(defaultValue: 50)),
                ),
              ),
            ),
          ),
        ),
      );
      // Nested local patches merge; the inner patch wins its own field only.
      expect(tester.getSize(handle(0)), const Size(30, 30));
      expect(
        (tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: rail(),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration)
            .color,
        const Color(0xff00ff00),
      );
    });

    testWidgets(
      'a local patch applies and captures across the tooltip overlay',
      (tester) async {
        const patched = Color(0xff876543);
        await tester.pumpWidget(
          _app(
            SemiSliderTheme(
              data: const SemiSliderThemeData(
                colorSliderMarkTextDefault: patched,
              ),
              child: SemiSlider(
                value: 33.0,
                tooltipVisible: true,
                tipFormatter: (v) => Builder(
                  builder: (context) => Text(
                    'tip',
                    style: TextStyle(
                      color: SemiSliderTheme.of(context)
                          .colorSliderMarkTextDefault,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await _settle(tester);
        final tip = find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.text('tip'),
        );
        expect(tip, findsOneWidget);
        expect((tester.widget<Text>(tip).style)!.color, patched);
      },
    );
  });
}
