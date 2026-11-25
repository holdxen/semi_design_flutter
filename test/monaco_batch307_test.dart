// batch307: colorPickerSaturationBox.ts truth replay.
// Truth from tool/ts2dart/batch307_truth.json (recursive TS transpile + vm,
// real Color/HSVA and real pointer monitor with stubbed DOM environment).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/color.dart'
    show Color, HSVA;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, toDisposable;
import 'package:semi_design_flutter/src/monaco/editor/contrib/colorPicker/browser/colorPickerParts/colorPickerSaturationBox.dart'
    show
      IColorPickerModelForSaturationBox,
      ISaturationCanvas,
      ISaturationContext,
      ISaturationGradient,
      ISaturationNode,
      ISaturationPointerMonitor,
      SaturationBox,
      SaturationBoxDomEnvironment,
      SaturationPointerEvent;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch307_truth.json').readAsStringSync())
    as Map<String, dynamic>;

final List<List<Object?>> listenerLog = <List<Object?>>[];

class _Node implements ISaturationNode {
  _Node(this.tagName);

  final String tagName;

  @override
  String className = '';

  @override
  final Map<String, String> style = <String, String>{};

  @override
  int offsetWidth = 100;

  @override
  int offsetHeight = 50;

  @override
  final List<ISaturationNode> children = <ISaturationNode>[];

  final Map<String, List<void Function(Object)>> listeners =
      <String, List<void Function(Object)>>{};

  @override
  ISaturationNode appendChild(ISaturationNode child) {
    children.add(child);
    return child;
  }

  @override
  IDisposable addListener(String type, void Function(Object event) listener) {
    listeners.putIfAbsent(type, () => <void Function(Object)>[]).add(listener);
    listenerLog.add(<Object?>[tagName, type]);
    return toDisposable(() {
      listeners[type]?.remove(listener);
    });
  }

  void fire(String type, Object event) {
    for (final void Function(Object) l in List<void Function(Object)>.from(
        listeners[type] ?? <void Function(Object)>[])) {
      l(event);
    }
  }
}

class _Gradient implements ISaturationGradient {
  final List<Object?> bounds;
  final List<Object?> stops = <Object?>[];

  _Gradient(this.bounds);

  @override
  void addColorStop(double offset, String color) =>
      stops.add(<Object?>[offset, color]);
}

class _Context implements ISaturationContext {
  final List<Object?> calls = <Object?>[];
  final List<_Gradient> gradients = <_Gradient>[];

  @override
  ISaturationGradient createLinearGradient(int x0, int y0, int x1, int y1) {
    final _Gradient g = _Gradient(<Object?>[x0, y0, x1, y1]);
    gradients.add(g);
    calls.add(<Object?>['gradient', x0, y0, x1, y1]);
    return g;
  }

  @override
  void rect(int x, int y, int width, int height) =>
      calls.add(<Object?>['rect', x, y, width, height]);

  @override
  set fillStyle(Object value) => calls.add(<Object?>[
        'fillStyle',
        value is String ? value : 'gradient',
      ]);

  @override
  void fill() => calls.add(<Object?>['fill']);
}

class _Canvas extends _Node implements ISaturationCanvas {
  _Canvas() : super('CANVAS');

  @override
  int width = 0;

  @override
  int height = 0;

  final _Context context = _Context();

  @override
  ISaturationContext getContext(String kind) => context;
}

class _Monitor implements ISaturationPointerMonitor {
  void Function(Object)? moveCallback;
  void Function([Object?])? stopCallback;

  @override
  bool isMonitoring() => moveCallback != null;

  @override
  void startMonitoring(
    ISaturationNode initialElement,
    int pointerId,
    int buttons,
    void Function(Object event) pointerMoveCallback,
    void Function([Object? event]) stopCallback,
  ) {
    moveCallback = pointerMoveCallback;
    this.stopCallback = stopCallback;
    initialElement.addListener('pointermove', pointerMoveCallback);
    initialElement.addListener('pointerup', (_) => stopMonitoring(true));
  }

  @override
  void stopMonitoring(bool invokeStopCallback) {
    final void Function([Object?])? cb = stopCallback;
    moveCallback = null;
    stopCallback = null;
    if (invokeStopCallback && cb != null) {
      cb();
    }
  }
}

class _Model implements IColorPickerModelForSaturationBox {
  final List<void Function(Color)> listeners = <void Function(Color)>[];

  @override
  Color color = Color(HSVA(0.5, 0.25, 0.75, 1));

  @override
  IDisposable onDidChangeColor(void Function(Color color) listener) {
    listeners.add(listener);
    return toDisposable(() => listeners.remove(listener));
  }

  void setColor(Color c) {
    color = c;
    for (final void Function(Color) l in List<void Function(Color)>.from(
        listeners)) {
      l(c);
    }
  }
}

Map<String, Object?> _domJson(SaturationBox box, _Canvas canvas) =>
    <String, Object?>{
      'wrapClass': box.domNode.className,
      'canvasClass': canvas.className,
      'canvasSize': <Object?>[canvas.width, canvas.height],
      'selection': <String, Object?>{
        'left': box.selectionStyle['left'],
        'top': box.selectionStyle['top'],
      },
      'calls': List<Object?>.from(canvas.context.calls),
      'gradients': canvas.context.gradients
          .map((g) => <String, Object?>{
                'bounds': g.bounds,
                'stops': List<Object?>.from(g.stops),
              })
          .toList(),
    };

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<dynamic> expected = truth['results'] as List<dynamic>;

  test('saturation box truth replay', () {
  final _Node documentNode = _Node('DOCUMENT');
  final _Node container = _Node('DIV');
  final _Canvas canvas = _Canvas();
  final _Model model = _Model();
  final _Monitor monitor = _Monitor();
  final List<Object?> changes = <Object?>[];
  final List<Object?> flushed = <Object?>[];

  late SaturationBox box;
  final SaturationBoxDomEnvironment env = SaturationBoxDomEnvironment(
    createNode: (String description) =>
        _Node(description.startsWith('.') ? 'DIV' : 'DIV')
          ..className = description.replaceFirst('.', ''),
    createCanvas: () => canvas,
    getDomNodePagePosition: (_) => (left: 10.0, top: 20.0),
    getOwnerDocument: (_) => documentNode,
  );

  box = SaturationBox(container, model, 2, env, monitor);
  final _Node boxNode = box.domNode as _Node;
  box.onDidChange((e) => changes.add(<Object?>[e['s'], e['v']]));
  box.onColorFlushed((_) => flushed.add('flush'));

  final List<Map<String, Object?>> actual = <Map<String, Object?>>[];

  actual.add(<String, Object?>{
    'label': 'constructed',
    'dom': _domJson(box, canvas),
    'children': container.children
        .map((c) => (c as _Node).className)
        .toList(),
  });

  boxNode.offsetWidth = 200;
  boxNode.offsetHeight = 100;
  box.layout();
  actual.add(<String, Object?>{
    'label': 'layout',
    'dom': _domJson(box, canvas),
  });

  final SaturationPointerEvent down = SaturationPointerEvent(
    target: canvas,
    pointerId: 1,
    buttons: 1,
    offsetX: 40.0,
    offsetY: 75.0,
    pageX: 70.0,
    pageY: 95.0,
  );
  boxNode.fire('pointerdown', down);
  actual.add(<String, Object?>{
    'label': 'pointer-down',
    'dom': _domJson(box, canvas),
    'changes': List<Object?>.from(changes),
    'listeners': listenerLog.map((e) => List<Object?>.from(e)).toList(),
  });
  changes.clear();

  monitor.moveCallback!(SaturationPointerEvent(
    target: canvas,
    pointerId: 1,
    buttons: 1,
    offsetX: 0.0,
    offsetY: 0.0,
    pageX: 210.0,
    pageY: 20.0,
  ));
  actual.add(<String, Object?>{
    'label': 'pointer-move',
    'dom': _domJson(box, canvas),
    'changes': List<Object?>.from(changes),
  });
  changes.clear();

  documentNode.fire('pointerup', down);
  actual.add(<String, Object?>{
    'label': 'pointer-up',
    'flushed': List<Object?>.from(flushed),
  });
  flushed.clear();

  model.setColor(Color(HSVA(0.2, 0.8, 0.4, 1)));
  actual.add(<String, Object?>{
    'label': 'color-change-after-up',
    'dom': _domJson(box, canvas),
  });

  expect(actual, expected);
  });
}
