// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// uri-overlay-editor.tsx`.
import 'package:flutter/material.dart';

import '../../../cells/glide_cell_types.dart';
import '../../../internal/growing_entry/glide_growing_entry.dart';

/// `UriOverlayEditor` (`uri-overlay-editor.tsx:17-49`): a read-only link with
/// a pencil that swaps the box for an editable entry.
class GlideUriOverlayEditor extends StatefulWidget {
  const GlideUriOverlayEditor({
    super.key,
    required this.uri,
    required this.preview,
    required this.onChange,
    required this.readonly,
    required this.forceEditMode,
    this.validatedSelection,
  });

  final String uri;
  final String preview;
  final ValueChanged<String> onChange;
  final bool readonly;
  final bool forceEditMode;
  final GlideSelectionRange? validatedSelection;

  @override
  State<GlideUriOverlayEditor> createState() =>
      _GlideUriOverlayEditorState();
}

class _GlideUriOverlayEditorState extends State<GlideUriOverlayEditor> {
  late bool _editMode;

  @override
  void initState() {
    super.initState();
    _editMode =
        !widget.readonly && (widget.uri.isEmpty || widget.forceEditMode);
  }

  @override
  Widget build(BuildContext context) {
    if (_editMode) {
      return GlideGrowingEntry(
        value: widget.uri,
        onChange: widget.onChange,
        highlight: true,
        autoFocus: true,
        altNewline: false,
        validatedSelection: widget.validatedSelection,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        if (!widget.readonly)
          GestureDetector(
            onTap: () => setState(() => _editMode = true),
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.edit, size: 16),
            ),
          ),
      ],
    );
  }
}
