// Port of `packages/core/src/cells/number-cell.tsx`.
import '../common/glide_utils.dart';
import '../internal/data_grid/render/glide_draw_text.dart';
import '../internal/data_grid/render/glide_draw_text.dart' as text;
import '../internal/data_grid_overlay_editor/private/glide_number_overlay_editor.dart';
import 'glide_cell_types.dart';

/// `numberCellRenderer` (`cells/number-cell.tsx:11-...`).
class GlideNumberCellRenderer extends GlideCellRenderer {
  const GlideNumberCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.number;

  @override
  bool needsHoverFor(GlideGridCell cell) =>
      cell is GlideNumberCell && cell.hoverEffect;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideNumberCell;
    if (cell.hoverEffect && args.hoverAmount > 0) {
      drawEditHoverIndicator(args, cell.displayData, cell.hoverEffectTheme);
    }
    drawTextCell(args, cell.displayData, contentAlign: cell.contentAlign);
  }

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) =>
      text.measureTextWidth(
        (cell as GlideNumberCell).displayData,
        theme,
        metrics,
      ) +
      theme.cellHorizontalPadding * 2;

  /// `provideEditor` (`number-cell.tsx:33-47`).
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    return GlideComponentEditor((props) {
      final value = props.value as GlideNumberCell;
      return GlideNumberOverlayEditor(
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
            displayData: glideNumberToDisplay(n, value.fixedDecimals),
          ),
        ),
      );
    });
  }

  /// `onDelete` (`number-cell.tsx`): `{ ...c, data: undefined }`.
  @override
  GlideGridCell? onDelete(GlideGridCell cell) =>
      (cell as GlideNumberCell).copyWith(data: null);

  /// `onPaste` (`number-cell.tsx`): raw number or `parseFloat`, falling back to
  /// the previous value when the paste is not numeric.
  @override
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) {
    final numberCell = cell as GlideNumberCell;
    final raw = details.rawValue;
    final num? newNumber = raw is num
        ? raw
        : num.tryParse(raw is String ? raw : toPaste);
    if (newNumber == null) return null;
    if (newNumber == numberCell.data) return null;
    return numberCell.copyWith(data: newNumber, displayData: '$newNumber');
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      '${(cell as GlideNumberCell).data ?? ''}';
}
