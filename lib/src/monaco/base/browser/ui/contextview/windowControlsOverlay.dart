// 1:1 port of vscode/src/vs/base/browser/ui/contextview/windowControlsOverlay.ts
// Pure geometry computation; TS `number` -> Dart `num`, interfaces -> carriers.

/// 1:1: `interface IWindowControlsOverlayTitlebarRect`
abstract class IWindowControlsOverlayTitlebarRect {
  num get x;
  num get y;
  num get width;
  num get height;
}

/// Value carrier for [IWindowControlsOverlayTitlebarRect].
class WindowControlsOverlayTitlebarRect
    implements IWindowControlsOverlayTitlebarRect {
  @override
  final num x;
  @override
  final num y;
  @override
  final num width;
  @override
  final num height;

  const WindowControlsOverlayTitlebarRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// 1:1: `interface IWindowControlsOverlayViewport`
abstract class IWindowControlsOverlayViewport {
  num get top;
  num get left;
  num get width;
  num get height;
}

/// Value carrier for [IWindowControlsOverlayViewport].
class WindowControlsOverlayViewport implements IWindowControlsOverlayViewport {
  @override
  final num top;
  @override
  final num left;
  @override
  final num width;
  @override
  final num height;

  const WindowControlsOverlayViewport({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}

/// 1:1: `interface IWindowControlsOverlaySize`
abstract class IWindowControlsOverlaySize {
  num get width;
  num get height;
}

/// Value carrier for [IWindowControlsOverlaySize].
class WindowControlsOverlaySize implements IWindowControlsOverlaySize {
  @override
  final num width;
  @override
  final num height;

  const WindowControlsOverlaySize({required this.width, required this.height});
}

/// 1:1: `interface IWindowControlsOverlayPosition`
abstract class IWindowControlsOverlayPosition {
  num get top;
  num get left;
}

/// Value carrier for [IWindowControlsOverlayPosition].
class WindowControlsOverlayPosition
    implements IWindowControlsOverlayPosition {
  @override
  final num top;
  @override
  final num left;

  const WindowControlsOverlayPosition({required this.top, required this.left});
}

/// 1:1: `interface IStrip`
class _Strip {
  final String side; // 'left' | 'right'
  final num start;
  final num end;

  const _Strip({required this.side, required this.start, required this.end});
}

/// Moves a view so that it does not cover the native window controls.
///
/// 1:1: `export function avoidWindowControlsOverlay(titlebarAreaRect, viewport, view, position)`
IWindowControlsOverlayPosition avoidWindowControlsOverlay(
  IWindowControlsOverlayTitlebarRect? titlebarAreaRect,
  IWindowControlsOverlayViewport viewport,
  IWindowControlsOverlaySize view,
  IWindowControlsOverlayPosition position,
) {
  if (titlebarAreaRect == null) {
    return position;
  }

  final List<num> values = <num>[
    titlebarAreaRect.x,
    titlebarAreaRect.y,
    titlebarAreaRect.width,
    titlebarAreaRect.height,
    viewport.top,
    viewport.left,
    viewport.width,
    viewport.height,
    view.width,
    view.height,
    position.top,
    position.left,
  ];
  if (values.any((num value) => !value.isFinite) ||
      titlebarAreaRect.height <= 0) {
    return position;
  }

  final num bandHeight = _mathMin(titlebarAreaRect.height, viewport.height);
  if (bandHeight <= 0) {
    return position;
  }

  final num areaStart =
      _clamp(titlebarAreaRect.x, 0, viewport.width);
  final num areaEnd = _clamp(
      titlebarAreaRect.x + titlebarAreaRect.width, areaStart, viewport.width);

  final List<_Strip> allStrips = <_Strip>[
    _Strip(
        side: 'left',
        start: viewport.left,
        end: viewport.left + areaStart),
    _Strip(
        side: 'right',
        start: viewport.left + areaEnd,
        end: viewport.left + viewport.width),
  ];
  final List<_Strip> strips = allStrips
      .where((_Strip strip) => strip.end - strip.start > 0)
      .toList();

  final num bandTop = viewport.top;
  final num bandBottom = viewport.top + bandHeight;

  bool overlapsStrip(num top, num left, _Strip strip) =>
      _overlaps(top, top + view.height, bandTop, bandBottom) &&
      _overlaps(left, left + view.width, strip.start, strip.end);

  final List<_Strip> overlapping = strips
      .where((_Strip strip) =>
          overlapsStrip(position.top, position.left, strip))
      .toList();
  if (overlapping.isEmpty) {
    return position;
  }

  // 1. Push the view below the titlebar band if it fits in the viewport
  if (bandBottom + view.height <= viewport.top + viewport.height) {
    return WindowControlsOverlayPosition(
        top: bandBottom, left: position.left);
  }

  // 2. Shift the view horizontally inwards, clear of the strip it covers
  if (overlapping.length == 1) {
    final _Strip strip = overlapping[0];
    final num left = strip.side == 'left' ? strip.end : strip.start - view.width;
    final bool fitsViewport = left >= viewport.left &&
        left + view.width <= viewport.left + viewport.width;
    if (fitsViewport &&
        !strips.any((_Strip other) =>
            overlapsStrip(position.top, left, other))) {
      return WindowControlsOverlayPosition(
          top: position.top, left: left);
    }
  }

  // 3. Move the view as far down as the viewport allows.
  return WindowControlsOverlayPosition(
    top: _mathMax(viewport.top, viewport.top + viewport.height - view.height),
    left: position.left,
  );
}

num _clamp(num value, num min, num max) => _mathMin(_mathMax(value, min), max);

num _mathMin(num a, num b) => a < b ? a : b;

num _mathMax(num a, num b) => a > b ? a : b;

bool _overlaps(num start, num end, num otherStart, num otherEnd) =>
    start < otherEnd && otherStart < end;
