// Data-driven port test for batch100: base/test/browser/testWindow.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart';
import 'package:semi_design_flutter/src/monaco/base/test/browser/testWindow.dart';

const String truthJson = r"""
{
  "exports": [
    "registerTestIframe",
    "whenTestIframeLaidOut"
  ],
  "registration": {
    "ids": [
      100000,
      100001
    ]
  },
  "detachedErrors": [
    "Attach the iframe to a document before registering its window.",
    "Attach the iframe to a document before waiting for its layout."
  ],
  "layoutBeforeFrame": {
    "rectCalls": 1,
    "queued": 1
  },
  "layout": {
    "rectCalls": 1,
    "expected": [
      320,
      240
    ]
  },
  "mismatchError": "The iframe's viewport is 999x0 after a rendered frame, expected 320x240."
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
List<Object?> list(Object? v) => (v as List).cast<Object?>();
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();

CodeWindow owner(String tag) => CodeWindow(tag);

void main() {
  setUp(() {
    nextTestWindowId = 100000;
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
  });

  test('batch100 exports', () {
    expect(truth['exports'], <Object?>['registerTestIframe', 'whenTestIframeLaidOut']);
  });

  test('batch100 registers iframes with increasing ids', () {
    final CodeWindow w1 = CodeWindow(Object());
    final CodeWindow w2 = CodeWindow(Object());
    final TestIframe i1 = TestIframe(contentWindow: w1, ownerWindow: owner('o1'));
    final TestIframe i2 = TestIframe(contentWindow: w2, ownerWindow: owner('o2'));
    final IDisposable d1 = registerTestIframe(i1);
    final IDisposable d2 = registerTestIframe(i2);
    expect(<Object?>[w1.vscodeWindowId, w2.vscodeWindowId], list(obj(truth['registration'])!['ids']));
    d1.dispose();
    d2.dispose();
  });

  test('batch100 detached iframes throw', () {
    final TestIframe detached = TestIframe(ownerWindow: owner('o3'));
    expect(() => registerTestIframe(detached),
        throwsA(isA<StateError>().having((StateError e) => e.message, 'message',
            list(truth['detachedErrors'])!.first)));
    expect(() => whenTestIframeLaidOut(detached), throwsA(isA<StateError>()));
  });

  test('batch100 waits for an owner animation frame', () async {
    final CodeWindow target = CodeWindow(Object());
    final CodeWindow ownerWindow = owner('o4');
    windowCarrier(target).innerWidth = 320;
    windowCarrier(target).innerHeight = 240;
    final TestIframe iframe = TestIframe(
      contentWindow: target,
      ownerWindow: ownerWindow,
      clientWidth: 320,
      clientHeight: 240,
    );
    final Future<void> pending = whenTestIframeLaidOut(iframe);
    expect(obj(truth['layoutBeforeFrame'])!['rectCalls'], iframe.rectCalls);
    windowCarrier(ownerWindow).flushAnimationFrame();
    await pending;
    expect(obj(truth['layout'])!['rectCalls'], iframe.rectCalls);
    expect(obj(truth['layout'])!['expected'], <Object?>[320, 240]);
  });

  test('batch100 viewport mismatch throws exact message', () async {
    final CodeWindow target = CodeWindow(Object());
    final CodeWindow ownerWindow = owner('o5');
    windowCarrier(target).innerWidth = 999;
    windowCarrier(target).innerHeight = 0;
    final TestIframe iframe = TestIframe(
      contentWindow: target,
      ownerWindow: ownerWindow,
      clientWidth: 320,
      clientHeight: 240,
    );
    final Future<void> pending = whenTestIframeLaidOut(iframe);
    windowCarrier(ownerWindow).flushAnimationFrame();
    expect(pending,
        throwsA(isA<StateError>().having((StateError e) => e.message, 'message',
            truth['mismatchError'])));
    await pending.catchError((Object _) {});
  });
}
