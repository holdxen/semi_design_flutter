import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  // 初始状态行即标注默认品牌色种子（#39c5bb；★计算 hex 为 #39c4bb——
  // RGB↔HSV 整数取整回程差，docs/semi_color_picker.md 差异清单 ①）。
  String _status = '默认品牌色 #39c5bb（★计算 hex #39c4bb）— 拖动滑条或输入查看事件。';

  // 受控（官方「受控」：value + onChanged 里 setState 落地）。
  SemiColorValue _controlled = SemiColorValue.parse('#39c5bb');

  // 严格受控（slider-controlled-button 惯例）：字段只回调不落地，按钮改值。
  static const SemiColorValue _buttonA = SemiColorValue(h: 120, s: 80, v: 60);
  static const SemiColorValue _buttonB = SemiColorValue(h: 300, s: 60, v: 40);
  SemiColorValue _buttonValue = _buttonA;

  // 事件回调顺序记录（onChanged / onEyeDropper / onOpenChange，slider 的
  // events demo 模式）。
  final List<String> _events = [];

  void _push(String event) {
    _events.add(event);
    if (_events.length > 8) _events.removeRange(0, _events.length - 8);
  }

  static String _num(double n) =>
      n == n.roundToDouble() ? '${n.round()}' : '$n';

  String _summary(SemiColorValue v) =>
      '${v.hex}（h=${_num(v.h)} s=${_num(v.s)} v=${_num(v.v)} '
      'a=${v.a.toStringAsFixed(2)}）';

  void _changed(SemiColorValue v) => setState(() {
    _push('onChanged ${v.hex}');
    _status = 'onChanged：${_summary(v)}';
  });

  /// 严格受控回调：只报通知，显示只跟随按钮改的值。
  void _strictChanged(SemiColorValue v) => setState(() {
    _push('onChanged ${v.hex}');
    _status = '严格：${_summary(v)}';
  });

  void _openChanged(bool open) => setState(() => _push('onOpenChange $open'));

  /// 吸管宿主桥（官方 eyeDropper；WICG EyeDropper 无 Flutter 通道）：
  /// 返回 rgba(…) 字符串——★结果强制 a=1。
  Future<Object?> _pickStraw() async {
    const result = 'rgba(255, 0, 0, 0.5)';
    setState(() {
      _push('onEyeDropper $result');
      _status = 'onEyeDropper：$result';
    });
    return result;
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 取色面板定宽（确定性量宽）；窄屏横向滚动，不溢出（switch/slider 的
  /// `_wideDemo` 模式）。
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

  /// 颜色转换方法行（官方 colorStringToValue 的移植 SemiColorValue.parse）。
  Widget _convertLine(String expr, SemiColorValue? value, String note) =>
      SemiText(
        value == null
            ? '$expr → null（$note）'
            : '$expr → h=${_num(value.h)} s=${_num(value.s)} '
                  'v=${_num(value.v)} a=${value.a.toStringAsFixed(2)} '
                  'hex=${value.hex}（$note）',
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            SemiText(_status, key: const ValueKey('colorpicker-status')),
            const SizedBox(height: 12),
            _demo(
              '放在弹层（usePopover）— hover 默认 24×24 色块触发',
              SemiColorPicker(
                key: const ValueKey('colorpicker-popover'),
                alpha: true,
                usePopover: true,
                onChanged: _changed,
                onOpenChange: _openChanged,
              ),
            ),
            _demo(
              '自定义 trigger（usePopover + child）— hover 按钮触发',
              SemiColorPicker(
                key: const ValueKey('colorpicker-popover-custom'),
                alpha: true,
                usePopover: true,
                onChanged: _changed,
                onOpenChange: _openChanged,
                child: SemiButton(
                  'Trigger',
                  key: const ValueKey('colorpicker-popover-custom-trigger'),
                  onPressed: () {},
                ),
              ),
            ),
            _demo(
              '正常展示 — inline 面板（alpha=true）',
              SemiColorPicker(
                key: const ValueKey('colorpicker-basic'),
                alpha: true,
                onChanged: _changed,
              ),
            ),
            const SemiText(
              '未支持（上游非 demo 能力）：className/style/inputProps/'
              'popoverProps、InputGroup 连体边框（本移植为普通 Row）、弹层 '
              'repositionKey；键盘操作/RTL/Form 上游即无。',
              key: ValueKey('colorpicker-unsupported-note'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('滴管取色器', [
            _demo(
              'eyeDropper + onEyeDropper 宿主桥 — ★rgba(…) 结果强制 a=1',
              SemiColorPicker(
                key: const ValueKey('colorpicker-eyedropper'),
                alpha: true,
                eyeDropper: true,
                onEyeDropper: _pickStraw,
                onChanged: _changed,
              ),
            ),
            _demo(
              '无 onEyeDropper — 取色按钮不渲染（上游 window.EyeDropper 门）',
              SemiColorPicker(
                key: const ValueKey('colorpicker-eyedropper-hidden'),
                alpha: true,
                eyeDropper: true,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('默认值', [
            _demo(
              "defaultValue=SemiColorValue.parse('rgb(57,197,187)')"
              '（品牌色 #39c5bb，★计算 hex #39c4bb）',
              SemiColorPicker(
                key: const ValueKey('colorpicker-default-value'),
                alpha: true,
                defaultValue: SemiColorValue.parse('rgb(57,197,187)'),
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控', [
            _demo(
              'value + onChanged setState 落地',
              SemiColorPicker(
                key: const ValueKey('colorpicker-controlled'),
                alpha: true,
                value: _controlled,
                onChanged: (v) {
                  setState(() => _controlled = v);
                  _changed(v);
                },
              ),
            ),
            _demo(
              '点击按钮改值（严格受控，选择器只回调不落地）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击切换颜色',
                    key: const ValueKey('colorpicker-controlled-bump'),
                    onPressed: () => setState(
                      () => _buttonValue = identical(_buttonValue, _buttonA)
                          ? _buttonB
                          : _buttonA,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SemiColorPicker(
                    key: const ValueKey('colorpicker-controlled-button'),
                    alpha: true,
                    value: _buttonValue,
                    onChanged: _strictChanged,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('顶部和底部渲染额外元素', [
            _demo(
              'topSlot / bottomSlot — 面板控件上下附加元素',
              SemiColorPicker(
                key: const ValueKey('colorpicker-slots'),
                alpha: true,
                topSlot: const SemiText('TopSlot'),
                bottomSlot: const SemiText('Bottom Slot'),
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('透明度 alpha', [
            _demo(
              'alpha=true — 透明度滑条与 % 输入（★a 固定 2 位小数、hex 8 位）',
              SemiColorPicker(
                key: const ValueKey('colorpicker-alpha'),
                alpha: true,
                onChanged: _changed,
              ),
            ),
            _demo(
              'alpha=false — ★每次提交强制 a=1 / 6 位 hex（提交级归一）',
              SemiColorPicker(
                key: const ValueKey('colorpicker-alpha-off'),
                alpha: false,
                defaultFormat: SemiColorFormat.rgba,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('格式切换（defaultFormat）', [
            _demo(
              'defaultFormat=hex — 格式 Select 切换显示与解析口径'
              '（★非法输入保留原文不回退）',
              SemiColorPicker(
                key: const ValueKey('colorpicker-format'),
                alpha: true,
                defaultFormat: SemiColorFormat.hex,
                onChanged: _changed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义尺寸', [
            _demo(
              'width=200 height=160 — width 贯穿面板，height 仅 SV 区',
              SemiColorPicker(
                key: const ValueKey('colorpicker-size'),
                alpha: true,
                width: 200,
                height: 160,
                onChanged: _changed,
              ),
              width: 200,
            ),
          ]),
          const SizedBox(height: 40),
          _section('事件回调', [
            _demo(
              'onChanged / onEyeDropper — onOpenChange 由弹层 demo 触发',
              SemiColorPicker(
                key: const ValueKey('colorpicker-events'),
                alpha: true,
                onEyeDropper: _pickStraw,
                onChanged: _changed,
              ),
            ),
            SemiText(
              _events.isEmpty ? '（尚无事件）' : _events.join(' → '),
              key: const ValueKey('colorpicker-events-log'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('颜色转换方法', [
            Column(
              key: const ValueKey('colorpicker-convert'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _convertLine(
                  "SemiColorValue.parse('#39c5bb')",
                  SemiColorValue.parse('#39c5bb'),
                  '★计算 hex #39c4bb：RGB↔HSV 整数取整回程差',
                ),
                _convertLine(
                  "SemiColorValue.parse('rgb(57,197,187)')",
                  SemiColorValue.parse('rgb(57,197,187)'),
                  '与上行相等（品牌色 #39c5bb）',
                ),
                _convertLine(
                  "SemiColorValue.parse('hsv(176,71,77)')",
                  SemiColorValue.parse('hsv(176,71,77)'),
                  '与默认品牌值相等',
                ),
                _convertLine(
                  "SemiColorValue.parse('#abc')",
                  SemiColorValue.parse('#abc'),
                  '★宽松 3 位简写：缺分量坍缩为 0（上游 NaN）',
                ),
                _convertLine(
                  "SemiColorValue.tryParse('green')",
                  SemiColorValue.tryParse('green'),
                  '无 #/rgb/hsv 前缀 → null（parse 抛 ArgumentError）',
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
