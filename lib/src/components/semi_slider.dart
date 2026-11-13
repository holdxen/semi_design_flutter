import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_slider_theme.dart';
import '../theme/semi_slider_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'semi_tooltip.dart';

/// Per-handle inner dot styling (upstream `handleDot?: { size, color }`).
class SemiSliderHandleDot {
  const SemiSliderHandleDot({this.size, this.color});

  /// Override of `$width-slider_handle_dot` (both axes).
  final double? size;

  /// Override of `$color-slider_handle_dot`.
  final Color? color;
}

/// A source-sized, non-Material slider (upstream Semi Slider).
///
/// `value != null` makes the slider controlled (SemiRating.value convention):
/// the widget renders `value` and only emits events, except while dragging
/// where the handle follows the pointer live (foundation.ts:552 "allow drag
/// for controlled component") and snaps to the `value` that flows back.
/// Releasing control (value back to null) retains the last controlled value;
/// entering control preserves local state. Uncontrolled, the internal value
/// starts at [defaultValue] (`0` / `[0, 0]`).
///
/// [value] / [defaultValue] are `double` in single mode and a length-2
/// `List<double>` when [range] (assert-checked union, the
/// SemiPinCode.format precedent). [onChanged] / [onAfterChange] report
/// `double` or an ascending `List<double>` (never the input list itself).
class SemiSlider extends StatefulWidget {
  const SemiSlider({
    super.key,
    this.value,
    this.defaultValue,
    this.range = false,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.vertical = false,
    this.verticalReverse = false,
    this.included = true,
    this.marks,
    this.showMarkLabel = true,
    this.tooltipOnMark = false,
    this.showTooltip = true,
    this.tipFormatter,
    this.tooltipVisible,
    this.showArrow = true,
    this.showBoundary = false,
    this.handleDot,
    this.onChanged,
    this.onAfterChange,
    this.onMouseUp,
    this.onBlur,
    this.getAriaValueText,
  }) : assert(
         value == null ||
             (range ? value is List && value.length == 2 : value is num),
         'value must be a double (single) or a length-2 List<double> (range).',
       ),
       assert(
         defaultValue == null ||
             (range
                 ? defaultValue is List && defaultValue.length == 2
                 : defaultValue is num),
         'defaultValue must be a double (single) or a length-2 List<double> '
         '(range).',
       ),
       assert(
         handleDot == null ||
             (range
                 ? handleDot is List<SemiSliderHandleDot> &&
                       handleDot.length == 2
                 : handleDot is SemiSliderHandleDot),
         'handleDot must be a SemiSliderHandleDot (single) or a length-2 '
         'List<SemiSliderHandleDot> (range).',
       );

  /// Current value; non-null makes the widget controlled.
  final Object? value;

  /// Uncontrolled initial value (`0` / `[0, 0]` when null).
  final Object? defaultValue;

  /// Whether both ends are draggable (`[v0, v1]` values).
  final bool range;
  final double min;
  final double max;
  final double step;
  final bool disabled;

  /// Flip the axis to vertical; [verticalReverse] flips the value axis too
  /// (min at the visual bottom, labels stay upright).
  final bool vertical;
  final bool verticalReverse;

  /// Whether the fill track renders (the dot highlight included asymmetry is
  /// a verbatim upstream quirk, see docs).
  final bool included;

  /// Scale labels; keys outside `[min, max]` are hidden.
  final Map<double, String>? marks;
  final bool showMarkLabel;

  /// Wrap each mark dot in a tooltip carrying the mark label.
  final bool tooltipOnMark;

  /// Upstream `tipFormatter: null` sentinel split out (差异清单): false hides
  /// every handle tooltip; [tipFormatter] only formats its content.
  final bool showTooltip;

  /// Formats the tooltip content (String or Widget); null renders the value.
  final Object? Function(double value)? tipFormatter;

  /// Forced tooltip visibility; null keeps the hover/drag/focus state machine.
  final bool? tooltipVisible;

  /// Whether the tooltip paints its arrow.
  final bool showArrow;

  /// Show the min/max boundary labels while the slider is hovered.
  final bool showBoundary;

  /// Inner handle dot(s); null renders none.
  final Object? handleDot;

  /// Reports every value change (`double`, or an ascending `List<double>`).
  final ValueChanged<Object?>? onChanged;

  /// Reports the committed value (drag end, click jump, recognized key up,
  /// and — ★ the index.tsx:315 quirk — external controlled `value` changes).
  final ValueChanged<Object?>? onAfterChange;

  /// Fired before [onAfterChange] when a drag session or a recognized key up
  /// ends (upstream `onHandleUpBefore`).
  final VoidCallback? onMouseUp;

  /// Fired when focus leaves the whole slider (movement between the two range
  /// handles is not a blur — the ★ suppression quirk).
  final VoidCallback? onBlur;

  /// `aria-valuetext` provider (`(value, index)`).
  final String Function(double value, int index)? getAriaValueText;

  /// Key of the handle at [index] (0 = 'min', 1 = 'max').
  static Key handleKey(int index) => ValueKey('SemiSlider.handle$index');

  /// Key of the rail.
  static const Key railKey = ValueKey('SemiSlider.rail');

  @override
  State<SemiSlider> createState() => _SemiSliderState();
}

class _SemiSliderState extends State<SemiSlider> {
  /// The internal value (`double` or `List<double>`). Controlled sliders
  /// render `widget.value` except while dragging (live follow).
  late Object _stateValue;

  /// The drag session is active (press on a handle until release).
  bool _dragging = false;

  /// Handle index of the active press/drag (0 = 'min', 1 = 'max').
  int? _dragIndex;

  /// Hovered handle index (upstream `focusPos` tooltip visibility).
  int? _hoverIndex;

  /// Keyboard-focused handle index.
  int? _focusIndex;

  /// Pointer-to-handle-center offset captured at drag start and preserved
  /// (the handle must not jump to the cursor).
  double _dragOffset = 0;

  bool _wrapperHovered = false;

  /// Mirrors the browser `:focus-visible` heuristic (the button
  /// `_keyboardUsed` gate): the outline and tooltip focus state only engage
  /// after keyboard input, never after mouse interaction.
  bool _keyboardUsed = false;

  final FocusNode _minNode = FocusNode();
  final FocusNode _maxNode = FocusNode();
  final GlobalKey _stackKey = GlobalKey();

  /// Value-axis length of the last layout (rail length).
  double _axisLen = 0;

  @override
  void initState() {
    super.initState();
    _stateValue = _initialValue();
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  Object _initialValue() {
    final v = widget.value ?? widget.defaultValue;
    if (v != null) return _normalize(v);
    return widget.range ? [0.0, 0.0] : 0.0;
  }

  /// `double | List<double>` normalization (int literals are accepted and
  /// widened — the Object union carries them as num).
  static Object _normalize(Object v) {
    if (v is List) {
      return [for (final e in v) (e as num).toDouble()];
    }
    return (v as num).toDouble();
  }

  @override
  void didUpdateWidget(SemiSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A single <-> range mode switch re-shapes the internal value (the State
    // is reused across configurations).
    if (widget.range != oldWidget.range) {
      final v = _stateValue;
      _stateValue = widget.range
          ? (v is List<double> ? v : <double>[v as double, v])
          : (v is List<double> ? v[0] : v);
    }
    // SemiRating.value convention (semi_rating.dart:122-129): releasing
    // control retains the last controlled value instead of resetting.
    if (oldWidget.value != null && widget.value == null) {
      _stateValue = _normalize(oldWidget.value!);
    }
    if (widget.value != null && !_sameValue(widget.value, oldWidget.value)) {
      _stateValue = _normalize(widget.value!);
      // ★ index.tsx:315 quirk: external controlled `value` changes also fire
      // onAfterChange (verbatim raw value, not output-rounded). Deferred past
      // the build phase (SemiTooltip._schedulePostFrame idiom): didUpdateWidget
      // runs inside the parent's build, so firing the callback synchronously
      // would break consumers that call setState from it ("called during
      // build") — callbacks only fire from events and post-frame.
      final Object raw = widget.value!;
      final ValueChanged<Object?>? after = widget.onAfterChange;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) after?.call(raw);
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _minNode.dispose();
    _maxNode.dispose();
    super.dispose();
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent && !_keyboardUsed && mounted) {
      setState(() => _keyboardUsed = true);
    }
    return false;
  }

  // -- value model -----------------------------------------------------------

  bool get _isRtl =>
      !widget.vertical && Directionality.of(context) == TextDirection.rtl;

  double get _span => widget.max - widget.min;

  double _clampV(double v) => v < widget.min
      ? widget.min
      : v > widget.max
      ? widget.max
      : v;

  /// ★ outPutValue (foundation.ts:420-447): round to the step's decimal count
  /// (multiplier = 10^decimals(step); step 1 rounds to whole numbers).
  double _round(double v) {
    final multiplier = _pow10(_decimals(widget.step));
    return (v * multiplier).roundToDouble() / multiplier;
  }

  /// JS `String(num)` decimal count (foundation.ts:421-427): integers carry
  /// no decimal part.
  static int _decimals(double num) {
    final text = num == num.roundToDouble() ? '${num.round()}' : '$num';
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(text)) return 0;
    final dot = text.indexOf('.');
    return dot < 0 ? 0 : text.length - dot - 1;
  }

  static double _pow10(int n) {
    var result = 1.0;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }

  /// ★ Step snap relative to 0 (foundation.ts:349-351) — only when
  /// `step != 1` — then clamp to `[min, max]`.
  double _finalize(double v) {
    final snapped = widget.step != 1
        ? (v / widget.step).roundToDouble() * widget.step
        : v;
    return _clampV(snapped);
  }

  /// ★ outPutValue on a pair: round both ends; when crossed, both collapse —
  /// dragging 'min' past max yields `[v1, v1]`, dragging 'max' past min yields
  /// `[v0, v0]` (foundation.ts:441 keyed on focusPos; here the moved handle).
  List<double> _outPair(List<double> pair, int moved) {
    final a = _round(pair[0]);
    final b = _round(pair[1]);
    if (a > b) return moved == 0 ? [b, b] : [a, a];
    return [a, b];
  }

  /// Output form of a stored/displayed value (idempotent on clean values).
  Object _outValueOf(Object v) {
    if (v is List<double>) {
      final a = _round(v[0]);
      final b = _round(v[1]);
      if (a > b) return _dragIndex == 0 ? [b, b] : [a, a];
      return [a, b];
    }
    return _round(v as double);
  }

  bool _sameValue(Object? a, Object? b) {
    if (a is List<double> && b is List<double>) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    return a == b;
  }

  bool _sameOut(Object a, Object b) {
    if (a is List<double> && b is List<double>) {
      return a[0] == b[0] && a[1] == b[1];
    }
    return a == b;
  }

  /// The displayed value: the live drag value while dragging, else the
  /// controlled `value`, else the internal one.
  Object get _display => _dragging
      ? _stateValue
      : (widget.value != null ? _normalize(widget.value!) : _stateValue);

  double _valueOf(int index) {
    final v = _display;
    return widget.range ? (v as List<double>)[index] : v as double;
  }

  double _fracOf(double value) {
    if (_span == 0) return 0;
    return ((value - widget.min) / _span).clamp(0.0, 1.0);
  }

  /// Value fraction -> physical fraction along the rail (from the left/top
  /// edge): RTL horizontal and verticalReverse mirror it (foundation.ts
  /// `transValueToPos`).
  double _physFrac(double frac) {
    if (widget.vertical) return widget.verticalReverse ? 1 - frac : frac;
    return _isRtl ? 1 - frac : frac;
  }

  double _fracFromPhys(double phys) {
    if (widget.vertical) return widget.verticalReverse ? 1 - phys : phys;
    return _isRtl ? 1 - phys : phys;
  }

  /// Pixel coordinate of [value] along the value axis (rail length [len]).
  double _posOf(double value, double len) => _physFrac(_fracOf(value)) * len;

  double _axisPos(Offset global) {
    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    final local = box.globalToLocal(global);
    return widget.vertical ? local.dy : local.dx;
  }

  double _handleCenter(int index) => _posOf(_valueOf(index), _axisLen);

  // -- interactions ----------------------------------------------------------

  void _handleTapDown(int index, Offset position) {
    if (widget.disabled) return;
    // A press focuses the handle (the browser focuses the tabIndex=0 span)
    // and clears the keyboard gate (checkbox/rating onTapDown same).
    (index == 0 ? _minNode : _maxNode).requestFocus();
    if (_keyboardUsed) setState(() => _keyboardUsed = false);
    _dragOffset = _axisPos(position) - _handleCenter(index);
    setState(() {
      // Keep the live-follow buffer in sync with the display before dragging.
      _stateValue = widget.value != null
          ? _normalize(widget.value!)
          : _stateValue;
      _dragging = true;
      _dragIndex = index;
    });
  }

  void _handlePanUpdate(int index, Offset position) {
    if (widget.disabled) return;
    final len = _axisLen;
    if (len <= 0) return;
    final pos = _axisPos(position) - _dragOffset;
    final frac = _fracFromPhys(pos / len);
    final value = _finalize(frac * _span + widget.min);
    final Object out;
    if (widget.range) {
      final pair = (_display as List<double>).toList();
      pair[index] = value;
      out = _outPair(pair, index);
    } else {
      out = _round(value);
    }
    if (_sameOut(out, _outValueOf(_display))) return;
    // Live follow even when controlled (foundation.ts:552).
    setState(() => _stateValue = out);
    widget.onChanged?.call(out);
  }

  /// Upstream `onHandleUp` (foundation.ts:599-619): `onHandleUpBefore`
  /// (onMouseUp) then `onHandleUpAfter` (onAfterChange with the output value).
  void _handleSessionEnd() {
    if (!_dragging && _dragIndex == null) return;
    final out = _outValueOf(_stateValue);
    setState(() {
      _dragging = false;
      _dragIndex = null;
      // ★ foundation.ts:616 — `onHandleUp` unconditionally calls
      // `adapter.onHandleLeave()` (`focusPos: ''`): the hover state is cleared
      // at release even though mid-drag exits are suppressed (onHandleLeave
      // skips while isDrag). Without this, releasing outside the handle after
      // a drag leaves `_hoverIndex` set forever and the tooltip never closes.
      _hoverIndex = null;
    });
    widget.onMouseUp?.call();
    widget.onAfterChange?.call(out);
  }

  /// Upstream `handleWrapClick` (foundation.ts:788-813): jump the nearest
  /// handle; controlled only notifies and does not jump. The jump completion
  /// fires onAfterChange (uncontrolled).
  void _handleWrapTap(Offset global) {
    if (widget.disabled) return;
    if (_dragging || _dragIndex != null) return;
    final len = _axisLen;
    if (len <= 0) return;
    final frac = _fracFromPhys(_axisPos(global) / len);
    final value = _finalize(frac * _span + widget.min);
    final Object out;
    int moved = 0;
    if (widget.range) {
      final pair = (_display as List<double>).toList();
      // Nearest handle by distance (foundation.ts:829-844; the upstream
      // verticalReverse flip is not replicated — 差异清单).
      final d0 = (value - pair[0]).abs();
      final d1 = (value - pair[1]).abs();
      moved = d0 <= d1 ? 0 : 1;
      pair[moved] = value;
      out = _outPair(pair, moved);
    } else {
      out = _round(value);
    }
    if (_sameOut(out, _outValueOf(_display))) return;
    widget.onChanged?.call(out);
    if (widget.value == null) {
      setState(() => _stateValue = out);
      widget.onAfterChange?.call(out);
    }
  }

  void _handleEnter(int index) {
    if (widget.disabled) return;
    if (_hoverIndex != index) setState(() => _hoverIndex = index);
  }

  void _handleLeave(int index) {
    if (widget.disabled) return;
    // Upstream `onHandleLeave` (foundation.ts:590-597): stays while dragging.
    if (_dragging && _dragIndex == index) return;
    if (_hoverIndex == index) setState(() => _hoverIndex = null);
  }

  // -- keyboard --------------------------------------------------------------

  /// Upstream `_handleHomeKey` / `_handleEndKey` (foundation.ts:661-687) —
  /// Home/End are ★ NOT RTL-inverted; the 'min' End and 'max' Home forms
  /// collapse both handles.
  Object _homeEndValue(int index, {required bool home}) {
    if (!widget.range) return home ? widget.min : widget.max;
    final pair = (_display as List<double>).toList();
    if (home) {
      return index == 0
          ? <double>[widget.min, pair[1]]
          : <double>[pair[0], pair[0]];
    }
    return index == 0
        ? <double>[pair[1], pair[1]]
        : <double>[pair[0], widget.max];
  }

  /// Upstream `_handleValueIncreaseWithKeyBoard` /
  /// `_handleValueDecreaseWithKeyBoard` (foundation.ts:621-659): the range
  /// handles may meet but never cross (further presses are no-ops).
  Object _stepValue(int index, double delta) {
    if (!widget.range) return _clampV(_valueOf(0) + delta);
    final pair = (_display as List<double>).toList();
    if (index == 0) {
      var next = pair[0] + delta;
      next = next < widget.min
          ? widget.min
          : next > pair[1]
          ? pair[1]
          : next;
      return <double>[next, pair[1]];
    }
    var next = pair[1] + delta;
    next = next < pair[0]
        ? pair[0]
        : next > widget.max
        ? widget.max
        : next;
    return <double>[pair[0], next];
  }

  /// Upstream `handleKeyDown` / `onHandleUp` keyup gate (foundation.ts
  /// :599-602, :689-747): recognized keys step on KeyDown (diff-gated), and
  /// ★ KeyUp of a recognized key fires onMouseUp then onAfterChange;
  /// unrelated keys do nothing.
  KeyEventResult _handleKey(int index, KeyEvent event) {
    final key = event.logicalKey;
    final recognized = {
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.pageUp,
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.home,
      LogicalKeyboardKey.end,
    };
    if (!recognized.contains(key)) return KeyEventResult.ignored;
    if (event is KeyUpEvent) {
      widget.onMouseUp?.call();
      widget.onAfterChange?.call(_outValueOf(_display));
      return KeyEventResult.handled;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (widget.disabled) return KeyEventResult.ignored;
    final Object raw;
    if (key == LogicalKeyboardKey.home) {
      raw = _homeEndValue(index, home: true);
    } else if (key == LogicalKeyboardKey.end) {
      raw = _homeEndValue(index, home: false);
    } else {
      // ★ RTL (horizontal only) inverts the arrows and PageUp/PageDown.
      final bool increase;
      double amount = widget.step;
      if (key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowRight) {
        increase = !_isRtl;
      } else if (key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowLeft) {
        increase = _isRtl;
      } else if (key == LogicalKeyboardKey.pageUp) {
        increase = !_isRtl;
        amount = 10 * widget.step;
      } else {
        increase = _isRtl;
        amount = 10 * widget.step;
      }
      raw = _stepValue(index, increase ? amount : -amount);
    }
    final Object out;
    if (raw is List<double>) {
      out = _outPair(raw, index);
    } else {
      out = _round(raw as double);
    }
    // Diff gate: further presses at a clamp boundary are no-ops.
    if (_sameOut(out, _outValueOf(_display))) return KeyEventResult.handled;
    if (widget.value == null) {
      setState(() => _stateValue = out);
    }
    widget.onChanged?.call(out);
    return KeyEventResult.handled;
  }

  /// ★ Blur suppression (index.tsx:204-209 `notifyBlur`): focus moving
  /// between the two range handles stays inside the slider and is not a blur.
  void _handleFocusChange(int index, bool focused) {
    setState(() => _focusIndex = focused ? index : null);
    if (focused) return;
    scheduleMicrotask(() {
      if (!mounted) return;
      if (_minNode.hasFocus || _maxNode.hasFocus) return;
      widget.onBlur?.call();
    });
  }

  // -- tooltip ---------------------------------------------------------------

  bool _tipVisible(int index) {
    if (!widget.showTooltip) return false;
    if (widget.tooltipVisible == true) return true;
    if (widget.tooltipVisible == false) return false;
    // Hovering/dragging the handle, or keyboard-focused (focus-visible gate).
    return _hoverIndex == index ||
        _dragIndex == index ||
        (_focusIndex == index && _keyboardUsed);
  }

  Widget _asWidget(Object value) => value is Widget
      ? value
      : Text('$value', maxLines: 1, overflow: TextOverflow.ellipsis);

  Widget _tipContent(double value) {
    final rounded = _round(value);
    if (widget.tipFormatter == null) return Text('$rounded');
    final result = widget.tipFormatter!(rounded);
    if (result == null) return Text('$rounded');
    return _asWidget(result);
  }

  // -- build -----------------------------------------------------------------

  /// Upstream `cursor: pointer` on the clickable parts — `.semi-slider-rail`
  /// (slider.scss:37), `-handle` (58), `-track` (90), `-dot` (113), `-mark`
  /// (134) and `-mark-reverse` (151). Disabled defers to the wrapper's
  /// `not-allowed` (forbidden) cursor.
  MouseCursor get _tapCursor =>
      widget.disabled ? MouseCursor.defer : SystemMouseCursors.click;

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiSliderTheme.resolve(context);
    final vertical = widget.vertical;

    final body = MouseRegion(
      // Upstream `cursor: not-allowed` on `.semi-slider-disabled` only —
      // the enabled wrapper declares NO cursor (slider.scss has none on
      // `&-wrapper`/`&-marks`/`&-boundary`); the hand is scoped to the
      // interactive parts below, not the whole bounding rect.
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _wrapperHovered = true),
      onExit: (_) => setState(() => _wrapperHovered = false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = vertical
              ? t.heightSliderVerticalWrapper
              : (constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0);
          final h = vertical
              ? (constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0)
              : t.heightSliderWrapper;
          _axisLen = vertical ? h : w;
          final children = <Widget>[
            _buildRail(t, vertical),
            _buildTrack(t, w, h, vertical),
            ..._buildDots(t, w, h, vertical),
            ..._buildMarks(t, w, h, vertical),
            ..._buildHandles(t, w, h, vertical),
            if (widget.showBoundary && _wrapperHovered)
              _buildBoundary(t, global, w),
          ];
          return SizedBox(
            width: w,
            height: h,
            child: Stack(
              key: _stackKey,
              clipBehavior: Clip.none,
              children: children,
            ),
          );
        },
      ),
    );

    if (vertical) return body;
    // `.semi-slider` root — `padding: $spacing-slider-paddingY
    // $spacing-slider-paddingX; margin: $spacing-slider-margin;` (upstream
    // renders the padded root wrapper solely in horizontal mode).
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: t.spacingSliderPaddingY,
        horizontal: t.spacingSliderPaddingX,
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacingSliderMargin),
        child: body,
      ),
    );
  }

  Widget _buildRail(SemiResolvedSliderThemeData t, bool vertical) {
    final top = vertical
        ? t.spacingSliderVerticalRailTop
        : t.spacingSliderRailTop;
    // `.semi-slider-rail` — `margin: $spacing-slider_rail-margin;` (vertical
    // rail keeps `width: $height-slider_rail` = the 4px wrapper width).
    final margin = t.spacingSliderRailMargin;
    return Positioned(
      top: top + margin,
      left: margin,
      right: margin,
      height: vertical ? null : t.heightSliderRail,
      bottom: vertical ? margin : null,
      child: Padding(
        // `.semi-slider-rail` — `padding: $spacing-slider_rail-padding`.
        padding: EdgeInsets.all(t.spacingSliderRailPadding),
        child: MouseRegion(
          cursor: _tapCursor,
          child: GestureDetector(
            key: SemiSlider.railKey,
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _handleWrapTap(d.globalPosition),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.colorSliderRailBgDefault,
                borderRadius: BorderRadius.circular(t.radiusSliderRail),
              ),
              // `.semi-slider-rail` — `color: $color-slider_rail;
              // font-size: $font-slider_rail-fontSize; line-height:
              // $font-slider_rail-lineHeight;` (inherited text styling; the rail
              // renders no text of its own upstream either).
              child: DefaultTextStyle(
                style: TextStyle(
                  color: t.colorSliderRail,
                  fontSize: t.fontSliderRailFontSize,
                  height: t.fontSliderRailLineHeight,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrack(
    SemiResolvedSliderThemeData t,
    double w,
    double h,
    bool vertical,
  ) {
    final len = vertical ? h : w;
    // Single mode fills from the min end (RTL: from the right edge — the
    // `right: 0` of upstream renderTrack).
    final p0 = _posOf(_valueOf(0), len);
    final p1 = widget.range
        ? _posOf(_valueOf(1), len)
        : _posOf(widget.min, len);
    final start = p0 < p1 ? p0 : p1;
    // Upstream `trackStyle = included ? trackStyle : {}` — no fill extent.
    final fill = widget.included ? (p1 - p0).abs() : 0.0;
    return Positioned(
      top: vertical ? start : t.spacingSliderTrackTop,
      left: vertical ? null : start,
      width: vertical ? t.heightSliderTrack : fill,
      height: vertical ? fill : t.heightSliderTrack,
      child: MouseRegion(
        cursor: _tapCursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _handleWrapTap(d.globalPosition),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.disabled
                  ? t.colorSliderTrackDisabledBg
                  : t.colorSliderTrackBgDefault,
              borderRadius: BorderRadius.circular(t.radiusSliderTrack),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  /// ★ foundation.ts:401-413 `isMarkActive` included asymmetry: single +
  /// `included: false` -> dots always un-highlighted; range + `included:
  /// false` -> dots always highlighted. Out-of-range marks return false
  /// (hidden); both 'active' and 'unActive' render.
  bool _isMarkActive(double mark) {
    if (mark < widget.min || mark > widget.max) return false;
    if (widget.range) {
      final pair = _display as List<double>;
      final outside = mark > pair[1] || mark < pair[0];
      return !(outside && widget.included);
    }
    return mark <= _valueOf(0) && widget.included;
  }

  bool _markInRange(double mark) => mark >= widget.min && mark <= widget.max;

  List<Widget> _buildDots(
    SemiResolvedSliderThemeData t,
    double w,
    double h,
    bool vertical,
  ) {
    final marks = widget.marks;
    if (marks == null || marks.isEmpty) return const [];
    final len = vertical ? h : w;
    final size = t.widthSliderDot;
    // index.tsx:594 — `calc(${markPercent * 100}% - 2px)` (2 = half of the
    // 4px `width-slider_dot`).
    final nudge = _SliderMetrics.dotCenterNudge;
    final result = <Widget>[];
    for (final mark in marks.keys) {
      if (!_markInRange(mark)) continue;
      final active = _isMarkActive(mark);
      final pos = _posOf(mark, len) - nudge;
      Widget dot = MouseRegion(
        cursor: _tapCursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _handleWrapTap(d.globalPosition),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.disabled
                  ? t.colorSliderDotBgDefault
                  : active
                  ? t.colorSliderDotBorderActive
                  : t.colorSliderDotBgDefault,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
      if (widget.tooltipOnMark) {
        // Upstream wraps each dot in `<Tooltip content={marks[mark]}>`.
        dot = SemiTooltip(content: Text(marks[mark] ?? ''), child: dot);
      }
      result.add(
        Positioned(
          top: vertical ? pos : t.spacingSliderDotTop,
          left: vertical ? null : pos + t.spacingSliderDotTranslateX,
          child: Transform.translate(
            offset: Offset(
              0,
              vertical ? t.spacingSliderVerticalDotTranslateY : 0,
            ),
            child: dot,
          ),
        ),
      );
    }
    return result;
  }

  List<Widget> _buildMarks(
    SemiResolvedSliderThemeData t,
    double w,
    double h,
    bool vertical,
  ) {
    final marks = widget.marks;
    if (!widget.showMarkLabel || marks == null || marks.isEmpty) {
      return const [];
    }
    final len = vertical ? h : w;
    // Vertical labels shift by the marks container margins (`top:
    // $spacing-slider_marks-top` + `margin-top:
    // $spacing-slider_vertical_marks-marginTop`, net -7 == -fontSize/2 so the
    // label centers on the dot); `verticalReverse` moves them to the left
    // side (`margin-left: $spacing-slider_vertical_marks-reverse-marginLeft`)
    // and keeps them upright (upstream `-mark-reverse`).
    final topBase = vertical
        ? t.spacingSliderMarksTop + t.spacingSliderVerticalMarksMarginTop
        : t.spacingSliderMarksTop;
    final sideBase = vertical
        ? (widget.verticalReverse
              ? t.spacingSliderVerticalMarksReverseMarginLeft
              : t.spacingSliderVerticalMarksMarginLeft)
        : t.spacingSliderMarksLeft;
    final result = <Widget>[];
    for (final entry in marks.entries) {
      final mark = entry.key;
      if (!_markInRange(mark)) continue;
      final anchorX = vertical ? sideBase : _posOf(mark, len) + sideBase;
      final anchorY = vertical ? _posOf(mark, len) + topBase : topBase;
      result.add(
        Positioned(
          left: anchorX,
          top: anchorY,
          // `transform: translate(-50%, 0)` — the label centers on its anchor
          // (FractionalTranslation hit-tests through the transform).
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: MouseRegion(
              cursor: _tapCursor,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _handleWrapTap(d.globalPosition),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: t.colorSliderMarkTextDefault,
                    fontSize: t.fontSliderMarksFontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return result;
  }

  List<Widget> _buildHandles(
    SemiResolvedSliderThemeData t,
    double w,
    double h,
    bool vertical,
  ) {
    final count = widget.range ? 2 : 1;
    final handles = <Widget>[
      for (var i = 0; i < count; i++) _buildHandle(t, i, w, h, vertical),
    ];
    // index.tsx:374 — `zIndex: chooseMovePos === 'min' && isDrag ? 2 : 1`
    // (_SliderMetrics.handleZIndex): the dragged handle paints last (on top).
    if (count == 2 && _dragIndex == 0) {
      return [handles[1], handles[0]];
    }
    return handles;
  }

  Widget _buildHandle(
    SemiResolvedSliderThemeData t,
    int index,
    double w,
    double h,
    bool vertical,
  ) {
    final size = t.widthSliderHandle;
    final len = vertical ? h : w;
    final pos = _posOf(_valueOf(index), len) - size / 2;
    final top = vertical
        ? pos + t.spacingSliderVerticalHandleMarginTop
        : t.spacingSliderHandleMarginTop + t.spacingSliderHandleTranslateY;
    final left = vertical
        ? t.spacingSliderVerticalHandleMarginLeft +
              t.spacingSliderVerticalHandleTranslateX
        : pos;
    final pressed = _dragIndex == index;
    final showFocus = _focusIndex == index && _keyboardUsed && !widget.disabled;
    final hovered = _hoverIndex == index;

    final border = widget.disabled
        ? Border.all(
            width: t.widthSliderHandleBorderDisabled,
            color: t.colorSliderHandleDisabledBorder,
          )
        : pressed
        ? Border.all(
            // `.semi-slider-handle-clicked` — `border: solid
            // $width-slider_handle_clicked $color-slider_handle-border-focus`.
            width: t.widthSliderHandleClicked,
            color: t.colorSliderHandleBorderFocus,
          )
        : null;
    final color = widget.disabled
        ? (hovered
              ? t.colorSliderHandleDisabledBorderHover
              : t.colorSliderHandleBgDefault)
        : hovered
        ? t.colorSliderHandleBgHover
        : t.colorSliderHandleBgDefault;
    final shadows = <BoxShadow>[
      // The keyboard focus ring (rating `_keyboardUsed` precedent) —
      // `outline: $width-slider_handle-focus solid $color-slider_handle-focus`.
      if (showFocus)
        BoxShadow(
          color: t.colorSliderHandleFocus,
          spreadRadius: t.widthSliderHandleFocus,
        ),
      if (!widget.disabled) ..._SliderMetrics.shadowKnob,
    ];

    final dot = _handleDotFor(t, index);
    // Raw pointer listeners (upstream `mousemove`/`mouseup` on document.body
    // after `mousedown` on the handle): no gesture-arena slop, the drag
    // starts on the press and follows every move.
    Widget handle = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _handleTapDown(index, e.position),
      onPointerMove: (e) {
        if (e.down) _handlePanUpdate(index, e.position);
      },
      onPointerUp: (_) => _handleSessionEnd(),
      onPointerCancel: (_) => _handleSessionEnd(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border,
          boxShadow: widget.disabled
              ? _SliderMetrics.shadowZero
              : (shadows.isEmpty ? null : shadows),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: dot == null ? null : Center(child: dot),
        ),
      ),
    );
    handle = MouseRegion(
      // `.semi-slider-handle` — `cursor: pointer` (slider.scss:58); pressed
      // is `-handle-clicked` — `cursor: grabbing` (82). Disabled defers to
      // the wrapper's `not-allowed`.
      cursor: widget.disabled
          ? MouseCursor.defer
          : _dragIndex == index
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.click,
      onEnter: (_) => _handleEnter(index),
      onExit: (_) => _handleLeave(index),
      child: handle,
    );
    handle = Semantics(
      container: true,
      slider: true,
      enabled: !widget.disabled,
      value: _ariaValue(index),
      child: handle,
    );
    handle = Focus(
      focusNode: index == 0 ? _minNode : _maxNode,
      canRequestFocus: !widget.disabled,
      onFocusChange: (focused) => _handleFocusChange(index, focused),
      onKeyEvent: (node, event) => _handleKey(index, event),
      child: handle,
    );
    handle = SemiTooltip(
      content: _tipContent(_valueOf(index)),
      trigger: SemiTooltipTrigger.custom,
      visible: _tipVisible(index),
      showArrow: widget.showArrow,
      position: SemiTooltipPosition.top,
      repositionKey: _fracOf(_valueOf(index)),
      child: handle,
    );
    return Positioned(
      key: SemiSlider.handleKey(index),
      left: left,
      top: top,
      width: size,
      height: size,
      child: handle,
    );
  }

  /// The handle-dot (`&-handle-dot`) renders ONLY when `handleDot` is
  /// provided (index.tsx:411-414); size/color default to
  /// `$width-slider_handle_dot` / `$color-slider_handle_dot`.
  Widget? _handleDotFor(SemiResolvedSliderThemeData t, int index) {
    final spec = widget.handleDot;
    if (spec == null) return null;
    final SemiSliderHandleDot resolved;
    if (spec is SemiSliderHandleDot) {
      resolved = spec;
    } else {
      resolved = (spec as List<SemiSliderHandleDot>)[index];
    }
    return Container(
      width: resolved.size ?? t.widthSliderHandleDot,
      height: resolved.size ?? t.widthSliderHandleDot,
      decoration: BoxDecoration(
        color: resolved.color ?? t.colorSliderHandleDot,
        shape: BoxShape.circle,
      ),
    );
  }

  String _ariaValue(int index) {
    final value = _valueOf(index);
    if (widget.getAriaValueText != null) {
      return widget.getAriaValueText!(value, index);
    }
    return '$value';
  }

  Widget _buildBoundary(
    SemiResolvedSliderThemeData t,
    SemiThemeData global,
    double w,
  ) {
    // slider.scss:157 `-boundary` — `font-size: $font-size-small` (12px ==
    // theme.typography.fontSizeSmall); `color: $color-slider-text-default`.
    final style = TextStyle(
      color: t.colorSliderTextDefault,
      fontSize: global.typography.fontSizeSmall,
    );
    // rtl.scss mirrors the labels: min on the right, max on the left.
    final minAtStart = !_isRtl;
    return Positioned(
      top: t.spacingSliderBoundaryTop,
      left: 0,
      width: w,
      height: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: minAtStart ? t.spacingSliderBoundaryMinLeft : null,
            right: minAtStart ? null : t.spacingSliderBoundaryMinLeft,
            child: Text('${widget.min}', style: style),
          ),
          Positioned(
            top: 0,
            right: minAtStart ? t.spacingSliderBoundaryMaxRight : null,
            left: minAtStart ? null : t.spacingSliderBoundaryMaxRight,
            child: Text('${widget.max}', style: style),
          ),
        ],
      ),
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_slider.py for the
/// 61 = 57 themed + 3 motion + 1 INTERNAL accounting; the hardcodes below are
/// the 另列 entries.
abstract final class _SliderMetrics {
  /// Upstream `$transform_scale-slider_handle: var(--semi-transform_scale-small)`
  /// (packages/semi-foundation/slider/animation.scss) is `scale(1,1)` — no
  /// transform is applied (slider.scss consumes `$transform_scale-slider_handle`
  /// in the handle transform; semi-theme-default/scss/animation.scss:29).
  // ignore: unused_field
  static const double transformScaleSliderHandle = 1;

  /// mixin.scss:14 `@mixin shadow-knob` on `.semi-slider-handle`:
  /// `box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 0 1px rgba(0, 0, 0, 0.3);`
  static const List<BoxShadow> shadowKnob = [
    BoxShadow(color: Color(0x1a000000), offset: Offset(0, 4), blurRadius: 6),
    BoxShadow(color: Color(0x4d000000), blurRadius: 1),
  ];

  /// mixin.scss:8 `@mixin shadow-0` on the disabled handle:
  /// `box-shadow: none;`
  static const List<BoxShadow> shadowZero = <BoxShadow>[];

  /// index.tsx:594 mark dot centering — `calc(${markPercent * 100}% - 2px)`
  /// (2 = half of the 4px `width-slider_dot`).
  static const double dotCenterNudge = 2;

  /// index.tsx:374 handle stacking —
  /// `zIndex: chooseMovePos === 'min' && isDrag ? 2 : 1` (the dragged handle
  /// paints on top).
  // ignore: unused_field
  static const int handleZIndex = 2;
}
