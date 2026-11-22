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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../cells/glide_cell_types.dart';
import '../../../common/glide_math.dart';
import '../../../common/glide_utils.dart';
import 'glide_draw_checkbox.dart';
import 'glide_draw_grid_arg.dart';
import '../glide_sprite_manager.dart';
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
      a.dragAndDropState,
      a.translateX,
    );
    if (effectiveCols.isEmpty) return;

    // Stage 13: background. Full-viewport fill; the damage path repaints the
    // damaged cells on top of it.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, a.width, a.height),
      Paint()..color = a.theme.bgCell,
    );

    // `ctx.fillStyle = outerTheme.bgHeader; ctx.fillRect(0, 0, width,
    // totalHeaderHeight)` (`data-grid-render.header.ts:47-48`): the strip
    // behind every header cell. It goes here rather than inside
    // `_drawGridHeaders` only because that runs after the grid lines and
    // would erase them; nothing paints into this band before this point.
    if (totalHeaderHeight > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, a.width, totalHeaderHeight),
        Paint()..color = a.theme.bgHeader,
      );
    }

    // Stage 14-16: cells, blanks, grid lines.
    // `const frameTime = performance.now()` (`data-grid-render.cells.ts:113`):
    // a fresh clock per paint, so a `lastUpdated` flash actually advances.
    // It used to arrive as a prop that nobody ever set, i.e. always 0.
    final frameTime = DateTime.now().millisecondsSinceEpoch;
    final spans = _drawCells(canvas, effectiveCols, totalHeaderHeight, frameTime);
    _drawGridLines(canvas, effectiveCols, spans, totalHeaderHeight);

    // Stage 9: header (drawn after the body so the sticky header always wins).
    _drawGridHeaders(canvas, effectiveCols, totalHeaderHeight);

    // Stage 12/16: rings and fill handle are painted last so blitting (here:
    // clipping) cannot eat their right/bottom edge.
    _drawFocusRing(canvas);
    _drawHighlightRings(canvas);
    _drawFillHandle(canvas);

    // Stage 17: group separator, then the column resize indicator.
    if (a.enableGroups) {
      _drawGroupHeaderSeparator(canvas);
    }
    if (a.isResizing && a.resizeIndicator != GlideResizeIndicator.none) {
      _drawColumnResizeIndicator(canvas, effectiveCols, totalHeaderHeight);
    }

    // Stage 18: the frozen-edge shadows. Upstream renders these as two DOM
    // overlays on top of the canvas (`data-grid.tsx:1884-1917`), so they go
    // last here too.
    _drawStickyShadows(canvas, effectiveCols, totalHeaderHeight);
  }

  /// `stickyShadow` (`data-grid.tsx:1878-1917`): an inset shadow on the
  /// right of the frozen columns and one under the header, both fading in
  /// with scroll. Nothing is drawn when both opacities are 0, which is the
  /// upstream `if (!opacityX && !opacityY) return null`.
  void _drawStickyShadows(
    Canvas canvas,
    List<GlideMappedColumn> effectiveCols,
    double totalHeaderHeight,
  ) {
    final a = arg;
    final opacityX = glideStickyShadowOpacityX(
      freezeColumns: a.freezeColumns,
      cellXOffset: a.cellXOffset,
      translateX: a.translateX,
      fixedShadowX: a.fixedShadowX,
    );
    final opacityY = glideStickyShadowOpacityY(
      cellYOffset: a.cellYOffset,
      translateY: a.translateY,
      rowHeight: a.rowHeight(a.cellYOffset),
      fixedShadowY: a.fixedShadowY,
    );
    if (opacityX <= 0 && opacityY <= 0) return;

    if (opacityX > 0) {
      // `left: stickyX; width: width - stickyX; height: height` (`:1890-1894`).
      final stickyX = getStickyWidth(effectiveCols);
      _drawInsetShadow(
        canvas,
        Rect.fromLTWH(stickyX, 0, a.width - stickyX, a.height),
        dx: 13,
        dy: 0,
        opacity: opacityX,
      );
    }

    if (opacityY > 0) {
      // `top: totalHeaderHeight; height: height` (`:1901-1905`). Upstream's
      // box runs past the bottom of the grid and is clipped by its container;
      // clipping to the grid here gives the same visible bands.
      _drawInsetShadow(
        canvas,
        Rect.fromLTWH(
          0,
          totalHeaderHeight,
          a.width,
          a.height - totalHeaderHeight,
        ),
        dx: 0,
        dy: 13,
        opacity: opacityY,
      );
    }
  }

  /// `box-shadow: inset 13px 0 10px -13px rgba(0,0,0,0.2)`
  /// (`data-grid.tsx:1897`, `:1910`), and the vertical twin with the axes
  /// swapped. The layer keeps the `dstOut` erase from eating the grid that is
  /// already on the canvas.
  void _drawInsetShadow(
    Canvas canvas,
    Rect box, {
    required double dx,
    required double dy,
    required double opacity,
  }) {
    const spread = -13.0;
    if (box.width <= 0 || box.height <= 0) return;
    final inner = Rect.fromLTWH(
      box.left - spread + dx,
      box.top - spread + dy,
      box.width + 2 * spread,
      box.height + 2 * spread,
    );
    if (inner.width <= 0 || inner.height <= 0) return;

    canvas.saveLayer(box, Paint());
    canvas.clipRect(box);
    canvas.drawRect(
      box,
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.2 * opacity),
    );
    canvas.drawRect(
      inner,
      Paint()
        ..color = const Color(0xFF000000)
        ..blendMode = BlendMode.dstOut
        // CSS `blur-radius: 10` is a sigma of 5 (the spec defines radius as
        // twice the standard deviation).
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();
  }

  // -------------------------------------------------------------------------
  // drawCells (`data-grid-render.cells.ts:75-456`)
  // -------------------------------------------------------------------------

  List<GlideRectangle>? _drawCells(
    Canvas canvas,
    List<GlideMappedColumn> effectiveColumns,
    double totalHeaderHeight,
    int frameTime,
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
        canvas.clipRect(Rect.fromLTWH(colDrawX, colDrawY, colWidth, colHeight));

        final colSelected = a.selection.columns.hasIndex(c.sourceIndex);
        final groupDetails = a.getGroupDetails;
        final groupTheme = groupDetails == null
            ? null
            : groupDetails(c.group ?? '').overrideTheme;
        final colTheme = c.themeOverride == null && groupTheme == null
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
              final spanKey = '$row,${span.start},${span.end},${c.sticky}';
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
            final spanIsHighlighted =
                span != null &&
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
                frameTime: frameTime,
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
    required int frameTime,
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

    // `drawLastUpdateUnderlay` (`data-grid-lib.ts:401-428`), whose return
    // value is upstream's `needsAnim`.
    final lastUpdated = cell.lastUpdated;
    var needsAnim = false;
    if (lastUpdated != null) {
      final progress = frameTime - lastUpdated;
      needsAnim = progress < lastUpdateAnimationMs;
      if (needsAnim) {
        final fade = 1 - progress / lastUpdateAnimationMs;
        canvas.drawRect(
          Rect.fromLTWH(
            rect.x + 1,
            rect.y + 1,
            rect.width - 1,
            rect.height - 1,
          ),
          Paint()..color = theme.bgSearchResult.withValues(alpha: fade),
        );
      }
    }

    final item = GlideItem(col, row);
    // `animationFrameRequested` (`data-grid-render.cells.ts:462-465,513`):
    // set when the renderer asks for another frame, reset per cell.
    var animationFrameRequested = false;
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
      frameTime: frameTime,
      metrics: arg.metrics,
      imageLoader: arg.imageLoader,
      requestAnimationFrame: ([state]) => animationFrameRequested = true,
    );

    // `if (drawCellCallback !== undefined && !isInnerOnlyCell(...))`
    // (`data-grid-render.cells.ts:545-547`): marker and new-row cells are
    // inner-only and never reach a consumer.
    void drawContent() => renderer.draw(args);
    final cellCallback = arg.drawCellCallback;
    if (cellCallback != null && !glideIsInnerOnlyCell(cell)) {
      cellCallback(args, drawContent);
    } else {
      drawContent();
    }

    // `if (needsAnim || animationFrameRequested) enqueue?.(allocatedItem)`
    // (`data-grid-render.cells.ts:561`). Enqueueing only once the flash was
    // *over* — as this port did — meant the next frame never came and the
    // animation froze on its first frame.
    if (needsAnim || animationFrameRequested) {
      arg.enqueue?.call(item);
    }
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
    for (var i = a.rows - a.freezeTrailingRows; i < a.rows; i++) {
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
              rowTheme?.horizontalBorderColor ?? rowTheme?.borderColor ?? hColor
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
        final headerItem = GlideItem(c.sourceIndex, GlideItem.headerRow);
        final selected = a.selection.columns.hasIndex(c.sourceIndex);
        final hasSelectedCell = a.selection.current?.cell.col == c.sourceIndex;
        final noHover = a.dragAndDropState != null || a.isResizing;
        final hover = noHover ? 0.0 : (a.hoverValues[headerItem] ?? 0);
        // `hoveredBoolean` (`data-grid-render.header.ts:95`).
        final hovered = !noHover && a.hoverInfo == headerItem;
        final hoverX = hovered ? a.hoverPosition?.dx : null;
        final hoverY = hovered ? a.hoverPosition?.dy : null;

        // `data-grid-render.header.ts:86-109`: the fill starts one pixel in
        // so the grid line of column 0 survives, and a selected column is
        // painted with the accent color rather than blended.
        final xOffset = c.sourceIndex == 0 ? 0.0 : 1.0;
        final rect = Rect.fromLTWH(
          drawX + xOffset,
          headerTop,
          c.width - xOffset,
          totalHeaderHeight - headerTop,
        );

        if (selected) {
          canvas.drawRect(rect, Paint()..color = theme.accentColor);
        } else if (hasSelectedCell || hover > 0) {
          if (hasSelectedCell) {
            canvas.drawRect(rect, Paint()..color = theme.bgHeaderHasFocus);
          }
          if (hover > 0) {
            canvas.saveLayer(
              rect,
              Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: hover),
            );
            canvas.drawRect(rect, Paint()..color = theme.bgHeaderHovered);
            canvas.restore();
          }
        }

        // Everything below is upstream's `drawHeaderInner`
        // (`data-grid-render.header.ts:415-...`): the marker column shows a
        // checkbox instead of a title, then the title is painted.
        void drawContent() {
          // `drawHeaderInner`'s marker branch (`data-grid-render.header.ts:
          // 433-459`): the marker column shows a checkbox instead of a title.
          final ext = c.extension;
          if (ext?.rowMarker != null && ext!.headerRowMarkerDisabled != true) {
            final checked = ext.rowMarkerChecked ?? GlideBooleanValue.empty;
            final alwaysVisible = ext.headerRowMarkerAlwaysVisible;
            // `globalAlpha = hoverAmount` unless the marker is always visible
            // (`data-grid-render.header.ts:435-457`).
            final alpha = checked == GlideBooleanValue.checked || alwaysVisible
                ? 1.0
                : hover;
            if (alpha > 0) {
              final markerTheme =
                  ext.headerRowMarkerTheme?.applyTo(theme) ?? theme;
              final markerRect = Rect.fromLTWH(
                drawX,
                headerTop,
                c.width,
                totalHeaderHeight - headerTop,
              );
              canvas.saveLayer(
                markerRect,
                Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
              );
              drawCheckbox(
                canvas,
                markerTheme,
                checked,
                drawX,
                headerTop,
                c.width,
                totalHeaderHeight - headerTop,
                maxSize: theme.checkboxMaxSize,
                alignment: GlideContentAlign.center,
                style: ext.rowMarker!,
              );
              canvas.restore();
            }
            return;
          }

          final fill = selected ? theme.textHeaderSelected : theme.textHeader;

          // `computeHeaderLayout` (`data-grid-render.header.ts:342-414`):
          // where the icon, overlay, title and indicator sit inside this
          // header. The title starts after the icon when there is one.
          final layout = computeHeaderLayout(
            c: c,
            x: drawX,
            y: headerTop,
            width: c.width,
            height: totalHeaderHeight - headerTop,
            theme: theme,
            metrics: a.metrics,
          );

          final sprite = a.spriteManager;
          // `variant` (`data-grid-render.header.ts:466-469`): a `highlight`
          // column draws the unselected icon in the `special` colors.
          final unselectedVariant =
              c.style == GlideColumnStyle.highlight
                  ? GlideSpriteVariant.special
                  : GlideSpriteVariant.normal;
          final iconVariant = selected
              ? GlideSpriteVariant.selected
              : unselectedVariant;

          final iconBounds = layout.iconBounds;
          if (c.icon != null && iconBounds != null && sprite != null) {
            sprite.drawSprite(
              c.icon!,
              iconVariant,
              canvas,
              iconBounds.x,
              iconBounds.y,
              iconBounds.width,
              theme,
            );
            final overlayBounds = layout.iconOverlayBounds;
            if (c.overlayIcon != null && overlayBounds != null) {
              sprite.drawSprite(
                c.overlayIcon!,
                selected ? GlideSpriteVariant.selected : GlideSpriteVariant.special,
                canvas,
                overlayBounds.x,
                overlayBounds.y,
                overlayBounds.width,
                theme,
              );
            }
          }

          // The title runs from the layout's `textBounds.x` to the right
          // padding, minus the menu button when one is reserved.
          final available = math.max(
            1.0,
            (drawX + c.width - theme.cellHorizontalPadding) -
                layout.textBounds.x -
                (c.hasMenu ? theme.headerIconSize : 0),
          );

          // `shouldDrawMenu` (`data-grid-render.header.ts:462`) plus the
          // gradient that keeps the title from running under the button
          // (`:474-493`): opaque until `width - 35`, gone by `width - 24.5`.
          // The gradient rides on `TextStyle.foreground` because this
          // Flutter's `TextPainter.paint` takes no `Paint` argument.
          final shouldDrawMenu =
              c.hasMenu &&
              (hovered || (a.touchMode && selected)) &&
              c.width > 35;
          final style = shouldDrawMenu
              ? theme.headerTextStyle.copyWith(
                  foreground: Paint()
                    ..shader = LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        fill,
                        fill,
                        fill.withValues(alpha: 0),
                        fill.withValues(alpha: 0),
                      ],
                      stops: [
                        0,
                        (c.width - 35) / c.width,
                        (c.width - 24.5) / c.width,
                        1,
                      ],
                    ).createShader(
                      Rect.fromLTWH(
                        drawX,
                        headerTop,
                        c.width,
                        totalHeaderHeight - headerTop,
                      ),
                    ),
                )
              : theme.headerTextStyle.copyWith(color: fill);

          final painter = a.metrics.painter(
            c.title,
            style,
            maxWidth: available,
            ellipsis: true,
          );
          painter.paint(
            canvas,
            Offset(
              layout.textBounds.x,
              headerTop +
                  (totalHeaderHeight - headerTop) / 2 -
                  painter.height / 2,
            ),
          );

          // The indicator icon after the title
          // (`data-grid-render.header.ts:527-555`), hidden when the menu
          // button would overlap it.
          final indicatorBounds = layout.indicatorIconBounds;
          if (c.indicatorIcon != null &&
              indicatorBounds != null &&
              sprite != null &&
              !(shouldDrawMenu &&
                  intersectRect(
                    layout.menuBounds.x,
                    layout.menuBounds.y,
                    layout.menuBounds.width,
                    layout.menuBounds.height,
                    indicatorBounds.x,
                    indicatorBounds.y,
                    indicatorBounds.width,
                    indicatorBounds.height,
                  ))) {
            sprite.drawSprite(
              c.indicatorIcon!,
              iconVariant,
              canvas,
              indicatorBounds.x,
              indicatorBounds.y,
              indicatorBounds.width,
              theme,
            );
          }

          // The button itself (`data-grid-render.header.ts:558-590`): the
          // triangle and the three-dot variant are plain primitives.
          if (shouldDrawMenu) {
            final menuBounds = layout.menuBounds;
            final overMenu =
                hoverX != null &&
                hoverY != null &&
                pointInRect(menuBounds, hoverX, hoverY);
            // `globalAlpha = 0.7` unless the pointer is over the button.
            final iconPaint = Paint()
              ..color = fill.withValues(alpha: overMenu ? 1 : 0.7);
            final cx = menuBounds.x + menuBounds.width / 2;
            final cy = menuBounds.y + menuBounds.height / 2;
            switch (c.menuIcon ?? GlideColumnMenuIcon.triangle) {
              case GlideColumnMenuIcon.dots:
                // `drawMenuDots` (`data-grid-lib.ts:657-662`), radius 1.25.
                for (final dy in const [-4.375, 0.0, 4.375]) {
                  canvas.drawCircle(Offset(cx, cy + dy), 1.25, iconPaint);
                }
              case GlideColumnMenuIcon.triangle:
                // `roundedPoly(..., 1)` (`data-grid-render.header.ts:571-584`);
                // the 1px corner rounding is dropped.
                final path = Path()
                  ..moveTo(cx - 5.5, cy - 3)
                  ..lineTo(cx + 5.5, cy - 3)
                  ..lineTo(cx, cy + 3)
                  ..close();
                canvas.drawPath(path, iconPaint);
            }
          }
        }

        // `if (drawHeaderCallback !== undefined)` (`data-grid-render.header
        // .ts:634-672`): the consumer gets `drawContent` and decides whether
        // the default header paint runs.
        final headerCallback = a.drawHeaderCallback;
        if (headerCallback != null) {
          headerCallback(
            GlideDrawHeaderArgs(
              canvas: canvas,
              theme: theme,
              rect: GlideRectangle(
                x: drawX,
                y: headerTop,
                width: c.width,
                height: totalHeaderHeight - headerTop,
              ),
              column: c,
              columnIndex: c.sourceIndex,
              isSelected: selected,
              hoverAmount: hover,
              isHovered: hovered,
              hasSelectedCell: hasSelectedCell,
              menuBounds: getHeaderMenuBounds(
                drawX,
                headerTop,
                c.width,
                totalHeaderHeight - headerTop,
              ),
              hoverX: hoverX,
              hoverY: hoverY,
            ),
            drawContent,
          );
        } else {
          drawContent();
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
          // `drawGroups` (`data-grid-render.header.ts:159-260`).
          final details =
              a.getGroupDetails?.call(group) ?? GlideGroupDetails(name: group);
          final groupTheme = details.overrideTheme?.applyTo(theme) ?? theme;
          final hovered = a.hoverInfo;
          final isHovered =
              hovered != null &&
              hovered.row == GlideItem.groupHeaderRow &&
              hovered.col >= colSpan.$1 &&
              hovered.col <= colSpan.$2;
          final fillColor = isHovered
              ? (groupTheme.bgGroupHeaderHovered ?? theme.bgHeaderHovered)
              : (groupTheme.bgGroupHeader ?? theme.bgHeader);

          canvas.save();
          canvas.clipRect(Rect.fromLTWH(x, y, w, h));
          canvas.drawRect(
            Rect.fromLTWH(x, y, w, h),
            Paint()..color = fillColor,
          );

          const xPad = 8.0;
          var drawX = x;
          if (details.icon != null) {
            _paintIcon(
              canvas,
              details.icon!,
              Rect.fromLTWH(drawX + xPad, (h - 20) / 2, 20, 20),
              groupTheme.textGroupHeader ?? groupTheme.textHeader,
            );
            drawX += 26;
          }

          final painter = a.metrics.painter(
            details.name,
            theme.headerTextStyle.copyWith(
              color: groupTheme.textGroupHeader ?? theme.textHeader,
            ),
            maxWidth: math.max(1.0, x + w - drawX - xPad),
            ellipsis: true,
          );
          painter.paint(
            canvas,
            Offset(drawX + xPad, h / 2 - painter.height / 2),
          );

          // Actions only appear while the header is hovered; the fade lets the
          // name disappear underneath them (`:218-257`).
          final actions = details.actions;
          if (actions != null && actions.isNotEmpty && isHovered) {
            final boxes = getActionBoundsForGroup(
              GlideRectangle(x: x, y: y, width: w, height: h),
              actions,
            );
            final fadeStartX = boxes.first.x - 10;
            final fadeWidth = x + w - fadeStartX;
            if (fadeWidth > 0) {
              final shader = LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [fillColor.withValues(alpha: 0), fillColor],
                stops: [0, math.min(1.0, 10 / fadeWidth), 1],
              ).createShader(Rect.fromLTWH(fadeStartX, y, fadeWidth, h));
              canvas.drawRect(
                Rect.fromLTWH(fadeStartX, y, fadeWidth, h),
                Paint()..shader = shader,
              );
            }

            for (var i = 0; i < actions.length; i++) {
              final action = actions[i];
              final box = boxes[i];
              final actionHovered = pointInRect(
                box,
                hovered.col.toDouble(),
                hovered.row.toDouble(),
              );
              final icon = action.icon;
              if (icon != null) {
                _paintIcon(
                  canvas,
                  icon,
                  Rect.fromLTWH(
                    box.x + box.width / 2 - 10,
                    box.y + box.height / 2 - 10,
                    20,
                    20,
                  ),
                  (actionHovered
                          ? (groupTheme.textGroupHeader ?? theme.textHeader)
                          : (groupTheme.textGroupHeader ?? theme.textHeader))
                      .withValues(alpha: actionHovered ? 1 : 0.6),
                );
              } else {
                // No sprite manager: fall back to the action's initial.
                final label = action.title.isEmpty
                    ? '?'
                    : action.title.substring(0, 1).toUpperCase();
                final labelPainter = a.metrics.painter(
                  label,
                  theme.headerTextStyle.copyWith(
                    color: (groupTheme.textGroupHeader ?? theme.textHeader)
                        .withValues(alpha: actionHovered ? 1 : 0.6),
                  ),
                );
                labelPainter.paint(
                  canvas,
                  Offset(
                    box.x + box.width / 2 - labelPainter.width / 2,
                    box.y + box.height / 2 - labelPainter.height / 2,
                  ),
                );
              }
            }
          }

          canvas.restore();
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

  /// `drawColumnResizeOutline` (`data-grid-render.ts:725-748`): a 2px rule
  /// over the header, plus the body when `resizeIndicator == "full"`.
  void _drawColumnResizeIndicator(
    Canvas canvas,
    List<GlideMappedColumn> effectiveCols,
    double totalHeaderHeight,
  ) {
    final a = arg;
    double? lineX;
    for (final c in effectiveCols) {
      if (c.sourceIndex == a.resizeColumn) {
        lineX = null;
        var x = 0.0;
        for (final e in effectiveCols) {
          if (e.sticky) {
            x += e.width;
            continue;
          }
          if (e.sourceIndex == a.resizeColumn) break;
          x += e.width;
        }
        lineX = x + c.width + (c.sticky ? 0 : a.translateX);
        break;
      }
    }
    if (lineX == null) return;

    final headerColor = Color.alphaBlend(
      a.theme.resizeIndicatorColor ?? a.theme.accentLight,
      a.theme.bgHeader,
    );
    canvas.drawLine(
      Offset(lineX, 0),
      Offset(lineX, totalHeaderHeight + 1),
      Paint()
        ..color = headerColor
        ..strokeWidth = 2,
    );
    if (a.resizeIndicator == GlideResizeIndicator.full) {
      canvas.drawLine(
        Offset(lineX, totalHeaderHeight),
        Offset(lineX, a.height),
        Paint()
          ..color = Color.alphaBlend(
            a.theme.resizeIndicatorColor ?? a.theme.accentLight,
            a.theme.bgCell,
          )
          ..strokeWidth = 2,
      );
    }
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
      // Guarded the same way as `totalHeaderHeight` below; `computeBounds`
      // derives the header strip from the difference of the two.
      groupHeaderHeight: a.enableGroups ? a.groupHeaderHeight : 0,
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
      // Guarded the same way as `totalHeaderHeight` below; `computeBounds`
      // derives the header strip from the difference of the two.
      groupHeaderHeight: a.enableGroups ? a.groupHeaderHeight : 0,
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

  /// Upstream draws group icons through the sprite manager, which this port
  /// does not have; [GlideGroupAction.icon] is a Flutter [IconData] instead.
  void _paintIcon(Canvas canvas, IconData icon, Rect rect, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(color: color, fontSize: rect.height),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        rect.center.dx - painter.width / 2,
        rect.center.dy - painter.height / 2,
      ),
    );
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
        : (Path()
            ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))));

    canvas.drawPath(path, Paint()..color = a.theme.bgCell);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = a.theme.accentColor,
    );
  }

  GlideTheme? _realize(GlideThemeOverride? override) =>
      override?.applyTo(arg.theme);

  @override
  bool shouldRepaint(GlideDataGridPainter oldDelegate) =>
      !_argEquals(oldDelegate.arg, arg);

  /// The Web equivalent is `computeCanBlit` (`data-grid-render.blit.ts:233`):
  /// if none of these change, the frame is identical and can be reused.
  ///
  /// Deviation: upstream reuses the *damaged* regions of the previous frame;
  /// Flutter retains the whole layer, so this is an all-or-nothing version of
  /// the same idea. It must therefore cover every field of [GlideDrawGridArg]
  /// — one omission means "that prop changed and the grid never repainted".
  /// The field list below is in declaration order so the two can be diffed.
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
        // Identity: the grid memoizes `mapColumns(columns, freezeColumns)`
        // (`data-grid.tsx:432`), so unchanged columns yield the same list —
        // which is how upstream compares the array too.
        identical(a.mappedColumns, b.mappedColumns) &&
        a.freezeColumns == b.freezeColumns &&
        a.freezeTrailingRows == b.freezeTrailingRows &&
        a.rows == b.rows &&
        a.rowHeight == b.rowHeight &&
        a.theme == b.theme &&
        a.selection == b.selection &&
        a.isFocused == b.isFocused &&
        a.drawFocus == b.drawFocus &&
        // Functions compare with `==`, not `identical`. Dart does not
        // canonicalize instance tear-offs — `identical(state.m, state.m)` is
        // false — so every method handed to the grid (`_enqueue`,
        // `_getCellContent`, `_renderers.forCell`, `_groupDetails`) would
        // otherwise be a new object per build and the check could never
        // hold. `==` still treats a fresh lambda as different, which is the
        // same contract React imposes with `useCallback`.
        a.verticalBorder == b.verticalBorder &&
        a.getCellContent == b.getCellContent &&
        a.getCellRenderer == b.getCellRenderer &&
        identical(a.metrics, b.metrics) &&
        a.getRowThemeOverride == b.getRowThemeOverride &&
        a.getGroupDetails == b.getGroupDetails &&
        // A fresh map per hover tick, so identity tracks the animation.
        identical(a.hoverValues, b.hoverValues) &&
        a.hoverInfo == b.hoverInfo &&
        a.hoverPosition == b.hoverPosition &&
        identical(a.damage, b.damage) &&
        a.hasAppendRow == b.hasAppendRow &&
        a.touchMode == b.touchMode &&
        a.fillHandle == b.fillHandle &&
        a.disabledRows == b.disabledRows &&
        // Value lists: the editor derives these per build, so identity would
        // make the whole check fail whenever a highlight or prelight exists.
        listEquals(a.prelightCells, b.prelightCells) &&
        listEquals(a.highlightRegions, b.highlightRegions) &&
        a.drawHeaderCallback == b.drawHeaderCallback &&
        a.drawCellCallback == b.drawCellCallback &&
        a.fixedShadowX == b.fixedShadowX &&
        a.fixedShadowY == b.fixedShadowY &&
        a.hyperWrapping == b.hyperWrapping &&
        a.enqueue == b.enqueue &&
        a.minimumCellWidth == b.minimumCellWidth &&
        a.dragAndDropState == b.dragAndDropState &&
        a.isResizing == b.isResizing &&
        a.resizeColumn == b.resizeColumn &&
        a.resizeIndicator == b.resizeIndicator &&
        identical(a.imageLoader, b.imageLoader) &&
        identical(a.spriteManager, b.spriteManager);
  }
}
