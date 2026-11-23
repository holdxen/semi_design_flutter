// 1:1 port of vs/base/test/browser/testWindow.ts
import 'dart:async' show Completer;

import '../../browser/dom.dart'
    show DomRect, registerWindow, windowCarrier;
import '../../browser/window.dart' show CodeWindow, ensureCodeWindow;
import '../../common/lifecycle.dart' show IDisposable;

int nextTestWindowId = 100000;

/// DOM `HTMLIFrameElement` carrier for the test helpers below.
class TestIframe {
  final CodeWindow? contentWindow;
  final CodeWindow? ownerWindow;
  final int clientWidth;
  final int clientHeight;
  int rectCalls = 0;

  TestIframe({
    this.contentWindow,
    this.ownerWindow,
    this.clientWidth = 0,
    this.clientHeight = 0,
  });

  DomRect getBoundingClientRect() {
    rectCalls++;
    return DomRect(width: clientWidth.toDouble(), height: clientHeight.toDouble());
  }
}

/// Gives the window of an iframe that a test created and attached its own window ID, and registers it, as the
/// auxiliary window service does for real windows. State that is kept per window ID, such as the animation frame
/// queue, is otherwise shared by every such iframe, so one test's iframe can affect another test's.
/// Dispose the returned registration when the iframe is removed.
IDisposable registerTestIframe(TestIframe iframe) {
  final CodeWindow? targetWindow = iframe.contentWindow;
  if (targetWindow == null) {
    throw StateError(
        'Attach the iframe to a document before registering its window.');
  }
  ensureCodeWindow(targetWindow, nextTestWindowId++);
  return registerWindow(targetWindow);
}

/// Resolves once the iframe's window has the viewport of the iframe's box. WebKit can report a freshly attached
/// iframe's viewport as 0x0 until its document is laid out and a frame is rendered, so tests that measure or hit
/// test inside the iframe must wait for this first.
Future<void> whenTestIframeLaidOut(TestIframe iframe) async {
  final CodeWindow? targetWindow = iframe.contentWindow;
  final CodeWindow? ownerWindow = iframe.ownerWindow;
  if (targetWindow == null || ownerWindow == null) {
    throw StateError(
        'Attach the iframe to a document before waiting for its layout.');
  }
  iframe.getBoundingClientRect();
  final Completer<void> frame = Completer<void>();
  windowCarrier(ownerWindow).requestAnimationFrame(() => frame.complete());
  await frame.future;
  final List<int> expected = <int>[iframe.clientWidth, iframe.clientHeight];
  final List<int> actual = <int>[
    windowCarrier(targetWindow).innerWidth,
    windowCarrier(targetWindow).innerHeight,
  ];
  if (actual[0] != expected[0] || actual[1] != expected[1]) {
    throw StateError(
        "The iframe's viewport is ${actual.join('x')} after a rendered frame, expected ${expected.join('x')}.");
  }
}
