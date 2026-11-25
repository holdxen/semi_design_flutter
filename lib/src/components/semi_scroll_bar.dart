import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_scroll_bar_theme.dart';

/// A Semi-styled overlay scrollbar.
///
/// Ports the official `.semi-light-scrollbar` WebKit rules: an 8px track-less
/// thumb with a 6px radius that reveals on content hover (and, as with
/// [RawScrollbar], while scrolling), then uses `--semi-color-fill-2`; hovering
/// the thumb itself switches to `--semi-color-fill-1`. Both colors resolve from
/// the Semi theme, so light and dark mode adapt automatically.
///
/// [child] (or a descendant) must be a scrollable, and [controller] should be
/// shared with it when one is supplied. Without a controller, the nearest
/// [PrimaryScrollController] is used, matching [RawScrollbar].
class SemiScrollBar extends StatefulWidget {
  const SemiScrollBar({
    super.key,
    required this.child,
    this.controller,
    this.thumbVisibility,
    this.showOnHover = true,
    this.interactive = true,
    this.thickness,
    this.radius,
    this.thumbColor,
    this.thumbHoverColor,
    this.minThumbLength,
    this.crossAxisMargin,
    this.mainAxisMargin,
    this.fadeDuration,
    this.timeToFade,
    this.padding,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  }) : assert(thickness == null || thickness >= 0),
       assert(minThumbLength == null || minThumbLength >= 0),
       assert(crossAxisMargin == null || crossAxisMargin >= 0),
       assert(mainAxisMargin == null || mainAxisMargin >= 0);

  /// The scrollable subtree the scrollbar is painted over.
  final Widget child;

  /// Controller shared with the scrollable. Defaults to the nearest
  /// [PrimaryScrollController].
  final ScrollController? controller;

  /// Keeps the thumb visible regardless of hover state.
  final bool? thumbVisibility;

  /// Reveals the thumb while the pointer is anywhere over [child].
  ///
  /// This mirrors the CSS `:hover` selector on `.semi-light-scrollbar`.
  final bool showOnHover;

  /// Whether the thumb can be dragged.
  final bool interactive;

  /// Thumb thickness. Defaults to the Semi value of 8.
  final double? thickness;

  /// Thumb corner radius. Defaults to the Semi value of 6.
  final Radius? radius;

  /// Thumb color while the content is hovered.
  final Color? thumbColor;

  /// Thumb color while the thumb itself is hovered.
  final Color? thumbHoverColor;

  /// Smallest thumb length in logical pixels.
  final double? minThumbLength;

  /// Distance from the scrollbar to the nearest edge.
  final double? crossAxisMargin;

  /// Distance from the scrollbar's start/end to the viewport edge.
  final double? mainAxisMargin;

  /// Fade-in/fade-out duration. Defaults to the CSS transition of 1 second.
  final Duration? fadeDuration;

  /// Delay before hiding after the pointer leaves.
  final Duration? timeToFade;

  /// Insets used when painting, defaulting to the ambient [MediaQuery] padding.
  final EdgeInsetsGeometry? padding;

  /// Predicate deciding which [ScrollNotification]s drive the scrollbar.
  final ScrollNotificationPredicate notificationPredicate;

  @override
  State<SemiScrollBar> createState() => _SemiScrollBarState();
}

class _SemiScrollBarState extends State<SemiScrollBar> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (value == _hovered) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiScrollBarTheme.resolve(context);
    final visible =
        (widget.thumbVisibility ?? false) || (widget.showOnHover && _hovered);
    // On desktop the ambient ScrollBehavior already wraps every Scrollable in
    // its own RawScrollbar; suppress it or two thumbs would be painted.
    final scrollBehavior = ScrollConfiguration.of(context)
        .copyWith(scrollbars: false);

    final bar = _SemiRawScrollbar(
      controller: widget.controller,
      thumbVisibility: visible,
      thickness: widget.thickness ?? theme.thickness,
      radius: widget.radius ?? theme.radius,
      thumbColor: widget.thumbColor ?? theme.thumbColor,
      thumbHoverColor: widget.thumbHoverColor ?? theme.thumbHoverColor,
      minThumbLength: widget.minThumbLength ?? theme.minThumbLength,
      crossAxisMargin: widget.crossAxisMargin ?? theme.crossAxisMargin,
      mainAxisMargin: widget.mainAxisMargin ?? theme.mainAxisMargin,
      fadeDuration: widget.fadeDuration ?? theme.fadeDuration,
      timeToFade: widget.timeToFade ?? theme.timeToFade,
      padding: widget.padding,
      interactive: widget.interactive,
      notificationPredicate: widget.notificationPredicate,
      child: ScrollConfiguration(behavior: scrollBehavior, child: widget.child),
    );

    if (!widget.showOnHover) return bar;
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: bar,
    );
  }
}

class _SemiRawScrollbar extends RawScrollbar {
  const _SemiRawScrollbar({
    required super.child,
    super.controller,
    super.thumbVisibility,
    super.thickness,
    super.radius,
    required Color thumbColor,
    required this.thumbHoverColor,
    super.minThumbLength,
    super.crossAxisMargin,
    super.mainAxisMargin,
    super.fadeDuration,
    super.timeToFade,
    super.padding,
    super.interactive,
    super.notificationPredicate,
  }) : super(thumbColor: thumbColor);

  final Color thumbHoverColor;

  @override
  RawScrollbarState<_SemiRawScrollbar> createState() =>
      _SemiRawScrollbarState();
}

class _SemiRawScrollbarState extends RawScrollbarState<_SemiRawScrollbar> {
  bool _thumbHovered = false;

  @override
  void updateScrollbarPainter() {
    super.updateScrollbarPainter();
    scrollbarPainter.color = _thumbHovered
        ? widget.thumbHoverColor
        : (widget.thumbColor ?? const Color(0x00000000));
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    final hovered = isPointerOverThumb(event.position, event.kind);
    if (hovered != _thumbHovered) {
      setState(() => _thumbHovered = hovered);
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    if (_thumbHovered) setState(() => _thumbHovered = false);
  }
}
