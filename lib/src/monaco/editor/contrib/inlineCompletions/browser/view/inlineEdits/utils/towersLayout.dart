// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/view/inlineEdits/utils/towersLayout.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

import '../../../../../../common/core/2d/size.dart';
import '../../../../../../common/core/ranges/offsetRange.dart';

/// The tower areas are arranged from left to right, touch and are aligned at the bottom.
/// How high can a tower be placed at the requested horizontal range, so that its size fits into the union of the stacked availableTowerAreas?
/// 1:1: `number` return (a JS number; callers use integer heights).
num getMaxTowerHeightInAvailableArea(OffsetRange towerHorizontalRange, List<Size2D> availableTowerAreas) {
  final num towerLeftOffset = towerHorizontalRange.start;
  final num towerRightOffset = towerHorizontalRange.endExclusive;

  num minHeight = double.maxFinite;

  // Calculate the accumulated width to find which tower areas the requested tower overlaps
  num currentLeftOffset = 0;
  for (final Size2D availableArea in availableTowerAreas) {
    final num currentRightOffset = currentLeftOffset + availableArea.width;

    // Check if the requested tower overlaps with this available area
    final num overlapLeft = towerLeftOffset > currentLeftOffset ? towerLeftOffset : currentLeftOffset;
    final num overlapRight = towerRightOffset < currentRightOffset ? towerRightOffset : currentRightOffset;

    if (overlapLeft < overlapRight) {
      // There is an overlap - track the minimum height
      minHeight = minHeight < availableArea.height ? minHeight : availableArea.height;
    }

    currentLeftOffset = currentRightOffset;
  }

  if (towerRightOffset > currentLeftOffset) {
    return 0;
  }

  // If no overlap was found, return 0
  return minHeight == double.maxFinite ? 0 : minHeight;
}
