import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TreeSelectPage extends StatefulWidget {
  const TreeSelectPage({super.key});

  @override
  State<TreeSelectPage> createState() => _TreeSelectPageState();
}

class _TreeSelectPageState extends State<TreeSelectPage> {
  String _status = '选择/勾选/过滤/清空，事件写入此行。';
  final List<String> _events = [];

  final Object _controlledValue = 'd';
  List<String> _controlledExpanded = const ['a'];

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  // ---- 基础数据（const——treeData 引用稳定） ----

  static const List<SemiTreeNodeData> _basicData = [
    SemiTreeNodeData(
      key: 'a',
      label: '研发',
      children: [
        SemiTreeNodeData(key: 'a-1', label: '前端', value: 'fe'),
        SemiTreeNodeData(key: 'a-2', label: '后端', value: 'be'),
        SemiTreeNodeData(key: 'a-3', label: '测试（禁用）', disabled: true),
      ],
    ),
    SemiTreeNodeData(
      key: 'b',
      label: '设计',
      children: [
        SemiTreeNodeData(key: 'b-1', label: '视觉'),
        SemiTreeNodeData(key: 'b-2', label: '交互'),
      ],
    ),
    SemiTreeNodeData(key: 'c', label: '运营', isLeaf: true),
    SemiTreeNodeData(key: 'd', label: '行政', isLeaf: true),
  ];

  static final List<SemiTreeNodeData> _lazyData = [
    const SemiTreeNodeData(key: 'lazy-root', label: '部门（懒加载）'),
    const SemiTreeNodeData(key: 'lazy-done', label: '已加载', isLeaf: true),
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
              child: SemiText(
                _status,
                key: const ValueKey('treeSelect-status'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section('基础', [
            _demo(
              '单选（选中收起弹层、回填标签文案）',
              SizedBox(
                width: 320,
                child: SemiTreeSelect(
                  key: const ValueKey('basic-single'),
                  treeData: _basicData,
                  placeholder: '请选择部门',
                  onSelect: (key, selected, node) =>
                      _push('onSelect:$key:$selected'),
                  onChange: (value) => _push('onChange:$value'),
                ),
              ),
            ),
            _demo(
              '多选（级联勾选、标签关闭）',
              SizedBox(
                width: 380,
                child: SemiTreeSelect(
                  key: const ValueKey('basic-multiple'),
                  treeData: _basicData,
                  multiple: true,
                  placeholder: '请选择成员',
                  onSelect: (key, selected, node) =>
                      _push('onSelect:$key:$selected'),
                  onChange: (value) => _push('onChange:$value'),
                ),
              ),
            ),
            _demo(
              '回填 + 清空（showClear）',
              SizedBox(
                width: 320,
                child: SemiTreeSelect(
                  key: const ValueKey('basic-clear'),
                  treeData: _basicData,
                  showClear: true,
                  defaultValue: 'fe',
                  placeholder: '请选择',
                  onChange: (value) => _push('onChange:$value'),
                  onClear: () => _push('onClear'),
                ),
              ),
            ),
          ]),
          _section('搜索', [
            _demo(
              '弹层内搜索（filterTreeNode）',
              SizedBox(
                width: 320,
                child: SemiTreeSelect(
                  key: const ValueKey('search-dropdown'),
                  treeData: _basicData,
                  filterTreeNode: true,
                  searchPlaceholder: '搜索部门',
                  onSearch: (input, keys, nodes) => _push('onSearch:$input'),
                  onChange: (value) => _push('onChange:$value'),
                ),
              ),
            ),
            _demo(
              '触发器内搜索（searchPosition: trigger，多选）',
              SizedBox(
                width: 380,
                child: SemiTreeSelect(
                  key: const ValueKey('search-trigger'),
                  treeData: _basicData,
                  multiple: true,
                  filterTreeNode: true,
                  searchPosition: SemiTreeSelectSearchPosition.trigger,
                  placeholder: '搜索并多选',
                  onSearch: (input, keys, nodes) => _push('onSearch:$input'),
                  onChange: (value) => _push('onChange:$value'),
                ),
              ),
            ),
          ]),
          _section('形态', [
            _demo(
              '尺寸三档 + 校验状态',
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 240,
                    child: SemiTreeSelect(
                      key: ValueKey('size-small'),
                      treeData: _basicData,
                      size: SemiInputSize.small,
                      placeholder: 'small 24',
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 240,
                    child: SemiTreeSelect(
                      key: ValueKey('size-normal'),
                      treeData: _basicData,
                      placeholder: 'default 32',
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 240,
                    child: SemiTreeSelect(
                      key: ValueKey('size-large'),
                      treeData: _basicData,
                      size: SemiInputSize.large,
                      placeholder: 'large 40',
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 240,
                    child: SemiTreeSelect(
                      key: ValueKey('status-warning'),
                      treeData: _basicData,
                      placeholder: 'warning',
                      validateStatus: SemiInputStatus.warning,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 240,
                    child: SemiTreeSelect(
                      key: ValueKey('status-error'),
                      treeData: _basicData,
                      placeholder: 'error',
                      validateStatus: SemiInputStatus.error,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 240,
                    child: SemiTreeSelect(
                      key: ValueKey('form-disabled'),
                      treeData: _basicData,
                      disabled: true,
                      defaultValue: 'fe',
                    ),
                  ),
                ],
              ),
            ),
            _demo(
              '无边框（borderless）',
              const SizedBox(
                width: 240,
                child: SemiTreeSelect(
                  key: ValueKey('form-borderless'),
                  treeData: _basicData,
                  borderless: true,
                  placeholder: 'hover / 聚焦显示',
                ),
              ),
            ),
            _demo(
              '前缀 / 后缀 / 多选折叠 +N',
              SizedBox(
                width: 380,
                child: SemiTreeSelect(
                  key: const ValueKey('form-slots'),
                  treeData: _basicData,
                  multiple: true,
                  defaultValue: const ['a-1', 'a-2', 'b-1', 'b-2'],
                  maxTagCount: 2,
                  showRestTagsPopover: true,
                  prefix: const SemiIcon(SemiIcons.user),
                  suffix: '人',
                  onChange: (value) => _push('onChange:$value'),
                ),
              ),
            ),
          ]),
          _section('受控 / 异步', [
            _demo(
              '受控 value + expandedKeys（交互只回调）',
              SizedBox(
                width: 320,
                child: SemiTreeSelect(
                  key: const ValueKey('controlled'),
                  treeData: _basicData,
                  value: _controlledValue,
                  expandedKeys: _controlledExpanded,
                  placeholder: '受控',
                  onChange: (value) => _push('onChange:$value'),
                  onExpand: (keys, expanded, node) {
                    _push('onExpand:${node.key}:$expanded');
                    setState(() {
                      _controlledExpanded = expanded
                          ? [..._controlledExpanded, node.key]
                          : _controlledExpanded
                                .where((k) => k != node.key)
                                .toList();
                    });
                  },
                ),
              ),
            ),
            _demo(
              '异步加载（loadData + Spin）',
              SizedBox(
                width: 320,
                child: SemiTreeSelect(
                  key: const ValueKey('lazy'),
                  treeData: _lazyData,
                  loadData: (node) async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                  },
                  onLoad: (keys, node) => _push('onLoad:${node.key}'),
                  onChange: (value) => _push('onChange:$value'),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
