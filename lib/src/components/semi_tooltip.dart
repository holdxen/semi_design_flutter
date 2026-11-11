import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_tooltip_theme.dart';
import '../theme/semi_tooltip_theme_data.dart';
import '../tokens/token_types.dart';
import 'tooltip_arrow_paths.dart';

/// How the tooltip is triggered (web `strings.TRIGGER_SET`).
enum SemiTooltipTrigger {
  /// Show on pointer enter / focus, hide on leave / blur.
  hover,

  /// Toggle on tap; outside taps close it.
  click,

  /// Show on focus, hide on blur.
  focus,

  /// Purely driven by [SemiTooltip.visible].
  custom,

  /// Show on secondary tap; outside taps close it.
  contextMenu,
}

/// A tooltip overlay following the Semi Design web Tooltip.
///
/// Port notes (see docs/semi_tooltip.md for the full difference list):
/// * [visible] is fully controlled when non-null: interaction events only call
///   [onVisibleChange] and never change visibility themselves (web is
///   semi-controlled and lets events mutate its own state).
/// * [zIndex] is kept for API parity but unused: the popup is inserted at the
///   top of the ambient [Overlay] in insertion order (web has no global
///   z-index mutex either).
/// * The popup follows scroll/transform through [CompositedTransformFollower];
///   the flip decision is not recomputed while scrolling.
class SemiTooltip extends StatefulWidget {
  const SemiTooltip({
    super.key,
    required this.content,
    required this.child,
    this.position = SemiTooltipPosition.top,
    this.trigger = SemiTooltipTrigger.hover,
    this.showArrow = true,
    this.arrowPointAtCenter = true,
    this.autoAdjustOverflow = true,
    this.spacing = 8,
    this.mouseEnterDelay = const Duration(milliseconds: 50),
    this.mouseLeaveDelay = const Duration(milliseconds: 50),
    this.clickToHide = false,
    this.closeOnEsc = false,
    this.visible,
    this.onVisibleChange,
    this.onClickOutSide,
    this.onEscKeyDown,
    this.motion = true,
    this.zIndex = 1060,
    this.repositionKey,
  });

  /// Popup body. Rendered inside the overlay with the tooltip theme text style.
  final Widget content;

  /// The trigger subtree.
  final Widget child;

  /// Preferred placement; auto-adjust may flip it (12 public placements).
  final SemiTooltipPosition position;

  /// Interaction mode.
  final SemiTooltipTrigger trigger;

  /// Whether to paint the small triangle.
  final bool showArrow;

  /// Anchor the arrow at the trigger center instead of the popup corner.
  final bool arrowPointAtCenter;

  /// Flip/expand/reduce/pin the placement when space is insufficient.
  final bool autoAdjustOverflow;

  /// Gap between trigger and popup along the placement axis.
  final double spacing;

  /// Hover/focus show delay (web `mouseEnterDelay`).
  final Duration mouseEnterDelay;

  /// Hover/focus hide delay (web `mouseLeaveDelay`).
  final Duration mouseLeaveDelay;

  /// Hide when the popup itself is tapped.
  final bool clickToHide;

  /// Consume Escape and close while visible. Escape is never consumed when
  /// false (it keeps propagating to ancestors).
  final bool closeOnEsc;

  /// Controlled visibility. Non-null makes the tooltip fully controlled:
  /// events only report through [onVisibleChange]. Null keeps an internal
  /// state.
  final bool? visible;

  /// Reports requested visibility changes (and, uncontrolled, actual ones).
  final ValueChanged<bool>? onVisibleChange;

  /// Called before closing because of a tap outside trigger and popup.
  final VoidCallback? onClickOutSide;

  /// Called when Escape is consumed (visible and [closeOnEsc]).
  final VoidCallback? onEscKeyDown;

  /// Whether the show/hide motion plays.
  final bool motion;

  /// Kept for API parity; overlay stacking is insertion order only.
  final int zIndex;

  /// Changing this value forces a reposition.
  final Object? repositionKey;

  @override
  State<SemiTooltip> createState() => _SemiTooltipState();
}

/// The 3 Sass declarations kept out of the theme: arrow correction factors and
/// a backdrop filter. See docs/semi_tooltip.md for the full mapping.
abstract final class _TooltipMetrics {
  /// `$horizontal-rate: 0.24` in packages/semi-foundation/tooltip/variables.scss.
  /// Sass-side correction factor behind the default `arrowAdjustedOffsetX`
  /// (0.24 * 24 = 5.76); kept for provenance.
  // ignore: unused_field
  static const double horizontalRate = 0.24;

  /// `$vertical-rate: 0` in packages/semi-foundation/tooltip/variables.scss.
  /// Corner-arrow vertical inset factor:
  /// `verticalRate * heightTooltipArrowVertical + arrowAdjustedOffsetY`.
  static const double verticalRate = 0;

  /// `$filter-tooltip-bg: none` in packages/semi-foundation/tooltip/variables.scss.
  /// Upstream `backdrop-filter` value is `none`, so no filter is applied.
  // ignore: unused_field
  static const String filter = 'none';
}

class _SemiTooltipState extends State<SemiTooltip>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  final GlobalKey _popupKey = GlobalKey();

  late final AnimationController _controller;
  CurvedAnimation? _curved;
  Animation<double>? _scale;
  Animation<double>? _opacity;

  OverlayEntry? _entry;
  Timer? _timer;
  CapturedThemes? _captured;
  TooltipPositionResult? _result;
  Offset _triggerOrigin = Offset.zero;
  bool _pendingShow = false;
  bool _showScheduled = false;
  bool _disposed = false;

  bool get _isControlled => widget.visible != null;

  bool get _effectiveVisible => _isControlled ? widget.visible! : _visible;
  bool _visible = false;

  bool get _reducedMotion =>
      !widget.motion ||
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
      !TickerMode.valuesOf(context).enabled;

  bool get _needsOutsideBarrier =>
      widget.trigger == SemiTooltipTrigger.click ||
      widget.trigger == SemiTooltipTrigger.contextMenu;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addStatusListener(_handleStatus);
    if (widget.visible == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) _show();
      });
    }
  }

  @override
  void didUpdateWidget(SemiTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible && _isControlled) {
      final wantShow = widget.visible!;
      _schedulePostFrame(() => wantShow ? _show() : _hide());
    }
    if (widget.repositionKey != oldWidget.repositionKey ||
        widget.position != oldWidget.position ||
        widget.spacing != oldWidget.spacing) {
      _schedulePostFrame(_reposition);
    }
    if (widget.content != oldWidget.content ||
        widget.showArrow != oldWidget.showArrow ||
        widget.clickToHide != oldWidget.clickToHide) {
      _schedulePostFrame(() => _entry?.markNeedsBuild());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedulePostFrame(_reposition);
  }

  /// Defers [fn] past the build phase: overlay insertion and controller
  /// ticks must not run while the tree is locked.
  void _schedulePostFrame(void Function() fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) fn();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    _clearTimer();
    _entry?.remove();
    _entry = null;
    _curved?.dispose();
    _controller.dispose();
    super.dispose();
  }

  // -- visibility pipeline --------------------------------------------------

  void _handleStatus(AnimationStatus status) {
    if (_disposed || _entry == null) return;
    switch (status) {
      case AnimationStatus.dismissed:
        _removeOverlay();
        if (_pendingShow) {
          _pendingShow = false;
          _show();
        }
      case AnimationStatus.completed:
        if (_pendingShow) {
          _pendingShow = false;
          _show();
        }
      default:
        break;
    }
  }

  /// Web `show()`. Re-opening during a running animation is parked in
  /// `_pendingShow` and replayed when the animation ends. The insertion is
  /// deferred to after the current frame so prop-driven shows never mutate the
  /// overlay during build.
  void _show() {
    if (_controller.isAnimating) {
      _pendingShow = true;
      return;
    }
    if (_entry != null || _showScheduled) return;
    _showScheduled = true;
    _clearTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showScheduled = false;
      if (_disposed || _entry != null || !_effectiveVisible) return;
      _insertOverlay();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _insertOverlay() {
    final resolved = SemiTooltipTheme.resolve(context);
    _configureAnimations(resolved);
    _result = null;
    _captured = InheritedTheme.capture(
      from: context,
      to: Overlay.of(context).context,
    );
    _entry = OverlayEntry(builder: _buildEntry);
    Overlay.of(context).insert(_entry!);
    WidgetsBinding.instance.addPostFrameCallback((_) => _firstPosition());
  }

  void _hide() {
    _pendingShow = false;
    _showScheduled = false;
    _clearTimer();
    if (_entry == null) return;
    if (_reducedMotion) {
      _controller.value = 0;
      _removeOverlay();
      return;
    }
    _controller.duration = SemiTooltipTheme.resolve(context)
        .animationDurationOut;
    _controller.reverse(from: _controller.value);
  }

  void _requestShow() {
    if (_isControlled) {
      if (widget.visible != true) widget.onVisibleChange?.call(true);
      return;
    }
    if (_entry != null || _showScheduled) return;
    _visible = true;
    widget.onVisibleChange?.call(true);
    _show();
  }

  void _requestHide() {
    if (_isControlled) {
      if (widget.visible != false) widget.onVisibleChange?.call(false);
      return;
    }
    if (_entry == null && !_showScheduled) return;
    _visible = false;
    widget.onVisibleChange?.call(false);
    _hide();
  }

  void _configureAnimations(SemiResolvedTooltipThemeData theme) {
    _curved?.dispose();
    _curved = CurvedAnimation(
      parent: _controller,
      curve: theme.animationFunctionIn,
      reverseCurve: theme.animationFunctionOut,
    );
    _scale = Tween<double>(
      begin: theme.zoomScaleFrom,
      end: 1,
    ).animate(_curved!);
    _opacity = Tween<double>(
      begin: theme.zoomOpacityFrom,
      end: theme.zoomOpacityTo,
    ).animate(_curved!);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    _result = null;
  }

  // -- delays (web shares a single timer between show and hide) --------------

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _delayShow() {
    _clearTimer();
    if (widget.mouseEnterDelay > Duration.zero) {
      _timer = Timer(widget.mouseEnterDelay, _requestShow);
    } else {
      _requestShow();
    }
  }

  void _delayHide() {
    _clearTimer();
    if (widget.mouseLeaveDelay > Duration.zero) {
      _timer = Timer(widget.mouseLeaveDelay, _requestHide);
    } else {
      _requestHide();
    }
  }

  // -- positioning ----------------------------------------------------------

  /// Waits for both popup dimensions before the first positioning (upstream
  /// renders the popup offscreen and only shows it once positioned).
  void _firstPosition() {
    if (_disposed || _entry == null) return;
    final popupBox = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (popupBox == null ||
        triggerBox == null ||
        !popupBox.hasSize ||
        !triggerBox.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _firstPosition());
      return;
    }
    _updatePosition(popupBox, triggerBox);
    if (_reducedMotion) {
      _controller.value = 1;
    } else {
      _controller.duration = SemiTooltipTheme.resolve(context)
          .animationDurationIn;
      _controller.forward(from: 0);
    }
    _entry?.markNeedsBuild();
  }

  void _reposition() {
    if (_entry == null || _result == null) return;
    final popupBox = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (popupBox == null ||
        triggerBox == null ||
        !popupBox.hasSize ||
        !triggerBox.hasSize) {
      return;
    }
    _updatePosition(popupBox, triggerBox);
    _entry?.markNeedsBuild();
  }

  void _updatePosition(RenderBox popupBox, RenderBox triggerBox) {
    _triggerOrigin = triggerBox.localToGlobal(Offset.zero);
    final triggerRect = TooltipRect(
      left: _triggerOrigin.dx,
      top: _triggerOrigin.dy,
      width: triggerBox.size.width,
      height: triggerBox.size.height,
    );
    final viewport = _viewportSize();
    final container = TooltipRect(
      left: 0,
      top: 0,
      width: viewport.width,
      height: viewport.height,
    );
    final resolved = SemiTooltipTheme.resolve(context);
    _result = positionTooltip(
      triggerRect: triggerRect,
      popupWidth: popupBox.size.width,
      popupHeight: popupBox.size.height,
      containerRect: container,
      viewportWidth: viewport.width,
      viewportHeight: viewport.height,
      position: widget.position,
      spacing: widget.spacing,
      autoAdjustOverflow: widget.autoAdjustOverflow,
      showArrow: widget.showArrow,
      arrowPointAtCenter: widget.arrowPointAtCenter,
      cornerInsetHorizontal: resolved.arrowAdjustedOffsetX,
      cornerInsetVertical:
          _TooltipMetrics.verticalRate * resolved.heightTooltipArrowVertical +
          resolved.arrowAdjustedOffsetY,
    );
  }

  Size _viewportSize() {
    final media = MediaQuery.maybeOf(context);
    if (media != null) return media.size;
    final view = View.of(context);
    return view.physicalSize / view.devicePixelRatio;
  }

  Offset get _followerOffset {
    final r = _result;
    if (r == null) return Offset.zero;
    return Offset(r.left - _triggerOrigin.dx, r.top - _triggerOrigin.dy);
  }

  Alignment get _originAlignment {
    final r = _result;
    if (r == null) return Alignment.center;
    return Alignment(
      r.transformOrigin.dx * 2 - 1,
      r.transformOrigin.dy * 2 - 1,
    );
  }

  // -- popup ----------------------------------------------------------------

  Widget _buildEntry(BuildContext entryContext) {
    final result = _result;
    return _captured!.wrap(
      Stack(
        clipBehavior: Clip.none,
        children: [
          if (_needsOutsideBarrier)
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handleOutsidePointer,
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: _followerOffset,
              child: FractionalTranslation(
                translation: Offset(
                  result?.translateX ?? 0,
                  result?.translateY ?? 0,
                ),
                child: MouseRegion(
                  onEnter: widget.trigger == SemiTooltipTrigger.hover
                      ? (_) => _delayShow()
                      : null,
                  onExit: widget.trigger == SemiTooltipTrigger.hover
                      ? (_) => _delayHide()
                      : null,
                  child: Opacity(
                    // Hidden until both popup dimensions are measured and the
                    // first position is computed (no first-frame flicker).
                    opacity: result == null ? 0 : 1,
                    child: FadeTransition(
                      opacity: _opacity ?? kAlwaysCompleteAnimation,
                      child: ScaleTransition(
                        scale: _scale ?? const AlwaysStoppedAnimation(1),
                        alignment: _originAlignment,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: widget.clickToHide
                              ? () => _requestHide()
                              : null,
                          child: SemiTooltipPopup(
                            key: _popupKey,
                            content: widget.content,
                            positionResult: result,
                            showArrow: widget.showArrow,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOutsidePointer(PointerDownEvent event) {
    final triggerBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    final popupBox = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    var inside = false;
    if (triggerBox != null && triggerBox.hasSize) {
      inside |= (triggerBox.localToGlobal(Offset.zero) & triggerBox.size)
          .contains(event.position);
    }
    if (popupBox != null && popupBox.hasSize) {
      inside |= (popupBox.localToGlobal(Offset.zero) & popupBox.size).contains(
        event.position,
      );
    }
    if (inside) return;
    widget.onClickOutSide?.call();
    _requestHide();
  }

  // -- trigger interaction --------------------------------------------------

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    if (!widget.closeOnEsc || !_effectiveVisible) {
      // Not consumed: Escape keeps propagating to ancestors.
      return KeyEventResult.ignored;
    }
    widget.onEscKeyDown?.call();
    if (widget.trigger != SemiTooltipTrigger.custom) {
      _requestHide();
    }
    return KeyEventResult.handled;
  }

  void _handleFocusChange(bool focused) {
    if (widget.trigger == SemiTooltipTrigger.focus ||
        widget.trigger == SemiTooltipTrigger.hover) {
      focused ? _delayShow() : _delayHide();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    switch (widget.trigger) {
      case SemiTooltipTrigger.click:
        child = GestureDetector(onTap: _requestShow, child: child);
      case SemiTooltipTrigger.contextMenu:
        child = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onSecondaryTapDown: (_) => _requestShow(),
          child: child,
        );
      case SemiTooltipTrigger.hover:
      case SemiTooltipTrigger.focus:
      case SemiTooltipTrigger.custom:
        break;
    }
    child = Focus(
      onKeyEvent: _handleKeyEvent,
      onFocusChange:
          widget.trigger == SemiTooltipTrigger.hover ||
              widget.trigger == SemiTooltipTrigger.focus
          ? _handleFocusChange
          : null,
      child: child,
    );
    if (widget.trigger == SemiTooltipTrigger.hover) {
      child = MouseRegion(
        onEnter: (_) => _delayShow(),
        onExit: (_) => _delayHide(),
        child: child,
      );
    }
    return CompositedTransformTarget(
      link: _link,
      key: _targetKey,
      child: child,
    );
  }
}

/// The popup surface: themed background, radius, padding, max width, text
/// style and the arrow. Exposes [placement]/[arrowOffset] for tests.
class SemiTooltipPopup extends StatelessWidget {
  const SemiTooltipPopup({
    super.key,
    required this.content,
    required this.positionResult,
    this.showArrow = true,
  });

  /// Popup body.
  final Widget content;

  /// Positioning result driving the arrow; null before first measurement.
  final TooltipPositionResult? positionResult;

  /// Whether the arrow paints.
  final bool showArrow;

  /// Placement after auto-adjust (may be one of the four `*Over` states).
  TooltipPlacement? get placement => positionResult?.placement;

  /// Arrow offset along the popup edge (50% fallback when [TooltipArrowOffset.fraction]
  /// is null).
  TooltipArrowOffset? get arrowOffset => positionResult?.arrowOffset;

  @override
  Widget build(BuildContext context) {
    final theme = SemiTooltipTheme.resolve(context);
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final padding = EdgeInsets.fromLTRB(
      rtl
          ? theme.spacingTooltipContentPaddingRight
          : theme.spacingTooltipContentPaddingLeft,
      theme.spacingTooltipContentPaddingTop,
      rtl
          ? theme.spacingTooltipContentPaddingLeft
          : theme.spacingTooltipContentPaddingRight,
      theme.spacingTooltipContentPaddingBottom,
    );
    final box = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: theme.widthTooltip),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorTooltipBgDefault,
          borderRadius: BorderRadius.circular(theme.radiusTooltip),
        ),
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: theme.colorTooltipTextDefault,
              fontSize: theme.fontSize,
            ),
            child: content,
          ),
        ),
      ),
    );
    final result = positionResult;
    if (!showArrow || result == null) return box;
    final tokens = SemiTheme.of(context).tooltip;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        box,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TooltipArrowPainter(
                placement: result.placement,
                arrowOffset: result.arrowOffset,
                // Upstream paints the triangle with the wrapper background so
                // it reads as part of the bubble; the dedicated arrow color
                // token defaults to the same channel.
                color: theme.colorTooltipArrowIconDefault,
                span: theme.widthTooltipArrow,
                verticalSpan: theme.heightTooltipArrowVertical,
                thickness: theme.heightTooltipArrow,
                verticalThickness: theme.widthTooltipArrowVertical,
                overlapX: theme.arrowOffsetX,
                overlapY: theme.arrowOffsetY,
                fallbackOffsetX: tokens.tooltipArrowOffsetX,
                fallbackOffsetY: tokens.tooltipArrowOffsetY,
                cornerInsetHorizontal: theme.arrowAdjustedOffsetX,
                cornerInsetVertical:
                    _TooltipMetrics.verticalRate *
                        theme.heightTooltipArrowVertical +
                    theme.arrowAdjustedOffsetY,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  _TooltipArrowPainter({
    required this.placement,
    required this.arrowOffset,
    required this.color,
    required this.span,
    required this.verticalSpan,
    required this.thickness,
    required this.verticalThickness,
    required this.overlapX,
    required this.overlapY,
    required this.fallbackOffsetX,
    required this.fallbackOffsetY,
    required this.cornerInsetHorizontal,
    required this.cornerInsetVertical,
  });

  final TooltipPlacement placement;
  final TooltipArrowOffset arrowOffset;
  final Color color;

  /// Along-edge arrow dimension (24 both ways upstream).
  final double span;
  final double verticalSpan;

  /// Perpendicular arrow dimension (7 both ways upstream).
  final double thickness;
  final double verticalThickness;

  /// 1px gap compensation overlapping the popup edge: [overlapX] on the
  /// left/right edges (`arrowOffsetX`), [overlapY] on the top/bottom edges
  /// (`arrowOffsetY`).
  final double overlapX;
  final double overlapY;

  /// Runtime 50% fallback tokens (`SemiTooltipTokens.tooltipArrowOffsetX/Y`).
  final SemiLength fallbackOffsetX;
  final SemiLength fallbackOffsetY;

  final double cornerInsetHorizontal;
  final double cornerInsetVertical;

  @override
  void paint(Canvas canvas, Size size) {
    final edge = placement.arrowEdge;
    final horizontal =
        edge == TooltipArrowEdge.top || edge == TooltipArrowEdge.bottom;
    final alongSpan = horizontal ? span : verticalSpan;
    final thick = horizontal ? thickness : verticalThickness;
    final extent = horizontal ? size.width : size.height;

    double center;
    if (placement.isCenter) {
      final fraction = arrowOffset.fraction;
      center = fraction != null
          ? fraction * extent
          : (horizontal ? fallbackOffsetX : fallbackOffsetY).resolve(extent);
    } else {
      final inset = horizontal ? cornerInsetHorizontal : cornerInsetVertical;
      final atStart = switch (placement) {
        TooltipPlacement.topLeft ||
        TooltipPlacement.bottomLeft ||
        TooltipPlacement.leftTop ||
        TooltipPlacement.rightTop ||
        TooltipPlacement.leftTopOver ||
        TooltipPlacement.rightTopOver => true,
        _ => false,
      };
      center = atStart ? inset + alongSpan / 2 : extent - inset - alongSpan / 2;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // The upstream arrow is the curved "wing" from TriangleArrow(.Vertical).tsx
    // scaled to the theme dimensions and rotated 180° for the opposite edge,
    // exactly like arrow.scss does with `transform: rotate(180deg)`.
    canvas.save();
    switch (edge) {
      case TooltipArrowEdge.bottom:
        canvas
          ..translate(center - alongSpan / 2, size.height - overlapY)
          ..scale(alongSpan / 24, thick / 7);
        canvas.drawPath(tooltipArrowWingHorizontal(), paint);
      case TooltipArrowEdge.top:
        canvas
          ..translate(center + alongSpan / 2, overlapY)
          ..rotate(math.pi)
          ..scale(alongSpan / 24, thick / 7);
        canvas.drawPath(tooltipArrowWingHorizontal(), paint);
      case TooltipArrowEdge.right:
        canvas
          ..translate(size.width - overlapY, center - alongSpan / 2)
          ..scale(thick / 7, alongSpan / 24);
        canvas.drawPath(tooltipArrowWingVertical(), paint);
      case TooltipArrowEdge.left:
        canvas
          ..translate(overlapY, center + alongSpan / 2)
          ..rotate(math.pi)
          ..scale(thick / 7, alongSpan / 24);
        canvas.drawPath(tooltipArrowWingVertical(), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TooltipArrowPainter oldDelegate) =>
      placement != oldDelegate.placement ||
      arrowOffset != oldDelegate.arrowOffset ||
      color != oldDelegate.color ||
      span != oldDelegate.span ||
      verticalSpan != oldDelegate.verticalSpan ||
      thickness != oldDelegate.thickness ||
      verticalThickness != oldDelegate.verticalThickness ||
      overlapX != oldDelegate.overlapX ||
      overlapY != oldDelegate.overlapY ||
      fallbackOffsetX != oldDelegate.fallbackOffsetX ||
      fallbackOffsetY != oldDelegate.fallbackOffsetY ||
      cornerInsetHorizontal != oldDelegate.cornerInsetHorizontal ||
      cornerInsetVertical != oldDelegate.cornerInsetVertical;
}
