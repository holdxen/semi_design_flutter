// Behavior matrix for SemiTimePicker plus coverage for the 20 Sass
// declarations (14 FIELDS + 6 MOTION + 0 INTERNAL) — the 29 HARDCODES
// provenance anchors live in the widget's `_TimePickerMetrics` / call sites,
// and the 6 dead MOTION fields (上游未消费) must NOT appear in the widget.
import 'dart:io';
import 'dart:ui' as ui;

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

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// The SemiTooltip popup needs a few frames to measure, position and run its
/// entrance motion before its content hit-tests reliably.
Future<void> settlePanel(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 60));
}

/// Pump [host] on a tall test surface (the range popup is wide/tall).
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  await tester.pumpWidget(host(child, direction: direction));
}

/// Open the panel by clicking the trigger input.
Future<void> openPicker(WidgetTester tester) async {
  await tester.tap(find.byType(SemiInput).first);
  await settlePanel(tester);
}

/// Tap a row of a column (the lists scroll).
Future<void> tapRow(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await settlePanel(tester);
}

/// A row Container of [listKey] carrying [label] (rows are the only
/// Containers inside a column).
Container rowContainer(WidgetTester tester, Key listKey, String label) {
  final finder = find.descendant(
    of: find.byKey(listKey),
    matching: find.widgetWithText(Container, label),
  );
  return tester.widget<Container>(finder);
}

Color? rowColor(WidgetTester tester, Key listKey, String label) {
  final container = rowContainer(tester, listKey, label);
  return container.color ?? (container.decoration as BoxDecoration?)?.color;
}

Color? textColor(WidgetTester tester, Key listKey, String label) => tester
    .widget<Text>(
      find.descendant(of: find.byKey(listKey), matching: find.text(label)),
    )
    .style
    ?.color;

double columnOffset(WidgetTester tester, Key listKey) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byKey(listKey),
        matching: find.byType(Scrollable),
      ),
    )
    .position
    .pixels;

SemiResolvedTimePickerThemeData resolved([SemiThemeData? theme]) =>
    const SemiTimePickerThemeData().resolve(
      theme ?? const SemiThemeData.light(),
    );

Color get _lightPrimary =>
    const SemiThemeData.light().colors.colorPrimaryLightDefault;
Color get _lightDisabled =>
    const SemiThemeData.light().colors.colorDisabledText;

/// A minimal picker — every parameter mirrors SemiTimePicker's.
Widget picker({
  SemiTimePickerType type = SemiTimePickerType.time,
  Object? value,
  Object? defaultValue,
  String? format,
  bool use12Hours = false,
  int? hourStep,
  int? minuteStep,
  int? secondStep,
  List<int> Function()? disabledHours,
  List<int> Function(int hour)? disabledMinutes,
  List<int> Function(int hour, int minute)? disabledSeconds,
  SemiTimeDisabledSpec Function(
    List<DateTime?> value,
    SemiTimePickerPanelSide side,
  )?
  disabledTime,
  bool hideDisabledOptions = false,
  String rangeSeparator = ' ~ ',
  bool? open,
  bool? defaultOpen,
  ValueChanged<bool>? onOpenChange,
  SemiTimePickerChanged? onChanged,
  bool disabled = false,
  SemiInputSize size = SemiInputSize.normal,
  bool showClear = true,
  String? clearText,
  Widget? clearIcon,
  bool inputReadOnly = false,
  bool borderless = false,
  String? placeholder,
  Widget? insetLabel,
  SemiInputStatus? validateStatus,
  Widget? panelHeader,
  Widget? panelFooter,
  SemiTooltipPosition? position,
  bool autoAdjustOverflow = true,
  bool motion = true,
  SemiTimePickerController? controller,
  Widget? child,
}) => SemiTimePicker(
  type: type,
  value: value,
  defaultValue: defaultValue,
  format: format,
  use12Hours: use12Hours,
  hourStep: hourStep,
  minuteStep: minuteStep,
  secondStep: secondStep,
  disabledHours: disabledHours,
  disabledMinutes: disabledMinutes,
  disabledSeconds: disabledSeconds,
  disabledTime: disabledTime,
  hideDisabledOptions: hideDisabledOptions,
  rangeSeparator: rangeSeparator,
  open: open,
  defaultOpen: defaultOpen,
  onOpenChange: onOpenChange,
  onChanged: onChanged,
  disabled: disabled,
  size: size,
  showClear: showClear,
  clearText: clearText,
  clearIcon: clearIcon,
  inputReadOnly: inputReadOnly,
  borderless: borderless,
  placeholder: placeholder,
  insetLabel: insetLabel,
  validateStatus: validateStatus,
  panelHeader: panelHeader,
  panelFooter: panelFooter,
  position: position,
  autoAdjustOverflow: autoAdjustOverflow,
  motion: motion,
  controller: controller,
  child: child,
);

typedef _Patch = SemiTimePickerThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedTimePickerThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-timePicker_range_picker_panel_split-border: var(--semi-color-border)',
    const Color(0xff123456),
    (v) => SemiTimePickerThemeData(
      colorTimePickerRangePickerPanelSplitBorder: v as Color,
    ),
    (d) => d.colorTimePickerRangePickerPanelSplitBorder,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-timePicker_range_panel-border: rgba(0, 0, 0, .1)',
    const Color(0xff234567),
    (v) => SemiTimePickerThemeData(colorTimePickerRangePanelBorder: v as Color),
    (d) => d.colorTimePickerRangePanelBorder,
    (t) => const Color(0x1a000000),
  ),
  (
    r'$width-timePicker_range_panel-border: 1px',
    5.0,
    (v) =>
        SemiTimePickerThemeData(widthTimePickerRangePanelBorder: v as double),
    (d) => d.widthTimePickerRangePanelBorder,
    (t) => 1.0,
  ),
  (
    r'$height-timePicker_panel_body: 252px',
    300.0,
    (v) => SemiTimePickerThemeData(heightTimePickerPanelBody: v as double),
    (d) => d.heightTimePickerPanelBody,
    (t) => 252.0,
  ),
  (
    r'$height-scrollList_item: 36px',
    40.0,
    (v) => SemiTimePickerThemeData(heightScrollListItem: v as double),
    (d) => d.heightScrollListItem,
    (t) => 36.0,
  ),
  (
    r'$width-timePicker_panel_list_ampm: 72px',
    80.0,
    (v) => SemiTimePickerThemeData(widthTimePickerPanelListAmpm: v as double),
    (d) => d.widthTimePickerPanelListAmpm,
    (t) => 72.0,
  ),
  (
    r'$width-timePicker_panel_list_hour: 64px',
    70.0,
    (v) => SemiTimePickerThemeData(widthTimePickerPanelListHour: v as double),
    (d) => d.widthTimePickerPanelListHour,
    (t) => 64.0,
  ),
  (
    r'$width-timePicker_panel_list_minute: 64px',
    71.0,
    (v) => SemiTimePickerThemeData(widthTimePickerPanelListMinute: v as double),
    (d) => d.widthTimePickerPanelListMinute,
    (t) => 64.0,
  ),
  (
    r'$width-timePicker_panel_list_second: 64px',
    72.0,
    (v) => SemiTimePickerThemeData(widthTimePickerPanelListSecond: v as double),
    (d) => d.widthTimePickerPanelListSecond,
    (t) => 64.0,
  ),
  (
    r'$width-timePicker_range_panel_scrolllist_body-border: 2px',
    3.0,
    (v) => SemiTimePickerThemeData(
      widthTimePickerRangePanelScrolllistBodyBorder: v as double,
    ),
    (d) => d.widthTimePickerRangePanelScrolllistBodyBorder,
    (t) => 2.0,
  ),
  (
    r'$spacing-timePicker_range_panel_scrolllist_header_body-padding: 0',
    7.0,
    (v) => SemiTimePickerThemeData(
      spacingTimePickerRangePanelScrolllistHeaderBodyPadding: v as double,
    ),
    (d) => d.spacingTimePickerRangePanelScrolllistHeaderBodyPadding,
    (t) => 0.0,
  ),
  (
    r'$radius-timePicker_range_panel: var(--semi-border-radius-medium)',
    9.0,
    (v) => SemiTimePickerThemeData(radiusTimePickerRangePanel: v as double),
    (d) => d.radiusTimePickerRangePanel,
    (t) => t.radius.borderRadiusMedium.value,
  ),
  (
    r'$radius-timePicker_input: var(--semi-border-radius-small)',
    5.0,
    (v) => SemiTimePickerThemeData(radiusTimePickerInput: v as double),
    (d) => d.radiusTimePickerInput,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$shadow-timePicker_range_panel: 0 4px 14px rgba(0, 0, 0, .1)',
    '0 1px 2px red',
    (v) => SemiTimePickerThemeData(shadowTimePickerRangePanel: v as String),
    (d) => d.shadowTimePickerRangePanel,
    (t) => '0 4px 14px rgba(0, 0, 0, .1)',
  ),
  (
    r'$transition_duration-timePicker-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 5),
    (v) =>
        SemiTimePickerThemeData(transitionDurationTimePickerBg: v as Duration),
    (d) => d.transitionDurationTimePickerBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tagInput-bg: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiTimePickerThemeData(transitionFunctionTagInputBg: v as Curve),
    (d) => d.transitionFunctionTagInputBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tagInput-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 6),
    (v) => SemiTimePickerThemeData(transitionDelayTagInputBg: v as Duration),
    (d) => d.transitionDelayTagInputBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-tagInput-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (v) => SemiTimePickerThemeData(
      transitionDurationTagInputBorder: v as Duration,
    ),
    (d) => d.transitionDurationTagInputBorder,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tagInput-border: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) =>
        SemiTimePickerThemeData(transitionFunctionTagInputBorder: v as Curve),
    (d) => d.transitionFunctionTagInputBorder,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tagInput-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 8),
    (v) =>
        SemiTimePickerThemeData(transitionDelayTagInputBorder: v as Duration),
    (d) => d.transitionDelayTagInputBorder,
    (t) => Duration.zero,
  ),
];

void main() {
  group('theme fields (20 = 14 FIELDS + 6 MOTION + 0 INTERNAL)', () {
    test('20 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(20));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiTimePickerThemeData().merge(patch),
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
          read(const SemiTimePickerThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiTimePickerThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_time_picker_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(20));
    });

    test('the 29 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_time_picker.dart')
          .readAsStringSync();
      final anchors = <String>[
        '-ms-overflow-style: none; /* Internet Explorer 10+ */',
        'scrollbar-width: none; /* Firefox */',
        '&::-webkit-scrollbar {',
        r'($height-timePicker_panel_body - $height-scrollList_item) * 0.5',
        '.semi-input-readonly { cursor: pointer }',
        r'.#{$prefix}-input-borderless:not(:focus-within):not(:hover){',
        'opacity: 0;',
        'DEFAULT_SCROLL_DURATION: 120',
        "DEFAULT_FORMAT: 'HH:mm:ss'",
        "DEFAULT_FORMAT_A: 'a h:mm:ss'",
        "DEFAULT_RANGE_SEPARATOR: ' ~ '",
        r'value = `0${option}`;',
        'format.match(/HH|hh|H|h/g)',
        'format.match(/mm/g)',
        'format.match(/ss/g)',
        'hour % 12 || 12',
        'transformValue.getHours() < 12 && transformValue.setHours((transformValue.getHours() % 12) + 12);',
        'transformValue.getHours() >= 12 && transformValue.setHours(transformValue.getHours() - 12);',
        'value + locale.hour',
        "mode={'normal'}",
        "time: '请选择时间',",
        "timeRange: '请选择时间范围',",
        "begin: '开始时间',",
        "end: '结束时间',",
        "hour: '时',",
        "minute: '分',",
        "second: '秒',",
        "AM: '上午',",
        "PM: '下午',",
      ];
      expect(anchors, hasLength(29));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test(
      'type coverage: 2 Color + 11 double + 1 String + 4 Duration + 2 Curve',
      () {
        final counts = <String, int>{};
        for (final (_, value, _, _, _) in fields) {
          final type = value is Curve ? 'Curve' : value.runtimeType.toString();
          counts.update(type, (n) => n + 1, ifAbsent: () => 1);
        }
        expect(counts['Color'], 2);
        expect(counts['double'], 11);
        expect(counts['String'], 1);
        expect(counts['Duration'], 4);
        expect(counts['Curve'], 2);
      },
    );

    test('dead MOTION fields stay out of the widget; docs mark them', () {
      const dead = [
        'transition_duration-timePicker-bg',
        'transition_function-tagInput-bg',
        'transition_delay-tagInput-bg',
        'transition_duration-tagInput-border',
        'transition_function-tagInput-border',
        'transition_delay-tagInput-border',
      ];
      const deadFields = [
        'transitionDurationTimePickerBg',
        'transitionFunctionTagInputBg',
        'transitionDelayTagInputBg',
        'transitionDurationTagInputBorder',
        'transitionFunctionTagInputBorder',
        'transitionDelayTagInputBorder',
      ];
      final widgetSource = File('lib/src/components/semi_time_picker.dart')
          .readAsStringSync();
      for (final name in deadFields) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      final docs = File('docs/semi_time_picker.md').readAsStringSync();
      for (final name in dead) {
        final rows = docs
            .split('\n')
            .where((line) => line.contains('\$$name:'))
            .toList();
        expect(rows, isNotEmpty, reason: name);
        expect(
          rows.any((row) => row.contains('（上游未消费）')),
          isTrue,
          reason: name,
        );
      }
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().timePicker,
        const SemiTimePickerThemeData(),
      );
      const patch = SemiTimePickerThemeData(heightTimePickerPanelBody: 100);
      const themes = SemiComponentThemes(timePicker: patch);
      expect(const SemiComponentThemes().copyWith(timePicker: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.timePicker, patch);
    });

    testWidgets('SemiTimePickerTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      await tester.pumpWidget(
        host(
          SemiTheme(
            data: const SemiThemeData.light(),
            child: SemiTimePickerTheme(
              data: const SemiTimePickerThemeData(
                widthTimePickerPanelListHour: 100,
                widthTimePickerPanelListAmpm: 200,
              ),
              child: SemiTimePickerTheme(
                data: const SemiTimePickerThemeData(
                  widthTimePickerPanelListHour: 80,
                ),
                child: picker(
                  use12Hours: true,
                  defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
                ),
              ),
            ),
          ),
        ),
      );
      await openPicker(tester);
      // Outer patch field (ampm width) still applies; the inner patch wins
      // its own field (hour width) only.
      expect(
        tester.getSize(find.byKey(SemiTimePicker.ampmListKey)).width,
        200.0,
      );
      expect(
        tester.getSize(find.byKey(SemiTimePicker.hourListKey)).width,
        80.0,
      );
      expect(
        tester.getSize(find.byKey(SemiTimePicker.hourListKey)).height,
        252.0,
      );
    });
  });

  group('format columns', () {
    testWidgets("format: 'HH' renders the hour column only", (tester) async {
      await pumpHost(
        tester,
        picker(format: 'HH', defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await openPicker(tester);
      expect(find.byKey(SemiTimePicker.hourListKey), findsOneWidget);
      expect(find.byKey(SemiTimePicker.minuteListKey), findsNothing);
      expect(find.byKey(SemiTimePicker.secondListKey), findsNothing);
      expect(find.byKey(SemiTimePicker.ampmListKey), findsNothing);
    });

    testWidgets("format: 'HH:mm' hides the second column", (tester) async {
      await pumpHost(
        tester,
        picker(format: 'HH:mm', defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await openPicker(tester);
      expect(find.byKey(SemiTimePicker.hourListKey), findsOneWidget);
      expect(find.byKey(SemiTimePicker.minuteListKey), findsOneWidget);
      expect(find.byKey(SemiTimePicker.secondListKey), findsNothing);
    });

    testWidgets('use12Hours adds the AM/PM column', (tester) async {
      await pumpHost(
        tester,
        picker(
          use12Hours: true,
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
        ),
      );
      await openPicker(tester);
      expect(find.byKey(SemiTimePicker.ampmListKey), findsOneWidget);
    });

    testWidgets('column texts are zero-padded values with zh suffixes', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await openPicker(tester);
      for (final label in ['00时', '12时', '23时', '00分', '30分', '00秒', '45秒']) {
        expect(
          find.descendant(
            of: find.byKey(SemiTimePicker.hourListKey),
            matching: find.text(label),
          ),
          label.endsWith('时') ? findsOneWidget : findsNothing,
          reason: label,
        );
        expect(
          find.descendant(
            of: find.byKey(SemiTimePicker.minuteListKey),
            matching: find.text(label),
          ),
          label.endsWith('分') ? findsOneWidget : findsNothing,
          reason: label,
        );
        expect(
          find.descendant(
            of: find.byKey(SemiTimePicker.secondListKey),
            matching: find.text(label),
          ),
          label.endsWith('秒') ? findsOneWidget : findsNothing,
          reason: label,
        );
      }
    });
  });

  group('steps', () {
    testWidgets('hourStep: 2 halves the hour column', (tester) async {
      await pumpHost(
        tester,
        picker(
          hourStep: 2,
          minuteStep: 10,
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
        ),
      );
      await openPicker(tester);
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.byType(Container),
        ),
        findsNWidgets(12),
      );
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('01时'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.minuteListKey),
          matching: find.byType(Container),
        ),
        findsNWidgets(6),
      );
    });
  });

  group('disabled options', () {
    testWidgets('disabled values stay visible but disabled (hide = false)', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          disabledHours: () => [3],
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
        ),
      );
      await openPicker(tester);
      expect(
        textColor(tester, SemiTimePicker.hourListKey, '03时'),
        _lightDisabled,
      );
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('03时'),
        ),
      );
      expect(changes, isEmpty);
    });

    testWidgets('hideDisabledOptions removes disabled values', (tester) async {
      await pumpHost(
        tester,
        picker(
          disabledHours: () => [3],
          hideDisabledOptions: true,
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
        ),
      );
      await openPicker(tester);
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('03时'),
        ),
        findsNothing,
      );
    });

    testWidgets('hide fallback: hidden selected value highlights the first '
        'non-disabled option', (tester) async {
      await pumpHost(
        tester,
        picker(
          disabledHours: () => [3],
          hideDisabledOptions: true,
          // The selected hour 3 is hidden → selectedIndex -1 → the highlight
          // falls back to the first non-disabled option (scrollItem.tsx:314-322).
          defaultValue: DateTime(2024, 1, 1, 3, 30, 45),
        ),
      );
      await openPicker(tester);
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('03时'),
        ),
        findsNothing,
      );
      expect(
        rowColor(tester, SemiTimePicker.hourListKey, '00时'),
        _lightPrimary,
      );
      expect(rowColor(tester, SemiTimePicker.hourListKey, '01时'), isNull);
    });
  });

  group('use12Hours', () {
    testWidgets('hour column lists [12, 01..11]; hour 0 selects 12时 AM', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(use12Hours: true, defaultValue: DateTime(2024, 1, 1, 0, 5, 0)),
      );
      await openPicker(tester);
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.byType(Container),
        ),
        findsNWidgets(12),
      );
      // `hour % 12 || 12` — hour 0 highlights 12时; AM is selected.
      expect(
        rowColor(tester, SemiTimePicker.hourListKey, '12时'),
        _lightPrimary,
      );
      expect(rowColor(tester, SemiTimePicker.ampmListKey, '上午'), _lightPrimary);
    });

    testWidgets('tapping 12时 under AM yields hour 0 (AM: setHours(v%12))', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          use12Hours: true,
          defaultValue: DateTime(2024, 1, 1, 5, 5, 0),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('12时'),
        ),
      );
      expect((changes.single.$1 as DateTime).hour, 0);
    });

    testWidgets('AM↔PM toggle shifts ±12 (no event when format hides the '
        'change — the formatted-string quirk)', (tester) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          use12Hours: true,
          format: 'h:mm',
          defaultValue: DateTime(2024, 1, 1, 3, 0, 1),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      // Toggling AM→PM lands 15:00:01 but formats to the same `3:00`
      // (foundation.ts:511-531 `_hasChanged`) → ★no event.
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.ampmListKey),
          matching: find.text('下午'),
        ),
      );
      expect(changes, isEmpty);
    });

    testWidgets('PM toggle with a visible meridiem token fires ±12', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          use12Hours: true,
          defaultValue: DateTime(2024, 1, 1, 3, 0, 1),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.ampmListKey),
          matching: find.text('下午'),
        ),
      );
      // `<12 → +12` (Combobox.tsx:151-156).
      expect((changes.single.$1 as DateTime).hour, 15);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.ampmListKey),
          matching: find.text('上午'),
        ),
      );
      // `>=12 → -12` (Combobox.tsx:159-162).
      expect((changes.last.$1 as DateTime).hour, 3);
    });

    testWidgets('PM hour selection converts (setHours(v%12+12))', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          use12Hours: true,
          defaultValue: DateTime(2024, 1, 1, 15, 0, 0),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('05时'),
        ),
      );
      expect((changes.single.$1 as DateTime).hour, 17);
    });

    testWidgets('disabledHours remaps through the 12h table '
        '(ComboxFoundation.disabledHours:98-110)', (tester) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          use12Hours: true,
          // 13 maps to 1 under PM — the 01时 option is disabled.
          disabledHours: () => [13],
          defaultValue: DateTime(2024, 1, 1, 15, 0, 0),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      expect(
        textColor(tester, SemiTimePicker.hourListKey, '01时'),
        _lightDisabled,
      );
      expect(rowColor(tester, SemiTimePicker.hourListKey, '01时'), isNull);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('01时'),
        ),
      );
      expect(changes, isEmpty);
    });
  });

  group('panel selection and open scroll positioning', () {
    testWidgets('open centers the selected rows (jumpTo semantics)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await openPicker(tester);
      // scrollItem.scrollToNode: centered offset = itemHeight * index (the
      // 108px spacer keeps first/last rows centerable).
      expect(columnOffset(tester, SemiTimePicker.hourListKey), 12 * 36.0);
      expect(columnOffset(tester, SemiTimePicker.minuteListKey), 30 * 36.0);
      expect(columnOffset(tester, SemiTimePicker.secondListKey), 45 * 36.0);
    });

    testWidgets('tapping a row selects it and lands the formatted value', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('20时'),
        ),
      );
      expect((changes.single.$1 as DateTime).hour, 20);
      expect(changes.single.$2, '20:30:45');
      expect(inputText(tester), '20:30:45');
      expect(
        rowColor(tester, SemiTimePicker.hourListKey, '20时'),
        _lightPrimary,
      );
    });
  });

  group('input round-trip', () {
    testWidgets('half-typed input passes through the isTimeFormatLike gate', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await tester.enterText(find.byType(EditableText).first, '12:0');
      await tester.pump();
      expect(changes, isEmpty);
      expect(inputText(tester), '12:0');
    });

    testWidgets('valid text commits (dateStr is the raw input)', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await tester.enterText(find.byType(EditableText).first, '01:02:03');
      await tester.pump();
      final date = changes.single.$1 as DateTime;
      expect((date.hour, date.minute, date.second), (1, 2, 3));
      expect(changes.single.$2, '01:02:03');
    });

    testWidgets('blur rolls invalid text back and clears the error', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await tester.enterText(find.byType(EditableText).first, '99:99:99');
      await tester.pump();
      expect(inputText(tester), '99:99:99');
      expect(
        tester.widget<SemiInput>(find.byType(SemiInput)).validateStatus,
        SemiInputStatus.error,
      );
      tester.binding.focusManager.primaryFocus?.unfocus();
      await settlePanel(tester);
      expect(inputText(tester), '12:30:45');
      expect(
        tester.widget<SemiInput>(find.byType(SemiInput)).validateStatus,
        SemiInputStatus.normal,
      );
    });

    testWidgets('empty input clears the value', (tester) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await tester.enterText(find.byType(EditableText).first, '');
      await tester.pump();
      expect(changes.single.$1, isNull);
      expect(changes.single.$2, '');
      expect(inputText(tester), '');
    });
  });

  group('clear button', () {
    testWidgets('showClear clears via the keyed clear button', (tester) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      // Focusing shows the clear button (SemiInput `_clearVisible`).
      await tester.tap(find.byType(SemiInput).first);
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.clearButtonKey), findsOneWidget);
      await tester.tap(find.byKey(SemiTimePicker.clearButtonKey));
      await settlePanel(tester);
      expect(changes.single.$1, isNull);
      expect(changes.single.$2, '');
      expect(inputText(tester), '');
    });

    testWidgets('clearText wraps the clear icon in a tooltip', (tester) async {
      await pumpHost(
        tester,
        picker(clearText: '清空', defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await tester.tap(find.byType(SemiInput).first);
      await settlePanel(tester);
      expect(
        find.descendant(
          of: find.byKey(SemiTimePicker.clearButtonKey),
          matching: find.byType(SemiTooltip),
        ),
        findsOneWidget,
      );
    });

    testWidgets('inputReadOnly still clears (showClearIgnoreDisabled)', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          inputReadOnly: true,
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      expect(tester.widget<SemiInput>(find.byType(SemiInput)).readonly, isTrue);
      await tester.tap(find.byType(SemiInput).first);
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.clearButtonKey), findsOneWidget);
      await tester.tap(find.byKey(SemiTimePicker.clearButtonKey));
      await settlePanel(tester);
      expect(changes.single.$1, isNull);
      expect(inputText(tester), '');
    });
  });

  group('controlled value', () {
    testWidgets('rendering follows value; selection only notifies', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      final value = ValueNotifier<Object?>(DateTime(2024, 1, 1, 12, 30, 45));
      addTearDown(value.dispose);
      await pumpHost(
        tester,
        ValueListenableBuilder<Object?>(
          valueListenable: value,
          builder: (context, v, _) => picker(
            value: v,
            onChanged: (date, dateStr) => changes.add((date, dateStr)),
          ),
        ),
      );
      await openPicker(tester);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey),
          matching: find.text('20时'),
        ),
      );
      // The event carries the pick; the display still follows `value`.
      expect((changes.single.$1 as DateTime).hour, 20);
      expect(inputText(tester), '12:30:45');
      value.value = DateTime(2024, 1, 1, 8, 0, 0);
      await settlePanel(tester);
      expect(inputText(tester), '08:00:00');
    });

    testWidgets('same formatted string does not notify (seconds hidden)', (
      tester,
    ) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          value: DateTime(2024, 1, 1, 12, 0, 1),
          format: 'HH:mm',
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      await openPicker(tester);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.minuteListKey),
          matching: find.text('00分'),
        ),
      );
      // 12:00:01 → 12:00:01 formats equal under 'HH:mm' — ★no event.
      expect(changes, isEmpty);
    });
  });

  group('controlled open', () {
    testWidgets('open: false keeps the panel closed but reports onOpenChange', (
      tester,
    ) async {
      final opens = <bool>[];
      await pumpHost(
        tester,
        picker(
          open: false,
          onOpenChange: opens.add,
          defaultValue: DateTime(2024),
        ),
      );
      await tester.tap(find.byType(SemiInput).first);
      await settlePanel(tester);
      // ★tap + focus both report open (upstream handlePanelOpen runs twice
      // while a controlled `open` keeps state.open false).
      expect(opens.last, isTrue);
      expect(find.byKey(SemiTimePicker.panelKey), findsNothing);
    });

    testWidgets('open: true shows the panel; false closes it', (tester) async {
      await pumpHost(
        tester,
        picker(open: true, defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsOneWidget);
      await pumpHost(
        tester,
        picker(open: false, defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsNothing);
    });
  });

  group('popover open/close', () {
    testWidgets('focus opens, outside click closes, disabled never opens', (
      tester,
    ) async {
      final opens = <bool>[];
      await pumpHost(
        tester,
        picker(
          defaultOpen: true,
          onOpenChange: opens.add,
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
        ),
      );
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsOneWidget);
      // Outside click closes (SemiTooltip barrier → onVisibleChange(false)).
      await tester.tapAt(const Offset(5, 5));
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsNothing);
      expect(opens.last, isFalse);
      // Focus opens the panel (foundation.handleFocus).
      await tester.enterText(find.byType(EditableText).first, '12:30:45');
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsOneWidget);
      expect(opens.last, isTrue);
    });

    testWidgets('disabled never opens', (tester) async {
      await pumpHost(
        tester,
        picker(disabled: true, defaultValue: DateTime(2024, 1, 1, 12, 30, 45)),
      );
      await tester.tap(find.byType(SemiInput).first, warnIfMissed: false);
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsNothing);
    });
  });

  group('range', () {
    testWidgets('two independent panels with joined display', (tester) async {
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          type: SemiTimePickerType.timeRange,
          defaultValue: ['', '01:00:00'],
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      // ★empty endpoint is legal: `['', '01:00:00']` displays `' ~ 01:00:00'`.
      expect(inputText(tester), ' ~ 01:00:00');
      expect(
        tester.widget<SemiInput>(find.byType(SemiInput)).validateStatus,
        SemiInputStatus.normal,
      );
      await openPicker(tester);
      expect(find.byKey(SemiTimePicker.hourListKey), findsNWidgets(2));
      // Range default headers 开始时间 / 结束时间 (TimePicker.tsx defaultHeaderMap).
      expect(find.text('开始时间'), findsOneWidget);
      expect(find.text('结束时间'), findsOneWidget);
      // Left/right pick independently.
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey).at(0),
          matching: find.text('05时'),
        ),
      );
      var dates = changes.single.$1 as List<DateTime?>;
      expect(dates[0]!.hour, 5);
      expect(dates[1]!.hour, 1);
      expect(changes.single.$2, ['05:00:00', '01:00:00']);
      await tapRow(
        tester,
        find.descendant(
          of: find.byKey(SemiTimePicker.hourListKey).at(1),
          matching: find.text('06时'),
        ),
      );
      dates = changes.last.$1 as List<DateTime?>;
      expect(dates[1]!.hour, 6);
    });

    testWidgets('disabledTime overrides per panel with top-level fallback', (
      tester,
    ) async {
      await pumpHost(
        tester,
        picker(
          type: SemiTimePickerType.timeRange,
          defaultValue: ['01:00:00', '02:00:00'],
          disabledHours: () => [20],
          disabledTime: (value, side) => side == SemiTimePickerPanelSide.left
              ? SemiTimeDisabledSpec(disabledHours: () => [10])
              : const SemiTimeDisabledSpec(),
        ),
      );
      await openPicker(tester);
      final left = find.byKey(SemiTimePicker.hourListKey).at(0);
      final right = find.byKey(SemiTimePicker.hourListKey).at(1);
      // Left panel: overridden to [10]; right panel: falls back to [20].
      expect(
        tester
            .widget<Text>(find.descendant(of: left, matching: find.text('10时')))
            .style
            ?.color,
        _lightDisabled,
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(of: right, matching: find.text('10时')),
            )
            .style
            ?.color,
        isNot(_lightDisabled),
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(of: right, matching: find.text('20时')),
            )
            .style
            ?.color,
        _lightDisabled,
      );
    });
  });

  group('controller', () {
    testWidgets('open/close/focus/blur drive the picker; detach is a no-op', (
      tester,
    ) async {
      final controller = SemiTimePickerController();
      final changes = <(Object?, Object?)>[];
      await pumpHost(
        tester,
        picker(
          controller: controller,
          defaultValue: DateTime(2024, 1, 1, 12, 30, 45),
          onChanged: (date, dateStr) => changes.add((date, dateStr)),
        ),
      );
      controller.open();
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsOneWidget);
      controller.close();
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsNothing);
      // Staged text rolls back on blur (foundation.handleInputBlur).
      await tester.enterText(find.byType(EditableText).first, '12');
      await tester.pump();
      expect(inputText(tester), '12');
      controller.blur();
      await settlePanel(tester);
      expect(inputText(tester), '12:30:45');
      controller.focus();
      await settlePanel(tester);
      expect(find.byKey(SemiTimePicker.panelKey), findsOneWidget);
      // Detached controller calls are no-ops (no crash).
      await pumpHost(tester, const SizedBox.shrink());
      controller.open();
      controller.close();
      controller.focus();
      controller.blur();
      await settlePanel(tester);
    });
  });

  group('trigger decoration', () {
    testWidgets('size/insetLabel/validateStatus/placeholder map to SemiInput', (
      tester,
    ) async {
      const label = Text('lbl');
      await pumpHost(
        tester,
        picker(
          size: SemiInputSize.large,
          insetLabel: label,
          validateStatus: SemiInputStatus.warning,
          placeholder: '自定义',
        ),
      );
      final input = tester.widget<SemiInput>(find.byType(SemiInput));
      expect(input.size, SemiInputSize.large);
      expect(input.insetLabel, same(label));
      expect(input.validateStatus, SemiInputStatus.warning);
      expect(input.placeholder, '自定义');
    });

    testWidgets('invalid value forces validateStatus error; default '
        'placeholder is zh', (tester) async {
      await pumpHost(tester, picker(value: 'garbage'));
      final input = tester.widget<SemiInput>(find.byType(SemiInput));
      expect(input.validateStatus, SemiInputStatus.error);
      expect(input.placeholder, '请选择时间');
      await pumpHost(
        tester,
        picker(type: SemiTimePickerType.timeRange, value: ['01:00:00', '']),
      );
      expect(
        tester.widget<SemiInput>(find.byType(SemiInput)).placeholder,
        '请选择时间范围',
      );
    });
  });
}
