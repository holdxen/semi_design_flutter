import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  String _status = '点击或按空格切换开关查看事件。';

  // 受控单值（checked + onChanged 里 setState 落地，官方「受控组件」）。
  bool _controlled = true;

  // 外置文案（官方「带文本」第二个 demo：文本放开关外部）。
  bool _externalOpen = false;

  // 按钮改值（严格受控：开关本身只回调不落地）。
  bool _buttonChecked = false;

  // 事件回调顺序记录（官方 onMouseEnter / onMouseLeave / onBlur）。
  final List<String> _events = [];

  void _logChange(bool next) => setState(() => _status = next ? '开' : '关');

  /// 严格受控 demo 的回调：只报通知（显示不落地），文案区分于普通切换。
  void _strictLog(bool next) =>
      setState(() => _status = '严格：${next ? '开' : '关'}');

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
  }

  void _eventsChange(bool next) => setState(() {
    _push('onChanged ${next ? '开' : '关'}');
    _status = next ? '开' : '关';
  });

  void _eventsEnter() => setState(() {
    _push('onMouseEnter');
    _status = '鼠标移入';
  });

  void _eventsLeave() => setState(() {
    _push('onMouseLeave');
    _status = '鼠标移出';
  });

  void _eventsBlur() => setState(() {
    _push('onBlur');
    _status = '失焦';
  });

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 开关行是定宽紧凑控件；窄屏横向滚动，不溢出。
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      const SizedBox(height: 12),
    ],
  );

  /// 官方「尺寸」每行四个：未选中 / 选中 / loading / loading+选中。
  Widget _sizeRow(String label, SemiSwitchSize size, String slug) => _demo(
    label,
    Row(
      children: [
        SemiSwitch(
          key: ValueKey('switch-size-$slug'),
          size: size,
          onChanged: _logChange,
        ),
        const SizedBox(width: 12),
        SemiSwitch(
          key: ValueKey('switch-size-$slug-checked'),
          size: size,
          defaultChecked: true,
          onChanged: _logChange,
        ),
        const SizedBox(width: 12),
        SemiSwitch(
          key: ValueKey('switch-size-$slug-loading'),
          size: size,
          loading: true,
        ),
        const SizedBox(width: 12),
        SemiSwitch(
          key: ValueKey('switch-size-$slug-loading-checked'),
          size: size,
          loading: true,
          defaultChecked: true,
        ),
      ],
    ),
  );

  /// 官方「带文本」每行一对：开/关 与 ｜/〇。
  Widget _textRow(
    String label,
    String slug, {
    required SemiSwitchSize size,
    bool checked = false,
  }) => _demo(
    label,
    Row(
      children: [
        SemiSwitch(
          key: ValueKey('switch-text$slug'),
          size: size,
          defaultChecked: checked,
          checkedText: '开',
          uncheckedText: '关',
          onChanged: _logChange,
        ),
        const SizedBox(width: 12),
        SemiSwitch(
          key: ValueKey('switch-text$slug-alt'),
          size: size,
          defaultChecked: checked,
          checkedText: '｜',
          uncheckedText: '〇',
          onChanged: _logChange,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            SemiText(_status, key: const ValueKey('switch-status')),
            const SizedBox(height: 12),
            _demo(
              'onChange 监听状态变化',
              SemiSwitch(
                key: const ValueKey('switch-basic'),
                onChanged: _logChange,
              ),
            ),
            _demo(
              'defaultChecked 初始选中（非受控）',
              SemiSwitch(
                key: const ValueKey('switch-uncontrolled'),
                defaultChecked: true,
                onChanged: _logChange,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸', [
            const SemiText('每行：未选中 / 选中 / loading / loading+选中'),
            const SizedBox(height: 6),
            _sizeRow("size='small'", SemiSwitchSize.small, 'small'),
            _sizeRow("size='default'", SemiSwitchSize.normal, 'default'),
            _sizeRow("size='large'", SemiSwitchSize.large, 'large'),
          ]),
          const SizedBox(height: 40),
          _section('不可用', [
            _demo(
              'disabled（tap/Space 全屏蔽）',
              SemiSwitch(
                key: const ValueKey('switch-disabled'),
                disabled: true,
                onChanged: _logChange,
              ),
            ),
            _demo(
              'disabled + checked',
              SemiSwitch(
                key: const ValueKey('switch-disabled-checked'),
                disabled: true,
                checked: true,
                onChanged: _logChange,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('带文本', [
            _textRow(
              'checkedText/uncheckedText（默认尺寸）',
              '',
              size: SemiSwitchSize.normal,
            ),
            _textRow(
              'defaultChecked — 选中展示 checkedText',
              '-checked',
              size: SemiSwitchSize.normal,
              checked: true,
            ),
            _textRow("size='large'", '-large', size: SemiSwitchSize.large),
            _textRow(
              "size='large' + defaultChecked",
              '-large-checked',
              size: SemiSwitchSize.large,
              checked: true,
            ),
            _textRow(
              "size='small' — 文案一律不渲染（官方注记）",
              '-small',
              size: SemiSwitchSize.small,
            ),
            _textRow(
              "size='small' + defaultChecked",
              '-small-checked',
              size: SemiSwitchSize.small,
              checked: true,
            ),
            _demo(
              '文案放开关外部（官方推荐）',
              Row(
                children: [
                  SemiText(
                    _externalOpen ? '已开启' : '已关闭',
                    key: const ValueKey('switch-text-external-label'),
                  ),
                  const SizedBox(width: 12),
                  SemiSwitch(
                    key: const ValueKey('switch-text-external'),
                    checked: _externalOpen,
                    onChanged: (next) => setState(() {
                      _externalOpen = next;
                      _status = next ? '开' : '关';
                    }),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控组件', [
            _demo(
              '受控组件（checked + setState 落地）',
              SemiSwitch(
                key: const ValueKey('switch-controlled'),
                checked: _controlled,
                onChanged: (next) => setState(() {
                  _controlled = next;
                  _status = next ? '开' : '关';
                }),
              ),
            ),
            _demo(
              '点击按钮改值（严格受控，开关只回调不落地）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击切换状态',
                    key: const ValueKey('switch-controlled-bump'),
                    onPressed: () =>
                        setState(() => _buttonChecked = !_buttonChecked),
                  ),
                  const SizedBox(height: 12),
                  SemiSwitch(
                    key: const ValueKey('switch-controlled-button'),
                    checked: _buttonChecked,
                    onChanged: _strictLog,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('加载中', [
            _demo(
              'loading',
              SemiSwitch(
                key: const ValueKey('switch-loading'),
                loading: true,
                onChanged: _logChange,
              ),
            ),
            _demo(
              'loading + defaultChecked',
              SemiSwitch(
                key: const ValueKey('switch-loading-checked'),
                loading: true,
                defaultChecked: true,
                onChanged: _logChange,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('事件回调', [
            _demo(
              'onChanged / onMouseEnter / onMouseLeave / onBlur',
              SemiSwitch(
                key: const ValueKey('switch-events'),
                onChanged: _eventsChange,
                onMouseEnter: _eventsEnter,
                onMouseLeave: _eventsLeave,
                onBlur: _eventsBlur,
              ),
            ),
            SemiText(
              _events.isEmpty ? '（尚无事件）' : _events.join(' → '),
              key: const ValueKey('switch-events-log'),
            ),
          ]),
        ],
      ),
    );
  }
}
