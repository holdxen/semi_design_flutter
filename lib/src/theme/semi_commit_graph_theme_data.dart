import 'package:flutter/widgets.dart';

import '../components/commit_graph_layout.dart';
import 'semi_theme_data.dart';

/// Overridable tokens for [SemiCommitGraph].
///
/// Follows the Semi theme layering: unresolved patch data ([SemiCommitGraphThemeData])
/// merges down the widget tree, then [resolve] fills gaps from the global
/// [SemiThemeData] color tokens and layout defaults.
@immutable
class SemiCommitGraphThemeData {
  const SemiCommitGraphThemeData({
    this.branchColors,
    this.taintedColor,
    this.backgroundColor,
    this.selectionColor,
    this.dotColor,
    this.messageColor,
    this.metaColor,
    this.refColor,
    this.lineWidth,
    this.dotRadius,
    this.rowHeight,
    this.horizontalPadding,
  });

  /// Palette assigned to branch lanes in order of first use.
  final List<Color>? branchColors;

  /// Color of the dashed "uncommitted changes" lane.
  final Color? taintedColor;

  final Color? backgroundColor;
  final Color? selectionColor;

  /// Color of the node dot outline. Defaults to the message text color.
  final Color? dotColor;

  /// Commit subject text color.
  final Color? messageColor;

  /// Author / timestamp / short id text color.
  final Color? metaColor;

  /// Ref (branch / tag) label color.
  final Color? refColor;

  final double? lineWidth;
  final double? dotRadius;

  /// Fixed row height. When null the row auto-sizes from its text.
  final double? rowHeight;

  final double? horizontalPadding;

  SemiCommitGraphThemeData copyWith({
    List<Color>? branchColors,
    Color? taintedColor,
    Color? backgroundColor,
    Color? selectionColor,
    Color? dotColor,
    Color? messageColor,
    Color? metaColor,
    Color? refColor,
    double? lineWidth,
    double? dotRadius,
    double? rowHeight,
    double? horizontalPadding,
  }) => SemiCommitGraphThemeData(
    branchColors: branchColors ?? this.branchColors,
    taintedColor: taintedColor ?? this.taintedColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    selectionColor: selectionColor ?? this.selectionColor,
    dotColor: dotColor ?? this.dotColor,
    messageColor: messageColor ?? this.messageColor,
    metaColor: metaColor ?? this.metaColor,
    refColor: refColor ?? this.refColor,
    lineWidth: lineWidth ?? this.lineWidth,
    dotRadius: dotRadius ?? this.dotRadius,
    rowHeight: rowHeight ?? this.rowHeight,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
  );

  SemiCommitGraphThemeData merge(SemiCommitGraphThemeData? other) =>
      other == null
          ? this
          : copyWith(
              branchColors: other.branchColors,
              taintedColor: other.taintedColor,
              backgroundColor: other.backgroundColor,
              selectionColor: other.selectionColor,
              dotColor: other.dotColor,
              messageColor: other.messageColor,
              metaColor: other.metaColor,
              refColor: other.refColor,
              lineWidth: other.lineWidth,
              dotRadius: other.dotRadius,
              rowHeight: other.rowHeight,
              horizontalPadding: other.horizontalPadding,
            );

  SemiResolvedCommitGraphThemeData resolve(SemiThemeData theme) {
    final colors = theme.colors;
    final resolvedColors = branchColors ?? kSemiGraphDefaultBranchColors;
    final message = messageColor ?? colors.colorText0;
    return SemiResolvedCommitGraphThemeData(
      branchColors: resolvedColors,
      taintedColor: taintedColor ?? colors.colorText3,
      backgroundColor: backgroundColor ?? colors.colorFill0,
      selectionColor: selectionColor ?? colors.colorPrimary.withValues(alpha: .12),
      dotColor: dotColor ?? message,
      messageColor: message,
      metaColor: metaColor ?? colors.colorText2,
      refColor: refColor ?? colors.colorPrimary,
      lineWidth: lineWidth ?? 2,
      dotRadius: dotRadius ?? 4,
      rowHeight: rowHeight,
      horizontalPadding: horizontalPadding ?? 4,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiCommitGraphThemeData &&
          _colorsEqual(branchColors, other.branchColors) &&
          taintedColor == other.taintedColor &&
          backgroundColor == other.backgroundColor &&
          selectionColor == other.selectionColor &&
          dotColor == other.dotColor &&
          messageColor == other.messageColor &&
          metaColor == other.metaColor &&
          refColor == other.refColor &&
          lineWidth == other.lineWidth &&
          dotRadius == other.dotRadius &&
          rowHeight == other.rowHeight &&
          horizontalPadding == other.horizontalPadding;

  @override
  int get hashCode => Object.hashAll([
        branchColors == null ? null : Object.hashAll(branchColors!),
        taintedColor,
        backgroundColor,
        selectionColor,
        dotColor,
        messageColor,
        metaColor,
        refColor,
        lineWidth,
        dotRadius,
        rowHeight,
        horizontalPadding,
      ]);
}

bool _colorsEqual(List<Color>? a, List<Color>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Fully resolved tokens (no nullable fields) consumed by the widget/painter.
@immutable
class SemiResolvedCommitGraphThemeData {
  const SemiResolvedCommitGraphThemeData({
    required this.branchColors,
    required this.taintedColor,
    required this.backgroundColor,
    required this.selectionColor,
    required this.dotColor,
    required this.messageColor,
    required this.metaColor,
    required this.refColor,
    required this.lineWidth,
    required this.dotRadius,
    required this.rowHeight,
    required this.horizontalPadding,
  });

  final List<Color> branchColors;
  final Color taintedColor;
  final Color backgroundColor;
  final Color selectionColor;
  final Color dotColor;
  final Color messageColor;
  final Color metaColor;
  final Color refColor;
  final double lineWidth;
  final double dotRadius;
  final double? rowHeight;
  final double horizontalPadding;
}
