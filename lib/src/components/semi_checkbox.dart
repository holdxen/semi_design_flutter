import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_checkbox_theme.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';

/// Checkbox presentation: plain, card framed, or card with the check box
/// hidden (upstream `default` / `card` / `pureCard`).
enum SemiCheckboxType { normal, card, pureCard }

/// Group layout axis. Vertical stacks with a row gap, horizontal wraps.
enum SemiCheckboxDirection { vertical, horizontal }

/// A synchronous, cancelable check-state change request. Late prevention or
/// stopping has no effect: the event is sealed once the dispatch completes.
class SemiCheckboxChangeEvent {
  SemiCheckboxChangeEvent(this.checked);

  /// The proposed new checked value (already flipped).
  final bool checked;

  bool _prevented = false, _stopped = false, _active = true;

  bool get defaultPrevented => _prevented;

  /// Rejects the checked-state application of an uncontrolled widget (the
  /// standalone toggle or the group value mutation). Controlled widgets only
  /// emit events and are unaffected, mirroring SemiTagCloseEvent.
  void preventDefault() {
    if (_active) _prevented = true;
  }

  /// Cancels the notification of the enclosing SemiCheckboxGroup (its value
  /// mutation and its onChanged).
  void stopPropagation() {
    if (_active) _stopped = true;
  }
}

/// One options-mode entry of [SemiCheckboxGroup].
class SemiCheckboxOption {
  const SemiCheckboxOption({
    this.label,
    this.value,
    this.extra,
    this.disabled = false,
  });

  /// String or Widget.
  final Object? label;
  final Object? value;

  /// String or Widget.
  final Object? extra;
  final bool disabled;
}

/// A source-sized, non-Material checkbox.
///
/// `checked != null` makes the checkbox controlled (SemiTag.visible
/// convention): the widget renders `checked` and only emits events. Releasing
/// control (checked back to null) retains the last controlled value; entering
/// control preserves local state. Uncontrolled, the internal value starts at
/// [defaultChecked] and toggles unless the event calls `preventDefault`.
///
/// Membership of a [SemiCheckboxGroup] requires a non-null [value] and an
/// enclosing group scope; inside a group `checked`/`defaultChecked` are
/// ignored, `disabled` is the OR of both levels and `type` follows the group.
class SemiCheckbox extends StatefulWidget {
  const SemiCheckbox({
    super.key,
    this.label,
    this.extra,
    this.checked,
    this.defaultChecked = false,
    this.indeterminate = false,
    this.disabled = false,
    this.value,
    this.type = SemiCheckboxType.normal,
    this.onChanged,
    this.onHover,
    this.onFocusChange,
    this.autofocus = false,
    this.semanticsLabel,
  });

  /// Key of the inner check box slot (16x20 line-height geometry).
  static const Key innerBoxKey = Key('SemiCheckbox.innerBox');

  /// Key of the card/pureCard outer frame decoration.
  static const Key outerBoxKey = Key('SemiCheckbox.outerBox');

  /// String or Widget.
  final Object? label;

  /// String or Widget; the secondary line under the label.
  final Object? extra;
  final bool? checked;
  final bool defaultChecked;

  /// Style-only mixed state (Semantics `mixed`); [checked] wins the icon.
  final bool indeterminate;
  final bool disabled;

  /// Group identity; non-null plus an enclosing scope makes this a member.
  final Object? value;
  final SemiCheckboxType type;
  final ValueChanged<SemiCheckboxChangeEvent>? onChanged;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final String? semanticsLabel;

  @override
  State<SemiCheckbox> createState() => _SemiCheckboxState();
}

class _SemiCheckboxState extends State<SemiCheckbox> {
  bool _checked = false;
  bool _hovering = false, _pressed = false, _focused = false;

  /// Mirrors the browser `:focus-visible` heuristic (the button
  /// `_keyboardUsed` gate): the outline only paints after keyboard input,
  /// never after mouse interaction.
  bool _keyboardUsed = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checked = widget.checked ?? widget.defaultChecked;
    _focusNode.addListener(_handleFocusChange);
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void didUpdateWidget(SemiCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // SemiTag.visible convention: releasing control retains the last
    // controlled value instead of resetting (upstream resets to false).
    if (oldWidget.checked != null && widget.checked == null) {
      _checked = oldWidget.checked!;
    }
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
    widget.onHover?.call(value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _toggle() {
    final scope = context.getInheritedWidgetOfExactType<_CheckboxGroupScope>();
    final Object? value = widget.value;
    if (scope != null && value != null) {
      if (scope.disabled || widget.disabled) return;
      final event = SemiCheckboxChangeEvent(!scope.values.contains(value));
      try {
        // Upstream CheckboxFoundation.handleChangeInGroup order: the child
        // onChange fires first, then the group is notified unless stopped.
        widget.onChanged?.call(event);
        if (!event._stopped) scope.notifyChange(value, event);
      } finally {
        event._active = false;
      }
      return;
    }
    if (widget.disabled) return;
    final event = SemiCheckboxChangeEvent(!(widget.checked ?? _checked));
    try {
      widget.onChanged?.call(event);
      if (!event.defaultPrevented && widget.checked == null) {
        setState(() => _checked = event.checked);
      }
    } finally {
      event._active = false;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _toggle();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static Widget _slot(Object? value, TextStyle style) {
    if (value == null) return const SizedBox.shrink();
    if (value is Widget) return value;
    return Text(value.toString(), style: style);
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiCheckboxTheme.resolve(context);
    final scope = context
        .dependOnInheritedWidgetOfExactType<_CheckboxGroupScope>();
    final group = (scope != null && widget.value != null) ? scope : null;
    final checked = group != null
        ? group.values.contains(widget.value)
        : (widget.checked ?? _checked);
    final disabled = group != null
        ? group.disabled || widget.disabled
        : widget.disabled;
    final type = group != null ? group.type : widget.type;
    final isCard = type != SemiCheckboxType.normal;
    final isPureCard = type == SemiCheckboxType.pureCard;
    final mixed = widget.indeterminate && !checked;
    final filled = checked || widget.indeterminate;
    final hovered = _hovering && !disabled;
    final pressed = _pressed && !disabled;
    final showFocus = _focused && _keyboardUsed && !disabled;

    // Inner check box: 16x16 paint box inside the 16x20 line-height slot.
    var boxBg = t.colorCheckboxDefaultBgDefault;
    var boxBorder = t.colorCheckboxDefaultBorderDefault;
    var iconColor = t.colorCheckboxCheckedIconDefault;
    if (disabled) {
      if (filled) {
        // `opacity: 0.75;` plus `box-shadow: inset 0 0 0 ... checked-bg-disabled`.
        boxBg = t.colorCheckboxCheckedBgDisabled;
        boxBorder = t.colorCheckboxCheckedBgDisabled;
        iconColor = t.colorCheckboxCheckedIconDisabled;
      } else {
        boxBg = t.colorCheckboxDisabledBgDefault;
        boxBorder = t.colorCheckboxDisabledBorderDefault;
      }
    } else if (filled) {
      if (pressed) {
        boxBg = t.colorCheckboxCheckedBgActive;
        boxBorder = t.colorCheckboxCheckedBorderActive;
        iconColor = t.colorCheckboxCheckedIconActive;
      } else if (hovered) {
        boxBg = t.colorCheckboxCheckedBgHover;
        boxBorder = t.colorCheckboxCheckedBorderHover;
        iconColor = t.colorCheckboxCheckedIconHover;
      } else {
        boxBg = t.colorCheckboxCheckedBgDefault;
        boxBorder = t.colorCheckboxCheckedBorderDefault;
      }
    } else if (pressed) {
      boxBg = t.colorCheckboxDefaultBgActive;
      boxBorder = t.colorCheckboxDefaultBorderHover;
    } else if (hovered) {
      boxBg = t.colorCheckboxDefaultBgHover;
      boxBorder = t.colorCheckboxDefaultBorderHover;
    }
    if (isCard && !filled && !disabled) {
      // `cardType_inner-bg-*` force the unchecked card box white (the three
      // `var(--semi-color-white)` overrides); checked states keep the checked
      // fill + white icon (upstream CSS cascade of `-checked` over `-cardType`).
      boxBg = pressed
          ? t.colorCheckboxCardTypeInnerBgActive
          : hovered
          ? t.colorCheckboxCardTypeInnerBgHover
          : t.colorCheckboxCardTypeInnerBgDefault;
    }
    if (showFocus && !isCard && !checked) {
      // `.focus-border` (focusInner only): `box-shadow: inset 0 0 0
      // $size-checkbox_inner-shadow` in the hover border color.
      boxBorder = t.colorCheckboxDefaultBorderHover;
    }
    Widget icon = const SizedBox.shrink();
    if (checked) {
      icon = SemiIcon(
        SemiIcons.checkboxTick,
        customSize: _CheckboxMetrics.tickIconSize,
        color: iconColor,
      );
    } else if (widget.indeterminate) {
      icon = SemiIcon(
        SemiIcons.checkboxIndeterminate,
        customSize: _CheckboxMetrics.tickIconSize,
        color: iconColor,
      );
    }
    Widget box = SizedBox(
      width: t.widthCheckboxInner,
      height: t.widthCheckboxInner,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(t.radiusCheckboxInner),
          border: Border.all(
            width: t.sizeCheckboxInnerShadow,
            color: boxBorder,
          ),
          boxShadow: showFocus && !isCard
              ? [
                  // `outline: $width-checkbox-outline solid
                  // $color-checkbox_primary-outline-focus` painted outside the
                  // border box without layout impact.
                  BoxShadow(
                    color: t.colorCheckboxPrimaryOutlineFocus,
                    spreadRadius: t.widthCheckboxOutline,
                  ),
                ]
              : null,
        ),
        child: Center(child: icon),
      ),
    );
    if (disabled && filled) {
      box = Opacity(
        opacity: _CheckboxMetrics.disabledCheckedOpacity,
        child: box,
      );
    }
    Widget slot = SizedBox(
      key: SemiCheckbox.innerBoxKey,
      width: t.widthCheckboxInner,
      height: t.heightCheckboxInner,
      child: Center(child: box),
    );
    if (isPureCard) {
      // `opacity: 0; width: 0;` — the hidden input keeps focus/blur semantics
      // upstream; Flutter semantics live on the wrapper Semantics node.
      slot = Opacity(
        opacity: _CheckboxMetrics.pureCardHideOpacity,
        child: SizedBox(
          width: _CheckboxMetrics.pureCardZeroWidth,
          height: t.heightCheckboxInner,
          child: slot,
        ),
      );
    }
    final gap = isPureCard
        ? _CheckboxMetrics.pureCardGap
        : t.spacingCheckboxLabelPaddingLeft;

    final labelStyle = TextStyle(
      fontSize: isCard
          ? t.fontCheckboxCardTypeAddonSize
          : global.typography.fontSizeRegular,
      fontWeight: isCard ? t.fontCheckboxCardTypeAddonFontWeight : null,
      height: isCard
          ? t.fontCheckboxCardTypeAddonLineHeight /
                t.fontCheckboxCardTypeAddonSize
          : t.fontCheckboxLabelLineHeight / global.typography.fontSizeRegular,
      color: disabled
          ? t.colorCheckboxLabelTextDisabled
          : isCard
          ? t.colorCheckboxCardTypeAddonTextDefault
          : t.colorCheckboxLabelTextDefault,
    );
    final extraStyle = TextStyle(
      fontSize: isCard
          ? t.fontCheckboxCardTypeExtraSize
          : global.typography.fontSizeRegular,
      fontWeight: isCard ? t.fontCheckboxCardTypeExtraFontWeight : null,
      height: isCard
          ? t.fontCheckboxCardTypeExtraLineHeight /
                t.fontCheckboxCardTypeExtraSize
          : null,
      color: disabled
          ? t.colorCheckboxLabelTextDisabled
          : isCard
          ? t.colorCheckboxCardTypeExtraTextDefault
          : t.colorCheckboxExtraTextDefault,
    );
    final content = <Widget>[
      if (widget.label != null) _slot(widget.label, labelStyle),
      if (widget.label != null && widget.extra != null)
        SizedBox(height: t.spacingCheckboxExtraMarginTop),
      if (widget.extra != null) _slot(widget.extra, extraStyle),
    ];
    // Upstream root `display: flex` stretches the row to its (bounded)
    // container while `display: inline-flex` inside horizontal groups keeps
    // content sizing; unbounded constraints fall back to content sizing so
    // the checkbox composes inside Rows and Wraps.
    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final texts = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            slot,
            if (content.isNotEmpty && gap > 0) SizedBox(width: gap),
            if (content.isNotEmpty)
              constraints.hasBoundedWidth ? Flexible(child: texts) : texts,
          ],
        );
      },
    );
    if (isCard) {
      body = DecoratedBox(
        key: SemiCheckbox.outerBoxKey,
        decoration: BoxDecoration(
          color: disabled
              ? checked
                    ? t.colorCheckboxCardTypeCheckedDisabledBg
                    : const Color(0x00000000)
              : checked
              ? t.colorCheckboxCardTypeCheckedBg
              : pressed
              ? t.colorCheckboxCardTypeBgActive
              : hovered
              ? t.colorCheckboxCardTypeBgHover
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(t.radiusCheckboxCardType),
          border: Border.all(
            width: checked && disabled
                ? t.widthCheckboxCardTypeCheckedDisabledBorder
                : t.widthCheckboxCardTypeCheckedBorder,
            color: disabled
                ? checked
                      ? t.colorCheckboxCardTypeCheckedDisabledBorderDefault
                      : t.colorCheckboxCardTypeBorderDefault
                : checked
                ? pressed
                      ? t.colorCheckboxCardTypeCheckedBorderActive
                      : hovered
                      ? t.colorCheckboxCardTypeCheckedBorderHover
                      : t.colorCheckboxCardTypeCheckedBorderDefault
                : t.colorCheckboxCardTypeBorderDefault,
          ),
          boxShadow: showFocus
              ? [
                  BoxShadow(
                    color: t.colorCheckboxPrimaryOutlineFocus,
                    spreadRadius: t.widthCheckboxOutline,
                  ),
                ]
              : null,
        ),
        // RTL-safe directional padding (equal start/end).
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            t.spacingCheckboxCardTypePaddingX,
            t.spacingCheckboxCardTypePaddingY,
            t.spacingCheckboxCardTypePaddingX,
            t.spacingCheckboxCardTypePaddingY,
          ),
          child: body,
        ),
      );
    }
    return Semantics(
      checked: mixed ? null : checked,
      mixed: mixed ? true : null,
      enabled: !disabled,
      label:
          widget.semanticsLabel ??
          (widget.label is String ? widget.label! as String : null),
      onTap: disabled ? null : _toggle,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: !disabled,
        onFocusChange: (v) {
          setState(() => _focused = v);
          widget.onFocusChange?.call(v);
        },
        onKeyEvent: _handleKey,
        child: MouseRegion(
          cursor: disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          onEnter: (_) => _setHover(true),
          onExit: (_) => _setHover(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : _toggle,
            onTapDown: disabled
                ? null
                : (_) => setState(() {
                    _pressed = true;
                    _keyboardUsed = false;
                  }),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _CheckboxGroupScope extends InheritedWidget {
  const _CheckboxGroupScope({
    required this.values,
    required this.disabled,
    required this.type,
    required this.notifyChange,
    required super.child,
  });

  final List<Object> values;
  final bool disabled;
  final SemiCheckboxType type;
  final void Function(Object value, SemiCheckboxChangeEvent event) notifyChange;

  @override
  bool updateShouldNotify(_CheckboxGroupScope oldWidget) =>
      !listEquals(values, oldWidget.values) ||
      disabled != oldWidget.disabled ||
      type != oldWidget.type ||
      notifyChange != oldWidget.notifyChange;
}

/// A scope that hands value/disabled/type down to its member [SemiCheckbox]es
/// (upstream React context). Membership needs a non-null child `value`; a
/// nested group's scope wins over the outer one.
///
/// Controlled (`value != null`) only notifies; releasing the controlled value
/// resets to empty (upstream CheckboxGroupFoundation.handlePropValueChange).
class SemiCheckboxGroup extends StatefulWidget {
  const SemiCheckboxGroup({
    super.key,
    this.value,
    this.defaultValue,
    this.options,
    this.children,
    this.direction = SemiCheckboxDirection.vertical,
    this.disabled = false,
    this.type = SemiCheckboxType.normal,
    this.onChanged,
  });

  final List<Object>? value;
  final List<Object>? defaultValue;

  /// Options mode; takes priority over [children] (upstream render order).
  final List<SemiCheckboxOption>? options;

  /// Children mode: arbitrary descendants, members join via the scope.
  final List<Widget>? children;
  final SemiCheckboxDirection direction;
  final bool disabled;
  final SemiCheckboxType type;
  final ValueChanged<List<Object>>? onChanged;

  @override
  State<SemiCheckboxGroup> createState() => _SemiCheckboxGroupState();
}

class _SemiCheckboxGroupState extends State<SemiCheckboxGroup> {
  late List<Object> _value;

  @override
  void initState() {
    super.initState();
    _value = List.of(widget.value ?? widget.defaultValue ?? const []);
  }

  @override
  void didUpdateWidget(SemiCheckboxGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // lodash isEqual in upstream componentDidUpdate: sync on any list change.
    if (!listEquals(oldWidget.value, widget.value)) {
      if (widget.value != null) {
        _value = List.of(widget.value!);
      } else if (oldWidget.value != null) {
        // Releasing control resets the group to empty (Form.CheckboxGroup).
        _value = [];
      }
    }
  }

  void _handleMemberChange(Object value, SemiCheckboxChangeEvent event) {
    final newValue = event.checked
        ? <Object>[..._value, value]
        : _value.where((entry) => entry != value).toList(growable: false);
    if (widget.value != null) {
      // Controlled mode only needs to notify.
      widget.onChanged?.call(newValue);
      return;
    }
    if (event.defaultPrevented) return;
    setState(() => _value = newValue);
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiCheckboxTheme.resolve(context);
    final items = <Widget>[
      if (widget.options != null)
        for (final option in widget.options!)
          SemiCheckbox(
            label: option.label,
            extra: option.extra,
            value: option.value,
            disabled: option.disabled,
          )
      else
        ...?widget.children,
    ];
    final isCard = widget.type != SemiCheckboxType.normal;
    Widget inner;
    if (widget.direction == SemiCheckboxDirection.horizontal) {
      inner = Wrap(
        spacing: t.spacingCheckboxGroupHorizontalMarginRight,
        runSpacing: t.spacingCheckboxGroupHorizontalMarginRight,
        children: items,
      );
    } else {
      final gap = isCard
          ? t.spacingCheckboxCardGroupVerticalMarginBottom
          : t.spacingCheckboxGroupVerticalItemMarginBottom;
      final children = <Widget>[
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          items[i],
        ],
      ];
      inner = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    return _CheckboxGroupScope(
      values: _value,
      disabled: widget.disabled,
      type: widget.type,
      notifyChange: _handleMemberChange,
      child: inner,
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_checkbox.py for the 68 = 66 themed + 2
/// INTERNAL accounting; the hardcodes below are the 另列 entries.
abstract final class _CheckboxMetrics {
  /// Upstream `$spacing-checkbox_extra-paddingLeft: $width-icon-medium + $spacing-tight`
  /// (packages/semi-foundation/checkbox/variables.scss) is declared but never
  /// referenced by checkbox.scss; kept as the widget-internal extra indent.
  // ignore: unused_field
  static const double extraPaddingLeft = 24;

  /// Upstream `$transform_scale-checkbox: var(--semi-transform_scale-none)`
  /// (packages/semi-foundation/checkbox/animation.scss) is `scale(1,1)` — no
  /// transform is applied.
  // ignore: unused_field
  static const double transformScaleCheckbox = 1;

  /// checkbox.scss `.semi-checkbox-inner-display .semi-checkbox-icon` —
  /// `font-size: 16px`.
  static const double tickIconSize = 16;

  /// checkbox.scss `.semi-checkbox-inner-pureCardType` — `opacity: 0;`.
  static const double pureCardHideOpacity = 0;

  /// checkbox.scss `.semi-checkbox-inner-pureCardType` — `width: 0;`.
  static const double pureCardZeroWidth = 0;

  /// checkbox.scss `.semi-checkboxGroup-vertical-pureCardType` —
  /// `column-gap: 0`.
  static const double pureCardGap = 0;

  /// checkbox.scss `.semi-checkbox-focus` — `outline: $width-checkbox-outline solid $color-checkbox_primary-outline-focus`.
  // ignore: unused_field
  static const String focusRingOutline =
      r'outline: $width-checkbox-outline solid $color-checkbox_primary-outline-focus';

  /// checkbox.scss `.semi-checkbox-inner-display` — `box-shadow: inset 0 0 0 $size-checkbox_inner-shadow` (inset border structure).
  // ignore: unused_field
  static const String innerInsetBorder =
      r'box-shadow: inset 0 0 0 $size-checkbox_inner-shadow';

  /// checkbox.scss `.semi-checkbox-disabled .inner-display` — `opacity: 0.75;`.
  static const double disabledCheckedOpacity = 0.75;
}
