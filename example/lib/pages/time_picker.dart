import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TimePickerPage extends StatefulWidget {
  const TimePickerPage({super.key});

  @override
  State<TimePickerPage> createState() => _TimePickerPageState();
}

class _TimePickerPageState extends State<TimePickerPage> {
  // 种子值取稳定引用（static final）：SemiTimePicker.didUpdateWidget 以
  // `oldWidget.defaultValue != widget.defaultValue` 判定重建内部状态，而 List
  // 是恒等比较——内联字面量每次 build 新实例会让非受控选择被重置（见汇报
  // 「组件发现」）。DateTime 有值相等不受影响，此处一并统一。
  static final DateTime _seed800 = DateTime(2024, 1, 1, 8, 0);
  static final DateTime _seed830 = DateTime(2024, 1, 1, 8, 30);
  static final DateTime _seed930 = DateTime(2024, 1, 1, 9, 30);
  static final DateTime _seed1100 = DateTime(2024, 1, 1, 11, 0);
  static final DateTime _seed1800 = DateTime(2024, 1, 1, 18, 0);
  static final DateTime _seed2000 = DateTime(2024, 1, 1, 20, 0);
  static final List<Object?> _seedRange = [_seed930, _seed1800];
  static final List<Object?> _seedRange2 = [_seed930, _seed1100];

  String _status = '点击触发器打开面板，选择时间查看事件。';

  // 事件回传顺序记录（onChanged / onOpenChange，slider 的 events demo 模式）。
  final List<String> _events = [];

  // 严格受控值（slider-controlled-button 惯例）：字段只回调不落地，按钮改值。
  DateTime _controlledValue = _seed800;

  // 受控 open（open 非空即受控）：按钮切换；onOpenChange 只报不落地。
  bool _controlledOpen = false;

  // 手动开关面板（官方 ref.open()/close()/focus()/blur()）。
  final SemiTimePickerController _controller = SemiTimePickerController();

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    _status = _events.join('；');
  }

  /// onChanged date-first：单选 (DateTime?, String)、范围
  /// (`List<DateTime?>`, `List<String>`)；★变更判定格式化字符串判等，
  /// date 展示原始值。
  void _changed(Object? date, Object? dateStr) =>
      setState(() => _push('onChanged ${date ?? '（空）'}'));

  void _openChanged(bool open) => setState(() => _push('onOpenChange $open'));

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 触发器定宽（确定性量宽）；窄屏横向滚动，不溢出（switch/slider 的
  /// `_wideDemo` 模式）——面板是 overlay，不占行内宽度。
  Widget _demo(String label, Widget child, {double width = 280}) => Column(
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
          _section('基础用法', [
            SemiText(_status, key: const ValueKey('timepicker-status')),
            const SizedBox(height: 12),
            _demo(
              '默认 HH:mm:ss — 点开面板选时，事件写入上方日志（★格式化字符串判等）',
              SemiTimePicker(
                key: const ValueKey('timepicker-basic'),
                defaultValue: _seed930,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('format 格式', [
            _demo(
              "format='HH:mm' — 无秒列（列显隐由 HH|hh|H|h / mm / ss 决定）",
              SemiTimePicker(
                key: const ValueKey('timepicker-format-hm'),
                format: 'HH:mm',
                defaultValue: _seed930,
                onChanged: _changed,
              ),
            ),
            _demo(
              "format='HH' — 仅时列",
              SemiTimePicker(
                key: const ValueKey('timepicker-format-h'),
                format: 'HH',
                defaultValue: _seed930,
                onChanged: _changed,
              ),
            ),
            _demo(
              "format='mm:ss' — 无时列",
              SemiTimePicker(
                key: const ValueKey('timepicker-format-ms'),
                format: 'mm:ss',
                defaultValue: _seed930,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('12 小时制', [
            _demo(
              'use12Hours — AM/PM 列（上午/下午），小时列 [12, 01..11]'
              '（★a/A 均输出 zh 上午/下午）',
              SemiTimePicker(
                key: const ValueKey('timepicker-12h'),
                use12Hours: true,
                defaultValue: _seed930,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('步长', [
            _demo(
              'hourStep=2 minuteStep=15 secondStep=30'
              '（★当前值不在步进网格时高亮回退首个非禁用项）',
              SemiTimePicker(
                key: const ValueKey('timepicker-steps'),
                hourStep: 2,
                minuteStep: 15,
                secondStep: 30,
                defaultValue: _seed830,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用时间', [
            _demo(
              'disabledHours/Minutes/Seconds — 禁用项置灰不可点',
              SemiTimePicker(
                key: const ValueKey('timepicker-disabled'),
                defaultValue: _seed930,
                disabledHours: () => [7, 8, 10, 11],
                disabledMinutes: (hour) => [0, 1, 2],
                disabledSeconds: (hour, minute) => [58, 59],
                onChanged: _changed,
              ),
            ),
            _demo(
              'hideDisabledOptions — 禁用项从列移除'
              '（★selectedIndex -1 回退首个非禁用项）',
              SemiTimePicker(
                key: const ValueKey('timepicker-disabled-hide'),
                defaultValue: _seed930,
                disabledHours: () => [7, 8, 10, 11],
                disabledMinutes: (hour) => [0, 1, 2],
                disabledSeconds: (hour, minute) => [58, 59],
                hideDisabledOptions: true,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控', [
            _demo(
              'value 受控 — 按钮改值（严格受控，onChanged 只报不落地）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击切换时间',
                    key: const ValueKey('timepicker-controlled-bump'),
                    onPressed: () => setState(
                      () => _controlledValue = _controlledValue.hour == 8
                          ? _seed2000
                          : _seed800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SemiTimePicker(
                    key: const ValueKey('timepicker-controlled'),
                    value: _controlledValue,
                    onChanged: _changed,
                  ),
                ],
              ),
            ),
            _demo(
              'open 受控 — 按钮切换（onOpenChange 只报不落地，开关只由 open 驱动）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击切换面板',
                    key: const ValueKey('timepicker-controlled-open-toggle'),
                    onPressed: () => setState(() {
                      _controlledOpen = !_controlledOpen;
                      _push('open → $_controlledOpen');
                    }),
                  ),
                  const SizedBox(height: 12),
                  SemiTimePicker(
                    key: const ValueKey('timepicker-controlled-open'),
                    open: _controlledOpen,
                    defaultValue: _seed930,
                    onOpenChange: _openChanged,
                    onChanged: _changed,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('时间范围', [
            _demo(
              "type=timeRange — 双面板（开始/结束），默认 ' ~ ' 分隔",
              SemiTimePicker(
                key: const ValueKey('timepicker-range'),
                type: SemiTimePickerType.timeRange,
                defaultValue: _seedRange,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
              width: 520,
            ),
            _demo(
              "rangeSeparator=' 至 ' — 自定义分隔符",
              SemiTimePicker(
                key: const ValueKey('timepicker-range-sep'),
                type: SemiTimePickerType.timeRange,
                rangeSeparator: ' 至 ',
                defaultValue: _seedRange,
                onChanged: _changed,
              ),
              width: 520,
            ),
            _demo(
              'disabledTime — 左右面板差异化禁用（SemiTimeDisabledSpec，'
              '左禁 10 时、右不禁）',
              SemiTimePicker(
                key: const ValueKey('timepicker-range-disabled'),
                type: SemiTimePickerType.timeRange,
                defaultValue: _seedRange2,
                disabledTime: (value, side) {
                  if (side == SemiTimePickerPanelSide.left) {
                    return SemiTimeDisabledSpec(disabledHours: () => [10]);
                  }
                  return const SemiTimeDisabledSpec();
                },
                onChanged: _changed,
              ),
              width: 520,
            ),
          ]),
          const SizedBox(height: 40),
          _section('面板插槽', [
            _demo(
              'panelHeader / panelFooter — 面板控件上下附加元素'
              '（范围缺省头=开始时间/结束时间）',
              SemiTimePicker(
                key: const ValueKey('timepicker-slots'),
                defaultValue: _seed930,
                panelHeader: const SemiText('Panel Header'),
                panelFooter: const SemiText('Panel Footer'),
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义触发器与 controller', [
            _demo(
              'child — 自定义触发器（triggerRender 替身），点按钮开面板',
              SemiTimePicker(
                key: const ValueKey('timepicker-custom-trigger'),
                defaultValue: _seed930,
                onChanged: _changed,
                child: SemiButton(
                  '选择时间',
                  key: const ValueKey('timepicker-custom-trigger-btn'),
                  onPressed: () {},
                ),
              ),
            ),
            _demo(
              // 按钮放触发器右侧：面板挂在触发器下方（bottomLeft、约 192 宽），
              // 放下面会被弹层盖住点不到。
              'controller — open()/close()/focus()/blur() 命令式控制',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 280,
                    child: SemiTimePicker(
                      key: const ValueKey('timepicker-controller'),
                      defaultValue: _seed930,
                      controller: _controller,
                      onChanged: _changed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SemiButton(
                        'open',
                        key: const ValueKey('timepicker-controller-open'),
                        onPressed: _controller.open,
                      ),
                      const SizedBox(height: 8),
                      SemiButton(
                        'close',
                        key: const ValueKey('timepicker-controller-close'),
                        onPressed: _controller.close,
                      ),
                      const SizedBox(height: 8),
                      SemiButton(
                        'focus',
                        key: const ValueKey('timepicker-controller-focus'),
                        onPressed: _controller.focus,
                      ),
                      const SizedBox(height: 8),
                      SemiButton(
                        'blur',
                        key: const ValueKey('timepicker-controller-blur'),
                        onPressed: _controller.blur,
                      ),
                    ],
                  ),
                ],
              ),
              width: 520,
            ),
          ]),
          const SizedBox(height: 40),
          _section('输入形态', [
            _demo(
              'inputReadOnly — 只读输入（★仍可清，showClearIgnoreDisabled 语义）',
              SemiTimePicker(
                key: const ValueKey('timepicker-readonly'),
                inputReadOnly: true,
                clearText: '清空',
                defaultValue: _seed930,
                onChanged: _changed,
              ),
            ),
            _demo(
              "showClear=false 无清空按钮 / clearText='清空'（清空按钮 tooltip 语义）",
              KeyedSubtree(
                key: const ValueKey('timepicker-clear'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 280,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-clear-off'),
                        showClear: false,
                        defaultValue: _seed930,
                        onChanged: _changed,
                      ),
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 280,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-clear-text'),
                        clearText: '清空',
                        defaultValue: _seed930,
                        onChanged: _changed,
                      ),
                    ),
                  ],
                ),
              ),
              width: 640,
            ),
            _demo(
              'size — small / normal / large 三档',
              KeyedSubtree(
                key: const ValueKey('timepicker-sizes'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-sizes-small'),
                        size: SemiInputSize.small,
                        defaultValue: _seed930,
                        onChanged: _changed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 200,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-sizes-normal'),
                        defaultValue: _seed930,
                        onChanged: _changed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 200,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-sizes-large'),
                        size: SemiInputSize.large,
                        defaultValue: _seed930,
                        onChanged: _changed,
                      ),
                    ),
                  ],
                ),
              ),
              width: 640,
            ),
            _demo(
              'borderless / insetLabel / placeholder / disabled / '
              'validateStatus=error',
              KeyedSubtree(
                key: const ValueKey('timepicker-misc'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-misc-borderless'),
                        borderless: true,
                        insetLabel: const SemiText('时间'),
                        onChanged: _changed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 220,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-misc-placeholder'),
                        placeholder: '自定义文案',
                        onChanged: _changed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 220,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-misc-disabled'),
                        disabled: true,
                        defaultValue: _seed930,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 220,
                      child: SemiTimePicker(
                        key: const ValueKey('timepicker-misc-error'),
                        validateStatus: SemiInputStatus.error,
                        defaultValue: _seed930,
                        onChanged: _changed,
                      ),
                    ),
                  ],
                ),
              ),
              width: 960,
            ),
          ]),
          const SizedBox(height: 40),
          const SemiText(
            '未支持/延期（照 docs/semi_time_picker.md 差异清单）：'
            'wheel 无限滚动（scrollItemProps，仅 normal 滚动列表）、'
            'timeZone 时区换算、locale 多语言（zh 文案/上午下午硬编码）、'
            'Form 联动、键盘导航/Esc/autofocus、'
            'getPopupContainer/dropdownMargin/popupStyle/popupClassName 等'
            '粒度 props、panels 数组配置（panelHeader/panelFooter 收敛共享）、'
            'onChangeWithDateFirst 固定 date-first、triggerRender → child。',
            key: ValueKey('timepicker-unsupported-note'),
          ),
        ],
      ),
    );
  }
}
