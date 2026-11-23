// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// uri-overlay-editor.tsx`.
import 'package:flutter/material.dart';

import '../../../cells/semi_cell_types.dart';
import '../../../internal/growing_entry/semi_growing_entry.dart';

/// `UriOverlayEditor` (`uri-overlay-editor.tsx:17-49`): a read-only link with
/// a pencil that swaps the box for an editable entry.
class SemiUriOverlayEditor extends StatefulWidget {
  const SemiUriOverlayEditor({
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
  final SemiSelectionRange? validatedSelection;

  @override
  State<SemiUriOverlayEditor> createState() =>
      _SemiUriOverlayEditorState();
}

class _SemiUriOverlayEditorState extends State<SemiUriOverlayEditor> {
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
      return SemiGrowingEntry(
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
