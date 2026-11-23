// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/iterator.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `namespace Iterable` -> class `IterableX`
// with static members (call sites `Iterable.X` become `IterableX.X`; see note).
// `function*` generators -> Dart `sync*` returning Iterable; `async` ->
// `Future`. `isIterable` is inlined from types.ts (already ported). Type guard
// overloads collapse to a single `bool` signature.
// ---------------------------------------------------------------------------

import './types.dart' as types;

/// Iterable utilities (TS `namespace Iterable`).
class IterableX {
  const IterableX._();

  /// TS `Iterable.is(thing)`. Named `isIterable` because `is` is a Dart keyword.
  static bool isIterable<T>(Object? thing) => thing is Iterable<T>;

  static const List<Never> _empty = <Never>[];

  static List<Never> empty<T>() => _empty;

  static Iterable<T> single<T>(T element) sync* {
    yield element;
  }

  static Iterable<T> wrap<T>(Object iterableOrElement) {
    if (isIterable<T>(iterableOrElement)) {
      return iterableOrElement as Iterable<T>;
    } else {
      return single(iterableOrElement as T);
    }
  }

  static Iterable<T> from<T>(Iterable<T>? iterable) => iterable ?? _empty;

  static Iterable<T> reverse<T>(List<T> array) sync* {
    for (int i = array.length - 1; i >= 0; i--) {
      yield array[i];
    }
  }

  static bool isEmpty<T>(Iterable<T>? iterable) {
    if (iterable == null) return true;
    final Iterator<T> it = iterable.iterator;
    return !it.moveNext();
  }

  static T? first<T>(Iterable<T> iterable) {
    final Iterator<T> it = iterable.iterator;
    return it.moveNext() ? it.current : null;
  }

  static bool some<T>(Iterable<T> iterable, bool Function(T t, int i) predicate) {
    int i = 0;
    for (final T element in iterable) {
      if (predicate(element, i++)) {
        return true;
      }
    }
    return false;
  }

  static bool every<T>(Iterable<T> iterable, bool Function(T t, int i) predicate) {
    int i = 0;
    for (final T element in iterable) {
      if (!predicate(element, i++)) {
        return false;
      }
    }
    return true;
  }

  static T? find<T>(Iterable<T> iterable, bool Function(T t) predicate) {
    for (final T element in iterable) {
      if (predicate(element)) {
        return element;
      }
    }
    return null;
  }

  static Iterable<T> filter<T>(Iterable<T> iterable, bool Function(T t) predicate) sync* {
    for (final T element in iterable) {
      if (predicate(element)) {
        yield element;
      }
    }
  }

  static Iterable<R> map<T, R>(Iterable<T> iterable, R Function(T t, int index) fn) sync* {
    int index = 0;
    for (final T element in iterable) {
      yield fn(element, index++);
    }
  }

  static Iterable<R> flatMap<T, R>(Iterable<T> iterable, Iterable<R> Function(T t, int index) fn) sync* {
    int index = 0;
    for (final T element in iterable) {
      yield* fn(element, index++);
    }
  }

  static Iterable<T> concat<T>(List<Object> iterables) sync* {
    for (final Object item in iterables) {
      if (types.isIterable(item)) {
        yield* item as Iterable<T>;
      } else {
        yield item as T;
      }
    }
  }

  static R reduce<T, R>(Iterable<T> iterable, R Function(R previousValue, T currentValue) reducer, R initialValue) {
    R value = initialValue;
    for (final T element in iterable) {
      value = reducer(value, element);
    }
    return value;
  }

  static int length<T>(Iterable<T> iterable) {
    int count = 0;
    for (final T _ in iterable) {
      count++;
    }
    return count;
  }

  /// Returns an iterable slice of the array, with the same semantics as
  /// `array.slice()`.
  static Iterable<T> slice<T>(List<T> arr, int from, [int? to]) {
    int end = to ?? arr.length;
    if (from < -arr.length) {
      from = 0;
    }
    if (from < 0) {
      from += arr.length;
    }

    if (end < 0) {
      end += arr.length;
    } else if (end > arr.length) {
      end = arr.length;
    }

    return _sliceRange(arr, from, end);
  }

  static Iterable<T> _sliceRange<T>(List<T> arr, int from, int to) sync* {
    for (; from < to; from++) {
      yield arr[from];
    }
  }

  /// Consumes `atMost` elements from iterable and returns the consumed elements,
  /// and an iterable for the rest of the elements.
  static (List<T>, Iterable<T>) consume<T>(Iterable<T> iterable, [num? atMost]) {
    final List<T> consumed = <T>[];
    final num limit = atMost ?? double.infinity;

    if (limit == 0) {
      return (consumed, iterable);
    }

    final Iterator<T> iterator = iterable.iterator;

    for (int i = 0; i < limit; i++) {
      if (!iterator.moveNext()) {
        return (consumed, _empty);
      }
      consumed.add(iterator.current);
    }

    return (consumed, _RestIterable<T>(iterator));
  }

  static Future<List<T>> asyncToArray<T>(Stream<T> iterable) async {
    final List<T> result = <T>[];
    await for (final T item in iterable) {
      result.add(item);
    }
    return result;
  }

  static Future<List<T>> asyncToArrayFlat<T>(Stream<List<T>> iterable) async {
    List<T> result = <T>[];
    await for (final List<T> item in iterable) {
      result = List<T>.from(result)..addAll(item);
    }
    return result;
  }
}

class _RestIterable<T> extends Iterable<T> {
  final Iterator<T> _iterator;
  _RestIterable(this._iterator);

  @override
  Iterator<T> get iterator => _iterator;
}

// NOTE: TS namespace `Iterable` is ported as class `IterableX` to avoid a name
// clash with dart:core's `Iterable`. This is the one intentional rename; every
// member name is preserved. All in-tree usages in the ported layers reference
// `IterableX.*`.
