// Port of `packages/core/src/internal/data-grid/data-grid-types.ts`.
//
// Translation notes (apply to every ported file):
// - TS unions over `kind` become a Dart `sealed class` hierarchy. `switch` on
//   `cell.kind` becomes exhaustive pattern matching, which the compiler checks
//   the same way `assertNever` did upstream.
// - `Item = readonly [col, row]` becomes [GlideItem]; the constructor is
//   positional in tuple order (`GlideItem(col, row)`) on purpose, so a
//   transposed call looks wrong at the call site.
// - `BooleanCell.data: boolean | null | undefined` has three states; Dart's
//   `bool?` only has two, so the tri-state is modelled by [GlideBooleanValue].
import 'package:flutter/widgets.dart';

import '../../common/glide_theme.dart';
import 'glide_selection.dart';

export 'glide_selection.dart';

/// `Item = readonly [col, row]` (`data-grid-types.ts:146`).
///
/// Positive rows are cells, `-1` is the header row and `-2` the group header.
@immutable
class GlideItem {
  const GlideItem(this.col, this.row);

  final int col;
  final int row;

  static const int headerRow = -1;
  static const int groupHeaderRow = -2;

  GlideItem offset(int colDelta, int rowDelta) =>
      GlideItem(col + colDelta, row + rowDelta);

  @override
  bool operator ==(Object other) =>
      other is GlideItem && other.col == col && other.row == row;

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => '[$col, $row]';
}

/// `Rectangle` (`data-grid-types.ts:295-300`).
@immutable
class GlideRectangle {
  const GlideRectangle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  const GlideRectangle.empty()
    : x = 0,
      y = 0,
      width = 0,
      height = 0;

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;
  double get bottom => y + height;

  GlideRectangle copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) => GlideRectangle(
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
  );

  GlideRectangle translate(double dx, double dy) =>
      GlideRectangle(x: x + dx, y: y + dy, width: width, height: height);

  GlideRectangle inflate(double dx, double dy) => GlideRectangle(
    x: x - dx,
    y: y - dy,
    width: width + dx * 2,
    height: height + dy * 2,
  );

  bool containsPoint(double px, double py) =>
      px >= x && px < x + width && py >= y && py < y + height;

  /// `itemIsInRect` (`render/data-grid-lib.ts:87-91`).
  bool containsItem(GlideItem item) =>
      item.col >= x &&
      item.col < x + width &&
      item.row >= y &&
      item.row < y + height;

  @override
  bool operator ==(Object other) =>
      other is GlideRectangle &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() =>
      'GlideRectangle(x: $x, y: $y, w: $width, h: $height)';
}

bool isRectangleEqual(GlideRectangle? a, GlideRectangle? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return a == b;
}

/// `GridCellKind` (`data-grid-types.ts:79-92`).
enum GlideCellKind {
  uri,
  text,
  image,
  rowID,
  number,
  bubble,
  boolean,
  loading,
  markdown,
  drilldown,
  protected,
  custom,

  // `InnerGridCellKind` (`data-grid-types.ts:497-500`). Not part of the public
  // 12; only the grid itself hands these to a renderer (row markers, trailing
  // "new row" cell).
  newRow,
  marker,
}

/// `"normal" | "faded"` (`data-grid-types.ts:314`). The *cell* style.
///
/// The column has its own, differently-valued `style`
/// (`data-grid-types.ts:157`) — see [GlideColumnStyle]. The two were briefly
/// conflated in this port, which made `"highlight"` unrepresentable.
enum GlideCellStyle { normal, faded }

/// `GridColumn.style`: `"normal" | "highlight"` (`data-grid-types.ts:157`).
///
/// Drives the sprite variant a header icon is drawn with
/// (`data-grid-render.header.ts:467-469`).
enum GlideColumnStyle { normal, highlight }

/// `"left" | "right" | "center"` (`data-grid-types.ts:317`).
enum GlideContentAlign { left, right, center }

/// `"label" | "square"` icon slots are `String` upstream (sprite ids).
typedef GlideColumnIcon = String;

/// `"triangle" | "dots"` (`data-grid-types.ts:127-130`).
enum GlideColumnMenuIcon { triangle, dots }

/// `"double-click" | "single-click" | "second-click"`
/// (`data-grid-types.ts:308`).
enum GlideCellActivationBehavior { doubleClick, singleClick, secondClick }

/// `[start, end]` inclusive span (`data-grid-types.ts:316`).
typedef GlideSpan = ({int start, int end});

/// `GridSelection` (`data-grid-types.ts:17-25`).
@immutable
class GlideGridSelection {
  const GlideGridSelection({
    this.current,
    this.columns = const GlideCompactSelection.empty(),
    this.rows = const GlideCompactSelection.empty(),
  });

  static const GlideGridSelection empty = GlideGridSelection();

  /// `current` block (`:18-22`). `rangeStack` is lowest to highest and does not
  /// include `range`.
  final GlideGridSelectionCurrent? current;
  final GlideCompactSelection columns;
  final GlideCompactSelection rows;

  GlideGridSelection copyWith({
    GlideGridSelectionCurrent? current,
    bool clearCurrent = false,
    GlideCompactSelection? columns,
    GlideCompactSelection? rows,
  }) => GlideGridSelection(
    current: clearCurrent ? null : (current ?? this.current),
    columns: columns ?? this.columns,
    rows: rows ?? this.rows,
  );

  /// `gridSelectionHasItem` (`render/data-grid-lib.ts:57-69`).
  bool hasItem(GlideItem item) {
    if (columns.hasIndex(item.col) || rows.hasIndex(item.row)) return true;
    final cur = current;
    if (cur == null) return false;
    if (cur.cell == item) return true;
    for (final r in [cur.range, ...cur.rangeStack]) {
      if (r.containsItem(item)) return true;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is GlideGridSelection &&
      other.current == current &&
      other.columns == columns &&
      other.rows == rows;

  @override
  int get hashCode => Object.hash(current, columns, rows);
}

/// `current` of [GlideGridSelection].
@immutable
class GlideGridSelectionCurrent {
  const GlideGridSelectionCurrent({
    required this.cell,
    required this.range,
    this.rangeStack = const [],
  });

  final GlideItem cell;
  final GlideRectangle range;
  final List<GlideRectangle> rangeStack;

  GlideGridSelectionCurrent copyWith({
    GlideItem? cell,
    GlideRectangle? range,
    List<GlideRectangle>? rangeStack,
  }) => GlideGridSelectionCurrent(
    cell: cell ?? this.cell,
    range: range ?? this.range,
    rangeStack: rangeStack ?? this.rangeStack,
  );

  @override
  bool operator ==(Object other) =>
      other is GlideGridSelectionCurrent &&
      other.cell == cell &&
      other.range == range &&
      _listEquals(other.rangeStack, rangeStack);

  @override
  int get hashCode => Object.hash(cell, range, Object.hashAll(rangeStack));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// `BooleanCell.data` tri-state (`data-grid-types.ts:31-38`).
///
/// Upstream uses `boolean | null | undefined`; the three states are preserved
/// here because the checkbox renders differently for `empty` (no box fill) and
/// `indeterminate` (dash).
enum GlideBooleanValue {
  empty,
  indeterminate,
  checked,
  unchecked;

  bool? get asBool => switch (this) {
    checked => true,
    unchecked => false,
    empty || indeterminate => null,
  };

  static GlideBooleanValue fromBool(bool? value) => switch (value) {
    true => checked,
    false => unchecked,
    null => empty,
  };
}

/// `HoverEffectTheme` (`data-grid-types.ts:336-339`).
@immutable
class GlideHoverEffectTheme {
  const GlideHoverEffectTheme({required this.bgColor, required this.fullSize});

  final Color bgColor;
  final bool fullSize;
}

/// `BaseGridCell` (`data-grid-types.ts:311-321`).
sealed class GlideGridCell {
  const GlideGridCell({
    this.allowOverlay = true,
    this.lastUpdated,
    this.style,
    this.themeOverride,
    this.span,
    this.contentAlign,
    this.cursor,
    this.copyData,
    this.activationBehaviorOverride,
  });

  final bool allowOverlay;

  /// Wall-clock millis; renderers flash the cell background for 500ms after a
  /// change (`drawLastUpdateUnderlay`, `data-grid-lib.ts:401-428`).
  final int? lastUpdated;
  final GlideCellStyle? style;
  final GlideThemeOverride? themeOverride;
  final GlideSpan? span;
  final GlideContentAlign? contentAlign;
  final MouseCursor? cursor;
  final String? copyData;
  final GlideCellActivationBehavior? activationBehaviorOverride;

  GlideCellKind get kind;

  /// `readonly` is only meaningful on editable cells; exposed uniformly so
  /// selection/editing code can ask once.
  bool get isReadonly => false;
}

/// `LoadingCell` (`data-grid-types.ts:324-329`).
class GlideLoadingCell extends GlideGridCell {
  /// `allowOverlay` defaults to false because the grid's own `loadingCell`
  /// is `{ kind: Loading, allowOverlay: false }` (`data-editor.tsx:762-765`),
  /// so a loading cell never opens an empty overlay.
  const GlideLoadingCell({
    this.skeletonWidth,
    this.skeletonHeight,
    this.skeletonWidthVariability,
    super.allowOverlay = false,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final double? skeletonWidth;
  final double? skeletonHeight;
  final double? skeletonWidthVariability;

  @override
  GlideCellKind get kind => GlideCellKind.loading;
}

/// `ProtectedCell` (`data-grid-types.ts:331-334`).
class GlideProtectedCell extends GlideGridCell {
  /// `allowOverlay` defaults to false: the protected cell has no
  /// `provideEditor` (`protected-cell.tsx`), and upstream's own examples
  /// always pass `allowOverlay: false`.
  const GlideProtectedCell({
    super.allowOverlay = false,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  @override
  GlideCellKind get kind => GlideCellKind.protected;
}

/// `TextCell` (`data-grid-types.ts:342-350`).
class GlideTextCell extends GlideGridCell {
  const GlideTextCell({
    required this.data,
    required this.displayData,
    this.readonly = false,
    this.allowWrapping = false,
    this.hoverEffect = false,
    this.hoverEffectTheme,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final String data;
  final String displayData;
  final bool readonly;
  final bool allowWrapping;
  final bool hoverEffect;
  final GlideHoverEffectTheme? hoverEffectTheme;

  @override
  GlideCellKind get kind => GlideCellKind.text;

  @override
  bool get isReadonly => readonly;

  GlideTextCell copyWith({
    String? data,
    String? displayData,
    bool? readonly,
    bool? allowWrapping,
    GlideContentAlign? contentAlign,
    GlideSpan? span,
    bool? allowOverlay,
  }) => GlideTextCell(
    data: data ?? this.data,
    displayData: displayData ?? this.displayData,
    readonly: readonly ?? this.readonly,
    allowWrapping: allowWrapping ?? this.allowWrapping,
    hoverEffect: hoverEffect,
    hoverEffectTheme: hoverEffectTheme,
    allowOverlay: allowOverlay ?? this.allowOverlay,
    lastUpdated: lastUpdated,
    style: style,
    themeOverride: themeOverride,
    span: span ?? this.span,
    contentAlign: contentAlign ?? this.contentAlign,
    cursor: cursor,
    copyData: copyData,
    activationBehaviorOverride: activationBehaviorOverride,
  );
}

/// `NumberCell` (`data-grid-types.ts:353-364`).
class GlideNumberCell extends GlideGridCell {
  const GlideNumberCell({
    required this.data,
    required this.displayData,
    this.readonly = false,
    this.fixedDecimals,
    this.allowNegative = true,
    this.thousandSeparator,
    this.decimalSeparator = '.',
    this.hoverEffect = false,
    this.hoverEffectTheme,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final num? data;
  final String displayData;
  final bool readonly;
  final int? fixedDecimals;
  final bool allowNegative;

  /// `thousandSeparator?: boolean | string` (`data-grid-types.ts`): null keeps
  /// the locale default (grouping on), `false` turns grouping off.
  final bool? thousandSeparator;
  final String decimalSeparator;
  final bool hoverEffect;
  final GlideHoverEffectTheme? hoverEffectTheme;

  @override
  GlideCellKind get kind => GlideCellKind.number;

  @override
  bool get isReadonly => readonly;

  GlideNumberCell copyWith({
    num? data,
    String? displayData,
    bool? readonly,
    GlideContentAlign? contentAlign,
    GlideSpan? span,
    bool? allowOverlay,
  }) => GlideNumberCell(
    data: data ?? this.data,
    displayData: displayData ?? this.displayData,
    readonly: readonly ?? this.readonly,
    fixedDecimals: fixedDecimals,
    allowNegative: allowNegative,
    thousandSeparator: thousandSeparator,
    decimalSeparator: decimalSeparator,
    hoverEffect: hoverEffect,
    hoverEffectTheme: hoverEffectTheme,
    allowOverlay: allowOverlay ?? this.allowOverlay,
    lastUpdated: lastUpdated,
    style: style,
    themeOverride: themeOverride,
    span: span ?? this.span,
    contentAlign: contentAlign ?? this.contentAlign,
    cursor: cursor,
    copyData: copyData,
    activationBehaviorOverride: activationBehaviorOverride,
  );
}

/// `ImageCell` (`data-grid-types.ts:367-373`).
class GlideImageCell extends GlideGridCell {
  const GlideImageCell({
    required this.data,
    this.rounding,
    this.displayData,
    this.readonly = false,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final List<String> data;
  final double? rounding;
  final List<String>? displayData;
  final bool readonly;

  @override
  GlideCellKind get kind => GlideCellKind.image;

  @override
  bool get isReadonly => readonly;

  GlideImageCell copyWith({List<String>? data, bool? readonly}) =>
      GlideImageCell(
        data: data ?? this.data,
        rounding: rounding,
        displayData: displayData,
        readonly: readonly ?? this.readonly,
        allowOverlay: allowOverlay,
        lastUpdated: lastUpdated,
        style: style,
        themeOverride: themeOverride,
        span: span,
        contentAlign: contentAlign,
        cursor: cursor,
        copyData: copyData,
        activationBehaviorOverride: activationBehaviorOverride,
      );
}

/// `BubbleCell` (`data-grid-types.ts:376-379`).
class GlideBubbleCell extends GlideGridCell {
  const GlideBubbleCell({
    required this.data,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final List<String> data;

  @override
  GlideCellKind get kind => GlideCellKind.bubble;
}

/// `DrilldownCellData` (`data-grid-types.ts:445-448`).
@immutable
class GlideDrilldownCellData {
  const GlideDrilldownCellData({required this.text, this.img});

  final String text;
  final String? img;
}

/// `DrilldownCell` (`data-grid-types.ts:451-454`).
class GlideDrilldownCell extends GlideGridCell {
  const GlideDrilldownCell({
    required this.data,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final List<GlideDrilldownCellData> data;

  @override
  GlideCellKind get kind => GlideCellKind.drilldown;
}

/// `BooleanCell` (`data-grid-types.ts:457-464`).
class GlideBooleanCell extends GlideGridCell {
  const GlideBooleanCell({
    required this.data,
    this.readonly = false,
    this.maxSize,
    this.hoverEffectIntensity,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  }) : super(allowOverlay: false);

  final GlideBooleanValue data;
  final bool readonly;
  final double? maxSize;
  final double? hoverEffectIntensity;

  /// `booleanCellIsEditable` (`data-grid-types.ts:468-470`).
  bool get isEditable => !readonly;

  @override
  GlideCellKind get kind => GlideCellKind.boolean;

  @override
  bool get isReadonly => readonly;

  GlideBooleanCell copyWith({
    GlideBooleanValue? data,
    bool? readonly,
    GlideSpan? span,
    GlideContentAlign? contentAlign,
    int? lastUpdated,
  }) => GlideBooleanCell(
    data: data ?? this.data,
    readonly: readonly ?? this.readonly,
    maxSize: maxSize,
    hoverEffectIntensity: hoverEffectIntensity,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    style: style,
    themeOverride: themeOverride,
    span: span ?? this.span,
    contentAlign: contentAlign ?? this.contentAlign,
    cursor: cursor,
    copyData: copyData,
    activationBehaviorOverride: activationBehaviorOverride,
  );
}

/// `RowIDCell` (`data-grid-types.ts:473-477`).
class GlideRowIdCell extends GlideGridCell {
  const GlideRowIdCell({
    required this.data,
    this.readonly = true,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final String data;
  final bool readonly;

  @override
  GlideCellKind get kind => GlideCellKind.rowID;

  @override
  bool get isReadonly => readonly;

  GlideRowIdCell copyWith({String? data, bool? readonly}) => GlideRowIdCell(
    data: data ?? this.data,
    readonly: readonly ?? this.readonly,
    allowOverlay: allowOverlay,
    lastUpdated: lastUpdated,
    style: style,
    themeOverride: themeOverride,
    span: span,
    contentAlign: contentAlign,
    cursor: cursor,
    copyData: copyData,
    activationBehaviorOverride: activationBehaviorOverride,
  );
}

/// `MarkdownCell` (`data-grid-types.ts:480-484`).
class GlideMarkdownCell extends GlideGridCell {
  const GlideMarkdownCell({
    required this.data,
    this.readonly = false,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final String data;
  final bool readonly;

  @override
  GlideCellKind get kind => GlideCellKind.markdown;

  @override
  bool get isReadonly => readonly;

  GlideMarkdownCell copyWith({String? data, bool? readonly}) => GlideMarkdownCell(
    data: data ?? this.data,
    readonly: readonly ?? this.readonly,
    allowOverlay: allowOverlay,
    lastUpdated: lastUpdated,
    style: style,
    themeOverride: themeOverride,
    span: span,
    contentAlign: contentAlign,
    cursor: cursor,
    copyData: copyData,
    activationBehaviorOverride: activationBehaviorOverride,
  );
}

/// `UriCell` (`data-grid-types.ts:487-494`).
class GlideUriCell extends GlideGridCell {
  const GlideUriCell({
    required this.data,
    this.displayData,
    this.readonly = false,
    this.onClickUri,
    this.hoverEffect = false,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  });

  final String data;
  final String? displayData;
  final bool readonly;
  final void Function(GlideItem item, String uri)? onClickUri;
  final bool hoverEffect;

  @override
  GlideCellKind get kind => GlideCellKind.uri;

  @override
  bool get isReadonly => readonly;

  GlideUriCell copyWith({String? data, String? displayData, bool? readonly}) =>
      GlideUriCell(
        data: data ?? this.data,
        displayData: displayData ?? this.displayData,
        readonly: readonly ?? this.readonly,
        onClickUri: onClickUri,
        hoverEffect: hoverEffect,
        allowOverlay: allowOverlay,
        lastUpdated: lastUpdated,
        style: style,
        themeOverride: themeOverride,
        span: span,
        contentAlign: contentAlign,
        cursor: cursor,
        copyData: copyData,
        activationBehaviorOverride: activationBehaviorOverride,
      );
}

/// `CustomCell` (`data-grid-types.ts:437-442`).
class GlideCustomCell<T> extends GlideGridCell {
  const GlideCustomCell({
    required this.data,
    required super.copyData,
    this.readonly = false,
    super.allowOverlay,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.activationBehaviorOverride,
  });

  final T data;
  final bool readonly;

  @override
  GlideCellKind get kind => GlideCellKind.custom;

  @override
  bool get isReadonly => readonly;

  GlideCustomCell<T> copyWith({T? data, String? copyData, bool? readonly}) =>
      GlideCustomCell<T>(
        data: data ?? this.data,
        copyData: copyData ?? this.copyData!,
        readonly: readonly ?? this.readonly,
        allowOverlay: allowOverlay,
        lastUpdated: lastUpdated,
        style: style,
        themeOverride: themeOverride,
        span: span,
        contentAlign: contentAlign,
        cursor: cursor,
        activationBehaviorOverride: activationBehaviorOverride,
      );
}

/// `NewRowCell` (`data-grid-types.ts:505-510`).
class GlideNewRowCell extends GlideGridCell {
  const GlideNewRowCell({
    required this.hint,
    this.icon,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  }) : super(allowOverlay: false);

  final String hint;
  final GlideColumnIcon? icon;

  @override
  GlideCellKind get kind => GlideCellKind.newRow;
}

/// `MarkerCell` (`data-grid-types.ts:513-521`).
class GlideMarkerCell extends GlideGridCell {
  const GlideMarkerCell({
    required this.row,
    required this.drawHandle,
    required this.checked,
    required this.checkboxStyle,
    required this.markerKind,
    super.lastUpdated,
    super.style,
    super.themeOverride,
    super.span,
    super.contentAlign,
    super.cursor,
    super.copyData,
    super.activationBehaviorOverride,
  }) : super(allowOverlay: false);

  final int row;
  final bool drawHandle;
  final GlideBooleanValue checked;
  final GlideMarkerCheckboxStyle checkboxStyle;
  final GlideMarkerKind markerKind;

  @override
  GlideCellKind get kind => GlideCellKind.marker;
}

/// `checkboxStyle: "square" | "circle"` (`data-grid-types.ts:519`).
enum GlideMarkerCheckboxStyle { square, circle }

/// `RowMarkerOptions["kind"]` (`data-editor.tsx:98`).
enum GlideRowMarkerKind {
  none,
  checkbox,
  number,
  clickableNumber,
  checkboxVisible,
  both,
}

/// `RowMarkerOptions` (`data-editor.tsx:97-106`).
@immutable
class GlideRowMarkerOptions {
  const GlideRowMarkerOptions({
    this.kind = GlideRowMarkerKind.checkbox,
    this.checkboxStyle = GlideMarkerCheckboxStyle.square,
    this.startIndex = 1,
    this.width,
    this.theme,
    this.headerTheme,
    this.headerAlwaysVisible = false,
    this.headerDisabled = false,
  });

  final GlideRowMarkerKind kind;
  final GlideMarkerCheckboxStyle checkboxStyle;
  final int startIndex;

  /// Unset → sized from the row count (`data-editor.tsx:952`).
  final double? width;
  final GlideThemeOverride? theme;
  final GlideThemeOverride? headerTheme;
  final bool headerAlwaysVisible;
  final bool headerDisabled;
}

/// `markerKind: "checkbox" | "number" | "both" | "checkbox-visible"`
/// (`data-grid-types.ts:520`).
enum GlideMarkerKind { checkbox, number, both, checkboxVisible }

/// `isInnerOnlyCell` (`data-grid-types.ts:256-258`).
bool isInnerOnlyCell(GlideGridCell cell) =>
    cell is GlideMarkerCell || cell is GlideNewRowCell;

/// `isEditableGridCell` (`data-grid-types.ts:221-234`).
bool isEditableGridCell(GlideGridCell cell) => switch (cell) {
  GlideLoadingCell() ||
  GlideBubbleCell() ||
  GlideRowIdCell() ||
  GlideProtectedCell() ||
  GlideDrilldownCell() ||
  GlideMarkerCell() ||
  GlideNewRowCell() => false,
  _ => true,
};

/// `isTextEditableGridCell` (`data-grid-types.ts:237-253`).
bool isTextEditableGridCell(GlideGridCell cell) => switch (cell) {
  GlideTextCell() ||
  GlideNumberCell() ||
  GlideMarkdownCell() ||
  GlideUriCell() => true,
  _ => false,
};

/// `ReadWriteGridCell`. Dart lacks the union, so this narrows to the
/// `readonly` flag on editable kinds.
bool isReadWriteCell(GlideGridCell cell) {
  if (!isEditableGridCell(cell)) return false;
  return switch (cell) {
    GlideTextCell(:final readonly) => !readonly,
    GlideNumberCell(:final readonly) => !readonly,
    GlideMarkdownCell(:final readonly) => !readonly,
    GlideUriCell(:final readonly) => !readonly,
    GlideCustomCell(:final readonly) => !readonly,
    GlideBooleanCell(:final readonly) => !readonly,
    _ => false,
  };
}

/// `EditListItem` (`data-grid-types.ts:502`).
@immutable
class GlideEditListItem {
  const GlideEditListItem({required this.location, required this.value});

  final GlideItem location;
  final GlideGridCell value;
}

/// `CellArray` (`data-grid-types.ts:133`).
typedef GlideCellArray = List<List<GlideGridCell>>;

/// `GetCellsThunk` (`data-grid-types.ts:191`).
typedef GlideGetCellsThunk = Future<GlideCellArray> Function();

/// `resolveCellsThunk` (`data-grid-types.ts:185-188`).
Future<GlideCellArray> resolveCellsThunk(Object thunk) async {
  if (thunk is GlideCellArray) return thunk;
  return await (thunk as GlideGetCellsThunk)();
}

/// `trailingRowOptions` (`data-grid-types.ts:159-165`).
@immutable
class GlideTrailingRowOptions {
  const GlideTrailingRowOptions({
    this.hint,
    this.addIcon,
    this.targetColumn,
    this.themeOverride,
    this.disabled = false,
    this.tint = false,
    this.sticky = false,
  });

  final String? hint;
  final GlideColumnIcon? addIcon;

  /// `number | GridColumn`; an int column index or a [GlideGridColumn].
  final Object? targetColumn;
  final GlideThemeOverride? themeOverride;
  final bool disabled;

  /// Editor-level extras (`data-editor.tsx:291-306`).
  final bool tint;

  /// Keeps the trailing row pinned while scrolling.
  final bool sticky;
}

/// `BaseGridColumn` (`data-grid-types.ts:148-166`).
@immutable
class GlideGridColumn {
  const GlideGridColumn({
    required this.title,
    this.width,
    this.id,
    this.group,
    this.icon,
    this.overlayIcon,
    this.menuIcon,
    this.indicatorIcon,
    this.hasMenu = false,
    this.grow,
    this.style,
    this.themeOverride,
    this.trailingRowOptions,
    this.extension,
  }) : assert(
         width != null || id != null,
         'a column must be sized (width) or auto sized (id)',
       );

  final String title;

  /// `SizedGridColumn.width` (`:175`); null means the column is auto sized and
  /// needs measuring (`use-column-sizer`).
  final double? width;
  final String? id;
  final String? group;
  final GlideColumnIcon? icon;
  final GlideColumnIcon? overlayIcon;
  final GlideColumnMenuIcon? menuIcon;
  final GlideColumnIcon? indicatorIcon;
  final bool hasMenu;
  final int? grow;
  final GlideColumnStyle? style;
  final GlideThemeOverride? themeOverride;
  final GlideTrailingRowOptions? trailingRowOptions;

  /// `InnerColumnExtension` (`data-grid-types.ts:196-203`), merged into the
  /// column type upstream.
  final GlideInnerColumnExtension? extension;

  /// `isSizedGridColumn` (`data-grid-types.ts:169-171`).
  bool get isSized => width != null;

  GlideGridColumn copyWith({
    String? title,
    double? width,
    String? id,
    Object? group = _sentinel,
    Object? icon = _sentinel,
    GlideColumnStyle? style,
    GlideThemeOverride? themeOverride,
    GlideTrailingRowOptions? trailingRowOptions,
    GlideInnerColumnExtension? extension,
  }) => GlideGridColumn(
    title: title ?? this.title,
    width: width ?? this.width,
    id: id ?? this.id,
    group: group == _sentinel ? this.group : group as String?,
    icon: icon == _sentinel ? this.icon : icon as GlideColumnIcon?,
    overlayIcon: overlayIcon,
    menuIcon: menuIcon,
    indicatorIcon: indicatorIcon,
    hasMenu: hasMenu,
    grow: grow,
    style: style ?? this.style,
    themeOverride: themeOverride ?? this.themeOverride,
    trailingRowOptions: trailingRowOptions ?? this.trailingRowOptions,
    extension: extension ?? this.extension,
  );
}

const Object _sentinel = Object();

/// `InnerColumnExtension` (`data-grid-types.ts:196-203`), mirrored on the
/// column so row-marker bookkeeping can live next to the column it describes.
@immutable
class GlideInnerColumnExtension {
  const GlideInnerColumnExtension({
    this.growOffset,
    this.rowMarker,
    this.rowMarkerChecked,
    this.headerRowMarkerTheme,
    this.headerRowMarkerAlwaysVisible = false,
    this.headerRowMarkerDisabled = false,
  });

  final int? growOffset;
  final GlideMarkerCheckboxStyle? rowMarker;
  final GlideBooleanValue? rowMarkerChecked;
  final GlideThemeOverride? headerRowMarkerTheme;
  final bool headerRowMarkerAlwaysVisible;
  final bool headerRowMarkerDisabled;

  GlideInnerColumnExtension copyWith({
    int? growOffset,
    GlideMarkerCheckboxStyle? rowMarker,
    GlideBooleanValue? rowMarkerChecked,
    GlideThemeOverride? headerRowMarkerTheme,
    bool? headerRowMarkerAlwaysVisible,
    bool? headerRowMarkerDisabled,
  }) => GlideInnerColumnExtension(
    growOffset: growOffset ?? this.growOffset,
    rowMarker: rowMarker ?? this.rowMarker,
    rowMarkerChecked: rowMarkerChecked ?? this.rowMarkerChecked,
    headerRowMarkerTheme: headerRowMarkerTheme ?? this.headerRowMarkerTheme,
    headerRowMarkerAlwaysVisible:
        headerRowMarkerAlwaysVisible ?? this.headerRowMarkerAlwaysVisible,
    headerRowMarkerDisabled:
        headerRowMarkerDisabled ?? this.headerRowMarkerDisabled,
  );
}

/// `FillHandleDirection` (`data-grid-types.ts:528`).
enum GlideFillHandleDirection { horizontal, vertical, orthogonal, any }

/// `FillHandleConfig` (`data-grid-types.ts:539-545`).
@immutable
class GlideFillHandleConfig {
  const GlideFillHandleConfig({
    this.shape = GlideFillHandleShape.square,
    this.size = 4,
    this.offsetX = -2,
    this.offsetY = -2,
    this.outline = 0,
  });

  final GlideFillHandleShape shape;
  final double size;
  final double offsetX;
  final double offsetY;
  final double outline;

  @override
  bool operator ==(Object other) =>
      other is GlideFillHandleConfig &&
      other.shape == shape &&
      other.size == size &&
      other.offsetX == offsetX &&
      other.offsetY == offsetY &&
      other.outline == outline;

  @override
  int get hashCode => Object.hash(shape, size, offsetX, offsetY, outline);
}

/// `resizeIndicator: "full" | "header" | "none"` (`data-grid.tsx:311`).
enum GlideResizeIndicator { full, header, none }

/// `shape: "square" | "circle"` (`data-grid-types.ts:540`).
enum GlideFillHandleShape { square, circle }

/// `DEFAULT_FILL_HANDLE` (`data-grid-types.ts:552-558`).
const GlideFillHandleConfig defaultFillHandle = GlideFillHandleConfig();

/// `SelectionRange = number | readonly [number, number]`
/// (`data-grid-types.ts:382`).
typedef GlideSelectionRange = Object;
