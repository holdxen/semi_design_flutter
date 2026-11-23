// 1:1 translation of vscode/src/vs/platform/instantiation/common/graph.ts

/// 1:1: `class Node<T>`
class Node<T> {
  final Map<String, Node<T>> incoming = <String, Node<T>>{};
  final Map<String, Node<T>> outgoing = <String, Node<T>>{};

  final String key;
  final T data;

  Node(this.key, this.data);
}

/// 1:1: `class Graph<T>`
class Graph<T> {
  final Map<String, Node<T>> _nodes = <String, Node<T>>{};

  final String Function(T element) _hashFn;

  Graph(this._hashFn);

  /// 1:1: `roots(): Node<T>[]`
  List<Node<T>> roots() {
    final List<Node<T>> ret = <Node<T>>[];
    for (final Node<T> node in _nodes.values) {
      if (node.outgoing.isEmpty) {
        ret.add(node);
      }
    }
    return ret;
  }

  /// 1:1: `insertEdge(from, to)`
  void insertEdge(T from, T to) {
    final Node<T> fromNode = lookupOrInsertNode(from);
    final Node<T> toNode = lookupOrInsertNode(to);

    fromNode.outgoing[toNode.key] = toNode;
    toNode.incoming[fromNode.key] = fromNode;
  }

  /// 1:1: `removeNode(data)`
  void removeNode(T data) {
    final String key = _hashFn(data);
    _nodes.remove(key);
    for (final Node<T> node in _nodes.values) {
      node.outgoing.remove(key);
      node.incoming.remove(key);
    }
  }

  /// 1:1: `lookupOrInsertNode(data)`
  Node<T> lookupOrInsertNode(T data) {
    final String key = _hashFn(data);
    Node<T>? node = _nodes[key];

    if (node == null) {
      node = Node<T>(key, data);
      _nodes[key] = node;
    }

    return node;
  }

  /// 1:1: `lookup(data): Node<T> | undefined`
  Node<T>? lookup(T data) => _nodes[_hashFn(data)];

  /// 1:1: `isEmpty(): boolean`
  bool isEmpty() => _nodes.isEmpty;

  /// 1:1: `toString()`
  @override
  String toString() {
    final List<String> data = <String>[];
    for (final MapEntry<String, Node<T>> entry in _nodes.entries) {
      final String key = entry.key;
      final Node<T> value = entry.value;
      data.add('$key\n\t(-> incoming)[${value.incoming.keys.join(', ')}]\n\t(outgoing ->)[${value.outgoing.keys.join(',')}]\n');
    }
    return data.join('\n');
  }

  /// This is brute force and slow and **only** to be used to trouble shoot.
  /// 1:1: `findCycleSlow()`
  String? findCycleSlow() {
    for (final MapEntry<String, Node<T>> entry in _nodes.entries) {
      final String id = entry.key;
      final Set<String> seen = <String>{id};
      final String? res = _findCycle(entry.value, seen);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  /// 1:1: `_findCycle(node, seen)`
  String? _findCycle(Node<T> node, Set<String> seen) {
    for (final MapEntry<String, Node<T>> entry in node.outgoing.entries) {
      final String id = entry.key;
      final Node<T> outgoing = entry.value;
      if (seen.contains(id)) {
        return [...seen, id].join(' -> ');
      }
      seen.add(id);
      final String? value = _findCycle(outgoing, seen);
      if (value != null) {
        return value;
      }
      seen.remove(id);
    }
    return null;
  }
}
