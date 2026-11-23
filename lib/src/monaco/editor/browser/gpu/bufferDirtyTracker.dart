// 1:1 port of vs/editor/browser/gpu/bufferDirtyTracker.ts

/// 1:1: `interface IBufferDirtyTrackerReader`
abstract class IBufferDirtyTrackerReader {
  /// The index of the first dirty index.
  int? get dataOffset;

  /// The index of the last dirty index (inclusive).
  int? get dirtySize;

  /// Whether the buffer is dirty.
  bool get isDirty;

  /// Clear the dirty state.
  void clear();
}

/// A simple tracker for dirty regions in a buffer.
class BufferDirtyTracker implements IBufferDirtyTrackerReader {
  int? _startIndex;
  int? _endIndex;

  @override
  int? get dataOffset => _startIndex;

  @override
  int? get dirtySize {
    if (_startIndex == null || _endIndex == null) {
      return null;
    }
    return _endIndex! - _startIndex! + 1;
  }

  @override
  bool get isDirty => _startIndex != null;

  /// Flag the index(es) as modified. Returns the index flagged.
  int flag(int index, [int length = 1]) {
    _flag(index);
    if (length > 1) {
      _flag(index + length - 1);
    }
    return index;
  }

  void _flag(int index) {
    if (_startIndex == null || index < _startIndex!) {
      _startIndex = index;
    }
    if (_endIndex == null || index > _endIndex!) {
      _endIndex = index;
    }
  }

  @override
  void clear() {
    _startIndex = null;
    _endIndex = null;
  }
}
