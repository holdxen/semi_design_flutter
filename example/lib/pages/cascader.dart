import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CascaderPage extends StatefulWidget {
  const CascaderPage({super.key});

  @override
  State<CascaderPage> createState() => _CascaderPageState();
}

class _CascaderPageState extends State<CascaderPage> {
  String _status = '点击触发器逐级选择；事件按发生顺序回显。';

  // 事件回传顺序记录（onChange/onSelect/onSearch）。
  final List<String> _events = [];

  static const _data = <SemiCascaderData>[
    SemiCascaderData(
      value: 'zhejiang',
      label: '浙江',
      children: [
        SemiCascaderData(
          value: 'hangzhou',
          label: '杭州',
          children: [
            SemiCascaderData(value: 'xihu', label: '西湖区'),
            SemiCascaderData(value: 'binjiang', label: '滨江区'),
          ],
        ),
        SemiCascaderData(value: 'ningbo', label: '宁波'),
      ],
    ),
    SemiCascaderData(
      value: 'jiangsu',
      label: '江苏',
      children: [
        SemiCascaderData(value: 'nanjing', label: '南京', disabled: true),
        SemiCascaderData(value: 'suzhou', label: '苏州'),
      ],
    ),
  ];

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('cascader-status')),
          const SizedBox(height: 16),
          _section('基本用法', [
            _demo(
              '单选逐级展开；点击叶子选中并收起（changeOnSelect 缺省 false）。',
              SemiCascader(
                treeData: _data,
                placeholder: '请选择',
                onSelect: (value) => _push('onSelect $value'),
                onChange: (value) => _push('onChange $value'),
              ),
            ),
          ]),
          _section('changeOnSelect 与多选', [
            _demo(
              'changeOnSelect——非叶子也可选中（面板保持打开）。',
              SemiCascader(
                treeData: _data,
                placeholder: '任意级可选',
                changeOnSelect: true,
                onChange: (value) => _push('changeOnSelect onChange $value'),
              ),
            ),
            _demo(
              'multiple 级联勾选（related + autoMergeValue）；maxTagCount 折叠 +N。',
              SemiCascader(
                treeData: _data,
                multiple: true,
                maxTagCount: 2,
                showRestTagsPopover: true,
                placeholder: '多选',
                onChange: (value) => _push('multiple onChange $value'),
              ),
            ),
          ]),
          _section('搜索', [
            _demo(
              'filterTreeNode——触发器内搜索，扁平结果列表（缺省只命中叶子）。',
              SemiCascader(
                treeData: _data,
                placeholder: '搜索：试试「西」',
                filterTreeNode: true,
                onSearch: (input) {
                  if (input.isNotEmpty) _push('onSearch $input');
                },
                onChange: (value) => _push('search onChange $value'),
              ),
            ),
          ]),
          _section('异步加载', [
            _demo(
              'loadData——展开未加载节点时拉取子级（行尾 Spin）。',
              SemiCascader(
                treeData: const [
                  SemiCascaderData(value: 'root', label: '根节点（点击加载）'),
                ],
                placeholder: '异步',
                loadData: (path) =>
                    Future<void>.delayed(const Duration(milliseconds: 400)),
                onLoad: (keys, node) => _push('onLoad ${node.value}'),
                onChange: (value) => _push('load onChange $value'),
              ),
            ),
          ]),
          _section('尺寸与状态', [
            _demo(
              'small / default / large 三档。',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiCascader(
                    treeData: _data,
                    size: SemiInputSize.small,
                    placeholder: 'small',
                  ),
                  const SizedBox(height: 8),
                  SemiCascader(treeData: _data, placeholder: 'default'),
                  const SizedBox(height: 8),
                  SemiCascader(
                    treeData: _data,
                    size: SemiInputSize.large,
                    placeholder: 'large',
                  ),
                ],
              ),
            ),
            _demo(
              'disabled / validateStatus warning / error + showClear。',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SemiCascader(treeData: _data, disabled: true),
                  const SizedBox(height: 8),
                  SemiCascader(
                    treeData: _data,
                    placeholder: 'warning',
                    validateStatus: SemiInputStatus.warning,
                  ),
                  const SizedBox(height: 8),
                  SemiCascader(
                    treeData: _data,
                    placeholder: 'error',
                    validateStatus: SemiInputStatus.error,
                    showClear: true,
                  ),
                ],
              ),
            ),
            _demo(
              'borderless 静默态（hover/聚焦前透明底 + 隐藏箭头）。',
              SemiCascader(
                treeData: _data,
                borderless: true,
                placeholder: 'borderless',
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
