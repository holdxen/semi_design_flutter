import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ChromeTabPage extends StatefulWidget {
  const ChromeTabPage({super.key});

  @override
  State<ChromeTabPage> createState() => _ChromeTabPageState();
}

class _ChromeTabPageState extends State<ChromeTabPage> {
  ChromeTabLocale _locale = ChromeTabLocale.zh;
  String _active = 'home';
  String _group = 'work';
  int _nextId = 1;
  final List<String> _events = [];
  final List<ChromeTabGroup> _groups = const [
    ChromeTabGroup(id: 'work', name: '工作'),
    ChromeTabGroup(id: 'personal', name: '个人'),
  ];
  late List<ChromeTabItem> _tabs = _initialTabs;

  static const List<ChromeTabItem> _initialTabs = [
    ChromeTabItem(id: 'home', title: '首页', closable: false),
    ChromeTabItem(
      id: 'docs',
      title: '组件文档',
      icon: SemiIcon(SemiIcons.bookStroked),
    ),
    ChromeTabItem(id: 'settings', title: '设置与偏好'),
    ChromeTabItem(id: 'long', title: '一个比较长的标签标题示例'),
    ChromeTabItem(id: 'disabled', title: '暂不可用', disabled: true),
  ];

  void _push(String message) {
    setState(() {
      _events.add(message);
      if (_events.length > 4) _events.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SemiTitle('ChromeTab', heading: 2),
          const SizedBox(height: 8),
          const SemiText('Chrome 风格工作区标签栏：状态由外部控制，支持分组、拖拽和右键操作。'),
          const SizedBox(height: 16),
          Row(
            children: [
              const SemiText('语言：'),
              for (final locale in ChromeTabLocale.values)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: SemiButton(
                    locale.name,
                    type: _locale == locale
                        ? SemiButtonType.primary
                        : SemiButtonType.tertiary,
                    onClick: () => setState(() => _locale = locale),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xfff5f7fa)),
            child: ChromeTab(
              tabs: _tabs,
              activeTabId: _active,
              groups: _groups,
              activeGroupId: _group,
              locale: _locale,
              onTabActivate: (id) {
                setState(() => _active = id);
                _push('activate: $id');
              },
              onTabEditAddress: (id) => _push('edit: $id'),
              onTabAdd: () {
                final id = 'new-${_nextId++}';
                setState(() {
                  _tabs = [
                    ..._tabs,
                    ChromeTabItem(id: id, title: '新标签 $_nextId'),
                  ];
                  _active = id;
                });
                _push('add: $id');
              },
              onTabClose: (id) {
                setState(() {
                  _tabs = _tabs.where((tab) => tab.id != id).toList();
                  if (_active == id && _tabs.isNotEmpty)
                    _active = _tabs.first.id;
                });
                _push('close: $id');
              },
              onTabReorder: (info) => _push(
                'reorder: ${info.tabId} ${info.position.name} ${info.targetTabId}',
              ),
              onGroupSwitch: (id) {
                setState(() => _group = id);
                _push('group: $id');
              },
              onTabCloseLeft: (id) => _push('close left: $id'),
              onTabCloseRight: (id) => _push('close right: $id'),
              onTabCloseOthers: (id) => _push('close others: $id'),
            ),
          ),
          const SizedBox(height: 16),
          SemiText(
            _events.isEmpty ? '点击或拖拽标签查看事件。' : _events.join('  ·  '),
            key: const ValueKey('chrome-tab-status'),
          ),
          const SizedBox(height: 24),
          const SemiTitle('局部主题', heading: 3),
          const SizedBox(height: 8),
          ChromeTabTheme(
            data: const ChromeTabThemeData(
              stripBackgroundColor: Color(0xff182230),
              tabTextColor: Color(0xff98a2b3),
              tabActiveTextColor: Color(0xff101828),
              tabActiveBackgroundColor: Color(0xfff9fafb),
              tabHoverBackgroundColor: Color(0xff344054),
              accentColor: Color(0xff7f56d9),
            ),
            child: ChromeTab(
              tabs: _tabs.take(3).toList(growable: false),
              activeTabId: _active,
              hideAddButton: true,
              hideGroupButton: true,
              locale: _locale,
            ),
          ),
        ],
      ),
    );
  }
}
