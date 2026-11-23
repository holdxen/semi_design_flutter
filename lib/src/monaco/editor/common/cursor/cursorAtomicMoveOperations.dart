// 1:1 port of vscode/src/vs/editor/common/cursor/cursorAtomicMoveOperations.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c

import '../../../base/common/charCode.dart';
import '../core/cursorColumns.dart';

/// 1:1: `export const enum Direction`
class Direction {
  static const int Left = 0;
  static const int Right = 1;
  static const int Nearest = 2;
}

/// 1:1: `export class AtomicTabMoveOperations`
class AtomicTabMoveOperations {
  /// Get the visible column at the position. If we get to a non-whitespace character first
  /// or past the end of string then return -1.
  ///
  /// **Note** `position` and the return value are 0-based.
  ///
  /// 1:1: `whitespaceVisibleColumn`. Source tuple `[number, number, number]` -> `List<int>`.
  static List<int> whitespaceVisibleColumn(
      String lineContent, int position, int tabSize) {
    final int lineLength = lineContent.length;
    int visibleColumn = 0;
    int prevTabStopPosition = -1;
    int prevTabStopVisibleColumn = -1;
    for (int i = 0; i < lineLength; i++) {
      if (i == position) {
        return <int>[
          prevTabStopPosition,
          prevTabStopVisibleColumn,
          visibleColumn
        ];
      }
      if (visibleColumn % tabSize == 0) {
        prevTabStopPosition = i;
        prevTabStopVisibleColumn = visibleColumn;
      }
      final int chCode = lineContent.codeUnitAt(i);
      switch (chCode) {
        case CharCode.Space:
          visibleColumn += 1;
          break;
        case CharCode.Tab:
          // Skip to the next multiple of tabSize.
          visibleColumn =
              CursorColumns.nextRenderTabStop(visibleColumn, tabSize);
          break;
        default:
          return <int>[-1, -1, -1];
      }
    }
    if (position == lineLength) {
      return <int>[
        prevTabStopPosition,
        prevTabStopVisibleColumn,
        visibleColumn
      ];
    }
    return <int>[-1, -1, -1];
  }

  /// Return the position that should result from a move left, right or to the
  /// nearest tab, if atomic tabs are enabled. Left and right are used for the
  /// arrow key movements, nearest is used for mouse selection. It returns
  /// -1 if atomic tabs are not relevant and you should fall back to normal
  /// behaviour.
  ///
  /// **Note**: `position` and the return value are 0-based.
  ///
  /// 1:1: `atomicPosition`
  static int atomicPosition(String lineContent, int position, int tabSize,
      int direction) {
    final int lineLength = lineContent.length;

    // Get the 0-based visible column corresponding to the position, or return
    // -1 if it is not in the initial whitespace.
    final List<int> info =
        AtomicTabMoveOperations.whitespaceVisibleColumn(lineContent, position, tabSize);
    final int prevTabStopPosition = info[0];
    final int prevTabStopVisibleColumn = info[1];
    final int visibleColumn = info[2];

    if (visibleColumn == -1) {
      return -1;
    }

    // Is the output left or right of the current position. The case for nearest
    // where it is the same as the current position is handled in the switch.
    late final bool left;
    switch (direction) {
      case Direction.Left:
        left = true;
        break;
      case Direction.Right:
        left = false;
        break;
      case Direction.Nearest:
        // The code below assumes the output position is either left or right
        // of the input position. If it is the same, return immediately.
        if (visibleColumn % tabSize == 0) {
          return position;
        }
        // Go to the nearest indentation.
        left = visibleColumn % tabSize <= (tabSize / 2);
        break;
      default:
        // TS exhaustiveness: `left` is definitely assigned for all enum members.
        return -1;
    }

    // If going left, we can just use the info about the last tab stop position and
    // last tab stop visible column that we computed in the first walk over the whitespace.
    if (left) {
      if (prevTabStopPosition == -1) {
        return -1;
      }
      // If the direction is left, we need to keep scanning right to ensure
      // that targetVisibleColumn + tabSize is before non-whitespace.
      // This is so that when we press left at the end of a partial
      // indentation it only goes one character. For example '      foo' with
      // tabSize 4, should jump from position 6 to position 5, not 4.
      int currentVisibleColumn = prevTabStopVisibleColumn;
      for (int i = prevTabStopPosition; i < lineLength; ++i) {
        if (currentVisibleColumn == prevTabStopVisibleColumn + tabSize) {
          // It is a full indentation.
          return prevTabStopPosition;
        }

        final int chCode = lineContent.codeUnitAt(i);
        switch (chCode) {
          case CharCode.Space:
            currentVisibleColumn += 1;
            break;
          case CharCode.Tab:
            currentVisibleColumn =
                CursorColumns.nextRenderTabStop(currentVisibleColumn, tabSize);
            break;
          default:
            return -1;
        }
      }
      if (currentVisibleColumn == prevTabStopVisibleColumn + tabSize) {
        return prevTabStopPosition;
      }
      // It must have been a partial indentation.
      return -1;
    }

    // We are going right.
    final int targetVisibleColumn =
        CursorColumns.nextRenderTabStop(visibleColumn, tabSize);

    // We can just continue from where whitespaceVisibleColumn got to.
    int currentVisibleColumn = visibleColumn;
    for (int i = position; i < lineLength; i++) {
      if (currentVisibleColumn == targetVisibleColumn) {
        return i;
      }

      final int chCode = lineContent.codeUnitAt(i);
      switch (chCode) {
        case CharCode.Space:
          currentVisibleColumn += 1;
          break;
        case CharCode.Tab:
          currentVisibleColumn =
              CursorColumns.nextRenderTabStop(currentVisibleColumn, tabSize);
          break;
        default:
          return -1;
      }
    }
    // This condition handles when the target column is at the end of the line.
    if (currentVisibleColumn == targetVisibleColumn) {
      return lineLength;
    }
    return -1;
  }
}
