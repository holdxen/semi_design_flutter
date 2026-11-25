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

import '../../cells/semi_cell_types.dart';
import '../../common/semi_utils.dart';
import '../../../theme/semi_theme.dart';

/// Text rendered by the built-in text-like editors. Other cell kinds (image,
/// bubble, drilldown, custom renderers) have no measurable text and keep the
/// fallback of filling the available width.
String? _editorText(SemiGridCell value) => switch (value) {
  SemiTextCell(:final data) => data,
  SemiNumberCell(:final data) => data == null ? '' : '$data',
  SemiRowIdCell(:final data) => data,
  SemiMarkdownCell(:final data) => data,
  SemiUriCell(:final data) => data,
  _ => null,
};

/// CSS `width: max-content` measures the widest line, so do the same here.
double _measureMaxLineWidth(String text, TextStyle style) {
  final painter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
  var width = 0.0;
  for (final line in text.split('\n')) {
    painter.text = TextSpan(text: line, style: style);
    painter.layout();
    width = math.max(width, painter.width);
  }
  painter.dispose();
  return width;
}

/// `DataGridOverlayEditorProps` (`data-grid-overlay-editor.tsx:27-52`).
class SemiDataGridOverlayEditor extends StatefulWidget {
  const SemiDataGridOverlayEditor({
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
  final SemiRectangle target;
  final SemiItem cell;
  final SemiGridCell content;
  final SemiDataGridTheme theme;
  final void Function(SemiGridCell? newCell, SemiEditorMovement movement)
  onFinishEditing;
  final bool forceEditMode;
  final bool highlight;
  final SemiGetCellRenderer getCellRenderer;

  /// `provideEditor` prop (`data-grid-overlay-editor.tsx:43`): takes
  /// precedence over the renderer's editor. [location] uses business
  /// coordinates, without the row-marker column.
  final SemiEditorProvider? Function(SemiGridCell cell, SemiItem location)?
  provideEditor;
  final String? initialValue;

  /// `bloom` (`[x, y]`): extra pixels of chrome around the target.
  final (double, double)? bloom;

  /// `validateCell` (`:45-49`): `false` marks the editor invalid, a cell
  /// replaces the value, anything else accepts it.
  final Object? Function(
    SemiItem cell,
    SemiGridCell newValue,
    SemiGridCell prevValue,
  )?
  validateCell;

  final SemiCellActivation? activation;

  @override
  State<SemiDataGridOverlayEditor> createState() =>
      _SemiDataGridOverlayEditorState();
}

class _SemiDataGridOverlayEditorState
    extends State<SemiDataGridOverlayEditor> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'SemiOverlayEditor');

  late SemiGridCell? _tempValue;
  late SemiGridCell _lastValue;
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
    if (widget.validateCell != null &&
        semiIsEditableGridCell(widget.content)) {
      final result = widget.validateCell!(
        widget.cell,
        widget.content,
        _lastValue,
      );
      _isValid = result != false;
    }
  }

  SemiGridCell get _targetValue => _tempValue ?? widget.content;

  void _finish(SemiGridCell? value, SemiEditorMovement movement) {
    if (_finished) return;
    _finished = true;
    widget.onFinishEditing(_isValid ? value : null, movement);
  }

  void _onClickOutside() => _finish(_tempValue, SemiEditorMovement.none);

  /// `setTempValue` (`:94-110`).
  void _setTempValue(SemiGridCell newVal) {
    var value = newVal;
    final validate = widget.validateCell;
    if (validate != null && semiIsEditableGridCell(value)) {
      final result = validate(widget.cell, value, _lastValue);
      if (result == false) {
        _isValid = false;
      } else if (result is SemiGridCell) {
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
    SemiGridCell? newValue,
    SemiEditorMovement? movement,
  ) {
    _finish(newValue, movement ?? SemiEditorMovement.none);
  }

  /// `onKeyDown` (`:128-160`).
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    var save = false;
    var movement = SemiEditorMovement.none;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      movement = SemiEditorMovement.none;
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      // Shift is reserved for multi-line editing.
      movement = SemiEditorMovement.down;
      save = true;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      movement = HardwareKeyboard.instance.isShiftPressed
          ? SemiEditorMovement.left
          : SemiEditorMovement.right;
      save = true;
    } else {
      return KeyEventResult.ignored;
    }

    _finish(save ? _tempValue : null, movement);
    return KeyEventResult.handled;
  }

  ({
    SemiEditorBuilder builder,
    bool pad,
    bool style,
    SemiThemeOverride? styleOverride,
  })?
  _resolveEditor() {
    // `provideEditor?.(cellWithLocation)` takes precedence over the renderer
    // (`data-grid-overlay-editor.tsx:170-172`).
    final external = widget.provideEditor?.call(widget.content, widget.cell);
    final provider = external ??
        widget.getCellRenderer(widget.content)?.provideEditor(
          widget.content,
          widget.cell,
        );
    if (provider == null) return null;

    final builder = provider is SemiObjectEditor
        ? provider.builder
        : (provider as SemiComponentEditor).builder;
    return (
      builder: builder,
      pad: !provider.disablePadding,
      style: !provider.disableStyling,
      styleOverride: provider is SemiObjectEditor
          ? provider.styleOverride
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (semiIsInnerOnlyCell(widget.content)) {
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
      SemiEditorProps(
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
        // `useStayOnScreen` (`use-stay-on-screen.ts:40`) pulls the box back
        // until its far edge is `10`px inside the viewport; `maxTop` spends
        // the same budget on the bottom edge, this does it on the right.
        final maxLeft = math.max(0.0, constraints.maxWidth - minWidth - 10);
        final effectiveLeft = left.clamp(0.0, maxLeft);

        final double maxWidth = math.max(
          minWidth,
          math.min(400.0, constraints.maxWidth - effectiveLeft),
        );

        // Upstream sets `width: max-content` on the box
        // (`data-grid-overlay-editor-style.tsx:29`): it hugs the text and is
        // clamped between the cell width and the 400px cap. Loose Flutter
        // constraints made SemiInput/SemiTextArea fill the cap instead, so
        // compute the content width explicitly. Editors without measurable
        // text keep the old fill-the-space behaviour.
        final text = _editorText(_targetValue);
        var desiredWidth = maxWidth;
        if (text != null) {
          final textWidth = _measureMaxLineWidth(
            text,
            theme.baseTextStyle.copyWith(fontSize: theme.editorFontSize),
          );
          // Bare inputs carry 8px horizontal padding + 1px border per side;
          // `gdg-pad` adds another 8.5px per side when enabled.
          final chrome = 18.0 + ((resolved?.pad ?? true) ? 17.0 : 0.0);
          desiredWidth = (textWidth + chrome)
              .clamp(minWidth, maxWidth)
              .toDouble();
        }

        // `gdg-pad` (`data-grid-overlay-editor-style.tsx:52-54`).
        final padding = (resolved?.pad ?? true)
            ? EdgeInsets.fromLTRB(
                8.5,
                math.max(0, (widget.target.height - 28) / 2),
                8.5,
                3,
              )
            : EdgeInsets.zero;

        final semi = SemiTheme.of(context);
        final editorRadius =
            theme.roundingRadius ?? semi.radius.borderRadiusSmall.resolve(0);
        Widget box = ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
            // `maxWidth` is at least `minWidth`: CSS lets `min-width` win
            // over `max-width` (`data-grid-overlay-editor-style.tsx:26-27`),
            // while BoxConstraints would assert. `desiredWidth` implements
            // the same `width: max-content` clamp described above.
            maxWidth: desiredWidth,
          ),
          child: Container(
            padding: padding,
            decoration: (resolved?.style ?? true)
                ? BoxDecoration(
                    color: theme.bgCell,
                    borderRadius: BorderRadius.circular(editorRadius),
                    boxShadow: [
                      BoxShadow(
                        color: semi.colors.colorFocusBorder,
                        blurRadius: 0,
                        spreadRadius: 1,
                      ),
                      ...semi.shadows.shadowElevated.toDropBoxShadows(),
                    ],
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(editorRadius),
              child: editor ?? const SizedBox.shrink(),
            ),
          ),
        );

        if (!_isValid) {
          box = DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: semi.colors.colorDanger),
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
              left: effectiveLeft,
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
