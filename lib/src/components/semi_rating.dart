import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_rating_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_tooltip.dart';

/// Rating item sizing (upstream `small` / `default`).
///
/// [SemiRating.size] additionally accepts a custom pixel `double` (upstream
/// `size?: 'small' | 'default' | number` — the union is carried as `Object`
/// with an assert, the SemiPinCode.format precedent).
enum SemiRatingSize { small, normal }

/// A source-sized, non-Material rating (upstream Semi Rating).
///
/// `value != null` makes the rating controlled (SemiTag.visible convention):
/// the widget renders `value` and only emits events. Releasing control (value
/// back to null) retains the last controlled value; entering control preserves
/// local state. Uncontrolled, the internal value starts at [defaultValue].
///
/// The displayed fill is `hoverValue ?? value` and each star clips to
/// `clamp(display - i, 0, 1)` — arbitrary decimals render (3.65 clips star 4
/// at 65%).
class SemiRating extends StatefulWidget {
  const SemiRating({
    super.key,
    this.value,
    this.defaultValue = 0,
    this.count = 5,
    this.allowHalf = false,
    this.allowClear = true,
    this.disabled = false,
    this.size = SemiRatingSize.normal,
    this.character,
    this.tooltips,
    this.onChanged,
    this.onHoverChange,
    this.onClick,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticsLabel,
  }) : assert(
         size is SemiRatingSize ||
             (size is double && size > 0 && size < double.infinity),
         'size must be a SemiRatingSize or a positive finite double '
         '(custom pixel size).',
       );

  /// Current rating; non-null makes the widget controlled.
  final double? value;

  /// Uncontrolled initial rating.
  final double defaultValue;

  /// Number of stars.
  final int count;

  /// Allow the x.5 hit on each star (pointer half + keyboard 0.5 step).
  final bool allowHalf;

  /// Clicking the current value again clears to 0 (upstream default true).
  final bool allowClear;
  final bool disabled;

  /// [SemiRatingSize] or a custom pixel `double` (assert-checked union).
  final Object size;

  /// Custom character/icon per star; null renders `SemiIcons.star` at the
  /// size-tier icon size (item.tsx:176).
  final Widget? character;

  /// Hover tip per star; only an integer hover (full star) shows it
  /// (upstream `hoverValue - 1 === ind`).
  final List<String>? tooltips;

  /// Reports every value change (also in controlled mode, which does not land).
  final ValueChanged<double>? onChanged;

  /// Reports the hover preview; mouse/keyboard leave reports null.
  final ValueChanged<double?>? onHoverChange;

  /// Clicked star index (upstream `(e, index)` without the event).
  final void Function(int index)? onClick;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;

  /// Replaces the computed semantics label.
  final String? semanticsLabel;

  @override
  State<SemiRating> createState() => _SemiRatingState();
}

class _SemiRatingState extends State<SemiRating> {
  late double _value;
  double? _hoverValue;
  double? _clearedValue;
  int? _hoverIndex;
  bool _focused = false;

  /// Mirrors the browser `:focus-visible` heuristic (the button
  /// `_keyboardUsed` gate): the outline only paints after keyboard input,
  /// never after mouse interaction.
  bool _keyboardUsed = false;

  /// Pointer x of the in-flight tap-down (the click hit for allowHalf).
  double? _downDx;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _value = widget.value ?? widget.defaultValue;
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void didUpdateWidget(SemiRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    // SemiTag.visible convention: releasing control retains the last
    // controlled value instead of resetting (checkbox :145 same).
    if (oldWidget.value != null && widget.value == null) {
      _value = oldWidget.value!;
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

  /// The committed value: the controlled value, else the internal one.
  double get _current => widget.value ?? _value;

  /// Upstream `updateValue` (foundation.ts :154-162): uncontrolled lands the
  /// value, controlled only notifies.
  void _updateValue(double value) {
    if (widget.value == null) {
      setState(() => _value = value);
    }
    widget.onChanged?.call(value);
  }

  /// Upstream `getStarValue` (foundation.ts :68-84): the pointer x against the
  /// star midline — LTR hits the left half, RTL the right half, at `x.5`.
  double _starValue(int index, double dx, double width) {
    var value = index + 1.0;
    if (widget.allowHalf) {
      final reverse = Directionality.of(context) == TextDirection.rtl;
      if (reverse ? dx > width / 2 : dx < width / 2) {
        value -= 0.5;
      }
    }
    return value;
  }

  /// Upstream `handleHover` (foundation.ts :86-89): same-value hovers are not
  /// re-reported and the `clearedValue` debounce suppresses previewing the
  /// value just cleared (foundation.ts :96).
  void _handleHover(int index, double dx, double width) {
    if (widget.disabled) return;
    final currValue = _starValue(index, dx, width);
    final report = currValue != _hoverValue && currValue != _clearedValue;
    setState(() {
      _hoverIndex = index;
      if (report) {
        _hoverValue = currValue;
        _clearedValue = null;
      }
    });
    if (report) {
      widget.onHoverChange?.call(currValue);
    }
  }

  /// Upstream `handleMouseLeave` (foundation.ts :92-94): always reports null.
  void _handleMouseLeave() {
    if (widget.disabled) return;
    setState(() {
      _hoverIndex = null;
      _hoverValue = null;
      _clearedValue = null;
    });
    widget.onHoverChange?.call(null);
  }

  void _handleTapDown(double dx) {
    _downDx = dx;
    // A tap clears the keyboard gate (checkbox onTapDown same): the ring
    // never shows after mouse interaction.
    if (_keyboardUsed) setState(() => _keyboardUsed = false);
  }

  /// Upstream `handleClick` (foundation.ts :98-109): a hit equal to the
  /// current value with [SemiRating.allowClear] clears to 0 and records
  /// `clearedValue`; a reset also drops the hover preview.
  void _handleClick(int index, double dx, double width) {
    if (widget.disabled) return;
    // Clicking a star focuses the rating (the browser focuses the native
    // radio div on click).
    _focusNode.requestFocus();
    final newValue = _starValue(index, dx, width);
    final isReset = widget.allowClear && newValue == _current;
    _updateValue(isReset ? 0 : newValue);
    if (isReset) {
      setState(() {
        _hoverValue = null;
        _clearedValue = newValue;
      });
      widget.onHoverChange?.call(null);
    } else {
      setState(() => _clearedValue = null);
    }
    widget.onClick?.call(index);
  }

  /// Enter applies the click semantics on the current value: the hit is the
  /// focused star segment, i.e. the current value itself (同值), so
  /// [SemiRating.allowClear] clears to 0.
  void _handleEnter() {
    if (widget.disabled) return;
    final value = _current;
    final isReset = widget.allowClear;
    _updateValue(isReset ? 0 : value);
    if (isReset) {
      setState(() {
        _hoverValue = null;
        _clearedValue = value;
      });
      widget.onHoverChange?.call(null);
    } else {
      setState(() => _clearedValue = null);
    }
    // Upstream `changeFocusStar` (foundation.ts :127-136): value 0 focuses
    // the empty star (its index is `count`), any other value focuses
    // `ceil(value) - 1`.
    widget.onClick?.call(value == 0 ? widget.count : value.ceil() - 1);
  }

  /// Upstream `handleKeyDown` (foundation.ts :119-146): arrows step and wrap
  /// 0<->count; RTL swaps increase/decrease (semi_input_number.dart :1159
  /// direction branch); KeyRepeat repeats (semi_input_number `_handleKey`
  /// gate). Enter applies the click semantics. No Home/End (upstream).
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final isDown = event is KeyDownEvent;
    if (!isDown && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (widget.disabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter) {
      _handleEnter();
      return KeyEventResult.handled;
    }
    final step = widget.allowHalf ? 0.5 : 1.0;
    final reverse = Directionality.of(context) == TextDirection.rtl;
    double? tempValue;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp) {
      tempValue = _current + (reverse ? -step : step);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown) {
      tempValue = _current + (reverse ? step : -step);
    }
    if (tempValue == null) return KeyEventResult.ignored;
    final newValue = tempValue > widget.count
        ? 0.0
        : tempValue < 0
        ? widget.count.toDouble()
        : tempValue;
    _updateValue(newValue);
    setState(() {
      _hoverValue = null;
      _clearedValue = null;
    });
    widget.onHoverChange?.call(null);
    return KeyEventResult.handled;
  }

  static String _formatValue(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';

  @override
  Widget build(BuildContext context) {
    final t = SemiRatingTheme.resolve(context);
    final disabled = widget.disabled;
    final display = _hoverValue ?? _current;
    final showFocus = _focused && _keyboardUsed && !disabled;
    final boxSize = switch (widget.size) {
      SemiRatingSize.small => t.widthRatingItemSmall,
      SemiRatingSize.normal => t.widthRatingItemDefault,
      _ => widget.size as double,
    };
    // item.tsx:176 — `const iconSize = isCustomSize ? 'inherit' : (size === 'small' ? 'default' : 'extra-large');`
    // The `small` tier (`default`) maps to SemiIconSize.normal (16), the
    // `default` tier (`extra-large`) to SemiIconSize.extraLarge (24) and the
    // numeric tier (`inherit`, li font-size == the custom size) to customSize.
    final iconSize = switch (widget.size) {
      SemiRatingSize.small => SemiIconSize.normal,
      SemiRatingSize.normal => SemiIconSize.extraLarge,
      _ => SemiIconSize.inherit,
    };
    final fontSize = switch (widget.size) {
      SemiRatingSize.small => t.fontRatingItemSmallFontSize,
      SemiRatingSize.normal => t.fontRatingItemDefaultFontSize,
      _ => boxSize,
    };

    final children = <Widget>[];
    for (var i = 0; i < widget.count; i++) {
      if (i > 0) {
        // `:not(:last-child) { margin-right: $spacing-rating_item-marginRight }`
        // (RTL mirrors to margin-left — a plain gap is direction-agnostic).
        children.add(SizedBox(width: t.spacingRatingItemMarginRight));
      }
      final index = i;
      Widget item = _RatingItem(
        boxSize: boxSize,
        fontSize: fontSize,
        iconSize: iconSize,
        iconCustomSize: boxSize,
        character: widget.character,
        fraction: (display - i).clamp(0.0, 1.0),
        hovered: _hoverIndex == i && !disabled,
        showFocus: showFocus && display > 0 && display.ceil() - 1 == i,
        disabled: disabled,
        colorFilled: t.colorRatingIconDefault,
        colorEmpty: t.colorRatingBgDefault,
        focusColor: t.colorRatingOutlineFocus,
        focusWidth: t.widthRatingOutlineFocus,
        onHover: (dx) => _handleHover(index, dx, boxSize),
        onTapDown: _handleTapDown,
        onTap: () => _handleClick(index, _downDx ?? boxSize / 2, boxSize),
      );
      if (widget.tooltips != null) {
        final tips = widget.tooltips!;
        // Upstream `showTips = hoverValue - 1 === ind` (index.tsx): only an
        // integer hover (full star) shows the tooltip — a half hover never
        // does.
        item = SemiTooltip(
          content: Text(i < tips.length ? tips[i] : ''),
          trigger: SemiTooltipTrigger.custom,
          visible: _hoverValue == i + 1,
          child: item,
        );
      }
      children.add(item);
    }

    Widget body = Padding(
      // Upstream root: `margin: $spacing-rating-margin; padding: $spacing-rating-padding;`
      padding: EdgeInsets.all(t.spacingRatingMargin + t.spacingRatingPadding),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
    body = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_RatingMetrics.starRadius),
        // `outline: $width-rating-outline-focus solid $color-rating-outline-focus`
        // on the root while value 0 (the star ring covers the rest).
        boxShadow: showFocus && display == 0
            ? [
                BoxShadow(
                  color: t.colorRatingOutlineFocus,
                  spreadRadius: t.widthRatingOutlineFocus,
                ),
              ]
            : null,
      ),
      child: body,
    );
    return Semantics(
      container: true,
      enabled: !disabled,
      label:
          widget.semanticsLabel ??
          'Rating: ${_formatValue(_current)} of ${widget.count} '
              '${_current == 1 ? 'star' : 'stars'}',
      onTap: disabled ? null : _handleEnter,
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
          // Upstream `onMouseLeave` on the list (index.tsx): leaving the whole
          // rating drops the preview; star-to-star moves stay inside.
          onExit: disabled ? null : (_) => _handleMouseLeave(),
          child: body,
        ),
      ),
    );
  }
}

/// One star cell: the two-layer half-fill stack of upstream item.tsx (base
/// character in the empty color, clipped overlay character in the icon color),
/// the hover `scale(1.1)` and the keyboard-gated focus ring.
class _RatingItem extends StatelessWidget {
  const _RatingItem({
    required this.boxSize,
    required this.fontSize,
    required this.iconSize,
    required this.iconCustomSize,
    required this.character,
    required this.fraction,
    required this.hovered,
    required this.showFocus,
    required this.disabled,
    required this.colorFilled,
    required this.colorEmpty,
    required this.focusColor,
    required this.focusWidth,
    required this.onHover,
    required this.onTapDown,
    required this.onTap,
  });

  final double boxSize;
  final double fontSize;
  final SemiIconSize iconSize;

  /// The numeric-size tier's custom icon size (item.tsx `isCustomSize`).
  final double iconCustomSize;
  final Widget? character;

  /// Fill of this star, `clamp(display - index, 0, 1)` (0..1).
  final double fraction;
  final bool hovered;
  final bool showFocus;
  final bool disabled;
  final Color colorFilled, colorEmpty, focusColor;
  final double focusWidth;
  final ValueChanged<double> onHover;
  final ValueChanged<double> onTapDown;
  final VoidCallback onTap;

  Widget _character(BuildContext context, Color color) {
    if (character != null) {
      // Custom characters inherit the star's font-size and color (the li
      // `font-size` + `color: inherit` cascade of rating.scss). `height: 1`
      // pins the text line box to the em square so glyph ink fits the
      // star box — the default line-height multiplier (~1.4x) overflowed
      // and the stack clipped the bottom of CJK glyphs like 「赞」.
      return IconTheme(
        data: IconThemeData(color: color, size: fontSize),
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style
              // No fixed line-height: inherit from DefaultTextStyle.
              .merge(TextStyle(fontSize: fontSize, color: color)),
          child: character!,
        ),
      );
    }
    return SemiIcon(
      SemiIcons.star,
      size: iconSize,
      customSize: iconSize == SemiIconSize.inherit ? iconCustomSize : null,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Upstream item.tsx renders `content` twice: `-second` is the full-size
    // base in `$color-rating-bg-default`; `-first` is the absolutely positioned
    // overlay clipped to `firstWidth` (inline `width: ...%`) in
    // `color: inherit` ($color-rating-icon-default). The ClipRect > Align
    // pair reproduces the clip and `AlignmentDirectional.centerStart` mirrors
    // with RTL (rtl.scss `-first { right: 0 }`).
    Widget layer(Color color) => SizedBox(
      width: boxSize,
      height: boxSize,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: _character(context, color),
      ),
    );
    final fill = Stack(
      children: [
        layer(colorEmpty),
        ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: fraction,
            // Upstream `-first` keeps `height: 100%` (only the width is the
            // runtime inline fraction).
            heightFactor: 1.0,
            child: layer(colorFilled),
          ),
        ),
      ],
    );
    return MouseRegion(
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: disabled ? null : (e) => onHover(e.localPosition.dx),
      onHover: disabled ? null : (e) => onHover(e.localPosition.dx),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Semantics live on the rating root (single tap action).
        excludeFromSemantics: true,
        onTapDown: disabled ? null : (d) => onTapDown(d.localPosition.dx),
        onTap: disabled ? null : onTap,
        child: AnimatedScale(
          // `.semi-rating-star > div:hover { transform: scale(1.1) }` —
          // disabled stars never scale (`-disabled` resets it to none).
          scale: hovered ? _RatingMetrics.hoverScale : 1.0,
          duration: _RatingMetrics.hoverScaleTransition,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_RatingMetrics.starRadius),
              boxShadow: showFocus
                  ? [
                      // `outline: $width-rating-outline-focus solid
                      // $color-rating-outline-focus` on the focused star.
                      BoxShadow(color: focusColor, spreadRadius: focusWidth),
                    ]
                  : null,
            ),
            child: fill,
          ),
        ),
      ),
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_rating.py for the 16 = 12 themed + 3 motion +
/// 1 INTERNAL accounting; the hardcodes below are the 另列 entries.
abstract final class _RatingMetrics {
  /// Upstream `$transform_scale-rating: var(--semi-transform_scale-none)`
  /// (packages/semi-foundation/rating/animation.scss) is `scale(1,1)` — no
  /// transform is applied (rating.scss consumes `$transform-scale-rating`).
  // ignore: unused_field
  static const double transformScaleRating = 1;

  /// rating.scss `.semi-rating` / `.semi-rating-star-wrapper` — `border-radius: 3px`.
  static const double starRadius = 3;

  /// rating.scss `.semi-rating-star > div:hover` — `transform: scale(1.1)`.
  static const double hoverScale = 1.1;

  /// rating.scss `.semi-rating-star` — `transition: all 0.5s`.
  static const Duration hoverScaleTransition = Duration(milliseconds: 500);

  /// rating.scss `.semi-rating-star-first` — `width: 50%` (the CSS default;
  /// upstream item.tsx always overrides it with the inline runtime width).
  // ignore: unused_field
  static const double firstDefaultWidthPercent = 50;
}
