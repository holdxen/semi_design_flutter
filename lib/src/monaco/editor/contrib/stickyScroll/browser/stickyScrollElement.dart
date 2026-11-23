// 1:1 port of vs/editor/contrib/stickyScroll/browser/stickyScrollElement.ts

import '../../../../base/common/uri.dart' show URI;

/// 1:1: `export class StickyRange`
class StickyRange {
  final int startLineNumber;
  final int endLineNumber;

  StickyRange(this.startLineNumber, this.endLineNumber);
}

/// 1:1: `export class StickyElement`
class StickyElement {
  /// Range of line numbers spanned by the current scope.
  final StickyRange? range;

  /// Must be sorted by start line number.
  final List<StickyElement> children;

  /// Parent sticky outline element.
  final StickyElement? parent;

  StickyElement(this.range, this.children, this.parent);
}

/// 1:1: `export class StickyModel`
class StickyModel {
  final URI uri;
  final int version;
  final StickyElement? element;
  final String? outlineProviderId;

  StickyModel(this.uri, this.version, this.element, this.outlineProviderId);
}
