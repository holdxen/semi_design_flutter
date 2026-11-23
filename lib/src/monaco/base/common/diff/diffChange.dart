// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/diff/diffChange.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

/// Represents information about a specific difference between two sequences.
class DiffChange {
  /// The position of the first element in the original sequence which
  /// this change affects.
  int originalStart;

  /// The number of elements from the original sequence which were
  /// affected.
  int originalLength;

  /// The position of the first element in the modified sequence which
  /// this change affects.
  int modifiedStart;

  /// The number of elements from the modified sequence which were
  /// affected (added).
  int modifiedLength;

  /// Constructs a new DiffChange with the given sequence information
  /// and content.
  DiffChange(this.originalStart, this.originalLength, this.modifiedStart, this.modifiedLength) {
    // Debug.Assert(originalLength > 0 || modifiedLength > 0, "originalLength and modifiedLength cannot both be <= 0");
  }

  /// The end point (exclusive) of the change in the original sequence.
  int getOriginalEnd() {
    return originalStart + originalLength;
  }

  /// The end point (exclusive) of the change in the modified sequence.
  int getModifiedEnd() {
    return modifiedStart + modifiedLength;
  }
}
