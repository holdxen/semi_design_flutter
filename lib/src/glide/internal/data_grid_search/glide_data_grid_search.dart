// Port of `packages/core/src/internal/data-grid-search/data-grid-search.tsx`
// plus `data-grid-search-style.tsx`.
//
// The search engine and the bar live in one file upstream; here they are
// separated by responsibility inside the same file so the editor can own the
// state (it needs the results for `prelightCells`) while the bar stays a
// presentational widget.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../cells/glide_cell_types.dart';
import '../../data_editor/glide_data_editor_fns.dart';

/// `targetSearchTimeMS` (`data-grid-search.ts:91`).
const double _targetSearchTimeMs = 10;

/// The result counter shown under the input (`data-grid-search.ts:123-127`).
@immutable
class GlideSearchStatus {
  const GlideSearchStatus({
    required this.rowsSearched,
    required this.results,
    required this.selectedIndex,
  });

  final int rowsSearched;
  final int results;
  final int selectedIndex;
}

/// The cell text a search pattern is tested against
/// (`data-grid-search.ts:204-227`). Null means "not searchable".
String? glideSearchTestString(GlideGridCell cell) {
  return switch (cell) {
    GlideTextCell value => value.displayData,
    GlideNumberCell value => value.displayData,
    GlideUriCell value => value.data,
    GlideMarkdownCell value => value.data,
    GlideBooleanCell value => switch (value.data) {
      GlideBooleanValue.checked => 'true',
      GlideBooleanValue.unchecked => 'false',
      _ => null,
    },
    // Upstream joins with a whale emoji; kept as the literal escape.
    GlideImageCell value => value.data.join('\u{1F433}'),
    GlideBubbleCell value => value.data.join('\u{1F433}'),
    GlideCustomCell value => value.copyData,
    _ => null,
  };
}

/// `new RegExp(str.replace(/([$()*+.?[\\\]^{|}-])/g, "\\$1"), "i")`
/// (`data-grid-search.ts:167`): the pattern is escaped and case insensitive.
RegExp glideSearchRegex(String input) {
  const meta = r'([\$()*+.?[\]\\^{|}-])';
  return RegExp(
    input.replaceAllMapped(RegExp(meta), (m) => '\\${m.group(1)}'),
    caseSensitive: false,
  );
}

/// The incremental, time-budgeted search loop
/// (`data-grid-search.ts:165-274`).
class GlideSearchRunner {
  int _generation = 0;

  /// Cancels any in-flight search; the next [search] starts a new one.
  void cancel() => _generation++;

  Future<void> search({
    required String pattern,
    required int rows,
    required int columnCount,
    required int startY,
    required GlideGetCellsForSelection getCells,
    required void Function(List<GlideItem> results) onResults,
    required void Function(GlideSearchStatus status) onStatus,
    required void Function(List<GlideItem> results, int selectedIndex)
    onResultsChanged,
    required int selectedIndex,
  }) async {
    cancel();
    final generation = _generation;
    if (pattern.isEmpty || rows <= 0) {
      onResults(const []);
      onStatus(
        const GlideSearchStatus(rowsSearched: 0, results: 0, selectedIndex: -1),
      );
      onResultsChanged(const [], -1);
      return;
    }

    final regex = glideSearchRegex(pattern);
    var searchY = startY;
    var searchStride = math.min(10, rows);
    var rowsSearched = 0;
    final runningResult = <GlideItem>[];

    onStatus(
      const GlideSearchStatus(rowsSearched: 0, results: 0, selectedIndex: -1),
    );

    final stopwatch = Stopwatch()..start();
    while (true) {
      if (generation != _generation) return;

      stopwatch.reset();
      final rowsLeft = rows - rowsSearched;
      final height = math.min(searchStride, math.min(rowsLeft, rows - searchY));
      if (height <= 0) break;

      final data = getCells(
        GlideRectangle(
          x: 0,
          y: searchY.toDouble(),
          width: columnCount.toDouble(),
          height: height.toDouble(),
        ),
      );
      if (data == null) break;

      var added = false;
      for (var r = 0; r < data.length; r++) {
        final row = data[r];
        for (var c = 0; c < row.length; c++) {
          final testString = glideSearchTestString(row[c]);
          if (testString != null && regex.hasMatch(testString)) {
            runningResult.add(GlideItem(c, r + searchY));
            added = true;
          }
        }
      }

      if (added) onResults(List.of(runningResult));

      rowsSearched += data.length;
      onStatus(
        GlideSearchStatus(
          rowsSearched: rowsSearched,
          results: runningResult.length,
          selectedIndex: selectedIndex,
        ),
      );
      onResultsChanged(List.of(runningResult), selectedIndex);

      if (searchY + searchStride >= rows) {
        searchY = 0;
      } else {
        searchY += searchStride;
      }

      final tElapsed = math.max(stopwatch.elapsedMicroseconds / 1000.0, 1.0);
      final scalar = _targetSearchTimeMs / tElapsed;
      searchStride = math.max(1, (searchStride * scalar).ceil());

      if (rowsSearched < rows && runningResult.length < 1000) {
        // The frame budget upstream gets from `requestAnimationFrame`.
        await Future<void>.delayed(Duration.zero);
      } else {
        break;
      }
    }
    if (generation == _generation) {
      onStatus(
        GlideSearchStatus(
          rowsSearched: rows,
          results: runningResult.length,
          selectedIndex: selectedIndex,
        ),
      );
    }
  }
}

/// `SearchWrapper` (`data-grid-search-style.tsx:3-96`).
class GlideSearchBar extends StatelessWidget {
  const GlideSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    required this.status,
    required this.rows,
    required this.theme,
    required this.focusNode,
    required this.textController,
    required this.onKeyDown,
    required this.onPrev,
    required this.onNext,
    required this.showClose,
    required this.onClose,
    required this.onCancelPointer,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final GlideSearchStatus? status;
  final int rows;
  final GlideTheme theme;
  final FocusNode focusNode;
  final TextEditingController textController;
  final KeyEventResult Function(FocusNode node, KeyEvent event) onKeyDown;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool showClose;
  final VoidCallback onClose;

  /// The bar swallows pointer events so they never reach the grid
  /// (`data-grid-search.ts:412-416`).
  final VoidCallback onCancelPointer;

  String get _resultString {
    final s = status;
    if (s == null) return 'Type to search';
    var text = s.results >= 1000
        ? 'over 1000'
        : '${s.results} result${s.results == 1 ? '' : 's'}';
    if (s.selectedIndex >= 0) {
      text = '${s.selectedIndex + 1} of $text';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final s = status;
    final progress = rows > 0
        ? ((s?.rowsSearched ?? 0) / rows * 100).clamp(0, 100)
        : 0.0;

    return Positioned(
      top: 4,
      right: 20,
      child: Listener(
        onPointerDown: (_) => onCancelPointer(),
        onPointerUp: (_) => onCancelPointer(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onCancelPointer,
          onSecondaryTapDown: (_) => onCancelPointer(),
          // A fixed width keeps the progress bar's `FractionallySizedBox`
          // from receiving an infinite constraint (`data-grid-search-style.tsx`
          // sizes the input at 220px and lets the bar size to it).
          child: SizedBox(
            width: 344,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.bgCell,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 220,
                        child: Focus(
                          focusNode: focusNode,
                          onKeyEvent: onKeyDown,
                          child: TextField(
                            autofocus: true,
                            controller: textController,
                            style: TextStyle(
                              fontSize: theme.editorFontSize,
                              color: theme.textDark,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: onChanged,
                          ),
                        ),
                      ),
                      _BarButton(
                        icon: Icons.keyboard_arrow_up,
                        label: 'Previous Result',
                        enabled: (status?.results ?? 0) > 0,
                        theme: theme,
                        onTap: onPrev,
                      ),
                      _BarButton(
                        icon: Icons.keyboard_arrow_down,
                        label: 'Next Result',
                        enabled: (status?.results ?? 0) > 0,
                        theme: theme,
                        onTap: onNext,
                      ),
                      if (showClose)
                        _BarButton(
                          icon: Icons.close,
                          label: 'Close Search',
                          enabled: true,
                          theme: theme,
                          onTap: onClose,
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _resultString,
                      style: TextStyle(fontSize: 11, color: theme.textDark),
                    ),
                  ),
                  if (s != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SizedBox(
                        height: 4,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress / 100,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: theme.textLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final GlideTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        tooltip: label,
        iconSize: 16,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
        color: theme.textMedium,
        icon: Icon(icon),
      ),
    );
  }
}
