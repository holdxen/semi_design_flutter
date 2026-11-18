// Non-Material date picker (upstream Semi DatePicker).
//
// The Sass variables of packages/semi-foundation/datePicker/{variables,animation}.scss
// land as the 223 theme fields of SemiDatePickerThemeData
// (223 = 220 FIELDS + 3 MOTION + 0 INTERNAL — see tool/generate_date_picker.py).
// The HARDCODES provenance anchors below live in `_DatePickerMetrics` / call
// sites. Ten declared-but-never-referenced upstream variables and the 3
// effectively-dead MOTION tokens stay theme fields but are never consumed here
// (see docs/semi_date_picker.md); tool/test_generate_date_picker.py and
// test/semi_date_picker_test.dart assert that.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';

import '../theme/semi_date_picker_theme.dart';
import '../theme/semi_date_picker_theme_data.dart';
import '../overlay/tooltip_positioning.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_input.dart';
import 'semi_tooltip.dart';

/// Upstream `Type` (dateTime/dateTimeRange are deferred — see the difference
/// list in docs/semi_date_picker.md).
enum SemiDatePickerType { date, dateRange, month, monthRange, year }

/// Upstream `PresetPosition` (`left` / `right` / `top` / `bottom`).
enum SemiDatePickerPresetPosition { left, right, top, bottom }

/// Upstream `RangeType` for the range trigger inputs and
/// [SemiDatePickerRangeInfo.rangeInputFocus].
enum SemiDatePickerRangeFocus { rangeStart, rangeEnd }

/// Upstream `PresetType` — `start`/`end` accept a value (`DateTime` | `String`
/// | `num` timestamp; ★`0` is a valid timestamp) or a `Function` returning one,
/// invoked at click time (upstream `handlePresetClick`).
class SemiDatePickerPreset {
  const SemiDatePickerPreset({this.text, this.start, this.end});

  /// Button label (upstream `text`).
  final String? text;

  /// Range start / single value (upstream `start`).
  final Object? start;

  /// Range end (upstream `end`).
  final Object? end;
}

/// Second argument of [SemiDatePicker.disabledDate] (upstream
/// `DisabledDateOptions`). Upstream passes `rangeStart`/`rangeEnd` as
/// `'yyyy-MM-dd' | ''` strings — the port passes `DateTime?` (null for the
/// empty string) and notes the difference (docs/semi_date_picker.md).
class SemiDatePickerRangeInfo {
  const SemiDatePickerRangeInfo({
    this.rangeStart,
    this.rangeEnd,
    this.rangeInputFocus,
  });

  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// Which range input is being edited (upstream `'rangeStart' | 'rangeEnd' |
  /// false`).
  final SemiDatePickerRangeFocus? rangeInputFocus;
}

/// `onChanged(date, dateStr)`: `date` is a `DateTime` (single types), a
/// `List<DateTime>` (range types) or `null` (cleared); `dateStr` is the
/// formatted text (range values joined with [SemiDatePicker.rangeSeparator]),
/// `''` on clear. ★Fixed argument order (date first — upstream
/// `onChangeWithDateFirst`; the flip is deferred). ★Never fires while a range
/// is half-picked (an empty range counts as complete and does fire).
typedef SemiDatePickerChanged = void Function(Object? date, String? dateStr);

/// Imperative handle (upstream ref methods `open`/`close`/`focus`/`blur`,
/// semi_pincode.dart:26-51 attach/detach precedent). Calls are no-ops while
/// detached.
class SemiDatePickerController {
  _SemiDatePickerState? _state;

  /// Opens the panel (upstream `open`: uncontrolled open only; a controlled
  /// `open` prop still reports `onOpenChange`).
  void open() {
    _state?._controllerOpen();
  }

  /// Closes the panel (upstream `close`).
  void close() {
    _state?._controllerClose();
  }

  /// Focuses the trigger input (range types default to `rangeStart`; pass
  /// [SemiDatePickerRangeFocus.rangeEnd] for the end input — upstream
  /// `focus(focusType)`).
  void focus([SemiDatePickerRangeFocus? focusType]) {
    _state?._controllerFocus(focusType);
  }

  /// Blurs the focused trigger input (upstream `blur`).
  void blur() {
    _state?._controllerBlur();
  }

  void _attach(_SemiDatePickerState state) {
    _state = state;
  }

  void _detach(_SemiDatePickerState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_date_picker.py for the
/// 223 = 220 + 3 + 0 accounting; the constants below are the 另列 HARDCODES
/// entries (their snippets are checked to appear in this file).
abstract final class _DatePickerMetrics {
  /// `@mixin all-center` (packages/semi-theme-default/scss/mixin.scss:22 —
  /// `display: flex; justify-content: center; align-items: center;`), used by
  /// the day cell (datePicker.scss:358) and the yam rows. The port centers
  /// with `Center` instead.
  // ignore: unused_field
  static const String allCenter =
      'display: flex; justify-content: center; align-items: center;';

  /// `@include shadow-0` (datePicker.scss:620, the jumperlist shadow —
  /// `box-shadow: none;`). Nothing to draw; recorded for provenance.
  // ignore: unused_field
  static const String shadowZero = 'box-shadow: none;';

  /// `@include font-size-small` (datePicker.scss:323, the weekday row —
  /// `$font-size-small: 12px` in packages/semi-theme-default/scss/variables.scss).
  static const double fontSizeSmall = 12;

  /// `@include font-size-regular` (datePicker.scss:159, scrolllist header —
  /// `$font-size-regular: 14px`). The day number inherits the regular size.
  static const double fontSizeRegular = 14;

  /// `@include font-size-header-6` (datePicker.scss:299, the navigation month
  /// title — `$font-size-header-6: 16px`).
  static const double fontSizeHeader6 = 16;

  /// `font-size: 13px` (datePicker.scss:844, `.semi-datepicker-popover-trigger
  /// .semi-input-wrapper`) — every trigger input renders at 13px. Text lays
  /// out at natural metrics (no `TextStyle.height`, per docs/semi_input.md).
  static const double triggerFontSize = 13;

  /// `border-left: 1px solid var(--semi-color-border)` (datePicker.scss:188,
  /// the yam two-column separator) and `border-left: 1px` (datePicker.scss:1239,
  /// the insetInput separator — deferred).
  static const double separatorBorderWidth = 1;

  /// `const height = weeksRowNum * numbers.WEEK_HEIGHT;` (month.tsx:293) with
  /// `WEEK_HEIGHT: 36` (constants.ts:62). The week row height of the month
  /// grid.
  static const double weekHeight = 36;

  /// `// 5px = $width-datepicker_presetPanel_scroll_bar / 3` (datePicker.scss:688,
  /// the 3-column top/bottom preset grid scrollbar allowance). The Wrap grid
  /// approximates the allowance; recorded for provenance.
  // ignore: unused_field
  static const double scrollbarPaddingThree = 5;

  /// `// 3px = $width-datepicker_presetPanel_scroll_bar / 5` (datePicker.scss:708,
  /// the 5-column top/bottom range preset grid scrollbar allowance). The Wrap
  /// grid approximates the allowance; recorded for provenance.
  // ignore: unused_field
  static const double scrollbarPaddingFive = 3;

  /// `transform: translateX(50%);` (datePicker.scss:1719) — the range input
  /// separator centers on its own half-slot (LTR). The port centers the
  /// separator with layout instead.
  // ignore: unused_field
  static const String separatorTranslate = 'transform: translateX(50%);';

  /// `transform: translateX(-50%);` (rtl.scss:189) — the RTL mirror of the
  /// separator translate.
  // ignore: unused_field
  static const String separatorTranslateRtl = 'transform: translateX(-50%);';

  /// `:not(#neverExistElement)` (datePicker.scss:215/940/944) — a pure CSS
  /// specificity hack; note only, nothing to port.
  // ignore: unused_field
  static const String priorityHack = ':not(#neverExistElement)';

  /// `$compact-max-width: calc(100vw - 32px);` (datePicker.scss:1133, the
  /// compact panel cap — density is deferred); note only.
  // ignore: unused_field
  static const String compactMaxWidth = 'calc(100vw - 32px)';

  /// `z-index: $z-popover` with `$z-popover: 1030`
  /// (packages/semi-theme-default/scss/variables.scss). Passed to
  /// `SemiTooltip.zIndex` (the select `_SelectMetrics.popoverZIndex`
  /// precedent).
  static const int popoverZIndex = 1030;

  /// Navigation button `min-width: 32px` (datePicker.scss,
  /// `$width-datepicker_navigation_button_min` is themed; the icon slot keeps
  /// its hit area here).
  static const double navButtonMinWidth = 32;

  /// The inner day box height (paired with the themed
  /// `widthDatepickerDayMain` width).
  static const double dayMainHeight = 32;

  /// zh-CN hardcodes (locale is deferred): weekday labels (`locale.weeks` of
  /// packages/semi-ui/locale/source/zh_CN.ts) and the navigation month title
  /// template `${year}年 ${month}` (locale `monthText`).
  static const List<String> weekdayLabels = ['日', '一', '二', '三', '四', '五', '六'];

  /// `locale.presets` of zh_CN.ts (`'快捷选择'`) — the left/right preset panel
  /// header (see [SemiDatePicker.presetHeader]).
  static const String presetHeaderDefault = '快捷选择';

  /// `locale.selectDate` of zh_CN.ts — the yam overlay back button.
  static const String yamBackLabel = '返回选择日期';

  /// `aria-label`s of navigation.tsx:105/113/131/141.
  static const String prevYearLabel = 'Previous year';
  static const String prevMonthLabel = 'Previous month';
  static const String nextMonthLabel = 'Next month';
  static const String nextYearLabel = 'Next year';

  /// `aria-label={... "Choose date" : "Change date"}` (datePicker.tsx:722).
  static const String chooseDateLabel = 'Choose date';
  static const String changeDateLabel = 'Change date';

  /// `aria-label="Clear range input value"` (dateInput.tsx:211).
  static const String clearRangeLabel = 'Clear range input value';

  /// `0 0 1px rgba(0, 0, 0, .3)` / `0 4px 14px rgba(0, 0, 0, .1)` — the two
  /// `@include shadow-elevated` layers (packages/semi-theme-default/scss/global.scss)
  /// of the popover surface (the select `_SelectMetrics` precedent; hardcoded
  /// to the light token values).
  static const List<BoxShadow> shadowElevated = [
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 1),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 4),
      blurRadius: 14,
    ),
  ];
}

// ---------------------------------------------------------------------------
// private date utilities (the date-fns subset the port needs)
// ---------------------------------------------------------------------------

/// JS-style day of week: 0 = Sunday .. 6 = Saturday (`Date.prototype.getDay`).
int _jsWeekday(DateTime d) => d.weekday % 7;

int _daysInMonth(int year, int month) {
  final next = month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);
  return DateTime(next.year, next.month, 0).day;
}

DateTime _addMonths(DateTime d, int n) => DateTime(d.year, d.month + n, 1);

/// `format(date, token)` for the `yyyy`/`MM`/`dd` subset (date-fns `format`).
String _dpFormat(DateTime d, String fmt) {
  final buffer = StringBuffer();
  var i = 0;
  while (i < fmt.length) {
    if (fmt.startsWith('yyyy', i)) {
      // date-fns `yyyy` pads to 4 digits but never truncates a longer year.
      final y = d.year.toString();
      buffer.write(y.length >= 4 ? y : y.padLeft(4, '0'));
      i += 4;
    } else if (fmt.startsWith('MM', i)) {
      buffer.write(d.month.toString().padLeft(2, '0'));
      i += 2;
    } else if (fmt.startsWith('dd', i)) {
      buffer.write(d.day.toString().padLeft(2, '0'));
      i += 2;
    } else {
      buffer.write(fmt[i]);
      i += 1;
    }
  }
  return buffer.toString();
}

/// Strict `parse(text, format, baseDate)` for the `yyyy`/`MM`/`dd` subset:
/// the whole text must match the format; fields absent from the format fall
/// back to the base date (date-fns `parse`). Returns null on any mismatch or
/// out-of-range component (date-fns yields an Invalid Date).
DateTime? _dpParseStrict(String text, String fmt, DateTime base) {
  final pattern = StringBuffer();
  final tokens = <String>[];
  var i = 0;
  while (i < fmt.length) {
    if (fmt.startsWith('yyyy', i)) {
      pattern.write(r'(\d{4})');
      tokens.add('yyyy');
      i += 4;
    } else if (fmt.startsWith('MM', i)) {
      pattern.write(r'(\d{2})');
      tokens.add('MM');
      i += 2;
    } else if (fmt.startsWith('dd', i)) {
      pattern.write(r'(\d{2})');
      tokens.add('dd');
      i += 2;
    } else {
      pattern.write(RegExp.escape(fmt[i]));
      i += 1;
    }
  }
  final match = RegExp('^$pattern\$').firstMatch(text);
  if (match == null) return null;
  var year = base.year;
  var month = base.month;
  var day = base.day;
  for (var t = 0; t < tokens.length; t++) {
    final value = int.parse(match.group(t + 1)!);
    switch (tokens[t]) {
      case 'yyyy':
        year = value;
      case 'MM':
        month = value;
      case 'dd':
        day = value;
    }
  }
  if (month < 1 || month > 12 || day < 1 || day > _daysInMonth(year, month)) {
    return null;
  }
  return DateTime(year, month, day);
}

/// `compatibleParse(value, formatToken, baseDate)` (parser.ts): try the format
/// first, then ISO-8601, then the timestamp parse; ★years with more than 4
/// digits are rejected; anything else is null (upstream `null`).
DateTime? _dpCompatibleParse(String value, String? fmt, DateTime base) {
  if (value.isEmpty) return null;
  DateTime? result;
  if (fmt != null) {
    result = _dpParseStrict(value, fmt, base);
  }
  result ??= DateTime.tryParse(value);
  result ??= _dpTimestampParse(value);
  if (result != null && result.year.toString().length > 4) {
    // ★ yearInvalid (parser.ts:28).
    return null;
  }
  return result;
}

DateTime? _dpTimestampParse(String value) {
  final millis = int.tryParse(value) ?? double.tryParse(value);
  if (millis == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis.round());
}

/// `_parseValue` (foundation.ts:324): Date / ISO string / millisecond
/// timestamp, ★`0` is a valid timestamp. Anything else returns null (upstream
/// throws a TypeError — see docs/semi_date_picker.md).
DateTime? _dpParseValue(Object? value, String? fmt) {
  if (value is DateTime) return value;
  if (value == null) return null;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.round());
  }
  if (value is String) {
    return _dpCompatibleParse(value, fmt, DateTime.now());
  }
  return null;
}

/// `getWeeks` (getMonthTable.ts): the month grid — leading blanks position the
/// 1st and rows are NOT padded (a month can span 4-6 rows).
List<List<DateTime?>> _dpGetWeeks(DateTime month, int weekStartsOn) {
  final first = DateTime(month.year, month.month, 1);
  final blanks = (_jsWeekday(first) - weekStartsOn + 7) % 7;
  final days = _daysInMonth(month.year, month.month);
  final cells = <DateTime?>[
    ...List<DateTime?>.filled(blanks, null),
    for (var d = 1; d <= days; d++) DateTime(month.year, month.month, d),
  ];
  final weeks = <List<DateTime?>>[];
  for (var i = 0; i < cells.length; i += 7) {
    weeks.add(cells.sublist(i, i + 7 > cells.length ? cells.length : i + 7));
  }
  return weeks;
}

/// `isSameDay` (date-fns).
bool _dpIsSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// `isBefore` / `isAfter` on the date part only (the range types compare
/// `startOfDay(date)` upstream — monthsGridFoundation.ts:1243).
int _dpCompareDays(DateTime a, DateTime b) {
  final da = DateTime(a.year, a.month, a.day);
  final db = DateTime(b.year, b.month, b.day);
  return da.compareTo(db);
}

/// `isBetween(day, {start, end})` (isBetween.ts): strictly between — the
/// endpoints themselves are excluded.
bool _dpIsBetween(DateTime day, DateTime start, DateTime end) {
  if (_dpCompareDays(start, end) >= 0) return false;
  return _dpCompareDays(day, start) > 0 && _dpCompareDays(day, end) < 0;
}

// ---------------------------------------------------------------------------
// public widget
// ---------------------------------------------------------------------------

/// A source-sized, non-Material date picker (upstream Semi DatePicker), driven
/// by packages/semi-foundation/datePicker/foundation.ts +
/// monthsGridFoundation.ts.
///
/// `value != null` makes the component controlled (the project-wide
/// convention): the display follows [value] and picks only emit [onChanged];
/// releasing control keeps the last displayed selection. `open != null` does
/// the same for the panel.
///
/// Value accepts `DateTime` | `String` | `num` (millisecond timestamp,
/// ★`0` valid) or a `List` of those (range types); invalid entries are
/// dropped (upstream warns and skips).
class SemiDatePicker extends StatefulWidget {
  const SemiDatePicker({
    super.key,
    this.type = SemiDatePickerType.date,
    this.value,
    this.defaultValue,
    this.format,
    this.disabledDate,
    this.onChanged,
    this.onOpenChange,
    this.onPanelChange,
    this.onClear,
    this.onBlur,
    this.onFocus,
    this.onPresetClick,
    this.open,
    this.defaultOpen = false,
    this.presets = const [],
    this.presetPosition = SemiDatePickerPresetPosition.bottom,
    this.presetHeader,
    this.weekStartsOn = 0,
    this.autoSwitchDate = true,
    this.syncSwitchMonth = false,
    this.size = SemiInputSize.normal,
    this.validateStatus = SemiInputStatus.normal,
    this.disabled = false,
    this.borderless = false,
    this.inputReadOnly = false,
    this.showClear = true,
    this.placeholder,
    this.prefix,
    this.insetLabel,
    this.inputStyle,
    this.rangeSeparator = ' ~ ',
    this.position,
    this.autoAdjustOverflow = true,
    this.motion = true,
    this.autofocus = false,
    this.semanticsLabel,
    this.controller,
  }) : assert(
         weekStartsOn >= 0 && weekStartsOn <= 6,
         'weekStartsOn must be 0 (Sunday) .. 6 (Saturday)',
       );

  /// Day-cell key helper (test positioning).
  static Key dayKey(DateTime day) =>
      ValueKey('SemiDatePicker.day-${day.year}-${day.month}-${day.day}');

  /// Key of the range clear button slot.
  static const Key clearButtonKey = Key('SemiDatePicker.clearButton');

  /// Keys of the navigation buttons and month titles.
  static const Key navPrevYearKey = Key('SemiDatePicker.navPrevYear');
  static const Key navPrevMonthKey = Key('SemiDatePicker.navPrevMonth');
  static const Key navNextMonthKey = Key('SemiDatePicker.navNextMonth');
  static const Key navNextYearKey = Key('SemiDatePicker.navNextYear');
  static const Key monthTitleKey = Key('SemiDatePicker.monthTitle');
  static const Key monthTitleRightKey = Key('SemiDatePicker.monthTitleRight');

  /// Key of the yam overlay back button.
  static const Key yamBackKey = Key('SemiDatePicker.yamBack');

  /// Preset button key helper (test positioning).
  static Key presetKey(int index) => ValueKey('SemiDatePicker.preset-$index');

  /// Upstream `type` (dateTime/dateTimeRange deferred).
  final SemiDatePickerType type;

  /// Controlled value (`DateTime` | `String` | `num` | `List` of those).
  final Object? value;

  /// Uncontrolled seed.
  final Object? defaultValue;

  /// Format tokens `yyyy`/`MM`/`dd` (+ literals). Defaults per type:
  /// date/dateRange `'yyyy-MM-dd'`, month/monthRange `'yyyy-MM'`, year
  /// `'yyyy'` (★upstream has no year entry — see docs).
  final String? format;

  /// Upstream `disabledDate(date, options)`. Range types pass the day at
  /// midnight (upstream `startOfDay`).
  final bool Function(DateTime date, SemiDatePickerRangeInfo info)?
  disabledDate;

  /// Selection change ([SemiDatePickerChanged]).
  final SemiDatePickerChanged? onChanged;

  /// Panel visibility change (upstream `onOpenChange`).
  final ValueChanged<bool>? onOpenChange;

  /// Month navigation of the month-grid panels (upstream `onPanelChange`;
  /// reports the changed panel's visible month — a range upstream reports
  /// both panels, see docs).
  final void Function(DateTime visibleDate, String text)? onPanelChange;

  /// Clear-button callback (upstream `onClear`).
  final VoidCallback? onClear;

  /// Blur/focus reports (upstream event-object signatures are trimmed).
  final VoidCallback? onBlur;
  final VoidCallback? onFocus;

  /// Preset click (fires alongside the selection change — upstream
  /// `onPresetClick`).
  final void Function(SemiDatePickerPreset preset)? onPresetClick;

  /// Controlled panel visibility (non-null = controlled).
  final bool? open;

  /// Uncontrolled initial visibility.
  final bool defaultOpen;

  /// Quick-control presets ([SemiDatePickerPreset]).
  final List<SemiDatePickerPreset> presets;

  /// Upstream `presetPosition` (default bottom). ★monthRange renders no
  /// presets (upstream "todo" gap).
  final SemiDatePickerPresetPosition presetPosition;

  /// Header text of the left/right preset panels (upstream `locale.presets`,
  /// zh-CN `快捷选择`; top/bottom panels have no header upstream).
  final String? presetHeader;

  /// First day of the week: 0 = Sunday .. 6 = Saturday (upstream
  /// `weekStartsOn`, default 0).
  final int weekStartsOn;

  /// After a year/month navigation the selection follows into the new month
  /// (day clamped to month end) without closing (upstream `autoSwitchDate`,
  /// default true; aborts when `disabledDate` rejects).
  final bool autoSwitchDate;

  /// Locks the two range panels to move together and hides the inner
  /// navigation buttons (upstream `syncSwitchMonth`, default false).
  final bool syncSwitchMonth;

  /// Trigger size (upstream `size`; range triggers map large → 40px).
  final SemiInputSize size;

  /// Trigger validate status (★`success` carries no visuals upstream).
  final SemiInputStatus validateStatus;

  final bool disabled;
  final bool borderless;

  /// Read-only trigger input (typed text is ignored; panel picks still work).
  final bool inputReadOnly;

  /// Clear button visibility gate — ★upstream defaults to `true` (the button
  /// itself shows on hover/focus with a non-empty value).
  final bool showClear;

  /// `String` (both inputs) or `List<String>` (start/end) placeholder.
  final Object? placeholder;

  /// Prefix slot (`String` | `Widget`), also covering [insetLabel] (the
  /// SemiInput slot conventions).
  final Object? prefix;

  /// Inset label (String renders bold; shares the prefix slot).
  final Object? insetLabel;

  /// Trigger text style overlay (the 13px upstream font is the base).
  final TextStyle? inputStyle;

  /// Range text join (upstream `rangeSeparator`, default `' ~ '`).
  final String rangeSeparator;

  /// Popup position (upstream `position`); default `bottomLeft`
  /// (`bottomRight` in RTL, datePicker.tsx:864-866).
  final SemiTooltipPosition? position;

  final bool autoAdjustOverflow;
  final bool motion;

  /// Focus the trigger on mount.
  final bool autofocus;

  /// Trigger semantics label (upstream `aria-label`).
  final String? semanticsLabel;

  final SemiDatePickerController? controller;

  @override
  State<SemiDatePicker> createState() => _SemiDatePickerState();
}

enum _YMChange { prevMonth, nextMonth, prevYear, nextYear }

enum _PanelSide { left, right }

enum _NavIcon { chevronLeft, chevronRight, doubleLeft, doubleRight }

class _SemiDatePickerState extends State<SemiDatePicker> {
  // -- state (ports of the foundation / monthsGrid state) --------------------

  bool _open = false;

  /// Internal selection buffer (uncontrolled); range types hold 2 when
  /// complete. Upstream `foundation.state.value`.
  List<DateTime> _value = const [];

  /// Staging input text (null = display the formatted value). Upstream
  /// `state.inputValue`.
  String? _inputValue;

  /// The range being picked (upstream monthsGrid `rangeStart`/`rangeEnd`
  /// strings — kept separately from `value`, ★a half-picked range shows in
  /// the grid/inputs but never lands).
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  /// Which range input is being edited (upstream `rangeInputFocus`).
  SemiDatePickerRangeFocus? _rangeInputFocus;

  /// focusRecordsRef — both records are marked with a zero-delay deferral
  /// (upstream `setTimeout(0)`, datePicker.tsx:338/358) so the close check of
  /// the pick that caused the focus never sees the new record.
  bool _focusStartRecord = false;
  bool _focusEndRecord = false;

  DateTime? _hoverDay;
  late DateTime _pickerLeft;
  late DateTime _pickerRight;
  bool _yamLeftOpen = false;
  bool _yamRightOpen = false;

  bool _triggerHovering = false;
  bool _clearHovered = false;
  Object? _repositionKey = Object();

  final FocusNode _triggerFocusNode = FocusNode(debugLabel: 'SemiDatePicker');
  final FocusNode _startFocusNode = FocusNode(
    debugLabel: 'SemiDatePicker.start',
  );
  final FocusNode _endFocusNode = FocusNode(debugLabel: 'SemiDatePicker.end');

  @override
  void initState() {
    super.initState();
    _initFromProps(assignState: false);
    _open = (widget.open ?? widget.defaultOpen) && !widget.disabled;
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(SemiDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (oldWidget.value != widget.value || oldWidget.type != widget.type) {
      _initFromProps();
    }
    if (oldWidget.open != widget.open) {
      // Upstream componentDidUpdate: a controlled `open` drives the panel and
      // closing only resets the inner state.
      if ((widget.open ?? false) && !_open && !widget.disabled) {
        _togglePanel(true);
      } else if (!(widget.open ?? false) && _open) {
        _togglePanel(false);
      }
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _triggerFocusNode.dispose();
    _startFocusNode.dispose();
    _endFocusNode.dispose();
    super.dispose();
  }

  /// `initFromProps` (foundation.ts:250) + the monthsGrid panel init.
  void _initFromProps({bool assignState = true}) {
    final raw = widget.value ?? widget.defaultValue;
    final value = _normalizeValue(raw);
    final now = DateTime.now();
    var left = value.isNotEmpty
        ? DateTime(value.first.year, value.first.month, 1)
        : DateTime(now.year, now.month, 1);
    var right = value.length > 1
        ? DateTime(value[1].year, value[1].month, 1)
        : _addMonths(left, 1);
    // `_autoAdjustMonth` (monthsGridFoundation.ts:784): swap inverted panels,
    // push a same-month right panel one month out.
    if (right.year * 12 + right.month < left.year * 12 + left.month) {
      (left, right) = (right, left);
    } else if (right.year == left.year && right.month == left.month) {
      right = _addMonths(left, 1);
    }
    void apply() {
      _value = value;
      _inputValue = null;
      _rangeStart = _isRange && value.isNotEmpty ? value.first : null;
      _rangeEnd = _isRange && value.length > 1 ? value[1] : null;
      _pickerLeft = left;
      _pickerRight = right;
      _yamLeftOpen = false;
      _yamRightOpen = false;
    }

    if (assignState) {
      setState(apply);
    } else {
      apply();
    }
  }

  // -- derived --------------------------------------------------------------

  bool get _isRange =>
      widget.type == SemiDatePickerType.dateRange ||
      widget.type == SemiDatePickerType.monthRange;

  bool get _isYearOrMonthType =>
      widget.type == SemiDatePickerType.month ||
      widget.type == SemiDatePickerType.monthRange ||
      widget.type == SemiDatePickerType.year;

  bool get _controlledValue => widget.value != null;
  bool get _controlledOpen => widget.open != null;

  String get _formatToken =>
      widget.format ??
      switch (widget.type) {
        SemiDatePickerType.date || SemiDatePickerType.dateRange => 'yyyy-MM-dd',
        SemiDatePickerType.month || SemiDatePickerType.monthRange => 'yyyy-MM',
        SemiDatePickerType.year => 'yyyy',
      };

  List<DateTime> get _effectiveValue =>
      widget.value != null ? _normalizeValue(widget.value) : _value;

  String get _display {
    if (_inputValue != null) return _inputValue!;
    if (_isRange) {
      final start = _rangeStart;
      final end = _rangeEnd;
      if (start == null && end == null) return '';
      if (start != null && end != null) {
        return '${_dpFormat(start, _formatToken)}${widget.rangeSeparator}${_dpFormat(end, _formatToken)}';
      }
      return start != null
          ? '${_dpFormat(start, _formatToken)}${widget.rangeSeparator}'
          : '${widget.rangeSeparator}${_dpFormat(end!, _formatToken)}';
    }
    return _formatDates(_effectiveValue.cast<DateTime?>());
  }

  // -- value plumbing -------------------------------------------------------

  List<DateTime> _normalizeValue(Object? raw) {
    if (raw == null) return const [];
    final list = raw is List ? raw : [raw];
    final out = <DateTime>[];
    for (final item in list) {
      // ★ `_parseValue`: `0` is a valid timestamp (`new Date(0)`); entries
      // that parse to nothing are dropped (upstream warns and skips).
      final parsed = _dpParseValue(item, widget.format);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  /// `formatDates` (foundation.ts:869): single values format flat, ranges join
  /// with [SemiDatePicker.rangeSeparator].
  String _formatDates(List<DateTime?> dates) {
    if (dates.isEmpty) return '';
    switch (widget.type) {
      case SemiDatePickerType.date:
      case SemiDatePickerType.month:
      case SemiDatePickerType.year:
        final d = dates.first;
        return d == null ? '' : _dpFormat(d, _formatToken);
      case SemiDatePickerType.dateRange:
      case SemiDatePickerType.monthRange:
        // Upstream keeps the empty side's slot (`'start ~ '` / `' ~ end'`).
        final start = dates.isNotEmpty ? dates[0] : null;
        final end = dates.length > 1 ? dates[1] : null;
        if (start != null && end != null) {
          return '${_dpFormat(start, _formatToken)}${widget.rangeSeparator}${_dpFormat(end, _formatToken)}';
        }
        if (start != null) {
          return '${_dpFormat(start, _formatToken)}${widget.rangeSeparator}';
        }
        if (end != null) {
          return '${widget.rangeSeparator}${_dpFormat(end, _formatToken)}';
        }
        return '';
    }
  }

  /// `parseInput` (foundation.ts:669): ★the parse must round-trip
  /// (parse → format === input) to be accepted.
  List<DateTime> _parseInput(String input) {
    if (input.isEmpty) return const [];
    if (!_isRange) {
      final parsed = _dpCompatibleParse(input, _formatToken, DateTime.now());
      if (parsed != null && _dpFormat(parsed, _formatToken) == input) {
        return [parsed];
      }
      return const [];
    }
    final parts = input.split(widget.rangeSeparator);
    final out = <DateTime>[];
    for (final part in parts) {
      final parsed = part.isEmpty
          ? null
          : _dpCompatibleParse(part, _formatToken, DateTime.now());
      if (parsed == null || _dpFormat(parsed, _formatToken) != part) {
        return const [];
      }
      out.add(parsed);
    }
    out.sort(_dpCompareDays);
    return out;
  }

  /// `parseInputLoose` (foundation.ts:737): keeps `null` slots for parts that
  /// do not round-trip.
  List<DateTime?> _parseInputLoose(String input) {
    if (input.isEmpty) return const [];
    if (!_isRange) {
      final parsed = _dpCompatibleParse(input, _formatToken, DateTime.now());
      if (parsed != null && _dpFormat(parsed, _formatToken) == input) {
        return [parsed];
      }
      return [null];
    }
    final parts = input.split(widget.rangeSeparator);
    final out = <DateTime?>[
      for (final part in parts)
        () {
          final parsed = part.isEmpty
              ? null
              : _dpCompatibleParse(part, _formatToken, DateTime.now());
          if (parsed != null && _dpFormat(parsed, _formatToken) == part) {
            return parsed;
          }
          return null;
        }(),
    ];
    if (out.every((d) => d != null)) {
      out.sort((a, b) => _dpCompareDays(a!, b!));
    }
    return out;
  }

  /// `_isRangeValueComplete` (foundation.ts:1270): ★an empty array counts as
  /// complete (clear/confirm paths rely on it).
  bool _isRangeValueComplete(List<DateTime?> dates) =>
      !dates.any((d) => d == null);

  bool _isDisabledDate(DateTime date, [SemiDatePickerRangeInfo? info]) {
    final callback = widget.disabledDate;
    if (callback == null) return false;
    return callback(
      DateTime(date.year, date.month, date.day),
      info ??
          SemiDatePickerRangeInfo(
            rangeStart: _rangeStart,
            rangeEnd: _rangeEnd,
            rangeInputFocus: _rangeInputFocus,
          ),
    );
  }

  /// `_someDateDisabled` (foundation.ts:1216): range types check the day at
  /// midnight and pass the pending selection as info.
  bool _someDateDisabled(List<DateTime?> dates, List<DateTime?> selected) {
    final info = SemiDatePickerRangeInfo(
      rangeStart: _isRange && selected.isNotEmpty ? selected[0] : null,
      rangeEnd: _isRange && selected.length > 1 ? selected[1] : null,
      rangeInputFocus: _rangeInputFocus,
    );
    for (final date in dates) {
      if (date != null && _isDisabledDate(date, info)) return true;
    }
    return false;
  }

  // -- open model -----------------------------------------------------------

  void _controllerOpen() {
    if (widget.disabled) return;
    if (!_controlledOpen) _togglePanel(true);
    widget.onOpenChange?.call(true);
  }

  void _controllerClose() {
    if (!_controlledOpen) {
      _togglePanel(false);
    } else {
      _resetInnerSelectedStates();
    }
    widget.onOpenChange?.call(false);
  }

  /// `openPanel` (foundation.ts:358).
  void _openPanel() {
    if (widget.disabled) return;
    if (!_controlledOpen) _togglePanel(true);
    widget.onOpenChange?.call(true);
  }

  /// `closePanel` (foundation.ts:397): a controlled `open` only resets the
  /// inner state.
  void _closePanel() {
    if (!_controlledOpen) {
      _togglePanel(false);
    } else {
      _resetInnerSelectedStates();
    }
    widget.onOpenChange?.call(false);
  }

  void _togglePanel(bool panelShow) {
    setState(() {
      _open = panelShow;
      if (!panelShow) {
        // Upstream adapter.togglePanel: closing resets the focus records.
        _focusStartRecord = false;
        _focusEndRecord = false;
        _yamLeftOpen = false;
        _yamRightOpen = false;
      }
    });
    if (!panelShow) _resetInnerSelectedStates();
  }

  /// `resetInnerSelectedStates` (foundation.ts:437): clear the staging input
  /// and drop the range focus (upstream `resetFocus` also notifies `onBlur`).
  void _resetInnerSelectedStates() {
    final hadFocus = _rangeInputFocus != null;
    setState(() {
      _inputValue = null;
      _rangeInputFocus = null;
    });
    if (hadFocus) widget.onBlur?.call();
  }

  /// SemiTooltip `onVisibleChange`: outside-barrier hits report `false`
  /// (`needConfirm` is deferred, so outside clicks always close — the select
  /// `_handleTooltipVisibleChange` sync precedent).
  void _handleTooltipVisibleChange(bool visible) {
    if (!mounted) return;
    if (visible == _open) return;
    if (visible) {
      _openPanel();
    } else {
      _closePanel();
    }
  }

  void _handleTriggerTap() {
    if (widget.disabled) return;
    if (_isRange && _rangeInputFocus == null) {
      // Upstream handleTriggerWrapperClick: without an input focus the panel
      // opens with the start input focused (setTimeout(0)).
      _setRangeInputFocus(SemiDatePickerRangeFocus.rangeStart);
    }
    _openPanel();
  }

  // -- focus records (focusRecordsRef) --------------------------------------

  /// Upstream adapter.setRangeInputFocus: the focus state applies immediately,
  /// the focus RECORD is marked in a zero-delay deferral (datePicker.tsx:338).
  void _setRangeInputFocus(SemiDatePickerRangeFocus focus) {
    final first = _rangeInputFocus == null;
    setState(() => _rangeInputFocus = focus);
    final node = focus == SemiDatePickerRangeFocus.rangeStart
        ? _startFocusNode
        : _endFocusNode;
    node.requestFocus();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      setState(() {
        if (focus == SemiDatePickerRangeFocus.rangeStart) {
          _focusStartRecord = true;
        } else {
          _focusEndRecord = true;
        }
      });
    });
    // `handleInputFocus`: `onFocus` fires only on the first focus of a range
    // session (or for non-range inputs).
    if (first || !_isRange) widget.onFocus?.call();
  }

  void _clearRangeInputFocus() {
    final hadFocus = _rangeInputFocus != null;
    setState(() => _rangeInputFocus = null);
    if (hadFocus) widget.onBlur?.call();
  }

  /// `couldPanelClosed` (datePicker.tsx:366): both inputs have been focused
  /// at least once.
  bool _couldPanelClosed() => _focusStartRecord && _focusEndRecord;

  /// `isAnotherPanelHasOpened` (datePicker.tsx:610): the OTHER input's record.
  bool _isAnotherPanelHasOpened(SemiDatePickerRangeFocus current) =>
      current == SemiDatePickerRangeFocus.rangeStart
      ? _focusEndRecord
      : _focusStartRecord;

  void _controllerFocus(SemiDatePickerRangeFocus? focusType) {
    if (_isRange) {
      _setRangeInputFocus(focusType ?? SemiDatePickerRangeFocus.rangeStart);
    } else {
      _startFocusNode.requestFocus();
      widget.onFocus?.call();
    }
  }

  void _controllerBlur() {
    if (_isRange) {
      _clearRangeInputFocus();
    }
    _startFocusNode.unfocus();
    _endFocusNode.unfocus();
    widget.onBlur?.call();
  }

  // -- input edits ----------------------------------------------------------

  /// `handleInputChange` (foundation.ts:505): a valid/empty input lands, an
  /// invalid one only stages.
  void _handleInputChange(String input) {
    final previous = _effectiveValue;
    final result = _parseInput(input);
    _updateCachedFromInput(input);
    if (result.isNotEmpty || input.isEmpty) {
      _updateValueAndInput(result, inputValue: input, force: input.isEmpty);
      if (!_someDateDisabled(result, result) && !listEquals(result, previous)) {
        _notifyChange(result);
      }
    } else {
      setState(() => _inputValue = input);
    }
  }

  /// `_updateCachedSelectedValueFromInput` (foundation.ts:561): the loose parse
  /// updates the pending range display of the grid.
  void _updateCachedFromInput(String input) {
    final loose = _parseInputLoose(input);
    if (!_isRange) return;
    if (loose.isEmpty) return;
    if (_someDateDisabled(loose, loose)) return;
    setState(() {
      _rangeStart = loose.isNotEmpty ? loose[0] : null;
      _rangeEnd = loose.length > 1 ? loose[1] : null;
    });
  }

  /// `handleInputComplete` (foundation.ts:634) — Enter: ★invalid/empty input
  /// falls back to the state value, else `DateTime.now()` / `[now, now]`.
  void _handleInputComplete() {
    final previous = _effectiveValue;
    final typed = _inputValue ?? '';
    var parsed = typed.isEmpty ? const <DateTime>[] : _parseInput(typed);
    if (parsed.isEmpty) parsed = previous;
    if (parsed.isEmpty) {
      final now = DateTime.now();
      parsed = _isRange ? [now, now] : [now];
    }
    _updateValueAndInput(parsed);
    if (!_someDateDisabled(parsed, parsed) && !listEquals(parsed, previous)) {
      _notifyChange(parsed);
    }
  }

  /// `_updateValueAndInput` (foundation.ts:946).
  void _updateValueAndInput(
    List<DateTime> value, {
    String? inputValue,
    bool force = false,
  }) {
    setState(() {
      if (force || value.isNotEmpty) {
        if (!_controlledValue && !_someDateDisabled(value, value)) {
          _value = value;
          if (_isRange) {
            _rangeStart = value.isNotEmpty ? value.first : null;
            _rangeEnd = value.length > 1 ? value[1] : null;
          }
        }
      }
      _inputValue = inputValue;
    });
  }

  void _notifyChange(List<DateTime?> value) {
    // ★ `_notifyChange` (foundation.ts:1166): a half-picked range never
    // notifies (an empty range counts as complete and does).
    if (_isRange && !_isRangeValueComplete(value)) return;
    final dates = value.whereType<DateTime>().toList();
    if (dates.isEmpty) {
      // Clear payload normalization (upstream reports type-dependent
      // `undefined`/`[]`; docs/semi_date_picker.md).
      widget.onChanged?.call(null, '');
      return;
    }
    final Object payload = _isRange ? List<DateTime>.from(dates) : dates.first;
    widget.onChanged?.call(payload, _formatDates(value));
  }

  void _handleInputClear() {
    // Single-type clear (upstream handleInputChange('') through the clear
    // button, plus notifyClear). The empty text also routes through
    // `onChanged('')` -> `_handleInputChange('')`, which lands the empty
    // value and emits the normalized `(null, '')` change exactly once.
    _updateValueAndInput(const [], inputValue: '', force: true);
    if (!_controlledValue) setState(() => _value = const []);
    widget.onClear?.call();
  }

  void _handleRangeInputClear() {
    // `handleRangeInputClear` (foundation.ts:617).
    setState(() {
      if (!_controlledValue) _value = const [];
      _inputValue = '';
      _rangeStart = null;
      _rangeEnd = null;
    });
    _clearRangeInputFocus();
    widget.onChanged?.call(null, '');
    widget.onClear?.call();
  }

  // -- selection (month grid) -----------------------------------------------

  /// `handleDayClick` (monthsGridFoundation.ts:596).
  void _handleDayClick(DateTime day, _PanelSide side) {
    switch (widget.type) {
      case SemiDatePickerType.date:
        _handleDateSelected(day, side);
      case SemiDatePickerType.dateRange:
        _handleRangeSelected(day);
      case SemiDatePickerType.month:
      case SemiDatePickerType.monthRange:
      case SemiDatePickerType.year:
        break;
    }
  }

  /// `handleDateSelected` (monthsGridFoundation.ts:610).
  void _handleDateSelected(DateTime day, _PanelSide side) {
    final dates = [day];
    final previous = _effectiveValue;
    _showDateOnPanel(side, day);
    if (!_controlledValue) {
      setState(() => _value = dates);
    }
    if (!_someDateDisabled(dates, dates) && !listEquals(dates, previous)) {
      _notifyChange(dates);
    }
    _closePanel();
  }

  /// `handleRangeSelected` (monthsGridFoundation.ts:673): ★picking an end
  /// before the start nulls the start (and re-focuses the start input);
  /// picking a start after the end nulls the end.
  void _handleRangeSelected(DateTime day) {
    var start = _rangeStart;
    var end = _rangeEnd;
    var startReset = false;
    var endReset = false;
    final focus = _rangeInputFocus;

    if (focus == SemiDatePickerRangeFocus.rangeEnd) {
      end = day;
      if (start != null && _dpCompareDays(day, start) < 0) {
        start = null;
        startReset = true;
      }
    } else {
      // rangeStart or unfocused.
      start = day;
      if (end != null && _dpCompareDays(end, day) < 0) {
        end = null;
        endReset = true;
      }
    }
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
    });

    // Next-focus logic (monthsGridFoundation.ts:703).
    if (focus == SemiDatePickerRangeFocus.rangeEnd) {
      if (startReset ||
          !_isAnotherPanelHasOpened(SemiDatePickerRangeFocus.rangeEnd) ||
          start == null) {
        _setRangeInputFocus(SemiDatePickerRangeFocus.rangeStart);
      }
    } else {
      if (endReset ||
          !_isAnotherPanelHasOpened(SemiDatePickerRangeFocus.rangeStart) ||
          end == null) {
        _setRangeInputFocus(SemiDatePickerRangeFocus.rangeEnd);
      }
    }

    if (start != null || end != null) {
      _handleSelectedChange([start, end]);
    }
  }

  /// `handleSelectedChange` (foundation.ts:969).
  void _handleSelectedChange(
    List<DateTime?> dates, {
    bool closePanel = true,
    bool needCheckFocusRecord = true,
    bool fromPreset = false,
  }) {
    final previous = _effectiveValue;
    final complete = _isRangeValueComplete(dates);
    if (!_someDateDisabled(dates, dates)) {
      final typed = dates.whereType<DateTime>().toList();
      final text = _formatDates(dates);
      if (_isRange && !complete) {
        // ★ #1357: an incomplete range updates the input display only.
        setState(() {
          _inputValue = text;
          _rangeStart = dates.isNotEmpty ? dates[0] : null;
          _rangeEnd = dates.length > 1 ? dates[1] : null;
        });
        return;
      }
      setState(() {
        if (!_controlledValue || fromPreset) {
          _value = typed;
          if (_isRange) {
            _rangeStart = typed.isNotEmpty ? typed.first : null;
            _rangeEnd = typed.length > 1 ? typed[1] : null;
          }
        }
        _inputValue = null;
      });
      if (!listEquals(typed, previous)) {
        _notifyChange(_isRange ? dates : typed);
      }
    }

    final focusRecordChecked = !needCheckFocusRecord || _couldPanelClosed();
    final shouldClose =
        (widget.type == SemiDatePickerType.date && closePanel) ||
        (widget.type == SemiDatePickerType.dateRange &&
            complete &&
            closePanel &&
            focusRecordChecked);
    if (shouldClose) _closePanel();
  }

  /// `updateDateAfterChangeYM` (monthsGridFoundation.ts:559) — autoSwitchDate:
  /// the selection follows into the new year/month (day clamped to the month
  /// end, e.g. 01-31 → 02-29) without closing; aborted when disabledDate
  /// rejects. ★Only single non-range selections follow (the upstream
  /// `includeRange` gate is dead code — see docs).
  void _updateDateAfterChangeYM(DateTime target) {
    if (!widget.autoSwitchDate) return;
    if (_isRange) return;
    final current = _effectiveValue;
    if (current.isEmpty) return;
    final selected = current.first;
    final day = selected.day.clamp(1, _daysInMonth(target.year, target.month));
    final fullDate = DateTime(target.year, target.month, day);
    final info = SemiDatePickerRangeInfo(
      rangeStart: _rangeStart,
      rangeEnd: _rangeEnd,
      rangeInputFocus: _rangeInputFocus,
    );
    if (_isDisabledDate(fullDate, info)) return;
    _handleSelectedChange([fullDate], closePanel: false);
  }

  // -- navigation (month grid) ----------------------------------------------

  /// `handleYearOrMonthChange` (monthsGridFoundation.ts:515).
  void _handleYearOrMonthChange(
    _YMChange change,
    _PanelSide side, {
    int step = 1,
    bool notSeparateInRange = false,
  }) {
    final picker = side == _PanelSide.left ? _pickerLeft : _pickerRight;
    final DateTime target;
    switch (change) {
      case _YMChange.prevMonth:
        target = _addMonths(picker, -step);
      case _YMChange.nextMonth:
        target = _addMonths(picker, step);
      case _YMChange.prevYear:
        target = _addMonths(picker, -12 * step);
      case _YMChange.nextYear:
        target = _addMonths(picker, 12 * step);
    }
    final updated = _setPicker(side, target);
    // `notifyPanelChange` — the changed panel's visible month (a range
    // upstream reports both panels; see docs).
    if (updated && !(notSeparateInRange && side == _PanelSide.left)) {
      widget.onPanelChange?.call(target, _dpFormat(target, _formatToken));
    }
    _updateDateAfterChangeYM(target);
  }

  bool _setPicker(_PanelSide side, DateTime target) {
    final current = side == _PanelSide.left ? _pickerLeft : _pickerRight;
    final changed =
        current.year != target.year || current.month != target.month;
    setState(() {
      if (side == _PanelSide.left) {
        _pickerLeft = target;
      } else {
        _pickerRight = target;
      }
      _repositionKey = Object();
    });
    return changed;
  }

  /// `handleSwitchMonthOrYear` (monthsGridFoundation.ts:385): syncSwitchMonth
  /// moves both panels together (inner buttons hidden); otherwise the OTHER
  /// panel is nudged off a same-month collision (handleSyncChangeMonths,
  /// monthsGridFoundation.ts:318).
  void _handleSwitch(_YMChange change, _PanelSide side) {
    final rangeType = _isRange;
    if (rangeType && widget.syncSwitchMonth) {
      _handleYearOrMonthChange(
        change,
        _PanelSide.left,
        notSeparateInRange: true,
      );
      _handleYearOrMonthChange(
        change,
        _PanelSide.right,
        notSeparateInRange: true,
      );
    } else {
      _handleYearOrMonthChange(change, side);
      if (rangeType) {
        final target = side == _PanelSide.left ? _pickerLeft : _pickerRight;
        _handleSyncChangeMonths(side, target);
      }
    }
  }

  void _handleSyncChangeMonths(_PanelSide side, DateTime target) {
    if (side == _PanelSide.right &&
        target.year == _pickerLeft.year &&
        target.month == _pickerLeft.month) {
      _handleYearOrMonthChange(
        _YMChange.prevMonth,
        _PanelSide.left,
        notSeparateInRange: true,
      );
    } else if (side == _PanelSide.left &&
        _pickerRight.year == target.year &&
        _pickerRight.month == target.month) {
      _handleYearOrMonthChange(
        _YMChange.nextMonth,
        _PanelSide.right,
        notSeparateInRange: true,
      );
    }
  }

  /// `toMonth`/`toYearMonth` (monthsGridFoundation.ts:360) — the yam overlay
  /// navigates the grid by the calendar-month difference (no overshoot).
  void _toYearMonth(_PanelSide side, DateTime target) {
    final picker = side == _PanelSide.left ? _pickerLeft : _pickerRight;
    final diff =
        (target.year - picker.year) * 12 + (target.month - picker.month);
    if (diff == 0) return;
    _handleYearOrMonthChange(
      diff < 0 ? _YMChange.prevMonth : _YMChange.nextMonth,
      side,
      step: diff.abs(),
    );
    if (_isRange) _handleSyncChangeMonths(side, target);
  }

  /// `handleShowDateAndTime` — move a panel to the month of `date`.
  void _showDateOnPanel(_PanelSide side, DateTime date) {
    _setPicker(side, DateTime(date.year, date.month, 1));
    if (_isRange) {
      // `_autoAdjustMonth`: keep the right panel strictly after the left.
      if (_pickerRight.year == _pickerLeft.year &&
          _pickerRight.month == _pickerLeft.month) {
        _setPicker(_PanelSide.right, _addMonths(_pickerLeft, 1));
      }
    }
  }

  // -- year/month selection (standalone yam types) --------------------------

  /// `handleYMSelectedChange` (foundation.ts:1028). ★month/monthRange/year
  /// selection does NOT close the panel (the upstream close block covers
  /// date/dateRange only — foundation.ts:1019).
  void _handleYamPick({
    required int year,
    required int month,
    required _PanelSide target,
  }) {
    if (widget.type == SemiDatePickerType.monthRange) {
      // yearAndMonthFoundation.selectYear/selectMonth ordering rules.
      var yearLeft = _rangeStart?.year ?? DateTime.now().year;
      var monthLeft = _rangeStart?.month ?? DateTime.now().month;
      var yearRight = _rangeEnd?.year ?? yearLeft;
      var monthRight = _rangeEnd?.month ?? monthLeft;
      if (target == _PanelSide.left) {
        if (year > yearRight || (year == yearRight && month > monthRight)) {
          // selectYear: `year[right] = item.value + 1` when the left moves
          // past the right; selectMonth catches up the right month.
          if (month > monthRight && year == yearRight) {
            monthRight = month;
          } else {
            yearRight = year + 1;
          }
        }
        yearLeft = year;
        monthLeft = month;
      } else {
        if (year < yearLeft || (year == yearLeft && month < monthLeft)) {
          yearLeft = year;
          monthLeft = month;
        }
        yearRight = year;
        monthRight = month;
      }
      setState(() {
        _rangeStart = DateTime(yearLeft, monthLeft);
        _rangeEnd = DateTime(yearRight, monthRight);
      });
      _handleSelectedChange([
        DateTime(yearLeft, monthLeft),
        DateTime(yearRight, monthRight),
      ]);
    } else {
      // month / year (upstream routes `year` through the broken range branch
      // and its formatDates has no `year` case — the port selects a single
      // value; docs/semi_date_picker.md).
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
      });
      _handleSelectedChange([DateTime(year, month)]);
    }
  }

  // -- presets --------------------------------------------------------------

  /// `handlePresetClick` (foundation.ts:1069): ★lazy function values are
  /// invoked at click time; a `{start: null, end: null}` preset clears the
  /// range (an empty array counts as complete) and closes the panel;
  /// disabled-date presets do not notify; `onPresetClick` always fires.
  void _handlePresetClick(SemiDatePickerPreset item) {
    final start = item.start is Function
        ? (item.start! as dynamic Function()).call()
        : item.start;
    final end = item.end is Function
        ? (item.end! as dynamic Function()).call()
        : item.end;
    final dates = _isRange
        ? <DateTime?>[
            start == null ? null : _dpParseValue(start, widget.format),
            end == null ? null : _dpParseValue(end, widget.format),
          ]
        : <DateTime?>[
            start == null ? null : _dpParseValue(start, widget.format),
          ];
    final typed = dates.whereType<DateTime>().toList();
    if (_isRange && typed.isEmpty) {
      // The clearing preset (upstream parseWithTimezone([null, null]) → []).
      setState(() {
        if (!_controlledValue) _value = const [];
        _inputValue = null;
        _rangeStart = null;
        _rangeEnd = null;
      });
      _notifyChange(const []);
      _closePanel();
    } else {
      _handleSelectedChange(
        dates,
        needCheckFocusRecord: false,
        fromPreset: true,
      );
    }
    widget.onPresetClick?.call(item);
  }

  // -- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = SemiDatePickerTheme.resolve(context);
    return Semantics(
      container: true,
      button: true,
      enabled: !widget.disabled,
      label:
          widget.semanticsLabel ??
          (_effectiveValue.isEmpty
              ? _DatePickerMetrics.chooseDateLabel
              : _DatePickerMetrics.changeDateLabel),
      child: SemiTooltip(
        content: _buildPanel(theme),
        trigger: SemiTooltipTrigger.custom,
        visible: _open,
        onVisibleChange: _handleTooltipVisibleChange,
        showArrow: false,
        popupBare: true,
        position: widget.position ?? _defaultPosition(context),
        autoAdjustOverflow: widget.autoAdjustOverflow,
        motion: widget.motion,
        zIndex: _DatePickerMetrics.popoverZIndex,
        repositionKey: _repositionKey,
        child: Focus(
          focusNode: _triggerFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: (focused) {
            if (!focused) widget.onBlur?.call();
          },
          child: Listener(
            // Upstream `.semi-datepicker-popover-trigger` wrapper onClick:
            // pointer events bypass the editable's gesture arena (the select
            // trigger's GestureDetector loses taps to inner inputs).
            onPointerDown: (_) => _handleTriggerTap(),
            behavior: HitTestBehavior.translucent,
            child: MouseRegion(
              cursor: widget.disabled
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              onEnter: (_) => setState(() => _triggerHovering = true),
              onExit: (_) => setState(() => _triggerHovering = false),
              child: _buildTrigger(theme),
            ),
          ),
        ),
      ),
    );
  }

  SemiTooltipPosition _defaultPosition(BuildContext context) {
    // ★ RTL flips the default (datePicker.tsx:864-866).
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return rtl
        ? SemiTooltipPosition.bottomRight
        : SemiTooltipPosition.bottomLeft;
  }

  // -- trigger --------------------------------------------------------------

  TextStyle get _inputTextStyle => TextStyle(
    // `font-size: 13px` (datePicker.scss:844). Never set `height`.
    fontSize: _DatePickerMetrics.triggerFontSize,
  ).merge(widget.inputStyle);

  Widget _buildTrigger(SemiResolvedDatePickerThemeData t) {
    if (_isRange && widget.type != SemiDatePickerType.monthRange) {
      return _buildRangeTrigger(t);
    }
    return _buildSingleTrigger(t);
  }

  String? _placeholderFor(int index) {
    final placeholder = widget.placeholder;
    if (placeholder is List) {
      return index < placeholder.length ? placeholder[index] as String? : null;
    }
    return placeholder as String?;
  }

  Widget _buildSingleTrigger(SemiResolvedDatePickerThemeData t) {
    final icon = SemiIcon(
      SemiIcons.calendar,
      color: t.colorDatepickerInputPrimaryTextDefault,
    );
    return SemiInput(
      value: _display,
      size: widget.size,
      validateStatus: widget.validateStatus,
      disabled: widget.disabled,
      readonly: widget.inputReadOnly,
      borderless: widget.borderless,
      placeholder: widget.type == SemiDatePickerType.monthRange
          ? '${_placeholderFor(0) ?? ''}${widget.rangeSeparator}${_placeholderFor(1) ?? ''}'
          : _placeholderFor(0),
      prefix: widget.prefix,
      insetLabel: widget.insetLabel,
      suffix: icon,
      showClear: widget.showClear,
      hideSuffix: widget.showClear,
      inputStyle: _inputTextStyle,
      semanticsLabel: widget.semanticsLabel,
      onChanged: widget.inputReadOnly ? null : _handleInputChange,
      onEnterPress: _handleInputComplete,
      onClear: _handleInputClear,
      focusNode: _startFocusNode,
    );
  }

  /// The `renderRangeInput` geometry (dateInput.tsx:232): prefix slot, -start
  /// wrapper, separator, -end wrapper, clear button, suffix.
  Widget _buildRangeTrigger(SemiResolvedDatePickerThemeData t) {
    final separator = widget.rangeSeparator;
    // dateInput.tsx:254 — the two fields split one text (the staged input
    // while typing, the formatted pending range otherwise).
    final String startText;
    final String endText;
    if (_inputValue != null) {
      final parts = _inputValue!.split(separator);
      startText = parts.first;
      endText = parts.length > 1 ? parts.last : '';
    } else {
      startText = _rangeStart == null
          ? ''
          : _dpFormat(_rangeStart!, _formatToken);
      endText = _rangeEnd == null ? '' : _dpFormat(_rangeEnd!, _formatToken);
    }
    final hasText =
        _rangeStart != null ||
        _rangeEnd != null ||
        (_inputValue?.isNotEmpty ?? false);
    final active = _rangeInputFocus != null && !widget.disabled;
    final showClearButton =
        widget.showClear &&
        !widget.disabled &&
        hasText &&
        (_triggerHovering || active);

    final Color bg;
    if (widget.disabled) {
      bg = t.colorDatepickerRangeInputDisabledBgDefault;
    } else {
      bg = switch (widget.validateStatus) {
        SemiInputStatus.warning => t.colorDatepickerRangeInputWarningBgDefault,
        // ★ upstream paints the error row's background from the
        // `-error-border-default` field (datePicker.scss:1068) — the
        // `-error-bg-default` variable is dead.
        SemiInputStatus.error => t.colorDatepickerRangeInputErrorBorderDefault,
        _ => t.colorDatepickerRangeInputBgDefault,
      };
    }
    final borderColor = active
        ? switch (widget.validateStatus) {
            SemiInputStatus.warning =>
              t.colorDatepickerRangeInputWarningBorderActive,
            SemiInputStatus.error =>
              t.colorDatepickerRangeInputErrorBorderActive,
            _ => t.colorDatepickerRangeInputBorderActive,
          }
        : t.colorDatepickerRangeInputBorderDefault;

    final height = switch (widget.size) {
      SemiInputSize.small => t.heightDatepickerRangeInputSmall,
      SemiInputSize.normal => t.heightDatepickerRangeInputDefault,
      SemiInputSize.large => t.heightDatepickerRangeInputLarge,
    };
    final innerFontSize = widget.size == SemiInputSize.large
        ? t.fontDatepickerRangeInputLargeFontSize
        : _DatePickerMetrics.triggerFontSize;

    return Semantics(
      container: true,
      enabled: !widget.disabled,
      child: MouseRegion(
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: DecoratedBox(
          key: const Key('SemiDatePicker.rangeTrigger'),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(t.radiusDatepickerRangeInput),
            border: Border.all(
              width: t.widthDatepickerRangeInputBorder,
              color: borderColor,
            ),
          ),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                if (widget.prefix != null || widget.insetLabel != null)
                  _RangeSlot(
                    key: const Key('SemiDatePicker.rangePrefix'),
                    padding: EdgeInsetsDirectional.only(
                      start: t.spacingDatepickerRangeInputPrefixPaddingLeft,
                      end: t.spacingDatepickerRangeInputPrefixPaddingRight,
                    ),
                    onTap: widget.disabled
                        ? null
                        : () => _setRangeInputFocus(
                            SemiDatePickerRangeFocus.rangeStart,
                          ),
                    child: _prefixWidget(t),
                  ),
                Expanded(
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: widget.disabled
                        ? null
                        : (_) => _setRangeInputFocus(
                            SemiDatePickerRangeFocus.rangeStart,
                          ),
                    child: _RangeInputWrapper(
                      focused:
                          _rangeInputFocus ==
                          SemiDatePickerRangeFocus.rangeStart,
                      disabled: widget.disabled,
                      validateStatus: widget.validateStatus,
                      theme: t,
                      child: SemiInput(
                        value: startText,
                        size: widget.size == SemiInputSize.large
                            ? SemiInputSize.normal
                            : SemiInputSize.small,
                        disabled: widget.disabled,
                        readonly: widget.inputReadOnly,
                        bare: true,
                        borderless: true,
                        placeholder: _placeholderFor(0),
                        inputStyle: TextStyle(fontSize: innerFontSize),
                        onChanged: widget.inputReadOnly
                            ? null
                            : (v) =>
                                  _handleRangeSideEdit(start: v, end: endText),
                        onEnterPress: _handleInputComplete,
                        focusNode: _startFocusNode,
                      ),
                    ),
                  ),
                ),
                // Separator: upstream centers it with `translateX(±50%)` on a
                // half-width slot; the port centers with layout (RTL flips).
                Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: widget.disabled
                      ? null
                      : (_) => _setRangeInputFocus(
                          SemiDatePickerRangeFocus.rangeStart,
                        ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          t.spacingDatepickerInsetInputSeparatorPaddingX,
                    ),
                    child: Text(
                      separator,
                      style: _inputTextStyle.copyWith(
                        fontSize: t
                            .fontDatepickerRangeInputPrefixSuffixClearbtnFontSize,
                        fontWeight: FontWeight.w600,
                        color: hasText && !widget.disabled
                            ? t.colorDatepickerRangeInputSeparatorTextActive
                            : t.colorDatepickerRangeInputTextDefault,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    // ★ Tab on the range-end input unfocuses
                    // (`handleRangeEndTabPress` → `setRangeInputFocus(false)`).
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.tab) {
                        _clearRangeInputFocus();
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: widget.disabled
                          ? null
                          : (_) => _setRangeInputFocus(
                              SemiDatePickerRangeFocus.rangeEnd,
                            ),
                      child: _RangeInputWrapper(
                        focused:
                            _rangeInputFocus ==
                            SemiDatePickerRangeFocus.rangeEnd,
                        disabled: widget.disabled,
                        validateStatus: widget.validateStatus,
                        theme: t,
                        child: SemiInput(
                          value: endText,
                          size: widget.size == SemiInputSize.large
                              ? SemiInputSize.normal
                              : SemiInputSize.small,
                          disabled: widget.disabled,
                          readonly: widget.inputReadOnly,
                          bare: true,
                          borderless: true,
                          placeholder: _placeholderFor(1),
                          inputStyle: TextStyle(fontSize: innerFontSize),
                          onChanged: widget.inputReadOnly
                              ? null
                              : (v) => _handleRangeSideEdit(
                                  start: startText,
                                  end: v,
                                ),
                          onEnterPress: _handleInputComplete,
                          focusNode: _endFocusNode,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showClearButton)
                  _RangeSlot(
                    key: SemiDatePicker.clearButtonKey,
                    padding: EdgeInsetsDirectional.only(
                      start: t.spacingDatepickerRangeInputClearbtnPaddingLeft,
                      end: t.spacingDatepickerRangeInputClearbtnPaddingRight,
                    ),
                    onHover: (hovered) =>
                        setState(() => _clearHovered = hovered),
                    onTap: widget.disabled ? null : _handleRangeInputClear,
                    child: Semantics(
                      button: true,
                      label: _DatePickerMetrics.clearRangeLabel,
                      child: SemiIcon(
                        SemiIcons.clear,
                        color: _clearHovered
                            ? t.colorDatepickerRangeInputClearbtnIconHover
                            : t.colorDatepickerRangeInputTextDefault,
                      ),
                    ),
                  ),
                _RangeSlot(
                  key: const Key('SemiDatePicker.rangeSuffix'),
                  padding: EdgeInsetsDirectional.only(
                    start: t.spacingDatepickerRangeInputSuffixPaddingLeft,
                    end: t.spacingDatepickerRangeInputSuffixPaddingRight,
                  ),
                  onTap: widget.disabled
                      ? null
                      : () => _setRangeInputFocus(
                          SemiDatePickerRangeFocus.rangeStart,
                        ),
                  child: SemiIcon(
                    SemiIcons.calendar,
                    color: t.colorDatepickerInputPrimaryTextDefault,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// `handleRangeInputChange` (dateInput.tsx:140): the two fields edit one
  /// joined string.
  void _handleRangeSideEdit({required String start, required String end}) {
    _handleInputChange('$start${widget.rangeSeparator}$end');
  }

  Widget _prefixWidget(SemiResolvedDatePickerThemeData t) {
    final slot = widget.prefix ?? widget.insetLabel;
    if (slot is String) {
      return Text(
        slot,
        style: TextStyle(
          fontSize: t.fontDatepickerRangeInputPrefixSuffixClearbtnFontSize,
          fontWeight: FontWeight.w600,
          color: widget.disabled
              ? t.colorDatepickerRangeInputDisabledTextDefault
              : t.colorDatepickerRangeInputTextDefault,
        ),
      );
    }
    return slot! as Widget;
  }

  // -- panel ----------------------------------------------------------------

  Widget _buildPanel(SemiResolvedDatePickerThemeData t) {
    final global = SemiTheme.of(context);
    final presets = _buildPresets(t);
    final content = _isYearOrMonthType
        ? _buildYamPanel(t, standalone: true)
        : _buildMonthGrids(t);
    final showPresets = presets != null;

    final Widget inner;
    switch (widget.presetPosition) {
      case SemiDatePickerPresetPosition.left when showPresets:
        inner = Row(
          mainAxisSize: MainAxisSize.min,
          children: [presets, content],
        );
      case SemiDatePickerPresetPosition.right when showPresets:
        inner = Row(
          mainAxisSize: MainAxisSize.min,
          children: [content, presets],
        );
      case SemiDatePickerPresetPosition.top when showPresets:
        inner = Column(
          mainAxisSize: MainAxisSize.min,
          children: [presets, content],
        );
      case _ when showPresets:
        inner = Column(
          mainAxisSize: MainAxisSize.min,
          children: [content, presets],
        );
      default:
        inner = content;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: global.colors.colorBg3,
        border: Border.all(width: 1, color: global.colors.colorBorder),
        borderRadius: BorderRadius.circular(
          global.radius.borderRadiusMedium.value,
        ),
        boxShadow: _DatePickerMetrics.shadowElevated,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          global.radius.borderRadiusMedium.value,
        ),
        child: inner,
      ),
    );
  }

  // -- month grids ----------------------------------------------------------

  Widget _buildMonthGrids(SemiResolvedDatePickerThemeData t) {
    final left = _buildMonthPanel(t, _PanelSide.left, _pickerLeft);
    if (!_isRange) return left;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [left, _buildMonthPanel(t, _PanelSide.right, _pickerRight)],
    );
  }

  Widget _buildMonthPanel(
    SemiResolvedDatePickerThemeData t,
    _PanelSide side,
    DateTime month,
  ) {
    final yamOpen = side == _PanelSide.left ? _yamLeftOpen : _yamRightOpen;
    final hideInner = _isRange && widget.syncSwitchMonth;
    return Padding(
      // `&-month { width: $width-datepicker_month; padding:
      // $spacing-datepicker_month-padding; padding-top: 0 }` (content-box).
      padding: EdgeInsets.fromLTRB(
        t.spacingDatepickerMonthPadding,
        0,
        t.spacingDatepickerMonthPadding,
        t.spacingDatepickerMonthPadding,
      ),
      child: SizedBox(
        width: t.widthDatepickerMonth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavigation(t, side, month, hideInner: hideInner),
            if (yamOpen)
              _buildYamPanel(t, standalone: false, side: side)
            else
              _buildMonthGrid(t, side, month),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(
    SemiResolvedDatePickerThemeData t,
    _PanelSide side,
    DateTime month, {
    required bool hideInner,
  }) {
    final strings = SemiLocalizations.of(context);
    Widget button(
      Key key,
      String label,
      _NavIcon icon,
      VoidCallback? onTap, {
      bool hidden = false,
    }) {
      // `visibility: hidden` keeps the icon in position (navigation.tsx:89).
      return Semantics(
        button: true,
        label: label,
        child: Opacity(
          opacity: hidden ? 0 : 1,
          child: IgnorePointer(
            ignoring: hidden,
            child: GestureDetector(
              key: key,
              onTap: widget.disabled ? null : onTap,
              child: SizedBox(
                width: _DatePickerMetrics.navButtonMinWidth,
                height: _DatePickerMetrics.navButtonMinWidth,
                child: Center(
                  // `display: flex; justify-content: center; align-items: center;`
                  // (the all-center mixin).
                  child: _navIcon(t, icon),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final leftSide = side == _PanelSide.left;
    // syncSwitchMonth hides the inner buttons (left panel's right pair, right
    // panel's left pair).
    final hideRightButtons = hideInner && leftSide;
    final hideLeftButtons = hideInner && !leftSide;
    return Row(
      children: [
        button(
          SemiDatePicker.navPrevYearKey,
          strings.previousYear,
          _NavIcon.doubleLeft,
          () => _handleSwitch(_YMChange.prevYear, side),
          hidden: hideLeftButtons,
        ),
        button(
          SemiDatePicker.navPrevMonthKey,
          strings.previousMonth,
          _NavIcon.chevronLeft,
          () => _handleSwitch(_YMChange.prevMonth, side),
          hidden: hideLeftButtons,
        ),
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              key: side == _PanelSide.left
                  ? SemiDatePicker.monthTitleKey
                  : SemiDatePicker.monthTitleRightKey,
              onTap: widget.disabled
                  ? null
                  : () {
                      setState(() {
                        if (side == _PanelSide.left) {
                          _yamLeftOpen = !_yamLeftOpen;
                        } else {
                          _yamRightOpen = !_yamRightOpen;
                        }
                        _repositionKey = Object();
                      });
                    },
              child: Container(
                height: _DatePickerMetrics.navButtonMinWidth,
                alignment: Alignment.center,
                child: Text(
                  strings.monthTitle(month.year, month.month),
                  style: TextStyle(
                    fontSize: _DatePickerMetrics.fontSizeHeader6,
                    fontWeight: FontWeight.w600,
                    color: t.colorDatepickerNavMonthIconTextDefault,
                  ),
                ),
              ),
            ),
          ),
        ),
        button(
          SemiDatePicker.navNextMonthKey,
          strings.nextMonth,
          _NavIcon.chevronRight,
          () => _handleSwitch(_YMChange.nextMonth, side),
          hidden: hideRightButtons,
        ),
        button(
          SemiDatePicker.navNextYearKey,
          strings.nextYear,
          _NavIcon.doubleRight,
          () => _handleSwitch(_YMChange.nextYear, side),
          hidden: hideRightButtons,
        ),
      ],
    );
  }

  Widget _navIcon(SemiResolvedDatePickerThemeData t, _NavIcon icon) {
    final color = t.colorDatepickerNavIconTextDefault;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final iconWidget = switch (icon) {
      _NavIcon.chevronLeft => SemiIcon(SemiIcons.chevronLeft, color: color),
      _NavIcon.chevronRight => SemiIcon(SemiIcons.chevronRight, color: color),
      _NavIcon.doubleLeft => SemiIcon(
        SemiIcons.doubleChevronLeft,
        color: color,
      ),
      _NavIcon.doubleRight => SemiIcon(
        SemiIcons.doubleChevronRight,
        color: color,
      ),
    };
    // ★ RTL flips the arrows (upstream `scaleX(-1)` — rtl.scss).
    return Transform.flip(flipX: rtl, child: iconWidget);
  }

  Widget _buildMonthGrid(
    SemiResolvedDatePickerThemeData t,
    _PanelSide side,
    DateTime month,
  ) {
    final weeks = _dpGetWeeks(month, widget.weekStartsOn);
    final labels = SemiLocalizations.of(context).weekdays;
    final start = widget.weekStartsOn;
    final rotated = [for (var i = 0; i < 7; i++) labels[(start + i) % 7]];
    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weekday row: `@include font-size-small` (12px), bold, text-2,
          // `border-bottom: $width-datepicker-border solid` (1px border).
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: t.widthDatepickerBorder,
                  color: t.colorDatepickerBorderBgDefault,
                ),
              ),
            ),
            child: Row(
              children: [
                for (final label in rotated)
                  SizedBox(
                    width: t.widthDatepickerDay,
                    height: t.widthDatepickerDay,
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: _DatePickerMetrics.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: t.colorDatepickerDayTextDefault,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // `const height = weeksRowNum * numbers.WEEK_HEIGHT;` (month.tsx:293,
          // WEEK_HEIGHT 36).
          SizedBox(
            height: weeks.length * _DatePickerMetrics.weekHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final week in weeks)
                  Row(
                    children: [
                      for (final day in week)
                        if (day == null)
                          SizedBox(
                            width: t.widthDatepickerDay,
                            height: t.widthDatepickerDay,
                          )
                        else
                          _buildDayCell(t, day, side),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- day cell -------------------------------------------------------------

  /// Day states (month.tsx getSingleDayStatus/getDateRangeStatus + the
  /// datePicker.scss day rules).
  Widget _buildDayCell(
    SemiResolvedDatePickerThemeData t,
    DateTime day,
    _PanelSide side,
  ) {
    final value = _effectiveValue;
    final today = DateTime.now();
    final isToday = _dpIsSameDay(day, today);
    final isSelected = value.any((d) => _dpIsSameDay(d, day));
    final isDisabled = _isDayDisabled(day);

    // Range states (getDateRangeStatus).
    final rangeStart = _rangeStart;
    final rangeEnd = _rangeEnd;
    final hoverDay = _hoverDay;
    final isHoverDay = hoverDay != null && _dpIsSameDay(day, hoverDay);
    final anySelected = rangeStart != null || rangeEnd != null;
    final bothSelected = rangeStart != null && rangeEnd != null;
    bool isInRange = false;
    bool isHover = false;
    bool hoverDayInStartSelection = false;
    bool hoverDayInEndSelection = false;
    bool hoverDayAroundOneSelected = false;
    if (anySelected) {
      bool hoverAfterStart = false;
      bool hoverBeforeEnd = false;
      if (rangeStart != null &&
          _rangeInputFocus == SemiDatePickerRangeFocus.rangeEnd &&
          hoverDay != null) {
        hoverAfterStart = _dpIsBetween(day, rangeStart, hoverDay);
      }
      if (rangeEnd != null &&
          _rangeInputFocus == SemiDatePickerRangeFocus.rangeStart &&
          hoverDay != null) {
        hoverBeforeEnd = _dpIsBetween(day, hoverDay, rangeEnd);
      }
      isHover = hoverAfterStart || hoverBeforeEnd || isHoverDay;
      if (!bothSelected) {
        hoverDayAroundOneSelected = isHoverDay;
      }
      if (bothSelected) {
        isInRange = _dpIsBetween(day, rangeStart, rangeEnd);
        hoverDayInStartSelection =
            isHoverDay &&
            _rangeInputFocus == SemiDatePickerRangeFocus.rangeStart;
        hoverDayInEndSelection =
            isHoverDay && _rangeInputFocus == SemiDatePickerRangeFocus.rangeEnd;
      }
    }

    // Background precedence mirrors the scss cascade (disabled > selected >
    // hover previews > in-range/hover path > hoverday > plain).
    final Color? bg;
    final BorderRadius radius;
    final bool fullWidth;
    if (isDisabled) {
      // ★ `&-disabled`: a plain disabled day keeps a transparent background
      // (disabled-fill only paints disabled days that also carry a
      // selection/hover class — datePicker.scss:536-570).
      final covered = isSelected || isInRange || isHover || isHoverDay;
      bg = covered ? t.colorDatepickerDateDisabledBgDefault : null;
      radius = BorderRadius.circular(t.widthDatepickerDayMainBorderRadius);
      fullWidth = false;
    } else if (isSelected) {
      bg = t.colorDatepickerDateSelectedBgDefault;
      radius = BorderRadius.circular(t.widthDatepickerDayMainBorderRadius);
      fullWidth = false;
    } else if (hoverDayAroundOneSelected ||
        hoverDayInStartSelection ||
        hoverDayInEndSelection) {
      // `hoverday-around-singleselected` (its own field) /
      // `hoverday-beforerange` / `hoverday-afterrange`
      // (`hoverday_range-bg-default`); the beforerange/afterrange rows keep
      // their half-rounded caps.
      bg = hoverDayAroundOneSelected
          ? t.colorDatepickerDateHoverdayAroundSingleSelectedBgDefault
          : t.colorDatepickerDateHoverdayRangeBgDefault;
      radius = hoverDayInStartSelection
          ? BorderRadius.horizontal(
              left: Radius.circular(t.widthDatepickerDayMainBorderRadius),
            )
          : hoverDayInEndSelection
          ? BorderRadius.horizontal(
              right: Radius.circular(t.widthDatepickerDayMainBorderRadius),
            )
          : BorderRadius.zero;
      fullWidth = true;
    } else if (isInRange || isHover) {
      // `inrange`/`inhover` (the ★hovered day itself is `inhover` too —
      // isHover folds `_isHoverDay` in month.tsx:172).
      bg = t.colorDatepickerDateInHoverBgDefault;
      radius = BorderRadius.zero;
      fullWidth = true;
    } else if (isHoverDay) {
      // Plain hover (no range preview): the `:hover` row paints date-bg-hover.
      bg = t.colorDatepickerDateBgHover;
      radius = BorderRadius.circular(t.widthDatepickerDayMainBorderRadius);
      fullWidth = false;
    } else {
      bg = null;
      radius = BorderRadius.circular(t.widthDatepickerDayMainBorderRadius);
      fullWidth = false;
    }

    final Color textColor;
    if (isDisabled) {
      textColor = isToday
          ? t.colorDatepickerDateTodayDisabledTextDefault
          : t.colorDatepickerDateDisabledTextDefault;
    } else if (isSelected) {
      textColor = t.colorDatepickerDateSelectedTextDefault;
    } else if (isToday) {
      textColor = t.colorDatepickerDateTodayTextDefault;
    } else {
      textColor = t.colorDatepickerDateTextDefault;
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      selected: isSelected,
      label: _dpFormat(day, 'yyyy-MM-dd'),
      child: MouseRegion(
        cursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoverDay = day),
        onExit: (_) => setState(() => _hoverDay = null),
        child: GestureDetector(
          key: SemiDatePicker.dayKey(day),
          onTap: isDisabled ? null : () => _handleDayClick(day, side),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: t.widthDatepickerDay,
            height: t.widthDatepickerDay,
            child: Center(
              // `display: flex; justify-content: center; align-items: center;`
              // (the all-center mixin).
              child: Container(
                width: fullWidth
                    ? t.widthDatepickerDay
                    : t.widthDatepickerDayMain,
                height: _DatePickerMetrics.dayMainHeight,
                decoration: BoxDecoration(color: bg, borderRadius: radius),
                alignment: Alignment.center,
                child: Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: _DatePickerMetrics.fontSizeRegular,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `getSingleDayStatus` disabled rules (month.tsx:101): the `disabledDate`
  /// callback plus ★range-side linking — once the opposite side has been
  /// picked (and its input focused at least once), days beyond it are disabled.
  bool _isDayDisabled(DateTime day) {
    if (_isDisabledDate(day)) return true;
    if (!_isRange) return false;
    final start = _rangeStart;
    final end = _rangeEnd;
    if (_rangeInputFocus == SemiDatePickerRangeFocus.rangeStart &&
        end != null &&
        _focusEndRecord) {
      return _dpCompareDays(day, end) > 0;
    }
    if (_rangeInputFocus == SemiDatePickerRangeFocus.rangeEnd &&
        start != null &&
        _focusStartRecord) {
      return _dpCompareDays(day, start) < 0;
    }
    return false;
  }

  // -- year and month panel -------------------------------------------------

  /// The yam picker (upstream scroll-wheel mechanics simplified to selectable
  /// lists; docs/semi_date_picker.md). [standalone] renders the
  /// month/monthRange/year pickers (no back button, value selection);
  /// otherwise it overlays a month-grid panel (back button, grid navigation —
  /// ★the overlay stays open after a selection, yearSelectionCallbacks).
  Widget _buildYamPanel(
    SemiResolvedDatePickerThemeData t, {
    required bool standalone,
    _PanelSide side = _PanelSide.left,
  }) {
    int yearLeft, monthLeft, yearRight, monthRight;
    if (standalone) {
      final left = _rangeStart ?? _effectiveValue.firstOrNull ?? DateTime.now();
      final right =
          _rangeEnd ?? (_effectiveValue.length > 1 ? _effectiveValue[1] : left);
      yearLeft = left.year;
      monthLeft = left.month;
      yearRight = right.year;
      monthRight = right.month;
    } else {
      yearLeft = _pickerLeft.year;
      monthLeft = _pickerLeft.month;
      yearRight = _pickerRight.year;
      monthRight = _pickerRight.month;
    }

    void pick(int year, int month, _PanelSide target) {
      if (standalone) {
        _handleYamPick(year: year, month: month, target: target);
      } else {
        // Overlay: navigate the month grid (toYearMonth) — the overlay stays
        // open (upstream yearSelectionCallbacks tests).
        _toYearMonth(target, DateTime(year, month));
      }
    }

    Widget column(
      int selectedYear,
      int selectedMonth,
      _PanelSide target, {
      int? minYear,
      int? minMonth,
    }) {
      return _YamColumn(
        theme: t,
        selectedYear: selectedYear,
        selectedMonth: selectedMonth,
        minYear: minYear,
        minMonth: minMonth,
        onYear: (year) => pick(year, selectedMonth, target),
        onMonth: (month) => pick(selectedYear, month, target),
        disabledDate: widget.disabledDate == null
            ? null
            : (year, month) => _isDisabledDate(DateTime(year, month)),
      );
    }

    final Widget? header = standalone
        ? null
        : Row(
            children: [
              Semantics(
                button: true,
                label: _DatePickerMetrics.yamBackLabel,
                child: GestureDetector(
                  key: SemiDatePicker.yamBackKey,
                  onTap: () => setState(() {
                    if (side == _PanelSide.left) {
                      _yamLeftOpen = false;
                    } else {
                      _yamRightOpen = false;
                    }
                    _repositionKey = Object();
                  }),
                  child: Row(
                    children: [
                      SemiIcon(
                        SemiIcons.chevronLeft,
                        color: t.colorDatepickerNavIconTextDefault,
                      ),
                      Text(
                        _DatePickerMetrics.yamBackLabel,
                        style: TextStyle(
                          fontSize: _DatePickerMetrics.fontSizeRegular,
                          color: t.colorDatepickerNavMonthIconTextDefault,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

    final Widget body;
    if (widget.type == SemiDatePickerType.monthRange) {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          column(yearLeft, monthLeft, _PanelSide.left),
          // `border-left: 1px solid var(--semi-color-border)`
          // (datePicker.scss:188, the yam two-column separator).
          Container(
            width: _DatePickerMetrics.separatorBorderWidth,
            color: t.colorDatepickerBorderBgDefault,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          column(
            yearRight,
            monthRight,
            _PanelSide.right,
            minYear: yearLeft,
            minMonth: yearLeft == yearRight ? monthLeft : null,
          ),
        ],
      );
    } else {
      body = column(yearLeft, monthLeft, side);
    }

    return Container(
      width: widget.type == SemiDatePickerType.monthRange
          ? t.widthDatepickerMonthRangePanelMax
          : t.widthDatepickerMonthPanelMax,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?header,
          SizedBox(height: t.heightDatepickerPanelYamScrolllist, child: body),
        ],
      ),
    );
  }

  // -- presets --------------------------------------------------------------

  Widget? _buildPresets(SemiResolvedDatePickerThemeData t) {
    if (widget.presets.isEmpty) return null;
    // ★ monthRange renders no presets (upstream "todo" gap).
    if (widget.type == SemiDatePickerType.monthRange) return null;
    final isTopBottom =
        widget.presetPosition == SemiDatePickerPresetPosition.top ||
        widget.presetPosition == SemiDatePickerPresetPosition.bottom;
    final columns = !isTopBottom
        ? 2
        : switch (widget.type) {
            SemiDatePickerType.dateRange => 5,
            SemiDatePickerType.month => 2,
            _ => 3,
          };

    // Item width from the presetPanel `_content` chain (the 5px/3px scrollbar
    // paddings of the CSS grid are approximated by the Wrap spacing).
    final itemWidth = switch (columns) {
      2 when !isTopBottom =>
        t.widthDatepickerPresetPanelLeftAndRightTwoColButton,
      2 => t.widthDatepickerPresetPanelTopAndBottomTwoColButton,
      3 => t.widthDatepickerPresetPanelTopAndBottomThreeColButton,
      _ => t.widthDatepickerPresetPanelTopAndBottomFiveColButton,
    };

    final Widget? header = isTopBottom
        ? null
        : Padding(
            padding: EdgeInsets.only(
              top: t.spacingDatepickerQuickControlHeaderPaddingTop,
            ),
            child: Text(
              // Upstream `locale.presets` (zh-CN `快捷选择`).
              widget.presetHeader ?? _DatePickerMetrics.presetHeaderDefault,
              style: TextStyle(
                fontSize: _DatePickerMetrics.fontSizeRegular,
                fontWeight: FontWeight.w600,
                color: t.colorDatepickerNavMonthIconTextDefault,
              ),
            ),
          );

    return SizedBox(
      width: isTopBottom ? null : t.widthDatepickerPresetPanelLeftAndRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?header,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTopBottom
                  ? t.spacingDatepickerQuickControlTopAndBottomContentPaddingX
                  : t.spacingDatepickerQuickControlContentPaddingX,
            ),
            child: Wrap(
              spacing: t.spacingDatepickerQuickControlItemMargin,
              runSpacing: t.spacingDatepickerQuickControlItemMargin,
              children: [
                for (var i = 0; i < widget.presets.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: SemiButton(
                      widget.presets[i].text ?? '',
                      key: SemiDatePicker.presetKey(i),
                      type: SemiButtonType.primary,
                      variant: SemiButtonVariant.solid,
                      size: SemiButtonSize.small,
                      onPressed: widget.disabled
                          ? null
                          : () => _handlePresetClick(widget.presets[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeSlot extends StatefulWidget {
  const _RangeSlot({
    super.key,
    required this.padding,
    required this.child,
    this.onTap,
    this.onHover,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;

  @override
  State<_RangeSlot> createState() => _RangeSlotState();
}

class _RangeSlotState extends State<_RangeSlot> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => widget.onHover?.call(true),
      onExit: (_) => widget.onHover?.call(false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
  }
}

/// The inner range input wrapper (fill-1 background while focused —
/// `$color-datepicker_range_input_inputWrapper-bg-focus`; the warning/error
/// rows follow the scss wrapper-active states).
class _RangeInputWrapper extends StatelessWidget {
  const _RangeInputWrapper({
    required this.focused,
    required this.disabled,
    required this.validateStatus,
    required this.theme,
    required this.child,
  });

  final bool focused;
  final bool disabled;
  final SemiInputStatus validateStatus;
  final SemiResolvedDatePickerThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Color bg = theme.colorDatepickerRangeInputInputWrapperBgDefault;
    if (!disabled && focused) {
      bg = switch (validateStatus) {
        SemiInputStatus.warning =>
          theme.colorDatepickerRangeInputWarningBgActive,
        SemiInputStatus.error => theme.colorDatepickerRangeInputErrorBgActive,
        _ => theme.colorDatepickerRangeInputInputWrapperBgFocus,
      };
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: theme.colorDatepickerRangeInputInputWrapperBorderDefault,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: theme.spacingDatepickerRangeInputInputWrapperInputPaddingY,
          horizontal:
              theme.spacingDatepickerRangeInputInputWrapperInputPaddingX,
        ),
        child: child,
      ),
    );
  }
}

/// The year/month picker column pair (the upstream scroll wheels simplified to
/// two selectable lists; docs/semi_date_picker.md).
class _YamColumn extends StatelessWidget {
  const _YamColumn({
    required this.theme,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYear,
    required this.onMonth,
    this.minYear,
    this.minMonth,
    this.disabledDate,
  });

  final SemiResolvedDatePickerThemeData theme;
  final int selectedYear;
  final int selectedMonth;

  /// monthRange right-panel constraints (yearAndMonthFoundation + the
  /// `needDisabled` rows of yearAndMonth.tsx:137/209).
  final int? minYear;
  final int? minMonth;
  final ValueChanged<int> onYear;
  final ValueChanged<int> onMonth;
  final bool Function(int year, int month)? disabledDate;

  static const int _yearSpan = 100;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startYear = now.year - _yearSpan;
    final endYear = now.year + _yearSpan;

    Widget list(
      List<({int value, String label, bool selected, bool disabled})> items,
      ValueChanged<int> onSelect,
    ) {
      return SingleChildScrollView(
        // Eager list (the upstream scroll wheels are simplified — all items
        // stay in the tree; docs/semi_date_picker.md).

        child: Column(
          children: [
            for (final item in items)
              GestureDetector(
                onTap: item.disabled ? null : () => onSelect(item.value),
                child: Container(
                  height: theme.heightDatepickerYamLiCompact,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.selected
                        ? theme.colorDatepickerDateBgDefault
                        : null,
                    borderRadius: BorderRadius.circular(
                      theme.widthDatepickerDayMainBorderRadius,
                    ),
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: _DatePickerMetrics.fontSizeRegular,
                      fontWeight: item.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: item.disabled
                          ? theme.colorDatepickerDateDisabledTextDefault
                          : item.selected
                          ? theme.colorDatepickerNavMonthIconTextDefault
                          : theme.colorDatepickerDayTextDefault,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final years = <({int value, String label, bool selected, bool disabled})>[
      for (var y = startYear; y <= endYear; y++)
        (
          value: y,
          label: y.toString(),
          selected: y == selectedYear,
          disabled:
              (minYear != null && y < minYear!) ||
              (disabledDate != null &&
                  List.generate(
                    12,
                    (m) => disabledDate!(y, m + 1),
                  ).every((disabled) => disabled)),
        ),
    ];
    final months = <({int value, String label, bool selected, bool disabled})>[
      for (var m = 1; m <= 12; m++)
        (
          value: m,
          label: SemiLocalizations.of(context).monthLabel(m),
          selected: m == selectedMonth,
          disabled:
              (minMonth != null && m < minMonth!) ||
              (disabledDate != null && disabledDate!(selectedYear, m)),
        ),
    ];

    return SizedBox(
      width: theme.widthDatepickerPanelYamScrolllistLiMin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: list(years, onYear)),
          Expanded(child: list(months, onMonth)),
        ],
      ),
    );
  }
}
