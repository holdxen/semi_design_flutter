// SemiBreadcrumb — 面包屑（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/breadcrumb/{variables.scss, animation.scss,
// breadcrumb.scss, rtl.scss, foundation.ts, itemFoundation.ts, constants.ts}、
// packages/semi-ui/breadcrumb/{index.tsx, item.tsx, bread-context.tsx}。主题对账
// 20 = 16 FIELDS + 4 MOTION + 0 INTERNAL（tool/generate_breadcrumb.py）——★0 死
// 变量（首个零死变量组件）：variables.scss 16 条 + animation.scss 4 条全被
// breadcrumb.scss / item.tsx 消费，本文件提及全部 20 个字段名
// （test_generate_breadcrumb.py 断言零死标 + 全消费）。
// 4 条 MOTION 是活字段（breadcrumb.scss:4 `@import "./animation.scss"` + :97-98
// 消费，0ms/ease-in/0ms/scale(1,1) 恒等）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_BreadcrumbMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_breadcrumb_theme.dart';
import '../theme/semi_breadcrumb_theme_data.dart';
import '../theme/semi_icon_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_dropdown.dart';
import 'semi_tooltip.dart';

/// 折叠区样式（上游 `strings.MORE_TYPE: ['default', 'popover']`，constants.ts:6
/// ——`default` 是 Dart 保留字，照 `defaultSize` 先例命名 `defaultType`）。
enum SemiBreadcrumbMoreType { defaultType, popover }

/// 路由条目（上游 `Route`/`RouteProps`，itemFoundation.ts:14-20 + item.tsx:16-18）。
class SemiBreadcrumbRoute {
  const SemiBreadcrumbRoute({
    this.name,
    this.href,
    this.icon,
    this.path,
    this.onClick,
  });

  /// 级别名：String | Widget（String 走 [SemiBreadcrumb.itemMaxWidth] 截断 +
  /// tooltip；★Widget 原样无截断 quirk，item.tsx:140 只对 string 走
  /// Typography.Text ellipsis）。
  final Object? name;

  /// 目标链接（仅元数据——Flutter 无 DOM anchor，点击走 onClick 链由应用导航）。
  final String? href;

  /// 级别图标（compact 决定 size：small 12 / default 16，item.tsx:86-96）。
  final Widget? icon;

  /// 路径元数据（genRoutes key 回退 `item-${name || path}-${idx}`，index.tsx:198）。
  final String? path;

  /// 条目自身点击（★先于父 onClick——itemFoundation.ts:29-33）。
  final void Function(SemiBreadcrumbRoute route)? onClick;
}

/// children 模式条目（数据载体——照 `SemiAnchorLink` 形制定稿为纯数据类，
/// [SemiBreadcrumb.children] 强类型消费；上游 `Breadcrumb.Item` 元素 + 克隆注入
/// active/shouldRenderSeparator 的形态由本移植内部等价承担）。
class SemiBreadcrumbItem {
  const SemiBreadcrumbItem({
    this.name,
    this.href,
    this.icon,
    this.onClick,
    this.separator,
    this.noLink = false,
  });

  /// 级别名：String | Widget（String 截断 + tooltip；★Widget 原样无截断 quirk）。
  final Object? name;

  /// 目标链接（仅元数据）。
  final String? href;

  /// 级别图标。
  final Widget? icon;

  /// 条目自身点击（★先于父 onClick）。
  final void Function()? onClick;

  /// 覆盖 context separator（★item.tsx:204 `this.props.separator ||` truthy
  /// 优先且**裸渲染不包壳**；falsy 回退 context——无法用 `''` 隐藏 quirk）。
  final Object? separator;

  /// 去 hover/active 色（item.tsx:178 `item-link: !noLink`）。
  final bool noLink;
}

/// 面包屑。
///
/// 双模式：[routes]（`SemiBreadcrumbRoute | String`——String 自动包装照
/// genRoutes foundation.ts:32-46）优先于 [children]。active 规则
/// （index.tsx:204/:257）：[activeIndex] ?? 末项；★active 项即使有 href 也渲染
/// 不可点 span、cursor default（item.tsx:181 + breadcrumb.scss:67-73）、点击不发
/// onClick。折叠（index.tsx:163-190/:216-269）：`autoCollapse && len >
/// maxItemCount`（★严格大于）且 isCollapsed 初始 true → 隐藏索引
/// `1..len-maxItemCount`（首项恒显、末 maxItemCount-1 项恒显）；more 按钮
/// （[SemiIcons.more]）替换隐藏区；★单向展开不可回收（handleExpand 置 false 后
/// 永不折叠）；more 按钮自身渲染 separator、Enter-only 键盘（foundation.ts:26-30
/// handleExpandEnterPress，Space 不响应 quirk）。
class SemiBreadcrumb extends StatefulWidget {
  const SemiBreadcrumb({
    super.key,
    this.routes,
    this.children = const <SemiBreadcrumbItem>[],
    this.separator = '/',
    this.compact = true,
    this.activeIndex,
    this.maxItemCount = 4,
    this.autoCollapse = true,
    this.moreType = SemiBreadcrumbMoreType.defaultType,
    this.renderMore,
    this.renderItem,
    this.showTooltip = true,
    this.itemMaxWidth = _BreadcrumbMetrics.truncationWidthDefault,
    this.onClick,
    this.semanticsLabel,
  });

  /// 路由条目（`SemiBreadcrumbRoute | String`，String 自动包装）；优先于
  /// [children]（index.tsx:226-229 `hasRoutes` 二选一）。
  final List<Object>? routes;

  /// children 模式条目（[routes] 为空时消费）。
  final List<SemiBreadcrumbItem> children;

  /// 分隔符（String | Widget；item.separator 可逐条覆盖——falsy 回退 quirk）。
  final Object? separator;

  /// 紧凑模式（true → 字号 12 + icon small；false → 字号 14 + icon default）。
  final bool compact;

  /// 选中项索引（缺省末项 active；★越界则无 active——严格相等口径）。
  final int? activeIndex;

  /// 折叠阈值（★`len > maxItemCount` 严格大于才折叠）。
  final int maxItemCount;

  /// 超出阈值时折叠（★单向展开不可回收）。
  final bool autoCollapse;

  /// 折叠区样式：defaultType 点击展开全部；popover 点击弹面板列 restItem。
  final SemiBreadcrumbMoreType moreType;

  /// 自定义折叠区内容（优先于 moreType；restItems 为隐藏项渲染件）。
  final Widget Function(List<Widget> restItems)? renderMore;

  /// 自定义条目内容（routes 模式；替换 name 渲染）。
  final Widget Function(SemiBreadcrumbRoute route)? renderItem;

  /// String name 悬停 tooltip（★false 仍截断 quirk，item.tsx:100-104）。
  final bool showTooltip;

  /// String name 截断宽（上游 showTooltip 对象形态的 `width`，index.tsx:91）。
  final double itemMaxWidth;

  /// 条目点击回传（★item 自身 onClick 先、父 onClick 后——itemFoundation.ts:29-33）。
  final void Function(SemiBreadcrumbRoute route)? onClick;

  /// 根语义名（缺省 `'Breadcrumb'`，index.tsx:97）。
  final String? semanticsLabel;

  /// 折叠 more 按钮（测试度量锚点）。
  static const Key moreKey = ValueKey('SemiBreadcrumbMore');

  /// popover 面板（测试度量锚点）。
  static const Key popoverPanelKey = ValueKey('SemiBreadcrumbPopoverPanel');

  /// 根（测试度量锚点）。
  static const Key rootKey = ValueKey('SemiBreadcrumbRoot');

  @override
  State<SemiBreadcrumb> createState() => _SemiBreadcrumbState();
}

class _SemiBreadcrumbState extends State<SemiBreadcrumb> {
  /// 上游 state.isCollapsed 初值 `true`（index.tsx:104）；★handleExpand 置 false
  /// 后永不折叠（单向展开不可回收，index.tsx:115-118）。
  bool _isCollapsed = true;

  /// popover 面板受控可见（SemiDropdown `visible` 受控口径）。
  bool _popoverOpen = false;

  /// routes 归一化（String 自动包装照 genRoutes foundation.ts:32-46）。
  _Crumb _normalize(SemiBreadcrumbRoute route) => _Crumb(
    route: route,
    // index.tsx:208 `renderItem ? renderItem(route._origin) : route.name`。
    name: widget.renderItem?.call(route) ?? route.name,
    icon: route.icon,
    onClick: route.onClick == null ? null : () => route.onClick!(route),
    separator: null,
    noLink: false,
  );

  /// children 归一化（合成父 onClick 参数：name/href/icon）。
  _Crumb _normalizeItem(SemiBreadcrumbItem item) => _Crumb(
    route: SemiBreadcrumbRoute(
      name: item.name,
      href: item.href,
      icon: item.icon,
    ),
    name: item.name,
    icon: item.icon,
    onClick: item.onClick,
    separator: item.separator,
    noLink: item.noLink,
  );

  /// foundation.ts:21-23 `handleClick`：先 item.onClick 后父 onClick(route)
  /// （itemFoundation.ts:29-33 `notifyClick` + `notifyParent`）。
  void _handleClick(_Crumb crumb) {
    crumb.onClick?.call();
    widget.onClick?.call(crumb.route);
  }

  /// foundation.ts:26-30 `handleExpandEnterPress`——Enter 展开（★Space 不响应
  /// quirk）。
  void _handleExpand() => setState(() => _isCollapsed = false);

  bool get _hasRenderMore => widget.renderMore != null;

  bool get _usesPopover =>
      !_hasRenderMore && widget.moreType == SemiBreadcrumbMoreType.popover;

  @override
  Widget build(BuildContext context) {
    final SemiResolvedBreadcrumbThemeData t = SemiBreadcrumbTheme.resolve(
      context,
    );
    final entries =
        (widget.routes != null && widget.routes!.isNotEmpty
                ? widget.routes!.map(
                    (route) => _normalize(
                      route is SemiBreadcrumbRoute
                          ? route
                          : SemiBreadcrumbRoute(name: route),
                    ),
                  )
                : widget.children.map(_normalizeItem))
            .toList();
    final length = entries.length;
    // index.tsx:235 `shouldCollapse`——★len > maxItemCount 严格大于。
    final shouldCollapse =
        widget.autoCollapse && length > widget.maxItemCount && _isCollapsed;
    final restLength = length - widget.maxItemCount;
    final fontSize = widget.compact
        ? t.fontBreadcrumbCompactFontSize
        : t.fontBreadcrumbLooseFontSize;

    // 隐藏项渲染件（restItems——item.tsx:206/:258 hidden 项 separator 抑制
    // quirk：restItem 自拼 separator，条目本体不带 separator）。
    final restItems = <Widget>[
      for (var idx = 1; idx <= restLength; idx++)
        _buildCell(
          entry: entries[idx],
          active: widget.activeIndex != null
              ? widget.activeIndex == idx
              : idx == length - 1,
          shouldRenderSeparator: false,
          t: t,
          fontSize: fontSize,
        ),
    ];

    final cells = <Widget>[];
    for (var idx = 0; idx < length; idx++) {
      // inCollapseArea = idx > 0 && idx <= restItemLength（index.tsx:199/:245）
      // ——隐藏项整格跳过（renderMore/popover 时经 restItems 二次渲染，separator
      // 已抑制）。
      if (shouldCollapse && idx > 0 && idx <= restLength) continue;
      cells.add(
        _buildCell(
          entry: entries[idx],
          active: widget.activeIndex != null
              ? widget.activeIndex == idx
              : idx == length - 1,
          // index.tsx:206/:258：末项无 separator。
          shouldRenderSeparator: idx != length - 1,
          t: t,
          fontSize: fontSize,
        ),
      );
      if (shouldCollapse && idx == 0) {
        cells.add(
          _buildMoreCell(restItems: restItems, t: t, fontSize: fontSize),
        );
      }
    }

    return Semantics(
      label: widget.semanticsLabel ?? 'Breadcrumb',
      container: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: fontSize),
        child: Wrap(
          key: SemiBreadcrumb.rootKey,
          // breadcrumb.scss:13-14 `flex-wrap: wrap`（wrapper 换行）。
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: cells,
        ),
      ),
    );
  }

  /// item-wrap 行（item.tsx:194-215 `render`：item + 可选 separator）。
  Widget _buildCell({
    required _Crumb entry,
    required bool active,
    required bool shouldRenderSeparator,
    required SemiResolvedBreadcrumbThemeData t,
    required double fontSize,
  }) {
    return Semantics(
      // item.tsx:202 `aria-current: "page"`——Flutter 无 aria-current 对应，
      // 以 selected 近似（见差异清单）。
      selected: active,
      link: !active && !entry.noLink && entry.route.href != null,
      label: entry.name is String ? entry.name as String : null,
      child: Padding(
        // breadcrumb.scss:30-31 item-wrap marginY + marginRight（RTL 翻
        // margin-left，rtl.scss:10-13——EdgeInsetsDirectional 自然翻边）。
        padding: EdgeInsetsDirectional.only(
          top: t.spacingBreadcrumbItemWrapMarginY,
          bottom: t.spacingBreadcrumbItemWrapMarginY,
          end: t.spacingBreadcrumbItemWrapMarginRight,
        ),
        child: Row(
          // breadcrumb.scss:28-29
          // `display: inline-flex; align-items: center`（item-wrap 容器）。
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              // breadcrumb.scss:39 item marginRight（RTL 翻边，rtl.scss:15-18）。
              padding: EdgeInsetsDirectional.only(
                end: t.spacingBreadcrumbItemMarginRight,
              ),
              child: _BreadcrumbItemView(
                entry: entry,
                active: active,
                t: t,
                fontSize: fontSize,
                compact: widget.compact,
                showTooltip: widget.showTooltip,
                itemMaxWidth: widget.itemMaxWidth,
                onTap: active ? null : () => _handleClick(entry),
              ),
            ),
            if (shouldRenderSeparator)
              _buildSeparator(
                override: entry.separator,
                t: t,
                fontSize: fontSize,
              ),
          ],
        ),
      ),
    );
  }

  /// separator（item.tsx:204 `this.props.separator || <span class=separator>`）：
  /// ★item.separator truthy 优先且裸渲染不包壳；falsy 回退 context separator
  /// （包壳着色 `colorBreadcrumbSepearatorDefaultIconDefault`）。
  Widget _buildSeparator({
    required Object? override,
    required SemiResolvedBreadcrumbThemeData t,
    required double fontSize,
  }) {
    // ★truthy 判定照 JS `||`：null/'' 均 falsy → 回退 context（无法用 `''`
    // 隐藏 quirk）。
    if (override != null && !(override is String && override.isEmpty)) {
      // ★裸渲染不包壳 quirk（item.tsx:204）。
      return override is Widget ? override : Text(override.toString());
    }
    final Object sep = widget.separator ?? '';
    final child = sep is Widget ? sep : Text(sep.toString());
    // breadcrumb.scss:116-119 separator 包壳 + 着色（★`sepearator` typo
    // 照抄——variables.scss:13 变量名上游原文错拼）。
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: fontSize,
        color: t.colorBreadcrumbSepearatorDefaultIconDefault,
      ),
      child: child,
    );
  }

  /// 折叠 more 行（index.tsx:163-190 `handleCollapse`：more 按钮 + 自带
  /// separator）。
  Widget _buildMoreCell({
    required List<Widget> restItems,
    required SemiResolvedBreadcrumbThemeData t,
    required double fontSize,
  }) {
    return Semantics(
      child: Padding(
        // breadcrumb.scss:30-31 item-wrap marginY + marginRight。
        padding: EdgeInsetsDirectional.only(
          top: t.spacingBreadcrumbItemWrapMarginY,
          bottom: t.spacingBreadcrumbItemWrapMarginY,
          end: t.spacingBreadcrumbItemWrapMarginRight,
        ),
        child: Row(
          // breadcrumb.scss:28-29
          // `display: inline-flex; align-items: center`。
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // breadcrumb.scss:38 `// flex-shrink: 0;`（注释留档）+ :111-114
            // `&-collapse { flex-shrink: 0 }`。
            Focus(
              onKeyEvent: (node, event) {
                // foundation.ts:26-30 `handleExpandEnterPress`——Enter-only
                // （★Space 不响应 quirk）。
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  if (_usesPopover) {
                    setState(() => _popoverOpen = true);
                  } else {
                    _handleExpand();
                  }
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  key: SemiBreadcrumb.moreKey,
                  behavior: HitTestBehavior.opaque,
                  // defaultType/renderMore：点击展开全部（popover 模式点击由
                  // SemiDropdown trigger: click 接管弹面板——见差异清单）。
                  onTap: _usesPopover ? null : _handleExpand,
                  child: Semantics(
                    button: true,
                    label: 'Expand breadcrumb items',
                    child: Padding(
                      // breadcrumb.scss:35-36
                      // `display: inline-flex; align-items: center`。
                      padding: EdgeInsetsDirectional.only(
                        // breadcrumb.scss:39 item marginRight（item-more 同款）。
                        end: t.spacingBreadcrumbItemMarginRight,
                      ),
                      child: _hasRenderMore
                          ? widget.renderMore!(restItems)
                          : _usesPopover
                          ? _buildPopover(restItems, t)
                          : const SemiIcon(SemiIcons.more),
                    ),
                  ),
                ),
              ),
            ),
            // index.tsx:182-184 more 按钮自身渲染 separator。
            _buildSeparator(override: null, t: t, fontSize: fontSize),
          ],
        ),
      ),
    );
  }

  /// popover 面板（index.tsx:130-161 `renderPopoverMore`）。
  ///
  /// ★自决点：上游 Popover（trigger 缺省 hover、`padding: 12` 硬编码、
  /// showArrow）→ 本移植用 [SemiDropdown]（trigger: click + content 自绘面板
  /// ——menu: SemiDropdownItemData 形态承载不了 restItem 横向行 + 自拼 separator，
  /// 故取 content 自绘；showArrow 不移植、面板内点击即收起 clickToHide）。
  Widget _buildPopover(
    List<Widget> restItems,
    SemiResolvedBreadcrumbThemeData t,
  ) {
    final sep = widget.separator;
    final children = <Widget>[];
    for (var i = 0; i < restItems.length; i++) {
      children.add(restItems[i]);
      if (i != restItems.length - 1) {
        // index.tsx:138-144 restItem 间自拼 separator（`restItem` 类包壳）。
        children.add(
          Padding(
            // breadcrumb.scss:123 restItem marginRight（RTL 翻边）。
            padding: EdgeInsetsDirectional.only(
              end: t.spacingBreadcrumbRestItemMarginRight,
            ),
            child: DefaultTextStyle.merge(
              // breadcrumb.scss:121-122 restItem 着色。
              style: TextStyle(color: t.colorBreadcrumbRestItemTextDefault),
              child: sep is Widget ? sep : Text(sep.toString()),
            ),
          ),
        );
      }
    }
    return SemiDropdown(
      trigger: SemiTooltipTrigger.click,
      clickToHide: true,
      visible: _popoverOpen,
      onVisibleChange: (open) => setState(() => _popoverOpen = open),
      content: Padding(
        // index.tsx:153-155 `padding: 12`（popover 面板硬编码）。
        padding: const EdgeInsets.all(_BreadcrumbMetrics.popoverPadding),
        child: Wrap(
          key: SemiBreadcrumb.popoverPanelKey,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ),
      child: const SemiIcon(SemiIcons.more),
    );
  }
}

/// item（item.tsx:135-192 `renderBreadItem` + `renderItem`）：hover/press 态行内
/// 自治（色态四字段）。
class _BreadcrumbItemView extends StatefulWidget {
  const _BreadcrumbItemView({
    required this.entry,
    required this.active,
    required this.t,
    required this.fontSize,
    required this.compact,
    required this.showTooltip,
    required this.itemMaxWidth,
    required this.onTap,
  });

  final _Crumb entry;
  final bool active;
  final SemiResolvedBreadcrumbThemeData t;
  final double fontSize;
  final bool compact;
  final bool showTooltip;
  final double itemMaxWidth;

  /// 点击链入口（active 为 null——不发 onClick quirk）。
  final VoidCallback? onTap;

  @override
  State<_BreadcrumbItemView> createState() => _BreadcrumbItemViewState();
}

class _BreadcrumbItemViewState extends State<_BreadcrumbItemView> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final active = widget.active;
    final noLink = widget.entry.noLink;
    // breadcrumb.scss:40/:64 色态四字段：
    // default `colorBreadcrumbDefaultTextDefault`（text-2）、hover
    // `colorBreadcrumbDefaultTextHover`（colorLink）、pressed
    // `colorBreadcrumbDefaultTextActive`（colorLinkHover）、选中
    // `colorBreadcrumbActiveTextDefault`（text-0，hover/active →
    // `colorBreadcrumbActiveTextActive`）。★noLink 去 hover/active 色
    // （item.tsx:178 无 item-link 类）。
    final Color color;
    if (active) {
      color = (_hover || _pressed)
          ? t.colorBreadcrumbActiveTextActive
          : t.colorBreadcrumbActiveTextDefault;
    } else if (noLink) {
      color = t.colorBreadcrumbDefaultTextDefault;
    } else {
      color = _hover
          ? t.colorBreadcrumbDefaultTextHover
          : _pressed
          ? t.colorBreadcrumbDefaultTextActive
          : t.colorBreadcrumbDefaultTextDefault;
    }
    return MouseRegion(
      // breadcrumb.scss:67-73 `cursor: default`（active 项）；可点项 click
      // 光标（:102/:107 `cursor: pointer`）；noLink 无 item-link 类 → default。
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // ★active 项点击不发 onClick（不跳转 quirk——item.tsx:181 active 渲染
        // 不可点 span）。
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Transform.scale(
          // breadcrumb.scss:98 `transform: scale($transform_scale-breadcrumb_link-text)`
          // （恒等 scale(1,1) → Transform.scale 消费 SemiTransform 字段）。
          // ★上游编译产物 `transform: scale(scale(1,1))` 无效 CSS bug
          // （semi.css:3349）——视觉无影响留档（note-only）。
          scaleX: t.transformScaleBreadcrumbLinkText.scaleX,
          scaleY: t.transformScaleBreadcrumbLinkText.scaleY,
          child: AnimatedDefaultTextStyle(
            // breadcrumb.scss:97
            // `transition: color $transition_duration-breadcrumb_link-text $transition-function_breadcrumb_link-text $transition_delay-breadcrumb_link-text`
            // ——duration/curve 槽消费；`transitionDelayBreadcrumbLinkText` 无
            // delay 槽 → 注释引用（docs 注明）。★quirk 照抄：使用处
            // `$transition-function_breadcrumb_link-text`（`_`）vs 声明
            // `$transition_function-breadcrumb_link-text`（`-`）混写。
            // breadcrumb.scss:96 `text-decoration: inherit`。
            duration: t.transitionDurationBreadcrumbLinkText,
            curve: t.transitionFunctionBreadcrumbLinkText,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: active
                  ? t.fontBreadcrumbActiveFontWeight
                  : t.fontBreadcrumbDefaultFontWeight,
              color: color,
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  /// item 内容行（icon + name；item.tsx:135-170 `renderBreadItem`）。
  Widget _buildContent(BuildContext context) {
    final children = <Widget>[];
    final icon = widget.entry.icon;
    if (icon != null) {
      children.add(
        Transform.translate(
          // breadcrumb.scss:81 `margin-bottom: -1px`（icon 基线 quirk——
          // inline-flex align-items:center 下等效下移 0.5px，Transform.translate
          // 近似；见差异清单）。
          offset: const Offset(0, 0.5),
          child: SemiIconTheme(
            // item.tsx:86-96 `renderIcon`：compact ? 'small' : 'default'。
            data: SemiIconThemeData(
              size: widget.compact ? SemiIconSize.small : SemiIconSize.normal,
            ),
            child: icon,
          ),
        ),
      );
    }
    final name = widget.entry.name;
    if (name != null) {
      if (children.isNotEmpty) {
        // breadcrumb.scss:37
        // `column-gap: $spacing-breadcrumb_item_text-marginLeft`（icon-title
        // 间距）；★RTL 双倍 quirk：rtl.scss:21-25 在 column-gap 之外又给 title
        // 加 margin-right——间距 8（column-gap + rtl margin-right 并存）。
        final rtl = Directionality.of(context) == TextDirection.rtl;
        children.add(
          SizedBox(
            width: widget.t.spacingBreadcrumbItemTextMarginLeft * (rtl ? 2 : 1),
          ),
        );
      }
      children.add(_buildName(name));
    }
    // breadcrumb.scss:35-36 `display: inline-flex; align-items: center`（item）。
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  /// name 渲染（item.tsx:135-170）：★String 走截断 + tooltip；Widget 原样无
  /// 截断 quirk。
  Widget _buildName(Object name) {
    if (name is! String) {
      // Widget（或非 String）原样渲染（item.tsx:162-169 inline 分支）。
      return name is Widget ? name : Text(name.toString());
    }
    Widget text = ConstrainedBox(
      // item.tsx:148-152 `style: { maxWidth: width }`（ellipsis 截断）。
      constraints: BoxConstraints(maxWidth: widget.itemMaxWidth),
      // ★showTooltip=false 仍截断 quirk（item.tsx:100-104 仅裁掉 tooltip，
      // width/ellipsis 照旧）。
      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    if (widget.showTooltip) {
      text = SemiTooltip(
        trigger: SemiTooltipTrigger.hover,
        // item.tsx:111 `position: 'top'`（opts 缺省 autoAdjustOverflow: true
        // ——SemiTooltip 自带；对象形态 opts 裁剪见差异清单）。
        position: SemiTooltipPosition.top,
        content: Text(name, style: TextStyle(fontSize: widget.fontSize)),
        child: text,
      );
    }
    return text;
  }
}

/// 归一化条目（routes/children 两模式统一渲染载体）。
class _Crumb {
  const _Crumb({
    required this.route,
    required this.name,
    required this.icon,
    required this.onClick,
    required this.separator,
    required this.noLink,
  });

  /// 父 onClick 参数（routes 模式 = 原 route；children 模式合成 name/href/icon）。
  final SemiBreadcrumbRoute route;

  /// 渲染内容（String | Widget——renderItem 输出已是 Widget）。
  final Object? name;

  final Widget? icon;

  /// item 自身 onClick（★先于父 onClick）。
  final VoidCallback? onClick;

  /// item.separator 覆盖（children 模式）。
  final Object? separator;

  final bool noLink;
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _BreadcrumbMetrics {
  /// index.tsx:90-93 showTooltip 缺省 + item.tsx:102/:107 —— `width: 150`
  /// （String name 截断宽）。
  static const double truncationWidthDefault = 150;

  /// index.tsx:153-155 popover 面板 `padding: 12`。
  static const double popoverPadding = 12;

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // index.tsx:97 缺省语义名 `'Breadcrumb'`（aria-label 缺省；调用点
  // `SemiBreadcrumb.build` Semantics）。
  //
  // breadcrumb.scss:81 `margin-bottom: -1px`（icon 基线 quirk——调用点
  // `_BreadcrumbItemViewState._buildContent` Transform.translate 近似）。
  //
  // breadcrumb.scss:67-73 `cursor: default`（active 项 hover/active 光标）。
  //
  // breadcrumb.scss:13-14 `flex-wrap: wrap`（wrapper 换行——调用点 Wrap）。
  //
  // breadcrumb.scss:10 `overflow: hidden`（死规则 note-only——根类是 wrapper，
  // `.semi-breadcrumb` 选择器永不命中）。
  //
  // breadcrumb.scss:98 / semi.css:3349 `transform: scale(scale(1,1))`（无效
  // 编译 bug note-only——token 自带 scale(1,1) 再包 scale(...)，视觉无影响）。
  //
  // breadcrumb.scss:38 `// flex-shrink: 0;`（注释留档）。
  //
  // breadcrumb.scss:96 `text-decoration: inherit`（link 继承文本装饰）。
  //
  // breadcrumb.scss:37
  //     `column-gap: $spacing-breadcrumb_item_text-marginLeft`
  // （icon-title 间距；RTL 双倍 quirk 见调用点）。
  //
  // breadcrumb.scss:28-29 / :35-36
  //     `display: inline-flex; align-items: center`
  // （item-wrap / item 行内弹性容器）。
  //
  // foundation.ts:26-30 `handleExpandEnterPress`（more 按钮 Enter-only 键盘，
  // ★Space 不响应 quirk）。
  //
  // item.tsx:111 `position: 'top'`（tooltip opts 缺省位置——docs 写 bottomLeft
  // 与代码不一致，留档见差异清单）。
  //
  // variables.scss:13 `sepearator`（分割线变量名上游原文错拼）。
}
