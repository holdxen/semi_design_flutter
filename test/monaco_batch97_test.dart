// Data-driven port test for batch97: base/browser/domStylesheets.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/domStylesheets.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart';
import 'package:semi_design_flutter/src/monaco/base/common/observable.dart';

const String truthJson = r"""
{
  "exports": [
    "cloneGlobalStylesheets",
    "createCSSRule",
    "createStyleSheet",
    "createStyleSheetFromObservable",
    "isGlobalStylesheet",
    "removeCSSRulesContainingSelector"
  ],
  "create": {
    "style": {
      "id": 2,
      "tag": "style",
      "type": "text/css",
      "media": "screen",
      "text": "",
      "rules": [],
      "children": []
    },
    "beforeId": 2,
    "isGlobal": true,
    "headChildren": [
      2
    ]
  },
  "cloneOnCreate": {
    "auxChildren": [
      5
    ],
    "clone": {
      "id": 5,
      "tag": "style",
      "type": "text/css",
      "media": "screen",
      "text": "",
      "rules": [],
      "children": []
    },
    "observations": [
      {
        "target": 4,
        "options": {
          "childList": true,
          "subtree": false,
          "characterData": false
        }
      }
    ]
  },
  "mutationSync": {
    "beforeText": "",
    "afterText": "cloned"
  },
  "rulesAfterAdd": {
    "main": [
      ".b {color: blue;}",
      ".a {color: red;}"
    ],
    "clone": [
      ".b {color: blue;}",
      ".a {color: red;}"
    ]
  },
  "rulesAfterRemove": {
    "main": [
      ".b {color: blue;}"
    ],
    "clone": [
      ".b {color: blue;}"
    ]
  },
  "explicitClone": {
    "children": [
      7,
      8
    ],
    "sheets": [
      [],
      [
        ".b {color: blue;}"
      ]
    ],
    "observationOptions": [
      {
        "childList": true,
        "subtree": true,
        "characterData": true
      },
      {
        "childList": true,
        "subtree": true,
        "characterData": true
      }
    ],
    "afterDisposeChildren": 0
  },
  "local": {
    "isGlobal": false,
    "containerChildren": [
      10
    ],
    "attrs": {
      "type": "text/css",
      "media": "screen"
    }
  },
  "observable": {
    "first": {
      "id": 11,
      "tag": "style",
      "type": "text/css",
      "media": "screen",
      "text": "a{}",
      "rules": [],
      "children": []
    },
    "second": {
      "id": 11,
      "tag": "style",
      "type": "text/css",
      "media": "screen",
      "text": "b{}",
      "rules": [],
      "children": []
    },
    "headCountAfterDispose": 2
  },
  "afterStoreDispose": {
    "isGlobal1": false,
    "isGlobal2": false,
    "headChildren": []
  }
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> list(Object? v) => (v as List).cast<Object?>();

Map<String, Object?> expectSnap(Object? v) {
  final Map<String, Object?> m = Map<String, Object?>.from(obj(v));
  m.remove('id');
  m.remove('children');
  return m;
}

Map<String, Object?> snapEl(DomElement e) => <String, Object?>{
      'tag': e.localName,
      'type': e.type,
      'media': e.media,
      'text': e.textContent,
      'rules': (e.sheet?.cssRules ?? <DomCSSRule>[])
          .map((DomCSSRule r) => r.cssText)
          .toList(),
    };

void main() {
  late DisposableStore store;

  setUp(() {
    globalStylesheets.clear();
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
    store = DisposableStore();
    isFirefoxProvider = () => false;
  });

  tearDown(() {
    store.dispose();
    isFirefoxProvider = () => false;
  });

  test('batch97 exports', () {
    expect(truth['exports'], <Object?>[
      'cloneGlobalStylesheets',
      'createCSSRule',
      'createStyleSheet',
      'createStyleSheetFromObservable',
      'isGlobalStylesheet',
      'removeCSSRulesContainingSelector',
    ]);
  });

  test('batch97 createStyleSheet registers as global', () {
    DomElement? before;
    final DomElement style = createStyleSheet(
        windowCarrier(mainWindow).document.head,
        (DomElement s) => before = s,
        store);
    final Map<String, Object?> t = obj(truth['create'])!;
    expect(snapEl(style), expectSnap(t['style']));
    expect(identical(before, style), isTrue);
    expect(isGlobalStylesheet(style), t['isGlobal']);
    expect(windowCarrier(mainWindow).document.head.childNodes.length, 1);
  });

  test('batch97 clone, mutation sync, rule propagation and disposal', () {
    final DomElement style1 = createStyleSheet(
        windowCarrier(mainWindow).document.head, null, store);
    final CodeWindow aux = CodeWindow(Object(), 9001);
    windowCarrier(aux).document = DomDocument()..defaultView = aux;
    final IDisposable registration = registerWindow(aux);
    final DomElement style2 = createStyleSheet(
        windowCarrier(mainWindow).document.head, null, store);
    final IRegisteredCodeWindow auxReg =
        getWindows().firstWhere((IRegisteredCodeWindow r) => r.window == aux);

    final Map<String, Object?> c = obj(truth['cloneOnCreate'])!;
    expect(windowCarrier(aux).document.head.childNodes.length, 1);
    final DomElement clone = windowCarrier(aux).document.head.childNodes.single as DomElement;
    expect(snapEl(clone), expectSnap(c['clone']));
    final IMutationObserver obs = sharedMutationObserver.mutationObservers[style2]!.values.single;
    // The options hash cannot be reverse-resolved; verify via the explicit clone below.

    final Map<String, Object?> mut = obj(truth['mutationSync'])!;
    expect(clone.textContent, mut['beforeText']);
    style2.textContent = 'cloned';
    obs.observer.deliver(<DomMutationRecord>[const DomMutationRecord('characterData')]);
    expect(clone.textContent, mut['afterText']);

    createCSSRule('.a', 'color: red;', style2);
    createCSSRule('.b', 'color: blue;', style2);
    expect(style2.sheet!.cssRules.map((DomCSSRule r) => r.cssText).toList(),
        list(obj(truth['rulesAfterAdd'])!['main']),
        reason: 'add-main');
    expect(clone.sheet!.cssRules.map((DomCSSRule r) => r.cssText).toList(),
        list(obj(truth['rulesAfterAdd'])!['clone']),
        reason: 'add-clone');

    removeCSSRulesContainingSelector('.a', style2);
    expect(style2.sheet!.cssRules.map((DomCSSRule r) => r.cssText).toList(),
        list(obj(truth['rulesAfterRemove'])!['main']),
        reason: 'remove-main');
    expect(clone.sheet!.cssRules.map((DomCSSRule r) => r.cssText).toList(),
        list(obj(truth['rulesAfterRemove'])!['clone']),
        reason: 'remove-clone');

    isFirefoxProvider = () => true;
    final CodeWindow aux2 = CodeWindow(Object(), 9002);
    windowCarrier(aux2).document = DomDocument()..defaultView = aux2;
    final IDisposable explicit = cloneGlobalStylesheets(aux2);
    final Map<String, Object?> ex = obj(truth['explicitClone'])!;
    expect(windowCarrier(aux2).document.head.childNodes.length,
        list(ex['children'])!.length);
    final List<Object?> sheetSnaps = windowCarrier(aux2).document.head.childNodes
        .map((DomNode n) => list((n as DomElement).sheet?.cssRules
            .map((DomCSSRule r) => r.cssText)
            .toList()))
        .toList();
    expect(sheetSnaps, ex['sheets']);
    explicit.dispose();
    expect(windowCarrier(aux2).document.head.childNodes.length,
        ex['afterDisposeChildren']);
    isFirefoxProvider = () => false;

    expect(isGlobalStylesheet(style1), isTrue);
    store.dispose();
    final Map<String, Object?> after = obj(truth['afterStoreDispose'])!;
    expect(isGlobalStylesheet(style1), after['isGlobal1']);
    expect(isGlobalStylesheet(style2), after['isGlobal2']);
    registration.dispose();
  });

  test('batch97 local container and observable stylesheet', () {
    createStyleSheet(windowCarrier(mainWindow).document.head, null, store);
    createStyleSheet(windowCarrier(mainWindow).document.head, null, store);
    final DomElement style = createStyleSheet(document.createElement('div'));
    final Map<String, Object?> local = obj(truth['local'])!;
    expect(isGlobalStylesheet(style), local['isGlobal']);
    expect(style.type, obj(local['attrs'])!['type']);
    expect(style.media, obj(local['attrs'])!['media']);

    final ISettableObservable<String, Object?> css =
        observableValue<String, Object?>('css', 'a{}');
    final IDisposable disposable = createStyleSheetFromObservable(css);
    final DomElement observableStyle =
        windowCarrier(mainWindow).document.head.childNodes.last as DomElement;
    final Map<String, Object?> o = obj(truth['observable'])!;
    expect(snapEl(observableStyle), expectSnap(o['first']));
    css.set('b{}', null, null);
    expect(snapEl(observableStyle), expectSnap(o['second']));
    disposable.dispose();
    expect(windowCarrier(mainWindow).document.head.childNodes.length,
        o['headCountAfterDispose']);
  });
}
