// Port of `packages/core/src/cells/index.ts` (`AllCellRenderers`).
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../internal/data_grid_overlay_editor/private/glide_image_overlay_editor.dart';
import 'glide_boolean_cell.dart';
import 'glide_cell_types.dart';
import 'glide_misc_cells.dart';
import 'glide_number_cell.dart';
import 'glide_text_cell.dart';

/// `itemMargin` (`image-cell.tsx:69`).
const double _itemMargin = 4;

/// `drawImage` (`image-cell.tsx:72-116`). Images that have not finished
/// decoding are simply skipped, which is what makes the first frame blank and
/// the following frames pop in — the loader repaints the grid through
/// `onLoaded`.
void glideDrawImage(
  GlideDrawCellArgs args,
  List<String> data,
  double rounding,
  GlideContentAlign? contentAlign,
) {
  final loader = args.imageLoader;
  if (loader == null) return;

  final rect = args.rect;
  final theme = args.theme;
  final imgHeight = rect.height - theme.cellVerticalPadding * 2;
  if (imgHeight <= 0) return;

  final images = <(ui.Image, double)>[];
  var totalWidth = 0.0;
  for (final url in data) {
    if (url.isEmpty) continue;
    final img = loader.loadOrGetImage(url, args.col, args.row);
    if (img == null) continue;
    final imgWidth = img.width * (imgHeight / img.height);
    images.add((img, imgWidth));
    totalWidth += imgWidth + _itemMargin;
  }

  if (totalWidth == 0) return;
  totalWidth -= _itemMargin;

  var drawX = rect.x + theme.cellHorizontalPadding;
  if (contentAlign == GlideContentAlign.right) {
    drawX = (rect.x + rect.width - theme.cellHorizontalPadding - totalWidth)
        .floorToDouble();
  } else if (contentAlign == GlideContentAlign.center) {
    drawX = (rect.x + rect.width / 2 - totalWidth / 2).floorToDouble();
  }

  final paint = Paint();
  for (final entry in images) {
    final (img, imgWidth) = entry;
    final dst = Rect.fromLTWH(
      drawX,
      rect.y + theme.cellVerticalPadding,
      imgWidth,
      imgHeight,
    );
    if (rounding > 0) {
      args.canvas.save();
      args.canvas.clipPath(
        roundedRectPath(
          GlideRectangle(
            x: dst.left,
            y: dst.top,
            width: dst.width,
            height: dst.height,
          ),
          rounding,
        ),
      );
    }
    args.canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      dst,
      paint,
    );
    if (rounding > 0) args.canvas.restore();

    drawX += imgWidth + _itemMargin;
  }
}

/// `imageCellRenderer` (`cells/image-cell.tsx`).
class GlideImageCellRenderer extends GlideCellRenderer {
  const GlideImageCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.image;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideImageCell;
    glideDrawImage(
      args,
      cell.displayData ?? cell.data,
      cell.rounding ?? args.theme.roundingRadius ?? 4,
      cell.contentAlign,
    );
  }

  /// `measure` (`image-cell.tsx:34`): `cell.data.length * 50`.
  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) => (cell as GlideImageCell).data.length * 50;

  /// `onDelete` (`image-cell.tsx:36-39`): `{ ...c, data: [] }`.
  @override
  GlideGridCell? onDelete(GlideGridCell cell) =>
      (cell as GlideImageCell).copyWith(data: const []);

  /// `provideEditor` (`image-cell.tsx:41-59`): `imageEditorOverride` has no
  /// counterpart, so the built-in viewer is always used.
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    return GlideComponentEditor((props) {
      final value = props.value as GlideImageCell;
      return GlideImageOverlayEditor(
        urls: value.data,
        canWrite: !value.readonly,
        onCancel: () => props.onFinishedEditing(null, null),
        onChange: (image) => props.onFinishedEditing(
          value.copyWith(data: [image]),
          null,
        ),
      );
    });
  }

  /// `onPaste` (`image-cell.tsx:61-79`): comma separated list of URLs.
  @override
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) {
    final imageCell = cell as GlideImageCell;
    final uris = <String>[];
    for (final fragment in toPaste.trim().split(',')) {
      final uri = Uri.tryParse(fragment.trim());
      if (uri != null && uri.hasScheme) uris.add(fragment.trim());
    }

    final current = imageCell.data;
    if (uris.length == current.length) {
      var same = true;
      for (var i = 0; i < uris.length; i++) {
        if (uris[i] != current[i]) {
          same = false;
          break;
        }
      }
      if (same) return null;
    }
    return imageCell.copyWith(data: uris);
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      (cell as GlideImageCell).data.join(', ');
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
