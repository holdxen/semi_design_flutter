// SemiAvatar — 上游 packages/semi-ui/avatar/{index.tsx,avatarGroup.tsx,
// TopSlotSvg.tsx} 与 packages/semi-foundation/avatar/{avatar.scss,
// variables.scss, animation.scss, mixin.scss} 的移植。
//
// 主题对账 **99 = 89 FIELDS + 10 MOTION + 0 INTERNAL**（variables.scss 89 声明
// + animation.scss 10 声明；`$module` 类名胶水、`$colors` 列表与 rtl.scss 的
// `direction: rtl` 不计；datePicker `223 = 220 + 3 + 0` … skeleton
// `17 = 15 FIELDS + 2 MOTION + 0 INTERNAL` 先例）。★1 死变量
// （`$width-avatar-bottom_slot_square_extra_small-border`，类名拼写不匹配的
// 事实死，见下方 square slot quirk），其余全部消费。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - mixin.scss:2 `background-color: rgba(var(--semi-#{$color}-3), 1)` —— 16 色
//   文字头像背景 = palette `{color}-3`（实时读取）。
// - mixin.scss:3 `color: rgba(var(--semi-white), 1)` —— 16 色文字头像白字。
// - avatar.scss:43 `.semi-avatar-label` `font-size-regular` + `font-weight: $font-weight-bold`
//   基础字型；small 档 `font-size-small`、default 档 `font-size-header-5`、
//   medium 档 `font-size-header-4`、large 档 `font-size-header-1`（均实时引用
//   theme.typography 对应 token）。
// - avatar.scss:57-60 `transform: scale(0.8)`（xs 两档 content 缩放）——被
//   index.tsx:243-246 行内 `transform: scale(...)` 覆盖，字符串内容从不生效
//   （死 CSS，Flutter 端不复现）。
// - avatar.scss:145 `object-fit: cover` —— 图片铺满裁切（CSS `&-image` 类与
//   index.tsx:380 的 `-img` 拼写不匹配，透明背景实际由不加颜色类达成）。
// - index.tsx:34-40 defaultProps `size: 'medium'`、`color: 'grey'`、
//   `shape: 'circle'`、`gap: 3`（`default` 档枚举名 normal）。
// - foundation.ts:57 `gap * 2 < nodeWidth` —— 字符串内容按 nodeWidth-gap*2
//   等比缩小（Flutter 端 Padding(gap)+FittedBox.scaleDown 等价）。
// - avatar.scss:27 `outline: $width-avatar-outline solid` —— focus 轮廓。
// - index.tsx:394 `role: 'listitem'`（组内）/ avatarGroup.tsx:92 `role='list'`。
// - avatarGroup.tsx:65-66 `Number of remaining Avatars` + `+${restNumber}`。
// - avatar.scss:411 `z-index: $z-avatar-default - $i`（start 首项最上）/
//   avatar.scss:414 `z-index: $z-avatar-default - 20 + $i`（end 末项最上）。
// - avatar.scss:367 `box-sizing: border-box` —— 组描边画在盒内（覆盖式环）。
// - TopSlotSvg.tsx:12 盾形路径
//   `M40.4918 46.5592C44.6795 43.176 46.261 34.1333 47.5301 25.6141C49.5854 11.8168 39.6662 1 25.8097 1C11.2857 1 3 11.4279 3 25.3518C3 33.7866 6.29361 43.8947 10.4602 46.5592C12.5868 47.9192 12.5868 47.9051 25.8097 47.9192C38.3651 47.9282 38.5352 48.14 40.4918 46.5592Z`
//   （51×52 viewBox，y 31.7392→47.9333 纵向渐变 + dy 1.65809/模糊 1.10539 投影）。
// - index.tsx:438 slot 渲染守卫 `"extra-small", "small", "default", "medium", "large", "extra-large"`
//   （topSlot 另需 circle；★extra-small 的 top slot 无任何 CSS 尺寸类 ——
//   零样式 quirk，仅继承字渲染）。
// - avatar.scss:332 `shape_square-extra_small` —— 底部 square 类名拼写
//   （下划线）与渲染的 `shape_square-extra-small`（连字符）不匹配，规则从不
//   命中：square+extra-small 的 font-size 回落继承的 `font-size-regular`，
//   border-width 回落 CSS 初始 `medium` = 3。
// - avatar.scss:276 `transform: translateY(50%)` —— 底部 slot 骑底边定位。
// - avatar.scss:509 `animation: $animation_duration-additionalBorder linear infinite`
//   呼吸描边 / :513 `animation: $animation_duration-content linear infinite`
//   内容脉冲。
// - avatar.scss:438 top/left: `-1 *  $width-avatar_additional-border - $spacing-avatar_additional-borderGap`
//   环外扩偏移。
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_avatar_theme.dart';
import '../theme/semi_avatar_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';

/// 头像形状（上游 `shape: 'circle' | 'square'`，缺省 circle）。
enum SemiAvatarShape { circle, square }

/// 头像尺寸七档。上游 `size: 'default'`（40px）→ 枚举 `normal`（`default` 是
/// Dart 关键字）；`customSize` 可传任意边长（上游 size 自由字符串）。
enum SemiAvatarSize {
  extraExtraSmall,
  extraSmall,
  small,
  normal,
  medium,
  large,
  extraLarge,
}

/// 16 个 palette 色 + white。★constants.ts `strings.COLOR` 含 `'white'` 但
/// avatar.scss `$colors` 只有 16 色 —— white 无背景样式（透明底、文字随宿主）。
enum SemiAvatarColor {
  amber,
  blue,
  cyan,
  green,
  grey,
  indigo,
  lightBlue,
  lightGreen,
  lime,
  orange,
  pink,
  purple,
  red,
  teal,
  violet,
  yellow,
  white,
}

/// 头像组叠压方向（上游 `overlapFrom: 'start' | 'end'`，缺省 start）。
enum SemiAvatarOverlapFrom { start, end }

/// 顶部角标（上游 `topSlot`）。`render` 整体替换默认渲染（上游语义）。
class SemiAvatarTopSlot {
  const SemiAvatarTopSlot({
    this.render,
    this.text,
    this.textColor,
    this.gradientStart,
    this.gradientEnd,
  });
  final Widget Function()? render;
  final Widget? text;
  final Color? textColor, gradientStart, gradientEnd;
}

/// 底部角标（上游 `bottomSlot`）。`render` 整体替换默认渲染。
class SemiAvatarBottomSlot {
  const SemiAvatarBottomSlot({
    this.render,
    this.shape = SemiAvatarShape.circle,
    this.text,
    this.bgColor,
    this.textColor,
  });
  final Widget Function()? render;
  final SemiAvatarShape shape;
  final Widget? text;
  final Color? bgColor, textColor;
}

/// 额外描边环（上游 `border: { color, motion } | true`）。
class SemiAvatarBorder {
  const SemiAvatarBorder({this.color, this.motion = false});
  final Color? color;
  final bool motion;
}

/// 非 Material 头像。图片（src）优先于文字（text）优先于 child。
///
/// 上游 index.tsx：图片加载失败时回落文字内容（`onImageError` 返回 false
/// 可保留图片占位）；字符串内容按 `gap` 自动缩放；onTap 存在时可聚焦，
/// Enter 触发、Escape 失焦。
class SemiAvatar extends StatefulWidget {
  const SemiAvatar({
    super.key,
    this.text,
    this.child,
    this.src,
    this.alt,
    this.color = SemiAvatarColor.grey,
    this.shape = SemiAvatarShape.circle,
    this.size = SemiAvatarSize.medium,
    this.customSize,
    this.gap = 3,
    this.onTap,
    this.onImageError,
    this.hoverMask,
    this.border,
    this.contentMotion = false,
    this.topSlot,
    this.bottomSlot,
    this.backgroundColor,
    this.textColor,
    this.semanticsLabel,
  });

  /// 文字内容（字符串头像，自动缩放）。
  final String? text;

  /// 自定义内容（图标等；图片与文字均缺席时渲染）。
  final Widget? child;

  /// 图片源。加载失败回落 [text]/[child]。
  final ImageProvider? src;

  /// 语义/无障碍描述（上游 `alt`）。
  final String? alt;

  final SemiAvatarColor color;
  final SemiAvatarShape shape;
  final SemiAvatarSize size;

  /// 自由边长（上游 size 自由字符串）；设置后覆盖 [size] 的盒尺寸，文字回落
  /// 基础 `font-size-regular`，square 圆角回落 0（无尺寸类 quirk）。
  final double? customSize;

  /// 文字自动缩放的水平留白（上游 `gap`，缺省 3）。
  final double gap;

  final VoidCallback? onTap;

  /// 图片加载失败回调；返回 `false` 保留图片占位、不回落文字（上游 onError
  /// 契约）。
  final bool Function()? onImageError;

  /// 悬浮遮罩（上游 `hoverMask`，hover 时铺满头像）。
  final Widget? hoverMask;

  /// 额外描边环；null 关闭。
  final SemiAvatarBorder? border;

  /// 内容脉冲（1000ms scale 1→0.9→1 循环）。
  final bool contentMotion;

  final SemiAvatarTopSlot? topSlot;
  final SemiAvatarBottomSlot? bottomSlot;

  /// Flutter 额外覆盖（不来自 Sass）。
  final Color? backgroundColor, textColor;

  /// 覆盖语义标签；缺省按 `alt ?? text` 生成（clickable 时带前缀）。
  final String? semanticsLabel;

  @override
  State<SemiAvatar> createState() => _SemiAvatarState();
}

class _SemiAvatarState extends State<SemiAvatar>
    with TickerProviderStateMixin {
  bool _imgFailed = false, _hovering = false, _focused = false;
  final _focus = FocusNode();
  late final AnimationController _content = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didUpdateWidget(SemiAvatar old) {
    super.didUpdateWidget(old);
    // index.tsx:145-158 src 变化重新探测加载状态。
    if (old.src != widget.src) _imgFailed = false;
  }

  @override
  void dispose() {
    _content.dispose();
    _ring.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _handleImageError() {
    // foundation.ts:34-40 handleImgLoadError：onError 返回 false 保留图片位。
    final keep = widget.onImageError?.call() == false;
    if (!keep && !_imgFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _imgFailed = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiAvatarTheme.resolve(context);
    final scope = _AvatarGroupScope.maybeOf(context);
    // 组内 size/shape 由 Group 统一决定（avatarGroup.tsx:86 cloneElement 语义）。
    final size = scope != null ? scope.size : widget.size;
    final shape = scope != null ? scope.shape : widget.shape;
    final box = widget.customSize ?? _boxOf(size, t);
    final radius = widget.customSize != null
        ? (shape == SemiAvatarShape.circle ? box / 2 : 0.0)
        : shape == SemiAvatarShape.circle
        // `$radius-avatar: var(--semi-border-radius-circle)` —— 50%，SemiLength
        // 按盒尺寸解析。
        ? t.radiusAvatar.resolveRadius(Size.square(box)).x
        : _radiusOf(size, t);
    final clickable = widget.onTap != null;
    final imgVisible = widget.src != null && !_imgFailed;

    // mixin.scss:2-3 `background-color: rgba(var(--semi-#{$color}-3), 1)` /
    // `color: rgba(var(--semi-white), 1)`；white 无样式类（quirk）。
    Color bg, fg;
    if (imgVisible) {
      bg = const Color(0x00000000);
      fg = global.palette.white.toColor();
    } else if (widget.color == SemiAvatarColor.white) {
      bg = const Color(0x00000000);
      fg = DefaultTextStyle.of(context).style.color ?? const Color(0xff000000);
    } else {
      bg = _paletteLevel3(widget.color, global);
      fg = global.palette.white.toColor();
    }
    if (widget.backgroundColor != null) bg = widget.backgroundColor!;
    if (widget.textColor != null) fg = widget.textColor!;

    Widget content;
    if (imgVisible) {
      content = Image(
        image: widget.src!,
        // avatar.scss:145 `object-fit: cover`。
        fit: BoxFit.cover,
        width: box,
        height: box,
        errorBuilder: (context, error, stack) {
          _handleImageError();
          return const SizedBox.shrink();
        },
      );
    } else if (widget.text != null) {
      // avatar.scss:43 基础 `font-size-regular` + `font-weight: $font-weight-bold`；
      // 尺寸档 mixin：`font-size-small`/`font-size-header-5`/`font-size-header-4`/
      // `font-size-header-1`；xxs/xl 用显式 Sass 字号。customSize 无尺寸类 →
      // 回落 `font-size-regular`。
      final (fontSize, lineHeight) = widget.customSize != null
          ? (global.typography.fontSizeRegular, global.typography.lineHeightRegular)
          : _labelOf(size, global, t);
      // foundation.ts:57 `gap * 2 < nodeWidth` —— 可用宽 nodeWidth-gap*2，
      // FittedBox.scaleDown 与 scale(nodeWidth-gap*2)/textWidth 等价。
      content = Padding(
        padding: EdgeInsets.all(widget.gap),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.text!,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              height: lineHeight / fontSize,
              fontWeight: global.typography.fontWeightBold,
              color: fg,
            ),
          ),
        ),
      );
    } else {
      content = widget.child ?? const SizedBox.shrink();
    }

    Widget body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: box,
        child: DecoratedBox(
          decoration: BoxDecoration(color: bg),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: Center(child: content)),
              if (_hovering && widget.hoverMask != null)
                Positioned.fill(child: widget.hoverMask!),
            ],
          ),
        ),
      ),
    );
    if (_focused) {
      // avatar.scss:27 `outline: $width-avatar-outline solid` + :30-32
      // `color-avatar-outline-focus` 轮廓（外描边，不占布局）。
      body = CustomPaint(
        foregroundPainter: _AvatarFocusPainter(
          t.colorAvatarOutlineFocus,
          t.widthAvatarOutline,
          radius,
        ),
        child: body,
      );
    }

    // avatar.scss:513 `animation: $animation_duration-content linear infinite`
    // 内容脉冲（0%→50%→100% scale）。
    _content.duration = t.animationDurationContent;
    if (widget.contentMotion) {
      if (!_content.isAnimating) _content.repeat();
      body = AnimatedBuilder(
        animation: _content,
        builder: (context, child) => Transform.scale(
          scale: _pulse(_content.value, t),
          child: child,
        ),
        child: body,
      );
    } else if (_content.isAnimating) {
      _content.stop();
      _content.value = 0;
    }

    final label = widget.semanticsLabel ??
        (() {
          // index.tsx:221/231-232 `clickable Avatar: ${alt}` 前缀 quirk。
          final base = widget.alt ?? widget.text ?? '';
          return clickable ? 'clickable Avatar: $base' : base;
        })();
    final interactive = Semantics(
      label: label,
      button: clickable,
      onTap: widget.onTap,
      // 上游 aria-label 覆盖内容文本（excludeSemantics 等价）。
      excludeSemantics: true,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: clickable,
        onFocusChange: (v) => setState(() => _focused = v),
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _focus.unfocus();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap, child: body),
      ),
    );

    final ringW = t.widthAvatarAdditionalBorder;
    final ringGap = t.spacingAvatarAdditionalBorderGap;
    final hasRing = widget.border != null;
    final slotSizes = _slotSizes.contains(size);
    final showTop = widget.topSlot != null && slotSizes && shape == SemiAvatarShape.circle;
    final showBottom = widget.bottomSlot != null && slotSizes;
    if (!hasRing && !showTop && !showBottom) {
      return MouseRegion(
        cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: interactive,
      );
    }

    // shouldWrap（index.tsx:435-442）：布局盒 = 头像盒；环与 slot 溢出绘制。
    final ringBox = box + 2 * (ringW + ringGap);
    Widget ring({bool animated = false}) {
      final borderRadius = shape == SemiAvatarShape.circle
          ? BorderRadius.circular(ringBox / 2)
          : BorderRadius.circular(
              widget.customSize != null ? 0 : _radiusOf(size, t),
            );
      Widget box_(double borderWidth, double opacity, double scale) => Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.border?.color ?? t.colorAvatarAdditionalBorder,
                width: borderWidth,
              ),
              borderRadius: borderRadius,
            ),
          ),
        ),
      );
      if (!animated) return box_(ringW, 1, 1);
      // avatar.scss:509 `animation: $animation_duration-additionalBorder linear infinite`
      // 呼吸环：透明度 1→0、scale 1→1.15、border-width W→0。
      return AnimatedBuilder(
        animation: _ring,
        builder: (context, _) {
          final f = _ring.value;
          return box_(
            ringW + (t.animationWidthAdditionalBorderEnd - ringW) * f,
            t.animationOpacityAdditionalBorderStart +
                (t.animationOpacityAdditionalBorderEnd -
                        t.animationOpacityAdditionalBorderStart) *
                    f,
            t.animationScaleAdditionalBorderStart +
                (t.animationScaleAdditionalBorderEnd -
                        t.animationScaleAdditionalBorderStart) *
                    f,
          );
        },
      );
    }

    if (hasRing && widget.border!.motion) {
      _ring.duration = t.animationDurationAdditionalBorder;
      if (!_ring.isAnimating) _ring.repeat();
    } else if (_ring.isAnimating) {
      _ring.stop();
      _ring.value = 0;
    }

    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: SizedBox.square(
          dimension: box,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: interactive),
              if (hasRing)
                Positioned(
                  left: -ringW - ringGap,
                  top: -ringW - ringGap,
                  width: ringBox,
                  height: ringBox,
                  child: IgnorePointer(child: ring()),
                ),
              if (hasRing && widget.border!.motion)
                Positioned(
                  left: -ringW - ringGap,
                  top: -ringW - ringGap,
                  width: ringBox,
                  height: ringBox,
                  child: IgnorePointer(child: ring(animated: true)),
                ),
              if (showTop)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox.square(
                      dimension: box,
                      child: _buildTopSlot(global, t, size),
                    ),
                  ),
                ),
              if (showBottom)
                Positioned(
                  // avatar.scss:275 bottom: gap + 环宽；:276 `transform: translateY(50%)`。
                  bottom: ringGap + ringW,
                  left: 0,
                  right: 0,
                  child: FractionalTranslation(
                    translation: const Offset(0, 0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildBottomSlot(global, t, size),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSlot(
    SemiThemeData global,
    SemiResolvedAvatarThemeData t,
    SemiAvatarSize size,
  ) {
    final slot = widget.topSlot!;
    if (slot.render != null) return slot.render!();
    // ★quirk：index.tsx:438 守卫含 extra-small，但 CSS 无 `-extra-small` 任何
    // top slot 尺寸类（零样式）——仅继承字渲染。
    final (fontSize, marginTop) = switch (size) {
      SemiAvatarSize.extraSmall => (global.typography.fontSizeRegular, 0.0),
      SemiAvatarSize.small => (
        t.fontAvatarTopSlotSmallFontSize,
        t.spacingAvatarTopSlotSmallContentMarginTop,
      ),
      SemiAvatarSize.normal => (
        t.fontAvatarTopSlotDefaultFontSize,
        t.spacingAvatarTopSlotDefaultContentMarginTop,
      ),
      SemiAvatarSize.medium => (
        t.fontAvatarTopSlotMediumFontSize,
        t.spacingAvatarTopSlotMediumContentMarginTop,
      ),
      SemiAvatarSize.large => (
        t.fontAvatarTopSlotLargeFontSize,
        t.spacingAvatarTopSlotLargeContentMarginTop,
      ),
      SemiAvatarSize.extraLarge => (
        t.fontAvatarTopSlotExtraLargeFontSize,
        t.spacingAvatarTopSlotExtraLargeContentMarginTop,
      ),
      SemiAvatarSize.extraExtraSmall => (0.0, 0.0),
    };
    Widget child = Stack(
      clipBehavior: Clip.none,
      children: [
        if (size != SemiAvatarSize.extraSmall)
          Positioned.fill(
            child: ClipOval(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: switch (size) {
                      SemiAvatarSize.small => t.spacingAvatarTopSlotSmallShift,
                      SemiAvatarSize.normal => t.spacingAvatarTopSlotDefaultShift,
                      SemiAvatarSize.medium => t.spacingAvatarTopSlotMediumShift,
                      SemiAvatarSize.large => t.spacingAvatarTopSlotLargeShift,
                      SemiAvatarSize.extraLarge =>
                        t.spacingAvatarTopSlotExtraLargeShift,
                      _ => 0.0,
                    },
                    left: 0,
                    right: 0,
                    height: 52,
                    child: Center(
                      child: Transform.scale(
                        scale: switch (size) {
                          SemiAvatarSize.small => t.spacingAvatarTopSlotSmallScale,
                          SemiAvatarSize.normal => t.spacingAvatarTopSlotDefaultScale,
                          SemiAvatarSize.medium => t.spacingAvatarTopSlotMediumScale,
                          SemiAvatarSize.large => t.spacingAvatarTopSlotLargeScale,
                          SemiAvatarSize.extraLarge =>
                            t.spacingAvatarTopSlotExtraLargeScale,
                          _ => 1.0,
                        },
                        child: SizedBox(
                          width: 51,
                          height: 52,
                          child: CustomPaint(
                            painter: _TopSlotShieldPainter(
                              slot.gradientStart ?? t.colorAvatarTopSlotGradientStart,
                              slot.gradientEnd ?? t.colorAvatarTopSlotGradientEnd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: marginTop,
          left: 0,
          right: 0,
          child: Center(
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                color: slot.textColor ?? t.colorAvatarTopSlotText,
                fontSize: fontSize,
                fontWeight: global.typography.fontWeightBold,
                height: 1,
              ),
              child: slot.text ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
    if (widget.contentMotion) {
      // index.tsx:301-303 顶层 wrapper 同样带 `-animated` 脉冲。
      child = AnimatedBuilder(
        animation: _content,
        builder: (context, c) => Transform.scale(scale: _pulse(_content.value, t), child: c),
        child: child,
      );
    }
    return child;
  }

  Widget _buildBottomSlot(
    SemiThemeData global,
    SemiResolvedAvatarThemeData t,
    SemiAvatarSize size,
  ) {
    final slot = widget.bottomSlot!;
    if (slot.render != null) return slot.render!();
    final fg = slot.textColor ?? global.colors.colorBg0;
    if (slot.shape == SemiAvatarShape.circle) {
      final d = switch (size) {
        SemiAvatarSize.extraSmall => t.widthAvatarBottomSlotCircleExtraSmall,
        SemiAvatarSize.small => t.widthAvatarBottomSlotCircleSmall,
        SemiAvatarSize.normal => t.widthAvatarBottomSlotCircleDefault,
        SemiAvatarSize.medium => t.widthAvatarBottomSlotCircleMedium,
        SemiAvatarSize.large => t.widthAvatarBottomSlotCircleLarge,
        SemiAvatarSize.extraLarge => t.widthAvatarBottomSlotCircleExtraLarge,
        SemiAvatarSize.extraExtraSmall => 0.0,
      };
      final fontSize = switch (size) {
        SemiAvatarSize.extraSmall => t.fontAvatarBottomSlotExtraSmallFontSize,
        SemiAvatarSize.small => t.fontAvatarBottomSlotSmallFontSize,
        SemiAvatarSize.normal => t.fontAvatarBottomSlotDefaultFontSize,
        SemiAvatarSize.medium => t.fontAvatarBottomSlotMediumFontSize,
        SemiAvatarSize.large => t.fontAvatarBottomSlotLargeFontSize,
        SemiAvatarSize.extraLarge => t.fontAvatarBottomSlotExtraLargeFontSize,
        SemiAvatarSize.extraExtraSmall => 0.0,
      };
      return SizedBox.square(
        dimension: d,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: slot.bgColor ?? t.colorAvatarBottomSlotBg,
            borderRadius: BorderRadius.all(
              global.radius.borderRadiusCircle.resolveRadius(Size.square(d)),
            ),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                color: fg,
                fontSize: fontSize,
                height: 1,
              ),
              child: slot.text ?? const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }
    // square。★quirk：CSS 类 `shape_square-extra_small`（下划线）与渲染的
    // `shape_square-extra-small`（连字符）拼写不匹配 —— extra-small 档规则从不
    // 命中，font-size 回落继承的 `font-size-regular`、border-width 回落 CSS
    // 初始 `medium` = 3（死变量 `$width-avatar-bottom_slot_square_extra_small-border`
    // 不消费）。
    final (fontSize, borderWidth) = switch (size) {
      SemiAvatarSize.extraSmall => (global.typography.fontSizeRegular, 3.0),
      SemiAvatarSize.small => (
        t.fontAvatarBottomSlotSmallFontSize,
        t.widthAvatarBottomSlotSquareSmallBorder,
      ),
      SemiAvatarSize.normal => (
        t.fontAvatarBottomSlotDefaultFontSize,
        t.widthAvatarBottomSlotSquareDefaultBorder,
      ),
      SemiAvatarSize.medium => (
        t.fontAvatarBottomSlotMediumFontSize,
        t.widthAvatarBottomSlotSquareMediumBorder,
      ),
      SemiAvatarSize.large => (
        t.fontAvatarBottomSlotLargeFontSize,
        t.widthAvatarBottomSlotSquareLargeBorder,
      ),
      SemiAvatarSize.extraLarge => (
        t.fontAvatarBottomSlotExtraLargeFontSize,
        t.widthAvatarBottomSlotSquareExtraLargeBorder,
      ),
      SemiAvatarSize.extraExtraSmall => (0.0, 0.0),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: slot.bgColor ?? t.colorAvatarBottomSlotBg,
        border: Border.all(
          color: t.colorAvatarBottomSlotSquareBorder,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(t.radiusAvatarBottomSlotSquare),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacingAvatarBottomSlotSquarePaddingX,
          vertical: t.spacingAvatarBottomSlotSquarePaddingY,
        ),
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(
            color: fg,
            fontSize: fontSize,
            fontWeight: global.typography.fontWeightBold,
            height: 1,
          ),
          child: slot.text ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// 0%→50%→100% 三段 scale 关键帧（`animation_scale-content-*`）。
double _pulse(double f, SemiResolvedAvatarThemeData t) {
  final a = t.animationScaleContentStart;
  final b = t.animationScaleContentMiddle;
  final c = t.animationScaleContentEnd;
  return f < .5 ? a + (b - a) * f * 2 : b + (c - b) * (f - .5) * 2;
}

/// 组内上下文：size/shape 由 Group 统一决定（avatarGroup.tsx:86 cloneElement
/// 覆盖子项）。
class _AvatarGroupScope extends InheritedWidget {
  const _AvatarGroupScope({
    required this.size,
    required this.shape,
    required super.child,
  });
  final SemiAvatarSize size;
  final SemiAvatarShape shape;
  static _AvatarGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AvatarGroupScope>();
  @override
  bool updateShouldNotify(_AvatarGroupScope old) =>
      size != old.size || shape != old.shape;
}

/// 头像组（上游 AvatarGroup）：叠压排列、`maxCount` 折叠 `+N`、`overlapFrom`
/// 决定层序。children 通常为 [SemiAvatar]；size/shape 由组统一决定。
class SemiAvatarGroup extends StatelessWidget {
  const SemiAvatarGroup({
    super.key,
    required this.children,
    this.size = SemiAvatarSize.medium,
    this.shape = SemiAvatarShape.circle,
    this.overlapFrom = SemiAvatarOverlapFrom.start,
    this.maxCount,
    this.renderMore,
  });

  final List<Widget> children;

  /// 统一尺寸/形状（覆盖子项自身参数，上游 cloneElement 语义）。
  final SemiAvatarSize size;
  final SemiAvatarShape shape;
  final SemiAvatarOverlapFrom overlapFrom;

  /// 折叠阈值；超出折叠为 `+N` 头像。
  final int? maxCount;

  /// 自定义 `+N` 渲染（整体替换，上游 renderMore 语义）。
  final Widget Function(int restNumber, List<Widget> restAvatars)? renderMore;

  @override
  Widget build(BuildContext context) {
    final t = SemiAvatarTheme.resolve(context);
    final box = _boxOf(size, t);
    final borderWidth = _groupBorderOf(size, t);
    final margin = _groupMarginOf(size, t);
    var items = List<Widget>.of(children);
    var restAvatars = const <Widget>[];
    var restNumber = 0;
    if (maxCount != null && items.length > maxCount!) {
      restNumber = items.length - maxCount!;
      restAvatars = items.sublist(maxCount!);
      items = [...items.sublist(0, maxCount!), _moreAvatar(restNumber, restAvatars, t)];
    }
    final n = items.length;
    // avatar.scss:409-416 `z-index: $z-avatar-default - $i`（start）/
    // `z-index: $z-avatar-default - 20 + $i`（end）；>21 项无 z 类（auto，
    // 低于正 z 层）。
    double zOf(int i) => overlapFrom == SemiAvatarOverlapFrom.start
        ? t.zAvatarDefault - i
        : t.zAvatarDefault - 20 + i;
    final order = [for (var i = 0; i < n; i++) i];
    order.sort((a, b) {
      final (za, zb) = (a <= 20 ? zOf(a) : double.negativeInfinity, b <= 20 ? zOf(b) : double.negativeInfinity);
      if (za != zb) return za.compareTo(zb);
      return a.compareTo(b);
    });
    return Semantics(
      // avatarGroup.tsx:92 `role='list'`。
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        width: n == 0 ? 0 : n * box + (n - 1) * margin,
        height: box,
        child: _AvatarGroupScope(
          size: size,
          shape: shape,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final i in order)
                Positioned(
                  left: i * (box + margin),
                  top: 0,
                  width: box,
                  height: box,
                  child: Semantics(
                    // index.tsx:394 `role: 'listitem'`。
                    sortKey: OrdinalSortKey(i.toDouble()),
                    child: _GroupItem(
                      box: box,
                      radius: shape == SemiAvatarShape.circle
                          ? box / 2
                          : _radiusOf(size, t),
                      borderColor: t.colorAvatarDefaultBorderDefault,
                      borderWidth: borderWidth,
                      child: items[i],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreAvatar(int restNumber, List<Widget> rest, SemiResolvedAvatarThemeData t) {
    if (renderMore != null) return renderMore!(restNumber, rest);
    // avatarGroup.tsx:65-66 语义 `Number of remaining Avatars：N,alt...`。
    final altList = rest
        .map((w) => w is SemiAvatar ? (w.alt ?? w.text ?? '') : '')
        .where((s) => s.isNotEmpty)
        .join(',');
    return SemiAvatar(
      // avatarGroup.tsx:66 `+${restNumber}`。
      text: '+$restNumber',
      backgroundColor: t.colorAvatarMoreDefaultBgDefault,
      semanticsLabel: 'Number of remaining Avatars：$restNumber,$altList',
    );
  }
}

/// 组内单项：`box-sizing: border-box` 的描边环覆盖式绘制。
class _GroupItem extends StatelessWidget {
  const _GroupItem({
    required this.box,
    required this.radius,
    required this.borderColor,
    required this.borderWidth,
    required this.child,
  });
  final double box, radius, borderWidth;
  final Color borderColor;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: box,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                // avatar.scss:367 `box-sizing: border-box` —— 描边画在盒内。
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// index.tsx:438 守卫 `"extra-small", "small", "default", "medium", "large", "extra-large"`
// —— topSlot/bottomSlot 可渲染尺寸（topSlot 另需 circle）。
const _slotSizes = {
  SemiAvatarSize.extraSmall,
  SemiAvatarSize.small,
  SemiAvatarSize.normal,
  SemiAvatarSize.medium,
  SemiAvatarSize.large,
  SemiAvatarSize.extraLarge,
};

/// avatar.scss 尺寸类盒宽（`$width-avatar_*`）。
double _boxOf(SemiAvatarSize size, SemiResolvedAvatarThemeData t) =>
    switch (size) {
      SemiAvatarSize.extraExtraSmall => t.widthAvatarExtraExtraSmall,
      SemiAvatarSize.extraSmall => t.widthAvatarExtraSmall,
      SemiAvatarSize.small => t.widthAvatarSmall,
      SemiAvatarSize.normal => t.widthAvatarDefault,
      SemiAvatarSize.medium => t.widthAvatarMedium,
      SemiAvatarSize.large => t.widthAvatarLarge,
      SemiAvatarSize.extraLarge => t.widthAvatarExtraLarge,
    };

/// avatar.scss 尺寸类圆角（`$radius-avatar_*`；circle 用 `radiusAvatar` 50%）。
double _radiusOf(SemiAvatarSize size, SemiResolvedAvatarThemeData t) =>
    switch (size) {
      SemiAvatarSize.extraExtraSmall => t.radiusAvatarExtraExtraSmall,
      SemiAvatarSize.extraSmall => t.radiusAvatarExtraSmall,
      SemiAvatarSize.small => t.radiusAvatarSmall,
      SemiAvatarSize.normal => t.radiusAvatarDefault,
      SemiAvatarSize.medium => t.radiusAvatarMedium,
      SemiAvatarSize.large => t.radiusAvatarLarge,
      SemiAvatarSize.extraLarge => t.radiusAvatarExtraLarge,
    };

/// 组描边宽（`$width-avatar_*-border`）。
double _groupBorderOf(SemiAvatarSize size, SemiResolvedAvatarThemeData t) =>
    switch (size) {
      SemiAvatarSize.extraExtraSmall => t.widthAvatarExtraExtraSmallBorder,
      SemiAvatarSize.extraSmall => t.widthAvatarExtraSmallBorder,
      SemiAvatarSize.small => t.widthAvatarSmallBorder,
      SemiAvatarSize.normal => t.widthAvatarDefaultBorder,
      SemiAvatarSize.medium => t.widthAvatarMediumBorder,
      SemiAvatarSize.large => t.widthAvatarLargeBorder,
      SemiAvatarSize.extraLarge => t.widthAvatarExtraLargeBorder,
    };

/// 组叠压左移（`$spacing-avatar_*-marginLeft`，负值）。
double _groupMarginOf(SemiAvatarSize size, SemiResolvedAvatarThemeData t) =>
    switch (size) {
      SemiAvatarSize.extraExtraSmall =>
        t.spacingAvatarExtraExtraSmallMarginLeft,
      SemiAvatarSize.extraSmall => t.spacingAvatarExtraSmallMarginLeft,
      SemiAvatarSize.small => t.spacingAvatarSmallMarginLeft,
      SemiAvatarSize.normal => t.spacingAvatarDefaultMarginLeft,
      SemiAvatarSize.medium => t.spacingAvatarMediumMarginLeft,
      SemiAvatarSize.large => t.spacingAvatarLargeMarginLeft,
      SemiAvatarSize.extraLarge => t.spacingAvatarExtraLargeMarginLeft,
    };

/// 文字头像字号/行高：xxs/xl 用显式 Sass 字号，其余用字号 mixin 对应
/// typography token（`font-size-small`→fontSizeSmall、`font-size-header-5`→
/// fontSizeHeading5、`font-size-header-4`→fontSizeHeading4、
/// `font-size-header-1`→fontSizeHeading1）。
(double, double) _labelOf(
  SemiAvatarSize size,
  SemiThemeData global,
  SemiResolvedAvatarThemeData t,
) => switch (size) {
  SemiAvatarSize.extraExtraSmall => (
    t.fontAvatarExtraExtraSmallSize,
    t.fontAvatarExtraExtraSmallLineHeight,
  ),
  SemiAvatarSize.extraSmall => (
    t.fontAvatarExtraSmallSize,
    t.fontAvatarExtraSmallLineHeight,
  ),
  SemiAvatarSize.small => (
    global.typography.fontSizeSmall,
    global.typography.lineHeightSmall,
  ),
  SemiAvatarSize.normal => (
    global.typography.fontSizeHeading5,
    global.typography.lineHeightHeading5,
  ),
  SemiAvatarSize.medium => (
    global.typography.fontSizeHeading4,
    global.typography.lineHeightHeading4,
  ),
  SemiAvatarSize.large => (
    global.typography.fontSizeHeading1,
    global.typography.lineHeightHeading1,
  ),
  SemiAvatarSize.extraLarge => (
    t.fontAvatarExtraLargeSize,
    t.fontAvatarExtraLargeLineHeight,
  ),
};

/// mixin.scss `avatar-style($color)` 的 `{color}-3` 背景（white 无样式类）。
Color _paletteLevel3(SemiAvatarColor color, SemiThemeData global) {
  final p = global.palette;
  final channels = switch (color) {
    SemiAvatarColor.amber => p.amber3,
    SemiAvatarColor.blue => p.blue3,
    SemiAvatarColor.cyan => p.cyan3,
    SemiAvatarColor.green => p.green3,
    SemiAvatarColor.grey => p.grey3,
    SemiAvatarColor.indigo => p.indigo3,
    SemiAvatarColor.lightBlue => p.lightBlue3,
    SemiAvatarColor.lightGreen => p.lightGreen3,
    SemiAvatarColor.lime => p.lime3,
    SemiAvatarColor.orange => p.orange3,
    SemiAvatarColor.pink => p.pink3,
    SemiAvatarColor.purple => p.purple3,
    SemiAvatarColor.red => p.red3,
    SemiAvatarColor.teal => p.teal3,
    SemiAvatarColor.violet => p.violet3,
    SemiAvatarColor.yellow => p.yellow3,
    SemiAvatarColor.white => null,
  };
  return channels?.toColor() ?? const Color(0x00000000);
}

/// TopSlotSvg.tsx 盾形（51×52 viewBox）：路径
/// `M40.4918 46.5592C44.6795 43.176 46.261 34.1333 47.5301 25.6141C49.5854 11.8168 39.6662 1 25.8097 1C11.2857 1 3 11.4279 3 25.3518C3 33.7866 6.29361 43.8947 10.4602 46.5592C12.5868 47.9192 12.5868 47.9051 25.8097 47.9192C38.3651 47.9282 38.5352 48.14 40.4918 46.5592Z`
/// + dy 1.65809 / 模糊 1.10539 的 30% 黑投影 + y 31.7392→47.9333 纵向渐变。
class _TopSlotShieldPainter extends CustomPainter {
  const _TopSlotShieldPainter(this.gradientStart, this.gradientEnd);
  final Color gradientStart, gradientEnd;
  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(40.4918, 46.5592)
          ..cubicTo(44.6795, 43.176, 46.261, 34.1333, 47.5301, 25.6141)
          ..cubicTo(49.5854, 11.8168, 39.6662, 1, 25.8097, 1)
          ..cubicTo(11.2857, 1, 3, 11.4279, 3, 25.3518)
          ..cubicTo(3, 33.7866, 6.29361, 43.8947, 10.4602, 46.5592)
          ..cubicTo(12.5868, 47.9192, 12.5868, 47.9051, 25.8097, 47.9192)
          ..cubicTo(38.3651, 47.9282, 38.5352, 48.14, 40.4918, 46.5592)
          ..close();
    final shadow = Paint()
      ..color = const Color(0x4d000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.10539);
    canvas.save();
    canvas.translate(0, 1.65809);
    canvas.drawPath(path, shadow);
    canvas.restore();
    final fill = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(17.671, 31.7392),
        const Offset(17.671, 47.9333),
        [gradientStart, gradientEnd],
      );
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(_TopSlotShieldPainter old) =>
      gradientStart != old.gradientStart || gradientEnd != old.gradientEnd;
}

/// focus 轮廓（`outline: $width-avatar-outline solid`）。
class _AvatarFocusPainter extends CustomPainter {
  const _AvatarFocusPainter(this.color, this.width, this.radius);
  final Color color;
  final double width, radius;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(
    RRect.fromRectAndRadius(
      (Offset.zero & size).inflate(width / 2),
      Radius.circular(radius),
    ),
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width,
  );
  @override
  bool shouldRepaint(_AvatarFocusPainter old) =>
      color != old.color || width != old.width || radius != old.radius;
}
