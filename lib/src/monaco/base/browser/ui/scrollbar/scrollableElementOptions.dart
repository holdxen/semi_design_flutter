// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/scrollbar/scrollableElementOptions.ts
// Translated 1:1. The three TS interfaces are option bags; they are modelled as
// mutable carrier classes with nullable fields (optional members) and concrete
// fields for the resolved variant. `ScrollbarVisibility` is an int enum port.
// ---------------------------------------------------------------------------

/// 1:1: `interface ScrollableElementCreationOptions` (all members optional).
class ScrollableElementCreationOptions {
  bool? lazyRender;
  String? className;
  bool? useShadows;
  bool? handleMouseWheel;
  bool? mouseWheelSmoothScroll;
  bool? inertialScroll;
  bool? flipAxes;
  bool? scrollYToX;
  bool? consumeMouseWheelIfScrollbarIsNeeded;
  bool? alwaysConsumeMouseWheel;
  num? mouseWheelScrollSensitivity;
  num? fastScrollSensitivity;
  bool? scrollPredominantAxis;
  num? arrowSize;
  Object? listenOnDomNode; // HTMLElement carrier
  int? horizontal; // ScrollbarVisibility
  num? horizontalScrollbarSize;
  num? horizontalSliderSize;
  bool? horizontalHasArrows;
  int? vertical; // ScrollbarVisibility
  num? verticalScrollbarSize;
  num? verticalSliderSize;
  bool? verticalHasArrows;
  bool? scrollByPage;
}

/// 1:1: `interface ScrollableElementChangeOptions`.
class ScrollableElementChangeOptions {
  bool? handleMouseWheel;
  num? mouseWheelScrollSensitivity;
  num? fastScrollSensitivity;
  bool? scrollPredominantAxis;
  int? horizontal; // ScrollbarVisibility
  num? horizontalScrollbarSize;
  int? vertical; // ScrollbarVisibility
  num? verticalScrollbarSize;
  bool? scrollByPage;
}

/// 1:1: `interface ScrollableElementResolvedOptions` (all members required).
class ScrollableElementResolvedOptions {
  ScrollableElementResolvedOptions({
    required this.lazyRender,
    required this.className,
    required this.useShadows,
    required this.handleMouseWheel,
    required this.flipAxes,
    required this.scrollYToX,
    required this.consumeMouseWheelIfScrollbarIsNeeded,
    required this.alwaysConsumeMouseWheel,
    required this.mouseWheelScrollSensitivity,
    required this.fastScrollSensitivity,
    required this.scrollPredominantAxis,
    required this.mouseWheelSmoothScroll,
    required this.inertialScroll,
    required this.arrowSize,
    required this.listenOnDomNode,
    required this.horizontal,
    required this.horizontalScrollbarSize,
    required this.horizontalSliderSize,
    required this.horizontalHasArrows,
    required this.vertical,
    required this.verticalScrollbarSize,
    required this.verticalSliderSize,
    required this.verticalHasArrows,
    required this.scrollByPage,
  });

  bool lazyRender;
  String className;
  bool useShadows;
  bool handleMouseWheel;
  bool flipAxes;
  bool scrollYToX;
  bool consumeMouseWheelIfScrollbarIsNeeded;
  bool alwaysConsumeMouseWheel;
  num mouseWheelScrollSensitivity;
  num fastScrollSensitivity;
  bool scrollPredominantAxis;
  bool mouseWheelSmoothScroll;
  bool inertialScroll;
  num arrowSize;
  Object? listenOnDomNode; // HTMLElement | null
  int horizontal; // ScrollbarVisibility
  num horizontalScrollbarSize;
  num horizontalSliderSize;
  bool horizontalHasArrows;
  int vertical; // ScrollbarVisibility
  num verticalScrollbarSize;
  num verticalSliderSize;
  bool verticalHasArrows;
  bool scrollByPage;
}
