import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
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
    this.popupBare = false,
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
    this.arrowColor,
    this.arrowFringeColor,
    this.arrowBoundingOffsetY = tooltipArrowBoundingOffsetY,
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

  /// Skip the tooltip bubble decoration: no background, padding, radius,
  /// arrow or max width are applied, and [content] paints its own surface
  /// (SemiDropdown's menu wrapper). Positioning still measures the content.
  final bool popupBare;

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

  /// Arrow fill override (null keeps `colorTooltipArrowIconDefault`). The
  /// popover-family bare popups (SemiPopconfirm) pass their bubble background
  /// so the wing reads as part of their own surface.
  final Color? arrowColor;

  /// Optional outline pass painted under the wing fill (popover arrow
  /// `path:nth-child(1)`, `fill: var(--semi-color-border)`). Null keeps the
  /// single-fill tooltip arrow.
  final Color? arrowFringeColor;

  /// Small-trigger arrow correction constant (upstream `arrowBounding.offsetY`
  /// — 2 for the tooltip, 6 for the popover family).
  final double arrowBoundingOffsetY;

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

/// Pointer-exemption registry for overlay popups (SemiDropdown's nested menu
/// requirement). An [SemiOverlayPointerExempt] scope wraps each popup's
/// content; a nested popup registers its global rect into the nearest ancestor
/// scope, and [SemiOverlayPointerExemptScope.addRegion] propagates the same
/// provider up the scope chain so multi-level nests stay exempt for every
/// ancestor while sibling scopes never see each other's regions.
class SemiOverlayPointerExemptScope {
  SemiOverlayPointerExemptScope({this.parent});

  /// The scope wrapping the popup that contains this popup's trigger (null at
  /// the top level).
  final SemiOverlayPointerExemptScope? parent;

  final List<Rect? Function()> _regions = [];

  /// Adds a region provider to this scope and every ancestor scope.
  void addRegion(Rect? Function() region) {
    _regions.add(region);
    parent?.addRegion(region);
  }

  /// Removes a provider previously added with [addRegion] (all scopes).
  void removeRegion(Rect? Function() region) {
    _regions.remove(region);
    parent?.removeRegion(region);
  }

  /// Whether [globalPosition] hits any region registered on this scope.
  bool exemptAt(Offset globalPosition) {
    for (final region in _regions) {
      final rect = region();
      if (rect != null && rect.contains(globalPosition)) {
        return true;
      }
    }
    return false;
  }
}

/// Wraps a popup's content with its [SemiOverlayPointerExemptScope] so nested
/// popups built inside it can register their regions on the right scope.
class SemiOverlayPointerExempt extends InheritedWidget {
  const SemiOverlayPointerExempt({
    super.key,
    required this.scope,
    required super.child,
  });

  final SemiOverlayPointerExemptScope scope;

  /// The nearest enclosing popup scope, or null outside any popup.
  static SemiOverlayPointerExemptScope? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SemiOverlayPointerExempt>()
      ?.scope;

  @override
  bool updateShouldNotify(SemiOverlayPointerExempt oldWidget) =>
      scope != oldWidget.scope;
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

  /// hover 展示只认真实指针移动（web mouseenter 语义）：布局变化把触发器推
  /// 到静止光标下时 Flutter 会合成 MouseRegion enter，上游不会弹 tooltip。
  bool _hoverArmed = false;

  /// Scope for popups nested inside this popup (exists while the entry lives).
  SemiOverlayPointerExemptScope? _exemptScope;

  /// Scope of the popup this tooltip's trigger lives in (null at top level).
  SemiOverlayPointerExemptScope? _ancestorScope;

  /// Stable identity so registration and removal match.
  late final Rect? Function() _exemptRegion = _popupGlobalRect;

  /// Owned so the focus trigger can request focus on click/tap (a bare [Focus]
  /// never gains focus from pointer input on its own).
  final FocusNode _focusNode = FocusNode();

  bool get _isControlled => widget.visible != null;

  bool get _effectiveVisible => _isControlled ? widget.visible! : _visible;
  bool _visible = false;

  bool get _reducedMotion =>
      !widget.motion ||
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
      !TickerMode.valuesOf(context).enabled;

  bool get _needsOutsideBarrier =>
      widget.trigger == SemiTooltipTrigger.click ||
      widget.trigger == SemiTooltipTrigger.contextMenu ||
      widget.trigger == SemiTooltipTrigger.focus ||
      // Managed-visibility custom consumers (SemiAutoComplete) need the
      // outside tap to report `onVisibleChange(false)`; visibility itself
      // stays caller-driven.
      widget.trigger == SemiTooltipTrigger.custom;

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
        widget.spacing != oldWidget.spacing ||
        widget.arrowBoundingOffsetY != oldWidget.arrowBoundingOffsetY) {
      _schedulePostFrame(_reposition);
    }
    if (widget.content != oldWidget.content ||
        widget.showArrow != oldWidget.showArrow ||
        widget.popupBare != oldWidget.popupBare ||
        widget.clickToHide != oldWidget.clickToHide ||
        widget.arrowColor != oldWidget.arrowColor ||
        widget.arrowFringeColor != oldWidget.arrowFringeColor) {
      _schedulePostFrame(() => _entry?.markNeedsBuild());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ancestorScope = SemiOverlayPointerExempt.maybeOf(context);
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
    _ancestorScope?.removeRegion(_exemptRegion);
    _entry?.remove();
    _entry = null;
    _curved?.dispose();
    _controller.dispose();
    _focusNode.dispose();
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
    _exemptScope = SemiOverlayPointerExemptScope(parent: _ancestorScope);
    if (_ancestorScope != null) {
      _ancestorScope!.addRegion(_exemptRegion);
    }
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
    _ancestorScope?.removeRegion(_exemptRegion);
    _entry?.remove();
    _entry = null;
    _result = null;
    _exemptScope = null;
  }

  /// Global rect of this tooltip's popup (null before the first layout).
  Rect? _popupGlobalRect() {
    final box = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
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
      arrowBoundingOffsetY: widget.arrowBoundingOffsetY,
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
    if (r == null) {
      // Park the un-measured popup off the trigger: before the first
      // position is computed the follower sits at the trigger origin, and
      // the popup's MouseRegion would steal its own trigger's hover for a
      // frame — hover-driven tooltips flapped on a 3-frame cycle (the mouse
      // cursor flickered over slider handles). Upstream inserts the portal
      // only after positioning; parking until measured mirrors that.
      return const Offset(0, -1000);
    }
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
                        child: _PointerTapArea(
                          // ★GestureDetector 会输给弹层内条目自己的手势竞技场
                          // （内层胜出——点条目关不掉）；上游 clickToHide 是 DOM
                          // click 监听恒观察子点击（同 _PointerTapArea 立论）。
                          onUpInside: widget.clickToHide
                              ? (_) => _requestHide()
                              : null,
                          child: SemiOverlayPointerExempt(
                            // Nested popups register their regions here; the
                            // scope chain links them to this tooltip's own
                            // ancestor scope.
                            scope: _exemptScope!,
                            // Popup-side twin of the trigger's key handler:
                            // the focus chain of content inside the overlay
                            // never passes through the trigger node.
                            child: Focus(
                              onKeyEvent: _handleKeyEvent,
                              child: SemiTooltipPopup(
                                key: _popupKey,
                                content: widget.content,
                                positionResult: result,
                                showArrow: widget.showArrow,
                                popupBare: widget.popupBare,
                                arrowColor: widget.arrowColor,
                                arrowFringeColor: widget.arrowFringeColor,
                              ),
                            ),
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
    // Popups nested inside this popup (registered rects) are not "outside".
    inside |= _exemptScope?.exemptAt(event.position) ?? false;
    if (inside) return;
    // Blur like the browser does when clicking outside a focused element, so
    // the trigger leaves the focused state for every trigger kind.
    _focusNode.unfocus();
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

  /// Touch fallback for the hover trigger: emulators and touch devices never
  /// produce hover events, so a touch tap toggles visibility directly. Mouse
  /// (and stylus) taps are ignored to keep upstream click semantics.
  void _handleHoverTapUp(PointerUpEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    if (_effectiveVisible) {
      _requestHide();
    } else {
      _requestShow();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    switch (widget.trigger) {
      case SemiTooltipTrigger.click:
        // Focus on press like a focusable web element, so closeOnEsc can
        // receive the key from the trigger's Focus node.
        child = _PointerTapArea(
          onDown: (_) => _focusNode.requestFocus(),
          onUpInside: (_) => _requestShow(),
          child: child,
        );
      case SemiTooltipTrigger.contextMenu:
        child = _PointerTapArea(
          onDown: (event) {
            if (event.buttons & kSecondaryMouseButton == 0) return;
            _focusNode.requestFocus();
            _requestShow();
          },
          child: child,
        );
      case SemiTooltipTrigger.hover:
        // Touch devices (mobile, emulators) never emit hover events, so the
        // hover trigger would be unreachable there. Taps from touch pointers
        // toggle the tooltip instead; mouse clicks keep the upstream hover
        // semantics and never toggle.
        child = _PointerTapArea(onUpInside: _handleHoverTapUp, child: child);
      case SemiTooltipTrigger.focus:
        // Flutter does not move focus on pointer input by itself (upstream is
        // DOM click-to-focus); request it explicitly so click/tap shows the
        // tooltip like a focusable web element.
        child = _PointerTapArea(
          onDown: (_) => _focusNode.requestFocus(),
          child: child,
        );
      case SemiTooltipTrigger.custom:
        break;
    }
    child = Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      onFocusChange:
          widget.trigger == SemiTooltipTrigger.hover ||
              widget.trigger == SemiTooltipTrigger.focus
          ? _handleFocusChange
          : null,
      child: child,
    );
    if (widget.trigger == SemiTooltipTrigger.hover) {
      // `onPointerHover` 只随真实指针移动触发（合成 enter 无 hover 事件），
      // 对齐 web mouseenter：收起侧边栏后光标不动不闪「展开侧边栏」。
      child = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: (_) {
          if (_hoverArmed) return;
          _hoverArmed = true;
          _delayShow();
        },
        child: MouseRegion(
          onExit: (_) {
            _hoverArmed = false;
            _delayHide();
          },
          child: child,
        ),
      );
    }
    return CompositedTransformTarget(
      link: _link,
      key: _targetKey,
      child: child,
    );
  }
}

/// Arena-free pointer tap detection for trigger activation.
///
/// A wrapping [GestureDetector] competes in the gesture arena with the
/// child's own recognizers and loses: the innermost recognizer wins, so a
/// trigger wrapping an interactive child (e.g. a `SemiButton` with
/// `onPressed`) would never activate. Upstream Trigger binds DOM click
/// listeners that always observe child clicks — a [Listener] mirrors that
/// semantics. [onUpInside] fires only when the pointer is released within the
/// trigger bounds (DOM click: down and up on the element).
class _PointerTapArea extends StatelessWidget {
  const _PointerTapArea({required this.child, this.onDown, this.onUpInside});

  final Widget child;
  final ValueChanged<PointerDownEvent>? onDown;
  final ValueChanged<PointerUpEvent>? onUpInside;

  @override
  Widget build(BuildContext context) {
    Offset? downPosition;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        downPosition = event.position;
        onDown?.call(event);
      },
      onPointerUp: (event) {
        final down = downPosition;
        downPosition = null;
        if (down == null || onUpInside == null) return;
        // The trigger subtree may unmount while the pointer is held (e.g. a
        // drag reorders the list this hover tooltip sits on) — a defunct
        // element's renderObject would throw mid-dispatch.
        if (!context.mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        if ((box.localToGlobal(Offset.zero) & box.size).contains(
          event.position,
        )) {
          onUpInside!(event);
        }
      },
      onPointerCancel: (_) {
        downPosition = null;
      },
      child: child,
    );
  }
}

/// The popup surface: themed background, radius, padding, max width, text
/// style and the arrow. Exposes [placement]/[arrowOffset] for tests. With
/// [popupBare] the bubble decoration is skipped entirely and [content] paints
/// its own surface.
class SemiTooltipPopup extends StatelessWidget {
  const SemiTooltipPopup({
    super.key,
    required this.content,
    required this.positionResult,
    this.showArrow = true,
    this.popupBare = false,
    this.arrowColor,
    this.arrowFringeColor,
  });

  /// Popup body.
  final Widget content;

  /// Positioning result driving the arrow; null before first measurement.
  final TooltipPositionResult? positionResult;

  /// Whether the arrow paints.
  final bool showArrow;

  /// Skip the bubble decoration (SemiTooltip.popupBare).
  final bool popupBare;

  /// Arrow fill override (SemiTooltip.arrowColor).
  final Color? arrowColor;

  /// Optional outline pass under the wing fill (SemiTooltip.arrowFringeColor).
  final Color? arrowFringeColor;

  /// Placement after auto-adjust (may be one of the four `*Over` states).
  TooltipPlacement? get placement => positionResult?.placement;

  /// Arrow offset along the popup edge (50% fallback when [TooltipArrowOffset.fraction]
  /// is null).
  TooltipArrowOffset? get arrowOffset => positionResult?.arrowOffset;

  @override
  Widget build(BuildContext context) {
    final result = positionResult;
    final withArrow = showArrow && result != null;
    if (popupBare) {
      // Bare popups paint their own surface; the arrow still rides along the
      // measured content edge (SemiPopconfirm's popover wing).
      if (!withArrow) return content;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _arrowPainter(context, result)),
            ),
          ),
        ],
      );
    }
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
    if (!withArrow) return box;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        box,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _arrowPainter(context, result)),
          ),
        ),
      ],
    );
  }

  _TooltipArrowPainter _arrowPainter(
    BuildContext context,
    TooltipPositionResult result,
  ) {
    final theme = SemiTooltipTheme.resolve(context);
    final tokens = SemiTheme.of(context).tooltip;
    return _TooltipArrowPainter(
      placement: result.placement,
      arrowOffset: result.arrowOffset,
      // Upstream paints the triangle with the wrapper background so
      // it reads as part of the bubble; the dedicated arrow color
      // token defaults to the same channel.
      color: arrowColor ?? theme.colorTooltipArrowIconDefault,
      fringeColor: arrowFringeColor,
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
          _TooltipMetrics.verticalRate * theme.heightTooltipArrowVertical +
          theme.arrowAdjustedOffsetY,
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
    this.fringeColor,
  });

  final TooltipPlacement placement;
  final TooltipArrowOffset arrowOffset;
  final Color color;

  /// Optional outline pass painted under the fill (popover arrow
  /// `path:nth-child(1)`); null keeps the single-fill tooltip arrow.
  final Color? fringeColor;

  /// Along-edge arrow dimension (24 both ways upstream).
  final double span;
  final double verticalSpan;

  /// Perpendicular arrow dimension: the upstream icon element box height
  /// (`height: $height-tooltip_arrow` — 7 for the tooltip wing, 8 for the
  /// popover-family box whose fringe pass overhangs the 7px wing by 1px).
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
    // exactly like arrow.scss does with `transform: rotate(180deg)`. Native
    // shape boxes: the wing path is 24x7 (7x24 vertical); with the fringe pass
    // (`path:nth-child(1)`, 24x8) the box grows 1px past the wing — that 8 is
    // the upstream `height: $height-tooltip_arrow` in the popover scope, so
    // [thickness] is normalized by the drawn shape's box height.
    final nativeBox = fringeColor != null ? 8 : 7;
    final boxScale = thick / nativeBox;
    canvas.save();
    void drawWing(Path horizontal, Path vertical) {
      switch (edge) {
        case TooltipArrowEdge.bottom:
          canvas
            ..translate(center - alongSpan / 2, size.height - overlapY)
            ..scale(alongSpan / 24, boxScale);
          canvas.drawPath(horizontal, paint);
        case TooltipArrowEdge.top:
          canvas
            ..translate(center + alongSpan / 2, overlapY)
            ..rotate(math.pi)
            ..scale(alongSpan / 24, boxScale);
          canvas.drawPath(horizontal, paint);
        case TooltipArrowEdge.right:
          canvas
            ..translate(size.width - overlapY, center - alongSpan / 2)
            ..scale(boxScale, alongSpan / 24);
          canvas.drawPath(vertical, paint);
        case TooltipArrowEdge.left:
          canvas
            ..translate(overlapY, center + alongSpan / 2)
            ..rotate(math.pi)
            ..scale(boxScale, alongSpan / 24);
          canvas.drawPath(vertical, paint);
      }
    }

    final fringe = fringeColor;
    if (fringe != null) {
      // Popover arrow `path:nth-child(1)` — the outline pass, painted under
      // the fill so only its 0.5–1px rim shows around the wing.
      paint.color = fringe;
      drawWing(tooltipArrowFringeHorizontal(), tooltipArrowFringeVertical());
      canvas.restore();
      canvas.save();
    }
    paint.color = color;
    drawWing(tooltipArrowWingHorizontal(), tooltipArrowWingVertical());
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TooltipArrowPainter oldDelegate) =>
      placement != oldDelegate.placement ||
      arrowOffset != oldDelegate.arrowOffset ||
      color != oldDelegate.color ||
      fringeColor != oldDelegate.fringeColor ||
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
