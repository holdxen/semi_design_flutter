// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// drilldown-overlay-editor.tsx`.
import 'package:flutter/widgets.dart';

import '../../../cells/glide_cell_types.dart';

/// `DrilldownOverlayEditor` (`drilldown-overlay-editor.tsx:35-47`): a
/// read-only row of chips, mirroring `DrilldownOverlayEditorStyle`.
class GlideDrilldownOverlayEditor extends StatelessWidget {
  const GlideDrilldownOverlayEditor({
    super.key,
    required this.drilldowns,
    required this.theme,
  });

  final List<GlideDrilldownCellData> drilldowns;
  final GlideTheme theme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final drilldown in drilldowns)
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.bgCell,
              borderRadius: BorderRadius.circular(theme.roundingRadius ?? 6),
              boxShadow: const [
                BoxShadow(color: Color(0x663E4156), blurRadius: 1),
                BoxShadow(
                  color: Color(0x663E4156),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (drilldown.img != null) ...[
                  Image.network(
                    drilldown.img!,
                    height: 16,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  drilldown.text,
                  style: TextStyle(color: theme.textDark, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
