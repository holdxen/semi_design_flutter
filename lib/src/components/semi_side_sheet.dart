// SemiSideSheet — 上游 packages/semi-ui/sideSheet/{index.tsx,SideSheetContent.tsx}
// 与 packages/semi-foundation/sideSheet/{sideSheet.scss,variables.scss,
// animation.scss,rtl.scss,sideSheetFoundation.ts,constants.ts} 的移植；弹层底座
// 为 vendored flutter_smart_dialog 引擎（lib/src/overlay/dialog_engine，
// PROVENANCE.md）。
//
// 主题对账 **31 = 19 FIELDS + 12 MOTION + 0 INTERNAL**（variables.scss 19
// 声明 + animation.scss 12 声明；`$module: #{$prefix}-sidesheet` 类名胶水不计，
// modal `81 = 63 FIELDS + 18 MOTION + 0 INTERNAL` 先例）。★0 死变量
// （sideSheet.scss/rtl.scss 逐条消费）。quirks：无（两条 scss 声明冒号空格
// 规整）——theme provenance 逐字留档。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - sideSheet.scss `@include font-size-regular`（根字号 14）
// - sideSheet.scss `@include font-size-header-5`（标题 mixin 18——被显式
//   `font-size: $font-sideSheet_title-fontSize` 同值覆盖，token 注释引用）
// - sideSheet.scss title `text-align: left`（rtl.scss 翻 right——Directionality
//   镜像表达）
// - sideSheet.scss `.semi-sidesheet-fixed` inner `box-shadow: var(--semi-shadow-elevated)`
//   （fixed 模式投影——variables.scss 无对应声明，scss 硬编码）
// - sideSheet.scss keyframes `translateY(-100%)`（top）/ `translateY(100%)`
//   （bottom）/ `translateX(-100%)`（left）/ `translateX(100%)`（right）四向
//   滑入滑出（keyframe 起点值非 Sass 变量）
// - sideSheet.scss mask keyframes `opacity: 0` → 1（蒙层渐显）
// - constants.ts `HEIGHT: 448`（top/bottom 缺省高）
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';
import '../overlay/dialog_engine/flutter_smart_dialog.dart';
import '../theme/semi_side_sheet_theme.dart';
import '../theme/semi_side_sheet_theme_data.dart';
import '../theme/semi_theme.dart';
import '../tokens/token_types.dart';
import 'semi_button.dart';
import 'semi_inset_shadow.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';

/// 上游 `strings.PLACEMENT`（constants.ts）。
enum SemiSideSheetPlacement { top, right, bottom, left }

/// 上游 `strings.SIZE`（constants.ts）。
enum SemiSideSheetSize { small, medium, large }

/// 侧边栏（Semi SideSheet）。
///
/// 声明式 API：`visible` 驱动显隐（上游 `<SideSheet visible>` 语义：
/// [onCancel] 只通知，是否关闭由使用方改 `visible`）。标题/内容/自定义
/// footer、四向 [placement]（缺省 right）、三档 [size]（small 448 /
/// medium 684 / large 920，仅 left/right 生效）、[width]（仅 left/right）、
/// [height]（仅 top/bottom，缺省 `HEIGHT: 448`）、[mask]/[maskClosable]、
/// [closable]/[closeIcon]、[closeOnEsc]（缺省 false）、[motion]（180ms
/// 四向滑入滑出 + 蒙层渐显）、[afterVisibleChange]。
///
/// 弹层由 vendored 引擎承载（tag/遮罩/动画入库 `SmartDialog.show`），蒙层
/// 点击走 [onCancel]（上游 `maskClosable` 语义）。
class SemiSideSheet extends StatefulWidget {
  const SemiSideSheet({
    super.key,
    this.visible = false,
    this.title,
    this.content,
    this.footer,
    this.placement = SemiSideSheetPlacement.right,
    this.size = SemiSideSheetSize.small,
    this.width,
    this.height,
    this.mask = true,
    this.maskClosable = true,
    this.closable = true,
    this.closeIcon,
    this.closeOnEsc = false,
    this.motion = true,
    this.onCancel,
    this.afterVisibleChange,
  });

  /// 显隐（声明式）。
  final bool visible;

  /// 标题：String | Widget（null 时标题行只渲染关闭钮）。
  final Object? title;

  /// 内容：String | Widget（上游 `children`）。
  final Object? content;

  /// 自定义 footer（上游 `footer`，null 时不渲染 footer 行）。
  final Widget? footer;

  /// 滑出方向（缺省 right）。
  final SemiSideSheetPlacement placement;

  /// 宽度档（`$width-sideSheet_size-*`；仅 left/right 生效）。
  final SemiSideSheetSize size;

  /// 自定义宽度（仅 left/right 生效，覆盖 [size]）。
  final double? width;

  /// 自定义高度（仅 top/bottom 生效，缺省 `HEIGHT: 448`）。
  final double? height;

  /// 蒙层显隐（false → fixed 模式：投影 + 点击穿透）。
  final bool mask;

  /// 蒙层点击触发 [onCancel]（声明式不自关）。
  final bool maskClosable;

  /// 右上角关闭按钮（点击触发 [onCancel]）。
  final bool closable;

  /// 关闭按钮图标（缺省 IconClose）。
  final Widget? closeIcon;

  /// Esc 触发 [onCancel]（上游缺省 false）。
  final bool closeOnEsc;

  /// 弹层切换动效（180ms 四向滑入滑出 + 蒙层渐显，sideSheet.scss keyframes）。
  final bool motion;

  /// 关闭通知（关闭按钮/蒙层点击/Esc——声明式不自关）。
  final VoidCallback? onCancel;

  /// 动画完成回调（上游 `afterVisibleChange`：入场动画完成后 true、出场
  /// 完成后 false）。
  final void Function(bool isVisible)? afterVisibleChange;

  @override
  State<SemiSideSheet> createState() => _SemiSideSheetState();
}

class _SemiSideSheetState extends State<SemiSideSheet> {
  static int _seq = 0;
  late final String _tag = 'semi-side-sheet-${_seq++}';
  final SmartDialogController _controller = SmartDialogController();
  bool _open = false;

  /// 引擎 body 动画 controller（animationBuilder 回写——内容层 SlideTransition
  /// 按自身尺寸驱动 keyframes `translateX/Y(±100%)` → 0）。
  AnimationController? _bodyController;

  /// 上游 componentWillUnmount 不通知 afterVisibleChange——dispose 强关时
  /// 置 false，show Future 完成后据此判是否补发 `(false)`。
  bool _notifyClose = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initState 里不能 dependOnInheritedWidget（主题解析）——首同步放这里。
    _sync();
  }

  @override
  void didUpdateWidget(SemiSideSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
    if (_open) _controller.refresh();
  }

  void _sync() {
    // 引擎 show/dismiss 走 post-frame（build 相位 dismiss 会 markNeedsBuild
    // during build，触发生命周期竞态）。
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNow());
  }

  void _syncNow() {
    if (!mounted) return;
    if (widget.visible && !_open) {
      _open = true;
      _notifyClose = true;
      final t = SemiSideSheetTheme.resolve(context);
      unawaited(() async {
        await SmartDialog.show<void>(
          tag: _tag,
          controller: _controller,
          // 定位在内容层（Align 按 placement 就近刷新——引擎 alignment 入库
          // 定死，placement 热换需即时生效，上游 renderContent 换 class 语义）。
          alignment: Alignment.center,
          // 遮罩点击只走 onMask（上游 maskClosable → onCancel），关闭权在
          // 使用方——`clickMaskDismiss` 恒 false。mask: false → fixed 模式
          // 无蒙层（上游无 mask 节点）：`onMask` 不注册 + 点击穿透
          // （`usePenetrate`）。
          clickMaskDismiss: false,
          onMask: !widget.mask
              ? null
              : () {
                  if (widget.maskClosable) widget.onCancel?.call();
                },
          maskColor: widget.mask
              ? t.colorSideSheetMaskBg
              : const Color(0x00000000),
          usePenetrate: !widget.mask,
          useAnimation: widget.motion,
          animationTime: t.animationDurationSideSheetInnerShow,
          // 回写 body controller 后原样返回——滑移在内容层按盒子尺寸驱动
          // （SlideTransition 包裹内容盒而非全屏定位层）。show/hide 同一
          // upstream 曲线（`cubic-bezier(0.25, 0.46, 0.45, 0.94)`），drive/
          // chain 无监听器（CurvedAnimation 挂监听会在引擎 controller 销毁后
          // 触发 disposed 通知）。keyframes `translateY(-100%)`（top）/
          // `translateY(100%)`（bottom）/ `translateX(-100%)`（left）/
          // `translateX(100%)`（right）→ 0：show 正放 / hide 反放，四向滑入
          // 滑出；蒙层 keyframes `opacity: 0` → 1 由引擎主动画渐显（180ms
          // 同曲线，modal 蒙层独立简写先例的同值特例）。
          animationBuilder: (controller, child, param) {
            _bodyController = widget.motion ? controller : null;
            return child;
          },
          builder: (_) => _buildContent(),
        );
        // show Future 在关闭动画完成后返回——补发 `(false)`（上游
        // onAnimationEnd → notifyVisibleChange 语义）。
        _bodyController = null;
        if (_notifyClose) {
          _notifyClose = false;
          widget.afterVisibleChange?.call(false);
        }
      }());
      _notifyVisible(t);
    } else if (!widget.visible && _open) {
      _open = false;
      unawaited(SmartDialog.dismiss<void>(tag: _tag));
    }
  }

  /// 入场动画完成后通知 `(true)`（上游 onAnimationEnd → notifyVisibleChange）。
  void _notifyVisible(SemiResolvedSideSheetThemeData t) {
    if (!widget.motion) {
      widget.afterVisibleChange?.call(true);
      return;
    }
    unawaited(
      Future<void>.delayed(t.animationDurationSideSheetInnerShow, () {
        if (mounted && _open) widget.afterVisibleChange?.call(true);
      }),
    );
  }

  @override
  void dispose() {
    if (_open) {
      _open = false;
      _notifyClose = false;
      unawaited(SmartDialog.dismiss<void>(tag: _tag, force: true));
    }
    super.dispose();
  }

  Widget _buildContent() => _SideSheetContent(
    title: widget.title,
    content: widget.content,
    footer: widget.footer,
    placement: widget.placement,
    size: widget.size,
    width: widget.width,
    height: widget.height,
    mask: widget.mask,
    closable: widget.closable,
    closeIcon: widget.closeIcon,
    closeOnEsc: widget.closeOnEsc,
    slide: _bodyController,
    onClose: () => widget.onCancel?.call(),
  );

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 侧边栏内容盒（sideSheet.scss `.semi-sidesheet-inner` 族）。
class _SideSheetContent extends StatelessWidget {
  const _SideSheetContent({
    required this.title,
    required this.content,
    required this.footer,
    required this.placement,
    required this.size,
    required this.width,
    required this.height,
    required this.mask,
    required this.closable,
    required this.closeIcon,
    required this.closeOnEsc,
    required this.slide,
    required this.onClose,
  });

  final Object? title;
  final Object? content;
  final Widget? footer;
  final SemiSideSheetPlacement placement;
  final SemiSideSheetSize size;
  final double? width;
  final double? height;
  final bool mask;
  final bool closable;
  final Widget? closeIcon;
  final bool closeOnEsc;

  /// 引擎 body 动画（motion: true 时非空——四向滑移驱动源）。
  final AnimationController? slide;
  final VoidCallback onClose;

  static Widget _slot(Object? value) => switch (value) {
    null => const SizedBox.shrink(),
    final Widget w => w,
    _ => Text(value.toString()),
  };

  bool get _isVertical =>
      placement == SemiSideSheetPlacement.left ||
      placement == SemiSideSheetPlacement.right;

  /// 上游 mask/wrap 按 placement 锚定（sideSheet.scss `-left/-right/-top/
  /// -bottom`）——内容层 Align 表达（placement 热换即时生效）。
  Alignment get _alignment => switch (placement) {
    SemiSideSheetPlacement.top => Alignment.topCenter,
    SemiSideSheetPlacement.right => Alignment.centerRight,
    SemiSideSheetPlacement.bottom => Alignment.bottomCenter,
    SemiSideSheetPlacement.left => Alignment.centerLeft,
  };

  /// keyframe 起点（`translateX/Y(±100%)` → 0）——SlideTransition 按自身
  /// 尺寸换算（FractionalTranslation 语义）。
  Offset get _slideOffset => switch (placement) {
    SemiSideSheetPlacement.top => const Offset(0, -1),
    SemiSideSheetPlacement.right => const Offset(1, 0),
    SemiSideSheetPlacement.bottom => const Offset(0, 1),
    SemiSideSheetPlacement.left => const Offset(-1, 0),
  };

  double _sizeWidth(SemiResolvedSideSheetThemeData t) => switch (size) {
    SemiSideSheetSize.small => t.widthSideSheetSizeSmall,
    SemiSideSheetSize.medium => t.widthSideSheetSizeMedium,
    SemiSideSheetSize.large => t.widthSideSheetSizeLarge,
  };

  @override
  Widget build(BuildContext context) {
    final t = SemiSideSheetTheme.resolve(context);
    final screen = MediaQuery.sizeOf(context);
    // 上游 renderContent：left/right（isVertical）宽 = width ?? size 档、
    // 高 `100%`；top/bottom 宽 `100%`、高 = height ?? `HEIGHT: 448`。
    final sheetWidth = _isVertical ? (width ?? _sizeWidth(t)) : screen.width;
    final sheetHeight = _isVertical ? screen.height : (height ?? 448);

    final closer = SemiButton(
      null,
      icon: closeIcon ?? const SemiIcon(SemiIcons.close),
      type: SemiButtonType.tertiary,
      variant: SemiButtonVariant.borderless,
      size: SemiButtonSize.small,
      semanticsLabel: SemiLocalizations.of(context).close,
      onPressed: onClose,
    );

    // `@include font-size-regular`（sideSheet.scss 根字号 14）；标题行
    // `.semi-sidesheet-header`（`align-items: flex-start`）。
    final header = Container(
      padding: EdgeInsetsDirectional.only(
        top: t.spacingSideSheetHeaderPadding,
        bottom: t.spacingSideSheetHeaderPaddingBottom,
        start: t.spacingSideSheetHeaderPadding,
        end: t.spacingSideSheetHeaderPadding,
      ),
      // `border-bottom: $width-sideSheet_header-borderBottom solid
      // $color-sideSheet_header-borderBottom`（0px 占位边——token 消费）。
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: t.colorSideSheetHeaderBorderBottom,
            width: t.widthSideSheetHeaderBorderBottom,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              // `margin: $spacing-sideSheet_title-margin`（0）。
              padding: EdgeInsets.all(t.spacingSideSheetTitleMargin),
              // 上游 title div：`@include font-size-header-5`（mixin 18）被
              // 显式 `font-size: $font-sideSheet_title-fontSize`（同值 18）+
              // `font-weight: $font-sideSheet_title-fontWeight` 覆盖——token
              // 直接消费；`text-align: left`（rtl.scss 翻 right——
              // Directionality 镜像表达）。
              child: switch (title) {
                final Widget w => w,
                _ => Text(
                  title?.toString() ?? '',
                  style: TextStyle(
                    fontSize: t.fontSideSheetTitleFontSize,
                    fontWeight: t.fontSideSheetTitleFontWeight,
                    color: t.colorSideSheetMainText,
                  ),
                ),
              },
            ),
          ),
          if (closable) closer,
        ],
      ),
    );

    final body = Padding(
      // `.semi-sidesheet-body { padding: $spacing-sideSheet_body-paddingY
      // $spacing-sideSheet_body-paddingX }`。
      padding: EdgeInsets.symmetric(
        vertical: t.spacingSideSheetBodyPaddingY,
        horizontal: t.spacingSideSheetBodyPaddingX,
      ),
      child: _slot(content),
    );

    final footerArea = footer == null
        ? null
        : Padding(
            // `.semi-sidesheet-footer { padding: $spacing-sideSheet_footer-padding }`。
            padding: EdgeInsets.all(t.spacingSideSheetFooterPadding),
            child: footer,
          );

    final box = Container(
      key: const ValueKey('semi-side-sheet-box'),
      width: sheetWidth,
      height: sheetHeight,
      // `.semi-sidesheet-inner { background-color: $color-sideSheet-bg;
      // backdrop-filter: $filter-sideSheet-bg（none）; overflow: auto }`
      // ——overflow 由 body 滚动表达。
      decoration: BoxDecoration(
        color: t.colorSideSheetBg,
        // fixed 模式（mask: false）inner `box-shadow: var(--semi-shadow-elevated)`
        // ——mask 模式无投影（变量非 Sass 声明，另列硬编码）；inset 层走
        // SemiInsetShadow 画师（见差异清单）。
        boxShadow: mask
            ? null
            : SemiTheme.of(context).shadows.shadowElevated.toDropBoxShadows(),
      ),
      clipBehavior: Clip.antiAlias,
      child: SemiInsetShadow(
        shadows: mask
            ? SemiShadows(const [])
            : SemiTheme.of(context).shadows.shadowElevated,
        // `-inner` 无圆角。
        borderRadius: BorderRadius.zero,
        child: Column(
          // `.semi-sidesheet-content { height: 100%; flex-direction: column;
          // overflow: hidden }`。
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            // `.semi-sidesheet-body { flex: 1; overflow: auto }`。
            Expanded(child: SingleChildScrollView(child: body)),
            ?footerArea,
          ],
        ),
      ),
    );

    // keyframes 四向滑入滑出：`translateY(-100%)`（top）/ `translateY(100%)`
    // （bottom）/ `translateX(-100%)`（left）/ `translateX(100%)`（right）→ 0
    // ——SlideTransition 按内容盒自身尺寸换算（show 正放 / hide 反放，引擎
    // body controller 驱动）。
    Widget sheet = box;
    if (slide != null) {
      sheet = SlideTransition(
        position: slide!.drive(
          Tween<Offset>(
            begin: _slideOffset,
            end: Offset.zero,
          ).chain(CurveTween(curve: t.animationFunctionSideSheetInnerShow)),
        ),
        child: sheet,
      );
    }

    return Align(
      alignment: _alignment,
      child: Semantics(
        // 上游 `role="dialog"`（inner-wrap）。
        container: true,
        child: _SideSheetFocus(
          closeOnEsc: closeOnEsc,
          onClose: onClose,
          // `margin: $spacing-sideSheet-margin`（0——根外边距）。
          child: Padding(
            padding: EdgeInsets.all(t.spacingSideSheetMargin),
            child: sheet,
          ),
        ),
      ),
    );
  }
}

/// 对话框焦点槽（上游 inner-wrap `tabIndex={-1}` 聚焦语义）。
///
/// 入场抢焦不用 `Focus(autofocus: true)`：其走 `FocusScope.of(context)
/// .autofocus()`，`_Autofocus.applyIfValid` 要求 `scope.focusedChild == null`
/// ——弹层外路由的 ModalScope 已占焦时被丢弃（Esc 静默失效）。这里挂载后
/// 显式 `requestFocus()`（`_doRequestFocus` 无条件抢焦）。
class _SideSheetFocus extends StatefulWidget {
  const _SideSheetFocus({
    required this.closeOnEsc,
    required this.onClose,
    required this.child,
  });

  final bool closeOnEsc;
  final VoidCallback onClose;
  final Widget child;

  @override
  State<_SideSheetFocus> createState() => _SideSheetFocusState();
}

class _SideSheetFocusState extends State<_SideSheetFocus> {
  final FocusNode _node = FocusNode(debugLabel: 'SemiSideSheet');

  @override
  void initState() {
    super.initState();
    // 首帧后抢焦（build 相位不做焦点迁移）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _node.requestFocus();
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _node,
    autofocus: true,
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent &&
          widget.closeOnEsc &&
          event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: widget.child,
  );
}
