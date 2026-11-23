// Port of the clipboard half of
// `packages/core/src/data-editor/data-editor.tsx`:
// - `onCopy` (`:3772-3875`)
// - `onCut` (`:3879-...`)
// - `onPasteInternal` (`:3583-3765`) including the nested `pasteToCell`
//
// The browser clipboard (`navigator.clipboard`, `ClipboardEvent.clipboardData`)
// is replaced by a small [SemiClipboard] abstraction over Flutter's
// `Clipboard`; `text/html` is read where the platform exposes it and written
// as plain text only, since `Clipboard.setData` has no HTML flavour.
import 'package:flutter/services.dart';

import '../cells/semi_cell_types.dart';
import '../common/semi_utils.dart';
import 'semi_copy_paste.dart';
import 'semi_data_editor_fns.dart';
import 'semi_key_handler.dart';

/// `onPaste` prop (`data-editor.tsx`): return `true` to let the default
/// multi-cell paste run, `false` to abort. Returning null/omitting uses the
/// single-cell renderer path.
typedef SemiPasteCallback =
    bool? Function(SemiItem location, List<List<String>> data);

/// `coercePasteValue` (`data-editor.tsx`).
typedef SemiCoercePasteValue =
    SemiGridCell? Function(String value, SemiGridCell cell);

/// System clipboard access, injectable for tests.
class SemiClipboard {
  const SemiClipboard();

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
SemiEditListItem? semiPasteToCell({
  required SemiGridCell inner,
  required SemiItem target,
  required Object? rawValue,
  Object? formatted,
  required SemiGetCellRenderer getCellRenderer,
  SemiCoercePasteValue? coercePasteValue,
}) {
  final stringifiedRawValue = rawValue is List
      ? (rawValue.map((e) => '$e').join('\n'))
      : (rawValue?.toString() ?? '');

  if (!semiIsInnerOnlyCell(inner) &&
      semiIsReadWriteCell(inner) &&
      !inner.isReadonly) {
    final coerced = coercePasteValue?.call(stringifiedRawValue, inner);
    if (coerced != null && semiIsEditableGridCell(coerced)) {
      return SemiEditListItem(location: target, value: coerced);
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
      SemiPasteDetails(
        formatted: formatted,
        formattedString: formattedString,
        rawValue: rawValue,
      ),
    );
    if (newVal == null) return null;
    return SemiEditListItem(location: target, value: newVal);
  }
  return null;
}

/// `onPasteInternal` (`data-editor.tsx:3583-3765`).
Future<void> semiPaste({
  required bool focused,
  required SemiGridSelection selection,
  required int rows,
  required int columnCount,
  required int rowMarkerOffset,
  required SemiGridCell Function(SemiItem item) getCellContent,
  required SemiGetCellRenderer getCellRenderer,
  required SemiCellsEditedCallback onCellsEdited,
  SemiPasteCallback? onPaste,
  SemiCoercePasteValue? coercePasteValue,
  SemiClipboard clipboard = const SemiClipboard(),
}) async {
  final selectedColumns = selection.columns;
  final selectedRows = selection.rows;

  SemiItem? target;
  final current = selection.current;
  if (current != null) {
    target = SemiItem(
      current.range.x.toInt(),
      current.range.y.toInt(),
    );
  } else if (selectedColumns.length == 1) {
    target = SemiItem(selectedColumns.firstIndex ?? 0, 0);
  } else if (selectedRows.length == 1) {
    target = SemiItem(rowMarkerOffset, selectedRows.firstIndex ?? 0);
  }

  if (!focused || target == null) return;

  SemiCopyBuffer? data;
  String? text;

  final html = await clipboard.readHtml();
  if (html != null) {
    data = semiDecodeHtml(html);
  }
  if (data == null) {
    text = await clipboard.readText();
  }
  if (data == null && text == null) return;

  final targetCol = target.col;
  final targetRow = target.row;

  final editList = <SemiEditListItem>[];

  if (onPaste == null) {
    final cellData = getCellContent(target);
    final rawValue = text ??
        data
            ?.map(
              (r) => r
                  .map((cb) => switch (cb) {
                    SemiBasicCellBuffer b => b.rawValue?.toString() ?? '',
                    SemiStringArrayCellBuffer b => b.rawValue.join('\n'),
                    _ => '',
                  })
                  .join('\t'),
            )
            .join('\t') ??
        '';
    final newVal = semiPasteToCell(
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
      data = semiUnquote(text);
    }

    final pass = onPaste(
      SemiItem(targetCol - rowMarkerOffset, targetRow),
      [
        for (final row in data)
          [
            for (final cb in row)
              switch (cb) {
                SemiBasicCellBuffer b => b.rawValue?.toString() ?? '',
                SemiStringArrayCellBuffer b => b.rawValue.join('\n'),
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
        final index = SemiItem(writeCol, writeRow);
        final dataItem = dataRow[col];
        final newVal = switch (dataItem) {
          SemiBasicCellBuffer b => semiPasteToCell(
            inner: getCellContent(index),
            target: index,
            rawValue: b.rawValue,
            formatted: b.formatted,
            getCellRenderer: getCellRenderer,
            coercePasteValue: coercePasteValue,
          ),
          SemiStringArrayCellBuffer b => semiPasteToCell(
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
Future<void> semiCopy({
  required bool focused,
  required bool copyEnabled,
  required SemiGridSelection selection,
  required int rows,
  required int rowMarkerOffset,
  required List<SemiGridColumn> columns,
  required SemiGetCellsForSelection getCellsForSelection,
  bool copyHeaders = false,
  SemiClipboard clipboard = const SemiClipboard(),
}) async {
  if (!copyEnabled || !focused) return;

  final selectedColumns = selection.columns;
  final selectedRows = selection.rows;

  Future<void> copyWithHeaders(
    List<List<SemiGridCell>> cells,
    List<int> columnIndexes,
  ) async {
    List<List<SemiGridCell>> payload = cells;
    if (copyHeaders) {
      final headers = <SemiGridCell>[
        for (final index in columnIndexes)
          SemiTextCell(
            data: columns[index].title,
            displayData: columns[index].title,
            allowOverlay: false,
          ),
      ];
      payload = [headers, ...cells];
    }
    final contents = semiGetCopyBufferContents(payload, columnIndexes);
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
    final cells = <List<SemiGridCell>>[];
    for (final rowIndex in selectedRows.indices) {
      final row = getCellsForSelection(
        SemiRectangle(
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
    final results = <List<List<SemiGridCell>>>[];
    final cols = <int>[];
    for (final col in selectedColumns.indices) {
      final cells = getCellsForSelection(
        SemiRectangle(
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
      final zipped = <List<SemiGridCell>>[
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
Future<void> semiCut({
  required bool focused,
  required bool cutEnabled,
  required SemiGridSelection selection,
  required int rows,
  required int rowMarkerOffset,
  required List<SemiGridColumn> columns,
  required SemiGetCellsForSelection getCellsForSelection,
  required SemiDeleteCallback onDelete,
  bool copyHeaders = false,
  SemiClipboard clipboard = const SemiClipboard(),
}) async {
  if (!cutEnabled || !focused) return;

  await semiCopy(
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

  var effective = SemiGridSelection(
    current: SemiGridSelectionCurrent(
      cell: current.cell,
      range: current.range,
      rangeStack: const [],
    ),
    rows: const SemiCompactSelection.empty(),
    columns: const SemiCompactSelection.empty(),
  );

  final onDeleteResult = onDelete(effective);
  if (onDeleteResult == false) return;
  if (onDeleteResult is SemiGridSelection) effective = onDeleteResult;
  if (effective.current == null) return;
}
