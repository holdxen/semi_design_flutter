// 1:1 translation of
// vscode/src/vs/editor/contrib/inlineCompletions/browser/model/graph.ts

/// 1:1: `class DirectedGraph<T>`
class DirectedGraph<T> {
  final Set<T> _nodes = <T>{};
  final Map<T, Set<T>> _outgoingEdges = <T, Set<T>>{};

  /// 1:1: `static from<T>(nodes, getOutgoing)`
  static DirectedGraph<T> from<T>(
      List<T> nodes, List<T> Function(T node) getOutgoing) {
    final DirectedGraph<T> graph = DirectedGraph<T>();

    for (final T node in nodes) {
      graph._nodes.add(node);
    }

    for (final T node in nodes) {
      final List<T> outgoing = getOutgoing(node);
      if (outgoing.isNotEmpty) {
        final Set<T> outgoingSet = <T>{};
        for (final T target in outgoing) {
          outgoingSet.add(target);
        }
        graph._outgoingEdges[node] = outgoingSet;
      }
    }

    return graph;
  }

  /// After this, the graph is guaranteed to have no cycles.
  /// 1:1: `removeCycles(): { foundCycles: T[] }`
  Map<String, dynamic> removeCycles() {
    final List<T> foundCycles = <T>[];
    final Set<T> visited = <T>{};
    final Set<T> recursionStack = <T>{};
    final List<MapEntry<T, T>> toRemove = <MapEntry<T, T>>[];

    void dfs(T node) {
      visited.add(node);
      recursionStack.add(node);

      final Set<T>? outgoing = _outgoingEdges[node];
      if (outgoing != null) {
        for (final T neighbor in outgoing) {
          if (!visited.contains(neighbor)) {
            dfs(neighbor);
          } else if (recursionStack.contains(neighbor)) {
            // Found a cycle
            foundCycles.add(neighbor);
            toRemove.add(MapEntry<T, T>(node, neighbor));
          }
        }
      }

      recursionStack.remove(node);
    }

    // Run DFS from all unvisited nodes
    for (final T node in _nodes) {
      if (!visited.contains(node)) {
        dfs(node);
      }
    }

    // Remove edges that cause cycles
    for (final MapEntry<T, T> entry in toRemove) {
      final Set<T>? outgoingSet = _outgoingEdges[entry.key];
      if (outgoingSet != null) {
        outgoingSet.remove(entry.value);
      }
    }

    return <String, dynamic>{'foundCycles': foundCycles};
  }

  /// 1:1: `getOutgoing(node): readonly T[]`
  List<T> getOutgoing(T node) {
    final Set<T>? outgoing = _outgoingEdges[node];
    return outgoing != null ? List<T>.from(outgoing) : <T>[];
  }
}
