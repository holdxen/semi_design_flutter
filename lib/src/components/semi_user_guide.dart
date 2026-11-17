// SemiUserGuide — 用户引导（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/userGuide/{variables.scss, animation.scss,
// userGuide.scss, foundation.ts, constants.ts}、
// packages/semi-ui/userGuide/index.tsx。主题对账
// 37 = 35 FIELDS + 2 MOTION + 0 INTERNAL（tool/generate_user_guide.py）——1 条
// 死 FIELDS（上游未消费）本文件不得出现其字段名（test_generate_user_guide.py
// 断言）：`$font-userGuide_popup_content_indicator-fontSize`（userGuide.scss:77
// 直写 `font-size: $font-size-regular` 顶替——本文件按 HARDCODE 实消费字号但
// 不得引用该字段名）。2 条 MOTION 是活字段（userGuide.scss:2
// `@import "./animation.scss"` + :22 `transition: all ...` 消费——聚光灯洞口
// 200ms/cubic-bezier(0.4, 0, 0.2, 1) 补间）。
//
// 结构（index.tsx render）：`mode: 'popup'`（缺省）= 当前步 Popover 卡
// （trigger custom 锚定聚光灯 padded 矩形）+ SVG 遮罩挖洞聚光灯；`mode:
// 'modal'` = 壳体走 SemiModal（feedback 先例）+ 自定义内容列。值模型：
// `current`（非 null 即受控——上游 `'current' in props` 显式 null 受控无对应，
// treeSelect 先例）+ `steps` 步进列表。回调：`onChange(current)` 仅值变化时发
// （foundation.ts:23-28 `_notifyChange`）、`onPrev/onNext(current)` 步进即发、
// `onSkip` 仅通知（不关显隐——visible 受控在使用方）、`onFinish` 末步 next 发
// （foundation.ts:68-76）。★`handlePrev` 不 clamp（负值可入——按钮在首步隐藏
// 使 UI 不可达，越界 `steps[current]` 上游 TypeError、本移植防御性跳过渲染）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_UserGuideMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_button_theme.dart';
import '../theme/semi_button_theme_data.dart';
import '../theme/semi_popover_theme.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_tooltip_theme.dart';
import '../theme/semi_tooltip_theme_data.dart';
import '../theme/semi_user_guide_theme.dart';
import '../theme/semi_user_guide_theme_data.dart';
import 'semi_button.dart';
import 'semi_modal.dart';
import 'semi_tooltip.dart';

/// 引导模式（上游 `strings.MODE: ['popup', 'modal']`，constants.ts:15）。
enum SemiUserGuideMode { popup, modal }

/// 步进主题（上游 `strings.THEME: ['default', 'primary']`，constants.ts:24；
/// `default` 是 Dart 保留字 → `defaultTheme`）。
enum SemiUserGuideThemeMode { defaultTheme, primary }

/// 上游 `nextButtonProps`/`prevButtonProps`（ButtonProps）的局部展开——只保留
/// `children`/`onClick` 两槽（差异清单：完整 ButtonProps 展开不移植）。
@immutable
class SemiUserGuideButtonProps {
  const SemiUserGuideButtonProps({this.child, this.onPressed});

  /// 按钮文案（覆盖 locale 缺省）。
  final Widget? child;

  /// 点击处理（覆盖内置 handlePrev/handleNext——上游 `{...prevButtonProps}`
  /// 在 onClick 之后展开，props.onClick 顶替）。
  final VoidCallback? onPressed;
}

/// 引导步骤（上游 `StepItem`，index.tsx:55-65）。
@immutable
class SemiUserGuideStep {
  const SemiUserGuideStep({
    this.target,
    this.cover,
    this.title,
    this.description,
    this.mask,
    this.showArrow,
    this.spotlightPadding,
    this.theme,
    this.position,
  });

  /// 目标 id（引用 [SemiUserGuideTarget] 注册表；上游
  /// `target?: (() => Element) | Element` —— Flutter 无 DOM 元素引用，
  /// anchor `SemiAnchorTarget` 注册先例，见差异清单）。
  final String? target;

  /// 封面（上游 `cover?: ReactNode`；popup 模式 img 语义 → 定高盒，
  /// modal 模式同定高盒）。
  final Widget? cover;

  /// 标题：String | Widget。
  final Object? title;

  /// 详情：String | Widget。
  final Object? description;

  /// 步蒙层优先（`step.mask ?? mask`，index.tsx:440/:543）。
  final bool? mask;

  /// 卡片箭头（缺省 true——上游 `showArrow={step.showArrow !== false}`）。
  final bool? showArrow;

  /// 步聚光灯内边距（优先于全局 [SemiUserGuide.spotlightPadding]；★0 照消费
  /// ——zero-padding 测试：`typeof stepPadding === 'number'` 口径）。
  final double? spotlightPadding;

  /// 步主题（覆盖全局 [SemiUserGuide.theme]；★modal 模式不消费——差异清单）。
  final SemiUserGuideThemeMode? theme;

  /// 卡片位置（覆盖全局 [SemiUserGuide.position]）。
  final SemiTooltipPosition? position;
}

/// 目标注册（上游 `step.target` 的 DOM 元素引用——Flutter 无 DOM，显式注册
/// RenderBox；anchor `SemiAnchorTarget` 先例）。
///
/// [id] 与 [SemiUserGuideStep.target] 对齐；重复 id 取首注册（DOM 顺序首匹配
/// 同口径）。
class SemiUserGuideTarget extends StatefulWidget {
  const SemiUserGuideTarget({super.key, required this.id, required this.child});

  /// 目标 id。
  final String id;

  final Widget child;

  @override
  State<SemiUserGuideTarget> createState() => _SemiUserGuideTargetState();
}

class _SemiUserGuideTargetState extends State<SemiUserGuideTarget> {
  /// 上游 `step.target` 是树内元素引用；注册表全局同口径（目标通常与引导
  /// 平级、不在其子树内；重复 id 取首个注册）。
  static final Map<String, List<_SemiUserGuideTargetState>> registry = {};

  @override
  void initState() {
    super.initState();
    registry.putIfAbsent(widget.id, () => []).add(this);
  }

  @override
  void didUpdateWidget(covariant SemiUserGuideTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _unregister(oldWidget.id);
      registry.putIfAbsent(widget.id, () => []).add(this);
    }
  }

  @override
  void dispose() {
    _unregister(widget.id);
    super.dispose();
  }

  void _unregister(String id) {
    final targets = registry[id];
    if (targets == null) return;
    targets.remove(this);
    if (targets.isEmpty) registry.remove(id);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 用户引导。
///
/// `mode: 'popup'`（缺省）：当前步卡片经 [SemiTooltip]（popupBare + popover
/// 表面）锚定到聚光灯 padded 矩形，蒙层 SVG 挖洞等价为 Path 差值涂色 + 四条
/// 透明捕获条（洞口点击穿到目标）。`mode: 'modal'`：[SemiModal] 壳体 +
/// 自定义内容列（cover/指示点/正文/按钮行）。visible 为 false 或 steps 为空
/// 时整棵不渲染（index.tsx:583-585）。
class SemiUserGuide extends StatefulWidget {
  const SemiUserGuide({
    super.key,
    this.current,
    this.finishText,
    this.skipText,
    this.prevText,
    this.nextText,
    this.mask = true,
    this.mode = SemiUserGuideMode.popup,
    this.nextButtonProps,
    this.onChange,
    this.onFinish,
    this.onNext,
    this.onPrev,
    this.onSkip,
    this.position = SemiTooltipPosition.bottom,
    this.prevButtonProps,
    this.showPrevButton = true,
    this.showSkipButton = true,
    this.spotlightPadding,
    this.steps = const <SemiUserGuideStep>[],
    this.theme = SemiUserGuideThemeMode.defaultTheme,
    this.visible = false,
    this.zIndex = _UserGuideMetrics.defaultZIndex,
  });

  /// 受控当前步（非 null 即受控——上游 `_isInProps('current')` 的显式 null
  /// 受控无对应；null 时非受控，步进自管）。
  final int? current;

  /// 末步按钮文案（缺省「完成」，上游 `finishText` + locale `finish`）。
  final String? finishText;

  /// 跳过按钮文案（缺省「跳过」，上游 locale `skip`——必要新增参数，locale
  /// 无 Flutter 对应；popconfirm `okText` 先例）。
  final String? skipText;

  /// 上一步按钮文案（缺省「上一步」；[SemiUserGuideButtonProps.child] 优先）。
  final String? prevText;

  /// 下一步按钮文案（缺省「下一步」；[SemiUserGuideButtonProps.child] 优先）。
  final String? nextText;

  /// 蒙层显隐（`step.mask` 优先，index.tsx:440/:543）。
  final bool mask;

  /// 引导模式（上游 `mode: 'popup'`）。
  final SemiUserGuideMode mode;

  /// 下一步按钮 props（children/onClick 两槽）。
  final SemiUserGuideButtonProps? nextButtonProps;

  /// 当前步变化回传（★仅值变化时发——foundation.ts:23-28）。
  final ValueChanged<int>? onChange;

  /// 末步 next 回传（foundation.ts:68-70）。
  final VoidCallback? onFinish;

  /// 下一步回传（foundation.ts:72-78）。
  final ValueChanged<int>? onNext;

  /// 上一步回传（foundation.ts:56-65）。
  final ValueChanged<int>? onPrev;

  /// 跳过回传（foundation.ts:80-82；★仅通知、不改显隐）。
  final VoidCallback? onSkip;

  /// 卡片位置（上游 `position: 'bottom'`）。
  final SemiTooltipPosition position;

  /// 上一步按钮 props（children/onClick 两槽）。
  final SemiUserGuideButtonProps? prevButtonProps;

  /// 显示上一步按钮（上游 `showPrevButton: true`；首步恒不显）。
  final bool showPrevButton;

  /// 显示跳过按钮（上游 `showSkipButton: true`；末步恒不显）。
  final bool showSkipButton;

  /// 全局聚光灯内边距（`step.spotlightPadding` 优先；缺省
  /// `DEFAULT_SPOTLIGHT_PADDING`）。
  final double? spotlightPadding;

  /// 步进列表（上游 `steps: []`）。
  final List<SemiUserGuideStep> steps;

  /// 主题（上游 `theme: 'default'`；★modal 模式不消费——差异清单）。
  final SemiUserGuideThemeMode theme;

  /// 显隐（上游 `visible: false`；false 或 steps 空时整棵不渲染）。
  final bool visible;

  /// 提升层级（上游 `DEFAULT_Z_INDEX`——overlay 插入序即层序，parity 参数，
  /// SemiPopover.zIndex 同口径）。
  final int zIndex;

  /// 聚光灯蒙层（测试度量锚点）。
  static const Key spotlightMaskKey = ValueKey('SemiUserGuideSpotlightMask');

  /// 聚光灯卡片锚点盒（测试度量锚点——即上游 fixed 锚 div）。
  static const Key spotlightAnchorKey = ValueKey(
    'SemiUserGuideSpotlightAnchor',
  );

  /// popup 卡片（测试度量锚点）。
  static const Key popupCardKey = ValueKey('SemiUserGuidePopupCard');

  /// popup 指示器文案（测试断言锚点）。
  static const Key indicatorKey = ValueKey('SemiUserGuideIndicator');

  /// modal 指示点行（测试度量锚点）。
  static const Key modalIndicatorKey = ValueKey('SemiUserGuideModalIndicator');

  @override
  State<SemiUserGuide> createState() => _SemiUserGuideState();
}

class _SemiUserGuideState extends State<SemiUserGuide>
    with WidgetsBindingObserver {
  /// 上游 state.current（`props.current || DEFAULT_CURRENT`——index.tsx:111）。
  int _current = _UserGuideMetrics.defaultCurrent;

  /// 聚光灯 padded 矩形（上游 state.spotlightRect——目标矩形外扩 padding）。
  Rect? _spotlightRect;

  CapturedThemes? _captured;
  OverlayEntry? _entry;

  /// 目标祖先滚动位（窗口 scroll 捕获的 Flutter 对应——任一祖先滚动即重测）。
  final Set<ScrollPosition> _boundPositions = {};

  bool _disposed = false;

  bool get _active => widget.visible && widget.steps.isNotEmpty;

  /// 上游 `getIsControlledComponent`（foundation.ts:35-37 `_isInProps('current')`
  /// ——本移植「非 null 即受控」口径）。
  bool get _isControlled => widget.current != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _current = widget.current ?? _UserGuideMetrics.defaultCurrent;
    _schedulePostFrame(() {
      _syncMode();
      // componentDidMount：updateSpotlightRect(true)（index.tsx:157）。
      _updateSpotlight(scrollIntoView: true);
    });
  }

  @override
  void didUpdateWidget(covariant SemiUserGuide oldWidget) {
    super.didUpdateWidget(oldWidget);
    // getDerivedStateFromProps（index.tsx:141-147）：受控 current 同步。
    if (widget.current != null && widget.current != _current) {
      _current = widget.current!;
    }
    final wasActive = oldWidget.visible && oldWidget.steps.isNotEmpty;
    if (!wasActive && _active) {
      // componentDidUpdate 开档（:181-184）：beforeShow + current 归零
      // （`setState({ current: 0 })` + 受控 derived 覆写 = `current ?? 0`）。
      _current = widget.current ?? _UserGuideMetrics.defaultCurrent;
    }
    _schedulePostFrame(() {
      _syncMode();
      // componentDidUpdate（:190）：新开档或 current 变化时滚入视口。
      _updateSpotlight(
        scrollIntoView:
            !wasActive && _active || oldWidget.current != widget.current,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedulePostFrame(() => _updateSpotlight(scrollIntoView: false));
  }

  @override
  void didChangeMetrics() {
    // window resize（index.tsx:152 `resize` → handleLayoutChange）。
    _schedulePostFrame(() => _updateSpotlight(scrollIntoView: false));
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _unbindAll();
    _removeEntry();
    super.dispose();
  }

  /// build 相位禁止改 overlay/setState——统一延后（semi_tooltip.dart 先例）。
  void _schedulePostFrame(void Function() fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) fn();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  // -- overlay（popup 模式）-------------------------------------------------

  /// popup 模式挂/卸自管 overlay（蒙层 + 锚点）；modal 模式由 build 承载
  /// [SemiModal]。上游 getPopupContainer 的 portal 容器选择不移植（差异清单）
  /// ——统一入根 Overlay，蒙层条目先插（mask 在卡之下，index.tsx:397/:436
  /// `zIndex: zIndex - 1` 语义）。
  void _syncMode() {
    final want = _active && widget.mode == SemiUserGuideMode.popup;
    if (want && _entry == null) {
      _captured = InheritedTheme.capture(
        from: context,
        to: Overlay.of(context).context,
      );
      _entry = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context).insert(_entry!);
    } else if (!want && _entry != null) {
      _removeEntry();
    } else {
      _entry?.markNeedsBuild();
    }
    if (!_active) _unbindAll();
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
    _captured = null;
  }

  Widget _buildOverlay(BuildContext entryContext) {
    final t = SemiUserGuideTheme.resolve(entryContext);
    final global = SemiTheme.of(entryContext);
    final rect = _spotlightRect;
    // index.tsx:426-430：renderSpotlight 仅在 step.target 存在且
    // spotlightRect 已测得时出图（`if (!step.target) return null`）；蒙层/
    // 捕获条只在 `step.mask ?? mask` 时渲染。★target 缺位时旧矩形留在 state
    // 但整棵不出（上游同口径）。
    final step = _currentStep;
    final targetStep = (step != null && step.target != null) ? step : null;
    final showMask = targetStep != null && (targetStep.mask ?? widget.mask);
    final stackChildren = <Widget>[
      if (rect != null && targetStep != null) ...[
        if (showMask) ...[
          // SVG mask 挖洞（index.tsx:437-459）：`fill="white"` 底 + `fill="black"`
          // 洞（`rx={4}`）→ 白显黑挖；等价 Path 差值涂 `overlay-bg` 色。
          IgnorePointer(
            child: TweenAnimationBuilder<Rect>(
              // `&-spotlight-rect { transition: all ... }`（userGuide.scss:22）
              // ——洞口矩形补间；四条捕获条按未补间矩形即时落位（上游仅
              // `-spotlight-rect` 带 transition 类）。
              tween: Tween<Rect>(begin: rect, end: rect),
              duration: t.transitionDurationUserGuideSpotLight,
              curve: t.transitionFunctionUserGuideSpotLight,
              builder: (context, hole, _) => CustomPaint(
                key: SemiUserGuide.spotlightMaskKey,
                size: MediaQuery.sizeOf(context),
                painter: _SpotlightMaskPainter(
                  hole: hole,
                  holeRadius: _UserGuideMetrics.holeRadius,
                  // fill="var(--semi-color-overlay-bg)"（index.tsx:457）——
                  // 实时引用 live token（generate_cropper.py 先例）。
                  color: global.colors.colorOverlayBg,
                ),
              ),
            ),
          ),
          // 四条 `fill="transparent"` 捕获条（index.tsx:461-488；
          // `pointer-events: auto`——蒙层区吞点击，洞口穿透）。
          ..._captureStrips(rect),
        ],
        // 上游 fixed 锚 div（index.tsx:362-372）：聚光灯 padded 矩形、
        // `pointer-events: none`。
        Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: IgnorePointer(
            child: SizedBox.expand(
              key: SemiUserGuide.spotlightAnchorKey,
              child: _buildCard(targetStep, t),
            ),
          ),
        ),
      ],
    ];
    return _captured!.wrap(
      Stack(fit: StackFit.expand, children: stackChildren),
    );
  }

  /// 上游四条透明捕获条几何（index.tsx:461-488）：上/左/右/下条环绕洞口。
  List<Widget> _captureStrips(Rect rect) {
    Widget strip(double l, double t, double w, double h) => Positioned(
      left: l,
      top: t,
      width: w < 0 ? 0 : w,
      height: h < 0 ? 0 : h,
      child: const Listener(
        // `pointer-events: auto`（userGuide.scss:18）——吞点击不透传。
        behavior: HitTestBehavior.opaque,
        onPointerDown: _swallowPointer,
      ),
    );
    final size = MediaQuery.sizeOf(context);
    return [
      strip(0, 0, size.width, rect.top),
      strip(0, rect.top, rect.left, rect.height),
      strip(rect.right, rect.top, size.width - rect.right, rect.height),
      strip(0, rect.bottom, size.width, size.height - rect.bottom),
    ];
  }

  static void _swallowPointer(PointerDownEvent _) {}

  // -- 卡片（popup 模式）----------------------------------------------------

  /// 卡片壳（SemiTooltip popupBare + 自绘 popover 表面——`padding: 0` +
  /// `max-width: fit-content` + width 400 覆写；primary 主题 bg 覆色）。
  Widget _buildCard(SemiUserGuideStep step, SemiResolvedUserGuideThemeData t) {
    final pop = SemiPopoverTheme.resolve(context);
    final global = SemiTheme.of(context);
    final isPrimary = _isPrimary(step);
    final showArrow = step.showArrow ?? true;
    return SemiTooltipTheme(
      // popover 作用域变量遮蔽的本地等价（semi_popover.dart 先例）：箭头几何 +
      // zoomIn/zoomOut 动效取 popover 值。
      data: SemiTooltipThemeData(
        heightTooltipArrow: pop.heightTooltipArrow,
        widthTooltipArrow: pop.widthTooltipArrow,
        heightTooltipArrowVertical: pop.heightTooltipArrowVertical,
        widthTooltipArrowVertical: pop.widthTooltipArrowVertical,
        arrowAdjustedOffsetY: pop.spacingTooltipArrowAdjustedOffsetY,
        arrowAdjustedOffsetX: pop.spacingTooltipArrowAdjustedOffsetX,
        animationDurationIn: pop.animationDurationPopoverIn,
        animationDurationOut: pop.animationDurationPopoverOut,
        animationFunctionIn: pop.animationFunctionPopoverIn,
        animationFunctionOut: pop.animationFunctionPopoverOut,
      ),
      child: SemiTooltip(
        content: _buildPopupContent(step, t),
        trigger: SemiTooltipTrigger.custom,
        visible: true,
        position: step.position ?? widget.position,
        showArrow: showArrow,
        popupBare: true,
        autoAdjustOverflow: true,
        // popover 常量（popover/constants.ts:42-43）：`SPACING: 4` /
        // `SPACING_WITH_ARROW: 10`。
        spacing: showArrow
            ? _UserGuideMetrics.popoverSpacingWithArrow
            : _UserGuideMetrics.popoverSpacing,
        // popover 族小触发器校正常量（popover/constants.ts:36-39
        // `ARROW_BOUNDING: { offsetY: 6 }`）。
        arrowBoundingOffsetY: _UserGuideMetrics.popoverArrowBoundingOffsetY,
        motion: true,
        zIndex: widget.zIndex,
        // index.tsx:369 `rePosKey={JSON.stringify(this.state.spotlightRect)}`。
        repositionKey: _spotlightRect,
        // Arrow.tsx `get(arrowStyle, 'backgroundColor', get(popStyle,
        // 'backgroundColor'))` ——popStyle 内联覆色或 popover 箭头缺省色。
        arrowColor: isPrimary
            ? global.colors.colorPrimary
            : pop.colorPopoverArrowBg,
        arrowFringeColor: pop.colorPopoverArrowBorder,
        child: const SizedBox.expand(),
      ),
    );
  }

  /// popup 卡内容（index.tsx:219-335 `renderPopupContent`）。
  Widget _buildPopupContent(
    SemiUserGuideStep step,
    SemiResolvedUserGuideThemeData t,
  ) {
    final index = _current;
    final isFirst = index == 0;
    final isLast = index == widget.steps.length - 1;
    final isPrimary = _isPrimary(step);
    final rootColor = isPrimary
        ? t.colorUserGuidePopupTextPrimary
        : t.colorUserGuidePopupTextDefault;
    final skipLabel = widget.skipText ?? _UserGuideMetrics.skipLabel;
    final prevLabel =
        widget.prevButtonProps?.child ??
        Text(widget.prevText ?? _UserGuideMetrics.prevLabel);
    final nextLabel = isLast
        ? Text(widget.finishText ?? _UserGuideMetrics.finishLabel)
        : (widget.nextButtonProps?.child ??
              Text(widget.nextText ?? _UserGuideMetrics.nextLabel));
    return DefaultTextStyle.merge(
      style: TextStyle(color: rootColor),
      child: DecoratedBox(
        key: SemiUserGuide.popupCardKey,
        // 弹层表面借 popover/variables.scss 实时引用（autocomplete 先例）：
        // `$color-popover-bg-default` + `$radius-popover` +
        // `@include shadow-elevated`。index.tsx:350-355
        // `basePopoverStyle = { padding: 0 }` + `primaryStyle = { backgroundColor:
        // 'var(--semi-color-primary)' }`；`.semi-userGuide-popover`
        // （userGuide.scss:25-28）`width: $width-userGuide_popover-default` +
        // `max-width: fit-content`。
        decoration: BoxDecoration(
          color: isPrimary
              ? SemiTheme.of(context).colors.colorPrimary
              : SemiPopoverTheme.resolve(context).colorPopoverBgDefault,
          borderRadius: BorderRadius.circular(
            SemiPopoverTheme.resolve(context).radiusPopover,
          ),
          boxShadow: SemiTheme.of(context).shadows.shadowElevated
              .toBoxShadows(),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: t.widthUserGuidePopoverDefault),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (step.cover != null)
                  ClipRRect(
                    // userGuide.scss:38-43 img：`display: block` +
                    // `height: $height-userGuide_popup_content_cover-default` +
                    // `width: 100%` + `$radius-userGuide_popup_content_cover`。
                    borderRadius: t.radiusUserGuidePopupContentCover,
                    child: SizedBox(
                      height: t.heightUserGuidePopupContentCoverDefault,
                      width: double.infinity,
                      child: step.cover,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(
                    t.spacingUserGuidePopupContentBodyPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (step.title != null)
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom:
                                t.spacingUserGuidePopupContentTitleMarginBottom,
                          ),
                          child: _styled(
                            step.title,
                            fontSize: t.fontUserGuidePopupContentTitleFontSize,
                            fontWeight:
                                t.fontUserGuidePopupContentTitleFontWeight,
                            lineHeight:
                                t.fontUserGuidePopupContentTitleLineHeight,
                          ),
                        ),
                      if (step.description != null)
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: t
                                .spacingUserGuidePopupContentDescriptionMarginBottom,
                          ),
                          child: _styled(
                            step.description,
                            fontSize:
                                t.fontUserGuidePopupContentDescriptionFontSize,
                            fontWeight: null,
                            lineHeight: t
                                .fontUserGuidePopupContentDescriptionLineHeight,
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.steps.length > 1)
                            // userGuide.scss:75-78 `&-indicator`——★字号直写
                            // `font-size: $font-size-regular`（顶替死变量）。
                            Text(
                              '${index + 1}/${widget.steps.length}',
                              key: SemiUserGuide.indicatorKey,
                              style: TextStyle(
                                fontSize: _UserGuideMetrics.fontSizeRegular,
                                height:
                                    t.fontUserGuidePopupContentIndicatorLineHeight /
                                    _UserGuideMetrics.fontSizeRegular,
                              ),
                            ),
                          Padding(
                            // userGuide.scss:53 `margin-left:
                            // $spacing-userGuide_popup_content_button-marginLeft`。
                            padding: EdgeInsetsDirectional.only(
                              start: t
                                  .spacingUserGuidePopupContentButtonMarginLeft,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: _withGaps([
                                if (widget.showSkipButton && !isLast)
                                  _guideButton(
                                    label: Text(skipLabel),
                                    type: isPrimary
                                        ? SemiButtonType.primary
                                        : SemiButtonType.tertiary,
                                    variant: isPrimary
                                        ? SemiButtonVariant.solid
                                        : SemiButtonVariant.light,
                                    // index.tsx:301/311 `style={isPrimaryTheme
                                    // ? { backgroundColor:
                                    // 'var(--semi-color-fill-2)' } : {}}`。
                                    bg: isPrimary
                                        ? SemiTheme.of(context)
                                              .colors
                                              .colorFill2
                                        : null,
                                    onPressed: _handleSkip,
                                  ),
                                if (widget.showPrevButton && !isFirst)
                                  _guideButton(
                                    label: prevLabel,
                                    type: isPrimary
                                        ? SemiButtonType.primary
                                        : SemiButtonType.tertiary,
                                    variant: isPrimary
                                        ? SemiButtonVariant.solid
                                        : SemiButtonVariant.light,
                                    bg: isPrimary
                                        ? SemiTheme.of(context)
                                              .colors
                                              .colorFill2
                                        : null,
                                    onPressed:
                                        widget.prevButtonProps?.onPressed ??
                                        _handlePrev,
                                  ),
                                _guideButton(
                                  label: nextLabel,
                                  type: SemiButtonType.primary,
                                  variant: isPrimary
                                      ? SemiButtonVariant.borderless
                                      : SemiButtonVariant.solid,
                                  // index.tsx:321 `style={isPrimaryTheme
                                  // ? { backgroundColor: '#FFF' } : {}}`。
                                  bg: isPrimary
                                      ? const Color(0xFFFFFFFF)
                                      : null,
                                  onPressed:
                                      widget.nextButtonProps?.onPressed ??
                                      _handleNext,
                                ),
                              ], t.spacingUserGuidePopupContentButtonGap),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- 卡片（modal 模式）----------------------------------------------------

  /// modal 模式（index.tsx:501-577 `renderModal`）——壳体走 [SemiModal]。
  Widget _buildModal(SemiResolvedUserGuideThemeData t) {
    final step = _currentStep!;
    final index = _current;
    final isFirst = index == 0;
    final isLast = index == widget.steps.length - 1;
    final skipLabel = widget.skipText ?? _UserGuideMetrics.skipLabel;
    final prevLabel =
        widget.prevButtonProps?.child ??
        Text(widget.prevText ?? _UserGuideMetrics.prevLabel);
    final nextLabel = isLast
        ? Text(widget.finishText ?? _UserGuideMetrics.finishLabel)
        : (widget.nextButtonProps?.child ??
              Text(widget.nextText ?? _UserGuideMetrics.nextLabel));
    return SemiModal(
      visible: true,
      // 上游 `header={null}` / `footer={null}`（'x' in props 显式空——无 header
      // 行、body 直通、无 closer、无 footer 节点）。
      header: const SemiModalEmptySlot(),
      footer: const SemiModalEmptySlot(),
      // userGuide.scss:83-92 `.#{$prefix}-modal-content` 覆写：`padding: 0` +
      // `width: $width-userGuide_modal_content_cover-default`（★cover 宽 token
      // 由 modal-content 消费——命名错位）+ `max-width: fit-content`；
      // :84-86 `.#{$prefix}-modal-small { width: fit-content; }`。
      contentPadding: EdgeInsets.zero,
      width: t.widthUserGuideModalContentCoverDefault,
      size: SemiModalSize.small,
      centered: true,
      maskClosable: false,
      closable: false,
      mask: step.mask ?? widget.mask,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (step.cover != null) ...[
            SizedBox(
              // userGuide.scss:94-96 `&-cover { height:
              // $height-userGuide_modal_content_cover-default; }`。
              height: t.heightUserGuideModalContentCoverDefault,
              width: double.infinity,
              child: step.cover,
            ),
            SizedBox(
              // userGuide.scss:98-110 `&-indicator`（★height/圆角/点径走 modal
              // 字段、column-gap 走 popup 字段——命名错位 quirk）。
              height: t.heightUserGuideModalContentIndicatorDefault,
              child: Row(
                key: SemiUserGuide.modalIndicatorKey,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _withGaps([
                  for (var i = 0; i < widget.steps.length; i++)
                    Container(
                      width: t.widthUserGuideModalContentIndicatorItemDefault,
                      height: t.heightUserGuideModalContentIndicatorItemDefault,
                      decoration: BoxDecoration(
                        color: i == index
                            ? t.colorUserGuideModalContentIndicatorBgActive
                            : t.colorUserGuideModalContentIndicatorBg,
                        borderRadius: BorderRadius.circular(
                          t.radiusUserGuideModalContentIndicator,
                        ),
                      ),
                    ),
                ], t.spacingUserGuidePopupContentIndicatorGap),
              ),
            ),
          ],
          if (step.title != null || step.description != null)
            Padding(
              padding: t.spacingUserGuideModalContentBodyPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (step.title != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: t.spacingUserGuideModalContentTitleMarginBottom,
                      ),
                      child: _styled(
                        step.title,
                        fontSize: t.fontUserGuideModalContentTitleFontSize,
                        fontWeight: t.fontUserGuideModalContentTitleFontWeight,
                        lineHeight: t.fontUserGuideModalContentTitleLineHeight,
                      ),
                    ),
                  if (step.description != null)
                    _styled(
                      step.description,
                      fontSize: t.fontUserGuideModalContentDescriptionFontSize,
                      fontWeight: null,
                      lineHeight:
                          t.fontUserGuideModalContentDescriptionLineHeight,
                    ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(
              t.spacingUserGuideModalContentFooterPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _withGaps([
                if (widget.showSkipButton && !isLast)
                  SemiButton(
                    skipLabel,
                    type: SemiButtonType.tertiary,
                    onPressed: _handleSkip,
                  ),
                if (widget.showPrevButton && !isFirst)
                  SemiButton(
                    prevLabel,
                    type: SemiButtonType.tertiary,
                    onPressed: widget.prevButtonProps?.onPressed ?? _handlePrev,
                  ),
                SemiButton(
                  nextLabel,
                  type: SemiButtonType.primary,
                  variant: SemiButtonVariant.solid,
                  onPressed: widget.nextButtonProps?.onPressed ?? _handleNext,
                ),
              ], t.spacingUserGuideModalContentButtonGap),
            ),
          ),
        ],
      ),
    );
  }

  // -- 共用 -----------------------------------------------------------------

  bool _isPrimary(SemiUserGuideStep step) =>
      widget.theme == SemiUserGuideThemeMode.primary ||
      step.theme == SemiUserGuideThemeMode.primary;

  /// title/description 插槽（String | Widget）+ CSS line-height 映射
  /// （`TextStyle.height = lineHeight / fontSize`——treeSelect 先例）。
  Widget _styled(
    Object? value, {
    required double fontSize,
    required FontWeight? fontWeight,
    required double lineHeight,
  }) {
    if (value is Widget) return value;
    return Text(
      value?.toString() ?? '',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight / fontSize,
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> children, double gap) {
    if (children.length < 2) return children;
    return [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(width: gap),
        children[i],
      ],
    ];
  }

  /// 带内联 bg 覆写的按钮（上游 `style={{ backgroundColor: ... }}`——内联压过
  /// :hover/:active 各态，覆色恒定）。
  Widget _guideButton({
    required Widget label,
    required SemiButtonType type,
    required SemiButtonVariant variant,
    required Color? bg,
    required VoidCallback? onPressed,
  }) {
    Widget button = SemiButton(
      label,
      type: type,
      variant: variant,
      onPressed: onPressed,
    );
    if (bg == null) return button;
    if (variant == SemiButtonVariant.solid) {
      // solid 背景走 `colorButton*Bg*` 字段——主题槽覆写三态。
      button = SemiButtonTheme(
        data: SemiButtonThemeData(
          colorButtonPrimaryBgDefault: bg,
          colorButtonPrimaryBgHover: bg,
          colorButtonPrimaryBgActive: bg,
        ),
        child: button,
      );
    } else {
      // borderless 默认态背景硬编码透明（semi_button.dart）→ 白盒底衬 +
      // hover/active 覆白（内联覆色恒定语义）。
      final bt = SemiButtonTheme.resolve(context);
      button = SemiButtonTheme(
        data: SemiButtonThemeData(
          colorButtonBorderlessBgHover: bg,
          colorButtonBorderlessBgActive: bg,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(bt.radiusButton),
          ),
          child: button,
        ),
      );
    }
    return button;
  }

  // -- 步进（foundation.ts）-------------------------------------------------

  /// foundation.ts:23-28 `_notifyChange`（仅值变化时发）。
  void _notifyChange(int current) {
    if (_current != current) widget.onChange?.call(current);
  }

  /// foundation.ts:47-56 `handlePrev`（★不 clamp——`getFinalPaading` 同文件
  /// 拼写 quirk 见 `_UserGuideMetrics`；★上游 setCurrent 先于 notify，React
  /// setState 异步下 `_notifyChange` 观察旧值——Flutter setState 同步执行，
  /// 为保「值变化才发」语义照 handleNext 次序先 notify 后 setState，外部回调
  /// 序 onChange→onPrev 不变，差异清单）。
  void _handlePrev() {
    final newCurrent = _current - 1;
    _notifyChange(newCurrent);
    widget.onPrev?.call(newCurrent);
    if (!_isControlled) {
      setState(() => _current = newCurrent);
    }
    _schedulePostFrame(() {
      _updateSpotlight(scrollIntoView: true);
      _entry?.markNeedsBuild();
    });
  }

  /// foundation.ts:58-78 `handleNext`（末步只发 onFinish；通知先于 setCurrent
  /// ——与 handlePrev 相反的上游次序照录）。
  void _handleNext() {
    final steps = widget.steps;
    final isLastStep = _current == steps.length - 1;
    if (isLastStep) {
      widget.onFinish?.call();
      return;
    }
    final newCurrent = _current + 1;
    _notifyChange(newCurrent);
    widget.onNext?.call(newCurrent);
    if (!_isControlled) {
      setState(() => _current = newCurrent);
    }
    _schedulePostFrame(() {
      _updateSpotlight(scrollIntoView: true);
      _entry?.markNeedsBuild();
    });
  }

  /// foundation.ts:80-82 `handleSkip`（仅通知）。
  void _handleSkip() {
    widget.onSkip?.call();
  }

  // -- 聚光灯度量 -----------------------------------------------------------

  SemiUserGuideStep? get _currentStep {
    if (_current < 0 || _current >= widget.steps.length) return null;
    return widget.steps[_current];
  }

  RenderBox? _targetBox(String id) {
    final targets = _SemiUserGuideTargetState.registry[id];
    final box = (targets == null || targets.isEmpty)
        ? null
        : targets.first.context.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  /// foundation.ts:47-55 `getFinalPaading`（★上游方法名拼写 quirk 原文
  /// `Paading`——见 `_UserGuideMetrics`）：step ?? 全局 ?? 默认。
  double _finalPadding(SemiUserGuideStep step) {
    final stepPadding = step.spotlightPadding;
    if (stepPadding != null) return stepPadding;
    final padding = widget.spotlightPadding;
    if (padding != null) return padding;
    return _UserGuideMetrics.defaultSpotlightPadding;
  }

  /// index.tsx:224-273 `updateSpotlightRect`（popup 模式 + visible 才度量
  /// ——「hidden/unmounted 后不再读取目标」契约，scroll-ownership 测试口径）。
  void _updateSpotlight({required bool scrollIntoView}) {
    if (!widget.visible || widget.mode != SemiUserGuideMode.popup) return;
    final step = _currentStep;
    if (step == null || step.target == null) return;
    final box = _targetBox(step.target!);
    // 上游 `target?.getBoundingClientRect()`——目标缺位时防御性跳过（上游抛
    // TypeError，差异清单）。
    if (box == null) {
      if (_spotlightRect != null) {
        setState(() => _spotlightRect = null);
        _entry?.markNeedsBuild();
      }
      return;
    }
    if (scrollIntoView || _spotlightRect == null) {
      _scrollIntoViewIfNeeded(box);
    }
    final origin = box.localToGlobal(Offset.zero);
    final raw = origin & box.size;
    final padding = _finalPadding(step);
    // index.tsx:253-258：矩形外扩 padding（x/y −p、w/h +2p）。
    final padded = Rect.fromLTRB(
      raw.left - padding,
      raw.top - padding,
      raw.right + padding,
      raw.bottom + padding,
    );
    if (padded != _spotlightRect) {
      setState(() => _spotlightRect = padded);
    }
    // 蒙层/卡片在自管 overlay——state 变化须显式重建入口（setState 只重建
    // 本体）。
    _entry?.markNeedsBuild();
    _rebindPositions();
  }

  /// index.tsx:187-216 `scrollTargetIntoViewIfNeeded`：目标整体在视口内则不滚
  /// （`block: 'center'` → ensureVisible alignment 0.5，差异清单）。
  void _scrollIntoViewIfNeeded(RenderBox box) {
    final origin = box.localToGlobal(Offset.zero);
    final rect = origin & box.size;
    final viewport = MediaQuery.sizeOf(context);
    final isInViewport =
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= viewport.height &&
        rect.right <= viewport.width;
    if (isInViewport) return;
    final step = _currentStep;
    final targets = step == null
        ? null
        : _SemiUserGuideTargetState.registry[step.target];
    final targetContext = (targets == null || targets.isEmpty)
        ? null
        : targets.first.context;
    if (targetContext != null) {
      // `scrollIntoView({ behavior: 'auto', block: 'center' })`（index.tsx:210-214）。
      Scrollable.ensureVisible(targetContext, alignment: 0.5);
    }
  }

  /// window scroll 捕获（index.tsx:153 `scroll`，capture）→ 目标全部祖先滚动
  /// 位逐一挂监听（差异清单）。
  void _rebindPositions() {
    final step = _currentStep;
    final targets = step == null
        ? null
        : _SemiUserGuideTargetState.registry[step.target];
    final targetContext = (targets == null || targets.isEmpty)
        ? null
        : targets.first.context;
    final positions = <ScrollPosition>{};
    targetContext?.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        final position = (element.state as ScrollableState).position;
        if (position.hasPixels) positions.add(position);
      }
      return true;
    });
    for (final position in _boundPositions.difference(positions)) {
      position.removeListener(_handleScrollLike);
    }
    for (final position in positions.difference(_boundPositions)) {
      position.addListener(_handleScrollLike);
    }
    _boundPositions
      ..clear()
      ..addAll(positions);
  }

  void _unbindAll() {
    for (final position in _boundPositions) {
      position.removeListener(_handleScrollLike);
    }
    _boundPositions.clear();
  }

  /// handleLayoutChange（index.tsx:218-221）：滚动/布局变化重测聚光灯。
  void _handleScrollLike() {
    _updateSpotlight(scrollIntoView: false);
  }

  // -- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!_active) return const SizedBox.shrink();
    if (widget.mode == SemiUserGuideMode.modal) {
      // 越界 current 防御（上游 `steps[current]` TypeError——差异清单）。
      if (_currentStep == null) return const SizedBox.shrink();
      return _buildModal(SemiUserGuideTheme.resolve(context));
    }
    // popup 模式：蒙层 + 卡片在自管 overlay（insert 延后到 postFrame）。
    return const SizedBox.shrink();
  }
}

/// SVG 遮罩挖洞等价涂色：viewport 填色 + 圆角矩形洞差值
/// （`fill="white"` 显 / `fill="black"` 挖的 mask 机制，index.tsx:437-448）。
class _SpotlightMaskPainter extends CustomPainter {
  const _SpotlightMaskPainter({
    required this.hole,
    required this.holeRadius,
    required this.color,
  });

  final Rect hole;
  final double holeRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final cut = Path()
      ..addRRect(RRect.fromRectAndRadius(hole, Radius.circular(holeRadius)));
    final paint = Paint()..color = color;
    canvas.drawPath(Path.combine(PathOperation.difference, full, cut), paint);
  }

  @override
  bool shouldRepaint(_SpotlightMaskPainter oldDelegate) =>
      hole != oldDelegate.hole ||
      holeRadius != oldDelegate.holeRadius ||
      color != oldDelegate.color;
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _UserGuideMetrics {
  /// constants.ts:30 `DEFAULT_CURRENT: 0`（current 缺省/开档归零）。
  static const int defaultCurrent = 0;

  /// constants.ts:31 `DEFAULT_SPOTLIGHT_PADDING: 5`（聚光灯内边距缺省）。
  static const double defaultSpotlightPadding = 5;

  /// constants.ts:32 `DEFAULT_Z_INDEX: 1030`（zIndex 缺省）。
  static const int defaultZIndex = 1030;

  /// index.tsx:446 `rx={4}`（聚光灯洞口圆角）。
  static const double holeRadius = 4;

  /// userGuide.scss:77 `font-size: $font-size-regular`（popup 指示器字号——
  /// ★直写全局 token 顶替 `$font-userGuide_popup_content_indicator-fontSize`
  /// 死变量；调用点 `_buildPopupContent` 指示器文本）。
  static const double fontSizeRegular = 14;

  /// popover/constants.ts:42-43 `SPACING: 4` / `SPACING_WITH_ARROW: 10`
  /// （锚-卡间距，SemiTooltip.spacing 槽消费）。
  static const double popoverSpacing = 4;
  static const double popoverSpacingWithArrow = 10;

  /// popover/constants.ts:36-39 `ARROW_BOUNDING` 的 `offsetY: 6`（小触发器
  /// 箭头校正）。
  static const double popoverArrowBoundingOffsetY = 6;

  /// 上游 locale 缺省文案（zh_CN.ts:197-202 `UserGuide`——locale 无 Flutter
  /// 对应，中文缺省直写；popconfirm 先例）。
  static const String skipLabel = '跳过';
  static const String nextLabel = '下一步';
  static const String prevLabel = '上一步';
  static const String finishLabel = '完成';

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // index.tsx:446 `rx={4}`（聚光灯洞口圆角——holeRadius）。
  //
  // index.tsx:457 `fill="var(--semi-color-overlay-bg)"`（蒙层填色——实时
  // 引用 `theme.colors.colorOverlayBg`，generate_cropper.py 先例）。
  //
  // index.tsx:439 `fill="white"` / :447 `fill="black"`（SVG mask 白显黑挖
  // 机制 → Path.combine difference）。
  //
  // userGuide.scss:15 `pointer-events: none`（svg 根不接指针——洞口穿透）。
  //
  // userGuide.scss:18 `pointer-events: auto`（透明捕获条吞点击）。
  //
  // userGuide.scss:22 `transition: all $transition_duration-userGuide_spotLight $transition_function-userGuide_spotLight`
  // （MOTION 消费行——TweenAnimationBuilder 洞口补间）。
  //
  // userGuide.scss:27 `max-width: fit-content`（popover 卡宽上限）。
  //
  // userGuide.scss:85 `width: fit-content`（`.semi-modal-small` 覆写——modal
  // 壳宽由 `width` prop 承担，差异清单注明 fit-content 收窄不复现）。
  //
  // userGuide.scss:40 `display: block`（封面 img 块级）。
  //
  // index.tsx:350 `padding: 0`（basePopoverStyle 卡 padding 归零）+ :529
  // `bodyStyle={{ padding: 0 }}` + userGuide.scss:90 `padding: 0`
  // （`.semi-modal-content` 覆写 → contentPadding 槽）。
  //
  // userGuide.scss:77 `font-size: $font-size-regular`（见 fontSizeRegular）。
  //
  // index.tsx:355 `backgroundColor: 'var(--semi-color-primary)'`（primary
  // 卡底——实时引用 `theme.colors.colorPrimary`）。
  //
  // index.tsx:301/:311 `backgroundColor: 'var(--semi-color-fill-2)'`
  // （primary 主题 skip/prev 底色——实时引用 `theme.colors.colorFill2`）。
  //
  // index.tsx:321 `backgroundColor: '#FFF'`（primary 主题 next 底色）。
  //
  // index.tsx:370 `showArrow={step.showArrow !== false}`（箭头缺省开）。
  //
  // index.tsx:397/:436 `zIndex: zIndex - 1`（蒙层在卡之下——本移植以 overlay
  // 插入序承担）。
  //
  // popover/constants.ts:42 `SPACING: 4` / :43 `SPACING_WITH_ARROW: 10`、
  // :36-39 `ARROW_BOUNDING` 的 `offsetY: 6`（popover 族几何常量）。
  //
  // foundation.ts:47 `getFinalPaading`（★上游方法名拼写 quirk 原文照抄——
  // `Paading` 多一个 a；调用点 `_finalPadding`）。
}
