import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  String _status = '展开/选择/勾选/过滤/加载，事件写入此行。';
  final List<String> _events = [];

  // 受控 expandedKeys / value。
  List<String> _controlledExpanded = const ['c1'];
  Object? _controlledValue = 'c1-1';

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  // ---- 基础数据（const——treeData 引用稳定） ----

  static const List<SemiTreeNodeData> _basicData = [
    SemiTreeNodeData(
      key: 'parent',
      label: '父节点',
      icon: SemiIcon(SemiIcons.folder),
      children: [
        SemiTreeNodeData(
          key: 'child-1',
          label: '子节点 A',
          icon: SemiIcon(SemiIcons.file),
        ),
        SemiTreeNodeData(
          key: 'child-2',
          label: '子节点 B',
          icon: SemiIcon(SemiIcons.file),
        ),
        SemiTreeNodeData(key: 'child-3', label: '子节点 C（禁用）', disabled: true),
      ],
    ),
    SemiTreeNodeData(
      key: 'leaf',
      label: '叶子节点',
      isLeaf: true,
      icon: SemiIcon(SemiIcons.file),
    ),
  ];

  static const List<SemiTreeNodeData> _directoryData = [
    SemiTreeNodeData(
      key: 'docs',
      label: '文档',
      children: [
        SemiTreeNodeData(
          key: 'docs-spec',
          label: '规范',
          children: [
            SemiTreeNodeData(
              key: 'docs-spec-api',
              label: 'API.md',
              isLeaf: true,
            ),
            SemiTreeNodeData(
              key: 'docs-spec-design',
              label: 'Design.md',
              isLeaf: true,
            ),
          ],
        ),
        SemiTreeNodeData(key: 'docs-readme', label: 'README.md', isLeaf: true),
      ],
    ),
    SemiTreeNodeData(
      key: 'src',
      label: '源码',
      children: [
        SemiTreeNodeData(key: 'src-tree', label: 'tree.dart', isLeaf: true),
      ],
    ),
  ];

  static const List<SemiTreeNodeData> _controlledData = [
    SemiTreeNodeData(
      key: 'c1',
      label: '受控父级',
      children: [
        SemiTreeNodeData(key: 'c1-1', label: '受控子一'),
        SemiTreeNodeData(key: 'c1-2', label: '受控子二'),
      ],
    ),
    SemiTreeNodeData(key: 'c2', label: '受控叶子', isLeaf: true),
  ];

  static List<SemiTreeNodeData> _virtualData(int count) => [
    for (var i = 1; i <= count; i++)
      SemiTreeNodeData(key: 'v$i', label: '虚拟行 $i', isLeaf: true),
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
          // ★定高日志行：事件追加变高会把下方内容下推（指针静止但控件移走
          // 会触发 hover 区 exit 抖动）。
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: SemiText(_status, key: const ValueKey('tree-status')),
            ),
          ),
          const SizedBox(height: 24),
          _section('基础', [
            _demo(
              'defaultExpandedKeys + 单选（onSelect 恒 true quirk；onChange 回传 '
              'value ?? key）+ 禁用节点（不可选但可展开）+ 运动展开收起',
              SizedBox(
                height: 240,
                child: SemiTree(
                  key: const ValueKey('tree-basic'),
                  treeData: _basicData,
                  defaultExpandedKeys: const ['parent'],
                  onSelect: (key, selected, node) =>
                      _push('onSelect $key/$selected'),
                  onChange: (value) => _push('onChange $value'),
                  onExpand: (keys, expanded, node) =>
                      _push('onExpand ${node.key}/$expanded'),
                ),
              ),
            ),
            _demo(
              'expandAction: click（整行点击即展开）与 doubleClick（300ms 内双击）',
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: SemiTree(
                        key: ValueKey('tree-click-expand'),
                        treeData: _basicData,
                        expandAction: SemiTreeExpandAction.click,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: SemiTree(
                        key: ValueKey('tree-double-expand'),
                        treeData: _basicData,
                        expandAction: SemiTreeExpandAction.doubleClick,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('目录 / 引导线', [
            _demo(
              'directory: true（folder / folder-open / file 兜底）+ showLine '
              '（每级缩进引导线 + 叶子折线）',
              const SizedBox(
                height: 260,
                child: SemiTree(
                  key: ValueKey('tree-directory'),
                  treeData: _directoryData,
                  directory: true,
                  showLine: true,
                  defaultExpandedKeys: ['docs', 'docs-spec'],
                ),
              ),
            ),
            _demo(
              'showLine + blockNode: false（底色只染标题文字区）',
              const SizedBox(
                height: 220,
                child: SemiTree(
                  key: ValueKey('tree-line-label'),
                  treeData: _directoryData,
                  showLine: true,
                  blockNode: false,
                  defaultExpandedKeys: ['docs'],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('多选与过滤', [
            _demo(
              'multiple + checkRelation: related — 勾选级联后代、祖先半选；'
              'autoMergeValue 去祖先、leafOnly 只留叶子；行点击与 checkbox 同逻辑',
              SizedBox(
                height: 240,
                child: SemiTree(
                  key: const ValueKey('tree-multiple'),
                  treeData: _basicData,
                  defaultExpandedKeys: const ['parent'],
                  multiple: true,
                  leafOnly: true,
                  onChange: (value) => _push('onChange $value'),
                  onSelect: (key, selected, node) =>
                      _push('onSelect $key/$selected'),
                ),
              ),
            ),
            _demo(
              'filterTreeNode: true + treeNodeFilterProp: label — 命中节点祖先自动展开'
              '并高亮（bold + primary）；showFilteredOnly: true 只留命中链',
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: SemiTree(
                      key: ValueKey('tree-filter'),
                      treeData: _directoryData,
                      filterTreeNode: true,
                      defaultExpandAll: true,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: SemiTree(
                      key: ValueKey('tree-filter-only'),
                      treeData: _directoryData,
                      filterTreeNode: true,
                      showFilteredOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('异步加载 / 空态', [
            _demo(
              'loadData — 未加载节点展开时该行显示 Spin；加载完成回填 children + '
              'onLoad(loadedKeys, node)',
              SizedBox(height: 220, child: _LazyTreeDemo(onEvent: _push)),
            ),
            _demo(
              'treeData: [] — 空态（localized「暂无数据」/ 自定义 emptyContent）',
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: SemiTree(key: ValueKey('tree-empty')),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: SemiTree(
                        key: ValueKey('tree-empty-custom'),
                        emptyContent: '没有数据',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('虚拟化 / 自定义渲染', [
            _demo(
              'virtualize: itemSize 30 + height 240 — ListView.builder（react-window '
              '替代）；labelEllipsis 缺省跟随 virtualize',
              SizedBox(
                height: 240,
                child: SemiTree(
                  key: const ValueKey('tree-virtual'),
                  treeData: _virtualData(200),
                  virtualize: const SemiTreeVirtualize(itemSize: 30),
                  onSelect: (key, selected, node) => _push('onSelect $key'),
                ),
              ),
            ),
            _demo(
              'renderLabel + tree icon 构建器 — 标题/图标完全自定义（高亮不注入）',
              SizedBox(
                height: 200,
                child: SemiTree(
                  key: const ValueKey('tree-custom-render'),
                  treeData: _basicData,
                  defaultExpandedKeys: const ['parent'],
                  icon: (node) => const SemiIcon(SemiIcons.component),
                  renderLabel: (label, node, word) =>
                      SemiText('· ${label?.toString() ?? ''}'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('受控与 RTL', [
            _demo(
              'expandedKeys 受控（点击箭头/条目只发 onExpand，handler 回写 props '
              '才展开；「切换展开」按钮亦可直接改 props）/ value 受控（点击只发 '
              'onChange，选中跟随 props）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SemiButton(
                        '切换展开',
                        onPressed: () => setState(
                          () =>
                              _controlledExpanded = _controlledExpanded.isEmpty
                              ? const ['c1']
                              : const [],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '选中受控子二',
                        onPressed: () =>
                            setState(() => _controlledValue = 'c1-2'),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '选中受控子一',
                        onPressed: () =>
                            setState(() => _controlledValue = 'c1-1'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: SemiTree(
                      key: const ValueKey('tree-controlled'),
                      treeData: _controlledData,
                      expandedKeys: _controlledExpanded,
                      value: _controlledValue,
                      // 整行点击即可展开/收起（受控——展开与否由下面 handler 回写）。
                      expandAction: SemiTreeExpandAction.click,
                      onChange: (value) => _push('onChange $value'),
                      onExpand: (keys, expanded, node) {
                        _push('onExpand ${node.key}/$expanded');
                        setState(() => _controlledExpanded = keys);
                      },
                    ),
                  ),
                ],
              ),
            ),
            _demo(
              'Directionality.rtl — 缩进/边距镜像、收起三角 rotate 90、引导线镜像；'
              'expandAction: click（点条目/箭头皆可展开收起）',
              const SizedBox(
                height: 220,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SemiTree(
                    key: ValueKey('tree-rtl'),
                    treeData: _directoryData,
                    directory: true,
                    showLine: true,
                    expandAction: SemiTreeExpandAction.click,
                    defaultExpandedKeys: ['docs', 'docs-spec'],
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

/// loadData 演示：加载完成后把 children 回填到树数据（模拟上游受控 loadData）。
class _LazyTreeDemo extends StatefulWidget {
  const _LazyTreeDemo({required this.onEvent});

  final ValueChanged<String> onEvent;

  @override
  State<_LazyTreeDemo> createState() => _LazyTreeDemoState();
}

class _LazyTreeDemoState extends State<_LazyTreeDemo> {
  List<SemiTreeNodeData> _data = const [
    SemiTreeNodeData(key: 'remote', label: '远程节点'),
    SemiTreeNodeData(key: 'local', label: '本地叶子', isLeaf: true),
  ];

  Future<void> _load(SemiTreeNodeData node) async {
    widget.onEvent('loadData ${node.key} 开始');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    setState(() {
      _data = [
        SemiTreeNodeData(
          key: node.key,
          label: node.label,
          children: const [
            SemiTreeNodeData(key: 'remote-1', label: '加载子一', isLeaf: true),
            SemiTreeNodeData(key: 'remote-2', label: '加载子二', isLeaf: true),
          ],
        ),
        _data.last,
      ];
    });
    widget.onEvent('loadData ${node.key} 完成');
  }

  @override
  Widget build(BuildContext context) {
    return SemiTree(
      key: const ValueKey('tree-lazy'),
      treeData: _data,
      loadData: _load,
      onLoad: (loadedKeys, node) =>
          widget.onEvent('onLoad ${loadedKeys.join(',')}'),
      onChange: (value) => widget.onEvent('onChange $value'),
    );
  }
}
