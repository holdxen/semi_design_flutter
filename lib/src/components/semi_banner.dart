// SemiBanner — 上游 packages/semi-ui/banner/index.tsx 与
// packages/semi-foundation/banner/{banner.scss,rtl.scss,foundation.ts,
// constants.ts} 的移植。
//
// 主题对账 **22 = 22 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 22 声明：
// color 12、spacing 6、width 2、height 1、radius 1；无 animation.scss；
// `$module` 胶水与 rtl.scss 不计；carousel `40 = 34 + 6 + 0`、modal
// `81 = 63 + 18 + 0` 先例）。0 死变量。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts `TYPE: ['info', 'success', 'danger', 'warning']`
// - index.tsx defaultProps `type: 'info'` / `fullMode: true`
// - renderCloser：关闭按钮 `theme="borderless"` `size="small"`
//   `type="tertiary"`，默认图标 `IconClose`，语义 `locale?.close`
// - renderIcon：类型图标 `IconAlertTriangle`（warning）/
//   `IconTickCircle`（success）/ `IconInfoCircle`（info）/
//   `IconAlertCircle`（danger），`size="large"`（20x20）
// - render：标题 `heading={5}`（Typography.Title），描述
//   `Typography.Paragraph`（banner.scss:16 `margin: 0`）
// - render：根节点 `role="alert"`
// - render：`title || title === 0` / `children || children === 0` 数字 0 渲染
//   （空串 falsy 不渲染）
// - remove：`e.stopPropagation()`；foundation.ts removeBanner 的
//   `notifyClose(e)` + `setVisible()`
// - constructor：`'target' has been deprecated`（已废弃 prop 警告）
// - wrapper 类名表：bordered 仅 `!fullMode && bordered`
// - banner.scss `-full`：`justify-content: center` / `align-items: center`
// - banner.scss `-in-container`：`.#{$module}-title + .#{$module}-description`
//   间距仅此模式
// - rtl.scss：关闭钮 `margin-left: 0` /
//   `margin-right: $spacing-banner_closeBtn-marginLeft`，icon 右边距镜像
import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';
import '../theme/semi_banner_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'typography/semi_paragraph.dart';
import 'typography/semi_title.dart';

/// 类型（上游 `strings.TYPE`，缺省 `info`）。
enum SemiBannerType { info, success, danger, warning }

/// 常驻状态/通知横幅。受控/非受控显隐约定同 `SemiTag`：`visible` 为 null 时
/// 关闭自动隐藏，受控时只回调；受控转非受控保留最近受控值。
class SemiBanner extends StatefulWidget {
  const SemiBanner({
    super.key,
    this.type = SemiBannerType.info,
    this.title,
    this.description,
    this.icon,
    this.showIcon = true,
    this.closeIcon,
    this.closable = true,
    this.extra,
    this.fullMode = true,
    this.bordered = false,
    this.visible,
    this.onClose,
    this.closeSemanticsLabel,
  });
  final SemiBannerType type;

  /// 标题（上游 `title`）。String/num 走 `Typography.Title heading={5}`，
  /// Widget 原样；数字 0 渲染、空串不渲染（上游 falsy 约定）。
  final Object? title;

  /// 描述（上游 `description`）。String/num 走 `Typography.Paragraph`
  ///（`margin: 0`），Widget 原样；数字 0 渲染、空串不渲染。
  final Object? description;

  /// 类型图标替换（上游 `icon`）；null 用类型默认图标。
  final Widget? icon;

  /// 显式隐藏图标（上游 `icon: null`）。
  final bool showIcon;

  /// 关闭按钮图标（上游 `closeIcon`）；null 用 `IconClose`。
  final Widget? closeIcon;

  /// 显示关闭按钮（上游 `closeIcon: null` 隐藏）。
  final bool closable;

  /// 额外内容行（上游 `children`，类名 `-extra`）。
  final Widget? extra;

  /// 全幅模式（上游 `fullMode`，缺省 true）；false 为 in-container
  /// （圆角 + 标题描述间距 + 可描边）。
  final bool fullMode;

  /// 描边（上游 `bordered`），仅 `!fullMode` 生效。
  final bool bordered;

  /// 显式受控显隐；null 非受控（关闭自动隐藏）。
  final bool? visible;

  /// 关闭通知（上游 `onClose`，无取消语义）。
  final VoidCallback? onClose;

  /// 关闭按钮语义标签（上游 locale `Banner.close`）；null 用 '关闭'。
  final String? closeSemanticsLabel;

  @override
  State<SemiBanner> createState() => _SemiBannerState();
}

class _SemiBannerState extends State<SemiBanner> {
  bool _visible = true;
  @override
  void didUpdateWidget(SemiBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != null && widget.visible == null) {
      _visible = oldWidget.visible!;
    }
  }

  void _close() {
    // index.tsx remove 的 `e.stopPropagation()` 不适用（Flutter 无冒泡）；
    // foundation.ts removeBanner：`notifyClose(e)` 后 `setVisible()`。
    widget.onClose?.call();
    if (mounted && widget.visible == null) {
      setState(() => _visible = false);
    }
  }

  static bool _hasContent(Object? value) =>
      value != null && (value is! String || value.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (!(widget.visible ?? _visible)) return const SizedBox.shrink();
    final t = SemiBannerTheme.resolve(context);
    final (bg, fg, borderColor) = switch (widget.type) {
      SemiBannerType.info => (
        t.colorBannerInfoBgDefault,
        t.colorBannerInfoTextDefault,
        t.colorBannerInfoBorderDefault,
      ),
      SemiBannerType.warning => (
        t.colorBannerWarningBgDefault,
        t.colorBannerWarningTextDefault,
        t.colorBannerWarningBorderDefault,
      ),
      SemiBannerType.success => (
        t.colorBannerSuccessBgDefault,
        t.colorBannerSuccessTextDefault,
        t.colorBannerSuccessBorderDefault,
      ),
      SemiBannerType.danger => (
        t.colorBannerDangerBgDefault,
        t.colorBannerDangerTextDefault,
        t.colorBannerDangerBorderDefault,
      ),
    };
    final iconSlot = !widget.showIcon
        ? null
        : Padding(
            // rtl.scss 把 margin-right 镜像为 margin-left——方向性边距自动翻转。
            padding: EdgeInsetsDirectional.only(
              end: t.spacingBannerIconMarginRight,
            ),
            child:
                widget.icon ??
                SemiIcon(
                  switch (widget.type) {
                    SemiBannerType.warning => SemiIcons.alertTriangle,
                    SemiBannerType.success => SemiIcons.tickCircle,
                    SemiBannerType.info => SemiIcons.infoCircle,
                    SemiBannerType.danger => SemiIcons.alertCircle,
                  },
                  size: SemiIconSize.large,
                  color: fg,
                ),
          );
    final hasTitle = _hasContent(widget.title);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle)
          switch (widget.title) {
            final Widget w => w,
            final o => SemiTitle(
              o.toString(),
              heading: 5,
              style: TextStyle(color: fg),
            ),
          },
        if (_hasContent(widget.description))
          Padding(
            // `.title + .description` 仅 in-container 有间距（fullMode 无）。
            padding: EdgeInsetsDirectional.only(
              top: hasTitle && !widget.fullMode
                  ? t.spacingBannerTitleDescriptionMarginTop
                  : 0,
            ),
            child: switch (widget.description) {
              final Widget w => w,
              final o => SemiParagraph(
                o.toString(),
                style: TextStyle(color: fg),
              ),
            },
          ),
      ],
    );
    final content = widget.fullMode
        ? Row(
            // banner.scss `-full`：`justify-content: center` /
            // `align-items: center`。
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ?iconSlot,
              // CSS shrink-to-fit：loose 约束下 Text 自然宽度（最宽行）封顶
              // 可用宽，Column 宽度取最宽子项。
              Flexible(child: body),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?iconSlot,
              // `-in-container` 的 content-body `flex: 1`。
              Expanded(child: body),
            ],
          );
    final closer = !widget.closable
        ? null
        : Padding(
            // rtl.scss：`margin-left: 0` /
            // `margin-right: $spacing-banner_closeBtn-marginLeft`。
            padding: EdgeInsetsDirectional.only(
              start: t.spacingBannerCloseBtnMarginLeft,
            ),
            child: SizedBox(
              width: t.widthBannerCloseBtn,
              height: t.heightBannerCloseBtn,
              child: SemiButton(
                null,
                icon: widget.closeIcon ?? const SemiIcon(SemiIcons.close),
                type: SemiButtonType.tertiary,
                variant: SemiButtonVariant.borderless,
                size: SemiButtonSize.small,
                semanticsLabel:
                    widget.closeSemanticsLabel ??
                    SemiLocalizations.of(context).close,
                onPressed: _close,
              ),
            ),
          );
    // `role="alert"`：常驻状态提示，按 live region 报告。
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: t.spacingBannerPaddingY,
          horizontal: t.spacingBannerPaddingX,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: widget.fullMode
              ? null
              : BorderRadius.circular(t.radiusBanner),
          border: widget.bordered && !widget.fullMode
              ? Border.all(width: t.widthBannerBorder, color: borderColor)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: content),
                ?closer,
              ],
            ),
            if (_hasContent(widget.extra))
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: t.spacingBannerExtraMarginTop,
                ),
                child: widget.extra,
              ),
          ],
        ),
      ),
    );
  }
}
