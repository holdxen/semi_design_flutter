import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_switch_theme.dart';
import '../theme/semi_switch_theme_data.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'semi_spin.dart';
import 'spin_svg.dart';

/// Switch sizing (upstream `small` / `default` / `large`).
enum SemiSwitchSize { small, normal, large }

/// A source-sized, non-Material switch (upstream Semi Switch).
///
/// `checked != null` makes the switch controlled (SemiRating.value convention):
/// the widget renders `checked` and only emits events. Releasing control
/// (checked back to null) retains the last controlled value; entering control
/// preserves local state. Uncontrolled, the internal state starts at
/// [defaultChecked] and lands every toggle.
///
/// ★ `defaultChecked || checked` truthy-init (index.tsx:79) is NOT ported —
/// controlled switches always render [checked] (差异清单).
class SemiSwitch extends StatefulWidget {
  const SemiSwitch({
    super.key,
    this.checked,
    this.defaultChecked = false,
    this.disabled = false,
    this.loading = false,
    this.size = SemiSwitchSize.normal,
    this.checkedText,
    this.uncheckedText,
    this.onChanged,
    this.onBlur,
    this.onMouseEnter,
    this.onMouseLeave,
    this.autofocus = false,
  });

  /// Current checked state; non-null makes the widget controlled.
  final bool? checked;

  /// Uncontrolled initial checked state.
  final bool defaultChecked;

  final bool disabled;
  final bool loading;
  final SemiSwitchSize size;

  /// Content shown only when checked (String or Widget); hidden at
  /// [SemiSwitchSize.small] (TSX gate).
  final Object? checkedText;

  /// Content shown only when unchecked (String or Widget); hidden at
  /// [SemiSwitchSize.small].
  final Object? uncheckedText;

  /// Reports every toggle — no diff gating (upstream `onChange` fires for
  /// every actual toggle, foundation.ts:30-38).
  final ValueChanged<bool>? onChanged;

  /// Fired after the focus ring is cleared (upstream order,
  /// index.tsx:126-129: `foundation.handleBlur()` then `props.onBlur`).
  final VoidCallback? onBlur;
  final VoidCallback? onMouseEnter;
  final VoidCallback? onMouseLeave;
  final bool autofocus;

  /// Key of the track box.
  static const Key trackKey = ValueKey('SemiSwitch.track');

  @override
  State<SemiSwitch> createState() => _SemiSwitchState();
}

class _SemiSwitchState extends State<SemiSwitch> {
  /// The internal checked state; controlled switches render `widget.checked`.
  late bool _state;

  bool _hovered = false;

  /// Pointer is pressed on the track (`:active`).
  bool _pressed = false;

  bool _focused = false;

  /// Mirrors the browser `:focus-visible` heuristic (the button
  /// `_keyboardUsed` gate): the outline only paints after keyboard input,
  /// never after mouse interaction.
  bool _keyboardUsed = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _state = widget.defaultChecked;
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void didUpdateWidget(SemiSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // SemiRating convention (semi_rating.dart:122-129, checkbox :145):
    // releasing control retains the last controlled value instead of
    // resetting.
    if (oldWidget.checked != null && widget.checked == null) {
      _state = oldWidget.checked!;
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent && !_keyboardUsed && mounted) {
      setState(() => _keyboardUsed = true);
    }
    return false;
  }

  bool get _checked => widget.checked ?? _state;

  /// `disabled` OR `loading` blocks everything (tap/Space do nothing,
  /// unfocusable).
  bool get _interactive => !widget.disabled && !widget.loading;

  void _toggle() {
    if (!_interactive) return;
    final next = !_checked;
    // Uncontrolled lands the state; controlled only notifies. No diff gating —
    // every actual toggle reports (foundation.ts:30-38 handleChange).
    if (widget.checked == null) {
      setState(() => _state = next);
    }
    widget.onChanged?.call(next);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_interactive) return;
    // A press focuses the switch (the browser focuses the native checkbox)
    // and clears the keyboard gate (rating/checkbox tap-down precedent) —
    // mouse-click focus draws no ring (`:focus-visible`).
    _focusNode.requestFocus();
    setState(() {
      _pressed = true;
      _keyboardUsed = false;
    });
  }

  void _handlePointerEnd() {
    if (!_pressed) return;
    setState(() => _pressed = false);
  }

  void _handleEnter(PointerEnterEvent event) {
    // Upstream `onMouseEnter` fires on the root div regardless of disabled.
    widget.onMouseEnter?.call();
    if (_hovered) return;
    setState(() => _hovered = true);
  }

  void _handleLeave(PointerExitEvent event) {
    widget.onMouseLeave?.call();
    if (!_hovered) return;
    setState(() => _hovered = false);
  }

  /// ★ Space toggles; Enter does NOT (native checkbox semantics).
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    _toggle();
    return KeyEventResult.handled;
  }

  void _handleFocusChange(bool focused) {
    if (focused) {
      setState(() => _focused = true);
      return;
    }
    // Upstream order (index.tsx:126-129): `foundation.handleBlur()` clears the
    // ring (`setFocusVisible(false)`) FIRST, then `props.onBlur` fires.
    setState(() => _focused = false);
    widget.onBlur?.call();
  }

  // -- build -----------------------------------------------------------------

  /// Checked text sits at the directional start side, unchecked text at the
  /// directional end side (switch.scss:142-158 — `right: 0` on the unchecked
  /// box; rtl.scss mirrors the sides). Strings render as styled [Text],
  /// Widgets inherit the style via [DefaultTextStyle] (the `_asWidget`
  /// precedent).
  Widget _textSlot(Object value, Color color, double fontSize) {
    final style = TextStyle(color: color, fontSize: fontSize);
    // switch.scss:148 `@include all-center` —
    // `display: flex; justify-content: center; align-items: center;`
    return Center(
      child: value is Widget
          ? DefaultTextStyle(style: style, child: value)
          : Text('$value', style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiSwitchTheme.resolve(context);
    final checked = _checked;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final g = _SwitchGeometry.of(t, widget.size);

    // Knob translate (★ checked-pressed shifts back by the expand width).
    final double knobTx;
    if (checked) {
      knobTx = _pressed ? g.pressedCheckedTx : g.checkedTx;
    } else {
      knobTx = g.uncheckedTx;
    }
    final knobWidth = _pressed ? g.pressedKnobW : g.knobW;

    final knob = AnimatedPositioned(
      duration: t.motionSwitchTransitionDuration,
      // switch.scss:117 `transition: transform ... ease-in-out, width ...
      // ease-in-out` — the knob easing is hardcoded upstream (the bg
      // transition tokenizes easeIn instead).
      curve: _SwitchMetrics.knobTransitionEasing,
      top: g.knobTop,
      left: rtl ? null : t.spacingSwitchKnobLeft + knobTx,
      right: rtl ? t.spacingSwitchKnobLeft + knobTx : null,
      width: knobWidth,
      height: g.knobW,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: checked
              ? t.colorSwitchKnobBgChecked
              : t.colorSwitchKnobBgDefault,
          borderRadius: BorderRadius.circular(g.knobRadius),
          border: widget.disabled && !checked
              ? Border.all(
                  // `&-disabled .-knob` — `border:
                  // $width-switch_knob_disabled-border
                  // $color-switch_knob-border-default solid` (checked+disabled
                  // resets it to `none`).
                  width: t.widthSwitchKnobDisabledBorder,
                  color: t.colorSwitchKnobBorderDefault,
                )
              : null,
          boxShadow: widget.disabled
              ? _SwitchMetrics.shadowZero
              : _SwitchMetrics.shadowKnob,
        ),
      ),
    );

    // The loading slot renders the spin in the knob's place (index.tsx:153-157)
    // at the `width-switch_spin-*` visual size, translating with the
    // `spin_*-translateX` fields.
    final spinSize = g.spinSize;
    final spinTx = checked ? g.spinCheckedTx : g.spinUncheckedTx;
    final spin = Positioned(
      // `&-loading` — `display: inline-flex; align-items: center;`
      top: (g.trackH - spinSize) / 2,
      left: rtl ? null : spinTx,
      right: rtl ? spinTx : null,
      width: spinSize,
      height: spinSize,
      child: SemiSpin(
        // index.tsx:154 — `size={size === 'default' ? 'middle' : size}`.
        size: switch (widget.size) {
          SemiSwitchSize.small => SemiSpinSize.small,
          SemiSwitchSize.normal => SemiSpinSize.middle,
          SemiSwitchSize.large => SemiSpinSize.large,
        },
        // switch.scss:180-183 forces the svg to `width-switch_spin-*` with
        // `color-switch_loading_spin-default` coloring.
        indicator: SemiIcon.svg(
          semiSpinSvg,
          customSize: spinSize,
          color: t.colorSwitchLoadingSpinDefault,
          excludeFromSemantics: true,
        ),
      ),
    );

    // Text boxes: mutually exclusive (checked ↔ unchecked), never at `small`
    // (index.tsx:149-150).
    final showCheckedText =
        checked &&
        widget.checkedText != null &&
        widget.size != SemiSwitchSize.small;
    final showUncheckedText =
        !checked &&
        widget.uncheckedText != null &&
        widget.size != SemiSwitchSize.small;
    final textW = widget.size == SemiSwitchSize.large
        ? t.widthSwitchCheckedUncheckedText
        : _SwitchMetrics.textWidthDefault;
    // `&-checked-text, &-unchecked-text` — `font-size: $font-size-small` for
    // the default size (packages/semi-theme-default/scss/variables.scss:58
    // `$font-size-small: 12px` == theme.typography.fontSizeSmall); the large
    // size uses `$font-size-regular: 14px` (variables.scss:59 ==
    // theme.typography.fontSizeRegular).
    final textSize = widget.size == SemiSwitchSize.large
        ? global.typography.fontSizeRegular
        : global.typography.fontSizeSmall;

    // `&-disabled.-checked` — `background-color:
    // $color-switch_checked_disabled-bg-default` wins the cascade over the
    // loading track colors (switch.scss:232 after :186); then `&-loading`
    // (:163/:186) over `&-disabled` (:62).
    final trackBg = widget.disabled && checked
        ? t.colorSwitchCheckedDisabledBgDefault
        : widget.loading
        ? (checked
              ? t.colorSwitchSpinCheckedBgDefault
              : t.colorSwitchSpinUncheckedBgDefault)
        : widget.disabled
        ? t.colorSwitchDisabledBgDefault
        : checked
        ? (_hovered
              ? t.colorSwitchCheckedBgHover
              : t.colorSwitchCheckedBgDefault)
        : (_hovered
              ? t.colorSwitchDefaultBgHover
              : t.colorSwitchDefaultBgDefault);
    // `&:active` — `border: $border-thickness-control
    // $color-switch_default-bg-active solid` (the checked-pressed bg stays
    // `success`: the `&-active` field is effectively dead, 上游未消费).
    final borderColor = _pressed
        ? t.colorSwitchDefaultBgActive
        : widget.disabled
        ? (checked
              ? t.colorSwitchCheckedDisabledBorderDefault
              : t.colorSwitchDisabledBorderDefault)
        : t.colorSwitchDefaultBorderDefault;
    // ★ `:focus-visible` gate (rating semi_rating.dart:299 precedent):
    // `_focused && _keyboardUsed`.
    final showFocus = _focused && _keyboardUsed && _interactive;

    return Semantics(
      container: true,
      toggled: checked,
      // ★ enabled mirrors the upstream `aria-disabled={disabled}` quirk
      // (index.tsx:179) — `loading` is NOT reflected.
      enabled: !widget.disabled,
      child: MouseRegion(
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: _handleEnter,
        onExit: _handleLeave,
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: _interactive,
          onFocusChange: _handleFocusChange,
          onKeyEvent: _handleKey,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handlePointerDown,
            onPointerUp: (_) => _handlePointerEnd(),
            onPointerCancel: (_) => _handlePointerEnd(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: DecoratedBox(
                // The frame (border + focus ring) paints as a FOREGROUND
                // decoration: the border overlays the background edge without
                // insetting the positioned children — knob/spin/text offsets
                // anchor to the track's border box (the documented geometry:
                // knob x == the translate values).
                key: SemiSwitch.trackKey,
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(g.trackRadius),
                  // `border: $border-thickness-control
                  // $color-switch_default-border-default solid` — the 1px
                  // track border is transparent at rest.
                  border: Border.all(
                    width: _SwitchMetrics.borderThicknessControl,
                    color: borderColor,
                  ),
                  boxShadow: showFocus
                      ? [
                          // `&-focus` — `outline: $width-switch-outline solid
                          // $color-switch_primary-outline-focus` (spread ring,
                          // the slider `_SliderMetrics` outline precedent).
                          BoxShadow(
                            color: t.colorSwitchPrimaryOutlineFocus,
                            spreadRadius: t.widthSwitchOutline,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedContainer(
                  width: g.trackW,
                  height: g.trackH,
                  // `transition: background-color $transition_duration-switch-bg
                  // $transition_function-switch-bg $transition_delay_switch-bg`
                  // (switch.scss:17; the delay token is `Duration.zero` —
                  // AnimatedContainer carries no delay channel).
                  duration: t.transitionDurationSwitchBg,
                  curve: t.transitionFunctionSwitchBg,
                  decoration: BoxDecoration(
                    color: trackBg,
                    borderRadius: BorderRadius.circular(g.trackRadius),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.loading) spin else knob,
                      if (showCheckedText)
                        PositionedDirectional(
                          start: 0,
                          top: 0,
                          width: textW,
                          height: g.trackH,
                          child: _textSlot(
                            widget.checkedText!,
                            t.colorSwitchCheckedTextDefault,
                            textSize,
                          ),
                        ),
                      if (showUncheckedText)
                        PositionedDirectional(
                          end: 0,
                          top: 0,
                          width: textW,
                          height: g.trackH,
                          child: _textSlot(
                            widget.uncheckedText!,
                            t.colorSwitchUncheckedTextDefault,
                            textSize,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Per-size geometry derived from switch.scss (default / large / small blocks).
class _SwitchGeometry {
  const _SwitchGeometry({
    required this.trackW,
    required this.trackH,
    required this.trackRadius,
    required this.knobW,
    required this.knobTop,
    required this.knobRadius,
    required this.uncheckedTx,
    required this.checkedTx,
    required this.pressedKnobW,
    required this.pressedCheckedTx,
    required this.spinSize,
    required this.spinUncheckedTx,
    required this.spinCheckedTx,
  });

  factory _SwitchGeometry.of(
    SemiResolvedSwitchThemeData t,
    SemiSwitchSize size,
  ) {
    return switch (size) {
      // ★ `$width-switch_knob_large_small` is verbatim the SMALL knob width.
      SemiSwitchSize.small => _SwitchGeometry(
        trackW: t.widthSwitchSmall,
        trackH: t.heightSwitchSmall,
        trackRadius: t.radiusSwitchSmall,
        knobW: t.widthSwitchKnobLargeSmall,
        knobTop: t.spacingSwitchKnobSmallPadding,
        knobRadius: t.widthSwitchKnobLargeSmall * 0.5,
        uncheckedTx: t.spacingSwitchUncheckedSmallTranslateX,
        checkedTx: t.spacingSwitchCheckedSmallTranslateX,
        pressedKnobW: t.widthSwitchKnobSmallActive,
        pressedCheckedTx:
            t.spacingSwitchCheckedSmallTranslateX -
            t.spacingSwitchExpandSmallTranslateX,
        spinSize: t.widthSwitchSpinSmall,
        spinUncheckedTx: t.spacingSwitchSpinUncheckedSmallTranslateX,
        spinCheckedTx: t.spacingSwitchSpinCheckedSmallTranslateX,
      ),
      SemiSwitchSize.normal => _SwitchGeometry(
        trackW: t.widthSwitch,
        trackH: t.heightSwitch,
        trackRadius: t.radiusSwitch,
        knobW: t.widthSwitchKnobDefault,
        knobTop: t.spacingSwitchKnobPadding,
        knobRadius: t.widthSwitchKnobDefault * 0.5,
        uncheckedTx: t.spacingSwitchUncheckedTranslateX,
        checkedTx: t.spacingSwitchCheckedTranslateX,
        pressedKnobW: t.widthSwitchKnobActive,
        pressedCheckedTx:
            t.spacingSwitchCheckedTranslateX - t.widthSwitchKnobExpand,
        spinSize: t.widthSwitchSpinDefault,
        spinUncheckedTx: t.spacingSwitchSpinUncheckedTranslateX,
        spinCheckedTx: t.spacingSwitchSpinCheckedTranslateX,
      ),
      SemiSwitchSize.large => _SwitchGeometry(
        trackW: t.widthSwitchLarge,
        trackH: t.heightSwitchLarge,
        trackRadius: t.radiusSwitchLarge,
        knobW: t.widthSwitchKnobLarge,
        knobTop: t.spacingSwitchKnobLargePadding,
        knobRadius: t.widthSwitchKnobLarge * 0.5,
        uncheckedTx: t.spacingSwitchUncheckedLargeTranslateX,
        checkedTx: t.spacingSwitchCheckedLargeTranslateX,
        pressedKnobW: t.widthSwitchKnobLargeActive,
        pressedCheckedTx:
            t.spacingSwitchCheckedLargeTranslateX -
            t.spacingSwitchExpandLargeTranslateX,
        spinSize: t.widthSwitchSpinLarge,
        spinUncheckedTx: t.spacingSwitchSpinUncheckedLargeTranslateX,
        spinCheckedTx: t.spacingSwitchSpinCheckedLargeTranslateX,
      ),
    };
  }

  final double trackW, trackH, trackRadius;
  final double knobW, knobTop, knobRadius;
  final double uncheckedTx, checkedTx, pressedKnobW, pressedCheckedTx;
  final double spinSize, spinUncheckedTx, spinCheckedTx;
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_switch.py for the
/// 66 = 63 themed + 3 motion + 0 INTERNAL accounting; the hardcodes below are
/// the 另列 entries.
abstract final class _SwitchMetrics {
  /// mixin.scss:14 `@mixin shadow-knob` on `.semi-switch-knob`
  /// (switch.scss:109):
  /// `box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 0 1px rgba(0, 0, 0, 0.3);`
  static const List<BoxShadow> shadowKnob = [
    BoxShadow(color: Color(0x1a000000), offset: Offset(0, 4), blurRadius: 6),
    BoxShadow(color: Color(0x4d000000), blurRadius: 1),
  ];

  /// mixin.scss:8 `@mixin shadow-0` on the disabled knob (switch.scss:78/96):
  /// `box-shadow: none;`
  static const List<BoxShadow> shadowZero = <BoxShadow>[];

  /// switch.scss:147 `&-checked-text, &-unchecked-text` — `width: 20px`
  /// (the default-size text box; large uses the
  /// `width-switch_checked_unchecked_text` field).
  static const double textWidthDefault = 20;

  /// switch.scss:117 knob transition — `transition: transform 200ms
  /// ease-in-out, width 200ms ease-in-out` (the bg transition tokenizes
  /// easeIn instead).
  static const Curve knobTransitionEasing = Curves.easeInOut;

  /// packages/semi-theme-default/scss/variables.scss:8 —
  /// `$border-thickness-control: 1px` (track border width).
  static const double borderThicknessControl = 1;
}
