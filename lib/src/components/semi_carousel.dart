// SemiCarousel — 上游 packages/semi-ui/carousel/{index.tsx,CarouselArrow.tsx,
// CarouselIndicator.tsx} 与 packages/semi-foundation/carousel/{carousel.scss,
// foundation.ts} 的移植。
//
// 主题对账 **40 = 34 FIELDS + 6 MOTION + 0 INTERNAL**（variables.scss 34 声明：
// color 15、width 6、height 6、spacing 6、radius 1；animation.scss 6 声明：两组
// transition 三元组；`$module` 胶水与 rtl.scss 不计；datePicker
// `223 = 220 + 3 + 0` … steps `104 = 94 + 10 + 0`、upload `85 = 85 + 0 + 0`、
// skeleton `17 = 15 + 2 + 0`、tabs `144 = 121 + 23 + 0` 先例）。0 死变量。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts `DEFAULT_ACTIVE_INDEX: 0` / `DEFAULT_INTERVAL: 2000` /
//   `DEFAULT_SPEED: 300`；枚举串 `ANIMATION_MAP: ['slide', 'fade']`、
//   `TYPE_MAP: ['columnar', 'line', 'dot']`、
//   `THEME_MAP: ['dark', 'primary', 'light']`、
//   `POSITION_MAP: ['left', 'center', 'right']`、
//   `ARROW_MAP: ['always', 'hover']`、`SIZE: ['small', 'medium']`、
//   `TRIGGER: ['click', 'hover']`
// - carousel.scss:380-405 slide keyframes `translateX(100%)` / `translateX(-100%)`
// - index.tsx:214 `transitionTimingFunction: 'ease'`（speed 毫秒）
// - carousel.scss:52 slide 非当前项 `visibility: hidden`；:31 fade `opacity: 0`
// - `IconChevronLeft` / `IconChevronRight`；aria-label="Previous index" /
//   aria-label="Next index"
// - rtl.scss:43 箭头翻转 `scaleX(-1)`
// - carousel.scss:363-372 hover 箭头 `opacity: 0`，`:hover` 恢复（&:hover）
// - index.tsx:197 400ms 防抖 `debounce(..., 400)`
// - 指示器项外边距 `:not(:last-child)`
// - index.tsx:250/270 `children.length > 1` 才渲染指示器/箭头
// - foundation.ts:118 `getSwitchingTime()` = interval + speed
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/semi_carousel_theme.dart';
import '../theme/semi_carousel_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';

/// 切换动画（上游 `animation: 'slide' | 'fade'`，缺省 slide）。
enum SemiCarouselAnimation { slide, fade }

/// 指示器形态（上游 `indicatorType: 'columnar' | 'line' | 'dot'`，缺省 dot）。
enum SemiCarouselIndicatorType { columnar, line, dot }

/// 主题色（上游 `theme: 'dark' | 'primary' | 'light'`，缺省 light）。
enum SemiCarouselThemeColor { dark, primary, light }

/// 指示器位置（上游 `indicatorPosition: 'left' | 'center' | 'right'`）。
enum SemiCarouselIndicatorPosition { left, center, right }

/// 箭头显示时机（上游 `arrowType: 'always' | 'hover'`）。
enum SemiCarouselArrowType { always, hover }

/// 指示器尺寸（上游 `indicatorSize: 'small' | 'medium'`）。
enum SemiCarouselSize { small, medium }

/// 指示器触发（上游 `trigger: 'click' | 'hover'`）。
enum SemiCarouselTrigger { click, hover }

/// 滑动方向（上游 `slideDirection: 'left' | 'right'`，缺省 left）。
enum SemiCarouselDirection { left, right }

/// 命令式控制器（上游实例方法 next/prev/goTo/play/stop）。
class SemiCarouselController {
  _SemiCarouselState? _state;

  void _attach(_SemiCarouselState state) => _state = state;
  void _detach(_SemiCarouselState state) {
    if (_state == state) _state = null;
  }

  bool get isAttached => _state != null;

  void next() => _state?._next();
  void prev() => _state?._prev();
  void goTo(int index) => _state?._goTo(index);

  /// 手动播放（上游 `play()`：即使 `autoPlay: false` 也强制启动）。
  void play({Duration? interval}) => _state?._play(interval: interval);

  void stop() => _state?._stop();
}

/// 轮播（Semi Carousel）。
///
/// `slide`/`fade` 两种切换；`speed` 毫秒；可自动播放（`interval + speed`
/// 间隔、hover 400ms 防抖暂停）；`dot`/`line`/`columnar` 三种指示器（左侧/
/// 居中/右侧、small/medium、click/hover 触发）；两侧箭头（always/hover、三种
/// 主题色）；受控 [activeIndex] / 非受控 [defaultActiveIndex]；RTL 镜像。
///
/// 尺寸：内容区宽高 100%（CSS），Flutter 需要父级给出有界宽高（例如放在
/// [SizedBox] 里）。
class SemiCarousel extends StatefulWidget {
  const SemiCarousel({
    super.key,
    this.children = const <Widget>[],
    this.activeIndex,
    this.defaultActiveIndex = 0,
    this.animation = SemiCarouselAnimation.slide,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(milliseconds: 2000),
    this.hoverToPause = true,
    this.speed = const Duration(milliseconds: 300),
    this.theme = SemiCarouselThemeColor.light,
    this.showArrow = true,
    this.showIndicator = true,
    this.indicatorType = SemiCarouselIndicatorType.dot,
    this.indicatorSize = SemiCarouselSize.small,
    this.indicatorPosition = SemiCarouselIndicatorPosition.center,
    this.indicatorTrigger = SemiCarouselTrigger.click,
    this.arrowType = SemiCarouselArrowType.always,
    this.slideDirection = SemiCarouselDirection.left,
    this.prevArrowIcon,
    this.nextArrowIcon,
    this.controller,
    this.onChange,
    this.semanticLabel,
  });

  /// 轮播项。
  final List<Widget> children;

  /// 受控选中下标；非 null 即受控（交互只回调）。
  final int? activeIndex;

  /// 非受控初始下标（上游 `DEFAULT_ACTIVE_INDEX: 0`）。
  final int defaultActiveIndex;

  final SemiCarouselAnimation animation;

  /// 自动播放（受控时不自动播放，与上游一致）。
  final bool autoPlay;

  /// 自动播放间隔（上游 `DEFAULT_INTERVAL: 2000`；实际切换间隔还要加 speed）。
  final Duration autoPlayInterval;

  /// hover 暂停（上游 autoPlay 为对象时的 `hoverToPause`，缺省 true）。
  final bool hoverToPause;

  /// 切换动画时长（上游 `DEFAULT_SPEED: 300`）。
  final Duration speed;

  final SemiCarouselThemeColor theme;
  final bool showArrow;
  final bool showIndicator;
  final SemiCarouselIndicatorType indicatorType;
  final SemiCarouselSize indicatorSize;
  final SemiCarouselIndicatorPosition indicatorPosition;
  final SemiCarouselTrigger indicatorTrigger;
  final SemiCarouselArrowType arrowType;
  final SemiCarouselDirection slideDirection;

  /// 自定义左右箭头图标（上游 `arrowProps.leftArrow/rightArrow.children`）。
  final Widget? prevArrowIcon;
  final Widget? nextArrowIcon;

  final SemiCarouselController? controller;

  /// 切换回调 `(activeIndex, preIndex)`。
  final void Function(int index, int preIndex)? onChange;

  /// 语义标签（`role="listbox"` 的头像说明位）。
  final String? semanticLabel;

  @override
  State<SemiCarousel> createState() => _SemiCarouselState();
}

class _SemiCarouselState extends State<SemiCarousel>
    with SingleTickerProviderStateMixin {
  late int _activeIndex;
  int _fromIndex = 0;
  bool _isReverse = false;
  bool _isInit = true;
  bool? _pendingReverse;
  bool _hovered = false;
  bool _forcePlay = false;
  Duration? _manualInterval;

  Timer? _timer;
  Timer? _hoverPauseTimer;
  Timer? _hoverResumeTimer;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: widget.speed > Duration.zero
        ? widget.speed
        : const Duration(milliseconds: 1),
    value: 1,
  );

  int get _count => widget.children.length;

  bool get _controlled => widget.activeIndex != null;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.activeIndex ?? widget.defaultActiveIndex;
    _fromIndex = _activeIndex;
    widget.controller?._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAutoPlay());
  }

  @override
  void didUpdateWidget(SemiCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (widget.speed != oldWidget.speed) {
      _anim.duration = widget.speed > Duration.zero
          ? widget.speed
          : const Duration(milliseconds: 1);
    }
    if (widget.activeIndex != null &&
        widget.activeIndex != oldWidget.activeIndex) {
      final target = widget.activeIndex!;
      final previous = _activeIndex;
      if (target != previous) {
        _fromIndex = previous;
        _isReverse = _pendingReverse ?? (previous > target);
        _pendingReverse = null;
        _activeIndex = target;
        _isInit = false;
        _anim.forward(from: 0);
      }
    }
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.children.length != widget.children.length) {
      _scheduleAutoPlay();
    }
    if (!_controlled && _activeIndex >= _count && _count > 0) {
      _activeIndex = _validIndex(_activeIndex);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hoverPauseTimer?.cancel();
    _hoverResumeTimer?.cancel();
    widget.controller?._detach(this);
    _anim.dispose();
    super.dispose();
  }

  int _validIndex(int index) => _count == 0 ? 0 : (index + _count) % _count;

  /// foundation.ts:118 `getSwitchingTime()` = interval + speed。
  Duration _switchingTime() =>
      (_manualInterval ?? widget.autoPlayInterval) + widget.speed;

  // -- commands --------------------------------------------------------------

  void _next() {
    final target = _validIndex(_activeIndex + 1);
    _select(target, reverse: false, restartAuto: true);
  }

  void _prev() {
    final target = _validIndex(_activeIndex - 1);
    _select(target, reverse: true, restartAuto: true);
  }

  void _goTo(int index) {
    _select(_validIndex(index), reverse: _activeIndex > index);
  }

  void _select(int target, {required bool reverse, bool restartAuto = false}) {
    _stopTimer();
    final previous = _activeIndex;
    if (_controlled) {
      _pendingReverse = reverse;
      if (target != previous) widget.onChange?.call(target, previous);
    } else if (target != previous) {
      setState(() {
        _fromIndex = previous;
        _isReverse = reverse;
        _activeIndex = target;
        _isInit = false;
      });
      _anim.forward(from: 0);
      widget.onChange?.call(target, previous);
    } else {
      _isReverse = reverse;
    }
    if (restartAuto) _scheduleAutoPlay();
  }

  void _play({Duration? interval}) {
    _forcePlay = true;
    _manualInterval = interval;
    _scheduleAutoPlay();
  }

  void _stop() {
    _forcePlay = false;
    _manualInterval = null;
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleAutoPlay() {
    if (!mounted) return;
    _stopTimer();
    if (_count <= 1) return;
    if (_controlled && !_forcePlay) return;
    if (!widget.autoPlay && !_forcePlay) return;
    if (_hovered && widget.hoverToPause) return;
    _timer = Timer(_switchingTime(), _next);
  }

  void _handlePointerEnter() {
    setState(() => _hovered = true);
    _hoverResumeTimer?.cancel();
    if (!widget.hoverToPause) return;
    // 上游 debouncedMouseEnter 400ms 后暂停。
    _hoverPauseTimer?.cancel();
    _hoverPauseTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _stopTimer();
    });
  }

  void _handlePointerExit() {
    setState(() => _hovered = false);
    _hoverPauseTimer?.cancel();
    _hoverResumeTimer?.cancel();
    if (!widget.hoverToPause) return;
    _hoverResumeTimer = Timer(
      const Duration(milliseconds: 400),
      _scheduleAutoPlay,
    );
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = SemiCarouselTheme.resolve(context);
    final count = _count;
    final showIndicator = widget.showIndicator && count > 1;
    final showArrow = widget.showArrow && count > 1;
    if (count == 0) return const SizedBox.shrink();
    return Semantics(
      label: widget.semanticLabel,
      child: MouseRegion(
        onEnter: (_) => _handlePointerEnter(),
        onExit: (_) => _handlePointerExit(),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildContent(t),
              if (showIndicator) _buildIndicator(t),
              if (showArrow) ..._buildArrows(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SemiResolvedCarouselThemeData theme) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        // index.tsx:214 `transitionTimingFunction: 'ease'`。
        final progress = Curves.ease.transform(_anim.value);
        final reverse = widget.slideDirection == SemiCarouselDirection.left
            ? _isReverse
            : !_isReverse;
        Widget? outgoing;
        Widget? incoming;
        for (var i = 0; i < _count; i++) {
          final isCurrent = i == _activeIndex;
          final isOutgoing =
              i == _fromIndex &&
              !_isInit &&
              _anim.value < 1 &&
              i != _activeIndex;
          if (!isCurrent && !isOutgoing) continue;
          Widget child = widget.children[i];
          if (widget.animation == SemiCarouselAnimation.fade) {
            final opacity = isCurrent ? progress : 1 - progress;
            child = Opacity(opacity: opacity.clamp(0.0, 1.0), child: child);
          } else {
            final double dx;
            if (_isInit) {
              dx = 0;
            } else if (isCurrent) {
              // slide-in keyframe `translateX(100%)` → 0（reverse 为 -100%）。
              dx = (reverse ? -1 : 1) * (1 - progress);
            } else {
              // slide-out keyframe 0 → `translateX(-100%)`（reverse 为 100%）。
              dx = (reverse ? 1 : -1) * progress;
            }
            child = FractionalTranslation(
              translation: Offset(dx, 0),
              child: child,
            );
          }
          final positioned = Positioned.fill(child: child);
          if (isCurrent) {
            incoming = positioned;
          } else {
            outgoing = positioned;
          }
        }
        final stackChildren = <Widget>[];
        if (outgoing != null) stackChildren.add(outgoing);
        if (incoming != null) stackChildren.add(incoming);
        return Stack(fit: StackFit.expand, children: stackChildren);
      },
    );
  }

  // -- indicator -------------------------------------------------------------

  Widget _buildIndicator(SemiResolvedCarouselThemeData theme) {
    final items = <Widget>[
      for (var i = 0; i < _count; i++)
        _IndicatorItem(
          key: ValueKey('carousel-indicator-$i'),
          active: i == _activeIndex,
          type: widget.indicatorType,
          size: widget.indicatorSize,
          colorTheme: widget.theme,
          trigger: widget.indicatorTrigger,
          t: theme,
          onActivate: () => _goTo(i),
        ),
    ];
    final row = switch (widget.indicatorType) {
      SemiCarouselIndicatorType.dot => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              // `:not(:last-child) { margin-right: 8px }`。
              padding: EdgeInsetsDirectional.only(
                end: i == items.length - 1
                    ? 0
                    : theme.spacingCarouselIndicatorDotMarginX,
              ),
              child: items[i],
            ),
        ],
      ),
      SemiCarouselIndicatorType.line => SizedBox(
        width: theme.widthCarouselIndicatorLine,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(child: items[i]),
              if (i != items.length - 1)
                SizedBox(width: theme.spacingCarouselIndicatorLineMarginX),
            ],
          ],
        ),
      ),
      SemiCarouselIndicatorType.columnar => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: i == items.length - 1
                    ? 0
                    : theme.spacingCarouselIndicatorColumnarMarginX,
              ),
              child: items[i],
            ),
        ],
      ),
    };
    final padding = theme.spacingCarouselIndicatorPadding;
    return switch (widget.indicatorPosition) {
      SemiCarouselIndicatorPosition.left => Positioned(
        left: padding,
        bottom: padding,
        child: row,
      ),
      SemiCarouselIndicatorPosition.right => Positioned(
        right: padding,
        bottom: padding,
        child: row,
      ),
      SemiCarouselIndicatorPosition.center => Positioned(
        left: 0,
        right: 0,
        bottom: padding,
        child: Center(child: row),
      ),
    };
  }

  // -- arrows ----------------------------------------------------------------

  List<Widget> _buildArrows(SemiResolvedCarouselThemeData theme) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final size = theme.widthCarouselArrow;
    final prev = _Arrow(
      key: const ValueKey('carousel-arrow-prev'),
      iconBuilder: (color) => widget.prevArrowIcon != null
          ? IconTheme.merge(
              data: IconThemeData(color: color, size: size),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: color, fontSize: size),
                child: widget.prevArrowIcon!,
              ),
            )
          : SemiIcon(SemiIcons.chevronLeft, customSize: size, color: color),
      semanticLabel: 'Previous index',
      colorTheme: widget.theme,
      alwaysVisible: widget.arrowType == SemiCarouselArrowType.always,
      visible: _hovered,
      flip: rtl,
      side: rtl
          ? SemiCarouselIndicatorPosition.right
          : SemiCarouselIndicatorPosition.left,
      spacing: rtl
          ? theme.spacingCarouselArrowRight
          : theme.spacingCarouselArrowLeft,
      t: theme,
      onTap: _prev,
    );
    final next = _Arrow(
      key: const ValueKey('carousel-arrow-next'),
      iconBuilder: (color) => widget.nextArrowIcon != null
          ? IconTheme.merge(
              data: IconThemeData(color: color, size: size),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: color, fontSize: size),
                child: widget.nextArrowIcon!,
              ),
            )
          : SemiIcon(SemiIcons.chevronRight, customSize: size, color: color),
      semanticLabel: 'Next index',
      colorTheme: widget.theme,
      alwaysVisible: widget.arrowType == SemiCarouselArrowType.always,
      visible: _hovered,
      flip: rtl,
      side: rtl
          ? SemiCarouselIndicatorPosition.left
          : SemiCarouselIndicatorPosition.right,
      spacing: rtl
          ? theme.spacingCarouselArrowLeft
          : theme.spacingCarouselArrowRight,
      t: theme,
      onTap: _next,
    );
    return [prev, next];
  }
}

// -- indicator item ---------------------------------------------------------

class _IndicatorItem extends StatefulWidget {
  const _IndicatorItem({
    super.key,
    required this.active,
    required this.type,
    required this.size,
    required this.colorTheme,
    required this.trigger,
    required this.t,
    required this.onActivate,
  });

  final bool active;
  final SemiCarouselIndicatorType type;
  final SemiCarouselSize size;
  final SemiCarouselThemeColor colorTheme;
  final SemiCarouselTrigger trigger;
  final SemiResolvedCarouselThemeData t;
  final VoidCallback onActivate;

  @override
  State<_IndicatorItem> createState() => _IndicatorItemState();
}

class _IndicatorItemState extends State<_IndicatorItem> {
  bool _hovered = false;
  bool _pressed = false;

  Color get _background {
    final t = widget.t;
    final (base, hover, active) = switch (widget.colorTheme) {
      SemiCarouselThemeColor.dark => (
        t.colorCarouselIndicatorThemeDarkBgDefault,
        t.colorCarouselIndicatorThemeDarkBgHover,
        t.colorCarouselIndicatorThemeDarkBgActive,
      ),
      SemiCarouselThemeColor.primary => (
        t.colorCarouselIndicatorThemePrimaryBgDefault,
        t.colorCarouselIndicatorThemePrimaryBgHover,
        t.colorCarouselIndicatorThemePrimaryBgActive,
      ),
      SemiCarouselThemeColor.light => (
        t.colorCarouselIndicatorThemeLightBgDefault,
        t.colorCarouselIndicatorThemeLightBgHover,
        t.colorCarouselIndicatorThemeLightBgActive,
      ),
    };
    // CSS 顺序：base → active（选中）→ :hover → :active（后写者胜）。
    if (_pressed) return active;
    if (_hovered) return hover;
    if (widget.active) return active;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final double? width;
    final double height;
    final BorderRadius? radius;
    switch (widget.type) {
      case SemiCarouselIndicatorType.dot:
        final side = widget.size == SemiCarouselSize.small
            ? t.widthCarouselIndicatorDotSmall
            : t.widthCarouselIndicatorDotMedium;
        width = side;
        height = side;
        // `border-radius: 50%`（radius token 存 50 百分比）。
        radius = BorderRadius.circular(
          side * t.radiusCarouselIndicatorDot / 100,
        );
      case SemiCarouselIndicatorType.line:
        width = null;
        height = widget.size == SemiCarouselSize.small
            ? t.heightCarouselIndicatorLineSmall
            : t.heightCarouselIndicatorLineMedium;
        radius = null;
      case SemiCarouselIndicatorType.columnar:
        width = widget.size == SemiCarouselSize.small
            ? t.widthCarouselIndicatorColumnarSmall
            : t.widthCarouselIndicatorColumnarMedium;
        final (normal, active) = widget.size == SemiCarouselSize.small
            ? (
                t.heightCarouselIndicatorColumnarSmallDefault,
                t.heightCarouselIndicatorColumnarSmallActive,
              )
            : (
                t.heightCarouselIndicatorColumnarMediumDefault,
                t.heightCarouselIndicatorColumnarMediumActive,
              );
        height = widget.active ? active : normal;
        radius = null;
    }
    Widget body = AnimatedContainer(
      duration: t.transitionDurationCarouselIndicatorBg,
      curve: t.transitionFunctionCarouselIndicatorBg,
      width: width,
      height: height,
      decoration: BoxDecoration(color: _background, borderRadius: radius),
    );
    // transition_delay（0ms）无 AnimatedContainer 对应，字段留档：
    // transitionDelayCarouselIndicatorBg。
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        if (widget.trigger == SemiCarouselTrigger.hover) {
          // CarouselIndicator.tsx:37-42 hover 触发立即切换（无防抖）。
          widget.onActivate();
        }
      },
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onPointerCancel: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.trigger == SemiCarouselTrigger.click
              ? widget.onActivate
              : null,
          child: body,
        ),
      ),
    );
  }
}

// -- arrow ------------------------------------------------------------------

class _Arrow extends StatefulWidget {
  const _Arrow({
    super.key,
    required this.iconBuilder,
    required this.semanticLabel,
    required this.colorTheme,
    required this.alwaysVisible,
    required this.visible,
    required this.flip,
    required this.side,
    required this.spacing,
    required this.t,
    required this.onTap,
  });

  final Widget Function(Color? color) iconBuilder;
  final String semanticLabel;
  final SemiCarouselThemeColor colorTheme;
  final bool alwaysVisible;
  final bool visible;
  final bool flip;
  final SemiCarouselIndicatorPosition side;
  final double spacing;
  final SemiResolvedCarouselThemeData t;
  final VoidCallback onTap;

  @override
  State<_Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  bool _hovered = false;

  Color get _color {
    final t = widget.t;
    return switch (widget.colorTheme) {
      SemiCarouselThemeColor.dark =>
        _hovered
            ? t.colorCarouselArrowThemeDarkBgHover
            : t.colorCarouselArrowThemeDarkBgDefault,
      SemiCarouselThemeColor.primary =>
        _hovered
            ? t.colorCarouselArrowThemePrimaryBgHover
            : t.colorCarouselArrowThemePrimaryBgDefault,
      SemiCarouselThemeColor.light =>
        _hovered
            ? t.colorCarouselArrowThemeLightBgHover
            : t.colorCarouselArrowThemeLightBgDefault,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    // rtl.scss:43 `transform: scaleX(-1)`。
    Widget flipIcon(Widget icon) =>
        widget.flip ? Transform.flip(flipX: true, child: icon) : icon;
    final opacity = widget.alwaysVisible || widget.visible ? 1.0 : 0.0;
    Widget arrow = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Semantics(
          button: true,
          label: widget.semanticLabel,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: _color),
            duration: t.transitionDurationCarouselArrowBg,
            curve: t.transitionFuncitonCarouselArrowBg,
            builder: (context, color, child) =>
                flipIcon(widget.iconBuilder(color)),
          ),
        ),
      ),
    );
    // transition_delay（0ms）无对应参数，字段留档：
    // transitionDelayCarouselArrowBg。
    arrow = Opacity(opacity: opacity, child: arrow);
    final positioned = widget.side == SemiCarouselIndicatorPosition.left
        ? Positioned(
            left: widget.spacing,
            top: 0,
            bottom: 0,
            child: Align(alignment: Alignment.centerLeft, child: arrow),
          )
        : Positioned(
            right: widget.spacing,
            top: 0,
            bottom: 0,
            child: Align(alignment: Alignment.centerRight, child: arrow),
          );
    return positioned;
  }
}
