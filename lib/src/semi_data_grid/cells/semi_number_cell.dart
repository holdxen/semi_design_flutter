// Port of `packages/core/src/cells/number-cell.tsx`.
import '../common/semi_utils.dart';
import '../internal/data_grid/render/semi_draw_text.dart';
import '../internal/data_grid/render/semi_draw_text.dart' as text;
import '../internal/data_grid_overlay_editor/private/semi_number_overlay_editor.dart';
import 'semi_cell_types.dart';

/// `numberCellRenderer` (`cells/number-cell.tsx:11-...`).
class SemiNumberCellRenderer extends SemiCellRenderer {
  const SemiNumberCellRenderer();

  @override
  SemiCellKind get kind => SemiCellKind.number;

  @override
  bool needsHoverFor(SemiGridCell cell) =>
      cell is SemiNumberCell && cell.hoverEffect;

  @override
  void draw(SemiDrawCellArgs args) {
    final cell = args.cell as SemiNumberCell;
    if (cell.hoverEffect && args.hoverAmount > 0) {
      drawEditHoverIndicator(args, cell.displayData, cell.hoverEffectTheme);
    }
    drawTextCell(args, cell.displayData, contentAlign: cell.contentAlign);
  }

  @override
  double? measure(
    SemiGridCell cell,
    SemiDataGridTheme theme,
    SemiTextMetrics metrics,
  ) =>
      text.measureTextWidth(
        (cell as SemiNumberCell).displayData,
        theme,
        metrics,
      ) +
      theme.cellHorizontalPadding * 2;

  /// `provideEditor` (`number-cell.tsx:33-47`).
  @override
  SemiEditorProvider? provideEditor(SemiGridCell cell, SemiItem location) {
    return SemiComponentEditor((props) {
      final value = props.value as SemiNumberCell;
      return SemiNumberOverlayEditor(
        value: value.data,
        disabled: value.readonly,
        highlight: props.isHighlighted,
        fixedDecimals: value.fixedDecimals,
        allowNegative: value.allowNegative,
        // `thousandSeparator ?? getThousandSeprator()`; only an explicit
        // `false` disables the grouping, which we pass as an empty string.
        thousandSeparator: value.thousandSeparator == false ? '' : null,
        decimalSeparator: value.decimalSeparator,
        // Upstream only writes `data` (`number-cell.tsx:45`); `displayData`
        // has to follow here or the cell keeps showing the old number, which
        // is why the text editor does the same pair.
        onChange: (n) => props.onChange(
          value.copyWith(
            data: n,
            displayData: semiNumberToDisplay(n, value.fixedDecimals),
          ),
        ),
      );
    });
  }

  /// `onDelete` (`number-cell.tsx`): `{ ...c, data: undefined }`.
  @override
  SemiGridCell? onDelete(SemiGridCell cell) =>
      (cell as SemiNumberCell).copyWith(data: null);

  /// `onPaste` (`number-cell.tsx`): raw number or `parseFloat`, falling back to
  /// the previous value when the paste is not numeric.
  @override
  SemiGridCell? onPaste(
    String toPaste,
    SemiGridCell cell,
    SemiPasteDetails details,
  ) {
    final numberCell = cell as SemiNumberCell;
    final raw = details.rawValue;
    final num? newNumber = raw is num
        ? raw
        : num.tryParse(raw is String ? raw : toPaste);
    if (newNumber == null) return null;
    if (newNumber == numberCell.data) return null;
    return numberCell.copyWith(data: newNumber, displayData: '$newNumber');
  }

  @override
  String getAccessibilityString(SemiGridCell cell) =>
      '${(cell as SemiNumberCell).data ?? ''}';
}
