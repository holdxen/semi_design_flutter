// Ports of the remaining core cell renderers:
// - `cells/bubble-cell.tsx`
// - `cells/loading-cell.tsx`
// - `cells/protected-cell.tsx`
// - `cells/row-id-cell.tsx`
// - `cells/markdown-cell.tsx`
// - `cells/uri-cell.tsx`
// - `cells/drilldown-cell.tsx`
// - `cells/new-row-cell.tsx`
// - `cells/marker-cell.tsx`
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../common/glide_utils.dart';
import '../internal/data_grid/render/glide_draw_checkbox.dart';
import '../internal/data_grid/render/glide_draw_text.dart';
import '../internal/data_grid_overlay_editor/private/glide_bubbles_overlay_editor.dart';
import '../internal/data_grid_overlay_editor/private/glide_drilldown_overlay_editor.dart';
import '../internal/data_grid_overlay_editor/private/glide_markdown_overlay_editor.dart';
import '../internal/data_grid_overlay_editor/private/glide_uri_overlay_editor.dart';
import '../internal/growing_entry/glide_growing_entry.dart';
import 'glide_cell_types.dart';

/// `makeAccessibilityStringForArray` (`common/utils.tsx`).
String makeAccessibilityStringForArray(List<String> data) => data.join(', ');

// ---------------------------------------------------------------------------
// BubbleCell (`bubble-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideBubbleCellRenderer extends GlideCellRenderer {
  const GlideBubbleCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.bubble;

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) {
    final data = (cell as GlideBubbleCell).data;
    if (data.isEmpty) return theme.cellHorizontalPadding * 2;
    var bubblesWidth = 0.0;
    for (final s in data) {
      bubblesWidth +=
          metrics.width(s, theme.baseTextStyle) +
          theme.bubblePadding * 2 +
          theme.bubbleMargin;
    }
    return bubblesWidth + 2 * theme.cellHorizontalPadding - theme.bubbleMargin;
  }

  @override
  void draw(GlideDrawCellArgs args) =>
      drawBubbles(args, (args.cell as GlideBubbleCell).data);

  /// `drawBubbles` (`bubble-cell.tsx:36-80`).
  void drawBubbles(GlideDrawCellArgs args, List<String> data) {
    final rect = args.rect;
    final theme = args.theme;
    final canvas = args.canvas;
    final metrics = args.metrics ?? GlideTextMetrics();
    final w = rect.width;
    final h = rect.height;

    var renderX = rect.x + theme.cellHorizontalPadding;

    final renderBoxes = <({double x, double width})>[];
    for (final s in data) {
      if (renderX > rect.x + w) break;
      final textWidth = metrics.width(s, theme.baseTextStyle);
      renderBoxes.add((x: renderX, width: textWidth));
      renderX += textWidth + theme.bubblePadding * 2 + theme.bubbleMargin;
    }

    final bubbles = Path();
    for (final box in renderBoxes) {
      bubbles.addPath(
        roundedRectPath(
          GlideRectangle(
            x: box.x,
            y: rect.y + (h - theme.bubbleHeight) / 2,
            width: box.width + theme.bubblePadding * 2,
            height: theme.bubbleHeight,
          ),
          theme.roundingRadius ?? theme.bubbleHeight / 2,
        ),
        Offset.zero,
      );
    }
    canvas.drawPath(
      bubbles,
      Paint()
        ..color = args.highlighted
            ? theme.bgBubbleSelected
            : theme.bgBubble,
    );

    for (var i = 0; i < renderBoxes.length; i++) {
      final box = renderBoxes[i];
      final style = theme.baseTextStyle.copyWith(color: theme.textBubble);
      final painter = metrics.painter(data[i], style);
      painter.paint(
        canvas,
        Offset(box.x + theme.bubblePadding, rect.y + h / 2 - painter.height / 2),
      );
    }
  }

  /// `provideEditor` (`bubble-cell.tsx:24-26`).
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    return GlideComponentEditor(
      (props) => GlideBubblesOverlayEditor(
        bubbles: (props.value as GlideBubbleCell).data,
        theme: props.theme,
      ),
    );
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      makeAccessibilityStringForArray((cell as GlideBubbleCell).data);
}

// ---------------------------------------------------------------------------
// LoadingCell (`loading-cell.tsx`)
// ---------------------------------------------------------------------------

/// `getRandomNumber` (`loading-cell.tsx:7-16`): xorshift seeded by position so
/// skeletons stay stable across frames.
double getLoadingRandomNumber(int x, int y) {
  var seed = x * 49632 + y * 325176;
  seed ^= seed << 13;
  seed ^= seed >> 17;
  seed ^= seed << 5;
  return (seed / 0xFFFFFFFF) * 2;
}

class GlideLoadingCellRenderer extends GlideCellRenderer {
  const GlideLoadingCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.loading;

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) => 120;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideLoadingCell;
    final skeletonWidth = cell.skeletonWidth;
    if (skeletonWidth == null || skeletonWidth == 0) return;

    final rect = args.rect;
    final theme = args.theme;
    var width = skeletonWidth;
    final variability = cell.skeletonWidthVariability;
    if (variability != null && variability > 0) {
      width += (getLoadingRandomNumber(args.col, args.row) * variability)
          .roundToDouble();
    }

    final hpad = theme.cellHorizontalPadding;
    if (width + hpad * 2 >= rect.width) {
      width = rect.width - hpad * 2 - 1;
    }
    final rectHeight =
        cell.skeletonHeight ??
        math.min(18.0, rect.height - 2 * theme.cellVerticalPadding);

    args.canvas.drawPath(
      roundedRectPath(
        GlideRectangle(
          x: rect.x + hpad,
          y: rect.y + (rect.height - rectHeight) / 2,
          width: width,
          height: rectHeight,
        ),
        theme.roundingRadius ?? 3,
      ),
      Paint()..color = theme.bgCellMedium,
    );
  }
}

// ---------------------------------------------------------------------------
// ProtectedCell (`protected-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideProtectedCellRenderer extends GlideCellRenderer {
  const GlideProtectedCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.protected;

  @override
  void draw(GlideDrawCellArgs args) {
    final rect = args.rect;
    final theme = args.theme;
    final canvas = args.canvas;
    final paint = Paint()
      ..color = theme.borderColor
      ..strokeWidth = 1;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height));
    // Upstream draws 45° hatching every 6px; the star overlay is drawn on top
    // by the same renderer.
    for (var x = rect.x - rect.height; x < rect.x + rect.width; x += 6) {
      canvas.drawLine(
        Offset(x, rect.y),
        Offset(x + rect.height, rect.y + rect.height),
        paint,
      );
    }
    canvas.restore();

    final star = Path()
      ..moveTo(rect.x + rect.width / 2, rect.y + rect.height / 2 - 5)
      ..lineTo(rect.x + rect.width / 2 + 1.4, rect.y + rect.height / 2 - 1.4)
      ..lineTo(rect.x + rect.width / 2 + 5, rect.y + rect.height / 2 - 1.4)
      ..lineTo(rect.x + rect.width / 2 + 2.2, rect.y + rect.height / 2 + 0.8)
      ..lineTo(rect.x + rect.width / 2 + 3.2, rect.y + rect.height / 2 + 5)
      ..lineTo(rect.x + rect.width / 2, rect.y + rect.height / 2 + 2.4)
      ..lineTo(rect.x + rect.width / 2 - 3.2, rect.y + rect.height / 2 + 5)
      ..lineTo(rect.x + rect.width / 2 - 2.2, rect.y + rect.height / 2 + 0.8)
      ..lineTo(rect.x + rect.width / 2 - 5, rect.y + rect.height / 2 - 1.4)
      ..lineTo(rect.x + rect.width / 2 - 1.4, rect.y + rect.height / 2 - 1.4)
      ..close();
    canvas.drawPath(star, Paint()..color = theme.textLight);
  }
}

// ---------------------------------------------------------------------------
// RowIDCell (`row-id-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideRowIdCellRenderer extends GlideCellRenderer {
  const GlideRowIdCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.rowID;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideRowIdCell;
    final theme = args.theme;
    final metrics = args.metrics ?? GlideTextMetrics();
    final painter = metrics.painter(
      cell.data,
      theme.baseTextStyle.copyWith(color: theme.textMedium),
      maxWidth: math.max(1, args.rect.width - theme.cellHorizontalPadding * 2),
      ellipsis: true,
    );
    painter.paint(
      args.canvas,
      Offset(
        args.rect.x + theme.cellHorizontalPadding,
        args.rect.y + args.rect.height / 2 - painter.height / 2,
      ),
    );
  }

  /// `provideEditor` (`row-id-cell.tsx:16-34`). The upstream widget sets
  /// `disabled={value.readonly !== false}`, so the entry is read-only unless
  /// `readonly: false` is passed explicitly.
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    return GlideComponentEditor((props) {
      final value = props.value as GlideRowIdCell;
      return GlideGrowingEntry(
        value: value.data,
        highlight: props.isHighlighted,
        autoFocus: !value.readonly,
        disabled: value.readonly != false,
        validatedSelection: null,
        onChange: (text) => props.onChange(value.copyWith(data: text)),
      );
    });
  }

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) =>
      metrics.width((cell as GlideRowIdCell).data, theme.baseTextStyle) +
      theme.cellHorizontalPadding * 2;

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      (cell as GlideRowIdCell).data;
}

// ---------------------------------------------------------------------------
// MarkdownCell (`markdown-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideMarkdownCellRenderer extends GlideCellRenderer {
  const GlideMarkdownCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.markdown;

  /// Canvas side of the markdown renderer draws the raw text; the rendered
  /// markdown preview lives in the overlay editor upstream (`MarkdownDiv`).
  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideMarkdownCell;
    drawTextCell(args, cell.data, contentAlign: cell.contentAlign);
  }

  /// `provideEditor` (`markdown-cell.tsx:23-44`).
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    return GlideComponentEditor((props) {
      final value = props.value as GlideMarkdownCell;
      return GlideMarkdownOverlayEditor(
        value: value,
        targetWidth: props.target.width,
        forceEditMode: props.forceEditMode,
        validatedSelection: null,
        onChange: (text) => props.onChange(value.copyWith(data: text)),
        onFinishedEditing: (newValue) =>
            props.onFinishedEditing(newValue, null),
      );
    });
  }

  @override
  GlideGridCell? onDelete(GlideGridCell cell) =>
      (cell as GlideMarkdownCell).copyWith(data: '');

  @override
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) {
    final markdown = cell as GlideMarkdownCell;
    if (toPaste == markdown.data) return null;
    return markdown.copyWith(data: toPaste);
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      (cell as GlideMarkdownCell).data;
}

// ---------------------------------------------------------------------------
// UriCell (`uri-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideUriCellRenderer extends GlideCellRenderer {
  const GlideUriCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.uri;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideUriCell;
    final theme = args.theme;
    final metrics = args.metrics ?? GlideTextMetrics();
    final display = cell.displayData ?? cell.data;
    final style = theme.baseTextStyle.copyWith(color: theme.linkColor);
    final painter = metrics.painter(
      display,
      style,
      maxWidth: math.max(1, args.rect.width - theme.cellHorizontalPadding * 2),
      ellipsis: true,
    );
    final dx = switch (cell.contentAlign) {
      GlideContentAlign.right =>
        args.rect.x + args.rect.width - theme.cellHorizontalPadding - painter.width,
      GlideContentAlign.center =>
        args.rect.x + args.rect.width / 2 - painter.width / 2,
      _ => args.rect.x + theme.cellHorizontalPadding,
    };
    final dy = args.rect.y + args.rect.height / 2 - painter.height / 2;
    painter.paint(args.canvas, Offset(dx, dy));
    args.canvas.drawLine(
      Offset(dx, dy + painter.height - 1),
      Offset(dx + painter.width, dy + painter.height - 1),
      Paint()
        ..color = theme.linkColor
        ..strokeWidth = 1,
    );
  }

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) {
    final uri = cell as GlideUriCell;
    return metrics.width(uri.displayData ?? uri.data, theme.baseTextStyle) +
        theme.cellHorizontalPadding * 2;
  }

  /// `provideEditor` (`uri-cell.tsx:130-151`).
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    final uriCell = cell as GlideUriCell;
    return GlideComponentEditor((props) {
      final value = props.value as GlideUriCell;
      return GlideUriOverlayEditor(
        uri: value.data,
        preview: value.displayData ?? value.data,
        readonly: value.readonly,
        forceEditMode: props.forceEditMode ||
            (uriCell.hoverEffect && uriCell.onClickUri != null),
        validatedSelection: null,
        // Upstream writes only `data` (`uri-cell.tsx:146-148`); the preview
        // comes from `displayData`, so it has to follow the edit.
        onChange: (text) =>
            props.onChange(value.copyWith(data: text, displayData: text)),
      );
    });
  }

  @override
  GlideGridCell? onDelete(GlideGridCell cell) =>
      (cell as GlideUriCell).copyWith(data: '', displayData: '');

  @override
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) {
    final uri = cell as GlideUriCell;
    if (toPaste == uri.data) return null;
    return uri.copyWith(
      data: toPaste,
      displayData: details.formattedString ?? uri.displayData,
    );
  }

  @override
  String getAccessibilityString(GlideGridCell cell) =>
      (cell as GlideUriCell).data;
}

// ---------------------------------------------------------------------------
// DrilldownCell (`drilldown-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideDrilldownCellRenderer extends GlideCellRenderer {
  const GlideDrilldownCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.drilldown;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideDrilldownCell;
    final rect = args.rect;
    final theme = args.theme;
    final metrics = args.metrics ?? GlideTextMetrics();
    final canvas = args.canvas;
    var renderX = rect.x + theme.cellHorizontalPadding;

    for (final item in cell.data) {
      if (renderX > rect.x + rect.width) break;
      final textWidth = metrics.width(item.text, theme.baseTextStyle);
      final pillWidth = textWidth + theme.bubblePadding * 2;

      canvas.drawPath(
        roundedRectPath(
          GlideRectangle(
            x: renderX,
            y: rect.y + (rect.height - theme.bubbleHeight) / 2,
            width: pillWidth,
            height: theme.bubbleHeight,
          ),
          theme.roundingRadius ?? theme.bubbleHeight / 2,
        ),
        Paint()..color = theme.bgBubble,
      );
      canvas.drawPath(
        roundedRectPath(
          GlideRectangle(
            x: renderX,
            y: rect.y + (rect.height - theme.bubbleHeight) / 2,
            width: pillWidth,
            height: theme.bubbleHeight,
          ),
          theme.roundingRadius ?? theme.bubbleHeight / 2,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = theme.drilldownBorder,
      );
      final painter = metrics.painter(
        item.text,
        theme.baseTextStyle.copyWith(color: theme.textBubble),
      );
      painter.paint(
        canvas,
        Offset(
          renderX + theme.bubblePadding,
          rect.y + rect.height / 2 - painter.height / 2,
        ),
      );
      renderX += pillWidth + theme.bubbleMargin;
    }
  }

  /// `provideEditor` (`drilldown-cell.tsx:33-36`).
  @override
  GlideEditorProvider? provideEditor(GlideGridCell cell, GlideItem location) {
    return GlideComponentEditor((props) {
      final value = props.value as GlideDrilldownCell;
      return GlideDrilldownOverlayEditor(
        drilldowns: value.data,
        theme: props.theme,
      );
    });
  }

  @override
  double? measure(
    GlideGridCell cell,
    GlideTheme theme,
    GlideTextMetrics metrics,
  ) {
    final drilldown = cell as GlideDrilldownCell;
    var width = 0.0;
    for (final item in drilldown.data) {
      width +=
          metrics.width(item.text, theme.baseTextStyle) +
          theme.bubblePadding * 2 +
          theme.bubbleMargin;
    }
    return width + 2 * theme.cellHorizontalPadding - theme.bubbleMargin;
  }

  @override
  String getAccessibilityString(GlideGridCell cell) => (cell as GlideDrilldownCell)
      .data
      .map((d) => d.text)
      .join(', ');
}

// ---------------------------------------------------------------------------
// MarkerCell (`marker-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideMarkerCellRenderer extends GlideCellRenderer {
  const GlideMarkerCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.marker;

  @override
  bool get needsHover => true;

  @override
  bool get needsHoverPosition => true;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideMarkerCell;
    final rect = args.rect;
    final theme = args.theme;
    final canvas = args.canvas;

    final drawCheckbox =
        cell.markerKind == GlideMarkerKind.checkbox ||
        cell.markerKind == GlideMarkerKind.both ||
        (cell.markerKind == GlideMarkerKind.checkboxVisible &&
            args.hoverAmount > 0);
    final drawNumber =
        cell.markerKind == GlideMarkerKind.number ||
        cell.markerKind == GlideMarkerKind.both;

    if (drawCheckbox) {
      drawCheckboxShape(
        canvas,
        theme,
        cell.checked,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        style: cell.checkboxStyle,
        highlighted: args.highlighted,
        hoverX: args.hoverX ?? -20,
        hoverY: args.hoverY ?? -20,
      );
    } else if (drawNumber) {
      final metrics = args.metrics ?? GlideTextMetrics();
      // `const text = index.toString()` (`marker-cell.tsx:106`) where
      // `index` is `cell.row`, already offset by `rowMarkerStartIndex`.
      final painter = metrics.painter(
        '${cell.row}',
        theme.markerTextStyle.copyWith(color: theme.textMedium),
      );
      painter.paint(
        canvas,
        Offset(
          rect.x + rect.width / 2 - painter.width / 2,
          rect.y + rect.height / 2 - painter.height / 2,
        ),
      );
    }
  }
}

/// Shared box drawing used by both the boolean cell and the marker cell; keeps
/// `drawCheckbox`'s import in this file explicit.
void drawCheckboxShape(
  Canvas canvas,
  GlideTheme theme,
  GlideBooleanValue checked,
  double x,
  double y,
  double width,
  double height, {
  GlideMarkerCheckboxStyle style = GlideMarkerCheckboxStyle.square,
  bool highlighted = false,
  double hoverX = -20,
  double hoverY = -20,
}) => drawCheckbox(
  canvas,
  theme,
  checked,
  x,
  y,
  width,
  height,
  style: style,
  highlighted: highlighted,
  hoverX: hoverX,
  hoverY: hoverY,
);

/// `getSquareXPosFromAlign` is also used by the marker's hit test.
bool isOverMarkerCheckbox({
  required GlideMarkerCell cell,
  required double posX,
  required double posY,
  required GlideRectangle bounds,
  required GlideTheme theme,
}) {
  final width = bounds.width;
  final height = bounds.height;
  final maxWidth = theme.checkboxMaxSize;
  final checkBoxWidth = getSquareWidth(
    maxWidth,
    height,
    theme.cellVerticalPadding,
  );
  final x = getSquareXPosFromAlign(
    GlideContentAlign.center,
    bounds.x,
    width,
    theme.cellHorizontalPadding,
    checkBoxWidth,
  );
  final bb = getSquareBb(x, (bounds.y + height / 2).floorToDouble(), checkBoxWidth);
  return pointIsWithinBb(bounds.x + posX, bounds.y + posY, bb);
}

// ---------------------------------------------------------------------------
// NewRowCell (`new-row-cell.tsx`)
// ---------------------------------------------------------------------------

class GlideNewRowCellRenderer extends GlideCellRenderer {
  const GlideNewRowCellRenderer();

  @override
  GlideCellKind get kind => GlideCellKind.newRow;

  @override
  void draw(GlideDrawCellArgs args) {
    final cell = args.cell as GlideNewRowCell;
    final rect = args.rect;
    final theme = args.theme;
    final metrics = args.metrics ?? GlideTextMetrics();

    // `+` glyph stands in for the add icon until the sprite system is ported.
    final plus = metrics.painter(
      '+',
      theme.baseTextStyle.copyWith(color: theme.textMedium),
    );
    var x = rect.x + theme.cellHorizontalPadding;
    plus.paint(args.canvas, Offset(x, rect.y + rect.height / 2 - plus.height / 2));
    x += plus.width + 6;

    final hint = metrics.painter(
      cell.hint,
      theme.baseTextStyle.copyWith(color: theme.textLight),
      maxWidth: math.max(1, rect.right - theme.cellHorizontalPadding - x),
      ellipsis: true,
    );
    hint.paint(args.canvas, Offset(x, rect.y + rect.height / 2 - hint.height / 2));
  }
}
