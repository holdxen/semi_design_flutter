// Data-driven port test for batch101: base/browser/formattedTextRenderer.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/formattedTextRenderer.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart';

const String truthJson = r"""
{
  "exports": [
    "renderFormattedText",
    "renderText"
  ],
  "renderText": [
    "div",
    [
      [
        "text",
        "a<b>& c"
      ]
    ]
  ],
  "renderTextTarget": {
    "same": true,
    "tree": [
      "div",
      [
        [
          "text",
          "x"
        ]
      ]
    ]
  },
  "cases": [
    {
      "name": "plain",
      "tree": [
        "div",
        [
          [
            "text",
            "hello"
          ]
        ]
      ]
    },
    {
      "name": "bold",
      "tree": [
        "div",
        [
          [
            "b",
            [
              [
                "text",
                "bold"
              ]
            ]
          ]
        ]
      ]
    },
    {
      "name": "italics",
      "tree": [
        "div",
        [
          [
            "i",
            [
              [
                "text",
                "ital"
              ]
            ]
          ]
        ]
      ]
    },
    {
      "name": "action",
      "tree": [
        "div",
        [
          [
            "a",
            [
              [
                "text",
                "click"
              ]
            ]
          ]
        ]
      ]
    },
    {
      "name": "code-off",
      "tree": [
        "div",
        [
          [
            "text",
            "``code``"
          ]
        ]
      ]
    },
    {
      "name": "code-on",
      "tree": [
        "div",
        [
          [
            "code",
            [
              [
                "text",
                "code"
              ]
            ]
          ]
        ]
      ]
    },
    {
      "name": "newline",
      "tree": [
        "div",
        [
          [
            "text",
            "a"
          ],
          [
            "br",
            []
          ],
          [
            "text",
            "b"
          ]
        ]
      ]
    },
    {
      "name": "escape",
      "tree": [
        "div",
        [
          [
            "text",
            "**not bold**"
          ]
        ]
      ]
    },
    {
      "name": "nested",
      "tree": [
        "div",
        [
          [
            "b",
            [
              [
                "text",
                "a "
              ],
              [
                "i",
                [
                  [
                    "text",
                    "b"
                  ]
                ]
              ],
              [
                "text",
                " "
              ],
              [
                "a",
                [
                  [
                    "text",
                    "c"
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    },
    {
      "name": "unmatched",
      "tree": [
        "div",
        [
          [
            "b",
            [
              [
                "text",
                "abc"
              ]
            ]
          ]
        ]
      ]
    },
    {
      "name": "triple-tag",
      "tree": [
        "div",
        [
          [
            "b",
            [
              [
                "text",
                "*x"
              ]
            ]
          ],
          [
            "text",
            "*"
          ]
        ]
      ]
    },
    {
      "name": "action-close-only",
      "tree": [
        "div",
        [
          [
            "text",
            "]x"
          ]
        ]
      ]
    }
  ],
  "actions": {
    "linkCount": 2,
    "callbacks": [
      [
        "fired",
        "0",
        "click"
      ],
      [
        "fired",
        "1",
        "click"
      ]
    ],
    "registrations": 4
  }
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
List<Object?> list(Object? v) => (v as List).cast<Object?>();
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();

Object snap(DomNode n) {
  if (n is DomTextNode) return <Object?>['text', n.data];
  final DomElement e = n as DomElement;
  return <Object?>[e.localName, e.childNodes.map(snap).toList()];
}

void collectLinks(DomNode n, List<DomElement> out) {
  if (n is DomElement && n.localName == 'a') out.add(n);
  n.childNodes.forEach((DomNode c) => collectLinks(c, out));
}

void main() {
  setUp(() {
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
  });

  test('batch101 exports', () {
    expect(truth['exports'], <Object?>['renderFormattedText', 'renderText']);
  });

  test('batch101 renderText', () {
    expect(snap(renderText('a<b>& c')), truth['renderText']);
    final DomElement target = document.createElement('div');
    expect(identical(renderText('x', null, target), target),
        obj(truth['renderTextTarget'])!['same']);
    expect(snap(target), <Object?>['div', <Object?>[<Object?>['text', 'x']]]);
  });

  test('batch101 formatting matrix matches truth', () {
    for (final Object? raw in list(truth['cases'])!) {
      final Map<String, Object?> c = obj(raw)!;
      final Map<String, Object?> input = <String, Object?>{
        'plain': 'hello',
        'bold': '**bold**',
        'italics': '__ital__',
        'action': '[[click]]',
        'code-off': '``code``',
        'code-on': '``code``',
        'newline': 'a\nb',
        'escape': r'\**not bold\**',
        'nested': '**a __b__ [[c]]**',
        'unmatched': '**abc',
        'triple-tag': '***x***',
        'action-close-only': ']x',
      };
      final bool code = c['name'] == 'code-on';
      final bool action = c['name'] == 'action' || c['name'] == 'nested';
      final DisposableStore store = DisposableStore();
      final IContentActionHandler? handler = action
          ? IContentActionHandler(
              callback: (String content, Object event) {},
              disposables: store,
            )
          : null;
      final DomElement rendered = renderFormattedText(
        input[c['name']] as String,
        FormattedTextRenderOptions(
          actionHandler: handler,
          renderCodeSegments: code,
        ),
      );
      expect(snap(rendered), c['tree'], reason: c['name'] as String);
    }
  });

  test('batch101 action links fire callbacks with action index', () {
    final List<Object?> fired = <Object?>[];
    final DisposableStore store = DisposableStore();
    final DomElement root = renderFormattedText('[[0]][[1]]',
        FormattedTextRenderOptions(
          actionHandler: IContentActionHandler(
            callback: (String content, Object event) => fired.add(<Object?>[
                  content, (event as StandardMouseEvent).browserEvent.type,
                ]),
            disposables: store,
          ),
        ));
    final List<DomElement> links = <DomElement>[];
    collectLinks(root, links);
    expect(links.length, obj(truth['actions'])!['linkCount']);
    for (final DomElement link in links) {
      link.dispatchEvent('click', DomEvent('click'));
    }
    final List<Object?> expectedCallbacks = list(obj(truth['actions'])!['callbacks'])!
        .map((Object? c) => list(c)!.skip(1).toList())
        .toList();
    expect(fired, expectedCallbacks);
    store.dispose();
  });
}
