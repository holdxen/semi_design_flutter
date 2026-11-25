// Port of `packages/core/src/cells/cell-types.ts`.
//
// `BaseDrawArgs` carries the canvas context upstream; in Flutter the `Canvas`
// is passed explicitly to [SemiCellRenderer.draw] because a `canvas.save()`
// pair around every cell would be much more expensive than in the DOM version.
// React's `requestAnimationFrame` state hook has no place here: renderers can
// call `args.requestAnimationFrame()` to ask the grid for another frame.
import 'package:flutter/widgets.dart';

import '../common/semi_image_window_loader.dart';
import '../common/semi_data_grid_theme.dart';
import '../internal/data_grid/semi_geometry.dart';
import '../internal/data_grid/semi_types.dart';

export '../internal/data_grid/semi_types.dart';
export '../internal/data_grid/semi_geometry.dart';
export '../common/semi_data_grid_theme.dart';

/// `BaseDrawArgs` (`cell-types.ts:16-31`).
class SemiDrawCellArgs {
  SemiDrawCellArgs({
    required this.canvas,
    required this.theme,
    required this.col,
    required this.row,
    required this.rect,
    required this.cell,
    required this.highlighted,
    this.hoverAmount = 0,
    this.hoverX,
    this.hoverY,
    this.cellFillColor,
    this.hyperWrapping = false,
    this.frameTime = 0,
    this.metrics,
    this.requestAnimationFrame,
    this.imageLoader,
  });

  final Canvas canvas;
  final SemiDataGridTheme theme;
  final int col;
  final int row;
  final SemiRectangle rect;
  final SemiGridCell cell;
  final bool highlighted;

  /// `hoverAmount` animates 0→1 over 80ms (`animation-manager.ts:67-94`).
  final double hoverAmount;
  final double? hoverX;
  final double? hoverY;

  /// Background the cell will be composited over; renderers use it for
  /// "knock-out" strokes (checkbox ticks, loading bars).
  final Color? cellFillColor;
  final bool hyperWrapping;
  final int frameTime;
  final SemiTextMetrics? metrics;

  /// `requestAnimationFrame(state?)` (`cell-types.ts:39`). Returning a value
  /// stores it as the renderer's per-cell draw state for the next frame.
  final void Function([Object? state])? requestAnimationFrame;

  /// `imageLoader` (`cell-types.ts:27`): resolved images for image cells.
  final SemiImageWindowLoader? imageLoader;

  SemiDrawCellArgs copyWith({
    int? col,
    SemiRectangle? rect,
    SemiGridCell? cell,
    bool? highlighted,
    double? hoverAmount,
  }) => SemiDrawCellArgs(
    canvas: canvas,
    theme: theme,
    col: col ?? this.col,
    row: row,
    rect: rect ?? this.rect,
    cell: cell ?? this.cell,
    highlighted: highlighted ?? this.highlighted,
    hoverAmount: hoverAmount ?? this.hoverAmount,
    hoverX: hoverX,
    hoverY: hoverY,
    cellFillColor: cellFillColor,
    hyperWrapping: hyperWrapping,
    frameTime: frameTime,
    metrics: metrics,
    requestAnimationFrame: requestAnimationFrame,
    imageLoader: imageLoader,
  );
}

/// `DrawHeaderCallback` (`data-grid-types.ts:41-60`): replaces the default
/// header paint. Call [drawContent] to run it, or do not and take over.
typedef SemiDrawHeaderCallback =
    void Function(SemiDrawHeaderArgs args, VoidCallback drawContent);

/// `DrawCellCallback` (`data-grid-types.ts:61-76`): same contract for cells.
typedef SemiDrawCellCallback =
    void Function(SemiDrawCellArgs args, VoidCallback drawContent);

/// The `args` half of [SemiDrawHeaderCallback]
/// (`data-grid-types.ts:42-59`).
@immutable
class SemiDrawHeaderArgs {
  const SemiDrawHeaderArgs({
    required this.canvas,
    required this.theme,
    required this.rect,
    required this.column,
    required this.columnIndex,
    required this.isSelected,
    required this.hoverAmount,
    required this.isHovered,
    required this.hasSelectedCell,
    required this.menuBounds,
    this.hoverX,
    this.hoverY,
  });

  final Canvas canvas;
  final SemiDataGridTheme theme;

  /// The header cell's box, in grid coordinates.
  final SemiRectangle rect;
  final SemiMappedColumn column;

  /// `columnIndex` is the *mangled* index; `SemiDataEditorProps.drawHeader`
  /// strips the row-marker column before handing it to a consumer.
  final int columnIndex;
  final bool isSelected;
  final double hoverAmount;
  final bool isHovered;
  final bool hasSelectedCell;

  /// `menuBounds` (`data-grid-types.ts:53`): where the header menu button
  /// sits, for a consumer that wants to draw it.
  final SemiRectangle menuBounds;
  final double? hoverX;
  final double? hoverY;

  SemiDrawHeaderArgs copyWith({int? columnIndex}) => SemiDrawHeaderArgs(
    canvas: canvas,
    theme: theme,
    rect: rect,
    column: column,
    columnIndex: columnIndex ?? this.columnIndex,
    isSelected: isSelected,
    hoverAmount: hoverAmount,
    isHovered: isHovered,
    hasSelectedCell: hasSelectedCell,
    menuBounds: menuBounds,
    hoverX: hoverX,
    hoverY: hoverY,
  );
}

/// `details` passed to `onPaste` (`cell-types.ts:102-108`).
@immutable
class SemiPasteDetails {
  const SemiPasteDetails({
    this.rawValue,
    this.formatted,
    this.formattedString,
  });

  final Object? rawValue;
  final Object? formatted;
  final String? formattedString;
}

/// `BaseCellRenderer` + `InternalCellRenderer` (`cell-types.ts:58-121`).
///
/// Upstream splits these into `InternalCellRenderer` (core cells) and
/// `CustomRenderer` (user cells); the extra members ([isMatch] and the
/// `onPaste` overload) are represented by [SemiCustomRenderer].
abstract class SemiCellRenderer {
  const SemiCellRenderer();

  /// `kind` (`cell-types.ts:60`).
  SemiCellKind get kind;

  /// `draw` (`cell-types.ts:61`).
  void draw(SemiDrawCellArgs args);

  /// `drawPrep` (`cell-types.ts:62`) — the Flutter painter resolves theme and
  /// text styles once per frame, so the prep hooks are folded into `draw`.
  bool get needsHover => false;

  /// `needsHover?: boolean | ((cell: T) => boolean)` (`:63`).
  bool needsHoverFor(SemiGridCell cell) => needsHover;

  /// `needsHoverPosition` (`:64`).
  bool get needsHoverPosition => false;

  /// `measure` (`:65`).
  double? measure(SemiGridCell cell, SemiDataGridTheme theme, SemiTextMetrics metrics) =>
      null;

  /// `provideEditor` (`:68`).
  SemiEditorProvider? provideEditor(
    SemiGridCell cell,
    SemiItem location,
  ) => null;

  /// `onClick` (`:71-81`). Returning a cell commits an edit without opening an
  /// overlay (used by booleans).
  SemiGridCell? onClick(SemiCellEventArgs args) => null;

  /// `onSelect` (`:83-92`).
  void onSelect(SemiCellEventArgs args) {}

  /// `onDelete` (`:93`).
  SemiGridCell? onDelete(SemiGridCell cell) => null;

  /// `getAccessibilityString` (`:99`).
  String getAccessibilityString(SemiGridCell cell) => '';

  /// `onPaste` (`:100-109`). Returns the complete cell, or null to delegate to
  /// `coercePasteValue`.
  SemiGridCell? onPaste(
    String toPaste,
    SemiGridCell cell,
    SemiPasteDetails details,
  ) => null;
}

/// `CustomRenderer` (`cell-types.ts:113-116`).
abstract class SemiCustomRenderer<T> extends SemiCellRenderer {
  const SemiCustomRenderer();

  /// `isMatch` (`:114`).
  bool isMatch(SemiCustomCell cell);

  /// `onPaste` returns only `T["data"]` upstream.
  T? onPasteData(String toPaste, T data) => null;

  @override
  SemiGridCell? onPaste(
    String toPaste,
    SemiGridCell cell,
    SemiPasteDetails details,
  ) {
    if (cell is! SemiCustomCell<T>) return null;
    final newData = onPasteData(toPaste, cell.data);
    if (newData == null) return null;
    return SemiCustomCell<T>(
      data: newData,
      copyData: cell.copyData,
      readonly: cell.readonly,
      allowOverlay: cell.allowOverlay,
      span: cell.span,
      contentAlign: cell.contentAlign,
      themeOverride: cell.themeOverride,
    );
  }
}

/// `onClick` / `onSelect` argument bag (`cell-types.ts:71-92`).
class SemiCellEventArgs {
  const SemiCellEventArgs({
    required this.cell,
    required this.posX,
    required this.posY,
    required this.bounds,
    required this.location,
    required this.theme,
    this.theme2,
    this.preventDefault,
    this.isTouch = false,
    this.isLongTouch = false,
    this.shiftKey = false,
    this.ctrlKey = false,
    this.metaKey = false,
    this.altKey = false,
  });

  final SemiGridCell cell;
  final double posX;
  final double posY;
  final SemiRectangle bounds;
  final SemiItem location;
  final SemiDataGridTheme theme;

  /// Kept so nested args (`BaseGridMouseEventArgs`) can be attached without a
  /// second type; the grid fills this with the resolved theme.
  final SemiDataGridTheme? theme2;

  /// `preventDefault` (`:78`).
  final void Function()? preventDefault;

  final bool isTouch;
  final bool isLongTouch;
  final bool shiftKey;
  final bool ctrlKey;
  final bool metaKey;
  final bool altKey;
}

/// `ProvideEditorComponent` (`data-grid-types.ts:385-400`).
///
/// A widget builder is enough here: React's controlled `onChange`/`onFinish`
/// pair maps to [SemiEditorController] callbacks.
typedef SemiEditorBuilder =
    Widget Function(SemiEditorProps props);

/// `ProvideEditorCallbackResult` (`data-grid-types.ts:401-410`): either the
/// plain component (with the `disablePadding`/`disableStyling` flags React
/// hangs off the function object) or an [SemiObjectEditor].
sealed class SemiEditorProvider {
  const SemiEditorProvider();

  bool get disablePadding;
  bool get disableStyling;
}

/// The plain-component form of [SemiEditorProvider].
class SemiComponentEditor extends SemiEditorProvider {
  const SemiComponentEditor(
    this.builder, {
    this.disablePadding = false,
    this.disableStyling = false,
  });

  final SemiEditorBuilder builder;

  @override
  final bool disablePadding;

  @override
  final bool disableStyling;
}

/// `ObjectEditorCallbackResult` (`data-grid-types.ts`): `{ editor,
/// deletedValue?, styleOverride? }`.
class SemiObjectEditor extends SemiEditorProvider {
  const SemiObjectEditor(
    this.builder, {
    this.deletedValue,
    this.styleOverride,
    this.disablePadding = false,
    this.disableStyling = false,
  });

  final SemiEditorBuilder builder;

  /// `deletedValue` (`data-editor.tsx:3166`): used by `deleteRange` when the
  /// renderer has no `onDelete`.
  final SemiGridCell Function(SemiGridCell cell)? deletedValue;
  final SemiThemeOverride? styleOverride;

  @override
  final bool disablePadding;

  @override
  final bool disableStyling;
}

/// `isObjectEditorCallbackResult` (`data-grid-types.ts:420-424`).
bool semiIsObjectEditor(SemiEditorProvider provider) =>
    provider is SemiObjectEditor;

/// `ProvideEditorComponent` props.
class SemiEditorProps {
  const SemiEditorProps({
    required this.value,
    required this.target,
    required this.theme,
    required this.isHighlighted,
    required this.forceEditMode,
    required this.initialValue,
    required this.onChange,
    required this.onFinishedEditing,
    this.isValid = true,
    this.activation,
  });

  final SemiGridCell value;
  final SemiRectangle target;
  final SemiDataGridTheme theme;
  final bool isHighlighted;
  final bool forceEditMode;
  final String? initialValue;
  final void Function(SemiGridCell newValue) onChange;

  /// `movement` mirrors `[-1|0|1, -1|0|1]` so Tab/Enter can move the selection.
  final void Function(SemiGridCell? newValue, SemiEditorMovement? movement)
  onFinishedEditing;
  final bool isValid;
  final SemiCellActivationBehavior? activation;
}

/// `movement?: readonly [-1 | 0 | 1, -1 | 0 | 1]`
/// (`data-grid-types.ts:387`).
@immutable
class SemiEditorMovement {
  const SemiEditorMovement(this.col, this.row);

  /// `[0, 0]` — commit without moving.
  static const SemiEditorMovement none = SemiEditorMovement(0, 0);

  static const SemiEditorMovement left = SemiEditorMovement(-1, 0);
  static const SemiEditorMovement right = SemiEditorMovement(1, 0);
  static const SemiEditorMovement up = SemiEditorMovement(0, -1);
  static const SemiEditorMovement down = SemiEditorMovement(0, 1);

  final int col;
  final int row;
}

/// `GetCellRendererCallback` (`cell-types.ts:124`).
typedef SemiGetCellRenderer = SemiCellRenderer? Function(SemiGridCell cell);

/// Lookup used by rendering and hit testing (`data-editor.tsx:1098-1115`).
class SemiRendererLookup {
  SemiRendererLookup({
    required this.renderers,
    this.customRenderers = const [],
  });

  final Map<SemiCellKind, SemiCellRenderer> renderers;
  final List<SemiCustomRenderer<dynamic>> customRenderers;

  SemiCellRenderer? forCell(SemiGridCell cell) {
    if (cell.kind == SemiCellKind.custom) {
      for (final r in customRenderers) {
        if (cell is SemiCustomCell && r.isMatch(cell)) return r;
      }
      return null;
    }
    return renderers[cell.kind];
  }
}
