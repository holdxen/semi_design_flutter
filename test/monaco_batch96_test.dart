// Data-driven port test for batch96: base/browser/dnd.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dnd.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';

const String truthJson = r"""
{
  "exports": [
    "DataTransfers",
    "DelayedDragHandler"
  ],
  "dataTransfers": {
    "RESOURCES": "ResourceURLs",
    "DOWNLOAD_URL": "DownloadURL",
    "FILES": "Files",
    "TEXT": "text/plain",
    "INTERNAL_URI_LIST": "application/vnd.code.uri-list"
  },
  "arm": {
    "prevented": true,
    "timers": [
      {
        "id": 1,
        "ms": 800,
        "fired": false,
        "cancelled": false
      }
    ],
    "calls": 0,
    "afterFire": {
      "calls": 1,
      "timers": [
        {
          "id": 1,
          "ms": 800,
          "fired": true,
          "cancelled": false
        }
      ]
    }
  },
  "abort": {
    "calls": 0,
    "snapshots": [
      {
        "type": "dragleave",
        "timer": {
          "id": 2,
          "ms": 800,
          "fired": false,
          "cancelled": true
        }
      },
      {
        "type": "drop",
        "timer": {
          "id": 2,
          "ms": 800,
          "fired": false,
          "cancelled": true
        }
      },
      {
        "type": "dragend",
        "timer": {
          "id": 2,
          "ms": 800,
          "fired": false,
          "cancelled": true
        }
      }
    ]
  },
  "dispose": {
    "calls": 0,
    "timer": {
      "id": 3,
      "ms": 800,
      "fired": false,
      "cancelled": true
    }
  },
  "listeners": {
    "c1": [
      "dragover",
      "dragleave",
      "drop",
      "dragend"
    ],
    "c1DisposedAfterFire": true
  }
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> list(Object? v) => (v as List).cast<Object?>();

class FakeHandle implements DndTimeoutHandle {
  @override
  final int milliseconds;
  @override
  bool cancelled = false;
  bool fired = false;
  final void Function() callback;

  FakeHandle(this.callback, this.milliseconds);

  void fire() {
    fired = true;
    callback();
  }

  @override
  void cancel() => cancelled = true;

  Map<String, Object?> snap(int id) => <String, Object?>{
        'id': id,
        'ms': milliseconds,
        'fired': fired,
        'cancelled': cancelled,
      };
}

class Recorder {
  final List<FakeHandle> handles = <FakeHandle>[];
  DndTimeoutHandle set(void Function() callback, int milliseconds) {
    final FakeHandle h = FakeHandle(callback, milliseconds);
    handles.add(h);
    return h;
  }

  void clear(DndTimeoutHandle handle) => handle.cancel();
}

void main() {
  late Recorder recorder;

  setUp(() {
    recorder = Recorder();
    dndSetTimeout = recorder.set;
    dndClearTimeout = recorder.clear;
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
  });

  tearDown(() {
    dndSetTimeout = (void Function() callback, int milliseconds) =>
        throw StateError('Unexpected timer');
    dndClearTimeout = (DndTimeoutHandle handle) {};
  });

  test('batch96 exports and data transfers', () {
    expect(truth['exports'], <Object?>['DataTransfers', 'DelayedDragHandler']);
    expect(obj(truth['dataTransfers']), <String, Object?>{
      'RESOURCES': DataTransfers.RESOURCES,
      'DOWNLOAD_URL': DataTransfers.DOWNLOAD_URL,
      'FILES': DataTransfers.FILES,
      'TEXT': DataTransfers.TEXT,
      'INTERNAL_URI_LIST': DataTransfers.INTERNAL_URI_LIST,
    });
  });

  test('batch96 dragover arms one 800ms timer and prevents default', () {
    final DomElement container = document.createElement('div');
    int calls = 0;
    final DelayedDragHandler handler =
        DelayedDragHandler(container, () => calls++);
    final DomEvent ev = DomEvent('dragover');
    container.dispatchEvent('dragover', ev);
    container.dispatchEvent('dragover', ev);
    final Map<String, Object?> t = obj(truth['arm'])!;
    expect(ev.defaultPrevented, t['prevented']);
    expect(recorder.handles.length, 1);
    expect(recorder.handles.single.snap(1), list(t['timers'])!.single);
    expect(calls, t['calls']);

    recorder.handles.single.fire();
    expect(calls, obj(t['afterFire'])!['calls']);
    expect(handler.timeout, isNull);
    expect(recorder.handles.single.snap(1),
        list(obj(t['afterFire'])!['timers'])!.single);
  });

  test('batch96 drag aborts clear the pending timer', () {
    for (final Object? raw in list(obj(truth['abort'])!['snapshots'])!) {
      final Recorder r = Recorder();
      dndSetTimeout = r.set;
      dndClearTimeout = r.clear;
      final Map<String, Object?> c = obj(raw)!;
      final DomElement container = document.createElement('div');
      int calls = 0;
      DelayedDragHandler(container, () => calls++);
      container.dispatchEvent('dragover', DomEvent('dragover'));
      container.dispatchEvent(c['type'] as String, DomEvent(c['type'] as String));
      expect(calls, obj(truth['abort'])!['calls']);
      final Map<String, Object?> t = Map<String, Object?>.from(obj(c['timer'])!)
        ..remove('id');
      final Map<String, Object?> a = Map<String, Object?>.from(r.handles.single.snap(1))
        ..remove('id');
      expect(a, t);
    }
  });

  test('batch96 dispose clears pending timer', () {
    final DomElement container = document.createElement('div');
    int calls = 0;
    final DelayedDragHandler handler =
        DelayedDragHandler(container, () => calls++);
    container.dispatchEvent('dragover', DomEvent('dragover'));
    handler.dispose();
    container.dispatchEvent('dragover', DomEvent('dragover'));
    final Map<String, Object?> t = obj(truth['dispose'])!;
    expect(calls, t['calls']);
    final Map<String, Object?> e = Map<String, Object?>.from(obj(t['timer'])!)
      ..remove('id');
    final Map<String, Object?> a = Map<String, Object?>.from(recorder.handles.single.snap(1))
      ..remove('id');
    expect(a, e);
  });
}
