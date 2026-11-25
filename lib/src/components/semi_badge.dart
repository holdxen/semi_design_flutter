// SemiBadge — 上游 packages/semi-ui/badge/index.tsx 与
// packages/semi-foundation/badge/{badge.scss,rtl.scss,variables.scss,
// constants.ts} 的移植。
//
// 主题对账 **37 = 37 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 37 声明：
// color 28、width 2、height 2、radius 1、spacing 2、z 2；无 animation.scss；
// `$module` 胶水与 rtl.scss 不计；banner `22 = 22 FIELDS + 0 MOTION + 0
// INTERNAL` 先例）。2 死 FIELDS（`$color-badge_default_light-bg-default`、
// `$z-badge_light-bg`——死变量留档不消费）；`$z-badge` 的 CSS z-index 无
// Flutter 对应（徽标以尾位 Stack 子置顶），字段留档不消费。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts `strings`：TYPE_SET: ['success', 'primary', 'secondary', 'tertiary', 'warning', 'danger']、
//   THEME_SET: ['solid', 'light', 'inverted']、
//   POS_SET: ['leftTop', 'leftBottom', 'rightTop', 'rightBottom']
// - index.tsx defaultProps：type: 'primary'、theme: 'solid'
// - index.tsx render：direction === 'rtl' ? 'leftTop' : 'rightTop'（缺省
//   position 随方向）
// - index.tsx render：isNumber(count) || isString(count)（custom 判定）、
//   count !== null && typeof count !== 'undefined'（showBadge 判定）
// - index.tsx render：overflowCount && overflowCount < count 溢出门槛、
//   `${overflowCount}+` 溢出格式
// - badge.scss `-count`：@include font-size-small（12px/16px）、
//   font-weight: $font-weight-regular、
//   border-radius: $height-badge_count * 0.5、text-align: center
// - badge.scss `-dot`/`-count`：box-sizing: border-box（Flutter 装饰边框
//   内含等价）
// - badge.scss `-custom`：display: flex（自定义内容原样铺开）
// - badge.scss 根/`-block`：position: relative / position: static
// - badge.scss 四角定位偏移：transform: translate(50%, -50%)（rightTop）、
//   transform: translate(50%, 50%)（rightBottom）、
//   transform: translate(-50%, -50%)（leftTop）、
//   transform: translate(-50%, 50%)（leftBottom）
// - rtl.scss：direction: rtl（Directionality 自然覆盖）
import 'package:flutter/widgets.dart';

import '../theme/semi_badge_theme.dart';
import '../theme/semi_theme.dart';

/// 类型（上游 `BadgeType` / `strings.TYPE_SET`，缺省 `primary`）。
enum SemiBadgeType { primary, secondary, tertiary, danger, warning, success }

/// 填充样式（上游 `theme` / `strings.THEME_SET`，缺省 `solid`）。
enum SemiBadgeVariant { solid, light, inverted }

/// 徽标锚角（上游 `BadgePosition` / `strings.POS_SET`；缺省随方向）。
enum SemiBadgePosition { leftTop, leftBottom, rightTop, rightBottom }

/// 角标/点状徽标。包裹 child 时四角锚定悬浮，无 child 时独立展示
///（上游 `-block`）；`count` 为 num/String 时出数字/文本徽标、为 Widget 时
/// 自定义徽标（custom 不吃 type/variant 颜色，内容自带样式）。
class SemiBadge extends StatelessWidget {
  const SemiBadge({
    super.key,
    this.count,
    this.dot = false,
    this.type = SemiBadgeType.primary,
    this.variant = SemiBadgeVariant.solid,
    this.position,
    this.overflowCount,
    this.child,
    this.onTap,
  }) : assert(
         count == null || count is num || count is String || count is Widget,
       );

  /// 计数内容（上游 `count`）：num 按 `overflowCount` 溢出格式化（整数值不带
  /// `.0`——JS String(N) 语义）、String 原样、Widget 自定义（custom）。
  /// null 且非 dot 时无徽标盒（上游零尺寸 span）。
  final Object? count;

  /// 点状徽标（上游 `dot`，缺省 false）；dot 时隐藏 count 内容。
  final bool dot;

  /// 颜色类型（上游 `type`，缺省 primary）。
  final SemiBadgeType type;

  /// 填充样式（上游 `theme`，缺省 solid）。
  final SemiBadgeVariant variant;

  /// 锚角（上游 `position`）；缺省 ltr → rightTop、rtl → leftTop
  ///（`direction === 'rtl' ? 'leftTop' : 'rightTop'`）。仅在 child 存在时
  /// 锚定，无 child 走独立展示。
  final SemiBadgePosition? position;

  /// 数字溢出上限（上游 `overflowCount`）：count 为 num 且 `overflowCount &&
  /// overflowCount < count` 时显示 `${overflowCount}+`（★0 视为 falsy 不溢出）。
  final num? overflowCount;

  /// 被包裹内容（上游 `children`）；null 时徽标独立展示（上游 `-block`）。
  final Widget? child;

  /// 点按（上游根 span 的 `onClick` 透传；onMouseEnter/onMouseLeave 无视觉
  /// 语义未移植）。
  final VoidCallback? onTap;

  /// JS `String(count)` 语义：整数值不带 `.0`。
  static String _formatNum(num value) =>
      value is int || value == value.roundToDouble()
      ? '${value.round()}'
      : '$value';

  /// `overflowCount && overflowCount < count` + `${overflowCount}+`。
  String get _countText {
    final count = this.count!;
    if (count is String) return count;
    final n = count as num;
    final overflow = overflowCount;
    return overflow != null && overflow != 0 && overflow < n
        ? '${_formatNum(overflow)}+'
        : _formatNum(n);
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiBadgeTheme.resolve(context);
    // custom = `count && !(isNumber(count) || isString(count))`；showBadge =
    // `count !== null && typeof count !== 'undefined'`。
    final custom = count is Widget;
    final showBadge = count != null;
    final (solidBg, lightBg, lightText, invertedText) = switch (type) {
      SemiBadgeType.primary => (
        t.colorBadgePrimarySolidBgDefault,
        t.colorBadgePrimaryLightBgDefault,
        t.colorBadgePrimaryLightTextDefault,
        t.colorBadgePrimaryInvertedTextDefault,
      ),
      SemiBadgeType.secondary => (
        t.colorBadgeSecondarySolidBgDefault,
        t.colorBadgeSecondaryLightBgDefault,
        t.colorBadgeSecondaryLightTextDefault,
        t.colorBadgeSecondaryInvertedTextDefault,
      ),
      SemiBadgeType.tertiary => (
        t.colorBadgeTertiarySolidBgDefault,
        t.colorBadgeTertiaryLightBgDefault,
        t.colorBadgeTertiaryLightTextDefault,
        t.colorBadgeTertiaryInvertedTextDefault,
      ),
      SemiBadgeType.danger => (
        t.colorBadgeDangerSolidBgDefault,
        t.colorBadgeDangerLightBgDefault,
        t.colorBadgeDangerLightTextDefault,
        t.colorBadgeDangerInvertedTextDefault,
      ),
      SemiBadgeType.warning => (
        t.colorBadgeWarningSolidBgDefault,
        t.colorBadgeWarningLightBgDefault,
        t.colorBadgeWarningLightTextDefault,
        t.colorBadgeWarningInvertedTextDefault,
      ),
      SemiBadgeType.success => (
        t.colorBadgeSuccessSolidBgDefault,
        t.colorBadgeSuccessLightBgDefault,
        t.colorBadgeSuccessLightTextDefault,
        t.colorBadgeSuccessInvertedTextDefault,
      ),
    };
    // 类选择器 `&-{type} { &-{theme} }`：solid 换底、light 换底 + 换字、
    // inverted 只换字（底留 default）；custom 两类均不吃（上游 `!custom`）。
    var bg = t.colorBadgeDefaultBgDefault;
    var text = t.colorBadgeDefaultTextDefault;
    switch (variant) {
      case SemiBadgeVariant.solid:
        bg = solidBg;
      case SemiBadgeVariant.light:
        bg = lightBg;
        text = lightText;
      case SemiBadgeVariant.inverted:
        text = invertedText;
    }
    final border = t.colorBadgeDefaultBorderDefault;

    // dot 覆盖 count 显示（`dot ? null : content`）；custom 不出盒样式类，
    // 自定义内容原样渲染。
    Widget? box;
    if (dot) {
      box = Container(
        width: t.widthBadgeDot,
        height: t.heightBadgeDot,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(width: t.widthBadgeBorder, color: border),
          // `var(--semi-border-radius-circle)`（= 50，百分比值——消费按
          // `size * value / 100`，steps 先例）→ 8 × 50 / 100 = 4 = 正圆。
          borderRadius: BorderRadius.circular(
            t.widthBadgeDot * t.radiusBadgeDot / 100,
          ),
        ),
      );
    } else if (custom) {
      box = count! as Widget;
    } else if (showBadge) {
      // `-count`：18 高、最小宽 18（盒含 1px 描边）、
      // `border-radius: $height-badge_count * 0.5` 胶囊、
      // `text-align: center`；`@include font-size-small`（12px/16px）+
      // `font-weight: $font-weight-regular`。
      final fontSize = global.typography.fontSizeSmall;
      box = Container(
        height: t.heightBadgeCount,
        constraints: BoxConstraints(minWidth: t.heightBadgeCount),
        padding: EdgeInsets.symmetric(
          vertical: t.spacingBadgeCountPaddingY,
          horizontal: t.spacingBadgeCountPaddingX,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(width: t.widthBadgeBorder, color: border),
          borderRadius: BorderRadius.circular(t.heightBadgeCount * 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          _countText,
          style: TextStyle(
            color: text,
            fontSize: fontSize,
            // No fixed line-height: inherit from DefaultTextStyle.
            fontWeight: global.typography.fontWeightRegular,
          ),
        ),
      );
    }

    Widget body;
    if (box == null) {
      body = child ?? const SizedBox.shrink();
    } else if (child == null) {
      body = box;
    } else {
      // 根 `position: relative` + 四角 `transform: translate`：Stack 内
      // 尾位子 + FractionalTranslation 等价（`Clip.none` 保留出角悬浮）。
      final pos =
          position ??
          (Directionality.of(context) == TextDirection.rtl
              ? SemiBadgePosition.leftTop
              : SemiBadgePosition.rightTop);
      final (top, right, bottom, left, offset) = switch (pos) {
        SemiBadgePosition.rightTop => (
          0.0,
          0.0,
          null,
          null,
          const Offset(0.5, -0.5),
        ),
        SemiBadgePosition.rightBottom => (
          null,
          0.0,
          0.0,
          null,
          const Offset(0.5, 0.5),
        ),
        SemiBadgePosition.leftTop => (
          0.0,
          null,
          null,
          0.0,
          const Offset(-0.5, -0.5),
        ),
        SemiBadgePosition.leftBottom => (
          null,
          null,
          0.0,
          0.0,
          const Offset(-0.5, 0.5),
        ),
      };
      body = Stack(
        clipBehavior: Clip.none,
        children: [
          child!,
          Positioned(
            top: top,
            right: right,
            bottom: bottom,
            left: left,
            child: FractionalTranslation(translation: offset, child: box),
          ),
        ],
      );
    }
    if (onTap == null) return body;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: body,
    );
  }
}
