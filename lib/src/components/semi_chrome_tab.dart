import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_chrome_tab_theme.dart';
import '../theme/semi_chrome_tab_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';

/// Language used by [SemiChromeTab]'s built-in labels.
///
/// The upstream qn-chrome-tabs web component ships `zh`, `en`, and `ko`
/// dictionaries and detects the browser language; passing [SemiChromeTab.locale]
/// overrides the ambient `Localizations` language.
enum SemiChromeTabLocale { zh, en, ko }

/// Controls when a tab title tooltip is shown.
enum SemiChromeTabTooltipMode { truncated, always, never }

/// The side of a target tab where a dragged tab is inserted.
enum SemiChromeTabReorderPosition { before, after }

/// A tab displayed by [SemiChromeTab].
@immutable
class SemiChromeTabItem {
  const SemiChromeTabItem({
    required this.id,
    required this.title,
    this.backgroundColor,
    this.icon,
  });

  final String id;
  final String title;

  /// Background of the tab while it is active. Falls back to
  /// `SemiChromeTabThemeData.chromeTabActiveBackground`.
  final Color? backgroundColor;

  /// Any widget: an `Image`, a [SemiIcon], or a custom icon from
  /// [SemiChromeTab.renderTabIcon]. Upstream favicon URLs are not fetched
  /// because the Flutter package has no network layer.
  final Widget? icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiChromeTabItem &&
          id == other.id &&
          title == other.title &&
          backgroundColor == other.backgroundColor &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(id, title, backgroundColor, icon);
}

/// A workspace group listed in [SemiChromeTab]'s group menu.
@immutable
class SemiChromeTabGroup {
  const SemiChromeTabGroup({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiChromeTabGroup && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Payload emitted after a dragged tab is dropped on another tab.
@immutable
class SemiChromeTabReorderInfo {
  const SemiChromeTabReorderInfo({
    required this.tabId,
    required this.targetTabId,
    required this.position,
  });

  final String tabId;
  final String targetTabId;
  final SemiChromeTabReorderPosition position;
}

/// A Chrome-style, externally controlled tab strip.
///
/// The widget renders the supplied lists and reports user actions through
/// callbacks. It never removes, reorders, or changes the supplied data itself,
/// mirroring the controlled `<qn-chrome-tabs>` web component.
///
/// An [Overlay] ancestor is required for the group menu, context menu, tooltips,
/// and the overflow tab list (normally supplied by `Navigator`).
class SemiChromeTab extends StatefulWidget {
  const SemiChromeTab({
    super.key,
    this.tabs = const <SemiChromeTabItem>[],
    this.activeTabId,
    this.groups = const <SemiChromeTabGroup>[],
    this.activeGroupId,
    this.locale,
    this.hideAddButton = false,
    this.hideGroupButton = false,
    this.hideScrollbar = true,
    this.tooltipMode = SemiChromeTabTooltipMode.truncated,
    this.onTabActivate,
    this.onTabEditAddress,
    this.onTabClose,
    this.onTabAdd,
    this.onTabReorder,
    this.onTabCloseLeft,
    this.onTabCloseRight,
    this.onTabCloseOthers,
    this.onGroupSwitch,
    this.onGroupAdd,
    this.onGroupRename,
    this.onGroupDelete,
    this.renderTabIcon,
    this.renderTabTooltip,
  });

  final List<SemiChromeTabItem> tabs;
  final String? activeTabId;
  final List<SemiChromeTabGroup> groups;
  final String? activeGroupId;
  final SemiChromeTabLocale? locale;
  final bool hideAddButton;
  final bool hideGroupButton;

  /// Whether the horizontal scroll indicator is hidden.
  final bool hideScrollbar;
  final SemiChromeTabTooltipMode tooltipMode;

  /// Click a tab.
  final ValueChanged<String>? onTabActivate;

  /// Double-click a tab.
  final ValueChanged<String>? onTabEditAddress;

  /// Close the tab. Emitted after the 140ms close animation, as upstream does.
  final ValueChanged<String>? onTabClose;
  final VoidCallback? onTabAdd;
  final ValueChanged<SemiChromeTabReorderInfo>? onTabReorder;
  final ValueChanged<String>? onTabCloseLeft;
  final ValueChanged<String>? onTabCloseRight;
  final ValueChanged<String>? onTabCloseOthers;
  final ValueChanged<String>? onGroupSwitch;
  final VoidCallback? onGroupAdd;
  final ValueChanged<String>? onGroupRename;
  final ValueChanged<String>? onGroupDelete;

  /// Overrides [SemiChromeTabItem.icon] when it returns non-null.
  final Widget? Function(SemiChromeTabItem tab)? renderTabIcon;

  /// Custom tooltip content. Returning null disables the tooltip for that tab.
  final Widget? Function(SemiChromeTabItem tab)? renderTabTooltip;

  @override
  State<SemiChromeTab> createState() => _SemiChromeTabState();
}

class _SemiChromeTabState extends State<SemiChromeTab> {
  static const double _scrollButtonWidth = 36;
  static const double _addSlotWidth = 38;
  static const double _addButtonSize = 30;
  static const double _groupButtonSize = 30;
  static const double _groupContentPaddingRight = 8;
  static const double _dividerWidth = 2;
  static const double _dividerHeight = 18;
  static const double _iconSize = 16;
  static const double _iconGap = 6;
  static const double _closeButtonSize = 18;
  static const double _groupMenuWidth = 210;
  static const double _contextMenuWidth = 172;
  static const double _menuRadius = 8;
  static const double _tooltipRadius = 12;
  static const int _menuSeparator = 0xffe8eaed;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _viewportKey = GlobalKey(debugLabel: 'semi-chrome-tabs');
  final GlobalKey _addButtonKey = GlobalKey(debugLabel: 'semi-chrome-tab-add');
  final GlobalKey _groupButtonKey = GlobalKey(
    debugLabel: 'semi-chrome-tab-group',
  );
  final GlobalKey _leftScrollKey = GlobalKey(
    debugLabel: 'semi-chrome-tab-scroll-left',
  );
  final GlobalKey _rightScrollKey = GlobalKey(
    debugLabel: 'semi-chrome-tab-scroll-right',
  );
  final Map<String, GlobalKey> _tabKeys = <String, GlobalKey>{};
  final Map<String, LayerLink> _tabLinks = <String, LayerLink>{};
  final LayerLink _leftScrollLink = LayerLink();
  final LayerLink _rightScrollLink = LayerLink();
  final LayerLink _groupLink = LayerLink();
  final ValueNotifier<int> _popupRevision = ValueNotifier<int>(0);

  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  String? _hoveredTabId;
  bool _groupHovered = false;
  final Set<String> _enteringIds = <String>{};
  final Set<String> _closingIds = <String>{};
  final Map<String, Timer> _closeTimers = <String, Timer>{};
  final Map<String, bool> _truncated = <String, bool>{};

  String? _dropTargetId;
  SemiChromeTabReorderPosition? _dropPosition;

  Timer? _doubleTapTimer;
  String? _pendingTapTabId;

  double? _pendingAddAnchorX;

  OverlayEntry? _popupEntry;
  _PopupKind? _popupKind;
  Timer? _popupCloseTimer;

  @override
  void initState() {
    super.initState();
    _syncTabKeys();
    _scroll.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateScrollControls();
      _ensureActiveVisible();
    });
  }

  @override
  void didUpdateWidget(covariant SemiChromeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTabKeys();

    final oldIds = oldWidget.tabs.map((tab) => tab.id).toSet();
    final newIds = widget.tabs.map((tab) => tab.id).toSet();
    for (final id in newIds.difference(oldIds)) {
      _enteringIds.add(id);
    }
    _closingIds.removeWhere((id) => !newIds.contains(id));
    if (widget.tabs.length < oldWidget.tabs.length) {
      _pendingAddAnchorX = null;
    }
    if ((_popupKind == _PopupKind.groupMenu &&
            (!_listEquals(widget.groups, oldWidget.groups) ||
                widget.activeGroupId != oldWidget.activeGroupId)) ||
        (widget.tooltipMode == SemiChromeTabTooltipMode.never &&
            _popupKind == _PopupKind.tooltip)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _closePopup();
      });
    }
    if (widget.activeTabId != oldWidget.activeTabId ||
        widget.tabs.length != oldWidget.tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensureActiveVisible();
      });
    }
    if (_pendingAddAnchorX != null &&
        widget.tabs.length > oldWidget.tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _settleAddAnchor();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollControls();
    });
  }

  @override
  void dispose() {
    _closePopup(refresh: false);
    for (final timer in _closeTimers.values) {
      timer.cancel();
    }
    _closeTimers.clear();
    _doubleTapTimer?.cancel();
    _popupCloseTimer?.cancel();
    _popupRevision.dispose();
    _scroll
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _syncTabKeys() {
    final ids = widget.tabs.map((tab) => tab.id).toSet();
    _tabKeys.removeWhere((id, _) => !ids.contains(id));
    _tabLinks.removeWhere((id, _) => !ids.contains(id));
    for (final id in ids) {
      _tabKeys.putIfAbsent(
        id,
        () => GlobalKey(debugLabel: 'semi-chrome-tab-$id'),
      );
      _tabLinks.putIfAbsent(id, LayerLink.new);
    }
  }

  SemiChromeTabLocale _locale(BuildContext context) {
    final explicit = widget.locale;
    if (explicit != null) return explicit;
    final language = Localizations.maybeLocaleOf(context)?.languageCode
        .toLowerCase();
    if (language == 'en') return SemiChromeTabLocale.en;
    if (language == 'ko') return SemiChromeTabLocale.ko;
    return SemiChromeTabLocale.zh;
  }

  _ChromeTabMessages _messages(BuildContext context) =>
      _messagesByLocale[_locale(context)]!;

  // ---------------------------------------------------------------------------
  // Scroll state
  // ---------------------------------------------------------------------------

  void _handleScroll() {
    _updateScrollControls();
    if (_popupEntry != null) _popupRevision.value++;
  }

  void _updateScrollControls() {
    if (!mounted) return;
    if (!_scroll.hasClients) {
      if (_canScrollLeft || _canScrollRight) {
        setState(() {
          _canScrollLeft = false;
          _canScrollRight = false;
        });
      }
      return;
    }
    final position = _scroll.position;
    final left = position.pixels > 1;
    final right = position.pixels < position.maxScrollExtent - 1;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  void _ensureActiveVisible() {
    final activeId = widget.activeTabId;
    if (activeId == null || !mounted) return;
    final viewportBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    final tabBox =
        _tabKeys[activeId]?.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null || tabBox == null || !_scroll.hasClients) return;
    final dx = tabBox.localToGlobal(Offset.zero, ancestor: viewportBox).dx;
    final right = dx + tabBox.size.width;
    final radius = SemiChromeTabTheme.resolve(context).chromeTabRadius + 2;
    final leftControl = _canScrollLeft ? _scrollButtonWidth : 0;
    final rightControl = _canScrollRight ? _scrollButtonWidth : 0;
    final viewportWidth = viewportBox.size.width;
    final position = _scroll.position;
    double? target;
    if (dx - radius < leftControl) {
      target = position.pixels + dx - radius - leftControl;
    } else if (right + radius > viewportWidth - rightControl) {
      target = position.pixels + right + radius + rightControl - viewportWidth;
    }
    if (target == null) return;
    _scroll.jumpTo(
      target
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble(),
    );
  }

  void _settleAddAnchor() {
    final anchor = _pendingAddAnchorX;
    _pendingAddAnchorX = null;
    if (anchor == null || !_scroll.hasClients) return;
    final addBox =
        _addButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (addBox == null) return;
    final current = addBox.localToGlobal(Offset.zero).dx;
    final delta = current - anchor;
    if (delta.abs() < 0.5) return;
    final position = _scroll.position;
    _scroll.jumpTo(
      (position.pixels + delta)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble(),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.maxScrollExtent <= position.minScrollExtent) return;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final target = (position.pixels + delta)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      _scroll.jumpTo(target);
    });
  }

  // ---------------------------------------------------------------------------
  // Interaction state
  // ---------------------------------------------------------------------------

  void _handleTabEnter(SemiChromeTabItem item) {
    _cancelPopupClose();
    if (_hoveredTabId != item.id) {
      setState(() => _hoveredTabId = item.id);
    }
    _maybeShowTooltip(item);
  }

  void _handleTabExit(SemiChromeTabItem item) {
    if (_hoveredTabId == item.id) {
      setState(() => _hoveredTabId = null);
    }
    _schedulePopupClose();
  }

  void _maybeShowTooltip(SemiChromeTabItem item) {
    final mode = widget.tooltipMode;
    if (mode == SemiChromeTabTooltipMode.never) {
      if (_popupKind == _PopupKind.tooltip) _closePopup();
      return;
    }
    final shouldShow =
        mode == SemiChromeTabTooltipMode.always ||
        (_truncated[item.id] ?? false);
    if (!shouldShow) {
      if (_popupKind == _PopupKind.tooltip) _closePopup();
      return;
    }
    Widget? content;
    if (widget.renderTabTooltip != null) {
      content = widget.renderTabTooltip!(item);
      if (content == null) {
        _closePopup();
        return;
      }
    } else {
      content = Text(
        item.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
      );
    }
    final theme = SemiChromeTabTheme.resolve(context);
    _showPopup(
      kind: _PopupKind.tooltip,
      anchorKey: _tabKeys[item.id],
      link: _tabLinks[item.id],
      content: _TooltipBubble(
        theme: theme,
        onEnter: _cancelPopupClose,
        onExit: _schedulePopupClose,
        child: content,
      ),
    );
  }

  void _handleTabTap(SemiChromeTabItem item) {
    _closeAllMenus();
    widget.onTabActivate?.call(item.id);
    if (_pendingTapTabId == item.id) {
      _doubleTapTimer?.cancel();
      _pendingTapTabId = null;
      widget.onTabEditAddress?.call(item.id);
      return;
    }
    _pendingTapTabId = item.id;
    _doubleTapTimer?.cancel();
    _doubleTapTimer = Timer(const Duration(milliseconds: 300), () {
      _pendingTapTabId = null;
    });
  }

  void _requestClose(SemiChromeTabItem item) {
    if (_closingIds.contains(item.id)) return;
    final theme = SemiChromeTabTheme.resolve(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = reduceMotion
        ? const Duration(milliseconds: 1)
        : theme.chromeTabCloseDuration;
    setState(() => _closingIds.add(item.id));
    _closeTimers[item.id]?.cancel();
    _closeTimers[item.id] = Timer(duration, () {
      _closeTimers.remove(item.id);
      if (!mounted) return;
      widget.onTabClose?.call(item.id);
    });
  }

  void _updateDropTarget(String targetId, Offset globalPosition) {
    final box =
        _tabKeys[targetId]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final position = globalPosition.dx < origin.dx + box.size.width / 2
        ? SemiChromeTabReorderPosition.before
        : SemiChromeTabReorderPosition.after;
    if (_dropTargetId == targetId && _dropPosition == position) return;
    setState(() {
      _dropTargetId = targetId;
      _dropPosition = position;
    });
  }

  void _clearDropTarget() {
    if (_dropTargetId == null && _dropPosition == null) return;
    setState(() {
      _dropTargetId = null;
      _dropPosition = null;
    });
  }

  void _scrollBy(double direction) {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final viewportWidth = position.viewportDimension;
    final delta = math.max(160.0, viewportWidth * 0.7) * direction;
    _scroll.animateTo(
      (position.pixels + delta)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble(),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
  }

  // ---------------------------------------------------------------------------
  // Popups
  // ---------------------------------------------------------------------------

  void _showPopup({
    required _PopupKind kind,
    required Widget content,
    GlobalKey? anchorKey,
    LayerLink? link,
    Offset? fixedPosition,
    bool alignRight = false,
    bool barrier = false,
    bool ignorePointer = false,
    double spacing = 6,
    double? topOffset,
  }) {
    _removePopupEntry();
    final revision = _popupRevision;
    _popupKind = kind;
    final entry = OverlayEntry(
      builder: (_) {
        if (fixedPosition != null) {
          return _FixedPopup(
            position: fixedPosition,
            barrier: barrier,
            onDismiss: _closePopup,
            child: content,
          );
        }
        return _AnchoredPopup(
          anchorKey: anchorKey!,
          link: link!,
          revision: revision,
          alignRight: alignRight,
          barrier: barrier,
          ignorePointer: ignorePointer,
          spacing: spacing,
          topOffset: topOffset,
          onDismiss: _closePopup,
          child: content,
        );
      },
    );
    _popupEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    if (mounted) setState(() {});
  }

  void _removePopupEntry() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  void _closePopup({bool refresh = true}) {
    _cancelPopupClose();
    _removePopupEntry();
    _popupKind = null;
    if (refresh && mounted) setState(() {});
  }

  void _closeAllMenus() => _closePopup();

  void _schedulePopupClose() {
    _cancelPopupClose();
    _popupCloseTimer = Timer(
      const Duration(milliseconds: 120),
      () => _closePopup(),
    );
  }

  void _cancelPopupClose() {
    _popupCloseTimer?.cancel();
    _popupCloseTimer = null;
  }

  void _showOverflowMenu(bool left) {
    _cancelPopupClose();
    final hidden = _hiddenTabs(left);
    if (hidden.isEmpty) {
      _closePopup();
      return;
    }
    final theme = SemiChromeTabTheme.resolve(context);
    _showPopup(
      kind: left ? _PopupKind.overflowLeft : _PopupKind.overflowRight,
      anchorKey: left ? _leftScrollKey : _rightScrollKey,
      link: left ? _leftScrollLink : _rightScrollLink,
      alignRight: !left,
      content: _OverflowPopup(
        theme: theme,
        onEnter: _cancelPopupClose,
        onExit: _schedulePopupClose,
        children: <Widget>[
          for (final tab in hidden)
            _OverflowOption(
              theme: theme,
              title: tab.title,
              onTap: () {
                _closePopup();
                widget.onTabActivate?.call(tab.id);
              },
            ),
        ],
      ),
    );
  }

  List<SemiChromeTabItem> _hiddenTabs(bool left) {
    final viewportBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null) return const <SemiChromeTabItem>[];
    final leftControl = _canScrollLeft ? _scrollButtonWidth : 0;
    final rightControl = _canScrollRight ? _scrollButtonWidth : 0;
    final width = viewportBox.size.width;
    final hidden = <SemiChromeTabItem>[];
    for (final tab in widget.tabs) {
      final box =
          _tabKeys[tab.id]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dx = box.localToGlobal(Offset.zero, ancestor: viewportBox).dx;
      final isHidden = left
          ? dx < leftControl
          : dx + box.size.width > width - rightControl;
      if (isHidden) hidden.add(tab);
    }
    return hidden;
  }

  void _toggleGroupMenu() {
    if (_popupKind == _PopupKind.groupMenu) {
      _closePopup();
      return;
    }
    _closeAllMenus();
    final theme = SemiChromeTabTheme.resolve(context);
    final messages = _messages(context);
    _showPopup(
      kind: _PopupKind.groupMenu,
      anchorKey: _groupButtonKey,
      link: _groupLink,
      alignRight: true,
      barrier: true,
      topOffset: 34,
      content: _GroupMenu(
        theme: theme,
        messages: messages,
        groups: widget.groups,
        activeGroupId: widget.activeGroupId,
        onSwitch: (id) {
          _closePopup();
          widget.onGroupSwitch?.call(id);
        },
        onRename: (id) {
          _closePopup();
          widget.onGroupRename?.call(id);
        },
        onDelete: (id) {
          _closePopup();
          widget.onGroupDelete?.call(id);
        },
        onAdd: () {
          _closePopup();
          widget.onGroupAdd?.call();
        },
      ),
    );
  }

  void _openContextMenu(SemiChromeTabItem item, Offset globalPosition) {
    _closeAllMenus();
    final messages = _messages(context);
    final surface = MediaQuery.maybeSizeOf(context) ?? const Size(800, 600);
    final left = math.min(globalPosition.dx, surface.width - _contextMenuWidth);
    final top = math.min(globalPosition.dy, surface.height - 150.0);
    _showPopup(
      kind: _PopupKind.contextMenu,
      fixedPosition: Offset(math.max(0.0, left), math.max(0.0, top)),
      barrier: true,
      content: _ContextMenu(
        theme: SemiChromeTabTheme.resolve(context),
        width: _contextMenuWidth,
        entries: <_ContextMenuEntry>[
          _ContextMenuEntry(messages.close, () {
            _closePopup();
            widget.onTabClose?.call(item.id);
          }),
          _ContextMenuEntry(messages.closeRight, () {
            _closePopup();
            widget.onTabCloseRight?.call(item.id);
          }),
          _ContextMenuEntry(messages.closeOthers, () {
            _closePopup();
            widget.onTabCloseOthers?.call(item.id);
          }),
          _ContextMenuEntry(messages.closeLeft, () {
            _closePopup();
            widget.onTabCloseLeft?.call(item.id);
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _syncTabKeys();
    final theme = SemiChromeTabTheme.resolve(context);
    final strip = MouseRegion(
      cursor: SystemMouseCursors.basic,
      onExit: (_) {},
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.chromeTabsBackground),
        child: SizedBox(
          height: theme.chromeTabsHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      _buildViewport(context, theme, constraints.maxWidth),
                ),
              ),
              if (!widget.hideGroupButton) _buildGroupButton(context, theme),
            ],
          ),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollControls();
    });
    return Semantics(container: true, explicitChildNodes: true, child: strip);
  }

  Widget _buildViewport(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    double viewportWidth,
  ) {
    final tabs = widget.tabs;
    final addVisible = !widget.hideAddButton;
    final extraWidth = addVisible
        ? _addSlotWidth + (tabs.isEmpty ? 0 : _dividerWidth)
        : 0.0;
    final available = math.max(0.0, viewportWidth - extraWidth);
    final naturalWidth = tabs.isEmpty
        ? 0.0
        : (available / tabs.length)
              .clamp(theme.chromeTabMinWidth, theme.chromeTabMaxWidth)
              .toDouble();
    final widths = <String, double>{
      for (final tab in tabs) tab.id: naturalWidth,
    };
    for (final tab in tabs) {
      _truncated[tab.id] = _isTitleTruncated(
        context,
        tab,
        widths[tab.id]!,
        _hasIcon(tab),
        theme,
      );
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (var index = 0; index < tabs.length; index++)
          SizedBox(
            key: ValueKey<String>('semi-chrome-tab-${tabs[index].id}'),
            width: widths[tabs[index].id]!,
            height: theme.chromeTabHeight,
            child: _buildTab(
              context,
              theme,
              tabs[index],
              index,
              widths[tabs[index].id]!,
            ),
          ),
        if (addVisible) ...<Widget>[
          if (tabs.isNotEmpty)
            SizedBox(
              width: _dividerWidth,
              height: theme.chromeTabHeight,
              child: Center(
                child: Opacity(
                  opacity: _newTabDividerVisible ? 1 : 0,
                  child: _dividerPill(theme),
                ),
              ),
            ),
          SizedBox(
            width: _addSlotWidth,
            height: theme.chromeTabHeight,
            child: Center(
              child: _AddButton(
                key: _addButtonKey,
                theme: theme,
                messages: _messages(context),
                onPointerDown: _handleAddPointerDown,
                onTap: () {
                  _closeAllMenus();
                  widget.onTabAdd?.call();
                },
              ),
            ),
          ),
        ],
      ],
    );

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: !widget.hideScrollbar),
              child: SingleChildScrollView(
                key: _viewportKey,
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: row,
              ),
            ),
          ),
          if (_canScrollLeft)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _ScrollButton(
                key: _leftScrollKey,
                link: _leftScrollLink,
                theme: theme,
                label: _messages(context).scrollLeft,
                icon: SemiIcons.chevronLeft,
                shadowOffset: const Offset(4, 0),
                onHoverChanged: (hovered) {
                  if (hovered) {
                    _showOverflowMenu(true);
                  } else {
                    _schedulePopupClose();
                  }
                },
                onTap: () {
                  _closePopup();
                  _scrollBy(-1);
                },
              ),
            ),
          if (_canScrollRight)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _ScrollButton(
                key: _rightScrollKey,
                link: _rightScrollLink,
                theme: theme,
                label: _messages(context).scrollRight,
                icon: SemiIcons.chevronRight,
                shadowOffset: const Offset(-4, 0),
                onHoverChanged: (hovered) {
                  if (hovered) {
                    _showOverflowMenu(false);
                  } else {
                    _schedulePopupClose();
                  }
                },
                onTap: () {
                  _closePopup();
                  _scrollBy(1);
                },
              ),
            ),
        ],
      ),
    );
  }

  bool get _newTabDividerVisible {
    final tabs = widget.tabs;
    if (tabs.isEmpty) return false;
    final lastId = tabs.last.id;
    return lastId != widget.activeTabId && lastId != _hoveredTabId;
  }

  bool _hasIcon(SemiChromeTabItem tab) =>
      widget.renderTabIcon?.call(tab) != null || tab.icon != null;

  bool _isTitleTruncated(
    BuildContext context,
    SemiChromeTabItem tab,
    double tabWidth,
    bool hasIcon,
    SemiResolvedChromeTabThemeData theme,
  ) {
    final available = math.max(
      0.0,
      tabWidth - 8 - 12 - (hasIcon ? _iconSize + _iconGap : 0),
    );
    final painter = TextPainter(
      text: TextSpan(
        text: tab.title,
        style: TextStyle(fontSize: theme.chromeTabsFontSize),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      ellipsis: '…',
    )..layout(maxWidth: available);
    return painter.didExceedMaxLines;
  }

  Widget _buildTab(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    SemiChromeTabItem tab,
    int index,
    double width,
  ) {
    final active = tab.id == widget.activeTabId;
    final hovered = tab.id == _hoveredTabId;
    final closing = _closingIds.contains(tab.id);
    final entering = _enteringIds.contains(tab.id);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final textColor = active
        ? theme.chromeTabActiveTextColor
        : theme.chromeTabTextColor;
    final activeBackground =
        tab.backgroundColor ?? theme.chromeTabActiveBackground;
    final icon = widget.renderTabIcon?.call(tab) ?? tab.icon;

    final surface = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (active)
          Positioned.fill(
            child: CustomPaint(
              painter: _ActiveTabBackgroundPainter(
                color: activeBackground,
                radius: theme.chromeTabRadius + 2,
              ),
            ),
          ),
        if (!active && hovered)
          Positioned(
            left: 3,
            right: 3,
            top: 5,
            bottom: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.chromeTabHoverBackground,
                borderRadius: BorderRadius.circular(theme.chromeTabRadius),
              ),
            ),
          ),
        if (_dividerVisible(index))
          Positioned(
            right: 0,
            top: (theme.chromeTabHeight - _dividerHeight) / 2,
            width: _dividerWidth,
            height: _dividerHeight,
            child: _dividerPill(theme),
          ),
        Positioned(
          left: 4,
          right: 4,
          top: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: IconTheme(
                      data: IconThemeData(color: textColor, size: _iconSize),
                      child: icon,
                    ),
                  ),
                  const SizedBox(width: _iconGap),
                ],
                Expanded(
                  child: Text(
                    tab.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.chromeTabsFontSize,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hovered)
          Positioned(
            right: 4,
            top: (theme.chromeTabHeight - 18) / 2,
            width: 30,
            height: 18,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      (active
                              ? activeBackground
                              : theme.chromeTabHoverBackground)
                          .withValues(alpha: 0),
                      active
                          ? activeBackground
                          : theme.chromeTabHoverBackground,
                    ],
                    stops: const <double>[0, 0.8],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 4,
          top: (theme.chromeTabHeight - _closeButtonSize) / 2,
          child: IgnorePointer(
            ignoring: !hovered,
            child: Opacity(
              opacity: hovered ? 1 : 0,
              child: Semantics(
                button: true,
                label: '${_messages(context).close} ${tab.title}',
                child: _CloseButton(
                  key: ValueKey<String>('semi-chrome-tab-close-${tab.id}'),
                  theme: theme,
                  color: theme.chromeTabTextColor,
                  onTap: () => _requestClose(tab),
                ),
              ),
            ),
          ),
        ),
        if (_dropTargetId == tab.id)
          Positioned(
            left: _dropPosition == SemiChromeTabReorderPosition.before
                ? 0
                : null,
            right: _dropPosition == SemiChromeTabReorderPosition.after
                ? 0
                : null,
            top: 5,
            bottom: 5,
            width: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.chromeTabsAccentColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
      ],
    );

    Widget tabContent = surface;
    if (closing) {
      tabContent = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1, end: 0),
        duration: reduceMotion
            ? const Duration(milliseconds: 1)
            : theme.chromeTabCloseDuration,
        curve: Curves.easeIn,
        child: tabContent,
        builder: (context, value, child) => Opacity(
          key: ValueKey<String>('semi-chrome-tab-closing-${tab.id}'),
          opacity: value,
          child: Transform.scale(scaleX: 0.88 + 0.12 * value, child: child),
        ),
      );
    } else if (entering) {
      tabContent = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: reduceMotion
            ? const Duration(milliseconds: 1)
            : theme.chromeTabEnterDuration,
        curve: Curves.easeOut,
        onEnd: () {
          if (!mounted) return;
          if (_enteringIds.remove(tab.id)) setState(() {});
        },
        child: tabContent,
        builder: (context, value, child) => Opacity(
          key: ValueKey<String>('semi-chrome-tab-entering-${tab.id}'),
          opacity: value,
          child: Transform.scale(scaleX: 0.88 + 0.12 * value, child: child),
        ),
      );
    }

    Widget interactive = MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => _handleTabEnter(tab),
      onExit: (_) => _handleTabExit(tab),
      child: CompositedTransformTarget(
        link: _tabLinks[tab.id]!,
        child: DragTarget<String>(
          onWillAcceptWithDetails: (details) => details.data != tab.id,
          onMove: (details) => _updateDropTarget(tab.id, details.offset),
          onLeave: (_) {
            if (_dropTargetId == tab.id) _clearDropTarget();
          },
          onAcceptWithDetails: (details) {
            final position = _dropPosition;
            _clearDropTarget();
            if (details.data == tab.id || position == null) return;
            widget.onTabReorder?.call(
              SemiChromeTabReorderInfo(
                tabId: details.data,
                targetTabId: tab.id,
                position: position,
              ),
            );
          },
          builder: (context, _, _) => Draggable<String>(
            data: tab.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: _closeAllMenus,
            onDragEnd: (_) => _clearDropTarget(),
            feedback: _dragFeedback(context, theme, tab, width),
            childWhenDragging: Opacity(opacity: 0.45, child: tabContent),
            child: Semantics(
              button: true,
              selected: active,
              label: tab.title,
              onTap: () => _handleTabTap(tab),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTap: () => _handleTabTap(tab),
                onSecondaryTapDown: (details) =>
                    _openContextMenu(tab, details.globalPosition),
                onLongPressStart: (details) =>
                    _openContextMenu(tab, details.globalPosition),
                child: tabContent,
              ),
            ),
          ),
        ),
      ),
    );

    if (closing) interactive = IgnorePointer(child: interactive);
    return SizedBox(
      key: _tabKeys[tab.id],
      width: width,
      height: theme.chromeTabHeight,
      child: interactive,
    );
  }

  bool _dividerVisible(int index) {
    final tabs = widget.tabs;
    final id = tabs[index].id;
    if (id == widget.activeTabId || id == _hoveredTabId) return false;
    final next = index + 1 < tabs.length ? tabs[index + 1] : null;
    if (next != null &&
        (next.id == widget.activeTabId || next.id == _hoveredTabId)) {
      return false;
    }
    return next != null || widget.hideAddButton;
  }

  Widget _dragFeedback(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    SemiChromeTabItem tab,
    double width,
  ) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: SizedBox(
        width: width,
        height: theme.chromeTabHeight,
        child: Opacity(
          opacity: 0.9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.chromeTabActiveBackground,
              borderRadius: BorderRadius.circular(theme.chromeTabRadius),
              boxShadow: theme.chromeTabsMenuShadow.toBoxShadows(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  tab.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: theme.chromeTabsFontSize,
                    color: theme.chromeTabActiveTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dividerPill(SemiResolvedChromeTabThemeData theme) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.chromeTabDividerColor,
      borderRadius: BorderRadius.circular(999),
    ),
    child: const SizedBox(width: _dividerWidth, height: _dividerHeight),
  );

  Widget _buildGroupButton(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
  ) {
    final open = _popupKind == _PopupKind.groupMenu;
    final messages = _messages(context);
    return Padding(
      padding: const EdgeInsets.only(right: _groupContentPaddingRight),
      child: Center(
        child: CompositedTransformTarget(
          link: _groupLink,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _groupHovered = true),
            onExit: (_) => setState(() => _groupHovered = false),
            child: GestureDetector(
              onTap: _toggleGroupMenu,
              child: Semantics(
                button: true,
                label: messages.selectGroup,
                child: Container(
                  key: _groupButtonKey,
                  width: _groupButtonSize,
                  height: _groupButtonSize,
                  decoration: BoxDecoration(
                    color: open || _groupHovered
                        ? theme.chromeTabsMenuHoverBackground
                        : theme.chromeTabsMenuIconBackground,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: SemiIcon(
                      SemiIcons.chevronDown,
                      customSize: _iconSize,
                      color: theme.chromeTabsMenuIconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAddPointerDown() {
    if (widget.tabs.length < 5) return;
    final lastTab = widget.tabs.last;
    final box =
        _tabKeys[lastTab.id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    _pendingAddAnchorX = box.localToGlobal(Offset.zero).dx + box.size.width;
  }
}

// -----------------------------------------------------------------------------
// Popup plumbing
// -----------------------------------------------------------------------------

enum _PopupKind { tooltip, overflowLeft, overflowRight, contextMenu, groupMenu }

class _AnchoredPopup extends StatefulWidget {
  const _AnchoredPopup({
    required this.anchorKey,
    required this.link,
    required this.revision,
    required this.child,
    required this.alignRight,
    required this.barrier,
    required this.ignorePointer,
    required this.spacing,
    required this.onDismiss,
    this.topOffset,
  });

  final GlobalKey anchorKey;
  final LayerLink link;
  final ValueNotifier<int> revision;
  final Widget child;
  final bool alignRight;
  final bool barrier;
  final bool ignorePointer;
  final double spacing;
  final double? topOffset;
  final VoidCallback onDismiss;

  @override
  State<_AnchoredPopup> createState() => _AnchoredPopupState();
}

class _AnchoredPopupState extends State<_AnchoredPopup> {
  final GlobalKey _contentKey = GlobalKey();
  Offset _offset = const Offset(0, -10000);
  Size? _measuredSize;

  @override
  void initState() {
    super.initState();
    widget.revision.addListener(_measure);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant _AnchoredPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) {
      oldWidget.revision.removeListener(_measure);
      widget.revision.addListener(_measure);
    }
  }

  @override
  void dispose() {
    widget.revision.removeListener(_measure);
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    final contentBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    final anchorBox =
        widget.anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (contentBox == null || anchorBox == null || !contentBox.hasSize) return;
    final size = contentBox.size;
    final anchorRect = anchorBox.localToGlobal(Offset.zero) & anchorBox.size;
    final surface = MediaQuery.maybeSizeOf(context) ?? const Size(800, 600);
    final desiredLeft = widget.alignRight
        ? anchorRect.right - size.width
        : anchorRect.left;
    final left = desiredLeft
        .clamp(8.0, math.max(8.0, surface.width - size.width - 8))
        .toDouble();
    double top;
    if (widget.topOffset != null) {
      top = anchorRect.top + widget.topOffset!;
    } else {
      top = anchorRect.bottom + widget.spacing;
      if (top + size.height > surface.height - 8) {
        top = anchorRect.top - size.height - widget.spacing;
      }
    }
    top = top
        .clamp(8.0, math.max(8.0, surface.height - size.height - 8))
        .toDouble();
    final offset = Offset(left, top) - anchorRect.topLeft;
    if (offset != _offset || size != _measuredSize) {
      setState(() {
        _offset = offset;
        _measuredSize = size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Opacity(
      opacity: _measuredSize == null ? 0 : 1,
      child: KeyedSubtree(key: _contentKey, child: widget.child),
    );
    if (widget.ignorePointer || _measuredSize == null) {
      content = IgnorePointer(child: content);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (widget.barrier)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => widget.onDismiss(),
            ),
          ),
        Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            offset: _offset,
            child: content,
          ),
        ),
      ],
    );
  }
}

class _FixedPopup extends StatelessWidget {
  const _FixedPopup({
    required this.position,
    required this.barrier,
    required this.onDismiss,
    required this.child,
  });

  final Offset position;
  final bool barrier;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (barrier)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => onDismiss(),
            ),
          ),
        Positioned(left: position.dx, top: position.dy, child: child),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Tab internals
// -----------------------------------------------------------------------------

class _ActiveTabBackgroundPainter extends CustomPainter {
  const _ActiveTabBackgroundPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 2.0;
    final right = size.width - 2.0;
    final top = 4.0;
    final bottom = size.height;
    final r = radius;
    final path = Path()
      ..moveTo(left - r, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - r)
      ..lineTo(left, top + r)
      ..quadraticBezierTo(left, top, left + r, top)
      ..lineTo(right - r, top)
      ..quadraticBezierTo(right, top, right, top + r)
      ..lineTo(right, bottom - r)
      ..quadraticBezierTo(right, bottom, right + r, bottom)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ActiveTabBackgroundPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}

class _CloseButton extends StatefulWidget {
  const _CloseButton({
    super.key,
    required this.theme,
    required this.color,
    required this.onTap,
  });

  final SemiResolvedChromeTabThemeData theme;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? widget.theme.chromeTabCloseHoverBackground
                : const Color(0x00000000),
          ),
          child: CustomPaint(painter: _CloseGlyphPainter(color: widget.color)),
        ),
      ),
    );
  }
}

class _CloseGlyphPainter extends CustomPainter {
  const _CloseGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final center = size.center(Offset.zero);
    const half = 4.5;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(math.pi / 4)
      ..drawLine(const Offset(-half, 0), const Offset(half, 0), paint)
      ..restore()
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(-math.pi / 4)
      ..drawLine(const Offset(-half, 0), const Offset(half, 0), paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_CloseGlyphPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _ScrollButton extends StatefulWidget {
  const _ScrollButton({
    super.key,
    required this.link,
    required this.theme,
    required this.label,
    required this.icon,
    required this.shadowOffset,
    required this.onHoverChanged,
    required this.onTap,
  });

  final LayerLink link;
  final SemiResolvedChromeTabThemeData theme;
  final String label;
  final SemiIconData icon;
  final Offset shadowOffset;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  @override
  State<_ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<_ScrollButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return CompositedTransformTarget(
      link: widget.link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hovered = true);
          widget.onHoverChanged(true);
        },
        onExit: (_) {
          setState(() => _hovered = false);
          widget.onHoverChanged(false);
        },
        child: Semantics(
          button: true,
          label: widget.label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onTap,
            child: Container(
              width: _SemiChromeTabState._scrollButtonWidth,
              decoration: BoxDecoration(
                color: theme.chromeTabsBackground,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0x1f3c4043),
                    offset: widget.shadowOffset,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? theme.chromeTabActiveBackground
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SemiIcon(
                      widget.icon,
                      customSize: _SemiChromeTabState._iconSize,
                      color: _hovered
                          ? theme.chromeTabsAccentColor
                          : theme.chromeTabTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({
    super.key,
    required this.theme,
    required this.messages,
    required this.onPointerDown,
    required this.onTap,
  });

  final SemiResolvedChromeTabThemeData theme;
  final _ChromeTabMessages messages;
  final VoidCallback onPointerDown;
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.messages.addTab,
      tooltip: widget.messages.addTabTitle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Listener(
          onPointerDown: (_) => widget.onPointerDown(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onTap,
            child: Container(
              width: _SemiChromeTabState._addButtonSize,
              height: _SemiChromeTabState._addButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hovered
                    ? const Color(0x14000000)
                    : const Color(0x00000000),
              ),
              alignment: Alignment.center,
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 22,
                  height: 1,
                  color: widget.theme.chromeTabTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Menus and overlays
// -----------------------------------------------------------------------------

class _GroupMenu extends StatefulWidget {
  const _GroupMenu({
    required this.theme,
    required this.messages,
    required this.groups,
    required this.activeGroupId,
    required this.onSwitch,
    required this.onRename,
    required this.onDelete,
    required this.onAdd,
  });

  final SemiResolvedChromeTabThemeData theme;
  final _ChromeTabMessages messages;
  final List<SemiChromeTabGroup> groups;
  final String? activeGroupId;
  final ValueChanged<String> onSwitch;
  final ValueChanged<String> onRename;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;

  @override
  State<_GroupMenu> createState() => _GroupMenuState();
}

class _GroupMenuState extends State<_GroupMenu> {
  String? _hoveredGroupId;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Container(
      width: _SemiChromeTabState._groupMenuWidth,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.chromeTabsMenuBackground,
        borderRadius: BorderRadius.circular(_SemiChromeTabState._menuRadius),
        border: Border.all(color: theme.chromeTabsMenuBorderColor),
        boxShadow: theme.chromeTabsMenuShadow.toBoxShadows(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final group in widget.groups)
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredGroupId = group.id),
              onExit: (_) => setState(() => _hoveredGroupId = null),
              child: _groupRow(context, theme, group),
            ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(_SemiChromeTabState._menuSeparator),
                ),
              ),
            ),
            child: _MenuButton(
              onTap: widget.onAdd,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              borderRadius: BorderRadius.circular(5),
              hoverColor: theme.chromeTabsMenuHoverBackground,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                widget.messages.addGroup,
                style: TextStyle(color: theme.chromeTabsMenuTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupRow(
    BuildContext context,
    SemiResolvedChromeTabThemeData theme,
    SemiChromeTabGroup group,
  ) {
    final active = group.id == widget.activeGroupId;
    final hovered = _hoveredGroupId == group.id;
    return Stack(
      children: <Widget>[
        _MenuButton(
          onTap: () => widget.onSwitch(group.id),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          borderRadius: BorderRadius.circular(5),
          hoverColor: theme.chromeTabsMenuHoverBackground,
          forceHover: hovered || active,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            group.name,
            style: TextStyle(
              color: active
                  ? theme.chromeTabsAccentColor
                  : theme.chromeTabsMenuTextColor,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        if (hovered)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(5),
                  topEnd: Radius.circular(5),
                ),
                gradient: LinearGradient(
                  colors: <Color>[
                    theme.chromeTabsMenuHoverBackground.withValues(alpha: 0),
                    theme.chromeTabsMenuHoverBackground,
                  ],
                  stops: const <double>[0, 0.22],
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _RowAction(
                      icon: SemiIcons.editStroked,
                      theme: theme,
                      label: '${widget.messages.rename} ${group.name}',
                      onTap: () => widget.onRename(group.id),
                    ),
                    _RowAction(
                      icon: SemiIcons.deleteStroked,
                      theme: theme,
                      label: '${widget.messages.delete} ${group.name}',
                      onTap: () => widget.onDelete(group.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RowAction extends StatefulWidget {
  const _RowAction({
    required this.icon,
    required this.theme,
    required this.label,
    required this.onTap,
  });

  final SemiIconData icon;
  final SemiResolvedChromeTabThemeData theme;
  final String label;
  final VoidCallback onTap;

  @override
  State<_RowAction> createState() => _RowActionState();
}

class _RowActionState extends State<_RowAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onTap,
          child: Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hovered
                  ? widget.theme.chromeTabCloseHoverBackground
                  : const Color(0x00000000),
            ),
            child: Center(
              child: SemiIcon(
                widget.icon,
                customSize: 15,
                color: widget.theme.chromeTabsMenuIconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextMenuEntry {
  const _ContextMenuEntry(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;
}

class _ContextMenu extends StatelessWidget {
  const _ContextMenu({
    required this.theme,
    required this.width,
    required this.entries,
  });

  final SemiResolvedChromeTabThemeData theme;
  final double width;
  final List<_ContextMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.chromeTabsMenuBackground,
        borderRadius: BorderRadius.circular(_SemiChromeTabState._menuRadius),
        border: Border.all(color: theme.chromeTabsMenuBorderColor),
        boxShadow: theme.chromeTabsMenuShadow.toBoxShadows(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < entries.length; index++)
            Container(
              margin: index == 0
                  ? const EdgeInsets.only(bottom: 4)
                  : EdgeInsets.zero,
              decoration: index == 0
                  ? const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(_SemiChromeTabState._menuSeparator),
                        ),
                      ),
                    )
                  : null,
              child: _MenuButton(
                onTap: entries[index].onTap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                borderRadius: BorderRadius.circular(5),
                hoverColor: theme.chromeTabsMenuHoverBackground,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  entries[index].label,
                  style: TextStyle(color: theme.chromeTabsMenuTextColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.onTap,
    required this.padding,
    required this.borderRadius,
    required this.hoverColor,
    required this.alignment,
    required this.child,
    this.forceHover = false,
  });

  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color hoverColor;
  final AlignmentGeometry alignment;
  final Widget child;
  final bool forceHover;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hovered = _hovered || widget.forceHover;
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onTap,
          child: Container(
            width: double.infinity,
            padding: widget.padding,
            alignment: widget.alignment,
            decoration: BoxDecoration(
              color: hovered ? widget.hoverColor : const Color(0x00000000),
              borderRadius: widget.borderRadius,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _OverflowPopup extends StatelessWidget {
  const _OverflowPopup({
    required this.theme,
    required this.onEnter,
    required this.onExit,
    required this.children,
  });

  final SemiResolvedChromeTabThemeData theme;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final surface = MediaQuery.maybeSizeOf(context) ?? const Size(800, 600);
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: math.min(240.0, surface.width - 16),
          maxWidth: math.min(240.0, surface.width - 16),
          maxHeight: math.min(320.0, surface.height - 16),
        ),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.chromeTabsMenuBackground,
            borderRadius: BorderRadius.circular(
              _SemiChromeTabState._tooltipRadius,
            ),
            border: Border.all(color: theme.chromeTabsMenuBorderColor),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverflowOption extends StatelessWidget {
  const _OverflowOption({
    required this.theme,
    required this.title,
    required this.onTap,
  });

  final SemiResolvedChromeTabThemeData theme;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _MenuButton(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: BorderRadius.circular(7),
      hoverColor: theme.chromeTabsMenuHoverBackground,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: theme.chromeTabsFontSize,
          color: theme.chromeTabsMenuTextColor,
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    required this.theme,
    required this.onEnter,
    required this.onExit,
    required this.child,
  });

  final SemiResolvedChromeTabThemeData theme;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = MediaQuery.maybeSizeOf(context) ?? const Size(800, 600);
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(360.0, surface.width - 16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.chromeTabsTooltipBackground,
            borderRadius: BorderRadius.circular(
              _SemiChromeTabState._tooltipRadius,
            ),
            border: Border.all(color: theme.chromeTabsTooltipBorderColor),
            boxShadow: theme.chromeTabsTooltipShadow.toBoxShadows(),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: theme.chromeTabsTooltipTextColor),
            child: child,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Localization
// -----------------------------------------------------------------------------

class _ChromeTabMessages {
  const _ChromeTabMessages({
    required this.close,
    required this.addTab,
    required this.addTabTitle,
    required this.selectGroup,
    required this.rename,
    required this.delete,
    required this.addGroup,
    required this.closeLeft,
    required this.closeRight,
    required this.closeOthers,
    required this.scrollLeft,
    required this.scrollRight,
  });

  final String close;
  final String addTab;
  final String addTabTitle;
  final String selectGroup;
  final String rename;
  final String delete;
  final String addGroup;
  final String closeLeft;
  final String closeRight;
  final String closeOthers;
  final String scrollLeft;
  final String scrollRight;
}

const Map<SemiChromeTabLocale, _ChromeTabMessages> _messagesByLocale =
    <SemiChromeTabLocale, _ChromeTabMessages>{
      SemiChromeTabLocale.zh: _ChromeTabMessages(
        close: '关闭',
        addTab: '添加标签页',
        addTabTitle: '添加标签页后，可再次打开同一个模块',
        selectGroup: '选择分组',
        rename: '重命名',
        delete: '删除',
        addGroup: '＋ 新建分组',
        closeLeft: '关闭左侧所有',
        closeRight: '关闭右侧所有',
        closeOthers: '关闭其他所有',
        scrollLeft: '向左滚动标签',
        scrollRight: '向右滚动标签',
      ),
      SemiChromeTabLocale.en: _ChromeTabMessages(
        close: 'Close',
        addTab: 'Add tab',
        addTabTitle: 'Add a tab to open the same module again',
        selectGroup: 'Select group',
        rename: 'Rename',
        delete: 'Delete',
        addGroup: '＋ New group',
        closeLeft: 'Close all to the left',
        closeRight: 'Close all to the right',
        closeOthers: 'Close other tabs',
        scrollLeft: 'Scroll tabs left',
        scrollRight: 'Scroll tabs right',
      ),
      SemiChromeTabLocale.ko: _ChromeTabMessages(
        close: '닫기',
        addTab: '탭 추가',
        addTabTitle: '탭을 추가하면 같은 모듈을 다시 열 수 있습니다',
        selectGroup: '그룹 선택',
        rename: '이름 변경',
        delete: '삭제',
        addGroup: '＋ 새 그룹',
        closeLeft: '왼쪽 탭 모두 닫기',
        closeRight: '오른쪽 탭 모두 닫기',
        closeOthers: '다른 탭 모두 닫기',
        scrollLeft: '탭을 왼쪽으로 스크롤',
        scrollRight: '탭을 오른쪽으로 스크롤',
      ),
    };
