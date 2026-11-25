// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/hover/browser/hoverTypes.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * Interfaces are erased to file-local opaque carriers; DOM/platform types
//    (Dimension, ScrollEvent, CancellationToken, ICodeEditor, etc.) are carried
//    as `Object` where they only appear in signatures.
//  * `HoverStartSource` comes from hoverOperation.ts (not yet ported) and is
//    carried as an opaque `Object` in signatures.
//  * The anonymous singleton `HoverParticipantRegistry` is a single instance.
// ---------------------------------------------------------------------------

import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;

/// 1:1: `IHoverPart`.
abstract class IHoverPart {
  Object get owner;
  Range get range;
  bool? get forceShowAtRange;
  bool? get isBeforeContent;
  bool isValidForHoverAnchor(HoverAnchor anchor);
}

/// 1:1: `const enum HoverAnchorType`.
class HoverAnchorType {
  const HoverAnchorType._();
  static const int Range = 1;
  static const int ForeignElement = 2;
}

/// 1:1: `HoverAnchor` (union of the two anchor classes).
abstract class HoverAnchor {
  int get type;
  int get priority;
  Range get range;
  bool equals(HoverAnchor other);
  bool canAdoptVisibleHover(HoverAnchor lastAnchor, Position showAtPosition);
}

/// 1:1: `HoverRangeAnchor`.
class HoverRangeAnchor implements HoverAnchor {
  @override
  final int type = HoverAnchorType.Range;
  @override
  final int priority;
  @override
  final Range range;
  final num? initialMousePosX;
  final num? initialMousePosY;

  HoverRangeAnchor(
    this.priority,
    this.range,
    this.initialMousePosX,
    this.initialMousePosY,
  );

  @override
  bool equals(HoverAnchor other) =>
      other.type == HoverAnchorType.Range && range.equalsRange(other.range);

  @override
  bool canAdoptVisibleHover(HoverAnchor lastAnchor, Position showAtPosition) =>
      lastAnchor.type == HoverAnchorType.Range &&
      showAtPosition.lineNumber == range.startLineNumber;
}

/// 1:1: `HoverForeignElementAnchor`.
class HoverForeignElementAnchor implements HoverAnchor {
  @override
  final int type = HoverAnchorType.ForeignElement;
  @override
  final int priority;
  final Object owner;
  @override
  final Range range;
  final num? initialMousePosX;
  final num? initialMousePosY;
  final bool? supportsMarkerHover;

  HoverForeignElementAnchor(
    this.priority,
    this.owner,
    this.range,
    this.initialMousePosX,
    this.initialMousePosY,
    this.supportsMarkerHover,
  );

  @override
  bool equals(HoverAnchor other) =>
      other.type == HoverAnchorType.ForeignElement &&
      identical(owner, (other as HoverForeignElementAnchor).owner);

  @override
  bool canAdoptVisibleHover(HoverAnchor lastAnchor, Position showAtPosition) =>
      lastAnchor.type == HoverAnchorType.ForeignElement &&
      identical(owner, (lastAnchor as HoverForeignElementAnchor).owner);
}

/// 1:1: `IEditorHoverStatusBar` (opaque carrier).
abstract class IEditorHoverStatusBar {}

/// 1:1: `IEditorHoverAction` (opaque carrier).
abstract class IEditorHoverAction {}

/// 1:1: `IEditorHoverColorPickerWidget` (opaque carrier).
abstract class IEditorHoverColorPickerWidget {}

/// 1:1: `IEditorHoverContext` (opaque carrier).
abstract class IEditorHoverContext {
  void onContentsChanged();
  void setMinimumDimensions(Object dimensions);
  void hide();
  void focus();
}

/// 1:1: `IEditorHoverRenderContext` (opaque carrier).
abstract class IEditorHoverRenderContext implements IEditorHoverContext {
  Object get fragment;
  IEditorHoverStatusBar get statusBar;
}

/// 1:1: `IRenderedHoverPart<T>` (opaque carrier).
abstract class IRenderedHoverPart<T extends IHoverPart> {
  T get hoverPart;
  Object get hoverElement;
  void dispose();
}

/// 1:1: `IRenderedHoverParts<T>` (opaque carrier).
abstract class IRenderedHoverParts<T extends IHoverPart> {
  List<IRenderedHoverPart<T>> get renderedHoverParts;
  void dispose();
}

/// 1:1: `RenderedHoverParts<T>` default implementation.
class RenderedHoverParts<T extends IHoverPart>
    implements IRenderedHoverParts<T> {
  @override
  final List<IRenderedHoverPart<T>> renderedHoverParts;
  final Object? disposables;

  RenderedHoverParts(this.renderedHoverParts, [this.disposables]);

  @override
  void dispose() {
    for (final IRenderedHoverPart<T> part in renderedHoverParts) {
      part.dispose();
    }
    (disposables as dynamic)?.dispose();
  }
}

/// 1:1: `IEditorHoverParticipant<T>` (opaque carrier).
abstract class IEditorHoverParticipant<T extends IHoverPart> {
  int get hoverOrdinal;
  bool? get hideCopyButton;
  T? computeSync(HoverAnchor anchor, List<Object> lineDecorations, Object source);
  Object createLoadingMessage(HoverAnchor anchor);
  IRenderedHoverParts<T> renderHoverParts(
    IEditorHoverRenderContext context,
    List<T> hoverParts,
  );
  String getAccessibleContent(T hoverPart);
}

/// 1:1: `IEditorHoverParticipantCtor` (opaque carrier).
typedef IEditorHoverParticipantCtor = Object Function(Object editor);

/// 1:1: `HoverParticipantRegistry` singleton.
class HoverParticipantRegistry {
  HoverParticipantRegistry._();

  static final HoverParticipantRegistry _instance =
      HoverParticipantRegistry._();

  factory HoverParticipantRegistry() => _instance;

  final List<Object> _participants = <Object>[];

  /// 1:1: `register`.
  void register(Object ctor) => _participants.add(ctor);

  /// 1:1: `getAll`.
  List<Object> getAll() => _participants;
}

/// 1:1: `IHoverWidget` (opaque carrier).
abstract class IHoverWidget {
  bool showsOrWillShow(Object mouseEvent);
  void hide();
}
