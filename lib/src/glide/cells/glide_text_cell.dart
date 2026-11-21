// Port of `packages/core/src/cells/text-cell.tsx`.
import '../internal/data_grid/render/glide_draw_text.dart';
import '../internal/data_grid/render/glide_draw_text.dart' as text;
import '../internal/growing_entry/glide_growing_entry.dart';
import 'glide_cell_types.dart';

/// `textCellRenderer` (`cells/text-cell.tsx:9-63`).
class GlideTextCellRenderer extends GlideCellRenderer {
  const GlideTextCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.text;

  @override
  bool needsHoverFor(GlideGridCell cell) =>
      cell is GlideTextCell && cell.hoverEffect;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideTextCell;
    if (cell.hoverEffect && args.hoverAmount > 0) {
      drawEditHoverIndicator(args, cell.displayData, cell.hoverEffectTheme);
    }
    drawTextCell(
      args,
      cell.displayData,
      contentAlign: cell.contentAlign,
      allowWrapping: cell.allowWrapping,
      hyperWrapping: args.hyperWrapping,
    );
  }

  /// `measure` (`text-cell.tsx:24-31`).
  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) {
    final textCell = cell as GlideTextCell;
    final lines = textCell.allowWrapping
        ? textCell.displayData.split('\n')
        : [textCell.displayData.split('\n').first];
    var maxLineWidth = 0.0;
    for (final line in lines) {
      final width = text.measureTextWidth(line, theme, metrics);
      if (width > maxLineWidth) maxLineWidth = width;
    }
    return maxLineWidth + 2 * theme.cellHorizontalPadding;
  }

  /// `onDelete` (`text-cell.tsx:32-35`).
  @override
  GlideGridCell? onDelete(GlideGridCell cell) =>
      (cell as GlideTextCell).copyWith(data: '', displayData: '');

  /// `provideEditor` (`text-cell.tsx:36-58`).
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    final textCell = cell as GlideTextCell;
    return GlideComponentEditor((props) {
      final value = props.value as GlideTextCell;
      return GlideGrowingEntry(
        value: value.data,
        autoFocus: value.readonly != true,
        disabled: value.readonly,
        altNewline: true,
        highlight: props.isHighlighted,
        onChange: (text) =>
            props.onChange(value.copyWith(data: text, displayData: text)),
      );
    }, disablePadding: textCell.allowWrapping);
  }

  /// `onPaste` (`text-cell.tsx:59-62`).
  @override
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) {
    final textCell = cell as GlideTextCell;
    if (toPaste == textCell.data) return null;
    return textCell.copyWith(
      data: toPaste,
      displayData: details.formattedString ?? textCell.displayData,
    );
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      (cell as GlideTextCell).data;
}
