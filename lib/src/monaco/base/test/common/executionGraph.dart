// 1:1 port of vs/base/test/common/executionGraph.ts

/// JS number stringification (integer-valued doubles drop `.0`).
String _n(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble() && value.abs() < 1e21) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// JS `Math.round` rounds half toward +Infinity; Dart `.round()` rounds half
/// away from zero. Reproduce JS semantics exactly.
int _jsRound(num value) => (value + 0.5).floor();

/// JS `${value}` stringification for the scalar/object carriers used here.
String _jsString(Object? value) {
  if (value is num) return _n(value);
  return value.toString();
}

class ExecutionRoot {
  final String label;

  ExecutionRoot(this.label);
}

class ExecutionEvent {
  /** Relative time (e.g. ms since startTime). Must be >= 0 and non-decreasing. */
  final num time;
  final String label;
  final ExecutionRoot root;
  /** `null` means this event is a direct child of its root. */
  final ExecutionEvent? parent;
  /** Caller frame extracted from the scheduling stack trace. */
  final String? detail;

  ExecutionEvent({
    required this.time,
    required this.label,
    required this.root,
    this.parent,
    this.detail,
  });
}

class ExecutionHistory {
  /** Roots in first-appearance order (column order for renderers). */
  final List<ExecutionRoot> roots;
  /** Events in time order. */
  final List<ExecutionEvent> events;

  ExecutionHistory({required this.roots, required this.events});
}

// -----------------------------------------------------------------------------
// Adapter: ScheduledTask[] -> ExecutionHistory
// -----------------------------------------------------------------------------

class TraceRootLike {
  final String label;
  TraceRootLike(this.label);
}

class TraceLike {
  final TraceLike? parent;
  final TraceRootLike root;

  TraceLike(this.parent, this.root);
}

class ScheduledTaskLike {
  final num time;
  final Object source;
  final String? stackTrace;
  final TraceLike? trace;

  ScheduledTaskLike({
    required this.time,
    required this.source,
    this.stackTrace,
    this.trace,
  });
}

class LogEntryLike {
  final TraceLike trace;
  final String message;

  LogEntryLike({required this.trace, required this.message});
}

ExecutionHistory buildHistoryFromTasks(
  List<ScheduledTaskLike> tasks,
  num startTime, [
  List<LogEntryLike> logs = const <LogEntryLike>[],
]) {
  final Map<Object, ExecutionRoot> rootByTrace = <Object, ExecutionRoot>{};
  final List<ExecutionRoot> roots = <ExecutionRoot>[];
  final Map<Object, ExecutionEvent> eventByTrace = <Object, ExecutionEvent>{};
  final List<ExecutionEvent> taskEvents = <ExecutionEvent>[];

  for (final ScheduledTaskLike task in tasks) {
    final TraceLike? trace = task.trace;
    if (trace == null) {
      continue;
    }

    ExecutionRoot? root = rootByTrace[trace.root];
    if (root == null) {
      root = ExecutionRoot(trace.root.label);
      rootByTrace[trace.root] = root;
      roots.add(root);
    }

    // Find the parent event by walking up the trace chain until we hit
    // either a trace whose event we know, or the trace root.
    ExecutionEvent? parentEvent;
    for (TraceLike? p = trace.parent; p != null; p = p.parent) {
      final ExecutionEvent? e = eventByTrace[p];
      if (e != null) {
        parentEvent = e;
        break;
      }
    }

    final ExecutionEvent event = ExecutionEvent(
      time: task.time - startTime,
      label: _jsString(task.source),
      root: root,
      parent: parentEvent,
      detail: extractCallerFrame(task.stackTrace),
    );
    eventByTrace[trace] = event;
    taskEvents.add(event);
  }

  // Group log entries by their parent task event, preserving emission order.
  final Map<ExecutionEvent, List<ExecutionEvent>> logsByParent =
      <ExecutionEvent, List<ExecutionEvent>>{};
  for (final LogEntryLike entry in logs) {
    ExecutionEvent? parentEvent;
    for (TraceLike? p = entry.trace; p != null; p = p.parent) {
      final ExecutionEvent? e = eventByTrace[p];
      if (e != null) {
        parentEvent = e;
        break;
      }
    }
    if (parentEvent == null) {
      continue;
    }

    final ExecutionEvent logEvent = ExecutionEvent(
      time: parentEvent.time,
      label: 'log: ' + entry.message,
      root: parentEvent.root,
      parent: parentEvent,
    );
    final List<ExecutionEvent>? bucket = logsByParent[parentEvent];
    if (bucket != null) {
      bucket.add(logEvent);
    } else {
      logsByParent[parentEvent] = <ExecutionEvent>[logEvent];
    }
  }

  // Interleave: each task event followed by its logs in emission order.
  final List<ExecutionEvent> events = <ExecutionEvent>[];
  for (final ExecutionEvent e in taskEvents) {
    events.add(e);
    final List<ExecutionEvent>? ls = logsByParent[e];
    if (ls != null) {
      events.addAll(ls);
    }
  }

  return ExecutionHistory(roots: roots, events: events);
}

final List<RegExp> _skipFramePatterns = <RegExp>[
  RegExp(r'[\/]virtualScheduling[\/]'),
  RegExp(r'[\/]vs[\/]base[\/]common[\/]async\.'),
  RegExp(r'timeTravelScheduler'),
  RegExp(r'RunOnceScheduler\.schedule'),
  RegExp(r'scheduleAtNextAnimationFrame'),
  RegExp(r'TimeoutTimer\.cancelAndSet'),
  RegExp(r'TimeoutTimer\.setIfNotSet'),
  RegExp(r'timeoutDeferred'),
  RegExp(r'createTimeout'),
];

const int MAX_DETAIL_FRAMES = 5;

String? extractCallerFrame(String? stackTrace) {
  if (stackTrace == null) {
    return null;
  }
  final List<String> frames = <String>[];
  for (final String line in stackTrace.split('\n')) {
    final String trimmed = line.trim();
    if (!trimmed.startsWith('at ')) {
      continue;
    }
    if (_skipFramePatterns.any((RegExp p) => p.hasMatch(trimmed))) {
      continue;
    }
    frames.add(trimmed.substring(3));
    if (frames.length >= MAX_DETAIL_FRAMES) {
      break;
    }
  }
  return frames.isEmpty ? null : frames.join('\n');
}

// -----------------------------------------------------------------------------
// Renderer: swimlane (one column per root)
// -----------------------------------------------------------------------------

String renderSwimlanes(ExecutionHistory history) {
  final List<ExecutionRoot> roots = history.roots;
  final List<ExecutionEvent> events = history.events;
  if (events.isEmpty) {
    return '(empty history)';
  }
  if (roots.isEmpty) {
    return events.map((ExecutionEvent e) => '[+${_n(e.time)}ms] ${e.label}').join('\n');
  }

  final int n = events.length;

  // Parent index per event (-1 = direct child of root).
  final List<int> parentOf = List<int>.filled(n, -1);
  final List<List<int>> childrenOf = List<List<int>>.generate(n, (_) => <int>[]);
  final Map<ExecutionEvent, int> indexOfEvent = <ExecutionEvent, int>{};
  for (int i = 0; i < n; i++) {
    indexOfEvent[events[i]] = i;
  }
  for (int i = 0; i < n; i++) {
    final ExecutionEvent? p = events[i].parent;
    if (p != null) {
      final int? pi = indexOfEvent[p];
      if (pi != null) {
        parentOf[i] = pi;
        childrenOf[pi].add(i);
      }
    }
  }

  // Is this event the last child of its parent event?
  final List<bool> isLastChild = List<bool>.filled(n, false);
  for (int i = 0; i < n; i++) {
    final int p = parentOf[i];
    if (p >= 0 && childrenOf[p][childrenOf[p].length - 1] == i) {
      isLastChild[i] = true;
    }
  }

  const int COLLAPSE_DEPTH_THRESHOLD = 6;
  final List<int> depthOf = List<int>.filled(n, 0);
  final List<int> slotOf = List<int>.filled(n, 0);
  for (int i = 0; i < n; i++) {
    final int p = parentOf[i];
    if (p >= 0) {
      depthOf[i] = depthOf[p] + 1;
      final bool collapse = isLastChild[i] && depthOf[i] >= COLLAPSE_DEPTH_THRESHOLD;
      slotOf[i] = slotOf[p] + (collapse ? 0 : 1);
    }
  }

  // Display label = label plus the caller stack frame when present.
  final List<String> displayLabelOf = List<String>.filled(n, '');
  final List<List<String>> detailLinesOf = List<List<String>>.filled(n, const <String>[]);
  for (int i = 0; i < n; i++) {
    final ExecutionEvent e = events[i];
    final List<String> frames = e.detail != null ? e.detail!.split('\n') : <String>[];
    displayLabelOf[i] = frames.isNotEmpty ? '${e.label} · ${frames[0]}' : e.label;
    // JS `[].slice(1)` returns [] rather than throwing (Dart sublist clamps).
    detailLinesOf[i] = frames.length > 1 ? frames.sublist(1) : <String>[];
  }

  // Column width per root (slot-based).
  final Map<ExecutionRoot, int> widthOf = <ExecutionRoot, int>{};
  for (final ExecutionRoot r in roots) {
    widthOf[r] = r.label.length;
  }
  for (int i = 0; i < n; i++) {
    final int baseIndent = slotOf[i] * 3 + 3;
    int maxLen = displayLabelOf[i].length;
    for (final String l in detailLinesOf[i]) {
      final int ll = l.length + 2;
      if (ll > maxLen) {
        maxLen = ll;
      }
    }
    final int w = baseIndent + maxLen;
    final int cur = widthOf[events[i].root] ?? 0;
    if (w > cur) {
      widthOf[events[i].root] = w;
    }
  }

  // Compute time column width based on max time (rounded).
  int maxTime = 0;
  if (n > 0) {
    maxTime = events.map((ExecutionEvent e) => _jsRound(e.time)).reduce((a, b) => a > b ? a : b);
  }
  final int timeColWidth = ('+' + maxTime.toString() + 'ms').length;

  final List<String> lines = <String>[];

  // Header: root labels centered in their columns.
  final List<String> header = <String>[];
  for (final ExecutionRoot r in roots) {
    final int w = widthOf[r]!;
    header.add(r.label.padLeft(((w + r.label.length) / 2).ceil()).padRight(w));
  }
  lines.add((' ' * timeColWidth + ' ' + header.join('  ')).trimRight());

  // Compute lastChild index for each event (for drawing continuation lines).
  final List<int> lastChildOf = List<int>.filled(n, -1);
  for (int i = 0; i < n; i++) {
    final List<int> kids = childrenOf[i];
    if (kids.isNotEmpty) {
      lastChildOf[i] = kids[kids.length - 1];
    }
  }

  // Per-root: set of "active ancestor" event indices.
  final Map<ExecutionRoot, Set<int>> laneStacks = <ExecutionRoot, Set<int>>{};
  for (final ExecutionRoot r in roots) {
    laneStacks[r] = <int>{};
  }

  for (int i = 0; i < n; i++) {
    final ExecutionEvent event = events[i];
    final String timeStr = ('+' + _jsRound(event.time).toString() + 'ms').padLeft(timeColWidth);

    final List<String> parts = <String>[];
    for (final ExecutionRoot r in roots) {
      final int w = widthOf[r]!;
      final Set<int> stack = laneStacks[r]!;

      if (r == event.root) {
        final int slot = slotOf[i];
        final List<String> indent = <String>[];
        for (int s = 0; s < slot; s++) {
          bool hasActive = false;
          for (final int a in stack) {
            if (slotOf[a] == s && lastChildOf[a] > i) {
              hasActive = true;
              break;
            }
          }
          indent.add(hasActive ? '│  ' : '   ');
        }
        final String prefix = isLastChild[i] ? '└─ ' : '├─ ';
        parts.add((indent.join('') + prefix + displayLabelOf[i]).padRight(w));
      } else {
        final List<int> activeSlots = <int>[];
        for (final int a in stack) {
          if (lastChildOf[a] > i) {
            activeSlots.add(slotOf[a]);
          }
        }
        int maxSlot = -1;
        for (final int s in activeSlots) {
          if (s > maxSlot) {
            maxSlot = s;
          }
        }
        final List<String> chars = List<String>.filled(maxSlot + 1 > 0 ? maxSlot + 1 : 0, '   ', growable: true);
        for (final int s in activeSlots) {
          chars[s] = '│  ';
        }

        // Find the next event in root r strictly after i.
        int nextJ = -1;
        for (int j = i + 1; j < n; j++) {
          if (events[j].root == r) {
            nextJ = j;
            break;
          }
        }
        if (nextJ >= 0 && parentOf[nextJ] >= 0) {
          final int s = slotOf[nextJ];
          if (!isLastChild[nextJ]) {
            while (chars.length <= s) {
              chars.add('   ');
            }
            if (chars[s] == '   ') {
              chars[s] = '|  ';
            }
          }
        }

        while (chars.isNotEmpty && chars[chars.length - 1] == '   ') {
          chars.removeLast();
        }
        parts.add(chars.join('').padRight(w));
      }
    }

    lines.add((timeStr + ' ' + parts.join('  ')).trimRight());

    // Continuation lines for any extra stack frames.
    final List<String> extras = detailLinesOf[i];
    if (extras.isNotEmpty) {
      final int slot = slotOf[i];
      final Set<int> stackForExtras = laneStacks[event.root]!;
      final bool hasOpenChildren = childrenOf[i].isNotEmpty;
      final List<String> extraIndent = <String>[];
      for (int s = 0; s < slot; s++) {
        bool hasActive = false;
        for (final int a in stackForExtras) {
          if (slotOf[a] == s && lastChildOf[a] > i) {
            hasActive = true;
            break;
          }
        }
        extraIndent.add(hasActive ? '│  ' : '   ');
      }
      extraIndent.add(hasOpenChildren ? '│  ' : '   ');
      for (final String extra in extras) {
        final List<String> extrasParts = <String>[];
        for (final ExecutionRoot r in roots) {
          final int w = widthOf[r]!;
          if (r == event.root) {
            extrasParts.add((extraIndent.join('') + extra).padRight(w));
          } else {
            final Set<int> otherStack = laneStacks[r]!;
            final List<int> activeSlots = <int>[];
            for (final int a in otherStack) {
              if (lastChildOf[a] > i) {
                activeSlots.add(slotOf[a]);
              }
            }
            int maxSlot = -1;
            for (final int s in activeSlots) {
              if (s > maxSlot) {
                maxSlot = s;
              }
            }
            final List<String> chars =
                List<String>.filled(maxSlot + 1 > 0 ? maxSlot + 1 : 0, '   ', growable: true);
            for (final int s in activeSlots) {
              chars[s] = '│  ';
            }
            while (chars.isNotEmpty && chars[chars.length - 1] == '   ') {
              chars.removeLast();
            }
            extrasParts.add(chars.join('').padRight(w));
          }
        }
        final String timePad = ' ' * timeColWidth;
        lines.add((timePad + ' ' + extrasParts.join('  ')).trimRight());
      }
    }

    // Stack maintenance.
    final Set<int> stack = laneStacks[event.root]!;
    if (childrenOf[i].isNotEmpty) {
      stack.add(i);
    }
    int cur = i;
    while (isLastChild[cur]) {
      final int p = parentOf[cur];
      if (p < 0) {
        break;
      }
      stack.remove(p);
      cur = p;
    }
  }

  return lines.join('\n');
}

// -----------------------------------------------------------------------------
// Renderer: interleaved lane graph (git-log style)
// -----------------------------------------------------------------------------

class _LaneNode {
  final String label;
  final _LaneNode? parent;
  final bool isSynthetic;

  const _LaneNode(this.label, this.parent, this.isSynthetic);
}

String renderLaneGraph(ExecutionHistory history) {
  final List<ExecutionEvent> events = history.events;
  if (events.isEmpty) {
    return '';
  }

  final List<_LaneNode> nodes = <_LaneNode>[];
  final Map<ExecutionRoot, _LaneNode> syntheticForRoot = <ExecutionRoot, _LaneNode>{};
  final Map<ExecutionEvent, _LaneNode> nodeByEvent = <ExecutionEvent, _LaneNode>{};

  // Which roots have at least one direct child event?
  final Set<ExecutionRoot> rootsWithChildren = <ExecutionRoot>{};
  for (final ExecutionEvent e in events) {
    if (e.parent == null) {
      rootsWithChildren.add(e.root);
    }
  }

  for (final ExecutionEvent e in events) {
    if (rootsWithChildren.contains(e.root) && !syntheticForRoot.containsKey(e.root)) {
      final _LaneNode syn = _LaneNode('+' + e.root.label, null, true);
      syntheticForRoot[e.root] = syn;
      nodes.add(syn);
    }
    final String timeStr = ('+' + _n(e.time) + 'ms').padLeft(7);
    final _LaneNode? parent =
        e.parent != null ? nodeByEvent[e.parent] : syntheticForRoot[e.root];
    final _LaneNode node = _LaneNode('[$timeStr] ${e.label}', parent, false);
    nodeByEvent[e] = node;
    nodes.add(node);
  }

  final int n = nodes.length;
  final List<int> parentOf = List<int>.filled(n, -1);
  final List<List<int>> childrenOf = List<List<int>>.generate(n, (_) => <int>[]);
  final Map<_LaneNode, int> indexOfNode = <_LaneNode, int>{};
  for (int i = 0; i < n; i++) {
    indexOfNode[nodes[i]] = i;
  }
  for (int i = 0; i < n; i++) {
    final _LaneNode? p = nodes[i].parent;
    if (p != null) {
      final int? pi = indexOfNode[p];
      if (pi != null) {
        parentOf[i] = pi;
        childrenOf[pi].add(i);
      }
    }
  }

  // Assign columns: every node with children gets its own column.
  final List<int> colOf = List<int>.filled(n, -1);
  int totalCols = 0;
  for (int i = 0; i < n; i++) {
    if (childrenOf[i].isNotEmpty) {
      colOf[i] = totalCols++;
    }
  }

  if (totalCols == 0) {
    return events
        .map((ExecutionEvent e) =>
            '[+' + (_n(e.time) + 'ms').padLeft(5) + '] ' + e.label)
        .join('\n');
  }

  final List<int> active = List<int>.filled(totalCols, -1);
  final List<String> lines = <String>[];

  for (int i = 0; i < n; i++) {
    final _LaneNode node = nodes[i];
    final int pIdx = parentOf[i];
    final int connectCol = pIdx >= 0 ? colOf[pIdx] : -1;
    final bool last = pIdx >= 0 && childrenOf[pIdx][childrenOf[pIdx].length - 1] == i;
    final int opensCol = childrenOf[i].isNotEmpty ? colOf[i] : -1;
    final int horizEnd = pIdx >= 0 ? (opensCol >= 0 ? opensCol : totalCols) : -1;

    final List<String> chars = <String>[];
    for (int c = 0; c < totalCols; c++) {
      final bool isActive = active[c] >= 0;
      final bool isConnect = c == connectCol;
      final bool isOpen = c == opensCol && !isConnect;
      final bool inHoriz = connectCol >= 0 && c > connectCol && c < horizEnd;

      late String g;
      late String s;
      if (isConnect) {
        g = last ? '└' : '├';
        s = '─';
      } else if (isOpen && node.isSynthetic) {
        g = '+';
        s = node.label.length > 1 ? node.label.substring(1, 2) : '?';
      } else if (isOpen && connectCol >= 0) {
        g = '╷';
        s = '─';
      } else if (isOpen) {
        g = '╷';
        s = ' ';
      } else if (inHoriz && isActive) {
        g = '┼';
        s = '─';
      } else if (inHoriz) {
        g = '─';
        s = '─';
      } else if (isActive) {
        g = '│';
        s = ' ';
      } else {
        g = ' ';
        s = ' ';
      }
      chars.add(g);
      chars.add(s);
    }

    if (last) {
      active[colOf[pIdx]] = -1;
    }
    if (opensCol >= 0) {
      active[opensCol] = i;
    }

    if (node.isSynthetic) {
      lines.add(chars.join('').trimRight());
    } else {
      lines.add(chars.join('') + node.label);
    }
  }

  return lines.join('\n');
}
