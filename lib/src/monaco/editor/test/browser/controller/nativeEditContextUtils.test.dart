// 1:1 port of
// vscode/src/vs/editor/test/browser/controller/nativeEditContextUtils.test.ts
//
// The TS `suite`/`test` callbacks are represented as callable Dart functions
// so the scenario can be asserted against the real TypeScript runtime truth.

import '../../../../base/browser/dom.dart' as dom;
import '../../../../base/common/lifecycle.dart' as lifecycle;
import '../../../../platform/log/common/log.dart' as log;
import '../../../browser/controller/editContext/native/nativeEditContextUtils.dart'
    as native;

/// 1:1: `suite('NativeEditContextUtils', ...)`
const String suiteName = 'NativeEditContextUtils';

/// 1:1: `test('tracks focus in the DOM node owner document', ...)`
const String testName = 'tracks focus in the DOM node owner document';

/// Carrier for the `assert.deepStrictEqual` payload of the test.
class FocusAssertion {
  FocusAssertion({
    required this.activeElement,
    required this.focused,
    required this.trackerFocused,
  });

  final bool activeElement;
  final bool focused;
  final bool trackerFocused;

  Map<String, Object?> toJson() => <String, Object?>{
        'activeElement': activeElement,
        'focused': focused,
        'trackerFocused': trackerFocused,
      };
}

/// Carrier for one executed test result.
class NativeEditContextUtilsTestResult {
  NativeEditContextUtilsTestResult({
    required this.actual,
    required this.expected,
    required this.equal,
    required this.focusCalls,
  });

  final FocusAssertion actual;
  final FocusAssertion expected;
  final bool equal;
  final int focusCalls;

  Map<String, Object?> toJson() => <String, Object?>{
        'actual': actual.toJson(),
        'expected': expected.toJson(),
        'equal': equal,
      };
}

/// Carrier for the test-suite's disposable collection.
final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();

/// 1:1: suite body — `tracks focus in the DOM node owner document`.
NativeEditContextUtilsTestResult
    tracksFocusInTheDomNodeOwnerDocument() {
  // `document.createElement('iframe')` / `registerTestIframe(iframe)` are
  // browser-only setup; in the Dart carrier the iframe content document is a
  // `DomDocument` owned by the suite's disposable store.
  final lifecycle.IDisposable iframeRegistration = lifecycle.Disposable.none;
  disposables.add(iframeRegistration);

  final dom.DomDocument contentDocument = dom.DomDocument();
  final _CountingElement target = _CountingElement('div')..tabIndex = 0;
  contentDocument.body.appendChild(target);

  bool focused = false;
  final native.FocusTracker tracker = disposables.add(native.FocusTracker(
    log.NullLogService(),
    target,
    (bool value) => focused = value,
  ));
  final int focusCallsBefore = _focusCalls(target);
  tracker.focus();
  final int focusCalls = _focusCalls(target) - focusCallsBefore;

  final FocusAssertion actual = FocusAssertion(
    activeElement: identical(contentDocument.activeElement, target),
    focused: focused,
    trackerFocused: tracker.isFocused,
  );
  final FocusAssertion expected = FocusAssertion(
    activeElement: true,
    focused: true,
    trackerFocused: true,
  );
  return NativeEditContextUtilsTestResult(
    actual: actual,
    expected: expected,
    equal: actual.toJson().toString() == expected.toJson().toString(),
    focusCalls: focusCalls,
  );
}

int _focusCalls(dom.DomElement target) =>
    target is _CountingElement ? target.focusCalls : 0;

class _CountingElement extends dom.DomElement {
  _CountingElement(super.tagName);

  int focusCalls = 0;

  @override
  void focus() {
    focusCalls++;
    super.focus();
  }
}

/// Run the suite body and return its truth-shaped payload.
Map<String, Object?> runSuite() {
  final NativeEditContextUtilsTestResult result =
      tracksFocusInTheDomNodeOwnerDocument();
  return <String, Object?>{
    'suiteName': suiteName,
    'testName': testName,
    'results': <Object?>[result.toJson()],
    'focusCalls': result.focusCalls,
  };
}
