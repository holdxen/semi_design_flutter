// 1:1 replay of the batch253 viewModel subsystem:
//   - editor/common/viewModel/glyphLanesModel.ts
//   - editor/common/coordinatesConverter.ts
//
// `tool/ts2dart/_batch253_truth.cjs` recursively transpiles and executes the
// real TypeScript modules + Range/Position/GlyphMarginLane/PositionAffinity
// (no stubs) and records:
//   * glyphLanesModel: push/reset ops + requiredLanes snapshots + lanes at
//     lines (covering all upstream glyphLanesModel.test.ts cases + extras).
//   * coordinatesConverter: IdentityCoordinatesConverter driven by a
//     structural ITextModel mock (the TS interface is erased). The same mock
//     semantics are reproduced here on the Dart side.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/coordinatesConverter.dart';
import '../lib/src/monaco/editor/common/core/position.dart';
import '../lib/src/monaco/editor/common/core/range.dart';
import '../lib/src/monaco/editor/common/viewModel/glyphLanesModel.dart';

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch253_truth.json').readAsStringSync()));

bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_same(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

// Structural ITextModel mock matching the truth harness exactly.
class _MockModel implements ITextModelForCoordinatesConverter {
  final int lineCount;
  final int maxColumn;
  _MockModel(this.lineCount, this.maxColumn);

  @override
  int getLineCount() => lineCount;

  @override
  Position validatePosition(Position pos) {
    final int ln = pos.lineNumber < 1
        ? 1
        : (pos.lineNumber > lineCount ? lineCount : pos.lineNumber);
    final int col = pos.column < 1
        ? 1
        : (pos.column > maxColumn ? maxColumn : pos.column);
    return Position(ln, col);
  }

  @override
  Range validateRange(Range range) {
    Position a = validatePosition(Position(range.startLineNumber, range.startColumn));
    Position b = validatePosition(Position(range.endLineNumber, range.endColumn));
    if (b.lineNumber < a.lineNumber ||
        (b.lineNumber == a.lineNumber && b.column < a.column)) {
      final Position t = a;
      a = b;
      b = t;
    }
    return Range(a.lineNumber, a.column, b.lineNumber, b.column);
  }
}

List<dynamic> _pos(Position p) => [p.lineNumber, p.column];
List<dynamic> _range(Range r) => [
      r.startLineNumber, r.startColumn, r.endLineNumber, r.endColumn,
    ];

void main() {
  final truth = _truth();

  group('batch253 glyphLanesModel', () {
    for (final raw in (truth['glyph'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final int initialMaxLine = (c['initialMaxLine'] as num).toInt();
        final model = GlyphMarginLanesModel(initialMaxLine);

        final snapshots = <int>[];
        for (final opRaw in (c['ops'] as List)) {
          final op = _map(opRaw);
          switch (op['kind'] as String) {
            case 'push':
              model.push(
                (op['lane'] as num).toInt(),
                Range((op['s'] as num).toInt(), 1, (op['e'] as num).toInt(), 1),
                op['persist'] == true,
              );
              break;
            case 'reset':
              model.reset((op['maxLine'] as num).toInt());
              break;
            default:
              throw StateError('unknown op: ${op['kind']}');
          }
          snapshots.add(model.requiredLanes);
        }

        expect(_same(snapshots, c['requiredSnapshots']), isTrue,
            reason: '${c['label']} requiredSnapshots');
        expect(model.requiredLanes, equals(c['requiredFinal']),
            reason: '${c['label']} requiredFinal');

        for (final qRaw in (c['lanes'] as List)) {
          final q = _map(qRaw);
          final int from = (q['from'] as num).toInt();
          final int n = (q['n'] as num).toInt();
          final rows = <List<int>>[];
          for (var i = 0; i < n; i++) {
            rows.add(model.getLanesAtLine(from + i));
          }
          expect(_same(rows, q['rows']), isTrue,
              reason: '${c['label']} lanes from=$from n=$n');
        }
      });
    }
  });

  group('batch253 coordinatesConverter', () {
    for (final raw in (truth['coord'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final model = _MockModel(10, 20);
        final conv = IdentityCoordinatesConverter(model);
        final result = _coordResult(conv, c['label'] as String);
        expect(_same(result, c['result']), isTrue,
            reason: '${c['label']} result');
      });
    }
  });
}

dynamic _coordResult(IdentityCoordinatesConverter c, String label) {
  switch (label) {
    case 'view-pos-to-model-in-range':
      return _pos(c.convertViewPositionToModelPosition(Position(3, 5)));
    case 'view-pos-to-model-clamped':
      return _pos(c.convertViewPositionToModelPosition(Position(99, 999)));
    case 'view-pos-to-model-min':
      return _pos(c.convertViewPositionToModelPosition(Position(0, 0)));
    case 'view-range-to-model':
      return _range(c.convertViewRangeToModelRange(Range(2, 3, 5, 8)));
    case 'view-range-to-model-clamped':
      return _range(c.convertViewRangeToModelRange(Range(99, 99, 1, 1)));
    case 'validate-view-position':
      return _pos(c.validateViewPosition(Position(1, 1), Position(4, 7)));
    case 'validate-view-range':
      return _range(c.validateViewRange(Range(1, 1, 2, 2), Range(6, 6, 8, 9)));
    case 'model-pos-to-view':
      return _pos(c.convertModelPositionToViewPosition(Position(7, 12)));
    case 'model-range-to-view':
      return _range(c.convertModelRangeToViewRange(Range(3, 4, 6, 10)));
    case 'visible-pos-valid':
      return c.modelPositionIsVisible(Position(1, 1));
    case 'visible-pos-last':
      return c.modelPositionIsVisible(Position(10, 1));
    case 'visible-pos-too-low':
      return c.modelPositionIsVisible(Position(0, 1));
    case 'visible-pos-too-high':
      return c.modelPositionIsVisible(Position(11, 1));
    case 'visible-range-valid':
      return c.modelRangeIsVisible(Range(1, 1, 10, 20));
    case 'visible-range-start-bad':
      return c.modelRangeIsVisible(Range(0, 1, 5, 1));
    case 'visible-range-end-bad':
      return c.modelRangeIsVisible(Range(1, 1, 11, 1));
    case 'model-line-view-line-count':
      return c.getModelLineViewLineCount(5);
    case 'view-line-number-of-model-pos':
      return c.getViewLineNumberOfModelPosition(5, 8);
    default:
      throw StateError('unknown coord label: $label');
  }
}
