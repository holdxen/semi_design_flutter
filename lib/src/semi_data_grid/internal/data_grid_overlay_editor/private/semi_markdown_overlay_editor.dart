// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// markdown-overlay-editor.tsx`.
import 'package:flutter/material.dart';

import '../../../cells/semi_cell_types.dart';
import '../../../internal/growing_entry/semi_growing_entry.dart';

/// `MarkdownOverlayEditor` (`markdown-overlay-editor.tsx:27-64`).
///
/// Web previews through `MarkdownDiv`; the Flutter port shows the markdown
/// source instead until the cell is edited, because no markdown renderer is
/// part of this package yet.
class SemiMarkdownOverlayEditor extends StatefulWidget {
  const SemiMarkdownOverlayEditor({
    super.key,
    required this.value,
    required this.onChange,
    required this.onFinishedEditing,
    required this.forceEditMode,
    this.targetWidth,
    this.validatedSelection,
  });

  final SemiMarkdownCell value;
  final ValueChanged<String> onChange;
  final void Function(SemiMarkdownCell newValue) onFinishedEditing;
  final bool forceEditMode;
  final double? targetWidth;
  final SemiSelectionRange? validatedSelection;

  @override
  State<SemiMarkdownOverlayEditor> createState() =>
      _SemiMarkdownOverlayEditorState();
}

class _SemiMarkdownOverlayEditorState
    extends State<SemiMarkdownOverlayEditor> {
  late bool _editMode;

  @override
  void initState() {
    super.initState();
    _editMode = widget.value.data.isEmpty || widget.forceEditMode;
  }

  @override
  Widget build(BuildContext context) {
    if (_editMode) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: (widget.targetWidth ?? 320) - 40,
            child: SemiGrowingEntry(
              value: widget.value.data,
              onChange: widget.onChange,
              highlight: false,
              autoFocus: true,
              altNewline: false,
              validatedSelection: widget.validatedSelection,
            ),
          ),
          GestureDetector(
            onTap: () => widget.onFinishedEditing(widget.value),
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.check, size: 16),
            ),
          ),
        ],
      );
    }

    final readonly = widget.value.readonly;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.value.data,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!readonly) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _editMode = true),
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.edit, size: 16),
            ),
          ),
        ],
      ],
    );
  }
}
