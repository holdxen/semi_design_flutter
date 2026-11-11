import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_collapse_theme.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'typography/semi_text.dart';

/// Upstream `expandIconPosition` (`packages/semi-ui/collapse/index.tsx`):
/// which header side hosts the expand/collapse arrow.
enum SemiCollapseIconPosition { left, right }

/// Semi accordion-style collapse. Children are [SemiCollapsePanel]s; the
/// activation set is ordered (LinkedHashSet semantics: toggling on appends,
/// toggling off removes).
///
/// [activeKeys] non-null means fully controlled — interactions only report
/// [onActiveKeysChanged] and never mutate internal state. Upstream's falsy
/// `activeKey: ''` trap is not reproduced: an empty set is controlled too.
/// [onActiveKeysChanged] always receives the ordered result.
class SemiCollapse extends StatefulWidget {
  const SemiCollapse({
    super.key,
    this.activeKeys,
    this.defaultActiveKeys = const {},
    this.accordion = false,
    this.clickHeaderToExpand = true,
    this.expandIcon,
    this.collapseIcon,
    this.expandIconPosition = SemiCollapseIconPosition.right,
    this.keepDOM = false,
    this.lazyRender = false,
    this.motion = true,
    this.onActiveKeysChanged,
    required this.children,
  });

  /// Ordered active keys. Non-null makes the collapse fully controlled.
  final Set<String>? activeKeys;

  /// Ordered initial keys when [activeKeys] is null. With [accordion] only
  /// the first key stays active at init (upstream `initActiveKey`).
  final Set<String> defaultActiveKeys;

  /// Only one panel active at a time; clicking the active panel collapses
  /// everything and reports `[]` (upstream `handleChange`).
  final bool accordion;

  /// When false only the arrow area toggles a panel (upstream
  /// `clickHeaderToExpand`).
  final bool clickHeaderToExpand;

  /// Collapsed-state arrow. Defaults to `SemiIcons.chevronDown`.
  final Widget? expandIcon;

  /// Expanded-state arrow. Defaults to `SemiIcons.chevronUp`.
  final Widget? collapseIcon;

  /// Arrow side (upstream `expandIconPosition`).
  final SemiCollapseIconPosition expandIconPosition;

  /// Keep collapsed content built with zero height (upstream `keepDOM`).
  /// Content state survives collapse; without it the content subtree is
  /// destroyed when the collapse animation settles.
  final bool keepDOM;

  /// Build panel content on first open only (upstream `lazyRender`). Gates
  /// the [keepDOM] content and initial mounting.
  final bool lazyRender;

  /// Animate height transitions (upstream `motion`). Disabled under
  /// `TickerMode`/`MediaQuery.disableAnimations`.
  final bool motion;

  /// Reports every toggle with the ordered resulting keys.
  final ValueChanged<List<String>>? onActiveKeysChanged;

  /// Panels (upstream `children`/`Collapse.Panel`).
  final List<SemiCollapsePanel> children;

  @override
  State<SemiCollapse> createState() => _SemiCollapseState();
}

class _SemiCollapseState extends State<SemiCollapse> {
  late Set<String> _activeSet;

  Set<String> get _effective => widget.activeKeys ?? _activeSet;

  @override
  void initState() {
    super.initState();
    final initial = Set<String>.of(widget.defaultActiveKeys);
    _activeSet = widget.accordion && initial.length > 1
        ? <String>{initial.first}
        : initial;
  }

  void _handleToggle(String itemKey) {
    final newSet = Set<String>.of(_effective);
    if (newSet.contains(itemKey)) {
      newSet.remove(itemKey);
    } else if (widget.accordion) {
      newSet
        ..clear()
        ..add(itemKey);
    } else {
      newSet.add(itemKey);
    }
    widget.onActiveKeysChanged?.call(newSet.toList(growable: false));
    if (widget.activeKeys == null) {
      setState(() => _activeSet = newSet);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      final seen = <String>{};
      for (final panel in widget.children) {
        if (!seen.add(panel.itemKey)) {
          throw FlutterError(
            'SemiCollapse requires unique SemiCollapsePanel.itemKey values, '
            'found duplicate "${panel.itemKey}".',
          );
        }
      }
      return true;
    }());
    return _CollapseScope(
      data: _CollapseScopeData(
        activeSet: _effective,
        expandIcon: widget.expandIcon,
        collapseIcon: widget.collapseIcon,
        clickHeaderToExpand: widget.clickHeaderToExpand,
        keepDOM: widget.keepDOM,
        lazyRender: widget.lazyRender,
        motion: widget.motion,
        expandIconPosition: widget.expandIconPosition,
        onToggle: _handleToggle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final panel in widget.children)
            KeyedSubtree(key: ValueKey<String>(panel.itemKey), child: panel),
        ],
      ),
    );
  }
}

/// One collapsible panel (upstream `Collapse.Panel`/`item.tsx`). [header] is
/// a [String] (rendered as [SemiText] with the themed header style) or a
/// [Widget] placed as-is. Unlike upstream the [extra] slot always renders,
/// at the header's right end.
class SemiCollapsePanel extends StatefulWidget {
  const SemiCollapsePanel({
    super.key,
    required this.itemKey,
    this.header,
    this.extra,
    this.showArrow = true,
    this.disabled = false,
    this.child,
    this.reCalcKey,
    this.onMotionEnd,
  }) : assert(
         header == null || header is String || header is Widget,
         'header must be a String or a Widget',
       );

  /// Unique key inside the owning [SemiCollapse] (upstream `itemKey`).
  final String itemKey;

  /// Header content: [String] or [Widget] (upstream `header`).
  final Object? header;

  /// Right-end header aux content (upstream `extra`). Always rendered; the
  /// 8px `spacingCollapseRightPaddingRight` gap applies only when the arrow
  /// shares the trailing block (upstream `header-right` last-child rule).
  final Widget? extra;

  /// Show the expand/collapse arrow (upstream `showArrow`).
  final bool showArrow;

  /// No toggling, disabled colors, keyboard ignored (upstream `disabled`).
  final bool disabled;

  /// Panel content (upstream `children`).
  final Widget? child;

  /// Height re-measure trigger (upstream `reCalcKey`). The port keeps no
  /// cached content height (expanded height follows content continuously),
  /// so a change only forces a rebuild — kept for API parity.
  final Object? reCalcKey;

  /// Called when the collapse (reverse) animation settles (upstream
  /// `onMotionEnd` on transition end; the 50ms fallback timer is replaced by
  /// the controller's dismissed status). Not called when `motion` is off.
  final VoidCallback? onMotionEnd;

  @override
  State<SemiCollapsePanel> createState() => _SemiCollapsePanelState();
}

class _SemiCollapsePanelState extends State<SemiCollapsePanel>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _controller = AnimationController(vsync: this);
  late _CollapseScopeData _scope;
  bool _initialized = false;
  bool _lastActive = false;
  bool _hasBeenActive = false;
  bool _transitioning = false;
  bool _hovering = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = _CollapseScope.of(context);
    _controller.duration = SemiCollapseTheme.resolve(context).animationDuration;
    _syncActive(_scope.activeSet.contains(widget.itemKey));
  }

  bool get _animationsEnabled =>
      _scope.motion &&
      TickerMode.valuesOf(context).enabled &&
      !MediaQuery.disableAnimationsOf(context);

  void _syncActive(bool active) {
    if (!_initialized) {
      // No entrance animation on first mount (upstream transition is not
      // armed for the initial render).
      _initialized = true;
      _lastActive = active;
      if (active) _hasBeenActive = true;
      _controller.value = active ? 1 : 0;
      return;
    }
    if (active == _lastActive) return;
    _lastActive = active;
    if (active) _hasBeenActive = true;
    if (_animationsEnabled) {
      _transitioning = true;
      if (active) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else {
      _controller.value = active ? 1 : 0;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    final wasTransitioning = _transitioning;
    _transitioning = false;
    if (wasTransitioning) {
      // The collapse transition settled: drop hidden content and report.
      widget.onMotionEnd?.call();
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(SemiCollapsePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reCalcKey != widget.reCalcKey) {
      // Content height follows layout continuously; a reCalcKey change only
      // needs a rebuild (kept for upstream API parity).
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter && key != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    if (widget.disabled || FocusManager.instance.primaryFocus != node) {
      // Upstream ignores events from descendants and disabled panels.
      return KeyEventResult.ignored;
    }
    // Upstream preventDefaults, then clicks the header — or the arrow
    // trigger when clickHeaderToExpand is false, which only toggles when the
    // arrow exists.
    if (_scope.clickHeaderToExpand || widget.showArrow) {
      _scope.onToggle(widget.itemKey);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiCollapseTheme.resolve(context);
    final fontSize = SemiTheme.of(context).typography.fontSizeRegular;
    final active = _scope.activeSet.contains(widget.itemKey);
    final enable = widget.child != null && !widget.disabled;
    final headerColor = widget.disabled
        ? theme.colorCollapseHeaderTextDisabled
        : theme.colorCollapseHeaderTextDefault;

    // Arrow tint: upstream `header-iconDisabled` hardcodes the disabled text
    // token; the port routes it through the themed disabled color.
    final iconColor = enable
        ? theme.colorCollapseHeaderIconDefault
        : theme.colorCollapseHeaderTextDisabled;
    Widget arrow = SemiIconTheme(
      data: SemiIconThemeData(
        color: iconColor,
        customSize: theme.sizeCollapseIconDefault,
      ),
      child: ExcludeSemantics(
        child:
            (enable
                ? (active ? _scope.collapseIcon : _scope.expandIcon)
                : _scope.expandIcon) ??
            SemiIcon(
              active && enable ? SemiIcons.chevronUp : SemiIcons.chevronDown,
              excludeFromSemantics: true,
            ),
      ),
    );
    if (!widget.disabled) {
      arrow = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _scope.onToggle(widget.itemKey),
        child: arrow,
      );
    }

    final iconPosLeft =
        _scope.expandIconPosition == SemiCollapseIconPosition.left;
    final showArrow = widget.showArrow;
    // Upstream `header-right` gives every span `padding-right` except the
    // last child: the gap sits between `extra` and the arrow, and only when
    // the arrow shares the trailing block.
    final extraEndPadding = showArrow && !iconPosLeft
        ? theme.spacingCollapseRightPaddingRight
        : 0.0;

    final title = widget.header is String
        ? SemiText(
            widget.header! as String,
            weight: theme.fontCollapseHeaderFontWeight,
            style: TextStyle(fontSize: fontSize, color: headerColor),
          )
        : widget.header == null
        ? const SizedBox.shrink()
        : widget.header! as Widget;

    final trailingChildren = <Widget>[
      if (widget.extra != null)
        Padding(
          padding: EdgeInsetsDirectional.only(end: extraEndPadding),
          child: widget.extra!,
        ),
      if (showArrow && !iconPosLeft) arrow,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedWidth;
        final row = Row(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconPosLeft && showArrow)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: theme.spacingCollapseHeaderIconLeftMarginRight,
                ),
                child: arrow,
              ),
            if (bounded) Expanded(child: title) else title,
            if (trailingChildren.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: trailingChildren,
              ),
          ],
        );

        final Color bg;
        if (widget.disabled) {
          bg = const Color(0x00000000);
        } else if (_pressed) {
          bg = theme.colorCollapseHeaderBgActive;
        } else if (_hovering) {
          bg = theme.colorCollapseHeaderBgHover;
        } else {
          bg = const Color(0x00000000);
        }

        Widget header = DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.radiusCollapseHeader),
          ),
          child: Padding(
            padding: EdgeInsets.all(theme.spacingCollapseHeaderPadding),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: headerColor),
              child: row,
            ),
          ),
        );
        header = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.disabled || !_scope.clickHeaderToExpand
              ? null
              : () => _scope.onToggle(widget.itemKey),
          child: header,
        );
        header = Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: widget.disabled
              ? null
              : (_) => setState(() => _pressed = true),
          onPointerUp: widget.disabled
              ? null
              : (_) => setState(() => _pressed = false),
          onPointerCancel: widget.disabled
              ? null
              : (_) => setState(() => _pressed = false),
          child: header,
        );
        header = Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKey,
          child: header,
        );
        header = Semantics(
          container: true,
          button: true,
          expanded: active,
          enabled: !widget.disabled,
          label: widget.header is String ? widget.header! as String : null,
          child: header,
        );
        header = MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.spacingCollapseHeaderMarginY,
              bottom: theme.spacingCollapseHeaderMarginY,
              start: theme.spacingCollapseHeaderMarginX,
              end: theme.spacingCollapseHeaderMarginX,
            ),
            child: header,
          ),
        );

        final buildContent =
            widget.child != null &&
            (active ||
                !_controller.isDismissed ||
                (_scope.keepDOM && (!_scope.lazyRender || _hasBeenActive)));
        Widget contentRegion = const SizedBox.shrink();
        if (buildContent) {
          final content = Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.spacingCollapseContentPaddingTop,
              end: theme.spacingCollapseContentPaddingRight,
              bottom: theme.spacingCollapseContentPaddingBottom,
              start: theme.spacingCollapseContentPaddingLeft,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: theme.colorCollapseContentTextDefault,
                fontSize: fontSize,
              ),
              child: widget.child!,
            ),
          );
          contentRegion = AnimatedBuilder(
            animation: _controller,
            child: content,
            builder: (context, child) {
              // Height follows content continuously: Align clips the bottom
              // of the natural-height child, so reCalcKey/text scaling/nested
              // size changes can never leave stale heights behind. The wrapper
              // shape is constant so the content subtree never re-mounts.
              return ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  heightFactor: theme.animationCurve.transform(
                    _controller.value,
                  ),
                  child: child,
                ),
              );
            },
          );
          contentRegion = ExcludeSemantics(
            excluding: !active,
            child: contentRegion,
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: theme.widthCollapseItemBorder,
                color: theme.colorCollapseItemBorderDefault,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: bounded
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [header, contentRegion],
          ),
        );
      },
    );
  }
}

/// Mirrors upstream `CollapseContext` (`packages/semi-ui/collapse/collapse-context.tsx`).
@immutable
class _CollapseScopeData {
  const _CollapseScopeData({
    required this.activeSet,
    required this.expandIcon,
    required this.collapseIcon,
    required this.clickHeaderToExpand,
    required this.keepDOM,
    required this.lazyRender,
    required this.motion,
    required this.expandIconPosition,
    required this.onToggle,
  });
  final Set<String> activeSet;
  final Widget? expandIcon;
  final Widget? collapseIcon;
  final bool clickHeaderToExpand;
  final bool keepDOM;
  final bool lazyRender;
  final bool motion;
  final SemiCollapseIconPosition expandIconPosition;
  final ValueChanged<String> onToggle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CollapseScopeData &&
          setEquals(activeSet, other.activeSet) &&
          expandIcon == other.expandIcon &&
          collapseIcon == other.collapseIcon &&
          clickHeaderToExpand == other.clickHeaderToExpand &&
          keepDOM == other.keepDOM &&
          lazyRender == other.lazyRender &&
          motion == other.motion &&
          expandIconPosition == other.expandIconPosition;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(activeSet),
    expandIcon,
    collapseIcon,
    clickHeaderToExpand,
    keepDOM,
    lazyRender,
    motion,
    expandIconPosition,
  );
}

class _CollapseScope extends InheritedWidget {
  const _CollapseScope({required this.data, required super.child});
  final _CollapseScopeData data;

  static _CollapseScopeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CollapseScope>()!.data;

  @override
  bool updateShouldNotify(_CollapseScope oldWidget) => data != oldWidget.data;
}

/// The 7 hardcoded Sass values kept out of the theme: the collapsible opacity
/// transition series, the header/content type-size mixin and the disabled
/// icon color. See docs/semi_collapse.md for the full mapping.
// ignore: unused_element
abstract final class _CollapseMetrics {
  /// `$transition_delay-collapsible-height: var(--semi-transition_delay-none)`
  /// in packages/semi-foundation/collapsible/animation.scss.
  /// Height transitions start immediately: the `none` delay token is 0.
  // ignore: unused_field
  static const Duration transitionDelayHeight = Duration.zero;

  /// `$transition_duration-collapsible-opacity: 250ms` in
  /// packages/semi-foundation/collapsible/animation.scss.
  /// Unused: upstream keeps Collapsible `fade` false for Collapse, so the
  /// wrapper opacity stays 1 and only height animates.
  // ignore: unused_field
  static const Duration transitionDurationOpacity = Duration(milliseconds: 250);

  /// `$transition_function-collapsible-opacity: var(--semi-transition_function-easeIn)`
  /// in packages/semi-foundation/collapsible/animation.scss.
  /// Unused: same `fade: false` reason as [transitionDurationOpacity].
  // ignore: unused_field
  static const Curve transitionFunctionOpacity = Curves.easeIn;

  /// `$transition_delay-collapsible-opacity: var(--semi-transition_delay-none)`
  /// in packages/semi-foundation/collapsible/animation.scss.
  /// Unused: same `fade: false` reason as [transitionDurationOpacity].
  // ignore: unused_field
  static const Duration transitionDelayOpacity = Duration.zero;

  /// `@include font-size-regular` in
  /// packages/semi-foundation/collapse/collapse.scss.
  /// Header type size is the live `typography.fontSizeRegular` token (14 by
  /// default); the mixin provenance is recorded here.
  // ignore: unused_field
  static const double headerBaseFontSize = 14;

  /// `@include font-size-regular` in
  /// packages/semi-foundation/collapse/collapse.scss.
  /// Content type size: same live token as [headerBaseFontSize].
  // ignore: unused_field
  static const double contentBaseFontSize = 14;

  /// `color: var(--semi-color-disabled-text)` in
  /// packages/semi-foundation/collapse/collapse.scss.
  /// Upstream hardcodes the disabled arrow color; the port reads
  /// `colorCollapseHeaderTextDisabled` from the theme instead (improvement).
  // ignore: unused_field
  static const String iconDisabledColor = 'var(--semi-color-disabled-text)';
}
