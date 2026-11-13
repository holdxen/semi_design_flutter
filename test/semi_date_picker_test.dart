// Behavior matrix for SemiDatePicker plus coverage for the 223 Sass
// declarations (220 FIELDS + 3 MOTION + 0 INTERNAL) — the 14 HARDCODES
// provenance anchors live in the widget's `_DatePickerMetrics` / call sites.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (the
/// semi_tag_input_test.dart host precedent — panels render into the overlay).
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
                builder: (context, child, _) =>
                    Center(child: SizedBox(width: 300, child: child)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String inputText(WidgetTester tester) => tester
    .widget<EditableText>(find.byType(EditableText).first)
    .controller
    .text;

List<String> inputTexts(WidgetTester tester) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .map((w) => w.controller.text)
    .toList();

String fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// The SemiTooltip popup needs a few frames to measure, position and run its
/// entrance motion before its content hit-tests reliably.
Future<void> settlePanel(WidgetTester tester) async {
  // The SemiTooltip popup needs a few frames to measure/position and its
  // entrance/exit motion to finish before content appears/disappears.
  await tester.pumpAndSettle(const Duration(milliseconds: 60));
}

/// Pump [host] on a tall test surface (the popup with presets exceeds the
/// default 800x600 window).
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) async {
  // No reset: `setSurfaceSize` asserts on the test zone, so the size stays
  // for every test in this file.
  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  await tester.pumpWidget(host(child, direction: direction));
}

/// Tap a year/month item of the yam picker (its lists scroll).
Future<void> tapYamItem(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await settlePanel(tester);
}

/// Open the panel by clicking the trigger (also focuses the start input for
/// range types — upstream handleTriggerWrapperClick).
Future<void> openPicker(WidgetTester tester) async {
  await tester.tap(find.byType(SemiInput).first);
  await settlePanel(tester);
}

SemiResolvedDatePickerThemeData resolved([SemiThemeData? theme]) =>
    const SemiDatePickerThemeData().resolve(
      theme ?? const SemiThemeData.light(),
    );

/// Decoration of a day cell's inner box (the day-main Container).
BoxDecoration dayDecoration(WidgetTester tester, DateTime day) =>
    tester
            .widget<Container>(
              find.descendant(
                of: find.byKey(SemiDatePicker.dayKey(day)),
                matching: find.byType(Container),
              ),
            )
            .decoration!
        as BoxDecoration;

/// Deep record-list comparison (`List` fields compare by identity under `==`).
void expectChange(
  List<(Object?, String?)> changes,
  List<(Object?, String?)> expected,
) {
  expect(changes, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(changes[i].$1, expected[i].$1);
    expect(changes[i].$2, expected[i].$2);
  }
}

/// The 7 weekday labels in display order (tree order).
List<String> weekdayLabels(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((w) => w.data ?? '')
    .where((s) => s.length == 1 && '日一二三四五六'.contains(s))
    .toList();

/// A minimal picker — every parameter mirrors SemiDatePicker's.
Widget picker({
  SemiDatePickerType type = SemiDatePickerType.date,
  Object? value,
  Object? defaultValue,
  String? format,
  bool Function(DateTime date, SemiDatePickerRangeInfo info)? disabledDate,
  SemiDatePickerChanged? onChanged,
  ValueChanged<bool>? onOpenChange,
  void Function(DateTime visibleDate, String text)? onPanelChange,
  VoidCallback? onClear,
  void Function(SemiDatePickerPreset preset)? onPresetClick,
  bool? open,
  bool defaultOpen = false,
  List<SemiDatePickerPreset> presets = const [],
  SemiDatePickerPresetPosition presetPosition =
      SemiDatePickerPresetPosition.bottom,
  String? presetHeader,
  int weekStartsOn = 0,
  bool autoSwitchDate = true,
  bool syncSwitchMonth = false,
  SemiInputSize size = SemiInputSize.normal,
  SemiInputStatus validateStatus = SemiInputStatus.normal,
  bool disabled = false,
  bool borderless = false,
  bool inputReadOnly = false,
  bool showClear = true,
  Object? placeholder,
  Object? prefix,
  String rangeSeparator = ' ~ ',
  SemiDatePickerController? controller,
}) => SemiDatePicker(
  type: type,
  value: value,
  defaultValue: defaultValue,
  format: format,
  disabledDate: disabledDate,
  onChanged: onChanged,
  onOpenChange: onOpenChange,
  onPanelChange: onPanelChange,
  onClear: onClear,
  onPresetClick: onPresetClick,
  open: open,
  defaultOpen: defaultOpen,
  presets: presets,
  presetPosition: presetPosition,
  presetHeader: presetHeader,
  weekStartsOn: weekStartsOn,
  autoSwitchDate: autoSwitchDate,
  syncSwitchMonth: syncSwitchMonth,
  size: size,
  validateStatus: validateStatus,
  disabled: disabled,
  borderless: borderless,
  inputReadOnly: inputReadOnly,
  showClear: showClear,
  placeholder: placeholder,
  prefix: prefix,
  rangeSeparator: rangeSeparator,
  controller: controller,
);

typedef _Patch = SemiDatePickerThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedDatePickerThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

/// All 223 upstream declarations: 220 FIELDS (variables.scss) + 3 MOTION
/// (animation.scss). INTERNAL is empty (no transform token upstream). Ten
/// FIELDS and the 3 MOTION tokens are upstream-dead (never consumed by the
/// widget); nine FIELDS are derived-chain-only (documented in the docs table).
final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$width-datepicker_day: 36px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(widthDatepickerDay: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerDay,
    (SemiThemeData theme) => 36,
  ),
  (
    r'$width-datepicker_day_main: 32px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(widthDatepickerDayMain: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerDayMain,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$width-datepicker_month: $width-datepicker_day * 7',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(widthDatepickerMonth: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerMonth,
    (SemiThemeData theme) => 252,
  ),
  (
    r'$width-datepicker_nav: 32px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(widthDatepickerNav: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerNav,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$height-datepicker_switch: 54px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(heightDatepickerSwitch: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerSwitch,
    (SemiThemeData theme) => 54,
  ),
  (
    r'$height-datepicker_timeType_yam: calc(100% - 54px)',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerTimeTypeYam: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerTimeTypeYam,
    (SemiThemeData theme) => 46,
  ),
  (
    r'$height-datepicker_timeType_tpk: calc(100% - 54px)',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerTimeTypeTpk: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerTimeTypeTpk,
    (SemiThemeData theme) => 46,
  ),
  (
    r'$height-datepicker_panel_yam_scrolllist: 266px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerPanelYamScrolllist: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerPanelYamScrolllist,
    (SemiThemeData theme) => 266,
  ),
  (
    r'$width-datepicker_monthPanel_max: 284px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerMonthPanelMax: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerMonthPanelMax,
    (SemiThemeData theme) => 284,
  ),
  (
    r'$width-datepicker_monthRangePanel_max: 384px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerMonthRangePanelMax: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerMonthRangePanelMax,
    (SemiThemeData theme) => 384,
  ),
  (
    r'$height-datepicker_timepicker_header_min: 24px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerTimepickerHeaderMin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerTimepickerHeaderMin,
    (SemiThemeData theme) => 24,
  ),
  (
    r'$width-datepicker_navigation_button_min: 32px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerNavigationButtonMin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerNavigationButtonMin,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$height-datepicker_yamShowing_min: 378px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerYamShowingMin: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerYamShowingMin,
    (SemiThemeData theme) => 378,
  ),
  (
    r'$width-datepicker_yamShowing_min: 284px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerYamShowingMin: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerYamShowingMin,
    (SemiThemeData theme) => 284,
  ),
  (
    r'$height-datepicker_dateType_yamShowing_min: 325px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerDateTypeYamShowingMin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerDateTypeYamShowingMin,
    (SemiThemeData theme) => 325,
  ),
  (
    r'$width-datepicker_panel_yam_scrolllist_li_min: 64px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPanelYamScrolllistLiMin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPanelYamScrolllistLiMin,
    (SemiThemeData theme) => 64,
  ),
  (
    r'$width-datepicker_presetPanel_left_and_right: 200px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelLeftAndRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelLeftAndRight,
    (SemiThemeData theme) => 200,
  ),
  (
    r'$height-datepicker_presetPanel_top_and_bottom_max: 100px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerPresetPanelTopAndBottomMax: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerPresetPanelTopAndBottomMax,
    (SemiThemeData theme) => 100,
  ),
  (
    r'$width-datepicker_presetPanel_scroll_bar: 15px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelScrollBar: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelScrollBar,
    (SemiThemeData theme) => 15,
  ),
  (
    r'$width-datepicker-border: $border-thickness-control',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(widthDatepickerBorder: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerBorder,
    (SemiThemeData theme) => 1,
  ),
  (
    r'$width-datepicker_yam_header-borderRadius: var(--semi-border-radius-medium)',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerYamHeaderBorderRadius: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerYamHeaderBorderRadius,
    (SemiThemeData theme) => theme.radius.borderRadiusMedium.value,
  ),
  (
    r'$width-datepicker_day_main-borderRadius: var(--semi-border-radius-small)',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerDayMainBorderRadius: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerDayMainBorderRadius,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$width-datepicker_quick_control-borderRadius: var(--semi-border-radius-medium)',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerQuickControlBorderRadius: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerQuickControlBorderRadius,
    (SemiThemeData theme) => theme.radius.borderRadiusMedium.value,
  ),
  (
    r'$width-datepicker_slot-border: 1px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerSlotBorder: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerSlotBorder,
    (SemiThemeData theme) => 1,
  ),
  (
    r'$width-datepicker_range_input-border: $border-thickness-control-focus',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerRangeInputBorder: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerRangeInputBorder,
    (SemiThemeData theme) => 1,
  ),
  (
    r'$width-datepicker_day_main-border: 1px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerDayMainBorder: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerDayMainBorder,
    (SemiThemeData theme) => 1,
  ),
  (
    r'$height-datepicker_timeType_insetInput_yam: 100%',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerTimeTypeInsetInputYam: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerTimeTypeInsetInputYam,
    (SemiThemeData theme) => 100,
  ),
  (
    r'$height-datepicker_timeType_insetInput_tpk: 100%',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerTimeTypeInsetInputTpk: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerTimeTypeInsetInputTpk,
    (SemiThemeData theme) => 100,
  ),
  (
    r'$width-datepicker_insetInput_date_type_wrapper: 284px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputDateTypeWrapper: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputDateTypeWrapper,
    (SemiThemeData theme) => 284,
  ),
  (
    r'$width-datepicker_insetInput_date_range_type_wrapper: $width-datepicker_insetInput_date_type_wrapper * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputDateRangeTypeWrapper: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputDateRangeTypeWrapper,
    (SemiThemeData theme) => 568,
  ),
  (
    r'$width-datepicker_insetInput_month_type_wrapper: 165px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputMonthTypeWrapper: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputMonthTypeWrapper,
    (SemiThemeData theme) => 165,
  ),
  (
    r'$width-datepicker_insetInput_month_range_type_wrapper: 331px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputMonthRangeTypeWrapper: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputMonthRangeTypeWrapper,
    (SemiThemeData theme) => 331,
  ),
  (
    r'$height-datepicker_insetInput_separator: 32px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerInsetInputSeparator: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerInsetInputSeparator,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$height-datepicker_month_grid_yearType_insetInput: 317px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerMonthGridYearTypeInsetInput: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerMonthGridYearTypeInsetInput,
    (SemiThemeData theme) => 317,
  ),
  (
    r'$height-datepicker_month_grid_timeType_insetInput: 317px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerMonthGridTimeTypeInsetInput: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerMonthGridTimeTypeInsetInput,
    (SemiThemeData theme) => 317,
  ),
  (
    r'$width-datepicker_range_trigger-border: 0px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerRangeTriggerBorder: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerRangeTriggerBorder,
    (SemiThemeData theme) => 0,
  ),
  (
    r'$spacing-datepicker_day-marginX: ($width-datepicker_day - $width-datepicker_day_main) * 0.5',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(spacingDatepickerDayMarginX: v as double),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerDayMarginX,
    (SemiThemeData theme) => 2,
  ),
  (
    r'$spacing-datepicker_yam_header-paddingX: $spacing-base',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerYamHeaderPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerYamHeaderPaddingX,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_yam_header-paddingY: $spacing-base-tight',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerYamHeaderPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerYamHeaderPaddingY,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_scrolllist_header-padding: $spacing-base',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerScrolllistHeaderPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerScrolllistHeaderPadding,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_scrolllist_body-padding: 0',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerScrolllistBodyPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerScrolllistBodyPadding,
    (SemiThemeData theme) => 0,
  ),
  (
    r'$spacing-datepicker_footer-paddingTop: 10px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(spacingDatepickerFooterPaddingTop: v as double),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerFooterPaddingTop,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_footer-paddingBottom: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterPaddingBottom: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterPaddingBottom,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_footer-paddingRight: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterPaddingRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterPaddingRight,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_footer_cancel_button-marginRight: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterCancelButtonMarginRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterCancelButtonMarginRight,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_footer_confirm_button-marginRight: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterConfirmButtonMarginRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterConfirmButtonMarginRight,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_navigation-paddingY: $spacing-base-tight',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerNavigationPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerNavigationPaddingY,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_navigation-paddingX: $spacing-base',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerNavigationPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerNavigationPaddingX,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_month-padding: $spacing-base',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(spacingDatepickerMonthPadding: v as double),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerMonthPadding,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_switch_datetime-paddingTop: $spacing-base',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerSwitchDatetimePaddingTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerSwitchDatetimePaddingTop,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_switch_datetime-paddingBottom: $spacing-base',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerSwitchDatetimePaddingBottom: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerSwitchDatetimePaddingBottom,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_switch_text-paddingLeft: $spacing-tight',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerSwitchTextPaddingLeft: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerSwitchTextPaddingLeft,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_quick_control_header-paddingTop: 18px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlHeaderPaddingTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlHeaderPaddingTop,
    (SemiThemeData theme) => 18,
  ),
  (
    r'$spacing-datepicker_quick_control_top_and_bottom_content-paddingX: $spacing-base-loose',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlTopAndBottomContentPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlTopAndBottomContentPaddingX,
    (SemiThemeData theme) => 20,
  ),
  (
    r'$spacing-datepicker_quick_control_content-paddingX: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlContentPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlContentPaddingX,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_quick_control_content-marginTop: 14px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlContentMarginTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlContentMarginTop,
    (SemiThemeData theme) => 14,
  ),
  (
    r'$spacing-datepicker_quick_control_item-margin: $spacing-tight',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlItemMargin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlItemMargin,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_range_input-paddingX: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputPaddingX,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_range_input-paddingY: 3px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputPaddingY,
    (SemiThemeData theme) => 3,
  ),
  (
    r'$spacing-datepicker_range_input_inputWrapper_input-paddingY: 2px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputInputWrapperInputPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputInputWrapperInputPaddingY,
    (SemiThemeData theme) => 2,
  ),
  (
    r'$spacing-datepicker_range_input_inputWrapper_input-paddingX: 4px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputInputWrapperInputPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputInputWrapperInputPaddingX,
    (SemiThemeData theme) => 4,
  ),
  (
    r'$spacing-datepicker_range_input_prefix-paddingLeft: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputPrefixPaddingLeft: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputPrefixPaddingLeft,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_range_input_prefix-paddingRight: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputPrefixPaddingRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputPrefixPaddingRight,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_range_input_suffix-paddingLeft: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputSuffixPaddingLeft: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputSuffixPaddingLeft,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_range_input_suffix-paddingRight: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputSuffixPaddingRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputSuffixPaddingRight,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_range_input_clearbtn-paddingLeft: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputClearbtnPaddingLeft: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputClearbtnPaddingLeft,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_range_input_clearbtn-paddingRight: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerRangeInputClearbtnPaddingRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerRangeInputClearbtnPaddingRight,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_navigation_insetInput-paddingY: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerNavigationInsetInputPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerNavigationInsetInputPaddingY,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper-margin: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperMargin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperMargin,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper-paddingY: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperPaddingY,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper-paddingX: 16px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperPaddingX,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper-paddingBottom: 0',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperPaddingBottom: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperPaddingBottom,
    (SemiThemeData theme) => 0,
  ),
  (
    r'$spacing-datepicker_insetInput_separator-paddingY: 0',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputSeparatorPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputSeparatorPaddingY,
    (SemiThemeData theme) => 0,
  ),
  (
    r'$spacing-datepicker_insetInput_separator-paddingX: 4px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputSeparatorPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputSeparatorPaddingX,
    (SemiThemeData theme) => 4,
  ),
  (
    r'$spacing-scrollList_item_wheel_list_outer-paddingRight: 18px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingScrollListItemWheelListOuterPaddingRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingScrollListItemWheelListOuterPaddingRight,
    (SemiThemeData theme) => 18,
  ),
  (
    r'$color-datepicker_panel-bg-default: var(--semi-color-bg-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerPanelBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerPanelBgDefault,
    (SemiThemeData theme) => theme.colors.colorBg3,
  ),
  (
    r'$color-datepicker_header-bg-default: var(--semi-color-bg-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerHeaderBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerHeaderBgDefault,
    (SemiThemeData theme) => theme.colors.colorBg3,
  ),
  (
    r'$color-datepicker_list-bg-default: var(--semi-color-bg-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerListBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerListBgDefault,
    (SemiThemeData theme) => theme.colors.colorBg3,
  ),
  (
    r'$color-datepicker_border-bg-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerBorderBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerBorderBgDefault,
    (SemiThemeData theme) => theme.colors.colorBorder,
  ),
  (
    r'$color-datepicker_footer-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerFooterBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerFooterBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-datepicker_quick-bg-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerQuickBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerQuickBgDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_quick_button-text-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerQuickButtonTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerQuickButtonTextDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-datepicker_day-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDayTextDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDayTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-datepicker_day-text-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDayTextHover: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDayTextHover,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-datepicker_day-text-active: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDayTextActive: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDayTextActive,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-datepicker_date-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDateTextDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDateTextDefault,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-datepicker_date-text-hover: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDateTextHover: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDateTextHover,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-datepicker_date-text-active: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDateTextActive: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDateTextActive,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-datepicker_date-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDateBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDateBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-datepicker_date-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDateBgHover: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDateBgHover,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-datepicker_date-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDateBgActive: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDateBgActive,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-datepicker_date_selected-text-default: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateSelectedTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateSelectedTextDefault,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$color-datepicker_date_selected-bg-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateSelectedBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateSelectedBgDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-datepicker_date_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateDisabledTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateDisabledTextDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledText,
  ),
  (
    r'$color-datepicker_date_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateDisabledBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateDisabledBgDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledFill,
  ),
  (
    r'$color-datepicker_date_today-text-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateTodayTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateTodayTextDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-datepicker_date_today_disabled-text-default: var(--semi-color-primary-disabled)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateTodayDisabledTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateTodayDisabledTextDefault,
    (SemiThemeData theme) => theme.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-datepicker_date_inHover-bg-default: var(--semi-color-primary-light-default)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateInHoverBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateInHoverBgDefault,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-datepicker_date_inRangeHover-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateInRangeHoverBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateInRangeHoverBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-datepicker_date_hoverDay-bg-default: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateHoverDayBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateHoverDayBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-datepicker_date_selectedRange-bg-hover: var(--semi-color-primary-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateSelectedRangeBgHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateSelectedRangeBgHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightHover,
  ),
  (
    r'$color-datepicker_date_hoverday_range-bg-default: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateHoverdayRangeBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateHoverdayRangeBgDefault,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightActive,
  ),
  (
    r'$color-datepicker_date_hoverday_around_single_selected-bg-default: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerDateHoverdayAroundSingleSelectedBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerDateHoverdayAroundSingleSelectedBgDefault,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightActive,
  ),
  (
    r'$color-datepicker_nav_monthIcon-text-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerNavMonthIconTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerNavMonthIconTextDefault,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-datepicker_navIcon-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerNavIconTextDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerNavIconTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-datepicker_input_primary-text-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerInputPrimaryTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerInputPrimaryTextDefault,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-datepicker_range_input-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-datepicker_range_input-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerRangeInputBgDefault: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerRangeInputBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-datepicker_range_input-bg-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerRangeInputBgHover: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerRangeInputBgHover,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-datepicker_range_input-border-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputBorderDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputBorderDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_range_input-border-active: var(--semi-color-focus-border)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputBorderActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputBorderActive,
    (SemiThemeData theme) => theme.colors.colorFocusBorder,
  ),
  (
    r'$color-datepicker_range_input_warning-border-active: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputWarningBorderActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputWarningBorderActive,
    (SemiThemeData theme) => theme.colors.colorWarning,
  ),
  (
    r'$color-datepicker_range_input_warning-bg-active: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputWarningBgActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputWarningBgActive,
    (SemiThemeData theme) => theme.colors.colorWarningLightHover,
  ),
  (
    r'$color-datepicker_range_input_warning-bg-default: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputWarningBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputWarningBgDefault,
    (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
  ),
  (
    r'$color-datepicker_range_input_warning-bg-hover: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputWarningBgHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputWarningBgHover,
    (SemiThemeData theme) => theme.colors.colorWarningLightHover,
  ),
  (
    r'$color-datepicker_range_input_warning-border-default: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputWarningBorderDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputWarningBorderDefault,
    (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
  ),
  (
    r'$color-datepicker_range_input_warning-border-hover: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputWarningBorderHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputWarningBorderHover,
    (SemiThemeData theme) => theme.colors.colorWarningLightHover,
  ),
  (
    r'$color-datepicker_range_input_error-border-default: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputErrorBorderDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputErrorBorderDefault,
    (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
  ),
  (
    r'$color-datepicker_range_input_error-bg-default: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputErrorBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputErrorBgDefault,
    (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
  ),
  (
    r'$color-datepicker_range_input_error-border-hover: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputErrorBorderHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputErrorBorderHover,
    (SemiThemeData theme) => theme.colors.colorDangerLightHover,
  ),
  (
    r'$color-datepicker_range_input_error-bg-hover: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputErrorBgHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputErrorBgHover,
    (SemiThemeData theme) => theme.colors.colorDangerLightHover,
  ),
  (
    r'$color-datepicker_range_input_error-border-active: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputErrorBorderActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputErrorBorderActive,
    (SemiThemeData theme) => theme.colors.colorDanger,
  ),
  (
    r'$color-datepicker_range_input_error-bg-active: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputErrorBgActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputErrorBgActive,
    (SemiThemeData theme) => theme.colors.colorDangerLightHover,
  ),
  (
    r'$color-datepicker_range_input_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputDisabledTextDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputDisabledTextDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledText,
  ),
  (
    r'$color-datepicker_range_input_disabled-bg-default: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputDisabledBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputDisabledBgDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledFill,
  ),
  (
    r'$color-datepicker_range_input_disabled-bg-hover: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputDisabledBgHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputDisabledBgHover,
    (SemiThemeData theme) => theme.colors.colorDisabledFill,
  ),
  (
    r'$color-datepicker_range_input_clearbtn-icon-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputClearbtnIconHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputClearbtnIconHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryHover,
  ),
  (
    r'$color-datepicker_range_input_inputWrapper-border-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputInputWrapperBorderDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputInputWrapperBorderDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_range_input_inputWrapper-bg-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputInputWrapperBgDefault: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputInputWrapperBgDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_range_input_inputWrapper-bg-focus: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputInputWrapperBgFocus: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputInputWrapperBgFocus,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-datepicker_range_input_separator-text-active: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeInputSeparatorTextActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeInputSeparatorTextActive,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-datepicker_day_main-border: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerDayMainBorder: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerDayMainBorder,
    (SemiThemeData theme) => theme.colors.colorPrimaryActive,
  ),
  (
    r'$color-datepicker_insetInput_separator: var(--semi-color-text-3)',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerInsetInputSeparator: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerInsetInputSeparator,
    (SemiThemeData theme) => theme.colors.colorText3,
  ),
  (
    r'$color-datepicker_range_trigger-border: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiDatePickerThemeData(colorDatepickerRangeTriggerBorder: v as Color),
    (SemiResolvedDatePickerThemeData d) => d.colorDatepickerRangeTriggerBorder,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_range_trigger-border-hover: transparent',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeTriggerBorderHover: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeTriggerBorderHover,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_range_trigger-border-active: transparent',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeTriggerBorderActive: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeTriggerBorderActive,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-datepicker_range_trigger-border-focus: transparent',
    const Color(0xff123456),
    (Object v) => SemiDatePickerThemeData(
      colorDatepickerRangeTriggerBorderFocus: v as Color,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.colorDatepickerRangeTriggerBorderFocus,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$font-datepicker_range_input_prefix_suffix_clearbtn-fontWeight: 600',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      fontDatepickerRangeInputPrefixSuffixClearbtnFontWeight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.fontDatepickerRangeInputPrefixSuffixClearbtnFontWeight,
    (SemiThemeData theme) => 600,
  ),
  (
    r'$font-datepicker_preset_header-fontWeight: 600',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      fontDatepickerPresetHeaderFontWeight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.fontDatepickerPresetHeaderFontWeight,
    (SemiThemeData theme) => 600,
  ),
  (
    r'$font-datepicker_range_input_prefix_suffix_clearbtn-fontSize: 14px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      fontDatepickerRangeInputPrefixSuffixClearbtnFontSize: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.fontDatepickerRangeInputPrefixSuffixClearbtnFontSize,
    (SemiThemeData theme) => 14,
  ),
  (
    r'$font-datepicker_range_input_prefix_suffix_clearbtn-lineHeight: 20px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      fontDatepickerRangeInputPrefixSuffixClearbtnLineHeight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.fontDatepickerRangeInputPrefixSuffixClearbtnLineHeight,
    (SemiThemeData theme) => 20,
  ),
  (
    r'$font-datepicker_range_input_large-fontSize: 16px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      fontDatepickerRangeInputLargeFontSize: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.fontDatepickerRangeInputLargeFontSize,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_month_compact-padding: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerMonthCompactPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerMonthCompactPadding,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$width-datepicker_day_compact: 28px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerDayCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerDayCompact,
    (SemiThemeData theme) => 28,
  ),
  (
    r'$width-datepicker_day_main_compact: 24px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerDayMainCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerDayMainCompact,
    (SemiThemeData theme) => 24,
  ),
  (
    r'$width-datepicker_day_compact-borderRadius: 4px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerDayCompactBorderRadius: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerDayCompactBorderRadius,
    (SemiThemeData theme) => 4,
  ),
  (
    r'$width-datepicker_month_compact: $width-datepicker_day_compact * 7 + $spacing-datepicker_month_compact-padding * 2',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerMonthCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerMonthCompact,
    (SemiThemeData theme) => 216,
  ),
  (
    r'$width-datepicker_nav_compact: 24px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerNavCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerNavCompact,
    (SemiThemeData theme) => 24,
  ),
  (
    r'$width-datepicker_panel_compact: 216px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(widthDatepickerPanelCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.widthDatepickerPanelCompact,
    (SemiThemeData theme) => 216,
  ),
  (
    r'$height-datepicker_switch_compact: 32px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerSwitchCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerSwitchCompact,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$height-datepicker_tpk_compact: 256px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerTpkCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerTpkCompact,
    (SemiThemeData theme) => 256,
  ),
  (
    r'$height-datepicker_yam_panel_compact: 256px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerYamPanelCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerYamPanelCompact,
    (SemiThemeData theme) => 256,
  ),
  (
    r'$height-datepicker_yam_li_compact: 32px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerYamLiCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerYamLiCompact,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$height-datepicker_yam_panel_header_compact: 48px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerYamPanelHeaderCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerYamPanelHeaderCompact,
    (SemiThemeData theme) => 48,
  ),
  (
    r'$radius-datepicker_range_input_inputWrapper: var(--semi-border-radius-small)',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      radiusDatepickerRangeInputInputWrapper: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.radiusDatepickerRangeInputInputWrapper,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$height-datepicker_range_input-default: 32px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerRangeInputDefault: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerRangeInputDefault,
    (SemiThemeData theme) => 32,
  ),
  (
    r'$height-datepicker_range_input-small: 24px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerRangeInputSmall: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerRangeInputSmall,
    (SemiThemeData theme) => 24,
  ),
  (
    r'$height-datepicker_range_input-large: 40px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerRangeInputLarge: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerRangeInputLarge,
    (SemiThemeData theme) => 40,
  ),
  (
    r'$width-datepicker_insetInput_date_type_wrapper_compact: 216px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputDateTypeWrapperCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputDateTypeWrapperCompact,
    (SemiThemeData theme) => 216,
  ),
  (
    r'$width-datepicker_insetInput_date_range_type_wrapper_compact: $width-datepicker_insetInput_date_type_wrapper_compact * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputDateRangeTypeWrapperCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputDateRangeTypeWrapperCompact,
    (SemiThemeData theme) => 432,
  ),
  (
    r'$width-datepicker_insetInput_month_type_wrapper_compact: 195px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerInsetInputMonthTypeWrapperCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerInsetInputMonthTypeWrapperCompact,
    (SemiThemeData theme) => 195,
  ),
  (
    r'$height-datepicker_insetInput_tpk_compact: 100%',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerInsetInputTpkCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerInsetInputTpkCompact,
    (SemiThemeData theme) => 100,
  ),
  (
    r'$height-datepicker_timeType_insetInput_yam_compact: 100%',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerTimeTypeInsetInputYamCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerTimeTypeInsetInputYamCompact,
    (SemiThemeData theme) => 100,
  ),
  (
    r'$height-datepicker_insetInput_wrapper_compact: 28px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerInsetInputWrapperCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerInsetInputWrapperCompact,
    (SemiThemeData theme) => 28,
  ),
  (
    r'$lineHeight-datepicker_compact: 20px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(lineHeightDatepickerCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.lineHeightDatepickerCompact,
    (SemiThemeData theme) => 20,
  ),
  (
    r'$lineHeight-datepicker_weekday_item_compact: 28px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      lineHeightDatepickerWeekdayItemCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.lineHeightDatepickerWeekdayItemCompact,
    (SemiThemeData theme) => 28,
  ),
  (
    r'$height-datepicker_insetInput_compact: 26px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerInsetInputCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerInsetInputCompact,
    (SemiThemeData theme) => 26,
  ),
  (
    r'$fontSize-datepicker_insetInput_compact-fontSize: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      fontSizeDatepickerInsetInputCompactFontSize: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.fontSizeDatepickerInsetInputCompactFontSize,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_switch_compact-padding: 6px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerSwitchCompactPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerSwitchCompactPadding,
    (SemiThemeData theme) => 6,
  ),
  (
    r'$spacing-datepicker_day_compact-margin: ($width-datepicker_day_compact - $width-datepicker_day_main_compact) * 0.5',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(spacingDatepickerDayCompactMargin: v as double),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerDayCompactMargin,
    (SemiThemeData theme) => 2,
  ),
  (
    r'$spacing-datepicker_weeks_compact-padding: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerWeeksCompactPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerWeeksCompactPadding,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_weeks_compact-paddingTop: $spacing-tight - 2px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerWeeksCompactPaddingTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerWeeksCompactPaddingTop,
    (SemiThemeData theme) => 6,
  ),
  (
    r'$spacing-datepicker_weekday_compact-paddingLeft: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerWeekdayCompactPaddingLeft: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerWeekdayCompactPaddingLeft,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_weekday_compact-paddingRight: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerWeekdayCompactPaddingRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerWeekdayCompactPaddingRight,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_weekday_compact-paddingBottom: $spacing-tight',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerWeekdayCompactPaddingBottom: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerWeekdayCompactPaddingBottom,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_compact-padding: 12px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(spacingDatepickerCompactPadding: v as double),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerCompactPadding,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_nav_compact-padding: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerNavCompactPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) => d.spacingDatepickerNavCompactPadding,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_yam_panel_header_compact-padding: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerYamPanelHeaderCompactPadding: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerYamPanelHeaderCompactPadding,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_footer_compact-paddintTop: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterCompactPaddintTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterCompactPaddintTop,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_footer_compact-paddintBottom: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterCompactPaddintBottom: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterCompactPaddintBottom,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$spacing-datepicker_footer_compact-paddintRight: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerFooterCompactPaddintRight: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerFooterCompactPaddintRight,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_scrolllist_shade_pre_compact-marginTop: -17px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerScrolllistShadePreCompactMarginTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerScrolllistShadePreCompactMarginTop,
    (SemiThemeData theme) => -17,
  ),
  (
    r'$spacing-datepicker_scrolllist_shade_post_compact-marginTop: 17px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerScrolllistShadePostCompactMarginTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerScrolllistShadePostCompactMarginTop,
    (SemiThemeData theme) => 17,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper_compact-margin: 4px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperCompactMargin: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperCompactMargin,
    (SemiThemeData theme) => 4,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper_compact-paddingY: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperCompactPaddingY: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperCompactPaddingY,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper_compact-paddingX: 8px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperCompactPaddingX: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperCompactPaddingX,
    (SemiThemeData theme) => 8,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper_compact-paddingBottom: 0',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperCompactPaddingBottom: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperCompactPaddingBottom,
    (SemiThemeData theme) => 0,
  ),
  (
    r'$spacing-datepicker_insetInput_wrapper_rangeType_compact-paddingTop: 0',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerInsetInputWrapperRangeTypeCompactPaddingTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerInsetInputWrapperRangeTypeCompactPaddingTop,
    (SemiThemeData theme) => 0,
  ),
  (
    r'$spacing-datepicker_quick_control_header_compact-paddingTop: 16px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlHeaderCompactPaddingTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlHeaderCompactPaddingTop,
    (SemiThemeData theme) => 16,
  ),
  (
    r'$spacing-datepicker_quick_control_content_compact-marginTop: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlContentCompactMarginTop: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlContentCompactMarginTop,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_quick_control_left_and_right_content_compact-paddingX: 12px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlLeftAndRightContentCompactPaddingX:
          v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlLeftAndRightContentCompactPaddingX,
    (SemiThemeData theme) => 12,
  ),
  (
    r'$spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX: 10px',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      spacingDatepickerQuickControlTopAndBottomContentCompactPaddingX:
          v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.spacingDatepickerQuickControlTopAndBottomContentCompactPaddingX,
    (SemiThemeData theme) => 10,
  ),
  (
    r'$radius-datepicker_range_input: var(--semi-border-radius-small)',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(radiusDatepickerRangeInput: v as double),
    (SemiResolvedDatePickerThemeData d) => d.radiusDatepickerRangeInput,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    r'$transition-datepicker_range_input: background-color .16s ease-in-out',
    'patched',
    (Object v) =>
        SemiDatePickerThemeData(transitionDatepickerRangeInput: v as String),
    (SemiResolvedDatePickerThemeData d) => d.transitionDatepickerRangeInput,
    (SemiThemeData theme) => 'background-color .16s ease-in-out',
  ),
  (
    r'$width-datepicker_presetPanel_left_and_right_content: $width-datepicker_presetPanel_left_and_right - $spacing-datepicker_quick_control_content-paddingX * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelLeftAndRightContent: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelLeftAndRightContent,
    (SemiThemeData theme) => 176,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_content_date: $width-datepicker_day * 7 + $spacing-datepicker_month-padding * 2 - $spacing-datepicker_quick_control_top_and_bottom_content-paddingX * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomContentDate: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomContentDate,
    (SemiThemeData theme) => 244,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_content_range: ($width-datepicker_day * 7 + $spacing-datepicker_month-padding * 2) * 2 - $spacing-datepicker_quick_control_top_and_bottom_content-paddingX * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomContentRange: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomContentRange,
    (SemiThemeData theme) => 528,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_content_month: 165px - $spacing-datepicker_quick_control_top_and_bottom_content-paddingX * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomContentMonth: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomContentMonth,
    (SemiThemeData theme) => 125,
  ),
  (
    r'$height-datepicker_month_max: $width-datepicker_day * 7 + 1px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerMonthMax: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerMonthMax,
    (SemiThemeData theme) => 253,
  ),
  (
    r'$height-datepicker_month_max_compact: $width-datepicker_day_compact * 7 + $spacing-datepicker_weeks_compact-paddingTop + $spacing-datepicker_weeks_compact-padding + $spacing-datepicker_weekday_compact-paddingBottom',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerMonthMaxCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerMonthMaxCompact,
    (SemiThemeData theme) => 220,
  ),
  (
    r'$height-datepicker_date_panel: $height-datepicker_month_max + $spacing-datepicker_month-padding + $width-datepicker_nav + $spacing-datepicker_navigation-paddingY * 2',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerDatePanel: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerDatePanel,
    (SemiThemeData theme) => 325,
  ),
  (
    r'$height-datepicker_date_time_panel: $height-datepicker_date_panel + $height-datepicker_switch - 1px',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerDateTimePanel: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerDateTimePanel,
    (SemiThemeData theme) => 378,
  ),
  (
    r'$height-datepicker_presetPanel_left_and_right_except_content: 20px + $spacing-datepicker_quick_control_header-paddingTop + $spacing-datepicker_quick_control_content-marginTop',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerPresetPanelLeftAndRightExceptContent: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerPresetPanelLeftAndRightExceptContent,
    (SemiThemeData theme) => 52,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_content_date_compact: $width-datepicker_day_compact * 7 + $spacing-datepicker_weeks_compact-padding * 2 - $spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomContentDateCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomContentDateCompact,
    (SemiThemeData theme) => 196,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_content_range_compact: ($width-datepicker_day_compact * 7 + $spacing-datepicker_weeks_compact-padding * 2) * 2 - $spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomContentRangeCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomContentRangeCompact,
    (SemiThemeData theme) => 412,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_content_month_compact: 165px - $spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX  * 2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomContentMonthCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomContentMonthCompact,
    (SemiThemeData theme) => 145,
  ),
  (
    r'$height-datepicker_date_panel_compact: $height-datepicker_month_max_compact + $width-datepicker_nav_compact + $spacing-datepicker_nav_compact-padding',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerDatePanelCompact: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerDatePanelCompact,
    (SemiThemeData theme) => 256,
  ),
  (
    r'$height-datepicker_date_time_panel_compact: $height-datepicker_date_panel_compact + $height-datepicker_switch_compact',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerDateTimePanelCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerDateTimePanelCompact,
    (SemiThemeData theme) => 288,
  ),
  (
    r'$height-datepicker_presetPanel_left_and_right_except_content_compact: 20px + $spacing-datepicker_quick_control_header_compact-paddingTop + $spacing-datepicker_quick_control_content_compact-marginTop',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerPresetPanelLeftAndRightExceptContentCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerPresetPanelLeftAndRightExceptContentCompact,
    (SemiThemeData theme) => 48,
  ),
  (
    r'$width-datepicker_presetPanel_left_and_right_two_col_button: ($width-datepicker_presetPanel_left_and_right_content - $spacing-datepicker_quick_control_item-margin) * 0.5',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelLeftAndRightTwoColButton: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelLeftAndRightTwoColButton,
    (SemiThemeData theme) => 84,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_three_col_button: ($width-datepicker_presetPanel_top_and_bottom_content_date - $spacing-datepicker_quick_control_item-margin * 2) * 0.333',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomThreeColButton: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomThreeColButton,
    (SemiThemeData theme) => 75.924,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_five_col_button: ($width-datepicker_presetPanel_top_and_bottom_content_range - $spacing-datepicker_quick_control_item-margin * 4) * 0.2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomFiveColButton: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomFiveColButton,
    (SemiThemeData theme) => 99.2,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_two_col_button: ($width-datepicker_presetPanel_top_and_bottom_content_month - $spacing-datepicker_quick_control_item-margin) * 0.5',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomTwoColButton: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomTwoColButton,
    (SemiThemeData theme) => 58.5,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_three_col_button_compact: ($width-datepicker_presetPanel_top_and_bottom_content_date_compact - $spacing-datepicker_quick_control_item-margin * 2) * 0.333',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomThreeColButtonCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomThreeColButtonCompact,
    (SemiThemeData theme) => 59.940000000000005,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_five_col_button_compact: ($width-datepicker_presetPanel_top_and_bottom_content_range_compact - $spacing-datepicker_quick_control_item-margin * 4) * 0.2',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomFiveColButtonCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomFiveColButtonCompact,
    (SemiThemeData theme) => 76,
  ),
  (
    r'$width-datepicker_presetPanel_top_and_bottom_two_col_button_compact: ($width-datepicker_presetPanel_top_and_bottom_content_month_compact - $spacing-datepicker_quick_control_item-margin) * 0.5',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      widthDatepickerPresetPanelTopAndBottomTwoColButtonCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.widthDatepickerPresetPanelTopAndBottomTwoColButtonCompact,
    (SemiThemeData theme) => 68.5,
  ),
  (
    r'$height-datepicker_inset_input: 32px + $spacing-datepicker_insetInput_wrapper-paddingY',
    -1234.5,
    (Object v) =>
        SemiDatePickerThemeData(heightDatepickerInsetInput: v as double),
    (SemiResolvedDatePickerThemeData d) => d.heightDatepickerInsetInput,
    (SemiThemeData theme) => 44,
  ),
  (
    r'$height-datepicker_preset_panel_inset_input: $height-datepicker_month_max + $spacing-datepicker_month-padding + $width-datepicker_nav + $spacing-datepicker_navigation_insetInput-paddingY * 2 + $height-datepicker_inset_input',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerPresetPanelInsetInput: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerPresetPanelInsetInput,
    (SemiThemeData theme) => 361,
  ),
  (
    r'$height-datepicker_inset_input_compact: 28px + $spacing-datepicker_insetInput_wrapper_compact-paddingY',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerInsetInputCompactDerived: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerInsetInputCompactDerived,
    (SemiThemeData theme) => 36,
  ),
  (
    r'$height-datepicker_preset_panel_inset_input_compact: $height-datepicker_month_max_compact + $width-datepicker_nav_compact + $spacing-datepicker_insetInput_wrapper_compact-paddingY * 2 + $height-datepicker_inset_input_compact',
    -1234.5,
    (Object v) => SemiDatePickerThemeData(
      heightDatepickerPresetPanelInsetInputCompact: v as double,
    ),
    (SemiResolvedDatePickerThemeData d) =>
        d.heightDatepickerPresetPanelInsetInputCompact,
    (SemiThemeData theme) => 296,
  ),
  (
    r'$transition_duration-datepicker_date-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) => SemiDatePickerThemeData(
      transitionDurationDatepickerDateBg: v as Duration,
    ),
    (SemiResolvedDatePickerThemeData d) => d.transitionDurationDatepickerDateBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-datepicker_date-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiDatePickerThemeData(transitionFunctionDatepickerDateBg: v as Curve),
    (SemiResolvedDatePickerThemeData d) => d.transitionFunctionDatepickerDateBg,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-datepicker_date-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiDatePickerThemeData(transitionDelayDatepickerDateBg: v as Duration),
    (SemiResolvedDatePickerThemeData d) => d.transitionDelayDatepickerDateBg,
    (SemiThemeData theme) => Duration.zero,
  ),
];

void main() {
  group('grid generation', () {
    testWidgets('Feb 2026: 4 rows at weekStartsOn 0 (1st on Sunday), 5 rows '
        'at weekStartsOn 1; ★rows are NOT padded', (tester) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2026, 2, 3), defaultOpen: true),
      );
      await settlePanel(tester);
      final first = tester.getCenter(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 1))),
      );
      final last = tester.getCenter(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 28))),
      );
      // 4 rows: the 28th sits 3 week rows below the 1st.
      expect(last.dy - first.dy, 3 * 36);
      // Leading blanks position the 1st: the Sunday 1st sits under the '日'
      // label column.
      final sun = tester.getCenter(find.text('日'));
      expect(first.dx, sun.dx);

      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          weekStartsOn: 1,
        ),
      );
      await settlePanel(tester);
      final first2 = tester.getCenter(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 1))),
      );
      final last2 = tester.getCenter(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 28))),
      );
      expect(last2.dy - first2.dy, 4 * 36);
      // The '日' label rotated to the last column still hosts the Sunday 1st.
      expect(first2.dx, tester.getCenter(find.text('日')).dx);
    });

    testWidgets('Aug 2026 spans 6 rows (5 leading blanks + 31 days)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2026, 8, 15), defaultOpen: true),
      );
      await settlePanel(tester);
      final first = tester.getCenter(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 8, 1))),
      );
      final last = tester.getCenter(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 8, 31))),
      );
      expect(last.dy - first.dy, 5 * 36);
    });

    testWidgets('weekStartsOn rotates the weekday labels', (tester) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2026, 2, 3), defaultOpen: true),
      );
      await settlePanel(tester);
      expect(weekdayLabels(tester), ['日', '一', '二', '三', '四', '五', '六']);
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          weekStartsOn: 3,
        ),
      );
      await settlePanel(tester);
      expect(weekdayLabels(tester), ['三', '四', '五', '六', '日', '一', '二']);
    });
  });

  group('navigation', () {
    testWidgets('steppers move month/year; the month title opens the yam '
        'overlay (★stays open after picks)', (tester) async {
      final panels = <String>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onPanelChange: (visible, text) => panels.add(text),
        ),
      );
      await settlePanel(tester);
      expect(find.text('2026年 2月'), findsOneWidget);

      await tester.tap(find.byKey(SemiDatePicker.navNextMonthKey));
      await settlePanel(tester);
      expect(find.text('2026年 3月'), findsOneWidget);
      expect(panels, ['2026-03-01']);

      await tester.tap(find.byKey(SemiDatePicker.navPrevYearKey));
      await settlePanel(tester);
      expect(find.text('2025年 3月'), findsOneWidget);
      expect(panels, ['2026-03-01', '2025-03-01']);

      await tester.tap(find.byKey(SemiDatePicker.monthTitleKey));
      await settlePanel(tester);
      expect(find.byKey(SemiDatePicker.yamBackKey), findsOneWidget);
      // ★The overlay stays open after a year pick (upstream
      // yearSelectionCallbacks: year then month fires onPanelChange twice).
      await tapYamItem(tester, find.text('2027'));
      expect(find.byKey(SemiDatePicker.yamBackKey), findsOneWidget);
      expect(panels, ['2026-03-01', '2025-03-01', '2027-03-01']);
      await tester.tap(find.byKey(SemiDatePicker.yamBackKey));
      await settlePanel(tester);
      expect(find.byKey(SemiDatePicker.yamBackKey), findsNothing);
    });

    testWidgets('dateRange: ★same-month nudge keeps the panels apart', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
          defaultOpen: true,
        ),
      );
      await settlePanel(tester);
      expect(find.text('2026年 2月'), findsOneWidget);
      expect(find.text('2026年 3月'), findsOneWidget);
      // Moving the left panel onto the right's month nudges the right panel.
      await tester.tap(find.byKey(SemiDatePicker.navNextMonthKey).first);
      await settlePanel(tester);
      expect(find.text('2026年 3月'), findsOneWidget); // left lands on March
      expect(find.text('2026年 4月'), findsOneWidget); // right nudged to April
    });

    testWidgets('syncSwitchMonth locks the panels together and hides the '
        'inner buttons', (tester) async {
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
          defaultOpen: true,
          syncSwitchMonth: true,
        ),
      );
      await settlePanel(tester);
      // The left panel's inner (next) buttons are hidden (visibility kept).
      final innerNext = find
          .ancestor(
            of: find.byKey(SemiDatePicker.navNextMonthKey).first,
            matching: find.byType(Opacity),
          )
          .first;
      expect(tester.widget<Opacity>(innerNext).opacity, 0);
      await tester.tap(find.byKey(SemiDatePicker.navPrevMonthKey).first);
      await settlePanel(tester);
      expect(find.text('2026年 1月'), findsOneWidget);
      expect(find.text('2026年 2月'), findsOneWidget);
    });
  });

  group('autoSwitchDate', () {
    testWidgets('01-31 follows into February with month-end clamp (→ 02-29) '
        'and ★does not close', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 31),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.navNextMonthKey));
      await settlePanel(tester);
      expect(find.text('2024年 2月'), findsOneWidget);
      expectChange(changes, [(DateTime(2024, 2, 29), '2024-02-29')]);
      expect(find.text('2024年 2月'), findsOneWidget);
    });

    testWidgets('aborts when disabledDate rejects the followed date', (
      tester,
    ) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 31),
          defaultOpen: true,
          disabledDate: (date, info) => date.month == 2,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.navNextMonthKey));
      await settlePanel(tester);
      expect(changes, isEmpty);
    });

    testWidgets('autoSwitchDate false leaves the selection behind', (
      tester,
    ) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 31),
          defaultOpen: true,
          autoSwitchDate: false,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.navNextMonthKey));
      await settlePanel(tester);
      expect(changes, isEmpty);
    });
  });

  group('range flow', () {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);

    testWidgets('first pick focuses the end input; ★half-pick never notifies; '
        '★panel closes only after BOTH inputs focused', (tester) async {
      final changes = <(Object?, String?)>[];
      // defaultOpen without touching the trigger: NO input has been focused.
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(10))));
      await settlePanel(tester);
      expect(changes, isEmpty);
      expect(inputTexts(tester), [fmt(d(10)), '']);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(20))));
      await settlePanel(tester);
      // Complete and notified, but ★the panel stays open: the start input was
      // never focused (the focusRecordsRef both-true requirement).
      expectChange(changes, [
        ([d(10), d(20)], '${fmt(d(10))} ~ ${fmt(d(20))}'),
      ]);
      expect(find.text('${now.year}年 ${now.month}月'), findsOneWidget);
    });

    testWidgets('trigger tap focuses start first, so a full pick closes the '
        'panel', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await openPicker(tester); // focuses the start input (record start).
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(10))));
      await settlePanel(tester); // flushes the deferred end record.
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(20))));
      await settlePanel(tester);
      expectChange(changes, [
        ([d(10), d(20)], '${fmt(d(10))} ~ ${fmt(d(20))}'),
      ]);
      // Panel closed (both records true at the closing check).
      expect(find.byKey(SemiDatePicker.monthTitleKey), findsNothing);
    });

    testWidgets('★end-before-start nulls the start and re-focuses the start '
        'input (the picked day becomes the END)', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(10)],
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byType(SemiInput).last); // focus the end input.
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(5))));
      await settlePanel(tester);
      expect(changes, isEmpty);
      expect(inputTexts(tester), ['', fmt(d(5))]);
    });

    testWidgets('★start-after-end nulls the end', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(5), d(10)],
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(20))));
      await settlePanel(tester);
      expect(changes, isEmpty);
      expect(inputTexts(tester), [fmt(d(20)), '']);
    });

    testWidgets('hover preview: ★the pending path AND the hovered day paint '
        'inhover (primary-light-default)', (tester) async {
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(10)],
          defaultOpen: true,
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byType(SemiInput).last); // focus the end input.
      await settlePanel(tester);
      final t = resolved();
      final gesture = await startMouse(tester);
      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiDatePicker.dayKey(d(15)))),
      );
      await settlePanel(tester);
      // ★The hovered day itself folds into `isHover` and also carries
      // `hoverday-around-singleselected` (one side picked) which wins the
      // cascade: primary-light-active. The path days paint inhover.
      expect(
        dayDecoration(tester, d(15)).color,
        t.colorDatepickerDateHoverdayAroundSingleSelectedBgDefault,
      );
      expect(
        dayDecoration(tester, d(12)).color,
        t.colorDatepickerDateInHoverBgDefault,
      );
      expect(dayDecoration(tester, d(20)).color, isNull);
      await gesture.moveTo(Offset.zero);
      await settlePanel(tester);
    });

    testWidgets('plain hover (no range preview) paints date-bg-hover '
        '(fill-0)', (tester) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2026, 2, 3), defaultOpen: true),
      );
      await settlePanel(tester);
      final t = resolved();
      final gesture = await startMouse(tester);
      await gesture.moveTo(
        tester.getCenter(
          find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 12))),
        ),
      );
      await settlePanel(tester);
      expect(
        dayDecoration(tester, DateTime(2026, 2, 12)).color,
        t.colorDatepickerDateBgHover,
      );
    });

    testWidgets('selected day paints primary bg + white text; today paints '
        'primary text', (tester) async {
      final today = DateTime.now();
      final month = DateTime(today.year, today.month, 3);
      await pumpHost(tester, picker(defaultValue: month, defaultOpen: true));
      await settlePanel(tester);
      final t = resolved();
      expect(
        dayDecoration(tester, month).color,
        t.colorDatepickerDateSelectedBgDefault,
      );
      final selectedText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(SemiDatePicker.dayKey(month)),
          matching: find.byType(Text),
        ),
      );
      expect(
        selectedText.style?.color,
        t.colorDatepickerDateSelectedTextDefault,
      );
      // Today's cell (not the selected one) carries the today text.
      if (today.day != 3) {
        final todayCell = DateTime(today.year, today.month, today.day);
        final todayText = tester.widget<Text>(
          find.descendant(
            of: find.byKey(SemiDatePicker.dayKey(todayCell)),
            matching: find.byType(Text),
          ),
        );
        expect(todayText.style?.color, t.colorDatepickerDateTodayTextDefault);
      }
    });
  });

  group('presets', () {
    final preset = SemiDatePickerPreset(
      text: 'early',
      start: DateTime(2026, 2, 1),
      end: DateTime(2026, 2, 5),
    );

    testWidgets('renders at all four positions with the left/right header', (
      tester,
    ) async {
      for (final position in SemiDatePickerPresetPosition.values) {
        await pumpHost(
          tester,
          picker(
            type: SemiDatePickerType.dateRange,
            defaultOpen: true,
            presets: [preset],
            presetPosition: position,
          ),
        );
        await settlePanel(tester);
        expect(
          find.byKey(SemiDatePicker.presetKey(0)),
          findsOneWidget,
          reason: '$position',
        );
        if (position == SemiDatePickerPresetPosition.left ||
            position == SemiDatePickerPresetPosition.right) {
          expect(find.text('快捷选择'), findsOneWidget);
        } else {
          expect(find.text('快捷选择'), findsNothing);
        }
        await pumpHost(tester, const SizedBox.shrink());
      }
    });

    testWidgets('★null preset clears the range and closes the panel', (
      tester,
    ) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
          defaultOpen: true,
          presets: const [SemiDatePickerPreset(text: 'clear')],
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.presetKey(0)));
      await settlePanel(tester);
      expectChange(changes, [(null, '')]);
      expect(find.byKey(SemiDatePicker.presetKey(0)), findsNothing);
    });

    testWidgets('disabled-date preset never notifies; ★lazy function values '
        'evaluate at click; onPresetClick still fires', (tester) async {
      final changes = <(Object?, String?)>[];
      var invocations = 0;
      final clicks = <SemiDatePickerPreset>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
          defaultOpen: true,
          disabledDate: (date, info) => date.month == 4,
          presets: [
            SemiDatePickerPreset(
              text: 'lazy',
              start: () {
                invocations++;
                return DateTime(2026, 4, 1);
              },
              end: () {
                invocations++;
                return DateTime(2026, 4, 9);
              },
            ),
          ],
          onChanged: (d, s) => changes.add((d, s)),
          onPresetClick: clicks.add,
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.presetKey(0)));
      await settlePanel(tester);
      expect(invocations, 2); // ★invoked at click time.
      expect(changes, isEmpty); // disabled dates never notify.
      expect(clicks, hasLength(1)); // onPresetClick still fires.
    });

    testWidgets('a valid preset lands the range and closes', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultOpen: true,
          presets: [preset],
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.presetKey(0)));
      await settlePanel(tester);
      expectChange(changes, [
        (
          [DateTime(2026, 2, 1), DateTime(2026, 2, 5)],
          '2026-02-01 ~ 2026-02-05',
        ),
      ]);
      expect(find.byKey(SemiDatePicker.presetKey(0)), findsNothing);
    });

    testWidgets('★monthRange renders no presets (upstream "todo" gap)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.monthRange,
          defaultOpen: true,
          presets: [preset],
        ),
      );
      await settlePanel(tester);
      expect(find.byKey(SemiDatePicker.presetKey(0)), findsNothing);
    });
  });

  group('disabledDate', () {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);

    testWidgets('standalone disabled days never land and paint disabled text '
        'on a ★transparent background', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          disabledDate: (date, info) => date.day == 10,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.tap(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 10))),
        warnIfMissed: false,
      );
      await settlePanel(tester);
      expect(changes, isEmpty);
      final t = resolved();
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 10))),
          matching: find.byType(Text),
        ),
      );
      expect(text.style?.color, t.colorDatepickerDateDisabledTextDefault);
      // ★a plain disabled day keeps a transparent background.
      expect(dayDecoration(tester, DateTime(2026, 2, 10)).color, isNull);
    });

    testWidgets('★range-side linking disables days beyond the picked side '
        '(focusRecordsRef gated)', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await openPicker(tester); // record start.
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(10))));
      await settlePanel(tester);
      // Focus is on the end input now: days before the start are disabled.
      await tester.tap(
        find.byKey(SemiDatePicker.dayKey(d(5))),
        warnIfMissed: false,
      );
      await settlePanel(tester);
      expect(inputTexts(tester), [fmt(d(10)), '']);
      expect(changes, isEmpty);
    });

    testWidgets('disabledDate info carries the pending range (DateTime? + '
        'focus)', (tester) async {
      final infos = <SemiDatePickerRangeInfo>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultOpen: true,
          disabledDate: (date, info) {
            infos.add(info);
            return false;
          },
        ),
      );
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(10))));
      await settlePanel(tester);
      expect(infos, isNotEmpty);
      final last = infos.last;
      expect(last.rangeInputFocus, SemiDatePickerRangeFocus.rangeEnd);
      expect(last.rangeStart, d(10));
    });
  });

  group('input round-trip', () {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);

    testWidgets('valid typed input commits on Enter', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.enterText(find.byType(EditableText).first, '2026-02-15');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settlePanel(tester);
      expectChange(changes, [(DateTime(2026, 2, 15), '2026-02-15')]);
    });

    testWidgets('★>4-digit years are rejected', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.enterText(find.byType(EditableText).first, '12345-01-01');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settlePanel(tester);
      expect(changes, isEmpty);
    });

    testWidgets('★invalid input falls back to the state value on Enter', (
      tester,
    ) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.enterText(find.byType(EditableText).first, 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settlePanel(tester);
      // Falls back to the state value (equal → no notification) and the
      // display restores the formatted value.
      expect(changes, isEmpty);
      expect(inputText(tester), '2026-02-03');
    });

    testWidgets('range: each field edits one joined string; a valid side '
        'commits the pair', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(5), d(10)],
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.enterText(find.byType(EditableText).last, fmt(d(20)));
      await settlePanel(tester);
      expectChange(changes, [
        ([d(5), d(20)], '${fmt(d(5))} ~ ${fmt(d(20))}'),
      ]);
    });

    testWidgets('month format round-trips (day falls back to the base date, '
        '★date-fns semantics)', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.month,
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      expect(inputText(tester), '2026-02');
      await tester.enterText(find.byType(EditableText).first, '2026-07');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settlePanel(tester);
      expect(changes, hasLength(1));
      expect(changes.single.$2, '2026-07');
      final date = changes.single.$1! as DateTime;
      expect(date.year, 2026);
      expect(date.month, 7);
    });
  });

  group('controlled and open', () {
    testWidgets('controlled value: display follows the prop; picks only '
        'notify', (tester) async {
      final changes = <(Object?, String?)>[];
      Widget build(Object? value) => host(
        picker(
          value: value,
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await tester.pumpWidget(build(DateTime(2026, 2, 3)));
      await settlePanel(tester);
      await tester.tap(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 10))),
      );
      await settlePanel(tester);
      expectChange(changes, [(DateTime(2026, 2, 10), '2026-02-10')]);
      // ★controlled: the display still follows the prop.
      expect(inputText(tester), '2026-02-03');
      await tester.pumpWidget(build(DateTime(2026, 2, 10)));
      await settlePanel(tester);
      expect(inputText(tester), '2026-02-10');
    });

    testWidgets('controlled open: outside click reports onOpenChange but the '
        'panel follows the prop', (tester) async {
      final opens = <bool>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          open: true,
          onOpenChange: opens.add,
        ),
      );
      await settlePanel(tester);
      expect(find.text('2026年 2月'), findsOneWidget);
      // Tap outside the panel/trigger (the tooltip barrier).
      await tester.tapAt(const Offset(20, 20));
      await settlePanel(tester);
      expect(opens, [false]);
      // ★controlled open keeps the panel mounted.
      expect(find.text('2026年 2月'), findsOneWidget);
    });

    testWidgets('uncontrolled open reports onOpenChange and closes outside', (
      tester,
    ) async {
      final opens = <bool>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onOpenChange: opens.add,
        ),
      );
      await settlePanel(tester);
      await tester.tapAt(const Offset(20, 20));
      await settlePanel(tester);
      expect(opens, [false]);
      expect(find.text('2026年 2月'), findsNothing);
    });
  });

  group('clear', () {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);

    testWidgets('showClear defaults true; the clear button clears value + '
        'input and reports (null, "")', (tester) async {
      final changes = <(Object?, String?)>[];
      var cleared = 0;
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          onChanged: (d, s) => changes.add((d, s)),
          onClear: () => cleared++,
        ),
      );
      await settlePanel(tester);
      // The single input hosts the SemiInput clear slot (visible once
      // focused/hovered with content).
      await tester.tap(find.byType(EditableText).first);
      await settlePanel(tester);
      expect(find.byKey(SemiInput.clearButtonKey), findsOneWidget);
      await tester.tap(
        find.byKey(SemiInput.clearButtonKey),
        warnIfMissed: false,
      );
      await settlePanel(tester);
      expectChange(changes, [(null, '')]);
      expect(cleared, 1);
      expect(inputText(tester), '');
    });

    testWidgets('range clear button appears while focused/hovered with '
        'content and clears', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(5), d(10)],
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      // Hidden until hover/focus (rendered only with content).
      expect(find.byKey(SemiDatePicker.clearButtonKey), findsNothing);
      await openPicker(tester); // focus start → clear becomes visible.
      expect(find.byKey(SemiDatePicker.clearButtonKey), findsOneWidget);
      await tester.tap(
        find.byKey(SemiDatePicker.clearButtonKey),
        warnIfMissed: false,
      );
      await settlePanel(tester);
      expectChange(changes, [(null, '')]);
    });

    testWidgets('showClear false renders no clear slot', (tester) async {
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(5), d(10)],
          showClear: false,
        ),
      );
      await settlePanel(tester);
      await openPicker(tester);
      expect(find.byKey(SemiDatePicker.clearButtonKey), findsNothing);
      expect(find.byKey(SemiInput.clearButtonKey), findsNothing);
    });
  });

  group('sizes, validateStatus, borderless, prefix', () {
    testWidgets('range trigger heights 24/32/40 per size', (tester) async {
      for (final (size, height) in [
        (SemiInputSize.small, 24.0),
        (SemiInputSize.normal, 32.0),
        (SemiInputSize.large, 40.0),
      ]) {
        await pumpHost(
          tester,
          picker(
            type: SemiDatePickerType.dateRange,
            defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
            size: size,
          ),
        );
        await settlePanel(tester);
        expect(
          tester
              .getSize(find.byKey(const Key('SemiDatePicker.rangeTrigger')))
              .height,
          height,
          reason: '$size',
        );
      }
    });

    testWidgets('validateStatus error paints the themed row (★the bg comes '
        'from the -error-border-default field)', (tester) async {
      final t = resolved();
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
          validateStatus: SemiInputStatus.error,
        ),
      );
      await settlePanel(tester);
      final deco =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('SemiDatePicker.rangeTrigger')),
                  )
                  .decoration
              as BoxDecoration;
      expect(deco.color, t.colorDatepickerRangeInputErrorBorderDefault);
    });

    testWidgets('borderless and prefix reach the trigger', (tester) async {
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2026, 2, 3),
          borderless: true,
          prefix: '¥',
        ),
      );
      await settlePanel(tester);
      final input = tester.widget<SemiInput>(find.byType(SemiInput).first);
      expect(input.borderless, isTrue);
      expect(input.prefix, '¥');
    });
  });

  group('RTL', () {
    testWidgets('arrows flip and the default position becomes bottomRight', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2026, 2, 3)),
        direction: TextDirection.rtl,
      );
      await settlePanel(tester);
      final tooltip = tester.widget<SemiTooltip>(find.byType(SemiTooltip));
      expect(tooltip.position, SemiTooltipPosition.bottomRight);
      await pumpHost(tester, picker(defaultValue: DateTime(2026, 2, 3)));
      await settlePanel(tester);
      expect(
        tester.widget<SemiTooltip>(find.byType(SemiTooltip)).position,
        SemiTooltipPosition.bottomLeft,
      );
    });

    testWidgets('range input slots flip (suffix moves to the start side)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [DateTime(2026, 2, 3), DateTime(2026, 3, 3)],
        ),
        direction: TextDirection.rtl,
      );
      await settlePanel(tester);
      final suffix = tester.getCenter(
        find.byKey(const Key('SemiDatePicker.rangeSuffix')),
      );
      final first = tester.getCenter(find.byType(SemiInput).first);
      // RTL: the suffix renders before (to the left of) the inputs.
      expect(suffix.dx < first.dx, isTrue);
    });
  });

  group('controller', () {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);

    testWidgets('open/close/focus/blur work; detached calls are no-ops', (
      tester,
    ) async {
      final controller = SemiDatePickerController();
      await pumpHost(
        tester,
        picker(type: SemiDatePickerType.dateRange, controller: controller),
      );
      await settlePanel(tester);
      controller.open();
      await settlePanel(tester);
      expect(find.text('${now.year}年 ${now.month}月'), findsOneWidget);
      controller.focus(SemiDatePickerRangeFocus.rangeEnd);
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(20))));
      await settlePanel(tester);
      // Focused end first: the pick lands as the END of an empty range.
      expect(inputTexts(tester), ['', fmt(d(20))]);
      controller.close();
      await settlePanel(tester);
      expect(find.text('${now.year}年 ${now.month}月'), findsNothing);
      controller.blur();
      await settlePanel(tester);
      // Detach (replace the host subtree) → calls become no-ops.
      await pumpHost(tester, const SizedBox.shrink());
      await settlePanel(tester);
      controller.open();
      controller.close();
      controller.focus();
      controller.blur();
      await settlePanel(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('keyboard', () {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);

    testWidgets('Enter commits the typed input; Tab on the range-end input '
        'unfocuses', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.dateRange,
          defaultValue: [d(5), d(10)],
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tester.enterText(find.byType(EditableText).first, fmt(d(15)));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settlePanel(tester);
      // ★parseInput sorts the pair ascending (the typed start came after the
      // existing end).
      expectChange(changes, [
        ([d(10), d(15)], '${fmt(d(10))} ~ ${fmt(d(15))}'),
      ]);

      // Tab on the end input clears the range focus: the next pick becomes a
      // fresh start.
      await tester.tap(find.byType(EditableText).last);
      await settlePanel(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await settlePanel(tester);
      await tester.tap(find.byKey(SemiDatePicker.dayKey(d(20))));
      await settlePanel(tester);
      expect(inputTexts(tester), [fmt(d(20)), '']);
    });
  });

  group('month/monthRange/year pickers', () {
    testWidgets('month: picking a month selects it and ★does not close the '
        'panel', (tester) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.month,
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      await tapYamItem(tester, find.text('8月'));
      expectChange(changes, [(DateTime(2026, 8), '2026-08')]);
      // ★panel stays open (the upstream close block covers date/dateRange).
      expect(find.text('8月'), findsOneWidget);
    });

    testWidgets('year type selects a single value with the yyyy format', (
      tester,
    ) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.year,
          defaultValue: DateTime(2026, 2, 3),
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      expect(inputText(tester), '2026');
      await tapYamItem(tester, find.text('2027'));
      expectChange(changes, [(DateTime(2027, 2), '2027')]);
    });

    testWidgets('monthRange keeps the right side at or after the left', (
      tester,
    ) async {
      final changes = <(Object?, String?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiDatePickerType.monthRange,
          defaultValue: [DateTime(2026, 2, 1), DateTime(2026, 6, 1)],
          defaultOpen: true,
          onChanged: (d, s) => changes.add((d, s)),
        ),
      );
      await settlePanel(tester);
      // Picking a left month past the right one catches the right month up.
      await tapYamItem(tester, find.text('8月').first);
      expect(changes.last.$1, [DateTime(2026, 8), DateTime(2026, 8)]);
    });
  });

  group('theme fields (220 + 3 + 0)', () {
    test('223 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(223));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(3),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(220),
      );
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiDatePickerThemeData().merge(patch),
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
          read(const SemiDatePickerThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiDatePickerThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source '
        '(incl. the paddint* typos and the \$spacing-scrollList_* name)', () {
      final source = File('lib/src/theme/semi_date_picker_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(223));
      // Verbatim quirk provenance.
      expect(
        source,
        contains(r'$spacing-datepicker_footer_compact-paddintTop: 10px'),
      );
      expect(
        source,
        contains(r'$spacing-datepicker_footer_compact-paddintBottom: 10px'),
      );
      expect(
        source,
        contains(r'$spacing-datepicker_footer_compact-paddintRight: 8px'),
      );
      expect(
        source,
        contains(
          r'$spacing-scrollList_item_wheel_list_outer-paddingRight: 18px',
        ),
      );
    });

    test('the 14 HARDCODES anchors live in the widget; the 10 dead fields and '
        '3 dead MOTION tokens are never consumed', () {
      final widgetSource = File('lib/src/components/semi_date_picker.dart')
          .readAsStringSync();
      const anchors = [
        'display: flex; justify-content: center; align-items: center;',
        'box-shadow: none;',
        r'$font-size-small: 12px',
        r'$font-size-regular: 14px',
        r'$font-size-header-6: 16px',
        'font-size: 13px',
        'border-left: 1px',
        'weeksRowNum * numbers.WEEK_HEIGHT',
        r'5px = $width-datepicker_presetPanel_scroll_bar / 3',
        r'3px = $width-datepicker_presetPanel_scroll_bar / 5',
        'transform: translateX(50%);',
        'transform: translateX(-50%);',
        ':not(#neverExistElement)',
        'calc(100vw - 32px)',
      ];
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
      // Dead upstream variables stay theme fields but are never consumed.
      const dead = [
        'widthDatepickerQuickControlBorderRadius',
        'spacingDatepickerRangeInputPaddingY',
        'colorDatepickerPanelBgDefault',
        'colorDatepickerDayTextHover',
        'colorDatepickerDateTextHover',
        'colorDatepickerDateTextActive',
        'colorDatepickerRangeInputWarningBorderHover',
        'colorDatepickerRangeInputErrorBgDefault',
        'colorDatepickerRangeInputErrorBorderHover',
        'spacingDatepickerCompactPadding',
        'transitionDurationDatepickerDateBg',
        'transitionFunctionDatepickerDateBg',
        'transitionDelayDatepickerDateBg',
      ];
      for (final name in dead) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
    });

    test('type coverage: 62 Color + 157 double + 1 String + 2 Duration + '
        '1 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 62);
      expect(counts['double'], 157);
      expect(counts['String'], 1);
      expect(counts['Duration'], 2);
      expect(fields.where((f) => f.$2 is Curve), hasLength(1));
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().datePicker,
        const SemiDatePickerThemeData(),
      );
      const patch = SemiDatePickerThemeData(widthDatepickerDay: 40);
      const themes = SemiComponentThemes(datePicker: patch);
      expect(const SemiComponentThemes().copyWith(datePicker: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.datePicker, patch);
    });

    testWidgets('SemiDatePickerTheme local patch applies (nested merge, inner '
        'wins its own field)', (tester) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiDatePickerTheme(
            data: const SemiDatePickerThemeData(
              widthDatepickerDay: 24,
              widthDatepickerMonth: 24 * 7,
            ),
            child: SemiDatePickerTheme(
              data: const SemiDatePickerThemeData(widthDatepickerDayMain: 20),
              child: host(
                picker(defaultValue: DateTime(2026, 2, 3), defaultOpen: true),
              ),
            ),
          ),
        ),
      );
      await settlePanel(tester);
      // Outer patch field (day width) still applies; the inner patch wins its
      // own field (day-main width) only.
      final size = tester.getSize(
        find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 10))),
      );
      expect(size.width, 24);
      final main = tester.getSize(
        find.descendant(
          of: find.byKey(SemiDatePicker.dayKey(DateTime(2026, 2, 10))),
          matching: find.byType(Container),
        ),
      );
      expect(main.width, 20);
    });
  });
}
