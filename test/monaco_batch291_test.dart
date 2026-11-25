// batch291: linesLayout.ts truth replay.
// Truth from tool/ts2dart/batch291_truth.json (recursive TS transpile + vm,
// real LinesLayout with whitespace / custom line height mutation sequences).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/lineHeights.dart'
    show CustomLineHeightData;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/linesLayout.dart'
    show
        EditorWhitespace,
        LinesLayout,
        PartialViewLinesViewportData,
        ViewWhitespaceViewportData;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch291_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) => MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

int _i(Object? v) => (v as num).toInt();
num _n(Object? v) => v as num;

/// Generated whitespace ids are normalized to w1/w2/... per case, matching the
/// truth harness (which also hides the module-level INSTANCE_COUNT).
class _Ids {
  final Map<String, String> _byLabel = <String, String>{};
  final Map<String, String> _byId = <String, String>{};
  int _next = 0;

  String add(String id) {
    final String label = 'w${++_next}';
    _byLabel[label] = id;
    _byId[id] = label;
    return label;
  }

  String id(String label) => _byLabel[label]!;
  String label(String id) => _byId[id] ?? id;
}

Map<String, Object?> _whitespaceJson(EditorWhitespace w, _Ids ids) =>
    <String, Object?>{
      'id': ids.label(w.id),
      'afterLineNumber': w.afterLineNumber,
      'ordinal': w.ordinal,
      'height': w.height,
      'minWidth': w.minWidth,
      'prefixSum': w.prefixSum,
    };

Map<String, Object?> _viewData(ViewWhitespaceViewportData d, _Ids ids) =>
    <String, Object?>{
      'id': ids.label(d.id),
      'afterLineNumber': d.afterLineNumber,
      'verticalOffset': d.verticalOffset,
      'height': d.height,
    };

Map<String, Object?> _viewportData(
        PartialViewLinesViewportData d, _Ids ids) =>
    <String, Object?>{
      'bigNumbersDelta': d.bigNumbersDelta,
      'startLineNumber': d.startLineNumber,
      'endLineNumber': d.endLineNumber,
      'relativeVerticalOffset': d.relativeVerticalOffset,
      'centeredLineNumber': d.centeredLineNumber,
      'completelyVisibleStartLineNumber': d.completelyVisibleStartLineNumber,
      'completelyVisibleEndLineNumber': d.completelyVisibleEndLineNumber,
      'lineHeight': d.lineHeight,
    };

Map<String, Object?> _snapshot(
    LinesLayout layout, int lineCount, String label, _Ids ids) {
  final List<Object?> lines = <Object?>[];
  for (int line = 1; line <= lineCount + 2; line++) {
    lines.add(<String, Object?>{
      'line': line,
      'height': layout.getLineHeightForLineNumber(line),
      'before': layout.getVerticalOffsetForLineNumber(line),
      'beforeZones': layout.getVerticalOffsetForLineNumber(line, true),
      'after': layout.getVerticalOffsetAfterLineNumber(line),
      'afterZones': layout.getVerticalOffsetAfterLineNumber(line, true),
    });
  }
  final List<Object?> offsets = <int>[
    0, 3, 10, 20, 37, 60, 100, 175, 300, 600,
  ].map((int o) {
    final ViewWhitespaceViewportData? at =
        layout.getWhitespaceAtVerticalOffset(o);
    return <String, Object?>{
      'offset': o,
      'line': layout.getLineNumberAtOrAfterVerticalOffset(o),
      'wsIndex': layout.getWhitespaceIndexAtOrAfterVerticallOffset(o),
      'at': at == null ? null : _viewData(at, ids),
      'isAfterLines': layout.isAfterLines(o),
      'top': layout.isInTopPadding(o),
      'bottom': layout.isInBottomPadding(o),
    };
  }).toList();
  final List<Object?> viewports = <List<int>>[
    <int>[0, 100],
    <int>[30, 155],
    <int>[100, 400],
    <int>[300, 900],
  ].map((List<int> pair) {
    final int a = pair[0];
    final int b = pair[1];
    return <String, Object?>{
      'range': <Object?>[a, b],
      'lines': _viewportData(layout.getLinesViewportData(a, b), ids),
      'ws': layout
          .getWhitespaceViewportData(a, b)
          .map((d) => _viewData(d, ids))
          .toList(),
    };
  }).toList();
  return <String, Object?>{
    'label': label,
    'whitespaces': layout
        .getWhitespaces()
        .map((w) => _whitespaceJson(w, ids))
        .toList(),
    'count': layout.getWhitespacesCount(),
    'hasWhitespace': layout.hasWhitespace(),
    'totalWhitespaceHeight': layout.getWhitespacesTotalHeight(),
    'totalHeight': layout.getLinesTotalHeight(),
    'minWidth': layout.getWhitespaceMinWidth(),
    'lines': lines,
    'offsets': offsets,
    'viewports': viewports,
  };
}

List<CustomLineHeightData> _customData(Object? raw) =>
    ((raw as List<dynamic>?) ?? <dynamic>[]).map((dynamic d) {
      final Map<String, dynamic> m = d as Map<String, dynamic>;
      return CustomLineHeightData(
        m['decorationId'] as String,
        _i(m['startLineNumber']),
        _i(m['endLineNumber']),
        _n(m['lineHeight']),
      );
    }).toList();

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch291 linesLayout truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final Map<String, dynamic> config = c['config'] as Map<String, dynamic>;
        final _Ids ids = _Ids();
        final LinesLayout layout = LinesLayout(
          _i(config['lineCount']),
          _n(config['defaultLineHeight']),
          _n(config['paddingTop']),
          _n(config['paddingBottom']),
          _customData(config['custom']),
        );
        int lineCount = _i(config['lineCount']);
        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        int resultIndex = 0;

        for (final dynamic rawOp in ops) {
          final Map<String, dynamic> op = rawOp as Map<String, dynamic>;
          final String kind = op['kind'] as String;
          final String label = op['label'] as String;
          late Map<String, Object?> snap;
          switch (kind) {
            case 'snapshot':
              snap = _snapshot(layout, lineCount, label, ids);
              break;
            case 'whitespace':
              final List<String> inserted = <String>[];
              layout.changeWhitespace((accessor) {
                for (final dynamic rawAction in op['actions'] as List<dynamic>) {
                  final Map<String, dynamic> a = rawAction as Map<String, dynamic>;
                  switch (a['type'] as String) {
                    case 'insert':
                      final String realId = accessor.insertWhitespace(
                        _i(a['after']),
                        _i(a['ordinal']),
                        _n(a['height']),
                        _n(a['minWidth']),
                      );
                      inserted.add(ids.add(realId));
                      break;
                    case 'change':
                      accessor.changeOneWhitespace(
                        ids.id(a['id'] as String),
                        _i(a['after']),
                        _n(a['height']),
                      );
                      break;
                    case 'remove':
                      accessor.removeWhitespace(ids.id(a['id'] as String));
                      break;
                    default:
                      fail('unknown whitespace action ${a['type']}');
                  }
                }
              });
              snap = _snapshot(layout, lineCount, label, ids);
              snap['inserted'] = inserted;
              break;
            case 'lineHeights':
              final bool changed = layout.changeLineHeights((accessor) {
                for (final dynamic rawAction in op['actions'] as List<dynamic>) {
                  final Map<String, dynamic> a = rawAction as Map<String, dynamic>;
                  if (a['type'] == 'insert') {
                    accessor.insertOrChangeCustomLineHeight(
                      a['id'] as String,
                      _i(a['start']),
                      _i(a['end']),
                      _n(a['height']),
                    );
                  } else {
                    accessor.removeCustomLineHeight(a['id'] as String);
                  }
                }
              });
              snap = _snapshot(layout, lineCount, label, ids);
              snap['changed'] = changed;
              break;
            case 'defaultLineHeight':
              layout.setDefaultLineHeight(_n(op['value']));
              snap = _snapshot(layout, lineCount, label, ids);
              break;
            case 'padding':
              layout.setPadding(_n(op['top']), _n(op['bottom']));
              snap = _snapshot(layout, lineCount, label, ids);
              break;
            case 'deleteLines':
              layout.onLinesDeleted(_i(op['from']), _i(op['to']));
              lineCount -= (_i(op['to']) - _i(op['from']) + 1);
              snap = _snapshot(layout, lineCount, label, ids);
              break;
            case 'insertLines':
              layout.onLinesInserted(_i(op['from']), _i(op['to']));
              lineCount += (_i(op['to']) - _i(op['from']) + 1);
              snap = _snapshot(layout, lineCount, label, ids);
              break;
            case 'flush':
              layout.onFlushed(_i(op['lineCount']), _customData(op['custom']));
              lineCount = _i(op['lineCount']);
              snap = _snapshot(layout, lineCount, label, ids);
              break;
            default:
              fail('unknown op $kind');
          }
          expect(snap, _norm(results[resultIndex++] as Object?));
        }
        expect(resultIndex, results.length);
      });
    }
  });
}
