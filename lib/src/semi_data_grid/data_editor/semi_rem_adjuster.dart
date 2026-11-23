// Port of `packages/core/src/data-editor/use-rem-adjuster.ts`.
//
// Web reads `document.documentElement`'s font size and, when `scaleToRem` is
// on, multiplies every dimension by `remSize / 16`. Flutter has no root font
// size; the equivalent is the platform text scaler, which callers can supply
// through `remSize` (or leave at the 16px default, which makes this a no-op).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../common/semi_data_grid_theme.dart';
import '../internal/data_grid/semi_geometry.dart';

/// The scaled dimensions `useRemAdjuster` returns (`data-editor.tsx:939-948`).
@immutable
class SemiRemAdjustment {
  const SemiRemAdjustment({
    required this.rowHeight,
    required this.headerHeight,
    required this.groupHeaderHeight,
    required this.theme,
    required this.overscrollX,
    required this.overscrollY,
  });

  final SemiRowHeight rowHeight;
  final double headerHeight;
  final double groupHeaderHeight;
  final SemiDataGridTheme theme;
  final double overscrollX;
  final double overscrollY;
}

/// `useRemAdjuster` (`use-rem-adjuster.ts:15-47`).
SemiRemAdjustment semiRemAdjuster({
  required bool scaleToRem,
  required double remSize,
  required SemiRowHeight rowHeightIn,
  required double headerHeightIn,
  required double groupHeaderHeightIn,
  required SemiDataGridTheme themeIn,
  required double overscrollXIn,
  required double overscrollYIn,
}) {
  if (!scaleToRem || remSize == 16) {
    return SemiRemAdjustment(
      rowHeight: rowHeightIn,
      headerHeight: headerHeightIn,
      groupHeaderHeight: groupHeaderHeightIn,
      theme: themeIn,
      overscrollX: overscrollXIn,
      overscrollY: overscrollYIn,
    );
  }

  final scaler = remSize / 16;
  final rh = rowHeightIn;
  return SemiRemAdjustment(
    rowHeight: rh.isFixed
        ? SemiRowHeight.fixed(rh(0) * scaler)
        : SemiRowHeight.variable((n) => (rh(n) * scaler).ceilToDouble()),
    headerHeight: (headerHeightIn * scaler).ceilToDouble(),
    groupHeaderHeight: (groupHeaderHeightIn * scaler).ceilToDouble(),
    theme: SemiThemeOverride(
      headerIconSize: themeIn.headerIconSize * scaler,
      cellHorizontalPadding: themeIn.cellHorizontalPadding * scaler,
      cellVerticalPadding: themeIn.cellVerticalPadding * scaler,
    ).applyTo(themeIn),
    overscrollX: (overscrollXIn * scaler).ceilToDouble(),
    overscrollY: (overscrollYIn * scaler).ceilToDouble(),
  );
}

/// The root font size the scaler should use; 16 is the identity.
double semiRemSizeFor(double textScale) => math.max(1.0, textScale) * 16;
