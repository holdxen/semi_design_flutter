// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/test/browser/graph.test.ts
// Translated 1:1. The mocha suite's active cases become Dart functions.
// `removeCycles()` returns a Map carrier `{foundCycles: List<T>}`; `T` is
// instantiated to String or int per case.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../browser/model/graph.dart' show DirectedGraph;

bool _listEq(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

List<Object?> _num(List<Object?> list) {
  final List<Object?> copy = List<Object?>.from(list);
  copy.sort((Object? a, Object? b) => (a as Comparable).compareTo(b));
  return copy;
}

List<String> Function(String) _strOutgoingA() => (String node) {
      switch (node) {
        case 'a':
          return <String>['b', 'c'];
        case 'b':
          return <String>['c'];
        case 'c':
          return <String>[];
        default:
          return <String>[];
      }
    };

void testFromEmptyGraph() {
  final DirectedGraph<String> graph = DirectedGraph.from<String>([], (node) => <String>[]);
  assert(graph.getOutgoing('a').isEmpty);
}

void testFromSingleNode() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a'], (node) => <String>[]);
  assert(graph.getOutgoing('a').isEmpty);
}

void testFromNodesAndEdges() {
  final DirectedGraph<String> graph =
      DirectedGraph.from(['a', 'b', 'c'], _strOutgoingA());
  assert(_listEq(_num(graph.getOutgoing('a')), <Object?>['b', 'c']));
  assert(_listEq(graph.getOutgoing('b'), <Object?>['c']));
  assert(_listEq(graph.getOutgoing('c'), <Object?>[]));
}

void testFromDuplicateEdges() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a', 'b'], (String node) {
    switch (node) {
      case 'a':
        return <String>['b', 'b'];
      case 'b':
        return <String>[];
      default:
        return <String>[];
    }
  });
  assert(_listEq(graph.getOutgoing('a'), <Object?>['b']));
  assert(_listEq(graph.getOutgoing('b'), <Object?>[]));
}

void testRemoveCyclesNoCycles() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a', 'b', 'c'], (String node) {
    switch (node) {
      case 'a':
        return <String>['b'];
      case 'b':
        return <String>['c'];
      case 'c':
        return <String>[];
      default:
        return <String>[];
    }
  });
  final Map<String, dynamic> result = graph.removeCycles();
  assert(_listEq(result['foundCycles'] as List, <Object?>[]));
  assert(_listEq(graph.getOutgoing('a'), <Object?>['b']));
  assert(_listEq(graph.getOutgoing('b'), <Object?>['c']));
  assert(_listEq(graph.getOutgoing('c'), <Object?>[]));
}

void testRemoveCyclesSimpleCycle() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a', 'b'], (String node) {
    switch (node) {
      case 'a':
        return <String>['b'];
      case 'b':
        return <String>['a'];
      default:
        return <String>[];
    }
  });
  final Map<String, dynamic> result = graph.removeCycles();
  final List found = result['foundCycles'] as List;
  assert(found.length == 1);
  assert(found.contains('a') || found.contains('b'));

  final List aOutgoing = graph.getOutgoing('a');
  final List bOutgoing = graph.getOutgoing('b');
  assert((aOutgoing.isEmpty && bOutgoing.length == 1) ||
      (aOutgoing.length == 1 && bOutgoing.isEmpty));
}

void testRemoveCyclesSelfLoop() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a'], (String node) {
    switch (node) {
      case 'a':
        return <String>['a'];
      default:
        return <String>[];
    }
  });
  final Map<String, dynamic> result = graph.removeCycles();
  assert(_listEq(result['foundCycles'] as List, <Object?>['a']));
  assert(_listEq(graph.getOutgoing('a'), <Object?>[]));
}

void testRemoveCyclesComplexCycle() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a', 'b', 'c', 'd'], (String node) {
    switch (node) {
      case 'a':
        return <String>['b'];
      case 'b':
        return <String>['c'];
      case 'c':
        return <String>['d', 'a'];
      case 'd':
        return <String>[];
      default:
        return <String>[];
    }
  });
  final Map<String, dynamic> result = graph.removeCycles();
  assert((result['foundCycles'] as List).length >= 1);
  assert(!graph.getOutgoing('c').contains('a'));
}

void testRemoveCyclesMultipleDisconnected() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a', 'b', 'c', 'd'], (String node) {
    switch (node) {
      case 'a':
        return <String>['b'];
      case 'b':
        return <String>['a'];
      case 'c':
        return <String>['d'];
      case 'd':
        return <String>['c'];
      default:
        return <String>[];
    }
  });
  final Map<String, dynamic> result = graph.removeCycles();
  assert((result['foundCycles'] as List).length >= 2);

  final List aOutgoing = graph.getOutgoing('a');
  final List bOutgoing = graph.getOutgoing('b');
  final List cOutgoing = graph.getOutgoing('c');
  final List dOutgoing = graph.getOutgoing('d');
  assert((aOutgoing.isEmpty && bOutgoing.length == 1) ||
      (aOutgoing.length == 1 && bOutgoing.isEmpty));
  assert((cOutgoing.isEmpty && dOutgoing.length == 1) ||
      (cOutgoing.length == 1 && dOutgoing.isEmpty));
}

void testGetOutgoingNonExistentNode() {
  final DirectedGraph<String> graph = DirectedGraph.from(['a'], (node) => <String>[]);
  assert(graph.getOutgoing('b').isEmpty);
}

void testWithNumberNodes() {
  final DirectedGraph<int> graph = DirectedGraph.from([1, 2, 3], (int node) {
    switch (node) {
      case 1:
        return <int>[2, 3];
      case 2:
        return <int>[3];
      case 3:
        return <int>[];
      default:
        return <int>[];
    }
  });
  assert(_listEq(_num(graph.getOutgoing(1)), <Object?>[2, 3]));
  assert(_listEq(graph.getOutgoing(2), <Object?>[3]));
  assert(_listEq(graph.getOutgoing(3), <Object?>[]));
}

void runAll() {
  testFromEmptyGraph();
  testFromSingleNode();
  testFromNodesAndEdges();
  testFromDuplicateEdges();
  testRemoveCyclesNoCycles();
  testRemoveCyclesSimpleCycle();
  testRemoveCyclesSelfLoop();
  testRemoveCyclesComplexCycle();
  testRemoveCyclesMultipleDisconnected();
  testGetOutgoingNonExistentNode();
  testWithNumberNodes();
}
