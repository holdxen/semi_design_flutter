// SemiNotification — 上游 packages/semi-ui/notification/{index.tsx,notice.tsx,
// useNotification} 与 packages/semi-foundation/notification/{notification.scss,
// variables.scss,animation.scss,rtl.scss,notificationFoundation.ts,
// notificationListFoundation.ts,constants.ts} 的移植；弹层底座为 vendored
// flutter_smart_dialog 引擎（lib/src/overlay/dialog_engine，PROVENANCE.md，
// SemiModal 先例）。
//
// 主题对账 **43 = 35 FIELDS + 8 MOTION + 0 INTERNAL**（variables.scss 35
// 声明：color 17、width 4、spacing 11、radius 1、font 2；animation.scss 8
// 声明；`$module: #{$prefix}-notification` 类名胶水与 rtl.scss 不计，modal
// `81 = 63 + 18 + 0`、banner `22 = 22 + 0 + 0` 先例）。1 条死变量
// `$spacing-notification_notice-marginRight`（上游零消费——死变量留档不
// 消费，见 tool/generate_notification.py）。quirk：`$animation_function-
// notification-hide` 行尾注释 `//消失时-过渡曲线`（缺空格）照抄留档。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts：`types: ['warning', 'success', 'info', 'error', 'default']`
//   / `themes: ['normal', 'light']` / `directions: ['ltr', 'rtl']`
// - index.tsx defaultConfig：`duration: 3`（单位秒）、`position: 'topRight'`、
//   `zIndex: 1010`、`title: ''`、`content: ''`
// - notice.tsx defaultProps：`showClose: true`、`theme: 'normal'`
// - notice.tsx renderTypeIcon：类型图标 `IconAlertTriangle`（warning）/
//   `IconTickCircle`（success）/ `IconInfoCircle`（info）/
//   `IconAlertCircle`（error），`size="large"`（20x20）；icon-show 类名门槛
//   `types.includes(type)`（含 'default'——类名出现但无图标）；自定义图标
//   clone 规则 `size: iconType.props.size || 'large'`
// - notice.tsx render：关闭钮 `theme="borderless"` `size="small"`
//   `type="tertiary"`，图标 `IconClose`，槽 `height: $width-icon-extra-large`
// - notice.tsx render：`{title ? (…) : ''}` / `{content ? (…) : ''}` falsy
//   渲染（纯 truthy——数字 0/空串不渲染，无 banner `|| title === 0` 例外）
// - notice.tsx render：根节点 `role="alert"`；`aria-labelledby` 标题引用
//   （titleID 前缀 `semi-notification-notice-title`，实例内稳定）
// - notice.tsx：`onMouseEnter` / `onMouseLeave` 悬停暂停计时；关闭路径
//   foundation.close(e) 的 `e.stopPropagation()`（Flutter 无冒泡）
// - notification.scss `-notice`：`@include shadow-elevated`、
//   `@include font-size-header-6`（标题 16/22）、`@include font-size-regular`
//   （内容 14/20）、`word-wrap: break-word`
// - notification.scss `-notice-light`：`background-image: linear-gradient(0deg,`
//   …) 覆盖层叠 `background-color: $color-notification_ambient-bg` 底色 +
//   1px 语义色描边
// - notification.scss `-list`：`z-index: $z-notification`（引擎插入序表达）、
//   `pointer-events: none`；`-notice` `pointer-events: auto`
// - notification.scss keyframes：`translateY(-100%)`（top）/
//   `translateY(100%)`（bottom）/ `translateX(-100%)`（topLeft/bottomLeft）/
//   `translateX(100%)`（topRight/bottomRight）——按 placement 反向滑出
// - index.tsx：`appliedUpdates` + `restartCloseTimer`（每次 update() 恰好
//   一次重启计时——本移植以 updateSeq 变化表达）；`scheduleRemovedNoticeRelease`
//   350ms 兜底释放（animationend 不可靠场景——Flutter 动画状态回调可靠，
//   等价由 reverse 完成回调表达）
// - index.tsx `getPopupContainer`（容器路由未移植——宿主恒挂 ambient
//   Overlay，SemiModal engine 路先例）
import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';
import '../overlay/dialog_engine/flutter_smart_dialog.dart';
import '../theme/semi_notification_theme.dart';
import '../theme/semi_notification_theme_data.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_inset_shadow.dart';

/// 类型（上游 `strings.types`；`default` 是 Dart 保留字——avatar `normal`
/// 先例，`SemiNotification.open()` 强制此值）。
enum SemiNotificationType { normal, info, success, warning, error }

/// 卡片填充（上游 `NoticeTheme` / `strings.themes`，缺省 `normal`；`light`
/// 语义色浅底 + 描边——badge `variant` 更名先例）。
enum SemiNotificationVariant { normal, light }

/// 位置（上游 `NoticePosition`，缺省 `position: 'topRight'`）。
enum SemiNotificationPosition {
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// 通知卡片（上游 `Notice`——notice.tsx + notificationFoundation.ts）。
///
/// 自动关闭计时、悬停暂停、关闭钮/计时器双路径与上游 foundation 一致：
/// 计时器/关闭钮都走 `notifyWrapperToRemove`（[onRemove]——宿主移除）+
/// `notifyClose`（[onClose]）；关闭钮先行 [onCloseClick]。更新重启计时由
/// [updateSeq] 驱动（上游 `appliedUpdates` + `restartCloseTimer` 语义——
/// 每次 update() 恰好一次）。
class SemiNotificationNotice extends StatefulWidget {
  const SemiNotificationNotice({
    super.key,
    this.id = '',
    this.title,
    this.content,
    this.type = SemiNotificationType.normal,
    this.variant = SemiNotificationVariant.normal,
    this.icon,
    this.showClose = true,
    this.duration = const Duration(seconds: 3),
    this.isClosing = false,
    this.updateSeq = 0,
    this.onClose,
    this.onCloseClick,
    this.onClick,
    this.onRemove,
    this.closeSemanticsLabel,
  });

  /// 通知 id（上游 `id`，[onCloseClick] 回传）。
  final String id;

  /// 标题（上游 `title`）。String/num 走 16/22 标题排版，Widget 原样；
  /// `{title ? (…) : ''}` 纯 truthy——数字 0/空串不渲染。
  final Object? title;

  /// 内容（上游 `content`）。String/num 走 14/20 正文排版，Widget 原样；
  /// `{content ? (…) : ''}` 纯 truthy——数字 0/空串不渲染。
  final Object? content;

  /// 类型（上游 `type`）；`normal`（'default'）无图标。
  final SemiNotificationType type;

  /// 填充（上游 `theme`，缺省 `normal`）；`light` 出语义色浅底 + 描边。
  final SemiNotificationVariant variant;

  /// 类型图标替换（上游 `icon`）；null 用类型默认图标。SemiIcon 未指定
  /// 尺寸时按 `size: iconType.props.size || 'large'` 规则补 20x20。
  final Widget? icon;

  /// 显示关闭按钮（上游 `showClose`，缺省 true）。
  final bool showClose;

  /// 自动关闭时长（上游 `duration` 单位秒、缺省 `duration: 3`）；[Duration.zero]
  /// 不排自动关闭（上游 falsy `duration` 语义）。
  final Duration duration;

  /// 正在退出（上游 `isClosing`——私有 prop）：抑制计时（含悬停恢复）。
  final bool isClosing;

  /// 更新序号（上游 `appliedUpdates` 触发的 `restartCloseTimer`）：变化时
  /// 重启自动关闭计时一次。
  final int updateSeq;

  /// 关闭通知（上游 `onClose` / `notifyClose`——计时器与关闭钮均触发）。
  final VoidCallback? onClose;

  /// 关闭钮点击（上游 `onCloseClick(id)`——先于移除触发）。
  final void Function(String id)? onCloseClick;

  /// 卡片点击（上游 `onClick`，无冒泡参数）。
  final VoidCallback? onClick;

  /// 请求宿主移除（上游私有 `close` prop——`notifyWrapperToRemove`）。
  final VoidCallback? onRemove;

  /// 关闭钮语义标签；null 用 '关闭'（上游图标钮无 aria-label——补语义）。
  final String? closeSemanticsLabel;

  @override
  State<SemiNotificationNotice> createState() => _SemiNotificationNoticeState();
}

class _SemiNotificationNoticeState extends State<SemiNotificationNotice> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // notificationFoundation.ts init：`_startCloseTimer()`——挂载即退出
    // （isClosing）不排计时（closeLifecycle 语义）。
    if (!widget.isClosing) _startTimer();
  }

  @override
  void didUpdateWidget(SemiNotificationNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isClosing != oldWidget.isClosing) {
      if (widget.isClosing) {
        _clearCloseTimer();
      } else {
        restartCloseTimer();
      }
    } else if (widget.updateSeq != oldWidget.updateSeq) {
      // 上游 ref 回调：`appliedUpdates` 命中后 `restartCloseTimer()`——
      // 每次 update() 恰好一次（entrance 结束的重渲染不再触发）。
      restartCloseTimer();
    }
  }

  @override
  void dispose() {
    // notificationFoundation.ts destroy（canonical）：`_clearCloseTimer()`。
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  /// 上游 `foundation.restartCloseTimer()`（clear + start）。
  void restartCloseTimer() {
    _clearCloseTimer();
    _startTimer();
  }

  /// 上游 `foundation._clearCloseTimer()`（悬停暂停）。
  void _clearCloseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    // 上游 `_startCloseTimer`：`duration && isNumber(duration)`——0 不排
    // 计时（测试以 `duration: 0` 固定通知）。
    if (widget.duration <= Duration.zero) return;
    _timer = Timer(widget.duration, _autoClose);
  }

  void _autoClose() {
    // foundation.close()：`notifyWrapperToRemove(_id)` + `notifyClose()`——
    // 计时器路径不触发 onCloseClick。
    widget.onRemove?.call();
    widget.onClose?.call();
  }

  void _close() {
    // notice.tsx close：`props.onCloseClick(props.id)` 先行，再
    // foundation.close(e)（`e.stopPropagation()`——Flutter 无冒泡，按钮
    // 手势不透传父级 GestureDetector）。
    widget.onCloseClick?.call(widget.id);
    widget.onRemove?.call();
    widget.onClose?.call();
  }

  /// `{title ? (…) : ''}` / `{content ? (…) : ''}` 纯 truthy 渲染。
  static bool _falsy(Object? value) =>
      value == null || value == '' || value == 0 || value == false;

  Widget? _typeIcon(SemiResolvedNotificationThemeData t) {
    // notice.tsx renderTypeIcon：`types.includes(type)` 类名门槛（含
    // 'default'——iconMap 无该项 → 无图标）。
    final custom = widget.icon;
    if (custom != null) {
      // `isSemiIcon(iconType) ? React.cloneElement(iconType, { size: iconType.props.size || 'large' }) : iconType`
      if (custom is SemiIcon &&
          custom.size == null &&
          custom.customSize == null) {
        if (custom.data != null) {
          return SemiIcon(
            custom.data,
            size: SemiIconSize.large,
            color: custom.color,
            rotate: custom.rotate,
            spin: custom.spin,
            semanticsLabel: custom.semanticsLabel,
            excludeFromSemantics: custom.excludeFromSemantics,
          );
        }
        if (custom.assetName != null) {
          return SemiIcon.asset(
            custom.assetName!,
            package: custom.package,
            size: SemiIconSize.large,
            color: custom.color,
            rotate: custom.rotate,
            spin: custom.spin,
            semanticsLabel: custom.semanticsLabel,
            excludeFromSemantics: custom.excludeFromSemantics,
          );
        }
        return SemiIcon.svg(
          custom.svgSource!,
          size: SemiIconSize.large,
          color: custom.color,
          rotate: custom.rotate,
          spin: custom.spin,
          semanticsLabel: custom.semanticsLabel,
          excludeFromSemantics: custom.excludeFromSemantics,
        );
      }
      return custom;
    }
    return switch (widget.type) {
      SemiNotificationType.warning => SemiIcon(
        SemiIcons.alertTriangle,
        size: SemiIconSize.large,
        color: t.colorNotificationWarningIcon,
      ),
      SemiNotificationType.success => SemiIcon(
        SemiIcons.tickCircle,
        size: SemiIconSize.large,
        color: t.colorNotificationSuccessIcon,
      ),
      SemiNotificationType.info => SemiIcon(
        SemiIcons.infoCircle,
        size: SemiIconSize.large,
        color: t.colorNotificationInfoIcon,
      ),
      SemiNotificationType.error => SemiIcon(
        SemiIcons.alertCircle,
        size: SemiIconSize.large,
        color: t.colorNotificationDangerIcon,
      ),
      SemiNotificationType.normal => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiNotificationTheme.resolve(context);
    final typography = SemiTheme.of(context).typography;
    // notification.scss `-notice` `@include shadow-elevated`——mixin 非声明
    // 变量，走全局 shadow token（generate_card `shadowElevated` 先例）；
    // drop 层进 BoxDecoration、inset 层走 SemiInsetShadow 画师（见差异清单）。
    final shadows = SemiTheme.of(context).shadows.shadowElevated;
    final icon = _typeIcon(t);
    final iconSlot = icon == null
        ? null
        : Padding(
            // rtl.scss icon 边距规则与基础同值（no-op quirk）——
            // EdgeInsetsDirectional 镜像（banner 先例）。
            padding: EdgeInsetsDirectional.only(
              end: t.spacingNotificationNoticeIconMarginRight,
            ),
            child: SizedBox(
              width: t.widthNotificationNoticeIcon,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: icon,
              ),
            ),
          );
    final isLight = widget.variant == SemiNotificationVariant.light;
    final (lightBg, lightBorder) = switch (widget.type) {
      SemiNotificationType.warning => (
        t.colorNotificationWarningLightBg,
        t.colorNotificationWarningLightBorder,
      ),
      SemiNotificationType.success => (
        t.colorNotificationSuccessLightBg,
        t.colorNotificationSuccessLightBorder,
      ),
      SemiNotificationType.info => (
        t.colorNotificationInfoLightBg,
        t.colorNotificationInfoLightBorder,
      ),
      SemiNotificationType.error => (
        t.colorNotificationDangerLightBg,
        t.colorNotificationDangerLightBorder,
      ),
      // notification.scss `-light`：`.…-info, .…-default` 共用 info 通道。
      SemiNotificationType.normal => (
        t.colorNotificationInfoLightBg,
        t.colorNotificationInfoLightBorder,
      ),
    };
    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?iconSlot,
        Expanded(
          child: Padding(
            // rtl.scss content-wrapper 边距规则与基础同值（no-op quirk）——
            // EdgeInsetsDirectional 镜像。
            padding: EdgeInsetsDirectional.only(
              end: t.spacingNotificationNoticeContentWrapperMarginRight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_falsy(widget.title))
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: t.spacingNotificationNoticeTitleMarginBottom,
                    ),
                    child: switch (widget.title) {
                      final Widget w => w,
                      // `@include font-size-header-6` 16/22 +
                      // `font-weight: $font-notification_notice_title-fontWeight`。
                      final o => Text(
                        o.toString(),
                        style: TextStyle(
                          fontSize: typography.fontSizeHeading6,
                          height:
                              typography.lineHeightHeading6 /
                              typography.fontSizeHeading6,
                          fontWeight: t.fontNotificationNoticeTitleFontWeight,
                          color: t.colorNotificationTitleText,
                        ),
                      ),
                    },
                  ),
                if (!_falsy(widget.content))
                  switch (widget.content) {
                    final Widget w => w,
                    // `@include font-size-regular` 14/20 +
                    // `font-weight: $font-notification_notice_content-fontWeight`。
                    final o => Text(
                      o.toString(),
                      style: TextStyle(
                        fontSize: typography.fontSizeRegular,
                        height:
                            typography.lineHeightRegular /
                            typography.fontSizeRegular,
                        fontWeight: t.fontNotificationNoticeContentFontWeight,
                        color: t.colorNotificationContentText,
                      ),
                    ),
                  },
              ],
            ),
          ),
        ),
        if (widget.showClose)
          SizedBox(
            // icon-close 槽 `height: $width-icon-extra-large`（24）。
            height: 24,
            child: SemiButton(
              null,
              icon: SemiIcon(
                SemiIcons.close,
                color: t.colorNotificationCloseBtnIcon,
              ),
              type: SemiButtonType.tertiary,
              variant: SemiButtonVariant.borderless,
              size: SemiButtonSize.small,
              semanticsLabel:
                  widget.closeSemanticsLabel ??
                  SemiLocalizations.of(context).close,
              onPressed: _close,
            ),
          ),
      ],
    );
    // `width: auto`（widthNotificationNotice）——shrink-to-fit 语义在列表列
    // （IntrinsicWidth）实现：列宽取最宽卡片、下限 minWidth；单卡铺满可用宽。
    return Semantics(
      // `role="alert"` + `aria-labelledby`（标题为语义锚
      // `semi-notification-notice-title`）——live region 报告。
      liveRegion: true,
      child: MouseRegion(
        // `onMouseEnter`：悬停暂停计时。
        onEnter: (_) => _clearCloseTimer(),
        // `onMouseLeave`：`startCloseTimer`（`!isClosing` 守卫恢复计时）。
        onExit: (_) {
          if (!widget.isClosing) restartCloseTimer();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onClick,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: t.widthNotificationNoticeMinWidth,
            ),
            child: Container(
              decoration: BoxDecoration(
                // light：`background-image: linear-gradient(0deg, …-light-bg, …-light-bg)`
                // 等价单色覆盖层与 `background-color: $color-notification_ambient-bg`
                // 底色的 alpha 合成（覆盖层不透明时即 _light-bg）——单
                // BoxDecoration 圆角一体成型，内层直角色块不再溢出外层圆角。
                color: isLight
                    ? Color.alphaBlend(lightBg, t.colorNotificationAmbientBg)
                    : t.colorNotificationBgDefault,
                borderRadius: BorderRadius.circular(t.radiusNotificationNotice),
                border: isLight
                    ? Border.all(
                        width: t.widthNotificationNoticeBorder,
                        color: lightBorder,
                      )
                    : null,
                boxShadow: shadows.toDropBoxShadows(),
              ),
              child: SemiInsetShadow(
                shadows: shadows,
                borderRadius: BorderRadius.circular(t.radiusNotificationNotice),
                borderWidth: isLight ? t.widthNotificationNoticeBorder : 0,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: t.spacingNotificationNoticePaddingTop,
                    // rtl.scss `padding-right: …-paddingLeft` /
                    // `padding-left: …-paddingRight`——方向性边距自动镜像。
                    bottom: t.spacingNotificationNoticePaddingBottom,
                    start: t.spacingNotificationNoticePaddingLeft,
                    end: t.spacingNotificationNoticePaddingRight,
                  ),
                  child: body,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 入退场位移（notification.scss keyframes 按 placement 反向滑出 + 透明度）。
class _NoticeSlot extends StatefulWidget {
  const _NoticeSlot({
    required this.entry,
    required this.position,
    required this.onRemove,
    required this.onReleased,
  });

  final _NoticeEntry entry;
  final SemiNotificationPosition position;

  /// 宿主移除请求注入（上游 `close={this.remove}`）。
  final VoidCallback onRemove;
  final void Function(_NoticeEntry entry) onReleased;

  @override
  State<_NoticeSlot> createState() => _NoticeSlotState();
}

class _NoticeSlotState extends State<_NoticeSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _released = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.entry.removing) {
      // 挂载即退出：无入动画，直接释放（closeLifecycle 挂载即 isClosing）。
      _controller.value = 0;
      _release(widget.entry);
    } else if (!widget.entry.motion) {
      // `motion: false`（defaultConfig）：无入动画。
      _controller.value = 1;
    } else {
      final t = SemiNotificationTheme.resolve(context);
      // 出现动画：opacity `$animation_opacity-notification-show` → 1、按
      // placement 位移回原位（`animation_delay-*: 0ms` 叠入时长）。
      _controller.animateTo(
        1,
        duration:
            t.animationDurationNotificationShow +
            t.animationDelayNotificationShow,
        curve: t.animationFunctionNotificationShow,
      );
    }
  }

  @override
  void didUpdateWidget(_NoticeSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry.removing && !oldWidget.entry.removing) {
      // 退场——按当前 entry 捕获释放对象（同 id 复用换代后不误放新实例）。
      final leaving = widget.entry;
      if (!widget.entry.motion) {
        // `motion: false`：无 leave 动画，即刻释放（leaveAnimations 语义）。
        _controller.value = 0;
        _release(leaving);
        return;
      }
      final t = SemiNotificationTheme.resolve(context);
      // 消失动画：opacity 1 → `$animation_opacity-notification-hide`、按
      // placement 反向滑出；完成即释放（上游 `scheduleRemovedNoticeRelease`
      // 350ms 兜底的等价——Flutter 动画状态回调可靠）。
      _controller
          .animateBack(
            0,
            duration:
                t.animationDurationNotificationHide +
                t.animationDelayNotificationHide,
            curve: t.animationFunctionNotificationHide,
          )
          .whenCompleteOrCancel(() => _release(leaving));
    } else if (!widget.entry.removing && oldWidget.entry.removing) {
      // 同 id 复用 leaving 通知（上游 leaveAnimations：旧实例即弃、新实例
      // `animation-show` 重新入场）——重置释放标记并重放入场动画。
      _released = false;
      if (!widget.entry.motion) {
        _controller.value = 1;
      } else {
        final t = SemiNotificationTheme.resolve(context);
        _controller.animateTo(
          1,
          duration:
              t.animationDurationNotificationShow +
              t.animationDelayNotificationShow,
          curve: t.animationFunctionNotificationShow,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _release(_NoticeEntry entry) {
    // 只释放当前代 entry：同 id 复用换代后，旧 leave 的完成回调不得误删新实例。
    if (_released || !identical(widget.entry, entry)) return;
    _released = true;
    // setState 触点不在 build 生命周期内联触发（宿主在 build 中）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(widget.entry, entry)) widget.onReleased(entry);
    });
  }

  Offset _offset() => switch (widget.position) {
    // `translateY(-100%)`
    SemiNotificationPosition.top => const Offset(0, -1),
    // `translateY(100%)`
    SemiNotificationPosition.bottom => const Offset(0, 1),
    // `translateX(-100%)`
    SemiNotificationPosition.topLeft ||
    SemiNotificationPosition.bottomLeft => const Offset(-1, 0),
    // `translateX(100%)`
    SemiNotificationPosition.topRight ||
    SemiNotificationPosition.bottomRight => const Offset(1, 0),
  };

  @override
  Widget build(BuildContext context) {
    final t = SemiNotificationTheme.resolve(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        return FractionalTranslation(
          translation: _offset() * (1 - v),
          child: FadeTransition(
            // show/hide 起止透明度同为 0（`$animation_opacity-notification-show`
            // / `-hide`）——begin 取 show、end 取 1-hide，单曲线驱动双向。
            opacity: _controller.drive(
              Tween<double>(
                begin: t.animationOpacityNotificationShow,
                end: 1 - t.animationOpacityNotificationHide,
              ),
            ),
            child: child,
          ),
        );
      },
      child: SemiNotificationNotice(
        id: widget.entry.id,
        title: widget.entry.title,
        content: widget.entry.content,
        type: widget.entry.type,
        variant: widget.entry.variant ?? SemiNotificationVariant.normal,
        icon: widget.entry.icon,
        showClose: widget.entry.showClose,
        duration: widget.entry.duration,
        isClosing: widget.entry.removing,
        updateSeq: widget.entry.updateSeq,
        onClose: widget.entry.onClose,
        onCloseClick: widget.entry.onCloseClick,
        onClick: widget.entry.onClick,
        onRemove: widget.onRemove,
        closeSemanticsLabel: widget.entry.closeSemanticsLabel,
      ),
    );
  }
}

/// 单条通知（上游 `NoticeInstance`）。
class _NoticeEntry {
  const _NoticeEntry({
    required this.id,
    required this.type,
    required this.themeData,
    required this.duration,
    required this.position,
    required this.updateSeq,
    required this.removing,
    required this.showClose,
    required this.motion,
    this.title,
    this.content,
    this.variant,
    this.icon,
    this.onClose,
    this.onCloseClick,
    this.onClick,
    this.closeSemanticsLabel,
    this.top,
    this.left,
    this.bottom,
    this.right,
  });

  final String id;
  final SemiNotificationType type;
  final SemiNotificationThemeData themeData;
  final Duration duration;
  final SemiNotificationPosition position;
  final int updateSeq;
  final bool removing;
  final bool showClose;
  final bool motion;
  final Object? title;
  final Object? content;
  final SemiNotificationVariant? variant;
  final Widget? icon;
  final VoidCallback? onClose;
  final void Function(String id)? onCloseClick;
  final VoidCallback? onClick;
  final String? closeSemanticsLabel;

  /// 列表偏移（上游 `Notification.config` 的 top/left/bottom/right——
  /// setPosInStyle 取首条通知）。
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;

  _NoticeEntry asRemoving() => _NoticeEntry(
    id: id,
    type: type,
    themeData: themeData,
    duration: duration,
    position: position,
    updateSeq: updateSeq,
    removing: true,
    showClose: showClose,
    motion: motion,
    title: title,
    content: content,
    variant: variant,
    icon: icon,
    onClose: onClose,
    onCloseClick: onCloseClick,
    onClick: onClick,
    closeSemanticsLabel: closeSemanticsLabel,
    top: top,
    left: left,
    bottom: bottom,
    right: right,
  );
}

/// 命令式入口（上游 `NotificationList` 静态层 + `Notification.*` 族）。
///
/// ```dart
/// final id = SemiNotification.success(title: '已保存', content: '设置已更新');
/// SemiNotification.close(id);
/// ```
class SemiNotification {
  SemiNotification._();

  static const String _tag = 'semi-notification';

  // 上游 defaultConfig + `Notification.config` 的全局缺省。
  static Duration _defaultDuration = const Duration(seconds: 3);
  static SemiNotificationPosition _defaultPosition =
      SemiNotificationPosition.topRight;
  static double? _defaultTop;
  static double? _defaultLeft;
  static double? _defaultBottom;
  static double? _defaultRight;

  /// 上游 `pendingNotices`——宿主挂载前的暂存（Map 插入序 = add 序）。
  static final Map<String, _NoticeEntry> _pending = {};

  static _NotificationHostState? _host;
  static bool _installing = false;
  static final Random _random = Random();

  /// `Notification.open`（type 强制 'default' → [SemiNotificationType.normal]）。
  static String open({
    BuildContext? context,
    String? id,
    Object? title,
    Object? content,
    Duration? duration,
    SemiNotificationPosition? position,
    SemiNotificationVariant? variant,
    Widget? icon,
    bool? showClose,
    bool? motion,
    VoidCallback? onClick,
    VoidCallback? onClose,
    void Function(String id)? onCloseClick,
    double? top,
    double? left,
    double? bottom,
    double? right,
    String? closeSemanticsLabel,
  }) => _add(
    SemiNotificationType.normal,
    context: context,
    id: id,
    title: title,
    content: content,
    duration: duration,
    position: position,
    variant: variant,
    icon: icon,
    showClose: showClose,
    motion: motion,
    onClick: onClick,
    onClose: onClose,
    onCloseClick: onCloseClick,
    top: top,
    left: left,
    bottom: bottom,
    right: right,
    closeSemanticsLabel: closeSemanticsLabel,
  );

  /// `Notification.info`（type 强制 info）。
  static String info({
    BuildContext? context,
    String? id,
    Object? title,
    Object? content,
    Duration? duration,
    SemiNotificationPosition? position,
    SemiNotificationVariant? variant,
    Widget? icon,
    bool? showClose,
    bool? motion,
    VoidCallback? onClick,
    VoidCallback? onClose,
    void Function(String id)? onCloseClick,
    double? top,
    double? left,
    double? bottom,
    double? right,
    String? closeSemanticsLabel,
  }) => _add(
    SemiNotificationType.info,
    context: context,
    id: id,
    title: title,
    content: content,
    duration: duration,
    position: position,
    variant: variant,
    icon: icon,
    showClose: showClose,
    motion: motion,
    onClick: onClick,
    onClose: onClose,
    onCloseClick: onCloseClick,
    top: top,
    left: left,
    bottom: bottom,
    right: right,
    closeSemanticsLabel: closeSemanticsLabel,
  );

  /// `Notification.success`（type 强制 success）。
  static String success({
    BuildContext? context,
    String? id,
    Object? title,
    Object? content,
    Duration? duration,
    SemiNotificationPosition? position,
    SemiNotificationVariant? variant,
    Widget? icon,
    bool? showClose,
    bool? motion,
    VoidCallback? onClick,
    VoidCallback? onClose,
    void Function(String id)? onCloseClick,
    double? top,
    double? left,
    double? bottom,
    double? right,
    String? closeSemanticsLabel,
  }) => _add(
    SemiNotificationType.success,
    context: context,
    id: id,
    title: title,
    content: content,
    duration: duration,
    position: position,
    variant: variant,
    icon: icon,
    showClose: showClose,
    motion: motion,
    onClick: onClick,
    onClose: onClose,
    onCloseClick: onCloseClick,
    top: top,
    left: left,
    bottom: bottom,
    right: right,
    closeSemanticsLabel: closeSemanticsLabel,
  );

  /// `Notification.error`（type 强制 error）。
  static String error({
    BuildContext? context,
    String? id,
    Object? title,
    Object? content,
    Duration? duration,
    SemiNotificationPosition? position,
    SemiNotificationVariant? variant,
    Widget? icon,
    bool? showClose,
    bool? motion,
    VoidCallback? onClick,
    VoidCallback? onClose,
    void Function(String id)? onCloseClick,
    double? top,
    double? left,
    double? bottom,
    double? right,
    String? closeSemanticsLabel,
  }) => _add(
    SemiNotificationType.error,
    context: context,
    id: id,
    title: title,
    content: content,
    duration: duration,
    position: position,
    variant: variant,
    icon: icon,
    showClose: showClose,
    motion: motion,
    onClick: onClick,
    onClose: onClose,
    onCloseClick: onCloseClick,
    top: top,
    left: left,
    bottom: bottom,
    right: right,
    closeSemanticsLabel: closeSemanticsLabel,
  );

  /// `Notification.warning`（type 强制 warning）。
  static String warning({
    BuildContext? context,
    String? id,
    Object? title,
    Object? content,
    Duration? duration,
    SemiNotificationPosition? position,
    SemiNotificationVariant? variant,
    Widget? icon,
    bool? showClose,
    bool? motion,
    VoidCallback? onClick,
    VoidCallback? onClose,
    void Function(String id)? onCloseClick,
    double? top,
    double? left,
    double? bottom,
    double? right,
    String? closeSemanticsLabel,
  }) => _add(
    SemiNotificationType.warning,
    context: context,
    id: id,
    title: title,
    content: content,
    duration: duration,
    position: position,
    variant: variant,
    icon: icon,
    showClose: showClose,
    motion: motion,
    onClick: onClick,
    onClose: onClose,
    onCloseClick: onCloseClick,
    top: top,
    left: left,
    bottom: bottom,
    right: right,
    closeSemanticsLabel: closeSemanticsLabel,
  );

  /// `Notification.close(id)` / `removeNotice(id)`——静默移除（含 leave
  /// 动画），不触发 onClose/onCloseClick（上游列表级移除语义）。
  static void close(String id) {
    _pending.remove(id);
    _host?.remove(id);
  }

  /// `Notification.destroyAll()`——瞬时卸载（上游 microtask 卸 wrapper：
  /// leave 动画不播、不触发回调）。
  static void destroyAll() {
    _pending.clear();
    _installing = false;
    unawaited(SmartDialog.dismiss<void>(tag: _tag, force: true));
  }

  /// `Notification.config(opts)`——改写后续 add 的全局缺省（top/left/
  /// bottom/right/duration/position）；zIndex 留档不消费（`zIndex: 1010`
  /// 引擎插入序表达）。
  static void config({
    double? top,
    double? bottom,
    double? left,
    double? right,
    Duration? duration,
    SemiNotificationPosition? position,
    int? zIndex,
  }) {
    if (top != null) _defaultTop = top;
    if (bottom != null) _defaultBottom = bottom;
    if (left != null) _defaultLeft = left;
    if (right != null) _defaultRight = right;
    if (duration != null) _defaultDuration = duration;
    if (position != null) _defaultPosition = position;
  }

  /// 测试复位（destroyAll + 全局缺省回位）。
  static void resetForTest() {
    destroyAll();
    _defaultDuration = const Duration(seconds: 3);
    _defaultPosition = SemiNotificationPosition.topRight;
    _defaultTop = null;
    _defaultLeft = null;
    _defaultBottom = null;
    _defaultRight = null;
  }

  static String _newId() {
    // 上游 getUuid('notification')：`notification-${Date.now()}-${Math.random()}`。
    return 'notification-${DateTime.now().millisecondsSinceEpoch}'
        '-${_random.nextDouble()}';
  }

  static String _add(
    SemiNotificationType type, {
    BuildContext? context,
    String? id,
    Object? title,
    Object? content,
    Duration? duration,
    SemiNotificationPosition? position,
    SemiNotificationVariant? variant,
    Widget? icon,
    bool? showClose,
    bool? motion,
    VoidCallback? onClick,
    VoidCallback? onClose,
    void Function(String id)? onCloseClick,
    double? top,
    double? left,
    double? bottom,
    double? right,
    String? closeSemanticsLabel,
  }) {
    // addNotice：`notice = { ...defaultConfig, ...notice }` + 同 id 更新
    // （`ref.has(id) ? ref.update(id, notice) : ref.add(...)`——has 只看
    // 存活通知，leaving 同 id 复用即换新实例）。update 合并取 copyWith
    // 语义：显式传入覆盖、缺省保留（上游 JS 展开把 defaultConfig 键缺省
    // 回退默认值——怪癖不照抄，见 docs 差异清单）。
    final noticeId = id ?? _newId();
    final existing = _host?.find(noticeId) ?? _pending[noticeId];
    // 主题解析锚点（SemiModal 先例）：context 非空捕获调用点局部主题快照，
    // 缺省沿用原快照/随宿主 ambient。
    final themeData = context != null
        ? SemiNotificationTheme.of(context)
        : (existing?.themeData ?? const SemiNotificationThemeData());
    final entry = _NoticeEntry(
      id: noticeId,
      type: type,
      themeData: themeData,
      duration: duration ?? existing?.duration ?? _defaultDuration,
      position: position ?? existing?.position ?? _defaultPosition,
      // 上游 `appliedUpdates`：update() 触发一次 `restartCloseTimer`。
      updateSeq: (existing?.updateSeq ?? -1) + 1,
      removing: false,
      showClose: showClose ?? existing?.showClose ?? true,
      motion: motion ?? existing?.motion ?? true,
      title: title ?? existing?.title,
      content: content ?? existing?.content,
      variant: variant ?? existing?.variant,
      icon: icon ?? existing?.icon,
      onClose: onClose ?? existing?.onClose,
      onCloseClick: onCloseClick ?? existing?.onCloseClick,
      onClick: onClick ?? existing?.onClick,
      closeSemanticsLabel: closeSemanticsLabel ?? existing?.closeSemanticsLabel,
      top: top ?? existing?.top ?? _defaultTop,
      left: left ?? existing?.left ?? _defaultLeft,
      bottom: bottom ?? existing?.bottom ?? _defaultBottom,
      right: right ?? existing?.right ?? _defaultRight,
    );
    final host = _host;
    if (host != null) {
      host.upsert(entry);
    } else {
      _pending[noticeId] = entry;
      _install();
    }
    return noticeId;
  }

  static void _install() {
    if (_host != null || _installing) return;
    _installing = true;
    unawaited(() async {
      await SmartDialog.show<void>(
        tag: _tag,
        controller: SmartDialogController(),
        keepSingle: true,
        // 宿主铺满 Overlay 自排 placement——蒙层全透明 + 点穿；
        // `clickMaskDismiss` 恒 false（关闭权在通知自身/句柄）。
        clickMaskDismiss: false,
        usePenetrate: true,
        useAnimation: false,
        maskColor: const Color(0x00000000),
        alignment: Alignment.topRight,
        // 弹层不绑页面（上游 wrapper 挂 body 跨路由存活）。
        bindPage: false,
        builder: (_) => const _NotificationHost(),
      );
    }());
  }

  static void _attach(_NotificationHostState host) {
    _host = host;
    _installing = false;
    final pending = List<_NoticeEntry>.of(_pending.values);
    _pending.clear();
    // 上游 ref 回调：`this.pendingNotices.forEach(notice => instance.add(notice))`。
    for (final entry in pending) {
      host.upsert(entry);
    }
  }

  static void _detach(_NotificationHostState host) {
    if (identical(_host, host)) {
      _host = null;
      _installing = false;
    }
  }
}

/// 通知列表宿主（上游 `NotificationList` render——按 placement 分组、最新
/// 在前；`pointer-events: none` 列表点穿由空白区不吸中表达，卡片
/// `pointer-events: auto`）。
class _NotificationHost extends StatefulWidget {
  const _NotificationHost();

  @override
  State<_NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends State<_NotificationHost> {
  /// 存活 + leaving 通知（add 前插——上游 `[opts, ...notices]` 最新在前）。
  final List<_NoticeEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    SemiNotification._attach(this);
  }

  @override
  void dispose() {
    SemiNotification._detach(this);
    super.dispose();
  }

  /// 存活通知查找（上游 `has(id)` 不含 leaving——同 id 复用换新实例）。
  _NoticeEntry? find(String id) {
    for (final entry in _entries) {
      if (entry.id == id && !entry.removing) return entry;
    }
    return null;
  }

  void upsert(_NoticeEntry entry) {
    setState(() {
      final i = _entries.indexWhere((e) => e.id == entry.id && !e.removing);
      if (i >= 0) {
        _entries[i] = entry;
      } else {
        // 上游 adapter updateNotices 的 removedItems 过滤：同 id 复用时
        // leaving 实例即刻丢弃。
        _entries.removeWhere((e) => e.id == entry.id);
        _entries.insert(0, entry);
      }
    });
  }

  void remove(String id) {
    setState(() {
      final i = _entries.indexWhere((e) => e.id == id && !e.removing);
      if (i >= 0) _entries[i] = _entries[i].asRemoving();
    });
  }

  void _release(_NoticeEntry entry) {
    // releaseRemovedNotice：动画结束（或 motion: false 立即）移出列表。
    if (mounted) setState(() => _entries.remove(entry));
  }

  Widget _bucket(
    SemiNotificationPosition position,
    List<_NoticeEntry> entries,
    SemiResolvedNotificationThemeData t,
  ) {
    // `width: auto` shrink-to-fit：IntrinsicWidth 取最宽卡片 max-content、
    // 下限 `min-width: 320px`（0 高占位行入 intrinsic）；stretch 后同列卡片
    // 等宽（上游 block 填满 list 宽）。
    return Padding(
      // `$spacing-notification_list-padding`。
      padding: EdgeInsets.all(t.spacingNotificationListPadding),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('notice-min-width'),
              width: t.widthNotificationNoticeMinWidth,
              height: 0,
            ),
            for (final entry in entries)
              // ValueKey 使槽位状态（入场/退场动画、计时、释放）跟随通知
              // 本身而非列表位置——增删移位不再串状态（上游 key={notice.id}）。
              Padding(
                key: ValueKey(entry.id),
                // margin: $spacing-notification_notice-margin 四边——CSS
                // 相邻卡片纵向 margin 折叠（间距 = margin 非 2×margin）：
                // 纵向半值对拆 + 列首尾补半值，等价折叠结果。
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacingNotificationNoticeMargin,
                  vertical: t.spacingNotificationNoticeMargin / 2,
                ),
                child: SemiNotificationTheme(
                  data: entry.themeData,
                  child: _NoticeSlot(
                    entry: entry,
                    position: position,
                    onRemove: () => remove(entry.id),
                    onReleased: _release,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placed(
    SemiNotificationPosition position,
    List<_NoticeEntry> entries,
    SemiResolvedNotificationThemeData t,
  ) {
    // setPosInStyle：偏移取首条通知（config 注入的 top/left/bottom/right）。
    final o = entries.first;
    final bucket = Padding(
      // `$spacing-notification_list-margin`。
      padding: EdgeInsets.all(t.spacingNotificationListMargin),
      child: _bucket(position, entries, t),
    );
    return switch (position) {
      SemiNotificationPosition.topRight => Positioned(
        top: o.top ?? 0,
        right: o.right ?? 0,
        child: bucket,
      ),
      SemiNotificationPosition.topLeft => Positioned(
        top: o.top ?? 0,
        left: o.left ?? 0,
        child: bucket,
      ),
      SemiNotificationPosition.bottomRight => Positioned(
        bottom: o.bottom ?? 0,
        right: o.right ?? 0,
        child: bucket,
      ),
      SemiNotificationPosition.bottomLeft => Positioned(
        bottom: o.bottom ?? 0,
        left: o.left ?? 0,
        child: bucket,
      ),
      // `top: 0; left: 50%; transform: translateX(-50%)`——显式 left 偏移
      // 覆写锚点（FractionalTranslation = translateX(-50%)）。
      SemiNotificationPosition.top =>
        o.left != null
            ? Positioned(
                top: o.top ?? 0,
                left: o.left,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: bucket,
                ),
              )
            : Positioned(
                top: o.top ?? 0,
                left: 0,
                right: o.right ?? 0,
                child: Align(alignment: Alignment.topCenter, child: bucket),
              ),
      SemiNotificationPosition.bottom =>
        o.left != null
            ? Positioned(
                bottom: o.bottom ?? 0,
                left: o.left,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: bucket,
                ),
              )
            : Positioned(
                bottom: o.bottom ?? 0,
                left: 0,
                right: o.right ?? 0,
                child: Align(alignment: Alignment.bottomCenter, child: bucket),
              ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiNotificationTheme.resolve(context);
    final buckets = <SemiNotificationPosition, List<_NoticeEntry>>{};
    for (final entry in _entries) {
      // 上游 render 分组：`notice.position || (direction === 'rtl' ? 'topLeft'
      // : 'topRight')`——defaultConfig 恒填 position 后该兜底不可达（方向
      // 兜底随 direction 留档，分组直接取 entry.position）。
      buckets.putIfAbsent(entry.position, () => []).add(entry);
    }
    return SizedBox.expand(
      child: Stack(
        children: [
          for (final position in SemiNotificationPosition.values)
            if (buckets[position] case final entries?)
              _placed(position, entries, t),
        ],
      ),
    );
  }
}
