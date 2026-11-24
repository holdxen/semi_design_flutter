// 1:1 port of vscode/src/vs/editor/browser/config/charWidthReader.ts
//
// Carriers: `applyFontInfo` (batch208) and `BareFontInfo` are used as-is; the
// DOM is the `base/browser/dom.dart` carrier (`mainDocument`, `DomElement`).
//
// Adaptations (documented inline):
//  * TS `const enum CharWidthRequestType` -> a class of `static const int`s.
//  * `targetWindow: Window` -> `DomWindowCarrier` (the port's window carrier).
//  * `testElement.innerText` -> `textContent` (the value is 256 repeated NBSP,
//    which whitespace collapsing does not affect).
//  * `offsetWidth` needs a real layout engine. The carrier has no layout, so
//    the probe is injectable (`offsetWidthOverride`, `null` reads the carrier
//    field) — same test-seam convention as `platform.dart` /
//    `inlineCompletionsService.dart`.
import '../../../base/browser/dom.dart' as dom;
import '../config/domFontInfo.dart' show applyFontInfo;
import '../../common/config/fontInfo.dart' show BareFontInfo;

/// 1:1: `export const enum CharWidthRequestType`.
class CharWidthRequestType {
  static const int Regular = 0;
  static const int Italic = 1;
  static const int Bold = 2;

  const CharWidthRequestType._();
}

/// TS reads `element.offsetWidth` from the browser layout engine; the Dart DOM
/// carrier has no layout, so the probe is a test/runtime seam.
num Function(dom.DomElement element)? _offsetWidthOverride;

set offsetWidthOverride(num Function(dom.DomElement element)? value) {
  _offsetWidthOverride = value;
}

num _offsetWidthOf(dom.DomElement element) =>
    (_offsetWidthOverride ?? (dom.DomElement e) => e.offsetWidth)(element);

/// 1:1: `export class CharWidthRequest`.
class CharWidthRequest {
  CharWidthRequest(this.chr, this.type);

  final String chr;
  final int type;
  num width = 0;

  void fulfill(num width) {
    this.width = width;
  }
}

/// 1:1: `class DomCharWidthReader`.
class DomCharWidthReader {
  DomCharWidthReader(this._bareFontInfo, this._requests);

  final BareFontInfo _bareFontInfo;
  final List<CharWidthRequest> _requests;

  dom.DomElement? _container;
  List<dom.DomElement>? _testElements;

  void read(dom.DomWindowCarrier targetWindow) {
    // Create a test container with all these test elements
    _createDomElements();

    // Add the container to the DOM
    targetWindow.document.body.appendChild(_container!);

    // Read character widths
    _readFromDomElements();

    // Remove the container from the DOM
    _container?.remove();

    _container = null;
    _testElements = null;
  }

  void _createDomElements() {
    final dom.DomElement container = dom.mainDocument.createElement('div');
    container.style['position'] = 'absolute';
    container.style['top'] = '-50000px';
    container.style['width'] = '50000px';

    final dom.DomElement regularDomNode = dom.mainDocument.createElement('div');
    applyFontInfo(regularDomNode, _bareFontInfo);
    container.appendChild(regularDomNode);

    final dom.DomElement boldDomNode = dom.mainDocument.createElement('div');
    applyFontInfo(boldDomNode, _bareFontInfo);
    boldDomNode.style['fontWeight'] = 'bold';
    container.appendChild(boldDomNode);

    final dom.DomElement italicDomNode = dom.mainDocument.createElement('div');
    applyFontInfo(italicDomNode, _bareFontInfo);
    italicDomNode.style['fontStyle'] = 'italic';
    container.appendChild(italicDomNode);

    final List<dom.DomElement> testElements = <dom.DomElement>[];
    for (final CharWidthRequest request in _requests) {
      final dom.DomElement parent;
      if (request.type == CharWidthRequestType.Regular) {
        parent = regularDomNode;
      } else if (request.type == CharWidthRequestType.Bold) {
        parent = boldDomNode;
      } else {
        // `Italic`, matching the TS if-chain's final branch.
        parent = italicDomNode;
      }

      parent.appendChild(dom.mainDocument.createElement('br'));

      final dom.DomElement testElement = dom.mainDocument.createElement('span');
      DomCharWidthReader._render(testElement, request);
      parent.appendChild(testElement);

      testElements.add(testElement);
    }

    _container = container;
    _testElements = testElements;
  }

  static void _render(dom.DomElement testElement, CharWidthRequest request) {
    if (request.chr == ' ') {
      String htmlString = '\u00a0';
      // Repeat character 256 (2^8) times
      for (int i = 0; i < 8; i++) {
        htmlString += htmlString;
      }
      // TS assigns `innerText`; repeated NBSP is unaffected by whitespace
      // collapsing, so the carrier's `textContent` is equivalent.
      testElement.textContent = htmlString;
    } else {
      String testString = request.chr;
      // Repeat character 256 (2^8) times
      for (int i = 0; i < 8; i++) {
        testString += testString;
      }
      testElement.textContent = testString;
    }
  }

  void _readFromDomElements() {
    for (int i = 0, len = _requests.length; i < len; i++) {
      final CharWidthRequest request = _requests[i];
      final dom.DomElement testElement = _testElements![i];

      request.fulfill(_offsetWidthOf(testElement) / 256);
    }
  }
}

/// 1:1: `export function readCharWidths(targetWindow, bareFontInfo, requests)`.
void readCharWidths(
  dom.DomWindowCarrier targetWindow,
  BareFontInfo bareFontInfo,
  List<CharWidthRequest> requests,
) {
  final DomCharWidthReader reader =
      DomCharWidthReader(bareFontInfo, requests);
  reader.read(targetWindow);
}
