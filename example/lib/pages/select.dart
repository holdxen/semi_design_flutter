import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String _status = '点击选择框选中选项查看事件。';

  static const List<SemiSelectOption> _options = [
    SemiSelectOption(value: 'douyin', label: '抖音'),
    SemiSelectOption(value: 'ulikecam', label: '轻颜相机'),
    SemiSelectOption(value: 'jianying', label: '剪映', disabled: true),
    SemiSelectOption(value: 'xigua', label: '西瓜视频'),
  ];

  // 受控 + 动态 Options。
  Object? _controlled = 'douyin';
  List<SemiSelectOption> _dynamic = _options;

  // 远程搜索。
  Timer? _remoteDebounce;
  Timer? _remoteLatency;
  bool _remoteLoading = false;
  List<SemiSelectOption> _remoteOptions = const [];

  @override
  void dispose() {
    _remoteDebounce?.cancel();
    _remoteLatency?.cancel();
    super.dispose();
  }

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

  void _handleRemoteSearch(String input) {
    _remoteDebounce?.cancel();
    _remoteDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _remoteLoading = true);
      _remoteLatency?.cancel();
      _remoteLatency = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _remoteOptions = [
            for (final o in _options)
              if (o.label is String &&
                  (input.isEmpty || (o.label! as String).contains(input)))
                o,
          ];
          _remoteLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本使用', [
            SemiText(_status, key: const ValueKey('select-status')),
            const SizedBox(height: 12),
            _demo(
              'options 列表',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-basic'),
                  options: _options,
                  placeholder: '请选择',
                  onChanged: (value) => setState(() => _status = '选中：$value'),
                  onDropdownVisibleChange: (open) =>
                      setState(() => _status = open ? '面板已展开' : '面板已收起'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('多选', [
            _demo(
              'multiple + maxTagCount=2 + max=2（超出触发 onExceed）',
              SizedBox(
                width: 320,
                child: SemiSelect(
                  key: const ValueKey('select-multi'),
                  multiple: true,
                  maxTagCount: 2,
                  showRestTagsPopover: true,
                  max: 2,
                  defaultValue: ['douyin', 'ulikecam'],
                  options: _options,
                  placeholder: '请选择',
                  onChanged: (value) => setState(() => _status = '多选值：$value'),
                  onExceed: (_) => setState(() => _status = '最多只允许选择两项'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('分组', [
            SizedBox(
              width: 240,
              child: SemiSelect(
                key: const ValueKey('select-group'),
                placeholder: '请选择',
                groups: const [
                  SemiSelectGroup(
                    label: '字节系',
                    options: [
                      SemiSelectOption(value: 'douyin', label: '抖音'),
                      SemiSelectOption(value: 'xigua', label: '西瓜视频'),
                    ],
                  ),
                  SemiSelectGroup(
                    label: '工具',
                    options: [
                      SemiSelectOption(value: 'ulikecam', label: '轻颜相机'),
                      SemiSelectOption(
                        value: 'jianying',
                        label: '剪映',
                        disabled: true,
                      ),
                    ],
                  ),
                ],
                onChanged: (value) => setState(() => _status = '分组选中：$value'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸与状态', [
            _demo(
              'small',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-small'),
                  size: SemiInputSize.small,
                  options: _options,
                  defaultValue: 'douyin',
                ),
              ),
            ),
            _demo(
              'default',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-normal'),
                  size: SemiInputSize.normal,
                  options: _options,
                  defaultValue: 'douyin',
                ),
              ),
            ),
            _demo(
              'large',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-large'),
                  size: SemiInputSize.large,
                  options: _options,
                  defaultValue: 'douyin',
                ),
              ),
            ),
            _demo(
              '禁用与校验态',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 200,
                    child: SemiSelect(
                      key: const ValueKey('select-disabled'),
                      disabled: true,
                      options: _options,
                      defaultValue: 'douyin',
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: SemiSelect(
                      key: const ValueKey('select-warning'),
                      validateStatus: SemiInputStatus.warning,
                      options: _options,
                      defaultValue: 'douyin',
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: SemiSelect(
                      key: const ValueKey('select-error'),
                      validateStatus: SemiInputStatus.error,
                      options: _options,
                      defaultValue: 'douyin',
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('前缀、后缀与清除', [
            SizedBox(
              width: 280,
              child: SemiSelect(
                key: const ValueKey('select-prefix'),
                options: _options,
                defaultValue: 'douyin',
                showClear: true,
                prefix: '产品',
                suffix: '款',
                onChanged: (value) => setState(() => _status = '选中：$value'),
                onClear: () => setState(() => _status = '已清空'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('顶部/底部附加项', [
            SizedBox(
              width: 240,
              child: SemiSelect(
                key: const ValueKey('select-slots'),
                options: _options,
                placeholder: '带附加项',
                outerTopSlot: const Padding(
                  padding: EdgeInsets.all(8),
                  child: SemiText('outerTopSlot'),
                ),
                innerBottomSlot: const Padding(
                  padding: EdgeInsets.all(8),
                  child: SemiText('innerBottomSlot'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控与动态 Options', [
            _demo(
              '受控值：$_controlled',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-controlled'),
                  value: _controlled,
                  options: _options,
                  placeholder: '受控选择框',
                  onChanged: (value) => setState(() {
                    _controlled = value;
                    _status = '受控值：$value';
                  }),
                ),
              ),
            ),
            Row(
              children: [
                SemiButton(
                  const Text('设为西瓜视频'),
                  key: const ValueKey('select-set-xigua'),
                  onPressed: () => setState(() {
                    _controlled = 'xigua';
                    _status = '受控值：xigua';
                  }),
                ),
                const SizedBox(width: 8),
                SemiButton(
                  const Text('切换选项表'),
                  key: const ValueKey('select-toggle-options'),
                  onPressed: () => setState(() {
                    _dynamic = _dynamic.length == 4
                        ? _options.sublist(0, 2)
                        : _options;
                    _status = '选项数：${_dynamic.length}';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 240,
              child: SemiSelect(
                key: const ValueKey('select-dynamic'),
                options: _dynamic,
                placeholder: '动态 Options',
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('搜索', [
            _demo(
              "filter=true（label 与组 label 匹配）",
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-filter'),
                  filter: true,
                  options: _options,
                  placeholder: '搜索选择框',
                  onSearch: (input) => setState(() => _status = '搜索：「$input」'),
                ),
              ),
            ),
            _demo(
              '自定义搜索逻辑（大写匹配）',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-filter-func'),
                  filter: (String input, SemiSelectOption option) => option
                      .plainText
                      .toUpperCase()
                      .contains(input.toUpperCase()),
                  options: _options,
                  placeholder: '自定义 filter',
                ),
              ),
            ),
            _demo(
              'searchPosition=dropdown（搜索框在面板内）',
              SizedBox(
                width: 240,
                child: SemiSelect(
                  key: const ValueKey('select-filter-dropdown'),
                  filter: true,
                  searchPosition: SemiSelectSearchPosition.dropdown,
                  searchPlaceholder: '搜索选项',
                  options: _options,
                  placeholder: '面板内搜索',
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('远程搜索', [
            SizedBox(
              width: 280,
              child: SemiSelect(
                key: const ValueKey('select-remote'),
                filter: true,
                remote: true,
                loading: _remoteLoading,
                options: _remoteOptions,
                placeholder: '远程搜索（200ms 防抖 + 500ms 请求）',
                onSearch: _handleRemoteSearch,
                onChanged: (value) => setState(() => _status = '远程选中：$value'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('创建条目', [
            SizedBox(
              width: 240,
              child: SemiSelect(
                key: const ValueKey('select-create'),
                filter: true,
                allowCreate: true,
                options: _options,
                placeholder: '输入新条目并回车创建',
                onCreate: (option) =>
                    setState(() => _status = '创建了：${option.value}'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义渲染', [
            _demo(
              '自定义已选项与候选项',
              SizedBox(
                width: 280,
                child: SemiSelect(
                  key: const ValueKey('select-custom'),
                  options: _options,
                  defaultValue: 'douyin',
                  placeholder: '自定义渲染样式',
                  renderSelectedItem: (option) =>
                      Text('已选 · ${option.plainText}'),
                  renderOptionItem:
                      (
                        option, {
                        selected,
                        focused,
                        inputValue,
                        onHover,
                        onTap,
                      }) => GestureDetector(
                        onTap: onTap,
                        child: Row(
                          children: [
                            const SemiIcon(SemiIcons.star, customSize: 14),
                            const SizedBox(width: 8),
                            Text('${option.plainText}${selected ? ' ✓' : ''}'),
                          ],
                        ),
                      ),
                  onChanged: (value) => setState(() => _status = '选中：$value'),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
