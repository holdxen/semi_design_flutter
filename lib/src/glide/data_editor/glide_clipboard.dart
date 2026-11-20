// Port of the clipboard half of
// `packages/core/src/data-editor/data-editor.tsx`:
// - `onCopy` (`:3772-3875`)
// - `onCut` (`:3879-...`)
// - `onPasteInternal` (`:3583-3765`) including the nested `pasteToCell`
//
// The browser clipboard (`navigator.clipboard`, `ClipboardEvent.clipboardData`)
// is replaced by a small [GlideClipboard] abstraction over Flutter's
// `Clipboard`; `text/html` is read where the platform exposes it and written
// as plain text only, since `Clipboard.setData` has no HTML flavour.
import 'package:flutter/services.dart';

import '../cells/glide_cell_types.dart';
import '../common/glide_utils.dart';
import 'glide_copy_paste.dart';
import 'glide_data_editor_fns.dart';
import 'glide_key_handler.dart';

/// `onPaste` prop (`data-editor.tsx`): return `true` to let the default
/// multi-cell paste run, `false` to abort. Returning null/omitting uses the
/// single-cell renderer path.
typedef GlidePasteCallback =
    bool? Function(GlideItem location, List<List<String>> data);

/// `coercePasteValue` (`data-editor.tsx`).
typedef GlideCoercePasteValue =
    GlideGridCell? Function(String value, GlideGridCell cell);

/// System clipboard access, injectable for tests.
class GlideClipboard {
  const GlideClipboard();

  Future<String?> readText() async =>
      (await Clipboard.getData(Clipboard.kTextPlain))?.text;

  /// Best effort: only platforms whose clipboard carries HTML answer the
  /// `text/html` format; everyone else gets null and falls back to plain
  /// text.
  Future<String?> readHtml() async =>
      (await Clipboard.getData('text/html'))?.text;

  Future<void> write({required String textPlain, required String textHtml}) =>
      Clipboard.setData(ClipboardData(text: textPlain));
}

/// `pasteToCell` (`data-editor.tsx:3586-3638`).
GlideEditListItem? glidePasteToCell({
  required GlideGridCell inner,
  required GlideItem target,
  required Object? rawValue,
  Object? formatted,
  required GlideGetCellRenderer getCellRenderer,
  GlideCoercePasteValue? coercePasteValue,
}) {
  final stringifiedRawValue = rawValue is List
      ? (rawValue.map((e) => '$e').join('\n'))
      : (rawValue?.toString() ?? '');

  if (!glideIsInnerOnlyCell(inner) &&
      glideIsReadWriteCell(inner) &&
      !inner.isReadonly) {
    final coerced = coercePasteValue?.call(stringifiedRawValue, inner);
    if (coerced != null && glideIsEditableGridCell(coerced)) {
      return GlideEditListItem(location: target, value: coerced);
    }

    final r = getCellRenderer(inner);
    if (r == null) return null;

    final formattedString = switch (formatted) {
      null => null,
      List list => list.map((e) => '$e').join('\n'),
      String value => value,
      _ => '$formatted',
    };
    final newVal = r.onPaste(
      stringifiedRawValue,
      inner,
      GlidePasteDetails(
        formatted: formatted,
        formattedString: formattedString,
        rawValue: rawValue,
      ),
    );
    if (newVal == null) return null;
    return GlideEditListItem(location: target, value: newVal);
  }
  return null;
}

/// `onPasteInternal` (`data-editor.tsx:3583-3765`).
Future<void> glidePaste({
  required bool focused,
  required GlideGridSelection selection,
  required int rows,
  required int columnCount,
  required int rowMarkerOffset,
  required GlideGridCell Function(GlideItem item) getCellContent,
  required GlideGetCellRenderer getCellRenderer,
  required GlideCellsEditedCallback onCellsEdited,
  GlidePasteCallback? onPaste,
  GlideCoercePasteValue? coercePasteValue,
  GlideClipboard clipboard = const GlideClipboard(),
}) async {
  final selectedColumns = selection.columns;
  final selectedRows = selection.rows;

  GlideItem? target;
  final current = selection.current;
  if (current != null) {
    target = GlideItem(
      current.range.x.toInt(),
      current.range.y.toInt(),
    );
  } else if (selectedColumns.length == 1) {
    target = GlideItem(selectedColumns.firstIndex ?? 0, 0);
  } else if (selectedRows.length == 1) {
    target = GlideItem(rowMarkerOffset, selectedRows.firstIndex ?? 0);
  }

  if (!focused || target == null) return;

  GlideCopyBuffer? data;
  String? text;

  final html = await clipboard.readHtml();
  if (html != null) {
    data = glideDecodeHtml(html);
  }
  if (data == null) {
    text = await clipboard.readText();
  }
  if (data == null && text == null) return;

  final targetCol = target.col;
  final targetRow = target.row;

  final editList = <GlideEditListItem>[];

  if (onPaste == null) {
    final cellData = getCellContent(target);
    final rawValue = text ??
        data
            ?.map(
              (r) => r
                  .map((cb) => switch (cb) {
                    GlideBasicCellBuffer b => b.rawValue?.toString() ?? '',
                    GlideStringArrayCellBuffer b => b.rawValue.join('\n'),
                    _ => '',
                  })
                  .join('\t'),
            )
            .join('\t') ??
        '';
    final newVal = glidePasteToCell(
      inner: cellData,
      target: target,
      rawValue: rawValue,
      getCellRenderer: getCellRenderer,
      coercePasteValue: coercePasteValue,
    );
    if (newVal != null) editList.add(newVal);
  } else {
    if (data == null) {
      if (text == null) return;
      data = glideUnquote(text);
    }

    final pass = onPaste(
      GlideItem(targetCol - rowMarkerOffset, targetRow),
      [
        for (final row in data)
          [
            for (final cb in row)
              switch (cb) {
                GlideBasicCellBuffer b => b.rawValue?.toString() ?? '',
                GlideStringArrayCellBuffer b => b.rawValue.join('\n'),
                _ => '',
              },
          ],
      ],
    );
    if (pass != true) return;

    for (var row = 0; row < data.length; row++) {
      if (row + targetRow >= rows) break;
      final dataRow = data[row];
      for (var col = 0; col < dataRow.length; col++) {
        final writeCol = col + targetCol;
        final writeRow = row + targetRow;
        if (writeCol >= columnCount) continue;
        if (writeRow >= rows) continue;
        final index = GlideItem(writeCol, writeRow);
        final dataItem = dataRow[col];
        final newVal = switch (dataItem) {
          GlideBasicCellBuffer b => glidePasteToCell(
            inner: getCellContent(index),
            target: index,
            rawValue: b.rawValue,
            formatted: b.formatted,
            getCellRenderer: getCellRenderer,
            coercePasteValue: coercePasteValue,
          ),
          GlideStringArrayCellBuffer b => glidePasteToCell(
            inner: getCellContent(index),
            target: index,
            rawValue: b.rawValue,
            formatted: b.formatted,
            getCellRenderer: getCellRenderer,
            coercePasteValue: coercePasteValue,
          ),
          _ => null,
        };
        if (newVal != null) editList.add(newVal);
      }
    }
  }

  onCellsEdited(editList);
}

/// `onCopy` (`data-editor.tsx:3772-3875`).
Future<void> glideCopy({
  required bool focused,
  required bool copyEnabled,
  required GlideGridSelection selection,
  required int rows,
  required int rowMarkerOffset,
  required List<GlideGridColumn> columns,
  required GlideGetCellsForSelection getCellsForSelection,
  bool copyHeaders = false,
  GlideClipboard clipboard = const GlideClipboard(),
}) async {
  if (!copyEnabled || !focused) return;

  final selectedColumns = selection.columns;
  final selectedRows = selection.rows;

  Future<void> copyWithHeaders(
    List<List<GlideGridCell>> cells,
    List<int> columnIndexes,
  ) async {
    List<List<GlideGridCell>> payload = cells;
    if (copyHeaders) {
      final headers = <GlideGridCell>[
        for (final index in columnIndexes)
          GlideTextCell(
            data: columns[index].title,
            displayData: columns[index].title,
            allowOverlay: false,
          ),
      ];
      payload = [headers, ...cells];
    }
    final contents = glideGetCopyBufferContents(payload, columnIndexes);
    await clipboard.write(
      textPlain: contents.textPlain,
      textHtml: contents.textHtml,
    );
  }

  final current = selection.current;
  if (current != null) {
    final range = current.range;
    final cells = getCellsForSelection(range);
    if (cells == null) return;
    await copyWithHeaders(cells, [
      for (var i = range.x.toInt() - rowMarkerOffset;
          i < range.x + range.width - rowMarkerOffset;
          i++)
        i,
    ]);
  } else if (selectedRows.length > 0) {
    final cells = <List<GlideGridCell>>[];
    for (final rowIndex in selectedRows.indices) {
      final row = getCellsForSelection(
        GlideRectangle(
          x: rowMarkerOffset.toDouble(),
          y: rowIndex.toDouble(),
          width: columns.length.toDouble(),
          height: 1,
        ),
      );
      if (row == null || row.isEmpty) continue;
      cells.add(row.first);
    }
    if (cells.isEmpty) return;
    await copyWithHeaders(cells, [
      for (var i = 0; i < columns.length; i++) i,
    ]);
  } else if (selectedColumns.length > 0) {
    final results = <List<List<GlideGridCell>>>[];
    final cols = <int>[];
    for (final col in selectedColumns.indices) {
      final cells = getCellsForSelection(
        GlideRectangle(
          x: col.toDouble(),
          y: 0,
          width: 1,
          height: rows.toDouble(),
        ),
      );
      if (cells == null) continue;
      results.add(cells);
      cols.add(col - rowMarkerOffset);
    }
    if (results.isEmpty) return;
    if (results.length == 1) {
      await copyWithHeaders(results.first, cols);
    } else {
      // FIXME: upstream calls this dumb too — zip the per-column results
      // row by row.
      final width = results.first.length;
      final zipped = <List<GlideGridCell>>[
        for (var r = 0; r < width; r++)
          [
            for (final column in results)
              if (r < column.length) ...column[r],
          ],
      ];
      await copyWithHeaders(zipped, cols);
    }
  }
}

/// `onCut` (`data-editor.tsx:3879-...`): copy, then delete the primary range.
Future<void> glideCut({
  required bool focused,
  required bool cutEnabled,
  required GlideGridSelection selection,
  required int rows,
  required int rowMarkerOffset,
  required List<GlideGridColumn> columns,
  required GlideGetCellsForSelection getCellsForSelection,
  required GlideDeleteCallback onDelete,
  bool copyHeaders = false,
  GlideClipboard clipboard = const GlideClipboard(),
}) async {
  if (!cutEnabled || !focused) return;

  await glideCopy(
    focused: focused,
    copyEnabled: true,
    selection: selection,
    rows: rows,
    rowMarkerOffset: rowMarkerOffset,
    columns: columns,
    getCellsForSelection: getCellsForSelection,
    copyHeaders: copyHeaders,
    clipboard: clipboard,
  );

  final current = selection.current;
  if (current == null) return;

  var effective = GlideGridSelection(
    current: GlideGridSelectionCurrent(
      cell: current.cell,
      range: current.range,
      rangeStack: const [],
    ),
    rows: const GlideCompactSelection.empty(),
    columns: const GlideCompactSelection.empty(),
  );

  final onDeleteResult = onDelete(effective);
  if (onDeleteResult == false) return;
  if (onDeleteResult is GlideGridSelection) effective = onDeleteResult;
  if (effective.current == null) return;
}
