import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  String _status = '拖动或点击滑块查看事件。';

  // 受控单值（value + onChanged 里 setState 落地）。
  double _controlled = 30;

  // 与输入框同步（官方「带输入框的」）。
  double _inputValue = 10;

  // 按钮改值（官方「受控组件」，严格受控：无 onChanged 不落地）。
  double _buttonValue = 10;

  // 事件回调顺序记录（官方 onHandleUpBefore / onAfterChange）。
  final List<String> _events = [];

  /// 回调输出为 double 或长度 2 的 List；整数值省略 `.0`（同 rating 的 _fmt）。
  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';

  String _fmtV(Object? v) {
    if (v is List) {
      return '[${v.map((e) => _fmt((e as num).toDouble())).join(', ')}]';
    }
    return _fmt((v as num).toDouble());
  }

  void _logChange(Object? v) => setState(() => _status = '变更：${_fmtV(v)}');
  void _logAfter(Object? v) => setState(() => _status = '提交：${_fmtV(v)}');

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
  }

  void _eventsChange(Object? v) => setState(() {
    _push('onChanged ${_fmtV(v)}');
    _status = '变更：${_fmtV(v)}';
  });

  void _eventsUp() => setState(() => _push('onMouseUp'));

  void _eventsAfter(Object? v) => setState(() {
    _push('onAfterChange ${_fmtV(v)}');
    _status = '提交：${_fmtV(v)}';
  });

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 全宽横向滑块直接占满内容宽（窄屏安全）。
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 12),
    ],
  );

  /// 定宽/组合示例横向滚动，窄屏不溢出。
  Widget _wideDemo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      const SizedBox(height: 12),
    ],
  );

  /// 垂直滑块：显式有界高度 + 左右留出刻度标签的余量。
  Widget _verticalDemo(
    String label,
    Widget slider, {
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24),
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      Padding(
        padding: padding,
        child: SizedBox(width: 4, height: 200, child: slider),
      ),
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
            SemiText(_status, key: const ValueKey('slider-status')),
            const SizedBox(height: 12),
            _demo(
              '默认（showBoundary: true，悬停显示 min/max）',
              SemiSlider(
                key: const ValueKey('slider-basic'),
                showBoundary: true,
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控', [
            _demo(
              '受控组件（value + setState 落地）',
              SemiSlider(
                key: const ValueKey('slider-controlled'),
                value: _controlled,
                onChanged: (v) => setState(() {
                  _controlled = (v as num).toDouble();
                  _status = '变更：${_fmtV(v)}';
                }),
                onAfterChange: _logAfter,
              ),
            ),
            _wideDemo(
              '与输入框同步（官方「带输入框的」）',
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: SemiSlider(
                      key: const ValueKey('slider-input'),
                      step: 1,
                      value: _inputValue,
                      onChanged: (v) => setState(() {
                        _inputValue = (v as num).toDouble();
                        _status = '变更：${_fmtV(v)}';
                      }),
                      onAfterChange: _logAfter,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: SemiInputNumber(
                      key: const ValueKey('slider-input-number'),
                      value: _inputValue,
                      min: 0,
                      max: 100,
                      onNumberChange: (n) => setState(() {
                        _inputValue = n.toDouble();
                        _status = '数值：${_fmt(_inputValue)}';
                      }),
                    ),
                  ),
                ],
              ),
            ),
            _demo(
              '点击按钮改值（严格受控，无 onChanged 不落地）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击增加值',
                    key: const ValueKey('slider-controlled-bump'),
                    onPressed: () => setState(() => _buttonValue += 10),
                  ),
                  const SizedBox(height: 12),
                  SemiSlider(
                    key: const ValueKey('slider-controlled-button'),
                    value: _buttonValue,
                    onAfterChange: _logAfter,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('范围选择', [
            _demo(
              'range=true（输出恒为升序对）',
              SemiSlider(
                key: const ValueKey('slider-range'),
                range: true,
                defaultValue: [20.0, 60.0],
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('步长', [
            _demo(
              'step=10, min=5 — 吸附网格相对 0（0/10/20…）',
              SemiSlider(
                key: const ValueKey('slider-step'),
                min: 5,
                max: 100,
                step: 10,
                defaultValue: 5,
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('刻度 marks', [
            _wideDemo(
              'step=10 marks（range）',
              SizedBox(
                width: 280,
                child: SemiSlider(
                  key: const ValueKey('slider-marks'),
                  step: 10,
                  marks: {
                    0: '0',
                    10: '10',
                    20: '20',
                    30: '30',
                    40: '40',
                    50: '50',
                    100: '100',
                  },
                  defaultValue: [10.0, 100.0],
                  range: true,
                  onChanged: _logChange,
                  onAfterChange: _logAfter,
                ),
              ),
            ),
            _wideDemo(
              'step=0.1 marks（range）',
              SizedBox(
                width: 280,
                child: SemiSlider(
                  key: const ValueKey('slider-marks-decimal'),
                  step: 0.1,
                  marks: {
                    0.1: '0.1',
                    0.2: '0.2',
                    0.3: '0.3',
                    0.4: '0.4',
                    0.5: '0.5',
                  },
                  min: 0,
                  max: 1,
                  defaultValue: [0.1, 0.5],
                  range: true,
                  onChanged: _logChange,
                  onAfterChange: _logAfter,
                ),
              ),
            ),
            _wideDemo(
              'Marks + tipFormatter（°C）',
              SizedBox(
                width: 280,
                child: SemiSlider(
                  key: const ValueKey('slider-marks-temp'),
                  marks: {20: '20°C', 40: '40°C'},
                  defaultValue: [0.0, 100.0],
                  range: true,
                  tipFormatter: (v) => '${_fmt(v)}°C',
                  getAriaValueText: (v, i) => '${_fmt(v)}°C',
                  onChanged: _logChange,
                  onAfterChange: _logAfter,
                ),
              ),
            ),
            _wideDemo(
              'included=false（隐藏填充轨）',
              SizedBox(
                width: 280,
                child: SemiSlider(
                  key: const ValueKey('slider-marks-included'),
                  marks: {20: '20°C', 40: '40°C'},
                  included: false,
                  defaultValue: [0.0, 100.0],
                  range: true,
                  tipFormatter: (v) => '${_fmt(v)}°C',
                  onChanged: _logChange,
                  onAfterChange: _logAfter,
                ),
              ),
            ),
            _wideDemo(
              'tooltipOnMark（悬停刻度点出提示）',
              SizedBox(
                width: 280,
                child: SemiSlider(
                  key: const ValueKey('slider-marks-tooltip'),
                  defaultValue: 50,
                  marks: {20: '20 分', 80: '80 分'},
                  tooltipOnMark: true,
                  onChanged: _logChange,
                  onAfterChange: _logAfter,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用', [
            _demo(
              'disabled=true（拖拽/点击/键盘全部禁用）',
              SemiSlider(
                key: const ValueKey('slider-disabled'),
                defaultValue: 40,
                disabled: true,
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('垂直', [
            _wideDemo(
              'vertical / range / marks',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _verticalDemo(
                    'vertical',
                    SemiSlider(
                      key: const ValueKey('slider-vertical'),
                      vertical: true,
                      onChanged: _logChange,
                      onAfterChange: _logAfter,
                    ),
                  ),
                  _verticalDemo(
                    'vertical range',
                    SemiSlider(
                      key: const ValueKey('slider-vertical-range'),
                      vertical: true,
                      range: true,
                      defaultValue: [20.0, 60.0],
                      onChanged: _logChange,
                      onAfterChange: _logAfter,
                    ),
                  ),
                  _verticalDemo(
                    'vertical marks',
                    SemiSlider(
                      key: const ValueKey('slider-vertical-marks'),
                      vertical: true,
                      range: true,
                      marks: {20: '20°C', 40: '40°C'},
                      step: 10,
                      defaultValue: [20.0, 60.0],
                      onChanged: _logChange,
                      onAfterChange: _logAfter,
                    ),
                    padding: const EdgeInsets.only(left: 24, right: 80),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('垂直反转', [
            _wideDemo(
              'verticalReverse / range / marks',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _verticalDemo(
                    'verticalReverse',
                    SemiSlider(
                      key: const ValueKey('slider-reverse'),
                      vertical: true,
                      verticalReverse: true,
                      onChanged: _logChange,
                      onAfterChange: _logAfter,
                    ),
                  ),
                  _verticalDemo(
                    'verticalReverse range',
                    SemiSlider(
                      key: const ValueKey('slider-reverse-range'),
                      vertical: true,
                      verticalReverse: true,
                      range: true,
                      defaultValue: [20.0, 60.0],
                      onChanged: _logChange,
                      onAfterChange: _logAfter,
                    ),
                  ),
                  _verticalDemo(
                    'verticalReverse marks',
                    SemiSlider(
                      key: const ValueKey('slider-reverse-marks'),
                      vertical: true,
                      verticalReverse: true,
                      range: true,
                      marks: {20: '20°C', 40: '40°C'},
                      step: 10,
                      defaultValue: [20.0, 60.0],
                      onChanged: _logChange,
                      onAfterChange: _logAfter,
                    ),
                    padding: const EdgeInsets.only(left: 80, right: 24),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('显示边界', [
            _wideDemo(
              'showBoundary=true — 悬停显示 min/max',
              SizedBox(
                width: 280,
                child: SemiSlider(
                  key: const ValueKey('slider-boundary'),
                  min: 5,
                  max: 50,
                  defaultValue: 20,
                  showBoundary: true,
                  onChanged: _logChange,
                  onAfterChange: _logAfter,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义 handleDot', [
            _demo(
              '默认 + handleDot（蓝点）',
              SemiSlider(
                key: const ValueKey('slider-dot'),
                showBoundary: true,
                handleDot: const SemiSliderHandleDot(
                  size: 4,
                  color: Color(0xff0000ff),
                ),
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
            _demo(
              'range + 双色 handleDot',
              SemiSlider(
                key: const ValueKey('slider-dot-range'),
                range: true,
                defaultValue: [20.0, 60.0],
                handleDot: const [
                  SemiSliderHandleDot(size: 4, color: Color(0xff0000ff)),
                  SemiSliderHandleDot(size: 4, color: Color(0xffffc0cb)),
                ],
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('tooltip/formatter', [
            _demo(
              'tipFormatter（\${v}%）',
              SemiSlider(
                key: const ValueKey('slider-tooltip'),
                defaultValue: 30,
                tipFormatter: (v) => '${_fmt(v)}%',
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
            _demo(
              'showTooltip=false（上游 tipFormatter: null）',
              SemiSlider(
                key: const ValueKey('slider-tooltip-hidden'),
                defaultValue: 30,
                showTooltip: false,
                onChanged: _logChange,
                onAfterChange: _logAfter,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('事件回调', [
            _demo(
              'onChanged / onMouseUp / onAfterChange',
              SemiSlider(
                key: const ValueKey('slider-events'),
                defaultValue: 20,
                onChanged: _eventsChange,
                onMouseUp: _eventsUp,
                onAfterChange: _eventsAfter,
              ),
            ),
            SemiText(
              _events.isEmpty ? '（尚无事件）' : _events.join(' → '),
              key: const ValueKey('slider-events-log'),
            ),
          ]),
        ],
      ),
    );
  }
}
