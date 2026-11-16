// Popover (气泡卡片) — upstream packages/semi-ui/popover/index.tsx, a thin
// Tooltip wrapper: `renderPopCard` wraps the content in a
// `div.semi-popover > div.semi-popover-content` card (`className={popCardCls}`
// / `${prefixCls}-content`) and forwards the trigger/positioning subset to
// Tooltip. The port builds on the SemiTooltip overlay shell (`popupBare` + a
// popover-family surface), exactly like SemiPopconfirm does: the
// trigger/positioning/flip/arrow/outside-click/Esc/controlled-visible
// machinery all comes from semi_tooltip.dart.
//
// Sass accounting (see docs/semi_popover.md):
// 26 = 20 FIELDS + 4 MOTION + 2 INTERNAL (packages/semi-foundation/popover/
// variables.scss 22 declarations + animation.scss 4). 37 HARDCODES anchors,
// 63 = 20 + 4 + 2 + 37 provenance entries. ★0 死变量（26 声明全部被
// popover.scss / 共享 tooltip arrow.scss（popover.scss `@import
// '../tooltip/arrow.scss'`）/ animation.scss 消费）；本地 20 条进入渲染路径，
// 4 条（`unset` quirk + `&-title` 三件套）经注释留档（上游消费方为无渲染方的
// CSS 规则 / 箭头 `color` 属性）。
//
// Theme-field consumption (24 = 20 FIELDS + 4 MOTION):
//   colorPopoverBgDefault / radiusPopover / spacingPopoverWithArrowPadding ->
//     _PopoverCard surface + with-arrow padding;
//   colorPopoverArrowBg / colorPopoverArrowBorder -> arrowColor /
//     arrowFringeColor (arrowStyle.backgroundColor / borderColor override,
//     borderOpacity composes into the fringe alpha);
//   widthPopoverArrow / heightPopoverArrow / widthPopoverArrowVertical /
//   heightPopoverArrowVertical -> arrow box 24x8 (8x24 vertical) via the
//   heightTooltipArrow / widthTooltipArrow / widthTooltipArrowVertical /
//   heightTooltipArrowVertical alias resolve chains;
//   spacingPopoverArrowAdjustedOffsetY -> spacingTooltipArrowAdjustedOffsetY;
//   heightTooltipArrow / widthTooltipArrow / widthTooltipArrowVertical /
//   heightTooltipArrowVertical / spacingTooltipArrowAdjustedOffsetX /
//   spacingTooltipArrowAdjustedOffsetY / animationDurationPopoverIn /
//   animationDurationPopoverOut / animationFunctionPopoverIn /
//   animationFunctionPopoverOut -> the SemiTooltipTheme patch in build() (the
//   local equivalent of the popover-scope variable shadowing that feeds the
//   shared tooltip/arrow.scss and the zoomIn/zoomOut motion);
//   colorTooltipArrowIconDefault ('unset' quirk), colorPopoverBorderDefault /
//   widthPopoverTitleBorder / spacingPopoverTitlePadding (`&-title` hook, no
//   renderer in current semi-ui) -> provenance comments only.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/semi_popover_theme.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_tooltip_theme.dart';
import '../theme/semi_tooltip_theme_data.dart';
import '../overlay/tooltip_positioning.dart';
import 'semi_tooltip.dart';

/// Arrow tint overrides (upstream `arrowStyle`, popover/index.tsx ArrowStyle).
///
/// Arrow.tsx resolves the two path fills as
/// `get(arrowStyle, 'backgroundColor', get(popStyle, 'backgroundColor'))` and
/// `get(arrowStyle, 'borderColor', get(popStyle, 'borderColor',))` with
/// `get(arrowStyle, 'borderOpacity')` on the fringe pass; `popStyle` is the
/// unported `style` prop, so the CSS fills
/// (`fill: $color-popover-arrow-bg` / `fill: $color-popover-arrow-border`)
/// are the local defaults. Upstream passes a render node to Tooltip; the
/// local shell only supports the bool form and paints the two-path arrow
/// itself.
// Upstream snippet (raw — angle brackets read as HTML in doc comments):
// showArrow ? <Arrow {...arrowProps} /> : false
@immutable
class SemiPopoverArrowStyle {
  const SemiPopoverArrowStyle({
    this.borderColor,
    this.backgroundColor,
    this.borderOpacity,
  });

  /// Fringe pass tint (`path:nth-child(1)`).
  final Color? borderColor;

  /// Wing pass tint (`path:nth-child(2)`).
  final Color? backgroundColor;

  /// Fringe pass opacity (SVG `opacity: borderOpacity`).
  final double? borderOpacity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiPopoverArrowStyle &&
          borderColor == other.borderColor &&
          backgroundColor == other.backgroundColor &&
          borderOpacity == other.borderOpacity;

  @override
  int get hashCode => Object.hash(borderColor, backgroundColor, borderOpacity);
}

/// 气泡卡片。Hover（默认）触发的轻量浮层，内容任意。
///
/// Upstream defaultProps (popover/index.tsx getDefaultPropsFromGlobalConfig):
/// `prefixCls: cssClasses.PREFIX`, `arrowBounding: numbers.ARROW_BOUNDING`
/// (`offsetY: 6`), `showArrow: false`, `autoAdjustOverflow: true`,
/// `zIndex: numbers.DEFAULT_Z_INDEX`, `motion: true`, `trigger: 'hover'`,
/// `position: 'bottom'`, `closeOnEsc: true`, `returnFocusOnClose: true`,
/// `guardFocus: true`, `disableFocusListener: true`, plus the legacy
/// `cancelText: 'No'` / `okText: 'Yes'` (PopConfirm leftovers — nothing
/// consumes them in popover/index.tsx). `role = trigger === 'click' ||
/// trigger === 'custom' ? 'dialog' : 'tooltip'` is unported (the shell keeps
/// no ARIA roles).
///
/// Builds on [SemiTooltip] (`popupBare: true`) with the popover-family surface
/// (bg-3 + shadow-elevated + medium radius) from popover.scss. Upstream
/// `PopoverProps` forwards most Tooltip props; the trigger/positioning subset
/// is passed through below. `visible` non-null makes it controlled (events
/// only report through [onVisibleChange], like the shell).
class SemiPopover extends StatelessWidget {
  const SemiPopover({
    super.key,
    required this.content,
    required this.child,
    this.position = SemiTooltipPosition.bottom,
    this.trigger = SemiTooltipTrigger.hover,
    this.showArrow = false,
    this.arrowStyle,
    this.arrowPointAtCenter = true,
    this.autoAdjustOverflow = true,
    this.spacing,
    this.mouseEnterDelay = const Duration(milliseconds: 50),
    this.mouseLeaveDelay = const Duration(milliseconds: 50),
    this.clickToHide = false,
    this.closeOnEsc = true,
    this.visible,
    this.onVisibleChange,
    this.onClickOutSide,
    this.onEscKeyDown,
    this.motion = true,
    this.zIndex = 1030,
    this.repositionKey,
    this.arrowBoundingOffsetY = 6,
  });

  /// Popup body (upstream `content`, plain node). The upstream function form
  /// `content({ initialFocusRef })` is not ported.
  final Widget content;

  /// The trigger subtree (upstream children).
  final Widget child;

  /// Preferred placement; auto-adjust may flip it. Upstream `position:
  /// 'bottom'`.
  final SemiTooltipPosition position;

  /// Interaction mode. Upstream `trigger: 'hover'`.
  final SemiTooltipTrigger trigger;

  /// Whether to paint the two-path popover arrow. Upstream `showArrow: false`.
  final bool showArrow;

  /// Arrow tint overrides (upstream `arrowStyle`).
  final SemiPopoverArrowStyle? arrowStyle;

  /// Anchor the arrow at the trigger center instead of the popup corner
  /// (upstream Tooltip default).
  final bool arrowPointAtCenter;

  /// Flip/expand/reduce/pin the placement when space is insufficient
  /// (upstream `autoAdjustOverflow: true`).
  final bool autoAdjustOverflow;

  /// Trigger-to-popup gap; defaults to the popover constants
  /// `spacing = showArrow ? numbers.SPACING_WITH_ARROW : numbers.SPACING`
  /// (10 : 4).
  final double? spacing;

  /// Hover show delay (upstream `mouseEnterDelay`).
  final Duration mouseEnterDelay;

  /// Hover hide delay (upstream `mouseLeaveDelay`).
  final Duration mouseLeaveDelay;

  /// Hide when the popup itself is tapped (upstream `clickToHide`).
  final bool clickToHide;

  /// Consume Escape and close while visible (upstream `closeOnEsc: true`).
  final bool closeOnEsc;

  /// Controlled visibility (upstream `visible`): non-null reports requests
  /// through [onVisibleChange] only.
  final bool? visible;

  /// Reports requested visibility changes (and, uncontrolled, actual ones).
  final ValueChanged<bool>? onVisibleChange;

  /// Called before closing because of a tap outside trigger and popup
  /// (upstream `onClickOutSide`).
  final VoidCallback? onClickOutSide;

  /// Called when Escape is consumed (visible and [closeOnEsc]).
  final VoidCallback? onEscKeyDown;

  /// Whether the show/hide motion plays (upstream `motion: true`).
  final bool motion;

  /// Kept for API parity; overlay stacking is insertion order only. Upstream
  /// `zIndex: numbers.DEFAULT_Z_INDEX` (1030).
  final int zIndex;

  /// Changing this value forces a reposition (upstream `rePosKey`).
  final Object? repositionKey;

  /// Small-trigger arrow correction constant (upstream `arrowBounding:
  /// numbers.ARROW_BOUNDING` — `offsetY: 6`). The upstream `width`/`height`
  /// feed the SVG box (theme arrow geometry here) and `offsetX` is consumed
  /// nowhere upstream.
  final double arrowBoundingOffsetY;

  @override
  Widget build(BuildContext context) {
    final t = SemiPopoverTheme.resolve(context);
    // Popover shadows the tooltip arrow variables in its own scope
    // (`$height-tooltip_arrow: $height-popover_arrow` …) so the shared
    // tooltip/arrow.scss positions the 24x8 icon box and the zoomIn/zoomOut
    // keyframes use the popover motion values; the same-named SemiTooltipTheme
    // patch is the local equivalent.
    final shellTheme = SemiTooltipThemeData(
      heightTooltipArrow: t.heightTooltipArrow,
      widthTooltipArrow: t.widthTooltipArrow,
      heightTooltipArrowVertical: t.heightTooltipArrowVertical,
      widthTooltipArrowVertical: t.widthTooltipArrowVertical,
      arrowAdjustedOffsetY: t.spacingTooltipArrowAdjustedOffsetY,
      arrowAdjustedOffsetX: t.spacingTooltipArrowAdjustedOffsetX,
      // &-animation-show/hide motion lines (verbatim upstream):
      // animation: #{$module}-zoomIn $animation_duration-popover-in $animation_function-popover-in;
      // animation: #{$module}-zoomOut $animation_duration-popover-out $animation_function-popover-out;
      animationDurationIn: t.animationDurationPopoverIn,
      animationDurationOut: t.animationDurationPopoverOut,
      animationFunctionIn: t.animationFunctionPopoverIn,
      animationFunctionOut: t.animationFunctionPopoverOut,
    );
    // Arrow.tsx: `get(arrowStyle, 'backgroundColor', …)` /
    // `get(arrowStyle, 'borderColor', …)` with `get(arrowStyle,
    // 'borderOpacity')` composed into the fringe pass alpha.
    final fringe = arrowStyle?.borderColor ?? t.colorPopoverArrowBorder;
    final fringeOpacity = arrowStyle?.borderOpacity;
    final fringeColor = fringeOpacity == null
        ? fringe
        : fringe.withValues(
            alpha: math.max(0, math.min(1, fringe.a * fringeOpacity)),
          );
    return SemiTooltipTheme(
      data: shellTheme,
      child: SemiTooltip(
        content: _PopoverCard(content: content, withArrow: showArrow),
        trigger: trigger,
        position: position,
        showArrow: showArrow,
        popupBare: true,
        arrowPointAtCenter: arrowPointAtCenter,
        autoAdjustOverflow: autoAdjustOverflow,
        spacing: spacing ?? (showArrow ? 10 : 4),
        mouseEnterDelay: mouseEnterDelay,
        mouseLeaveDelay: mouseLeaveDelay,
        clickToHide: clickToHide,
        closeOnEsc: closeOnEsc,
        visible: visible,
        onVisibleChange: onVisibleChange,
        onEscKeyDown: onEscKeyDown,
        onClickOutSide: onClickOutSide,
        motion: motion,
        // `z-index: $z-popover` (popover.scss wrapper = 1030).
        zIndex: zIndex,
        repositionKey: repositionKey,
        arrowBoundingOffsetY: arrowBoundingOffsetY,
        arrowColor: arrowStyle?.backgroundColor ?? t.colorPopoverArrowBg,
        arrowFringeColor: fringeColor,
        child: child,
      ),
    );
  }
}

/// The 2 Sass declarations kept out of the theme: the arrow correction factor
/// and the backdrop filter. See docs/semi_popover.md for the full mapping.
// ignore: unused_element
abstract final class _PopoverMetrics {
  /// `$horizontal-rate: 0.24` in packages/semi-foundation/popover/variables.scss.
  /// Sass-side correction factor behind `spacingTooltipArrowAdjustedOffsetX`
  /// (0.24 * 24 = 5.76); kept for provenance.
  // ignore: unused_field
  static const double horizontalRate = 0.24;

  /// `$filter-popover-bg: none` in packages/semi-foundation/popover/variables.scss.
  /// Upstream `backdrop-filter: $filter-popover-bg` resolves to `none`.
  // ignore: unused_field
  static const String filter = 'none';
}

/// The `.semi-popover` card surface (popover.scss `.#{$module}-wrapper`).
class _PopoverCard extends StatelessWidget {
  const _PopoverCard({required this.content, required this.withArrow});

  /// Upstream content node (the `renderPopCard` inner
  /// `${prefixCls}-content` div — the commented-out `&-content` padding rule
  /// means content carries its own spacing).
  final Widget content;

  /// Whether the arrow shows: `.semi-popover-with-arrow` adds the card
  /// padding.
  final bool withArrow;

  @override
  Widget build(BuildContext context) {
    final t = SemiPopoverTheme.resolve(context);
    final global = SemiTheme.of(context);
    // Styling hooks without a renderer in current semi-ui (provenance only):
    // `&-title` — `padding: $spacing-popover_title-padding;` and
    // border-bottom: $width-popover_title-border solid $color-popover-border-default;
    // (content-side class convention) — and rtl.scss `direction: rtl` on the
    // card (Directionality covers it).
    // `padding: $spacing-popover_withArrow-padding;` on
    // `.semi-popover-with-arrow`; without the arrow the wrapper carries no
    // padding upstream.
    final padding = withArrow
        ? EdgeInsets.all(t.spacingPopoverWithArrowPadding)
        : EdgeInsets.zero;
    return DecoratedBox(
      decoration: BoxDecoration(
        // `$color-popover-bg-default: var(--semi-color-bg-3)` +
        // `backdrop-filter: $filter-popover-bg` (`none`) +
        // `@include shadow-elevated` + `z-index: $z-popover` (insertion
        // order in the local overlay) + `$radius-popover` on the wrapper.
        color: t.colorPopoverBgDefault,
        borderRadius: BorderRadius.circular(t.radiusPopover),
        boxShadow: global.shadows.shadowElevated.toBoxShadows(),
      ),
      child: Padding(
        padding: padding,
        child: DefaultTextStyle.merge(
          // `@include font-size-regular` (14/20) on the wrapper; the hidden →
          // shown wrapper states are `opacity: 0;` → `opacity: 1;`, played by
          // the shell motion.
          style: TextStyle(
            fontSize: global.typography.fontSizeRegular,
            height:
                global.typography.lineHeightRegular /
                global.typography.fontSizeRegular,
          ),
          child: content,
        ),
      ),
    );
  }
}
