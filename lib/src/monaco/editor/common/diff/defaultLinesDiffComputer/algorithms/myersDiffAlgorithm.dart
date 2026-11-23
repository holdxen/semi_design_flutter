/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 翻译自 vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/algorithms/myersDiffAlgorithm.ts

import 'dart:typed_data';

import '../../../core/ranges/offsetRange.dart';
import 'diffAlgorithm.dart';

/// 1:1: `export class MyersDiffAlgorithm implements IDiffAlgorithm`
class MyersDiffAlgorithm implements IDiffAlgorithm {
  @override
  DiffAlgorithmResult compute(ISequence seq1, ISequence seq2,
      [ITimeout? timeout]) {
    final ITimeout t = timeout ?? InfiniteTimeout.instance;

    // These are common special cases.
    // The early return improves performance dramatically.
    if (seq1.length == 0 || seq2.length == 0) {
      return DiffAlgorithmResult.trivial(seq1, seq2);
    }

    final ISequence seqX = seq1; // Text on the x axis
    final ISequence seqY = seq2; // Text on the y axis

    // 1:1: `getXAfterSnake(x, y)` — closure captured seqX/seqY
    int getXAfterSnake(int x, int y) {
      while (x < seqX.length &&
          y < seqY.length &&
          seqX.getElement(x) == seqY.getElement(y)) {
        x++;
        y++;
      }
      return x;
    }

    int d = 0;
    // V[k]: X value of longest d-line that ends in diagonal k.
    final FastInt32Array V = FastInt32Array();
    V.set(0, getXAfterSnake(0, 0));

    final FastArrayNegativeIndices<SnakePath?> paths =
        FastArrayNegativeIndices<SnakePath?>();
    paths.set(0, V.get(0) == 0 ? null : SnakePath(null, 0, 0, V.get(0)));

    int k = 0;

    outerLoop: while (true) {
      d++;
      if (!t.isValid()) {
        return DiffAlgorithmResult.trivialTimedOut(seqX, seqY);
      }
      // The paper has `for (k = -d; k <= d; k += 2)`, but we can ignore
      // diagonals that cannot influence the result.
      final int lowerBound = -(d < seqY.length + (d % 2) ? d : seqY.length + (d % 2));
      final int upperBound = (d < seqX.length + (d % 2) ? d : seqX.length + (d % 2));
      for (k = lowerBound; k <= upperBound; k += 2) {
        // We can use the X values of (d-1)-lines to compute X value of the longest d-lines.
        final int maxXofDLineTop =
            k == upperBound ? -1 : V.get(k + 1); // vertical non-diagonal
        final int maxXofDLineLeft =
            k == lowerBound ? -1 : V.get(k - 1) + 1; // horizontal non-diagonal
        final int maxTopLeft = (maxXofDLineTop > maxXofDLineLeft
            ? maxXofDLineTop
            : maxXofDLineLeft);
        final int x = (maxTopLeft < seqX.length ? maxTopLeft : seqX.length);
        final int y = x - k;
        if (x > seqX.length || y > seqY.length) {
          // This diagonal is irrelevant for the result.
          continue;
        }
        final int newMaxX = getXAfterSnake(x, y);
        V.set(k, newMaxX);
        final SnakePath? lastPath =
            x == maxXofDLineTop ? paths.get(k + 1) : paths.get(k - 1);
        paths.set(
            k, newMaxX != x ? SnakePath(lastPath, x, y, newMaxX - x) : lastPath);

        if (V.get(k) == seqX.length && V.get(k) - k == seqY.length) {
          break outerLoop;
        }
      }
    }

    SnakePath? path = paths.get(k);
    final List<SequenceDiff> result = <SequenceDiff>[];
    int lastAligningPosS1 = seqX.length;
    int lastAligningPosS2 = seqY.length;

    while (true) {
      final int endX = path != null ? path.x + path.length : 0;
      final int endY = path != null ? path.y + path.length : 0;

      if (endX != lastAligningPosS1 || endY != lastAligningPosS2) {
        result.add(SequenceDiff(
          OffsetRange(endX, lastAligningPosS1),
          OffsetRange(endY, lastAligningPosS2),
        ));
      }
      if (path == null) {
        break;
      }
      lastAligningPosS1 = path.x;
      lastAligningPosS2 = path.y;

      path = path.prev;
    }

    final List<SequenceDiff> reversed = result.reversed.toList();
    return DiffAlgorithmResult(reversed, false);
  }
}

/// 1:1: `class SnakePath`
class SnakePath {
  final SnakePath? prev;
  final int x;
  final int y;
  final int length;
  SnakePath(this.prev, this.x, this.y, this.length);
}

/// 1:1: `class FastInt32Array` — an array that supports fast negative indices.
class FastInt32Array {
  Int32List _positiveArr = Int32List(10);
  Int32List _negativeArr = Int32List(10);

  int get(int idx) {
    if (idx < 0) {
      idx = -idx - 1;
      return _negativeArr[idx];
    } else {
      return _positiveArr[idx];
    }
  }

  void set(int idx, int value) {
    if (idx < 0) {
      idx = -idx - 1;
      if (idx >= _negativeArr.length) {
        final Int32List arr = _negativeArr;
        _negativeArr = Int32List(arr.length * 2);
        _negativeArr.setAll(0, arr);
      }
      _negativeArr[idx] = value;
    } else {
      if (idx >= _positiveArr.length) {
        final Int32List arr = _positiveArr;
        _positiveArr = Int32List(arr.length * 2);
        _positiveArr.setAll(0, arr);
      }
      _positiveArr[idx] = value;
    }
  }
}

/// 1:1: `class FastArrayNegativeIndices<T>` — fast negative indices.
class FastArrayNegativeIndices<T> {
  final List<T?> _positiveArr = <T?>[];
  final List<T?> _negativeArr = <T?>[];

  T get(int idx) {
    // JS sparse array returns undefined for unset indices.
    if (idx < 0) {
      idx = -idx - 1;
      return (idx < _negativeArr.length ? _negativeArr[idx] : null) as T;
    } else {
      return (idx < _positiveArr.length ? _positiveArr[idx] : null) as T;
    }
  }

  void set(int idx, T value) {
    if (idx < 0) {
      idx = -idx - 1;
      // JS sparse array auto-grows; Dart must pad with nulls.
      while (_negativeArr.length <= idx) {
        _negativeArr.add(null);
      }
      _negativeArr[idx] = value;
    } else {
      while (_positiveArr.length <= idx) {
        _positiveArr.add(null);
      }
      _positiveArr[idx] = value;
    }
  }
}

