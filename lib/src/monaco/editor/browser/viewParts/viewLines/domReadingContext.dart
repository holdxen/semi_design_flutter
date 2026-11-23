// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/viewLines/domReadingContext.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// Opaque carrier for the `HTMLElement` used for DOM geometry reads.
///
/// The source calls `getBoundingClientRect()` and reads `offsetWidth`; these
/// are surfaced as injectable members so the lazy-read control flow can be
/// exercised without a real DOM.
class DomReadElement {
  DomReadElement({
    required this.rectProvider,
    required this.offsetWidth,
  });

  /// 1:1: `getBoundingClientRect(): { left, width }`
  final Map<String, num> Function() rectProvider;

  final num offsetWidth;

  Map<String, num> getBoundingClientRect() => rectProvider();
}

/// 1:1: `export class DomReadingContext`
class DomReadingContext {
  bool _didDomLayout = false;
  num _clientRectDeltaLeft = 0;
  num _clientRectScale = 1;
  bool _clientRectRead = false;

  final DomReadElement _domNode;

  /// 1:1: `public readonly endNode: HTMLElement`
  final Object endNode;

  DomReadingContext(this._domNode, this.endNode);

  bool get didDomLayout => _didDomLayout;

  void _readClientRect() {
    if (!_clientRectRead) {
      _clientRectRead = true;
      final Map<String, num> rect = _domNode.getBoundingClientRect();
      markDidDomLayout();
      _clientRectDeltaLeft = rect['left'] ?? 0;
      final num offsetWidth = _domNode.offsetWidth;
      _clientRectScale = offsetWidth > 0 ? (rect['width'] ?? 0) / offsetWidth : 1;
    }
  }

  num get clientRectDeltaLeft {
    if (!_clientRectRead) {
      _readClientRect();
    }
    return _clientRectDeltaLeft;
  }

  num get clientRectScale {
    if (!_clientRectRead) {
      _readClientRect();
    }
    return _clientRectScale;
  }

  void markDidDomLayout() {
    _didDomLayout = true;
  }
}
