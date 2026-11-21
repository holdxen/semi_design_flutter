// Port of `packages/core/src/data-editor/row-grouping.ts` plus the pure
// helpers of `row-grouping-api.ts`.
//
// Upstream wraps the same logic in `React.useMemo`/`useCallback`; the work is
// pure, so this file exposes plain functions and the editor memoizes the
// results itself.
import 'package:flutter/foundation.dart';

import '../common/glide_theme.dart';
import '../internal/data_grid/glide_geometry.dart';

/// `RowGroup` (`row-grouping.ts:11-18`).
///
/// The upstream `processGroup` also accepts a bare number (a group header
/// without collapse state); that legacy form is not modelled here.
@immutable
class GlideRowGroup {
  const GlideRowGroup({
    required this.headerIndex,
    this.isCollapsed = false,
    this.subGroups,
  });

  /// Index of the header row in the *grouped* row space.
  final int headerIndex;
  final bool isCollapsed;
  final List<GlideRowGroup>? subGroups;

  GlideRowGroup copyWith({
    int? headerIndex,
    bool? isCollapsed,
    List<GlideRowGroup>? subGroups,
    bool clearSubGroups = false,
  }) => GlideRowGroup(
    headerIndex: headerIndex ?? this.headerIndex,
    isCollapsed: isCollapsed ?? this.isCollapsed,
    subGroups: clearSubGroups ? null : (subGroups ?? this.subGroups),
  );
}

/// `navigationBehavior` (`row-grouping.ts:56`).
enum GlideRowGroupNavigationBehavior { normal, skip, skipUp, skipDown, block }

/// `selectionBehavior` (`row-grouping.ts:62`).
enum GlideRowGroupSelectionBehavior { allowSpanning, blockSpanning }

/// `RowGroupingOptions` (`row-grouping.ts:20-63`).
@immutable
class GlideRowGroupingOptions {
  const GlideRowGroupingOptions({
    required this.groups,
    required this.height,
    this.themeOverride,
    this.navigationBehavior = GlideRowGroupNavigationBehavior.normal,
    this.selectionBehavior = GlideRowGroupSelectionBehavior.allowSpanning,
  });

  final List<GlideRowGroup> groups;
  final double height;
  final GlideThemeOverride? themeOverride;
  final GlideRowGroupNavigationBehavior navigationBehavior;
  final GlideRowGroupSelectionBehavior selectionBehavior;
}

/// `ExpandedRowGroup` (`row-grouping.ts:65-71`).
@immutable
class GlideExpandedRowGroup {
  const GlideExpandedRowGroup({
    required this.headerIndex,
    required this.isCollapsed,
    required this.depth,
    required this.path,
    this.subGroups,
  });

  final int headerIndex;
  final bool isCollapsed;
  final int depth;
  final List<int> path;
  final List<GlideExpandedRowGroup>? subGroups;
}

/// `expandRowGroups` (`row-grouping.ts:73-104`).
List<GlideExpandedRowGroup> expandRowGroups(List<GlideRowGroup> groups) {
  GlideExpandedRowGroup process(
    GlideRowGroup group,
    int depth,
    List<int> path,
  ) {
    final expanded = GlideExpandedRowGroup(
      headerIndex: group.headerIndex,
      isCollapsed: group.isCollapsed,
      depth: depth,
      path: path,
    );
    final subGroups = group.subGroups;
    if (subGroups == null) return expanded;

    final children = [
      for (var i = 0; i < subGroups.length; i++)
        process(subGroups[i], depth + 1, [...path, i]),
    ]..sort((a, b) => a.headerIndex.compareTo(b.headerIndex));
    return GlideExpandedRowGroup(
      headerIndex: expanded.headerIndex,
      isCollapsed: expanded.isCollapsed,
      depth: expanded.depth,
      path: expanded.path,
      subGroups: children,
    );
  }

  final result = [
    for (var i = 0; i < groups.length; i++) process(groups[i], 0, [i]),
  ];
  return result..sort((a, b) => a.headerIndex.compareTo(b.headerIndex));
}

/// `FlattenedRowGroup` (`row-grouping.ts:106-114`).
@immutable
class GlideFlattenedRowGroup {
  const GlideFlattenedRowGroup({
    required this.rowIndex,
    required this.headerIndex,
    required this.contentIndex,
    required this.isCollapsed,
    required this.depth,
    required this.rows,
    required this.path,
  });

  final int rowIndex;
  final int headerIndex;
  final int contentIndex;
  final bool isCollapsed;
  final int depth;
  final int rows;
  final List<int> path;
}

/// `flattenRowGroups` (`row-grouping.ts:120-178`).
List<GlideFlattenedRowGroup> flattenRowGroups(
  GlideRowGroupingOptions rowGrouping,
  int rows,
) {
  final flattened = <_SkippableGroup>[];

  void processGroup(
    GlideExpandedRowGroup group,
    int? nextHeaderIndex, {
    bool skipChildren = false,
  }) {
    var rowsInGroup = nextHeaderIndex != null
        ? nextHeaderIndex - group.headerIndex
        : rows - group.headerIndex;
    final subGroups = group.subGroups;
    if (subGroups != null && subGroups.isNotEmpty) {
      rowsInGroup = subGroups.first.headerIndex - group.headerIndex;
    }
    rowsInGroup--; // the header isn't in the group

    flattened.add(
      _SkippableGroup(
        rowIndex: -1,
        headerIndex: group.headerIndex,
        contentIndex: -1,
        skip: skipChildren,
        isCollapsed: group.isCollapsed,
        depth: group.depth,
        rows: rowsInGroup,
        path: group.path,
      ),
    );

    if (subGroups != null) {
      for (var i = 0; i < subGroups.length; i++) {
        final nextSubHeaderIndex = i < subGroups.length - 1
            ? subGroups[i + 1].headerIndex
            : nextHeaderIndex;
        processGroup(
          subGroups[i],
          nextSubHeaderIndex,
          skipChildren: skipChildren || group.isCollapsed,
        );
      }
    }
  }

  final expandedGroups = expandRowGroups(rowGrouping.groups);
  for (var i = 0; i < expandedGroups.length; i++) {
    final nextHeaderIndex = i < expandedGroups.length - 1
        ? expandedGroups[i + 1].headerIndex
        : null;
    processGroup(expandedGroups[i], nextHeaderIndex);
  }

  var rowIndex = 0;
  var contentIndex = 0;
  for (final g in flattened) {
    g.contentIndex = contentIndex;
    contentIndex += g.rows;

    g.rowIndex = rowIndex;
    rowIndex += g.isCollapsed ? 1 : g.rows + 1;
  }

  return [
    for (final g in flattened)
      if (!g.skip)
        GlideFlattenedRowGroup(
          rowIndex: g.rowIndex,
          headerIndex: g.headerIndex,
          contentIndex: g.contentIndex,
          isCollapsed: g.isCollapsed,
          depth: g.depth,
          rows: g.rows,
          path: g.path,
        ),
  ];
}

class _SkippableGroup {
  _SkippableGroup({
    required this.rowIndex,
    required this.headerIndex,
    required this.contentIndex,
    required this.skip,
    required this.isCollapsed,
    required this.depth,
    required this.rows,
    required this.path,
  });

  int rowIndex;
  int headerIndex;
  int contentIndex;
  final bool skip;
  final bool isCollapsed;
  final int depth;
  final int rows;
  final List<int> path;
}

/// `MapResult` (`row-grouping.ts:180-187`).
@immutable
class GlideRowMapResult {
  const GlideRowMapResult({
    required this.path,
    required this.isGroupHeader,
    required this.originalIndex,
    required this.groupIndex,
    required this.groupRows,
    required this.contentIndex,
  });

  final List<int> path;
  final bool isGroupHeader;
  final int originalIndex;
  final int groupIndex;
  final int groupRows;
  final int contentIndex;
}

/// `mapRowIndexToPath` (`row-grouping.ts:190-238`).
GlideRowMapResult mapRowIndexToPath(
  int row,
  List<GlideFlattenedRowGroup>? flattenedRowGroups,
) {
  if (flattenedRowGroups == null || flattenedRowGroups.isEmpty) {
    return GlideRowMapResult(
      path: [row],
      isGroupHeader: false,
      originalIndex: row,
      groupIndex: row,
      contentIndex: row,
      groupRows: -1,
    );
  }

  var toGo = row;
  for (final group in flattenedRowGroups) {
    if (toGo == 0) {
      return GlideRowMapResult(
        path: [...group.path, -1],
        isGroupHeader: true,
        originalIndex: group.headerIndex,
        groupIndex: -1,
        contentIndex: -1,
        groupRows: group.rows,
      );
    }
    if (!group.isCollapsed) {
      if (toGo <= group.rows) {
        return GlideRowMapResult(
          path: [...group.path, toGo - 1],
          isGroupHeader: false,
          originalIndex: group.headerIndex + toGo,
          groupIndex: toGo - 1,
          contentIndex: group.contentIndex + toGo - 1,
          groupRows: group.rows,
        );
      }
      toGo = toGo - group.rows - 1;
    } else {
      toGo--;
    }
  }

  // This shouldn't happen (upstream `row-grouping.ts:227-237`).
  return GlideRowMapResult(
    path: [row],
    isGroupHeader: false,
    originalIndex: row,
    groupIndex: row,
    contentIndex: row,
    groupRows: -1,
  );
}

/// The memoized outputs of `useRowGroupingInner` (`row-grouping.ts:240-326`).
@immutable
class GlideRowGroupingResult {
  const GlideRowGroupingResult({
    required this.rows,
    required this.flattened,
    this.rowNumberMapper,
    this.rowHeight,
    this.getRowThemeOverride,
  });

  /// `effectiveRows` (`row-grouping.ts:265-268`).
  final int rows;
  final List<GlideFlattenedRowGroup> flattened;

  /// `rowNumberMapper` (`row-grouping.ts:279-296`); null marks a group header
  /// row, which has no row number.
  final int? Function(int row)? rowNumberMapper;

  /// `rowHeight` (`row-grouping.ts:270-277`).
  final double Function(int row)? rowHeight;

  /// `getRowThemeOverride` (`row-grouping.ts:298-310`).
  final GlideThemeOverride? Function(int row)? getRowThemeOverride;
}

/// `getRowThemeOverrideIn` (`data-editor.tsx`): the indexed form the grid's
/// one-argument `getRowThemeOverride` cannot express, so the editor adapts it.
typedef GlideGetRowThemeOverrideIndexed =
    GlideThemeOverride? Function(int row, int groupIndex, int contentIndex);

/// `useRowGroupingInner` (`row-grouping.ts:247-326`).
GlideRowGroupingResult useRowGroupingInner({
  required GlideRowGroupingOptions? options,
  required int rows,
  required GlideRowHeight rowHeightIn,
  required GlideGetRowThemeOverrideIndexed? getRowThemeOverrideIn,
}) {
  final rowHeightIsFixed = rowHeightIn.isFixed;
  final fixedRowHeight = rowHeightIsFixed ? rowHeightIn(0) : 0.0;
  final flattened = options == null
      ? const <GlideFlattenedRowGroup>[]
      : flattenRowGroups(options, rows);
  final hasGroups = options != null && flattened.isNotEmpty;

  final flattenedMap = <int, GlideFlattenedRowGroup>{
    for (final group in flattened) group.rowIndex: group,
  };

  final effectiveRows = options == null
      ? rows
      : flattened.fold<int>(
          0,
          (acc, group) => acc + (group.isCollapsed ? 1 : group.rows + 1),
        );

  // `rowHeight` (`row-grouping.ts:270-277`).
  double Function(int)? rowHeight;
  if (hasGroups) {
    if (!(rowHeightIsFixed && options.height == fixedRowHeight)) {
      rowHeight = (rowIndex) {
        if (flattenedMap.containsKey(rowIndex)) return options.height;
        return rowHeightIsFixed ? fixedRowHeight : rowHeightIn(rowIndex);
      };
    }
  }

  // `rowNumberMapperOut` (`row-grouping.ts:279-296`).
  int? Function(int)? rowNumberMapper;
  if (hasGroups) {
    rowNumberMapper = (row) {
      var toGo = row;
      for (final group in flattened) {
        if (toGo == 0) return null; // the header itself has no number
        toGo--;
        if (!group.isCollapsed) {
          if (toGo < group.rows) return group.contentIndex + toGo;
          toGo -= group.rows;
        }
      }
      return row;
    };
  }

  // `getRowThemeOverride` (`row-grouping.ts:298-310`).
  GlideThemeOverride? Function(int)? themeOverride;
  if (options == null) {
    if (getRowThemeOverrideIn != null) {
      themeOverride = (row) => getRowThemeOverrideIn(row, row, row);
    }
  } else if (getRowThemeOverrideIn != null ||
      options.themeOverride != null) {
    themeOverride = (row) {
      final mapped = mapRowIndexToPath(row, flattened);
      if (mapped.isGroupHeader) return options.themeOverride;
      return getRowThemeOverrideIn?.call(
        row,
        mapped.groupIndex,
        mapped.contentIndex,
      );
    };
  }

  return GlideRowGroupingResult(
    rows: effectiveRows,
    flattened: flattened,
    rowNumberMapper: rowNumberMapper,
    rowHeight: rowHeight,
    getRowThemeOverride: themeOverride,
  );
}

/// `getSelectionRowLimits` (`data-editor.tsx:2708-2725`): with
/// `block-spanning` selections cannot cross a group header.
(int, int)? getSelectionRowLimits({
  required GlideRowGroupingOptions? options,
  required List<GlideFlattenedRowGroup> flattened,
  required int selectedRow,
}) {
  if (options == null ||
      options.selectionBehavior != GlideRowGroupSelectionBehavior.blockSpanning) {
    return null;
  }

  final mapped = mapRowIndexToPath(selectedRow, flattened);
  if (mapped.isGroupHeader) return (selectedRow, selectedRow);

  final groupRowIndex = mapped.path.last;
  final lowerBounds = selectedRow - groupRowIndex;
  final upperBounds = selectedRow + mapped.groupRows - groupRowIndex - 1;
  return (lowerBounds, upperBounds);
}

/// `getRowGroupingForPath` (`row-grouping-api.ts:66-72`).
GlideRowGroup getRowGroupingForPath(
  List<GlideRowGroup> rowGrouping,
  List<int> path,
) {
  final index = path.first;
  final rest = path.skip(1).toList();
  if (rest.isEmpty || rest.first == -1) return rowGrouping[index];
  return getRowGroupingForPath(
    rowGrouping[index].subGroups ?? const [],
    rest,
  );
}

/// `updateRowGroupingByPath` (`row-grouping-api.ts:52-64`).
List<GlideRowGroup> updateRowGroupingByPath(
  List<GlideRowGroup> rowGrouping,
  List<int> path,
  GlideRowGroup Function(GlideRowGroup group) update,
) {
  final index = path.first;
  final rest = path.skip(1).toList();
  return [
    for (var i = 0; i < rowGrouping.length; i++)
      i != index
          ? rowGrouping[i]
          : (rest.isEmpty || rest.first == -1
                ? update(rowGrouping[i])
                : rowGrouping[i].copyWith(
                    subGroups: updateRowGroupingByPath(
                      rowGrouping[i].subGroups ?? const [],
                      rest,
                      update,
                    ),
                  )),
  ];
}
