// Port of `packages/core/src/data-editor/use-column-sizer.ts`
// (`measureColumn` + the `measureCell` helper it delegates to).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../cells/glide_cell_types.dart';
import 'glide_data_editor_fns.dart';

/// `defaultSize` (`use-column-sizer.ts:15`): the stand-in width for cells a
/// renderer cannot measure.
const double glideDefaultCellMeasure = 150;

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

/// `useColumnSizer`'s result (`use-column-sizer.ts:88-91`).
@immutable
class GlideSizedColumns {
  const GlideSizedColumns({
    required this.columns,
    required this.nonGrowWidth,
  });

  final List<GlideGridColumn> columns;

  /// The summed width *before* grow distribution, which is what the horizontal
  /// scroll extent is derived from (`data-editor.tsx:1118`).
  final double nonGrowWidth;
}

/// `useColumnSizer` (`use-column-sizer.ts:78-253`).
///
/// Upstream samples the first ~10 rows in a layout effect and only measures
/// once the cells for the current `columns` identity have arrived, so the
/// first frame shows `defaultSize` placeholders. The Flutter version measures
/// synchronously because `getCellsForSelection` is not a thunk here.
GlideSizedColumns useColumnSizer({
  required List<GlideGridColumn> columns,
  required int rows,
  required GlideGetCellsForSelection? getCellsForSelection,
  required double clientWidth,
  required double minColumnWidth,
  required double maxColumnWidth,
  required GlideTheme theme,
  required GlideGetCellRenderer getCellRenderer,
  required GlideTextMetrics metrics,
  Map<String, double>? memo,
}) {
  var allSized = true;
  for (final c in columns) {
    if (c.width == null) {
      allSized = false;
      break;
    }
  }
  // Sample rows (`use-column-sizer.ts:123-141`): ten rows, plus the last.
  List<List<GlideGridCell>>? selectedData;
  if (!allSized && getCellsForSelection != null && rows > 0) {
    var computeRows = math.max(1, 10 - (columns.length ~/ 10000));
    var tailRows = 0;
    if (computeRows < rows && computeRows > 1) {
      computeRows--;
      tailRows = 1;
    }
    final head = getCellsForSelection(
      GlideRectangle(
        x: 0,
        y: 0,
        width: columns.length.toDouble(),
        height: math.min(rows, computeRows).toDouble(),
      ),
    );
    selectedData = head;
    if (tailRows > 0 && selectedData != null) {
      final tail = getCellsForSelection(
        GlideRectangle(
          x: 0,
          y: (rows - 1).toDouble(),
          width: columns.length.toDouble(),
          height: 1,
        ),
      );
      if (tail != null) selectedData = [...selectedData, ...tail];
    }
  }

  // `getRaw` (`use-column-sizer.ts:168-217`): already-sized columns pass
  // through as the very same list instance, but the grow distribution below
  // still runs over them.
  List<GlideGridColumn> raw;
  if (allSized) {
    raw = columns;
  } else {
    raw = <GlideGridColumn>[];
    for (var colIndex = 0; colIndex < columns.length; colIndex++) {
      final c = columns[colIndex];
      if (c.width != null) {
        raw.add(c);
        continue;
      }

      final id = c.id;
      final memoized = id == null ? null : memo?[id];
      if (memoized != null) {
        raw.add(c.copyWith(width: memoized));
        continue;
      }
      if (selectedData == null || id == null) {
        raw.add(c.copyWith(width: glideDefaultCellMeasure));
        continue;
      }

      final measured = glideMeasureColumn(
        theme: theme,
        column: c,
        colIndex: colIndex,
        selectedData: selectedData,
        minColumnWidth: minColumnWidth,
        maxColumnWidth: maxColumnWidth,
        removeOutliers: true,
        getCellRenderer: getCellRenderer,
        metrics: metrics,
      );
      memo?[id] = measured;
      raw.add(c.copyWith(width: measured));
    }
  }

  // Grow distribution (`use-column-sizer.ts:220-247`).
  var totalWidth = 0.0;
  var totalGrow = 0;
  final distribute = <int>[];
  for (var i = 0; i < raw.length; i++) {
    totalWidth += raw[i].width ?? 0;
    final grow = raw[i].grow;
    if (grow != null && grow > 0) {
      totalGrow += grow;
      distribute.add(i);
    }
  }

  var result = raw;
  if (totalWidth < clientWidth && distribute.isNotEmpty) {
    final writeable = [...raw];
    final extra = clientWidth - totalWidth;
    var remaining = extra;
    for (var di = 0; di < distribute.length; di++) {
      final i = distribute[di];
      final weighted = (raw[i].grow ?? 0) / totalGrow;
      final toAdd = di == distribute.length - 1
          ? remaining
          : math.min(remaining, (extra * weighted).floorToDouble());
      writeable[i] = _withGrowOffset(raw[i], toAdd);
      remaining -= toAdd;
    }
    result = writeable;
  }

  return GlideSizedColumns(columns: result, nonGrowWidth: totalWidth);
}

/// `writeable[i] = { ...result[i], growOffset: toAdd, width: width + toAdd }`
/// (`use-column-sizer.ts:239-244`).
GlideGridColumn _withGrowOffset(GlideGridColumn column, double offset) {
  final extension = column.extension;
  return column.copyWith(
    width: (column.width ?? 0) + offset,
    extension: extension == null
        ? GlideInnerColumnExtension(growOffset: offset.round())
        : extension.copyWith(growOffset: offset.round()),
  );
}
