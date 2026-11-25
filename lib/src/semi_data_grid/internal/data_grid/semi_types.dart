// Port of `packages/core/src/internal/data-grid/data-grid-types.ts`.
//
// Translation notes (apply to every ported file):
// - TS unions over `kind` become a Dart `sealed class` hierarchy. `switch` on
//   `cell.kind` becomes exhaustive pattern matching, which the compiler checks
//   the same way `assertNever` did upstream.
// - `Item = readonly [col, row]` becomes [SemiItem]; the constructor is
//   positional in tuple order (`SemiItem(col, row)`) on purpose, so a
//   transposed call looks wrong at the call site.
// - `BooleanCell.data: boolean | null | undefined` has three states; Dart's
//   `bool?` only has two, so the tri-state is modelled by [SemiBooleanValue].
import 'package:flutter/widgets.dart';

import '../../common/semi_data_grid_theme.dart';
import 'semi_selection.dart';

export 'semi_selection.dart';

/// `Item = readonly [col, row]` (`data-grid-types.ts:146`).
///
/// Positive rows are cells, `-1` is the header row and `-2` the group header.
@immutable
class SemiItem {
  const SemiItem(this.col, this.row);

  final int col;
  final int row;

  static const int headerRow = -1;
  static const int groupHeaderRow = -2;

  SemiItem offset(int colDelta, int rowDelta) =>
      SemiItem(col + colDelta, row + rowDelta);

  @override
  bool operator ==(Object other) =>
      other is SemiItem && other.col == col && other.row == row;

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => '[$col, $row]';
}

/// `Rectangle` (`data-grid-types.ts:295-300`).
@immutable
class SemiRectangle {
  const SemiRectangle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  const SemiRectangle.empty()
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

  SemiRectangle copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) => SemiRectangle(
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
  );

  SemiRectangle translate(double dx, double dy) =>
      SemiRectangle(x: x + dx, y: y + dy, width: width, height: height);

  SemiRectangle inflate(double dx, double dy) => SemiRectangle(
    x: x - dx,
    y: y - dy,
    width: width + dx * 2,
    height: height + dy * 2,
  );

  bool containsPoint(double px, double py) =>
      px >= x && px < x + width && py >= y && py < y + height;

  /// `itemIsInRect` (`render/data-grid-lib.ts:87-91`).
  bool containsItem(SemiItem item) =>
      item.col >= x &&
      item.col < x + width &&
      item.row >= y &&
      item.row < y + height;

  @override
  bool operator ==(Object other) =>
      other is SemiRectangle &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() =>
      'SemiRectangle(x: $x, y: $y, w: $width, h: $height)';
}

bool isRectangleEqual(SemiRectangle? a, SemiRectangle? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return a == b;
}

/// `GridCellKind` (`data-grid-types.ts:79-92`).
enum SemiCellKind {
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
/// (`data-grid-types.ts:157`) — see [SemiColumnStyle]. The two were briefly
/// conflated in this port, which made `"highlight"` unrepresentable.
enum SemiCellStyle { normal, faded }

/// `GridColumn.style`: `"normal" | "highlight"` (`data-grid-types.ts:157`).
///
/// Drives the sprite variant a header icon is drawn with
/// (`data-grid-render.header.ts:467-469`).
enum SemiColumnStyle { normal, highlight }

/// `"left" | "right" | "center"` (`data-grid-types.ts:317`).
enum SemiContentAlign { left, right, center }

/// `"label" | "square"` icon slots are `String` upstream (sprite ids).
typedef SemiColumnIcon = String;

/// `"triangle" | "dots"` (`data-grid-types.ts:127-130`).
enum SemiColumnMenuIcon { triangle, dots }

/// `"double-click" | "single-click" | "second-click"`
/// (`data-grid-types.ts:308`).
enum SemiCellActivationBehavior { doubleClick, singleClick, secondClick }

/// `[start, end]` inclusive span (`data-grid-types.ts:316`).
typedef SemiSpan = ({int start, int end});

/// `GridSelection` (`data-grid-types.ts:17-25`).
@immutable
class SemiGridSelection {
  const SemiGridSelection({
    this.current,
    this.columns = const SemiCompactSelection.empty(),
    this.rows = const SemiCompactSelection.empty(),
  });

  static const SemiGridSelection empty = SemiGridSelection();

  /// `current` block (`:18-22`). `rangeStack` is lowest to highest and does not
  /// include `range`.
  final SemiGridSelectionCurrent? current;
  final SemiCompactSelection columns;
  final SemiCompactSelection rows;

  SemiGridSelection copyWith({
    SemiGridSelectionCurrent? current,
    bool clearCurrent = false,
    SemiCompactSelection? columns,
    SemiCompactSelection? rows,
  }) => SemiGridSelection(
    current: clearCurrent ? null : (current ?? this.current),
    columns: columns ?? this.columns,
    rows: rows ?? this.rows,
  );

  /// `gridSelectionHasItem` (`render/data-grid-lib.ts:57-69`).
  bool hasItem(SemiItem item) {
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
      other is SemiGridSelection &&
      other.current == current &&
      other.columns == columns &&
      other.rows == rows;

  @override
  int get hashCode => Object.hash(current, columns, rows);
}

/// `current` of [SemiGridSelection].
@immutable
class SemiGridSelectionCurrent {
  const SemiGridSelectionCurrent({
    required this.cell,
    required this.range,
    this.rangeStack = const [],
  });

  final SemiItem cell;
  final SemiRectangle range;
  final List<SemiRectangle> rangeStack;

  SemiGridSelectionCurrent copyWith({
    SemiItem? cell,
    SemiRectangle? range,
    List<SemiRectangle>? rangeStack,
  }) => SemiGridSelectionCurrent(
    cell: cell ?? this.cell,
    range: range ?? this.range,
    rangeStack: rangeStack ?? this.rangeStack,
  );

  @override
  bool operator ==(Object other) =>
      other is SemiGridSelectionCurrent &&
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
enum SemiBooleanValue {
  empty,
  indeterminate,
  checked,
  unchecked;

  bool? get asBool => switch (this) {
    checked => true,
    unchecked => false,
    empty || indeterminate => null,
  };

  static SemiBooleanValue fromBool(bool? value) => switch (value) {
    true => checked,
    false => unchecked,
    null => empty,
  };
}

/// `HoverEffectTheme` (`data-grid-types.ts:336-339`).
@immutable
class SemiHoverEffectTheme {
  const SemiHoverEffectTheme({required this.bgColor, required this.fullSize});

  final Color bgColor;
  final bool fullSize;
}

/// `BaseGridCell` (`data-grid-types.ts:311-321`).
sealed class SemiGridCell {
  const SemiGridCell({
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
  final SemiCellStyle? style;
  final SemiThemeOverride? themeOverride;
  final SemiSpan? span;
  final SemiContentAlign? contentAlign;
  final MouseCursor? cursor;
  final String? copyData;
  final SemiCellActivationBehavior? activationBehaviorOverride;

  SemiCellKind get kind;

  /// `readonly` is only meaningful on editable cells; exposed uniformly so
  /// selection/editing code can ask once.
  bool get isReadonly => false;
}

/// `LoadingCell` (`data-grid-types.ts:324-329`).
class SemiLoadingCell extends SemiGridCell {
  /// `allowOverlay` defaults to false because the grid's own `loadingCell`
  /// is `{ kind: Loading, allowOverlay: false }` (`data-editor.tsx:762-765`),
  /// so a loading cell never opens an empty overlay.
  const SemiLoadingCell({
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
  SemiCellKind get kind => SemiCellKind.loading;
}

/// `ProtectedCell` (`data-grid-types.ts:331-334`).
class SemiProtectedCell extends SemiGridCell {
  /// `allowOverlay` defaults to false: the protected cell has no
  /// `provideEditor` (`protected-cell.tsx`), and upstream's own examples
  /// always pass `allowOverlay: false`.
  const SemiProtectedCell({
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
  SemiCellKind get kind => SemiCellKind.protected;
}

/// `TextCell` (`data-grid-types.ts:342-350`).
class SemiTextCell extends SemiGridCell {
  const SemiTextCell({
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
  final SemiHoverEffectTheme? hoverEffectTheme;

  @override
  SemiCellKind get kind => SemiCellKind.text;

  @override
  bool get isReadonly => readonly;

  SemiTextCell copyWith({
    String? data,
    String? displayData,
    bool? readonly,
    bool? allowWrapping,
    SemiContentAlign? contentAlign,
    SemiSpan? span,
    bool? allowOverlay,
  }) => SemiTextCell(
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
class SemiNumberCell extends SemiGridCell {
  const SemiNumberCell({
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
  final SemiHoverEffectTheme? hoverEffectTheme;

  @override
  SemiCellKind get kind => SemiCellKind.number;

  @override
  bool get isReadonly => readonly;

  SemiNumberCell copyWith({
    num? data,
    bool clearData = false,
    String? displayData,
    bool? readonly,
    SemiContentAlign? contentAlign,
    SemiSpan? span,
    bool? allowOverlay,
  }) => SemiNumberCell(
    data: clearData ? null : data ?? this.data,
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
class SemiImageCell extends SemiGridCell {
  const SemiImageCell({
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
  SemiCellKind get kind => SemiCellKind.image;

  @override
  bool get isReadonly => readonly;

  SemiImageCell copyWith({List<String>? data, bool? readonly}) =>
      SemiImageCell(
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
class SemiBubbleCell extends SemiGridCell {
  const SemiBubbleCell({
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
  SemiCellKind get kind => SemiCellKind.bubble;
}

/// `DrilldownCellData` (`data-grid-types.ts:445-448`).
@immutable
class SemiDrilldownCellData {
  const SemiDrilldownCellData({required this.text, this.img});

  final String text;
  final String? img;
}

/// `DrilldownCell` (`data-grid-types.ts:451-454`).
class SemiDrilldownCell extends SemiGridCell {
  const SemiDrilldownCell({
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

  final List<SemiDrilldownCellData> data;

  @override
  SemiCellKind get kind => SemiCellKind.drilldown;
}

/// `BooleanCell` (`data-grid-types.ts:457-464`).
class SemiBooleanCell extends SemiGridCell {
  const SemiBooleanCell({
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

  final SemiBooleanValue data;
  final bool readonly;
  final double? maxSize;
  final double? hoverEffectIntensity;

  /// `booleanCellIsEditable` (`data-grid-types.ts:468-470`).
  bool get isEditable => !readonly;

  @override
  SemiCellKind get kind => SemiCellKind.boolean;

  @override
  bool get isReadonly => readonly;

  SemiBooleanCell copyWith({
    SemiBooleanValue? data,
    bool? readonly,
    SemiSpan? span,
    SemiContentAlign? contentAlign,
    int? lastUpdated,
  }) => SemiBooleanCell(
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
class SemiRowIdCell extends SemiGridCell {
  const SemiRowIdCell({
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
  SemiCellKind get kind => SemiCellKind.rowID;

  @override
  bool get isReadonly => readonly;

  SemiRowIdCell copyWith({String? data, bool? readonly}) => SemiRowIdCell(
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
class SemiMarkdownCell extends SemiGridCell {
  const SemiMarkdownCell({
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
  SemiCellKind get kind => SemiCellKind.markdown;

  @override
  bool get isReadonly => readonly;

  SemiMarkdownCell copyWith({String? data, bool? readonly}) => SemiMarkdownCell(
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
class SemiUriCell extends SemiGridCell {
  const SemiUriCell({
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
  final void Function(SemiItem item, String uri)? onClickUri;
  final bool hoverEffect;

  @override
  SemiCellKind get kind => SemiCellKind.uri;

  @override
  bool get isReadonly => readonly;

  SemiUriCell copyWith({String? data, String? displayData, bool? readonly}) =>
      SemiUriCell(
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
class SemiCustomCell<T> extends SemiGridCell {
  const SemiCustomCell({
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
  SemiCellKind get kind => SemiCellKind.custom;

  @override
  bool get isReadonly => readonly;

  SemiCustomCell<T> copyWith({T? data, String? copyData, bool? readonly}) =>
      SemiCustomCell<T>(
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
class SemiNewRowCell extends SemiGridCell {
  const SemiNewRowCell({
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
  final SemiColumnIcon? icon;

  @override
  SemiCellKind get kind => SemiCellKind.newRow;
}

/// `MarkerCell` (`data-grid-types.ts:513-521`).
class SemiMarkerCell extends SemiGridCell {
  const SemiMarkerCell({
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
  final SemiBooleanValue checked;
  final SemiMarkerCheckboxStyle checkboxStyle;
  final SemiMarkerKind markerKind;

  @override
  SemiCellKind get kind => SemiCellKind.marker;
}

/// `checkboxStyle: "square" | "circle"` (`data-grid-types.ts:519`).
enum SemiMarkerCheckboxStyle { square, circle }

/// `RowMarkerOptions["kind"]` (`data-editor.tsx:98`).
enum SemiRowMarkerKind {
  none,
  checkbox,
  number,
  clickableNumber,
  checkboxVisible,
  both,
}

/// `RowMarkerOptions` (`data-editor.tsx:97-106`).
@immutable
class SemiRowMarkerOptions {
  const SemiRowMarkerOptions({
    this.kind = SemiRowMarkerKind.checkbox,
    this.checkboxStyle = SemiMarkerCheckboxStyle.square,
    this.startIndex = 1,
    this.width,
    this.theme,
    this.headerTheme,
    this.headerAlwaysVisible = false,
    this.headerDisabled = false,
  });

  final SemiRowMarkerKind kind;
  final SemiMarkerCheckboxStyle checkboxStyle;
  final int startIndex;

  /// Unset → sized from the row count (`data-editor.tsx:952`).
  final double? width;
  final SemiThemeOverride? theme;
  final SemiThemeOverride? headerTheme;
  final bool headerAlwaysVisible;
  final bool headerDisabled;
}

/// `markerKind: "checkbox" | "number" | "both" | "checkbox-visible"`
/// (`data-grid-types.ts:520`).
enum SemiMarkerKind { checkbox, number, both, checkboxVisible }

/// `isInnerOnlyCell` (`data-grid-types.ts:256-258`).
bool isInnerOnlyCell(SemiGridCell cell) =>
    cell is SemiMarkerCell || cell is SemiNewRowCell;

/// `isEditableGridCell` (`data-grid-types.ts:221-234`).
bool isEditableGridCell(SemiGridCell cell) => switch (cell) {
  SemiLoadingCell() ||
  SemiBubbleCell() ||
  SemiRowIdCell() ||
  SemiProtectedCell() ||
  SemiDrilldownCell() ||
  SemiMarkerCell() ||
  SemiNewRowCell() => false,
  _ => true,
};

/// `isTextEditableGridCell` (`data-grid-types.ts:237-253`).
bool isTextEditableGridCell(SemiGridCell cell) => switch (cell) {
  SemiTextCell() ||
  SemiNumberCell() ||
  SemiMarkdownCell() ||
  SemiUriCell() => true,
  _ => false,
};

/// `ReadWriteGridCell`. Dart lacks the union, so this narrows to the
/// `readonly` flag on editable kinds.
bool isReadWriteCell(SemiGridCell cell) {
  if (!isEditableGridCell(cell)) return false;
  return switch (cell) {
    SemiTextCell(:final readonly) => !readonly,
    SemiNumberCell(:final readonly) => !readonly,
    SemiMarkdownCell(:final readonly) => !readonly,
    SemiUriCell(:final readonly) => !readonly,
    SemiCustomCell(:final readonly) => !readonly,
    SemiBooleanCell(:final readonly) => !readonly,
    _ => false,
  };
}

/// `EditListItem` (`data-grid-types.ts:502`).
@immutable
class SemiEditListItem {
  const SemiEditListItem({required this.location, required this.value});

  final SemiItem location;
  final SemiGridCell value;
}

/// `CellArray` (`data-grid-types.ts:133`).
typedef SemiCellArray = List<List<SemiGridCell>>;

/// `GetCellsThunk` (`data-grid-types.ts:191`).
typedef SemiGetCellsThunk = Future<SemiCellArray> Function();

/// `resolveCellsThunk` (`data-grid-types.ts:185-188`).
Future<SemiCellArray> resolveCellsThunk(Object thunk) async {
  if (thunk is SemiCellArray) return thunk;
  return await (thunk as SemiGetCellsThunk)();
}

/// `trailingRowOptions` (`data-grid-types.ts:159-165`).
@immutable
class SemiTrailingRowOptions {
  const SemiTrailingRowOptions({
    this.hint,
    this.addIcon,
    this.targetColumn,
    this.themeOverride,
    this.disabled = false,
    this.tint = false,
    this.sticky = false,
  });

  final String? hint;
  final SemiColumnIcon? addIcon;

  /// `number | GridColumn`; an int column index or a [SemiGridColumn].
  final Object? targetColumn;
  final SemiThemeOverride? themeOverride;
  final bool disabled;

  /// Editor-level extras (`data-editor.tsx:291-306`).
  final bool tint;

  /// Keeps the trailing row pinned while scrolling.
  final bool sticky;
}

/// `BaseGridColumn` (`data-grid-types.ts:148-166`).
@immutable
class SemiGridColumn {
  const SemiGridColumn({
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
  final SemiColumnIcon? icon;
  final SemiColumnIcon? overlayIcon;
  final SemiColumnMenuIcon? menuIcon;
  final SemiColumnIcon? indicatorIcon;
  final bool hasMenu;
  final int? grow;
  final SemiColumnStyle? style;
  final SemiThemeOverride? themeOverride;
  final SemiTrailingRowOptions? trailingRowOptions;

  /// `InnerColumnExtension` (`data-grid-types.ts:196-203`), merged into the
  /// column type upstream.
  final SemiInnerColumnExtension? extension;

  /// `isSizedGridColumn` (`data-grid-types.ts:169-171`).
  bool get isSized => width != null;

  SemiGridColumn copyWith({
    String? title,
    double? width,
    String? id,
    Object? group = _sentinel,
    Object? icon = _sentinel,
    SemiColumnStyle? style,
    SemiThemeOverride? themeOverride,
    SemiTrailingRowOptions? trailingRowOptions,
    SemiInnerColumnExtension? extension,
  }) => SemiGridColumn(
    title: title ?? this.title,
    width: width ?? this.width,
    id: id ?? this.id,
    group: group == _sentinel ? this.group : group as String?,
    icon: icon == _sentinel ? this.icon : icon as SemiColumnIcon?,
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
class SemiInnerColumnExtension {
  const SemiInnerColumnExtension({
    this.growOffset,
    this.rowMarker,
    this.rowMarkerChecked,
    this.headerRowMarkerTheme,
    this.headerRowMarkerAlwaysVisible = false,
    this.headerRowMarkerDisabled = false,
  });

  final int? growOffset;
  final SemiMarkerCheckboxStyle? rowMarker;
  final SemiBooleanValue? rowMarkerChecked;
  final SemiThemeOverride? headerRowMarkerTheme;
  final bool headerRowMarkerAlwaysVisible;
  final bool headerRowMarkerDisabled;

  SemiInnerColumnExtension copyWith({
    int? growOffset,
    SemiMarkerCheckboxStyle? rowMarker,
    SemiBooleanValue? rowMarkerChecked,
    SemiThemeOverride? headerRowMarkerTheme,
    bool? headerRowMarkerAlwaysVisible,
    bool? headerRowMarkerDisabled,
  }) => SemiInnerColumnExtension(
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
enum SemiFillHandleDirection { horizontal, vertical, orthogonal, any }

/// `FillHandleConfig` (`data-grid-types.ts:539-545`).
@immutable
class SemiFillHandleConfig {
  const SemiFillHandleConfig({
    this.shape = SemiFillHandleShape.square,
    this.size = 4,
    this.offsetX = -2,
    this.offsetY = -2,
    this.outline = 0,
  });

  final SemiFillHandleShape shape;
  final double size;
  final double offsetX;
  final double offsetY;
  final double outline;

  @override
  bool operator ==(Object other) =>
      other is SemiFillHandleConfig &&
      other.shape == shape &&
      other.size == size &&
      other.offsetX == offsetX &&
      other.offsetY == offsetY &&
      other.outline == outline;

  @override
  int get hashCode => Object.hash(shape, size, offsetX, offsetY, outline);
}

/// `resizeIndicator: "full" | "header" | "none"` (`data-grid.tsx:311`).
enum SemiResizeIndicator { full, header, none }

/// `shape: "square" | "circle"` (`data-grid-types.ts:540`).
enum SemiFillHandleShape { square, circle }

/// `DEFAULT_FILL_HANDLE` (`data-grid-types.ts:552-558`).
const SemiFillHandleConfig defaultFillHandle = SemiFillHandleConfig();

/// `SelectionRange = number | readonly [number, number]`
/// (`data-grid-types.ts:382`).
typedef SemiSelectionRange = Object;
