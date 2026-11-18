import 'package:flutter/material.dart' show showDialog;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/chrome_tab_theme.dart';
import '../theme/chrome_tab_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_dropdown.dart';
import 'semi_tooltip.dart';

/// Language used by ChromeTab's built-in labels.
enum ChromeTabLocale { zh, en, ko }

/// Controls when a tab title tooltip is shown.
enum ChromeTabTooltipMode { truncated, always, never }

/// The side of a target tab where a dragged tab is inserted.
enum ChromeTabReorderPosition { before, after }

/// A tab displayed by [ChromeTab].
@immutable
class ChromeTabItem {
  const ChromeTabItem({
    required this.id,
    required this.title,
    this.backgroundColor,
    this.icon,
    this.disabled = false,
    this.closable = true,
  });

  final String id;
  final String title;
  final Color? backgroundColor;
  final Widget? icon;
  final bool disabled;
  final bool closable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChromeTabItem &&
          id == other.id &&
          title == other.title &&
          backgroundColor == other.backgroundColor &&
          icon == other.icon &&
          disabled == other.disabled &&
          closable == other.closable;

  @override
  int get hashCode =>
      Object.hash(id, title, backgroundColor, icon, disabled, closable);
}

/// A group shown in ChromeTab's group menu.
@immutable
class ChromeTabGroup {
  const ChromeTabGroup({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChromeTabGroup && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Payload emitted after a tab is dropped on another tab.
@immutable
class ChromeTabReorderInfo {
  const ChromeTabReorderInfo({
    required this.tabId,
    required this.targetTabId,
    required this.position,
  });

  final String tabId;
  final String targetTabId;
  final ChromeTabReorderPosition position;
}

/// A Chrome-like, externally controlled tab strip.
///
/// The widget renders the supplied lists and reports user actions through
/// callbacks. It never removes, reorders, or changes the supplied data itself.
class ChromeTab extends StatefulWidget {
  const ChromeTab({
    super.key,
    this.tabs = const <ChromeTabItem>[],
    this.activeTabId,
    this.groups = const <ChromeTabGroup>[],
    this.activeGroupId,
    this.locale,
    this.tooltipMode = ChromeTabTooltipMode.truncated,
    this.tabTooltipMode,
    this.hideAddButton = false,
    this.hideGroupButton = false,
    this.onTabActivate,
    this.onTabEditAddress,
    this.onTabClose,
    this.onTabAdd,
    this.onGroupSwitch,
    this.onGroupAdd,
    this.onGroupRename,
    this.onGroupDelete,
    this.onTabReorder,
    this.onTabCloseLeft,
    this.onTabCloseRight,
    this.onTabCloseOthers,
    this.onActivate,
    this.onEdit,
    this.onClose,
    this.onAdd,
    this.onSwitchGroup,
    this.onAddGroup,
    this.onRenameGroup,
    this.onDeleteGroup,
    this.onReorder,
    this.onCloseLeft,
    this.onCloseRight,
    this.onCloseOthers,
    this.renderTabIcon,
    this.renderTabTooltip,
  });

  final List<ChromeTabItem> tabs;
  final String? activeTabId;
  final List<ChromeTabGroup> groups;
  final String? activeGroupId;
  final ChromeTabLocale? locale;
  final ChromeTabTooltipMode tooltipMode;

  /// Alias matching the web component property name.
  final ChromeTabTooltipMode? tabTooltipMode;
  final bool hideAddButton;
  final bool hideGroupButton;
  final ValueChanged<String>? onTabActivate;
  final ValueChanged<String>? onTabEditAddress;
  final ValueChanged<String>? onTabClose;
  final VoidCallback? onTabAdd;
  final ValueChanged<String>? onGroupSwitch;
  final VoidCallback? onGroupAdd;
  final ValueChanged<String>? onGroupRename;
  final ValueChanged<String>? onGroupDelete;
  final ValueChanged<ChromeTabReorderInfo>? onTabReorder;
  final ValueChanged<String>? onTabCloseLeft;
  final ValueChanged<String>? onTabCloseRight;
  final ValueChanged<String>? onTabCloseOthers;

  /// Short callback aliases matching the web component event vocabulary.
  final ValueChanged<String>? onActivate;
  final ValueChanged<String>? onEdit;
  final ValueChanged<String>? onClose;
  final VoidCallback? onAdd;
  final ValueChanged<String>? onSwitchGroup;
  final VoidCallback? onAddGroup;
  final ValueChanged<String>? onRenameGroup;
  final ValueChanged<String>? onDeleteGroup;
  final ValueChanged<ChromeTabReorderInfo>? onReorder;
  final ValueChanged<String>? onCloseLeft;
  final ValueChanged<String>? onCloseRight;
  final ValueChanged<String>? onCloseOthers;
  final Widget? Function(ChromeTabItem tab)? renderTabIcon;
  final Widget? Function(ChromeTabItem tab)? renderTabTooltip;

  @override
  State<ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<ChromeTab> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _tabKeys = <String, GlobalKey>{};
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  String? get _activeTabId => widget.activeTabId;
  String? get _activeGroupId => widget.activeGroupId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncScrollButtons);
    _syncTabKeys();
  }

  @override
  void didUpdateWidget(ChromeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTabKeys();
    if (widget.activeTabId != oldWidget.activeTabId &&
        widget.activeTabId != null) {
      _ensureTabVisible(widget.activeTabId!);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncScrollButtons)
      ..dispose();
    super.dispose();
  }

  void _syncTabKeys() {
    final ids = widget.tabs.map((tab) => tab.id).toSet();
    _tabKeys.removeWhere((id, _) => !ids.contains(id));
    for (final id in ids) {
      _tabKeys.putIfAbsent(id, GlobalKey.new);
    }
  }

  void _syncScrollButtons() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final left = position.pixels > position.minScrollExtent + 1;
    final right = position.pixels < position.maxScrollExtent - 1;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  void _ensureTabVisible(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _tabKeys[id]?.currentContext;
      if (context != null && mounted) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 160),
        );
      }
      _syncScrollButtons();
    });
  }

  void _activate(ChromeTabItem tab) {
    if (tab.disabled) return;
    (widget.onTabActivate ?? widget.onActivate)?.call(tab.id);
    _ensureTabVisible(tab.id);
  }

  void _closeTab(String id) => (widget.onTabClose ?? widget.onClose)?.call(id);
  void _addTab() => (widget.onTabAdd ?? widget.onAdd)?.call();
  void _switchGroup(String id) =>
      (widget.onGroupSwitch ?? widget.onSwitchGroup)?.call(id);

  ChromeTabLocale _locale(BuildContext context) {
    if (widget.locale != null) return widget.locale!;
    final localizations = Localizations.maybeLocaleOf(context);
    final language = localizations?.languageCode ?? 'zh';
    if (language == 'en') return ChromeTabLocale.en;
    if (language == 'ko') return ChromeTabLocale.ko;
    return ChromeTabLocale.zh;
  }

  String _message(BuildContext context, String key) {
    const values = <ChromeTabLocale, Map<String, String>>{
      ChromeTabLocale.zh: {
        'close': '关闭',
        'add': '添加标签页',
        'group': '选择分组',
        'newGroup': '新建分组',
        'rename': '重命名',
        'delete': '删除',
        'left': '关闭左侧所有',
        'right': '关闭右侧所有',
        'others': '关闭其他所有',
        'scrollLeft': '向左滚动标签',
        'scrollRight': '向右滚动标签',
      },
      ChromeTabLocale.en: {
        'close': 'Close',
        'add': 'Add tab',
        'group': 'Select group',
        'newGroup': 'New group',
        'rename': 'Rename',
        'delete': 'Delete',
        'left': 'Close all to the left',
        'right': 'Close all to the right',
        'others': 'Close other tabs',
        'scrollLeft': 'Scroll tabs left',
        'scrollRight': 'Scroll tabs right',
      },
      ChromeTabLocale.ko: {
        'close': '닫기',
        'add': '탭 추가',
        'group': '그룹 선택',
        'newGroup': '새 그룹',
        'rename': '이름 변경',
        'delete': '삭제',
        'left': '왼쪽 탭 모두 닫기',
        'right': '오른쪽 탭 모두 닫기',
        'others': '다른 탭 모두 닫기',
        'scrollLeft': '탭을 왼쪽으로 스크롤',
        'scrollRight': '탭을 오른쪽으로 스크롤',
      },
    };
    return values[_locale(context)]![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChromeTabTheme.resolve(context);
    final direction = Directionality.of(context);
    final tabs = <Widget>[
      for (var index = 0; index < widget.tabs.length; index++)
        _buildTab(context, theme, widget.tabs[index], index),
    ];
    final strip = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.stripBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.tabDividerColor)),
      ),
      child: SizedBox(
        height: theme.stripHeight,
        child: Row(
          textDirection: direction,
          children: [
            if (_canScrollLeft) _scrollButton(context, theme, true),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisSize: MainAxisSize.min, children: tabs),
              ),
            ),
            if (_canScrollRight) _scrollButton(context, theme, false),
            if (!widget.hideAddButton) _addButton(context, theme),
            if (!widget.hideGroupButton && widget.groups.isNotEmpty)
              _groupButton(context, theme),
          ],
        ),
      ),
    );
    return Semantics(container: true, label: 'Chrome tabs', child: strip);
  }

  Widget _scrollButton(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    bool left,
  ) {
    final icon = left ? SemiIcons.chevronLeft : SemiIcons.chevronRight;
    return Semantics(
      button: true,
      label: _message(context, left ? 'scrollLeft' : 'scrollRight'),
      child: GestureDetector(
        key: ValueKey('chrome-tab-scroll-${left ? 'left' : 'right'}'),
        onTap: () => _scrollController.animateTo(
          (_scrollController.offset + (left ? -180 : 180)).clamp(
            0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
        ),
        child: SizedBox(
          width: theme.scrollButtonWidth,
          height: theme.stripHeight,
          child: Center(child: SemiIcon(icon, customSize: 16)),
        ),
      ),
    );
  }

  Widget _addButton(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
  ) {
    return Semantics(
      button: true,
      label: _message(context, 'add'),
      child: GestureDetector(
        key: const ValueKey('chrome-tab-add'),
        onTap: _addTab,
        child: SizedBox(
          width: theme.newTabButtonSize,
          height: theme.stripHeight,
          child: const Center(child: SemiIcon(SemiIcons.plus, customSize: 16)),
        ),
      ),
    );
  }

  Widget _groupButton(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
  ) {
    final menu = <SemiDropdownNode>[
      for (final group in widget.groups)
        SemiDropdownItemData(
          name: group.name,
          active: group.id == _activeGroupId,
          onTap: () {
            _switchGroup(group.id);
          },
        ),
      const SemiDropdownDividerData(),
      SemiDropdownItemData(
        name: _message(context, 'newGroup'),
        onTap: widget.onGroupAdd ?? widget.onAddGroup,
      ),
      if (_activeGroupId != null)
        SemiDropdownItemData(
          name: _message(context, 'rename'),
          onTap: () => (widget.onGroupRename ?? widget.onRenameGroup)?.call(
            _activeGroupId!,
          ),
        ),
      if (_activeGroupId != null)
        SemiDropdownItemData(
          name: _message(context, 'delete'),
          onTap: () => (widget.onGroupDelete ?? widget.onDeleteGroup)?.call(
            _activeGroupId!,
          ),
        ),
    ];
    return SemiDropdown(
      key: const ValueKey('chrome-tab-group'),
      trigger: SemiTooltipTrigger.click,
      position: SemiTooltipPosition.bottomRight,
      menu: menu,
      child: Semantics(
        button: true,
        expanded: false,
        label: _message(context, 'group'),
        child: SizedBox(
          width: theme.groupButtonSize,
          height: theme.stripHeight,
          child: const Center(
            child: SemiIcon(SemiIcons.chevronDown, customSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    ChromeTabItem tab,
    int index,
  ) {
    final selected = tab.id == _activeTabId;
    final icon = widget.renderTabIcon?.call(tab) ?? tab.icon;
    final title = Text(
      tab.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: tab.disabled
            ? theme.tabDisabledTextColor
            : selected
            ? theme.tabActiveTextColor
            : theme.tabTextColor,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    final body = _TabSurface(
      key: _tabKeys[tab.id],
      theme: theme,
      selected: selected,
      disabled: tab.disabled,
      backgroundColor: selected
          ? tab.backgroundColor ?? theme.tabActiveBackgroundColor
          : theme.tabBackgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SizedBox(
              width: theme.iconSize,
              height: theme.iconSize,
              child: icon,
            ),
            SizedBox(width: theme.tabIconGap),
          ],
          Flexible(child: title),
          if (tab.closable) ...[
            SizedBox(width: theme.tabCloseRight),
            _closeButton(context, theme, tab),
          ],
        ],
      ),
    );
    final tabWithInteraction = SizedBox(
      key: ValueKey('chrome-tab-tap-${tab.id}'),
      width: theme.tabMaxWidth,
      height: theme.stripHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tab.disabled ? null : () => _activate(tab),
        onLongPress: tab.disabled ? null : () => _showTabActions(context, tab),
        child: body,
      ),
    );
    final tooltip = widget.renderTabTooltip?.call(tab);
    Widget result = tabWithInteraction;
    final tooltipMode = widget.tabTooltipMode ?? widget.tooltipMode;
    if (tooltipMode != ChromeTabTooltipMode.never &&
        (tooltipMode == ChromeTabTooltipMode.always ||
            tooltip != null ||
            (tooltipMode == ChromeTabTooltipMode.truncated &&
                tab.title.length > 18))) {
      result = SemiTooltip(
        content: tooltip ?? Text(tab.title),
        trigger: SemiTooltipTrigger.hover,
        showArrow: false,
        position: SemiTooltipPosition.bottom,
        child: result,
      );
    }
    return RepaintBoundary(
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data != tab.id,
        onAcceptWithDetails: (details) {
          if (details.data == tab.id) return;
          final targetContext = _tabKeys[tab.id]?.currentContext;
          final renderObject = targetContext?.findRenderObject();
          final targetWidth = renderObject is RenderBox
              ? renderObject.size.width
              : theme.tabMaxWidth;
          final localPosition = renderObject is RenderBox
              ? renderObject.globalToLocal(details.offset)
              : Offset(targetWidth / 2, 0);
          final position = localPosition.dx < targetWidth / 2
              ? ChromeTabReorderPosition.before
              : ChromeTabReorderPosition.after;
          (widget.onTabReorder ?? widget.onReorder)?.call(
            ChromeTabReorderInfo(
              tabId: details.data,
              targetTabId: tab.id,
              position: position,
            ),
          );
        },
        builder: (_, _, _) => tabWithInteraction,
      ),
    );
  }

  Widget _closeButton(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    ChromeTabItem tab,
  ) {
    return Semantics(
      button: true,
      label: '${_message(context, 'close')} ${tab.title}',
      child: GestureDetector(
        key: ValueKey('chrome-tab-close-${tab.id}'),
        onTap: () => _closeTab(tab.id),
        child: SizedBox(
          width: theme.closeButtonWidth,
          height: theme.closeButtonHeight,
          child: const Center(child: SemiIcon(SemiIcons.close, customSize: 13)),
        ),
      ),
    );
  }

  void _showTabActions(BuildContext context, ChromeTabItem tab) {
    // Long press is the touch equivalent of the browser context menu. The
    // desktop secondary-tap path is provided by the same menu wrapper below.
    showDialog<void>(
      context: context,
      builder: (context) => _TabActionMenu(
        tab: tab,
        close: widget.onTabClose ?? widget.onClose,
        closeLeft: widget.onTabCloseLeft ?? widget.onCloseLeft,
        closeRight: widget.onTabCloseRight ?? widget.onCloseRight,
        closeOthers: widget.onTabCloseOthers ?? widget.onCloseOthers,
        label: _message,
      ),
    );
  }

  KeyEventResult _handleKey(ChromeTabItem tab, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _activate(tab);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      if (tab.closable) _closeTab(tab.id);
      return KeyEventResult.handled;
    }
    final current = widget.tabs.indexWhere((item) => item.id == tab.id);
    if (current < 0 || widget.tabs.isEmpty) return KeyEventResult.ignored;
    var next = current;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    if (key == LogicalKeyboardKey.home) {
      next = 0;
    } else if (key == LogicalKeyboardKey.end) {
      next = widget.tabs.length - 1;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      next += rtl ? -1 : 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      next += rtl ? 1 : -1;
    } else {
      return KeyEventResult.ignored;
    }
    next = (next + widget.tabs.length) % widget.tabs.length;
    final target = widget.tabs[next];
    if (!target.disabled) {
      FocusScope.of(context).requestFocus(Focus.of(context));
      _activate(target);
    }
    return KeyEventResult.handled;
  }
}

class _TabSurface extends StatefulWidget {
  const _TabSurface({
    super.key,
    required this.theme,
    required this.selected,
    required this.disabled,
    required this.backgroundColor,
    required this.child,
  });

  final SemiResolvedChromeTabThemeData theme;
  final bool selected;
  final bool disabled;
  final Color backgroundColor;
  final Widget child;

  @override
  State<_TabSurface> createState() => _TabSurfaceState();
}

class _TabSurfaceState extends State<_TabSurface> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = _pressed
        ? widget.theme.tabPressedBackgroundColor
        : _hovered
        ? widget.theme.tabHoverBackgroundColor
        : widget.backgroundColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.theme.tabMinWidth,
            maxWidth: widget.theme.tabMaxWidth,
            minHeight: widget.theme.tabHeight,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(widget.theme.tabRadius),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.theme.tabContentPaddingX,
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabActionMenu extends StatelessWidget {
  const _TabActionMenu({
    required this.tab,
    required this.close,
    required this.closeLeft,
    required this.closeRight,
    required this.closeOthers,
    required this.label,
  });

  final ChromeTabItem tab;
  final ValueChanged<String>? close;
  final ValueChanged<String>? closeLeft;
  final ValueChanged<String>? closeRight;
  final ValueChanged<String>? closeOthers;
  final String Function(BuildContext, String) label;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (tab.closable)
        _action(context, label(context, 'close'), () {
          Navigator.of(context).pop();
          close?.call(tab.id);
        }),
      _action(context, label(context, 'left'), () {
        Navigator.of(context).pop();
        closeLeft?.call(tab.id);
      }),
      _action(context, label(context, 'right'), () {
        Navigator.of(context).pop();
        closeRight?.call(tab.id);
      }),
      _action(context, label(context, 'others'), () {
        Navigator.of(context).pop();
        closeOthers?.call(tab.id);
      }),
    ];
    return Center(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xffffffff)),
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(mainAxisSize: MainAxisSize.min, children: actions),
          ),
        ),
      ),
    );
  }

  Widget _action(BuildContext context, String text, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(text),
          ),
        ),
      );
}
