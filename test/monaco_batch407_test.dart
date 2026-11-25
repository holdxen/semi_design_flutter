// 1:1 replay of
//   `editor/contrib/inlineCompletions/browser/model/computeGhostText.ts`.
// Truth: `tool/ts2dart/_batch407_truth.cjs` -> `batch407_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/edits/textEdit.dart'
    show TextReplacement;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/computeGhostText.dart';
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/singleTextEditHelpers.dart'
    show ITextModelForSingleTextEditHelpers;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch407_truth.json').readAsStringSync()),
    );

class _Model implements ITextModelForSingleTextEditHelpers {
  final String lineText;
  _Model(this.lineText);

  String getLineContent(int lineNumber) => lineText;

  @override
  String getValueInRange(Range range, [int? endOfLinePreference]) {
    if (range.startLineNumber != range.endLineNumber) return '';
    return lineText.substring(range.startColumn - 1, range.endColumn - 1);
  }
}

Object? _ghostJson(GhostText? g) => g == null
    ? null
    : <String, Object?>{
        'lineNumber': g.lineNumber,
        'parts': g.parts
            .map((GhostTextPart p) => <String, Object?>{
                  'column': p.column,
                  'text': p.text,
                  'preview': p.preview,
                })
            .toList(),
      };

/// Cases mirrored from the truth harness. Each entry carries the exact inputs;
/// only expected outputs are read from truth JSON.
final List<Map<String, dynamic>> _cases = <Map<String, dynamic>>[
  <String, dynamic>{
    'label': 'prefix-insert',
    'line': 'hello',
    'startColumn': 6,
    'endColumn': 6,
    'text': ' world',
    'mode': 'prefix',
  },
  <String, dynamic>{
    'label': 'prefix-replace',
    'line': 'hel',
    'startColumn': 1,
    'endColumn': 4,
    'text': 'hello',
    'mode': 'prefix',
  },
  <String, dynamic>{
    'label': 'prefix-invalid',
    'line': 'abc',
    'startColumn': 1,
    'endColumn': 4,
    'text': 'axcxc',
    'mode': 'prefix',
  },
  <String, dynamic>{
    'label': 'subword-brackets',
    'line': 'if ()',
    'startColumn': 4,
    'endColumn': 4,
    'text': 'if (f() = 1) { g(); }',
    'mode': 'subword',
  },
  <String, dynamic>{
    'label': 'subword-smart-cursor',
    'line': 'foo',
    'startColumn': 1,
    'endColumn': 4,
    'text': 'foobar',
    'mode': 'subwordSmart',
    'cursorColumn': 10,
  },
  <String, dynamic>{
    'label': 'preview-suffix',
    'line': 'hell',
    'startColumn': 5,
    'endColumn': 5,
    'text': 'hello',
    'mode': 'subword',
    'previewSuffixLength': 2,
  },
  <String, dynamic>{
    'label': 'indent',
    'line': '  abc',
    'startColumn': 1,
    'endColumn': 6,
    'text': '    xyz',
    'mode': 'subword',
  },
  <String, dynamic>{
    'label': 'deletion',
    'line': 'abcd',
    'startColumn': 2,
    'endColumn': 4,
    'text': '',
    'mode': 'subword',
  },
];

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> truthResults = <String, dynamic>{
    for (final dynamic r in truth['results'] as List<dynamic>)
      (r as Map)['label'] as String: r['result'],
  };

  test('compute ghost text replay TS truth', () {
    for (final Map<String, dynamic> c in _cases) {
      final String label = c['label'] as String;
      final TextReplacement edit = TextReplacement(
        Range(1, c['startColumn'] as int, 1, c['endColumn'] as int),
        c['text'] as String,
      );
      final _Model model = _Model(c['line'] as String);
      final Position? cursor = c['cursorColumn'] == null
          ? null
          : Position(1, c['cursorColumn'] as int);
      final GhostText? result = computeGhostText(
        edit,
        model,
        c['mode'] as String,
        cursor,
        (c['previewSuffixLength'] ?? 0) as int,
      );
      expect(
        jsonEncode(_ghostJson(result)),
        jsonEncode(truthResults[label]),
        reason: 'mismatch at $label',
      );
    }

    // Multi-line edit -> undefined.
    final GhostText? multiline = computeGhostText(
      TextReplacement(Range(1, 1, 2, 1), 'x'),
      _Model('abc'),
      'subword',
    );
    expect(
      jsonEncode(_ghostJson(multiline)),
      jsonEncode(truthResults['multiline']),
      reason: 'mismatch at multiline',
    );
  });
}
