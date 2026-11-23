// Data-driven port test for batch98: base/browser/ui/aria/aria.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/aria/aria.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';

const String truthJson = r"""
{
  "exports": [
    "alert",
    "setARIAContainer",
    "status"
  ],
  "container": {
    "tag": "body",
    "className": "",
    "attributes": {},
    "text": "",
    "children": [
      {
        "tag": "div",
        "className": "monaco-aria-container",
        "attributes": {},
        "text": "",
        "children": [
          {
            "tag": "div",
            "className": "monaco-alert",
            "attributes": {
              "role": "alert",
              "aria-atomic": "true"
            },
            "text": "",
            "children": []
          },
          {
            "tag": "div",
            "className": "monaco-alert",
            "attributes": {
              "role": "alert",
              "aria-atomic": "true"
            },
            "text": "",
            "children": []
          },
          {
            "tag": "div",
            "className": "monaco-status",
            "attributes": {
              "aria-live": "polite",
              "aria-atomic": "true"
            },
            "text": "",
            "children": []
          },
          {
            "tag": "div",
            "className": "monaco-status",
            "attributes": {
              "aria-live": "polite",
              "aria-atomic": "true"
            },
            "text": "",
            "children": []
          }
        ]
      }
    ]
  },
  "events": [
    [
      "clear",
      4
    ],
    [
      "clear",
      3
    ],
    [
      "text",
      5
    ],
    [
      "visibility",
      3,
      "hidden"
    ],
    [
      "visibility",
      3,
      "visible"
    ],
    [
      "clear",
      3
    ],
    [
      "clear",
      4
    ],
    [
      "text",
      5
    ],
    [
      "visibility",
      4,
      "hidden"
    ],
    [
      "visibility",
      4,
      "visible"
    ],
    [
      "clear",
      4
    ],
    [
      "clear",
      3
    ],
    [
      "text",
      6
    ],
    [
      "visibility",
      3,
      "hidden"
    ],
    [
      "visibility",
      3,
      "visible"
    ],
    [
      "clear",
      6
    ],
    [
      "clear",
      5
    ],
    [
      "text",
      2
    ],
    [
      "visibility",
      5,
      "hidden"
    ],
    [
      "visibility",
      5,
      "visible"
    ],
    [
      "clear",
      5
    ],
    [
      "clear",
      6
    ],
    [
      "text",
      2
    ],
    [
      "visibility",
      6,
      "hidden"
    ],
    [
      "visibility",
      6,
      "visible"
    ]
  ],
  "containerAfter": {
    "tag": "body",
    "className": "",
    "attributes": {},
    "text": "",
    "children": [
      {
        "tag": "div",
        "className": "monaco-aria-container",
        "attributes": {},
        "text": "",
        "children": [
          {
            "tag": "div",
            "className": "monaco-alert",
            "attributes": {
              "role": "alert",
              "aria-atomic": "true"
            },
            "text": "second",
            "children": []
          },
          {
            "tag": "div",
            "className": "monaco-alert",
            "attributes": {
              "role": "alert",
              "aria-atomic": "true"
            },
            "text": "",
            "children": []
          },
          {
            "tag": "div",
            "className": "monaco-status",
            "attributes": {
              "aria-live": "polite",
              "aria-atomic": "true"
            },
            "text": "",
            "children": []
          },
          {
            "tag": "div",
            "className": "monaco-status",
            "attributes": {
              "aria-live": "polite",
              "aria-atomic": "true"
            },
            "text": "s1",
            "children": []
          }
        ]
      }
    ]
  },
  "textsAfter": [
    "second",
    "",
    "",
    "s1"
  ],
  "longMessage": {
    "insertedLengths": [
      20000
    ]
  },
  "beforeInit": {
    "events": [],
    "ok": true
  }
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> list(Object? v) => (v as List).cast<Object?>();

Map<String, Object?> snap(DomElement e) => <String, Object?>{
      'tag': e.localName,
      'className': e.className,
      'attributes': Map<String, Object?>.fromEntries(e.attributes
          .map((MapEntry<String, String> a) => MapEntry<String, Object?>(a.key, a.value))),
      'text': e.textContent,
      'children': e.childNodes
          .whereType<DomElement>()
          .map((DomElement c) => snap(c))
          .toList(),
    };

List<Object?> texts(DomElement e) {
  final List<Object?> out = <Object?>[];
  void walk(DomElement n) {
    if (n.childNodes.whereType<DomElement>().isEmpty) {
      out.add(n.textContent);
    }
    n.childNodes.whereType<DomElement>().forEach(walk);
  }
  walk(e);
  return out;
}

void main() {
  setUp(() {
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
    ariaContainer = null;
    alertContainer = null;
    alertContainer2 = null;
    statusContainer = null;
    statusContainer2 = null;
  });

  test('batch98 exports', () {
    expect(truth['exports'], <Object?>['alert', 'setARIAContainer', 'status']);
  });

  test('batch98 container structure', () {
    final DomElement parent = document.createElement('body');
    setARIAContainer(parent);
    expect(snap(parent), obj(truth['container']));
  });

  test('batch98 alternating containers and truncation', () {
    final DomElement parent = document.createElement('body');
    setARIAContainer(parent);

    alert('first');
    alert('first');
    alert('second');
    status('s1');
    status('s1');
    expect(texts(parent), truth['textsAfter']);

    expect(alertContainer!.textContent, 'second');
    expect(alertContainer2!.textContent, '');
    expect(statusContainer!.textContent, '');
    expect(statusContainer2!.textContent, 's1');
    expect(alertContainer!.style.getPropertyValue('visibility'), 'visible');

    alert('x' * 20050);
    expect(alertContainer!.textContent.length,
        list(obj(truth['longMessage'])!['insertedLengths'])!.single);
  });

  test('batch98 alert/status before init are no-ops', () {
    alert('ignored');
    status('ignored');
    expect(truth['beforeInit'], isA<Map<String, Object?>>());
    expect(list(obj(truth['beforeInit'])!['events'])!.isEmpty, isTrue);
  });
}
