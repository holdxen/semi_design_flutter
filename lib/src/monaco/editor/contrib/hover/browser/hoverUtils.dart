// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/hover/browser/hoverUtils.ts
// Translated 1:1. `dom.getDomNodePagePosition` becomes an injectable rect
// provider (Dart has no browser DOM); mouse events are narrow carriers.
// ---------------------------------------------------------------------------

/// 1:1: `const enum PADDING`.
class PADDING {
  const PADDING._();
  static const int VALUE = 3;
}

/// 1:1: page-position rect carrier.
class HoverElementRect {
  final num left;
  final num top;
  final num width;
  final num height;

  HoverElementRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// 1:1 injectable `dom.getDomNodePagePosition`.
HoverElementRect Function(Object element) hoverElementRectProvider = (Object element) =>
    throw UnimplementedError('hoverElementRectProvider is not installed');

/// 1:1: `isMousePositionWithinElement`.
bool isMousePositionWithinElement(Object element, num posx, num posy) {
  final HoverElementRect elementRect = hoverElementRectProvider(element);
  if (posx < elementRect.left + PADDING.VALUE ||
      posx > elementRect.left + elementRect.width - PADDING.VALUE ||
      posy < elementRect.top + PADDING.VALUE ||
      posy > elementRect.top + elementRect.height - PADDING.VALUE) {
    return false;
  }
  return true;
}

/// 1:1: modifier flag carrier.
class HoverMouseFlags {
  bool ctrlKey;
  bool metaKey;
  bool altKey;

  HoverMouseFlags({
    this.ctrlKey = false,
    this.metaKey = false,
    this.altKey = false,
  });
}

/// 1:1: `IEditorMouseEvent.event` member.
abstract class IEditorMouseEventForHover {
  HoverMouseFlags get event;
}

/// 1:1: `shouldShowHover`.
bool shouldShowHover(
  String hoverEnabled,
  String multiCursorModifier,
  IEditorMouseEventForHover mouseEvent,
) {
  if (hoverEnabled == 'on') {
    return true;
  }
  if (hoverEnabled == 'off') {
    return false;
  }
  return isTriggerModifierPressed(multiCursorModifier, mouseEvent.event);
}

/// 1:1: `isTriggerModifierPressed`.
bool isTriggerModifierPressed(String multiCursorModifier, HoverMouseFlags event) {
  if (multiCursorModifier == 'altKey') {
    return event.ctrlKey || event.metaKey;
  }
  // multiCursorModifier is ctrlKey or metaKey
  return event.altKey;
}
