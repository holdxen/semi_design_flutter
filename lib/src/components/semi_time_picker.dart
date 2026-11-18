// SemiTimePicker — 时间选择器（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/timePicker/{foundation.ts, ComboxFoundation.ts,
// utils/index.ts, constants.ts}、packages/semi-ui/timePicker/{TimePicker.tsx,
// Combobox.tsx, TimeInput.tsx}。主题对账 20 = 14 FIELDS + 6 MOTION + 0
// INTERNAL（tool/generate_time_picker.py）——6 条 MOTION 全为死变量（上游未
// 消费），本文件不得出现其字段名（test_generate_time_picker.py 断言）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_TimePickerMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_time_picker_theme.dart';
import '../theme/semi_time_picker_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_input.dart';
import 'semi_tooltip.dart';

/// 面板种类：单选 / 时间范围。
enum SemiTimePickerType { time, timeRange }

/// 范围模式下面板方位（上游 `PanelType = 'left' | 'right'`）——`disabledTime`
/// 的 `side` 参数。
enum SemiTimePickerPanelSide { left, right }

/// `onChanged(date, dateStr)`：单选时 `date` 为 `DateTime`（清空为 `null`）、
/// `dateStr` 为格式化文本；范围时 `date` 为 `List<DateTime?>`、`dateStr` 为
/// `List<String>`（上游 `notifyChange` 回传 `Date | Date[]` 与
/// `string | string[]`——★dateStr 槽位必须放宽为 `Object?` 才能容纳范围的
/// 字符串列表，brief 的 `String?` 签名装不下，见 docs/semi_time_picker.md
/// 差异清单）。
/// ★固定 date-first 参数序（上游 `onChangeWithDateFirst` 固定 true）。
typedef SemiTimePickerChanged = void Function(Object? date, Object? dateStr);

/// 范围模式按面板覆盖禁用规则（上游 `disabledTime(value, panelType)` 的返回
/// 形状）；缺省成员回退顶层 `disabledHours`/`disabledMinutes`/`disabledSeconds`
/// （foundation.ts:74-95 `getDisabledTimeFns`）。仅 `type == timeRange` 时调用。
class SemiTimeDisabledSpec {
  const SemiTimeDisabledSpec({
    this.disabledHours,
    this.disabledMinutes,
    this.disabledSeconds,
  });

  final List<int> Function()? disabledHours;
  final List<int> Function(int hour)? disabledMinutes;
  final List<int> Function(int hour, int minute)? disabledSeconds;
}

/// Imperative handle（上游 ref 方法 `open`/`close`/`focus`/`blur`；
/// semi_date_picker.dart:84-117 attach/detach 先例）——脱离后 no-op。
class SemiTimePickerController {
  _SemiTimePickerState? _state;

  /// Opens the panel（非受控 `open`；受控 `open` 仍回报 `onOpenChange`）。
  void open() {
    _state?._controllerOpen();
  }

  /// Closes the panel.
  void close() {
    _state?._controllerClose();
  }

  /// Focuses the trigger input.
  void focus() {
    _state?._controllerFocus();
  }

  /// Blurs the trigger input.
  void blur() {
    _state?._controllerBlur();
  }

  void _attach(_SemiTimePickerState state) {
    _state = state;
  }

  void _detach(_SemiTimePickerState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// 时间选择器。
///
/// 值语义（上游 foundation.ts / ComboxFoundation.ts）：[value] / [defaultValue]
/// 宽入 `Object?`——`DateTime` 原样、`num` 毫秒时间戳（★`0` 合法）、`String`
/// 按 [format] 解析（基准今天）、`null`/`''` 为空。`type == timeRange` 时为
/// `List<Object?>`（长 0-2，允许空端 `null`/`''`，显示 `[start, end].join(rangeSeparator)`）。
/// ★受控惯例 `value != null` 即受控（上游 truthiness 判定，docs 注明）；释放
/// 控制保留最后显示值（semi_rating 先例）。
class SemiTimePicker extends StatefulWidget {
  const SemiTimePicker({
    super.key,
    this.type = SemiTimePickerType.time,
    this.value,
    this.defaultValue,
    this.format,
    this.use12Hours = false,
    this.infinite = true,
    this.hourStep,
    this.minuteStep,
    this.secondStep,
    this.disabledHours,
    this.disabledMinutes,
    this.disabledSeconds,
    this.disabledTime,
    this.hideDisabledOptions = false,
    this.rangeSeparator = _TimePickerMetrics.defaultRangeSeparator,
    this.open,
    this.defaultOpen,
    this.onOpenChange,
    this.onChanged,
    this.disabled = false,
    this.size = SemiInputSize.normal,
    this.showClear = true,
    this.clearText,
    this.clearIcon,
    this.inputReadOnly = false,
    this.borderless = false,
    this.placeholder,
    this.insetLabel,
    this.validateStatus,
    this.panelHeader,
    this.panelFooter,
    this.position,
    this.autoAdjustOverflow = true,
    this.motion = true,
    this.controller,
    this.child,
  }) : assert(hourStep == null || hourStep > 0, 'hourStep must be > 0'),
       assert(minuteStep == null || minuteStep > 0, 'minuteStep must be > 0'),
       assert(secondStep == null || secondStep > 0, 'secondStep must be > 0');

  static const Key panelKey = Key('SemiTimePicker.panel');
  static const Key hourListKey = Key('SemiTimePicker.hourList');
  static const Key minuteListKey = Key('SemiTimePicker.minuteList');
  static const Key secondListKey = Key('SemiTimePicker.secondList');
  static const Key ampmListKey = Key('SemiTimePicker.ampmList');
  static const Key inputKey = Key('SemiTimePicker.input');
  static const Key clearButtonKey = Key('SemiTimePicker.clearButton');

  final SemiTimePickerType type;

  /// 当前值；非空即受控。单选为 `DateTime | String | num`，范围为 `List<Object?>`。
  final Object? value;

  /// 非受控初始值（同 [value] 形状）。
  final Object? defaultValue;

  /// 时间格式 token（`HH`/`H`/`hh`/`h`/`mm`/`ss`/`a`/`A` 子集 + 字面分隔符）。
  /// 缺省 `use12Hours ? 'a h:mm:ss' : 'HH:mm:ss'`；非字符串回退 `'HH:mm:ss'`
  ///（Dart 类型系统下不可达，上游 `getValidFormat` 兜底留档）。
  final String? format;

  /// 12 小时制：出 AM/PM 列，小时列 `[12, 1..11]`。
  final bool use12Hours;

  /// 小时、分钟和秒列是否循环滚动。默认开启；设为 false 可保留有限普通列表行为。
  final bool infinite;

  /// 小时/分钟/秒步进（`generateOptions` 的 `step`），缺省 1。
  final int? hourStep;
  final int? minuteStep;
  final int? secondStep;

  /// 返回禁用值列表（24 小时制；12 小时制列内按
  /// ComboxFoundation.disabledHours 重映射）。
  final List<int> Function()? disabledHours;
  final List<int> Function(int hour)? disabledMinutes;
  final List<int> Function(int hour, int minute)? disabledSeconds;

  /// 仅范围生效（foundation.getDisabledTimeFns:74-95）；缺省成员回退顶层函数。
  final SemiTimeDisabledSpec Function(
    List<DateTime?> value,
    SemiTimePickerPanelSide side,
  )?
  disabledTime;

  /// true 时禁用项从列中移除（★selectedIndex 变 -1 → 回退第一个非禁用项，
  /// scrollItem.tsx:314-322）；false 保留置灰不可点。
  final bool hideDisabledOptions;

  /// 范围输入/回传的端点分隔符。
  final String rangeSeparator;

  /// 非空即受控（open != null）。
  final bool? open;
  final bool? defaultOpen;
  final ValueChanged<bool>? onOpenChange;

  /// 变更回传（date-first）；★变更判定用格式化字符串判等（foundation.ts:511-531
  /// `_hasChanged`——format 不含秒时 12:00:01 与 12:00:59 判「未变」）。
  final SemiTimePickerChanged? onChanged;

  final bool disabled;
  final SemiInputSize size;

  /// 清空按钮（disabled 时强制关；inputReadOnly 时仍可清——上游
  /// `showClearIgnoreDisabled` 语义，见 `_buildTrigger`）。
  final bool showClear;
  final String? clearText;
  final Widget? clearIcon;

  /// 只读输入（光标 `.semi-input-readonly { cursor: pointer }`；仍可清）。
  final bool inputReadOnly;

  /// 无边框输入（时钟图标 hover/focus 前 `opacity: 0`）。
  final bool borderless;

  final String? placeholder;
  final Widget? insetLabel;
  final SemiInputStatus? validateStatus;

  /// 面板头/脚插槽（范围模式缺省头 = 开始时间/结束时间，
  /// TimePicker.tsx `createPanelProps` 的 `defaultHeaderMap`）。
  final Widget? panelHeader;
  final Widget? panelFooter;

  /// 弹层位置；缺省 bottomLeft（RTL 时 bottomRight，foundation.getPosition）。
  final SemiTooltipPosition? position;
  final bool autoAdjustOverflow;
  final bool motion;
  final SemiTimePickerController? controller;

  /// triggerRender 替身——child 取代默认输入框触发器。
  final Widget? child;

  @override
  State<SemiTimePicker> createState() => _SemiTimePickerState();
}

class _SemiTimePickerState extends State<SemiTimePicker> {
  // -- state (foundation.ts state) ------------------------------------------

  bool _open = false;

  /// Internal value buffer (uncontrolled). Slots are null for empty endpoints.
  List<DateTime?> _value = const [];

  /// Staging input text (null = display the formatted value). Upstream
  /// `state.inputValue`.
  String? _inputValue;

  /// Upstream `state.invalid` — parse failure or a disabled HMS hit.
  bool _invalid = false;

  /// Per-slot AM/PM (foundation.ts:162-165 `isAM`).
  List<bool> _isAM = const [true];

  bool _triggerHovering = false;
  bool _focused = false;
  Object? _repositionKey = Object();

  final FocusNode _triggerFocusNode = FocusNode(
    debugLabel: 'SemiTimePicker.trigger',
  );
  final FocusNode _inputFocusNode = FocusNode(
    debugLabel: 'SemiTimePicker.input',
  );

  @override
  void initState() {
    super.initState();
    _initFromProps(assignState: false);
    _open = (widget.open ?? widget.defaultOpen ?? false) && !widget.disabled;
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(SemiTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    // ★释放控制（value 非空→空）保留最后显示值（semi_rating 先例）；进入控制
    // 或受控值/格式变化时重建内部状态（foundation.refreshProps）。
    // ★defaultValue 仅初值语义（上游 React 同款——getInitialState 只跑一次），
    // 不进重建条件：范围的内联 List 字面量每次重建都是新实例（恒等比较不等），
    // 若参与重建会把已选值回滚到种子（TimePickerPage 实测）。
    final released = oldWidget.value != null && widget.value == null;
    if (!released &&
        (oldWidget.value != widget.value ||
            oldWidget.type != widget.type ||
            oldWidget.format != widget.format ||
            oldWidget.use12Hours != widget.use12Hours)) {
      _initFromProps();
      _repositionKey = Object();
    }
    if (oldWidget.open != widget.open) {
      // Upstream componentDidUpdate: a controlled `open` drives the panel.
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
    _inputFocusNode.dispose();
    super.dispose();
  }

  // -- derived --------------------------------------------------------------

  bool get _isRange => widget.type == SemiTimePickerType.timeRange;
  bool get _controlledValue => widget.value != null;
  bool get _controlledOpen => widget.open != null;

  /// `getValidFormat`（foundation.ts:195-204）：props.format → 12h 默认 →
  /// `DEFAULT_FORMAT: 'HH:mm:ss'` / `DEFAULT_FORMAT_A: 'a h:mm:ss'`
  /// （timePicker/constants.ts:25/26）。
  String get _formatToken {
    final format = widget.format;
    if (format != null) return format;
    return widget.use12Hours
        ? _TimePickerMetrics.defaultFormatA
        : _TimePickerMetrics.defaultFormat;
  }

  /// `showHour`/`showMinute`/`showSecond`（ComboxFoundation.ts:72-74）：
  /// `format.match(/HH|hh|H|h/g)`、`format.match(/mm/g)`、
  /// `format.match(/ss/g)`。
  bool get _showHour => RegExp(r'HH|hh|H|h').hasMatch(_formatToken);
  bool get _showMinute => _formatToken.contains('mm');
  bool get _showSecond => _formatToken.contains('ss');

  List<DateTime?> get _effectiveValue =>
      widget.value != null ? _normalizeValue(widget.value).$1 : _value;

  String get _display {
    if (_inputValue != null) return _inputValue!;
    return _formatValue(_effectiveValue);
  }

  String get _placeholder {
    final placeholder = widget.placeholder;
    if (placeholder != null) return placeholder;
    final strings = SemiLocalizations.of(context);
    return _isRange ? strings.chooseTimeRange : strings.chooseTime;
  }

  // -- value plumbing -------------------------------------------------------

  /// `getInitialState`（foundation.ts:135-189）+ `parseToDate`
  /// String 按 format 解析（基准今天）、null/''→空。返回 (slots, 解析失败)。
  (List<DateTime?>, bool) _normalizeValue(Object? raw) {
    if (raw == null) return (const [], false);
    final list = raw is List ? raw : [raw];
    final slots = <DateTime?>[];
    var failed = false;
    for (final item in list) {
      if (item == null || item == '') {
        // 空端点合法（foundation.ts:191-193 `_isEmptyRangeEnd`）。
        slots.add(null);
        continue;
      }
      final parsed = _tpParseValue(item, _formatToken);
      if (parsed == null) failed = true;
      slots.add(parsed);
    }
    return (slots, failed);
  }

  /// `formatValue`（foundation.ts:429-452）：空槽 → `''`，端点 join
  /// [SemiTimePicker.rangeSeparator]。
  String _formatValue(List<DateTime?> dates) {
    final strings = SemiLocalizations.of(context);
    return dates
        .map(
          (d) => d == null
              ? ''
              : _tpFormat(d, _formatToken, am: strings.am, pm: strings.pm),
        )
        .join(
          widget.rangeSeparator == _TimePickerMetrics.defaultRangeSeparator
              ? strings.timeRangeSeparator
              : widget.rangeSeparator,
        );
  }

  /// `createDateDefault`（ComboxFoundation.ts:147-150）：面板兜底 = 今天
  /// 00:00:00。
  DateTime _createDateDefault() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 面板显示日期：空槽兜底今天 00:00:00（ComboxFoundation.ts:133-142
  /// `getDisplayDateFromTimeStamp`）。
  DateTime _panelDate(int index) {
    final value = _effectiveValue;
    if (index < value.length && value[index] != null) return value[index]!;
    return _createDateDefault();
  }

  /// `_hasChanged`（foundation.ts:511-531）：★格式化字符串判等——长度不等或任
  /// 一端格式化文本不同才算变更（format 不含秒时 12:00:01 与 12:00:59 判「未变」）。
  bool _hasChanged(List<DateTime?> dates, List<DateTime?> oldDates) {
    if (dates.length != oldDates.length) return true;
    for (var i = 0; i < dates.length; i++) {
      final date = dates[i];
      final oldDate = oldDates[i];
      if (date != null &&
          oldDate != null &&
          _tpFormat(date, _formatToken) == _tpFormat(oldDate, _formatToken)) {
        continue;
      }
      return true;
    }
    return false;
  }

  /// `_notifyChange`（foundation.ts:482-509）：date-first；范围回传
  /// `List<DateTime?>` + `List<String>`（input 按 rangeSeparator 切分）。
  void _notifyChange(List<DateTime?> value, String inputValue) {
    if (_isRange) {
      widget.onChanged?.call(
        value,
        inputValue.split(
          widget.rangeSeparator == _TimePickerMetrics.defaultRangeSeparator
              ? SemiLocalizations.of(context).timeRangeSeparator
              : widget.rangeSeparator,
        ),
      );
    } else {
      widget.onChanged?.call(value.isEmpty ? null : value.first, inputValue);
    }
  }

  /// `initDataFromDefaultValue`/`getInitialState`（foundation.ts:131-189）。
  void _initFromProps({bool assignState = true}) {
    final raw = widget.value ?? widget.defaultValue;
    final (slots, failed) = _normalizeValue(raw);
    final invalid = failed || _isDisabledAny(slots);
    final isAM = _initialIsAM(slots);
    void apply() {
      _value = slots;
      _inputValue = null;
      _invalid = invalid;
      _isAM = isAM;
    }

    if (assignState) {
      setState(apply);
    } else {
      apply();
    }
  }

  /// foundation.ts:162-165：`const isAM = [true, false]; parsedValues.map(...)`
  /// ——JS `map` 跳过空洞，空槽保留位置缺省（index 0 → AM，其余 → PM）。
  List<bool> _initialIsAM(List<DateTime?> slots) {
    final out = List<bool>.generate(slots.length, (i) => i == 0);
    for (var i = 0; i < slots.length; i++) {
      final d = slots[i];
      if (d != null) out[i] = d.hour < 12;
    }
    return out;
  }

  bool _isAMAt(int index) =>
      index < _isAM.length ? _isAM[index] : (index == 0 ? true : false);

  void _setIsAM(int index, bool value) {
    while (_isAM.length <= index) {
      _isAM = [..._isAM, _isAM.isEmpty ? true : false];
    }
    final next = [..._isAM];
    next[index] = value;
    _isAM = next;
  }

  // -- disabled -------------------------------------------------------------

  /// `getDisabledTimeFns`（foundation.ts:74-95）：`disabledTime` 仅范围生效，
  /// 返回成员缺省回退顶层函数。
  ({
    List<int> Function()? hours,
    List<int> Function(int hour)? minutes,
    List<int> Function(int hour, int minute)? seconds,
  })
  _disabledFns(int index) {
    if (_isRange && widget.disabledTime != null) {
      final side = index == 1
          ? SemiTimePickerPanelSide.right
          : SemiTimePickerPanelSide.left;
      final spec = widget.disabledTime!(_effectiveValue, side);
      return (
        hours: spec.disabledHours ?? widget.disabledHours,
        minutes: spec.disabledMinutes ?? widget.disabledMinutes,
        seconds: spec.disabledSeconds ?? widget.disabledSeconds,
      );
    }
    return (
      hours: widget.disabledHours,
      minutes: widget.disabledMinutes,
      seconds: widget.disabledSeconds,
    );
  }

  /// `disabledHours` 12h 重映射（ComboxFoundation.ts:98-110）：AM 取 `<12`
  /// 并把 0 映射为 12；PM 把 12 保持 12、其余减 12。
  List<int>? _remapDisabledHours(List<int>? options, bool isAM) {
    if (!widget.use12Hours || options == null) return options;
    return isAM
        ? options.where((h) => h < 12).map((h) => h == 0 ? 12 : h).toList()
        : options.map((h) => h == 12 ? 12 : h - 12).toList();
  }

  /// `isDisabledHMS`（foundation.ts:97-112）+ `validateDates:380-402`：值命中
  /// 禁用 HMS（空端点合法——foundation.ts:191-193）。
  bool _isDisabledHms(DateTime date, int index) {
    final fns = _disabledFns(index);
    final hours = fns.hours?.call();
    if (hours != null && hours.contains(date.hour)) return true;
    final minutes = fns.minutes?.call(date.hour);
    if (minutes != null && minutes.contains(date.minute)) return true;
    final seconds = fns.seconds?.call(date.hour, date.minute);
    if (seconds != null && seconds.contains(date.second)) return true;
    return false;
  }

  bool _isDisabledAny(List<DateTime?> slots) {
    for (var i = 0; i < slots.length; i++) {
      final d = slots[i];
      if (d != null && _isDisabledHms(d, i)) return true;
    }
    return false;
  }

  // -- open model -----------------------------------------------------------

  void _controllerOpen() {
    if (widget.disabled) return;
    _openPanel();
  }

  void _controllerClose() {
    _closePanel();
  }

  /// `handleFocus`（foundation.ts:285-290）：输入 focus 即开面板。
  void _handleFocus() {
    setState(() => _focused = true);
    if (!_open) _openPanel();
  }

  void _openPanel() {
    if (widget.disabled) return;
    if (!_controlledOpen) _togglePanel(true);
    widget.onOpenChange?.call(true);
  }

  void _closePanel() {
    if (!_controlledOpen) _togglePanel(false);
    widget.onOpenChange?.call(false);
  }

  void _togglePanel(bool panelShow) {
    setState(() => _open = panelShow);
  }

  /// SemiTooltip `onVisibleChange`：外点关报 `false`（datePicker
  /// `_handleTooltipVisibleChange` 先例）。disabled 不开。
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
    _openPanel();
  }

  void _controllerFocus() {
    _inputFocusNode.requestFocus();
  }

  void _controllerBlur() {
    _inputFocusNode.unfocus();
  }

  // -- input edits ----------------------------------------------------------

  /// `handleInputChange`（foundation.ts:325-362）：先过 `isTimeFormatLike` 形状
  /// 门（utils/index.ts:126-153）——半截输入（如 `12:0`）直接放行不打断，空串
  /// 特跳；合法/空提交落值并回传，非法只置 invalid。
  void _handleInputChange(String input) {
    setState(() => _inputValue = input);
    if (input != '') {
      final parts = input.split(widget.rangeSeparator);
      if (parts.any((part) => !_tpIsTimeFormatLike(part, _formatToken))) {
        return;
      }
    }
    final (dates, failed) = _parseInput(input);
    final invalid = failed || _isDisabledAny(dates);
    final oldValue = _effectiveValue;
    var value = [...oldValue];
    if (!invalid) {
      value = dates;
    }
    if (!_controlledValue) {
      setState(() {
        _value = value;
        _invalid = invalid;
      });
    } else {
      setState(() => _invalid = false);
    }
    if (_hasChanged(value, oldValue)) {
      _notifyChange(value, input);
    }
  }

  /// `parseInput`（foundation.ts:454-464）：按 rangeSeparator 切分逐段解析
  /// （`parseToDate('')` → 空槽）。
  (List<DateTime?>, bool) _parseInput(String input) {
    if (input.isEmpty) return (const [], false);
    final dates = <DateTime?>[];
    var failed = false;
    for (final part in input.split(widget.rangeSeparator)) {
      if (part.isEmpty) {
        dates.add(null);
        continue;
      }
      final parsed = _tpParse(part, _formatToken, DateTime.now());
      if (parsed == null) failed = true;
      dates.add(parsed);
    }
    return (dates, failed);
  }

  /// `handleInputBlur`（foundation.ts:404-427）：★blur 回滚——非空回写
  /// `formatValue(value)` 并清 error；空则清空值。
  void _handleInputBlur() {
    final text = _inputValue ?? _formatValue(_effectiveValue);
    setState(() {
      _focused = false;
      if (text.isNotEmpty) {
        _inputValue = _formatValue(_effectiveValue);
        _invalid = false;
      } else {
        _inputValue = '';
        if (!_controlledValue) _value = const [];
        _invalid = false;
      }
    });
  }

  // -- panel selection ------------------------------------------------------

  /// `handlePanelChange`（foundation.ts:206-240）+ `Combobox.onItemChange`
  /// （Combobox.tsx:135-174）：按列选中/切 AM/PM 后落值（受控只回传）。
  void _handleSelect(int index, _ColumnType type, int value) {
    final base = _panelDate(index);
    var hour = base.hour;
    var minute = base.minute;
    var second = base.second;
    var isAM = _isAMAt(index);
    switch (type) {
      case _ColumnType.hour:
        if (widget.use12Hours) {
          // Combobox.tsx:141-145：`AM: setHours(v%12)`、`PM: setHours(v%12+12)`。
          hour = isAM ? value % 12 : (value % 12) + 12;
        } else {
          hour = value;
        }
      case _ColumnType.minute:
        minute = value;
      case _ColumnType.second:
        second = value;
      case _ColumnType.ampm:
        if (widget.use12Hours) {
          if (value == 1) {
            // PM（Combobox.tsx:151-156）：
            // `transformValue.getHours() < 12 && transformValue.setHours((transformValue.getHours() % 12) + 12);`
            isAM = false;
            if (base.hour < 12) hour = (base.hour % 12) + 12;
          } else {
            // AM（Combobox.tsx:159-162）：
            // `transformValue.getHours() >= 12 && transformValue.setHours(transformValue.getHours() - 12);`
            isAM = true;
            if (base.hour >= 12) hour = base.hour - 12;
          }
        }
    }
    final date = DateTime(
      base.year,
      base.month,
      base.day,
      hour,
      minute,
      second,
    );
    final oldValue = _effectiveValue;
    final value2 = [...oldValue];
    while (value2.length <= index) {
      value2.add(null);
    }
    value2[index] = date;
    final inputValue = _formatValue(value2);
    setState(() {
      _setIsAM(index, isAM);
      if (!_controlledValue) {
        _value = value2;
        _inputValue = inputValue;
        _invalid = _isDisabledAny(value2);
      }
    });
    if (_hasChanged(value2, oldValue)) {
      _notifyChange(value2, inputValue);
    }
  }

  /// 清空（上游 Input clear → `onChange('')` → `handleInputChange('')`）。
  void _handleClear() {
    _handleInputChange('');
  }

  // -- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      container: true,
      enabled: !widget.disabled,
      child: SemiTooltip(
        content: _buildPanel(context, rtl),
        trigger: SemiTooltipTrigger.custom,
        visible: _open,
        onVisibleChange: _handleTooltipVisibleChange,
        showArrow: false,
        popupBare: true,
        zIndex: _TimePickerMetrics.popoverZIndex,
        position: widget.position ?? _defaultPosition(rtl),
        autoAdjustOverflow: widget.autoAdjustOverflow,
        motion: widget.motion,
        repositionKey: _repositionKey,
        child: Focus(
          focusNode: _triggerFocusNode,
          onFocusChange: (focused) {
            if (focused) {
              _handleFocus();
            } else {
              _handleInputBlur();
            }
          },
          child: Listener(
            // Upstream `.semi-timepicker` 触发器 onClick：pointer 事件绕过手势
            // 竞技场（datePicker 触发器先例）。
            onPointerDown: (_) => _handleTriggerTap(),
            behavior: HitTestBehavior.translucent,
            child: MouseRegion(
              // 光标只挂触发器子树（仓库规则 6）；`.semi-input-readonly { cursor: pointer }`
              // （timePicker.scss:126-128）——readonly 也是 pointer。
              cursor: widget.disabled
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              onEnter: (_) => setState(() => _triggerHovering = true),
              onExit: (_) => setState(() => _triggerHovering = false),
              child: KeyedSubtree(
                key: SemiTimePicker.inputKey,
                child: widget.child ?? _buildTrigger(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SemiTooltipPosition _defaultPosition(bool rtl) {
    // foundation.getPosition:65-72 — rtl 时缺省 bottomRight。
    return rtl
        ? SemiTooltipPosition.bottomRight
        : SemiTooltipPosition.bottomLeft;
  }

  // -- trigger --------------------------------------------------------------

  Widget _buildTrigger(BuildContext context) {
    final global = SemiTheme.of(context);
    // 时钟后缀（TimeInput.tsx:201 `suffix={<IconClock onClick={...} />}`）。
    final clock = SemiIcon(SemiIcons.clock, color: global.colors.colorText2);
    final Widget suffix;
    if (widget.borderless) {
      // borderless 时钟图标 hover/focus 前 `opacity: 0`（timePicker.scss:131-138
      // `.#{$prefix}-input-borderless:not(:focus-within):not(:hover){` 的
      // `opacity: 0;`）——用 MouseRegion hover + Focus 状态实现。
      suffix = Opacity(
        opacity: _triggerHovering || _focused ? 1 : 0,
        child: clock,
      );
    } else {
      suffix = clock;
    }
    // inputReadOnly 分支：SemiInput 未移植上游 `showClearIgnoreDisabled`
    // （TimeInput.tsx:197「inputReadOnly only blocks typing, the picker's
    // clear button stays available」）——readonly 时清空按钮自绘在后缀位，
    // 保持「inputReadOnly 时仍可清」。
    final customClear =
        widget.inputReadOnly && widget.showClear && !widget.disabled;
    final text = _display;
    final showCustomClear =
        customClear && text.isNotEmpty && (_triggerHovering || _focused);
    return SemiInput(
      value: text,
      size: widget.size,
      validateStatus: _invalid
          ? SemiInputStatus.error
          : (widget.validateStatus ?? SemiInputStatus.normal),
      disabled: widget.disabled,
      readonly: widget.inputReadOnly,
      borderless: widget.borderless,
      placeholder: _placeholder,
      insetLabel: widget.insetLabel,
      suffix: showCustomClear
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [_clearIcon(), suffix],
            )
          : suffix,
      showClear: widget.showClear && !widget.disabled && !widget.inputReadOnly,
      // TimeInput.tsx:190 `hideSuffix`（清空按钮可见时隐藏时钟后缀）。
      hideSuffix: true,
      clearIcon: _clearIcon(),
      onChanged: widget.inputReadOnly ? null : _handleInputChange,
      focusNode: _inputFocusNode,
    );
  }

  /// `clearIcon={typeof clearText === 'string' ? <span title={clearText}>...`
  /// （TimeInput.tsx:189）——clearText 有值时 tooltip 语义。
  Widget _clearIcon() {
    final icon = widget.clearIcon ?? const SemiIcon(SemiIcons.clear);
    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.inputReadOnly ? _handleClear : null,
      child: icon,
    );
    final clearText = widget.clearText;
    if (clearText != null) {
      result = SemiTooltip(
        content: Text(clearText),
        trigger: SemiTooltipTrigger.hover,
        showArrow: false,
        child: result,
      );
    }
    return KeyedSubtree(key: SemiTimePicker.clearButtonKey, child: result);
  }

  // -- panel ----------------------------------------------------------------

  Widget _buildPanel(BuildContext context, bool rtl) {
    final theme = SemiTimePickerTheme.resolve(context);
    final panels = [
      _buildOnePanel(context, theme, 0),
      if (_isRange) _buildOnePanel(context, theme, 1),
    ];
    final Widget inner;
    if (_isRange) {
      inner = _buildRangeSkin(context, theme, rtl, panels);
    } else {
      inner = _buildPopoverSurface(context, panels.first);
    }
    return KeyedSubtree(key: SemiTimePicker.panelKey, child: inner);
  }

  /// 单面板/弹层白底 = 自绘 Popover 表面（popupBare 无表面）：
  /// `DecoratedBox(colorBg3 + 1px colorBorder + radiusMedium + shadowElevated
  /// 双影)` + ClipRRect（semi_date_picker.dart:1948-1963 /
  /// semi_color_picker.dart build 先例）。
  Widget _buildPopoverSurface(BuildContext context, Widget child) {
    final global = SemiTheme.of(context);
    final radius = global.radius.borderRadiusMedium.value;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: global.colors.colorBg3,
        border: Border.all(width: 1, color: global.colors.colorBorder),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: _TimePickerMetrics.shadowElevated,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }

  /// 范围面板皮肤（timePicker.scss:84-115）：外描边
  /// `$width-timePicker_range_panel-border: 1px` +
  /// `$color-timePicker_range_panel-border: rgba(0, 0, 0, .1)`、圆角
  /// `$radius-timePicker_range_panel`、影 `$shadow-timePicker_range_panel`
  /// （String 字段的 BoxShadow twin）；中缝
  /// `$width-timePicker_range_panel_scrolllist_body-border: 2px` 右边框
  /// `$color-timePicker_range_picker_panel_split-border`（rtl.scss:17-27 翻到
  /// 左边）。
  Widget _buildRangeSkin(
    BuildContext context,
    SemiResolvedTimePickerThemeData t,
    bool rtl,
    List<Widget> panels,
  ) {
    final global = SemiTheme.of(context);
    final radius = t.radiusTimePickerRangePanel;
    final children = <Widget>[];
    for (var i = 0; i < panels.length; i++) {
      final BorderSide? divider = i == 0
          ? BorderSide(
              width: t.widthTimePickerRangePanelScrolllistBodyBorder,
              color: t.colorTimePickerRangePickerPanelSplitBorder,
            )
          : null;
      children.add(
        Container(
          decoration: divider == null
              ? null
              : BoxDecoration(
                  border: rtl ? Border(left: divider) : Border(right: divider),
                ),
          child: panels[i],
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: global.colors.colorBg3,
        border: Border.all(
          width: t.widthTimePickerRangePanelBorder,
          color: t.colorTimePickerRangePanelBorder,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [_TimePickerMetrics.shadowRangePanel],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: rtl ? children.reversed.toList() : children,
        ),
      ),
    );
  }

  Widget _buildOnePanel(
    BuildContext context,
    SemiResolvedTimePickerThemeData t,
    int index,
  ) {
    final header = _panelHeader(index);
    final footer = widget.panelFooter;
    // header/body padding 消费
    // `$spacing-timePicker_range_panel_scrolllist_header_body-padding: 0`
    //（timePicker.scss:110-113；0 值字段照用即消费）。
    final pad = EdgeInsets.all(
      t.spacingTimePickerRangePanelScrolllistHeaderBodyPadding,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) Padding(padding: pad, child: header),
        Padding(padding: pad, child: _buildColumns(t, index)),
        if (footer != null) Padding(padding: pad, child: footer),
      ],
    );
  }

  /// 范围缺省面板头 = 开始时间 / 结束时间（TimePicker.tsx `createPanelProps`
  /// `defaultHeaderMap`）。
  Widget? _panelHeader(int index) {
    if (widget.panelHeader != null) return widget.panelHeader;
    if (!_isRange) return null;
    final strings = SemiLocalizations.of(context);
    return Text(index == 1 ? strings.endTime : strings.beginTime);
  }

  /// 列序固定 ampm,hour,minute,second（Combobox.tsx renderAMPMSelect→hour→
  /// minute→second）；RTL 时列序镜像（rtl.scss:1-30 语义）。
  Widget _buildColumns(SemiResolvedTimePickerThemeData t, int index) {
    final columns = <Widget>[
      if (widget.use12Hours) _buildAmpmColumn(t, index),
      if (_showHour) _buildHourColumn(t, index),
      if (_showMinute) _buildMinuteColumn(t, index),
      if (_showSecond) _buildSecondColumn(t, index),
    ];
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rtl ? columns.reversed.toList() : columns,
    );
  }

  List<({int value, String label, bool selected, bool disabled})> _options(
    List<int> values,
    List<int>? disabledOptions,
    int selectedIndex,
    String suffix,
  ) {
    final items = <({int value, String label, bool selected, bool disabled})>[];
    for (var i = 0; i < values.length; i++) {
      final option = values[i];
      final disabled = disabledOptions?.contains(option) ?? false;
      items.add((
        value: option,
        label: '${_formatOptionLabel(option)}$suffix',
        selected: i == selectedIndex,
        disabled: disabled,
      ));
    }
    return items;
  }

  /// `formatOption`（ComboxFoundation.ts:9-24）补零——上游原文片段
  /// value = `0${option}`;
  /// （`option < 10` 时补零）。
  String _formatOptionLabel(int option) {
    var value = '$option';
    if (option < 10) {
      value = '0$option';
    }
    return value;
  }

  /// 列文本 = 补零值 + zh 后缀（Combobox.tsx:202 `const transformHour =
  /// (value: string) => value + locale.hour;`）。
  int _displaySelectedIndex(
    List<int> values,
    List<int>? disabledOptions,
    int selectedIndex,
  ) {
    if (selectedIndex >= 0) return selectedIndex;
    // ★selectedIndex -1（hideDisabledOptions 移除了选中值/步进不含当前值）→
    // 回退第一个非禁用项（scrollItem.tsx:314-322 `getNodeByIndex`）。
    for (var i = 0; i < values.length; i++) {
      if (!(disabledOptions?.contains(values[i]) ?? false)) return i;
    }
    return values.isEmpty ? -1 : 0;
  }

  Widget _buildHourColumn(SemiResolvedTimePickerThemeData t, int index) {
    final date = _panelDate(index);
    final isAM = _isAMAt(index);
    final fns = _disabledFns(index);
    final disabledOptions = _remapDisabledHours(fns.hours?.call(), isAM);
    final options = _generateOptions(
      24,
      disabledOptions,
      widget.hideDisabledOptions,
      widget.hourStep ?? 1,
    );
    List<int> optionsAdj;
    int selected;
    if (widget.use12Hours) {
      // Combobox.tsx:194-196：`hourOptionsAdj = [12].concat(hourOptions.filter(
      // h => h < 12 && h > 0))`、`hourAdj = hour % 12 || 12`。
      optionsAdj = [12, ...options.where((h) => h < 12 && h > 0)];
      selected = date.hour % 12 == 0 ? 12 : date.hour % 12;
    } else {
      optionsAdj = options;
      selected = date.hour;
    }
    final rawIndex = optionsAdj.indexOf(selected);
    final strings = SemiLocalizations.of(context);
    return _buildColumn(
      key: SemiTimePicker.hourListKey,
      width: t.widthTimePickerPanelListHour,
      height: t.heightTimePickerPanelBody,
      itemHeight: t.heightScrollListItem,
      items: _options(
        optionsAdj,
        disabledOptions,
        _displaySelectedIndex(optionsAdj, disabledOptions, rawIndex),
        strings.hour,
      ),
      selectedIndex: _displaySelectedIndex(
        optionsAdj,
        disabledOptions,
        rawIndex,
      ),
      infinite: widget.infinite,
      onSelect: (v) => _handleSelect(index, _ColumnType.hour, v),
    );
  }

  Widget _buildMinuteColumn(SemiResolvedTimePickerThemeData t, int index) {
    final date = _panelDate(index);
    final fns = _disabledFns(index);
    final disabledOptions = fns.minutes?.call(date.hour);
    final options = _generateOptions(
      60,
      disabledOptions,
      widget.hideDisabledOptions,
      widget.minuteStep ?? 1,
    );
    final rawIndex = options.indexOf(date.minute);
    final strings = SemiLocalizations.of(context);
    return _buildColumn(
      key: SemiTimePicker.minuteListKey,
      width: t.widthTimePickerPanelListMinute,
      height: t.heightTimePickerPanelBody,
      itemHeight: t.heightScrollListItem,
      items: _options(
        options,
        disabledOptions,
        _displaySelectedIndex(options, disabledOptions, rawIndex),
        strings.minute,
      ),
      selectedIndex: _displaySelectedIndex(options, disabledOptions, rawIndex),
      infinite: widget.infinite,
      onSelect: (v) => _handleSelect(index, _ColumnType.minute, v),
    );
  }

  Widget _buildSecondColumn(SemiResolvedTimePickerThemeData t, int index) {
    final date = _panelDate(index);
    final fns = _disabledFns(index);
    final disabledOptions = fns.seconds?.call(date.hour, date.minute);
    final options = _generateOptions(
      60,
      disabledOptions,
      widget.hideDisabledOptions,
      widget.secondStep ?? 1,
    );
    final rawIndex = options.indexOf(date.second);
    final strings = SemiLocalizations.of(context);
    return _buildColumn(
      key: SemiTimePicker.secondListKey,
      width: t.widthTimePickerPanelListSecond,
      height: t.heightTimePickerPanelBody,
      itemHeight: t.heightScrollListItem,
      items: _options(
        options,
        disabledOptions,
        _displaySelectedIndex(options, disabledOptions, rawIndex),
        strings.second,
      ),
      selectedIndex: _displaySelectedIndex(options, disabledOptions, rawIndex),
      infinite: widget.infinite,
      onSelect: (v) => _handleSelect(index, _ColumnType.second, v),
    );
  }

  /// AM/PM 列（Combobox.tsx:281-314）：`[{value: 'AM', text: 上午}, {value:
  /// 'PM', text: 下午}]`，无补零无后缀。
  Widget _buildAmpmColumn(SemiResolvedTimePickerThemeData t, int index) {
    final isAM = _isAMAt(index);
    final strings = SemiLocalizations.of(context);
    final texts = [strings.am, strings.pm];
    final items = <({int value, String label, bool selected, bool disabled})>[
      for (var i = 0; i < 2; i++)
        (
          value: i,
          label: texts[i],
          selected: i == (isAM ? 0 : 1),
          disabled: false,
        ),
    ];
    return _buildColumn(
      key: SemiTimePicker.ampmListKey,
      width: t.widthTimePickerPanelListAmpm,
      height: t.heightTimePickerPanelBody,
      itemHeight: t.heightScrollListItem,
      items: items,
      selectedIndex: isAM ? 0 : 1,
      onSelect: (v) => _handleSelect(index, _ColumnType.ampm, v),
    );
  }

  /// `generateOptions(24|60|60, disabled, hideDisabled, step)`
  /// （ComboxFoundation.ts:26-34）：`for (value = 0; value < length;
  /// value += step)`，hide 时移除禁用值。
  List<int> _generateOptions(
    int length,
    List<int>? disabledOptions,
    bool hideDisabledOptions,
    int step,
  ) {
    final arr = <int>[];
    for (var value = 0; value < length; value += step) {
      if (disabledOptions == null ||
          !disabledOptions.contains(value) ||
          !hideDisabledOptions) {
        arr.add(value);
      }
    }
    return arr;
  }

  Widget _buildColumn({
    required Key key,
    required double width,
    required double height,
    required double itemHeight,
    required List<({int value, String label, bool selected, bool disabled})>
    items,
    required int selectedIndex,
    bool infinite = false,
    required ValueChanged<int> onSelect,
  }) {
    return _TimePickerColumn(
      key: key,
      width: width,
      height: height,
      itemHeight: itemHeight,
      items: items,
      selectedIndex: selectedIndex,
      infinite: infinite,
      onSelect: onSelect,
    );
  }
}

/// 普通滚动列表列（上游 V2.22.0 默认 `mode={'normal'}`（Combobox.tsx）——
/// **非滚轮**；`_YamColumn` 样板 semi_date_picker.dart:2709-2823）。
class _TimePickerColumn extends StatefulWidget {
  const _TimePickerColumn({
    super.key,
    required this.width,
    required this.height,
    required this.itemHeight,
    required this.items,
    required this.selectedIndex,
    this.infinite = false,
    required this.onSelect,
  });

  final double width;
  final double height;
  final double itemHeight;
  final List<({int value, String label, bool selected, bool disabled})> items;
  final int selectedIndex;
  final bool infinite;
  final ValueChanged<int> onSelect;

  @override
  State<_TimePickerColumn> createState() => _TimePickerColumnState();
}

class _TimePickerColumnState extends State<_TimePickerColumn> {
  static const int _loopBlocks = 1001;
  static const Duration _settleDelay = Duration(milliseconds: 33);
  static const Duration _scrollDuration = Duration(milliseconds: 120);

  final ScrollController _controller = ScrollController();
  Timer? _settleTimer;
  int? _settledVirtual;
  int? _lastNotifiedIndex;
  bool _rebasing = false;

  bool get _cycled => widget.infinite && widget.items.isNotEmpty;
  int get _dataCount => widget.items.length;
  int get _virtualCount => _cycled ? _dataCount * _loopBlocks : _dataCount;
  int get _middleStart => _cycled ? _dataCount * (_loopBlocks ~/ 2) : 0;

  int _dataOf(int virtual) {
    if (_dataCount == 0) return 0;
    final remainder = virtual % _dataCount;
    return remainder < 0 ? remainder + _dataCount : remainder;
  }

  @override
  void initState() {
    super.initState();
    _scheduleCenter(initial: true);
  }

  @override
  void didUpdateWidget(_TimePickerColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.infinite != widget.infinite ||
        !_sameItems(oldWidget.items, widget.items)) {
      _scheduleCenter(initial: false);
    }
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _sameItems(
    List<({int value, String label, bool selected, bool disabled})> a,
    List<({int value, String label, bool selected, bool disabled})> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value ||
          a[i].label != b[i].label ||
          a[i].disabled != b[i].disabled) {
        return false;
      }
    }
    return true;
  }

  int _initialIndex() {
    if (_dataCount == 0) return 0;
    if (widget.selectedIndex >= 0 && widget.selectedIndex < _dataCount) {
      return widget.selectedIndex;
    }
    for (var i = 0; i < _dataCount; i++) {
      if (!widget.items[i].disabled) return i;
    }
    return 0;
  }

  /// 打开面板时把选中项放到中间块，并保持原有的首尾留白定位。
  void _scheduleCenter({required bool initial}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final index = _initialIndex();
      final virtual = _cycled ? _middleStart + index : index;
      _settledVirtual = virtual;
      _lastNotifiedIndex = index;
      final target = _targetOffset(virtual);
      _controller.jumpTo(target);
    });
  }

  double _rowOffset(int virtual) {
    final inset = (widget.height - widget.itemHeight) * 0.5;
    return inset + virtual * widget.itemHeight;
  }

  double _targetOffset(int virtual) {
    final viewport = _controller.position.viewportDimension;
    final target = _rowOffset(virtual) - (viewport - widget.itemHeight) * 0.5;
    return target.clamp(0.0, _controller.position.maxScrollExtent);
  }

  void _scheduleSettle() {
    _settleTimer?.cancel();
    _settleTimer = Timer(_settleDelay, _settle);
  }

  void _onScroll(ScrollNotification notification) {
    if (!_cycled || _rebasing) return;
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      _scheduleSettle();
      _rebaseIfNeeded();
    }
  }

  int _nearestEnabled() {
    if (!_controller.hasClients || _dataCount == 0) return -1;
    final inset = (widget.height - widget.itemHeight) * 0.5;
    final center =
        _controller.offset + _controller.position.viewportDimension * 0.5;
    final anchor =
        ((center - inset - widget.itemHeight * 0.5) / widget.itemHeight)
            .round();
    var best = -1;
    var bestDistance = double.infinity;
    final start = _cycled ? anchor - _dataCount : 0;
    final end = _cycled ? anchor + _dataCount : _dataCount - 1;
    for (var virtual = start; virtual <= end; virtual++) {
      if (virtual < 0 || virtual >= _virtualCount) continue;
      final item = widget.items[_dataOf(virtual)];
      if (item.disabled) continue;
      final distance = (_rowOffset(virtual) + widget.itemHeight * 0.5 - center)
          .abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = virtual;
      }
    }
    return best;
  }

  void _settle() {
    if (!mounted || !_controller.hasClients || _dataCount == 0 || _rebasing) {
      return;
    }
    final virtual = _nearestEnabled();
    if (virtual < 0) return;
    _settledVirtual = virtual;
    final target = _targetOffset(virtual);
    if ((_controller.offset - target).abs() > 0.5) {
      _controller.animateTo(
        target,
        duration: _scrollDuration,
        curve: Curves.easeOut,
      );
    }
    final dataIndex = _dataOf(virtual);
    if (_lastNotifiedIndex != dataIndex) {
      _lastNotifiedIndex = dataIndex;
      widget.onSelect(widget.items[dataIndex].value);
    }
  }

  void _rebaseIfNeeded() {
    if (!_cycled || !_controller.hasClients || _dataCount == 0 || _rebasing) {
      return;
    }
    final blockHeight = _dataCount * widget.itemHeight;
    final offset = _controller.offset;
    final max = _controller.position.maxScrollExtent;
    final threshold = blockHeight * 2;
    if (offset <= threshold || offset >= max - threshold) {
      final middleOffset = _middleStart * widget.itemHeight;
      final delta = middleOffset - (offset - (offset % blockHeight));
      final next = (offset + delta).clamp(0.0, max);
      _rebasing = true;
      _controller.jumpTo(next);
      if (_settledVirtual != null) {
        final currentData = _dataOf(_settledVirtual!);
        _settledVirtual = _middleStart + currentData;
      }
      _rebasing = false;
    }
  }

  Widget _buildItem(BuildContext context, int virtual, int dataIndex) {
    final item = widget.items[dataIndex];
    final selected = widget.infinite
        ? virtual == _settledVirtual
        : item.selected;
    return GestureDetector(
      onTap: item.disabled
          ? null
          : () {
              if (widget.infinite) {
                _settledVirtual = virtual;
                _lastNotifiedIndex = dataIndex;
                final target = _targetOffset(virtual);
                _controller.animateTo(
                  target,
                  duration: _scrollDuration,
                  curve: Curves.easeOut,
                );
              }
              widget.onSelect(item.value);
            },
      child: MouseRegion(
        cursor: item.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: Container(
          height: widget.itemHeight,
          width: widget.width,
          alignment: Alignment.center,
          color: selected ? _timePickerSelectedColor(context) : null,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: _TimePickerMetrics.fontSizeRegular,
              color: item.disabled
                  ? _timePickerDisabledColor(context)
                  : _timePickerTextColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinite(BuildContext context, double inset) {
    return SingleChildScrollView(
      controller: _controller,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: inset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              _buildItem(context, i, i),
          ],
        ),
      ),
    );
  }

  Widget _buildInfinite(BuildContext context, double inset) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(notification);
        return false;
      },
      child: ListView.builder(
        controller: _controller,
        padding: EdgeInsets.symmetric(vertical: inset),
        itemExtent: widget.itemHeight,
        itemCount: _virtualCount,
        itemBuilder: (context, virtual) =>
            _buildItem(context, virtual, _dataOf(virtual)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = (widget.height - widget.itemHeight) * 0.5;
    final child = _cycled
        ? _buildInfinite(context, inset)
        : _buildFinite(context, inset);
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }

  Color _timePickerTextColor(BuildContext context) =>
      SemiTheme.of(context).colors.colorText0;

  Color _timePickerSelectedColor(BuildContext context) =>
      SemiTheme.of(context).colors.colorPrimaryLightDefault;

  Color _timePickerDisabledColor(BuildContext context) =>
      SemiTheme.of(context).colors.colorDisabledText;
}

enum _ColumnType { ampm, hour, minute, second }

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_time_picker.py for the
/// 20 = 14 FIELDS + 6 MOTION + 0 INTERNAL accounting; the constants below are
/// the 另列 HARDCODES entries (their snippets are checked to appear in this
/// file).
abstract final class _TimePickerMetrics {
  /// Locale values are resolved through SemiLocalizations at build time.
  /// Upstream locale anchors remain in this note-only block:
  /// time: '请选择时间',
  /// timeRange: '请选择时间范围',
  /// begin: '开始时间',
  /// end: '结束时间',
  /// hour: '时',
  /// minute: '分',
  /// second: '秒',
  /// AM: '上午',
  /// PM: '下午',

  // ($height-timePicker_panel_body - $height-scrollList_item) * 0.5
  // .semi-input-readonly { cursor: pointer }
  // .#{$prefix}-input-borderless:not(:focus-within):not(:hover){
  // opacity: 0;
  // transformValue.getHours() < 12 && transformValue.setHours((transformValue.getHours() % 12) + 12);
  // transformValue.getHours() >= 12 && transformValue.setHours(transformValue.getHours() - 12);
  // -ms-overflow-style: none; /* Internet Explorer 10+ */
  // scrollbar-width: none; /* Firefox */
  // &::-webkit-scrollbar {
  // DEFAULT_SCROLL_DURATION: 120
  // DEFAULT_FORMAT: 'HH:mm:ss'
  // DEFAULT_FORMAT_A: 'a h:mm:ss'
  // DEFAULT_RANGE_SEPARATOR: ' ~ '
  // value = `0${option}`;
  // format.match(/HH|hh|H|h/g)
  // format.match(/mm/g)
  // format.match(/ss/g)
  // hour % 12 || 12
  // value + locale.hour
  // mode={'normal'}
  // Runtime locale text is supplied by SemiLocalizations. The upstream
  // locale values are retained as note-only provenance anchors:
  // time: '请选择时间', timeRange: '请选择时间范围', begin: '开始时间',
  // end: '结束时间', hour: '时', minute: '分', second: '秒',
  // AM: '上午', PM: '下午'.

  /// `DEFAULT_FORMAT: 'HH:mm:ss'` / `DEFAULT_FORMAT_A: 'a h:mm:ss'` /
  /// `DEFAULT_RANGE_SEPARATOR: ' ~ '`（timePicker/constants.ts:25/26/6）。
  static const String defaultFormat = 'HH:mm:ss';
  static const String defaultFormatA = 'a h:mm:ss';
  static const String defaultRangeSeparator = ' ~ ';

  /// `@include font-size-regular` → `$font-size-regular: 14px`
  /// （packages/semi-theme-default/scss/mixin.scss）。
  static const double fontSizeRegular = 14;

  /// 弹层 zIndex（上游 Popover `zIndex: 1030`）。
  static const int popoverZIndex = 1030;

  /// `$shadow-timePicker_range_panel: 0 4px 14px rgba(0, 0, 0, .1)`（String
  /// 主题字段 [SemiTimePickerThemeData.shadowTimePickerRangePanel] 的同值
  /// BoxShadow twin——注释互指；原文见该字段 provenance）。
  static const BoxShadow shadowRangePanel = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 4),
    blurRadius: 14,
  );

  /// `0 0 1px rgba(0, 0, 0, .3)` / `0 4px 14px rgba(0, 0, 0, .1)` — the two
  /// box-shadow layers of the `@include shadow-elevated` mixin
  /// (packages/semi-theme-default/scss/global.scss) painting the Popover
  /// surface that hosts the panel (popover.scss); hardcoded to the light
  /// token values (same pair as _ColorPickerMetrics.shadowElevatedBlur/Drop,
  /// semi_color_picker.dart).
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
// private time utilities (the date-fns subset the port needs —
// ★与 semi_date_picker.dart 的 `_dp*` 子集同源重复，见 docs/semi_time_picker.md)
// ---------------------------------------------------------------------------

/// `format(date, token)` for the `HH`/`H`/`hh`/`h`/`mm`/`ss`/`a`/`A` subset.
/// ★`A` 当 `a`（Combobox.tsx:171 `format.replace(/(\s+)A/g, '$1a')` 的语义——
/// date-fns 只支持小写 `a`）；`a`/`A` 输出 zh 上午/下午。
String _tpFormat(DateTime d, String fmt, {String am = 'AM', String pm = 'PM'}) {
  final buffer = StringBuffer();
  var i = 0;
  while (i < fmt.length) {
    final String rep;
    final int len;
    if (fmt.startsWith('HH', i)) {
      rep = d.hour.toString().padLeft(2, '0');
      len = 2;
    } else if (fmt.startsWith('hh', i)) {
      rep = _twelveHour(d.hour).toString().padLeft(2, '0');
      len = 2;
    } else if (fmt.startsWith('mm', i)) {
      rep = d.minute.toString().padLeft(2, '0');
      len = 2;
    } else if (fmt.startsWith('ss', i)) {
      rep = d.second.toString().padLeft(2, '0');
      len = 2;
    } else if (fmt.startsWith('H', i)) {
      rep = '${d.hour}';
      len = 1;
    } else if (fmt.startsWith('h', i)) {
      rep = '${_twelveHour(d.hour)}';
      len = 1;
    } else if (fmt.startsWith('m', i)) {
      rep = '${d.minute}';
      len = 1;
    } else if (fmt.startsWith('s', i)) {
      rep = '${d.second}';
      len = 1;
    } else if (fmt.startsWith('a', i) || fmt.startsWith('A', i)) {
      rep = d.hour < 12 ? am : pm;
      len = 1;
    } else {
      buffer.write(fmt[i]);
      i += 1;
      continue;
    }
    buffer.write(rep);
    i += len;
  }
  return buffer.toString();
}

/// `h`/`hh` 的 12 小时值：`hour % 12 || 12`（0 → 12）。
int _twelveHour(int hour) {
  final v = hour % 12;
  return v == 0 ? 12 : v;
}

/// Strict `parse(text, format, baseDate)` for the same subset: the whole text
/// must match the format; fields absent from the format fall back to the base
/// date（date-fns `parse`）。`a`/`A` 接受 zh/AM/PM 标记；`h`/`hh` 无 meridiem
/// 时按 12 小时折半（12 → 0）。越界组件返回 null（date-fns Invalid Date）。
DateTime? _tpParse(String text, String fmt, DateTime base) {
  final pattern = StringBuffer();
  final tokens = <String>[];
  var i = 0;
  while (i < fmt.length) {
    if (fmt.startsWith('HH', i)) {
      pattern.write(r'(\d{2})');
      tokens.add('HH');
      i += 2;
    } else if (fmt.startsWith('hh', i)) {
      pattern.write(r'(\d{2})');
      tokens.add('hh');
      i += 2;
    } else if (fmt.startsWith('mm', i)) {
      pattern.write(r'(\d{2})');
      tokens.add('mm');
      i += 2;
    } else if (fmt.startsWith('ss', i)) {
      pattern.write(r'(\d{2})');
      tokens.add('ss');
      i += 2;
    } else if (fmt.startsWith('H', i)) {
      pattern.write(r'(\d{1,2})');
      tokens.add('H');
      i += 1;
    } else if (fmt.startsWith('h', i)) {
      pattern.write(r'(\d{1,2})');
      tokens.add('h');
      i += 1;
    } else if (fmt.startsWith('m', i)) {
      pattern.write(r'(\d{1,2})');
      tokens.add('m');
      i += 1;
    } else if (fmt.startsWith('s', i)) {
      pattern.write(r'(\d{1,2})');
      tokens.add('s');
      i += 1;
    } else if (fmt.startsWith('a', i) || fmt.startsWith('A', i)) {
      pattern.write(r'(上午|下午|AM|PM|am|pm)');
      tokens.add('a');
      i += 1;
    } else {
      pattern.write(RegExp.escape(fmt[i]));
      i += 1;
    }
  }
  final match = RegExp('^$pattern\$').firstMatch(text);
  if (match == null) return null;
  var hour = 0;
  var minute = 0;
  var second = 0;
  var pm = false;
  var hasMeridiem = false;
  for (var t = 0; t < tokens.length; t++) {
    final raw = match.group(t + 1)!;
    switch (tokens[t]) {
      case 'HH':
        hour = int.parse(raw);
      case 'H':
        hour = int.parse(raw);
      case 'hh':
        hour = int.parse(raw) % 12;
      case 'h':
        hour = int.parse(raw) % 12;
      case 'mm':
        minute = int.parse(raw);
      case 'm':
        minute = int.parse(raw);
      case 'ss':
        second = int.parse(raw);
      case 's':
        second = int.parse(raw);
      case 'a':
        hasMeridiem = true;
        pm = raw == '下午' || raw == 'PM' || raw == 'pm';
    }
  }
  if (hasMeridiem && pm) hour += 12;
  if (hour > 23 || minute > 59 || second > 59) return null;
  return DateTime(base.year, base.month, base.day, hour, minute, second);
}

/// `parseToDate`（utils/index.ts:14-35）：DateTime 原样、num→毫秒时间戳
/// （★`0` 合法）、String 按 format 解析（基准今天）、null/''→空。
DateTime? _tpParseValue(Object? input, String formatToken) {
  if (input is DateTime) return input;
  if (input == null) return null;
  if (input is num) {
    return DateTime.fromMillisecondsSinceEpoch(input.round());
  }
  if (input is String) {
    if (input == '') return null;
    return _tpParse(input, formatToken, DateTime.now());
  }
  return null;
}

/// `isTimeFormatLike`（utils/index.ts:126-153）：长度/分段形状门——半截输入
/// （如 `12:0`）判「不像」，交由调用方放行不打断输入过程。
bool _tpIsTimeFormatLike(String time, String formatToken) {
  var isLike = true;
  const dateFnsSupportFormatCh = 'BDEGHKLMOPQRSTXYabcehimopqstuwxyz';
  final formatSupportChReg = RegExp('[$dateFnsSupportFormatCh]');
  final formatNotSupportChReg = RegExp('[^$dateFnsSupportFormatCh]');
  final hmsReg = RegExp(r'[H|m|s]{1,2}');
  final formatSplitted = _jsSplit(formatToken, formatNotSupportChReg);
  final timeSeparator = formatToken.replaceAll(formatSupportChReg, '');
  final escapedTimeSeparator = timeSeparator.replaceAllMapped(
    RegExp(r'[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]'),
    (m) => '\\${m[0]}',
  );
  final timeSplitted = timeSeparator.isEmpty
      ? <String>[time]
      : _jsSplit(time, RegExp('[$escapedTimeSeparator]'));
  if (formatSplitted.length != timeSplitted.length) {
    isLike = false;
  } else {
    for (var i = 0; i < timeSplitted.length; i++) {
      final formatStr = formatSplitted[i];
      final timeStr = timeSplitted[i];
      // 当前段对应分/秒且长度短于格式（`HH:mm` | `12:0` → false）。
      if (hmsReg.hasMatch(formatStr) && timeStr.length < formatStr.length) {
        isLike = false;
        break;
      }
    }
  }
  return isLike;
}

/// JS `String.prototype.split(regexp)` 语义：在每个正则匹配处切开并保留空段。
List<String> _jsSplit(String text, RegExp reg) {
  final out = <String>[];
  var start = 0;
  for (final match in reg.allMatches(text)) {
    out.add(text.substring(start, match.start));
    start = match.end;
  }
  out.add(text.substring(start));
  return out;
}
