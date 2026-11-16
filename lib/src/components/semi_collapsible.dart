// SemiCollapsible — 折叠容器（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/collapsible/{variables.scss, animation.scss,
// collapsible.scss, constants.ts, foundation.ts}、
// packages/semi-ui/collapsible/index.tsx。主题对账
// 6 = 0 FIELDS + 6 MOTION + 0 INTERNAL（tool/generate_collapsible.py）——
// ★0 死变量：variables.scss 0 声明（空文件）+ animation.scss 6 声明全被
// collapsible.scss:9-10 `transition:` 简写消费，本文件提及全部 6 个字段名
// （test_generate_collapsible.py 断言零死标 + 全消费）。
// 6 条 MOTION 是活字段（collapsible.scss:1 `@import "./animation.scss"` +
// :9-10 消费，250ms/cubic-bezier(0.25,0.1,0.25,1)/0ms/250ms/ease-in/0ms）。
//
// HARDCODES（另列）上游片段以注释逐字留档在调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_collapsible_theme.dart';
import '../theme/semi_collapsible_theme_data.dart';

/// 折叠容器（上游 `Collapsible`，packages/semi-ui/collapsible/index.tsx）。
///
/// 纯行为组件：[child] 在展开/收起间做高度过渡（可选 `fade` 淡入淡出），
/// 被 Semi 的 Collapse、Tree、Navigation 等复用；也可单独包裹任意内容实现
/// 自定义折叠行为。受控组件——[isOpen] 即唯一状态源（上游无 uncontrolled 形态，
/// `defaultProps.isOpen: false`，index.tsx:43-53）。
///
/// 展开态高度持续跟随内容自然高度（布局期同步测高，无上游 ResizeObserver 的
/// 陈旧高度窗口）；收起态高度为 [collapseHeight]（[collapseHeightAdaptive]
/// 时取 `min(内容高, collapseHeight)`）。内容恒按自然高度顶端排版、底部裁切
/// （上游 wrapper `overflow: 'hidden'` 盒语义）。
class SemiCollapsible extends StatefulWidget {
  const SemiCollapsible({
    super.key,
    this.isOpen = false,
    this.duration,
    this.motion = true,
    this.keepDOM = false,
    this.lazyRender = false,
    this.collapseHeight = 0,
    this.collapseHeightAdaptive = false,
    this.reCalcKey,
    this.fade = false,
    this.onMotionEnd,
    this.child,
  });

  /// 是否展开内容区域（上游 `isOpen`，缺省 false）。
  final bool isOpen;

  /// 动画时长覆盖（上游 `duration: number` 毫秒，缺省 250）；null 取主题
  /// [SemiCollapsibleThemeData.transitionDurationCollapsibleHeight]。
  final Duration? duration;

  /// 是否开启动画（上游 `motion`，缺省 true）；false 瞬切。
  final bool motion;

  /// 收起后保持内容构建（State 不失效），高度裁 0（上游 `keepDOM`，缺省
  /// false——收起动画结束后销毁内容）。
  final bool keepDOM;

  /// 配合 [keepDOM] 使用：true 时首次展开才构建内容（上游 `lazyRender`，
  /// 缺省 false）。keepDOM=false 时该参数无效（上游 `shouldRender` 语义，
  /// index.tsx:216-218）。
  final bool lazyRender;

  /// 收起态高度（上游 `collapseHeight`，缺省 0 = 完全收起）。
  final double collapseHeight;

  /// 内容高度小于 [collapseHeight] 时收起态自适应内容高
  /// （`Math.min(内容高, collapseHeight)`，上游 `collapseHeightAdaptive`，
  /// 缺省 false——收起态恒为 collapseHeight，可高于内容）。
  final bool collapseHeightAdaptive;

  /// 高度重测触发键（上游 `reCalcKey`）。本实现高度持续跟随内容（变化天然
  /// 重测），改变只触发重建（保留 API 对齐）。
  final Object? reCalcKey;

  /// 淡入淡出（上游 `fade`，缺省 false）。仅 [collapseHeight] == 0 时生效
  /// （上游 opacity 公式 `(isOpen || !fade || collapseHeight !== 0) ? 1 : 0`，
  /// index.tsx:208）。
  final bool fade;

  /// 动画结束回调（上游 `onMotionEnd`）：展开、收起动画结束都会触发；
  /// [motion] 为 false 或系统关闭动画时不触发（上游 `isTransitioning` 语义）。
  final VoidCallback? onMotionEnd;

  /// 内容（上游 `children`）。
  final Widget? child;

  @override
  State<SemiCollapsible> createState() => _SemiCollapsibleState();
}

class _SemiCollapsibleState extends State<SemiCollapsible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late SemiResolvedCollapsibleThemeData _theme;
  bool _initialized = false;
  bool _lastOpen = false;
  bool _transitioning = false;
  bool _hasBeenRendered = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = SemiCollapsibleTheme.resolve(context);
    _controller.duration =
        widget.duration ?? _theme.transitionDurationCollapsibleHeight;
    _syncOpen();
  }

  bool get _animationsEnabled =>
      widget.motion &&
      TickerMode.valuesOf(context).enabled &&
      !MediaQuery.disableAnimationsOf(context);

  void _syncOpen() {
    if (!_initialized) {
      // 初始渲染无入场动画（上游 wrapper 高度直接落位、transition 未武装，
      // 与 SemiCollapse 移植同口径）。
      _initialized = true;
      _lastOpen = widget.isOpen;
      _controller.value = widget.isOpen ? 1 : 0;
      return;
    }
    final open = widget.isOpen;
    if (open == _lastOpen) return;
    _lastOpen = open;
    // 上游 getDerivedStateFromProps（index.tsx:130-141）：展开（或 motion
    // 关闭）时 visible 立即落位、收起动画期间内容保持构建——visible 由控制器
    // 状态派生（`!_controller.isDismissed`），故此处只驱动过渡。
    if (_animationsEnabled) {
      _transitioning = true;
      if (open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else {
      _controller.value = open ? 1 : 0;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward ||
        status == AnimationStatus.reverse) {
      return;
    }
    // 上游 handleMotionEnd（index.tsx:170-179）：transitionend（守卫
    // `event.propertyName === 'height'`，index.tsx:230）或兜底定时器先到者
    // 结算——收起结束丢弃内容，展开/收起结束都回调 onMotionEnd。移植由控制器
    // 结算状态驱动（`duration + 50` 兜底定时器被 dismissed/completed 状态取代）。
    final wasTransitioning = _transitioning;
    _transitioning = false;
    if (wasTransitioning) {
      widget.onMotionEnd?.call();
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(SemiCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration =
          widget.duration ?? _theme.transitionDurationCollapsibleHeight;
    }
    if (oldWidget.isOpen != widget.isOpen) {
      _syncOpen();
    }
    if (oldWidget.reCalcKey != widget.reCalcKey) {
      // 内容高度由布局持续跟随，reCalcKey 变化只需重建（保留 API 对齐）。
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 上游 shouldRender（index.tsx:216-221）：
    // (keepDOM && (lazyRender ? hasBeenRendered : true)) ||
    // collapseHeight !== 0 || visible || isOpen。
    // visible ≙ 动画未结算（`!_controller.isDismissed`）。
    final shouldRender =
        (widget.keepDOM && (widget.lazyRender ? _hasBeenRendered : true)) ||
        widget.collapseHeight != 0 ||
        !_controller.isDismissed ||
        widget.isOpen;
    if (shouldRender && !_hasBeenRendered) {
      _hasBeenRendered = true;
    }
    final content = shouldRender ? widget.child : null;

    return AnimatedBuilder(
      animation: _controller,
      child: content,
      builder: (context, child) {
        final t = _controller.value;
        final heightT = _theme.transitionFunctionCollapsibleHeight.transform(t);
        // 上游 opacity 公式（index.tsx:208）：仅 fade 且 collapseHeight == 0
        // 时透明度随过渡走 0↔1（曲线
        // transitionFunctionCollapsibleOpacity = ease-in，时长同 `duration`；
        // transitionDurationCollapsibleOpacity 是 CSS 回退默认）；
        // transitionDelayCollapsibleHeight / transitionDelayCollapsibleOpacity
        // 均为 0ms（var(--semi-transition_delay-none)）——控制器无延迟槽，注释
        // 引用留档。
        final opacity = widget.fade && widget.collapseHeight == 0
            ? _theme.transitionFunctionCollapsibleOpacity.transform(t)
            : 1.0;
        return Opacity(
          opacity: opacity,
          child: _CollapsibleClip(
            t: heightT,
            collapseHeight: widget.collapseHeight,
            collapseHeightAdaptive: widget.collapseHeightAdaptive,
            child: child,
          ),
        );
      },
    );
  }
}

/// 上游 wrapper 裁切盒（`overflow: 'hidden'`，index.tsx:205 包装盒 + :239
/// inner div 同款）：内容恒按自然高度顶端排版，可见高度随动画系数插值
/// （收起 [collapseHeight] ↔ 展开内容高），底部裁切。
///
/// 上游经 `ResizeObserver`（index.tsx:55/:121）测内容高、
/// `Math.ceil(entry.borderBoxSize[0].blockSize)`（index.tsx:108）取整，
/// 且首测前有 `height: 'auto'` + `maxHeight` 夹取的 unmeasured 窗口
/// （index.tsx:200-207）；本实现在布局期同步量高——天然精确、无陈旧缓存高，
/// 该窗口不复存在。
class _CollapsibleClip extends SingleChildRenderObjectWidget {
  const _CollapsibleClip({
    required this.t,
    required this.collapseHeight,
    required this.collapseHeightAdaptive,
    super.child,
  });

  /// 已过主题曲线的展开系数（0 = 收起，1 = 展开）。
  final double t;

  /// 收起态高度（0 = 完全收起）。
  final double collapseHeight;

  /// 收起态高度是否对矮内容自适应（`Math.min(内容高, collapseHeight)`）。
  final bool collapseHeightAdaptive;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _CollapsibleClipBox(t, collapseHeight, collapseHeightAdaptive);

  @override
  void updateRenderObject(
    BuildContext context,
    _CollapsibleClipBox renderObject,
  ) {
    renderObject
      ..t = t
      ..collapseHeight = collapseHeight
      ..collapseHeightAdaptive = collapseHeightAdaptive;
  }
}

class _CollapsibleClipBox extends RenderProxyBox {
  _CollapsibleClipBox(
    this._t,
    this._collapseHeight,
    this._collapseHeightAdaptive,
  );

  double _t;
  double _collapseHeight;
  bool _collapseHeightAdaptive;

  set t(double value) {
    if (_t == value) return;
    _t = value;
    markNeedsLayout();
  }

  set collapseHeight(double value) {
    if (_collapseHeight == value) return;
    _collapseHeight = value;
    markNeedsLayout();
  }

  set collapseHeightAdaptive(bool value) {
    if (_collapseHeightAdaptive == value) return;
    _collapseHeightAdaptive = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      // shouldRender=false ⇒ collapseHeight == 0（上游公式），空盒零高。
      size = constraints.smallest;
      return;
    }
    // 内容按自然高度排版（高度不受裁切盒约束），宽度照 block 语义铺满可用宽
    // （无界宽时收缩内容宽——Align 收缩换行先例）。
    child.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );
    final contentHeight = child.size.height;
    final collapsed = _collapseHeightAdaptive
        ? math.min(contentHeight, _collapseHeight)
        : _collapseHeight;
    final visible = collapsed + (contentHeight - collapsed) * _t;
    size = constraints.constrain(
      Size(
        constraints.hasBoundedWidth ? constraints.maxWidth : child.size.width,
        visible,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
    );
  }
}
