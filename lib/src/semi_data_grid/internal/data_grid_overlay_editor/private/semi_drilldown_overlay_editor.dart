// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// drilldown-overlay-editor.tsx`.
import 'package:flutter/widgets.dart';

import '../../../cells/semi_cell_types.dart';
import '../../../../theme/semi_theme.dart';

/// `DrilldownOverlayEditor` (`drilldown-overlay-editor.tsx:35-47`): a
/// read-only row of chips, mirroring `DrilldownOverlayEditorStyle`.
class SemiDrilldownOverlayEditor extends StatelessWidget {
  const SemiDrilldownOverlayEditor({
    super.key,
    required this.drilldowns,
    required this.theme,
  });

  final List<SemiDrilldownCellData> drilldowns;
  final SemiDataGridTheme theme;

  @override
  Widget build(BuildContext context) {
    final semi = SemiTheme.of(context);
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
              borderRadius: BorderRadius.circular(
                theme.roundingRadius ??
                    semi.radius.borderRadiusMedium.resolve(0),
              ),
              boxShadow: semi.shadows.shadowElevated.toDropBoxShadows(),
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
                  style: TextStyle(
                    color: theme.textDark,
                    fontSize: theme.baseFontSize,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
