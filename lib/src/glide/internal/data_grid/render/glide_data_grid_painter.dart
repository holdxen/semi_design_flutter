// Port of `packages/core/src/internal/data-grid/render/data-grid-render.ts`,
// `data-grid-render.cells.ts` and `data-grid-render.lines.ts` for a Flutter
// `CustomPainter`.
//
// What changes versus the Web version:
// - No `canvas.width = w * dpr` dance: the framework owns the surface and the
//   canvas already works in logical pixels.
// - No blit / double buffering: `CustomPainter` is recorded into a `Picture`
//   and Flutter's raster cache handles the reuse. `canBlit` therefore only
//   gates `shouldRepaint` (see [GlideDataGridPainter._argEquals]).
// - The `PrepResult` font/fill-style reuse chain is unnecessary because
//   `TextPainter` bakes the style into its layout; the text cache in
//   [GlideTextMetrics] does that job.
// - Damage still short-circuits cells, matching the `damage` fast path.
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../cells/glide_cell_types.dart';
import 'glide_draw_grid_arg.dart';
import 'glide_render_walk.dart';

/// `drawGrid` (`data-grid-render.ts:115-797`).
class GlideDataGridPainter extends CustomPainter {
  GlideDataGridPainter(this.arg, {super.repaint});

  final GlideDrawGridArg arg;

  @override
  void paint(Canvas canvas, Size size) {
    final a = arg;
    if (a.width == 0 || a.height == 0) return;

    final totalHeaderHeight = a.enableGroups
        ? a.groupHeaderHeight + a.headerHeight
        : a.headerHeight;
    final effectiveCols = getEffectiveColumns(
      a.mappedColumns,
      a.cellXOffset,
      a.width,
      null,
      a.translateX,
    );
    if (effectiveCols.isEmpty) return;

    // Stage 13: background. Full-viewport fill; the damage path repaints the
    // damaged cells on top of it.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, a.width, a.height),
      Paint()..color = a.theme.bgCell,
    );

    // Stage 14-16: cells, blanks, grid lines.
    final spans = _drawCells(canvas, effectiveCols, totalHeaderHeight);
    _drawGridLines(canvas, effectiveCols, spans, totalHeaderHeight);

    // Stage 9: header (drawn after the body so the sticky header always wins).
    _drawGridHeaders(canvas, effectiveCols, totalHeaderHeight);

    // Stage 12/16: rings and fill handle are painted last so blitting (here:
    // clipping) cannot eat their right/bottom edge.
    _drawFocusRing(canvas);
    _drawHighlightRings(canvas);
    _drawFillHandle(canvas);

    // Stage 17: column resize indicator.
    if (a.enableGroups) {
      _drawGroupHeaderSeparator(canvas);
    }
  }

  // -------------------------------------------------------------------------
  // drawCells (`data-grid-render.cells.ts:75-456`)
  // -------------------------------------------------------------------------

  List<GlideRectangle>? _drawCells(
    Canvas canvas,
    List<GlideMappedColumn> effectiveColumns,
    double totalHeaderHeight,
  ) {
    final a = arg;
    final damage = a.damage;
    final drawRegions = const <GlideRectangle>[];
    final skipPoint = getSkipPoint(drawRegions);
    final handledSpans = <String>{};
    List<GlideRectangle>? result;

    walkColumns(
      effectiveCols: effectiveColumns,
      cellYOffset: a.cellYOffset,
      translateX: a.translateX,
      translateY: a.translateY,
      totalHeaderHeight: totalHeaderHeight,
      cb: (c, drawX, colDrawStartY, clipX, startRow) {
        final diff = math.max(0.0, clipX - drawX);
        final colDrawX = drawX + diff;
        final colDrawY = totalHeaderHeight + 1;
        final colWidth = c.width - diff;
        final colHeight = a.height - totalHeaderHeight - 1;
        if (colWidth <= 0 || colHeight <= 0) return null;

        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(colDrawX, colDrawY, colWidth, colHeight),
        );

        final colSelected = a.selection.columns.hasIndex(c.sourceIndex);
        final groupDetails = a.getGroupDetails;
        final groupTheme = groupDetails == null
            ? null
            : groupDetails(c.group ?? '').overrideTheme;
        final colTheme =
            c.themeOverride == null && groupTheme == null
            ? a.theme
            : a.theme.merge([_realize(groupTheme), _realize(c.themeOverride)]);

        walkRowsInCol(
          startRow: startRow,
          drawY: colDrawStartY,
          height: a.height,
          rows: a.rows,
          getRowHeight: a.rowHeight,
          freezeTrailingRows: a.freezeTrailingRows,
          hasAppendRow: a.hasAppendRow,
          skipToY: skipPoint,
          cb: (drawY, row, rh, isSticky, isTrailingRow) {
            if (row < 0) return null;

            if (damage != null && !damage.hasAt(c.sourceIndex, row)) {
              return null;
            }

            final rowSelected = a.selection.rows.hasIndex(row);
            final rowDisabled = a.disabledRows.hasIndex(row);
            final cell = row < a.rows
                ? a.getCellContent(GlideItem(c.sourceIndex, row))
                : const GlideLoadingCell();

            var cellX = drawX;
            var cellWidth = c.width;
            var drawingSpan = false;
            var skipContents = false;

            final span = cell.span;
            if (span != null) {
              final spanKey =
                  '$row,${span.start},${span.end},${c.sticky}';
              if (!handledSpans.contains(spanKey)) {
                final areas = getSpanBounds(
                  span: span,
                  cellX: drawX,
                  cellY: drawY,
                  cellW: c.width,
                  cellH: rh,
                  column: c,
                  allColumns: a.mappedColumns,
                );
                final area = c.sticky ? areas.$1 : areas.$2;
                if (!c.sticky && areas.$1 != null) skipContents = true;
                if (area != null) {
                  cellX = area.x;
                  cellWidth = area.width;
                  handledSpans.add(spanKey);
                  canvas.restore();
                  canvas.save();
                  final d = math.max(0.0, clipX - area.x);
                  canvas.clipRect(
                    Rect.fromLTWH(area.x + d, drawY, area.width - d, rh),
                  );
                  (result ??= []).add(
                    GlideRectangle(
                      x: area.x + d,
                      y: drawY,
                      width: area.width - d,
                      height: rh,
                    ),
                  );
                  drawingSpan = true;
                }
              } else {
                return null;
              }
            }

            final rowTheme = a.getRowThemeOverride?.call(row);
            final trailingTheme = isTrailingRow
                ? c.trailingRowOptions?.themeOverride
                : null;
            final theme =
                cell.themeOverride == null &&
                    rowTheme == null &&
                    trailingTheme == null
                ? colTheme
                : colTheme.merge([
                    _realize(rowTheme),
                    _realize(trailingTheme),
                    _realize(cell.themeOverride),
                  ]);

            final cellIndex = GlideItem(c.sourceIndex, row);
            final isSelected = cellIsSelected(cellIndex, cell, a.selection);
            var accentCount = cellIsInRange(
              cellIndex,
              cell,
              a.selection,
              a.drawFocus,
            );
            final spanIsHighlighted = span != null &&
                a.selection.columns.some(
                  (index) => index >= span.start && index <= span.end,
                );
            if (isSelected && !a.isFocused && a.drawFocus) {
              accentCount = 0;
            } else if (isSelected && a.drawFocus) {
              accentCount = math.max(accentCount, 1);
            }
            if (spanIsHighlighted) accentCount++;
            if (!isSelected) {
              if (rowSelected) accentCount++;
              if (colSelected && !isTrailingRow) accentCount++;
            }

            final bgCell = cell.kind == GlideCellKind.protected
                ? theme.bgCellMedium
                : theme.bgCell;
            var fill = bgCell;

            if (accentCount > 0 || rowDisabled) {
              if (rowDisabled) {
                fill = Color.alphaBlend(theme.bgHeader, fill);
              }
              for (var i = 0; i < accentCount; i++) {
                fill = Color.alphaBlend(theme.accentLight, fill);
              }
            } else if (a.prelightCells != null) {
              for (final pre in a.prelightCells!) {
                if (pre.col == c.sourceIndex && pre.row == row) {
                  fill = Color.alphaBlend(theme.bgSearchResult, fill);
                  break;
                }
              }
            }

            final highlights = a.highlightRegions;
            if (highlights != null) {
              for (final region in highlights) {
                final r = region.range;
                if (region.style != GlideHighlightStyle.solidOutline &&
                    r.x <= c.sourceIndex &&
                    c.sourceIndex < r.x + r.width &&
                    r.y <= row &&
                    row < r.y + r.height) {
                  fill = Color.alphaBlend(region.color, fill);
                }
              }
            }

            final cellRect = GlideRectangle(
              x: cellX,
              y: drawY,
              width: cellWidth,
              height: rh,
            );
            canvas.drawRect(
              Rect.fromLTWH(cellX, drawY, cellWidth, rh),
              Paint()..color = fill,
            );

            final faded = cell.style == GlideCellStyle.faded;
            if (faded) {
              canvas.saveLayer(
                Rect.fromLTWH(cellX, drawY, cellWidth, rh),
                Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6),
              );
            }

            if (cellWidth > a.minimumCellWidth && !skipContents) {
              final hoverValue = a.hoverValues[cellIndex] ?? 0;
              final hoverInfo = a.hoverInfo;
              final hoverPosition = a.hoverPosition;
              _drawCell(
                canvas,
                cell: cell,
                col: c.sourceIndex,
                row: row,
                rect: cellRect,
                highlighted: accentCount > 0,
                theme: theme,
                fill: fill,
                hoverAmount: hoverValue,
                hoverX: hoverInfo == cellIndex ? hoverPosition?.dx : null,
                hoverY: hoverInfo == cellIndex ? hoverPosition?.dy : null,
              );
            }

            if (faded) canvas.restore();

            if (drawingSpan) {
              canvas.restore();
              canvas.save();
              canvas.clipRect(
                Rect.fromLTWH(colDrawX, colDrawY, colWidth, colHeight),
              );
            }

            return null;
          },
        );

        canvas.restore();
        return null;
      },
    );

    return result;
  }

  /// `drawCell` (`data-grid-render.cells.ts:467-563`).
  void _drawCell(
    Canvas canvas, {
    required GlideGridCell cell,
    required int col,
    required int row,
    required GlideRectangle rect,
    required bool highlighted,
    required GlideTheme theme,
    required Color fill,
    required double hoverAmount,
    double? hoverX,
    double? hoverY,
  }) {
    final renderer = arg.getCellRenderer(cell);
    if (renderer == null) return;

    // `drawLastUpdateUnderlay` (`data-grid-lib.ts:401-428`).
    final lastUpdated = cell.lastUpdated;
    if (lastUpdated != null) {
      final progress = arg.frameTime - lastUpdated;
      if (progress < lastUpdateAnimationMs) {
        final fade = 1 - progress / lastUpdateAnimationMs;
        canvas.drawRect(
          Rect.fromLTWH(rect.x + 1, rect.y + 1, rect.width - 1, rect.height - 1),
          Paint()..color = theme.bgSearchResult.withValues(alpha: fade),
        );
      } else if (arg.enqueue != null) {
        arg.enqueue!(GlideItem(col, row));
      }
    }

    final item = GlideItem(col, row);
    final args = GlideDrawCellArgs(
      canvas: canvas,
      theme: theme,
      col: col,
      row: row,
      rect: rect,
      cell: cell,
      highlighted: highlighted,
      hoverAmount: hoverAmount,
      hoverX: hoverX,
      hoverY: hoverY,
      cellFillColor: fill,
      hyperWrapping: arg.hyperWrapping,
      frameTime: arg.frameTime,
      metrics: arg.metrics,
      requestAnimationFrame: arg.enqueue == null
          ? null
          : ([state]) => arg.enqueue!(item),
    );

    renderer.draw(args);
  }

  // -------------------------------------------------------------------------
  // drawGridLines (`data-grid-render.lines.ts:279-379`)
  // -------------------------------------------------------------------------

  void _drawGridLines(
    Canvas canvas,
    List<GlideMappedColumn> effectiveCols,
    List<GlideRectangle>? spans,
    double totalHeaderHeight,
  ) {
    final a = arg;
    final theme = a.theme;

    if (spans != null && spans.isNotEmpty) {
      final clip = Path()..fillType = PathFillType.evenOdd;
      clip.addRect(Rect.fromLTWH(0, 0, a.width, a.height));
      for (final span in spans) {
        clip.addRect(
          Rect.fromLTWH(
            span.x + 1,
            span.y + 1,
            span.width - 1,
            span.height - 1,
          ),
        );
      }
      canvas.save();
      canvas.clipPath(clip);
    }

    final hColor = theme.horizontalBorderColor ?? theme.borderColor;
    final vColor = theme.borderColor;

    // Vertical lines: `x` starts at 0.5 and accumulates column widths.
    var x = 0.5;
    for (var index = 0; index < effectiveCols.length; index++) {
      final c = effectiveCols[index];
      if (c.width == 0) continue;
      x += c.width;
      final tx = c.sticky ? x : x + a.translateX;
      if (a.verticalBorder(index + 1)) {
        canvas.drawLine(
          Offset(tx, math.max(a.groupHeaderHeight, 0)),
          Offset(tx, a.height),
          Paint()
            ..color = vColor
            ..strokeWidth = 1,
        );
      }
    }

    var freezeY = a.height + 0.5;
    for (
      var i = a.rows - a.freezeTrailingRows;
      i < a.rows;
      i++
    ) {
      final rh = a.rowHeight(i);
      freezeY -= rh;
      canvas.drawLine(
        Offset(0, freezeY),
        Offset(a.width, freezeY),
        Paint()
          ..color = hColor
          ..strokeWidth = 1,
      );
    }

    var y = totalHeaderHeight + 0.5;
    var row = a.cellYOffset;
    while (y + a.translateY < freezeY) {
      final ty = y + a.translateY;
      final rowTheme = a.getRowThemeOverride?.call(row);
      canvas.drawLine(
        Offset(0, ty),
        Offset(a.width, ty),
        Paint()
          ..color =
              rowTheme?.horizontalBorderColor ??
              rowTheme?.borderColor ??
              hColor
          ..strokeWidth = 1,
      );
      y += a.rowHeight(row);
      row++;
    }

    if (spans != null && spans.isNotEmpty) canvas.restore();

    // `overdrawStickyBoundaries` (`lines.ts:107-147`).
    _overdrawStickyBoundaries(canvas, effectiveCols, totalHeaderHeight);
  }

  void _overdrawStickyBoundaries(
    Canvas canvas,
    List<GlideMappedColumn> effectiveCols,
    double totalHeaderHeight,
  ) {
    final a = arg;
    var drawFreezeBorder = false;
    for (final c in effectiveCols) {
      if (c.sticky) continue;
      drawFreezeBorder = a.verticalBorder(c.sourceIndex);
      break;
    }
    final hColor = a.theme.horizontalBorderColor ?? a.theme.borderColor;
    final drawX = drawFreezeBorder ? getStickyWidth(effectiveCols) : 0.0;

    final vPaint = Paint()
      ..color = Color.alphaBlend(a.theme.borderColor, a.theme.bgCell)
      ..strokeWidth = 1;

    if (drawX != 0) {
      canvas.drawLine(
        Offset(drawX + 0.5, 0),
        Offset(drawX + 0.5, a.height),
        vPaint,
      );
    }

    if (a.freezeTrailingRows > 0) {
      final h = a.rowHeight.trailingHeight(a.rows, a.freezeTrailingRows);
      canvas.drawLine(
        Offset(0, a.height - h + 0.5),
        Offset(a.width, a.height - h + 0.5),
        Paint()
          ..color = Color.alphaBlend(hColor, a.theme.bgCell)
          ..strokeWidth = 1,
      );
    }
  }

  // -------------------------------------------------------------------------
  // drawGridHeaders (`data-grid-render.header.ts`)
  // -------------------------------------------------------------------------

  void _drawGridHeaders(
    Canvas canvas,
    List<GlideMappedColumn> effectiveCols,
    double totalHeaderHeight,
  ) {
    final a = arg;
    final theme = a.theme;
    final headerTop = a.enableGroups ? a.groupHeaderHeight : 0.0;

    // Header background + titles.
    walkColumns(
      effectiveCols: effectiveCols,
      cellYOffset: a.cellYOffset,
      translateX: a.translateX,
      translateY: 0,
      totalHeaderHeight: 0,
      cb: (c, drawX, _, clipX, _) {
        final hovered = a.hoverInfo == GlideItem(c.sourceIndex, GlideItem.headerRow);
        final selected = a.selection.columns.hasIndex(c.sourceIndex);

        var bg = theme.bgHeader;
        if (a.isFocused && selected) {
          bg = theme.bgHeaderHasFocus;
        } else if (hovered) {
          bg = theme.bgHeaderHovered;
        }
        if (selected) bg = Color.alphaBlend(theme.accentLight, bg);

        final rect = Rect.fromLTWH(
          drawX,
          headerTop,
          c.width,
          totalHeaderHeight - headerTop,
        );
        canvas.drawRect(rect, Paint()..color = bg);

        final style = theme.headerTextStyle.copyWith(
          color: selected ? theme.textHeader : theme.textHeader,
        );
        final available = math.max(
          1.0,
          c.width -
              theme.cellHorizontalPadding * 2 -
              (c.hasMenu ? theme.headerIconSize : 0),
        );
        final painter = a.metrics.painter(
          c.title,
          style,
          maxWidth: available,
          ellipsis: true,
        );
        painter.paint(
          canvas,
          Offset(
            drawX + theme.cellHorizontalPadding,
            headerTop +
                (totalHeaderHeight - headerTop) / 2 -
                painter.height / 2,
          ),
        );

        // Upstream draws a 2px accent underline on the focused/selected column
        // header (`header.ts`).
        if (selected) {
          canvas.drawRect(
            Rect.fromLTWH(
              drawX,
              totalHeaderHeight - 2,
              c.width,
              2,
            ),
            Paint()..color = theme.accentColor,
          );
        }
        return null;
      },
    );

    // Group header.
    if (a.enableGroups) {
      walkGroups(
        effectiveCols: effectiveCols,
        width: a.width,
        translateX: a.translateX,
        groupHeaderHeight: a.groupHeaderHeight,
        cb: (colSpan, group, x, y, w, h) {
          if (group.isEmpty) return;
          canvas.drawRect(
            Rect.fromLTWH(x, 0, w, h),
            Paint()..color = theme.bgGroupHeader ?? theme.bgHeader,
          );
          final painter = a.metrics.painter(
            group,
            theme.headerTextStyle.copyWith(
              color: theme.textGroupHeader ?? theme.textHeader,
            ),
            maxWidth: math.max(1.0, w - theme.cellHorizontalPadding * 2),
            ellipsis: true,
          );
          painter.paint(
            canvas,
            Offset(
              x + (w - painter.width) / 2,
              h / 2 - painter.height / 2,
            ),
          );
        },
      );
    }

    // Header bottom border (`render.ts:314-321`).
    canvas.drawLine(
      Offset(0, totalHeaderHeight - 0.5),
      Offset(a.width, totalHeaderHeight - 0.5),
      Paint()
        ..color = Color.alphaBlend(
          theme.headerBottomBorderColor ??
              theme.horizontalBorderColor ??
              theme.borderColor,
          theme.bgHeader,
        )
        ..strokeWidth = 1,
    );
  }

  void _drawGroupHeaderSeparator(Canvas canvas) {
    final theme = arg.theme;
    canvas.drawLine(
      Offset(0, arg.groupHeaderHeight - 0.5),
      Offset(arg.width, arg.groupHeaderHeight - 0.5),
      Paint()
        ..color = Color.alphaBlend(theme.borderColor, theme.bgHeader)
        ..strokeWidth = 1,
    );
  }

  // -------------------------------------------------------------------------
  // Focus ring / highlights / fill handle
  // -------------------------------------------------------------------------

  GlideRectangle _boundsForRange(GlideRectangle range) {
    final a = arg;
    final topLeft = computeBounds(
      col: range.x.toInt(),
      row: range.y.toInt(),
      width: a.width,
      height: a.height,
      groupHeaderHeight: a.groupHeaderHeight,
      totalHeaderHeight: a.enableGroups
          ? a.headerHeight + a.groupHeaderHeight
          : a.headerHeight,
      cellXOffset: a.cellXOffset,
      cellYOffset: a.cellYOffset,
      translateX: a.translateX,
      translateY: a.translateY,
      rows: a.rows,
      freezeColumns: a.freezeColumns,
      freezeTrailingRows: a.freezeTrailingRows,
      mappedColumns: a.mappedColumns,
      rowHeight: a.rowHeight,
    );
    final bottomRight = computeBounds(
      col: (range.x + range.width - 1).toInt(),
      row: (range.y + range.height - 1).toInt(),
      width: a.width,
      height: a.height,
      groupHeaderHeight: a.groupHeaderHeight,
      totalHeaderHeight: a.enableGroups
          ? a.headerHeight + a.groupHeaderHeight
          : a.headerHeight,
      cellXOffset: a.cellXOffset,
      cellYOffset: a.cellYOffset,
      translateX: a.translateX,
      translateY: a.translateY,
      rows: a.rows,
      freezeColumns: a.freezeColumns,
      freezeTrailingRows: a.freezeTrailingRows,
      mappedColumns: a.mappedColumns,
      rowHeight: a.rowHeight,
    );
    if (topLeft.width == 0 || bottomRight.width == 0) {
      return GlideRectangle.empty();
    }
    return GlideRectangle(
      x: topLeft.x,
      y: topLeft.y,
      width: bottomRight.x + bottomRight.width - topLeft.x,
      height: bottomRight.y + bottomRight.height - topLeft.y,
    );
  }

  /// `drawFocusRing` (`data-grid-render.rings.ts`).
  void _drawFocusRing(Canvas canvas) {
    final a = arg;
    final current = a.selection.current;
    if (current == null || !a.drawFocus || !a.isFocused) return;

    for (final range in current.rangeStack) {
      final bounds = _boundsForRange(range);
      if (bounds.width == 0) continue;
      _strokeRing(canvas, bounds, a.theme.accentLight, 1);
    }

    final bounds = _boundsForRange(current.range);
    if (bounds.width == 0) return;
    _strokeRing(canvas, bounds, a.theme.accentColor, 2);

    // Inner hairline keeps the ring readable over the accent fill.
    _strokeRing(canvas, bounds.inflate(-1, -1), a.theme.bgCell, 1);
  }

  void _strokeRing(
    Canvas canvas,
    GlideRectangle bounds,
    Color color,
    double width,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(
        bounds.x + 1,
        bounds.y + 1,
        math.max(0, bounds.width - 2),
        math.max(0, bounds.height - 2),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  /// `drawHighlightRings` (`data-grid-render.rings.ts`).
  void _drawHighlightRings(Canvas canvas) {
    final regions = arg.highlightRegions;
    if (regions == null) return;
    for (final region in regions) {
      if (region.style == GlideHighlightStyle.noOutline) continue;
      final bounds = _boundsForRange(region.range);
      if (bounds.width == 0) continue;
      final rect = Rect.fromLTWH(
        bounds.x + 1,
        bounds.y + 1,
        bounds.width - 2,
        bounds.height - 2,
      );
      if (region.style == GlideHighlightStyle.dashedOutline) {
        _strokeDashedRect(canvas, rect, region.color, 2);
      } else {
        canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = region.color,
        );
      }
    }
  }

  /// Canvas 2D has a `setLineDash` Flutter's `Paint` does not, so the dash is
  /// cut out of the outline with `PathMetrics` — the same reason upstream's
  /// `hugRectToTarget` exists (dashed outlines must stay cheap).
  void _strokeDashedRect(
    Canvas canvas,
    Rect rect,
    Color color,
    double width, {
    double dash = 6,
    double gap = 4,
  }) {
    final path = Path()..addRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  /// `drawFillHandle` (`data-grid-render.ts` / `data-grid-render.rings.ts`).
  void _drawFillHandle(Canvas canvas) {
    final a = arg;
    final config = a.fillHandle;
    final current = a.selection.current;
    if (config == null || current == null || !a.drawFocus) return;

    final bounds = _boundsForRange(current.range);
    if (bounds.width == 0) return;

    final cfg = config;
    final size = cfg.size;
    final x = bounds.x + bounds.width + cfg.offsetX - size / 2;
    final y = bounds.y + bounds.height + cfg.offsetY - size / 2;
    final rect = Rect.fromLTWH(x, y, size, size);
    final radius = cfg.shape == GlideFillHandleShape.circle ? size / 2 : 0.0;

    final path = radius == 0
        ? (Path()..addRect(rect))
        : (Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))));

    canvas.drawPath(path, Paint()..color = a.theme.bgCell);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = a.theme.accentColor,
    );
  }

  GlideTheme? _realize(GlideThemeOverride? override) => override?.applyTo(arg.theme);

  @override
  bool shouldRepaint(GlideDataGridPainter oldDelegate) =>
      !_argEquals(oldDelegate.arg, arg);

  /// The Web equivalent is `computeCanBlit` (`data-grid-render.blit.ts:233`):
  /// if none of these change, the frame is identical and can be reused.
  bool _argEquals(GlideDrawGridArg a, GlideDrawGridArg b) {
    if (identical(a, b)) return true;
    return a.width == b.width &&
        a.height == b.height &&
        a.headerHeight == b.headerHeight &&
        a.groupHeaderHeight == b.groupHeaderHeight &&
        a.enableGroups == b.enableGroups &&
        a.cellXOffset == b.cellXOffset &&
        a.cellYOffset == b.cellYOffset &&
        a.translateX == b.translateX &&
        a.translateY == b.translateY &&
        identical(a.mappedColumns, b.mappedColumns) &&
        a.freezeColumns == b.freezeColumns &&
        a.freezeTrailingRows == b.freezeTrailingRows &&
        a.rows == b.rows &&
        a.rowHeight == b.rowHeight &&
        a.theme == b.theme &&
        a.selection == b.selection &&
        a.isFocused == b.isFocused &&
        a.drawFocus == b.drawFocus &&
        a.getCellContent == b.getCellContent &&
        a.getRowThemeOverride == b.getRowThemeOverride &&
        identical(a.hoverValues, b.hoverValues) &&
        a.hoverInfo == b.hoverInfo &&
        a.hoverPosition == b.hoverPosition &&
        identical(a.damage, b.damage) &&
        a.hasAppendRow == b.hasAppendRow &&
        a.fillHandle?.size == b.fillHandle?.size &&
        a.disabledRows == b.disabledRows &&
        identical(a.prelightCells, b.prelightCells) &&
        identical(a.highlightRegions, b.highlightRegions);
  }
}
