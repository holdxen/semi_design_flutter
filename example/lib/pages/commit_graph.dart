import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Gallery page for the ported git commit graph widget.
class CommitGraphPage extends StatefulWidget {
  const CommitGraphPage({super.key});

  @override
  State<CommitGraphPage> createState() => _CommitGraphPageState();
}

class _CommitGraphPageState extends State<CommitGraphPage> {
  String _selected = '点击某个提交查看详情';

  // Topological order: children before parents (git log --topo-order).
  static final List<SemiCommitGraphNode> _commits = [
    const SemiCommitGraphNode(id: 'worktree', uncommitted: true, summary: ''),
    const SemiCommitGraphNode(
      id: 'a7f3c2e9d41b',
      shortId: 'a7f3c2e',
      summary: 'Merge branch \'feature/login\' into main',
      author: 'Alice',
      timestamp: '2026-11-20 18:02',
      refs: ['main'],
      parents: ['main2c83', 'feat2b91'],
    ),
    const SemiCommitGraphNode(
      id: 'feat2b91',
      shortId: 'feat2b9',
      summary: 'Add JWT refresh token',
      author: 'Bob',
      timestamp: '17:40',
      refs: ['feature/login'],
      parents: ['feat1a70'],
    ),
    const SemiCommitGraphNode(
      id: 'main2c83',
      shortId: 'main2c8',
      summary: 'Fix navigation bar overflow',
      author: 'Alice',
      timestamp: '16:15',
      parents: ['main1f04'],
    ),
    const SemiCommitGraphNode(
      id: 'feat1a70',
      shortId: 'feat1a7',
      summary: 'Start login feature',
      author: 'Bob',
      timestamp: '15:50',
      parents: ['main1f04'],
    ),
    const SemiCommitGraphNode(
      id: 'main1f04',
      shortId: 'main1f0',
      summary: 'Initial commit',
      author: 'Alice',
      timestamp: '2026-11-19',
      refs: ['v1.0'],
    ),
    const SemiCommitGraphNode(
      id: 'orph9d2',
      shortId: 'orph9d2',
      summary: 'Docs: standalone gh-pages root',
      author: 'Carol',
      timestamp: '2026-11-18',
      refs: ['gh-pages'],
    ),
  ];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('提交历史图', [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: SemiTheme.of(context).colors.colorBorder,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SemiCommitGraph(
                key: const ValueKey('commit-graph-basic'),
                commits: _commits,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onCommitSelected: (node) =>
                    setState(() => _selected = '${node.shortId} · ${node.summary}'),
              ),
            ),
            const SizedBox(height: 12),
            SemiText(_selected, type: SemiTextType.secondary),
          ]),
          const SizedBox(height: 40),
          _section('隐藏 graph 列', [
            SizedBox(
              height: 220,
              child: SemiCommitGraph(
                key: const ValueKey('commit-graph-no-graph'),
                commits: _commits,
                graphVisible: false,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
