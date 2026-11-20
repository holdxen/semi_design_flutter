// Pure Dart port of Gittyup / GitAhead's commit graph layout algorithm.
// Original: src/ui/CommitList.cpp (CommitModel::columns/fetchRows/nextColor),
// Copyright (c) 2016 Scientific Toolworks, Inc., MIT license.
//
// Keep this file free of Flutter widget imports: it only needs dart:ui colors,
// so it stays trivially unit-testable and usable off the widget tree.

import 'dart:ui' show Color;

/// Plain description of one commit. Replaces `git::Commit` in the original.
///
/// [parents] holds parent ids in order (first entry is the first parent).
/// Commits must be supplied to [SemiCommitGraphLayout.compute] in topological
/// order — children before parents — which is what `git log --topo-order`
/// produces.
class SemiCommitGraphNode {
  const SemiCommitGraphNode({
    required this.id,
    this.shortId = '',
    this.summary = '',
    this.author = '',
    this.timestamp = '',
    this.refs = const [],
    this.parents = const [],
    this.uncommitted = false,
  });

  /// Stable unique id (e.g. the full 40-char hash).
  final String id;

  /// Short id shown in the list. Falls back to [id] when empty at paint time.
  final String shortId;

  /// Commit subject line.
  final String summary;

  /// Author name.
  final String author;

  /// Preformatted timestamp string (this widget does not format dates).
  final String timestamp;

  /// Branch / tag labels drawn next to the short id.
  final List<String> refs;

  /// Parent ids, in order. Empty means a root commit.
  final List<String> parents;

  /// Marks the "working tree changes" pseudo row (dashed lane).
  final bool uncommitted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiCommitGraphNode &&
          id == other.id &&
          shortId == other.shortId &&
          summary == other.summary &&
          author == other.author &&
          timestamp == other.timestamp &&
          _listEquals(refs, other.refs) &&
          _listEquals(parents, other.parents) &&
          uncommitted == other.uncommitted;

  @override
  int get hashCode => Object.hash(
        id,
        shortId,
        summary,
        author,
        timestamp,
        Object.hashAll(refs),
        Object.hashAll(parents),
        uncommitted,
      );
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The nine segment kinds drawn for branch topology (mirrors the C++ enum).
enum SemiGraphSegment {
  dot,
  top,
  middle,
  bottom,
  cross,
  leftIn,
  leftOut,
  rightIn,
  rightOut,
}

/// A single drawn segment and its resolved color.
class SemiGraphSegmentData {
  const SemiGraphSegmentData(this.segment, this.color);

  final SemiGraphSegment segment;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is SemiGraphSegmentData &&
      segment == other.segment &&
      color == other.color;

  @override
  int get hashCode => Object.hash(segment, color);
}

/// One lane slot in a row: the list of segments drawn in that slot.
typedef SemiGraphColumn = List<SemiGraphSegmentData>;

/// Layout result for a single commit row.
class SemiGraphRow {
  const SemiGraphRow(this.node, this.columns);

  final SemiCommitGraphNode node;
  final List<SemiGraphColumn> columns;
}

class _Parent {
  const _Parent(this.id, this.color, this.tainted, this.taintedColor);

  final String id;
  final Color color;
  final bool tainted;
  final Color taintedColor;

  /// A tainted lane uses the tainted color except on the exact commit it
  /// points at, where it joins back into the graph.
  Color effectiveColor(String forCommit) =>
      tainted && id != forCommit ? taintedColor : color;
}

/// Gittyup's `conf/themes/Dark.lua` graph.edge1 .. graph.edge15.
const List<Color> kSemiGraphDefaultBranchColors = <Color>[
  Color(0xFF53AFEC),
  Color(0xFF82DA2A),
  Color(0xFFDA2ADA),
  Color(0xFFDA822A),
  Color(0xFF2ADADA),
  Color(0xFFDA2A82),
  Color(0xFF84A896),
  Color(0xFF2ADA82),
  Color(0xFF822ADA),
  Color(0xFF66D1E0),
  Color(0xFFD3C27E),
  Color(0xFF95CB80),
  Color(0xFF50D4BE),
  Color(0xFF2ADA82),
  Color(0xFFDA822A),
];

/// Computes graph columns for every commit. Pure, synchronous, widget-free.
class SemiCommitGraphLayout {
  const SemiCommitGraphLayout({
    this.branchColors = kSemiGraphDefaultBranchColors,
    this.taintedColor = const Color(0xFF888888),
  });

  final List<Color> branchColors;
  final Color taintedColor;

  List<SemiGraphRow> compute(List<SemiCommitGraphNode> commits) {
    final rows = <SemiGraphRow>[];
    if (commits.isEmpty) return rows;

    // Guard against an empty palette so _nextColor can never loop forever.
    final colors = branchColors.isEmpty ? kSemiGraphDefaultBranchColors : branchColors;

    final parentsOf = <String, List<String>>{
      for (final commit in commits) commit.id: commit.parents,
    };
    final emitted = <String>{};
    final parents = <_Parent>[];

    for (var i = 0; i < commits.length; i++) {
      final commit = commits[i];

      // Uncommitted changes pseudo row: dashed lane into the next real commit.
      if (commit.uncommitted) {
        final row = <SemiGraphColumn>[
          <SemiGraphSegmentData>[
            SemiGraphSegmentData(SemiGraphSegment.bottom, taintedColor),
            SemiGraphSegmentData(SemiGraphSegment.dot, const Color(0x00000000)),
          ],
        ];
        String target = '';
        for (var j = i + 1; j < commits.length; j++) {
          if (!commits[j].uncommitted) {
            target = commits[j].id;
            break;
          }
        }
        parents.add(_Parent(
          target,
          _nextColor(parents, colors),
          true,
          taintedColor,
        ));
        rows.add(SemiGraphRow(commit, row));
        emitted.add(commit.id);
        continue;
      }

      // Give a root / newly pushed commit its own lane.
      var root = false;
      if (_indexOfParent(parents, commit.id) < 0) {
        root = true;
        parents.add(_Parent(commit.id, _nextColor(parents, colors), false, taintedColor));
      }

      final rowParents = List<_Parent>.from(parents);

      final replacements = <String>[];
      for (final parentId in commit.parents) {
        if (_indexOfParent(parents, parentId) < 0 &&
            !emitted.contains(parentId)) {
          replacements.add(parentId);
        }
      }

      final index = _indexOfParent(parents, commit.id);
      if (index >= 0) {
        final parent = parents.removeAt(index);
        if (replacements.isNotEmpty) {
          final replacement = replacements.removeAt(0);
          parents.insert(
            index,
            _Parent(replacement, parent.color, parent.tainted,
                parent.taintedColor),
          );
          for (final extra in replacements) {
            parents.add(_Parent(extra, _nextColor(parents, colors), false, taintedColor));
          }
        }
        // No replacements: the lane closes (root commit).
      }

      rows.add(SemiGraphRow(
        commit,
        _columns(commit.id, parentsOf[commit.id] ?? const [], rowParents,
            parents, root),
      ));
      emitted.add(commit.id);
    }

    return rows;
  }

  static Color _nextColor(List<_Parent> parents, List<Color> colors) {
    final counts = <Color, int>{};
    for (final parent in parents) {
      counts[parent.color] = (counts[parent.color] ?? 0) + 1;
    }
    var usage = 0;
    while (true) {
      for (final color in colors) {
        if ((counts[color] ?? 0) == usage) return color;
      }
      usage++;
    }
  }

  static int _indexOfParent(List<_Parent> parents, String id) {
    for (var i = 0; i < parents.length; i++) {
      if (parents[i].id == id) return i;
    }
    return -1;
  }

  /// The heart of the layout, ported 1:1 from `CommitModel::columns()`.
  static List<SemiGraphColumn> _columns(
    String commit,
    List<String> commitParents,
    List<_Parent> parents,
    List<_Parent> nextParents,
    bool root,
  ) {
    final count = parents.length;
    final columns = List<SemiGraphColumn>.generate(
      count,
      (_) => <SemiGraphSegmentData>[],
      growable: true,
    );

    // Incoming paths above the dot. A root has no path on its new lane.
    final incoming = root ? count - 1 : count;
    for (var i = 0; i < incoming; i++) {
      columns[i].add(SemiGraphSegmentData(
        SemiGraphSegment.top,
        parents[i].effectiveColor(commit),
      ));
    }

    // Outgoing paths below the dot toward each successor lane.
    for (var i = 0; i < count; i++) {
      final parent = parents[i];
      final List<String> successors = parent.id == commit
          ? commitParents
          : <String>[parent.id];

      for (final successor in successors) {
        final index = _indexOfParent(nextParents, successor);
        if (index < 0) continue;

        final single = successors.length == 1;
        final color = single
            ? parent.effectiveColor(commit)
            : nextParents[index].effectiveColor(commit);

        if (index < i) {
          columns[index].add(
              SemiGraphSegmentData(SemiGraphSegment.rightIn, color));
          for (var j = index + 1; j < i; j++) {
            columns[j].add(SemiGraphSegmentData(SemiGraphSegment.cross, color));
          }
          columns[i].add(SemiGraphSegmentData(SemiGraphSegment.leftOut, color));
        } else if (index > i) {
          columns[i].add(SemiGraphSegmentData(SemiGraphSegment.rightOut, color));
          for (var j = i + 1; j < index; j++) {
            columns[j].add(SemiGraphSegmentData(SemiGraphSegment.cross, color));
          }
          if (index == columns.length) {
            columns.add(<SemiGraphSegmentData>[]);
          }
          columns[index].add(SemiGraphSegmentData(SemiGraphSegment.leftIn, color));
        } else {
          columns[index].add(
              SemiGraphSegmentData(SemiGraphSegment.bottom, color));
        }
      }
    }

    // Middle section last: dot on the commit's own lane, plain vertical lines
    // on the others.
    for (var i = 0; i < count; i++) {
      final parent = parents[i];
      final dot = parent.id == commit;
      columns[i].add(SemiGraphSegmentData(
        dot ? SemiGraphSegment.dot : SemiGraphSegment.middle,
        parent.effectiveColor(commit),
      ));
    }

    return columns;
  }
}
