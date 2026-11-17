// SemiImage — 上游 packages/semi-ui/image/{image.tsx,preview.tsx,previewInner.tsx,
// previewImage.tsx,previewHeader.tsx,previewFooter.tsx,interface.tsx,
// previewContext.tsx} 与 packages/semi-foundation/image/{image.scss,variables.scss,
// animation.scss,rtl.scss,imageFoundation.ts,previewFoundation.ts,
// previewInnerFoundation.ts,previewImageFoundation.ts,previewFooterFoundation.ts,
// utils.ts,constants.ts} 的移植。
//
// 主题对账 **52 = 44 FIELDS + 8 MOTION + 0 INTERNAL**（variables.scss 44 声明
// + animation.scss 8 声明；`$module` 类名胶水与 rtl.scss 的 `direction: rtl`
// 不计；avatar `99 = 89 FIELDS + 10 MOTION + 0 INTERNAL`、upload
// `85 = 85 + 0 + 0` 先例）。★8 死变量（`$spacing-image_mask_info_text-marginTop`
// / `$color-image_mask-bg` / `$color-image_mask_info_text` —— renderMask 死代码；
// `$color-image_preview-bg` —— image.scss:70 硬编码；transition 三兄弟 ——
// image.scss:220 注释行/零引用；`$transform_rotate-image_preview_spinner` ——
// 只被 image.scss:237 的死 `@keyframes spinner` 引用），本文件不得出现这些
// 字段名，生成器 assertNotIn 断言。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - image.tsx:55 defaultProps `preview: true`。
// - image.tsx:168-173 `renderMask` —— 死代码（render() 从不调用），遮罩
//   `IconEyeOpened` + `getLocalTextByKey("preview")`（"预览"）与三条 mask 变量
//   一起留档不复现。
// - image.tsx:111-116 缺省加载占位 `Skeleton.Image`（Flutter: SemiSkeletonImage）。
// - image.tsx:144-148 缺省失败 `IconUploadError size="extra-large"`
//   （Flutter: SemiIcons.uploadError）。
// - image.tsx:185 高清源回落 `preview.src ?? src`。
// - image.scss:17-20 `max-width: none`（注释 `the max-width of img/video is set to 100%`
//   tailwind 兼容）。
// - image.scss:27 `cursor: zoom-in`（成功且可预览）。
// - image.scss:31 `&-error` → `opacity: 0`（失败图隐藏）。
// - image.scss:70 `background-color: var(--semi-color-overlay-bg)` —— 预览层背景
//   硬编码（`$color-image_preview-bg` 因此死）。
// - image.scss:75 `.#{$module}-preview-hide` → `opacity: 0`（chrome 自动隐藏）。
// - image.scss:88 `border-radius: 50%`（prev/next 圆形）。
// - image.scss:157 `bottom: 16px`（footer 居底）。
// - image.scss:219 `z-index: 0`（预览图层）。
// - image.scss:226 `transform: translate(-50%, -50%)`（spin 居中）。
// - image.scss:118 `pointer-events: none`（header 命中穿透，close 例外）。
// - image.scss:110 `font-size-regular`（header 字体）。
// - image.scss:163 `font-size-header-6`（页码字体）。
// - image.scss:237 `@keyframes spinner` —— 死 keyframe（全仓无 animation-name
//   消费），连同 `$transform_rotate-image_preview_spinner` 留档。
// - image.scss:220 `// transition: transform $transition_duration-image_preview_image_img`
//   —— 注释掉的 transition（transition 三死变量唯一出现处）。
// - image.scss:245 `img[src=""], img:not([src])` → opacity 0（空 src 隐藏）。
// - rtl.scss:8 `direction: rtl`；rtl.scss:30 `margin-right: $spacing-image_preview_footer_gap-marginLeft`
//   （gap 翻转）；rtl.scss:15 `$transform_rotate-image_preview_icon-rtl`（箭头 180°）。
// - constants.ts:8 `DEFAULT_Z_INDEX: 1070`（zIndex 缺省；`$z-image_preview` 同值）。
// - previewInner.tsx:68-82 defaultProps `zoomStep: 0.1`、`infinite: false`、
//   `closable: true`、`closeOnEsc: true`、`lazyLoad: false`、`preLoad: true`、
//   `preLoadGap: 2`、`maskClosable: true`、`viewerVisibleDelay: 10000`、
//   `maxZoom: 5`、`minZoom: 0.1`。
// - preview.tsx:62-67 组 defaultProps `lazyLoadMargin: '0px 100px 100px 0px'`、
//   `lazyLoad: true`（组侧缺省，props 类缺省取 Inner 的 `lazyLoad: false`）。
// - preview.tsx:198 `imageID: index++` —— 组内递归扫描派发索引（Flutter 端换算为
//   扫描序 + 元素树点击定位）。
// - previewInnerFoundation.ts:197 `ROTATE_STEP = 90`。
// - previewInnerFoundation.ts:128 `Math.abs(clientX - x) > 5 || Math.abs(y - clientY) > 5`
//   —— mask 关闭 5px 容错。
// - previewInnerFoundation.ts:143 `e.keyCode === KeyCode.ESC`（closeOnEsc）。
// - previewInnerFoundation.ts:155 `(currentIndexInState + step + srcLength) % srcLength`
//   —— 取模换页（回调恒换算，端点按钮受 infinite 控制）。
// - previewInnerFoundation.ts:176 `lastIndexOf("/") + 1).split('?')[0]` —— 下载
//   文件名 basename 去 query（setDownloadName 覆盖）。
// - previewInnerFoundation.ts:220 `(currZoom + zoomStep).toFixed(2)` —— 滚轮步进
//   保留 2 位小数。
// - previewInnerFoundation.ts:327 `Math.min(max, Math.max(min, zoom))` —— 缩放钳制。
// - previewImageFoundation.ts:98 `containerWidth - 80` —— 自适应缩放预留边距。
// - previewImageFoundation.ts:101 `reservedWidth / imageWidth, reservedHeight / imageHeight).toFixed(2)`
//   —— 自适应 zoom 取小保留 2 位。
// - previewImageFoundation.ts:53-54 `_initialZoomAppliedSrc` —— initialZoom 每
//   src 只应用一次。
// - previewImageFoundation.ts:208 `width * cosTheta + height * sinTheta` —— 旋转
//   感知包围盒。
// - previewImageFoundation.ts:248 `(e.offsetX - 0.5 * width) * (1 - newZoom / currZoom) + translate.x`
//   —— 滚轮缩放定桩（按 0/90/180/270 分象限）。
// - previewImageFoundation.ts:312 `e.buttons === 1` —— 仅左键拖拽。
// - previewImageFoundation.ts:302 `Math.min(translateX, extremeX)` —— 平移钳制。
// - previewFooter.tsx:48-54 defaultProps `min: 10`、`max: 500`、`step: 10`
//   （百分比档）。
// - previewFooter.tsx:262 `getIconChevronLeft` —— 菜单序
//   `chevronLeft | n/m | chevronRight | − | slider | + | 比例 | 旋转 | 下载`。
// - previewFooter.tsx:274 `menuItems.splice(3, 0` / :275 `menuItems.splice(8, 0`
//   —— 分隔线插在位 3 与位 8。
// - previewFooter.tsx:255 `` `${v}%` `` —— slider tip 百分比。
// - previewFooter.tsx:96 `}, 50)` —— slider onChange 节流 50ms。
// - previewFooterFoundation.ts:29 `ratio === "adaptation" ? "realSize" : "adaptation"`
//   —— 比例钮切换（图标显示目标模式）。
// - previewFooter.tsx:142 `handleRotateLeft` —— footer 旋转恒左旋（右旋仅
//   renderPreviewMenu 透出）。
// - previewFooter.tsx:126 `zIndex={zIndex + 1}` —— footer tooltip 层级 +1。
// - previewFooter.tsx:186 `preview-footer-disabled` —— 禁用态（`$color-image_preview_disabled`）。
// - previewHeader.tsx:15 `titles[currentIndex]` —— 组标题覆盖 previewTitle。
// - utils.ts:35 `crossMerge` —— 预加载序（当前 ±1, ±2… 交叉外扩）。
// - utils.ts:18 `fetch(src)` —— 下载走 fetch→blob→anchor（web DOM 专有，
//   Flutter 端回调驱动，见差异清单）。
// - utils.ts:5 `composedPath()` —— mask 关闭目标判定（icon/footer 免关）。
// - previewInner.tsx:408 `total !== 1 && (infinite || currentIndex !== 0)` ——
//   prev 显示条件（next 对称）。
// - previewInner.tsx:95 `document.body.style.overflow` —— body 滚动锁（web 专有，
//   Flutter 端不适用）。
// - previewInner.tsx:236 `willUpdateStates.ratio = 'adaptation'` —— 打开/换图重置。
//
// ★quirk 留档：`$color-image-preview_divider-bg` 命名连字符不一致（照抄）；
// `--semi-transform-rotate-none` 连字符拼写 token；scale3d z 维丢弃；组内
// `imageID` 与 `finalSrcList = [...srcArr, ...children]` 前缀错位（src[] 与
// children 同用时上游即错位，照搬）；previewImage `clickZoom` 是死 prop（声明
// 无消费）；maskClosable 判定的是 mouseup 目标而非 mousedown（icon/footer 免关，
// header 关闭钮不在免关名单——双路径同效）。
//
// ★Flutter 差异：`src` 由 string URL 化为 ImageProvider（测试可注入同步
// provider）；lazyLoad/lazyLoadMargin API 保留但无 IntersectionObserver 等价
// （不延迟加载）；下载由 `onDownload`/`onDownloadError` 回调驱动（`fetch(src)`
// →anchor 是 web DOM 机制），文件名推导保留；crossOrigin/getPopupContainer/
// imgStyle/imgCls/contextmenu 禁存等 web 专有项裁剪；rtl 仅做 prev/next 换侧、
// gap 翻转与箭头旋转；body 滚动锁不适用；chrome 自动隐藏用
// `transitionDurationImagePreview`（image.scss:71 同源）做 AnimatedOpacity。
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_image_theme.dart';
import '../theme/semi_image_theme_data.dart';
import '../theme/semi_slider_theme.dart';
import '../theme/semi_spin_theme.dart';
import '../theme/semi_spin_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_skeleton.dart';
import 'semi_spin.dart';
import 'semi_tooltip.dart';

/// 预览缩放模式（上游 `RatioType = "adaptation" | "realSize"`）。
enum SemiImageRatioType {
  /// 适应窗口（自适应 zoom）。
  adaptation,

  /// 原始尺寸（zoom = 1）。
  realSize,
}

/// 图片加载状态机（上游 `loadStatus: "loading" | "success" | "error"`）。
enum SemiImageLoadStatus { loading, success, error }

/// 预览层配置（上游 `PreviewProps`/`PreviewInnerProps` 合一；类名避
/// `SemiImagePreview` 组件名冲突取 Props 后缀）。
///
/// 缺省值对齐 previewInner.tsx:68-82 defaultProps（`showTooltip: false`、
/// `zoomStep: 0.1`、`infinite: false`、`closable: true`、`closeOnEsc: true`、
/// `lazyLoad: false`、`preLoad: true`、`preLoadGap: 2`、`maskClosable: true`、
/// `viewerVisibleDelay: 10000`、`maxZoom: 5`、`minZoom: 0.1`）；
/// `zIndex` 缺省 constants.ts `DEFAULT_Z_INDEX: 1070`。
class SemiImagePreviewProps {
  const SemiImagePreviewProps({
    this.visible,
    this.defaultVisible = false,
    this.currentIndex,
    this.defaultCurrentIndex = 0,
    this.src,
    this.previewTitle,
    this.maskClosable = true,
    this.closable = true,
    this.zoomStep = 0.1,
    this.infinite = false,
    this.showTooltip = false,
    this.closeOnEsc = true,
    this.lazyLoad = false,
    this.lazyLoadMargin,
    this.preLoad = true,
    this.preLoadGap = 2,
    this.disableDownload = false,
    this.viewerVisibleDelay = 10000,
    this.zIndex = 1070,
    this.maxZoom = 5,
    this.minZoom = 0.1,
    this.initialZoom,
    this.prevTip,
    this.nextTip,
    this.zoomInTip,
    this.zoomOutTip,
    this.rotateTip,
    this.downloadTip,
    this.adaptiveTip,
    this.originTip,
    this.renderLeftIcon,
    this.renderRightIcon,
    this.renderCloseIcon,
    this.renderHeader,
    this.renderPreviewMenu,
    this.onVisibleChange,
    this.onChange,
    this.onClose,
    this.onZoomIn,
    this.onZoomOut,
    this.onPrev,
    this.onNext,
    this.onRatioChange,
    this.onRotateLeft,
    this.onDownload,
    this.onDownloadError,
    this.setDownloadName,
  });

  /// 受控显隐（null 非受控，配合 [defaultVisible]）。
  final bool? visible;
  final bool defaultVisible;

  /// 受控当前页（null 非受控，配合 [defaultCurrentIndex]）。
  final int? currentIndex;
  final int defaultCurrentIndex;

  /// 图库源；单图缺省 `[image]`，对象形式覆盖 `preview.src ?? src`。
  final List<ImageProvider>? src;

  /// 标题（组内被 `titles[currentIndex]` 覆盖）。
  final Widget? previewTitle;

  /// 点击遮罩关闭（mouseup 目标非 icon/footer 且位移 ≤ 5px）。
  final bool maskClosable;
  final bool closable;

  /// 滚轮/±按钮缩放步进（比例值，0.1 = 10%）。
  final double zoomStep;
  final bool infinite;
  final bool showTooltip;
  final bool closeOnEsc;

  /// 组内懒加载（★Flutter 差异：无 IntersectionObserver 等价，仅保留 API）。
  final bool lazyLoad;
  final String? lazyLoadMargin;

  /// 预加载开关与前后跨度。
  final bool preLoad;
  final int preLoadGap;

  final bool disableDownload;

  /// 操作栏无操作自动隐藏延时（ms）。
  final int viewerVisibleDelay;

  /// 仅 API 对齐（overlay 插入序表达，tooltip zIndex 先例）。
  final int zIndex;

  final double maxZoom;
  final double minZoom;

  /// 每个 src 只应用一次的初始缩放（`_initialZoomAppliedSrc`）。
  final double? initialZoom;

  final String? prevTip,
      nextTip,
      zoomInTip,
      zoomOutTip,
      rotateTip,
      downloadTip,
      adaptiveTip,
      originTip;

  /// 自定义左右切换图标（可按当前页定制）。
  final Widget Function(int currentIndex)? renderLeftIcon;
  final Widget Function(int currentIndex)? renderRightIcon;
  final Widget Function()? renderCloseIcon;
  final Widget Function()? renderHeader;
  final Widget Function(SemiImagePreviewMenuProps)? renderPreviewMenu;

  final ValueChanged<bool>? onVisibleChange;
  final ValueChanged<int>? onChange;
  final VoidCallback? onClose;
  final ValueChanged<double>? onZoomIn;
  final ValueChanged<double>? onZoomOut;
  final ValueChanged<int>? onPrev;
  final ValueChanged<int>? onNext;
  final ValueChanged<SemiImageRatioType>? onRatioChange;
  final ValueChanged<double>? onRotateLeft;

  /// 下载回调（★Flutter 差异：web fetch 落盘改为应用回调驱动）。
  final void Function(ImageProvider src, int index)? onDownload;
  final ValueChanged<ImageProvider>? onDownloadError;
  final String Function(ImageProvider src)? setDownloadName;
}

/// `renderPreviewMenu` 透出的菜单能力（上游 `MenuProps`）。
class SemiImagePreviewMenuProps {
  const SemiImagePreviewMenuProps({
    required this.min,
    required this.max,
    required this.step,
    required this.curPage,
    required this.totalNum,
    required this.zoom,
    required this.ratio,
    required this.disabledPrev,
    required this.disabledNext,
    required this.disableDownload,
    required this.disabledZoomIn,
    required this.disabledZoomOut,
    required this.onDownload,
    required this.onNext,
    required this.onPrev,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRatioClick,
    required this.onRotateLeft,
    required this.onRotateRight,
  });
  final double min, max, step, zoom;
  final int curPage, totalNum;
  final SemiImageRatioType ratio;
  final bool disabledPrev, disabledNext, disableDownload;
  final bool disabledZoomIn, disabledZoomOut;
  final VoidCallback onDownload, onNext, onPrev, onZoomIn, onZoomOut;
  final VoidCallback onRatioClick, onRotateLeft, onRotateRight;
}

/// 图片（上游 `Image`，image.tsx + imageFoundation.ts）。
///
/// 上游 `src: string` 化为 [ImageProvider]（★Flutter 差异，测试可注入同步
/// provider）；`preview: boolean | PreviewProps` 拆为 [preview] 布尔 +
/// [previewProps]（对象形式，含 `defaultVisible`/受控 `visible` 等）。
class SemiImage extends StatefulWidget {
  const SemiImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.alt,
    this.placeholder,
    this.fallback,
    this.preview = true,
    this.previewProps,
    this.onLoad,
    this.onError,
    this.onClick,
    this.imageID,
  });

  /// 主图源（上游 `src`）。
  final ImageProvider image;

  /// 外层盒尺寸（上游 `width`/`height` 同时约束 img）。
  final double? width, height;

  /// 语义描述（上游 `alt`）。
  final String? alt;

  /// 加载占位（上游 `placeholder`；缺省 `Skeleton.Image`）。
  final Widget? placeholder;

  /// 失败回退（上游 `fallback: string | ReactNode`，Flutter 统一 Widget；
  /// 缺省 `IconUploadError size="extra-large"`）。
  final Widget? fallback;

  /// 是否可预览（上游 `preview: true`，成功加载后 `cursor: zoom-in`）。
  final bool preview;

  /// 预览层配置（上游 `preview` 对象形式；`src` 覆盖高清源）。
  final SemiImagePreviewProps? previewProps;

  final VoidCallback? onLoad, onError, onClick;

  /// 组内索引（上游由 Preview `imageID: index++` 注入；组内缺省由扫描序解析）。
  final int? imageID;

  @override
  State<SemiImage> createState() => _SemiImageState();
}

class _SemiImageState extends State<SemiImage> {
  SemiImageLoadStatus _loadStatus = SemiImageLoadStatus.loading;
  bool _previewVisible = false;
  ui.Image? _frame;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    final props = widget.previewProps;
    _previewVisible = props?.visible ?? props?.defaultVisible ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant SemiImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      // getDerivedStateFromProps：`props.src !== state.src` → 重置 loading。
      _loadStatus = SemiImageLoadStatus.loading;
      _frame = null;
      _resolveImage();
    }
    final visible = widget.previewProps?.visible;
    if (visible != null && visible != _previewVisible) {
      _previewVisible = visible;
    }
  }

  void _resolveImage() {
    if (_listener != null) {
      _stream?.removeListener(_listener!);
    }
    final stream = widget.image.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener(
      (info, synchronousCall) {
        if (!mounted) return;
        setState(() {
          _loadStatus = SemiImageLoadStatus.success;
          _frame = info.image;
        });
        widget.onLoad?.call();
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(() => _loadStatus = SemiImageLoadStatus.error);
        widget.onError?.call();
      },
    );
    _listener = listener;
    _stream = stream..addListener(listener);
  }

  @override
  void dispose() {
    if (_listener != null) {
      _stream?.removeListener(_listener!);
    }
    super.dispose();
  }

  void _handleClick() {
    // imageFoundation.ts handleClick：`if (!preview) return`；组内走共享图库
    // （`setCurrentIndex(imageID)` + `handleVisibleChange(true)`），否则开私有预览。
    if (!widget.preview) return;
    widget.onClick?.call();
    final group = _ImageGroupScope.maybeOf(context);
    if (group != null) {
      final index = widget.imageID ?? group.indexOfImage(context);
      if (index >= 0) {
        group.setCurrentIndex(index);
      }
      group.handleVisibleChange(true);
    } else {
      _handlePreviewVisibleChange(true);
    }
  }

  void _handlePreviewVisibleChange(bool newVisible) {
    // imageFoundation.ts:48-63：对象形式先回调 `preview.onVisibleChange`，
    // 仅当 `visible` 非受控时写 state。
    widget.previewProps?.onVisibleChange?.call(newVisible);
    if (widget.previewProps?.visible == null) {
      setState(() => _previewVisible = newVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiImageTheme.resolve(context);
    final group = _ImageGroupScope.maybeOf(context);
    final showPreviewCursor =
        widget.preview && _loadStatus == SemiImageLoadStatus.success;
    // image.tsx:183 `canPreview = loadStatus === "success" && preview && !isInGroup()`。
    final canPreview =
        _loadStatus == SemiImageLoadStatus.success &&
        widget.preview &&
        group == null;

    // 上游 `<img>` 无 width/height 时按自然像素尺寸渲染（CSS px 语义，
    // max-width: none）；显式宽高优先。
    final naturalW = _frame?.width.toDouble() ?? 0;
    final naturalH = _frame?.height.toDouble() ?? 0;
    final boxW = widget.width ?? naturalW;
    final boxH = widget.height ?? naturalH;
    final img = Opacity(
      // image.scss:31 `&-error` → `opacity: 0`。
      opacity: _loadStatus == SemiImageLoadStatus.error ? 0 : 1,
      child: _frame == null
          ? SizedBox(width: boxW, height: boxH)
          : RawImage(
              image: _frame,
              width: boxW,
              height: boxH,
              fit: BoxFit.fill,
            ),
    );

    // image.scss:245 `img[src=""], img:not([src])` → opacity 0：ImageProvider 非
    // 空恒有源，空串场景由 Flutter 图片管线自然不出图。
    final overlay = Positioned.fill(
      child: IgnorePointer(child: _buildStatus(context, t, global)),
    );

    final can = canPreview;
    return Semantics(
      label: widget.alt,
      image: true,
      child: MouseRegion(
        // image.scss:27 `cursor: zoom-in`。
        cursor: showPreviewCursor
            ? SystemMouseCursors.zoomIn
            : MouseCursor.defer,
        child: GestureDetector(
          onTap: _handleClick,
          child: Container(
            width: boxW == 0 ? null : boxW,
            height: boxH == 0 ? null : boxH,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // `.semi-image` 基础：border-radius: $radius-image。
              borderRadius: BorderRadius.circular(t.radiusImage),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: img),
                if (_loadStatus != SemiImageLoadStatus.success) overlay,
                if (can)
                  Positioned.fill(
                    child: SemiImagePreviewInner(props: _effectivePreview()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SemiImagePreviewProps _effectivePreview() {
    final props = widget.previewProps ?? const SemiImagePreviewProps();
    // image.tsx:185 `preview.src ?? src`。
    final src = props.src ?? [widget.image];
    return SemiImagePreviewProps(
      visible: _previewVisible,
      src: src,
      previewTitle: props.previewTitle,
      maskClosable: props.maskClosable,
      closable: props.closable,
      zoomStep: props.zoomStep,
      infinite: props.infinite,
      showTooltip: props.showTooltip,
      closeOnEsc: props.closeOnEsc,
      lazyLoad: props.lazyLoad,
      lazyLoadMargin: props.lazyLoadMargin,
      preLoad: props.preLoad,
      preLoadGap: props.preLoadGap,
      disableDownload: props.disableDownload,
      viewerVisibleDelay: props.viewerVisibleDelay,
      zIndex: props.zIndex,
      maxZoom: props.maxZoom,
      minZoom: props.minZoom,
      initialZoom: props.initialZoom,
      prevTip: props.prevTip,
      nextTip: props.nextTip,
      zoomInTip: props.zoomInTip,
      zoomOutTip: props.zoomOutTip,
      rotateTip: props.rotateTip,
      downloadTip: props.downloadTip,
      adaptiveTip: props.adaptiveTip,
      originTip: props.originTip,
      renderLeftIcon: props.renderLeftIcon,
      renderRightIcon: props.renderRightIcon,
      renderCloseIcon: props.renderCloseIcon,
      renderHeader: props.renderHeader,
      renderPreviewMenu: props.renderPreviewMenu,
      onVisibleChange: _handlePreviewVisibleChange,
      onChange: props.onChange,
      onClose: props.onClose,
      onZoomIn: props.onZoomIn,
      onZoomOut: props.onZoomOut,
      onPrev: props.onPrev,
      onNext: props.onNext,
      onRatioChange: props.onRatioChange,
      onRotateLeft: props.onRotateLeft,
      onDownload: props.onDownload,
      onDownloadError: props.onDownloadError,
      setDownloadName: props.setDownloadName,
    );
  }

  Widget _buildStatus(
    BuildContext context,
    SemiResolvedImageThemeData t,
    SemiThemeData global,
  ) {
    // `.semi-image-status`：flex 居中、radius-image、`$color-image_status-bg`
    // 背景、`$color-image_status` 图标色。
    final Widget child;
    if (_loadStatus == SemiImageLoadStatus.error) {
      // image.tsx:139-150 renderError：fallback（string 化 img 不复现，统一
      // Widget）包 `.semi-image-status`，缺省 `IconUploadError`。
      child =
          widget.fallback ??
          SemiIcon(
            SemiIcons.uploadError,
            size: SemiIconSize.extraLarge,
            color: t.colorImageStatus,
          );
    } else {
      // image.tsx:127-137 renderLoad：placeholder 包 `.semi-image-status`，
      // 缺省 `Skeleton.Image`。
      child = widget.placeholder ?? const SemiSkeletonImage();
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.colorImageStatusBg,
        borderRadius: BorderRadius.circular(t.radiusImage),
      ),
      child: child,
    );
  }
}

/// 组图库（上游 `Preview`，preview.tsx；semi-ui 根导出名 `ImagePreview`）。
///
/// 递归扫描 [children] 中的 [SemiImage]（`imageID: index++`）合并 src/title，
/// 共享一个 [SemiImagePreviewInner]。缺省 `lazyLoad: true`、
/// `lazyLoadMargin: '0px 100px 100px 0px'`（preview.tsx:62-67）。
class SemiImagePreview extends StatefulWidget {
  const SemiImagePreview({
    super.key,
    required this.children,
    this.props = const SemiImagePreviewProps(),
    this.src = const [],
    this.lazyLoad = true,
    this.lazyLoadMargin = '0px 100px 100px 0px',
    this.setDownloadName,
    this.style,
    this.className,
  });

  final List<Widget> children;

  /// 预览层配置（visible/currentIndex 受控或非受控）。
  final SemiImagePreviewProps props;

  /// 显式图库源（上游 `src: string[]`）；children 扫描源追加其后
  /// （★quirk 照搬：`finalSrcList = [...srcArr, ...srcListInChildren]` 与
  /// `imageID` 从 0 起的前缀错位）。
  final List<ImageProvider> src;

  /// ★Flutter 差异：仅保留 API（无 IntersectionObserver 等价）。
  final bool lazyLoad;
  final String lazyLoadMargin;

  final String Function(ImageProvider src)? setDownloadName;

  /// 组容器样式（上游 style/className 落 `.semi-image-preview-group`）。
  final TextStyle? style;
  final String? className;

  @override
  State<SemiImagePreview> createState() => _SemiImagePreviewState();
}

class _SemiImagePreviewState extends State<SemiImagePreview> {
  final GlobalKey _groupKey = GlobalKey();
  late int _currentIndex;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.props.currentIndex ?? widget.props.defaultCurrentIndex;
    _visible = widget.props.visible ?? widget.props.defaultVisible;
  }

  @override
  void didUpdateWidget(covariant SemiImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.props.currentIndex;
    if (index != null && index != _currentIndex) {
      _currentIndex = index;
    }
    final visible = widget.props.visible;
    if (visible != null && visible != _visible) {
      _visible = visible;
    }
  }

  // preview.tsx:164-199 loopImageIndex：递归收集 SemiImage 的预览源与标题。
  void _collect(Widget widget, List<ImageProvider> srcs, List<Widget?> titles) {
    if (widget is SemiImage) {
      if (widget.preview) {
        // `preview.src ?? src`（对象形式取首项，组内一图一源）。
        final props = widget.previewProps;
        final src = props?.src != null && props!.src!.isNotEmpty
            ? props.src!.first
            : widget.image;
        srcs.add(src);
        titles.add(props?.previewTitle);
      }
      return;
    }
    if (widget is MultiChildRenderObjectWidget) {
      for (final child in widget.children) {
        _collect(child, srcs, titles);
      }
      return;
    }
    if (widget is SingleChildRenderObjectWidget) {
      final child = widget.child;
      if (child != null) _collect(child, srcs, titles);
      return;
    }
    if (widget is ParentDataWidget) {
      _collect(widget.child, srcs, titles);
      return;
    }
    if (widget is ProxyWidget) {
      _collect(widget.child, srcs, titles);
      return;
    }
    if (widget is Container && widget.child != null) {
      _collect(widget.child!, srcs, titles);
    }
  }

  void _handleVisibleChange(bool newVisible) {
    // previewFoundation.ts：`!(visible in props)` 时写 state，回调恒发。
    if (widget.props.visible == null) {
      setState(() => _visible = newVisible);
    }
    widget.props.onVisibleChange?.call(newVisible);
  }

  void _handleCurrentIndexChange(int index) {
    if (widget.props.currentIndex == null) {
      setState(() => _currentIndex = index);
    }
    widget.props.onChange?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final childSrcs = <ImageProvider>[];
    final titles = <Widget?>[];
    for (final child in widget.children) {
      _collect(child, childSrcs, titles);
    }
    // preview.tsx:210-211 `finalSrcList = [...srcArr, ...srcListInChildren]`。
    final srcs = [...widget.src, ...childSrcs];
    final inner = widget.props;
    return _ImageGroupScope(
      previewSrc: srcs,
      titles: titles,
      currentIndex: _currentIndex,
      visible: _visible,
      lazyLoad: widget.lazyLoad,
      groupKey: _groupKey,
      setCurrentIndex: _handleCurrentIndexChange,
      handleVisibleChange: _handleVisibleChange,
      setDownloadName: widget.setDownloadName ?? inner.setDownloadName,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            key: _groupKey,
            width: double.infinity,
            child: Wrap(children: widget.children),
          ),
          SemiImagePreviewInner(
            props: SemiImagePreviewProps(
              visible: _visible,
              currentIndex: _currentIndex,
              src: srcs,
              previewTitle: inner.previewTitle,
              maskClosable: inner.maskClosable,
              closable: inner.closable,
              zoomStep: inner.zoomStep,
              infinite: inner.infinite,
              showTooltip: inner.showTooltip,
              closeOnEsc: inner.closeOnEsc,
              lazyLoad: inner.lazyLoad,
              preLoad: inner.preLoad,
              preLoadGap: inner.preLoadGap,
              disableDownload: inner.disableDownload,
              viewerVisibleDelay: inner.viewerVisibleDelay,
              zIndex: inner.zIndex,
              maxZoom: inner.maxZoom,
              minZoom: inner.minZoom,
              initialZoom: inner.initialZoom,
              prevTip: inner.prevTip,
              nextTip: inner.nextTip,
              zoomInTip: inner.zoomInTip,
              zoomOutTip: inner.zoomOutTip,
              rotateTip: inner.rotateTip,
              downloadTip: inner.downloadTip,
              adaptiveTip: inner.adaptiveTip,
              originTip: inner.originTip,
              renderLeftIcon: inner.renderLeftIcon,
              renderRightIcon: inner.renderRightIcon,
              renderCloseIcon: inner.renderCloseIcon,
              renderHeader: inner.renderHeader,
              renderPreviewMenu: inner.renderPreviewMenu,
              onVisibleChange: _handleVisibleChange,
              onChange: _handleCurrentIndexChange,
              onClose: inner.onClose,
              onZoomIn: inner.onZoomIn,
              onZoomOut: inner.onZoomOut,
              onPrev: inner.onPrev,
              onNext: inner.onNext,
              onRatioChange: inner.onRatioChange,
              onRotateLeft: inner.onRotateLeft,
              onDownload: inner.onDownload,
              onDownloadError: inner.onDownloadError,
              setDownloadName: widget.setDownloadName ?? inner.setDownloadName,
            ),
          ),
        ],
      ),
    );
  }
}

/// 组上下文（上游 `PreviewContext`）。
class _ImageGroupScope extends InheritedWidget {
  const _ImageGroupScope({
    required this.previewSrc,
    required this.titles,
    required this.currentIndex,
    required this.visible,
    required this.lazyLoad,
    required this.groupKey,
    required this.setCurrentIndex,
    required this.handleVisibleChange,
    required this.setDownloadName,
    required super.child,
  });

  final List<ImageProvider> previewSrc;
  final List<Widget?> titles;
  final int currentIndex;
  final bool visible;
  final bool lazyLoad;
  final GlobalKey groupKey;
  final ValueChanged<int> setCurrentIndex;
  final ValueChanged<bool> handleVisibleChange;
  final String Function(ImageProvider src)? setDownloadName;

  static _ImageGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ImageGroupScope>();

  /// 点击定位：元素树深度优先（视觉序）解析被点 SemiImage 的索引，
  /// 等价 `imageID: index++` 注入（preview.tsx:198）。
  int indexOfImage(BuildContext imageContext) {
    final root = groupKey.currentContext;
    if (root == null) return -1;
    var index = 0;
    var found = -1;
    void visit(Element element) {
      if (found >= 0) return;
      final w = element.widget;
      if (w is SemiImage) {
        if (w.preview) {
          if (identical(element, imageContext)) found = index;
          index++;
        }
        return;
      }
      element.visitChildElements(visit);
    }

    root.visitChildElements(visit);
    return found;
  }

  @override
  bool updateShouldNotify(_ImageGroupScope oldWidget) =>
      currentIndex != oldWidget.currentIndex ||
      visible != oldWidget.visible ||
      !identical(previewSrc, oldWidget.previewSrc) ||
      !identical(titles, oldWidget.titles);
}

/// 全屏预览层（上游 `PreviewInner`，previewInner.tsx + 四个 foundation）。
///
/// `visible` 受控（[SemiImagePreviewProps.visible]）；`currentIndex` 受控或
/// 非受控。以 ambient Overlay 插入序表达 `$z-image_preview` 层级（tooltip
/// zIndex 先例）。
class SemiImagePreviewInner extends StatefulWidget {
  const SemiImagePreviewInner({super.key, required this.props});

  final SemiImagePreviewProps props;

  @override
  State<SemiImagePreviewInner> createState() => _SemiImagePreviewInnerState();
}

class _SemiImagePreviewInnerState extends State<SemiImagePreviewInner> {
  OverlayEntry? _entry;

  // 预览层状态（previewInner.tsx:193-204 state）。
  late double _zoom;
  late int _currentIndex;
  late SemiImageRatioType _ratio;
  late double _rotation;
  late bool _viewerVisible;
  late bool _preloadAfterVisibleChange;
  String _direction = '';
  final Set<ImageProvider> _imgLoadStatus = {};

  // 画布状态（previewImage.tsx state + previewImageFoundation 字段）。
  bool _canvasLoading = true;
  ui.Image? _canvasImage;
  ImageProvider? _canvasProvider;
  ImageStream? _canvasStream;
  ImageStreamListener? _canvasListener;
  double _naturalWidth = 0, _naturalHeight = 0;
  double _canvasWidth = 0, _canvasHeight = 0;
  Offset _translate = Offset.zero;

  // 交互缓存。
  Offset _startMouseDown = Offset.zero;
  Offset _startDrag = Offset.zero;
  bool _upOnChrome = false;
  bool _moveOnChrome = false;
  bool _closeHover = false;
  bool _initialZoomApplied = false;
  ImageProvider? _initialZoomAppliedSrc;
  Size _containerSize = Size.zero;
  DateTime _lastMoveProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _viewerTimer;

  /// 组标题（`titles[currentIndex]` 覆盖 previewTitle）：build 时抓取，
  /// entry 渲染时经 [_currentTitle] 实时取值，避免 build 顺序依赖。
  List<Widget?>? _groupTitles;

  Widget? get _currentTitle {
    final titles = _groupTitles;
    if (titles != null &&
        _currentIndex < titles.length &&
        titles[_currentIndex] != null) {
      return titles[_currentIndex];
    }
    return _p.previewTitle;
  }

  // previewFooter.tsx:48-54 defaultProps（百分比档）：`min: 10`、`max: 500`、
  // `step: 10`（由 Inner 以 `zoom*100` 等透传覆盖）。

  SemiImagePreviewProps get _p => widget.props;

  List<ImageProvider> get _imgSrc => _p.src ?? const [];

  @override
  void initState() {
    super.initState();
    _zoom = 0.1;
    _currentIndex = _p.currentIndex ?? _p.defaultCurrentIndex;
    _ratio = SemiImageRatioType.adaptation;
    _rotation = 0;
    _viewerVisible = true;
    _preloadAfterVisibleChange = true;
    if (_p.visible == true) {
      _updateTimer();
      _scheduleEntrySync();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_p.visible == true) _resolveCanvas();
  }

  @override
  void didUpdateWidget(covariant SemiImagePreviewInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final visible = _p.visible == true;
    final wasVisible = oldWidget.props.visible == true;
    if (visible != wasVisible) {
      if (visible) {
        // gDSFP：visible→true 重置 `rotation=0`、`ratio='adaptation'`、
        // viewerVisible、preloadAfterVisibleChange（previewInner.tsx:234-239）。
        _rotation = 0;
        _ratio = SemiImageRatioType.adaptation;
        _viewerVisible = true;
        _preloadAfterVisibleChange = true;
        _beforeShow();
      } else {
        _afterHide();
      }
    }
    if (visible && oldWidget.props.src != _p.src) {
      _updateTimer();
    }
    final index = _p.currentIndex;
    if (index != null && index != _currentIndex) {
      _currentIndex = index;
      // gDSFP：换图重置 `willUpdateStates.ratio = 'adaptation'`。
      _ratio = SemiImageRatioType.adaptation;
      _resolveCanvas();
    }
    if (!identical(oldWidget.props.src, _p.src)) {
      _resolveCanvas();
    }
  }

  @override
  void dispose() {
    _removeEntry();
    _viewerTimer?.cancel();
    _disposeCanvas();
    super.dispose();
  }

  void _disposeCanvas() {
    if (_canvasListener != null) {
      _canvasStream?.removeListener(_canvasListener!);
      _canvasListener = null;
    }
  }

  void _beforeShow() {
    // previewInnerFoundation.ts beforeShow：注册按键、锁 body 滚动、启计时。
    // `document.body.style.overflow` 锁是 web 专有（★Flutter 差异）。
    _updateTimer();
    _resolveCanvas();
    _scheduleEntrySync();
  }

  void _afterHide() {
    _clearTimer();
    // remove 同样不能发生在 build 中，走帧后同步。
    _scheduleEntrySync();
  }

  void _updateTimer() {
    // viewerVisibleDelay 自动隐藏（previewInnerFoundation.ts:81-85）。
    _clearTimer();
    _viewerTimer = Timer(Duration(milliseconds: _p.viewerVisibleDelay), () {
      if (mounted && _viewerVisible) {
        _mutate(() => _viewerVisible = false);
      }
    });
  }

  void _clearTimer() {
    _viewerTimer?.cancel();
    _viewerTimer = null;
  }

  /// 状态变更后同步重绘 overlay 内容（entry builder 读取本 State）。
  /// 同步 ImageStream 回调可能落在 build 相位（didUpdateWidget/didChangeDependencies
  /// → resolve → listener 同步触发），entry 不是当前构建子树，markNeedsBuild
  /// 需推迟到帧后。
  void _mutate(VoidCallback fn) {
    setState(fn);
    final entry = _entry;
    if (entry == null) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        entry.markNeedsBuild();
      });
    } else {
      entry.markNeedsBuild();
    }
  }

  /// insert/remove 不能发生在 build 中（markNeedsBuild during build），
  /// 统一推迟到帧后执行。
  void _scheduleEntrySync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncEntry();
    });
  }

  void _syncEntry() {
    final visible = _p.visible == true;
    if (visible && _entry == null) {
      _entry = OverlayEntry(builder: _buildLayer);
      Overlay.of(context).insert(_entry!);
    } else if (!visible && _entry != null) {
      _removeEntry();
    } else {
      _entry?.markNeedsBuild();
    }
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  // ---------- 换页（previewInnerFoundation.ts:151-171 handleSwitchImage）。

  void _handleSwitchImage(String direction) {
    final step = direction == 'prev' ? -1 : 1;
    final length = _imgSrc.length;
    if (length == 0) return;
    // `(currentIndexInState + step + srcLength) % srcLength`。
    final newIndex = (_currentIndex + step + length) % length;
    if (_p.currentIndex != null) {
      final group = _ImageGroupScope.maybeOf(context);
      if (group != null) group.setCurrentIndex(newIndex);
    }
    // 本地副本同步更新（受控时 didUpdateWidget 会确认同值），entry 立即带
    // `titles[currentIndex]` 重绘。
    _mutate(() => _currentIndex = newIndex);
    _p.onChange?.call(newIndex);
    if (direction == 'prev') {
      _p.onPrev?.call(newIndex);
    } else {
      _p.onNext?.call(newIndex);
    }
    _mutate(() {
      _direction = direction;
      _rotation = 0;
    });
    _resolveCanvas();
  }

  // ---------- 缩放（previewInnerFoundation.ts:206-217 + 321-329）。

  double _clampZoom(double zoom) {
    // `Math.min(max, Math.max(min, zoom))`。
    final max = _p.maxZoom;
    final min = _p.minZoom;
    if (!zoom.isFinite) return min;
    return math.min(max, math.max(min, zoom));
  }

  double _round2(double value) => (value * 100).roundToDouble() / 100;

  void _handleZoomImage(double newZoom, {bool notify = true, Offset? anchor}) {
    final nextZoom = _clampZoom(newZoom);
    if (_zoom != nextZoom) {
      if (notify) {
        if (nextZoom > _zoom) {
          _p.onZoomIn?.call(nextZoom);
        } else {
          _p.onZoomOut?.call(nextZoom);
        }
      }
      _mutate(() => _zoom = nextZoom);
      _changeZoom(nextZoom, anchor: anchor);
    }
  }

  void _onWheel(PointerScrollEvent event) {
    // previewInnerFoundation.ts:99-117 onWheel：`deltaY<0` 放大 / `>0` 缩小，
    // 步进 `(currZoom + zoomStep).toFixed(2)`，仅当结果在 [min,max] 内。
    final delta = event.scrollDelta.dy;
    double? next;
    if (delta < 0) {
      if (_zoom + _p.zoomStep <= _p.maxZoom) {
        next = _round2(_zoom + _p.zoomStep);
      }
    } else if (delta > 0) {
      if (_zoom - _p.zoomStep >= _p.minZoom) {
        next = _round2(_zoom - _p.zoomStep);
      }
    }
    if (next != null) {
      final anchor = _anchorOffset(event.localPosition);
      _handleZoomImage(next, anchor: anchor);
    }
  }

  /// 指针相对未旋转图盒左上角的偏移（上游 e.offsetX/offsetY）。
  Offset? _anchorOffset(Offset local) {
    final w = _canvasWidth, h = _canvasHeight;
    if (w <= 0 || h <= 0) return null;
    final center = Offset(_containerSize.width / 2, _containerSize.height / 2);
    final topLeft = center + _translate - Offset(w / 2, h / 2);
    final offset = local - topLeft;
    final inside =
        offset.dx >= 0 && offset.dy >= 0 && offset.dx <= w && offset.dy <= h;
    return inside ? offset : null;
  }

  // ---------- 画布几何（previewImageFoundation.ts）。

  ({double width, double height}) _boundingRect(
    double w,
    double h,
    double rotation,
  ) {
    // `width * cosTheta + height * sinTheta`（旋转感知包围盒）。
    final radians = rotation * math.pi / 180;
    final sinTheta = math.sin(radians).abs();
    final cosTheta = math.cos(radians).abs();
    return (
      width: w * cosTheta + h * sinTheta,
      height: w * sinTheta + h * cosTheta,
    );
  }

  ({bool canDragVertical, bool canDragHorizontal}) _canDragDirection(
    double width,
    double height,
  ) => (
    canDragHorizontal: width > _containerSize.width,
    canDragVertical: height > _containerSize.height,
  );

  Offset _safeTranslate(double width, double height, double x, double y) {
    // getSafeTranslate：极端位移 `Math.min(translateX, extremeX)` 钳制；
    // 轴仅在图超出容器时可动。
    final extremeX = (width - _containerSize.width) / 2;
    final extremeY = (height - _containerSize.height) / 2;
    final drag = _canDragDirection(width, height);
    var newX = 0.0, newY = 0.0;
    if (drag.canDragHorizontal) {
      newX = x > 0 ? math.min(x, extremeX) : math.max(x, -extremeX);
    }
    if (drag.canDragVertical) {
      newY = y > 0 ? math.min(y, extremeY) : math.max(y, -extremeY);
    }
    return Offset(newX, newY);
  }

  double _adaptationZoom() {
    // `_getAdaptationZoom`：`containerWidth - 80` 预留边距；
    // `reservedWidth / imageWidth, reservedHeight / imageHeight).toFixed(2)`。
    if (_naturalWidth <= 0 || _naturalHeight <= 0) return 1;
    final bound = _boundingRect(_naturalWidth, _naturalHeight, _rotation);
    final reservedWidth = _containerSize.width - 80;
    final reservedHeight = _containerSize.height - 80;
    return _round2(
      math.min(reservedWidth / bound.width, reservedHeight / bound.height),
    );
  }

  double _initialZoom() {
    // `_initialZoomAppliedSrc` —— initialZoom 每 src 只应用一次。
    final provider = _canvasProvider;
    if (provider != _initialZoomAppliedSrc) {
      _initialZoomAppliedSrc = provider;
      _initialZoomApplied = false;
    }
    final initial = _p.initialZoom;
    if (!_initialZoomApplied &&
        initial != null &&
        initial.isFinite &&
        initial > 0) {
      _initialZoomApplied = true;
      return _clampZoom(initial);
    }
    if (_ratio == SemiImageRatioType.adaptation) {
      return _clampZoom(_adaptationZoom());
    }
    return _clampZoom(1);
  }

  void _initializeImage({bool notify = true}) {
    final next = _initialZoom();
    if (_zoom != next) {
      if (notify) {
        _handleZoomImage(next, notify: true);
      } else {
        // 初载 zoom 变化不透出回调（previewImageFoundation.ts:151-158）。
        _zoom = next;
        _changeZoom(next);
      }
    } else {
      _changeZoom(next);
    }
    _translate = Offset.zero;
  }

  void _changeZoom(double newZoom, {Offset? anchor}) {
    // previewImageFoundation.ts:226-281 changeZoom：等比平移、定桩缩放
    // （`(e.offsetX - 0.5 * width) * (1 - newZoom / currZoom) + translate.x`）、
    // `Math.min(translateX, extremeX)` 钳制。
    final changeScale = newZoom / (_zoom == 0 ? 1 : _zoom);
    final newWidth = (_naturalWidth * newZoom).floorToDouble();
    final newHeight = (_naturalHeight * newZoom).floorToDouble();
    var newX = (_translate.dx * changeScale).floorToDouble();
    var newY = (_translate.dy * changeScale).floorToDouble();

    final imageBound = _boundingRect(_canvasWidth, _canvasHeight, _rotation);
    final newImageBound = (
      width: imageBound.width * changeScale,
      height: imageBound.height * changeScale,
    );

    if (anchor != null) {
      final width = _canvasWidth, height = _canvasHeight;
      final ratio = 1 - newZoom / (_zoom == 0 ? 1 : _zoom);
      var angle = _rotation % 360;
      if (angle < 0) angle += 360;
      // 0/90/180/270 分象限定桩（previewImageFoundation.ts:242-265）。
      switch (angle) {
        case 0:
          newX = (anchor.dx - 0.5 * width) * ratio + _translate.dx;
          newY = (anchor.dy - 0.5 * height) * ratio + _translate.dy;
        case 90:
          newX = (0.5 * height - anchor.dy) * ratio + _translate.dx;
          newY = (anchor.dx - 0.5 * width) * ratio + _translate.dy;
        case 180:
          newX = (0.5 * width - anchor.dx) * ratio + _translate.dx;
          newY = (0.5 * height - anchor.dy) * ratio + _translate.dy;
        case 270:
          newX = (anchor.dy - 0.5 * height) * ratio + _translate.dx;
          newY = (0.5 * width - anchor.dx) * ratio + _translate.dy;
      }
    }

    _translate = _safeTranslate(
      newImageBound.width,
      newImageBound.height,
      newX,
      newY,
    );
    _canvasWidth = newWidth;
    _canvasHeight = newHeight;
  }

  // ---------- 拖拽（previewImageFoundation.ts:311-342）。

  void _handleImageDrag(Offset globalPosition) {
    // `e.buttons === 1` 仅左键（Listener onPointerMove + buttons 掩码）。
    final bound = _boundingRect(_canvasWidth, _canvasHeight, _rotation);
    final drag = _canDragDirection(bound.width, bound.height);
    if (!drag.canDragHorizontal && !drag.canDragVertical) return;
    final delta = globalPosition - _startDrag;
    var newX = _translate.dx;
    var newY = _translate.dy;
    if (drag.canDragHorizontal) newX += delta.dx;
    if (drag.canDragVertical) newY += delta.dy;
    _translate = _safeTranslate(bound.width, bound.height, newX, newY);
    _startDrag = globalPosition;
  }

  // ---------- 旋转/比例/下载。

  void _handleRotateImage(String direction) {
    // `ROTATE_STEP = 90`；`onRotateLeft` 双向透出绝对角度。
    const rotateStep = 90.0;
    final next = _rotation + (direction == 'left' ? -rotateStep : rotateStep);
    _mutate(() => _rotation = next);
    _p.onRotateLeft?.call(next);
  }

  void _handleAdjustRatio(SemiImageRatioType type) {
    _mutate(() => _ratio = type);
    _p.onRatioChange?.call(type);
    _initializeImage();
  }

  void _handleDownload() {
    // previewInnerFoundation.ts:173-180 handleDownload：文件名
    // `lastIndexOf("/") + 1).split('?')[0]`，setDownloadName 覆盖；
    // `fetch(src)` 落盘是 web DOM 机制（★Flutter 差异：回调驱动）。
    if (_imgSrc.isEmpty) return;
    final src = _imgSrc[_currentIndex];
    final _ = _downloadName(src);
    _p.onDownload?.call(src, _currentIndex);
  }

  String _downloadName(ImageProvider src) {
    final custom =
        _ImageGroupScope.maybeOf(context)?.setDownloadName ??
        _p.setDownloadName;
    if (custom != null) return custom(src);
    if (src is NetworkImage) {
      final url = src.url;
      return url.substring(url.lastIndexOf("/") + 1).split('?')[0];
    }
    return src.toString();
  }

  // ---------- 预加载（previewInnerFoundation.ts:227-291 + utils.ts crossMerge）。

  void _onImageLoad(ImageProvider src) {
    _imgLoadStatus.add(src);
    if (_preloadAfterVisibleChange) {
      _preloadGapImage();
      _preloadAfterVisibleChange = false;
    } else {
      _preloadSingleImage();
    }
  }

  void _preloadGapImage() {
    if (!_p.preLoad || _p.preLoadGap < 1 || _imgSrc.isEmpty) return;
    // `crossMerge` 交叉外扩预加载序（1..n 点开第 4 张 → 5,3,6,2）。
    final preload = _getPreloadImageArr(
      _imgSrc,
      _currentIndex,
      _p.preLoadGap,
      _p.infinite,
    );
    for (final provider in preload) {
      if (!_imgLoadStatus.contains(provider)) {
        precacheImage(
          provider,
          context,
        ).then((_) => _imgLoadStatus.add(provider), onError: (_) {});
      }
    }
  }

  void _preloadSingleImage() {
    if (!_p.preLoad || _p.preLoadGap < 1 || _imgSrc.isEmpty) return;
    var index = _currentIndex + (_direction == 'prev' ? -1 : 1) * _p.preLoadGap;
    if (index < 0 || index >= _imgSrc.length) {
      if (_p.infinite) {
        index = (index + _imgSrc.length) % _imgSrc.length;
      } else {
        return;
      }
    }
    final provider = _imgSrc[index];
    if (!_imgLoadStatus.contains(provider)) {
      precacheImage(
        provider,
        context,
      ).then((_) => _imgLoadStatus.add(provider), onError: (_) {});
    }
  }

  // ---------- 画布图源解析。

  void _resolveCanvas() {
    if (_imgSrc.isEmpty) return;
    final provider = _imgSrc[_currentIndex];
    if (provider == _canvasProvider && _canvasListener != null) return;
    _disposeCanvas();
    _canvasProvider = provider;
    _canvasLoading = true;
    final stream = provider.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener(
      (info, synchronousCall) {
        if (!mounted) return;
        _mutate(() {
          _canvasImage = info.image;
          _naturalWidth = info.image.width.toDouble();
          _naturalHeight = info.image.height.toDouble();
          _canvasLoading = false;
        });
        // 图片初载计算 zoom（previewImageFoundation.ts:145-153）。
        _initializeImage(notify: false);
        _onImageLoad(provider);
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        _mutate(() => _canvasLoading = false);
        // 加载失败也按方向预载下一张（previewInner.tsx:316-318）。
        _preloadSingleImage();
      },
    );
    _canvasListener = listener;
    _canvasStream = stream..addListener(listener);
  }

  // ---------- mask 关闭（previewInnerFoundation.ts:119-134 handleMouseUp）。

  void _handlePointerUp(PointerUpEvent event) {
    final delta = event.localPosition - _startMouseDown;
    // `Math.abs(clientX - x) > 5 || Math.abs(y - clientY) > 5` 5px 容错；
    // 目标为 icon/footer 不关（utils.ts `composedPath()` 等价标记）。
    var couldClose = !_upOnChrome;
    _upOnChrome = false;
    if (delta.dx.abs() > 5 || delta.dy.abs() > 5) couldClose = false;
    if (couldClose && _p.maskClosable) {
      _p.onVisibleChange?.call(false);
    }
  }

  void _handlePointerMove(PointerEvent event) {
    // mousemove 节流 50ms（lodash.throttle 等价）：有效区显 chrome 并复位
    // viewerVisibleDelay 计时；chrome 区清计时（previewInnerFoundation.ts:66-85）。
    final now = DateTime.now();
    if (now.difference(_lastMoveProcessed).inMilliseconds < 50) return;
    _lastMoveProcessed = now;
    final onChrome = _moveOnChrome;
    _moveOnChrome = false;
    if (!onChrome) {
      if (!_viewerVisible) _mutate(() => _viewerVisible = true);
      _updateTimer();
    } else {
      _clearTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    _groupTitles = _ImageGroupScope.maybeOf(context)?.titles;
    _scheduleEntrySync();
    return const SizedBox.shrink();
  }

  Widget _buildLayer(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiImageTheme.resolve(context);
    final media = MediaQuery.of(context);
    _containerSize = media.size;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final total = _imgSrc.length;
    // `total !== 1 && (infinite || currentIndex !== 0)`。
    final showPrev = total != 1 && (_p.infinite || _currentIndex != 0);
    final showNext = total != 1 && (_p.infinite || _currentIndex != total - 1);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // `e.keyCode === KeyCode.ESC`（closeOnEsc）。
          if (_p.closeOnEsc &&
              event is KeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            _p.onVisibleChange?.call(false);
            _p.onClose?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // image.scss:70 `background-color: var(--semi-color-overlay-bg)`
            // —— `$color-image_preview-bg` 硬编码死因。
            ColoredBox(color: global.colors.colorOverlayBg),
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerUp: _handlePointerUp,
              onPointerMove: _handlePointerMove,
              onPointerHover: _handlePointerMove,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) _onWheel(event);
              },
              onPointerDown: (event) {
                _startMouseDown = event.localPosition;
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCanvas(t),
                  if (showPrev)
                    _chrome(
                      t,
                      rtl: rtl,
                      child: _prevNext(
                        t,
                        isPrev: true,
                        rtl: rtl,
                        render: _p.renderLeftIcon?.call(_currentIndex),
                      ),
                    ),
                  if (showNext)
                    _chrome(
                      t,
                      rtl: rtl,
                      child: _prevNext(
                        t,
                        isPrev: false,
                        rtl: rtl,
                        render: _p.renderRightIcon?.call(_currentIndex),
                      ),
                    ),
                  _chrome(
                    t,
                    rtl: rtl,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildFooter(t, global, showPrev, showNext, rtl),
                    ),
                  ),
                  // image.scss:118 `z-index: $z-image_preview_header`（1，
                  // 其余 auto）——Flutter 端换算 Stack 绘制序（avatar 组
                  // z-index 先例）：header 恒最上。
                  if (t.zImagePreviewHeader > 0)
                    _chrome(
                      t,
                      rtl: rtl,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildHeader(t, global),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// chrome 自动隐藏包装（hideViewerCls）：image.scss:75
  /// `.#{$module}-preview-hide` → `opacity: 0`；image.scss:71
  /// `transition: opacity ...`。
  Widget _chrome(
    SemiResolvedImageThemeData t, {
    required bool rtl,
    required Widget child,
  }) => AnimatedOpacity(
    opacity: _viewerVisible ? 1 : 0,
    duration: t.transitionDurationImagePreview,
    child: child,
  );

  Widget _buildCanvas(SemiResolvedImageThemeData t) {
    final drag = _canDragDirection(_canvasWidth, _canvasHeight);
    final canDrag = drag.canDragHorizontal || drag.canDragVertical;
    // image.scss:219 `z-index: 0` + `transform: scale3d(...) rotate(...)`；
    // `transformScale3dImagePreviewImageImg`（`scale3d(1, 1, 1)` 恒等，z 维
    // 丢弃）先于 rotate 施加，rotate 取 transformRotateImagePreviewImageImg
    // （缺省 none）。
    final scale = t.transformScale3dImagePreviewImageImg;
    final baseAngle = t.transformRotateImagePreviewImageImg.degrees;
    Widget image = _canvasImage == null
        ? const SizedBox.shrink()
        : RawImage(
            image: _canvasImage,
            width: _canvasWidth,
            height: _canvasHeight,
            fit: BoxFit.fill,
          );
    image = Transform.rotate(
      angle: (_rotation + baseAngle) * math.pi / 180,
      child: Transform.translate(offset: _translate, child: image),
    );
    if (scale.scaleX != 1 || scale.scaleY != 1) {
      image = Transform.scale(
        scaleX: scale.scaleX,
        scaleY: scale.scaleY,
        child: image,
      );
    }
    // `// transition: transform $transition_duration-image_preview_image_img`
    // （上游注释掉，不复现）。
    return MouseRegion(
      cursor: canDrag ? SystemMouseCursors.grab : MouseCursor.defer,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (event.buttons & kPrimaryButton != 0) {
            _startDrag = event.position;
          }
        },
        onPointerMove: (event) {
          // `e.buttons === 1` 仅左键拖拽。
          if (event.buttons & kPrimaryButton != 0) {
            _handleImageDrag(event.position);
            _mutate(() {});
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: image,
              ),
            ),
            if (_canvasLoading)
              Center(
                child: SemiSpinTheme(
                  data: SemiSpinThemeData(color: t.colorImagePreviewImageSpin),
                  // image.scss:226 `transform: translate(-50%, -50%)`（spin 居中）。
                  child: const SemiSpin(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _prevNext(
    SemiResolvedImageThemeData t, {
    required bool isPrev,
    required bool rtl,
    Widget? render,
  }) {
    // image.scss:82-103 `-icon`/`-prev`/`-next`：40×40 圆形
    // （`border-radius: 50%`）、背景 `$color-image_preview_icon-bg`、
    // 前景 `$color-image_preview_icon`、`transform: translateY(-50%)`、
    // 侧距 `$spacing-image_preview_icon-x`。rtl 翻转左右侧
    // （rtl.scss:12-23）并旋转 180°（rtl.scss:15
    // `$transform_rotate-image_preview_icon-rtl`）。
    final icon =
        render ??
        SemiIcon(
          isPrev ? SemiIcons.arrowLeft : SemiIcons.arrowRight,
          size: SemiIconSize.large,
          rotate: rtl ? t.transformRotateImagePreviewIconRtl.degrees : 0,
          color: t.colorImagePreviewIcon,
        );
    final onLeft = isPrev != rtl;
    return Align(
      alignment: onLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          left: onLeft ? t.spacingImagePreviewIconX : 0,
          right: onLeft ? 0 : t.spacingImagePreviewIconX,
        ),
        child: Listener(
          // icon 目标免 mask 关（utils.ts `composedPath()`）。
          onPointerUp: (_) => _upOnChrome = true,
          onPointerMove: (_) => _moveOnChrome = true,
          onPointerHover: (_) => _moveOnChrome = true,
          child: GestureDetector(
            onTap: () => _handleSwitchImage(isPrev ? 'prev' : 'next'),
            child: Container(
              width: t.widthImagePreviewIcon,
              height: t.heightImagePreviewIcon,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.colorImagePreviewIconBg,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SemiResolvedImageThemeData t, SemiThemeData global) {
    // image.scss:105-139 `-header`：高 `$height-image_preview_header`、
    // padding `$spacing-image_preview_header-paddingY/X`、前景
    // `$color-image_preview_header`、`font-size-regular` +
    // `font-weight: normal`、`pointer-events: none`（close 例外）、
    // `z-index: $z-image_preview_header`。
    final props = _p;
    final Widget title;
    if (props.renderHeader != null) {
      title = props.renderHeader!();
    } else {
      title = DefaultTextStyle(
        style: TextStyle(
          color: t.colorImagePreviewHeader,
          fontSize: global.typography.fontSizeRegular,
          height:
              global.typography.lineHeightRegular /
              global.typography.fontSizeRegular,
          fontWeight: global.typography.fontWeightRegular,
        ),
        child: _currentTitle ?? const SizedBox.shrink(),
      );
    }
    // header 属 chrome 区（mousemove → clearTimer），但不在 mask 关闭的免关
    // 名单（`composedPath()` NOT_CLOSE_TARGETS 只有 icon/footer）。
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (_) => _moveOnChrome = true,
      onPointerHover: (_) => _moveOnChrome = true,
      child: Container(
        height: t.heightImagePreviewHeader,
        padding: EdgeInsets.symmetric(
          vertical: t.spacingImagePreviewHeaderPaddingY,
          horizontal: t.spacingImagePreviewHeaderPaddingX,
        ),
        child: Row(
          children: [
            Expanded(child: title),
            if (props.closable)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => _mutate(() => _closeHover = true),
                onExit: (_) => _mutate(() => _closeHover = false),
                child: GestureDetector(
                  onTap: () {
                    _p.onVisibleChange?.call(false);
                    _p.onClose?.call();
                  },
                  child: Container(
                    width: t.widthImagePreviewHeaderClose,
                    height: t.heightImagePreviewHeaderClose,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // hover `background-color: $color-image_header_close-bg`。
                      color: _closeHover ? t.colorImageHeaderCloseBg : null,
                    ),
                    child:
                        props.renderCloseIcon?.call() ??
                        SemiIcon(
                          SemiIcons.close,
                          color: t.colorImagePreviewHeader,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(
    SemiResolvedImageThemeData t,
    SemiThemeData global,
    bool showPrev,
    bool showNext,
    bool rtl,
  ) {
    // image.scss:141-208 `-footer`：wrapper `bottom: 16px` 居中；content 高
    // `$height-image_preview_footer`、`$color-image_preview_footer-bg`、
    // `$radius-image_preview_footer`、padding `$spacing-image_preview_footer-paddingY/X`；
    // `preview-footer-disabled` 禁用色 `$color-image_preview_disabled`。
    final props = _p;
    final total = _imgSrc.length;
    final zoomPercent = _zoom * 100;
    final gapLeft = rtl
        // rtl.scss:30 `margin-right: $spacing-image_preview_footer_gap-marginLeft`。
        ? t.spacingImagePreviewFooterGapRtlMarginLeft
        : t.spacingImagePreviewFooterGapMarginLeft;

    Widget icon(
      SemiIconData data,
      VoidCallback? onTap, {
      bool disabled = false,
      bool gap = false,
      double rotate = 0,
      String? tip,
    }) {
      final box = Listener(
        onPointerUp: (_) => _upOnChrome = true,
        onPointerMove: (_) => _moveOnChrome = true,
        onPointerHover: (_) => _moveOnChrome = true,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            // `preview-footer-disabled`（previewFooter.tsx:186）只置
            // `color: $color-image_preview_disabled`（图标着色）+ 禁点击，
            // 无背景 —— 背景色是误加，官方禁用态无色块。
            padding: gap ? EdgeInsetsDirectional.only(start: gapLeft) : null,
            child: SemiIcon(
              data,
              size: SemiIconSize.large,
              rotate: rotate,
              color: disabled
                  ? t.colorImagePreviewDisabled
                  : t.colorImagePreviewFooterIcon,
            ),
          ),
        ),
      );
      if (tip == null || !props.showTooltip) return box;
      // `zIndex={zIndex + 1}` —— footer tooltip 层级 +1（`$z-image_preview`
      // 1070 + 1，插入序表达）。
      return SemiTooltip(
        content: Text(tip),
        zIndex: t.zImagePreview.toInt() + 1,
        child: box,
      );
    }

    // 菜单序（previewFooter.tsx:261-271 getMenu，首项 `getIconChevronLeft`）：
    // `chevronLeft | n/m | chevronRight | − | slider | + | 比例 | 旋转 | 下载`，
    // `menuItems.splice(3, 0` 与 `menuItems.splice(8, 0` 在首插后的列表上定位：
    // 分隔线落位 chevronRight 后与 比例/旋转 之间（下载自带 -gap，无分隔线）。
    final menu = <Widget>[
      icon(
        SemiIcons.chevronLeft,
        () => _handleSwitchImage('prev'),
        disabled: !showPrev,
        // rtl.scss:38 `$transform_rotate-image_preview_icon-rtl`（180°）。
        rotate: rtl ? t.transformRotateImagePreviewIconRtl.degrees : 0,
        tip: props.prevTip ?? '上一张',
      ),
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: t.spacingImagePreviewFooterPageMarginY,
          horizontal: t.spacingImagePreviewFooterPageMarginX,
        ),
        // image.scss:163 `font-size-header-6`。
        child: Text(
          '${_currentIndex + 1}/$total',
          style: TextStyle(
            color: t.colorImagePreviewFooterIcon,
            fontSize: global.typography.fontSizeHeading6,
            height:
                global.typography.lineHeightHeading6 /
                global.typography.fontSizeHeading6,
          ),
        ),
      ),
      icon(
        SemiIcons.chevronRight,
        () => _handleSwitchImage('next'),
        disabled: !showNext,
        rotate: rtl ? t.transformRotateImagePreviewIconRtl.degrees : 0,
        tip: props.nextTip ?? '下一张',
      ),
      _divider(t),
      icon(
        SemiIcons.minus,
        () => _changeSliderValue(false),
        disabled: zoomPercent <= props.minZoom * 100,
        tip: props.zoomOutTip ?? '缩小',
      ),
      _zoomSlider(t),
      icon(
        SemiIcons.plus,
        () => _changeSliderValue(true),
        disabled: zoomPercent >= props.maxZoom * 100,
        tip: props.zoomInTip ?? '放大',
      ),
      icon(
        // `ratio === "adaptation" ? "realSize" : "adaptation"` —— 图标显示
        // 目标模式。
        _ratio == SemiImageRatioType.adaptation
            ? SemiIcons.realSizeStroked
            : SemiIcons.windowAdaptionStroked,
        () => _handleAdjustRatio(
          _ratio == SemiImageRatioType.adaptation
              ? SemiImageRatioType.realSize
              : SemiImageRatioType.adaptation,
        ),
        gap: true,
        tip: _ratio == SemiImageRatioType.adaptation
            ? props.originTip ?? '原始尺寸'
            : props.adaptiveTip ?? '适应页面',
      ),
      _divider(t),
      icon(
        SemiIcons.rotate,
        // `handleRotateLeft` —— footer 恒左旋。
        () => _handleRotateImage('left'),
        tip: props.rotateTip ?? '旋转',
      ),
      icon(
        SemiIcons.download,
        props.disableDownload ? null : _handleDownload,
        disabled: props.disableDownload,
        gap: true,
        tip: props.downloadTip ?? '下载',
      ),
    ];

    if (props.renderPreviewMenu != null) {
      return Listener(
        onPointerUp: (_) => _upOnChrome = true,
        onPointerMove: (_) => _moveOnChrome = true,
        onPointerHover: (_) => _moveOnChrome = true,
        child: props.renderPreviewMenu!(
          SemiImagePreviewMenuProps(
            min: props.minZoom * 100,
            max: props.maxZoom * 100,
            step: props.zoomStep * 100,
            curPage: _currentIndex + 1,
            totalNum: total,
            zoom: zoomPercent,
            ratio: _ratio,
            disabledPrev: !showPrev,
            disabledNext: !showNext,
            disableDownload: props.disableDownload,
            disabledZoomIn: zoomPercent >= props.maxZoom * 100,
            disabledZoomOut: zoomPercent <= props.minZoom * 100,
            onDownload: _handleDownload,
            onNext: () => _handleSwitchImage('next'),
            onPrev: () => _handleSwitchImage('prev'),
            onZoomIn: () => _changeSliderValue(true),
            onZoomOut: () => _changeSliderValue(false),
            onRatioClick: () => _handleAdjustRatio(
              _ratio == SemiImageRatioType.adaptation
                  ? SemiImageRatioType.realSize
                  : SemiImageRatioType.adaptation,
            ),
            onRotateLeft: () => _handleRotateImage('left'),
            onRotateRight: () => _handleRotateImage('right'),
          ),
        ),
      );
    }

    return Listener(
      onPointerUp: (_) => _upOnChrome = true,
      onPointerMove: (_) => _moveOnChrome = true,
      onPointerHover: (_) => _moveOnChrome = true,
      child: Padding(
        // image.scss:157 `bottom: 16px`。
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: t.heightImagePreviewFooter,
          padding: EdgeInsets.symmetric(
            vertical: t.spacingImagePreviewFooterPaddingY,
            horizontal: t.spacingImagePreviewFooterPaddingX,
          ),
          decoration: BoxDecoration(
            color: t.colorImagePreviewFooterBg,
            borderRadius: BorderRadius.circular(t.radiusImagePreviewFooter),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: menu),
        ),
      ),
    );
  }

  Widget _divider(SemiResolvedImageThemeData t) => Container(
    margin: EdgeInsets.symmetric(
      vertical: t.spacingImagePreviewFooterDividerMarginY,
      horizontal: t.spacingImagePreviewFooterDividerMarginX,
    ),
    width: 1,
    height: t.heightImagePreviewFooter / 2,
    color: t.colorImagePreviewDividerBg,
  );

  void _changeSliderValue(bool plus) {
    // previewFooterFoundation.ts:7-16：±step 百分比钳制 [min,max]。
    final zoomPercent = _zoom * 100;
    final step = _p.zoomStep * 100;
    var next = plus ? zoomPercent + step : zoomPercent - step;
    final max = _p.maxZoom * 100;
    final min = _p.minZoom * 100;
    if (next > max) next = max;
    if (next < min) next = min;
    _commitSliderValue(next);
  }

  DateTime _lastSlider = DateTime.fromMillisecondsSinceEpoch(0);

  /// slider 拖动专用（previewFooter.tsx:96 `}, 50)` 节流；± 按钮不节流，
  /// 与 previewFooterFoundation.ts:7-16 `changeSliderValue` 直达一致）。
  void _handleSliderValue(double percent) {
    final now = DateTime.now();
    if (now.difference(_lastSlider).inMilliseconds < 50) return;
    _lastSlider = now;
    _commitSliderValue(percent);
  }

  void _commitSliderValue(double percent) {
    // previewFooterFoundation.ts:18-25 handleValueChange。
    final zoom = _round2(percent / 100);
    if (percent > _zoom * 100) {
      _p.onZoomIn?.call(zoom);
    } else {
      _p.onZoomOut?.call(zoom);
    }
    _handleZoomImage(zoom, notify: false);
  }

  Widget _zoomSlider(SemiResolvedImageThemeData t) {
    // footer zoom slider：`width-image_preview_footer_slider` 132、
    // padding `$spacing-image_preview_footer_slider-paddingY/X`、rail
    // `$color-image_preview_footer_slider_rail` + `$height-image_preview_footer_slider`、
    // handle `$width/height-image_preview_footer_slider_handle` +
    // `$spacing-image_preview_footer_slider_handle-marginTop`；tip `` `${v}%` ``。
    final width = t.widthImagePreviewFooterSlider;
    final trackHeight = t.heightImagePreviewFooterSlider;
    final handleWidth = t.widthImagePreviewFooterSliderHandle;
    final handleHeight = t.heightImagePreviewFooterSliderHandle;
    final min = _p.minZoom * 100;
    final max = _p.maxZoom * 100;
    final percent = (_zoom * 100).clamp(min, max);
    final ratio = max == min ? 0.0 : (percent - min) / (max - min);
    final tip = '$percent%'; // `${v}%`。
    final trackColor = SemiSliderTheme.resolve(context)
        .colorSliderTrackBgDefault;
    final slider = LayoutBuilder(
      builder: (context, constraints) {
        final usable = math.max(1.0, width - handleWidth);
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: t.spacingImagePreviewFooterSliderPaddingX,
            vertical: t.spacingImagePreviewFooterSliderPaddingY,
          ),
          child: SizedBox(
            width: width,
            height:
                handleHeight + t.spacingImagePreviewFooterSliderHandleMarginTop,
            child: Listener(
              onPointerUp: (_) => _upOnChrome = true,
              onPointerMove: (_) => _moveOnChrome = true,
              onPointerHover: (_) => _moveOnChrome = true,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final next =
                      min +
                      (details.localPosition.dx / usable).clamp(0.0, 1.0) *
                          (max - min);
                  _handleSliderValue(next);
                },
                onTapUp: (details) {
                  final next =
                      min +
                      (details.localPosition.dx / usable).clamp(0.0, 1.0) *
                          (max - min);
                  _handleSliderValue(next);
                },
                child: Semantics(
                  slider: true,
                  value: tip,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // rail 全宽（image.scss 只改高度/色；`$width-image_preview_footer_slider`
                      // 132 内容宽）。
                      Container(
                        width: width,
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: t.colorImagePreviewFooterSliderRail,
                          borderRadius: BorderRadius.circular(trackHeight / 2),
                        ),
                      ),
                      // 已走过段（image.scss 未覆盖 track 色，回落 slider 基础
                      // `colorSliderTrackBgDefault` = primary）。
                      Positioned(
                        left: 0,
                        child: Container(
                          width: ratio * usable + handleWidth / 2,
                          height: trackHeight,
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius: BorderRadius.circular(
                              trackHeight / 2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: ratio * usable,
                        top:
                            t.spacingImagePreviewFooterSliderHandleMarginTop /
                            2,
                        child: Container(
                          width: handleWidth,
                          height: handleHeight,
                          decoration: BoxDecoration(
                            color: t.colorImagePreviewFooterIcon,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (!_p.showTooltip) return slider;
    // `zIndex={zIndex + 1}`。
    return SemiTooltip(
      content: Text(tip),
      zIndex: t.zImagePreview.toInt() + 1,
      child: slider,
    );
  }
}

/// `crossMerge`（utils.ts:35-51）：左右交叉合并（右先左后）。
List<T> _crossMerge<T>(List<T> left, List<T> right) {
  final result = <T>[];
  final cross = math.min(left.length, right.length);
  for (var i = 0; i < cross; i++) {
    result.add(right[i]);
    result.add(left[i]);
  }
  if (left.length > right.length) {
    result.addAll(left.sublist(right.length));
  } else if (left.length < right.length) {
    result.addAll(right.sublist(left.length));
  }
  return result;
}

/// 预加载序（utils.ts:52-86 getPreloadImagArr）：当前 ±gap 交叉外扩去重。
List<ImageProvider> _getPreloadImageArr(
  List<ImageProvider> imgSrc,
  int currentIndex,
  int preLoadGap,
  bool infinite,
) {
  final beginIndex = currentIndex - preLoadGap;
  final endIndex = currentIndex + preLoadGap;
  final srcLength = imgSrc.length;
  List<ImageProvider> left = [];
  List<ImageProvider> right = [];
  if (preLoadGap >= (srcLength / 2).floor()) {
    if (infinite) {
      final doubled = [...imgSrc, ...imgSrc];
      left = doubled.sublist(
        math.max(0, beginIndex + srcLength),
        currentIndex + srcLength,
      );
      right = doubled.sublist(
        currentIndex + 1,
        math.min(endIndex + 1, 2 * srcLength),
      );
    } else {
      left = imgSrc.sublist(0, currentIndex);
      right = imgSrc.sublist(currentIndex + 1, srcLength);
    }
  } else {
    if (infinite) {
      final doubled = [...imgSrc, ...imgSrc];
      left = doubled.sublist(beginIndex + srcLength, currentIndex + srcLength);
      right = doubled.sublist(currentIndex + 1, endIndex + 1);
    } else if (beginIndex >= 0 && endIndex < srcLength) {
      left = imgSrc.sublist(beginIndex, currentIndex);
      right = imgSrc.sublist(currentIndex + 1, endIndex + 1);
    } else if (beginIndex < 0) {
      left = imgSrc.sublist(0, currentIndex);
      right = imgSrc.sublist(currentIndex + 1, 2 * preLoadGap + 1);
    } else {
      right = imgSrc.sublist(currentIndex + 1, srcLength);
      left = imgSrc.sublist(srcLength - 2 * preLoadGap - 1, currentIndex);
    }
  }
  final result = _crossMerge(left.reversed.toList(), right);
  return result.toSet().toList();
}
