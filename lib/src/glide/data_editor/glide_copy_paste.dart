// Port of `packages/core/src/data-editor/copy-paste.ts`.
//
// Two Web-only pieces are adapted:
// - `decodeHTML` walks the DOM with `querySelector`; here a small hand-rolled
//   parser handles the `<table>` shapes the grid itself emits plus the
//   `<a>`/`<ol>`/`gdg-raw-value` attributes Excel, Sheets and Numbers emit.
// - `copyToClipboard` writes `text/plain` through `Clipboard.setData`;
//   `text/html` is produced by [glideGetCopyBufferContents] but Flutter has
//   no cross-platform HTML clipboard format, so it is exposed for callers
//   that have one.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../internal/data_grid/glide_types.dart';

/// `StringArrayCellBuffer` (`copy-paste.ts:10-15`).
@immutable
class GlideStringArrayCellBuffer {
  const GlideStringArrayCellBuffer({
    required this.formatted,
    required this.rawValue,
    this.doNotEscape = false,
  });

  final List<String> formatted;
  final List<String> rawValue;
  final bool doNotEscape;
}

/// `BasicCellBuffer` (`copy-paste.ts:17-22`).
@immutable
class GlideBasicCellBuffer {
  const GlideBasicCellBuffer({
    required this.formatted,
    required this.rawValue,
    required this.format,
    this.doNotEscape = false,
  });

  final String formatted;

  /// `string | number | boolean | BooleanEmpty | BooleanIndeterminate |
  /// undefined`; booleans are kept as `bool`, tri-state as
  /// [GlideBooleanValue], everything else stringified.
  final Object? rawValue;
  final String format;
  final bool doNotEscape;
}

/// `CellBuffer` (`copy-paste.ts:23`).
typedef GlideCellBuffer = Object;

/// `CopyBuffer` (`copy-paste.ts:24`).
typedef GlideCopyBuffer = List<List<GlideCellBuffer>>;

/// `convertCellToBuffer` (`copy-paste.ts:26-109`).
GlideCellBuffer glideConvertCellToBuffer(GlideGridCell cell) {
  final copyData = cell.copyData;
  if (copyData != null) {
    // Do not escape the copy value if it was explicitly specified via
    // `copyData`.
    return GlideBasicCellBuffer(
      formatted: copyData,
      rawValue: copyData,
      format: 'string',
      doNotEscape: true,
    );
  }

  return switch (cell) {
    GlideBooleanCell value => GlideBasicCellBuffer(
      formatted: switch (value.data) {
        GlideBooleanValue.checked => 'TRUE',
        GlideBooleanValue.unchecked => 'FALSE',
        GlideBooleanValue.indeterminate => 'INDETERMINATE',
        _ => '',
      },
      rawValue: value.data == GlideBooleanValue.empty
          ? null
          : value.data,
      format: 'boolean',
    ),
    GlideCustomCell value => GlideBasicCellBuffer(
      formatted: value.copyData ?? '',
      rawValue: value.copyData ?? '',
      format: 'string',
    ),
    GlideImageCell value => GlideStringArrayCellBuffer(
      formatted: List.of(value.data),
      rawValue: List.of(value.data),
    ),
    GlideBubbleCell value => GlideStringArrayCellBuffer(
      formatted: List.of(value.data),
      rawValue: List.of(value.data),
    ),
    GlideDrilldownCell value => GlideStringArrayCellBuffer(
      formatted: [for (final d in value.data) d.text],
      rawValue: [for (final d in value.data) d.text],
    ),
    GlideTextCell value => GlideBasicCellBuffer(
      formatted: value.displayData,
      rawValue: value.data,
      format: 'string',
    ),
    GlideUriCell value => GlideBasicCellBuffer(
      formatted: value.displayData ?? value.data,
      rawValue: value.data,
      format: 'url',
    ),
    GlideMarkdownCell value => GlideBasicCellBuffer(
      formatted: value.data,
      rawValue: value.data,
      format: 'string',
    ),
    GlideRowIdCell value => GlideBasicCellBuffer(
      formatted: value.data,
      rawValue: value.data,
      format: 'string',
    ),
    GlideNumberCell value => GlideBasicCellBuffer(
      formatted: value.displayData,
      rawValue: value.data,
      format: 'number',
    ),
    GlideLoadingCell() => const GlideBasicCellBuffer(
      formatted: '#LOADING',
      rawValue: '',
      format: 'string',
    ),
    GlideProtectedCell() => const GlideBasicCellBuffer(
      formatted: '************',
      rawValue: '',
      format: 'string',
    ),
    // `GridCellKind.NewRow`/`Marker` are internal to the grid and never
    // appear in a selection upstream either.
    _ => const GlideBasicCellBuffer(formatted: '', rawValue: '', format: 'string'),
  };
}

/// `createBufferFromGridCells` (`copy-paste.ts:111-128`).
GlideCopyBuffer glideCreateBufferFromGridCells(
  List<List<GlideGridCell>> cells,
  List<int> columnIndexes,
) => [
  for (var index = 0; index < cells.length; index++)
    [
      for (var i = 0; i < cells[index].length; i++)
        () {
          final cell = cells[index][i];
          final span = cell.span;
          final mappedIndex = columnIndexes.isEmpty
              ? null
              : (index < columnIndexes.length ? columnIndexes[index] : null);
          if (span != null && mappedIndex != null && span.start != mappedIndex) {
            return const GlideBasicCellBuffer(
              formatted: '',
              rawValue: '',
              format: 'string',
            );
          }
          return glideConvertCellToBuffer(cell);
        }(),
    ],
];

String _escapeIfNeeded(String str, {required bool withComma}) {
  final pattern = withComma ? RegExp(r'[\t\n",]') : RegExp(r'[\t\n"]');
  if (pattern.hasMatch(str)) {
    return '"${str.replaceAll('"', '""')}"';
  }
  return str;
}

/// `createTextBuffer` (`copy-paste.ts:137-153`): TSV with RFC-4180 quoting.
String glideCreateTextBuffer(GlideCopyBuffer copyBuffer) {
  final lines = <String>[];
  for (final row in copyBuffer) {
    final line = <String>[];
    for (final cell in row) {
      if (cell is GlideStringArrayCellBuffer) {
        line.add([
          for (final x in cell.formatted) _escapeIfNeeded(x, withComma: true),
        ].join(','));
      } else {
        final basic = cell as GlideBasicCellBuffer;
        if (basic.format == 'url') {
          line.add(basic.rawValue?.toString() ?? '');
        } else {
          line.add(
            basic.doNotEscape
                ? basic.formatted
                : _escapeIfNeeded(basic.formatted, withComma: false),
          );
        }
      }
    }
    lines.add(line.join('\t'));
  }
  return lines.join('\n');
}

String _formatHtmlTextContent(String text) {
  // Tabs become four spaces (Google Sheets rejects tabs) and runs of spaces
  // are wrapped in spans so they survive the paste (`copy-paste.ts:155-162`).
  var result = text.replaceAll('\t', '    ');
  return result.replaceAllMapped(RegExp(r' {2,}'), (m) {
    final run = m.group(0)!;
    return List.filled(run.length, '<span> </span>').join();
  });
}

String _formatHtmlAttributeContent(String attrText) =>
    '"${attrText
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')}"';

/// `createHtmlBuffer` (`copy-paste.ts:180-216`).
String glideCreateHtmlBuffer(GlideCopyBuffer copyBuffer) {
  final lines = <String>[
    '<style type="text/css"><!--br {mso-data-placement:same-cell;}--></style>',
    '<table><tbody>',
  ];
  for (final row in copyBuffer) {
    lines.add('<tr>');
    for (final cell in row) {
      if (cell is GlideStringArrayCellBuffer) {
        final items = <String>[];
        for (var ind = 0; ind < cell.formatted.length; ind++) {
          items.add(
            '<li gdg-raw-value=${_formatHtmlAttributeContent(cell.rawValue[ind])}>'
            '${_formatHtmlTextContent(cell.formatted[ind])}</li>',
          );
        }
        lines.add(
          '<td gdg-format="string-array"><ol>${items.join()}</ol></td>',
        );
      } else {
        final basic = cell as GlideBasicCellBuffer;
        final formatStr = 'gdg-format="${basic.format}"';
        if (basic.format == 'url') {
          lines.add(
            '<td $formatStr><a href="${basic.rawValue}">'
            '${_formatHtmlTextContent(basic.formatted)}</a></td>',
          );
        } else {
          lines.add(
            '<td gdg-raw-value=${_formatHtmlAttributeContent(
              basic.rawValue?.toString() ?? '',
            )} $formatStr>${_formatHtmlTextContent(basic.formatted)}</td>',
          );
        }
      }
    }
    lines.add('</tr>');
  }
  lines.add('</tbody></table>');
  return lines.join();
}

/// `getCopyBufferContents` (`copy-paste.ts:223-237`).
({String textPlain, String textHtml}) glideGetCopyBufferContents(
  List<List<GlideGridCell>> cells,
  List<int> columnIndexes,
) {
  final copyBuffer = glideCreateBufferFromGridCells(cells, columnIndexes);
  return (
    textPlain: glideCreateTextBuffer(copyBuffer),
    textHtml: glideCreateHtmlBuffer(copyBuffer),
  );
}

/// `unquote` (`data-editor-fns.ts:107-166`): parses pasted TSV back into a
/// [GlideCopyBuffer].
///
/// The state machine maps one-to-one onto upstream's `State` enum; the
/// per-character `index` bookkeeping is kept so the slice boundaries match.
GlideCopyBuffer glideUnquote(String input) {
  const stateNone = 0;
  const stateInString = 1;
  const stateInStringPostQuote = 2;

  String descape(String s) {
    if (s.startsWith('"') && s.endsWith('"') && s.length >= 2) {
      s = s.substring(1, s.length - 1).replaceAll('""', '"');
    }
    return s;
  }

  final rows = <List<String>>[];
  var current = <String>[];

  var start = 0;
  var state = stateNone;
  final str = input.replaceAll('\r\n', '\n');
  var index = 0;
  for (final char in str.split('')) {
    switch (state) {
      case stateNone:
        if (char == '\t' || char == '\n') {
          current.add(str.substring(start, index));
          start = index + 1;
          if (char == '\n') {
            rows.add(current);
            current = [];
          }
        } else if (char == '"') {
          state = stateInString;
        }
      case stateInString:
        if (char == '"') state = stateInStringPostQuote;
      case stateInStringPostQuote:
        if (char == '"') {
          state = stateInString;
        } else if (char == '\t' || char == '\n') {
          current.add(descape(str.substring(start, index)));
          start = index + 1;
          if (char == '\n') {
            rows.add(current);
            current = [];
          }
          state = stateNone;
        } else {
          state = stateNone;
        }
    }
    index++;
  }
  if (start < str.length) {
    current.add(descape(str.substring(start, str.length)));
  }
  rows.add(current);

  return [
    for (final row in rows)
      [
        for (final c in row)
          GlideBasicCellBuffer(formatted: c, rawValue: c, format: 'string'),
      ],
  ];
}

/// `copyToClipboard` (`data-editor-fns.ts:168-215`).
///
/// Only `text/plain` is written; see the file header for why.
Future<void> glideCopyToClipboard(
  List<List<GlideGridCell>> cells,
  List<int> columnIndexes,
) async {
  final contents = glideGetCopyBufferContents(cells, columnIndexes);
  await Clipboard.setData(ClipboardData(text: contents.textPlain));
}

/// `restoreHtmlEntities` (`copy-paste.ts:171-178`).
String glideRestoreHtmlEntities(String str) => str
    .replaceAll('&quot;', '"')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&');

/// `decodeHTML` (`copy-paste.ts:239-320`).
///
/// Returns null when the payload has no `<table>`, matching upstream.
GlideCopyBuffer? glideDecodeHtml(String html) {
  final source = html.replaceAll('&nbsp;', ' ');
  if (_findFirstTag(source, 'table') == -1) return null;

  final result = <List<GlideCellBuffer>>[];
  List<GlideCellBuffer>? current;

  // Walk `<tr>` blocks; inside each, walk `<td>` blocks.
  final trPattern = RegExp(r'<tr[^>]*>', caseSensitive: false);
  final tdPattern = RegExp(r'<td([^>]*)>(.*?)</td>', caseSensitive: false,
      dotAll: true);

  for (final tr in trPattern.allMatches(source).toList()) {
    final rowStart = tr.end;
    final rowEnd = source.indexOf('</tr>', rowStart);
    final rowHtml = source.substring(
      rowStart,
      rowEnd == -1 ? source.length : rowEnd,
    );
    final cells = <GlideCellBuffer>[];
    for (final td in tdPattern.allMatches(rowHtml)) {
      cells.add(_decodeCell(td.group(1) ?? '', td.group(2) ?? ''));
    }
    if (cells.isNotEmpty) {
      if (current != null) result.add(current);
      current = cells;
    }
  }
  if (current != null) result.add(current);

  // Apple Numbers wraps the payload in `<p><font>`; strip the stray newlines
  // it emits between the `<br>` markers (`copy-paste.ts:266-304`).
  if (result.isEmpty) return null;
  return result;
}

GlideCellBuffer _decodeCell(String attributeText, String innerHtml) {
  var format = 'string';

  final rawMatch = RegExp(
    r'gdg-raw-value\s*=\s*"([^"]*)"',
    caseSensitive: false,
  ).firstMatch(attributeText);
  final formatMatch = RegExp(
    r'gdg-format\s*=\s*"([^"]*)"',
    caseSensitive: false,
  ).firstMatch(attributeText);
  if (formatMatch != null) format = formatMatch.group(1)!;

  var text = innerHtml;

  // `<br>` becomes a newline, as upstream does on the DOM clone.
  text = text.replaceAllMapped(
    RegExp(r'<br\s*/?>', caseSensitive: false),
    (_) => '\n',
  );

  final anchor = RegExp(
    r'<a[^>]*href\s*=\s*"([^"]*)"[^>]*>(.*?)</a>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(text);
  if (anchor != null) {
    return GlideBasicCellBuffer(
      rawValue: glideRestoreHtmlEntities(anchor.group(1)!),
      formatted: _stripTags(anchor.group(2)!),
      format: format,
    );
  }

  if (RegExp(r'<ol[^>]*>', caseSensitive: false).hasMatch(text)) {
    final items = RegExp(
      r'<li[^>]*gdg-raw-value\s*=\s*"([^"]*)"[^>]*>(.*?)</li>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(text);
    final raws = <String>[];
    final formatted = <String>[];
    for (final item in items) {
      raws.add(glideRestoreHtmlEntities(item.group(1)!));
      formatted.add(_stripTags(item.group(2)!));
    }
    return GlideStringArrayCellBuffer(formatted: formatted, rawValue: raws);
  }

  final plain = _stripTags(text).replaceAll('\n\n', '\n');
  if (rawMatch != null) {
    return GlideBasicCellBuffer(
      rawValue: glideRestoreHtmlEntities(rawMatch.group(1)!),
      formatted: plain,
      format: format,
    );
  }
  return GlideBasicCellBuffer(
    rawValue: plain,
    formatted: plain,
    format: format,
  );
}

String _stripTags(String html) {
  var out = html.replaceAll(RegExp(r'<[^>]*>'), '');
  out = out.replaceAll('&nbsp;', ' ');
  return out;
}

int _findFirstTag(String html, String tag) =>
    html.toLowerCase().indexOf('<$tag');
