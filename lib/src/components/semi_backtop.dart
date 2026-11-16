// SemiBackTop — 回到顶部（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/backTop/{variables.scss, backtop.scss,
// rtl.scss, foundation.ts, constants.ts}、packages/semi-ui/backTop/index.tsx。
// 主题对账 3 = 3 FIELDS + 0 MOTION + 0 INTERNAL（tool/generate_backtop.py）
// ——3 条 variables.scss 声明全落 theme 字段，0 条死变量（全部上游消费：
// backtop.scss:8-10）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_BackTopMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_backtop_theme.dart';
import '../theme/semi_backtop_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';

/// 回到顶部。
///
/// 显示（foundation.ts:93-103 `handleScroll`）：监听 [scrollController]，
/// `scrollTop > visibilityHeight` 时显示（:100），否则隐藏；目标缺失隐藏
/// （:94-98）。点击（foundation.ts:44-47 `onClick` → `setScrollTop(0)`）：
/// animateTo 滚回顶部（[duration] + `easing: 'easeInOutCubic'`）并回传
/// [onClick]；★点击按上游 `throttle(this.handleClick, ...)` 双沿节流（leading
/// 即发 + trailing 窗口末补发，unmount 后 pending 不达——pendingClick 测试
/// 口径）。定位：上游 `position: fixed`（视口固定）→ 本移植为宿主 [Stack]
/// 直接子节点 `PositionedDirectional`（end/bottom = 主题间距，RTL 自动翻边），
/// 见差异清单。
class SemiBackTop extends StatefulWidget {
  const SemiBackTop({
    super.key,
    this.scrollController,
    this.visibilityHeight = _BackTopMetrics.visibilityHeightDefault,
    this.duration = _BackTopMetrics.durationDefault,
    this.onClick,
    this.child,
    this.semanticsLabel,
  });

  /// 滚动容器（上游 `target: getDefaultTarget`——window 无对应，见差异清单；
  /// 缺省不监听、恒不可见）。
  final ScrollController? scrollController;

  /// 出现阈值（`scrollTop > visibilityHeight` 时显示；index.tsx:38
  /// `visibilityHeight: 400`）。
  final double visibilityHeight;

  /// 滚动到顶部的时间（index.tsx:40 `duration: 450`，毫秒）；★同值兼作点击
  /// 节流窗口，且窗口在 mount 时捕获（index.tsx:64 quirk）。
  final Duration duration;

  /// 点击回传（上游 `onClick(e: MouseEvent)`——e 无对应，见差异清单）。
  final VoidCallback? onClick;

  /// 按钮内容（上游 `children`）；缺省 `renderDefault`（index.tsx:105-107
  /// `theme="light"` + `icon={<IconChevronUp />}`）。
  final Widget? child;

  /// 语义名（★上游无 aria-label——本移植补 Semantics button，见差异清单）。
  final String? semanticsLabel;

  /// 按钮内容（测试度量锚点）。
  static const Key contentKey = ValueKey('SemiBackTopContent');

  @override
  State<SemiBackTop> createState() => _SemiBackTopState();
}

class _SemiBackTopState extends State<SemiBackTop> {
  bool _visible = false;

  /// index.tsx:64 throttle 窗口——★mount 时捕获（componentDidMount 一次性
  /// `throttle(this.handleClick, ...)`，后续 duration 变更不换窗 quirk）。
  late Duration _throttleWindow;

  /// 双沿节流（lodash throttle `leading: true, trailing: true`）：窗口内点击
  /// 只置 [Timer]。
  Timer? _throttleTimer;
  bool _pendingClick = false;

  late final FocusNode _focusNode = FocusNode(debugLabel: 'SemiBackTop');

  @override
  void initState() {
    super.initState();
    _throttleWindow = widget.duration;
    widget.scrollController?.addListener(_updateVisibility);
    // foundation.ts:28-34 `init`：注册 scroll listener 并立即 `handleScroll`。
    _updateVisibility();
    // ★上游 DOM 挂载即有目标；Flutter 滚动容器首帧后才 attach——补一帧再评估
    // （见差异清单）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant SemiBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      // foundation.ts:44-51 `updateTarget`：目标换绑立即重估（上游 destroy
      // + init 同口径；同目标不动——pendingClick/propUpdates 测试口径）。
      oldWidget.scrollController?.removeListener(_updateVisibility);
      widget.scrollController?.addListener(_updateVisibility);
      _updateVisibility();
    }
    if (oldWidget.visibilityHeight != widget.visibilityHeight) {
      // index.tsx:68-71 componentDidUpdate：visibilityHeight 变化即
      // `handleScroll`（propUpdates 测试口径）。
      _updateVisibility();
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_updateVisibility);
    // index.tsx:77-79 componentWillUnmount `this.handler.cancel()`——
    // pending trailing 不达（pendingClick 测试口径）。
    _throttleTimer?.cancel();
    _pendingClick = false;
    _focusNode.dispose();
    super.dispose();
  }

  // -- visibility ------------------------------------------------------------

  /// foundation.ts:93-103 `handleScroll`（★上游 `requestAnimationFrame(update)`
  /// 包装 → 同步评估，见差异清单）。
  void _updateVisibility() {
    final controller = widget.scrollController;
    // the target may be missing (e.g. an unset ref)（foundation.ts:94-98
    // `updateVisible(false)`）。
    if (controller == null || !controller.hasClients) {
      _setVisible(false);
      return;
    }
    // getScroll（foundation.ts:52-60 `scrollTop`/`pageYOffset`）→ pixels。
    final double scrollTop = controller.position.pixels;
    // foundation.ts:100 `updateVisible(scrollTop > visibilityHeight)`。
    _setVisible(scrollTop > widget.visibilityHeight);
  }

  void _setVisible(bool visible) {
    if (_visible == visible) return;
    setState(() => _visible = visible);
  }

  // -- click -----------------------------------------------------------------

  /// index.tsx:64 `throttle(this.handleClick, this.props.duration ?? BackTop.defaultProps.duration)`
  /// （lodash throttle 双沿：leading 即发 + trailing 窗口末补发；★窗口 mount
  /// 时捕获）。
  void _handleTap() {
    if (_throttleTimer != null) {
      // trailing edge：窗口内再点只置旗标，窗口末补发（pendingClick 测试
      // `keeps the trailing click while mounted`）。
      _pendingClick = true;
      return;
    }
    _invokeClick();
    _throttleTimer = Timer(_throttleWindow, () {
      _throttleTimer = null;
      if (!mounted) return;
      if (_pendingClick) {
        _pendingClick = false;
        _invokeClick();
      }
    });
  }

  /// index.tsx:101-103 `handleClick` → foundation.ts:44-47 `onClick`
  /// （`setScrollTop(0)` + `notifyClick(e)`）。
  void _invokeClick() {
    _setScrollTop(0);
    widget.onClick?.call();
  }

  /// foundation.ts:49-52 `setScrollTop` → :62-82 `scrollTo`（`from`/`to` 逐帧
  /// 写 scrollTop → animateTo）。
  void _setScrollTop(double to) {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    // getScroll（foundation.ts:52-60）→ from = position.pixels。
    // foundation.ts:72 `easing: 'easeInOutCubic'`（semi-animation 命名缓动）。
    controller.position.animateTo(
      to,
      duration: widget.duration,
      curve: Curves.easeInOutCubic,
    );
  }

  /// ★偏差（统一交互约定）：上游静态 div 无键盘激活（index.tsx:119-120
  /// jsx-a11y 禁用注释）——本移植补 Enter（Space/可打印键忽略，锚点
  /// keyboardActivation 同口径）。
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      _handleTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // -- render ----------------------------------------------------------------

  /// index.tsx:105-107 `renderDefault`——`theme="light"` +
  /// `icon={<IconChevronUp />}`（IconButton 无 onClick，点击由外层 div 承担）。
  Widget _buildDefaultButton() => SemiButton(
    null,
    variant: SemiButtonVariant.light,
    icon: const SemiIcon(SemiIcons.chevronUp),
  );

  @override
  Widget build(BuildContext context) {
    // 上游 `content = visible ? (...) : null`（index.tsx:117）。
    if (!_visible) return const SizedBox.shrink();
    final SemiResolvedBackTopThemeData t = SemiBackTopTheme.resolve(context);
    final Widget content = widget.child ?? _buildDefaultButton();
    return PositionedDirectional(
      // backtop.scss:8-9 `right: $spacing-backtop-right; bottom: $spacing-backtop-bottom;`
      // （RTL：rtl.scss:6-8 `direction: rtl` / `right: auto` /
      // `left: $spacing-backtop-right` → end/start 自动翻边）。
      // backtop.scss:10 `z-index: $z-backtop`——★无 z-index Flutter 槽
      // （SemiTooltip.zIndex 同口径）：叠放由宿主 Stack 子序决定；
      // `zBacktop` 无消费槽 → 注释引用（transitionDelayAnchorTitleText 先例，
      // docs 注明）。
      end: t.spacingBacktopRight,
      bottom: t.spacingBacktopBottom,
      child: Semantics(
        button: true,
        label: widget.semanticsLabel,
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _onKey,
          child: MouseRegion(
            // backtop.scss:11 `cursor: pointer`。
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              child: ClipRect(
                // backtop.scss:14 `overflow: hidden`。
                key: SemiBackTop.contentKey,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _BackTopMetrics {
  /// index.tsx:38 `visibilityHeight: 400`（缺省可见阈值）。
  static const double visibilityHeightDefault = 400;

  /// index.tsx:40 `duration: 450`（缺省滚动毫秒数；★同值兼作节流窗口且
  /// mount 时捕获）。
  static const Duration durationDefault = Duration(milliseconds: 450);

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // backtop.scss:6 `position: fixed`（视口固定 → PositionedDirectional 宿主
  // Stack 子节点，见差异清单）。
  //
  // backtop.scss:7 `box-sizing: border-box`（Flutter 盒模型天生 border-box
  // ——注释留档）。
  //
  // backtop.scss:10 `z-index: $z-backtop`（★无 z-index Flutter 槽——叠放由
  // 宿主 Stack 子序决定，SemiTooltip.zIndex 同口径；字段 `zBacktop` 注释
  // 引用留档）。
  //
  // backtop.scss:11 `cursor: pointer`（→ MouseRegion(SystemMouseCursors.click)）。
  //
  // backtop.scss:13 `text-align: center`（内容居中——固定内容盒 shrink-wrap，
  // 注释留档）。
  //
  // backtop.scss:14 `overflow: hidden`（→ ClipRect）。
  //
  // rtl.scss:6-8 RTL 覆盖
  //     direction: rtl
  //     right: auto
  //     left: $spacing-backtop-right
  // （→ Directionality + PositionedDirectional end/start 自动翻边）。
  //
  // index.tsx:39 `target: getDefaultTarget`（`const getDefaultTarget = () => window;`
  // index.tsx:16——window 无对应 → scrollController，见差异清单）。
  //
  // index.tsx:64 `throttle(this.handleClick, this.props.duration ?? BackTop.defaultProps.duration)`
  // （双沿节流；★窗口 mount 时捕获 quirk——调用点 `_handleTap`）。
  //
  // index.tsx:106 `theme="light"`（默认按钮 variant light）。
  //
  // index.tsx:106 `icon={<IconChevronUp />}`（默认按钮图标）。
  //
  // foundation.ts:72 `easing: 'easeInOutCubic'`（滚动动画缓动——调用点
  // `_setScrollTop`）。
}
