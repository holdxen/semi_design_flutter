import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class DatePickerPage extends StatefulWidget {
  const DatePickerPage({super.key});

  @override
  State<DatePickerPage> createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> {
  String _status = '点击触发器打开面板，选择日期查看事件。';

  // 受控（value + onChanged 里 setState 落地）。
  Object? _controlled = DateTime(2024, 1, 15);

  // 严格受控（slider-controlled-button 惯例）：字段只回调不落地，按钮改值。
  DateTime _buttonDate = DateTime(2024, 2, 15);

  // 事件回调顺序记录（onChanged / onOpenChange / onPanelChange /
  // onPresetClick / onClear，slider 的 events demo 模式）。
  final List<String> _events = [];

  // 手动开关面板（官方 Methods 的 ref.open()/close()/focus()/blur()）。
  final SemiDatePickerController _controller = SemiDatePickerController();

  void _push(String event) {
    _events.add(event);
    if (_events.length > 8) _events.removeRange(0, _events.length - 8);
  }

  void _changed(Object? date, String? dateStr) => setState(() {
    _push('onChanged ${date == null ? 'null' : dateStr ?? ''}');
    _status = date == null ? 'onChanged：（空）' : 'onChanged：$dateStr';
  });

  /// 严格受控回调：只报通知，显示只跟随按钮改的值。
  void _strictChanged(Object? date, String? dateStr) => setState(() {
    _push('onChanged ${date == null ? 'null' : dateStr ?? ''}');
    _status = '严格：$dateStr';
  });

  void _openChanged(bool open) => setState(() => _push('onOpenChange $open'));

  void _panelMoved(DateTime visibleDate, String text) =>
      setState(() => _push('onPanelChange $text'));

  void _presetClicked(SemiDatePickerPreset preset) =>
      setState(() => _push('onPresetClick ${preset.text ?? ''}'));

  void _cleared() => setState(() => _push('onClear'));

  /// 官方「带有快捷方式的日期时间选择」的 Today/Tomorrow（★函数值惰性求值，
  /// 点击时才调用）；「清空」预设（★start/end 皆空）清值并关门。
  List<SemiDatePickerPreset> _quickPresets() => [
    SemiDatePickerPreset(
      text: '今天',
      start: () => DateTime.now(),
      end: () => DateTime.now(),
    ),
    SemiDatePickerPreset(
      text: '明天',
      start: () => DateTime.now().add(const Duration(days: 1)),
      end: () => DateTime.now().add(const Duration(days: 1)),
    ),
    const SemiDatePickerPreset(text: '清空'),
  ];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 触发器定宽（确定性量宽）；窄屏横向滚动，不溢出（switch/slider 的
  /// `_wideDemo` 模式）——日历面板是 overlay，不占行内宽度。
  Widget _demo(String label, Widget child, {double width = 320}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: width, child: child),
      ),
      const SizedBox(height: 12),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            SemiText(_status, key: const ValueKey('datepicker-status')),
            const SizedBox(height: 12),
            _demo(
              'type=date — 点击选择日期；非法输入回退（★round-trip）',
              SemiDatePicker(
                key: const ValueKey('datepicker-basic'),
                onChanged: _changed,
                onOpenChange: _openChanged,
                onClear: _cleared,
              ),
            ),
            const SemiText(
              '未支持（官方 demo 延期）：小尺寸 density、多个日期选择 multiple、'
              '日期与时间 dateTime/dateTimeRange、内嵌输入框 insetInput、'
              '确认选择 needConfirm、附加区域 topSlot/bottomSlot、'
              '自定义触发器 triggerRender、自定义日期渲染 renderDate/renderFullDate、'
              '周选择 startDateOffset/endDateOffset、默认面板月 defaultPickerValue、'
              'disabledTime。',
              key: ValueKey('datepicker-unsupported-note'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控', [
            _demo(
              'value + onChanged setState 落地',
              SemiDatePicker(
                key: const ValueKey('datepicker-controlled'),
                value: _controlled,
                onChanged: (date, dateStr) {
                  setState(() => _controlled = date);
                  _changed(date, dateStr);
                },
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              '点击按钮改值（严格受控，选择器只回调不落地）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击切换日期',
                    key: const ValueKey('datepicker-controlled-bump'),
                    onPressed: () => setState(
                      () => _buttonDate = _buttonDate.month == 2
                          ? DateTime(2024, 3, 15)
                          : DateTime(2024, 2, 15),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SemiDatePicker(
                    key: const ValueKey('datepicker-controlled-button'),
                    value: _buttonDate,
                    onChanged: _strictChanged,
                    onOpenChange: _openChanged,
                  ),
                ],
              ),
              width: 400,
            ),
          ]),
          const SizedBox(height: 40),
          _section('日期范围', [
            _demo(
              'type=dateRange — 首点后面板常开（★），终点早于起点则起点换序重置',
              SemiDatePicker(
                key: const ValueKey('datepicker-range'),
                type: SemiDatePickerType.dateRange,
                placeholder: const ['开始日期', '结束日期'],
                onChanged: _changed,
                onOpenChange: _openChanged,
                onClear: _cleared,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('同步切换双面板月份', [
            _demo(
              'syncSwitchMonth — 双面板同移，内侧箭头隐藏占位',
              SemiDatePicker(
                key: const ValueKey('datepicker-sync'),
                type: SemiDatePickerType.dateRange,
                syncSwitchMonth: true,
                onChanged: _changed,
                onOpenChange: _openChanged,
                onPanelChange: _panelMoved,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('事件回调', [
            _demo(
              'onChanged / onOpenChange / onPanelChange / onPresetClick / onClear',
              SemiDatePicker(
                key: const ValueKey('datepicker-events'),
                defaultValue: DateTime.now(),
                presets: _quickPresets(),
                onChanged: _changed,
                onOpenChange: _openChanged,
                onPanelChange: _panelMoved,
                onPresetClick: _presetClicked,
                onClear: _cleared,
              ),
            ),
            SemiText(
              _events.isEmpty ? '（尚无事件）' : _events.join(' → '),
              key: const ValueKey('datepicker-events-log'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('切换月份/年份（autoSwitchDate）', [
            _demo(
              '导航后选中值跟随进新月（★月末钳制 01-31 → 02-29）且不关面板；'
              '默认面板月由 defaultValue 提供（defaultPickerValue 未支持）',
              SemiDatePicker(
                key: const ValueKey('datepicker-auto-switch'),
                defaultValue: DateTime(2024, 1, 31),
                onChanged: _changed,
                onOpenChange: _openChanged,
                onPanelChange: _panelMoved,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('周起始 weekStartsOn', [
            _demo(
              'weekStartsOn=1 — 周一为每周第一天（官方周选择 offsets 未支持）',
              SemiDatePicker(
                key: const ValueKey('datepicker-week-start'),
                weekStartsOn: 1,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('年月选择', [
            _demo(
              'type=month — 年/月列表选择（★选中不自动关面板）',
              SemiDatePicker(
                key: const ValueKey('datepicker-month'),
                type: SemiDatePickerType.month,
                placeholder: '请选择年月',
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
              width: 140,
            ),
          ]),
          const SizedBox(height: 40),
          _section('年月范围选择', [
            _demo(
              'type=monthRange — 双列年月范围（★不渲染预设）',
              SemiDatePicker(
                key: const ValueKey('datepicker-month-range'),
                type: SemiDatePickerType.monthRange,
                placeholder: const ['开始年月', '结束年月'],
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
              width: 200,
            ),
          ]),
          const SizedBox(height: 40),
          _section('快捷选择', [
            _demo(
              'presets + presetPosition=left — ★函数值惰性求值；「清空」预设清值关门',
              SemiDatePicker(
                key: const ValueKey('datepicker-presets'),
                presets: _quickPresets(),
                presetPosition: SemiDatePickerPresetPosition.left,
                onChanged: _changed,
                onOpenChange: _openChanged,
                onPresetClick: _presetClicked,
                onClear: _cleared,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用与不可选日期', [
            _demo(
              'disabled — 整体禁用',
              SemiDatePicker(
                key: const ValueKey('datepicker-disabled-prop'),
                disabled: true,
                defaultValue: DateTime.now(),
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              'disabledDate — 禁用每月 15 日（点击无效）',
              SemiDatePicker(
                key: const ValueKey('datepicker-disabled'),
                disabledDate: (date, info) => date.day == 15,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              '动态禁用 — 起点选定后禁用更早的日期（options.rangeStart）',
              SemiDatePicker(
                key: const ValueKey('datepicker-disabled-range'),
                type: SemiDatePickerType.dateRange,
                placeholder: const ['开始日期', '结束日期'],
                disabledDate: (date, info) {
                  final start = info.rangeStart;
                  return start != null &&
                      date.isBefore(
                        DateTime(start.year, start.month, start.day),
                      );
                },
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              '按聚焦侧禁用（options.rangeInputFocus）',
              SemiDatePicker(
                key: const ValueKey('datepicker-disabled-focus'),
                type: SemiDatePickerType.dateRange,
                motion: false,
                placeholder: const ['开始日期', '结束日期'],
                disabledDate: (date, info) {
                  final base = DateTime.now();
                  final today = DateTime(base.year, base.month, base.day);
                  final window =
                      info.rangeInputFocus ==
                          SemiDatePickerRangeFocus.rangeStart
                      ? 2
                      : 3;
                  return !date.isBefore(
                        today.subtract(Duration(days: window)),
                      ) &&
                      !date.isAfter(today.add(Duration(days: window)));
                },
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义显示格式', [
            _demo(
              "format='yyyy年MM月dd日'",
              SemiDatePicker(
                key: const ValueKey('datepicker-format'),
                format: 'yyyy年MM月dd日',
                defaultValue: DateTime(2024, 1, 15),
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              "rangeSeparator='至'",
              SemiDatePicker(
                key: const ValueKey('datepicker-separator'),
                type: SemiDatePickerType.dateRange,
                rangeSeparator: '至',
                placeholder: const ['开始日期', '结束日期'],
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸与状态', [
            _demo(
              "size='small'",
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-small'),
                size: SemiInputSize.small,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              'size=default（normal）',
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-normal'),
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              "size='large'",
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-large'),
                size: SemiInputSize.large,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              'validateStatus=warning',
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-warning'),
                validateStatus: SemiInputStatus.warning,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              'validateStatus=error',
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-error'),
                validateStatus: SemiInputStatus.error,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              'borderless — 无边框触发器',
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-borderless'),
                borderless: true,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              'inputReadOnly — 输入只读，仅面板点选',
              SemiDatePicker(
                key: const ValueKey('datepicker-sizes-readonly'),
                inputReadOnly: true,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('控制器', [
            _demo(
              'SemiDatePickerController.open()/close()/focus()/blur()',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap（非 Row）：textScale 1.2 下四个按钮超出 400 定宽时
                  // 换行不溢出（窄屏安全）。
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SemiButton(
                        'open',
                        key: const ValueKey('datepicker-controller-open'),
                        onPressed: _controller.open,
                      ),
                      SemiButton(
                        'close',
                        key: const ValueKey('datepicker-controller-close'),
                        onPressed: _controller.close,
                      ),
                      SemiButton(
                        'focus',
                        key: const ValueKey('datepicker-controller-focus'),
                        onPressed: _controller.focus,
                      ),
                      SemiButton(
                        'blur',
                        key: const ValueKey('datepicker-controller-blur'),
                        onPressed: _controller.blur,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SemiDatePicker(
                    key: const ValueKey('datepicker-controller'),
                    controller: _controller,
                    onChanged: _changed,
                    onOpenChange: _openChanged,
                  ),
                ],
              ),
              width: 400,
            ),
          ]),
        ],
      ),
    );
  }
}
