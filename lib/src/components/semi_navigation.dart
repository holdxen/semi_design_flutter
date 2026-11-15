// SemiNavigation — 导航菜单（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/navigation/{variables.scss, animation.scss,
// mixin.scss, navigation.scss, rtl.scss, foundation.ts, itemFoundation.ts,
// subNavFoundation.ts, NavItem.ts, constants.ts}、
// packages/semi-ui/navigation/{index.tsx, Item.tsx, SubNav.tsx, Header.tsx,
// Footer.tsx, CollapseButton.tsx} + zh_CN.ts locale。主题对账
// 122 = 119 FIELDS + 3 MOTION + 0 INTERNAL（tool/generate_navigation.py）——
// ★10 死变量（迄今最多）：真死 9 + 事实死 1，全部留档不消费（落 theme +
// docs「（上游未消费）」；本文件不得出现任何死字段名，生成器 assertNotIn 断言）。
// 3 条 MOTION 是活字段（navigation.scss:2 `@import "./animation.scss"` + :92 消费，
// 0ms/easeIn/0ms 恒等）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_NavigationMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_navigation_theme.dart';
import '../theme/semi_navigation_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_dropdown.dart';
import 'semi_tooltip.dart';

/// 导航模式（上游 `strings.MODE`，constants.ts:3-4）。
enum SemiNavigationMode { vertical, horizontal }

/// Sub 展开图标位置（上游 `toggleIconPosition`，index.tsx:170 缺省 `right`）。
enum SemiNavigationToggleIconPosition { left, right }

/// 菜单条目（上游 `ItemProps`/`SubNavProps` 合体——有 `items` 即 Sub）。
///
/// ★items 归一化照 NavItem.ts:12-24：String 条目包装为 `{text, itemKey}`
/// （同一字符串）；嵌套 `items` 递归归一化（一层或多层）。
class SemiNavigationItem {
  const SemiNavigationItem({
    required this.itemKey,
    this.text,
    this.icon,
    this.link,
    this.disabled = false,
    this.indent,
    this.items,
  }) : assert(
         itemKey is String || itemKey is int,
         'itemKey must be a String or an int',
       );

  /// 唯一键（String | int；★0 是合法 key——foundation.ts:79 `??` 判定 quirk，
  /// 不做 falsy 丢弃）。
  final Object itemKey;

  /// 标题：String | Widget。
  final Object? text;

  /// 前置图标。
  final Widget? icon;

  /// 目标链接（href 元数据——Flutter 不导航，照 breadcrumb 口径应用自理）。
  final String? link;

  /// 禁用（点击/键盘均不响应，itemFoundation.ts:70-72）。
  final bool disabled;

  /// 手动缩进（bool | int；JS truthy 语义——仅 `limitIndent: false` 时参与
  /// 占位图标数计算，Item.tsx:213-215；★int 0 为 falsy quirk）。
  final Object? indent;

  /// 子级递归（`String | SemiNavigationItem` 混排照上游 NavItems；非空即 Sub）。
  final List<Object>? items;
}

/// 头部（上游 `NavHeaderProps`，Header.tsx）。
class SemiNavigationHeader {
  const SemiNavigationHeader({this.logo, this.text, this.link});

  /// logo 图标（渲染 36×36，`object-fit: scale-down` 语义）。
  final Widget? logo;

  /// 标题：String | Widget（collapsed 时隐藏，Header.tsx:63-65）。
  final Object? text;

  /// 目标链接（href 元数据，不导航）。
  final String? link;
}

/// 尾部（上游 `NavFooterProps`，Footer.tsx）。
class SemiNavigationFooter {
  const SemiNavigationFooter({
    this.collapseButton = false,
    this.collapseText,
    this.onClick,
    this.child,
  });

  /// 渲染收起按钮（★horizontal 不渲染——Footer.tsx:64 quirk）。
  final bool collapseButton;

  /// 收起按钮文案（String 固定串；上游 `collapseText?: (collapsed) => ReactNode`
  /// 函数形态收敛为固定串——collapsed=>String 或固定串；缺省走 locale
  /// 「收起侧边栏/展开侧边栏」）。
  final String? collapseText;

  /// footer 容器点击（上游 wrapper `onClick`，Footer.tsx:74）。
  final VoidCallback? onClick;

  /// 自定义 footer 内容（非空时优先于 collapseButton，Footer.tsx:64
  /// `!isValidElement(children) && collapseButton` 才渲染按钮）。
  final Widget? child;
}

/// onSelect 载荷（上游 `OnSelectedData`，index.tsx:28-34）。
class SemiNavigationSelectInfo {
  const SemiNavigationSelectInfo({
    required this.itemKey,
    required this.selectedKeys,
    this.text,
  });

  /// 被点条目键。
  final Object itemKey;

  /// ★点击键列表 `[itemKey]`（itemFoundation.ts:83 原义——自动附的一级父 key
  /// 不进载荷，只进内部 state/视觉）。
  final List<Object> selectedKeys;

  /// 被点条目标题。
  final Object? text;
}

/// onOpenChange 载荷（上游 `OnOpenChangeData`，subNavFoundation.ts:17-21）。
class SemiNavigationOpenInfo {
  const SemiNavigationOpenInfo({
    required this.itemKey,
    required this.openKeys,
    required this.isOpen,
  });

  /// Sub 键。
  final Object itemKey;

  /// 变更后的 openKeys（add/remove 之后的全量列表）。
  final List<Object> openKeys;

  /// 是否展开。
  final bool isOpen;
}

/// onClick 载荷（★item/sub 两路 payload 不一致 quirk——item 发 `{itemKey, text}`、
/// sub 发 `{itemKey, openKeys, isOpen}`（subNavFoundation.ts:115），可空字段并存；
/// 上游声明 `{itemKey, domEvent, isOpen}`（foundation.ts:12-16）与实际不符留档）。
class SemiNavigationClickInfo {
  const SemiNavigationClickInfo({
    required this.itemKey,
    this.text,
    this.openKeys,
    this.isOpen,
  });

  /// 被点键（item 或 Sub 标题）。
  final Object itemKey;

  /// item 路载荷（sub 路为 null）。
  final Object? text;

  /// sub 路载荷（item 路为 null）。
  final List<Object>? openKeys;

  /// sub 路载荷（item 路为 null）。
  final bool? isOpen;
}

/// 导航菜单（三模式：vertical 240px / collapsed 60px / horizontal 60px 高）。
///
/// 选中（itemFoundation.ts:67-96 + index.tsx:252-258）：单选替换；★已选中再点
/// **不触发 onSelect 不移除**；★选中子项自动附一级父 key
/// （`selectLevelZeroParentKeys`，foundation.ts:210-229——Sub 标题亮 selected）；
/// selectedKeys 非空即受控。展开（subNavFoundation.ts:97-125 + index.tsx:407）：
/// ★openKeys 受控**仅 vertical 未折叠生效**（quirk）；无 openKeys 输入且 vertical
/// 时自动展开选中项祖先（foundation.ts:174-188 `getWillOpenKeys`）；Sub 标题点击
/// toggle + onOpenChange。collapsed/horizontal 的 Sub 走弹层菜单（自绘列表，
/// SemiDropdown content 形态——menu 形态承载不了 nav item 六态色，见 docs）。
class SemiNavigation extends StatefulWidget {
  const SemiNavigation({
    super.key,
    this.items = const <Object>[],
    this.mode = SemiNavigationMode.vertical,
    this.selectedKeys,
    this.defaultSelectedKeys,
    this.openKeys,
    this.defaultOpenKeys,
    this.isCollapsed,
    this.defaultIsCollapsed,
    this.onSelect,
    this.onOpenChange,
    this.onCollapseChange,
    this.onClick,
    this.header,
    this.footer,
    this.limitIndent = true,
    this.toggleIconPosition = SemiNavigationToggleIconPosition.right,
    this.expandIcon,
    this.subNavMotion = true,
  });

  /// 条目（`String | SemiNavigationItem` 混排，String 自动包装——NavItem.ts:12-24）。
  final List<Object> items;

  /// 模式（vertical | horizontal，constants.ts:3-4）。
  final SemiNavigationMode mode;

  /// 选中键（非空即受控）。
  final List<Object>? selectedKeys;

  /// 初始选中键。
  final List<Object>? defaultSelectedKeys;

  /// 展开键（★受控仅 vertical 未折叠生效——index.tsx:407 quirk）。
  final List<Object>? openKeys;

  /// 初始展开键。
  final List<Object>? defaultOpenKeys;

  /// 折叠态（非空即受控）。
  final bool? isCollapsed;

  /// 初始折叠态。
  final bool? defaultIsCollapsed;

  /// 选中回调（★已选中再点不触发）。
  final void Function(SemiNavigationSelectInfo info)? onSelect;

  /// Sub 展开/收起回调（vertical 标题点击与 collapsed/horizontal 弹层可见性
  /// 变更均走此口）。
  final void Function(SemiNavigationOpenInfo info)? onOpenChange;

  /// 折叠态变更回调（回传**新值**，foundation.ts:261-268）。
  final ValueChanged<bool>? onCollapseChange;

  /// 点击回调（★item/sub 两路 payload 不一致——SemiNavigationClickInfo）。
  final void Function(SemiNavigationClickInfo info)? onClick;

  /// 头部。
  final SemiNavigationHeader? header;

  /// 尾部。
  final SemiNavigationFooter? footer;

  /// 子级缩进限制（true=子级统一 44px 缩进；false=按 indent 参数占位缩进）。
  final bool limitIndent;

  /// Sub 展开图标位置（left | right）。
  final SemiNavigationToggleIconPosition toggleIconPosition;

  /// 自定义 Sub 展开图标（缺省 chevron_down）。
  final Widget? expandIcon;

  /// Sub 内联展开动画（true → 高度+fade；false 瞬时）。
  final bool subNavMotion;

  /// 根（测试度量锚点）。
  static const Key rootKey = ValueKey('SemiNavigationRoot');

  /// 收起按钮（测试度量锚点）。
  static const Key collapseButtonKey = ValueKey('SemiNavigationCollapseButton');

  /// 弹层菜单面板（测试度量锚点）。
  static const Key subPopupKey = ValueKey('SemiNavigationSubPopup');

  @override
  State<SemiNavigation> createState() => _SemiNavigationState();
}

class _SemiNavigationState extends State<SemiNavigation> {
  /// 有效选中键（含自动附的一级父 key——index.tsx:252-258）。
  List<Object> _selectedKeys = const [];

  /// 有效展开键（foundation.ts:174-188 `getWillOpenKeys`）。
  List<Object> _openKeys = const [];

  /// 折叠态（index.tsx:190 `Boolean(isControlled ? isCollapsed : defaultIsCollapsed)`）。
  bool _isCollapsed = false;

  /// itemKey -> 父键链（foundation.ts:71-113 `buildItemKeysMap`）。
  final Map<Object, List<Object>> _itemKeysMap = {};

  bool get _selectedControlled => widget.selectedKeys != null;

  /// ★openKeys 受控仅 vertical 未折叠生效（index.tsx:407 quirk）。
  bool get _openKeysControlled =>
      widget.openKeys != null &&
      widget.mode == SemiNavigationMode.vertical &&
      !_isCollapsed;

  bool get _isHorizontal => widget.mode == SemiNavigationMode.horizontal;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.isCollapsed ?? widget.defaultIsCollapsed ?? false;
    _rebuildKeys();
  }

  @override
  void didUpdateWidget(SemiNavigation old) {
    super.didUpdateWidget(old);
    if (widget.isCollapsed != null && widget.isCollapsed != _isCollapsed) {
      _isCollapsed = widget.isCollapsed!;
    }
    if (old.items != widget.items) {
      _rebuildKeys();
      return;
    }
    // componentDidUpdate（index.tsx:221-236）：selectedKeys 变更重算选中+自动
    // 展开祖先；openKeys 受控变更直接替换。
    if (widget.selectedKeys != null &&
        widget.selectedKeys != old.selectedKeys) {
      setState(() {
        _selectedKeys = _withParentKeys(widget.selectedKeys!);
        _openKeys = _willOpenKeys();
      });
    } else if (widget.openKeys != null && widget.openKeys != old.openKeys) {
      setState(() {
        _openKeys = List<Object>.of(widget.openKeys!);
      });
    }
  }

  /// items 归一化 + key map + 初始选中/展开（foundation.ts:122-145 `init`）。
  void _rebuildKeys() {
    _itemKeysMap.clear();
    _buildItemKeysMap(widget.items, const []);
    final input = widget.selectedKeys ?? widget.defaultSelectedKeys;
    _selectedKeys = _withParentKeys(input ?? const []);
    _openKeys = _willOpenKeys();
  }

  static SemiNavigationItem _normalize(Object raw) {
    // NavItem.ts:12-24：非对象条目 → {text: options, itemKey: options}。
    if (raw is String) {
      return SemiNavigationItem(itemKey: raw, text: raw);
    }
    return raw as SemiNavigationItem;
  }

  void _buildItemKeysMap(List<Object> items, List<Object> parentKeys) {
    for (final raw in items) {
      final item = _normalize(raw);
      _itemKeysMap[item.itemKey] = List<Object>.of(parentKeys);
      if (item.items != null && item.items!.isNotEmpty) {
        _buildItemKeysMap(item.items!, [...parentKeys, item.itemKey]);
      }
    }
  }

  /// ★选中子项自动附一级父 key（foundation.ts:210-229
  /// `selectLevelZeroParentKeys`——只附最顶层父键）。
  List<Object> _withParentKeys(List<Object> keys) {
    final result = List<Object>.of(keys);
    for (final key in keys) {
      final parents = _itemKeysMap[key];
      if (parents != null && parents.isNotEmpty) {
        final levelZero = parents.first;
        if (!result.contains(levelZero)) {
          result.add(levelZero);
        }
      }
    }
    return result;
  }

  /// getWillOpenKeys（foundation.ts:174-188）：★无 openKeys/defaultOpenKeys 输入
  /// 且 vertical 且有选中输入时自动展开选中项祖先。
  List<Object> _willOpenKeys() {
    final input = widget.openKeys ?? widget.defaultOpenKeys;
    if (input != null) {
      return List<Object>.of(input);
    }
    if (widget.mode != SemiNavigationMode.vertical) {
      return List<Object>.of(_openKeys);
    }
    final selectedInput = widget.selectedKeys ?? widget.defaultSelectedKeys;
    if (selectedInput == null) {
      return List<Object>.of(_openKeys);
    }
    final merged = List<Object>.of(_openKeys);
    for (final key in selectedInput) {
      for (final parent in _itemKeysMap[key] ?? const <Object>[]) {
        if (!merged.contains(parent)) {
          merged.add(parent);
        }
      }
    }
    return merged;
  }

  /// itemFoundation.ts:67-96 `handleClick`：单选替换、★已选中再点不触发不移除、
  /// onSelect 载荷 `selectedKeys = [itemKey]`（:83）。
  void _handleItemTap(SemiNavigationItem item) {
    if (item.disabled) {
      return;
    }
    final already = _selectedKeys.contains(item.itemKey);
    if (!_selectedControlled && !already) {
      setState(() {
        _selectedKeys = _withParentKeys([item.itemKey]);
      });
    }
    if (!already) {
      widget.onSelect?.call(
        SemiNavigationSelectInfo(
          itemKey: item.itemKey,
          selectedKeys: <Object>[item.itemKey],
          text: item.text,
        ),
      );
    }
    // notifyGlobalOnClick（itemFoundation.ts:93）：item 路 {itemKey, text}。
    widget.onClick?.call(
      SemiNavigationClickInfo(itemKey: item.itemKey, text: item.text),
    );
  }

  /// subNavFoundation.ts:97-125 `handleClick`（Sub 标题点击 toggle）。
  void _handleSubTitleTap(SemiNavigationItem item) {
    if (item.disabled) {
      return;
    }
    final isOpen = _openKeys.contains(item.itemKey);
    _applyOpen(item.itemKey, !isOpen);
  }

  /// 打开/收起 Sub 并通知（updateOpen + notifyGlobalOpenChange +
  /// notifyGlobalOnClick——subNavFoundation.ts:111-125）。
  void _applyOpen(Object itemKey, bool isOpen, {bool notifyClick = true}) {
    final openKeys = List<Object>.of(_openKeys);
    if (isOpen) {
      if (!openKeys.contains(itemKey)) {
        openKeys.add(itemKey);
      }
    } else {
      openKeys.remove(itemKey);
    }
    if (!_openKeysControlled) {
      setState(() {
        _openKeys = openKeys;
      });
    }
    widget.onOpenChange?.call(
      SemiNavigationOpenInfo(
        itemKey: itemKey,
        openKeys: openKeys,
        isOpen: isOpen,
      ),
    );
    if (notifyClick) {
      // ★sub 路 onClick payload {itemKey, openKeys, isOpen}（与 item 路不一致）。
      widget.onClick?.call(
        SemiNavigationClickInfo(
          itemKey: itemKey,
          openKeys: openKeys,
          isOpen: isOpen,
        ),
      );
    }
  }

  /// 弹层可见性变更（subNavFoundation.ts:71-90 `handleDropdownVisibleChange`
  /// ——只 notifyGlobalOpenChange 不发 onClick）。
  void _handlePopupVisible(SemiNavigationItem item, bool visible) {
    if (visible == _openKeys.contains(item.itemKey)) {
      return;
    }
    _applyOpen(item.itemKey, visible, notifyClick: false);
  }

  /// foundation.ts:261-268 `handleCollapseChange`。
  void _toggleCollapsed() {
    final next = !_isCollapsed;
    if (widget.isCollapsed == null) {
      setState(() {
        _isCollapsed = next;
      });
    }
    widget.onCollapseChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final SemiResolvedNavigationThemeData t = SemiNavigationTheme.resolve(
      context,
    );
    // rtl.scss:3-39 镜像：EdgeInsetsDirectional/Directionality 自然翻边；
    // border-right → border-left（rtl.scss:8-9）。
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final collapsed = _isCollapsed && !_isHorizontal;

    final Widget inner;
    if (_isHorizontal) {
      inner = Row(
        children: [
          if (widget.header != null) _buildHeader(t),
          Expanded(child: _buildList(t, horizontal: true)),
        ],
      );
    } else {
      inner = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) _buildHeader(t),
          Expanded(child: _buildList(t, horizontal: false)),
          if (widget.footer != null) _buildFooter(t),
        ],
      );
    }

    // nav:13 `overflow: hidden`（折叠渐隐裁剪）。nav:17 `user-select: none`
    // （文本不可选——Flutter 默认即不可选，note-only）。
    // nav:18 `transition: $motion-navigation_padding, $motion-navigation_width`
    // ——折叠动画消费 motionNavigationWidth（宽度）与 motionNavigationPadding /
    // motionNavigationPaddingRtl（内边距）的 duration+curve 语义（String 简写
    // 解析，见 _NavigationMetrics.parseMotion*）。
    return Semantics(
      container: true,
      child: AnimatedContainer(
        key: SemiNavigation.rootKey,
        width: _isHorizontal
            ? null
            : (collapsed
                  ? t.widthNavigationContainerCollapsed
                  : t.widthNavigationContainerBase),
        height: _isHorizontal ? t.heightNavigationHorizontalHeader : null,
        duration: _NavigationMetrics.parseMotionDuration(
          t.motionNavigationWidth,
        ),
        curve: _NavigationMetrics.parseMotionCurve(t.motionNavigationWidth),
        decoration: BoxDecoration(
          color: t.colorNavigationBgDefault,
          border: _rootBorder(t, rtl),
        ),
        clipBehavior: Clip.hardEdge,
        child: AnimatedPadding(
          duration: _NavigationMetrics.parseMotionDuration(
            // rtl.scss:10 `transition: $motion-navigation_padding_rtl, ...`。
            rtl ? t.motionNavigationPaddingRtl : t.motionNavigationPadding,
          ),
          curve: _NavigationMetrics.parseMotionCurve(
            rtl ? t.motionNavigationPaddingRtl : t.motionNavigationPadding,
          ),
          padding: _rootPadding(t),
          child: inner,
        ),
      ),
    );
  }

  EdgeInsetsGeometry _rootPadding(SemiResolvedNavigationThemeData t) {
    if (_isHorizontal) {
      // nav:597-598 horizontal 水平 padding。
      return EdgeInsetsDirectional.only(
        start: t.spacingNavigationHorizontalPaddingLeft,
        end: t.spacingNavigationHorizontalPaddingRight,
      );
    }
    // nav:15-16 根水平 padding（collapsed 走 collapsed-paddingX）。
    final x = _isCollapsed
        ? t.spacingNavigationCollapsedPaddingX
        : t.spacingNavigationPaddingX;
    return EdgeInsets.symmetric(horizontal: x);
  }

  Border _rootBorder(SemiResolvedNavigationThemeData t, bool rtl) {
    if (_isHorizontal) {
      // nav:595-596 horizontal：border-right: none + border-bottom。
      return Border(bottom: _side(t));
    }
    // nav:19 border-right（RTL → border-left，rtl.scss:8-9）。
    return rtl ? Border(left: _side(t)) : Border(right: _side(t));
  }

  BorderSide _side(SemiResolvedNavigationThemeData t) => BorderSide(
    width: t.widthNavigationBorder,
    color: t.colorNavigationBorderDefault,
  );

  /// 头部（Header.tsx + nav:357-387/:402-426）。
  Widget _buildHeader(SemiResolvedNavigationThemeData t) {
    final header = widget.header!;
    final collapsed = _isCollapsed && !_isHorizontal;
    final logo = header.logo;
    final children = <Widget>[
      if (logo != null)
        Padding(
          // nav:363-364 logo margin（RTL 翻边，rtl.scss:48-52）。
          padding: EdgeInsetsDirectional.only(
            start: t.spacingNavigationHeaderLogoMarginLeft,
            end: collapsed ? 0 : t.spacingNavigationHeaderLogoMarginRight,
          ),
          child: SizedBox(
            // nav:371-372 logo 36×36（collapsed 宽走 nav:414 `width:
            // $height-navigation_header_logo_collapsed` 当宽用 quirk）。
            width: collapsed
                ? t.heightNavigationHeaderLogoCollapsed
                : t.widthNavigationHeaderLogo,
            height: collapsed
                ? t.heightNavigationHeaderLogoCollapsed
                : t.heightNavigationHeaderLogo,
            // nav:373 `object-fit: scale-down`。
            child: FittedBox(fit: BoxFit.scaleDown, child: logo),
          ),
        ),
      // Header.tsx:63-65：collapsed 隐 text。
      if (header.text != null && !collapsed)
        Flexible(
          child: DefaultTextStyle.merge(
            // nav:378 `@include font-size-header-5`（mixin 来源 global
            // `$font-size-header-5` = 18，见 _NavigationMetrics.fontSizeHeader5）
            // + nav:379 字重 + nav:381 色。
            style: TextStyle(
              fontSize: _NavigationMetrics.fontSizeHeader5,
              fontWeight: t.fontNavigationHeaderItemFontWeight,
              color: t.colorNavigationHeaderTextDefault,
            ),
            // nav:382-383 ellipsis 三连（单行省略）。
            child: header.text is Widget
                ? header.text! as Widget
                : Text(
                    header.text!.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
    ];
    final row = Row(mainAxisSize: MainAxisSize.min, children: children);
    return Padding(
      padding: _headerPadding(t),
      child: _isHorizontal
          // nav:614-615 horizontal header margin-right。
          ? Padding(
              padding: EdgeInsetsDirectional.only(
                end: t.spacingNavigationHorizontalHeaderLogoMarginRight,
              ),
              child: row,
            )
          : row,
    );
  }

  EdgeInsets _headerPadding(SemiResolvedNavigationThemeData t) {
    if (_isHorizontal) {
      return EdgeInsets.zero;
    }
    // nav:544-547 垂直 header padding（collapsed 走 nav:551-552）。★3.5 公式 quirk
    // （variables.scss:50/:52
    //     `($width-navigation_container_collapsed - $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border - $height-navigation_header_logo_collapsed) * 0.5`
    // = 3.5，见 _NavigationMetrics.verticalHeaderPaddingFormula）。
    return EdgeInsets.only(
      top: t.spacingNavigationHeaderPaddingTop,
      bottom: t.spacingNavigationHeaderPaddingBottom,
      left: _isCollapsed
          ? t.spacingNavigationVerticalNavHeaderCollapsedPaddingLeft
          : t.spacingNavigationVerticalNavHeaderPaddingLeft,
      right: _isCollapsed
          ? t.spacingNavigationVerticalNavHeaderCollapsedPaddingRight
          : t.spacingNavigationVerticalNavHeaderPaddingRight,
    );
  }

  /// 条目列表（nav:29-47 `&-list` + nav:537-541 list-wrapper）。
  Widget _buildList(
    SemiResolvedNavigationThemeData t, {
    required bool horizontal,
  }) {
    final entries = widget.items.map(_normalize).toList();
    final rows = <Widget>[
      for (var idx = 0; idx < entries.length; idx++)
        _buildEntry(
          item: entries[idx],
          level: 0,
          first: idx == 0,
          last: idx == entries.length - 1,
          horizontal: horizontal,
          inPopup: false,
          t: t,
        ),
    ];
    if (horizontal) {
      // nav:618-620 horizontal list：inline-flex 一行排布。
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: rows),
      );
    }
    return SingleChildScrollView(
      // nav:538 list-wrapper paddingTop。
      padding: EdgeInsetsDirectional.only(
        top: t.spacingNavigationListWrapperPaddingTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  /// 单条目分发（有 items → Sub，无 → Item）。
  Widget _buildEntry({
    required SemiNavigationItem item,
    required int level,
    required bool first,
    required bool last,
    required bool horizontal,
    required bool inPopup,
    VoidCallback? onAfterTap,
    required SemiResolvedNavigationThemeData t,
  }) {
    final hasChildren = item.items != null && item.items!.isNotEmpty;
    final Widget row;
    if (hasChildren) {
      row = _buildSub(
        item: item,
        level: level,
        last: last,
        horizontal: horizontal,
        inPopup: inPopup,
        t: t,
      );
    } else {
      row = _buildItem(
        item: item,
        level: level,
        last: last,
        horizontal: horizontal,
        inPopup: inPopup,
        subItem: level > 0,
        onAfterTap: onAfterTap,
        t: t,
      );
    }
    // nav:277-279 `.sub .item:first-child { margin-top: 8 }`（子级首位）。
    if (first && level > 0 && !inPopup) {
      return Padding(
        padding: EdgeInsetsDirectional.only(
          top: t.spacingNavigationSubItemFirstChildMarginTop,
        ),
        child: row,
      );
    }
    return row;
  }

  /// 普通条目行（Item.tsx render + mixin.scss 状态色）。
  Widget _buildItem({
    required SemiNavigationItem item,
    required int level,
    required bool last,
    required bool horizontal,
    required bool inPopup,
    required bool subItem,
    VoidCallback? onAfterTap,
    required SemiResolvedNavigationThemeData t,
  }) {
    return _NavItemRow(
      item: item,
      level: level,
      selected: _selectedKeys.contains(item.itemKey),
      horizontal: horizontal,
      subItem: subItem,
      inPopup: inPopup,
      last: last,
      limitIndent: widget.limitIndent,
      toggleIconPosition: widget.toggleIconPosition,
      collapsed: _isCollapsed && !horizontal,
      t: t,
      onTap: () {
        _handleItemTap(item);
        onAfterTap?.call();
      },
    );
  }

  /// Sub（SubNav.tsx：标题 + 内联折叠列表或弹层菜单）。
  Widget _buildSub({
    required SemiNavigationItem item,
    required int level,
    required bool last,
    required bool horizontal,
    required bool inPopup,
    required SemiResolvedNavigationThemeData t,
  }) {
    final isOpen = _openKeys.contains(item.itemKey);
    final collapsed = _isCollapsed && !horizontal;
    Widget title = _NavSubTitle(
      item: item,
      level: level,
      isOpen: isOpen,
      selected: _selectedKeys.contains(item.itemKey),
      horizontal: horizontal,
      inPopup: inPopup,
      collapsed: collapsed,
      limitIndent: widget.limitIndent,
      toggleIconPosition: widget.toggleIconPosition,
      expandIcon: widget.expandIcon,
      subNavMotion: widget.subNavMotion,
      t: t,
      onTap: () => _handleSubTitleTap(item),
    );
    if (collapsed && item.disabled) {
      // Item.tsx:294-296：collapsed 的 disabled Sub 也包 tooltip。
      title = SemiTooltip(
        trigger: SemiTooltipTrigger.hover,
        position: SemiTooltipPosition.right,
        arrowPointAtCenter: false,
        mouseEnterDelay: _NavigationMetrics.tooltipShowDelay,
        mouseLeaveDelay: _NavigationMetrics.tooltipHideDelay,
        content: Text(item.text?.toString() ?? ''),
        child: title,
      );
    }

    final rawChildren = item.items!;
    // collapsed/horizontal 的子级渲染进弹层——全链 inPopup 语义（min-width 150 /
    // 弹层色 / popover 字重）。
    final bool childInPopup = inPopup || collapsed || horizontal;
    final children = <Widget>[
      for (var idx = 0; idx < rawChildren.length; idx++)
        _buildEntry(
          item: _normalize(rawChildren[idx]),
          level: level + 1,
          first: idx == 0,
          last: idx == rawChildren.length - 1,
          horizontal: horizontal,
          inPopup: childInPopup,
          // 弹层内点条目即收起（近似 Dropdown.Item 行为，见差异清单 23）。
          onAfterTap: (collapsed || horizontal)
              ? () => _handlePopupVisible(item, false)
              : null,
          t: t,
        ),
    ];

    // collapsed/horizontal：Sub 全走弹层菜单（SubNav.tsx:359-361 wrapDropdown）。
    // ★自决点：自绘列表（SemiDropdown content 形态——SemiDropdownItemData menu
    // 形态承载不了 nav item 六态色与 min-width 150；嵌套 Sub 由 SemiDropdown 的
    // pointer-exempt scope 接住，semi_tooltip.dart SemiOverlayPointerExemptScope
    // 先例）。
    if (collapsed || horizontal) {
      final popup = Container(
        key: SemiNavigation.subPopupKey,
        // nav:751-755 `.semi-dropdown-menu .semi-navigation-item-sub` padding。
        padding: EdgeInsets.all(t.spacingNavigationItemSubPadding),
        constraints: BoxConstraints(
          minWidth: t.widthNavigationDropdownItemNavItemMinWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // 弹层在 Overlay 里宽度无界——stretch 非法，行自带 min-width。
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
      return SemiDropdown(
        trigger: SemiTooltipTrigger.hover,
        // SubNav.tsx:336：horizontal 顶层 bottomLeft、其余 rightTop。
        position: !horizontal || inPopup
            ? SemiTooltipPosition.rightTop
            : SemiTooltipPosition.bottomLeft,
        // constants.ts:25-26 `DEFAULT_SUBNAV_OPEN_DELAY: 0` /
        // `DEFAULT_SUBNAV_CLOSE_DELAY: 100`。
        mouseEnterDelay: _NavigationMetrics.subNavOpenDelay,
        mouseLeaveDelay: _NavigationMetrics.subNavCloseDelay,
        visible: isOpen,
        onVisibleChange: (visible) => _handlePopupVisible(item, visible),
        content: popup,
        child: title,
      );
    }

    // vertical 内联展开（subNavMotion true → 高度+fade；false 瞬时）。
    final subList = Padding(
      // nav:262 `ul.sub` padding（subWrap padding/margin 见外层）。
      padding: EdgeInsets.all(t.spacingNavigationSubPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    final Widget body;
    if (widget.subNavMotion) {
      body = AnimatedSize(
        // 上游 Collapsible（SubNav.tsx:277-286）CSS 高度+fade 动画无 token——
        // 硬编码近似，见差异清单。
        duration: _NavigationMetrics.subNavMotionDuration,
        curve: Curves.easeInOut,
        alignment: AlignmentDirectional.topStart,
        child: ClipRect(
          child: AnimatedOpacity(
            duration: _NavigationMetrics.subNavMotionDuration,
            opacity: isOpen ? 1 : 0,
            child: isOpen
                ? subList
                // 零尺寸 DecoratedBox 陷阱：闭合态给宽度占位。
                : const SizedBox(width: double.infinity),
          ),
        ),
      );
    } else {
      body = isOpen ? subList : const SizedBox.shrink();
    }
    return Container(
      // nav:242-245 sub-wrap padding / margin-top。
      margin: EdgeInsetsDirectional.only(
        top: t.spacingNavigationSubWrapMarginTop,
      ),
      padding: EdgeInsets.all(t.spacingNavigationSubWrapPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, body],
      ),
    );
  }

  /// 尾部（Footer.tsx + CollapseButton.tsx + nav:389-399/:557-588/:715-724）。
  Widget _buildFooter(SemiResolvedNavigationThemeData t) {
    final footer = widget.footer!;
    final collapsed = _isCollapsed && !_isHorizontal;
    final Widget content;
    if (footer.child != null) {
      // Footer.tsx:64 `!isValidElement(children) && collapseButton` 才渲染按钮。
      content = footer.child!;
    } else if (footer.collapseButton && !_isHorizontal) {
      content = _buildCollapseButton(t);
    } else {
      content = const SizedBox.shrink();
    }
    final row = Row(
      // nav:576-578 collapsed footer：justify-content: center。
      mainAxisAlignment: collapsed
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [Flexible(child: content)],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Footer.tsx:74 wrapper onClick。
      onTap: footer.onClick,
      child: Padding(
        // nav:391 footer padding（vertical 覆盖 nav:559-560；horizontal
        // nav:717 padding-right: 0）。
        padding: _footerPadding(t),
        child: DefaultTextStyle.merge(
          // nav:558 footer 色。
          style: TextStyle(color: t.colorNavigationFooterIconDefault),
          child: row,
        ),
      ),
    );
  }

  EdgeInsets _footerPadding(SemiResolvedNavigationThemeData t) {
    if (_isHorizontal) {
      return EdgeInsets.only(
        top: t.spacingNavigationFooterPaddingY,
        bottom: t.spacingNavigationFooterPaddingY,
        left: t.spacingNavigationFooterPaddingX,
      );
    }
    return EdgeInsets.only(
      top: t.spacingNavigationFooterPaddingY,
      bottom: t.spacingNavigationFooterPaddingY,
      left: t.spacingNavigationVerticalFooterPaddingLeft,
      right: t.spacingNavigationVerticalFooterPaddingRight,
    );
  }

  /// 收起按钮（CollapseButton.tsx + nav:562-587）。
  Widget _buildCollapseButton(SemiResolvedNavigationThemeData t) {
    final collapsed = _isCollapsed;
    // zh_CN.ts:100-103 locale：'收起侧边栏' / '展开侧边栏'（缺省文案）。
    final label =
        widget.footer!.collapseText ?? (collapsed ? '展开侧边栏' : '收起侧边栏');
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      // CSS flexbox shrink 语义：收起态窄栏内图标/间距/标题均可收缩。
      children: [
        const Flexible(child: SemiIcon(SemiIcons.sidebar)),
        // nav:564 `margin-left: $spacing-navigation_vertical_footer_semi_button_content_right-marginLeft`
        // （收起按钮标题左侧外边距）+ nav:583-584 collapsed 标题 `opacity: 0`。
        Flexible(
          child: SizedBox(
            width: t
                .spacingNavigationVerticalFooterSemiButtonContentRightMarginLeft,
          ),
        ),
        Flexible(
          child: AnimatedOpacity(
            // nav:566/:584 `transition: $motion-navigation_collapsed_opacity`
            // ——渐隐动画消费 motionNavigationCollapsedOpacity 的 duration+curve
            // 语义（nav:57-67 折叠渐隐 `opacity: 0` / `opacity: 1`）。
            duration: _NavigationMetrics.parseMotionDuration(
              t.motionNavigationCollapsedOpacity,
            ),
            curve: _NavigationMetrics.parseMotionCurve(
              t.motionNavigationCollapsedOpacity,
            ),
            opacity: collapsed ? 0 : 1,
            child: Text(
              label,
              // nav:396-397 collapse-btn 省略三连。
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
    final button = SemiButton(
      content,
      key: SemiNavigation.collapseButtonKey,
      type: SemiButtonType.tertiary,
      variant: SemiButtonVariant.borderless,
      // nav:569-571 `& > .semi-button { padding-left/right: 8px }`。
      noHorizontalPadding: SemiButtonNoPadding.both,
      onPressed: _toggleCollapsed,
    );
    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacingNavigationFooterCollapseBtnInnerPaddingX,
      ),
      child: button,
    );
    if (collapsed) {
      // CollapseButton.tsx:39-43：折叠时 icon-only + tooltip。
      return SemiTooltip(
        trigger: SemiTooltipTrigger.hover,
        position: SemiTooltipPosition.right,
        arrowPointAtCenter: false,
        // constants.ts:23 `DEFAULT_TOOLTIP_SHOW_DELAY: 0` /
        // :24 `DEFAULT_TOOLTIP_HIDE_DELAY: 100`。
        mouseEnterDelay: _NavigationMetrics.tooltipShowDelay,
        mouseLeaveDelay: _NavigationMetrics.tooltipHideDelay,
        content: Text(label),
        child: padded,
      );
    }
    return padded;
  }
}

/// 普通条目行（Item.tsx render + mixin.scss 12 状态色 + nav:76-110 行盒）。
class _NavItemRow extends StatefulWidget {
  const _NavItemRow({
    required this.item,
    required this.level,
    required this.selected,
    required this.horizontal,
    required this.subItem,
    required this.inPopup,
    required this.last,
    required this.limitIndent,
    required this.toggleIconPosition,
    required this.collapsed,
    required this.t,
    required this.onTap,
  });

  final SemiNavigationItem item;
  final int level;
  final bool selected;
  final bool horizontal;
  final bool subItem;
  final bool inPopup;
  final bool last;
  final bool limitIndent;
  final SemiNavigationToggleIconPosition toggleIconPosition;
  final bool collapsed;
  final SemiResolvedNavigationThemeData t;
  final VoidCallback onTap;

  @override
  State<_NavItemRow> createState() => _NavItemRowState();
}

class _NavItemRowState extends State<_NavItemRow> {
  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  /// JS truthy：bool / 非 0 int（★0 falsy quirk）。
  static bool indentTruthy(Object? indent) {
    if (indent is bool) {
      return indent;
    }
    if (indent is int) {
      return indent != 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final item = widget.item;
    final disabled = item.disabled;
    final selected = widget.selected;
    // ★弹层内条目不走 horizontal 色系（上游 horizontal 色规则 scoped
    // `.semi-navigation-horizontal .semi-navigation-list`，portal 外不命中——
    // 弹层统一 itemL1 系近似，见差异清单）。
    final horiz = widget.horizontal && !widget.inPopup;
    // mixin.scss 状态映射（12 状态）：default/hover/active/selected/
    // hover-selected/active-selected/disabled/disabled-selected；子级行（Ln）
    // hover/active/selected 复用 itemL1 mixin（navigation.scss:289-319 quirk
    // ——itemLn 状态系预留未接线）但底色走 itemLn default（nav:268-269）。
    final Color bg;
    final Color textColor;
    final Color iconColor;
    if (horiz) {
      // mixin.scss:78-98 item-horizontal-* 系。
      if (disabled) {
        if (selected || _hover || _pressed) {
          bg = t.colorNavigationHorizontalItemL1DisabledBgDefault;
          textColor = t.colorNavigationHorizontalItemL1DisabledTextDefault;
          iconColor = t.colorNavigationHorizontalItemL1DisabledIconDefault;
        } else {
          bg = t.colorNavigationHorizontalItemL1BgDefault;
          textColor = t.colorNavigationHorizontalItemL1TextDefault;
          iconColor = t.colorNavigationHorizontalItemL1IconDefault;
        }
      } else if (selected) {
        bg = t.colorNavigationHorizontalItemL1SelectedBgDefault;
        textColor = t.colorNavigationHorizontalItemL1SelectedTextDefault;
        iconColor = t.colorNavigationHorizontalItemL1SelectedIconDefault;
      } else if (_pressed) {
        bg = t.colorNavigationHorizontalItemL1BgActive;
        textColor = t.colorNavigationHorizontalItemL1TextActive;
        iconColor = t.colorNavigationHorizontalItemL1IconActive;
      } else if (_hover) {
        bg = t.colorNavigationHorizontalItemL1BgHover;
        textColor = t.colorNavigationHorizontalItemL1TextHover;
        iconColor = t.colorNavigationHorizontalItemL1IconHover;
      } else {
        bg = t.colorNavigationHorizontalItemL1BgDefault;
        textColor = t.colorNavigationHorizontalItemL1TextDefault;
        iconColor = t.colorNavigationHorizontalItemL1IconDefault;
      }
    } else if (disabled) {
      // mixin.scss:10-19 item-disabled + :36-44 item-disabled-selected。
      if (selected && widget.subItem && (_hover || _pressed)) {
        // nav:324-328 子级 selected+disabled quirk：bg 走 itemL1 selected、
        // text 走 itemL1 disabled（非 selected_disabled 系）。
        bg = t.colorNavigationItemL1SelectedBgDefault;
        textColor = t.colorNavigationItemL1DisabledTextDefault;
        iconColor = t.colorNavigationItemL1SelectedDisabledIconDefault;
      } else if (selected) {
        bg = t.colorNavigationItemL1SelectedDisabledBgDefault;
        textColor = t.colorNavigationItemL1SelectedDisabledTextDefault;
        iconColor = t.colorNavigationItemL1SelectedDisabledIconDefault;
      } else {
        bg = t.colorNavigationItemL1DisabledBgDefault;
        textColor = t.colorNavigationItemL1DisabledTextDefault;
        iconColor = t.colorNavigationItemL1DisabledIconDefault;
      }
    } else if (selected) {
      // mixin.scss:2-9 item-selected + :20-27 hover-selected + :28-35
      // active-selected（子级 hover/active 保持 item-selected——nav:300-318）。
      if (_pressed && !widget.subItem) {
        bg = t.colorNavigationItemL1BgActive;
        textColor = t.colorNavigationItemL1SelectedTextActive;
      } else if (_hover && !widget.subItem) {
        bg = t.colorNavigationItemL1BgHover;
        textColor = t.colorNavigationItemL1SelectedTextHover;
      } else {
        bg = t.colorNavigationItemL1SelectedBgDefault;
        textColor = t.colorNavigationItemL1SelectedTextDefault;
      }
      iconColor = t.colorNavigationItemL1SelectedIconDefault;
    } else if (_pressed) {
      bg = t.colorNavigationItemL1BgActive;
      textColor = t.colorNavigationItemL1TextActive;
      iconColor = t.colorNavigationItemL1IconActive;
    } else if (_hover) {
      bg = t.colorNavigationItemL1BgHover;
      textColor = t.colorNavigationItemL1TextHover;
      iconColor = t.colorNavigationItemL1IconHover;
    } else {
      bg = widget.subItem
          ? t.colorNavigationItemLnBgDefault
          : t.colorNavigationItemL1BgDefault;
      textColor = widget.subItem
          ? t.colorNavigationItemLnTextDefault
          : t.colorNavigationItemL1TextDefault;
      iconColor = t.colorNavigationItemL1IconDefault;
    }

    // 字重：顶层 item 600（nav:40-41）、子级 item 400（nav:274）、弹层 item
    // 400（nav:88 基准）、弹层选中 400（nav:732-734 `normal` 关键字 quirk）。
    final FontWeight weight;
    if (widget.inPopup && selected) {
      weight = t.fontNavigationPopoverNavItemSelectedFontWeight;
    } else if (widget.inPopup) {
      weight = t.fontNavigationItemNormalFontWeight;
    } else if (widget.subItem) {
      weight = t.fontNavigationSubItemFontWeight;
    } else {
      weight = t.fontNavigationItemFontWeight;
    }

    // Item.tsx:220/:223：toggleIconPosition left 时条目前也有 toggle 槽
    // （普通条目 toggleIcon 为空——空槽占位 quirk）。
    final leading = <Widget>[];
    if (widget.toggleIconPosition == SemiNavigationToggleIconPosition.left) {
      leading.add(_slot(const SizedBox.shrink(), t, gap: _iconGap(t)));
    }
    if (!widget.limitIndent && !widget.collapsed && !horiz) {
      // Item.tsx:213-215 手动缩进占位图标（limitIndent=false）：
      // `iconAmount = (icon && !indent) ? level : level - 1`。
      final iconAmount = (item.icon != null && !indentTruthy(item.indent))
          ? widget.level
          : widget.level - 1;
      for (var i = 0; i < iconAmount; i++) {
        leading.add(_slot(const SizedBox.shrink(), t, gap: _iconGap(t)));
      }
    }
    final showIconSlot =
        item.icon != null || indentTruthy(item.indent) || widget.subItem;
    final textIsFirst = leading.isEmpty && !showIconSlot;

    final text = item.text;
    final textWidget = text == null
        ? null
        : Padding(
            // nav:282 子级无图标文本 44px 缩进：
            //     `$spacing-base-tight + $width-navigation_icon_left + $width-navigation_icon_text_between`
            // （= 12+20+12 = 44；文本 first-child 才命中）。
            padding: EdgeInsetsDirectional.only(
              start: widget.subItem && textIsFirst
                  ? t.spacingNavigationItemPaddingX +
                        t.widthNavigationIconLeft +
                        t.widthNavigationIconTextBetween
                  : 0,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                // nav:87 `@include font-size-regular`（顶层/弹层）/ nav:258-259
                // `.sub` 容器字号（子级）。
                fontSize: widget.subItem
                    ? t.fontNavigationSubFontSize
                    : _NavigationMetrics.fontSizeRegular,
                fontWeight: weight,
                color: textColor,
              ),
              child: text is Widget
                  ? text
                  : Text(
                      text.toString(),
                      // nav:94-97
                      // `overflow: hidden; white-space: nowrap; text-overflow: ellipsis`。
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          );

    final rowChildren = <Widget>[
      // CSS flexbox shrink 语义：窄帧（折叠动画）下各槽位可收缩不溢出。
      for (final slot in leading) Flexible(child: slot),
      if (showIconSlot)
        Flexible(
          child: _slot(
            item.icon ?? const SizedBox.shrink(),
            t,
            gap: _iconGap(t),
            color: iconColor,
          ),
        ),
      if (textWidget != null) Flexible(child: textWidget),
    ];

    final row = AnimatedContainer(
      // MOTION 3 消费（nav:92 bg transition——0ms/easeIn/0ms 恒等注释口径照
      // anchor 先例）。
      duration: t.transitionDurationNavigationItemL1Bg,
      curve: t.transitionFunctionNavigationItemL1Bg,
      // transitionDelayNavigationItemL1Bg delay 槽 AnimatedContainer 无对应
      // ——注释引用（docs 注明）。
      // nav:81-85 行盒：圆角 3（★名宽实圆角 quirk）、padding X12/Y8、
      // margin-bottom 8（末位 0——nav:525-527）。
      margin: EdgeInsetsDirectional.only(
        top: widget.inPopup
            ? t.spacingNavigationDropdownItemNavItemMarginTop
            : 0,
        bottom: widget.inPopup
            ? t.spacingNavigationDropdownItemNavItemMarginBottom
            : widget.last
            ? t.spacingNavigationVerticalNavItemLastMarginBottom
            : widget.horizontal
            ? t.spacingNavigationHorizontalNavListItemMarginBottom
            : t.spacingNavigationItemMarginBottom,
        // nav:663-665 horizontal 非末位右 margin。
        end: widget.horizontal && !widget.last
            ? t.spacingNavigationHorizontalNavListItemNotLastMarginRight
            : 0,
      ),
      padding: EdgeInsets.symmetric(
        vertical: t.spacingNavigationItemPaddingY,
        horizontal: t.spacingNavigationItemPaddingX,
      ),
      constraints: BoxConstraints(
        minHeight: t.heightNavigationItemBase,
        minWidth: widget.inPopup
            ? t.widthNavigationDropdownItemNavItemMinWidth
            : 0,
      ),
      decoration: BoxDecoration(
        color: bg,
        // nav:81 `border-radius: $width-navigation_item-borderRadius`。
        borderRadius: BorderRadius.circular(t.widthNavigationItemBorderRadius),
      ),
      child: Row(
        // 弹层（Overlay 无界）/horizontal（横滚无界）shrink-wrap；主树 max 铺满。
        mainAxisSize: widget.inPopup || widget.horizontal
            ? MainAxisSize.min
            : MainAxisSize.max,
        children: rowChildren,
      ),
    );

    final focusOutline = Container(
      decoration: _focused
          // nav:106-108 focus outline：`widthNavigationOutline`(2) solid
          // `colorNavigationOutlineFocus` + offset `widthNavigationOutlineOffset`(-2)。
          ? BoxDecoration(
              border: Border.all(
                width: t.widthNavigationOutline,
                color: t.colorNavigationOutlineFocus,
              ),
              borderRadius: BorderRadius.circular(
                t.widthNavigationItemBorderRadius,
              ),
            )
          : null,
      child: Padding(
        // outline-offset: -2（向内收）。
        padding: EdgeInsets.all(_focused ? -t.widthNavigationOutlineOffset : 0),
        child: row,
      ),
    );

    final mouse = Semantics(
      // aria 近似（见差异清单 28）：menuitem 的 selected/disabled。
      selected: widget.selected,
      enabled: !disabled,
      child: MouseRegion(
        // nav:79 `cursor: pointer`；mix:13/39/71 `cursor: not-allowed`。
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Focus(
          onKeyEvent: (node, event) {
            // itemFoundation.ts:101-110：Enter 激活（link 不导航，照 breadcrumb）。
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              if (!disabled) {
                widget.onTap();
              }
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : widget.onTap,
            onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
            onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
            onTapCancel: disabled
                ? null
                : () => setState(() => _pressed = false),
            child: focusOutline,
          ),
        ),
      ),
    );
    if (widget.collapsed && !widget.inPopup && !widget.subItem) {
      // Item.tsx:294-296：collapsed 平铺 item 包 tooltip（position: right）。
      return SemiTooltip(
        trigger: SemiTooltipTrigger.hover,
        position: SemiTooltipPosition.right,
        // Item.tsx:162-168 wrapTooltip 无 opts——上游缺省 arrowPointAtCenter:
        // false。
        arrowPointAtCenter: false,
        mouseEnterDelay: _NavigationMetrics.tooltipShowDelay,
        mouseLeaveDelay: _NavigationMetrics.tooltipHideDelay,
        content: text is Widget ? text : Text(text?.toString() ?? ''),
        child: mouse,
      );
    }
    return mouse;
  }

  /// 图标间距（vertical icon-info 右距 12；horizontal 首位图标右距 8——
  /// nav:698-704）。
  double _iconGap(SemiResolvedNavigationThemeData t) => widget.horizontal
      ? t.spacingNavigationHorizontalIconFirstMarginRight
      : t.widthNavigationIconTextBetween;

  /// 图标槽（nav:166-172 icon-info：min-width 20 + 间距）。
  Widget _slot(
    Widget icon,
    SemiResolvedNavigationThemeData t, {
    required double gap,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: gap),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: t.widthNavigationIconLeftMinWidth,
        ),
        child: color == null
            ? icon
            : DefaultTextStyle.merge(
                style: TextStyle(color: color),
                child: icon,
              ),
      ),
    );
  }
}

/// Sub 标题行（SubNav.tsx renderTitleDiv + nav:139-155/:249-255/:441-490）。
class _NavSubTitle extends StatefulWidget {
  const _NavSubTitle({
    required this.item,
    required this.level,
    required this.isOpen,
    required this.selected,
    required this.horizontal,
    required this.inPopup,
    required this.collapsed,
    required this.limitIndent,
    required this.toggleIconPosition,
    required this.expandIcon,
    required this.subNavMotion,
    required this.t,
    required this.onTap,
  });

  final SemiNavigationItem item;
  final int level;
  final bool isOpen;
  final bool selected;
  final bool horizontal;
  final bool inPopup;
  final bool collapsed;
  final bool limitIndent;
  final SemiNavigationToggleIconPosition toggleIconPosition;
  final Widget? expandIcon;
  final bool subNavMotion;
  final SemiResolvedNavigationThemeData t;
  final VoidCallback onTap;

  @override
  State<_NavSubTitle> createState() => _NavSubTitleState();
}

class _NavSubTitleState extends State<_NavSubTitle> {
  bool _hover = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final item = widget.item;
    final disabled = item.disabled;
    final selected = widget.selected;
    final horiz = widget.horizontal && !widget.inPopup;

    // nav:441-442 + mixin 状态（vertical）；nav:667-690 horizontal 系。
    final Color bg;
    final Color textColor;
    final Color iconColor;
    if (horiz) {
      if (disabled) {
        bg = t.colorNavigationHorizontalItemL1DisabledBgDefault;
        textColor = t.colorNavigationHorizontalItemL1DisabledTextDefault;
        iconColor = t.colorNavigationHorizontalItemL1DisabledIconDefault;
      } else if (selected) {
        bg = t.colorNavigationHorizontalItemL1SelectedBgDefault;
        textColor = t.colorNavigationHorizontalItemL1SelectedTextDefault;
        iconColor = t.colorNavigationHorizontalItemL1SelectedIconDefault;
      } else {
        bg = t.colorNavigationHorizontalItemL1BgDefault;
        textColor = (_hover || _pressed)
            ? t.colorNavigationHorizontalItemL1TextHover
            : t.colorNavigationHorizontalItemL1TextDefault;
        iconColor = (_hover || _pressed)
            ? t.colorNavigationHorizontalItemL1IconHover
            : t.colorNavigationHorizontalItemL1IconDefault;
      }
    } else if (disabled) {
      if (selected && (_hover || _pressed)) {
        bg = t.colorNavigationItemL1SelectedDisabledBgDefault;
        textColor = t.colorNavigationItemL1SelectedDisabledTextDefault;
      } else {
        bg = t.colorNavigationItemL1DisabledBgDefault;
        textColor = t.colorNavigationItemL1DisabledTextDefault;
      }
      iconColor = t.colorNavigationItemL1DisabledIconDefault;
    } else if (selected) {
      // nav:444-449 selected：item-selected mixin 后 bg 被覆盖回
      // `colorNavigationItemL1BgDefault`（transparent quirk）；hover/active 走
      // item-hover-selected/item-active-selected（nav:465-476）。
      if (_pressed) {
        bg = t.colorNavigationItemL1BgActive;
        textColor = t.colorNavigationItemL1SelectedTextActive;
      } else if (_hover) {
        bg = t.colorNavigationItemL1BgHover;
        textColor = t.colorNavigationItemL1SelectedTextHover;
      } else {
        bg = t.colorNavigationItemL1BgDefault;
        textColor = t.colorNavigationItemL1SelectedTextDefault;
      }
      iconColor = t.colorNavigationItemL1SelectedIconDefault;
    } else if (_pressed) {
      bg = t.colorNavigationItemL1BgActive;
      textColor = t.colorNavigationItemL1TextActive;
      iconColor = t.colorNavigationItemL1IconActive;
    } else if (_hover) {
      bg = t.colorNavigationItemL1BgHover;
      textColor = t.colorNavigationItemL1TextHover;
      iconColor = t.colorNavigationItemL1IconHover;
    } else {
      bg = t.colorNavigationItemL1BgDefault;
      textColor = t.colorNavigationItemL1TextDefault;
      iconColor = t.colorNavigationItemL1IconDefault;
    }

    // 字重：顶层 sub-title 600（nav:43-45）、selected 600（nav:445）、disabled
    // 600（nav:457）、弹层 400（nav:88 基准）、弹层选中 400（nav:732-734
    // `normal` 关键字 quirk）。
    final FontWeight weight;
    if (widget.inPopup && selected) {
      weight = t.fontNavigationPopoverNavItemSelectedFontWeight;
    } else if (widget.inPopup) {
      weight = t.fontNavigationItemNormalFontWeight;
    } else if (selected) {
      weight = t.fontNavigationSubSelectedFontWeight;
    } else if (disabled) {
      weight = t.fontNavigationSubDisabledFontWeight;
    } else if (widget.level == 0) {
      weight = t.fontNavigationSubTitleFontWeight;
    } else {
      weight = t.fontNavigationSubFontWeight;
    }

    // SubNav.tsx:206-225 toggle 图标选择（collapsed 子层 chevron_right；顶层无；
    // horizontal 子层 chevron_right、顶层 expandIcon ?? chevron_down）。
    final Widget? toggle;
    if (widget.collapsed) {
      toggle = widget.inPopup ? const SemiIcon(SemiIcons.chevronRight) : null;
    } else if (widget.horizontal) {
      toggle = widget.inPopup
          ? const SemiIcon(SemiIcons.chevronRight)
          : (widget.expandIcon ?? const SemiIcon(SemiIcons.chevronDown));
    } else {
      toggle = widget.expandIcon ?? const SemiIcon(SemiIcons.chevronDown);
    }
    // 旋转动画（nav:343-350 硬编码——HARDCODE；horizontal 不旋转 fix#1198，
    // SubNav.tsx:217-218）。
    final Widget? animatedToggle;
    if (toggle != null &&
        !widget.horizontal &&
        !widget.collapsed &&
        widget.subNavMotion) {
      animatedToggle = AnimatedRotation(
        turns: widget.isOpen ? -0.5 : 0,
        // nav:343-350 `transition: transform 200ms ease-in-out`。
        duration: _NavigationMetrics.chevronRotateDuration,
        curve: Curves.easeInOut,
        child: toggle,
      );
    } else {
      animatedToggle = toggle;
    }

    final leading = <Widget>[];
    if (widget.toggleIconPosition == SemiNavigationToggleIconPosition.left &&
        animatedToggle != null) {
      leading.add(
        Flexible(child: _toggleSlot(animatedToggle, t, null, color: iconColor)),
      );
    }
    if (!widget.limitIndent && !widget.collapsed && !horiz) {
      // SubNav.tsx:227-231 占位图标（同 Item.tsx:213-215）。
      final iconAmount =
          (item.icon != null && !_NavItemRowState.indentTruthy(item.indent))
          ? widget.level
          : widget.level - 1;
      for (var i = 0; i < iconAmount; i++) {
        leading.add(
          _toggleSlot(const SizedBox.shrink(), t, null, color: iconColor),
        );
      }
    }
    final showIconSlot =
        item.icon != null ||
        _NavItemRowState.indentTruthy(item.indent) ||
        (!widget.horizontal && widget.level > 0);
    final textIsFirst = leading.isEmpty && !showIconSlot;

    final children = <Widget>[
      // CSS flexbox shrink 语义：窄帧（折叠动画）下各槽位可收缩不溢出
      //（leading 槽位已包 Flexible）。
      ...leading,
      if (showIconSlot)
        Flexible(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: t.widthNavigationIconTextBetween,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: t.widthNavigationIconLeftMinWidth,
              ),
              child: item.icon ?? const SizedBox.shrink(),
            ),
          ),
        ),
      Flexible(
        child: Padding(
          // nav:282 44px 缩进（同 item 规则——文本 first-child 才命中）。
          padding: EdgeInsetsDirectional.only(
            start: widget.level > 0 && textIsFirst
                ? t.spacingNavigationItemPaddingX +
                      t.widthNavigationIconLeft +
                      t.widthNavigationIconTextBetween
                : 0,
          ),
          child: DefaultTextStyle.merge(
            // nav:87 `@include font-size-regular`。
            style: TextStyle(
              fontSize: _NavigationMetrics.fontSizeRegular,
              fontWeight: weight,
              color: textColor,
            ),
            child: item.text is Widget
                ? item.text! as Widget
                : Text(
                    item.text?.toString() ?? '',
                    // nav:94-97
                    // `overflow: hidden; white-space: nowrap; text-overflow: ellipsis`。
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ),
      if (widget.toggleIconPosition == SemiNavigationToggleIconPosition.right &&
          animatedToggle != null)
        Flexible(
          child: _toggleSlot(
            animatedToggle,
            t,
            widget.horizontal
                ? t.spacingNavigationHorizontalIconLastMarginLeft
                : null,
            color: iconColor,
          ),
        ),
    ];

    final row = AnimatedContainer(
      duration: t.transitionDurationNavigationItemL1Bg,
      curve: t.transitionFunctionNavigationItemL1Bg,
      // nav:81-85 行盒 + nav:158 sub-title margin-bottom。
      margin: EdgeInsetsDirectional.only(
        bottom: widget.horizontal
            ? t.spacingNavigationHorizontalNavListItemMarginBottom
            : t.spacingNavigationSubTitleMarginBottom,
        end: widget.horizontal
            ? t.spacingNavigationHorizontalNavListItemNotLastMarginRight
            : 0,
      ),
      padding: EdgeInsets.symmetric(
        vertical: widget.inPopup
            ? t.spacingNavigationDropdownItemNavSubTitlePaddingY
            : t.spacingNavigationItemPaddingY,
        horizontal: widget.inPopup
            ? t.spacingNavigationDropdownItemNavSubTitlePaddingX
            : t.spacingNavigationItemPaddingX,
      ),
      constraints: BoxConstraints(
        minHeight: t.heightNavigationItemBase,
        minWidth: widget.inPopup
            ? t.widthNavigationDropdownItemNavItemMinWidth
            : 0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.widthNavigationItemBorderRadius),
      ),
      child: Row(
        // 弹层（Overlay 无界）/horizontal（横滚无界）shrink-wrap；主树 max 铺满。
        mainAxisSize: widget.inPopup || widget.horizontal
            ? MainAxisSize.min
            : MainAxisSize.max,
        children: children,
      ),
    );

    final focusOutline = Container(
      decoration: _focused
          ? BoxDecoration(
              border: Border.all(
                width: t.widthNavigationOutline,
                color: t.colorNavigationOutlineFocus,
              ),
              borderRadius: BorderRadius.circular(
                t.widthNavigationItemBorderRadius,
              ),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.all(_focused ? -t.widthNavigationOutlineOffset : 0),
        child: row,
      ),
    );

    return Semantics(
      // aria 近似（见差异清单 28）：menuitem 的 selected/disabled/expanded。
      selected: selected,
      enabled: !disabled,
      expanded: widget.isOpen,
      child: MouseRegion(
        // nav:79 `cursor: pointer`；disabled → `cursor: not-allowed`（mix:13/39/71）。
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Focus(
          onKeyEvent: (node, event) {
            // subNavFoundation.ts:132-136：Enter 同样 toggle。
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              if (!disabled) {
                widget.onTap();
              }
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : widget.onTap,
            onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
            onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
            onTapCancel: disabled
                ? null
                : () => setState(() => _pressed = false),
            child: focusOutline,
          ),
        ),
      ),
    );
  }

  /// toggle 槽（nav:181-187 icon-toggle-*：min-width 20 + 间距）。
  Widget _toggleSlot(
    Widget toggle,
    SemiResolvedNavigationThemeData t,
    double? gapOverride, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: gapOverride ?? t.widthNavigationIconTextBetween,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: t.widthNavigationIconLeftMinWidth,
        ),
        child: color == null
            ? toggle
            : DefaultTextStyle.merge(
                style: TextStyle(color: color),
                child: toggle,
              ),
      ),
    );
  }
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）+ motion 解析。
abstract final class _NavigationMetrics {
  /// nav:378 `@include font-size-header-5`（mixin 来源 global
  /// `$font-size-header-5` = 18——header 标题字号）。
  static const double fontSizeHeader5 = 18;

  /// nav:87 `@include font-size-regular`（mixin 来源 global `$font-size-regular`
  /// = 14——条目/标题字号；子级走 `fontNavigationSubFontSize` 同值）。
  static const double fontSizeRegular = 14;

  /// nav:343-350 `transition: transform 200ms ease-in-out`（chevron 旋转）。
  static const Duration chevronRotateDuration = Duration(milliseconds: 200);

  /// constants.ts:23 `DEFAULT_TOOLTIP_SHOW_DELAY: 0`（ms）——
  /// `TOOLTIP_SHOW_DELAY: 0`。
  static const Duration tooltipShowDelay = Duration.zero;

  /// constants.ts:24 `DEFAULT_TOOLTIP_HIDE_DELAY: 100`（ms）——
  /// `TOOLTIP_HIDE_DELAY: 100`。
  static const Duration tooltipHideDelay = Duration(milliseconds: 100);

  /// constants.ts:25 `DEFAULT_SUBNAV_OPEN_DELAY: 0`（ms）——
  /// `SUBNAV_OPEN_DELAY: 0`。
  static const Duration subNavOpenDelay = Duration.zero;

  /// constants.ts:26 `DEFAULT_SUBNAV_CLOSE_DELAY: 100`（ms）——
  /// `SUBNAV_CLOSE_DELAY: 100`。
  static const Duration subNavCloseDelay = Duration(milliseconds: 100);

  /// Sub 内联展开动画时长（上游 Collapsible CSS 高度动画无 token——硬编码近似，
  /// 见差异清单）。
  static const Duration subNavMotionDuration = Duration(milliseconds: 200);

  /// ★String 简写解析（datePicker `transitionDatepickerRangeInput` 字段原文消费
  /// ——折叠动画消费其 duration+curve 语义）：首段时长（`100ms`/`.2s` 等）。
  static Duration parseMotionDuration(String shorthand) {
    final match = RegExp(r'([0-9]*\.?[0-9]+)(ms|s)').firstMatch(shorthand);
    if (match == null) {
      return Duration.zero;
    }
    final value = double.parse(match.group(1)!);
    return match.group(2) == 's'
        ? Duration(milliseconds: (value * 1000).round())
        : Duration(milliseconds: value.round());
  }

  /// ★String 简写解析：`cubic-bezier(a, b, c, d)` → Cubic（含负控制点
  /// `-.1`——Cubic 无 assert）；关键字 `ease-out`/`ease-in-out` 近似映射。
  static Curve parseMotionCurve(String shorthand) {
    final cubic = RegExp(r'cubic-bezier\(([^)]+)\)').firstMatch(shorthand);
    if (cubic != null) {
      final parts = cubic
          .group(1)!
          .split(',')
          .map((p) => double.parse(p.trim()))
          .toList();
      return Cubic(parts[0], parts[1], parts[2], parts[3]);
    }
    if (shorthand.contains('ease-in-out')) {
      return Curves.easeInOut;
    }
    if (shorthand.contains('ease-out')) {
      return Curves.easeOut;
    }
    return Curves.easeIn;
  }

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // nav:343-350 `transition: transform 200ms ease-in-out`（chevron 旋转
  // ——调用点 `_NavSubTitleState.build` AnimatedRotation）。
  //
  // nav:282
  //     `$spacing-base-tight + $width-navigation_icon_left + $width-navigation_icon_text_between`
  // （子级无图标文本缩进 = 12+20+12 = 44px——调用点 `_NavItemRowState.build` /
  // `_NavSubTitleState.build` Padding）。
  //
  // nav:710 `word-wrap: none`（非法 CSS 值 note-only——编译器丢弃，仅
  // `-item-collapsed` 规则携带）。
  //
  // nav:79 `cursor: pointer`（条目手型——调用点 MouseRegion）。
  //
  // mix:13/39/71 `cursor: not-allowed`（禁用光标——调用点 MouseRegion）。
  //
  // nav:17 `user-select: none`（文本不可选——Flutter 默认即不可选，note-only）。
  //
  // nav:94-97 `overflow: hidden; white-space: nowrap; text-overflow: ellipsis`
  // （条目文本单行省略三连——调用点 Text ellipsis）。
  //
  // nav:57-67 折叠渐隐 `opacity: 0` / `opacity: 1`（collapsed 文字/尾图标/头部
  // 文案渐隐——调用点 collapsed 分支）。
  //
  // nav:87 `@include font-size-regular`（条目字号 mixin 来源——14）。
  //
  // nav:378 `@include font-size-header-5`（header 标题字号 mixin 来源——18）。
  //
  // zh_CN.ts:100-103 '收起侧边栏' / '展开侧边栏'（footer 收起按钮缺省文案）。
  //
  // constants.ts:22 `DEFAULT_SUBNAV_MAX_HEIGHT: 999`（死常量 note-only——上游
  // 从未消费）。
  //
  // constants.ts:23 `DEFAULT_TOOLTIP_SHOW_DELAY: 0`（`TOOLTIP_SHOW_DELAY: 0`）。
  //
  // constants.ts:24 `DEFAULT_TOOLTIP_HIDE_DELAY: 100`（`TOOLTIP_HIDE_DELAY: 100`）。
  //
  // constants.ts:25 `DEFAULT_SUBNAV_OPEN_DELAY: 0`（`SUBNAV_OPEN_DELAY: 0`）。
  //
  // constants.ts:26 `DEFAULT_SUBNAV_CLOSE_DELAY: 100`（`SUBNAV_CLOSE_DELAY: 100`）。
  //
  // variables.scss:50/:52 3.5 公式（`($width-navigation_container_collapsed -
  // $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border -
  // $height-navigation_header_logo_collapsed) * 0.5`——header 左内边距，解析值
  // 解析值 3.5，调用点 `_SemiNavigationState._headerPadding`）。
  //
  // nav:373 `object-fit: scale-down`（logo 缩放——调用点 FittedBox scaleDown）。
}
