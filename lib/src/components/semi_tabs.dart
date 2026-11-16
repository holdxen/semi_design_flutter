// SemiTabs — 上游 packages/semi-ui/tabs/{index.tsx,TabBar.tsx,TabItem.tsx,
// TabPane.tsx} 与 packages/semi-foundation/tabs/{tabs.scss,foundation.ts} 的移植。
//
// 主题对账 **144 = 121 FIELDS + 23 MOTION + 0 INTERNAL**（variables.scss 121
// 声明 + animation.scss 23 声明；`$module`/`$ignoreIcon` 胶水与 rtl.scss 不计；
// datePicker `223 = 220 + 3 + 0` … steps `104 = 94 + 10 + 0`、upload
// `85 = 85 + 0 + 0`、skeleton `17 = 15 + 2 + 0` 先例）。★9 死变量（theme 注释
// 「上游未消费」）：线条式页签三个背景、选中背景/选中图标色、箭头 hover/active
// 背景、tabPanel topShow/bottomShow 位移（keyframes 误用 leftShow/rightShow）。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - index.tsx:73 `showRestInDropdown = true`；:76 `arrowPosition = 'both'`
// - constants.ts `DEFAULT_ACTIVE_KEY: 1`；locale `more: '更多'` / `close: '关闭'`
// - TabBar.tsx `IconChevronDown` / `IconChevronLeft` / `IconChevronRight`；
//   TabItem.tsx `IconClose`
// - TabItem.tsx `data-tabkey` / `aria-selected` / `tabIndex={selected ? 0 : -1}`
// - TabPane.tsx `semi-tabs-pane-motion-overlay`
// - tabs.scss:80 `@include font-size-regular`（页签字号 14）
// - tabs.scss:348 `:nth-of-type(1)`（首项 padding 置 0）
// - tabs.scss:124 关闭图标 `margin-left: 10px`
// - rtl.scss:33 `transform: scaleX(-1)`（RTL 箭头翻转）
// - tabs.scss:690 `translateY($animation_transform_translateX-tabs_tabPanel-leftShow)`
//   （topShow/bottomShow keyframes 误用 left/right 变量 —— 上游 quirk）
// - tabs.scss:672 `animation-fill-mode: forwards`
// - tabs.scss:615 斜线分割 `linear-gradient(to bottom right, ...)`
// - tabs.scss:235 `overflow-y: auto`（折叠下拉最大高 300）
// - tabs.scss:612 slash `content: ""` 伪元素
// - tabs.scss:452 卡片左侧选中 `width: 1px`（::after 遮住轨道线）
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_tabs_theme.dart';
import '../theme/semi_tabs_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import '../tokens/token_types.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_dropdown.dart';
import 'semi_tooltip.dart';

/// 页签形态（上游 `type: 'line' | 'card' | 'button' | 'slash'`，缺省 line）。
enum SemiTabsType { line, card, button, slash }

/// 尺寸（上游 `size: 'small' | 'medium' | 'large'`，缺省 large）。
enum SemiTabsSize { small, medium, large }

/// 方向（上游 `tabPosition: 'top' | 'left'`，缺省 top）。
enum SemiTabsPosition { top, left }

/// 单个页签（index.tsx `PlainTab` + TabPane children）。
class SemiTabData {
  const SemiTabData({
    required this.itemKey,
    this.tab,
    this.icon,
    this.disabled = false,
    this.closable = false,
    this.content,
  });

  /// 唯一键。
  final String itemKey;

  /// 标签内容：String | Widget。
  final Object? tab;

  /// 前置图标。
  final Widget? icon;

  /// 禁用（不响应点击，禁用色）。
  final bool disabled;

  /// 显示关闭按钮（点击回调 [SemiTabs.onTabClose]，不自动删项——上游同）。
  final bool closable;

  /// 页签内容。
  final Widget? content;
}

/// 页签（Semi Tabs）。
///
/// 四形态（line/card/button/slash）× 三尺寸 × 上/左两个方向；受控
/// [activeKey] / 非受控 [defaultActiveKey]（缺省首个非禁用项）。`collapsible`
/// 在 Flutter 端映射为横条滚动 + 两端箭头（上游 OverflowList 是溢出折叠 +
/// 下拉，差异见 docs）；`more` 是上游「保留前 N 项 + 更多下拉」形态。
/// 键盘：左右/上下箭头移动焦点（基础 TabItem focus 语义）、Enter/Space 选中、
/// Delete/Backspace 关闭可关闭项（foundation.ts:76-132）。
class SemiTabs extends StatefulWidget {
  const SemiTabs({
    super.key,
    this.tabList = const <SemiTabData>[],
    this.activeKey,
    this.defaultActiveKey,
    this.type = SemiTabsType.line,
    this.size = SemiTabsSize.large,
    this.tabPosition = SemiTabsPosition.top,
    this.collapsible = false,
    this.more,
    this.renderMoreTrigger,
    this.tabBarExtraContent,
    this.tabPaneMotion = true,
    this.keepDOM = true,
    this.lazyRender = false,
    this.onChange,
    this.onTabClick,
    this.onTabClose,
  }) : assert(more == null || more >= 0, 'more must be >= 0');

  /// 页签列表。
  final List<SemiTabData> tabList;

  /// 受控选中键；非 null 即受控（点击只回调，不内部切换）。
  final String? activeKey;

  /// 非受控初始选中键。
  final String? defaultActiveKey;

  final SemiTabsType type;
  final SemiTabsSize size;
  final SemiTabsPosition tabPosition;

  /// 横条滚动 + 两端箭头（上游 `collapsible: true | 'auto'`；`'auto'` 未移植，
  /// 二者在此等价）。
  final bool collapsible;

  /// 上游 `more: number` —— 保留前 `list.length - more` 项，其余收进「更多」
  /// 下拉。
  final int? more;

  /// 上游 `more.render` —— 自定义「更多」触发器。
  final Widget Function()? renderMoreTrigger;

  /// 右侧附加内容（`tabBarExtraContent`）。
  final Widget? tabBarExtraContent;

  /// 页签切换动效（TabPane 200ms 位移 + 淡入，`tabPaneMotion`）。
  final bool tabPaneMotion;

  /// 保留所有 pane 的 DOM（`keepDOM`，上游缺省 true）。
  final bool keepDOM;

  /// 只渲染访问过的 pane（`lazyRender`，上游缺省 false）。
  final bool lazyRender;

  /// 选中变化（仅变化时回调）。
  final ValueChanged<String>? onChange;

  /// 点击页签（含已选中项；禁用项不触发）。
  final ValueChanged<String>? onTabClick;

  /// 关闭（`closable` 页签的关闭按钮/Delete 键；不自动删项）。
  final ValueChanged<String>? onTabClose;

  @override
  State<SemiTabs> createState() => _SemiTabsState();
}

class _SemiTabsState extends State<SemiTabs> {
  String? _activeKey;
  String? _prevActiveKey;
  final Set<String> _visited = <String>{};
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  final ScrollController _scroll = ScrollController();
  bool _canScrollStart = false;
  bool _canScrollEnd = false;

  @override
  void initState() {
    super.initState();
    _activeKey = _initialKey();
    if (_activeKey != null) _visited.add(_activeKey!);
    _scroll.addListener(_syncScrollArrows);
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(SemiTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeKey != null && widget.activeKey != oldWidget.activeKey) {
      _prevActiveKey = _activeKey;
      _activeKey = widget.activeKey;
      _visited.add(widget.activeKey!);
    }
    if (!_sameKeys(oldWidget.tabList, widget.tabList)) {
      _syncFocusNodes();
      if (widget.activeKey == null && !_hasKey(widget.tabList, _activeKey)) {
        _prevActiveKey = _activeKey;
        _activeKey = _firstEnabledKey();
        if (_activeKey != null) _visited.add(_activeKey!);
      }
    }
    if (widget.activeKey == null && !_hasKey(widget.tabList, _activeKey)) {
      _prevActiveKey = _activeKey;
      _activeKey = _firstEnabledKey();
      if (_activeKey != null) _visited.add(_activeKey!);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  bool _hasKey(List<SemiTabData> list, String? key) =>
      key != null && list.any((tab) => tab.itemKey == key);

  bool _sameKeys(List<SemiTabData> a, List<SemiTabData> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every(
        (i) =>
            a[i].itemKey == b[i].itemKey &&
            a[i].disabled == b[i].disabled &&
            a[i].closable == b[i].closable,
      );

  String? _firstEnabledKey() {
    for (final tab in widget.tabList) {
      if (!tab.disabled) return tab.itemKey;
    }
    return null;
  }

  String? _initialKey() {
    if (widget.activeKey != null) return widget.activeKey;
    if (widget.defaultActiveKey != null) return widget.defaultActiveKey;
    return _firstEnabledKey();
  }

  void _syncFocusNodes() {
    final keys = widget.tabList.map((tab) => tab.itemKey).toSet();
    _focusNodes.removeWhere((key, node) {
      if (keys.contains(key)) return false;
      node.dispose();
      return true;
    });
    for (final tab in widget.tabList) {
      _focusNodes.putIfAbsent(tab.itemKey, FocusNode.new);
    }
  }

  SemiTabData _tabAt(int index) => widget.tabList[index];

  int _indexOf(String key) =>
      widget.tabList.indexWhere((tab) => tab.itemKey == key);

  void _select(String key) {
    if (key == _activeKey) return;
    final controlled = widget.activeKey != null;
    if (!controlled) {
      setState(() {
        _prevActiveKey = _activeKey;
        _activeKey = key;
        _visited.add(key);
      });
    } else {
      _prevActiveKey = _activeKey;
    }
    widget.onChange?.call(key);
  }

  void _handleTap(SemiTabData tab) {
    if (tab.disabled) return;
    _select(tab.itemKey);
    widget.onTabClick?.call(tab.itemKey);
  }

  void _handleClose(SemiTabData tab) {
    widget.onTabClose?.call(tab.itemKey);
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final enabled = <int>[
      for (var i = 0; i < widget.tabList.length; i++)
        if (!widget.tabList[i].disabled) i,
    ];
    if (enabled.isEmpty) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final position = enabled.indexOf(index);
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowDown) {
      final delta = key == LogicalKeyboardKey.arrowRight && rtl ? -1 : 1;
      final next =
          enabled[(position + delta + enabled.length) % enabled.length];
      _focusNodes[_tabAt(next).itemKey]?.requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowUp) {
      final delta = key == LogicalKeyboardKey.arrowLeft && rtl ? 1 : -1;
      final next =
          enabled[(position + delta + enabled.length) % enabled.length];
      _focusNodes[_tabAt(next).itemKey]?.requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _handleTap(_tabAt(index));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      final tab = _tabAt(index);
      if (tab.closable) _handleClose(tab);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusNodes[_tabAt(enabled.first).itemKey]?.requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusNodes[_tabAt(enabled.last).itemKey]?.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _syncScrollArrows() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final canStart = position.pixels > position.minScrollExtent + 0.5;
    final canEnd = position.pixels < position.maxScrollExtent - 0.5;
    if (canStart != _canScrollStart || canEnd != _canScrollEnd) {
      setState(() {
        _canScrollStart = canStart;
        _canScrollEnd = canEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiTabsTheme.resolve(context);
    final global = SemiTheme.of(context);
    final bar = _buildBar(t, global);
    final content = _buildContent(t);
    if (widget.tabPosition == SemiTabsPosition.left) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar,
          Expanded(child: content),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [bar, content],
    );
  }

  // -- bar -------------------------------------------------------------------

  Widget _buildBar(SemiResolvedTabsThemeData t, SemiThemeData global) {
    if (widget.collapsible && widget.tabPosition == SemiTabsPosition.top) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollArrows());
    }
    final extra = _buildExtra(t);
    Widget bar;
    if (widget.tabPosition == SemiTabsPosition.left) {
      bar = _buildLeftBar(t, global, extra);
    } else {
      bar = _buildTopBar(t, global);
      if (extra != null) {
        bar = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: bar),
            extra,
          ],
        );
      }
    }
    final decoration = _barDecoration(t);
    return decoration == null
        ? bar
        : DecoratedBox(decoration: decoration, child: bar);
  }

  BoxDecoration? _barDecoration(SemiResolvedTabsThemeData t) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final top = widget.tabPosition == SemiTabsPosition.top;
    if (widget.type == SemiTabsType.line) {
      final side = BorderSide(
        color: t.colorTabsTabLineDefaultBorderDefault,
        width: t.widthTabsBarLineBorder,
      );
      return BoxDecoration(
        border: top
            ? Border(bottom: side)
            : Border(
                right: rtl ? BorderSide.none : side,
                left: rtl ? side : BorderSide.none,
              ),
      );
    }
    if (widget.type == SemiTabsType.card) {
      final cardSide = BorderSide(
        color: t.colorTabsTabCardDefaultBorderDefault,
        width: t.widthTabsBarCardBorder,
      );
      return BoxDecoration(
        border: top
            ? Border(bottom: cardSide)
            : Border(
                right: rtl ? BorderSide.none : cardSide,
                left: rtl ? cardSide : BorderSide.none,
              ),
      );
    }
    return null;
  }

  Widget _buildTopBar(SemiResolvedTabsThemeData t, SemiThemeData global) {
    final items = _buildBarItems(t, global);
    if (widget.collapsible) {
      return Row(
        // 上游 `.semi-tabs-bar-collapse { align-items: center }`。
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildArrow(t, start: true, onTap: () => _scrollBy(-80)),
          Flexible(
            // 上游折叠条只用箭头滚动、无滚动条——关掉桌面端 ScrollBehavior
            // 自动包上的 RawScrollbar（`copyWith(scrollbars: false)`）。
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisSize: MainAxisSize.min, children: items),
              ),
            ),
          ),
          _buildArrow(t, start: false, onTap: () => _scrollBy(80)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildLeftBar(
    SemiResolvedTabsThemeData t,
    SemiThemeData global,
    Widget? extra,
  ) {
    final items = _buildBarItems(t, global);
    // card 左向等宽铺满（上游 `.semi-tabs-bar-left` flex column + stretch），
    // 选中项内侧 bg-1 边才能盖住条侧轨道线；bar 在 Row 里是 intrinsic 宽，
    // `IntrinsicWidth` 先定宽为最宽项（上游 flex 行为）。
    final card = widget.type == SemiTabsType.card;
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: card
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        ...items,
        if (extra != null)
          Align(alignment: AlignmentDirectional.centerEnd, child: extra),
      ],
    );
    return card ? IntrinsicWidth(child: column) : column;
  }

  void _scrollBy(double delta) {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildArrow(
    SemiResolvedTabsThemeData t, {
    required bool start,
    required VoidCallback onTap,
  }) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final enabled = start ? _canScrollStart : _canScrollEnd;
    final icon = start
        ? (rtl ? SemiIcons.chevronRight : SemiIcons.chevronLeft)
        : (rtl ? SemiIcons.chevronLeft : SemiIcons.chevronRight);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: start ? t.spacingTabsOverflowIconMarginRight : 0,
        start: start ? 0 : t.spacingTabsOverflowIconMarginLeft,
      ),
      child: _TabsArrow(
        icon: icon,
        enabled: enabled,
        t: t,
        onTap: enabled ? onTap : null,
      ),
    );
  }

  List<Widget> _buildBarItems(
    SemiResolvedTabsThemeData t,
    SemiThemeData global,
  ) {
    final list = widget.tabList;
    // 上游 `effectiveCollapsible ? renderCollapsedTab() : (more ? ...)`：
    // collapsible 优先，`more` 不再生效。
    final more = widget.collapsible ? null : widget.more;
    final keep = more == null
        ? list.length
        : list.length - (more < list.length ? more : list.length);
    final visible = more == null ? list : list.sublist(0, keep);
    final rest = more == null ? const <SemiTabData>[] : list.sublist(keep);
    final items = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      // `more` 时触发器是同级元素：最后一个可见页签仍保留右侧间距（上游
      // `:not(:last-of-type)` 只算 `.semi-tabs-tab` 兄弟节点）。
      final last = i == visible.length - 1 && more == null;
      items.add(
        _wrapItem(
          _buildBarItem(visible[i], i, last, t, global),
          last: last,
          t: t,
        ),
      );
    }
    if (more != null) {
      items.add(_buildMoreTrigger(rest, t, global));
    }
    return items;
  }

  Widget _wrapItem(
    Widget child, {
    required bool last,
    required SemiResolvedTabsThemeData t,
  }) {
    final top = widget.tabPosition == SemiTabsPosition.top;
    EdgeInsetsGeometry? margin;
    if (top) {
      final gap = switch (widget.type) {
        SemiTabsType.line => t.spacingTabsBarLineTabMarginRight,
        SemiTabsType.card => t.spacingTabsBarCardTabMarginRight,
        SemiTabsType.button => t.spacingTabsBarButtonTabMarginRight,
        SemiTabsType.slash => t.spacingTabsBarSlashMarginRight,
      };
      if (!last && gap > 0) {
        margin = EdgeInsetsDirectional.only(end: gap);
      }
    } else if (widget.type == SemiTabsType.card) {
      margin = EdgeInsetsDirectional.only(
        bottom: t.spacingTabsBarCardTabLeftMarginBottom,
      );
    } else if (widget.type == SemiTabsType.button) {
      margin = EdgeInsetsDirectional.only(
        bottom: t.spacingTabsBarButtonTabLeftMarginBottom,
      );
    }
    return margin == null ? child : Padding(padding: margin, child: child);
  }

  Widget _buildBarItem(
    SemiTabData tab,
    int index,
    bool last,
    SemiResolvedTabsThemeData t,
    SemiThemeData global,
  ) {
    return _TabItem(
      key: ValueKey('tab-${tab.itemKey}'),
      data: tab,
      selected: tab.itemKey == _activeKey,
      type: widget.type,
      size: widget.size,
      position: widget.tabPosition,
      first: index == 0,
      last: last,
      t: t,
      global: global,
      focusNode: _focusNodes[tab.itemKey],
      onTap: () => _handleTap(tab),
      onClose: () => _handleClose(tab),
      onKeyEvent: (event) => _handleKey(index, event),
    );
  }

  Widget _buildMoreTrigger(
    List<SemiTabData> rest,
    SemiResolvedTabsThemeData t,
    SemiThemeData global,
  ) {
    final custom = widget.renderMoreTrigger;
    final trigger = custom != null
        ? custom()
        : _MoreTrigger(
            t: t,
            global: global,
            type: widget.type,
            text: _TabsStrings.more,
          );
    // tabs.scss:235 `overflow-y: auto` + :32 `max-height: 300px`。
    final menu = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: t.heightTabsOverflowList),
      child: SizedBox(
        width: 160,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final tab in rest)
                _MoreRow(
                  tab: tab,
                  active: tab.itemKey == _activeKey,
                  t: t,
                  global: global,
                  onTap: () => _handleTap(tab),
                ),
            ],
          ),
        ),
      ),
    );
    return SemiDropdown(
      trigger: SemiTooltipTrigger.hover,
      position: SemiTooltipPosition.bottomLeft,
      showTick: true,
      clickToHide: true,
      content: menu,
      child: trigger,
    );
  }

  Widget? _buildExtra(SemiResolvedTabsThemeData t) {
    final extra = widget.tabBarExtraContent;
    if (extra == null) return null;
    Widget child = Container(
      padding: EdgeInsets.symmetric(
        vertical: t.spacingTabsBarExtraPaddingY,
        horizontal: t.spacingTabsBarExtraPaddingX,
      ),
      child: extra,
    );
    if (widget.type == SemiTabsType.line) {
      final lineHeight = widget.size == SemiTabsSize.small
          ? t.fontTabsBarExtraSmallLineHeight
          : t.fontTabsBarExtraLargeLineHeight;
      final height = widget.size == SemiTabsSize.small
          ? t.heightTabsBarExtraSmall
          : t.heightTabsBarExtraLarge;
      child = SizedBox(
        height: height,
        child: SizedBox(
          height: lineHeight,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        ),
      );
    }
    return child;
  }

  // -- content ---------------------------------------------------------------

  Widget _buildContent(SemiResolvedTabsThemeData t) {
    final top = widget.tabPosition == SemiTabsPosition.top;
    final padding = top
        ? EdgeInsets.symmetric(
            vertical: t.spacingTabsContentPaddingY,
            horizontal: t.spacingTabsContentPaddingX,
          )
        : EdgeInsets.symmetric(
            vertical: t.spacingTabsContentLeftPaddingY,
            horizontal: t.spacingTabsContentLeftPaddingX,
          );
    final motionOffset = _paneMotionOffset(t);
    final children = <Widget>[];
    for (final tab in widget.tabList) {
      final active = tab.itemKey == _activeKey;
      if (!widget.keepDOM && !active) continue;
      // lazyRender 只影响内容渲染（上游 TabPane.shouldRender），外层节点仍在。
      final rendered =
          !widget.lazyRender || _visited.contains(tab.itemKey) || active;
      Widget pane = DefaultTextStyle.merge(
        style: TextStyle(color: t.colorTabsTabPaneTextDefault),
        child: rendered
            ? (tab.content ?? const SizedBox.shrink())
            : const SizedBox.shrink(),
      );
      if (active && motionOffset != null) {
        pane = _TabsPaneMotion(
          key: ValueKey('pane-motion-${tab.itemKey}-${_activeKey ?? ''}'),
          offset: motionOffset,
          startOpacity: t.animationOpacityTabsTabPanelShow,
          duration: t.animationDurationTabsTabPanelShow,
          curve: t.animationFunctionTabsTabPanelShow,
          delay: t.animationDelayTabsTabPanelShow,
          child: pane,
        );
      }
      children.add(
        Offstage(
          offstage: !active,
          child: TickerMode(enabled: active, child: pane),
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  /// TabPane.tsx:54-73 `getDirection` + top/left keyframes：进入方向由前一个
  /// 选中项与当前项的相对位置决定；top 用左右位移（60/-60），left 用上下位移
  /// （★上游 topShow/bottomShow keyframes 实际引用 leftShow/rightShow 变量）。
  Offset? _paneMotionOffset(SemiResolvedTabsThemeData t) {
    if (!widget.tabPaneMotion) return null;
    final previous = _prevActiveKey;
    final active = _activeKey;
    if (previous == null || active == null || previous == active) return null;
    final prevIndex = _indexOf(previous);
    final activeIndex = _indexOf(active);
    if (prevIndex == -1 || activeIndex == -1) return null;
    final direction = prevIndex > activeIndex;
    final primary = direction
        ? t.animationTransformTranslateXTabsTabPanelRightShow
        : t.animationTransformTranslateXTabsTabPanelLeftShow;
    if (widget.tabPosition == SemiTabsPosition.top) {
      return Offset(primary, 0);
    }
    return Offset(0, primary);
  }
}

// -- bar item ---------------------------------------------------------------

class _TabItem extends StatefulWidget {
  const _TabItem({
    super.key,
    required this.data,
    required this.selected,
    required this.type,
    required this.size,
    required this.position,
    required this.first,
    required this.last,
    required this.t,
    required this.global,
    required this.focusNode,
    required this.onTap,
    required this.onClose,
    required this.onKeyEvent,
  });

  final SemiTabData data;
  final bool selected;
  final SemiTabsType type;
  final SemiTabsSize size;
  final SemiTabsPosition position;
  final bool first;
  final bool last;
  final SemiResolvedTabsThemeData t;
  final SemiThemeData global;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  /// Mirrors the browser `:focus-visible` heuristic (the button
  /// `_keyboardUsed` gate): the outline only paints after keyboard input,
  /// never after mouse interaction.
  bool _keyboardUsed = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    super.dispose();
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent && !_keyboardUsed && mounted) {
      setState(() => _keyboardUsed = true);
    }
    return false;
  }

  bool get _disabled => widget.data.disabled;

  Color get _textColor {
    final t = widget.t;
    if (_disabled) {
      return _hovered
          ? t.colorTabsTabLineDisabledTextHover
          : t.colorTabsTabLineDisabledTextDefault;
    }
    if (widget.selected) {
      return widget.type == SemiTabsType.button
          ? t.colorTabsTabButtonSelectedTextDefault
          : t.colorTabsTabLineSelectedTextDefault;
    }
    if (widget.type == SemiTabsType.button) {
      // 按钮式非选中项只换底色，文字保持 `$color-tabs_tab_button-text-default`。
      return t.colorTabsTabButtonTextDefault;
    }
    if (_pressed) return t.colorTabsTabLineDefaultTextActive;
    if (_hovered) return t.colorTabsTabLineDefaultTextHover;
    return t.colorTabsTabLineDefaultTextDefault;
  }

  Color get _iconColor {
    final t = widget.t;
    if (widget.selected) return t.colorTabsTabSelectedIconDefault;
    if (_pressed) return t.colorTabsTabIconActive;
    if (_hovered) return t.colorTabsTabIconHover;
    return t.colorTabsTabIconDefault;
  }

  Color get _background {
    final t = widget.t;
    if (_disabled) return const Color(0x00000000);
    switch (widget.type) {
      case SemiTabsType.line:
        if (widget.position == SemiTabsPosition.left) {
          if (widget.selected) {
            return t.colorTabsTabLineVerticalSelectedBgDefault;
          }
          if (_pressed) return t.colorTabsTabLineVerticalBgActive;
          if (_hovered) return t.colorTabsTabLineVerticalBgHover;
        }
        return const Color(0x00000000);
      case SemiTabsType.card:
        if (widget.selected) return const Color(0x00000000);
        if (_pressed) return t.colorTabsTabCardBgActive;
        if (_hovered) return t.colorTabsTabCardBgHover;
        return const Color(0x00000000);
      case SemiTabsType.button:
        if (widget.selected) return t.colorTabsTabButtonSelectedBgDefault;
        if (_pressed) return t.colorTabsTabButtonBgActive;
        if (_hovered) return t.colorTabsTabButtonBgHover;
        return const Color(0x00000000);
      case SemiTabsType.slash:
        return const Color(0x00000000);
    }
  }

  Border? get _border {
    final t = widget.t;
    final top = widget.position == SemiTabsPosition.top;
    final transparent = const Color(0x00000000);
    switch (widget.type) {
      case SemiTabsType.line:
        final color = widget.selected
            ? t.colorTabsTabLineIndicatorSelectedIconDefault
            : _pressed
            ? t.colorTabsTabLineDefaultBorderActive
            : _hovered
            ? t.colorTabsTabLineDefaultBorderHover
            : transparent;
        final side = BorderSide(
          color: _disabled ? transparent : color,
          width: t.widthTabsBarLineTabBorder,
        );
        return top
            ? Border(bottom: side)
            : Border(
                right: Directionality.of(context) == TextDirection.rtl
                    ? side
                    : BorderSide.none,
                left: Directionality.of(context) == TextDirection.rtl
                    ? BorderSide.none
                    : side,
              );
      case SemiTabsType.card:
        final indicator = BorderSide(
          color: widget.selected
              ? t.colorTabsTabCardIndicatorSelectedIconDefault
              : transparent,
          width: t.widthTabsBarCardBorder,
        );
        if (top) {
          // 上游未选中 `border-bottom: none`、选中 `border-bottom: bg-1`
          // ——两态等高（8+0 = 7+1），选中的 bg-1 底边与条底轨道线同像素行
          // 才能盖线；未选中留线。
          return Border(
            top: indicator,
            left: indicator,
            right: indicator,
            bottom: widget.selected
                ? BorderSide(
                    color: t.colorTabsTabCardSelectedBgDefault,
                    width: t.widthTabsBarCardBorder,
                  )
                : BorderSide.none,
          );
        }
        final rtl = Directionality.of(context) == TextDirection.rtl;
        // 内侧 1px 边即遮线（上游 `::after { right:-1px }` / RTL `left:-1px`
        // 的盒内等价——条轨道线画在子项之下）：选中 bg-1 盖线，未选透明。
        final edge = BorderSide(
          color: widget.selected
              ? t.colorTabsTabCardSelectedBgDefault
              : transparent,
          width: t.widthTabsBarCardBorder,
        );
        return Border(
          top: indicator,
          bottom: indicator,
          left: rtl ? edge : indicator,
          right: rtl ? indicator : edge,
        );
      case SemiTabsType.button:
      case SemiTabsType.slash:
        return null;
    }
  }

  BorderRadius? get _radius {
    final t = widget.t;
    switch (widget.type) {
      case SemiTabsType.card:
        return widget.position == SemiTabsPosition.top
            ? t.radiusTabsTabCard
            : t.radiusTabsTabCardLeft;
      case SemiTabsType.button:
        return BorderRadius.circular(t.radiusTabsTabButton);
      case SemiTabsType.line:
      case SemiTabsType.slash:
        return null;
    }
  }

  EdgeInsetsGeometry get _padding {
    final t = widget.t;
    if (widget.position == SemiTabsPosition.top) {
      switch (widget.type) {
        case SemiTabsType.line:
          final (top, right, bottom, left) = switch (widget.size) {
            SemiTabsSize.small => (
              t.spacingTabsBarLineTabSmallPaddingTop,
              t.spacingTabsBarLineTabSmallPaddingRight,
              t.spacingTabsBarLineTabSmallPaddingBottom,
              t.spacingTabsBarLineTabSmallPaddingLeft,
            ),
            SemiTabsSize.medium => (
              t.spacingTabsBarLineTabMediumPaddingTop,
              t.spacingTabsBarLineTabMediumPaddingRight,
              t.spacingTabsBarLineTabMediumPaddingBottom,
              t.spacingTabsBarLineTabMediumPaddingLeft,
            ),
            SemiTabsSize.large => (
              t.spacingTabsBarLineTabPaddingTop,
              t.spacingTabsBarLineTabPaddingRight,
              t.spacingTabsBarLineTabPaddingBottom,
              t.spacingTabsBarLineTabPaddingLeft,
            ),
          };
          return EdgeInsetsDirectional.fromSTEB(
            widget.first ? 0 : left,
            top,
            right,
            bottom,
          );
        case SemiTabsType.card:
          return widget.selected
              ? EdgeInsetsDirectional.fromSTEB(
                  t.spacingTabsBarCardTabActivePaddingLeft,
                  t.spacingTabsBarCardTabActivePaddingTop,
                  t.spacingTabsBarCardTabActivePaddingRight,
                  t.spacingTabsBarCardTabActivePaddingBottom,
                )
              : EdgeInsetsDirectional.symmetric(
                  vertical: t.spacingTabsBarCardTabPaddingY,
                  horizontal: t.spacingTabsBarCardTabPaddingX,
                );
        case SemiTabsType.button:
          return EdgeInsetsDirectional.symmetric(
            vertical: t.spacingTabsBarButtonTabPaddingY,
            horizontal: t.spacingTabsBarButtonTabPaddingX,
          );
        case SemiTabsType.slash:
          return EdgeInsetsDirectional.fromSTEB(
            widget.first ? 0 : t.spacingTabsBarSlashTabPaddingX,
            t.spacingTabsBarSlashTabPaddingY,
            t.spacingTabsBarSlashTabPaddingX,
            t.spacingTabsBarSlashTabPaddingY,
          );
      }
    }
    switch (widget.type) {
      case SemiTabsType.line:
        final padding = switch (widget.size) {
          SemiTabsSize.small => t.spacingTabsBarLineTabLeftSmallPadding,
          SemiTabsSize.medium => t.spacingTabsBarLineTabLeftMediumPadding,
          SemiTabsSize.large => t.spacingTabsBarLineTabLeftPadding,
        };
        return EdgeInsets.all(padding);
      case SemiTabsType.card:
        return widget.selected
            ? EdgeInsetsDirectional.symmetric(
                vertical: t.spacingTabsBarCardTabLeftActivePaddingY,
                horizontal: t.spacingTabsBarCardTabLeftActivePaddingX,
              )
            : EdgeInsetsDirectional.symmetric(
                vertical: t.spacingTabsBarCardTabPaddingY,
                horizontal: t.spacingTabsBarCardTabPaddingX,
              );
      case SemiTabsType.button:
        return EdgeInsetsDirectional.symmetric(
          vertical: t.spacingTabsBarButtonTabPaddingY,
          horizontal: t.spacingTabsBarButtonTabPaddingX,
        );
      case SemiTabsType.slash:
        return EdgeInsetsDirectional.symmetric(
          vertical: t.spacingTabsBarSlashTabPaddingY,
          horizontal: t.spacingTabsBarSlashTabPaddingX,
        );
    }
  }

  Duration get _transitionDuration {
    final t = widget.t;
    return switch (widget.type) {
      SemiTabsType.line => t.transitionDurationTabsTabLineBorder,
      SemiTabsType.card => t.transitionDurationTabsTabCardBg,
      SemiTabsType.button => t.transitionDurationTabsTabButtonBg,
      SemiTabsType.slash => t.transitionDurationTabsTabLineText,
    };
  }

  // `transition_delay-*`（默认 0ms）无 AnimatedContainer 对应，留档不消费：
  // transitionDelayTabsTabLineBorder / transitionDelayTabsTabLineText /
  // transitionDelayTabsTabButtonBg / transitionDelayTabsTabCardBg。
  Curve get _transitionCurve {
    final t = widget.t;
    return switch (widget.type) {
      SemiTabsType.line => t.transitionFunctionTabsTabLineBorder,
      SemiTabsType.card => t.transitionFunctionTabsTabCardBg,
      SemiTabsType.button => t.transitionFunctionTabsTabButtonBg,
      SemiTabsType.slash => t.transitionFunctionTabsTabLineText,
    };
  }

  SemiTransform get transform {
    final t = widget.t;
    return switch (widget.type) {
      SemiTabsType.line => t.transformScaleTabsTabLineItem,
      SemiTabsType.card => t.transformScaleTabsTabCardItem,
      SemiTabsType.button => t.transformScaleTabsTabButtonItem,
      SemiTabsType.slash => t.transformScaleTabsTabLineItem,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final fontSize = switch (widget.size) {
      SemiTabsSize.small => t.fontTabsBarSmallFontSize,
      SemiTabsSize.medium => t.fontTabsBarMediumFontSize,
      SemiTabsSize.large => t.fontTabsBarLargeFontSize,
    };
    final weight = widget.selected
        ? t.fontTabsTabActiveFontWeight
        : t.fontTabsTabFontWeight;
    final label = _label(widget.data.tab);

    Widget core = AnimatedContainer(
      duration: _transitionDuration,
      curve: _transitionCurve,
      padding: _padding,
      decoration: BoxDecoration(
        color: _background,
        border: _border,
        // ★卡片态边框四色不同（选中底边用 bg-1 盖线），BoxDecoration 不允许
        // 非均匀边框 + borderRadius —— 圆角交给外层 ClipRRect 裁剪。
        borderRadius: widget.type == SemiTabsType.card ? null : _radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.data.icon != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: t.spacingTabsTabIconMarginRight,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: t.spacingTabsTabIconTop),
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: 14,
                    color: _disabled ? null : _iconColor,
                  ),
                  child: widget.data.icon!,
                ),
              ),
            ),
          Flexible(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: weight,
                color: _textColor,
              ),
              child: label,
            ),
          ),
          if (widget.data.closable)
            // 关闭图标 `margin-left: 10px`（tabs.scss:124）。
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: Semantics(
                  button: true,
                  label: _TabsStrings.close,
                  child: SemiIcon(
                    SemiIcons.close,
                    customSize: 14,
                    color: widget.global.colors.colorText2,
                  ),
                ),
              ),
            ),
          if (widget.type == SemiTabsType.slash && !widget.last)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: t.spacingTabsBarSlashLineMarginLeft,
                top: t.spacingTabsBarSlashLineMarginTop,
                bottom: t.spacingTabsBarSlashLineMarginBottom,
              ),
              child: SizedBox(
                width: t.widthTabsTabSlashLine,
                height: t.heightTabsTabSlashLine,
                child: CustomPaint(
                  painter: _SlashPainter(t.colorTabsTabSlashLine),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.type == SemiTabsType.card) {
      core = ClipRRect(borderRadius: _radius!, child: core);
    }

    core = Transform.scale(
      // tabs.scss `transform: scale($transform_scale-tabs_tab_*-item)`（token =
      // scale(1,1) 恒等）。
      scaleX: transform.scaleX,
      scaleY: transform.scaleY,
      child: core,
    );

    if (_focused && _keyboardUsed) {
      // `&:focus-visible { outline: $width-tabs-outline solid
      // $color-tabs_tab-outline-focus; outline-offset: $width-tabs-outline-offset
      // }`（line 用 `$width-tabs_bar_line-outline-offset`，负值 = 内缩）。
      // 环走 `:focus-visible` 门控（`_keyboardUsed`，button 先例）：点击聚焦
      // 不画、键盘聚焦才画。
      final inset =
          (widget.type == SemiTabsType.line
                  ? t.widthTabsBarLineOutlineOffset
                  : t.widthTabsOutlineOffset)
              .abs();
      final radius =
          widget.type == SemiTabsType.line || widget.type == SemiTabsType.slash
          ? 0.0
          : t.radiusTabsTabButton;
      core = Stack(
        children: [
          core,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FocusRingPainter(
                  color: t.colorTabsTabOutlineFocus,
                  width: t.widthTabsOutline,
                  inset: inset,
                  radius: radius,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      selected: widget.selected,
      enabled: !_disabled,
      child: MouseRegion(
        cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: Listener(
          onPointerDown: _disabled
              ? null
              : (_) => setState(() {
                    // 按下清键盘模态（rating/checkbox tap-down 先例）——
                    // 鼠标点击聚焦不画焦点环（`:focus-visible`）。
                    _pressed = true;
                    _keyboardUsed = false;
                  }),
          onPointerUp: (_) {
            if (_pressed) setState(() => _pressed = false);
          },
          onPointerCancel: (_) {
            if (_pressed) setState(() => _pressed = false);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _disabled
                ? null
                : () {
                    // 浏览器里 tabindex 元素点击即聚焦；键盘导航从点击处开始。
                    widget.focusNode?.requestFocus();
                    widget.onTap();
                  },
            child: Focus(
              focusNode: widget.focusNode,
              onFocusChange: (focused) => setState(() => _focused = focused),
              onKeyEvent: (node, event) => widget.onKeyEvent(event),
              child: core,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(Object? tab) {
    if (tab == null) return const SizedBox.shrink();
    if (tab is Widget) return tab;
    return Text(tab.toString());
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.color,
    required this.width,
    required this.inset,
    required this.radius,
  });

  final Color color;
  final double width;
  final double inset;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        (Offset(inset, inset) &
                Size(
                  (size.width - inset * 2).clamp(0.0, double.infinity),
                  (size.height - inset * 2).clamp(0.0, double.infinity),
                ))
            .deflate(0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular((radius - inset).clamp(0.0, double.infinity)),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      inset != oldDelegate.inset ||
      radius != oldDelegate.radius;
}

class _SlashPainter extends CustomPainter {
  const _SlashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // tabs.scss:615 `linear-gradient(to bottom right, ...)` 1px 斜线（从左下到右上）。
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_SlashPainter oldDelegate) => color != oldDelegate.color;
}

class _TabsArrow extends StatefulWidget {
  const _TabsArrow({
    required this.icon,
    required this.enabled,
    required this.t,
    required this.onTap,
  });

  final SemiIconData icon;
  final bool enabled;
  final SemiResolvedTabsThemeData t;
  final VoidCallback? onTap;

  @override
  State<_TabsArrow> createState() => _TabsArrowState();
}

class _TabsArrowState extends State<_TabsArrow> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final enabled = widget.enabled;
    final Color color;
    final Color background;
    final Color border;
    if (!enabled) {
      color = _hovered
          ? t.colorTabsTabPaneArrowDisabledTextHover
          : t.colorTabsTabPaneArrowDisabledTextDefault;
      background = _hovered
          ? t.colorTabsTabPaneArrowDisabledBgHover
          : t.colorTabsTabPaneArrowDisabledBgDefault;
      border = t.colorTabsTabPaneArrowBorderDefault;
    } else if (_pressed) {
      // tabs.scss:254 用字面量 `var(--semi-color-fill-1)`（声明色未消费）。
      color = t.colorTabsTabPaneArrowTextActive;
      background = SemiTheme.of(context).colors.colorFill1;
      border = t.colorTabsTabPaneArrowBorderActive;
    } else if (_hovered) {
      // tabs.scss:246 用字面量 `var(--semi-color-fill-0)`。
      color = t.colorTabsTabPaneArrowTextHover;
      background = SemiTheme.of(context).colors.colorFill0;
      border = t.colorTabsTabPaneArrowBorderHover;
    } else {
      color = t.colorTabsTabPaneArrowTextDefault;
      background = t.colorTabsTabPaneArrowBgDefault;
      border = t.colorTabsTabPaneArrowBorderDefault;
    }
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: Listener(
        onPointerDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(t.spacingTabsTabPaneArrow),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: border,
                width: t.widthTabsTabPaneArrowBorder,
              ),
            ),
            child: SemiIcon(widget.icon, customSize: 14, color: color),
          ),
        ),
      ),
    );
  }
}

class _MoreTrigger extends StatelessWidget {
  const _MoreTrigger({
    required this.t,
    required this.global,
    required this.type,
    required this.text,
  });

  final SemiResolvedTabsThemeData t;
  final SemiThemeData global;
  final SemiTabsType type;
  final String text;

  @override
  Widget build(BuildContext context) {
    final (top, right, bottom, left) = switch (type) {
      SemiTabsType.line => (
        t.spacingTabsBarLineTabPaddingTop,
        t.spacingTabsBarLineTabPaddingRight,
        t.spacingTabsBarLineTabPaddingBottom,
        t.spacingTabsBarLineTabPaddingLeft,
      ),
      SemiTabsType.card => (
        t.spacingTabsBarCardTabPaddingY,
        t.spacingTabsBarCardTabPaddingX,
        t.spacingTabsBarCardTabPaddingY,
        t.spacingTabsBarCardTabPaddingX,
      ),
      SemiTabsType.button => (
        t.spacingTabsBarButtonTabPaddingY,
        t.spacingTabsBarButtonTabPaddingX,
        t.spacingTabsBarButtonTabPaddingY,
        t.spacingTabsBarButtonTabPaddingX,
      ),
      SemiTabsType.slash => (
        t.spacingTabsBarSlashTabPaddingY,
        t.spacingTabsBarSlashTabPaddingX,
        t.spacingTabsBarSlashTabPaddingY,
        t.spacingTabsBarSlashTabPaddingX,
      ),
    };
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(left, top, right, bottom),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 14, color: global.colors.colorText2),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: t.spacingTabsTabMoreTriggerIconMarginLeft,
              end: t.spacingTabsTabMoreTriggerIconMarginRight,
              top: t.spacingTabsTabMoreTriggerIconMarginTop,
              bottom: t.spacingTabsTabMoreTriggerIconMarginBottom,
            ),
            child: SemiIcon(SemiIcons.chevronDown, customSize: 14),
          ),
        ],
      ),
    );
  }
}

class _MoreRow extends StatefulWidget {
  const _MoreRow({
    required this.tab,
    required this.active,
    required this.t,
    required this.global,
    required this.onTap,
  });

  final SemiTabData tab;
  final bool active;
  final SemiResolvedTabsThemeData t;
  final SemiThemeData global;
  final VoidCallback onTap;

  @override
  State<_MoreRow> createState() => _MoreRowState();
}

class _MoreRowState extends State<_MoreRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.global.colors;
    final tab = widget.tab;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _hovered ? colors.colorFill0 : null,
            borderRadius: const BorderRadius.all(Radius.circular(3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      size: 14,
                      color: widget.active
                          ? colors.colorPrimary
                          : colors.colorText2,
                    ),
                    child: tab.icon!,
                  ),
                ),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: widget.active
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tab.disabled
                        ? colors.colorDisabledText
                        : widget.active
                        ? colors.colorPrimary
                        : colors.colorText0,
                  ),
                  child: tab.tab is Widget
                      ? tab.tab! as Widget
                      : Text(tab.tab?.toString() ?? ''),
                ),
              ),
              if (widget.active)
                SemiIcon(
                  SemiIcons.tick,
                  customSize: 16,
                  color: colors.colorPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// TabPane.tsx CSSAnimation 等价：200ms 位移 + 透明度（fill-mode forwards）。
class _TabsPaneMotion extends StatefulWidget {
  const _TabsPaneMotion({
    super.key,
    required this.offset,
    required this.startOpacity,
    required this.duration,
    required this.curve,
    required this.delay,
    required this.child,
  });

  final Offset offset;
  final double startOpacity;
  final Duration duration;
  final Curve curve;
  final Duration delay;
  final Widget child;

  @override
  State<_TabsPaneMotion> createState() => _TabsPaneMotionState();
}

class _TabsPaneMotionState extends State<_TabsPaneMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration > Duration.zero
        ? widget.duration
        : const Duration(milliseconds: 1),
  );
  int _delayToken = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    if (widget.delay > Duration.zero) {
      final token = ++_delayToken;
      Future<void>.delayed(widget.delay, () {
        if (mounted && token == _delayToken) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _delayToken++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _controller.drive(CurveTween(curve: widget.curve));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(
            widget.offset.dx * (1 - value),
            widget.offset.dy * (1 - value),
          ),
          child: Opacity(
            opacity: (widget.startOpacity + (1 - widget.startOpacity) * value)
                .clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Locale `Tabs.more` / `Tabs.close`（zh_CN: '更多' / '关闭'）。
abstract final class _TabsStrings {
  static const String more = '更多';
  static const String close = '关闭';
}
