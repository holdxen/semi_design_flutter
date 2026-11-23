// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/view/inlineEdits/inlineEditsViews/debugVisualization.ts
// Translated 1:1 from TypeScript. The browser DOM (document.createElement,
// ResizeObserver) has no Dart equivalent; bridged through replaceable
// top-level carriers (same convention as other `globalThis` bridges). The
// visualization effect / $$visualization marker logic is reproduced exactly.
// ---------------------------------------------------------------------------

import '../../../../../../../base/common/lifecycle.dart' show IDisposable;
import '../../../../../../../base/common/observable.dart' show IReader, derived;
import '../../../../../../common/core/2d/rect.dart' show Rect;

/// 1:1: `export interface IVisualizationEffect`
abstract class IVisualizationEffect {
  IDisposable visualize();
}

/// 1:1: `export function setVisualization(data: object, visualization: IVisualizationEffect): void`
void setVisualization(Object data, IVisualizationEffect visualization) {
  // TS: `(data as any)['$$visualization'] = visualization`. Data is a Map
  // carrier in the Dart port, so the marker is a Map entry.
  if (data is Map) {
    data['\$\$visualization'] = visualization;
  }
}

/// 1:1: `export function debugLogRects(rects: Record<string, Rect> | Rect[], elem: HTMLElement): object`
Object debugLogRects(Object rects, Object elem) {
  Object normalized = rects;
  if (rects is List) {
    final Map<String, Object?> record = <String, Object?>{};
    for (int index = 0; index < rects.length; index++) {
      record[index.toString()] = rects[index];
    }
    normalized = record;
  }
  final Map map = normalized as Map;
  setVisualization(map, ManyRectVisualizer(map, elem));
  return map;
}

/// 1:1: `export function debugLogRect(rect: Rect, elem: HTMLElement, name: string): Rect`
Rect debugLogRect(Rect rect, Object elem, String name) {
  setVisualization(rect, HtmlRectVisualizer(rect, elem, name));
  return rect;
}

/// 1:1: `export function debugLogHorizontalOffsetRange(rect, elem, name): Rect`
Rect debugLogHorizontalOffsetRange(Rect rect, Object elem, String name) {
  setVisualization(rect,
      HtmlHorizontalOffsetRangeVisualizer(rect, elem, name, 0, 'above'));
  return rect;
}

/// 1:1: `export function debugLogHorizontalOffsetRanges(rects, elem): object`
Object debugLogHorizontalOffsetRanges(Object rects, Object elem) {
  Object normalized = rects;
  if (rects is List) {
    final Map<String, Object?> record = <String, Object?>{};
    for (int index = 0; index < rects.length; index++) {
      record[index.toString()] = rects[index];
    }
    normalized = record;
  }
  final Map map = normalized as Map;
  setVisualization(map, ManyHorizontalOffsetRangeVisualizer(map, elem));
  return map;
}

/// 1:1: `class ManyRectVisualizer implements IVisualizationEffect`
class ManyRectVisualizer implements IVisualizationEffect {
  final Map _rects;
  final Object _elem;
  ManyRectVisualizer(this._rects, this._elem);

  @override
  IDisposable visualize() {
    final List<IDisposable> d = <IDisposable>[];
    for (final Object? key in _rects.keys) {
      if (key == '\$\$visualization') continue;
      final v = HtmlRectVisualizer(_rects[key] as Rect, _elem, key.toString());
      d.add(v.visualize());
    }
    return _disposeAll(d);
  }
}

/// 1:1: `class ManyHorizontalOffsetRangeVisualizer implements IVisualizationEffect`
class ManyHorizontalOffsetRangeVisualizer implements IVisualizationEffect {
  final Map _rects;
  final Object _elem;
  ManyHorizontalOffsetRangeVisualizer(this._rects, this._elem);

  @override
  IDisposable visualize() {
    final List<IDisposable> d = <IDisposable>[];
    final List<Object?> keys = _rects.keys.where((k) => k != '\$\$visualization').toList();
    for (int index = 0; index < keys.length; index++) {
      final String labelPosition = index % 2 == 0 ? 'above' : 'below';
      final v = HtmlHorizontalOffsetRangeVisualizer(
          _rects[keys[index]] as Rect, _elem, keys[index].toString(),
          index * 12, labelPosition);
      d.add(v.visualize());
    }
    return _disposeAll(d);
  }
}

IDisposable _disposeAll(List<IDisposable> d) => _DisposeAll(d);

class _DisposeAll implements IDisposable {
  final List<IDisposable> _items;
  _DisposeAll(this._items);
  @override
  void dispose() {
    for (final d in _items) {
      d.dispose();
    }
  }
}

/// DOM element carrier used by the visualizers (no DOM in Dart).
abstract class VizElement {
  VizElement createElement(String tag);
  void setStyle(VizElement el, String key, String value);
  void setText(VizElement el, String text);
  void appendChild(VizElement parent, VizElement child);
  void appendToBody(VizElement el);
  void remove(VizElement el);
  Map<String, num> getBoundingClientRect(VizElement el);
}

/// ResizeObserver carrier.
abstract class VizResizeObserver {
  VizResizeObserver(void Function() callback);
  void observe(VizElement el);
  void disconnect();
}

/// Replaceable DOM bridge (no-op default).
VizElement? debugVizDocument;
VizResizeObserver Function(void Function())? debugVizResizeObserverFactory;

/// 1:1: `class HtmlHorizontalOffsetRangeVisualizer implements IVisualizationEffect`
class HtmlHorizontalOffsetRangeVisualizer implements IVisualizationEffect {
  final Rect _rect;
  final Object _elem;
  final String _name;
  final num _verticalOffset;
  final String _labelPosition;
  HtmlHorizontalOffsetRangeVisualizer(this._rect, this._elem, this._name,
      [this._verticalOffset = 0, this._labelPosition = 'above']);

  @override
  IDisposable visualize() {
    final VizElement doc = debugVizDocument ?? _NoopVizElement();
    final VizElement container = doc.createElement('div');
    doc.setStyle(container, 'position', 'fixed');
    doc.setStyle(container, 'pointerEvents', 'none');
    doc.setStyle(container, 'zIndex', '100000');

    final VizElement horizontalLine = doc.createElement('div');
    doc.setStyle(horizontalLine, 'position', 'absolute');
    doc.setStyle(horizontalLine, 'height', '2px');
    doc.setStyle(horizontalLine, 'backgroundColor', 'green');
    doc.setStyle(horizontalLine, 'top', '50%');
    doc.setStyle(horizontalLine, 'transform', 'translateY(-50%)');

    final VizElement startBar = doc.createElement('div');
    doc.setStyle(startBar, 'position', 'absolute');
    doc.setStyle(startBar, 'width', '2px');
    doc.setStyle(startBar, 'height', '8px');
    doc.setStyle(startBar, 'backgroundColor', 'green');
    doc.setStyle(startBar, 'left', '0');
    doc.setStyle(startBar, 'top', '50%');
    doc.setStyle(startBar, 'transform', 'translateY(-50%)');

    final VizElement endBar = doc.createElement('div');
    doc.setStyle(endBar, 'position', 'absolute');
    doc.setStyle(endBar, 'width', '2px');
    doc.setStyle(endBar, 'height', '8px');
    doc.setStyle(endBar, 'backgroundColor', 'green');
    doc.setStyle(endBar, 'right', '0');
    doc.setStyle(endBar, 'top', '50%');
    doc.setStyle(endBar, 'transform', 'translateY(-50%)');

    final VizElement label = doc.createElement('div');
    doc.setText(label, _name);
    doc.setStyle(label, 'position', 'absolute');
    if (_labelPosition == 'above') {
      doc.setStyle(label, 'bottom', '12px');
    } else {
      doc.setStyle(label, 'top', '12px');
    }
    doc.setStyle(label, 'left', '2px');
    doc.setStyle(label, 'color', 'green');
    doc.setStyle(label, 'fontSize', '10px');
    doc.setStyle(label, 'backgroundColor', 'rgba(255, 255, 255, 0.95)');
    doc.setStyle(label, 'padding', '1px 3px');
    doc.setStyle(label, 'border', '1px solid green');
    doc.setStyle(label, 'borderRadius', '2px');
    doc.setStyle(label, 'whiteSpace', 'nowrap');
    doc.setStyle(label, 'boxShadow', '0 1px 2px rgba(0,0,0,0.15)');
    doc.setStyle(label, 'fontFamily', 'monospace');

    doc.appendChild(container, horizontalLine);
    doc.appendChild(container, startBar);
    doc.appendChild(container, endBar);
    doc.appendChild(container, label);

    void updatePosition() {
      final Map<String, num> elemRect =
          doc.getBoundingClientRect(_elem as VizElement);
      final num centerY = _rect.top + (_rect.height / 2) + _verticalOffset;
      final num left = (elemRect['left'] ?? 0) + _rect.left;
      final num width = _rect.width;
      doc.setStyle(container, 'left', '$left');
      doc.setStyle(container, 'top', '${(elemRect['top'] ?? 0) + centerY}');
      doc.setStyle(container, 'width', '$width');
      doc.setStyle(container, 'height', '8');
      doc.setStyle(horizontalLine, 'width', '$width');
    }

    doc.appendToBody(container);
    updatePosition();

    final VizResizeObserver observer =
        (debugVizResizeObserverFactory ?? _defaultResizeObserver)(updatePosition);
    observer.observe(_elem as VizElement);

    return _VizDisposable(() {
      observer.disconnect();
      doc.remove(container);
    });
  }
}

/// 1:1: `class HtmlRectVisualizer implements IVisualizationEffect`
class HtmlRectVisualizer implements IVisualizationEffect {
  final Rect _rect;
  final Object _elem;
  final String _name;
  HtmlRectVisualizer(this._rect, this._elem, this._name);

  @override
  IDisposable visualize() {
    final VizElement doc = debugVizDocument ?? _NoopVizElement();
    final VizElement div = doc.createElement('div');
    doc.setStyle(div, 'position', 'fixed');
    doc.setStyle(div, 'border', '1px solid red');
    doc.setStyle(div, 'boxSizing', 'border-box');
    doc.setStyle(div, 'pointerEvents', 'none');
    doc.setStyle(div, 'zIndex', '100000');

    final VizElement label = doc.createElement('div');
    doc.setText(label, _name);
    doc.setStyle(label, 'position', 'absolute');
    doc.setStyle(label, 'top', '-20px');
    doc.setStyle(label, 'left', '0');
    doc.setStyle(label, 'color', 'red');
    doc.setStyle(label, 'fontSize', '12px');
    doc.setStyle(label, 'backgroundColor', 'rgba(255, 255, 255, 0.7)');
    doc.appendChild(div, label);

    void updatePosition() {
      final Map<String, num> elemRect =
          doc.getBoundingClientRect(_elem as VizElement);
      doc.setStyle(div, 'left', '${(elemRect['left'] ?? 0) + _rect.left}');
      doc.setStyle(div, 'top', '${(elemRect['top'] ?? 0) + _rect.top}');
      doc.setStyle(div, 'width', '${_rect.width}');
      doc.setStyle(div, 'height', '${_rect.height}');
    }

    doc.appendToBody(div);
    updatePosition();

    final VizResizeObserver observer =
        (debugVizResizeObserverFactory ?? _defaultResizeObserver)(updatePosition);
    observer.observe(_elem as VizElement);

    return _VizDisposable(() {
      observer.disconnect();
      doc.remove(div);
    });
  }
}

VizResizeObserver _defaultResizeObserver(void Function() cb) =>
    debugVizResizeObserverFactory != null
        ? debugVizResizeObserverFactory!(cb)
        : _NoopResizeObserver(cb);

class _VizDisposable implements IDisposable {
  final void Function() _fn;
  _VizDisposable(this._fn);
  @override
  void dispose() => _fn();
}

/// 1:1: `export function debugView(value: unknown, reader: IReader): void`
void debugView(Object? value, IReader reader) {
  if (value is Map && value.containsKey('\$\$visualization')) {
    final IVisualizationEffect vis = value['\$\$visualization'] as IVisualizationEffect;
    debugReadDisposable(vis.visualize(), reader);
  }
}

/// 1:1: `function debugReadDisposable(d: IDisposable, reader: IReader): void`
void debugReadDisposable(IDisposable d, IReader reader) {
  derived<Object?, Object?>((dynamic _reader) {
    (_reader.store as dynamic).add(d);
    return null;
  }).read(reader);
}

// ---- default no-op DOM carrier ----
class _NoopVizElement implements VizElement {
  @override
  VizElement createElement(String tag) => this;
  @override
  void setStyle(VizElement el, String key, String value) {}
  @override
  void setText(VizElement el, String text) {}
  @override
  void appendChild(VizElement parent, VizElement child) {}
  @override
  void appendToBody(VizElement el) {}
  @override
  void remove(VizElement el) {}
  @override
  Map<String, num> getBoundingClientRect(VizElement el) =>
      <String, num>{'left': 0, 'top': 0};
}

class _NoopResizeObserver implements VizResizeObserver {
  _NoopResizeObserver(void Function() cb);
  @override
  void observe(VizElement el) {}
  @override
  void disconnect() {}
}
