// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/hover/browser/contentHoverTypes.ts
// Translated 1:1. `IHoverPart`, `HoverAnchor` and `ContentHoverComputerOptions`
// are erased interfaces/types in the source and are carried locally here.
// ---------------------------------------------------------------------------

/// 1:1: `IHoverPart.isValidForHoverAnchor` member.
abstract class IHoverPartForContentHover {
  bool isValidForHoverAnchor(Object anchor);
}

/// 1:1: `ContentHoverComputerOptions` carrier (opaque).
class ContentHoverComputerOptions {
  final Object? value;

  const ContentHoverComputerOptions(this.value);
}

/// 1:1: `export class ContentHoverResult`.
class ContentHoverResult {
  final List<IHoverPartForContentHover> hoverParts;
  final bool isComplete;
  final ContentHoverComputerOptions options;

  ContentHoverResult(this.hoverParts, this.isComplete, this.options);

  ContentHoverResult filter(Object anchor) {
    final List<IHoverPartForContentHover> filteredHoverParts = hoverParts
        .where((IHoverPartForContentHover m) =>
            m.isValidForHoverAnchor(anchor))
        .toList();
    if (filteredHoverParts.length == hoverParts.length) {
      return this;
    }
    return FilteredContentHoverResult(
        this, filteredHoverParts, isComplete, options);
  }
}

/// 1:1: `export class FilteredContentHoverResult extends ContentHoverResult`.
class FilteredContentHoverResult extends ContentHoverResult {
  final ContentHoverResult original;

  FilteredContentHoverResult(
    this.original,
    List<IHoverPartForContentHover> messages,
    bool isComplete,
    ContentHoverComputerOptions options,
  ) : super(messages, isComplete, options);

  @override
  ContentHoverResult filter(Object anchor) => original.filter(anchor);
}
