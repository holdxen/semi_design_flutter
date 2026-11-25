import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_radio_theme.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';

/// Radio presentation: plain, button, card framed, or card with the radio
/// circle hidden (upstream `default` / `button` / `card` / `pureCard`; the
/// upstream name `default` is a Dart reserved word).
enum SemiRadioType { normal, button, card, pureCard }

/// Selection-cancel semantics: [SemiRadioMode.advanced] allows deselecting the
/// current member of a group (upstream renders a checkbox input in that mode).
enum SemiRadioMode { normal, advanced }

/// Button-type sizing triple (upstream `small` / `middle` / `large` — the
/// middle name is copied verbatim from strings.BUTTON_SIZE).
enum SemiRadioButtonSize { small, middle, large }

/// Group layout axis. Vertical stacks with a row gap, horizontal wraps;
/// button groups lay out inline and ignore the direction (upstream).
enum SemiRadioDirection { horizontal, vertical }

/// A synchronous, cancelable checked-state change request. Late prevention or
/// stopping has no effect: the event is sealed once the dispatch completes.
class SemiRadioChangeEvent {
  SemiRadioChangeEvent(this.checked, this.value);

  /// The proposed new checked value of the member.
  final bool checked;

  /// The proposed group value: the member's [SemiRadio.value] when selecting
  /// and null when cancelling (upstream `RadioChangeEvent.target.value`, the
  /// flat form of `target{}`).
  final Object? value;

  bool _prevented = false, _stopped = false, _active = true;

  bool get defaultPrevented => _prevented;

  /// Rejects the checked-state application of an uncontrolled widget (the
  /// standalone toggle or the group value mutation). Controlled widgets only
  /// emit events and are unaffected, mirroring SemiCheckboxChangeEvent.
  void preventDefault() {
    if (_active) _prevented = true;
  }

  /// Cancels the rest of the notification chain (upstream radio.tsx fires the
  /// group before the member; stopping breaks before the member's onChanged).
  void stopPropagation() {
    if (_active) _stopped = true;
  }
}

/// One options-mode entry of [SemiRadioGroup].
class SemiRadioOption {
  const SemiRadioOption({
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

/// A source-sized, non-Material radio.
///
/// `checked != null` makes the radio controlled (SemiTag.visible convention):
/// the widget renders `checked` and only emits events. Releasing control
/// (checked back to null) retains the last controlled value; entering control
/// preserves local state. Uncontrolled, the internal value starts at
/// [defaultChecked] and toggles unless the event calls `preventDefault`.
///
/// Membership of a [SemiRadioGroup] requires a non-null [value] and an
/// enclosing group scope; inside a group `checked`/`defaultChecked` are
/// ignored, `disabled` is the OR of both levels and `type`/`mode`/button size
/// follow the group. Group members are mutually exclusive: exactly the member
/// whose `value` equals the group value renders checked.
class SemiRadio extends StatefulWidget {
  // `child` is a required positional parameter: Dart cannot mix optional
  // positional and named parameters, so the label of the plan's `[child,]`
  // sketch is required (pass null for a label-less radio).
  const SemiRadio(
    this.child, {
    super.key,
    this.extra,
    this.checked,
    this.defaultChecked = false,
    this.disabled = false,
    this.value,
    this.type = SemiRadioType.normal,
    this.mode = SemiRadioMode.normal,
    this.onChanged,
    this.onHover,
    this.onFocusChange,
    this.autofocus = false,
    this.semanticsLabel,
  });

  /// Key of the inner radio circle slot (16x20 line-height geometry).
  static const Key innerBoxKey = Key('SemiRadio.innerBox');

  /// Key of the card/pureCard frame (and of the button surface decoration).
  static const Key outerBoxKey = Key('SemiRadio.outerBox');

  /// String or Widget; the label (upstream `children`).
  final Object? child;

  /// String or Widget; the secondary line under the label.
  final Object? extra;
  final bool? checked;
  final bool defaultChecked;
  final bool disabled;

  /// Group identity; non-null plus an enclosing scope makes this a member.
  final Object? value;
  final SemiRadioType type;
  final SemiRadioMode mode;
  final ValueChanged<SemiRadioChangeEvent>? onChanged;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final String? semanticsLabel;

  @override
  State<SemiRadio> createState() => _SemiRadioState();
}

class _SemiRadioState extends State<SemiRadio> {
  bool _checked = false;
  bool _hovering = false, _pressed = false, _focused = false;

  /// Mirrors the browser `:focus-visible` heuristic (the button
  /// `_keyboardUsed` gate): the outline only paints after keyboard input,
  /// never after mouse interaction.
  bool _keyboardUsed = false;

  final FocusNode _focusNode = FocusNode();

  /// Group registry link (roving tabindex order); null when not a member.
  _SemiRadioGroupState? _joinedGroup;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked ?? widget.defaultChecked;
    _focusNode.addListener(_handleFocusChange);
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
    _syncMembership();
  }

  @override
  void didUpdateWidget(SemiRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // SemiTag.visible convention: releasing control retains the last
    // controlled value instead of resetting (upstream resets to false).
    if (oldWidget.checked != null && widget.checked == null) {
      _checked = oldWidget.checked!;
    }
    _syncMembership();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _joinedGroup?._unregister(this);
    _joinedGroup = null;
    super.dispose();
  }

  /// Members (non-null value inside a scope) join the group registry, which
  /// drives the roving tabindex and the arrow-key selection movement.
  void _syncMembership() {
    final scope = context.getInheritedWidgetOfExactType<_RadioGroupScope>();
    final target = (scope != null && widget.value != null) ? scope.group : null;
    if (target == _joinedGroup) return;
    _joinedGroup?._unregister(this);
    _joinedGroup = target;
    target?._register(this);
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

  /// Click/keyboard activation.
  ///
  /// In a group the upstream chain runs group-first (radio.tsx :176-184):
  /// `scope.notifyChange(event)` (the group's onChanged) unless the member is
  /// re-clicked while already selected in normal mode — that case is fully
  /// silent, mirroring native radios emitting no change event for the checked
  /// input (the `lastValue !== value` gate of radioGroupFoundation.handleChange
  /// :58). Otherwise the member's own `onChanged` follows unless the event
  /// called `stopPropagation`, and the uncontrolled group value lands unless
  /// prevented. Standalone radios toggle like SemiCheckbox.
  void _activate() {
    final scope = context.getInheritedWidgetOfExactType<_RadioGroupScope>();
    if (scope != null && widget.value != null) {
      if (scope.disabled || widget.disabled) return;
      final bool selected = scope.value == widget.value;
      if (scope.mode == SemiRadioMode.normal && selected) {
        scope.group.setRoving(widget.value);
        return;
      }
      final event = (scope.mode == SemiRadioMode.advanced && selected)
          // advanced 点已选项 → 取消（组值置 null、event.checked=false、
          // event.value=null，上游 radioGroupFoundation.handleChange :46）。
          ? SemiRadioChangeEvent(false, null)
          : SemiRadioChangeEvent(true, widget.value);
      try {
        scope.group.notifyChange(event);
        if (!event._stopped) widget.onChanged?.call(event);
        if (!event.defaultPrevented) scope.group.applyChange(event);
      } finally {
        event._active = false;
      }
      scope.group.setRoving(widget.value);
      return;
    }
    if (widget.disabled) return;
    final event = SemiRadioChangeEvent(
      !(widget.checked ?? _checked),
      widget.value,
    );
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
    final scope = context.getInheritedWidgetOfExactType<_RadioGroupScope>();
    if (scope != null && widget.value != null) {
      // WAI-ARIA radiogroup roving (upstream leans on native radio semantics;
      // reimplemented here after semi_dropdown._handleKey's enabled wrap):
      // arrows move to the next/previous enabled member and select it, Space
      // selects the focused member, Enter is not intercepted (native radios do
      // not respond to Enter).
      if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowDown) {
        scope.group.moveSelection(this, forward: true);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowUp) {
        scope.group.moveSelection(this, forward: false);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.space) {
        _activate();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _activate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static Widget _slot(Object? value, TextStyle style, {TextAlign? align}) {
    if (value == null) return const SizedBox.shrink();
    if (value is Widget) return value;
    return Text(value.toString(), style: style, textAlign: align);
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiRadioTheme.resolve(context);
    final scope = context
        .dependOnInheritedWidgetOfExactType<_RadioGroupScope>();
    final group = (scope != null && widget.value != null) ? scope : null;
    final checked = group != null
        ? group.value == widget.value
        : (widget.checked ?? _checked);
    final disabled = group != null
        ? group.disabled || widget.disabled
        : widget.disabled;
    final type = group != null ? group.type : widget.type;
    final buttonSize = group != null
        ? group.buttonSize
        : SemiRadioButtonSize.middle;
    final isButton = type == SemiRadioType.button;
    final isCard = type == SemiRadioType.card || type == SemiRadioType.pureCard;
    final isPureCard = type == SemiRadioType.pureCard;
    final focusOuter = isCard || isButton;
    // Live roving lookup: the captured scope [current] is computed before the
    // members register on the first build, so the first-enabled derivation
    // must run against the live registry (registration order == tree order).
    final isCurrent = group != null && group.liveCurrent == widget.value;
    final hovered = _hovering && !disabled;
    final pressed = _pressed && !disabled;
    final showFocus = _focused && _keyboardUsed && !disabled;

    // Inner radio circle: 16x16 paint box inside the 20px line-height slot
    // (radio.scss `.semi-radio-inner`).
    var boxBg = t.colorRadioDefaultBgDefault;
    var boxBorder = t.colorRadioDefaultBorderDefault;
    var boxBorderWidth = t.widthRadioInnderBorder;
    if (disabled) {
      boxBg = checked
          ? t.colorRadioCheckedBgDisabled
          : t.colorRadioDisabledBgDefault;
      boxBorder = checked
          ? t.colorRadioCheckedBorderDisabled
          : t.colorRadioDefaultBorderDisabled;
    } else if (checked) {
      boxBg = pressed
          ? t.colorRadioPrimaryBgActive
          : hovered
          ? t.colorRadioPrimaryBgHover
          : t.colorRadioPrimaryBgDefault;
      if (isCard) {
        // The card-family checked border fields win over the generic ones
        // (radio.scss `.cardRadioGroup_checked` cascade).
        boxBorder = pressed
            ? t.colorRadioCardRadioGroupCheckedBorderActive
            : hovered
            ? t.colorRadioCardRadioGroupCheckedBorderHover
            : t.colorRadioPrimaryBorderDefault;
      } else {
        boxBorder = pressed
            ? t.colorRadioCheckedBorderActive
            : hovered
            ? t.colorRadioCheckedBorderHover
            : t.colorRadioPrimaryBorderDefault;
      }
    } else if (pressed) {
      boxBg = t.colorRadioDefaultBgActive;
      boxBorder = t.colorRadioDefaultBorderHover;
      boxBorderWidth = t.widthRadioHoverBorder;
    } else if (hovered) {
      boxBg = t.colorRadioDefaultBgHover;
      boxBorder = t.colorRadioDefaultBorderHover;
      boxBorderWidth = t.widthRadioHoverBorder;
    }
    if (isCard && !checked && !disabled) {
      // `card-bg-*` force the card-mode circle white (radio.scss
      // `.cardRadioGroup .inner-display` three `var(--semi-color-white)`
      // overrides).
      boxBg = pressed
          ? t.colorRadioCardBgActive
          : hovered
          ? t.colorRadioCardBgHover
          : t.colorRadioCardBgDefault;
    }
    if (showFocus && !focusOuter && !checked) {
      // `.semi-radio-focus-border`: `border: solid $width-radio_hover-border
      // $color-radio_default-border-hover`.
      boxBorder = t.colorRadioDefaultBorderHover;
      boxBorderWidth = t.widthRadioHoverBorder;
    }

    final buttonFontSize = switch (buttonSize) {
      SemiRadioButtonSize.small => t.fontRadioButtonRadioSmallDefaultSize,
      SemiRadioButtonSize.middle => t.fontRadioButtonRadioMiddleDefaultSize,
      SemiRadioButtonSize.large => t.fontRadioButtonRadioLargeDefaultSize,
    };
    final TextStyle labelStyle;
    if (isButton) {
      labelStyle = TextStyle(
        fontSize: buttonFontSize,
        fontWeight: checked
            ? t.fontRadioButtonRadioCheckedFontWeight
            : hovered
            ? t.fontRadioButtonRadioHoverFontWeight
            : t.fontRadioButtonRadioDefaultFontWeight,
        // No fixed line-height: inherit from DefaultTextStyle.
        color: disabled
            ? t.colorRadioButtonRadioTextDisabled
            : checked
            ? t.colorRadioAddonButtonRadioTextChecked
            : t.colorRadioButtonRadioTextDefault,
      );
    } else if (isCard) {
      labelStyle = TextStyle(
        fontSize: t.fontRadioCardRadioGroupAddonSize,
        fontWeight: t.fontRadioCardRadioGroupAddonFontWeight,
        // No fixed line-height: inherit from DefaultTextStyle.
        color: disabled
            ? t.colorRadioDisabledTextDefault
            : t.colorRadioCardRadioGroupAddonTextDefault,
      );
    } else {
      labelStyle = TextStyle(
        fontSize: global.typography.fontSizeRegular,
        // No fixed line-height: inherit from DefaultTextStyle.
        color: disabled
            ? t.colorRadioDisabledTextDefault
            : t.colorRadioDefaultTextDefault,
      );
    }
    final extraStyle = isCard
        ? TextStyle(
            fontSize: t.fontRadioCardRadioGroupExtraSize,
            fontWeight: t.fontRadioCardRadioGroupExtraFontWeight,
            // No fixed line-height: inherit from DefaultTextStyle.
            color: disabled
                ? t.colorRadioDisabledTextDefault
                : t.colorRadioCardRadioGroupExtraTextDefault,
          )
        : TextStyle(
            fontSize: global.typography.fontSizeRegular,
            color: disabled
                ? t.colorRadioDisabledTextDefault
                : t.colorRadioExtraTextDefault,
          );

    Widget body;
    if (isButton) {
      // Button surface: the addon label carries the padding/colors/radius
      // (radio.scss `.semi-radio-addon-buttonRadio`); the circle stays hidden
      // (`opacity: 0;` upstream) and `extra` is not rendered.
      final (padV, padH) = switch (buttonSize) {
        SemiRadioButtonSize.small => (
          t.spacingRadioAddonButtonRadioSmallPaddingY,
          t.spacingRadioAddonButtonRadioSmallPaddingX,
        ),
        SemiRadioButtonSize.middle => (
          t.spacingRadioAddonButtonRadioMiddlePaddingY,
          t.spacingRadioAddonButtonRadioMiddlePaddingX,
        ),
        SemiRadioButtonSize.large => (
          t.spacingRadioAddonButtonRadioLargePaddingY,
          t.spacingRadioAddonButtonRadioLargePaddingX,
        ),
      };
      body = DecoratedBox(
        key: SemiRadio.outerBoxKey,
        decoration: BoxDecoration(
          color: checked
              ? t.colorRadioAddonButtonRadioBgChecked
              : hovered
              ? t.colorRadioAddonButtonRadioBgHover
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(t.radiusRadioAddonButtonRadio),
          boxShadow: showFocus
              ? [
                  BoxShadow(
                    color: t.colorRadioPrimaryOutlineFocus,
                    spreadRadius: t.widthRadioOutline,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(padH, padV, padH, padV),
          child: _slot(widget.child, labelStyle, align: TextAlign.center),
        ),
      );
      if (group == null) {
        // `-buttonRadioComponent` (standalone button radio): the outer
        // wrapper adds the fill-0 surface around the button.
        body = DecoratedBox(
          decoration: BoxDecoration(
            color: t.colorRadioButtonRadioBgDefault,
            borderRadius: BorderRadius.circular(t.radiusRadioButtonRadio),
          ),
          child: Padding(
            padding: EdgeInsets.all(t.spacingRadioButtonRadioPadding),
            child: body,
          ),
        );
      }
    } else {
      // Checked center dot: the `radio` icon asset is a filled dot that fills
      // the circle box (radio.scss `.inner-display .semi-icon`).
      Widget icon = const SizedBox.shrink();
      if (checked) {
        icon = SemiIcon(
          SemiIcons.radio,
          customSize: t.widthRadioInner,
          color: disabled
              ? t.colorRadioCheckedIconDisabled
              : t.colorRadioPrimaryTextDefault,
        );
      }
      Widget box = SizedBox(
        width: t.widthRadioInner,
        height: t.widthRadioInner,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: boxBg,
            // radio.scss `.semi-radio-inner-display` — `border-radius:
            // $width-radio_inner` (a perfect circle, not a radius token).
            borderRadius: BorderRadius.circular(t.widthRadioInner / 2),
            border: Border.all(width: boxBorderWidth, color: boxBorder),
            boxShadow: showFocus && !focusOuter
                ? [
                    // `.semi-radio-focus`: `outline: $width-radio-outline
                    // solid $color-radio_primary-outline-focus` painted
                    // outside the border box without layout impact.
                    BoxShadow(
                      color: t.colorRadioPrimaryOutlineFocus,
                      spreadRadius: t.widthRadioOutline,
                    ),
                  ]
                : null,
          ),
          child: Center(child: icon),
        ),
      );
      if (disabled) {
        // `.semi-radio-disabled .inner-display` — `opacity: 0.75;`.
        box = Opacity(opacity: _RadioMetrics.disabledInnerOpacity, child: box);
      }
      final showSlot = !isPureCard;
      final slot = SizedBox(
        key: SemiRadio.innerBoxKey,
        width: showSlot ? t.widthRadioInner : 0,
        height: t.heightRadioInnerMin,
        child: showSlot ? Center(child: box) : null,
      );
      // Content column: label over extra with the content row gap; button
      // radios keep the label only (upstream `extra && !isButtonRadio`).
      final content = <Widget>[
        if (widget.child != null) _slot(widget.child, labelStyle),
        if (widget.child != null && widget.extra != null)
          SizedBox(height: t.spacingRadioContentRowGap),
        if (widget.extra != null) _slot(widget.extra, extraStyle),
      ];
      // Upstream root `display: flex` stretches the row to its (bounded)
      // container while `display: inline-flex` keeps content sizing;
      // unbounded constraints fall back to content sizing so the radio
      // composes inside Rows and Wraps.
      body = LayoutBuilder(
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
              if (showSlot) slot,
              if (showSlot && content.isNotEmpty)
                SizedBox(width: t.spacingRadioAddonPaddingLeft),
              if (content.isNotEmpty)
                constraints.hasBoundedWidth ? Flexible(child: texts) : texts,
            ],
          );
        },
      );
      if (isCard) {
        // Card frame (radio.scss `.semi-radio-cardRadioGroup`): paddingX 16 /
        // paddingY 12, radius 3, 1px state border.
        final (cardBg, cardBorderColor, cardBorderWidth) = checked
            ? disabled
                  ? (
                      t.colorRadioCardRadioGroupDisabledBgChecked,
                      t.colorRadioCardRadioGroupBorderDisabledActive,
                      t.widthRadioCardRadioGroupCheckedDisabledBorder,
                    )
                  : (
                      t.colorRadioCardRadioGroupBgChecked,
                      pressed
                          ? t.colorRadioCardRadioGroupCheckedBorderActive
                          : hovered
                          ? t.colorRadioCardRadioGroupCheckedBorderHover
                          : t.colorRadioCardRadioGroupBorderActive,
                      t.widthRadioCardRadioGroupCheckedBorder,
                    )
            : (
                pressed
                    ? t.colorRadioCardRadioGroupBgActive
                    : hovered
                    ? t.colorRadioCardRadioGroupBgHover
                    : t.colorRadioCardRadioGroupBgDefault,
                t.colorRadioCardRadioGroupBorderDefault,
                t.widthRadioCardRadioGroupCheckedBorder,
              );
        body = DecoratedBox(
          key: SemiRadio.outerBoxKey,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(t.radiusRadioCardRadioGroup),
            border: Border.all(width: cardBorderWidth, color: cardBorderColor),
            boxShadow: showFocus
                ? [
                    BoxShadow(
                      color: t.colorRadioPrimaryOutlineFocus,
                      spreadRadius: t.widthRadioOutline,
                    ),
                  ]
                : null,
          ),
          // RTL-safe directional padding (equal start/end).
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              t.spacingRadioCardRadioGroupPaddingX,
              t.spacingRadioCardRadioGroupPaddingY,
              t.spacingRadioCardRadioGroupPaddingX,
              t.spacingRadioCardRadioGroupPaddingY,
            ),
            child: body,
          ),
        );
      }
    }
    return Semantics(
      checked: checked,
      enabled: !disabled,
      label:
          widget.semanticsLabel ??
          (widget.child is String ? widget.child! as String : null),
      onTap: disabled ? null : _activate,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: !disabled,
        // Roving tabindex: the whole group shares one Tab stop (the current
        // member — the selected one, or the first enabled member).
        skipTraversal: group != null && !isCurrent,
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
            onTap: disabled
                ? null
                : () {
                    // Upstream label clicks focus the hidden input.
                    _focusNode.requestFocus();
                    _activate();
                  },
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

/// A scope that hands value/disabled/type/mode/button size down to its member
/// [SemiRadio]es (upstream React context) and owns the roving tabindex plus
/// the group-level change application (upstream RadioGroupFoundation).
/// Membership needs a non-null child `value`; a nested group's scope wins over
/// the outer one.
///
/// Controlled (`value != null`) only notifies; releasing the controlled value
/// retains the last value (checkbox :141 convention).
class SemiRadioGroup extends StatefulWidget {
  const SemiRadioGroup({
    super.key,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.disabled = false,
    this.direction = SemiRadioDirection.horizontal,
    this.type = SemiRadioType.normal,
    this.buttonSize = SemiRadioButtonSize.middle,
    this.mode = SemiRadioMode.normal,
    this.options,
    this.children,
  });

  final Object? value;
  final Object? defaultValue;

  /// Proposed-value callback (SemiRadioChangeEvent carries the flat
  /// `target{checked, value}` pair); fired before the member's onChanged.
  final ValueChanged<SemiRadioChangeEvent>? onChanged;
  final bool disabled;
  final SemiRadioDirection direction;
  final SemiRadioType type;
  final SemiRadioButtonSize buttonSize;
  final SemiRadioMode mode;

  /// Options mode; takes priority over [children] (upstream render order).
  final List<SemiRadioOption>? options;

  /// Children mode: arbitrary descendants, members join via the scope.
  final List<Widget>? children;

  @override
  State<SemiRadioGroup> createState() => _SemiRadioGroupState();
}

class _SemiRadioGroupState extends State<SemiRadioGroup> {
  Object? _value;

  /// Roving tabindex current member value; null derives the Tab stop from the
  /// selected value or the first enabled member.
  Object? _roving;

  /// Member states in registration (tree) order — the roving registry.
  final List<_SemiRadioState> _members = [];

  @override
  void initState() {
    super.initState();
    _value = widget.value ?? widget.defaultValue;
    _roving = _value;
  }

  @override
  void didUpdateWidget(SemiRadioGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // SemiTag.visible convention (checkbox :141): releasing control retains
    // the last value instead of resetting; a controlled change syncs.
    if (widget.value != null && widget.value != oldWidget.value) {
      _value = widget.value;
      _roving = widget.value;
    }
  }

  void _register(_SemiRadioState member) {
    _members.add(member);
  }

  void _unregister(_SemiRadioState member) {
    _members.remove(member);
    if (_roving != null && !_members.any((m) => m.widget.value == _roving)) {
      _roving = null;
    }
  }

  List<_SemiRadioState> get _enabledMembers => [
    for (final member in _members)
      if (!member.widget.disabled) member,
  ];

  /// Roving tabindex current member value (the group's single Tab stop):
  /// the roving override, else the selected value, else the first enabled
  /// member (registration order == tree order).
  Object? get currentRoving {
    if (_roving != null) return _roving;
    if (_value != null) return _value;
    for (final member in _enabledMembers) {
      return member.widget.value;
    }
    return null;
  }

  /// Group-first notification (upstream radio.tsx :176-184 fires the group
  /// callback before the member's).
  void notifyChange(SemiRadioChangeEvent event) {
    widget.onChanged?.call(event);
  }

  /// Uncontrolled value application (RadioGroupFoundation.handleChange lands
  /// the event value — null cancels in advanced mode); controlled groups only
  /// notify.
  void applyChange(SemiRadioChangeEvent event) {
    if (widget.value != null) return;
    setState(() => _value = event.value);
  }

  void setRoving(Object? value) {
    if (_roving == value) return;
    setState(() => _roving = value);
  }

  /// Roving selection movement: arrows move to the next/previous enabled
  /// member (wrapping, skipping disabled) and select it through the full
  /// change chain (semi_dropdown._handleKey's enabled wrap precedent).
  void moveSelection(_SemiRadioState from, {required bool forward}) {
    final enabled = _enabledMembers;
    if (enabled.isEmpty) return;
    final index = enabled.indexOf(from);
    if (index < 0) return;
    final target =
        enabled[(index + (forward ? 1 : -1) + enabled.length) % enabled.length];
    setRoving(target.widget.value);
    target._focusNode.requestFocus();
    target._activate();
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiRadioTheme.resolve(context);
    final items = <Widget>[
      if (widget.options != null)
        for (final option in widget.options!)
          SemiRadio(
            option.label,
            value: option.value,
            disabled: option.disabled,
            extra: option.extra,
          )
      else
        ...?widget.children,
    ];
    Widget inner;
    if (widget.type == SemiRadioType.button) {
      // Button groups are inline-block containers of padded items
      // (radioGroup.tsx `-buttonRadio` + per-item `-buttonRadioGroup`).
      final (itemV, itemH) = switch (widget.buttonSize) {
        // radio.scss `-buttonRadioGroup-small` swaps the two fields in CSS
        // position (`padding: $..._small-paddingX $..._small-paddingY`): the
        // paddingX field is vertical, the paddingY field horizontal.
        SemiRadioButtonSize.small => (
          t.spacingRadioButtonRadioGroupSmallPaddingX,
          t.spacingRadioButtonRadioGroupSmallPaddingY,
        ),
        SemiRadioButtonSize.middle => (
          t.spacingRadioButtonRadioGroupMiddlePadding,
          t.spacingRadioButtonRadioGroupMiddlePadding,
        ),
        SemiRadioButtonSize.large => (
          t.spacingRadioButtonRadioGroupLargePadding,
          t.spacingRadioButtonRadioGroupLargePadding,
        ),
      };
      inner = DecoratedBox(
        decoration: BoxDecoration(
          color: t.colorRadioButtonRadioBgDefault,
          borderRadius: BorderRadius.circular(t.radiusRadioButtonRadio),
        ),
        child: Wrap(
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  itemH,
                  itemV,
                  // `&:not(:last-child) { padding-right:
                  // $spacing-radio_buttonRadioGroup-paddingRight; }` (0).
                  i == items.length - 1
                      ? itemH
                      : t.spacingRadioButtonRadioGroupPaddingRight,
                  itemV,
                ),
                child: items[i],
              ),
          ],
        ),
      );
    } else if (widget.direction == SemiRadioDirection.vertical) {
      // row-gap: $spacing-radio_group_vertical-marginBottom.
      inner = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              SizedBox(height: t.spacingRadioGroupVerticalMarginBottom),
            items[i],
          ],
        ],
      );
    } else {
      // gap: $spacing-radio_group_horizontal-marginRight.
      inner = Wrap(
        spacing: t.spacingRadioGroupHorizontalMarginRight,
        runSpacing: t.spacingRadioGroupHorizontalMarginRight,
        children: items,
      );
    }
    return _RadioGroupScope(
      group: this,
      value: _value,
      disabled: widget.disabled,
      type: widget.type,
      buttonSize: widget.buttonSize,
      mode: widget.mode,
      current: currentRoving,
      child: inner,
    );
  }
}

class _RadioGroupScope extends InheritedWidget {
  const _RadioGroupScope({
    required this.group,
    required this.value,
    required this.disabled,
    required this.type,
    required this.buttonSize,
    required this.mode,
    required this.current,
    required super.child,
  });

  /// Dispatch surface of the group state (change chain, roving, registry).
  final _SemiRadioGroupState group;
  final Object? value;
  final bool disabled;
  final SemiRadioType type;
  final SemiRadioButtonSize buttonSize;
  final SemiRadioMode mode;

  /// Roving tabindex current member value, captured at build time (used for
  /// rebuild notification only).
  final Object? current;

  /// Live roving lookup for members: the captured [current] predates member
  /// registration on the first build.
  Object? get liveCurrent => group.currentRoving;

  @override
  bool updateShouldNotify(_RadioGroupScope oldWidget) =>
      value != oldWidget.value ||
      disabled != oldWidget.disabled ||
      type != oldWidget.type ||
      buttonSize != oldWidget.buttonSize ||
      mode != oldWidget.mode ||
      current != oldWidget.current;
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_radio.py for the 103 = 96 FIELDS + 6 motion +
/// 1 INTERNAL accounting; the hardcodes below are the 另列 entries.
abstract final class _RadioMetrics {
  /// Upstream `$transform_scale-radio: var(--semi-transform_scale-none)`
  /// (packages/semi-foundation/radio/animation.scss) is `scale(1,1)` — no
  /// transform is applied (upstream dead variable).
  // ignore: unused_field
  static const double transformScaleRadio = 1;

  /// radio.scss `.semi-radio-inner` — `margin-top: 2px;` (the circle's
  /// baseline nudge; reproduced by centering the 16px circle in the 20px
  /// `$height-radio_inner_min` slot).
  // ignore: unused_field
  static const double innerMarginTop = 2;

  /// radio.scss `.semi-radio-disabled .semi-radio-inner-display` —
  /// `opacity: 0.75;`.
  static const double disabledInnerOpacity = 0.75;

  /// radio.scss `.semi-radio-focus` —
  /// `outline: $width-radio-outline solid $color-radio_primary-outline-focus`.
  // ignore: unused_field
  static const String focusRingOutline =
      r'outline: $width-radio-outline solid $color-radio_primary-outline-focus';

  /// radio.scss `.semi-radio-focus-border` —
  /// `border: solid $width-radio_hover-border $color-radio_default-border-hover`.
  // ignore: unused_field
  static const String focusRingBorder =
      r'border: solid $width-radio_hover-border $color-radio_default-border-hover';

  /// radio.scss `.semi-radio-inner-display .semi-icon` — `font-size: 14px`
  /// with `svg { width: 100%; height: 100%; }`: the checked dot fills the
  /// 16px circle box.
  // ignore: unused_field
  static const double innerDotIconFill = 14;

  /// radio.scss `.semi-radio-inner-buttonRadio, .semi-radio-inner-pureCardRadio`
  /// — `opacity: 0;` (upstream hides the circle; Flutter omits it entirely).
  // ignore: unused_field
  static const double hiddenInner = 0;

  /// radio.scss `.semi-radio-inner-display` — `border-radius: $width-radio_inner`
  /// (a perfect circle, not a radius token).
  // ignore: unused_field
  static const String circleRadius = r'border-radius: $width-radio_inner';

  /// radio.scss `.semi-radio-addon-buttonRadio` — `text-align: center`.
  // ignore: unused_field
  static const String buttonAddonTextAlign = 'text-align: center';
}
