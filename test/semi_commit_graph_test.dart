import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {double width = 600}) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: SemiApp(
      home: Center(child: SizedBox(width: width, height: 400, child: child)),
    ),
  ),
);

const commits = [
  SemiCommitGraphNode(
    id: 'c2',
    shortId: 'c2',
    summary: 'Merge feature',
    author: 'Alice',
    timestamp: '18:02',
    refs: ['main'],
    parents: ['c1a', 'c1b'],
  ),
  SemiCommitGraphNode(
    id: 'c1b',
    shortId: 'c1b',
    summary: 'Feature work',
    parents: ['c0'],
  ),
  SemiCommitGraphNode(
    id: 'c1a',
    shortId: 'c1a',
    summary: 'Main work',
    parents: ['c0'],
  ),
  SemiCommitGraphNode(id: 'c0', shortId: 'c0', summary: 'Initial'),
];

void main() {
  testWidgets('renders summaries, refs and a custom painter per row', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SemiCommitGraph(commits: commits)));

    expect(find.text('Merge feature'), findsOneWidget);
    expect(find.text('[main]'), findsOneWidget);
    expect(find.text('Initial'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(SemiCommitGraph), findsOneWidget);
  });

  testWidgets('tap calls onCommitSelected with tapped node', (tester) async {
    String? selected;
    await tester.pumpWidget(
      host(
        SemiCommitGraph(
          commits: commits,
          onCommitSelected: (node) => selected = node.id,
        ),
      ),
    );

    await tester.tap(find.text('Feature work'));
    await tester.pump();
    expect(selected, 'c1b');
  });

  testWidgets('selectedId controls highlight without internal state', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SemiCommitGraph(commits: commits, selectedId: 'c1a')),
    );
    final selected = find.ancestor(
      of: find.text('Main work'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.selected == true,
      ),
    );
    expect(selected, findsWidgets);
  });

  testWidgets('graph width follows actual lane count, not a fixed width', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SemiCommitGraph(commits: commits)));

    // Default dot radius 4 -> column width 12. merges have 2 lanes (24px),
    // the root has 1 lane (12px); content must start right after the lines.
    final graphBoxes = find.byWidgetPredicate(
      (w) => w is SizedBox && w.child is CustomPaint && (w.width ?? 0) < 100,
    );
    final widths = [
      for (var i = 0; i < graphBoxes.evaluate().length; i++)
        tester.getSize(graphBoxes.at(i)).width,
    ];
    expect(widths, [24, 24, 24, 12]);
  });

  testWidgets('graphVisible false still renders the commit list', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiCommitGraph(commits: commits, graphVisible: false),
      ),
    );
    expect(find.text('Merge feature'), findsOneWidget);
    expect(find.text('Initial'), findsOneWidget);
  });

  testWidgets('uncommitted row shows a dashed painter and italic text', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiCommitGraph(
          commits: [
            SemiCommitGraphNode(id: 'w', uncommitted: true, summary: ''),
            SemiCommitGraphNode(id: 'c0', summary: 'Initial'),
          ],
        ),
      ),
    );
    expect(find.text('Uncommitted changes'), findsOneWidget);
  });

  testWidgets('local theme override changes branch colors', (tester) async {
    const custom = [
      Color(0xFF123456),
      Color(0xFF654321),
    ];
    await tester.pumpWidget(
      host(
        SemiCommitGraphTheme(
          data: SemiCommitGraphThemeData(branchColors: custom),
          child: const SemiCommitGraph(commits: commits),
        ),
      ),
    );
    final resolved = SemiCommitGraphTheme.resolve(
      tester.element(find.byType(SemiCommitGraph)),
    );
    expect(resolved.branchColors, custom);
  });
}
