// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// number-overlay-editor.tsx`.
//
// Web uses `react-number-format`'s `NumericFormat`, which reformats on every
// keystroke and keeps the caret anchored to the digit count. This is the same
// contract: [GlideNumberOverlayEditor] regroups on change and restores the
// caret by counting digits, not characters.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../cells/glide_cell_types.dart';

/// `NumberOverlayEditor` (`number-overlay-editor.tsx:32-76`).
class GlideNumberOverlayEditor extends StatefulWidget {
  const GlideNumberOverlayEditor({
    super.key,
    required this.value,
    required this.onChange,
    this.disabled = false,
    this.highlight = true,
    this.fixedDecimals,
    this.allowNegative = true,
    this.thousandSeparator,
    this.decimalSeparator,
    this.validatedSelection,
    this.theme,
  });

  /// `value` (`number-overlay-editor.tsx:68`): `-0` renders as `-`.
  final num? value;
  final void Function(num newValue) onChange;
  final bool disabled;
  final bool highlight;
  final int? fixedDecimals;
  final bool allowNegative;

  /// Unset → `","` when the decimal separator is `"."`, else `"."`
  /// (`number-overlay-editor.tsx:19-30`).
  final String? thousandSeparator;
  final String? decimalSeparator;
  final GlideSelectionRange? validatedSelection;
  final GlideTheme? theme;

  @override
  State<GlideNumberOverlayEditor> createState() =>
      _GlideNumberOverlayEditorState();
}

class _GlideNumberOverlayEditorState extends State<GlideNumberOverlayEditor> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  String get _decimalSeparator => widget.decimalSeparator ?? '.';

  String get _thousandSeparator =>
      widget.thousandSeparator ??
      (_decimalSeparator == '.' ? ',' : '.');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      // `onFocus` (`number-overlay-editor.tsx:60-62`): a highlighted editor
      // selects the whole value, otherwise the caret lands at the end.
      final length = _controller.text.length;
      _controller.selection = TextSelection(
        baseOffset: widget.highlight ? 0 : length,
        extentOffset: length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Formats [value] with grouping and `fixedDecimals`.
  String _formatValue(num? value) {
    if (value == null) return '';
    final negative = value < 0 || (value == 0 && value.toDouble().isNegative);
    final abs = value.abs().toDouble();
    final decimals = widget.fixedDecimals;
    var text = decimals != null
        ? abs.toStringAsFixed(decimals)
        : (abs.truncateToDouble() == abs
              ? abs.toStringAsFixed(0)
              : '$abs');
    if (text.contains('.')) {
      final parts = text.split('.');
      text = '${_group(parts[0])}$_decimalSeparator${parts[1]}';
    } else {
      text = _group(text);
    }
    return negative && widget.allowNegative ? '-$text' : text;
  }

  String _group(String digits) {
    if (digits.length < 4) return digits;
    final sep = _thousandSeparator;
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(sep);
      out.write(digits[i]);
    }
    return out.toString();
  }

  /// Re-formats the typed text and reports the parsed value
  /// (`number-overlay-editor.tsx:69`).
  void _onChanged(String raw) {
    final sep = _decimalSeparator;
    final selection = _controller.selection;
    final caret = selection.isValid ? selection.extentOffset : raw.length;

    var text = raw;
    var negative = text.startsWith('-');
    if (negative) text = text.substring(1);

    final decimalIndex = text.indexOf(sep);
    var integer = decimalIndex == -1 ? text : text.substring(0, decimalIndex);
    var fraction = decimalIndex == -1
        ? ''
        : text.substring(decimalIndex + 1);

    final digitsBeforeCaret = _digitCount(raw, caret);
    integer = integer.replaceAll(RegExp('[^0-9]'), '');
    fraction = fraction.replaceAll(RegExp('[^0-9]'), '');
    if (!widget.allowNegative) negative = false;

    final decimals = widget.fixedDecimals;
    if (decimals != null && fraction.length > decimals) {
      fraction = fraction.substring(0, decimals);
    }

    var out = (negative ? '-' : '') + _group(integer);
    if (decimalIndex != -1 || fraction.isNotEmpty) {
      out = '$out$sep$fraction';
    }
    if (out != _controller.text) {
      _controller.value = TextEditingValue(
        text: out,
        selection: _collapsedAfterDigits(out, digitsBeforeCaret),
      );
    }

    final parsed = num.tryParse(
      '${negative ? '-' : ''}$integer'
      '${fraction.isEmpty ? '' : '$sep$fraction'}',
    );
    if (parsed != null) widget.onChange(parsed);
  }

  int _digitCount(String text, int upTo) {
    var count = 0;
    for (var i = 0; i < upTo && i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (code >= 0x30 && code <= 0x39) count++;
    }
    return count;
  }

  TextSelection _collapsedAfterDigits(String text, int digits) {
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (code >= 0x30 && code <= 0x39) {
        seen++;
        if (seen == digits) {
          return TextSelection.collapsed(offset: i + 1);
        }
      }
    }
    return TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? GlideTheme.light();
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.disabled,
      autofocus: true,
      keyboardType: TextInputType.number,
      maxLines: 1,
      style: theme.baseTextStyle.copyWith(fontSize: theme.editorFontSize),
      onChanged: _onChanged,
      inputFormatters: [
        widget.allowNegative
            ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]'))
            : FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: theme.cellHorizontalPadding - 1.5,
          vertical: theme.cellVerticalPadding,
        ),
      ),
    );
  }
}
