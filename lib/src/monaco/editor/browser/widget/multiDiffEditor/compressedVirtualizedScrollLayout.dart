// 1:1 port of vs/editor/browser/widget/multiDiffEditor/compressedVirtualizedScrollLayout.ts
import '../../../../base/common/errors.dart' show BugIndicatingError;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;

/// 1:1: `type CompressedVirtualizedItemVisibility = 'before' | 'visible' | 'after'`
class CompressedVirtualizedItemVisibility {
  static const String before = 'before';
  static const String visible = 'visible';
  static const String after = 'after';
}

/// 1:1: `type LayoutRevision = number & { _brand }` (brand has no Dart analogue)
typedef LayoutRevision = int;

class ICompressedVirtualizedItemLayout {
  /// Complete item range in outer scroll coordinates.
  final OffsetRange contentRange;
  /// Item range in the compressed rendered coordinate system.
  final OffsetRange renderedRange;
  /// Height removed from the rendered row and represented by item-local scrolling.
  final int maxScrollOffset;
  /// Item-local scroll coordinates.
  final int scrollOffset;
  final String visibility;

  const ICompressedVirtualizedItemLayout({
    required this.contentRange,
    required this.renderedRange,
    required this.maxScrollOffset,
    required this.scrollOffset,
    required this.visibility,
  });
}

class ICompressedVirtualizedScrollLayout {
  final LayoutRevision revision;
  /// Clamped position in the complete outer scroll coordinates.
  final int scrollTop;
  /// Complete height of the logical item content, excluding transient scroll slack.
  final int logicalScrollHeight;
  /// Complete height of all items and inter-item gaps.
  final int scrollHeight;
  final int leadingScrollSlack;
  final int trailingScrollSlack;
  /// Height occupied by the compressed item rows and inter-item gaps.
  final int renderedHeight;
  final OffsetRange contentViewport;
  final OffsetRange renderedViewport;
  /// Full-content height above the viewport represented by item-local scrolling.
  final int hiddenContentHeightAboveViewport;
  final List<ICompressedVirtualizedItemLayout> items;

  const ICompressedVirtualizedScrollLayout({
    required this.revision,
    required this.scrollTop,
    required this.logicalScrollHeight,
    required this.scrollHeight,
    required this.leadingScrollSlack,
    required this.trailingScrollSlack,
    required this.renderedHeight,
    required this.contentViewport,
    required this.renderedViewport,
    required this.hiddenContentHeightAboveViewport,
    required this.items,
  });
}

class ICompressedVirtualizedScrollLayoutInput {
  final LayoutRevision? revision;
  final int scrollTop;
  final int viewportHeight;
  final int itemGap;
  final List<int> itemHeights;
  final int? leadingScrollSlack;
  final int? trailingScrollSlack;

  const ICompressedVirtualizedScrollLayoutInput({
    this.revision,
    required this.scrollTop,
    required this.viewportHeight,
    required this.itemGap,
    required this.itemHeights,
    this.leadingScrollSlack,
    this.trailingScrollSlack,
  });
}

class ILogicalPosition {
  final LayoutRevision revision;
  final int offset;

  const ILogicalPosition(this.revision, this.offset);
}

class ISizeEdit {
  final OffsetRange oldRange;
  final OffsetRange newRange;

  const ISizeEdit(this.oldRange, this.newRange);
}

class IAnchoredSizeEditBatch {
  final LayoutRevision fromRevision;
  final LayoutRevision toRevision;
  final List<ISizeEdit> edits;
  final ILogicalPosition anchor;

  const IAnchoredSizeEditBatch(this.fromRevision, this.toRevision, this.edits, this.anchor);
}

/// 1:1: `asLayoutRevision(value)`
LayoutRevision asLayoutRevision(int value) => value;

/// Computes the complete and compressed vertical layout of a virtualized list.
ICompressedVirtualizedScrollLayout computeCompressedVirtualizedScrollLayout(
    ICompressedVirtualizedScrollLayoutInput input) {
  assertNonNegative('viewportHeight', input.viewportHeight);
  final int leadingScrollSlack = input.leadingScrollSlack ?? 0;
  final int trailingScrollSlack = input.trailingScrollSlack ?? 0;
  assertNonNegative('leadingScrollSlack', leadingScrollSlack);
  assertNonNegative('trailingScrollSlack', trailingScrollSlack);
  final int logicalScrollHeight =
      computeCompressedVirtualizedScrollHeight(input.itemHeights, input.itemGap);
  final int scrollHeight = leadingScrollSlack + logicalScrollHeight + trailingScrollSlack;
  final int maxScrollTop = scrollHeight - input.viewportHeight > 0
      ? scrollHeight - input.viewportHeight
      : 0;
  final int scrollTop = input.scrollTop < 0
      ? 0
      : (input.scrollTop > maxScrollTop ? maxScrollTop : input.scrollTop);
  final OffsetRange contentViewport =
      OffsetRange.ofStartAndLength(scrollTop - leadingScrollSlack, input.viewportHeight);

  int contentTop = 0;
  int renderedTop = leadingScrollSlack;
  int hiddenContentHeightAboveViewport = 0;
  final List<ICompressedVirtualizedItemLayout> items = <ICompressedVirtualizedItemLayout>[];

  for (int index = 0; index < input.itemHeights.length; index++) {
    final int fullHeight = input.itemHeights[index];
    final int renderedHeight = fullHeight < input.viewportHeight ? fullHeight : input.viewportHeight;
    final int maxScrollOffset = fullHeight - renderedHeight;
    final OffsetRange contentRange = OffsetRange.ofStartAndLength(contentTop, fullHeight);
    final OffsetRange renderedRange = OffsetRange.ofStartAndLength(renderedTop, renderedHeight);

    late String visibility;
    late int scrollOffset;
    if (contentRange.isBefore(contentViewport)) {
      visibility = CompressedVirtualizedItemVisibility.before;
      scrollOffset = maxScrollOffset;
    } else if (contentRange.isAfter(contentViewport)) {
      visibility = CompressedVirtualizedItemVisibility.after;
      scrollOffset = 0;
    } else {
      visibility = CompressedVirtualizedItemVisibility.visible;
      final int startDelta = contentViewport.start - contentRange.start;
      scrollOffset = startDelta < 0
          ? 0
          : (startDelta > maxScrollOffset ? maxScrollOffset : startDelta);
    }

    hiddenContentHeightAboveViewport += scrollOffset;
    items.add(ICompressedVirtualizedItemLayout(
      contentRange: contentRange,
      renderedRange: renderedRange,
      maxScrollOffset: maxScrollOffset,
      scrollOffset: scrollOffset,
      visibility: visibility,
    ));

    if (index < input.itemHeights.length - 1) {
      contentTop += fullHeight + input.itemGap;
      renderedTop += renderedHeight + input.itemGap;
    } else {
      contentTop += fullHeight;
      renderedTop += renderedHeight;
    }
  }

  final int renderedScrollTop = scrollTop - hiddenContentHeightAboveViewport;
  return ICompressedVirtualizedScrollLayout(
    revision: input.revision ?? asLayoutRevision(0),
    scrollTop: scrollTop,
    logicalScrollHeight: logicalScrollHeight,
    scrollHeight: scrollHeight,
    leadingScrollSlack: leadingScrollSlack,
    trailingScrollSlack: trailingScrollSlack,
    renderedHeight: renderedTop + trailingScrollSlack,
    contentViewport: contentViewport,
    renderedViewport:
        OffsetRange.ofStartAndLength(renderedScrollTop, input.viewportHeight),
    hiddenContentHeightAboveViewport: hiddenContentHeightAboveViewport,
    items: items,
  );
}

List<OffsetRange> computeItemRanges(List<int> itemHeights, int itemGap) {
  assertNonNegative('itemGap', itemGap);
  final List<OffsetRange> ranges = <OffsetRange>[];
  int offset = 0;
  for (int index = 0; index < itemHeights.length; index++) {
    final int height = itemHeights[index];
    assertNonNegative('itemHeights[$index]', height);
    ranges.add(OffsetRange.ofStartAndLength(offset, height));
    offset += height + (index < itemHeights.length - 1 ? itemGap : 0);
  }
  return ranges;
}

IAnchoredSizeEditBatch createAnchoredSizeEditBatch(
  LayoutRevision fromRevision,
  LayoutRevision toRevision,
  List<int> oldItemHeights,
  List<int> newItemHeights,
  int oldItemGap,
  int newItemGap,
  int anchorOffset,
) {
  if (oldItemHeights.length != newItemHeights.length) {
    throw BugIndicatingError('Size edits require stable item identity and ordering');
  }
  final List<OffsetRange> oldRanges = computeItemRanges(oldItemHeights, oldItemGap);
  final List<OffsetRange> newRanges = computeItemRanges(newItemHeights, newItemGap);
  final List<ISizeEdit> edits = <ISizeEdit>[];
  for (int index = 0; index < oldRanges.length; index++) {
    if (!oldRanges[index].equals(newRanges[index])) {
      edits.add(ISizeEdit(oldRanges[index], newRanges[index]));
    }
  }
  return IAnchoredSizeEditBatch(
      fromRevision, toRevision, edits, ILogicalPosition(fromRevision, anchorOffset));
}

/// 1:1: `type RemovedPositionAffinity = 'itemStart' | 'itemEnd'`
class RemovedPositionAffinity {
  static const String itemStart = 'itemStart';
  static const String itemEnd = 'itemEnd';
}

ILogicalPosition mapLogicalPosition(ILogicalPosition position,
    IAnchoredSizeEditBatch edit,
    [String removedPositionAffinity = RemovedPositionAffinity.itemStart]) {
  if (position.revision != edit.fromRevision) {
    throw BugIndicatingError(
        'Cannot map layout revision ${position.revision} through revision ${edit.fromRevision}');
  }
  int mappedOffset = position.offset;
  for (final ISizeEdit sizeEdit in edit.edits) {
    if (position.offset < sizeEdit.oldRange.start) {
      break;
    }
    if (sizeEdit.oldRange.contains(position.offset)) {
      final int relativeOffset = position.offset - sizeEdit.oldRange.start;
      mappedOffset = relativeOffset < sizeEdit.newRange.length
          ? sizeEdit.newRange.start + relativeOffset
          : (removedPositionAffinity == RemovedPositionAffinity.itemEnd
              ? sizeEdit.newRange.endExclusive
              : sizeEdit.newRange.start);
      return ILogicalPosition(edit.toRevision, mappedOffset);
    }
    mappedOffset = position.offset + sizeEdit.newRange.endExclusive - sizeEdit.oldRange.endExclusive;
  }
  return ILogicalPosition(edit.toRevision, mappedOffset);
}

int computeCompressedVirtualizedScrollHeight(List<int> itemHeights, int itemGap) {
  assertNonNegative('itemGap', itemGap);
  for (int i = 0; i < itemHeights.length; i++) {
    assertNonNegative('itemHeights[$i]', itemHeights[i]);
  }
  if (itemHeights.isEmpty) {
    return 0;
  }
  return itemHeights.fold<int>(0, (result, height) => result + height) +
      itemGap * (itemHeights.length - 1);
}

void assertNonNegative(String name, num value) {
  if (!value.isFinite || value < 0) {
    throw BugIndicatingError('$name must be a finite non-negative number, got $value');
  }
}
