import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Flutter 化的 qn-chrome-tabs 官方 demo。
///
/// 页面刻意保持“受控组件”写法：ChromeTab 只报告操作，所有标签、分组、
/// 活动项和排序结果都在这个页面里落地，方便把示例直接复制到业务代码中。
class ChromeTabPage extends StatefulWidget {
  const ChromeTabPage({super.key});

  @override
  State<ChromeTabPage> createState() => _ChromeTabPageState();
}

class _ChromeTabPageState extends State<ChromeTabPage> {
  ChromeTabLocale _locale = ChromeTabLocale.zh;
  String _activeGroupId = 'work';
  int _nextTabId = 1;
  int _nextGroupId = 1;
  int _renameCount = 1;
  bool _darkPreview = false;
  String _selectedPreset = 'Sea Salt Blue';
  String _scriptCode =
      "tabsElement.activeGroupId = 'work';\ntabsElement.activeTabId = 'customers';";
  ChromeTabThemeData _theme = _presets.first.data;
  final List<String> _events = <String>[];

  List<ChromeTabGroup> _groups = <ChromeTabGroup>[
    const ChromeTabGroup(id: 'work', name: 'Work'),
    const ChromeTabGroup(id: 'study', name: 'Study'),
  ];

  final Map<String, List<ChromeTabItem>> _tabsByGroup =
      <String, List<ChromeTabItem>>{
        'work': <ChromeTabItem>[
          const ChromeTabItem(
            id: 'home',
            title: '首页',
            icon: SemiIcon(SemiIcons.homeStroked),
            closable: false,
          ),
          const ChromeTabItem(
            id: 'orders',
            title: '订单中心',
            icon: SemiIcon(SemiIcons.shoppingBagStroked),
          ),
          const ChromeTabItem(
            id: 'customers',
            title: '客户管理',
            icon: SemiIcon(SemiIcons.userGroup),
          ),
          const ChromeTabItem(
            id: 'reports',
            title: '数据报表',
            icon: SemiIcon(SemiIcons.barChartHStroked),
          ),
          const ChromeTabItem(
            id: 'settings',
            title: '系统设置',
            icon: SemiIcon(SemiIcons.settingStroked),
          ),
        ],
        'study': <ChromeTabItem>[
          const ChromeTabItem(
            id: 'docs',
            title: '组件文档',
            icon: SemiIcon(SemiIcons.bookStroked),
          ),
          const ChromeTabItem(
            id: 'notes',
            title: '学习笔记',
            icon: SemiIcon(SemiIcons.editStroked),
          ),
        ],
      };

  final Map<String, String?> _activeTabByGroup = <String, String?>{
    'work': 'home',
    'study': 'docs',
  };

  List<ChromeTabItem> get _visibleTabs => List<ChromeTabItem>.of(
    _tabsByGroup[_activeGroupId] ?? const <ChromeTabItem>[],
  );

  String? get _activeTabId => _activeTabByGroup[_activeGroupId];

  ChromeTabGroup? get _activeGroup {
    for (final group in _groups) {
      if (group.id == _activeGroupId) return group;
    }
    return null;
  }

  static const List<_ChromeThemePreset> _presets = <_ChromeThemePreset>[
    _ChromeThemePreset(
      keyName: 'sea-salt-blue',
      name: 'Sea Salt Blue',
      description: 'Clean and bright',
      data: ChromeTabThemeData(
        stripHeight: 44,
        tabMinWidth: 58,
        tabMaxWidth: 148,
        tabRadius: 10,
        stripBackgroundColor: Color(0xffdbeafe),
        tabTextColor: Color(0xff475569),
        tabActiveTextColor: Color(0xff0f172a),
        tabHoverBackgroundColor: Color(0xffbfdbfe),
        tabActiveBackgroundColor: Color(0xffffffff),
        tabDividerColor: Color(0xff93c5fd),
        closeButtonHoverBackgroundColor: Color(0xffbfdbfe),
        accentColor: Color(0xff2563eb),
        menuBackgroundColor: Color(0xffffffff),
        menuBorderColor: Color(0xffbfdbfe),
        menuHoverBackgroundColor: Color(0xffeff6ff),
        menuTextColor: Color(0xff334155),
        menuIconColor: Color(0xff2563eb),
        menuIconBackgroundColor: Color(0xffeff6ff),
      ),
    ),
    _ChromeThemePreset(
      keyName: 'midnight-purple',
      name: 'Midnight Purple',
      description: 'Deep contrast',
      data: ChromeTabThemeData(
        stripHeight: 46,
        tabMinWidth: 64,
        tabMaxWidth: 156,
        tabRadius: 12,
        stripBackgroundColor: Color(0xff182230),
        tabTextColor: Color(0xff98a2b3),
        tabActiveTextColor: Color(0xff101828),
        tabHoverBackgroundColor: Color(0xff344054),
        tabActiveBackgroundColor: Color(0xfff9fafb),
        tabDividerColor: Color(0xff475467),
        closeButtonHoverBackgroundColor: Color(0xffd6bbfb),
        accentColor: Color(0xff7f56d9),
        menuBackgroundColor: Color(0xffffffff),
        menuBorderColor: Color(0xffd0d5dd),
        menuHoverBackgroundColor: Color(0xfff4ebff),
        menuTextColor: Color(0xff344054),
        menuIconColor: Color(0xff7f56d9),
        menuIconBackgroundColor: Color(0xfff4ebff),
      ),
    ),
    _ChromeThemePreset(
      keyName: 'cherry-mist',
      name: 'Cherry Mist',
      description: 'Soft and light',
      data: ChromeTabThemeData(
        stripHeight: 42,
        tabMinWidth: 56,
        tabMaxWidth: 142,
        tabRadius: 14,
        stripBackgroundColor: Color(0xfffce7f3),
        tabTextColor: Color(0xff9d174d),
        tabActiveTextColor: Color(0xff831843),
        tabHoverBackgroundColor: Color(0xfffbcfe8),
        tabActiveBackgroundColor: Color(0xfffff7fb),
        tabDividerColor: Color(0xfff9a8d4),
        closeButtonHoverBackgroundColor: Color(0xfff9a8d4),
        accentColor: Color(0xffdb2777),
        menuBackgroundColor: Color(0xfffff7fb),
        menuBorderColor: Color(0xfffbcfe8),
        menuHoverBackgroundColor: Color(0xfffce7f3),
        menuTextColor: Color(0xff9d174d),
        menuIconColor: Color(0xffdb2777),
        menuIconBackgroundColor: Color(0xfffce7f3),
      ),
    ),
    _ChromeThemePreset(
      keyName: 'forest-green',
      name: 'Forest Green',
      description: 'Calm and natural',
      data: ChromeTabThemeData(
        stripHeight: 44,
        tabMinWidth: 60,
        tabMaxWidth: 150,
        tabRadius: 11,
        stripBackgroundColor: Color(0xffd1fae5),
        tabTextColor: Color(0xff3f6555),
        tabActiveTextColor: Color(0xff064e3b),
        tabHoverBackgroundColor: Color(0xffa7f3d0),
        tabActiveBackgroundColor: Color(0xfff0fdf4),
        tabDividerColor: Color(0xff6ee7b7),
        closeButtonHoverBackgroundColor: Color(0xff6ee7b7),
        accentColor: Color(0xff059669),
        menuBackgroundColor: Color(0xfff0fdf4),
        menuBorderColor: Color(0xffa7f3d0),
        menuHoverBackgroundColor: Color(0xffd1fae5),
        menuTextColor: Color(0xff065f46),
        menuIconColor: Color(0xff059669),
        menuIconBackgroundColor: Color(0xffd1fae5),
      ),
    ),
    _ChromeThemePreset(
      keyName: 'amber-orange',
      name: 'Amber Orange',
      description: 'Warm and vivid',
      data: ChromeTabThemeData(
        stripHeight: 43,
        tabMinWidth: 58,
        tabMaxWidth: 146,
        tabRadius: 9,
        stripBackgroundColor: Color(0xfffef3c7),
        tabTextColor: Color(0xff92400e),
        tabActiveTextColor: Color(0xff78350f),
        tabHoverBackgroundColor: Color(0xfffde68a),
        tabActiveBackgroundColor: Color(0xfffffbeb),
        tabDividerColor: Color(0xfffcd34d),
        closeButtonHoverBackgroundColor: Color(0xfffcd34d),
        accentColor: Color(0xffd97706),
        menuBackgroundColor: Color(0xfffffbeb),
        menuBorderColor: Color(0xfffde68a),
        menuHoverBackgroundColor: Color(0xfffef3c7),
        menuTextColor: Color(0xff92400e),
        menuIconColor: Color(0xffd97706),
        menuIconBackgroundColor: Color(0xfffef3c7),
      ),
    ),
    _ChromeThemePreset(
      keyName: 'mono-square',
      name: 'Mono Square',
      description: 'Minimal and crisp',
      data: ChromeTabThemeData(
        stripHeight: 40,
        tabMinWidth: 56,
        tabMaxWidth: 138,
        tabRadius: 3,
        stripBackgroundColor: Color(0xffe5e7eb),
        tabTextColor: Color(0xff4b5563),
        tabActiveTextColor: Color(0xff111827),
        tabHoverBackgroundColor: Color(0xffd1d5db),
        tabActiveBackgroundColor: Color(0xffffffff),
        tabDividerColor: Color(0xff6b7280),
        closeButtonHoverBackgroundColor: Color(0xffd1d5db),
        accentColor: Color(0xff111827),
        menuBackgroundColor: Color(0xffffffff),
        menuBorderColor: Color(0xff9ca3af),
        menuHoverBackgroundColor: Color(0xfff3f4f6),
        menuTextColor: Color(0xff111827),
        menuIconColor: Color(0xff111827),
        menuIconBackgroundColor: Color(0xffe5e7eb),
      ),
    ),
  ];

  String _ui(String zh, String en, [String? ko]) {
    return switch (_locale) {
      ChromeTabLocale.zh => zh,
      ChromeTabLocale.en => en,
      ChromeTabLocale.ko => ko ?? en,
    };
  }

  String _tabTitle(ChromeTabItem tab) {
    const titles = <String, List<String>>{
      'home': <String>['首页', 'Home', '홈'],
      'orders': <String>['订单中心', 'Orders', '주문'],
      'customers': <String>['客户管理', 'Customers', '고객'],
      'reports': <String>['数据报表', 'Reports', '보고서'],
      'settings': <String>['系统设置', 'Settings', '설정'],
      'docs': <String>['组件文档', 'Docs', '문서'],
      'notes': <String>['学习笔记', 'Notes', '노트'],
    };
    final translated = titles[tab.id];
    if (translated == null) return tab.title;
    return translated[_locale.index];
  }

  List<ChromeTabItem> _localizedTabs(Iterable<ChromeTabItem> tabs) => tabs
      .map(
        (tab) => ChromeTabItem(
          id: tab.id,
          title: _tabTitle(tab),
          backgroundColor: tab.backgroundColor,
          icon: tab.icon,
          disabled: tab.disabled,
          closable: tab.closable,
        ),
      )
      .toList(growable: false);

  void _log(
    String event, [
    Map<String, Object?> detail = const <String, Object?>{},
  ]) {
    final suffix = detail.isEmpty ? '' : ' ${jsonEncode(detail)}';
    setState(() {
      _events.insert(0, '$event$suffix');
      if (_events.length > 8) _events.removeLast();
    });
  }

  void _setLocale(ChromeTabLocale locale) {
    setState(() => _locale = locale);
    _log('locale: ${locale.name}');
  }

  void _activate(String id) {
    if (!_visibleTabs.any((tab) => tab.id == id)) return;
    setState(() => _activeTabByGroup[_activeGroupId] = id);
    _log('activate', <String, Object?>{'tabId': id});
  }

  void _addTab() {
    final id = 'new-${_nextTabId++}';
    final title = _ui(
      '新标签页 $_nextTabId',
      'New tab $_nextTabId',
      '새 탭 $_nextTabId',
    );
    final tab = ChromeTabItem(
      id: id,
      title: title,
      icon: const SemiIcon(SemiIcons.plusCircleStroked),
    );
    setState(() {
      _tabsByGroup[_activeGroupId] = <ChromeTabItem>[..._visibleTabs, tab];
      _activeTabByGroup[_activeGroupId] = id;
    });
    _log('add', <String, Object?>{'tabId': id, 'groupId': _activeGroupId});
  }

  void _closeTab(String id) {
    final current = _visibleTabs;
    final index = current.indexWhere((tab) => tab.id == id);
    if (index < 0 || !current[index].closable) return;
    final remaining = current.where((tab) => tab.id != id).toList();
    final wasActive = _activeTabId == id;
    setState(() {
      _tabsByGroup[_activeGroupId] = remaining;
      if (wasActive) {
        _activeTabByGroup[_activeGroupId] = remaining.isEmpty
            ? null
            : remaining[(index - 1).clamp(0, remaining.length - 1)].id;
      }
    });
    _log('close', <String, Object?>{'tabId': id});
  }

  void _closeMany(String id, String mode) {
    final current = _visibleTabs;
    final index = current.indexWhere((tab) => tab.id == id);
    if (index < 0) return;
    bool shouldClose(int tabIndex, ChromeTabItem tab) {
      if (!tab.closable) return false;
      if (mode == 'left') return tabIndex < index;
      if (mode == 'right') return tabIndex > index;
      return tab.id != id;
    }

    final remaining = <ChromeTabItem>[];
    for (var i = 0; i < current.length; i++) {
      if (!shouldClose(i, current[i])) remaining.add(current[i]);
    }
    setState(() {
      _tabsByGroup[_activeGroupId] = remaining;
      if (!_activeTabByGroup[_activeGroupId].let(
        (id) => id != null && remaining.any((tab) => tab.id == id),
      )) {
        _activeTabByGroup[_activeGroupId] = remaining.isEmpty
            ? null
            : remaining.first.id;
      }
    });
    _log('close $mode', <String, Object?>{'tabId': id});
  }

  void _renameTab(String id) {
    final current = _visibleTabs;
    final index = current.indexWhere((tab) => tab.id == id);
    if (index < 0) return;
    final old = current[index];
    final newTitle = '${_tabTitle(old)} · ${++_renameCount}';
    final updated = <ChromeTabItem>[...current];
    updated[index] = ChromeTabItem(
      id: old.id,
      title: newTitle,
      icon: old.icon,
      backgroundColor: old.backgroundColor,
      disabled: old.disabled,
      closable: old.closable,
    );
    setState(() => _tabsByGroup[_activeGroupId] = updated);
    _log('rename', <String, Object?>{'tabId': id, 'title': newTitle});
  }

  void _reorder(ChromeTabReorderInfo info) {
    final current = _visibleTabs;
    final sourceIndex = current.indexWhere((tab) => tab.id == info.tabId);
    final targetIndex = current.indexWhere((tab) => tab.id == info.targetTabId);
    if (sourceIndex < 0 || targetIndex < 0 || sourceIndex == targetIndex) {
      return;
    }
    final reordered = <ChromeTabItem>[...current]..removeAt(sourceIndex);
    var insertion = reordered.indexWhere((tab) => tab.id == info.targetTabId);
    if (info.position == ChromeTabReorderPosition.after) insertion++;
    reordered.insert(insertion, current[sourceIndex]);
    setState(() => _tabsByGroup[_activeGroupId] = reordered);
    _log('reorder', <String, Object?>{
      'tabId': info.tabId,
      'targetTabId': info.targetTabId,
      'position': info.position.name,
    });
  }

  void _switchGroup(String id) {
    if (!_groups.any((group) => group.id == id)) return;
    setState(() => _activeGroupId = id);
    _log('switchGroup', <String, Object?>{'groupId': id});
  }

  void _addGroup() {
    final id = 'group-${_nextGroupId++}';
    final name = _ui(
      '新分组 $_nextGroupId',
      'New group $_nextGroupId',
      '새 그룹 $_nextGroupId',
    );
    final tabId = '$id-tab';
    setState(() {
      _groups = <ChromeTabGroup>[
        ..._groups,
        ChromeTabGroup(id: id, name: name),
      ];
      _tabsByGroup[id] = <ChromeTabItem>[
        ChromeTabItem(id: tabId, title: _ui('新标签页', 'New tab', '새 탭')),
      ];
      _activeTabByGroup[id] = tabId;
      _activeGroupId = id;
    });
    _log('addGroup', <String, Object?>{'groupId': id});
  }

  void _renameGroup(String id) {
    final group = _groups.where((item) => item.id == id).firstOrNull;
    if (group == null) return;
    final newName = '${group.name} · ${++_renameCount}';
    setState(() {
      _groups = _groups
          .map(
            (item) =>
                item.id == id ? ChromeTabGroup(id: id, name: newName) : item,
          )
          .toList();
    });
    _log('renameGroup', <String, Object?>{'groupId': id, 'name': newName});
  }

  void _deleteGroup(String id) {
    if (_groups.length <= 1) return;
    final nextGroups = _groups.where((group) => group.id != id).toList();
    final nextId = id == _activeGroupId ? nextGroups.first.id : _activeGroupId;
    setState(() {
      _groups = nextGroups;
      _tabsByGroup.remove(id);
      _activeTabByGroup.remove(id);
      _activeGroupId = nextId;
    });
    _log('deleteGroup', <String, Object?>{'groupId': id});
  }

  void _applyPreset(_ChromeThemePreset preset) {
    setState(() {
      _selectedPreset = preset.name;
      _theme = preset.data;
    });
    _log('theme: ${preset.name}');
  }

  void _resetTheme() {
    final preset = _presets.first;
    setState(() {
      _selectedPreset = preset.name;
      _theme = preset.data;
    });
    _log('theme: reset');
  }

  void _editTheme({double? height, double? radius, Color? accent}) {
    setState(() {
      _selectedPreset = 'Custom';
      _theme = _theme.copyWith(
        stripHeight: height,
        tabHeight: height,
        tabRadius: radius,
        accentColor: accent,
      );
    });
  }

  ChromeTabThemeData get _previewTheme {
    if (!_darkPreview) return _theme;
    return _theme.copyWith(
      stripBackgroundColor: const Color(0xff111827),
      tabTextColor: const Color(0xffcbd5e1),
      tabActiveTextColor: const Color(0xff111827),
      tabHoverBackgroundColor: const Color(0xff374151),
      tabActiveBackgroundColor: const Color(0xfff8fafc),
      tabDividerColor: const Color(0xff475569),
      menuBackgroundColor: const Color(0xff1f2937),
      menuTextColor: const Color(0xfff8fafc),
    );
  }

  void _runScript(String action) {
    switch (action) {
      case 'activate':
        _activeGroupId = 'work';
        _activeTabByGroup['work'] = 'customers';
        _scriptCode = "tabsElement.activeGroupId = 'work';\ntabsElement.activeTabId = 'customers';";
        _log('Script API', <String, Object?>{
          'action': 'activate',
          'tabId': 'customers',
        });
      case 'add':
        _scriptCode = "tabsElement.tabs = [...tabsElement.tabs, {\n  id: 'new-tab',\n  title: 'New tab',\n}];";
        _addTab();
      case 'close':
        _scriptCode = "tabsElement.tabs = tabsElement.tabs.filter(\n  tab => tab.id !== activeTabId,\n);";
        final active = _activeTabId;
        if (active != null) _closeTab(active);
      case 'closeRight':
        _scriptCode = "const index = tabsElement.tabs.findIndex(\n  tab => tab.id === activeTabId,\n);\ntabsElement.tabs = tabsElement.tabs.slice(0, index + 1);";
        final active = _activeTabId;
        if (active != null) _closeMany(active, 'right');
      case 'groupWork':
        _scriptCode =
            "tabsElement.activeGroupId = 'work';\ntabsElement.tabs = workTabs;";
        _switchGroup('work');
      case 'groupStudy':
        _scriptCode = "tabsElement.activeGroupId = 'study';\ntabsElement.tabs = studyTabs;";
        _switchGroup('study');
    }
  }

  Map<String, Object?> get _stateJson => <String, Object?>{
    'activeGroupId': _activeGroupId,
    'activeTabId': _activeTabId,
    'groups': _groups
        .map(
          (group) => <String, Object?>{
            'id': group.id,
            'name': group.id == 'work'
                ? _ui('工作', 'Work', '워크')
                : group.id == 'study'
                ? _ui('学习', 'Study', '스터디')
                : group.name,
          },
        )
        .toList(),
    'tabs': _tabsByGroup.entries
        .expand(
          (entry) => entry.value.map(
            (tab) => <String, Object?>{
              'id': tab.id,
              'groupId': entry.key,
              'title': _tabTitle(tab),
            },
          ),
        )
        .toList(),
  };

  Widget _section({
    required Key key,
    required String title,
    required Widget child,
  }) {
    return DecoratedBox(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xffffffff).withValues(alpha: 0.72),
        border: Border.all(color: const Color(0xffe5e7eb)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SemiTitle(title, heading: 3),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _smallButton(
    String label, {
    Key? key,
    VoidCallback? onPressed,
    SemiButtonType type = SemiButtonType.secondary,
    Widget? icon,
  }) {
    return SemiButton(
      label,
      key: key,
      size: SemiButtonSize.small,
      type: type,
      icon: icon,
      onPressed: onPressed,
    );
  }

  Widget _buildLocaleHeader() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        SemiText(_ui('语言', 'Language', '언어'), strong: true),
        for (final locale in ChromeTabLocale.values)
          _smallButton(
            locale == ChromeTabLocale.zh
                ? '中文'
                : locale == ChromeTabLocale.en
                ? 'EN'
                : '한국어',
            type: _locale == locale
                ? SemiButtonType.primary
                : SemiButtonType.tertiary,
            onPressed: () => _setLocale(locale),
          ),
      ],
    );
  }

  Widget _buildOfficialPreview() {
    final visible = _localizedTabs(_visibleTabs);
    return ChromeTabTheme(
      data: _theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _theme.stripBackgroundColor ?? const Color(0xffdbeafe),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ChromeTab(
          key: const ValueKey('chrome-tab-official-preview'),
          tabs: visible,
          activeTabId: _activeTabId,
          groups: _groups
              .map(
                (group) => ChromeTabGroup(
                  id: group.id,
                  name: group.id == 'work'
                      ? _ui('工作', 'Work', '워크')
                      : group.id == 'study'
                      ? _ui('学习', 'Study', '스터디')
                      : group.name,
                ),
              )
              .toList(growable: false),
          activeGroupId: _activeGroupId,
          locale: _locale,
          tooltipMode: ChromeTabTooltipMode.always,
          onTabActivate: _activate,
          onTabEditAddress: _renameTab,
          onTabAdd: _addTab,
          onTabClose: _closeTab,
          onTabReorder: _reorder,
          onTabCloseLeft: (id) => _closeMany(id, 'left'),
          onTabCloseRight: (id) => _closeMany(id, 'right'),
          onTabCloseOthers: (id) => _closeMany(id, 'others'),
          onGroupSwitch: _switchGroup,
          onGroupAdd: _addGroup,
          onGroupRename: _renameGroup,
          onGroupDelete: _deleteGroup,
        ),
      ),
    );
  }

  Widget _buildThemePresets() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        for (final preset in _presets)
          GestureDetector(
            key: ValueKey('chrome-tab-preset-${preset.keyName}'),
            onTap: () => _applyPreset(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 150,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: preset.data.stripBackgroundColor,
                border: Border.all(
                  color: _selectedPreset == preset.name
                      ? preset.data.accentColor ?? const Color(0xff2563eb)
                      : const Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(preset.data.tabRadius ?? 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: preset.data.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SemiText(
                          preset.name,
                          strong: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  SemiText(preset.description, size: SemiTextSize.small),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThemeEditor() {
    final colorPresets = <MapEntry<String, Color>>[
      const MapEntry<String, Color>('Blue', Color(0xff2563eb)),
      const MapEntry<String, Color>('Purple', Color(0xff7f56d9)),
      const MapEntry<String, Color>('Green', Color(0xff059669)),
      const MapEntry<String, Color>('Orange', Color(0xffd97706)),
      const MapEntry<String, Color>('Ink', Color(0xff111827)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _smallButton(
              _darkPreview ? '浅色预览' : '深色预览',
              icon: SemiIcon(_darkPreview ? SemiIcons.sun : SemiIcons.moon),
              onPressed: () => setState(() => _darkPreview = !_darkPreview),
            ),
            _smallButton(
              'Reset',
              key: const ValueKey('chrome-tab-theme-reset'),
              onPressed: _resetTheme,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SemiText(_ui('尺寸与圆角', 'Size and radius', '크기와 모서리'), strong: true),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final height in <double>[38, 44, 50])
              _smallButton(
                'Height ${height.toInt()}',
                type: _theme.stripHeight == height
                    ? SemiButtonType.primary
                    : SemiButtonType.tertiary,
                onPressed: () => _editTheme(height: height),
              ),
            for (final radius in <double>[0, 8, 14])
              _smallButton(
                'Radius ${radius.toInt()}',
                type: _theme.tabRadius == radius
                    ? SemiButtonType.primary
                    : SemiButtonType.tertiary,
                onPressed: () => _editTheme(radius: radius),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SemiText(_ui('强调色', 'Accent color', '강조 색상'), strong: true),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: <Widget>[
            for (final entry in colorPresets)
              GestureDetector(
                key: ValueKey('chrome-tab-color-${entry.key.toLowerCase()}'),
                onTap: () => _editTheme(accent: entry.value),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _theme.accentColor == entry.value
                          ? const Color(0xff111827)
                          : const Color(0x00000000),
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ChromeTabTheme(
          data: _previewTheme,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _previewTheme.stripBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ChromeTab(
              tabs: _localizedTabs(_visibleTabs.take(3)),
              activeTabId: _activeTabId,
              hideAddButton: true,
              hideGroupButton: true,
              locale: _locale,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScriptControls() {
    final actions = <Map<String, String>>[
      <String, String>{'id': 'activate', 'label': 'Activate customers'},
      <String, String>{'id': 'add', 'label': 'Add tab'},
      <String, String>{'id': 'close', 'label': 'Close active tab'},
      <String, String>{'id': 'closeRight', 'label': 'Close all to the right'},
      <String, String>{'id': 'groupWork', 'label': 'Switch to Work'},
      <String, String>{'id': 'groupStudy', 'label': 'Switch to Study'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final action in actions)
              _smallButton(
                action['label']!,
                key: ValueKey('chrome-tab-script-${action['id']}'),
                onPressed: () => _runScript(action['id']!),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _codeBlock(_scriptCode),
      ],
    );
  }

  Widget _buildStateJson() {
    final source = const JsonEncoder.withIndent('  ').convert(_stateJson);
    return _codeBlock(source, key: const ValueKey('chrome-tab-state-json'));
  }

  Widget _buildEventLog() {
    return DecoratedBox(
      key: const ValueKey('chrome-tab-event-log'),
      decoration: BoxDecoration(
        color: const Color(0xff0f172a),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _events.isEmpty
            ? const SemiText(
                'No events yet — click a tab, use the menu, or run a script.',
                style: TextStyle(color: Color(0xffcbd5e1)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final event in _events)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SemiText(
                        event,
                        style: const TextStyle(
                          color: Color(0xffcbd5e1),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickStart() {
    const code =
        "final tabs = <ChromeTabItem>[\n  const ChromeTabItem(id: 'home', title: 'Home'),\n  const ChromeTabItem(id: 'orders', title: 'Orders'),\n];\n\nChromeTab(\n  tabs: tabs,\n  activeTabId: activeTabId,\n  onTabActivate: (id) => setState(() => activeTabId = id),\n  onTabClose: (id) => setState(() =>\n    tabs.removeWhere((tab) => tab.id == id)),\n);";
    return _codeBlock(code, key: const ValueKey('chrome-tab-quick-start'));
  }

  Widget _buildIconDemo() {
    final iconTabs = <ChromeTabItem>[
      const ChromeTabItem(
        id: 'svg',
        title: 'SVG image',
        icon: SemiIcon(SemiIcons.imageStroked),
      ),
      const ChromeTabItem(
        id: 'favicon',
        title: 'Default favicon',
        icon: SemiIcon(SemiIcons.globeStroked),
      ),
      const ChromeTabItem(id: 'custom', title: 'Custom renderTabIcon'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SemiText(
          _ui(
            '支持 SemiIcon、图片图标，也可以通过 renderTabIcon 返回任意 Widget。',
            'Use SemiIcon, image icons, or return any Widget from renderTabIcon.',
            'SemiIcon과 renderTabIcon 사용자 위젯을 지원합니다.',
          ),
        ),
        const SizedBox(height: 10),
        ChromeTab(
          key: const ValueKey('chrome-tab-icon-demo'),
          tabs: iconTabs,
          activeTabId: 'svg',
          hideAddButton: true,
          hideGroupButton: true,
          locale: _locale,
          renderTabIcon: (tab) {
            if (tab.id != 'custom') return null;
            return const SemiIcon(
              SemiIcons.checkCircleStroked,
              color: Color(0xff059669),
            );
          },
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: <Widget>[
            SemiText('SemiIcon', icon: SemiIcon(SemiIcons.bookStroked)),
            SemiText(
              'Custom SVG-like icon',
              icon: SemiIcon(SemiIcons.checkCircleStroked),
            ),
          ],
        ),
      ],
    );
  }

  Widget _codeBlock(String source, {Key? key}) {
    return DecoratedBox(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xff0f172a),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SemiText(
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
  }

  @override
  Widget build(BuildContext context) {
    final status = _ui(
      '点击标签、双击重命名、长按打开批量关闭菜单，或拖拽标签排序。',
      'Click, double-click, long-press, or drag tabs to exercise the controlled API.',
      '탭을 클릭·더블 클릭·길게 누르거나 드래그해 제어 API를 확인하세요.',
    );
    return Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (_) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SemiTitle('ChromeTab', heading: 2),
                SemiText(
                  _ui(
                    'qn-chrome-tabs 官方 demo 的 Flutter 版本：受控标签、分组、主题与 Script API。',
                    'A Flutter version of the official qn-chrome-tabs demo: controlled tabs, groups, themes, and Script API.',
                    '공식 qn-chrome-tabs 데모의 Flutter 버전입니다.',
                  ),
                ),
                const SizedBox(height: 12),
                _buildLocaleHeader(),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-official-preview-section'),
                  title: _ui(
                    '官方受控预览',
                    'Official controlled preview',
                    '공식 제어 미리보기',
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildOfficialPreview(),
                      const SizedBox(height: 8),
                      SemiText(
                        status,
                        key: const ValueKey('chrome-tab-status'),
                      ),
                      const SizedBox(height: 6),
                      SemiText(
                        _ui(
                          '活动分组：${_activeGroup?.name ?? ''} · 活动标签：${_activeTabId ?? '—'}',
                          'Active group: ${_activeGroup?.name ?? ''} · active tab: ${_activeTabId ?? '—'}',
                          '활성 그룹: ${_activeGroup?.name ?? ''} · 활성 탭: ${_activeTabId ?? '—'}',
                        ),
                        type: SemiTextType.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-theme-presets'),
                  title: 'Theme presets',
                  child: _buildThemePresets(),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-theme-editor'),
                  title: 'Interactive theme editor',
                  child: _buildThemeEditor(),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-script-controls'),
                  title: 'Script control',
                  child: _buildScriptControls(),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-state-json-section'),
                  title: 'Current state JSON',
                  child: _buildStateJson(),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-event-log-section'),
                  title: 'Event log',
                  child: _buildEventLog(),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-quick-start-section'),
                  title: 'Flutter quick start',
                  child: _buildQuickStart(),
                ),
                const SizedBox(height: 16),
                _section(
                  key: const ValueKey('chrome-tab-icon-demo-section'),
                  title: 'Tab icon examples',
                  child: _buildIconDemo(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChromeThemePreset {
  const _ChromeThemePreset({
    required this.keyName,
    required this.name,
    required this.description,
    required this.data,
  });

  final String keyName;
  final String name;
  final String description;
  final ChromeTabThemeData data;
}

extension on Object? {
  T let<T>(T Function(Object?) transform) => transform(this);
}

extension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
