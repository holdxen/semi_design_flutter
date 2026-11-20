import 'package:flutter/widgets.dart';

import '../theme/semi_commit_graph_theme.dart';
import '../theme/semi_commit_graph_theme_data.dart';
import 'commit_graph_layout.dart';

/// A Git commit-history graph widget, ported from Gittyup / GitAhead's
/// `CommitList` graph view. Renders the branch topology (dots, vertical lanes,
/// fork/merge curves, dashed uncommitted lane) computed by
/// [SemiCommitGraphLayout], next to each commit's summary and metadata.
///
/// Commits are supplied as plain data — no git library required. They must be
/// in topological order (children before parents), like `git log --topo-order`.
///
/// ```dart
/// SemiCommitGraph(
///   commits: [
///     SemiCommitGraphNode(id: 'c2', shortId: 'c2', summary: 'Merge', parents: ['c1a', 'c1b']),
///     SemiCommitGraphNode(id: 'c1b', shortId: 'c1b', summary: 'Feature', parents: ['c0']),
///     SemiCommitGraphNode(id: 'c1a', shortId: 'c1a', summary: 'Main', parents: ['c0']),
///     SemiCommitGraphNode(id: 'c0', shortId: 'c0', summary: 'Initial'),
///   ],
///   onCommitSelected: (node) => debugPrint(node.id),
/// )
/// ```
class SemiCommitGraph extends StatefulWidget {
  const SemiCommitGraph({
    super.key,
    required this.commits,
    this.onCommitSelected,
    this.graphVisible = true,
    this.selectedId,
    this.shrinkWrap = false,
    this.physics,
  });

  /// Commits in topological order (children before parents).
  final List<SemiCommitGraphNode> commits;

  /// Called when a row is tapped, with the tapped commit.
  final ValueChanged<SemiCommitGraphNode>? onCommitSelected;

  /// Hide the graph lanes and show only the commit list.
  final bool graphVisible;

  /// Externally controlled selected commit id. When null the widget manages
  /// its own selection internally.
  final String? selectedId;

  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  State<SemiCommitGraph> createState() => _SemiCommitGraphState();
}

class _SemiCommitGraphState extends State<SemiCommitGraph> {
  String? _internalSelection;

  String? get _selection => widget.selectedId ?? _internalSelection;

  void _select(SemiCommitGraphNode node) {
    if (widget.selectedId == null) {
      setState(() => _internalSelection = node.id);
    }
    widget.onCommitSelected?.call(node);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiCommitGraphTheme.resolve(context);
    final layout = SemiCommitGraphLayout(
      branchColors: theme.branchColors,
      taintedColor: theme.taintedColor,
    );
    final rows = layout.compute(widget.commits);

    final rowHeight = theme.rowHeight ?? 56.0;
    // Column width is derived from the dot radius the same way the C++ code
    // derives it from the font ascent (r = w/3).
    final columnWidth = theme.dotRadius * 3;

    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: rows.length,
      itemBuilder: (context, index) => _CommitGraphRow(
        row: rows[index],
        theme: theme,
        selected: rows[index].node.id == _selection,
        graphVisible: widget.graphVisible,
        rowHeight: rowHeight,
        columnWidth: columnWidth,
        onTap: () => _select(rows[index].node),
      ),
    );
  }
}

class _CommitGraphRow extends StatelessWidget {
  const _CommitGraphRow({
    required this.row,
    required this.theme,
    required this.selected,
    required this.graphVisible,
    required this.rowHeight,
    required this.columnWidth,
    required this.onTap,
  });

  final SemiGraphRow row;
  final SemiResolvedCommitGraphThemeData theme;
  final bool selected;
  final bool graphVisible;
  final double rowHeight;
  final double columnWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final node = row.node;
    final background = selected ? theme.selectionColor : theme.backgroundColor;
    // Qt advances the text rect by exactly one column width per active lane
    // (`rect.setX(x + w)`), so the content sits snug against the last line.
    final graphWidth = columnWidth * row.columns.length;

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (graphVisible)
          SizedBox(
            width: graphWidth,
            child: CustomPaint(
              painter: _CommitGraphPainter(
                columns: row.columns,
                theme: theme,
                columnWidth: columnWidth,
              ),
            ),
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              // Qt: rect starts at +2, each lane advances by w, then +hMargin.
              left: theme.horizontalPadding + 2,
              right: theme.horizontalPadding,
              top: 6,
              bottom: 6,
            ),
            child: node.uncommitted
                ? Center(
                    child: Text(
                      node.summary.isEmpty ? 'Uncommitted changes' : node.summary,
                      style: TextStyle(
                        color: theme.metaColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              node.summary,
                              style: TextStyle(
                                color: theme.messageColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (node.author.isNotEmpty || node.timestamp.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                [
                                  node.author,
                                  node.timestamp,
                                ].where((s) => s.isNotEmpty).join('  '),
                                style: TextStyle(
                                  color: theme.metaColor,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            node.shortId.isEmpty
                                ? (node.id.length > 7
                                    ? node.id.substring(0, 7)
                                    : node.id)
                                : node.shortId,
                            style: TextStyle(
                              color: theme.metaColor,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          for (final ref in node.refs) ...[
                            const SizedBox(width: 6),
                            Text(
                              '[$ref]',
                              style: TextStyle(
                                color: theme.refColor,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: '${node.summary}, ${node.id}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: rowHeight,
          color: background,
          child: content,
        ),
      ),
    );
  }
}

/// Paints the graph segments. Direct port of `CommitDelegate::paint`'s
/// "Draw graph" block, using dart:ui Canvas instead of QPainter.
class _CommitGraphPainter extends CustomPainter {
  _CommitGraphPainter({
    required this.columns,
    required this.theme,
    required this.columnWidth,
  });

  final List<SemiGraphColumn> columns;
  final SemiResolvedCommitGraphThemeData theme;
  final double columnWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final h2 = h / 2;
    final h4 = h / 4;
    final r = theme.dotRadius;
    final w = columnWidth;

    final dotPaint = Paint()
      ..color = theme.dotColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < columns.length; i++) {
      final x = i * w;
      final x1 = x + w / 2;
      final x2 = x + w;
      final y1 = h2 - r;
      final y2 = h2;
      final y3 = h2 + r;
      final y4 = h2 + h4;
      final y5 = h;

      for (final segment in columns[i]) {
        final color = segment.color;
        final dashed = color == theme.taintedColor;
        final linePaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.lineWidth
          ..strokeCap = StrokeCap.round;
        switch (segment.segment) {
          case SemiGraphSegment.dot:
            canvas.drawCircle(Offset(x1, y2), r, dotPaint);
            break;
          case SemiGraphSegment.top:
            _line(canvas, x1, 0, x1, y1, linePaint, dashed);
            break;
          case SemiGraphSegment.middle:
            _line(canvas, x1, y1, x1, y3, linePaint, dashed);
            break;
          case SemiGraphSegment.bottom:
            _line(canvas, x1, y3, x1, y5, linePaint, dashed);
            break;
          case SemiGraphSegment.cross:
            _line(canvas, x, y4, x2, y4, linePaint, dashed);
            break;
          case SemiGraphSegment.rightOut:
            _curve(canvas, x1, y3, x1, y4, x2, y4, linePaint, dashed);
            break;
          case SemiGraphSegment.leftOut:
            _curve(canvas, x1, y3, x1, y4, x, y4, linePaint, dashed);
            break;
          case SemiGraphSegment.rightIn:
            _curve(canvas, x1, y5, x1, y4, x2, y4, linePaint, dashed);
            break;
          case SemiGraphSegment.leftIn:
            _curve(canvas, x1, y5, x1, y4, x, y4, linePaint, dashed);
            break;
        }
      }
      // The graph viewport is already capped to a few columns by the row;
      // stop once columns would overflow it.
      if (x + w > size.width) break;
    }
  }

  static void _line(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Paint paint,
    bool dashed,
  ) {
    if (dashed) {
      _dashedLine(canvas, Offset(x1, y1), Offset(x2, y2), paint);
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  static void _curve(
    Canvas canvas,
    double x1,
    double y1,
    double cx,
    double cy,
    double x2,
    double y2,
    Paint paint,
    bool dashed,
  ) {
    final path = Path()
      ..moveTo(x1, y1)
      ..quadraticBezierTo(cx, cy, x2, y2);
    if (dashed) {
      _dashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  static void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 2.0;
    const gap = 2.0;
    final length = (b - a).distance;
    if (length == 0) return;
    final dir = (b - a) / length;
    var d = 0.0;
    while (d < length) {
      final end = (d + dash).clamp(0.0, length);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d += dash + gap;
    }
  }

  static void _dashedPath(Canvas canvas, Path path, Paint paint) {
    // Approximate a dashed bezier by walking its extracted path metrics.
    final metrics = path.computeMetrics().toList();
    const dash = 2.0;
    const gap = 2.0;
    for (final metric in metrics) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CommitGraphPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.columnWidth != columnWidth ||
      _columnsDiffer(oldDelegate.columns, columns);

  static bool _columnsDiffer(
    List<SemiGraphColumn> a,
    List<SemiGraphColumn> b,
  ) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) return true;
      for (var j = 0; j < a[i].length; j++) {
        if (a[i][j] != b[i][j]) return true;
      }
    }
    return false;
  }
}
