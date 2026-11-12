import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_input_number_theme.dart';
import '../theme/semi_input_number_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_input.dart';

/// A source-sized, non-Material numeric stepper input (upstream Semi
/// InputNumber) built on [SemiInput].
///
/// The display text lives in this widget's own state machine (upstream
/// `value`/`number` dual state in
/// packages/semi-foundation/inputNumber/foundation.ts): [SemiInput] is only
/// the editing shell (`value: null` + this widget's controller), exactly the
/// [SemiAutoComplete] composition. `value != null` makes the input controlled
/// (the project-wide convention): edits and steps only emit callbacks and the
/// display follows [value] formatted while not focusing (upstream
/// `componentDidUpdate`), while the focusing state keeps the intermediate
/// input text alive.
///
/// Port notes (see docs/semi_input_number.md for the full difference list):
/// * [onChanged] reports the display text of every edit/step; the numeric
///   channel is split into [onNumberChange] (valid numbers only).
/// * [min]/[max] are nullable (upstream `±Infinity`); [pressTimeout]/
///   [pressInterval] are [Duration]s.
/// * `currency`/locale formatting is deferred (needs Intl); use
///   [formatter]/[parser] instead. `onKeyDown` and mouse-wheel stepping are
///   not ported (upstream has no wheel either).
class SemiInputNumber extends StatefulWidget {
  const SemiInputNumber({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.onNumberChange,
    this.onUpClick,
    this.onDownClick,
    this.onClear,
    this.step = 1,
    this.shiftStep = 10,
    this.min,
    this.max,
    this.precision,
    this.formatter,
    this.parser,
    this.scientificNotation = false,
    this.disabled = false,
    this.readonly = false,
    this.borderless = false,
    this.hideButtons = false,
    this.innerButtons = false,
    this.keepFocus = false,
    this.pressTimeout = const Duration(milliseconds: 250),
    this.pressInterval = const Duration(milliseconds: 250),
    this.size = SemiInputSize.normal,
    this.showClear = false,
    this.clearIcon,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.insetLabel,
    this.validateStatus = SemiInputStatus.normal,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.semanticsLabel,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  /// Key of the stepper button box (outer and inner forms).
  static const Key stepperKey = Key('SemiInputNumber.stepper');

  /// Key of the up button.
  static const Key upButtonKey = Key('SemiInputNumber.upButton');

  /// Key of the down button.
  static const Key downButtonKey = Key('SemiInputNumber.downButton');

  /// Non-null makes the input controlled (the SemiInput convention): the
  /// display follows this number formatted and edits/steps only emit
  /// callbacks (upstream `value`).
  final num? value;

  /// Seed of the uncontrolled number state (upstream `defaultValue`); an
  /// external [controller] with text wins over it (and asserts against it).
  final num? initialValue;

  /// Fires on every edit/step/clear with the new display text (upstream
  /// `onChange`, narrowed to the display string — see docs/semi_input_number.md).
  final ValueChanged<String>? onChanged;

  /// Fires only when a valid in-range number changes (upstream
  /// `onNumberChange`).
  final ValueChanged<num>? onNumberChange;

  /// Fires after an up-button/keyboard step with the new display text
  /// (upstream `onUpClick`).
  final ValueChanged<String>? onUpClick;

  /// Fires after a down-button/keyboard step with the new display text
  /// (upstream `onDownClick`).
  final ValueChanged<String>? onDownClick;

  /// Fires after a clear tap (following `onChanged('')`).
  final VoidCallback? onClear;

  /// Step of one click/arrow (upstream `step`, `DEFAULT_STEP: 1`).
  final num step;

  /// Step while Shift is held (upstream `shiftStep`, `DEFAULT_SHIFT_STEP: 10`).
  final num shiftStep;

  /// Lower bound; null is unbounded (upstream `-Infinity`).
  final num? min;

  /// Upper bound; null is unbounded (upstream `Infinity`).
  final num? max;

  /// Fixed fraction digits; blur/init round with 四舍五入
  /// (half away from zero, see docs/semi_input_number.md).
  final int? precision;

  /// Display formatter (upstream `formatter`), applied after precision
  /// adjustment/scientific notation.
  final String Function(String)? formatter;

  /// Input parser (upstream `parser`), applied before numeric parsing.
  final String Function(String)? parser;

  /// Displays long numbers in scientific notation (threshold fixed at 15
  /// significant digits, `Default threshold: 15 digits` in foundation.ts);
  /// expands to the full number on focus (upstream `scientificNotation`).
  final bool scientificNotation;

  final bool disabled;
  final bool readonly;
  final bool borderless;

  /// Hides the outer stepper; `innerButtons` still shows its suffix stepper on
  /// hover/focus (upstream `renderSuffix`/`renderButtons`).
  final bool hideButtons;

  /// Renders the stepper as [SemiInput.suffix] while hovering or focused and
  /// the user [suffix] otherwise (upstream `innerButtons`).
  final bool innerButtons;

  /// Re-requests focus after button presses (upstream `keepFocus`).
  final bool keepFocus;

  /// Delay before press-and-hold starts repeating (upstream `pressTimeout`).
  final Duration pressTimeout;

  /// Interval of press-and-hold repeats (upstream `pressInterval`).
  final Duration pressInterval;

  final SemiInputSize size;

  /// Shows the clear button while hovering or focused with non-empty text.
  final bool showClear;

  /// Custom clear icon (defaults to `SemiIcons.clear`).
  final Widget? clearIcon;

  final String? placeholder;

  /// String or Widget, passed through to [SemiInput] (upstream `prefix`).
  final Object? prefix;

  /// String or Widget, passed through to [SemiInput] (upstream `suffix`); the
  /// inner stepper swaps with it on hover/focus.
  final Object? suffix;

  /// String or Widget, passed through to [SemiInput] (upstream `insetLabel`).
  final Object? insetLabel;

  final SemiInputStatus validateStatus;

  /// Focuses the input on mount (upstream `autofocus`).
  final bool autofocus;

  /// External controller hosting the display text; never disposed by the
  /// widget.
  final TextEditingController? controller;

  /// External focus node; never disposed by the widget.
  final FocusNode? focusNode;

  final String? semanticsLabel;

  @override
  State<SemiInputNumber> createState() => _SemiInputNumberState();
}

class _SemiInputNumberState extends State<SemiInputNumber> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  /// The parsed number backing the display (upstream `number`).
  num? _number;

  /// Upstream `focusing` — the input-intermediate state.
  bool _focusing = false;

  /// Upstream `hovering` — the whole wrapper hover (drives the inner stepper
  /// and the borderless idle opacity).
  bool _hovering = false;

  /// Upstream `clickUpOrDown` — the last interaction was a step.
  bool _clickUpOrDown = false;

  /// Pressed stepper half (`:active`), null when idle.
  bool? _pressedUp;

  /// Hovered stepper half (`:hover`), null when idle.
  bool? _hoveredUp;

  Timer? _pressTimer;
  Timer? _pressInterval;

  // Cursor bookkeeping (upstream `recordCursorPosition`/`restoreCursor`).
  int _cursorStart = 0;
  String _cursorAfter = '';

  bool get _isControlled => widget.value != null;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_handleTextTick);
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode(debugLabel: 'SemiInputNumber');
      _ownsFocusNode = true;
    }
    // Upstream constructor: `focusing: Boolean(props.autofocus)`.
    _focusing = widget.autofocus;
    _initFromProps();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  /// Upstream `_getInitState` + `_setInitValue`: the seed (controlled [value],
  /// else [initialValue], else the external controller text) is formatted,
  /// parsed back with clamp + precision and displayed formatted; an invalid
  /// seed displays empty. A display string differing from the seed notifies
  /// `onChanged` (upstream `_setInitValue` notify, deferred past the first
  /// build).
  void _initFromProps() {
    final seed =
        widget.value ??
        widget.initialValue ??
        (widget.controller != null && widget.controller!.text.isNotEmpty
            ? widget.controller!.text
            : null);
    if (seed == null) {
      _number = null;
      _setDisplay('');
      return;
    }
    // Upstream `_getInitState`: numbers are formatted first, strings pass raw.
    final valueStr = seed is num ? _doFormat(seed) : seed as String;
    final parsedNum = _doParse(
      valueStr,
      needCheckPrec: false,
      needAdjustPrec: true,
      needAdjustMaxMin: true,
    );
    final number = _isValidNumber(parsedNum) ? parsedNum : null;
    final formatted = number != null ? _doFormat(number, true, true) : '';
    _number = number;
    _setDisplay(formatted);
    final seedText = seed is num ? _jsNumStr(seed) : seed as String;
    if (formatted != seedText) {
      // Number state was already seeded — upstream `notifyNumberChange`
      // compares against the constructor state and stays silent here.
      final baseline = _number;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _notifyChange(formatted, _toNumber(formatted, true), baseline);
      });
    }
  }

  @override
  void didUpdateWidget(SemiInputNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleTextTick);
      if (_ownsController) _controller.dispose();
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController(text: _controller.text);
        _ownsController = true;
      }
      _controller.addListener(_handleTextTick);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      } else {
        _focusNode = FocusNode(debugLabel: 'SemiInputNumber');
        _ownsFocusNode = true;
      }
    }
    final a = oldWidget.value;
    final b = widget.value;
    final bothNaN = (a?.isNaN ?? false) && (b?.isNaN ?? false);
    if ((a != b || (bothNaN && a != null)) && !bothNaN) {
      _syncFromValue();
    }
  }

  /// Upstream `componentDidUpdate` value branch: non-focusing displays the
  /// formatted value (empty when invalid); focusing keeps the input
  /// intermediate state (only the number tracks valid values, and only a
  /// step-driven value reformats the display).
  void _syncFromValue() {
    final baseline = _number;
    String? newValue;
    final value = widget.value;
    if (value == null) {
      newValue = '';
      _number = null;
      _setDisplay('');
    } else {
      final valueStr = _doFormat(value);
      final parsedNum = _doParse(
        valueStr,
        needCheckPrec: false,
        needAdjustPrec: true,
        needAdjustMaxMin: true,
      );
      if (_focusing) {
        if (_isValidNumber(parsedNum) && parsedNum != _number) {
          _number = parsedNum;
          if (_clickUpOrDown) {
            newValue = _doFormat(_number, true);
            _setDisplay(newValue, restoreCursor: true);
          }
        } else if (!value.isNaN) {
          newValue = _doFormat(value, false);
          _setDisplay(newValue);
        } else {
          newValue = valueStr;
          _setDisplay(newValue);
        }
      } else if (_isValidNumber(parsedNum)) {
        _number = parsedNum;
        newValue = _doFormat(parsedNum, true, true);
        _setDisplay(newValue);
      } else {
        newValue = '';
        _number = null;
        _setDisplay('');
      }
    }
    if (newValue != null &&
        newValue.isNotEmpty &&
        newValue != _jsNumStr(value ?? 0)) {
      _notifyChange(newValue, _toNumber(newValue, true), baseline);
    }
  }

  @override
  void dispose() {
    _stopPress();
    _controller.removeListener(_handleTextTick);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleTextTick() {
    if (mounted) setState(() {});
  }

  // -- display text helpers --------------------------------------------------

  void _recordCursorPosition() {
    final selection = _controller.selection;
    if (selection.isValid && selection.start >= 0) {
      _cursorStart = selection.start;
      _cursorAfter = _controller.text.substring(selection.end);
    } else {
      _cursorStart = _controller.text.length;
      _cursorAfter = '';
    }
  }

  /// Upstream `restoreCursor`/`restoreByAfter`: find the recorded suffix back
  /// in the new text and put the caret before it; the port falls back to the
  /// recorded offset (clamped) so a step keeps the caret position.
  void _restoreCursor() {
    final text = _controller.text;
    for (var start = 0; start < _cursorAfter.length; start++) {
      final part = _cursorAfter.substring(start);
      final index = text.lastIndexOf(part);
      if (index != -1 && index + part.length == text.length) {
        _controller.selection = TextSelection.collapsed(offset: index);
        return;
      }
    }
    _controller.selection = TextSelection.collapsed(
      offset: _cursorStart.clamp(0, text.length),
    );
  }

  void _setDisplay(String text, {bool restoreCursor = false}) {
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (restoreCursor) _restoreCursor();
  }

  /// Upstream `notifyChange`/`notifyNumberChange`, narrowed to the port's
  /// channels: `onChanged` fires with the display text whenever upstream
  /// fires `onChange`; `onNumberChange` fires only for valid numbers that
  /// differ from [numberBefore] (the pre-operation number — React state stays
  /// stale inside one handler).
  void _notifyChange(String display, num? candidate, num? numberBefore) {
    widget.onChanged?.call(display);
    if (candidate != null &&
        _isValidNumber(candidate) &&
        candidate != numberBefore) {
      widget.onNumberChange?.call(candidate);
    }
  }

  // -- numeric core (foundation.ts) ------------------------------------------

  /// JS `Number.prototype.toString` on the shortest round-trip form (Dart
  /// suffixes integral doubles with `.0`; JS does not).
  static String _jsNumStr(num n) {
    final s = n.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// JS `Math.round` (ties toward +∞) — upstream `utils/number.ts` math.
  static double _jsRound(double x) => (x + 0.5).floorToDouble();

  /// Upstream `utils/number.ts` `plus`: float-error-free addition.
  static double _numPlus(double a, double b) {
    final base = math
        .pow(10, math.max(_precLenOf(a), _precLenOf(b)))
        .toDouble();
    return _jsRound(a * base + b * base) / base;
  }

  /// Upstream `utils/number.ts` `minus`.
  static double _numMinus(double a, double b) => _numPlus(a, -b);

  static int _precLenOf(num n) {
    if (!n.isFinite || n == 0) return 0;
    final s = _jsNumStr(n.abs());
    if (RegExp(r'[eE]').hasMatch(s)) {
      final parts = s.split(RegExp(r'[eE]'));
      final mantissaDecimals = parts[0].contains('.')
          ? parts[0].split('.')[1].length
          : 0;
      return math.max(0, mantissaDecimals - int.parse(parts[1]));
    }
    return s.contains('.') ? s.length - s.indexOf('.') - 1 : 0;
  }

  /// Upstream `_getPrecLen` — decimal length of a number or numeric string.
  int _getPrecLen(Object? value) {
    if (value is! String) {
      final n = value as num? ?? 0;
      return _precLenOf(n);
    }
    final idx = value.indexOf('.') + 1;
    return idx != 0 ? value.length - idx : 0;
  }

  /// JS `ToNumber` (the lodash `toNumber` string path): strict parse with
  /// trimmed whitespace; `''` maps to 0 like `+''`.
  static num? _jsToNumber(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return 0;
    final n = double.tryParse(v);
    if (n == null || n.isNaN) return null;
    return n;
  }

  /// JS `parseFloat` — lenient leading-number extraction
  /// (`"1000CNY" -> 1000`); null when no leading number.
  static num? _floatParse(String raw) {
    final match = RegExp(r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?')
        .firstMatch(raw.trimLeft());
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  /// 四舍五入 — rounds the decimal representation half away from zero (JS
  /// `toFixed` rounds the binary value instead; see docs/semi_input_number.md).
  static String _toFixed(num value, int fractionDigits) {
    if (!value.isFinite) return value.toString();
    var text = _jsNumStr(value);
    var exp = 0;
    final eIndex = text.indexOf('e');
    if (eIndex >= 0) {
      exp = int.parse(text.substring(eIndex + 1));
      text = text.substring(0, eIndex);
    }
    var negative = false;
    if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }
    final parts = text.split('.');
    var digits = parts[0] + (parts.length > 1 ? parts[1] : '');
    var point = parts[0].length + exp;
    var cut = point + fractionDigits;
    if (cut < 0) {
      digits = '0';
      point = 0;
    } else if (cut > digits.length) {
      digits = digits.padRight(cut, '0');
    } else {
      final rest = digits.substring(cut);
      digits = digits.substring(0, cut);
      if (rest.isNotEmpty && rest.codeUnitAt(0) >= 0x35 /* '5' */ ) {
        final chars = digits.split('').map(int.parse).toList();
        var i = chars.length - 1;
        while (i >= 0) {
          if (chars[i] < 9) {
            chars[i] += 1;
            break;
          }
          chars[i] = 0;
          i -= 1;
        }
        var rounded = chars.join();
        if (i < 0) {
          rounded = '1$rounded';
          point += 1;
        }
        digits = rounded;
      }
    }
    if (cut < 0 && fractionDigits > 0) {
      // Rounds to zero: `0.00...` with the requested fraction digits.
      digits = '0';
    }
    if (int.tryParse(digits) == 0) negative = false;
    final buf = StringBuffer(negative ? '-' : '');
    if (point <= 0) {
      buf.write('0');
    } else {
      buf.write(digits.substring(0, math.min(point, digits.length)));
    }
    var fraction = point < 0
        ? '0' * math.min(-point, fractionDigits)
        : digits.substring(math.min(point, digits.length));
    fraction = fraction.padRight(fractionDigits, '0');
    if (fraction.isNotEmpty) {
      buf
        ..write('.')
        ..write(fraction);
    }
    return buf.toString();
  }

  /// Upstream `_adjustPrec`: `Number(value).toFixed(precision)` when a
  /// precision is set and the value is numeric, else the plain string.
  String _adjustPrec(Object? value) {
    final precision = widget.precision;
    if (precision != null && value != null && value != '') {
      final n = value is num ? value : _jsToNumber(value as String);
      if (n != null && n.isFinite) return _toFixed(n, precision);
    }
    return value == null
        ? ''
        : (value is String ? value : _jsNumStr(value as num));
  }

  /// Upstream `doFormat(value, needAdjustPrec, needAdjustCurrency)` minus the
  /// currency branch: precision adjustment, optional scientific notation
  /// (the blur/init paths), then the user formatter.
  String _doFormat(
    Object? value, [
    bool needAdjustPrec = true,
    bool needAdjustScientific = false,
  ]) {
    String str = needAdjustPrec
        ? _adjustPrec(value)
        : (value == null
              ? ''
              : (value is String ? value : _jsNumStr(value as num)));
    if (widget.scientificNotation && needAdjustScientific) {
      final numValue = value is num ? value : _floatParse(str);
      if (numValue != null && numValue.isFinite) {
        str = _toScientificNotation(numValue);
      }
    }
    if (widget.formatter != null) str = widget.formatter!(str);
    return str;
  }

  /// Upstream `_toScientificNotation` (threshold `_getScientificNotationThreshold`).
  String _toScientificNotation(num n) {
    const threshold = _InputNumberMetrics.scientificNotationThreshold;
    final absNum = n.abs();
    final numStr = _jsNumStr(absNum);
    final hasExp = RegExp(r'[eE]').hasMatch(numStr);
    final significantDigits = numStr
        .replaceAll(RegExp(r'[.\-+eE]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if ((hasExp || significantDigits.length >= threshold) && absNum != 0) {
      final fractionDigits = math.max(0, math.min(100, threshold - 1));
      final exp = absNum == 0 ? '0' : n.toStringAsExponential(fractionDigits);
      return exp
          .replaceAllMapped(RegExp(r'(\.\d*?)0+e'), (m) => '${m[1]}e')
          .replaceFirst(RegExp(r'\.e'), 'e');
    }
    return _jsNumStr(n);
  }

  /// Upstream `afterParser` — the parser output as string.
  String _afterParser(String value) =>
      widget.parser != null ? widget.parser!(value) : value;

  /// Upstream `foundation.toNumber` (parser + precision adjust + parse).
  num? _toNumber(Object? value, [bool needAdjustPrec = true]) {
    if (value is num) return value.isNaN ? null : value;
    var v = value as String;
    if (widget.parser != null) v = widget.parser!(v);
    if (needAdjustPrec) v = _adjustPrec(v);
    return _jsToNumber(v);
  }

  /// Upstream `doParse` — parser, scientific-literal support, precision
  /// legality check (`needCheckPrec`), optional toFixed + clamp.
  num? _doParse(
    Object? value, {
    bool needCheckPrec = true,
    bool needAdjustPrec = false,
    bool needAdjustMaxMin = false,
  }) {
    if (value is num) {
      var v = value;
      if (v.isNaN) return null;
      if (needAdjustPrec) {
        final adjusted = _jsToNumber(_adjustPrec(v));
        if (adjusted == null) return null;
        v = adjusted;
      }
      return needAdjustMaxMin ? _fetchMinOrMax(v) : v;
    }
    var str = value as String;
    if (widget.parser != null) str = widget.parser!(str);
    if (RegExp(r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)[eE][+-]?\d+$')
        .hasMatch(str.trim())) {
      final scientificNum = double.tryParse(str.trim());
      if (scientificNum != null && !scientificNum.isNaN) {
        if (needAdjustMaxMin) return _fetchMinOrMax(scientificNum);
        if (needAdjustPrec) return _jsToNumber(_adjustPrec(scientificNum));
        return scientificNum;
      }
    }
    if (needCheckPrec) {
      final zeroIsValid =
          !str.contains('.') ||
          (str == '0' || str.lastIndexOf('0') < str.length - 1);
      final dotIsValid =
          str.lastIndexOf('.') < str.length - 1 &&
          '.'.allMatches(str).length < 2;
      if (!zeroIsValid || !dotIsValid) return null;
    }
    if (needAdjustPrec) str = _adjustPrec(str);
    if (str.isEmpty) return null;
    final n = _jsToNumber(str);
    if (n == null) return null;
    return needAdjustMaxMin ? _fetchMinOrMax(n) : n;
  }

  /// Upstream `fetchMinOrMax` with nullable bounds.
  num _fetchMinOrMax(num current) {
    final min = widget.min;
    final max = widget.max;
    if (min != null && current < min) return min;
    if (max != null && current > max) return max;
    return current;
  }

  /// Upstream `isValidNumber` with nullable bounds.
  bool _isValidNumber(num? value, {bool needCheckPrec = true}) {
    if (value == null || value.isNaN) return false;
    final precision = widget.precision;
    final precIsValid =
        !needCheckPrec || precision == null || _getPrecLen(value) <= precision;
    return (widget.min == null || value >= widget.min!) &&
        (widget.max == null || value <= widget.max!) &&
        precIsValid;
  }

  // -- edits -----------------------------------------------------------------

  /// Upstream `handleInputChange` — the dual-state edit path: valid inputs
  /// format, in-between fragments (`"-"`, `"1."`, `"1.0"`) stay alive without
  /// clamping, empty clears the number. Controlled edits only land the
  /// display; uncontrolled edits also land the number.
  void _handleInputChanged(String v) {
    if (widget.disabled || widget.readonly) return;
    final baseline = _number;
    _recordCursorPosition();
    final parsedNum = _doParse(
      v,
      needCheckPrec: true,
      needAdjustPrec: true,
      needAdjustMaxMin: true,
    );
    final toNum = _doParse(
      v,
      needCheckPrec: false,
      needAdjustPrec: false,
      needAdjustMaxMin: false,
    );
    final valueAfterParser = _afterParser(v);

    String formattedNum = v;
    String notifyText;
    num? candidate;
    if (v == '') {
      // Upstream empty branch; the port also clears the controlled number so
      // the clear chain resets the value (see docs/semi_input_number.md).
      _number = null;
      notifyText = '';
    } else if (_isValidNumber(toNum) && _isValidNumber(parsedNum)) {
      formattedNum = _doFormat(toNum, false);
      notifyText = formattedNum;
      candidate = toNum;
    } else {
      if (toNum != null) {
        // Parsed but out of range/precision: keep the typed digits alive
        // (upstream L213-230 dot/padding repair).
        formattedNum = _doFormat(toNum, false);
        final dotIndex = valueAfterParser.lastIndexOf('.');
        final lengthAfterDot = valueAfterParser.length - 1 - dotIndex;
        final precLength = _getPrecLen(toNum);
        if (precLength == 0) {
          final dotBeginStr = dotIndex > -1
              ? valueAfterParser.substring(dotIndex)
              : '';
          formattedNum += dotBeginStr;
        } else if (precLength < lengthAfterDot) {
          formattedNum += '0' * (lengthAfterDot - precLength);
        }
      } else {
        formattedNum = _doFormat(valueAfterParser, false);
      }
      notifyText = formattedNum;
      candidate = _toNumber(_isControlled ? formattedNum : valueAfterParser);
    }

    if (!_isControlled && v != '' && toNum != null) {
      _number = toNum;
    }

    // Upstream `setValue`: controlled keeps `formattedNum`, uncontrolled
    // keeps the parser/formatter-round-tripped raw text.
    _setDisplay(
      _isControlled ? formattedNum : _doFormat(valueAfterParser, false),
      restoreCursor: true,
    );
    _notifyChange(notifyText, candidate, baseline);
  }

  /// Upstream `handleInputBlur` — normalize on blur: parse + clamp + toFixed,
  /// extract a leading number from garbage (`"1000CNY" -> 1000`), fall back to
  /// the old value formatting when nothing parses.
  void _handleBlur() {
    final baseline = _number;
    final currentValue = _controller.text;
    var currentNumber = _number;
    if (currentNumber != null || currentValue.isNotEmpty) {
      final parsedNum = _doParse(
        currentValue,
        needCheckPrec: false,
        needAdjustPrec: true,
        needAdjustMaxMin: true,
      );
      var numHasChanged = false;
      var strHasChanged = false;
      num? willSetNum;
      String? willSetVal;

      if (_isValidNumber(parsedNum) && parsedNum != currentNumber) {
        willSetNum = parsedNum;
        if (!_isControlled) currentNumber = willSetNum;
        numHasChanged = true;
      }

      if (!_isValidNumber(parsedNum)) {
        // Upstream issue #38: extract a number from "1000CNY"-style input.
        final extracted = _floatParse(currentValue);
        if (extracted != null) {
          final limited = _fetchMinOrMax(extracted);
          if (limited != currentNumber) {
            willSetNum = limited;
            if (!_isControlled) currentNumber = willSetNum;
            numHasChanged = true;
          }
        } else if (currentNumber != null && !currentNumber.isNaN) {
          final limited = _fetchMinOrMax(currentNumber);
          if (limited != currentNumber) {
            willSetNum = limited;
            if (!_isControlled) currentNumber = willSetNum;
            numHasChanged = true;
          }
        }
      }

      final currentFormattedNum = _doFormat(currentNumber, true, true);
      if (currentFormattedNum != currentValue) {
        willSetVal = currentFormattedNum;
        strHasChanged = true;
      }

      if (strHasChanged || numHasChanged) {
        if (willSetVal != null) _setDisplay(willSetVal);
        if (willSetNum != null && !_isControlled) _number = willSetNum;
        final display = willSetVal ?? currentValue;
        // Upstream `notifyVal = willSetVal ?? willSetNum`.
        final notifyVal = willSetVal ?? willSetNum;
        final candidate = notifyVal is num
            ? notifyVal
            : (notifyVal != null ? _toNumber(notifyVal, true) : null);
        _notifyChange(display, candidate, baseline);
      }
    }
    _focusing = false;
  }

  /// Upstream `handleInputFocus` — expand scientific notation to the full
  /// number while editing.
  void _handleFocusChange(bool focused) {
    if (focused) {
      final value = _controller.text;
      if (value.isNotEmpty && widget.scientificNotation) {
        final isScientificStr =
            RegExp(r'[eE]').hasMatch(value) &&
            RegExp(r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)[eE][+-]?\d+$')
                .hasMatch(value.trim());
        if (isScientificStr) {
          final parsedNum = _doParse(
            value,
            needCheckPrec: false,
            needAdjustPrec: false,
            needAdjustMaxMin: false,
          );
          if (_isValidNumber(parsedNum)) {
            _setDisplay(_doFormat(parsedNum, true, false));
          }
        }
      }
      _recordCursorPosition();
      _focusing = true;
      _clickUpOrDown = false;
    } else {
      _handleBlur();
    }
    setState(() {});
  }

  // -- stepping --------------------------------------------------------------

  /// Upstream `add`/`minus`: float-safe accumulation gated by
  /// `|bound - current| >= |step|`, then clamped to `[min, max]`, returned as
  /// the formatted display text (no scientific notation while editing).
  String _stepDisplay({required bool up, required bool shift}) {
    final propStep = shift ? widget.shiftStep : widget.step;
    final step = (up ? propStep : -propStep).toDouble();
    final stepAbs = step.abs();
    var curNum = _number?.toDouble() ?? 0.0;
    final min = widget.min?.toDouble();
    final max = widget.max?.toDouble();
    final scale = math
        .pow(
          10,
          [
            _getPrecLen(min),
            _getPrecLen(max),
            _getPrecLen(curNum),
            _getPrecLen(step),
          ].reduce(math.max),
        )
        .toDouble();
    if (step < 0) {
      if (_numMinus(min ?? -double.infinity, curNum).abs() >= stepAbs) {
        curNum = _jsRound(curNum * scale + step * scale) / scale;
      }
    } else if (step > 0) {
      if (_numMinus(max ?? double.infinity, curNum).abs() >= stepAbs) {
        curNum = _jsRound(curNum * scale + step * scale) / scale;
      }
    }
    if (min != null && min > curNum) curNum = min;
    if (max != null && max < curNum) curNum = max;
    return _doFormat(curNum, true, false);
  }

  /// Upstream `upClick`/`downClick` + `_doInput`: step, land (uncontrolled),
  /// notify `onUpClick`/`onDownClick` with the new display text (button
  /// presses only — keyboard steps skip that channel upstream).
  void _stepOnce({
    required bool up,
    bool restoreCursor = false,
    bool notifyClick = false,
  }) {
    final baseline = _number;
    _clickUpOrDown = true;
    if (restoreCursor) _recordCursorPosition();
    final display = _stepDisplay(
      up: up,
      shift: HardwareKeyboard.instance.isShiftPressed,
    );
    final number = _doParse(display, needCheckPrec: false);
    if (number != null && !_isControlled) _number = number;
    if (!_isControlled) _setDisplay(display);
    if (widget.keepFocus) {
      _focusing = true;
      _clickUpOrDown = true;
    }
    _notifyChange(display, number, baseline);
    if (notifyClick) {
      if (up) {
        widget.onUpClick?.call(display);
      } else {
        widget.onDownClick?.call(display);
      }
    }
    if (restoreCursor) _restoreCursor();
    setState(() {});
  }

  /// Upstream `renderButtons` boundary check — strict `number === max/min`
  /// equality (not `>=`), and the nullable bound must exist (upstream
  /// `null === Infinity` is never allowed to match).
  bool _notAllowed(bool up) => up
      ? (widget.max != null && _number == widget.max)
      : (widget.min != null && _number == widget.min);

  /// Upstream `handleUpClick`/`handleDownClick`: left button only, silent on
  /// disabled/readonly and on the strict `number == max/min` not-allowed
  /// boundary; steps once, then repeats after `pressTimeout` every
  /// `pressInterval` until release/leave/dispose.
  void _handleButtonDown({required bool up, required PointerDownEvent event}) {
    if (widget.disabled || widget.readonly) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons & kPrimaryMouseButton == 0) {
      return;
    }
    if (_notAllowed(up)) return;
    _stepOnce(up: up, notifyClick: true);
    // Upstream `_preventDefault`: keepFocus/innerButtons keep the input
    // focused after a press.
    if (widget.keepFocus || widget.innerButtons) _focusNode.requestFocus();
    _stopPress();
    setState(() => _pressedUp = up);
    _pressTimer = Timer(widget.pressTimeout, () {
      _pressInterval = Timer.periodic(widget.pressInterval, (_) {
        _stepOnce(up: up, notifyClick: true);
      });
    });
  }

  void _stopPress() {
    _pressTimer?.cancel();
    _pressTimer = null;
    _pressInterval?.cancel();
    _pressInterval = null;
    if (_pressedUp != null && mounted) setState(() => _pressedUp = null);
  }

  /// Upstream `handleInputKeyDown`: ArrowUp/ArrowDown step (KeyRepeat
  /// repeats), Shift picks `shiftStep`, the caret is preserved; Enter rides
  /// `SemiInput.onEnterPress`, left/right arrows and Tab propagate.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final isDown = event is KeyDownEvent;
    if (!isDown && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      if (widget.disabled || widget.readonly) return KeyEventResult.ignored;
      _stepOnce(up: key == LogicalKeyboardKey.arrowUp, restoreCursor: true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // -- build -----------------------------------------------------------------

  /// Upstream `renderButtons`: the two-halves stepper box.
  Widget _buildStepper(
    SemiResolvedInputNumberThemeData t, {
    required bool inner,
  }) {
    final double height = switch (widget.size) {
      SemiInputSize.small =>
        inner
            ? t.heightInputNumberButtonInnerSmall
            : t.heightInputNumberButtonSmall,
      SemiInputSize.normal =>
        inner
            ? t.heightInputNumberButtonInnerDefault
            : t.heightInputNumberButtonDefault,
      SemiInputSize.large =>
        inner
            ? t.heightInputNumberButtonInnerLarge
            : t.heightInputNumberButtonLarge,
    };
    // `-suffix-btns-inner-hover`: the inner box swaps its border while the
    // wrapper hovers unfocused.
    final borderColor = inner && _hovering && !_focusing
        ? t.colorInputNumberButtonBorderHover
        : t.colorInputNumberButtonBorderDefault;
    return Container(
      key: SemiInputNumber.stepperKey,
      width: t.widthInputNumberButton,
      height: height,
      decoration: BoxDecoration(
        color: t.colorInputNumberButtonBgDefault,
        border: Border.all(
          width: t.widthInputNumberButtonBorder,
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(
          inner ? t.radiusInputNumberInner : t.radiusInputNumber,
        ),
      ),
      // `overflow: hidden` on `-suffix-btns-inner`.
      clipBehavior: inner ? Clip.antiAlias : Clip.none,
      child: Column(
        children: [
          Expanded(child: _buildButton(t, up: true)),
          Expanded(child: _buildButton(t, up: false)),
        ],
      ),
    );
  }

  Widget _buildButton(SemiResolvedInputNumberThemeData t, {required bool up}) {
    final disabled = widget.disabled;
    final notAllowed = _notAllowed(up);
    final inert = disabled || notAllowed;
    final pressed = !inert && _pressedUp == up;
    final hovered = !inert && _hoveredUp == up;
    final Color bg;
    if (disabled) {
      bg = t.colorInputNumberButtonBgDisabled;
    } else if (pressed) {
      // `&-button-up/down:not(.-not-allowed):active`.
      bg = t.colorInputNumberButtonBgActive;
    } else if (hovered) {
      // `&-button-up/down:not(.-not-allowed):hover`.
      bg = t.colorInputNumberButtonBgHover;
    } else {
      // Not-allowed keeps the default look: the container paints
      // `$color-inputNumber_button-bg-default` and the button stays
      // transparent; only `cursor: not-allowed` marks it.
      bg = const Color(0x00000000);
    }
    final iconColor = disabled
        ? t.colorInputNumberButtonTextDisabled
        : t.colorInputNumberButtonTextDefault;
    Widget button = ColoredBox(
      color: bg,
      child: Center(
        child: SemiIcon(
          up ? SemiIcons.chevronUp : SemiIcons.chevronDown,
          size: _InputNumberMetrics.stepperIconSize,
          color: iconColor,
        ),
      ),
    );
    return MouseRegion(
      cursor: inert ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredUp = up),
      onExit: (_) {
        setState(() => _hoveredUp = null);
        // Releasing outside the button still stops the repeat chain.
        if (_pressedUp == up) _stopPress();
      },
      child: Listener(
        key: up ? SemiInputNumber.upButtonKey : SemiInputNumber.downButtonKey,
        behavior: HitTestBehavior.opaque,
        onPointerDown: inert
            ? null
            : (event) => _handleButtonDown(up: up, event: event),
        onPointerUp: (_) => _stopPress(),
        onPointerCancel: (_) => _stopPress(),
        child: button,
      ),
    );
  }

  Widget _buildInput(SemiResolvedInputNumberThemeData t) {
    final inner = widget.innerButtons;
    final showInnerStepper = inner && (_hovering || _focusing);
    // `.semi-input-clearbtn + .semi-input-suffix` margin rule
    // (`$spacing-inputNumber_clearbtn_suffix-marginLeft`).
    final clearVisible =
        widget.showClear &&
        !widget.disabled &&
        !widget.readonly &&
        _controller.text.isNotEmpty &&
        (_hovering || _focusing);
    final double margin;
    if (inner) {
      margin = showInnerStepper && clearVisible
          ? t.spacingInputNumberClearbtnSuffixMarginLeft
          : t.spacingInputNumberButtonInnerMarginLeft;
    } else {
      margin = t.spacingInputNumberButtonMarginLeft;
    }
    final stepper = _buildStepper(t, inner: inner);
    Object? suffixSlot = widget.suffix;
    if (showInnerStepper) {
      final padded = margin == 0
          ? stepper
          : margin > 0
          ? Padding(
              padding: EdgeInsetsDirectional.only(start: margin),
              child: stepper,
            )
          : Transform.translate(
              offset: Offset(
                Directionality.of(context) == TextDirection.ltr
                    ? margin
                    : -margin,
                0,
              ),
              child: stepper,
            );
      suffixSlot = padded;
    }
    return SemiInput(
      controller: _controller,
      focusNode: _focusNode,
      value: null,
      size: widget.size,
      validateStatus: widget.validateStatus,
      disabled: widget.disabled,
      readonly: widget.readonly,
      borderless: widget.borderless,
      placeholder: widget.placeholder,
      prefix: widget.prefix,
      suffix: suffixSlot,
      insetLabel: widget.insetLabel,
      showClear: widget.showClear,
      clearIcon: widget.clearIcon,
      onChanged: _handleInputChanged,
      onFocusChange: _handleFocusChange,
      onClear: widget.onClear,
      semanticsLabel: widget.semanticsLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiInputNumberTheme.resolve(context);
    final inner = widget.innerButtons;
    final outerStepper = !widget.hideButtons && !inner;

    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final input = _buildInput(t);
        if (!outerStepper) return input;
        // `borderless` idle hides the outer stepper (inputNumber.scss
        // `:not(:focus-within):not(:hover)` opacity rule).
        final stepper = Opacity(
          opacity: widget.borderless && !_hovering && !_focusing
              ? _InputNumberMetrics.borderlessHiddenOpacity
              : 1,
          child: _buildStepper(t, inner: false),
        );
        final gap = SizedBox(width: t.spacingInputNumberButtonMarginLeft);
        final children = <Widget>[
          if (constraints.hasBoundedWidth) Expanded(child: input) else input,
          gap,
          stepper,
        ];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );
      },
    );

    body = MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: body,
    );

    body = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: body,
    );

    final valueText = _number != null ? _jsNumStr(_number!) : '';
    return Semantics(
      container: true,
      enabled: !widget.disabled,
      // `role="spinbutton"` with `aria-valuenow/min/max/step`.
      value: valueText,
      increasedValue: valueText.isEmpty
          ? ''
          : _stepDisplay(up: true, shift: false),
      decreasedValue: valueText.isEmpty
          ? ''
          : _stepDisplay(up: false, shift: false),
      onIncrease: widget.disabled || widget.readonly
          ? null
          : () => _stepOnce(up: true),
      onDecrease: widget.disabled || widget.readonly
          ? null
          : () => _stepOnce(up: false),
      child: body,
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_input_number.py for the 28 = 21 FIELDS + 6
/// MOTION + 1 INTERNAL accounting; the hardcodes below are the 另列 entries.
abstract final class _InputNumberMetrics {
  /// Upstream `$transform_scale-inputNumber: var(--semi-transform_scale-none)`
  /// (packages/semi-foundation/inputNumber/animation.scss) is `scale(1)` — no
  /// transform is applied.
  // ignore: unused_field
  static const double transformScaleInputNumber = 1;

  /// `IconChevronUp/IconChevronDown size="extra-small"` in
  /// packages/semi-ui/inputNumber/index.tsx (`renderButtons`) — the stepper
  /// chevrons render at the semi-icons extra-small size (8px, see
  /// docs/semi_icon.md).
  static const SemiIconSize stepperIconSize = SemiIconSize.extraSmall;

  /// `DEFAULT_PRESS_TIMEOUT: 250` in
  /// packages/semi-foundation/inputNumber/constants.ts — default of both
  /// [SemiInputNumber.pressTimeout] and [SemiInputNumber.pressInterval]
  /// (upstream `defaultProps` sets both from `DEFAULT_PRESS_TIMEOUT`).
  // ignore: unused_field
  static const int pressTimeoutDefault = 250;

  /// `DEFAULT_STEP: 1` in packages/semi-foundation/inputNumber/constants.ts —
  /// default of [SemiInputNumber.step].
  // ignore: unused_field
  static const num stepDefault = 1;

  /// `DEFAULT_SHIFT_STEP: 10` in
  /// packages/semi-foundation/inputNumber/constants.ts — default of
  /// [SemiInputNumber.shiftStep].
  // ignore: unused_field
  static const num shiftStepDefault = 10;

  /// `MOUSE_BUTTON_LEFT: 0` in
  /// packages/semi-foundation/inputNumber/constants.ts — the DOM button index
  /// of the left mouse button; the port checks `kPrimaryMouseButton` on the
  /// Flutter pointer instead.
  // ignore: unused_field
  static const int mouseButtonLeft = 0;

  /// `return 15; // Default threshold: 15 digits` in
  /// packages/semi-foundation/inputNumber/foundation.ts
  /// (`_getScientificNotationThreshold`) — significant-digit threshold of
  /// [SemiInputNumber.scientificNotation].
  static const int scientificNotationThreshold = 15;

  /// inputNumber.scss `&-suffix-btns > .#{$module}-button` — `height: 50%`
  /// (each stepper half is half the button box).
  // ignore: unused_field
  static const String buttonSplitHeight = 'height: 50%';

  /// inputNumber.scss `&-suffix-btns-inner` — `overflow: hidden` (clipped by
  /// the inner box `Clip.antiAlias`).
  // ignore: unused_field
  static const String innerButtonsOverflow = 'overflow: hidden';

  /// inputNumber.scss `&-button-up-not-allowed/&-button-down-not-allowed` —
  /// `cursor: not-allowed` (the port paints `SystemMouseCursors.forbidden`).
  // ignore: unused_field
  static const String notAllowedCursor = 'cursor: not-allowed';

  /// inputNumber.scss `:not(:focus-within):not(:hover) .semi-input-borderless
  /// + .-suffix-btns` — `opacity: 0` on the idle borderless stepper.
  static const double borderlessHiddenOpacity = 0;
}
