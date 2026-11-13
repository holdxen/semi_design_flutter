import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_input_theme.dart';
import '../theme/semi_input_theme_data.dart';
import '../theme/semi_pincode_theme.dart';
import '../theme/semi_pincode_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'semi_input.dart';

/// Character class accepted by [SemiPinCode.format] (upstream `"number" |
/// "mixed"`).
enum SemiPinCodeFormat {
  /// Digits only (`numberReg = /^\d*$/` in
  /// packages/semi-foundation/pincode/foundation.ts).
  number,

  /// One alphanumerical character (`mixedReg = /^[0-9a-zA-Z]$/` in
  /// packages/semi-foundation/pincode/foundation.ts).
  mixed,
}

/// Imperative handle for the individual cells (upstream ref methods
/// `focus`/`blur` in packages/semi-ui/pincode/index.tsx). Attach/detach is
/// maintained by the [SemiPinCode] state; both methods are no-ops while
/// detached.
class SemiPinCodeController {
  _SemiPinCodeState? _state;

  /// Focuses the cell at [index] and puts the caret at the end of its text
  /// (upstream `focus`: `inputDOM.focus(); inputDOM.setSelectionRange(1, 1)`).
  void focus(int index) {
    _state?._focusCell(index);
  }

  /// Blurs the cell at [index] (upstream `blur`).
  void blur(int index) {
    _state?._blurCell(index);
  }

  void _attach(_SemiPinCodeState state) {
    _state = state;
  }

  void _detach(_SemiPinCodeState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// A source-sized, non-Material verification-code input (upstream Semi
/// PinCode): a row of single-character cells driven by
/// packages/semi-foundation/pincode/foundation.ts.
///
/// The value model is a `List<String>` of single characters internally
/// (upstream `valueList`) exchanged as one joined string over [onChanged] /
/// [onComplete]. `value != null` makes the component controlled (the
/// project-wide convention): edits only emit callbacks and the display
/// follows [value] character by character until the parent updates it
/// (upstream `value`, verified by the upstream test suite).
///
/// Port notes (see docs/semi_pincode.md for the full difference list):
/// * [format] is the upstream union `"number" | "mixed" | RegExp | ((value:
///   string) => boolean)` carried as `Object` ([SemiPinCodeFormat],
///   [RegExp] or `bool Function(String)`).
/// * Upstream paste (`onPaste`) has no Flutter event counterpart: a
///   multi-character inserted delta on one cell's text is distributed cell by
///   cell, character by character.
/// * `id`/`tabIndex`/`aria-*` are not ported; [controller] takes the place of
///   the upstream ref.
class SemiPinCode extends StatefulWidget {
  const SemiPinCode({
    super.key,
    this.value,
    this.initialValue,
    this.count = 6,
    this.format = SemiPinCodeFormat.number,
    this.onChanged,
    this.onComplete,
    this.disabled = false,
    this.autoFocus = true,
    this.size = SemiInputSize.normal,
    this.validateStatus = SemiInputStatus.normal,
    this.onBlur,
    this.controller,
  }) : assert(
         format is SemiPinCodeFormat ||
             format is RegExp ||
             format is bool Function(String),
         'format must be a SemiPinCodeFormat, a RegExp or a bool Function(String).',
       );

  /// Key of the rendered cell box at [index].
  static Key cellKey(int index) => Key('SemiPinCode.cell$index');

  /// Non-null makes the component controlled (the project-wide convention):
  /// the display follows this string character by character and edits only
  /// emit callbacks (upstream `value`).
  final String? value;

  /// Seed of the uncontrolled value state (upstream `defaultValue`).
  final String? initialValue;

  /// Number of cells (upstream `count`, `count: 6` in
  /// packages/semi-ui/pincode/index.tsx `defaultProps`).
  final int count;

  /// Accepted characters (upstream `format`): a [SemiPinCodeFormat], a
  /// [RegExp] or a `bool Function(String)` invoked per character.
  final Object format;

  /// Fires on every single-cell write/delete with the full value —
  /// `valueList.join('')`, empty slots erased (upstream `onChange`).
  final ValueChanged<String>? onChanged;

  /// Fires once when the last cell is written (upstream `onComplete`); a
  /// delete + refill fires it again (upstream has no re-entry guard).
  final ValueChanged<String>? onComplete;

  final bool disabled;

  /// Focuses cell 0 on mount (upstream `autoFocus`, defaulted to `true` in
  /// `defaultProps`).
  final bool autoFocus;

  final SemiInputSize size;

  final SemiInputStatus validateStatus;

  /// Fires when focus leaves the whole component (upstream wrapper `onBlur`
  /// with an outside `relatedTarget`); moving between cells never fires it.
  final VoidCallback? onBlur;

  /// Imperative cell handle (upstream ref `focus`/`blur`); never disposed by
  /// the widget.
  final SemiPinCodeController? controller;

  @override
  State<SemiPinCode> createState() => _SemiPinCodeState();
}

class _SemiPinCodeState extends State<SemiPinCode> {
  late List<TextEditingController> _cellControllers;
  late List<FocusNode> _focusNodes;

  /// Last text each cell displays — the baseline the incoming IME deltas are
  /// diffed against (the port's paste/single-input discrimination).
  late List<String> _baseline;

  /// Upstream `valueList` state — one character per cell, empty slots ''.
  late List<String> _valueList;

  /// Upstream `currentActiveIndex` — updated when a cell gains focus only.
  // ignore: unused_field
  int _activeIndex = 0;

  bool _blurCheckPending = false;

  bool get _isControlled => widget.value != null;

  @override
  void initState() {
    super.initState();
    _valueList = _seedList();
    _initCells(widget.count);
    widget.controller?._attach(this);
    // Upstream renders `autoFocus && index === 0` on the first cell.
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.disabled) _focusCell(0);
      });
    }
  }

  /// Upstream constructor state: `(value || defaultValue).split('')` — the
  /// port lets a non-null [SemiPinCode.value] win even when empty (the
  /// project-wide controlled convention).
  List<String> _seedList() =>
      (widget.value ?? widget.initialValue ?? '').split('');

  void _initCells(int count) {
    _cellControllers = List.generate(count, (i) {
      final text = i < _valueList.length ? _valueList[i] : '';
      return TextEditingController.fromValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
    });
    _baseline = List.generate(
      count,
      (i) => i < _valueList.length ? _valueList[i] : '',
    );
    _focusNodes = List.generate(count, (i) {
      final node = FocusNode(debugLabel: 'SemiPinCode[$i]');
      node.addListener(() => _handleFocusTick(i));
      return node;
    });
  }

  @override
  void didUpdateWidget(SemiPinCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (widget.value != oldWidget.value) {
      // Upstream `componentDidUpdate`: the state list mirrors `value`.
      _valueList = (widget.value ?? '').split('');
      _syncCells();
    }
    if (widget.count != oldWidget.count) {
      _disposeCells();
      _initCells(widget.count);
      _syncCells();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _disposeCells();
    super.dispose();
  }

  void _disposeCells() {
    for (final controller in _cellControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
  }

  void _handleFocusTick(int i) {
    if (!mounted) return;
    final node = _focusNodes[i];
    if (node.hasFocus) {
      // Upstream `handleCurrentActiveIndexChange` focus branch.
      setState(() => _activeIndex = i);
    } else {
      _scheduleBlurCheck();
      setState(() {});
    }
  }

  /// Upstream wrapper `handleBlur` (`relatedTarget` outside the component):
  /// one frame after a cell loses focus, fire [SemiPinCode.onBlur] only when
  /// every cell is unfocused — cell-to-cell moves stay silent.
  void _scheduleBlurCheck() {
    if (_blurCheckPending) return;
    _blurCheckPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _blurCheckPending = false;
      if (!mounted) return;
      if (_focusNodes.every((node) => !node.hasFocus)) {
        widget.onBlur?.call();
      }
    });
  }

  // -- cell display ----------------------------------------------------------

  void _setCellText(int i, String text) {
    if (i < 0 || i >= _cellControllers.length) return;
    final controller = _cellControllers[i];
    if (controller.text != text) {
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    _baseline[i] = text;
  }

  /// Rewrites every cell display from `_valueList` — the controlled display
  /// contract (`value` wins until the parent updates it) and the paste
  /// "防原始 delta 残留" rewrite.
  void _syncCells() {
    for (var i = 0; i < _cellControllers.length; i++) {
      _setCellText(i, i < _valueList.length ? _valueList[i] : '');
    }
  }

  // -- value core (foundation.ts) -------------------------------------------

  /// Upstream `validateValue` (foundation.ts:64-79): the enum classes accept
  /// empty strings, [RegExp] is a bare `hasMatch` (no empty short-circuit —
  /// 空串不放行), functions run per character.
  bool _validateValue(String value) {
    final format = widget.format;
    if (format is SemiPinCodeFormat) {
      if (format == SemiPinCodeFormat.number) {
        return value.isEmpty || _PinCodeMetrics.numberReg.hasMatch(value);
      }
      return value.isEmpty || _PinCodeMetrics.mixedReg.hasMatch(value);
    }
    if (format is RegExp) return format.hasMatch(value);
    return (format as bool Function(String))(value);
  }

  /// Upstream `completeSingleInput`: write the character, notify the join,
  /// land it only when uncontrolled, then blur + `onComplete` on the last cell
  /// or focus the next one.
  void _completeSingleInput(int i, String singleInputValue) {
    final valueList = [..._valueList];
    while (valueList.length <= i) {
      valueList.add('');
    }
    valueList[i] = singleInputValue;
    widget.onChanged?.call(valueList.join(''));
    if (!_isControlled) {
      _valueList = valueList;
    }
    if (i + 1 > widget.count - 1) {
      _blurAll();
      widget.onComplete?.call(valueList.join(''));
    } else {
      _focusCell(i + 1);
    }
  }

  /// Backspace/Delete value path (foundation.ts `handleKeyDownOnSingleInput`):
  /// clear the cell, notify the join (land first when uncontrolled), keep the
  /// displays in step.
  void _clearSingleCell(int i) {
    final valueList = [..._valueList];
    while (valueList.length <= i) {
      valueList.add('');
    }
    valueList[i] = '';
    if (!_isControlled) {
      _valueList = valueList;
    }
    widget.onChanged?.call(valueList.join(''));
    _syncCells();
  }

  void _focusCell(int i) {
    if (i < 0 || i >= _focusNodes.length) return;
    _focusNodes[i].requestFocus();
    final controller = _cellControllers[i];
    // Upstream `focus`: `setSelectionRange(1, 1)` — caret at the end.
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  void _blurCell(int i) {
    if (i < 0 || i >= _focusNodes.length) return;
    _focusNodes[i].unfocus();
  }

  void _blurAll() {
    for (final node in _focusNodes) {
      node.unfocus();
    }
  }

  // -- per-cell text input ---------------------------------------------------

  /// The insert portion of `old -> text` (longest common prefix/suffix
  /// trimmed) — the port's paste vs single-input discriminator.
  static String _insertedDelta(String old, String text) {
    var prefix = 0;
    while (prefix < old.length &&
        prefix < text.length &&
        old[prefix] == text[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < old.length - prefix &&
        suffix < text.length - prefix &&
        old[old.length - 1 - suffix] == text[text.length - 1 - suffix]) {
      suffix++;
    }
    return text.substring(prefix, text.length - suffix);
  }

  /// Every cell's `onChanged` (upstream per-input `onChange`, index.tsx:135):
  /// IME composition deltas are ignored, a one-character insert writes the
  /// text's last character (`v[v.length - 1]`, overwrite semantics), a
  /// multi-character insert is distributed like a paste (foundation.ts
  /// `handlePaste`: validate per character, break on the first invalid one,
  /// every write runs `completeSingleInput`). Empty deltas never land —
  /// deletion rides the Backspace/Delete keys.
  void _handleCellChanged(int i, String text) {
    if (widget.disabled) return;
    final composing = _cellControllers[i].value.composing;
    // Upstream `isComposing` guard (index.tsx:136-141): nothing lands while
    // an IME composition is in progress.
    if (composing.isValid && !composing.isCollapsed) return;
    final old = _baseline[i];
    if (text == old) return;
    final inserted = _insertedDelta(old, text);
    if (inserted.isEmpty) {
      _syncCells();
      return;
    }
    if (inserted.length == 1) {
      final char = text[text.length - 1];
      if (!_validateValue(char)) {
        // Silent ignore — restore the cell display (upstream keeps the
        // controlled `value`/state text).
        _syncCells();
        return;
      }
      _completeSingleInput(i, char);
      _syncCells();
      return;
    }
    // Paste branch (upstream `handlePaste`, distributing from cell i).
    final last = math.min(widget.count - 1, i + inserted.length);
    for (
      var idx = i, c = 0;
      idx < widget.count && c < inserted.length;
      idx++, c++
    ) {
      if (!_validateValue(inserted[c])) break;
      _completeSingleInput(idx, inserted[c]);
    }
    for (var k = i; k <= last; k++) {
      _setCellText(k, k < _valueList.length ? _valueList[k] : '');
    }
  }

  // -- keyboard --------------------------------------------------------------

  /// Outer wrapper keys (foundation.ts `handleKeyDownOnSingleInput`, mapped to
  /// the focused cell): Backspace clears + steps back (clamped at 0), Delete
  /// clears + steps forward (clamped at count-1), ArrowLeft/ArrowRight only
  /// move focus. Enter/Tab/Escape and character keys propagate; repeats act
  /// nothing.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.disabled) return KeyEventResult.ignored;
    final index = _focusNodes.indexWhere((cell) => cell.hasPrimaryFocus);
    if (index < 0) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      _clearSingleCell(index);
      _focusCell(math.max(0, index - 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete) {
      _clearSingleCell(index);
      _focusCell(math.min(widget.count - 1, index + 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _focusCell(math.max(0, index - 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _focusCell(math.min(widget.count - 1, index + 1));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // -- build -----------------------------------------------------------------

  /// Upstream wrapper size class -> cell gap (`$spacing-pinCode_*-marginRight`,
  /// `&:last-child { margin-right: 0 }`).
  double _cellGap(SemiResolvedPinCodeThemeData pin) => switch (widget.size) {
    SemiInputSize.small => pin.spacingPinCodeSmallMarginRight,
    SemiInputSize.normal => pin.spacingPinCodeDefaultMarginRight,
    SemiInputSize.large => pin.spacingPinCodeLargeMarginRight,
  };

  @override
  Widget build(BuildContext context) {
    final pin = SemiPinCodeTheme.resolve(context);
    final gap = _cellGap(pin);
    Widget body = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < widget.count; i++)
          Padding(
            // `&:last-child { margin-right: 0px; }` (pincode.scss:15-17).
            padding: EdgeInsetsDirectional.only(
              end: i == widget.count - 1 ? 0 : gap,
            ),
            child: _PinCodeCell(
              index: i,
              controller: _cellControllers[i],
              focusNode: _focusNodes[i],
              focused: _focusNodes[i].hasFocus,
              disabled: widget.disabled,
              size: widget.size,
              validateStatus: widget.validateStatus,
              numberKeyboard: widget.format == SemiPinCodeFormat.number,
              onChanged: (text) => _handleCellChanged(i, text),
            ),
          ),
      ],
    );
    body = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: body,
    );
    return body;
  }
}

/// One single-character cell: upstream renders a full [SemiInput] per cell
/// (implicit input.scss dependency), so the box reuses the SemiInput wrapper
/// tokens while the geometry comes from the PinCode theme.
class _PinCodeCell extends StatefulWidget {
  const _PinCodeCell({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.disabled,
    required this.size,
    required this.validateStatus,
    required this.numberKeyboard,
    required this.onChanged,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool disabled;
  final SemiInputSize size;
  final SemiInputStatus validateStatus;
  final bool numberKeyboard;
  final ValueChanged<String> onChanged;

  @override
  State<_PinCodeCell> createState() => _PinCodeCellState();
}

class _PinCodeCellState extends State<_PinCodeCell> {
  bool _hovering = false;

  double _width(SemiResolvedPinCodeThemeData pin) => switch (widget.size) {
    SemiInputSize.small => pin.widthPinCodeInputSmall,
    SemiInputSize.normal => pin.widthPinCodeInputDefault,
    SemiInputSize.large => pin.widthPinCodeInputLarge,
  };

  double _height(SemiResolvedInputThemeData input) => switch (widget.size) {
    SemiInputSize.small => input.heightInputWrapperSmall,
    SemiInputSize.normal => input.heightInputWrapperDefault,
    SemiInputSize.large => input.heightInputWrapperLarge,
  };

  /// The input-wrapper box rules (input.scss:34-53, 85-111) mapped onto the
  /// SemiInput theme fields — disabled, error/warning, focus, hover, default.
  (Color, Color) _resolveDecoration(SemiResolvedInputThemeData input) {
    if (widget.disabled) {
      return (
        input.colorInputDisabledBgDefault,
        input.colorInputDefaultBorderDefault,
      );
    }
    final status = widget.validateStatus;
    if (status == SemiInputStatus.error) {
      if (widget.focused) {
        return (
          input.colorInputDangerBgFocus,
          input.colorInputDangerBorderFocus,
        );
      }
      if (_hovering) {
        return (
          input.colorInputDangerBgHover,
          input.colorInputDangerBorderHover,
        );
      }
      return (
        input.colorInputDangerBgDefault,
        input.colorInputDangerBorderDefault,
      );
    }
    if (status == SemiInputStatus.warning) {
      if (widget.focused) {
        return (
          input.colorInputWarningBgFocus,
          input.colorInputWarningBorderFocus,
        );
      }
      if (_hovering) {
        return (
          input.colorInputWarningBgHover,
          input.colorInputWarningBorderHover,
        );
      }
      return (
        input.colorInputWarningBgDefault,
        input.colorInputWarningBorderDefault,
      );
    }
    if (widget.focused) {
      return (
        input.colorInputDefaultBgFocus,
        input.colorInputDefaultBorderFocus,
      );
    }
    if (_hovering) {
      return (
        input.colorInputDefaultBgHover,
        input.colorInputDefaultBorderHover,
      );
    }
    return (
      input.colorInputDefaultBgDefault,
      input.colorInputDefaultBorderDefault,
    );
  }

  /// `font-size-regular` for small/default and `font-size-header-6` for large
  /// (input.scss:46-55) — 14/14/16.
  double _fontSize(SemiThemeData global) => widget.size == SemiInputSize.large
      ? global.typography.fontSizeHeading6
      : global.typography.fontSizeRegular;

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final input = SemiInputTheme.resolve(context);
    final pin = SemiPinCodeTheme.resolve(context);
    final fontSize = _fontSize(global);
    final (bg, borderColor) = _resolveDecoration(input);
    final borderWidth = widget.focused
        ? input.widthInputWrapperFocusBorder
        : input.widthInputWrapperBorder;
    final style = TextStyle(
      fontSize: fontSize,
      color: widget.disabled
          ? input.colorInputDisabledTextDefault
          : input.colorInputDefaultTextDefault,
    );
    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Listener(
        // Whole-box focus like SemiInput: the cell padding is part of the
        // field's click area.
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.disabled
            ? null
            : (_) => widget.focusNode.requestFocus(),
        child: SizedBox(
          width: _width(pin),
          height: _height(input),
          child: DecoratedBox(
            key: SemiPinCode.cellKey(widget.index),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(width: borderWidth, color: borderColor),
              borderRadius: BorderRadius.circular(input.radiusInputWrapper),
            ),
            child: ExcludeFocus(
              excluding: widget.disabled,
              child: IgnorePointer(
                ignoring: widget.disabled,
                child: Center(
                  // pincode.scss:35-38 `input { padding: 0; text-align:
                  // center; }` — no padding, centered text (HARDCODES anchor
                  // in `_PinCodeMetrics.cellInputPaddingTextAlign`).
                  child: SizedBox(
                    width: double.infinity,
                    child: EditableText(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      style: style,
                      cursorColor:
                          style.color ?? input.colorInputDefaultTextDefault,
                      backgroundCursorColor:
                          input.colorInputDisabledTextDefault,
                      // Selection is invisible without this (see
                      // `_InputMetrics.selectionHighlight` in semi_input.dart):
                      // RenderEditable skips painting a null highlight.
                      selectionColor: global.colors.colorPrimary.withValues(
                        alpha: 0.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      keyboardType: widget.numberKeyboard
                          ? TextInputType.number
                          : TextInputType.text,
                      onChanged: widget.onChanged,
                    ),
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

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_pincode.py for the 6 = 6 FIELDS + 0 MOTION + 0
/// INTERNAL accounting; the hardcodes below are the 另列 entries.
abstract final class _PinCodeMetrics {
  /// `count: 6` in packages/semi-ui/pincode/index.tsx (`defaultProps`) —
  /// default of [SemiPinCode.count].
  // ignore: unused_field
  static const int countDefault = 6;

  /// `numberReg = /^\d*$/` in packages/semi-foundation/pincode/foundation.ts
  /// (PinCodeFoundation) — the [SemiPinCodeFormat.number] validator.
  static final RegExp numberReg = RegExp(r'^\d*$');

  /// `mixedReg = /^[0-9a-zA-Z]$/` in
  /// packages/semi-foundation/pincode/foundation.ts (PinCodeFoundation) — the
  /// [SemiPinCodeFormat.mixed] validator.
  static final RegExp mixedReg = RegExp(r'^[0-9a-zA-Z]$');

  /// pincode.scss:35-38 `.semi-pincode-wrapper .semi-input-wrapper input` —
  /// `input { padding: 0; text-align: center; }`: the cell text is centered
  /// and the cell input carries no padding (the [EditableText] is centered in
  /// the box with `TextAlign.center`).
  // ignore: unused_field
  static const String cellInputPaddingTextAlign =
      'input { padding: 0; text-align: center; }';
}
