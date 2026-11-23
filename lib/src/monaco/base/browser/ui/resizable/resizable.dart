// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/resizable/resizable.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers:
//   - `Dimension` -> `dom.Dimension`.
//   - `Sash`/`SashState`/`Orientation`/`OrthogonalEdge` -> `sash.dart`.
//   - `Event<T>` / `Emitter<T>` -> `events.Event<T>` / `events.Emitter<T>`.
//   - `Event.any(...)` -> `events.eventAny<T>([...])`.
//   - `DisposableStore` -> `lifecycle.DisposableStore`.
//   - `x + 'px'` number string -> local `_jsNum` (integer doubles drop `.0`).
// ---------------------------------------------------------------------------

import '../../dom.dart' as dom;
import '../sash/sash.dart' as sash;
import '../../../common/event.dart' as events;
import '../../../common/lifecycle.dart' as lifecycle;

/// 1:1: `export interface IResizeEvent`.
class IResizeEvent {
  IResizeEvent({
    required this.dimension,
    required this.done,
    this.reset,
    this.north,
    this.east,
    this.south,
    this.west,
  });

  final dom.Dimension dimension;
  final bool done;
  final String? reset;
  final bool? north;
  final bool? east;
  final bool? south;
  final bool? west;

  Map<String, Object?> toMap() => <String, Object?>{
        'dimension': <String, Object?>{
          'width': dimension.width,
          'height': dimension.height,
        },
        'done': done,
        if (reset != null) 'reset': reset,
        if (north != null) 'north': north,
        if (east != null) 'east': east,
        if (south != null) 'south': south,
        if (west != null) 'west': west,
      };
}

String _jsNum(num value) {
  if (value is double && value == value.toInt()) return value.toInt().toString();
  return value.toString();
}

/// Test injection hook mirroring the TS `new Sash(...)` call sites.
/// Defaults to the real `sash.Sash`; tests swap in a recording fake.
sash.Sash Function(
  dom.DomElement container,
  Object layoutProvider,
  sash.SashOptions options,
) sashFactory = (dom.DomElement container, Object layoutProvider,
        sash.SashOptions options) =>
    sash.Sash(container, layoutProvider, options);

/// 1:1: east sash layout provider: `getVerticalSashLeft: () => this._size.width`.
class _EastLayoutProvider extends sash.IVerticalSashLayoutProvider {
  _EastLayoutProvider(this._owner);
  final ResizableHTMLElement _owner;

  @override
  num getVerticalSashLeft(sash.Sash sash) => _owner._size.width;
}

/// 1:1: west sash layout provider: `getVerticalSashLeft: () => 0`.
class _WestLayoutProvider extends sash.IVerticalSashLayoutProvider {
  @override
  num getVerticalSashLeft(sash.Sash sash) => 0;
}

/// 1:1: north sash layout provider: `getHorizontalSashTop: () => 0`.
class _NorthLayoutProvider extends sash.IHorizontalSashLayoutProvider {
  @override
  num getHorizontalSashTop(sash.Sash sash) => 0;
}

/// 1:1: south sash layout provider: `getHorizontalSashTop: () => this._size.height`.
class _SouthLayoutProvider extends sash.IHorizontalSashLayoutProvider {
  _SouthLayoutProvider(this._owner);
  final ResizableHTMLElement _owner;

  @override
  num getHorizontalSashTop(sash.Sash sash) => _owner._size.height;
}

/// 1:1: `export class ResizableHTMLElement`.
class ResizableHTMLElement {
  final events.Emitter<void> _onDidWillResize = events.Emitter<void>();
  events.Event<void> get onDidWillResize => _onDidWillResize.event;

  final events.Emitter<IResizeEvent> _onDidResize = events.Emitter<IResizeEvent>();
  events.Event<IResizeEvent> get onDidResize => _onDidResize.event;

  late final sash.Sash _northSash;
  late final sash.Sash _eastSash;
  late final sash.Sash _southSash;
  late final sash.Sash _westSash;
  final lifecycle.DisposableStore _sashListener = lifecycle.DisposableStore();

  dom.Dimension _size = dom.Dimension(0, 0);
  dom.Dimension _minSize = dom.Dimension(0, 0);
  dom.Dimension _maxSize = dom.Dimension(
    9007199254740991, // Number.MAX_SAFE_INTEGER
    9007199254740991,
  );
  dom.Dimension? _preferredSize;

  /// 1:1: `readonly domNode: HTMLElement` (created in constructor).
  late final dom.DomElement domNode;

  ResizableHTMLElement() {
    domNode = dom.document.createElement('div');

    _eastSash = sashFactory(
        domNode,
        _EastLayoutProvider(this),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    _westSash = sashFactory(
        domNode,
        _WestLayoutProvider(),
        sash.SashOptions(orientation: sash.Orientation.VERTICAL));
    _northSash = sashFactory(
        domNode,
        _NorthLayoutProvider(),
        sash.SashOptions(
            orientation: sash.Orientation.HORIZONTAL,
            orthogonalEdge: sash.OrthogonalEdge.North));
    _southSash = sashFactory(
        domNode,
        _SouthLayoutProvider(this),
        sash.SashOptions(
            orientation: sash.Orientation.HORIZONTAL,
            orthogonalEdge: sash.OrthogonalEdge.South));

    _northSash.orthogonalStartSash = _westSash;
    _northSash.orthogonalEndSash = _eastSash;
    _southSash.orthogonalStartSash = _westSash;
    _southSash.orthogonalEndSash = _eastSash;

    dom.Dimension? currentSize;
    num deltaY = 0;
    num deltaX = 0;

    _sashListener.add(events.eventAny<sash.SashEvent>(<events.Event<sash.SashEvent>>[
      _northSash.onDidStart,
      _eastSash.onDidStart,
      _southSash.onDidStart,
      _westSash.onDidStart,
    ])((Object? _) {
      if (currentSize == null) {
        _onDidWillResize.fire(null);
        currentSize = _size;
        deltaY = 0;
        deltaX = 0;
      }
    }));
    _sashListener.add(events.eventAny<void>(<events.Event<void>>[
      _northSash.onDidEnd,
      _eastSash.onDidEnd,
      _southSash.onDidEnd,
      _westSash.onDidEnd,
    ])((Object? _) {
      if (currentSize != null) {
        currentSize = null;
        deltaY = 0;
        deltaX = 0;
        _onDidResize.fire(IResizeEvent(dimension: _size, done: true));
      }
    }));

    _sashListener.add(_eastSash.onDidChange((Object? e) {
      final sash.SashEvent se = e as sash.SashEvent;
      if (currentSize != null) {
        deltaX = se.currentX - se.startX;
        layout(currentSize!.height + deltaY, currentSize!.width + deltaX);
        _onDidResize.fire(IResizeEvent(
            dimension: _size, done: false, east: true));
      }
    }));
    _sashListener.add(_westSash.onDidChange((Object? e) {
      final sash.SashEvent se = e as sash.SashEvent;
      if (currentSize != null) {
        deltaX = -(se.currentX - se.startX);
        layout(currentSize!.height + deltaY, currentSize!.width + deltaX);
        _onDidResize.fire(IResizeEvent(
            dimension: _size, done: false, west: true));
      }
    }));
    _sashListener.add(_northSash.onDidChange((Object? e) {
      final sash.SashEvent se = e as sash.SashEvent;
      if (currentSize != null) {
        deltaY = -(se.currentY - se.startY);
        layout(currentSize!.height + deltaY, currentSize!.width + deltaX);
        _onDidResize.fire(IResizeEvent(
            dimension: _size, done: false, north: true));
      }
    }));
    _sashListener.add(_southSash.onDidChange((Object? e) {
      final sash.SashEvent se = e as sash.SashEvent;
      if (currentSize != null) {
        deltaY = se.currentY - se.startY;
        layout(currentSize!.height + deltaY, currentSize!.width + deltaX);
        _onDidResize.fire(IResizeEvent(
            dimension: _size, done: false, south: true));
      }
    }));

    _sashListener.add(events.eventAny<void>(<events.Event<void>>[
      _eastSash.onDidReset,
      _westSash.onDidReset,
    ])((Object? _) {
      final dom.Dimension? preferred = _preferredSize;
      if (preferred != null) {
        layout(_size.height, preferred.width);
        _onDidResize.fire(IResizeEvent(
            dimension: _size, done: true, reset: 'width'));
      }
    }));
    _sashListener.add(events.eventAny<void>(<events.Event<void>>[
      _northSash.onDidReset,
      _southSash.onDidReset,
    ])((Object? _) {
      final dom.Dimension? preferred = _preferredSize;
      if (preferred != null) {
        layout(preferred.height, _size.width);
        _onDidResize.fire(IResizeEvent(
            dimension: _size, done: true, reset: 'height'));
      }
    }));
  }

  /// 1:1: `dispose()`.
  void dispose() {
    _northSash.dispose();
    _southSash.dispose();
    _eastSash.dispose();
    _westSash.dispose();
    _sashListener.dispose();
    _onDidResize.dispose();
    _onDidWillResize.dispose();
    domNode.remove();
  }

  /// 1:1: `enableSashes(north, east, south, west)`.
  void enableSashes(bool north, bool east, bool south, bool west) {
    _northSash.state = north ? sash.SashState.Enabled : sash.SashState.Disabled;
    _eastSash.state = east ? sash.SashState.Enabled : sash.SashState.Disabled;
    _southSash.state = south ? sash.SashState.Enabled : sash.SashState.Disabled;
    _westSash.state = west ? sash.SashState.Enabled : sash.SashState.Disabled;
  }

  /// 1:1: `layout(height = this.size.height, width = this.size.width)`.
  void layout([num? height, num? width]) {
    num h = height ?? _size.height;
    num w = width ?? _size.width;

    final num minHeight = _minSize.height;
    final num minWidth = _minSize.width;
    final num maxHeight = _maxSize.height;
    final num maxWidth = _maxSize.width;

    h = minMaxClamp(h, minHeight, maxHeight);
    w = minMaxClamp(w, minWidth, maxWidth);

    final dom.Dimension newSize = dom.Dimension(w, h);
    if (!dom.Dimension.equals(newSize, _size)) {
      domNode.style['height'] = '${_jsNum(h)}px';
      domNode.style['width'] = '${_jsNum(w)}px';
      _size = newSize;
      _northSash.layout();
      _eastSash.layout();
      _southSash.layout();
      _westSash.layout();
    }
  }

  /// 1:1: `clearSashHoverState()`.
  void clearSashHoverState() {
    _eastSash.clearSashHoverState();
    _westSash.clearSashHoverState();
    _northSash.clearSashHoverState();
    _southSash.clearSashHoverState();
  }

  /// 1:1: `get size()`.
  dom.Dimension get size => _size;

  /// 1:1: `set maxSize(value)` / `get maxSize()`.
  set maxSize(dom.Dimension value) => _maxSize = value;
  dom.Dimension get maxSize => _maxSize;

  /// 1:1: `set minSize(value)` / `get minSize()`.
  set minSize(dom.Dimension value) => _minSize = value;
  dom.Dimension get minSize => _minSize;

  /// 1:1: `set preferredSize(value)` / `get preferredSize()`.
  set preferredSize(dom.Dimension? value) => _preferredSize = value;
  dom.Dimension? get preferredSize => _preferredSize;
}

/// JS `Math.max(min, Math.min(max, value))`.
num minMaxClamp(num value, num min, num max) =>
    value < min ? min : (value > max ? max : value);
