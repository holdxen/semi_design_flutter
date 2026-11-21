// Port of `packages/core/src/data-editor/use-column-sizer.ts`
// (`measureColumn` + the `measureCell` helper it delegates to).
import 'dart:math' as math;

import '../cells/glide_cell_types.dart';

/// `defaultSize` (`use-column-sizer.ts`): the stand-in width for cells a
/// renderer cannot measure.
const double glideDefaultCellMeasure = 50;

/// `measureCell` (`use-column-sizer.ts:214-221`).
double glideMeasureCell(
  GlideGridCell cell,
  GlideTheme theme,
  GlideGetCellRenderer getCellRenderer,
  GlideTextMetrics metrics,
) {
  final r = getCellRenderer(cell);
  return r?.measure(cell, theme, metrics) ?? glideDefaultCellMeasure;
}

/// `measureColumn` (`use-column-sizer.ts:181-212`).
double glideMeasureColumn({
  required GlideTheme theme,
  required GlideGridColumn column,
  required int colIndex,
  required List<List<GlideGridCell>> selectedData,
  required double minColumnWidth,
  required double maxColumnWidth,
  required bool removeOutliers,
  required GlideGetCellRenderer getCellRenderer,
  required GlideTextMetrics metrics,
}) {
  var max = 0.0;
  final sizes = <double>[];
  for (final row in selectedData) {
    if (colIndex >= row.length) continue;
    final size = glideMeasureCell(
      row[colIndex],
      theme,
      getCellRenderer,
      metrics,
    );
    if (size > max) max = size;
    sizes.add(size);
  }

  if (sizes.length > 5 && removeOutliers) {
    max = 0;
    var sum = 0.0;
    for (final size in sizes) {
      sum += size;
    }
    final average = sum / sizes.length;
    for (var i = 0; i < sizes.length; i++) {
      if (sizes[i] >= average * 2) {
        sizes[i] = 0;
      } else if (sizes[i] > max) {
        max = sizes[i];
      }
    }
  }

  final titleWidth = metrics.width(column.title, theme.headerTextStyle) +
      theme.cellHorizontalPadding * 2 +
      (column.icon == null ? 0 : 28);
  if (titleWidth > max) max = titleWidth;

  return math.max(
    minColumnWidth.ceilToDouble(),
    math.min(maxColumnWidth.floorToDouble(), max.ceilToDouble()),
  );
}
