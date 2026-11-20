import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

List<SemiCommitGraphNode> _sample() => [
  const SemiCommitGraphNode(id: 'worktree', uncommitted: true),
  const SemiCommitGraphNode(id: 'merge', parents: ['main2', 'feat2']),
  const SemiCommitGraphNode(id: 'feat2', parents: ['feat1']),
  const SemiCommitGraphNode(id: 'main2', parents: ['main1']),
  const SemiCommitGraphNode(id: 'feat1', parents: ['main1']),
  const SemiCommitGraphNode(id: 'main1'),
  const SemiCommitGraphNode(id: 'orphan'),
];

List<SemiGraphSegment> segs(SemiGraphRow row, int column) =>
    row.columns[column].map((s) => s.segment).toList();

void main() {
  test('one row per commit, in order', () {
    final rows = const SemiCommitGraphLayout().compute(_sample());
    expect(rows.length, 7);
    for (var i = 0; i < rows.length; i++) {
      expect(rows[i].node, _sample()[i]);
    }
  });

  test('merge commit gets two lanes', () {
    final rows = const SemiCommitGraphLayout().compute(_sample());
    expect(rows[1].node.id, 'merge');
    expect(rows[1].columns.length, 2);
  });

  test('uncommitted row is dashed and points into HEAD', () {
    final rows = const SemiCommitGraphLayout().compute(_sample());
    final row = rows[0];
    expect(row.columns.length, 1);
    expect(segs(row, 0), [
      SemiGraphSegment.bottom,
      SemiGraphSegment.dot,
    ]);
    expect(row.columns[0][0].color, const SemiCommitGraphLayout().taintedColor);
  });

  test('side branch routes back into the main lane', () {
    final rows = const SemiCommitGraphLayout().compute(_sample());
    // feat1 (lane 1) merges back toward main1 (lane 0).
    expect(segs(rows[4], 0), contains(SemiGraphSegment.rightIn));
    expect(segs(rows[4], 1), contains(SemiGraphSegment.leftOut));
  });

  test('root and orphan commits end on a single lane', () {
    final rows = const SemiCommitGraphLayout().compute(_sample());
    // main1 was registered as a parent lane one row earlier, so it keeps an
    // incoming Top segment; the orphan is a fresh root with only a dot.
    expect(rows[5].columns.length, 1);
    expect(segs(rows[5], 0), [SemiGraphSegment.top, SemiGraphSegment.dot]);
    expect(rows[6].columns.length, 1);
    expect(segs(rows[6], 0), [SemiGraphSegment.dot]);
  });

  test('graphVisible text-only path still aligns rows', () {
    // Layout is independent of visibility; hiding is a paint-time concern.
    final rows = const SemiCommitGraphLayout().compute(_sample());
    expect(rows.every((r) => r.columns.isNotEmpty), isTrue);
  });

  test('empty input yields no rows', () {
    expect(const SemiCommitGraphLayout().compute([]), isEmpty);
  });

  test('linear history keeps a single lane with vertical segments', () {
    final rows = const SemiCommitGraphLayout().compute([
      const SemiCommitGraphNode(id: 'c2', parents: ['c1']),
      const SemiCommitGraphNode(id: 'c1', parents: ['c0']),
      const SemiCommitGraphNode(id: 'c0'),
    ]);
    expect(rows.every((r) => r.columns.length == 1), isTrue);
    expect(segs(rows[0], 0), contains(SemiGraphSegment.dot));
    // The last root still has an incoming Top from the previous row's parent.
    expect(segs(rows[2], 0), [SemiGraphSegment.top, SemiGraphSegment.dot]);
  });

  test('theme default branch colors match Gittyup Dark palette', () {
    expect(kSemiGraphDefaultBranchColors.length, 15);
    expect(kSemiGraphDefaultBranchColors.first, const Color(0xFF53AFEC));
  });
}
