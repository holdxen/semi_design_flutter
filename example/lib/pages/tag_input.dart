import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TagInputPage extends StatefulWidget {
  const TagInputPage({super.key});

  @override
  State<TagInputPage> createState() => _TagInputPageState();
}

class _TagInputPageState extends State<TagInputPage> {
  String _status = '在输入框回车添加标签，查看事件。';

  // 受控（官方「标签受控」：value + onChanged 里 setState 落地）。
  List<String> _controlled = const ['抖音'];

  // 严格受控（slider-controlled-button 惯例）：字段只回调不落地，按钮改值。
  List<String> _buttonTags = const ['抖音', '火山'];
  int _buttonSeq = 0;

  // 输入受控（官方「输入受控」：inputValue + onInputChange 落地）。
  String _controlledInput = 'abc';

  // 自定义标签渲染（官方「自定义标签渲染」的受控 value）。
  List<String> _renderTags = const ['夏可漫'];

  // 焦点管理（官方「焦点管理」ref.focus()/blur()）。
  final SemiTagInputController _controller = SemiTagInputController();

  // 事件回调顺序记录（onChanged / onAdd / onRemove / onExceed /
  // onInputExceed，slider 的 events demo 模式）。
  final List<String> _events = [];

  String _fmt(List<String> v) => '[${v.join(', ')}]';

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
  }

  void _changed(List<String> v) => setState(() {
    _push('onChanged ${_fmt(v)}');
    _status = 'onChanged：${_fmt(v)}';
  });

  void _added(List<String> v) => setState(() {
    _push('onAdd ${_fmt(v)}');
    _status = 'onAdd：${_fmt(v)}';
  });

  void _removed(String value, int index) => setState(() {
    _push('onRemove $value@$index');
    _status = 'onRemove：$value@$index';
  });

  void _exceeded(List<String> v) => setState(() {
    _push('onExceed ${_fmt(v)}');
    _status = 'onExceed：${_fmt(v)}';
  });

  void _inputExceeded(String v) => setState(() {
    _push('onInputExceed $v');
    _status = 'onInputExceed：$v';
  });

  /// 严格受控回调：只报通知，显示只跟随按钮改的值。
  void _strictChanged(List<String> v) => setState(() {
    _push('onChanged ${_fmt(v)}');
    _status = '严格：${_fmt(v)}';
  });

  /// 「回调」demo 附带的输入行与焦点事件。
  void _inputChanged(String v) => setState(() {
    _push('onInputChange $v');
    _status = 'onInputChange：$v';
  });

  void _focusGained() => setState(() {
    _push('onFocus');
    _status = '聚焦';
  });

  void _blurred() => setState(() {
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

  /// 标签输入框定宽 400（确定性量宽）；窄屏横向滚动，不溢出
  /// （switch/slider 的 `_wideDemo` 模式）。
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: 400, child: child),
      ),
      const SizedBox(height: 12),
    ],
  );

  /// 自定义标签（官方 renderTagItem：头像 + name@semi.com + 关闭钮）。
  Widget _renderTagItem(String value, int index, VoidCallback onClose) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xffeaf2ff),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      SemiText('$value@semi.com'),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: onClose,
        child: const SemiIcon(SemiIcons.close, customSize: 12),
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
          _section('基本演示', [
            SemiText(_status, key: const ValueKey('taginput-status')),
            const SizedBox(height: 12),
            _demo(
              'defaultValue + placeholder，回车建标（空段过滤、★值不 trim）',
              SemiTagInput(
                key: const ValueKey('taginput-basic'),
                defaultValue: const ['抖音', '火山', '西瓜视频'],
                placeholder: '请输入...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('批量添加', [
            _demo(
              "separator='-' — 单分隔符批量输入",
              SemiTagInput(
                key: const ValueKey('taginput-separator'),
                separator: '-',
                placeholder: '使用 - 进行批量输入',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
            _demo(
              'separator=["-", "/", "|", "++"] — 多分隔符批量输入',
              SemiTagInput(
                key: const ValueKey('taginput-separator-multi'),
                separator: const ['-', '/', '|', '++'],
                placeholder: '支持多个分隔符进行批量输入',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('批量删除', [
            _demo(
              'showClear — 悬浮显示清除钮，一键清空标签与输入（不发 onRemove）',
              SemiTagInput(
                key: const ValueKey('taginput-clear'),
                showClear: true,
                defaultValue: const ['抖音', '火山'],
                placeholder: '请输入...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用', [
            _demo(
              'disabled — 输入/回车/关闭/清空全部屏蔽',
              SemiTagInput(
                key: const ValueKey('taginput-disabled'),
                disabled: true,
                showClear: true,
                defaultValue: const ['抖音', '火山', '西瓜视频'],
                placeholder: '请输入...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸大小', [
            _demo(
              "size='small'（根高 24）",
              SemiTagInput(
                key: const ValueKey('taginput-size-small'),
                size: SemiInputSize.small,
                placeholder: 'small',
              ),
            ),
            _demo(
              'size=default（根高 32）',
              SemiTagInput(
                key: const ValueKey('taginput-size-default'),
                placeholder: 'default',
              ),
            ),
            _demo(
              "size='large'（根高 40）",
              SemiTagInput(
                key: const ValueKey('taginput-size-large'),
                size: SemiInputSize.large,
                placeholder: 'large',
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('不同校验状态样式', [
            _demo(
              'validateStatus=default',
              SemiTagInput(
                key: const ValueKey('taginput-validate-default'),
                placeholder: 'default',
              ),
            ),
            _demo(
              'validateStatus=warning',
              SemiTagInput(
                key: const ValueKey('taginput-validate-warning'),
                validateStatus: SemiInputStatus.warning,
                placeholder: 'warning',
              ),
            ),
            _demo(
              'validateStatus=error',
              SemiTagInput(
                key: const ValueKey('taginput-validate-error'),
                validateStatus: SemiInputStatus.error,
                placeholder: 'error',
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('前缀 / 后缀', [
            _demo(
              'prefix 图标（点按聚焦输入）',
              SemiTagInput(
                key: const ValueKey('taginput-prefix-icon'),
                prefix: const SemiIcon(SemiIcons.user),
              ),
            ),
            _demo(
              'prefix 文本',
              SemiTagInput(
                key: const ValueKey('taginput-prefix'),
                prefix: 'Prefix',
              ),
            ),
            _demo(
              'suffix 图标',
              SemiTagInput(
                key: const ValueKey('taginput-suffix-icon'),
                suffix: const SemiIcon(SemiIcons.gift),
              ),
            ),
            _demo(
              'suffix 文本',
              SemiTagInput(
                key: const ValueKey('taginput-suffix'),
                suffix: 'Suffix',
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('失焦后自动创建标签', [
            _demo(
              'addOnBlur — 失焦时把待输入文本走完整添加流',
              SemiTagInput(
                key: const ValueKey('taginput-add-on-blur'),
                addOnBlur: true,
                defaultValue: const ['抖音', '火山', '西瓜视频'],
                placeholder: '请输入...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('过滤重复标签', [
            _demo(
              'allowDuplicates=false — 已存在与批内重复丢弃（保留首个）',
              SemiTagInput(
                key: const ValueKey('taginput-duplicates'),
                allowDuplicates: false,
                defaultValue: const ['抖音', '火山', '西瓜视频'],
                placeholder: '请输入...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('输入限制', [
            _demo(
              'max=3 — 超出触发 onExceed 并静默截尾',
              SemiTagInput(
                key: const ValueKey('taginput-max'),
                max: 3,
                placeholder: '最多输入3条标签..',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
                onExceed: _exceeded,
              ),
            ),
            _demo(
              'maxLength=5 — 单段超长拒绝并触发 onInputExceed',
              SemiTagInput(
                key: const ValueKey('taginput-max-length'),
                maxLength: 5,
                placeholder: '单个标签长度不超过5...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
                onInputExceed: _inputExceeded,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('限制标签展示数量', [
            _demo(
              'maxTagCount=2 — 超出折叠为 +N（悬浮显示余标 popover）',
              SemiTagInput(
                key: const ValueKey('taginput-max-tag-count'),
                maxTagCount: 2,
                showRestTagsPopover: true,
                defaultValue: const ['抖音', '火山', '西瓜视频'],
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('标签受控', [
            _demo(
              '受控组件（value + setState 落地）',
              SemiTagInput(
                key: const ValueKey('taginput-controlled'),
                value: _controlled,
                onChanged: (v) {
                  setState(() => _controlled = v);
                  _changed(v);
                },
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
            _demo(
              '点击按钮改值（严格受控，字段只回调不落地）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '点击追加标签',
                    key: const ValueKey('taginput-controlled-bump'),
                    onPressed: () => setState(() {
                      _buttonSeq += 1;
                      _buttonTags = [..._buttonTags, '新标签$_buttonSeq'];
                    }),
                  ),
                  const SizedBox(height: 12),
                  SemiTagInput(
                    key: const ValueKey('taginput-controlled-button'),
                    value: _buttonTags,
                    draggable: true,
                    onChanged: _strictChanged,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('输入受控', [
            _demo(
              'inputValue + onInputChange（输入行受控）',
              SemiTagInput(
                key: const ValueKey('taginput-controlled-input'),
                inputValue: _controlledInput,
                onInputChange: (v) => setState(() => _controlledInput = v),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('回调', [
            _demo(
              'onChanged/onAdd/onRemove/onInputChange/onFocus/onBlur',
              SemiTagInput(
                key: const ValueKey('taginput-events'),
                defaultValue: const ['抖音'],
                placeholder: '请输入...',
                showClear: true,
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
                onInputChange: _inputChanged,
                onFocusChange: (focused) {
                  if (focused) _focusGained();
                },
                onBlur: _blurred,
              ),
            ),
            SemiText(
              _events.isEmpty ? '（尚无事件）' : _events.join(' → '),
              key: const ValueKey('taginput-events-log'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('焦点管理', [
            _demo(
              'SemiTagInputController.focus()/blur()',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiTagInput(
                    key: const ValueKey('taginput-focus'),
                    defaultValue: const ['抖音', '火山'],
                    controller: _controller,
                  ),
                  const SizedBox(height: 10),
                  SemiButton(
                    '点击按钮聚焦',
                    key: const ValueKey('taginput-focus-button'),
                    onPressed: _controller.focus,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义标签渲染', [
            _demo(
              'renderTagItem（头像 + name@semi.com + 关闭钮 onClose）',
              SemiTagInput(
                key: const ValueKey('taginput-render-item'),
                value: _renderTags,
                renderTagItem: _renderTagItem,
                onChanged: (v) {
                  setState(() => _renderTags = v);
                  _changed(v);
                },
                onRemove: _removed,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('拖拽排序', [
            _demo(
              'draggable — 聚焦显示拖拽手柄，落点只发一次 onChanged',
              SemiTagInput(
                key: const ValueKey('taginput-draggable'),
                draggable: true,
                allowDuplicates: false,
                defaultValue: const ['抖音', '火山', '西瓜视频'],
                placeholder: '请输入...',
                onChanged: _changed,
                onAdd: _added,
                onRemove: _removed,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
