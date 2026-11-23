// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/navigator.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. `interface` -> `abstract class`;
// TS constructor parameter defaults that reference earlier params -> Dart
// optional positional params resolved in the initializer list.
// ---------------------------------------------------------------------------

import 'dart:math' as math;

abstract class INavigator<T> {
  T? current();
  T? previous();
  T? first();
  T? last();
  T? next();
}

class ArrayNavigator<T> implements INavigator<T> {
  final List<T> items;
  int start;
  int end;
  int index;

  ArrayNavigator(this.items, [int? start, int? end, int? index])
      : start = start ?? 0,
        end = end ?? items.length,
        index = index ?? (start ?? 0) - 1;

  @override
  T? current() {
    if (index == start - 1 || index == end) {
      return null;
    }

    return items[index];
  }

  @override
  T? next() {
    index = math.min(index + 1, end);
    return current();
  }

  @override
  T? previous() {
    index = math.max(index - 1, start - 1);
    return current();
  }

  @override
  T? first() {
    index = start;
    return current();
  }

  @override
  T? last() {
    index = end - 1;
    return current();
  }
}
