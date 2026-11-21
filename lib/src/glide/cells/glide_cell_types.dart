// Port of `packages/core/src/cells/cell-types.ts`.
//
// `BaseDrawArgs` carries the canvas context upstream; in Flutter the `Canvas`
// is passed explicitly to [GlideCellRenderer.draw] because a `canvas.save()`
// pair around every cell would be much more expensive than in the DOM version.
// React's `requestAnimationFrame` state hook has no place here: renderers can
// call `args.requestAnimationFrame()` to ask the grid for another frame.
import 'package:flutter/widgets.dart';

import '../common/glide_theme.dart';
import '../internal/data_grid/glide_geometry.dart';
import '../internal/data_grid/glide_types.dart';

export '../internal/data_grid/glide_types.dart';
export '../internal/data_grid/glide_geometry.dart';
export '../common/glide_theme.dart';

/// `BaseDrawArgs` (`cell-types.ts:16-31`).
class GlideDrawCellArgs {
  GlideDrawCellArgs({
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
  });

  final Canvas canvas;
  final GlideTheme theme;
  final int col;
  final int row;
  final GlideRectangle rect;
  final GlideGridCell cell;
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
  final GlideTextMetrics? metrics;

  /// `requestAnimationFrame(state?)` (`cell-types.ts:39`). Returning a value
  /// stores it as the renderer's per-cell draw state for the next frame.
  final void Function([Object? state])? requestAnimationFrame;

  GlideDrawCellArgs copyWith({
    GlideRectangle? rect,
    GlideGridCell? cell,
    bool? highlighted,
    double? hoverAmount,
  }) => GlideDrawCellArgs(
    canvas: canvas,
    theme: theme,
    col: col,
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
  );
}

/// `details` passed to `onPaste` (`cell-types.ts:102-108`).
@immutable
class GlidePasteDetails {
  const GlidePasteDetails({
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
/// `onPaste` overload) are represented by [GlideCustomRenderer].
abstract class GlideCellRenderer {
  const GlideCellRenderer();

  /// `kind` (`cell-types.ts:60`).
  GlideCellKind get kind;

  /// `draw` (`cell-types.ts:61`).
  void draw(GlideDrawCellArgs args);

  /// `drawPrep` (`cell-types.ts:62`) — the Flutter painter resolves theme and
  /// text styles once per frame, so the prep hooks are folded into `draw`.
  bool get needsHover => false;

  /// `needsHover?: boolean | ((cell: T) => boolean)` (`:63`).
  bool needsHoverFor(GlideGridCell cell) => needsHover;

  /// `needsHoverPosition` (`:64`).
  bool get needsHoverPosition => false;

  /// `measure` (`:65`).
  double? measure(GlideGridCell cell, GlideTheme theme, GlideTextMetrics metrics) =>
      null;

  /// `provideEditor` (`:68`).
  GlideEditorProvider? provideEditor(
    GlideGridCell cell,
    GlideItem location,
  ) => null;

  /// `onClick` (`:71-81`). Returning a cell commits an edit without opening an
  /// overlay (used by booleans).
  GlideGridCell? onClick(GlideCellEventArgs args) => null;

  /// `onSelect` (`:83-92`).
  void onSelect(GlideCellEventArgs args) {}

  /// `onDelete` (`:93`).
  GlideGridCell? onDelete(GlideGridCell cell) => null;

  /// `getAccessibilityString` (`:99`).
  String getAccessibilityString(GlideGridCell cell) => '';

  /// `onPaste` (`:100-109`). Returns the complete cell, or null to delegate to
  /// `coercePasteValue`.
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) => null;
}

/// `CustomRenderer` (`cell-types.ts:113-116`).
abstract class GlideCustomRenderer<T> extends GlideCellRenderer {
  const GlideCustomRenderer();

  /// `isMatch` (`:114`).
  bool isMatch(GlideCustomCell cell);

  /// `onPaste` returns only `T["data"]` upstream.
  T? onPasteData(String toPaste, T data) => null;

  @override
  GlideGridCell? onPaste(
    String toPaste,
    GlideGridCell cell,
    GlidePasteDetails details,
  ) {
    if (cell is! GlideCustomCell<T>) return null;
    final newData = onPasteData(toPaste, cell.data);
    if (newData == null) return null;
    return GlideCustomCell<T>(
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
class GlideCellEventArgs {
  const GlideCellEventArgs({
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

  final GlideGridCell cell;
  final double posX;
  final double posY;
  final GlideRectangle bounds;
  final GlideItem location;
  final GlideTheme theme;

  /// Kept so nested args (`BaseGridMouseEventArgs`) can be attached without a
  /// second type; the grid fills this with the resolved theme.
  final GlideTheme? theme2;

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
/// pair maps to [GlideEditorController] callbacks.
typedef GlideEditorBuilder =
    Widget Function(GlideEditorProps props);

/// `ProvideEditorCallbackResult` (`data-grid-types.ts:401-410`): either the
/// plain component (with the `disablePadding`/`disableStyling` flags React
/// hangs off the function object) or an [GlideObjectEditor].
sealed class GlideEditorProvider {
  const GlideEditorProvider();

  bool get disablePadding;
  bool get disableStyling;
}

/// The plain-component form of [GlideEditorProvider].
class GlideComponentEditor extends GlideEditorProvider {
  const GlideComponentEditor(
    this.builder, {
    this.disablePadding = false,
    this.disableStyling = false,
  });

  final GlideEditorBuilder builder;

  @override
  final bool disablePadding;

  @override
  final bool disableStyling;
}

/// `ObjectEditorCallbackResult` (`data-grid-types.ts`): `{ editor,
/// deletedValue?, styleOverride? }`.
class GlideObjectEditor extends GlideEditorProvider {
  const GlideObjectEditor(
    this.builder, {
    this.deletedValue,
    this.styleOverride,
    this.disablePadding = false,
    this.disableStyling = false,
  });

  final GlideEditorBuilder builder;

  /// `deletedValue` (`data-editor.tsx:3166`): used by `deleteRange` when the
  /// renderer has no `onDelete`.
  final GlideGridCell Function(GlideGridCell cell)? deletedValue;
  final GlideThemeOverride? styleOverride;

  @override
  final bool disablePadding;

  @override
  final bool disableStyling;
}

/// `isObjectEditorCallbackResult` (`data-grid-types.ts:420-424`).
bool glideIsObjectEditor(GlideEditorProvider provider) =>
    provider is GlideObjectEditor;

/// `ProvideEditorComponent` props.
class GlideEditorProps {
  const GlideEditorProps({
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

  final GlideGridCell value;
  final GlideRectangle target;
  final GlideTheme theme;
  final bool isHighlighted;
  final bool forceEditMode;
  final String? initialValue;
  final void Function(GlideGridCell newValue) onChange;

  /// `movement` mirrors `[-1|0|1, -1|0|1]` so Tab/Enter can move the selection.
  final void Function(GlideGridCell? newValue, GlideEditorMovement? movement)
  onFinishedEditing;
  final bool isValid;
  final GlideCellActivationBehavior? activation;
}

/// `movement?: readonly [-1 | 0 | 1, -1 | 0 | 1]`
/// (`data-grid-types.ts:387`).
@immutable
class GlideEditorMovement {
  const GlideEditorMovement(this.col, this.row);

  /// `[0, 0]` — commit without moving.
  static const GlideEditorMovement none = GlideEditorMovement(0, 0);

  static const GlideEditorMovement left = GlideEditorMovement(-1, 0);
  static const GlideEditorMovement right = GlideEditorMovement(1, 0);
  static const GlideEditorMovement up = GlideEditorMovement(0, -1);
  static const GlideEditorMovement down = GlideEditorMovement(0, 1);

  final int col;
  final int row;
}

/// `GetCellRendererCallback` (`cell-types.ts:124`).
typedef GlideGetCellRenderer = GlideCellRenderer? Function(GlideGridCell cell);

/// Lookup used by rendering and hit testing (`data-editor.tsx:1098-1115`).
class GlideRendererLookup {
  GlideRendererLookup({
    required this.renderers,
    this.customRenderers = const [],
  });

  final Map<GlideCellKind, GlideCellRenderer> renderers;
  final List<GlideCustomRenderer<dynamic>> customRenderers;

  GlideCellRenderer? forCell(GlideGridCell cell) {
    if (cell.kind == GlideCellKind.custom) {
      for (final r in customRenderers) {
        if (cell is GlideCustomCell && r.isMatch(cell)) return r;
      }
      return null;
    }
    return renderers[cell.kind];
  }
}
