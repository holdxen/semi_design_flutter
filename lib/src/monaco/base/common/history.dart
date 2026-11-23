// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/history.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - `interface IHistory<T>` -> abstract class; optional methods/properties
//     (`replace?`, `onDidChange?`) -> nullable getters.
//   - `new Set()` default -> internal `_SetHistory<T>` carrier (Dart Set has
//     no `replace`/`onDidChange`).
//   - `[Symbol.iterator]()` -> `Iterable<T>`.
// ---------------------------------------------------------------------------

import 'collections.dart' as collections;
import 'event.dart' as event;
import 'lifecycle.dart' as lifecycle;
import 'navigator.dart' as navigator;

/// 1:1: `export interface IHistory<T>`
abstract class IHistory<T> {
  bool delete(T t);

  IHistory<T> add(T t);

  bool has(T t);

  void clear();

  void forEach(void Function(T value, T value2, Set<T> set) callbackfn,
      [Object? thisArg]);

  /// 1:1: `replace?(t: T[]): void` — optional method.
  void Function(List<T> values)? get replace;

  /// 1:1: `readonly onDidChange?: Event<string[]>`
  event.Event<List<String>>? get onDidChange;
}

/// TS `new Set()` used as the default [IHistory].
class _SetHistory<T> implements IHistory<T> {
  final Set<T> _set;

  _SetHistory([Iterable<T>? values])
      : _set = values == null ? <T>{} : <T>{...values};

  @override
  bool delete(T t) => _set.remove(t);

  @override
  IHistory<T> add(T t) {
    _set.add(t);
    return this;
  }

  @override
  bool has(T t) => _set.contains(t);

  @override
  void clear() => _set.clear();

  @override
  void forEach(void Function(T value, T value2, Set<T> set) callbackfn,
      [Object? thisArg]) {
    for (final T value in _set) {
      callbackfn(value, value, _set);
    }
  }

  @override
  void Function(List<T> values)? get replace => null;

  @override
  event.Event<List<String>>? get onDidChange => null;
}

/// JS truthiness used by `_currentPosition()` (`if (!currentElement)`).
bool _isFalsy(Object? value) {
  if (value == null) return true;
  if (value is bool) return !value;
  if (value is num) return value == 0;
  if (value is String) return value.isEmpty;
  return false;
}

/// 1:1: `export class HistoryNavigator<T> implements INavigator<T>`
class HistoryNavigator<T> implements navigator.INavigator<T> {
  final int _limit;
  late navigator.ArrayNavigator<T> _navigator;
  lifecycle.IDisposable? _disposable;
  IHistory<T> _history;

  HistoryNavigator([IHistory<T>? history, int limit = 10])
      : _history = history ?? _SetHistory<T>(),
        _limit = limit {
    _onChange();
    final event.Event<List<String>>? onDidChange = _history.onDidChange;
    if (onDidChange != null) {
      _disposable = onDidChange((Object? _) => _onChange());
    }
  }

  /// 1:1: `public getHistory(): T[]`
  List<T> getHistory() => _elements;

  /// 1:1: `public add(t: T)`
  void add(T t) {
    _history.delete(t);
    _history.add(t);
    _onChange();
  }

  @override
  T? next() => _navigator.next();

  @override
  T? previous() {
    if (_currentPosition() != 0) {
      return _navigator.previous();
    }
    return null;
  }

  @override
  T? current() => _navigator.current();

  @override
  T? first() => _navigator.first();

  @override
  T? last() => _navigator.last();

  bool isFirst() => _currentPosition() == 0;

  bool isLast() => _currentPosition() >= _elements.length - 1;

  bool isNowhere() => _navigator.current() == null;

  bool has(T t) => _history.has(t);

  void clear() {
    _history.clear();
    _onChange();
  }

  void _onChange() {
    _reduceToLimit();
    final List<T> elements = _elements;
    _navigator = navigator.ArrayNavigator<T>(
        elements, 0, elements.length, elements.length);
  }

  void _reduceToLimit() {
    final List<T> data = _elements;
    if (data.length > _limit) {
      final List<T> replaceValue = data.sublist(data.length - _limit);
      final void Function(List<T> values)? replace = _history.replace;
      if (replace != null) {
        replace(replaceValue);
      } else {
        _history = _SetHistory<T>(replaceValue);
      }
    }
  }

  int _currentPosition() {
    final T? currentElement = _navigator.current();
    if (_isFalsy(currentElement)) {
      return -1;
    }
    return _elements.indexOf(currentElement as T);
  }

  List<T> get _elements {
    final List<T> elements = <T>[];
    _history.forEach((T e, T value2, Set<T> set) => elements.add(e));
    return elements;
  }

  /// 1:1: `public dispose(): void`
  void dispose() {
    if (_disposable != null) {
      _disposable!.dispose();
      _disposable = null;
    }
  }
}

/// 1:1: `interface HistoryNode<T>`
class HistoryNode<T> {
  T value;
  HistoryNode<T>? previous;
  HistoryNode<T>? next;

  HistoryNode(this.value, [this.previous, this.next]);
}

/// 1:1: `export class HistoryNavigator2<T>`
class HistoryNavigator2<T> {
  late final collections.SetWithKey<T> valueSet;
  late HistoryNode<T> head;
  late HistoryNode<T> tail;
  late HistoryNode<T> cursor;
  int _size;

  final int capacity;
  final Object? Function(T t) identityFn;

  int get size => _size;

  HistoryNavigator2(List<T> history,
      [this.capacity = 10, Object? Function(T t)? identityFn])
      : identityFn = identityFn ?? ((T t) => t),
        _size = 1 {
    if (history.isEmpty) {
      throw StateError('not supported');
    }

    head = tail = cursor = HistoryNode<T>(history[0]);
    valueSet = collections.SetWithKey<T>([history[0]], this.identityFn);
    for (int i = 1; i < history.length; i++) {
      add(history[i]);
    }
  }

  /// 1:1: `add(value: T): void`
  void add(T value) {
    final HistoryNode<T> node = HistoryNode<T>(value, tail);
    tail.next = node;
    tail = node;
    cursor = tail;
    _size++;

    if (valueSet.contains(value)) {
      _deleteFromList(value);
    } else {
      valueSet.add(value);
    }

    while (_size > capacity) {
      valueSet.delete(head.value);
      head = head.next!;
      head.previous = null;
      _size--;
    }
  }

  /// 1:1: `replaceLast(value: T): T`
  T replaceLast(T value) {
    if (identityFn(tail.value) == identityFn(value)) {
      return value;
    }

    final T oldValue = tail.value;
    valueSet.delete(oldValue);
    tail.value = value;

    if (valueSet.contains(value)) {
      _deleteFromList(value);
    } else {
      valueSet.add(value);
    }

    return oldValue;
  }

  /// 1:1: `prepend(value: T): void`
  void prepend(T value) {
    if (_size == capacity || valueSet.contains(value)) {
      return;
    }

    final HistoryNode<T> node = HistoryNode<T>(value, null, head);
    head.previous = node;
    head = node;
    _size++;

    valueSet.add(value);
  }

  bool isAtEnd() => identical(cursor, tail);

  T current() => cursor.value;

  T previous() {
    if (cursor.previous != null) {
      cursor = cursor.previous!;
    }
    return cursor.value;
  }

  T next() {
    if (cursor.next != null) {
      cursor = cursor.next!;
    }
    return cursor.value;
  }

  bool has(T t) => valueSet.contains(t);

  T resetCursor() {
    cursor = tail;
    return cursor.value;
  }

  Iterator<T> get iterator => _iterate().iterator;

  /// Dart carrier for `[Symbol.iterator]()`.
  List<T> toList() => _iterate().toList();

  Iterable<T> _iterate() sync* {
    HistoryNode<T>? node = head;
    while (node != null) {
      yield node.value;
      node = node.next;
    }
  }

  void _deleteFromList(T value) {
    HistoryNode<T> temp = head;
    final Object? valueKey = identityFn(value);
    while (!identical(temp, tail)) {
      if (identityFn(temp.value) == valueKey) {
        if (identical(temp, head)) {
          head = head.next!;
          head.previous = null;
        } else {
          temp.previous!.next = temp.next;
          temp.next!.previous = temp.previous;
        }
        _size--;
      }
      temp = temp.next!;
    }
  }
}
