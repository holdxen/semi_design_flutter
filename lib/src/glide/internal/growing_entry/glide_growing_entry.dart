// Port of `packages/core/src/internal/growing-entry/growing-entry.tsx`.
//
// Web uses a contenteditable `<textarea>` wrapper. Flutter's `TextField` with
// `maxLines: null` grows the same way; the caret/selection APIs differ, so
// `validatedSelection` is applied once after the first frame.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/glide_theme.dart';
import '../data_grid/glide_types.dart';

/// `GrowingEntry` (`growing-entry.tsx`).
class GlideGrowingEntry extends StatefulWidget {
  const GlideGrowingEntry({
    super.key,
    required this.value,
    required this.onChange,
    this.autoFocus = true,
    this.disabled = false,
    this.altNewline = false,
    this.highlight = false,
    this.theme,
    this.validatedSelection,
    this.padding,
    this.onKeyEvent,
  });

  final String value;
  final ValueChanged<String> onChange;
  final bool autoFocus;
  final bool disabled;

  /// `altNewline`: Enter commits, Alt+Enter inserts a newline (`text-cell`).
  final bool altNewline;
  final bool highlight;
  final GlideTheme? theme;

  /// `SelectionRange = number | [number, number]`.
  final GlideSelectionRange? validatedSelection;
  final EdgeInsets? padding;
  final KeyEventResult Function(KeyEvent event, String value)? onKeyEvent;

  @override
  State<GlideGrowingEntry> createState() => _GlideGrowingEntryState();
}

class _GlideGrowingEntryState extends State<GlideGrowingEntry> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    if (widget.validatedSelection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final sel = widget.validatedSelection;
        if (sel is int) {
          _controller.selection = TextSelection.collapsed(offset: sel);
        } else if (sel is List && sel.length >= 2) {
          _controller.selection = TextSelection(
            baseOffset: sel[0] as int,
            extentOffset: sel[1] as int,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(GlideGrowingEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? GlideTheme.light();
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter, alt: true):
            _AltEnterIntent(),
      },
      child: Actions(
        actions: {
          _AltEnterIntent: CallbackAction<_AltEnterIntent>(
            onInvoke: (_) {
              final sel = _controller.selection;
              final text = _controller.text;
              final offset = sel.isValid ? sel.end : text.length;
              _controller.value = TextEditingValue(
                text: '${text.substring(0, offset)}\n${text.substring(offset)}',
                selection: TextSelection.collapsed(offset: offset + 1),
              );
              widget.onChange(_controller.text);
              return null;
            },
          ),
        },
        child: Focus(
          onKeyEvent: (node, event) =>
              widget.onKeyEvent?.call(event, _controller.text) ??
              KeyEventResult.ignored,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autoFocus,
            enabled: !widget.disabled,
            maxLines: null,
            expands: false,
            cursorColor: theme.accentColor,
            style: theme.baseTextStyle.copyWith(fontSize: theme.editorFontSize),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding:
                  widget.padding ??
                  EdgeInsets.symmetric(
                    horizontal: theme.cellHorizontalPadding -
                        1.5, // upstream 8.5px vs 8px cell padding
                    vertical: theme.cellVerticalPadding,
                  ),
            ),
            textAlignVertical: TextAlignVertical.center,
            onChanged: widget.onChange,
          ),
        ),
      ),
    );
  }
}

class _AltEnterIntent extends Intent {
  const _AltEnterIntent();
}
