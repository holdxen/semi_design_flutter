// Port of `packages/core/src/cells/text-cell.tsx`.
import '../internal/data_grid/render/semi_draw_text.dart';
import '../internal/data_grid/render/semi_draw_text.dart' as text;
import '../internal/growing_entry/semi_growing_entry.dart';
import 'semi_cell_types.dart';

/// `textCellRenderer` (`cells/text-cell.tsx:9-63`).
class SemiTextCellRenderer extends SemiCellRenderer {
  const SemiTextCellRenderer();

  @override
  SemiCellKind get kind => SemiCellKind.text;

  @override
  bool needsHoverFor(SemiGridCell cell) =>
      cell is SemiTextCell && cell.hoverEffect;

  @override
  void draw(SemiDrawCellArgs args) {
    final cell = args.cell as SemiTextCell;
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
    SemiGridCell cell,
    SemiDataGridTheme theme,
    SemiTextMetrics metrics,
  ) {
    final textCell = cell as SemiTextCell;
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
  SemiGridCell? onDelete(SemiGridCell cell) =>
      (cell as SemiTextCell).copyWith(data: '', displayData: '');

  /// `provideEditor` (`text-cell.tsx:36-58`).
  @override
  SemiEditorProvider? provideEditor(SemiGridCell cell, SemiItem location) {
    final textCell = cell as SemiTextCell;
    return SemiComponentEditor((props) {
      final value = props.value as SemiTextCell;
      return SemiGrowingEntry(
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
  SemiGridCell? onPaste(
    String toPaste,
    SemiGridCell cell,
    SemiPasteDetails details,
  ) {
    final textCell = cell as SemiTextCell;
    if (toPaste == textCell.data) return null;
    return textCell.copyWith(
      data: toPaste,
      displayData: details.formattedString ?? textCell.displayData,
    );
  }

  @override
  String getAccessibilityString(SemiGridCell cell) =>
      (cell as SemiTextCell).data;
}
