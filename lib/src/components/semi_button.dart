import 'dart:math' as math;

import 'package:flutter/rendering.dart' show OverflowBoxFit, RenderProxyBox;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_button_theme.dart';
import '../theme/semi_button_theme_data.dart';
import '../theme/semi_icon_theme.dart';
import '../tokens/token_types.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'typography/semi_text.dart';

/// Upstream `strings.btnTypes` (`packages/semi-foundation/button/constants.ts`).
enum SemiButtonType { primary, secondary, tertiary, warning, danger }

/// Upstream `strings.themes`, the Button `theme` prop.
enum SemiButtonVariant { solid, light, outline, borderless }

/// Upstream `strings.sizes`; `normal` is upstream `default`
/// (`$height-button_default`, 32px).
enum SemiButtonSize { small, normal, large }

/// Upstream `strings.iconPositions` (default `left`).
enum SemiButtonIconPosition { left, right }

/// Upstream `noHorizontalPadding` union
/// (`boolean | 'left' | 'right' | ['left', 'right']`); the port keeps the
/// physical side names as logical start/end edges (see docs/semi_button.md).
enum SemiButtonNoPadding { none, left, right, both }

/// The values [SemiButtonGroup] injects into its children (upstream
/// `cloneElement(item, { disabled, size, type, ...item.props, ...rest })`).
///
/// Null means "not explicitly set": children merge with
/// child props winning over `disabled`/`size`/`type`, while a non-null group
/// `variant`/`colorful` wins over the child (upstream `...rest` order).
class SemiButtonScope extends InheritedWidget {
  const SemiButtonScope({
    super.key,
    this.disabled,
    this.type,
    this.variant,
    this.size,
    this.colorful,
    required super.child,
  });

  final bool? disabled;
  final SemiButtonType? type;
  final SemiButtonVariant? variant;
  final SemiButtonSize? size;
  final bool? colorful;

  static SemiButtonScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SemiButtonScope>();

  @override
  bool updateShouldNotify(SemiButtonScope oldWidget) =>
      disabled != oldWidget.disabled ||
      type != oldWidget.type ||
      variant != oldWidget.variant ||
      size != oldWidget.size ||
      colorful != oldWidget.colorful;
}

/// A Semi Design button (upstream `Button`/`index.tsx` + `Button.tsx` +
/// `iconButton/index.tsx`, no Material widgets).
///
/// Port notes (see docs/semi_button.md for the full difference list):
/// * `htmlType` and `circle` are not ported (upstream `circle` has no scss
///   rule and is a no-op).
/// * Null props mean "not explicitly set" so [SemiButtonGroup] can reproduce
///   the upstream `cloneElement` merge order; the effective defaults are
///   `type: primary`, `variant: light`, `size: normal`, `disabled: false`,
///   `colorful: false`.
/// * `onPressed == null` is not pressable but keeps the enabled visuals
///   (upstream `onClick` defaults to `noop`).
class SemiButton extends StatefulWidget {
  const SemiButton(
    this.child, {
    super.key,
    this.type,
    this.variant,
    this.size,
    this.loading = false,
    this.disabled,
    this.block = false,
    this.icon,
    this.iconPosition = SemiButtonIconPosition.left,
    this.iconSize,
    this.noHorizontalPadding = SemiButtonNoPadding.none,
    this.colorful,
    this.onPressed,
    this.onHoverChange,
    this.autofocus = false,
    this.semanticsLabel,
  }) : assert(
         child == null || child is String || child is Widget,
         'child must be a String, a Widget or null',
       );

  /// Label content: [String] (rendered as [SemiText] with the button
  /// typography) or [Widget] placed as-is. Null renders an icon-only button
  /// (upstream `children == null || children === ''`).
  final Object? child;

  /// Button tier; null falls back to the group value, then `primary`.
  final SemiButtonType? type;

  /// Visual theme (upstream `theme`); null falls back to the group value,
  /// then `light`.
  final SemiButtonVariant? variant;

  /// Size tier; null falls back to the group value, then `normal`.
  final SemiButtonSize? size;

  /// Loading state: the spinner replaces the icon slot in place and pointer
  /// clicks are intercepted (upstream `pointer-events: none`). `disabled`
  /// wins over `loading` and there is no controlled-loading mode.
  final bool loading;

  /// Disabled state; null falls back to the group value, then `false`.
  final bool? disabled;

  /// Full-width button (upstream `width: 100%`).
  final bool block;

  /// Icon slot widget (upstream `icon`); laid out at 16px (or [iconSize])
  /// with an 8px gap to the label.
  final Widget? icon;

  /// Icon side (upstream `iconPosition`, default `left`).
  final SemiButtonIconPosition iconPosition;

  /// Icon slot size override (upstream `IconSize`; upstream accepts the prop
  /// but never applies it — the port resolves it into the icon theme).
  final SemiIconSize? iconSize;

  /// Zeroes the horizontal button padding on the given edges
  /// (upstream `noHorizontalPadding`).
  final SemiButtonNoPadding noHorizontalPadding;

  /// Colorful AI variant; only `primary`/`tertiary` react to it (other types
  /// ignore it, upstream keeps the plain look). Null falls back to the group
  /// value, then `false`.
  final bool? colorful;

  /// Activation callback (upstream `onClick`). Null keeps enabled visuals but
  /// is not pressable.
  final VoidCallback? onPressed;

  /// Mouse hover reports (upstream `onMouseEnter`/`onMouseLeave`).
  final ValueChanged<bool>? onHoverChange;

  /// Request focus on mount.
  final bool autofocus;

  /// Accessible label (upstream `aria-label`).
  final String? semanticsLabel;

  @override
  State<SemiButton> createState() => _SemiButtonState();
}

/// A group of buttons (upstream `ButtonGroup`/`buttonGroup.tsx`).
///
/// Merge order (upstream `cloneElement(item, { disabled, size, type,
/// ...item.props, ...rest })`): a child's explicit `disabled`/`type`/`size`
/// wins over the group, while an explicit group `variant`/`colorful` wins
/// over the child. Non-`outline` buttons get a 1px divider after each
/// adjacent pair and the first/last button keeps one rounded side.
class SemiButtonGroup extends StatelessWidget {
  const SemiButtonGroup({
    super.key,
    this.disabled,
    this.type,
    this.variant,
    this.size,
    this.colorful,
    required this.children,
    this.semanticsLabel,
  });

  /// Group-level defaults; see [SemiButtonScope] for the merge order.
  final bool? disabled;
  final SemiButtonType? type;
  final SemiButtonVariant? variant;
  final SemiButtonSize? size;
  final bool? colorful;

  /// Direct children; only [SemiButton] children get dividers and rounding.
  final List<Widget> children;

  /// Accessible label (upstream `aria-label`).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      items.add(
        _ButtonPosition(
          isFirst: i == 0,
          isLast: i == children.length - 1,
          child: child,
        ),
      );
      // Upstream getInnerWithLine: a divider follows every direct Button
      // except the last, and only when its merged theme is not `outline`.
      if (i < children.length - 1 && child is SemiButton) {
        final lineVariant = variant ?? child.variant ?? SemiButtonVariant.light;
        if (lineVariant != SemiButtonVariant.outline) {
          items.add(
            Builder(
              builder: (context) {
                final t = SemiButtonTheme.resolve(context);
                final lineType = type ?? child.type ?? SemiButtonType.primary;
                final lineDisabled = child.disabled ?? disabled ?? false;
                return SizedBox(
                  width: t.widthButtonGroupBorder,
                  height: t.heightButtonGroupLineDefault,
                  child: ColoredBox(
                    color: _groupLineColor(
                      t,
                      lineType,
                      lineVariant,
                      lineDisabled,
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    }
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: SemiButtonScope(
        disabled: disabled,
        type: type,
        variant: variant,
        size: size,
        colorful: colorful,
        child: Wrap(
          spacing: 0,
          runSpacing: 0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: items,
        ),
      ),
    );
  }
}

/// Per-child position flags the group injects (upstream
/// `> .#{$module}:first-child/:last-child` on the raw children, so a
/// non-button first child leaves the first button unrounded).
class _ButtonPosition extends InheritedWidget {
  const _ButtonPosition({
    required this.isFirst,
    required this.isLast,
    required super.child,
  });

  final bool isFirst, isLast;

  static _ButtonPosition? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ButtonPosition>();

  @override
  bool updateShouldNotify(_ButtonPosition oldWidget) =>
      isFirst != oldWidget.isFirst || isLast != oldWidget.isLast;
}

class _SemiButtonState extends State<SemiButton> {
  bool _hovering = false;
  bool _pressed = false;
  bool _focused = false;

  /// Mirrors the browser `:focus-visible` heuristic (the dropdown
  /// `_keyboardUsed` gate): the 2px outline only paints after keyboard input,
  /// never after mouse interaction. A global keyboard-modality tracker makes
  /// Tab-focus behave like upstream (the key event lands before focus moves).
  bool _keyboardUsed = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent && !_keyboardUsed && mounted) {
      setState(() => _keyboardUsed = true);
    }
    return false;
  }

  void _handleFocusChange() {
    if (mounted && _focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  void _setHover(bool value) {
    if (_hovering == value) return;
    setState(() => _hovering = value);
    widget.onHoverChange?.call(value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _activate() {
    widget.onPressed?.call();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      // Loading intercepts pointer input only (upstream `pointer-events:
      // none`); the native button still fires `onClick` from the keyboard.
      if (!(widget.disabled ?? false)) _activate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scope = SemiButtonScope.maybeOf(context);
    final position = _ButtonPosition.maybeOf(context);
    // Upstream cloneElement merge order (buttonGroup.tsx): child props win
    // over the group's disabled/size/type; the group's variant/colorful (the
    // `...rest` spread) wins over the child.
    final type = widget.type ?? scope?.type ?? SemiButtonType.primary;
    final variant = scope?.variant ?? widget.variant ?? SemiButtonVariant.light;
    final size = widget.size ?? scope?.size ?? SemiButtonSize.normal;
    final disabled = widget.disabled ?? scope?.disabled ?? false;
    final colorful = scope?.colorful ?? widget.colorful ?? false;
    final inGroup = scope != null;

    final t = SemiButtonTheme.resolve(context);
    final state = disabled
        ? _ButtonState.disabled
        : _pressed
        ? _ButtonState.active
        : _hovering
        ? _ButtonState.hover
        : _ButtonState.def;
    final visual = _resolveVisual(t, type, variant, state, colorful);
    final iconOnly =
        widget.child == null ||
        (widget.child is String && (widget.child! as String).isEmpty);

    // Upstream iconButton.scss: loading renders the spinner in the icon slot
    // (`loading && !disabled` routes through IconButton in index.tsx).
    final showSpinner = widget.loading && !disabled;
    // Upstream iconButton/index.tsx (as written): IconAILoading for
    // `colorful && theme != solid`, and for every solid tertiary button.
    final useAiSpinner =
        showSpinner &&
        ((colorful && variant != SemiButtonVariant.solid) ||
            (variant == SemiButtonVariant.solid &&
                type == SemiButtonType.tertiary));

    Widget? iconSlot;
    if (showSpinner) {
      iconSlot = _ButtonSpinner(
        duration: useAiSpinner
            ? t.animationDurationButtonIconCustomIconLoading
            : t.animationDurationButtonIconLoading,
        child: SemiIcon(
          useAiSpinner ? SemiIcons.aiLoading : SemiIcons.spin,
          customSize: _ButtonMetrics.spinnerBoxSize,
          color: visual.color,
          excludeFromSemantics: true,
        ),
      );
    } else if (widget.icon != null) {
      iconSlot = SemiIconTheme(
        data: SemiIconThemeData(color: visual.color, size: widget.iconSize),
        child: widget.icon!,
      );
    }

    Widget? textSlot;
    if (widget.child != null && !iconOnly) {
      final fontSize = switch (size) {
        SemiButtonSize.small => t.fontButtonSmallFontSize,
        SemiButtonSize.normal => t.fontButtonFontSize,
        SemiButtonSize.large => t.fontButtonLargeFontSize,
      };
      final lineHeight = switch (size) {
        SemiButtonSize.small => t.fontButtonSmallLineHeight,
        SemiButtonSize.normal => t.fontButtonLineHeight,
        SemiButtonSize.large => t.fontButtonLargeLineHeight,
      };
      final fontWeight = switch (size) {
        SemiButtonSize.small => t.fontButtonSmallFontWeight,
        SemiButtonSize.normal => t.fontButtonFontWeight,
        SemiButtonSize.large => t.fontButtonLargeFontWeight,
      };
      final Widget text = widget.child is String
          ? SemiText(
              widget.child! as String,
              style: TextStyle(
                color: visual.color,
                fontSize: fontSize,
                height: lineHeight / fontSize,
                fontWeight: fontWeight,
              ),
            )
          : widget.child! as Widget;
      final gradient = visual.textGradient;
      textSlot = gradient == null
          ? text
          : ShaderMask(
              // Upstream `background-clip: text; color: transparent` on the
              // content span.
              blendMode: BlendMode.srcIn,
              shaderCallback: (r) => gradient.forSize(r.size).createShader(r),
              child: text,
            );
    }

    final gap = SizedBox(
      width: widget.iconPosition == SemiButtonIconPosition.left
          ? t.spacingButtonIconOnlyContentMarginLeft
          : t.spacingButtonIconOnlyContentMarginRight,
    );
    final List<Widget> rowChildren =
        widget.iconPosition == SemiButtonIconPosition.left
        ? [
            ?iconSlot,
            if (iconSlot != null && textSlot != null) gap,
            if (textSlot != null) Flexible(child: textSlot),
          ]
        : [
            if (textSlot != null) Flexible(child: textSlot),
            if (iconSlot != null && textSlot != null) gap,
            ?iconSlot,
          ];
    Widget content = OverflowBox(
      // CSS overflow is visible: scaled-up labels keep painting over the
      // fixed-height box instead of raising layout errors.
      fit: OverflowBoxFit.deferToChild,
      minHeight: 0,
      maxHeight: double.infinity,
      // A plain `alignment` makes a Container expand to the widest
      // constraints; centering is only wanted for pinned widths.
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowChildren,
      ),
    );

    final padX = switch (size) {
      SemiButtonSize.small => t.spacingButtonSmallPaddingLeft,
      SemiButtonSize.normal => t.spacingButtonDefaultPaddingLeft,
      SemiButtonSize.large => t.spacingButtonLargePaddingLeft,
    };
    final iconPadX = switch (size) {
      SemiButtonSize.small => t.spacingButtonIconOnlySmallPaddingLeft,
      SemiButtonSize.normal => t.spacingButtonIconOnlyDefaultPaddingLeft,
      SemiButtonSize.large => t.spacingButtonIconOnlyLargePaddingLeft,
    };
    // Upstream `padding-bottom: $spacing-button_default-paddingTop` (the
    // default size reads the top token; small/large use their own).
    final padTop = switch (size) {
      SemiButtonSize.small => t.spacingButtonSmallPaddingTop,
      SemiButtonSize.normal => t.spacingButtonDefaultPaddingTop,
      SemiButtonSize.large => t.spacingButtonLargePaddingTop,
    };
    final padBottom = switch (size) {
      SemiButtonSize.small => t.spacingButtonSmallPaddingBottom,
      SemiButtonSize.normal => t.spacingButtonDefaultPaddingTop,
      SemiButtonSize.large => t.spacingButtonLargePaddingBottom,
    };
    // Upstream iconButton.scss mirrors the quirk for the default icon-only
    // box (`padding-bottom: $spacing-button_iconOnly_default-paddingRight`).
    final iconPadTop = switch (size) {
      SemiButtonSize.small => t.spacingButtonIconOnlySmallPaddingTop,
      SemiButtonSize.normal => t.spacingButtonIconOnlyDefaultPaddingTop,
      SemiButtonSize.large => t.spacingButtonIconOnlyLargePaddingTop,
    };
    final iconPadBottom = switch (size) {
      SemiButtonSize.small => t.spacingButtonIconOnlySmallPaddingBottom,
      SemiButtonSize.normal => t.spacingButtonIconOnlyDefaultPaddingRight,
      SemiButtonSize.large => t.spacingButtonIconOnlyLargePaddingBottom,
    };

    final noPad = widget.noHorizontalPadding;
    double edge(SemiButtonNoPadding side) =>
        noPad == side || noPad == SemiButtonNoPadding.both ? 0 : 1;
    final startFactor = edge(SemiButtonNoPadding.left);
    final endFactor = edge(SemiButtonNoPadding.right);

    // In a group the button box keeps zero horizontal padding and the
    // content span carries the horizontal padding (button.scss `&-group`).
    final EdgeInsetsGeometry padding = inGroup
        ? EdgeInsetsDirectional.only(
            top: iconOnly ? iconPadTop : padTop,
            bottom: iconOnly ? iconPadBottom : padBottom,
          )
        : EdgeInsetsDirectional.only(
            top: iconOnly ? iconPadTop : padTop,
            bottom: iconOnly ? iconPadBottom : padBottom,
            start: (iconOnly ? iconPadX : padX) * startFactor,
            end: (iconOnly ? iconPadX : padX) * endFactor,
          );
    if (inGroup) {
      // The group zeroes the button box padding and moves the horizontal
      // padding onto the content span; `noHorizontalPadding` only ever
      // touched the button box, so it has no effect here (upstream inline
      // style on the already-0 button padding).
      content = Padding(
        padding: EdgeInsetsDirectional.only(
          start: iconOnly ? iconPadX : padX,
          end: iconOnly ? iconPadX : padX,
        ),
        child: content,
      );
    }

    final BorderRadiusGeometry radius;
    if (inGroup) {
      final first = position?.isFirst ?? false;
      final last = position?.isLast ?? false;
      final r = Radius.circular(t.radiusButtonGroup);
      radius = first && last
          ? BorderRadius.all(r)
          : first
          ? BorderRadiusDirectional.only(topStart: r, bottomStart: r)
          : last
          ? BorderRadiusDirectional.only(topEnd: r, bottomEnd: r)
          : BorderRadius.zero;
    } else {
      radius = BorderRadiusDirectional.circular(t.radiusButton);
    }

    // Upstream `&-outline:not(:last-child)` inside a group: the right border
    // turns transparent and the margin pulls the next button 1px over it.
    // The upstream rtl.scss never mirrors those two physical declarations.
    final outlineOverlap =
        inGroup &&
        variant == SemiButtonVariant.outline &&
        !(position?.isLast ?? true);
    // Upstream pairs the overlap with `border-right-color: transparent`; the
    // overlapped seam is covered by the next sibling's border (z-order), and a
    // non-uniform Border cannot carry a borderRadius (BoxDecoration assert),
    // so the border stays uniform.
    final border = Border.all(
      color: visual.borderColor,
      width: visual.borderWidth,
    );

    final transform = _transformFor(t, type, variant);
    final (duration, curve) = _transitionFor(t, type, variant);

    Widget box = AnimatedContainer(
      duration: duration,
      curve: curve,
      // Upstream `transform: scale($transform_scale-button_*)` (identity in
      // the default theme). The transition delay trio has no
      // AnimatedContainer counterpart and stays documentation.
      transform: Matrix4.diagonal3Values(transform.scaleX, transform.scaleY, 1),
      transformAlignment: Alignment.center,
      width: widget.block
          ? double.infinity
          : iconOnly
          ? switch (size) {
              SemiButtonSize.small => t.widthButtonIconOnlySmall,
              SemiButtonSize.normal => t.widthButtonIconOnlyDefault,
              SemiButtonSize.large => t.widthButtonIconOnlyLarge,
            }
          : null,
      height: iconOnly
          ? switch (size) {
              SemiButtonSize.small => t.heightButtonIconOnlySmall,
              SemiButtonSize.normal => t.heightButtonIconOnlyDefault,
              SemiButtonSize.large => t.heightButtonIconOnlyLarge,
            }
          : switch (size) {
              SemiButtonSize.small => t.heightButtonSmall,
              SemiButtonSize.normal => t.heightButtonDefault,
              SemiButtonSize.large => t.heightButtonLarge,
            },
      padding: padding,
      // A plain `alignment` makes a Container expand to the widest
      // constraints; centering is only wanted for pinned widths.
      alignment: widget.block || iconOnly ? Alignment.center : null,
      decoration: BoxDecoration(
        // The gradient paints through the size-aware adapter; color covers
        // every plain state.
        color: visual.backgroundGradient == null ? visual.background : null,
        gradient: visual.backgroundGradient == null
            ? null
            : _SemiGradientBox(visual.backgroundGradient!),
        border: border,
        borderRadius: radius,
        boxShadow: _focused && _keyboardUsed && !disabled
            ? [
                // The upstream `outline` is painted outside the border box
                // without layout impact; a zero-blur spread shadow reproduces
                // that ring.
                BoxShadow(
                  color: _focusColor(t, type, variant),
                  spreadRadius: t.widthButtonOutline,
                ),
              ]
            : null,
      ),
      child: content,
    );

    box = MouseRegion(
      cursor: disabled || widget.loading
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: box,
    );
    box = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: disabled
          ? null
          : (_) => setState(() {
              _pressed = true;
              _keyboardUsed = false;
            }),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: box,
    );
    final pointerEnabled =
        !disabled && !widget.loading && widget.onPressed != null;
    box = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: pointerEnabled ? _activate : null,
      child: box,
    );
    box = Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: !disabled,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: _handleKey,
      child: box,
    );
    final result = Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticsLabel,
      // Upstream `aria-disabled: disabled` — loading keeps the button enabled.
      onTap: !disabled && widget.onPressed != null ? _activate : null,
      child: box,
    );
    if (!outlineOverlap) return result;
    return _NegativeEndMargin(
      extent: t.widthButtonOutlineBorder,
      child: result,
    );
  }
}

/// The four upstream pseudo-class slots of the state color lookup.
enum _ButtonState { def, hover, active, disabled }

@immutable
class _ButtonVisual {
  const _ButtonVisual({
    required this.background,
    this.backgroundGradient,
    required this.borderColor,
    required this.borderWidth,
    required this.color,
    this.textGradient,
  });

  final Color? background;
  final SemiGradient? backgroundGradient;
  final Color borderColor;
  final double borderWidth;

  /// The CSS `color` of the button (text fill and icon currentColor).
  final Color color;

  /// Upstream colorful text fill (`background-clip: text`).
  final SemiGradient? textGradient;
}

/// Per-type field lookups of variables.scss, kept in one record so the state
/// resolver stays a per-(type, variant, state) field query.
({
  Color bgDef,
  Color bgHover,
  Color bgActive,
  Color borderDef,
  Color borderHover,
  Color borderActive,
  Color textDef,
  Color textHover,
  Color textActive,
  Color borderlessText,
  Color outlineBorder,
})
_typeFields(SemiResolvedButtonThemeData t, SemiButtonType type) {
  return switch (type) {
    SemiButtonType.primary => (
      bgDef: t.colorButtonPrimaryBgDefault,
      bgHover: t.colorButtonPrimaryBgHover,
      bgActive: t.colorButtonPrimaryBgActive,
      borderDef: t.colorButtonPrimaryBorderDefault,
      borderHover: t.colorButtonPrimaryBorderHover,
      borderActive: t.colorButtonPrimaryBorderActive,
      textDef: t.colorButtonPrimaryTextDefault,
      textHover: t.colorButtonPrimaryTextHover,
      textActive: t.colorButtonPrimaryTextActive,
      borderlessText: t.colorButtonPrimaryBorderlessTextDefault,
      outlineBorder: t.colorButtonPrimaryOutlineBorderDefault,
    ),
    SemiButtonType.secondary => (
      bgDef: t.colorButtonSecondaryBgDefault,
      bgHover: t.colorButtonSecondaryBgHover,
      bgActive: t.colorButtonSecondaryBgActive,
      borderDef: t.colorButtonSecondaryBorderDefault,
      borderHover: t.colorButtonSecondaryBorderHover,
      borderActive: t.colorButtonSecondaryBorderActive,
      textDef: t.colorButtonSecondaryTextDefault,
      textHover: t.colorButtonSecondaryTextHover,
      textActive: t.colorButtonSecondaryTextActive,
      borderlessText: t.colorButtonSecondaryBorderlessTextDefault,
      outlineBorder: t.colorButtonSecondaryOutlineBorderDefault,
    ),
    SemiButtonType.tertiary => (
      bgDef: t.colorButtonTertiaryBgDefault,
      bgHover: t.colorButtonTertiaryBgHover,
      bgActive: t.colorButtonTertiaryBgActive,
      borderDef: t.colorButtonTertiaryBorderDefault,
      borderHover: t.colorButtonTertiaryBorderHover,
      borderActive: t.colorButtonTertiaryBorderActive,
      textDef: t.colorButtonTertiaryTextDefault,
      textHover: t.colorButtonTertiaryTextHover,
      textActive: t.colorButtonTertiaryTextActive,
      borderlessText: t.colorButtonTertiarySolidTextDefault,
      outlineBorder: t.colorButtonTertiaryOutlineBorderDefault,
    ),
    SemiButtonType.warning => (
      bgDef: t.colorButtonWarningBgDefault,
      bgHover: t.colorButtonWarningBgHover,
      bgActive: t.colorButtonWarningBgActive,
      borderDef: t.colorButtonWarningBorderDefault,
      borderHover: t.colorButtonWarningBorderHover,
      borderActive: t.colorButtonWarningBorderActive,
      textDef: t.colorButtonWarningTextDefault,
      textHover: t.colorButtonWarningTextHover,
      textActive: t.colorButtonWarningTextActive,
      borderlessText: t.colorButtonWarningBorderlessTextDefault,
      outlineBorder: t.colorButtonWarningOutlineBorderDefault,
    ),
    SemiButtonType.danger => (
      bgDef: t.colorButtonDangerBgDefault,
      bgHover: t.colorButtonDangerBgHover,
      bgActive: t.colorButtonDangerBgActive,
      borderDef: t.colorButtonDangerBorderDefault,
      borderHover: t.colorButtonDangerBorderHover,
      borderActive: t.colorButtonDangerBorderActive,
      textDef: t.colorButtonDangerTextDefault,
      textHover: t.colorButtonDangerTextHover,
      textActive: t.colorButtonDangerTextActive,
      borderlessText: t.colorButtonDangerBorderlessTextDefault,
      outlineBorder: t.colorButtonDangerOutlineBorderDefault,
    ),
  };
}

/// The per-type disabled background pair (solid / light).
({Color solid, Color light}) _typeDisabledBg(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
) {
  return switch (type) {
    SemiButtonType.primary => (
      solid: t.colorButtonDisabledPrimaryBgDefault,
      light: t.colorButtonDisabledLightPrimaryBgDefault,
    ),
    SemiButtonType.secondary => (
      solid: t.colorButtonDisabledSecondaryBgDefault,
      light: t.colorButtonDisabledLightSecondaryBgDefault,
    ),
    SemiButtonType.tertiary => (
      solid: t.colorButtonDisabledTertiaryBgDefault,
      light: t.colorButtonDisabledLightTertiaryBgDefault,
    ),
    SemiButtonType.warning => (
      solid: t.colorButtonDisabledWarningBgDefault,
      light: t.colorButtonDisabledLightWarningBgDefault,
    ),
    SemiButtonType.danger => (
      solid: t.colorButtonDisabledDangerBgDefault,
      light: t.colorButtonDisabledLightDangerBgDefault,
    ),
  };
}

/// State color resolver: a per-(type, variant, state) query over the
/// variables.scss fields, mirroring the button.scss cascade (see
/// docs/semi_button.md for the derivation table and the unused-field quirks).
_ButtonVisual _resolveVisual(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
  _ButtonState state,
  bool colorful,
) {
  final fields = _typeFields(t, type);
  if (state == _ButtonState.disabled) {
    final backgrounds = _typeDisabledBg(t, type);
    final Color background = switch (variant) {
      SemiButtonVariant.solid => backgrounds.solid,
      SemiButtonVariant.light => backgrounds.light,
      SemiButtonVariant.outline ||
      SemiButtonVariant.borderless => const Color(0x00000000),
    };
    final Color color = switch (variant) {
      SemiButtonVariant.solid => t.colorButtonDisabledSolidTextDefault,
      SemiButtonVariant.light ||
      SemiButtonVariant.borderless => t.colorButtonDisabledTextDefault,
      SemiButtonVariant.outline => t.colorButtonDisabledOutlineTextDefault,
    };
    final (Color borderColor, double borderWidth) = switch (variant) {
      SemiButtonVariant.solid => (fields.borderDef, t.widthButtonBorder),
      SemiButtonVariant.light => (
        t.colorButtonLightBorderDefault,
        t.widthButtonLightBorder,
      ),
      SemiButtonVariant.borderless => (
        t.colorButtonBorderlessBorderDefault,
        t.widthButtonBorderlessBorder,
      ),
      SemiButtonVariant.outline => (
        t.colorButtonDisabledOutlineBorderDefault,
        t.widthButtonOutlineBorder,
      ),
    };
    return _ButtonVisual(
      background: background,
      borderColor: borderColor,
      borderWidth: borderWidth,
      color: color,
    );
  }
  final hover = state == _ButtonState.hover;
  final active = state == _ButtonState.active;

  Color? background;
  SemiGradient? backgroundGradient;
  switch (variant) {
    case SemiButtonVariant.solid:
      if (colorful && type == SemiButtonType.primary) {
        backgroundGradient = active
            ? t.colorButtonPrimarySolidColorfulBgActive
            : hover
            ? t.colorButtonPrimarySolidColorfulBgHover
            : t.colorButtonPrimarySolidColorfulBgDefault;
      } else if (colorful && type == SemiButtonType.tertiary) {
        backgroundGradient = active
            ? t.colorButtonTertiarySolidColorfulBgActive
            : hover
            ? t.colorButtonTertiarySolidColorfulBgHover
            : t.colorButtonTertiarySolidColorfulBgDefault;
      } else {
        background = active
            ? fields.bgActive
            : hover
            ? fields.bgHover
            : fields.bgDef;
      }
    case SemiButtonVariant.light:
      background = active
          ? t.colorButtonLightBgActive
          : hover
          ? t.colorButtonLightBgHover
          : t.colorButtonLightBgDefault;
    case SemiButtonVariant.borderless:
      background = active
          ? t.colorButtonBorderlessBgActive
          : hover
          ? t.colorButtonBorderlessBgHover
          : const Color(0x00000000);
    case SemiButtonVariant.outline:
      background = active
          ? t.colorButtonOutlineBgActive
          : hover
          ? t.colorButtonOutlineBgHover
          : const Color(0x00000000);
  }

  final (Color borderColor, double borderWidth) = switch (variant) {
    SemiButtonVariant.solid => (
      active
          ? fields.borderActive
          : hover
          ? fields.borderHover
          : fields.borderDef,
      t.widthButtonBorder,
    ),
    SemiButtonVariant.light => (
      active
          ? t.colorButtonLightBorderActive
          : hover
          ? t.colorButtonLightBorderHover
          : t.colorButtonLightBorderDefault,
      t.widthButtonLightBorder,
    ),
    SemiButtonVariant.borderless => (
      active
          ? t.colorButtonBorderlessBorderActive
          : hover
          ? t.colorButtonBorderlessBorderHover
          : t.colorButtonBorderlessBorderDefault,
      t.widthButtonBorderlessBorder,
    ),
    SemiButtonVariant.outline => (
      colorful && type == SemiButtonType.primary
          ? t.colorButtonPrimaryLightOutlineBorder
          : fields.outlineBorder,
      t.widthButtonOutlineBorder,
    ),
  };

  Color color;
  SemiGradient? textGradient;
  switch (variant) {
    case SemiButtonVariant.solid:
      color = active
          ? fields.textActive
          : hover
          ? fields.textHover
          : fields.textDef;
      if (colorful && type == SemiButtonType.tertiary) {
        textGradient = t.colorButtonTertiarySolidColorfulTextDefault;
      }
    case SemiButtonVariant.light || SemiButtonVariant.borderless:
      if (colorful && type == SemiButtonType.primary) {
        textGradient = variant == SemiButtonVariant.light
            ? t.colorButtonPrimaryLightColorfulTextDefault
            : t.colorButtonPrimaryLightBorderlessTextDefault;
        color = t.colorButtonPrimaryBorderlessTextDefault;
      } else if (type == SemiButtonType.tertiary) {
        color = t.colorButtonTertiarySolidTextDefault;
      } else {
        color = fields.borderlessText;
      }
    case SemiButtonVariant.outline:
      if (colorful && type == SemiButtonType.primary) {
        color = t.colorButtonPrimaryLightOutlineTextDefault;
      } else if (type == SemiButtonType.tertiary) {
        color = t.colorButtonTertiarySolidTextDefault;
      } else {
        color = fields.borderlessText;
      }
  }
  return _ButtonVisual(
    background: background,
    backgroundGradient: backgroundGradient,
    borderColor: borderColor,
    borderWidth: borderWidth,
    color: color,
    textGradient: textGradient,
  );
}

/// Upstream focus ring colors: the base rule keeps
/// `$color-button_primary_outline-focus` for every type, and only danger and
/// warning override it outside `light`/`borderless` (upstream quirk kept).
Color _focusColor(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  if (variant == SemiButtonVariant.solid ||
      variant == SemiButtonVariant.outline) {
    if (type == SemiButtonType.danger) return t.colorButtonDangerOutlineFocus;
    if (type == SemiButtonType.warning) return t.colorButtonWarningOutlineFocus;
  }
  return t.colorButtonPrimaryOutlineFocus;
}

/// The background transition trio per cascade slot (type rule for
/// solid/outline, own rule for light/borderless). The delay member has no
/// AnimatedContainer counterpart and stays documentation.
(Duration, Curve) _transitionFor(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  switch (variant) {
    case SemiButtonVariant.light:
      return (
        t.transitionDurationButtonLightBg,
        t.transitionFunctionButtonLightBg,
      );
    case SemiButtonVariant.borderless:
      return (
        t.transitionDurationButtonBorderlessBg,
        t.transitionFunctionButtonBorderlessBg,
      );
    case SemiButtonVariant.solid || SemiButtonVariant.outline:
      switch (type) {
        case SemiButtonType.primary:
          return (
            t.transitionDurationButtonPrimaryBg,
            t.transitionFunctionButtonPrimaryBg,
          );
        case SemiButtonType.secondary:
          return (
            t.transitionDurationButtonSecondaryBg,
            t.transitionFunctionButtonSecondaryBg,
          );
        case SemiButtonType.tertiary:
          return (
            t.transitionDurationButtonTertiaryBg,
            t.transitionFunctionButtonTertiaryBg,
          );
        case SemiButtonType.warning:
          return (
            t.transitionDurationButtonWarningBg,
            t.transitionFunctionButtonWarningBg,
          );
        case SemiButtonType.danger:
          return (
            t.transitionDurationButtonDangerBg,
            t.transitionFunctionButtonDangerBg,
          );
      }
  }
}

/// Upstream `transform: scale($transform_scale-button_*)` slot selection.
SemiTransform _transformFor(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  switch (variant) {
    case SemiButtonVariant.light:
      return t.transformScaleButtonLight;
    case SemiButtonVariant.borderless:
      return t.transformScaleButtonBorderless;
    case SemiButtonVariant.solid || SemiButtonVariant.outline:
      switch (type) {
        case SemiButtonType.primary:
          return t.transformScaleButtonPrimary;
        case SemiButtonType.secondary:
          return t.transformScaleButtonSecondary;
        case SemiButtonType.tertiary:
          return t.transformScaleButtonTertiary;
        case SemiButtonType.warning:
          return t.transformScaleButtonWarning;
        case SemiButtonType.danger:
          return t.transformScaleButtonDanger;
      }
  }
}

/// Upstream `.#{$module}-group-line-{theme,type,-disabled}` cascade: the
/// borderless class wins, then the light class, then disabled over the type
/// background (button.scss file order).
Color _groupLineColor(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
  bool disabled,
) {
  if (variant == SemiButtonVariant.borderless) return const Color(0x00000000);
  if (variant == SemiButtonVariant.light) return t.colorButtonLightBgDefault;
  return disabled ? t.colorButtonDisabledBgDefault : _typeFields(t, type).bgDef;
}

/// Upstream `margin-right: -1 * $width-button_outline-border` on outline
/// buttons inside a group. The framework forbids negative margins, so the
/// box reports a width reduced by [extent] while the child keeps painting at
/// its full width and the next sibling pulls over the shared seam.
class _NegativeEndMargin extends SingleChildRenderObjectWidget {
  const _NegativeEndMargin({required this.extent, required super.child});

  final double extent;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _NegativeEndMarginBox(extent);

  @override
  void updateRenderObject(
    BuildContext context,
    _NegativeEndMarginBox renderObject,
  ) {
    renderObject.extent = extent;
  }
}

class _NegativeEndMarginBox extends RenderProxyBox {
  _NegativeEndMarginBox(this.extent);

  double extent;

  @override
  void performLayout() {
    super.performLayout();
    size = constraints.constrain(
      Size(math.max(0, size.width - extent), size.height),
    );
  }
}

/// Wraps a token [SemiGradient] for [BoxDecoration]; the shader is built from
/// the painted rect so the CSS gradient angle maps like `forSize`.
class _SemiGradientBox extends Gradient {
  _SemiGradientBox(this.gradient)
    : super(colors: gradient.colors, stops: gradient.stops);
  final SemiGradient gradient;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) =>
      gradient.forSize(rect.size).createShader(rect);

  @override
  Gradient scale(double factor) => _SemiGradientBox(
    SemiGradient(gradient.degrees, [
      for (final color in gradient.colors)
        color.withValues(alpha: math.max(0, math.min(1, color.a * factor))),
    ], gradient.stops),
  );

  @override
  Gradient withOpacity(double opacity) => scale(opacity);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SemiGradientBox && gradient == other.gradient;

  @override
  int get hashCode => gradient.hashCode;

  @override
  String toString() => 'SemiGradientBox($gradient)';
}

/// The loading spinner (upstream `SpinIcon`/`IconAILoading` inside the
/// `@keyframes rotate` container of iconButton.scss).
class _ButtonSpinner extends StatefulWidget {
  const _ButtonSpinner({required this.duration, required this.child});

  final Duration duration;
  final Widget child;

  @override
  State<_ButtonSpinner> createState() => _ButtonSpinnerState();
}

class _ButtonSpinnerState extends State<_ButtonSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_ButtonSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _spin.duration = widget.duration;
    }
    _sync();
  }

  void _sync() {
    final animate =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && !_spin.isAnimating) _spin.repeat();
    if (!animate) {
      _spin.stop();
      _spin.value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _spin,
    child: widget.child,
    builder: (context, child) =>
        Transform.rotate(angle: _spin.value * 2 * math.pi, child: child),
  );
}

/// The hardcoded Sass values kept out of the theme (plus the two shared
/// literals the state resolver documents). See docs/semi_button.md for the
/// full mapping.
// ignore: unused_element
abstract final class _ButtonMetrics {
  /// `width: 16px; height: 16px` in
  /// packages/semi-foundation/button/iconButton.scss (`.#{$module}-loading
  /// .#{$module}-content > svg`): the loading spinner box.
  static const double spinnerBoxSize = 16;

  /// `@include shadow-0` in packages/semi-foundation/button/button.scss
  /// (`.#{$module}`); the mixin in packages/semi-theme-default/scss/mixin.scss
  /// is `box-shadow: none`, so the button paints no shadow.
  // ignore: unused_field
  static const String shadow0Mixin = '@include shadow-0';

  /// The `box-shadow: none` body of the `shadow-0` mixin definition.
  // ignore: unused_field
  static const String shadow0 = 'box-shadow: none';

  /// `rgba(var(--semi-white), 1)` — the shared solid-button text fill of
  /// variables.scss (5× `text-default`/`text-hover`/`text-active`); the theme
  /// fields resolve it through `theme.palette.white.toColor()` and the
  /// literal is recorded here (palette `--semi-white: 255,255,255`).
  // ignore: unused_field
  static const Color whiteTextFill = Color(0xFFFFFFFF);

  /// `outline: $width-button-outline solid ...` in button.scss
  /// (`:focus-visible`): the 2px focus outline. The port paints it as a
  /// zero-blur spread shadow sized by the themed `widthButtonOutline` (2).
  // ignore: unused_field
  static const String focusOutline = r'outline: $width-button-outline solid';

  /// `background-clip: text` on the colorful content span (button.scss);
  /// rendered as a [ShaderMask] around the label.
  // ignore: unused_field
  static const String contentClipText = 'background-clip: text';

  /// `color: transparent` paired with `background-clip: text` on the
  /// colorful content span.
  // ignore: unused_field
  static const String contentTransparentText = 'color: transparent';

  /// `pointer-events: none` in iconButton.scss (`&-loading`): pointer clicks
  /// are intercepted while loading.
  // ignore: unused_field
  static const String loadingPointerEvents = 'pointer-events: none';

  /// `cursor: not-allowed` in button.scss (`&-disabled`) and iconButton.scss
  /// (`&-loading`), mapped to [SystemMouseCursors.forbidden].
  // ignore: unused_field
  static const String loadingCursor = 'cursor: not-allowed';

  /// `cursor: pointer` on the base rule (enabled buttons).
  // ignore: unused_field
  static const String baseCursor = 'cursor: pointer';

  /// `width: 100%` in button.scss (`&-block`).
  // ignore: unused_field
  static const String blockWidth = 'width: 100%';

  /// `margin-right: -1 * $width-button_outline-border` in button.scss
  /// (`&-group > .#{$module}-outline:not(:last-child)`); the port reads the
  /// themed `widthButtonOutlineBorder` (1px overlap).
  // ignore: unused_field
  static const String groupOutlineOverlapMargin =
      r'margin-right: -1 * $width-button_outline-border';

  /// `border-right-color: transparent` of the same outline-overlap rule.
  // ignore: unused_field
  static const String groupOutlineOverlapBorder =
      'border-right-color: transparent';

  /// `padding-bottom: $spacing-button_default-paddingTop` in button.scss
  /// (the default size reads the top token; small/large read their own
  /// `-paddingBottom`). The default icon-only box mirrors the quirk with
  /// `padding-bottom: $spacing-button_iconOnly_default-paddingRight`.
  // ignore: unused_field
  static const String bottomPaddingQuirk =
      r'padding-bottom: $spacing-button_default-paddingTop';

  /// `font-family: inherit` on the base rule.
  // ignore: unused_field
  static const String fontFamilyInherit = 'font-family: inherit';

  /// `white-space: nowrap` on the base rule.
  // ignore: unused_field
  static const String whiteSpaceNowrap = 'white-space: nowrap';

  /// `user-select: none` on the base rule.
  // ignore: unused_field
  static const String userSelectNone = 'user-select: none';

  /// `vertical-align: middle` on the base rule.
  // ignore: unused_field
  static const String verticalAlignMiddle = 'vertical-align: middle';

  /// `rotate(360deg)` of the `@keyframes #{$prefix}-animation-rotate` used
  /// by the loading spinner (iconButton.scss).
  // ignore: unused_field
  static const String rotateKeyframes = 'rotate(360deg)';

  /// `display: inline-flex` on the base rule (and `&-with-icon`).
  // ignore: unused_field
  static const String inlineFlexCenter = 'display: inline-flex';

  /// `animation-fill-mode: forwards` of the loading spinner animation
  /// (iconButton.scss).
  // ignore: unused_field
  static const String loadingAnimationFillMode =
      'animation-fill-mode: forwards';
}
