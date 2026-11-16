// SemiFloatButton — 悬浮按钮（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/floatButton/{variables.scss, floatButton.scss,
// rtl.scss（空）, constants.ts}、packages/semi-ui/floatButton/{index.tsx,
// floatButtonGroup.tsx, interface.ts}。
// 主题对账 39 = 39 FIELDS + 0 MOTION + 0 INTERNAL（tool/generate_float_button.py）
// ——39 条 variables.scss 声明全落 theme 字段，2 条死变量（上游零消费，本文件
// 不得提及其字段名）；`zFloatButton` / `zFloatButtonGroup` 留档不消费（CSS
// z-index 无 Flutter 槽——叠放由宿主 Stack 子序决定）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_FloatButtonMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_float_button_theme.dart';
import '../theme/semi_float_button_theme_data.dart';
import 'semi_badge.dart';

/// 形状（上游 `shape` / `strings.SHAPE`，缺省 `round`）。
enum SemiFloatButtonShape { square, round }

/// 尺寸（上游 `size` / `strings.SIZE`，缺省 `default` → `defaultSize`，
/// `SemiAnchorSize.defaultSize` 先例）。
enum SemiFloatButtonSize { small, defaultSize, large }

/// 徽章参数（上游 `badge: BadgeProps` 展开到 Badge 的视觉字段子集）。
///
/// ★`position` 未移植：floatButton 的 badge 被 floatButton.scss:64-110
/// 挪位规则钉在圆角对角线点上（见差异清单），BadgeProps.position 的四角语义
/// 在本组件内不成立。
class SemiFloatButtonBadge {
  const SemiFloatButtonBadge({
    this.count,
    this.dot = false,
    this.type = SemiBadgeType.primary,
    this.variant = SemiBadgeVariant.solid,
    this.overflowCount,
  }) : assert(
         count == null || count is num || count is String || count is Widget,
       );

  /// 计数内容（上游 `count`）：num/String/Widget，语义同 [SemiBadge.count]。
  final Object? count;

  /// 点状徽标（上游 `dot`，缺省 false）。
  final bool dot;

  /// 颜色类型（上游 `type`，缺省 primary）。
  final SemiBadgeType type;

  /// 填充样式（上游 `theme`，缺省 solid）。
  final SemiBadgeVariant variant;

  /// 数字溢出上限（上游 `overflowCount`）。
  final num? overflowCount;
}

/// 悬浮按钮组点击事件（上游 item 容器冒泡点击 MouseEvent 的
/// `stopPropagation()` 对应物；同步可取消，派发完成后封印——
/// SemiCheckboxChangeEvent 惯例）。
class SemiFloatButtonGroupClickEvent {
  bool _stopped = false, _active = true;

  /// 冒泡是否已断。
  bool get propagationStopped => _stopped;

  /// 取消冒泡到组 [SemiFloatButtonGroup.onClick]（上游 item 回调内
  /// `e.stopPropagation()`——itemProps.test.jsx `respects stopPropagation`）。
  void stopPropagation() {
    if (_active) _stopped = true;
  }
}

/// 悬浮按钮组子项（上游 `FloatButtonGroupItem`）。
///
/// ★上游继承 `FloatButtonProps` 但渲染只消费 icon/content/badge/disabled/
/// href/target/onClick/value——shape/colorful/size 为死接口面（见差异清单）。
class SemiFloatButtonGroupItem {
  const SemiFloatButtonGroupItem({
    this.value,
    this.content,
    this.icon,
    this.badge,
    this.disabled = false,
    this.href,
    this.target,
    this.onClick,
  }) : assert(content == null || content is String || content is Widget);

  /// 子项标识（上游 `value` → `data-value`；组回调回传，无值则 null——
  /// `item.dataset.value` 口径）。
  final String? value;

  /// 文本内容（上游 `content`：string | ReactNode → String 或 Widget）。
  final Object? content;

  /// 图标（上游 `icon`）。
  final Widget? icon;

  /// 徽章参数（上游 `badge: BadgeProps`）。
  final SemiFloatButtonBadge? badge;

  /// 禁用（上游 `disabled`——★仅断回调、无视觉差，见差异清单）。
  final bool disabled;

  /// 目标链接（href 元数据——Flutter 不导航，照 breadcrumb 口径应用自理）。
  final String? href;

  /// 链接打开目标（target 元数据，不导航）。
  final String? target;

  /// 子项点击（上游 `onClick(e)`；事件内 `stopPropagation()` 可断组回调）。
  final void Function(SemiFloatButtonGroupClickEvent event)? onClick;
}

/// 悬浮按钮。
///
/// 渲染（index.tsx:49-75）：外层 div（size/shape 类）> 可选 Badge > body div
/// （shape/colorful/disabled/size 类）> icon。点击（:27-47 `handleClick`）：
/// disabled 即断（:30），随后 href 跳转（:35-41，★不移植——href/target 仅
/// 元数据）+ `onClick(e)` 回传。定位：上游 `position: fixed`
/// （floatButton.scss:8）+ `bottom`/`right` 主题间距（:9-10）→ 本移植为宿主
/// [Stack] 直接子节点 [PositionedDirectional]（见差异清单）。
class SemiFloatButton extends StatefulWidget {
  const SemiFloatButton({
    super.key,
    this.shape = SemiFloatButtonShape.round,
    this.size = SemiFloatButtonSize.defaultSize,
    this.colorful = false,
    this.disabled = false,
    this.icon,
    this.badge,
    this.onClick,
    this.href,
    this.target,
    this.semanticsLabel,
  });

  /// 形状（上游 `shape`，缺省 round——index.tsx:18 `shape: 'round'`）。
  final SemiFloatButtonShape shape;

  /// 尺寸（上游 `size`，缺省 default——index.tsx:20 `size: 'default'`）。
  final SemiFloatButtonSize size;

  /// 多彩（上游 `colorful`，缺省 false——index.tsx:19 `colorful: false`；
  /// ★colorful 类级联在 disabled 之后——colorful + disabled 时多彩视觉胜出
  /// quirk，见差异清单）。
  final bool colorful;

  /// 禁用（上游 `disabled`：断点击 + 禁用配色 + `cursor: not-allowed`）。
  final bool disabled;

  /// 图标（上游 `icon: ReactNode`）。
  final Widget? icon;

  /// 徽章参数（上游 `badge: BadgeProps`——包在 body 外层）。
  final SemiFloatButtonBadge? badge;

  /// 点击回传（上游 `onClick(e: MouseEvent)`——e 无对应，anchor 偏差同口径）。
  final VoidCallback? onClick;

  /// 目标链接（href 元数据——Flutter 不导航，照 breadcrumb 口径应用自理）。
  final String? href;

  /// 链接打开目标（target 元数据，不导航）。
  final String? target;

  /// 语义名（★上游无 aria-label——本移植补 Semantics button，见差异清单）。
  final String? semanticsLabel;

  /// 按钮主体盒（测试度量锚点）。
  static const Key bodyKey = ValueKey('SemiFloatButtonBody');

  /// badge 挪位锚（测试度量锚点——外层定位是 PositionedDirectional，
  /// badge 挪位层同型，需独立锚点区分）。
  static const Key badgeAnchorKey = ValueKey('SemiFloatButtonBadgeAnchor');

  @override
  State<SemiFloatButton> createState() => _SemiFloatButtonState();
}

class _SemiFloatButtonState extends State<SemiFloatButton> {
  bool _hovering = false, _pressed = false;
  late final FocusNode _focusNode = FocusNode(debugLabel: 'SemiFloatButton');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// index.tsx:27-47 `handleClick`（:30 `if (disabled) { return; }` 断路；
  /// :35-41 href 跳转不移植；`onClick(e)` 回传）。
  void _handleTap() {
    if (widget.disabled) return;
    widget.onClick?.call();
  }

  /// ★偏差（统一交互约定）：上游静态 div 无键盘激活（index.tsx:63
  /// jsx-a11y 禁用注释）——本移植补 Enter（Space/可打印键忽略，锚点
  /// keyboardActivation 同口径）。
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      _handleTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// floatButton.scss:14-53 body 配色（-body/-disabled/-colorful 三条类规则
  /// 同挂 body div；★-disabled（:31）在 -colorful（:41）之前——同特异性后
  /// 者胜，colorful + disabled 残留多彩视觉 quirk）。hover/active 对应
  /// `&:hover` / `&:active`（:22-28 / :36-38 / :44-51）。
  ///
  /// 多彩底走 `SemiGradient` token（button colorful 先例）——body 为固定
  /// width×width 盒，按已知边长 `forSize` 预解析（fluid 盒的
  /// `_SemiGradientBox` 涂装口径等价）。
  ({Color? bg, Gradient? gradient, Color text}) _bodyColors(
    SemiResolvedFloatButtonThemeData t,
    double width,
  ) {
    if (widget.colorful) {
      final gradient = _pressed
          ? t.colorFloatButtonColorfulBgActive
          : _hovering
          ? t.colorFloatButtonColorfulBgHover
          : t.colorFloatButtonColorfulBg;
      return (
        bg: null,
        gradient: gradient.forSize(Size.square(width)),
        text: t.colorFloatButtonColorfulText,
      );
    }
    if (widget.disabled) {
      return (
        bg: t.colorFloatButtonDisabledBg,
        gradient: null,
        text: t.colorFloatButtonDisabledText,
      );
    }
    return (
      bg: _pressed
          ? t.colorFloatButtonBgActive
          : _hovering
          ? t.colorFloatButtonBgHover
          : t.colorFloatButtonBg,
      gradient: null,
      text: t.colorFloatButtonText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiFloatButtonTheme.resolve(context);
    final double width = switch (widget.size) {
      SemiFloatButtonSize.small => t.widthFloatButtonSmall,
      SemiFloatButtonSize.defaultSize => t.widthFloatButton,
      SemiFloatButtonSize.large => t.widthFloatButtonLarge,
    };
    final colors = _bodyColors(t, width);

    // floatButton.scss:14-20 body 盒（flex 居中——`display: flex` /
    // `align-items: center` / `justify-content: center` → Alignment.center）。
    Widget body = Container(
      key: SemiFloatButton.bodyKey,
      width: width,
      height: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bg,
        gradient: colors.gradient,
        // floatButton.scss:115-121 形状圆角（`-square` 方形 /
        // `-round` 全圆）。
        borderRadius: BorderRadius.circular(
          widget.shape == SemiFloatButtonShape.square
              ? t.radiusFloatButtonSquare
              : t.radiusFloatButtonRound,
        ),
        boxShadow: t.shadowFloatButton.toBoxShadows(),
      ),
      // body `color: $color-floatButton-text`（:17）——icon 走 currentColor
      // / DefaultTextStyle 色。
      child: DefaultTextStyle(
        style: TextStyle(color: colors.text),
        child: widget.icon ?? const SizedBox.shrink(),
      ),
    );

    if (widget.badge case final badge?) {
      // floatButton.scss:55-113 badge 挪位八条 `top: calc(...)` /
      // `inset-inline-end: calc(...)`：badge 中心骑在圆角对角线上
      // （0.29 * R——`(√2 - 1)/√2 * R = 0.29 * R`，方形 R = 方形圆角、
      // 圆形 R = 0.5 * 边长）。
      final double inset = switch (widget.shape) {
        SemiFloatButtonShape.square =>
          _FloatButtonMetrics.badgeCornerFactor * t.radiusFloatButtonSquare,
        SemiFloatButtonShape.round =>
          _FloatButtonMetrics.badgeCornerFactor * 0.5 * width,
      };
      body = Stack(
        clipBehavior: Clip.none,
        children: [
          body,
          PositionedDirectional(
            key: SemiFloatButton.badgeAnchorKey,
            top: inset,
            end: inset,
            child: FractionalTranslation(
              // 默认角（rightTop/ltr、leftTop/rtl）的 translate 居中标注。
              translation: Directionality.of(context) == TextDirection.rtl
                  ? const Offset(-0.5, -0.5)
                  : const Offset(0.5, -0.5),
              child: SemiBadge(
                count: badge.count,
                dot: badge.dot,
                type: badge.type,
                variant: badge.variant,
                overflowCount: badge.overflowCount,
              ),
            ),
          ),
        ],
      );
    }

    return PositionedDirectional(
      // floatButton.scss:9-10 `bottom: $spacing-floatButton-bottom;
      // right: $spacing-floatButton-right;`（RTL 自动翻边——inset-inline 等价）。
      // floatButton.scss:11 `z-index: $z-floatButton`——★无 z-index Flutter 槽
      // （SemiTooltip.zIndex / zBacktop 同口径）：叠放由宿主 Stack 子序决定；
      // `zFloatButton` 无消费槽 → 注释引用（transitionDelayAnchorTitleText 先例，
      // docs 注明）。
      end: t.spacingFloatButtonRight,
      bottom: t.spacingFloatButtonBottom,
      child: Semantics(
        button: true,
        enabled: !widget.disabled,
        label: widget.semanticsLabel,
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _onKey,
          child: MouseRegion(
            // floatButton.scss:12 `cursor: pointer`；:34 `cursor: not-allowed`
            // （禁用 → forbidden）。
            cursor: widget.disabled
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: widget.disabled
                  ? null
                  : (_) => setState(() => _pressed = true),
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerCancel: (_) => setState(() => _pressed = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.disabled ? null : _handleTap,
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 悬浮按钮组。
///
/// 渲染（floatButtonGroup.tsx:67-105）：容器（inline-flex + padding + gap）>
/// 逐项行（icon + content，badge 可选外挂）。点击（:41-66）：容器委托
/// `e.target.closest` 读 `item.dataset.value`（:45/49，★DOM 委托不移植——
/// 逐项 GestureDetector，见差异清单）→ 组 `onClick(value, e)`（:50）；
/// 子项先走 `handleItemClick`（:53-66）：disabled 断路（:54-57
/// `e.stopPropagation()`——子项与组回调均不达），否则 href 跳转（:57-63，
/// ★不移植）+ `item.onClick(e)`，回调内可 `stopPropagation()` 断组回调。
class SemiFloatButtonGroup extends StatelessWidget {
  const SemiFloatButtonGroup({
    super.key,
    required this.items,
    this.disabled = false,
    this.onClick,
    this.semanticsLabel,
  });

  /// 子项列表（上游 `items`）。
  final List<SemiFloatButtonGroupItem> items;

  /// 禁用（上游 `disabled`——★仅断回调、无视觉差，见差异清单）。
  final bool disabled;

  /// 组点击回传（上游 `onClick(value: string, e: MouseEvent)`——
  /// `e.currentTarget` 无对应；事件即子项派发的同一实例）。
  final void Function(String? value, SemiFloatButtonGroupClickEvent event)?
  onClick;

  /// 语义名（★上游无 aria-label——本移植补 Semantics，见差异清单）。
  final String? semanticsLabel;

  /// 组容器盒（测试度量锚点）。
  static const Key groupKey = ValueKey('SemiFloatButtonGroup');

  /// 子项行（测试度量锚点；按 index 附加）。
  static Key itemKey(int index) => ValueKey('SemiFloatButtonGroupItem$index');

  /// floatButtonGroup.tsx:41-66 点击派发（★`e.target.closest` / :49
  /// `item.dataset.value` DOM 委托 → 逐项回调直调）：禁用断路、子项回调先于
  /// 组回调、`stopPropagation()` 断组（itemProps.test.jsx 口径）。
  void _dispatch(SemiFloatButtonGroupItem item) {
    if (disabled || item.disabled) {
      // floatButtonGroup.tsx:55 `e.stopPropagation()`——禁用断路：子项与组
      // 回调均不达（itemProps.test.jsx `does not activate a disabled item` /
      // `does not run item actions when the whole group is disabled`）。
      return;
    }
    final event = SemiFloatButtonGroupClickEvent();
    item.onClick?.call(event);
    if (!event.propagationStopped) {
      // floatButtonGroup.tsx:50 `this.props.onClick?.(value, e)`。
      onClick?.call(item.value, event);
    }
    // 派发完成封印（SemiCheckboxChangeEvent 惯例）。
    event._active = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiFloatButtonTheme.resolve(context);
    return PositionedDirectional(
      // floatButton.scss:127-128 `bottom: $spacing-floatButton_group-bottom;
      // right: $spacing-floatButton_group-right;`。
      // floatButton.scss:129 `z-index: $z-floatButton_group`——★无 z-index
      // Flutter 槽（zBacktop 同口径）：叠放由宿主 Stack 子序决定；
      // `zFloatButtonGroup` 无消费槽 → 注释引用（docs 注明）。
      end: t.spacingFloatButtonGroupRight,
      bottom: t.spacingFloatButtonGroupBottom,
      child: Semantics(
        container: true,
        label: semanticsLabel,
        child: Container(
          key: SemiFloatButtonGroup.groupKey,
          // floatButton.scss:124-134 组容器（`display: inline-flex` →
          // Row shrink-wrap；`padding: $spacing-floatButton_group-padding`；
          // `gap: $spacing-floatButton_group-columnGap`）。
          decoration: BoxDecoration(
            color: t.colorFloatButtonGroupBg,
            borderRadius: BorderRadius.circular(
              t.radiusFloatButtonGroupBorderRadius,
            ),
            boxShadow: t.shadowFloatButtonGroup.toBoxShadows(),
          ),
          padding: EdgeInsets.all(t.spacingFloatButtonGroupPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: t.spacingFloatButtonGroupColumnGap,
            children: [
              for (final (index, item) in items.indexed)
                _GroupItemView(
                  key: SemiFloatButtonGroup.itemKey(index),
                  item: item,
                  onTap: () => _dispatch(item),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 组子项行（hover/active 底色——floatButton.scss:149-155 `&:hover` /
/// `&:active`）。
class _GroupItemView extends StatefulWidget {
  const _GroupItemView({super.key, required this.item, required this.onTap});

  final SemiFloatButtonGroupItem item;
  final VoidCallback onTap;

  @override
  State<_GroupItemView> createState() => _GroupItemViewState();
}

class _GroupItemViewState extends State<_GroupItemView> {
  bool _hovering = false, _pressed = false;
  late final FocusNode _focusNode = FocusNode(
    debugLabel: 'SemiFloatButtonGroupItem',
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// ★偏差（统一交互约定）：上游静态 div 无键盘激活——补 Enter（锚点
  /// keyboardActivation 同口径）。
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final t = SemiFloatButtonTheme.resolve(context);
    final Object? content = item.content;
    // floatButtonGroup.tsx:79-87 `<Badge {...item.badge}><div item/></Badge>`
    // ——badge 包裹可点行（badge 在点击目标之外，dot 命中不触发子项回调）。
    Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Container(
        // floatButton.scss:136-147 `&-item`（`padding:
        // $spacing-floatButton_group_item-paddingY
        // $spacing-floatButton_group_item-paddingX`；`column-gap:
        // $spacing-floatButton_group_item-columnGap`；`font-style:
        // normal` → TextStyle 注释留档）。
        padding: EdgeInsets.symmetric(
          vertical: t.spacingFloatButtonGroupItemPaddingY,
          horizontal: t.spacingFloatButtonGroupItemPaddingX,
        ),
        decoration: BoxDecoration(
          color: _pressed
              ? t.colorFloatButtonGroupItemBgActive
              : _hovering
              ? t.colorFloatButtonGroupItemBgHover
              : null,
          borderRadius: BorderRadius.circular(
            t.radiusFloatButtonGroupItemBorderRadius,
          ),
        ),
        // `color: $color-floatButton_group_item-text` + font 三件
        // （fontSize/fontWeight/lineHeight）→ DefaultTextStyle 级联
        // （icon currentColor / Text 同源）。
        child: DefaultTextStyle(
          style: TextStyle(
            color: t.colorFloatButtonGroupItemText,
            fontSize: t.fontFloatButtonGroupItemFontSize,
            height:
                t.fontFloatButtonGroupItemLineHeight /
                t.fontFloatButtonGroupItemFontSize,
            fontWeight: t.fontFloatButtonGroupItemFontWeight,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: t.spacingFloatButtonGroupItemColumnGap,
            children: [
              if (item.icon != null) item.icon!,
              if (content != null)
                content is Widget ? content : Text('$content'),
            ],
          ),
        ),
      ),
    );
    if (item.badge case final badge?) {
      row = SemiBadge(
        count: badge.count,
        dot: badge.dot,
        type: badge.type,
        variant: badge.variant,
        overflowCount: badge.overflowCount,
        child: row,
      );
    }
    return Semantics(
      button: true,
      enabled: !item.disabled,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: MouseRegion(
          // floatButton.scss:137 `cursor: pointer`（★禁用不改光标 quirk）。
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => setState(() => _pressed = true),
            onPointerUp: (_) => setState(() => _pressed = false),
            onPointerCancel: (_) => setState(() => _pressed = false),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _FloatButtonMetrics {
  /// badge 挪位对角线因子（`(√2 - 1）/√2 * R = 0.29 * R`，floatButton.scss
  /// badge 注释计算式）。
  static const double badgeCornerFactor = 0.29;

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // constants.ts:16 `SHAPE: ['square', 'round']`（形状枚举）。
  //
  // constants.ts:17 `SIZE: ['small', 'default', 'large']`（尺寸枚举）。
  //
  // index.tsx:18 `shape: 'round'`（缺省形状；floatButtonGroup.tsx:32 死
  // defaultProps 同字面量）。
  //
  // index.tsx:19 `colorful: false`（缺省非多彩）。
  //
  // index.tsx:20 `size: 'default'`（缺省尺寸）。
  //
  // index.tsx:36 `window.open(href, '_blank')`（href 新窗跳转——不移植，
  // href/target 仅元数据，breadcrumb 先例）。
  //
  // index.tsx:38 `window.location.href = href`（同窗跳转——同上不移植）。
  //
  // floatButton.scss:8 `position: fixed`（视口固定 → PositionedDirectional
  // 宿主 Stack 子节点，见差异清单）。
  //
  // floatButton.scss:12 `cursor: pointer`（→ MouseRegion(SystemMouseCursors.click)）。
  //
  // floatButton.scss:34 `cursor: not-allowed`（禁用光标 → SystemMouseCursors.forbidden）。
  //
  // floatButton.scss:18 `display: flex`（body 居中盒——Flex 恒等）。
  //
  // floatButton.scss:19 `align-items: center`（→ Alignment.center）。
  //
  // floatButton.scss:20 `justify-content: center`（→ Alignment.center）。
  //
  // floatButton.scss:64-65 badge 挪位（方形）
  //     top: calc(0.29 * $radius-floatButton_square)
  //     inset-inline-end: calc(0.29 * $radius-floatButton_square)
  // （badge 中心骑方形圆角对角线——调用点 build 的 inset 计算）。
  //
  // floatButton.scss:82-83 badge 挪位（默认尺寸圆形）
  //     top: calc(0.29 * 0.5 * $width-floatButton)
  //     inset-inline-end: calc(0.29 * 0.5 * $width-floatButton)
  // （R = 0.5 * 边长）。
  //
  // floatButton.scss:96-97 badge 挪位（小尺寸圆形）
  //     top: calc(0.29 * 0.5 * $width-floatButton_small)
  //     inset-inline-end: calc(0.29 * 0.5 *$width-floatButton_small)
  // （★上游 `*$width` 少一空格 quirk——逐字照抄）。
  //
  // floatButton.scss:109-110 badge 挪位（大尺寸圆形）
  //     top: calc(0.29 * 0.5 * $width-floatButton_large)
  //     inset-inline-end: calc(0.29 * 0.5 * $width-floatButton_large)
  //
  // floatButton.scss:132 `display: inline-flex`（组容器 → Row shrink-wrap）。
  //
  // floatButton.scss:145 `font-style: normal`（子项文字样式恒等——注释留档）。
  //
  // floatButtonGroup.tsx:33 `type: 'default'`（死 defaultProps——`type` 非组
  // props，接口死面 quirk）。
  //
  // floatButtonGroup.tsx:34 `size: 'medium'`（死 defaultProps——`size` 非组
  // props）。
  //
  // floatButtonGroup.tsx:45 `e.target.closest`（DOM 委托定项——不移植，逐项
  // GestureDetector，见差异清单）。
  //
  // floatButtonGroup.tsx:49 `item.dataset.value`（DOM 读值——→ `item.value`
  // 直读）。
  //
  // floatButtonGroup.tsx:55 `e.stopPropagation()`（禁用断路——子项与组回调
  // 均不达）。
  //
  // floatButtonGroup.tsx:58 `window.open(item.href, '_blank')`（子项新窗
  // 跳转——不移植，href/target 元数据）。
  //
  // floatButtonGroup.tsx:60 `window.location.href = item.href`（子项同窗
  // 跳转——同上不移植）。
  //
  // floatButtonGroup.tsx:50 `this.props.onClick?.(value, e)`（组回调派发——
  // 调用点 `_dispatch`）。
}
