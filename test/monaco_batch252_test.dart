// 1:1 replay of `editor/contrib/smartSelect/browser/wordSelections.ts`.
//
// `tool/ts2dart/_batch252_truth.cjs` recursively transpiles and executes the
// real TypeScript module + Range/Position/CharCode/strings/wordHelper (no
// stubs) and drives the provider with a structural ITextModel mock whose
// `getWordAtPosition` uses the REAL `getWordAtText` and the exact wordPattern
// from the upstream smartSelect source test.
//
// Replayed here with the equivalent Dart `getWordAtText` + RegExp, so both
// sides share a 1:1 word-boundary implementation.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/position.dart';
import '../lib/src/monaco/editor/common/core/range.dart';
import '../lib/src/monaco/editor/common/core/wordHelper.dart';
import '../lib/src/monaco/editor/contrib/smartSelect/browser/wordSelections.dart';

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch252_truth.json').readAsStringSync()));

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

List<dynamic> _range(IRange r) => [
      r.startLineNumber, r.startColumn, r.endLineNumber, r.endColumn,
    ];

List<dynamic> _ranges(List<SelectionRange> buckets) =>
    buckets.map((sr) => _range(sr.range)).toList();

// Exact wordPattern from smartSelect.test.ts setup (same as truth harness).
final RegExp _wordPattern = RegExp(
  r'''(-?\d*\.\d\w*)|([^\`\~\!\@\#\$\%\^\&\*\(\)\=\+\[\{\]\}\\\;\:\'\"\,\.\<\>\/\?\s]+)''',
);

class _MockWordModel implements IWordSelectionModel {
  _MockWordModel(this._lines);
  final List<String> _lines;

  @override
  IRange getFullModelRange() =>
      Range(1, 1, _lines.length, _lines[_lines.length - 1].length + 1);

  @override
  IWordAtPosition? getWordAtPosition(Position pos) {
    // A fresh WordDefinition per call resets the mutable `lastIndex`, matching
    // TS `ensureValidWordDefinition` behaviour for a fresh regex literal.
    return getWordAtText(pos.column, WordDefinition(_wordPattern), _lines[pos.lineNumber - 1], 0);
  }

  @override
  int getLineLength(int lineNumber) => _lines[lineNumber - 1].length;

  @override
  int getLineFirstNonWhitespaceColumn(int lineNumber) {
    final m = RegExp(r'\S').firstMatch(_lines[lineNumber - 1]);
    return m == null ? 0 : m.start + 1;
  }

  @override
  int getLineLastNonWhitespaceColumn(int lineNumber) {
    final m = RegExp(r'\S\s*$').firstMatch(_lines[lineNumber - 1]);
    return m == null ? 0 : m.start + 1;
  }

  @override
  int getLineMaxColumn(int lineNumber) => _lines[lineNumber - 1].length + 1;
}

void main() {
  final t = _truth();

  void checkCase(Map<String, dynamic> c, bool selectSubwords) {
    test(c['label'] as String, () {
      final input = _map(c['input']);
      final value = input['value'] as String;
      final idx = value.indexOf('|');
      final text = value.replaceFirst('|', '');
      final model = _MockWordModel([text]);
      final provider = WordSelectionRangeProvider(selectSubwords);
      final ranges = provider.provideSelectionRanges(model, [Position(1, idx + 1)]);
      final actual = _ranges(ranges[0]);
      expect(_same(actual, c['ranges']), isTrue,
          reason: '${c['label']}: expected ${c['ranges']}, got $actual');
    });
  }

  group('batch252: WordSelectionRangeProvider (selectSubwords=true)', () {
    for (final raw in (t['withSubwords'] as List)) {
      checkCase(_map(raw), true);
    }
  });

  group('batch252: WordSelectionRangeProvider (selectSubwords=false)', () {
    for (final raw in (t['withoutSubwords'] as List)) {
      checkCase(_map(raw), false);
    }
  });

  test('whitespace-only line contributes full line', () {
    final model = _MockWordModel(['    ']);
    final provider = WordSelectionRangeProvider();
    final actual = _ranges(provider.provideSelectionRanges(model, [Position(1, 3)])[0]);
    expect(_same(actual, t['whitespaceLine']), isTrue,
        reason: 'expected ${t['whitespaceLine']}, got $actual');
  });

  test('multiple positions', () {
    final model = _MockWordModel(['fooBar baz']);
    final provider = WordSelectionRangeProvider();
    final buckets = provider.provideSelectionRanges(model, [Position(1, 2), Position(1, 9)]);
    final actual = buckets.map((b) => _ranges([...b])).toList();
    expect(_same(actual, t['multiPositions']), isTrue,
        reason: 'expected ${t['multiPositions']}, got $actual');
  });
}
