// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// bubbles-overlay-editor.tsx`.
import 'package:flutter/widgets.dart';

/// `BubblesOverlayEditor` (`bubbles-overlay-editor.tsx:12-21`): bubbles are
/// display-only — upstream mounts an empty `<textarea>` to hold focus, which
/// has no counterpart here because the overlay owns its own focus.
class GlideBubblesOverlayEditor extends StatelessWidget {
  const GlideBubblesOverlayEditor({super.key, required this.bubbles});

  final List<String> bubbles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final bubble in bubbles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEF0),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(bubble, style: const TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}
