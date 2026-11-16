import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  String _status = '点击步骤 / 切换 current，事件写入此行。';
  final List<String> _events = [];

  int _controlledCurrent = 1;

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  static const List<SemiStepData> _fillSteps = [
    SemiStepData(title: '已完成', description: '这是一段描述文案'),
    SemiStepData(title: '进行中', description: '这是一段描述文案'),
    SemiStepData(title: '等待中', description: '这是一段描述文案'),
  ];

  static const List<SemiStepData> _basicSteps = [
    SemiStepData(title: '填写信息', description: '基础信息'),
    SemiStepData(title: '验证身份', description: '短信验证'),
    SemiStepData(title: '完成', description: '提交成功'),
  ];

  static const List<SemiStepData> _statusSteps = [
    SemiStepData(title: '已完成', description: 'finish'),
    SemiStepData(
      title: '错误步骤',
      description: 'error',
      status: SemiStepStatus.error,
    ),
    SemiStepData(
      title: '警告步骤',
      description: 'warning',
      status: SemiStepStatus.warning,
    ),
    SemiStepData(title: '等待中', description: 'wait'),
  ];

  static const List<SemiStepData> _navSteps = [
    SemiStepData(title: '第一步'),
    SemiStepData(title: '第二步'),
    SemiStepData(title: '第三步'),
  ];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
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
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: SemiText(_status, key: const ValueKey('steps-status')),
            ),
          ),
          const SizedBox(height: 24),
          _section('fill（默认）', [
            _demo(
              'current: 1 — 左序号/状态图标 + 标题 + 描述；done → tick、当前 process '
              '原色、等待 fill-0 序号；点击非当前步发 onChange',
              SemiSteps(
                key: const ValueKey('steps-fill'),
                steps: _fillSteps,
                current: 1,
                onChange: (current) => _push('onChange $current'),
              ),
            ),
            _demo(
              'direction: vertical — 每步等高卡片纵向排布',
              SemiSteps(
                key: const ValueKey('steps-fill-vertical'),
                steps: _fillSteps,
                current: 2,
                direction: SemiStepsDirection.vertical,
                onChange: (current) => _push('onChange $current'),
              ),
            ),
            _demo(
              '状态覆盖 — finish/error/warning/wait 混排（step.status 优先）',
              const SemiSteps(
                key: ValueKey('steps-fill-status'),
                steps: _statusSteps,
                current: 1,
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('basic 简版', [
            _demo(
              '水平 + hasLine — 标题 + 连接线（done 连接线 primary）；current: 1',
              const SemiSteps(
                key: ValueKey('steps-basic'),
                type: SemiStepsType.basic,
                steps: _basicSteps,
                current: 1,
              ),
            ),
            _demo(
              '垂直 + hasLine — icon 列下接垂直连接线，content min-height 42',
              const SemiSteps(
                key: ValueKey('steps-basic-vertical'),
                type: SemiStepsType.basic,
                direction: SemiStepsDirection.vertical,
                steps: _basicSteps,
                current: 0,
              ),
            ),
            _demo(
              'size: small — 序号 20、标题 14；可点击（hover 标题/描述变色）',
              SemiSteps(
                key: const ValueKey('steps-basic-small'),
                type: SemiStepsType.basic,
                size: SemiStepSize.small,
                steps: _basicSteps,
                current: 1,
                onChange: (current) => _push('onChange $current'),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('nav 导航式', [
            _demo(
              'current: 1 — 当前项 text-0 + 600，非末项 chevron（grey-3）；'
              'small 标题 14；点击发 onChange',
              SemiSteps(
                key: const ValueKey('steps-nav'),
                type: SemiStepsType.nav,
                steps: _navSteps,
                current: 1,
                onChange: (current) => _push('onChange $current'),
              ),
            ),
            _demo(
              'size: small',
              SemiSteps(
                key: const ValueKey('steps-nav-small'),
                type: SemiStepsType.nav,
                size: SemiStepSize.small,
                steps: _navSteps,
                current: 2,
                onChange: (current) => _push('onChange $current'),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('受控 current 与自定义图标', [
            _demo(
              'current 受控 — 按钮改值 _controlledCurrent；点击只回传 onChange',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SemiButton(
                        '上一步',
                        onPressed: () => setState(() {
                          if (_controlledCurrent > 0) _controlledCurrent--;
                        }),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '下一步',
                        onPressed: () => setState(() {
                          if (_controlledCurrent < _fillSteps.length - 1) {
                            _controlledCurrent++;
                          }
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SemiSteps(
                    key: const ValueKey('steps-controlled'),
                    steps: _fillSteps,
                    current: _controlledCurrent,
                    onChange: (current) => _push('onChange $current'),
                  ),
                ],
              ),
            ),
            _demo(
              '自定义 icon（SemiStepData.icon 覆盖状态图标；basic 不再渲染序号）',
              const SemiSteps(
                key: ValueKey('steps-custom-icon'),
                type: SemiStepsType.basic,
                steps: [
                  SemiStepData(
                    title: '首页',
                    icon: SemiIcon(SemiIcons.home),
                    status: SemiStepStatus.finish,
                  ),
                  SemiStepData(
                    title: '设置',
                    icon: SemiIcon(SemiIcons.setting),
                    status: SemiStepStatus.process,
                  ),
                  SemiStepData(
                    title: '完成',
                    icon: SemiIcon(SemiIcons.tickCircle),
                  ),
                ],
                current: 1,
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('RTL', [
            _demo(
              'Directionality.rtl — 边距镜像、水平连接线随标题方向；nav 反向排列',
              const Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiSteps(
                      key: ValueKey('steps-rtl-fill'),
                      steps: _fillSteps,
                      current: 1,
                    ),
                    SizedBox(height: 16),
                    SemiSteps(
                      key: ValueKey('steps-rtl-basic'),
                      type: SemiStepsType.basic,
                      steps: _basicSteps,
                      current: 1,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
