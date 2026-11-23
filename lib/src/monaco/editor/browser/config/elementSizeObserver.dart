// 1:1 port of vscode/src/vs/editor/browser/config/elementSizeObserver.ts
import '../../../base/browser/dom.dart' as DOM
    show
        DomElement,
        DomResizeObserver,
        DomResizeObserverEntry,
        getWindow,
        resizeObserverCtor,
        scheduleAtNextAnimationFrame;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../common/core/2d/dimension.dart' show Dimension, IDimension;

/// 1:1: `class ElementSizeObserver extends Disposable`
class ElementSizeObserver extends Disposable {
  late final Emitter<void> _onDidChange;
  late final Event<void> onDidChange;

  final DOM.DomElement? _referenceDomElement;
  num _width;
  num _height;
  DOM.DomResizeObserver? _resizeObserver;

  ElementSizeObserver(DOM.DomElement? referenceDomElement, IDimension? dimension)
      : _referenceDomElement = referenceDomElement,
        _width = -1,
        _height = -1,
        _resizeObserver = null {
    _onDidChange = Emitter<void>();
    register(_onDidChange);
    onDidChange = _onDidChange.event;
    measureReferenceDomElement(false, dimension);
  }

  @override
  void dispose() {
    stopObserving();
    super.dispose();
  }

  num getWidth() => _width;
  num getHeight() => _height;

  /// TS private field exposed read-only for the truth test.
  DOM.DomResizeObserver? get resizeObserver => _resizeObserver;

  void startObserving() {
    if (_resizeObserver == null && _referenceDomElement != null) {
      // React to resize observer only once per animation frame. The first
      // delivery reacts immediately, later ones are postponed to a frame.
      IDimension? observedDimension;
      void observeNow() {
        if (observedDimension != null) {
          observe(Dimension(
              observedDimension!.width, observedDimension!.height));
        } else {
          observe();
        }
      }

      bool shouldObserve = false;
      bool alreadyObservedThisAnimationFrame = false;

      void update() {
        if (shouldObserve && !alreadyObservedThisAnimationFrame) {
          try {
            shouldObserve = false;
            alreadyObservedThisAnimationFrame = true;
            observeNow();
          } finally {
            DOM.scheduleAtNextAnimationFrame(
                DOM.getWindow(_referenceDomElement!), () {
              alreadyObservedThisAnimationFrame = false;
              update();
            });
          }
        }
      }

      _resizeObserver = DOM.resizeObserverCtor(
        (List<DOM.DomResizeObserverEntry> entries, DOM.DomResizeObserver self) {
          if (entries.isNotEmpty && entries.first.contentRect != null) {
            observedDimension = Dimension(
              entries.first.contentRect!.width,
              entries.first.contentRect!.height,
            );
          } else {
            observedDimension = null;
          }
          shouldObserve = true;
          update();
        },
      );
      _resizeObserver!.observe(_referenceDomElement!);
    }
  }

  void stopObserving() {
    if (_resizeObserver != null) {
      _resizeObserver!.disconnect();
      _resizeObserver = null;
    }
  }

  void observe([IDimension? dimension]) {
    measureReferenceDomElement(true, dimension);
  }

  void measureReferenceDomElement(bool emitEvent, [IDimension? dimension]) {
    num observedWidth = 0;
    num observedHeight = 0;
    if (dimension != null) {
      observedWidth = dimension.width;
      observedHeight = dimension.height;
    } else if (_referenceDomElement != null) {
      observedWidth = _referenceDomElement!.clientWidth;
      observedHeight = _referenceDomElement!.clientHeight;
    }
    if (observedWidth < 5) observedWidth = 5;
    if (observedHeight < 5) observedHeight = 5;
    if (_width != observedWidth || _height != observedHeight) {
      _width = observedWidth;
      _height = observedHeight;
      if (emitEvent) {
        _onDidChange.fire(null);
      }
    }
  }
}
