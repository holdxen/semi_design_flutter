// Data-driven port test for batch99: base/browser/ui/dnd/dnd.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/dnd/dnd.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';

const String truthJson = r"""
{
  "exports": [
    "applyDragImage"
  ],
  "noTransfer": {
    "calls": [],
    "timers": 0,
    "body": {
      "id": 1,
      "className": "",
      "text": "",
      "children": []
    }
  },
  "workbench": {
    "calls": [
      [
        "setDragImage",
        5,
        -10,
        -10
      ]
    ],
    "target": 3,
    "image": {
      "id": 5,
      "className": "monaco-drag-image a b",
      "text": "hello",
      "children": []
    },
    "timers": [
      {
        "ms": 0,
        "fired": false
      }
    ],
    "afterTimer": {
      "imageRemoved": true,
      "children": 1
    }
  },
  "fallback": {
    "calls": [
      [
        "setDragImage",
        8,
        -10,
        -10
      ]
    ],
    "image": {
      "id": 8,
      "className": "monaco-drag-image",
      "text": "solo",
      "children": []
    }
  }
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> list(Object? v) => (v as List).cast<Object?>();

Map<String, Object?> snapNoId(Object? v) {
  final Map<String, Object?> m = Map<String, Object?>.from(obj(v)!);
  m.remove('id');
  return m;
}

void main() {
  late void Function()? pending;

  setUp(() {
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
    pending = null;
    uiDndSetTimeout = (void Function() cb) => pending = cb;
  });

  test('batch99 exports', () {
    expect(truth['exports'], <Object?>['applyDragImage']);
  });

  test('batch99 no dataTransfer is a no-op', () {
    final DomElement body = document.body;
    final DomDragEvent e = DomDragEvent('dragstart');
    applyDragImage(e, body, 'ignored');
    expect(pending, isNull);
    expect(body.childNodes, isEmpty);
    expect(list(obj(truth['noTransfer'])!['calls'])!.isEmpty, isTrue);
  });

  test('batch99 uses monaco-workbench ancestor and removes image on timer', () {
    final DomDocument doc = windowCarrier(mainWindow).document;
    final DomElement body = doc.body;
    final DomElement workbench = doc.createElement('div')
      ..classList.add('monaco-workbench');
    final DomElement inner = doc.createElement('div')..classList.add('inner');
    body.appendChild(workbench);
    workbench.appendChild(inner);

    final DomDragEvent e = DomDragEvent('dragstart')..dataTransfer = DomDataTransfer();
    applyDragImage(e, inner, 'hello', <String>['a', 'b']);

    final Map<String, Object?> t = obj(truth['workbench'])!;
    final List<Object?> calls = (e.dataTransfer!).setDragImageCalls;
    expect(calls.single, isA<List<Object?>>());
    final List<Object?> call = list(calls.single)!;
    expect(<Object?>[call[1], call[2]], list(list(t['calls'])!.single)!.skip(2).toList());
    expect(identical(call[0], workbench.childNodes.last), isTrue);

    final DomElement image = workbench.childNodes.last as DomElement;
    final Map<String, Object?> expectedImage = snapNoId(t['image'])
      ..remove('children');
    expect(<String, Object?>{
      'className': image.className,
      'text': image.textContent,
    }, expectedImage);
    expect(list(t['timers'])!.single, <String, Object?>{'ms': 0, 'fired': false});
    expect(pending, isNotNull);
    pending!();
    expect(t['afterTimer'], <String, Object?>{'imageRemoved': true, 'children': 1});
    expect(workbench.childNodes.single, same(inner));
  });

  test('batch99 falls back to ownerDocument.body', () {
    final DomDocument doc = windowCarrier(mainWindow).document;
    final DomElement container = doc.createElement('div')..classList.add('outside');
    final DomDragEvent e = DomDragEvent('dragstart')..dataTransfer = DomDataTransfer();
    applyDragImage(e, container, 'solo');
    final Map<String, Object?> t = obj(truth['fallback'])!;
    final DomElement image = doc.body.childNodes.last as DomElement;
    final Map<String, Object?> expectedImage = snapNoId(t['image'])
      ..remove('children');
    expect(<String, Object?>{
      'className': image.className,
      'text': image.textContent,
    }, expectedImage);
    final List<Object?> call = list((e.dataTransfer!).setDragImageCalls.single)!;
    expect(<Object?>[call[1], call[2]], <Object?>[-10, -10]);
    pending!();
  });
}
