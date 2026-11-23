// Port of `drawTextCell` (`packages/core/src/internal/data-grid/render/
// data-grid-lib.ts:447-606`).
//
// Flutter differences, all local to this file:
// - `ctx.textAlign`/`textBaseline` have no direct equivalent; alignment is
//   applied by translating the `TextPainter`, vertical centering uses
//   `(rect.height - painter.height) / 2` (which is exactly what the canvas
//   `middle` baseline + `getMiddleCenterBias` combination achieved).
// - `canvas-hypertxt`'s `split` is replaced by `TextPainter` greedy wrapping
//   with an explicit `maxLines`, derived from the available height.
import 'package:flutter/widgets.dart';

import '../../../cells/semi_cell_types.dart';

final RegExp _rtl = RegExp(r'[\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC]');

/// `direction` (`common/utils.tsx:174-176`).
bool isRtlText(String value) => _rtl.hasMatch(value);

/// `truncateString` (`data-grid-lib.ts:495-507`).
///
/// The `/4` factor is upstream's cheap "average glyph is 4px" guard; it is
/// intentionally kept because `TextPainter` clipping is a different visual
/// result (web clips at the last whole glyph, this trims before measuring).
String truncateString(String data, double w) {
  if (data.contains('\n')) {
    data = data.split(RegExp(r'\r?\n')).first;
  }
  final max = w / 4;
  if (data.length > max) {
    data = data.substring(0, max.toInt());
  }
  return data;
}

/// `drawTextCell` (`data-grid-lib.ts:549-606`).
void drawTextCell(
  SemiDrawCellArgs args,
  String data, {
  SemiContentAlign? contentAlign,
  bool allowWrapping = false,
  bool hyperWrapping = false,
}) {
  final rect = args.rect;
  final theme = args.theme;
  var text = data;
  if (!allowWrapping) text = truncateString(text, rect.width);
  if (text.isEmpty) return;

  final style = theme.baseTextStyle;
  final metrics = args.metrics ?? SemiTextMetrics();
  final rtl = isRtlText(text);
  final align = contentAlign ?? (rtl ? SemiContentAlign.right : null);
  final direction = rtl ? TextDirection.rtl : TextDirection.ltr;

  if (allowWrapping) {
    final maxWidth = (rect.width - theme.cellHorizontalPadding * 2).clamp(
      1.0,
      double.infinity,
    );
    final lineHeight = theme.baseFontSize * theme.lineHeight;
    final maxLines =
        ((rect.height - theme.cellVerticalPadding * 2) / lineHeight).floor().clamp(
          1,
          10000,
        );
    final painter = metrics.painter(
      text,
      style,
      maxWidth: maxWidth,
      maxLines: maxLines,
      textAlign: switch (align) {
        SemiContentAlign.right => TextAlign.right,
        SemiContentAlign.center => TextAlign.center,
        _ => TextAlign.left,
      },
      textDirection: direction,
    );

    final x = rect.x + theme.cellHorizontalPadding;
    final optimalY = rect.y + rect.height / 2 - painter.height / 2;
    final y = optimalY < rect.y + theme.cellVerticalPadding
        ? rect.y + theme.cellVerticalPadding
        : optimalY;

    final mustClip = painter.height + theme.cellVerticalPadding > rect.height;
    if (mustClip) {
      args.canvas.save();
      args.canvas.clipRect(
        Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height),
      );
    }
    painter.paint(args.canvas, Offset(x, y));
    if (mustClip) args.canvas.restore();
    return;
  }

  final painter = metrics.painter(
    text,
    style,
    maxWidth: double.infinity,
    textDirection: direction,
  );

  final textWidth = painter.width;
  final dx = switch (align) {
    SemiContentAlign.right =>
      rect.x + rect.width - (theme.cellHorizontalPadding + 0.5) - textWidth,
    SemiContentAlign.center => rect.x + rect.width / 2 - textWidth / 2,
    _ => rect.x + theme.cellHorizontalPadding + 0.5,
  };
  final dy = rect.y + rect.height / 2 - painter.height / 2;
  painter.paint(args.canvas, Offset(dx, dy));
}

/// `drawTextCellExternal` (`data-grid-lib.ts:446-468`).
void drawTextCellExternal(
  SemiDrawCellArgs args,
  String data, {
  SemiContentAlign? contentAlign,
  bool allowWrapping = false,
}) {
  drawTextCell(
    args,
    data,
    contentAlign: contentAlign,
    allowWrapping: allowWrapping,
    hyperWrapping: args.hyperWrapping,
  );
}

/// `getMeasuredTextCache` / `measure` helpers used by column auto-sizing.
double measureTextWidth(String text, SemiDataGridTheme theme, SemiTextMetrics metrics) =>
    metrics.width(text, theme.baseTextStyle);

/// `drawEditHoverIndicator` (`render/draw-edit-hover-indicator.ts`): the pencil
/// badge drawn over a hovered editable text cell. Kept as a small separate
/// helper because the icon sprite system is not ported yet.
void drawEditHoverIndicator(
  SemiDrawCellArgs args,
  String data,
  SemiHoverEffectTheme? hoverEffectTheme,
) {
  final rect = args.rect;
  final theme = args.theme;
  final amount = args.hoverAmount;
  if (amount <= 0) return;

  final canvas = args.canvas;
  final bg = hoverEffectTheme?.bgColor ?? theme.bgCellMedium;
  final full = hoverEffectTheme?.fullSize ?? false;
  final r = full
      ? rect
      : SemiRectangle(
          x: rect.x,
          y: rect.y,
          width: rect.width,
          height: rect.height,
        );

  canvas.save();
  canvas.clipRect(Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height));
  canvas.drawRect(
    Rect.fromLTWH(r.x, r.y, r.width, r.height),
    Paint()..color = bg.withValues(alpha: amount),
  );
  drawTextCell(args, data);
  canvas.restore();
}
