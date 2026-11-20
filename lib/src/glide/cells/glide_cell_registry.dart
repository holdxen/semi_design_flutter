// Port of `packages/core/src/cells/index.ts` (`AllCellRenderers`).
//
// The image cell renderer is deferred: upstream it needs `ImageWindowLoader`
// and a sprite sheet, which are browser concerns. Until then `GlideImageCell`
// falls back to a flat placeholder block of the right size.
import 'package:flutter/widgets.dart';

import 'glide_boolean_cell.dart';
import 'glide_cell_types.dart';
import 'glide_misc_cells.dart';
import 'glide_number_cell.dart';
import 'glide_text_cell.dart';

/// `imageCellRenderer` (`cells/image-cell.tsx`) stand-in: draws a neutral
/// placeholder rectangle sized to the cell.
class GlideImageCellRenderer extends GlideCellRenderer {
  const GlideImageCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.image;

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) => 100;

  @override
  void draw(GlideDrawCellArgs args) {
    final rect = args.rect;
    final theme = args.theme;
    final pad = theme.cellHorizontalPadding;
    args.canvas.drawPath(
      roundedRectPath(
        GlideRectangle(
          x: rect.x + pad,
          y: rect.y + theme.cellVerticalPadding,
          width: rect.width - pad * 2,
          height: rect.height - theme.cellVerticalPadding * 2,
        ),
        theme.roundingRadius ?? 4,
      ),
      Paint()..color = theme.bgCellMedium,
    );
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      (cell as GlideImageCell).displayData?.join(', ') ?? '';
}

/// `AllCellRenderers` (`cells/index.ts:20-34`), indexed by kind for the
/// lookup the painter uses on every cell.
const Map<GlideCellKind, GlideCellRenderer> glideAllCellRenderers = {
  GlideCellKind.marker: GlideMarkerCellRenderer(),
  GlideCellKind.newRow: GlideNewRowCellRenderer(),
  GlideCellKind.boolean: GlideBooleanCellRenderer(),
  GlideCellKind.bubble: GlideBubbleCellRenderer(),
  GlideCellKind.drilldown: GlideDrilldownCellRenderer(),
  GlideCellKind.image: GlideImageCellRenderer(),
  GlideCellKind.loading: GlideLoadingCellRenderer(),
  GlideCellKind.markdown: GlideMarkdownCellRenderer(),
  GlideCellKind.number: GlideNumberCellRenderer(),
  GlideCellKind.protected: GlideProtectedCellRenderer(),
  GlideCellKind.rowID: GlideRowIdCellRenderer(),
  GlideCellKind.text: GlideTextCellRenderer(),
  GlideCellKind.uri: GlideUriCellRenderer(),
};

/// `getCellRenderer` callback (`data-grid.tsx:299`) over the built-in
/// renderers plus any `customRenderers`.
class GlideDefaultRendererLookup extends GlideRendererLookup {
  GlideDefaultRendererLookup({
    super.customRenderers,
    this.extra = const {},
  }) : super(renderers: const {});

  /// Renderers that take precedence over the built-ins, keyed by kind.
  final Map<GlideCellKind, GlideCellRenderer> extra;

  @override
  GlideCellRenderer? forCell(GlideGridCell cell) {
    if (cell.kind == GlideCellKind.custom) {
      for (final r in customRenderers) {
        if (cell is GlideCustomCell && r.isMatch(cell)) return r;
      }
      return null;
    }
    return extra[cell.kind] ?? glideAllCellRenderers[cell.kind];
  }
}
