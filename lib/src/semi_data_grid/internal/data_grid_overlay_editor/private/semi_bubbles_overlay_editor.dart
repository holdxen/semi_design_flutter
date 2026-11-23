// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// bubbles-overlay-editor.tsx`.
import 'package:flutter/widgets.dart';

import '../../../common/semi_data_grid_theme.dart';
import '../../../../theme/semi_theme.dart';

/// `BubblesOverlayEditor` (`bubbles-overlay-editor.tsx:12-21`): bubbles are
/// display-only — upstream mounts an empty `<textarea>` to hold focus, which
/// has no counterpart here because the overlay owns its own focus.
class SemiBubblesOverlayEditor extends StatelessWidget {
  const SemiBubblesOverlayEditor({
    super.key,
    required this.bubbles,
    this.theme,
  });

  final List<String> bubbles;
  final SemiDataGridTheme? theme;

  @override
  Widget build(BuildContext context) {
    final t = theme ?? SemiDataGridTheme.fromSemiTheme(SemiTheme.of(context));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final bubble in bubbles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: t.bgBubble,
              borderRadius: BorderRadius.circular(t.bubbleHeight / 2),
            ),
            child: Text(
              bubble,
              style: TextStyle(fontSize: t.baseFontSize, color: t.textBubble),
            ),
          ),
      ],
    );
  }
}
