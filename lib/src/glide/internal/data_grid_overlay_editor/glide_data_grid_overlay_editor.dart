// Port of `packages/core/src/internal/data-grid-overlay-editor/
// data-grid-overlay-editor.tsx` (+ its styled component).
//
// Web uses a DOM portal plus a `ClickOutsideContainer`; Flutter uses an
// `OverlayEntry` supplied by the owner. The editor is therefore rendered as
// a full-size `Stack`: a transparent backdrop absorbs outside clicks and the
// editor box is positioned over the target cell.
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../cells/glide_cell_types.dart';
import '../../common/glide_utils.dart';

/// `DataGridOverlayEditorProps` (`data-grid-overlay-editor.tsx:27-52`).
class GlideDataGridOverlayEditor extends StatefulWidget {
  const GlideDataGridOverlayEditor({
    super.key,
    required this.target,
    required this.cell,
    required this.content,
    required this.theme,
    required this.onFinishEditing,
    required this.forceEditMode,
    required this.highlight,
    required this.getCellRenderer,
    this.provideEditor,
    this.initialValue,
    this.bloom,
    this.validateCell,
    this.activation,
  });

  /// Bounds of the cell being edited, in grid coordinates.
  final GlideRectangle target;
  final GlideItem cell;
  final GlideGridCell content;
  final GlideTheme theme;
  final void Function(GlideGridCell? newCell, GlideEditorMovement movement)
  onFinishEditing;
  final bool forceEditMode;
  final bool highlight;
  final GlideGetCellRenderer getCellRenderer;

  /// `provideEditor` prop — takes precedence over the renderer's.
  final GlideEditorBuilder? provideEditor;
  final String? initialValue;

  /// `bloom` (`[x, y]`): extra pixels of chrome around the target.
  final (double, double)? bloom;

  /// `validateCell` (`:45-49`): `false` marks the editor invalid, a cell
  /// replaces the value, anything else accepts it.
  final Object? Function(
    GlideItem cell,
    GlideGridCell newValue,
    GlideGridCell prevValue,
  )?
  validateCell;

  final GlideCellActivationBehavior? activation;

  @override
  State<GlideDataGridOverlayEditor> createState() =>
      _GlideDataGridOverlayEditorState();
}

class _GlideDataGridOverlayEditorState
    extends State<GlideDataGridOverlayEditor> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'GlideOverlayEditor');

  late GlideGridCell? _tempValue;
  late GlideGridCell _lastValue;
  late bool _isValid;
  bool _finished = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tempValue = widget.forceEditMode ? widget.content : null;
    _lastValue = _tempValue ?? widget.content;
    _isValid = true;
    // Take focus away from the grid once the editor is on screen; `autofocus`
    // alone does not steal it from an already-focused ancestor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
    if (widget.validateCell != null && glideIsEditableGridCell(widget.content)) {
      final result = widget.validateCell!(
        widget.cell,
        widget.content,
        _lastValue,
      );
      _isValid = result != false;
    }
  }

  GlideGridCell get _targetValue => _tempValue ?? widget.content;

  void _finish(GlideGridCell? value, GlideEditorMovement movement) {
    if (_finished) return;
    _finished = true;
    widget.onFinishEditing(_isValid ? value : null, movement);
  }

  void _onClickOutside() => _finish(_tempValue, GlideEditorMovement.none);

  /// `setTempValue` (`:94-110`).
  void _setTempValue(GlideGridCell newVal) {
    var value = newVal;
    final validate = widget.validateCell;
    if (validate != null && glideIsEditableGridCell(value)) {
      final result = validate(widget.cell, value, _lastValue);
      if (result == false) {
        _isValid = false;
      } else if (result is GlideGridCell) {
        value = result;
        _isValid = true;
      } else {
        _isValid = true;
      }
    }
    setState(() {
      _tempValue = value;
      _lastValue = value;
    });
  }

  /// `onEditorFinished` (`:120-126`) as used by the editor components.
  void _onEditorFinished(
    GlideGridCell? newValue,
    GlideEditorMovement? movement,
  ) {
    _finish(newValue, movement ?? GlideEditorMovement.none);
  }

  /// `onKeyDown` (`:128-160`).
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    var save = false;
    var movement = GlideEditorMovement.none;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      movement = GlideEditorMovement.none;
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      // Shift is reserved for multi-line editing.
      movement = GlideEditorMovement.down;
      save = true;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      movement = HardwareKeyboard.instance.isShiftPressed
          ? GlideEditorMovement.left
          : GlideEditorMovement.right;
      save = true;
    } else {
      return KeyEventResult.ignored;
    }

    _finish(save ? _tempValue : null, movement);
    return KeyEventResult.handled;
  }

  ({GlideEditorBuilder builder, bool pad, bool style, GlideThemeOverride? styleOverride})?
  _resolveEditor() {
    final external = widget.provideEditor;
    if (external != null) {
      return (builder: external, pad: true, style: true, styleOverride: null);
    }

    // `editorProvider === undefined` leaves the clip region empty upstream
    // (`data-grid-overlay-editor.tsx:164-173`), so a cell without an editor
    // still opens a styled box rather than failing.
    final renderer = widget.getCellRenderer(widget.content);
    final provider = renderer?.provideEditor(widget.content, widget.cell);
    if (provider == null) return null;

    final builder = provider is GlideObjectEditor
        ? provider.builder
        : (provider as GlideComponentEditor).builder;
    return (
      builder: builder,
      pad: !provider.disablePadding,
      style: !provider.disableStyling,
      styleOverride: provider is GlideObjectEditor
          ? provider.styleOverride
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (glideIsInnerOnlyCell(widget.content)) {
      return const SizedBox.shrink();
    }

    final resolved = _resolveEditor();
    final theme = widget.theme;

    final (bloomX, bloomY) = widget.bloom ?? (1, 1);
    final left = widget.target.x - bloomX;
    final top = widget.target.y - bloomY;
    final minWidth = widget.target.width + bloomX * 2;
    final minHeight = widget.target.height + bloomY * 2;

    final editor = resolved?.builder(
      GlideEditorProps(
        value: _targetValue,
        target: widget.target,
        theme: theme,
        isHighlighted: widget.highlight,
        forceEditMode: widget.forceEditMode,
        initialValue: widget.initialValue,
        onChange: _setTempValue,
        onFinishedEditing: _onEditorFinished,
        isValid: _isValid,
        activation: widget.activation,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTop = math.max(0.0, constraints.maxHeight - minHeight - 10);

        // `gdg-pad` (`data-grid-overlay-editor-style.tsx:52-54`).
        final padding = (resolved?.pad ?? true)
            ? EdgeInsets.fromLTRB(
                8.5,
                math.max(0, (widget.target.height - 28) / 2),
                8.5,
                3,
              )
            : EdgeInsets.zero;

        Widget box = ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
            maxWidth: math.min(400, constraints.maxWidth - left),
          ),
          child: Container(
            padding: padding,
            decoration: (resolved?.style ?? true)
                ? BoxDecoration(
                    color: theme.bgCell,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.accentColor,
                        blurRadius: 0,
                        spreadRadius: 1,
                      ),
                      const BoxShadow(
                        color: Color(0x663E4156),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                      const BoxShadow(
                        color: Color(0x263E4156),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: editor ?? const SizedBox.shrink(),
            ),
          ),
        );

        if (!_isValid) {
          box = DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.accentColor),
            ),
            child: box,
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // `ClickOutsideContainer` (`click-outside-container.tsx`).
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _onClickOutside,
              onSecondaryTapDown: (_) => _onClickOutside(),
              child: const ColoredBox(color: Color(0x00FFFFFF)),
            ),
            Positioned(
              left: left,
              top: top.clamp(0.0, maxTop),
              child: Focus(
                focusNode: _focusNode,
                onKeyEvent: _handleKeyEvent,
                autofocus: true,
                child: box,
              ),
            ),
          ],
        );
      },
    );
  }
}
