// SemiModal — 上游 packages/semi-ui/modal/{Modal.tsx,ModalContent.tsx,
// ConfirmModal.tsx,confirm.tsx,useModal} 与 packages/semi-foundation/modal/
// {modal.scss,variables.scss,animation.scss,rtl.scss,modalFoundation.ts,
// modalContentFoundation.ts} 的移植；弹层底座为 vendored flutter_smart_dialog
// 引擎（lib/src/overlay/dialog_engine，PROVENANCE.md）。
//
// 主题对账 **81 = 63 FIELDS + 18 MOTION + 0 INTERNAL**（variables.scss 63
// 声明 + animation.scss 18 声明；`$module: #{$prefix}-modal` 类名胶水不计，
// steps `104 = 94 + 10 + 0`、tabs `144 = 121 + 23 + 0` 先例）。★0 死变量。
// quirks：`$spacing-modal_footer-paddingY:0` 等冒号后无空格四条、
// `$animation_opacity-modal_content-open : 0` 冒号前空格、
// `$radius-modal_footer: 0 0 5px 5px;;` 双分号——theme provenance 逐字留档。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - modal.scss `@include font-size-regular`（根字号 14）
// - modal.scss `.semi-modal-centered { margin: auto }`（居中覆写）
// - modal.scss `align-items: flex-start` + auto margin 居中技巧
// - modal.scss wrap `overflow: auto`
// - variables.scss `$width-modal_full_width: calc(100vw - 64px)`
// - modal.scss `width: $width-icon-extra-large`（图标槽 24）
// - modal.scss footer `text-align: right`
// - modal.scss mask `z-index: $z-modal-mask`（引擎插入序表达）
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/dialog_engine/flutter_smart_dialog.dart';
import '../theme/semi_modal_theme.dart';
import '../theme/semi_modal_theme_data.dart';
import '../theme/semi_theme_data.dart';
import 'semi_button.dart';
import 'semi_inset_shadow.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'typography/semi_title.dart';

/// 上游 `strings.SIZE`（constants.ts）。
enum SemiModalSize { small, medium, large, fullWidth }

/// 上游 `ConfirmProps['type']`（confirm.tsx）。
enum SemiModalConfirmType { confirm, info, success, warning, error }

/// 命令式句柄（上游 `Modal.confirm()` 返回 `{ destroy, update }`）。
class SemiModalHandle {
  SemiModalHandle._(this._destroy, this._update);

  final VoidCallback _destroy;
  final void Function(_ModalConfig Function(_ModalConfig)) _update;

  /// 关闭（上游 `destroy` —— 走关闭动画后卸载）。
  void destroy() => _destroy();

  /// 就地更新配置（上游 `update`）。
  void update({
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool? closeOnEsc,
    bool? fullScreen,
  }) => _update(
    (c) => c.copyWith(
      title: title,
      content: content,
      icon: icon,
      okText: okText,
      cancelText: cancelText,
      okType: okType,
      hasCancel: hasCancel,
      onOk: onOk,
      onCancel: onCancel,
      width: width,
      height: height,
      size: size,
      centered: centered,
      maskClosable: maskClosable,
      closeOnEsc: closeOnEsc,
      fullScreen: fullScreen,
    ),
  );
}

/// 区域遮罩容器（上游 `getPopupContainer` 容器 + `position: relative` 的
/// Flutter 形态——DOM 回调在 Flutter 的等价物是就近 scope；modal.scss:210-216
/// `.semi-modal-popup`：mask/wrap 由 `position: fixed` 切 `absolute`，只铺
/// 容器 + `overflow: hidden`）。
///
/// [SemiModal] 位于本容器内（命令式族传入本区域内的 `context`）时只遮罩本
/// 区域；`maskFixed: true` 仍走全窗（modal.scss:218-222 `.semi-modal-fixed`）。
/// 区域内不锁页面滚动（上游 body overflow 锁只在挂 body 时生效，Modal.tsx:
/// 141-151）；区域内 tooltip 等其他弹层不受影响（专用 scope 不劫持 ambient
/// Overlay 路由）。容器需有界（同上游 `position: relative` 容器需有尺寸）。
class SemiModalRegion extends StatefulWidget {
  const SemiModalRegion({super.key, required this.child});

  final Widget child;

  /// 最近的区域容器 state（无则 null——弹层路由判据）。
  static _SemiModalRegionState? _maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_SemiModalRegionState>();

  @override
  State<SemiModalRegion> createState() => _SemiModalRegionState();
}

class _SemiModalRegionState extends State<SemiModalRegion> {
  final List<Widget> _layers = <Widget>[];

  void _insert(Widget layer) {
    setState(() => _layers.add(layer));
  }

  void _remove(Widget layer) {
    if (!mounted) return;
    setState(() => _layers.remove(layer));
  }

  @override
  Widget build(BuildContext context) {
    // `overflow: hidden`（modal.scss:214 popup 模式 wrap/mask）——弹层不越界。
    return ClipRect(
      child: Stack(
        children: <Widget>[
          widget.child,
          for (final layer in _layers) Positioned.fill(child: layer),
        ],
      ),
    );
  }
}

/// 上游 `header={null}` / `footer={null}` 的「显式空槽」哨兵（JS props 键存在
/// 即覆盖缺省渲染——Dart `Widget?` 无法区分「未传」与「显式 null」，以此表达）。
/// header 槽：无标题行、body 走直通分支（不进 body-wrapper、无 closer——上游
/// renderBody `hasHeader` quirk）；footer 槽：无 footer 节点（无
/// `semi-modal-footer` 边距包裹）。
class SemiModalEmptySlot extends StatelessWidget {
  const SemiModalEmptySlot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 对话框（Semi Modal）。
///
/// 两态 API：
/// * 声明式——`visible` 驱动显隐（上游 `<Modal visible>` 语义：onOk/onCancel
///   只通知，是否关闭由使用方改 `visible`；回调返回 `Future` 时按钮自动
///   loading 至完成）；
/// * 命令式——[SemiModal.confirm]/[info]/[success]/[warning]/[error]
///   （上游 `Modal.confirm()` 一族：内部管理显隐，onOk/onCancel 返回
///   `Future` 时按钮 loading、完成后自动关闭，返回 [SemiModalHandle]）。
///
/// 弹层由 vendored 引擎承载（tag/队列/遮罩/动画）；蒙层点击与 Esc 走
/// [onCancel]（上游 `maskClosable`/`closeOnEsc` 语义）。
class SemiModal extends StatefulWidget {
  const SemiModal({
    super.key,
    this.visible = false,
    this.title,
    this.content,
    this.icon,
    this.header,
    this.footer,
    this.contentPadding,
    this.width,
    this.height,
    this.size = SemiModalSize.small,
    this.centered = false,
    this.mask = true,
    this.maskClosable = true,
    this.maskFixed = false,
    this.closable = true,
    this.closeIcon,
    this.closeOnEsc = true,
    this.hasCancel = true,
    this.okText,
    this.okType = SemiButtonType.primary,
    this.cancelText,
    this.confirmLoading,
    this.cancelLoading,
    this.onOk,
    this.onCancel,
    this.afterClose,
    this.motion = true,
    this.fullScreen = false,
    this.footerFill = false,
    this.modalRender,
  });

  /// 显隐（声明式）。
  final bool visible;

  /// 标题：String | Widget（null 且无 [header] 时不渲染 header）。
  final Object? title;

  /// 内容：String | Widget（上游 `children`/`content`）。
  final Object? content;

  /// 标题前图标（有 [header] 时无效）。
  final Widget? icon;

  /// 自定义 header（整体替换标题行）。
  final Widget? header;

  /// 自定义 footer（整体替换按钮行）。
  final Widget? footer;

  /// 内容盒 padding（缺省 modal.scss `-content` 的
  /// `$spacing-modal_content-paddingY/X` 0/24；UserGuide 的
  /// `.#{$prefix}-modal-content { padding: 0 }` 覆写落点）。
  final EdgeInsets? contentPadding;

  final double? width;
  final double? height;

  /// 上游 `size`（`small` 448 / `medium` 684 / `large` 920 / `full-width`
  /// = `calc(100vw - 64px)`，视口 - 64）。
  final SemiModalSize size;

  /// 垂直居中（`.semi-modal-centered { margin: auto }`）。
  final bool centered;

  /// 蒙层显隐。
  final bool mask;

  /// 蒙层点击触发 [onCancel]（声明式不自关；命令式关闭）。
  final bool maskClosable;

  /// 区域内仍走全窗遮罩（上游 `maskFixed`，modal.scss:218-222
  /// `.semi-modal-fixed`）——[SemiModalRegion] 内默认只遮区域。
  final bool maskFixed;

  /// 右上角关闭按钮（点击触发 [onCancel]）。
  final bool closable;
  final Widget? closeIcon;

  /// Esc 触发 [onCancel]。
  final bool closeOnEsc;

  /// 是否渲染取消按钮。
  final bool hasCancel;

  /// 确定按钮文案（缺省 locale「确定」）。
  final String? okText;

  /// 确定按钮类型（上游 `okType`，`error` 变体缺省 `danger`）。
  final SemiButtonType okType;

  /// 取消按钮文案（缺省 locale「取消」）。
  final String? cancelText;

  /// 确定/取消 loading（null 时按钮 loading 跟随回调返回的 `Future`）。
  final bool? confirmLoading;
  final bool? cancelLoading;

  final FutureOr<void> Function()? onOk;
  final FutureOr<void> Function()? onCancel;

  /// 关闭动画结束后回调（上游 `afterClose`）。
  final VoidCallback? afterClose;

  /// 弹层切换动效（120ms scale 0.7→1 + fade，modal.scss keyframes）。
  final bool motion;

  /// 全屏（radius 0、无描边、铺满）。
  final bool fullScreen;

  /// footer 按钮通栏（`footerFill`，按钮 `block`）。
  final bool footerFill;

  /// 对话框节点包装（上游 `modalRender`）。
  final Widget Function(Widget)? modalRender;

  // -- 命令式（confirm.tsx with* 一族） ------------------------------------

  /// `Modal.confirm`（图标 help-circle，primary 色）。
  static SemiModalHandle confirm({
    BuildContext? context,
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool maskFixed = false,
    bool? closeOnEsc,
    bool fullScreen = false,
    VoidCallback? afterClose,
    bool motion = true,
    bool footerFill = false,
  }) => _showConfirm(
    SemiModalConfirmType.confirm,
    context,
    title: title,
    content: content,
    icon: icon,
    okText: okText,
    cancelText: cancelText,
    okType: okType,
    hasCancel: hasCancel,
    onOk: onOk,
    onCancel: onCancel,
    width: width,
    height: height,
    size: size,
    centered: centered,
    maskClosable: maskClosable,
    maskFixed: maskFixed,
    closeOnEsc: closeOnEsc,
    fullScreen: fullScreen,
    afterClose: afterClose,
    motion: motion,
    footerFill: footerFill,
  );

  /// `Modal.info`（图标 info-circle，info 色）。
  static SemiModalHandle info({
    BuildContext? context,
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool maskFixed = false,
    bool? closeOnEsc,
    bool fullScreen = false,
    VoidCallback? afterClose,
    bool motion = true,
    bool footerFill = false,
  }) => _showConfirm(
    SemiModalConfirmType.info,
    context,
    title: title,
    content: content,
    icon: icon,
    okText: okText,
    cancelText: cancelText,
    okType: okType,
    hasCancel: hasCancel,
    onOk: onOk,
    onCancel: onCancel,
    width: width,
    height: height,
    size: size,
    centered: centered,
    maskClosable: maskClosable,
    maskFixed: maskFixed,
    closeOnEsc: closeOnEsc,
    fullScreen: fullScreen,
    afterClose: afterClose,
    motion: motion,
    footerFill: footerFill,
  );

  /// `Modal.success`（图标 tick-circle，success 色）。
  static SemiModalHandle success({
    BuildContext? context,
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool maskFixed = false,
    bool? closeOnEsc,
    bool fullScreen = false,
    VoidCallback? afterClose,
    bool motion = true,
    bool footerFill = false,
  }) => _showConfirm(
    SemiModalConfirmType.success,
    context,
    title: title,
    content: content,
    icon: icon,
    okText: okText,
    cancelText: cancelText,
    okType: okType,
    hasCancel: hasCancel,
    onOk: onOk,
    onCancel: onCancel,
    width: width,
    height: height,
    size: size,
    centered: centered,
    maskClosable: maskClosable,
    maskFixed: maskFixed,
    closeOnEsc: closeOnEsc,
    fullScreen: fullScreen,
    afterClose: afterClose,
    motion: motion,
    footerFill: footerFill,
  );

  /// `Modal.warning`（图标 alert-triangle，warning 色）。
  static SemiModalHandle warning({
    BuildContext? context,
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool maskFixed = false,
    bool? closeOnEsc,
    bool fullScreen = false,
    VoidCallback? afterClose,
    bool motion = true,
    bool footerFill = false,
  }) => _showConfirm(
    SemiModalConfirmType.warning,
    context,
    title: title,
    content: content,
    icon: icon,
    okText: okText,
    cancelText: cancelText,
    okType: okType,
    hasCancel: hasCancel,
    onOk: onOk,
    onCancel: onCancel,
    width: width,
    height: height,
    size: size,
    centered: centered,
    maskClosable: maskClosable,
    maskFixed: maskFixed,
    closeOnEsc: closeOnEsc,
    fullScreen: fullScreen,
    afterClose: afterClose,
    motion: motion,
    footerFill: footerFill,
  );

  /// `Modal.error`（图标 alert-circle，danger 色；`okType` 缺省 `danger`）。
  static SemiModalHandle error({
    BuildContext? context,
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool maskFixed = false,
    bool? closeOnEsc,
    bool fullScreen = false,
    VoidCallback? afterClose,
    bool motion = true,
    bool footerFill = false,
  }) => _showConfirm(
    SemiModalConfirmType.error,
    context,
    title: title,
    content: content,
    icon: icon,
    okText: okText,
    cancelText: cancelText,
    okType: okType ?? SemiButtonType.danger,
    hasCancel: hasCancel,
    onOk: onOk,
    onCancel: onCancel,
    width: width,
    height: height,
    size: size,
    centered: centered,
    maskClosable: maskClosable,
    maskFixed: maskFixed,
    closeOnEsc: closeOnEsc,
    fullScreen: fullScreen,
    afterClose: afterClose,
    motion: motion,
    footerFill: footerFill,
  );

  static int _seq = 0;

  static SemiModalHandle _showConfirm(
    SemiModalConfirmType type,
    BuildContext? context, {
    Object? title,
    Object? content,
    Widget? icon,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool maskFixed = false,
    bool? closeOnEsc,
    bool fullScreen = false,
    VoidCallback? afterClose,
    required bool motion,
    required bool footerFill,
  }) {
    final tag = 'semi-modal-confirm-${_seq++}';
    final controller = SmartDialogController();
    // host ← → state 循环引用：闭包延迟解引用（事件/帧回调才会触发）。
    late final _ConfirmState state;
    final host = SemiModal._installEntry(
      tag: tag,
      controller: controller,
      // 上游 `getPopupContainer` 非 body → 区域层（maskFixed 强制全窗）。
      region: maskFixed
          ? null
          : (context == null ? null : SemiModalRegion._maybeOf(context)),
      theme: _resolveTheme(context),
      centered: centered ?? false,
      mask: true,
      motion: motion,
      afterClose: afterClose,
      onMask: () => state.handleMask(),
      builder: () => state.build(),
    );
    state = _ConfirmState(
      type: type,
      host: host,
      config: _ModalConfig(
        title: title,
        content: content,
        icon: icon,
        okText: okText,
        cancelText: cancelText,
        okType: okType,
        hasCancel: hasCancel,
        onOk: onOk,
        onCancel: onCancel,
        width: width,
        height: height,
        size: size,
        centered: centered,
        maskClosable: maskClosable,
        closeOnEsc: closeOnEsc,
        fullScreen: fullScreen,
        motion: motion,
        footerFill: footerFill,
      ),
    );
    return SemiModalHandle._(state.destroy, state.update);
  }

  /// 主题解析锚点：命令式 API 可选带 context；缺省亮色 token
  /// （`SemiThemeData.light()` resolve）。
  static SemiResolvedModalThemeData _resolveTheme(BuildContext? context) {
    if (context != null) return SemiModalTheme.resolve(context);
    return const SemiModalThemeData().resolve(const SemiThemeData.light());
  }

  /// 弹层入库（统一入口）：`region` 非空走区域层（只遮 [SemiModalRegion]——
  /// 上游 `getPopupContainer` 非 body 路径），否则引擎全窗。返回承载句柄
  /// （refresh/dismiss）。引擎路动画用 `animationBuilder` 精确消费
  /// `animation_transform_scale-modal_content-open: 0.7` +
  /// `animation_opacity-modal_content-open : 0`（★冒号前空格 quirk）+
  /// 120ms `cubic-bezier(0.215, 0.61, 0.355, 1)`（show 正放 / hide 反放）。
  static _ModalHost _installEntry({
    required String tag,
    required SmartDialogController controller,
    required _SemiModalRegionState? region,
    required SemiResolvedModalThemeData theme,
    required bool centered,
    required bool mask,
    required bool motion,
    required VoidCallback? afterClose,
    required VoidCallback onMask,
    required Widget Function() builder,
  }) {
    final t = theme;
    if (region == null) {
      unawaited(() async {
        await SmartDialog.show<void>(
          tag: tag,
          controller: controller,
          // 遮罩点击只走 onMask（上游 maskClosable → onCancel），关闭权在
          // 调用方/句柄——`clickMaskDismiss` 恒 false。mask: false → 透明蒙层。
          clickMaskDismiss: false,
          onMask: onMask,
          maskColor: mask ? t.colorModalMaskBg : const Color(0x00000000),
          // `margin: auto` / `align-items: flex-start` 居中语义由 alignment
          // 表达；非 centered 距顶 marginY 80（spacingModalMarginY 在内容盒
          // 上消费）。
          alignment: centered ? Alignment.center : Alignment.topCenter,
          useAnimation: motion,
          animationTime: t.animationDurationModalShow,
          // show/hide 同一 upstream 曲线（`cubic-bezier(0.215, 0.61, 0.355,
          // 1)`），drive/chain 无监听器（CurvedAnimation 挂监听会在引擎
          // controller 销毁后触发 disposed 通知）。
          animationBuilder: motion
              ? (controller, child, param) {
                  final curve = t.animationFunctionModalShow;
                  return ScaleTransition(
                    scale: controller.drive(
                      Tween<double>(
                        begin: t.animationTransformScaleModalContentOpen.scaleX,
                        end: 1,
                      ).chain(CurveTween(curve: curve)),
                    ),
                    child: FadeTransition(
                      opacity: controller.drive(
                        Tween<double>(
                          begin: t.animationOpacityModalContentOpen,
                          end: 1,
                        ).chain(CurveTween(curve: curve)),
                      ),
                      child: child,
                    ),
                  );
                }
              : null,
          builder: (_) => builder(),
        );
        afterClose?.call();
      }());
      return _EngineHost(tag, controller);
    }
    final key = GlobalKey<_RegionModalLayerState>();
    late final _RegionModalLayer layer;
    layer = _RegionModalLayer(
      key: key,
      theme: t,
      centered: centered,
      mask: mask,
      motion: motion,
      onMask: onMask,
      builder: builder,
    );
    region._insert(layer);
    return _RegionHost(region, layer, key, afterClose);
  }

  @override
  State<SemiModal> createState() => _SemiModalState();
}

/// 弹层承载句柄（全窗引擎 vs 区域层——上游 `getPopupContainer` 双路径）。
abstract class _ModalHost {
  /// 就地刷新内容（update/按钮 loading 态）。
  void refresh();

  /// 关闭（[force] 跳过关闭动画——dispose 语义）。
  Future<void> dismiss({bool force = false});
}

class _EngineHost implements _ModalHost {
  _EngineHost(this._tag, this._controller);

  final String _tag;
  final SmartDialogController _controller;

  @override
  void refresh() => _controller.refresh();

  @override
  Future<void> dismiss({bool force = false}) =>
      SmartDialog.dismiss<void>(tag: _tag, force: force);
}

class _RegionHost implements _ModalHost {
  _RegionHost(this._region, this._layer, this._key, this._afterClose);

  final _SemiModalRegionState _region;
  final _RegionModalLayer _layer;
  final GlobalKey<_RegionModalLayerState> _key;
  final VoidCallback? _afterClose;
  bool _closed = false;

  @override
  void refresh() => _key.currentState?._markNeedsContent();

  @override
  Future<void> dismiss({bool force = false}) async {
    if (_closed) return;
    _closed = true;
    if (!force) {
      // 关闭动画后卸层（层在中途被卸载时落空即出）。
      try {
        await _key.currentState?._animateOut();
      } catch (_) {}
    }
    _region._remove(_layer);
    _afterClose?.call();
  }
}

/// 区域层（modal.scss:210-216 `.semi-modal-popup`：mask/内容只铺容器 + 独立
/// 120ms scale 0.7→1 + fade——同引擎路 animationBuilder）。
class _RegionModalLayer extends StatefulWidget {
  const _RegionModalLayer({
    super.key,
    required this.theme,
    required this.centered,
    required this.mask,
    required this.motion,
    required this.onMask,
    required this.builder,
  });

  final SemiResolvedModalThemeData theme;
  final bool centered;
  final bool mask;
  final bool motion;
  final VoidCallback onMask;
  final Widget Function() builder;

  @override
  State<_RegionModalLayer> createState() => _RegionModalLayerState();
}

class _RegionModalLayerState extends State<_RegionModalLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.theme.animationDurationModalShow,
  );

  @override
  void initState() {
    super.initState();
    if (widget.motion) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markNeedsContent() {
    if (mounted) setState(() {});
  }

  Future<void> _animateOut() async {
    if (!widget.motion || !mounted) return;
    try {
      await _controller.reverse().orCancel;
    } catch (_) {
      // TickerCanceled——反放中途被卸载。
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final curve = t.animationFunctionModalShow;
    Widget content = widget.builder();
    if (widget.motion) {
      content = ScaleTransition(
        scale: _controller.drive(
          Tween<double>(
            begin: t.animationTransformScaleModalContentOpen.scaleX,
            end: 1,
          ).chain(CurveTween(curve: curve)),
        ),
        child: FadeTransition(
          opacity: _controller.drive(
            Tween<double>(
              begin: t.animationOpacityModalContentOpen,
              end: 1,
            ).chain(CurveTween(curve: curve)),
          ),
          child: content,
        ),
      );
    }
    return Stack(
      children: [
        // 蒙层（mask: false → 透明仍占位接点击，同引擎 `clickMaskDismiss: false`
        // 的 onMask 语义）。
        Positioned.fill(
          child: GestureDetector(
            key: const ValueKey('semi-modal-region-mask'),
            behavior: HitTestBehavior.opaque,
            onTap: widget.onMask,
            child: ColoredBox(
              color: widget.mask ? t.colorModalMaskBg : const Color(0x00000000),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: widget.centered ? Alignment.center : Alignment.topCenter,
            child: content,
          ),
        ),
      ],
    );
  }
}

class _SemiModalState extends State<SemiModal> {
  static int _seq = 0;
  late final String _tag = 'semi-modal-${_seq++}';
  final SmartDialogController _controller = SmartDialogController();
  _ModalHost? _host;
  bool _open = false;
  bool _okPending = false;
  bool _cancelPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initState 里不能 dependOnInheritedWidget（主题解析）——首同步放这里。
    _sync();
  }

  @override
  void didUpdateWidget(SemiModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
    if (_open) _host?.refresh();
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
      _host = SemiModal._installEntry(
        tag: _tag,
        controller: _controller,
        // 上游 `getPopupContainer` 非 body → 区域层（maskFixed 强制全窗）。
        region: widget.maskFixed ? null : SemiModalRegion._maybeOf(context),
        theme: SemiModalTheme.resolve(context),
        centered: widget.centered,
        mask: widget.mask,
        motion: widget.motion,
        afterClose: widget.afterClose,
        onMask: () {
          if (widget.maskClosable) _notify(widget.onCancel, ok: false);
        },
        builder: _buildContent,
      );
    } else if (!widget.visible && _open) {
      _open = false;
      unawaited(_host?.dismiss());
      _host = null;
    }
  }

  /// 声明式：只通知（上游 handleOk/handleCancel + promise 时按钮 loading），
  /// 关闭权在使用方（改 `visible`）。
  Future<void> _notify(
    FutureOr<void> Function()? callback, {
    required bool ok,
  }) async {
    final result = callback?.call();
    if (result is Future<void>) {
      setState(() => ok ? _okPending = true : _cancelPending = true);
      _host?.refresh();
      try {
        await result;
      } catch (_) {}
      if (!mounted) return;
      setState(() => ok ? _okPending = false : _cancelPending = false);
      _host?.refresh();
    }
  }

  @override
  void dispose() {
    if (_open) {
      _open = false;
      unawaited(_host?.dismiss(force: true));
      _host = null;
    }
    super.dispose();
  }

  Widget _buildContent() {
    final content = _ModalContent(
      config: _ModalConfig.fromWidget(widget),
      onClose: () {
        if (widget.closable) _notify(widget.onCancel, ok: false);
      },
      onOk: widget.onOk == null ? null : () => _notify(widget.onOk, ok: true),
      onCancel: () => _notify(widget.onCancel, ok: false),
      confirmLoading: widget.confirmLoading ?? _okPending,
      cancelLoading: widget.cancelLoading ?? _cancelPending,
    );
    final wrapped = widget.modalRender?.call(content) ?? content;
    return wrapped;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 命令式 confirm 族的内部状态（ConfirmModal.tsx 的可见性/loading 语义）。
class _ConfirmState {
  _ConfirmState({required this.type, required this.host, required this.config});

  final SemiModalConfirmType type;
  final _ModalHost host;
  _ModalConfig config;
  bool confirmPending = false;
  bool cancelPending = false;

  void handleMask() {
    if (config.maskClosable ?? true) unawaited(handleCancel());
  }

  void destroy() {
    unawaited(host.dismiss());
  }

  void update(_ModalConfig Function(_ModalConfig) merge) {
    config = merge(config);
    host.refresh();
  }

  Future<void> handleOk() async {
    final result = config.onOk?.call();
    if (result is Future<void>) {
      confirmPending = true;
      host.refresh();
      try {
        await result;
      } catch (_) {
        confirmPending = false;
        host.refresh();
        return;
      }
      confirmPending = false;
    }
    await host.dismiss();
  }

  Future<void> handleCancel() async {
    final result = config.onCancel?.call();
    if (result is Future<void>) {
      cancelPending = true;
      host.refresh();
      try {
        await result;
      } catch (_) {
        cancelPending = false;
        host.refresh();
        return;
      }
      cancelPending = false;
    }
    await host.dismiss();
  }

  Widget build() => _ModalContent(
    config: config,
    type: type,
    onClose: handleCancel,
    onOk: handleOk,
    onCancel: handleCancel,
    confirmLoading: confirmPending,
    cancelLoading: cancelPending,
  );
}

/// 声明式/命令式共享的配置快照（上游 ModalReactProps 子集）。
class _ModalConfig {
  const _ModalConfig({
    this.title,
    this.content,
    this.icon,
    this.header,
    this.footer,
    this.contentPadding,
    this.okText,
    this.cancelText,
    this.okType,
    this.hasCancel,
    this.onOk,
    this.onCancel,
    this.width,
    this.height,
    this.size,
    this.centered,
    this.maskClosable,
    this.closeOnEsc,
    this.fullScreen = false,
    this.motion = true,
    this.footerFill = false,
  });

  factory _ModalConfig.fromWidget(SemiModal w) => _ModalConfig(
    title: w.title,
    content: w.content,
    icon: w.icon,
    header: w.header,
    footer: w.footer,
    contentPadding: w.contentPadding,
    okText: w.okText,
    cancelText: w.cancelText,
    okType: w.okType,
    hasCancel: w.hasCancel,
    onOk: w.onOk,
    onCancel: w.onCancel,
    width: w.width,
    height: w.height,
    size: w.size,
    centered: w.centered,
    maskClosable: w.maskClosable,
    closeOnEsc: w.closeOnEsc,
    fullScreen: w.fullScreen,
    motion: w.motion,
    footerFill: w.footerFill,
  );

  final Object? title;
  final Object? content;
  final Widget? icon;
  final Widget? header;
  final Widget? footer;
  final EdgeInsets? contentPadding;
  final String? okText;
  final String? cancelText;
  final SemiButtonType? okType;
  final bool? hasCancel;
  final FutureOr<void> Function()? onOk;
  final FutureOr<void> Function()? onCancel;
  final double? width;
  final double? height;
  final SemiModalSize? size;
  final bool? centered;
  final bool? maskClosable;
  final bool? closeOnEsc;
  final bool fullScreen;
  final bool motion;
  final bool footerFill;

  _ModalConfig copyWith({
    Object? title,
    Object? content,
    Widget? icon,
    Widget? header,
    Widget? footer,
    EdgeInsets? contentPadding,
    String? okText,
    String? cancelText,
    SemiButtonType? okType,
    bool? hasCancel,
    FutureOr<void> Function()? onOk,
    FutureOr<void> Function()? onCancel,
    double? width,
    double? height,
    SemiModalSize? size,
    bool? centered,
    bool? maskClosable,
    bool? closeOnEsc,
    bool? fullScreen,
  }) => _ModalConfig(
    title: title ?? this.title,
    content: content ?? this.content,
    icon: icon ?? this.icon,
    header: header ?? this.header,
    footer: footer ?? this.footer,
    contentPadding: contentPadding ?? this.contentPadding,
    okText: okText ?? this.okText,
    cancelText: cancelText ?? this.cancelText,
    okType: okType ?? this.okType,
    hasCancel: hasCancel ?? this.hasCancel,
    onOk: onOk ?? this.onOk,
    onCancel: onCancel ?? this.onCancel,
    width: width ?? this.width,
    height: height ?? this.height,
    size: size ?? this.size,
    centered: centered ?? this.centered,
    maskClosable: maskClosable ?? this.maskClosable,
    closeOnEsc: closeOnEsc ?? this.closeOnEsc,
    fullScreen: fullScreen ?? this.fullScreen,
    motion: motion,
    footerFill: footerFill,
  );
}

/// 对话框内容盒（modal.scss `.semi-modal-content` 及其 header/body/footer）。
class _ModalContent extends StatelessWidget {
  const _ModalContent({
    required this.config,
    required this.onClose,
    required this.onOk,
    required this.onCancel,
    this.type,
    required this.confirmLoading,
    required this.cancelLoading,
  });

  final _ModalConfig config;
  final VoidCallback onClose;
  final FutureOr<void> Function()? onOk;
  final FutureOr<void> Function()? onCancel;
  final SemiModalConfirmType? type;
  final bool confirmLoading;
  final bool cancelLoading;

  static bool _isBodyWrapper(_ModalConfig config, Widget? header) =>
      config.header == null && header == null;

  static Widget _slot(Object? value) => switch (value) {
    null => const SizedBox.shrink(),
    final Widget w => w,
    _ => Text(value.toString()),
  };

  @override
  Widget build(BuildContext context) {
    final t = SemiModalTheme.resolve(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final isConfirm = type != null;
    // `@include font-size-regular`（modal.scss 根字号 14）；标题实际走
    // Typography.Title heading 5（font-modal_header-* 被 Title 类覆盖——
    // CSS specificity quirk 照抄，两 token 注释引用）。
    final icon = config.icon;
    final iconSlot = icon == null
        ? null
        : SizedBox(
            // `width: $width-icon-extra-large`（图标槽 24）。
            width: 24,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: isConfirm
                    ? t.spacingModalConfirmIconWrapperMarginRight
                    : t.spacingModalIconWrapperMarginRight,
              ),
              child: icon,
            ),
          );
    final closer = SemiButton(
      null,
      icon: const SemiIcon(SemiIcons.close),
      type: SemiButtonType.tertiary,
      variant: SemiButtonVariant.borderless,
      size: SemiButtonSize.small,
      semanticsLabel: '关闭',
      onPressed: onClose,
    );

    final hasHeader = config.title != null || isConfirm;
    final Widget? header = hasHeader
        ? Container(
            // `margin: $spacing-modal_header-marginY`（confirm 走
            // `$spacing-modal_confirm_header-marginBottom`）。
            margin: EdgeInsetsDirectional.only(
              top: t.spacingModalHeaderMarginY,
              bottom: isConfirm
                  // confirm 仅覆写 `margin-bottom`（顶部 24 保持）。
                  ? t.spacingModalConfirmHeaderMarginBottom
                  : t.spacingModalHeaderMarginY,
              start: t.spacingModalHeaderMarginX,
              end: t.spacingModalHeaderMarginX,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?iconSlot,
                Expanded(
                  // 上游 `Typography.Title heading 5`（String 走 SemiTitle；
                  // Widget 原样）。
                  child: switch (config.title) {
                    final Widget w => w,
                    _ => SemiTitle(config.title?.toString() ?? '', heading: 5),
                  },
                ),
                closer,
              ],
            ),
          )
        : null;

    final body = Padding(
      // `.semi-modal-withIcon { margin-left: 36px }`。
      padding: EdgeInsetsDirectional.only(
        start: icon != null ? t.spacingModalContentWithiconMarginLeft : 0,
      ),
      child: _slot(config.content),
    );
    final footer = _buildFooter(t, rtl);
    // 自定义 header 整体替换标题行（上游 `'header' in props` 分支）；
    // [SemiModalEmptySlot] = `header={null}` 显式空（无 header 行、body 直通、
    // 无 closer——上游 renderBody `hasHeader` quirk）。
    final Widget? headerArea = switch (config.header) {
      SemiModalEmptySlot() => null,
      final Widget customHeader => Padding(
        padding: EdgeInsetsDirectional.only(
          top: t.spacingModalHeaderMarginY,
          bottom: t.spacingModalHeaderMarginY,
        ),
        child: customHeader,
      ),
      _ => header,
    };

    final box = Container(
      key: const ValueKey('semi-modal-box'),
      // 上游 `isFullScreen` 最后覆写 `width/height: 100%`（优先于 width/
      // height props）——铺满视口。
      width: config.fullScreen
          ? MediaQuery.sizeOf(context).width
          : (config.width ?? _sizeWidth(t, context)),
      height: config.fullScreen
          ? MediaQuery.sizeOf(context).height
          : config.height,
      decoration: BoxDecoration(
        color: t.colorModalBg,
        // `-content-fullScreen { border: none }`（占位的 1px 透明边也会
        // 把内容挤偏 1px——全屏直接不描边）。
        border: config.fullScreen
            ? null
            : Border.all(
                color: t.colorModalContentBorder,
                width: t.widthModalContentBorder,
              ),
        borderRadius: BorderRadius.circular(
          config.fullScreen
              ? t.radiusModalContentFullscreen
              : t.radiusModalContent,
        ),
        // inset 层走 SemiInsetShadow 画师（见差异清单）。
        boxShadow: t.shadowModalContent.toDropBoxShadows(),
      ),
      clipBehavior: Clip.antiAlias,
      child: SemiInsetShadow(
        shadows: t.shadowModalContent,
        borderRadius: BorderRadius.circular(
          config.fullScreen
              ? t.radiusModalContentFullscreen
              : t.radiusModalContent,
        ),
        borderWidth: config.fullScreen ? 0 : t.widthModalContentBorder,
        child: Padding(
          padding:
              config.contentPadding ??
              EdgeInsets.symmetric(
                vertical: t.spacingModalContentPaddingY,
                horizontal: t.spacingModalContentPaddingX,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?headerArea,
              if (_isBodyWrapper(config, header))
                // 无 header 时 body-wrapper：icon + body + closer 行。
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: t.spacingModalBodyWrapperMarginY,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ?iconSlot,
                      Expanded(child: _slot(config.content)),
                      closer,
                    ],
                  ),
                )
              else if (config.fullScreen || config.height != null)
                // `-body { flex: 1 1 auto }`：定高容器（`-content-fullScreen
                // { height: 100% }` / `-content-height-set`）里 body 吃满余量，
                // footer 被推到容器底部（`marginY` 24 距底）。
                Expanded(child: body)
              else
                body,
              ?footer,
            ],
          ),
        ),
      ),
    );

    // 非 centered：距容器顶 marginY 80（`margin: 80px auto`）。
    final Widget placed;
    if (config.fullScreen) {
      // `-content-fullScreen { margin: unset; top:
      // $spacing-modal_content_fullscreen-top }`（0）。
      placed = Padding(
        padding: EdgeInsetsDirectional.only(
          top: t.spacingModalContentFullscreenTop,
        ),
        child: box,
      );
    } else if (config.centered == true) {
      placed = box;
    } else {
      // 非 centered：距容器顶 marginY 80（`margin: 80px auto`）。
      placed = Padding(
        padding: EdgeInsetsDirectional.only(top: t.spacingModalMarginY),
        child: box,
      );
    }
    // 上游 `role="dialog" aria-modal="true"` → Semantics container 语义。
    return Semantics(
      container: true,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              config.closeOnEsc == true &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            onClose();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: placed,
      ),
    );
  }

  double? _sizeWidth(SemiResolvedModalThemeData t, BuildContext context) {
    final size = config.size ?? SemiModalSize.small;
    return switch (size) {
      SemiModalSize.small => t.widthModalSmall,
      SemiModalSize.medium => t.widthModalMedium,
      SemiModalSize.large => t.widthModalLarge,
      // `calc(100vw - 64px)`：视口宽 - 64。
      SemiModalSize.fullWidth => MediaQuery.sizeOf(context).width - 64,
    };
  }

  Widget? _buildFooter(SemiResolvedModalThemeData t, bool rtl) {
    // [SemiModalEmptySlot] = `footer={null}` 显式空（无 footer 节点——上游
    // `'footer' in props ? footer : renderFooter()` 覆盖缺省按钮行）。
    if (config.footer is SemiModalEmptySlot) return null;
    if (config.footer case final Widget customFooter) {
      return Container(
        margin: EdgeInsetsDirectional.only(
          top: t.spacingModalFooterMarginY,
          bottom: t.spacingModalFooterMarginY,
          start: t.spacingModalFooterMarginX,
          end: t.spacingModalFooterMarginX,
        ),
        child: customFooter,
      );
    }
    final okType = config.okType ?? SemiButtonType.primary;
    final showCancel = config.hasCancel ?? true;
    // 上游默认 footer：ok 恒渲染（onOk 缺省 noop）+ cancel 按 hasCancel。
    final buttons = <Widget>[
      if (showCancel)
        SemiButton(
          config.cancelText ?? '取消',
          type: SemiButtonType.tertiary,
          loading: cancelLoading,
          block: config.footerFill,
          onPressed: () => onCancel?.call(),
        ),
      if (showCancel)
        // footer 按钮 `margin-left: 12`（RTL 翻为 margin-right）。
        SizedBox(width: t.spacingModalFooterButtonMarginLeft),
      SemiButton(
        config.okText ?? '确定',
        type: okType,
        loading: confirmLoading,
        block: config.footerFill,
        onPressed: () => onOk?.call(),
      ),
    ];
    return Container(
      margin: EdgeInsetsDirectional.only(
        top: t.spacingModalFooterMarginY,
        bottom: t.spacingModalFooterMarginY,
        start: t.spacingModalFooterMarginX,
        end: t.spacingModalFooterMarginX,
      ),
      // `text-align: right`（rtl.scss 翻为 left）。
      child: Row(
        mainAxisAlignment: rtl
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: config.footerFill
            ? [for (final b in buttons) Expanded(child: b)]
            : buttons,
      ),
    );
  }
}
