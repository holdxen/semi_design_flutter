// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/ternarySearchTree.ts
// Translated 1:1 from TypeScript.
//   - `IKeyIterator.reset/next(): this` -> covariant return of implementing type.
//   - `Undef.Val` symbol -> private sentinel object (Dart has no unique symbol).
//   - `IterableIterator` -> `Iterable<MapEntry<K, V>>`.
//   - JS truthiness (`||`, `if (min.key)`) -> `_truthy` helper.
// ---------------------------------------------------------------------------

import 'arrays.dart' as arrays;
import 'assert.dart' as asserts;
import 'charCode.dart';
import 'strings.dart' as strings;
import 'uri.dart';

/// 1:1: `IKeyIterator<K>`
abstract class IKeyIterator<K> {
  IKeyIterator<K> reset(K key);
  IKeyIterator<K> next();
  bool hasNext();
  int cmp(String a);
  String value();
}

/// 1:1: `StringIterator`
class StringIterator implements IKeyIterator<String> {
  String _value = '';
  int _pos = 0;

  @override
  StringIterator reset(String key) {
    _value = key;
    _pos = 0;
    return this;
  }

  @override
  StringIterator next() {
    _pos += 1;
    return this;
  }

  @override
  bool hasNext() => _pos < _value.length - 1;

  @override
  int cmp(String a) {
    final int aCode = a.codeUnitAt(0);
    final int thisCode = _value.codeUnitAt(_pos);
    return aCode - thisCode;
  }

  @override
  String value() => _value[_pos];
}

/// 1:1: `ConfigKeysIterator`
class ConfigKeysIterator implements IKeyIterator<String> {
  late String _value;
  late int _from;
  late int _to;
  final bool _caseSensitive;

  ConfigKeysIterator([this._caseSensitive = true]);

  @override
  ConfigKeysIterator reset(String key) {
    _value = key;
    _from = 0;
    _to = 0;
    return next();
  }

  @override
  bool hasNext() => _to < _value.length;

  @override
  ConfigKeysIterator next() {
    _from = _to;
    bool justSeps = true;
    for (; _to < _value.length; _to++) {
      final int ch = _value.codeUnitAt(_to);
      if (ch == CharCode.Period) {
        if (justSeps) {
          _from++;
        } else {
          break;
        }
      } else {
        justSeps = false;
      }
    }
    return this;
  }

  @override
  int cmp(String a) => _caseSensitive
      ? strings.compareSubstring(a, _value, 0, a.length, _from, _to)
      : strings.compareSubstringIgnoreCase(a, _value, 0, a.length, _from, _to);

  @override
  String value() => _value.substring(_from, _to);
}

/// 1:1: `PathIterator`
class PathIterator implements IKeyIterator<String> {
  late String _value;
  late int _valueLen;
  late int _from;
  late int _to;
  final bool _splitOnBackslash;
  final bool _caseSensitive;

  PathIterator([this._splitOnBackslash = true, this._caseSensitive = true]);

  @override
  PathIterator reset(String key) {
    _from = 0;
    _to = 0;
    _value = key;
    _valueLen = key.length;
    for (int pos = key.length - 1; pos >= 0; pos--) {
      final int ch = _value.codeUnitAt(pos);
      if (!(ch == CharCode.Slash ||
          (_splitOnBackslash && ch == CharCode.Backslash))) {
        break;
      }
      _valueLen--;
    }
    return next();
  }

  @override
  bool hasNext() => _to < _valueLen;

  @override
  PathIterator next() {
    _from = _to;
    bool justSeps = true;
    for (; _to < _valueLen; _to++) {
      final int ch = _value.codeUnitAt(_to);
      if (ch == CharCode.Slash ||
          (_splitOnBackslash && ch == CharCode.Backslash)) {
        if (justSeps) {
          _from++;
        } else {
          break;
        }
      } else {
        justSeps = false;
      }
    }
    return this;
  }

  @override
  int cmp(String a) => _caseSensitive
      ? strings.compareSubstring(a, _value, 0, a.length, _from, _to)
      : strings.compareSubstringIgnoreCase(a, _value, 0, a.length, _from, _to);

  @override
  String value() => _value.substring(_from, _to);
}

/// 1:1: `UriIteratorState` (const enum)
class UriIteratorState {
  static const int Scheme = 1;
  static const int Authority = 2;
  static const int Path = 3;
  static const int Query = 4;
  static const int Fragment = 5;
}

/// 1:1: `UriIterator`
class UriIterator implements IKeyIterator<URI> {
  late PathIterator _pathIterator;
  late URI _value;
  List<int> _states = <int>[];
  int _stateIdx = 0;
  final bool Function(URI) _ignorePathCasing;
  final bool Function(URI) _ignoreQueryAndFragment;

  UriIterator(this._ignorePathCasing, this._ignoreQueryAndFragment);

  int get _state =>
      _stateIdx < _states.length ? _states[_stateIdx] : 0;

  @override
  UriIterator reset(URI key) {
    _value = key;
    _states = <int>[];
    if (_value.scheme.isNotEmpty) {
      _states.add(UriIteratorState.Scheme);
    }
    if (_value.authority.isNotEmpty) {
      _states.add(UriIteratorState.Authority);
    }
    if (_value.path.isNotEmpty) {
      _pathIterator = PathIterator(false, !_ignorePathCasing(key));
      _pathIterator.reset(key.path);
      if (_pathIterator.value().isNotEmpty) {
        _states.add(UriIteratorState.Path);
      }
    }
    if (!_ignoreQueryAndFragment(key)) {
      if (_value.query.isNotEmpty) {
        _states.add(UriIteratorState.Query);
      }
      if (_value.fragment.isNotEmpty) {
        _states.add(UriIteratorState.Fragment);
      }
    }
    _stateIdx = 0;
    return this;
  }

  @override
  UriIterator next() {
    if (_state == UriIteratorState.Path && _pathIterator.hasNext()) {
      _pathIterator.next();
    } else {
      _stateIdx += 1;
    }
    return this;
  }

  @override
  bool hasNext() =>
      (_state == UriIteratorState.Path && _pathIterator.hasNext()) ||
      _stateIdx < _states.length - 1;

  @override
  int cmp(String a) {
    if (_state == UriIteratorState.Scheme) {
      return strings.compareIgnoreCase(a, _value.scheme);
    } else if (_state == UriIteratorState.Authority) {
      return strings.compareIgnoreCase(a, _value.authority);
    } else if (_state == UriIteratorState.Path) {
      return _pathIterator.cmp(a);
    } else if (_state == UriIteratorState.Query) {
      return strings.compare(a, _value.query);
    } else if (_state == UriIteratorState.Fragment) {
      return strings.compare(a, _value.fragment);
    }
    throw StateError('Unexpected URI iterator state');
  }

  @override
  String value() {
    if (_state == UriIteratorState.Scheme) {
      return _value.scheme;
    } else if (_state == UriIteratorState.Authority) {
      return _value.authority;
    } else if (_state == UriIteratorState.Path) {
      return _pathIterator.value();
    } else if (_state == UriIteratorState.Query) {
      return _value.query;
    } else if (_state == UriIteratorState.Fragment) {
      return _value.fragment;
    }
    throw StateError('Unexpected URI iterator state');
  }
}

/// 1:1: `Undef.Val` unique symbol placeholder.
class _UndefVal {
  const _UndefVal();
}

final Object _undefVal = const _UndefVal();

Object? _undefWrap(Object? value) => value ?? _undefVal;

Object? _undefUnwrap(Object? value) =>
    identical(value, _undefVal) ? null : value;

/// JS truthiness for the `||` and `if (key)` occurrences in the source.
bool _truthy(Object? value) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.isNotEmpty;
  }
  if (value is num) {
    return value != 0 && !value.isNaN;
  }
  return true;
}

/// 1:1: `TernarySearchTreeNode<K, V>`
class TernarySearchTreeNode<K, V> {
  int height = 1;
  late String segment;
  Object? value;
  K? key;
  TernarySearchTreeNode<K, V>? left;
  TernarySearchTreeNode<K, V>? mid;
  TernarySearchTreeNode<K, V>? right;

  bool isEmpty() =>
      left == null && mid == null && right == null && value == null;

  TernarySearchTreeNode<K, V> rotateLeft() {
    final TernarySearchTreeNode<K, V> tmp = right!;
    right = tmp.left;
    tmp.left = this;
    updateHeight();
    tmp.updateHeight();
    return tmp;
  }

  TernarySearchTreeNode<K, V> rotateRight() {
    final TernarySearchTreeNode<K, V> tmp = left!;
    left = tmp.right;
    tmp.right = this;
    updateHeight();
    tmp.updateHeight();
    return tmp;
  }

  void updateHeight() {
    height = 1 + (heightLeft > heightRight ? heightLeft : heightRight);
  }

  int balanceFactor() => heightRight - heightLeft;

  int get heightLeft => left?.height ?? 0;

  int get heightRight => right?.height ?? 0;
}

/// 1:1: `Dir` (const enum)
class _Dir {
  static const int Left = -1;
  static const int Mid = 0;
  static const int Right = 1;
}

/// Mutable equivalent of the source tuple `[Dir, TernarySearchTreeNode<K,V>]`.
class _StackEntry<K, V> {
  int dir;
  TernarySearchTreeNode<K, V> node;
  _StackEntry(this.dir, this.node);
}

/// 1:1: `TernarySearchTree<K, V>`
class TernarySearchTree<K, V> {
  /// 1:1: `forUris`
  static TernarySearchTree<URI, E> forUris<E>(
      [bool Function(URI)? ignorePathCasing,
      bool Function(URI)? ignoreQueryAndFragment]) {
    return TernarySearchTree<URI, E>(UriIterator(
      ignorePathCasing ?? ((URI key) => false),
      ignoreQueryAndFragment ?? ((URI key) => false),
    ));
  }

  /// 1:1: `forPaths`
  static TernarySearchTree<String, E> forPaths<E>([bool ignorePathCasing = false]) {
    return TernarySearchTree<String, E>(
        PathIterator(true, !ignorePathCasing));
  }

  /// 1:1: `forStrings`
  static TernarySearchTree<String, E> forStrings<E>() =>
      TernarySearchTree<String, E>(StringIterator());

  /// 1:1: `forConfigKeys`
  static TernarySearchTree<String, E> forConfigKeys<E>() =>
      TernarySearchTree<String, E>(ConfigKeysIterator());

  final IKeyIterator<K> _iter;
  TernarySearchTreeNode<K, V>? _root;

  TernarySearchTree(this._iter);

  /// 1:1: `clear`
  void clear() {
    _root = null;
  }

  /// 1:1: `fill` (both overloads; TS tuples are `[K, V]` lists in Dart).
  void fill(Object? values, [List<K>? keys]) {
    if (keys != null) {
      final List<K> arr = keys.sublist(0);
      arrays.shuffle(arr);
      for (final K k in arr) {
        set(k, values as V);
      }
    } else {
      final List<dynamic> arr = List<dynamic>.from(values as List);
      arrays.shuffle(arr);
      for (final dynamic entry in arr) {
        final List<dynamic> tuple = entry as List<dynamic>;
        set(tuple[0] as K, tuple[1] as V);
      }
    }
  }

  /// 1:1: `set`
  V? set(K key, V element) {
    final IKeyIterator<K> iter = _iter.reset(key);
    late TernarySearchTreeNode<K, V> node;

    if (_root == null) {
      _root = TernarySearchTreeNode<K, V>();
      _root!.segment = iter.value();
    }
    final List<_StackEntry<K, V>> stack = <_StackEntry<K, V>>[];

    node = _root!;
    while (true) {
      final int val = iter.cmp(node.segment);
      if (val > 0) {
        // left
        if (node.left == null) {
          node.left = TernarySearchTreeNode<K, V>();
          node.left!.segment = iter.value();
        }
        stack.add(_StackEntry<K, V>(_Dir.Left, node));
        node = node.left!;
      } else if (val < 0) {
        // right
        if (node.right == null) {
          node.right = TernarySearchTreeNode<K, V>();
          node.right!.segment = iter.value();
        }
        stack.add(_StackEntry<K, V>(_Dir.Right, node));
        node = node.right!;
      } else if (iter.hasNext()) {
        // mid
        iter.next();
        if (node.mid == null) {
          node.mid = TernarySearchTreeNode<K, V>();
          node.mid!.segment = iter.value();
        }
        stack.add(_StackEntry<K, V>(_Dir.Mid, node));
        node = node.mid!;
      } else {
        break;
      }
    }

    // set value
    final V? oldElement = _undefUnwrap(node.value) as V?;
    node.value = _undefWrap(element);
    node.key = key;

    // balance
    for (int i = stack.length - 1; i >= 0; i--) {
      final TernarySearchTreeNode<K, V> balanceNode = stack[i].node;

      balanceNode.updateHeight();
      final int bf = balanceNode.balanceFactor();

      if (bf < -1 || bf > 1) {
        final int d1 = stack[i].dir;
        final int d2 = stack[i + 1].dir;

        if (d1 == _Dir.Right && d2 == _Dir.Right) {
          // right, right -> rotate left
          stack[i].node = balanceNode.rotateLeft();
        } else if (d1 == _Dir.Left && d2 == _Dir.Left) {
          // left, left -> rotate right
          stack[i].node = balanceNode.rotateRight();
        } else if (d1 == _Dir.Right && d2 == _Dir.Left) {
          // right, left -> double rotate right, left
          balanceNode.right = stack[i + 1].node = stack[i + 1].node.rotateRight();
          stack[i].node = balanceNode.rotateLeft();
        } else if (d1 == _Dir.Left && d2 == _Dir.Right) {
          // left, right -> double rotate left, right
          balanceNode.left = stack[i + 1].node = stack[i + 1].node.rotateLeft();
          stack[i].node = balanceNode.rotateRight();
        } else {
          throw StateError('Unexpected rotation direction');
        }

        // patch path to parent
        if (i > 0) {
          switch (stack[i - 1].dir) {
            case _Dir.Left:
              stack[i - 1].node.left = stack[i].node;
              break;
            case _Dir.Right:
              stack[i - 1].node.right = stack[i].node;
              break;
            case _Dir.Mid:
              stack[i - 1].node.mid = stack[i].node;
              break;
          }
        } else {
          _root = stack[0].node;
        }
      }
    }

    return oldElement;
  }

  /// 1:1: `get`
  V? get(K key) => _undefUnwrap(_getNode(key)?.value) as V?;

  /// 1:1: `_getNode`
  TernarySearchTreeNode<K, V>? _getNode(K key) {
    final IKeyIterator<K> iter = _iter.reset(key);
    TernarySearchTreeNode<K, V>? node = _root;
    while (node != null) {
      final int val = iter.cmp(node.segment);
      if (val > 0) {
        node = node.left;
      } else if (val < 0) {
        node = node.right;
      } else if (iter.hasNext()) {
        iter.next();
        node = node.mid;
      } else {
        break;
      }
    }
    return node;
  }

  /// 1:1: `has`
  bool has(K key) {
    final TernarySearchTreeNode<K, V>? node = _getNode(key);
    return !(node?.value == null && node?.mid == null);
  }

  /// 1:1: `delete`
  void delete(K key) => _delete(key, false);

  /// 1:1: `deleteSuperstr`
  void deleteSuperstr(K key) => _delete(key, true);

  /// 1:1: `_delete`
  void _delete(K key, bool superStr) {
    final IKeyIterator<K> iter = _iter.reset(key);
    final List<_StackEntry<K, V>> stack = <_StackEntry<K, V>>[];
    TernarySearchTreeNode<K, V>? node = _root;

    while (node != null) {
      final int val = iter.cmp(node.segment);
      if (val > 0) {
        stack.add(_StackEntry<K, V>(_Dir.Left, node));
        node = node.left;
      } else if (val < 0) {
        stack.add(_StackEntry<K, V>(_Dir.Right, node));
        node = node.right;
      } else if (iter.hasNext()) {
        iter.next();
        stack.add(_StackEntry<K, V>(_Dir.Mid, node));
        node = node.mid;
      } else {
        break;
      }
    }

    if (node == null) {
      return;
    }

    if (superStr) {
      node.left = null;
      node.mid = null;
      node.right = null;
      node.height = 1;
    } else {
      node.key = null;
      node.value = null;
    }

    // BST node removal
    if (node.mid == null && node.value == null) {
      if (node.left != null && node.right != null) {
        // full node: replace with min-node of the right branch
        final List<_StackEntry<K, V>> stack2 = <_StackEntry<K, V>>[
          _StackEntry<K, V>(_Dir.Right, node),
        ];
        final TernarySearchTreeNode<K, V> min = _min(node.right!, stack2);

        if (_truthy(min.key)) {
          node.key = min.key;
          node.value = min.value;
          node.segment = min.segment;

          final TernarySearchTreeNode<K, V>? newChild = min.right;
          if (stack2.length > 1) {
            final _StackEntry<K, V> last = stack2[stack2.length - 1];
            switch (last.dir) {
              case _Dir.Left:
                last.node.left = newChild;
                break;
              case _Dir.Mid:
              case _Dir.Right:
                asserts.assertCondition(false);
                break;
            }
          } else {
            node.right = newChild;
          }

          final TernarySearchTreeNode<K, V>? newChild2 = _balanceByStack(stack2);
          if (stack.isNotEmpty) {
            final _StackEntry<K, V> last = stack[stack.length - 1];
            switch (last.dir) {
              case _Dir.Left:
                last.node.left = newChild2;
                break;
              case _Dir.Mid:
                last.node.mid = newChild2;
                break;
              case _Dir.Right:
                last.node.right = newChild2;
                break;
            }
          } else {
            _root = newChild2;
          }
        }
      } else {
        // empty or half empty
        final TernarySearchTreeNode<K, V>? newChild = node.left ?? node.right;
        if (stack.isNotEmpty) {
          final _StackEntry<K, V> last = stack[stack.length - 1];
          switch (last.dir) {
            case _Dir.Left:
              last.node.left = newChild;
              break;
            case _Dir.Mid:
              last.node.mid = newChild;
              break;
            case _Dir.Right:
              last.node.right = newChild;
              break;
          }
        } else {
          _root = newChild;
        }
      }
    }

    // AVL balance
    _root = _balanceByStack(stack) ?? _root;
  }

  /// 1:1: `_min`
  TernarySearchTreeNode<K, V> _min(TernarySearchTreeNode<K, V> node,
      List<_StackEntry<K, V>> stack) {
    while (node.left != null) {
      stack.add(_StackEntry<K, V>(_Dir.Left, node));
      node = node.left!;
    }
    return node;
  }

  /// 1:1: `_balanceByStack`
  TernarySearchTreeNode<K, V>? _balanceByStack(List<_StackEntry<K, V>> stack) {
    for (int i = stack.length - 1; i >= 0; i--) {
      final TernarySearchTreeNode<K, V> node = stack[i].node;

      node.updateHeight();
      final int bf = node.balanceFactor();
      if (bf > 1) {
        // right heavy
        if (node.right!.balanceFactor() >= 0) {
          // right, right -> rotate left
          stack[i].node = node.rotateLeft();
        } else {
          // right, left -> double rotate
          node.right = node.right!.rotateRight();
          stack[i].node = node.rotateLeft();
        }
      } else if (bf < -1) {
        // left heavy
        if (node.left!.balanceFactor() <= 0) {
          // left, left -> rotate right
          stack[i].node = node.rotateRight();
        } else {
          // left, right -> double rotate
          node.left = node.left!.rotateLeft();
          stack[i].node = node.rotateRight();
        }
      }

      // patch path to parent
      if (i > 0) {
        switch (stack[i - 1].dir) {
          case _Dir.Left:
            stack[i - 1].node.left = stack[i].node;
            break;
          case _Dir.Right:
            stack[i - 1].node.right = stack[i].node;
            break;
          case _Dir.Mid:
            stack[i - 1].node.mid = stack[i].node;
            break;
        }
      } else {
        return stack[0].node;
      }
    }

    return null;
  }

  /// 1:1: `findSubstr`
  V? findSubstr(K key) {
    final IKeyIterator<K> iter = _iter.reset(key);
    TernarySearchTreeNode<K, V>? node = _root;
    Object? candidate;
    while (node != null) {
      final int val = iter.cmp(node.segment);
      if (val > 0) {
        node = node.left;
      } else if (val < 0) {
        node = node.right;
      } else if (iter.hasNext()) {
        iter.next();
        final Object? unwrapped = _undefUnwrap(node.value);
        if (_truthy(unwrapped)) {
          candidate = unwrapped;
        }
        node = node.mid;
      } else {
        break;
      }
    }
    final Object? atNode =
        node != null ? _undefUnwrap(node.value) : null;
    return (_truthy(atNode) ? atNode : candidate) as V?;
  }

  /// 1:1: `findSuperstr`
  Iterable<MapEntry<K, V>>? findSuperstr(K key) =>
      _findSuperstrOrElement(key, false) as Iterable<MapEntry<K, V>>?;

  /// 1:1: `_findSuperstrOrElement` (single implementation of both overloads).
  Object? _findSuperstrOrElement(K key, bool allowValue) {
    final IKeyIterator<K> iter = _iter.reset(key);
    TernarySearchTreeNode<K, V>? node = _root;
    while (node != null) {
      final int val = iter.cmp(node.segment);
      if (val > 0) {
        node = node.left;
      } else if (val < 0) {
        node = node.right;
      } else if (iter.hasNext()) {
        iter.next();
        node = node.mid;
      } else {
        if (node.mid == null) {
          return allowValue ? _undefUnwrap(node.value) : null;
        } else {
          return _entries(node.mid);
        }
      }
    }
    return null;
  }

  /// 1:1: `hasElementOrSubtree`
  bool hasElementOrSubtree(K key) =>
      _findSuperstrOrElement(key, true) != null;

  /// 1:1: `forEach`
  void forEach(void Function(V value, K index) callback) {
    for (final MapEntry<K, V> entry in entries) {
      callback(entry.value, entry.key);
    }
  }

  /// Dart carrier for the source `[Symbol.iterator]()`.
  Iterable<MapEntry<K, V>> get entries => _entries(_root);

  /// Allows `for (final e in tree)` without clashing with source `forEach`.
  Iterator<MapEntry<K, V>> get iterator => entries.iterator;

  /// Dart convenience carrier for `Iterable.toList()`.
  List<MapEntry<K, V>> toList() => entries.toList();

  /// 1:1: `_entries`
  Iterable<MapEntry<K, V>> _entries(TernarySearchTreeNode<K, V>? node) {
    final List<MapEntry<K, V>> result = <MapEntry<K, V>>[];
    _dfsEntries(node, result);
    return result;
  }

  /// 1:1: `_dfsEntries`
  void _dfsEntries(TernarySearchTreeNode<K, V>? node,
      List<MapEntry<K, V>> bucket) {
    if (node == null) {
      return;
    }
    if (node.left != null) {
      _dfsEntries(node.left, bucket);
    }
    if (node.value != null) {
      bucket.add(MapEntry<K, V>(node.key as K, _undefUnwrap(node.value) as V));
    }
    if (node.mid != null) {
      _dfsEntries(node.mid, bucket);
    }
    if (node.right != null) {
      _dfsEntries(node.right, bucket);
    }
  }

  /// 1:1: source `_isBalanced` (for debug/testing); public so tests can call it.
  bool isBalanced() => _nodeIsBalanced(_root);

  bool _nodeIsBalanced(TernarySearchTreeNode<K, V>? node) {
    if (node == null) {
      return true;
    }
    final int bf = node.balanceFactor();
    if (bf < -1 || bf > 1) {
      return false;
    }
    return _nodeIsBalanced(node.left) && _nodeIsBalanced(node.right);
  }
}
