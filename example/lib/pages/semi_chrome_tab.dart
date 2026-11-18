import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Flutter port of the qn-chrome-tabs official demo.
///
/// The page stays deliberately controlled: [SemiChromeTab] only reports user
/// actions, while tabs, groups, the active ids, and reorder results live here.
class SemiChromeTabPage extends StatefulWidget {
  const SemiChromeTabPage({super.key});

  @override
  State<SemiChromeTabPage> createState() => _SemiChromeTabPageState();
}

class _SemiChromeTabPageState extends State<SemiChromeTabPage> {
  SemiChromeTabLocale _locale = SemiChromeTabLocale.zh;
  SemiChromeTabLayoutAnimation _layoutAnimation =
      SemiChromeTabLayoutAnimation.chromium;
  SemiChromeTabThemeData _theme = _presets.first.data;
  String _selectedPreset = _presets.first.name;
  String _activeGroupId = 'work';
  int _nextTabId = 1;
  int _nextGroupId = 1;
  int _nextOverflowTabId = 100;
  String _status = '点击标签、双击改名、拖拽排序；右键打开批量关闭菜单。';
  final List<String> _events = <String>[];

  final List<SemiChromeTabGroup> _groups = <SemiChromeTabGroup>[
    const SemiChromeTabGroup(id: 'work', name: 'Work'),
    const SemiChromeTabGroup(id: 'study', name: 'Study'),
  ];

  final Map<String, List<SemiChromeTabItem>> _tabsByGroup =
      <String, List<SemiChromeTabItem>>{
        'work': <SemiChromeTabItem>[
          const SemiChromeTabItem(
            id: 'home',
            title: '首页',
            icon: SemiIcon(SemiIcons.homeStroked),
          ),
          const SemiChromeTabItem(
            id: 'orders',
            title: '订单中心',
            icon: SemiIcon(SemiIcons.shoppingBagStroked),
          ),
          const SemiChromeTabItem(
            id: 'customers',
            title: '客户管理',
            icon: SemiIcon(SemiIcons.userGroup),
            backgroundColor: Color(0xffeef6ff),
          ),
          const SemiChromeTabItem(
            id: 'reports',
            title: '数据报表',
            icon: SemiIcon(SemiIcons.barChartHStroked),
          ),
          const SemiChromeTabItem(
            id: 'settings',
            title: '系统设置',
            icon: SemiIcon(SemiIcons.settingStroked),
          ),
        ],
        'study': <SemiChromeTabItem>[
          const SemiChromeTabItem(
            id: 'docs',
            title: '组件文档',
            icon: SemiIcon(SemiIcons.bookStroked),
          ),
          const SemiChromeTabItem(
            id: 'notes',
            title: '学习笔记',
            icon: SemiIcon(SemiIcons.editStroked),
          ),
        ],
      };

  final Map<String, String?> _activeByGroup = <String, String?>{
    'work': 'home',
    'study': 'docs',
  };

  final List<SemiChromeTabItem> _overflowTabs = <SemiChromeTabItem>[
    for (var i = 0; i < 10; i++)
      SemiChromeTabItem(id: 'overflow-$i', title: '工作区 ${i + 1}'),
  ];
  String? _overflowActive = 'overflow-0';

  List<SemiChromeTabItem> get _visibleTabs =>
      _tabsByGroup[_activeGroupId] ?? const <SemiChromeTabItem>[];

  String? get _activeTabId => _activeByGroup[_activeGroupId];

  void _log(String event) {
    setState(() {
      _status = event;
      _events.insert(0, event);
      if (_events.length > 8) _events.removeLast();
    });
  }

  List<SemiChromeTabItem> _tabsOf(String groupId) =>
      _tabsByGroup.putIfAbsent(groupId, () => <SemiChromeTabItem>[]);

  void _activate(String id) {
    setState(() => _activeByGroup[_activeGroupId] = id);
    _log('tab-activate → $id');
  }

  void _editAddress(String id) {
    final tabs = _tabsOf(_activeGroupId);
    final index = tabs.indexWhere((tab) => tab.id == id);
    if (index < 0) return;
    final tab = tabs[index];
    final title = tab.title.endsWith(' ✎')
        ? tab.title.substring(0, tab.title.length - 2)
        : '${tab.title} ✎';
    setState(() {
      tabs[index] = SemiChromeTabItem(
        id: tab.id,
        title: title,
        icon: tab.icon,
        backgroundColor: tab.backgroundColor,
      );
    });
    _log('tab-edit-address → $id（演示内直接改名）');
  }

  void _closeTab(String id) {
    final tabs = _tabsOf(_activeGroupId);
    setState(() {
      tabs.removeWhere((tab) => tab.id == id);
      if (_activeByGroup[_activeGroupId] == id) {
        _activeByGroup[_activeGroupId] = tabs.isEmpty ? null : tabs.first.id;
      }
    });
    _log('tab-close → $id');
  }

  void _addTab() {
    final tabs = _tabsOf(_activeGroupId);
    final id = 'tab-${_nextTabId++}';
    setState(() {
      tabs.add(
        SemiChromeTabItem(
          id: id,
          title: '新标签 $id',
          icon: const SemiIcon(SemiIcons.file),
        ),
      );
      _activeByGroup[_activeGroupId] = id;
    });
    _log('tab-add → $id');
  }

  void _reorder(SemiChromeTabReorderInfo info) {
    final tabs = _tabsOf(_activeGroupId);
    final from = tabs.indexWhere((tab) => tab.id == info.tabId);
    var target = tabs.indexWhere((tab) => tab.id == info.targetTabId);
    if (from < 0 || target < 0 || from == target) return;
    setState(() {
      final item = tabs.removeAt(from);
      if (from < target) target -= 1;
      final insert = info.position == SemiChromeTabReorderPosition.before
          ? target
          : target + 1;
      tabs.insert(insert.clamp(0, tabs.length), item);
    });
    _log(
      'tab-reorder → ${info.tabId} ${info.position.name} ${info.targetTabId}',
    );
  }

  void _closeBatch(String tabId, String action) {
    final tabs = _tabsOf(_activeGroupId);
    final target = tabs.indexWhere((tab) => tab.id == tabId);
    if (target < 0) return;
    setState(() {
      switch (action) {
        case 'left':
          tabs.removeRange(0, target);
          break;
        case 'right':
          tabs.removeRange(target + 1, tabs.length);
          break;
        case 'others':
          final keep = tabs[target];
          tabs
            ..clear()
            ..add(keep);
          break;
        case 'close':
          tabs.removeAt(target);
          break;
      }
      if (!tabs.any((tab) => tab.id == _activeByGroup[_activeGroupId])) {
        _activeByGroup[_activeGroupId] = tabs.isEmpty ? null : tabs.first.id;
      }
    });
    _log('tab-close-$action → $tabId');
  }

  void _switchGroup(String id) {
    setState(() => _activeGroupId = id);
    _log('group-switch → $id');
  }

  void _addGroup() {
    final id = 'group-${_nextGroupId++}';
    setState(() {
      _groups.add(SemiChromeTabGroup(id: id, name: '分组 $id'));
      _tabsByGroup[id] = <SemiChromeTabItem>[];
      _activeByGroup[id] = null;
      _activeGroupId = id;
    });
    _log('group-add → $id');
  }

  void _renameGroup(String id) {
    final index = _groups.indexWhere((group) => group.id == id);
    if (index < 0) return;
    final group = _groups[index];
    final name = group.name.endsWith(' ✎')
        ? group.name.substring(0, group.name.length - 2)
        : '${group.name} ✎';
    setState(() => _groups[index] = SemiChromeTabGroup(id: id, name: name));
    _log('group-rename → $id');
  }

  void _deleteGroup(String id) {
    if (_groups.length <= 1) {
      _log('group-delete 被忽略（至少保留一个分组）');
      return;
    }
    setState(() {
      _groups.removeWhere((group) => group.id == id);
      _tabsByGroup.remove(id);
      _activeByGroup.remove(id);
      if (_activeGroupId == id) _activeGroupId = _groups.first.id;
    });
    _log('group-delete → $id');
  }

  void _setTheme(SemiChromeTabThemeData data, String preset) {
    setState(() {
      _theme = data;
      _selectedPreset = preset;
    });
  }

  static const List<_ChromePreset> _presets = <_ChromePreset>[
    _ChromePreset('Chrome 默认', SemiChromeTabThemeData()),
    _ChromePreset(
      'Sea Salt Blue',
      SemiChromeTabThemeData(
        chromeTabsHeight: 44,
        chromeTabMinWidth: 58,
        chromeTabMaxWidth: 148,
        chromeTabRadius: 10,
        chromeTabsBackground: Color(0xffdbeafe),
        chromeTabTextColor: Color(0xff475569),
        chromeTabActiveTextColor: Color(0xff0f172a),
        chromeTabHoverBackground: Color(0xffbfdbfe),
        chromeTabActiveBackground: Color(0xffffffff),
        chromeTabDividerColor: Color(0xff93c5fd),
        chromeTabCloseHoverBackground: Color(0xffbfdbfe),
        chromeTabsAccentColor: Color(0xff2563eb),
        chromeTabsMenuBorderColor: Color(0xffbfdbfe),
        chromeTabsMenuHoverBackground: Color(0xffeff6ff),
        chromeTabsMenuTextColor: Color(0xff334155),
        chromeTabsMenuIconColor: Color(0xff2563eb),
        chromeTabsMenuIconBackground: Color(0xffeff6ff),
      ),
    ),
    _ChromePreset(
      'Midnight Purple',
      SemiChromeTabThemeData(
        chromeTabsHeight: 42,
        chromeTabRadius: 9,
        chromeTabsBackground: Color(0xff1f1b2e),
        chromeTabTextColor: Color(0xffa79bd0),
        chromeTabActiveTextColor: Color(0xfff5f3ff),
        chromeTabHoverBackground: Color(0xff352c52),
        chromeTabActiveBackground: Color(0xff4c3a7a),
        chromeTabDividerColor: Color(0x557c6aa8),
        chromeTabCloseHoverBackground: Color(0xff5b488d),
        chromeTabsAccentColor: Color(0xffa78bfa),
        chromeTabsMenuBackground: Color(0xff241e3a),
        chromeTabsMenuBorderColor: Color(0xff443768),
        chromeTabsMenuHoverBackground: Color(0xff352c52),
        chromeTabsMenuTextColor: Color(0xffe9e3ff),
        chromeTabsMenuIconColor: Color(0xffc4b5fd),
        chromeTabsMenuIconBackground: Color(0xff352c52),
        chromeTabsTooltipBackground: Color(0xff241e3a),
        chromeTabsTooltipBorderColor: Color(0xff443768),
        chromeTabsTooltipTextColor: Color(0xfff5f3ff),
      ),
    ),
    _ChromePreset(
      'Cherry Mist',
      SemiChromeTabThemeData(
        chromeTabsHeight: 40,
        chromeTabRadius: 12,
        chromeTabsBackground: Color(0xfffde7ef),
        chromeTabTextColor: Color(0xff9d5b74),
        chromeTabActiveTextColor: Color(0xff4a1d2b),
        chromeTabHoverBackground: Color(0xfffbcfdf),
        chromeTabActiveBackground: Color(0xffffffff),
        chromeTabDividerColor: Color(0x66e7a3bb),
        chromeTabCloseHoverBackground: Color(0xfff8bcd0),
        chromeTabsAccentColor: Color(0xffdb2777),
        chromeTabsMenuBorderColor: Color(0xfff8bcd0),
        chromeTabsMenuHoverBackground: Color(0xfffff1f5),
        chromeTabsMenuTextColor: Color(0xff6b2337),
        chromeTabsMenuIconColor: Color(0xffdb2777),
      ),
    ),
    _ChromePreset(
      'Forest Green',
      SemiChromeTabThemeData(
        chromeTabsHeight: 42,
        chromeTabRadius: 10,
        chromeTabsBackground: Color(0xffe3efe6),
        chromeTabTextColor: Color(0xff4f6b58),
        chromeTabActiveTextColor: Color(0xff13281a),
        chromeTabHoverBackground: Color(0xffc7e0cf),
        chromeTabActiveBackground: Color(0xffffffff),
        chromeTabDividerColor: Color(0x6686b495),
        chromeTabCloseHoverBackground: Color(0xffbcd9c5),
        chromeTabsAccentColor: Color(0xff15803d),
        chromeTabsMenuBorderColor: Color(0xffbcd9c5),
        chromeTabsMenuHoverBackground: Color(0xfff0f8f2),
        chromeTabsMenuTextColor: Color(0xff274435),
        chromeTabsMenuIconColor: Color(0xff15803d),
      ),
    ),
    _ChromePreset(
      'Mono Square',
      SemiChromeTabThemeData(
        chromeTabsHeight: 38,
        chromeTabRadius: 2,
        chromeTabMinWidth: 64,
        chromeTabMaxWidth: 132,
        chromeTabsBackground: Color(0xfff2f2f2),
        chromeTabTextColor: Color(0xff666666),
        chromeTabActiveTextColor: Color(0xff111111),
        chromeTabHoverBackground: Color(0xffe4e4e4),
        chromeTabActiveBackground: Color(0xffffffff),
        chromeTabDividerColor: Color(0x33000000),
        chromeTabCloseHoverBackground: Color(0xffd4d4d4),
        chromeTabsAccentColor: Color(0xff111111),
        chromeTabsMenuBorderColor: Color(0xffd4d4d4),
        chromeTabsMenuHoverBackground: Color(0xfff2f2f2),
        chromeTabsMenuTextColor: Color(0xff111111),
        chromeTabsMenuIconColor: Color(0xff111111),
      ),
    ),
  ];

  Widget _codeBlock(String source, {Key? key}) => DecoratedBox(
    key: key,
    decoration: BoxDecoration(
      color: const Color(0xff0f172a),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          source,
          style: const TextStyle(
            color: Color(0xffe2e8f0),
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ),
    ),
  );

  Widget _section({
    required Key key,
    required String title,
    required String description,
    required List<Widget> children,
  }) => Column(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SemiTitle(title, heading: 3),
      const SizedBox(height: 4),
      SemiText(description, type: SemiTextType.secondary),
      const SizedBox(height: 12),
      ...children,
    ],
  );

  Widget _buildPreview() {
    final tabs = List<SemiChromeTabItem>.of(_visibleTabs);
    return SizedBox(
      key: const ValueKey('semi-chrome-tab-preview'),
      child: SemiChromeTabTheme(
        data: _theme,
        child: SemiChromeTab(
          tabs: tabs,
          activeTabId: _activeTabId,
          groups: _groups,
          activeGroupId: _activeGroupId,
          locale: _locale,
          layoutAnimation: _layoutAnimation,
          onTabActivate: _activate,
          onTabEditAddress: _editAddress,
          onTabClose: _closeTab,
          onTabAdd: _addTab,
          onTabReorder: _reorder,
          onTabCloseLeft: (id) => _closeBatch(id, 'left'),
          onTabCloseRight: (id) => _closeBatch(id, 'right'),
          onTabCloseOthers: (id) => _closeBatch(id, 'others'),
          onGroupSwitch: _switchGroup,
          onGroupAdd: _addGroup,
          onGroupRename: _renameGroup,
          onGroupDelete: _deleteGroup,
        ),
      ),
    );
  }

  Widget _buildLocalePicker() => Row(
    key: const ValueKey('semi-chrome-tab-locale'),
    children: <Widget>[
      for (final entry in const <(SemiChromeTabLocale, String)>[
        (SemiChromeTabLocale.zh, '中文'),
        (SemiChromeTabLocale.en, 'English'),
        (SemiChromeTabLocale.ko, '한국어'),
      ])
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: SemiButton(
            entry.$2,
            size: SemiButtonSize.small,
            type: _locale == entry.$1
                ? SemiButtonType.primary
                : SemiButtonType.tertiary,
            variant: _locale == entry.$1
                ? SemiButtonVariant.light
                : SemiButtonVariant.borderless,
            onPressed: () => setState(() => _locale = entry.$1),
          ),
        ),
    ],
  );

  Widget _buildPresets() => Wrap(
    key: const ValueKey('semi-chrome-tab-theme-presets'),
    spacing: 8,
    runSpacing: 8,
    children: <Widget>[
      for (final preset in _presets)
        SemiButton(
          preset.name,
          size: SemiButtonSize.small,
          type: _selectedPreset == preset.name
              ? SemiButtonType.primary
              : SemiButtonType.tertiary,
          variant: _selectedPreset == preset.name
              ? SemiButtonVariant.light
              : SemiButtonVariant.outline,
          onPressed: () => _setTheme(preset.data, preset.name),
        ),
    ],
  );

  Widget _buildThemeEditor() => Column(
    key: const ValueKey('semi-chrome-tab-theme-editor'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Wrap(
        key: const ValueKey('semi-chrome-tab-layout-animation'),
        spacing: 8,
        children: <Widget>[
          SemiButton(
            'Chromium bounds',
            size: SemiButtonSize.small,
            type: _layoutAnimation == SemiChromeTabLayoutAnimation.chromium
                ? SemiButtonType.primary
                : SemiButtonType.tertiary,
            onPressed: () => setState(
              () => _layoutAnimation = SemiChromeTabLayoutAnimation.chromium,
            ),
          ),
          SemiButton(
            'Immediate',
            size: SemiButtonSize.small,
            type: _layoutAnimation == SemiChromeTabLayoutAnimation.immediate
                ? SemiButtonType.primary
                : SemiButtonType.tertiary,
            onPressed: () => setState(
              () => _layoutAnimation = SemiChromeTabLayoutAnimation.immediate,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      _slider(
        '标签栏高度 ${(_theme.chromeTabsHeight ?? 38).round()}px',
        value: _theme.chromeTabsHeight ?? 38,
        min: 32,
        max: 56,
        step: 2,
        onChanged: (value) => setState(
          () => _theme = _theme.copyWith(chromeTabsHeight: value as double),
        ),
      ),
      _slider(
        '标签最小宽度 ${(_theme.chromeTabMinWidth ?? 52).round()}px',
        value: _theme.chromeTabMinWidth ?? 52,
        min: 40,
        max: 120,
        step: 2,
        onChanged: (value) => setState(
          () => _theme = _theme.copyWith(chromeTabMinWidth: value as double),
        ),
      ),
      _slider(
        '标签最大宽度 ${(_theme.chromeTabMaxWidth ?? 120).round()}px',
        value: _theme.chromeTabMaxWidth ?? 120,
        min: 100,
        max: 240,
        step: 4,
        onChanged: (value) => setState(
          () => _theme = _theme.copyWith(chromeTabMaxWidth: value as double),
        ),
      ),
      _slider(
        '标签圆角 ${(_theme.chromeTabRadius ?? 8).round()}px',
        value: _theme.chromeTabRadius ?? 8,
        min: 0,
        max: 16,
        step: 1,
        onChanged: (value) => setState(
          () => _theme = _theme.copyWith(chromeTabRadius: value as double),
        ),
      ),
      _slider(
        'Layout duration ${_theme.chromeTabLayoutDuration?.inMilliseconds ?? 200}ms',
        value: _theme.chromeTabLayoutDuration?.inMilliseconds.toDouble() ?? 200,
        min: 80,
        max: 300,
        step: 10,
        onChanged: (value) => setState(
          () => _theme = _theme.copyWith(
            chromeTabLayoutDuration: Duration(
              milliseconds: (value as double).round(),
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SemiButton(
        '恢复默认',
        size: SemiButtonSize.small,
        type: SemiButtonType.tertiary,
        variant: SemiButtonVariant.borderless,
        onPressed: () => _setTheme(_presets.first.data, _presets.first.name),
      ),
    ],
  );

  Widget _slider(
    String label, {
    required double value,
    required double min,
    required double max,
    required double step,
    required ValueChanged<Object?> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SemiText(label, type: SemiTextType.secondary),
        SizedBox(
          width: 360,
          child: SemiSlider(
            value: value,
            min: min,
            max: max,
            step: step,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );

  Widget _buildOverflowDemo() {
    final tabs = List<SemiChromeTabItem>.of(_overflowTabs);
    return Column(
      key: const ValueKey('semi-chrome-tab-overflow'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SemiText(
          '容器收窄到 420px：标签收缩到最小宽度后出现左右滚动按钮；'
          '悬停按钮会列出该侧被裁掉的标签。',
          type: SemiTextType.secondary,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 420,
          child: SemiChromeTab(
            tabs: tabs,
            activeTabId: _overflowActive,
            locale: _locale,
            hideGroupButton: true,
            hideScrollbar: true,
            layoutAnimation: SemiChromeTabLayoutAnimation.immediate,
            onTabActivate: (id) => setState(() => _overflowActive = id),
            onTabAdd: () {
              setState(() {
                final id = 'overflow-${_nextOverflowTabId++}';
                _overflowTabs.add(SemiChromeTabItem(id: id, title: '工作区 $id'));
                _overflowActive = id;
              });
              _log('overflow tab-add');
            },
            onTabClose: (id) => setState(() {
              _overflowTabs.removeWhere((tab) => tab.id == id);
              if (_overflowActive == id) {
                _overflowActive = _overflowTabs.isEmpty
                    ? null
                    : _overflowTabs.first.id;
              }
            }),
            onTabReorder: (info) {
              final from = _overflowTabs.indexWhere(
                (tab) => tab.id == info.tabId,
              );
              var target = _overflowTabs.indexWhere(
                (tab) => tab.id == info.targetTabId,
              );
              if (from < 0 || target < 0 || from == target) return;
              setState(() {
                final item = _overflowTabs.removeAt(from);
                if (from < target) target -= 1;
                _overflowTabs.insert(
                  info.position == SemiChromeTabReorderPosition.before
                      ? target
                      : target + 1,
                  item,
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTooltipDemo() => Column(
    key: const ValueKey('semi-chrome-tab-tooltip'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const SemiText(
        'truncated 模式只在标题被省略时显示；always 始终显示；'
        'renderTabTooltip 可以替换气泡内容。',
        type: SemiTextType.secondary,
      ),
      const SizedBox(height: 8),
      SemiChromeTab(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(id: 'long', title: '一个非常非常长的标签标题，用来触发省略号和 tooltip'),
          SemiChromeTabItem(id: 'short', title: '短标题'),
        ],
        activeTabId: 'long',
        locale: _locale,
        hideAddButton: true,
        hideGroupButton: true,
        renderTabTooltip: (tab) => Text('自定义提示：${tab.title}'),
      ),
    ],
  );

  Widget _buildIconDemo() => Column(
    key: const ValueKey('semi-chrome-tab-icon-demo'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const SemiText(
        '标签图标是任意 Widget：SemiIcon、Image 或 renderTabIcon 返回值。',
        type: SemiTextType.secondary,
      ),
      const SizedBox(height: 8),
      SemiChromeTab(
        tabs: const <SemiChromeTabItem>[
          SemiChromeTabItem(
            id: 'icon-home',
            title: 'SemiIcon',
            icon: SemiIcon(SemiIcons.homeStroked),
          ),
          SemiChromeTabItem(
            id: 'icon-image',
            title: 'Image icon',
            icon: SemiIcon(SemiIcons.imageStroked),
          ),
          SemiChromeTabItem(id: 'icon-custom', title: 'renderTabIcon'),
        ],
        activeTabId: 'icon-home',
        locale: _locale,
        hideAddButton: true,
        hideGroupButton: true,
        renderTabIcon: (tab) => tab.id == 'icon-custom'
            ? const SemiIcon(
                SemiIcons.checkCircleStroked,
                color: Color(0xff059669),
              )
            : null,
      ),
    ],
  );

  String get _stateJson =>
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'activeGroupId': _activeGroupId,
        'activeTabId': _activeTabId,
        'groups': <Object?>[
          for (final group in _groups)
            <String, Object?>{'id': group.id, 'name': group.name},
        ],
        'tabs': <Object?>[
          for (final tab in _visibleTabs)
            <String, Object?>{'id': tab.id, 'title': tab.title},
        ],
        'locale': _locale.name,
      });

  Widget _buildEventLog() => Column(
    key: const ValueKey('semi-chrome-tab-event-log'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (_events.isEmpty)
        const SemiText('暂无事件。', type: SemiTextType.tertiary)
      else
        for (final event in _events)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: SemiText(
              event,
              size: SemiTextSize.small,
              type: SemiTextType.secondary,
            ),
          ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SemiTitle('SemiChromeTab', heading: 2),
          const SizedBox(height: 4),
          const SemiText(
            'qn-chrome-tabs 的 Flutter 移植：受控标签、Chrome 缺口几何、'
            '拖拽排序、右键批量关闭、分组菜单、溢出悬浮列表和 tooltip。',
          ),
          const SizedBox(height: 12),
          _buildLocalePicker(),
          const SizedBox(height: 16),
          _section(
            key: const ValueKey('semi-chrome-tab-preview-section'),
            title: '受控预览',
            description: '所有状态由本页保存；组件只回调操作，不修改输入列表。',
            children: <Widget>[
              _buildPreview(),
              const SizedBox(height: 10),
              SemiText(_status, key: const ValueKey('semi-chrome-tab-status')),
            ],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-theme-presets-section'),
            title: '主题预设',
            description: 'CSS 变量一一映射为 SemiChromeTabThemeData 字段。',
            children: <Widget>[_buildPresets()],
          ),
          const SizedBox(height: 16),
          _section(
            key: const ValueKey('semi-chrome-tab-theme-editor-section'),
            title: '主题微调',
            description: '调整高度、宽度和圆角，预览立即更新。',
            children: <Widget>[_buildThemeEditor()],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-overflow-section'),
            title: '溢出导航',
            description: '左右滚动按钮 + 隐藏标签悬浮列表 + 滚轮横向滚动。',
            children: <Widget>[_buildOverflowDemo()],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-tooltip-section'),
            title: 'Tooltip',
            description: '标题截断检测与自定义气泡内容。',
            children: <Widget>[_buildTooltipDemo()],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-icon-section'),
            title: '标签图标',
            description: '图标由调用方提供；组件不请求 favicon URL。',
            children: <Widget>[_buildIconDemo()],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-state-json-section'),
            title: '当前状态',
            description: '页面保存的受控数据。',
            children: <Widget>[
              _codeBlock(
                _stateJson,
                key: const ValueKey('semi-chrome-tab-state-json'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-event-log-section'),
            title: '事件日志',
            description: '最近 8 条回调。',
            children: <Widget>[_buildEventLog()],
          ),
          const SizedBox(height: 24),
          _section(
            key: const ValueKey('semi-chrome-tab-quick-start-section'),
            title: '快速上手',
            description: '受控写法：事件里更新外部状态。',
            children: <Widget>[
              _codeBlock(
                "final tabs = <SemiChromeTabItem>[\n"
                "  const SemiChromeTabItem(id: 'home', title: '首页'),\n"
                "  const SemiChromeTabItem(id: 'docs', title: '文档'),\n"
                "];\n\n"
                'SemiChromeTab(\n'
                '  tabs: tabs,\n'
                "  activeTabId: activeTabId,\n"
                '  onTabActivate: (id) => setState(() => activeTabId = id),\n'
                '  onTabClose: (id) => setState(() =>\n'
                '    tabs.removeWhere((tab) => tab.id == id)),\n'
                ');',
                key: const ValueKey('semi-chrome-tab-quick-start'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChromePreset {
  const _ChromePreset(this.name, this.data);

  final String name;
  final SemiChromeTabThemeData data;
}
