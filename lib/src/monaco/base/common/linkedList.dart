// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/linkedList.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS sentinel `Node.Undefined` -> Dart `null`
// for the `next`/`prev`/`first`/`last` links (a null link is "undefined node").
// `void Function()` remove handles mirror the source closures. Structure,
// method names (`isEmpty()` stays a method) and control flow are otherwise
// identical. An `iterable` getter exposes iteration without mixing in
// `Iterable` (whose `isEmpty` getter would clash with the source method).
// ---------------------------------------------------------------------------

class _Node<E> {
  E element;
  _Node<E>? next;
  _Node<E>? prev;

  _Node(this.element);
}

/// A doubly linked list.
class LinkedList<E> {
  _Node<E>? _first;
  _Node<E>? _last;
  int _size = 0;

  int get size => _size;

  bool isEmpty() => _first == null;

  void clear() {
    _Node<E>? node = _first;
    while (node != null) {
      final _Node<E>? next = node.next;
      node.prev = null;
      node.next = null;
      node = next;
    }

    _first = null;
    _last = null;
    _size = 0;
  }

  void Function() unshift(E element) => _insert(element, false);

  void Function() push(E element) => _insert(element, true);

  void Function() _insert(E element, bool atTheEnd) {
    final _Node<E> newNode = _Node<E>(element);
    if (_first == null) {
      _first = newNode;
      _last = newNode;
    } else if (atTheEnd) {
      // push
      final _Node<E> oldLast = _last!;
      _last = newNode;
      newNode.prev = oldLast;
      oldLast.next = newNode;
    } else {
      // unshift
      final _Node<E> oldFirst = _first!;
      _first = newNode;
      newNode.next = oldFirst;
      oldFirst.prev = newNode;
    }
    _size += 1;

    bool didRemove = false;
    return () {
      if (!didRemove) {
        didRemove = true;
        _remove(newNode);
      }
    };
  }

  E? shift() {
    if (_first == null) {
      return null;
    } else {
      final E res = _first!.element;
      _remove(_first!);
      return res;
    }
  }

  E? pop() {
    if (_last == null) {
      return null;
    } else {
      final E res = _last!.element;
      _remove(_last!);
      return res;
    }
  }

  E? peek() {
    if (_last == null) {
      return null;
    } else {
      return _last!.element;
    }
  }

  void _remove(_Node<E> node) {
    if (node.prev != null && node.next != null) {
      // middle
      final _Node<E> anchor = node.prev!;
      anchor.next = node.next;
      node.next!.prev = anchor;
    } else if (node.prev == null && node.next == null) {
      // only node
      _first = null;
      _last = null;
    } else if (node.next == null) {
      // last
      _last = node.prev;
      _last!.next = null;
    } else if (node.prev == null) {
      // first
      _first = node.next;
      _first!.prev = null;
    }

    // done
    _size -= 1;
  }

  Iterable<E> get iterable sync* {
    _Node<E>? node = _first;
    while (node != null) {
      yield node.element;
      node = node.next;
    }
  }
}
