// Port of `packages/core/src/cells/number-cell.tsx`.
import '../internal/data_grid/render/glide_draw_text.dart';
import '../internal/data_grid/render/glide_draw_text.dart' as text;
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
