// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewModel/glyphLanesModel.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../core/range.dart';
import '../model.dart' show GlyphMarginLane;

/// 1:1: `const MAX_LANE = GlyphMarginLane.Right;`
const int _maxLane = GlyphMarginLane.Right;

/// 1:1: `export class GlyphMarginLanesModel implements IGlyphMarginLanesModel`
class GlyphMarginLanesModel {
  late Uint8List _lanes;
  int _persist = 0;
  int _requiredLanes = 1; // always render at least one lane

  GlyphMarginLanesModel(int maxLine) {
    _lanes = Uint8List(((maxLine + 1) * _maxLane / 8).ceil());
  }

  /// 1:1: `public reset(maxLine: number)`
  void reset(int maxLine) {
    final int bytes = ((maxLine + 1) * _maxLane / 8).ceil();
    if (_lanes.length < bytes) {
      _lanes = Uint8List(bytes);
    } else {
      _lanes.fillRange(0, _lanes.length, 0);
    }
    _requiredLanes = 1;
  }

  /// 1:1: `public get requiredLanes()`
  int get requiredLanes => _requiredLanes;

  /// 1:1: `public push(lane: GlyphMarginLane, range: Range, persist?: boolean)`
  void push(int lane, Range range, [bool persist = false]) {
    if (persist) {
      _persist |= (1 << (lane - 1));
    }
    for (int i = range.startLineNumber; i <= range.endLineNumber; i++) {
      final int bit = (_maxLane * i) + (lane - 1);
      // JS `bit >>> 3` (unsigned shift). bit is always >= 0 here, so Dart's
      // truncating `~/` by 8 is equivalent. `lanes[bit >>> 3]` uses the same.
      _lanes[bit >> 3] |= (1 << (bit % 8));
      final int count = countAtLine(i);
      _requiredLanes = count > _requiredLanes ? count : _requiredLanes;
    }
  }

  /// 1:1: `public getLanesAtLine(lineNumber: number): GlyphMarginLane[]`
  List<int> getLanesAtLine(int lineNumber) {
    final List<int> lanes = <int>[];
    int bit = _maxLane * lineNumber;
    for (int i = 0; i < _maxLane; i++) {
      if ((_persist & (1 << i)) != 0 || (_lanes[bit >> 3] & (1 << (bit % 8))) != 0) {
        lanes.add(i + 1);
      }
      bit++;
    }
    return lanes.isNotEmpty ? lanes : <int>[GlyphMarginLane.Center];
  }

  /// 1:1: `private countAtLine(lineNumber: number): number`
  int countAtLine(int lineNumber) {
    int bit = _maxLane * lineNumber;
    int count = 0;
    for (int i = 0; i < _maxLane; i++) {
      if ((_persist & (1 << i)) != 0 || (_lanes[bit >> 3] & (1 << (bit % 8))) != 0) {
        count++;
      }
      bit++;
    }
    return count;
  }
}
