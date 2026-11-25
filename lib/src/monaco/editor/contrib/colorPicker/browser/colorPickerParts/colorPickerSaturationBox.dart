// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/colorPicker/browser/colorPickerParts/
// colorPickerSaturationBox.ts
//
// Adaptations (documented inline):
//  * DOM nodes/canvas/listeners and GlobalPointerMoveMonitor are injected as
//    narrow contracts — Dart has no browser DOM.
//  * `IColorPickerModel` is reduced to the members actually read.
//  * JS number -> string in CSS values uses [_jsNum] (no ".0" suffix).
// ---------------------------------------------------------------------------
import '../../../../../base/common/color.dart' show Color, ColorFormatCSS, HSVA;
import '../../../../../base/common/event.dart' show Emitter, Event;
import '../../../../../base/common/lifecycle.dart' show Disposable, IDisposable;

/// 1:1: DOM node surface used by the box.
abstract class ISaturationNode {
  String get className;
  set className(String value);
  Map<String, String> get style;
  int get offsetWidth;
  int get offsetHeight;
  List<ISaturationNode> get children;
  ISaturationNode appendChild(ISaturationNode child);
  IDisposable addListener(String type, void Function(Object event) listener);
}

/// 1:1: canvas gradient surface.
abstract class ISaturationGradient {
  void addColorStop(double offset, String color);
}

/// 1:1: canvas 2d context surface.
abstract class ISaturationContext {
  ISaturationGradient createLinearGradient(
      int x0, int y0, int x1, int y1);
  void rect(int x, int y, int width, int height);
  set fillStyle(Object value);
  void fill();
}

/// 1:1: canvas surface.
abstract class ISaturationCanvas extends ISaturationNode {
  int get width;
  set width(int value);
  int get height;
  set height(int value);
  ISaturationContext getContext(String kind);
}

/// 1:1: `GlobalPointerMoveMonitor` surface.
abstract class ISaturationPointerMonitor {
  bool isMonitoring();
  void startMonitoring(
    ISaturationNode initialElement,
    int pointerId,
    int buttons,
    void Function(Object event) pointerMoveCallback,
    void Function([Object? event]) stopCallback,
  );
  void stopMonitoring(bool invokeStopCallback);
}

/// 1:1: `PointerEvent` surface read here.
class SaturationPointerEvent {
  final Object? target;
  final int pointerId;
  final int buttons;
  final double offsetX;
  final double offsetY;
  final double pageX;
  final double pageY;

  SaturationPointerEvent({
    required this.target,
    required this.pointerId,
    required this.buttons,
    required this.offsetX,
    required this.offsetY,
    required this.pageX,
    required this.pageY,
  });
}

/// 1:1: `ColorPickerModel` members read here.
abstract class IColorPickerModelForSaturationBox {
  Color get color;
  IDisposable onDidChangeColor(void Function(Color color) listener);
}

/// 1:1: DOM environment providers (`$`, `document.createElement`,
/// `dom.getDomNodePagePosition`).
class SaturationBoxDomEnvironment {
  final ISaturationNode Function(String description) createNode;
  final ISaturationCanvas Function() createCanvas;
  final ({double left, double top}) Function(ISaturationNode node)
      getDomNodePagePosition;
  final ISaturationNode Function(ISaturationNode node) getOwnerDocument;

  SaturationBoxDomEnvironment({
    required this.createNode,
    required this.createCanvas,
    required this.getDomNodePagePosition,
    required this.getOwnerDocument,
  });
}

String _jsNum(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

/// 1:1: `export class SaturationBox extends Disposable`.
class SaturationBox extends Disposable {
  final ISaturationNode _domNode;
  final ISaturationNode selection;
  final ISaturationCanvas _canvas;
  final IColorPickerModelForSaturationBox _model;
  final double _pixelRatio;
  final ISaturationPointerMonitor _monitor;
  final SaturationBoxDomEnvironment _dom;

  late int width;
  late int height;

  final Emitter<Map<String, double>> _onDidChange =
      Emitter<Map<String, double>>();
  late final Event<Map<String, double>> onDidChange = _onDidChange.event;

  final Emitter<void> _onColorFlushed = Emitter<void>();
  late final Event<void> onColorFlushed = _onColorFlushed.event;

  SaturationBox(
    ISaturationNode container,
    this._model,
    this._pixelRatio,
    this._dom,
    this._monitor,
  )   : _domNode = _dom.createNode('.saturation-wrap'),
        selection = _dom.createNode('.saturation-selection'),
        _canvas = _dom.createCanvas() {
    _domNode.className = 'saturation-wrap';
    container.appendChild(_domNode);
    _canvas.className = 'saturation-box';
    _domNode.appendChild(_canvas);
    _domNode.appendChild(selection);
    layout();
    register(_domNode.addListener('pointerdown', onPointerDown));
    register(_model.onDidChangeColor(onDidChangeColor));
  }

  ISaturationNode get domNode => _domNode;

  void onPointerDown(Object event) {
    final SaturationPointerEvent e = event as SaturationPointerEvent;
    final Object? target = e.target;
    if (target == null || target is! ISaturationNode) {
      return;
    }
    final ({double left, double top}) origin =
        _dom.getDomNodePagePosition(_domNode);

    if (!identical(target, selection)) {
      onDidChangePosition(e.offsetX, e.offsetY);
    }

    _monitor.startMonitoring(
      target,
      e.pointerId,
      e.buttons,
      (Object moveEvent) {
        final SaturationPointerEvent m = moveEvent as SaturationPointerEvent;
        onDidChangePosition(m.pageX - origin.left, m.pageY - origin.top);
      },
      ([Object? event]) {},
    );

    final ISaturationNode ownerDocument = _dom.getOwnerDocument(target);
    late final IDisposable pointerUpListener;
    pointerUpListener = ownerDocument.addListener('pointerup', (_) {
      _onColorFlushed.fire(null);
      pointerUpListener.dispose();
      _monitor.stopMonitoring(true);
    });
  }

  void onDidChangePosition(double left, double top) {
    final double s = left / width < 0
        ? 0
        : (left / width > 1 ? 1 : left / width);
    final double v = 1 - top / height < 0
        ? 0
        : (1 - top / height > 1 ? 1 : 1 - top / height);

    paintSelection(s, v);
    _onDidChange.fire(<String, double>{'s': s, 'v': v});
  }

  void layout() {
    width = _domNode.offsetWidth;
    height = _domNode.offsetHeight;
    _canvas.width = (width * _pixelRatio).toInt();
    _canvas.height = (height * _pixelRatio).toInt();
    paint();

    final HSVA hsva = _model.color.hsva;
    paintSelection(hsva.s, hsva.v);
  }

  void paint() {
    final HSVA hsva = _model.color.hsva;
    final Color saturatedColor = Color(HSVA(hsva.h, 1, 1, 1));
    final ISaturationContext ctx = _canvas.getContext('2d');

    final ISaturationGradient whiteGradient =
        ctx.createLinearGradient(0, 0, _canvas.width, 0);
    whiteGradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
    whiteGradient.addColorStop(0.5, 'rgba(255, 255, 255, 0.5)');
    whiteGradient.addColorStop(1, 'rgba(255, 255, 255, 0)');

    final ISaturationGradient blackGradient =
        ctx.createLinearGradient(0, 0, 0, _canvas.height);
    blackGradient.addColorStop(0, 'rgba(0, 0, 0, 0)');
    blackGradient.addColorStop(1, 'rgba(0, 0, 0, 1)');

    ctx.rect(0, 0, _canvas.width, _canvas.height);
    ctx.fillStyle = ColorFormatCSS.format(saturatedColor);
    ctx.fill();
    ctx.fillStyle = whiteGradient;
    ctx.fill();
    ctx.fillStyle = blackGradient;
    ctx.fill();
  }

  void paintSelection(double s, double v) {
    selection.style['left'] = '${_jsNum(s * width)}px';
    selection.style['top'] = '${_jsNum(height - v * height)}px';
  }

  void onDidChangeColor(Color color) {
    if (_monitor.isMonitoring()) {
      return;
    }
    paint();
    final HSVA hsva = color.hsva;
    paintSelection(hsva.s, hsva.v);
  }
}
