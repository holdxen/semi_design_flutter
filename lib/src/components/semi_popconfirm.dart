// Popconfirm (气泡确认框) — upstream packages/semi-ui/popconfirm/index.tsx on
// top of Popover. The port builds on the SemiTooltip overlay shell
// (`popupBare` + a popover-family surface), exactly like SemiDropdown does:
// the trigger/positioning/flip/arrow/outside-click/Esc/controlled-visible
// machinery all comes from semi_tooltip.dart.
//
// Sass accounting (see docs/semi_popconfirm.md):
// 23 = 19 FIELDS + 4 INTERNAL (packages/semi-foundation/popconfirm/variables.scss;
// there is no popconfirm animation.scss — the upstream popover motion
// 100ms cubic-bezier(0.215, 0.61, 0.355, 1) is value-identical to the tooltip
// motion already played by the shell). 11 HARDCODES anchors,
// 34 = 19 + 4 + 11 provenance entries. ★2 上游死变量（`btn_close-margin`
// 一对）只留 `_PopconfirmMetrics` provenance 常量；其余 21 条全部进入渲染
// 路径，theme 字段 0 死变量。

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/semi_popconfirm_theme.dart';
import '../theme/semi_popconfirm_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_tooltip_theme.dart';
import '../theme/semi_tooltip_theme_data.dart';
import '../overlay/tooltip_positioning.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_tooltip.dart';

/// Sentinel for [SemiPopconfirm.icon]'s default: upstream `icon` defaults to
/// `<IconAlertTriangle size="extra-large" />` tinted
/// `$color-popconfirm_header_alert-icon: var(--semi-color-warning)`. It is the
/// constructor default, so `icon: null` is how the icon slot hides (upstream
/// only renders the slot for a valid element) and any other widget replaces it
/// untinted.
class SemiPopconfirmDefaultIcon extends StatelessWidget {
  const SemiPopconfirmDefaultIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SemiPopconfirmTheme.resolve(context);
    return SemiIcon(
      SemiIcons.alertTriangle,
      customSize: theme.widthPopconfirmIcon,
      color: theme.colorPopconfirmHeaderAlertIcon,
    );
  }
}

/// 气泡确认框。点击（默认）触发的轻量二次确认气泡，内嵌确认/取消按钮。
///
/// Builds on [SemiTooltip] (`popupBare: true`) with a popover-family surface
/// (bg-3 + shadow-elevated + medium radius) and the confirm card from
/// popconfirm.scss. Upstream `PopconfirmProps extends PopoverProps`; the
/// trigger/positioning subset is passed through below.
///
/// 确认/取消回调返回 `Future` 时对应按钮 loading，完成后自动关闭，reject
/// 仅清除 loading 并保持打开（上游 popconfirmFoundation.handleConfirm/
/// handleCancel 语义）；`visible` 非空即受控，只经 [onVisibleChange] 报告
/// 请求，关闭权在使用方。
class SemiPopconfirm extends StatefulWidget {
  const SemiPopconfirm({
    super.key,
    required this.child,
    this.title,
    this.content,
    this.icon = const SemiPopconfirmDefaultIcon(),
    this.okText,
    this.cancelText,
    this.okType = SemiButtonType.primary,
    this.cancelType = SemiButtonType.tertiary,
    this.okLoading,
    this.cancelLoading,
    this.onConfirm,
    this.onCancel,
    this.visible,
    this.defaultVisible = false,
    this.onVisibleChange,
    this.disabled = false,
    this.showCloseIcon = true,
    this.trigger = SemiTooltipTrigger.click,
    this.position,
    this.showArrow = false,
    this.arrowPointAtCenter = false,
    this.spacing,
    this.autoAdjustOverflow = true,
    this.clickToHide = false,
    this.closeOnEsc = true,
    this.onEscKeyDown,
    this.onClickOutSide,
    this.motion = true,
    this.zIndex = 1030,
  });

  /// 触发气泡的目标子树（上游 children）。
  final Widget child;

  /// Header title (upstream `title`, plain node). Null hides the title node.
  final Widget? title;

  /// Body content (upstream `content`). Null hides the body node. The
  /// upstream function form `content({ initialFocusRef })` is not ported.
  final Widget? content;

  /// Header icon (upstream `icon`). The [SemiPopconfirmDefaultIcon] default
  /// renders the warning triangle; `null` hides the slot; any other widget
  /// replaces it (only a valid element renders upstream).
  final Widget? icon;

  /// 确认按钮文案（缺省「确认」，上游 locale `confirm`）。
  final String? okText;

  /// 取消按钮文案（缺省「取消」，上游 locale `cancel`）。
  final String? cancelText;

  /// 确认按钮类型（上游 `okType`，固定 solid 主题）。
  final SemiButtonType okType;

  /// 取消按钮类型（上游 `cancelType`；关闭按钮同用此类型）。
  final SemiButtonType cancelType;

  /// 确认按钮 loading（null 时跟随 [onConfirm] 返回的 `Future`）。
  final bool? okLoading;

  /// 取消按钮 loading（null 时跟随 [onCancel] 返回的 `Future`）。
  final bool? cancelLoading;

  /// 确认回调；返回 `Future` 时按钮 loading，resolve 后自动关闭（非受控），
  /// reject 仅去 loading 并保持打开。
  final FutureOr<void> Function()? onConfirm;

  /// 取消回调（右上关闭按钮同走此回调）；loading/关闭语义同 [onConfirm]。
  final FutureOr<void> Function()? onCancel;

  /// 受控显示。非空即完全受控：事件只经 [onVisibleChange] 报告请求。
  final bool? visible;

  /// 非受控初始显示（上游 `defaultVisible`）。
  final bool defaultVisible;

  /// 显隐请求/变化回调（上游 `onVisibleChange`）。
  final ValueChanged<bool>? onVisibleChange;

  /// 为 true 时直接渲染 [child]，不包气泡（上游 `disabled`）。
  final bool disabled;

  /// 标题栏右上角关闭按钮（上游 `showCloseIcon`，默认开）。
  final bool showCloseIcon;

  /// 触发方式（上游 `trigger`，默认 click；受控时事件仅上报）。
  final SemiTooltipTrigger trigger;

  /// 弹出方向；缺省 bottomLeft（RTL 时 bottomRight，上游默认位置语义）。
  final SemiTooltipPosition? position;

  /// 是否画三角箭头（上游 Popover `showArrow`，默认 false）。
  final bool showArrow;

  /// 箭头是否指向触发物中心（上游 `arrowPointAtCenter`，默认 false）。
  final bool arrowPointAtCenter;

  /// 触发物与气泡间距；缺省 showArrow ? 10 : 4。
  final double? spacing;

  /// 空间不足时翻转/收缩（上游 `autoAdjustOverflow`）。
  final bool autoAdjustOverflow;

  /// 点气泡自身是否关闭（上游 `clickToHide`）。
  final bool clickToHide;

  /// Esc 关闭（上游 `closeOnEsc`，默认 true）。
  final bool closeOnEsc;

  /// Esc 被消费时回调（上游 `onEscKeyDown`）。
  final VoidCallback? onEscKeyDown;

  /// 点击气泡与触发物之外时回调（上游 `onClickOutSide`，随后关闭）。
  final VoidCallback? onClickOutSide;

  /// 显隐动画（上游 `motion`）。
  final bool motion;

  /// Kept for API parity (`$z-popover: 1030`); overlay stacking is insertion
  /// order only.
  final int zIndex;

  @override
  State<SemiPopconfirm> createState() => _SemiPopconfirmState();
}

class _SemiPopconfirmState extends State<SemiPopconfirm> {
  late bool _visible;
  bool _confirmPending = false;
  bool _cancelPending = false;

  @override
  void initState() {
    super.initState();
    _visible = widget.visible ?? widget.defaultVisible;
  }

  @override
  void didUpdateWidget(SemiPopconfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != null && widget.visible != _visible) {
      _visible = widget.visible!;
    }
  }

  /// Upstream `isControlled('visible')`.
  bool get _controlled => widget.visible != null;

  /// Upstream popconfirmFoundation.handleVisibleChange: the uncontrolled mode
  /// owns the state, every closing path ends here, and the UI layer only calls
  /// through when the request differs from the mirrored state.
  void _handleVisibleChange(bool visible) {
    if (visible == _visible) return;
    if (!_controlled) {
      setState(() => _visible = visible);
    }
    widget.onVisibleChange?.call(visible);
  }

  /// Upstream popconfirmFoundation.handleConfirm: a returned Promise drives
  /// the ok button's loading; resolve closes (uncontrolled), reject only
  /// clears loading and keeps the popup open. A plain return closes at once.
  Future<void> _handleConfirm() async {
    final result = widget.onConfirm?.call();
    if (result is Future<void>) {
      setState(() => _confirmPending = true);
      try {
        await result;
      } catch (_) {
        if (!mounted) return;
        setState(() => _confirmPending = false);
        return;
      }
      if (!mounted) return;
      setState(() => _confirmPending = false);
    }
    _handleVisibleChange(false);
  }

  /// Upstream popconfirmFoundation.handleCancel; the close button routes here
  /// too (both fire `onCancel`).
  Future<void> _handleCancel() async {
    final result = widget.onCancel?.call();
    if (result is Future<void>) {
      setState(() => _cancelPending = true);
      try {
        await result;
      } catch (_) {
        if (!mounted) return;
        setState(() => _cancelPending = false);
        return;
      }
      if (!mounted) return;
      setState(() => _cancelPending = false);
    }
    _handleVisibleChange(false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) return widget.child;
    // The popover-family arrow paints with the bubble skin, not the tooltip
    // bubble: fill `fill: var(--semi-color-bg-3)` (Arrow.tsx `path:nth-child(2)`
    // — same wing shape as the tooltip arrow), fringe
    // `fill: var(--semi-color-border)` (`path:nth-child(1)`).
    final colors = SemiTheme.of(context).colors;
    final card = _PopconfirmCard(
      title: widget.title,
      content: widget.content,
      icon: widget.icon,
      withArrow: widget.showArrow,
      showCloseIcon: widget.showCloseIcon,
      okText: widget.okText,
      cancelText: widget.cancelText,
      okType: widget.okType,
      cancelType: widget.cancelType,
      okLoading: widget.okLoading ?? _confirmPending,
      cancelLoading: widget.cancelLoading ?? _cancelPending,
      onConfirm: _handleConfirm,
      onCancel: _handleCancel,
    );
    return SemiTooltipTheme(
      // PopConfirm renders on the Popover card upstream, so its arrow is the
      // popover arrow: `numbers.ARROW_BOUNDING` (24x8 box — the fringe pass
      // `path:nth-child(1)` overhangs the 7px wing by 1px).
      data: const SemiTooltipThemeData(
        heightTooltipArrow: 8,
        widthTooltipArrow: 24,
        heightTooltipArrowVertical: 24,
        widthTooltipArrowVertical: 8,
      ),
      child: SemiTooltip(
        content: card,
        trigger: widget.trigger,
        position:
            widget.position ??
            (Directionality.maybeOf(context) == TextDirection.rtl
                ? SemiTooltipPosition.bottomRight
                : SemiTooltipPosition.bottomLeft),
        showArrow: widget.showArrow,
        popupBare: true,
        arrowPointAtCenter: widget.arrowPointAtCenter,
        autoAdjustOverflow: widget.autoAdjustOverflow,
        // Popover defaults:
        // `spacing = showArrow ? numbers.SPACING_WITH_ARROW : numbers.SPACING`
        // (popover/index.tsx — 10 : 4).
        spacing: widget.spacing ?? (widget.showArrow ? 10 : 4),
        clickToHide: widget.clickToHide,
        closeOnEsc: widget.closeOnEsc,
        visible: _visible,
        onVisibleChange: _handleVisibleChange,
        onEscKeyDown: widget.onEscKeyDown,
        onClickOutSide: widget.onClickOutSide,
        motion: widget.motion,
        // `z-index: $z-popover` (popover.scss wrapper = 1030).
        zIndex: widget.zIndex,
        arrowColor: colors.colorBg3,
        arrowFringeColor: colors.colorBorder,
        child: widget.child,
      ),
    );
  }
}

/// The 4 Sass declarations kept out of the theme (2 derived with-arrow
/// paddings + the 2 upstream-dead close-button margin declarations). See
/// docs/semi_popconfirm.md for the full mapping.
abstract final class _PopconfirmMetrics {
  /// Inner padding without the arrow — popconfirm.scss:
  /// `padding: $spacing-popconfirm-top $spacing-popconfirm-top $spacing-popconfirm-top $spacing-popconfirm-bottom;`
  /// (24 24 24 20 — upstream 4-value quirk: `$spacing-popconfirm-bottom`
  /// lands on the CSS left edge) and rtl.scss:
  /// `padding: $spacing-popconfirm-top $spacing-popconfirm-bottom $spacing-popconfirm-top $spacing-popconfirm-top;`
  /// (24 20 24 24, left/right mirrored).
  static EdgeInsets innerPadding(
    SemiResolvedPopconfirmThemeData t, {
    required bool rtl,
  }) {
    final edge = rtl ? t.spacingPopconfirmTop : t.spacingPopconfirmBottom;
    final other = rtl ? t.spacingPopconfirmBottom : t.spacingPopconfirmTop;
    return EdgeInsets.fromLTRB(
      edge,
      t.spacingPopconfirmTop,
      other,
      t.spacingPopconfirmTop,
    );
  }

  /// `$spacing-popconfirm_popover_with_arrow_inner-padding: ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-bottom - $spacing-popconfirm_with_arrow-padding)` in packages/semi-foundation/popconfirm/variables.scss.
  /// `$spacing-popconfirm_popover_with_arrow_inner_rtl-padding: ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-bottom - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding)` in packages/semi-foundation/popconfirm/variables.scss.
  /// Derived at runtime from the scalar fields: 12 12 12 8 at defaults (the
  /// same upstream left-edge quirk), 12 8 12 12 mirrored for RTL.
  static EdgeInsets withArrowInnerPadding(
    SemiResolvedPopconfirmThemeData t, {
    required bool rtl,
  }) {
    final inset = t.spacingPopconfirmTop - t.spacingPopconfirmWithArrowPadding;
    final edge =
        t.spacingPopconfirmBottom - t.spacingPopconfirmWithArrowPadding;
    return EdgeInsets.fromLTRB(
      rtl ? inset : edge,
      inset,
      rtl ? edge : inset,
      inset,
    );
  }

  /// Body withIcon indent — popconfirm.scss:
  /// `margin-left: $width-popconfirm-icon + $spacing-popconfirm_header_icon-marginRight;`
  /// (24 + 12 = 36). rtl.scss never mirrors it: stays physical left.
  static double bodyWithIconIndent(SemiResolvedPopconfirmThemeData t) =>
      t.widthPopconfirmIcon + t.spacingPopconfirmHeaderIconMarginRight;

  /// `$spacing-popconfirm_btn_close-margin: 24px` in packages/semi-foundation/popconfirm/variables.scss.
  /// Upstream-dead: no scss rule consumes it (the compiled popconfirm.css has
  /// no close-button margin rule); kept for provenance only.
  // ignore: unused_field
  static const double btnCloseMargin = 24;

  /// `$spacing-popconfirm_popover_with_arrow_inner_btn_close-marginTop: $spacing-popconfirm_btn_close-margin - $spacing-popconfirm_with_arrow-padding` in packages/semi-foundation/popconfirm/variables.scss.
  /// Derived (24 - 12 = 12) and equally unconsumed upstream; provenance only.
  // ignore: unused_field
  static const double btnCloseMarginTopWithArrow = 12;
}

/// The confirm card: popconfirm.scss's `-inner`/`-header`/`-body`/`-footer`
/// stack and the popover-family surface around it.
class _PopconfirmCard extends StatelessWidget {
  const _PopconfirmCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.withArrow,
    required this.showCloseIcon,
    required this.okText,
    required this.cancelText,
    required this.okType,
    required this.cancelType,
    required this.okLoading,
    required this.cancelLoading,
    required this.onConfirm,
    required this.onCancel,
  });

  final Widget? title;
  final Widget? content;
  final Widget? icon;
  final bool withArrow;
  final bool showCloseIcon;
  final String? okText;
  final String? cancelText;
  final SemiButtonType okType;
  final SemiButtonType cancelType;
  final bool okLoading;
  final bool cancelLoading;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final t = SemiPopconfirmTheme.resolve(context);
    final global = SemiTheme.of(context);
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final hasIcon = icon != null;

    // `$spacing-popconfirm_header_title-marginBottom: 8px` below the title.
    final titleNode = title == null
        ? null
        : Padding(
            padding: EdgeInsets.all(
              // `header_content_p-margin/-padding` (both 0) reset the `<p>`
              // box the title occupies upstream.
              t.spacingPopconfirmHeaderContentPMargin +
                  t.spacingPopconfirmHeaderContentPPadding,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: t.spacingPopconfirmHeaderTitleMarginBottom,
              ),
              child: DefaultTextStyle.merge(
                // `@include font-size-header-6` (16/22) — the title keeps the
                // h6 metrics and swaps the weight/color tokens.
                style: TextStyle(
                  fontSize: global.typography.fontSizeHeading6,
                  height:
                      global.typography.lineHeightHeading6 /
                      global.typography.fontSizeHeading6,
                  fontWeight: t.fontPopconfirmHeaderTitleFontWeight,
                  color: t.colorPopconfirmHeaderText,
                ),
                child: title!,
              ),
            ),
          );

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasIcon)
          Padding(
            // `margin-right: $spacing-popconfirm_header_icon-marginRight`
            // (flipped to margin-left by rtl.scss).
            padding: EdgeInsetsDirectional.only(
              end: t.spacingPopconfirmHeaderIconMarginRight,
            ),
            child: SizedBox(
              width: t.widthPopconfirmIcon,
              height: t.widthPopconfirmIcon,
              child: icon,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [?titleNode],
          ),
        ),
        if (showCloseIcon)
          SizedBox(
            // `$width-popconfirm_close_btn: 24px` — upstream-dead sizing hook;
            // consumes it as the close button box (the icon-only small button
            // is exactly 24×24 at defaults).
            width: t.widthPopconfirmCloseBtn,
            height: t.widthPopconfirmCloseBtn,
            child: SemiButton(
              null,
              icon: const SemiIcon(SemiIcons.close),
              type: cancelType,
              variant: SemiButtonVariant.borderless,
              size: SemiButtonSize.small,
              semanticsLabel: '关闭',
              onPressed: onCancel,
            ),
          ),
      ],
    );

    final body = content == null
        ? null
        : Padding(
            // `-body-withIcon` — `margin-left: $width-popconfirm-icon +
            // $spacing-popconfirm_header_icon-marginRight` (36), never
            // mirrored in rtl.scss.
            padding: EdgeInsets.only(
              left: hasIcon ? _PopconfirmMetrics.bodyWithIconIndent(t) : 0,
            ),
            child: Padding(
              // `body_p-margin/-padding` (both 0) reset the `<p>` box.
              padding: EdgeInsets.all(
                t.spacingPopconfirmBodyPMargin +
                    t.spacingPopconfirmBodyPPadding,
              ),
              child: DefaultTextStyle.merge(
                // The popover wrapper sets `@include font-size-regular` (14)
                // for popup content; the body text color is
                // `$color-popconfirm_body-text`.
                style: TextStyle(
                  fontSize: global.typography.fontSizeRegular,
                  color: t.colorPopconfirmBodyText,
                ),
                child: content!,
              ),
            ),
          );

    final cancelBtn = SemiButton(
      cancelText ?? '取消',
      type: cancelType,
      loading: cancelLoading,
      onPressed: onCancel,
    );
    final okBtn = SemiButton(
      okText ?? '确认',
      type: okType,
      variant: SemiButtonVariant.solid,
      loading: okLoading,
      onPressed: onConfirm,
    );
    final footer = Padding(
      // `margin-top: $spacing-popconfirm_footer-marginTop` (25).
      padding: EdgeInsets.only(top: t.spacingPopconfirmFooterMarginTop),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            // `footer > .semi-button:first-child:not(:last-child)` —
            // `margin-right: $spacing-popconfirm_footer_btn-marginRight` (8),
            // flipped to margin-left by rtl.scss.
            padding: EdgeInsetsDirectional.only(
              end: t.spacingPopconfirmFooterBtnMarginRight,
            ),
            child: cancelBtn,
          ),
          okBtn,
        ],
      ),
    );

    return ConstrainedBox(
      // `max-width: $width-popconfirm-maxWidth` (400).
      constraints: BoxConstraints(maxWidth: t.widthPopconfirmMaxWidth),
      child: DecoratedBox(
        // Popover wrapper skin:
        // `$color-popover-bg-default: var(--semi-color-bg-3)` and
        // `box-shadow: var(--semi-shadow-elevated)`, with
        // `$radius-popconfirm-popover` on the bubble
        // (`.semi-popconfirm-popover { border-radius: ... }` overrides the
        // popover radius with the popconfirm token).
        decoration: BoxDecoration(
          color: global.colors.colorBg3,
          borderRadius: BorderRadius.circular(t.radiusPopconfirmPopover),
          boxShadow: global.shadows.shadowElevated.toBoxShadows(),
        ),
        child: Padding(
          padding: withArrow
              ? _PopconfirmMetrics.withArrowInnerPadding(t, rtl: rtl)
              : _PopconfirmMetrics.innerPadding(t, rtl: rtl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, ?body, footer],
          ),
        ),
      ),
    );
  }
}
