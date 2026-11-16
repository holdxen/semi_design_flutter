import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  final List<String> _events = [];
  String _status = '点击页签 / 关闭页签，事件写入此行。';

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  static const List<SemiTabData> _lineTabs = [
    SemiTabData(itemKey: '1', tab: '文档', content: Text('文档内容：线形态页签的基础信息。')),
    SemiTabData(itemKey: '2', tab: '快速入门', content: Text('快速入门内容：安装与初始化。')),
    SemiTabData(
      itemKey: '3',
      tab: '禁用',
      disabled: true,
      content: Text('禁用页签内容。'),
    ),
  ];

  static const List<SemiTabData> _closableTabs = [
    SemiTabData(
      itemKey: 'a',
      tab: '可关闭 A',
      closable: true,
      content: Text('A 的内容'),
    ),
    SemiTabData(
      itemKey: 'b',
      tab: '可关闭 B',
      closable: true,
      icon: SemiIcon(SemiIcons.tick, customSize: 14),
      content: Text('B 的内容'),
    ),
    SemiTabData(itemKey: 'c', tab: '普通 C', content: Text('C 的内容')),
  ];

  static List<SemiTabData> _manyTabs(String prefix) => [
    for (var i = 1; i <= 8; i++)
      SemiTabData(
        itemKey: '$prefix-$i',
        tab: '$prefix $i',
        content: Text('$prefix 内容 $i'),
      ),
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
      const SizedBox(height: 16),
    ],
  );

  Widget _panel({required Widget child}) => SizedBox(
    width: 640,
    child: DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF7F8FA)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('tabs-status')),
          const SizedBox(height: 24),
          _section('线条（line）', [
            _demo(
              '默认大尺寸 + 禁用页签',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-line'),
                  tabList: _lineTabs,
                  onChange: (key) => _push('line onChange=$key'),
                  onTabClick: (key) => _push('line onTabClick=$key'),
                ),
              ),
            ),
            _demo(
              '三种尺寸（large / medium / small）',
              _panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final size in SemiTabsSize.values) ...[
                      SemiText(size.name, style: const TextStyle(fontSize: 12)),
                      SemiTabs(
                        tabList: _closableTabs,
                        size: size,
                        tabPaneMotion: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _demo(
              '可关闭 + 图标',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-closable'),
                  tabList: _closableTabs,
                  tabPaneMotion: false,
                  onTabClose: (key) => _push('line onTabClose=$key'),
                ),
              ),
            ),
            _demo(
              '右侧附加内容',
              _panel(
                child: SemiTabs(
                  tabList: _lineTabs,
                  tabBarExtraContent: const SemiButton('操作'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('卡片（card）', [
            _demo(
              'top',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-card-top'),
                  tabList: _lineTabs,
                  type: SemiTabsType.card,
                  tabPaneMotion: false,
                ),
              ),
            ),
            _demo(
              'left',
              _panel(
                child: SizedBox(
                  height: 160,
                  child: SemiTabs(
                    key: const ValueKey('tabs-card-left'),
                    tabList: _lineTabs,
                    type: SemiTabsType.card,
                    tabPosition: SemiTabsPosition.left,
                    tabPaneMotion: false,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('按钮（button）', [
            _demo(
              'top',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-button'),
                  tabList: _lineTabs,
                  type: SemiTabsType.button,
                  tabPaneMotion: false,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('斜线（slash）', [
            _demo(
              '顶部分隔斜线',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-slash'),
                  tabList: _lineTabs,
                  type: SemiTabsType.slash,
                  tabPaneMotion: false,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('滚动折叠（collapsible）', [
            _demo(
              '横向滚动 + 两端箭头',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-collapsible'),
                  tabList: _manyTabs('滚动'),
                  collapsible: true,
                  tabPaneMotion: false,
                  onChange: (key) => _push('collapsible onChange=$key'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('更多下拉（more）', [
            _demo(
              '保留前 2 项，其余收进「更多」',
              _panel(
                child: SemiTabs(
                  key: const ValueKey('tabs-more'),
                  tabList: _manyTabs('更多'),
                  more: 6,
                  tabPaneMotion: false,
                  onChange: (key) => _push('more onChange=$key'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('RTL 与动效', [
            _demo(
              'RTL（顺序镜像）+ 切换动效',
              _panel(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SemiTabs(
                    key: const ValueKey('tabs-rtl'),
                    tabList: _lineTabs,
                    onChange: (key) => _push('rtl onChange=$key'),
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
